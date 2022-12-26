#pragma semicolon 1
#pragma newdecls required

#define QUEUE_TIME	90.0

static const char RoundRetryWin[][] =
{
	"vo/announcer_dec_kill03.mp3",
	"vo/announcer_dec_kill05.mp3",
	"vo/announcer_dec_kill10.mp3",
	"vo/announcer_dec_kill11.mp3",
	"vo/announcer_dec_kill14.mp3"
};

static const char RoundRetryLoss[][] =
{
	"vo/announcer_do_not_fail_again.mp3",
	"vo/announcer_do_not_fail_this_time.mp3",
	"vo/announcer_you_must_not_fail_again.mp3",
	"vo/announcer_you_must_not_fail_this_time.mp3"
};

enum struct ModEnum
{
	char Desc[128];
	int Tier;
	int Unlock;
	int Slot;
	int Level;

	Function OnSpawn;
	Function OnWaves;

	void SetupEnum(KeyValues kv)
	{
		kv.GetString("func_onspawn", this.Desc, 128);
		this.OnSpawn = GetFunctionByName(null, this.Desc);

		kv.GetString("func_onwaves", this.Desc, 128);
		this.OnWaves = GetFunctionByName(null, this.Desc);

		kv.GetString("desc", this.Desc, 128);
		this.Tier = kv.GetNum("tier");
		this.Unlock = kv.GetNum("unlock");
		this.Slot = kv.GetNum("slot");
		this.Level = kv.GetNum("level");
	}

	void CallOnSpawn(int entity)
	{
		if(this.OnSpawn != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.OnSpawn);
			Call_PushCell(entity);
			Call_Finish();
		}
	}

	void CallOnWaves(ArrayList list)
	{
		if(this.OnSpawn != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.OnSpawn);
			Call_PushCell(list);
			Call_Finish();
		}
	}
}

enum struct WaveEnum
{
	float Delay;
	int Index;
	float Pos[3];
	float Angle;

	bool Boss;
	int Level;
	int Health;
	int Rarity;

	void SetupEnum(KeyValues kv, char[] buffer, int length)
	{
		kv.GetSectionName(buffer, length);
		this.Delay = StringToFloat(buffer);

		kv.GetString("name", buffer, length);
		this.Index = StringToInt(buffer);
		if(!this.Index)
			this.Index = GetIndexByPluginName(buffer);

		kv.GetVector("pos", this.Pos);
		this.Angle = kv.GetFloat("angle", -1.0);
		this.Boss = view_as<bool>(kv.GetNum("boss"));
		this.Level = kv.GetNum("level");
		this.Health = kv.GetNum("health");
		this.Rarity = kv.GetNum("rarity");
	}
}

enum struct StageEnum
{
	float StartPos[3];
	int XP;
	int Cash;
	int Level;

	char DropName1[48];
	float DropChance1;
	int DropTier1;

	char DropName2[48];
	float DropChance2;
	int DropTier2;

	char DropName3[48];
	float DropChance3;
	int DropTier3;

	char DropName4[48];
	float DropChance4;
	int DropTier4;

	char MusicEasy[PLATFORM_MAX_PATH];
	int MusicEasyTime;
	float MusicEasyVolume;

	int MusicTier;
	char MusicHard[PLATFORM_MAX_PATH];
	int MusicHardTime;
	float MusicHardVolume;

	StringMap ModList;
	ArrayList WaveList;

	void Delete()
	{
		delete this.ModList;
		delete this.WaveList;
	}

