

int i_HexCustomDamageTypes[MAXENTITIES]; //We use this to avoid using tf2's damage types in cases we dont want to, i.e. too many used, we cant use more. For like white stuff and all, this is just extra on what we already have.

//Use what already exists in tf2 please, only add stuff here if it needs extra spacing like ice damage and so on
//I dont want to use DMG_SHOCK for example due to its extra ugly effect thats annoying!

#define ZR_DAMAGE_NONE							0		  	//Nothing special.
#define ZR_DAMAGE_ICE							(1 << 1)
#define ZR_DAMAGE_LASER_NO_BLAST				(1 << 2)
#define ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED	(1 << 3)
#define ZR_DAMAGE_GIB_REGARDLESS				(1 << 4)
#define ZR_DAMAGE_IGNORE_DEATH_PENALTY			(1 << 5)	//used for removing the dmg reduction fro mdowned.
#define ZR_DAMAGE_REFLECT_LOGIC					(1 << 6)
#define ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS		(1 << 7)
#define ZR_SLAY_DAMAGE							(1 << 8)
#define ZR_STAIR_ANTI_ABUSE_DAMAGE				(1 << 9)
#define ZR_DAMAGE_NPC_REFLECT					(1 << 10)	//this npc reflects damage to another npc that can also reflect damage, use this to filter out the damage.
#define ZR_DAMAGE_CANNOTGIB_REGARDLESS			(1 << 11)
#define ZR_DAMAGE_ALLOW_SELFHURT				(1 << 12)

#define HEAL_NO_RULES				0	 	 
//Nothing special.
#define HEAL_SELFHEAL				(1 << 1) 
//Most healing debuffs shouldnt work with this.
#define HEAL_ABSOLUTE				(1 << 2) 
//Any and all healing changes or buffs or debuffs dont work that dont affect the weapon directly.
#define HEAL_SILENCEABLE			(1 << 3) 
//Silence Entirely nukes this heal
#define HEAL_PASSIVE_NO_NOTIF		(1 << 4) 
//Heals but doesnt notify anyone

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
	Ammo_Metal_Sub,		// 26 Used to display metal on other types of weapons.
	Ammo_ClassSpecific,		// 27 This is used for weapons that require their own ammo.
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
	"ArchDebuff",			// 10
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
	"Mythic Caster",	// 26
	"Psychic Warlord",	//27, Psychokinesis and Magnesis Staff, possibly more in the future
	"Archetype Victoria" //28, Damn this is an Archetype for a Victorian weapon made by beep.
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

bool ForceNiko;
Handle g_hImpulse;

Handle g_hSetLocalOrigin;
Handle g_hSetLocalAngles;
Handle g_hSnapEyeAngles;
Handle g_hSetAbsVelocity;
ArrayList RecentSoundList[MAXTF2PLAYERS];

float f_PlayerLastKeyDetected[MAXTF2PLAYERS];
float f_BotDelayShow[MAXTF2PLAYERS];
float f_OneShotProtectionTimer[MAXTF2PLAYERS];
float f_PreventMedigunCrashMaybe[MAXTF2PLAYERS];
int i_EntityToAlwaysMeleeHit[MAXTF2PLAYERS];
float i_WasInResPowerup[MAXTF2PLAYERS] = {0.0,0.0,0.0};
//int Dont_Crouch[MAXENTITIES]={0, ...};

ConVar Cvar_clamp_back_speed; //tf_clamp_back_speed
ConVar Cvar_LoostFooting; //tf_movement_lost_footing_friction
ConVar sv_cheats;
ConVar nav_edit;
bool DoingLagCompensation;
bool b_LagCompNPC_No_Layers;
bool b_LagCompNPC_ExtendBoundingBox;
bool b_LagCompNPC_OnlyAllies;
#if !defined NOG
ConVar mp_bonusroundtime;
bool b_LagCompNPC_AwayEnemies;
bool b_LagCompNPC_BlockInteral;
bool b_LagCompAlliedPlayers; //Make sure this actually compensates allies.
#endif

ConVar zr_spawnprotectiontime;
#if !defined RTS
float f_BackstabDmgMulti[MAXENTITIES];
float f_BackstabCooldown[MAXENTITIES];
float f_BackstabHealOverThisDuration[MAXENTITIES];
float f_BackstabHealTotal[MAXENTITIES];
float f_BackstabBossDmgPenalty[MAXENTITIES];
float f_BackstabBossDmgPenaltyNpcTime[MAXENTITIES][MAXTF2PLAYERS];
float f_HudCooldownAntiSpam[MAXTF2PLAYERS];
float Damage_dealt_in_total[MAXENTITIES];
int Animation_Setting[MAXTF2PLAYERS];
int Animation_Index[MAXTF2PLAYERS];
int Animation_Retry[MAXTF2PLAYERS];
#endif

