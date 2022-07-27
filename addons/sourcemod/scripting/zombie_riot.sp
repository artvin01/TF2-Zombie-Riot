#pragma semicolon 1

#include <tf2>
#include <collisionhook>
#include <sourcemod>
#include <clientprefs>
#include <tf2_stocks>
#include <sdkhooks>
#include <dhooks>
#include <tf2items>
#include <tf_econ_data>
#include <tf2attributes>
#include <lambda>
#include <PathFollower>
#include <PathFollower_Nav>
#include <morecolors>

//#include <studio_hdr>
#undef REQUIRE_PLUGIN
#include <minecraft_tf2>
#include <textstore>

	
#tryinclude <menus-controller>


#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

#define NPC_HARD_LIMIT 42 
#define ZR_MAX_NPCS (NPC_HARD_LIMIT*2)
#define ZR_MAX_NPCS_ALLIED 64
#define ZR_MAX_BUILDINGS 128
#define ZR_MAX_TRAPS 64
#define ZR_MAX_BREAKBLES 32
#define ZR_MAX_SPAWNERS 64

// THESE ARE TO TOGGLE THINGS!

#define LagCompensation

#define HaveLayersForLagCompensation

//Not used cus i need all the performance i can get.

#define NoSendProxyClass

//#define DisableInterpolation

//maybe doing this will help lag, as there are no aim layers in zombies, they always look forwards no matter what.

//edit: No, makes you miss more often.


//Comment this out, and reload the plugin once ingame if you wish to have infinite cash.


ConVar CvarNoRoundStart;
ConVar CvarDisableThink;
ConVar CvarInfiniteCash;
ConVar CvarNoSpecialZombieSpawn;
ConVar CvarEnablePrivatePlugins;
ConVar CvarMaxBotsForKillfeed;
ConVar CvarXpMultiplier;

bool Toggle_sv_cheats = false;
#define CompensatePlayers

//#define FastStart

// THESE ARE TO TOGGLE THINGS!


//MOST THINGS ARE HARDCODED TO BLUE AND RED!!!! REASON IS COLLISSION ISSUES WITH BASEBOSS AND OTHER STUFF!
//If you can make it cross team work then be my guest but i seriously cannot see a way to do this without 5x the effort.

//RED: Humans
//BLUE: Enemy zombies

//some zombies are on red.


//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!

/*
	THIS CODE IS COMPRISED OF MULTIPLE CODERS JUST ADDING THEIR THINGS!
	SO HOW THIS CODE WORKS CAN HEAVILY VARY FROM FILE TO FILE!!!
	
	Also keep in mind that i (artvin) started coding here with only half a year of knowledege so you'll see a fuckton of shitcode.
	
	Current coders that in anyway actively helped, in order of how much:
	
	Batfoxkid
	Artvin
	Mikusch
	Suza
	Alex
	Spookmaster
	
	Alot of code is borrowed/just takes from other plugins i or friends made, often with permission,
	rarely without cus i couldnt contact the person or it was just open sourcecode, credited anyways when i did that.
	
	You will also see alot of "inconsistent indentation" warnings, if 1.11 compiler told me where this shit happend then i would fix it
	but i honestly dont got the patience to look though all these sub files (more then 100)
*/

//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!

#pragma newdecls required

#define FAR_FUTURE	100000000.0
#define MAXENTITIES	2048
#define MAXTF2PLAYERS	36

#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

#define CONFIG		"configs/zombie_riot"
#define CONFIG_CFG	CONFIG ... "/%s.cfg"

#define DISPENSER_BLUEPRINT	"models/buildables/dispenser_blueprint.mdl"
#define SENTRY_BLUEPRINT	"models/buildables/sentry1_blueprint.mdl"

native any FuncToVal(Function bruh);

enum
{
	EF_BONEMERGE			= 0x001,	// Performs bone merge on client side
	EF_BRIGHTLIGHT 			= 0x002,	// DLIGHT centered at entity origin
	EF_DIMLIGHT 			= 0x004,	// player flashlight
	EF_NOINTERP				= 0x008,	// don't interpolate the next frame
	EF_NOSHADOW				= 0x010,	// Don't cast no shadow
	EF_NODRAW				= 0x020,	// don't draw entity
	EF_NORECEIVESHADOW		= 0x040,	// Don't receive no shadow
	EF_BONEMERGE_FASTCULL	= 0x080,	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
	EF_ITEM_BLINK			= 0x100,	// blink an item so that the user notices it.
	EF_PARENT_ANIMATES		= 0x200,	// always assume that the parent entity is animating
	EF_MAX_BITS = 10
};

enum
{
	Ammo_Metal = 3,		// 3	Metal
	Ammo_Jar = 6,		// 6	Jar
	Ammo_Pistol,		// 7	Pistol
	Ammo_Rocket,		// 8	Rocket Launchers
	Ammo_Flame,		// 9	Flamethrowers
	Ammo_Flare,		// 10	Flare Guns
	Ammo_Grenade,		// 11	Grenade Launchers
	Ammo_Sticky,		// 12	Stickybomb Launchers
	Ammo_Minigun,		// 13	Miniguns
	Ammo_Bolt,		// 14	Resuce Ranger, Cursader's Crossbow
	Ammo_Syringe,		// 15	Needle Guns
	Ammo_Sniper,		// 16	Sniper Rifles
	Ammo_Arrow,		// 17	Huntsman
	Ammo_SMG,		// 18	SMGs
	Ammo_Revolver,		// 19	Revolverss
	Ammo_Shotgun,		// 20	Shotgun, Shortstop, Force-A-Nature, Soda Popper
	Ammo_Heal,		// 21 Healing Ammunition
	Ammo_Medigun,		// 22 Medigun Ammunition
	Ammo_Laser,		// 23 Laser Battery
	Ammo_Hand_Grenade,		// 24 Hand Grenade types
	Ammo_Potion_Supply,		// 25 Drink Types
	Ammo_MAX
}

Handle SyncHud_Notifaction;
Handle SyncHud_WandMana;

ConVar zr_voteconfig;
ConVar tf_bot_quota;

int CurrentGame;
bool b_GameOnGoing = true;
//bool b_StoreGotReset = false;
int CurrentCash;
bool LastMann;
bool EscapeMode;
bool EscapeModeForNpc;

//bool RaidMode; 							//Is this raidmode?
float RaidModeScaling = 0.5;			//what multiplier to use for the raidboss itself?
float RaidModeTime = 0.0;
float f_TimerTickCooldownRaid = 0.0;
float f_TimerTickCooldownShop = 0.0;
int RaidBossActive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?
float Medival_Difficulty_Level = 0.0;	



int CurrentPlayers;
int PlayersAliveScaling;
int GlobalIntencity;
ConVar cvarTimeScale;
ConVar CvarMpSolidObjects; //mp_solidobjects 
Handle sv_cheats;
bool b_PhasesThroughBuildingsCurrently[MAXTF2PLAYERS];
Cookie CookieXP;
Cookie CookiePlayStreak;

int CurrentRound;
int CurrentWave = -1;
int StartCash;
float RoundStartTime;
char WhatDifficultySetting[64];
float healing_cooldown[MAXTF2PLAYERS];
float Damage_dealt_in_total[MAXTF2PLAYERS];
int Healing_done_in_total[MAXTF2PLAYERS];
int i_BarricadeHasBeenDamaged[MAXTF2PLAYERS];
int Resupplies_Supplied[MAXTF2PLAYERS];

bool thirdperson[MAXTF2PLAYERS];
bool WaitingInQueue[MAXTF2PLAYERS];
int dieingstate[MAXTF2PLAYERS];

//bool Wand_Fired;

TFClassType CurrentClass[MAXTF2PLAYERS];
TFClassType WeaponClass[MAXTF2PLAYERS];
int CurrentAmmo[MAXTF2PLAYERS][Ammo_MAX];
int CashSpent[MAXTF2PLAYERS];
int Level[MAXTF2PLAYERS];
int XP[MAXTF2PLAYERS];
int ImpulseBuffer[MAXTF2PLAYERS];
int Ammo_Count_Ready[MAXTF2PLAYERS];
//float Armor_Ready[MAXTF2PLAYERS];
float Increaced_Sentry_damage_Low[MAXENTITIES];
float Increaced_Sentry_damage_High[MAXENTITIES];
float Resistance_for_building_Low[MAXENTITIES];

int Armour_Level_Current[MAXTF2PLAYERS];


float Increaced_Overall_damage_Low[MAXTF2PLAYERS];
float Resistance_Overall_Low[MAXTF2PLAYERS];
bool Moved_Building[MAXENTITIES] = {false,... };
//bool Do_Not_Regen_Mana[MAXTF2PLAYERS];

//float Resistance_for_building_High[MAXENTITIES];
int Armor_Charge[MAXTF2PLAYERS];
int Zombies_Currently_Still_Ongoing;

int Elevators_Currently_Build[MAXTF2PLAYERS]={0, ...};
int i_SupportBuildingsBuild[MAXTF2PLAYERS]={0, ...};
int i_BarricadesBuild[MAXTF2PLAYERS]={0, ...};

int Elevator_Owner[MAXENTITIES]={0, ...};
bool Is_Elevator[MAXENTITIES]={false, ...};
int Dont_Crouch[MAXENTITIES]={0, ...};

enum
{
	TEUTON_NONE,
	TEUTON_DEAD,
	TEUTON_WAITING
}

int TeutonType[MAXTF2PLAYERS];
int PlayerPoints[MAXTF2PLAYERS];
int i_ExtraPlayerPoints[MAXTF2PLAYERS];
int i_PreviousPointAmount[MAXTF2PLAYERS];
	
int Animation_Setting[MAXTF2PLAYERS];
int Animation_Index[MAXTF2PLAYERS];

float delay_hud[MAXTF2PLAYERS];

int Current_Mana[MAXTF2PLAYERS];
float Mana_Regen_Delay[MAXTF2PLAYERS];
float Mana_Hud_Delay[MAXTF2PLAYERS];

int Armor_table_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int i_Healing_station_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Perk_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Pack_A_Punch_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];


bool b_NpcHasDied[MAXENTITIES]={true, ...};
const int i_MaxcountNpc = ZR_MAX_NPCS;
int i_ObjectsNpcs[ZR_MAX_NPCS];

bool b_IsAlliedNpc[MAXENTITIES]={false, ...};
const int i_MaxcountNpc_Allied = ZR_MAX_NPCS_ALLIED;
int i_ObjectsNpcs_Allied[ZR_MAX_NPCS_ALLIED];

const int i_MaxcountBuilding = ZR_MAX_BUILDINGS;
int i_ObjectsBuilding[ZR_MAX_BUILDINGS];
bool i_IsABuilding[MAXENTITIES];

const int i_MaxcountTraps = ZR_MAX_TRAPS;
int i_ObjectsTraps[ZR_MAX_TRAPS];

const int i_MaxcountBreakable = ZR_MAX_BREAKBLES;
int i_ObjectsBreakable[ZR_MAX_BREAKBLES];

//We kinda check these almost 24/7, its better to put them into an array!
const int i_MaxcountSpawners = ZR_MAX_SPAWNERS;
int i_ObjectsSpawners[ZR_MAX_SPAWNERS];
			
int g_CarriedDispenser[MAXPLAYERS+1];
int i_BeingCarried[MAXENTITIES];

//bool b_AllowBuildCommand[MAXPLAYERS + 1];

int Building_Mounted[MAXENTITIES];
bool b_SentryIsCustom[MAXENTITIES];
int i_NpcInternalId[MAXENTITIES];
bool b_IsCamoNPC[MAXENTITIES];

bool Doing_Handle_Mount[MAXPLAYERS + 1]={false, ...};
bool b_Doing_Buildingpickup_Handle[MAXPLAYERS + 1]={false, ...};

int i_PlayerToCustomBuilding[MAXPLAYERS + 1]={0, ...};

float f_TimeUntillNormalHeal[MAXPLAYERS + 1]={0.0, ...};
bool f_ClientServerShowMessages[MAXTF2PLAYERS];

float f_DisableDyingTimer[MAXPLAYERS + 1]={0.0, ...};
int i_DyingParticleIndication[MAXPLAYERS + 1]={-1, ...};

