#pragma semicolon 1
#pragma newdecls required

#include <adt_trie_sort>

static bool DungeonMode;
static ArrayList MusicList;	// MusicEnum
static ArrayList RaidList;	// StringMap
static ArrayList RoomList;	// RoomInfo
static StringMap LootMap;	// LootInfo
static float AttackTime;
static int MaxWaveScale;

enum struct LootInfo
{
	int Count;
	float Bonus;
	int Color[4];
	StringMap Items;

	bool SetupKv(const char[] name, KeyValues kv)
	{
		this.Items = new StringMap();

		if(kv.JumpToKey("Items"))
		{
			if(kv.GotoFirstSubKey(false))
			{
				char buffer[64];

				do
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					this.Items.SetValue(buffer, kv.GetNum(NULL_STRING));

					if(Rogue_GetNamedArtifact(buffer) == -1 && GetFunctionByName(null, buffer) == INVALID_FUNCTION)
						LogError("Unknown item '%s' for loot table '%s'", buffer, name);
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}

			kv.GoBack();
		}

		this.Count = kv.GetNum("count", 1);
		this.Bonus = kv.GetFloat("bonus");
		kv.GetColor4("color", this.Color);
		return true;
	}

	void RollLoot()
	{
		int count = this.Count;
		if(GetURandomFloat() < this.Bonus)	
			count++;
		
		for(int a; a < count; a++)
		{
			ArrayList list = new ArrayList();
			StringMapSnapshot snap = this.Items.Snapshot();

			int common;
			int length = snap.Length;
			for(int b; b < length; b++)
			{
				int size = snap.KeyBufferSize(b) + 1;
				char[] buffer = new char[size];
				snap.GetKey(b, buffer, size);

				if(Rogue_HasNamedArtifact(buffer))
					continue;
				
				this.Items.GetValue(buffer, common);
				for(int c; c < common; c++)
				{
					list.Push(b);
				}
			}

			length = list.Length;
			if(length < 1)
				break;
			
			length = GetURandomInt() % length;
			length = list.Get(length);
			delete list;

			common = snap.KeyBufferSize(length) + 1;
			char[] buffer = new char[common];
			snap.GetKey(length, buffer, common);
			delete snap;

			Function func = GetFunctionByName(null, buffer);
			if(func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_Finish();
			}
			else if(LootMap.ContainsKey(buffer))
			{
				Dungeon_RollNamedLoot(buffer);
			}
			else
			{
				Rogue_GiveNamedArtifact(buffer);
			}
		}

		EmitSoundToAll("ui/itemcrate_smash_rare.wav");
	}

	void Clean()
	{
		delete this.Items;
	}
}

enum struct RoomInfo
{
	char Name[64];
	int Common;
	int Victory;
	int MinWave;
	int MaxWave;
	float WaveChance;
	int WaveAmount;
	float LootScale;
	float Timelimit;
	float Cooldown;
	float CurrentCooldown;
	char Spawn[32];
	char Key[64];
	Function FuncStart;

	StringMap Fights;
	StringMap Loots;

