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
//#include <lambda>
#include <morecolors>
#include <cbasenpc>
#include <tf2utils>
#if !defined UseDownloadTable
#include <filenetwork>
#endif
#include <queue>
#include <profiler>

#pragma dynamic    131072

#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

#define NPC_HARD_LIMIT 40 
#define ZR_MAX_NPCS (NPC_HARD_LIMIT*4)
#define ZR_MAX_NPCS_ALLIED 40 //Never need more.
#define ZR_MAX_LAG_COMP 128 
#define ZR_MAX_BUILDINGS 128 //cant ever have more then 64 realisticly speaking
#define ZR_MAX_TRAPS 64
#define ZR_MAX_BREAKBLES 32
#define ZR_MAX_SPAWNERS 128
#define ZR_MAX_GIBCOUNT 12 //Anymore then this, and it will only summon 1 gib per zombie instead.

//#pragma dynamic    131072
//Allah This plugin has so much we need to do this.

// THESE ARE TO TOGGLE THINGS!
enum OSType
{
    OS_Linux = 0,
    OS_Windows,
    OS_Unknown
}

#define LagCompensation

#define HaveLayersForLagCompensation

//Not used cus i need all the performance i can get.

#define NoSendProxyClass

//maybe doing this will help lag, as there are no aim layers in zombies, they always look forwards no matter what.

//edit: No, makes you miss more often.


//Comment this out, and reload the plugin once ingame if you wish to have infinite cash.

public const float OFF_THE_MAP[3] = { 16383.0, 16383.0, -16383.0 };
public float OFF_THE_MAP_NONCONST[3] = { 16383.0, 16383.0, -16383.0 };

ConVar CvarRPGInfiniteLevelAndAmmo;
ConVar CvarDisableThink;
//ConVar CvarMaxBotsForKillfeed;
ConVar CvarXpMultiplier;
ConVar zr_downloadconfig;
ConVar CvarRerouteToIp;
ConVar CvarRerouteToIpAfk;
ConVar CvarKickPlayersAt;
ConVar CvarMaxPlayerAlive;

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

#define CONFIG_CFG	CONFIG ... "/%s.cfg"

#define DISPENSER_BLUEPRINT	"models/buildables/dispenser_blueprint.mdl"
#define SENTRY_BLUEPRINT	"models/buildables/sentry1_blueprint.mdl"

native any FuncToVal(Function bruh);

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
};

public const char ItemArchetype[][] =
{
	"",	// No archetype.	
//PRIMARY SECONDARY
	"Multi Pellet",		// 1
	"Rapid Fire",		// 2
	"Infinite Fire",	// 3
	"none",		// 4
	"Single Pellet",	// 5
	"Far Range",		// 6
	"Trap Master",		// 7 this can include builder weapons!
	"Explosive Mind",	// 8 Most Explosive weapons
//SUPPORT ITEMS
	"Team Support",		// 9
	"Debuff",			// 10
//MELEE'S
	"Brawler",			// 11 most fist melee's
	"Ambusher",			// 12 spy backstab weapons
	"Combatant",		// 13 Longsword any melee that has no special abilities, mostly
//	"Martial Artist",	// ?? Weapons with heavy skill usage such as judgement of iberia
//	edit: Too general, cant.
	"Aberration",		// 14 Melee weapons that summon things, currenly only fusion blade
	"Duelist",			// 15 Melee weapons that exell at taking down/fighting single targets, see ark due to parry
	"Lord",				// 16 Any melee that heavily has ranged attacks, see Lappland melee as the only one currently
	"Crusher",			// 17 Any melee that has very good aoe, see judgement of ibera or final hammer pap

	
//MAGE WEAPONS
	"Summoner",			// 18
	"Chain Caster",		// 19
	"Multi Caster",		// 20
	"Base Caster",		// 21

// CUSTOM
	"Abyssal Hunter",	// 22
	"Kazimierz",		// 23
	"Bloodletter",	//24, Vampire Knives fast-attack path
	"Bloody Butcher", //25, Vampire Knives cleaver path
	"Mythic Caster"	// 26		
};

public const int RenderColors_RPG[][] =
{
	{255, 255, 255, 255}, 	// 0
	{0, 255, 0, 255, 255}, 	//Green
	{ 65, 105, 225 , 255},	//Blue
	{ 255, 255, 0 , 255},	//yellow
	{ 178, 34, 34 , 255},	//Red
	{ 138, 43, 226 , 255},	//wat
	{0, 0, 0, 255}			//none, black.
};


Handle SyncHud_Notifaction;
Handle SyncHud_WandMana;
Handle g_hImpulse;
Handle g_hRecalculatePlayerBodygroups;

Handle g_hSetLocalOrigin;
Handle g_hSnapEyeAngles;
Handle g_hSetAbsVelocity;

bool DoingLagCompensation;

float f_BotDelayShow[MAXTF2PLAYERS];
float f_OneShotProtectionTimer[MAXTF2PLAYERS];
int i_EntityToAlwaysMeleeHit[MAXTF2PLAYERS];
//int Dont_Crouch[MAXENTITIES]={0, ...};

bool b_IsAloneOnServer = false;

ConVar cvarTimeScale;
ConVar CvarMpSolidObjects; //mp_solidobjects 
ConVar CvarTfMMMode; // tf_mm_servermode
ConVar sv_cheats;
ConVar nav_edit;
bool b_PhasesThroughBuildingsCurrently[MAXTF2PLAYERS];
bool b_LagCompNPC_No_Layers;
bool b_LagCompNPC_AwayEnemies;
bool b_LagCompNPC_ExtendBoundingBox;
bool b_LagCompNPC_BlockInteral;
bool b_LagCompNPC_OnlyAllies;

bool b_LagCompAlliedPlayers; //Make sure this actually compensates allies.

bool i_HasBeenBackstabbed[MAXENTITIES];
bool i_HasBeenHeadShotted[MAXENTITIES];

int g_particleImpactFlesh;
int g_particleImpactRubber;

float f_CooldownForHurtParticle[MAXENTITIES];	
float f_ClientConnectTime[MAXENTITIES];	
float f_BackstabDmgMulti[MAXENTITIES];
float f_BackstabCooldown[MAXENTITIES];
int i_BackstabHealEachTick[MAXENTITIES];
int i_BackstabHealTicks[MAXENTITIES];
bool b_BackstabLaugh[MAXENTITIES];
float f_BackstabBossDmgPenalty[MAXENTITIES];
float f_BackstabBossDmgPenaltyNpcTime[MAXENTITIES][MAXTF2PLAYERS];
float f_AntiStuckPhaseThroughFirstCheck[MAXTF2PLAYERS];
float f_AntiStuckPhaseThrough[MAXTF2PLAYERS];

bool thirdperson[MAXTF2PLAYERS];
bool b_DoNotUnStuck[MAXENTITIES];
bool b_PlayerIsInAnotherPart[MAXENTITIES];

float f_ShowHudDelayForServerMessage[MAXTF2PLAYERS];
//float Check_Standstill_Delay[MAXTF2PLAYERS];
//bool Check_Standstill_Applied[MAXTF2PLAYERS];

float max_mana[MAXTF2PLAYERS];
float mana_regen[MAXTF2PLAYERS];
bool has_mage_weapon[MAXTF2PLAYERS];

int i_WhatLevelForHudIsThisClientAt[MAXTF2PLAYERS];

//bool Wand_Fired;

TFClassType CurrentClass[MAXTF2PLAYERS];
TFClassType WeaponClass[MAXTF2PLAYERS];
int CurrentAmmo[MAXTF2PLAYERS][Ammo_MAX];
int i_SemiAutoWeapon[MAXENTITIES];
int i_SemiAutoWeapon_AmmoCount[MAXENTITIES]; //idk like 10 slots lol
bool i_WeaponCannotHeadshot[MAXENTITIES];
float i_WeaponDamageFalloff[MAXENTITIES];
float f_DelayAttackspeedAnimation[MAXTF2PLAYERS +1];
float f_DelayAttackspeedPreivous[MAXENTITIES]={1.0, ...};
float f_DelayAttackspeedPanicAttack[MAXENTITIES];
float f_ClientArmorRegen[MAXENTITIES];
int i_CustomWeaponEquipLogic[MAXENTITIES]={0, ...};
int i_CurrentEquippedPerk[MAXENTITIES];
int Building_Max_Health[MAXENTITIES]={0, ...};
int Building_Repair_Health[MAXENTITIES]={0, ...};

float f_ClientReviveDelay[MAXENTITIES];

#define MAXSTICKYCOUNTTONPC 12
const int i_MaxcountSticky = MAXSTICKYCOUNTTONPC;
int i_StickyToNpcCount[MAXENTITIES][MAXSTICKYCOUNTTONPC]; //12 should be the max amount of stickies.
int i_StickyAccessoryLogicItem[MAXTF2PLAYERS]; //Item for stickies like "no bounce"

float f_SemiAutoStats_FireRate[MAXENTITIES];
int i_SemiAutoStats_MaxAmmo[MAXENTITIES];
float f_SemiAutoStats_ReloadTime[MAXENTITIES];

float f_MedigunChargeSave[MAXTF2PLAYERS][4];

float Increaced_Sentry_damage_Low[MAXENTITIES];
float Increaced_Sentry_damage_High[MAXENTITIES];
float Resistance_for_building_Low[MAXENTITIES];

bool b_DisplayDamageHud[MAXTF2PLAYERS];
bool b_HudHitMarker[MAXTF2PLAYERS] = {true, ...};

float f_ArmorHudOffsetX[MAXTF2PLAYERS];
float f_ArmorHudOffsetY[MAXTF2PLAYERS];

float f_HurtHudOffsetX[MAXTF2PLAYERS];
float f_HurtHudOffsetY[MAXTF2PLAYERS];

float f_WeaponHudOffsetX[MAXTF2PLAYERS];
float f_WeaponHudOffsetY[MAXTF2PLAYERS];

float f_NotifHudOffsetX[MAXTF2PLAYERS];
float f_NotifHudOffsetY[MAXTF2PLAYERS];

bool b_HudScreenShake[MAXTF2PLAYERS] = {true, ...};
bool b_HudLowHealthShake[MAXTF2PLAYERS] = {true, ...};
float f_ZombieVolumeSetting[MAXTF2PLAYERS];

float Increaced_Overall_damage_Low[MAXENTITIES];
float Resistance_Overall_Low[MAXENTITIES];
float f_EmpowerStateSelf[MAXENTITIES];
float f_EmpowerStateOther[MAXENTITIES];

//This is for going through things via lag comp or other reasons to teleport things away.
//bool Do_Not_Regen_Mana[MAXTF2PLAYERS];;
bool i_ClientHasCustomGearEquipped[MAXTF2PLAYERS]={false, ...};
	
int Animation_Setting[MAXTF2PLAYERS];
int Animation_Index[MAXTF2PLAYERS];
int Animation_Retry[MAXTF2PLAYERS];
bool b_IsPlayerNiko[MAXTF2PLAYERS];

float delay_hud[MAXTF2PLAYERS];
float f_DelayBuildNotif[MAXTF2PLAYERS];
float f_ClientInvul[MAXENTITIES]; //Extra ontop of uber if they somehow lose it to some god damn reason.

int Current_Mana[MAXTF2PLAYERS];
float Mana_Regen_Delay[MAXTF2PLAYERS];
float RollAngle_Regen_Delay[MAXTF2PLAYERS];
float Mana_Hud_Delay[MAXTF2PLAYERS];

