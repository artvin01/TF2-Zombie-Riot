#pragma semicolon 1
#pragma newdecls required

#include <adt_trie_sort>

static bool DungeonMode;
static ArrayList MusicList;	// DMusicInfo
static ArrayList RaidList;	// StringMap
static ArrayList RoomList;	// RoomInfo
static ArrayList BaseList;	// RoomInfo
static StringMap LootMap;	// LootInfo
static float AttackTime;
static int MaxWaveScale;
static char TeleHome[64];
static char TeleRival[64];
static char TeleEnter[64];
static char TeleNext[64];

enum struct DMusicInfo
{
	int Common;
	int MinAttack;
	int MaxAttack;
	//int Duration;
	char Key[64];
	MusicEnum Music;

	bool SetupKv(KeyValues kv)
	{
		if(!this.Music.SetupKv("", kv))
			return false;
		
		//this.Duration = this.Music.Time;
		//this.Music.Time = 9999;
		this.Common = kv.GetNum("common", 1);
		this.MinAttack = kv.GetNum("minattack", -9999);
		this.MaxAttack = kv.GetNum("maxattack", 9999);
		kv.GetString("key", this.Key, sizeof(this.Key));
		return true;
	}
}

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

					//if(Rogue_GetNamedArtifact(buffer) == -1 && GetFunctionByName(null, buffer) == INVALID_FUNCTION)
					//	LogError("Unknown item '%s' for loot table '%s'", buffer, name);
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
			{
				delete list;
				break;
			}
			
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
	}

	void Clean()
	{
		delete this.Items;
	}
}

enum struct RoomInfo
{
	//char Name[64];
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
		char name[64];
		kv.GetSectionName(name, sizeof(name));
		//if(FailTranslation(this.Name))
		//	return false;

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
							LogError("Unknown waveset '%s' for room '%s'", this.Key, name);
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
						LogError("Unknown loot table '%s' for room '%s'", this.Key, name);
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

	void RollLoot(const float spawnPos[3] = NULL_VECTOR)
	{
		if(!this.Loots)
			return;
		
		bool victory = IsNullVector(spawnPos);
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
				Dungeon_SpawnLoot(spawnPos, buffer, this.LootScale);
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

		if(victory && count)
			EmitSoundToAll("ui/itemcrate_smash_rare.wav");
	}

	void Clean()
	{
		delete this.Fights;
		delete this.Loots;
	}
}

enum DungeonZone
{
	Zone_Unknown = 0,
	Zone_HomeBase,
	Zone_RivalBase,
	Zone_Dungeon,
	Zone_DungeonWait,	// Waiting for next dungeon room
	
	Zone_MAX
}

static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// -1 = Rival Setup, 0 = None, 1 = Room, 2 = Base, 3 = Final
static Handle GameTimer;
static float BattleTimelimit;
static float DelayVoteFor;
static int CurrentRoomIndex = -1;
static int NextRoomIndex = -1;
static int CurrentBaseIndex = -1;
static float BattleWaveScale;
static float EnemyScaling;
static DungeonZone LastZone[MAXENTITIES];
static int ZoneMarkerRef[Zone_MAX] = {-1, ...};

void Dungeon_PluginStart()
{
	LoadTranslations("zombieriot.phrases.dungeon");
	HookEntityOutput("trigger_multiple", "OnStartTouch", TriggerStartTouch);
}

