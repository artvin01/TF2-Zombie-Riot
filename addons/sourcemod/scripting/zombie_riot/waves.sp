enum struct Enemy
{
	int Health;
	int Is_Boss;
	int Is_Outlined;
	int Is_Health_Scaled;
	int Does_Not_Scale;
	int Is_Immune_To_Nuke;
	bool Is_Static;
	bool Friendly;
	int Index;
	int Credits;
	char Data[16];
}

enum struct MiniBoss
{
	int Index;
	int Powerup;
	float Delay;
	float HealthMulti;
	char Sound[128];
	char Icon[128];
	char Text_1[128];
	char Text_2[128];
	char Text_3[128];
	char Text_4[128];
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
	int medival_difficulty;
	
	char music_round_1[255];
	int music_duration_1;
	char music_round_2[255];
	int music_duration_2;
	float Setup;
	ArrayList Waves;
}

enum struct Vote
{
	char Name[64];
	char Config[64];
	int Level;
}

static ArrayList Rounds;
static ArrayList Voting;
static ArrayList MiniBosses;
static ArrayStack Enemies;
static Handle WaveTimer;
static float Cooldown;
static bool InSetup;
//static bool InFreeplay;
static int WaveIntencity;

static bool Gave_Ammo_Supply;
static int VotedFor[MAXTF2PLAYERS];

static char LastWaveWas[64];

void Waves_PluginStart()
{
	RegAdminCmd("zr_setwave", Waves_SetWaveCmd, ADMFLAG_CHEATS);
	RegAdminCmd("zr_panzer", Waves_ForcePanzer, ADMFLAG_CHEATS);
}

bool Waves_InFreeplay()
{
	return (Rounds && CurrentRound >= Rounds.Length);
}

bool Waves_InSetup()
{
	return (InSetup || !Waves_Started());
}

void Waves_MapStart()
{
	PrecacheSound("zombie_riot/panzer/siren.mp3", true);
	PrecacheSound("zombie_riot/sawrunner/iliveinyourwalls.mp3", true);
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
	if(Voting && !VotedFor[client] && GameRules_GetProp("m_bInWaitingForPlayers", 1))
	{
		Menu menu = new Menu(Waves_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t:\n ","Vote for the difficulty");
		
		menu.AddItem("", "No Vote");
		
		Vote vote;
		int length = Voting.Length;
		for(int i; i<length; i++)
		{
			Voting.GetArray(i, vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);
			
			if(Level[client] < vote.Level)
			{
				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, Level[client]);
				menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
			}
			else
			{
				menu.AddItem(vote.Config, vote.Name);
			}
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

void OnMapEndWaves()
{
	if(Voting)
	{
		delete Voting;
	}
	Zero(VotedFor);	
}

void Waves_SetupVote(KeyValues map)
{
	Cooldown = 0.0;
	
	if(Voting)
	{
		delete Voting;
		Voting = null;
	}
	
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(kv.JumpToKey("Waves"))
		{
			Waves_SetupWaves(kv, true);
			return;
		}
		else if(!kv.JumpToKey("Setup"))
		{
			kv = null;
		}
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		zr_voteconfig.GetString(buffer, sizeof(buffer));
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);
		kv = new KeyValues("Setup");
		kv.ImportFromFile(buffer);
		RequestFrame(DeleteHandle, kv);
	}
	
	StartCash = kv.GetNum("cash");
	if(!kv.JumpToKey("Waves"))
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "waves")
		kv = new KeyValues("Waves");
		kv.ImportFromFile(buffer);
		Waves_SetupWaves(kv, true);
		delete kv;
		return;
	}
	
	Voting = new ArrayList(sizeof(Vote));
	
	Vote vote;
	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(vote.Name, sizeof(vote.Name));
		kv.GetString("file", vote.Config, sizeof(vote.Config));
		vote.Level = kv.GetNum("level");
		Voting.PushArray(vote);
	} while(kv.GotoNextKey());
	
	if(LastWaveWas[0])
	{
		int length = Voting.Length;
		if(length > 2)
		{
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				if(StrEqual(vote.Config, LastWaveWas))
				{
					if(vote.Level > 0)
						Voting.Erase(i);
					
					break;
				}
			}
		}
	}
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)>1)
		{
			Waves_RoundStart();
			break;
		}
	}
}

