#pragma semicolon 1
#pragma newdecls required

enum struct Enemy
{
	int Health;
	int Is_Boss;
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
	char CustomName[64];
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
	int AmmoBoxExtra;
	bool MapSetupRelay;
	bool Custom_Refresh_Npc_Store;
	int medival_difficulty;
	
	MusicEnum music_round_1;
	MusicEnum music_round_2;
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
	char Config[256];
	int Level;
	char Desc[256];
	char Append[64];
	bool Locked;
}

static ArrayList Enemies;
static ArrayList Rounds;
static ArrayList Voting;
static ArrayList VotingMods;
static bool CanReVote;
static ArrayList MiniBosses;
static float Cooldown;
static bool InSetup;
static int FakeMaxWaves;
static int WaveLevel;

static Function ModFuncRemove = INVALID_FUNCTION;
static Function ModFuncAlly = INVALID_FUNCTION;
static Function ModFuncEnemy = INVALID_FUNCTION;
static Function ModFuncWeapon = INVALID_FUNCTION;

static ConVar CvarSkyName;
static char SkyNameRestore[64];

static StringMap g_AllocPooledStringCache;

static int Gave_Ammo_Supply;
static int VotedFor[MAXTF2PLAYERS];
static float VoteEndTime;
static float f_ZombieAntiDelaySpeedUp;
static int i_ZombieAntiDelaySpeedUp;
static Handle WaveTimer;
static float ProgressTimerEndAt;
static bool ProgressTimerType;

static bool UpdateFramed;
static int WaveGiftItem;
static char LastWaveWas[64];

public Action Waves_ProgressTimer(Handle timer)
{
	if(Classic_Mode() && ProgressTimerType)
	{
		// Delay progress if a boss is alive
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
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
	delete Rounds;
	delete g_AllocPooledStringCache;
	FogEntity = INVALID_ENT_REFERENCE;
	SkyNameRestore[0] = 0;
	FakeMaxWaves = 0;

	int objective = GetObjectiveResource();
	if(objective != -1)
		SetEntProp(objective, Prop_Send, "m_iChallengeIndex", -1);
	
	Waves_UpdateMvMStats();
}

void Waves_PlayerSpawn(int client)
{
	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		SetVariantString("rpg_fortress_envfog");
		AcceptEntityInput(client, "SetFogController");
	}
}

public Action NpcEnemyAliveLimit(int client, int args)
{
	PrintToConsoleAll("EnemyNpcAlive %i | EnemyNpcAliveStatic %i",EnemyNpcAlive, EnemyNpcAliveStatic);
	return Plugin_Handled;
}

public Action Waves_ForcePanzer(int client, int args)
{
	NPC_SpawnNext(true, true); //This will force spawn a panzer.
	return Plugin_Handled;
}

public Action Waves_SetWaveCmd(int client, int args)
{
	Waves_ClearWaves();
	
	char buffer[12];
	GetCmdArgString(buffer, sizeof(buffer));
	CurrentRound = StringToInt(buffer);
	CurrentWave = -1;
	Waves_Progress();
	return Plugin_Handled;
}

bool Waves_InVote()
{
	return (Rogue_Mode() || Voting || VotingMods);
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
	else if(VotingMods)
	{
		VotedFor[client] = 0;
		Waves_CallVote(client);
	}
	return Plugin_Handled;
}

