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
	Function FuncCollect;
	Function FuncRemove;
	Function FuncAlly;
	Function FuncEnemy;
	Function FuncWeapon;

	void SetupKv(KeyValues kv)
	{
		this.ShopCost = kv.GetNum("shopcost");
		this.DropChance = kv.GetNum("dropchance");
		
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

	Function FuncStart;
	char WaveSet[PLATFORM_MAX_PATH];

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}

		kv.GetString("camera", this.Camera, 64);
		kv.GetString("spawn", this.Spawn, 64);
		kv.GetString("skyname", this.Skyname, 64);
		this.Hidden = view_as<bool>(kv.GetNum("hidden"));
		this.Repeat = view_as<bool>(kv.GetNum("repeatable"));
		
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
	}
}

enum struct Floor
{
	char Name[64];
	char Camera[64];
	char Skyname[64];
	int RoomCount;

	char MusicNormal[PLATFORM_MAX_PATH];
	int TimeNormal;
	bool CustomNormal;

	char MusicCurse[PLATFORM_MAX_PATH];
	int TimeCurse;
	bool CustomCurse;

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

		kv.GetString("normal_path", this.MusicNormal, PLATFORM_MAX_PATH);
		this.TimeNormal = kv.GetNum("normal_time");
		this.CustomNormal = view_as<bool>(kv.GetNum("normal_download"));
		if(this.MusicNormal[0])
		{
			if(this.CustomNormal)
			{
				PrecacheSoundCustom(this.MusicNormal);
			}
			else
			{
				PrecacheSound(this.MusicNormal);
			}
		}

		kv.GetString("curse_path", this.MusicCurse, PLATFORM_MAX_PATH);
		this.TimeCurse = kv.GetNum("curse_time");
		this.CustomCurse = view_as<bool>(kv.GetNum("curse_download"));
		if(this.MusicCurse[0])
		{
			if(this.CustomCurse)
			{
				PrecacheSoundCustom(this.MusicCurse);
			}
			else
			{
				PrecacheSound(this.MusicCurse);
			}
		}

		Stage stage;

