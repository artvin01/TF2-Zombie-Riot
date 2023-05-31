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
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", this.Name);
		}
		
		char buffer[70];
		Format(buffer, sizeof(buffer), "%s Desc", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", buffer);
		}
	}
}

enum struct Artifact
{
	char Name[64];
	int ShopCost;
	int DropChance;
	Function FuncCollect;
	Function FuncAlly;
	Function FuncEnemy;

	void SetupKv(KeyValues kv)
	{
		this.ShopCost = kv.GetNum("shopcost");
		this.DropChance = kv.GetNum("dropchance");
		
		kv.GetString("func_collect", this.Name, 64);
		this.FuncCollect = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_ally", this.Name, 64);
		this.FuncAlly = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;
		
		kv.GetString("func_enemy", this.Name, 64);
		this.FuncEnemy = this.Name[0] ? GetFunctionByName(null, this.Name) : INVALID_FUNCTION;

		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", this.Name);
		}
		
		char buffer[70];
		Format(buffer, sizeof(buffer), "%s Desc", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", buffer);
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

	Function FuncStart;
	char WaveSet[PLATFORM_MAX_PATH];

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", this.Name);
		}

		kv.GetString("camera", this.Camera, 64);
		kv.GetString("spawn", this.Spawn, 64);
		kv.GetString("skyname", this.Skyname, 64);
		this.Hidden = view_as<bool>(kv.GetNum("hidden"));
		
		kv.GetString("func_start", this.WaveSet, PLATFORM_MAX_PATH);
		this.FuncStart = this.WaveSet[0] ? GetFunctionByName(null, this.WaveSet) : INVALID_FUNCTION;

		kv.GetString("wave", this.WaveSet, PLATFORM_MAX_PATH);
		if(this.WaveSet[0])
		{
			char buffer[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, this.WaveSet);
			if(!FileExists(buffer))
			{
				this.WaveSet[0] = 0;
				LogError("\"%s\" wave set does not exist", this.WaveSet);
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

	ArrayList Encounters;
	ArrayList Finals;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			strcopy(this.Name, 64, "Missing Rouge Translation");
			LogError("\"%s\" translation does not exist", this.Name);
		}

		this.RoomCount = kv.GetNum("rooms", 2) - 2;
		kv.GetString("camera", this.Camera, 64);
		kv.GetString("skyname", this.Skyname, 64);

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

static bool InRougeMode;

static ArrayList Voting;
static float VoteEndTime;
static int VotedFor[MAXTF2PLAYERS];
static Function VoteFunc;
static char VoteTitle[256];

static ArrayList Curses;
static ArrayList Artifacts;
static ArrayList Floors;

static int GameState;
static Handle ProgressTimer;

static int CurrentFloor;
static int CurrentCount;
static int CurrentStage;
static ArrayList CurrentExclude;

bool Rouge_Mode()	// If Rouge-Like is enabled
{
	return InRougeMode;
}

void Rouge_MapStart()
{
	InRougeMode = false;
}

void Rouge_SetupVote(KeyValues kv)
{
	InRougeMode = true;

	Zero(VotedFor);

	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	VoteFunc = INVALID_FUNCTION;
	
	Vote vote;
	kv.GotoFirstSubKey(false);
	do
	{
		kv.GetSectionName(vote.Name, sizeof(vote.Name));
		Voting.PushArray(vote);
	}
	while(kv.GotoNextKey(false));

	CreateTimer(1.0, Rouge_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	kv.Rewind();
	kv.JumpToKey("Rouge");

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

	if(kv.JumpToKey("Curses"))
	{
		if(kv.GotoFirstSubKey(false))
		{
			Curses = new ArrayList(sizeof(Curse));
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
			Artifacts = new ArrayList(sizeof(Artifact));
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
			Floors = new ArrayList(sizeof(Floor));
			
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

void Rouge_RevoteCmd(int client)	// Waves_RevoteCmd
{
	Rouge_CallVote(client, true);
}

bool Rouge_CallVote(int client, bool force = false)	// Waves_CallVote
{
	if(Voting && (force || !VotedFor[client]))
	{
		if(VoteFunc == INVALID_FUNCTION)
		{
			Menu menu = new Menu(Rouge_CallVoteH);
			
			SetGlobalTransTarget(client);
			
			menu.SetTitle("%t\n ", "Vote for the starting item");
			
			Vote vote;
			Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
			menu.AddItem(NULL_STRING, vote.Name);

			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				Format(vote.Config, sizeof(vote.Config), "%t", vote.Name);
				menu.AddItem(vote.Name, vote.Config);
			}
			
			menu.ExitButton = false;
			menu.Display(client, MENU_TIME_FOREVER);
			return true;
		}

		return CallGenericVote(client);
	}
	return false;
}

public int Rouge_CallVoteH(Menu menu, MenuAction action, int client, int choice)
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
						Voting.GetArray(choice, vote);
						FormatEx(vote.Config, sizeof(vote.Config), "%s Desc", vote.Name);
						CPrintToChat(client, "%t: %t", vote.Name, vote.Config);
						Rouge_CallVote(client, true);
						return 0;
					}
				}
			}
			
			Store_Menu(client);
		}
	}
	return 0;
}

