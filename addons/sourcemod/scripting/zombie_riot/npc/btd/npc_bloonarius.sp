#pragma semicolon 1
#pragma newdecls required

static const char BloonLowData[][] =
{
	"3",
	"4",
	"5",
	"7"
};

// Halved on Elite
static const int BloonLowCount[] =
{
	2,
	2,
	3,
	3
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
	"8",
	"9",
	"",
	""
};

// Halved on Elite
static const int BloonHighCount[] =
{
	3,//30,
	8,//60,
	3,//6,
	2//10
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
	
	return RoundToCeil(float(count) * multi);
}

static float MoabSpeed(bool elite)
{
	if(CurrentRound < (elite ? 29 : 59))
		return 62.5;
	
	return 75.0;
}

static int CurrentTier(bool elite)
{
	int round = CurrentRound - 14;
	
	if(!elite)	// 40,60,80,100 -> 15,30,45,60
	{
	//	round = (round - 20) * 3 / 4;
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
	return round;
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
	else
	{
		if(CurrentRound > 98)
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
	
	// Reference to +20% increase in BTD6 co-op
	RaidModeScaling *= 0.2 + (players * 0.2);
}

static int i_PlayMusicSound;

void Bloonarius_MapStart()
{
	PrecacheSound("zombie_riot/btd/bossbloonariusdeath.wav");
	PrecacheSound("zombie_riot/btd/bossbloonariusspawn.wav");
	PrecacheSound("zombie_riot/btd/bossbloonariusvomit.wav");
	PrecacheSound("#zombie_riot/btd/musicbossbloonarius.mp3");
	/*
	PrecacheSoundCustom("zombie_riot/btd/bossbloonariusdeath.wav");
	PrecacheSoundCustom("zombie_riot/btd/bossbloonariusspawn.wav");
	PrecacheSoundCustom("zombie_riot/btd/bossbloonariusvomit.wav");
	PrecacheSoundCustom("#zombie_riot/btd/musicbossbloonarius.mp3");
	*/
}

methodmap Bloonarius < CClotBody
{
	public void PlaySpawnSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusspawn.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 2.0);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusdeath.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 2.0);
	}
	public void PlayLifelossSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusvomit.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 2.0);
	}
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
			return CurrentTier(this.m_bElite);
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
	public Bloonarius(int clien, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool elite = false;//StrContains(data, "e") != -1;
		
		Bloonarius npc = view_as<Bloonarius>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bad.mdl", "1.15", "1000000", ally, false, true, true, true));
		
		i_NpcInternalId[npc.index] = BTD_BLOONARIUS;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 128, 255, 128, 255);
		
		int activity = npc.LookupActivity("ACT_FLOAT");
		if(activity > 0)
			npc.StartActivity(activity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed(elite);
		npc.m_bElite = elite;
		npc.m_iLivesLost = 0;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_flNextMeleeAttack = 0.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bloonarius_ClotThink);
		
		for(int i; i < ZR_MAX_SPAWNERS; i++)
		{
			if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
			{
				Spawner_AddToArray(npc.index, true);
				i_ObjectsSpawners[i] = npc.index;
				break;
			}
		}
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		SetBossBloonPower(CountPlayersOnRed(), elite);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				LookAtTarget(client, npc.index);
		}

		npc.PlaySpawnSound();
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		Raidboss_Clean_Everyone();

		i_PlayMusicSound = 0;
		ToggleMapMusic(false);
		
		//ExcuteRelay("zr_btdraid", "FireUser1");
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
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	npc.Update();
	
	int time = GetTime();
	if(i_PlayMusicSound < time)
	{
		i_PlayMusicSound = time + 999;//198;	// Raid timer lasts as long as the music I guess, no need to loop this one...
		EmitCustomToAll("#zombie_riot/btd/musicbossbloonarius.mp3", npc.index, SNDCHAN_STATIC, SNDLEVEL_NONE);
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	//if(npc.m_bElite)
	{
		float armor = 1.0;
		if(Zombies_Currently_Still_Ongoing > 50)
			armor *= Pow(0.97, float(Zombies_Currently_Still_Ongoing - 50));
		
		npc.m_flMeleeArmor = armor;
		npc.m_flRangedArmor = armor;
	}
	
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
		npc.PlayLifelossSound();
		npc.m_iLivesLost++;
		npc.m_iMiniLivesLost++;
		
		int entity = -1;
		while((entity=FindEntityByClassname(entity, "base_boss")) != -1)
		{
			if(entity != npc.index && !view_as<CClotBody>(entity).m_bThisNpcIsABoss && !b_Map_BaseBoss_No_Layers[entity] && !b_ThisNpcIsImmuneToNuke[entity] && GetEntProp(entity, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				SDKHooks_TakeDamage(entity, 0, 0, 99999999.0, DMG_BLAST);
				SDKHooks_TakeDamage(entity, 0, 0, 99999999.0, DMG_BLAST);
			}
		}
		
		int players = CountPlayersOnRed();
		int tier = npc.m_iTier;
		//if(!npc.m_bElite)
		//	SetBossBloonPower(players, false);
		
		int count = SpawnMulti(BloonHighCount[tier], players, npc.m_bElite);
		
		for(int i; i < count; i++)
		{
			CreateTimer(float(i) * 0.1, Bloonarius_SpawnBloonTimer, npc.m_bElite, TIMER_FLAG_NO_MAPCHANGE);
		}
		
		if(npc.m_bElite)
		{
			count = SpawnMulti(ZombieHighCount[tier], players, false);
			
			for(int i; i < count; i++)
			{
				CreateTimer(float(i) * 0.1, Bloonarius_SpawnZombieTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		
		npc.m_flNextThinkTime = gameTime + 2.0;

		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		
		//if(npc.m_bElite)
		{
			npc.m_flMeleeArmor = 0.1;
			npc.m_flRangedArmor = 0.1;
		}
		return;
	}
	
	if(npc.m_iMiniLivesLost < 99 && !NpcStats_IsEnemySilenced(npc.index))
	{
		nextLoss = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * (99 - npc.m_iMiniLivesLost) / 100;
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < nextLoss)
		{
			npc.m_iMiniLivesLost++;
			
			int players = CountPlayersOnRed();
			int tier = npc.m_iTier;
			
			int count = SpawnMulti(BloonLowCount[tier], players, npc.m_bElite);
			
			Enemy enemy;
			enemy.Index = BTD_BLOON;
			//enemy.Is_Static = !npc.m_bElite;
			strcopy(enemy.Data, sizeof(enemy.Data), BloonLowData[tier]);
			
			for(int i; i<count; i++)
			{
				Waves_AddNextEnemy(enemy);
			}
			
			Zombies_Currently_Still_Ongoing += count;
			
			if(npc.m_bElite)
			{
				enemy.Index = ZombieLow[tier];
				enemy.Data[0] = 0;
				
				count = SpawnMulti(ZombieLowCount[tier], players, false);
				
				for(int i; i < count; i++)
				{
					Waves_AddNextEnemy(enemy);
				}
			}
		}
	}
	
	if(npc.m_iTarget < 1 || !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_flGetClosestTargetTime = 0.0;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, false, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 5.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		PF_SetGoalEntity(npc.index, npc.m_iTarget);
		npc.StartPathing();
		
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Target close enough to hit
			if(flDistanceToTarget < 20000)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				
				Handle swingTrace;
				if(npc.DoAimbotTrace(swingTrace, npc.m_iTarget))
				{
					if(TR_GetEntityIndex(swingTrace) == npc.m_iTarget)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(ShouldNpcDealBonusDamage(npc.m_iTarget))
						{
							SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 20.0 * float(CurrentRound), DMG_CLUB, -1, _, vecHit);
						}
						else
						{
							SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 8.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
						}
					}
					
					delete swingTrace;
				}
			}
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
	}
}

