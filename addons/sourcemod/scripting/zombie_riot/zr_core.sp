#pragma semicolon 1
#pragma newdecls required

#define AskPluginLoad2_ ZR_PluginLoad
#define OnPluginStart_ ZR_PluginStart

public const int AmmoData[][] =
{
	// Price, Ammo
	{ 0, 0 },			//N/A
	{ 0, 0 },			//Primary
	{ 0, 99999 },		//Secondary
	{ 10, 500 },		//Metal
	{ 0, 0 },			//Ball
	{ 0, 0 },			//Food
	{ 0, 0 },			//Jar
	{ 10, 72 },			//Pistol Magazines
	{ 10, 12 },			//Rockets
	{ 10, 100 },		//Flamethrower Tank
	{ 10, 12 },			//Flares
	{ 10, 10 },			//Grenades
	{ 10, 10 },			//Stickybombs
	{ 10, 100 },		//Minigun Barrel
	{ 10, 10 },			//Custom Bolt
	{ 10, 100 },		//Meedical Syringes
	{ 10, 12 },			//Sniper Rifle Rounds
	{ 10, 12 },			//Arrows
	{ 10, 60 },			//SMG Magazines
	{ 10, 14 },			//REvolver Rounds
	{ 10, 12 },			//Shotgun Shells
	{ 10, 400 },		//Healing Medicine
	{ 10, 500 },		//Medigun Fluid
	{ 10, 80 },			//Laser Battery
	{ 0, 0 },			//Hand Grenade
	{ 0, 0 }			//Drinks like potions
};

int i_CurrentEquippedPerk[MAXTF2PLAYERS];

//FOR PERK MACHINE!
public const char PerkNames[][] =
{
	"No Perk",
	"Quick Revive",
	"Juggernog",
	"Double Tap",
	"Speed Cola",
	"Deadshot Daiquiri",
	"Widows Wine",
};

public const char PerkNames_Recieved[][] =
{
	"No Perk",
	"Quick Revive Recieved",
	"Juggernog Recieved",
	"Double Tap Recieved",
	"Speed Cola Recieved",
	"Deadshot Daiquiri Recieved",
	"Widows Wine Recieved",
};