void Dungeon_EntityCreated(int entity)
{
	LastZone[entity] = Zone_Unknown;
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

bool Dungeon_FinalBattle()
{
	return Dungeon_Mode() && (CurrentAttacks + 1) >= RaidList.Length;
}

int Dungeon_GetRound(bool forceTime = false)
{
	if(AttackType > 1 || forceTime)
	{
		int maxAttacks = RaidList.Length;
		if(!maxAttacks)
			return MaxWaveScale;
		
		int current = (CurrentAttacks * MaxWaveScale / maxAttacks);
		int ongoing = RoundToFloor((AttackTime - (NextAttackAt - GetGameTime())) / AttackTime * float(MaxWaveScale) / float(maxAttacks));
		return current + ongoing;
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

	if(BaseList)
	{
		int length = BaseList.Length;
		for(int i; i < length; i++)
		{
			BaseList.GetArray(i, room);
			room.Clean();
		}
		delete BaseList;
	}

	DMusicInfo music;
	if(MusicList)
	{
		int length = MusicList.Length;
		for(int i; i < length; i++)
		{
			MusicList.GetArray(i, music);
			music.Music.Clear();
		}
		delete MusicList;
	}

	MusicList = new ArrayList(sizeof(DMusicInfo));
	RaidList = new ArrayList();
	LootMap = new StringMap();
	RoomList = new ArrayList(sizeof(RoomInfo));
	BaseList = new ArrayList(sizeof(RoomInfo));

	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];

	kv.GetString("tele_homebase", TeleHome, sizeof(TeleHome));
	kv.GetString("tele_rivalbase", TeleRival, sizeof(TeleRival));
	kv.GetString("tele_dungeonenter", TeleEnter, sizeof(TeleEnter));
	kv.GetString("tele_dungeonnext", TeleNext, sizeof(TeleNext));
	
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
	
	if(kv.JumpToKey("Bases"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(room.SetupKv(kv))
					BaseList.PushArray(room);
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
				if(music.SetupKv(kv))
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
	if(Dungeon_Mode())
		mp_disable_respawn_times.BoolValue = true;

	CurrentAttacks = 0;
	CurrentRoomIndex = -1;
	NextRoomIndex = -1;
	CurrentBaseIndex = -1;
	DelayVoteFor = 0.0;
	delete GameTimer;
	AttackType = 0;
	EnemyScaling = 0.0;

	for(int i; i < sizeof(ZoneMarkerRef); i++)
	{
		ZoneMarkerRef[i] = -1;
	}
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
	PrintToChatAll("Dungeon_Start");

	delete GameTimer;

	float pos[3], ang[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
			Dungeon_SetZoneMarker(i_ObjectsSpawners[i], Zone_HomeBase);
			break;
		}
	}

	NextAttackAt = GetGameTime() + AttackTime;
	GameTimer = CreateTimer(0.5, DungeonMainTimer);
	Ammo_Count_Ready = 20;
	mp_disable_respawn_times.BoolValue = false;

	CreateAllDefaultBuidldings(pos, ang);

	int highestLevel;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			int amount = SkillTree_GetByName(client, "Ingot Up 1");
			if(amount > highestLevel)
				highestLevel = amount;
		}
	}

	int startingIngots = highestLevel + 8;
	//Rogue_AddIngots(startingIngots, true);
	Construction_AddMaterial("crystal", startingIngots, true);

	SetRandomMusic();
}

