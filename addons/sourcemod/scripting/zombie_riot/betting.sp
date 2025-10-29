#pragma semicolon 1
#pragma newdecls required

static bool InBetWarMode;
static int MaxBetRound;
static float CameraZ;
static char BetTeamSpawn[2][64];
static MusicEnum BackgroundMusic;

static ArrayList Voting;
static float VoteEndTime;
static int VotedFor[MAXPLAYERS];
static bool VotedAllIn[MAXPLAYERS];

static int BetMoney[MAXPLAYERS];
static int CurrentBetRound;
static int GameState;

static Handle ProgressTimer;
static Menu WinMenuPanel;

bool BetWar_Mode()
{
	return InBetWarMode;
}

float BetWar_Camera()
{
	return CameraZ;
}

void BetWar_PluginStart()
{
	AddCommandListener(BetWar_SpecMode, "spec_mode");
}

static Action BetWar_SpecMode(int client, const char[] command, int args)
{
	if(BetWar_Mode() && !IsPlayerAlive(client) && IsClientObserver(client))
	{
		SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_FREEZECAM);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

void BetWar_MapStart()
{
	delete Voting;
	delete ProgressTimer;
	delete WinMenuPanel;
	InBetWarMode = false;
	BackgroundMusic.Clear();
}

void BetWar_SetupVote(KeyValues kv)
{
	InBetWarMode = true;
	BackgroundMusic.Clear();
	BetWar_RoundEnd();

	kv.Rewind();
	kv.JumpToKey("Waves");

	Waves_SetupWaves(kv, false);

	kv.Rewind();
	kv.JumpToKey("BetWars");

	BackgroundMusic.SetupKv("music_background", kv);

	CameraZ = kv.GetFloat("camera_z", -1.0);
	MaxBetRound = kv.GetNum("rounds", 10);
	kv.GetString("spawn_blue", BetTeamSpawn[0], sizeof(BetTeamSpawn[]), "spawn_blue");
	kv.GetString("spawn_red", BetTeamSpawn[1], sizeof(BetTeamSpawn[]), "spawn_red");

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

void BetWar_RevoteCmd(int client)	// Waves_RevoteCmd
{
	BetWar_CallVote(client, true);
}

bool BetWar_CallVote(int client, bool force = false)	// Waves_CallVote
{
	if(Voting && (force || !VotedFor[client]))
	{
		int bet = CurrentBet();
		
		Menu menu = new Menu(BetWar_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("Round %d / %d\nPlace your bets\n ", CurrentBetRound + 1, MaxBetRound);
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		menu.AddItem(NULL_STRING, vote.Name, VotedFor[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		int length = Voting.Length;
		for(int i; i < length; i++)
		{
			Voting.GetArray(i, vote);

			Format(vote.Config, sizeof(vote.Config), "%s%s ($%d)", vote.Name, vote.Append, bet);
			menu.AddItem(vote.Name, vote.Config, BetMoney[client] < bet || ((VotedFor[client] == i + 1) && !VotedAllIn[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}

		if(CurrentBetRound > 4 || BetMoney[client] < bet)
		{
			for(int i; i < length; i++)
			{
				Format(vote.Config, sizeof(vote.Config), "%s%s (ALL IN)", vote.Name, vote.Append);
				menu.AddItem(vote.Name, vote.Config, BetMoney[client] < 100 || ((VotedFor[client] == i + 1) && VotedAllIn[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
		}
		
		menu.ExitButton = false;
		menu.Display(client, RoundToCeil(VoteEndTime - GetGameTime()));
		return true;
	}
	return false;
}

static int BetWar_CallVoteH(Menu menu, MenuAction action, int client, int choice)
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
				switch(choice)
				{
					case 0:
					{
						VotedFor[client] = 0;
					}
					default:
					{
						VotedFor[client] = 1 + ((choice - 1) % Voting.Length);
						VotedAllIn[client] = choice > Voting.Length;
					}
				}
				
				BetWar_CallVote(client, true);
			}
			else
			{
				Store_Menu(client);
			}
		}
	}
	return 0;
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

		int time = RoundFloat(VoteEndTime - GetGameTime());

		SetGlobalTransTarget(LANG_SERVER);
		char buffer[256];

		if(top[0] != -1)
		{
			Vote vote;
			Voting.GetArray(top[0], vote);

			if(time < 8 && time > 0)
			{
				FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left", count, total, time);
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, time, vote.Name, votes[top[0]]);

				for(int i = 1; i < sizeof(top); i++)
				{
					if(top[i] != -1)
					{
						Voting.GetArray(top[i], vote);

						Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
					}
				}
			}
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left", count, total, time);
		}

		PrintHintTextToAll(buffer);
	}
	else
	{
		PrintHintTextToAll("No Vote, %ds left", RoundFloat(VoteEndTime - GetGameTime()));
	}
}

void BetWar_StartSetup()	// Waves_RoundStart()
{
	BetWar_RoundEnd();

	float time = 30.0;
	
	VoteEndTime = GetGameTime() + time;

	delete ProgressTimer;
	ProgressTimer = CreateTimer(time, BetWar_ReadyTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

static Action BetWar_ReadyTimer(Handle timer)
{
	ProgressTimer = CreateTimer(1.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	Waves_SetReadyStatus(1);
	
	return Plugin_Continue;
}

void BetWar_RoundEnd()
{
	delete Voting;
	delete ProgressTimer;
	GameState = State_Setup;
	Zero(BetMoney);
	CurrentBetRound = 0;
}

public Action BetWar_ProgressTimer(Handle timer)
{
	ProgressTimer = null;
	
	switch(GameState)
	{
		case State_Trans:
		{
			BetWar_Progress();
			return Plugin_Stop;
		}
		case State_Vote:
		{
			DisplayHintVote();

			if(RoundFloat(VoteEndTime - GetGameTime()) < 1)
				delete Voting;
			
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
					FreezeNpcInTime(entity, Voting ? 1.5 : 0.1, true);
			}

			if(!Voting)
			{
				BetWar_Progress();
				return Plugin_Stop;
			}
		}
		case State_Stage:
		{
			float suddenDeath = GetGameTime() - VoteEndTime - 25.0;

			int winner = -1;

			if(suddenDeath < 64.0)
			{
				for(int i; i < i_MaxcountNpcTotal; i++)
				{
					int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
					if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
					{
						int team = GetTeam(entity);

						if(suddenDeath > 8.0)
							f_AttackSpeedNpcIncrease[entity] = 8.0 / suddenDeath;
						
						if(suddenDeath > 32.0)
							SDKHooks_TakeDamage(entity, 0, 0, ReturnEntityMaxHealth(entity) * 0.03, DMG_TRUEDAMAGE, _, {0.1,0.1,0.1});
						
						if(winner == -1)
						{
							winner = team;
						}
						else if(winner != team)
						{
							winner = -2;
							break;
						}
					}
				}
			}
			
			if(winner != -2)
			{
				BetWar_Progress(winner);
				return Plugin_Stop;
			}

			ProgressTimer = CreateTimer(0.2, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Stop;
		}
		default:
		{
			if(!Voting && GameRules_GetRoundState() == RoundState_ZombieRiot)
			{
				if(CvarNoRoundStart.BoolValue)
				{
					PrintToChatAll("zr_noroundstart is enabled");
				}
				else
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client) && GetClientTeam(client) == 2 && !IsFakeClient(client))
						{
							BetWar_Progress();
							return Plugin_Stop;
						}
					}
				}
			}
		}
	}

	ProgressTimer = CreateTimer(1.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

void BetWar_Progress(int winner = -1)
{
	switch(GameState)
	{
		case State_Setup:
		{
			Zero(BetMoney);
			CurrentCash = 0;

			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2)
				{
					BetMoney[client] = 1000;
					CashSpent[client] = -1000;
					SetEntProp(client, Prop_Send, "m_nCurrency", BetMoney[client]);
				}
			}

			BackgroundMusic.CopyTo(BGMusicSpecial1);
			
			GameState = State_Trans;
			delete ProgressTimer;
			ProgressTimer = CreateTimer(0.5, BetWar_RemoveNPCs, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		case State_Trans:
		{
			if(CurrentBetRound >= MaxBetRound)
			{
				delete WinMenuPanel;
				Menu menu = new Menu(BetWarBlankPanel);

				int count;
				int[] client = new int[MaxClients];
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && GetClientTeam(i) == 2)
					{
						client[count++] = i;
					}
				}

				SortCustom1D(client, count, BetWarSorting);

				int matchPlace, matchCash;

				char buffer[64];
				for(int i; i < count; i++)
				{
					if(matchCash != BetMoney[client[i]])
					{
						matchCash = BetMoney[client[i]];
						matchPlace = i + 1;
					}

					if(BetMoney[client[i]] > 99)
					{
						Format(buffer, sizeof(buffer), "| #%d %N %d", matchPlace, client[i], BetMoney[client[i]]);
					}
					else
					{
						Format(buffer, sizeof(buffer), "| #%d %N OUT!", matchPlace, client[i]);
					}

					menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
				}

				menu.ExitButton = false;
				
				for(int i; i < count; i++)
				{
					menu.SetTitle("GAME OVER!\n \nYou got %d cash!\n ", BetMoney[client[i]]);
					menu.Display(client[i], MENU_TIME_FOREVER);
				}

				WinMenuPanel = menu;

				ForcePlayerWin();
			}
			else
			{
				bool spawnNew = true;

				for(int i; i < i_MaxcountNpcTotal; i++)
				{
					int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
					if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
					{
						spawnNew = false;
						FreezeNpcInTime(entity, 5.0, true);
					}
				}

				if(spawnNew)
				{
					SetupBetWaves();

					VoteEndTime = GetGameTime() + 8.0;

					delete ProgressTimer;
					ProgressTimer = CreateTimer(3.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					Zero(VotedFor);
					VoteEndTime = GetGameTime() + 5.0;
					f_DelaySpawnsForVariousReasons = VoteEndTime;
					delete WinMenuPanel;
					
					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && GetClientTeam(client) == 2)
						{
							ClientCommand(client, "playgamesound ui/duel_challenge.wav");
							BetWar_CallVote(client, true);
						}
					}
					
					GameState = State_Vote;
					delete ProgressTimer;
					ProgressTimer = CreateTimer(1.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		case State_Vote:
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && VotedFor[client])
				{
					ClientCommand(client, "playgamesound ui/duel_score_behind.wav");
				}
			}
			
			GameState = State_Stage;
			delete ProgressTimer;
			ProgressTimer = CreateTimer(5.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		case State_Stage:
		{
			Waves_ClearWaveCurrentSpawningEnemies();

			int won = -1;
			switch(winner)
			{
				case 3:
					won = 0;
				
				case 4:
					won = 1;
			}

			int[] gain = new int[MaxClients+1];

			if(winner > 0)
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					gain[client] = 0;

					if(IsClientInGame(client) && BetMoney[client] > 99 && VotedFor[client])
					{
						int team = (VotedFor[client] - 1) % 2;
						if(team == won)
						{
							gain[client] += CurrentBet();
							if(VotedAllIn[client])
								gain[client] *= 2;
							
							CPrintToChatAll("{green}%t", "Cash Gained This Wave", gain[client]);
							ClientCommand(client, "playgamesound ui/duel_challenge_accepted_with_restriction.wav");
						}
						else
						{
							gain[client] -= CurrentBet();
							if(VotedAllIn[client])
								gain[client] = -BetMoney[client];
							
							CPrintToChatAll("{red}Lost %d cash this wave!", -gain[client]);
							ClientCommand(client, "playgamesound ui/duel_challenge_rejected_with_restriction.wav");
						}
						
						BetMoney[client] += gain[client];
						if(BetMoney[client] < 100)
						{
							BetMoney[client] = CurrentBetRound;
							CashSpent[client] = 0;
						}
						else
						{
							CashSpent[client] = -BetMoney[client];
						}
						
						SetEntProp(client, Prop_Send, "m_nCurrency", -CashSpent[client]);
					}
				}
			}
			else
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					gain[client] = 0;
				}
			}

			Panel panel = new Panel();
			
			SetGlobalTransTarget(LANG_SERVER);

			static const char TeamText[][] = { "NOBODY", "BLU", "RED" };
			char buffer[64];
			
			FormatEx(buffer, sizeof(buffer), "%s WON", TeamText[won + 1]);
			panel.DrawText(buffer);
			panel.DrawText(" ");
			FormatEx(buffer, sizeof(buffer), "Round %d Results", CurrentBetRound + 1);
			panel.DrawText(buffer);
			panel.DrawText(" ");

			int count;
			int[] client = new int[MaxClients];
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && GetClientTeam(i) == 2)
				{
					client[count++] = i;
				}
			}

			SortCustom1D(client, count, BetWarSorting);

			int matchPlace, matchCash;

			for(int i; i < count; i++)
			{
				if(matchCash != BetMoney[client[i]])
				{
					matchCash = BetMoney[client[i]];
					matchPlace = i + 1;
				}

				if(BetMoney[client[i]] > 99)
				{
					Format(buffer, sizeof(buffer), "#%d %N (%s%d) %d", matchPlace, client[i], gain[client[i]] < 0 ? "" : "+", gain[client[i]], BetMoney[client[i]]);
				}
				else
				{
					Format(buffer, sizeof(buffer), "#%d %N (%s%d) OUT!", matchPlace, client[i], gain[client[i]] < 0 ? "" : "+", gain[client[i]]);
				}

				panel.DrawText(buffer);
			}
			
			for(int i; i < count; i++)
			{
				panel.Send(client[i], BetWarBlankPanel, MENU_TIME_FOREVER);
			}

			delete panel;

			if(matchCash < 100)
			{
				ForcePlayerLoss(false);
			}
			else
			{
				GameState = State_Trans;
				delete ProgressTimer;
				ProgressTimer = CreateTimer(4.0, BetWar_RemoveNPCs, _, TIMER_FLAG_NO_MAPCHANGE);
				CurrentBetRound++;
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

static Action BetWar_RemoveNPCs(Handle timer)
{
	bool found;

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			SmiteNpcToDeath(entity);
			found = true;
		}
	}

	if(found)
	{
		ProgressTimer = CreateTimer(1.0, BetWar_RemoveNPCs, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		ProgressTimer = CreateTimer(1.0, BetWar_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		WaveEndLogicExtra();
	}
	
	return Plugin_Continue;
}

static int BetWarSorting(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(BetMoney[elem1] > BetMoney[elem2])
		return -1;
	
	if(BetMoney[elem1] < BetMoney[elem2])
		return 1;
	
	return (elem1 > elem2) ? 1 : -1;
}

static int BetWarBlankPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return 0;
}

bool BetWar_ShowStatus(int client)
{
	if(BetWar_Mode())
	{
		switch(GameState)
		{
			case State_Vote:
			{
				if(Voting && Voting.Length > 1)
				{
					Vote vote;

					Voting.GetArray(0, vote);
					SetHudTextParams(0.0, -1.0, 0.11, 55, 55, 255, 255);
					ShowSyncHudText(client, SyncHud_WandMana, vote.Config);

					Voting.GetArray(1, vote);
					SetHudTextParams(1.0, -1.0, 0.11, 255, 55, 55, 255);
					ShowSyncHudText(client, SyncHud_ArmorCounter, vote.Config);
				}
			}
			case State_Stage:
			{
				char buffer[2][256];

				for(int target = 1; target <= MaxClients; target++)
				{
					if(IsClientInGame(target) && VotedFor[target])
					{
						int team = (VotedFor[target] - 1) % 2;

						Format(buffer[team], sizeof(buffer[]), "%s%N%s\n%s", (team == 1 && target == client) ? "--> " : "", target, (team == 0 && target == client) ? " <--" : "", buffer[team]);
					}
				}

				SetHudTextParams(0.0, -1.0, 0.11, 55, 55, 255, 255);
				ShowSyncHudText(client, SyncHud_WandMana, buffer[0]);

				SetHudTextParams(1.0, -1.0, 0.11, 255, 55, 55, 255);
				ShowSyncHudText(client, SyncHud_ArmorCounter, buffer[1]);
			}
		}

		return true;
	}

	return false;
}

static void SetupBetWaves()
{
	delete Voting;
	Voting = new ArrayList(sizeof(Vote));

	ArrayList list = Waves_GetRoundsArrayList();

	Round round;
	list.GetArray(list.Length - 1, round);
	int length = round.Waves.Length;

	float totalBudget = 1.2 + ((CurrentBetRound == 9 ? 2.0 : GetRandomFloat(1.0, 2.0)) * (CurrentBetRound * 0.25));
	totalBudget *= 2.0;
	float totalCount = 1.0 + (CurrentBetRound / 4.4);
	if(totalCount > 2.9)
		totalCount = 2.9;
	
	float teamBudget[2];
	int teamCount[2];
	for(int i; i < 2; i++)
	{
		teamBudget[i] = totalBudget * GetRandomFloat(0.9, 1.1);
		teamCount[i] = RoundToFloor(totalCount + GetURandomFloat());
	}

	// Balance out budget if other team got more enemy count
	for(int i; i < 2; i++)
	{
		if(teamCount[i ? 0 : 1] > teamCount[i ? 1 : 0])
			teamBudget[i ? 0 : 1] /= float(teamCount[i ? 0 : 1]) / float(teamCount[i ? 1 : 0]);
	}

	SetGlobalTransTarget(LANG_SERVER);

	Vote vote[2];
	char buffer[64];

	int fails;
	
	Wave wave;
	for(int i; i < (teamCount[0] + teamCount[1]); i++)
	{
		int choosen = GetURandomInt() % length;
		round.Waves.GetArray(choosen, wave);
		
		int team = i >= teamCount[0];

		float budgetSpent = teamBudget[team];

		if((team == 0 && (i + 1) < teamCount[0]) ||
		   (team == 1 && (i + 1) < (teamCount[0] + teamCount[1])))
		{
			// Only spend some of the budget, save some for the next enemy group
			budgetSpent *= GetRandomFloat(0.35, 0.65);
		}

		// Too expensive of an enemy
		if(wave.Delay > budgetSpent)
		{
			if(fails < (wave.Count > 1 ? 20 : 10))
			{
				i--;
				fails++;
				continue;
			}
		}

		teamBudget[team] -= budgetSpent;
		
		float multi = budgetSpent / wave.Delay;
		int count = RoundFloat(wave.Count * multi);
		if(count < 1)
			count = 1;
		
		if(wave.Count < 1)
			wave.EnemyData.Health = RoundFloat(wave.EnemyData.Health * multi);
		
		wave.EnemyData.Team = team ? 4 : 3;
		strcopy(wave.EnemyData.Spawn, 64, BetTeamSpawn[team]);
		wave.EnemyData.ExtraDamage *= 3.0;

		if(wave.EnemyData.CustomName[0])
		{
			FormatEx(buffer, sizeof(buffer), "%t x%d\n", wave.EnemyData.CustomName, count);
		}
		else
		{
			NPC_GetNameById(wave.EnemyData.Index, buffer, sizeof(buffer));
			Format(buffer, sizeof(buffer), "%t x%d\n", buffer, count);
		}

		StrCat(vote[team].Config, sizeof(vote[].Config), buffer);

		fails = 0;
		for(int b; b == 0 || b < count; b++)
		{
			Waves_AddNextEnemy(wave.EnemyData, true, 2 - i);
		}
	}
	
	strcopy(vote[0].Name, sizeof(vote[].Name), "BLU");
	strcopy(vote[1].Name, sizeof(vote[].Name), "RED");

	Voting.PushArray(vote[0]);
	Voting.PushArray(vote[1]);
}

static int CurrentBet()
{
	switch(CurrentBetRound)
	{
		case 0:
			return 200;
		
		case 1:
			return 240;
		
		case 2:
			return 300;
		
		case 3:
			return 400;
		
		case 4:
			return 550;
		
		case 5:
			return 800;
		
		case 6:
			return 1200;
		
		case 7:
			return 1800;
		
		case 8:
			return 3000;
		
		case 9:
			return 5000;
	}

	return (CurrentBetRound * 1000);
}

bool BetWar_PlayerRunCmd(int client, int &buttons, float vel[3])
{
	if(!BetWar_Mode() || !RTSCamera_InCamera(client))
		return false;
	
	buttons = 0;
	Zero(vel);
	return true;
}

bool BetWar_Started()	// Waves_Started()
{
	return GameState != State_Setup;
}

bool BetWar_UpdateMvMStats()
{
	return false;
}
