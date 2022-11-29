#pragma semicolon 1
#pragma newdecls required

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

float MultiGlobal = 0.25;
float f_WasRecentlyRevivedViaNonWave[MAXTF2PLAYERS];

#include "zombie_riot/npc.sp"	// Global NPC List

#include "zombie_riot/database.sp"
#include "zombie_riot/escape.sp"
#include "zombie_riot/item_gift_rpg.sp"
#include "zombie_riot/music.sp"
#include "zombie_riot/queue.sp"
#include "zombie_riot/tutorial.sp"
#include "zombie_riot/waves.sp"
#include "zombie_riot/zombie_drops.sp"
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
//#include "zombie_riot/custom/weapon_minecraft.sp"
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
	CreateNative("ZR_GetWaveCount", Native_GetWaveCounts);
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
	
	Database_PluginStart();
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

void ZR_MapStart()
{
	EscapeMode = false;
	EscapeModeForNpc = false;
	
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	RoundStartTime = 0.0;
	cvarTimeScale.SetFloat(1.0);
	Waves_MapStart();
	Music_MapStart();
	Remove_Healthcooldown();
	Medigun_PersonOnMapStart();
	Star_Shooter_MapStart();
	Bison_MapStart();
	Pomson_MapStart();
	Mangler_MapStart();
	Pipebomb_MapStart();
	Wand_Map_Precache();
	Wand_Attackspeed_Map_Precache();
	Wand_Fire_Map_Precache();
	Wand_FireBall_Map_Precache();
	Wand_Lightning_Map_Precache();
	Wand_LightningAbility_Map_Precache();
	Wand_Necro_Map_Precache();
	Wand_NerosSpell_Map_Precache();
	Wand_autoaim_Map_Precache();
	Weapon_Arrow_Shoot_Map_Precache();
//	Weapon_Pipe_Shoot_Map_Precache();
	OnMapStart_Build_on_Build();
	Building_MapStart();
	Survival_Knife_Map_Precache();
	Aresenal_Weapons_Map_Precache();
	SS2_Map_Precache();
	Wand_Elemental_Map_Precache();
	Wand_Elemental_2_Map_Precache();
	Map_Precache_Zombie_Drops();
	Wand_CalciumSpell_Map_Precache();
	Wand_Calcium_Map_Precache();
//	Wand_Black_Fire_Map_Precache();
	Wand_Chlorophite_Map_Precache();
	MapStart_CustomMeleePrecache();
	MagicRestore_MapStart();
	Wind_Staff_MapStart();
	Nailgun_Map_Precache();
	OnMapStart_NPC_Base();
	Gb_Ball_Map_Precache();
	Map_Precache_Zombie_Drops_Gift();
	Grenade_Custom_Precache();
	BoomStick_MapPrecache();
	Charged_Handgun_Map_Precache();
	TBB_Precahce_Mangler_2();
	BeamWand_MapStart();
	M3_Abilities_Precache();
	Ark_autoaim_Map_Precache();
	Wand_LightningPap_Map_Precache();
	Wand_Cryo_Precache();
	Abiltity_Coin_Flip_Map_Change();
	Wand_Cryo_Precache();
	Npc_Sp_Precache();
	Fusion_Melee_OnMapStart();
	Atomic_MapStart();
	SSS_Map_Precache();
	ExplosiveBullets_Precache();
	Quantum_Gear_Map_Precache();
	WandStocks_Map_Precache();
	Weapon_RiotShield_Map_Precache();
	
	Zombies_Currently_Still_Ongoing = 0;
	// An info_populator entity is required for a lot of MvM-related stuff (preserved entity)
//	CreateEntityByName("info_populator");
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	CreateTimer(2.0, GetClosestSpawners, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	
	FormatEx(char_MusicString1, sizeof(char_MusicString1), "");
			
	FormatEx(char_MusicString2, sizeof(char_MusicString2), "");
			
	i_MusicLength1 = 0;
	i_MusicLength2 = 0;
	
	//Store_RandomizeNPCStore(true);
}

void ZR_ClientPutInServer(int client)
{
	Queue_PutInServer(client);
	i_AmountDowned[client] = 0;
	dieingstate[client] = 0;
	TeutonType[client] = 0;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	CashRecievedNonWave[client] = 0;
	Healing_done_in_total[client] = 0;
	i_BarricadeHasBeenDamaged[client] = 0;
	i_KillsMade[client] = 0;
	i_Backstabs[client] = 0;
	i_Headshots[client] = 0;
	Ammo_Count_Ready[client] = 0;
	Armor_Charge[client] = 0;
	Doing_Handle_Mount[client] = false;
	b_Doing_Buildingpickup_Handle[client] = false;
	g_CarriedDispenser[client] = INVALID_ENT_REFERENCE;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	i_CurrentEquippedPerk[client] = 0;
	i_HealthBeforeSuit[client] = 0;
	i_ClientHasCustomGearEquipped[client] = false;
	
	if(CurrentRound)
		CashSpent[client] = RoundToCeil(float(CurrentCash) * 0.20);
}

void ZR_ClientDisconnect(int client)
{
	SetClientTutorialMode(client, false);
	SetClientTutorialStep(client, 0);
	Pets_ClientDisconnect(client);
	Queue_ClientDisconnect(client);
	b_HasBeenHereSinceStartOfWave[client] = false;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	CashRecievedNonWave[client] = 0;
	Healing_done_in_total[client] = 0;
	Ammo_Count_Ready[client] = 0;
	Armor_Charge[client] = 0;
	PlayerPoints[client] = 0;
	i_PreviousPointAmount[client] = 0;
	i_ExtraPlayerPoints[client] = 0;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	Escape_DropItem(client, false);
}

public any Native_GetWaveCounts(Handle plugin, int numParams)
{
	return CurrentRound;
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

public void OnClientAuthorized(int client)
{
	Database_ClientAuthorized(client);
}

public void OnClientDisconnect_Post(int client)
{
	int Players_left;
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			Players_left++;
	}
	CheckAlivePlayers(_);
}

public Action Timer_Dieing(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] > 0)
	{
		if(b_LeftForDead[client])
		{
			dieingstate[client] -= 3;
			f_DelayLookingAtHud[client] = GetGameTime() + 0.2;
			PrintCenterText(client, "%t", "Reviving", dieingstate[client]);
			
			if(dieingstate[client] <= 0)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				RequestFrame(Movetype_walk, client);
				dieingstate[client] = 0;
					
				SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", client);
				f_WasRecentlyRevivedViaNonWave[client] = GetGameTime() + 1.0;
				
				float pos[3], ang[3];
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
				ang[2] = 0.0;
				DHook_RespawnPlayer(client);
				
				TeleportEntity(client, pos, ang, NULL_VECTOR);
				SetEntProp(client, Prop_Send, "m_bDucked", true);
				SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
				CClotBody npc = view_as<CClotBody>(client);
				npc.m_bThisEntityIgnored = false;
				SetEntityCollisionGroup(client, 5);
				PrintCenterText(client, "");
				DoOverlay(client, "");
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
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
				
				return Plugin_Stop;
			}
			return Plugin_Continue;
		}
		
		if(f_DisableDyingTimer[client] >= GetGameTime())
		{
			return Plugin_Continue;
		}
		SetEntityHealth(client, GetClientHealth(client) - 1);
		SDKHooks_TakeDamage(client, client, client, 1.0);
		
		if(!b_LeftForDead[client])
		{
			int particle = EntRefToEntIndex(i_DyingParticleIndication[client]);
			if(IsValidEntity(particle))
			{
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
				
				color[0] = GetEntProp(client, Prop_Send, "m_iHealth") * 255  / 210; // red  200 is the max health you can have while dying.
				color[1] = GetEntProp(client, Prop_Send, "m_iHealth") * 255  / 210;	// green
					
				color[0] = 255 - color[0];
				
				SetVariantColor(color);
				AcceptEntityInput(particle, "SetGlowColor");
			}
		}
			
		return Plugin_Continue;
	}
	int particle = EntRefToEntIndex(i_DyingParticleIndication[client]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	dieingstate[client] = 0;
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	
	return Plugin_Stop;
}