	bool SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));
		if(FailTranslation(this.Name))
			return false;

		char buffer[PLATFORM_MAX_PATH];
		
		if(kv.JumpToKey("Fights"))
		{
			this.Fights = new StringMap();

			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(this.Key, sizeof(this.Key));
					this.Fights.SetValue(this.Key, kv.GetNum(NULL_STRING));

					if(this.Key[0])
					{
						BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, this.Key);
						if(!FileExists(buffer))
						{
							LogError("Unknown waveset '%s' for room '%s'", this.Key, this.Name);
						}
						else
						{
							KeyValues wavekv = new KeyValues("Waves");

							wavekv.ImportFromFile(buffer);
							Waves_CacheWaves(wavekv, true);

							delete wavekv;
						}
					}
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}

			kv.GoBack();
		}
		else
		{
			this.Fights = null;
		}

		if(kv.JumpToKey("Loots"))
		{
			this.Loots = new StringMap();

			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(this.Key, sizeof(this.Key));
					this.Loots.SetValue(this.Key, kv.GetNum(NULL_STRING));

					if(Rogue_GetNamedArtifact(this.Key) == -1 && !LootMap.ContainsKey(this.Key))
						LogError("Unknown loot table '%s' for room '%s'", this.Key, this.Name);
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}

			kv.GoBack();
		}
		else
		{
			this.Loots = null;
		}

		this.Common = kv.GetNum("common", 1);
		this.Victory = kv.GetNum("victory");
		this.WaveChance = kv.GetFloat("wavechance", -0.001);
		this.WaveAmount = kv.GetNum("waveamount");
		this.LootScale = kv.GetFloat("lootscale");
		this.Timelimit = kv.GetFloat("timelimit");
		this.Cooldown = kv.GetFloat("cooldown");
		this.MinWave = kv.GetNum("minwave", -9999);
		this.MaxWave = kv.GetNum("maxwave", 9999);
		kv.GetString("spawn", this.Spawn, sizeof(this.Spawn));
		kv.GetString("key", this.Key, sizeof(this.Key));
		this.FuncStart = KvGetFunction(kv, "func_start");
		return true;
	}

	void RollLoot(bool victory)
	{
		if(!this.Loots)
			return;
		
		int count = victory ? this.Victory : 0;
		if(!victory)
		{
			for(int a; a < this.WaveAmount; a++)
			{
				if(GetURandomFloat() < this.WaveChance)
					count++;
			}
		}

		for(int a; a < count; a++)
		{
			ArrayList list = new ArrayList();
			StringMapSnapshot snap = this.Loots.Snapshot();

			int common;
			int length = snap.Length;
			for(int b; b < length; b++)
			{
				int size = snap.KeyBufferSize(b) + 1;
				char[] buffer = new char[size];
				snap.GetKey(b, buffer, size);

				this.Loots.GetValue(buffer, common);
				for(int c; c < common; c++)
				{
					list.Push(b);
				}
			}

			length = GetURandomInt() % list.Length;
			length = list.Get(length);
			delete list;

			common = snap.KeyBufferSize(length) + 1;
			char[] buffer = new char[common];
			snap.GetKey(length, buffer, common);
			delete snap;

			if(!victory)
			{
				Dungeon_SpawnLoot(buffer, this.LootScale);
			}
			else if(LootMap.ContainsKey(buffer))
			{
				CPrintToChatAll("%t", "Found Dungeon Loot", buffer);

				LootInfo loot;
				LootMap.GetArray(buffer, loot, sizeof(loot));
				loot.RollLoot();

				Dungeon_AddBattleScale(this.LootScale);
			}
			else
			{
				Rogue_GiveNamedArtifact(buffer);
				Dungeon_AddBattleScale(this.LootScale);
			}
		}
	}

	void Clean()
	{
		delete this.Fights;
		delete this.Loots;
	}
}

static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// 0 = None, 1 = Room, 2 = Base, 3 = Final
static Handle GameTimer;
static float BattleTimelimit;
static float DelayVoteFor;
static int LastRoomIndex;
static float BattleWaveScale;
static float EnemyScaling;

void Dungeon_PluginStart()
{
	LoadTranslations("zombieriot.phrases.dungeon"); 
}

bool Dungeon_Mode()
{
	return DungeonMode;
}

bool Dungeon_Started()
{
	return Dungeon_Mode() && GameRules_GetRoundState() == RoundState_ZombieRiot;
}

bool Dungeon_InSetup()
{
	return Dungeon_Mode() && AttackType < 2;
}

bool Dungeon_PeaceTime()
{
	return Dungeon_Mode() && AttackType < 1;
}

bool Dungeon_FinalBattle()
{
	return Dungeon_Mode() && (CurrentAttacks + 1) >= RaidList.Length;
}

int Dungeon_GetRound()
{
	if(AttackType > 1)
	{
		int maxAttacks = RaidList.Length;
		if(!maxAttacks)
			return MaxWaveScale;
		
		return (CurrentAttacks * MaxWaveScale / maxAttacks)
	}
	
	return RoundToFloor(BattleWaveScale);
}

void Dungeon_MapStart()
{
	DungeonMode = false;
	Dungeon_RoundEnd();
}