void Waves_SetupMiniBosses(KeyValues map)
{
	if(MiniBosses)
	{
		delete MiniBosses;
		MiniBosses = null;
	}
	
	if(CvarNoSpecialZombieSpawn.BoolValue)
		return;
	
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("MiniBoss"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		zr_minibossconfig.GetString(buffer, sizeof(buffer));
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);
		kv = new KeyValues("MiniBoss");
		kv.ImportFromFile(buffer);
		RequestFrame(DeleteHandle, kv);
	}
	
	if(kv.GotoFirstSubKey())
	{
		MiniBoss boss;
		MiniBosses = new ArrayList(sizeof(MiniBoss));
		
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			
			boss.Index = StringToInt(buffer);
			if(!boss.Index)
				boss.Index = GetIndexByPluginName(buffer);
			
			boss.Powerup = kv.GetNum("powerup");
			boss.Delay = kv.GetFloat("delay", 2.0);
			boss.HealthMulti = kv.GetFloat("healthmulti");
			kv.GetString("sound", boss.Sound, sizeof(boss.Sound));
			if(boss.Sound[0])
				PrecacheSound(boss.Sound);
				
			kv.GetString("icon", boss.Icon, sizeof(boss.Icon));
			
			kv.GetString("text_1", boss.Text_1, sizeof(boss.Text_1));
			kv.GetString("text_2", boss.Text_2, sizeof(boss.Text_2));
			kv.GetString("text_3", boss.Text_3, sizeof(boss.Text_3));
			
			MiniBosses.PushArray(boss);
		} while(kv.GotoNextKey());
	}
}

bool Waves_GetMiniBoss(MiniBoss boss)
{
	if(!MiniBosses)
		return false;
	
	MiniBosses.GetArray(GetURandomInt() % MiniBosses.Length, boss);
	return true;
}

void Waves_SetupWaves(KeyValues kv, bool start)
{
	Round round;
	if(Rounds)
	{
		int length = Rounds.Length;
		for(int i; i < length; i++)
		{
			Rounds.GetArray(i, round);
			delete round.Waves;
		}
		delete Rounds;
	}
	
	Rounds = new ArrayList(sizeof(Round));
	
	if(Enemies)
		delete Enemies;
	
	Enemies = new ArrayStack(sizeof(Enemy));
	
	b_SpecialGrigoriStore = view_as<bool>(kv.GetNum("grigori_special_shop_logic"));
	f_ExtraDropChanceRarity = kv.GetFloat("gift_drop_chance_multiplier");
	
	if(f_ExtraDropChanceRarity < 0.01) //Incase some idiot forgot
	{
		f_ExtraDropChanceRarity = 1.0;
	}
	Enemy enemy;
	Wave wave;
	kv.GotoFirstSubKey();
	char buffer[64], plugin[64];
	do
	{
		round.Cash = kv.GetNum("cash");
		round.Custom_Refresh_Npc_Store = view_as<bool>(kv.GetNum("grigori_refresh_store"));
		round.medival_difficulty = kv.GetNum("medival_research_level");
		round.Xp = kv.GetNum("xp");
		round.Setup = kv.GetFloat("setup");
	
		kv.GetString("music_track_1", round.music_round_1, sizeof(round.music_round_1));
		round.music_duration_1 = kv.GetNum("music_seconds_1");
		
		kv.GetString("music_track_2", round.music_round_2, sizeof(round.music_round_2));
		round.music_duration_2 = kv.GetNum("music_seconds_2");
		
		if(round.music_round_1[0])
			PrecacheSound(round.music_round_1, true);
		
		if(round.music_round_2[0])
			PrecacheSound(round.music_round_2, true);

		round.Waves = new ArrayList(sizeof(Wave));
		if(kv.GotoFirstSubKey())
		{
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
						enemy.Does_Not_Scale = kv.GetNum("does_not_scale");
						enemy.Is_Outlined = kv.GetNum("is_outlined");
						enemy.Is_Health_Scaled = kv.GetNum("is_health_scaling");
						enemy.Is_Immune_To_Nuke = kv.GetNum("is_immune_to_nuke");
						enemy.Is_Static = view_as<bool>(kv.GetNum("is_static"));
						enemy.Friendly = view_as<bool>(kv.GetNum("friendly"));
						enemy.Credits = kv.GetNum("cash");
						
						kv.GetString("data", enemy.Data, sizeof(enemy.Data));
						
						wave.EnemyData = enemy;
						round.Waves.PushArray(wave);
					}
				}
			} while(kv.GotoNextKey());
			
			kv.GoBack();
		}
		
		Rounds.PushArray(round);
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
}

