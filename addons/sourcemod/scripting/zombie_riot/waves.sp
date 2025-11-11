#pragma semicolon 1
#pragma newdecls required

enum struct Enemy
{
	int Health;
	int Is_Boss;
	int ForceScaling;
	float WaitingTimeGive;
	float ExtraSize;
	int Is_Outlined;
	int Is_Health_Scaled;
	int Does_Not_Scale;
	int ignore_max_cap;
	int Is_Immune_To_Nuke;
	bool Is_Static;
	int Team;
	int Index;
	float Credits;
	char Data[64];
	float ExtraMeleeRes;
	float ExtraRangedRes;
	float ExtraSpeed;
	float ExtraDamage;
	char Spawn[64];
	float ExtraThinkSpeed;
	char CustomName[64];
	int Priority;
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
	int DangerLevel;
}

enum struct Round
{
	int Xp;
	int Cash;
	int CashShould;
	int AmmoBoxExtra;
	bool MapSetupRelay;
	bool Custom_Refresh_Npc_Store;
	int medival_difficulty;
	
	MusicEnum music_round_1;
	MusicEnum music_round_2;
	MusicEnum music_setup;
	int MusicOutroDuration;
	char music_round_outro[255];
	bool music_custom_outro;
	char Message[255];
	bool SpawnGrigori;
	int GrigoriMaxSellsItems;
	float Setup;
	bool NoMiniboss;
	bool NoBarney;
	ArrayList Waves;
	
	char Skyname[64];
	bool FogChange;
	int FogBlend;
	int FogColor1[4];
	int FogColor2[4];
	float FogStart;
	float FogEnd;
	float FogDesnity;	
	
	bool Override_Music_Setup;
}

enum struct Vote
{
	char Name[64];
	char Config[256];
	int Level;
	char Desc[256];
	char Append[64];
	char Unlock1[64];
	char Unlock2[64];
	bool Locked;
}

static ArrayList Enemies[3];
static ArrayList Rounds;
static ArrayList Voting;
static ArrayList VotingMods;
static bool CanReVote;
static ArrayList MiniBosses;
static float Cooldown;
static bool InSetup;
static int FakeMaxWaves;
static bool NoBarneySpawn;
static int WaveLevel;
static int MapSeed;

static Function ModFuncRemove = INVALID_FUNCTION;
static Function ModFuncAlly = INVALID_FUNCTION;
static Function ModFuncEnemy = INVALID_FUNCTION;
static Function ModFuncWeapon = INVALID_FUNCTION;

static ConVar CvarSkyName;
static char SkyNameRestore[64];

static StringMap g_AllocPooledStringCache;

static int Gave_Ammo_Supply;
static int VotedFor[MAXPLAYERS];
static float VoteEndTime;
static float f_ZombieAntiDelaySpeedUp;
static int i_ZombieAntiDelaySpeedUp;
static Handle WaveTimer;
static float ProgressTimerEndAt;
static bool ProgressTimerType;
static bool FirstMapRound;

static bool UpdateFramed;
static int WaveGiftItem;
static char LastWaveWas[64];

static int Freeplay_Info;
//static bool Freeplay_w500reached;
static float MinibossScalingHandle = 1.0;
static float Freeplay_TimeCash;
static float Freeplay_CashTimeLeft;

static int RelayCurrentRound = -1;
static float OverrideScalingManually;

public Action Waves_ProgressTimer(Handle timer)
{
	if(Classic_Mode() && ProgressTimerType)
	{
		// Delay progress if a boss is alive
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entity))
			{
				if(GetTeam(entity) == TFTeam_Blue)
				{
					CClotBody npcstats = view_as<CClotBody>(entity);
					if(npcstats.m_bThisNpcIsABoss && !npcstats.m_bStaticNPC)
					{
						WaveTimer = CreateTimer(0.5, Waves_ProgressTimer);
						return Plugin_Continue;
					}
				}
			}
		}
	}

	ProgressTimerEndAt = 0.0;
	WaveTimer = null;
	Waves_Progress();
	return Plugin_Continue;
}

void Waves_PluginStart()
{
	CvarSkyName = FindConVar("sv_skyname");

	RegConsoleCmd("sm_revote", Waves_RevoteCmd, "Revote the vote");

	RegAdminCmd("zr_setwave", Waves_SetWaveCmd, ADMFLAG_CHEATS);
	RegAdminCmd("zr_panzer", Waves_ForcePanzer, ADMFLAG_CHEATS);
	RegAdminCmd("zr_CurrentEnemyAliveLimits", NpcEnemyAliveLimit, ADMFLAG_CHEATS);
}

bool Waves_InFreeplay()
{
	return (!Rogue_Mode() && !Construction_Mode() && Rounds && CurrentRound >= Rounds.Length);
}

bool Waves_InSetup()
{
	if(Construction_Mode())
		return Construction_InSetup();
	
	if(Rogue_Mode())
		return Rogue_InSetup();
	
	return (InSetup || !Waves_Started());
}

void Waves_MapStart()
{
	delete Rounds;
	delete g_AllocPooledStringCache;
	SkyNameRestore[0] = 0;
	FakeMaxWaves = 0;
	NoBarneySpawn = true;
	Freeplay_Info = 0;
	FirstMapRound = true;
	MinibossScalingHandle = 1.0;
	MapSeed = GetURandomInt();
//	Freeplay_w500reached = false;

	int objective = GetObjectiveResource();
	if(objective != -1)
		SetEntProp(objective, Prop_Send, "m_iChallengeIndex", -1);

	Waves_UpdateMvMStats();
	Freeplay_TimeCash = 0.0;
	Freeplay_CashTimeLeft = 0.0;
}

int Waves_MapSeed()
{
	return MapSeed;
}

void Waves_PlayerSpawn(int client)
{
	ShowCustomFogToClient(client);
}

float MinibossScalingReturn()
{
	if(Rogue_Mode())
		return 1.0;
	if(Construction_Mode())
		return 1.0;
	if(BetWar_Mode())
		return 1.0;

	return MinibossScalingHandle;
}
public Action NpcEnemyAliveLimit(int client, int args)
{
	ReplyToCommand(client, "EnemyNpcAlive %i | EnemyNpcAliveStatic %i",EnemyNpcAlive, EnemyNpcAliveStatic);
	return Plugin_Handled;
}

public Action Waves_ForcePanzer(int client, int args)
{
	char arg[20];
	int index=0;
	GetCmdArg(1, arg, sizeof(arg));
	if(StringToIntEx(arg, index) <= 0 || index <= 0)
		index=-1;

	NPC_SpawnNext(true, true, index); //This will force spawn a panzer.
	return Plugin_Handled;
}

public Action Waves_SetWaveCmd(int client, int args)
{
	Waves_ClearWaves();
	
	char buffer[12];
	GetCmdArgString(buffer, sizeof(buffer));
	CurrentRound = StringToInt(buffer);
	RelayCurrentRound = CurrentRound;
	CurrentWave = -1;
	Waves_Progress();
	return Plugin_Handled;
}

bool Waves_InVote()
{
	return (Rogue_Mode() || Construction_Mode() || Voting || VotingMods);
}

public Action Waves_RevoteCmd(int client, int args)
{
	if(BetWar_Mode())
	{
		BetWar_RevoteCmd(client);
	}
	else if(Rogue_Mode() || Construction_Mode())
	{
		Rogue_RevoteCmd(client);
	}
	else if(CyberVote)
	{
		RaidMode_RevoteCmd(client);
	}
	else if(Voting)
	{
		VotedFor[client] = 0;
		Waves_CallVote(client);
	}
	else if(VotingMods)
	{
		VotedFor[client] = 0;
		Waves_CallVote(client);
	}
	return Plugin_Handled;
}

bool Waves_CallVote(int client, int force = 0)
{
	if(BetWar_Mode())
		return BetWar_CallVote(client);
	
	if(Rogue_Mode() || Construction_Mode())
		return Rogue_CallVote(client);
	else if(CyberVote)
		return RaidMode_CallVote(client);
	
	if((Voting || VotingMods) && (force || !VotedFor[client]))
	{
		Menu menu = new Menu(Waves_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t:\n ", Voting ? "Vote for the difficulty" : "Vote for the modifier");
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		if(Voting)
		{
			menu.AddItem(NULL_STRING, vote.Name);
		}
		else
		{
			menu.AddItem(NULL_STRING, vote.Name, ITEMDRAW_SPACER);
		}

		bool levels = CvarLeveling.BoolValue;

		if(Voting)
		{
			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				//There must be atleast 4 selections for the cooldown to work.
				if(length >= 4 && vote.Level > 0 && LastWaveWas[0] && StrEqual(vote.Config, LastWaveWas))
				{
					Format(vote.Name, sizeof(vote.Name), "%s (Cooldown)", vote.Name);
					if(AprilFoolsIconOverride() == STEAM_HAPPY)
						Format(vote.Name, sizeof(vote.Name), "Steam Happy (Cooldown)");
					menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
				}
				// Unlocks (atleast one player needs it)
				else if(vote.Unlock1[0] && (!Items_HasNamedItem(client, vote.Unlock1) || (vote.Unlock2[0] && !Items_HasNamedItem(client, vote.Unlock2))))
				{
					Format(vote.Name, sizeof(vote.Name), "%s (%s)", vote.Name, vote.Append);
					if(AprilFoolsIconOverride() == STEAM_HAPPY)
						Format(vote.Name, sizeof(vote.Name), "Steam Happy (%s)", vote.Append);
						
					menu.AddItem(vote.Config, vote.Name, (Items_HasNamedItem(0, vote.Unlock1) && (!vote.Unlock2[0] || Items_HasNamedItem(0, vote.Unlock2))) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
				}
				else
				{
					if(levels)
						Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, vote.Level);

					int MenuDo = ITEMDRAW_DISABLED;
					if(!vote.Level || i == 0)
						MenuDo = ITEMDRAW_DEFAULT;
					if(Level[client] >= 1)
						MenuDo = ITEMDRAW_DEFAULT;
					menu.AddItem(vote.Config, vote.Name, MenuDo);
				}
			}
		}
		else
		{
			if(levels)
			{
				Format(vote.Name, sizeof(vote.Name), "Standard (Lv %d)", WaveLevel);
			}
			else
			{
				strcopy(vote.Name, sizeof(vote.Name), "Standard");
			}
			
			menu.AddItem(NULL_STRING, vote.Name);

			int length = VotingMods.Length;
			for(int i = 1; i < length; i++)
			{
				VotingMods.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				
				if(levels)
				{
					float multi = float(vote.Level) / 1000.0;
					
					int level = WaveLevel;
					if(level < 10)
						level = 10;
					
					level = WaveLevel + RoundFloat(level * multi);

					Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, level);
				}
				int MenuDo = ITEMDRAW_DISABLED;
				if(Level[client] >= 1)
					MenuDo = ITEMDRAW_DEFAULT;
				menu.AddItem(vote.Config, vote.Name, MenuDo);
			}
		}
		
		menu.ExitButton = false;
		menu.DisplayAt(client, (force / 7 * 7), MENU_TIME_FOREVER);
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
			ArrayList list = Voting ? Voting : VotingMods;
			if(list)
			{
				if(!choice || VotedFor[client] != choice)
				{
					VotedFor[client] = choice;
					
					if(VotedFor[client] == 0)
					{
						VotedFor[client] = -1;
					}
					else if(VotedFor[client] > list.Length)
					{
						VotedFor[client] = 0;
						Waves_CallVote(client, choice);
						return 0;
					}
					else
					{
						Vote vote;
						list.GetArray(choice - 1, vote);

						if(vote.Desc[0] && TranslationPhraseExists(vote.Desc))
						{
							CPrintToChat(client, "%s: %t", vote.Name, vote.Desc);
						}
						else
						{
							CPrintToChat(client, "%s: %s", vote.Name, vote.Desc);
						}

						Waves_CallVote(client, choice);
						return 0;
					}
				}
			}

			Store_Menu(client);
		}
	}
	return 0;
}

public Action Waves_VoteDisplayTimer(Handle timer)
{
	if(!Voting && !VotingMods)
		return Plugin_Stop;
	
	Waves_DisplayHintVote();
	return Plugin_Continue;
}

