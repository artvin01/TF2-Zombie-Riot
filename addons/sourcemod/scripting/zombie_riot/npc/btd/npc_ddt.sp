#pragma semicolon 1
#pragma newdecls required

static const char SoundLead[][] =
{
	"zombie_riot/btd/hitmetal01.wav",
	"zombie_riot/btd/hitmetal02.wav",
	"zombie_riot/btd/hitmetal03.wav",
	"zombie_riot/btd/hitmetal04.wav"
};

static const char SoundMoabHit[][] =
{
	"zombie_riot/btd/hitmoab01.wav",
	"zombie_riot/btd/hitmoab02.wav",
	"zombie_riot/btd/hitmoab03.wav",
	"zombie_riot/btd/hitmoab04.wav"
};

static const char SoundMoabPop[][] =
{
	"zombie_riot/btd/moabdestroyed01.wav",
	"zombie_riot/btd/moabdestroyed02.wav",
	"zombie_riot/btd/moabdestroyed03.wav",
	"zombie_riot/btd/moabdestroyed04.wav"
};

static float MoabSpeed()
{
	if(CurrentRound < 80)
		return 305.0;
	
	if(CurrentRound < 100)
		return 305.0 * (1.0 + (CurrentRound - 79) * 0.02);
	
	return 305.0 * (1.0 + (CurrentRound - 70) * 0.02);
}

static int MoabHealth(bool fortified)
{
	float value = 40000.0;	// 400 RGB
	value *= 0.5;
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
	
	return RoundFloat((value + (Bloon_HPRatio(fortified, Bloon_Ceramic) * 3.0) * Bloon_BaseHealth()));	// 104x3 RGB
}

void DDT_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dark Dirigible Titan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ddt");
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
	for(int i; i<sizeof(SoundMoabHit); i++)
	{
		PrecacheSoundCustom(SoundMoabHit[i]);
	}
	for(int i; i<sizeof(SoundLead); i++)
	{
		PrecacheSoundCustom(SoundLead[i]);
	}
	for(int i; i<sizeof(SoundMoabPop); i++)
	{
		PrecacheSoundCustom(SoundMoabPop[i]);
	}
	PrecacheModel("models/zombie_riot/btd/ddt.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DDT(vecPos, vecAng, team, data);
}

methodmap DDT < CClotBody
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
	public void PlayLeadSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundLead) - 1);
		EmitCustomToAll(SoundLead[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabHit) - 1);
		EmitCustomToAll(SoundMoabHit[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabPop) - 1);
		EmitCustomToAll(SoundMoabPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public DDT(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		DDT npc = view_as<DDT>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/ddt.mdl", "1.0", buffer, ally, false, true));
		
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPTYPE_NONE;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bFortified = fortified;
		
		npc.m_bCamo = true;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDoNotGiveWaveDelay = true;
		
		func_NPCDeath[npc.index] = DDT_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = DDT_OnTakeDamage;
		func_NPCThink[npc.index] = DDT_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, DDT_ClotDamagedPost);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 60);
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void DDT_ClotThink(int iNPC)
{
	DDT npc = view_as<DDT>(iNPC);
	
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

	bool camo = !NpcStats_IsEnemySilenced(npc.index);
	if(camo && HasSpecificBuff(npc.index, "Revealed"))
		camo = false;

	if(npc.m_bCamo)
	{
		if(!camo)
		{
			npc.m_bCamo = false;
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		}
	}
	else if(camo)
	{
		npc.m_bCamo = true;
		SetEntityRenderColor(npc.index, 255, 255, 255, 60);
	}

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
		
		//Target close enough to hit
		if(flDistanceToTarget < 20000)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				float damageDealDo = 60.0;
				
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

public Action DDT_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	DDT npc = view_as<DDT>(victim);
	
	if((damagetype & DMG_PLASMA) || (damagetype & DMG_TRUEDAMAGE))
	{
		npc.PlayHitSound();
	}
	else if((damagetype & DMG_BLAST))
	{
		damage *= 0.15 / MultiGlobalHealthBoss;

		damagePosition[2] += 50.0;
		npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
		damagePosition[2] -= 50.0;
	}
	else
	{
		damage *= 0.15 / MultiGlobalHealthBoss;
		npc.PlayLeadSound();

		damagePosition[2] += 50.0;
		npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
		damagePosition[2] -= 50.0;
	}
	return Plugin_Changed;
}

public void DDT_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	DDT npc = view_as<DDT>(victim);
	npc.UpdateBloonOnDamage();
}

public void DDT_NPCDeath(int entity)
{
	DDT npc = view_as<DDT>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, DDT_ClotDamagedPost);
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/ddt.mdl");
		DispatchKeyValue(entity_death, "skin", "4");
		if(npc.m_bFortified)
			DispatchKeyValue(entity_death, "body", "1");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		SetTeam(entity_death, GetTeam(npc.index));
		
		pos[2] += 20.0;
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", npc.m_bFortified ? DDT_PostFortifiedDeath : DDT_PostDeath, true);
	}
}

public void DDT_PostDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("ExplosionCore_MidAir", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	int spawn_index = NPC_CreateByName("npc_bloon", -1, pos, angles, GetTeam(caller), "9rc");
	if(spawn_index > MaxClients)
	{
		ScalingMultiplyEnemyHpGlobalScale(spawn_index);
		NpcStats_CopyStats(caller, spawn_index);
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
	}
}

public void DDT_PostFortifiedDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("ExplosionCore_MidAir", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	int spawn_index = NPC_CreateByName("npc_bloon", -1, pos, angles, GetTeam(caller), "9frc");
	if(spawn_index > MaxClients)
	{
		ScalingMultiplyEnemyHpGlobalScale(spawn_index);
		NpcStats_CopyStats(caller, spawn_index);
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
	}
}