//Needs to be global.
int i_HowManyBombsOnThisEntity[MAXENTITIES][MAXTF2PLAYERS];
float f_ChargeTerroriserSniper[MAXENTITIES];
bool b_npcspawnprotection[MAXENTITIES];
bool b_ThisNpcIsSawrunner[MAXENTITIES];
float f_LowTeslarDebuff[MAXENTITIES];
float f_HighTeslarDebuff[MAXENTITIES];

float f_WidowsWineDebuff[MAXENTITIES];
float f_WidowsWineDebuffPlayerCooldown[MAXENTITIES];

#define FL_WIDOWS_WINE_DURATION 5.0

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
int Armor_Level[MAXPLAYERS + 1]={0, ...}; 				//701
int Jesus_Blessing[MAXPLAYERS + 1]={0, ...}; 				//777
float Panic_Attack[MAXENTITIES]={0.0, ...};				//651
float Mana_Regen_Level[MAXENTITIES]={0.0, ...};				//405
int i_HeadshotAffinity[MAXPLAYERS + 1]={0, ...}; 				//785
int i_SurvivalKnifeCount[MAXENTITIES]={0, ...}; 				//33
int i_BarbariansMind[MAXPLAYERS + 1]={0, ...}; 				//830
int i_SoftShoes[MAXPLAYERS + 1]={0, ...}; 				//527
int i_GlitchedGun[MAXENTITIES]={0, ...}; 				//731
int i_AresenalTrap[MAXENTITIES]={0, ...}; 				//719
int i_ArsenalBombImplanter[MAXENTITIES]={0, ...}; 				//544
int i_NoBonusRange[MAXENTITIES]={0, ...}; 				//410
int i_BuffBannerPassively[MAXENTITIES]={0, ...}; 				//786
int i_BadHealthRegen[MAXENTITIES]={0, ...}; 				//805

int i_LowTeslarStaff[MAXENTITIES]={0, ...}; 				//3002
int i_HighTeslarStaff[MAXENTITIES]={0, ...}; 				//3000

Function EntityFuncAttack[MAXENTITIES];
Function EntityFuncAttack2[MAXENTITIES];
Function EntityFuncAttack3[MAXENTITIES];
Function EntityFuncReload4[MAXENTITIES];
//Function EntityFuncReloadSingular5[MAXENTITIES];

int i_assist_heal_player[MAXTF2PLAYERS];
float f_assist_heal_player_time[MAXTF2PLAYERS];

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE

bool b_Is_Npc_Rocket[MAXENTITIES];
bool b_Is_Player_Rocket[MAXENTITIES];
bool b_Is_Player_Rocket_Through_Npc[MAXENTITIES];
bool b_Is_Blue_Npc[MAXENTITIES];

int i_ExplosiveProjectileHexArray[MAXENTITIES];
int h_NpcCollissionHookType[MAXENTITIES];

#define EP_GENERIC                  0          	//Nothing special.
#define EP_NO_KNOCKBACK              (1 << 0)   	// No knockback



bool b_Map_BaseBoss_No_Layers[MAXENTITIES];
int b_NpcForcepowerupspawn[MAXENTITIES]={0, ...}; 
float f_TempCooldownForVisualManaPotions[MAXPLAYERS+1];
float f_DelayLookingAtHud[MAXPLAYERS+1];
bool b_EntityIsArrow[MAXENTITIES];

//int g_iLaserMaterial, g_iHaloMaterial;


#define EXPLOSION_AOE_DAMAGE_FALLOFF 1.7
#define LASER_AOE_DAMAGE_FALLOFF 1.5
#define EXPLOSION_RADIUS 150.0
#define EXPLOSION_RANGE_FALLOFF 0.4

//#define DO_NOT_COMPENSATE_THESE 211, 442, 588, 30665, 264, 939, 880, 1123, 208, 1178, 594, 954, 1127, 327, 1153, 425, 1081, 740, 130, 595, 207, 351, 1083, 58, 528, 1151, 996, 1092, 752, 308, 1007, 1004, 1005, 206, 305

bool b_Do_Not_Compensate[MAXENTITIES];
bool b_Only_Compensate_CollisionBox[MAXENTITIES];
bool b_Only_Compensate_AwayPlayers[MAXENTITIES];
bool b_ExtendBoundingBox[MAXENTITIES];
bool b_BlockLagCompInternal[MAXENTITIES];
bool b_Dont_Move_Building[MAXENTITIES];
int b_BoundingBoxVariant[MAXENTITIES];
bool b_IsAloneOnServer = false;


bool b_IsPlayerABot[MAXPLAYERS+1];

bool b_IgnoreWarningForReloadBuidling[MAXTF2PLAYERS];

bool b_BlockPanzerInThisDifficulty;
bool b_SpecialGrigoriStore;
float f_ExtraDropChanceRarity = 1.0;


//GLOBAL npc things
bool b_thisNpcHasAnOutline[MAXENTITIES];
bool b_ThisNpcIsImmuneToNuke[MAXENTITIES];
bool applied_lastmann_buffs_once = false;

int AmmoData[][] =
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
char PerkNames[][] =
{
	"No Perk",
	"Quick Revive",
	"Juggernog",
	"Double Tap",
	"Speed Cola",
	"Deadshot Daiquiri",
	"Widows Wine",
};

char PerkNames_Recieved[][] =
{
	"No Perk",
	"Quick Revive Recieved",
	"Juggernog Recieved",
	"Double Tap Recieved",
	"Speed Cola Recieved",
	"Deadshot Daiquiri Recieved",
	"Widows Wine Recieved",
};

enum
{
	NOTHING 						= 0,	
	HEADCRAB_ZOMBIE 				= 1,	
	FORTIFIED_HEADCRAB_ZOMBIE 		= 2,	
	FASTZOMBIE 						= 3,	
	FORTIFIED_FASTZOMBIE 			= 4,
	TORSOLESS_HEADCRAB_ZOMBIE 		= 5,	
	FORTIFIED_GIANT_POISON_ZOMBIE 	= 6,	
	POISON_ZOMBIE 					= 7,	
	FORTIFIED_POISON_ZOMBIE 		= 8,	
	FATHER_GRIGORI 					= 9,
	COMBINE_POLICE_PISTOL			= 10,	
	COMBINE_POLICE_SMG				= 11,	
	COMBINE_SOLDIER_AR2				= 12,
	COMBINE_SOLDIER_SHOTGUN			= 13,	
	COMBINE_SOLDIER_SWORDSMAN		= 14,
	COMBINE_SOLDIER_ELITE			= 15,
	COMBINE_SOLDIER_GIANT_SWORDSMAN	= 16,
	COMBINE_SOLDIER_DDT				= 17,
	COMBINE_SOLDIER_COLLOSS			= 18, //Hetimus
	COMBINE_OVERLORD				= 19, 
	SCOUT_ZOMBIE					= 20,
	ENGINEER_ZOMBIE					= 21,
	HEAVY_ZOMBIE					= 22,
	FLYINGARMOR_ZOMBIE				= 23,
	FLYINGARMOR_TINY_ZOMBIE			= 24,
	KAMIKAZE_DEMO					= 25,
	MEDIC_HEALER					= 26,
	HEAVY_ZOMBIE_GIANT				= 27,
	SPY_FACESTABBER					= 28,
	SOLDIER_ROCKET_ZOMBIE			= 29,
	SOLDIER_ZOMBIE_MINION			= 30,
	SOLDIER_ZOMBIE_BOSS				= 31,
	SPY_THIEF						= 32,
	SPY_TRICKSTABBER				= 33,
	SPY_HALF_CLOACKED				= 34,
	SNIPER_MAIN						= 35,
	DEMO_MAIN						= 36,
	BATTLE_MEDIC_MAIN				= 37,
	GIANT_PYRO_MAIN					= 38,
	COMBINE_DEUTSCH_RITTER			= 39,
	SPY_MAIN_BOSS					= 40,
	
	
	XENO_HEADCRAB_ZOMBIE 				= 41,	
	XENO_FORTIFIED_HEADCRAB_ZOMBIE 		= 42,	
	XENO_FASTZOMBIE 					= 43,	
	XENO_FORTIFIED_FASTZOMBIE 			= 44,
	XENO_TORSOLESS_HEADCRAB_ZOMBIE 		= 45,	
	XENO_FORTIFIED_GIANT_POISON_ZOMBIE 	= 46,	
	XENO_POISON_ZOMBIE 					= 47,	
	XENO_FORTIFIED_POISON_ZOMBIE 		= 48,	
	XENO_FATHER_GRIGORI 				= 49,
	XENO_COMBINE_POLICE_PISTOL			= 50,	
	XENO_COMBINE_POLICE_SMG				= 51,	
	XENO_COMBINE_SOLDIER_AR2			= 52,
	XENO_COMBINE_SOLDIER_SHOTGUN		= 53,	
	XENO_COMBINE_SOLDIER_SWORDSMAN		= 54,
	XENO_COMBINE_SOLDIER_ELITE			= 55,
	XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN	= 56,
	XENO_COMBINE_SOLDIER_DDT			= 57,
	XENO_COMBINE_SOLDIER_COLLOSS		= 58, //Hetimus
	XENO_COMBINE_OVERLORD				= 59, 
	XENO_SCOUT_ZOMBIE					= 60,
	XENO_ENGINEER_ZOMBIE				= 61,
	XENO_HEAVY_ZOMBIE					= 62,
	XENO_FLYINGARMOR_ZOMBIE				= 63,
	XENO_FLYINGARMOR_TINY_ZOMBIE		= 64,
	XENO_KAMIKAZE_DEMO					= 65,
	XENO_MEDIC_HEALER					= 66,
	XENO_HEAVY_ZOMBIE_GIANT				= 67,
	XENO_SPY_FACESTABBER				= 68,
	XENO_SOLDIER_ROCKET_ZOMBIE			= 69,
	XENO_SOLDIER_ZOMBIE_MINION			= 70,
	XENO_SOLDIER_ZOMBIE_BOSS			= 71,
	XENO_SPY_THIEF						= 72,
	XENO_SPY_TRICKSTABBER				= 73,
	XENO_SPY_HALF_CLOACKED				= 74,
	XENO_SNIPER_MAIN					= 75,
	XENO_DEMO_MAIN						= 76,
	XENO_BATTLE_MEDIC_MAIN				= 77,
	XENO_GIANT_PYRO_MAIN				= 78,
	XENO_COMBINE_DEUTSCH_RITTER			= 79,
	XENO_SPY_MAIN_BOSS					= 80,
	
	NAZI_PANZER							= 81,
	BOB_THE_GOD_OF_GODS					= 82,
	NECRO_COMBINE						= 83,
	NECRO_CALCIUM						= 84,
	CURED_FATHER_GRIGORI				= 85,
	
	ALT_COMBINE_MAGE					= 86,
	
	BTD_BLOON							= 87,
	BTD_MOAB							= 88,
	BTD_BFB								= 89,
	BTD_ZOMG							= 90,
	BTD_DDT								= 91,
	BTD_BAD								= 92,
	
	ALT_MEDIC_APPRENTICE_MAGE			= 93,
	SAWRUNNER							= 94,
	
	RAIDMODE_TRUE_FUSION_WARRIOR		= 95,
	ALT_MEDIC_CHARGER					= 96,
	ALT_MEDIC_BERSERKER					= 97,
	
	MEDIVAL_MILITIA						= 98,
	MEDIVAL_ARCHER						= 99,
	MEDIVAL_MAN_AT_ARMS					= 100,
	MEDIVAL_SKIRMISHER					= 101,
	MEDIVAL_SWORDSMAN					= 102,
	MEDIVAL_TWOHANDED_SWORDSMAN			= 103,
	MEDIVAL_CROSSBOW_MAN				= 104,
	MEDIVAL_SPEARMEN					= 105,
	MEDIVAL_HANDCANNONEER				= 106,
	MEDIVAL_ELITE_SKIRMISHER			= 107,
	RAIDMODE_BLITZKRIEG					= 108,
	MEDIVAL_PIKEMAN						= 109,
	ALT_MEDIC_SUPPERIOR_MAGE			= 110,
	CITIZEN					= 111,
}


