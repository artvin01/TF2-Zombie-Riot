#pragma semicolon 1
#pragma newdecls required

#define ITEM_CASH	"Credits"
#define ITEM_XP		"XP"
#define ITEM_MASTERY	"Form Mastery"
#define MIN_FADE_DISTANCE 3000.0
#define MAX_FADE_DISTANCE 3700.0

enum
{
	WEAPON_BIGFRYINGPAN = 1,
	WEAPON_LANTEAN = 2,


	//any that are shared, just stick it here.
	WEAPON_KRITZKRIEG = 999,
}

int BaseStrength;
int BasePrecision;
int BaseArtifice;
int BaseEndurance;
int BaseStructure;
int BaseIntelligence;
int BaseCapacity;
int BaseLuck;
int BaseAgility;
int BaseUpgradeCost;
int BaseUpgradeScale;
int BaseUpdateStats = 1;
int BaseMaxLevel;
ConVar mp_disable_respawn_times;
ConVar CvarSkyName;

bool DisabledDownloads[MAXPLAYERS];

int RaceIndex[MAXPLAYERS];
int i_TransformationSelected[MAXPLAYERS];
int i_TransformationLevel[MAXPLAYERS];
float f_TransformationDelay[MAXPLAYERS]; 	//if he takess too long and cancels it, itll just drop the progress.

char StoreWeapon[MAXENTITIES][48];
int i_TagColor[MAXPLAYERS][4];
char c_TagName[MAXPLAYERS][64];
int b_BrushToOwner[MAXENTITIES];
int b_OwnerToBrush[MAXENTITIES];
float Animal_Happy[MAXPLAYERS][10][3];
float f3_PositionArrival[MAXENTITIES][3];
int hFromSpawnerIndex[MAXENTITIES] = {-1, ...};

int b_PlayerIsPVP[MAXENTITIES];
int i_CurrentStamina[MAXPLAYERS];
int i_MaxStamina[MAXPLAYERS];
float f_ClientTargetedByNpc[MAXPLAYERS];
float f_MasteryTextHint[MAXPLAYERS];

bool b_NpcIsInADungeon[MAXENTITIES];
int i_NpcFightOwner[MAXENTITIES];
float f_NpcFightTime[MAXENTITIES];
float f_SingerBuffedFor[MAXENTITIES];

int BackpackBonus[MAXENTITIES];
int Strength[MAXENTITIES];
int Precision[MAXENTITIES];
int Artifice[MAXENTITIES];
int Endurance[MAXENTITIES];
int Structure[MAXENTITIES];
int Intelligence[MAXENTITIES];
int Capacity[MAXENTITIES];
int Agility[MAXENTITIES];
int Luck[MAXENTITIES];
int ArmorCorrosion[MAXENTITIES];

float f_ClientSinceLastHitNpc[MAXENTITIES][MAXPLAYERS];
float f_FlatDamagePiercing[MAXENTITIES];

//CC CONTRACT DIFFICULTIES!
bool b_DungeonContracts_LongerCooldown[MAXPLAYERS];
bool b_DungeonContracts_SlowerAttackspeed[MAXPLAYERS];
bool b_DungeonContracts_SlowerMovespeed[MAXPLAYERS];
//bool b_DungeonContracts_BleedOnHit[MAXPLAYERS]; Global inside core.sp
int i_NpcIsUnderSpawnProtectionInfluence[MAXENTITIES];

static char MapConfig[64];

Cookie HudSettings_Cookies;
Cookie HudSettingsExtra_Cookies;

#include "npc.sp"	// Global NPC List

#include "races.sp"
#include "actor.sp"
#include "cooking.sp"
#include "crafting.sp"
#include "dungeon.sp"
#include "editor.sp"
#include "fishing.sp"
#include "games.sp"
#include "garden.sp"
#include "mining.sp"
#include "music.sp"
#include "party.sp"
#include "plots.sp"
#include "quests.sp"
#include "saves.sp"
#include "spawns.sp"
#include "stats.sp"
#include "store.sp"
#include "textstore.sp"
#include "tinker.sp"
#include "traffic.sp"
#include "worldtext.sp"
#include "zones.sp"
#include "custom/wand/weapon_default_wand.sp"
#include "custom/wand/weapon_lantean_wand.sp"
#include "custom/weapon_samurai_sword.sp"
#include "custom/weapon_brick.sp"
#include "../zombie_riot/custom/homing_projectile_logic.sp"
#include "custom/accesorry_mudrock_shield.sp"
#include "custom/weapon_passanger.sp"
#include "custom/passive_true_strength.sp"
#include "custom/melee_war_cry.sp"
#include "custom/passive_chrono_shift.sp"
#include "custom/weapon_heal_aoe.sp"
#include "custom/passive_golden_agility.sp"
#include "custom/weapon_bubble_proc.sp"
#include "custom/emblem_doublejump.sp"
#include "custom/weapon_boom_stick.sp"
#include "custom/skill_big_bang.sp"
#include "custom/octane_kick_melee.sp"
#include "custom/ranged_back_rocket.sp"
#include "custom/mage_skill_oblitiration_shot.sp"