// Waves_SetupVote
void Dungeon_SetupVote(KeyValues kv)
{
	PrecacheMvMIconCustom("classic_defend", false);
	PrecacheSound("ui/chime_rd_2base_pos.wav");
	PrecacheSound("ui/chime_rd_2base_neg.wav");
	PrecacheSound("ui/itemcrate_smash_rare.wav");

	DungeonMode = true;

	Rogue_SetupVote(kv, "Dungeon");

	if(RaidList)
	{
		int length = RaidList.Length;
		for(int i; i < length; i++)
		{
			CloseHandle(RaidList.Get(i));
		}
		delete RaidList;
	}

	LootInfo loot;
	if(LootMap)
	{
		StringMapSnapshot snap = LootMap.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] buffer = new char[size];
			snap.GetKey(i, buffer, size);
			LootMap.GetArray(buffer, loot, sizeof(loot));
			loot.Clean();
		}
		delete snap;
		delete LootMap;
	}

	RoomInfo room;
	if(RoomList)
	{
		int length = RoomList.Length;
		for(int i; i < length; i++)
		{
			RoomList.GetArray(i, room);
			room.Clean();
		}
		delete RoomList;
	}

	MusicEnum music;
	if(MusicList)
	{
		int length = MusicList.Length;
		for(int i; i < length; i++)
		{
			MusicList.GetArray(i, music);
			music.Clear();
		}
		delete MusicList;
	}

	MusicList = new ArrayList(sizeof(MusicEnum));
	RaidList = new ArrayList();
	LootMap = new StringMap();
	RoomList = new ArrayList(sizeof(RoomInfo));

	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];
	
	if(kv.JumpToKey("Loots"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(buffer1, sizeof(buffer1));
				if(loot.SetupKv(buffer1, kv))
				{
					if(!LootMap.SetArray(buffer1, loot, sizeof(loot), false))
						loot.Clean();
				}
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("Rooms"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(room.SetupKv(kv))
					RoomList.PushArray(room);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("Raids"))
	{
		AttackTime = kv.GetFloat("delay", 300.0);
		MaxWaveScale = kv.GetNum("maxwave", 39);

		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(kv.GotoFirstSubKey(false))
				{
					StringMap map = new StringMap();

					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						kv.GetString(NULL_STRING, buffer2, sizeof(buffer2));
						map.SetString(buffer1, buffer2);
					}
					while(kv.GotoNextKey(false));

					RaidList.Push(map);

					kv.GoBack();
				}
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("RandomMusic"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(music.SetupKv("", kv))
					MusicList.PushArray(music);
			}
			while(kv.GotoNextKey());
		}

		kv.GoBack();
	}

	SteamWorks_UpdateGameTitle();
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			Waves_RoundStart();
			break;
		}
	}

	Waves_SetReadyStatus(2);
}

// Waves_RoundStart()
void Dungeon_StartSetup()
{
	Zero(PlayerVotedForThis);
	Rogue_StartSetup();
	Construction_RoundEnd();

	NextAttackAt = 0.0;
	BattleWaveScale = 0.0;

	delete GameTimer;
	GameTimer = CreateTimer(1.0, Timer_WaitingPeriod, _, TIMER_REPEAT);
	
	//Just incase, reget spawnsers, beacuse its way too fast and needs a frame, start setup is too fast!
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		SDKHook_TeamSpawn_SpawnPostInternal(ent, _, _, _);
	}
/*
	ArrayList list = new ArrayList();
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red)
		{
			list.Push(i);
		}
	}

	int length = list.Length;
	if(length <= 0)
	{
		PrintToChatAll("%i Construction_StartSetup() SOMEHOW HAD 0 SPAWNERS????????",length);
		delete list;
		return;
	}
	int choosen = GetURandomInt() % length;
	for(int i; i < length; i++)
	{
		int index = list.Get(i);
		SetEntProp(i_ObjectsSpawners[index], Prop_Data, "m_bDisabled", index != choosen);
	}

	delete list;
	*/
}

void Dungeon_RoundEnd()
{
	CurrentAttacks = 0;
	DelayVoteFor = 0.0;
	delete GameTimer;
	AttackType = 0;
	EnemyScaling = 0.0;
}

static Action Timer_WaitingPeriod(Handle timer)
{
	float pos1[3], pos2[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
			break;
		}
	}

	if(CvarInfiniteCash.BoolValue)
		return Plugin_Continue;
		
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetClientAbsOrigin(client, pos2);
			if(GetVectorDistance(pos1, pos2, true) > 900000.0)
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos1, {0.0, 0.0, 0.0});
			}
		}
	}
	
	return Plugin_Continue;
}

