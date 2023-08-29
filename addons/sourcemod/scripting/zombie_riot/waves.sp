#pragma semicolon 1
#pragma newdecls required

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
	float Credits;
	char Data[64];
	float ExtraMeleeRes;
	float ExtraRangedRes;
	float ExtraSpeed;
	float ExtraDamage;
	char Spawn[64];
}

enum struct MiniBoss
{
	int Index;
	int Powerup;
	float Delay;
	float HealthMulti;
	bool SoundCustom;
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
	
	char RelayName[64];
	char RelayFire[64];

	int Count;
	Enemy EnemyData;
}

enum struct Round
{
	int Xp;
	int Cash;
	bool MapSetupRelay;
	bool Custom_Refresh_Npc_Store;
	int medival_difficulty;
	
	char music_round_1[255];
	int music_duration_1;
	bool music_custom_1;
	char music_round_2[255];
	int music_duration_2;
	bool music_custom_2;
	char music_round_outro[255];
	bool music_custom_outro;
	char Message[255];
	bool SpawnGrigori;
	int GrigoriMaxSellsItems;
	float Setup;
	ArrayList Waves;
	
	char Skyname[64];
	bool FogChange;
	char FogBlend[32];
	char FogColor1[32];
	char FogColor2[32];
	float FogStart;
	float FogEnd;
	float FogDesnity;
}

enum struct Vote
{
	char Name[64];
	char Config[64];
	int Level;
	char Desc[256];
	char Append[16];
}

static ArrayList Rounds;
static ArrayList Voting;
static bool CanReVote;
static ArrayList MiniBosses;
static ArrayStack Enemies;
static Handle WaveTimer;
static float Cooldown;
static bool InSetup;
//static bool InFreeplay;

static ConVar CvarSkyName;
static char SkyNameRestore[64];
static int FogEntity = INVALID_ENT_REFERENCE;

static int Gave_Ammo_Supply;
static int VotedFor[MAXTF2PLAYERS];
static float VoteEndTime;

static char LastWaveWas[64];
static int WaveGiftItem;

void Waves_PluginStart()
{
	CvarSkyName = FindConVar("sv_skyname");

	RegConsoleCmd("sm_revote", Waves_RevoteCmd, "Revote the vote");

	RegAdminCmd("zr_setwave", Waves_SetWaveCmd, ADMFLAG_CHEATS);
	RegAdminCmd("zr_panzer", Waves_ForcePanzer, ADMFLAG_CHEATS);
}

bool Waves_InFreeplay()
{
	return (!Rogue_Mode() && Rounds && CurrentRound >= Rounds.Length);
}

bool Waves_InSetup()
{
	if(Rogue_Mode())
		return Rogue_InSetup();
	
	return (InSetup || !Waves_Started());
}

void Waves_MapStart()
{
	FogEntity = INVALID_ENT_REFERENCE;
	SkyNameRestore[0] = 0;
}

void Waves_PlayerSpawn(int client)
{
	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		SetVariantString("rpg_fortress_envfog");
		AcceptEntityInput(client, "SetFogController");
	}
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

bool Waves_InVote()
{
	return (Rogue_Mode() || Voting);
}

public Action Waves_RevoteCmd(int client, int args)
{
	if(Rogue_Mode())
	{
		Rogue_RevoteCmd(client);
	}
	else if(Voting)
	{
		VotedFor[client] = 0;
		Waves_CallVote(client);
	}
	return Plugin_Handled;
}

