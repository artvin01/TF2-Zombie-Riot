#pragma semicolon 1
#pragma newdecls required

enum struct Curse
{
	char Name[64];
	Function Func;

	void SetupKv(KeyValues kv)
	{
		kv.GetString(NULL_STRING, this.Name, 64);
		this.Func = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;

		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}
		
		char buffer[64];
		Format(buffer, sizeof(buffer), "%s Desc", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			LogError("\"%s\" translation does not exist", buffer);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}

		Format(buffer, sizeof(buffer), "%s Lore", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			LogError("\"%s\" translation does not exist", buffer);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}
	}
}

enum struct Artifact
{
	char Name[64];
	int ShopCost;
	int DropChance;
	bool Multi;
	bool Hidden;
	Function FuncCollect;
	Function FuncRemove;
	Function FuncAlly;
	Function FuncEnemy;
	Function FuncWeapon;
	Function FuncWaveStart;
	Function FuncStageStart;
	Function FuncIngotChanged;
	Function FuncRecoverWeapon;
	Function FuncStageEnd;
	Function FuncTakeDamage;
	Function FuncFloorChange;

	void SetupKv(KeyValues kv)
	{
		this.ShopCost = kv.GetNum("shopcost");
		this.DropChance = kv.GetNum("dropchance");
		this.Multi = view_as<bool>(kv.GetNum("multi"));
		this.Hidden = view_as<bool>(kv.GetNum("hidden"));
		
		kv.GetString("func_collect", this.Name, 64);
		this.FuncCollect = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_remove", this.Name, 64);
		this.FuncRemove = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_ally", this.Name, 64);
		this.FuncAlly = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_enemy", this.Name, 64);
		this.FuncEnemy = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_weapon", this.Name, 64);
		this.FuncWeapon = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_wavestart", this.Name, 64);
		this.FuncWaveStart = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_stagestart", this.Name, 64);
		this.FuncStageStart = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_ingotchanged", this.Name, 64);
		this.FuncIngotChanged = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_recoverweapon", this.Name, 64);
		this.FuncRecoverWeapon = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_stageend", this.Name, 64);
		this.FuncStageEnd = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_takedamage", this.Name, 64);
		this.FuncTakeDamage = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_floorchange", this.Name, 64);
		this.FuncFloorChange = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;

		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}
		
		char buffer[64];
		Format(buffer, sizeof(buffer), "%s Desc", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			LogError("\"%s\" translation does not exist", buffer);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}
	}
}

enum struct Stage
{
	char Name[64];
	char Camera[64];
	char Spawn[64];
	char Skyname[64];
	bool Hidden;
	bool Repeat;

	// >0: Rooms progressed eg. 1 is first room, 2 is second room
	// <0: Room left eg. on a 5 stage floor, -1 is before final room, -4 is first room
	int ForcePosition;

	Function FuncStart;
	char WaveSet[PLATFORM_MAX_PATH];
	char ArtifactKey[64];
	bool InverseKey;
	MusicEnum IntroMusic;

	void SetupKv(KeyValues kv, const char[] floorsky)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}

		kv.GetString("camera", this.Camera, 64);
		kv.GetString("spawn", this.Spawn, 64);
		kv.GetString("skyname", this.Skyname, 64, floorsky);
		this.Hidden = view_as<bool>(kv.GetNum("hidden"));
		this.Repeat = view_as<bool>(kv.GetNum("repeatable"));
		this.ForcePosition = kv.GetNum("forcepos");
		this.IntroMusic.SetupKv("intromusic", kv);
		
		kv.GetString("func_start", this.WaveSet, PLATFORM_MAX_PATH);
		this.FuncStart = this.WaveSet[0] ? GetFunctionByName(null, this.WaveSet) : INVALID_FUNCTION;

		kv.GetString("wave", this.WaveSet, PLATFORM_MAX_PATH);
		if(this.WaveSet[0])
		{
			char buffer[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, this.WaveSet);
			if(!FileExists(buffer))
			{
				LogError("\"%s\" wave set does not exist", this.WaveSet);
				this.WaveSet[0] = 0;
			}
		}

		kv.GetString("key", this.ArtifactKey, 64);
		this.InverseKey = view_as<bool>(kv.GetNum("keyinverse"));
	}
}

enum struct Floor
{
	char Name[64];
	char Camera[64];
	char Skyname[64];
	char ArtifactKey[64];
	int RoomCount;

	MusicEnum MusicNormal;
	MusicEnum MusicCurse;

	ArrayList Encounters;
	ArrayList Finals;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}

		this.RoomCount = kv.GetNum("rooms", 2) - 2;
		kv.GetString("camera", this.Camera, 64);
		kv.GetString("skyname", this.Skyname, 64);
		kv.GetString("key", this.ArtifactKey, 64);

		this.MusicNormal.SetupKv("normal_music", kv);
		this.MusicCurse.SetupKv("curse_music", kv);

		Stage stage;

		this.Encounters = new ArrayList(sizeof(Stage));
		if(kv.JumpToKey("Stages"))
		{
			if(kv.GotoFirstSubKey())
			{

				do
				{
					stage.SetupKv(kv, this.Skyname);
					this.Encounters.PushArray(stage);
				}
				while(kv.GotoNextKey());
				
				kv.GoBack();
			}

			kv.GoBack();
		}

		if(kv.JumpToKey("Final"))
		{
			if(kv.GotoFirstSubKey())
			{
				this.Finals = new ArrayList(sizeof(Stage));
				
				do
				{
					stage.SetupKv(kv, this.Skyname);
					this.Finals.PushArray(stage);
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}

			kv.GoBack();
		}
		else
		{
			this.Finals = null;
		}
	}
}

enum
{
	State_Setup = 0,
	State_Vote,
	State_Trans,
	State_Stage
}

enum
{
	BobChaos = 0,
	BlueParadox = 1,
	ReilaRift = 2
}

static bool InRogueMode;

static Handle VoteTimer;
static ArrayList Voting;
static float VoteEndTime;
static int VotedFor[MAXPLAYERS];
static Function VoteFunc;
static char VoteTitle[256];
static char StartingItem[64];

static ArrayList Curses;
static ArrayList Artifacts;
static ArrayList Floors;

static int GameState;
static Handle ProgressTimer;

static bool Offline = true;
static int RogueTheme;
static int CurrentFloor;
static int CurrentCount;
static int CurrentStage;
static bool CurrentType;
static ArrayList CurrentExclude;
static ArrayList CurrentCollection;
static ArrayList CurrentMissed;
static int CurrentIngots;
static int BonusLives;
static int BattleIngots;
static bool RequiredBattle;
static float BattleChaos;
static int CurrentChaos;
static int CurrentUmbral;

static int CurseOne = -1;
static int CurseTwo = -1;
static int CurseTime;
static int ExtraStageCount;
static int ForcedVoteSeed = -1;

// Rogue Items
bool b_LeaderSquad;
bool b_GatheringSquad;
bool b_ResearchSquad;
float f_ProvokedAngerCD[MAXENTITIES];

void Rogue_PluginStart()
{
	RegAdminCmd("zr_give_artifact", Rogue_DebugGive, ADMFLAG_ROOT);
	RegAdminCmd("zr_skipbattle", Rogue_DebugSkip, ADMFLAG_ROOT);
	RegAdminCmd("zr_setstage", Rogue_DebugSet, ADMFLAG_ROOT);
	
	LoadTranslations("zombieriot.phrases.rogue");
	LoadTranslations("zombieriot.phrases.rogue.paradox");
	LoadTranslations("zombieriot.phrases.rogue.rift");
}

public Action Rogue_DebugGive(int client, int args)
{
	char buffer[64];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");
	Rogue_GiveNamedArtifact(buffer);
	return Plugin_Handled;
}

public Action Rogue_DebugSkip(int client, int args)
{
	if(!InRogueMode)
		return Plugin_Continue;
	
	Rogue_SetProgressTime(1.0, true);
	return Plugin_Handled;
}