void Waves_DisplayHintVote()
{
	ArrayList list = Voting ? Voting : VotingMods;
	int length = list.Length;
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
			list.GetArray(top[0], vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					list.GetArray(top[i], vote);
					vote.Name[0] = CharToUpper(vote.Name[0]);

					Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
}

void Waves_MapEnd()
{
	CurrentGame = -1;
	delete Voting;
	delete VotingMods;
	Zero(VotedFor);
	Waves_SetDifficultyName(NULL_STRING);
	UpdateMvMStatsFrame();

	if(ModFuncRemove != INVALID_FUNCTION)
	{
		Call_StartFunction(null, ModFuncRemove);
		Call_Finish();
	}

	ModFuncRemove = INVALID_FUNCTION;
	ModFuncAlly = INVALID_FUNCTION;
	ModFuncEnemy = INVALID_FUNCTION;
	ModFuncWeapon = INVALID_FUNCTION;
}

void Waves_SetupVote(KeyValues map, bool modifierOnly = false)
{
	mp_disable_respawn_times.BoolValue = true;

	if(!modifierOnly)
	{
		Cooldown = 0.0;
		delete Voting;
	}
	delete VotingMods;
	
	KeyValues kv = zr_ignoremapconfig.BoolValue ? null : map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Setup") && !kv.JumpToKey("Waves"))
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
	}
	
	if(!modifierOnly)
		StartCash = kv.GetNum("cash", 700);

	// Betting Wars Gamemode
	if(map && kv.GetNum("bettingwars"))
	{
		if(!modifierOnly)
			BetWar_SetupVote(kv);

		if(kv != map)
			delete kv;
		
		return;
	}

	// Construction Gamemode
	if(map && kv.GetNum("construction"))
	{
		if(!modifierOnly)
			Construction_SetupVote(kv);

		if(kv != map)
			delete kv;
		
		return;
	}

	// Rogue Gamemode
	if(map && kv.GetNum("roguemode"))
	{
		if(!modifierOnly)
			Rogue_SetupVote(kv);

		if(kv != map)
			delete kv;
		
		return;
	}

	if(!modifierOnly)
	{
		// ZS-Classic Gamemode
		if(kv.GetNum("classicmode"))
			Classic_Enable();
	}

	bool autoSelect = CvarAutoSelectWave.BoolValue;	
	Vote vote;
	
	if(!modifierOnly)
	{
		// Is a wave cfg itself
		if(!kv.JumpToKey("Waves"))
		{
			Waves_SetupWaves(kv, true);

			if(kv != map)
				delete kv;
			
			return;
		}

		Voting = new ArrayList(sizeof(Vote));
		int limit = CvarVoteLimit.IntValue;
		
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(vote.Name, sizeof(vote.Name));
				kv.GetString("file", vote.Config, sizeof(vote.Config));
				kv.GetString("desc", vote.Desc, sizeof(vote.Desc));
				kv.GetString("unlock", vote.Unlock1, sizeof(vote.Unlock1));
				kv.GetString("unlock2", vote.Unlock2, sizeof(vote.Unlock2));
				kv.GetString("unlockdesc", vote.Append, sizeof(vote.Append));
				vote.Level = kv.GetNum("level");
				Voting.PushArray(vote);

				// If we're downloading via downloadstable, add every vote option to that
				if(!autoSelect && limit < 1 && !FileNetwork_Enabled())
				{
					BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
					KeyValues wavekv = new KeyValues("Waves");
					wavekv.ImportFromFile(buffer);
					bool CacheNpcs = false;
					if(!FileNetworkLib_Installed())
						CacheNpcs = true;
					if(CvarFileNetworkDisable.IntValue >= FILENETWORK_ICONONLY)
						CacheNpcs = true;
					Waves_CacheWaves(wavekv, CacheNpcs);
					delete wavekv;
				}

			} while(kv.GotoNextKey());

			kv.GoBack();
		}

		if(limit > 0)
		{
			for(int length = Voting.Length; length > limit; length--)
			{
				Voting.Erase(MapSeed % length);
			}

			if(!autoSelect && !FileNetwork_Enabled())
			{
				for(int i; i < limit; i++)
				{
					Voting.GetArray(i, vote);
					
					BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
					KeyValues wavekv = new KeyValues("Waves");
					wavekv.ImportFromFile(buffer);
					bool CacheNpcs = false;
					if(!FileNetworkLib_Installed())
						CacheNpcs = true;
					if(CvarFileNetworkDisable.IntValue >= FILENETWORK_ICONONLY)
						CacheNpcs = true;
					Waves_CacheWaves(wavekv, CacheNpcs);
					delete wavekv;
				}
			}
		}

		kv.GoBack();
	}

	if(CvarAutoSelectDiff.BoolValue == modifierOnly && kv.JumpToKey("Modifiers"))
	{
		if(kv.GotoFirstSubKey())
		{
			VotingMods = new ArrayList(sizeof(Vote));
			strcopy(vote.Name, sizeof(vote.Name), "Standard");
			strcopy(vote.Desc, sizeof(vote.Desc), "Standard Desc");
			vote.Config[0] = 0;
			vote.Level = 0;
			VotingMods.PushArray(vote);
			do
			{
				vote.Level = RoundFloat(kv.GetFloat("level", 1.0) * 1000.0);

				kv.GetString("func_collect", vote.Config, sizeof(vote.Config));
				kv.GetString("func_remove", vote.Name, sizeof(vote.Name));
				Format(vote.Config, sizeof(vote.Config), "%s;%s", vote.Config, vote.Name);

				kv.GetString("func_ally", vote.Name, sizeof(vote.Name));
				Format(vote.Config, sizeof(vote.Config), "%s;%s", vote.Config, vote.Name);

				kv.GetString("func_enemy", vote.Name, sizeof(vote.Name));
				Format(vote.Config, sizeof(vote.Config), "%s;%s", vote.Config, vote.Name);

				kv.GetString("func_weapon", vote.Name, sizeof(vote.Name));
				Format(vote.Config, sizeof(vote.Config), "%s;%s", vote.Config, vote.Name);

				kv.GetSectionName(vote.Name, sizeof(vote.Name));
				kv.GetString("desc", vote.Desc, sizeof(vote.Desc));
				VotingMods.PushArray(vote);
			} while(kv.GotoNextKey());

			kv.GoBack();

			// Auto-select the modifier based on average player level
			if(modifierOnly)
			{
				int choosenLevel = 0;
				int choosen = 0; //Standart.
				int AverageLevel = Waves_AverageLevelGet(100);
				int length = VotingMods.Length;
				for(int i; i < length; i++)
				{
					VotingMods.GetArray(i, vote);

					float multi = float(vote.Level) / 1000.0;

					int level = WaveLevel;
					if(level < 10)
						level = 10;
					
					level += RoundToNearest(level * multi);
					if(AverageLevel >= level && level > choosenLevel)
					{
						choosen = i;
						choosenLevel = level;
					}
				}

				if(choosen != -1)
				{
					VotingMods.GetArray(choosen, vote);
					
					CPrintToChatAll("{crimson}%t: %s", "Modifier set to", vote.Name);
					if(vote.Desc[0])
						PrintToChatAll("%t", vote.Desc);
					ChatSetupTip();
					EmitSoundToAll("ui/chime_rd_2base_neg.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 70);
					EmitSoundToAll("ui/chime_rd_2base_pos.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 120);

					WaveLevel = choosenLevel;
					Native_OnDifficultySet(-1, WhatDifficultySetting_Internal, WaveLevel);
					
					FormatEx(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s [%s]", WhatDifficultySetting_Internal, vote.Name);
					Waves_SetDifficultyName(WhatDifficultySetting);

					char funcs[5][64];
					ExplodeString(vote.Config, ";", funcs, sizeof(funcs), sizeof(funcs[]));
					
					Function func = funcs[0][0] ? GetFunctionByName(null, funcs[0]) : INVALID_FUNCTION;
					ModFuncRemove = funcs[1][0] ? GetFunctionByName(null, funcs[1]) : INVALID_FUNCTION;
					ModFuncAlly = funcs[2][0] ? GetFunctionByName(null, funcs[2]) : INVALID_FUNCTION;
					ModFuncEnemy = funcs[3][0] ? GetFunctionByName(null, funcs[3]) : INVALID_FUNCTION;
					ModFuncWeapon = funcs[4][0] ? GetFunctionByName(null, funcs[4]) : INVALID_FUNCTION;

					if(func != INVALID_FUNCTION)
					{
						Call_StartFunction(null, func);
						Call_Finish();
					}
				}

				delete VotingMods;
			}
		}
	}

	if(kv != map)
		delete kv;
	
	if(modifierOnly)
		return;

	if(autoSelect)
	{
		int pos = MapSeed % Voting.Length;
		Voting.GetArray(pos, vote);
		delete Voting;
		
		strcopy(LastWaveWas, sizeof(LastWaveWas), vote.Config);
		CPrintToChatAll("{crimson}%t: %s","Difficulty set to", vote.Name);
		EmitSoundToAll("ui/chime_rd_2base_neg.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 70);
		EmitSoundToAll("ui/chime_rd_2base_pos.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 120);

		vote.Name[0] = CharToUpper(vote.Name[0]);

		Queue_DifficultyVoteEnded();
		Native_OnDifficultySet(pos, vote.Name, vote.Level);
		
		if(pos > 3)
			pos = 3;
		
		Waves_SetDifficultyName(vote.Name);
		WaveLevel = vote.Level;
		
		Format(vote.Name, sizeof(vote.Name), "FireUser%d", pos + 1);
		ExcuteRelay("zr_waveselected", vote.Name);
		
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
		KeyValues kv2 = new KeyValues("Waves");
		kv2.ImportFromFile(buffer);
		Waves_SetupWaves(kv2, false);
		delete kv2;

		DoGlobalMultiScaling();
		Waves_UpdateMvMStats();
	}
	else
	{
		CanReVote = Voting.Length > 2;
		CreateTimer(1.0, Waves_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
	
	if(CvarNoSpecialZombieSpawn.BoolValue || Rogue_Mode() || Construction_Mode())
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
	}
	
	if(kv.GotoFirstSubKey())
	{
		MiniBoss boss;
		MiniBosses = new ArrayList(sizeof(MiniBoss));
		
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			
			boss.Index = NPC_GetByPlugin(buffer);
			if(boss.Index == -1)
			{
				LogError("[Config] Unknown NPC '%s' in mini-bosses", buffer);
				continue;
			}
			
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

	if(kv != map)
		delete kv;
}

bool Waves_GetMiniBoss(MiniBoss boss, int RND = -1)
{
	if(!MiniBosses)
		return false;
	
	int length = MiniBosses.Length;
	if(!length)
		return false;
	
	int level;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] != TEUTON_WAITING && IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			if(Level[client] > level)
				level = Level[client];
		}
	}

	level /= 3;
	if(level < 1)
		return false;

	if(length > level)
		length = level;
	
	MiniBosses.GetArray((RND != -1 ? RND : GetURandomInt()) % length, boss);
	return true;
}

// Cache Music and NPCs
void Waves_CacheWaves(KeyValues kv, bool npcs)
{
	MusicEnum music;
	music.SetupKv("music_setup", kv);
	music.SetupKv("music_lastman", kv);
	music.SetupKv("music_win", kv);
	music.SetupKv("music_loss", kv);
	
	kv.GotoFirstSubKey();
	do
	{
		music.SetupKv("music_1", kv);
		music.SetupKv("music_1", kv);
		music.SetupKv("music_2", kv);
		music.SetupKv("music_setup", kv);
		
		if(kv.GetNum("music_download_outro"))
		{
			kv.GetString("music_track_outro", music.Path, sizeof(music.Path));
			if(music.Path[0])
				PrecacheSoundCustom(music.Path);
		}

		if(npcs && kv.GotoFirstSubKey())
		{
			do
			{
				if(kv.GetSectionName(music.Path, sizeof(music.Path)) && StrContains(music.Path, "music") != 0)
				{
					char DataSave[255];
					kv.GetString("plugin", music.Path, sizeof(music.Path));
					kv.GetString("data", DataSave, sizeof(DataSave));
					if(music.Path[0])
						NPC_GetByPlugin(music.Path,_, DataSave);
				}
			} while(kv.GotoNextKey());
			
			kv.GoBack();
		}
	} while(kv.GotoNextKey());
	music.Clear();
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
			round.music_round_1.Clear();
			round.music_round_2.Clear();
			delete round.Waves;
		}
		delete Rounds;
	}
	
	Rounds = new ArrayList(sizeof(Round));
	
	CurrentRound = 0;
	CurrentWave = -1;
	RelayCurrentRound = 0;
	
	Waves_ClearWaves();
	Waves_ResetCashGiveWaveEnd();
	
	char buffer[128], plugin[64];

	f_ExtraDropChanceRarity = kv.GetFloat("gift_drop_chance_multiplier", 0.5);
	i_WaveHasFreeplay = kv.GetNum("do_freeplay", 0);
	kv.GetString("complete_item", buffer, sizeof(buffer));
	WaveGiftItem = buffer[0] ? Items_NameToId(buffer) : -1;
	bool autoCash = view_as<bool>(kv.GetNum("auto_raid_cash"));
	FakeMaxWaves = kv.GetNum("fakemaxwaves");
	NoBarneySpawn = view_as<bool>(kv.GetNum("no_barney", 0));
	kv.GetString("relay_send_start", buffer, sizeof(buffer));
	if(buffer[0])
	{
		ExcuteRelay(buffer);
	}

	if(NoBarneySpawn)
	{
		//delete any rebels that exist to be sure.
		int INPC = 0;
		int a;
		while((INPC = FindEntityByNPC(a)) != -1)
		{
			if(IsValidEntity(INPC))
			{
				if(INPC != 0 && Citizen_IsIt(INPC))
				{
					b_DissapearOnDeath[INPC] = true;
					b_DoGibThisNpc[INPC] = true;
					SmiteNpcToDeath(INPC);
					SmiteNpcToDeath(INPC);
					SmiteNpcToDeath(INPC);
					SmiteNpcToDeath(INPC);
				}
			}
		}
		//Delete any existing rebels to be sure.
	}
	ResourceRegenMulti = kv.GetFloat("resourceregen", 1.0);
	Barracks_InstaResearchEverything = view_as<bool>(kv.GetNum("full_research"));
	StartCash = kv.GetNum("cash", StartCash);
	OverrideScalingManually = kv.GetFloat("miniboss_scaling", 0.0);
	Waves_TrySpawnBarney();

	int objective = GetObjectiveResource();
	if(objective != -1)
		SetEntProp(objective, Prop_Send, "m_iChallengeIndex", kv.GetNum("mvmdiff", -1));
	
	kv.GetString("author_format", buffer, sizeof(buffer));
	if(buffer[0])
		CPrintToChatAll("%t", "Format By", buffer);
	
	kv.GetString("author_npcs", buffer, sizeof(buffer));
	if(buffer[0])
		CPrintToChatAll("%t", "NPCs By", buffer);
	
	kv.GetString("author_raid", buffer, sizeof(buffer));
	if(buffer[0])
		CPrintToChatAll("%t", "Raidboss By", buffer);
	
	kv.GetString("difficulty", buffer, sizeof(buffer));
	if(buffer[0])
		Waves_SetDifficultyName(buffer);
		
	round.music_setup.SetupKv("music_setup", kv);
	
	if(round.music_setup.Valid())
	{
		round.music_setup.CopyTo(MusicSetup1);
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client); //This is actually more expensive then i thought.
				SetMusicTimer(client, GetTime() + 5);
			}
		}
	}
	
	MusicLastmann.SetupKv("music_lastman", kv);
	MusicWin.SetupKv("music_win", kv);
	MusicLoss.SetupKv("music_loss", kv);

	
	Enemy enemy;
	Wave wave;
	kv.GotoFirstSubKey();
	do
	{
		round.music_setup.SetupKv("music_setup", kv);
		round.Override_Music_Setup=view_as<bool>(kv.GetNum("override_music_setup"));
		if(kv.GetSectionName(buffer, sizeof(buffer)) && StrContains(buffer, "music_setup") != -1)
		{
			continue;
		}

		round.Cash = kv.GetNum("cash");
		round.AmmoBoxExtra = kv.GetNum("ammobox_extra");
		round.Custom_Refresh_Npc_Store = view_as<bool>(kv.GetNum("grigori_refresh_store"));
		round.medival_difficulty = kv.GetNum("Medieval_research_level");
		round.MapSetupRelay = view_as<bool>(kv.GetNum("map_setup_fake"));
		round.Xp = kv.GetNum("xp");
		round.Setup = kv.GetFloat("setup");
		round.NoMiniboss = view_as<bool>(kv.GetNum("no_miniboss"));

		round.music_round_1.SetupKv("music_1", kv);
		round.music_round_2.SetupKv("music_2", kv);
		
		kv.GetString("music_track_outro", round.music_round_outro, sizeof(round.music_round_outro));
		round.MusicOutroDuration = kv.GetNum("music_outro_duration");
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
			kv.GetColor("fogcolor", round.FogColor1[0], round.FogColor1[1], round.FogColor1[2], round.FogColor1[3]);
			kv.GetColor("fogcolor2", round.FogColor2[0], round.FogColor2[1], round.FogColor2[2], round.FogColor2[3]);
			round.FogStart = kv.GetFloat("fogstart");
			round.FogEnd = kv.GetFloat("fogend");
			round.FogDesnity = kv.GetFloat("fogmaxdensity");
			round.FogBlend = kv.GetNum("fogblend");
		}

		int nonBosses;

		round.Waves = new ArrayList(sizeof(Wave));
		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(kv.GetSectionName(buffer, sizeof(buffer)) && StrContains(buffer, "music") != 0)
				{
					kv.GetString("plugin", plugin, sizeof(plugin));
					if(plugin[0])
					{
						enemy.Index = NPC_GetByPlugin(plugin);
						if(enemy.Index == -1)
						{
							LogError("[Config] Unknown NPC '%s' in waves", plugin);
							continue;
						}

						wave.Delay = StringToFloat(buffer);
						wave.Count = kv.GetNum("count", 1);

						kv.GetString("relayname", wave.RelayName, sizeof(wave.RelayName));
						kv.GetString("relayfire", wave.RelayFire, sizeof(wave.RelayFire));
						
						enemy.Health = kv.GetNum("health");
						enemy.Is_Boss = kv.GetNum("is_boss");
						enemy.ForceScaling = kv.GetNum("force_scaling"); //0 is nothing, 1 means it forces normal scaling for ammount
						//good for boss rushes
						enemy.WaitingTimeGive = kv.GetFloat("waiting_time_give", 0.0);
						enemy.Does_Not_Scale = kv.GetNum("does_not_scale");
						enemy.ignore_max_cap = kv.GetNum("ignore_max_cap");
						if(wave.Count <= 0)
						{
							enemy.Does_Not_Scale = true;
						}
						enemy.Is_Outlined = kv.GetNum("is_outlined");
						enemy.Is_Health_Scaled = kv.GetNum("is_health_scaling");
						enemy.Is_Immune_To_Nuke = kv.GetNum("is_immune_to_nuke");
						enemy.Is_Static = view_as<bool>(kv.GetNum("is_static"));
						enemy.Team = kv.GetNum("team_npc", 3);
						enemy.Credits = kv.GetFloat("cash");
						enemy.ExtraMeleeRes = kv.GetFloat("extra_melee_res", 1.0);
						enemy.ExtraRangedRes = kv.GetFloat("extra_ranged_res", 1.0);
						enemy.ExtraSpeed = kv.GetFloat("extra_speed", 1.0);
						enemy.ExtraDamage = kv.GetFloat("extra_damage", 1.0);
						enemy.ExtraSize = kv.GetFloat("extra_size", 1.0);
						enemy.ExtraThinkSpeed = kv.GetFloat("extra_thinkspeed", 1.0);
						wave.DangerLevel = kv.GetNum("danger_level");
						int PrioLevel = 0;
						enemy.Priority = 0;
						if(kv.GetNum("is_boss") > 0)
						{
							//if its a boss, it should always have priority no matter what
							enemy.Priority = 1;
						}
						PrioLevel = kv.GetNum("priority", -1);
						if(PrioLevel >= 0)
						{
							//incase you want to override priorities
							enemy.Priority = PrioLevel;
						}
						
						kv.GetString("data", enemy.Data, sizeof(enemy.Data));
						kv.GetString("spawn", enemy.Spawn, sizeof(enemy.Spawn));
						kv.GetString("custom_name", enemy.CustomName, sizeof(enemy.CustomName));
						if(!enemy.Credits)
							nonBosses++;
						
						if(enemy.Team == 4 && Rogue_GetChaosLevel() > 3)
						{
							enemy.Team = TFTeam_Red;
							enemy.Health /= 10;
							enemy.ExtraDamage *= 5.0;
						}
						
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

				round.CashShould = round.Cash;
				round.Cash = 0;
			}
		}
		
		Rounds.PushArray(round);
	} while(kv.GotoNextKey());

	int waves = Rounds.Length;
	if(waves > 58 || waves < 29)
	{
		if(waves > 1)	//incase some wavetype has only 1 waves 
			waves--;	//this makes it scale cleanly on fastmode. since Rounds.Length gets the wave amount PLUS 1. so 40 waves is 41, 60 is 61, etc.
		//if we are above 40 waves, we dont change it from 1.0, i.e. it cant go lower!
		MinibossScalingHandle = (40.0 / float(waves));
		if(MinibossScalingHandle <= 1.0)
			MinibossScalingHandle = 1.0;
	}
	else
	{
		MinibossScalingHandle = 1.0;
	}

	if(OverrideScalingManually != 0.0)
		MinibossScalingHandle = OverrideScalingManually;

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
	else
	{
		bool RoundHadCustomMusic = BGMusicSpecial1.Valid();
	
		if(MusicString1.Valid())
			RoundHadCustomMusic = true;
				
		if(MusicString2.Valid())
			RoundHadCustomMusic = true;

		if(RaidMusicSpecial1.Valid())
			RoundHadCustomMusic = true;

		Rounds.GetArray(0, round);

		if(RoundHadCustomMusic) //only do it when there was actually custom music previously
		{	
			bool ReplaceMusic = false;
			//there was music the previous round, but there is none now.
			if(!round.music_round_1.Valid() && MusicString1.Valid())
			{
				ReplaceMusic = true;
			}
			//they are different, cancel out.
			if(round.music_round_1.Valid())
			{
				if(!StrEqual(MusicString1.Path, round.music_round_1.Path))
				{
					ReplaceMusic = true;
				}
			}
			if(!round.music_round_2.Valid() && MusicString2.Valid())
			{
				ReplaceMusic = true;
			}
			//they are different, cancel out.
			if(round.music_round_2.Valid())
			{
				if(!StrEqual(MusicString2.Path, round.music_round_2.Path))
				{
					ReplaceMusic = true;
				}
			}

			//if it had raid music, replace anyways!
			if(RaidMusicSpecial1.Valid())
				ReplaceMusic = true;
			
			if(ReplaceMusic)
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						SetMusicTimer(client, GetTime() + RoundToNearest(round.Setup) + 2); //This is here beacuse of raid music.
						Music_Stop_All(client);
					}
				}	
			}
		}

		//This should nullfy anyways if nothings in it
		RemoveAllCustomMusic();

		round.music_round_1.CopyTo(MusicString1);
		round.music_round_2.CopyTo(MusicString2);
	}

	Waves_UpdateMvMStats();
	DoGlobalMultiScaling();
}

