#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSounds[][] = {
	"zombie_riot/miniboss/kamikaze/become_enraged56.wav",
};

static const char g_Spawn[][] = {
	"zombie_riot/miniboss/kamikaze/spawn.wav",
};

static int NPCId;

static float fl_KamikazeInitiate;
static float fl_KamikazeSpawnDelay;
static float fl_KamikazeSpawnRateDelay;
static float fl_KamikazeSpawnDuration;
static bool b_KamikazeEvent;
static int i_TimesFailedToTeleport;

void BeheadedKamiKaze_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_Spawn));	   i++) { PrecacheSoundCustom(g_Spawn[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/zombie_riot/serious/kamikaze_4.mdl");
	PrecacheSoundCustom("#zombie_riot/miniboss/kamikaze/sam_rush_2.mp3");
		
	fl_KamikazeInitiate = 0.0;
	fl_KamikazeSpawnDelay = 0.0;
	fl_KamikazeSpawnDuration = 0.0;
	b_KamikazeEvent = false;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Beheaded Kamikaze");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_beheaded_kami");
	strcopy(data.Icon, sizeof(data.Icon), "kamikaze");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return BeheadedKamiKaze(vecPos, vecAng, team, data);
}

methodmap BeheadedKamiKaze < CClotBody
{
	
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetEngineTime())
			return;
		

		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 75, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetEngineTime() + 0.85;
		
	}
	
	public void PlaySpawnSound() 
	{
		EmitCustomToAll(g_Spawn[GetRandomInt(0, sizeof(g_Spawn) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.5, 100);
	}
	
	public BeheadedKamiKaze(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(CClotBody(vecPos, vecAng, "models/zombie_riot/serious/kamikaze_4.mdl", "1.10", MinibossHealthScaling(2.0, true), ally));
		
		i_NpcWeight[npc.index] = 2;
		npc.m_bisWalking = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "bomb");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		npc.m_flSpeed = 500.0;
		
		
		func_NPCDeath[npc.index] = BeheadedKamiKaze_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BeheadedKamiKaze_OnTakeDamage;
		func_NPCThink[npc.index] = BeheadedKamiKaze_ClotThink;

		npc.m_bDoSpawnGesture = true;
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		float wave = float(Waves_GetRoundScale()+1); //Wave scaling
		
		wave *= 0.133333;

		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		npc.m_bDissapearOnDeath = true;

		bool norandom = StrContains(data, "norandom") != -1;
		if(norandom)
			npc.m_fbRangedSpecialOn = true;

		if(ally == TFTeam_Blue && !norandom)
		{
			if(fl_KamikazeInitiate < GetGameTime())
			{
				//This is a kamikaze that was newly initiated!
				//add new kamikazies whenever possible.
				//this needs to happen every tick!
				DoGlobalMultiScaling();
				float SpawnRate = 0.25;
				fl_KamikazeSpawnRateDelay = 0.0;
				SpawnRate /= MultiGlobalEnemy;
				DataPack pack = new DataPack();
				pack.WriteFloat(SpawnRate);
				pack.WriteFloat(GetGameTime() + 10.0); //they took too long to kill that one. Spawn more regardless.
				pack.WriteCell(EntIndexToEntRef(npc.index));
				RequestFrame(SpawnBeheadedKamikaze, pack);
				b_KamikazeEvent = true;
				i_TimesFailedToTeleport = 0;
			}

			fl_KamikazeInitiate = GetGameTime() + 15.0;
			
			bool teleported;
			if (!b_KamikazeEvent || i_TimesFailedToTeleport < 10)
				teleported = TeleportDiversioToRandLocation(npc.index, _, 2500.0, 1250.0) == 1;
			
			if (!teleported)
			{
				if (b_KamikazeEvent)
					i_TimesFailedToTeleport++;
				
				//incase their random spawn code fails, they'll spawn here.
				int Spawner_entity = GetRandomActiveSpawner();
				if(IsValidEntity(Spawner_entity))
				{
					float pos[3];
					float ang[3];
					GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
					TeleportEntity(npc.index, pos, ang, NULL_VECTOR);
				}
			}	
		}

		npc.PlaySpawnSound();
		float pos[3]; WorldSpaceCenter(npc.index, pos);
		pos[2] -= 10.0;
		TE_Particle("teleported_blue", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		
		npc.StartPathing();
		
		return npc;
	}
	
	
}


public void BeheadedKamiKaze_ClotThink(int iNPC)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(iNPC);
	npc.PlayIdleAlertSound();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
			
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(!npc.m_fbRangedSpecialOn && npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 10);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 10.0;
			}
		}
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.StartPathing();
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 9025.0 && !npc.m_flAttackHappenswillhappen)
		{
			Kamikaze_DeathExplosion(npc.index);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action BeheadedKamiKaze_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
		
		
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BeheadedKamiKaze_NPCDeath(int entity)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(entity);
	
	StopCustomSound(npc.index, SNDCHAN_VOICE, "zombie_riot/miniboss/kamikaze/become_enraged56.wav");
	Kamikaze_DeathExplosion(entity);
}