/*
#include "custom/wand/weapon_default_wand.sp"
#include "custom/wand/weapon_fire_wand.sp"
#include "custom/wand/weapon_lightning_wand.sp"
#include "custom/wand/weapon_icicles.sp"
#include "custom/potion_healing_effects.sp"
#include "custom/ground_beserkhealtharmor.sp"	
#include "custom/ranged_sentrythrow.sp"
*/
#include "custom/ground_pound_melee.sp"
#include "custom/ranged_mortar_strike.sp"
#include "custom/weapon_wand_fire_ball.sp"
#include "../shared/custom/joke_medigun_mod_drain_health.sp"
#include "custom/weapon_short_teleport.sp"
#include "custom/ground_aircutter.sp"	
#include "custom/ranged_quick_reflex.sp"
/*
#include "custom/wand/weapon_arts_wand.sp"
#include "custom/weapon_semi_auto.sp"
#include "custom/wand/weapon_sword_wand.sp"
*/
#include "custom/weapon_coin_flip.sp"
#include "custom/transform_expidonsan.sp"
#include "custom/transform_iberian.sp"
#include "custom/transform_merc_human.sp"
#include "custom/transform_ruianian.sp"
#include "custom/transform_seaborn.sp"

void RPG_PluginStart()
{
	HudSettings_Cookies = new Cookie("zr_hudsetting", "hud settings", CookieAccess_Protected);
	HudSettingsExtra_Cookies = new Cookie("zr_hudsettingextra", "hud settings Extra", CookieAccess_Protected);
	RegAdminCmd("sm_give_xp", Command_GiveXp, ADMFLAG_ROOT, "Give XP to the Person");
	RegAdminCmd("sm_enable_pvp", Command_EnablePVP, ADMFLAG_ROOT, "Enable PVP");
	RegAdminCmd("sm_resetstats_grant", Command_GiveReset, ADMFLAG_ROOT, "Resets their char and sets Skillpoints (set to 0 to just reset them)");
	
	LoadTranslations("rpgfortress.phrases");

	Dungeon_PluginStart();
	Editor_PluginStart();
	Fishing_PluginStart();
	Games_PluginStart();
	Store_Reset();
	Party_PluginStart();
	Saves_PluginStart();
	Spawns_PluginStart();
	Stats_PluginStart();
	TextStore_PluginStart();
	Traffic_PluginStart();
	Zones_PluginStart();
	Quests_PluginStart();

	CountPlayersOnRed();
	Medigun_PluginStart();
	RpgPluginStart_Store();
	RequestFrame(CheckIfAloneOnServer);

	mp_disable_respawn_times = FindConVar("mp_disable_respawn_times");
	mp_disable_respawn_times.Flags &= ~(FCVAR_NOTIFY|FCVAR_REPLICATED);
	CvarSkyName = FindConVar("sv_skyname");
}

void RPG_PluginEnd()
{
	char buffer[64];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			/*
			if(StrEqual(buffer, "zr_base_npc"))
			{
				NPC_Despawn(i);
				continue;
			}
			else */
			if(!StrContains(buffer, "prop_dynamic") || !StrContains(buffer, "point_worldtext") || !StrContains(buffer, "info_particle_system"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrEqual(buffer, "rpg_fortress"))
					continue;
			}
			else if(!StrContains(buffer, "prop_physics"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrContains(buffer, "rpg_item"))
					continue;
			}
			else
			{
				continue;
			}

			RemoveEntity(i);
		}
	}

	Party_PluginEnd();
	Saves_PluginEnd();
}