void CreateAllDefaultBuidldings(float pos[3], float ang[3])
{
	NPC_CreateByName("obj_dungeon_center", 0, pos, ang, TFTeam_Red);
	float PosSave[3];
	float RandAng[3];
	PosSave = pos;
	/*
		As of now, hardcoded to this map.
	*/
	int iNpc;
	for(int Loop; Loop < 4; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		iNpc = NPC_CreateByName("obj_dungeon_wall1", -1, PosSave, RandAng, TFTeam_Red);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
	for(int Loop; Loop < 4; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		PosSave[2] += 16.0;
		iNpc = NPC_CreateByName("obj_ammobox", -1, PosSave, RandAng, TFTeam_Red);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
	for(int Loop; Loop < 4; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		iNpc = NPC_CreateByName("obj_armortable", -1, PosSave, RandAng, TFTeam_Red);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
	for(int Loop; Loop < 1; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		iNpc = NPC_CreateByName("obj_const2_cannon", -1, PosSave, RandAng, TFTeam_Red);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
	for(int Loop; Loop < 1; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		iNpc = NPC_CreateByName("obj_perkmachine", -1, PosSave, RandAng, TFTeam_Red);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
}

static void SetRandomMusic()
{
	DMusicInfo music;
	ArrayList pool = new ArrayList();
	int length = MusicList.Length;
	for(int a; a < length; a++)
	{
		MusicList.GetArray(a, music);
		if(!music.Key[0])
			continue;

		if(music.MinAttack > CurrentAttacks || music.MaxAttack < CurrentAttacks)
			continue;

		if(!Rogue_HasNamedArtifact(music.Key))
		{
			Function func = GetFunctionByName(null, music.Key);
			if(func == INVALID_FUNCTION)
				continue;
			
			bool value;
			Call_StartFunction(null, func);
			Call_Finish(value);
			if(!value)
				continue;
		}

		for(int b; b < music.Common; b++)
		{
			pool.Push(a);
		}
	}

	if(pool.Length == 0)
	{
		for(int a; a < length; a++)
		{
			MusicList.GetArray(a, music);
			if(music.Key[0])
				continue;

			if(music.MinAttack > CurrentAttacks || music.MaxAttack < CurrentAttacks)
				continue;

			for(int b; b < music.Common; b++)
			{
				pool.Push(a);
			}
		}
	}

	length = pool.Length;
	if(length < 1)
	{
		delete pool;
		return;
	}

	length = pool.Get(GetURandomInt() % length);
	delete pool;

	MusicList.GetArray(length, music);

	int time = GetTime();
//	int nextAttack = RoundToCeil(NextAttackAt - GetGameTime()) - music.Duration;

//	if(nextAttack > 0)
//		time += GetRandomInt(0, nextAttack);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && IsClientInGame(client))
		{
			Music_Stop_All(client);
			SetMusicTimer(client, time);
		}
	}

	PrintToChatAll("SetRandomMusic '%s'", music.Music.Path);
	music.Music.CopyTo(BGMusicSpecial1);
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
					if(Dungeon_GetEntityZone(client) == Zone_Dungeon)
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

bool Dungeon_CanRespawn()
{
	if(!Dungeon_Mode())
		return false;
	
	if(Dungeon_InSetup())
		return true;
	
	return ObjectDungeonCenter_Alive();
}

int Dungeon_DownedBonus()
{
	if(!Dungeon_Mode())
		return 0;
	
	if(Dungeon_InSetup())
		return 0;
	
	return ObjectDungeonCenter_Alive() ? 999 : -2;
}

static void TriggerStartTouch(const char[] output, int caller, int activator, float delay)
{
	if(Dungeon_Mode() && AttackType < 2 && activator > 0 && activator <= MAXENTITIES && (activator <= MaxClients || !b_NpcHasDied[activator]))
	{
		char name[64];
		if(GetEntPropString(caller, Prop_Data, "m_iName", name, sizeof(name)))
		{
			DungeonZone zone = Zone_Unknown;

			if(StrEqual(name, TeleHome, false))
			{
				zone = Zone_HomeBase;
			}
			else if(StrEqual(name, TeleRival, false))
			{
				zone = Zone_RivalBase;
			}
			else if(StrEqual(name, TeleEnter, false))
			{
				zone = Zone_Dungeon;
			}
			else if(StrEqual(name, TeleNext, false))
			{
				zone = Zone_DungeonWait;
				
				if(NextRoomIndex == -1)
				{
					float time = NextAttackAt - GetGameTime();
					if(time > 100.0)
					{
						if(DelayVoteFor < GetGameTime() && !Rogue_VoteActive())
							CreateNewDungeon();
					}
					else
					{
						zone = Zone_HomeBase;
					}
				}
			}

			if(zone != Zone_Unknown)
			{
				if(zone == Zone_Dungeon && IsValidEntity(ZoneMarkerRef[Zone_DungeonWait]))
					zone = Zone_DungeonWait;

				if(IsValidEntity(ZoneMarkerRef[zone]))
				{
					float pos[3], ang[3];
					GetEntPropVector(ZoneMarkerRef[zone], Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(ZoneMarkerRef[zone], Prop_Data, "m_angRotation", ang);

					TeleportEntity(activator, pos, ang);
					Dungeon_SetEntityZone(activator, zone);
				}
				else if(activator <= MaxClients)
				{
					f_DelayLookingAtHud[activator] = GetGameTime() + 2.0;
					PrintCenterText(activator, "%T", "Dungeon Not Ready Yet", activator);
				}
			}
		}
	}
}
/*
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

	SurroundingAreasCollector areas = TheNavMesh.CollectSurroundingAreas(goalArea, _, 100.0, 18.0);

	int length = areas.Count();
	int start = GetURandomInt() % length;
	for(int i = start + 1; i != start; i++)
	{
		if(i >= length)
		{
			i = -1;
			continue;
		}

		CNavArea startArea = areas.Get(i);
		if(startArea == NULL_AREA)
			continue;
		
		if(startArea.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
			continue;
		
		//if(!TheNavMesh.BuildPath(startArea, goalArea, pos))
		//	continue;
		
		startArea.GetCenter(pos);
		break;
	}

	pos[2] += 1.0;
}*/
void Dungeon_TeleportCratesRewards(int entity, float pos[3])
{
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	hullcheckmaxs = view_as<float>( { 24.0, 24.0, 24.0 } );
	hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
	float PosRand[3];
	PosRand = pos;
	PosRand[0] += GetRandomFloat(-125.0, 125.0);
	PosRand[1] -= GetRandomFloat(-125.0, 125.0);
	Npc_Teleport_Safe(entity, PosRand, hullcheckmins, hullcheckmaxs, true);
}

void Dungeon_SpawnLoot(const float pos[3], const char[] name, float waveScale)
{
	float newPos[3];
	newPos = pos;
//	Dungeon_TeleportRandomly(newPos);

	DungeonLoot npc = view_as<DungeonLoot>(NPC_CreateById(DungeonLoot_Id(), 0, newPos, NULL_VECTOR, 3, "t"));
	npc.SetLootData(name, waveScale);
}

void Dungeon_SetZoneMarker(int entity, DungeonZone zone)
{
	ZoneMarkerRef[zone] = entity;
	if(ZoneMarkerRef[zone] > 0 && ZoneMarkerRef[zone] < sizeof(ZoneMarkerRef))
		ZoneMarkerRef[zone] = EntIndexToEntRef(ZoneMarkerRef[zone]);
}

int Dungeon_GetZoneMarker(DungeonZone zone)
{
	return ZoneMarkerRef[zone];
}

void Dungeon_SetEntityZone(int entity, DungeonZone zone)
{
	LastZone[entity] = zone;
}

DungeonZone Dungeon_GetEntityZone(int entity, bool forceReset = false)
{
	if(LastZone[entity] == Zone_Unknown || forceReset)
	{
		LastZone[entity] = Zone_Unknown;

		CNavArea endNav = TheNavMesh.GetNavAreaEntity(entity, GETNAVAREA_ALLOW_BLOCKED_AREAS, 1000.0);
		if(endNav != NULL_AREA)
		{
			float pos[3];
			CNavArea startNav;

			for(int i = 1; i < view_as<int>(Zone_MAX); i++)
			{
				if(IsValidEntity(ZoneMarkerRef[i]))
				{
					GetEntPropVector(ZoneMarkerRef[i], Prop_Data, "m_vecOrigin", pos);
					startNav = TheNavMesh.GetNavArea(pos);

					if(TheNavMesh.BuildPath(endNav, startNav, pos))
					{
						LastZone[entity] = view_as<DungeonZone>(i);
						break;
					}
				}
			}
		}
	}

	return LastZone[entity];
}

static Action DungeonMainTimer(Handle timer)
{
	float time = NextAttackAt - GetGameTime();
	if(time > 0.0)
	{
		if(AttackType == -1)
		{
			/*
				Check if rival base is setup now
			*/
			if(DelayVoteFor < GetGameTime() && !Rogue_VoteActive())
				Dungeon_BattleVictory();
		}
		else if(AttackType == 1)
		{
			CheckRivalStatus();

			/*
				Check if anyone out on the field is alive
			*/
			int alive, waiting;
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
					{
						switch(Dungeon_GetEntityZone(client))
						{
							case Zone_Dungeon:
								alive++;
							
							case Zone_DungeonWait:
								waiting++;
						}
					}
				}
			}

			if(!alive || ((alive * 3) < waiting))
				BattleLosted();
		}
		else if(AttackType < 1 && time > 20.0 && DelayVoteFor < GetGameTime() && !Rogue_VoteActive())
		{
			/*
				Create new rival base if one is currently dead
			*/
			bool alive = CheckRivalStatus();

			if(!alive && time > 100.0)
			{
				CreateNewRivals();
			}
			else
			{
				/*
					Start next dungeon if there's some waiting for it
				*/
				if(NextRoomIndex == -1)
				{
					if(time > 100.0 && !Rogue_VoteActive())
						CreateNewDungeon();
				}

				if(NextRoomIndex != -1)
				{
					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && Dungeon_GetEntityZone(client) == Zone_DungeonWait)
							{
								StartNewDungeon();
								break;
							}
						}
					}
				}
			}
		}

		GameTimer = CreateTimer(0.5, DungeonMainTimer);
		Waves_UpdateMvMStats();
		return Plugin_Stop;
	}

	/*
		Raid Attack
	*/

	CheckRivalStatus();

	CurrentAttacks++;
	CurrentRoomIndex = -1;
	NextRoomIndex = -1;
	CurrentBaseIndex = -1;
	EnemyScaling = 0.0;

	int index = -1;
	bool final = CurrentAttacks >= RaidList.Length;
	AttackType = final ? 3 : 2;

	Rogue_SetBattleIngots(CurrentAttacks > 1 ? 6 : 5);
	
	TeleportToFrom(Zone_HomeBase);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
			{
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

static void CreateNewDungeon()
{
	PrintToChatAll("CreateNewDungeon");
	f_DelayNextWaveStartAdvancingDeathNpc = GetGameTime() + 9.0;
	
	RoomInfo room;
	ArrayList roomPool = new ArrayList();
	int highestCommon;
	int round = RoundToFloor(BattleWaveScale);
	int length = RoomList.Length;
	for(int a; a < length; a++)
	{
		RoomList.GetArray(a, room);
		if(room.Common > highestCommon)
			highestCommon = room.Common;

		if(a == CurrentRoomIndex)
			continue;
		
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

	length = roomPool.Length;
	if(length < 1)
	{
		PrintToChatAll("ERROR: No Dungeons");
		delete roomPool;
		return;
	}
		
	NextRoomIndex = roomPool.Get(GetURandomInt() % length);
	delete roomPool;

	RoomList.GetArray(NextRoomIndex, room);

	bool found;

	char buffer[64];
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "info_teleport_destination")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, room.Spawn, false))
		{
			if(!found || (GetURandomInt() % 2))
			{
				Dungeon_SetZoneMarker(entity, Zone_DungeonWait);
				found = true;
			}
		}
	}

	if(!found)
	{
		for(int i; i < ZR_MAX_SPAWNERS; i++)
		{
			if(IsValidEntity(i_ObjectsSpawners[i]))
			{
				GetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrEqual(buffer, room.Spawn, false))
				{
					if(!found || (GetURandomInt() % 2))
					{
						Dungeon_SetZoneMarker(entity, Zone_DungeonWait);
						found = true;
					}
				}
			}
		}
	}

	if(!found)
		PrintToChatAll("ERROR: Unknown spawn point '%s'", room.Spawn);
	
	TeleportToFrom(Zone_DungeonWait, Zone_DungeonWait);
}

