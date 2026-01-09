#pragma semicolon 1
#pragma newdecls required

static ArrayList hConst2_SpawnerSaveWave;

enum struct Const2SpawnerEnum
{
	int SpawnerAmRef;
	int SpawnerArrayAm;
	char DataWave[512];
}

static const char g_SpawnStart[][] =
{
	"buttons/blip1.wav",
};
static const char g_SpawnStartDo[][] =
{
	"friends/friend_join.wav",
};

static const char g_SpawnEnd[][] =
{
	"buttons/combine_button_locked.wav",
};

static int NPCId;

void Const2SpawnerOnMapStart()
{
	PrecacheSoundArray(g_SpawnStart);
	PrecacheSoundArray(g_SpawnEnd);
	PrecacheSoundArray(g_SpawnStartDo);
	PrecacheModel("models/editor/ground_node.mdl");
	PrecacheModel("models/editor/ground_node_hint.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Const2 Spawner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_const2_spawner");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int Const2Spawner_Id()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Const2Spawner(vecPos, vecAng, team, data);
}

methodmap Const2Spawner < CClotBody
{
	public void PlaySpawnSoundStart()
	{
		EmitSoundToAll(g_SpawnStart[GetRandomInt(0, sizeof(g_SpawnStart) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpawnSoundStartDo()
	{
		EmitSoundToAll(g_SpawnStartDo[GetRandomInt(0, sizeof(g_SpawnStartDo) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SpawnStartDo[GetRandomInt(0, sizeof(g_SpawnStartDo) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpawnSoundEnd() 
	{
		EmitSoundToAll(g_SpawnEnd[GetRandomInt(0, sizeof(g_SpawnEnd) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SpawnEnd[GetRandomInt(0, sizeof(g_SpawnEnd) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property int m_iSpawnerAm
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property bool m_bEnemyBase
	{
		public get()							{ return b_movedelay_walk[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_walk[this.index] = TempValueForProperty; }
	}
	public Const2Spawner(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		char DataAm[512];
		char buffers[2][256];
		bool EnemyBaseIs = false;
		Format(DataAm, sizeof(DataAm), "%s", data);
		if(StrContains(DataAm, ";enemy_base") != -1)
		{
			PrintToChatAll("confirm enemy_base");
			EnemyBaseIs = true;
			ReplaceString(DataAm, sizeof(DataAm), ";enemy_base", "");
		}
		/*
			0 : WaveData
			1 : Location
		*/

		ExplodeString(DataAm, ";", buffers, sizeof(buffers), sizeof(buffers[]));
	//	if(buffers[0][0])
	//		ExplodeString(buffers[0], " ", DataAm, sizeof(DataAm));
		if(buffers[1][0])
			ExplodeStringFloat(buffers[1], " ", vecPos, sizeof(vecPos));

		Const2Spawner npc = view_as<Const2Spawner>(CClotBody(vecPos, vecAng, "models/editor/ground_node.mdl", "1.0", "999999999", ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		Is_a_Medic[npc.index] = true;
		i_NpcIsABuilding[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		b_CantCollidie[npc.index] = true; 
		b_CantCollidieAlly[npc.index] = true; 
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath = true;
		b_HideHealth[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		npc.m_flSpeed = 0.0;

		//dont take up spawn edicts or whatever
		AddNpcToAliveList(npc.index, 1);

		static float flPos[3]; 
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 0.5;
		npc.m_iWearable2 = ParticleEffectAt(flPos, "utaunt_aestheticlogo_orange_lines", 0.0);


		if(!hConst2_SpawnerSaveWave)
			hConst2_SpawnerSaveWave = new ArrayList(sizeof(Const2SpawnerEnum));

		int SpawnArrayFree = 1;
		
		Const2SpawnerEnum Initdata;
		int length = hConst2_SpawnerSaveWave.Length;
		for(int i; i < length; i++)
		{
			// Loop through the arraylist to find the right attacker and victim
			hConst2_SpawnerSaveWave.GetArray(i, Initdata);
			if(!IsValidEntity(Initdata.SpawnerAmRef))
			{
				// No longer Valid
				hConst2_SpawnerSaveWave.Erase(i);
				i--;
				length--;
				continue;
			}
			if(SpawnArrayFree >= Rounds_MAX)
			{
				npc.m_flNextThinkTime = FAR_FUTURE;
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				PrintToChatAll("TOO MANY CONST2 SPAWNERS, STOP!!!!");
				return npc;
			}
			if(Initdata.SpawnerArrayAm == SpawnArrayFree)
			{
				SpawnArrayFree++;
				continue;
			}
			//found a free one.
		}
		Const2SpawnerEnum edata;
		// Create a new entry
		npc.m_bEnemyBase = EnemyBaseIs;

		edata.SpawnerAmRef = EntIndexToEntRef(npc.index);
		Format(edata.DataWave, sizeof(edata.DataWave), "%s", buffers[0]);
		edata.SpawnerArrayAm = SpawnArrayFree;
		hConst2_SpawnerSaveWave.PushArray(edata);
		
		npc.m_iSpawnerAm = SpawnArrayFree;

		return npc;
	}
}
bool DetectedEnemyHit_Const2;
static void ClotThink(int iNPC)
{
	Const2Spawner npc = view_as<Const2Spawner>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(!npc.m_bEnemyBase)
		f_DelayNextWaveStartAdvancingDeathNpc = GetGameTime() + 1.5;
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
//	npc.m_flNextThinkTime = gameTime + 0.1;
	npc.m_flNextThinkTime = gameTime + 0.25;

	switch(b_NoHealthbar[npc.index])
	{
		case 0:
		{
			if(Rounds[npc.m_iSpawnerAm])
			{
				//when a spawner is active, prevent end of waves
				npc.m_flNextThinkTime = gameTime + 0.5;
				int GroupBunchSpawn = RoundToNearest(4.0 * MultiGlobalEnemy);
				float SpawnLocation[3];
				GetAbsOrigin(npc.index, SpawnLocation);
				SpawnLocation[2] += 5.0;
				bool DidSpawn = false;
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
				
				for(int AmountSpawn; AmountSpawn < GroupBunchSpawn; AmountSpawn++)
				{
					if(npc.m_bEnemyBase)
					{
						if(EnemyNpcAliveConst2 >= MaxEnemiesAllowedSpawnNext())
						{	
							return;
						}
					}
					float PosRand[3];
					PosRand = SpawnLocation;
					PosRand[0] += GetRandomFloat(-50.0, 50.0);
					PosRand[1] -= GetRandomFloat(-50.0, 50.0);
					bool Succeed = Npc_Teleport_Safe(npc.index, PosRand, hullcheckmins, hullcheckmaxs, true, false);
					if(!Succeed)
						PosRand = SpawnLocation;

					int NpcForward = -1;
					if(NPC_SpawnNext(false, false, npc.m_iSpawnerAm, PosRand, NpcForward, npc.m_bEnemyBase))
					{
						//We keep track of static NPCS.
						if(npc.m_bEnemyBase && IsValidEntity(NpcForward))
							AddNpcToAliveList(NpcForward, 2);

						DidSpawn = true;
					}
				}
				if(DidSpawn)
				{
					npc.PlaySpawnSoundStart();
				}
			}
			else
			{
				npc.m_flNextThinkTime = gameTime + 9999.9;
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				npc.PlaySpawnSoundEnd();
				if(Dungeon_Mode())
				{
					float SpawnLocation[3];
					GetAbsOrigin(npc.index, SpawnLocation);
					Dungeon_WaveEnd(SpawnLocation, npc.m_bEnemyBase);
				}
			}
		}
		case 1:
		{
			DetectedEnemyHit_Const2 = false;
			Explode_Logic_Custom(0.0, 0, npc.index, 0, _, 400.0, _,_,true,_,_,_,_, DetectedEnemyHit_Const2_Internal);
			if(DetectedEnemyHit_Const2 && hConst2_SpawnerSaveWave)
			{
				Const2SpawnerEnum data;
				int length = hConst2_SpawnerSaveWave.Length;
				for(int i; i < length; i++)
				{
					// Loop through the arraylist to find the right attacker and victim
					hConst2_SpawnerSaveWave.GetArray(i, data);
					if(data.SpawnerAmRef == EntIndexToEntRef(npc.index))
					{
						
						static float flPos[3]; 
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 0.5;
						npc.m_iWearable1 = ParticleEffectAt(flPos, "utaunt_aestheticlogo_orange_beam", 0.0);
						npc.PlaySpawnSoundStartDo();
						

						npc.SetModel("models/editor/ground_node_hint.mdl");
						Spawner_CreateEnemies(npc.m_iSpawnerAm, data.DataWave);
						b_NoHealthbar[npc.index] = 0;
						hConst2_SpawnerSaveWave.Erase(i);
						i--;
						length--;
						continue;
					}
					else if(!IsValidEntity(data.SpawnerAmRef))
					{
						// No longer Valid
						hConst2_SpawnerSaveWave.Erase(i);
						i--;
						length--;
						continue;
					}
				}
			}
		}
	}
}

void DetectedEnemyHit_Const2_Internal(int entity, int victim, float damage, int weapon)
{
	DetectedEnemyHit_Const2 = true;
}
static void ClotDeath(int entity)
{
	Const2Spawner npc = view_as<Const2Spawner>(entity);
	//???
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}




static void Spawner_CreateEnemies(int SpawnerDo , const char[] data)
{
	char Buffer[512];
	BuildPath(Path_SM, Buffer, sizeof(Buffer), CONFIG_CFG, data);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(Buffer);
	Waves_SetupWaves(kv, false, SpawnerDo);
	delete kv;
}