//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!





//int Bob_To_Player[MAXENTITIES];
bool Bob_Exists = false;
int Bob_Exists_Index = -1;

public void CheckIfAloneOnServer()
{
	b_IsAloneOnServer = false;
	int players;
	int player_alone;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
		{
			players += 1;
			player_alone = client;
		}
	}
	if(players == 1)
	{
		b_IsAloneOnServer = true;	
	}
	if (players < 4 && players > 0)
	{
		if (Bob_Exists)
			return;
		
		Spawn_Bob_Combine(player_alone);
		
	}
	else if (Bob_Exists)
	{
		Bob_Exists = false;
		NPC_Despawn_bob(EntRefToEntIndex(Bob_Exists_Index));
		Bob_Exists_Index = -1;
	}
}

public void Spawn_Bob_Combine(int client)
{
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	flAng[2] = 0.0;
	int bob = Npc_Create(BOB_THE_GOD_OF_GODS, client, flPos, flAng, true);
	Bob_Exists = true;
	Bob_Exists_Index = EntIndexToEntRef(bob);
	GiveNamedItem(client, "Bob the Overgod of gods and destroyer of multiverses");
}

public void NPC_Despawn_bob(int entity)
{
	if(IsValidEntity(entity) && entity != 0)
	{
		BobTheGod_NPCDeath(entity);
	}
	Bob_Exists_Index = -1;
}

