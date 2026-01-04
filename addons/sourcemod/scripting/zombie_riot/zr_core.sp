#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9
#define STARTER_WEAPON_LEVEL	5
#define MAX_TARGETS_HIT 10

#define MVM_CLASS_FLAG_NONE				0			// Show Nothing
#define MVM_CLASS_FLAG_NORMAL			(1 << 0)	// Normal
#define MVM_CLASS_FLAG_SUPPORT			(1 << 1)	// Support
#define MVM_CLASS_FLAG_MISSION			(1 << 2)	// Support - Flashing for Spies, Busters, Engis
#define MVM_CLASS_FLAG_MINIBOSS			(1 << 3)	// Normal - Red Background
#define MVM_CLASS_FLAG_ALWAYSCRIT		(1 << 4)	// Add Blue Borders
#define MVM_CLASS_FLAG_SUPPORT_LIMITED	(1 << 5)	// Only Visible When Active

public const int AmmoData[][] =
{
	// Price, Ammo
	{ 0, 0 },			//N/A
	{ 0, 0 },			//Primary
	{ 0, 4222 },		//Secondary
	{ 10, 50 },			//Metal
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
	{ 10, 75 },		//Medical Syringes
	{ 10, 12 },			//Sniper Rifle Rounds
	{ 10, 12 },			//Arrows
	{ 10, 60 },			//SMG Magazines
	{ 10, 14 },			//REvolver Rounds
	{ 10, 12 },			//Shotgun Shells
	{ 10, 500 },		//Healing Medicine
	{ 10, 500 },		//Medigun Fluid
	{ 10, 80 },			//Laser Battery
	{ 0, 0 },			//Hand Grenade
	{ 0, 0 },			//???
	{ 0, 0 },			//???
	{ 0, 0 }			//???
};

public const int DefaultWaveCash[] =
{
	300, 300, 500, 300, 300, 300, 300, 300, 300, 1000,
	500, 500, 500, 750, 750, 1500, 2000, 1200, 1200, 2500,
	1250, 1250, 1500, 2250, 1500, 1500, 2900, 1750, 1750, 5000,
	1850, 1850, 1850, 1850, 1850, 3000, 3000, 4000, 4000, 20000,
	3000, 3000, 3000, 3000, 15000,
	2500, 2500, 3000, 4000, 25000,
	3000, 3000, 3000, 3000
};

stock int DefaultTotalCash(int wave)
{
	static int totalCash[sizeof(DefaultWaveCash)];

	if(!totalCash[0])
	{
		int total;
		for(int i; i < sizeof(DefaultWaveCash); i++)
		{
			total += DefaultWaveCash[i];
			totalCash[i] = total;
		}
	}
	
	int twave = wave;
	if(twave >= sizeof(DefaultWaveCash))
		twave = sizeof(DefaultWaveCash) - 1;
	
	return totalCash[twave];
}

//FOR PERK MACHINE!
public const char PerkNames[][] =
{
	"No Perk",
	"Regene Berry",
	"Obsidian Oaf",
	"Morning Coffee",
	"Hasty Hops",
	"Marksman Beer",
	"Teslar Mule",
	"Stockpile Stout",
	"Energy Drink"
};

public const char PerkNames_Received[][] =
{
	"No Perk",
	"Regene Berry Received",
	"Obsidian Oaf Received",
	"Morning Coffee Received",
	"Hasty Hops Received",
	"Marksman Beer Received",
	"Teslar Mule Received",
	"Stockpile Stout Received",
	"Energy Drink Received"
};

public const char PerkNames_two_Letter[][] =
{
	"--",
	"RB",
	"OO",
	"MC",
	"HH",
	"MB",
	"TM",
	"SS",
	"ED"
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
	WEAPON_COSMIC_TERROR = 8,
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
	WEAPON_GERMAN = 42,
	WEAPON_SENSAL_SCYTHE = 43,
	WEAPON_SENSAL_SCYTHE_PAP_1 = 44,
	WEAPON_SENSAL_SCYTHE_PAP_2 = 45,
	WEAPON_SENSAL_SCYTHE_PAP_3 = 46,
	WEAPON_HAZARD = 47,
	WEAPON_HAZARD_UNSTABLE = 48,
	WEAPON_HAZARD_LUNATIC = 49,
	WEAPON_HAZARD_CHAOS = 50,
	WEAPON_HAZARD_STABILIZED = 51,
	WEAPON_HAZARD_DEMI = 52,
	WEAPON_HAZARD_PERFECT = 53,
	WEAPON_FIRE_WAND = 54,
	WEAPON_CASINO = 55,
	WEAPON_ION_BEAM = 56,
	WEAPON_SEABORNMELEE = 57,
	WEAPON_LEPER_MELEE = 58,
	WEAPON_LEPER_MELEE_PAP = 59,
	WEAPON_FLAGELLANT_MELEE = 60,
	WEAPON_FLAGELLANT_HEAL = 61,
	WEAPON_SEABORN_MISC = 62,
	WEAPON_TEXAN_BUISNESS = 63,
	WEAPON_FLAGELLANT_DAMAGE = 64,
	WEAPON_FUSION_PAP1 = 65,
	WEAPON_FUSION_PAP2 = 66,
	WEAPON_STAR_SHOOTER = 67,
	WEAPON_BOBS_GUN = 68,
	WEAPON_IMPACT_LANCE = 69,
	WEAPON_BUFF_BANNER = 70,
	WEAPON_SURVIVAL_KNIFE_PAP1 = 71,
	WEAPON_SURVIVAL_KNIFE_PAP2 = 72,
	WEAPON_SURVIVAL_KNIFE_PAP3 = 73,
	WEAPON_TRASH_CANNON = 74,
	WEAPON_SKULL_SERVANT = 75,
	WEAPON_NECRO_WANDS = 76,
	WEAPON_KIT_BLITZKRIEG_CORE = 77,
	WEAPON_QUIBAI = 78,
	WEAPON_ANGELIC_SHOTGUN = 79,
	WEAPON_RAPIER = 80,
	WEAPON_RED_BLADE = 81,
	WEAPON_GRAVATON_WAND = 82,
	UNUSED_WEAPON_83 = 83,
	WEAPON_SICCERINO = 84,
	WEAPON_DIMENSION_RIPPER = 85,
	WEAPON_HELL_HOE_1 = 86,
	WEAPON_HELL_HOE_2 = 87,
	WEAPON_HELL_HOE_3 = 88,
	WEAPON_LUDO = 89,
	WEAPON_KAHMLFIST = 90,
	WEAPON_HHH_AXE = 91,
	WEAPON_MESSENGER_LAUNCHER = 92,
	WEAPON_NAILGUN_SMG = 93,
	WEAPON_NAILGUN_SHOTGUN = 94,
	WEAPON_BLACKSMITH = 95,
	WEAPON_COSMIC_PILLAR = 96,
	WEAPON_COSMIC_RAILCANNON = 97,
	WEAPON_GRENADEHUD = 98,
	WEAPON_WEST_REVOLVER = 99,
	WEAPON_OBUCH = 100,
	WEAPON_VICTORIAN_LAUNCHER = 101,
	WEAPON_BOOM_HAMMER = 102,
	WEAPON_MERCHANT = 103,
	WEAPON_MERCHANTGUN = 104,
	WEAPON_RUSTY_RIFLE = 105,
	WEAPON_MG42 = 106,
	WEAPON_ION_BEAM_PULSE = 107,
	WEAPON_ION_BEAM_NIGHT = 108,
	WEAPON_ION_BEAM_FEED  = 109,
	WEAPON_CHAINSAW  = 110,
	WEAPON_FLAMETAIL = 111,
	WEAPON_OCEAN_PAP = 112,
	WEAPON_EXPIDONSAN_REAPIR = 113,
	WEAPON_WALDCH_SWORD_NOVISUAL = 114,
	WEAPON_WALDCH_SWORD_REAL = 115,
	WEAPON_MLYNAR_PAP_2 = 116,
	WEAPON_ULPIANUS = 117,
	WEAPON_WRATHFUL_BLADE = 118,
	WEAPON_MAGNESIS = 119,
	WEAPON_SUPERUBERSAW = 120,
	WEAPON_YAKUZA = 121,
	WEAPON_EXPLORER = 122,
	WEAPON_FULLMOON = 123,
	WEAPON_SKADI = 124,
	WEAPON_HUNTING_RIFLE = 125,
	WEAPON_URANIUM_RIFLE = 126,
	WEAPON_LOGOS = 127,
	WEAPON_WALTER = 128,
	WEAPON_OLDINFINITYBLADE = 129,
	WEAPON_NYMPH = 130,
	WEAPON_CASTLEBREAKER = 131,
	WEAPON_ZEALOT_MELEE = 132,
	WEAPON_ZEALOT_GUN = 133,
	WEAPON_ZEALOT_POTION = 134,
	WEAPON_KIT_FRACTAL	= 135,
	WEAPON_KIT_PROTOTYPE	= 136,
	WEAPON_KIT_PROTOTYPE_MELEE	= 137,
	WEAPON_PURNELL_MELEE = 138,
	WEAPON_PURNELL_PRIMARY = 139,
	WEAPON_KRITZKRIEG = 140,
	WEAPON_X10KNIFE = 141,
	WEAPON_RUINA_DRONE_KNIFE = 142,
	WEAPON_TORNADO_BLITZ = 143,
	WEAPON_BUFFPOTION = 144,
	WEAPON_REIUJI_WAND = 145,
	WEAPON_CHEESY_MELEE = 146,
	WEAPON_CHEESY_PRIMARY = 147,
	WEAPON_CHEMICAL_THROWER = 148,
	WEAPON_RITUALIST = 149,
	WEAPON_SHERRIF = 150,
	WEAPON_SHERRIF_LEVERACTION = 151,
	WEAPON_BOOMERANG = 152,
	WEAPON_CHEESY_SECONDARY = 153,
	WEAPON_RAIGEKI = 154,
	WEAPON_HAMMER_NONPAP = 155,
	WEAPON_HAMMER_PAP_1 = 156,
	WEAPON_SIGIL_BLADE = 157,
    WEAPON_KIT_OMEGA_GAUSS = 158,
    WEAPON_KIT_OMEGA = 159,
    WEAPON_KIT_PURGE_CRUSHER = 160,
    WEAPON_KIT_PURGE_RAMPAGER = 161,
    WEAPON_KIT_PURGE_ANNAHILATOR = 162,
    WEAPON_KIT_PURGE_MISC = 163,
	WEAPON_BOMB_AR = 164
}

enum
{
	Type_Hidden = -1,
	Type_DONOTUSE = 0,
	Type_Ally = 1,
	Type_Special,
	Type_Raid,
	Type_Common,
	Type_Alt,
	Type_Xeno,
	Type_BTD,
	Type_Medieval,
	Type_COF,
	Type_Seaborn,
	Type_Expidonsa,
	Type_Interitus,
	Type_BlueParadox,
	Type_Void,
	Type_Ruina,
	Type_IberiaExpiAlliance,
	Type_WhiteflowerSpecial,
	Type_Victoria,
	Type_Matrix,
	Type_Aperture,
	Type_Mutation,
	Type_Curtain,
	Type_Necropolain
}