public Action Rogue_DebugSet(int client, int args)
{
	if(!InRogueMode)
		return Plugin_Continue;
	
	if(args == 2)
	{
		int index = GetCmdArgInt(1);

		Floor floor;
		Floors.GetArray(index, floor);
		CurrentFloor = index;

		GetCmdArg(2, floor.Name, sizeof(floor.Name));
		
		Stage stage;
		index = GetStageByName(floor, floor.Name, false, stage);
		if(index == -1)
		{
			index = GetStageByName(floor, floor.Name, true, stage);
			if(index == -1)
			{
				ReplyToCommand(client, "Unknown stage \"%s\"", floor.Name);
			}
			else
			{
				SetNextStage(index, true, stage);
			}
		}
		else
		{
			SetNextStage(index, false, stage);
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: zr_setstage <floor number> <stage name>");
	}
	return Plugin_Handled;
}

bool Rogue_Mode()	// If Rogue-Like is enabled
{
	return InRogueMode;
}

bool Rogue_NoDiscount()
{
	return InRogueMode && !b_ResearchSquad;
}

int Rogue_Theme()
{
	return InRogueMode ? RogueTheme : -1;
}

void Rogue_MapStart()
{
	delete Voting;
	delete Curses;
	delete Artifacts;
	delete CurrentCollection;
	RogueTheme = 0;
	InRogueMode = false;
	Zero(f_ProvokedAngerCD);
	Rogue_Paradox_MapStart();
	Rogue_ParadoxShop_Fail();
	Rogue_BlueParadox_Reset();
	Rogue_Dome_Mapstart();
}

void Rogue_SetupVote(KeyValues kv, const char[] artifactOnly = "")
{
	if(!artifactOnly[0])
	{
		PrecacheSound("misc/halloween/gotohell.wav");
		PrecacheSound("music/stingers/hl1_stinger_song28.mp3");
		PrecacheSound("ui/halloween_boss_player_becomes_it.wav");

		InRogueMode = true;
	}

	Zero(VotedFor);

	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	VoteFunc = INVALID_FUNCTION;

	Vote vote;
	kv.JumpToKey("Starting");
	kv.GotoFirstSubKey(false);
	do
	{
		kv.GetSectionName(vote.Name, sizeof(vote.Name));
		kv.GetString(NULL_STRING, vote.Config, sizeof(vote.Config));
		
		Voting.PushArray(vote);
	}
	while(kv.GotoNextKey(false));

	if(!VoteTimer)
		VoteTimer = CreateTimer(1.0, Rogue_VoteDisplayTimer, _, TIMER_REPEAT);

	if(artifactOnly[0])
	{
		kv.Rewind();
		kv.JumpToKey(artifactOnly);
	}
	else
	{
		kv.Rewind();
		kv.JumpToKey("Rogue");
	}

	RogueTheme = kv.GetNum("roguestyle");

	Floor floor;

	delete Curses;
	delete Artifacts;
	delete CurrentCollection;

	if(Floors)
	{
		Stage stage;
		int length1 = Floors.Length;
		for(int a; a < length1; a++)
		{
			Floors.GetArray(a, floor);

			if(floor.Encounters)
			{
				int length2 = floor.Encounters.Length;
				for(int b; b < length2; b++)
				{
					floor.Encounters.GetArray(b, stage);
					stage.IntroMusic.Clear();
				}
				
				delete floor.Encounters;
			}

			if(floor.Finals)
			{
				int length2 = floor.Finals.Length;
				for(int b; b < length2; b++)
				{
					floor.Finals.GetArray(b, stage);
					stage.IntroMusic.Clear();
				}

				delete floor.Finals;
			}

			floor.MusicCurse.Clear();
			floor.MusicNormal.Clear();
		}

		delete Floors;
	}

	if(!artifactOnly[0])
	{
		Curses = new ArrayList(sizeof(Curse));
		Floors = new ArrayList(sizeof(Floor));
	}

	Artifacts = new ArrayList(sizeof(Artifact));

	if(!artifactOnly[0] && kv.JumpToKey("Curses"))
	{
		if(kv.GotoFirstSubKey(false))
		{
			Curse curse;
			
			do
			{
				curse.SetupKv(kv);
				Curses.PushArray(curse);
			}
			while(kv.GotoNextKey(false));

			kv.GoBack();
		}

		kv.GoBack();
	}

	if(kv.JumpToKey("Artifacts"))
	{
		if(kv.GotoFirstSubKey())
		{
			Artifact artifact;
			
			do
			{
				artifact.SetupKv(kv);
				Artifacts.PushArray(artifact);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	if(!artifactOnly[0] && kv.JumpToKey("Floors"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				floor.SetupKv(kv);
				Floors.PushArray(floor);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	if(kv.JumpToKey("CustomSounds"))
	{
		char buffer[PLATFORM_MAX_PATH];
		if(kv.GotoFirstSubKey(false))
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				if(buffer[0])
					PrecacheSoundCustom(buffer, _, kv.GetNum(NULL_STRING, 15));
			}
			while(kv.GotoNextKey(false));

			kv.GoBack();
		}

		kv.GoBack();
	}

	MusicEnum music;
	music.SetupKv("music_setup", kv);
	if(music.Valid())
	{
		music.CopyTo(MusicSetup1);
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client); //This is actually more expensive then i thought.
				SetMusicTimer(client, GetTime() + 5);
			}
		}
	}

	if(!artifactOnly[0])
	{
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
}

void Rogue_RevoteCmd(int client)	// Waves_RevoteCmd
{
	Rogue_CallVote(client, true);
}

bool Rogue_CallVote(int client, bool force = false)	// Waves_CallVote
{
	if(Voting && (force || !VotedFor[client]))
	{
		if(VoteFunc == INVALID_FUNCTION)
		{
			Menu menu = new Menu(Rogue_CallVoteH);
			
			SetGlobalTransTarget(client);
			
			menu.SetTitle("%t\n ", "Vote for the starting item");
			
			Vote vote;
			Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
			menu.AddItem(NULL_STRING, vote.Name);

			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);

				bool locked;

				if(vote.Config[0] && !CvarRogueSpecialLogic.BoolValue)
				{
					locked = true;
					
					for(int target = 1; target <= MaxClients; target++)
					{
						if(IsClientInGame(target) && GetClientTeam(target) == 2 && Items_HasNamedItem(target, vote.Config))
						{
							locked = false;
							break;
						}
					}
				}

				Format(vote.Config, sizeof(vote.Config), "%t%s", vote.Name, locked ? " (Locked)" : "");
				menu.AddItem(vote.Name, vote.Config, locked ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
			
			menu.ExitButton = false;
			menu.Display(client, RoundToCeil(VoteEndTime - GetGameTime()));
			return true;
		}

		return CallGenericVote(client);
	}
	return false;
}

public int Rogue_CallVoteH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			if(Voting)
			{
				if(!choice || VotedFor[client] != choice)
				{
					VotedFor[client] = choice;
					if(VotedFor[client] == 0)
					{
						VotedFor[client] = -1;
					}
					else
					{
						Vote vote;
						Voting.GetArray(choice - 1, vote);
						FormatEx(vote.Config, sizeof(vote.Config), "%s Desc", vote.Name);
						CPrintToChat(client, "%t", "Artifact Info", vote.Name, vote.Config);
						Rogue_CallVote(client, true);
						return 0;
					}
				}
			}
			
			Store_Menu(client);
		}
	}
	return 0;
}

public Action Rogue_VoteDisplayTimer(Handle timer)
{
	if(!Voting)
	{
		VoteTimer = null;
		return Plugin_Stop;
	}
	
	DisplayHintVote();
	return Plugin_Continue;
}

static void DisplayHintVote()
{
	int length = Voting.Length;
	if(length > 1)
	{
		int count, total;
		int[] votes = new int[length + 1];
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				total++;

				if(VotedFor[client])
				{
					count++;

					if(VotedFor[client] > 0 && VotedFor[client] <= length)
						votes[VotedFor[client] - 1]++;
				}
			}
		}

		int top[3] = {-1, ...};
		for(int i; i < length; i++)
		{
			if(votes[i] < 1)
			{

			}
			else if(top[0] == -1 || votes[i] > votes[top[0]])
			{
				top[2] = top[1];
				top[1] = top[0];
				top[0] = i;
			}
			else if(top[1] == -1 || votes[i] > votes[top[1]])
			{
				top[2] = top[1];
				top[1] = i;
			}
			else if(top[2] == -1 || votes[i] > votes[top[2]])
			{
				top[2] = i;
			}
		}

		if(top[0] != -1)
		{
			Vote vote;
			Voting.GetArray(top[0], vote);

			SetGlobalTransTarget(LANG_SERVER);

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %t: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					Voting.GetArray(top[i], vote);

					Format(buffer, sizeof(buffer), "%s\n%d. %t: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
	else
	{
		PrintHintTextToAll("No Vote, %ds left", RoundFloat(VoteEndTime - GetGameTime()));
	}
}

void Rogue_StartSetup()	// Waves_RoundStart()
{
	Rogue_RoundEnd();
	Offline = false;

	float wait = 60.0;

	if(Voting)
	{
		wait = zr_waitingtime.FloatValue;
		float time = wait - 30.0;
		if(time < 20.0)
			time = 20.0;
		
		VoteEndTime = GetGameTime() + time;
		CreateTimer(time, Rogue_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

		if(wait < time)
			wait = time;
	}
	else if(StartingItem[0])
	{
		Rogue_GiveNamedArtifact(StartingItem);
	}

	Rogue_SetProgressTime(wait, true, true);

	if(RogueTheme == BlueParadox)
	{
		SPrintToChatAll("Resetting found Weapons.....");
		//prevents when restarting, finding 2 instantly...
		Store_RandomizeNPCStore(ZR_STORE_RESET);
		//reveal 15
		Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, 10);
		Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, 5);
	}
}

void Rogue_RoundEnd()
{
	delete ProgressTimer;
	GameState = State_Setup;
	CurrentFloor = 0;
	CurrentStage = -1;
	CurrentCount = -1;
	delete CurrentExclude;
	delete CurrentMissed;
	CurrentIngots = 0;
	CurrentChaos = 0;
	CurrentUmbral = 50;
	BonusLives = 0;
	BattleChaos = 0.0;
	Offline = true;
	Rogue_BlueParadox_Reset();

	if(CurrentCollection)
	{
		ArrayList list = CurrentCollection;
		CurrentCollection = null;

		Artifact artifact;
		int length = list.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(list.Get(i), artifact);
			if(artifact.FuncRemove != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncRemove);
				Call_Finish();
			}
		}

		delete list;
	}
	
	//StartingItem[0] = 0;
	CurseTime = 0;
	
	if(CurseOne != -1)
	{
		Curse curse;
		Curses.GetArray(CurseOne, curse);
		if(curse.Func != INVALID_FUNCTION)
		{
			Call_StartFunction(null, curse.Func);
			Call_PushCell(false);
			Call_Finish();
		}	

		CurseOne = -1;
	}
	
	if(CurseTwo != -1)
	{
		Curse curse;
		Curses.GetArray(CurseTwo, curse);
		if(curse.Func != INVALID_FUNCTION)
		{
			Call_StartFunction(null, curse.Func);
			Call_PushCell(false);
			Call_Finish();
		}

		CurseTwo = -1;
	}

	ClearStats();
}

