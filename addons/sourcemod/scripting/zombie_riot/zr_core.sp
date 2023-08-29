#pragma semicolon 1
#pragma newdecls required

//#define UseDownloadTable

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9
#define STARTER_WEAPON_LEVEL	5

//#define ZR_ApplyKillEffects NPC_DeadEffects
#define ZR_GetWaveCount Rogue_GetRoundScale

public const int AmmoData[][] =
{
	// Price, Ammo
	{ 0, 0 },			//N/A
	{ 0, 0 },			//Primary
	{ 0, 4222 },		//Secondary
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
	"Recycle Poire"
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
	"Recycle Poire Recieved"
};

enum
{
	WEAPON_ARK = 1,
	WEAPON_FUSION = 2,
	WEAPON_BOUNCING = 3,
	WEAPON_MAIMMOAB = 4,
	WEAPON_CRIPPLEMOAB = 5,
	WEAPON_IRENE = 6,
	WEAPON_7 = 7,
	WEAPON_8 = 8,
	WEAPON_9 = 9,
	WEAPON_10 = 10,
	WEAPON_OCEAN = 11,
	WEAPON_NEARL = 12,
	WEAPON_LAPPLAND = 13,
	WEAPON_LANTEAN = 14,
	WEAPON_SPECTER = 15,
	WEAPON_RIOT_SHIELD = 16,
	WEAPON_YAMATO = 17,
	WEAPON_BATTILONS = 18,
	WEAPON_SAGA = 19,
	WEAPON_BEAM_PAP = 20,
	WEAPON_MLYNAR = 21,
	WEAPON_GLADIIA = 22,
	WEAPON_SPIKELAYER = 23,
	WEAPON_BLEMISHINE = 24,
	WEAPON_FANTASY_BLADE = 25,
	WEAPON_BOOMSTICK = 26,
	WEAPON_TEUTON_DEAD = 27,
	WEAPON_MLYNAR_PAP = 28,
	WEAPON_VAMPKNIVES_1 = 29,
	WEAPON_VAMPKNIVES_2 = 30,
	WEAPON_VAMPKNIVES_2_CLEAVER = 31,
	WEAPON_VAMPKNIVES_3 = 32,
	WEAPON_VAMPKNIVES_3_CLEAVER = 33,
	WEAPON_VAMPKNIVES_4 = 34,
	WEAPON_VAMPKNIVES_4_CLEAVER = 35,
	WEAPON_SPEEDFISTS = 36,
	WEAPON_ANCIENT_BANNER = 37,
	WEAPON_QUINCY_BOW = 38,
	WEAPON_JUDGE = 39,
	WEAPON_JUDGE_PAP = 40,
	WEAPON_BOARD = 41,
	WEAPON_GERMAN = 42
}

ArrayList SpawnerList;

//int Bob_To_Player[MAXENTITIES];
bool Bob_Exists = false;
int GrigoriMaxSells = 3;
int Bob_Exists_Index = -1;
int CurrentPlayers;
ConVar zr_voteconfig;
ConVar zr_tagblacklist;
ConVar zr_tagwhitelist;
ConVar zr_minibossconfig;
ConVar zr_ignoremapconfig;
ConVar zr_smallmapbalancemulti;
ConVar CvarNoRoundStart;
ConVar CvarInfiniteCash;
ConVar CvarNoSpecialZombieSpawn;
ConVar zr_spawnprotectiontime;
ConVar zr_viewshakeonlowhealth;
ConVar zr_disablerandomvillagerspawn;
ConVar zr_waitingtime;
//ConVar CvarEnablePrivatePlugins;
int CurrentGame = -1;
bool b_GameOnGoing = true;
//bool b_StoreGotReset = false;
int CurrentCash;
bool LastMann;
int LimitNpcs;

//bool RaidMode; 							//Is this raidmode?
float RaidModeScaling = 0.5;			//what multiplier to use for the raidboss itself?
float RaidModeTime = 0.0;
float f_TimerTickCooldownRaid = 0.0;
float f_TimerTickCooldownShop = 0.0;
float f_FreeplayDamageExtra = 1.0;
int SalesmanAlive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?

int PlayersAliveScaling;
int PlayersInGame;
bool ZombieMusicPlayed;
int GlobalIntencity;
bool b_HasBeenHereSinceStartOfWave[MAXTF2PLAYERS];
Cookie CookieScrap;
Cookie CookieXP;
ArrayList Loadouts[MAXTF2PLAYERS];

Handle g_hSDKMakeCarriedObjectDispenser;
Handle g_hSDKMakeCarriedObjectSentry;
float f_RingDelayGift[MAXENTITIES];