void Waves_RoundStart(bool event = false)
{
	if(event)
	{
		if(SkyNameRestore[0])
		{
			CvarSkyName.SetString(SkyNameRestore, true);
			SkyNameRestore[0] = 0;
		}

		ClearCustomFog(FogType_Wave);
	}
	
	Waves_ClearWaves();
	
	Waves_RoundEnd();
	Freeplay_ResetAll();

	Kit_Fractal_ResetRound();
	
	if(Construction_Mode() || Rogue_Mode() || BetWar_Mode())
	{
		
	}
	else if(Voting)
	{
		float wait = zr_waitingtime.FloatValue;
		if(VotingMods)
		{
			if(wait < 90.0 || Voting.Length < 3)
				CanReVote = false;
			
			if(wait < 60.0)
				delete VotingMods;
		}
		else if(wait < 60.0 || Voting.Length < 3)
		{
			CanReVote = false;
		}
		
		float time = wait - (CanReVote ? 30.0 : 0.0);
		if(VotingMods)
			time -= 30.0;
		
		if(time < 20.0)
			time = 20.0;

		if(VotingMods && Voting.Length < 2)
			time = 1.0;
		
		VoteEndTime = GetGameTime() + time;
		CreateTimer(time, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

		if(wait < time)
			wait = time;

		//SpawnTimer(wait);
		//CreateTimer(wait, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		
		Waves_SetReadyStatus(2);
	}
	else
	{
		delete VotingMods;

		if(FirstMapRound)
		{
			FirstMapRound = false;
			CreateTimer(zr_waitingtime.FloatValue, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
			Waves_SetReadyStatus(2);
			//Stop music.
		}
		else
		{
			Waves_SetReadyStatus(1);
		}
	}

	//music\mvm_class_menu_bg.wav
	if(CurrentCash != StartCash)
	{
		Store_Reset();
		CurrentGame = GetTime();
		CurrentCash = StartCash;
		for(int client=1; client<=MaxClients; client++)
		{
			CurrentAmmo[client] = CurrentAmmo[0];
			if(IsClientInGame(client) && IsPlayerAlive(client))
				TF2_RegeneratePlayer(client);
		}
	}
	if(CvarInfiniteCash.BoolValue)
		CurrentCash = 999999;

	if(BetWar_Mode())
	{
		BetWar_StartSetup();
	}
	else if(Construction_Mode())
	{
		Construction_StartSetup();
	}
	else if(Rogue_Mode())
	{
		Rogue_StartSetup();
	}

	Waves_UpdateMvMStats();
}

void Waves_RoundEnd()
{
	Cooldown = 0.0;
	InSetup = true;
//	InFreeplay = false;
	CurrentRound = 0;
	RelayCurrentRound = 0;
	CurrentWave = -1;
	Medival_Difficulty_Level = 0.0; //make sure to set it to 0 othrerwise waves will become impossible
	Medival_Difficulty_Level_NotMath = 0;

	if(Rogue_Mode() || Construction_Mode())
		delete Rounds;
}

public Action Waves_RoundStartTimer(Handle timer)
{
	if(!Voting && !VotingMods)
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
		}
		else
		{
			CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		
	}
	return Plugin_Continue;
}

public Action Waves_AllowVoting(Handle timer)
{
	Waves_SetReadyStatus(1);
	SPrintToChatAll("이제 준비(F4)를 할 수 있습니다.");
	return Plugin_Continue;
}

public Action Waves_EndVote(Handle timer, float time)
{
	ArrayList list = Voting ? Voting : VotingMods;
	if(list)
	{
		int length = list.Length;
		if(length)
		{
			Waves_DisplayHintVote();

			int[] votes = new int[length];
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					DoOverlay(client, "", 2);
					if(VotedFor[client]>0 && VotedFor[client] <= length && GetClientTeam(client)==2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}

			if(CanReVote)
			{
				int high1 = 0;	
				int high2 = -1;
				int high3 = -1;
				for(int i = 1; i < length; i++)
				{
					if(votes[i])
					{
						if(votes[i] > votes[high1])
						{
							high3 = high2;
							high2 = high1;
							high1 = i;
						}
						else if(high2 == -1 || votes[i] > votes[high2])
						{
							high3 = high2;
							high2 = i;
						}
						else if(high3 == -1 || votes[i] > votes[high3])
						{
							high3 = i;
						}
					}
				}

				if(high3 != -1 && votes[high3])
				{
					high1 = votes[high2];
					for(int i = length - 1; i >= 0; i--)
					{
						if(votes[i] < high1)
						{
							list.Erase(i);
						}
					}

					Zero(VotedFor);
					CanReVote = false;
					VoteEndTime = GetGameTime() + 30.0;
					CreateTimer(30.0, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
					PrintHintTextToAll("Vote for the top %d options!", list.Length);
					SPrintToChatAll("Vote for the top %d options!", list.Length);
					Waves_SetReadyStatus(2);
					return Plugin_Continue;
				}
				else
				{
					CanReVote = false;
				}
			}
			
			int highest;
			for(int i=1; i<length; i++)
			{
				if(votes[i] > votes[highest])
					highest = i;
			}

			bool normal = Voting == list;
			
			Vote vote;
			list.GetArray(highest, vote);
			
			if(VotingMods == list)
			{
				delete VotingMods;
			}
			else
			{
				delete Voting;
			}
			
			if(normal)
			{
				strcopy(LastWaveWas, sizeof(LastWaveWas), vote.Config);
				CPrintToChatAll("{crimson}%t: %s","Difficulty set to", vote.Name);
				EmitSoundToAll("ui/chime_rd_2base_neg.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 70);
				EmitSoundToAll("ui/chime_rd_2base_pos.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 120);

				char buffer[PLATFORM_MAX_PATH];
				if(votes[highest] > 3)
				{
					BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "vote_trackedvotes.cfg");
					KeyValues kv = new KeyValues("TrackedVotes");
					kv.ImportFromFile(buffer);
					kv.SetNum(vote.Name, kv.GetNum(vote.Name) + 1);
					kv.ExportToFile(buffer);
					delete kv;
				}
				
				vote.Name[0] = CharToUpper(vote.Name[0]);

				Queue_DifficultyVoteEnded();
				if(!VotingMods)
					Native_OnDifficultySet(highest, vote.Name, vote.Level);
				
				if(highest > 3)
					highest = 3;
				
				Waves_SetDifficultyName(vote.Name);
				WaveLevel = vote.Level;
				
			//	Format(vote.Name, sizeof(vote.Name), "FireUser%d", highest + 1);
			//	ExcuteRelay("zr_waveselected", vote.Name);
				
				BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
				KeyValues kv = new KeyValues("Waves");
				kv.ImportFromFile(buffer);
				Waves_SetupWaves(kv, false);
				delete kv;
				Waves_SetReadyStatus(2);

				if(VotingMods)
				{
					float duration = CanReVote ? 30.0 : 60.0;
					
					Zero(VotedFor);
					VoteEndTime = GetGameTime() + duration;
					CreateTimer(1.0, Waves_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					CreateTimer(duration, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

					PrintHintTextToAll("Vote for the wave modifier!");
					SPrintToChatAll("Vote for the wave modifier!");
				}
				else
				{
					Waves_SetReadyStatus(1);
				}

				DoGlobalMultiScaling();
				Waves_UpdateMvMStats();
			}
			else
			{
				CPrintToChatAll("{crimson}%t: %s", "Modifier set to", vote.Name);
				if(vote.Desc[0])
					PrintToChatAll("%t", vote.Desc);

				ChatSetupTip();
				EmitSoundToAll("ui/chime_rd_2base_neg.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 70);
				EmitSoundToAll("ui/chime_rd_2base_pos.wav", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0, 120);
				
				if(highest > 0)
				{
					float multi = float(vote.Level) / 1000.0;

					int level = WaveLevel;
					if(level < 20) 
						level = 20;
					//assume 20 is the minimum.
					
					WaveLevel += RoundFloat(level * multi);

					Native_OnDifficultySet(-1, WhatDifficultySetting_Internal, WaveLevel);
					
					FormatEx(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s [%s]", WhatDifficultySetting_Internal, vote.Name);
					Waves_SetDifficultyName(WhatDifficultySetting);

					char funcs[5][64];
					ExplodeString(vote.Config, ";", funcs, sizeof(funcs), sizeof(funcs[]));
					
					Function func = funcs[0][0] ? GetFunctionByName(null, funcs[0]) : INVALID_FUNCTION;
					ModFuncRemove = funcs[1][0] ? GetFunctionByName(null, funcs[1]) : INVALID_FUNCTION;
					ModFuncAlly = funcs[2][0] ? GetFunctionByName(null, funcs[2]) : INVALID_FUNCTION;
					ModFuncEnemy = funcs[3][0] ? GetFunctionByName(null, funcs[3]) : INVALID_FUNCTION;
					ModFuncWeapon = funcs[4][0] ? GetFunctionByName(null, funcs[4]) : INVALID_FUNCTION;

					if(func != INVALID_FUNCTION)
					{
						Call_StartFunction(null, func);
						Call_Finish();
					}
				}
				else
				{
					Native_OnDifficultySet(-1, WhatDifficultySetting_Internal, WaveLevel);
				}

				Waves_SetReadyStatus(1);
				DoGlobalMultiScaling();
				Waves_UpdateMvMStats();
			}
		}
		else
		{
			if(VotingMods == list)
			{
				delete VotingMods;
			}
			else
			{
				delete Voting;
			}
		}
	}
	else
	{
		Waves_SetReadyStatus(1);
	}

	return Plugin_Continue;
}

void Waves_ClearWaves()
{
	delete Enemies[0];
	delete Enemies[1];
	delete Enemies[2];
}

void Waves_Progress(bool donotAdvanceRound = false)
{
	/*PrintCenterTextAll("Waves_Progress %d | %d | %d | %d | %d", InSetup ? 0 : 1,
		Rounds ? 1 : 0,
		CvarNoRoundStart.BoolValue ? 0 : 1,
		GameRules_GetRoundState() == RoundState_BetweenRounds ? 0 : 1,
		Cooldown > GetGameTime() ? 0 : 1);*/
	
	if(InSetup || !Rounds || CvarNoRoundStart.BoolValue || GameRules_GetRoundState() == RoundState_BetweenRounds || Cooldown > GetGameTime() || BetWar_Mode())
		return;

	Cooldown = GetGameTime();
	ProgressTimerEndAt = 0.0;
	delete WaveTimer;
	
	Round round;
	Wave wave;
	int length = Rounds.Length-1;
	bool panzer_spawn = false;
	bool panzer_sound = false;
	bool subgame = (Rogue_Mode() || Construction_Mode());
	static int panzer_chance;
	bool GiveAmmoSupplies = true;

	if(CurrentRound < length)
	{
		Rounds.GetArray(CurrentRound, round);
		if(++CurrentWave < round.Waves.Length)
		{
			f_FreeplayDamageExtra = 1.0;
			round.Waves.GetArray(CurrentWave, wave);

			if(!CurrentWave)
			{
				Rogue_TriggerFunction(Artifact::FuncWaveStart);

				if(Classic_Mode())
					Classic_NewRoundStart(round.Cash);
			}

			if(wave.RelayName[0])
				ExcuteRelay(wave.RelayName, wave.RelayFire);
			
			DoGlobalMultiScaling();
			
			int Is_a_boss = wave.EnemyData.Is_Boss;
			bool ScaleWithHpMore = wave.Count == 0;

			float WaitingTimeGive = wave.EnemyData.WaitingTimeGive;
			if(!LastMann && WaitingTimeGive > 0.0)
			{
				SPrintToChatAll("준비 시간 %.1f 초 드립니다.",WaitingTimeGive);
				GiveProgressDelay(WaitingTimeGive);
				f_DelaySpawnsForVariousReasons = GetGameTime() + WaitingTimeGive;
				SpawnTimer(WaitingTimeGive);
			}
			
			if(Is_a_boss >= 2)
			{
				if(Is_a_boss == 2)
				{
					if(LastMann && !b_IsAloneOnServer)
					{
						SPrintToChatAll("레이드 보스 등장 전까지 45 초 남았습니다... 준비하십시오");
						GiveProgressDelay(45.0);
						f_DelaySpawnsForVariousReasons = GetGameTime() + 45.0;
						SpawnTimer(45.0);
					}
					else if(WaitingTimeGive <= 0.0)
					{
						SPrintToChatAll("레이드 보스 등장 전까지 30 초 남았습니다... 준비하십시오.");
						GiveProgressDelay(30.0);
						f_DelaySpawnsForVariousReasons = GetGameTime() + 30.0;
						SpawnTimer(30.0);
					}
					Citizen_SetupStart();
				}
				Music_EndLastmann();
				RespawnCheckCitizen();
				//if its setboss 4, itll force respawn everyone.
				/*
				if(Is_a_boss == 4)
					ReviveAll(_,_,true);
				else
					ReviveAll(true);
				*/
				ReviveAll(_,_,true);

				CheckAlivePlayers();
				WaveEndLogicExtra();
			}
			
			int count = wave.Count;
			
			if(wave.EnemyData.Does_Not_Scale == 0 && count > 0)
			{
				if(Is_a_boss == 0 || wave.EnemyData.ForceScaling == 1)
				{
					count = RoundToNearest(float(count) * MultiGlobalEnemy);
					//the scaling on this cant be too high, otherwise rounds drag on forever.
				}
				else
				{
					//if its a boss, then it scales like old logic, beacuse bosses should spawn more as they have more of an impact
					count = RoundToNearest(float(count) * MultiGlobalEnemyBoss);
				}
			}
			
			if(count < 1) //So its always 1
				count = 1;
				
			
			if(wave.EnemyData.ignore_max_cap == 0)
			{
				if(count > 250) //So its always less then 250, except if defined otherwise.
					count = 250;
			}
			
			if(wave.EnemyData.Team != TFTeam_Red)
			{
				Zombies_Currently_Still_Ongoing += count;
			}
			
			
			int Is_Health_Scaling;
			
			Is_Health_Scaling = 0;
			
			BalanceDropMinimum(MultiGlobalEnemy);
			
			Is_Health_Scaling = wave.EnemyData.Is_Health_Scaled;
			
			if(Is_a_boss >= 1 || Is_Health_Scaling >= 1)
			{			
				float multiBoss;
				//note: do not use exponential formulars
				/*
					They are just too unbalanced.
					Lets treat each player as just more hp flat.
				*/
				if(ScaleWithHpMore)
				{
					multiBoss = MultiGlobalHighHealthBoss;
				}
				if(!ScaleWithHpMore)
				{
					multiBoss = MultiGlobalHealthBoss;
				}

				if(!ScaleWithHpMore && wave.Count > 0)
				{
					// Increase boss health
					multiBoss *= MultiGlobalEnemyBoss;

					//Give extra damage to bosses that scale like this, but only half as much.
					wave.EnemyData.ExtraDamage = wave.EnemyData.ExtraDamage * (((MultiGlobalScalingBossExtra - 1.0) * 0.5) + 1.0);
					// Decrease for every boss spawned
					float decrease = float(count) / float(wave.Count);
					if(decrease > 1.0)
					{
						multiBoss /= decrease;
					}
				}
				
				int Tempomary_Health = RoundToNearest(float(wave.EnemyData.Health) * multiBoss);
				wave.EnemyData.Health = Tempomary_Health;
			}
		
			for(int i; i<count; i++)
			{
				Waves_AddNextEnemy(wave.EnemyData, view_as<bool>(wave.EnemyData.ignore_max_cap));
			}
			
			if(wave.Delay > 0.0)
			{
				float delay = wave.Delay * (1.0 + (MultiGlobalEnemy * 0.4));
				WaveTimer = CreateTimer(delay, Waves_ProgressTimer);
				ProgressTimerType = CurrentWave == (round.Waves.Length - 1);
				
				if(delay > 9.0)
					ProgressTimerEndAt = GetGameTime() + delay;
			}
		}
		else if(donotAdvanceRound)
		{
			CurrentWave = round.Waves.Length - 1;
			GiveAmmoSupplies = false;
		}
		else
		{
			int PrevRoundMusic = 0;
			WaveEndLogicExtra();

			if(!Classic_Mode())
			{
				int CashGive = round.Cash;
				Native_OnGivenCash(0, CashGive);
				CurrentCash += CashGive;

				if(CashGive)
				{
					if(Construction_Mode())
					{
						CPrintToChatAll("%t", "Gained Material", CashGive, "Cash");
					}
					else
					{
						CPrintToChatAll("{green}%t","Cash Gained This Wave", CashGive);
					}
				}
			}
			
			Citizen_WaveStart();
			ExcuteRelay("zr_wavedone");
			Waves_ResetCashGiveWaveEnd();
			CurrentRound++;
			CurrentWave = -1;
			//This ensures no invalid spawn happens.
			Spawners_Timer();
			if(CurrentRound != length)
			{
				char ExecuteRelayThings[64];

				// 60 Wave Scaling
				int ScalingDoWavesDone = CurrentRound;
				if(OverrideScalingManually != 0.0)
				{
					ScalingDoWavesDone = RoundToFloor(float(CurrentRound) * OverrideScalingManually);
				}
				else if(length < 59)
				{
					ScalingDoWavesDone = RoundToFloor(float(CurrentRound) * (60.001 / float(length - 1)));
				}
				
				for(; RelayCurrentRound < ScalingDoWavesDone ; RelayCurrentRound++)
				{
					//old logic
					FormatEx(ExecuteRelayThings, sizeof(ExecuteRelayThings), "zr_wavefinish_wave_%d", RelayCurrentRound + 1);
					ExcuteRelay(ExecuteRelayThings);
				}

				// No Scaling
				FormatEx(ExecuteRelayThings, sizeof(ExecuteRelayThings), "zr_waveend_%d", CurrentRound);
				ExcuteRelay(ExecuteRelayThings);
			}

			bool wasEmptyWave = !round.Waves.Length;
			
			if(!wasEmptyWave)
				Native_OnWaveEnd();

			RequestFrames(StopMapMusicAll, 60);
			
			Waves_ClearWaves();

			bool music_stop = false;
			//Do we stop the music ?
			//If theres an outro track, play it here.
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
			PrevRoundMusic = round.MusicOutroDuration;

			//If there was a music outro, was duration did it have? Set the music timer delay here.
			if(PrevRoundMusic > 0)
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && !b_IsPlayerABot[client])
					{
						SetMusicTimer(client, GetTime() + round.MusicOutroDuration); //This is here beacuse of raid music.
					}
				}
			}

			//was the a leaving round message?
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
				CPrintToChatAll("{crimson}%t", round.Message);
			}
			//Did we beforehand stop the music, due to playing an outtro track?
			//if yes, remove it here.
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !b_IsPlayerABot[client])
				{
					if(music_stop)
					{
						Music_Stop_All(client);
					}
				}
			}
			if(round.music_setup.Valid()&&round.Override_Music_Setup)
			{
				round.music_setup.CopyTo(MusicSetup1);
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && !b_IsPlayerABot[client])
						SetMusicTimer(client, GetTime() + 5);
				}
			}
			if(round.GrigoriMaxSellsItems > 0)
			{
				GrigoriMaxSells = round.GrigoriMaxSellsItems;
			}

			bool refreshNPCStore;
			if(round.SpawnGrigori)
			{
				Spawn_Cured_Grigori();
				refreshNPCStore = true;
				if(i_SpecialGrigoriReplace == 2)
				for(int client_Grigori=1; client_Grigori<=MaxClients; client_Grigori++)
				{
					if(IsClientInGame(client_Grigori) && GetClientTeam(client_Grigori)==2)
					{
						if(i_SpecialGrigoriReplace == 0)
						{
							ClientCommand(client_Grigori, "playgamesound vo/ravenholm/yard_greetings.wav");
							SetHudTextParams(-1.0, -1.0, 3.01, 34, 139, 34, 255);
							SetGlobalTransTarget(client_Grigori);
							ShowSyncHudText(client_Grigori,  SyncHud_Notifaction, "%t", "Father Grigori Spawn");	
						}	
						else if(i_SpecialGrigoriReplace == 2)
						{
							SetHudTextParams(-1.0, -1.0, 3.01, 125, 125, 125, 255);
							SetGlobalTransTarget(client_Grigori);
							ShowSyncHudText(client_Grigori,  SyncHud_Notifaction, "%t", "The World Machine Spawn");	
						}
					}
				}
			}
			
			// Above is the round that just ended
			Rounds.GetArray(CurrentRound, round);
			// Below is the new round
			
			if(round.MapSetupRelay)
			{
				ExcuteRelay("zr_setuptime");
				Citizen_SetupStart();
				f_DelaySpawnsForVariousReasons = GetGameTime() + 1.5; //Delay spawns for 1.5 seconds, so maps can do their thing.
				RequestFrames(StopMapMusicAll, 60);
			}
			
			if(round.Skyname[0])
				Waves_SetSkyName(round.Skyname);

			if(round.FogChange)
				SetCustomFog(FogType_Wave, round.FogColor1, round.FogColor2, round.FogStart, round.FogEnd, round.FogDesnity, round.FogBlend, true);
			
			//Loop through all the still alive enemies that are indexed!
			int Zombies_alive_still = 0;

			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int npc_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if (IsValidEntity(npc_index))
				{
					if(!b_NpcHasDied[npc_index])
					{
						if(GetTeam(npc_index) != TFTeam_Red)
						{
							Zombies_alive_still += 1;
						}
					}
				}
			}
			Zombies_Currently_Still_Ongoing = 0;
			Zombies_Currently_Still_Ongoing = Zombies_alive_still;
			
			/*
			if(!subgame && CurrentRound >= RoundToNearest(12.0 * (1.0 / MinibossScalingReturn())))
			{
				int count;
				int i = MaxClients + 1;
				while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
				{
					if(!b_NpcHasDied[i])
					{
						if(Citizen_IsIt(i))
							count++;
					}
				}
			}
			// ?????? Old code, we dont know what it does.
			*/
			//always increase chance of miniboss.
			if(CurrentRound == (RoundToNearest(7.0 * (1.0 / MinibossScalingReturn()))) && !round.NoMiniboss)
			{
				panzer_spawn = true;
				panzer_sound = true;
				panzer_chance = 10;
			}
			else if((CurrentRound > RoundToNearest(7.0 * (1.0 / MinibossScalingReturn())) && round.Setup <= 30.0 && !round.NoMiniboss))
			{
				bool chance = (panzer_chance == 10 ? false : !GetRandomInt(0, panzer_chance));
				if(panzer_chance != 10)
					Modifier_MiniBossSpawn(chance);
				
				panzer_spawn = chance;
				panzer_sound = chance;
				panzer_chance--;
				if(panzer_spawn)
				{
					panzer_chance = 10;
				}
				else
				{
					Flagellant_MiniBossChance(panzer_chance);
				}
			}
			else
			{
				panzer_chance--;
				panzer_spawn = false;
				panzer_sound = false;
			}

			if(subgame) //disable
			{
				panzer_spawn = false;
				panzer_sound = false;
			}
			
			bool wasLastMann = (LastMann && EntRefToEntIndex(RaidBossActive) == -1);
			bool GiveBreakForPlayers = false;
			int PlayersOnServerLeft = CountPlayersOnRed(0);
			int PlayersaliveLeft = CountPlayersOnRed(1);
			if(PlayersOnServerLeft > 20)
			{
				PlayersOnServerLeft = 20;
				//its capped at a certain amount, cus if like 15 people are left alive in a 40 player server, 
				//its still fine, 20 is the cap imo.
			}
			if(CountPlayersOnRed(0) > 4)
			{
				//only do this above 4 players.
				if(float(PlayersOnServerLeft) * 0.38 >= (float(PlayersaliveLeft)))
				{
					//make it so if too many players died, itll assume the base is entirely dead, 
					//nothing is left, and only a few remain
					//This we give them a small break to rebuild, so this doesnt repeat.
					GiveBreakForPlayers = true;
				}
			}
			//if(!wasEmptyWave)
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						DoOverlay(client, "", 2);
						if(!wasEmptyWave && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING && f_PlayerLastKeyDetected[client] > GetGameTime() - 10.0)
						{
							//make sure client isnt afk.
							//Make sure client is playing the wave

							int xp = round.Xp;
							if(round.Xp)
							{
								//fast fix, as we dont want to edit EVERY single config.
								xp *= 5;
							}
							else
							{
								xp = WaveLevel;
								if(xp > 50)
									xp = 50;
								else if(xp < 25)
									xp = 25;
								
								if(CurrentCash < 5000)	// < 15 (5700 - 1000)
								{
									//xp *= 1;
								}
								else if(CurrentCash < 18000)	// < 30 (19300 - 2500)
								{
									xp *= 2;
								}
								else if(CurrentCash < 41000)	// < 45 (42050 - 5000)
								{
									xp *= 4;
								}
								else
								{
									xp *= 8;
								}
							}

							GiveXP(client, xp);
						
							if(round.Setup > 0.0)
							{
								SetGlobalTransTarget(client);
								PrintHintText(client, "%t","Press TAB To open the store");
							}
						}
					}
				}
				
				Music_EndLastmann();
				RespawnCheckCitizen();
				ReviveAll();
				CheckAlivePlayers();
			}
			BlockOtherRaidMusic = false;
			if(round.AmmoBoxExtra)
			{
				Ammo_Count_Ready += round.AmmoBoxExtra;	
			}
			if(round.Custom_Refresh_Npc_Store)
			{
				refreshNPCStore = true;
			}

			if(round.medival_difficulty != 0)
			{
				Medival_Wave_Difficulty_Riser(round.medival_difficulty); // Refresh me !!!
			}
			
			//MUSIC LOGIC
			bool RoundHadCustomMusic = BGMusicSpecial1.Valid();
			if(MusicString1.Valid())
				RoundHadCustomMusic = true;	
			if(MusicString2.Valid())
				RoundHadCustomMusic = true;
			if(RaidMusicSpecial1.Valid())
				RoundHadCustomMusic = true;

			//we previously had custom music, what do we do ?
			if(RoundHadCustomMusic)
			{	
				bool ReplaceMusic = false;
				if(!round.music_round_1.Valid() && MusicString1.Valid())
				{
					ReplaceMusic = true;
				}
				if(round.music_round_1.Valid())
				{
					if(!StrEqual(MusicString1.Path, round.music_round_1.Path))
					{
						ReplaceMusic = true;
					}
				}
				//there was music the previous round, but there is none now.
				if(!round.music_round_2.Valid() && MusicString2.Valid())
				{
					ReplaceMusic = true;
				}
				//they are different, cancel out.
				if(round.music_round_2.Valid())
				{
					if(!StrEqual(MusicString2.Path, round.music_round_2.Path))
					{
						ReplaceMusic = true;
					}
				}

				//if it had raid music, replace anyways.
				if(RaidMusicSpecial1.Valid())
					ReplaceMusic = true;
				
				if(ReplaceMusic)
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetMusicTimer(client, GetTime() + RoundToNearest(round.Setup) + 2); //This is here beacuse of raid music.
							Music_Stop_All(client);
						}
					}	
				}
			}

			//This should nullfy anyways if nothings in it
			RemoveAllCustomMusic();

			round.music_round_1.CopyTo(MusicString1);
			round.music_round_2.CopyTo(MusicString2);
			
			if(round.Setup > 1.0 && PrevRoundMusic <= 0)
			{
				if(round.Setup > 59.0)
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							//a little delay.
							SetMusicTimer(client, GetTime() + 1);
						}
					}
				}
				else if(MusicString1.Valid() || MusicString2.Valid())
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetMusicTimer(client, GetTime() + RoundToNearest(round.Setup));
						}
					}
				}
				else
				{
					//Reset and stop music?
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetMusicTimer(client, GetTime() + 1); //This is here beacuse of raid music.
							Music_Stop_All(client);
						}
					}
				}
			}

			SteamWorks_UpdateGameTitle();
			
			if(CurrentRound == length)
			{
				refreshNPCStore = true;
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				ExcuteRelay("zr_victory");
				
				if(!subgame)
				{
					Cooldown = GetGameTime() + 30.0;
					
					SpawnTimer(30.0);
					CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				}
				RequestFrames(StopMapMusicAll, 60);
				
				int total = 0;
				int[] players = new int[MaxClients];
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i))
					{
						if(!Construction_Mode() || Construction_FinalBattle())
							Music_Stop_All(i);

						if(!subgame)
						{
							SendConVarValue(i, sv_cheats, "1");
						}
						
						players[total++] = i;

						if(WaveGiftItem != -1 && PlayerPoints[i] > 500)
						{
							if(Items_GiveIdItem(i, WaveGiftItem))
								CPrintToChat(i,"{default}You have found {yellow}%s{default}!", Items_GetNameOfId(WaveGiftItem));
						}
					}
				}

				if(!subgame || Construction_FinalBattle())
				{
					ResetReplications();
					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.5, SetTimeBack);
					if(!Music_Disabled())
						EmitCustomToAll("#zombiesurvival/music_win_1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					

					if(i_WaveHasFreeplay > 0)
					{
						if(i_WaveHasFreeplay == 1)
						{
							Menu menu = new Menu(Waves_FreeplayVote);
							menu.SetTitle("%t","Victory Menu 2");
							menu.AddItem("", "Yes");
							menu.AddItem("", "No");
							menu.ExitButton = false;
							menu.DisplayVote(players, total, 30);
						}
						else
						{
							for (int client = 1; client <= MaxClients; client++)
							{
								if(IsValidClient(client) && GetClientTeam(client) == 2)
								{
									SetHudTextParams(-1.0, -1.0, 7.5, 0, 255, 255, 255);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client, SyncHud_Notifaction, "%t", "freeplay_start_1");
								}
							}
							Freeplay_Info = 1;
							CreateTimer(7.5, Freeplay_HudInfoTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
						}
					}
					else
					{
						ConVar roundtime = FindConVar("mp_bonusroundtime");
						float last = roundtime.FloatValue;
						roundtime.FloatValue = 20.0;

						ForcePlayerWin();

						roundtime.FloatValue = last;
					}
					
					RemoveAllCustomMusic(true);
				}
				else
				{
					RemoveAllCustomMusic();
				}

				if(subgame)
				{
					ClearCustomFog(FogType_Wave);
					
					if(Construction_Mode())
					{
						Construction_BattleVictory();
					}
					else if(Rogue_Mode())
					{
						Rogue_BattleVictory();
					}
				}

				Citizen_SetupStart();
			}
			else if(round.Setup > 0.0)
			{
				refreshNPCStore = true;
				InSetup = true;
				ExcuteRelay("zr_setuptime");

				if(round.Setup > 59.0)
				{
					for (int client = 1; client <= MaxClients; client++)
					{
						if(IsValidClient(client))
						{
							//saving XP and inventory, nothing else.
							Database_SaveXpAndItems(client);
						}
					}
					if(PrevRoundMusic > 0)
					{
						AlreadyWaitingSet(true);
					}
					if(EnableSilentMode)
					{
						Waves_SetReadyStatus(2);
						//wait a minimum of 30 seconds when theres too many players.
						SPrintToChatAll("30 초간은 준비할 수 없습니다.");
						CreateTimer(30.0, Waves_AllowVoting, _, TIMER_FLAG_NO_MAPCHANGE);
					}
					else
						Waves_SetReadyStatus(1);
				}
				else
				{
					Cooldown = GetGameTime() + round.Setup;

					SpawnTimer(round.Setup);
					CreateTimer(round.Setup, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				}
				RequestFrames(StopMapMusicAll, 60);

				Citizen_SetupStart();
			}
			else if(wasLastMann && !Rogue_Mode() && round.Waves.Length)
			{
				Cooldown = GetGameTime() + 45.0;

				SpawnTimer(45.0);
				CreateTimer(45.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				SPrintToChatAll("준비 시간 45 초 드립니다...");
			}
			else if(GiveBreakForPlayers && !Rogue_Mode() && round.Waves.Length)
			{
				Cooldown = GetGameTime() + 30.0;

				SpawnTimer(30.0);
				CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				SPrintToChatAll("많은 팀원이 사망했으므로, 준비 시간 30 초 드립니다...");
			}
			else
			{
				Store_RandomizeNPCStore(ZR_STORE_WAVEPASSED);
				if(refreshNPCStore)
					Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);

				
				NPC_SpawnNext(panzer_spawn, panzer_sound, -1);
				return;
			}

			Store_RandomizeNPCStore(ZR_STORE_WAVEPASSED);
			
			if(refreshNPCStore)
				Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);
			
		}
	}
	else if(subgame)
	{
		SPrintToChatAll("FREEPLAY OCCURED, BAD CFG, REPORT BUG");
		CurrentRound = 0;
		RelayCurrentRound = 0;
		CurrentWave = -1;
	}
	else
	{
		bool EarlyReturn = false;
		//We are in freeplay, past normal waves.
		if(i_WaveHasFreeplay == 2)
			EarlyReturn = Waves_NextFreeplayCall(donotAdvanceRound);
//		else if(i_WaveHasFreeplay == 1)
//			//EarlyReturn = Waves_NextSpecialWave();
		else
			SPrintToChatAll("웨이브가 알 수 없는 이유로 고장남. 빨리 리포트할 것.");

		if(EarlyReturn)
		{
			return;
		}
	}
	if(CurrentRound == 0 && !subgame)
	{
		if(StartCash < 1500)
		{
			for(int client=1; client<=MaxClients; client++)
			{
				GrantCreditsBack(client);
			}
		}
		
		Ammo_Count_Ready = 8;
	}

	if(!Construction_Mode() || Construction_FinalBattle())	// In Construction: Base raids must be dealt with
		WaveStart_SubWaveStart();
	
	if(CurrentWave == 0 && GiveAmmoSupplies)
	{
		Renable_Powerups();
		CheckIfAloneOnServer();
		Ammo_Count_Ready += 1;

		if(!Construction_Mode())
		{
			for (int target = 1; target <= MaxClients; target++)
			{
				if(i_CurrentEquippedPerk[target] & PERK_STOCKPILE_STOUT) 
				{
					Ammo_Count_Used[target] -= 1;
				}
			}
		}
	}
	else if (Gave_Ammo_Supply > 2 && GiveAmmoSupplies)
	{
		Ammo_Count_Ready += 1;
		Gave_Ammo_Supply = 0;

		if(!Construction_Mode())
		{
			for (int target = 1; target <= MaxClients; target++)
			{
				if(i_CurrentEquippedPerk[target] & PERK_STOCKPILE_STOUT) 
				{
					Ammo_Count_Used[target] -= 1;
				}
			}
		}
	}	
	else if(GiveAmmoSupplies)
	{
		Gave_Ammo_Supply += 1;	
	}