void RPG_MapStart()
{
	Zero2(f3_SpawnPosition);
	Zero(f_ClientTargetedByNpc);
	Fishing_OnMapStart();
#if defined ZR
	Medigun_PersonOnMapStart();
#endif
	Zones_MapStart();

	CreateTimer(2.0, CheckClientConvars, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.5, GlobalTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	Wand_Map_Precache();
	
	Transform_Expidonsa_MapStart();
	Transform_Iberian_MapStart();
	Transform_MercHuman_MapStart();
	Transform_Ruianian_MapStart();
	Transform_Seaborn_MapStart();

	SamuraiSword_Map_Precache();
	GroundSlam_Map_Precache();
	Mortar_MapStart();
	Wand_FireBall_Map_Precache();
	BrickWeapon_Map_Precache();
	Abiltity_TrueStrength_PluginStart();
	AirCutter_Map_Precache();
	QuickReflex_MapStart();
	Wand_Short_Teleport_Map_Precache();
	Passanger_Wand_MapStart();
	PrecachePlayerGiveGiveResponseVoice();
	WarCryOnMapStart();
	Wand_HolyLight_Map_Precache();
	Abiltity_GoldenAgility_MapStart();
	Wand_BubbleProctection_Map_Precache();
	BoomStick_MapPrecache();
	BigBang_Map_Precache();
	Abiltity_Coin_Flip_Map_Change();
	Abiltity_TrueStrength_Shield_Shield_MapStart();
	OctaneKick_Map_Precache();
	BackRockets_MapStart();
	Mage_Oblitiration_Shot_Map_Precache();
	Weapon_lantean_Wand_ClearAll();
	Weapon_lantean_Wand_Map_Precache();
	PrecacheSound("weapons/physcannon/physcannon_drop.wav");
	MapStartPlotMisc();

	/*
	HealingPotion_Map_Start();
	Wand_Fire_Map_Precache();
	Wand_Lightning_Map_Precache();
	Wand_Arts_MapStart();

	Wand_IcicleShard_Map_Precache();
	SentryThrow_MapStart();
	BeserkerRageGain_Map_Precache();
	*/

	
}

void RPG_MapEnd()
{
	Spawns_MapEnd();
	MapConfig[0] = 0;
}

void RPG_SetupMapSpecific(const char[] mapname)
{
	bool found;
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG);
	DirectoryListing dir = OpenDirectory(buffer);
	if(dir != INVALID_HANDLE)
	{
		FileType file;
		while(dir.GetNext(MapConfig, sizeof(MapConfig), file))
		{
			if(file != FileType_Directory)
				continue;
			
			if(StrContains(mapname, MapConfig, false) == -1)
				continue;
			
			found = true;
			break;
		}
		delete dir;
	}

	if(!found)
		SetFailState("Can not find folder in '%s' for map '%s'", buffer, mapname);
	
	if(LibraryExists("LoadSoundscript"))
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG ... "/%s/soundscript.txt", MapConfig);
		LoadSoundScript(buffer);
	}
}
void RPG_ConfigSetup()
{
	Zones_ConfigSetup();
	Actor_ConfigSetup();
	Cooking_ConfigSetup();
	Crafting_ConfigSetup();
	Dungeon_ConfigSetup();
	Fishing_ConfigSetup();
	Games_ConfigSetup();
	Garden_ConfigSetup();
	Mining_ConfigSetup();
	Quests_ConfigSetup();
	Plots_ConfigSetup();
	Races_ConfigSetup();
	Saves_ConfigSetup();
	Spawns_ConfigSetup();
	Tinker_ConfigSetup();
	Worldtext_ConfigSetup();
	
	TextStore_ConfigSetup();
}

bool RPG_BuildPath(char[] buffer, int length, const char[] name)
{
	BuildPath(Path_SM, buffer, length, CONFIG ... "/%s/%s.cfg", MapConfig, name);
	return view_as<bool>(MapConfig[0]);
}

void RPG_PutInServer(int client)
{
	CountPlayersOnRed();
	AdjustBotCount();

	int userid = GetClientUserId(client);
	QueryClientConVar(client, "cl_allowdownload", OnQueryFinished, userid);
	QueryClientConVar(client, "cl_downloadfilter", OnQueryFinished, userid);

	mp_disable_respawn_times.ReplicateToClient(client, "1");
}

