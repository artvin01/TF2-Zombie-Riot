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
static float RespawnTime;
static int MaxWaveScale;
static char TeleHome[64];
static char TeleRival[64];
static char TeleEnter[64];
static char TeleNext[64];
static int LimitNotice;
static bool NoticenoDungeon;


#define MONEY_SCLAING_PUSHFUTURE 3
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
		if(name[0])
		{
			
		}
		
			//erroring go

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
	int MinAttack;
	int MaxAttack;
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
		this.MinAttack = kv.GetNum("minattack", -9999);
		this.MaxAttack = kv.GetNum("maxattack", 9999);
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
				//CPrintToChatAll("%t", "Found Dungeon Loot", buffer);

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

		//if(victory && count)
		//	EmitSoundToAll("ui/itemcrate_smash_rare.wav");
	}

	void Clean()
	{
		delete this.Fights;
		delete this.Loots;
	}
}

static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// -1 = Rival Setup, 0 = None, 1 = Room, 2 = Base, 3 = Final
static Handle GameTimer;
//static float BattleTimelimit;
static float DelayVoteFor;
static int CurrentRoomIndex = -1;
static int NextRoomIndex = -1;
static int CurrentBaseIndex = -1;
static float BattleWaveScale;
static float EnemyScaling;
static bool NerfNextRaid;
static float LastKilledAt[MAXPLAYERS];
static DungeonZone LastZone[MAXENTITIES];

int Dungeon_AttackType()
{
	return AttackType;
}
void Dungeon_PluginStart()
{
	LoadTranslations("zombieriot.phrases.dungeon");
	HookEntityOutput("trigger_multiple", "OnStartTouch", TriggerStartTouch);
	RegAdminCmd("sm_dungeon_enemies_left", Dungeon_Debuff_EnemiesLeft, ADMFLAG_GENERIC, "Debug to see what remains to win");
}

void Dungeon_EntityCreated(int entity)
{
	LastZone[entity] = Zone_Unknown;
}

public bool Dungeon_Mode()
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
	return Dungeon_Mode() && CurrentAttacks >= RaidList.Length;
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

int Dungeon_CurrentAttacks()
{
	return CurrentAttacks;
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
	PrecacheMvMIconCustom("robo_extremethreat");
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
	ToggleEntityByName(TeleRival, true);
	ToggleEntityByName(TeleEnter, true);
	UpdateBlockedNavmesh();
	
	if(kv.JumpToKey("CustomIcons"))
	{
		if(kv.GotoFirstSubKey(false))
		{
			do
			{
				kv.GetSectionName(buffer1, sizeof(buffer1));
				PrecacheMvMIconCustom(buffer1, view_as<bool>(kv.GetNum(NULL_STRING)));
			}
			while(kv.GotoNextKey(false));

			kv.GoBack();
		}

		kv.GoBack();
	}
	
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
		RespawnTime = kv.GetFloat("respawn", 20.0);
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

						BuildPath(Path_SM, buffer2, sizeof(buffer2), CONFIG_CFG, buffer1);
						if(!FileExists(buffer2))
						{
							LogError("Unknown waveset '%s' for raid", buffer1);
						}
						else
						{
							KeyValues wavekv = new KeyValues("Waves");

							wavekv.ImportFromFile(buffer2);
							Waves_CacheWaves(wavekv, true);

							delete wavekv;
						}
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
	//GameTimer = CreateTimer(1.0, Timer_WaitingPeriod, _, TIMER_REPEAT);
	
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
	NerfNextRaid = false;
	Zero(LastKilledAt);

	for(int i; i < sizeof(ZoneMarkerRef); i++)
	{
		ZoneMarkerRef[i] = -1;
	}
}
/*
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
*/
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
			ExplainToClientDungeon(client);
			int amount = SkillTree_GetByName(client, "Ingot Up 1");
			if(amount > highestLevel)
				highestLevel = amount;
		}
	}

	int startingIngots = highestLevel + 8;
	//Rogue_AddIngots(startingIngots, true);
	Construction_AddMaterial("crystal", startingIngots, true);

	Dungeon_SetRandomMusic();

	CreateNewRivals();
}