//int Bob_To_Player[MAXENTITIES];
bool Bob_Exists = false;
int GrigoriMaxSells = 3;
int Bob_Exists_Index = -1;
int CurrentPlayers;
ConVar zr_voteconfig;
ConVar zr_tagblacklist;
ConVar zr_tagwhitelist;
ConVar zr_tagwhitehard;
ConVar zr_minibossconfig;
ConVar zr_ignoremapconfig;
ConVar CvarNoRoundStart;
ConVar Cvar_VshMapFix;
ConVar CvarNoSpecialZombieSpawn;
ConVar zr_disablerandomvillagerspawn;
ConVar zr_waitingtime;
ConVar zr_maxscaling_untillhp;
ConVar zr_maxsbosscaling_untillhp;
ConVar zr_raidmultihp;
ConVar zr_multi_maxenemiesalive_cap;
ConVar zr_multi_scaling;
int CurrentGame = -1;
bool b_GameOnGoing = true;
//bool b_StoreGotReset = false;
int CurrentCash;
int GlobalExtraCash;
bool LastMann;
bool LastMannScreenEffect;

//this is to display a hud icon showing that youre the last remaining player, i.e.
// shows to everyone, showing that, oh shit, dont die.
bool LastMann_BeforeLastman;
int LimitNpcs;
int i_MVMPopulator;

//bool RaidMode; 							//Is this raidmode?
float RaidModeScaling = 0.5;			//what multiplier to use for the raidboss itself?
float RaidModeTime = 0.0;
float f_TimerTickCooldownRaid = 0.0;
float f_TimerTickCooldownShop = 0.0;
float f_FreeplayDamageExtra = 1.0;
int SalesmanAlive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?

float PlayerCountBuffScaling = 1.0;
float PlayerCountBuffAttackspeedScaling = 1.0;
float PlayerCountResBuffScaling = 1.0;
int PlayersAliveScaling;
int PlayersInGame;
bool ZombieMusicPlayed;
int GlobalIntencity;
bool b_HasBeenHereSinceStartOfWave[MAXPLAYERS];
Cookie CookieScrap;
Cookie CookieXP;
ArrayList Loadouts[MAXPLAYERS];

float f_RingDelayGift[MAXENTITIES];
float Resistance_for_building_High[MAXENTITIES];

//custom wave music.
MusicEnum MusicString1;
MusicEnum MusicString2;
MusicEnum MusicSetup1;
MusicEnum MusicLastmann;
MusicEnum MusicWin;
MusicEnum MusicLoss;
MusicEnum RaidMusicSpecial1;
MusicEnum BGMusicSpecial1;
//custom wave music.
float f_DelaySpawnsForVariousReasons;
int CurrentRound[Rounds_MAX];
int CurrentWave[Rounds_MAX] = {-1, ...};
int StartCash;
float RoundStartTime;
char WhatDifficultySetting_Internal[32];
char WhatDifficultySetting[32];
float healing_cooldown[MAXPLAYERS];
float f_TimeAfterSpawn[MAXPLAYERS];
float WoodAmount[MAXPLAYERS];
float FoodAmount[MAXPLAYERS];
float GoldAmount[MAXPLAYERS];
int SupplyRate[MAXPLAYERS];
//int i_PreviousBuildingCollision[MAXENTITIES];
bool b_AlaxiosBuffItem[MAXENTITIES];
int i_Reviving_This_Client[MAXPLAYERS];
float f_Reviving_This_Client[MAXPLAYERS];
float f_HudCooldownAntiSpamRaid[MAXPLAYERS];
int i_MaxArmorTableUsed[MAXPLAYERS];
float ResourceRegenMulti;
bool Barracks_InstaResearchEverything;
bool b_HoldingInspectWeapon[MAXPLAYERS];

#define SF2_PLAYER_VIEWBOB_TIMER 10.0
#define SF2_PLAYER_VIEWBOB_SCALE_X 0.05
#define SF2_PLAYER_VIEWBOB_SCALE_Y 0.0
#define SF2_PLAYER_VIEWBOB_SCALE_Z 0.0
#define RAID_MAX_ARMOR_TABLE_USE 20
#define ZR_ARMOR_DAMAGE_REDUCTION 0.75
#define ZR_ARMOR_DAMAGE_REDUCTION_INVRERTED 0.25

float Armor_regen_delay[MAXPLAYERS];

//ConVar CvarSvRollspeed; // sv_rollspeed 
//ConVar CvarSvRollagle; // sv_rollangle
ConVar mp_disable_respawn_times;
//int i_SvRollAngle[MAXPLAYERS];

	
bool DisableSpawnProtection;
bool DisableRandomSpawns;
int CashSpent[MAXPLAYERS];
int CashSpentGivePostSetup[MAXPLAYERS];
bool CashSpentGivePostSetupWarning[MAXPLAYERS];
int CashSpentTotal[MAXPLAYERS];
int CashSpentLoadout[MAXPLAYERS];
int CashReceivedNonWave[MAXPLAYERS];
bool StarterCashMode[MAXPLAYERS] = {true, ...};
int Scrap[MAXPLAYERS];
int PlayStreak[MAXPLAYERS];
int Ammo_Count_Ready;
int Ammo_Count_Used[MAXPLAYERS];
//float Armor_Ready[MAXPLAYERS];
int b_NpcForcepowerupspawn[MAXENTITIES]={0, ...}; 

int Armour_Level_Current[MAXPLAYERS];
int Armor_Charge[MAXENTITIES];
int Armor_DebuffType[MAXENTITIES];
float f_Armor_BreakSoundDelay[MAXENTITIES];

float AnyMenuOpen[MAXPLAYERS];
float LastStoreMenu[MAXPLAYERS];
bool LastStoreMenu_Store[MAXPLAYERS];

//We kinda check these almost 24/7, its better to put them into an array!
const int i_MaxcountSpawners = ZR_MAX_SPAWNERS;
int i_ObjectsSpawners[ZR_MAX_SPAWNERS];

const int i_MaxcountTraps = ZR_MAX_TRAPS;
int i_ObjectsTraps[ZR_MAX_TRAPS];
float f_ChargeTerroriserSniper[MAXENTITIES];

int StoreWeapon[MAXENTITIES];
int i_HealthBeforeSuit[MAXPLAYERS]={0, ...};
float f_HealthBeforeSuittime[MAXPLAYERS]={0.0, ...};

int Level[MAXPLAYERS];
int XP[MAXPLAYERS];
int i_ExtraPlayerPoints[MAXPLAYERS];
int i_PreviousPointAmount[MAXPLAYERS];
int SpecialLastMan;

bool WaitingInQueue[MAXPLAYERS];
float FreeplayTimeLimit;

float fl_blitz_ioc_punish_timer[MAXENTITIES+1][MAXENTITIES+1];

float f_WasRecentlyRevivedViaNonWave[MAXPLAYERS];
float f_WasRecentlyRevivedViaNonWaveClassChange[MAXPLAYERS];

float f_MedigunChargeSave[MAXPLAYERS][4];
float f_SaveBannerRageMeter[MAXPLAYERS][2];


float f_DisableDyingTimer[MAXPLAYERS + 1]={0.0, ...};
int i_DyingParticleIndication[MAXPLAYERS + 1][3];
//1 is text, 2 is glow, 3 is death marker
float f_DyingTextTimer[MAXPLAYERS + 1];
bool b_DyingTextOff[MAXPLAYERS + 1];

float GlobalCheckDelayAntiLagPlayerScale;
bool AllowSpecialSpawns;
int i_AmountDowned[MAXPLAYERS+1];

bool b_IgnoreWarningForReloadBuidling[MAXPLAYERS];

float Building_Collect_Cooldown[MAXENTITIES][MAXPLAYERS];

bool b_SpecialGrigoriStore = true;
float f_ExtraDropChanceRarity = 1.0;
bool applied_lastmann_buffs_once = false;
int i_WaveHasFreeplay = 0;
float fl_MatrixReflect[MAXENTITIES];


#include "include/zombie_riot.inc"

#include "npc.sp"	// Global NPC List