public const char NPC_Names[][] =
{
	"nothing",
	"Headcrab Zombie",
	"Fortified Headcrab Zombie",
	"Fast Zombie",
	"Fortified Fast Zombie",
	"Torsoless Headcrab Zombie",
	"Fortified Giant Poison Zombie",
	"Poison Zombie",
	"Fortified Poison Zombie",
	"Father Grigori",
	"Metro Cop",
	"Metro Raider",
	"Combine Rifler",
	"Combine Shotgunner",
	"Combine Swordsman",
	"Combine Elite",
	"Combine Giant Swordsman",
	"Combine DDT",
	"Combine Golden Collos",
	"Combine Overlord",
	"Scout Assulter",
	"Engineer Deconstructor",
	"Heavy Brawler",
	"Flying Armor",
	"Tiny Flying Armor",
	"Kamikaze Demo",
	"Medic Supporter",
	"Giant Heavy Brawler",
	"Spy Facestabber",
	"Soldier Rocketeer",
	"Soldier Minion",
	"Soldier Giant Summoner",
	"Spy Thief",
	"Spy Trickstabber",
	"Half Cloaked Spy",
	"Sniper Main",
	"Demoknight Main",
	"Battle Medic Main",
	"Giant Pyro Main",
	"Combine Deutsch Ritter",
	"X10 Spy Main",
	
	//XENO
	
	"Xeno Headcrab Zombie",
	"Xeno Fortified Headcrab Zombie",
	"Xeno Fast Zombie",
	"Xeno Fortified Fast Zombie",
	"Xeno Torsoless Headcrab Zombie",
	"Xeno Fortified Giant Poison Zombie",
	"Xeno Poison Zombie",
	"Xeno Fortified Poison Zombie",
	"Xeno Father Grigori",
	"Xeno Metro Cop",
	"Xeno Metro Raider",
	"Xeno Combine Rifler",
	"Xeno Combine Shotgunner",
	"Xeno Combine Swordsman",
	"Xeno Combine Elite",
	"Xeno Combine Giant Swordsman",
	"Xeno Combine DDT",
	"Xeno Combine Golden Collos",
	"Xeno Combine Overlord",
	"Xeno Scout Assulter",
	"Xeno Engineer Deconstructor",
	"Xeno Heavy Brawler",
	"Xeno Flying Armor",
	"Xeno Tiny Flying Armor",
	"Xeno Kamikaze Demo",
	"Xeno Medic Supporter",
	"Xeno Giant Heavy Brawler",
	"Xeno Spy Facestabber",
	"Xeno Soldier Rocketeer",
	"Xeno Soldier Minion",
	"Xeno Soldier Giant Summoner",
	"Xeno Spy Thief",
	"Xeno Spy Trickstabber",
	"Xeno Half Cloaked Spy",
	"Xeno Sniper Main",
	"Xeno Demoknight Main",
	"Xeno Battle Medic Main",
	"Xeno Giant Pyro Main",
	"Xeno Combine Deutsch Ritter",
	"Xeno X10 Spy Main",
	
	"Nazi Panzer",
	"Bob the Overgod of gods and destroyer of multiverses",
	"Revived Combine DDT",
	"Spookmaster Boner",
	"Cured Father Grigori",
	"Combine Mage",
	
	"Bloon",
	"Massive Ornery Air Blimp",
	"Brutal Floating Behemoth",
	"Zeppelin of Mighty Gargantuaness",
	"Dark Dirigible Titan",
	"Big Airship of Doom",
	
	
	"Medic Apprentice Mage",
	"Sawrunner",
	"True Fusion Warrior",
	"Medic Charger",
	"Medic Berserker",
	"Militia",
	"Archer",
	"Man-At-Arms",
	"Skirmisher",
	"Long Swordsman",
	"Twohanded Swordsman",
	"Crossbow Man",
	"Spearman",
	"Hand Cannoneer",
	"Elite Skirmisher",
	"Blitzkrieg",
	"Pikeman",
	"Medic Supperior Mage",
	"Rebel"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"npc_nothing",
	"npc_headcrabzombie",
	"npc_headcrabzombie_fortified",
	"npc_fastzombie",
	"npc_fastzombie_fortified",
	"npc_torsoless_headcrabzombie",
	"npc_poisonzombie_fortified_giant",
	"npc_poisonzombie",
	"npc_poisonzombie_fortified",
	"npc_last_survivor",
	"npc_combine_police_pistol",
	"npc_combine_police_smg",
	"npc_combine_soldier_ar2",
	"npc_combine_soldier_shotgun",
	"npc_combine_soldier_swordsman",
	"npc_combine_soldier_elite",
	"npc_combine_soldier_giant_swordsman",
	"npc_combine_soldier_swordsman_ddt",
	"npc_combine_soldier_collos_swordsman",
	"npc_combine_soldier_overlord",
	"npc_zombie_scout_grave",
	"npc_zombie_engineer_grave",
	"npc_zombie_heavy_grave",
	"npc_flying_armor",
	"npc_flying_armor_tiny_swords",
	"npc_kamikaze_demo",
	"npc_medic_healer",
	"npc_zombie_heavy_giant_grave",
	"npc_zombie_spy_grave",
	"npc_zombie_soldier_grave",
	"npc_zombie_soldier_minion_grave",
	"npc_zombie_soldier_giant_grave",
	"npc_spy_thief",
	"npc_spy_trickstabber",
	"npc_spy_half_cloacked_main",
	"npc_sniper_main",
	"npc_zombie_demo_main",
	"npc_medic_main",
	"npc_zombie_pyro_giant_main",
	"npc_combine_soldier_deutsch_ritter",
	"npc_spy_boss",
	
	//XENO
	
	"npc_xeno_headcrabzombie",
	"npc_xeno_headcrabzombie_fortified",
	"npc_xeno_fastzombie",
	"npc_xeno_fastzombie_fortified",
	"npc_xeno_torsoless_headcrabzombie",
	"npc_xeno_poisonzombie_fortified_giant",
	"npc_xeno_poisonzombie",
	"npc_xeno_poisonzombie_fortified",
	"npc_xeno_last_survivor",
	"npc_xeno_combine_police_pistol",
	"npc_xeno_combine_police_smg",
	"npc_xeno_combine_soldier_ar2",
	"npc_xeno_combine_soldier_shotgun",
	"npc_xeno_combine_soldier_swordsman",
	"npc_xeno_combine_soldier_elite",
	"npc_xeno_combine_soldier_giant_swordsman",
	"npc_xeno_combine_soldier_swordsman_ddt",
	"npc_xeno_combine_soldier_collos_swordsman",
	"npc_xeno_combine_soldier_overlord",
	"npc_xeno_zombie_scout_grave",
	"npc_xeno_zombie_engineer_grave",
	"npc_xeno_zombie_heavy_grave",
	"npc_xeno_flying_armor",
	"npc_xeno_flying_armor_tiny_swords",
	"npc_xeno_kamikaze_demo",
	"npc_xeno_medic_healer",
	"npc_xeno_zombie_heavy_giant_grave",
	"npc_xeno_zombie_spy_grave",
	"npc_xeno_zombie_soldier_grave",
	"npc_xeno_zombie_soldier_minion_grave",
	"npc_xeno_zombie_soldier_giant_grave",
	"npc_xeno_spy_thief",
	"npc_xeno_spy_trickstabber",
	"npc_xeno_spy_half_cloacked_main",
	"npc_xeno_sniper_main",
	"npc_xeno_zombie_demo_main",
	"npc_xeno_medic_main",
	"npc_xeno_zombie_pyro_giant_main",
	"npc_xeno_combine_soldier_deutsch_ritter",
	"npc_xeno_spy_boss",
	
	"npc_panzer",
	"npc_bob_the_overlord",
	"npc_necromancy_combine",
	"npc_necromancy_calcium",
	"npc_cured_last_survivor",
	
	"npc_alt_combine_soldier_mage",
	
	"npc_bloon",
	"",
	"",
	"",
	"",
	"",
	"npc_alt_medic_apprentice_mage",
	"npc_sawrunner",
	"npc_true_fusion_warrior",
	"npc_alt_medic_charger",
	"npc_alt_medic_berserker",
	"npc_medival_militia",
	"npc_medival_archer",
	"npc_medival_man_at_arms",
	"npc_medival_skrirmisher",
	"npc_medival_swordsman",
	"npc_medival_twohanded_swordsman",
	"npc_medival_crossbow",
	"npc_medival_spearmen",
	"npc_medival_handcannoneer",
	"npc_medival_elite_skirmisher",
	"npc_blitzkrieg",
	"npc_medival_pikeman",
	"npc_alt_medic_supperior_mage",
	"npc_citizen"
};

#include "zombie_riot/stocks.sp"
#include "zombie_riot/music.sp"
#include "zombie_riot/waves.sp"
#include "zombie_riot/attributes.sp"
#include "zombie_riot/configs.sp"
#include "zombie_riot/convars.sp"
#include "zombie_riot/dhooks.sp"
#include "zombie_riot/sdkcalls.sp"
#include "zombie_riot/sdkhooks.sp"
#include "zombie_riot/npcs.sp"
#include "zombie_riot/store.sp"
#include "zombie_riot/viewchanges.sp"
#include "zombie_riot/npc_stats.sp"

#include "zombie_riot/buildonbuilding.sp"
#include "zombie_riot/custom_melee_logic.sp"

#include "zombie_riot/thirdperson.sp"
#include "zombie_riot/escape.sp"
#include "zombie_riot/zombie_drops.sp"

#if defined LagCompensation
#include "zombie_riot/baseboss_lagcompensation.sp"
#endif

#include "zombie_riot/npc_death_showing.sp"
#include "zombie_riot/queue.sp"
#include "zombie_riot/item_gift_rpg.sp"


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
//#include "zombie_riot/custom/weapon_fusion_melee.sp"
#include "zombie_riot/custom/spike_layer.sp"
#include "zombie_riot/custom/weapon_grenade.sp"
#include "zombie_riot/custom/weapon_pipebomb.sp"
#include "zombie_riot/custom/weapon_default_wand.sp"
#include "zombie_riot/custom/weapon_wand_increace_attack.sp"
#include "zombie_riot/custom/weapon_fire_wand.sp"
#include "zombie_riot/custom/weapon_wand_fire_ball.sp"
#include "zombie_riot/custom/weapon_lightning_wand.sp"
#include "zombie_riot/custom/weapon_wand_lightning_spell.sp"
#include "zombie_riot/custom/weapon_necromancy_wand.sp"
#include "zombie_riot/custom/weapon_wand_necro_spell.sp"
#include "zombie_riot/custom/weapon_autoaim_wand.sp"
#include "zombie_riot/custom/weapon_arrow_shot.sp"
//#include "zombie_riot/custom/weapon_pipe_shot.sp"
#include "zombie_riot/custom/weapon_survival_knife.sp"
#include "zombie_riot/custom/weapon_glitched.sp"
#include "zombie_riot/custom/weapon_minecraft.sp"
#include "zombie_riot/custom/arse_enal_layer_tripmine.sp"
#include "zombie_riot/custom/weapon_serioussam2_shooter.sp"
#include "zombie_riot/custom/weapon_elemental_staff.sp"
#include "zombie_riot/custom/weapon_elemental_staff_2.sp"
#include "zombie_riot/custom/weapon_infinity_blade.sp"
//#include "zombie_riot/custom/weapon_black_fire_wand.sp"
#include "zombie_riot/custom/weapon_chlorophite.sp"
#include "zombie_riot/custom/weapon_chlorophite_heavy.sp"
#include "zombie_riot/custom/weapon_drink_resupply_mana.sp"
#include "zombie_riot/custom/weapon_wind_staff.sp"
#include "zombie_riot/custom/weapon_nailgun.sp"
#include "zombie_riot/custom/weapon_five_seven.sp"
#include "zombie_riot/custom/weapon_gb_medigun.sp"
#include "zombie_riot/custom/weapon_charged_handgun.sp"
#include "zombie_riot/custom/weapon_wand_beam.sp"

#include "zombie_riot/custom/weapon_calcium_wand.sp"
#include "zombie_riot/custom/weapon_wand_calcium_spell.sp"
#include "zombie_riot/custom/weapon_passive_banner.sp"
#include "zombie_riot/custom/weapon_zeroknife.sp"
#include "zombie_riot/custom/pets.sp"

//FOR ESCAPE MAP ONLY!
#include "zombie_riot/custom/escape_sentry_hat.sp"
#include "zombie_riot/custom/m3_abilities.sp"

