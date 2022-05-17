static const char WaveTypes[][][] =
{
	{ "Normal", "waves" },
	{ "Alternative Waves (Hard)", "waves_alt" },
	{ "Xeno Infection (Very Hard)", "waves_xeno" }
};

enum struct Enemy
{
	int Health;
	int Is_Boss;
	int Index;
	char Data[16];
}

enum struct Wave
{
	float Delay;
	int Intencity;
	
	int Count;
	Enemy EnemyData;
}

enum struct Round
{
	int Xp;
	int Cash;
	bool Custom_Refresh_Npc_Store;
	float Setup;
	ArrayList Waves;
}

static ArrayList Rounds;
static ArrayStack Enemies;
static Handle WaveTimer;
static float Cooldown;
static bool InSetup;
//static bool InFreeplay;
static int WaveIntencity;

static bool Gave_Ammo_Supply;
static bool DoneVote;
static int VotedFor[MAXTF2PLAYERS];

void Waves_PluginStart()
{
	RegAdminCmd("zr_setwave", Waves_SetWaveCmd, ADMFLAG_CHEATS);
	RegAdminCmd("zr_panzer", Waves_ForcePanzer, ADMFLAG_CHEATS);
}

bool Waves_InFreeplay()
{
	return CurrentRound >= Rounds.Length;
}

void Waves_MapStart()
{
	PrecacheSound("zombie_riot/panzer/siren.mp3", true);
}

public Action Waves_ForcePanzer(int client, int args)
{
	NPC_SpawnNext(false, true, true); //This will force spawn a panzer.
	return Plugin_Handled;
}

public Action Waves_SetWaveCmd(int client, int args)
{
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
	
	char buffer[12];
	GetCmdArgString(buffer, sizeof(buffer));
	CurrentRound = StringToInt(buffer);
	CurrentWave = -1;
	Waves_Progress();
	return Plugin_Handled;
}

bool Waves_CallVote(int client)
{
	if(!DoneVote && !VotedFor[client] && GameRules_GetProp("m_bInWaitingForPlayers", 1))
	{
		Menu menu = new Menu(Waves_CallVoteH);
		
		menu.SetTitle("Vote for the difficulty:\n ");
		
		menu.AddItem("", "No Vote");
		for(int i; i<sizeof(WaveTypes); i++)
		{
			menu.AddItem("", WaveTypes[i][0]);
		}
		
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
		return true;
	}
	return false;
}

public int Waves_CallVoteH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			VotedFor[client] = choice;
			if(VotedFor[client] == 0)
				VotedFor[client] = -1;
			
			Store_Menu(client);
		}
	}
	return 0;
}

void Waves_ConfigSetup(KeyValues map, bool start=true)
{
	if(Rounds)
		delete Rounds;
	
	Rounds = new ArrayList(sizeof(Round));
	
	if(Enemies)
		delete Enemies;
	
	Enemies = new ArrayStack(sizeof(Enemy));
	
	DoneVote = false;
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(kv.JumpToKey("Waves"))
		{
			DoneVote = true;
		}
		else
		{
			kv = null;
		}
	}

	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		zr_waveconfig.GetString(buffer, sizeof(buffer));
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);
		kv = new KeyValues("Waves");
		kv.ImportFromFile(buffer);
		RequestFrame(DeleteHandle, kv);
	}
	
	StartCash = kv.GetNum("cash");
	b_BlockPanzerInThisDifficulty = view_as<bool>(kv.GetNum("block_panzer"));
	b_SpecialGrigoriStore = view_as<bool>(kv.GetNum("grigori_special_shop_logic"));
	Enemy enemy;
	Round round;
	Wave wave;
	kv.GotoFirstSubKey();
	char plugin[64];
	do
	{
		round.Cash = kv.GetNum("cash");
		round.Custom_Refresh_Npc_Store = view_as<bool>(kv.GetNum("grigori_refresh_store"));
		round.Xp = kv.GetNum("xp");
		round.Setup = kv.GetFloat("setup");
		if(kv.GotoFirstSubKey())
		{
			round.Waves = new ArrayList(sizeof(Wave));
			do
			{
				if(kv.GetSectionName(buffer, sizeof(buffer)))
				{
					kv.GetString("plugin", plugin, sizeof(plugin));
					if(plugin[0])
					{
						wave.Delay = StringToFloat(buffer);
						wave.Count = kv.GetNum("count", 1);
						wave.Intencity = kv.GetNum("intencity");
						
						enemy.Index = StringToInt(plugin);
						if(!enemy.Index)
							enemy.Index = GetIndexByPluginName(plugin);
						
						enemy.Health = kv.GetNum("health");
						enemy.Is_Boss = kv.GetNum("is_boss");
						kv.GetString("data", enemy.Data, sizeof(enemy.Data));
						
						wave.EnemyData = enemy;
						round.Waves.PushArray(wave);
					}
				}
			} while(kv.GotoNextKey());
			
			kv.GoBack();
			Rounds.PushArray(round);
		}
	} while(kv.GotoNextKey());
	
	if(start)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)>1)
			{
				Waves_RoundStart();
				break;
			}
		}
	}
	