#include "zombie_riot/npc.sp"
#include "zombie_riot/music.sp"
#include "zombie_riot/waves.sp"
#include "zombie_riot/escape.sp"
#include "zombie_riot/zombie_drops.sp"
#include "zombie_riot/queue.sp"
#include "zombie_riot/item_gift_rpg.sp"
#include "zombie_riot/tutorial.sp"
#include "zombie_riot/custom/building.sp"
#include "zombie_riot/custom/healing_medkit.sp"
#include "zombie_riot/custom/weapon_slug_rifle.sp"
#include "zombie_riot/custom/weapon_boom_stick.sp"
#include "zombie_riot/custom/weapon_heavy_eagle.sp"
#include "zombie_riot/custom/weapon_annabelle.sp"
#include "zombie_riot/custom/weapon_rampager.sp"
#include "zombie_riot/custom/joke_medigun_mod_drain_health.sp"
#include "zombie_riot/custom/weapon_heaven_eagle.sp"
#include "zombie_riot/custom/weapon_star_shooter.sp"
#include "zombie_riot/custom/weapon_bison.sp"
#include "zombie_riot/custom/weapon_pomson.sp"
#include "zombie_riot/custom/weapon_cowmangler.sp"
#include "zombie_riot/custom/weapon_cowmangler_2.sp"
#include "zombie_riot/custom/weapon_auto_shotgun.sp"
#include "zombie_riot/custom/weapon_fists_of_kahml.sp"
#include "zombie_riot/custom/weapon_fusion_melee.sp"
#include "zombie_riot/custom/spike_layer.sp"
#include "zombie_riot/custom/weapon_grenade.sp"
#include "zombie_riot/custom/weapon_pipebomb.sp"
#include "zombie_riot/custom/wand/weapon_default_wand.sp"
#include "zombie_riot/custom/wand/weapon_wand_increace_attack.sp"
#include "zombie_riot/custom/wand/weapon_fire_wand.sp"
#include "zombie_riot/custom/wand/weapon_wand_fire_ball.sp"
#include "zombie_riot/custom/wand/weapon_lightning_wand.sp"
#include "zombie_riot/custom/wand/weapon_wand_cryo.sp"
#include "zombie_riot/custom/wand/weapon_wand_lightning_spell.sp"
#include "zombie_riot/custom/wand/weapon_necromancy_wand.sp"
#include "zombie_riot/custom/wand/weapon_wand_necro_spell.sp"
#include "zombie_riot/custom/wand/weapon_autoaim_wand.sp"
#include "zombie_riot/custom/weapon_arrow_shot.sp"
//#include "zombie_riot/custom/weapon_pipe_shot.sp"
#include "zombie_riot/custom/weapon_survival_knife.sp"
#include "zombie_riot/custom/weapon_glitched.sp"
#include "zombie_riot/custom/weapon_minecraft.sp"
#include "zombie_riot/custom/arse_enal_layer_tripmine.sp"
#include "zombie_riot/custom/weapon_serioussam2_shooter.sp"
#include "zombie_riot/custom/wand/weapon_elemental_staff.sp"
#include "zombie_riot/custom/wand/weapon_elemental_staff_2.sp"
#include "zombie_riot/custom/weapon_infinity_blade.sp"
//#include "zombie_riot/custom/weapon_black_fire_wand.sp"
#include "zombie_riot/custom/wand/weapon_chlorophite.sp"
#include "zombie_riot/custom/wand/weapon_chlorophite_heavy.sp"
#include "zombie_riot/custom/weapon_drink_resupply_mana.sp"
#include "zombie_riot/custom/weapon_wind_staff.sp"
#include "zombie_riot/custom/wand/weapon_nailgun.sp"
#include "zombie_riot/custom/weapon_five_seven.sp"
#include "zombie_riot/custom/weapon_gb_medigun.sp"
#include "zombie_riot/custom/weapon_charged_handgun.sp"
#include "zombie_riot/custom/wand/weapon_wand_beam.sp"
#include "zombie_riot/custom/wand/weapon_wand_lightning_pap.sp"
#include "zombie_riot/custom/wand/weapon_calcium_wand.sp"
#include "zombie_riot/custom/wand/weapon_wand_calcium_spell.sp"
#include "zombie_riot/custom/weapon_passive_banner.sp"
#include "zombie_riot/custom/weapon_zeroknife.sp"
#include "zombie_riot/custom/weapon_ark.sp"
#include "zombie_riot/custom/pets.sp"
#include "zombie_riot/custom/coin_flip.sp"
#include "zombie_riot/custom/weapon_manual_reload.sp"
#include "zombie_riot/custom/weapon_atomic.sp"
#include "zombie_riot/custom/weapon_super_star_shooter.sp"
#include "zombie_riot/custom/weapon_Texan_business.sp"
#include "zombie_riot/custom/weapon_explosivebullets.sp"
#include "zombie_riot/custom/weapon_sniper_monkey.sp"
#include "zombie_riot/custom/weapon_cspyknife.sp"
#include "zombie_riot/custom/wand/weapon_quantum_weaponry.sp"
#include "zombie_riot/custom/weapon_riotshield.sp"
#include "zombie_riot/custom/escape_sentry_hat.sp"
#include "zombie_riot/custom/m3_abilities.sp"

void ZR_PluginLoad()
{
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetWaveCount", Native_GetWaveCounts);
	CreateNative("ZR_GetLevelCount", Native_GetLevelCount);
}