void Waves_RoundStart()
{
	if(Voting && !GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		int length = Voting.Length;
		if(length)
		{
			int[] votes = new int[length];
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					DoOverlay(client, "");
					if(VotedFor[client]>0 && GetClientTeam(client)==2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}
			
			int highest;
			for(int i=1; i<length; i++)
			{
				if(votes[i] > votes[highest])
					highest = i;
			}
			
			//if(votes[highest])
			{
				Vote vote;
				Voting.GetArray(highest, vote);
				
				delete Voting;
				Voting = null;
				
				strcopy(LastWaveWas, sizeof(LastWaveWas), vote.Config);
				PrintToChatAll("%t: %s","Difficulty set to", vote.Name);
				
				Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "FireUser%d", highest + 1);
				ExcuteRelay("zr_waveselected", WhatDifficultySetting);
				
				strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), vote.Name);
				
				char buffer[PLATFORM_MAX_PATH];
				BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
				KeyValues kv = new KeyValues("Waves");
				kv.ImportFromFile(buffer);
				Waves_SetupWaves(kv, false);
				delete kv;
			}
		}
	}
	
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
	
	Waves_RoundEnd();
	
	CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
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
		PrintToChatAll("%t", "Be sure to spend all your starting cash!");
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
	CurrentRound = 0;
	CurrentWave = -1;
	Medival_Difficulty_Level = 0.0; //make sure to set it to 0 othrerwise waves will become impossible
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
				
				if(!Store_HasAnyItem(client))
					Store_PutInServer(client);
			}
		}
		if(any_player_on && !CvarNoRoundStart.BoolValue)
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

/*void Waves_ClearWaves()
{
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
}*/

