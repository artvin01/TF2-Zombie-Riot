#pragma semicolon 1
#pragma newdecls required

#include <tf2_stocks>
#include <sdkhooks>
#include <collisionhook>
#include <clientprefs>
#include <dhooks>
#include <tf2items>
#include <tf_econ_data>
#include <tf2attributes>
#include <lambda>
#include <PathFollower>
#include <PathFollower_Nav>
#include <morecolors>
#tryinclude <menus-controller>

#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

#define NPC_HARD_LIMIT 42 
#define ZR_MAX_NPCS (NPC_HARD_LIMIT*2)
#define ZR_MAX_NPCS_ALLIED 42 //Never need more.
#define ZR_MAX_LAG_COMP 128 
#define ZR_MAX_BUILDINGS 64 //cant ever have more then 64 realisticly speaking
#define ZR_MAX_TRAPS 64
#define ZR_MAX_BREAKBLES 32
#define ZR_MAX_SPAWNERS 32 //cant ever have more then 32, if your map does, then what thed fuck are you doing ?
#define ZR_MAX_GIBCOUNT 20 //Anymore then this, and it will only summon 1 gib per zombie instead.

#define MAX_PLAYER_COUNT			12
#define MAX_PLAYER_COUNT_STRING		"12"
//cant do more then 12, more then 12 cause memory isssues because that many npcs can just cause that much lag


//#pragma dynamic    131072
//Allah This plugin has so much we need to do this.

// THESE ARE TO TOGGLE THINGS!

#define LagCompensation

#define HaveLayersForLagCompensation

//Not used cus i need all the performance i can get.

#define NoSendProxyClass

//maybe doing this will help lag, as there are no aim layers in zombies, they always look forwards no matter what.

//edit: No, makes you miss more often.


//Comment this out, and reload the plugin once ingame if you wish to have infinite cash.


ConVar CvarNoRoundStart;
ConVar CvarDisableThink;
ConVar CvarInfiniteCash;
ConVar CvarNoSpecialZombieSpawn;
//ConVar CvarEnablePrivatePlugins;
ConVar CvarMaxBotsForKillfeed;
ConVar CvarXpMultiplier;

bool Toggle_sv_cheats = false;
bool b_MarkForReload = false; //When you wanna reload the plugin on map change...
//#define CompensatePlayers

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
*/

//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!
//ATTENTION PLEASE!!!!!!!!!

#define FAR_FUTURE	100000000.0
#define MAXENTITIES	2048
#define MAXTF2PLAYERS	36

#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

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
ConVar zr_tagblacklist;
ConVar zr_tagwhitelist;
ConVar zr_minibossconfig;
ConVar zr_ignoremapconfig;
ConVar zr_smallmapbalancemulti;
ConVar zr_spawnprotectiontime;
//ConVar tf_bot_quota;

int CurrentGame;
bool b_GameOnGoing = true;
//bool b_StoreGotReset = false;
int CurrentCash;
bool LastMann;
bool EscapeMode;
bool EscapeModeForNpc;
bool DoingLagCompensation;

//bool RaidMode; 							//Is this raidmode?
float RaidModeScaling = 0.5;			//what multiplier to use for the raidboss itself?
float RaidModeTime = 0.0;
float f_TimerTickCooldownRaid = 0.0;
float f_TimerTickCooldownShop = 0.0;
int RaidBossActive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?
float Medival_Difficulty_Level = 0.0;	
int SalesmanAlive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?


int CurrentPlayers;
int PlayersAliveScaling;
int PlayersInGame;
int GlobalIntencity;
bool b_HasBeenHereSinceStartOfWave[MAXTF2PLAYERS];
ConVar cvarTimeScale;
ConVar CvarMpSolidObjects; //mp_solidobjects 
//ConVar CvarSvRollspeed; // sv_rollspeed 
ConVar CvarSvRollagle; // sv_rollangle
ConVar CvarTfMMMode; // tf_mm_servermode
Handle sv_cheats;
bool b_PhasesThroughBuildingsCurrently[MAXTF2PLAYERS];
Cookie CookieXP;
Cookie CookieScrap;
Cookie CookiePlayStreak;
Cookie Niko_Cookies;
Cookie CookieCache;
ArrayList Loadouts[MAXTF2PLAYERS];

//custom wave music.
char char_MusicString1[256];
int i_MusicLength1;
char char_MusicString2[256];
int i_MusicLength2;
//custom wave music.

float f_DelaySpawnsForVariousReasons;
int CurrentRound;
int CurrentWave = -1;
int StartCash;
float RoundStartTime;
char WhatDifficultySetting[64];
float healing_cooldown[MAXTF2PLAYERS];
float Damage_dealt_in_total[MAXTF2PLAYERS];
int i_Damage_dealt_in_total[MAXTF2PLAYERS];
int i_KillsMade[MAXTF2PLAYERS];
int i_Backstabs[MAXTF2PLAYERS];
bool i_HasBeenBackstabbed[MAXENTITIES];
int i_Headshots[MAXTF2PLAYERS];
bool i_HasBeenHeadShotted[MAXENTITIES];
float f_TimeAfterSpawn[MAXTF2PLAYERS];