public void OnQueryFinished(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int userid)
{
	if(result == ConVarQuery_Okay && GetClientOfUserId(userid) == client)
	{
		if(StrEqual(cvarName, "cl_allowdownload"))
		{
			if(!StringToInt(cvarValue))
				DisabledDownloads[client] = true;
		}
		else if(StrEqual(cvarName, "cl_downloadfilter"))
		{
			if(StrContains("all", cvarValue) == -1)
				DisabledDownloads[client] = true;
		}

		mp_disable_respawn_times.ReplicateToClient(client, "1");
	}
}

void RPG_ClientCookiesCached(int client)
{
	HudSettings_ClientCookiesCached(client);
	ThirdPerson_OnClientCookiesCached(client);
}

void RPG_ClientDisconnect(int client)
{
	for(int loop1; loop1 < sizeof(Animal_Happy[]); loop1++)
	{
		for(int loop2; loop2 < sizeof(Animal_Happy[][]); loop2++)
		{
			Animal_Happy[client][loop1][loop2] = 0.0;
		}
	}

	DisabledDownloads[client] = false;
	b_PlayerIsPVP[client] = false;
	f_MasteryTextHint[client] = 0.0;

	if(AreClientCookiesCached(client))
	{
		char buffer[128];		

		FormatEx(buffer, sizeof(buffer), "%.3f;%.3f;%.3f;%.3f;%.3f;%.3f;%.3f;%.3f", f_ArmorHudOffsetX[client], f_ArmorHudOffsetY[client], f_HurtHudOffsetX[client], f_HurtHudOffsetY[client], f_WeaponHudOffsetX[client], f_WeaponHudOffsetY[client], f_NotifHudOffsetX[client], f_NotifHudOffsetY[client]);
		HudSettings_Cookies.Set(client, buffer);

		FormatEx(buffer, sizeof(buffer), "%b;%b;%b", b_HudScreenShake[client], b_HudLowHealthShake_UNSUED[client], b_HudHitMarker[client]);
		HudSettingsExtra_Cookies.Set(client, buffer);
	}

	UpdateLevelAbovePlayerText(client, true);
	Dungeon_ClientDisconnect(client);
	Fishing_ClientDisconnect(client);
	Music_ClientDisconnect(client);
	Party_ClientDisconnect(client);
	Saves_ClientDisconnect(client);
	Stats_ClientDisconnect(client);
	TextStore_ClientDisconnect(client);
	TrueStrengthShieldDisconnect(client);
	TrueStrengthUnequip(client);
	ChronoShiftUnequipOrDisconnect(client);
//	BeserkHealthArmorDisconnect(client);
	f_TransformationDelay[client] = 0.0;
	RequestFrame(CheckIfAloneOnServer);
}

void RPG_ClientDisconnect_Post()
{
	CountPlayersOnRed();
}

void RPG_EntityCreated(int entity, const char[] classname)
{
	Level[entity] = 0;
	b_NpcIsInADungeon[entity] = false;
	i_NpcFightOwner[entity] = false;
	f_SingerBuffedFor[entity] = 0.0;
	StoreWeapon[entity][0] = 0;
	hFromSpawnerIndex[entity] = -1;
	Dungeon_ResetEntity(entity);
	Plots_EntityCreated(entity);
	Stats_ClearCustomStats(entity);
	Zones_EntityCreated(entity, classname);
	OnEntityCreatedMeleeWarcry(entity);
}

void RPG_PlayerRunCmdPost(int client, int buttons)
{
	TextStore_PlayerRunCmd(client);
	Editor_PlayerRunCmd(client, buttons);
	Fishing_PlayerRunCmd(client);
	Garden_PlayerRunCmd(client);
	Music_PlayerRunCmd(client);
}

void RPG_UpdateHud(int client)
{
	Stats_UpdateHud(client);
}

public void CheckAlivePlayersforward(int killed)
{
	CheckAlivePlayers(killed);
}

void CheckAlivePlayers(int killed = 0)
{
	Dungeon_CheckAlivePlayers(killed);
}
public Action GlobalTimer(Handle timer)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Spawns_CheckBadClient(client);
		}
	}
	return Plugin_Continue;
}

public Action CheckClientConvars(Handle timer)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && GetClientTeam(client)==3)
			{
				if(IsFakeClient(client))
				{
					KickClient(client);	
				}
				else
				{
					ClientCommand(client, "retry");
				}
			}
			else if(!IsFakeClient(client))
			{
				QueryClientConVar(client, "snd_musicvolume", ConVarCallback); //snd_musicvolume
			}
			Spawns_CheckBadClient(client);
		}
	}
	return Plugin_Continue;
}