public void Spawn_Cured_Grigori()
{
	int client = -1;
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			client = client_summon;
		}
	}
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	flAng[2] = 0.0;
	int entity = Npc_Create(CURED_FATHER_GRIGORI, client, flPos, flAng, true);
	SalesmanAlive = EntIndexToEntRef(entity);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_grigori");
	
	for(int client_Give_item=1; client_Give_item<=MaxClients; client_Give_item++)
	{
		if(IsClientInGame(client_Give_item) && GetClientTeam(client_Give_item)==2)
		{
			GiveNamedItem(client_Give_item, "Cured Grigori");
		}
	}
}

//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!
//	BOB ALONE PLAYER STUFF!

void CheckAlivePlayersforward(int killed=0)
{
	CheckAlivePlayers(killed, _);
}

void CheckAlivePlayers(int killed=0, int Hurtviasdkhook = 0)
{
	if(!Waves_Started() || GameRules_GetRoundState() != RoundState_RoundRunning)
	{
		LastMann = false;
		CurrentPlayers = 0;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
			{
				CurrentPlayers++;
			}
		}
		return;
	}
	
	CheckIfAloneOnServer();
	
	bool alive;
	LastMann = !Waves_InSetup();
	int players = CurrentPlayers;
	CurrentPlayers = 0;
	int GlobalIntencity_Reduntant = Waves_GetIntencity();
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
		{
			CurrentPlayers++;
			if(killed != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE/* && dieingstate[client] == 0*/)
			{
				if(dieingstate[client] > 0)
				{
					GlobalIntencity_Reduntant++;	
				}
				if(!alive)
				{
					alive = true;
				}
				else if(LastMann)
				{
					LastMann = false;
				}
				
			}
			else
			{
				GlobalIntencity_Reduntant++;
			}
			
			if(Hurtviasdkhook != 0)
			{
				LastMann = true;
			}
		}
	}
	
	if(CurrentPlayers < players)
		CurrentPlayers = players;
	
	if(LastMann && !GlobalIntencity_Reduntant) //Make sure if they are alone, it wont play last man music.
		LastMann = false;
	
	if(LastMann)
	{
		static bool Died[MAXTF2PLAYERS];
		for(int client=1; client<=MaxClients; client++)
		{
			Died[client] = false;
			if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
			{
				if((killed != client || Hurtviasdkhook != client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] > 0)
				{
					Died[client] = true;
					SDKHooks_TakeDamage(client, client, client, 99999.0, DMG_DROWN, _, _, _, true);
				}
			}
		}
		ExcuteRelay("zr_lasthuman");
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] == TEUTON_NONE)
			{
				if(IsPlayerAlive(client) && !applied_lastmann_buffs_once && !Died[client])
				{
					if(dieingstate[client] > 0)
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
					}
					
					for(int i=1; i<=MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsFakeClient(i))
						{
							Music_Stop_All(i);
							SetMusicTimer(i, GetTime() + 5); //give them 5 seconds to react to full on panic.
							SetEntPropEnt(i, Prop_Send, "m_hObserverTarget", client);
						}
					}
					
					for(int i=1; i<=MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsFakeClient(i))
						{
							SendConVarValue(i, sv_cheats, "1");
						}
					}
					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.3, SetTimeBack);
				
					applied_lastmann_buffs_once = true;
					
					SetHudTextParams(-1.0, -1.0, 3.0, 255, 0, 0, 255);
					ShowHudText(client, -1, "%T", "Last Alive", client);
					int MaxHealth;
					MaxHealth = SDKCall_GetMaxHealth(client) * 2;
					
					SetEntProp(client, Prop_Send, "m_iHealth", MaxHealth);
					
					int Extra = 0;
						
					Extra = RoundToNearest(Attributes_FindOnPlayer(client, 701));

					if(Extra == 50)
						Armor_Charge[client] = 200;
						
					else if(Extra == 100)
						Armor_Charge[client] = 350;
						
					else if(Extra == 150)
						Armor_Charge[client] = 700;
						
					else if(Extra == 200)
						Armor_Charge[client] = 1500;
						
					else
						Armor_Charge[client] = 150;
									
				}
			}
		}
	}
	else
		applied_lastmann_buffs_once = false;
	
	if(!alive)
	{
		if (Bob_Exists)
		{
			Bob_Exists = false;
			int bob_index = EntRefToEntIndex(Bob_Exists_Index);
			NPC_Despawn_bob(bob_index);
			Bob_Exists_Index = 0;
		}
	
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		
		if(killed)
		{
			Music_RoundEnd(killed);
			CreateTimer(5.0, Remove_All, _, TIMER_FLAG_NO_MAPCHANGE);
		//	RequestFrames(Remove_All, 300);
		}
	}
}



