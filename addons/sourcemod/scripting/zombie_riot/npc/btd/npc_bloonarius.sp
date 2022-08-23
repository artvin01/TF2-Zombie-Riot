#pragma semicolon 1

static const char BloonLowData[][] =
{
	"3",
	"4",
	"5",
	"7"
};

static const int BloonLowCount[] =
{
	8,
	15,
	25,
	15
};

static const int BloonHigh[] =
{
	BTD_BLOON,
	BTD_BLOON,
	BTD_MOAB,
	BTD_ZOMG
};

static const char BloonHighData[][] =
{
	"9",
	"9",
	"",
	""
};

// Halved on Elite
static const int BloonHighCount[] =
{
	30,
	60,
	6,
	10
};

static const int ZombieLow[] =
{
	XENO_HEADCRAB_ZOMBIE,
	XENO_COMBINE_POLICE_PISTOL,
	XENO_SCOUT_ZOMBIE,
	XENO_SPY_THIEF
};

static const int ZombieLowCount[] =
{
	1,
	1,
	1,
	1
};

static const int ZombieHigh[] =
{
	XENO_FORTIFIED_GIANT_POISON_ZOMBIE,
	XENO_COMBINE_SOLDIER_DDT,
	XENO_KAMIKAZE_DEMO,
	XENO_COMBINE_DEUTSCH_RITTER
};

static const int ZombieHighCount[] =
{
	5,
	20,
	20,
	5
};

static int SpawnMulti(int count, int players, bool elite)
{
	float multi = float(players) * 0.25;
	if(elite)
		multi *= 0.5;
	
	
}

static float MoabSpeed(bool elite)
{
	if(CurrentRound < (elite ? 29 : 59))
		return 12.5;
	
	return 15.0;
}

static int CurrentTier(bool elite)
{
	int round = CurrentRound - 14;
	
	if(!elite)	// 40,60,80,100 -> 15,30,45,60
	{
		round = (round - 20) * 3 / 4;
	}
	
	round /= 15;
	if(round > 3)
	{
		round = 3;
	}
	else if(round < 0)
	{
		round = 0;
	}
}

static void SetBossBloonPower(int players, bool elite)
{
	if(elite)
	{
		if(CurrentRound > 58)
		{
			RaidModeScaling = 80.0 / 3.0;
		}
		else if(CurrentRound > 43)
		{
			RaidModeScaling = 20.0 / 3.0;
		}
		else if(CurrentRound > 28)
		{
			RaidModeScaling = 1.0;
		}
		else
		{
			RaidModeScaling = 1.0 / 6.0;
		}
	}
	else if(CurrentRound > 98)
	{
		RaidModeScaling = 10.0;
	}
	else if(CurrentRound > 78)
	{
		RaidModeScaling = 14.0 / 3.0;
	}
	else if(CurrentRound > 58)
	{
		RaidModeScaling = 1.0;
	}
	else
	{
		RaidModeScaling = 4.0 / 15.0;
	}
	
	// Reference to +20% increase in BTD6 co-op
	RaidModeScaling *= 0.2 + (players * 0.2);
	
	// Reference to late game scaling
	if(CurrentRound > 99)
	{
		RaidModeScaling *= 1.0 + (CurrentRound - 71) * 0.05;
	}
	else if(CurrentRound > 79)
	{
		RaidModeScaling *= 1.0 + (CurrentRound - 79) * 0.02;
	}
}