	void SetupEnum(KeyValues kv, char[] buffer, int length)
	{
		kv.GetVector("pos", this.StartPos);
		this.XP = kv.GetNum("xp");
		this.Cash = kv.GetNum("cash");
		this.Level = kv.GetNum("level");

		kv.GetString("drop_name_1", this.DropName1, 48);
		this.DropChance1 = kv.GetFloat("drop_chance_1", 1.0);
		this.DropTier1 = kv.GetNum("drop_tier_1");

		kv.GetString("drop_name_2", this.DropName2, 48);
		this.DropChance2 = kv.GetFloat("drop_chance_2", 1.0);
		this.DropTier2 = kv.GetNum("drop_tier_2");

		kv.GetString("drop_name_3", this.DropName3, 48);
		this.DropChance3 = kv.GetFloat("drop_chance_3", 1.0);
		this.DropTier3 = kv.GetNum("drop_tier_3");

		kv.GetString("drop_name_4", this.DropName4, 48);
		this.DropChance4 = kv.GetFloat("drop_chance_4", 1.0);
		this.DropTier4 = kv.GetNum("drop_tier_4");

		kv.GetString("music_easy_file", this.MusicEasy, PLATFORM_MAX_PATH);
		if(this.MusicEasy[0])
			PrecacheSound(this.MusicEasy);
		
		this.MusicEasyTime = kv.GetNum("music_easy_duration");
		this.MusicEasyVolume = kv.GetFloat("music_easy_volume", 1.0);
		
		if(kv.GetNum("music_easy_download"))
		{
			Format(buffer, length, "sound/%s", this.MusicEasy);
			ReplaceString(buffer, length, "#", "");
			if(FileExists(buffer, true))
			{
				AddFileToDownloadsTable(buffer);
			}
			else
			{
				LogError("'%s' is missing from files", buffer);
			}
		}

		kv.GetString("music_hard_file", this.MusicHard, PLATFORM_MAX_PATH);
		if(this.MusicHard[0])
			PrecacheSound(this.MusicHard);
		
		this.MusicHardTime = kv.GetNum("music_hard_duration");
		this.MusicHardVolume = kv.GetFloat("music_hard_volume", 1.0);
		this.MusicTier = kv.GetNum("music_hard_cap", 99999);
		
		if(kv.GetNum("download"))
		{
			Format(buffer, length, "sound/%s", this.MusicHard);
			ReplaceString(buffer, length, "#", "");
			if(FileExists(buffer, true))
			{
				AddFileToDownloadsTable(buffer);
			}
			else
			{
				LogError("'%s' is missing from files", buffer);
			}
		}

		if(kv.JumpToKey("Mods"))
		{
			if(kv.GotoFirstSubKey())
			{
				ModEnum mod;
				this.ModList = new StringMap();

				do
				{
					kv.GetSectionName(buffer, length);
					mod.SetupEnum(kv);
					this.ModList.SetArray(buffer, mod, sizeof(mod));
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}

			kv.GoBack();
		}
		else
		{
			this.ModList = null;
		}

		WaveEnum wave;
		this.WaveList = new ArrayList(sizeof(WaveEnum));

		if(kv.JumpToKey("Waves"))
		{
			if(kv.GotoFirstSubKey())
			{
				do
				{
					wave.SetupEnum(kv, buffer, length);
					this.WaveList.PushArray(wave);
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}

			kv.GoBack();
		}
	}

	void DoAllDrops(int client, int tier)
	{
		TextStore_AddItemCount(client, "Credits", this.Cash + tier);
		TextStore_AddItemCount(client, "XP", this.XP + tier);

		float multi = 1.0 + float(tier) * 0.1;
		float luck = 1.0 + (float(Stats_Luck(client)) / 300.0);
		
		if(this.DropName1[0])
			RollItemDrop(client, this.DropName1, this.DropChance1 * multi * luck);
		
		if(this.DropName2[0])
			RollItemDrop(client, this.DropName2, this.DropChance2 * multi * luck);
		
		if(this.DropName3[0])
			RollItemDrop(client, this.DropName3, this.DropChance3 * multi * luck);
		
		if(this.DropName4[0])
			RollItemDrop(client, this.DropName4, this.DropChance4 * multi * luck);

	}
}

enum struct DungeonEnum
{
	char Model[PLATFORM_MAX_PATH];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];

	float RespawnPos[3];
	
	int EntRef;

	StringMap StageList;

	ArrayList ModList;
	ArrayList WaveList;
	char CurrentStage[64];
	float StartTime;
	int PlayerCount;
	int CurrentHost;
	int LastSoundTime;

	int TierLevel(ArrayList slotList)
	{
		int tier;
		if(this.ModList && this.CurrentStage[0])
		{
			static StageEnum stage;
			if(this.StageList.GetArray(this.CurrentStage, stage, sizeof(stage)))
			{
				int length = this.ModList.Length;
				for(int i; i < length; i++)
				{
					static ModEnum mod;
					this.ModList.GetString(i, mod.Desc, sizeof(mod.Desc));
					if(stage.ModList.GetArray(mod.Desc, mod, sizeof(mod)))
					{
						tier += mod.Tier;

						if(slotList && mod.Slot)
							slotList.Push(mod.Slot);
					}
				}
			}
		}
		return tier;
	}

	void Delete()
	{
		delete this.ModList;
		delete this.WaveList;

		StageEnum stage;
		StringMapSnapshot snap = this.StageList.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			this.StageList.GetArray(name, stage, sizeof(stage));
			stage.Delete();
		}

		delete snap;
		delete this.StageList;
	}
	
	void SetupEnum(KeyValues kv, char[] buffer, int length)
	{
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH);
		if(!this.Model[0])
			SetFailState("Missing model in dungeon.cfg");
		