void Kamikaze_DeathExplosion(int entity)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(entity);
	if(npc.m_flAttackHappenswillhappen)
	{
		return;
	}
	npc.m_flAttackHappenswillhappen = true;
	//change team to one that isnt existant.
	float startPosition[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition); 
	startPosition[2] += 45.0;
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(startPosition[0]);
	pack_boom.WriteFloat(startPosition[1]);
	pack_boom.WriteFloat(startPosition[2]);
	pack_boom.WriteCell(1);
	RequestFrame(MakeExplosionFrameLaterKami, pack_boom);

	b_NpcIsTeamkiller[entity] = true;
	Explode_Logic_Custom(90.0 * npc.m_flWaveScale,
	npc.index,
	npc.index,
	-1,
	_,
	150.0,
	_,
	_,
	true,
	99,
	false,
	5.0,
	_,
	BeheadedKamiBoomInternal);
	b_NpcIsTeamkiller[entity] = true;
	SmiteNpcToDeath(entity);
	/*

CTFPlayer::ChangeTeam( 4 ) - invalid team index.
CTFPlayer::ChangeTeam( 4 ) - invalid team index.
CTFPlayer::ChangeTeam( 4 ) - invalid team index.
??
	*/
}

float BeheadedKamiBoomInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return 0.0;

	//instakill any be_headeads.
	if(i_NpcInternalId[victim] == NPCId)
	{
		return 1000000000.0;
	}
	else if(!b_NpcHasDied[victim] && GetTeam(victim) != TFTeam_Red)
		return damage * 15.0;
  
	return damage;
}

void SpawnBeheadedKamikaze(DataPack pack)
{
	if(Waves_InSetup())
	{
		b_KamikazeEvent = false;
		fl_KamikazeSpawnDuration = 0.0;
		delete pack;
		return;
	}

	if(f_DelaySpawnsForVariousReasons + 0.15 < GetGameTime())
		f_DelaySpawnsForVariousReasons = GetGameTime() + 0.15;
	
	ResetPack(pack);
	float spawndelay = ReadPackFloat(pack);
	float ForceSpawn_Moretime = ReadPackFloat(pack);
	int FirstKamiKaze = EntRefToEntIndex(ReadPackCell(pack));

	bool InitiateSpawns = false;

	if(ForceSpawn_Moretime < GetGameTime())
		InitiateSpawns = true;

	if(!IsValidEntity(FirstKamiKaze))
	{
		InitiateSpawns = true;
	}
	else
	{
		if(b_NpcHasDied[FirstKamiKaze])
			InitiateSpawns = true;
	}

	if(!InitiateSpawns)
	{
		RequestFrame(SpawnBeheadedKamikaze, pack);
		return;
	}

	//This now means we initiate spawns!
	if(fl_KamikazeSpawnDuration == 0.0)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(IsValidClient(client))
				{
					EmitCustomToClient(client, "#zombie_riot/miniboss/kamikaze/sam_rush_2.mp3", client, SNDCHAN_AUTO, 90, _, 1.0);
				}
			}
		}
		fl_KamikazeSpawnDelay = GetGameTime() + 5.0;
		fl_KamikazeSpawnDuration = GetGameTime() + 18.0 + 5.0;
	}

	//can we still spawn
	if(fl_KamikazeSpawnDuration > GetGameTime())
	{
		if(fl_KamikazeSpawnDelay > GetGameTime())
		{
			RequestFrame(SpawnBeheadedKamikaze, pack);
			return;
		}
		if(fl_KamikazeSpawnRateDelay > GetGameTime())
		{
			RequestFrame(SpawnBeheadedKamikaze, pack);
			return;
		}
		fl_KamikazeSpawnRateDelay = GetGameTime() + spawndelay;
		int Kamikazies = 0;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int INpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if (IsValidEntity(INpc))
			{
				if(!b_NpcHasDied[INpc] && i_NpcInternalId[INpc] == NPCId)
				{
					Kamikazies += 1;
				}
			}
		}
		if(Kamikazies < (MaxEnemiesAllowedSpawnNext()))
		{
			//spawn a kamikaze here!
			int Spawner_entity = GetRandomActiveSpawner();
			float pos[3];
			float ang[3];
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			}
			int spawn_npc = NPC_CreateById(NPCId, -1, pos, ang, TFTeam_Blue); //can only be enemy
			NpcAddedToZombiesLeftCurrently(spawn_npc, true);
		}
		RequestFrame(SpawnBeheadedKamikaze, pack);
		return;
	}
	//its over, no more spawning.
	b_KamikazeEvent = false;
	fl_KamikazeSpawnDuration = 0.0;
	delete pack;
}

bool KamikazeEventHappening()
{
	return b_KamikazeEvent;
}

public void MakeExplosionFrameLaterKami(DataPack pack)
{
	pack.Reset();
	float vec_pos[3];
	vec_pos[0] = pack.ReadFloat();
	vec_pos[1] = pack.ReadFloat();
	vec_pos[2] = pack.ReadFloat();
	int Do_Sound = pack.ReadCell();
	
	if(Do_Sound == 1)
	{		
		EmitAmbientSound("ambient/explosions/explode_3.wav", vec_pos, _, 75, _,0.7, GetRandomInt(75, 110));
	}
	SpawnSmallExplosionNotRandom(vec_pos);
	delete pack;
}