static void StartNewDungeon()
{
	PrintToChatAll("StartNewDungeon");
	
	ZoneMarkerRef[Zone_Dungeon] = ZoneMarkerRef[Zone_DungeonWait];
	ZoneMarkerRef[Zone_DungeonWait] = -1;

	CurrentRoomIndex = NextRoomIndex;
	NextRoomIndex = -1;
	
	RoomInfo room;
	RoomList.GetArray(CurrentRoomIndex, room);
	room.CurrentCooldown = room.Cooldown + GetGameTime();
	RoomList.SetArray(CurrentRoomIndex, room);
	
	Rogue_SetBattleIngots(0);

	float time = room.Fights ? 0.0 : 5.0;
	if(room.FuncStart != INVALID_FUNCTION)
	{
		Call_StartFunction(null, room.FuncStart);
		Call_Finish(time);
	}

	if(!time && room.Fights)
		StartBattle(room);
	
	if(time < 30.0)
		Dungeon_DelayVoteFor(time);

	TeleportToFrom(Zone_Dungeon, Zone_DungeonWait, Zone_Dungeon);
}

static void CreateNewRivals()
{
	PrintToChatAll("CreateNewRivals");

	RoomInfo room;
	ArrayList roomPool = new ArrayList();
	int round = RoundToFloor(BattleWaveScale);
	int length = BaseList.Length;
	for(int a; a < length; a++)
	{
		BaseList.GetArray(a, room);

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

	length = roomPool.Length;
	if(length < 1)
	{
		PrintToChatAll("ERROR: No Rival Bases");
		delete roomPool;
		return;
	}
		
	CurrentBaseIndex = roomPool.Get(GetURandomInt() % length);
	delete roomPool;

	BaseList.GetArray(CurrentBaseIndex, room);
	room.CurrentCooldown = room.Cooldown + GetGameTime();
	BaseList.SetArray(CurrentBaseIndex, room);

	bool found;

	char buffer[64];
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "info_teleport_destination")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, room.Spawn, false))
		{
			if(!found || (GetURandomInt() % 2))
			{
				Dungeon_SetZoneMarker(entity, Zone_RivalBase);
				found = true;
			}
		}
	}

	if(!found)
	{
		for(int i; i < ZR_MAX_SPAWNERS; i++)
		{
			if(IsValidEntity(i_ObjectsSpawners[i]))
			{
				GetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrEqual(buffer, room.Spawn, false))
				{
					if(!found || (GetURandomInt() % 2))
					{
						Dungeon_SetZoneMarker(entity, Zone_RivalBase);
						found = true;
					}
				}
			}
		}
	}

	if(!found)
		PrintToChatAll("ERROR: Unknown spawn point '%s'", room.Spawn);

	float time = 0.0;
	if(room.FuncStart != INVALID_FUNCTION)
	{
		Call_StartFunction(null, room.FuncStart);
		Call_Finish(time);
	}

	StartBattle(room, time);
	AttackType = -1;
	EnemyScaling = 0.0;

	Dungeon_DelayVoteFor(time + 5.0);
	
	TeleportToFrom(Zone_RivalBase, Zone_RivalBase);
}

