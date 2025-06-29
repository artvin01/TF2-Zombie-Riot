#pragma semicolon 1
#pragma newdecls required

static int SpawnMulti(int count, int players)
{
	float multi = float(players) * 0.25;
	if(elite)
		multi *= 0.5;
	
	return RoundToCeil(float(count) * multi);
}

static float MoabSpeed()
{
	float multi = 3.6;
	if(npc.m_flArmorCount > 0.0)
	{
		switch(CurrentTier())
		{
			case 0:
				multi = 5.22;
			
			case 1:
				multi = 5.4;
			
			case 2:
				multi = 5.58;
			
			default:
				multi = 5.94;
		}
	}

	return 250.0 * multi;
}

static int CurrentTier()
{
	// 39,59,79,99
	int round = (CurrentRound - 38) / 20;
	
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

static void SetBossBloonPower(int players)
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
	
	// Reference to +20% increase in BTD6 co-op
	RaidModeScaling *= 0.2 + (players * 0.2);
}

void Bloonarius_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reality Warper Phayze");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_phayze");
	strcopy(data.Icon, sizeof(data.Icon), "special_blimp");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombie_riot/btd/musicbossbloonarius.mp3");
	PrecacheModel("models/zombie_riot/btd/bloonarius.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Bloonarius(vecPos, vecAng, team, data);
}
methodmap Bloonarius < CClotBody
{
	public void PlaySpawnSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusspawn.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 3.0);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusdeath.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 3.0);
	}
	public void PlayLifelossSound()
	{
		EmitCustomToAll("zombie_riot/btd/bossbloonariusvomit.wav", this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, 3.0);
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
			return CurrentTier();
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
		if(GetEntProp(this.index, Prop_Data, "m_iHealth") < (GetEntProp(this.index, Prop_Data, "m_iMaxHealth") / 2))
			SetEntProp(this.index, Prop_Send, "m_nSkin", 1);
	}
	public Bloonarius(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		if(IsValidEntity(RaidBossActive))	// Bloon raids fail if another can't spawn
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			return view_as<Bloonarius>(-1);
		}

		bool final = StrContains(data, "final") != -1;
		
		Bloonarius npc = view_as<Bloonarius>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/ddt.mdl", "3.0", "1000000", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 5;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
		int activity = npc.LookupActivity("ACT_FLOAT");
		if(activity > 0)
			npc.StartActivity(activity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = STEPTYPE_NONE;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisNpcIsABoss = true;
		b_thisNpcIsARaid[npc.index] = true;

		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);

		npc.m_bisWalking = false;
		npc.m_bnew_target = final;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_iLivesLost = 0;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_flNextMeleeAttack = 0.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
		
		func_NPCDeath[npc.index] = Bloonarius_NPCDeath;
		func_NPCThink[npc.index] = Bloonarius_ClotThink;
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = elite;
		
		SetBossBloonPower(CountPlayersOnRed(), elite);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				LookAtTarget(client, npc.index);
		}

		npc.PlaySpawnSound();
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombie_riot/btd/musicbossbloonarius.mp3");
		music.Time = 198;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Primal One");
		strcopy(music.Artist, sizeof(music.Artist), "Tim Haywood");
		Music_SetRaidMusic(music);
		
		RaidModeTime = 9999999.9; //cant afford to delete it, since duo.

		i_PlayMusicSound[npc.index] = 0;
		ToggleMapMusic(false);
		npc.m_flMeleeArmor = 1.15;
		
		if(!VIPBuilding_Active())
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
				{
					Spawns_AddToArray(npc.index, true);
					i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
					break;
				}
			}

		}
		
		//ExcuteRelay("zr_btdraid", "FireUser1");
		return npc;
	}
}