		this.Scale = kv.GetFloat("scale", 1.0);
		
		kv.GetString("anim_idle", this.Idle, 64);
		
		kv.GetVector("pos", this.Pos);
		kv.GetVector("ang", this.Ang);
		
		kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
		if(this.Wear1[0])
			PrecacheModel(this.Wear1);
		
		kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
		if(this.Wear2[0])
			PrecacheModel(this.Wear2);
		
		kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
		if(this.Wear3[0])
			PrecacheModel(this.Wear3);
		
		kv.GetVector("deathpos", this.RespawnPos);

		StageEnum stage;
		this.StageList = new StringMap();

		if(kv.GotoFirstSubKey())
		{
			do
			{
				stage.SetupEnum(kv, buffer, length);
				kv.GetSectionName(buffer, length);
				this.StageList.SetArray(buffer, stage, sizeof(stage));
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}
	}
	
	void Despawn()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);

			int brush = EntRefToEntIndex(b_OwnerToBrush[entity]);
			if(IsValidEntity(brush))
			{
				RemoveEntity(brush);
			}

			if(entity != -1)
				RemoveEntity(entity);
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void Spawn()
	{
		if(EntRefToEntIndex(this.EntRef) == INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				
				
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				
				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);

				int brush = SpawnSeperateCollisionBox(entity);
				//Just reuse it.
				b_BrushToOwner[brush] = EntIndexToEntRef(entity);
				b_OwnerToBrush[entity] = EntIndexToEntRef(brush);
				
				if(this.Wear1[0])
					GivePropAttachment(entity, this.Wear1);
				
				if(this.Wear2[0])
					GivePropAttachment(entity, this.Wear2);
				
				if(this.Wear3[0])
					GivePropAttachment(entity, this.Wear3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetAnimation", entity, entity);
				
				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static ConVar mp_disable_respawn_times;
static Handle SyncHud;
static Handle DungeonTimer;
static StringMap DungeonList;
static KeyValues SaveKv;
static char DungeonMenu[MAXTF2PLAYERS][64];
static bool AltMenu[MAXTF2PLAYERS];
static char InDungeon[MAXENTITIES][64];
static int LastResult[MAXENTITIES];

void Dungeon_PluginStart()
{
	SyncHud = CreateHudSynchronizer();
	mp_disable_respawn_times = FindConVar("mp_disable_respawn_times");
}

void Dungeon_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Dungeon"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "dungeon");
		kv = new KeyValues("Dungeon");
		kv.ImportFromFile(buffer);
	}

	delete DungeonTimer;

	if(DungeonList)
	{
		DungeonEnum dungeon;
		StringMapSnapshot snap = DungeonList.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			DungeonList.GetArray(name, dungeon, sizeof(dungeon));
			dungeon.Delete();
		}

		delete snap;
		delete DungeonList;
	}
	
	DungeonList = new StringMap();

	DungeonEnum dungeon;
	dungeon.EntRef = INVALID_ENT_REFERENCE;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			dungeon.SetupEnum(kv, buffer, sizeof(buffer));
			kv.GetSectionName(buffer, sizeof(buffer));
			DungeonList.SetArray(buffer, dungeon, sizeof(dungeon));
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
	
	delete SaveKv;

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "dungeon_savedata");
	SaveKv = new KeyValues("SaveDData");
	SaveKv.ImportFromFile(buffer);
}

int Dungeon_GetClientRank(int client, const char[] name, const char[] stage)
{
	int rank;

	SaveKv.Rewind();
	if(SaveKv.JumpToKey(name) && SaveKv.JumpToKey(stage))
	{
		static char steamid[64];
		if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
			rank = SaveKv.GetNum(steamid, -1);
	}

	return rank;
}

void Dungeon_EnableZone(const char[] name)
{
	static DungeonEnum dungeon;
	if(DungeonList.GetArray(name, dungeon, sizeof(dungeon)))
	{
		dungeon.Spawn();
		DungeonList.SetArray(name, dungeon, sizeof(dungeon));
	}
}

void Dungeon_DisableZone(const char[] name)
{
	static DungeonEnum dungeon;
	if(DungeonList.GetArray(name, dungeon, sizeof(dungeon)))
	{
		dungeon.Despawn();
		DungeonList.SetArray(name, dungeon, sizeof(dungeon));
	}
}

