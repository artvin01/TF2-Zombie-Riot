#pragma semicolon 1
#pragma newdecls required

#include <adt_trie_sort>

#define QUEUE_TIME	60.0

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
	char Name[32];
	char Desc[168];
	int Tier;
	int Unlock;
	int Slot;
	int Level;

	Function OnPlayer;
	Function OnSpawn;
	Function OnWaves;

	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);

		kv.GetString("func_onplayer", this.Desc, 168);
		this.OnPlayer = GetFunctionByName(null, this.Desc);

		kv.GetString("func_onspawn", this.Desc, 168);
		this.OnSpawn = GetFunctionByName(null, this.Desc);

		kv.GetString("func_onwaves", this.Desc, 168);
		this.OnWaves = GetFunctionByName(null, this.Desc);

		kv.GetString("desc", this.Desc, 168);
		this.Tier = kv.GetNum("tier");
		this.Unlock = kv.GetNum("unlock");
		this.Slot = kv.GetNum("slot");
		this.Level = kv.GetNum("level");
	}

	void CallOnPlayer(int client)
	{
		if(this.OnPlayer != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.OnPlayer);
			Call_PushCell(client);
			Call_Finish();
		}
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
		if(this.OnWaves != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.OnWaves);
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
	int HPRegen;
	float ExtraMeleeRes;
	float ExtraRangedRes;
	float ExtraSpeed;
	float ExtraDamage;
	char CustomName[64];
	char Data[512];

	void SetupEnum(KeyValues kv, char[] buffer, int length)
	{
		kv.GetSectionName(buffer, length);
		this.Delay = StringToFloat(buffer);

		kv.GetString("name", buffer, length);
		this.Index = NPC_GetByPlugin(buffer);

		kv.GetVector("pos", this.Pos);
		this.Angle = kv.GetFloat("angle", -1.0);
		this.Boss = view_as<bool>(kv.GetNum("boss"));
		this.Level = kv.GetNum("level");
		this.Health = kv.GetNum("health");
		this.Rarity = kv.GetNum("rarity");
		this.HPRegen = kv.GetNum("hpregen");

		this.ExtraMeleeRes = kv.GetFloat("extra_melee_res", 1.0);
		this.ExtraRangedRes = kv.GetFloat("extra_ranged_res", 1.0);
		this.ExtraSpeed = kv.GetFloat("extra_speed", 1.0);
		this.ExtraDamage = kv.GetFloat("extra_damage", 1.0);
		kv.GetString("custom_name", this.CustomName, sizeof(this.CustomName));
		kv.GetString("data", this.Data, sizeof(this.Data));
	}
}

enum struct StageEnum
{
	float StartPos[3];
	int XP;
	int Cash;
	int Level;
	int MaxLevel;
	int MaxPlayers;
	int MinRisk;
	char Quest[64];

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

	char DropName5[48];
	float DropChance5;
	int DropTier5;
	
	char DropName6[48];
	float DropChance6;
	int DropTier6;
	
	char DropName7[48];
	float DropChance7;
	int DropTier7;
	
	char DropName8[48];
	float DropChance8;
	int DropTier8;
	
	char DropName9[48];
	float DropChance9;
	int DropTier9;

	char MusicEasy[PLATFORM_MAX_PATH];
	int MusicEasyTime;
	float MusicEasyVolume;
	bool MusicEasyCustom;
	char MusicEasyDesc[PLATFORM_MAX_PATH];

	int MusicTier;
	char MusicHard[PLATFORM_MAX_PATH];
	int MusicHardTime;
	float MusicHardVolume;
	bool MusicHardCustom;
	char MusicHardDesc[PLATFORM_MAX_PATH];

	ArrayList ModList;
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
		this.MaxLevel = kv.GetNum("maxlevel", this.Level * 21 / 20);
		this.MaxPlayers = kv.GetNum("maxplayers", 10);
		this.MinRisk = kv.GetNum("minrisk", -1);

		kv.GetString("quest", this.Quest, 64);

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

		kv.GetString("drop_name_5", this.DropName5, 48);
		this.DropChance5 = kv.GetFloat("drop_chance_5", 1.0);
		this.DropTier5 = kv.GetNum("drop_tier_5");

		kv.GetString("drop_name_6", this.DropName6, 48);
		this.DropChance6 = kv.GetFloat("drop_chance_6", 1.0);
		this.DropTier6 = kv.GetNum("drop_tier_6");

		kv.GetString("drop_name_7", this.DropName7, 48);
		this.DropChance7 = kv.GetFloat("drop_chance_7", 1.0);
		this.DropTier7 = kv.GetNum("drop_tier_7");

		kv.GetString("drop_name_8", this.DropName8, 48);
		this.DropChance8 = kv.GetFloat("drop_chance_8", 1.0);
		this.DropTier8 = kv.GetNum("drop_tier_8");

		kv.GetString("drop_name_9", this.DropName9, 48);
		this.DropChance9 = kv.GetFloat("drop_chance_9", 1.0);
		this.DropTier9 = kv.GetNum("drop_tier_9");

		kv.GetString("music_easy_file", this.MusicEasy, PLATFORM_MAX_PATH);
		this.MusicEasyTime = kv.GetNum("music_easy_duration");
		this.MusicEasyVolume = kv.GetFloat("music_easy_volume", 1.0);
		int download = kv.GetNum("music_easy_download");
		kv.GetString("music_easy_desc", this.MusicEasyDesc, PLATFORM_MAX_PATH);
		this.MusicEasyCustom = false;