#include "aprilfools_settings.sp"
#include "building.sp"
#include "database.sp"
#include "elemental.sp"
#include "escape.sp"
#include "freeplay.sp"
#include "items.sp"
#include "music.sp"
#include "natives.sp"
#include "queue.sp"
#include "skilltree.sp"
#include "spawns.sp"
#include "store.sp"
#include "teuton_sound_override.sp"
#include "barney_sound_override.sp"
#include "kleiner_sound_override.sp"
#include "tutorial.sp"
#include "waves.sp"
#include "zombie_drops.sp"
#include "rogue.sp"
#include "mvm_hud.sp"
#include "steamworks.sp"
#include "zsclassic.sp"
#include "construction.sp"
#include "betting.sp"
#include "dungeons.sp"
#include "sm_skyboxprops.sp"
#include "custom/homing_projectile_logic.sp"
#include "custom/weapon_slug_rifle.sp"
#include "custom/weapon_boom_stick.sp"
#include "custom/weapon_heavy_eagle.sp"
#include "custom/weapon_annabelle.sp"
#include "custom/weapon_rampager.sp"
#include "custom/weapon_heaven_eagle.sp"
#include "custom/weapon_star_shooter.sp"
#include "custom/weapon_bison.sp"
#include "custom/weapon_pomson.sp"
#include "custom/weapon_cowmangler.sp"
#include "custom/weapon_cowmangler_2.sp"
#include "custom/weapon_auto_shotgun.sp"
#include "custom/weapon_tornado.sp"
#include "custom/weapon_fists_of_kahml.sp"
#include "custom/weapon_fusion_melee.sp"
#include "custom/spike_layer.sp"
#include "custom/weapon_grenade.sp"
#include "custom/wand/weapon_default_wand.sp"
#include "custom/wand/weapon_wand_increase_attack.sp"
#include "custom/wand/weapon_fire_wand.sp"
#include "custom/wand/weapon_wand_fire_ball.sp"
#include "custom/wand/weapon_lightning_wand.sp"
#include "custom/wand/weapon_wand_cryo.sp"
#include "custom/wand/weapon_wand_lightning_spell.sp"
#include "custom/wand/weapon_necromancy_wand.sp"
#include "custom/wand/weapon_wand_necro_spell.sp"
#include "custom/wand/weapon_autoaim_wand.sp"
#include "custom/wand/weapon_wand_skulls.sp"
#include "custom/weapon_arrow_shot.sp"
//#include "custom/weapon_pipe_shot.sp"
#include "custom/weapon_survival_knife.sp"
#include "custom/weapon_glitched.sp"
//#include "custom/weimage.pngapon_minecraft.sp"
#include "custom/arse_enal_layer_tripmine.sp"
#include "custom/wand/weapon_elemental_staff.sp"
#include "custom/wand/weapon_elemental_staff_2.sp"
//#include "custom/weapon_black_fire_wand.sp"
#include "custom/wand/weapon_chlorophite.sp"
#include "custom/wand/weapon_chlorophite_heavy.sp"
#include "custom/weapon_drink_resupply_mana.sp"
#include "custom/weapon_wind_staff.sp"
#include "custom/wand/weapon_nailgun.sp"
#include "custom/weapon_five_seven.sp"
#include "custom/weapon_gb_medigun.sp"
#include "custom/weapon_charged_handgun.sp"
#include "custom/wand/weapon_wand_beam.sp"
#include "custom/wand/weapon_wand_lightning_pap.sp"
#include "custom/wand/weapon_calcium_wand.sp"
#include "custom/wand/weapon_wand_calcium_spell.sp"
#include "custom/weapon_passive_banner.sp"
#include "custom/weapon_ark.sp"
#include "custom/coin_flip.sp"
#include "custom/weapon_manual_reload.sp"
#include "custom/weapon_super_star_shooter.sp"
#include "custom/weapon_Texan_business.sp"
#include "custom/weapon_explosivebullets.sp"
#include "custom/weapon_sniper_monkey.sp"
#include "custom/weapon_cspyknife.sp"
#include "custom/wand/weapon_quantum_weaponry.sp"
#include "custom/weapon_riotshield.sp"
#include "custom/m3_abilities.sp"
#include "custom/weapon_health_hose.sp"
#include "custom/weapon_superubersaw.sp"
#include "../shared/custom/joke_medigun_mod_drain_health.sp"
#include "../shared/custom/weapon_judgement_of_iberia.sp"
#include "../shared/custom/weapon_phlog_replacement.sp"
#include "custom/weapon_cosmic_terror.sp"
#include "custom/wand/weapon_wand_potions.sp"
#include "custom/weapon_ocean_song.sp"
#include "custom/wand/weapon_lantean_wand.sp"
#include "custom/weapon_specter.sp"
#include "custom/weapon_yamato.sp"
#include "custom/wand/weapon_quincy_bow.sp"
#include "custom/weapon_fantasy_blade.sp"
#include "custom/weapon_saga.sp"
#include "custom/wand/weapon_wand_beam_pap.sp"
#include "custom/weapon_mlynar.sp"
#include "custom/weapon_enforcer.sp"
#include "custom/weapon_blemishine.sp"
#include "custom/weapon_gladiia.sp"
#include "custom/weapon_vampire_knives.sp"
#include "custom/weapon_judge.sp"
#include "custom/weapon_board.sp"
#include "custom/wand/weapon_german_caster.sp"
#include "custom/weapon_sensal.sp"
#include "custom/weapon_hazard.sp"
#include "custom/weapon_casino.sp"
#include "custom/wand/weapon_ion_beam_wand.sp"
#include "custom/kit_seaborn.sp"
#include "custom/weapon_class_leper.sp"
#include "custom/kit_flagellant.sp"
#include "custom/kit_zealot.sp"
#include "custom/kit_purnell.sp"
#include "custom/cosmetics/silvester_cosmetics_yay.sp"
#include "custom/cosmetics/magia_cosmetics.sp"
#include "custom/wand/weapon_wand_impact_lance.sp"
#include "custom/weapon_trash_cannon.sp"
#include "custom/weapon_rusty_rifle.sp"
#include "custom/weapon_wrathful_blade.sp"
#include "custom/kit_blitzkrieg.sp"
#include "custom/kit_fractal.sp"
#include "custom/weapon_laz_laser_cannon.sp"
#include "custom/weapon_angelic_shotgonnus.sp"
#include "custom/weapon_fullmoon.sp"
#include "custom/red_blade.sp"
#include "custom/weapon_rapier.sp"
#include "custom/wand/weapon_wand_gravaton.sp"
#include "custom/wand/weapon_wand_reiuji.sp"
#include "custom/weapon_heavy_particle_rifle.sp"
#include "custom/weapon_railcannon.sp"
#include "custom/wand/weapon_dimension_ripper.sp"
#include "custom/weapon_hell_hoe.sp"
#include "custom/wand/weapon_ludo.sp"
#include "custom/weapon_messenger.sp"
#include "custom/kit_blacksmith.sp"
#include "custom/weapon_deagle_west.sp"
#include "custom/weapon_victorian.sp"
#include "custom/weapon_obuch.sp"
#include "custom/kit_merchant.sp"
#include "custom/weapon_mg42.sp"
#include "custom/weapon_chainsaw.sp"
#include "custom/weapon_flametail.sp"
#include "custom/weapon_ulpianus.sp"
#include "custom/wand/weapon_wand_magnesis.sp"
#include "custom/wand/weapon_wand_raigeki.sp"
#include "custom/kit_blacksmith_brew.sp"
#include "custom/weapon_yakuza.sp"
#include "custom/weapon_skadi.sp"
#include "custom/weapon_hunting_rifle.sp"
#include "custom/wand/weapon_logos.sp"
#include "custom/weapon_walter.sp"
#include "custom/wand/weapon_wand_nymph.sp"
#include "custom/weapon_castlebreaker.sp"
#include "custom/kit_soldine.sp"
#include "custom/weapon_kritzkrieg.sp"
#include "custom/wand/weapon_bubble_wand.sp"
#include "custom/kit_blacksmith_grill.sp"
#include "custom/kit_cheese.sp"
#include "custom/weapon_flamethrower_chemical.sp"
#include "custom/wand/weapon_ritualist.sp"
#include "custom/weapon_boomerang.sp"
#include "custom/wand/weapon_wand_sigil_blade.sp"
#include "custom/kit_omega.sp"
#include "custom/kit_purging.sp"
#include "custom/weapon_bombplant_smg.sp"
#include "custom/weapon_guiding_missile.sp"

void ZR_PluginLoad()
{
	Natives_PluginLoad();
}

void ZR_PluginStart()
{
	LoadTranslations("zombieriot.phrases.zombienames");
	LoadTranslations("zombieriot.phrases.npctalk");
	
	RegServerCmd("zr_reloadnpcs", OnReloadCommand, "Reload NPCs");
	RegServerCmd("sm_reloadnpcs", OnReloadCommand, "Reload NPCs", FCVAR_HIDDEN);

	//any noob will eventually type these!!
	RegConsoleCmd("sm_store", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_shop", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_market", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_zmarket", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_weapons", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_walmart", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_tesco", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_buy", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_guns", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_gun", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_givegun", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_giveweapons", Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_giveweapon", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_cmd", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_cmds", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_commands", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_help", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_giveweapon", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_info", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_givemeall", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_giveall", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_freeitems", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_wear", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_wearme", 		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_zr", 			Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_lidlnord", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_kaufland", 	Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_ikea",		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_zabka",		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	RegConsoleCmd("sm_penny",		Access_StoreViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);


	RegConsoleCmd("sm_afk", Command_AFK, "BRB GONNA CLEAN MY MOM'S DISHES");
	//RegConsoleCmd("sm_rtd", Command_RTdFail, "Go away.");						//Littearlly cannot support RTD. I will remove this onec i add support for it, but i doubt i ever will.
	
	RegAdminCmd("sm_give_cash", Command_GiveCash, ADMFLAG_ROOT, "Give Cash to the Person");
	RegAdminCmd("sm_give_buff", Command_GiveBuff, ADMFLAG_ROOT, "Give a named buff");
	RegAdminCmd("sm_give_scrap", Command_GiveScrap, ADMFLAG_ROOT, "Give scrap to the Person"); //old and unused.
	RegAdminCmd("sm_give_xp", Command_GiveXp, ADMFLAG_ROOT, "Give XP to the Person");
	RegAdminCmd("sm_set_xp", Command_SetXp, ADMFLAG_ROOT, "Set XP to the Person");
	RegAdminCmd("sm_give_cash_all", Command_GiveCashAll, ADMFLAG_ROOT, "Give Cash to All");
	RegAdminCmd("sm_tutorial_test", Command_TestTutorial, ADMFLAG_ROOT, "Test The Tutorial");			//DEBUG
	RegAdminCmd("sm_give_dialog", Command_GiveDialogBox, ADMFLAG_ROOT, "Give a dialog box");			//DEBUG
	RegAdminCmd("sm_afk_knight", Command_AFKKnight, ADMFLAG_ROOT, "BRB GONNA MURDER MY MOM'S DISHES");	//DEBUG
	RegAdminCmd("sm_spawn_grigori", Command_SpawnGrigori, ADMFLAG_ROOT, "Forcefully summon grigori");	//DEBUG
	RegAdminCmd("sm_displayhud", CommandDebugHudTest, ADMFLAG_ROOT, "debug stuff");						//DEBUG
	RegAdminCmd("sm_fake_death_client", Command_FakeDeathCount, ADMFLAG_ROOT, "Fake Death Count"); 	//DEBUG
	RegAdminCmd("sm_spawn_vehicle", Command_PropVehicle, ADMFLAG_ROOT, "Spawn Vehicle"); 	//DEBUG
	RegAdminCmd("sm_loadbgmusic", CommandBGTest, ADMFLAG_RCON, "Load a config containing a music field as passive music");
	RegAdminCmd("sm_forceset_team", Command_SetTeamCustom, ADMFLAG_ROOT, "Set Team custom to a player"); 	//DEBUG
	
	RegAdminCmd("zr_rein", CommandAdminReinforce, ADMFLAG_ROOT, "Deploying Reinforce");
	RegAdminCmd("zr_waveadd", Waves_AdminsWaveTimeAddCmd, ADMFLAG_ROOT, "Wave Time Add");
	RegAdminCmd("zr_waveremain", Waves_AdminsWaveTimeRemainCmd, ADMFLAG_ROOT, "Wave Time Remain");
	RegAdminCmd("zr_raidend", Waves_AdminsRaidTimeEndCmd, ADMFLAG_ROOT, "Raid Force END");
	RegAdminCmd("zr_raidadd", Waves_AdminsRaidTimeAddCmd, ADMFLAG_ROOT, "Raid Time Add");
	RegAdminCmd("zr_scaletest", Waves_ScaleTestCmd, ADMFLAG_ROOT, "Usage: zr_scaletest <Players> [AllyRebels] [EnemyCount] [EnemyHP]  [EnemyDMG]");
	
	
	CookieXP = new Cookie("zr_xp", "Your XP", CookieAccess_Protected);
	CookieScrap = new Cookie("zr_Scrap", "Your Scrap", CookieAccess_Protected);

	SkyboxProps_OnPluginStart();
	Construction_PluginStart();
	Database_PluginStart();
	Items_PluginStart();
	Medigun_PluginStart();
	OnPluginStartMangler();
	OnPluginStart_Glitched_Weapon();
	SkillTree_PluginStart();
	Tutorial_PluginStart();
	Waves_PluginStart();
	Rogue_PluginStart();
	Spawns_PluginStart();
	Object_PluginStart();
	SteamWorks_PluginStart();
	Vehicle_PluginStart();
	Kritzkrieg_PluginStart();
	BetWar_PluginStart();
	Dungeon_PluginStart();
	Format(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), "%s", "No Difficulty Selected Yet");
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		OnEntityCreated(ent, "info_player_teamspawn");	
	}

	for (int ent = -1; (ent = FindEntityByClassname(ent, "ambient_generic")) != -1;) 
	{
		OnEntityCreated(ent, "ambient_generic");	
	}
	
	BobTheGod_OnPluginStart();
	VIPBuilding_PluginStart();
	NpcConst2Building_CommandPluginStart();
}

