#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3",
	"vo/engineer_standonthepoint03.mp3",
	"vo/engineer_standonthepoint04.mp3",
};


void VictorianMechanist_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/player/engineer.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mechanist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mechanist");
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "engineer"); 		//leaderboard_class_(insert the name)
	data.IconCustom = false;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianMechanist(client, vecPos, vecAng, ally);
}

static int i_overcharge[MAXENTITIES];

methodmap VictorianMechanist < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	
	public VictorianMechanist(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictorianMechanist npc = view_as<VictorianMechanist>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.2", "12500", ally));
		
		i_NpcWeight[npc.index] = 3;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 250.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.Anger = false;
		npc.m_flNextRangedAttack = 10.0;
		
		i_overcharge[npc.index] = 0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 100, 255);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum23_cranium_cooler/sum23_cranium_cooler.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 100, 100, 100, 255);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_sleuth_suit_style3/dec23_sleuth_suit_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_contaminated_carryall/hwn2024_contaminated_carryall.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable7 = npc.EquipItem("head", "models/weapons/c_models/c_pda_engineer/c_pda_engineer.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	VictorianMechanist npc = view_as<VictorianMechanist>(iNPC);
	
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(npc.m_flJumpStartTime < GameTime)
		{
			npc.m_flSpeed = 170.0;
		}
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		
		if(flDistanceToTarget < 1562500)	//1250 range
		{
			if(npc.m_flNextRangedAttack < GameTime)
			{
				npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
				npc.m_flNextRangedAttack = GameTime + 45.0;

				int health = ReturnEntityMaxHealth(npc.index) * 5;

				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				
				if(MaxEnemiesAllowedSpawnNext(1) > EnemyNpcAlive)
				{
					int entity = NPC_CreateByName("npc_avangard", -1, pos, ang, GetTeam(npc.index));
					if(entity > MaxClients)
					{
						NpcAddedToZombiesLeftCurrently(entity, true);
						SetEntProp(entity, Prop_Data, "m_iHealth", health);
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
						view_as<CClotBody>(entity).m_flNextThinkTime = GetGameTime(entity) + 8.0;
					}
				}
				else
				{
					npc.m_flNextRangedAttack = 0.0;
				}
			}
			if(flDistanceToTarget < 255000) //too close, back off!! Now! /uhhh something range
			{
				npc.StartPathing();
				
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see. oh shit, I don't have eyes (how do I see? *googles how to see*)
				{
					float vBackoffPos[3];
					
					BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
					
					NPC_SetGoalVector(npc.index, vBackoffPos, true);
				}
			}
			else
			{
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				else
				{
					npc.StartPathing();
				}
			}
		}
		else
		{
			npc.StartPathing();
		}
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			/*
			int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);
			*/
			
			
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} else {
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianMechanist npc = view_as<VictorianMechanist>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	VictorianMechanist npc = view_as<VictorianMechanist>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}