//custom wave music.
char char_MusicString1[256];
int i_MusicLength1;
bool b_MusicCustom1;
char char_MusicString2[256];
int i_MusicLength2;
bool b_MusicCustom2;
char char_RaidMusicSpecial1[256];
int i_RaidMusicLength1;
bool b_RaidMusicCustom1;
//custom wave music.
float f_DelaySpawnsForVariousReasons;
int CurrentRound;
int CurrentWave = -1;
int StartCash;
float RoundStartTime;
char WhatDifficultySetting[21];
float healing_cooldown[MAXTF2PLAYERS];
float Damage_dealt_in_total[MAXTF2PLAYERS];
int i_Damage_dealt_in_total[MAXTF2PLAYERS];
float f_TimeAfterSpawn[MAXTF2PLAYERS];
float WoodAmount[MAXTF2PLAYERS];
float FoodAmount[MAXTF2PLAYERS];
float GoldAmount[MAXTF2PLAYERS];
int SupplyRate[MAXTF2PLAYERS];

#define SF2_PLAYER_VIEWBOB_TIMER 10.0
#define SF2_PLAYER_VIEWBOB_SCALE_X 0.05
#define SF2_PLAYER_VIEWBOB_SCALE_Y 0.0
#define SF2_PLAYER_VIEWBOB_SCALE_Z 0.0

float Armor_regen_delay[MAXTF2PLAYERS];

//ConVar CvarSvRollspeed; // sv_rollspeed 
ConVar CvarSvRollagle; // sv_rollangle
int i_SvRollAngle[MAXTF2PLAYERS];

Handle SyncHud_ArmorCounter;
	
int CashSpent[MAXTF2PLAYERS];
int CashSpentTotal[MAXTF2PLAYERS];
int CashRecievedNonWave[MAXTF2PLAYERS];
int Scrap[MAXTF2PLAYERS];
int PlayStreak[MAXTF2PLAYERS];
int Ammo_Count_Ready;
int Ammo_Count_Used[MAXTF2PLAYERS];
//float Armor_Ready[MAXTF2PLAYERS];
int b_NpcForcepowerupspawn[MAXENTITIES]={0, ...}; 

int Armour_Level_Current[MAXTF2PLAYERS];
int Armor_Charge[MAXENTITIES];

int Elevators_Currently_Build[MAXTF2PLAYERS]={0, ...};
int i_SupportBuildingsBuild[MAXTF2PLAYERS]={0, ...};
int i_BarricadesBuild[MAXTF2PLAYERS]={0, ...};

//We kinda check these almost 24/7, its better to put them into an array!
const int i_MaxcountSpawners = ZR_MAX_SPAWNERS;
int i_ObjectsSpawners[ZR_MAX_SPAWNERS];

const int i_MaxcountTraps = ZR_MAX_TRAPS;
int i_ObjectsTraps[ZR_MAX_TRAPS];
float f_ChargeTerroriserSniper[MAXENTITIES];

float Resistance_for_building_High[MAXENTITIES];
int i_WhatBuilding[MAXENTITIES]={0, ...};
bool Building_Constructed[MAXENTITIES]={false, ...};

int Elevator_Owner[MAXENTITIES]={0, ...};
bool Is_Elevator[MAXENTITIES]={false, ...};

int StoreWeapon[MAXENTITIES];
int i_HealthBeforeSuit[MAXTF2PLAYERS]={0, ...};

int Level[MAXTF2PLAYERS];
int XP[MAXTF2PLAYERS];
int PlayerPoints[MAXTF2PLAYERS];
int i_ExtraPlayerPoints[MAXTF2PLAYERS];
int i_PreviousPointAmount[MAXTF2PLAYERS];

int Healing_done_in_total[MAXTF2PLAYERS];
int i_BarricadeHasBeenDamaged[MAXTF2PLAYERS];
int i_PlayerDamaged[MAXTF2PLAYERS];
int Resupplies_Supplied[MAXTF2PLAYERS];
bool WaitingInQueue[MAXTF2PLAYERS];

int Armor_table_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int i_Healing_station_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Perk_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Pack_A_Punch_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
float fl_blitz_ioc_punish_timer[MAXENTITIES+1][MAXENTITIES+1];

int i_ThisEntityHasAMachineThatBelongsToClient[MAXENTITIES];
int i_ThisEntityHasAMachineThatBelongsToClientMoney[MAXENTITIES];

float MultiGlobal = 0.25;
float MultiGlobalHealth = 0.25;
float f_WasRecentlyRevivedViaNonWave[MAXTF2PLAYERS];
			
int g_CarriedDispenser[MAXPLAYERS+1];
int i_BeingCarried[MAXENTITIES];
float f_BuildingIsNotReady[MAXTF2PLAYERS];

float GlobalAntiSameFrameCheck_NPC_SpawnNext;
//bool b_AllowBuildCommand[MAXPLAYERS + 1];

int Building_Mounted[MAXENTITIES];
bool b_SentryIsCustom[MAXENTITIES];

bool Doing_Handle_Mount[MAXPLAYERS + 1]={false, ...};
bool b_Doing_Buildingpickup_Handle[MAXPLAYERS + 1]={false, ...};

int i_PlayerToCustomBuilding[MAXPLAYERS + 1]={0, ...};

float f_DisableDyingTimer[MAXPLAYERS + 1]={0.0, ...};
int i_DyingParticleIndication[MAXPLAYERS + 1][2];
float f_DyingTextTimer[MAXPLAYERS + 1];
bool b_DyingTextOff[MAXPLAYERS + 1];

