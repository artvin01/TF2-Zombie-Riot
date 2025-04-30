#pragma semicolon 1
#pragma newdecls required

enum struct CvarInfo
{
	ConVar cvar;
	char value[16];
	char defaul[16];
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
	ConVar_Add("mp_humans_must_join_team", "red"); //Only read
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

	ConVar_Add("tf_scout_air_dash_count", "-1"); //Remove doublejumps
	ConVar_Add("tf_allow_player_use", "1"); //Allow use!
	ConVar_Add("tf_flamethrower_boxsize", "0.0"); //Flamethrower Particles are useless in ZR

	ConVar_Add("sv_hudhint_sound", "0.0"); //Removes the wind sound when calling hint hunds
#if defined ZR
	ConVar_Add("mp_tournament", "1"); //NEEDS to be 1 , or else mvm logic seems to break in ZR.
	ConVar_Add("mp_disable_respawn_times", "1.0"); 
	ConVar_Add("tf_mvm_defenders_team_size", "99");
	//going above this is dumb
	ConVar_Add("tf_mvm_max_connected_players", "99");
#endif
#if defined ZR || defined RPG
	ConVar_Add("mp_waitingforplayers_time", "0.0");
#endif
#if defined RPG
	ConVar_Add("mp_friendlyfire", "1.0");
#endif

#if defined ZR
	CvarMaxPlayerAlive = CreateConVar("zr_maxplayersplaying", "-1", "How many players can play at once?");
	CvarNoRoundStart = CreateConVar("zr_noroundstart", "0", "Makes it so waves refuse to start or continune", FCVAR_DONTRECORD);
	Cvar_VshMapFix = CreateConVar("zr_stripmaplogic", "0", "Strip maps of logic for ZR", FCVAR_DONTRECORD);
	CvarNoSpecialZombieSpawn = CreateConVar("zr_nospecial", "0", "No Panzer will spawn or anything alike");
	zr_voteconfig = CreateConVar("zr_voteconfig", "raidmode", "Vote config zr/ .cfg already included");
	zr_tagblacklist = CreateConVar("zr_tagblacklist", "", "Tags to blacklist from weapons config");
	zr_tagwhitelist = CreateConVar("zr_tagwhitelist", "", "Tags to whitelist from weapons config");
	zr_tagwhitehard = CreateConVar("zr_tagwhitehard", "1", "If whitelist requires a tag instead of allowing");
	zr_minibossconfig = CreateConVar("zr_minibossconfig", "miniboss", "Mini Boss config zr/ .cfg already included");
	zr_ignoremapconfig = CreateConVar("zr_ignoremapconfig", "0", "If to ignore map-specific configs");
	zr_smallmapbalancemulti = CreateConVar("zr_smallmapmulti", "1.0", "For small maps, so harder difficulities with alot of aoe can still be played.");
	zr_disablerandomvillagerspawn = CreateConVar("zr_norandomvillager", "0.0", "Enable/Disable if medival villagers spawn randomly on the map or only on spawnpoints.");
	zr_waitingtime = CreateConVar("zr_waitingtime", "120.0", "Waiting for players time.");
	zr_enemymulticap = CreateConVar("zr_enemymulticap", "4.0", "Max enemy count multipler, will scale by health onwards", _, true, 0.5);
	zr_multi_multiplier = CreateConVar("zr_multi_enemy", "1.0", "Multiply the current scaling");
	zr_multi_maxcap = CreateConVar("zr_multi_zr_cap", "1.0", "Multiply the current max enemies allowed");
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

	HookConVarChange(zr_tagblacklist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitelist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitehard, StoreCvarChanged);
	HookConVarChange(zr_voteconfig, WavesCvarChanged);
	HookConVarChange(zr_minibossconfig, WavesCvarChanged);
	HookConVarChange(CvarAutoSelectWave, WavesCvarChanged);
	HookConVarChange(zr_ignoremapconfig, DownloadCvarChanged);
	HookConVarChange(zr_downloadconfig, DownloadCvarChanged);
#endif

#if defined ZR || defined RPG
	CvarFileNetworkDisable = CreateConVar("zr_filenetwork_disable", "0", "0 means as intended, 1 means fast download sounds (itll download any waves present instnatly), 2 means download MVM style matreials too");
	CvarXpMultiplier = CreateConVar("zr_xpmultiplier", "1.0", "Amount of xp gained is multiplied by.");
	CvarRPGInfiniteLevelAndAmmo = CreateConVar("rpg_debug_store", "0", "Debug", FCVAR_DONTRECORD);
	CvarCustomModels = CreateConVar("zr_custommodels", "1", "If custom player models are enabled");
	
	//default should be 0.1
	zr_spawnprotectiontime = CreateConVar("zr_spawnprotectiontime", "0.1", "How long zombie spawn protection lasts for.");
#endif

#if defined ZR || defined RTS	
	CvarInfiniteCash = CreateConVar("zr_infinitecash", "0", "Money is infinite and always set to 999999", FCVAR_DONTRECORD);
#endif

	CvarDisableThink = CreateConVar("zr_disablethinking", "0", "Disable NPC thinking", FCVAR_DONTRECORD);
	zr_interactforcereload = CreateConVar("zr_interactforcereload", "0", "force interact with reload, it also blocks spray interacting like before.");

	mp_bonusroundtime = FindConVar("mp_bonusroundtime");
	mp_bonusroundtime.SetBounds(ConVarBound_Upper, false);

	//AutoExecConfig(true, "zombie_riot");
	
}

static void ConVar_Add(const char[] name, const char[] value, bool enforce=true)
{
	CvarInfo info;
	info.cvar = FindConVar(name);
	info.cvar.Flags &= ~FCVAR_CHEAT;
	strcopy(info.value, sizeof(info.value), value);
	info.enforce = enforce;

	if(CvarEnabled)
	{
		info.cvar.GetString(info.defaul, sizeof(info.defaul));
		info.cvar.SetString(info.value);
		info.cvar.AddChangeHook(ConVar_OnChanged);
	}

	CvarList.PushArray(info);
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
	
	info.cvar.Flags &= ~FCVAR_CHEAT;
	strcopy(info.value, sizeof(info.value), value);
	info.enforce = enforce;

	if(CvarEnabled)
	{
		info.cvar.GetString(info.defaul, sizeof(info.defaul));
		info.cvar.SetString(info.value);
		info.cvar.AddChangeHook(ConVar_OnChanged);
	}

	if(!CvarMapList)
		CvarMapList = new ArrayList(sizeof(CvarInfo));

	CvarMapList.PushArray(info);
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
		}

		if(CvarMapList)
		{
			length = CvarMapList.Length;
			for(int i; i<length; i++)
			{
				CvarMapList.GetArray(i, info);

				info.cvar.RemoveChangeHook(ConVar_OnChanged);
				info.cvar.SetString(info.defaul);
			}

			delete CvarMapList;
		}

		CvarEnabled = false;
	}
}

public void ConVar_OnChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	int index = CvarList.FindValue(cvar, CvarInfo::cvar);
	if(index != -1)
	{
		CvarInfo info;
		CvarList.GetArray(index, info);

		if(!StrEqual(newValue, info.value))
		{
			if(info.enforce)
			{
				strcopy(info.defaul, sizeof(info.defaul), newValue);
				CvarList.SetArray(index, info);
				info.cvar.SetString(info.value);
			}
			else
			{
				info.cvar.RemoveChangeHook(ConVar_OnChanged);
				CvarList.Erase(index);
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
	if(!Configs_HasExecuted())
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
	if(!Configs_HasExecuted())
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