void CreateAllDefaultBuidldings(float pos[3], float ang[3])
{
	int iNpc;
	iNpc = Building_BuildByName("obj_dungeon_center", 0, pos, ang);
	SetTeam(iNpc, TFTeam_Red);
	float PosSave[3];
	float RandAng[3];
	PosSave = pos;
	/*
		As of now, hardcoded to this map.
	*/
	for(int Loop; Loop < 4; Loop++)
	{
		PosSave = pos;
		PosSave[0] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
		PosSave[1] += GetRandomInt(0,1) ? GetRandomFloat(-250.0,-50.0) : GetRandomFloat(50.0, 250.0);
	//	RandAng[0] = GetRandomFloat(-180.0,180.0);
		RandAng[1] = GetRandomFloat(-180.0,180.0);
		iNpc = Building_BuildByName("obj_dungeon_wall1", -1, PosSave, RandAng);
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
		iNpc = Building_BuildByName("obj_ammobox", -1, PosSave, RandAng);
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
		iNpc = Building_BuildByName("obj_armortable", -1, PosSave, RandAng);
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
		iNpc = Building_BuildByName("obj_const2_cannon", -1, PosSave, RandAng);
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
		iNpc = Building_BuildByName("obj_perkmachine", -1, PosSave, RandAng);
		SetTeam(iNpc, TFTeam_Red);
		ObjectGeneric objstats = view_as<ObjectGeneric>(iNpc);
		objstats.m_bNoOwnerRequired = true;
	}
}

void Dungeon_SetRandomMusic()
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

void Dungeon_PlayerDowned(int client)
{
	if(dieingstate[client] <= 0)
		LastKilledAt[client] = GetGameTime();
}

