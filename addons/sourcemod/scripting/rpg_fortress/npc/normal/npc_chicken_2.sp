#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSound[][] = {
	"vo/taunts/scout_taunts19.mp3",
	"vo/taunts/scout_taunts20.mp3",
	"vo/taunts/scout_taunts21.mp3",
	"vo/taunts/scout_taunts22.mp3",
};

static const char g_HurtSound[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};


public void StartChicken_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	PrecacheModel("models/player/scout.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chicken");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chicken_2");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return StartChicken(vecPos, vecAng, team);
}

methodmap StartChicken < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,GetRandomInt(125, 135));

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,GetRandomInt(125, 135));
		
	}
	
	
	public StartChicken(float vecPos[3], float vecAng[3], int ally)
	{
		StartChicken npc = view_as<StartChicken>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "0.5", "300", ally, false,_,_,_,{16.0,16.0,36.0}));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_bDissapearOnDeath = true;
		npc.m_flSpeed = 120.0;

		npc.m_bisWalking = false;

		int skin = GetRandomInt(0, 1);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_nugget_noggin/sf14_nugget_noggin.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_fowl_fists/sf14_fowl_fists.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_talon_trotters/sf14_talon_trotters.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetVariantInt(7);
		AcceptEntityInput(npc.index, "SetBodyGroup");


		func_NPCDeath[npc.index] = StartChicken_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = StartChicken_OnTakeDamage;
		func_NPCThink[npc.index] = StartChicken_ClotThink;
		
		npc.StartPathing();
		
		return npc;
	}
	
}


public void StartChicken_ClotThink(int iNPC)
{
	StartChicken npc = view_as<StartChicken>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
		npc.m_flNextMeleeAttack = 0.0; //Run!!
	}
	npc.PlayIdleSound();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly, also happens when they stop follwing.
	{
		npc.m_flSpeed = 0.0;

		if(npc.m_bPathing)
		{
			npc.StopPathing();
				
		}
	}
	else
	{
		npc.m_flSpeed = 120.0;

		if(!npc.m_bPathing)
			npc.StartPathing();
	}

	float vecTarget[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);

	float fl_DistanceToOriginalSpawn = GetVectorDistance(vecTarget, f3_PositionArrival[npc.index], true);
	if(fl_DistanceToOriginalSpawn < (80.0 * 80.0)) //We are too far away from our home! return!
	{
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_STAND_MELEE");
	}
	
		
	//Roam while idle
		
	//Is it time to pick a new place to go?
	if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
	{
		//Pick a random goal area
	//	CNavArea RandomArea = PickRandomArea();	
			
	//	if(RandomArea == NULL_AREA) 
	//		return;

		float AproxRandomSpaceToWalkTo[3];

		AproxRandomSpaceToWalkTo[0] = f3_SpawnPosition[npc.index][0];
		AproxRandomSpaceToWalkTo[1] = f3_SpawnPosition[npc.index][1];
		AproxRandomSpaceToWalkTo[2] = f3_SpawnPosition[npc.index][2];

		AproxRandomSpaceToWalkTo[2] += 20.0;

		AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 400.0),(AproxRandomSpaceToWalkTo[0] + 400.0));
		AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 400.0),(AproxRandomSpaceToWalkTo[1] + 400.0));
		
	//	if(!PF_IsPathToVectorPossible(iNPC, AproxRandomSpaceToWalkTo))
	//		return;
		
		Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
		TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
		delete ToGroundTrace;

		npc.m_bisWalking = true;

		npc.SetActivity("ACT_MP_RUN_MELEE");

		view_as<CClotBody>(iNPC).StartPathing();
		view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);

		f3_PositionArrival[iNPC][0] = AproxRandomSpaceToWalkTo[0];
		f3_PositionArrival[iNPC][1] = AproxRandomSpaceToWalkTo[1];
		f3_PositionArrival[iNPC][2] = AproxRandomSpaceToWalkTo[2];
			
		//Timeout
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
	}
}

public Action StartChicken_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	StartChicken npc = view_as<StartChicken>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void StartChicken_NPCDeath(int entity)
{
	StartChicken npc = view_as<StartChicken>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