static void HudSettings_ClientCookiesCached(int client)
{
	char buffer[128];
	HudSettings_Cookies.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		// Cookie has stuff, get values
		float buffers[8];
		ExplodeStringFloat(buffer, ";", buffers, sizeof(buffers));

		f_ArmorHudOffsetX[client] = buffers[0];
		f_ArmorHudOffsetY[client] = buffers[1];
		f_HurtHudOffsetX[client] = buffers[2];
		f_HurtHudOffsetY[client] = buffers[3];
		f_WeaponHudOffsetX[client] = buffers[4];
		f_WeaponHudOffsetY[client] = buffers[5];
		f_NotifHudOffsetX[client] = buffers[6];
		f_NotifHudOffsetY[client] = buffers[7];
	}
	else
	{
		// Cookie empty, get our own
		f_ArmorHudOffsetX[client] = -0.085;
		f_ArmorHudOffsetY[client] = 0.0;
		f_HurtHudOffsetX[client] = 0.0;
		f_HurtHudOffsetY[client] = 0.0;
		f_WeaponHudOffsetX[client] = 0.0;
		f_WeaponHudOffsetY[client] = 0.0;
		f_NotifHudOffsetX[client] = 0.0;
		f_NotifHudOffsetY[client] = 0.0;
	}
	HudSettingsExtra_Cookies.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		// Cookie has stuff, get values
		int buffers[3];
		ExplodeStringInt(buffer, ";", buffers, sizeof(buffers));
		b_HudScreenShake[client] = view_as<bool>(buffers[0]);
		b_HudLowHealthShake_UNSUED[client] = view_as<bool>(buffers[1]);
		b_HudHitMarker[client] = view_as<bool>(buffers[2]);
	}
	else
	{
		// Cookie empty, get our own
		b_HudScreenShake[client] = true;
		b_HudLowHealthShake_UNSUED[client] = true;
		b_HudHitMarker[client] = true;
	}
}

public Action Command_EnablePVP(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_enable_pvp <target>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[12];
	GetCmdArg(2, buf, sizeof(buf));

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		if(b_PlayerIsPVP[targets[target]])
		{
			PrintToChat(targets[target], "disabled PVP on %N!", targets[target]);
			PrintToChat(client, "disabled PVP on %N!", targets[target]);
			b_PlayerIsPVP[targets[target]] = false;
		}
		else
		{
			PrintToChat(targets[target], "Enabled PVP on %N!", targets[target]);
			PrintToChat(client, "Enabled PVP on %N!", targets[target]);
			b_PlayerIsPVP[targets[target]] = true;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_GiveXp(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_xp <target> <cash>");
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
			PrintToChat(targets[target], "You got %i XP from the admin %N!", money, client);
			int xp = money;
			Stats_GiveXP(targets[target], xp);
		}
		else
		{
			PrintToChat(targets[target], "You lost %i XP due to the admin %N!", money, client);
			int xp = money;
			Stats_GiveXP(targets[target], xp);
		}
	}
	
	return Plugin_Handled;
}
public Action Command_GiveReset(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_resetstats_grant <target> <skillpoints> (0 to use default)");
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
			PrintToChat(targets[target], "An admin reset your character and set your skillpoints.", money);
			Stats_ReskillEverything(targets[target], money);
		}
		else
		{
			PrintToChat(targets[target], "An admin reset your character, you got awarded back all your skillpoints.", money);
			Stats_ReskillEverything(targets[target], money);
		}
	}
	
	return Plugin_Handled;
}