int Healing_done_in_total[MAXTF2PLAYERS];
int i_BarricadeHasBeenDamaged[MAXTF2PLAYERS];
int Resupplies_Supplied[MAXTF2PLAYERS];

bool thirdperson[MAXTF2PLAYERS];
bool WaitingInQueue[MAXTF2PLAYERS];
int dieingstate[MAXTF2PLAYERS];
bool b_DoNotUnStuck[MAXENTITIES];

//bool Wand_Fired;

TFClassType CurrentClass[MAXTF2PLAYERS];
TFClassType WeaponClass[MAXTF2PLAYERS];
int CurrentAmmo[MAXTF2PLAYERS][Ammo_MAX];
int i_SemiAutoWeapon[MAXENTITIES];
int i_SemiAutoWeapon_AmmoCount[MAXENTITIES]; //idk like 10 slots lol
bool i_WeaponCannotHeadshot[MAXENTITIES];
float i_WeaponDamageFalloff[MAXENTITIES];

#define MAXSTICKYCOUNTTONPC 12
const int i_MaxcountSticky = MAXSTICKYCOUNTTONPC;
int i_StickyToNpcCount[MAXENTITIES][MAXSTICKYCOUNTTONPC]; //12 should be the max amount of stickies.
int i_StickyAccessoryLogicItem[MAXTF2PLAYERS]; //Item for stickies like "no bounce"

float f_SemiAutoStats_FireRate[MAXENTITIES];
int i_SemiAutoStats_MaxAmmo[MAXENTITIES];
float f_SemiAutoStats_ReloadTime[MAXENTITIES];

float f_MedigunChargeSave[MAXTF2PLAYERS][4];

	
int CashSpent[MAXTF2PLAYERS];
int CashSpentTotal[MAXTF2PLAYERS];
int CashRecievedNonWave[MAXTF2PLAYERS];
int Level[MAXTF2PLAYERS];
int XP[MAXTF2PLAYERS];
int Scrap[MAXTF2PLAYERS];
int Ammo_Count_Ready[MAXTF2PLAYERS];
//float Armor_Ready[MAXTF2PLAYERS];
float Increaced_Sentry_damage_Low[MAXENTITIES];
float Increaced_Sentry_damage_High[MAXENTITIES];
float Resistance_for_building_Low[MAXENTITIES];

int Armour_Level_Current[MAXTF2PLAYERS];


float Increaced_Overall_damage_Low[MAXENTITIES];
float Resistance_Overall_Low[MAXENTITIES];
float f_EmpowerStateSelf[MAXENTITIES];
float f_EmpowerStateOther[MAXENTITIES];

//This is for going through things via lag comp or other reasons to teleport things away.
//bool Do_Not_Regen_Mana[MAXTF2PLAYERS];

//float Resistance_for_building_High[MAXENTITIES];
int Armor_Charge[MAXTF2PLAYERS];
int Zombies_Currently_Still_Ongoing;

int Elevators_Currently_Build[MAXTF2PLAYERS]={0, ...};
int i_SupportBuildingsBuild[MAXTF2PLAYERS]={0, ...};
int i_BarricadesBuild[MAXTF2PLAYERS]={0, ...};
int i_WhatBuilding[MAXENTITIES]={0, ...};
bool Building_Constructed[MAXENTITIES]={false, ...};

int Elevator_Owner[MAXENTITIES]={0, ...};
bool Is_Elevator[MAXENTITIES]={false, ...};
int Dont_Crouch[MAXENTITIES]={0, ...};

int StoreWeapon[MAXENTITIES];
int i_CustomWeaponEquipLogic[MAXENTITIES]={0, ...};
int i_HealthBeforeSuit[MAXTF2PLAYERS]={0, ...};
bool i_ClientHasCustomGearEquipped[MAXTF2PLAYERS]={false, ...};

enum
{
	WEAPON_ARK = 1,
	WEAPON_FUSION = 2,
	WEAPON_BOUNCING = 3,
	WEAPON_MAIMMOAB = 4,
	WEAPON_CRIPPLEMOAB = 5
}

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
bool b_IsPlayerNiko[MAXTF2PLAYERS];

float delay_hud[MAXTF2PLAYERS];
float f_DelayBuildNotif[MAXTF2PLAYERS];
float f_ClientInvul[MAXTF2PLAYERS]; //Extra ontop of uber if they somehow lose it to some god damn reason.

int Current_Mana[MAXTF2PLAYERS];
float Mana_Regen_Delay[MAXTF2PLAYERS];
float Mana_Hud_Delay[MAXTF2PLAYERS];

int Armor_table_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int i_Healing_station_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Perk_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];
int Pack_A_Punch_Machine_money_limit[MAXTF2PLAYERS][MAXTF2PLAYERS];