#if defined NormalRound
#else
	CurrentCash = 999999;
#endif
}

void Waves_RoundStart()
{
	if(!DoneVote && !GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		int votes[sizeof(WaveTypes)];
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				DoOverlay(client, "");
				if(VotedFor[client]>0 && GetClientTeam(client)>1)
				{
					votes[VotedFor[client]-1]++;
				}
			}
		}
		
		int highest;
		for(int i=1; i<sizeof(WaveTypes); i++)
		{
			if(votes[i] > votes[highest])
				highest = i;
		}
		if(votes[highest])
		{
			DoneVote = true;
			zr_waveconfig.SetString(WaveTypes[highest][1]);
			PrintToChatAll("Difficulty set to: %s", WaveTypes[highest][0]);
			Waves_ConfigSetup(null, false);
		}
	}
	
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
	
	Waves_RoundEnd();
	CurrentRound = 0;
	CurrentWave = -1;
	
	#if defined NormalRound
	
		#if defined FastStart
		CreateTimer(1.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		
		#else
		CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		
		#endif
	
	#endif
	/*
	char buffer[64];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			if(StrEqual(buffer, "base_boss"))
				RemoveEntity(i);
		}
	}
	*/
	//DONT. Breaks map base_boss.
	if(CurrentCash != StartCash)
	{
		Store_Reset();
		CurrentGame = GetTime();
		CurrentCash = StartCash;
		PrintToChatAll("Be sure to spend all your starting cash!");
		for(int client=1; client<=MaxClients; client++)
		{
			CurrentAmmo[client] = CurrentAmmo[0];
			if(IsClientInGame(client) && IsPlayerAlive(client))
				TF2_RegeneratePlayer(client);
		}
	}
}

void Waves_RoundEnd()
{
	InSetup = true;
//	InFreeplay = false;
	WaveIntencity = 0;
}

public Action Waves_RoundStartTimer(Handle timer)
{
	if(!GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		bool any_player_on = false;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			{
				any_player_on = true;
				
				if(Store_HasAnyItem(client))
				{
					Store_SaveLoadout(client, CookieLoadout);
				}
				else if(!Store_LoadLoadout(client, CookieLoadout))
				{
					Store_PutInServer(client);
				}
			}
		}
		if(any_player_on)
		{
			
			InSetup = false;
			Waves_Progress();
		}
		else
		{
			CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		
	}
	return Plugin_Continue;
}

float MultiGlobal = 0.25;