bool i_HasBeenBackstabbed[MAXENTITIES];
bool i_HasBeenHeadShotted[MAXENTITIES];

int g_particleImpactFlesh;
int g_particleImpactRubber;


#if !defined RTS
float f_damageAddedTogether[MAXTF2PLAYERS];
float f_damageAddedTogetherGametime[MAXTF2PLAYERS];
int i_HudVictimToDisplay[MAXTF2PLAYERS];
int i_HudVictimToDisplay2[MAXTF2PLAYERS];
#endif

bool b_NetworkedCrouch[MAXTF2PLAYERS];	
//bool b_AntiSlopeCamp[MAXTF2PLAYERS];	
float f_CooldownForHurtParticle[MAXENTITIES];	
float f_ClientConnectTime[MAXENTITIES];	
float f_AntiStuckPhaseThroughFirstCheck[MAXTF2PLAYERS];
float f_AntiStuckPhaseThrough[MAXTF2PLAYERS];
float f_MultiDamageTaken[MAXENTITIES];
float f_MultiDamageTaken_Flat[MAXENTITIES];
float f_MultiDamageDealt[MAXENTITIES];
float f_ExtraOffsetNpcHudAbove[MAXENTITIES];
int i_OwnerEntityEnvLaser[MAXENTITIES];
int TeamNumber[MAXENTITIES];
int i_NextAttackDoubleHit[MAXENTITIES];

bool thirdperson[MAXTF2PLAYERS];
bool b_DoNotUnStuck[MAXENTITIES];
float f_NoUnstuckVariousReasons[MAXENTITIES];
//bool b_PlayerIsInAnotherPart[MAXENTITIES];
bool b_EntityIsStairAbusing[MAXENTITIES];
bool b_EntityCantBeColoured[MAXENTITIES];
float f_EntityIsStairAbusing[MAXENTITIES];
int i_WhatLevelForHudIsThisClientAt[MAXTF2PLAYERS];

//bool Wand_Fired;

float f_Data_InBattleHudDisableDelay[MAXTF2PLAYERS];
float f_InBattleDelay[MAXENTITIES];

int Healing_done_in_total[MAXENTITIES];
int i_PlayerDamaged[MAXENTITIES];
bool b_PlayerWasAirbornKnockbackReduction[MAXTF2PLAYERS];
ConVar CvarRPGInfiniteLevelAndAmmo;
ConVar CvarXpMultiplier;
TFClassType CurrentClass[MAXTF2PLAYERS]={TFClass_Scout, ...};
TFClassType WeaponClass[MAXTF2PLAYERS]={TFClass_Scout, ...};

bool b_GivePlayerHint[MAXTF2PLAYERS];
#if defined ZR
int i_ObjectsBuilding[ZR_MAX_BUILDINGS];
bool b_IgnoreMapMusic[MAXTF2PLAYERS];
bool b_DisableDynamicMusic[MAXTF2PLAYERS];
bool b_EnableRightSideAmmoboxCount[MAXTF2PLAYERS];
bool b_EnableCountedDowns[MAXTF2PLAYERS];
bool b_EnableClutterSetting[MAXTF2PLAYERS];
bool b_EnableNumeralArmor[MAXTF2PLAYERS];
int i_CustomModelOverrideIndex[MAXTF2PLAYERS];
int FogEntity = INVALID_ENT_REFERENCE;
int PlayerPoints[MAXTF2PLAYERS];
float f_InBattleHudDisableDelay[MAXTF2PLAYERS];
int CurrentAmmo[MAXTF2PLAYERS][Ammo_MAX];
float DeleteAndRemoveAllNpcs = 5.0;
bool b_angered_twice[MAXENTITIES];
bool Viewchanges_PlayerModelsAnims[] =
{
	false,
	true,
	true,
	false,
	true,
};

ConVar cvarTimeScale;
float f_BombEntityWeaponDamageApplied[MAXENTITIES][MAXTF2PLAYERS];
//Above is the actual damage to be dealing
int i_HowManyBombsOnThisEntity[MAXENTITIES][MAXTF2PLAYERS];

int i_HowManyBombsHud[MAXENTITIES];
int i_PlayerToCustomBuilding[MAXENTITIES] = {0, ...};
float f_BuildingIsNotReady[MAXTF2PLAYERS] = {0.0, ...};
float f_AmmoConsumeExtra[MAXTF2PLAYERS];
#endif

#if defined ZR || defined RTS
ConVar CvarInfiniteCash;
#endif

#if defined ZR || defined RTS || defined RPG
Handle SyncHud_ArmorCounter;
#endif