public Plugin myinfo =
{
	name		=	"TF2: Zombie Riot",
	author		=	"Artvin & Batfoxkid & Mikusch",
	description	=	"Zombie Riot, Gamemode based off Gmod Zombie survival and the millions of CSS Zombie Riot servers.",
	version		=	"1.0"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("FuncToVal");
	CreateNative("FuncToVal", Native_FuncToVal);
	CreateNative("TPC_Get", Native_Get);
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetWaveCount", Native_GetWaveCounts);
	return APLRes_Success;
}

public void OnPluginStart()
{
	CurrentAmmo[0] = { 1, 1, 1, 200, 1, 1, 1,
	48,
	24,
	200,
	16,
	20,
	32,
	200,
	20,
	190,
	25,
	12,
	100,
	30,
	38,
	200,
	1000,
	100,
	1,
	1};

	HookEvent("teamplay_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("post_inventory_application", OnPlayerResupply, EventHookMode_Post);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
	HookEvent("teamplay_broadcast_audio", OnBroadcast, EventHookMode_Pre);
	HookEvent("teamplay_win_panel", OnWinPanel, EventHookMode_Pre);
	HookEvent("teamplay_setup_finished", OnSetupFinished, EventHookMode_PostNoCopy);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre);
	HookEvent("player_connect_client", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", OnPlayerConnect, EventHookMode_Pre);
//	HookEvent("nav_blocked", NavBlocked, EventHookMode_Pre);
	
	HookUserMessage(GetUserMessageId("SayText2"), Hook_BlockUserMessageEx, true);
	
	AddCommandListener(OnAutoTeam, "autoteam");
	AddCommandListener(OnAutoTeam, "jointeam");
	AddCommandListener(OnBuildCmd, "build");
	AddCommandListener(OnDropItem, "dropitem");
	AddCommandListener(OnTaunt, "taunt");
	AddCommandListener(OnTaunt, "+taunt");
	AddCommandListener(OnSayCommand, "say");
	AddCommandListener(OnSayCommand, "say_team");
	AddCommandListener(Command_Voicemenu, "voicemenu");
//	AddCommandListener(OnTaunt, "taunt");
	
	RegServerCmd("zr_reloadnpcs", OnReloadCommand, "Reload NPCs");
	RegServerCmd("sm_reloadnpcs", OnReloadCommand, "Reload NPCs", FCVAR_HIDDEN);
	RegServerCmd("zr_update_blocked_nav", OnReloadBlockNav, "Reload Nav Blocks");
	RegConsoleCmd("sm_store", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_shop", Access_StoreViaCommand, "Please Press TAB instad");
	RegConsoleCmd("sm_afk", Command_AFK, "BRB GONNA CLEAN MY MOM'S DISHES");
	RegConsoleCmd("sm_give_cash", Command_GiveCash, "Give Cash to the Person",ADMFLAG_ROOT);
	RegConsoleCmd("sm_give_dialog", Command_GiveDialogBox, "Give a dialog box",ADMFLAG_ROOT);
	RegAdminCmd("sm_afk_knight", Command_AFKKnight, ADMFLAG_GENERIC, "BRB GONNA MURDER MY MOM'S DISHES");
	RegAdminCmd("sm_change_collision", Command_ChangeCollision, ADMFLAG_GENERIC, "change all npc's collisions");
	RegAdminCmd("sm_spawn_grigori", Command_SpawnGrigori, ADMFLAG_GENERIC, "Forcefully summon grigori");
	
	RegAdminCmd("sm_toggle_fake_cheats", Command_ToggleCheats, ADMFLAG_GENERIC, "ToggleCheats");
	

					
	sv_cheats = FindConVar("sv_cheats");
	cvarTimeScale = FindConVar("host_timescale");
	tf_bot_quota = FindConVar("tf_bot_quota");
	
	CvarMpSolidObjects = FindConVar("tf_solidobjects");
	if(CvarMpSolidObjects)
		CvarMpSolidObjects.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
	
	ConVar cvar = FindConVar("tf_bot_count");
	cvar.Flags &= ~FCVAR_NOTIFY;
	
	CookieXP = new Cookie("zr_xp", "Your XP", CookieAccess_Protected);
	CookiePlayStreak = new Cookie("zr_playstreak", "How many times you played in a row", CookieAccess_Protected);
	
	HookEntityOutput("logic_relay", "OnTrigger", OnRelayTrigger);
	HookEntityOutput("logic_relay", "OnUser1", OnRelayFireUser1);
	
	LoadTranslations("zombieriot.phrases");
	LoadTranslations("zombieriot.phrases.zombienames");
	LoadTranslations("zombieriot.phrases.weapons");
	LoadTranslations("zombieriot.phrases.bob");
	LoadTranslations("common.phrases");
	
	DHook_Setup();
	SDKCall_Setup();
	
	ConVar_PluginStart();
	NPC_PluginStart();
	SDKHook_PluginStart();
	Thirdperson_PluginStart();
	Store_PluginStart();
	Waves_PluginStart();
	Medigun_PluginStart();
	OnPluginStartMangler();
	SentryHat_OnPluginStart();
	OnPluginStart_Build_on_Building();
	OnPluginStart_Glitched_Weapon();
//	Building_PluginStart();
#if defined LagCompensation
	OnPluginStart_LagComp();
#endif
	NPC_Base_InitGamedata();
	
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet"); 
	//Global Hud for huds.
	SyncHud_Notifaction = CreateHudSynchronizer();
	SyncHud_WandMana = CreateHudSynchronizer();
		
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			CurrentClass[client] = TF2_GetPlayerClass(client);
		}
	}
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		OnEntityCreated(ent, "info_player_teamspawn");	
	}
	b_BlockPanzerInThisDifficulty = false;
}

public Action Timer_Temp(Handle timer)
{
	if(CvarDisableThink.BoolValue)
	{
		float gameTime = GetGameTime() + 1.0;
		for(int i = MaxClients + 1; i < MAXENTITIES; i++)
		{
			view_as<CClotBody>(i).m_flNextDelayTime = gameTime;
		}
	}
	
	if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
	{
		if (RaidModeTime > GetGameTime() && RaidModeTime < GetGameTime() + 60.0)
		{
			PlayTickSound(true, false);
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Calculate_And_Display_hp(client, EntRefToEntIndex(RaidBossActive), 0.0, true);
			}
		}
	}
	if (GetWaveSetupCooldown() > GetGameTime() && GetWaveSetupCooldown() < GetGameTime() + 10.0)
	{
		PlayTickSound(false, true);
	}
	NPC_SpawnNext(false, false, false);
	return Plugin_Continue;
}

public void OnPluginEnd()
{
//	OnPluginEnd_LagComp();
	ConVar_Disable();
	
	// Remove the populator on plugin end
	
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			DHook_UnhookClient(i);
			OnClientDisconnect(i);
		}
	}
	
	char buffer[64];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			if(StrEqual(buffer, "base_boss"))
				RemoveEntity(i);
		}
	}
	
}

//bool Reload_Plugin_Temp_Fix = false;

public Action OnTaunt(int client, const char[] command, int args)
{
	if(dieingstate[client] != 0)
	{
		return Plugin_Handled;
	}
	
	Pets_OnTaunt(client);
	return Plugin_Continue;
}

public Action OnSayCommand(int client, const char[] command, int args)
{
	return NPC_SayCommand(client, command);
}

public void OnMapStart()
{
	PrecacheSound("weapons/knife_swing_crit.wav");
	PrecacheSound("weapons/shotgun/shotgun_dbl_fire.wav");
	PrecacheSound("npc/vort/attack_shoot.wav");
	PrecacheSound("npc/strider/fire.wav");
	PrecacheSound("weapons/shotgun/shotgun_fire7.wav");
	PrecacheSound("#items/tf_music_upgrade_machine.wav");
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
	PrecacheSound("misc/halloween/spell_overheal.wav");
	PrecacheSound("weapons/gauss/fire1.wav");
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
	PrecacheSound("weapons/capper_shoot.wav");

	PrecacheSound("zombiesurvival/headshot1.wav");
	PrecacheSound("zombiesurvival/headshot2.wav");
	PrecacheSound("misc/halloween/clock_tick.wav");
	PrecacheSound("mvm/mvm_bomb_warning.wav");
	PrecacheSound("weapons/jar_explode.wav");
	
	MapStartResetAll();
	EscapeMode = false;
	EscapeModeForNpc = false;
	
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	char buffer[16];
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(!StrEqual(buffer, "zr_escapemode", false))
			continue;
		
		EscapeMode = true;
		EscapeModeForNpc = true;
		break;
	}
	
	RoundStartTime = 0.0;
	cvarTimeScale.SetFloat(1.0);
	Waves_MapStart();
	Music_MapStart();
	DHook_MapStart();
	SDKHook_MapStart();
	ViewChange_MapStart();
	Remove_Healthcooldown();
	Third_PersonOnMapStart();
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
//	g_iHaloMaterial = PrecacheModel("materials/sprites/halo01.vmt");
//	g_iLaserMaterial = PrecacheModel("materials/sprites/laserbeam.vmt");
	Zombies_Currently_Still_Ongoing = 0;
	// An info_populator entity is required for a lot of MvM-related stuff (preserved entity)
//	CreateEntityByName("info_populator");
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	CreateTimer(0.2, Timer_Temp, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, GetClosestSpawners, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
	OnRoundEnd(null, NULL_STRING, false);
//	OnMapEnd_LagComp();
	OnMapEndWaves();
	ConVar_Disable();
}

public void OnConfigsExecuted()
{
	RequestFrame(Configs_ConfigsExecuted);
	/*
	if(Reload_Plugin_Temp_Fix)
	{
		ServerCommand("sm plugins reload zombie_riot");
		return;
	}
	else
	{
		Reload_Plugin_Temp_Fix = true;
	}
	*/
}
public Action OnReloadBlockNav(int args)
{
	UpdateBlockedNavmesh();
	return Plugin_Handled;
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
			if(StrEqual(path, "base_boss"))
				RemoveEntity(i);
		}
	}
	return Plugin_Handled;
}

public Action Command_AFK(int client, int args)
{
	if(client)
	{
		WaitingInQueue[client] = true;
		ChangeClientTeam(client, 1);
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

public Action Command_ChangeCollision(int client, int args)
{
	char buf[12];
	GetCmdArg(1, buf, sizeof(buf));
	int Collision = StringToInt(buf); 
	
	for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
		if (IsValidEntity(baseboss_index) && baseboss_index != 0)
		{
			Change_Npc_Collision(baseboss_index, Collision);
		}
	}
	return Plugin_Handled;
}

public Action Command_SpawnGrigori(int client, int args)
{
	Store_RandomizeNPCStore();
	Spawn_Cured_Grigori();
	return Plugin_Handled;
}

public Action Command_ToggleCheats(int client, int args)
{
	if(Toggle_sv_cheats)
	{
		Toggle_sv_cheats = false;
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "0");
			}
		}	
	}
	else
	{
		Toggle_sv_cheats = true;
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "1");
			}
		}
	}
	return Plugin_Handled;
}

					
public void OnClientPutInServer(int client)
{
	b_IsPlayerABot[client] = false;
	if(IsFakeClient(client))
	{
		TF2_ChangeClientTeam(client, TFTeam_Blue);
		DHook_HookClient(client);
		b_IsPlayerABot[client] = true;
		return;
	}
	else
	{
		Queue_PutInServer(client);
	}
	DHook_HookClient(client);
	SDKHook_HookClient(client);
	dieingstate[client] = 0;
	TeutonType[client] = 0;
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	Healing_done_in_total[client] = 0;
	i_BarricadeHasBeenDamaged[client] = 0;
	Ammo_Count_Ready[client] = 0;
	Armor_Charge[client] = 0;
	Doing_Handle_Mount[client] = false;
	b_Doing_Buildingpickup_Handle[client] = false;
	g_CarriedDispenser[client] = INVALID_ENT_REFERENCE;
	WeaponClass[client] = TFClass_Unknown;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	i_CurrentEquippedPerk[client] = 0;
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	f_ShowHudDelayForServerMessage[client] = GetGameTime() + 50.0;
	
	QueryClientConVar(client, "snd_musicvolume", ConVarCallback);
	
	if(CurrentRound && Store_PutInServer(client))
		CashSpent[client] = RoundToCeil(float(CurrentCash) * 0.40);
	
	if(AreClientCookiesCached(client)) //Ingore this. This only bugs it out, just force it, who cares.
		OnClientCookiesCached(client);	
}

