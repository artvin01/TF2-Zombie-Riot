#pragma semicolon 1
#pragma newdecls required

enum struct CvarInfo
{
	ConVar cvar;
	char value[16];
	char defaul[16];
	int OldFlags;
	int FlagsToDelete;
	bool enforce;
}

static ArrayList CvarList;
static ArrayList CvarMapList;
static bool CvarEnabled;

void ConVar_PluginStart()
{
	CvarList = new ArrayList(sizeof(CvarInfo));

	ConVar_Add("mp_forcecamera", "0.0"); //Allow people to roam in spectator
	ConVar_Add("mp_autoteambalance", "0.0");  //Force red
	ConVar_Add("mp_forceautoteam", "1.0"); //Force red
	ConVar_Add("tf_bot_reevaluate_class_in_spawnroom", "1.0");//Bot logic to not break it
	ConVar_Add("tf_bot_keep_class_after_death", "1.0"); //Bot logic to not break it
#if defined ZR
	ConVar_Add("mp_humans_must_join_team", "any");
#else 
	ConVar_Add("mp_humans_must_join_team", "red"); //Only red
#endif
	ConVar_Add("mp_allowspectators", "1");
	
	ConVar_Add("mp_teams_unbalance_limit", "0.0"); //Dont rebalance
	ConVar_Add("mp_scrambleteams_auto", "0.0"); //No scramble
	ConVar_Add("tf_dropped_weapon_lifetime", "0.0"); //Remove dropped weapons
	ConVar_Add("tf_spawn_glows_duration", "0.0"); //No glow duration
	ConVar_Add("tf_weapon_criticals_distance_falloff", "1.0"); //Remove crits
	ConVar_Add("tf_weapon_minicrits_distance_falloff", "1.0"); //Remove crits
	ConVar_Add("tf_weapon_criticals", "0.0");		//Remove crits
	ConVar_Add("tf_weapon_criticals_melee", "0.0");		//Remove crits
	ConVar_Add("tf_boost_drain_time", "99999.0"); //Overheal Logic, make it perma
	ConVar_Add("tf_avoidteammates_pushaway", "0"); 
	tf_scout_air_dash_count = ConVar_Add("tf_scout_air_dash_count", "0", false); 

	ConVar_Add("tf_allow_player_use", "1"); //Allow use!
	ConVar_Add("tf_flamethrower_boxsize", "0.0", true, (FCVAR_NOTIFY | FCVAR_CHEAT)); //Flamethrower Particles are useless in ZR

	ConVar_Add("sv_hudhint_sound", "0.0"); //Removes the wind sound when calling hint hunds
#if defined ZR
	ConVar_Add("mp_tournament", "1"); //NEEDS to be 1 , or else mvm logic seems to break in ZR.
	ConVar_Add("tf_mvm_defenders_team_size", "99");
	ConVar_Add("tf_mvm_max_connected_players", "99");
#endif

#if defined RPG
	ConVar_Add("mp_waitingforplayers_time", "0.0");
#endif

	ConVar_Add("mp_friendlyfire", "1.0");
	ConVar_Add("mp_flashlight", "0.0"); 
	//disable flashlight as it looks buggy and causes fps issues
	//you need to set a setting beforehand to make it work, so its really bad.

#if defined ZR
	CvarMaxPlayerAlive = CreateConVar("zr_maxplayersplaying", "-1", "How many players can play at once?");
	CvarNoRoundStart = CreateConVar("zr_noroundstart", "0", "Makes it so waves refuse to start or continune", FCVAR_DONTRECORD);
	Cvar_VshMapFix = CreateConVar("zr_stripmaplogic", "0", "Strip maps of logic for ZR", FCVAR_DONTRECORD);
	CvarNoSpecialZombieSpawn = CreateConVar("zr_nospecial", "0", "No Panzer will spawn or anything alike");
	zr_voteconfig = CreateConVar("zr_voteconfig", "fastmode", "Vote config zr/ .cfg already included");
	zr_tagblacklist = CreateConVar("zr_tagblacklist", "", "Tags to blacklist from weapons config");
	zr_tagwhitelist = CreateConVar("zr_tagwhitelist", "", "Tags to whitelist from weapons config");
	zr_tagwhitehard = CreateConVar("zr_tagwhitehard", "1", "If whitelist requires a tag instead of allowing");
	zr_minibossconfig = CreateConVar("zr_minibossconfig", "miniboss", "Mini Boss config zr/ .cfg already included");
	zr_ignoremapconfig = CreateConVar("zr_ignoremapconfig", "0", "If to ignore map-specific configs");
	zr_disablerandomvillagerspawn = CreateConVar("zr_norandomvillager", "0.0", "Enable/Disable if medival villagers spawn randomly on the map or only on spawnpoints.");
	zr_waitingtime = CreateConVar("zr_waitingtime", "120.0", "Waiting for players time.");
	zr_maxscaling_untillhp = CreateConVar("zr_maxscaling_untillhp", "3.4", "Max enemy count multipler, will scale by health onwards", _, true, 0.5);
	zr_maxsbosscaling_untillhp = CreateConVar("zr_maxbossscaling_untillhp", "4.0", "Max enemy boss count multipler, will scale by health and damage onwards", _, true, 0.5);
	zr_multi_scaling = CreateConVar("zr_multi_scaling", "1.0", "Multiply the current scaling");
	zr_multi_maxenemiesalive_cap = CreateConVar("zr_multi_maxenemiesalive_cap", "1.0", "Multiply the current max enemies allowed");
	zr_raidmultihp = CreateConVar("zr_raidmultihp", "1.0", "Multiply any boss HP that acts as a raid or megaboss, usefull for certain maps.");
	// MapSpawnersActive = CreateConVar("zr_spawnersactive", "4", "How many spawners are active by default,", _, true, 0.0, true, 32.0);
	//CHECK npcs.sp FOR THIS ONE!
	zr_downloadconfig = CreateConVar("zr_downloadconfig", "", "Downloads override config zr/ .cfg already included");
	CvarRerouteToIp = CreateConVar("zr_rerouteip", "", "If the server is full, reroute", FCVAR_DONTRECORD);
	CvarKickPlayersAt = CreateConVar("zr_kickplayersat", "", "If the server is full, Do reroute or kick", FCVAR_DONTRECORD);
	CvarRerouteToIpAfk = CreateConVar("zr_rerouteipafk", "", "If the server is full, reroute", FCVAR_DONTRECORD);
	CvarSkillPoints = CreateConVar("zr_skillpoints", "1", "If skill points are enabled");
	CvarRogueSpecialLogic = CreateConVar("zr_roguespeciallogic", "0", "Incase your server wants to remove some restrictions off the roguemode.");
	CvarLeveling = CreateConVar("zr_playerlevels", "1", "If player levels are enabled");
	CvarAutoSelectWave = CreateConVar("zr_autoselectwave", "0", "If to automatically set a wave on map start instead of running a vote");
	CvarAutoSelectDiff = CreateConVar("zr_autoselectdiff", "0", "If to automatically set a difficulty on map start instead of running a vote");
	CvarVoteLimit = CreateConVar("zr_wavevotelimit", "0", "Max amount of options to put in waveset voting, 0 to disable");

	HookConVarChange(zr_tagblacklist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitelist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitehard, StoreCvarChanged);
	HookConVarChange(zr_voteconfig, WavesCvarChanged);
	HookConVarChange(zr_minibossconfig, WavesCvarChanged);
	HookConVarChange(CvarAutoSelectWave, WavesCvarChanged);
	HookConVarChange(CvarAutoSelectDiff, WavesCvarChanged);
	HookConVarChange(CvarVoteLimit, WavesCvarChanged);
	HookConVarChange(zr_ignoremapconfig, DownloadCvarChanged);
	HookConVarChange(zr_downloadconfig, DownloadCvarChanged);
#endif

#if defined ZR || defined RPG
	CvarFileNetworkDisable = CreateConVar("zr_filenetwork_disable", "0", "0 means as intended, 1 means fast download sounds (itll download any waves present instnatly), 2 means download MVM style matreials too");
	CvarXpMultiplier = CreateConVar("zr_xpmultiplier", "1.0", "Amount of xp gained is multiplied by.");
	CvarRPGInfiniteLevelAndAmmo = CreateConVar("rpg_debug_store", "0", "Debug", FCVAR_DONTRECORD);
	CvarCustomModels = CreateConVar("zr_custommodels", "1", "If custom player models are enabled");
	
	//default should be 0.5
	zr_spawnprotectiontime = CreateConVar("zr_spawnprotectiontime", "0.2", "How long zombie spawn protection lasts for.");
#endif

#if defined ZR || defined RTS	
	CvarInfiniteCash = CreateConVar("zr_infinitecash", "0", "Money is infinite and always set to 999999", FCVAR_DONTRECORD);
#endif

	CvarDisableThink = CreateConVar("zr_disablethinking", "0", "Disable NPC thinking", FCVAR_DONTRECORD);
	zr_interactforcereload = CreateConVar("zr_interactforcereload", "0", "force interact with reload, it also blocks spray interacting like before.");

	mp_bonusroundtime = FindConVar("mp_bonusroundtime");
	mp_bonusroundtime.SetBounds(ConVarBound_Upper, false);

	sv_cheats = ConVar_Add("sv_cheats", "0", false, (FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT));
	nav_edit = FindConVar("nav_edit");

#if defined ZR
	cvarTimeScale = FindConVar("host_timescale");
	mp_disable_respawn_times = FindConVar("mp_disable_respawn_times");
#endif

	Cvar_clamp_back_speed = ConVar_Add("tf_clamp_back_speed", "0.7", false, (FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT));
	Cvar_LoostFooting = ConVar_Add("tf_movement_lost_footing_friction", "0.1", false, (FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT));
	sv_gravity = ConVar_Add("sv_gravity", "800", false, (FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT));
	ConVar_Add("sv_tags", "", false, (FCVAR_NOTIFY));
	
#if defined RPG	
	AutoExecConfig(true, "zombie_riot");
#endif
}