void ZR_MapStart()
{
	MusicString1.Clear();
	MusicString2.Clear();
	MusicSetup1.Clear();
	MusicLastmann.Clear();
	MusicWin.Clear();
	MusicLoss.Clear();
	RaidMusicSpecial1.Clear();
	PrecacheSound("ui/hitsound_electro1.wav");
	PrecacheSound("ui/hitsound_electro2.wav");
	PrecacheSound("ui/hitsound_electro3.wav");
	PrecacheSound("ui/hitsound_space.wav");
	PrecacheSound("#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
	PrecacheSound("ui/chime_rd_2base_neg.wav");
	PrecacheSound("ui/chime_rd_2base_pos.wav");
	PrecacheSound("items/suitchargeno1.wav");
	PrecacheSound("beams/beamstart5.wav");
	TeutonSoundOverrideMapStart();
	BarneySoundOverrideMapStart();
	KleinerSoundOverrideMapStart();
	SkyboxProps_OnMapStart();
	Tutorial_MapStart();
	Rogue_MapStart();
	Classic_MapStart();
	Construction_MapStart();
	BetWar_MapStart();
	Dungeon_MapStart();
	Zero(TeutonType); //Reset teutons on mapchange
	f_AllowInstabuildRegardless = 0.0;
	Zero(i_NormalBarracks_HexBarracksUpgrades);
	Zero(i_NormalBarracks_HexBarracksUpgrades_2);
	Ammo_Count_Ready = 0;
	ZombieMusicPlayed = false;
	Seaborn_OnMapStart();
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	Format(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), "%s", "No Difficulty Selected Yet");
	WavesUpdateDifficultyName();
	cvarTimeScale.SetFloat(1.0);
	GlobalCheckDelayAntiLagPlayerScale = 0.0;
	Zero(f_Reviving_This_Client);
	Zero(i_Reviving_This_Client);
	WaveStart_SubWaveStart(GetGameTime());
	Reset_stats_starshooter();
	Zero(f_RingDelayGift);
	Zero(f_HealthBeforeSuittime);
	Music_ClearAll();
	BuildingVoteEndResetCD();
	Medigun_ClearAll();
	WindStaff_ClearAll();
	Lighting_Wand_Spell_ClearAll();
	Wand_Cryo_Burst_ClearAll();
	Arrow_Spell_ClearAll();
	Survival_Knife_ClearAll();
	Wand_autoaim_ClearAll();
	Weapon_lantean_Wand_ClearAll();
	Wand_Elemental_2_ClearAll();
	Wand_Calcium_Spell_ClearAll();
	Wand_Fire_Spell_ClearAll();
	Wand_Default_Spell_ClearAll();
	Wand_Necro_Spell_ClearAll();
	Wand_Skull_Summon_ClearAll();
	Rusty_Rifle_ResetAll();
	ShieldLogic_OnMapStart();
	Weapon_RapierMapChange();
	Rogue_OnAbilityUseMapStart();
	Weapon_TexanBuisnesMapChange();
	AngelicShotgun_MapStart();
	FullMoon_MapStart();
	SuperUbersaw_Mapstart();
	RaidModeTime = 0.0;
	f_TimerTickCooldownRaid = 0.0;
	f_TimerTickCooldownShop = 0.0;
	Zero2(fl_blitz_ioc_punish_timer);
	Zero(b_HideCosmeticsPlayer);
	KahmlFistMapStart();
	M3_ClearAll();
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
	Zero(f_TerroriserAntiSpamCd);
	Zero(f_DisableDyingTimer);
	Zero(f_DyingTextTimer);
	Zero(healing_cooldown);
	Zero(f_WasRecentlyRevivedViaNonWave);
	Zero(f_WasRecentlyRevivedViaNonWaveClassChange);
	Zero(f_TimeAfterSpawn);
	Zero2(f_ArmorCurrosionImmunity);
	Zero(fl_MatrixReflect);
	Reset_stats_Irene_Global();
	Reset_stats_PHLOG_Global();
	Irene_Map_Precache();
	PHLOG_Map_Precache();
	Cosmic_Map_Precache();
	Weapon_lantean_Wand_Map_Precache();
	PrecachePlayerGiveGiveResponseVoice();
	Mlynar_Map_Precache();
	Hazard_Map_Precache();
	Judge_Map_Precache();
	Reset_stats_Mlynar_Global();
//	Reset_stats_Casino_Global();
	Blemishine_Map_Precache();
	
	Waves_MapStart();
	Freeplay_OnMapStart();
	Music_MapStart();
	Wand_Map_Precache();
	Wand_Skulls_Precache();
	Wand_Attackspeed_Map_Precache();
	Wand_Fire_Map_Precache();
	Wand_FireBall_Map_Precache();
	Wand_Lightning_Map_Precache();
	WeaponBoomerang_MapStart();
	Wand_LightningAbility_Map_Precache();
	Wand_Necro_Map_Precache();
	Wand_NerosSpell_Map_Precache();
	Wand_autoaim_Map_Precache();
	Weapon_Arrow_Shoot_Map_Precache();
	Weapon_Hose_Precache();
//	Weapon_Pipe_Shoot_Map_Precache();
	Survival_Knife_Map_Precache();
	Aresenal_Weapons_Map_Precache();
	Uranium_MapStart();
	Wand_Elemental_Map_Precache();
	Wand_Elemental_2_Map_Precache();
	Map_Precache_Zombie_Drops();
	Wand_CalciumSpell_Map_Precache();
	Wand_Calcium_Map_Precache();
//	Wand_Black_Fire_Map_Precache();
	Wand_Chlorophite_Map_Precache();
	MagicRestore_MapStart();
	Wind_Staff_MapStart();
	Nailgun_Map_Precache();
	OnMapStart_NPC_Base();
	Gb_Ball_Map_Precache();
	Map_Precache_Zombie_Drops_Gift();
	Grenade_Custom_Precache();
	Weapon_Tornado_Blitz_Precache();
	BoomStick_MapPrecache();
	MG42_Map_Precache();
	Charged_Handgun_Map_Precache();
	M3_Abilities_Precache();
	Ark_autoaim_Map_Precache();
	Wand_LightningPap_Map_Precache();
	Wand_Cryo_Precache();
	Abiltity_Coin_Flip_Map_Change();
	Wand_Cryo_Precache();
	Vampire_Knives_Precache();
	Fusion_Melee_OnMapStart();
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
	Fractal_Kit_MapStart();
	Casino_MapStart();
	Saga_MapStart();
	Beam_Wand_Pap_OnMapStart();
	Gladiia_MapStart();
	WeaponBoard_Precache();
	Weapon_German_MapStart();
	Weapon_Ludo_MapStart();
	Ion_Beam_Wand_MapStart();
	OnMapStartLeper();
	Flagellant_MapStart();
	Ritualist_MapStart();
	Wand_Impact_Lance_Mapstart();
	Trash_Cannon_Precache();
	Rusty_Rifle_Precache();
	Kit_Blitzkrieg_Precache();
	ResetMapStartRedBladeWeapon();
	Mapstart_Chainsaw();
	Gravaton_Wand_MapStart();
	Reiuji_Wand_OnMapStart();
	Heavy_Particle_Rifle_Mapstart();
	Precache_Railcannon();
	ResetMapStartDimWeapon();
	Hell_Hoe_MapStart();
	ResetMapStartMessengerWeapon();
	ResetMapStartWest();
	Object_MapStart();
	ResetMapStartVictoria();
	Obuch_Mapstart();
	Ulpianus_MapStart();
	Magnesis_Precache();
	Raigeki_Precache();
	Wrathful_Blade_Precache();
	Yakuza_MapStart();
	ResetMapStartSkadiWeapon();
	Logos_MapStart();
	ResetMapStartCastleBreakerWeapon();
	OnMapStartZealot();
	Wkit_Soldin_OnMapStart();
	Purnell_MapStart();
	Kritzkrieg_OnMapStart();
	BubbleWand_MapStart();
	Cheese_MapStart();
	KitOmega_OnMapStart();
	Wand_Sigil_Blade_MapStart();
	PurgeKit_MapStart();
	ResetMapStartExploARWeapon();
	
	Zombies_Currently_Still_Ongoing = 0;
	// An info_populator entity is required for a lot of MvM-related stuff (preserved entity)
//	CreateEntityByName("info_populator");
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	CreateTimer(0.1, GlobalTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	RemoveAllCustomMusic();
	
	ResetMapStartSensalWeapon();
	//This enables the MVM money hud, looks way better.
	//SetVariantString("ForceEnableUpgrades(2)");
	//AcceptEntityInput(0, "RunScriptCode");
	CreateMVMPopulator();
	RoundStartTime = FAR_FUTURE;
	
	for (int i = 0; i < FogType_COUNT; i++)
		CustomFogEntity[i] = INVALID_ENT_REFERENCE;
	
	MapFogEntity = INVALID_ENT_REFERENCE;
}

public void OnMapInit()
{
	if(!Cvar_VshMapFix.BoolValue)
		return;
		//skip
	OnMapInit_ZR();

	//nerf full health kits
	char classname[64];
	int length = EntityLump.Length();
	for(int i; i < length; i++)
	{
		EntityLumpEntry entry = EntityLump.Get(i);
		
		int key = entry.FindKey("classname");
		if(key != -1)
		{
			entry.Get(key, _, _, classname, sizeof(classname));
			if(!StrContains(classname, "item_healthkit_full"))
			{
				entry.Update(key, NULL_STRING, "item_healthkit_medium");
			}
			else if(!StrContains(classname, "tf_logic_arena")
			 || !StrContains(classname, "tf_logic_arena")
			  || !StrContains(classname, "trigger_capture_area"))
			{
				EntityLump.Erase(i);
				i--;
				length--;
			}
		}
	}
}

public Action GlobalTimer(Handle timer)
{
	static int frame;
	frame++;
// Due to how fast spawns are, it has to be on game frame.
//	NPC_SpawnNext(false, false);

	if(frame % 5)
		return Plugin_Continue;
	
	bool ForceMusicStopAndReset = false;
	if(f_AllowInstabuildRegardless && f_AllowInstabuildRegardless < GetGameTime())
	{
		f_AllowInstabuildRegardless = 0.0;
		ForceMusicStopAndReset = true;
	}
	if(Rogue_Mode() || Construction_Mode() || Dungeon_Mode())
	{
		ForceMusicStopAndReset = false;
	}
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(ForceMusicStopAndReset)
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 2);
			}
			else
			{
				Music_Update(client);
			}
		}
	}
	
	if(frame % 20)
		return Plugin_Continue;
	
	Zombie_Delay_Warning();
	Spawners_Timer();
	if(frame % 100)
		return Plugin_Continue;

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			PlayerApplyDefaults(client);
			if(HasSpecificBuff(client, "Dimensional Turbulence"))
			{
				if(IsValidClient(client) && i_HealthBeforeSuit[client] == 0 && TeutonType[client] == TEUTON_NONE)
				{
					for(int i; i<=Ammo_Laser; i++)
					{
						if(i == Ammo_Jar)
							continue;
							
						CurrentAmmo[client][i] = 9999;
						SetAmmo(client, i, 9999);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

void ZR_ClientPutInServer(int client)
{
	b_HasBeenHereSinceStartOfWave[client] = false;
	Queue_PutInServer(client);
	i_AmountDowned[client] = 0;
	if(CurrentModifOn() == 3)
		i_AmountDowned[client] = 1;
	Waves_TrySpawnBarney();
		
	dieingstate[client] = 0;
	TeutonType[client] = 0;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	CashReceivedNonWave[client] = 0;
	Healing_done_in_total[client] = 0;
	i_BarricadeHasBeenDamaged[client] = 0;
	i_PlayerDamaged[client] = 0;
	i_KillsMade[client] = 0;
	i_Backstabs[client] = 0;
	i_Headshots[client] = 0;
	Armor_Charge[client] = 0;
	f_Armor_BreakSoundDelay[client] = 0.0;
	Timer_Knife_Management[client] = null;
	i_CurrentEquippedPerk[client] = 0;
	UpdatePerkName(client);
	i_HealthBeforeSuit[client] = 0;
	i_ClientHasCustomGearEquipped[client] = 0;
	
	Construction_PutInServer(client);
	if(CountPlayersOnServer() == 1)
	{
//		Waves_SetReadyStatus(2);
		//fixes teuton issue hopefully?
		//happens when you loose and instnatly ragequit or something.
		for(int client_summon=1; client_summon<=MaxClients; client_summon++)
		{
			TeutonType[client_summon] = TEUTON_NONE;
		}
	}
	CheckAllClientPrefs(client);

	//if someone joints mid waves, make them buy atleast 70% of the cash before being allowed to play.
	if(!Waves_Started())
		b_AntiLateSpawn_Allow[client] = true;
	else
		b_AntiLateSpawn_Allow[client] = false;

	if(BetWar_Mode())
		b_AntiLateSpawn_Allow[client] = true;
}

void ZR_ClientDisconnect(int client)
{
	Citizen_PlayerReplacement(client);
	Native_ZR_OnGetXP(client, XP[client], 1);
	SetClientTutorialMode(client, false);
	SetClientTutorialStep(client, 0);
	DataBase_ClientDisconnect(client);
	Building_ClientDisconnect(client);
	Queue_ClientDisconnect(client);
	Vehicle_Exit(client, true, false);
	Reset_stats_Irene_Singular(client);
	Reset_stats_PHLOG_Singular(client);
	Reset_stats_Passanger_Singular(client);
	Reset_stats_Survival_Singular(client);
	Reset_stats_LappLand_Singular(client);
	Reset_stats_Mlynar_Singular(client);
	Reset_stats_SpikeLayer_Singular(client);
	Reset_stats_Blemishine_Singular(client);
	Reset_stats_Judge_Singular(client);
	Reset_stats_Drink_Singular(client);
	Reset_stats_Grenade_Singular(client);
	Reset_stats_Skullswand_Singular(client);
	ResetPlayer_BuildingBeingCarried(client);
	b_HasBeenHereSinceStartOfWave[client] = false;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	CashReceivedNonWave[client] = 0;
	Healing_done_in_total[client] = 0;
	Armor_Charge[client] = 0;
	PlayerPoints[client] = 0;
	i_PreviousPointAmount[client] = 0;
	i_ExtraPlayerPoints[client] = 0;
	Timer_Knife_Management[client] = null;
	Escape_DropItem(client, false);
	WoodAmount[client] = 0.0;
	FoodAmount[client] = 0.0;
	GoldAmount[client] = 0.0;
	i_PlayerModelOverrideIndexWearable[client] = -1;
	b_HideCosmeticsPlayer[client] = false;
	UnequipDispenser(client, true);
	//reeset to 0
	Leper_ClientDisconnect(client);
}

public void OnMapInit_ZR()
{
	bool mvm;

	char buffer[64];
	int length = EntityLump.Length();
	for(int i; i < length; i++)
	{
		EntityLumpEntry entry = EntityLump.Get(i);
		
		int index = entry.FindKey("classname");
		if(index != -1)
		{
			entry.Get(index, _, _, buffer, sizeof(buffer));
			delete entry;

			if(StrEqual(buffer, "tf_logic_mann_vs_machine"))
			{
				EntityLump.Erase(i);
				length--;
				mvm = true;
				break;
			}
		}
		else
		{
			delete entry;
		}
	}

	if(mvm)
	{
		for(int i; i < length; i++)
		{
			EntityLumpEntry entry = EntityLump.Get(i);
			
			int index = entry.FindKey("classname");
			if(index != -1)
			{
				entry.Get(index, _, _, buffer, sizeof(buffer));

				if(StrEqual(buffer, "tf_logic_mann_vs_machine") ||
					StrEqual(buffer, "item_teamflag") ||
					StrEqual(buffer, "func_respawnroomvisualizer") ||
					StrEqual(buffer, "func_upgradestation") ||
					StrEqual(buffer, "func_flagdetectionzone") ||
					StrEqual(buffer, "func_nav_prefer") ||
					StrEqual(buffer, "func_nav_avoid") ||
					!StrContains(buffer, "item_healthkit") ||
					!StrContains(buffer, "item_ammopack"))
				{
					EntityLump.Erase(i);
					i--;
					length--;
				}
				else if(StrEqual(buffer, "trigger_multiple"))
				{
					index = entry.FindKey("spawnflags");
					if(index != -1)
					{
						entry.Get(index, _, _, buffer, sizeof(buffer));
						int flags = StringToInt(buffer) | (1 << 1);	// Add NPCs
						IntToString(flags, buffer, sizeof(buffer));
						entry.Update(index, _, buffer);
					}
				}
				else if(StrEqual(buffer, "filter_activator_team") ||
					StrEqual(buffer, "filter_activator_tfteam"))
				{
					// Set team filters for all teams
					index = entry.FindKey("filterteam");
					if(index != -1)
					{
						entry.Update(index, _, "4");
					}

					index = entry.FindKey("TeamNum");
					if(index != -1)
					{
						entry.Update(index, _, "4");
					}

					index = entry.FindKey("Negated");
					if(index != -1)
					{
						entry.Update(index, _, "1");
					}
					else
					{
						entry.Append("Negated", "1");
					}
				}
			}
			
			delete entry;
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


public Action Command_RTdFail(int client, int args)
{
	if(client)
	{
		SPrintToChat(client, "Looks like the dice broke.");
		ClientCommand(client, "playgamesound vo/k_lab/kl_fiddlesticks.wav");
	}
	return Plugin_Handled;
}
public Action Command_AFK(int client, int args)
{
	if(client)
	{
		ForcePlayerSuicide(client);
		UnequipDispenser(client, true);
		WaitingInQueue[client] = true;
		SetTeam(client, 1);
		Queue_ClientDisconnect(client);
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

public Action CommandDebugHudTest(int client, int args)
{
	//What are you.
	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_displayhud <number>");
	        return Plugin_Handled;
	}

	int Number = GetCmdArgInt(1);
	Medival_Wave_Difficulty_Riser(Number);
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

public Action Command_GiveBuff(int client, int args)
{
	//What are you.
	if(args < 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_buff <target> <buffname> <duration>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[128];
	GetCmdArg(2, buf, sizeof(buf));

	char buf2[16];
	GetCmdArg(3, buf2, sizeof(buf2));
	float buffduration = StringToFloat(buf2); 
	

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		PrintToChat(targets[target], "You got the %s buff for %.1f seconds, from the admin %N!", buf, buffduration, client);
		ApplyStatusEffect(targets[target], targets[target], buf, buffduration);
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


public Action Command_SetXp(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_set_xp <target> <cash>");
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
			PrintToChat(targets[target], "Your XP got set to %i from the admin %N!", money, client);
			Native_ZR_OnGetXP(client, money, 1);
			XP[targets[target]] = money;
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
			Native_ZR_OnGetXP(client, money, 0);
			XP[targets[target]] += money;
		}
		else
		{
			PrintToChat(targets[target], "You lost %i XP due to the admin %N!", money, client);
			Native_ZR_OnGetXP(client, money, 0);
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
		WaitingInQueue[client] = true;
		SetTeam(client, 2);
	}
	return Plugin_Handled;
}

public Action Command_SpawnGrigori(int client, int args)
{
	Spawn_Cured_Grigori();
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);
	return Plugin_Handled;
}

public Action Command_PropVehicle(int client, int args)
{
/*
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}

	PrecacheModel("models/buggy.mdl");

	int vehicle = CreateEntityByName("prop_vehicle_driveable");
	
	DispatchKeyValue(vehicle, "model", "models/buggy.mdl");
	DispatchKeyValue(vehicle, "vscripts", "vehicle.nut");
	DispatchKeyValue(vehicle, "vehiclescript", "scripts/vehicles/jeep_test.txt");
	DispatchKeyValue(vehicle, "spawnflags", "1"); // SF_PROP_VEHICLE_ALWAYSTHINK
	DispatchKeyValueVector(vehicle, "origin", flPos);
	DispatchKeyValueVector(vehicle, "angles", flAng);
	SetEntProp(vehicle, Prop_Data, "m_nVehicleType", 0);

	DispatchSpawn(vehicle);
*/
	ReplyToCommand(client, "You probably wanted sm_spawn_npc");
	return Plugin_Handled;
}

public void OnClientAuthorized(int client)
{
	Ammo_Count_Used[client] = 0;
	CashSpentTotal[client] = 0;
	
	if(CurrentRound[Rounds_Default])
	{
		// Give extra cash to newly joined
		int cash = CurrentCash / 20;
		if(StartCash < 750)
			cash += StartCash / 2;
		
		CashSpent[client] = -cash;
		CashReceivedNonWave[client] = cash;
	}
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
				Vehicle_Exit(client);
				if(dieingstate[client] != -5)
				{
					GiveCompleteInvul(client, 2.0);
					EmitSoundToAll("mvm/mvm_revive.wav", client, SNDCHAN_AUTO, 70, _, 0.7);
					MakePlayerGiveResponseVoice(client, 3); //Revived response!
				}
				SetEntityMoveType(client, MOVETYPE_WALK);
				RequestFrame(Movetype_walk, EntRefToEntIndex(client));
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
				DoOverlay(client, "", 2);
				SetEntityHealth(client, 50);
				RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(client));
				Rogue_TriggerFunction(Artifact::FuncRevive, client);
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
						continue;

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
			int HealthRemaining = GetEntProp(client, Prop_Send, "m_iHealth");
			if(HealthRemaining < 210)
			{
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
					
				color[0] = HealthRemaining * 255  / 210; // red  200 is the max health you can have while dying.
				color[1] = HealthRemaining * 255  / 210;	// green
						
				color[0] = 255 - color[0];
			}
			else
			{
				color[0] = 0;
				color[1] = 0;
				color[2] = 255;
				color[3] = 255;
			}

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
						SetVariantString("DOWNED");
						AcceptEntityInput(TextFormat, "SetText");
					}
					else
					{
						SetVariantString("REVIVE");
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
	particle = EntRefToEntIndex(i_DyingParticleIndication[client][2]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	dieingstate[client] = 0;
	SDKHooks_UpdateMarkForDeath(client, true);
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	
	return Plugin_Stop;
}

public void Spawn_Bob_Combine(int client)
{
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	flAng[2] = 0.0;
	int bob = NPC_CreateByName("npc_bob_the_overlord", client, flPos, flAng, TFTeam_Red);
	Bob_Exists = true;
	Bob_Exists_Index = EntIndexToEntRef(bob);
}

public void NPC_Despawn_bob(int entity)
{
	if(IsValidEntity(entity) && entity != 0)
	{
		SmiteNpcToDeath(entity);
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
	int entity = NPC_CreateByName("npc_cured_last_survivor", client, flPos, flAng, TFTeam_Red);
	SalesmanAlive = EntIndexToEntRef(entity);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_grigori");
}

void CheckAlivePlayersforward(int killed=0)
{
	CheckAlivePlayers(killed, _);
}

void CheckLastMannStanding(int killed)
{
	int PlayersLeftNotDowned = 0;
	LastMann_BeforeLastman = false;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
		{
			CurrentPlayers++;
			if(killed != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE/* && dieingstate[client] == 0*/)
			{
				if(dieingstate[client] == 0)
				{
					PlayersLeftNotDowned++;
				}
			}
		}
	}
	if(PlayersLeftNotDowned == 1)
	{
		LastMann_BeforeLastman = true;
	}
}
void CheckAlivePlayers(int killed=0, int Hurtviasdkhook = 0, bool TestLastman = false, int CheckForLastManAlone = 0)
{
	if(!Waves_Started() || Waves_InSetup() || GameRules_GetRoundState() != RoundState_ZombieRiot)
	{
		LastMann = false;
		LastMann_BeforeLastman = false;
		Yakuza_Lastman(0);
		CurrentPlayers = 0;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
			{
				if(!b_AntiLateSpawn_Allow[client])
					continue;
				CurrentPlayers++;
			}
		}
		if(!TestLastman)
			return;
	}
	
	CheckIfAloneOnServer();
	
	bool alive;
	LastMann = true;
	LastMann_BeforeLastman = false;
	CurrentPlayers = 0;
	int PlayersLeftNotDowned = 0;
	int GlobalIntencity_Reduntant;
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
		{
			if(!b_AntiLateSpawn_Allow[client])
				continue;
			CurrentPlayers++;
			if(killed != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE/* && dieingstate[client] == 0*/)
			{
				if(dieingstate[client] > 0)
				{
					GlobalIntencity_Reduntant++;	
				}
				else
				{
					PlayersLeftNotDowned++;
				}
				if(!alive)
				{
					alive = true;
				}
				else if(LastMann)
				{
					LastMann = false;
					Yakuza_Lastman(0);
				}
			}
			else
			{
				GlobalIntencity_Reduntant++;
			}
			
			if(Hurtviasdkhook != 0)
			{
				LastMann_BeforeLastman = true;
				LastMann = true;
				LastMannScreenEffect = false;
			}
		}
	}
	/*
		This is so the last person alive, who is not dead, but not downed
		i.e. last man up
		PlayersLeftNotDowned

	*/
	if(LastMann && !GlobalIntencity_Reduntant) //Make sure if they are alone, it wont play last man music.
	{
		//if its above 700, it just assumes we triggered lastman
		if(i_AmountDowned[CheckForLastManAlone] < 700)
		{
			PlayersLeftNotDowned = 99;
			LastMann_BeforeLastman = false;
			LastMann = false;
		}
	}

	if(PlayersLeftNotDowned == 1)
	{
		LastMann_BeforeLastman = true;
	}

	if(TestLastman)
	{
		LastMann = true;
		LastMannScreenEffect = false;
		applied_lastmann_buffs_once = false;
	}

	if(LastMann)
	{
		static bool Died[MAXPLAYERS];
		for(int client=1; client<=MaxClients; client++)
		{
			Died[client] = false;
			if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
			{
				if(!b_AntiLateSpawn_Allow[client])
					continue;
				if((killed != client || Hurtviasdkhook != client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] > 0)
				{
					Died[client] = true;
					SDKHooks_TakeDamage(client, client, client, 99999.0, DMG_TRUEDAMAGE, _, _, _, true);
					ForcePlayerSuicide(client);
				}
			}
		}

		if(Rogue_NoLastman())
		{
			LastMann = false;
		}
		else
		{
			if(!applied_lastmann_buffs_once)
			{
				CauseFadeInAndFadeOut(0,1.0,1.0,1.0, "235");
				PlayTeamDeadSound();
				Zero(delay_hud); //Allow the hud to immedietly update
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
					{
						FreezeNpcInTime(entity, 3.0, true);
						IncreaseEntityDamageTakenBy(entity, 0.000001, 3.0);
					}
				}
				RaidModeTime += 3.0;
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
							SDKCall_SetSpeed(client);
							int entity, i;
							while(TF2U_GetWearable(client, entity, i))
							{
								if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
									continue;

								SetEntityRenderMode(entity, RENDER_NORMAL);
								SetEntityRenderColor(entity, 255, 255, 255, 255);
							}
							SetEntityRenderMode(client, RENDER_NORMAL);
							SetEntityRenderColor(client, 255, 255, 255, 255);
							SetEntityCollisionGroup(client, 5);
						}

						if(Yakuza_IsNotInJoint(client))
						{
							Yakuza_AddCharge(client, 99999);
							Yakuza_Lastman(1);
							CPrintToChatAll("{crimson}Something awakens inside %N.......",client);
						}
						if(Zealot_Sugmar(client))
						{
							Yakuza_Lastman(2);
							CPrintToChatAll("{crimson}%N descended into a fanatical worship of Sigmar, and set out to cleanse the unrighteous themselves.",client);
						}
						if(Fractal_LastMann(client))
						{
							//get some cool line.
							Max_Fractal_Crystals(client);
							CPrintToChatAll("{purple}Twirl{crimson}'s Essence enters %N...",client);
							Yakuza_Lastman(3);
						}
						if(Wkit_Soldin_LastMann(client))
						{
							ChargeSoldineMeleeHit(client,client,true, 999.9);
							ChargeSoldineRocketJump(client, client, true, 999.9);
							CPrintToChatAll("{crimson}Expidonsa Activates %N's emergency protocols...",client);
							Yakuza_Lastman(4);
						}
						if(Purnell_Lastman(client))
						{
							CPrintToChatAll("{crimson}%N gets filled with the unyielding desire to avenge his patients.",client);
							Yakuza_Lastman(5);
						}
						if(Blacksmith_Lastman(client))
						{
							CPrintToChatAll("{crimson}%N Seems to be completly and utterly screwed.",client);
							Yakuza_Lastman(6);
						}
						if(BlitzKit_LastMann(client))
						{
							CPrintToChatAll("{crimson}The Machine Within %N screams: FOR VICTORY",client);
							Yakuza_Lastman(7);
						}
						if(IsFlaggilant(client) || IsClientLeper(client))
						{
							if(IsFlaggilant(client))
								CPrintToChatAll("{crimson}The undying soul %N refuses to ever die.",client);
							else if(IsClientLeper(client))
								CPrintToChatAll("{crimson}The King %N cannot stand this any longer..!",client);
								
							int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
							if(weapon != -1)
							{
								Saga_ChargeReduction(client, weapon, 999.9);
							}
							Yakuza_Lastman(8);
						}
						if(SeaMelee_IsSeaborn(client))
						{
							CPrintToChatAll("{crimson}The sea entirely corrupts %N.",client);
							Yakuza_Lastman(9);
						}
						if(Merchant_IsAMerchant(client))
						{
							CPrintToChatAll("{crimson}The merchant knows not who to trade with... Thus massively enrages.",client);
							Yakuza_Lastman(10);
						}
						if(Is_Cheesed_Up(client))
						{
							CPrintToChatAll("{darkviolet}%N decides to inject themselves with plasma as a last resort...", client);
							Yakuza_Lastman(11);
						}
						/*
						if(Sigil_LastMann(client))
						{
							CPrintToChatAll("{blue}Diabolus Ex Machina.",client);
							Yakuza_Lastman(12);
						}
						*/
						if(Wkit_Omega_LastMann(client))
						{
							CPrintToChatAll("{gold}%N is now alone, however giving up isn't in their vocabulary.",client);
							Yakuza_Lastman(13);
						}
						if(PurgeKit_LastMann(client))
						{
							CPrintToChatAll("{crimson}%N's purging protocol activates.",client);
							Yakuza_Lastman(14);
						}
						
						for(int i=1; i<=MaxClients; i++)
						{
							if(IsClientInGame(i) && !IsFakeClient(i))
							{
								if(!BlockLastmanMusicRaidboss(i))
								{
									Music_Stop_All(i);
									SetMusicTimer(i, GetTime() + 2); //give them 2 seconds, long enough for client predictions to fade.
								}
								SetEntPropEnt(i, Prop_Send, "m_hObserverTarget", client);
							}
						}
						
						/*
						for(int i=1; i<=MaxClients; i++)
						{
							if(IsClientInGame(i) && !IsFakeClient(i))
							{
								SendConVarValue(i, sv_cheats, "1");
							}
						}
						
						cvarTimeScale.SetFloat(0.1);
						CreateTimer(0.3, SetTimeBack);
						*/
					
						applied_lastmann_buffs_once = true;
						
						SetHudTextParams(-1.0, -1.0, 3.0, 255, 0, 0, 255);
						if(b_IsAloneOnServer)
							ShowHudText(client, -1, "%T", "Last Alive Alone", client);
						else
							ShowHudText(client, -1, "%T", "Last Alive", client);

						int MaxHealth;
						MaxHealth = SDKCall_GetMaxHealth(client) * 2;
						if(b_IsAloneOnServer)
							MaxHealth /= 2;
							
						if(i_HealthBeforeSuit[client] == 0)
						{
							SetEntProp(client, Prop_Send, "m_iHealth", MaxHealth);
						}
						//if in quantum suit, dont.

						int Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);
						if(b_IsAloneOnServer)
							Armor_Max /= 2;

						Armor_Charge[client] = Armor_Max;
						GiveCompleteInvul(client, 3.0);
					}
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

		bool rogue = Rogue_Mode();
		if(rogue)
			rogue = !Rogue_BattleLost();
	
		if(!rogue)
		{
			ForcePlayerLoss(false);
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
public void SetHealthAfterReviveRaid(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		RequestFrame(SetHealthAfterReviveRaidAgain, ref);	
	}
}

public void SetHealthAfterReviveRaidAgain(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		RequestFrame(SetHealthAfterReviveRaidAgainAgain, ref);	
	}
}

public void SetHealthAfterReviveRaidAgainAgain(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{	
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
	}
}
//Revival raid spam

//Set hp spam after normal revive
public void SetHealthAfterRevive(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{	
		RequestFrame(SetHealthAfterReviveAgain, ref);	
	}
}

public void SetHealthAfterReviveAgain(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		SetEntityHealth(client, 50);
	}
}

//Set hp spam after normal revive

stock void UpdatePlayerPoints(int client)
{
	int Points;
	
	Points += Healing_done_in_total[client] / 3;

	if(Rogue_Mode())
	{
		Points += RoundToCeil(Damage_dealt_in_total[client]) / 250;
	}
	else
	{
		Points += RoundToCeil(Damage_dealt_in_total[client]) / 50;
	}

	i_Damage_dealt_in_total[client] = RoundToCeil(Damage_dealt_in_total[client]);
	
	Points += Resupplies_Supplied[client] * 2;
	
	Points += i_BarricadeHasBeenDamaged[client] / 5;

	if(Rogue_Mode())
	{
		Points += i_PlayerDamaged[client] / 10;
	}
	else
	{
		Points += i_PlayerDamaged[client] / 5;
	}
	
	Points += i_ExtraPlayerPoints[client] / 2;
	
	Points /= 10;
	
	PlayerPoints[client] = Points;	// Do stuff here :)
}

stock int MaxArmorCalculation(int ArmorLevel = -1, int client, float multiplyier)
{
	if(ArmorLevel == -1)
	{
		ArmorLevel = RoundToNearest(Attributes_GetOnPlayer(client, 701, false));
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

	else if(ArmorLevel == 250)
		Armor_Max = 3000;
		
	else
		Armor_Max = 200;

	if(i_CurrentEquippedPerk[client] & PERK_STOCKPILE_STOUT)
	{
		Armor_Max = RoundToCeil(float(Armor_Max) * 1.5);
	}
		
	return (RoundToCeil(float(Armor_Max) * multiplyier));
	
}

float f_IncrementalSmallArmor[MAXENTITIES];
stock void GiveArmorViaPercentage(int client, float multiplyier, float MaxMulti, bool flat = false, bool HealCorrosion = false, int ArmorGiver = -1)
{
	int Armor_Max;
	
	Armor_Max = MaxArmorCalculation(Armor_Level[client], client, MaxMulti);
	float ArmorToGive;
	if(Armor_Charge[client] < Armor_Max)
	{
		if(flat)
		{
			int i_TargetHealAmount; //Health to actaully apply

			if (multiplyier <= 1.0 && multiplyier > 0.0)
			{
				f_IncrementalSmallArmor[client] += multiplyier;
					
				if(f_IncrementalSmallArmor[client] >= 1.0)
				{
					f_IncrementalSmallArmor[client] -= 1.0;
					i_TargetHealAmount = 1;
				}
			}
			else
			{
				if(i_TargetHealAmount < 0.0) //negative heal
				{
					i_TargetHealAmount = RoundToFloor(multiplyier);
				}
				else
				{
					i_TargetHealAmount = RoundToFloor(multiplyier);
				
					float Decimal_healing = FloatFraction(multiplyier);
										
										
					f_IncrementalSmallArmor[client] += Decimal_healing;
										
					while(f_IncrementalSmallArmor[client] >= 1.0)
					{
						f_IncrementalSmallArmor[client] -= 1.0;
						i_TargetHealAmount += 1;
					}
				}		
			}
			ArmorToGive = float(i_TargetHealAmount);
				
		}
		else
		{
			ArmorToGive = float(Armor_Max) * multiplyier;
		}
			
		if(FullMoonIs(client) && !HealCorrosion)
		{
			if(dieingstate[client] == 0)
				HealEntityGlobal(client, client, ArmorToGive * 0.5, 1.0,_,HEAL_SELFHEAL);
			return;
		}
		Armor_Charge[client] += RoundToNearest(ArmorToGive);
		if(HealCorrosion)
		{
			if(Armor_Charge[client] >= 0)
			{
				Armor_Charge[client] = 0;
			}
		}
		if(Armor_Charge[client] >= Armor_Max)
		{
			Armor_Charge[client] = Armor_Max;
		}
	}

	if(ArmorGiver > 0 && ArmorToGive > 0.0)
	{
		ApplyArmorEvent(client, RoundToNearest(ArmorToGive), ArmorGiver);
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
	if((i_CurrentEquippedPerk[client] & PERK_STOCKPILE_STOUT) && !ignoreperk)
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

public Action ZR_CheckValidityOfPostions_OfObjects(Handle timer,bool recheck)
{
	ZR_CheckValidityOfPostions_OfObjectsInternal(recheck);
	return Plugin_Stop;
}
void ZR_CheckValidityOfPostions_OfObjectsInternal(bool recheck)
{
	//if in setup, keep checking.
	if(Waves_InSetup() && recheck)
		CreateTimer(5.0, ZR_CheckValidityOfPostions_OfObjects, true, TIMER_FLAG_NO_MAPCHANGE);

	float pos2[3];
	for(int iEntity; iEntity<i_MaxcountBuilding; iEntity++) //BUILDINGS!
	{
		//check if they are in any type of invalid pos, maybe outside of map, or moreso, inside a kill trigger due to map changes!
		int iObj = EntRefToEntIndexFast(i_ObjectsBuilding[iEntity]);
		if(!IsValidEntity(iObj))
			continue;

		GetEntPropVector(iObj, Prop_Data, "m_vecAbsOrigin", pos2);
		if(!IsBoxHazard(pos2, f3_CustomMinMaxBoundingBoxMinExtra[iObj], f3_CustomMinMaxBoundingBox[iObj]))
			continue;
		if(Building_Mounted[iObj] != -1)
			continue;
		//Make sure that mounted buildings are never deleted like this!
			
		int builder_owner = GetEntPropEnt(iObj, Prop_Send, "m_hOwnerEntity");
		DeleteAndRefundBuilding(builder_owner, iObj);
	}
	
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(b_NpcHasDied[entity])
			continue;
		if(!Citizen_IsIt(entity))
			continue;

		Citizen npc = view_as<Citizen>(entity);
		if(npc.m_nDowned && npc.m_iWearable3 > 0)
		{
			
		}
		else
			continue;

		npc.SetDowned(false);
		if(Waves_InSetup())
			continue;
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
void ReviveAll(bool raidspawned = false, bool setmusicfalse = false, bool ForceFullHealth = false)
{
	//only set false here
	if(!setmusicfalse)
		ZombieMusicPlayed = setmusicfalse;

	ZR_CheckValidityOfPostions_OfObjectsInternal(true);
	CreateTimer(1.0, ZR_CheckValidityOfPostions_OfObjects, false, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(5.0, ZR_CheckValidityOfPostions_OfObjects, false, TIMER_FLAG_NO_MAPCHANGE);
	//needed for map logic!

	for(int client=1; client<=MaxClients; client++)
	{
		CheckClientLateJoin(client, false);
		bool ClientWasInWave = false;
		if(b_HasBeenHereSinceStartOfWave[client])
			ClientWasInWave = true;
		b_HasBeenHereSinceStartOfWave[client] = false;
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
				SDKCall_SetSpeed(client);
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
						continue;

					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
			}
			ForcePlayerCrouch(client, false);
			//just make visible.
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);

			if(i_AmountDowned[client] > 0)
				i_AmountDowned[client] = 0;
			if(CurrentModifOn() == 3)
				i_AmountDowned[client] = 1;

			DoOverlay(client, "", 2);
			if(raidspawned)
				if(!ClientWasInWave)
					continue;
					
			if(!b_AntiLateSpawn_Allow[client])
				continue;
			if(GetClientTeam(client)==2)
			{
				if(TeutonType[client] != TEUTON_WAITING)
				{
					b_HasBeenHereSinceStartOfWave[client] = true;
				}
				if((!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD))
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
					SDKCall_SetSpeed(client);
					int entity, i;
					while(TF2U_GetWearable(client, entity, i))
					{
						if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
							continue;
							
						SetEntityRenderMode(entity, RENDER_NORMAL);
						SetEntityRenderColor(entity, 255, 255, 255, 255);
					}
					SetEntityRenderMode(client, RENDER_NORMAL);
					SetEntityRenderColor(client, 255, 255, 255, 255);
					SetEntityCollisionGroup(client, 5);
					if(!raidspawned && !ForceFullHealth)
					{
						SetEntityHealth(client, 50);
						RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(client));
					}
				}
				if(raidspawned || ForceFullHealth)
				{
					if(GetEntProp(client, Prop_Data, "m_iHealth") <= SDKCall_GetMaxHealth(client))
					{
						SetEntityHealth(client, SDKCall_GetMaxHealth(client));
						RequestFrame(SetHealthAfterReviveRaid, EntIndexToEntRef(client));	
					}
				}
			}
			CreateTimer(0.1, Timer_ChangePersonModel, GetClientUserId(client));
		}
	}
	
	Music_EndLastmann();
	CheckAlivePlayers();
}

float XpFloatGive[MAXPLAYERS];

void GiveXP(int client, int xp, bool freeplay = false, bool SetXpAndLevelSilently = false)
{
	if(Waves_InFreeplay() && !freeplay)
	{
		//no xp in freeplay.
		return;
	}

	float DecimalXp = float(xp);

	if(!SetXpAndLevelSilently)
	{
		DecimalXp *= CvarXpMultiplier.FloatValue;
		
		if(DecimalXp >= 10000.0)
		{
			//looks like someone got a bullshit amount of points somehow, ignore!
			return;
		}
	}
	
	XpFloatGive[client] += DecimalXp;
	
	int XpGive = 0;
	XpGive = RoundToFloor(DecimalXp);

	XpFloatGive[client] += FloatFraction(DecimalXp);

	while(XpFloatGive[client] >= 1.0)
	{
		XpFloatGive[client] -= 1.0;
		XpGive += 1;
	}

	XP[client] += XpGive;
	Native_ZR_OnGetXP(client, XpGive, 0);

	int nextLevel = XpToLevel(XP[client]);
	if(nextLevel > Level[client])
	{
		if(CvarLeveling.BoolValue)
		{
			if(!SetXpAndLevelSilently && Level[client] < STARTER_WEAPON_LEVEL)
			{
				static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
				ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);

				int maxhealth = SDKCall_GetMaxHealth(client) * 4 / 3;
				if(GetClientHealth(client) < maxhealth)
					SetEntityHealth(client, maxhealth);
			}
			
			
			while(Level[client] < nextLevel)
			{
				Level[client]++;

				if(!SetXpAndLevelSilently)
				{
					if(Level[client] == STARTER_WEAPON_LEVEL)
					{
						CPrintToChat(client, "%t", "All Weapons Unlocked");
					}
					
					Store_PrintLevelItems(client, Level[client]);
				}
			}
			PrintToChat(client, "%T", "Level Up",client, Level[client]);
			if(!SetXpAndLevelSilently && CvarSkillPoints.BoolValue && Level[client] >= STARTER_WEAPON_LEVEL)
			{
				SkillTree_CalcSkillPoints(client);
				CPrintToChat(client, "%T", "Current Skill Points",client, SkillTree_UnspentPoints(client));
			}
		}
	}
}

void PlayerApplyDefaults(int client)
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
		CheckAllClientPrefs(client);
		int point_difference = PlayerPoints[client] - i_PreviousPointAmount[client];
		
		if(point_difference > 0)
		{
			//Too much xp given, we have to reduce it by 10x
			GiveXP(client, point_difference / 5);
		}
		
		i_PreviousPointAmount[client] = PlayerPoints[client];
    }
}

void CheckAllClientPrefs(int client)
{
	QueryClientConVar(client, "snd_musicvolume", ConVarCallback); //cl_showpluginmessages
	QueryClientConVar(client, "hud_combattext", ConVarCallback_DamageNumbers); //cl_showpluginmessages
	QueryClientConVar(client, "cl_first_person_uses_world_model", ConVarCallback_FirstPersonViewModel);

	if(f_BegPlayerToSetRagdollFade[client] != FAR_FUTURE && f_BegPlayerToSetRagdollFade[client] < GetGameTime())
	{
		f_BegPlayerToSetRagdollFade[client] = GetGameTime() + 15.0;
		QueryClientConVar(client, "g_ragdoll_fadespeed", ConVarCallback_g_ragdoll_fadespeed);
	}

	if(f_BegPlayerR_TeethSet[client] != FAR_FUTURE && f_BegPlayerR_TeethSet[client] < GetGameTime())
	{
		f_BegPlayerR_TeethSet[client] = GetGameTime() + (60.0 * 20.0); //every 20 minutes.
		QueryClientConVar(client, "r_teeth", ConVarCallback_r_teeth);
	}
}

float GetClientSaveUberGametime[MAXPLAYERS];
float GetClientSaveRageGametime[MAXPLAYERS];

void ClientSaveUber(int client)
{
	if(GetClientSaveUberGametime[client] == GetGameTime())
		return;

	GetClientSaveUberGametime[client] = GetGameTime();
	int ie;
	int entity;
	while(TF2_GetItem(client, entity, ie))
	{
		int index = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 411:
			{
				if(b_IsAMedigun[entity])
				{
					f_MedigunChargeSave[client][0] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
				}
			}
			case 211:
			{
				if(b_IsAMedigun[entity])
				{
					f_MedigunChargeSave[client][1] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
				}
			}
			case 998:
			{
				if(b_IsAMedigun[entity])
				{
					f_MedigunChargeSave[client][2] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
				}
			}
		}
	}
}