void WeaponAttackResourceReduction(int client, int weapon)
{
	float ResourceCostAttack = Attributes_Get(weapon, 4003, 0.0);
	float StaminaCostAttack = Attributes_Get(weapon, 4004, 0.0);
	int StatsForCalcMulti;
	int StatsForCalcMultiAdd;
	if(ResourceCostAttack != 0.0)
	{
		if(i_IsWandWeapon[weapon])
		{
			Stats_Artifice(client, StatsForCalcMultiAdd);
			StatsForCalcMulti += StatsForCalcMultiAdd;
			ResourceCostAttack *= float(StatsForCalcMulti);
		}
		else
		{
			Stats_Precision(client, StatsForCalcMultiAdd);
			StatsForCalcMulti += StatsForCalcMultiAdd;
			ResourceCostAttack *= float(StatsForCalcMulti);
		}
		ResourceCostAttack *= 0.5;
		RPGCore_ResourceReduction(client, RoundToNearest(ResourceCostAttack));
	}
	StatsForCalcMulti = 0;
	if(StaminaCostAttack != 0.0)
	{
		Stats_Strength(client, StatsForCalcMultiAdd);
		StatsForCalcMulti += StatsForCalcMultiAdd;
		StaminaCostAttack *= float(StatsForCalcMulti);
		StaminaCostAttack *= 0.5;
		RPGCore_StaminaReduction(weapon, client, RoundToNearest(StaminaCostAttack));
	}
}


void RPGCore_StaminaReduction(int weapon, int client, int amount)
{
	i_CurrentStamina[client] -= amount;
	if(i_CurrentStamina[client] < 0)
	{
		i_CurrentStamina[client] = 0;
		//Give them a huge attack delay.
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(EntIndexToEntRef(client));
		RequestFrame(RPGCore_StaminaReduction_Puishment, pack);
	}
}

													
void RPGCore_StaminaReduction_Puishment(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && IsValidClient(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 3.0);
		SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 3.0);
	}
	delete pack;
}

void RPGCore_StaminaAddition(int client, int amount)
{
	if(amount < 1)
		amount = 1;

	i_CurrentStamina[client] += amount;
	if(i_CurrentStamina[client] > i_MaxStamina[client])
	{
		i_CurrentStamina[client] = i_MaxStamina[client];
	}
}

void RPGCore_ResourceReduction(int client, int amount, bool isformdrain = false)
{
	static Race race;	
	static Form form;
	Races_GetClientInfo(client, race, form);

	float multi = 1.0;
	if(!isformdrain)
		multi = form.GetFloatStat(client, Form::EnergyMulti, Stats_GetFormMastery(client, form.Name));
	
	Current_Mana[client] -= RoundToNearest(float(amount) * (1.0 / multi));
	if(Current_Mana[client] <= 0)
	{
		Current_Mana[client] = 0;
		bool CancelDeform = false;
		if(form.Func_FormEnergyRunOutLogic != INVALID_FUNCTION && form.Func_FormEnergyRunOutLogic != view_as<Function>(0))
		{
			Call_StartFunction(null, form.Func_FormEnergyRunOutLogic);
			Call_PushCell(client);
			Call_Finish(CancelDeform);
		}
		if(CancelDeform)
			return;
		//De-Transform logic.
		De_TransformClient(client);
		TF2_StunPlayer(client, 3.0, 0.75, TF_STUNFLAGS_LOSERSTATE|TF_STUNFLAG_SLOWDOWN);
		f_TransformationDelay[client] = GetGameTime() + 6.0;
		//less punishment.
		int i, entity;
		while(TF2_GetItem(client, entity, i))
		{
			ApplyTempAttrib(entity, 6, 4.0, 5.0);
			ApplyTempAttrib(entity, 2, 0.25, 5.0);
			ApplyTempAttrib(entity, 410, 0.25, 5.0);
		}
	}
}


void RPGCore_ResourceAddition(int client, int amount)
{
	Current_Mana[client] += amount;
	if(Current_Mana[client] > RoundToCeil(max_mana[client]))
	{
		Current_Mana[client] = RoundToCeil(max_mana[client]);
	}
}


bool RPGCore_PlayerCanPVP(int attacker, int victim)
{
	if(attacker > MaxClients)
	{
		attacker = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
	}
	if(attacker > MaxClients)
		return false;

	if(attacker < 0)
		return false;

	if(attacker == victim)
		return false;
		
	if(b_PlayerIsPVP[attacker] && b_PlayerIsPVP[victim])
	{
		return true;
	}
	
	if(Party_FriendlyFire(attacker, victim))
		return true;
	
	return false;
}


void RPGCore_AddClientToHurtList(int entity, int client)
{
	if(client <= MaxClients)
		f_ClientSinceLastHitNpc[entity][client] = GetGameTime() + 10.0;
}

void RPGCore_ResetHurtList(int entity)
{
	for(int client = 0; client <= MaxClients; client++)
	{
		f_ClientSinceLastHitNpc[entity][client] = 0.0;
	}
}