// Returns true if an base is ongoing
static bool CheckRivalStatus()
{
	if(CurrentBaseIndex == -1)
		return false;
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity == INVALID_ENT_REFERENCE || !IsEntityAlive(entity))
			continue;
		
		if(GetTeam(entity) == TFTeam_Red)
			continue;
		
		DungeonZone zone = Dungeon_GetEntityZone(entity);
		if(zone != Zone_RivalBase)
			continue;
		
		if(ObjectDWall_IsId(i_NpcInternalId[entity]))
			continue;

		return true;
	}

	RoomInfo room;
	BaseList.GetArray(CurrentBaseIndex, room);
	room.RollLoot(NULL_VECTOR);

	CurrentBaseIndex = -1;
	return false;
}

bool Const2_IgnoreBuilding_FindTraget(int entity)
{
	if(ObjectDWall_IsId(i_NpcInternalId[entity]))
		return true;
	return false;
}

static void TeleportToFrom(DungeonZone tele, DungeonZone from1 = Zone_Unknown, DungeonZone from2 = Zone_MAX, DungeonZone from3 = Zone_MAX)
{
	float pos[3], ang[3];
	if(IsValidEntity(ZoneMarkerRef[tele]))
	{
		GetEntPropVector(ZoneMarkerRef[tele], Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(ZoneMarkerRef[tele], Prop_Data, "m_angRotation", ang);
	}
	else
	{
		PrintToChatAll("ERROR: No zone marker for %d", tele);
		return;
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			DungeonZone zone = Dungeon_GetEntityZone(client);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos, ang, NULL_VECTOR);
				SaveLastValidPositionEntity(client, pos);
				Dungeon_SetEntityZone(client, tele);
			}
		}
	}
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			DungeonZone zone = Dungeon_GetEntityZone(entity);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				if(GetTeam(entity) == TFTeam_Red && i_NpcInternalId[entity] != Remain_ID())
				{
					TeleportEntity(entity, pos, ang, NULL_VECTOR);
					SaveLastValidPositionEntity(entity, pos);
					Dungeon_SetEntityZone(entity, tele);
				}
				else
				{
					f_CreditsOnKill[entity] = 0.0;
					SmiteNpcToDeath(entity);
				}
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
		{
			DungeonZone zone = Dungeon_GetEntityZone(entity);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				DeleteAndRefundBuilding(builder_owner, entity);
			}
		}
	}

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		DungeonZone zone = Dungeon_GetEntityZone(entity);
		if(
			(zone == tele && (zone == Zone_HomeBase || tele == Zone_RivalBase)) ||
			((zone == Zone_Dungeon || zone == Zone_DungeonWait) && (tele == Zone_Dungeon || tele == Zone_DungeonWait))
		)
		{
			// Home -> Home
			// Rival -> Rival
			// Dungeon/Wait -> Dungeon/Wait
			TeleportEntity(entity, pos, ang, NULL_VECTOR);
			break;
		}
		else if(zone == Zone_Unknown)
		{
			Vehicle_Exit(entity, false, true);
			RemoveEntity(entity);
		}
	}
}