// Rogue_RoundStartTimer()
void Dungeon_Start()
{
	delete GameTimer;

	float pos[3], ang[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
			break;
		}
	}

	NextAttackAt = GetGameTime() + AttackTime;
	GameTimer = CreateTimer(0.5, DungeonMainTimer);
	Ammo_Count_Ready = 20;

	NPC_CreateByName("npc_base_building", -1, pos, ang, TFTeam_Red);

	int highestLevel;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			int amount = SkillTree_GetByName(client, "Ingot Up 1");
			if(amount > highestLevel)
				highestLevel = amount;
			
			Music_Stop_All(client);
			SetMusicTimer(client, GetTime() + 35);
		}
	}

	int startingIngots = highestLevel + 8;
	//Rogue_AddIngots(startingIngots, true);
	Construction_AddMaterial("crystal", startingIngots, true);

	SetRandomMusic();
}

static void SetRandomMusic()
{
	int length = MusicList.Length;
	if(length)
	{
		static MusicEnum music;
		MusicList.GetArray(GetURandomInt() % length, music);
		music.CopyTo(BGMusicSpecial1);
	}
}

void Dungeon_AntiStalled()
{
	switch(AttackType)
	{
		case 1:
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsPlayerAlive(client))
				{
					if(!Dungeon_EntityAtBase(client))
						ForcePlayerSuicide(client, true);
				}
			}
		}
		case 2:
		{
			ForcePlayerLoss();
		}
	}
}

void Dungeon_TeleportRandomly(float pos[3])
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && !Dungeon_EntityAtBase(client, true))
			{
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
				break;
			}
		}
	}

	CNavArea goalArea = TheNavMesh.GetNavArea(pos, 1000.0);
	if(goalArea == NULL_AREA)
	{
		PrintToChatAll("ERROR: Could not find valid nav area for location (%f %f %f)", pos[0], pos[1], pos[2]);
		return;
	}

	for(int i; i < 50; i++)
	{
		CNavArea startArea = PickRandomArea();
		if(startArea == NULL_AREA)
			continue;
		
		if(startArea.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
			continue;
		
		if(!TheNavMesh.BuildPath(startArea, goalArea, pos))
			continue;
		
		startArea.GetCenter(pos);
		break;
	}

	pos[2] += 10.0;
}

void Dungeon_SpawnLoot(const char[] name, float waveScale)
{
	float pos[3];
	Dungeon_TeleportRandomly(pos);

	DungeonLoot npc = view_as<DungeonLoot>(NPC_CreateById(DungeonLoot_Id(), 0, pos, NULL_VECTOR, 3));
	npc.SetLootData(name, waveScale);
}

bool Dungeon_EntityAtBase(int client, bool outOfBoundsResult = false)
{
	CNavArea endNav = TheNavMesh.GetNavAreaEntity(client, GETNAVAREA_ALLOW_BLOCKED_AREAS, 1000.0);
	if(endNav == NULL_AREA)
		return outOfBoundsResult;
	
	float pos[3];
	CNavArea startNav;
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			startNav = TheNavMesh.GetNavArea(pos);
			break;
		}
	}

	if(startNav == NULL_AREA)
		return outOfBoundsResult;
	
	return TheNavMesh.BuildPath(endNav, startNav, pos);
}