public Action Rogue_EndVote(Handle timer, float time)
{
	if(Voting)
	{
		int length = Voting.Length;
		if(length)
		{
			DisplayHintVote();

			int[] votes = new int[length];
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(VotedFor[client] > 0 && GetClientTeam(client) == 2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}
			
			int highest;
			for(int i = 1; i < length; i++)
			{
				if(votes[i] > votes[highest])
					highest = i;
			}
			
			Vote vote;
			Voting.GetArray(highest, vote);
			delete Voting;
			
			if(VoteFunc == INVALID_FUNCTION)
			{
				Native_OnDifficultySet(highest, vote.Name, vote.Level);
				
				Rogue_GiveNamedArtifact(vote.Name);
				strcopy(StartingItem, sizeof(StartingItem), vote.Name);
				Waves_SetReadyStatus(1);
			}
			else
			{
				Call_StartFunction(null, VoteFunc);
				Call_PushArray(vote, sizeof(vote));
				Call_PushCell(highest);
				Call_Finish();
			}
		}
	}
	return Plugin_Continue;
}

public Action Rogue_RoundStartTimer(Handle timer)
{
	ProgressTimer = null;
	
	if(!Voting && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		if(CvarNoRoundStart.BoolValue)
		{
			PrintToChatAll("zr_noroundstart is enabled");
		}
		else if(Construction_Mode())
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2 && !IsFakeClient(client))
				{
					Construction_Start();
					return Plugin_Stop;
				}
			}
		}
		else if(InRogueMode)
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2 && !IsFakeClient(client))
				{
					Rogue_NextProgress();
					return Plugin_Stop;
				}
			}
		}
		else
		{
			PrintToChatAll("ERROR: Unknown custom gametype");
		}
	}

	ProgressTimer = CreateTimer(1.0, Rogue_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action Rogue_ProgressTimer(Handle timer)
{
	ProgressTimer = null;
	if(Floors)
		Rogue_NextProgress();
	
	return Plugin_Stop;
}

void Rogue_BattleVictory()
{
	ReviveAll();
	Waves_RoundEnd();
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();
	Rogue_ParadoxShop_Victory();
	Rogue_RiftShop_Victory();

	Rogue_Dome_WaveEnd();
	
	float time = 5.0;
	
	if(BattleIngots > 0)
	{
		switch(RogueTheme)
		{
			case BobChaos:
			{
				if((GetURandomInt() % 8) < BattleIngots)
				{
					Artifact artifact;
					if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
						Rogue_GiveNamedArtifact(artifact.Name);
				}
			}
			case BlueParadox:
			{
				int recover = 4;

				if(BattleIngots > 4)
				{
					recover = CurrentFloor > 1 ? 6 : 8;
				}
				else if(BattleIngots >= 1)
				{
					recover = CurrentFloor > 1 ? 4 : 6;
				}

				if(BattleIngots >= 1 && CurrentFloor >= 4)
					recover += 5;

				Rogue_TriggerFunction(Artifact::FuncRecoverWeapon, recover);

				if(recover)
				{
					Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, recover);
				}

				if(!(GetURandomInt() % (Rogue_GetChaosLevel() > 1 ? 3 : 4)))
				{
					Artifact artifact;
					if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
						Rogue_GiveNamedArtifact(artifact.Name);
				}
			}
			case ReilaRift:
			{
				Artifact artifact;

				if(CurrentFloor < 5 && CurrentCount < 4 && !Rogue_Rift_NoStones())
				{
					if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
						time = Rogue_Rift_OptionalVoteItem(artifact.Name);
				}
				
				if((GetURandomInt() % 8) < BattleIngots)
				{
					if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
						Rogue_GiveNamedArtifact(artifact.Name);
				}
			}
		}

		if(Rogue_HasFriendship())
			BattleIngots += BattleIngots > 4 ? 2 : 1;
		
		Rogue_AddIngots(BattleIngots);
	}

	if(RogueTheme == BlueParadox)
	{
		//tiny compensation
		int chaos = RoundToFloor(BattleChaos);
		chaos -= 1;
		if(chaos < 0)
			chaos = 0;

		if(chaos > 25)
			chaos = 25;
			
		if(chaos > 0)
		{
			BattleChaos -= float(chaos);
			Rogue_AddChaos(chaos);
		}
		Rogue_ParadoxDLC_Flawless(chaos);
	}

	if(CurrentType)
	{
		Rogue_SetProgressTime(time, false);
		//Rogue_NextProgress();
	}
	else
	{
		Rogue_SetProgressTime(time, true);

		Floor floor;
		Floors.GetArray(CurrentFloor, floor);

		Stage stage;
		floor.Encounters.GetArray(CurrentStage, stage);

		SetFloorMusic(floor, false);
	}
}

bool Rogue_BattleLost()
{
	Rogue_ParadoxShop_Fail();
	Rogue_RiftShop_Fail();
	bool victory = false;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);

	Rogue_Dome_WaveEnd();

	if(victory || (BonusLives > 0 && !RequiredBattle))
	{
		if(!victory)
		{
			if(BonusLives > 1)
			{
				CPrintToChatAll("{green}You lost the battle but continued the adventure, {yellow}another retry is ready.");
			}
			else
			{
				CPrintToChatAll("{green}You lost the battle but continued the adventure, {red}this is your last chance!");
			}
		}

		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 10);
			}
		}

		Waves_RoundEnd();
		Store_RogueEndFightReset();
		TeleportToSpawn();

		Rogue_SetProgressTime(5.0, false, true);
		
		/*Floor floor;
		Floors.GetArray(CurrentFloor, floor);

		Stage stage;
		if(CurrentType)
		{
			floor.Finals.GetArray(CurrentStage, stage);
		}
		else
		{
			floor.Encounters.GetArray(CurrentStage, stage);
		}*/

		int chaos = RoundToFloor(BattleChaos);
		if(chaos > 0)
		{
			BattleChaos = 0.0;
			Rogue_RemoveChaos(chaos);
		}

		if(!victory)
			BonusLives--;
		
		return false;
	}
	
	return true;	// Return true to fail the game
}