public Action Rouge_VoteDisplayTimer(Handle timer)
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

void Rouge_StartSetup()	// Waves_RoundStart()
{
	Rouge_RoundEnd();

	float wait = 60.0;

	if(Voting)
	{
		wait = zr_waitingtime.FloatValue;
		float time = wait - 30.0;
		if(time < 20.0)
			time = 20.0;
		
		VoteEndTime = GetGameTime() + time;
		CreateTimer(time, Rouge_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

		if(wait < time)
			wait = time;
	}

	SetProgressTime(wait, true);
}

void Rouge_RoundEnd()
{
	delete ProgressTimer;
	GameState = State_Setup;
	CurrentFloor = 0;
	CurrentStage = -1;
	CurrentCount = -1;
	delete CurrentExclude;
}

public Action Rouge_EndVote(Handle timer, float time)
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
				CPrintToChatAll("%t", "New Artifact", vote.Name);

				Format(vote.Name, sizeof(vote.Name), "%s Desc", vote.Name);
				CPrintToChatAll("%t", vote.Name);

				// TODO: Give Artifact
			}
			else
			{
				Call_StartFunction(null, VoteFunc);
				Call_PushArray(vote, sizeof(vote));
				Call_Finish();
			}
		}
	}
	return Plugin_Continue;
}

public Action Rouge_RoundStartTimer(Handle timer)
{
	ProgressTimer = null;

	if(!Voting && !CvarNoRoundStart.BoolValue)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			{
				Rouge_NextProgress();
				return Plugin_Stop;
			}
		}
	}

	ProgressTimer = CreateTimer(10.0, Rouge_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

void Rouge_BattleVictory()
{
	Waves_RoundEnd();

	// TODO: Victory stuff

	SetProgressTime(30.0, true);
}

bool Rouge_BattleLost()
{
	return true;	// Return true to fail the game

	//SetProgressTime(5.0, false);
	//return false;
}

void Rouge_NextProgress()
{
	switch(GameState)
	{
		case State_Setup:
		{
			Store_RemoveSellValue();
			
			Ammo_Count_Ready = 8;
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2)
				{
					int cash = StartCash - (Resupplies_Supplied[client] * 10);
					if(CashSpent[client] < cash)
						CashSpent[client] = cash;
					
					CashSpent[client] -= StartCash;
				}
			}

			CurrentCash = 0;
			
			CurrentFloor = 0;
			CurrentCount = -1;
			delete CurrentExclude;

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
				SetNextStage(id, stage, 15.0);
			}
		}
		case State_Trans:
		{
			Floor floor;
			Floors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			floor.Encounters.GetArray(CurrentStage, stage);

			StartStage(stage);
		}
		case State_Stage:
		{
			Floor floor;
			Floors.GetArray(CurrentFloor, floor);
			
			if(CurrentCount > floor.RoomCount)
			{
				// Go to next floor
				CurrentFloor++;
				CurrentStage = -1;
				CurrentCount = -1;

				if(CurrentFloor >= Floors.Length)	// All the floors are done
				{
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
					Floors.GetArray(CurrentFloor, floor);
					SetAllCamera(floor.Camera, floor.Skyname);

					strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), floor.Name);

					SetHudTextParamsEx(-1.0, -1.0, 8.0, {255, 255, 255, 255}, {255, 200, 155, 255}, 2, 0.1, 0.1);
					for(int client = 1; client <= MaxClients; client++)
					{
						if(!b_IsPlayerABot[client] && IsClientInGame(client))
						{
							SetGlobalTransTarget(client);
							ShowHudText(client, -1, "%t", floor.Name);
						}
					}

					// TODO: Curse Rolls

					GameState = State_Trans;
					SetProgressTime(7.0, false);
				}
			}
			else if(CurrentCount == floor.RoomCount)	// Final Stage
			{
				Stage stage;
				int id = GetRandomStage(floor, stage, true, false);
				if(id == -1)
				{
					// We somehow don't have a final stage
					CurrentCount = floor.RoomCount + 1;
					Rouge_NextProgress();
				}
				else
				{
					SetNextStage(id, stage, 30.0);
				}
			}
			else	// Normal Stage
			{
				Rouge_CreateGenericVote(Rouge_Vote_NextStage, "Vote for the next stage");

				int count = 2;
				if(!(GetURandomInt() % 6))
					count++;
				
				Vote vote;
				Stage stage;
				for(int i; i < count; i++)
				{
					int id = GetRandomStage(floor, stage, false, false);
					if(id != -1)
					{
						strcopy(vote.Config, sizeof(vote.Config), stage.Name);

						if(stage.Hidden)
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
					Rouge_StartGenericVote();
					GameState = State_Vote;
				}
				else	// We somehow ran out of normal rooms
				{
					delete Voting;
					CurrentCount = floor.RoomCount;
					Rouge_NextProgress();
				}
			}
		}
		default:
		{
			PrintToChatAll("INVALID GAME STATE %d, REPORT BUG", GameState);
		}
	}
}