bool Waves_CallVote(int client, int force = 0)
{
	if(Rogue_Mode())
		return Rogue_CallVote(client);
	
	if((Voting || VotingMods) && (force || !VotedFor[client]))
	{
		Menu menu = new Menu(Waves_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t:\n ", Voting ? "Vote for the difficulty" : "Vote for the modifier");
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		menu.AddItem(NULL_STRING, vote.Name);

		if(Voting)
		{
			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				
				if(vote.Level > 0 && LastWaveWas[0] && StrEqual(vote.Config, LastWaveWas))
				{
					Format(vote.Name, sizeof(vote.Name), "%s (Cooldown)", vote.Name);
					menu.AddItem(vote.Config, vote.Name, ITEMDRAW_DISABLED);
				}
				else
				{
					Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, vote.Level);
					menu.AddItem(vote.Config, vote.Name, (Level[client] < vote.Level && Database_IsCached(client)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
			}
		}
		else
		{
			Format(vote.Name, sizeof(vote.Name), "Standard (Lv %d)", WaveLevel);
			menu.AddItem(NULL_STRING, vote.Name);

			int length = VotingMods.Length;
			for(int i = 1; i < length; i++)
			{
				VotingMods.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				
				float multi = float(vote.Level) / 1000.0;
				
				int level = WaveLevel;
				if(level < 10)
					level = 10;
				
				level = WaveLevel + RoundFloat(level * multi);

				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, level);
				menu.AddItem(vote.Config, vote.Name, (Level[client] < level && Database_IsCached(client)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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

void Waves_SetupVote(KeyValues map)
{
	Cooldown = 0.0;
	delete Voting;
	delete VotingMods;
	
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
	}
	
	StartCash = kv.GetNum("cash");

	// Rogue Gamemode
	if(map && kv.GetNum("roguemode"))
	{
		Rogue_SetupVote(kv);

		if(kv != map)
			delete kv;
		
		return;
	}

	// ZS-Classic Gamemode
	if(kv.GetNum("classicmode"))
		Classic_Enable();

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
	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(vote.Name, sizeof(vote.Name));
			kv.GetString("file", vote.Config, sizeof(vote.Config));
			kv.GetString("desc", vote.Desc, sizeof(vote.Desc));
			vote.Level = kv.GetNum("level");
			Voting.PushArray(vote);
		} while(kv.GotoNextKey());

		kv.GoBack();
	}

	kv.GoBack();

	if(kv.JumpToKey("Modifiers"))
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
		}
	}

	if(kv != map)
		delete kv;

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

bool Waves_GetMiniBoss(MiniBoss boss)
{
	if(!MiniBosses)
		return false;
	
	int length = MiniBosses.Length;
	if(!length)
		return false;

	/*
	int level;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] != TEUTON_WAITING && IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			if(Level[client] > level)
				level = Level[client];
		}
	}
	level = level / 10 - 10;
	if(level < 0)
		return false;

	if(length > level)
		length = level;
	*/

	MiniBosses.GetArray(GetURandomInt() % length, boss);
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
	
	Waves_ClearWaves();
	
	char buffer[128], plugin[64];

	f_ExtraDropChanceRarity = kv.GetFloat("gift_drop_chance_multiplier", 0.5);
	i_WaveHasFreeplay = kv.GetNum("do_freeplay", 0);
	kv.GetString("complete_item", buffer, sizeof(buffer));
	WaveGiftItem = buffer[0] ? Items_NameToId(buffer) : -1;
	bool autoCash = view_as<bool>(kv.GetNum("auto_raid_cash"));
	FakeMaxWaves = kv.GetNum("fakemaxwaves");
	ResourceRegenMulti = kv.GetFloat("resourceregen", 1.0);

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
	
	Enemy enemy;
	Wave wave;
	kv.GotoFirstSubKey();
	do
	{
		round.Cash = kv.GetNum("cash");
		round.AmmoBoxExtra = kv.GetNum("ammobox_extra");
		round.Custom_Refresh_Npc_Store = view_as<bool>(kv.GetNum("grigori_refresh_store"));
		round.medival_difficulty = kv.GetNum("medival_research_level");
		round.MapSetupRelay = view_as<bool>(kv.GetNum("map_setup_fake"));
		round.Xp = kv.GetNum("xp");
		round.Setup = kv.GetFloat("setup");
		round.NoMiniboss = view_as<bool>(kv.GetNum("no_miniboss"));
		round.NoBarney = view_as<bool>(kv.GetNum("no_barney"));

		round.music_round_1.SetupKv("music_1", kv);
		round.music_round_2.SetupKv("music_2", kv);
		
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
						wave.DangerLevel = kv.GetNum("danger_level");
						
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
	else
	{
		bool RoundHadCustomMusic = false;
	
		if(MusicString1.Path[0])
			RoundHadCustomMusic = true;
				
		if(MusicString2.Path[0])
			RoundHadCustomMusic = true;

		if(RaidMusicSpecial1.Path[0])
		{
			RoundHadCustomMusic = true;
		}

		Rounds.GetArray(0, round);

		if(RoundHadCustomMusic) //only do it when there was actually custom music previously
		{	
			bool ReplaceMusic = false;
			if(!round.music_round_1.Path[0] && MusicString1.Path[0])
			{
				ReplaceMusic = true;
			}
			if(round.music_round_1.Path[0])
			{
				if(!StrEqual(MusicString1.Path, round.music_round_1.Path))
				{
					ReplaceMusic = true;
				}
			}
			//there was music the previous round, but there is none now.
			if(!round.music_round_2.Path[0] && MusicString2.Path[0])
			{
				ReplaceMusic = true;
			}
			//they are different, cancel out.
			if(round.music_round_1.Path[0])
			{
				if(!StrEqual(MusicString2.Path, round.music_round_2.Path))
				{
					ReplaceMusic = true;
				}
			}

			//if it had raid music, replace anyways.
			if(RaidMusicSpecial1.Path[0])
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

		MusicString1 = round.music_round_1;
		MusicString2 = round.music_round_2;
	}

	Waves_UpdateMvMStats();
	DoGlobalMultiScaling();
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
	
	Waves_ClearWaves();
	
	Waves_RoundEnd();
	Freeplay_ResetAll();
	
	if(Rogue_Mode())
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
		
		VoteEndTime = GetGameTime() + time;
		CreateTimer(time, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

		if(wait < time)
			wait = time;

		//SpawnTimer(wait);
		CreateTimer(wait, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		
		Waves_SetReadyStatus(2);
	}
	else
	{
		delete VotingMods;
		Waves_SetReadyStatus(1);
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

	if(Rogue_Mode())
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
	CurrentWave = -1;
	Medival_Difficulty_Level = 0.0; //make sure to set it to 0 othrerwise waves will become impossible

	if(Rogue_Mode())
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
				for(int i = 1; i < length; i++)
				{
					if(votes[i] > votes[high1])
					{
						high2 = high1;
						high1 = i;
					}
					else if(high2 == -1 || votes[i] > votes[high2])
					{
						high2 = i;
					}
				}

				if(high2 != -1)
				{
					high1 = votes[high2];
					for(int i = length - 1; i >= 0; i--)
					{
						if(votes[i] < high1)
						{
							list.Erase(i);
						}
					}
				}

				Zero(VotedFor);
				CanReVote = false;
				VoteEndTime = GetGameTime() + 30.0;
				CreateTimer(30.0, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
				PrintHintTextToAll("Vote for the top %d options!", list.Length);
				PrintToChatAll("Vote for the top %d options!", list.Length);
			}
			else
			{
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
					PrintToChatAll("%t: %s","Difficulty set to", vote.Name);

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
					
					Format(vote.Name, sizeof(vote.Name), "FireUser%d", highest + 1);
					ExcuteRelay("zr_waveselected", vote.Name);
					
					BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, vote.Config);
					KeyValues kv = new KeyValues("Waves");
					kv.ImportFromFile(buffer);
					Waves_SetupWaves(kv, false);
					delete kv;

					if(VotingMods)
					{
						Zero(VotedFor);
						VoteEndTime = GetGameTime() + 30.0;
						CreateTimer(1.0, Waves_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						CreateTimer(30.0, Waves_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);

						PrintHintTextToAll("Vote for the wave modifier!");
						PrintToChatAll("Vote for the wave modifier!");
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
					PrintToChatAll("%t: %s", "Modifier set to", vote.Name);
					
					if(highest > 0)
					{
						float multi = float(vote.Level) / 1000.0;

						int level = WaveLevel;
						if(level < 10)
							level = 10;
						
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
	return Plugin_Continue;
}

void Waves_ClearWaves()
{
	delete Enemies;
	Enemies = new ArrayList(sizeof(Enemy));
}

void Waves_Progress(bool donotAdvanceRound = false)
{
	/*
	PrintCenterTextAll("Waves_Progress %d | %d | %d | %d | %d", InSetup ? 0 : 1,
		Rounds ? 1 : 0,
		CvarNoRoundStart.BoolValue ? 0 : 1,
		GameRules_GetRoundState() == RoundState_BetweenRounds ? 0 : 1,
		Cooldown > GetGameTime() ? 0 : 1);
	*/
	if(InSetup || !Rounds || CvarNoRoundStart.BoolValue || GameRules_GetRoundState() == RoundState_BetweenRounds || Cooldown > GetGameTime())
		return;

	Cooldown = GetGameTime();
	ProgressTimerEndAt = 0.0;
	delete WaveTimer;
	
	Round round;
	Wave wave;
	int length = Rounds.Length-1;
	bool panzer_spawn = false;
	bool panzer_sound = false;
	bool rogue = Rogue_Mode();
	static int panzer_chance;
	bool GiveAmmoSupplies = true;

	if(CurrentRound < length)
	{
		Rounds.GetArray(CurrentRound, round);
		if(++CurrentWave < round.Waves.Length)
		{
			f_FreeplayDamageExtra = 1.0;
			round.Waves.GetArray(CurrentWave, wave);

			if(!CurrentWave && Classic_Mode())
				Classic_NewRoundStart(round.Cash);

			if(wave.RelayName[0])
				ExcuteRelay(wave.RelayName, wave.RelayFire);
			
			DoGlobalMultiScaling();
			
			int Is_a_boss = wave.EnemyData.Is_Boss;
			bool ScaleWithHpMore = wave.Count == 0;
			
			if(Is_a_boss >= 2)
			{
				if(Is_a_boss == 2)
				{
					if(LastMann)
					{
						PrintToChatAll("You were given extra 45 seconds to prepare for the raidboss... Get ready.");
						GiveProgressDelay(45.0);
						f_DelaySpawnsForVariousReasons = GetGameTime() + 45.0;
						SpawnTimer(45.0);
					}
					else
					{
						PrintToChatAll("You were given extra 30 seconds to prepare for the raidboss... Get ready.");
						GiveProgressDelay(30.0);
						f_DelaySpawnsForVariousReasons = GetGameTime() + 30.0;
						SpawnTimer(30.0);
					}
				}
				Music_EndLastmann();
				ReviveAll(true);
				CheckAlivePlayers();
				WaveEndLogicExtra();
			}
			
			int count = wave.Count;
			
			if(wave.EnemyData.Does_Not_Scale == 0 && count > 0)
			{
				if(Is_a_boss == 0)
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
				
				int Tempomary_Health = RoundToNearest(float(wave.EnemyData.Health) * multiBoss);
				wave.EnemyData.Health = Tempomary_Health;
			}
			else if(MultiGlobalHealth > 1.0)
			{
				wave.EnemyData.Health = RoundToNearest(float(wave.EnemyData.Health) * MultiGlobalHealth);
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
			WaveEndLogicExtra();

			if(!Classic_Mode())
			{
				int CashGive = round.Cash;
				CurrentCash += CashGive;

				if(CashGive)
				{
					CPrintToChatAll("{green}%t","Cash Gained This Wave", CashGive);
				}
			}
			
			ExcuteRelay("zr_wavedone");
			CurrentRound++;
			CurrentWave = -1;
			if(CurrentRound != length)
			{
				char ExecuteRelayThings[255];
				//do not during freeplay.
				FormatEx(ExecuteRelayThings, sizeof(ExecuteRelayThings), "zr_wavefinish_wave_%i",CurrentRound);
				ExcuteRelay(ExecuteRelayThings);
			}
			RequestFrames(StopMapMusicAll, 60);
			
			Waves_ClearWaves();

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
				CPrintToChatAll("{crimson}%t", round.Message);
			}
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
			//add a minimum of 0.5 seconds because of custom spawns.
			//breaks mininbosses, cant
		//	GiveProgressDelay(0.5);
		//	f_DelaySpawnsForVariousReasons = GetGameTime() + 0.5;
			
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
					DispatchKeyValue(entity, "fogblend", round.FogBlend);
					DispatchKeyValue(entity, "fogcolor", round.FogColor1);
					DispatchKeyValue(entity, "fogcolor2", round.FogColor2);
					DispatchKeyValueFloat(entity, "fogstart", round.FogStart);
					DispatchKeyValueFloat(entity, "fogend", round.FogEnd);
					DispatchKeyValueFloat(entity, "fogmaxdensity", round.FogDesnity);

					DispatchKeyValue(entity, "targetname", "rpg_fortress_envfog");
					DispatchKeyValue(entity, "fogenable", "1");
					DispatchKeyValue(entity, "spawnflags", "1");
					DispatchSpawn(entity);
					AcceptEntityInput(entity, "TurnOn");

					FogEntity = EntIndexToEntRef(entity);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetVariantString("rpg_fortress_envfog");
							AcceptEntityInput(client, "SetFogController");
						}
					}
				}
			}
			
			//Loop through all the still alive enemies that are indexed!
			int Zombies_alive_still = 0;

			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int npc_index = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
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
			
	//		if(Zombies_Currently_Still_Ongoing > 0 && (Zombies_Currently_Still_Ongoing - Zombies_alive_still) > 0)
	//		{
	//			CPrintToChatAll("{crimson}%d zombies have been wasted...", Zombies_Currently_Still_Ongoing - Zombies_alive_still);
	//		}
			Zombies_Currently_Still_Ongoing = 0;
			
			Zombies_Currently_Still_Ongoing = Zombies_alive_still;
			
			//Loop through all the still alive enemies that are indexed!
			
			//always increace chance of miniboss.
			if(!rogue && CurrentRound == 4 && !round.NoBarney)
			{
				Citizen_SpawnAtPoint("b");
			}
			else if(CurrentRound == 11 && !round.NoMiniboss)
			{
				panzer_spawn = true;
				panzer_sound = true;
				panzer_chance = 10;
			}
			else if((CurrentRound > 11 && round.Setup <= 30.0 && !round.NoMiniboss))
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
						DoOverlay(client, "", 2);
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
			if(round.AmmoBoxExtra)
			{
				Ammo_Count_Ready += round.AmmoBoxExtra;	
			}
			if(round.Custom_Refresh_Npc_Store)
			{
				//PrintToChatAll("%t", "Grigori Store Refresh");
				//Store_RandomizeNPCStore(0); // Refresh me !!!
				refreshNPCStore = true;
			}
			if(round.medival_difficulty != 0)
			{
			//	PrintToChatAll("%t", "Grigori Store Refresh");
				Medival_Wave_Difficulty_Riser(round.medival_difficulty); // Refresh me !!!
			}
			
			//MUSIC LOGIC
			
			bool RoundHadCustomMusic = false;
		
			if(MusicString1.Path[0])
				RoundHadCustomMusic = true;
					
			if(MusicString2.Path[0])
				RoundHadCustomMusic = true;

			if(RaidMusicSpecial1.Path[0])
			{
				RoundHadCustomMusic = true;
			}

			if(RoundHadCustomMusic) //only do it when there was actually custom music previously
			{	
				bool ReplaceMusic = false;
				if(!round.music_round_1.Path[0] && MusicString1.Path[0])
				{
					ReplaceMusic = true;
				}
				if(round.music_round_1.Path[0])
				{
					if(!StrEqual(MusicString1.Path, round.music_round_1.Path))
					{
						ReplaceMusic = true;
					}
				}
				//there was music the previous round, but there is none now.
				if(!round.music_round_2.Path[0] && MusicString2.Path[0])
				{
					ReplaceMusic = true;
				}
				//they are different, cancel out.
				if(round.music_round_1.Path[0])
				{
					if(!StrEqual(MusicString2.Path, round.music_round_2.Path))
					{
						ReplaceMusic = true;
					}
				}

				//if it had raid music, replace anyways.
				if(RaidMusicSpecial1.Path[0])
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

			MusicString1 = round.music_round_1;
			MusicString2 = round.music_round_2;
			
			if(round.Setup > 1.0)
			{
				if(round.Setup > 59.0)
				{
					for(int client=1; client<=MaxClients; client++)
					{
						if(IsClientInGame(client))
						{
							SetMusicTimer(client, GetTime() + 99999);
						}
					}
				}
				else if(MusicString1.Path[0] || MusicString2.Path[0])
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

			SteamWorks_UpdateGameTitle();
			
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
				RequestFrames(StopMapMusicAll, 60);
				
				int total = 0;
				int[] players = new int[MaxClients];
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i))
					{
						Music_Stop_All(i);
						if(!rogue)
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

				if(!rogue)
				{
					ResetReplications();
					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.5, SetTimeBack);
					if(!Music_Disabled())
						EmitCustomToAll("#zombiesurvival/music_win_1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					

					if(zr_allowfreeplay.BoolValue && i_WaveHasFreeplay > 0)
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
							Menu menu = new Menu(Waves_FreeplayVote);
							menu.SetTitle("%t","Victory Menu");
							menu.AddItem("", "Yes");
							menu.AddItem("", "No");
							menu.ExitButton = false;
							menu.DisplayVote(players, total, 30);
						}
						
					}
					else
					{
						ConVar roundtime = FindConVar("mp_bonusroundtime");
						float last = roundtime.FloatValue;
						roundtime.FloatValue = 20.0;

						MVMHud_Disable();
						int entity = CreateEntityByName("game_round_win"); 
						DispatchKeyValue(entity, "force_map_reset", "1");
						SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Red);
						DispatchSpawn(entity);
						AcceptEntityInput(entity, "RoundWin");

						roundtime.FloatValue = last;
					}
					RemoveAllCustomMusic();
				}
				
				RemoveAllCustomMusic();

				if(rogue)
				{
					Rogue_BattleVictory();
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
			else if(wasLastMann && !Rogue_Mode())
			{
				Cooldown = GetGameTime() + 30.0;

				SpawnTimer(30.0);
				CreateTimer(30.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
				
				PrintToChatAll("You were given extra 30 seconds to prepare...");
			}
			else
			{
				Store_RandomizeNPCStore(0, _, true);
				if(refreshNPCStore)
					Store_RandomizeNPCStore(0);
				
				NPC_SpawnNext(panzer_spawn, panzer_sound);
				return;
			}

			if(refreshNPCStore)
				Store_RandomizeNPCStore(0);
			
			Store_RandomizeNPCStore(0, _, true);
		}
	}
	else if(Rogue_Mode())
	{
		PrintToChatAll("FREEPLAY OCCURED, BAD CFG, REPORT BUG");
		CurrentRound = 0;
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
			PrintToChatAll("epic fail");

		if(EarlyReturn)
		{
			return;
		}
	}
	if(CurrentRound == 0 && !Rogue_Mode())
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

	WaveStart_SubWaveStart();
	if(CurrentWave == 0 && GiveAmmoSupplies)
	{
		Renable_Powerups();
		CheckIfAloneOnServer();
		Ammo_Count_Ready += 1;

	//	if(!Classic_Mode())
		{
			for (int target = 1; target <= MaxClients; target++)
			{
				if(i_CurrentEquippedPerk[target] == 7) //recycle gives extra
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

	//	if(!Classic_Mode())
		{
			for (int target = 1; target <= MaxClients; target++)
			{
				if(i_CurrentEquippedPerk[target] == 7) //recycle gives extra
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

bool Waves_IsEmpty()
{
	if(!Enemies || !Enemies.Length)
		return true;
	
	return false;
}

bool Waves_GetNextEnemy(Enemy enemy)
{
	if(!Enemies)
		return false;
	
	int length = Enemies.Length;
	if(!length)
		return false;
	
	Enemies.GetArray(length - 1, enemy);
	Enemies.Erase(length - 1);
	return true;
}

void Waves_AddNextEnemy(const Enemy enemy, bool random = false)
{
	if(Enemies)
	{
		if(random)
		{
			int index = Enemies.Length;
			if(index > 1)
			{
				index = GetURandomInt() % index;

				Enemies.ShiftUp(index);
				Enemies.SetArray(index, enemy);
				return;
			}
		}
		
		Enemies.PushArray(enemy);
	}
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
	if(Enemies)
		Zombies_Currently_Still_Ongoing -= Enemies.Length;
	
	Waves_ClearWaves();
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

int Waves_GetMaxRound()
{
	return FakeMaxWaves ? FakeMaxWaves : (Rounds.Length-1);
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
	Building_WaveEnd();
	SeaFounder_ClearnNethersea();
	VoidArea_ClearnNethersea();
	M3_AbilitiesWaveEnd();
	Specter_AbilitiesWaveEnd();	
	Rapier_CashWaveEnd();
	LeperResetUses();
	Building_ResetRewardValuesWave();
	FallenWarriorGetRandomSeedEachWave();
	Zero(i_MaxArmorTableUsed);
	for(int client; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			b_BobsCuringHand_Revived[client] += GetRandomInt(1,3);
			if(Items_HasNamedItem(client, "Bob's Curing Hand"))
			{
				b_BobsCuringHand[client] = true;
			}
			else
			{
				b_BobsCuringHand[client] = false;
			}
		}
	}
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
	if(InSetup || Classic_Mode())
		return;

	switch(i_ZombieAntiDelaySpeedUp)
	{
		case 0:
		{
			if(f_ZombieAntiDelaySpeedUp < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 1;
				CPrintToChatAll("{crimson}Enemies grow restless...");
			}
		}
		case 1:
		{
			if(f_ZombieAntiDelaySpeedUp + 15.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 2;
				CPrintToChatAll("{crimson}Enemies grow annoyed and go faster...");
			}
		}
		case 2:
		{
			if(f_ZombieAntiDelaySpeedUp + 35.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 3;
				CPrintToChatAll("{crimson}Enemies grow furious and become even faster...");
			}
		}
		case 3:
		{
			if(f_ZombieAntiDelaySpeedUp + 55.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 4;
				CPrintToChatAll("{crimson}Enemies become pissed off and gain super speed...");
			}
		}
		case 4:
		{
			if(f_ZombieAntiDelaySpeedUp + 75.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 5;
				CPrintToChatAll("{crimson}Enemies become infuriated and will reach you...");
			}
		}
		case 5:
		{
			if(f_ZombieAntiDelaySpeedUp + 150.0 < GetGameTime())
			{
				i_ZombieAntiDelaySpeedUp = 6;
				CPrintToChatAll("{crimson}Die.");
			}
		}
	}
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
	float playercount = float(CountPlayersOnRed());
			
	if(playercount == 1.0) //If alone, spawn wayless, it makes it way too difficult otherwise.
	{
		playercount = 0.70;
	}
	else if(playercount < 1.0)
	{
		playercount = 0.70;
	}
			
	float multi = Pow(1.08, playercount);

	multi -= 0.31079601; //So if its 4 players, it defaults to 1.0
	
	MultiGlobalHealthBoss = playercount * 0.2;
	MultiGlobalHighHealthBoss = playercount * 0.34;
	MultiGlobalEnemyBoss = playercount * 0.3;

	
	//certain maps need this.
	MultiGlobalHighHealthBoss *= zr_raidmultihp.FloatValue;

	float cap = zr_enemymulticap.FloatValue;

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
	if(PlayerCountBuffScaling > 1.2)
	{
		PlayerCountBuffScaling = 1.2;
	}

	PlayerCountBuffAttackspeedScaling = 6.0 / playercount;
	if(PlayerCountBuffAttackspeedScaling > 1.2)
	{
		PlayerCountBuffAttackspeedScaling = 1.2;
	}

	PlayerCountResBuffScaling = (1.0 - (playercount / 48.0)) + 0.1;
	if(PlayerCountResBuffScaling < 0.75)
	{
		PlayerCountResBuffScaling = 0.75;
	}
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

static int GetMvMStats()
{
	return FindEntityByClassname(-1, "tf_mann_vs_machine_stats");
}

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

	int mvm = GetMvMStats();
	if(mvm != -1)
	{
		static int m_currentWaveStats, m_runningTotalWaveStats;

		if(!m_currentWaveStats)
		{
			m_currentWaveStats = FindSendPropInfo("CMannVsMachineStats", "m_currentWaveStats");
			if(m_currentWaveStats < 1)
				ThrowError("Invalid offset");
		}

		if(!m_runningTotalWaveStats)
		{
			m_runningTotalWaveStats = FindSendPropInfo("CMannVsMachineStats", "m_runningTotalWaveStats");
			if(m_runningTotalWaveStats < 1)
				ThrowError("Invalid offset");
		}

		if(Rogue_UpdateMvMStats(mvm, m_currentWaveStats, m_runningTotalWaveStats))
			return;

		float cashLeft, totalCash;

		int activecount, totalcount;
		int id[24];
		int count[24];
		int flags[24];
		bool active[24];
		bool forceflags[24];

		if(Classic_Mode() && ProgressTimerEndAt)
		{
			id[0] = -1;
			count[0] = RoundToCeil(ProgressTimerEndAt - GetGameTime());
			flags[0] = ProgressTimerType ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
			if(count[0] < 31)
				flags[0] += MVM_CLASS_FLAG_ALWAYSCRIT;
			
			active[0] = true;
			Waves_UpdateMvMStats(33);
		}
		
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
						if(wave.EnemyData.Is_Boss == 0)
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
								flags[b] = SetupFlags(wave.EnemyData, false);

								if(!Classic_Mode() && ((flags[b] & MVM_CLASS_FLAG_SUPPORT) || (flags[b] & MVM_CLASS_FLAG_MISSION)))
								{
									// Only show "Support" when actually active
									flags[b] = 0;
									continue;
								}

								id[b] = wave.EnemyData.Index;
								forceflags[b] = wave.EnemyData.ignore_max_cap > 0;
							}

							count[b] += num;
							
							break;
						}
					}
				}
			}
		}

		if(Enemies)
		{
			static Enemy enemy;
			int length = Enemies.Length;
			for(int a; a < length; a++)
			{
				Enemies.GetArray(a, enemy);
				cashLeft += enemy.Credits;
				activecount++;

				for(int b; b < sizeof(id); b++)
				{
					if(!id[b] || id[b] == enemy.Index)
					{
						count[b]++;
						
						if(!id[b])
						{
							id[b] = enemy.Index;
							flags[b] = SetupFlags(enemy, (!Classic_Mode() && !freeplay));
						}
						
						break;
					}
				}
			}
		}

		int entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
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
							id[b] = i_NpcInternalId[entity];
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

			NPCData data;
			for(int i; i < sizeof(id); i++)
			{
				if(id[i] == -1)
				{
					Waves_SetWaveClass(objective, i, count[i], (flags[i] & MVM_CLASS_FLAG_MINIBOSS) ? "classic_reinforce" : "classic_defend", flags[i], active[i]);
				}
				else if(id[i])
				{
					NPC_GetById(id[i], data);
					if(data.Flags == -1)
					{
						Waves_SetWaveClass(objective, i);
						continue;
					}

					if(!data.Icon[0])
						strcopy(data.Icon, sizeof(data.Icon), "robo_extremethreat");
					
					if(!data.Flags || forceflags[i])
						data.Flags = flags[i];

					//PrintToChatAll("ID: %d Count: %d Flags: %d On: %d", id[i], count[i], flags[i], active[i]);
					Waves_SetWaveClass(objective, i, count[i], data.Icon, data.Flags, active[i]);
				}
				else
				{
					Waves_SetWaveClass(objective, i);
				}
			}
		}

		if(Rogue_GetChaosLevel() < 3)
		{
			int acquired = RoundFloat(totalCash - cashLeft);
		
			SetEntData(mvm, m_currentWaveStats + 4, acquired, 4, true);	// nCreditsDropped
			SetEntData(mvm, m_currentWaveStats + 8, acquired, 4, true);	// nCreditsAcquired
			SetEntData(mvm, m_currentWaveStats + 12, 0, 4, true);	// nCreditsBonus

			SetEntData(mvm, m_runningTotalWaveStats + 4, CurrentCash - StartCash, 4, true);	// nCreditsDropped
			SetEntData(mvm, m_runningTotalWaveStats + 8, CurrentCash - StartCash, 4, true);	// nCreditsAcquired
			SetEntData(mvm, m_runningTotalWaveStats + 12, GlobalExtraCash, 4, true);	// nCreditsBonus
		}
	}

	//profiler.Stop();
	//PrintToChatAll("Profiler: %f", profiler.Time);
	//delete profiler;
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

		//if(data.Is_Boss > 1)
		//	flags |= MVM_CLASS_FLAG_MISSION;
	}

	if(data.Is_Boss || data.Is_Outlined)
		flags |= MVM_CLASS_FLAG_MINIBOSS;
	
	if(data.ExtraMeleeRes < 1.0 || 
	data.ExtraRangedRes < 1.0 || 
	data.ExtraSpeed > 1.0 || 
	data.ExtraDamage > 1.0 || 
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

void Waves_SetReadyStatus(int status)
{
	switch(status)
	{
		case 0:	// Normal
		{
			InSetup = false;
			GameRules_SetProp("m_bInWaitingForPlayers", false);
			GameRules_SetProp("m_bInSetup", false);
			GameRules_SetProp("m_iRoundState", RoundState_ZombieRiot);
		}
		case 1:	// Ready Up
		{
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
			
		//	KillFeed_ForceClear();
			/*
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(IsFakeClient(client))
						KillFeed_SetBotTeam(client, TFTeam_Blue);
				}
			}
			*/
		}
		case 2:	// Waiting
		{
			GameRules_SetProp("m_bInWaitingForPlayers", true);
			GameRules_SetProp("m_bInSetup", true);
			GameRules_SetProp("m_iRoundState", RoundState_BetweenRounds);
			FindConVar("tf_mvm_min_players_to_start").IntValue = 199;

			int objective = GetObjectiveResource();
			if(objective != -1)
				SetEntProp(objective, Prop_Send, "m_bMannVsMachineBetweenWaves", true);
			
			KillFeed_ForceClear();
			SDKCall_ResetPlayerAndTeamReadyState();
			/*
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(IsFakeClient(client))
						KillFeed_SetBotTeam(client, TFTeam_Blue);
				}
			}
			*/
		}
	}
}

void Waves_SetWaveClass(int objective, int index, int count = 0, const char[] icon = "", int flags = 0, bool active = false)
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
			NPC_SpawnNext(true, true);
		}
		else
		{
			NPC_SpawnNext(false, false);
		}
		
		CurrentWave = 9;
	}
	else if(donotAdvanceRound)
	{
		CurrentWave = 9;
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
		
		ExcuteRelay("zr_wavedone");
		CurrentRound++;
		CurrentWave = -1;
		
		int TestVal = 0;
		Spawns_GetNextPos({0.0,0.0,0.0}, {0.0,0.0,0.0}, "",_,TestVal);
		//This ensures no invalid spawn happens.
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				DoOverlay(client, "", 2);
				if(IsPlayerAlive(client) && GetClientTeam(client)==2)
					GiveXP(client, round.Xp);
			}
		}
		
		ReviveAll();
		
		Music_EndLastmann();
		CheckAlivePlayers();

		if((CurrentRound % 5) == 4)
		{
			Freeplay_SetupStart(postWaves);

			Cooldown = GetGameTime() + 15.0;
			
			InSetup = true;
			ExcuteRelay("zr_setuptime");
			
			SpawnTimer(15.0);
			CreateTimer(15.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			RequestFrames(StopMapMusicAll, 60);
			
			Citizen_SetupStart();
		}
		else
		{
			return true;
		}
	}
	return false;
}

/*
bool Waves_NextSpecialWave(rounds Rounds, bool panzer_spawn, bool panzer_sound, int panzer_chance, bool GiveAmmoSupplies)
{
	Rounds.GetArray(length, round);
	if(++CurrentWave < 8)
	{
		DoGlobalMultiScaling();

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
						Waves_AddNextEnemy(wave.EnemyData);
					}
					
					Zombies_Currently_Still_Ongoing += wave.Count;

					if(!(--Max_Enemy_Get))
						break;
				}
			}
		}

		// Note: Artvin remove this, this is freeplay code
		if(Freeplay_ShouldMiniBoss() && !rogue) //no miniboss during roguelikes.
		{
			panzer_spawn = true;
			NPC_SpawnNext(panzer_spawn, true);
		}
		else
		{
			panzer_spawn = false;
			NPC_SpawnNext(false, false);
		}
		
		if(!Enemies.Length)
		{
			CurrentWave++;
			Waves_Progress();
			return true;
		}
		CurrentWave = 9;
	}
	else if(donotAdvanceRound)
	{
		CurrentWave = 9;
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
		
		ExcuteRelay("zr_wavedone");
		CurrentRound++;
		CurrentWave = -1;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				DoOverlay(client, "", 2);
				if(IsPlayerAlive(client) && GetClientTeam(client)==2)
					GiveXP(client, round.Xp);
			}
		}
		
		ReviveAll();
		
		Music_EndLastmann();
		CheckAlivePlayers();

		if((CurrentRound % 5) == 4)
		{
			Freeplay_SetupStart(postWaves);

			Cooldown = GetGameTime() + 15.0;
			
			InSetup = true;
			ExcuteRelay("zr_setuptime");
			
			SpawnTimer(15.0);
			CreateTimer(15.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
			
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
			
			menu.DisplayVote(players, total, 15);
			
			Citizen_SetupStart();
		}
		else
		{
			return true;
		}
	}
	return false;
}
*/

#include "zombie_riot/modifiers.sp"