void Rogue_NextProgress()
{
	switch(GameState)
	{
		case State_Setup:
		{
			for(int client=1; client<=MaxClients; client++)
			{
				GrantCreditsBack(client);
			}
			
			Ammo_Count_Ready = 8;
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

			CPrintToChatAll("{crimson}%t", "Explain Construction 0");

			switch(RogueTheme)
			{
				case BobChaos:
				{
					CPrintToChatAll("{green}%t", "Explain Rogue1 1");
					CPrintToChatAll("{green}%t", "Explain Rogue1 2");
					CPrintToChatAll("{green}%t", "Explain Rogue1 3");
				}
				case BlueParadox:
				{
					CPrintToChatAll("{green}%t", "Explain Rogue1 1");
					CPrintToChatAll("{green}%t", "Explain Rogue1 2");
					CPrintToChatAll("{green}%t", "Explain Rogue1 3");
					CPrintToChatAll("{green}%t", "Explain Rogue2 1");
					CPrintToChatAll("{green}%t", "Explain Rogue2 2");
				}
				case ReilaRift:
				{
					CPrintToChatAll("{green}%t", "Explain Rogue1 1");
					CPrintToChatAll("{green}%t", "Explain Rogue1 2");
					CPrintToChatAll("{green}%t", "Explain Rogue1 3");
				}
			}
			
			CurrentFloor = 0;
			CurrentCount = -1;
			delete CurrentExclude;

			int startingIngots = highestLevel + 8;

			Rogue_AddIngots(startingIngots, true);

			Floor floor;
			Floors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			int id = GetRandomStage(floor, stage, 1, _, 1, 99);
			if(id == -1)
			{
				PrintToChatAll("NO BATTLES ON FIRST FLOOR? BAD CFG, REPORT BUG");
			}
			else
			{
				SetNextStage(id, false, stage, 10.0);
			}

			SetHudTextParamsEx(-1.0, -1.0, 8.0, {255, 255, 255, 255}, {255, 200, 155, 255}, 2, 0.1, 0.1);
			for(int client = 1; client <= MaxClients; client++)
			{
				if(!b_IsPlayerABot[client] && IsClientInGame(client))
				{
					SetGlobalTransTarget(client);
					ShowHudText(client, -1, "%t", floor.Name);
				}
			}

			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "%s Lore", floor.Name);
			if(TranslationPhraseExists(buffer))
				PrintToChatAll("%t", buffer);
		}
		case State_Trans:
		{
			Floor floor;
			Floors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			if(CurrentType)
			{
				floor.Finals.GetArray(CurrentStage, stage);
			}
			else
			{
				floor.Encounters.GetArray(CurrentStage, stage);
			}

			StartStage(stage);
		}
		case State_Stage:
		{
			Floor floor;
			Floors.GetArray(CurrentFloor, floor);

			Stage stage;

			if(CurrentStage != -1)
			{
				if(CurrentType)
				{
					floor.Finals.GetArray(CurrentStage, stage);
				}
				else
				{
					floor.Encounters.GetArray(CurrentStage, stage);
				}
			}

			int maxRooms = floor.RoomCount + ExtraStageCount;

			bool removeCurse;
			switch(RogueTheme)
			{
				case ReilaRift:
					removeCurse = (--CurseTime) < 1;

				default:
					removeCurse = CurrentCount > maxRooms;
			}
			
			if(removeCurse)
			{
				if(CurseOne != -1)
				{
					Curse curse;
					Curses.GetArray(CurseOne, curse);
					if(curse.Func != INVALID_FUNCTION)
					{
						Call_StartFunction(null, curse.Func);
						Call_PushCell(false);
						Call_Finish();
					}

					CurseOne = -1;
					
					if(RogueTheme == ReilaRift)
						CPrintToChatAll("%t", "Curse Rift Closed", curse.Name);
				}
				
				if(CurseTwo != -1)
				{
					Curse curse;
					Curses.GetArray(CurseTwo, curse);
					if(curse.Func != INVALID_FUNCTION)
					{
						Call_StartFunction(null, curse.Func);
						Call_PushCell(false);
						Call_Finish();
					}

					CurseTwo = -1;
				}
			}

			if(RogueTheme == ReilaRift && CurseTime < 0 && CurseOne == -1)	// Reila Rogue starts curses anytime
			{
				int diff = Rogue_Rift_CurseLevel();
				int rank = Rogue_GetUmbralLevel() + (diff - 1);
				if(diff > 0 && rank > 0 && (GetURandomInt() % (15 - (rank * 3))) < (-CurseTime))
				{
					int length = Curses.Length;
					if(length)
					{
						CurseTime = 4;
						CurseOne = GetURandomInt() % length;
						
						Curse curse;
						Curses.GetArray(CurseOne, curse);
						if(curse.Func != INVALID_FUNCTION)
						{
							Call_StartFunction(null, curse.Func);
							Call_PushCell(true);
							Call_PushCellRef(CurseTime);
							Call_Finish();
						}

						char buffer[64];
						FormatEx(buffer, sizeof(buffer), "%s Desc", curse.Name);
						CPrintToChatAll("{red}%t{default}: %t", curse.Name, buffer);

						FormatEx(buffer, sizeof(buffer), "%s Lore", curse.Name);
						CPrintToChatAll("%t", buffer);

						EmitSoundToAll("ui/halloween_boss_player_becomes_it.wav");
					}
				}
			}
			
			if(CurrentCount > maxRooms)	// Go to next floor
			{
				CurrentFloor++;
				CurrentStage = -1;
				CurrentCount = -1;
				ExtraStageCount = 0;
				
				bool victory = CurrentFloor >= Floors.Length;
				if(!victory)
				{
					Native_OnSpecialModeProgress(CurrentFloor, Floors.Length);
					Floors.GetArray(CurrentFloor, floor);
					if(floor.ArtifactKey[0] && !Rogue_HasNamedArtifact(floor.ArtifactKey))
					{
						if(CurrentFloor == (Floors.Length - 1))
						{
							victory = true;
						}
						else
						{
							// Check next floor
							CurrentCount = maxRooms + 1;
							Rogue_NextProgress();
							return;
						}
					}
				}

				SteamWorks_UpdateGameTitle();
				Rogue_BlueParadox_NewFloor(CurrentFloor);

				if(victory)	// All the floors are done
				{
					ForcePlayerWin();
				}
				else
				{
					Rogue_SendToFloor(CurrentFloor, CurrentCount);
				}
			}
			else if(CurrentCount == maxRooms)	// Final Stage
			{
				int id = GetRandomStage(floor, stage, 2, ForcedVoteSeed, CurrentCount + 2, maxRooms + 2);
				ForcedVoteSeed = -1;

				if(id == -1)
				{
					// We somehow don't have a final stage
					CurrentCount = maxRooms + 1;
					Rogue_NextProgress();
				}
				else
				{
					TeleportToSpawn();
					
					SetFloorMusic(floor, true);
					SetNextStage(id, true, stage, 20.0);
				}
			}
			else	// Normal Stage
			{
				Rogue_CreateGenericVote(Rogue_Vote_NextStage, "Vote for the next stage");

				int count = RogueTheme == BlueParadox ? 3 : 2;
				if(!(GetURandomInt() % 6))
					count++;
				
				bool bonus = (RogueTheme == ReilaRift && !(GetURandomInt() % 20));
				if(bonus)
					count++;
				
				if(ExtraStageCount > 0)
				{
					if(GetURandomInt() % 2)
						count++;
				}
				else if(ExtraStageCount < 0)
				{
					count = 1;
				}
				
				Vote vote;
				for(int i; i < count; i++)
				{
					int id = GetRandomStage(floor, stage, 0, ForcedVoteSeed, CurrentCount + 2, maxRooms + 2);
					if(id != -1)
					{
						ForcedVoteSeed = -1;
						
						strcopy(vote.Config, sizeof(vote.Config), stage.Name);
						vote.Level = GetURandomInt();

						if(Rogue_Curse_HideNames() || Rogue_GetChaosLevel() > 2)
						{
							strcopy(vote.Name, sizeof(vote.Name), "Dense Fog");
						}
						else if(stage.Hidden)
						{
							strcopy(vote.Name, sizeof(vote.Name), "Encounter");
						}
						else
						{
							strcopy(vote.Name, sizeof(vote.Name), stage.Name);
						}

						if(i == ((Rogue_GetChaosLevel() == 4) ? 1 : 0))
							SetAllCamera(stage.Camera, stage.Skyname);
						
						// Show the next stage if possible
						if(CurrentFloor < 5 && RogueTheme == ReilaRift)
						{
							int future = id;
							vote.Level = GetURandomInt();

							if(i == (count-1) && bonus && stage.ForcePosition == 0)
							{
								// Random bonus stage
								vote.Level = -2;
								strcopy(vote.Append, sizeof(vote.Append), "  (Ω)");
							}
							else
							{
								PrintToChatAll("DEBUG: CurrentCount %d / maxRooms %d", CurrentCount, maxRooms);
								if((CurrentCount-1) == maxRooms)
								{
									future = GetRandomStage(floor, stage, 2, vote.Level, CurrentCount + 3, maxRooms + 2);
								}
								else
								{
									future = GetRandomStage(floor, stage, 0, vote.Level, CurrentCount + 3, maxRooms + 2);
								}

								if(future == id || future == -1)
								{
									strcopy(vote.Append, sizeof(vote.Append), "  (→ ???)");
								}
								else
								{
									if(stage.Hidden)
									{
										strcopy(vote.Append, sizeof(vote.Append), "  (→ Encounter)");
									}
									else
									{
										Format(vote.Append, sizeof(vote.Append), "  (→ %T)", stage.Name, LANG_SERVER);
									}
								}
							}
						}

						Voting.PushArray(vote);
					}
				}

				if(Voting.Length)
				{
					SetFloorMusic(floor, true);

					Rogue_StartGenericVote(15.0);
					GameState = State_Vote;

					TeleportToSpawn();

					//MusicString2.Clear();
					//RaidMusicSpecial1.Clear();
				}
				else	// We somehow ran out of normal rooms
				{
					delete Voting;
					CurrentCount = maxRooms;
					Rogue_NextProgress();
				}
			}
		}
		default:
		{
			PrintToChatAll("INVALID GAME STATE %d, REPORT BUG", GameState);
			GameState = State_Stage;
			Rogue_NextProgress();
		}
	}

	Waves_UpdateMvMStats();
}

void Rogue_SendToFloor(int floorIndex, int stageIndex = -1, bool cutscene = true)
{
	CurrentFloor = floorIndex;
	CurrentCount = stageIndex;

	if(!cutscene)
		return;

	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncFloorChange != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncFloorChange);
				Call_PushCellRef(CurrentFloor);
				Call_PushCellRef(CurrentCount);
				Call_Finish();
			}
		}
	}

	Floor floor;
	Floors.GetArray(CurrentFloor, floor);

	TeleportToSpawn();

	SetAllCamera(floor.Camera, floor.Skyname);

	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), floor.Name);
	strcopy(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), floor.Name);
	WavesUpdateDifficultyName();

	char buffer[64];

	bool cursed;
	if(RogueTheme != ReilaRift)	// Reila Rogue
	{
		if(!(GetURandomInt() % 5) || Rogue_Paradox_SpecialForceCurse(CurrentFloor))
		{
			int length = Curses.Length;
			if(length)
			{
				cursed = true;

				if(Rogue_Paradox_SpecialForceCurse(CurrentFloor))
				{
					CurseOne = length - 1;
				}
				else
				{
					CurseOne = GetURandomInt() % length;
				}
				
				if(length > 1 && !(GetURandomInt() % 4))
				{
					CurseTwo = GetURandomInt() % (length - 1);
					if(CurseTwo >= CurseOne)
						CurseTwo++;
				}
				
				Curse curse;
				Curses.GetArray(CurseOne, curse);
				if(curse.Func != INVALID_FUNCTION)
				{
					Call_StartFunction(null, curse.Func);
					Call_PushCell(true);
					Call_Finish();
				}

				FormatEx(buffer, sizeof(buffer), "%s Desc", curse.Name);
				CPrintToChatAll("{red}%t{default}: %t", curse.Name, buffer);

				FormatEx(buffer, sizeof(buffer), "%s Lore", curse.Name);
				CPrintToChatAll("%t", buffer);

				if(CurseTwo != -1)
				{
					Curses.GetArray(CurseTwo, curse);
					if(curse.Func != INVALID_FUNCTION)
					{
						Call_StartFunction(null, curse.Func);
						Call_PushCell(true);
						Call_Finish();
					}

					FormatEx(buffer, sizeof(buffer), "%s Desc", curse.Name);
					CPrintToChatAll("{red}%t{default}: %t", curse.Name, buffer);

					FormatEx(buffer, sizeof(buffer), "%s Lore", curse.Name);
					CPrintToChatAll("%t", buffer);
				}
			}
		}
	}

	if(RogueTheme == BlueParadox)
		Rogue_Paradox_OnNewFloor(CurrentFloor);

	SetHudTextParamsEx(-1.0, -1.0, 8.0, {255, 255, 255, 255}, {255, 200, 155, 255}, 2, 0.1, 0.1);
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			ShowHudText(client, -1, "%t", floor.Name);
			Music_Stop_All(client);
			SetMusicTimer(client, GetTime() + (cursed ? 0 : 7));
		}
	}

	FormatEx(buffer, sizeof(buffer), "%s Lore", floor.Name);
	if(TranslationPhraseExists(buffer))
		PrintToChatAll("%t", buffer);

	Rogue_SetProgressTime(7.0, false);

	if(cursed)
	{
		RemoveAllCustomMusic();
		MusicString1.Time = 9;

		if(RogueTheme == BlueParadox)
		{
			strcopy(MusicString1.Path, sizeof(MusicString1.Path), "music/stingers/hl1_stinger_song28.mp3");
		}
		else
		{
			strcopy(MusicString1.Path, sizeof(MusicString1.Path), "misc/halloween/gotohell.wav");
		}
	}
	else
	{
		SetFloorMusic(floor, false);
	}
}