		if(this.MusicEasy[0])
		{
			if(download)
			{
				this.MusicEasyCustom = true;
				PrecacheSoundCustom(this.MusicEasy, _, download);
			}
			else
			{
				PrecacheSound(this.MusicEasy);
			}
		}
		
		kv.GetString("music_hard_file", this.MusicHard, PLATFORM_MAX_PATH);
		this.MusicHardTime = kv.GetNum("music_hard_duration");
		this.MusicHardVolume = kv.GetFloat("music_hard_volume", 1.0);
		download = kv.GetNum("music_hard_download");
		this.MusicTier = kv.GetNum("music_hard_cap", 99999);
		kv.GetString("music_hard_desc", this.MusicHardDesc, PLATFORM_MAX_PATH);
		this.MusicHardCustom = false;

		if(this.MusicHard[0])
		{
			if(download)
			{
				this.MusicHardCustom = true;
				PrecacheSoundCustom(this.MusicHard, _, download);
			}
			else
			{
				PrecacheSound(this.MusicHard);
			}
		}

		if(kv.JumpToKey("Mods"))
		{
			if(kv.GotoFirstSubKey())
			{
				ModEnum mod;
				this.ModList = new ArrayList(sizeof(ModEnum));

				do
				{
					mod.SetupEnum(kv);
					this.ModList.PushArray(mod);
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

	int FindModByName(const char[] name, ModEnum mod)
	{
		int length = this.ModList.Length;
		for(int i; i < length; i++)
		{
			this.ModList.GetArray(i, mod);
			if(StrEqual(name, mod.Name, false))
				return i;
		}
		return -1;
	}

	float GetDropChance(int level, int luck, int tier, char name[48], float chance = 1.0, int required = 0)
	{
		if(!name[0] || level < this.Level)
		{
			if(level != 0)
				return 0.0;
		}
		if(required > tier)
			return 0.0;
		
		if(StrEqual(name, ITEM_XP, false))
		{
			if(level > this.MaxLevel || !this.XP)
			{
				if(level != 0)
					return 0.0;
			}
			
			Format(name, sizeof(name), "%d XP", this.XP * (10 + tier) / 10);
			return 1.0;
		}
		
		if(StrEqual(name, ITEM_CASH, false))
		{
			Format(name, sizeof(name), "%d Credits", this.Cash * (10 + tier) / 10);
			return 1.0;
		}
		float multi = (1.0 + (float(tier - required) * 0.1)) * chance * (float(300 + luck) / 300.0);
		if(multi > 1.0)
			multi = 1.0;
		
		return multi;
	}

	void RollItemDrop(int[] clients, int amount, int luck, int tier, char name[48], float chance, int droptier)
	{
		//say level as atleast one.
		if(name[0] && this.GetDropChance(0, luck, tier, name, chance, droptier) > GetURandomFloat())
		{
			for(int i; i < amount; i++)
			{
				if(Level[clients[i]] >= this.Level)
				{
					TextStore_AddItemCount(clients[i], name, 1,_, true);
				}
			}
		}
	}

	void DoAllDrops(int[] clients, int amount, int tier)
	{
		int luck;

		for(int i; i < amount; i++)
		{
			if(Level[clients[i]] < this.Level)
				continue;
			
			luck += Stats_Luck(clients[i]);

			TextStore_AddItemCount(clients[i], ITEM_CASH, this.Cash * (10 + tier) / 10);

			if(Level[clients[i]] <= this.MaxLevel)
				TextStore_AddItemCount(clients[i], ITEM_XP, this.XP * (10 + tier) / 10,_, 2);
		}

		luck = (luck * 2) / amount;

		this.RollItemDrop(clients, amount, luck, tier, this.DropName1, this.DropChance1, this.DropTier1);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName2, this.DropChance2, this.DropTier2);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName3, this.DropChance3, this.DropTier3);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName4, this.DropChance4, this.DropTier4);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName5, this.DropChance5, this.DropTier5);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName6, this.DropChance6, this.DropTier6);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName7, this.DropChance7, this.DropTier7);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName8, this.DropChance8, this.DropTier8);
		this.RollItemDrop(clients, amount, luck, tier, this.DropName9, this.DropChance9, this.DropTier9);
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
					if(stage.ModList.GetArray(this.ModList.Get(i), mod))
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

static Handle SyncHud;
static Handle DungeonTimer;
static StringMap DungeonList;
static char DungeonMenu[MAXPLAYERS][64];
static int AltMenu[MAXPLAYERS];
char InDungeon[MAXENTITIES][64];
static int LastResult[MAXENTITIES];

void Dungeon_PluginStart()
{
	SyncHud = CreateHudSynchronizer();
}

void Dungeon_ConfigSetup()
{
	PrecacheSound("misc/your_team_won.mp3");
	PrecacheSound("misc/your_team_lost.mp3");

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "dungeon");
	KeyValues kv = new KeyValues("Dungeon");
	kv.SetEscapeSequences(true);
	kv.ImportFromFile(buffer);

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

	delete kv;
}