bool Dungeon_Interact(int client, int entity)
{
	StringMapSnapshot snap = DungeonList.Snapshot();

	bool result;
	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i) + 1;
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		static DungeonEnum dungeon;
		DungeonList.GetArray(name, dungeon, sizeof(dungeon));
		if(EntRefToEntIndex(dungeon.EntRef) == entity)
		{
			strcopy(DungeonMenu[client], sizeof(DungeonMenu[]), name);
			ShowMenu(client, 0);
			result = true;
			break;
		}
	}

	delete snap;
	return result;
}

static void ShowMenu(int client, int page)
{
	static DungeonEnum dungeon;
	if(DungeonList.GetArray(DungeonMenu[client], dungeon, sizeof(dungeon)))
	{
		Menu menu = new Menu(Dungeon_MenuHandle);

		int leader = Party_GetPartyLeader(client);
		if(!leader)
			leader = client;
		
		static StageEnum stage;
		if(dungeon.CurrentStage[0])
		{
			int time = RoundToFloor(GetGameTime() - dungeon.StartTime);
			if(time >= 0)
			{
				menu.SetTitle("RPG Fortress\n \nContingency Contract:\n%s △%d\nTime Elapsed: %d:%02d\n ", dungeon.CurrentStage, dungeon.TierLevel(null), time / 60, time % 60);

				for(int target = 1; target <= MaxClients; target++)
				{
					if(StrEqual(InDungeon[target], DungeonMenu[client]))
					{
						if(client == target)
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%N (Leave)\n ", client);
							
							if(menu.ItemCount)
							{
								menu.InsertItem(0, NULL_STRING, dungeon.CurrentStage);
							}
							else
							{
								menu.AddItem(NULL_STRING, dungeon.CurrentStage);
							}
						}
						else if(IsPlayerAlive(target))
						{
							GetClientName(target, dungeon.CurrentStage, sizeof(dungeon.CurrentStage));
							menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
						}
						else
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%N (Dead)", target);
							menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
						}
					}
				}
			}
			else
			{
				time = -time;

				ArrayList slots;
				menu.SetTitle("RPG Fortress\n \nContingency Contract:\n%s △%d\nStarts In: %d:%02d\n ", dungeon.CurrentStage, dungeon.TierLevel(slots), time / 60, time % 60);

				dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage));

				if(AltMenu[client] || !stage.ModList)
				{
					AltMenu[client] = true;

					bool found;
					for(int target = 1; target <= MaxClients; target++)
					{
						if(client == target && client == leader)
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%N (Leave)\n ", client);
							
							if(menu.ItemCount)
							{
								menu.InsertItem(0, NULL_STRING, dungeon.CurrentStage);
							}
							else
							{
								menu.AddItem(NULL_STRING, dungeon.CurrentStage);
							}
							
							found = true;
						}
						else if(client != leader && target == leader)
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%N (Party Leader)", target);
							menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
						}
						else if(dungeon.CurrentHost == target)
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%N (Host)", target);
							menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
						}
						else if(StrEqual(InDungeon[target], DungeonMenu[client]))
						{
							GetClientName(target, dungeon.CurrentStage, sizeof(dungeon.CurrentStage));
							menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
						}
					}

					if(!found)
					{
						if(client == leader)
						{
							GetDisplayString(stage.Level, dungeon.CurrentStage, sizeof(dungeon.CurrentStage));
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "Enter Queue (%s)\n ", dungeon.CurrentStage);
							menu.InsertItem(0, NULL_STRING, dungeon.CurrentStage, stage.Level > Level[client] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
						}
						else
						{
							menu.InsertItem(0, NULL_STRING, "Party Leader Must Enter Queue\n ", ITEMDRAW_DISABLED);
						}
					}
				}
				else
				{
					StringMapSnapshot snap = stage.ModList.Snapshot();

					int length = snap.Length;
					for(int i; i < length; i++)
					{
						int size = snap.KeyBufferSize(i) + 1;
						char[] name = new char[size];
						snap.GetKey(i, name, size);

						static ModEnum mod;
						stage.ModList.GetArray(name, mod, sizeof(mod));
						if(dungeon.ModList.FindString(name) != -1)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[X] %s △%d\n%s\n ", name, mod.Tier, mod.Desc);
						}
						else if(Dungeon_GetClientRank(client, DungeonMenu[client], dungeon.CurrentStage) < mod.Unlock)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[!] %s △%d\nComplete with atleast △%d to unlock\n ", name, mod.Tier, mod.Unlock);
							menu.AddItem(NULL_STRING, mod.Desc, ITEMDRAW_DISABLED);
							continue;
						}
						else if(mod.Slot && slots.FindValue(mod.Slot) != -1)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[!] %s △%d\nConflicts with other modifiers\n ", name, mod.Tier);
							menu.AddItem(NULL_STRING, mod.Desc, ITEMDRAW_DISABLED);
							continue;
						}
						else
						{
							Format(mod.Desc, sizeof(mod.Desc), "[ ] %s △%d\n%s\n ", name, mod.Tier, mod.Desc);
						}

						menu.AddItem(name, mod.Desc, client == dungeon.CurrentHost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
					}

					delete snap;

					menu.Pagination = 3;
				}

				menu.ExitBackButton = view_as<bool>(stage.ModList);
			}
		}
		else
		{
			if(client == leader)
			{
				menu.SetTitle("RPG Fortress\n \nContingency Contract:");
			}
			else
			{
				menu.SetTitle("RPG Fortress\n \nContingency Contract:\nYour Party Leader is %N", leader);
			}

			StringMapSnapshot snap = dungeon.StageList.Snapshot();

			int length = snap.Length;
			for(int i; i < length; i++)
			{
				int size = snap.KeyBufferSize(i) + 1;
				char[] name = new char[size];
				snap.GetKey(i, name, size);

				if(dungeon.StageList.GetArray(name, stage, sizeof(stage)))
				{
					GetDisplayString(stage.Level, stage.MusicEasy, sizeof(stage.MusicEasy));
					Format(stage.MusicEasy, sizeof(stage.MusicEasy), "%s (%s)", name, stage.MusicEasy);
					menu.AddItem(name, stage.MusicEasy, (stage.Level > Level[client] || client != leader) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
			}

			delete snap;
		}

		menu.DisplayAt(client, page, MENU_TIME_FOREVER);
	}
}