//Maybe Delay it by 1 frame?
/*
public void SendProxyActivate(int client)
{
	SendProxy_Hook(client, "m_iClass", Prop_Int, SendProp_OnClientClass);
}

USE THIS INSTEAD

https://github.com/Kenzzer/classproxy/blob/master/scripting/include/classproxy.inc

Kenzzer my beloved
*/
public void OnClientCookiesCached(int client)
{
	ThirdPerson_OnClientCookiesCached(client);
	char buffer[12];
	CookieXP.Get(client, buffer, sizeof(buffer));
	XP[client] = StringToInt(buffer);
	Level[client] = XpToLevel(XP[client]);
	Store_ClientCookiesCached(client);
}

public void OnClientDisconnect(int client)
{
	Pets_ClientDisconnect(client);
	Queue_ClientDisconnect(client);
//	DHook_ClientDisconnect();
	Store_ClientDisconnect(client);
	Damage_dealt_in_total[client] = 0.0;
	Resupplies_Supplied[client] = 0;
	Healing_done_in_total[client] = 0;
	Ammo_Count_Ready[client] = 0;
	Armor_Charge[client] = 0;
	PlayerPoints[client] = 0;
	i_PreviousPointAmount[client] = 0;
	i_ExtraPlayerPoints[client] = 0;
	WeaponClass[client] = TFClass_Unknown;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	Escape_DropItem(client, false);
	if(XP[client] > 0)
	{
		char buffer[12];
		IntToString(XP[client], buffer, sizeof(buffer));
		CookieXP.Set(client, buffer);
	}
	XP[client] = 0;
}

public void OnClientDisconnect_Post(int client)
{
//	DHook_ClientDisconnectPost();
	int Players_left;
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			Players_left++;
	}
	CheckAlivePlayers(_);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	b_GameOnGoing = true;
	/*
	if(FindEntityByClassname(-1, "env_sun") == -1)
	{
		int entity_1 = CreateEntityByName("env_sun");
		if(IsValidEntity(entity_1))
		{
			DispatchSpawn(entity_1);
		}
	}
	maybe fixes 0x2f23f7 and 0x2f2388
	
	Edit: Does not.
	*/
	LastMann = false;
	
	if(RoundStartTime > GetGameTime())
		return;
	
	RoundStartTime = GetGameTime()+0.1;
	
	Escape_RoundStart();
	Store_RoundStart();
	Waves_RoundStart();
}

public void OnSetupFinished(Event event, const char[] name, bool dontBroadcast)
{
	Escape_SetupEnd();
}

public Action OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(event.GetBool("autoteam"))
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if(client)
		{
			ChangeClientTeam(client, 3);
			OnAutoTeam(client, name, 0);
		}
	}
	
	if(event.GetBool("silent"))
		return Plugin_Continue;
	
	event.BroadcastDisabled = true;
	return Plugin_Changed;
}

public Action OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	if(!event.GetBool("bot"))
		return Plugin_Continue;
	
	event.BroadcastDisabled = true;
	return Plugin_Changed;
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	b_GameOnGoing = false;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Escape_DropItem(client);
			Damage_dealt_in_total[client] = 0.0;
			Resupplies_Supplied[client] = 0;
			Healing_done_in_total[client] = 0;
			Ammo_Count_Ready[client] = 0;
			Armor_Charge[client] = 0;
//			Music_Timer[client] = GetEngineTime() + 20.0;
//			Armor_Ready[client] = 0.0;
		}
	}
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsClientInGame(client_check) && TeutonType[client_check] != TEUTON_WAITING)
			TeutonType[client_check] = 0;
	}
	NPC_RoundEnd();
	Store_Reset();
	Waves_RoundEnd();
	Escape_RoundEnd();
	CurrentGame = 0;
}
/*
public void OnGameFrame()
{
	Wand_Homing();
}
*/

public Action OnTeutonHealth(int client, int &health)
{
	if(TeutonType[client])
	{
		SetEntityHealth(client, 0);
		return Plugin_Continue;
	}
	
	SDKUnhook(client, SDKHook_GetMaxHealth, OnTeutonHealth);
	return Plugin_Continue;
}

public void OnPlayerResupply(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client)
	{
		//DEFAULTS
		if(dieingstate[client] == 0)
		{
			b_ThisEntityIgnored[client] = false;
		}
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
		SetVariantString("");
	  	AcceptEntityInput(client, "SetCustomModel");
	  	//DEFAULTS
	  	
		CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
		ViewChange_DeleteHands(client);
		ViewChange_UpdateHands(client, CurrentClass[client]);
		
		if(WaitingInQueue[client])
			TeutonType[client] = TEUTON_WAITING;
		
		if(TeutonType[client] != TEUTON_NONE)
		{
			FakeClientCommand(client, "menuselect 0");
			SDKHook(client, SDKHook_GetMaxHealth, OnTeutonHealth);
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			
			int entity = MaxClients+1;
			while(TF2_GetWearable(client, entity))
			{
				TF2_RemoveWearable(client, entity);
			}
			
			TF2Attrib_RemoveAll(client);
			TF2Attrib_SetByDefIndex(client, 68, -1.0);
			SetVariantString(COMBINE_CUSTOM_MODEL);
	  		AcceptEntityInput(client, "SetCustomModel");
	   		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);
	   		
	   		b_ThisEntityIgnored[client] = true;
	   		
	   		int weapon_index = Store_GiveSpecificItem(client, "Teutonic Longsword");
	   		
	   		TF2Attrib_RemoveAll(weapon_index);
	   		
	   		float damage;
	   		
	   		int Wave_Count = Waves_GetRound() + 1;
			
			if(Wave_Count < 5)
				damage = 0.25;
				
			if(Wave_Count <= 10)
				damage = 0.4;
						
			else if(Wave_Count <= 15)
				damage = 1.0;
					
			else if(Wave_Count <= 20)
				damage = 1.5;
						
			else if(Wave_Count <= 25)
				damage = 2.5;
						
			else if(Wave_Count <= 30)
				damage = 5.0;
						
			else if(Wave_Count <= 40)
				damage = 7.0;
						
			else if(Wave_Count <= 45)
				damage = 25.0;
					
			else if(Wave_Count <= 50)
				damage = 35.0;
				
			else if(Wave_Count <= 55)
				damage = 45.0;
					
			else if(Wave_Count <= 60)
				damage = 50.0;
				
			else if(Wave_Count <= 70)
				damage = 60.0;
				
			else if(Wave_Count <= 80)
				damage = 80.0;
				
			else if(Wave_Count <= 90)
				damage = 90.0;
					
			else
				damage = 100.0;
			
	   		TF2Attrib_SetByDefIndex(weapon_index, 2, damage);
	   		TF2Attrib_SetByDefIndex(weapon_index, 264, 0.0);
	   		TF2Attrib_SetByDefIndex(weapon_index, 263, 0.0);
	   		TF2Attrib_SetByDefIndex(weapon_index, 6, 1.2);
	   		TF2Attrib_SetByDefIndex(weapon_index, 412, 0.0);
	   		TF2Attrib_SetByDefIndex(weapon_index, 442, 1.1);
	   		TFClassType ClassForStats = WeaponClass[client];
	   		
	   		TF2Attrib_SetByDefIndex(weapon_index, 107, RemoveExtraSpeed(ClassForStats));
	   		TF2Attrib_SetByDefIndex(weapon_index, 476, 0.0);
	   		SetEntityCollisionGroup(client, 1);
	   		SetEntityCollisionGroup(weapon_index, 1);
	   		
	   		int wearable;
	   		
	   		wearable = GiveWearable(client, 30727);
	   		
	   		SetEntPropFloat(wearable, Prop_Send, "m_flModelScale", 0.9);
	   		
	   		wearable = GiveWearable(client, 30969);
	   		
	   		SetEntPropFloat(wearable, Prop_Send, "m_flModelScale", 1.25);
	   		
	   		SetEntPropFloat(weapon_index, Prop_Send, "m_flModelScale", -0.8);
	   		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.7);
	   		
	   		SetAmmo(client, Ammo_Metal, CurrentAmmo[client][Ammo_Metal]);
			SetAmmo(client, Ammo_Jar, 1);
			for(int i=Ammo_Pistol; i<Ammo_MAX; i++)
			{
				SetAmmo(client, i, CurrentAmmo[client][i]);
			}
	   		
		}
		else
		{
			int entity = MaxClients+1;
			while(TF2_GetWearable(client, entity))
			{
				switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
				{
					case 57, 131, 133, 231, 405, 406, 444, 608, 642, 1099, 1144:
						TF2_RemoveWearable(client, entity);
				}
			}
			
			ViewChange_PlayerModel(client);
			Store_ApplyAttribs(client);
			Pets_PlayerResupply(client);
			
			if(dieingstate[client])
			{
			}
			else
			{
				Store_GiveAll(client, Waves_GetRound()>1 ? 50 : 300); //give 300 hp instead of 200 in escape.
			}
			
			SetAmmo(client, Ammo_Metal, CurrentAmmo[client][Ammo_Metal]);
			SetAmmo(client, Ammo_Jar, 1);
			for(int i=Ammo_Pistol; i<Ammo_MAX; i++)
			{
				SetAmmo(client, i, CurrentAmmo[client][i]);
			}
			
			PrintHintText(client, "%T", "Open Store", client);
		}
	}
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client)
	{
		Escape_DropItem(client);
		if(g_CarriedDispenser[client] != INVALID_ENT_REFERENCE)
		{
			DestroyDispenser(client);
		}
	}
	
	Citizen_PlayerDeath(client);
	Bob_player_killed(event, name, dontBroadcast);
	RequestFrame(CheckAlivePlayersforward, client); //REQUEST frame cus isaliveplayer doesnt even get applied yet in this function instantly, so wait 1 frame
}