void Waves_Progress()
{
	if(InSetup)
		return;
	
	if(WaveTimer)
	{
		KillTimer(WaveTimer);
		WaveTimer = null;
	}
	
	Round round;
	Wave wave;
	int length = Rounds.Length-1;
	bool panzer_spawn = false;
	bool panzer_sound = false;
	static int panzer_chance;
	if(CurrentRound < length)
	{
		Rounds.GetArray(CurrentRound, round);
		if(++CurrentWave < round.Waves.Length)
		{
			round.Waves.GetArray(CurrentWave, wave);
			WaveIntencity = wave.Intencity;
			
			float multi = 0.0;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
					multi += 0.25;
					MultiGlobal = multi;
			}
			
			if(multi < 0.5)
				multi = 0.5;
			
			int count = RoundToFloor(float(wave.Count)*multi);
			if(count < 1)
				count = 1;
			
			if(count > 150)
				count = 150;
			
			Zombies_Currently_Still_Ongoing += count;
			
			
			int Is_a_boss;
						
			Is_a_boss = 0;
			
			BalanceDropMinimum(multi);
			
			Is_a_boss = wave.EnemyData.Is_Boss;
			
			if(Is_a_boss >= 1)
			{			
				float multi_health;
							
				multi_health = 0.25;
							
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
						multi_health += 0.12;
				}
	
				if(multi_health < 0.5)
					multi_health = 0.5;	
					
				int Tempomary_Health = RoundToCeil(float(wave.EnemyData.Health) * multi_health);
				wave.EnemyData.Health = Tempomary_Health;
			}
		
			for(int i; i<count; i++)
			{
				Enemies.PushArray(wave.EnemyData);
			}
			
			if(wave.Delay > 0.0)
				WaveTimer = CreateTimer(wave.Delay, Waves_ProgressTimer);
		}
		else
		{
			CurrentCash += round.Cash;
			PrintToChatAll("%t","Cash Gained This Wave", round.Cash);
			CurrentRound++;
			CurrentWave = -1;
			
			for(int client_Penalise=1; client_Penalise<=MaxClients; client_Penalise++)
			{
				if(IsClientInGame(client_Penalise))
				{
					if(GetClientTeam(client_Penalise)!=2)
					{
						PrintToChat(client_Penalise, "You have only gained 60%% due to not being in-game.");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.40);
					}
					else if (TeutonType[client_Penalise] == TEUTON_WAITING)
					{
						PrintToChat(client_Penalise, "You have only gained 70 %% due to being a non-player player, but still helping. (You are a Teutonic Knight!)");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.30);
					}
				}
			}
			
			Rounds.GetArray(CurrentRound, round);
			
			Zombies_Currently_Still_Ongoing = 0;
			
			if(CurrentRound == 15) //He should spawn at wave 16.
			{
				for(int client_Grigori=1; client_Grigori<=MaxClients; client_Grigori++)
				{
					if(IsClientInGame(client_Grigori) && GetClientTeam(client_Grigori)==2)
					{
						ClientCommand(client_Grigori, "playgamesound vo/ravenholm/yard_greetings.wav");
						SetHudTextParams(-1.0, -1.0, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client_Grigori);
						ShowSyncHudText(client_Grigori,  SyncHud_Notifaction, "Grigori Has been cured!\nYou can talk to him during setup times to get a 20%% Discount on random items!");		
					}
				}
				
				Store_RandomizeNPCStore();
				Spawn_Cured_Grigori();
			}
			if(!b_BlockPanzerInThisDifficulty)
			{
				if(CurrentRound == 11)
				{
					panzer_spawn = true;
					panzer_sound = true;
					panzer_chance = 10;
				}
				else if(CurrentRound > 11 && round.Setup <= 30.0)
				{
					bool chance = (panzer_chance == 10 ? false : !GetRandomInt(0, panzer_chance));
					panzer_spawn = chance;
					panzer_sound = chance;
					if(panzer_spawn)
					{
						panzer_chance = 10;
					}
					else
					{
						panzer_chance--;
					}
				}
			}
			else
			{
				panzer_spawn = false;
				panzer_sound = false;
			}
			
		//	if( 1 == 1)//	if(!LastMann || round.Setup > 0.0)
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						DoOverlay(client, "off");
						if(GetClientTeam(client)==2 && IsPlayerAlive(client))
						{
							GiveXP(client, round.Xp);
							if(round.Setup > 0.0)
							{
								PrintHintText(client, "Press %%+showscores%% to open the store");
								StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
							}
						}
					}
				}
				
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client)==2)
					{
						if(!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD)
						{
							DHook_RespawnPlayer(client);
						}
						else if(dieingstate[client] > 0)
						{
							dieingstate[client] = 0;
							Store_ApplyAttribs(client);
							TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
							int entity, i;
							while(TF2U_GetWearable(client, entity, i))
							{
								SetEntityRenderMode(entity, RENDER_NORMAL);
								SetEntityRenderColor(entity, 255, 255, 255, 255);
							}
							SetEntityRenderMode(client, RENDER_NORMAL);
							SetEntityRenderColor(client, 255, 255, 255, 255);
							SetEntityCollisionGroup(client, 5);
							if(!EscapeMode)
							{
								SetEntityHealth(client, 50);
								RequestFrame(SetHealthAfterRevive, client);
							}	
							else
							{
								SetEntityHealth(client, 150);
								RequestFrame(SetHealthAfterRevive, client);						
							}
						}
					}
				}
				
				Music_EndLastmann();
				CheckAlivePlayers();
			}
			if(round.Custom_Refresh_Npc_Store)
			{
				PrintToChatAll("%t", "Grigori Store Refresh");
				Store_RandomizeNPCStore(); // Refresh me !!!
			}
			if(CurrentRound == length)
			{
				Cooldown = round.Setup + 30.0;
				
				Store_RandomizeNPCStore();
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				int timer = CreateEntityByName("team_round_timer");
				DispatchKeyValue(timer, "show_in_hud", "1");
				DispatchSpawn(timer);
				
				SetVariantInt(RoundToCeil(Cooldown));
				AcceptEntityInput(timer, "SetTime");
				AcceptEntityInput(timer, "Resume");
				AcceptEntityInput(timer, "Enable");
				SetEntProp(timer, Prop_Send, "m_bAutoCountdown", false);
				
				GameRules_SetPropFloat("m_flStateTransitionTime", Cooldown);
				CreateTimer(Cooldown, Timer_RemoveEntity, EntIndexToEntRef(timer));
				
				Event event = CreateEvent("teamplay_update_timer", true);
				event.Fire();
				
				CreateTimer(Cooldown, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				int total = 0;
				int[] players = new int[MaxClients];
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i))
					{
						Music_Stop_All(i);
						players[total++] = i;
					}
				}
				cvarTimeScale.SetFloat(0.1);
				CreateTimer(0.5, SetTimeBack);
				
				EmitSoundToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			
				Menu menu = new Menu(Waves_FreeplayVote);
				menu.SetTitle("The Zombies have been defeated!\nGo into Freeplay..?\nFreeplay will play infinitly.\nThe further you go, the harder it gets.\n ");
				menu.AddItem("", "Yes");
				menu.AddItem("", "No");
				menu.ExitButton = false;
				
				menu.DisplayVote(players, total, 30);
			}
			else if(round.Setup > 0.0)
			{
				Cooldown = round.Setup+GetGameTime();
				
				Store_RandomizeNPCStore();
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				int timer = CreateEntityByName("team_round_timer");
				DispatchKeyValue(timer, "show_in_hud", "1");
				DispatchSpawn(timer);
				
				SetVariantInt(RoundToFloor(round.Setup));
				AcceptEntityInput(timer, "SetTime");
				AcceptEntityInput(timer, "Resume");
				AcceptEntityInput(timer, "Enable");
				SetEntProp(timer, Prop_Send, "m_bAutoCountdown", false);
				
				GameRules_SetPropFloat("m_flStateTransitionTime", Cooldown);
				CreateTimer(round.Setup, Timer_RemoveEntity, EntIndexToEntRef(timer));
				
				Event event = CreateEvent("teamplay_update_timer", true);
				event.Fire();
				
				CreateTimer(round.Setup, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				Waves_Progress();
				NPC_SpawnNext(false, panzer_spawn, panzer_sound);
				return;
			}
		}
		
		if(!EscapeMode)
			tf_bot_quota.IntValue = CurrentWave + 2;
	}
	else
	{
		Rounds.GetArray(length, round);
		if(++CurrentWave < 1)
		{
			float multi = 1.0 + ((CurrentRound-length) * 0.02);
			Rounds.GetArray(length, round);
			length = round.Waves.Length;
			int Max_Enemy_Get = 0;
			for(int i; i<length; i++)
			{
				//if(GetRandomInt(0, 1)) //This spwns too many
				if(GetRandomInt(0, 3) == 3 && Max_Enemy_Get <= 3) //Do not allow more then 3 different enemy types at once, or else freeplay just takes way too long and the RNG will cuck it.
				{
					Max_Enemy_Get += 1;
					round.Waves.GetArray(i, wave);
					int count = RoundToFloor(float(wave.Count) / GetRandomFloat(0.2, 1.3) * multi);
					wave.EnemyData.Health = (RoundToCeil(float(wave.EnemyData.Health) * float(CurrentRound) * multi * 1.35 * 3.0)); //removing /3 cus i want 3x the hp!!!
					//Double it, icant be bothered to go through all the configs and change every single number.
					for(int a; a<count; a++)
					{
						Enemies.PushArray(wave.EnemyData);
					}
				}
			}
			if(!b_BlockPanzerInThisDifficulty)
			{
				if(GetRandomInt(0, 1) == 1) //make him spawn way more often in freeplay.
				{
					panzer_spawn = true;
					NPC_SpawnNext(false, panzer_spawn, false);
					
					if(!EscapeMode)
						tf_bot_quota.IntValue = Max_Enemy_Get + 2;
				}
				else
				{
					panzer_spawn = false;
					NPC_SpawnNext(false, false, false);
					
					if(!EscapeMode)
						tf_bot_quota.IntValue = Max_Enemy_Get + 1;
				}
			}
			
			if(Enemies.Empty)
			{
				CurrentWave--;
				Waves_Progress();
				return;
			}
		}
		else
		{
			CurrentCash += round.Cash;
			PrintToChatAll("%t","Cash Gained This Wave", round.Cash);
			CurrentRound++;
			CurrentWave = -1;
			Rounds.GetArray(length, round);
		//	if( 1 == 1)//	if(!LastMann || round.Setup > 0.0)
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						DoOverlay(client, "off");
						if(IsPlayerAlive(client) && GetClientTeam(client)==2)
							GiveXP(client, round.Xp);
					}
				}
				
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client)==2)
					{
						if(!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD)
						{
							DHook_RespawnPlayer(client);
						}
						else if(dieingstate[client] > 0)
						{
							dieingstate[client] = 0;
							Store_ApplyAttribs(client);
							TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
							int entity, i;
							while(TF2U_GetWearable(client, entity, i))
							{
								SetEntityRenderMode(entity, RENDER_NORMAL);
								SetEntityRenderColor(entity, 255, 255, 255, 255);
							}
							SetEntityRenderMode(client, RENDER_NORMAL);
							SetEntityRenderColor(client, 255, 255, 255, 255);
							SetEntityCollisionGroup(client, 5);
							if(!EscapeMode)
							{
								SetEntityHealth(client, 50);
								RequestFrame(SetHealthAfterRevive, client);
							}	
							else
							{
								SetEntityHealth(client, 150);
								RequestFrame(SetHealthAfterRevive, client);						
							}
						}
					}
				}
				
				Music_EndLastmann();
				CheckAlivePlayers();
			}
			if((CurrentRound % 5) == 4)
			{
				Cooldown = round.Setup + 30.0;
				
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				int timer = CreateEntityByName("team_round_timer");
				DispatchKeyValue(timer, "show_in_hud", "1");
				DispatchSpawn(timer);
				
				SetVariantInt(RoundToCeil(Cooldown));
				AcceptEntityInput(timer, "SetTime");
				AcceptEntityInput(timer, "Resume");
				AcceptEntityInput(timer, "Enable");
				SetEntProp(timer, Prop_Send, "m_bAutoCountdown", false);
				
				GameRules_SetPropFloat("m_flStateTransitionTime", Cooldown);
				CreateTimer(Cooldown, Timer_RemoveEntity, EntIndexToEntRef(timer));
				
				Event event = CreateEvent("teamplay_update_timer", true);
				event.Fire();
				
				CreateTimer(Cooldown, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				Menu menu = new Menu(Waves_FreeplayVote);
				menu.SetTitle("Continue Freeplay..?\nThis will be asked every 5 waves.\n ");
				menu.AddItem("", "Yes");
				menu.AddItem("", "No");
				menu.ExitButton = false;
				
				int total = 0;
				int[] players = new int[MaxClients];
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i)==2)
						players[total++] = i;
				}
				
				menu.DisplayVote(players, total, 30);
			}
			else
			{
				Waves_Progress();
				return;
			}
		}
	}
	if(CurrentRound == 0)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2)
			{
				Ammo_Count_Ready[client] = 8;
				CashSpent[client] = StartCash;
			}
		}
	}
	if(CurrentWave == 0)
	{
		Renable_Powerups();
		CheckIfAloneOnServer();
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2)
			{
				Ammo_Count_Ready[client] += 1;
			}
		}
	}
