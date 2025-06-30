#pragma semicolon 1
#pragma newdecls required

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
		return 200.0;
	
	if(CurrentRound < 100)
		return 200.0 * (1.0 + (CurrentRound - 79) * 0.02);
	
	return 200.0 * (1.0 + (CurrentRound - 70) * 0.02);
}

static int MoabHealth(bool fortified)
{
	float value = 1300.0;	// 200x3 + 700 RGB
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
	
	return RoundFloat((value + (Bloon_HPRatio(fortified, Bloon_Ceramic) * 9.0) * Bloon_BaseHealth()));	// 104x3x3 RGB
}

void Bfb_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Brutal Floating Behemoth");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bfb");
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
	for(int i; i<sizeof(SoundMoabPop); i++)
	{
		PrecacheSoundCustom(SoundMoabPop[i]);
	}
	PrecacheModel("models/zombie_riot/btd/bfb.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return BFB(vecPos, vecAng, team, data);
}

methodmap BFB < CClotBody
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
		int sound = GetRandomInt(0, sizeof(SoundMoabPop) - 1);
		EmitCustomToAll(SoundMoabPop[sound], this.index, SNDCHAN_AUTO, 80, _, 2.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public BFB(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		BFB npc = view_as<BFB>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bfb.mdl", "1.0", buffer, ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
		func_NPCDeath[npc.index] = Bfb_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Bfb_OnTakeDamage;
		func_NPCThink[npc.index] = Bfb_ClotThink;

		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = STEPTYPE_NONE;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bFortified = fortified;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDoNotGiveWaveDelay = true;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bfb_ClotDamagedPost);
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void Bfb_ClotThink(int iNPC)
{
	BFB npc = view_as<BFB>(iNPC);
	
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
				float damageDealDo = 35.0;
				
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

public Action Bfb_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	BFB npc = view_as<BFB>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bfb_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	BFB npc = view_as<BFB>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bfb_NPCDeath(int entity)
{
	BFB npc = view_as<BFB>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bfb_ClotDamagedPost);

	float pos[3], angles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	int spawn_index = NPC_CreateByName("npc_moab", -1, pos, angles, GetTeam(entity), npc.m_bFortified ? "f" : "");
	ScalingMultiplyEnemyHpGlobalScale(spawn_index);
	if(spawn_index > MaxClients)
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
	NpcStats_CopyStats(npc.index, spawn_index);
}