float GlobalCheckDelayAntiLagPlayerScale;
bool AllowSpecialSpawns;
int i_AmountDowned[MAXPLAYERS+1];

bool b_IgnoreWarningForReloadBuidling[MAXTF2PLAYERS];

float Building_Collect_Cooldown[MAXENTITIES][MAXTF2PLAYERS];

bool b_SpecialGrigoriStore;
float f_ExtraDropChanceRarity = 1.0;
bool applied_lastmann_buffs_once = false;


#include "zombie_riot/npc.sp"	// Global NPC List

#include "zombie_riot/buildonbuilding.sp"
#include "zombie_riot/database.sp"
#include "zombie_riot/escape.sp"
#include "zombie_riot/freeplay.sp"
#include "zombie_riot/items.sp"
#include "zombie_riot/music.sp"
#include "zombie_riot/natives.sp"
#include "zombie_riot/queue.sp"
#include "zombie_riot/tutorial.sp"
#include "zombie_riot/waves.sp"
#include "zombie_riot/zombie_drops.sp"
#include "zombie_riot/rogue.sp"
#include "zombie_riot/sm_skyboxprops.sp"
#include "zombie_riot/custom/homing_projectile_logic.sp"
#include "zombie_riot/custom/building.sp"
#include "zombie_riot/custom/healing_medkit.sp"
#include "zombie_riot/custom/weapon_slug_rifle.sp"
#include "zombie_riot/custom/weapon_boom_stick.sp"
#include "zombie_riot/custom/weapon_heavy_eagle.sp"
#include "zombie_riot/custom/weapon_annabelle.sp"
#include "zombie_riot/custom/weapon_rampager.sp"
#include "zombie_riot/custom/weapon_heaven_eagle.sp"
#include "zombie_riot/custom/weapon_star_shooter.sp"
#include "zombie_riot/custom/weapon_bison.sp"
#include "zombie_riot/custom/weapon_pomson.sp"
#include "zombie_riot/custom/weapon_cowmangler.sp"
#include "zombie_riot/custom/weapon_cowmangler_2.sp"
#include "zombie_riot/custom/weapon_auto_shotgun.sp"
#include "zombie_riot/custom/weapon_tornado.sp"
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
#include "zombie_riot/custom/wand/weapon_wand_skulls.sp"
#include "zombie_riot/custom/weapon_arrow_shot.sp"
//#include "zombie_riot/custom/weapon_pipe_shot.sp"
#include "zombie_riot/custom/weapon_survival_knife.sp"
#include "zombie_riot/custom/weapon_glitched.sp"
//#include "zombie_riot/custom/weimage.pngapon_minecraft.sp"
#include "zombie_riot/custom/arse_enal_layer_tripmine.sp"
#include "zombie_riot/custom/wand/weapon_elemental_staff.sp"
#include "zombie_riot/custom/wand/weapon_elemental_staff_2.sp"
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
#include "zombie_riot/custom/weapon_health_hose.sp"
#include "shared/custom/weapon_street_fighter.sp"
#include "shared/custom/joke_medigun_mod_drain_health.sp"
#include "shared/custom/weapon_judgement_of_iberia.sp"
#include "shared/custom/weapon_phlog_replacement.sp"
#include "zombie_riot/custom/weapon_cosmic_terror.sp"
#include "zombie_riot/custom/wand/weapon_wand_potions.sp"
#include "zombie_riot/custom/weapon_ocean_song.sp"
#include "zombie_riot/custom/wand/weapon_lantean_wand.sp"
#include "zombie_riot/custom/weapon_specter.sp"
#include "zombie_riot/custom/weapon_yamato.sp"
#include "zombie_riot/custom/wand/weapon_quincy_bow.sp"
#include "zombie_riot/custom/weapon_fantasy_blade.sp"
#include "zombie_riot/custom/weapon_saga.sp"
#include "zombie_riot/custom/wand/weapon_wand_beam_pap.sp"
#include "zombie_riot/custom/weapon_mlynar.sp"
#include "zombie_riot/custom/weapon_enforcer.sp"
#include "zombie_riot/custom/weapon_blemishine.sp"
#include "zombie_riot/custom/weapon_gladiia.sp"
#include "zombie_riot/custom/weapon_vampire_knives.sp"
#include "zombie_riot/custom/weapon_judge.sp"
#include "zombie_riot/custom/weapon_board.sp"
#include "zombie_riot/custom/wand/weapon_german_caster.sp"

void ZR_PluginLoad()
{
	Natives_PluginLoad();
}