bool b_NpcHasDied[MAXENTITIES]={true, ...};
bool b_BuildingHasDied[MAXENTITIES]={true, ...};
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

bool i_NpcIsABuilding[MAXENTITIES];

const int i_MaxcountBreakable = ZR_MAX_BREAKBLES;
int i_ObjectsBreakable[ZR_MAX_BREAKBLES];


bool b_IsAGib[MAXENTITIES];
int i_NpcInternalId[MAXENTITIES];
bool b_IsCamoNPC[MAXENTITIES];
bool b_NoKillFeed[MAXENTITIES];

float f_TimeUntillNormalHeal[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZone[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZoneDamage[MAXENTITIES]={0.0, ...};
bool f_ClientServerShowMessages[MAXTF2PLAYERS];

//Needs to be global.
bool b_IsABow[MAXENTITIES];
bool b_IsAMedigun[MAXENTITIES];
int i_HowManyBombsOnThisEntity[MAXENTITIES][MAXTF2PLAYERS];
float f_BombEntityWeaponDamageApplied[MAXENTITIES][MAXTF2PLAYERS];
float f_TargetWasBlitzedByRiotShield[MAXENTITIES][MAXENTITIES];
bool b_npcspawnprotection[MAXENTITIES];
float f_LowTeslarDebuff[MAXENTITIES];
float f_HighTeslarDebuff[MAXENTITIES];
float f_Silenced[MAXENTITIES];
float f_VeryLowIceDebuff[MAXENTITIES];
float f_LowIceDebuff[MAXENTITIES];
float f_HighIceDebuff[MAXENTITIES];
bool b_Frozen[MAXENTITIES];
bool b_NoGravity[MAXENTITIES];
float f_TankGrabbedStandStill[MAXENTITIES];
float f_TimeFrozenStill[MAXENTITIES];
float f_BuildingAntiRaid[MAXENTITIES];
float f_StunExtraGametimeDuration[MAXENTITIES];
float f_RaidStunResistance[MAXENTITIES];
bool b_PernellBuff[MAXENTITIES];
float f_HussarBuff[MAXENTITIES];
float f_Ruina_Speed_Buff[MAXENTITIES];
float f_Ruina_Speed_Buff_Amt[MAXENTITIES];
float f_Ruina_Defense_Buff[MAXENTITIES];
float f_Ruina_Defense_Buff_Amt[MAXENTITIES];
float f_Ruina_Attack_Buff[MAXENTITIES];
float f_Ruina_Attack_Buff_Amt[MAXENTITIES];
float f_GodArkantosBuff[MAXENTITIES];
float f_Ocean_Buff_Weak_Buff[MAXENTITIES];
float f_Ocean_Buff_Stronk_Buff[MAXENTITIES];
float f_BannerDurationActive[MAXENTITIES];
float f_BuffBannerNpcBuff[MAXENTITIES];
float f_AncientBannerNpcBuff[MAXENTITIES];
float f_BattilonsNpcBuff[MAXENTITIES];
float f_MaimDebuff[MAXENTITIES];
float f_PassangerDebuff[MAXENTITIES];
float f_CrippleDebuff[MAXENTITIES];
float f_CudgelDebuff[MAXENTITIES];
float f_PotionShrinkEffect[MAXENTITIES];
int BleedAmountCountStack[MAXENTITIES];
bool b_HasBombImplanted[MAXENTITIES];
int g_particleCritText;
int g_particleMiniCritText;
int g_particleMissText;
int LastHitRef[MAXENTITIES];
int DamageBits[MAXENTITIES];
float Damage[MAXENTITIES];
int LastHitWeaponRef[MAXENTITIES];
Handle IgniteTimer[MAXENTITIES];
int IgniteFor[MAXENTITIES];
int IgniteId[MAXENTITIES];
int IgniteRef[MAXENTITIES];
float BurnDamage[MAXENTITIES];
int i_NervousImpairmentArrowAmount[MAXENTITIES];
float f_KnockbackPullDuration[MAXENTITIES];
float f_DoNotUnstuckDuration[MAXENTITIES];
float f_UnstuckTimerCheck[MAXENTITIES];
int i_PullTowardsTarget[MAXENTITIES];
float f_PullStrength[MAXENTITIES];

bool b_StickyIsSticking[MAXENTITIES];

RenderMode i_EntityRenderMode[MAXENTITIES]={RENDER_NORMAL, ...};
int i_EntityRenderColour1[MAXENTITIES]={255, ...};
int i_EntityRenderColour2[MAXENTITIES]={255, ...};
int i_EntityRenderColour3[MAXENTITIES]={255, ...};
int i_EntityRenderColour4[MAXENTITIES]={255, ...};
bool i_EntityRenderOverride[MAXENTITIES]={false, ...};

bool b_RocketBoomEffect[MAXENTITIES]={false, ...};
//6 wearables
int i_Wearable[MAXENTITIES][7];
int i_FreezeWearable[MAXENTITIES];
float f_WidowsWineDebuff[MAXENTITIES];
float f_WidowsWineDebuffPlayerCooldown[MAXENTITIES];
float f_SpecterDyingDebuff[MAXENTITIES];

int i_Hex_WeaponUsesTheseAbilities[MAXENTITIES];





#define ABILITY_NONE                 0          	//Nothing special.

#define ABILITY_M1				(1 << 1) 
#define ABILITY_M2				(1 << 2) 
#define ABILITY_R				(1 << 3) 	

#define FL_WIDOWS_WINE_DURATION 4.0


int i_HexCustomDamageTypes[MAXENTITIES]; //We use this to avoid using tf2's damage types in cases we dont want to, i.e. too many used, we cant use more. For like white stuff and all, this is just extra on what we already have.

//Use what already exists in tf2 please, only add stuff here if it needs extra spacing like ice damage and so on
//I dont want to use DMG_SHOCK for example due to its extra ugly effect thats annoying!

#define ZR_DAMAGE_NONE                			0          	//Nothing special.
#define ZR_DAMAGE_ICE							(1 << 1)
#define ZR_DAMAGE_LASER_NO_BLAST				(1 << 2)
#define ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED	(1 << 3)
#define ZR_DAMAGE_GIB_REGARDLESS				(1 << 4)
#define ZR_DAMAGE_IGNORE_DEATH_PENALTY			(1 << 5)
#define ZR_DAMAGE_REFLECT_LOGIC					(1 << 6)
#define ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS		(1 << 7)

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
#if defined ZR
int Armor_Level[MAXPLAYERS + 1]={0, ...}; 				//701
int Jesus_Blessing[MAXPLAYERS + 1]={0, ...}; 				//777
int i_BadHealthRegen[MAXENTITIES]={0, ...}; 				//805
bool b_HasGlassBuilder[MAXTF2PLAYERS];
bool b_HasMechanic[MAXTF2PLAYERS];
int i_MaxSupportBuildingsLimit[MAXTF2PLAYERS];
bool b_LeftForDead[MAXTF2PLAYERS];
bool b_StickyExtraGrenades[MAXTF2PLAYERS];
float f_LeftForDead_Cooldown[MAXTF2PLAYERS];
bool FinalBuilder[MAXENTITIES];
bool GlassBuilder[MAXENTITIES];
bool HasMechanic[MAXENTITIES];
int Building_Hidden_Prop[MAXENTITIES][2];
#endif
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

int i_BleedDurationWeapon[MAXENTITIES]={0, ...}; 				//149
int i_BurnDurationWeapon[MAXENTITIES]={0, ...}; 				//208
int i_ExtinquisherWeapon[MAXENTITIES]={0, ...}; 				//638
float f_UberOnHitWeapon[MAXENTITIES]={0.0, ...}; 				//17

int i_LowTeslarStaff[MAXENTITIES]={0, ...}; 				//3002
int i_HighTeslarStaff[MAXENTITIES]={0, ...}; 				//3000
int b_PhaseThroughBuildingsPerma[MAXTF2PLAYERS];
bool b_FaceStabber[MAXTF2PLAYERS];
bool b_IsCannibal[MAXTF2PLAYERS];

float f_NpcImmuneToBleed[MAXENTITIES];
bool b_NpcIsInvulnerable[MAXENTITIES];

Function EntityFuncAttack[MAXENTITIES];
Function EntityFuncAttackInstant[MAXENTITIES];
Function EntityFuncAttack2[MAXENTITIES];
Function EntityFuncAttack3[MAXENTITIES];
Function EntityFuncReload4[MAXENTITIES];
//Function EntityFuncReloadSingular5[MAXENTITIES];

int i_assist_heal_player[MAXTF2PLAYERS];
float f_assist_heal_player_time[MAXTF2PLAYERS];
float f_ClientMusicVolume[MAXTF2PLAYERS];
float f_BegPlayerToSetDuckConvar[MAXTF2PLAYERS];

#if defined RPG
int Level[MAXENTITIES];
bool b_DungeonContracts_BleedOnHit[MAXENTITIES];
bool b_DungeonContracts_FlatDamageIncreace5[MAXTF2PLAYERS];
bool b_DungeonContracts_ZombieSpeedTimes3[MAXENTITIES];
bool b_DungeonContracts_ZombieFlatArmorMelee[MAXENTITIES];
bool b_DungeonContracts_ZombieFlatArmorRanged[MAXENTITIES];
bool b_DungeonContracts_ZombieFlatArmorMage[MAXENTITIES];
bool b_DungeonContracts_ZombieArmorDebuffResistance[MAXENTITIES];
bool b_DungeonContracts_35PercentMoreDamage[MAXENTITIES];
bool b_DungeonContracts_25PercentMoreDamage[MAXENTITIES];
#endif

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE

bool b_Is_Npc_Projectile[MAXENTITIES];
bool b_Is_Player_Projectile[MAXENTITIES];
bool b_ForceCollisionWithProjectile[MAXENTITIES];
bool b_Is_Player_Projectile_Through_Npc[MAXENTITIES];
bool b_Is_Blue_Npc[MAXENTITIES];
bool b_CannotBeHeadshot[MAXENTITIES];
bool b_CannotBeBackstabbed[MAXENTITIES];
bool b_CannotBeStunned[MAXENTITIES];
bool b_CannotBeKnockedUp[MAXENTITIES];
bool b_CannotBeSlowed[MAXENTITIES];
float f_NpcTurnPenalty[MAXENTITIES];
bool b_IsInUpdateGroundConstraintLogic;

int i_ExplosiveProjectileHexArray[MAXENTITIES];
int h_NpcCollissionHookType[MAXENTITIES];
int h_NpcSolidHookType[MAXENTITIES];
#define EP_GENERIC                  		0          					// Nothing special.
#define EP_NO_KNOCKBACK              		(1 << 0)   					// No knockback
#define EP_DEALS_SLASH_DAMAGE              	(1 << 1)   					// Slash Damage (For no npc scaling, or ignoring resistances.)
#define EP_DEALS_CLUB_DAMAGE              	(1 << 2)   					// To deal melee damage.
#define EP_GIBS_REGARDLESS              	(1 << 3)   					// Even if its anything then blast, it will still gib.
#define EP_DEALS_PLASMA_DAMAGE             	(1 << 4)   					// for wands to deal plasma dmg
#define EP_DEALS_DROWN_DAMAGE             	(1 << 5)
#define EP_IS_ICE_DAMAGE              		(1 << 6)   					// Even if its anything then blast, it will still gib.

bool b_Map_BaseBoss_No_Layers[MAXENTITIES];
float f_TempCooldownForVisualManaPotions[MAXPLAYERS+1];
float f_DelayLookingAtHud[MAXPLAYERS+1];
bool b_EntityIsArrow[MAXENTITIES];
bool b_EntityIsWandProjectile[MAXENTITIES];
bool b_EntityIgnoredByShield[MAXENTITIES];
int i_WandIdNumber[MAXENTITIES]; //This is to see what wand is even used. so it does its own logic and so on.
float f_WandDamage[MAXENTITIES]; //
int i_WandOwner[MAXENTITIES]; //
int i_WandWeapon[MAXENTITIES]; //
int i_WandParticle[MAXENTITIES]; //Only one allowed, dont use more. ever. ever ever. lag max otherwise.
bool i_IsWandWeapon[MAXENTITIES]; 
bool i_IsWrench[MAXENTITIES]; 
bool i_InternalMeleeTrace[MAXENTITIES]; 
bool b_is_a_brush[MAXENTITIES]; 
bool b_IsVehicle[MAXENTITIES]; 
bool b_IsARespawnroomVisualiser[MAXENTITIES];
float f_ImmuneToFalldamage[MAXENTITIES]; 
int i_WeaponSoundIndexOverride[MAXENTITIES];
int i_WeaponModelIndexOverride[MAXENTITIES];
float f_WeaponSizeOverride[MAXENTITIES];
float f_WeaponSizeOverrideViewmodel[MAXENTITIES];

int g_iLaserMaterial_Trace, g_iHaloMaterial_Trace;


#define EXPLOSION_AOE_DAMAGE_FALLOFF 1.5
#define LASER_AOE_DAMAGE_FALLOFF 1.65
#define EXPLOSION_RADIUS 150.0
#define EXPLOSION_RANGE_FALLOFF 0.4 //obsolete.

//#define DO_NOT_COMPENSATE_THESE 211, 442, 588, 30665, 264, 939, 880, 1123, 208, 1178, 594, 954, 1127, 327, 1153, 425, 1081, 740, 130, 595, 207, 351, 1083, 58, 528, 1151, 996, 1092, 752, 308, 1007, 1004, 1005, 206, 305

bool b_Do_Not_Compensate[MAXENTITIES];
bool b_Only_Compensate_CollisionBox[MAXENTITIES];
bool b_Only_Compensate_AwayPlayers[MAXENTITIES];
bool b_ExtendBoundingBox[MAXENTITIES];
bool b_BlockLagCompInternal[MAXENTITIES];
bool b_Dont_Move_Building[MAXENTITIES];
bool b_Dont_Move_Allied_Npc[MAXENTITIES];
int b_BoundingBoxVariant[MAXENTITIES];
bool b_ThisEntityIgnored[MAXENTITIES];
bool b_ThisEntityIgnoredByOtherNpcsAggro[MAXENTITIES];
bool b_ThisEntityIgnoredEntirelyFromAllCollisions[MAXENTITIES];
bool b_ThisEntityIsAProjectileForUpdateContraints[MAXENTITIES];
bool b_IgnoredByPlayerProjectiles[MAXENTITIES];

bool b_IsPlayerABot[MAXPLAYERS+1];
float f_CooldownForHurtHud[MAXPLAYERS];	
int i_PreviousInteractedEntity[MAXENTITIES];
bool i_PreviousInteractedEntityDo[MAXENTITIES];
//Otherwise we get kicks if there is too much hurting going on.

Address g_hSDKStartLagCompAddress;
Address g_hSDKEndLagCompAddress;
bool g_GottenAddressesForLagComp;

//Handle g_hSDKIsClimbingOrJumping;
//SDKCalls
Handle g_hUpdateCollisionBox;
//Handle g_hGetVisionInterface;
//Handle g_hGetPrimaryKnownThreat;
//Handle g_hAddKnownEntity;
//Handle g_hGetKnownEntity;
//Handle g_hGetKnown;
//Handle g_hUpdatePosition;
//Handle g_hUpdateVisibilityStatus;
//DynamicHook g_hAlwaysTransmit;
// Handle g_hJumpAcrossGap;
Handle g_hGetVectors;
Handle g_hLookupActivity;
Handle g_hLookupSequence;
Handle g_hSDKWorldSpaceCenter;
Handle g_hStudio_FindAttachment;
Handle g_hGetAttachment;
Handle g_hResetSequenceInfo;
#if defined ZR
Handle g_hLookupBone;
Handle g_hGetBonePosition;
#endif
//Death

//PluginBot SDKCalls
Handle g_hGetSolidMask;
Handle g_hGetSolidMaskAlly;
//DHooks
//Handle g_hGetCurrencyValue;
DynamicHook g_DHookRocketExplode; //from mikusch but edited
DynamicHook g_DHookMedigunPrimary; 

Handle gH_BotAddCommand = INVALID_HANDLE;

int CurrentGibCount = 0;
bool b_LimitedGibGiveMoreHealth[MAXENTITIES];
//GLOBAL npc things

float played_headshotsound_already [MAXTF2PLAYERS];

int played_headshotsound_already_Case [MAXTF2PLAYERS];
int played_headshotsound_already_Pitch [MAXTF2PLAYERS];

float f_IsThisExplosiveHitscan[MAXENTITIES];
float f_CustomGrenadeDamage[MAXENTITIES];

float f_TraceAttackWasTriggeredSameFrame[MAXENTITIES];

enum
{
	STEPTYPE_NORMAL = 1,	
	STEPTYPE_COMBINE = 2,	
	STEPTYPE_PANZER = 3,
	STEPTYPE_COMBINE_METRO = 4,
	STEPTYPE_TANK = 5,
	STEPTYPE_ROBOT = 6,
	STEPTYPE_SEABORN = 7
}

enum
{
	STEPSOUND_NORMAL = 1,	
	STEPSOUND_GIANT = 2,	
}

enum
{
	BLEEDTYPE_NORMAL = 1,	
	BLEEDTYPE_METAL = 2,	
	BLEEDTYPE_RUBBER = 3,
	BLEEDTYPE_XENO = 4,
	BLEEDTYPE_SKELETON = 5,
	BLEEDTYPE_SEABORN = 6
}

//This model is used to do custom models for npcs, mainly so we can make cool animations without bloating downloads
#define NIKO_PLAYERMODEL "models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl"
#define COMBINE_CUSTOM_MODEL "models/zombie_riot/combine_attachment_police_216.mdl"

#define DEFAULT_UPDATE_DELAY_FLOAT 0.0//0.0151 //Make it 0 for now

#define DEFAULT_HURTDELAY 0.35 //Make it 0 for now


#define RAD2DEG(%1) ((%1) * (180.0 / FLOAT_PI))
#define DEG2RAD(%1) ((%1) * FLOAT_PI / 180.0)

#define	SHAKE_START					0			// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP					1			// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE				2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY				3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY		4			// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE		5			// Starts a shake that does NOT rumble the controller.

#define GORE_ABDOMEN	  (1 << 0)
#define GORE_FOREARMLEFT  (1 << 1)
#define GORE_HANDRIGHT	(1 << 2)
#define GORE_FOREARMRIGHT (1 << 3)
#define GORE_HEAD		 (1 << 4)
#define GORE_HEADLEFT	 (1 << 5)
#define GORE_HEADRIGHT	(1 << 6)
#define GORE_UPARMLEFT	(1 << 7)
#define GORE_UPARMRIGHT   (1 << 8)
#define GORE_HANDLEFT	 (1 << 9)


//I put these here so we can change them on fly if we need to, cus zombies can be really loud, or quiet.

#define NORMAL_ZOMBIE_SOUNDLEVEL	 80
#define NORMAL_ZOMBIE_VOLUME	 0.8

#define BOSS_ZOMBIE_SOUNDLEVEL	 90
#define BOSS_ZOMBIE_VOLUME	 1.0

#define RAIDBOSS_ZOMBIE_SOUNDLEVEL	 95
#define RAIDBOSSBOSS_ZOMBIE_VOLUME	 1.0

#define ARROW_TRAIL "effects/arrowtrail_blu.vmt"
#define ARROW_TRAIL_RED "effects/arrowtrail_red.vmt"

char g_ArrowHitSoundSuccess[][] = {
	"weapons/fx/rics/arrow_impact_flesh.wav",
	"weapons/fx/rics/arrow_impact_flesh2.wav",
	"weapons/fx/rics/arrow_impact_flesh3.wav",
	"weapons/fx/rics/arrow_impact_flesh4.wav",
};

char g_ArrowHitSoundMiss[][] = {
	"weapons/fx/rics/arrow_impact_concrete.wav",
	"weapons/fx/rics/arrow_impact_concrete2.wav",
	"weapons/fx/rics/arrow_impact_concrete4.wav",
};

char g_GibSound[][] = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
	"physics/flesh/flesh_bloody_break.wav",
};
char g_GibEating[][] = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
};