bool Rogue_ShowStatus(int client)
{
	if(Rogue_Mode())
	{
		switch(GameState)
		{
			case State_Trans, State_Vote:
			{
				static Floor floor;
				Floors.GetArray(CurrentFloor, floor);

				SetHudTextParams(0.15, 0.05, 0.81, 255, 255, 255, 255);
				int DisplayDo = CurrentCount + (GameState == State_Vote ? 2 : 1);
				if(DisplayDo <= 1)
					DisplayDo = 1;
				
				ShowSyncHudText(client, SyncHud_WandMana, "%T", "Rogue Stage Status",client, floor.Name, DisplayDo, (floor.RoomCount + ExtraStageCount) + 2);
				return true;
			}
		}
	}

	return false;
}

static void SetFloorMusic(const Floor floor, bool stop)
{
	if(Rogue_HasNamedArtifact("Torn Keycard"))
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 199);
			}
		}
		return;
	}

	bool curse = CurseOne != -1 || CurseTwo != -1;
	if(RaidMusicSpecial1.Valid() || !StrEqual(MusicString1.Path, curse ? floor.MusicCurse.Path : floor.MusicNormal.Path))
	{
		if(stop)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					Music_Stop_All(client);
					SetMusicTimer(client, GetTime() + 1);
				}
			}
		}

		RemoveAllCustomMusic();

		if(curse)
		{
			floor.MusicCurse.CopyTo(MusicString1);
		}
		else
		{
			floor.MusicNormal.CopyTo(MusicString1);
		}
	}
}

ArrayList Rogue_CreateGenericVote(Function func, const char[] title)
{
	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	VoteFunc = func;
	strcopy(VoteTitle, sizeof(VoteTitle), title);

	return Voting;
}

void Rogue_StartGenericVote(float time = 20.0)
{
	Zero(VotedFor);
	if(!VoteTimer)
		VoteTimer = CreateTimer(1.0, Rogue_VoteDisplayTimer, _, TIMER_REPEAT);

	VoteEndTime = GetGameTime() + time;
	CreateTimer(time, Rogue_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

	Rogue_SetProgressTime(time + 5.0, false);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && GetClientMenu(client) == MenuSource_None)
			Rogue_CallVote(client);
	}
}

static bool CallGenericVote(int client)
{
	if(TeutonType[client] == TEUTON_WAITING)
		return false;
	
	Menu menu = new Menu(Rogue_CallGenericVoteH);
	
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n ", VoteTitle);
	
	Vote vote;
	Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
	menu.AddItem(NULL_STRING, vote.Name);

	int length = Voting.Length;
	for(int i; i < length; i++)
	{
		Voting.GetArray(i, vote);
		Format(vote.Name, sizeof(vote.Name), "%t%s", vote.Name, vote.Append);
		menu.AddItem(vote.Config, vote.Name, vote.Locked ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(length < 9)
		menu.Pagination = 0;
	
	menu.ExitButton = false;
	menu.Display(client, RoundToCeil(VoteEndTime - GetGameTime()));
	return true;
}

public int Rogue_CallGenericVoteH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			if(Voting)
			{
				if(!choice || VotedFor[client] != choice)
				{
					VotedFor[client] = choice;
					if(VotedFor[client] == 0 || choice > Voting.Length)
					{
						VotedFor[client] = -1;
					}
					else
					{
						Vote vote;
						Voting.GetArray(choice - 1, vote);
						if(VoteFunc == Rogue_Vote_NextStage)
						{
							if(Rogue_GetChaosLevel() != 4)
							{
								Floor floor;
								Floors.GetArray(CurrentFloor, floor);
								
								Stage stage;
								GetStageByName(floor, vote.Config, false, stage);

								SetClientCamera(client, stage.Camera, stage.Skyname);
							}

							Rogue_CallVote(client, true);
							return 0;
						}
						else if(StrEqual(vote.Desc, "Artifact Config Info"))
						{
							FormatEx(vote.Name, sizeof(vote.Name), "%s Desc", vote.Config);
							CPrintToChat(client, "%t", "Artifact Info", vote.Config, vote.Name);

							Rogue_CallVote(client, true);
							return 0;
						}
						else if(StrEqual(vote.Desc, "Artifact Info"))
						{
							SplitString(vote.Name, " △", vote.Name, sizeof(vote.Name));
							FormatEx(vote.Config, sizeof(vote.Config), "%s Desc", vote.Name);
							CPrintToChat(client, "%t", "Artifact Info", vote.Name, vote.Config);

							Rogue_CallVote(client, true);
							return 0;
						}
						else
						{
							CPrintToChat(client, "%t", vote.Desc);
							Rogue_CallVote(client, true);
							return 0;
						}
					}
				}
			}
			
			Store_Menu(client);
		}
	}
	return 0;
}

static void SetNextStage(int id, bool type, const Stage stage, float time = 5.0)
{
	CurrentCount++;
	CurrentStage = id;
	CurrentType = type;

	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), stage.Name);
	strcopy(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), stage.Name);
	WavesUpdateDifficultyName();
	if(stage.WaveSet[0])	// If a battle, give map over view for 5 seconds
	{
		GameState = State_Trans;
		SetAllCamera(stage.Camera, stage.Skyname);
		Rogue_SetProgressTime(time, true);
	}
	else
	{
		StartStage(stage);
	}

	Waves_UpdateMvMStats();
}

void Rogue_StartThisBattle(float time = 10.0)
{
	delete ProgressTimer;

	Floor floor;
	Floors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	if(CurrentType)
	{
		floor.Finals.GetArray(CurrentStage, stage);
	}
	else
	{
		floor.Encounters.GetArray(CurrentStage, stage);
	}

	StartBattle(stage, time);
}

static void StartBattle(const Stage stage, float time = 3.0)
{
	Rogue_TriggerFunction(Artifact::FuncStageStart);
	if(!stage.IntroMusic.Path[0])
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 3);
			}
		}
	}

	RemoveAllCustomMusic();

	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, stage.WaveSet);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(buffer);
	Waves_SetupWaves(kv, false);
	delete kv;

	CreateTimer(time, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);

	Rogue_Curse_BattleStart();
	WaveStart_SubWaveStart(GetGameTime());
}

static void StartStage(const Stage stage)
{
	GameState = State_Stage;
	BattleIngots = CurrentFloor > 1 ? 4 : 3;
	RequiredBattle = false;
	SetAllCamera();

	if(stage.IntroMusic.Path[0])
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + stage.IntroMusic.Time);
				if(stage.IntroMusic.Custom)
				{
					EmitCustomToClient(client, stage.IntroMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, stage.IntroMusic.Volume);
				}
				else
				{
					EmitSoundToClient(client, stage.IntroMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					EmitSoundToClient(client, stage.IntroMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				}
			}
		}

		RemoveAllCustomMusic();
	}

	float time = stage.WaveSet[0] ? 0.0 : 5.0;
	if(stage.FuncStart != INVALID_FUNCTION)
	{
		Call_StartFunction(null, stage.FuncStart);
		Call_Finish(time);
	}

	if(!time && stage.WaveSet[0])
	{
		StartBattle(stage);
	}
	else
	{
		Rogue_SetProgressTime(time, false);
	}

	GogglesFollower_StartStage(stage.Name);
	Waves_SetSkyName(stage.Skyname);

	float pos[3], ang[3];

	char buffer[64];
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "info_teleport_destination")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, stage.Spawn, false))
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
				if(StrEqual(buffer, stage.Spawn, false))
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
				SmiteNpcToDeath(entity);
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			DeleteAndRefundBuilding(builder_owner, entity);
		}
	}

	switch(RogueTheme)
	{
		case BlueParadox:
		{
			if(CurrentFloor != 2)
				Rogue_Dome_WaveStart(pos);
		}
		case ReilaRift:
		{
			Rogue_Dome_WaveStart(pos);
		}
	}

	if(b_LeaderSquad)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				SpawnHealth(client);
				break;
			}
		}
	}

	if(b_GatheringSquad)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				SpawnMaxAmmo(client);
				break;
			}
		}
	}

	if(Rogue_Curse_HideNames())
		Rogue_AddIngots(1);
}