int i_ThisEntityHasAMachineThatBelongsToClient[MAXENTITIES];
int i_ThisEntityHasAMachineThatBelongsToClientMoney[MAXENTITIES];

bool b_NpcHasDied[MAXENTITIES]={true, ...};
const int i_MaxcountNpc = ZR_MAX_NPCS;
int i_ObjectsNpcs[ZR_MAX_NPCS];

const int i_Maxcount_Apply_Lagcompensation = ZR_MAX_LAG_COMP;
int i_Objects_Apply_Lagcompensation[ZR_MAX_LAG_COMP];
bool b_DoNotIgnoreDuringLagCompAlly[MAXENTITIES]={false, ...};


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


bool b_IsAGib[MAXENTITIES];
			
int g_CarriedDispenser[MAXPLAYERS+1];
int i_BeingCarried[MAXENTITIES];
float f_BuildingIsNotReady[MAXTF2PLAYERS];

float GlobalAntiSameFrameCheck_NPC_SpawnNext;
//bool b_AllowBuildCommand[MAXPLAYERS + 1];

int Building_Mounted[MAXENTITIES];
bool b_SentryIsCustom[MAXENTITIES];
int i_NpcInternalId[MAXENTITIES];
bool b_IsCamoNPC[MAXENTITIES];

bool Doing_Handle_Mount[MAXPLAYERS + 1]={false, ...};
bool b_Doing_Buildingpickup_Handle[MAXPLAYERS + 1]={false, ...};

int i_PlayerToCustomBuilding[MAXPLAYERS + 1]={0, ...};

float f_TimeUntillNormalHeal[MAXENTITIES]={0.0, ...};
bool f_ClientServerShowMessages[MAXTF2PLAYERS];

float f_DisableDyingTimer[MAXPLAYERS + 1]={0.0, ...};
int i_DyingParticleIndication[MAXPLAYERS + 1]={-1, ...};

//Needs to be global.
int i_HowManyBombsOnThisEntity[MAXENTITIES][MAXTF2PLAYERS];
float f_TargetWasBlitzedByRiotShield[MAXENTITIES][MAXENTITIES];
float f_ChargeTerroriserSniper[MAXENTITIES];
bool b_npcspawnprotection[MAXENTITIES];
bool b_ThisNpcIsSawrunner[MAXENTITIES];
float f_LowTeslarDebuff[MAXENTITIES];
float f_HighTeslarDebuff[MAXENTITIES];
float f_VeryLowIceDebuff[MAXENTITIES];
float f_LowIceDebuff[MAXENTITIES];
float f_HighIceDebuff[MAXENTITIES];
bool b_Frozen[MAXENTITIES];
float f_TankGrabbedStandStill[MAXENTITIES];
float f_StunExtraGametimeDuration[MAXENTITIES];
bool b_PernellBuff[MAXENTITIES];
float f_MaimDebuff[MAXENTITIES];
float f_CrippleDebuff[MAXENTITIES];
int BleedAmountCountStack[MAXENTITIES];
int g_particleCritText;
int LastHitId[MAXENTITIES];
int DamageBits[MAXENTITIES];
float Damage[MAXENTITIES];
int LastHitWeaponRef[MAXENTITIES];
Handle IgniteTimer[MAXENTITIES];
int IgniteFor[MAXENTITIES];
int IgniteId[MAXENTITIES];
int IgniteRef[MAXENTITIES];

bool b_StickyIsSticking[MAXENTITIES];

RenderMode i_EntityRenderMode[MAXENTITIES]={RENDER_NORMAL, ...};
int i_EntityRenderColour1[MAXENTITIES]={255, ...};
int i_EntityRenderColour2[MAXENTITIES]={255, ...};
int i_EntityRenderColour3[MAXENTITIES]={255, ...};
int i_EntityRenderColour4[MAXENTITIES]={255, ...};
bool i_EntityRenderOverride[MAXENTITIES]={false, ...};

//6 wearables
int i_Wearable[MAXENTITIES][6];

float f_WidowsWineDebuff[MAXENTITIES];
float f_WidowsWineDebuffPlayerCooldown[MAXTF2PLAYERS];

int i_Hex_WeaponUsesTheseAbilities[MAXENTITIES];

#define ABILITY_NONE                 0          	//Nothing special.

#define ABILITY_M1				(1 << 1) 
#define ABILITY_M2				(1 << 2) 
#define ABILITY_R				(1 << 3) 	

#define FL_WIDOWS_WINE_DURATION 4.0


int i_HexCustomDamageTypes[MAXENTITIES]; //We use this to avoid using tf2's damage types in cases we dont want to, i.e. too many used, we cant use more. For like white stuff and all, this is just extra on what we already have.

//Use what already exists in tf2 please, only add stuff here if it needs extra spacing like ice damage and so on
//I dont want to use DMG_SHOCK for example due to its extra ugly effect thats annoying!