public Action Timer_Dieing(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] > 0)
	{
		if(f_DisableDyingTimer[client] >= GetGameTime())
		{
			return Plugin_Continue;
		}
		SetEntityHealth(client, GetClientHealth(client) - 1);
		SDKHooks_TakeDamage(client, client, client, 1.0);
		
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
	if (players == 1)
	{
		b_IsAloneOnServer = true;
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
	int entity = Npc_Create(CURED_FATHER_GRIGORI, client, flPos, flAng, true);
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
	if(!Waves_Started())
	{
		LastMann = false;
		GlobalIntencity = 0;
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
	LastMann = true;
	int players = CurrentPlayers;
	CurrentPlayers = 0;
	GlobalIntencity = Waves_GetIntencity();
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
		{
			CurrentPlayers++;
			if(killed != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
			{
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
				GlobalIntencity++;
			}
		}
	}
	
	if(CurrentPlayers < players)
		CurrentPlayers = players;
	
	if(LastMann && !GlobalIntencity) //Make sure if they are alone, it wont play last man music.
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
		//			Music_Timer[client] = 0.0;
				
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
public Action OnBroadcast(Event event, const char[] name, bool dontBroadcast)
{
	static char sound[PLATFORM_MAX_PATH];
	event.GetString("sound", sound, sizeof(sound));
	if(!StrContains(sound, "Game.Your", false) || StrEqual(sound, "Game.Stalemate", false) || !StrContains(sound, "Announcer.", false))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action OnWinPanel(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Handled;
}
/*
public Action NavBlocked(Event event, const char[] name, bool dontBroadcast)
{
	PrintHintText(1, "t");
	
	int area = event.GetInt("area");
	bool blocked = event.GetBool("blocked");
	if(blocked)
	{
		PrintToChatAll("%i", area);
	}
	
	return Plugin_Stop;
}
*/
public Action OnAutoTeam(int client, const char[] command, int args)
{
	if(client)
	{
		if(IsFakeClient(client))
		{
			ChangeClientTeam(client, view_as<int>(TFTeam_Blue));
		}
		else if(Queue_JoinTeam(client))
		{
			ChangeClientTeam(client, view_as<int>(TFTeam_Red));
			ShowVGUIPanel(client, "class_red");
		}
	}
	return Plugin_Handled;
}

public Action OnBuildCmd(int client, const char[] command, int args)
{
	if(client && GameRules_GetProp("m_bInWaitingForPlayers"))
		return Plugin_Handled;
		
	return Plugin_Continue;
}

public Action OnRelayTrigger(const char[] output, int entity, int caller, float delay)
{
	char name[32];
	GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
	if(!StrContains(name, "nav_reloader", false)) //Sometimes blocking shit doesnt work.
	{
		UpdateBlockedNavmesh();
	}
	else if(!StrContains(name, "zr_respawn", false))
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				DoOverlay(client, "");
				if(GetClientTeam(client)==2)
				{
					if(!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD)
					{
						DHook_RespawnPlayer(client);
					}
					else if(dieingstate[client] > 0)
					{
						dieingstate[client] = 0;
						Store_ApplyAttribs(client);
						TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
						int entity_wearable, i;
						while(TF2U_GetWearable(client, entity_wearable, i))
						{
							SetEntityRenderMode(entity_wearable, RENDER_NORMAL);
							SetEntityRenderColor(entity_wearable, 255, 255, 255, 255);
						}
						SetEntityRenderMode(client, RENDER_NORMAL);
						SetEntityRenderColor(client, 255, 255, 255, 255);
						SetEntityCollisionGroup(client, 5);
						SetEntityHealth(client, SDKCall_GetMaxHealth(client));
					}
				}
			}
		}
		
		CheckAlivePlayers();
	}
	else if(!StrContains(name, "zr_cash_", false))
	{
		char buffers[4][12];
		ExplodeString(name, "_", buffers, sizeof(buffers), sizeof(buffers[]));
		
		int cash = StringToInt(buffers[2]);
		CurrentCash += cash;
		PrintToChatAll("Gained %d cash!", cash);
	}
	// DO NOT DO 
	// return Plugin_Handled;!!!!!!
	//This breaks maps.
	return Plugin_Continue;
}

public Action OnRelayFireUser1(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[32];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));

		if(!StrContains(name, "zr_cash_", false))
		{
			char buffers[4][12];
			ExplodeString(name, "_", buffers, sizeof(buffers), sizeof(buffers[]));
			
			int cash = StringToInt(buffers[2]);
			CashSpent[caller] -= cash;
			PrintToChat(caller, "Gained %d cash!", cash);
		}
	}
	// DO NOT DO 
	// return Plugin_Handled;!!!!!!
	//This breaks maps.
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(b_IsPlayerABot[client])
	{
		return Plugin_Continue;
	}
	#if defined LagCompensation
	OnPlayerRunCmd_Lag_Comp(client, angles, tickcount);
	#endif
	if(ImpulseBuffer[client] > 0)
	{
		/*
		if(!CvarCheats.BoolValue)
		{
			CvarCheats.SetBool(true, false, false);
			RequestFrame(Frame_OffCheats);
		}
		*/
		
		ImpulseBuffer[client] = -ImpulseBuffer[client];
		impulse = 101;
		return Plugin_Changed;
	}
	
	if(ImpulseBuffer[client] < 0)
	{
		SetEntityHealth(client, -ImpulseBuffer[client]);
		
		ImpulseBuffer[client] = 0;

		SetAmmo(client, 1, 9999);
		SetAmmo(client, 2, 9999);
		SetAmmo(client, Ammo_Metal, CurrentAmmo[client][Ammo_Metal]);
		for(int i=Ammo_Jar; i<Ammo_MAX; i++)
		{
			SetAmmo(client, i, CurrentAmmo[client][i]);
		}
		if(EscapeMode)
		{
			SetAmmo(client, Ammo_Metal, 99099); //just give infinite metal. There is no reason not to. (in Escape.)
			SetAmmo(client, 21, 99999);
		}
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 0.0);
		
		OnWeaponSwitchPost(client, GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));
	}
	
	Escape_PlayerRunCmd(client);
	/*
	if(dieingstate[client] > 0)
	{
		Dont_Crouch[client] -= 1;
		buttons |= IN_DUCK;
		SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
		Return_Changed = true;
	}	
	*/
	static int holding[MAXTF2PLAYERS];
	static bool was_reviving[MAXTF2PLAYERS];
	static int was_reviving_this[MAXTF2PLAYERS];
	if(holding[client])
	{
		if(!(buttons & holding[client]))
			holding[client] = 0;
	}
	else if(buttons & IN_ATTACK2)
	{
		holding[client] = IN_ATTACK2;
		
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		b_IgnoreWarningForReloadBuidling[client] = false;
		if(IsValidEntity(weapon_holding))
		{
			char classname[32];
			GetEntityClassname(weapon_holding, classname, 32);
			Action action = Plugin_Continue;
			if(EntityFuncAttack2[weapon_holding] && EntityFuncAttack2[weapon_holding]!=INVALID_FUNCTION)
			{
				bool result = false; //ignore crit.
				Call_StartFunction(null, EntityFuncAttack2[weapon_holding]);
				Call_PushCell(client);
				Call_PushCell(weapon_holding);
				Call_PushString(classname);
				Call_PushCellRef(result);
				Call_Finish(action);
			}
			if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)
			{
				if(EntityFuncAttack2[weapon_holding] != MountBuildingToBack && TeutonType[client] == TEUTON_NONE)
				{
					b_IgnoreWarningForReloadBuidling[client] = true;
					Pickup_Building_M2(client, weapon, false);
				}
			}
		}
		StartPlayerOnlyLagComp(client, true);
		if(InteractKey(client, weapon_holding, false)) //doesnt matter which one
		{
			buttons &= ~IN_ATTACK2;
			EndPlayerOnlyLagComp(client);
			return Plugin_Changed;
		}
		EndPlayerOnlyLagComp(client);
	}
	else if(buttons & IN_RELOAD)
	{
		holding[client] = IN_RELOAD;
		if(angles[0] < -70.0)
		{
			int entity = EntRefToEntIndex(Building_Mounted[client]);
			if(IsValidEntity(entity))
			{
				Building_Interact(client, entity, true);
			}
		}
		else
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			StartPlayerOnlyLagComp(client, true);
			if(InteractKey(client, weapon_holding, true))
			{
				buttons &= ~IN_RELOAD;
				EndPlayerOnlyLagComp(client);
				return Plugin_Changed;
			}
			EndPlayerOnlyLagComp(client);
			if(IsValidEntity(weapon_holding))
			{
				Action action = Plugin_Continue;
				if(EntityFuncAttack3[weapon_holding] && EntityFuncAttack3[weapon_holding]!=INVALID_FUNCTION)
				{
					bool result = false; //ignore crit.
					char classname[32];
					GetEntityClassname(weapon_holding, classname, 32);
					Call_StartFunction(null, EntityFuncAttack3[weapon_holding]);
					Call_PushCell(client);
					Call_PushCell(weapon_holding);
					Call_PushString(classname);
					Call_PushCellRef(result);
					Call_Finish(action);
				}
			}
		}
	}
	else if(buttons & IN_SCORE && dieingstate[client] == 0)
	{
		holding[client] = IN_SCORE;
		if(WaitingInQueue[client])
		{
			Queue_Menu(client);
		}
		else
		{
			Store_Menu(client);
		}
	}
	else if(buttons & IN_ATTACK3)
	{
		holding[client] = IN_ATTACK3;
		
		if (IsPlayerAlive(client))
		{
			M3_Abilities(client);
		}
	}
	
	if(buttons & IN_ATTACK)
	{
		int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(entity > MaxClients)
			Attributes_Fire(client, entity);
	}
	
	if(holding[client] == IN_RELOAD && dieingstate[client] <= 0 && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
	{
		int target = GetClientPointVisibleRevive(client);
		if(target > 0 && target <= MaxClients)
		{
			float Healer[3];
			Healer[2] += 62;
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Healer); 
			float Injured[3];
			Injured[2] += 62;
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", Injured);
			if(GetVectorDistance(Healer, Injured) <= 250.0)
			{
				SetEntityMoveType(target, MOVETYPE_NONE);
				was_reviving[client] = true;
				f_DelayLookingAtHud[client] = GetGameTime() + 0.5;
				f_DelayLookingAtHud[target] = GetGameTime() + 0.5;
				PrintCenterText(client, "%t", "Reviving", dieingstate[target]);
				PrintCenterText(target, "%t", "You're Being Revived.", dieingstate[target]);
				was_reviving_this[client] = target;
				f_DisableDyingTimer[target] = GetGameTime() + 0.05;
				if(i_CurrentEquippedPerk[client] == 1)
				{
					dieingstate[target] -= 2;
				}
				else
				{
					dieingstate[target] -= 1;
				}
				
				if(dieingstate[target] <= 0)
				{
					SetEntityMoveType(target, MOVETYPE_WALK);
					dieingstate[target] = 0;
					
					SetEntPropEnt(target, Prop_Send, "m_hObserverTarget", client);
					DHook_RespawnPlayer(target);
					
					float pos[3], ang[3];
					GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
					SetEntProp(target, Prop_Send, "m_bDucked", true);
					SetEntityFlags(target, GetEntityFlags(target)|FL_DUCKING);
					CClotBody npc = view_as<CClotBody>(client);
					npc.m_bThisEntityIgnored = false;
					TeleportEntity(target, pos, ang, NULL_VECTOR);
					SetEntityCollisionGroup(target, 5);
					PrintCenterText(client, "");
					PrintCenterText(target, "");
					DoOverlay(target, "");
					if(!EscapeMode)
					{
						SetEntityHealth(target, 50);
						RequestFrame(SetHealthAfterRevive, target);
					}	
					else
					{
						SetEntityHealth(target, 150);
						RequestFrame(SetHealthAfterRevive, target);						
					}
					int entity, i;
					while(TF2U_GetWearable(target, entity, i))
					{
						SetEntityRenderMode(entity, RENDER_NORMAL);
						SetEntityRenderColor(entity, 255, 255, 255, 255);
					}
					SetEntityRenderMode(target, RENDER_NORMAL);
					SetEntityRenderColor(target, 255, 255, 255, 255);
				}
			}
			else if (was_reviving[client])
			{
				SetEntityMoveType(target, MOVETYPE_WALK);
				was_reviving[client] = false;
				PrintCenterText(client, "");
				PrintCenterText(target, "");
			}
		}
		else if(target > MaxClients)
		{
			float Healer[3];
			Healer[2] += 62;
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Healer); 
			float Injured[3];
			Injured[2] += 62;
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", Injured);
			if(GetVectorDistance(Healer, Injured) <= 250.0)
			{
				int ticks;
				was_reviving[client] = true;
				f_DelayLookingAtHud[client] = GetGameTime() + 0.5;
				was_reviving_this[client] = target;
				if(i_CurrentEquippedPerk[client] == 1)
				{
					ticks = Citizen_ReviveTicks(target, 2);
				}
				else
				{
					ticks = Citizen_ReviveTicks(target, 1);
				}
				
				if(ticks <= 0)
				{
					PrintCenterText(client, "");
				}
				else
				{
					PrintCenterText(client, "%t", "Reviving", ticks);
				}
			}
			else if (was_reviving[client])
			{
				was_reviving[client] = false;
				PrintCenterText(client, "");
			}
		}
		else if (was_reviving[client])
		{
			was_reviving[client] = false;
			PrintCenterText(client, "");
			if(IsValidClient(was_reviving_this[client]))
			{
				SetEntityMoveType(was_reviving_this[client], MOVETYPE_WALK);
				PrintCenterText(was_reviving_this[client], "");
			}
		}
	}
	else if (was_reviving[client])
	{
		was_reviving[client] = false;
		PrintCenterText(client, "");
		if(IsValidClient(was_reviving_this[client]))
		{
			SetEntityMoveType(was_reviving_this[client], MOVETYPE_WALK);
			PrintCenterText(was_reviving_this[client], "");
		}
	}
	
//	Building_PlayerRunCmd(client, buttons);
	return Plugin_Continue;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3])
{
	Pets_PlayerRunCmdPost(client, buttons, angles);
	Medikit_healing(client, buttons);
}

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