//	PrintToChatAll("Wave: %d - %d", CurrentRound+1, CurrentWave+1);

	Waves_UpdateMvMStats();
}

static Action Freeplay_HudInfoTimer(Handle timer)
{
	switch(Freeplay_Info)
	{
		case 0:
		{
			return Plugin_Stop;
		}
		case 1:
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client) && GetClientTeam(client) == 2)
				{
					SetHudTextParams(-1.0, -1.0, 7.5, 0, 255, 255, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "%t", "freeplay_start_2");
				}
			}
			Freeplay_Info = 2;
		}
		case 2:
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client) && GetClientTeam(client) == 2)
				{
					SetHudTextParams(-1.0, -1.0, 7.5, 255, 0, 0, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "%t", "freeplay_start_3");
				}
			}
			Freeplay_Info = 3;
		}
		case 3:
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client) && GetClientTeam(client) == 2)
				{
					SetHudTextParams(-1.0, -1.0, 7.5, 0, 255, 255, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "%t", "freeplay_start_4");
				}
			}
			FreeplayTimeLimit = GetGameTime() + 3607.5; // one hour and 7.5 extra seconds because of setup time smh
			CPrintToChatAll("{yellow}IMPORTANT: The faster you beat waves, the more cash AND experience you'll get!");
			CreateTimer(0.1, Freeplay_ExtraCashTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			Freeplay_Info = 0;
		}
		default:
		{
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

static Action Freeplay_ExtraCashTimer(Handle timer)
{
	if(FreeplayTimeLimit < GetGameTime())
	{
		return Plugin_Stop;
	}

	if(Freeplay_CashTimeLeft < GetGameTime())
	{
		if(Freeplay_TimeCash > 0.0)
		{
			Freeplay_TimeCash -= 3.5;
			if(Freeplay_TimeCash < 0.0)
				Freeplay_TimeCash = 0.0;
		}
	}

	return Plugin_Continue;
}

void Freeplay_SetCashTime(float duration)
{
	Freeplay_CashTimeLeft = duration;
}
float Freeplay_GetRemainingCash()
{
	return Freeplay_TimeCash;
}
void Freeplay_SetRemainingCash(float amount)
{
	Freeplay_TimeCash = amount;
}


public void Medival_Wave_Difficulty_Riser(int difficulty)
{
	CPrintToChatAll("{darkred}%t", "Medieval_Difficulty", difficulty);
	
	float difficulty_math = Pow(0.95, float(difficulty));
	
	if(difficulty_math < 0.1) //Just make sure that it doesnt go below.
	{
		difficulty_math = 0.1;
	}
	//invert the number and then just set the difficulty medival level to the % amount of damage resistance.
	//This means that you can go upto 100% dmg res but if youre retarded enough to do this then you might aswell have an unplayable experience.
	
	Medival_Difficulty_Level_NotMath = difficulty;
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
				ForcePlayerWin();
			}
		}
	}
	return 0;
}