//	else if (IsEven(CurrentRound+1)) Is even doesnt even work, just do a global bool of every 2nd round, should be good. And probably work out even better.
	else if (!Gave_Ammo_Supply)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2)
			{
				Ammo_Count_Ready[client] += 1;
			}
		}
		Gave_Ammo_Supply = true;
	}	
	else
	{
		Gave_Ammo_Supply = false;	
	}
	PrintToChatAll("Wave: %d - %d", CurrentRound+1, CurrentWave+1);
	
}

public int Waves_FreeplayVote(Menu menu, MenuAction action, int item, int param2)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_VoteEnd:
		{
			if(item)
			{
				int entity = CreateEntityByName("game_round_win"); 
				DispatchKeyValue(entity, "force_map_reset", "1");
				SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Red);
				DispatchSpawn(entity);
				AcceptEntityInput(entity, "RoundWin");
			}
		}
	}
	return 0;
}
				
int Waves_GetNextEnemy(int &health, int &isBoss, char[] data, int length)
{
	if(Enemies.Empty)
		return 0;
	
	Enemy enemy;
	Enemies.PopArray(enemy);
	
	isBoss = enemy.Is_Boss;
	strcopy(data, length, enemy.Data);
	health = enemy.Health;
	return enemy.Index;
}

bool Waves_Started()
{
	return CurrentWave != -1;
}

int Waves_GetRound()
{
	return CurrentRound;
}

int Waves_GetIntencity()
{
	return WaveIntencity;
}

public Action Waves_ProgressTimer(Handle timer)
{
	WaveTimer = null;
	Waves_Progress();
	return Plugin_Continue;
}