methodmap Bloonarius < CClotBody
{
	property bool m_bElite
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
	property int m_iLivesLost
	{
		public get()
		{
			return this.m_iOverlordComboAttack;
		}
		public set(int value)
		{
			this.m_iOverlordComboAttack = value;
		}
	}
	property int m_iTier
	{
		public get()
		{
			return round;
		}
	}
	property int m_iMiniLivesLost
	{
		public get()
		{
			return this.m_iAttacksTillMegahit;
		}
		public set(int value)
		{
			this.m_iAttacksTillMegahit = value;
		}
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public Bloonarius(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool elite = StrContains(data, "e") != -1;
		
		Bloonarius npc = view_as<Bloonarius>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bad.mdl", "1.0", "20000", ally, false, true));
		
		i_NpcInternalId[npc.index] = BTD_BLOOONARIUS;
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bElite = elite;
		npc.m_iLivesLost = 0;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Bloonarius_ClotDamaged);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bloonarius_ClotThink);
		
		npc.StartPathing();
		
		for(int i; i < ZR_MAX_SPAWNERS; i++)
		{
			if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
			{
				Spawner_AddToArray(entity);
				i_ObjectsSpawners[i] = entity;
				break;
			}
		}
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		SetBossBloonPower(CountPlayersOnRed(), npc.m_bElite);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				LookAtTarget(client, npc.index);
		}
		
		RaidModeTime = GetGameTime() + 300.0;
		
		Raidboss_Clean_Everyone();
		return npc;
	}
}

public void Bloonarius_ClotThink(int iNPC)
{
	Bloonarius npc = view_as<Bloonarius>(iNPC);
	
	if(npc.m_bElite)
	{
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime();
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_bElite)
	{
		float armor = 1.0;
		if(Zombies_Currently_Still_Ongoing > 30)
			armor *= Pow(0.97, float(Zombies_Currently_Still_Ongoing - 30));
		
		npc.m_flMeleeArmor = armor;
		npc.m_flRangedArmor = armor;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int nextLoss = -999999;
	if(npc.m_bElite)
	{
		if(npc.m_iLivesLost < 7)
			nextLoss = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * (7 - npc.m_iLivesLost) / 8;
	}
	else if(npc.m_iLivesLost < 4)
	{
		nextLoss = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * (3 - npc.m_iLivesLost) / 4;
	}
	
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if(health < nextLoss)
	{
		npc.m_iLivesLost++;
		
		int players = CountPlayersOnRed();
		if(CurrentRound > 80)
			SetBossBloonPower(CountPlayersOnRed(), npc.m_bElite);
	}
	
	if(npc.m_iMiniLivesLost < 99)
	{
		nextLoss = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * (99 - npc.m_iMiniLivesLost) / 100;
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < nextLoss)
		{
			npc.m_iMiniLivesLost++;
			
			float multi = float(CountPlayersOnRed() / 8.0);
			
			int tier = npc.m_iTier;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 5.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
													
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			PF_SetGoalVector(npc.index, PredictSubjectPosition(npc, PrimaryThreatIndex));
		}
		else
		{
			PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 20000)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				
				Handle swingTrace;
				if(npc.DoAimbotTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(npc.m_bFortified)
						{
							if(target <= MaxClients)
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 7000.0, DMG_CLUB, -1, _, vecHit);
							}
						}
						else
						{
							if(target <= MaxClients)
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 5000.0, DMG_CLUB, -1, _, vecHit);
							}
						}
					}
					
					delete swingTrace;
				}
			}
		}
		
		npc.StartPathing();
		
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bloonarius_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bloonarius npc = view_as<Bloonarius>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bloonarius_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Bloonarius npc = view_as<Bloonarius>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bloonarius_NPCDeath(int entity)
{
	Bloonarius npc = view_as<Bloonarius>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Bloonarius_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Bloonarius_ClotThink);
	
	Spawner_RemoveFromArray(entity);
	
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(i_ObjectsSpawners[i] == entity)
		{
			i_ObjectsSpawners[i] = 0;
			break;
		}
	}
	
	int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
	
	float pos[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	for(int i; i<3; i++)
	{
		int spawn_index = Npc_Create(BTD_DDT, -1, pos, angles, team == 2, npc.m_bFortified ? "f" : "");
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/Bloonarius.mdl");
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
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", npc.m_bFortified ? Bloonarius_PostFortifiedDeath : Bloonarius_PostDeath, true);
	}
}

public void Bloonarius_PostDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = Npc_Create(BTD_ZOMG, -1, pos, angles, GetEntProp(caller, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
}

public void Bloonarius_PostFortifiedDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = Npc_Create(BTD_ZOMG, -1, pos, angles, GetEntProp(caller, Prop_Send, "m_iTeamNum") == 2, "f");
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
}