stock void Dungeon_StartThisBattle(float time = 10.0)
{
	RoomInfo room;
	RoomList.GetArray(CurrentRoomIndex, room);
	
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
	if(!index)
	{
		for(int a; a < length; a++)
		{
			list.Push(a);
		}

		index = list.Length;
	}
	
	index = index ? list.Get(GetURandomInt() % index) : -1;
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
		PrintToChatAll("NO ROOM???? REPORT THIS BUG");
	}

	delete list;
	delete snap;

	//float limit = room.Timelimit;
	//if(limit < 1.0)
	//	limit = 420.0;

	float maxLimit = NextAttackAt - GetGameTime();
	//if(limit > maxLimit)
	//	limit = maxLimit;

	SetBattleTimelimit(maxLimit);
}

void Dungeon_BattleVictory()
{
	Waves_RoundEnd();

	if(AttackType < 1)
	{
		AttackType = 0;
		return;
	}
	
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();

	int ingots = Rogue_GetBattleIngots();
	if(ingots)
		Construction_AddMaterial("crystal", ingots);

	if(CurrentRoomIndex != -1 && AttackType == 1)
	{
		RoomInfo room;
		RoomList.GetArray(CurrentRoomIndex, room);
		room.RollLoot(NULL_VECTOR);
	}

	if(AttackType == 2)
	{
		// Reset next attack, give full time after a raid
		NextAttackAt = GetGameTime() + AttackTime;

		SetRandomMusic();
	}
	
	Zero(i_AmountDowned);
	AttackType = 0;
	Dungeon_DelayVoteFor(20.0);

	Const2_ReviveAllBuildings();

	ZoneMarkerRef[Zone_Dungeon] = -1;
}