char g_GibSoundMetal[][] = {
	"ui/item_metal_pot_drop.wav",
	"ui/item_metal_scrap_drop.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_weapon_drop.wav",
};

char g_CombineSoldierStepSound[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};

char g_DefaultStepSound[][] = {
	"player/footsteps/concrete1.wav",
	"player/footsteps/concrete3.wav",
	"player/footsteps/concrete2.wav",
	"player/footsteps/concrete4.wav",
};

char g_CombineMetroStepSound[][] = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav",
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav",
};

char g_PanzerStepSound[][] = {
	"mvm/giant_common/giant_common_step_01.wav",
	"mvm/giant_common/giant_common_step_02.wav",
	"mvm/giant_common/giant_common_step_03.wav",
	"mvm/giant_common/giant_common_step_04.wav",
	"mvm/giant_common/giant_common_step_05.wav",
	"mvm/giant_common/giant_common_step_06.wav",
	"mvm/giant_common/giant_common_step_07.wav",
	"mvm/giant_common/giant_common_step_08.wav",
};

char g_RobotStepSound[][] = {
	"mvm/player/footsteps/robostep_01.wav",
	"mvm/player/footsteps/robostep_02.wav",
	"mvm/player/footsteps/robostep_03.wav",
	"mvm/player/footsteps/robostep_04.wav",
	"mvm/player/footsteps/robostep_05.wav",
	"mvm/player/footsteps/robostep_06.wav",
	"mvm/player/footsteps/robostep_07.wav",
	"mvm/player/footsteps/robostep_08.wav",
	"mvm/player/footsteps/robostep_09.wav",
	"mvm/player/footsteps/robostep_10.wav",
	"mvm/player/footsteps/robostep_11.wav",
	"mvm/player/footsteps/robostep_12.wav",
	"mvm/player/footsteps/robostep_13.wav",
	"mvm/player/footsteps/robostep_14.wav",
	"mvm/player/footsteps/robostep_15.wav",
	"mvm/player/footsteps/robostep_16.wav",
	"mvm/player/footsteps/robostep_17.wav",
	"mvm/player/footsteps/robostep_18.wav",

};

char g_TankStepSound[][] = {
	"infected_riot/tank/tank_walk_1_fix.mp3",
};

float f_ArrowDamage[MAXENTITIES];
int h_ArrowInflictorRef[MAXENTITIES];
Function i_ProjectileExtraFunction[MAXENTITIES];
float h_BonusDmgToSpecialArrow[MAXENTITIES];
int f_ArrowTrailParticle[MAXENTITIES]={INVALID_ENT_REFERENCE, ...};
bool b_IsEntityAlwaysTranmitted[MAXENTITIES];
bool b_IsEntityNeverTranmitted[MAXENTITIES];