public Action Bloonarius_SpawnBloonTimer(Handle timer, bool elite)
{
	if(IsValidEntity(RaidBossActive))
	{
		int tier = CurrentTier(elite);
		
		float pos[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_angRotation", ang);
		
		int spawn_index = Npc_Create(BloonHigh[tier], -1, pos, ang, false, BloonHighData[tier]);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
	return Plugin_Continue;
}

public Action Bloonarius_SpawnZombieTimer(Handle timer)
{
	if(IsValidEntity(RaidBossActive))
	{
		int tier = CurrentTier(true);
		
		float pos[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_angRotation", ang);
		
		int spawn_index = Npc_Create(ZombieHigh[tier], -1, pos, ang, false);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
	return Plugin_Continue;
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

	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	ToggleMapMusic(true);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
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
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/bad.mdl");
		DispatchKeyValue(entity_death, "skin", "0");
		if(npc.m_bElite)
			DispatchKeyValue(entity_death, "body", "1");
		
		DispatchSpawn(entity_death);

		SetEntityRenderMode(entity_death, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity_death, 128, 255, 128, 255);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", Bloonarius_PostDeath, true);
	}
}

public void Bloonarius_PostDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	RemoveEntity(caller);
}

static void ToggleMapMusic(bool enable)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "env_soundscape")) != -1)
	{
		AcceptEntityInput(entity, enable ? "Enable" : "Disable");
	}
}