static void TeleportToSpawn()
{
	Rogue_Dome_WaveEnd();
	
	float pos[3], ang[3];

	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]))
		{
			if(GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == 2)
			{
				GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
				break;
			}
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			if(TeutonType[client] == TEUTON_DEAD)
				TF2_RespawnPlayer(client);
			
			Vehicle_Exit(client, false, false);
			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
	}
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red && i_NpcInternalId[entity] != Remain_ID())
			{
				TeleportEntity(entity, pos, ang, NULL_VECTOR);
			}
			else
			{
				SmiteNpcToDeath(entity);
			}
		}
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			DeleteAndRefundBuilding(builder_owner, entity);
		}
	}
}

static int GetStageByName(const Floor floor, const char[] name, bool final, Stage stage)
{
	ArrayList list = final ? floor.Finals : floor.Encounters;
	if(!list)
		list = floor.Encounters;
	
	int length = list.Length;
	for(int i; i < length; i++)
	{
		list.GetArray(i, stage);
		if(StrEqual(name, stage.Name, false))
			return i;
	}

	return -1;
}

static int GetRandomStage(const Floor floor, Stage stage, int type, int seed = -1, int pos = 0, int maxstages = 0)
{
	ArrayList list = type == 2 ? floor.Finals : floor.Encounters;
	if(!list)
		list = floor.Encounters;
	
	int length = list.Length;

	int rand = seed == -1 ? GetURandomInt() : seed;

	int start = rand % length;
	int i = start;
	
	if(type == 2)
	{
		int choosen = -1;

		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);
			if(stage.ArtifactKey[0])
			{
				if(Rogue_HasNamedArtifact(stage.ArtifactKey) != stage.InverseKey)
					return i;
			}
			else if(choosen == -1)
			{
				choosen = i;
			}

			i++;
		}
		while(i != start);

		if(choosen != -1)
			list.GetArray(choosen, stage);
		
		return choosen;
	}
	else
	{
		// Search for "forcepos" key
		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);

			if(stage.ForcePosition != 0)
			{
				if(stage.ForcePosition == pos || (stage.ForcePosition == (pos - maxstages)))
				{
					if(!Voting || Voting.FindString(stage.Name, Vote::Config) == -1)
					{
						if(!stage.ArtifactKey[0] || Rogue_HasNamedArtifact(stage.ArtifactKey) != stage.InverseKey)	// Key
							return i;
					}
				}
			}

			i++;
		}
		while(i != start);

		// Normal Search
		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);

			if(stage.ForcePosition == 0)
			{
				if((CurrentFloor < 5 && RogueTheme == ReilaRift) || !Voting || Voting.FindString(stage.Name, Vote::Config) == -1)
				{
					if(!stage.ArtifactKey[0] || Rogue_HasNamedArtifact(stage.ArtifactKey) != stage.InverseKey)	// Key
					{
						if(!type || (stage.WaveSet[0] && stage.FuncStart == INVALID_FUNCTION))	// If Type 1, Normal Battles Only
						{
							if(!CurrentExclude || CurrentExclude.FindString(stage.Name) == -1)	// Exclude List
								return i;
						}
					}
				}
			}

			i++;
		}
		while(i != start);
	}

	return -1;
}

static int ViewCamareasTemp[MAXENTITIES] = {-1, ...};

static void SetClientCamera(int client, const char[] name = "", const char[] skyname = "")
{
	if(name[0])
	{
		char buffer[64];
		int entity = -1;
		while((entity = FindEntityByClassname(entity, "point_camera")) != -1)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				Waves_SetSkyName(skyname, client);
				ForceClientViewOntoEntity(client, entity);
				SetEntityFlags(client, GetEntityFlags(client)|FL_FROZEN|FL_ATCONTROLS);
				return;
			}
		}

		//TF2_AddCondition(client, TFCond_FreezeInput);
	}
	//else
	//{
	//	TF2_RemoveCondition(client, TFCond_FreezeInput);
	//}
	
	SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));
	SetClientViewEntity(client, client);
	Thirdperson_PlayerSpawn(client);
}

static void SetAllCamera(const char[] name = "", const char[] skyname = "")
{
	if(name[0])
	{
		char buffer[64];
		int entity = -1;
		while((entity = FindEntityByClassname(entity, "point_camera")) != -1)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				Waves_SetSkyName(skyname);
				
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && IsPlayerAlive(client))
					{
						SetEntityFlags(client, GetEntityFlags(client)|FL_FROZEN|FL_ATCONTROLS);
						ForceClientViewOntoEntity(client, entity);
					//	Animator_ForceCameraView(client, true, entity, 10.0);
					}
				}

				return;
			}
		}
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));
			SetClientViewEntity(client, client);
			//TF2_RemoveCondition(client, TFCond_FreezeInput);
			Thirdperson_PlayerSpawn(client);
		}
	}

	ClearAllCameras();
}

void Rogue_SetProgressTime(float time, bool hud, bool waitForPlayers = false)
{
	delete ProgressTimer;
	ProgressTimer = CreateTimer(time, waitForPlayers ? Rogue_RoundStartTimer : Rogue_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);

	if(hud)
		SpawnTimer(time);
}

bool Rogue_ArtifactEnabled()
{
	return view_as<bool>(Artifacts);
}

void Rogue_ArtifactMenu(int client, int page)
{
	Menu menu = new Menu(Rogue_ArtifactMenuH);
	
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", "Collected Artifacts");

	char buffer[64];

	Artifact artifact;
	int length = CurrentCollection ? CurrentCollection.Length : 0;
	if(length)
	{
		for(int i; i < length; i++)
		{
			int index = CurrentCollection.Get(i);
			Artifacts.GetArray(index, artifact);
			if(!artifact.Hidden)
			{
				FormatEx(buffer, sizeof(buffer), "%t", artifact.Name);
				menu.AddItem(artifact.Name, buffer);
			}
		}
	}
	else
	{
		FormatEx(artifact.Name, sizeof(artifact.Name), "%t", "None");
		menu.AddItem("", artifact.Name, ITEMDRAW_DISABLED);
	}
	
	menu.ExitBackButton = true;
	menu.DisplayAt(client, page / 7 * 7, MENU_TIME_FOREVER);
}

public int Rogue_ArtifactMenuH(Menu menu, MenuAction action, int client, int choice)
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
				Store_Menu(client);
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			if(buffer[0])
			{
				char desc[64];
				FormatEx(desc, sizeof(desc), "%s Desc", buffer);
				CPrintToChat(client, "%t", "Artifact Info", buffer, desc);
			}
			
			Rogue_ArtifactMenu(client, choice);
		}
	}
	return 0;
}

void Rogue_ApplyAttribs(int client, StringMap map)	// Store_ApplyAttribs()
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncAlly != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncAlly);
				Call_PushCell(client);
				Call_PushCell(map);
				Call_Finish();
			}
		}
	}
}

void Rogue_GiveItem(int client, int entity)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncWeapon != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncWeapon);
				Call_PushCell(entity);
				Call_PushCell(client);
				Call_Finish();
			}
		}
	}

	if(Rogue_GetChaosLevel() == 4)
	{
		b_LeftForDead[client] = true;
	}
}

void Rogue_AllySpawned(int entity)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncAlly != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncAlly);
				Call_PushCell(entity);
				Call_PushCell(0);
				Call_Finish();
			}
		}
	}
}

void Rogue_EnemySpawned(int entity)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncEnemy != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncEnemy);
				Call_PushCell(entity);
				Call_Finish();
			}
		}
	}
	
	if(Rogue_GetChaosLevel() > 1 && !(GetURandomInt() % 2))
	{
		float armor = fl_MeleeArmor[entity];
		fl_MeleeArmor[entity] = fl_RangedArmor[entity];
		fl_RangedArmor[entity] = armor;
	}
}

void Rogue_ReviveSpeed(int &amount)
{
	Rogue_StoryTeller_ReviveSpeed(amount);
	Rogue_Paradox_ReviveSpeed(amount);
}

void Rogue_PlayerDowned(int client)
{
	if(Rogue_GetChaosLevel() > 3)
		i_AmountDowned[client]++;
	
	if(!Waves_InSetup() && RogueTheme == BlueParadox)
	{
		// Gain 10.0 for the total of all players downing
		float chaos = 10.0 / float(CurrentPlayers);
		Rogue_ParadoxDLC_BattleChaos(chaos);
		BattleChaos += chaos;
	}
}

bool Rogue_NoLastman()
{
	return Rogue_Mode() && !Rogue_Paradox_Lastman();
}

bool Rogue_UnlockStore()
{
	return (Rogue_Mode() && RogueTheme == BlueParadox);
}

void Rogue_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(artifact.FuncTakeDamage != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncTakeDamage);
				Call_PushCell(victim);
				Call_PushCellRef(attacker);
				Call_PushCellRef(inflictor);
				Call_PushCellRef(damage);
				Call_PushCellRef(damagetype);
				Call_PushCellRef(weapon);
				Call_Finish();
			}
		}
	}
}