bool i_WeaponCannotHeadshot[MAXENTITIES];
float i_WeaponDamageFalloff[MAXENTITIES];
#if defined ZR
float f_Weapon_BackwardsWalkPenalty[MAXENTITIES]={0.7, ...};
float f_Client_BackwardsWalkPenalty[MAXTF2PLAYERS]={0.7, ...};
#else
float f_Weapon_BackwardsWalkPenalty[MAXENTITIES]={0.9, ...};
float f_Client_BackwardsWalkPenalty[MAXTF2PLAYERS]={0.9, ...};
#endif

float f_Client_LostFriction[MAXTF2PLAYERS]={0.1, ...};
int i_SemiAutoWeapon[MAXENTITIES];
int i_SemiAutoWeapon_AmmoCount[MAXENTITIES];
float f_DelayAttackspeedPreivous[MAXENTITIES]={1.0, ...};
int i_PlayerModelOverrideIndexWearable[MAXTF2PLAYERS] = {-1, ...};
bool b_HideCosmeticsPlayer[MAXTF2PLAYERS];
float f_HealDelayParticle[MAXENTITIES]={1.0, ...};

bool b_IsAloneOnServer = false;
bool b_TauntSpeedIncrease[MAXTF2PLAYERS] = {true, ...};
Handle SyncHud_Notifaction;
Handle SyncHud_WandMana;
int i_CustomWeaponEquipLogic[MAXENTITIES]={0, ...};


//only used in zr, however, can also be used for other gamemodes incase theres a limit.
bool b_EnemyNpcWasIndexed[MAXENTITIES][2];
int EnemyNpcAlive = 0;
int EnemyNpcAliveStatic = 0;

const int i_MaxcountBuilding = ZR_MAX_BUILDINGS;

float f_ClientReviveDelay[MAXENTITIES];
float f_ClientReviveDelayMax[MAXENTITIES];
float f_ClientReviveDelayReviveTime[MAXENTITIES];
float f_ClientBeingReviveDelay[MAXENTITIES];

#define MAXSTICKYCOUNTTONPC 42
const int i_MaxcountSticky = MAXSTICKYCOUNTTONPC;
int i_StickyToNpcCount[MAXENTITIES][MAXSTICKYCOUNTTONPC]; //12 should be the max amount of stickies.

float Resistance_for_building_Low[MAXENTITIES];

bool b_DisplayDamageHud[MAXTF2PLAYERS][2];
float f_DisplayDamageHudCooldown[MAXTF2PLAYERS];
bool b_HudHitMarker[MAXTF2PLAYERS] = {true, ...};
float fl_ruina_battery[MAXENTITIES];
float fl_ruina_battery_max[MAXENTITIES];

bool b_HudScreenShake[MAXTF2PLAYERS] = {true, ...};
bool b_HudLowHealthShake_UNSUED[MAXTF2PLAYERS] = {true, ...};
float f_ZombieVolumeSetting[MAXTF2PLAYERS];
int i_CurrentIdBeforeAnnoation[MAXTF2PLAYERS];
float f_TutorialUpdateStep[MAXTF2PLAYERS];

//Just speeds up their time ig?
float f_AttackSpeedNpcIncrease[MAXENTITIES] = {1.0, ...};
float f_AllowInstabuildRegardless = 0.0;
int ClientAttribResetCount[MAXTF2PLAYERS];


//This is for going through things via lag comp or other reasons to teleport things away.
//bool Do_Not_Regen_Mana[MAXTF2PLAYERS];;
bool i_ClientHasCustomGearEquipped[MAXTF2PLAYERS]={false, ...};

float delay_hud[MAXTF2PLAYERS];
float f_DelayBuildNotif[MAXTF2PLAYERS];
float f_ClientInvul[MAXENTITIES]; //Extra ontop of uber if they somehow lose it to some god damn reason.

bool b_NpcHasDied[MAXENTITIES]={true, ...};
bool b_BuildingHasDied[MAXENTITIES]={true, ...};
const int i_MaxcountNpc = ZR_MAX_NPCS;

bool b_DoNotIgnoreDuringLagCompAlly[MAXENTITIES]={false, ...};

bool b_NpcIsTeamkiller[MAXENTITIES]={false, ...};
bool b_AllowSelfTarget[MAXENTITIES]={false, ...};
bool b_AllowCollideWithSelfTeam[MAXENTITIES]={false, ...};

const int i_MaxcountNpcTotal = ZR_MAX_NPCS;
int i_ObjectsNpcsTotal[ZR_MAX_NPCS];
bool i_IsABuilding[MAXENTITIES];

bool i_NpcIsABuilding[MAXENTITIES];
bool b_NpcIgnoresbuildings[MAXENTITIES];