static ConVar ConVar_Add(const char[] name, const char[] value, bool enforce=true, int flagsremove = FCVAR_CHEAT)
{
	CvarInfo info;
	info.cvar = FindConVar(name);
	info.OldFlags = info.cvar.Flags;
	info.cvar.Flags &= ~(flagsremove);
	info.FlagsToDelete = flagsremove;
	strcopy(info.value, sizeof(info.value), value);
	info.enforce = enforce;

	if(CvarEnabled)
		info.cvar.GetString(info.defaul, sizeof(info.defaul));

	CvarList.PushArray(info);
	
	if(CvarEnabled)
	{
		info.cvar.AddChangeHook(ConVar_OnChanged);
		if(value[0])
			info.cvar.SetString(info.value);
	}
	
	return (info.cvar);
}

stock void ConVar_AddTemp(const char[] name, const char[] value, bool enforce=true)
{
	CvarInfo info;
	info.cvar = FindConVar(name);
	if(!info.cvar)
	{
		LogError("Invalid cvar \"%s\" from being set from config", name);
		return;
	}
	
	if(info.cvar.Flags & FCVAR_PROTECTED)
	{
		LogError("Blocked \"%s\" from being set from config", name);
		return;
	}
	
	info.OldFlags = info.cvar.Flags;
	info.cvar.Flags &= ~FCVAR_CHEAT;
	strcopy(info.value, sizeof(info.value), value);
	info.enforce = enforce;

	if(CvarEnabled)
		info.cvar.GetString(info.defaul, sizeof(info.defaul));

	if(!CvarMapList)
		CvarMapList = new ArrayList(sizeof(CvarInfo));

	CvarMapList.PushArray(info);
	
	if(CvarEnabled)
	{
		info.cvar.AddChangeHook(ConVar_OnChanged);
		if(value[0])
			info.cvar.SetString(info.value);
	}
}