//Arrays for npcs!
int i_NoEntityFoundCount[MAXENTITIES]={0, ...};
float f3_CustomMinMaxBoundingBox[MAXENTITIES][3];
bool b_DissapearOnDeath[MAXENTITIES];
bool b_IsGiant[MAXENTITIES];
bool b_Pathing[MAXENTITIES];
bool b_Jumping[MAXENTITIES];
bool b_AllowBackWalking[MAXENTITIES];
float fl_JumpStartTime[MAXENTITIES];
float fl_JumpStartTimeInternal[MAXENTITIES];
float fl_JumpCooldown[MAXENTITIES];
float fl_NextThinkTime[MAXENTITIES];
float fl_NextRunTime[MAXENTITIES];
float fl_NextMeleeAttack[MAXENTITIES];
float fl_Speed[MAXENTITIES];
int i_Target[MAXENTITIES];
float fl_GetClosestTargetTime[MAXENTITIES];
float fl_GetClosestTargetTimeTouch[MAXENTITIES];
int b_DoNotChangeTargetTouchNpc[MAXENTITIES];
float fl_GetClosestTargetNoResetTime[MAXENTITIES];
float fl_NextHurtSound[MAXENTITIES];
float fl_HeadshotCooldown[MAXENTITIES];
bool b_CantCollidie[MAXENTITIES];
bool b_CollidesWithEachother[MAXENTITIES];
bool b_CantCollidieAlly[MAXENTITIES];
bool b_BuildingIsStacked[MAXENTITIES];
bool b_bBuildingIsPlaced[MAXENTITIES];
bool b_XenoInfectedSpecialHurt[MAXENTITIES];
float fl_XenoInfectedSpecialHurtTime[MAXENTITIES];
bool b_DoGibThisNpc[MAXENTITIES];
float f3_SpawnPosition[MAXENTITIES][3];
int i_SpawnProtectionEntity[MAXENTITIES]={-1, ...};
float f3_VecPunchForce[MAXENTITIES][3];
float fl_NextDelayTime[MAXENTITIES];
float fl_NextIdleSound[MAXENTITIES];
float fl_AttackHappensMinimum[MAXENTITIES];
float fl_AttackHappensMaximum[MAXENTITIES];
bool b_AttackHappenswillhappen[MAXENTITIES];
bool b_thisNpcIsABoss[MAXENTITIES];
bool b_thisNpcIsARaid[MAXENTITIES]; //This is used for scaling.
bool b_TryToAvoidTraverse[MAXENTITIES];
bool b_NoKnockbackFromSources[MAXENTITIES];
int i_NpcWeight[MAXENTITIES]; //This is used for scaling.
bool b_StaticNPC[MAXENTITIES];
float f3_VecTeleportBackSave[MAXENTITIES][3];
float f3_VecTeleportBackSaveJump[MAXENTITIES][3];
bool b_NPCVelocityCancel[MAXENTITIES];
bool b_NPCTeleportOutOfStuck[MAXENTITIES];
float fl_DoSpawnGesture[MAXENTITIES];
bool b_isWalking[MAXENTITIES];
bool b_TeamGlowDefault[MAXENTITIES];
int i_StepNoiseType[MAXENTITIES];
int i_NpcStepVariation[MAXENTITIES];
int i_BleedType[MAXENTITIES];
int i_State[MAXENTITIES];
bool b_movedelay[MAXENTITIES];
float fl_NextRangedAttack[MAXENTITIES];
float fl_NextRangedAttackHappening[MAXENTITIES];
int i_AttacksTillReload[MAXENTITIES];
bool b_Gunout[MAXENTITIES];
float fl_ReloadDelay[MAXENTITIES];
float fl_InJump[MAXENTITIES];
float fl_DoingAnimation[MAXENTITIES];
float fl_NextRangedBarrage_Spam[MAXENTITIES];
float fl_NextRangedBarrage_Singular[MAXENTITIES];
bool b_NextRangedBarrage_OnGoing[MAXENTITIES];
float fl_NextTeleport[MAXENTITIES];
bool b_Anger[MAXENTITIES];
float fl_NextRangedSpecialAttack[MAXENTITIES];
float fl_NextRangedSpecialAttackHappens[MAXENTITIES];
bool b_RangedSpecialOn[MAXENTITIES];
float fl_RangedSpecialDelay[MAXENTITIES];
float fl_movedelay[MAXENTITIES];
float fl_NextChargeSpecialAttack[MAXENTITIES];
float fl_AngerDelay[MAXENTITIES];
bool b_FUCKYOU[MAXENTITIES];
bool b_FUCKYOU_move_anim[MAXENTITIES];
bool b_healing[MAXENTITIES];
bool b_new_target[MAXENTITIES];
float fl_ReloadIn[MAXENTITIES];
int i_TimesSummoned[MAXENTITIES];
float fl_AttackHappens_2[MAXENTITIES];
float fl_Charge_delay[MAXENTITIES];
float fl_Charge_Duration[MAXENTITIES];
bool b_movedelay_gun[MAXENTITIES];
bool b_Half_Life_Regen[MAXENTITIES];
float fl_Dead_Ringer_Invis[MAXENTITIES];
float fl_Dead_Ringer[MAXENTITIES];
bool b_Dead_Ringer_Invis_bool[MAXENTITIES];
int i_AttacksTillMegahit[MAXENTITIES];
int i_WeaponArchetype[MAXENTITIES];
int i_WeaponForceClass[MAXENTITIES];
int i_Viewmodel_PlayerModel[MAXENTITIES];
int i_Viewmodel_WeaponModel[MAXTF2PLAYERS];
int i_nm_body_client[MAXTF2PLAYERS];

float fl_NextFlameSound[MAXENTITIES];
float fl_FlamerActive[MAXENTITIES];
bool b_DoSpawnGesture[MAXENTITIES];
bool b_LostHalfHealth[MAXENTITIES];
bool b_LostHalfHealthAnim[MAXENTITIES];
bool b_DuringHighFlight[MAXENTITIES];
bool b_DuringHook[MAXENTITIES];
bool b_GrabbedSomeone[MAXENTITIES];
bool b_UseDefaultAnim[MAXENTITIES];
bool b_FlamerToggled[MAXENTITIES];
float fl_WaveScale[MAXENTITIES];
float fl_StandStill[MAXENTITIES];
float fl_GrappleCooldown[MAXENTITIES];
float fl_HookDamageTaken[MAXENTITIES];

bool b_PlayHurtAnimation[MAXENTITIES];
bool b_follow[MAXENTITIES];
bool b_movedelay_walk[MAXENTITIES];
bool b_movedelay_run[MAXENTITIES];
bool b_IsFriendly[MAXENTITIES];
bool b_stand_still[MAXENTITIES];
bool b_Reloaded[MAXENTITIES];
float fl_Following_Master_Now[MAXENTITIES];
float fl_DoingSpecial[MAXENTITIES];
float fl_ComeToMe[MAXENTITIES];
int i_MedkitAnnoyance[MAXENTITIES];
float fl_idle_talk[MAXENTITIES];
float fl_heal_cooldown[MAXENTITIES];
float fl_Hurtie[MAXENTITIES];
float fl_ExtraDamage[MAXENTITIES];
int i_Changed_WalkCycle[MAXENTITIES];
bool b_WasSadAlready[MAXENTITIES];
int i_TargetAlly[MAXENTITIES];
bool b_GetClosestTargetTimeAlly[MAXENTITIES];
float fl_Duration[MAXENTITIES];
int i_OverlordComboAttack[MAXENTITIES];
int i_TextEntity[MAXENTITIES][4];
float f_TextEntityDelay[MAXENTITIES];

int i_Activity[MAXENTITIES];
int i_PoseMoveX[MAXENTITIES];
int i_PoseMoveY[MAXENTITIES];
//Arrays for npcs!
bool b_bThisNpcGotDefaultStats_INVERTED[MAXENTITIES];
bool b_LagCompensationDeletedArrayList[MAXENTITIES];
float b_isGiantWalkCycle[MAXENTITIES];

bool Is_a_Medic[MAXENTITIES]; //THIS WAS INSIDE THE NPCS!

int i_CreditsOnKill[MAXENTITIES];
float f_CreditsOnKill[MAXENTITIES];

int i_InSafeZone[MAXENTITIES];
float fl_MeleeArmor[MAXENTITIES] = {1.0, ...};
float fl_RangedArmor[MAXENTITIES] = {1.0, ...};

float fl_Extra_MeleeArmor[MAXENTITIES] = {1.0, ...};
float fl_Extra_RangedArmor[MAXENTITIES] = {1.0, ...};
float fl_Extra_Speed[MAXENTITIES] = {1.0, ...};
float fl_Extra_Damage[MAXENTITIES] = {1.0, ...};

bool b_ScalesWithWaves[MAXENTITIES]; //THIS WAS INSIDE THE NPCS!

float f_StuckOutOfBoundsCheck[MAXENTITIES];

int g_particleImpactMetal;

char c_HeadPlaceAttachmentGibName[MAXENTITIES][64];
float f_ExplodeDamageVulnerabilityNpc[MAXENTITIES];

/*
	Above Are Variables/Defines That Are Shared

	Below Are Shared Overrides
*/

#include "shared/stocks_override.sp"
#include "shared/npc_stats.sp"	// NPC Stats is required here due to important methodmap
#include "shared/npc_collision_logic.sp"	// NPC collisions are sepearted for ease
#include "shared/npc_trace_filters.sp"	// NPC trace filters are sepearted for ease

/*
	Below Are Variables/Defines That Are Per Gamemode
*/

#if defined ZR
#include "zombie_riot/zr_core.sp"
#endif

#if defined RPG
#include "rpg_fortress/rpg_core.sp"
#endif

/*
	Below Are Non-Shared Variables/Defines
*/

#include "shared/attributes.sp"
#include "shared/commands.sp"
#include "shared/configs.sp"
#include "shared/convars.sp"
#include "shared/custom_melee_logic.sp"
#include "shared/dhooks.sp"
#include "shared/events.sp"
#include "shared/filenetwork.sp"
#include "shared/killfeed.sp"
#include "shared/npcs.sp"
#include "shared/sdkcalls.sp"
#include "shared/sdkhooks.sp"
#include "shared/stocks.sp"
#include "shared/store.sp"
#include "shared/thirdperson.sp"
#include "shared/viewchanges.sp"
#include "shared/wand_projectile.sp"

#include "shared/baseboss_lagcompensation.sp"

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
	
#if defined ZR
	ZR_PluginLoad();
#endif

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
	FileNetwork_PluginStart();

	RegServerCmd("zr_update_blocked_nav", OnReloadBlockNav, "Reload Nav Blocks");
	RegAdminCmd("sm_play_viewmodel_anim", Command_PlayViewmodelAnim, ADMFLAG_ROOT, "Testing viewmodel animation manually");
	RegConsoleCmd("sm_make_niko", Command_MakeNiko, "Turn This player into niko");
	
	RegAdminCmd("sm_toggle_fake_cheats", Command_ToggleCheats, ADMFLAG_GENERIC, "ToggleCheats");
	RegAdminCmd("zr_reload_plugin", Command_ToggleReload, ADMFLAG_GENERIC, "Reload plugin on map change");
	
	RegAdminCmd("sm_test_hud_notif", Command_Hudnotif, ADMFLAG_GENERIC, "Hud Notif");
	RegConsoleCmd("sm_getpos", GetPos);