bool Waves_IsEmpty()
{
	if((!Enemies[0] || !Enemies[0].Length)
	 && (!Enemies[1] || !Enemies[1].Length)
	  && (!Enemies[2] || !Enemies[2].Length))
		return true;
	
	return false;
}

bool Waves_GetNextEnemy(Enemy enemy)
{
	for(int i = sizeof(Enemies) - 1; i >= 0; i--)
	{
		if(!Enemies[i])
			continue;
		
		int length = Enemies[i].Length;
		if(!length)
			continue;
		
		Enemies[i].GetArray(length - 1, enemy);
		Enemies[i].Erase(length - 1);
		return true;
	}

	return false;
}

void Waves_AddNextEnemy(const Enemy enemy, bool random = false, int prio = -1)
{
	int slot = prio;
	if(slot < 0)
	{
		slot = enemy.Priority;
		if(slot < 0)
			slot = 0;
	}

	if(slot >= sizeof(Enemies))
		slot = sizeof(Enemies) - 1;
	
	if(!Enemies[slot])
		Enemies[slot] = new ArrayList(sizeof(Enemy));
	
	if(random)
	{
		int index = Enemies[slot].Length;
		if(index > 1)
		{
			index = GetURandomInt() % index;

			Enemies[slot].ShiftUp(index);
			Enemies[slot].SetArray(index, enemy);
			return;
		}
	}
	
	Enemies[slot].PushArray(enemy);
}