void ZR_PluginStart()
{
	RegServerCmd("zr_reloadnpcs", OnReloadCommand, "Reload NPCs");
	RegServerCmd("sm_reloadnpcs", OnReloadCommand, "Reload NPCs", FCVAR_HIDDEN);
	RegConsoleCmd("sm_store", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_shop", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_afk", Command_AFK, "BRB GONNA CLEAN MY MOM'S DISHES");
	RegAdminCmd("sm_give_cash", Command_GiveCash, ADMFLAG_ROOT, "Give Cash to the Person");
	RegAdminCmd("sm_tutorial_test", Command_TestTutorial, ADMFLAG_ROOT, "Test The Tutorial");
	RegAdminCmd("sm_give_dialog", Command_GiveDialogBox, ADMFLAG_ROOT, "Give a dialog box");
	RegAdminCmd("sm_afk_knight", Command_AFKKnight, ADMFLAG_GENERIC, "BRB GONNA MURDER MY MOM'S DISHES");
	RegAdminCmd("sm_spawn_grigori", Command_SpawnGrigori, ADMFLAG_GENERIC, "Forcefully summon grigori");
	
	CookieCache = new Cookie("zr_lastgame", "The last game saved data is from", CookieAccess_Protected);
	CookieXP = new Cookie("zr_xp", "Your XP", CookieAccess_Protected);
	CookieScrap = new Cookie("zr_Scrap", "Your Scrap", CookieAccess_Protected);
	CookiePlayStreak = new Cookie("zr_playstreak", "How many times you played in a row", CookieAccess_Protected);
	
	Medigun_PluginStart();
	OnPluginStartMangler();
	SentryHat_OnPluginStart();
	OnPluginStart_Build_on_Building();
	OnPluginStart_Glitched_Weapon();
	Tutorial_PluginStart();
	Waves_PluginStart();
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		OnEntityCreated(ent, "info_player_teamspawn");	
	}
}

public Action OnReloadCommand(int args)
{
	char path[PLATFORM_MAX_PATH], filename[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "plugins/npc");
	FileType filetype;
	Handle directory = OpenDirectory(path);
	if(directory)
	{
		while(ReadDirEntry(directory, filename, sizeof(filename), filetype))
		{
			if(filetype==FileType_File && StrContains(filename, ".smx", false)!=-1)
				ServerCommand("sm plugins reload npc/%s", filename);
		}
	}
	
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, path, sizeof(path)))
		{
			if(!StrContains(path, "base_boss"))
				RemoveEntity(i);
		}
	}
	return Plugin_Handled;
}



public Action Command_AFK(int client, int args)
{
	if(client)
	{
		b_HasBeenHereSinceStartOfWave[client] = false;
		WaitingInQueue[client] = true;
		ChangeClientTeam(client, 1);
	}
	return Plugin_Handled;
}


public Action Command_TestTutorial(int client, int args)
{
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_tutorial_test <target>");
        return Plugin_Handled;
    }	
       
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		StartTutorial(targets[target]);
	}
	return Plugin_Handled;
}
public Action Command_GiveCash(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_cash <target> <cash>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[12];
	GetCmdArg(2, buf, sizeof(buf));
	int money = StringToInt(buf); 

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		if(money > 0)
		{
			PrintToChat(targets[target], "You got %i cash from the admin %N!", money, client);
			CashSpent[targets[target]] -= money;
		}
		else
		{
			PrintToChat(targets[target], "You lost %i cash due to the admin %N!", money, client);
			CashSpent[targets[target]] -= money;			
		}
	}
	
	return Plugin_Handled;
}


public Action Command_GiveDialogBox(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_dialog <target> <Question>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[64];
	GetCmdArg(2, buf, sizeof(buf));
	
	char buf2[64];
	GetCmdArg(3, buf2, sizeof(buf2));

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		SetGlobalTransTarget(client);
		char yourPoints[64];
		Format(yourPoints, sizeof(yourPoints), buf); 
				
		Handle hKv = CreateKeyValues("Stuff", "title", yourPoints);
		KvSetColor(hKv, "color", 0, 255, 0, 255); //green
		KvSetNum(hKv,   "level", 1); //im not sure..
		KvSetNum(hKv,   "time",  10); // how long? 
		KvSetString(hKv,   "command", "say /tp"); //command when selected
		KvSetString(hKv,   "msg",  buf2); // how long? 
		CreateDialog(client, hKv, DialogType_Menu);
		CloseHandle(hKv);
	}
	
	return Plugin_Handled;
}

public Action Command_AFKKnight(int client, int args)
{
	if(client)
	{
		WaitingInQueue[client] = true;
		ChangeClientTeam(client, 2);
	}
	return Plugin_Handled;
}

public Action Command_SpawnGrigori(int client, int args)
{
	Spawn_Cured_Grigori();
	Store_RandomizeNPCStore(false);
	return Plugin_Handled;
}