		this.Encounters = new ArrayList(sizeof(Stage));
		if(kv.JumpToKey("Stages"))
		{
			if(kv.GotoFirstSubKey())
			{

				do
				{
					stage.SetupKv(kv);
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
					stage.SetupKv(kv);
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

static bool InRogueMode;

static ArrayList Voting;
static float VoteEndTime;
static int VotedFor[MAXTF2PLAYERS];
static Function VoteFunc;
static char VoteTitle[256];
static char StartingItem[64];

static ArrayList Curses;
static ArrayList Artifacts;
static ArrayList Floors;

static int GameState;
static Handle ProgressTimer;

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

static int CurseOne = -1;
static int CurseTwo = -1;
static int ExtraStageCount;

// Rogue Items
bool b_LeaderSquad;
bool b_GatheringSquad;
bool b_ResearchSquad;

void Rogue_PluginStart()
{
	RegAdminCmd("zr_giveartifact", Rogue_DebugGive, ADMFLAG_ROOT);
	RegAdminCmd("zr_skipbattle", Rogue_DebugSkip, ADMFLAG_ROOT);
	RegAdminCmd("zr_setstage", Rogue_DebugSet, ADMFLAG_ROOT);
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

void Rogue_MapStart()
{
	InRogueMode = false;
}

void Rogue_SetupVote(KeyValues kv)
{
	PrecacheSound("misc/halloween/gotohell.wav");

	InRogueMode = true;

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
		Voting.PushArray(vote);
	}
	while(kv.GotoNextKey(false));

	CreateTimer(1.0, Rogue_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	kv.Rewind();
	kv.JumpToKey("Rogue");

	Floor floor;

	delete Curses;
	delete Artifacts;

	if(Floors)
	{
		int length = Floors.Length;
		for(int i; i < length; i++)
		{
			Floors.GetArray(i, floor);
			delete floor.Encounters;
			delete floor.Finals;
		}

		delete Floors;
	}

	Curses = new ArrayList(sizeof(Curse));
	Artifacts = new ArrayList(sizeof(Artifact));
	Floors = new ArrayList(sizeof(Floor));

	if(kv.JumpToKey("Curses"))
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

	if(kv.JumpToKey("Floors"))
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
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			Waves_RoundStart();
			break;
		}
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
				Format(vote.Config, sizeof(vote.Config), "%t%s", vote.Name, vote.Append);
				menu.AddItem(vote.Name, vote.Config);
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
				if(VotedFor[client] != choice)
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
		return Plugin_Stop;
	
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

					if(VotedFor[client] > 0)
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

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					Voting.GetArray(top[i], vote);

					Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
}

void Rogue_StartSetup()	// Waves_RoundStart()
{
	Rogue_RoundEnd();

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
}

void Rogue_RoundEnd()
{
	delete ProgressTimer;
	GameState = State_Setup;
	CurrentFloor = 0;
	CurrentStage = -1;
	CurrentCount = -1;
	delete CurrentExclude;
	delete CurrentCollection;
	CurrentIngots = 0;
	
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
				Rogue_GiveNamedArtifact(vote.Name);
				strcopy(StartingItem, sizeof(StartingItem), vote.Name);
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
	
	if(!Voting && !CvarNoRoundStart.BoolValue)
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

	ProgressTimer = CreateTimer(10.0, Rogue_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action Rogue_ProgressTimer(Handle timer)
{
	ProgressTimer = null;
	Rogue_NextProgress();
	return Plugin_Stop;
}

void Rogue_BattleVictory()
{
	Waves_RoundEnd();
	Store_RogueEndFightReset();

	if(BattleIngots > 0)
	{
		if((GetURandomInt() % 8) < BattleIngots)
		{
			Artifact artifact;
			if(Rogue_GetRandomArtfiact(artifact, true, -1) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
		}

		if(Rogue_HasFriendship())
			BattleIngots += BattleIngots > 4 ? 2 : 1;
		
		CurrentIngots += BattleIngots;
		CPrintToChatAll("%t", "Gained Ingots", BattleIngots);
	}

	Rogue_SetProgressTime(30.0, true);
	
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

	SetFloorMusic(floor, false);
}

bool Rogue_BattleLost()
{
	if(BonusLives > 0)	// TODO: Flag when it's a boss stage
	{
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

		Rogue_SetProgressTime(5.0, false, true);
		
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
					//int cash = StartCash - (Resupplies_Supplied[client] * 10);
					//if(CashSpent[client] < cash)
					//	CashSpent[client] = cash;
					//
					//CashSpent[client] -= StartCash;

					if(Level[client] > highestLevel)
						highestLevel = Level[client];
				}
			}

			//CurrentCash = 0;
			
			CurrentFloor = 0;
			CurrentCount = -1;
			delete CurrentExclude;

			int startingIngots = (highestLevel + 80) / 10;
			if(startingIngots < 8)
			{
				startingIngots = 8;
			}
			else if(startingIngots > 16)
			{
				startingIngots = 16;
			}

			CurrentIngots += startingIngots;

			Floor floor;
			Floors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			int id = GetRandomStage(floor, stage, false, true);
			if(id == -1)
			{
				PrintToChatAll("NO BATTLES ON FIRST FLOOR? BAD CFG, REPORT BUG");
			}
			else
			{
				SetNextStage(id, false, stage, 15.0);
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
			
			if(CurrentCount > maxRooms)
			{
				// Go to next floor
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
				
				if(CurseTwo)
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

				CurrentFloor++;
				CurrentStage = -1;
				CurrentCount = -1;
				ExtraStageCount = 0;

				if(CurrentFloor >= Floors.Length)	// All the floors are done
				{
					for(int client = 1; client <= MaxClients; client++)
					{
						if(!b_IsPlayerABot[client] && IsClientInGame(client))
						{
							Music_Stop_All(client);
							SetMusicTimer(client, GetTime() + 33);
						}
					}

					char_MusicString1[0] = 0;
					char_MusicString2[0] = 0;
					char_RaidMusicSpecial1[0] = 0;

					CurrentFloor = 0;

					EmitCustomToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);

					int entity = CreateEntityByName("game_round_win"); 
					DispatchKeyValue(entity, "force_map_reset", "1");
					SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Red);
					DispatchSpawn(entity);
					AcceptEntityInput(entity, "RoundWin");
				}
				else
				{
					TeleportToSpawn();

					Floors.GetArray(CurrentFloor, floor);
					SetAllCamera(floor.Camera, floor.Skyname);

					strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), floor.Name);

					bool cursed;
					if(!(GetURandomInt() % 5))
					{
						int length = Curses.Length;
						if(length)
						{
							cursed = true;

							CurseOne = GetURandomInt() % length;
							
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

							char buffer[64];
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

					Rogue_SetProgressTime(7.0, false);

					if(cursed)
					{
						strcopy(char_MusicString1, sizeof(char_MusicString1), "misc/halloween/gotohell.wav");
						char_MusicString2[0] = 0;
						char_RaidMusicSpecial1[0] = 0;
						i_MusicLength1 = 7;
						b_MusicCustom1 = false;
					}
					else
					{
						SetFloorMusic(floor, false);
					}
				}
			}
			else if(CurrentCount == maxRooms)	// Final Stage
			{
				int id = GetRandomStage(floor, stage, true, false);
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
					SetNextStage(id, true, stage, 30.0);
				}
			}
			else	// Normal Stage
			{
				Rogue_CreateGenericVote(Rogue_Vote_NextStage, "Vote for the next stage");

				int count = 2;
				if(!(GetURandomInt() % 6))
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
					int id = GetRandomStage(floor, stage, false, false);
					if(id != -1)
					{
						strcopy(vote.Config, sizeof(vote.Config), stage.Name);

						if(Rogue_Curse_HideNames())
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

						Voting.PushArray(vote);

						if(!i)
							SetAllCamera(stage.Camera, stage.Skyname);
					}
				}

				if(Voting.Length)
				{
					TeleportToSpawn();
					
					SetFloorMusic(floor, true);

					Rogue_StartGenericVote();
					GameState = State_Vote;

					char_MusicString2[0] = 0;
					char_RaidMusicSpecial1[0] = 0;
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
		}
	}
}

static void SetFloorMusic(const Floor floor, bool stop)
{
	bool curse = CurseOne != -1 || CurseTwo != -1;
	if(char_RaidMusicSpecial1[0] || !StrEqual(char_MusicString1, curse ? floor.MusicCurse : floor.MusicNormal))
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

		char_MusicString2[0] = 0;
		char_RaidMusicSpecial1[0] = 0;

		if(curse)
		{
			strcopy(char_MusicString1, sizeof(char_MusicString1), floor.MusicCurse);
			i_MusicLength1 = floor.TimeCurse;
			b_MusicCustom1 = floor.CustomCurse;
		}
		else
		{
			strcopy(char_MusicString1, sizeof(char_MusicString1), floor.MusicNormal);
			i_MusicLength1 = floor.TimeNormal;
			b_MusicCustom1 = floor.CustomNormal;
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
	CreateTimer(1.0, Rogue_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	VoteEndTime = GetGameTime() + time;
	CreateTimer(time, Rogue_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

	Rogue_SetProgressTime(time + 10.0, false);

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
		menu.AddItem(vote.Config, vote.Name);
	}

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
				if(VotedFor[client] != choice)
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
						if(VoteFunc == Rogue_Vote_NextStage)
						{
							Floor floor;
							Floors.GetArray(CurrentFloor, floor);
							
							Stage stage;
							GetStageByName(floor, vote.Config, false, stage);

							SetClientCamera(client, stage.Camera, stage.Skyname);

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

static void SetNextStage(int id, bool type, const Stage stage, float time = 10.0)
{
	CurrentCount++;
	CurrentStage = id;
	CurrentType = type;

	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), stage.Name);

	if(stage.WaveSet[0])	// If a battle, give map over view for 10 seconds
	{
		GameState = State_Trans;
		SetAllCamera(stage.Camera, stage.Skyname);
		Rogue_SetProgressTime(time, true);
	}
	else
	{
		StartStage(stage);
	}
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

	StartBattle(stage, time + 1.0);
	Rogue_SetProgressTime(time, true);
}

static void StartBattle(const Stage stage, float time = 3.0)
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, stage.WaveSet);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(buffer);
	Waves_SetupWaves(kv, false);
	delete kv;

	CreateTimer(time, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client);
			SetMusicTimer(client, GetTime() + 3);
		}
	}

	char_MusicString1[0] = 0;
	char_MusicString2[0] = 0;
	char_RaidMusicSpecial1[0] = 0;

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

	Rogue_Curse_BattleStart();
}

static void StartStage(const Stage stage)
{
	GameState = State_Stage;
	BattleIngots = CurrentFloor > 1 ? 4 : 3;
	SetAllCamera();

	float time = stage.WaveSet[0] ? 0.0 : 10.0;
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

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
			TeleportEntity(client, pos, ang, NULL_VECTOR);
	}
	