bool Waves_CallVote(int client)
{
	if(Rogue_Mode())
		return Rogue_CallVote(client);
	
	if(Voting && !VotedFor[client])
	{
		Menu menu = new Menu(Waves_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t:\n ","Vote for the difficulty");
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		menu.AddItem(NULL_STRING, vote.Name);
		
		int length = Voting.Length;
		for(int i; i<length; i++)
		{
			Voting.GetArray(i, vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);
			
			if(vote.Level > 0 && LastWaveWas[0] && StrEqual(vote.Config, LastWaveWas))
			{
				Format(vote.Name, sizeof(vote.Name), "%s (Cooldown)", vote.Name);
				menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
			}
			else if(Level[client] < vote.Level && Database_IsCached(client))
			{
				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, vote.Level);
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

public Action Waves_VoteDisplayTimer(Handle timer)
{
	if(!Voting)
		return Plugin_Stop;
	
	Waves_DisplayHintVote();
	return Plugin_Continue;
}

void Waves_DisplayHintVote()
{
	int length = Voting.Length;
	if(length > 1)
	{
		int count, total;
		int[] votes = new int[length + 1];
		for(int client=1; client<=MaxClients; client++)
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
			vote.Name[0] = CharToUpper(vote.Name[0]);

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					Voting.GetArray(top[i], vote);
					vote.Name[0] = CharToUpper(vote.Name[0]);

					Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
}

void OnMapEndWaves()
{
	CurrentGame = -1;
	delete Voting;
	Zero(VotedFor);
}

void Waves_SetupVote(KeyValues map)
{
	Cooldown = 0.0;
	delete Voting;
	
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

	if(map && kv.GetNum("roguemode"))
	{
		Rogue_SetupVote(kv);
		return;
	}

	if(!kv.JumpToKey("Waves"))
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "waves");
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

	CanReVote = Voting.Length > 1;

	CreateTimer(1.0, Waves_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
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
	
	if(CvarNoSpecialZombieSpawn.BoolValue || Rogue_Mode())
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
			boss.SoundCustom = view_as<bool>(kv.GetNum("sound_iscustom"));
			if(boss.SoundCustom)
			{
				kv.GetString("sound", boss.Sound, sizeof(boss.Sound));
				kv.GetString("sound_alt", buffer, sizeof(buffer));
				if(boss.Sound[0])
					PrecacheSoundCustom(boss.Sound, buffer);
			}
			else
			{
				kv.GetString("sound", boss.Sound, sizeof(boss.Sound));
				if(boss.Sound[0])
					PrecacheSound(boss.Sound);
			}
				
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
	
	char buffer[64], plugin[64];

	b_SpecialGrigoriStore = view_as<bool>(kv.GetNum("grigori_special_shop_logic"));
	f_ExtraDropChanceRarity = kv.GetFloat("gift_drop_chance_multiplier", 0.5);
	kv.GetString("complete_item", buffer, sizeof(buffer));
	WaveGiftItem = buffer[0] ? Items_NameToId(buffer) : -1;
	bool autoCash = view_as<bool>(kv.GetNum("auto_raid_cash"));
	
	Enemy enemy;
	Wave wave;
	kv.GotoFirstSubKey();
	do
	{
		round.Cash = kv.GetNum("cash");
		round.Custom_Refresh_Npc_Store = view_as<bool>(kv.GetNum("grigori_refresh_store"));
		round.medival_difficulty = kv.GetNum("medival_research_level");
		round.MapSetupRelay = view_as<bool>(kv.GetNum("map_setup_fake"));
		round.Xp = kv.GetNum("xp");
		round.Setup = kv.GetFloat("setup");
	
		kv.GetString("music_track_1", round.music_round_1, sizeof(round.music_round_1));
		round.music_duration_1 = kv.GetNum("music_seconds_1");
		round.music_custom_1 = view_as<bool>(kv.GetNum("music_download_1"));
		
		kv.GetString("music_track_2", round.music_round_2, sizeof(round.music_round_2));
		round.music_duration_2 = kv.GetNum("music_seconds_2");
		round.music_custom_2 = view_as<bool>(kv.GetNum("music_download_2"));
		
		if(round.music_round_1[0])
		{
			if(round.music_custom_1)
			{
				PrecacheSoundCustom(round.music_round_1);
			}
			else
			{
				PrecacheSound(round.music_round_1);
			}
		}
		
		if(round.music_round_2[0])
		{
			if(round.music_custom_2)
			{
				PrecacheSoundCustom(round.music_round_2);
			}
			else
			{
				PrecacheSound(round.music_round_2);
			}
		}
		
		kv.GetString("music_track_outro", round.music_round_outro, sizeof(round.music_round_outro));
		round.music_custom_outro = view_as<bool>(kv.GetNum("music_download_outro"));
		round.SpawnGrigori = view_as<bool>(kv.GetNum("spawn_grigori"));
		round.GrigoriMaxSellsItems = kv.GetNum("grigori_sells_items_max");
		if(round.music_round_outro[0])
		{
			if(round.music_custom_outro)
			{
				PrecacheSoundCustom(round.music_round_outro);
			}
			else
			{
				PrecacheSound(round.music_round_outro);
			}
		}

		kv.GetString("message_outro", round.Message, sizeof(round.Message));

		kv.GetString("skyname", round.Skyname, sizeof(round.Skyname));

		round.FogChange = view_as<bool>(kv.GetNum("fogenable"));
		if(round.FogChange)
		{
			kv.GetString("fogblend", round.FogBlend, sizeof(round.FogBlend));
			kv.GetString("fogcolor", round.FogColor1, sizeof(round.FogColor1));
			kv.GetString("fogcolor2", round.FogColor2, sizeof(round.FogColor2));
			round.FogStart = kv.GetFloat("fogstart");
			round.FogEnd = kv.GetFloat("fogend");
			round.FogDesnity = kv.GetFloat("fogmaxdensity");
		}

		int nonBosses;

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

						kv.GetString("relayname", wave.RelayName, sizeof(wave.RelayName));
						kv.GetString("relayfire", wave.RelayFire, sizeof(wave.RelayFire));
						
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
						enemy.Credits = kv.GetFloat("cash");
						enemy.ExtraMeleeRes = kv.GetFloat("extra_melee_res", 1.0);
						enemy.ExtraRangedRes = kv.GetFloat("extra_ranged_res", 1.0);
						enemy.ExtraSpeed = kv.GetFloat("extra_speed", 1.0);
						enemy.ExtraDamage = kv.GetFloat("extra_damage", 1.0);
						
						kv.GetString("data", enemy.Data, sizeof(enemy.Data));
						kv.GetString("spawn", enemy.Spawn, sizeof(enemy.Spawn));

						if(!enemy.Credits)
							nonBosses++;
						
						wave.EnemyData = enemy;
						round.Waves.PushArray(wave);
					}
				}
			} while(kv.GotoNextKey());
			
			kv.GoBack();
		}

		if(autoCash && nonBosses)
		{
			int length = round.Waves.Length;
			if(length)
			{
				float fcash = float(round.Cash) / float(nonBosses);
				for(int i; i < length; i++)
				{
					round.Waves.GetArray(i, wave);
					if(wave.EnemyData.Credits)
						continue;

					float count = float(wave.Count);
					if(count < 1.0)
						count = 1.0;
					
					wave.EnemyData.Credits = fcash / count;
					round.Waves.SetArray(i, wave);
				}

				round.Cash = 0;
			}
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
	if(SkyNameRestore[0])
	{
		CvarSkyName.SetString(SkyNameRestore, true);
		SkyNameRestore[0] = 0;
	}

	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(FogEntity);
		if(entity != INVALID_ENT_REFERENCE)
			RemoveEntity(entity);
		
		FogEntity = INVALID_ENT_REFERENCE;
	}
	
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
	
	Waves_RoundEnd();
	Freeplay_ResetAll();
	
	if(Rogue_Mode())
	{
		Rogue_StartSetup();
	}
	else if(Voting)
	{
		float wait = zr_waitingtime.FloatValue;
		if(wait < 90.0)
			CanReVote = false;
		
		float time = wait - (CanReVote ? 60.0 : 30.0);
		if(time < 20.0)
			time = 20.0;
		
		VoteEndTime = GetGameTime() + time;
		CreateTimer(time, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

		if(wait < time)
			wait = time;

		SpawnTimer(wait);
		CreateTimer(wait, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		SpawnTimer(90.0);
		CreateTimer(90.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	}

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
	Cooldown = 0.0;
	InSetup = true;
//	InFreeplay = false;
	CurrentRound = 0;
	CurrentWave = -1;
	Medival_Difficulty_Level = 0.0; //make sure to set it to 0 othrerwise waves will become impossible
}

public Action Waves_RoundStartTimer(Handle timer)
{
	if(!Voting)
	{
		bool any_player_on = false;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
				any_player_on = true;
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

public Action Waves_EndVote(Handle timer, float time)
{
	if(Voting)
	{
		int length = Voting.Length;
		if(length)
		{
			Waves_DisplayHintVote();

			int[] votes = new int[length];
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					DoOverlay(client, "");
					if(VotedFor[client]>0 && VotedFor[client] <= length && GetClientTeam(client)==2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}

			if(CanReVote)
			{
				int high1 = 0;
				int high2 = 1;
				for(int i = 2; i < length; i++)
				{
					if(votes[i] > votes[high1])
					{
						high2 = high1;
						high1 = i;
					}
					else if(votes[i] > votes[high2])
					{
						high2 = i;
					}
				}

				high1 = votes[high2];
				for(int i = length - 1; i >= 0; i--)
				{
					if(votes[i] < high1)
					{
						Voting.Erase(i);
					}
				}

				Zero(VotedFor);
				CanReVote = false;
				VoteEndTime = GetGameTime() + 30.0;
				CreateTimer(30.0, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
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
					
					strcopy(LastWaveWas, sizeof(LastWaveWas), vote.Config);
					PrintToChatAll("%t: %s","Difficulty set to", vote.Name);

					Queue_DifficultyVoteEnded();
					Native_OnDifficultySet(highest);
					
					if(highest > 3)
						highest = 3;
					
					Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "FireUser%d", highest + 1);
					ExcuteRelay("zr_waveselected", WhatDifficultySetting);
					
					vote.Name[0] = CharToUpper(vote.Name[0]);
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
		else
		{
			delete Voting;
		}
	}
	return Plugin_Continue;
}

/*void Waves_ClearWaves()
{
	delete Enemies;
	Enemies = new ArrayStack(sizeof(Enemy));
}*/

void Waves_Progress()
{
	if(InSetup || !Rounds || CvarNoRoundStart.BoolValue || Cooldown > GetGameTime())
		return;
		
	delete WaveTimer;
	
	Round round;
	Wave wave;
	int length = Rounds.Length-1;
	bool panzer_spawn = false;
	bool panzer_sound = false;
	bool rogue = Rogue_Mode();
	static int panzer_chance;

	if(CurrentRound < length)
	{
		Rounds.GetArray(CurrentRound, round);
		if(++CurrentWave < round.Waves.Length)
		{
			f_FreeplayDamageExtra = 1.0;
			round.Waves.GetArray(CurrentWave, wave);

			if(wave.RelayName[0])
				ExcuteRelay(wave.RelayName, wave.RelayFire);
			
			float playercount = float(CountPlayersOnRed());
			
			if(playercount == 1.0) //If alone, spawn wayless, it makes it way too difficult otherwise.
			{
				playercount = 0.70;
			}

			float multi = Pow(1.08, playercount);

			multi -= 0.31079601; //So if its 4 players, it defaults to 1.0, and lower means abit less! meaning if alone you fight 70% instead of 50%
			
			MultiGlobal = multi;
			
			int Is_a_boss = wave.EnemyData.Is_Boss;
			bool ScaleWithHpMore = wave.Count == 0;
			
			if(Is_a_boss == 2)
			{
				Raidboss_Clean_Everyone();
				ReviveAll(true);
				Music_EndLastmann();
				CheckAlivePlayers();
				WaveEndLogicExtra();
			}
			
			int count = wave.Count;
			
			if(wave.EnemyData.Does_Not_Scale == 0)
			{
				if(Is_a_boss == 0)
				{
					count = RoundToNearest(float(count)*multi);
				}
				else
				{
					float multiBoss = playercount * 0.25;
					//If its any boss, then make it scale like old.
					count = RoundToNearest(float(count)*multiBoss);
				}
			}
			
			if(count < 1) //So its always 1
				count = 1;
				
			
			if(count > 150) //So its always less then 150.
				count = 150;
			
			if(!wave.EnemyData.Friendly)
			{
				Zombies_Currently_Still_Ongoing += count;
			}
			
			
			int Is_Health_Scaling;
			
			Is_Health_Scaling = 0;
			
			BalanceDropMinimum(multi);
			
			Is_Health_Scaling = wave.EnemyData.Is_Health_Scaled;
			
			if(Is_a_boss >= 1 || Is_Health_Scaling >= 1)
			{			
				float multiBoss;
				//note: do not use exponential formulars
				/*
					They are just too unbalanced.
					Lets treat each player as just more hp flat.
				*/
				if(playercount > 12)
				{
					if(ScaleWithHpMore)
					{
						multiBoss = playercount * 0.4;
					}
				}
				else
				{
					if(ScaleWithHpMore)
					{
						multiBoss = playercount * 0.34;
					}
				}

				if(!ScaleWithHpMore)
				{
					multiBoss = playercount * 0.2;
					MultiGlobalHealth = multiBoss;
				}
				
				int Tempomary_Health = RoundToNearest(float(wave.EnemyData.Health) * multiBoss);
				wave.EnemyData.Health = Tempomary_Health;
			}
		
			for(int i; i<count; i++)
			{
				Enemies.PushArray(wave.EnemyData);
			}
			
			if(wave.Delay > 0.0)
				WaveTimer = CreateTimer(wave.Delay * (MultiGlobal * 0.75), Waves_ProgressTimer);
		}
		else
		{
			WaveEndLogicExtra();
			CreateTimer(1.0, DeleteEntitiesInHazards, _, TIMER_FLAG_NO_MAPCHANGE);
			CurrentCash += round.Cash;
			if(round.Cash)
			{
				CPrintToChatAll("{green}%t","Cash Gained This Wave", round.Cash);
			}

			ExcuteRelay("zr_wavedone");
			CurrentRound++;
			CurrentWave = -1;
			
			delete Enemies;
			Enemies = new ArrayStack(sizeof(Enemy));
			
			for(int client_Penalise=1; client_Penalise<=MaxClients; client_Penalise++)
			{
				if(IsClientInGame(client_Penalise))
				{
					if(GetClientTeam(client_Penalise)!=2)
					{
						SetGlobalTransTarget(client_Penalise);
						PrintToChat(client_Penalise, "%t", "You have only gained 80%% due to not being in-game");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.20);
					}
					else if (TeutonType[client_Penalise] == TEUTON_WAITING)
					{
						SetGlobalTransTarget(client_Penalise);
						PrintToChat(client_Penalise, "%t", "You have only gained 90 %% due to being a non-player player, but still helping");
						CashSpent[client_Penalise] += RoundToCeil(float(round.Cash) * 0.10);
					}
				}
			}

			bool music_stop = false;
			if(round.music_round_outro[0])
			{
				music_stop = true;
				if(round.music_custom_outro)
				{
					EmitCustomToAll(round.music_round_outro, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.45);
				}
				else
				{
					EmitSoundToAll(round.music_round_outro, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.73);
					EmitSoundToAll(round.music_round_outro, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.73);
				}
			}

			if(round.Message[0])
			{
				SetHudTextParams(-1.0, -1.0, 8.0, 255, 0, 0, 255);
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && !b_IsPlayerABot[client])
					{
						SetGlobalTransTarget(client);
						ShowHudText(client, -1, "%t", round.Message);
					}
				}
			}
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(music_stop)
					{
						Music_Stop_All(client);
					}
				}
			}
			if(round.GrigoriMaxSellsItems > 0)
			{
				GrigoriMaxSells = round.GrigoriMaxSellsItems;
			}

			bool refreshNPCStore;
			if(round.SpawnGrigori)
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
				Spawn_Cured_Grigori();
				refreshNPCStore = true;
			}
			
			// Above is the round that just ended
			Rounds.GetArray(CurrentRound, round);
			// Below is the new round
			
			if(round.MapSetupRelay)
			{
				ExcuteRelay("zr_setuptime");
				Citizen_SetupStart();
				f_DelaySpawnsForVariousReasons = GetGameTime() + 1.5; //Delay spawns for 1.5 seconds, so maps can do their thing.
			}

			if(round.Skyname[0])
				Waves_SetSkyName(round.Skyname);

			if(round.FogChange)
			{
				if(FogEntity != INVALID_ENT_REFERENCE)
				{
					int entity = EntRefToEntIndex(FogEntity);
					if(entity > MaxClients)
						RemoveEntity(entity);
					
					FogEntity = INVALID_ENT_REFERENCE;
				}
				
				int entity = CreateEntityByName("env_fog_controller");
				if(entity != -1)
				{
					char name[64];
					FormatEx(name, sizeof(name), "rpg_fortress_envfog_%d", CurrentRound);

					DispatchKeyValue(entity, "fogblend", round.FogBlend);
					DispatchKeyValue(entity, "fogcolor", round.FogColor1);
					DispatchKeyValue(entity, "fogcolor2", round.FogColor2);
					DispatchKeyValueFloat(entity, "fogstart", round.FogStart);
					DispatchKeyValueFloat(entity, "fogend", round.FogEnd);
					DispatchKeyValueFloat(entity, "fogmaxdensity", round.FogDesnity);

					DispatchKeyValue(entity, "targetname", name);
					DispatchKeyValue(entity, "fogenable", "1");
					DispatchKeyValue(entity, "spawnflags", "1");
					DispatchSpawn(entity);
					AcceptEntityInput(entity, "TurnOn");

					FogEntity = EntIndexToEntRef(entity);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetVariantString(name);
							AcceptEntityInput(client, "SetFogController");
						}
					}
				}
			}
			
			//Loop through all the still alive enemies that are indexed!
			int Zombies_alive_still = 0;

			for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
			{
				int npc_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
				if (IsValidEntity(npc_index) && npc_index != 0)
				{
					if(!b_NpcHasDied[npc_index])
					{
						if(GetEntProp(npc_index, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
						{
							Zombies_alive_still += 1;
						}
					}
				}
			}
			
			if(Zombies_Currently_Still_Ongoing > 0 && (Zombies_Currently_Still_Ongoing - Zombies_alive_still) > 0)
			{
				CPrintToChatAll("{crimson}%d zombies have been wasted...", Zombies_Currently_Still_Ongoing - Zombies_alive_still);
			}
			Zombies_Currently_Still_Ongoing = 0;
			
			Zombies_Currently_Still_Ongoing = Zombies_alive_still;
			
			//Loop through all the still alive enemies that are indexed!
			
			if(!rogue && CurrentRound == 4)
			{
				Citizen_SpawnAtPoint("b");
			}
			else if(CurrentRound == 11)
			{
				panzer_spawn = true;
				panzer_sound = true;
				panzer_chance = 10;
			}
			else if((CurrentRound > 11 && round.Setup <= 30.0))
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

			if(rogue) //disable
			{
				panzer_spawn = false;
				panzer_sound = false;
			}
			
			bool wasLastMann = (LastMann && EntRefToEntIndex(RaidBossActive) == -1);
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
				//PrintToChatAll("%t", "Grigori Store Refresh");
				//Store_RandomizeNPCStore(false); // Refresh me !!!
				refreshNPCStore = true;
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

			if(char_RaidMusicSpecial1[0])
			{
				RoundHasCustomMusic = true;
			}

			if(RoundHasCustomMusic) //only do it when there was actually custom music previously
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						SetMusicTimer(client, GetTime() + RoundToNearest(round.Setup) + 1); //This is here beacuse of raid music.
						Music_Stop_All(client);
					}
				}	
			}

			//This should nullfy anyways if nothings in it
			strcopy(char_MusicString1, sizeof(char_MusicString1), round.music_round_1);
			strcopy(char_MusicString2, sizeof(char_MusicString2), round.music_round_2);
			char_RaidMusicSpecial1[0] = 0;

			i_MusicLength1 = round.music_duration_1;
			i_MusicLength2 = round.music_duration_2;

			b_MusicCustom1 = round.music_custom_1;
			b_MusicCustom2 = round.music_custom_2;
			
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
				refreshNPCStore = true;
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				ExcuteRelay("zr_victory");
				
				if(!rogue)
				{
					Cooldown = GetGameTime() + 30.0;
					
					SpawnTimer(30.0);
					CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				}
				
				int total = 0;
				int[] players = new int[MaxClients];
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i))
					{
						Music_Stop_All(i);
						if(!rogue)
							SendConVarValue(i, sv_cheats, "1");
						
						players[total++] = i;

						if(WaveGiftItem != -1 && PlayerPoints[i] > 500)
						{
							if(Items_GiveIdItem(i, WaveGiftItem))
								CPrintToChat(i,"{default}You have found {yellow}%s{default}!", Items_GetNameOfId(WaveGiftItem));
						}
					}
				}

				if(!rogue)
				{
					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.5, SetTimeBack);
					
					EmitCustomToAll("#zombiesurvival/music_win.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);

					Menu menu = new Menu(Waves_FreeplayVote);
					menu.SetTitle("%t","Victory Menu");
					menu.AddItem("", "Yes");
					menu.AddItem("", "No");
					menu.ExitButton = false;
					
					menu.DisplayVote(players, total, 30);
				}
				
				char_MusicString1[0] = 0;
				char_MusicString2[0] = 0;
				char_RaidMusicSpecial1[0] = 0;

				i_MusicLength1 = 1;
				i_MusicLength2 = 1;

				if(rogue)
				{
					Rogue_BattleVictory();
				}

				Citizen_SetupStart();
			}
			else if(round.Setup > 0.0)
			{
				Cooldown = GetGameTime() + round.Setup;
				
				refreshNPCStore = true;
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				SpawnTimer(round.Setup);
				CreateTimer(round.Setup, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);

				Citizen_SetupStart();
			}
			else if(wasLastMann)
			{
				Cooldown = GetGameTime() + 30.0;
				
				SpawnTimer(30.0);
				CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				PrintToChatAll("You were given extra 30 seconds to prepare...");
			}
			else
			{
				if(refreshNPCStore)
					Store_RandomizeNPCStore(false);
				
				Waves_Progress();
				NPC_SpawnNext(false, panzer_spawn, panzer_sound);
				return;
			}

			if(refreshNPCStore)
				Store_RandomizeNPCStore(false);
		}
	}
	else if(Rogue_Mode())
	{
		PrintToChatAll("FREEPLAY OCCURED, BAD CFG, REPORT BUG");
	}
	else
	{
		Rounds.GetArray(length, round);
		if(++CurrentWave < 1)
		{
			float playercount = float(CountPlayersOnRed());
			float multi = Pow(1.08, playercount);
			multi -= 0.31079601; //So if its 4 players, it defaults to 1.0, and lower means abit less! meaning if alone you fight 70% instead of 50%
			MultiGlobal = multi;

			int postWaves = CurrentRound - length;
			f_FreeplayDamageExtra = 1.0 + (postWaves / 30.0);

			Rounds.GetArray(length, round);
			length = round.Waves.Length;
			
			int Max_Enemy_Get = Freeplay_EnemyCount();
			for(int i; i < length; i++)
			{
				if(Freeplay_ShouldAddEnemy()) //Do not allow more then 3 different enemy types at once, or else freeplay just takes way too long and the RNG will cuck it.
				{
					round.Waves.GetArray(i, wave);
					Freeplay_AddEnemy(postWaves, wave.EnemyData, wave.Count);

					if(wave.Count > 0)
					{
						for(int a; a < wave.Count; a++)
						{
							Enemies.PushArray(wave.EnemyData);
						}
						
						Zombies_Currently_Still_Ongoing += wave.Count;

						if(!(--Max_Enemy_Get))
							break;
					}
				}
			}

			// Note: Artvan remove this, this is freeplay code
			if(Freeplay_ShouldMiniBoss() && !rogue) //no miniboss during roguelikes.
			{
				panzer_spawn = true;
				NPC_SpawnNext(false, panzer_spawn, false);
			}
			else
			{
				panzer_spawn = false;
				NPC_SpawnNext(false, false, false);
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
			WaveEndLogicExtra();

			int postWaves = CurrentRound - length;
			Freeplay_OnEndWave(postWaves, round.Cash);
			CurrentCash += round.Cash;

			if(round.Cash)
			{
				CPrintToChatAll("{green}%t{default}","Cash Gained This Wave", round.Cash);
			}
			
			char_RaidMusicSpecial1[0] = 0;
			
			ExcuteRelay("zr_wavedone");
			CurrentRound++;
			CurrentWave = -1;
			//Rounds.GetArray(length, round);
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
				Freeplay_SetupStart(postWaves);

				Cooldown = GetGameTime() + 30.0;
				
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				SpawnTimer(30.0);
				CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
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
				
				Citizen_SetupStart();
			}
			else
			{
				Waves_Progress();
				return;
			}
		}
	}
	if(CurrentRound == 0 && !Rogue_Mode())
	{
		if(StartCash < 1500)
			Store_RemoveSellValue();
		
		Ammo_Count_Ready = 8;
		if(StartCash < 1500)
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client)==2)
				{
					int cash = StartCash - (Resupplies_Supplied[client] * 10);
					if(CashSpent[client] < cash)
						CashSpent[client] = cash;
					
					CashSpent[client] -= StartCash;
				}
			}

			CurrentCash = 0;
		}
	}
	if(CurrentWave == 0)
	{
		Renable_Powerups();
		CheckIfAloneOnServer();
		Ammo_Count_Ready += 1;
		for (int target = 1; target <= MaxClients; target++)
		{
			if(i_CurrentEquippedPerk[target] == 7) //recycle gives extra
			{
				Ammo_Count_Used[target] -= 1;
			}
		}
	}
	else if (Gave_Ammo_Supply > 2)
	{
		Ammo_Count_Ready += 1;
		Gave_Ammo_Supply = 0;
		for (int target = 1; target <= MaxClients; target++)
		{
			if(i_CurrentEquippedPerk[target] == 7) //recycle gives extra
			{
				Ammo_Count_Used[target] -= 1;
			}
		}
	}	
	else
	{
		Gave_Ammo_Supply += 1;	
	}