#define ZR_DAMAGE_NONE                	0          	//Nothing special.
#define ZR_DAMAGE_ICE					(1 << 1)
#define ZR_DAMAGE_LASER_NO_BLAST		(1 << 2)

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
int Armor_Level[MAXPLAYERS + 1]={0, ...}; 				//701
int Jesus_Blessing[MAXPLAYERS + 1]={0, ...}; 				//777
float Panic_Attack[MAXENTITIES]={0.0, ...};				//651
float Mana_Regen_Level[MAXPLAYERS]={0.0, ...};				//405
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
int b_PhaseThroughBuildingsPerma[MAXTF2PLAYERS];
bool b_FaceStabber[MAXTF2PLAYERS];
bool b_IsCannibal[MAXTF2PLAYERS];
bool b_HasGlassBuilder[MAXTF2PLAYERS];
bool b_LeftForDead[MAXTF2PLAYERS];

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

bool b_Is_Npc_Projectile[MAXENTITIES];
bool b_Is_Player_Projectile[MAXENTITIES];
bool b_Is_Player_Projectile_Through_Npc[MAXENTITIES];
bool b_Is_Blue_Npc[MAXENTITIES];
bool b_IsInUpdateGroundConstraintLogic;

int i_ExplosiveProjectileHexArray[MAXENTITIES];
int h_NpcCollissionHookType[MAXENTITIES];
#define EP_GENERIC                  		0          					// Nothing special.
#define EP_NO_KNOCKBACK              		(1 << 0)   					// No knockback
#define EP_DEALS_SLASH_DAMAGE              	(1 << 1)   					// Slash Damage (For no npc scaling, or ignoring resistances.)
#define EP_DEALS_CLUB_DAMAGE              	(1 << 2)   					// To deal melee damage.



bool b_Map_BaseBoss_No_Layers[MAXENTITIES];
int b_NpcForcepowerupspawn[MAXENTITIES]={0, ...}; 
float f_TempCooldownForVisualManaPotions[MAXPLAYERS+1];
float f_DelayLookingAtHud[MAXPLAYERS+1];
bool b_EntityIsArrow[MAXENTITIES];
bool b_EntityIsWandProjectile[MAXENTITIES];
int i_WandIdNumber[MAXENTITIES]; //This is to see what wand is even used. so it does its own logic and so on.
float f_WandDamage[MAXENTITIES]; //
int i_WandOwner[MAXENTITIES]; //
int i_WandWeapon[MAXENTITIES]; //
int i_WandParticle[MAXENTITIES]; //Only one allowed, dont use more. ever. ever ever. lag max otherwise.

int g_iLaserMaterial_Trace, g_iHaloMaterial_Trace;


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
bool b_Dont_Move_Allied_Npc[MAXENTITIES];
int b_BoundingBoxVariant[MAXENTITIES];
bool b_IsAloneOnServer = false;
bool b_ThisEntityIgnored[MAXENTITIES];
bool b_ThisEntityIgnoredEntirelyFromAllCollisions[MAXENTITIES];
bool b_ThisEntityIsAProjectileForUpdateContraints[MAXENTITIES];

bool b_IsPlayerABot[MAXPLAYERS+1];
int i_AmountDowned[MAXPLAYERS+1];

bool b_IgnoreWarningForReloadBuidling[MAXTF2PLAYERS];

bool b_SpecialGrigoriStore;
float f_ExtraDropChanceRarity = 1.0;

int CurrentGibCount = 0;
bool b_LimitedGibGiveMoreHealth[MAXENTITIES];
//GLOBAL npc things
bool b_thisNpcHasAnOutline[MAXENTITIES];
bool b_ThisNpcIsImmuneToNuke[MAXENTITIES];
bool applied_lastmann_buffs_once = false;

#include "shared/stocks_override.sp"
#include "shared/stocks.sp"

#if defined ZR
#include "zombie_riot/zr_core.sp"
#endif

#if defined RPG
#include "rpg_fortress/rpg_core.sp"
#endif

#include "shared/attributes.sp"
#include "shared/configs.sp"
#include "shared/convars.sp"
#include "shared/dhooks.sp"
#include "shared/sdkcalls.sp"
#include "shared/sdkhooks.sp"
#include "shared/npcs.sp"
#include "shared/store.sp"
#include "shared/viewchanges.sp"
#include "shared/npc_stats.sp"
#include "shared/database.sp"
#include "shared/thirdperson.sp"

#include "shared/buildonbuilding.sp"
#include "shared/custom_melee_logic.sp"

#if defined LagCompensation
#include "shared/baseboss_lagcompensation.sp"
#endif

#include "shared/npc_death_showing.sp"
#include "shared/wand_projectile.sp"