bool Dungeon_InRespawnTimer(int client)
{
	if(!Dungeon_Started())
		return false;
	
	float time = (RespawnTime + LastKilledAt[client]) - GetGameTime();
	if(time > 0.0)
	{
		f_DelayLookingAtHud[client] = GetGameTime() + time;
		PrintCenterText(client, "Respawning in %ds...", RoundToCeil(time));
		return true;
	}

	return false;
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
				if(IsValidClient(activator))
					ExplainToClientDungeon(activator);
				zone = Zone_RivalBase;
			}
			else if(StrEqual(name, TeleEnter, false))
			{
				if(IsValidClient(activator))
					ExplainToClientDungeon(activator);
				zone = Zone_Dungeon;
			}
			else if(StrEqual(name, TeleNext, false))
			{
				zone = Zone_DungeonWait;
				
				if(NextRoomIndex == -1)
				{
					float time = NextAttackAt - GetGameTime();
					if(time > 60.0)
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
				
				if(zone != Zone_HomeBase && activator <= MaxClients)
				{
					// Don't carry constructs outside home base
					ObjectGeneric obj = view_as<ObjectGeneric>(GetCarryingObject(activator));
					if(IsValidEntity(obj.index) && obj.m_bConstructBuilding)
						return;
				}

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

void Dungeon_TeleportRandomly(float pos[3])
{
	CNavArea goalArea = TheNavMesh.GetNavArea(pos, 1000.0);
	if(goalArea == NULL_AREA)
	{
		PrintToChatAll("ERROR: Could not find valid nav area for location (%f %f %f)", pos[0], pos[1], pos[2]);
		return;
	}

	SurroundingAreasCollector areas = TheNavMesh.CollectSurroundingAreas(goalArea, 3000.0, 100.0, 18.0);

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
}

void Dungeon_TeleportCratesRewards(int entity, float pos[3], float range = 125.0)
{
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	hullcheckmaxs = view_as<float>( { 24.0, 24.0, 24.0 } );
	hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
	float PosRand[3];
	PosRand = pos;
	PosRand[0] += GetRandomFloat(-range, range);
	PosRand[1] -= GetRandomFloat(-range, range);
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

		float AbsPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsPos);
		CNavArea endNav = TheNavMesh.GetNavAreaEntity(entity, GETNAVAREA_ALLOW_BLOCKED_AREAS, 500.0);
		if(endNav == NULL_AREA)
			endNav = TheNavMesh.GetNearestNavArea(AbsPos, false, 60.0, _, _, _);
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
	NoticeDungeonNoTimeLeft();
	if(time > 0.0 || AttackType > 1)
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
					if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && !dieingstate[client])
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
				//CreateNewRivals();
			}
			else
			{
				/*
					Start next dungeon if there's some waiting for it
				*/
				if(NextRoomIndex == -1)
				{
					if(time > 60.0 && !Rogue_VoteActive())
						CreateNewDungeon();
				}

				if(NextRoomIndex != -1)
				{
					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							if(IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
							{
								switch(Dungeon_GetEntityZone(client))
								{
									case Zone_Dungeon, Zone_DungeonWait:
									{
										StartNewDungeon();
										break;
									}
								}
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
	ToggleEntityByName(TeleRival, false);
	ToggleEntityByName(TeleEnter, false);
	UpdateBlockedNavmesh();

	CheckRivalStatus();

	CurrentAttacks++;
	CurrentRoomIndex = -1;
	NextRoomIndex = -1;
	CurrentBaseIndex = -1;
	EnemyScaling = 0.0;

	int index = -1;
	bool final = CurrentAttacks >= RaidList.Length;
	AttackType = final ? 3 : 2;

	Rogue_SetBattleIngots(CurrentAttacks > 1 ? 18 : 15);
	
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
		//SetBattleTimelimit(AttackTime - 3.0);
	}
	else
	{
		PrintToChatAll("NO BATTLE %d???? REPORT THIS BUG", CurrentAttacks);
	}

	EmitGameSoundToAll("Ambient.Siren");
	WaveStart_SubWaveStart(GetGameTime());
	
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
/*
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
*/
void Dungeon_DelayVoteFor(float time)
{
	DelayVoteFor = GetGameTime() + time;
}

static void CreateNewDungeon()
{
	f_DelayNextWaveStartAdvancingDeathNpc = GetGameTime() + 9.0;
	
	RoomInfo room;
	ArrayList roomPool = new ArrayList();
	int highestCommon;
	int round = RoundToFloor(BattleWaveScale);
	int length = RoomList.Length;
	for(int a; a < length; a++)
	{
		RoomList.GetArray(a, room);
		if(room.Common < 19 && room.Common > highestCommon)
			highestCommon = room.Common;

		if(a == CurrentRoomIndex)
			continue;
		
		if(room.CurrentCooldown > GetGameTime())
			continue;
		
		if(room.MinAttack > CurrentAttacks || room.MaxAttack < CurrentAttacks)
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
			if(room.Common < 19 && room.Common >= highestCommon)
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
	CPrintToChatAll("{yellow}%t", "Dungeon New");
}

static void StartNewDungeon()
{
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
	RoomInfo room;
	ArrayList roomPool = new ArrayList();
	int round = RoundToFloor(BattleWaveScale);
	int length = BaseList.Length;
	for(int a; a < length; a++)
	{
		BaseList.GetArray(a, room);

		if(room.CurrentCooldown > GetGameTime())
			continue;
		
		if(room.MinAttack > CurrentAttacks || room.MaxAttack < CurrentAttacks)
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

	Dungeon_DelayVoteFor(time + 15.0);
	
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

public bool Const2_IgnoreBuilding_FindTraget(int entity)
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
	
	int a;
	int entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(IsEntityAlive(entity))
		{
			DungeonZone zone = Dungeon_GetEntityZone(entity);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				if(GetTeam(entity) != TFTeam_Red || i_NpcInternalId[entity] == Remain_ID())
				{
					f_CreditsOnKill[entity] = 0.0;
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
				}
				else
				{
					TeleportEntity(entity, pos, ang, NULL_VECTOR);
					SaveLastValidPositionEntity(entity, pos);
					Dungeon_SetEntityZone(entity, tele);
				}
			}
		}
	}
	entity = 0;
	a = 0;
	//fixes npcs second phase
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(IsEntityAlive(entity))
		{
			DungeonZone zone = Dungeon_GetEntityZone(entity);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				if(GetTeam(entity) != TFTeam_Red || i_NpcInternalId[entity] == Remain_ID())
				{
					f_CreditsOnKill[entity] = 0.0;
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
					SmiteNpcToDeath(entity);
				}
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
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

	entity = -1;
	while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		DungeonZone zone = Dungeon_GetEntityZone(entity);

		if(b_ThisNpcIsImmuneToNuke[entity])	// Temp car
			zone = Zone_Unknown;
		
		if(
			(zone == tele && (zone == Zone_HomeBase || tele == Zone_RivalBase)) ||
			((zone == Zone_Dungeon || zone == Zone_DungeonWait) && (tele == Zone_Dungeon || tele == Zone_DungeonWait))
		)
		{
			if(zone == tele && zone == Zone_HomeBase)
				continue;
			
			// Home -> Home
			// Rival -> Rival
			// Dungeon/Wait -> Dungeon/Wait
			TeleportEntity(entity, pos, ang, NULL_VECTOR);
			break;
		}
		else if(zone == Zone_Unknown)
		{
			RemoveEntity(entity);
		}
	}
/*
	DataPack pack;
	CreateDataTimer(0.2, KillToFrom, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(tele);
	pack.WriteCell(from1);
	pack.WriteCell(from2);
	pack.WriteCell(from3);*/
}
/*
static Action KillToFrom(Handle timer, DataPack pack)
{
	bool found;

	pack.Reset();

	DungeonZone tele = pack.ReadCell();
	DungeonZone from1 = pack.ReadCell();
	DungeonZone from2 = pack.ReadCell();
	DungeonZone from3 = pack.ReadCell();
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			DungeonZone zone = Dungeon_GetEntityZone(entity);
			if(zone == Zone_Unknown || (zone != tele && from1 == Zone_Unknown) || zone == from1 || zone == from2 || zone == from3)
			{
				if(GetTeam(entity) != TFTeam_Red || i_NpcInternalId[entity] == Remain_ID())
				{
					f_CreditsOnKill[entity] = 0.0;
					SmiteNpcToDeath(entity);
					found = true;
				}
			}
		}
	}

	return found ? Plugin_Continue : Plugin_Stop;
}*/

stock void Dungeon_StartThisBattle(float time = 10.0)
{
	RoomInfo room;
	RoomList.GetArray(CurrentRoomIndex, room);
	
	StartBattle(room, time);
}

static void StartBattle(const RoomInfo room, float time = 0.1)
{
	if(!room.Fights)
		return;

	AttackType = 1;
	int scale;
	int round = Dungeon_GetRound();
	int lowestDiff = 999;
	int data[2];

	char buffer[PLATFORM_MAX_PATH];
	ArrayList listPre = new ArrayList(sizeof(data));

	// Gather data
	StringMapSnapshot snap = room.Fights.Snapshot();
	int length = snap.Length;
	for(int a; a < length; a++)
	{
		snap.GetKey(a, buffer, sizeof(buffer));
		room.Fights.GetValue(buffer, scale);

		data[0] = a;
		data[1] = abs(round - scale);

		if(lowestDiff > data[1])
			lowestDiff = data[1];
		
		listPre.PushArray(data);
	}

	ArrayList listPost = new ArrayList();
	
	// Check data
	for(int a; a < length; a++)
	{
		listPre.GetArray(a, data);

		// Less difference, more common
		int common = 10 - (data[1] - lowestDiff);
		for(int b; b < common; b++)
		{
			listPost.Push(data[0]);
		}
	}

	delete listPre;
	
	length = listPost.Length;
	if(length)
	{
		length = listPost.Get(GetURandomInt() % length);
		snap.GetKey(length, buffer, sizeof(buffer));

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

	delete snap;
	delete listPost;

	/*float limit = room.Timelimit;
	if(limit < 1.0)
		limit = 420.0;

	float maxLimit = NextAttackAt - GetGameTime();
	if(limit > maxLimit)
		limit = maxLimit;

	SetBattleTimelimit(limit);*/
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
	
	int attack = AttackType;
	AttackType = 0;

	if(attack == 1)
	{
		if(CurrentRoomIndex != -1)
		{
			RoomInfo room;
			RoomList.GetArray(CurrentRoomIndex, room);
			room.RollLoot(NULL_VECTOR);
		}

		CPrintToChatAll("{green}%t", "Dungeon Success");
	}
	
	Zero(i_AmountDowned);
	Dungeon_DelayVoteFor(1.0);

	if(attack == 2)
	{
		// Reset next attack, give full time after a raid
		NextAttackAt = GetGameTime() + AttackTime;
		NerfNextRaid = false;

		Dungeon_SetRandomMusic();
		CreateNewRivals();	
		ToggleEntityByName(TeleRival, true);
		ToggleEntityByName(TeleEnter, true);
		UpdateBlockedNavmesh();
	}

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
	
	TeleportToFrom(Zone_Dungeon, Zone_HomeBase);
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
			BaseList.GetArray(CurrentBaseIndex, room);
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

void Dungeon_BuildingDeath(int entity)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(CurrentBaseIndex != -1)
		{
			float pos[3];
			GetAbsOrigin(entity, pos);
			
			RoomInfo room;
			BaseList.GetArray(CurrentBaseIndex, room);
			room.RollLoot(pos);
		}
	}
}

void Dungeon_MainBuildingDeath(int entity)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(CurrentBaseIndex != -1)
		{
			float pos[3];
			GetAbsOrigin(entity, pos);

			RoomInfo room;
			BaseList.GetArray(CurrentBaseIndex, room);
			room.RollLoot(pos);
			room.RollLoot(pos);

			NerfNextRaid = true;

			CPrintToChatAll("%t", "Enemy Center Death");
		}
	}
}

void Dungeon_AddBattleScale(float scale)
{
	BattleWaveScale += scale;
}

bool Dungeon_AtLimitNotice()
{
	return LimitNotice != 0;
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
				if(Dungeon_GetEntityZone(entity) != Zone_RivalBase)
				{
					//nerf enemies in dungeons by 10%
					fl_Extra_Damage[entity] *= 0.9;
					SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 0.9));
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 0.9));


					// Reward cash depending on the wave scaling and how much left
					if(!i_IsABuilding[entity] && !i_NpcIsABuilding[entity])
					{
						int round = Dungeon_GetRound(true) + MONEY_SCLAING_PUSHFUTURE;
						int limit = MONEY_SCLAING_PUSHFUTURE + RoundFloat(ObjectC2House_CountBuildings() * 3.5);
						if(round > limit)
						{
							round = limit;

							if(!ObjectC2House_CanUpgrade() && ObjectDungeonCenter_Level() >= CurrentAttacks)
							{
								LimitNotice = 0;
							}
							else if(LimitNotice < 1)
							{
								CPrintToChatAll("{crimson}%t", "Upgrade Build Houses");
								LimitNotice = 1;
							}
							else
							{
								LimitNotice++;
								if(LimitNotice > 49)
									LimitNotice = -1;
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
							int reward = (goal - current) / RoundToNearest((float((b_thisNpcIsABoss[entity] ? 4 : 40)) * MultiGlobalEnemy));
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
			case 2, 3:	// Raid/Final NPC
			{
				if(NerfNextRaid)
				{
					if(b_thisNpcIsABoss[entity])
					{
						fl_Extra_Damage[entity] *= 0.9;
						fl_Extra_MeleeArmor[entity] *= 1.1;
						fl_Extra_RangedArmor[entity] *= 1.1;
					}
					else
					{
						fl_Extra_Damage[entity] *= 0.8;
						fl_Extra_MeleeArmor[entity] *= 1.25;
						fl_Extra_RangedArmor[entity] *= 1.25;
					}
				}
			}
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
			int round = Dungeon_GetRound(true) + MONEY_SCLAING_PUSHFUTURE;
			int limit = MONEY_SCLAING_PUSHFUTURE + RoundFloat(ObjectC2House_CountBuildings() * 3.5);
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
						if(time < 61)
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

stock void ToggleEntityByName(const char[] name, bool toggleMode)
{
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if(IsValidEntity(i))
		{
			static char buffer[32];
			GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				if(!toggleMode)
					AcceptEntityInput(i, "Disable");
				else
					AcceptEntityInput(i, "Enable");
			}
		}
	}
}

stock int FindByEntityName(const char[] name)
{
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if(IsValidEntity(i))
		{
			static char buffer[32];
			GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				return i;
			}
		}
	}
	return -1;
}