void ZR_PluginStart()
{
	LoadTranslations("zombieriot.phrases.zombienames");
	
	RegServerCmd("zr_reloadnpcs", OnReloadCommand, "Reload NPCs");
	RegServerCmd("sm_reloadnpcs", OnReloadCommand, "Reload NPCs", FCVAR_HIDDEN);
	RegConsoleCmd("sm_store", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_shop", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_afk", Command_AFK, "BRB GONNA CLEAN MY MOM'S DISHES");
	RegAdminCmd("sm_give_cash", Command_GiveCash, ADMFLAG_ROOT, "Give Cash to the Person");
	RegAdminCmd("sm_give_scrap", Command_GiveScrap, ADMFLAG_ROOT, "Give scrap to the Person");
	RegAdminCmd("sm_give_xp", Command_GiveXp, ADMFLAG_ROOT, "Give XP to the Person");
	RegAdminCmd("sm_give_cash_all", Command_GiveCashAll, ADMFLAG_ROOT, "Give Cash to All");
	RegAdminCmd("sm_tutorial_test", Command_TestTutorial, ADMFLAG_ROOT, "Test The Tutorial");
	RegAdminCmd("sm_give_dialog", Command_GiveDialogBox, ADMFLAG_ROOT, "Give a dialog box");
	RegAdminCmd("sm_afk_knight", Command_AFKKnight, ADMFLAG_ROOT, "BRB GONNA MURDER MY MOM'S DISHES");
	RegAdminCmd("sm_spawn_grigori", Command_SpawnGrigori, ADMFLAG_ROOT, "Forcefully summon grigori");
	
	RegAdminCmd("sm_spawn_ruina_ion", Command_Spawn_Ruina_Cannon, ADMFLAG_ROOT, "Spawns a ruina Ion Cannon"); 
	RegAdminCmd("sm_kill_ruina_ion", Command_Kill_Ruina_Cannon, ADMFLAG_ROOT, "Kills all ruina Ion Cannon"); 
	RegAdminCmd("sm_fake_death_client", Command_FakeDeathCount, ADMFLAG_GENERIC, "Fake Death Count");
	
	CookieXP = new Cookie("zr_xp", "Your XP", CookieAccess_Protected);
	CookieScrap = new Cookie("zr_Scrap", "Your Scrap", CookieAccess_Protected);
	
	CvarSvRollagle = FindConVar("sv_rollangle");
	if(CvarSvRollagle)
		CvarSvRollagle.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	SkyboxProps_OnPluginStart();
	OnPluginStart_Build_on_Building();
	Database_PluginStart();
	Items_PluginStart();
	Medigun_PluginStart();
	OnPluginStartMangler();
	SentryHat_OnPluginStart();
	OnPluginStart_Glitched_Weapon();
	Tutorial_PluginStart();
	Waves_PluginStart();
	Rogue_PluginStart();
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		OnEntityCreated(ent, "info_player_teamspawn");	
	}
	
	BobTheGod_OnPluginStart();
}