public Plugin myinfo =
{
	name		=	"NPC Gamemode Core",
	author		=	"Artvin & Batfoxkid & Mikusch",
	description	=	"Zombie Riot & RPG Fortress",
	version		=	"manual"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("FuncToVal");
	CreateNative("FuncToVal", Native_FuncToVal);
	
	Thirdperson_PluginLoad();
	_AskPluginLoad2();
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
	
	Commands_PluginStart();
	Events_PluginStart();
	
	OnPluginStart_();
	
	RegServerCmd("zr_update_blocked_nav", OnReloadBlockNav, "Reload Nav Blocks");
	RegAdminCmd("sm_play_viewmodel_anim", Command_PlayViewmodelAnim, ADMFLAG_ROOT, "Testing viewmodel animation manually");
	RegConsoleCmd("sm_make_niko", Command_MakeNiko, "Turn This player into niko");
	
	RegAdminCmd("sm_change_collision", Command_ChangeCollision, ADMFLAG_GENERIC, "change all npc's collisions");
	
	RegAdminCmd("sm_toggle_fake_cheats", Command_ToggleCheats, ADMFLAG_GENERIC, "ToggleCheats");
	RegAdminCmd("zr_reload_plugin", Command_ToggleReload, ADMFLAG_GENERIC, "Reload plugin on map change");
	
	RegAdminCmd("sm_test_hud_notif", Command_Hudnotif, ADMFLAG_GENERIC, "Hud Notif");
//	HookEvent("npc_hurt", OnNpcHurt);
	
	sv_cheats = FindConVar("sv_cheats");
	cvarTimeScale = FindConVar("host_timescale");
//	tf_bot_quota = FindConVar("tf_bot_quota");

	CvarMpSolidObjects = FindConVar("tf_solidobjects");
	if(CvarMpSolidObjects)
		CvarMpSolidObjects.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	CvarSvRollagle = FindConVar("sv_rollangle");
	if(CvarSvRollagle)
		CvarSvRollagle.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	CvarTfMMMode = FindConVar("tf_mm_servermode");
	if(CvarTfMMMode)
		CvarTfMMMode.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	
	ConVar cvar = FindConVar("tf_bot_count");
	cvar.Flags &= ~FCVAR_NOTIFY;
	
	int cvarCheatsflags = GetConVarFlags(sv_cheats);
	cvarCheatsflags &= ~FCVAR_NOTIFY;
	SetConVarFlags(sv_cheats, cvarCheatsflags);
	
	Niko_Cookies = new Cookie("zr_niko", "Are you a niko", CookieAccess_Protected);
	
	HookEntityOutput("logic_relay", "OnTrigger", OnRelayTrigger);
	//HookEntityOutput("logic_relay", "OnUser1", OnRelayFireUser1);
	
	LoadTranslations("zombieriot.phrases");
	LoadTranslations("zombieriot.phrases.zombienames");
	LoadTranslations("zombieriot.phrases.weapons.description");
	LoadTranslations("zombieriot.phrases.weapons");
	LoadTranslations("zombieriot.phrases.bob");
	LoadTranslations("zombieriot.phrases.icons"); 
	LoadTranslations("common.phrases");
	
	DHook_Setup();
	SDKCall_Setup();
	ConVar_PluginStart();
	NPC_PluginStart();
	SDKHook_PluginStart();
	Thirdperson_PluginStart();
	Database_PluginStart();
//	Building_PluginStart();
#if defined LagCompensation
	OnPluginStart_LagComp();
#endif
	NPC_Base_InitGamedata();
	
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
			if(!StrContains(buffer, "base_boss"))
				RemoveEntity(i);
		}
	}
	
}

//bool Reload_Plugin_Temp_Fix = false;

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
	PrecacheSound("player/crit_hit5.wav");
	PrecacheSound("player/crit_hit4.wav");
	PrecacheSound("player/crit_hit3.wav");
	PrecacheSound("player/crit_hit2.wav");
	PrecacheSound("player/crit_hit.wav");
	
	MapStartResetAll();
	EscapeMode = false;
	EscapeModeForNpc = false;
	
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "No Difficulty Selected Yet");
	
	RoundStartTime = 0.0;
	cvarTimeScale.SetFloat(1.0);
	Waves_MapStart();
	Music_MapStart();
#if !defined NoSendProxyClass
	DHook_MapStart();
#endif
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
	
	g_iHaloMaterial_Trace = PrecacheModel("materials/sprites/halo01.vmt");
	g_iLaserMaterial_Trace = PrecacheModel("materials/sprites/laserbeam.vmt");
	Zombies_Currently_Still_Ongoing = 0;
	// An info_populator entity is required for a lot of MvM-related stuff (preserved entity)
//	CreateEntityByName("info_populator");
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	CreateTimer(0.2, Timer_Temp, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, GetClosestSpawners, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	
	FormatEx(char_MusicString1, sizeof(char_MusicString1), "");
			
	FormatEx(char_MusicString2, sizeof(char_MusicString2), "");
			
	i_MusicLength1 = 0;
	i_MusicLength2 = 0;
	
	//Store_RandomizeNPCStore(true);
}

public void OnMapEnd()
{
	Store_RandomizeNPCStore(true);
	OnRoundEnd(null, NULL_STRING, false);
//	OnMapEnd_LagComp();
	OnMapEndWaves();
	ConVar_Disable();
}