public void ZRModifs_ModifEnemyChaos(int iNpc)
{
	if(i_NpcInternalId[iNpc] == DungeonLoot_Id() ||i_NpcInternalId[iNpc] == Const2Spawner_Id())
		return;
		
	fl_Extra_Damage[iNpc] *= 1.10;
	int Health = GetEntProp(iNpc, Prop_Data, "m_iMaxHealth");
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(Health) * 1.10));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(Health) * 1.10));

	if(b_thisNpcIsABoss[iNpc])
		return;
	if(i_IsABuilding[iNpc])
		return;
	if(i_NpcIsABuilding[iNpc])
		return;
//	if(Dungeon_GetEntityZone(iNpc) != Zone_Dungeon && Dungeon_GetEntityZone(iNpc) != Zone_RivalBase)
//		return;
	//Rare
	if(GetRandomInt(0,RoundToCeil(75.0 * MultiGlobalEnemy)) != 0)
		return;
	b_thisNpcHasAnOutline[iNpc] = true;
	GiveNpcOutLineLastOrBoss(iNpc, true);
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(iNpc)) * 3.0));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(iNpc)) * 3.0));
	fl_Extra_Damage[iNpc] *= 1.2;
	bool RetryBuffGiving = false;
	bool GiveOneGuranteed = true;
	int MaxHits = 0;
	while(GiveOneGuranteed || RetryBuffGiving || GetRandomInt(1,4) == 1)
	{
		MaxHits++;
		if(MaxHits >= 1000)
		{
			break;
		}
		GiveOneGuranteed = false;
		RetryBuffGiving = false;
		switch(GetRandomInt(1,18))
		{
			case 1:
			{
				if(HasSpecificBuff(iNpc, "The Haste"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Haste", 999999.9);
			}
			case 2:
			{
				if(HasSpecificBuff(iNpc, "The Big"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Big", 999999.9);
			}
			case 3:
			{
				if(HasSpecificBuff(iNpc, "The Strong"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Strong", 999999.9);
			}
			case 4:
			{
				if(HasSpecificBuff(iNpc, "The Tiny"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Tiny", 999999.9);
			}
			case 5:
			{
				if(HasSpecificBuff(iNpc, "The Bleeder"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Bleeder", 999999.9);
			}
			case 6:
			{
				if(HasSpecificBuff(iNpc, "The Vampire"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Vampire", 999999.9);
			}
			case 7:
			{
				if(HasSpecificBuff(iNpc, "The Anti Sea"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Anti Sea", 999999.9);
			}
			case 8:
			{
				if(HasSpecificBuff(iNpc, "The Sprayer"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Sprayer", 999999.9);
			}
			case 9:
			{
				if(HasSpecificBuff(iNpc, "The Gravitational"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The Gravitational", 999999.9);
			}
			case 10:
			{
				if(HasSpecificBuff(iNpc, "1 UP"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "1 UP", 999999.9);
			}
			case 11:
			{
				if(HasSpecificBuff(iNpc, "Regenerating"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "Regenerating", 999999.9);
			}
			case 12:
			{
				if(HasSpecificBuff(iNpc, "Laggy"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "Laggy", 999999.9);
			}
			case 13:
			{
				//free token
				RetryBuffGiving = true;
				ApplyStatusEffect(iNpc, iNpc, "Verde", 999999.9);
			}
			case 14:
			{
				if(HasSpecificBuff(iNpc, "Void Afflicted"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "Void Afflicted", 999999.9);
			}
			case 15:
			{
				if(Elemental_DamageRatio(iNpc, Element_Warped) > 0.0)
				{
					RetryBuffGiving = true;
				}
				else
				{
					Elemental_AddWarpedDamage(iNpc, iNpc, 1, false, _, true);
					if(Elemental_DamageRatio(iNpc, Element_Warped) > 0.0)
					{
						fl_Extra_MeleeArmor[iNpc] /= 3.0;
						fl_Extra_RangedArmor[iNpc] /= 3.0;
						fl_Extra_Speed[iNpc] *= 1.1;
						fl_Extra_Damage[iNpc] *= 1.1;
					}
				}
			}
			case 16:
			{
				if(HasSpecificBuff(iNpc, "The First"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "The First", 999999.9);
			}
			case 17:
			{
				if(HasSpecificBuff(iNpc, "Perfected Instinct"))
					RetryBuffGiving = true;
				else
					ApplyStatusEffect(iNpc, iNpc, "Perfected Instinct", 999999.9);
			}
			case 18:
			{
				if(HasSpecificBuff(iNpc, "Xeno Infection") || HasSpecificBuff(iNpc, "Xeno Infection Buff Only"))
					RetryBuffGiving = true;

				Xeno_Resurgance_Enemy(iNpc);
			}
		}
	}
	
	//This is a unique enemy, give mega buffs
}


public Action Dungeon_Debuff_EnemiesLeft(int client, int args)
{
	
	return Plugin_Handled;
}

void ExplainToClientDungeon(int activator, bool force = false)
{
	//NO TRANSLATIONS SHOULD EXIST FOR THIS.
	//This is so it can be used as detection without printing anything
	if(!force)
	{
		if(!Database_IsCached(activator))
			return;
		if(WasAlreadyExplainedToClient(activator, "Explain Dungeon Do"))
			return;

		if(Items_HasNamedItem(activator, "Construction 2 Tutorial Explain"))
			return;

		Items_GiveNamedItem(activator, "Construction 2 Tutorial Explain");
		Force_ExplainBuffToClient(activator, "Explain Dungeon Do", true);
	}
	
	DataPack pack;
	CreateDataTimer(7.0, Timer_ExplainDungeons, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(activator));
	pack.WriteCell(1);
	
	//now explain fully.
}
public Action Timer_ExplainDungeons(Handle timer, DataPack pack2)
{
	pack2.Reset();
	int client = EntRefToEntIndex(pack2.ReadCell());
	if(!IsValidClient(client))
		return Plugin_Stop;
	int WhichAt = pack2.ReadCell();
	
	ExplainDoInternal(client, WhichAt);
	if(WhichAt >= 6)
		return Plugin_Stop;
	WhichAt++;
	DataPack pack;
	CreateDataTimer(10.0, Timer_ExplainDungeons, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(WhichAt);
	return Plugin_Stop;
}



void ExplainDoInternal(int client, int which)
{
	switch(which)
	{
		case 1, 2, 3, 6:
		{
			float pos[3];
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
				{
					GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
					break;
				}
			}

			char buffer[255];
			switch(which)
			{
				case 1:
				{
					FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 1", client);
				}
				case 2:
				{
					FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 2", client);
				}
				case 3:
				{
					FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 3", client);
				}
				case 6:
				{
					FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 6", client);
				}
			}
			
			pos[2] += 120.0;
			ShowAnnotationToPlayer(client, pos, buffer, 7.0, 0);
		}
		case 4:
		{

			//	ToggleEntityByName(TeleRival, true);
			int entity = FindByEntityName(TeleEnter);
			if(!IsValidEntity(entity))
				return;
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 4", client);
			float AbsPos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsPos);
			AbsPos[2] += 120.0;
			ShowAnnotationToPlayer(client, AbsPos, buffer, 7.0, 0);
		}
		case 5:
		{

			//	ToggleEntityByName(TeleRival, true);
			int entity = FindByEntityName(TeleRival);
			if(!IsValidEntity(entity))
				return;
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%T", "Explain Dungeon Mechanics 5", client);
			float AbsPos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsPos);
			AbsPos[2] += 120.0;
			ShowAnnotationToPlayer(client, AbsPos, buffer, 7.0, 0);
		}
	}
}

void NoticeDungeonNoTimeLeft()
{
	float time = NextAttackAt - GetGameTime();
	if(time > 60.0)	
	{
		NoticenoDungeon = false;
		return;
	}
	if(AttackType >= 2)
		return;

	if(!NoticenoDungeon)
	{
		CPrintToChatAll("{crimson}%t", "Dungeon Empty Untill Next Raid");
	}
	NoticenoDungeon = true;
}
#include "roguelike/dungeon_items.sp"
#include "roguelike/dungeon_encounters.sp"