public int Dungeon_MenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				AltMenu[client] = !AltMenu[client];
				ShowMenu(client, 0);
			}
		}
		case MenuAction_Select:
		{
			static DungeonEnum dungeon;
			if(DungeonList.GetArray(DungeonMenu[client], dungeon, sizeof(dungeon)))
			{
				static StageEnum stage;
				if(dungeon.CurrentStage[0])
				{
					if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
					{
						menu.GetItem(choice, dungeon.CurrentStage, sizeof(dungeon.CurrentStage));
						if(dungeon.CurrentHost != client && !AltMenu[client] && GetGameTime() < dungeon.StartTime)	// Add/Remove Mod
						{
							if(!dungeon.CurrentStage[0] || !dungeon.ModList)
							{
								ShowMenu(client, 0);
							}
							else
							{
								int pos = dungeon.ModList.FindString(dungeon.CurrentStage);
								if(pos != -1)
								{
									dungeon.ModList.Erase(pos);
								}
								else if(stage.ModList.ContainsKey(dungeon.CurrentStage))
								{
									dungeon.ModList.PushString(dungeon.CurrentStage);
								}

								ShowMenu(client, choice);
							}
						}
						else if(dungeon.CurrentStage[0])
						{
							ShowMenu(client, 0);
						}
						else	// Join/Leave Lobby
						{
							bool alreadyIn = StrEqual(InDungeon[client], DungeonMenu[client]);
							for(int target = 1; target <= MaxClients; target++)
							{
								if(client == target || Party_IsClientMember(target, client))
								{
									Dungeon_ClientDisconnect(target, true);

									if(!alreadyIn)
									{
										if(LastResult[target] > 0)
										{
											ClientCommand(target, "playgamesound %s", RoundRetryWin[GetURandomInt() % sizeof(RoundRetryWin)]);
											LastResult[target] = 0;
										}
										else if(LastResult[target] < 0)
										{
											ClientCommand(target, "playgamesound %s", RoundRetryLoss[GetURandomInt() % sizeof(RoundRetryLoss)]);
											LastResult[target] = 0;
										}

										strcopy(InDungeon[target], sizeof(InDungeon[]), DungeonMenu[client]);
									}
								}
							}

							if(!alreadyIn)
								ShowMenu(client, 0);
						}
					}
				}
				else	// Create Lobby
				{
					menu.GetItem(choice, dungeon.CurrentStage, sizeof(dungeon.CurrentStage));
					if(dungeon.CurrentStage[0] && dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
					{
						delete dungeon.ModList;
						if(stage.ModList)
							dungeon.ModList = new ArrayList(ByteCountToCells(64));
						
						dungeon.CurrentHost = client;
						dungeon.StartTime = GetGameTime() + QUEUE_TIME;
						DungeonList.SetArray(DungeonMenu[client], dungeon, sizeof(dungeon));
						strcopy(InDungeon[client], sizeof(InDungeon[]), DungeonMenu[client]);
						
						if(!DungeonTimer)
							DungeonTimer = CreateTimer(0.2, Dungeon_Timer, _, TIMER_REPEAT);
						
						if(LastResult[client] > 0)
						{
							ClientCommand(client, "playgamesound %s", RoundRetryWin[GetURandomInt() % sizeof(RoundRetryWin)]);
							LastResult[client] = 0;
						}
						else if(LastResult[client] < 0)
						{
							ClientCommand(client, "playgamesound %s", RoundRetryLoss[GetURandomInt() % sizeof(RoundRetryLoss)]);
							LastResult[client] = 0;
						}
					}

					ShowMenu(client, 0);
				}
			}
		}
	}
	return 0;
}