void Waves_ClearWave()
{
	if(Rounds && CurrentRound >= 0 && CurrentRound < Rounds.Length)
	{
		Round round;
		Rounds.GetArray(CurrentRound, round);
		CurrentWave = round.Waves.Length;
	}
	else
	{
		CurrentWave = -1;
	}
}

void Waves_ClearWaveCurrentSpawningEnemies()
{
	if(Enemies[0])
		Zombies_Currently_Still_Ongoing -= Enemies[0].Length;
	
	if(Enemies[1])
		Zombies_Currently_Still_Ongoing -= Enemies[1].Length;
	
	if(Enemies[2])
		Zombies_Currently_Still_Ongoing -= Enemies[2].Length;
	
	Waves_ClearWaves();
}

bool Waves_Started()
{
	if(BetWar_Mode())
		return BetWar_Started();
	
	if(Construction_Mode())
		return Construction_Started();
	
	if(Rogue_Mode())
		return Rogue_Started();
	
	return (CurrentRound || CurrentWave != -1);
}

int Waves_GetRoundScale()
{
	if(Construction_Mode())
		return Construction_GetRound();
	
	if(Rogue_Mode())
		return Rogue_GetRound();
	
	if(BetWar_Mode())
		return 1;

	if(Waves_InFreeplay())
	{
		int RoundGive = CurrentRound;
		if(RoundGive < 40)
		{
			RoundGive = 40; //should atleast always be treated as round 40.
		}
		return RoundGive;
	}

	return CurrentRound;
}

int Waves_GetMaxRound(bool real = false)
{
	return (!real && FakeMaxWaves) ? FakeMaxWaves : (Rounds.Length-1);
}

float GetWaveSetupCooldown()
{
	return Cooldown;
}

int Waves_GetLevel()
{
	return WaveLevel;
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
	VoidArea_ClearnNethersea();
	FallenWarriorGetRandomSeedEachWave();
	ResetAbilitiesWaveEnd();
	for(int client; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			b_BobsCuringHand_Revived[client] += GetRandomInt(1,2);
			if(Rogue_Theme() == ReilaRift)
			{
				//give 2x the shit
				b_BobsCuringHand_Revived[client] += GetRandomInt(1,2);
				b_BobsCuringHand_Revived[client] += GetRandomInt(1,2);
			}
		}
	}
}

void ResetAbilitiesWaveEnd()
{
	M3_AbilitiesWaveEnd();
	Specter_AbilitiesWaveEnd();	
	Rapier_CashWaveEnd();
	LeperResetUses();
	SniperMonkey_ResetUses();
	ResetFlameTail();
	Building_ResetRewardValuesWave();
	CastleBreaker_ResetCashGain();
	ZombieDrops_AllowExtraCash();
	Zero(i_MaxArmorTableUsed);
}

void WaveStart_SubWaveStart(float time = 0.0)
{
//	f_ZombieAntiDelaySpeedUp = Cooldown + 600.0;
	if(time == 0.0)
		f_ZombieAntiDelaySpeedUp = Cooldown + 420.0;
	else
		f_ZombieAntiDelaySpeedUp = time + 420.0;
	
	i_ZombieAntiDelaySpeedUp = 0; //warning off
}

void Zombie_Delay_Warning()
{
	if(!Waves_Started() || InSetup || Classic_Mode() || Construction_InSetup())
		return;

	switch(i_ZombieAntiDelaySpeedUp)
	{
		case 0:
		{
			if(f_ZombieAntiDelaySpeedUp < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 1;
				CPrintToChatAll("{crimson}적들이 불안해하고 있습니다...");
			}
		}
		case 1:
		{
			if(f_ZombieAntiDelaySpeedUp + 15.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 2;
				CPrintToChatAll("{crimson}적들이 점점 짜증내며 속도를 올리고 있습니다...");
			}
		}
		case 2:
		{
			if(f_ZombieAntiDelaySpeedUp + 35.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 3;
				CPrintToChatAll("{crimson}적들이 화를 내고 있어, 이동 속도가 더욱 증가하고 있습니다...");
			}
		}
		case 3:
		{
			if(f_ZombieAntiDelaySpeedUp + 55.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 4;
				CPrintToChatAll("{crimson}적들이 분노하여 이동 속도가 매우 빨라졌습니다...");
			}
		}
		case 4:
		{
			if(f_ZombieAntiDelaySpeedUp + 75.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 5;
				CPrintToChatAll("{crimson}적들이 완전히 격노하여 대상을 순식간에 쫒아갑니다...");
			}
		}
		case 5:
		{
			if(f_ZombieAntiDelaySpeedUp + 100.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 6;
				CPrintToChatAll("{crimson}죽어라.");
				
				if(Construction_Mode())
					ForcePlayerLoss();
			}
		}
		case 6:
		{
			if(f_ZombieAntiDelaySpeedUp + 400.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 7;
				CPrintToChatAll("{crimson}You are probably abusing something, perish, go my uber swordsmen.");
				if(!Rogue_Mode())
					AntiDelaySpawnEnemies(999999999, 5, true);
			}
		}
	}
}

void AntiDelaySpawnEnemies(int health = 0, int count, bool is_a_boss = false)
{
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin("npc_chaos_swordsman");
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 0.2;
	enemy.ExtraRangedRes = 0.2;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 9999.0;
	enemy.ExtraThinkSpeed = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = 3;
	for(int i; i<count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += count;
}

float Zombie_DelayExtraSpeed()
{
	if(InSetup || Classic_Mode())
		return 1.0;
	
	switch(i_ZombieAntiDelaySpeedUp)
	{
		case 2:
		{
			return 1.15;
		}
		case 3:
		{
			return 1.35;
		}
		case 4:
		{
			return 1.5;
		}
		case 5:
		{
			return 1.75;
		}
		case 6:
		{
			return 3.0;
		}
	}
	return 1.0;
}


void DoGlobalMultiScaling()
{
	float playercount = ZRStocks_PlayerScalingDynamic();

	if(playercount < 2.0)
		playercount = 2.0;
	
	int PlayersIngame = RoundToNearest(ZRStocks_PlayerScalingDynamic(0.0,true, true));

	if(PlayersIngame >= 19.0)
		EnableSilentMode = true;
	else
		EnableSilentMode = false;
	
	playercount *= 0.88;
	playercount *= GetScaledPlayerCountMulti(PlayersIngame);

	float multi = playercount / 4.0;
	
	Rogue_Rift_MultiScale(multi);
	
	//raids or super bosses health
	MultiGlobalHighHealthBoss = playercount * 0.34;
	if(MultiGlobalHighHealthBoss <= 0.8)
	{
		//on very low playercounts raids deal less damage anyways, so hp shouldnt go that low.
		MultiGlobalHighHealthBoss = 0.8;
	}

	//Enemy bosses AMOUNT
	float cap = zr_maxsbosscaling_untillhp.FloatValue;
	float BossMulti = playercount * 0.3; 

	if(BossMulti > cap)
	{
		MultiGlobalScalingBossExtra = BossMulti / cap;
		MultiGlobalEnemyBoss = cap;
	}
	else
	{
		MultiGlobalScalingBossExtra = 1.0;
		MultiGlobalEnemyBoss = BossMulti;
	}
	
	//normal bosses health
	MultiGlobalHealthBoss = playercount * 0.2;

	if(MultiGlobalHealthBoss <= 1.0)
	{
		//Enemy bosses AMOUNT affects HP too, so keeping  this on 1.0 is good.
		MultiGlobalHealthBoss = 1.0;
	}

	//scale extra HP higher
	MultiGlobalHealthBoss *= (((MultiGlobalScalingBossExtra - 1.0) * 0.75) + 1.0);

	//certain maps need this, if they are too big and raids have issues etc.
	MultiGlobalHighHealthBoss *= zr_raidmultihp.FloatValue;

	cap = zr_maxscaling_untillhp.FloatValue;

	if(multi > cap)
	{
		MultiGlobalHealth = multi / cap;
		MultiGlobalEnemy = cap;
	}
	else
	{
		MultiGlobalHealth = 1.0;
		MultiGlobalEnemy = multi;
	}

	MultiGlobalEnemy *= ZRModifs_MaxSpawnWaveModif();
	MultiGlobalEnemyBoss *= ZRModifs_MaxSpawnWaveModif();

	PlayerCountBuffScaling = 4.5 / playercount;
	if(PlayerCountBuffScaling > 1.0)
	{
		PlayerCountBuffScaling = 1.0;
	}
	//Shouldnt be lower then 0.25
	if(PlayerCountBuffScaling < 0.25)
	{
		PlayerCountBuffScaling = 0.25;
	}

	PlayerCountBuffAttackspeedScaling = 6.0 / playercount;
	if(PlayerCountBuffAttackspeedScaling > 1.0)
	{
		PlayerCountBuffAttackspeedScaling = 1.0;
	}
	//Shouldnt be lower then 0.5
	if(PlayerCountBuffAttackspeedScaling < 0.5)
	{
		PlayerCountBuffAttackspeedScaling = 0.5;
	}

	PlayerCountResBuffScaling = (1.0 - (playercount / 48.0)) + 0.1;
	if(PlayerCountResBuffScaling < 0.75)
	{
		PlayerCountResBuffScaling = 0.75;
	}
}

// Anything below this amount of players is considered "balanced" and players are each considered as pulling their weight.
#define SCALE_PLAYERCOUNT_CUTOFF    14
// Controls how quickly the scaling multiplier drops off.
// Lower values = slower decay, players beyond SCALE_PLAYERCOUNT_CUTOFF contribute much more to scaling, much longer
// Higher valeus = faster decay, players beyond SCALE_PLAYERCOUNT_CUTOFF contribute much less to scaling, much sooner
#define SCALE_DROP_RATE             0.04
// Lowest possible multiplier for high player counts.
// Once scaling settles, each player contributes at least 80% of a player, never lower.
// This only really matters for very high playercounts even beyond 40, simply a safeguard so it can't go into insanity.
#define SCALE_MIN_MUTIPLIER         0.8

// Returns the effective players for scaling
float GetScaledPlayerCountMulti(int players)
{
    if (players <= SCALE_PLAYERCOUNT_CUTOFF)
        return 1.0;
    
    float excess = float(players - SCALE_PLAYERCOUNT_CUTOFF);
    float multiplier = 1.0 - (1.0 - SCALE_MIN_MUTIPLIER) * (1.0 - Exponential(-SCALE_DROP_RATE * excess));

    return multiplier;
}

void ScalingMultiplyEnemyHpGlobalScale(int iNpc, float modif_hp = 1.0)
{
	float Maxhealth = float(ReturnEntityMaxHealth(iNpc));
	Maxhealth *= MultiGlobalHealth;
	Maxhealth *= modif_hp;
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToNearest(Maxhealth));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToNearest(Maxhealth));
}