void ZR_MapStart()
{
	SkyboxProps_OnMapStart();
	Rogue_MapStart();
	Ammo_Count_Ready = 0;
	ZombieMusicPlayed = false;
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	RoundStartTime = 0.0;
	cvarTimeScale.SetFloat(1.0);
	GlobalCheckDelayAntiLagPlayerScale = 0.0;
	OnMapStart_Build_on_Build();
	Reset_stats_starshooter();
	Zero(f_RingDelayGift);
	Music_ClearAll();
	Building_ClearAll();
	Medigun_ClearAll();
	WindStaff_ClearAll();
	Lighting_Wand_Spell_ClearAll();
	Wand_Cryo_Burst_ClearAll();
	Arrow_Spell_ClearAll();
	Survival_Knife_ClearAll();
	MedKit_ClearAll();
	Wand_autoaim_ClearAll();
	Weapon_lantean_Wand_ClearAll();
	Wand_Elemental_2_ClearAll();
	Wand_Calcium_Spell_ClearAll();
	Wand_Fire_Spell_ClearAll();
	Wand_Default_Spell_ClearAll();
	Wand_Necro_Spell_ClearAll();
	Wand_Skull_Summon_ClearAll();
	ShieldLogic_OnMapStart();
	Rogue_OnAbilityUseMapStart();
	RaidModeTime = 0.0;
	f_TimerTickCooldownRaid = 0.0;
	f_TimerTickCooldownShop = 0.0;
	Zero2(Armor_table_money_limit);
	Zero2(i_Healing_station_money_limit);
	Zero2(Perk_Machine_money_limit);
	Zero2(Pack_A_Punch_Machine_money_limit);
	Zero2(fl_blitz_ioc_punish_timer);
	CleanAllBuildingEscape();
	M3_ClearAll();
	ZeroRage_ClearAll();
	SniperMonkey_ClearAll();
	Weapon_Cspyknife_ClearAll();
	f_DelaySpawnsForVariousReasons = 0.0;
	Zero(Damage_dealt_in_total);
	Zero(b_HasBeenHereSinceStartOfWave);
	Zero(i_KillsMade);
	Zero(i_Backstabs);
	Zero(i_Headshots);
	Zero(f_TutorialUpdateStep);
	Zero(healing_cooldown);
	Zero(f_BuildingIsNotReady);
	Zero(f_TerroriserAntiSpamCd);
	Zero(f_DisableDyingTimer);
	Zero(f_DyingTextTimer);
	Zero(healing_cooldown);
	Zero(i_ThisEntityHasAMachineThatBelongsToClientMoney);
	Zero(f_WasRecentlyRevivedViaNonWave);
	Zero(f_TimeAfterSpawn);
	Reset_stats_Irene_Global();
	Reset_stats_PHLOG_Global();
	Irene_Map_Precache();
	PHLOG_Map_Precache();
	Cosmic_Map_Precache();
	Weapon_lantean_Wand_Map_Precache();
	EscapeSentryHat_MapStart();
	PrecachePlayerGiveGiveResponseVoice();
	Mlynar_Map_Precache();
	Judge_Map_Precache();
	Reset_stats_Mlynar_Global();
	Blemishine_Map_Precache();
	
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
	Wand_Skulls_Precache();
	Wand_Attackspeed_Map_Precache();
	Wand_Fire_Map_Precache();
	Wand_FireBall_Map_Precache();
	Wand_Lightning_Map_Precache();
	Wand_LightningAbility_Map_Precache();
	Wand_Necro_Map_Precache();
	Wand_NerosSpell_Map_Precache();
	Wand_autoaim_Map_Precache();
	Weapon_Arrow_Shoot_Map_Precache();
	Weapon_Hose_Precache();
//	Weapon_Pipe_Shoot_Map_Precache();
	Building_MapStart();
	Survival_Knife_Map_Precache();
	Aresenal_Weapons_Map_Precache();
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
	Weapon_Tornado_Blitz_Precache();
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
	Vampire_Knives_Precache();
	Fusion_Melee_OnMapStart();
	Atomic_MapStart();
	SSS_Map_Precache();
	ExplosiveBullets_Precache();
	Quantum_Gear_Map_Precache();
	WandStocks_Map_Precache();
	Weapon_RiotShield_Map_Precache();
	Passanger_Map_Precache();
	Reset_stats_Passanger_Global();
	Wand_Potions_Precache();
	ResetMapStartOcean();
	Specter_MapStart();
	Reset_stats_Yamato_Global();	//acts as a reset/map precache
	QuincyMapStart();
	Fantasy_Blade_MapStart();
	Saga_MapStart();
	Beam_Wand_Pap_OnMapStart();
	Gladiia_MapStart();
	WeaponBoard_Precache();
	Weapon_German_MapStart();
	
	Zombies_Currently_Still_Ongoing = 0;
	// An info_populator entity is required for a lot of MvM-related stuff (preserved entity)
//	CreateEntityByName("info_populator");
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	CreateTimer(2.0, GetClosestSpawners, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	
	char_MusicString1[0] = 0;
	char_MusicString2[0] = 0;
	char_RaidMusicSpecial1[0] = 0;
			
	i_MusicLength1 = 0;
	i_MusicLength2 = 0;
	i_RaidMusicLength1 = 0;
	b_RaidMusicCustom1 = false;
	
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
	i_PlayerDamaged[client] = 0;
	i_KillsMade[client] = 0;
	i_Backstabs[client] = 0;
	i_Headshots[client] = 0;
	Armor_Charge[client] = 0;
	Doing_Handle_Mount[client] = false;
	b_Doing_Buildingpickup_Handle[client] = false;
	g_CarriedDispenser[client] = INVALID_ENT_REFERENCE;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	i_CurrentEquippedPerk[client] = 0;
	i_HealthBeforeSuit[client] = 0;
	i_ClientHasCustomGearEquipped[client] = false;
	/*
	if(CurrentRound)
		CashSpent[client] = RoundToCeil(float(CurrentCash) * 0.20);
	See databaseuh
	*/

}

void ZR_ClientDisconnect(int client)
{
	SetClientTutorialMode(client, false);
	SetClientTutorialStep(client, 0);
	DataBase_ClientDisconnect(client);
	Pets_ClientDisconnect(client);
	Queue_ClientDisconnect(client);
	Reset_stats_Irene_Singular(client);
	Reset_stats_PHLOG_Singular(client);
	Reset_stats_Passanger_Singular(client);
	Reset_stats_Survival_Singular(client);
	Reset_stats_LappLand_Singular(client);
	Reset_stats_Mlynar_Singular(client);
	Reset_stats_SpikeLayer_Singular(client);
	Reset_stats_Blemishine_Singular(client);
	Reset_stats_Judge_Singular(client);
	b_HasBeenHereSinceStartOfWave[client] = false;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	CashRecievedNonWave[client] = 0;
	Healing_done_in_total[client] = 0;
	Armor_Charge[client] = 0;
	PlayerPoints[client] = 0;
	i_PreviousPointAmount[client] = 0;
	i_ExtraPlayerPoints[client] = 0;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	Escape_DropItem(client, false);
	WoodAmount[client] = 0.0;
	FoodAmount[client] = 0.0;
	GoldAmount[client] = 0.0;
	
	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
		if(IsValidEntity(entity)) //delete all buildings that arent mounted
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
			{
				static char classname[64];
				GetEntityClassname(entity, classname, sizeof(classname));
				if(!StrContains(classname, "obj_sentrygun"))
				{
					//sometimes this building does not vanish upon being used, we must destroy it manually.
					RemoveEntity(entity);
				}
			}
		}
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
			if(!StrContains(path, "zr_base_npc"))
				RemoveEntity(i);
		}
	}
	return Plugin_Handled;
}