void ClientApplyMedigunUber(int client)
{
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 411:
			{
				if(b_IsAMedigun[weapon])
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][0]);
					f_MedigunChargeSave[client][0] = 0.0;
				}
			}
			case 211:
			{
				if(b_IsAMedigun[weapon])
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][1]);
					f_MedigunChargeSave[client][1] = 0.0;
				}
			}
			case 998:
			{
				if(b_IsAMedigun[weapon])
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][2]);
					f_MedigunChargeSave[client][2] = 0.0;
				}
			}
		}
	}
}
void ClientSaveRageMeterStatus(int client)
{
	if(GetClientSaveRageGametime[client] == GetGameTime())
		return;

	GetClientSaveRageGametime[client] = GetGameTime();

	if(GetEntProp(client, Prop_Send, "m_bRageDraining"))
		f_SaveBannerRageMeter[client][0] = 1.0;
	else
		f_SaveBannerRageMeter[client][0] = 0.0;

	float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter");
	f_SaveBannerRageMeter[client][1] = rage;
}

void ClientApplyRageMeterStatus(int client)
{
	//Must delay for a frame, it gets applied later and im way too lazy to figure out what exact function it comes after
	//for refference, medigun for example works on this frame.
	RequestFrame(ClientApplyRageMeterStatusDelay, EntIndexToEntRef(client));
}