void Dungeon_ResetEntity(int entity)
{
	InDungeon[entity][0] = 0;
}

void Dungeon_ClientDisconnect(int client, bool alive = false)
{
	AltMenu[client] = false;
	LastResult[client] = 0;

	if(InDungeon[client][0])
	{
		static DungeonEnum dungeon;
		if(DungeonList.GetArray(InDungeon[client], dungeon, sizeof(dungeon)) && dungeon.CurrentHost == client && !dungeon.WaveList)
		{
			dungeon.StartTime += 30.0;
			float maximum = GetGameTime() + QUEUE_TIME;
			if(dungeon.StartTime > maximum)
				dungeon.StartTime = maximum;
			
			dungeon.CurrentHost = 0;
			for(int target = 1; target <= MaxClients; target++)
			{
				if(target != client)
				{
					int leader = dungeon.CurrentHost ? 0 : Party_GetPartyLeader(target);
					if((!leader || leader == client) && StrEqual(InDungeon[client], InDungeon[target]))
					{
						if(!dungeon.CurrentHost)
							dungeon.CurrentHost = target;
						
						ClientCommand(target, "playgamesound vo/announcer_time_added.mp3");
						SPrintToChat(target, "%N left the lobby as the host, %N is the new host!", client, dungeon.CurrentHost);
					}
				}
			}
		}

		if(alive)
			mp_disable_respawn_times.ReplicateToClient(client, "0");

		InDungeon[client][0] = 0;
		Dungeon_CheckAlivePlayers(client);
	}
}

void Dungeon_CheckAlivePlayers(int killed)
{
	StringMapSnapshot snap = DungeonList.Snapshot();

	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i) + 1;
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		bool found;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(client != killed && StrEqual(InDungeon[client], name) && IsPlayerAlive(client))
			{
				found = true;
				break;
			}
		}

		if(!found)
			CleanDungeon(name, false);
	}

	delete snap;
}

bool Dungeon_MenuOverride(int client)
{
	if(InDungeon[client][0] && !IsPlayerAlive(client))
	{
		static DungeonEnum dungeon;
		if(DungeonList.GetArray(InDungeon[client], dungeon, sizeof(dungeon)) && dungeon.WaveList)
		{
			strcopy(DungeonMenu[client], sizeof(DungeonMenu[]), InDungeon[client]);
			ShowMenu(client, 0);
			return true;
		}
	}

	return false;
}

static void StartDungeon(const char[] name)
{
	static DungeonEnum dungeon;
	if(DungeonList.GetArray(name, dungeon, sizeof(dungeon)))
	{
		static StageEnum stage;
		if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
		{
			dungeon.PlayerCount = 0;

			int rand = GetURandomInt() % 11;
			int[] clients = new int[MaxClients];
			for(int client = 1; client <= MaxClients; client++)
			{
				if(StrEqual(InDungeon[client], name))
				{
					InDungeon[client][0] = 0;
					mp_disable_respawn_times.ReplicateToClient(client, "1");

					for(int i; i < 3; i++)
					{
						f3_SpawnPosition[client][i] = stage.StartPos[i];
					}

					ClientCommand(client, "playgamesound vo/compmode/cm_admin_round_start_%02d.mp3", rand + 1);
					TF2_RespawnPlayer(client);
					clients[dungeon.PlayerCount++] = client;
				}
			}

			delete dungeon.WaveList;
			dungeon.WaveList = stage.WaveList.Clone();
			
			int tier;
			if(dungeon.ModList)
			{
				int length = dungeon.ModList.Length;
				for(int i; i < length; i++)
				{
					static ModEnum mod;
					dungeon.ModList.GetString(i, mod.Desc, sizeof(mod.Desc));
					if(stage.ModList.GetArray(mod.Desc, mod, sizeof(mod)))
					{
						tier += mod.Tier;

						for(int c; c < dungeon.PlayerCount; c++)
						{
							SPrintToChat(clients[c], mod.Desc);
						}

						mod.CallOnWaves(dungeon.WaveList);
					}

				}
			}

			for(int c; c < dungeon.PlayerCount; c++)
			{
				if(stage.MusicTier > tier)
				{
					if(stage.MusicEasy[0])
						Music_SetOverride(clients[c], stage.MusicEasy, stage.MusicEasyTime, stage.MusicEasyVolume);	
				}
				else if(stage.MusicHard[0])
				{
					Music_SetOverride(clients[c], stage.MusicHard, stage.MusicHardTime, stage.MusicHardVolume);	
				}
			}
			
			DungeonList.SetArray(name, dungeon, sizeof(dungeon));
		}
		else
		{
			ThrowError("Somehow got invalid stage '%s'", dungeon.CurrentStage);
		}
	}
	else
	{
		ThrowError("Somehow got invalid dungeon '%s'", name);
	}
}