	for(int i; i < i_MaxcountNpc; i++)
	{
		entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
	}
	
	for(int i; i < i_MaxcountNpc_Allied; i++)
	{
		entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			TeleportEntity(entity, pos, ang, NULL_VECTOR);
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		entity = EntRefToEntIndex(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && !i_BeingCarried[entity])
			SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
	}

	if(Rogue_Curse_HideNames())
		Rogue_AddIngots(1);
}

static void TeleportToSpawn()
{
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
			TeleportEntity(client, pos, ang, NULL_VECTOR);
	}
	
	for(int i; i < i_MaxcountNpc; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
	}
	
	for(int i; i < i_MaxcountNpc_Allied; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			TeleportEntity(entity, pos, ang, NULL_VECTOR);
	}

	for(int i; i < i_MaxcountBuilding; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[i]);
		if(entity != INVALID_ENT_REFERENCE && !i_BeingCarried[entity])
			SDKHooks_TakeDamage(entity, 0, 0, 99999999.9, DMG_ACID);
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

static int GetRandomStage(const Floor floor, Stage stage, bool final, bool battleOnly)
{
	ArrayList list = final ? floor.Finals : floor.Encounters;
	if(!list)
		list = floor.Encounters;
	
	int length = list.Length;

	int start = GetURandomInt() % length;
	int i = start;
	do
	{
		if(i >= length)
		{
			i = 0;
			continue;
		}
		
		list.GetArray(i, stage);
		if((!battleOnly || (stage.WaveSet[0] && stage.FuncStart == INVALID_FUNCTION)) && (final || !CurrentExclude || CurrentExclude.FindString(stage.Name) == -1))
			return i;

		i++;
	}
	while(i != start);

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
				return;
			}
		}

		//TF2_AddCondition(client, TFCond_FreezeInput);
	}
	//else
	//{
	//	TF2_RemoveCondition(client, TFCond_FreezeInput);
	//}
	
	SetClientViewEntity(client, client);
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
			SetClientViewEntity(client, client);
			//TF2_RemoveCondition(client, TFCond_FreezeInput);
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

