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
static bool CvarEnabled;

void ConVar_PluginStart()
{
	if(CvarList != INVALID_HANDLE)
		delete CvarList;

	CvarList = new ArrayList(sizeof(CvarInfo));

	ConVar_Add("mp_forcecamera", "0.0");
	ConVar_Add("mp_autoteambalance", "0.0");
	ConVar_Add("mp_forceautoteam", "1.0");
	ConVar_Add("tf_bot_reevaluate_class_in_spawnroom", "1.0");
	ConVar_Add("tf_bot_keep_class_after_death", "1.0");
	ConVar_Add("mp_humans_must_join_team", "red");
	ConVar_Add("mp_teams_unbalance_limit", "0.0");
	ConVar_Add("mp_scrambleteams_auto", "0.0");
	ConVar_Add("tf_dropped_weapon_lifetime", "0.0");
	ConVar_Add("tf_spawn_glows_duration", "0.0");
	ConVar_Add("tf_weapon_criticals_distance_falloff", "1.0");
	ConVar_Add("tf_weapon_minicrits_distance_falloff", "1.0");
	ConVar_Add("tf_weapon_criticals", "0.0");
	ConVar_Add("tf_weapon_criticals_melee", "0.0");
	ConVar_Add("tf_boost_drain_time", "99999.0"); 			// have our own find logic..?
	ConVar_Add("tf_avoidteammates_pushaway", "0"); 
	
	ConVar_Add("sv_parallel_packentities", "1.0");
	ConVar_Add("sv_parallel_sendsnapshot", "0.0");
	ConVar_Add("sv_maxunlag", "1.0");
	ConVar_Add("tf_scout_air_dash_count", "0");
	
	ConVar_Add("nb_blind", "1.0"); //for bot
	ConVar_Add("tf_bot_quota_mode", "normal"); //for bot
//	ConVar_Add("tf_bot_quota", "2");
	
	ConVar_Add("sv_quota_stringcmdspersecond", "1000"); //IF FOR SOME REASON THE SERVER LAGS MASIVELY, PUT IT BACK TO 40/100 AT MOST! some cunt is abusing.
	
	ConVar_Add("nb_allow_climbing", "0.0"); // default:1
	ConVar_Add("nb_allow_gap_jumping", "0.0"); // default:1
	
	ConVar_Add("nb_update_framelimit", "30"); // default:15
	ConVar_Add("nb_update_frequency", "0.1"); // default:0
	ConVar_Add("nb_last_area_update_tolerance", "2.0"); // default:4
	ConVar_Add("sv_rollspeed", "2400.0"); // default: idk
#if defined ZR
	ConVar_Add("mp_tournament", "1");
	ConVar_Add("mp_disable_respawn_times", "1.0");
	ConVar_Add("tf_mvm_defenders_team_size", "99");
	//going above this is dumb
	ConVar_Add("tf_mvm_max_connected_players", "99");
	ConVar_Add("tf_obj_upgrade_per_hit", "0");
	ConVar_Add("tf_playergib", "0");

	CvarMaxPlayerAlive = CreateConVar("zr_maxplayersplaying", "16", "How many players can play at once?");
	CvarNoRoundStart = CreateConVar("zr_noroundstart", "0", "Makes it so waves refuse to start or continune", FCVAR_DONTRECORD);
	CvarNoSpecialZombieSpawn = CreateConVar("zr_nospecial", "0", "No Panzer will spawn or anything alike", FCVAR_DONTRECORD);
	zr_voteconfig = CreateConVar("zr_voteconfig", "raidmode", "Vote config zr/ .cfg already included");
	zr_tagblacklist = CreateConVar("zr_tagblacklist", "nominigames", "Tags to blacklist from weapons config", FCVAR_DONTRECORD);
	zr_tagwhitelist = CreateConVar("zr_tagwhitelist", "", "Tags to whitelist from weapons config", FCVAR_DONTRECORD);
	zr_tagwhitehard = CreateConVar("zr_tagwhitehard", "1", "If whitelist requires a tag instead of allowing", FCVAR_DONTRECORD);
	zr_minibossconfig = CreateConVar("zr_minibossconfig", "miniboss", "Mini Boss config zr/ .cfg already included");
	zr_ignoremapconfig = CreateConVar("zr_ignoremapconfig", "0", "If to ignore map-specific configs", FCVAR_DONTRECORD);
	zr_smallmapbalancemulti = CreateConVar("zr_smallmapmulti", "1.0", "For small maps, so harder difficulities with alot of aoe can still be played.", FCVAR_DONTRECORD);
	zr_disablerandomvillagerspawn = CreateConVar("zr_norandomvillager", "0.0", "Enable/Disable if medival villagers spawn randomly on the map or only on spawnpoints.");
	zr_waitingtime = CreateConVar("zr_waitingtime", "120.0", "Waiting for players time.");
	zr_enemymulticap = CreateConVar("zr_enemymulticap", "5.0", "Max enemy count multipler, will scale by health onwards", _, true, 0.5);
	zr_multi_multiplier = CreateConVar("zr_multi_enemy", "1.0", "Multiply the current scaling");
	zr_multi_maxcap = CreateConVar("zr_multi_zr_cap", "1.0", "Multiply the current max enemies allowed");
	zr_raidmultihp = CreateConVar("zr_raidmultihp", "1.0", "Multiply any boss HP that acts as a raid or megaboss, usefull for certain maps.", FCVAR_DONTRECORD);
	// MapSpawnersActive = CreateConVar("zr_spawnersactive", "4", "How many spawners are active by default,", _, true, 0.0, true, 32.0);
	//CHECK npcs.sp FOR THIS ONE!
	zr_downloadconfig = CreateConVar("zr_downloadconfig", "", "Downloads override config zr/ .cfg already included", FCVAR_DONTRECORD);
	CvarRerouteToIp = CreateConVar("zr_rerouteip", "", "If the server is full, reroute", FCVAR_DONTRECORD);
	CvarKickPlayersAt = CreateConVar("zr_kickplayersat", "", "If the server is full, Do reroute or kick", FCVAR_DONTRECORD);
	CvarRerouteToIpAfk = CreateConVar("zr_rerouteipafk", "", "If the server is full, reroute", FCVAR_DONTRECORD);
	CvarSkillPoints = CreateConVar("zr_skillpoints", "1", "If skill points are enabled");
	CvarRogueSpecialLogic = CreateConVar("zr_roguespeciallogic", "0", "Incase your server wants to remove some restrictions off the roguemode.");
	CvarLeveling = CreateConVar("zr_playerlevels", "1", "If player levels are enabled");
	CvarFileNetworkDisable = CreateConVar("zr_filenetwork_disable", "0", "0 means as intended, 1 means fast download sounds (itll download any waves present instnatly), 2 means download MVM style matreials too");

	HookConVarChange(zr_tagblacklist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitelist, StoreCvarChanged);
	HookConVarChange(zr_tagwhitehard, StoreCvarChanged);
#else
	ConVar_Add("mp_waitingforplayers_time", "0.0");
#endif

#if defined ZR || defined RPG
	CvarXpMultiplier = CreateConVar("zr_xpmultiplier", "1.0", "Amount of xp gained is multiplied by.");
	CvarRPGInfiniteLevelAndAmmo = CreateConVar("rpg_debug_store", "0", "Debug", FCVAR_DONTRECORD);
	ConVar_Add("mp_waitingforplayers_time", "0.0");
#endif
	//default should be 0.1
	zr_spawnprotectiontime = CreateConVar("zr_spawnprotectiontime", "0.1", "How long zombie spawn protection lasts for.");
	
	//CvarMaxBotsForKillfeed = CreateConVar("zr_maxbotsforkillfeed", "8", "The maximum amount of blue bots allowed for the killfeed and more");
	CvarDisableThink = CreateConVar("zr_disablethinking", "0", "Disable NPC thinking", FCVAR_DONTRECORD);

#if defined ZR || defined RTS	
	CvarInfiniteCash = CreateConVar("zr_infinitecash", "0", "Money is infinite and always set to 999999", FCVAR_DONTRECORD);
#endif

#if defined RPG
	ConVar_Add("mp_friendlyfire", "1.0"); // default: 0.9 Ty to miku for showing me
#endif
	mp_bonusroundtime = FindConVar("mp_bonusroundtime");
	mp_bonusroundtime.SetBounds(ConVarBound_Upper, false);

	AutoExecConfig(true, "zombie_riot");
	
}