static Action DungeonMainTimer(Handle timer)
{
	float time = NextAttackAt - GetGameTime();
	if(time > 0.0)
	{
		if(AttackType == 1)
		{
			/*
				Check if anyone out on the field is alive
			*/
			bool alive;
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && !Dungeon_EntityAtBase(client, true))
					{
						alive = true;
						break;
					}
				}
			}

			if(!alive)
				BattleLosted();
		}
		else if(AttackType < 1 && time > 99.0 && DelayVoteFor < GetGameTime() && !Rogue_VoteActive())
		{
			/*
				Dungeon Room Voting
			*/
			RoomInfo room;
			ArrayList roomPool;
			int highestCommon;
			int round = RoundToFloor(BattleWaveScale);
			int length = RoomList.Length;
			for(int a; a < length; a++)
			{
				RoomList.GetArray(a, room);

				if(room.Common > highestCommon)
					highestCommon = room.Common;

				if(room.CurrentCooldown > GetGameTime())
					continue;
				
				if(room.MinWave > round || room.MaxWave < round)
					continue;

				if(room.Key[0] && !Rogue_HasNamedArtifact(room.Key))
				{
					Function func = GetFunctionByName(null, room.Key);
					if(func == INVALID_FUNCTION)
						continue;
					
					bool value;
					Call_StartFunction(null, func);
					Call_Finish(value);
					if(!value)
						continue;
				}

				for(int b; b < room.Common; b++)
				{
					roomPool.Push(a);
				}
			}

			// Removes all commons
			if(Rogue_HasNamedArtifact("Dungeon Compass"))
			{
				highestCommon--;
				for(int a; a < length; a++)
				{
					RoomList.GetArray(a, room);
					if(room.Common >= highestCommon)
					{
						for(int b; (b = roomPool.FindValue(a)) != -1; )
						{
							roomPool.Erase(b);
						}
					}
				}

				Rogue_RemoveNamedArtifact("Dungeon Compass");
			}

			Vote vote;
//			ArrayList voting = Rogue_CreateGenericVote(Dungeon_RoomVote, "Dungeon Room Vote");

			int count = 1;//(GetURandomInt() % 5) ? 2 : 3;
			for(int a; a < count; a++)
			{
				length = roomPool.Length;
				if(length < 1)
					break;
				
				int index = roomPool.Get(GetURandomInt() % length);

				RoomList.GetArray(index, room);
				room.CurrentCooldown = room.Cooldown + GetGameTime();
				RoomList.SetArray(index, room);

				strcopy(vote.Name, sizeof(vote.Name), room.Name);
				IntToString(index, vote.Config, sizeof(vote.Config));
/*				voting.PushArray(vote);

				for(int b; (b = roomPool.FindValue(index)) != -1; )
				{
					roomPool.Erase(b);
				}
*/
				Dungeon_RoomVote(vote);
			}
/*
			strcopy(vote.Name, sizeof(vote.Name), time < 130.0 ? "Dungeon Stop Looking" : "Dungeon Keep Looking");
			vote.Desc[0] = 0;
			IntToString(-1, vote.Config, sizeof(vote.Config));
			voting.PushArray(vote);

			Rogue_StartGenericVote(30.0);
			DelayVoteFor = GetGameTime() + 31.0;
*/
		}

		GameTimer = CreateTimer(0.5, DungeonMainTimer);
		Waves_UpdateMvMStats();
		return Plugin_Stop;
	}

	/*
		Raid Attack
	*/

	CurrentAttacks++;
	LastRoomIndex = -1;
	EnemyScaling = 0.0;

	int index = -1;
	bool final = CurrentAttacks >= RaidList.Length;
	AttackType = final ? 3 : 2;

	Rogue_SetBattleIngots(CurrentAttacks > 1 ? 6 : 5);
	
	float pos1[3], pos2[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
			break;
		}
	}
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red && i_NpcInternalId[entity] != Remain_ID())
			{
				TeleportEntity(entity, pos1);
				SaveLastValidPositionEntity(entity, pos1);
			}
			else
			{
				f_CreditsOnKill[entity] = 0.0;
				SmiteNpcToDeath(entity);
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity] && !Dungeon_EntityAtBase(entity))
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			DeleteAndRefundBuilding(builder_owner, entity);
		}
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
			{
				GetClientAbsOrigin(client, pos2);
				if(GetVectorDistance(pos1, pos2, true) > 900000.0)
				{
					Vehicle_Exit(client, false, false);
					TeleportEntity(client, pos1, {0.0, 0.0, 0.0});
					SaveLastValidPositionEntity(client, pos1);
				}
				
				Store_ApplyAttribs(client);
				Store_GiveAll(client, GetClientHealth(client));
			}
			else if(GetClientTeam(client) == 2)
			{
				DHook_RespawnPlayer(client);
			}

			if(!b_IsPlayerABot[client])
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 1);
			}
		}
	}

	BGMusicSpecial1.Clear();

	char buffer1[PLATFORM_MAX_PATH], buffer2[64];

	StringMap map = RaidList.Get(CurrentAttacks - 1);
	SortedSnapshot snap = CreateSortedSnapshot(map, Sort_Random);
	int length = snap.Length;
	for(int i; i < length; i++)
	{
		snap.GetKey(i, buffer1, sizeof(buffer1));
		map.GetString(buffer1, buffer2, sizeof(buffer2));
		if(buffer2[0])
		{
			if(!Rogue_HasNamedArtifact(buffer2))
			{
				Function func = GetFunctionByName(null, buffer2);
				if(func == INVALID_FUNCTION)
					continue;
				
				bool value;
				Call_StartFunction(null, func);
				Call_Finish(value);
				if(!value)
					continue;
			}
		}
		else if(index != -1)
		{
			continue;
		}
		
		index = i;
	}

	if(index != -1)
	{
		snap.GetKey(index, buffer2, sizeof(buffer2));
		BuildPath(Path_SM, buffer1, sizeof(buffer1), CONFIG_CFG, buffer2);
		KeyValues kv = new KeyValues("Waves");
		kv.ImportFromFile(buffer1);
		Waves_SetupWaves(kv, false);
		delete kv;

		Rogue_TriggerFunction(Artifact::FuncStageStart);
		RemoveAllCustomMusic();
		CreateTimer(float(AttackType * AttackType), Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		SetBattleTimelimit(AttackTime - 3.0);
	}
	else
	{
		PrintToChatAll("NO BATTLE %d???? REPORT THIS BUG", CurrentAttacks);
	}
	
	delete snap;

	if(final)
	{
		NextAttackAt = 0.0;
		GameTimer = null;
	}
	else
	{
		NextAttackAt = GetGameTime() + AttackTime;
		GameTimer = CreateTimer(0.5, DungeonMainTimer);
	}
	return Plugin_Stop;
}