void Dungeon_DeleteChar(const char[] id)
{
	KeyValues kv = Saves_Kv("dungeon");
	
	if(kv.GotoFirstSubKey())
	{
		do
		{
			if(kv.GotoFirstSubKey())
			{
				do
				{
					kv.DeleteKey(id);
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}
		}
		while(kv.GotoNextKey());
	}
}

int Dungeon_GetClientRank(int client, const char[] name, const char[] stage)
{
	int rank = -1;

	KeyValues kv = Saves_Kv("dungeon");
	if(kv.JumpToKey(name) && kv.JumpToKey(stage))
	{
		static char id[64];
		if(Saves_ClientCharId(client, id, sizeof(id)))
			rank = kv.GetNum(id, -1);
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
				menu.SetTitle("RPG Fortress\n \nChaos Surgence:\n%s △%d\nTime Elapsed: %d:%02d\n ", dungeon.CurrentStage, dungeon.TierLevel(null), time / 60, time % 60);

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

				dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage));

				ArrayList slots = new ArrayList();
				int tier = dungeon.TierLevel(slots);
				if(tier < stage.MinRisk)
				{
					menu.SetTitle("RPG Fortress\n \nChaos Surgence:\n%s △%d\nRequires △%d to Start\n ", dungeon.CurrentStage, tier, stage.MinRisk);
				}
				else
				{
					menu.SetTitle("RPG Fortress\n \nChaos Surgence:\n%s △%d\nStarts In: %d:%02d\n ", dungeon.CurrentStage, tier, time / 60, time % 60);
				}

				if(AltMenu[client] ==  2)
				{
					int level = Level[client];
					int luck;
					for(int target = 1; target <= MaxClients; target++)
					{
						if(StrEqual(InDungeon[target], DungeonMenu[client]))
							luck += Stats_Luck(target);
					}
					
					stage.DropChance1 = stage.GetDropChance(level, luck, tier, stage.DropName1, stage.DropChance1, stage.DropTier1);
					if(stage.DropChance1)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName1, RoundToFloor(stage.DropChance1 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance2 = stage.GetDropChance(level, luck, tier, stage.DropName2, stage.DropChance2, stage.DropTier2);
					if(stage.DropChance2)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName2, RoundToFloor(stage.DropChance2 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance3 = stage.GetDropChance(level, luck, tier, stage.DropName3, stage.DropChance3, stage.DropTier3);
					if(stage.DropChance3)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName3, RoundToFloor(stage.DropChance3 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance4 = stage.GetDropChance(level, luck, tier, stage.DropName4, stage.DropChance4, stage.DropTier4);
					if(stage.DropChance4)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName4, RoundToFloor(stage.DropChance4 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance5 = stage.GetDropChance(level, luck, tier, stage.DropName5, stage.DropChance5, stage.DropTier5);
					if(stage.DropChance5)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName5, RoundToFloor(stage.DropChance5 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance6 = stage.GetDropChance(level, luck, tier, stage.DropName6, stage.DropChance6, stage.DropTier6);
					if(stage.DropChance6)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName6, RoundToFloor(stage.DropChance6 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance7 = stage.GetDropChance(level, luck, tier, stage.DropName7, stage.DropChance7, stage.DropTier7);
					if(stage.DropChance7)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName7, RoundToFloor(stage.DropChance7 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance8 = stage.GetDropChance(level, luck, tier, stage.DropName8, stage.DropChance8, stage.DropTier8);
					if(stage.DropChance8)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName8, RoundToFloor(stage.DropChance8 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					stage.DropChance9 = stage.GetDropChance(level, luck, tier, stage.DropName9, stage.DropChance9, stage.DropTier9);
					if(stage.DropChance9)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - %d％", stage.DropName9, RoundToFloor(stage.DropChance9 * 100.0));
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					strcopy(stage.DropName9, sizeof(stage.DropName9), ITEM_XP);
					stage.DropChance9 = stage.GetDropChance(level, luck, tier, stage.DropName9);
					if(stage.DropChance9)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - 100％", stage.DropName9);
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
					
					strcopy(stage.DropName9, sizeof(stage.DropName9), ITEM_CASH);
					stage.DropChance9 = stage.GetDropChance(level, luck, tier, stage.DropName9);
					if(stage.DropChance9)
					{
						Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "%s - 100％", stage.DropName9);
						menu.AddItem(NULL_STRING, dungeon.CurrentStage, ITEMDRAW_DISABLED);
					}
				}
				else if(AltMenu[client] == 1 || !stage.ModList)
				{
					AltMenu[client] = 1;

					bool found;
					for(int target = 1; target <= MaxClients; target++)
					{
						if(client == target && client == leader)
						{
							if(StrEqual(InDungeon[client], DungeonMenu[client]))
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
						if(StageSlotsLeft(DungeonMenu[client], stage) < Party_Count(client))
						{
							menu.InsertItem(0, NULL_STRING, "Dungeon Is Full\n ", ITEMDRAW_DISABLED);
						}
						else if(client == leader)
						{
							Format(dungeon.CurrentStage, sizeof(dungeon.CurrentStage), "Enter Queue (Level %d)\n ", stage.Level);
							menu.InsertItem(0, NULL_STRING, dungeon.CurrentStage, stage.Level > LowestLevel(client) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
						}
						else
						{
							menu.InsertItem(0, NULL_STRING, "Party Leader Must Enter Queue\n ", ITEMDRAW_DISABLED);
						}
					}
				}
				else
				{
					int rank = Dungeon_GetClientRank(client, DungeonMenu[client], dungeon.CurrentStage);
					int length = stage.ModList.Length;
					for(int i; i < length; i++)
					{
						static ModEnum mod;
						stage.ModList.GetArray(i, mod);
						if(dungeon.ModList.FindValue(i) != -1)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[X] %s △%d\n%s\n ", mod.Name, mod.Tier, mod.Desc);
						}
						else if(rank < mod.Unlock)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[!] %s △%d\nComplete with atleast △%d to unlock\n ", mod.Name, mod.Tier, mod.Unlock);
							menu.AddItem(NULL_STRING, mod.Desc, ITEMDRAW_DISABLED);
							continue;
						}
						else if(mod.Slot && slots.FindValue(mod.Slot) != -1)
						{
							Format(mod.Desc, sizeof(mod.Desc), "[!] %s △%d\nConflicts with other modifiers\n ", mod.Name, mod.Tier);
							menu.AddItem(NULL_STRING, mod.Desc, ITEMDRAW_DISABLED);
							continue;
						}
						else
						{
							Format(mod.Desc, sizeof(mod.Desc), "[ ] %s △%d\n%s\n ", mod.Name, mod.Tier, mod.Desc);
						}

						menu.AddItem(mod.Name, mod.Desc, client == dungeon.CurrentHost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
					}

					menu.Pagination = 3;
				}

				menu.ExitBackButton = true;
				delete slots;
			}
		}
		else
		{
			if(client == leader)
			{
				menu.SetTitle("RPG Fortress\n \nChaos Surgence:");
			}
			else
			{
				menu.SetTitle("RPG Fortress\n \nChaos Surgence:\nYour Party Leader is %N", leader);
			}

			SortedSnapshot snap = CreateSortedSnapshot(dungeon.StageList);

			int length = snap.Length;
			for(int i; i < length; i++)
			{
				int size = snap.KeyBufferSize(i) + 1;
				char[] name = new char[size];
				snap.GetKey(i, name, size);

				if(dungeon.StageList.GetArray(name, stage, sizeof(stage)))
				{
					if(!stage.Quest[0] || Quests_GetStatus(client, stage.Quest) == Status_Completed)
					{
						Format(stage.MusicEasy, sizeof(stage.MusicEasy), "%s (Level %d)", name, stage.Level);
						menu.AddItem(name, stage.MusicEasy, (stage.Level > LowestLevel(client) || client != leader) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
					}
				}
			}

			delete snap;
		}

		int pagination = menu.Pagination;
		if(pagination < 3)
			pagination = 999;
		
		menu.DisplayAt(client, page / pagination * pagination, MENU_TIME_FOREVER);
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
				if(++AltMenu[client] > 2)
					AltMenu[client] = 0;
				
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
						if(dungeon.CurrentHost == client && !AltMenu[client] && GetGameTime() < dungeon.StartTime)	// Add/Remove Mod
						{
							if(!dungeon.CurrentStage[0] || !dungeon.ModList)
							{
								ShowMenu(client, 0);
							}
							else
							{
								static ModEnum mod;
								int modPos = stage.FindModByName(dungeon.CurrentStage, mod);
								if(modPos != -1)
								{
									int pos = dungeon.ModList.FindValue(modPos);
									if(pos != -1)
									{
										dungeon.ModList.Erase(pos);
									}
									else
									{
										dungeon.ModList.Push(modPos);
									}
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
							if(alreadyIn || StageSlotsLeft(DungeonMenu[client], stage) >= Party_Count(client))
							{
								bool party = Party_GetPartyLeader(client) == client;
								for(int target = 1; target <= MaxClients; target++)
								{
									if(client == target || (party && Party_IsClientMember(target, client)))
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
							dungeon.ModList = new ArrayList();
						
						dungeon.CurrentHost = client;
						dungeon.StartTime = GetGameTime() + QUEUE_TIME;
						DungeonList.SetArray(DungeonMenu[client], dungeon, sizeof(dungeon));

						bool party = Party_GetPartyLeader(client) == client;
						for(int target = 1; target <= MaxClients; target++)
						{
							if(client == target || (party && Party_IsClientMember(target, client)))
							{
								Dungeon_ClientDisconnect(target, true);

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
						
						if(!DungeonTimer)
							DungeonTimer = CreateTimer(0.2, Dungeon_Timer, _, TIMER_REPEAT);
					}

					ShowMenu(client, 0);
				}
			}
		}
	}
	return 0;
}

static int StageSlotsLeft(const char[] dungeon, const StageEnum stage)
{
	int players;

	for(int client = 1; client <= MaxClients; client++)
	{
		if(StrEqual(InDungeon[client], dungeon))
			players++;
	}

	return stage.MaxPlayers - players;
}

static int LowestLevel(int client)
{
	int lowest = Level[client];

	if(Party_GetPartyLeader(client))
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(Party_IsClientMember(client, target))
			{
				int level = Level[target];
				if(level < lowest)
					lowest = level;
			}
		}
	}

	return lowest;
}

void Dungeon_ResetEntity(int entity)
{
	ClearDungeonStats(entity);
	InDungeon[entity][0] = 0;
}

bool Dungeon_IsDungeon(int client)
{
	return view_as<bool>(InDungeon[client][0]);
}

void Dungeon_ClientDisconnect(int client, bool alive = false)
{
	AltMenu[client] = 0;
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
		ClearDungeonStats(client);
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
					CancelClientMenu(client);
					mp_disable_respawn_times.ReplicateToClient(client, "1");
					f3_SpawnPosition[client] = stage.StartPos;
					ClientCommand(client, "playgamesound vo/compmode/cm_admin_round_start_%02d.mp3", rand + 1);
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
					if(stage.ModList.GetArray(dungeon.ModList.Get(i), mod))
					{
						tier += mod.Tier;

						for(int c; c < dungeon.PlayerCount; c++)
						{
							mod.CallOnPlayer(clients[c]);
							SPrintToChat(clients[c], mod.Desc);
						}

						mod.CallOnWaves(dungeon.WaveList);
					}
				}
			}
			
			for(int c; c < dungeon.PlayerCount; c++)
			{
				RPGCore_CancelMovementAbilities(clients[c]);
				TF2_RespawnPlayer(clients[c]);

				if(stage.MusicTier > tier)
				{
					if(stage.MusicEasy[0])
						Music_SetOverride(clients[c], stage.MusicEasy, stage.MusicEasyTime, view_as<bool>(stage.MusicEasyCustom), stage.MusicEasyVolume, stage.MusicEasyDesc);	
				}
				else if(stage.MusicHard[0])
				{
					Music_SetOverride(clients[c], stage.MusicHard, stage.MusicHardTime, view_as<bool>(stage.MusicHardCustom), stage.MusicHardVolume, stage.MusicHardDesc);	
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
					if(stage.ModList.GetArray(dungeon.ModList.Get(i), mod))
						tier += mod.Tier;
				}
			}

			KeyValues kv = Saves_Kv("dungeon");
			kv.JumpToKey(name, true);
			kv.JumpToKey(dungeon.CurrentStage, true);

			int amount;
			int[] clients = new int[MaxClients];
			for(int client = 1; client <= MaxClients; client++)
			{
				if(StrEqual(InDungeon[client], name))
				{
					if(dungeon.WaveList)
					{
						clients[amount++] = client;
						InDungeon[client][0] = 0;
						f3_SpawnPosition[client] = dungeon.RespawnPos;
						ClearDungeonStats(client);
						CreateTimer(8.25, Dungeon_EndMusicTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						CreateTimer(8.25, Dungeon_RespawnTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

						if(victory)
						{
							LastResult[client] = 1;
							Music_SetOverride(client, "misc/your_team_won.mp3", 999, false, 1.0);

							if(IsPlayerAlive(client))
								TF2_AddCondition(client, TFCond_HalloweenCritCandy, 8.1);

							if(Saves_ClientCharId(client, mod.Desc, sizeof(mod.Desc)))
							{
								if(tier > kv.GetNum(mod.Desc, -1))
									kv.SetNum(mod.Desc, tier);
							}
						}
						else
						{
							LastResult[client] = -1;
							Music_SetOverride(client, "misc/your_team_lost.mp3", 999, false, 1.0);
						}
					}
				}
			}
			
			if(victory)
			{
				if(amount)
					stage.DoAllDrops(clients, amount, tier);
				
				Saves_SaveClient(0);
			}

			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
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

				int alive;
				int a, entity;
				while((entity = FindEntityByNPC(a)) != -1)
				{
					if(StrEqual(InDungeon[entity], name) && GetEntProp(entity, Prop_Send, "m_iTeamNum") != 2)
						alive++;
				}

				if(alive > 9)
				{
					int over = alive - 9;
					for(int client = 1; client <= MaxClients; client++)
					{
						if(StrEqual(InDungeon[client], name))
						{
							PrintCenterText(client, "There's too many of them! You're dying!");
							
							int health = GetClientHealth(client);
							int damage = SDKCall_GetMaxHealth(client) * over / 100;
							if(health > damage)
							{
								SetEntityHealth(client, health - damage);
							}
							else
							{
								ForcePlayerSuicide(client);
							}
						}
					}
				}

				float time = GetGameTime() - dungeon.StartTime;
				size = dungeon.WaveList.Length;
				if(size)
				{
					for(int loopa; loopa < size; loopa++)
					{
						static WaveEnum wave;
						dungeon.WaveList.GetArray(loopa, wave);
						if(wave.Delay < time)
						{
							static float ang[3];
							ang[1] = wave.Angle;
							if(ang[1] < 0.0)
								ang[1] = GetURandomFloat() * 360.0;

							entity = NPC_CreateById(wave.Index, 0, wave.Pos, ang, false, wave.Data);
							if(entity != -1)
							{
								Level[entity] = wave.Level;
								XP[entity] = 0; //No xp will be given on kill.
								b_thisNpcIsABoss[entity] = wave.Boss;
								b_NpcIsInADungeon[entity] = true;
								strcopy(InDungeon[entity], sizeof(InDungeon[]), name);

								float PlayerCountScaling = float(dungeon.PlayerCount);

								switch(dungeon.PlayerCount)
								{
									case 1:
										PlayerCountScaling = 0.85;
									case 2:
										PlayerCountScaling = 1.35;
									case 3:
										PlayerCountScaling = 1.65;
									case 4:
										PlayerCountScaling = 2.1;
									case 5:
										PlayerCountScaling = 2.45;
									case 6:
										PlayerCountScaling = 2.8;
								}

								if(wave.Health)
								{
									// +20% each player
									wave.Health = RoundToCeil(float(wave.Health) * PlayerCountScaling);
									SetEntProp(entity, Prop_Data, "m_iMaxHealth", wave.Health);
									SetEntProp(entity, Prop_Data, "m_iHealth", wave.Health);
								}
								if(wave.HPRegen)
								{
									wave.HPRegen = RoundToCeil(float(wave.HPRegen) * PlayerCountScaling * 0.55);
									i_HpRegenInBattle[entity] = wave.HPRegen;
								}

								fl_Extra_MeleeArmor[entity] = wave.ExtraMeleeRes;
								fl_Extra_RangedArmor[entity] = wave.ExtraRangedRes;
								fl_Extra_Speed[entity] = wave.ExtraSpeed;
								fl_Extra_Damage[entity] = wave.ExtraDamage;

								if(wave.CustomName[0])
									strcopy(c_NpcName[entity], sizeof(c_NpcName[]), wave.CustomName);
								
								StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");

								if(dungeon.ModList)
								{
									static StageEnum stage;
									if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
									{
										size = dungeon.ModList.Length;
										for(int b; b < size; b++)
										{
											if(stage.ModList.GetArray(dungeon.ModList.Get(b), mod))
											{
												Level[entity] += mod.Level;
												mod.CallOnSpawn(entity);
											}
										}
									}
								}
								
								Apply_Text_Above_Npc(entity, wave.Rarity, ReturnEntityMaxHealth(entity));
							}

							dungeon.WaveList.Erase(loopa);
							break;
						}
					}
				}
				else if(!alive)
				{
					CleanDungeon(name, true);
				}
			}
			else if(dungeon.StartTime)
			{
				found = true;
				int time = RoundToCeil(dungeon.StartTime - GetGameTime());
				if(time > 0)
				{
					static StageEnum stage;
					if(dungeon.StageList.GetArray(dungeon.CurrentStage, stage, sizeof(stage)))
					{
						int tier = dungeon.TierLevel(null);
						if(StageSlotsLeft(name, stage) < 0)
						{
							dungeon.StartTime = GetGameTime() + QUEUE_TIME;
							DungeonList.SetArray(name, dungeon, sizeof(dungeon));
							
							for(int client = 1; client <= MaxClients; client++)
							{
								if(StrEqual(InDungeon[client], name))
								{
									SetHudTextParams(-1.0, 0.08, 0.3, 200, 69, 0, 200);
									ShowSyncHudText(client, SyncHud, "Too many people.");
								}
							}
						}
						else if(tier < stage.MinRisk)
						{
							dungeon.StartTime = GetGameTime() + QUEUE_TIME;
							DungeonList.SetArray(name, dungeon, sizeof(dungeon));

							for(int client = 1; client <= MaxClients; client++)
							{
								if(StrEqual(InDungeon[client], name))
								{
									SetHudTextParams(-1.0, 0.08, 0.3, 200, 69, 0, 200);
									ShowSyncHudText(client, SyncHud, "Waiting...\n%s △%d", dungeon.CurrentStage, tier);
								}
							}
						}
						else
						{
							if(time > 30)
							{
								if(StageSlotsLeft(name, stage) < 1)
								{
									time = stage.ModList ? 10 : 5;
									dungeon.StartTime = GetGameTime() + time;
									dungeon.LastSoundTime = -1;
								}
								else if(b_IsAloneOnServer)
								{
									time = stage.ModList ? 30 : 5;
									dungeon.StartTime = GetGameTime() + time;
									dungeon.LastSoundTime = -1;
								}
							}

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
									ShowSyncHudText(client, SyncHud, "%d:%02d\n%s △%d", time / 60, time % 60, dungeon.CurrentStage, tier);
								}
							}

							if(dungeon.LastSoundTime != time)
							{
								dungeon.LastSoundTime = time;
								DungeonList.SetArray(name, dungeon, sizeof(dungeon));
							}
						}
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

static stock int RandomStaticSeed(int seed, int rand)
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


public void Dungeon_Spawn_25HP(int entity)
{
	int health = ReturnEntityMaxHealth(entity) * 5 / 4;
	
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_50HP(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	
	health = RoundToNearest(float(health) * 1.5);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_75HP(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	
	health = RoundToNearest(float(health) * 1.75);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
}

public void Dungeon_Spawn_DmgBonus15(int entity)
{
	fl_Extra_Damage[entity] *= 1.15;
}
public void Dungeon_Spawn_DmgBonus25(int entity)
{
	fl_Extra_Damage[entity] *= 1.25;
}

public void Dungeon_Spawn_DmgBonus35(int entity)
{
	fl_Extra_Damage[entity] *= 1.35;
}

public void Dungeon_Spawn_DmgBonus40(int entity)
{
	fl_Extra_Damage[entity] *= 1.40;
}

public void Dungeon_Spawn_DmgBonus60(int entity)
{
	fl_Extra_Damage[entity] *= 1.60;
}

public void Dungeon_Spawn_DoubleHpRegen(int entity)
{
	i_HpRegenInBattle[entity] *= 2;
}

public void Dungeon_JunalEnhancedSuperGear(int entity)
{
	b_JunalSpecialGear100k[entity] = true;
}

public void Dungeon_Spawn_FlatRes(int entity)
{
	Endurance[entity] += 300;
}
public void Dungeon_Spawn_FlatResZombie(int entity)
{
	Endurance[entity] += 1000;
}
public void Dungeon_Spawn_FlatResWF1(int entity)
{
	Endurance[entity] += 3000;
}

public void Dungeon_Spawn_BuffBosses1(int entity)
{
	if(b_thisNpcIsABoss[entity])
	{
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 1.1);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.1;
		fl_Extra_Speed[entity] *= 1.1;
	}
}

public void Dungeon_Spawn_BuffBosses2(int entity)
{
	if(b_thisNpcIsABoss[entity])
	{
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 1.2);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.2;
		fl_Extra_Speed[entity] *= 1.2;
	}
}

public void Dungeon_Spawn_MegaEnslaver(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_slave_master"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_iOverlordComboAttack = 1;
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 1.5);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.2;
		fl_Extra_Speed[entity] *= 1.1;
	}
}

public void Dungeon_Spawn_GrigoriCorrupted(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_enemy_grigori"))
	{
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 1.5);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.2;
		fl_Extra_Speed[entity] *= 1.5;
	}
}

public void Dungeon_Cave_Super_Ai(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	if(StrEqual(npc_classname, "npc_auto_cave_defense"))
	{
		//CClotBody npc = view_as<CClotBody>(entity);
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 1.50);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.10;
		fl_Extra_Speed[entity] *= 1.10;
		Endurance[entity] += 650;
	}
}
public void Dungeon_JunalTheUnstoppable(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	if(StrEqual(npc_classname, "npc_original_infected"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 3.0);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 2.0;
		fl_Extra_Speed[entity] *= 1.20;
		npc.m_iOverlordComboAttack = 1;
	}
}

public void Dungeon_RepairedCombineGear(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	if(StrEqual(npc_classname, "npc_zombiefied_combine_soldier_swordsman"))
	{
		//CClotBody npc = view_as<CClotBody>(entity);
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 1.50);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.10;
		fl_Extra_Speed[entity] *= 1.10;
		Endurance[entity] += 3500;
	}
}


public void Dungeon_40_Percent_More_Cooldown(int entity)
{
	b_DungeonContracts_LongerCooldown[entity] = true;
}

public void Dungeon_30_Percent_Slower_Attackspeed(int entity)
{
	b_DungeonContracts_SlowerAttackspeed[entity] = true;
}
public void Dungeon_15_Percent_Slower_MoveSpeed(int entity)
{
	b_DungeonContracts_SlowerMovespeed[entity] = true;
}
 
public void Dungeon_Spawn_ChaosMiner(ArrayList list)
{
	static WaveEnum wave;
	if(!wave.Index)
	{
		wave.Delay = 200.0;
		wave.Index = NPC_GetByPlugin("npc_chaos_afflicted_miner");
		wave.Pos = {-5143.458984, -5173.052734, -1487.338745};
		wave.Angle = -130.0;
		wave.Boss = true;
		wave.Level = 750;
		wave.Health = 650000;
		wave.Rarity = 1;
		wave.HPRegen= 0;

		wave.ExtraMeleeRes = 1.0;
		wave.ExtraRangedRes = 1.0;
		wave.ExtraSpeed = 1.0;
		wave.ExtraDamage = 1.0;
		wave.CustomName = "??????";
	}
	list.PushArray(wave);
}

public void Dungeon_Spawn_Hurigrajao(ArrayList list)
{
	static WaveEnum wave;
	if(!wave.Index)
	{	
		wave.Delay = 140.0;
		wave.Index = NPC_GetByPlugin("npc_huirgrajo");
		wave.Pos = {-1560.944458, 8319.227539, -502.811187};
		wave.Angle = -130.0;
		wave.Boss = true;
		wave.Level = 5500;
		wave.Health = 12000000;
		wave.Rarity = 4;
		wave.HPRegen= 8000;

		wave.ExtraMeleeRes = 1.0;
		wave.ExtraRangedRes = 1.0;
		wave.ExtraSpeed = 1.0;
		wave.ExtraDamage = 4.0;
		wave.CustomName = "Julians Right Hand, Mind Altered";
	}
	list.PushArray(wave);
}
public void ClearDungeonStats(int entity)
{
	if(entity < MAXPLAYERS)
	{
		b_DungeonContracts_LongerCooldown[entity] = false;
		b_DungeonContracts_SlowerAttackspeed[entity] = false;
		b_DungeonContracts_SlowerMovespeed[entity] = false;
	}
}

stock void RPG_ChaosSurgance(int victim, int attacker, int weapon, float &damage)
{
	if(b_JunalSpecialGear100k[victim])
	{
		float DamageMaxPunish = 100000.0;
		//if they deal more then 100 or equivilant in one hit, punish
		if(IsValidEntity(weapon))
		{
			float DamagePiercing = Attributes_Get(weapon, 4005, 1.0);
			DamageMaxPunish *= DamagePiercing;
		}
		if(damage > DamageMaxPunish)
		{
			float damageOverLimit = damage - DamageMaxPunish;
			damageOverLimit *= 0.65;
			damage = damageOverLimit + DamageMaxPunish;
		}
	}
}



public void Dungeon_Spawn_HyperElite(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_elite"))
	{
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 2.5);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.2;
		fl_Extra_Speed[entity] *= 0.5;
	}
}
public void Dungeon_Spawn_MasterBlaster(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_nano_blaster"))
	{
		int health = ReturnEntityMaxHealth(entity);
		
		health = RoundToNearest(float(health) * 2.0);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.4;
		fl_Extra_Speed[entity] *= 1.2;
	}
}

public void Dungeon_MasterCamo(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 400.0);
	SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1200.0);
		
	if(IsValidEntity(npc.m_iWearable1))
	{
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 400.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1200.0);
	}
	if(IsValidEntity(npc.m_iWearable2))
	{
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 400.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1200.0);
	}
	if(IsValidEntity(npc.m_iWearable3))
	{
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 400.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1200.0);
	}
	if(IsValidEntity(npc.m_iWearable4))
	{
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 400.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1200.0);
	}
	if(IsValidEntity(npc.m_iWearable5))
	{
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 400.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1200.0);
	}
}
public void Dungeon_Spawn_SelectedOne(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_selected_few"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_iOverlordComboAttack = 1;
	}
}

