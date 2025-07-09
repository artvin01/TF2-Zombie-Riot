#pragma semicolon 1
#pragma newdecls required

static const char SoundMoabHit[][] =
{
	"zombie_riot/btd/hitmoab01.wav",
	"zombie_riot/btd/hitmoab02.wav",
	"zombie_riot/btd/hitmoab03.wav",
	"zombie_riot/btd/hitmoab04.wav"
};

static const char SoundZomgPop[][] =
{
	"zombie_riot/btd/zomgdestroyed01.wav",
	"zombie_riot/btd/zomgdestroyed02.wav"
};

static float MoabSpeed()
{
	if(CurrentRound < 80)
		return 150.0;
	
	if(CurrentRound < 100)
		return 150.0 * (1.0 + (CurrentRound - 79) * 0.02);
	
	return 150.0 * (1.0 + (CurrentRound - 70) * 0.02);
}

static int MoabHealth(bool fortified)
{
	float value = 20000.0;	// 20000 RGB
	value *= BLOON_HP_MULTI_GLOBAL;
	if(IsValidEntity(RaidBossActive))
		value *= 0.8;
	
	if(fortified)
		value *= 2.0;
	
	if(CurrentRound > 123)
	{
		value *= 1.05 + (CurrentRound - 106) * 0.15;
	}
	else if(CurrentRound > 99)
	{
		value *= 1.0 + (CurrentRound - 71) * 0.05;
	}
	else if(CurrentRound > 79)
	{
		value *= 1.0 + (CurrentRound - 79) * 0.02;
	}
	
	return RoundFloat(value * Bloon_BaseHealth());
}

void Bad_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Big Airship of Doom");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bad");
	strcopy(data.Icon, sizeof(data.Icon), "special_blimp");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_BTD;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for(int i; i<sizeof(SoundZomgPop); i++)
	{
		PrecacheSoundCustom(SoundZomgPop[i]);
	}
	for(int i; i<sizeof(SoundMoabHit); i++)
	{
		PrecacheSoundCustom(SoundMoabHit[i]);
	}
	
	PrecacheModel("models/zombie_riot/btd/bad.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Bad(vecPos, vecAng, team, data);
}

methodmap Bad < CClotBody
{
	property bool m_bFortified
	{
		public get()
		{
			return this.m_bLostHalfHealth;
		}
		public set(bool value)
		{
			this.m_bLostHalfHealth = value;
		}
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabHit) - 1);
		EmitCustomToAll(SoundMoabHit[sound], this.index, SNDCHAN_VOICE, 80, _, 2.0);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundZomgPop) - 1);
		EmitCustomToAll(SoundZomgPop[sound], this.index, SNDCHAN_AUTO, 80, _, 2.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public Bad(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		Bad npc = view_as<Bad>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bad.mdl", "1.0", buffer, ally, false, true));
		
		i_NpcWeight[npc.index] = 5;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = STEPTYPE_NONE;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		
		func_NPCDeath[npc.index] = Bad_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Bad_OnTakeDamage;
		func_NPCThink[npc.index] = Bad_ClotThink;
		npc.m_flSpeed = MoabSpeed();
		npc.m_bFortified = fortified;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDoNotGiveWaveDelay = true;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bad_ClotDamagedPost);
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void Bad_ClotThink(int iNPC)
{
	Bad npc = view_as<Bad>(iNPC);
	
	if(npc.m_bFortified)
	{
		SetVariantInt(1);
		AcceptEntityInput(iNPC, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
													
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			
			float VecPredictPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, VecPredictPos);
			npc.SetGoalVector(VecPredictPos);
		}
		else
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		if(flDistanceToTarget < 20000)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
				float damageDealDo = 100.0;
				
				if(npc.m_bFortified)
					damageDealDo *= 1.4;
				if(ShouldNpcDealBonusDamage(PrimaryThreatIndex))
					damageDealDo *= 25.0;
					
				SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, npc.index, damageDealDo, DMG_CLUB, -1, _, WorldSpaceVec);				
			}
		}
		npc.StartPathing();
		
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bad_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bad npc = view_as<Bad>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bad_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Bad npc = view_as<Bad>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bad_NPCDeath(int entity)
{
	Bad npc = view_as<Bad>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bad_ClotDamagedPost);
	
	
	int team = GetTeam(entity);
	
	float pos[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	for(int i; i<3; i++)
	{
		int spawn_index = NPC_CreateByName("npc_ddt", -1, pos, angles, team, npc.m_bFortified ? "f" : "");
		ScalingMultiplyEnemyHpGlobalScale(spawn_index);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
		NpcStats_CopyStats(npc.index, spawn_index);
	}
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/bad.mdl");
		DispatchKeyValue(entity_death, "skin", "4");
		if(npc.m_bFortified)
			DispatchKeyValue(entity_death, "body", "1");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		SetEntProp(entity_death, Prop_Send, "m_iTeamNum", team);
		
		pos[2] += 20.0;
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", npc.m_bFortified ? Bad_PostFortifiedDeath : Bad_PostDeath, true);
	}
}

public void Bad_PostDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = NPC_CreateByName("npc_zomg", -1, pos, angles, GetTeam(caller));
		ScalingMultiplyEnemyHpGlobalScale(spawn_index);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
		NpcStats_CopyStats(caller, spawn_index);
	}
}

public void Bad_PostFortifiedDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = NPC_CreateByName("npc_zomg", -1, pos, angles, GetTeam(caller), "f");
		ScalingMultiplyEnemyHpGlobalScale(spawn_index);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
		NpcStats_CopyStats(caller, spawn_index);
	}
}