//	HookEvent("npc_hurt", OnNpcHurt);
	
	sv_cheats = FindConVar("sv_cheats");
	nav_edit = FindConVar("nav_edit");
	cvarTimeScale = FindConVar("host_timescale");

	CvarMpSolidObjects = FindConVar("tf_solidobjects");
	if(CvarMpSolidObjects)
		CvarMpSolidObjects.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	CvarTfMMMode = FindConVar("tf_mm_servermode");
	if(CvarTfMMMode)
		CvarTfMMMode.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	
	//FindConVar("tf_bot_count").Flags &= ~FCVAR_NOTIFY;
	FindConVar("sv_tags").Flags &= ~FCVAR_NOTIFY;

	sv_cheats.Flags &= ~FCVAR_NOTIFY;
	
	LoadTranslations("zombieriot.phrases");
	LoadTranslations("zombieriot.phrases.weapons.description");
	LoadTranslations("zombieriot.phrases.weapons");
	LoadTranslations("zombieriot.phrases.bob");
	LoadTranslations("zombieriot.phrases.icons"); 
	LoadTranslations("zombieriot.phrases.rogue"); 
	LoadTranslations("zombieriot.phrases.item.gift.desc"); 
	LoadTranslations("common.phrases");
	
	DHook_Setup();
	SDKCall_Setup();
	ConVar_PluginStart();
	KillFeed_PluginStart();
	NPC_PluginStart();
	SDKHook_PluginStart();
	Thirdperson_PluginStart();
//	Building_PluginStart();
#if defined LagCompensation
	OnPluginStart_LagComp();
#endif
	NPC_Base_InitGamedata();
	
#if defined ZR
	ZR_PluginStart();
#endif
	
#if defined RPG
	RPG_PluginStart();
#endif
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

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "*")) != -1)
	{
		//if (IsValidEntity(i))
		{
			static char strClassname[64];
			GetEntityClassname(entity, strClassname, sizeof(strClassname));
			OnEntityCreated(entity,strClassname);
		}
	}
}

public void OnAllPluginsLoaded()
{
	NPC_OnAllPluginsLoaded();
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
	
#if defined ZR
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
//	PlayerIllgalMapCheck();
#endif
	
	return Plugin_Continue;
}

public void OnPluginEnd()
{
	ConVar_Disable();
	
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			DHook_UnhookClient(i);
			OnClientDisconnect(i);
		}
	}
	/*
	char classname[256];
	for(int i = MaxClients + 1; i < MAXENTITIES; i++)
	{
		if(IsValidEntity(i))
		{
			GetEntityClassname(i, classname, sizeof(classname)); 
			//prevent crash.

			if(StrContains(classname, "zr_base_npc"))
			{
				RemoveEntity(i);
				continue;
			}
		}
	}
	*/
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
	PrecacheSound("physics/metal/metal_box_impact_bullet2.wav");
	PrecacheSound("physics/metal/metal_box_impact_bullet3.wav");
	PrecacheSound("misc/halloween/spell_overheal.wav");
	PrecacheSound("weapons/gauss/fire1.wav");
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
	PrecacheSound("weapons/capper_shoot.wav");

	PrecacheSound("misc/halloween/clock_tick.wav");
	PrecacheSound("mvm/mvm_bomb_warning.wav");
	PrecacheSound("weapons/jar_explode.wav");
	PrecacheSound("player/crit_hit5.wav");
	PrecacheSound("player/crit_hit4.wav");
	PrecacheSound("player/crit_hit3.wav");
	PrecacheSound("player/crit_hit2.wav");
	PrecacheSound("player/crit_hit.wav");
	PrecacheSound("player/crit_hit_mini.wav");
	PrecacheSound("player/crit_hit_mini2.wav");
	PrecacheSound("player/crit_hit_mini3.wav");
	PrecacheSound("player/crit_hit_mini4.wav");
	PrecacheSound("mvm/mvm_revive.wav");

	PrecacheSoundCustom("zombiesurvival/headshot1.wav");
	PrecacheSoundCustom("zombiesurvival/headshot2.wav");
	PrecacheSoundCustom("zombiesurvival/hm.mp3");
	PrecacheSound("weapons/explode1.wav");
	PrecacheSound("weapons/explode2.wav");
	PrecacheSound("weapons/explode3.wav");
	PrecacheSound(")weapons/pipe_bomb1.wav");
	PrecacheSound(")weapons/pipe_bomb2.wav");
	PrecacheSound(")weapons/pipe_bomb3.wav");
	
	MapStartResetAll();
	
#if defined ZR
	ZR_MapStart();
#endif
	
#if defined RPG
	RPG_MapStart();
#endif

	Npc_Sp_Precache();
	OnMapStart_NPC_Base();
	SDKHook_MapStart();
	ViewChange_MapStart();
	MapStart_CustomMeleePrecache();
	WandStocks_Map_Precache();
	Zero(f_AntiStuckPhaseThroughFirstCheck);
	Zero(f_AntiStuckPhaseThrough);
	g_iHaloMaterial_Trace = PrecacheModel("materials/sprites/halo01.vmt");
	g_iLaserMaterial_Trace = PrecacheModel("materials/sprites/laserbeam.vmt");
	CreateTimer(0.2, Timer_Temp, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
#if defined ZR
	Store_RandomizeNPCStore(true);
	OnRoundEnd(null, NULL_STRING, false);
	OnMapEndWaves();
	NPC_MapEnd();
#endif

#if defined RPG
	RPG_MapEnd();
#endif

	ConVar_Disable();
	FileNetwork_MapEnd();
}

public void OnConfigsExecuted()
{
	if(b_MarkForReload)
	{
		ServerCommand("sm plugins reload zombie_riot");
		return;
	}
	
	Configs_ConfigsExecuted();
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

#if defined ZR
public Action Command_FakeDeathCount(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_fake_death_client <target> <count>");
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
		dieingstate[targets[target]] = anim_index;
	}
	return Plugin_Handled;
}
#endif

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