stock void ConVar_RemoveTemp(const char[] name)
{
	if(CvarMapList)
	{
		ConVar cvar = FindConVar(name);
		int index = CvarMapList.FindValue(cvar, CvarInfo::cvar);
		if(index != -1)
		{
			CvarInfo info;
			CvarMapList.GetArray(index, info);
			CvarMapList.Erase(index);

			if(CvarEnabled)
			{
				info.cvar.RemoveChangeHook(ConVar_OnChanged);
				info.cvar.SetString(info.defaul);
			}
		}
	}
}

//its better to-inforce the flags.
void ConVar_ToggleDo()
{
	CvarInfo info;
	int length = CvarList.Length;
	for(int i; i<length; i++)
	{
		CvarList.GetArray(i, info);
		info.cvar.Flags &= ~(info.FlagsToDelete);
		CvarList.SetArray(i, info);
	}
}
void ConVar_Enable()
{
	if(!CvarEnabled)
	{
		CvarInfo info;
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarList.GetArray(i, info);
			info.cvar.GetString(info.defaul, sizeof(info.defaul));
			CvarList.SetArray(i, info);
			
			if(info.value[0])
				info.cvar.SetString(info.value);

			info.cvar.AddChangeHook(ConVar_OnChanged);
		}

		if(CvarMapList)
		{
			length = CvarMapList.Length;
			for(int i; i<length; i++)
			{
				CvarMapList.GetArray(i, info);
				info.cvar.GetString(info.defaul, sizeof(info.defaul));
				CvarMapList.SetArray(i, info);

				if(info.value[0])
					info.cvar.SetString(info.value);
					
				info.cvar.AddChangeHook(ConVar_OnChanged);
			}
		}

		CvarEnabled = true;
	}
}