bool b_IsAGib[MAXENTITIES];
int i_NpcInternalId[MAXENTITIES];
bool b_IsCamoNPC[MAXENTITIES];
bool b_NoKillFeed[MAXENTITIES];

float f_TimeUntillNormalHeal[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZone[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZoneDamage[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZoneStairs[MAXENTITIES]={0.0, ...};
float f_ClientWasTooLongInsideHurtZoneDamageStairs[MAXENTITIES]={0.0, ...};

bool b_HideHealth[MAXENTITIES];
bool b_IsABow[MAXENTITIES];
bool b_WeaponHasNoClip[MAXENTITIES];
bool b_IsAMedigun[MAXENTITIES];
int PrevOwnerMedigun[MAXENTITIES];
float flNpcCreationTime[MAXENTITIES];
int i_IsNpcType[MAXENTITIES];
int i_npcspawnprotection[MAXENTITIES];
float f_DomeInsideTest[MAXENTITIES];
bool b_Frozen[MAXENTITIES];
bool b_NoGravity[MAXENTITIES];
float f_TankGrabbedStandStill[MAXENTITIES];
float f_TimeFrozenStill[MAXENTITIES];
float f_StunExtraGametimeDuration[MAXENTITIES];
float f_BannerDurationActive[MAXENTITIES];
//0 means bad, 1 means good
float f_BubbleProcStatus[MAXENTITIES][2];
float f_DuelStatus[MAXENTITIES];
int BleedAmountCountStack[MAXENTITIES];
bool b_HasBombImplanted[MAXENTITIES];
int i_RaidGrantExtra[MAXENTITIES];
int g_particleCritText;
int g_particleMiniCritText;
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
int i_ChaosArrowAmount[MAXENTITIES];
int i_VoidArrowAmount[MAXENTITIES];
float f_KnockbackPullDuration[MAXENTITIES];
float f_DoNotUnstuckDuration[MAXENTITIES];
float f_UnstuckTimerCheck[MAXENTITIES][2];
int i_PullTowardsTarget[MAXENTITIES];
float f_PullStrength[MAXENTITIES];

float ReplicateClient_Svairaccelerate[MAXTF2PLAYERS];
float ReplicateClient_BackwardsWalk[MAXTF2PLAYERS];
float ReplicateClient_LostFooting[MAXTF2PLAYERS];
int ReplicateClient_Tfsolidobjects[MAXTF2PLAYERS];
int ReplicateClient_RollAngle[MAXTF2PLAYERS];

bool b_StickyIsSticking[MAXENTITIES];

RenderMode i_EntityRenderMode[MAXENTITIES]={RENDER_NORMAL, ...};
int i_EntityRenderColour1[MAXENTITIES]={255, ...};
int i_EntityRenderColour2[MAXENTITIES]={255, ...};
int i_EntityRenderColour3[MAXENTITIES]={255, ...};
int i_EntityRenderColour4[MAXENTITIES]={255, ...};
bool i_EntityRenderOverride[MAXENTITIES]={false, ...};

//6 wearables
int i_Wearable[MAXENTITIES][9];
int i_FreezeWearable[MAXENTITIES];
int i_InvincibleParticle[MAXENTITIES];
int i_InvincibleParticlePrev[MAXENTITIES];
float f_WidowsWineDebuffPlayerCooldown[MAXENTITIES];

int i_Hex_WeaponUsesTheseAbilities[MAXENTITIES];
char c_WeaponUseAbilitiesHud[MAXENTITIES][16];
float PrepareMusicVolume[MAXTF2PLAYERS];


//Used for any double arrays like lantean wand or health hose.
#if defined ZR
float f_BannerAproxDur[MAXENTITIES];
//bool b_AlreadyHitTankThrow[MAXENTITIES][MAXENTITIES];
#endif

// This is used for stuff like: Youre on fire, or mark for death icon above your head
//this is needed as when you change classes via our system tf2 just deletes it, screw tf2.
float f_UpdateModelIssues[MAXTF2PLAYERS];
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
float f_ArmorHudOffsetX[MAXTF2PLAYERS];
float f_ArmorHudOffsetY[MAXTF2PLAYERS];

float f_HurtHudOffsetX[MAXTF2PLAYERS];
float f_HurtHudOffsetY[MAXTF2PLAYERS];

float f_WeaponHudOffsetX[MAXTF2PLAYERS];
float f_WeaponHudOffsetY[MAXTF2PLAYERS];

float f_NotifHudOffsetX[MAXTF2PLAYERS];
float f_NotifHudOffsetY[MAXTF2PLAYERS];


#if defined RPG
int Level[MAXENTITIES];
int XP[MAXENTITIES];
int i_CreditsOnKill[MAXENTITIES];
int i_HpRegenInBattle[MAXENTITIES];
bool b_JunalSpecialGear100k[MAXENTITIES];
#endif

#if defined ZR || defined RPG
int i_Damage_dealt_in_total[MAXTF2PLAYERS];
bool IsInsideManageRegularWeapons;
bool b_ProximityAmmo[MAXTF2PLAYERS];
int i_HeadshotAffinity[MAXTF2PLAYERS]={0, ...}; 
int i_nm_body_client[MAXTF2PLAYERS];
int i_CurrentEquippedPerk[MAXENTITIES];
float f_DelayAttackspeedAnimation[MAXTF2PLAYERS +1];
float f_DelayAttackspeedPanicAttack[MAXENTITIES];

#if defined ZR 
int i_SpecialGrigoriReplace;
float f_TimeSinceLastGiveWeapon[MAXENTITIES]={1.0, ...};
int i_WeaponAmmoAdjustable[MAXENTITIES];
int Resupplies_Supplied[MAXENTITIES];
bool b_LeftForDead[MAXTF2PLAYERS];
int i_BarricadeHasBeenDamaged[MAXENTITIES];
int i_CurrentEquippedPerkPreviously[MAXENTITIES];
float Mana_Regen_Delay[MAXTF2PLAYERS];
float Mana_Regen_Delay_Aggreviated[MAXTF2PLAYERS];
float Mana_Regen_Block_Timer[MAXTF2PLAYERS];
float Mana_Loss_Delay[MAXTF2PLAYERS];
//float RollAngle_Regen_Delay[MAXTF2PLAYERS];
bool b_FaceStabber[MAXENTITIES];
int Armor_Level[MAXTF2PLAYERS]={0, ...}; 				//701
int Grigori_Blessing[MAXTF2PLAYERS]={0, ...}; 				//777
bool b_HasGlassBuilder[MAXTF2PLAYERS];
bool b_HasMechanic[MAXTF2PLAYERS];
int i_MaxSupportBuildingsLimit[MAXTF2PLAYERS];
bool b_AggreviatedSilence[MAXTF2PLAYERS];
bool b_ArmorVisualiser[MAXENTITIES];
//bool b_BobsCuringHand[MAXTF2PLAYERS];
//bool b_XenoVial[MAXTF2PLAYERS];
int b_BobsCuringHand_Revived[MAXTF2PLAYERS];
bool b_StickyExtraGrenades[MAXTF2PLAYERS];
bool FinalBuilder[MAXENTITIES];
bool GlassBuilder[MAXENTITIES];
bool WildingenBuilder[MAXENTITIES];
bool WildingenBuilder2[MAXENTITIES];
bool HasMechanic[MAXENTITIES];
bool b_ExpertTrapper[MAXENTITIES];
bool b_RaptureZombie[MAXENTITIES];
float f_ClientArmorRegen[MAXENTITIES];
//bool b_NemesisHeart[MAXTF2PLAYERS];
//bool b_OverlordsFinalWish[MAXTF2PLAYERS];
//bool b_BobsTrueFear[MAXTF2PLAYERS];
//bool b_TwirlHairpins[MAXTF2PLAYERS];
//bool b_KahmlLastWish[MAXTF2PLAYERS];
//bool b_VoidPortalOpened[MAXTF2PLAYERS];
//bool b_AvangardCoreB[MAXTF2PLAYERS];
float f_ArmorCurrosionImmunity[MAXENTITIES][Element_MAX];
float f_CooldownForHurtHud_Ally[MAXTF2PLAYERS];	
float mana_regen[MAXTF2PLAYERS];
bool has_mage_weapon[MAXTF2PLAYERS];
int i_SoftShoes[MAXTF2PLAYERS]={0, ...}; 				//527
bool b_IsCannibal[MAXTF2PLAYERS];
bool b_Reinforce[MAXTF2PLAYERS];
char g_GibEating[][] = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
};
#endif
#endif
bool b_AvoidBuildingsAtAllCosts[MAXENTITIES];	
float f_MaxAnimationSpeed[MAXENTITIES];	
Handle g_hRecalculatePlayerBodygroups;
float f_WandDamage[MAXENTITIES]; //
int i_WandWeapon[MAXENTITIES]; //
int i_WandParticle[MAXENTITIES]; //Only one allowed, dont use more. ever. ever ever. lag max otherwise.
//float Check_Standstill_Delay[MAXTF2PLAYERS];
//bool Check_Standstill_Applied[MAXTF2PLAYERS];

float max_mana[MAXTF2PLAYERS];



int Current_Mana[MAXTF2PLAYERS];
float Mana_Hud_Delay[MAXTF2PLAYERS];
int i_WandIdNumber[MAXENTITIES]; //This is to see what wand is even used. so it does its own logic and so on.


//int played_headshotsound_already_Case [MAXTF2PLAYERS];
//int played_headshotsound_already_Pitch [MAXTF2PLAYERS];
int g_particleMissText;
float f_SemiAutoStats_FireRate[MAXENTITIES];
int i_SemiAutoStats_MaxAmmo[MAXENTITIES];
float f_SemiAutoStats_ReloadTime[MAXENTITIES];
float Mana_Regen_Level[MAXTF2PLAYERS]={0.0, ...};				//405
int i_SurvivalKnifeCount[MAXENTITIES]={0, ...}; 				//33
int i_GlitchedGun[MAXENTITIES]={0, ...}; 				//731
int i_AresenalTrap[MAXENTITIES]={0, ...}; 				//719
int i_ArsenalBombImplanter[MAXENTITIES]={0, ...}; 				//544
int i_LowTeslarStaff[MAXENTITIES]={0, ...}; 				//3002
int i_HighTeslarStaff[MAXENTITIES]={0, ...}; 				//3000
int i_NoBonusRange[MAXENTITIES]={0, ...}; 				//410
int i_BuffBannerPassively[MAXENTITIES]={0, ...}; 				//786
bool b_BackstabLaugh[MAXENTITIES];
//float played_headshotsound_already [MAXTF2PLAYERS];
int i_IsAloneWeapon[MAXENTITIES];
bool i_InternalMeleeTrace[MAXENTITIES]; 
int i_StickyAccessoryLogicItem[MAXTF2PLAYERS]; //Item for stickies like "no bounce"
//char c_WeaponSoundOverrideString[MAXENTITIES][255];
int WeaponRef_viewmodel[MAXTF2PLAYERS] = {-1, ...};
int HandRef[MAXTF2PLAYERS] = {-1, ...};
int i_Viewmodel_PlayerModel[MAXENTITIES] = {-1, ...};
int i_Worldmodel_WeaponModel[MAXTF2PLAYERS] = {-1, ...};
int i_OverrideWeaponSlot[MAXENTITIES]={-1, ...};
int i_MeleeAttackFrameDelay[MAXENTITIES]={12, ...};
bool b_MeleeCanHeadshot[MAXENTITIES]={false, ...};
int i_MeleeHitboxHit[MAXENTITIES]={false, ...};
float Panic_Attack[MAXENTITIES]={0.0, ...};				//651
int i_WandOwner[MAXENTITIES]; //				//785



bool b_NpcIsInvulnerable[MAXENTITIES];
bool b_NpcUnableToDie[MAXENTITIES];

Function EntityFuncAttack[MAXENTITIES];
Function EntityFuncAttackInstant[MAXENTITIES];
Function EntityFuncAttack2[MAXENTITIES];
Function EntityFuncAttack3[MAXENTITIES];
Function EntityFuncReload4[MAXENTITIES];
//Function EntityFuncReloadSingular5[MAXENTITIES];

float f_ClientMusicVolume[MAXTF2PLAYERS];
bool b_FirstPersonUsesWorldModel[MAXTF2PLAYERS];
float f_BegPlayerToSetRagdollFade[MAXTF2PLAYERS];
float f_BegPlayerR_TeethSet[MAXTF2PLAYERS];

//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
//ATTRIBUTE ARRAY SUBTITIUTE
bool b_ForceCollisionWithProjectile[MAXENTITIES];
bool b_ProjectileCollideIgnoreWorld[MAXENTITIES];
bool b_IsAProjectile[MAXENTITIES];
bool b_Is_Player_Projectile_Through_Npc[MAXENTITIES];
bool b_CannotBeHeadshot[MAXENTITIES];
bool b_CannotBeBackstabbed[MAXENTITIES];
float f_NpcTurnPenalty[MAXENTITIES];
float f_ClientInAirSince[MAXENTITIES];
bool b_IsInUpdateGroundConstraintLogic;
bool b_IgnorePlayerCollisionNPC[MAXENTITIES];
bool b_ProjectileCollideWithPlayerOnly[MAXENTITIES];
bool b_IgnoreAllCollisionNPC[MAXENTITIES];		//for npc's that noclip

int i_ExplosiveProjectileHexArray[MAXENTITIES];
int h_NpcCollissionHookType[MAXENTITIES];
int h_NpcSolidHookType[MAXENTITIES];
int h_NpcHandleEventHook[MAXENTITIES];
bool b_KillHookHandleEvent[MAXENTITIES];
#define EP_GENERIC				  		0		  					// Nothing special.
#define EP_NO_KNOCKBACK			  		(1 << 0)   					// No knockback
#define EP_DEALS_UNUSED_1			  	(1 << 1)   				// Slash Damage (For no npc scaling, or ignoring resistances.)
#define EP_DEALS_CLUB_DAMAGE			  	(1 << 2)   				// To deal melee damage.
#define EP_GIBS_REGARDLESS			  	(1 << 3)   					// Even if its anything then blast, it will still gib.
#define EP_DEALS_PLASMA_DAMAGE			 	(1 << 4)   				// for wands to deal plasma dmg
#define EP_DEALS_TRUE_DAMAGE			 	(1 << 5)
#define EP_IS_ICE_DAMAGE			  		(1 << 6)   				// Even if its anything then blast, it will still gib.

float f_TempCooldownForVisualManaPotions[MAXTF2PLAYERS+1];
float f_DelayLookingAtHud[MAXTF2PLAYERS+1];
bool b_EntityIsArrow[MAXENTITIES];
bool b_EntityIsWandProjectile[MAXENTITIES];
bool b_EntityIgnoredByShield[MAXENTITIES];
int i_IsWandWeapon[MAXENTITIES]; 
bool i_IsWrench[MAXENTITIES]; 
bool i_IsSupportWeapon[MAXENTITIES]; 
bool i_IsKitWeapon[MAXENTITIES]; 
bool b_is_a_brush[MAXENTITIES]; 
int i_IsVehicle[MAXENTITIES]; 
bool b_IsARespawnroomVisualiser[MAXENTITIES];
float f_ImmuneToFalldamage[MAXENTITIES]; 
int i_WeaponSoundIndexOverride[MAXENTITIES];
int i_WeaponModelIndexOverride[MAXENTITIES];
int i_WeaponVMTExtraSetting[MAXENTITIES];
int i_WeaponBodygroup[MAXENTITIES];
int i_WeaponFakeIndex[MAXENTITIES];
float f_WeaponSizeOverride[MAXENTITIES];
float f_WeaponSizeOverrideViewmodel[MAXENTITIES];
float f_WeaponVolumeStiller[MAXENTITIES];
float f_WeaponVolumeSetRange[MAXENTITIES];
float f_FreeplayAlteredDamageOld_Barracks[MAXENTITIES];
float f_FreeplayAlteredHealthOld_Barracks[MAXENTITIES];
float f_NpcAdjustFriction[MAXENTITIES];


int g_iLaserMaterial_Trace, g_iHaloMaterial_Trace;


#define EXPLOSION_AOE_DAMAGE_FALLOFF 0.64
#define LASER_AOE_DAMAGE_FALLOFF 0.6
#define EXPLOSION_RADIUS 150.0
#define EXPLOSION_RANGE_FALLOFF 0.5

#if !defined NOG
//#define DO_NOT_COMPENSATE_THESE 211, 442, 588, 30665, 264, 939, 880, 1123, 208, 1178, 594, 954, 1127, 327, 1153, 425, 1081, 740, 130, 595, 207, 351, 1083, 58, 528, 1151, 996, 1092, 752, 308, 1007, 1004, 1005, 206, 305

bool b_Do_Not_Compensate[MAXENTITIES];
bool b_Only_Compensate_CollisionBox[MAXENTITIES];
bool b_Only_Compensate_AwayPlayers[MAXENTITIES];
bool b_ExtendBoundingBox[MAXENTITIES];
bool b_BlockLagCompInternal[MAXENTITIES];
bool b_Dont_Move_Building[MAXENTITIES];
bool b_Dont_Move_Allied_Npc[MAXENTITIES];
#endif

#if defined ZR || defined RPG
bool g_GottenAddressesForLagComp;
Address g_hSDKStartLagCompAddress;
Address g_hSDKEndLagCompAddress;
//bool b_PhasesThroughBuildingsCurrently[MAXTF2PLAYERS];
float f_MedicCallIngore[MAXTF2PLAYERS];
#endif

int b_BoundingBoxVariant[MAXENTITIES];
bool b_ThisEntityIgnored_NoTeam[MAXENTITIES];
bool b_ThisEntityIgnored[MAXENTITIES];
bool b_ThisEntityIgnoredByOtherNpcsAggro[MAXENTITIES];
bool b_ThisEntityIgnoredEntirelyFromAllCollisions[MAXENTITIES]={false, ...};
bool b_ThisEntityIgnoredBeingCarried[MAXENTITIES];
bool b_ThisEntityIsAProjectileForUpdateContraints[MAXENTITIES];
bool b_IgnoredByPlayerProjectiles[MAXENTITIES];

bool b_IsPlayerABot[MAXTF2PLAYERS+1];
float f_CooldownForHurtHud[MAXTF2PLAYERS];
int i_PreviousInteractedEntity[MAXENTITIES];
//Otherwise we get kicks if there is too much hurting going on.

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
Handle g_hSDKWorldSpaceCenter;
Handle g_hStudio_FindAttachment;
Handle g_hResetSequenceInfo;
#if defined ZR || defined RPG
DynamicHook g_DHookMedigunPrimary; 
float f_ModifThirdPersonAttackspeed[MAXENTITIES]={1.0, ...};
#endif
//Death

//PluginBot SDKCalls
Handle g_hGetSolidMask;
//DHooks
//Handle g_hGetCurrencyValue;
DynamicHook g_DHookRocketExplode; //from mikusch but edited


int CurrentGibCount = 0;
float f_GibHealingAmount[MAXENTITIES];
//GLOBAL npc things

float f_MinicritSoundDelay[MAXTF2PLAYERS];

float f_CustomGrenadeDamage[MAXENTITIES];

float f_TraceAttackWasTriggeredSameFrame[MAXENTITIES];

float TickrateModify;
int TickrateModifyInt;
float f_ClientDoDamageHud[MAXTF2PLAYERS][2];
float f_ClientDoDamageHud_Hurt[MAXTF2PLAYERS][2];
float f3_NpcSavePos[MAXENTITIES][3];  
float f_DelayComputingOfPath[MAXENTITIES];

enum
{
	STEPTYPE_NONE = 0,
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
	BLEEDTYPE_SEABORN = 6,
	BLEEDTYPE_VOID = 7
}



int i_TankAntiStuck[MAXENTITIES];
int i_PlayMusicSound[MAXENTITIES];
float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
float fl_ThrowPlayerCooldown[MAXENTITIES];
float fl_ThrowPlayerImmenent[MAXENTITIES];
bool b_ThrowPlayerImmenent[MAXENTITIES];
int i_GrabbedThis[MAXENTITIES];
float fl_ThrowDelay[MAXENTITIES];
int i_TankThrewThis[MAXENTITIES];
bool i_ThrowAlly[MAXENTITIES];
int i_IWantToThrowHim[MAXENTITIES];
float f3_LastValidPosition[MAXENTITIES][3]; //Before grab to be exact
int i_PlayIdleAlertSound[MAXENTITIES];
int i_ammo_count[MAXENTITIES];
bool b_we_are_reloading[MAXENTITIES];
float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];
int i_wingslot[MAXENTITIES];
int i_haloslot[MAXENTITIES];
int i_ClosestAlly[MAXENTITIES];
float i_ClosestAllyCD[MAXENTITIES];
int i_ClosestAllyTarget[MAXENTITIES];
float i_ClosestAllyCDTarget[MAXENTITIES];

float fl_BEAM_RechargeTime[MAXENTITIES];	//how long until laser is reusable
float fl_BEAM_ChargeUpTime[MAXENTITIES];	//how long until the laser BEGINS
float fl_BEAM_DurationTime[MAXENTITIES];	//how long until the laser ends
float fl_BEAM_ThrottleTime[MAXENTITIES];	//if you want to make a laser only do something 10 times a second instead of 66 during a think hook

float fl_AbilityVectorData[MAXENTITIES][3];	//if you wish to transfer vector data between stuff. or save it for something else
int i_Ruina_Laser_BEAM_HitDetected[100];	//if your laser has to hit more then 100 targets, your doing something wrong.
int i_AmountProjectiles[MAXENTITIES];

int i_NemesisEntitiesHitAoeSwing[MAXENTITIES];	//Who got hit
float f_NemesisEnemyHitCooldown[MAXENTITIES];

float f_NemesisCauseInfectionBox[MAXENTITIES];
float f_NemesisHitBoxStart[MAXENTITIES];
float f_NemesisHitBoxEnd[MAXENTITIES];
float fl_RegainWalkAnim[MAXENTITIES];
float fl_OverrideWalkDest[MAXENTITIES];
float fl_StopDodge[MAXENTITIES];
float fl_StopDodgeCD[MAXENTITIES];

int i_GunMode[MAXENTITIES];
int i_GunAmmo[MAXENTITIES];
float f_NemesisImmuneToInfection[MAXENTITIES];
float f_NemesisSpecialDeathAnimation[MAXENTITIES];
float f_NemesisRandomInfectionCycle[MAXENTITIES];
bool b_InKame[MAXENTITIES];
bool b_said_player_weaponline[MAXTF2PLAYERS]; //Yes, i know, itll break if multiple raids spawn, but it doesnt really matter....
float fl_said_player_weaponline_time[MAXENTITIES];
int i_current_wave[MAXENTITIES];
bool FactorySpawn[MAXENTITIES];
bool MK2[MAXENTITIES];
bool Limit[MAXENTITIES];
bool Anvil[MAXENTITIES];
int i_ally_index[MAXENTITIES];

//some lasers had some variation of this, i just condeced it down to 1
int LaserVarious_HitDetection[MAXENTITIES];
int i_SaidLineAlready[MAXENTITIES];