static void CleanDungeon(const char[] name, bool victory)
{
	static DungeonEnum dungeon;
	if(DungeonList.GetArray(name, dungeon, sizeof(dungeon)) && dungeon.CurrentStage[0])
	{
		static StageEnum stage;
		if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
		{
			static ModEnum mod;

			int tier;
			if(dungeon.ModList)
			{
				int length = dungeon.ModList.Length;
				for(int i; i < length; i++)
				{
					dungeon.ModList.GetString(i, mod.Desc, sizeof(mod.Desc));
					if(stage.ModList.GetArray(mod.Desc, mod, sizeof(mod)))
						tier += mod.Tier;
				}
			}

			SaveKv.Rewind();
			SaveKv.JumpToKey(name, true);
			SaveKv.JumpToKey(dungeon.CurrentStage, true);

			bool clear = (victory || !dungeon.WaveList);
			for(int client = 1; client <= MaxClients; client++)
			{
				if(StrEqual(InDungeon[client], name))
				{
					clear = true;
					if(dungeon.WaveList)
					{
						InDungeon[client][0] = 0;
						
						for(int i; i < 3; i++)
						{
							f3_SpawnPosition[client][i] = dungeon.RespawnPos[i];
						}
						
						CreateTimer(8.25, Dungeon_EndMusicTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						CreateTimer(8.25, Dungeon_RespawnTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

						if(victory)
						{
							LastResult[client] = 1;
							Music_SetOverride(client, "misc/your_team_won.mp3", 999, 1.0);

							if(IsPlayerAlive(client))
								TF2_AddCondition(client, TFCond_HalloweenCritCandy, 8.1);

							stage.DoAllDrops(client, tier);
							if(GetClientAuthId(client, AuthId_Steam3, mod.Desc, sizeof(mod.Desc)))
								SaveKv.SetNum(mod.Desc, tier);
						}
						else
						{
							LastResult[client] = -1;
							Music_SetOverride(client, "misc/your_team_lost.mp3", 999, 1.0);
						}
					}
				}
			}

			if(victory)
			{
				BuildPath(Path_SM, mod.Desc, sizeof(mod.Desc), CONFIG_CFG, "dungeon_savedata");

				SaveKv.Rewind();
				SaveKv.ExportToFile(mod.Desc);
			}

			if(clear)
			{
				int i = MaxClients + 1;
				while((i = FindEntityByClassname(i, "base_boss")) != -1)
				{
					if(StrEqual(InDungeon[i], name))
						NPC_Despawn(i);
				}
				
				dungeon.CurrentStage[0] = 0;
				dungeon.CurrentHost = 0;
				dungeon.StartTime = 0.0;
				delete dungeon.ModList;
				delete dungeon.WaveList;
				DungeonList.SetArray(name, dungeon, sizeof(dungeon));
			}
		}
		else
		{
			ThrowError("Somehow got invalid stage '%s'", dungeon.CurrentStage);
		}
	}
}

bool Dungeon_CanClientRespawn(int client)
{
	if(InDungeon[client][0])
	{
		static DungeonEnum dungeon;
		DungeonList.GetArray(InDungeon[client], dungeon, sizeof(dungeon));
		if(dungeon.WaveList)
			return false;
	}

	return true;
}

public Action Dungeon_EndMusicTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
		Music_SetOverride(client);
	
	return Plugin_Stop;
}

public Action Dungeon_RespawnTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && f3_SpawnPosition[client][0])
	{
		TF2_RespawnPlayer(client);
		mp_disable_respawn_times.ReplicateToClient(client, "0");
	}
	return Plugin_Stop;
}