//england is my city
static void BattleLosted()
{
	Waves_RoundEnd();
	bool victory = false;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();
	
	Zero(i_AmountDowned);
	AttackType = 0;
	
	//TeleportToFrom(Zone_DungeonWait, Zone_Dungeon);

	CPrintToChatAll("{crimson}%t", "Dungeon Failed");
	Dungeon_DelayVoteFor(20.0);

	ZoneMarkerRef[Zone_Dungeon] = -1;
}

void Dungeon_WaveEnd(const float spawner[3] = NULL_VECTOR, bool rivalBase = false)
{
	if(!Dungeon_Mode())
		return;
	
	if(!RoomList)
	{
		PrintToChatAll("Dungeon_WaveEnd failed???");
		return;
	}

	if(rivalBase)
	{
		if(CurrentBaseIndex != -1)
		{
			RoomInfo room;
			RoomList.GetArray(CurrentBaseIndex, room);
			room.RollLoot(spawner);
		}
	}
	else if(CurrentRoomIndex != -1 && AttackType == 1)
	{
		RoomInfo room;
		RoomList.GetArray(CurrentRoomIndex, room);
		room.RollLoot(spawner);
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
	{
		loot.RollLoot();
	}
	else
	{
		PrintToChatAll("UNKNOWN LOOT \"%s\", REPORT BUG", name);
	}
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
	if(Dungeon_Mode() &&
	 i_NpcInternalId[entity] != DungeonLoot_Id() &&
	  i_NpcInternalId[entity] != Const2Spawner_Id())
	{
		switch(AttackType)
		{
			case -1:	// Town NPC
			{
				b_StaticNPC[entity] = true;
				AddNpcToAliveList(entity, 1);
			}
			case 1:	// Dungeon NPC
			{
				// Reward cash depending on the wave scaling and how much left
				static int LimitNotice;

				int round = Dungeon_GetRound(true);
				int limit = 4 + RoundFloat(ObjectC2House_CountBuildings() * 3.5);
				if(round > limit)
				{
					round = limit;

					if(!LimitNotice)
					{
						CPrintToChatAll("%t", "Upgrade Build Houses");
						LimitNotice = 1;
					}
					else
					{
						LimitNotice++;
						if(LimitNotice > 49)
							LimitNotice = 0;
					}
				}
				else
				{
					LimitNotice = 0;
				}
				
				int current = CurrentCash - GlobalExtraCash - StartCash;

				int a, other;
				while((other = FindEntityByNPC(a)) != -1)
				{
					if(!b_NpcHasDied[other] && GetTeam(other) != TFTeam_Red)
						current += RoundFloat(f_CreditsOnKill[other]);
				}

				int goal = DefaultTotalCash(round);
				if(current < goal)
				{
					int reward = (goal - current) / RoundToNearest((float((b_thisNpcIsABoss[entity] ? 5 : 50)) * MultiGlobalEnemy));
					if(reward < 5)
						reward = 5;
					
					f_CreditsOnKill[entity] += float(reward / 5 * 5);
				}
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
	if(!Dungeon_Mode() || AttackType > 1)
		return false;
	
	int objective = FindEntityByClassname(-1, "tf_objective_resource");
	if(objective != -1)
	{
		int itemCount, worldMoney;
		float gameTime = GetGameTime();

		if(AttackType == 1)
		{
			int round = Dungeon_GetRound();
			int limit = 4 + RoundFloat(ObjectC2House_CountBuildings() * 3.5);
			if(round > limit)
				round = limit;
			
			int current = CurrentCash - GlobalExtraCash;
			int goal = DefaultTotalCash(round);

			if(current < goal)
				worldMoney = goal - current;
		}

		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", worldMoney);

		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", CurrentAttacks + 1);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", RaidList.Length);

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

		// Use the bar as a timer
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", itemCount + RoundToCeil(AttackTime));
	}

	return true;
}

#include "roguelike/dungeon_items.sp"
#include "roguelike/dungeon_encounters.sp"