void Waves_ForceSetup(float cooldown)
{
	Cooldown = GetGameTime() + cooldown;
	InSetup = true;
	
	CreateTimer(cooldown, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

static int GetObjectiveResource()
{
	return FindEntityByClassname(-1, "tf_objective_resource");
}
/*
static int GetMvMStats()
{
	return FindEntityByClassname(-1, "tf_mann_vs_machine_stats");
}
*/
void Waves_UpdateMvMStats(int frames = 10)
{
	if(!UpdateFramed)
	{
		UpdateFramed = true;
		RequestFrames(UpdateMvMStatsFrame, frames);
	}
}

static void UpdateMvMStatsFrame()
{
	//Profiler profiler = new Profiler();
	//profiler.Start();

	UpdateFramed = false;

	if(BetWar_UpdateMvMStats())
		return;

	if(Construction_UpdateMvMStats())
		return;

	if(Rogue_UpdateMvMStats())
		return;

	float cashLeft, totalCash;

	int activecount, totalcount;
	int id[48];
	int count[48];
	int flags[48];
	bool active[48];
	static char icon[48][32];

	if(Classic_Mode() && ProgressTimerEndAt)
	{
		id[0] = -1;
		count[0] = RoundToCeil(ProgressTimerEndAt - GetGameTime());
		flags[0] = ProgressTimerType ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
		strcopy(icon[0], sizeof(icon), ProgressTimerType ? "classic_defend" : "classic_reinforce");
		if(count[0] < 31)
			flags[0] += MVM_CLASS_FLAG_ALWAYSCRIT;
		
		active[0] = true;
		Waves_UpdateMvMStats(33);
	}
	
	NPCData data;
	int maxwaves = Rounds ? (Rounds.Length - 1) : 0;
	bool freeplay = !(maxwaves && CurrentRound >= 0 && CurrentRound < maxwaves);
	if(!freeplay)
	{
		Round round;
		Rounds.GetArray(CurrentRound, round);
		if(!InSetup && !Classic_Mode() && CurrentRound != (maxwaves - 1))
		{
			cashLeft += float(round.Cash);
			totalCash += float(round.Cash);
		}
		
		if(round.Waves)
		{
			Wave wave;
			int length = round.Waves.Length;
			for(int a = length - 1; a >= 0; a--)
			{
				round.Waves.GetArray(a, wave);

				int num = wave.Count;
				float cash = wave.EnemyData.Credits / float(num);
				
				if(wave.EnemyData.Does_Not_Scale == 0)
				{
					if(wave.EnemyData.Is_Boss == 0 || wave.EnemyData.ForceScaling == 1)
					{
						num = RoundToNearest(float(num) * MultiGlobalEnemy);
					}
					else
					{
						num = RoundToNearest(float(num) * MultiGlobalEnemyBoss);
					}
				}
				
				if(num < 1)
				{
					num = 1;
				}
				else if(num > 250)
				{
					if(wave.EnemyData.ignore_max_cap == 0)
						num = 250;
				}

				totalcount += num;
				totalCash += cash;
				
				if(a > CurrentWave)
				{
					cashLeft += cash;
					activecount += num;
				}
				else
				{
					num = 0;
				}

				for(int b; b < sizeof(id); b++)
				{
					if(!id[b] || id[b] == wave.EnemyData.Index)
					{
						if(!id[b])
						{
							NPC_GetById(wave.EnemyData.Index, data);
							if(data.Flags == -1)
								break;

							if(!data.Flags || wave.EnemyData.ignore_max_cap > 0)
							{
								flags[b] = SetupFlags(wave.EnemyData, false);
							}
							else
							{
								flags[b] = data.Flags;
							}
							
							if((flags[b] & MVM_CLASS_FLAG_SUPPORT) || (flags[b] & MVM_CLASS_FLAG_MISSION) || (flags[b] & MVM_CLASS_FLAG_SUPPORT_LIMITED))
							{
								// Only show "Support" when actually active
								if(!InSetup)
									break;
							}

							id[b] = wave.EnemyData.Index;

							if(data.Icon[0])
							{
								strcopy(icon[b], sizeof(icon[]), data.Icon);
							}
							else
							{
								strcopy(icon[b], sizeof(icon[]), "robo_extremethreat");
							}
							if(AprilFoolsIconOverride() == STEAM_HAPPY)
								strcopy(icon[b], sizeof(icon[]), "steamhappy");
						}

						count[b] += num;
						
						break;
					}
				}
			}
		}
	}
	
	for(int i = sizeof(Enemies) - 1; i >= 0; i--)
	{
		if(!Enemies[i])
			continue;
		static Enemy enemy;
		int length = Enemies[i].Length;
		for(int a; a < length; a++)
		{
			Enemies[i].GetArray(a, enemy);
			cashLeft += enemy.Credits;
			activecount++;

			for(int b; b < sizeof(id); b++)
			{
				if(!id[b] || id[b] == enemy.Index)
				{
					count[b]++;
					
					if(!id[b])
					{
						NPC_GetById(enemy.Index, data);
						if(data.Flags == -1)
							break;

						if(!data.Flags || enemy.ignore_max_cap > 0)
						{
							flags[b] = SetupFlags(enemy, (!Classic_Mode() && !freeplay));
						}
						else
						{
							flags[b] = data.Flags;
						}
						
						id[b] = enemy.Index;

						if(data.Icon[0])
						{
							strcopy(icon[b], sizeof(icon[]), data.Icon);
						}
						else
						{
							strcopy(icon[b], sizeof(icon[]), "robo_extremethreat");
						}
						if(AprilFoolsIconOverride() == STEAM_HAPPY)
							strcopy(icon[b], sizeof(icon[]), "steamhappy");
					}
					
					break;
				}
			}
		}
	}

	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(!b_NpcHasDied[entity] && GetTeam(entity) != TFTeam_Red)
		{
			cashLeft += f_CreditsOnKill[entity];
			activecount++;

			for(int b; b < sizeof(id); b++)
			{
				if(!id[b] || id[b] == i_NpcInternalId[entity])
				{
					count[b]++;
					active[b] = true;
					
					if(!id[b])
					{
						NPC_GetById(i_NpcInternalId[entity], data);
						if(data.Flags == -1)
							break;
						
						if(data.Flags)
						{
							flags[b] = data.Flags;
						}
						else
						{
							flags[b] = (freeplay || Classic_Mode() || b_thisNpcIsARaid[entity]) ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_SUPPORT;
							if(b_thisNpcIsABoss[entity] || b_thisNpcHasAnOutline[entity])
								flags[b] |= MVM_CLASS_FLAG_MINIBOSS;

							if(fl_Extra_MeleeArmor[entity] < 1.0 || 
							fl_Extra_RangedArmor[entity] < 1.0 || 
							fl_Extra_Speed[entity] > 1.0 || 
							fl_Extra_Damage[entity] > 1.0 ||
							b_thisNpcIsARaid[entity])
								flags[b] |= MVM_CLASS_FLAG_ALWAYSCRIT;
						}
						
						id[b] = i_NpcInternalId[entity];

						if(data.Icon[0])
						{
							strcopy(icon[b], sizeof(icon[]), data.Icon);
						}
						else
						{
							strcopy(icon[b], sizeof(icon[]), "robo_extremethreat");
						}
						if(AprilFoolsIconOverride() == STEAM_HAPPY)
							strcopy(icon[b], sizeof(icon[]), "steamhappy");
					}
					
					break;
				}
			}
		}
	}

	Classic_UpdateMvMStats(cashLeft);

	int objective = GetObjectiveResource();
	if(objective != -1)
	{
		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", Rogue_GetChaosLevel() > 2 ? (GetURandomInt() % 99999) : RoundToNearest(cashLeft));
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", totalcount > activecount ? totalcount : activecount);

		if(FakeMaxWaves)
			maxwaves = FakeMaxWaves;

		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", CurrentRound + 1);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", CurrentRound < maxwaves ? maxwaves : 0);

		static int maxCount;
		if(!maxCount)
		{
			int size1, size2;
			WaveSizeLimit(objective, size1, size2);
			maxCount = size1 + size2;
		}

		a = 0;
		for(int b; b < maxCount; )
		{
			// Out of enemies, blank out rest
			if(a >= sizeof(id))
			{
				Waves_SetWaveClass(objective, b);
				b++;
				continue;
			}

			// No enemy slotted here
			if(!id[a] || !count[a])
			{
				a++;
				continue;
			}

			// Rest of enemies to fill the meter
			if(b == (maxCount - 1))
			{
				int leftovers = count[a];

				for(a++; a < sizeof(id); a++)
				{
					if(id[a])
						leftovers += count[a];
				}

				Waves_SetWaveClass(objective, b, leftovers, "unknown", MVM_CLASS_FLAG_NORMAL, false);
				break;
			}
			
			// Add enemy here
			Waves_SetWaveClass(objective, b, count[a], icon[a], flags[a], active[a]);
			a++;
			b++;
		}
	}

	if(Rogue_GetChaosLevel() < 3)
		Waves_SetCreditAcquired(RoundFloat(totalCash - cashLeft));
	
	//profiler.Stop();
	//PrintToChatAll("Profiler: %f", profiler.Time);
	//delete profiler;
}

void Waves_SetCreditAcquired(int amount)
{
	//No warning, this is unused as of now.
	amount += 1;
	amount = amount + 1;
	/*
	int mvm = GetMvMStats();
	if(mvm != -1)
	{
		static char buffer[512];
		Format(buffer, sizeof(buffer), "NetProps.SetPropInt(self, \"m_currentWaveStats.nCreditsDropped\", %d); " ...
						"NetProps.SetPropInt(self, \"m_currentWaveStats.nCreditsAcquired\", %d); " ...
						"NetProps.SetPropInt(self, \"m_currentWaveStats.nCreditsBonus\", 0); " ...
						"NetProps.SetPropInt(self, \"m_runningTotalWaveStats.nCreditsDropped\", %d); " ...
						"NetProps.SetPropInt(self, \"m_runningTotalWaveStats.nCreditsAcquired\", %d); " ...
						"NetProps.SetPropInt(self, \"m_runningTotalWaveStats.nCreditsBonus\", %d);",
						amount, amount, CurrentCash - StartCash, CurrentCash - StartCash, GlobalExtraCash);
		SetVariantString(buffer);
		AcceptEntityInput(mvm, "RunScriptCode");
	}
	*/
}

static int SetupFlags(const Enemy data, bool support)
{
	int flags = 0;
	
	if(data.Is_Boss < 2 && (support || data.ignore_max_cap || data.Is_Static || data.Team == TFTeam_Red))
	{
		flags |= MVM_CLASS_FLAG_SUPPORT;
	}
	else
	{
		flags |= MVM_CLASS_FLAG_NORMAL;
	}

	if(data.Is_Boss || data.Is_Outlined)
		flags |= MVM_CLASS_FLAG_MINIBOSS;
	
	if(data.ExtraMeleeRes < 1.0 || 
	data.ExtraRangedRes < 1.0 || 
	data.ExtraSpeed > 1.0 || 
	data.ExtraDamage > 1.0 || 
	data.ExtraThinkSpeed > 1.0 ||
	data.Is_Boss > 1)
		flags |= MVM_CLASS_FLAG_ALWAYSCRIT;
	
	return flags;
}

static Handle ReadyUpTimer;

static Action ReadyUpHack(Handle timer)
{
	// We can't call ResetPlayerAndTeamReadyState to reset m_bPlayerReadyBefore
	// So the timer won't go down as players ready up again
	// Were doing it ourselves here
	
	if(FindEntityByClassname(-1, "tf_gamerules") != -1 && GameRules_GetRoundState() == RoundState_BetweenRounds)
	{
		float time = GameRules_GetPropFloat("m_flRestartRoundTime");
		if(time > 0.0)
			time -= GetGameTime();

		if(time < 12.0 && time > 8.0)
		{
			GameRules_SetPropFloat("m_flRestartRoundTime", GetGameTime() + 8.0);
			return Plugin_Continue;
		}
		int ready, players;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] != TEUTON_WAITING && IsClientInGame(client) && GetClientTeam(client) == TFTeam_Red)
			{
				players++;
				if(GameRules_GetProp("m_bPlayerReady", _, client))
					ready++;
			}
		}
		
		if(time > 12.0 || time < 0.0)
		{
			float set = -1.0;

			// Artvin Request: Start instantly at half players ready up
			ready *= 2;
			ready--;
			
			if(ready >= players)
			{
				set = 12.0;
			}
			else if(ready > 0)
			{
				set = 150.0 - (120.0 * float(ready - 1) / float(players - 1));
			}

			if(time != set && (time < 0.0 || set < time))
			{
				if(set > 0.0)
					set += GetGameTime();
				
				GameRules_SetPropFloat("m_flRestartRoundTime", set);
			}

			return Plugin_Continue;
		}
	}

	ReadyUpTimer = null;
	return Plugin_Stop;
}

bool AlreadySetWaiting = false;

void AlreadyWaitingSet(bool set)
{
	AlreadySetWaiting = set;
}
void Waves_SetReadyStatus(int status, bool stopmusic = true)
{
	//LogStackTrace("Hello! -> %d", status);
	switch(status)
	{
		case 0:	// Normal
		{
			InSetup = false;
			GameRules_SetProp("m_bInWaitingForPlayers", false);
			GameRules_SetProp("m_bInSetup", false);
			GameRules_SetProp("m_iRoundState", RoundState_ZombieRiot);
			//stop music once game starts.
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					SetMusicTimer(client, GetTime() + 2); //This is here beacuse of raid music.
					Music_Stop_All(client);
				}
			}	
			AlreadySetWaiting = false;
		}
		case 1:	// Ready Up
		{
			ChatSetupTip();
			GameRules_SetProp("m_bInWaitingForPlayers", true);
			GameRules_SetProp("m_bInSetup", true);
			GameRules_SetProp("m_iRoundState", RoundState_BetweenRounds);
			FindConVar("tf_mvm_min_players_to_start").IntValue = 1;

			int objective = GetObjectiveResource();
			if(objective != -1)
				SetEntProp(objective, Prop_Send, "m_bMannVsMachineBetweenWaves", true);
			
			SDKCall_ResetPlayerAndTeamReadyState();

			if(!ReadyUpTimer)
				ReadyUpTimer = CreateTimer(0.2, ReadyUpHack, _, TIMER_REPEAT);

			if(!AlreadySetWaiting && !Rogue_Mode())
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						SetMusicTimer(client, GetTime() + 2); //This is here beacuse of raid music.
						Music_Stop_All(client);
					}
				}	
			}
			AlreadySetWaiting = true;
		}
		case 2:	// Waiting
		{
			if(stopmusic && !AlreadySetWaiting && !Rogue_Mode())
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						SetMusicTimer(client, GetTime() + 2); //This is here beacuse of raid music.
						Music_Stop_All(client);
					}
				}	
			}
			AlreadySetWaiting = true;
			SDKCall_ResetPlayerAndTeamReadyState();
			
			GameRules_SetProp("m_bInWaitingForPlayers", true);
			GameRules_SetProp("m_bInSetup", true);
			GameRules_SetProp("m_iRoundState", RoundState_BetweenRounds);
			FindConVar("tf_mvm_min_players_to_start").IntValue = 199;
			GameRules_SetPropFloat("m_flRestartRoundTime", -1.0);

			int objective = GetObjectiveResource();
			if(objective != -1)
				SetEntProp(objective, Prop_Send, "m_bMannVsMachineBetweenWaves", true);
			
			KillFeed_ForceClear();

			if(ReadyUpTimer)
				delete ReadyUpTimer;

			ReadyUpTimer = null;
		}
	}
}