bool RPGCore_ClientAllowedToTargetNpc(int victim, int attacker)
{
	//if a player is being attacked, always allow.
	if(victim <= MaxClients)
		return true;

	//if the attacker is an entity, always allow.
	if(attacker > MaxClients)
		return true;
	
	//do not include party leader here.


	bool EnemyWasAttackedBefore;
	int PartyLeader = Party_GetPartyLeader(attacker);
	if(PartyLeader)
	{
		//They are in a party, anyone in another party has attacked the enemy first.
		for(int client; client <= MaxClients; client++)
		{
			if(attacker != client && f_ClientSinceLastHitNpc[victim][client] > GetGameTime())
			{
				if(Party_GetPartyLeader(client) != PartyLeader)
				{
					EnemyWasAttackedBefore = true;
					break;
				}
			}
		}
		if(EnemyWasAttackedBefore)
		{
			return false;
		}
	}
	else
	{
		//they are not in a party, anyone else attacked the enemy first.
		for(int client; client <= MaxClients; client++)
		{
			if(attacker != client && f_ClientSinceLastHitNpc[victim][client] > GetGameTime())
			{
				EnemyWasAttackedBefore = true;
				break;
			}
		}
		if(EnemyWasAttackedBefore)
		{
			return false;
		}
	}
	//if someone attacked them while in a party, then allow.
	if(!EnemyWasAttackedBefore && i_npcspawnprotection[victim] != NPC_SPAWNPROT_OFF && i_NpcIsUnderSpawnProtectionInfluence[victim] > 0)
	{
		if(!RPGSpawns_GivePrioLevel(Level[victim], Level[attacker]))
		{
			return false;
		}
	}
	//As of now, all checks passed.
	return true;
}
/*
	int client;

	while(RpgCore_CountClientsWorthyForKillCredit(entity, client) <= MaxClients)
	{

	}
*/


bool RpgCore_CountClientsWorthyForKillCredit(int entity, int &client)
{
	// Start by adding 1; limit; keep adding 1
	for(client++; client <= MaxClients; client++)
	{
		if(!IsValidClient(client))
			continue;

		if(f_ClientSinceLastHitNpc[entity][client] < GetGameTime())
			continue;
		
		//Code for if its in party here:

		//no distance check.
		//no level check as of now.
		return true;
	}

	return false;
}

void RpgCore_OnKillGiveMastery(int client, int MaxHealth)
{
	if(Stats_GetCurrentFormMasteryMax(client))
		return;

	float CombinedDamagesPre;
	float CombinedDamages;
	int BaseDamage;
	float Multiplier;
	float Multiplier2;
	int bonus;
	Stats_Strength(client, BaseDamage, bonus, Multiplier, Multiplier2);
	CombinedDamagesPre = float(BaseDamage) * Multiplier * Multiplier2;
	if(CombinedDamagesPre > CombinedDamages)
		CombinedDamages = CombinedDamagesPre;

	Stats_Precision(client, BaseDamage, bonus, Multiplier, Multiplier2);
	CombinedDamagesPre = float(BaseDamage) * Multiplier * Multiplier2;
	if(CombinedDamagesPre > CombinedDamages)
		CombinedDamages = CombinedDamagesPre;

	Stats_Artifice(client, BaseDamage, bonus, Multiplier, Multiplier2);
	CombinedDamagesPre = float(BaseDamage) * Multiplier * Multiplier2;
	if(CombinedDamagesPre > CombinedDamages)
		CombinedDamages = CombinedDamagesPre;

	float f_Stats_GetCurrentFormMastery;
	f_Stats_GetCurrentFormMastery = RPGStats_FlatDamageSetStats(client, 0, RoundToNearest(CombinedDamages));

	//only a 5% chance!
	int GrantGuranteed[MAXPLAYERS];

	if(float(MaxHealth) > f_Stats_GetCurrentFormMastery * 1.5)
	{
		if(GrantGuranteed[client] < 10 && GetRandomFloat(0.0, 1.0) >= 0.2)
		{	
			GrantGuranteed[client] += 2;
			return;
		}
	}
	else if(float(MaxHealth) > f_Stats_GetCurrentFormMastery * 0.75)
	{
		if(GrantGuranteed[client] < 10 && GetRandomFloat(0.0, 1.0) >= 0.1)
		{	
			GrantGuranteed[client] += 1;
			return;
		}
	}
	else
	{
		if(f_MasteryTextHint[client] < GetGameTime())
			SPrintToChat(client, "This enemy cannot give you mastery.");

		f_MasteryTextHint[client] = GetGameTime() + 5.0;
		return;
	}
//	bool WasGuranteed = false;
	if(GrantGuranteed[client] >= 10)
	{
//		WasGuranteed = true;
		GrantGuranteed[client] = 0;
	}
	//Get the highest statt you can find.

	//todo: Make it also work if your level is low enough!
	if(float(MaxHealth) > f_Stats_GetCurrentFormMastery * 0.75)
	{
		float MasteryCurrent = Stats_GetCurrentFormMastery(client);
		float MasteryAdd;
		if(GetRandomFloat(0.0, 1.0) <= 0.1)
		{
			MasteryAdd += GetRandomFloat(0.2, 0.3);
		}
		MasteryAdd += GetRandomFloat(0.11, 0.13);
		MasteryAdd *= 2.0;
		int totalInt = Stats_Intelligence(client);
		if(totalInt >= 6000)
		{
			MasteryAdd *= 1.6875;
			SPrintToChat(client, "Your Extreme intellect boosts you, your current form obtained %0.2f (1.6875x) Mastery points.",MasteryAdd);
		}
		else if(totalInt >= 1000)
		{
			MasteryAdd *= 1.25;
			SPrintToChat(client, "Your intellect boosts you, your current form obtained %0.2f (1.25x) Mastery points.",MasteryAdd);
		}
		else
			SPrintToChat(client, "Your current form obtained %0.2f Mastery points.",MasteryAdd);

		MasteryCurrent += MasteryAdd;
		Stats_SetCurrentFormMastery(client, MasteryCurrent);
		//enemy was able to survive atleast 1 hit and abit more, allow them to use form mastery, it also counts the current form!.
	}
}