void ClientApplyRageMeterStatusDelay(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return;

	bool NoBanner = true;
	int Bufftype = 0;
	int ie, weapon;
	SetEntProp(client, Prop_Send, "m_bRageDraining", view_as<int>(f_SaveBannerRageMeter[client][0]));
	SetEntPropFloat(client, Prop_Send, "m_flRageMeter", f_SaveBannerRageMeter[client][1]);
	while(TF2_GetItem(client, weapon, ie))
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_ANCIENT_BANNER, WEAPON_BATTILONS, WEAPON_BUFF_BANNER:
			{
				Bufftype = RoundToNearest(Attributes_Get(weapon, 116, 0.0));
				NoBanner = false;
			}
		}
	}
	if(!NoBanner && view_as<bool>(f_SaveBannerRageMeter[client][0]))
	{
		Handle pack;
		CreateDataTimer(0.1, DeployBannerIconBuff, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, Bufftype);
	}
}

public Action DeployBannerIconBuff(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int Bufftype = pack.ReadCell();
	if(IsValidClient(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
	{
		if(GetEntProp(client, Prop_Send, "m_bRageDraining"))
		{
			Event event = CreateEvent("deploy_buff_banner", true);
			event.SetInt("buff_type", Bufftype);
			event.SetInt("buff_owner", GetClientUserId(client));
			event.Fire();
		}
	}
	return Plugin_Stop;
}

stock int GetClientPointVisibleRevive(int iClient, float flDistance = 100.0)
{
	float vecOrigin[3], vecAngles[3], vecEndOrigin[3];
	GetClientEyePosition(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngles);
	
	if(f_Reviving_This_Client[iClient] < GetGameTime())
	{
		i_Reviving_This_Client[iClient] = 0;
	}

	Handle hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, Trace_DontHitAlivePlayer, iClient);
	TR_GetEndPosition(vecEndOrigin, hTrace);
	
	int iReturn = -1;
	int iHit = TR_GetEntityIndex(hTrace);
	
	if (TR_DidHit(hTrace) && iHit != iClient && GetVectorDistance(vecOrigin, vecEndOrigin, true) < (flDistance * flDistance))
		iReturn = iHit;

	if(iReturn > 0)
	{
		i_Reviving_This_Client[iClient] = iReturn;
		f_Reviving_This_Client[iClient] = GetGameTime() + 0.35;
	}
	else
	{
		i_Reviving_This_Client[iClient] = 0;
		f_Reviving_This_Client[iClient] = 0.0;
	}
	
	delete hTrace;
	return iReturn;
}

stock bool isPlayerMad(int client) {

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == -1)
		return false;

	if (i_CustomWeaponEquipLogic[weapon_holding] == WEAPON_HELL_HOE_3) {

		int clientMaxHp = SDKCall_GetMaxHealth(client);
		int health = GetClientHealth(client);
		if (health >= clientMaxHp/2)
			return false;

		return true;
	}
	/*
	else if (i_CustomWeaponEquipLogic[weapon_holding] == WEAPON_HELL_HOE_2) {
		return g_isPlayerInDeathMarch_HellHoe[client];
	}
	*/
	return false;
}