ArrayList Rouge_CreateGenericVote(Function func, const char[] title)
{
	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	VoteFunc = func;
	strcopy(VoteTitle, sizeof(VoteTitle), title);

	return Voting;
}

void Rouge_StartGenericVote(float time = 20.0)
{
	Zero(VotedFor);
	CreateTimer(1.0, Rouge_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	VoteEndTime = GetGameTime() + time;
	CreateTimer(time, Rouge_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

	SetProgressTime(time + 10.0, false);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && GetClientMenu(client) == MenuSource_None)
			Rouge_CallVote(client);
	}
}

static bool CallGenericVote(int client)
{
	Menu menu = new Menu(Rouge_CallGenericVoteH);
	
	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n ", VoteTitle);
	
	Vote vote;
	Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
	menu.AddItem(NULL_STRING, vote.Name);

	int length = Voting.Length;
	for(int i; i < length; i++)
	{
		Voting.GetArray(i, vote);
		Format(vote.Name, sizeof(vote.Name), "%t", vote.Name);
		menu.AddItem(vote.Config, vote.Name);
	}
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	return true;
}

public int Rouge_CallGenericVoteH(Menu menu, MenuAction action, int client, int choice)
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
						Voting.GetArray(choice, vote);
						if(VoteFunc == Rouge_Vote_NextStage)
						{
							Floor floor;
							Floors.GetArray(CurrentFloor, floor);
							
							Stage stage;
							GetStageByName(floor, vote.Config, false, stage);

							SetClientCamera(client, stage.Camera, stage.Skyname);
							return 0;
						}
						else if(vote.Desc[0])
						{
							CPrintToChat(client, "%t", vote.Desc);
							Rouge_CallVote(client, true);
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

static void SetNextStage(int id, const Stage stage, float time = 10.0)
{
	CurrentCount++;
	CurrentStage = id;

	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), stage.Name);

	if(stage.WaveSet[0])	// If a battle, give map over view for 10 seconds
	{
		GameState = State_Trans;
		SetAllCamera(stage.Camera, stage.Skyname);
		SetProgressTime(time, true);
	}
	else
	{
		StartStage(stage);
	}
}

void Rouge_StartThisBattle(float time = 10.0)
{
	delete ProgressTimer;

	Floor floor;
	Floors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	floor.Encounters.GetArray(CurrentStage, stage);

	StartBattle(stage, time + 1.0);
	SetProgressTime(time, true);
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
}

static void StartStage(const Stage stage)
{
	GameState = State_Stage;
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
		SetProgressTime(time, false);
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
		if(entity != INVALID_ENT_REFERENCE)
		{
			// TODO: Do stuff like building refunds, etc.
			SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
		}
	}
}

static int GetStageByName(const Floor floor, const char[] name, bool final, Stage stage)
{
	ArrayList list = final ? floor.Encounters : floor.Finals;
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
	ArrayList list = final ? floor.Encounters : floor.Finals;
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
		if((!battleOnly || stage.WaveSet[0]) && (final || !CurrentExclude || CurrentExclude.FindValue(i) == -1))
			return i;

		i++;
	}
	while(i != start);

	return -1;
}

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
				SetClientViewEntity(client, entity);
				return;
			}
		}

		TF2_AddCondition(client, TFCond_FreezeInput);
	}
	else
	{
		TF2_RemoveCondition(client, TFCond_FreezeInput);
	}
	
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
						SetClientViewEntity(client, entity);
						TF2_AddCondition(client, TFCond_FreezeInput);
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
			TF2_RemoveCondition(client, TFCond_FreezeInput);
		}
	}
}

static void SetProgressTime(float time, bool hud)
{
	delete ProgressTimer;
	ProgressTimer = CreateTimer(time, Rouge_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);

	if(hud)
		SpawnTimer(time);
}

bool Rouge_InSetup()	// Waves_InSetup()
{
	return (GameState == State_Setup || ProgressTimer);
}

bool Rouge_Started()	// Waves_Started()
{
	return GameState != State_Setup;
}

int Rouge_GetRound()	// Waves_GetRound()
{
	return ProgressTimer ? CurrentFloor : CurrentRound;
}

int Rouge_GetWave()	// Waves_GetWave()
{
	return ProgressTimer ? CurrentCount : CurrentWave;
}

int Rouge_GetRoundScale()
{
	return Rouge_Started() ? ((CurrentFloor * 15) + (CurrentCount * 2)) : CurrentRound;
}

public void Rouge_Vote_NextStage(const Vote vote)
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
	else
	{
		if(!CurrentExclude)
			CurrentExclude = new ArrayList();
		
		CurrentExclude.Push(id);
	}

	SetNextStage(id, stage);
}

#include "rougelike/encounter_battles.sp"

//ROUGELIKE ITEMS
/*TODO*/bool b_SpearheadSquad;		 //should be done in store 
bool b_ProvokedAnger;
/*TODO*/bool b_MalfunctionShield;
/*TODO*/bool b_GrigoriCoinPurse;	 //should be done when the weapon is created/when a battle starts
bool b_MusicReleasingRadio;

//ROUGELIKE .sp
//This is only needed for items that are more then just flat stat changes.

#include "rougelike/provoked_anger.sp"