void Waves_Progress()
{
	if(InSetup || !Rounds || CvarNoRoundStart.BoolValue)
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
			
			float multi = 0.05;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
					multi += 0.25;
			}
			
			if(multi < 0.5)
				multi = 0.5;
			
			MultiGlobal = multi;
			
			int Is_a_boss = wave.EnemyData.Is_Boss;
			bool ScaleWithHpMore = wave.Count == 0;
			
			if(Is_a_boss == 2)
			{
				Raidboss_Clean_Everyone();
				ReviveAll();
				Music_EndLastmann();
				CheckAlivePlayers();
			}
			
			int count = wave.Count;
			
			if(wave.EnemyData.Does_Not_Scale == 0)
			{
				count = RoundToNearest(float(count)*multi);
			}
			
			if(count < 1)
				count = 1;
				
			
			if(count > 150)
				count = 150;
			
			Zombies_Currently_Still_Ongoing += count;
			
			
			int Is_Health_Scaling;
			
			Is_Health_Scaling = 0;
			
			BalanceDropMinimum(multi);
			
			Is_Health_Scaling = wave.EnemyData.Is_Health_Scaled;
			
			if(Is_a_boss >= 1 || Is_Health_Scaling >= 1)
			{			
				float multi_health;
				
				
				if(ScaleWithHpMore)
				{
					multi_health = 0.01;
				}
				else
				{
					multi_health = 0.25;
				}
							
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
					{
						if(ScaleWithHpMore)
						{
							multi_health += 0.20;
						}
						else
						{
							multi_health += 0.15;
						}
					}
				}
				
				if(!ScaleWithHpMore)
				{
					if(multi_health < 0.5)
						multi_health = 0.5;	
				}
				
				float amount_of_people = float(CountPlayersOnRed());
				
				if(ScaleWithHpMore)
				{
					amount_of_people *= 0.14;
					
					if(amount_of_people < 1.0)
						amount_of_people = 1.0;
				}
				else
				{
					amount_of_people *= 0.1;
				
					if(amount_of_people < 1.0)
						amount_of_people = 1.0;				
					
				}
					
				multi_health *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
					
				int Tempomary_Health = RoundToNearest(float(wave.EnemyData.Health) * multi_health);
				wave.EnemyData.Health = Tempomary_Health;
			}
		
			for(int i; i<count; i++)
			{
				Enemies.PushArray(wave.EnemyData);
			}
			
			if(wave.Delay > 0.0)
				WaveTimer = CreateTimer(wave.Delay * MultiGlobal, Waves_ProgressTimer);
		}
		else
		{
			int extra = Building_GetCashOnWave(round.Cash);
			CurrentCash += round.Cash;
			if(round.Cash)
				CPrintToChatAll("{green}%t{default}","Cash Gained This Wave", round.Cash);
				
			
			CurrentRound++;
			CurrentWave = -1;
			
			delete Enemies;
			Enemies = new ArrayStack(sizeof(Enemy));
			
			for(int client_Penalise=1; client_Penalise<=MaxClients; client_Penalise++)
			{
				if(IsClientInGame(client_Penalise))
				{
					if(extra)
					{
						CashSpent[client_Penalise] -= extra;
						CashRecievedNonWave[client_Penalise] += extra;
						CPrintToChat(client_Penalise, "{green}%t{default}","Cash Gained This Wave Village", extra);
					}
					
					if(GetClientTeam(client_Penalise)!=2)
					{
						SetGlobalTransTarget(client_Penalise);
						PrintToChat(client_Penalise, "%t", "You have only gained 60%% due to not being in-game");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.40);
					}
					else if (TeutonType[client_Penalise] == TEUTON_WAITING)
					{
						SetGlobalTransTarget(client_Penalise);
						PrintToChat(client_Penalise, "%t", "You have only gained 70 %% due to being a non-player player, but still helping");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.30);
					}
				}
			}
			
			Rounds.GetArray(CurrentRound, round);
			
			//Loop through all the still alive enemies that are indexed!
			int Zombies_alive_still = 0;
			
			NPCData npc;
			for(int i=NPCList.Length-1; i>=0; i--)
			{
				NPCList.GetArray(i, npc);
				int npc_index = EntRefToEntIndex(npc.Ref);
				if(npc_index > MaxClients && IsValidEntity(npc_index))
				{
					if(GetEntProp(npc_index, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red) && !b_NpcHasDied[npc_index])
					{
						Zombies_alive_still += 1;
					}
				}
			}
			
			
		//	Zombies_Currently_Still_Ongoing -= 1; //one zombieis always still aliv
			
			
			if(Zombies_Currently_Still_Ongoing > 0 && (Zombies_Currently_Still_Ongoing - Zombies_alive_still) > 0)
			{
				for(int client_Penalise=1; client_Penalise<=MaxClients; client_Penalise++)
				{
					if(IsClientInGame(client_Penalise))	
					{
						CPrintToChat(client_Penalise, "{crimson}%i Zombies have been wasted...{default} you have lost money!", Zombies_Currently_Still_Ongoing - Zombies_alive_still);
					}
				}
			}
			
			Zombies_Currently_Still_Ongoing = 0;
			
			Zombies_Currently_Still_Ongoing = Zombies_alive_still;
			
			//Loop through all the still alive enemies that are indexed!
			
			if(CurrentRound == 4)
			{
				Citizen_SpawnAtPoint();
			}
			else if(CurrentRound == 15) //He should spawn at wave 16.
			{
				for(int client_Grigori=1; client_Grigori<=MaxClients; client_Grigori++)
				{
					if(IsClientInGame(client_Grigori) && GetClientTeam(client_Grigori)==2)
					{
						ClientCommand(client_Grigori, "playgamesound vo/ravenholm/yard_greetings.wav");
						SetHudTextParams(-1.0, -1.0, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client_Grigori);
						ShowSyncHudText(client_Grigori,  SyncHud_Notifaction, "%t", "Father Grigori Spawn");		
					}
				}
				
				Store_RandomizeNPCStore(false);
				Spawn_Cured_Grigori();
			}
			else if(CurrentRound == 11)
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
								SetGlobalTransTarget(client);
								PrintHintText(client, "%t","Press TAB To open the store");
								StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
							}
						}
					}
				}
				
				ReviveAll();
				Music_EndLastmann();
				CheckAlivePlayers();
			}
			if(round.Custom_Refresh_Npc_Store)
			{
				PrintToChatAll("%t", "Grigori Store Refresh");
				Store_RandomizeNPCStore(false); // Refresh me !!!
			}
			if(round.medival_difficulty != 0)
			{
			//	PrintToChatAll("%t", "Grigori Store Refresh");
				Medival_Wave_Difficulty_Riser(round.medival_difficulty); // Refresh me !!!
			}
			
			//MUSIC LOGIC
			
			bool RoundHasCustomMusic = false;
		
			if(char_MusicString1[0])
				RoundHasCustomMusic = true;
					
			if(char_MusicString2[0])
				RoundHasCustomMusic = true;
				
			if(RoundHasCustomMusic) //only do it when there was actually custom music previously
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						Music_Stop_All(client);
					}
				}	
			}
			//This should nullfy anyways if nothings in it
			FormatEx(char_MusicString1, sizeof(char_MusicString1), round.music_round_1);
			
			FormatEx(char_MusicString2, sizeof(char_MusicString2), round.music_round_2);

			i_MusicLength1 = round.music_duration_1;
			
			i_MusicLength2 = round.music_duration_2;
			
			if(round.Setup > 1.0)
			{
				if(char_MusicString1[0] || char_MusicString2[0])
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetMusicTimer(client, GetTime() + RoundToNearest(round.Setup));
						}
					}
				}
			}
			
			
			
			//MUSIC LOGIC
			if(CurrentRound == length)
			{
				Cooldown = round.Setup + 30.0;
				
				Store_RandomizeNPCStore(false);
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
						SendConVarValue(i, sv_cheats, "1");
						players[total++] = i;
					}
				}
				cvarTimeScale.SetFloat(0.1);
				CreateTimer(0.5, SetTimeBack);
				
				EmitSoundToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				
				FormatEx(char_MusicString1, sizeof(char_MusicString1), "");
			
				FormatEx(char_MusicString2, sizeof(char_MusicString2), "");
		
				i_MusicLength1 = 1;
					
				i_MusicLength2 = 1;
			
			
				Menu menu = new Menu(Waves_FreeplayVote);
				menu.SetTitle("%t","Victory Menu");
				menu.AddItem("", "Yes");
				menu.AddItem("", "No");
				menu.ExitButton = false;
				
				menu.DisplayVote(players, total, 30);
			}
			else if(round.Setup > 0.0)
			{
				Cooldown = round.Setup+GetGameTime();
				
				Store_RandomizeNPCStore(false);
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
		{
			int botscalculaton;
			
			if((CurrentWave + 2) > CvarMaxBotsForKillfeed.IntValue)
			{
				botscalculaton = CvarMaxBotsForKillfeed.IntValue;
			}
			else
			{
				botscalculaton = CurrentWave + 2;
			}
				
			tf_bot_quota.IntValue = botscalculaton;
		}
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
			if(GetRandomInt(0, 1) == 1) //make him spawn way more often in freeplay.
			{
				panzer_spawn = true;
				NPC_SpawnNext(false, panzer_spawn, false);
				
				if(!EscapeMode)
				{
					int botscalculaton;
					
					if((CurrentWave + 2) > CvarMaxBotsForKillfeed.IntValue)
					{
						botscalculaton = CvarMaxBotsForKillfeed.IntValue;
					}
					else
					{
						botscalculaton = CurrentWave + 2;
					}
						
					tf_bot_quota.IntValue = botscalculaton;
				}
			}
			else
			{
				panzer_spawn = false;
				NPC_SpawnNext(false, false, false);
				
				if(!EscapeMode)
				{
					int botscalculaton;
					
					if((CurrentWave + 2) > CvarMaxBotsForKillfeed.IntValue)
					{
						botscalculaton = CvarMaxBotsForKillfeed.IntValue;
					}
					else
					{
						botscalculaton = CurrentWave + 2;
					}
					
					tf_bot_quota.IntValue = botscalculaton;
				}
			}
			
			if(Enemies.Empty)
			{
				CurrentWave++;
				Waves_Progress();
				return;
			}
		}
		else
		{
			CurrentCash += round.Cash;
			if(round.Cash)
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
				
				ReviveAll();
				
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
				if(StartCash < 10000)
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
//	PrintToChatAll("Wave: %d - %d", CurrentRound+1, CurrentWave+1);
	
}

public void Medival_Wave_Difficulty_Riser(int difficulty)
{
	PrintToChatAll("%t", "Medival_Difficulty", difficulty);
	
	float difficulty_math = float(difficulty);
	
	difficulty_math *= -1.0;
	
	difficulty_math /= 10.0;
	
	difficulty_math += 1.0;
	
	if(difficulty_math < 0.1) //Just make sure that it doesnt go below.
	{
		difficulty_math = 0.1;
	}
	//invert the number and then just set the difficulty medival level to the % amount of damage resistance.
	//This means that you can go upto 100% dmg res but if youre retarded enough to do this then you might aswell have an unplayable experience.
	
	Medival_Difficulty_Level = difficulty_math; //More armor and damage taken.
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

bool Waves_GetNextEnemy(Enemy enemy)
{
	if(!Enemies || Enemies.Empty)
		return false;
	
	Enemies.PopArray(enemy);
	return true;
}

void Waves_AddNextEnemy(const Enemy enemy)
{
	if(Enemies)
		Enemies.PushArray(enemy);
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

float GetWaveSetupCooldown()
{
	return Cooldown;
}
public Action Waves_ProgressTimer(Handle timer)
{
	WaveTimer = null;
	Waves_Progress();
	return Plugin_Continue;
}