public void Bloonarius_ClotThink(int iNPC)
{
	Bloonarius npc = view_as<Bloonarius>(iNPC);
	
	if(npc.m_bStaticNPC)
	{
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	npc.Update();

	if(!npc.m_bStaticNPC && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
	}
	
	if(Music_Disabled())
	{
		int time = GetTime();
		if(i_PlayMusicSound[npc.index] < time)
		{
			i_PlayMusicSound[npc.index] = time + 198;
			EmitCustomToAll("#zombie_riot/btd/musicbossbloonarius.mp3", npc.index, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
		}
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	//if(npc.m_bElite)
	{
		/*
		float armor = 1.0;
		if(Zombies_Currently_Still_Ongoing > 50)
			armor *= Pow(0.97, float(Zombies_Currently_Still_Ongoing - 50));
		
		npc.m_flMeleeArmor = armor;
		npc.m_flRangedArmor = armor;
		*/
	}
	
	int nextLoss = -999999;
	if(npc.m_bStaticNPC)
	{
		if(npc.m_iLivesLost < 7)
			nextLoss = ReturnEntityMaxHealth(npc.index) * (7 - npc.m_iLivesLost) / 8;
	}
	else if(npc.m_iLivesLost < 4)
	{
		nextLoss = ReturnEntityMaxHealth(npc.index) * (3 - npc.m_iLivesLost) / 4;
	}
	
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if(health < nextLoss)
	{
		npc.PlayLifelossSound();
		npc.m_iLivesLost++;
		npc.m_iMiniLivesLost++;
		
		int a, entity;
		while((entity = FindEntityByNPC(a)) != -1)
		{
			if(entity != npc.index && npc.m_bStaticNPC == view_as<CClotBody>(entity).m_bStaticNPC && !view_as<CClotBody>(entity).m_bThisNpcIsABoss && !b_ThisNpcIsImmuneToNuke[entity] && GetTeam(entity) != view_as<int>(TFTeam_Red))
			{
				SmiteNpcToDeath(entity);
				SmiteNpcToDeath(entity);
			}
		}
		
		int players = CountPlayersOnRed();
		int tier = npc.m_iTier;
		//if(!npc.m_bElite)
		//	SetBossBloonPower(players, false);
		
		int count = SpawnMulti(BloonHighCount[tier], players, npc.m_bStaticNPC);
		
		for(int i; i < count; i++)
		{
			CreateTimer(float(i) * 0.1, Bloonarius_SpawnBloonTimer, npc.m_bStaticNPC, TIMER_FLAG_NO_MAPCHANGE);
		}
		
		npc.AddGesture("ACT_BLOONARIUS_RAGE");
		npc.m_flNextThinkTime = gameTime + 1.8;

		npc.StopPathing();
		
		
		//if(npc.m_bElite)
		{
			//npc.m_flMeleeArmor = 0.1;
			//npc.m_flRangedArmor = 0.1;
		}
		return;
	}
	
	if(npc.m_iMiniLivesLost < 99 && !NpcStats_IsEnemySilenced(npc.index) && MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
	{
		nextLoss = ReturnEntityMaxHealth(npc.index) * (99 - npc.m_iMiniLivesLost) / 100;
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < nextLoss)
		{
			npc.m_iMiniLivesLost++;
			
			int players = CountPlayersOnRed();
			int tier = npc.m_iTier;
			int count = SpawnMulti(BloonLowCount[tier], players, npc.m_bStaticNPC);

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			for(;count >= 1; count--)
			{
				int spawn_index = NPC_CreateByName("npc_bloon", -1, pos, ang, GetTeam(npc.index), BloonLowData[tier]);
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					ScalingMultiplyEnemyHpGlobalScale(spawn_index);
					AddNpcToAliveList(spawn_index, 1);
				}
			}

			if(npc.m_flHeadshotCooldown < gameTime)
				npc.AddGesture((GetURandomInt() % 2) ? "ACT_BLOONARIUS_HURT_LEFT" : "ACT_BLOONARIUS_HURT_RIGHT", false);
		}
	}
	
	if(npc.m_iTarget < 1 || !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_flGetClosestTargetTime = 0.0;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, false, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 5.0;
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );	
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);		
		float distance = GetVectorDistance(vecTarget, WorldSpaceVec, true);

		npc.SetGoalEntity(npc.m_iTarget);
		npc.StartPathing();

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						if(ShouldNpcDealBonusDamage(npc.m_iTarget))
						{
							SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 40.0 * float(CurrentRound), DMG_CLUB, -1, _, vecHit);
						}
						else
						{
							SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 160.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
						}
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 20000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_BLOONARIUS_ATTACK");
				
				npc.m_flAttackHappens = gameTime + 0.25;
				
				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
				npc.m_flHeadshotCooldown = gameTime + 0.85;
			}
		}
	}
	else
	{
		npc.StopPathing();
		
	}
}

public Action Bloonarius_SpawnBloonTimer(Handle timer, bool elite)
{
	if(IsValidEntity(RaidBossActive))
	{
		int tier = CurrentTier(elite);
		
		float pos[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(RaidBossActive, Prop_Data, "m_angRotation", ang);
		
		int spawn_index = NPC_CreateByName(BloonHigh[tier], -1, pos, ang, TFTeam_Blue, BloonHighData[tier]);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(EntRefToEntIndex(RaidBossActive), spawn_index);
			ScalingMultiplyEnemyHpGlobalScale(spawn_index);
			Zombies_Currently_Still_Ongoing++;
			view_as<CClotBody>(spawn_index).m_bStaticNPC = elite;
			if(elite)
				AddNpcToAliveList(spawn_index, 1);
		}
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

	Waves_ClearWaveCurrentSpawningEnemies();

	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	StopSound(npc.index, SNDCHAN_STATIC, "#zombie_riot/btd/musicbossbloonarius.mp3");
	ToggleMapMusic(true);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);

	if(npc.m_bnew_target)
	{
		ForcePlayerWin();
	}
	
	Spawns_RemoveFromArray(entity);
	
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
		
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/bloonarius.mdl");
		DispatchKeyValue(entity_death, "skin", "1");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 3.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("bloonarius_death");
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