void ConVar_Disable()
{
	if(CvarEnabled)
	{
		CvarInfo info;
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarList.GetArray(i, info);
			info.cvar.RemoveChangeHook(ConVar_OnChanged);
			info.cvar.SetString(info.defaul);
			info.cvar.Flags = info.OldFlags;
		}

		if(CvarMapList)
		{
			length = CvarMapList.Length;
			for(int i; i<length; i++)
			{
				CvarMapList.GetArray(i, info);

				info.cvar.RemoveChangeHook(ConVar_OnChanged);
				info.cvar.SetString(info.defaul);
				info.cvar.Flags = info.OldFlags;
			}

			delete CvarMapList;
		}

		CvarEnabled = false;
	}
}

public void ConVar_OnChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	CvarInfo info;
	int index = CvarList.FindValue(cvar, CvarInfo::cvar);
	if(index != -1)
	{
		CvarList.GetArray(index, info);

		if(!StrEqual(newValue, info.value))
		{
			if(info.enforce)
			{
				strcopy(info.defaul, sizeof(info.defaul), newValue);
				CvarList.SetArray(index, info);
				info.cvar.SetString(info.value);
			}
		}
	}

	if(CvarMapList)
	{
		int index2 = CvarMapList.FindValue(cvar, CvarInfo::cvar);
		if(index2 != -1)
		{
			CvarMapList.GetArray(index2, info);

			if(!StrEqual(newValue, info.value))
			{
				if(info.enforce)
				{
					strcopy(info.defaul, sizeof(info.defaul), newValue);
					CvarMapList.SetArray(index2, info);
					info.cvar.SetString(info.value);
				}
			}
		}
	}
}

#if defined ZR
static void StoreCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	//update store if these are updated.
	Items_SetupConfig();
	Store_ConfigSetup();
	CheckAprilFools();
}

static void WavesCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(!Configs_HasExecuted() || StrEqual(oldValue, newValue))
		return;
	
	char mapname[64];
	GetMapName(mapname, sizeof(mapname));
	KeyValues kv = Configs_GetMapKv(mapname);
	Waves_SetupVote(kv);
	Waves_SetupMiniBosses(kv);
	delete kv;
}

static void DownloadCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(!Configs_HasExecuted() || StrEqual(oldValue, newValue))
		return;
	
	char mapname[64];
	GetMapName(mapname, sizeof(mapname));
	KeyValues kv = Configs_GetMapKv(mapname);
	FileNetwork_ConfigSetup(kv);
	Building_ConfigSetup();
	NPC_ConfigSetup();
	Waves_SetupVote(kv);
	Waves_SetupMiniBosses(kv);
	delete kv;
}
#endif


void Convars_FixClientsideIssues(int client)
{
	SendConVarValue(client, tf_scout_air_dash_count, "1");
	//set to 1 for a frame...
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	RequestFrames(Convars_FixClientsideIssuesFrameAfter, 1, pack);
}
stock void Convars_FixClientsideIssuesFrameAfter(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(client))
	{
		delete pack;
		return;
	}

	//set to 0 afterwards.
	SendConVarValue(client, tf_scout_air_dash_count, "0");
	delete pack;
}