public void Dungeon_Spawn_WhiteflowerLeadersStrong(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_boss") || StrEqual(npc_classname, "npc_whiteflower_outlander_leader") || StrEqual(npc_classname, "npc_whiteflower_flowering_darkness"))
	{
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 2.0);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Speed[entity] *= 1.05;
		ApplyStatusEffect(entity, entity, "Hussar's Warscream", 15.0);
	}
}

public void Dungeon_Spawn_Aggrated(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_aggrat"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_iOverlordComboAttack = 1;
		fl_Extra_Damage[entity] *= 2.0;
	}
}

public void Dungeon_Spawn_NormalEnemyBuffWF(int entity)
{
	if(!b_thisNpcIsABoss[entity])
	{
		fl_Extra_Damage[entity] *= 1.15;
		i_HpRegenInBattle[entity] *= 3;
		fl_Extra_Speed[entity] *= 1.15;
	}
}

public void Dungeon_Spawn_TempMegaBuff(int entity)
{
	ApplyStatusEffect(entity, entity, "War Cry", 5.0);
	ApplyStatusEffect(entity, entity, "Defensive Backup", 5.0);
}


public void Dungeon_Spawn_AntiIberianTank(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_tank"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_iOverlordComboAttack = 1;
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 2.0);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.2;
	}
}
public void Dungeon_Spawn_WhiteflowerPowered(int entity)
{
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_whiteflower_boss"))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		npc.m_iOverlordComboAttack = 1;
		int health = ReturnEntityMaxHealth(entity);
		health = RoundToNearest(float(health) * 1.5);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		fl_Extra_Damage[entity] *= 1.1;
		i_HpRegenInBattle[entity] = RoundToNearest(float(i_HpRegenInBattle[entity]) * 1.5);
	}
}