bool PlayerIsInNpcBattle(int client, float ExtradelayTime = 0.0)
{
	bool InBattle = false;
	if(f_InBattleHudDisableDelay[client] > (GetGameTime() + ExtradelayTime))
		InBattle = true;

	return InBattle;
}


void ForcePlayerWin(bool fakeout = false)
{
	bool PlayNormalMusic = false;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && IsClientInGame(client) && !IsFakeClient(client))
		{
			Music_Stop_All(client);
			SetMusicTimer(client, GetTime() + 33);
			SendConVarValue(client, sv_cheats, "1");
			Convars_FixClientsideIssues(client);
			if(MusicWin.PlayMusic(client))
				PlayNormalMusic = false;
		}
	}
	if(!fakeout)
		ResetReplications();

	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);
	if(PlayNormalMusic)
		EmitCustomToAll("#zombiesurvival/music_win_1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);


	if(!fakeout)
	{
		MusicString1.Clear();
		MusicString2.Clear();
		MusicSetup1.Clear();
		MusicLastmann.Clear();
		MusicWin.Clear();
		MusicLoss.Clear();
		RaidMusicSpecial1.Clear();
		MVMHud_Disable();
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Red);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		RemoveAllCustomMusic();
		Native_ZR_OnWinTeam(TFTeam_Red);
	}
}