public Action Command_AFK(int client, int args)
{
	if(client)
	{
	//	DestroyDispenser(client);
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

public Action Command_GiveCashAll(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_cash_all <cash>");
        return Plugin_Handled;
    }

	char buf[12];
	GetCmdArg(1, buf, sizeof(buf));
	int money = StringToInt(buf); 
	
	if(money > 0)
	{
		PrintToChatAll("You gained %i cash due to the admin %N!", money, client);	
	}
	else
	{
		PrintToChatAll("You lost %i cash due to the admin %N!", money, client);	
	}
	CurrentCash += money;

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
public Action Command_GiveScrap(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_scrap <target> <scrap>");
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
			PrintToChat(targets[target], "You got %i scrap from the admin %N!", money, client);
			Scrap[targets[target]] += money;
		}
		else
		{
			PrintToChat(targets[target], "You lost %i scrap due to the admin %N!", money, client);
			Scrap[targets[target]] += money;			
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
			XP[targets[target]] += money;
		}
		else
		{
			PrintToChat(targets[target], "You lost %i XP due to the admin %N!", money, client);
			XP[targets[target]] += money;			
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
		DestroyDispenser(client);
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
	Ammo_Count_Used[client] = 0;
	CashSpentTotal[client] = 0;
	f_LeftForDead_Cooldown[client] = 0.0;
	
	if(CurrentRound)
		CashSpent[client] = RoundToCeil(float(CurrentCash) * 0.20);
}

void ZR_OnClientDisconnect_Post()
{
	CheckAlivePlayers();
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
				if(dieingstate[client] != -5)
				{
					GiveCompleteInvul(client, 2.0);
					EmitSoundToAll("mvm/mvm_revive.wav", client, SNDCHAN_AUTO, 90, _, 1.0);
					MakePlayerGiveResponseVoice(client, 3); //Revived response!
				}
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
				SetEntityHealth(client, 50);
				RequestFrame(SetHealthAfterRevive, client);
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
			int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
				
			color[0] = GetEntProp(client, Prop_Send, "m_iHealth") * 255  / 210; // red  200 is the max health you can have while dying.
			color[1] = GetEntProp(client, Prop_Send, "m_iHealth") * 255  / 210;	// green
					
			color[0] = 255 - color[0];

			int particle = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
			if(IsValidEntity(particle))
			{
				SetVariantColor(color);
				AcceptEntityInput(particle, "SetGlowColor");
			}
			int TextFormat = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
			if(IsValidEntity(TextFormat))
			{
				if(f_DyingTextTimer[client] < GetGameTime())
				{
					if(b_DyingTextOff[client])
					{
						b_DyingTextOff[client] = false;
						SetVariantString("DOWNED [R]");
						AcceptEntityInput(TextFormat, "SetText");
					}
					else
					{
						SetVariantString("REVIVE [R]");
						AcceptEntityInput(TextFormat, "SetText");
						b_DyingTextOff[client] = true;
					}
					f_DyingTextTimer[client] = GetGameTime() + 1.0;
				}
				SetVariantColor(color);
				AcceptEntityInput(TextFormat, "SetColor");
			}
		}
			
		return Plugin_Continue;
	}
	int particle = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	particle = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
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


public void Spawn_Bob_Combine(int client)
{
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	flAng[2] = 0.0;
	int bob = Npc_Create(BOB_THE_GOD_OF_GODS, client, flPos, flAng, true);
	Bob_Exists = true;
	Bob_Exists_Index = EntIndexToEntRef(bob);
	Items_GiveNPCKill(client, BOB_THE_GOD_OF_GODS);
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
			Items_GiveNPCKill(client_Give_item, CURED_FATHER_GRIGORI);
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
	bool rogue = Rogue_Mode();
	if(!Waves_Started() || (rogue && Rogue_InSetup()) || GameRules_GetRoundState() != RoundState_RoundRunning)
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
	LastMann = (!rogue && !Waves_InSetup());
	int players = CurrentPlayers;
	CurrentPlayers = 0;
	int GlobalIntencity_Reduntant;
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
	
	if(rogue || (LastMann && !GlobalIntencity_Reduntant)) //Make sure if they are alone, it wont play last man music.
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
					if(i_HealthBeforeSuit[client] == 0)
					{
						SetEntProp(client, Prop_Send, "m_iHealth", MaxHealth);
					}
					//if in quantum suit, dont.
					
					int Extra = 0;
						
					Extra = RoundToNearest(Attributes_FindOnPlayerZR(client, 701));
					int Armor_Max = MaxArmorCalculation(Extra, client, 1.0);

					Armor_Charge[client] = Armor_Max;
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
			Bob_Exists_Index = -1;
		}

		if(rogue)
			rogue = !Rogue_BattleLost();
	
		if(!rogue)
		{
			int entity = CreateEntityByName("game_round_win"); 
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
		}

		if(killed)
		{
			Music_RoundEnd(killed, !rogue);
			if(!rogue)
			{
				CreateTimer(5.0, Remove_All, _, TIMER_FLAG_NO_MAPCHANGE);
			//	RequestFrames(Remove_All, 300);
			}
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
		SetEntityHealth(client, 50);
	}
}