static void WaveSizeLimit(int objective, int &asize1 = 0, int &asize2 = 0, int &aname1 = 0, int &aname2 = 0)
{
	static int size1, size2, name1, name2;

	if(!size1)
		size1 = GetEntPropArraySize(objective, Prop_Send, "m_nMannVsMachineWaveClassCounts");
	
	if(!size2)
		size2 = GetEntPropArraySize(objective, Prop_Send, "m_nMannVsMachineWaveClassCounts2");
	
	if(!name1)
		name1 = GetEntSendPropOffs(objective, "m_iszMannVsMachineWaveClassNames", true);
	
	if(!name2)
		name2 = GetEntSendPropOffs(objective, "m_iszMannVsMachineWaveClassNames2", true);
	
	asize1 = size1;
	asize2 = size2;
	aname1 = name1;
	aname2 = name2;
}

void Waves_SetWaveClass(int objective, int index, int count = 0, const char[] icon = "", int flags = 0, bool active = false)
{
	static int size1, size2, name1, name2;

	if(!size1)
		WaveSizeLimit(objective, size1, size2, name1, name2);

	if(index < size1)
	{
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveClassCounts", count, _, index);
		SetEntDataAllocString(objective, name1 + (index * 4), icon);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveClassFlags", flags, _, index);
		SetEntProp(objective, Prop_Send, "m_bMannVsMachineWaveClassActive", active, _, index);
	}
	else
	{
		int index2 = index - size1;
		if(index2 < size2)
		{
			SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveClassCounts2", count, _, index2);
			SetEntDataAllocString(objective, name2 + (index2 * 4), icon);
			SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveClassFlags2", flags, _, index2);
			SetEntProp(objective, Prop_Send, "m_bMannVsMachineWaveClassActive2", active, _, index2);
		}
	}
	
}

static void SetEntDataAllocString(int entity, int offset, const char[] string)
{
	Address address = AllocPooledString(string);
	if(address != view_as<Address>(GetEntData(entity, offset, 4)))
		SetEntData(entity, offset, address, 4, true);
}

/**
 * Inserts a string into the game's string pool.  This uses the same implementation that is in
 * SourceMod's core:
 * 
 * https://github.com/alliedmodders/sourcemod/blob/b14c18ee64fc822dd6b0f5baea87226d59707d5a/core/HalfLife2.cpp#L1415-L1423
 */
static Address AllocPooledString(const char[] value) {
	if(!g_AllocPooledStringCache)
		g_AllocPooledStringCache = new StringMap();

	Address pValue;
	if (g_AllocPooledStringCache.GetValue(value, pValue)) {
		return pValue;
	}

	int ent = FindEntityByClassname(-1, "worldspawn");
	if (ent != 0) {
		return Address_Null;
	}
	int offset = FindDataMapInfo(ent, "m_iName");
	if (offset <= 0) {
		return Address_Null;
	}
	Address pOrig = view_as<Address>(GetEntData(ent, offset));
	DispatchKeyValue(ent, "targetname", value);
	pValue = view_as<Address>(GetEntData(ent, offset));
	SetEntData(ent, offset, pOrig);

	g_AllocPooledStringCache.SetValue(value, pValue);
	return pValue;
}

void Waves_SetDifficultyName(const char[] name)
{
	strcopy(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), name);
	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), name);
	WavesUpdateDifficultyName();
	SteamWorks_UpdateGameTitle();
}

void WavesUpdateDifficultyName()
{
	int objective = GetObjectiveResource();
	if(objective != -1)
	{
		static int offset;
		if(!offset)
			offset = GetEntSendPropOffs(objective, "m_iszMvMPopfileName", true);

		SetEntDataAllocString(objective, offset, WhatDifficultySetting);
	}	
}

void Waves_ApplyAttribs(int client, StringMap map)	// Store_ApplyAttribs()
{
	if(Aperture_ShouldDoLastStand())
	{
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			ApplyStatusEffect(client, client, "Chaos Infliction", 999.0);
		}
		else
		{
			RemoveSpecificBuff(client, "Chaos Infliction");
		}
	}
	if(ModFuncAlly != INVALID_FUNCTION)
	{
		Call_StartFunction(null, ModFuncAlly);
		Call_PushCell(client);
		Call_PushCell(map);
		Call_Finish();
	}
}

void Waves_GiveItem(int entity)
{
	if(ModFuncWeapon != INVALID_FUNCTION)
	{
		Call_StartFunction(null, ModFuncWeapon);
		Call_PushCell(entity);
		Call_Finish();
	}
}

void Waves_AllySpawned(int entity)
{
	if(ModFuncAlly != INVALID_FUNCTION)
	{
		Call_StartFunction(null, ModFuncAlly);
		Call_PushCell(entity);
		Call_PushCell(0);
		Call_Finish();
	}
}

void Waves_EnemySpawned(int entity)
{
	if(ModFuncEnemy != INVALID_FUNCTION)
	{
		Call_StartFunction(null, ModFuncEnemy);
		Call_PushCell(entity);
		Call_Finish();
	}
	if(!b_thisNpcIsARaid[entity] && XenoExtraLogic(true))
	{
		ApplyStatusEffect(entity, entity, "Xeno's Territory", 99999.0);
	}
	if(!b_thisNpcIsARaid[entity] && FishExtraLogic(true))
	{
		ApplyStatusEffect(entity, entity, "Corrupted Godly Power", 99999.0);
	}
}

bool Waves_NextFreeplayCall(bool donotAdvanceRound)
{
	int length = Rounds.Length - 1;
	Round round;
	Rounds.GetArray(length, round);
	if(++CurrentWave < 8)
	{
		DoGlobalMultiScaling();

		int postWaves = CurrentRound - length;
		f_FreeplayDamageExtra = 1.0 + (postWaves / 45.0);

		Rounds.GetArray(length, round);
		length = round.Waves.Length;

		Wave wave;
		ArrayList common = new ArrayList(sizeof(Wave));
		ArrayList boss = new ArrayList(sizeof(Wave));
		
		int Max_Enemy_Get = Freeplay_EnemyCount();
		for(int i; i < length; i++)
		{
			round.Waves.GetArray(i, wave);
			if(wave.EnemyData.Is_Boss)
			{
				boss.PushArray(wave);
			}
			else
			{
				common.PushArray(wave);
			}
		}

		common.Sort(Sort_Random, Sort_Integer);
		boss.Sort(Sort_Random, Sort_Integer);

		for(int i; i < Max_Enemy_Get; i++)
		{
			int dangerlevel = Freeplay_GetDangerLevelCurrent();
			bool isBoss = !(GetURandomInt() % 9);

			if(isBoss)
			{
				int bossdanger = dangerlevel;
				
				if(bossdanger >= 5)
					bossdanger = 4;

				int index = boss.FindValue(bossdanger, Wave::DangerLevel);
				if(index == -1)
					continue;
				
				boss.GetArray(index, wave);
				boss.Erase(index);
			}
			else
			{
				int index = common.FindValue(dangerlevel, Wave::DangerLevel);
				if(index == -1)
					continue;
				
				common.GetArray(index, wave);
				common.Erase(index);
			}
			
			Freeplay_AddEnemy(postWaves, wave.EnemyData, wave.Count);

			if(wave.Count > 0)
			{
				for(int a; a < wave.Count; a++)
				{
					Waves_AddNextEnemy(wave.EnemyData);
				}
				
				Zombies_Currently_Still_Ongoing += wave.Count;
			}
		}

		delete common;
		delete boss;

		if(Freeplay_ShouldMiniBoss())
		{
			NPC_SpawnNext(true, true, -1);
		}
		else
		{
			NPC_SpawnNext(false, false, -1);
		}
		
		CurrentWave = 9;
	}
	else if(donotAdvanceRound)
	{
		CurrentWave = 9;
	}
	else
	{
		if(FreeplayTimeLimit < GetGameTime())
		{
			CPrintToChatAll("{gold}코쉬{white}: 1 시간 정도는 살아남은것 같네. 흐음...");
			CPrintToChatAll("{gold}코쉬{white}: 너희가 버틴 웨이브는... : {green}%i!",CurrentRound+1);
			if(CurrentRound+1 < 100)
			{
				CPrintToChatAll("{gold}코쉬{white}: 봐봐, 더 오래 버틸 수 있었잖아! 그러니까 밍기적대지도 말고, 빨리 빨리 진행하라구!");
				CPrintToChatAll("{lightcyan}제이나{white}: 끝난거 맞죠? 이제 집에 갈 수 있겠네요, {lightblue}네말{white}이 절 기다리고 있을거에요.");
			}
			else if(CurrentRound+1 >= 100 && CurrentRound+1 < 150)
			{
				CPrintToChatAll("{gold}코쉬{white}: 대단한 기록이었어. 그치만... {orange}더 오래 버틸 수 있을지도.");
				CPrintToChatAll("{lightcyan}제이나{white}: 여기서 더 오래...? 진심으로 하시는 소리세요!?");
			}
			else
			{
				CPrintToChatAll("{gold}코쉬{white}: 정말... {crimson}멋져! {white}너무 멋지고 완벽한 훈련이야!");
				CPrintToChatAll("{lightcyan}제이나{white}: {red}...당신, 지금 괜찮은거 맞으시죠, {gold}코쉬?");
			}
				

			ForcePlayerWin();
			return true;
		}
		WaveEndLogicExtra();

		Freeplay_OnEndWave(round.Cash);
		
		CurrentCash += round.Cash;

		if(round.Cash)
		{
			CPrintToChatAll("{gold}%t{default}","Simulation Time Left", ((FreeplayTimeLimit - GetGameTime()) / 60.0));
			CPrintToChatAll("{green}%t{default}","Cash Gained This Wave", round.Cash);
		}
		else
		{
			//Thisi s responseable for auto balance scaling for raids.
			int ExtraCashGive = round.CashShould - Waves_CashGainedTotalThisWave();
			if(ExtraCashGive > 0)
			{
				CurrentCash += ExtraCashGive;
			}
		}
		Waves_ResetCashGiveWaveEnd();
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
		//Incase we had music play during outro, and set a time.
		if(round.MusicOutroDuration > 0)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && !b_IsPlayerABot[client])
				{
					SetMusicTimer(client, GetTime() + round.MusicOutroDuration); //This is here beacuse of raid music.
				}
			}
		}

		//stop music if we had custom ones before.
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
		
		RaidMusicSpecial1.Clear();
		
		Citizen_WaveStart();
		ExcuteRelay("zr_wavedone");
		CurrentRound++;
		CurrentWave = -1;
		//This ensures no invalid spawn happens.
		Spawners_Timer();

		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				DoOverlay(client, "", 2);
				if(GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING && f_PlayerLastKeyDetected[client] > GetGameTime() - 10.0)
				{
					//make sure client isnt afk.
					//Make sure client is playing the wave
					GiveXP(client, round.Xp);
				}
			}
		}
		
		Music_EndLastmann();
		ReviveAll();
		
		CheckAlivePlayers();

		if((CurrentRound % 5) == 4)
		{
			Freeplay_SetupStart(true);
			float time = Freeplay_SetupValues();
			
			if(time > 0.0)
			{
				Cooldown = GetGameTime() + time;
			
				InSetup = true;
				ExcuteRelay("zr_setuptime");
				
				SpawnTimer(time);
				CreateTimer(time, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			
			RequestFrames(StopMapMusicAll, 60);
			
			Citizen_SetupStart();
			if(CurrentRound+1 == 200)
			{
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && !b_IsPlayerABot[client])
					{
						SetHudTextParams(-1.0, -1.0, 5.0, 255, 135, 0, 255);
						ShowHudText(client, -1, "You've gone far, lads...\nBut will you make it further?");
					}
				}
			}
		}
		else
		{
			return true;
		}
	}
	return false;
}

int CashGainedTotal;
void Waves_ResetCashGiveWaveEnd()
{
	CashGainedTotal = 0;
}
void Waves_AddCashGivenThisWaveViaKills(int cash)
{
	CashGainedTotal += cash;
}
int Waves_CashGainedTotalThisWave()
{
	return CashGainedTotal;
}

int Waves_AverageLevelGet(int MaxLevelAllow)
{
	//Max levels is used incase you dont want to scale a lvl 500 player as lvl 500 player, in this case it should only go as high as lvl 120 imo.
	int ClientsGot;
	int LevelObtained;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client) && Database_IsCached(client))
		{
			if(Level[client] >= MaxLevelAllow)
				LevelObtained += MaxLevelAllow;
			else if(Level[client] <= 0) //Dont divide by 0...
				LevelObtained += 1;
			else
				LevelObtained += Level[client];

			ClientsGot++;
		}
	}
	if(ClientsGot <= 0)
	{
		//return lvl 1.
		return 1;
	}
	//This will obtain the average level of the server.
	return (LevelObtained / ClientsGot);
}

void Waves_TrySpawnBarney()
{
	if(CvarInfiniteCash.BoolValue)
		return;
	if(Rogue_Mode())
		return;
	if(Construction_Mode())
		return;
	if(NoBarneySpawn)
		return;
	if(BetWar_Mode())
		return;
		
	//check for barney.
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(b_NpcHasDied[entity])
			continue;
		if(!Citizen_IsIt(entity))
			continue;
		Citizen npc = view_as<Citizen>(entity);
		if(npc.m_bHero)
			return;
		//we have a barney or alyx
	}
	Citizen_SpawnAtPoint("b");
	Citizen_SpawnAtPoint(_);
	CPrintToChatAll("{gray}바니 칼훈{default}: 이봐, 좀 늦었지만 도와주러 왔어! 잘 버텨줬어!");
	CPrintToChatAll("{gray}바니 칼훈{default}: 내 친구한테 말을 걸면 뭔가 특별한 명령을 내릴수 있으니까 기억해둬.");
}

ArrayList Waves_GetRoundsArrayList()
{
	return Rounds;
}

#include "modifiers.sp"