void ConVar_Add(const char[] name, const char[] value, bool enforce=true)
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

stock void ConVar_Remove(const char[] name)
{
	ConVar cvar = FindConVar(name);
	int index = CvarList.FindValue(cvar, CvarInfo::cvar);
	if(index != -1)
	{
		CvarInfo info;
		CvarList.GetArray(index, info);
		CvarList.Erase(index);

		if(CvarEnabled)
		{
			info.cvar.RemoveChangeHook(ConVar_OnChanged);
			info.cvar.SetString(info.defaul);
		}
	}
}

void ConVar_Enable()
{
	if(!CvarEnabled)
	{
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarInfo info;
			CvarList.GetArray(i, info);
			info.cvar.GetString(info.defaul, sizeof(info.defaul));
			CvarList.SetArray(i, info);

			info.cvar.SetString(info.value);
			info.cvar.AddChangeHook(ConVar_OnChanged);
		}

		CvarEnabled = true;
	}
}

void ConVar_Disable()
{
	if(CvarEnabled)
	{
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarInfo info;
			CvarList.GetArray(i, info);

			info.cvar.RemoveChangeHook(ConVar_OnChanged);
			info.cvar.SetString(info.defaul);
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


public void StoreCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	//update store if these are updated.
	Items_SetupConfig();
	Store_ConfigSetup();
}