//Revival raid spam
public void SetHealthAfterReviveRaid(int client)
{
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		RequestFrame(SetHealthAfterReviveRaidAgain, client);	
	}
}

public void SetHealthAfterReviveRaidAgain(int client)
{
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		RequestFrame(SetHealthAfterReviveRaidAgainAgain, client);	
	}
}

public void SetHealthAfterReviveRaidAgainAgain(int client)
{
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
	}
}
//Revival raid spam

//Set hp spam after normal revive
public void SetHealthAfterRevive(int client)
{
	if(IsValidClient(client))
	{	
		RequestFrame(SetHealthAfterReviveAgain, client);	
	}
}

public void SetHealthAfterReviveAgain(int client)
{
	if(IsValidClient(client))
	{	
		RequestFrame(SetHealthAfterReviveAgainAgain, client);	
		if(EscapeMode)
		{
			SetEntityHealth(client, 150);
		}
		else
		{
			SetEntityHealth(client, 50);
		}
	}
	
}

public void SetHealthAfterReviveAgainAgain(int client) //For some reason i have to do it more then once for escape.
{
	if(IsValidClient(client))
	{	
		if(EscapeMode)
		{
			SetEntityHealth(client, 150);
		}
		else
		{
			SetEntityHealth(client, 50);
		}
	}
}

//Set hp spam after normal revive


public void NPC_SpawnNextRequestFrame(bool force)
{
	NPC_SpawnNext(false, false, false);
}

public void TF2_OnWaitingForPlayersEnd()
{
	Queue_WaitingForPlayersEnd();
}