void Rogue_ArtifactMenu(int client, int page)
{
	Menu menu = new Menu(Rogue_ArtifactMenuH);
	
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", "Collected Artifacts");

	Artifact artifact;
	int length = CurrentCollection ? CurrentCollection.Length : 0;
	if(length)
	{
		for(int i; i < length; i++)
		{
			int index = CurrentCollection.Get(i);
			Artifacts.GetArray(index, artifact);
			
			menu.AddItem(artifact.Name, artifact.Name);
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

void Rogue_GiveItem(int entity)
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
				Call_Finish();
			}
		}
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
}

int Rogue_GetRandomArtfiact(Artifact artifact, bool blacklist, int forcePrice = -1)
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

		if(blacklist)
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

void Rogue_GiveNamedArtifact(const char[] name, bool silent = false)
{
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
					for(int a; a < i_MaxcountNpc_Allied; a++)
					{
						int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[a]);
						if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
						{
							Call_StartFunction(null, artifact.FuncAlly);
							Call_PushCell(entity);
							Call_PushCell(INVALID_HANDLE);
							Call_Finish();
						}
					}

					for(int a; a < i_MaxcountBuilding; a++)
					{
						int entity = EntRefToEntIndex(i_ObjectsBuilding[a]);
						if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
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
				if(artifact.FuncRemove != INVALID_FUNCTION)	// Items can only be "removed" when have a func_remove
				{
					Call_StartFunction(null, artifact.FuncRemove);
					Call_Finish();

					CurrentCollection.Erase(i);
				}
				return;
			}
		}

		PrintToChatAll("UNKNOWN ITEM \"%s\", REPORT BUG", name);
	}
}

int Rogue_GetIngots()
{
	return CurrentIngots;
}

void Rogue_AddIngots(int amount)
{
	CurrentIngots += amount;
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
}

bool Rogue_InSetup()	// Waves_InSetup()
{
	return (GameState == State_Setup || ProgressTimer);
}

bool Rogue_Started()	// Waves_Started()
{
	return GameState != State_Setup;
}

int Rogue_GetRound()	// Waves_GetRound()
{
	return ProgressTimer ? CurrentFloor : CurrentRound;
}

int Rogue_GetWave()	// Waves_GetWave()
{
	return ProgressTimer ? CurrentCount : CurrentWave;
}

int Rogue_GetRoundScale()
{
	return Rogue_Started() ? ((CurrentFloor * 15) + (CurrentCount * 2)) : CurrentRound;
}

void Rogue_AddExtraStage(int count)
{
	ExtraStageCount += count;
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
	else if(stage.Repeat)
	{
		if(!CurrentExclude)
			CurrentExclude = new ArrayList(sizeof(stage.Name));
		
		CurrentExclude.PushString(stage.Name);
	}

	SetNextStage(id, false, stage);
}

//thanks to mikusch for showing me this.
void ForceClientViewOntoEntity(int client, int entity)
{
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
bool b_HandOfElderMages; 				
bool b_BraceletsOfAgility; 				//shield items
bool b_ElasticFlyingCape; 				//shield items
bool b_HealingSalve; 					//see sdkhooks think and item_generic
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

	Rogue_Barracks_Reset();
	Rogue_StoryTeller_Reset();
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
//#include "roguelike/item_hands.sp"

#include "roguelike/provoked_anger.sp"
#include "roguelike/shield_items.sp"
#include "roguelike/on_ability_use.sp"
#include "roguelike/hand_of_elder_mages.sp"