static void SetBattleTimelimit(float time)
{
	BattleTimelimit = time > 0.0 ? (GetGameTime() + time - 520.0) : GetGameTime() + 420.0;
	WaveStart_SubWaveStart(BattleTimelimit);
}

static stock void DecreaseBattleTimelimit(float time)
{
	if(BattleTimelimit && BattleTimelimit > GetGameTime())
	{
		BattleTimelimit -= time;
		if(BattleTimelimit < GetGameTime())
			BattleTimelimit = GetGameTime();
		
		WaveStart_SubWaveStart(BattleTimelimit);
	}
}

void Dungeon_DelayVoteFor(float time)
{
	DelayVoteFor = GetGameTime() + time;
}

static void Dungeon_RoomVote(const Vote vote)
{
	LastRoomIndex = StringToInt(vote.Config);
	if(LastRoomIndex != -1)
	{
		RoomInfo room;
		RoomList.GetArray(LastRoomIndex, room);

		Rogue_SetBattleIngots(0);

		float time = room.Fights ? 0.0 : 5.0;
		if(room.FuncStart != INVALID_FUNCTION)
		{
			Call_StartFunction(null, room.FuncStart);
			Call_Finish(time);
		}

		if(!time && room.Fights)
		{
			StartBattle(room);
		}
		else
		{
			Dungeon_DelayVoteFor(time);
		}

		float pos[3], ang[3];

		char buffer[64];
		int entity = -1;
		while((entity = FindEntityByClassname(entity, "info_teleport_destination")) != -1)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, room.Spawn, false))
			{
				if(!pos[0] || (GetURandomInt() % 2))
				{
					GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
				}
			}
		}

		if(!pos[0])
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(IsValidEntity(i_ObjectsSpawners[i]))
				{
					GetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", buffer, sizeof(buffer));
					if(StrEqual(buffer, room.Spawn, false))
					{
						if(!pos[0] || (GetURandomInt() % 2))
						{
							GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
							GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
						}
					}
				}
			}
		}

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos, ang, NULL_VECTOR);
				SaveLastValidPositionEntity(client, pos);
			}
		}
		
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) == TFTeam_Red && i_NpcInternalId[entity] != Remain_ID())
				{
					TeleportEntity(entity, pos, ang, NULL_VECTOR);
					SaveLastValidPositionEntity(entity, pos);
				}
				else
				{
					f_CreditsOnKill[entity] = 0.0;
					SmiteNpcToDeath(entity);
				}
			}
		}

		for(int i; i < i_MaxcountBuilding; i++)
		{
			entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
			if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity] && !Dungeon_EntityAtBase(entity))
			{
				int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				DeleteAndRefundBuilding(builder_owner, entity);
			}
		}
	}
}

stock void Dungeon_StartThisBattle(float time = 10.0)
{
	RoomInfo room;
	RoomList.GetArray(LastRoomIndex, room);
	
	StartBattle(room, time);
}