public void Dungeon_Spawn_SecondGiant(ArrayList list)
{
	static WaveEnum wave;
	if(!wave.Index)
	{	
		wave.Delay = 45.0;
		wave.Index = NPC_GetByPlugin("npc_whiteflower_giant_swordsman");
		wave.Pos = {-5253.514648, -10782.250976, 3264.031250};
		wave.Angle = -130.0;
		wave.Boss = true;
		wave.Level = 12000;
		wave.Health = 15000000;
		wave.Rarity = 1;
		wave.HPRegen= 30000;

		wave.ExtraMeleeRes = 1.0;
		wave.ExtraRangedRes = 1.0;
		wave.ExtraSpeed = 1.4;
		wave.ExtraDamage = 1.4;
		wave.CustomName = "Copied W.F. Giant Man";
	}
	list.PushArray(wave);
}

public void Dungeon_Spawn_SecondGiantStrong(ArrayList list)
{
	static WaveEnum wave;
	if(!wave.Index)
	{	
		wave.Delay = 45.0;
		wave.Index = NPC_GetByPlugin("npc_whiteflower_giant_swordsman");
		wave.Pos = {-5253.514648, -10782.250976, 3264.031250};
		wave.Angle = -130.0;
		wave.Boss = true;
		wave.Level = 20000;
		wave.Health = 70000000;
		wave.Rarity = 1;
		wave.HPRegen= 70000;

		wave.ExtraMeleeRes = 1.0;
		wave.ExtraRangedRes = 1.0;
		wave.ExtraSpeed = 1.5;
		wave.ExtraDamage = 3.0;
		wave.CustomName = "W.F. Giant Man";
	}
	list.PushArray(wave);
}