//Set hp spam after normal revive


public void NPC_SpawnNextRequestFrame(bool force)
{
	NPC_SpawnNext(false, false, false);
}

stock void UpdatePlayerPoints(int client)
{
	int Points;
	
	Points += Healing_done_in_total[client] / 3;
	
	Points += RoundToCeil(Damage_dealt_in_total[client]) / 200;

	i_Damage_dealt_in_total[client] = RoundToCeil(Damage_dealt_in_total[client]);
	
	Points += Resupplies_Supplied[client] * 2;
	
	Points += i_BarricadeHasBeenDamaged[client] / 65;

	Points += i_PlayerDamaged[client] / 20;
	
	Points += i_ExtraPlayerPoints[client] / 2;
	
	Points /= 10;
	
	PlayerPoints[client] = Points;	// Do stuff here :)
}

stock int MaxArmorCalculation(int ArmorLevel = -1, int client, float multiplyier)
{
	if(ArmorLevel == -1)
	{
		ArmorLevel = RoundToNearest(Attributes_FindOnPlayerZR(client, 701));
	}

	int Armor_Max;
	
	if(ArmorLevel == 50)
		Armor_Max = 300;
											
	else if(ArmorLevel == 100)
		Armor_Max = 450;
											
	else if(ArmorLevel == 150)
		Armor_Max = 1000;
										
	else if(ArmorLevel == 200)
		Armor_Max = 2000;	
		
	else
		Armor_Max = 200;

	if(i_CurrentEquippedPerk[client] == 7) // Recycle Porier
	{
		Armor_Max = RoundToCeil(float(Armor_Max) * 1.5);
	}
		
	return (RoundToCeil(float(Armor_Max) * multiplyier));
	
}

stock void GiveArmorViaPercentage(int client, float multiplyier, float MaxMulti)
{
	int Armor_Max;
	
	Armor_Max = MaxArmorCalculation(_, client, MaxMulti);
	/*
	if(i_CurrentEquippedPerk[client] == 7) // Recycle Porier
	{
		Armor_Max = RoundToCeil(float(Armor_Max) * 1.5);
	}
	*/
	if(Armor_Charge[client] < Armor_Max)
	{
		int ArmorToGive;

		ArmorToGive = RoundToCeil(float(Armor_Max) * multiplyier);
		
		Armor_Charge[client] += ArmorToGive;

		if(Armor_Charge[client] >= Armor_Max)
		{
			Armor_Charge[client] = Armor_Max;
		}
	}
	
}
stock void AddAmmoClient(int client, int AmmoType, int AmmoCount = 0, float Multi = 1.0, bool ignoreperk = false)
{
	int AmmoToAdd;
	if(AmmoCount == 0)
	{
		AmmoToAdd = AmmoData[AmmoType][1];
	}
	else
	{
		AmmoToAdd = AmmoCount;
	}
	if(i_CurrentEquippedPerk[client] == 7 && !ignoreperk) // Recycle Porier
	{
		AmmoToAdd = RoundToCeil(float(AmmoToAdd) * 1.33);
	}
	if(Multi != 1.0)
	{
		AmmoToAdd = RoundToCeil(float(AmmoToAdd) * Multi);
	}


	SetAmmo(client, AmmoType, GetAmmo(client, AmmoType)+(AmmoToAdd));
}

//	f_TimerTickCooldownRaid = 0.0;
//	f_TimerTickCooldownShop = 0.0;
stock void PlayTickSound(bool RaidTimer, bool NormalTimer)
{
	if(NormalTimer)
	{
		if(f_TimerTickCooldownShop < GetGameTime())
		{
			f_TimerTickCooldownShop = GetGameTime() + 0.9;
			EmitSoundToAll("misc/halloween/clock_tick.wav", _, SNDCHAN_AUTO, _, _, 1.0);
		}
	}
	if(RaidTimer)
	{
		if(f_TimerTickCooldownRaid < GetGameTime())
		{
			float Timer_Show = RaidModeTime - GetGameTime();
		
			if(Timer_Show < 0.0)
				Timer_Show = 0.0;
				
			
			if(Timer_Show < 10.0)
			{
				if(Timer_Show < 5.0)
				{
					f_TimerTickCooldownRaid = GetGameTime() + 0.9;
				}
				else
				{
					f_TimerTickCooldownRaid = GetGameTime() + 1.9;
				}
			}
			else
				f_TimerTickCooldownRaid = GetGameTime() + 10.0;
				
			EmitSoundToAll("mvm/mvm_bomb_warning.wav", _, SNDCHAN_AUTO, _, _, 1.0);
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "You have %.1f Seconds left to kill the Raid!", Timer_Show);	
				}
			}
		}
	}
}