public void Update_Ammo(int  client)
{
	for(int i; i<Ammo_MAX; i++)
	{
		CurrentAmmo[client][i] = GetAmmo(client, i);
	}	
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
	RequestFrame(Update_Ammo, client);

	Action action = Plugin_Continue;
	Function func = EntityFuncAttack[weapon];
	if(func && func!=INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushString(classname);
		Call_PushCellRef(result);
		Call_Finish(action);
	}
	
	if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee && !StrEqual(classname, "tf_weapon_wrench"))
	{
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
		
		if(attack_speed > 5.0)
		{
			attack_speed *= 0.5; //Too fast! It makes animations barely play at all
		}
		
		TF2Attrib_SetByDefIndex(client, 201, attack_speed);
			
		if(!IsWandWeapon(weapon))
		{
			if(Panic_Attack[weapon])
			{
				float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
				float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);
				
				if(flpercenthpfrommax >= 1.0)
					flpercenthpfrommax = 1.0; //maths to not allow negative suuuper slow attack speed
					
				float Attack_speed = flpercenthpfrommax / Panic_Attack[weapon];
				
				if(Attack_speed <= Panic_Attack[weapon])
				{
					Attack_speed = Panic_Attack[weapon]; //DONT GO ABOVE THIS, WILL BREAK SOME MELEE'S DUE TO THEIR ALREADY INCREACED ATTACK SPEED.
				}
				else if (Attack_speed >= 1.15)
				{
					Attack_speed = 1.15; //hardcoding this lol
				}
				/*
				if(TF2_IsPlayerInCondition(client,TFCond_RuneHaste))
					Attack_speed = 1.0; //If they are last, dont alter attack speed, otherwise breaks melee, again.
					//would also make them really op
				*/
				TF2Attrib_SetByDefIndex(weapon, 396, Attack_speed);
			}
			if(StrEqual(classname, "tf_weapon_knife"))
			{
				Handle swingTrace;
				b_LagCompNPC_No_Layers = true;
				float vecSwingForward[3];
				StartLagCompensation_Base_Boss(client, false);
				DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
				FinishLagCompensation_Base_boss();
				int target = TR_GetEntityIndex(swingTrace);	
										
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);	
					
				int Item_Index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				PlayCustomWeaponSoundFromPlayerCorrectly(target, client, weapon, Item_Index, classname);	
					
				if(target > 0)
				{
				//	PrintToChatAll("%i",MELEE_HIT);
				//	SDKCall_CallCorrectWeaponSound(weapon, MELEE_HIT, 1.0);
				// 	This doesnt work sadly and i dont have the power/patience to make it work, just do a custom check with some big shit, im sorry.
					float damage = 40.0;
					
					Address address = TF2Attrib_GetByDefIndex(weapon, 2);
					if(address != Address_Null)
						damage *= TF2Attrib_GetValue(address);
						
					
					address = TF2Attrib_GetByDefIndex(weapon, 1);
					if(address != Address_Null)
						damage *= TF2Attrib_GetValue(address);
						
					SDKHooks_TakeDamage(target, client, client, damage, DMG_CLUB, weapon, CalculateDamageForce(vecSwingForward, 20000.0), vecHit, false); //, CalculateBulletDamageForce(m_vecDirShooting, 1.0));	
				}
				delete swingTrace;
			}
			else
			{
				DataPack pack;
				//The delay is usually 0.2 seconds.
				CreateDataTimer(0.2, Timer_Do_Melee_Attack, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(EntIndexToEntRef(weapon));
				pack.WriteString(classname);
			}
		}
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 201, 1.0);
	}
	return action;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!StrContains(classname, "info_player_teamspawn")) 
	{
		for (int i = 0; i < ZR_MAX_SPAWNERS; i++)
		{
			if (!IsValidEntity(i_ObjectsSpawners[i]) || i_ObjectsSpawners[i] == 0)
			{
				Spawner_AddToArray(entity);
				i_ObjectsSpawners[i] = entity;
				i = ZR_MAX_SPAWNERS;
			}
		}
	}
	else if (entity > 0 && entity <= 2048 && IsValidEntity(entity))
	{
		b_EntityIsArrow[entity] = false;
		CClotBody npc = view_as<CClotBody>(entity);
		b_SentryIsCustom[entity] = false;
		b_Is_Npc_Rocket[entity] = false;
		b_Is_Player_Rocket[entity] = false;
		Moved_Building[entity] = false;
		b_Is_Blue_Npc[entity] = false;
		EntityFuncAttack[entity] = INVALID_FUNCTION;
		EntityFuncAttack2[entity] = INVALID_FUNCTION;
		EntityFuncAttack3[entity] = INVALID_FUNCTION;
		EntityFuncReload4[entity] = INVALID_FUNCTION;
		b_Map_BaseBoss_No_Layers[entity] = false;
		b_Is_Player_Rocket_Through_Npc[entity] = false;
		i_IsABuilding[entity] = false;
		i_InSafeZone[entity] = 0;
		h_NpcCollissionHookType[entity] = 0;
		OnEntityCreated_Build_On_Build(entity, classname);
		SetDefaultValuesToZeroNPC(entity);
		
		if(!StrContains(classname, "env_entity_dissolver"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly_Disolve);
		}
		else if(!StrContains(classname, "item_currencypack_custom"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "tf_projectile_energy_ring"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "entity_medigun_shield"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "tf_projectile_energy_ball"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "item_powerup_rune"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "tf_projectile_spellfireball"))
		{
			SDKHook(entity, SDKHook_SpawnPost, ApplyExplosionDhook_Fireball);
			SDKHook(entity, SDKHook_SpawnPost, Wand_Necro_Spell);
			SDKHook(entity, SDKHook_SpawnPost, Wand_Calcium_Spell);
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		//	ApplyExplosionDhook_Rocket(entity);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "vgui_screen")) //Delete dispenser screen cut its really not needed at all, just takes up stuff for no reason
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "base_boss"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Check_For_Team_Npc);
		//	Check_For_Team_Npc(EntIndexToEntRef(entity)); //Dont delay ?
		}
		else if(!StrContains(classname, "func_breakable"))
		{
			for (int i = 0; i < ZR_MAX_BREAKBLES; i++)
			{
				if (EntRefToEntIndex(i_ObjectsBreakable[i]) <= 0)
				{
					i_ObjectsBreakable[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_BREAKBLES;
				}
			}
			SDKHook(entity, SDKHook_OnTakeDamagePost, Func_Breakable_Post);
		}
		else if(!StrContains(classname, "tf_projectile_syringe"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			//SDKHook_SpawnPost doesnt work
		}
		
		else if(!StrContains(classname, "tf_projectile_healing_bolt"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team_Player);
			//SDKHook_SpawnPost doesnt work
		}
		
		else if(!StrContains(classname, "tf_projectile_pipe_remote"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			ApplyExplosionDhook_Pipe(entity);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "tf_projectile_arrow"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "prop_dynamic"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics_multiplayer"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "tf_projectile_pipe"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			ApplyExplosionDhook_Pipe(entity);
			SDKHook(entity, SDKHook_SpawnPost, Is_Pipebomb);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "tf_projectile_rocket"))
		{
			SDKHook(entity, SDKHook_SpawnPost, ApplyExplosionDhook_Rocket);
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		}
		else if (!StrContains(classname, "tf_weapon_medigun")) 
		{
			Medigun_OnEntityCreated(entity);
		}
		else if (!StrContains(classname, "tf_weapon_handgun_scout_primary")) 
		{
			ScatterGun_Prevent_M2_OnEntityCreated(entity);
		}
		else if (!StrContains(classname, "tf_weapon_particle_cannon")) 
		{
			OnManglerCreated(entity);
		}
		else if(!StrContains(classname, "obj_"))
		{
			npc.bCantCollidieAlly = true;
			
			i_IsABuilding[entity] = true;
			for (int i = 0; i < ZR_MAX_BUILDINGS; i++)
			{
				if (EntRefToEntIndex(i_ObjectsBuilding[i]) <= 0)
				{
					i_ObjectsBuilding[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_BUILDINGS;
				}
			}
			SDKHook(entity, SDKHook_SpawnPost, Building_EntityCreatedPost);
		}
		/*
		else if(!StrContains(classname, "tf_gamerules_data"))
		{
			GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
		}
		*/
		else if(!StrContains(classname, "trigger_hurt"))
		{
			SDKHook(entity, SDKHook_StartTouch, SDKHook_SafeSpot_StartTouch);
			SDKHook(entity, SDKHook_EndTouch, SDKHook_SafeSpot_EndTouch);
		}
		else if(!StrContains(classname, "func_respawnroom"))
		{
			SDKHook(entity, SDKHook_StartTouch, SDKHook_RespawnRoom_StartTouch);
			SDKHook(entity, SDKHook_EndTouch, SDKHook_RespawnRoom_EndTouch);
		}
	}
	
}

public void SDKHook_SafeSpot_StartTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InSafeZone))
		i_InSafeZone[target]++;
}

public void SDKHook_SafeSpot_EndTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InSafeZone))
		i_InSafeZone[target]--;
}

public void SDKHook_RespawnRoom_StartTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InSafeZone) && GetEntProp(entity, Prop_Send, "m_iTeamNum") == GetEntProp(target, Prop_Send, "m_iTeamNum"))
		i_InSafeZone[target]++;
}

public void SDKHook_RespawnRoom_EndTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InSafeZone) && GetEntProp(entity, Prop_Send, "m_iTeamNum") == GetEntProp(target, Prop_Send, "m_iTeamNum"))
		i_InSafeZone[target]--;
}

public void Set_Projectile_Collision(int entity)
{
	if(IsValidEntity(entity) && GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Blue))
	{
		SetEntityCollisionGroup(entity, 27);
	}
}