public void Dungeon_Expidonsa_ScaleLevel_10000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 2.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 2.0;
	i_HpRegenInBattle[entity] *= 8;
	fl_Extra_Speed[entity] *= 1.1;

	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 10k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}

public void Dungeon_Expidonsa_ScaleLevel_15000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 5.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 4.0;
	i_HpRegenInBattle[entity] *= 30;
	fl_Extra_Speed[entity] *= 1.125;
	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 15k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}

public void Dungeon_Expidonsa_ScaleLevel_20000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 8.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 6.0;
	i_HpRegenInBattle[entity] *= 50;
	fl_Extra_Speed[entity] *= 1.175;	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 20k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}
public void Dungeon_Expidonsa_ScaleLevel_25000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 10.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 8.0;
	i_HpRegenInBattle[entity] *= 80;
	fl_Extra_Speed[entity] *= 1.2;	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 25k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}

public void Dungeon_Expidonsa_ScaleLevel_30000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 13.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 10.0;
	i_HpRegenInBattle[entity] *= 120;
	fl_Extra_Speed[entity] *= 1.22;	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 30k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}
public void Dungeon_Expidonsa_ScaleLevel_35000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 15.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 12.0;
	i_HpRegenInBattle[entity] *= 250;
	fl_Extra_Speed[entity] *= 1.25;	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 35k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}
public void Dungeon_Expidonsa_ScaleLevel_40000(int entity)
{
	int health = ReturnEntityMaxHealth(entity);
	health = RoundToNearest(float(health) * 18.0);
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	SetEntProp(entity, Prop_Data, "m_iHealth", health);
	fl_Extra_Damage[entity] *= 14.0;
	i_HpRegenInBattle[entity] *= 350;
	fl_Extra_Speed[entity] *= 1.3;	
	// Strip "!"
	bool found = ReplaceStringEx(c_NpcName[entity], sizeof(c_NpcName[]), "!", "") != -1;
	
	// Add " 10k"
	StrCat(c_NpcName[entity], sizeof(c_NpcName[]), " 40k");

	// Add "!"
	if(found)
		StrCat(c_NpcName[entity], sizeof(c_NpcName[]), "!");
}
