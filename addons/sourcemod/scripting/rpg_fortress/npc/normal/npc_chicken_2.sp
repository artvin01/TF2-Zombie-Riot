#pragma semicolon 1
#pragma newdecls required



public void StartChicken_OnMapStart_NPC()
{
	PrecacheModel("models/player/scout.mdl");
}

methodmap StartChicken < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		char buffer[PLATFORM_MAX_PATH];
		Format(buffer, sizeof(buffer), "vo/taunts/scout_taunts%d.mp3", GetRandomInt(19, 22));
		EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 75, _, 1.0, GetRandomInt(125, 135));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		char buffer[PLATFORM_MAX_PATH];
		Format(buffer, sizeof(buffer), "vo/scout_painsharp0%d.mp3", GetRandomInt(1, 8));
		EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 75, _, 1.0, GetRandomInt(125, 135));
		this.m_flNextHurtSound = GetGameTime() + GetRandomFloat(0.6, 1.6);
		
	}
	
	
	public StartChicken(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		StartChicken npc = view_as<StartChicken>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "0.5", "300", ally, false,_,_,_,{8.0,8.0,16.0}));
		
		i_NpcInternalId[npc.index] = START_CHICKEN;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = 120.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, StartChicken_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, StartChicken_ClotThink);
		
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

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.StartPathing();
		
		return npc;
	}
	
}

//TODO 
//Rewrite
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
		npc.m_flNextTargetTime = 0.0; //Run!!
	}
	npc.PlayIdleSound();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
		
	//Roam while idle
		
	//Is it time to pick a new place to go?
	if(npc.m_flNextTargetTime < GetGameTime(npc.index))
	{
		//Pick a random goal area
		NavArea RandomArea = PickRandomArea();	
			
		if(RandomArea == NavArea_Null) 
			return;
			
		float vecGoal[3]; RandomArea.GetCenter(vecGoal);
		
		if(!PF_IsPathToVectorPossible(iNPC, vecGoal))
			return;
			
		PF_SetGoalVector(iNPC, vecGoal);
		PF_StartPathing(iNPC);
			
		//Timeout
		npc.m_flNextTargetTime = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
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

	SDKUnhook(entity, SDKHook_OnTakeDamage, StartChicken_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, StartChicken_ClotThink);
}