void RPGCore_SetFlatDamagePiercing(int entity, float value)
{
	f_FlatDamagePiercing[entity] = value;
}

void RPGCore_ClientTargetedByNpc(int client, float time)
{
	f_ClientTargetedByNpc[client] = GetGameTime() + time;
}

float RPGCore_ClientTargetedByNpcReturn(int client)
{
	return f_ClientTargetedByNpc[client];
}

void RPGCore_CopyStatsOver(int npc_owner, int npc_target)
{
	fl_Extra_Damage[npc_target] = fl_Extra_Damage[npc_owner];
	fl_Extra_Damage[npc_target] = fl_Extra_Damage[npc_owner];
	fl_Extra_Speed[npc_target] = fl_Extra_Speed[npc_owner];
	Endurance[npc_target] = Endurance[npc_owner];
}


bool RPGCore_ClientCanTransform(int client)
{
	if(f_TransformationDelay[client] > GetGameTime())
		return false;

	if(!IsValidClient(client))
		return false;

	if(!IsPlayerAlive(client))
		return false;

	static Race race;
	//static Form form;
	if(Races_GetRaceByIndex(RaceIndex[client], race))
	{
		if(i_TransformationSelected[client] > 0 && i_TransformationSelected[client] <= race.Forms.Length)
		{
			//race.Forms.GetArray(i_TransformationSelected[client] - 1, form);
		}
		else
		{
			return false;
			//form.Default();
		}	
	}
	return true;
}

//This is needed for certain abilities actions.
void RPGCore_CancelMovementAbilities(int client)
{
	AircutterCancelAbility(client);
}

void RPG_FlatRes(int victim, int attacker, int weapon, float &damage)
{
	float FlatDamageResistance = RPGStats_FlatDamageResistance(victim);
	if(f_FlatDamagePiercing[attacker] != 1.0)
	{
		FlatDamageResistance *= f_FlatDamagePiercing[attacker];
	}
	if(IsValidEntity(weapon))
	{
		float DamagePiercing = Attributes_Get(weapon, 4005, 1.0);
		FlatDamageResistance *= DamagePiercing;
	}
	float damageMinimum = (damage * 0.05);
	damage -= FlatDamageResistance;
	if(damage < damageMinimum)
	{
		damage = damageMinimum;
	}
}
public bool Dungeon_Mode()
{
	return false;
}
int Dungeon_GetEntityZone(int entity, bool forceReset = false)
{
	return 0;
}
public bool Const2_IgnoreBuilding_FindTraget(int entity)
{
	return false;
}