void ForcePlayerLoss(bool WasRaid = true)
{
	if(WasRaid)
	{
		if(Rogue_Mode())
		{
			
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client)==2 && IsPlayerAlive(client))
				{
					ForcePlayerSuicide(client);
				}
			}
			//KILL all players instead
			return;
		}
	}
	MVMHud_Disable();
	ZR_NpcTauntWin();
	ZR_NpcTauntWinClear();
	int entity = CreateEntityByName("game_round_win"); 
	DispatchKeyValue(entity, "force_map_reset", "1");
	SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "RoundWin");
	Music_RoundEnd(entity);
	RaidBossActive = INVALID_ENT_REFERENCE;
	Native_ZR_OnWinTeam(TFTeam_Blue);
	
	MusicString1.Clear();
	MusicString2.Clear();
	MusicSetup1.Clear();
	MusicLastmann.Clear();
	MusicWin.Clear();
	MusicLoss.Clear();
	RaidMusicSpecial1.Clear();
}



stock void SPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, "%s%s", STORE_PREFIX, buffer);
}
stock void SPrintToChatAll(const char[] message, any ...)
{
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 2);
	CPrintToChatAll("%s%s", STORE_PREFIX, buffer);
}


//IF you disable ingame downloads, it will download all these files nontherless!
void ZR_FastDownloadForce()
{
	//do not download!!
	if(FileNetwork_Enabled())
		return;

	PrecacheSharedDarkestMusic();
	PrecacheTwirlMusic();
	SeaBornMusicDo();
	PurnellMusicOst();
	PrecacheBlitzMusic();
	SoldineKitDownload();
	ZealotMusicDownload();
	YakuzaMusicDownload();
	FullmoonDownload();
	Cheese_PrecacheMusic();
	Core_PrecacheGlobalCustom();
	PrecacheMusicZr();
}



public Action Command_SetTeamCustom(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_forceset_team <target> <team (above 4)>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[12];
	GetCmdArg(2, buf, sizeof(buf));
	int teamset = StringToInt(buf); 
	
	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		PrintToChatAll("target %i, TeamSet %i",targets[target], teamset);
		SetTeam(targets[target], teamset);
	}
	
	return Plugin_Handled;
}

void SetCustomFog(int fogType, int color1[4], int color2[4], float start, float end, float maxDensity, int blend = 2, bool overwriteOtherCustomFog = false)
{
	if (!overwriteOtherCustomFog && IsValidEntity(CustomFogEntity[fogType]))
		return;
	
	ClearCustomFog(fogType);
	
	if (!IsValidEntity(MapFogEntity))
	{
		int fog = INVALID_ENT_REFERENCE;
		int mapFog = INVALID_ENT_REFERENCE;
		int count;
		while ((fog = FindEntityByClassname(fog, "env_fog_controller")) != INVALID_ENT_REFERENCE)
		{
			// Store the last known fog
			char buffer[64];
			GetEntPropString(fog, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if (StrContains(buffer, "rpg_fortress_envfog") == 0)
				continue;
			
			mapFog = fog;
			count++;
		}
		
		if (count == 0)
		{
			// Map has no fog
			MapFogEntity = INVALID_ENT_REFERENCE;
		}
		else if (count == 1)
		{
			// We only found 1 env_fog_controller, this has to be the map's
			MapFogEntity = mapFog;
		}
		else
		{
			// Multiple fog controllers! If every single player has the same fog controller, we'll assume this is the one we want to store
			int lastController = INVALID_ENT_REFERENCE;
			for (int client = 1; client <= MaxClients; client++)
			{
				if (!IsClientInGame(client) || IsFakeClient(client))
					continue;
				
				int controller = GetEntPropEnt(client, Prop_Send, "m_PlayerFog.m_hCtrl");
				if (controller == EntRefToEntIndex(ActiveFogEntity))
				{
					// Players are using a custom fog so this is pointless. gg
					lastController = INVALID_ENT_REFERENCE;
					break;
				}
				
				if (lastController != INVALID_ENT_REFERENCE && lastController != controller)
				{
					// Players have different controllers. Give up. It's over
					lastController = INVALID_ENT_REFERENCE;
					break;
				}
				
				lastController = controller;
			}
			
			MapFogEntity = lastController;
		}
	}
	
	int entity = CreateEntityByName("env_fog_controller");
	if (entity != INVALID_ENT_REFERENCE)
	{
		char buffer[64];
		
		FormatEx(buffer, sizeof(buffer), "rpg_fortress_envfog_%d", entity);
		DispatchKeyValue(entity, "targetname", buffer);
		
		FormatEx(buffer, sizeof(buffer), "%d %d %d %d", color1[0], color1[1], color1[2], color1[3]);
		DispatchKeyValue(entity, "fogcolor", buffer);
		
		FormatEx(buffer, sizeof(buffer), "%d %d %d %d", color2[0], color2[1], color2[2], color2[3]);
		DispatchKeyValue(entity, "fogcolor2", buffer);
		
		DispatchKeyValueFloat(entity, "fogstart", start);
		DispatchKeyValueFloat(entity, "fogend", end);
		DispatchKeyValueFloat(entity, "fogmaxdensity", maxDensity);
		
		DispatchKeyValueInt(entity, "fogblend", blend);
		
		DispatchKeyValue(entity, "fogenable", "1");
		DispatchKeyValue(entity, "spawnflags", "1");
		DispatchKeyValue(entity, "fogRadial", "1");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "TurnOn");

		CustomFogEntity[fogType] = EntIndexToEntRef(entity);
		UpdateCustomFog();
	}
}

void ClearCustomFog(int fogType)
{
	int entity = EntRefToEntIndex(CustomFogEntity[fogType]);
	if (IsValidEntity(entity))
		RemoveEntity(entity);
	
	CustomFogEntity[fogType] = INVALID_ENT_REFERENCE;
	UpdateCustomFog();
}

void UpdateCustomFog()
{
	int fogToUse = INVALID_ENT_REFERENCE;
	if (IsValidEntity(CustomFogEntity[FogType_NPC]))
	{
		fogToUse = CustomFogEntity[FogType_NPC];
		ActiveFogEntity = fogToUse;
	}
	else if (IsValidEntity(CustomFogEntity[FogType_Wave]))
	{
		fogToUse = CustomFogEntity[FogType_Wave];
		ActiveFogEntity = fogToUse;
	}
	else if (IsValidEntity(MapFogEntity))
	{
		fogToUse = MapFogEntity;
		
		// This is cleared because it's only used when necessary (maps might have multiple entities)
		MapFogEntity = INVALID_ENT_REFERENCE;
		ActiveFogEntity = INVALID_ENT_REFERENCE;
	}
	else
	{
		ActiveFogEntity = INVALID_ENT_REFERENCE;
	}
	
	if (fogToUse == INVALID_ENT_REFERENCE)
		return;
	
	int entity = EntRefToEntIndex(fogToUse);
	char buffer[64];
	GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
	if (buffer[0] == '\0')
	{
		// Give the controller a name if it has none. If it has no name, there's no point in changing it back
		buffer = "mapfog";
		SetEntPropString(entity, Prop_Data, "m_iName", buffer);
	}
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			SetVariantString(buffer);
			AcceptEntityInput(client, "SetFogController");
		}
	}
}

void ShowCustomFogToClient(int client)
{
	if (!IsValidEntity(ActiveFogEntity))
		return;
	
	// This is used on late joins for specific clients, use UpdateCustomFog to update globally
	int entity = EntRefToEntIndex(ActiveFogEntity);
	char buffer[64];
	GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer)); // By this point, this should always have a name
	
	SetVariantString(buffer);
	AcceptEntityInput(client, "SetFogController");
}