int Rogue_GetNamedArtifact(const char[] name, Artifact artifact)
{
	int pos = Artifacts.FindString(name, Artifact::Name);
	if(pos != -1)
		Artifacts.GetArray(pos, artifact);
	
	return pos;
}

int Rogue_GetRandomArtifact(Artifact artifact, bool blacklist, int forcePrice = -1)
{
	if(!CurrentMissed)
		CurrentMissed = new ArrayList();
	
	ArrayList list = new ArrayList();

	int length = Artifacts.Length;
	for(int i; i < length; i++)
	{
		Artifacts.GetArray(i, artifact);
		if(forcePrice == -1)
		{
			if(artifact.DropChance &&	// Can drop
				(!CurrentCollection || CurrentCollection.FindValue(i) == -1) &&	// Not collected
				(!blacklist || !CurrentMissed || CurrentMissed.FindValue(i) == -1))	// Not blacklisted
			{
				for(int a; a < artifact.DropChance; a++)
				{
					list.Push(i);
				}
			}
		}
		else if(artifact.ShopCost == forcePrice &&	// In price
			(!CurrentCollection || CurrentCollection.FindValue(i) == -1) &&	// Not collected
			(!blacklist || !CurrentMissed || CurrentMissed.FindValue(i) == -1))	// Not blacklisted
		{
			list.Push(i);
		}
	}

	int found = -1;
	length = list.Length;

	if(length)
	{
		found = list.Get(GetURandomInt() % length);
		Artifacts.GetArray(found, artifact);

		if(blacklist && !artifact.Multi)
			CurrentMissed.Push(found);
	}

	delete list;
	return found;
}

stock bool Rogue_HasNamedArtifact(const char[] name)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(StrEqual(artifact.Name, name, false))
				return true;
		}
	}
	return false;
}

void Rogue_GiveNamedArtifact(const char[] name, bool silent = false, bool noFail = false)
{
	if(Offline || !Artifacts)
		return;
	
	if(!CurrentCollection)
		CurrentCollection = new ArrayList();
	
	Artifact artifact;
	int length = Artifacts.Length;
	for(int i; i < length; i++)
	{
		Artifacts.GetArray(i, artifact);
		if(StrEqual(artifact.Name, name, false))
		{
			if(!silent)
			{
				CPrintToChatAll("%t", "New Artifact", artifact.Name);

				Format(artifact.Name, sizeof(artifact.Name), "%s Desc", artifact.Name);
				CPrintToChatAll("%t", artifact.Name);
			}

			CurrentCollection.Push(i);

			if(artifact.FuncCollect != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncCollect);
				Call_Finish();
			}

			if(artifact.FuncAlly != INVALID_FUNCTION)
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && IsPlayerAlive(client))
						Store_ApplyAttribs(client);
				}

				if(artifact.FuncAlly != INVALID_FUNCTION)
				{
					for(int a; a < i_MaxcountNpcTotal; a++)
					{
						int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
						if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Red)
						{
							Call_StartFunction(null, artifact.FuncAlly);
							Call_PushCell(entity);
							Call_PushCell(INVALID_HANDLE);
							Call_Finish();
						}
					}
				}
			}

			if(artifact.FuncWeapon != INVALID_FUNCTION)
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && IsPlayerAlive(client))
						Store_GiveAll(client, GetClientHealth(client));
				}
			}
			return;
		}
	}

	if(!noFail)
		PrintToChatAll("UNKNOWN ITEM \"%s\", REPORT BUG", name);
}

stock void Rogue_RemoveNamedArtifact(const char[] name)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			if(StrEqual(artifact.Name, name, false))
			{
				CurrentCollection.Erase(i);
				if(artifact.FuncRemove != INVALID_FUNCTION)
				{
					//call remove function.
					Call_StartFunction(null, artifact.FuncRemove);
					Call_Finish();
				}
				return;
			}
		}

		PrintToChatAll("UNKNOWN ITEM \"%s\", REPORT BUG", name);
	}
}

stock ArrayList Rogue_GetCurrentCollection()
{
	return CurrentCollection;
}

stock ArrayList Rogue_GetCurrentArtifacts()
{
	return Artifacts;
}

void Rogue_TriggerFunction(int pos, any &data = 0)
{
	if(CurrentCollection)
	{
		Artifact artifact;
		int length = CurrentCollection.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(CurrentCollection.Get(i), artifact);
			Function func = GetItemInArray(artifact, pos);
			if(func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCellRef(data);
				Call_Finish();
			}
		}
	}
}

int Rogue_GetIngots()
{
	return CurrentIngots;
}

void Rogue_AddIngots(int amount, bool silent = false)
{
	int given = amount;
	Rogue_TriggerFunction(Artifact::FuncIngotChanged, given);

	if(given)
	{
		CurrentIngots += given;
		Waves_UpdateMvMStats();

		if(!silent)
		{
			if(given < 0)
			{
				CPrintToChatAll("%t", "Lost Ingots", -given);
			}
			else
			{
				CPrintToChatAll("%t", "Gained Ingots", given);
			}
		}
	}
}

void Rogue_SetBattleIngots(int amount)
{
	BattleIngots = amount;
}

void Rogue_AddBattleIngots(int amount)
{
	BattleIngots += amount;
}

stock int Rogue_GetBonusLife()
{
	return BonusLives;
}

void Rogue_AddBonusLife(int amount)
{
	BonusLives += amount;
	Waves_UpdateMvMStats();
}

stock int Rogue_GetChaos()
{
	return CurrentChaos;
}

stock int Rogue_GetChaosLevel()
{
	if(CurrentChaos > 99)
	{
		return 4;
	}
	else if(CurrentChaos > 69)
	{
		return 3;
	}
	else if(CurrentChaos > 39)
	{
		return 2;
	}
	else if(CurrentChaos > 19)
	{
		return 1;
	}

	return 0;
}

// 0 = Allys, 1 = Friendly, 2 = Netural, 3 = Enemy, 4 = Targeted
stock int Rogue_GetUmbralLevel()
{
	if(CurrentUmbral < 21)
	{
		return 4;
	}
	else if(CurrentUmbral < 41)
	{
		return 3;
	}
	else if(CurrentUmbral < 61)
	{
		return 2;
	}
	else if(CurrentUmbral < 81)
	{
		return 1;
	}

	return 0;
}