static void StartBattle(const RoomInfo room, float time = 3.0)
{
	if(!room.Fights)
		return;

	AttackType = 1;
	int scale;
	int round = Dungeon_GetRound();

	char buffer[PLATFORM_MAX_PATH];
	ArrayList list = new ArrayList();

	StringMapSnapshot snap = room.Fights.Snapshot();
	int length = snap.Length;
	for(int a; a < length; a++)
	{
		snap.GetKey(a, buffer, sizeof(buffer));
		room.Fights.GetValue(buffer, scale);

		int common = (MaxWaveScale - abs(MaxWaveScale - scale));
		if(common < (MaxWaveScale / 2))
			continue;
		
		common /= 4;
		for(int b; b < common; b++)
		{
			list.Push(a);
		}
	}
	
	int index = list.Length;
	if(index < 0)
	{
		for(int a; a < length; a++)
		{
			list.Push(a);
		}

		index = list.Length;
	}
	
	index = index > 0 ? list.Get(GetURandomInt() % index) : -1;
	if(index != -1)
	{
		snap.GetKey(index, buffer, sizeof(buffer));

		room.Fights.GetValue(buffer, scale);
		EnemyScaling = ScaleBasedOnRound(round) / ScaleBasedOnRound(scale);

		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);
		KeyValues kv = new KeyValues("Waves");
		kv.ImportFromFile(buffer);
		Waves_SetupWaves(kv, false);
		delete kv;

		Rogue_TriggerFunction(Artifact::FuncStageStart);
		RemoveAllCustomMusic();
		CreateTimer(time, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		PrintToChatAll("NO ROOM %s???? REPORT THIS BUG", room.Name);
	}

	delete snap;

	float limit = room.Timelimit;
	if(limit < 1.0)
		limit = 420.0;

	float maxLimit = NextAttackAt - GetGameTime();
	if(limit > maxLimit)
		limit = maxLimit;

	SetBattleTimelimit(limit);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			Store_ApplyAttribs(client);
			Store_GiveAll(client, GetClientHealth(client));
		}
	}
}

void Dungeon_BattleVictory()
{
	Waves_RoundEnd();
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();
	
	int ingots = Rogue_GetBattleIngots();
	if(ingots)
		Construction_AddMaterial("crystal", ingots);

	if(LastRoomIndex != -1 && AttackType == 1)
	{
		RoomInfo room;
		RoomList.GetArray(LastRoomIndex, room);
		room.RollLoot(true);
	}

	if(AttackType == 2)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + GetRandomInt(90, 150));
			}
		}

		SetRandomMusic();
	}
	
	Zero(i_AmountDowned);
	AttackType = 0;
}

static void BattleLosted()
{
	Waves_RoundEnd();
	bool victory = false;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();
	
	Zero(i_AmountDowned);
	AttackType = 0;
	
	float pos[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			break;
		}
	}
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red && i_NpcInternalId[entity] != Remain_ID())
			{
				TeleportEntity(entity, pos);
				SaveLastValidPositionEntity(entity, pos);
			}
			else
			{
				f_CreditsOnKill[entity] = 0.0;
				SmiteNpcToDeath(entity);
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity] && !Dungeon_EntityAtBase(entity))
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			DeleteAndRefundBuilding(builder_owner, entity);
		}
	}

	CPrintToChatAll("{crimson}%t", "Dungeon Failed");
	DelayVoteFor = GetGameTime() + 5.0;
}

void Dungeon_WaveEnd(bool final)
{
	if(!final && LastRoomIndex != -1 && AttackType == 1)
	{
		RoomInfo room;
		RoomList.GetArray(LastRoomIndex, room);
		room.RollLoot(false);
	}
}

bool Dungeon_LootExists(const char[] name)
{
	return LootMap && LootMap.ContainsKey(name);
}

bool Dungeon_GetNamedLoot(const char[] name, LootInfo loot)
{
	return LootMap && LootMap.GetArray(name, loot, sizeof(loot));
}

void Dungeon_RollNamedLoot(const char[] name)
{
	LootInfo loot;
	if(LootMap && LootMap.GetArray(name, loot, sizeof(loot)))
		loot.RollLoot();

	PrintToChatAll("UNKNOWN LOOT \"%s\", REPORT BUG", name);
}

void Dungeon_AddBattleScale(float scale)
{
	BattleWaveScale += scale;
}

static float ScaleBasedOnRound(int round)
{
	return (500.0 + Pow(float(round), 2.6));
}