public Action GetPos(int client, int args)
{
	float pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	ReplyToCommand(client, "m_vecOrigin: %f %f %f", pos[0], pos[1], pos[2]);

	GetClientEyeAngles(client, pos);
	ReplyToCommand(client, "m_vecAngles: %f %f %f", pos[0], pos[1], pos[2]);
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

public void OnClientPostAdminCheck(int client)
{
#if defined ZR
	Database_ClientPostAdminCheck(client);
#endif
}
				
public void OnClientPutInServer(int client)
{
	KillFeed_ClientPutInServer(client);

	b_IsPlayerABot[client] = false;
	if(IsFakeClient(client))
	{
		TF2_ChangeClientTeam(client, TFTeam_Blue);
		DHook_HookClient(client);
		b_IsPlayerABot[client] = true;
		return;
	}
	f_ClientConnectTime[client] = GetGameTime() + 30.0;
	
	DHook_HookClient(client);
	FileNetwork_ClientPutInServer(client);
	SDKHook_HookClient(client);
	
//	f_LeftForDead_Cooldown[client] = GetGameTime() + 100.0;
	//do cooldown upon connection.
	AdjustBotCount();
	WeaponClass[client] = TFClass_Unknown;
	f_ClientReviveDelay[client] = 0.0;
	
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	f_HussarBuff[client] = 0.0;
	f_Ocean_Buff_Stronk_Buff[client] = 0.0;
	f_Ocean_Buff_Weak_Buff[client] = 0.0;
	f_Ruina_Speed_Buff[client] = 0.0;
	f_Ruina_Defense_Buff[client] = 0.0;
	f_Ruina_Attack_Buff[client] = 0.0;
	f_Ruina_Speed_Buff_Amt[client] = 0.0;
	f_Ruina_Defense_Buff_Amt[client] = 0.0;
	f_Ruina_Attack_Buff_Amt[client] = 0.0;
	f_ShowHudDelayForServerMessage[client] = GetGameTime() + 50.0;
	
#if defined ZR
	f_TutorialUpdateStep[client] = 0.0;
	ZR_ClientPutInServer(client);
#endif
	
#if defined RPG
	RPG_PutInServer(client);

	if(AreClientCookiesCached(client)) //Ingore this. This only bugs it out, just force it, who cares.
		OnClientCookiesCached(client);	
#endif

	QueryClientConVar(client, "snd_musicvolume", ConVarCallback);
	
}

#if defined RPG
public void OnClientCookiesCached(int client)
{
	RPG_ClientCookiesCached(client);
}
#endif

public void OnClientDisconnect(int client)
{
	FileNetwork_ClientDisconnect(client);
	KillFeed_ClientDisconnect(client);
	Store_ClientDisconnect(client);
	
	i_ClientHasCustomGearEquipped[client] = false;
	i_EntityToAlwaysMeleeHit[client] = 0;

#if defined ZR
	i_HealthBeforeSuit[client] = 0;
	f_ClientArmorRegen[client] = 0.0;
	b_HoldingInspectWeapon[client] = false;
	f_MedicCallIngore[client] = 0.0;
	ZR_ClientDisconnect(client);
	f_DelayAttackspeedAnimation[client] = 0.0;
	//Needed to reset attackspeed stuff.
	f_LeftForDead_Cooldown[client] = 0.0;
	f_IlligalStuck_ClientDelayCheck[client] = 0.0;
	for(int Count; Count<MAX_STUCK_PAST_CHECK; Count++)
	{
		f3_IlligalStuck_AveragePosClient[client][Count][0] = 0.0;
		f3_IlligalStuck_AveragePosClient[client][Count][1] = 0.0;
		f3_IlligalStuck_AveragePosClient[client][Count][2] = 0.0;
		i2_IlligalStuck_StuckTrueFalse[client][Count] = 0;
	}
#endif

	b_DisplayDamageHud[client] = false;
	WeaponClass[client] = TFClass_Unknown;

#if defined RPG
	RPG_ClientDisconnect(client);
#endif

	b_HudScreenShake[client] = true;
	b_HudLowHealthShake[client] = true;
	b_HudHitMarker[client] = true;
	f_ZombieVolumeSetting[client] = 0.0;
	b_IsPlayerNiko[client] = false;
}

public void OnClientDisconnect_Post(int client)
{
#if defined ZR
	ZR_OnClientDisconnect_Post();
#endif

	RequestFrame(CheckIfAloneOnServer);

#if defined RPG
	RPG_ClientDisconnect_Post();
#endif
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(b_IsPlayerABot[client])
		return Plugin_Continue;
	
#if defined LagCompensation
	OnPlayerRunCmd_Lag_Comp(client, angles, tickcount);
#endif

#if defined ZR
	Escape_PlayerRunCmd(client);
	
	//tutorial stuff.
	Tutorial_MakeClientNotMove(client);
#endif

	if(buttons & IN_ATTACK)
	{
		int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(entity > MaxClients)
		{
			
#if defined ZR
			f_Actualm_flNextPrimaryAttack[entity] = GetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack");
#endif
			
			bool cancel_attack = false;
			cancel_attack = Attributes_Fire(entity);
			
			if(cancel_attack)
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	
#if defined ZR
	static bool was_reviving[MAXTF2PLAYERS];
	static int was_reviving_this[MAXTF2PLAYERS];
#endif

	static int holding[MAXTF2PLAYERS];
	if(holding[client] & IN_ATTACK)
	{
		if(!(buttons & IN_ATTACK))
			holding[client] &= ~IN_ATTACK;
	}
	else if(buttons & IN_ATTACK)
	{
		holding[client] |= IN_ATTACK;
		
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding != -1)
		{
			if(EntityFuncAttackInstant[weapon_holding] && EntityFuncAttackInstant[weapon_holding]!=INVALID_FUNCTION)
			{
				bool result = false; //ignore crit.
				int slot = 1;
				Action action;
				Call_StartFunction(null, EntityFuncAttackInstant[weapon_holding]);
				Call_PushCell(client);
				Call_PushCell(weapon_holding);
				Call_PushCellRef(result);
				Call_PushCell(slot); //This is attack 1
				Call_Finish(action);
			}
		}
	}
	
	if(holding[client] & IN_ATTACK2)
	{
		if(!(buttons & IN_ATTACK2))
			holding[client] &= ~IN_ATTACK2;
	}
	else if(buttons & IN_ATTACK2)
	{
		holding[client] |= IN_ATTACK2;
		
#if defined ZR
		b_IgnoreWarningForReloadBuidling[client] = false;
#endif
		
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding != -1)
		{
			if(EntityFuncAttack2[weapon_holding] && EntityFuncAttack2[weapon_holding]!=INVALID_FUNCTION)
			{
				bool result = false; //ignore crit.
				int slot = 2;
				Action action;
				Call_StartFunction(null, EntityFuncAttack2[weapon_holding]);
				Call_PushCell(client);
				Call_PushCell(weapon_holding);
				Call_PushCellRef(result);
				Call_PushCell(slot); //This is attack 2 :)
				Call_Finish(action);
			}
			
			#if defined ZR
			char classname[36];
			GetEntityClassname(weapon_holding, classname, sizeof(classname));
			
			if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)
			{
				if(EntityFuncAttack2[weapon_holding] != MountBuildingToBack && TeutonType[client] == TEUTON_NONE)
				{
					b_IgnoreWarningForReloadBuidling[client] = true;
					Pickup_Building_M2(client, weapon, false);
				}
			}
			#endif
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
	
	if(holding[client] & IN_RELOAD)
	{
		if(!(buttons & IN_RELOAD))
			holding[client] &= ~IN_RELOAD;
	}
	else if(buttons & IN_RELOAD)
	{
		holding[client] |= IN_RELOAD;
		
		
		#if defined ZR
		if(angles[0] < -70.0)
		{
			int entity = EntRefToEntIndex(Building_Mounted[client]);
			if(IsValidEntity(entity))
			{
				Building_Interact(client, entity, true);
			}
		}
		else
		#endif
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
			
			if(weapon_holding != -1)
			{
				if(EntityFuncAttack3[weapon_holding] && EntityFuncAttack3[weapon_holding]!=INVALID_FUNCTION)
				{
					bool result = false; //ignore crit.
					int slot = 3;
					Action action;
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

	if(holding[client] & IN_SCORE)
	{
		if(!(buttons & IN_SCORE))
			holding[client] &= ~IN_SCORE;
	}
	else if(buttons & IN_SCORE)
	{
		holding[client] |= IN_SCORE;
		
#if defined ZR
		if(dieingstate[client] == 0)
		{
			if(WaitingInQueue[client])
			{
				Queue_Menu(client);
			}
			else if(b_HoldingInspectWeapon[client])
			{
				Store_OpenItemPage(client);
			}
			else
			{
				Store_Menu(client);
			}

		}
#endif
		
#if defined RPG
		FakeClientCommandEx(client, "sm_store");
#endif
	}
	
#if defined ZR

	if(holding[client] & IN_ATTACK3)
	{
		if(!(buttons & IN_ATTACK3))
			holding[client] &= ~IN_ATTACK3;
	}
	else if(buttons & IN_ATTACK3)
	{
		holding[client] |= IN_ATTACK3;
		
		if(TeutonType[client] == TEUTON_NONE)
		{
			if(IsPlayerAlive(client))
			{
				M3_Abilities(client);
			}
		}
	}
	float GameTime = GetGameTime();
	if(f_ClientReviveDelay[client] < GameTime)
	{
		f_ClientReviveDelay[client] = GameTime + 0.1;
		if((holding[client] & IN_RELOAD) && dieingstate[client] <= 0 && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
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
					f_DelayLookingAtHud[client] = GameTime + 0.5;
					f_DelayLookingAtHud[target] = GameTime + 0.5;
					PrintCenterText(client, "%t", "Reviving", dieingstate[target]);
					PrintCenterText(target, "%t", "You're Being Revived.", dieingstate[target]);
					was_reviving_this[client] = target;
					f_DisableDyingTimer[target] = GameTime + 0.15;
					if(i_CurrentEquippedPerk[client] == 1)
					{
						dieingstate[target] -= 12 * Rogue_ReviveSpeed();
					}
					else
					{
						dieingstate[target] -= 6 * Rogue_ReviveSpeed();
					}
					
					if(dieingstate[target] <= 0)
					{
						SetEntityMoveType(target, MOVETYPE_WALK);
						RequestFrame(Movetype_walk, target);
						dieingstate[target] = 0;
						
						SetEntPropEnt(target, Prop_Send, "m_hObserverTarget", client);
						f_WasRecentlyRevivedViaNonWave[target] = GameTime + 1.0;
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
						SetEntityHealth(target, 50);
						RequestFrame(SetHealthAfterRevive, target);
						int entity, i;
						while(TF2U_GetWearable(target, entity, i))
						{
							SetEntityRenderMode(entity, RENDER_NORMAL);
							SetEntityRenderColor(entity, 255, 255, 255, 255);
						}
						if(i_CurrentEquippedPerk[client] == 1)
						{
							StartHealingTimer(client, 0.1, float(SDKCall_GetMaxHealth(client)) * 0.02, 10);
							StartHealingTimer(target, 0.1, float(SDKCall_GetMaxHealth(target)) * 0.02, 10);
						}
						else
						{
							StartHealingTimer(client, 0.1, float(SDKCall_GetMaxHealth(client)) * 0.01, 10);
							StartHealingTimer(target, 0.1, float(SDKCall_GetMaxHealth(target)) * 0.01, 10);
						}
						
						SetEntityRenderMode(target, RENDER_NORMAL);
						SetEntityRenderColor(target, 255, 255, 255, 255);
						EmitSoundToAll("mvm/mvm_revive.wav", target, SNDCHAN_AUTO, 90, _, 1.0);
						MakePlayerGiveResponseVoice(target, 3); //Revived response!
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
					f_DelayLookingAtHud[client] = GameTime + 0.5;
					was_reviving_this[client] = target;
					if(i_CurrentEquippedPerk[client] == 1)
					{
						ticks = Citizen_ReviveTicks(target, 12 * Rogue_ReviveSpeed(), client);
					}
					else
					{
						ticks = Citizen_ReviveTicks(target, 6 * Rogue_ReviveSpeed(), client);
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
	}
	
//	Building_PlayerRunCmd(client, buttons);
#endif	// ZR

	return Plugin_Continue;
}

public void Movetype_walk(int client)
{
	if(IsValidClient(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon)
{
#if defined ZR
	SemiAutoWeapon(client, buttons);
	Pets_PlayerRunCmdPost(client, buttons, angles);
	Medikit_healing(client, buttons);
#endif

#if defined RPG
	RPG_PlayerRunCmdPost(client);
#endif
}

public void Update_Ammo(int  client)
{
	if(IsValidClient(client))
	{
		for(int i; i<Ammo_MAX; i++)
		{
			CurrentAmmo[client][i] = GetAmmo(client, i);
		}	
	}
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
#if defined ZR
	if(i_HealthBeforeSuit[client] == 0)
	{
		RequestFrame(Update_Ammo, client);
	}
#endif

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
		char buffer[128];
		for(int i; i < i_SemiAutoWeapon_AmmoCount[weapon]; i++)
		{
			buffer[i] = '|';
		}

		PrintHintText(client, buffer);
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
	
	float GameTime = GetGameTime();
	
	if(TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee)
	{
		//If it stoo fast then we dont want to do it eveytime, that can be laggy and it doesnt even change anything.
		//Also check if its the exact same number again, if it is, dont even set it.
		//0.25 is a sane number!
		if(f_DelayAttackspeedAnimation[client] < GameTime)
		{
			f_DelayAttackspeedAnimation[client] = GameTime + 0.25;

			float attack_speed;
			
			attack_speed = 1.0 / Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
			
			if(attack_speed > 5.0)
			{
				attack_speed *= 0.5; //Too fast! It makes animations barely play at all
			}
			if(f_DelayAttackspeedPreivous[client] != attack_speed) //Its not the exact same as before, dont set, no need.
			{
				Attributes_Set(client, 201, attack_speed);
			}
			f_DelayAttackspeedPreivous[client] = attack_speed;
		}

		if(!i_IsWandWeapon[weapon] && StrContains(classname, "tf_weapon_wrench"))
		{
			if(Panic_Attack[weapon] != 0.0 && !i_IsWrench[weapon])
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
				
				
				if (Attack_speed >= 1.15)
				{
					Attack_speed = 1.15; //hardcoding this lol
				}
				/*
				if(TF2_IsPlayerInCondition(client,TFCond_RuneHaste))
					Attack_speed = 1.0; //If they are last, dont alter attack speed, otherwise breaks melee, again.
					//would also make them really op
				*/
				if(f_DelayAttackspeedPanicAttack[weapon] != Attack_speed) //Its not the exact same as before, dont set, no need.
				{
					Attributes_Set(weapon, 396, Attack_speed);
				}
				f_DelayAttackspeedPanicAttack[weapon] = Attack_speed;
			}
			else
			{
				if(f_DelayAttackspeedPanicAttack[weapon] != 1.0) //Its not the exact same as before, dont set, no need.
				{
					Attributes_Set(weapon, 396, 1.0);
				}
				f_DelayAttackspeedPanicAttack[weapon] = 1.0;				
			}
			if(!StrContains(classname, "tf_weapon_knife") && i_InternalMeleeTrace[weapon])
			{
				DataPack pack = new DataPack();
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(EntIndexToEntRef(weapon));
				pack.WriteString(classname);
				Timer_Do_Melee_Attack(pack);
			}
			else if(i_InternalMeleeTrace[weapon])
			{
				DataPack pack = new DataPack();
				//The delay is usually 0.2 seconds.
			
		//		CreateDataTimer(0.2, Timer_Do_Melee_Attack, pack, TIMER_FLAG_NO_MAPCHANGE);

				//every 0.1 has 6 frames
				//soo..
				//we will use request frames in this case, reasoningbeing is that melee's should be relieable, timers have an ugly 0.1 delay thing where it
				//only does check every 0.1 seconds.
				//passanger ability for example could benifit from this, although thats unneeded.
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(EntIndexToEntRef(weapon));
				pack.WriteString(classname);
				RequestFrames(Timer_Do_Melee_Attack, 12, pack);
			}
		}
	}
	else
	{
		if(f_DelayAttackspeedAnimation[client] < GameTime)
		{
			f_DelayAttackspeedAnimation[client] = GameTime + 0.25;
			Attributes_Set(client, 201, 1.0);
			f_DelayAttackspeedPreivous[client] = 1.0;
		}
	}
	return action;
}

#if defined ZR
public void SDKHook_TeamSpawn_SpawnPost(int entity)
{
	for (int i = 0; i < ZR_MAX_SPAWNERS; i++)
	{
		if (!IsValidEntity(i_ObjectsSpawners[i]) || i_ObjectsSpawners[i] == 0)
		{
			Spawner_AddToArray(entity);
			i_ObjectsSpawners[i] = entity;
			return;
		}
	}

	PrintToChatAll("MAP HAS TOO MANY SPAWNERS, REPORT BUG");
	LogError("MAP HAS TOO MANY SPAWNERS");
}
#endif

public void OnEntityCreated(int entity, const char[] classname)
{
#if defined ZR
	if (!StrContains(classname, "info_player_teamspawn")) 
	{
		RequestFrame(SDKHook_TeamSpawn_SpawnPost, entity);
	}
#endif
	
	if (entity > 0 && entity <= 2048 && IsValidEntity(entity))
	{
		f_ClientInvul[entity] = 0.0;
		f_BackstabDmgMulti[entity] = 0.0;
		f_KnockbackPullDuration[entity] = 0.0;
		f_DoNotUnstuckDuration[entity] = 0.0;
		i_PullTowardsTarget[entity] = 0;
		f_PullStrength[entity] = 0.0;
		i_CustomWeaponEquipLogic[entity] = 0;
		b_LagCompensationDeletedArrayList[entity] = false;
		b_bThisNpcGotDefaultStats_INVERTED[entity] = false;
#if defined ZR
		SetEntitySpike(entity, false);
		i_WhatBuilding[entity] = 0;
		StoreWeapon[entity] = -1;
		b_SentryIsCustom[entity] = false;
		Building_Mounted[entity] = -1;
#endif
		i_WeaponSoundIndexOverride[entity] = 0;
		f_WeaponSizeOverride[entity] = 1.0;
		f_WeaponSizeOverrideViewmodel[entity] = 1.0;
		i_WeaponModelIndexOverride[entity] = 0;
		f_PotionShrinkEffect[entity] = 0.0; //here because inflictor can have it (arrows)
		f_ExplodeDamageVulnerabilityNpc[entity] = 1.0;
		f_DelayAttackspeedPreivous[entity] = 1.0;
		f_DelayAttackspeedPanicAttack[entity] = -1.0;
		f_HussarBuff[entity] = 0.0;
		f_Ruina_Speed_Buff[entity] = 0.0;
		f_Ruina_Defense_Buff[entity] = 0.0;
		f_Ruina_Attack_Buff[entity] = 0.0;
		f_Ruina_Speed_Buff_Amt[entity] = 0.0;
		f_Ruina_Defense_Buff_Amt[entity] = 0.0;
		f_Ruina_Attack_Buff_Amt[entity] = 0.0;
		f_GodArkantosBuff[entity] = 0.0;
		f_WidowsWineDebuffPlayerCooldown[entity] = 0.0;
		f_Ocean_Buff_Stronk_Buff[entity] = 0.0;
		b_NoKnockbackFromSources[entity] = false;
		f_Ocean_Buff_Weak_Buff[entity] = 0.0;
		i_CurrentEquippedPerk[entity] = 0;
		i_IsWandWeapon[entity] = false;
		i_IsWrench[entity] = false;
		LastHitRef[entity] = -1;
		DamageBits[entity] = -1;
		Damage[entity] = 0.0;
		LastHitWeaponRef[entity] = -1;
		IgniteTimer[entity] = INVALID_HANDLE;
		IgniteFor[entity] = -1;
		IgniteId[entity] = -1;
		IgniteRef[entity] = -1;
		Is_a_Medic[entity] = false;
		b_IsEntityAlwaysTranmitted[entity] = false;
		b_IsEntityNeverTranmitted[entity] = false;

		//Normal entity render stuff, This should be set to these things on spawn, just to be sure.
		b_DoNotIgnoreDuringLagCompAlly[entity] = false;
		i_EntityRenderMode[entity] = RENDER_NORMAL;
		i_EntityRenderColour1[entity] = 255;
		i_EntityRenderColour2[entity] = 255;
		i_EntityRenderColour3[entity] = 255;
		i_EntityRenderColour4[entity] = 255;
		i_EntityRenderOverride[entity] = false;
		b_StickyIsSticking[entity] = false;
		h_ArrowInflictorRef[entity] = -1;
		i_ProjectileExtraFunction[entity] = INVALID_FUNCTION;
		h_BonusDmgToSpecialArrow[entity] = 1.0;
		
		b_RocketBoomEffect[entity] = false;
		b_IsAlliedNpc[entity] = false;
		b_ThisEntityIsAProjectileForUpdateContraints[entity] = false;
		b_EntityIsArrow[entity] = false;
		b_EntityIsWandProjectile[entity] = false;
		b_EntityIgnoredByShield[entity] = false;
		i_WandIdNumber[entity] = -1;
		CClotBody npc = view_as<CClotBody>(entity);
		b_Is_Npc_Projectile[entity] = false;
		b_Is_Player_Projectile[entity] = false;
		b_Is_Blue_Npc[entity] = false;
		EntityFuncAttack[entity] = INVALID_FUNCTION;
		EntityFuncAttack2[entity] = INVALID_FUNCTION;
		EntityFuncAttack3[entity] = INVALID_FUNCTION;
		EntityFuncReload4[entity] = INVALID_FUNCTION;
		EntityFuncAttackInstant[entity] = INVALID_FUNCTION;
		b_Map_BaseBoss_No_Layers[entity] = false;
		b_Is_Player_Projectile_Through_Npc[entity] = false;
		b_ForceCollisionWithProjectile[entity] = false;
		i_IsABuilding[entity] = false;
		i_InSafeZone[entity] = 0;
		h_NpcCollissionHookType[entity] = 0;
		h_NpcSolidHookType[entity] = 0;
		SetDefaultValuesToZeroNPC(entity);
		i_SemiAutoWeapon[entity] = false;
		f_BannerDurationActive[entity] = 0.0;
		f_BuffBannerNpcBuff[entity] = 0.0;
		f_BattilonsNpcBuff[entity] = 0.0;
		f_AncientBannerNpcBuff[entity] = 0.0;
		b_NpcHasDied[entity] = true;
		b_BuildingHasDied[entity] = true;
		b_is_a_brush[entity] = false;
		b_IsVehicle[entity] = false;
		b_IsARespawnroomVisualiser[entity] = false;
		b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = false;
		b_IsAGib[entity] = false;
		b_ThisEntityIgnored[entity] = false;
		b_ThisEntityIgnoredByOtherNpcsAggro[entity] = false;
		b_IgnoredByPlayerProjectiles[entity] = false;
		b_DoNotUnStuck[entity] = false;
		f_NpcImmuneToBleed[entity] = 0.0;
		b_NpcIsInvulnerable[entity] = false;
		i_NpcInternalId[entity] = 0;
		b_IsABow[entity] = false;
		b_IsAMedigun[entity] = false;
		b_HasBombImplanted[entity] = false;
		i_IsABuilding[entity] = false;
		i_NervousImpairmentArrowAmount[entity] = 0;
		i_WeaponArchetype[entity] = 0;
		i_WeaponForceClass[entity] = 0;
		
		fl_Extra_MeleeArmor[entity] 		= 1.0;
		fl_Extra_RangedArmor[entity] 		= 1.0;
		fl_Extra_Speed[entity] 				= 1.0;
		fl_Extra_Damage[entity] 			= 1.0;
#if defined ZR
		HasMechanic[entity] = false;
		i_BuildingRecievedHordings[entity] = false;
		FinalBuilder[entity] = false;
		GlassBuilder[entity] = false;
		Resistance_for_building_High[entity] = 0.0;
		Armor_Charge[entity] = 0;
		i_EntityRecievedUpgrades[entity]	 	= ZR_UNIT_UPGRADES_NONE;
		i_EntityRecievedUpgrades_2[entity] 		= ZR_UNIT_UPGRADES_NONE;
#endif

		KillFeed_EntityCreated(entity);


#if defined ZR
		BarracksEntityCreated(entity);
		OnEntityCreated_Build_On_Build(entity, classname);
		Wands_Potions_EntityCreated(entity);
		Saga_EntityCreated(entity);
		Mlynar_EntityCreated(entity);
		Board_EntityCreated(entity);

		BannerOnEntityCreated(entity);
#endif

#if defined RPG
		RPG_EntityCreated(entity, classname);
		TextStore_EntityCreated(entity);
#endif

		if(!StrContains(classname, "env_entity_dissolver"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "instanced_scripted_scene"))
		{
			b_ThisEntityIgnored[entity] = true;
		}
		else if(!StrContains(classname, "tf_ammo_pack"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "item_currencypack_custom"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
#if defined RPG
		else if(!StrContains(classname, "phys_bone_follower"))
		{
			//every prop_Dynamic that spawns these  can make upto 16 entities, holy fuck
			//make a func_brush and use it to detect collisions!
			RemoveEntity(entity);
		}
#endif
		else if(!StrContains(classname, "tf_projectile_energy_ring"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		else if(!StrContains(classname, "func_brush"))
		{
			b_is_a_brush[entity] = true;
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
			#if defined ZR
			SDKHook(entity, SDKHook_SpawnPost, Wand_Necro_Spell);
			SDKHook(entity, SDKHook_SpawnPost, Wand_Calcium_Spell);
			#endif
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
		/*
		else if(!StrContains(classname, "zr_base_npc"))
		{
		//	SDKHook(entity, SDKHook_SpawnPost, Check_For_Team_Npc);
		//	Check_For_Team_Npc(EntIndexToEntRef(entity)); //Dont delay ?
		}
		*/
		else if(!StrContains(classname, "tf_weapon_compound_bow"))
		{
			b_IsABow[entity] = true;
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
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
		}
		else if(!StrContains(classname, "tf_projectile_flare"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team);
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(entity));
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
		else if(!StrContains(classname, "func_respawnroomvisualizer"))
		{
			b_IsARespawnroomVisualiser[entity] = true;
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
		else if(!StrContains(classname, "trigger_teleport")) //npcs think they cant go past this sometimes, lol
		{
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
			
#if defined ZR
			SDKHook(entity, SDKHook_SpawnPost, Is_Pipebomb);
#endif
			
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
		else if (!StrContains(classname, "tf_weapon_handgun_scout_primary")) 
		{
			ScatterGun_Prevent_M2_OnEntityCreated(entity);
		}
		else if (!StrContains(classname, "tf_weapon_medigun")) 
		{
			b_IsAMedigun[entity] = true;
			Medigun_OnEntityCreated(entity);
		}
#if defined ZR
		else if (!StrContains(classname, "tf_weapon_particle_cannon")) 
		{
			OnManglerCreated(entity);
		}
#endif
		
		else if(!StrContains(classname, "obj_"))
		{
		//	g_ObjStartUpgrading.HookEntity(Hook_Pre, entity, ObjStartUpgrading_SmackPre); //causes crashes.
			//prevent upgrades at all times.
			b_BuildingHasDied[entity] = false;
			npc.bCantCollidieAlly = true;
			i_IsABuilding[entity] = true;
			b_NoKnockbackFromSources[entity] = true;
			for (int i = 0; i < ZR_MAX_BUILDINGS; i++)
			{
				if (EntRefToEntIndex(i_ObjectsBuilding[i]) <= 0)
				{
					i_ObjectsBuilding[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_BUILDINGS;
				}
			}
			
#if defined ZR
			SDKHook(entity, SDKHook_SpawnPost, Building_EntityCreatedPost);
#endif
			
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
		else if(!StrContains(classname, "point_worldtext"))
		{
			Hook_DHook_UpdateTransmitState(entity);
			b_ThisEntityIgnored[entity] = true;
		}
		else if(!StrContains(classname, "info_particle_system"))
		{
			Hook_DHook_UpdateTransmitState(entity);
			b_ThisEntityIgnored[entity] = true;
		}
		else if(!StrContains(classname, "func_regenerate"))
		{
			SDKHook(entity, SDKHook_StartTouch, SDKHook_Regenerate_StartTouch);
			SDKHook(entity, SDKHook_Touch, SDKHook_Regenerate_Touch);
		}
		else if(!StrContains(classname, "prop_vehicle"))
		{
#if defined ZR
			Armor_Charge[entity] = 100000;
#endif
			b_IsVehicle[entity] = true;
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

public Action SDKHook_Regenerate_StartTouch(int entity, int target)
{
	if(target > 0 && target <= MaxClients)
	{
		TF2_RegeneratePlayer(target);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action SDKHook_Regenerate_Touch(int entity, int target)
{
	if(target > 0 && target <= MaxClients)
		return Plugin_Handled;

	return Plugin_Continue;
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
			AddEntityToLagCompList(entity);
			
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
			AddEntityToLagCompList(entity);
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
			AddEntityToLagCompList(entity);
			
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
			AddEntityToLagCompList(entity);
		}
	}
}

public void Delete_instantly(int entity)
{
	RemoveEntity(entity);
}

public void Delete_FrameLater(int ref) //arck, they are client side...
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
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
	if(entity > 0 && entity < MAXENTITIES)
	{
		OnEntityDestroyed_LagComp(entity);
		
		if(entity > MaxClients)
		{
			Attributes_EntityDestroyed(entity);
			i_WandIdNumber[entity] = -1;
			NPC_CheckDead(entity);
			i_ExplosiveProjectileHexArray[entity] = 0; //reset on destruction.
			
#if defined ZR
			SkyboxProps_OnEntityDestroyed(entity);
			OnEntityDestroyed_BackPack(entity);
			BuildingHordingsRemoval(entity);
#endif
			RemoveNpcThingsAgain(entity);
			IsCustomTfGrenadeProjectile(entity, 0.0);
			if(h_NpcCollissionHookType[entity] != 0)
			{
				if(!DHookRemoveHookID(h_NpcCollissionHookType[entity]))
				{
					PrintToConsoleAll("Somehow Failed to unhook h_NpcCollissionHookType");
				}
			}
			if(h_NpcSolidHookType[entity] != 0)
			{
				if(!DHookRemoveHookID(h_NpcSolidHookType[entity]))
				{
					PrintToConsoleAll("Somehow Failed to unhook h_NpcSolidHookType");
				}
			}
		}
		#if defined ZR
		OnEntityDestroyed_Build_On_Build(entity);
		#endif
	}
}

public void RemoveNpcThingsAgain(int entity)
{
	CleanAllAppliedEffects_BombImplanter(entity, false);
	//Dont have to check for if its an npc or not, really doesnt matter in this case, just be sure to delete it cus why not
	//incase this breaks, add a baseboss check
#if defined ZR
	CleanAllApplied_Aresenal(entity, true);
	b_NpcForcepowerupspawn[entity] = 0;	
#endif
	CleanAllApplied_Cryo(entity);
	i_HexCustomDamageTypes[entity] = 0;
}

public void CheckIfAloneOnServer()
{
	CountPlayersOnRed();
	b_IsAloneOnServer = false;
	int players;

#if defined ZR
	int player_alone;
#endif

	for(int client=1; client<=MaxClients; client++)
	{
		
#if defined ZR
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
#else
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client))
#endif
		
		{
			players += 1;

#if defined ZR
			player_alone = client;
#endif

		}
	}
	if(players == 1)
	{
		b_IsAloneOnServer = true;	
	}
	
#if defined ZR
	if (players < 4 && players > 0)
	{
		if (Bob_Exists)
			return;
		
		if(!CvarInfiniteCash.BoolValue)
		{
			Spawn_Bob_Combine(player_alone);
		}
		
	}
	else if (Bob_Exists)
	{
		Bob_Exists = false;
		NPC_Despawn_bob(EntRefToEntIndex(Bob_Exists_Index));
		Bob_Exists_Index = -1;
	}
#endif
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

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(condition == TFCond_Cloaked)
	{
		TF2_RemoveCondition(client, TFCond_Cloaked);
	}
	else if(condition == TFCond_SpawnOutline) //this is a hopefully prevention for client crashes, i am unsure why this happens.
	//Idea got from a client dump.
	{
		TF2_RemoveCondition(client, TFCond_SpawnOutline);
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
	}
}


bool InteractKey(int client, int weapon, bool Is_Reload_Button = false)
{
	if(weapon != -1) //Just allow. || GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")<GetGameTime())
	{
		static float vecEndOrigin[3];
		int entity = GetClientPointVisible(client, _, _, _, vecEndOrigin); //So you can also correctly interact with players holding shit.
		if(entity > 0)
		{
#if defined RPG
			if(b_is_a_brush[entity]) //THIS is for brushes that act as collision boxes for NPCS inside quests.sp
			{
				int entityfrombrush = BrushToEntity(entity);
				if(entityfrombrush != -1)
				{
					entity = entityfrombrush;
				}
			}
#endif

#if defined ZR
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{

				if (b_Is_Blue_Npc[entity])
					return false;
					
				if(Building_Interact(client, entity, Is_Reload_Button))
					return true;
					
				if(Store_Girogi_Interact(client, entity, buffer, Is_Reload_Button))
					return true;

				if (TeutonType[client] == TEUTON_WAITING)
					return false;

				if(Escape_Interact(client, entity))
					return true;
				
				//if(Store_Interact(client, entity, buffer))
				//	return true;

				if(Citizen_Interact(client, entity))
					return true;
				
				if(Is_Reload_Button && BarrackBody_Interact(client, entity))
					return true;
				
				if (b_Is_Blue_Npc[entity])
					return false;
			}
#endif
					
#if defined RPG
			if(TextStore_Interact(client, entity, Is_Reload_Button))
				return true;
			
			if(Tinker_Interact(client, entity, weapon))
				return true;

			if(Quests_Interact(client, entity))
				return true;
			
			if(Dungeon_Interact(client, entity))
				return true;

			if(AllyNpcInteract(client, entity, weapon))
				return true;
#endif
		
		}
		
#if defined RPG
		else
		{
			if(Garden_Interact(client, vecEndOrigin))
				return true;
		}
#endif
		
	}
	return false;
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

//#file "Zombie Riot" broke in sm 1.11

static void MapStartResetAll()
{
	Zero(i_CustomWeaponEquipLogic);
	Zero(b_IsAGib);
	Zero(i_Hex_WeaponUsesTheseAbilities);
	Zero(f_WidowsWineDebuffPlayerCooldown);
	Zero(f_WidowsWineDebuff);
	Zero(f_TempCooldownForVisualManaPotions);
	Zero(i_IsABuilding);
	Zero(f_ImmuneToFalldamage);
	Zero(f_DelayLookingAtHud);
	Zero(f_TimeUntillNormalHeal);
	Zero(f_ClientWasTooLongInsideHurtZone);
	Zero(f_ClientWasTooLongInsideHurtZoneDamage);
	Zero(Mana_Regen_Delay);
	Zero(RollAngle_Regen_Delay);
	Zero(Mana_Hud_Delay);
	Zero(delay_hud);
	Zero(Increaced_Overall_damage_Low);
	Zero(Resistance_Overall_Low);
	Zero(Increaced_Sentry_damage_Low);
	Zero(Increaced_Sentry_damage_High);
	Zero(Resistance_for_building_Low);
	Zero(f_BotDelayShow);
	SDKHooks_ClearAll();
	Zero(f_OneShotProtectionTimer);
	CleanAllNpcArray();
	Zero(f_ClientServerShowMessages);
	Zero(h_NpcCollissionHookType);
	Zero(h_NpcSolidHookType);
	Zero2(i_StickyToNpcCount);
	Zero(f_DelayBuildNotif);
	Zero(f_ClientInvul);
	Zero(i_HasBeenBackstabbed);
	Zero(i_HasBeenHeadShotted);
	Zero(b_LimitedGibGiveMoreHealth);
	Zero2(f_TargetWasBlitzedByRiotShield);
	Zero(f_StunExtraGametimeDuration);
	CurrentGibCount = 0;
	Zero(f_EmpowerStateSelf);
	Zero(f_EmpowerStateOther);
}

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
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

//ty miku for tellingg

public void ConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientMusicVolume[client] = StringToFloat(cvarValue);
}

public void ConVarCallbackDuckToVolume(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
	{
		if(f_BegPlayerToSetDuckConvar[client] < GetGameTime())
		{
			f_BegPlayerToSetDuckConvar[client] = GetGameTime() + 300.0;
			if(StringToFloat(cvarValue) < 0.9)
			{
				SetGlobalTransTarget(client);
				PrintToChat(client,"%t", "Show Grigori Mute Hint Message");
			}
		}
	}
}

public Action AdminCheckKick(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		int KickAt;

		if(CvarKickPlayersAt.IntValue > 0)
		{
			KickAt = CvarKickPlayersAt.IntValue;
		}
		else
		{
			KickAt = CvarMaxPlayerAlive.IntValue;
		}

		int playersOnServer = CountPlayersOnServer();

		if(playersOnServer > (KickAt))
		{
			for(int clientkick=1; clientkick<=MaxClients; clientkick++)
			{
				if(IsClientInGame(clientkick))
				{
					if(!IsFakeClient(clientkick) && GetClientTeam(clientkick) < 2 && f_ClientConnectTime[clientkick] < GetGameTime())
					{
						if(!(CheckCommandAccess(clientkick, "sm_mute", ADMFLAG_SLAY)))
						{
							playersOnServer--;
							char buffer[64];
							CvarRerouteToIpAfk.GetString(buffer, sizeof(buffer));
							if(buffer[0])
							{
								ClientCommand(clientkick,"redirect %s",buffer);
								CreateTimer(1.0, RedirectPlayerSpec, EntIndexToEntRef(clientkick), TIMER_FLAG_NO_MAPCHANGE);
							}
							else
							{
								KickClient(clientkick, "You were in spectator and the server was full.");
							}
							break;
						}
					}
				}
			}

			if(playersOnServer > (KickAt))
			{
				//doesnt work.
				if(!(CheckCommandAccess(client, "sm_mute", ADMFLAG_SLAY)))
				{
					char buffer[64];
					CvarRerouteToIp.GetString(buffer, sizeof(buffer));
					if(buffer[0])
					{
						ClientCommand(client,"redirect %s",buffer);
						CreateTimer(1.0, RedirectPlayer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						KickClient(client, "Server is full, please wait. All files should have been downloaded for you already");
					}
				}
			}

		}
	}
	return Plugin_Continue;
}

public Action RedirectPlayer(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		char buffer[64];
		CvarRerouteToIp.GetString(buffer, sizeof(buffer));
		KickClient(client, "This server is full, try: %s",buffer);
	}
	return Plugin_Continue;
}
public Action RedirectPlayerSpec(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		char buffer[64];
		CvarRerouteToIp.GetString(buffer, sizeof(buffer));
		KickClient(client, "You were in spectator and the server was full try: %s",buffer);
	}
	return Plugin_Continue;
}