public Action Dungeon_Timer(Handle timer)
{
	bool found;
	StringMapSnapshot snap = DungeonList.Snapshot();

	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i) + 1;
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		static DungeonEnum dungeon;
		if(DungeonList.GetArray(name, dungeon, sizeof(dungeon)))
		{
			static ModEnum mod;

			if(dungeon.WaveList)
			{
				found = true;
				float time = GetGameTime() - dungeon.StartTime;
				size = dungeon.WaveList.Length;
				if(size)
				{
					for(int a; a < size; a++)
					{
						static WaveEnum wave;
						dungeon.WaveList.GetArray(a, wave);
						if(wave.Delay < time)
						{
							static float ang[3];
							ang[1] = wave.Angle;
							if(ang[1] < 0.0)
								ang[1] = GetURandomFloat() * 360.0;

							int entity = Npc_Create(wave.Index, 0, wave.Pos, ang, false);
							if(entity != -1)
							{
								Level[entity] = wave.Level;
								i_CreditsOnKill[entity] = 0;
								XP[entity] = Level[entity] / 3;
								b_thisNpcIsABoss[entity] = wave.Boss;
								b_NpcIsInADungeon[entity] = true;
								
								if(wave.Health)
								{
									// +20% each player
									wave.Health = wave.Health * (4 + dungeon.PlayerCount) / 5;
									SetEntProp(entity, Prop_Data, "m_iMaxHealth", wave.Health);
									SetEntProp(entity, Prop_Data, "m_iHealth", wave.Health);
								}

								static StageEnum stage;
								if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
								{
									size = dungeon.ModList.Length;
									for(int b; b < size; b++)
									{
										dungeon.ModList.GetString(b, mod.Desc, sizeof(mod.Desc));
										if(stage.ModList.GetArray(mod.Desc, mod, sizeof(mod)))
										{
											Level[entity] += mod.Level;
											mod.CallOnSpawn(entity);
										}
									}
								}

								Apply_Text_Above_Npc(entity, wave.Rarity, GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
							}

							dungeon.WaveList.Erase(a);
							break;
						}
					}
				}
				else
				{
					int entity = MaxClients + 1;
					while((entity = FindEntityByClassname(entity, "base_boss")) != -1)
					{
						if(StrEqual(InDungeon[entity], name) && GetEntProp(entity, Prop_Send, "m_iTeamNum") != 2)
							break;
					}

					if(entity == -1)
						CleanDungeon(name, true);
				}
			}
			else if(dungeon.StartTime)
			{
				found = true;
				int time = RoundToCeil(dungeon.StartTime - GetGameTime());
				if(time > 0)
				{
					for(int client = 1; client <= MaxClients; client++)
					{
						if(StrEqual(InDungeon[client], name))
						{
							if(dungeon.LastSoundTime != time)
							{
								switch(time)
								{
									case 30, 20, 10, 5, 4, 3, 2, 1:
										ClientCommand(client, "playgamesound vo/announcer_begins_%dsec.mp3", time);
								}
							}

							SetHudTextParams(-1.0, 0.08, 0.3, 200, 69, 0, 200);
							ShowSyncHudText(client, SyncHud, "%d:%02d\n%s △%d", time / 60, time % 60, dungeon.CurrentStage, dungeon.TierLevel(null));
						}
					}

					if(dungeon.LastSoundTime != time)
					{
						dungeon.LastSoundTime = time;
						DungeonList.SetArray(name, dungeon, sizeof(dungeon));
					}
				}
				else
				{
					StartDungeon(name);
				}
			}
		}
	}

	delete snap;

	if(found)
		return Plugin_Continue;
	
	DungeonTimer = null;
	return Plugin_Stop;
}

static void RollItemDrop(int client, const char[] name, float chance)
{
	if(chance > GetURandomFloat())
		TextStore_AddItemCount(client, name, 1);
}

static int RandomStaticSeed(int seed, int rand)
{
	if(rand < 0)
		rand = -rand;
	
	if(rand < 2)
		rand = 2;
	
	if(seed > (2147483646 / rand))
		return seed - (2147483646 / rand);
	
	return seed * rand;
}

/*
	func_onspawn
*/

public void Dungeon_Spawn_20HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 6 / 5;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_25HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 5 / 4;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_33HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 4 / 3;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_50HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 3 / 2;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_75HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 7 / 4;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_100HP(int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 2;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

/*
	func_onwaves
*/

public void Dungeon_Wave_TenFastZombies(ArrayList list)
{
	int length = list.Length;
	int seed = length;

	for(int i; i < 10; i++)
	{
		seed = RandomStaticSeed(seed, i + 2);

		static WaveEnum wave;
		list.GetArray(seed % length, wave);
		
		wave.Index = FAST_ZOMBIE;
		wave.Boss = false;
		wave.Level--;
		wave.Rarity = 1;

		list.PushArray(wave);
	}
}