public void Check_For_Team_Npc(int entity)
{
//	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		CClotBody npcstats = view_as<CClotBody>(entity);
		if(!npcstats.m_bThisNpcGotDefaultStats_INVERTED) //IF THIS IS FALSE, then that means that a baseboss spawned without getting default stats.
		{
			//ADD TELEPORT LOGIC IF NEEDED!!!
			RequestFrame(Check_For_Team_Npc_Delayed, EntIndexToEntRef(entity)); //outside plugins are doing something...., give them time to do their crap...
			return;
		}
		b_NpcHasDied[entity] = false;
		b_IsAlliedNpc[entity] = false;
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
		//	SDKHook(entity, SDKHook_TraceAttack, NPC_TraceAttack);
			SDKHook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
			SDKHook(entity, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);
			npcstats.bCantCollidieAlly = true;
			npcstats.bCantCollidie = false;
			b_IsAlliedNpc[entity] = true;
			if(!npcstats.m_bThisNpcGotDefaultStats_INVERTED) //IF THIS IS FALSE, then that means that a baseboss spawned without getting default stats.
			{
				npcstats.SetDefaultStatsZombieRiot(view_as<int>(TFTeam_Red));
			}
			
			if(npcstats.m_bThisEntityIgnored) //do not collide. This is just as a global rule.
			{
				npcstats.bCantCollidie = true;
			}
			
			SetEntProp(entity, Prop_Send, "m_bGlowEnabled", false);
			
			for (int i = 0; i < ZR_MAX_NPCS_ALLIED; i++)
			{
				if (EntRefToEntIndex(i_ObjectsNpcs_Allied[i]) <= 0)
				{
					i_ObjectsNpcs_Allied[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_NPCS_ALLIED;
				}
			}
			
		}	
		else
		{
			//This code only exists if a base_boss that gets summoned isnt a boss, and also isnt applied by the plugin, so it will default to a non boss
			//As a safety measure.
			//Todo: If any map has any base_boss, detect and apply.
			//Idea: detect if team 0, if yes, move to zombie team and apply boss status!
		//	PrintToChatAll("%i",GetCustomKeyValue(entity,"m_bThisEntityIgnored", "1", 2));
		//	SetCustomKeyValue(client, "m_bThisEntityIgnored", "0");
			
			SDKHook(entity, SDKHook_TraceAttack, NPC_TraceAttack);
			SDKHook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
			if(!npcstats.m_bThisNpcGotDefaultStats_INVERTED) //IF THIS IS FALSE, then that means that a baseboss spawned without getting default stats.
			{
				b_Map_BaseBoss_No_Layers[entity] = true;
				SDKHook(entity, SDKHook_OnTakeDamagePost, Map_BaseBoss_Damage_Post);
				npcstats.SetDefaultStatsZombieRiot(view_as<int>(TFTeam_Blue));
			}
			
			else
			{
				SDKHook(entity, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	
			}
			
			
			npcstats.bCantCollidie = true;
			npcstats.bCantCollidieAlly = false;
			b_Is_Blue_Npc[entity] = true;
			for (int i = 0; i < ZR_MAX_NPCS; i++)
			{
				if (EntRefToEntIndex(i_ObjectsNpcs[i]) <= 0)
				{
					i_ObjectsNpcs[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_NPCS;
				}
			}
			
		}
	}
}


public void Check_For_Team_Npc_Delayed(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		CClotBody npcstats = view_as<CClotBody>(entity);
		b_NpcHasDied[entity] = false;
		b_IsAlliedNpc[entity] = false;
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
		//	SDKHook(entity, SDKHook_TraceAttack, NPC_TraceAttack);
			SDKHook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
			SDKHook(entity, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);
			npcstats.bCantCollidieAlly = true;
			npcstats.bCantCollidie = false;
			b_IsAlliedNpc[entity] = true;
			if(!npcstats.m_bThisNpcGotDefaultStats_INVERTED) //IF THIS IS FALSE, then that means that a baseboss spawned without getting default stats.
			{
				npcstats.SetDefaultStatsZombieRiot(view_as<int>(TFTeam_Red));
			}
			
			if(npcstats.m_bThisEntityIgnored) //do not collide. This is just as a global rule.
			{
				npcstats.bCantCollidie = true;
			}
			
			SetEntProp(entity, Prop_Send, "m_bGlowEnabled", false);
			
			for (int i = 0; i < ZR_MAX_NPCS_ALLIED; i++)
			{
				if (EntRefToEntIndex(i_ObjectsNpcs_Allied[i]) <= 0)
				{
					i_ObjectsNpcs_Allied[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_NPCS_ALLIED;
				}
			}
			
		}	
		else
		{
			//This code only exists if a base_boss that gets summoned isnt a boss, and also isnt applied by the plugin, so it will default to a non boss
			//As a safety measure.
			//Todo: If any map has any base_boss, detect and apply.
			//Idea: detect if team 0, if yes, move to zombie team and apply boss status!
		//	PrintToChatAll("%i",GetCustomKeyValue(entity,"m_bThisEntityIgnored", "1", 2));
		//	SetCustomKeyValue(client, "m_bThisEntityIgnored", "0");
			
			SDKHook(entity, SDKHook_TraceAttack, NPC_TraceAttack);
			SDKHook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
			if(!npcstats.m_bThisNpcGotDefaultStats_INVERTED) //IF THIS IS FALSE, then that means that a baseboss spawned without getting default stats.
			{
				b_Map_BaseBoss_No_Layers[entity] = true;
				SDKHook(entity, SDKHook_OnTakeDamagePost, Map_BaseBoss_Damage_Post);
				npcstats.SetDefaultStatsZombieRiot(view_as<int>(TFTeam_Blue));
			}
			
			else
			{
				SDKHook(entity, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	
			}
			
			npcstats.bCantCollidie = true;
			npcstats.bCantCollidieAlly = false;
			b_Is_Blue_Npc[entity] = true;
			for (int i = 0; i < ZR_MAX_NPCS; i++)
			{
				if (EntRefToEntIndex(i_ObjectsNpcs[i]) <= 0)
				{
					i_ObjectsNpcs[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_NPCS;
				}
			}
			
		}
	}
}

public void Delete_instantly(int entity)
{
	RemoveEntity(entity);
}

public void Delete_instantly_Disolve(int entity) //arck, they are client side...
{
	RemoveEntity(entity);
}

/*
public void Delete_instantly_Laser_ball(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner <= MaxClients)
	{
		RemoveEntity(entity);
	}
	if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
	{
		b_Is_Npc_Rocket[entity] = true; 
	}
}
*/
public void OnEntityDestroyed(int entity)
{
	if(IsValidEntity(entity))
	{
		#if defined LagCompensation
		OnEntityDestroyed_LagComp(entity);
		#endif
		
		if(entity > MaxClients)
		{
			i_ExplosiveProjectileHexArray[entity] = 0; //reset on destruction.
			
			OnEntityDestroyed_BackPack(entity);
			
			RemoveNpcThingsAgain(entity);
			IsCustomTfGrenadeProjectile(entity, 0.0);
			
			if(h_NpcCollissionHookType[entity] != 0)
			{
				if(!DHookRemoveHookID(h_NpcCollissionHookType[entity]))
				{
					PrintToConsoleAll("Somehow Failed to unhook h_NpcCollissionHookType");
				}
			}
		}
	}
	
	OnEntityDestroyed_Build_On_Build(entity);
			
	if(Waves_Started())
	{
		RequestFrame(NPC_CheckDead);
	}
	NPC_Base_OnEntityDestroyed(entity);
}

public void NPC_SpawnNextRequestFrame(bool force)
{
	NPC_SpawnNext(false, false, false);
}

public void RemoveNpcThingsAgain(int entity)
{
	//Dont have to check for if its an npc or not, really doesnt matter in this case, just be sure to delete it cus why not
	//incase this breaks, add a baseboss check
	CleanAllAppliedEffects(entity);
	CleanAllApplied_Aresenal(entity);
	b_NpcForcepowerupspawn[entity] = 0;	
}
/*
//Looping function for above!
for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
{
	int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
}
*/

/*
//Looping function for above!
for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
{
	int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
}
*/

/*
//Looping function for above!
for(int entitycount; entitycount<i_MaxcountHomingMagicShot; entitycount++)
{
	int entity = EntRefToEntIndex(i_ObjectsHomingMagicShot[entitycount]);
}
*/


public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int index, Handle &item)
{
	if(!StrContains(classname, "tf_wear"))
	{
		switch(index)
		{	
			case 57, 131, 133, 231, 405, 406, 444, 608, 642, 1099, 1144:
			{
				if(!item)
					return Plugin_Stop;
				
				TF2Items_SetFlags(item, OVERRIDE_ATTRIBUTES);
				TF2Items_SetNumAttributes(item, 0);
				return Plugin_Changed;
			}
		}
	}
	/*else if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)
	{
		if(!item)
			return Plugin_Stop;
		
		TF2Items_SetFlags(item, OVERRIDE_ATTRIBUTES);
		TF2Items_SetNumAttributes(item, 5);
		TF2Items_SetAttribute(item, 0, 1, 0.623);
		TF2Items_SetAttribute(item, 1, 15, 0.0);
		TF2Items_SetAttribute(item, 2, 93, 0.0);
		TF2Items_SetAttribute(item, 3, 95, 0.0);
		TF2Items_SetAttribute(item, 4, 2043, 0.0);
		return Plugin_Changed;
	}*/
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(condition == TFCond_UberchargedCanteen)
	{
		TF2_AddCondition(client, TFCond_UberchargedCanteen, 3.0);
	}
	else if(condition == TFCond_Zoomed && thirdperson[client] && IsPlayerAlive(client))
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	}
	else if (condition == TFCond_Slowed && IsPlayerAlive(client))
	{
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if(IsValidClient(client)) //Need this, i think this has a chance to return -1 for some reason. probably disconnect.
	{
		if(condition == TFCond_Zoomed && thirdperson[client] && IsPlayerAlive(client))
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
		}
		else if(condition == TFCond_Slowed && IsPlayerAlive(client))
		{
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
		}
		else if (condition == TFCond_Dazed)
		{
			//Fixes full stuns not unhiding the active weapon when the stun ends
			// ty miku
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(weapon))
				SetEntProp(weapon, Prop_Send, "m_fEffects", GetEntProp(weapon, Prop_Send, "m_fEffects") & ~0x020);
		}
	}
}

public void TF2_OnWaitingForPlayersEnd()
{
	Queue_WaitingForPlayersEnd();
}

public Action SendProp_OnClientClass(int client, const char[] name, int &value, int element)
{
	if(WeaponClass[client] == TFClass_Unknown)
		return Plugin_Handled;

	value = view_as<int>(WeaponClass[client]);

	/*if(target == client)
	{
		static int LastClass[MAXTF2PLAYERS];
		if(LastClass[client] != value)
		{
			CreateTimer(0.1, Timer_ShowHudToClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			LastClass[client] = value;
		}
	}*/

	return Plugin_Changed;
}

bool InteractKey(int client, int weapon, bool Is_Reload_Button = false)
{
	if(weapon!=-1) //Just allow. || GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")<GetGameTime())
	{
		int entity = GetClientPointVisible(client); //So you can also correctly interact with players holding shit.
		if(entity > 0)
		{
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(Building_Interact(client, entity, Is_Reload_Button))
					return true;
					
				if(Store_Girogi_Interact(client, entity, buffer, Is_Reload_Button))
					return true;
					
				if(Escape_Interact(client, entity))
					return true;
				
				if(Store_Interact(client, entity, buffer))
					return true;
				
				if(Citizen_Interact(client, entity))
					return true;
				
			}
		}
	}
	return false;
}

void GiveXP(int client, int xp)
{
	XP[client] += RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue);
	int nextLevel = XpToLevel(XP[client]);
	if(nextLevel > Level[client])
	{
		static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
		ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);
//		SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "Level Up", nextLevel);
		
		bool found;
		for(Level[client]++; Level[client]<=nextLevel; Level[client]++)
		{
			if(Store_PrintLevelItems(client, Level[client]))
				found = true;
		}
		
		if(!found)
			PrintToChat(client, "%t", "None");
	}
}

public Action OnDropItem(int client, const char[] command, int args)
{
	Escape_DropItem(client);
	return Plugin_Handled;
}

int XpToLevel(int xp)
{
	return RoundToFloor(Pow(xp/200.0, 0.5));
}

int LevelToXp(int lv)
{
	return RoundToCeil(Pow(float(lv), 2.0)*200.0);
}
/*
public void Frame_OffCheats()
{
	CvarCheats.SetBool(false, false, false);
}
*/
public any Native_FuncToVal(Handle plugin, int numParams)
{
	return GetNativeCell(1);
}

public any Native_ApplyKillEffects(Handle plugin, int numParams)
{
	NPC_DeadEffects(GetNativeCell(1));
	return Plugin_Handled;
}

public any Native_GetWaveCounts(Handle plugin, int numParams)
{
	return CurrentRound;
}

//#file "Zombie Riot" broke in sm 1.11

public Action Hook_BlockUserMessageEx(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	char message[32];
	msg.ReadByte();
	msg.ReadByte();
	msg.ReadString(message, sizeof(message));
	
	if(strcmp(message, "#TF_Name_Change") == 0)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}


public void MapStartResetAll()
{
	Zero(f_WidowsWineDebuffPlayerCooldown);
	Zero(f_TempCooldownForVisualManaPotions);
	Zero(i_IsABuilding);
	Zero(f_DelayLookingAtHud);
	Zero(f_TimeUntillNormalHeal);
	Zero(Mana_Regen_Delay);
	Zero(Mana_Hud_Delay);
	Zero(delay_hud);
	Zero(healing_cooldown);
	Zero(Damage_dealt_in_total);
	Zero(Increaced_Overall_damage_Low);
	Zero(Resistance_Overall_Low);
	Zero(f_DisableDyingTimer);
	Zero(Increaced_Sentry_damage_Low);
	Zero(Increaced_Sentry_damage_High);
	Zero(Resistance_for_building_Low);
	Zero(f_RingDelayGift);
	Zero(Music_Timer);
	Music_ClearAll();
	Zero(f_BotDelayShow);
	NPC_Spawn_ClearAll();
	SDKHooks_ClearAll();
	Zero(f_OneShotProtectionTimer);
	Zero(f_BuildingIsNotReady);
	Building_ClearAll();
	Zero(f_TerroriserAntiSpamCd);
	Medigun_ClearAll();
	WindStaff_ClearAll();
	Lighting_Wand_Spell_ClearAll();
	Arrow_Spell_ClearAll();
	Survival_Knife_ClearAll();
	Zero(healing_cooldown);
	MedKit_ClearAll();
	Wand_autoaim_ClearAll();
	Wand_Elemental_2_ClearAll();
	Wand_Calcium_Spell_ClearAll();
	Wand_Fire_Spell_ClearAll();
	Wand_Default_Spell_ClearAll();
	Wand_Necro_Spell_ClearAll();
	RaidModeTime = 0.0;
	f_TimerTickCooldownRaid = 0.0;
	f_TimerTickCooldownShop = 0.0;
	CleanAllNpcArray();
	Zero2(Armor_table_money_limit);
	Zero2(i_Healing_station_money_limit);
	Zero2(Perk_Machine_money_limit);
	Zero2(Pack_A_Punch_Machine_money_limit);
	CleanAllBuildingEscape();
	Zero(f_ClientServerShowMessages);
	Zero(h_NpcCollissionHookType);
	M3_ClearAll();
	ZeroRage_ClearAll();
}