//	PrintToChatAll("Wave: %d - %d", CurrentRound+1, CurrentWave+1);
	
}

public void Medival_Wave_Difficulty_Riser(int difficulty)
{
	PrintToChatAll("%t", "Medival_Difficulty", difficulty);
	
	float difficulty_math = Pow(0.9, float(difficulty));
	
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
	if(Rogue_Mode())
		return Rogue_Started();
	
	return (CurrentRound || CurrentWave != -1);
}

int Waves_GetRound()
{
	if(Rogue_Mode())
		return Rogue_GetRound();
	
	return CurrentRound;
}

public int Waves_GetWave()
{
	if(Rogue_Mode())
		return Rogue_GetWave();
	
	return CurrentWave;
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

void Waves_SetSkyName(const char[] skyname = "", int client = 0)
{
	if(client)
	{
		if(!IsFakeClient(client))
		{
			if(skyname[0])
			{
				CvarSkyName.ReplicateToClient(client, skyname);
			}
			else
			{
				char buffer[64];
				CvarSkyName.GetString(buffer, sizeof(buffer));
				CvarSkyName.ReplicateToClient(client, buffer);
			}
		}
	}
	else if(skyname[0])
	{
		if(!SkyNameRestore[0])
			CvarSkyName.GetString(SkyNameRestore, sizeof(SkyNameRestore));
		
		CvarSkyName.SetString(skyname, true);
	}
	else if(SkyNameRestore[0])
	{
		CvarSkyName.SetString(SkyNameRestore, true);
		SkyNameRestore[0] = 0;
	}
}


void WaveEndLogicExtra()
{
	SeaFounder_ClearnNethersea();
	M3_AbilitiesWaveEnd();
	Specter_AbilitiesWaveEnd();	
}