public void OnConfigsExecuted()
{
	RequestFrame(Configs_ConfigsExecuted);
	if(b_MarkForReload)
	{
		ServerCommand("sm plugins reload zombie_riot");
		return;
	}
}
public Action OnReloadBlockNav(int args)
{
	UpdateBlockedNavmesh();
	return Plugin_Handled;
}

public Action Command_MakeNiko(int client, int args)
{
	if(b_IsPlayerNiko[client])
	{
		PrintToChat(client,"You are no longer niko, respawn to apply");
		b_IsPlayerNiko[client] = false;
	}
	else
	{
		PrintToChat(client,"You are now niko, respawn to apply");
		b_IsPlayerNiko[client] = true;
	}
	return Plugin_Handled;
}
public Action Command_PlayViewmodelAnim(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_play_viewmodel_anim <target> <index>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[12];
	GetCmdArg(2, buf, sizeof(buf));
	int anim_index = StringToInt(buf); 

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		int viewmodel = GetEntPropEnt(targets[target], Prop_Send, "m_hViewModel");
		if(viewmodel>MaxClients && IsValidEntity(viewmodel)) //For some reason it plays the horn anim again, just set it to idle!
		{
			int animation = anim_index;
			SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
		}
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


public Action Command_Hudnotif(int client, int args)
{
	char buf[64];
	GetCmdArg(1, buf, sizeof(buf));
	ShowGameText(client, buf, 0, "%t", "A Miniboss has Spawned..");
	
	return Plugin_Handled;
}

public Action Command_ToggleReload(int client, int args)
{
	if(b_MarkForReload)
	{
		PrintToChat(client, "The plugin WILL NOT reload on map change.");
		b_MarkForReload = false;
	}
	else
	{
		PrintToChat(client, "The plugin WILL reload on map change.");
		b_MarkForReload = true;
	}
	return Plugin_Handled;
}

public void OnClientAuthorized(int client)
{
	Database_ClientAuthorized(client);
}
					
public void OnClientPutInServer(int client)
{
	i_AmountDowned[client] = 0;
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
	WeaponClass[client] = TFClass_Unknown;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	i_CurrentEquippedPerk[client] = 0;
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	f_ShowHudDelayForServerMessage[client] = GetGameTime() + 50.0;

	i_HealthBeforeSuit[client] = 0;
	i_ClientHasCustomGearEquipped[client] = false;
	
	QueryClientConVar(client, "snd_musicvolume", ConVarCallback);
	
	if(CurrentRound)
		CashSpent[client] = RoundToCeil(float(CurrentCash) * 0.20);
	
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
	Tutorial_LoadCookies(client);
	char buffer[12];
	CookieXP.Get(client, buffer, sizeof(buffer));
	XP[client] = StringToInt(buffer);
	Level[client] = XpToLevel(XP[client]);

	CookieScrap.Get(client, buffer, sizeof(buffer));
	Scrap[client] = StringToInt(buffer);
	
	if(Scrap[client] < 0)
	{
		Scrap[client] = 0;
	}
	
	char buffer_niko[12];
	Niko_Cookies.Get(client, buffer_niko, sizeof(buffer_niko));
	if(StringToInt(buffer_niko) == 1)
	{
	 	b_IsPlayerNiko[client] = true;
	}
	else
	{
		b_IsPlayerNiko[client] = false;
	}
	
	Store_ClientCookiesCached(client);
}

public void OnClientDisconnect(int client)
{
	SetClientTutorialMode(client, false);
	SetClientTutorialStep(client, 0);
	Pets_ClientDisconnect(client);
	Queue_ClientDisconnect(client);
//	DHook_ClientDisconnect();
	Store_ClientDisconnect(client);
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
	WeaponClass[client] = TFClass_Unknown;
	Timer_Knife_Management[client] = INVALID_HANDLE;
	Escape_DropItem(client, false);
	if(XP[client] > 0)
	{
		char buffer[12];
		IntToString(XP[client], buffer, sizeof(buffer));
		CookieXP.Set(client, buffer);
		
		char buffer_niko[12];
		
		int niko_int = 0;
		
		if(b_IsPlayerNiko[client])
			niko_int = 1;
			
		IntToString(niko_int, buffer_niko, sizeof(buffer_niko));
		Niko_Cookies.Set(client, buffer_niko);
	}
	if(Scrap[client] > -1)
	{
		char buffer[12];
		IntToString(Scrap[client], buffer, sizeof(buffer));
		CookieScrap.Set(client, buffer);


	}
	Scrap[client] = -1;
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

/*public void OnGameFrame()
{
	//Wand_Homing();
	Cryo_SearchDamage();
}*/

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
	
	Escape_PlayerRunCmd(client);
	
	//tutorial stuff.
	Tutorial_MakeClientNotMove(client);
	
	if(buttons & IN_ATTACK)
	{
		int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(entity > MaxClients)
		{
			f_Actualm_flNextPrimaryAttack[entity] = GetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack");
			bool cancel_attack = false;
			cancel_attack = Attributes_Fire(client, entity);
			
			if(cancel_attack)
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	
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

		//	PrintToConsole(client,"Weapon Is %s", EntityFuncAttack2[weapon_holding]);

			if(EntityFuncAttack2[weapon_holding] && EntityFuncAttack2[weapon_holding]!=INVALID_FUNCTION)
			{
				bool result = false; //ignore crit.
				int slot = 2;
				Call_StartFunction(null, EntityFuncAttack2[weapon_holding]);
				Call_PushCell(client);
				Call_PushCell(weapon_holding);
				Call_PushCellRef(result);
				Call_PushCell(slot); //This is attack 2 :)
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
					int slot = 3;
					char classname[32];
					GetEntityClassname(weapon_holding, classname, 32);
					Call_StartFunction(null, EntityFuncAttack3[weapon_holding]);
					Call_PushCell(client);
					Call_PushCell(weapon_holding);
					Call_PushCellRef(result);
					Call_PushCell(slot);	//This is R :)
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
		
		if (IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
		{
			M3_Abilities(client);
		}
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
					RequestFrame(Movetype_walk, target);
					dieingstate[target] = 0;
					
					SetEntPropEnt(target, Prop_Send, "m_hObserverTarget", client);
					f_WasRecentlyRevivedViaNonWave[target] = GetGameTime() + 1.0;
					DHook_RespawnPlayer(target);
					
					float pos[3], ang[3];
					GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
					ang[2] = 0.0;
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
					ticks = Citizen_ReviveTicks(target, 2, client);
				}
				else
				{
					ticks = Citizen_ReviveTicks(target, 1, client);
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

public void Movetype_walk(int client)
{
	if(IsValidClient(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3])
{
	SemiAutoWeapon(client, buttons);
	Pets_PlayerRunCmdPost(client, buttons, angles);
	Medikit_healing(client, buttons);
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
		int slot = 1;
		Call_StartFunction(null, func);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushCellRef(result);
		Call_PushCell(slot);	//This is m1 :)
		Call_Finish(action);
	}
	
	if(i_SemiAutoWeapon[weapon])
	{
		i_SemiAutoWeapon_AmmoCount[weapon] -= 1;
		PrintHintText(client, "[%i/%i]", i_SemiAutoStats_MaxAmmo[weapon],i_SemiAutoWeapon_AmmoCount[weapon]);
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
	
	if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)
	{
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
		
		if(attack_speed > 5.0)
		{
			attack_speed *= 0.5; //Too fast! It makes animations barely play at all
		}
		
		TF2Attrib_SetByDefIndex(client, 201, attack_speed);
			
		if(!IsWandWeapon(weapon) && StrContains(classname, "tf_weapon_wrench"))
		{
			if(Panic_Attack[weapon] && !IsEngineerWeapon(weapon))
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
			if(!StrContains(classname, "tf_weapon_knife"))
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
		i_WhatBuilding[entity] = 0;
		StoreWeapon[entity] = -1;
		LastHitId[entity] = -1;
		DamageBits[entity] = -1;
		Damage[entity] = 0.0;
		LastHitWeaponRef[entity] = -1;
		IgniteTimer[entity] = INVALID_HANDLE;
		IgniteFor[entity] = -1;
		IgniteId[entity] = -1;
		IgniteRef[entity] = -1;

		//Normal entity render stuff, This should be set to these things on spawn, just to be sure.
		b_DoNotIgnoreDuringLagCompAlly[entity] = false;
		i_EntityRenderMode[entity] = RENDER_NORMAL;
		i_EntityRenderColour1[entity] = 255;
		i_EntityRenderColour2[entity] = 255;
		i_EntityRenderColour3[entity] = 255;
		i_EntityRenderColour4[entity] = 255;
		i_EntityRenderOverride[entity] = false;
		b_StickyIsSticking[entity] = false;

		b_ThisEntityIsAProjectileForUpdateContraints[entity] = false;
		b_EntityIsArrow[entity] = false;
		b_EntityIsWandProjectile[entity] = false;
		CClotBody npc = view_as<CClotBody>(entity);
		b_SentryIsCustom[entity] = false;
		b_Is_Npc_Projectile[entity] = false;
		b_Is_Player_Projectile[entity] = false;
		b_Is_Blue_Npc[entity] = false;
		EntityFuncAttack[entity] = INVALID_FUNCTION;
		EntityFuncAttack2[entity] = INVALID_FUNCTION;
		EntityFuncAttack3[entity] = INVALID_FUNCTION;
		EntityFuncReload4[entity] = INVALID_FUNCTION;
		b_Map_BaseBoss_No_Layers[entity] = false;
		b_Is_Player_Projectile_Through_Npc[entity] = false;
		i_IsABuilding[entity] = false;
		i_InSafeZone[entity] = 0;
		h_NpcCollissionHookType[entity] = 0;
		OnEntityCreated_Build_On_Build(entity, classname);
		SetDefaultValuesToZeroNPC(entity);
		i_SemiAutoWeapon[entity] = false;
		b_NpcHasDied[entity] = true;
		
		if(!StrContains(classname, "env_entity_dissolver"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly_Disolve);
		}
		else if(!StrContains(classname, "tf_ammo_pack"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
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
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		//	ApplyExplosionDhook_Rocket(entity);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "vgui_screen")) //Delete dispenser screen cut its really not needed at all, just takes up stuff for no reason
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "tf_weapon_wrench")) //need custom logic here
		{
			OnWrenchCreated(entity);
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
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
			//SDKHook_SpawnPost doesnt work
		}
		
		else if(!StrContains(classname, "tf_projectile_healing_bolt"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team_Player);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			//SDKHook_SpawnPost doesnt work
		}
		
		else if(!StrContains(classname, "tf_projectile_pipe_remote"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			ApplyExplosionDhook_Pipe(entity, true);
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "tf_projectile_arrow"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "prop_dynamic"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics_multiplayer"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics_override"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			b_Is_Player_Projectile[entity] = true; //Pretend its a player projectile for now.
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "func_door_rotating"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			b_Is_Player_Projectile[entity] = true; //Pretend its a player projectile for now.
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			b_Is_Player_Projectile[entity] = true; //Pretend its a player projectile for now.
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "tf_projectile_pipe"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			ApplyExplosionDhook_Pipe(entity, false);
			SDKHook(entity, SDKHook_SpawnPost, Is_Pipebomb);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
			//SDKHook_SpawnPost doesnt work
		}
		else if(!StrContains(classname, "tf_projectile_rocket"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			SDKHook(entity, SDKHook_SpawnPost, ApplyExplosionDhook_Rocket);
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
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
	{
		i_InSafeZone[target]++;
	}
}

public void SDKHook_SafeSpot_EndTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InSafeZone))
	{
		i_InSafeZone[target]--;
	}
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
			for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Make them lag compensate
			{
				if (EntRefToEntIndex(i_Objects_Apply_Lagcompensation[i]) <= 0)
				{
					i_Objects_Apply_Lagcompensation[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_LAG_COMP;
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
			for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Make them lag compensate
			{
				if (EntRefToEntIndex(i_Objects_Apply_Lagcompensation[i]) <= 0)
				{
					i_Objects_Apply_Lagcompensation[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_LAG_COMP;
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
		b_Is_Npc_Projectile[entity] = true; 
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
			NPC_CheckDead(entity);
			b_IsAGib[entity] = false;
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
	CleanAllApplied_Cryo(entity);
	b_NpcForcepowerupspawn[entity] = 0;	
	i_HexCustomDamageTypes[entity] = 0;
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
	if(condition == TFCond_Cloaked)
	{
		TF2_RemoveCondition(client, TFCond_Cloaked);
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
				
				//if(Store_Interact(client, entity, buffer))
				//	return true;
				
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
		SetEntityHealth(client, SDKCall_GetMaxHealth(client) * 3 / 2);
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "Level Up", nextLevel);
		
		bool found;
		int slots;
		
		for(Level[client]++; Level[client]<=nextLevel; Level[client]++)
		{
			if(Store_PrintLevelItems(client, Level[client]))
				found = true;
			
			if(!(Level[client] % 2))
				slots++;
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

public any Native_GetLevelCount(Handle plugin, int numParams)
{
	return Level[GetNativeCell(1)];
}

//#file "Zombie Riot" broke in sm 1.11


public void MapStartResetAll()
{
	GlobalCheckDelayAntiLagPlayerScale = 0.0;
	Zero(b_IsAGib);
	Reset_stats_starshooter();
	Zero(f_StuckTextChatNotif);
	Zero(i_ThisEntityHasAMachineThatBelongsToClientMoney);
	Zero(f_WasRecentlyRevivedViaNonWave);
	Zero(f_TimeAfterSpawn);
	Zero(i_Hex_WeaponUsesTheseAbilities);
	Zero(f_WidowsWineDebuffPlayerCooldown);
	Zero(f_WidowsWineDebuff);
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
	Wand_Cryo_Burst_ClearAll();
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
	Zero2(i_StickyToNpcCount);
	SniperMonkey_ClearAll();
	Weapon_Cspyknife_ClearAll();
	Zero(f_TutorialUpdateStep);
	Zero(f_DelayBuildNotif);
	Zero(f_ClientInvul);
	f_DelaySpawnsForVariousReasons = 0.0;
	Zero(i_KillsMade);
	Zero(i_Backstabs);
	Zero(i_HasBeenBackstabbed);
	Zero(i_Headshots);
	Zero(i_HasBeenHeadShotted);
	Zero(f_StuckTextChatNotif);
	Zero(b_LimitedGibGiveMoreHealth);
	Zero2(f_TargetWasBlitzedByRiotShield);
	Zero(f_StunExtraGametimeDuration);
	CurrentGibCount = 0;
	Zero(b_HasBeenHereSinceStartOfWave);
	Zero(f_EmpowerStateSelf);
	Zero(f_EmpowerStateOther);
}