stock void Rogue_AddChaos(int amount, bool silent = false)
{
	int change = amount;

	Rogue_Paradox_AddChaos(change);

	CurrentChaos += change;

	Waves_UpdateMvMStats();

	if(!silent)
		CPrintToChatAll("%t", "Gained Chaos", change);
	
	if(Rogue_GetChaosLevel() > 3)
		CreateTimer(10.0, Rogue_ChaosChaos, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

stock void Rogue_AddUmbral(int amount, bool silent = false)
{
	int change = amount;
	
	if(CurrentUmbral < 1)
	{
		CurrentUmbral = 0;
		return;
	}

	CurrentUmbral += change;

	Waves_UpdateMvMStats();

	if(!silent)
	{
		if(change > 0)
		{
			CPrintToChatAll("%t", "Bad Umbral", change);
		}
		else
		{
			CPrintToChatAll("%t", "Good Umbral", -change);
		}
	}
}

static Action Rogue_ChaosChaos(Handle timer)
{
	if(Rogue_GetChaosLevel() < 4)
	{
		CreateTimer(0.5, SetTimeBack);
		return Plugin_Stop;
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			SendConVarValue(client, sv_cheats, "1");
			Convars_FixClientsideIssues(client);
		}
	}

	ResetReplications();
	
	float mod = 1.0 + (CurrentChaos * 0.003);
	if(mod > 3.0)
		mod = 3.0;

	cvarTimeScale.SetFloat(GetRandomFloat(1.0 / mod, mod));
	return Plugin_Continue;
}

stock void Rogue_RemoveChaos(int amount)
{
	int change = amount;

	CurrentChaos -= change;
	if(CurrentChaos < 0)
	{
		change += CurrentChaos;
		CurrentChaos = 0;
	}

	Waves_UpdateMvMStats();
	CPrintToChatAll("%t", "Lost Chaos", change);
}

stock bool Rogue_CurseActive()
{
	return (CurseOne != -1 || CurseTwo != -1);
}

bool Rogue_InSetup()	// Waves_InSetup()
{
	return (GameState == State_Setup || ProgressTimer);
}

bool Rogue_CanRegen()
{
	return !Rogue_Mode() || RogueTheme != BlueParadox || !Rogue_InSetup();
}

bool Rogue_Started()	// Waves_Started()
{
	return GameState != State_Setup;
}

int Rogue_GetRound()	// Waves_GetRoundScale()
{
	return (CurrentFloor * 10) + CurrentCount;
}

int Rogue_GetFloor()
{
	return CurrentFloor;
}

int Rogue_GetStage()
{
	return CurrentCount;
}

stock void Rogue_AddExtraStage(int count)
{
	ExtraStageCount += count;
	Waves_UpdateMvMStats();
}

stock void Rogue_SetRequiredBattle(bool value)
{
	RequiredBattle = value;
}

public void Rogue_Vote_NextStage(const Vote vote)
{
	Floor floor;
	Floors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	int id = GetStageByName(floor, vote.Config, false, stage);

	if(id == -1)
	{
		PrintToChatAll("STAGE \"%s\" VANISHED, REPORT BUG", vote.Config);
		floor.Encounters.GetArray(0, stage);
		id = 0;
	}
	else if(!stage.Repeat)
	{
		if(!CurrentExclude)
			CurrentExclude = new ArrayList(sizeof(stage.Name));
		
		CurrentExclude.PushString(stage.Name);
	}

	if(vote.Level == -2)
	{
		ForcedVoteSeed = -1;
		ExtraStageCount++;
	}
	else
	{
		ForcedVoteSeed = vote.Level;
	}

	SetNextStage(id, false, stage);
}

bool Rogue_UpdateMvMStats()
{
	if(!Rogue_Mode() || !Rogue_InSetup())
		return false;
	
	int objective = FindEntityByClassname(-1, "tf_objective_resource");
	if(objective != -1)
	{
		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", Rogue_GetChaosLevel() > 2 ? (GetURandomInt() % 99999) : 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", 0);

		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", 0);

		for(int i; i < 24; i++)
		{
			switch(i)
			{
				case 0:
				{
					switch(Rogue_GetChaosLevel())
					{
						case 3:
						{
							Waves_SetWaveClass(objective, i, GetURandomInt() % 3, "medic", MVM_CLASS_FLAG_MINIBOSS, true);
						}
						case 4:
						{
							Waves_SetWaveClass(objective, i, 0, "medic", MVM_CLASS_FLAG_MINIBOSS);
						}
						default:
						{
							Waves_SetWaveClass(objective, i, BonusLives, "medic", MVM_CLASS_FLAG_MINIBOSS, true);
						}
					}

					continue;
				}
				case 1:
				{
					switch(Rogue_GetChaosLevel())
					{
						case 3:
						{
							Waves_SetWaveClass(objective, i, GetURandomInt() % 199, "rogue_ingots", MVM_CLASS_FLAG_NORMAL, true);
						}
						case 4:
						{
							Waves_SetWaveClass(objective, i, 0, "rogue_ingots", MVM_CLASS_FLAG_NORMAL);
						}
						default:
						{
							Waves_SetWaveClass(objective, i, CurrentIngots, "rogue_ingots", MVM_CLASS_FLAG_NORMAL, true);
						}
					}

					continue;
				}
				case 2:
				{
					switch(RogueTheme)
					{
						case BlueParadox:
						{
							switch(Rogue_GetChaosLevel())
							{
								case 1, 2:
								{
									Waves_SetWaveClass(objective, i, CurrentChaos, "rogue_chaos_1", MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_ALWAYSCRIT, true);
								}
								case 3, 4:
								{
									Waves_SetWaveClass(objective, i, CurrentChaos, "rogue_chaos_1", MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT, true);
								}
								default:
								{
									Waves_SetWaveClass(objective, i, CurrentChaos, "rogue_chaos_1", MVM_CLASS_FLAG_NORMAL, true);
								}
							}

							continue;
						}
						case ReilaRift:
						{
							if(CurrentUmbral > 0)
							{
								// TODO: Custom Icon
								switch(Rogue_GetUmbralLevel())
								{
									case 0:	// Most Friendly
										Waves_SetWaveClass(objective, i, CurrentUmbral, "robo_extremethreat", MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_ALWAYSCRIT, true);
									
									case 1, 2:
										Waves_SetWaveClass(objective, i, CurrentUmbral, "robo_extremethreat", MVM_CLASS_FLAG_NORMAL, true);
									
									case 3:
										Waves_SetWaveClass(objective, i, CurrentUmbral, "robo_extremethreat", MVM_CLASS_FLAG_MINIBOSS, true);
									
									default:	// Most Hated
										Waves_SetWaveClass(objective, i, CurrentUmbral, "robo_extremethreat", MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT, true);
								}

								continue;
							}
						}
					}
				}
				case 3:
				{
					switch(RogueTheme)
					{
						case ReilaRift:
						{
							if(CurseOne != -1)
							{
								Waves_SetWaveClass(objective, i, CurseTime, "void_gate", MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_ALWAYSCRIT, true);
							}
							else
							{
								Waves_SetWaveClass(objective, i, 0, "void_gate", MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_ALWAYSCRIT, false);
							}
							
							continue;
						}
					}
				}
				/*
				case 4:
				{
					//current Stage
					int DisplayDo = CurrentCount + (GameState == State_Vote ? 2 : 1);
					if(DisplayDo <= 1)
						DisplayDo = 1;
					Waves_SetWaveClass(objective, i, DisplayDo, "current_stage", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}
				case 5:
				{
					//Max Stages
					Waves_SetWaveClass(objective, i, maxRooms + 2, "max_stage", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}
				case 6:
				{
					//Current Floor
					int DisplayDo = CurrentFloor + 1;
					if(DisplayDo <= 1)
						DisplayDo = 1;
					Waves_SetWaveClass(objective, i, DisplayDo, "current_floor", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}
				case 7:
				{
					//Max Floors
					int length1 = Floors.Length;
					Waves_SetWaveClass(objective, i, length1, "max_floor", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}
				*/
			}
			Waves_SetWaveClass(objective, i);
		}
	}

	if(Rogue_GetChaosLevel() < 3)
		Waves_SetCreditAcquired(0);
	
	return true;
}

//thanks to mikusch for showing me this.
void ForceClientViewOntoEntity(int client, int entity)
{
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");

	int ViewTarget = EntRefToEntIndex(ViewCamareasTemp[entity]);
	if(IsValidEntity(ViewTarget))
	{
		SetClientViewEntity(client, ViewTarget);
		//TF2_AddCondition(client, TFCond_FreezeInput);
	}
	else
	{
		float rotation[3];
		float origin[3];
		int viewcontrol = CreateEntityByName("prop_dynamic");
		if (IsValidEntity(viewcontrol))
		{
			GetEntPropVector(entity, Prop_Send, "m_angRotation", rotation);
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
			SetEntityModel(viewcontrol, "models/empty.mdl");
			DispatchKeyValueVector(viewcontrol, "origin", origin);
			DispatchKeyValueVector(viewcontrol, "angles", rotation);
			DispatchSpawn(viewcontrol);
			ViewCamareasTemp[entity] = EntIndexToEntRef(viewcontrol);		
			SetClientViewEntity(client, viewcontrol);
			//TF2_AddCondition(client, TFCond_FreezeInput);
		}
	}
}

void ClearAllCameras()
{
	for(int i=1; i<MAXENTITIES; i++)
	{
		int ViewTarget = EntRefToEntIndex(ViewCamareasTemp[i]);
		if(IsValidEntity(ViewTarget))
		{
			RemoveEntity(ViewTarget);
		}
	}
}

//ROUGELIKE ITEMS

// Dear Artvin, remove these as much as you can, use func_ally, func_weapon, etc.
// Use these if you need some custom logic that's not just stats on a player/weapon

bool b_ProvokedAnger;
bool b_MalfunctionShield;				//shield items
bool b_MusicReleasingRadio;
bool b_WrathOfItallians; 				//see on_ability_use.sp
bool b_BraceletsOfAgility; 				//shield items
bool b_ElasticFlyingCape; 				//shield items
bool b_HealthyEssence; 					//see stocks for healing and various other healing methods like medigun
bool b_FizzyDrink; 			 			//see npc.sp ontakedamage
bool b_HoverGlider; 			 		//see npc.sp ontakedamage
bool b_NickelInjectedPack; 				 //see store GiveAll
bool b_SteelRazor; 				 		
bool b_SpanishSpecialisedGunpowder; 	

static void ClearStats()
{
	b_LeaderSquad = false;
	b_GatheringSquad = false;
	b_ResearchSquad = false;
	b_ProvokedAnger = false;
	b_MalfunctionShield = false;
	b_MusicReleasingRadio = false;
	b_WrathOfItallians = false;
	b_BraceletsOfAgility = false;
	b_ElasticFlyingCape = false;
	b_HealthyEssence = false;
	b_FizzyDrink = false;
	b_HoverGlider = false;
	b_NickelInjectedPack = false;
	b_SteelRazor = false;
	b_SpanishSpecialisedGunpowder = false;

	Rogue_Barracks_Reset();
	Rogue_StoryTeller_Reset();
	Rogue_Whiteflower_Reset();
}

bool IS_MusicReleasingRadio()
{
	return b_MusicReleasingRadio;
}

//ROUGELIKE .sp
//This is only needed for items that are more then just flat stat changes.

#include "roguelike/curses.sp"
#include "roguelike/encounter_battles.sp"
#include "roguelike/encounter_items.sp"
#include "roguelike/item_generic.sp"
#include "roguelike/item_squads.sp"
#include "roguelike/item_barracks.sp"
#include "roguelike/item_storyteller.sp"
#include "roguelike/item_hands.sp"

#include "roguelike/provoked_anger.sp"
#include "roguelike/shield_items.sp"
#include "roguelike/on_ability_use.sp"
#include "roguelike/hand_of_elder_mages.sp"

#include "roguelike/paradox_theme.sp"
#include "roguelike/paradox_generic.sp"
#include "roguelike/paradox_encounters.sp"
#include "roguelike/paradox_dome.sp"

#include "roguelike/item_whiteflower.sp"
#include "roguelike/paradox_dlc.sp"

#include "roguelike/rift_main.sp"
#include "roguelike/rift_encounters.sp"
#include "roguelike/rift_items.sp"
#include "roguelike/rift_hands.sp"
#include "roguelike/rift_stones.sp"