public Action DeleteEntitiesInHazards(Handle timer)
{
	float BuildingPos[3];
	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
		if (IsValidEntity(entity) && !i_BeingCarried[entity])
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", BuildingPos);
			BuildingPos[2] + 10.0;
			if(IsPointNoBuild(BuildingPos))
			{
				RemoveEntity(entity);
			}
		}
	}
	for(int entitycount; entitycount<ZR_MAX_TRAPS; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsTraps[entitycount]);
		if (IsValidEntity(entity))
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", BuildingPos);
			BuildingPos[2] + 10.0;
			if(IsPointNoBuild(BuildingPos))
			{
				RemoveEntity(entity);
			}
		}
	}
	for(int entity; entity<MAXENTITIES; entity++)
	{
		if (IsValidEntity(entity))
		{
			if(IsEntitySpike(entity))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", BuildingPos);
				BuildingPos[2] + 10.0;
				if(IsPointNoBuild(BuildingPos))
				{
					RemoveEntity(entity);
				}
			}
		}
	}
	return Plugin_Handled;
}
void ReviveAll(bool raidspawned = false)
{
	//only set false here
	ZombieMusicPlayed = false;

	CreateTimer(1.0, DeleteEntitiesInHazards, _, TIMER_FLAG_NO_MAPCHANGE);

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			int glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);

			
			glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);

			if(IsPlayerAlive(client))
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
			}
			//just make visible.
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);

			i_AmountDowned[client] = 0;
			DoOverlay(client, "");
			if(GetClientTeam(client)==2)
			{
				if(TeutonType[client] != TEUTON_WAITING)
				{
					b_HasBeenHereSinceStartOfWave[client] = true;
				}
				if((!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD)/* && !IsValidEntity(EntRefToEntIndex(RaidBossActive))*/)
				{
					applied_lastmann_buffs_once = false;
					DHook_RespawnPlayer(client);
					GiveCompleteInvul(client, 2.0);
				}
				else if(dieingstate[client] > 0)
				{
					GiveCompleteInvul(client, 2.0);
					if(b_LeftForDead[client])
					{
						dieingstate[client] = -8; //-8 for incode reasons, check dieing timer.
					}
					else
					{
						dieingstate[client] = 0;
					}
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
					if(!raidspawned)
					{
						SetEntityHealth(client, 50);
						RequestFrame(SetHealthAfterRevive, client);
					}
				}
				if(raidspawned)
				{
					if(GetEntProp(client, Prop_Data, "m_iHealth") <= SDKCall_GetMaxHealth(client))
					{
						SetEntityHealth(client, SDKCall_GetMaxHealth(client));
						RequestFrame(SetHealthAfterReviveRaid, client);	
					}
				}
			}
		}
	}
	
	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[entity] == CITIZEN)
		{
			Citizen npc = view_as<Citizen>(entity);
			if(npc.m_nDowned && npc.m_iWearable3 > 0)
			{
				npc.SetDowned(false);
				if(!Waves_InSetup())
				{
					int target = 0;
					for(int i=1; i<=MaxClients; i++)
					{
						if(IsClientInGame(i))
						{
							if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE && f_TimeAfterSpawn[i] < GetGameTime() && dieingstate[i] == 0) //dont spawn near players who just spawned
							{
								target = i;
								break;
							}
						}
					}
					
					if(target)
					{
						float pos[3], ang[3];
						GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
						GetEntPropVector(target, Prop_Data, "m_angRotation", ang);
						ang[2] = 0.0;
						TeleportEntity(npc.index, pos, ang, NULL_VECTOR);
					}
				}
			}
		}
	}
	
	Music_EndLastmann();
	CheckAlivePlayers();
}

int XpToLevel(int xp)
{
	return RoundToFloor(Pow(xp / 200.0, 0.5));
}

int LevelToXp(int lv)
{
	return lv * lv * 200;
}

void GiveXP(int client, int xp)
{
	XP[client] += RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue);
	int nextLevel = XpToLevel(XP[client]);
	if(nextLevel > Level[client])
	{
		static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
		ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);
		
		int maxhealth = SDKCall_GetMaxHealth(client);
		if(GetClientHealth(client) < maxhealth)
			SetEntityHealth(client, maxhealth);
		
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "Level Up", nextLevel);
		
		bool found;
		int slots;
		
		while(Level[client] < nextLevel)
		{
			Level[client]++;

			if(Level[client] == STARTER_WEAPON_LEVEL)
				CPrintToChat(client, "%t", "All Weapons Unlocked");
			
			if(Store_PrintLevelItems(client, Level[client]))
				found = true;
			
			if(Level[client] > STARTER_WEAPON_LEVEL && !(Level[client] % 2))
				slots++;
			
			if(Level[client] < 81 && !(Level[client] % 10))
				CPrintToChat(client, "%t", "Additional Starting Ingot", (Level[client] + 70) / 10, (Level[client] + 80) / 10);
		}
		
		if(slots)
		{
			PrintToChat(client, "%t", "Loadout Slots", slots);
		}
		else if(!found)
		{
			PrintToChat(client, "%t", "None");
		}
	}
}