void Dungeon_EnemySpawned(int entity)
{
	if(Dungeon_Mode() && i_NpcInternalId[entity] != DungeonLoot_Id())
	{
		// Reward cash depending on the wave scaling and how much left
		if(AttackType < 2)
		{
			int round = Dungeon_GetRound();
			if(round > 39)
				round = 39;
			
			int current = CurrentCash - GlobalExtraCash;

			int a, other;
			while((other = FindEntityByNPC(a)) != -1)
			{
				if(!b_NpcHasDied[other] && GetTeam(other) != TFTeam_Red)
					current += RoundFloat(f_CreditsOnKill[other]);
			}

			int goal = DefaultTotalCash(round);
			if(current < goal)
			{
				int reward = (goal - current) / (b_thisNpcIsABoss[entity] ? 5 : 50);
				if(reward < 5)
					reward = 5;
				
				f_CreditsOnKill[entity] += float(reward / 5 * 5);
			}
		}

		if(EnemyScaling > 0.0)
		{
			fl_Extra_Damage[entity] *= 1.0 + ((EnemyScaling - 1.0) / 3.0);
			
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * EnemyScaling));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * EnemyScaling));
		}
	}
}

bool Dungeon_UpdateMvMStats()
{
	if(!Dungeon_Mode() || AttackType > 0)
		return false;
	
	int objective = FindEntityByClassname(-1, "tf_objective_resource");
	if(objective != -1)
	{
		int itemCount, worldMoney;
		float gameTime = GetGameTime();

		if(AttackType == 1)
		{
			int round = Dungeon_GetRound();
			if(round > 39)
				round = 39;
			
			int current = CurrentCash - GlobalExtraCash;
			int goal = DefaultTotalCash(round);

			if(current < goal)
				worldMoney = goal - current;
		}

		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", worldMoney);

		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", CurrentAttacks);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", RaidList.Length + 1);

		StringMap map = Construction_GetMaterialStringMap();
		StringMapSnapshot snap = map ? map.Snapshot() : null;
		int snapLength = snap ? snap.Length : 0;
		int snapPos;

		for(int i; i < 24; i++)
		{
			switch(i)
			{
				case 0:
				{
					if(NextAttackAt)
					{
						int time = RoundToCeil(NextAttackAt - gameTime);
						int flags = (CurrentAttacks + 1) < RaidList.Length ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
						if(time < 100)
							flags += MVM_CLASS_FLAG_ALWAYSCRIT;
						
						itemCount += time;
						Waves_SetWaveClass(objective, i, time, "classic_defend", flags, true);
						continue;
					}
				}
				case 1:
				{
					static int LastRound;
					static int FrameCount;

					int round = RoundToFloor(BattleWaveScale);
					int flags = round < 39 ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;

					if(LastRound != round)
					{
						flags += MVM_CLASS_FLAG_ALWAYSCRIT;

						if(FrameCount > 2)
						{
							FrameCount = 0;
							LastRound = round;
						}
						else
						{
							FrameCount++;
						}
					}
					
					itemCount += round + 1;
					Waves_SetWaveClass(objective, i, round + 1, "robo_extremethreat", flags, true);
					continue;
				}
				/*case 2:
				{
					itemCount += Rogue_GetIngots();
					Waves_SetWaveClass(objective, i, Rogue_GetIngots(), "rogue_ingots", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}*/
				default:
				{
					bool found;
					while(snapPos < snapLength)
					{
						static const char prefix[] = "material_";

						int size = snap.KeyBufferSize(snapPos) + strlen(prefix) + 1;
						char[] key = new char[size];
						snap.GetKey(snapPos, key, size);
						snapPos++;

						int amount;
						map.GetValue(key, amount);
						if(amount > 0)
						{
							Format(key, size, "%s%s", prefix, key);

							itemCount += amount;
							Waves_SetWaveClass(objective, i, amount, key, MVM_CLASS_FLAG_NORMAL, true);
							found = true;
							break;
						}
					}

					if(found)
						continue;
				}
			}

			Waves_SetWaveClass(objective, i);
		}

		// Use the bar as a timer for room timelimit
		float timeLeft = BattleTimelimit + 520.0 - gameTime;
		float timeMax = NextAttackAt - gameTime;
		if(timeLeft > timeMax)
			timeLeft = timeMax - 1.0;
		
		float ratio = (timeLeft > 0.0 && timeMax > 0.0) ? (timeLeft / timeMax) : 0.0;

		int count = itemCount + RoundToFloor((1.0 - ratio) * 199.0 * float(itemCount));
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", count);
	}

	return true;
}

#include "roguelike/dungeon_items.sp"
#include "roguelike/dungeon_encounters.sp"