#pragma semicolon 1
#pragma newdecls required

#include <tf2_stocks>
#include <sdkhooks>
#include <clientprefs>
#include <dhooks>
#if defined ZR || defined RPG
#undef AUTOLOAD_EXTENSIONS
#tryinclude <tf2items>
#define AUTOLOAD_EXTENSIONS
#include <tf_econ_data>
#endif
#if !defined RTS
#include <tf2attributes>
#endif
//#include <lambda>
#include <morecolors>
#include <cbasenpc>
#include <tf2utils>
#include <profiler>
#include <collisionhook>
#include <sourcescramble>
//#include <handledebugger>
#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#include <loadsoundscript>

#pragma dynamic	131072

#define CHAR_FULL	"█"
#define CHAR_PARTFULL	"▓"
#define CHAR_PARTEMPTY	"▒"
#define CHAR_EMPTY	"░"

//#define TFTeam			PleaseUse_int
#define TFTeam_Unassigned 	0
#define TFTeam_Spectator 	1
#define TFTeam_Red 		2
#define TFTeam_Blue		3

#define TFTeam_Stalkers 		5

#define TF2_GetClientTeam	PleaseUse_GetTeam
#define TF2_ChangeClientTeam	PleaseUse_SetTeam

#define RoundState_ZombieRiot view_as<RoundState>(11)

#if defined ZR
#define NPC_HARD_LIMIT		40
#define ZR_MAX_NPCS		196
#define ZR_MAX_LAG_COMP		128 
#define ZR_MAX_BUILDINGS	128 //cant ever have more then 64 realisticly speaking
#define ZR_MAX_TRAPS		64
#define ZR_MAX_SPAWNERS		256
#else

#define ZR_MAX_NPCS		256
#define ZR_MAX_LAG_COMP		256 
#define ZR_MAX_BUILDINGS	256

#endif

#define ZR_MAX_GIBCOUNT		12 //Anymore then this, and it will only summon 1 gib per zombie instead.
#define ZR_MAX_GIBCOUNT_ABSOLUTE 35 //Anymore then this, and the duration is halved for gibs staying.
#define RAIDBOSS_GLOBAL_ATTACKLIMIT 16

//#pragma dynamic	131072
//Allah This plugin has so much we need to do this.

// THESE ARE TO TOGGLE THINGS!
enum OSType
{
	OS_Linux = 0,
	OS_Windows,
	OS_Unknown
}

OSType OperationSystem;

enum
{
	EDICT_NPC = 0,
	EDICT_PLAYER,
	EDICT_RAID,
	EDICT_EFFECT
}
//maybe doing this will help lag, as there are no aim layers in zombies, they always look forwards no matter what.

//edit: No, makes you miss more often.

bool EnableSilentMode = false;
//Comment this out, and reload the plugin once ingame if you wish to have infinite cash.

public const float OFF_THE_MAP[3] = { 16383.0, 16383.0, -16383.0 };
public float OFF_THE_MAP_NONCONST[3] = { 16383.0, 16383.0, -16383.0 };

#if defined ZR
ConVar zr_downloadconfig;
ConVar CvarSkillPoints;
ConVar CvarRogueSpecialLogic;
ConVar CvarLeveling;
ConVar CvarAutoSelectWave;
ConVar CvarAutoSelectDiff;
ConVar CvarVoteLimit;
#endif
ConVar CvarCustomModels;
ConVar CvarFileNetworkDisable;

enum
{
	FILENETWORK_ENABLED = 0,
	FILENETWORK_ICONONLY = 1,
	FILENETWORK_DISABLED = 2,

}

ConVar CvarDisableThink;
//ConVar CvarMaxBotsForKillfeed;
ConVar CvarRerouteToIp;
ConVar CvarRerouteToIpAfk;
ConVar CvarKickPlayersAt;
ConVar CvarMaxPlayerAlive;
ConVar zr_interactforcereload;
bool BlockOtherRaidMusic = false;
//ConVar CvarDebugOffset;

int CurrentEntities;
bool Toggle_sv_cheats = false;
bool b_MarkForReload = false; //When you wanna reload the plugin on map change...

#define FAR_FUTURE	100000000.0
//double for 100 player support????

#define	HIDEHUD_WEAPONSELECTION		( 1<<0 )	// Hide ammo count & weapon selection
#define	HIDEHUD_FLASHLIGHT			( 1<<1 )
#define	HIDEHUD_ALL					( 1<<2 )
#define HIDEHUD_HEALTH				( 1<<3 )	// Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			( 1<<4 )	// Hide when local player's dead
#define HIDEHUD_NEEDSUIT			( 1<<5 )	// Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS			( 1<<6 )	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				( 1<<7 )	// Hide all communication elements (saytext, voice icon, etc)
#define	HIDEHUD_CROSSHAIR			( 1<<8 )	// Hide crosshairs
#define	HIDEHUD_VEHICLE_CROSSHAIR	( 1<<9 )	// Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			( 1<<10 )
#define HIDEHUD_BONUS_PROGRESS		( 1<<11 )	// Hide bonus progress display (for bonus map challenges)
#define HIDEHUD_BUILDING_STATUS		( 1<<12 )  
#define HIDEHUD_CLOAK_AND_FEIGN		( 1<<13 )   
#define HIDEHUD_PIPES_AND_CHARGE		( 1<<14 )	
#define HIDEHUD_METAL		( 1<<15 )	
#define HIDEHUD_TARGET_ID		( 1<<16 )	

#define MULTIDMG_NONE 		 ( 1<<0 )
#define MULTIDMG_MAGIC_WAND  ( 1<<1 )
#define MULTIDMG_BLEED 		 ( 1<<2 )
#define MULTIDMG_BUILDER 	 ( 1<<3 )

#define CONFIG_CFG	CONFIG ... "/%s.cfg"

#define DISPENSER_BLUEPRINT	"models/buildables/dispenser_blueprint.mdl"
#define SENTRY_BLUEPRINT	"models/buildables/sentry1_blueprint.mdl"

#define BANNER_DURATION_FIX_FLOAT 1.0

#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
//Needs to be global.


#define ABILITY_NONE				 0		  	//Nothing special.

#define ABILITY_M1				(1 << 1) 
#define ABILITY_M2				(1 << 2) 
#define ABILITY_R				(1 << 3) 	

#define FL_WIDOWS_WINE_DURATION 4.0
#define FL_WIDOWS_WINE_DURATION_NPC 0.85

#define MELEE_RANGE 64.0
#define MELEE_BOUNDS 22.0



#include "global_arrays.sp"
//This model is used to do custom models for npcs, mainly so we can make cool animations without bloating downloads
#define COMBINE_CUSTOM_MODEL 		"models/zombie_riot/combine_attachment_police_228.mdl"

//model uses self made IK rigs, to not break the top stuff.
#define COMBINE_CUSTOM_2_MODEL 		"models/zombie_riot/combine_attachment_police_secondmodel_22.mdl"

#define WEAPON_CUSTOM_WEAPONRY_1 	"models/zombie_riot/weapons/custom_weaponry_1_52.mdl"
/*
	1 - sensal scythe
	2 - scythe_throw
*/
//#define ZR_TEST_MODEL	"models/zombie_riot/weapons/test_models9.mdl"

#define WINGS_MODELS_1 	"models/zombie_riot/weapons/custom_wings_1_3.mdl"
enum
{
	WINGS_FUSION 	= 1,
	WINGS_LANCELOT	= 2,
	WINGS_RULIANA	= 4,
	WINGS_TWIRL		= 8,
	WINGS_HELIA		= 16,
	WINGS_STELLA	= 32,
	WINGS_KARLAS	= 64
}

#define RUINA_CUSTOM_MODELS_1	"models/zombie_riot/weapons/ruina_models_1_2_2.mdl"
enum	//it appears if I try to make it go above 14 it starts glitching out
{		
	RUINA_ICBM 				= 1,		//1
	RUINA_HALO_1 			= 2,		//2
	RUINA_QUINCY_BOW_1 		= 4,		//3
	RUINA_BLADE_1			= 8,		//4
	RUINA_MAGI_GUN_1		= 16,		//5
	RUINA_STAFF_1			= 32,		//6
	RUINA_HAND_CREST_1		= 64,		//7
	RUINA_LAN_SWORD_1		= 128,		//8
	RUINA_EUR_STAFF_1		= 256,		//9
	RUINA_DAGGER_1			= 512,		//10
	RUINA_RADAR_GUN_1		= 1024,		//11
	RUINA_HEALING_STAFF_1	= 2048,		//12
	RUINA_W30_HAND_CREST	= 4096,		//13
	RUINA_IANA_BLADE		= 8192,		//14
}
#define RUINA_CUSTOM_MODELS_2	"models/zombie_riot/weapons/ruina_models_2_5.mdl"
enum
{
	RUINA_QUINCY_BOW_2		= 1,			//1
	RUINA_HAND_CREST_2		= 2,			//2
	RUINA_LAN_SWORD_2		= 4,			//3
	RUINA_EUR_STAFF_2		= 8,			//4
	RUINA_BLADE_2			= 16,			//5
	RUINA_LAZER_CANNON_1	= 32,			//6
	RUINA_DAGGER_2			= 64,			//7
	RUINA_HEALING_STAFF_2	= 128,			//8
	RUINA_REI_LAUNCHER		= 256,			//9
	RUINA_WINGS_1			= 512,			//10
	RUINA_IMPACT_LANCE_1	= 1024,			//11
	RUINA_IMPACT_LANCE_2	= 2048,			//12
	RUINA_IMPACT_LANCE_3	= 4096,			//13
	RUINA_IMPACT_LANCE_4	= 8192,			//14
	RUINA_HAND_CREST_3		= 16384,		//15
	RUINA_ZANGETSU			= 32768,		//16
	RUINA_ZANGETSU_2		= 65536,		//17
	RUINA_BLADE_3			= 131072,		//18
	RUINA_LAN_SWORD_3		= 262144,		//19
	RUINA_LAZER_CANNON_2	= 524288,		//20
	RUINA_WINGS_2			= 1048576		//21	going beyond this it legit cannot compile anymore, likely due to too many things
}
#define RUINA_CUSTOM_MODELS_3	"models/zombie_riot/weapons/ruina_models_3_2.mdl"
enum
{
	RUINA_WINGS_4			= 1,			//1
	RUINA_WINGS_3			= 2,			//2
	RUINA_MAGIA_TOWER_1		= 4,			//3
	RUINA_MAGIA_TOWER_2		= 8,			//4
	RUINA_MAGIA_TOWER_3		= 16,			//5
	RUINA_MAGIA_TOWER_4		= 32,			//6
	RUINA_TWIRL_MELEE_1		= 64,			//7
	RUINA_TWIRL_CREST_1		= 128,			//8
	RUINA_TWIRL_MELEE_2		= 256,			//9
	RUINA_TWIRL_CREST_2		= 512,			//10
	RUINA_TWIRL_CREST_3		= 1024,			//11
	RUINA_TWIRL_MELEE_3		= 2048,			//12
	RUINA_TWIRL_MELEE_4		= 4096,			//13
	RUINA_TWIRL_CREST_4		= 8192,			//14
	RUINA_QUINCY_BOW_3		= 16384			//15
}
#define RUINA_CUSTOM_MODELS_4	"models/zombie_riot/weapons/ruina_models_4_3.mdl"
enum
{
	RUINA_STELLA_CREST			= 1,			//1
	RUINA_STELLA_CREST_CHARGING	= 2,			//2
	RUINA_KARLAS_PROJECTILE		= 4,			//4 ITS A SPACE SHIP, BUT ACTUALLY NOT!
	RUINA_FANTASY_BLADE			= 8,			//8 its a sword, that looks like a spaceship..
	RUINA_FRACTAL_LENZ			= 16,			//16 the primary medic weapon animation is ASSSSSSSS for making a magic-spell weapon specifically for what I wanted. so the model effort is "eh". but I had no choice :(
	RUINA_FRACTAL_HARVESTER		= 32
}
enum
{
	NPC_SPAWNPROT_OFF = -1,
	NPC_SPAWNPROT_INIT = 0,
	NPC_SPAWNPROT_ON = 1,
	NPC_SPAWNPROT_UNSTUCK = 3
}

#if defined ZR
	#define DEFAULT_UPDATE_DELAY_FLOAT 0.0 //0.0151 //Make it 0 for now
#else
	#define DEFAULT_UPDATE_DELAY_FLOAT 0.0151 //rpg needs a bigger delay.
#endif

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

char g_GibSoundMetal[][] = {
	"physics/metal/metal_box_break1.wav",
	"physics/metal/metal_box_break2.wav",
};
/*
char g_GibSoundMetal[][] = {
	"ui/item_metal_pot_drop.wav",
	"ui/item_metal_scrap_drop.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_weapon_drop.wav",
};
*/
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

#if defined BONEZONE_BASE

#define BONEZONE_MODEL		"models/zombie_riot/the_bone_zone/basic_bones.mdl"
#define BONEZONE_MODEL_BOSS	"models/zombie_riot/the_bone_zone/boss_bones.mdl"
#define MODEL_SSB   		"models/zombie_riot/the_bone_zone/supreme_spookmaster_bones.mdl"
#define PARTICLE_SSB_SPAWN	"doomsday_tentpole_vanish01"
#define SND_TRANSFORM		")vo/halloween_boss/knight_alert.mp3"
#define PARTICLE_TRANSFORM	"ghost_appearation"
#define SND_GIB_SKELETON	")misc/halloween/skeleton_break.wav"

char g_BoneZoneBuffDefaultSFX[][] = {
	"vo/halloween_boo1.mp3",
	"vo/halloween_boo2.mp3",
	"vo/halloween_boo3.mp3",
	"vo/halloween_boo4.mp3",
	"vo/halloween_boo5.mp3",
	"vo/halloween_boo6.mp3",
	"vo/halloween_boo7.mp3"
};

char g_HHHGrunts[][] = {
	")vo/halloween_boss/knight_alert01.mp3",
	")vo/halloween_boss/knight_alert02.mp3"
};

char g_HHHYells[][] = {
	")vo/halloween_boss/knight_attack01.mp3",
	")vo/halloween_boss/knight_attack02.mp3",
	")vo/halloween_boss/knight_attack03.mp3",
	")vo/halloween_boss/knight_attack04.mp3",
};

char g_HHHLaughs[][] = {
	")vo/halloween_boss/knight_laugh01.mp3",
	")vo/halloween_boss/knight_laugh02.mp3",
	")vo/halloween_boss/knight_laugh03.mp3",
	")vo/halloween_boss/knight_laugh04.mp3",
};

char g_HHHPain[][] = {
	")vo/halloween_boss/knight_pain01.mp3",
	")vo/halloween_boss/knight_pain02.mp3",
	")vo/halloween_boss/knight_pain03.mp3"
};

char g_WitchLaughs[][] = {
	")items/halloween/witch01.wav",
	")items/halloween/witch02.wav",
	")items/halloween/witch03.wav"
};

#define SOUND_HHH_DEATH												")vo/halloween_boss/knight_dying.mp3"
#define SOUND_DANGER_BIG_GUY_IS_HERE								")mvm/mvm_cpoint_klaxon.wav"
#define SOUND_DANGER_KILL_THIS_GUY_IMMEDIATELY						")vo/announcer_security_alert.mp3"
#define PARTICLE_DANGER_BIG_GUY_IS_HERE								"teleportedin_blue"

#endif

float f_ArrowDamage[MAXENTITIES];
int h_ArrowInflictorRef[MAXENTITIES];
Function i_ProjectileExtraFunction[MAXENTITIES] = {INVALID_FUNCTION, ...};
float h_BonusDmgToSpecialArrow[MAXENTITIES];
int f_ArrowTrailParticle[MAXENTITIES]={INVALID_ENT_REFERENCE, ...};
bool b_IsEntityAlwaysTranmitted[MAXENTITIES];
bool b_IsEntityNeverTranmitted[MAXENTITIES];
int b_NoHealthbar[MAXENTITIES];

float f_AprilFoolsSetStuff[MAXENTITIES];
//Arrays for npcs!
int i_NoEntityFoundCount[MAXENTITIES]={0, ...};
float f3_CustomMinMaxBoundingBox[MAXENTITIES][3];
float f3_CustomMinMaxBoundingBoxMinExtra[MAXENTITIES][3];
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
float fl_GravityMulti[MAXENTITIES];
int i_Target[MAXENTITIES];
float fl_GetClosestTargetTime[MAXENTITIES];
float fl_GetClosestTargetTimeTouch[MAXENTITIES];
int b_DoNotChangeTargetTouchNpc[MAXENTITIES];
float fl_GetClosestTargetNoResetTime[MAXENTITIES];
float fl_NextHurtSound[MAXENTITIES];
float fl_NextHurtSoundArmor[MAXENTITIES];
float fl_HeadshotCooldown[MAXENTITIES];
bool b_CantCollidie[MAXENTITIES];
bool b_CollidesWithEachother[MAXENTITIES];
bool b_CantCollidieAlly[MAXENTITIES];
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
bool b_ShowNpcHealthbar[MAXENTITIES];
bool b_TryToAvoidTraverse[MAXENTITIES];
bool b_NoKnockbackFromSources[MAXENTITIES];
bool b_IsATrigger[MAXENTITIES];
bool b_IsATriggerHurt[MAXENTITIES];
int i_NpcWeight[MAXENTITIES]; //This is used for scaling.
bool b_StaticNPC[MAXENTITIES];
float f3_VecTeleportBackSave[MAXENTITIES][3];
float f3_VecTeleportBackSaveJump[MAXENTITIES][3];
float f3_VecTeleportBackSave_OutOfBounds[MAXENTITIES][3];
float f_GameTimeTeleportBackSave_OutOfBounds[MAXENTITIES];
bool b_NPCVelocityCancel[MAXENTITIES];
bool b_NPCTeleportOutOfStuck[MAXENTITIES];
float fl_DoSpawnGesture[MAXENTITIES];
bool b_isWalking[MAXENTITIES];
bool b_DoNotGiveWaveDelay[MAXENTITIES];
bool b_TeamGlowDefault[MAXENTITIES];
int i_StepNoiseType[MAXENTITIES];
int i_NpcStepVariation[MAXENTITIES];
int i_BleedType[MAXENTITIES];
int i_State[MAXENTITIES];
int i_AnimationState[MAXENTITIES];
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
float fl_AbilityOrAttack[MAXENTITIES][10];

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
float fl_ArmorSetting[MAXENTITIES][3];
int i_ArmorSetting[MAXENTITIES][2];
bool b_InteractWithReload[MAXENTITIES];
bool b_DisableSetupMusic[MAXENTITIES];
bool b_DisableStatusEffectHints[MAXENTITIES];
bool b_LastManDisable[MAXENTITIES];
float f_HeadshotDamageMultiNpc[MAXENTITIES];

int b_OnDeathExtraLogicNpc[MAXENTITIES];
#define	ZRNPC_DEATH_NOHEALTH		( 1<<0 )	// Do not give health on kill!
#define	ZRNPC_DEATH_NOGIB		( 1<<1 )	// Do not give health on kill!

float f_MutePlayerTalkShutUp[MAXPLAYERS];
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
int i_Changed_WalkCycle[MAXENTITIES];
bool b_WasSadAlready[MAXENTITIES];
int i_TargetAlly[MAXENTITIES];
bool b_GetClosestTargetTimeAlly[MAXENTITIES];
float fl_Duration[MAXENTITIES];
int i_OverlordComboAttack[MAXENTITIES];
int i_TextEntity[MAXENTITIES][5];
float f_TextEntityDelay[MAXENTITIES];
float AntiSpamTipGive;

int i_Activity[MAXENTITIES];
int i_PoseMoveX[MAXENTITIES];
int i_PoseMoveY[MAXENTITIES];
//Arrays for npcs!
bool b_ThisWasAnNpc[MAXENTITIES];

bool Is_a_Medic[MAXENTITIES]; //THIS WAS INSIDE THE NPCS!

float f_CreditsOnKill[MAXENTITIES];

int i_InHurtZone[MAXENTITIES];
float fl_MeleeArmor[MAXENTITIES] = {1.0, ...};
float fl_RangedArmor[MAXENTITIES] = {1.0, ...};
float fl_TotalArmor[MAXENTITIES] = {1.0, ...};

float fl_Extra_MeleeArmor[MAXENTITIES] = {1.0, ...};
float fl_Extra_RangedArmor[MAXENTITIES] = {1.0, ...};
float fl_Extra_Speed[MAXENTITIES] = {1.0, ...};
float fl_Extra_Damage[MAXENTITIES] = {1.0, ...};
float fl_GibVulnerablity[MAXENTITIES] = {1.0, ...};
float f_RoleplayTalkLimit[MAXENTITIES] = {0.0, ...};

bool b_ScalesWithWaves[MAXENTITIES]; //THIS WAS INSIDE THE NPCS!

float f_StuckOutOfBoundsCheck[MAXENTITIES];
float f_CooldownForAbilities[MAXENTITIES][2];

int g_particleImpactMetal;

#if defined ZR
char c_HeadPlaceAttachmentGibName[MAXENTITIES][5];
#else
char c_HeadPlaceAttachmentGibName[MAXENTITIES][64];
#endif

float f_ExplodeDamageVulnerabilityNpc[MAXENTITIES];
#if defined ZR
float f_DelayNextWaveStartAdvancingDeathNpc;
int Armor_Wearable[MAXPLAYERS];
int Cosmetic_WearableExtra[MAXPLAYERS];
#endif

bool b_DamageNumbers[MAXPLAYERS];

int OriginalWeapon_AmmoType[MAXENTITIES];

/*
	Above Are Variables/Defines That Are Shared

	Below Are Shared Overrides
*/

#include "stocks_override.sp"
#include "master_takedamage.sp"
#include "npc_default_sounds.sp"	// NPC Stats is required here due to important methodmap
#include "npc_stats.sp"	// NPC Stats is required here due to important methodmap
#include "npc_collision_logic.sp"	// NPC collisions are sepearted for ease
#include "npc_trace_filters.sp"	// NPC trace filters are sepearted for ease

/*
	Below Are Variables/Defines That Are Per Gamemode
*/

#if defined ZR
#include "../zombie_riot/zr_core.sp"
#endif

#if defined RPG
#include "../rpg_fortress/rpg_core.sp"
#endif

#if defined RTS
#include "../fortress_wars/rts_core.sp"
#endif

#if defined NOG
#include "../standalone/nog_core.sp"
#endif

/*
	Below Are Non-Shared Variables/Defines
*/

#if defined ZR || defined RPG
#include "custom_melee_logic.sp"
#include "killfeed.sp"
#include "thirdperson.sp"
#include "viewchanges.sp"
#endif

#include "attributes.sp"

#include "commands.sp"
#include "convars.sp"
#include "dhooks.sp"
#include "events.sp"

#if defined ZR || defined NOG
#include "npccamera.sp"
#endif

#if defined ZR
#include "rtscamera.sp"
#endif

#include "baseboss_lagcompensation.sp"
#include "configs.sp"
#include "damage.sp"
#include "status_effects.sp"
#include "filenetwork.sp"
#include "npcs.sp"
#include "sdkcalls.sp"
#include "sdkhooks.sp"
#include "stocks.sp"
#include "wand_projectile.sp"

public Plugin myinfo =
{
	name		=	"NPC Gamemode Core",
	author		=	"Artvin & Batfoxkid & Mikusch",
	description	=	"Zombie Riot & Fortress Wars",
	version		=	"manual"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
#if defined ZR || defined RPG
	Thirdperson_PluginLoad();
#endif

#if defined ZR
	ZR_PluginLoad();
#endif

	return APLRes_Success;
}

public void OnPluginStart()
{
#if defined ZR
	CurrentAmmo[0] = { 1, 1, 1, 600, 1, 1, 1,
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
	1,
	1,
	1};
#endif
	
#if !defined NOG
	Commands_PluginStart();
	Events_PluginStart();
#endif
	checkOS();
	FileNetwork_PluginStart();

	RegServerCmd("zr_update_blocked_nav", OnReloadBlockNav, "Reload Nav Blocks");
	RegAdminCmd("sm_play_viewmodel_anim", Command_PlayViewmodelAnim, ADMFLAG_ROOT, "Testing viewmodel animation manually");

	RegAdminCmd("sm_toggle_fake_cheats", Command_ToggleCheats, ADMFLAG_GENERIC, "ToggleCheats");
	RegAdminCmd("zr_reload_plugin", Command_ToggleReload, ADMFLAG_GENERIC, "Reload plugin on map change");
	
	RegAdminCmd("sm_test_hud_notif", Command_Hudnotif, ADMFLAG_GENERIC, "Hud Notif");
	RegConsoleCmd("sm_getpos", GetPos);
	
	LoadTranslations("zombieriot.phrases");
	LoadTranslations("zombieriot.phrases.weapons.description");
	LoadTranslations("zombieriot.phrases.weapons");
	LoadTranslations("zombieriot.phrases.bob");
	LoadTranslations("zombieriot.phrases.tips");	
	LoadTranslations("zombieriot.phrases.icons");
	LoadTranslations("zombieriot.phrases.item.gift.desc"); 
	LoadTranslations("common.phrases");
	LoadTranslations("zombieriot.phrases.status_effects");
	
	DHook_Setup();
	SDKCall_Setup();
	ConVar_PluginStart();
	NPC_PluginStart();
	NPCStats_PluginStart();
	SDKHook_PluginStart();
	OnPluginStart_LagComp();
	NPC_Base_InitGamedata();
#if defined NPC_CAMERA
	NPCCamera_PluginStart();
#endif

#if defined NOG
	NOG_PluginStart();
#endif

#if defined RTS_CAMERA
	RTSCamera_PluginStart();
#endif
	
	SyncHud_Notifaction = CreateHudSynchronizer();
	SyncHud_WandMana = CreateHudSynchronizer();
#if defined ZR
	ZR_PluginStart();
#endif
	
#if defined RPG
	RPG_PluginStart();
#endif

#if defined ZR || defined RPG
	KillFeed_PluginStart();
	Thirdperson_PluginStart();
#endif

	WandProjectile_GamedataInit();
	
#if defined RTS
	RTS_PluginStart();
#endif

	//Global Hud for huds.

#if defined ZR
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			CurrentClass[client] = TF2_GetPlayerClass(client);
		}
	}
#endif

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
	Core_DoTickrateChanges();
}
void Core_DoTickrateChanges()
{
	//needs to get called a few times just incase.
	//it isnt expensive so it really doesnt matter.
	float tickrate = 1.0 / GetTickInterval();
	TickrateModifyInt = RoundToNearest(tickrate);

	TickrateModify = tickrate / 66.0;
}

public void OnLibraryAdded(const char[] name)
{
#if defined ZR
	FileNetwork_LibraryAdded(name);
	SteamWorks_LibraryAdded(name);
#endif
}

public void OnLibraryRemoved(const char[] name)
{
#if defined ZR
	FileNetwork_LibraryRemoved(name);
	SteamWorks_LibraryRemoved(name);
#endif
}

/*
public void OnAllPluginsLoaded()
{
	NPC_OnAllPluginsLoaded();
}
*/
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
	if(RaidbossIgnoreBuildingsLogic())
	{
		if(i_npcspawnprotection[EntRefToEntIndex(RaidBossActive)] > NPC_SPAWNPROT_INIT)
		{
			RaidModeTime += 0.2;
			//if the raidboss is in spawn protection, prevent raidmode from going up.
		}
		if (RaidModeScaling != 0.0 && RaidModeTime > GetGameTime() && RaidModeTime < GetGameTime() + 60.0)
		{
			PlayTickSound(true, false);
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Calculate_And_Display_hp(client, EntRefToEntIndex(RaidBossActive), 0.0, true, .RaidHudForce = true);
			}
		}
	}
	if (GetWaveSetupCooldown() > GetGameTime() && GetWaveSetupCooldown() < GetGameTime() + 10.0)
	{
		PlayTickSound(false, true);
	}
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
#if defined ZR
			if(!CvarInfiniteCash.BoolValue) //if on, assume were on a test server, dont slay.
				ForcePlayerSuicide(i);
#endif
		}
	}

	
#if defined RTS_CAMERA
	RTSCamera_PluginEnd();
#endif

#if defined RPG
	RPG_PluginEnd();
#endif

#if defined ZR
//	Waves_MapEnd(); DO NOT CALL THIS ON PLUGIN END, plugin ends anways, why change anything???
	RemoveMVMLogicSafety();
	Vehicle_PluginEnd();
#endif
	float WaitingForPlayersTime = FindConVar("mp_waitingforplayers_time").FloatValue;
	if(WaitingForPlayersTime <= 0.0)
		return;
	//Fixes ZR breaking waiting for players.
	GameRules_SetProp("m_bInWaitingForPlayers", false);
}

#if defined ZR
void RemoveMVMLogicSafety()
{
	char mapname[64];
	GetMapName(mapname, sizeof(mapname));
	if(!StrContains(mapname, "mvm_"))
	{
		//This new map has MVM logic, DO NOT REMOVE MVM!!!
		RevertMVMPoplator();
		return;
	}
	MVMHud_Disable();
//	GameRules_SetProp("m_iRoundstate", 0);
	
	int populator = FindEntityByClassname(-1, "info_populator");
	if (populator != -1)
	{
		//find populator
		// Using RemoveImmediate is required because RemoveEntity deletes the populator a few frames later.
		// This may cause the global populator pointer to be set to NULL even if a new populator was created.
		SDKCall_RemoveImmediate(populator);
	}
}
#endif

void Core_PrecacheGlobalCustom()
{
	PrecacheSoundCustom("zombiesurvival/headshot1.wav");
	PrecacheSoundCustom("zombiesurvival/headshot2.wav");
	PrecacheSoundCustom("zombiesurvival/hm.mp3");
}
public void OnMapStart()
{
	AntiSpamTipGive = 0.0;
	PrecacheSound("weapons/knife_swing_crit.wav");
	PrecacheSound("weapons/shotgun/shotgun_dbl_fire.wav");
	PrecacheSound("npc/vort/attack_shoot.wav");
	PrecacheSound("npc/strider/fire.wav");
	PrecacheSound("weapons/shotgun/shotgun_fire7.wav");
	PrecacheSound("#items/tf_music_upgrade_machine.wav");
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
	PrecacheSound("physics/metal/metal_box_impact_bullet2.wav");
	PrecacheSound("physics/metal/metal_box_impact_bullet3.wav");
	PrecacheSound("npc/assassin/ball_zap1.wav");
	PrecacheSound("misc/halloween/spell_overheal.wav");
	PrecacheSound("weapons/gauss/fire1.wav");
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
	PrecacheSound("weapons/capper_shoot.wav");
	PrecacheSound("ambient/explosions/explode_3.wav");
	PrecacheSound("ui/medic_alert.wav");
	PrecacheSound("weapons/drg_wrench_teleport.wav");
	PrecacheSound("weapons/medigun_no_target.wav");

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
	PrecacheSound("weapons/breadmonster/throwable/bm_throwable_throw.wav");
	PrecacheSound("weapons/samurai/tf_marked_for_death_indicator.wav");
	Zero(f_PreventMovementClient);
	Zero(f_PreventMedigunCrashMaybe);
	Zero(f_ClientReviveDelayReviveTime);
	Zero(f_MutePlayerTalkShutUp);
	ResetIgnorePointVisible();
	DHooks_MapStart();
#if defined ZR || defined RPG
	FileNetwork_MapStart();
	Core_PrecacheGlobalCustom();
#endif
	Core_DoTickrateChanges();
	PrecacheSound("weapons/explode1.wav");
	PrecacheSound("weapons/explode2.wav");
	PrecacheSound("weapons/explode3.wav");
	PrecacheSound(")weapons/pipe_bomb1.wav");
	PrecacheSound(")weapons/pipe_bomb2.wav");
	PrecacheSound(")weapons/pipe_bomb3.wav");

	PrecacheModel(COMBINE_CUSTOM_MODEL);
	PrecacheModel(COMBINE_CUSTOM_2_MODEL);
	PrecacheModel(WEAPON_CUSTOM_WEAPONRY_1);
	PrecacheModel(WINGS_MODELS_1);
	
	//PrecacheModel(ZR_TEST_MODEL);

	PrecacheModel(RUINA_CUSTOM_MODELS_1);
	PrecacheModel(RUINA_CUSTOM_MODELS_2);
	PrecacheModel(RUINA_CUSTOM_MODELS_3);
	PrecacheModel(RUINA_CUSTOM_MODELS_4);
	
#if defined ZR
	PrecacheSound("npc/scanner/cbot_discharge1.wav");
	Zero(i_CustomWeaponEquipLogic);
	Zero(Mana_Hud_Delay);
	Zero(Mana_Regen_Delay);
	Zero(Mana_Regen_Delay_Aggreviated);
//	Zero(RollAngle_Regen_Delay);
	Zero(f_InBattleHudDisableDelay);
	Zero(f_InBattleDelay);
	Zero(f_TimerStatusEffectsDo);
	Building_MapStart();
#endif
	
	for(int i = 0; i <= MAXENTITIES; i++)
	{
		EntityKilled_HitDetectionCooldown(i);
	}
	SDKHooks_ClearAll();
	InitStatusEffects();

	Zero(f_MinicritSoundDelay);
	Zero(b_IsAGib);
	Zero(i_Hex_WeaponUsesTheseAbilities);
	Zero(f_WidowsWineDebuffPlayerCooldown);
	Zero(f_TempCooldownForVisualManaPotions);
	Zero(i_IsABuilding);
	Zero(f_ImmuneToFalldamage);
	Zero(f_DelayLookingAtHud);
	Zero(f_TimeUntillNormalHeal);
	Zero(f_ClientWasTooLongInsideHurtZone);
	Zero(f_ClientWasTooLongInsideHurtZoneDamage);
	Zero(f_ClientWasTooLongInsideHurtZoneStairs);
	Zero(f_ClientWasTooLongInsideHurtZoneDamageStairs);
	Zero(delay_hud);
	Zero(Resistance_for_building_Low);
	Zero(f_BotDelayShow);
	Zero(f_OneShotProtectionTimer);
	CleanAllNpcArray();
	Zero(h_NpcCollissionHookType);
	Zero(h_NpcSolidHookType);
	Zero(h_NpcHandleEventHook);
	Zero(b_KillHookHandleEvent);
	Zero2(i_StickyToNpcCount);
	Zero(f_DelayBuildNotif);
	Zero(f_ClientInvul);
	Zero(i_HasBeenBackstabbed);
	Zero(i_HasBeenHeadShotted);
	Zero(f_GibHealingAmount);
	Zero(f_StunExtraGametimeDuration);
	CurrentGibCount = 0;
	Zero(b_NetworkedCrouch);
	
#if defined VIEW_CHANGES
	ViewChange_MapStart();
#endif

#if defined ZR
	ZR_MapStart();
	Waves_SetReadyStatus(2, false);
#endif

#if defined RPG
	RPG_MapStart();
#endif

#if defined ZR || defined RPG
	MapStart_CustomMeleePrecache();
	WandStocks_Map_Precache();
#endif

#if defined RTS
	RTS_MapStart();
#endif

#if defined RTS_CAMERA
	RTSCamera_MapStart();
#endif

	Npc_Sp_Precache();
	OnMapStart_NPC_Base();
	SDKHook_MapStart();
	MapStartResetNpc();
	Zero(f_AntiStuckPhaseThroughFirstCheck);
	Zero(f_AntiStuckPhaseThrough);
	Zero(f_BegPlayerToSetRagdollFade);
	Zero(f_BegPlayerR_TeethSet);
	g_iHaloMaterial_Trace = PrecacheModel("materials/sprites/halo01.vmt");
	g_iLaserMaterial_Trace = PrecacheModel("materials/sprites/laserbeam.vmt");
	CreateTimer(0.2, Timer_Temp, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	PrecacheSound("mvm/mvm_tank_horn.wav");
	DeleteShadowsOffZombieRiot();

	if(LibraryExists("LoadSoundscript"))
	{
		char soundname[256];
		SoundScript soundscript = LoadSoundScript("scripts/game_sounds_vehicles.txt");
		for(int i = 0; i < soundscript.Count; i++)
		{
			SoundEntry entry = soundscript.GetSound(i);
			entry.GetName(soundname, sizeof(soundname));
			PrecacheScriptSound(soundname);
		}
	}
	ConVar_ToggleDo();
	CAddColor("redsunfirst", 0xF78C56);
	CAddColor("redsunsecond", 0xEEA953);
}

void DeleteShadowsOffZombieRiot()
{
	//found shadow lod
	int entityshadow = -1;
	entityshadow = FindEntityByClassname(entityshadow, "shadow_control");

	if(!IsValidEntity(entityshadow))
	{
		entityshadow = CreateEntityByName("shadow_control");
		DispatchSpawn(entityshadow);
	}
	
	//Create new shadow entity, and make own own rules
	//This disables shadows form npcs, entirely unneecceary as some models have broken as hell shadows.
	if(IsValidEntity(entityshadow))
	{
		//This just badly hides shadows
		/*
		Whenever we set sv_cheats to 1, and to 0, it sets r_shadows_gamecontrol  to all clients to 0
		to fix this we have to delete and remake the shadow controll EVERY TIME.
		This is terrible
		Colour atleast just hides ths shadows which is fine enough, i guess.

		We cant set EF_NOSHADOW  on npcs for some reason either ,it is a dark day.
		*/
		DispatchKeyValue(entityshadow,"color", "255 255 255 0");
		SetVariantInt(1); 
		AcceptEntityInput(entityshadow, "SetShadowsDisabled"); 
	}

}

public void OnMapEnd()
{
#if defined ZR
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client))
		{
			KickClient(client);
		}
	}
	Store_RandomizeNPCStore(ZR_STORE_RESET);
	OnRoundEnd(null, NULL_STRING, false);
	Waves_MapEnd();
	Spawns_MapEnd();
	Vehicle_MapEnd();
	NPC_MapEnd();
#endif

#if defined RPG
	RPG_MapEnd();
#endif

	Configs_MapEnd();
	ConVar_Disable();
	FileNetwork_MapEnd();
	NpcStats_OnMapEnd();
#if defined ZR
	RemoveMVMLogicSafety();
#endif
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

public void OnGameFrame()
{
#if defined ZR
	int MaxLimitTest = 0;
	while(NPC_SpawnNext(false, false))
	{
		MaxLimitTest++;
		//failsafe
		if(MaxLimitTest >= 2)
		{
			break;
		}
	}
#endif	
#if defined RPG
	DoubleJumpGameFrame();
#endif	
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
		ResetReplications();
		Toggle_sv_cheats = false;
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "0");
				Convars_FixClientsideIssues(i);
			}
		}	
	}
	else
	{
		ResetReplications();
		Toggle_sv_cheats = true;
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "1");
				Convars_FixClientsideIssues(i);
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
	float Ang[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	ReplyToCommand(client, "m_vecOrigin: %f %f %f", pos[0], pos[1], pos[2]);

	GetClientEyeAngles(client, Ang);
	ReplyToCommand(client, "m_vecAngles: %f %f %f", Ang[0], Ang[1], Ang[2]);

	ReplyToCommand(client, "Bulding Copypaste: %.1f %.1f %.1f;%.1f %.1f %.1f", pos[0], pos[1], pos[2], Ang[0], Ang[1], Ang[2]);
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

//ty miku for tellingg
public void ConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientMusicVolume[client] = StringToFloat(cvarValue);
}
public void ConVarCallback_DamageNumbers(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
	{
		if(StringToInt(cvarValue) == 0)
		{
			b_DamageNumbers[client] = false;
		}
		else
		{
			b_DamageNumbers[client] = true;
		}
	}
}
public void ConVarCallback_FirstPersonViewModel(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		b_FirstPersonUsesWorldModel[client] = view_as<bool>(StringToInt(cvarValue));
}

public void ConVarCallback_g_ragdoll_fadespeed(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
	{
		if(StringToInt(cvarValue) == 0)
		{
			SetGlobalTransTarget(client);
			SPrintToChat(client,"%t", "Show Ragdoll Hint Message");
		}
		else
		{
			f_BegPlayerToSetRagdollFade[client] = FAR_FUTURE;
		}
	}
}

public void ConVarCallback_r_teeth(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
	{
		if(StringToInt(cvarValue) == 1)
		{
			SetGlobalTransTarget(client);
			SPrintToChat(client,"%t", "Show Ragdoll Teeth Message");
		}
		else
		{
			f_BegPlayerR_TeethSet[client] = FAR_FUTURE;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
#if defined ZR
	Database_ClientPostAdminCheck(client);
#endif
}
				
public void OnClientPutInServer(int client)
{
	Core_DoTickrateChanges();
#if defined ZR || defined RPG
	KillFeed_ClientPutInServer(client);
#endif

	b_IsPlayerABot[client] = false;
	TeamNumber[client] = -1;
#if !defined NOG
	if(IsFakeClient(client))
	{
		if(IsClientSourceTV(client))
		{
			f_ClientMusicVolume[client] = 1.0;
			f_ZombieVolumeSetting[client] = 0.0;
			SetTeam(client, TFTeam_Spectator);
			b_IsPlayerABot[client] = true;
			return;
		}
		/*	
			We will abuse mvm bot spawn logic!
			Only allow 2 bots!
		*/	
		int botcount;
		for(int clientloop = 1; clientloop <= MaxClients; clientloop++)
		{
			if(IsClientInGame(clientloop) && IsFakeClient(clientloop) && !IsClientSourceTV(clientloop))
			{
				botcount += 1;
				if(botcount > 2)
				{
					KickClient(client);
					return;
				}
			}
		}
		SetTeam(client, TFTeam_Blue);
		DHook_HookClient(client);
		b_IsPlayerABot[client] = true;
		return;
	}
#endif
	b_GivePlayerHint[client] = false;
	f_ClientConnectTime[client] = GetGameTime() + 30.0;
	//do cooldown upon connection.
	f_ClientInvul[client] = 0.0;
	f_RoleplayTalkLimit[client] = 0.0;
#if !defined NOG
	DHook_HookClient(client);
#endif
	FileNetwork_ClientPutInServer(client);
	SDKHook_HookClient(client);

#if defined ZR
	PrepareMusicVolume[client] = 0.0;
	SetMusicTimer(client, GetTime() + 1);
	AdjustBotCount();
	WeaponClass[client] = TFClass_Scout;
	f_BegPlayerToSetRagdollFade[client] = GetGameTime() + 20.0;
	f_BegPlayerR_TeethSet[client] = GetGameTime() + 40.0;
#endif
	
	f_ClientReviveDelay[client] = 0.0;
	f_ClientBeingReviveDelay[client] = 0.0;
	f_ClientReviveDelayMax[client] = 0.0;
	f_DisplayDamageHudCooldown[client] = 0.0;
	
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	f_MultiDamageTaken[client] = 1.0;
	f_MultiDamageTaken_Flat[client] = 1.0;
	f_MultiDamageDealt[client] = 1.0;
	
#if defined ZR
	ResetExplainBuffStatus(client);
	f_TutorialUpdateStep[client] = 0.0;
	ZR_ClientPutInServer(client);
#endif
	
#if defined RPG
	RPG_PutInServer(client);

	if(AreClientCookiesCached(client)) //Ingore this. This only bugs it out, just force it, who cares.
		OnClientCookiesCached(client);
		
	RequestFrame(CheckIfAloneOnServer);	
#endif

	QueryClientConVar(client, "snd_musicvolume", ConVarCallback);
	QueryClientConVar(client, "cl_first_person_uses_world_model", ConVarCallback_FirstPersonViewModel);

#if defined ZR
	SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN | HIDEHUD_BONUS_PROGRESS); 
	if(ForceNiko)
		OverridePlayerModel(client, NIKO_2, true);
	if(!Waves_Started() || Waves_InSetup())
	{
		DoGlobalMultiScaling();
		if(b_AntiLateSpawn_Allow[client])
			b_HasBeenHereSinceStartOfWave[client] = true;
	}
#endif
	MedigunPutInServerclient(client);
}

public void OnClientCookiesCached(int client)
{	
#if defined RPG
	RPG_ClientCookiesCached(client);
#endif

#if defined RTS_CAMERA
	RTSCamera_ClientCookiesCached(client);
#endif
}

public void OnClientDisconnect(int client)
{
	FileNetwork_ClientDisconnect(client);

#if defined VIEW_CHANGES
	ViewChange_ClientDisconnect(client);
#endif

#if defined ZR || defined RPG
	KillFeed_ClientDisconnect(client);
	Store_ClientDisconnect(client);
	Current_Mana[client] = 0;
#endif

#if defined RTS
	RTS_ClientDisconnect(client);
#endif

#if defined RTS_CAMERA
	RTSCamera_ClientDisconnect(client);
#endif

	i_ClientHasCustomGearEquipped[client] = 0;
	i_EntityToAlwaysMeleeHit[client] = 0;
	ReplicateClient_Svairaccelerate[client] = -1.0;
	ReplicateClient_BackwardsWalk[client] = -1.0;
	ReplicateClient_LostFooting[client] = -1.0;
	ReplicateClient_Gravity[client] = -1;
	i_Client_Gravity[client] = 800; //incase
	ReplicateClient_Tfsolidobjects[client] = -1;
	ReplicateClient_RollAngle[client] = -1;
	b_NetworkedCrouch[client] = false;
	//Reset!

#if defined ZR
	f_InBattleHudDisableDelay[client] = 0.0;
	f_InBattleDelay[client] = 0.0;
	i_HealthBeforeSuit[client] = 0;
	f_ClientArmorRegen[client] = 0.0;
	b_HoldingInspectWeapon[client] = false;
	f_MedicCallIngore[client] = 0.0;
	ZR_ClientDisconnect(client);
	f_DelayAttackspeedAnimation[client] = 0.0;
	f_BuildingIsNotReady[client] = 0.0;
	f_VintulumBombRecentlyUsed[client] = 0.0;
	//Needed to reset attackspeed stuff
#endif

	b_DisplayDamageHud[client][0] = false;
	b_DisplayDamageHud[client][1] = false;

#if defined ZR
	WeaponClass[client] = TFClass_Scout;
#endif

#if defined RPG
	RPG_ClientDisconnect(client);
#endif

	b_HudScreenShake[client] = true;
	b_HudLowHealthShake_UNSUED[client] = true;
	b_HudHitMarker[client] = true;
	b_DisplayDamageHudSettingInvert[client] = false;
	f_ZombieVolumeSetting[client] = 0.0;
}

public void OnClientDisconnect_Post(int client)
{
#if defined ZR
	ZR_OnClientDisconnect_Post();
	RequestFrame(CheckIfAloneOnServer);
#endif

#if defined RPG
	RequestFrame(CheckIfAloneOnServer);
	RPG_ClientDisconnect_Post();
#endif
}

#if defined RTS_CAMERA
public void OnPlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	RTSCamera_PlayerRunCmdPre(client, buttons, impulse, vel, weapon, mouse);
}
#endif

#if defined ZR
static bool was_reviving[MAXPLAYERS];
static int was_reviving_this[MAXPLAYERS];
#endif

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(b_IsPlayerABot[client])
	{
		return Plugin_Continue;
	}
	if(f_PreventMedigunCrashMaybe[client] > GetGameTime())
	{
		buttons &= ~IN_ATTACK;
	}
	if(f_PreventMovementClient[client] > GetGameTime())
	{
		buttons = 0;
		return Plugin_Changed;
	}
	/*
	Instant community feedback that T is very bad.
	using idk what other button to use.
	*/
#if defined ZR
	if(impulse == 201)
	{
		bool BlockImpulse = false;
		//if the cvar is on, but we want spray again
		if(zr_interactforcereload.BoolValue)
		{
			BlockImpulse = true;
		}

		if(BlockImpulse)
		{
			if(b_InteractWithReload[client])
				BlockImpulse = false;
			else
				BlockImpulse = true;
		}
		else
		{
			if(b_InteractWithReload[client])
				BlockImpulse = true;
			else
				BlockImpulse = false;
		}
		if(!BlockImpulse)
		{
			f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
			//We want to spray, but spray in ZR means interaction!
			//do we hold score?
			if(!(buttons & IN_SCORE))
			{
				impulse = 0;
			}
			DoInteractKeyLogic(angles, client);

		}
	}

	if(buttons & IN_ATTACK3)
		buttons |= IN_SPEED;
#endif
//Is player active? atleast somewhat.
	if(buttons > 0)
	{
		f_PlayerLastKeyDetected[client] = GetGameTime() + 2.0;
	}
	if(EntityFuncPlayerRunCmd[client] && EntityFuncPlayerRunCmd[client] != INVALID_FUNCTION)
	{
		Call_StartFunction(null, EntityFuncPlayerRunCmd[client]);
		Call_PushCell(client);
		Call_PushCellRef(buttons);
		Call_PushCellRef(impulse);
		Call_PushArray(vel, sizeof(vel));
		Call_PushArray(angles, sizeof(angles));
		Call_PushCellRef(weapon);
		Call_PushCellRef(subtype);
		Call_PushCellRef(cmdnum);
		Call_PushCellRef(tickcount);
		Call_PushCellRef(seed);
		Call_PushArray(mouse, sizeof(mouse));
		Call_Finish();
	}
	OnPlayerRunCmd_Lag_Comp(client, angles, tickcount);
	
#if defined RTS
	RTS_PlayerRunCmd(client);
#endif

#if defined ZR
	Escape_PlayerRunCmd(client);
	
	//tutorial stuff.
	Tutorial_MakeClientNotMove(client);

	if(SkillTree_PlayerRunCmd(client, buttons, vel))
		return Plugin_Changed;
	
	if(BetWar_PlayerRunCmd(client, buttons, vel))
		return Plugin_Changed;
#endif

#if defined RPG
	if(Plots_PlayerRunCmd(client, buttons))
		return Plugin_Changed;
#endif

#if defined ZR || defined RPG
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
	
	static int holding[MAXPLAYERS];
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
	
	//support in_use
	if(holding[client] & IN_USE)
	{
		if(!(buttons & IN_USE))
			holding[client] &= ~IN_USE;
	}
	else if(buttons & IN_USE)
	{
		holding[client] |= IN_USE;
		
		f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
		DoInteractKeyLogic(angles, client);
	}
	
	if(holding[client] & IN_ATTACK2)
	{
		if(!(buttons & IN_ATTACK2))
			holding[client] &= ~IN_ATTACK2;
		else
		{
			if(f_CooldownForAbilities[client][0] < GetGameTime())
			{
				f_CooldownForAbilities[client][0] = GetGameTime() + 0.1;
				if(Ability_Check_Cooldown(client, 2) < 0.0)
				{
					f_CooldownForAbilities[client][0] = GetGameTime() + 0.5;
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
					}
				}
			}
		}
			
	}
	else if(buttons & IN_ATTACK2)
	{
		holding[client] |= IN_ATTACK2;
		
#if defined ZR
		b_IgnoreWarningForReloadBuidling[client] = false;
#endif
		f_CooldownForAbilities[client][0] = GetGameTime() + 0.5;
		// force wait 1 second so it isnt activated automatically

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
		}
	}
	
	if(holding[client] & IN_RELOAD)
	{
		if(!(buttons & IN_RELOAD))
			holding[client] &= ~IN_RELOAD;
		else
		{
			if(f_CooldownForAbilities[client][1] < GetGameTime())
			{
				f_CooldownForAbilities[client][1] = GetGameTime() + 0.1;
				if(Ability_Check_Cooldown(client, 3) < 0.0)
				{
					f_CooldownForAbilities[client][1] = GetGameTime() + 0.5;
					bool AllowImpulse = true;
				
					AllowImpulse = false;
					//if the cvar is on, but we want spray again
					if(zr_interactforcereload.BoolValue)
					{
						AllowImpulse = true;
					}

					if(AllowImpulse)
					{
						if(b_InteractWithReload[client])
							AllowImpulse = false;
						else
							AllowImpulse = true;
					}
					else
					{
						if(b_InteractWithReload[client])
							AllowImpulse = true;
						else
							AllowImpulse = false;
					}

					
					if(AllowImpulse)
					{
						f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
						if(DoInteractKeyLogic(angles, client))
							return Plugin_Continue;
					}

					// force wait 1 second so it isnt activated automatically
					int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
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
		}
	}
	else if(buttons & IN_RELOAD)
	{
		holding[client] |= IN_RELOAD;
		
		bool AllowImpulse = true;
		
		AllowImpulse = false;
		//if the cvar is on, but we want spray again
		if(zr_interactforcereload.BoolValue)
		{
			AllowImpulse = true;
		}

		if(AllowImpulse)
		{
			if(b_InteractWithReload[client])
				AllowImpulse = false;
			else
				AllowImpulse = true;
		}
		else
		{
			if(b_InteractWithReload[client])
				AllowImpulse = true;
			else
				AllowImpulse = false;
		}

		if(AllowImpulse)
		{
			f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
			if(DoInteractKeyLogic(angles, client))
				return Plugin_Continue;
		}

		f_CooldownForAbilities[client][1] = GetGameTime() + 0.5;
		// force wait 1 second so it isnt activated automatically
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
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

	if(holding[client] & IN_SCORE)
	{
		if(!(buttons & IN_SCORE))
			holding[client] &= ~IN_SCORE;
	}
	else if(buttons & IN_SCORE)
	{
		holding[client] |= IN_SCORE;
		
#if defined ZR
		if(GetClientTeam(client) == 2)
		{
			if(dieingstate[client] == 0)
			{
				if(WaitingInQueue[client])
				{
					Queue_Menu(client);
				}
				else
				{
					Store_Menu(client);
				}
			}
		}
		else
		{
			
			if(LastStoreMenu[client] || AnyMenuOpen[client])
			{
				HideMenuInstantly(client);
				//show a blank page to instantly hide it
				CancelClientMenu(client);
				ClientCommand(client, "slot10");
				ResetStoreMenuLogic(client);
			}
			else
			{
				c_WeaponUseAbilitiesHud[client][0] = 0;
				Items_EncyclopediaMenu(client);
			}
		}
#endif

#if defined RPG
		FakeClientCommandEx(client, "menuselect 0");
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
		
		if((f_ClientReviveDelayReviveTime[client] > GetGameTime()) && dieingstate[client] <= 0 && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
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
					f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
					ReviveClientFromOrToEntity(target, client);
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
					f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
					int ticks;
					was_reviving[client] = true;
					f_DelayLookingAtHud[client] = GameTime + 0.5;
					was_reviving_this[client] = target;
					int speed = (i_CurrentEquippedPerk[client] & PERK_REGENE) ? 12 : 6;
					Rogue_ReviveSpeed(speed);
					ticks = Citizen_ReviveTicks(target, speed, client);
					
					if(ticks <= 0)
					{
						PrintCenterText(client, "");
					}
					else
					{
						PrintCenterText(client, "%t", "Reviving", ticks);
					}
				}
			}
		}
		ClientRevivalTickLogic(client);
	}
#endif	// ZR
#endif	// ZR & RPG

	if(f_PreventMedigunCrashMaybe[client] > GetGameTime())
	{
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void Movetype_walk(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon)
{
#if defined ZR
	SemiAutoWeapon(client, buttons);
#endif

#if defined RPG
	RPG_PlayerRunCmdPost(client, buttons);
#endif
}

#if defined ZR || defined RPG

#if defined ZR
public void Update_Ammo(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidClient(client) && IsPlayerAlive(client) && i_HealthBeforeSuit[client] == 0 && TeutonType[client] == TEUTON_NONE)
	{
		for(int i; i<Ammo_MAX; i++)
		{
			CurrentAmmo[client][i] = GetAmmo(client, i);
		}
	}
	else
	{
		delete pack;
		return;
	}
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
	int weapon_ref = pack.ReadCell();
	if(weapon_ref == -1)
	{
		Clip_SaveAllWeaponsClipSizes(client);
	}
	else
	{
		int weapon = EntRefToEntIndex(weapon_ref);
		if(IsValidEntity(weapon))
		{
			ClipSaveSingle(client, weapon);
		}
	}
	delete pack;
}
#endif


public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
#if defined ZR
	if(i_HealthBeforeSuit[client] == 0 && TeutonType[client] == TEUTON_NONE)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		RequestFrame(Update_Ammo, pack);
	}
	float ExtraAmmoConsume = Attributes_Get(weapon, 4014, 0.0);
	if(ExtraAmmoConsume != 0.0)
	{
		if(ExtraAmmoConsume > 0.0)
		{
			f_AmmoConsumeExtra[client] += ExtraAmmoConsume;
			
			int ConsumeAmmoReserve;
			while (f_AmmoConsumeExtra[client] >= 1.0)
			{
				f_AmmoConsumeExtra[client] -= 1.0;
				ConsumeAmmoReserve++;
			}
			if(ConsumeAmmoReserve >= 1)
			{
				int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
				SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type) - ConsumeAmmoReserve);
			}
		}
		else
		{
			//it is negative, we give back ammo?
			f_AmmoConsumeExtra[client] += ExtraAmmoConsume;
			
			int ConsumeAmmoReserve;
			while (f_AmmoConsumeExtra[client] <= -1.0)
			{
				f_AmmoConsumeExtra[client] += 1.0;
				ConsumeAmmoReserve++;
			}
			if(ConsumeAmmoReserve >= 1)
			{
				int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
				if(Ammo_type >= 1)
					SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type) + ConsumeAmmoReserve);
			}
		}
	}
#endif

#if defined RPG
	//Set ammo to inf here.
	SetAmmo(client, 1, 9999);
	SetAmmo(client, 2, 9999);

	RPGStore_SetWeaponDamageToDefault(weapon, client, classname);
	WeaponAttackResourceReduction(client, weapon);
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
		
	}
	DataPack pack_WeaponAmmo = new DataPack();
	pack_WeaponAmmo.WriteCell(EntIndexToEntRef(client));
	pack_WeaponAmmo.WriteCell(EntIndexToEntRef(weapon));
	RequestFrame(CheckWeaponAmmoLogicExternal, pack_WeaponAmmo);
	
	float GameTime = GetGameTime();
	int WeaponSlot = TF2_GetClassnameSlot(classname, weapon);

	if(i_OverrideWeaponSlot[weapon] != -1)
	{
		WeaponSlot = i_OverrideWeaponSlot[weapon];
	}
	if(WeaponSlot == TFWeaponSlot_Melee)
	{
		//If it stoo fast then we dont want to do it eveytime, that can be laggy and it doesnt even change anything.
		//Also check if its the exact same number again, if it is, dont even set it.
		//0.25 is a sane number!
		if(f_DelayAttackspeedAnimation[client] < GameTime)
		{
			f_DelayAttackspeedAnimation[client] = GameTime + 0.25;

			float attack_speed;
			
			attack_speed = 1.0 / Attributes_Get(weapon, 6, 1.0);
			attack_speed *= (1.0 / Attributes_Get(weapon, 396, 1.0));

			if(f_ModifThirdPersonAttackspeed[weapon] != 1.0)
				attack_speed *= f_ModifThirdPersonAttackspeed[weapon];
			
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
//#if defined ZR
//		if(i_IsWandWeapon[weapon] != 1 && (StrContains(classname, "tf_weapon_wrench") || EntityFuncAttack[weapon] == Wrench_Hit_Repair_Replacement))
//#else
		if(i_IsWandWeapon[weapon] != 1 && (StrContains(classname, "tf_weapon_wrench")))
//#endif
		{
			if(Panic_Attack[weapon] != 0.0 && !i_IsWrench[weapon])
			{
				float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
				
#if defined ZR
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_FULLMOON)
				{
					//itll think youre much lower HP then usual. NEEDED! otherwise this weapon SUCKS!!!!!!!
					flHealth *= 0.65; 
				}
#endif
				float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);

				if(flpercenthpfrommax >= 1.0)
					flpercenthpfrommax = 1.0; //maths to not allow negative suuuper slow attack speed
					
				float Attack_speed = flpercenthpfrommax / 0.65;
				
				if(Attack_speed <= Panic_Attack[weapon])
				{
					Attack_speed = Panic_Attack[weapon]; //DONT GO ABOVE THIS, WILL BREAK SOME MELEE'S DUE TO THEIR ALREADY increased ATTACK SPEED.
				}
				
				
#if defined ZR
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_FULLMOON)
				{
					if (Attack_speed >= 1.0)
					{
						Attack_speed = 1.0; //hardcoding this lol
					} 
				}
#endif
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
			if((!StrContains(classname, "tf_weapon_knife") || i_MeleeAttackFrameDelay[weapon] == 0) && i_InternalMeleeTrace[weapon])
			{
				Timer_Do_Melee_Attack(weapon, client, 0, classname);
			}
			else if(i_InternalMeleeTrace[weapon])
			{
				Timer_Do_Melee_Attack(weapon, client, i_MeleeAttackFrameDelay[weapon], classname);
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
#endif	// ZR & RPG

#if defined ZR
void SDKHook_TeamSpawn_SpawnPost(int entity)
{
	if(!IsValidEntity(entity))
		return;
	
	SDKHook_TeamSpawn_SpawnPostInternal(entity);
}
void SDKHook_TeamSpawn_SpawnPostInternal(int entity, int SpawnsMax = 2000000000, int i_SpawnSetting = 0, int MaxWaves = 999)
{
	for (int i = 0; i < ZR_MAX_SPAWNERS; i++)
	{
		if (i_ObjectsSpawners[i] == entity)
			return;
	}

	for (int i = 0; i < ZR_MAX_SPAWNERS; i++)
	{
		if (!IsValidEntity(i_ObjectsSpawners[i]))
		{
			bool Allyspawn = false;

			if(GetTeam(entity) == TFTeam_Red)
				Allyspawn = true;

			Spawns_AddToArray(entity,_, Allyspawn, SpawnsMax, i_SpawnSetting, MaxWaves);
			
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
	if(entity > CurrentEntities)
		CurrentEntities = entity;

#if defined ZR
	if (!StrContains(classname, "info_player_teamspawn")) 
	{
		RequestFrame(SDKHook_TeamSpawn_SpawnPost, entity);
	}
#endif
//	PrintToChatAll("entity: %i| Clkassname %s",entity, classname);
	if (entity > 0 && entity <= 2048 && IsValidEntity(entity))
	{
		f_TimeTillMeleeAttackShould[entity] = 0.0;
		StatusEffectReset(entity, true);
		f_InBattleDelay[entity] = 0.0;
		b_AllowCollideWithSelfTeam[entity] = false;
		NPCStats_SetFuncsToZero(entity);
		f3_VecTeleportBackSave_OutOfBounds[entity][0] = 0.0;
		f3_VecTeleportBackSave_OutOfBounds[entity][1] = 0.0;
		f3_VecTeleportBackSave_OutOfBounds[entity][2] = 0.0;
		f_GameTimeTeleportBackSave_OutOfBounds[entity] = 0.0;
		b_ThisEntityIgnoredBeingCarried[entity] = false;
		f_ClientInvul[entity] = 0.0;
		i_SavedActualWeaponSlot[entity] = -1;
#if !defined RTS
		f_BackstabDmgMulti[entity] = 0.0;
#endif
		f_KnockbackPullDuration[entity] = 0.0;
		i_PullTowardsTarget[entity] = 0;
		f_PullStrength[entity] = 0.0;
#if defined ZR || defined RPG
		CoinEntityCreated(entity);
#endif
		//set it to 0!
		i_ExplosiveProjectileHexArray[entity] = 0;
		b_ThisWasAnNpc[entity] = false;
		i_WeaponSoundIndexOverride[entity] = 0;
		f_WeaponSizeOverride[entity] = 1.0;
		f_WeaponSizeOverrideViewmodel[entity] = 1.0;
		f_WeaponVolumeStiller[entity] = 1.0;
		i_WeaponModelIndexOverride[entity] = 0;
		i_WeaponVMTExtraSetting[entity] = -1;
		i_WeaponBodygroup[entity] = -1;
		i_WeaponFakeIndex[entity] = -1;
		b_NoKnockbackFromSources[entity] = false;
		f_ExplodeDamageVulnerabilityNpc[entity] = 1.0;
#if defined ZR
		b_FaceStabber[entity] = false;
		i_CustomWeaponEquipLogic[entity] = -1;
		Resistance_for_building_High[entity] = 0.0;
		i_IsNpcType[entity] = 0;
		BarracksEntityCreated(entity);
		SetEntitySpike(entity, false);
		StoreWeapon[entity] = -1;
		Building_Mounted[entity] = -1;
		EntitySpawnToDefaultSiccerino(entity);
		b_NpcIsTeamkiller[entity] = false;
		IberiaEntityCreated(entity);
		f_HealDelayParticle[entity] = 0.0;
		f_DelayAttackspeedPreivous[entity] = 1.0;
		f_DelayAttackspeedPanicAttack[entity] = -1.0;
		f_WidowsWineDebuffPlayerCooldown[entity] = 0.0;
		b_NoKnockbackFromSources[entity] = false;
		i_CurrentEquippedPerk[entity] = 0;
		i_CurrentEquippedPerkPreviously[entity] = 0;
		i_WandIdNumber[entity] = -1;
		i_IsAloneWeapon[entity] = false;
		i_SemiAutoWeapon[entity] = false;
		HasMechanic[entity] = false;
		FinalBuilder[entity] = false;
		GlassBuilder[entity] = false;
		f_FreeplayAlteredHealthOld_Barracks[entity] = 1.0;
		f_FreeplayAlteredDamageOld_Barracks[entity] = 1.0;
		WildingenBuilder[entity] = false;
		WildingenBuilder2[entity] = false;
		Armor_Charge[entity] = 0;
#endif
		b_IsATrigger[entity] = false;
		b_IsATriggerHurt[entity] = false;
		i_IsWandWeapon[entity] = false;
		i_IsWrench[entity] = false;
		b_CanSeeBuildingValues[entity] = false;
		i_IsSupportWeapon[entity] = false;
		LastHitRef[entity] = -1;
		f_MultiDamageTaken[entity] = 1.0;
		f_MultiDamageTaken_Flat[entity] = 1.0;
		f_MultiDamageDealt[entity] = 1.0;
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
		b_NoHealthbar[entity] = 0;
		
		//Normal entity render stuff, This should be set to these things on spawn, just to be sure.
		b_DoNotIgnoreDuringLagCompAlly[entity] = false;
		f_EntityRenderColour[entity][0] = 1.0;
		f_EntityRenderColour[entity][1] = 1.0;
		f_EntityRenderColour[entity][2] = 1.0;
		i_EntityRenderColourSave[entity][0] = 255;
		i_EntityRenderColourSave[entity][1] = 255;
		i_EntityRenderColourSave[entity][2] = 255;
		b_StickyIsSticking[entity] = false;
		h_ArrowInflictorRef[entity] = -1;
		i_ProjectileExtraFunction[entity] = INVALID_FUNCTION;
		h_BonusDmgToSpecialArrow[entity] = 1.0;
		b_ThisEntityIsAProjectileForUpdateContraints[entity] = false;
		b_EntityIsArrow[entity] = false;
		b_EntityIsWandProjectile[entity] = false;
		b_EntityIgnoredByShield[entity] = false;
		CClotBody npc = view_as<CClotBody>(entity);
		EntityFuncAttack[entity] = INVALID_FUNCTION;
		EntityFuncAttack2[entity] = INVALID_FUNCTION;
		EntityFuncAttack3[entity] = INVALID_FUNCTION;
		EntityFuncReload4[entity] = INVALID_FUNCTION;
		EntityFuncAttackInstant[entity] = INVALID_FUNCTION;
		b_Is_Player_Projectile_Through_Npc[entity] = false;
		b_IgnorePlayerCollisionNPC[entity] = false;
		b_IgnoreAllCollisionNPC[entity] = false;
		b_ForceCollisionWithProjectile[entity] = false;
		b_ProjectileCollideIgnoreWorld[entity] = false;
		i_IsABuilding[entity] = false;
		b_NpcIgnoresbuildings[entity] = false;
		i_InHurtZone[entity] = 0;
		h_NpcCollissionHookType[entity] = 0;
		h_NpcSolidHookType[entity] = 0;
		SetDefaultValuesToZeroNPC(entity);

		f_BannerDurationActive[entity] = 0.0;
		f_DuelStatus[entity] = 0.0;
		b_BuildingHasDied[entity] = true;
		b_is_a_brush[entity] = false;
		i_IsVehicle[entity] = 0;
		b_IsARespawnroomVisualiser[entity] = false;
		b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = false;
		b_IsAGib[entity] = false;
		b_ThisEntityIgnored[entity] = false;
		b_ThisEntityIgnored_NoTeam[entity] = false;
		b_ThisEntityIgnoredByOtherNpcsAggro[entity] = false;
		b_IgnoredByPlayerProjectiles[entity] = false;
		b_DoNotUnStuck[entity] = false;
		f_NoUnstuckVariousReasons[entity] = 0.0;
		b_NpcIsInvulnerable[entity] = false;
		b_NpcUnableToDie[entity] = false;
		i_NpcInternalId[entity] = 0;
		b_IsABow[entity] = false;
		b_IsAMedigun[entity] = false;
		b_IsAFlameThrower[entity] = false;
		b_HasBombImplanted[entity] = false;
		i_RaidGrantExtra[entity] = 0;
		i_IsABuilding[entity] = false;
		i_NervousImpairmentArrowAmount[entity] = 0;
		i_VoidArrowAmount[entity] = 0;
		i_ChaosArrowAmount[entity] = 0;
		i_WeaponArchetype[entity] = 0;
		i_WeaponForceClass[entity] = 0;
		b_ProjectileCollideWithPlayerOnly[entity] = false;
		b_EntityCantBeColoured[entity] = false;
		TeamNumber[entity] = -1;
		fl_Extra_MeleeArmor[entity] 		= 1.0;
		fl_Extra_RangedArmor[entity] 		= 1.0;
		fl_Extra_Speed[entity] 				= 1.0;
		fl_Extra_Damage[entity] 			= 1.0;
		f_AttackSpeedNpcIncrease[entity] 	= 1.0;
		fl_GibVulnerablity[entity] 			= 1.0;
#if defined ZR || defined RPG
		KillFeed_EntityCreated(entity);
#endif

#if defined ZR
		Saga_EntityCreated(entity);
		Mlynar_EntityCreated(entity);
		Board_EntityCreated(entity);

		Elemental_ClearDamage(entity);
		Dungeon_EntityCreated(entity);
#endif

#if defined RPG
		RPG_EntityCreated(entity, classname);
		TextStore_EntityCreated(entity);
#endif
		b_IsAProjectile[entity] = false; 	
		b_IsCustomProjectile[entity] = false;
		if(!StrContains(classname, "entity_revive_marker")
		  || !StrContains(classname, "tf_projectile_energy_ring")
		  || !StrContains(classname, "entity_medigun_shield")
		  || !StrContains(classname, "tf_projectile_energy_ball")
		  || !StrContains(classname, "item_powerup_rune")
		  || !StrContains(classname, "vgui_screen"))
		{
			SDKHook(entity, SDKHook_SpawnPost, Delete_instantly);
		}
		if(!StrContains(classname, "tf_objective_resource"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		else if(!StrContains(classname, "tf_flame_manager"))
		{
			SDKHook(entity, SDKHook_SpawnPost, MakeFlamesUseless);
		}
		else if(!StrContains(classname, "instanced_scripted_scene"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
			//stringpool_fix crash.
			SetEntProp(entity, Prop_Data, "m_bForcePurgeFixedupStrings", true);
		}
		else if(!StrContains(classname, "tf_player_manager"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
#if defined ZR || defined RPG
		else if(!StrContains(classname, "phys_bone_follower"))
		{
			//every prop_Dynamic that spawns these  can make upto 16 entities, holy fuck
			//make a func_brush and use it to detect collisions!
			RemoveEntity(entity);
		}
#endif
		else if(!StrContains(classname, "func_brush"))
		{
			b_is_a_brush[entity] = true;
		}
#if defined ZR || defined RPG
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
			b_IsAProjectile[entity] = true;
			
		//	ApplyExplosionDhook_Rocket(entity);
			//SDKHook_SpawnPost doesnt work
		}
#endif
		else if(!StrContains(classname, "tf_weapon_compound_bow"))
		{
			b_IsABow[entity] = true;
		}
		else if(!StrContains(classname, "tf_weapon_crossbow"))
		{
			b_IsABow[entity] = true;
		}
		else if(!StrContains(classname, "func_breakable"))
		{
			SDKHook(entity, SDKHook_OnTakeDamagePost, Func_Breakable_Post);
		}
		else if(!StrContains(classname, "prop_vehicle_driveable"))
		{
			i_IsVehicle[entity] = 1;
			//npc.bCantCollidieAlly = true;
			//b_IsAProjectile[entity] = true;
			//SDKUnhook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);  // ?????
		}
#if defined ZR || defined RPG
		else if(!StrContains(classname, "tf_projectile_syringe"))
		{
			//This can only be on red anyways.
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SetTeam(entity, TFTeam_Red);
			b_IsAProjectile[entity] = true;
		}
		else if(!StrContains(classname, "tf_projectile_flare"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			b_IsAProjectile[entity] = true;
		}
		else if(!StrContains(classname, "tf_projectile_healing_bolt"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, See_Projectile_Team_Player);
			//SDKHook_SpawnPost doesnt work
			b_IsAProjectile[entity] = true;
			b_ProjectileCollideWithPlayerOnly[entity] = true;
		}
		
		else if(!StrContains(classname, "tf_projectile_pipe_remote"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_SpawnPost, PipeApplyDamageCustom);
			ApplyExplosionDhook_Pipe(entity, true);
			//SDKHook_SpawnPost doesnt work
			b_IsAProjectile[entity] = true;
		}
		else if(!StrContains(classname, "tf_projectile_arrow"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			SDKHook(entity, SDKHook_Touch, ArrowTouchNonCombatEntity);
			b_IsAProjectile[entity] = true;
		}
#endif
		else if(!StrContains(classname, "prop_dynamic"))
		{
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "func_respawnroomvisualizer"))
		{
			b_IsARespawnroomVisualiser[entity] = true;
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
		}
		else if(!StrContains(classname, "prop_physics_multiplayer"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "prop_physics_override"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "trigger_teleport")) //npcs think they cant go past this sometimes, lol
		{
			b_IsATrigger[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
		else if(!StrContains(classname, "trigger_hurt")) //npcs think they cant go past this sometimes, lol
		{
			b_IsATrigger[entity] = true;
			b_IsATriggerHurt[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_StartTouch, SDKHook_TriggerHurt_StartTouch);
			SDKHook(entity, SDKHook_EndTouch, SDKHook_TriggerHurt_EndTouch);
		}
		else if(!StrContains(classname, "monster_resource")) //npcs think they cant go past this sometimes, lol
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		else if(!StrContains(classname, "water_lod_control")) //npcs think they cant go past this sometimes, lol
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		//not really a brush, but we'll treat it like one.
		else if(!StrContains(classname, "func_door_rotating"))
		{
			b_is_a_brush[entity] = true;
		}
		else if(!StrContains(classname, "func_door"))
		{
			b_is_a_brush[entity] = true;
		}
		else if(!StrContains(classname, "prop_physics"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
		}
#if defined ZR || defined RPG
		else if(!StrContains(classname, "tf_projectile_pipe"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			ApplyExplosionDhook_Pipe(entity, false);
			SDKHook(entity, SDKHook_SpawnPost, PipeApplyDamageCustom);
			b_IsAProjectile[entity] = true;
			
#if defined ZR
			SDKHook(entity, SDKHook_SpawnPost, Is_Pipebomb);
#endif

		}
		else if(!StrContains(classname, "tf_projectile_rocket"))
		{
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			SDKHook(entity, SDKHook_SpawnPost, ApplyExplosionDhook_Rocket);
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			Hook_DHook_UpdateTransmitState(entity);
			b_IsAProjectile[entity] = true;
			
		}
#endif
		else if(!StrContains(classname, "zr_projectile_base"))
		{
			b_IsCustomProjectile[entity] = true;
			SetEntityRenderMode(entity, RENDER_NORMAL); //Make it entirely invis.
			b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
			npc.bCantCollidie = true;
			npc.bCantCollidieAlly = true;
			SDKHook(entity, SDKHook_SpawnPost, ApplyLateLogic_ProjectileBase);
			SDKHook(entity, SDKHook_SpawnPost, Set_Projectile_Collision);
			Hook_DHook_UpdateTransmitState(entity);
			b_IsAProjectile[entity] = true;
			
		}
#if defined ZR || defined RPG
		else if (!StrContains(classname, "tf_weapon_handgun_scout_primary")) 
		{
			ScatterGun_Prevent_M2_OnEntityCreated(entity);
		}
#endif
		else if (!StrContains(classname, "tf_weapon_medigun")) 
		{
			b_IsAMedigun[entity] = true;
#if defined ZR || defined RPG
			Medigun_OnEntityCreated(entity);
#endif
		}
		else if(!StrContains(classname, "tf_weapon_flamethrower")) 
		{
			b_IsAFlameThrower[entity] = true;
		}
#if defined ZR
		else if (!StrContains(classname, "tf_weapon_particle_cannon")) 
		{
			OnManglerCreated(entity);
		}
#endif
		else if(!StrContains(classname, "obj_") && !StrEqual(classname, "obj_vehicle"))
		{
			b_BuildingHasDied[entity] = false;
			npc.bCantCollidieAlly = true;
			i_IsABuilding[entity] = true;
			b_NoKnockbackFromSources[entity] = true;
		}
		else if(!StrContains(classname, "point_worldtext"))
		{
			Hook_DHook_UpdateTransmitState(entity);
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		else if(!StrContains(classname, "info_particle_system"))
		{
			Hook_DHook_UpdateTransmitState(entity);
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
			b_EntityCantBeColoured[entity] = true;
 		}
		else if(!StrContains(classname, "info_target"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		else if(!StrContains(classname, "info_teleport_destination"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
		else if(!StrContains(classname, "env_beam"))
		{
			b_ThisEntityIgnored[entity] = true;
			b_ThisEntityIgnored_NoTeam[entity] = true;
		}
#if defined ZR
		else if(!StrContains(classname, "func_regenerate"))
		{
			SDKHook(entity, SDKHook_StartTouch, SDKHook_Regenerate_StartTouch);
			SDKHook(entity, SDKHook_Touch, SDKHook_Regenerate_Touch);
		}
#endif
	}
}

public void SDKHook_TriggerHurt_StartTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InHurtZone))
	{
		i_InHurtZone[target]++;
	}
}

public void SDKHook_TriggerHurt_EndTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(i_InHurtZone))
	{
		i_InHurtZone[target]--;
	}
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

void Set_Projectile_Collision(int entity)
{
	//needs to be delayed by frame, team setting in tf2 happens after its spawned.
	RequestFrame(Set_Projectile_CollisionFrame, EntRefToEntIndex(entity));
}

void Set_Projectile_CollisionFrame(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
		return;

	if(GetTeam(entity) != view_as<int>(TFTeam_Blue))
	{
		SetEntityCollisionGroup(entity, 27);
		
#if defined RPG
		int attacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(RPGCore_PlayerCanPVP(attacker, attacker))
		{
			//set team to blue while in pvp, so all interactions work just fine, but only do this while in PVP.
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		}
#endif
	}
}
public void Delete_instantly(int entity)
{
	RemoveEntity(entity);
}
public void MakeFlamesUseless(int entity)
{
	//This makes the flamethrower itself do nothing. we do our own logic.
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
}
public void Delete_FrameLater(int ref) //arck, they are client side...
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
}

void RemoveNpcThingsAgain(int entity)
{
#if defined ZR
	CleanAllAppliedEffects_BombImplanter(entity, false);
	//Dont have to check for if its an npc or not, really doesnt matter in this case, just be sure to delete it cus why not
	//incase this breaks, add a baseboss check
	CleanAllApplied_Aresenal(entity, true);
	b_NpcForcepowerupspawn[entity] = 0;	
	CleanAllApplied_Cryo(entity);
	EnemyResetUranium(entity);
#endif
	i_HexCustomDamageTypes[entity] = 0;
}

public void OnEntityDestroyed(int entity)
{
#if !defined NOG
	DHook_EntityDestoryed();
#endif
	
	if(entity > 0 && entity < MAXENTITIES)
	{
		EntityKilled_HitDetectionCooldown(entity);
		WeaponWeaponAdditionOnRemoved(entity);
		CurrentEntities--;

		if(entity > MaxClients)
		{
			MedigunCheckAntiCrash(entity);
			FlamethrowerAntiCrash(entity);
#if !defined RTS
			Attributes_EntityDestroyed(entity);
#endif
			i_ExplosiveProjectileHexArray[entity] = 0; //reset on destruction.
			
#if defined ZR
		//	WeaponSwtichToWarningPostDestroyed(entity);
			i_WandIdNumber[entity] = -1;
			SkyboxProps_OnEntityDestroyed(entity);
#endif
#if !defined NOG
			IsCustomTfGrenadeProjectile(entity, 0.0);
#endif
		}
		NPCStats_SetFuncsToZero(entity);
	}
}
void PreMedigunCheckAntiCrash(int client)
{
	int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(active != -1)
	{
		MedigunCheckAntiCrash(active);
	}
}
void MedigunCheckAntiCrash(int entity)
{
	//This is needed beacuse:
	/*
		If a client holds m1, and then their medigun changes or-
		 to any other weapon it will try to play the animation
		 onto the new weapon, if the player has a bad weapon
		 or an invalid weapon, or nothing...

		 CRASH!

		 This prevents the client from holding m1 when it despawns a medigun, hopefully it works!
	*/
	if(b_IsAMedigun[entity])
	{
		GetEntProp(entity, Prop_Send, "m_bHealing", 0);
		f_MedigunDelayAttackThink[entity] = 0.0;
		//owner netprop doesnt work sadly.
		int MedigunOwner = PrevOwnerMedigun[entity];
		if(IsValidClient(MedigunOwner))
		{
			f_PreventMedigunCrashMaybe[MedigunOwner] = GetGameTime() + 0.1;
		}
	}
}

void FlamethrowerAntiCrash(int entity)
{
	//This is needed beacuse:
	/*
		If a client holds m1 while the flamethrower is deleted, 
		this can cause the effect of the flamemanager not being deleted
		correctly, and causes a clientside flame particle that stays forever.
	*/

	if(!b_IsAFlameThrower[entity])
		return;

	int EntityLoop;
	while((EntityLoop=FindEntityByClassname(EntityLoop, "tf_flame_manager")) != -1)
	{
		if(IsValidEntity(EntityLoop))
		{
			int Owner = GetEntPropEnt(EntityLoop, Prop_Send, "m_hOwnerEntity");
			if(Owner == entity)
			{
				RemoveEntity(EntityLoop);
				return;
			}
		}
	}
}
#if defined ZR || defined RPG
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
#endif
#if defined RPG 
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client))
#endif
		{
			if(!b_AntiLateSpawn_Allow[client])
				continue;
#if defined ZR
			if(!b_HasBeenHereSinceStartOfWave[client])
				continue;
#endif
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
	if(BetWar_Mode())
		return;
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
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] == TEUTON_NONE)
		{
			//update clients
			Store_ApplyAttribs(client);
		}
	}
#endif
}
#endif

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
	int entity = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
}
*/

/*
//Looping function for above!
for(int entitycount; entitycount<i_MaxcountHomingMagicShot; entitycount++)
{
	int entity = EntRefToEntIndex(i_ObjectsHomingMagicShot[entitycount]);
}
*/

#if defined ZR || defined RPG
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(condition == TFCond_Cloaked)
	{
		TF2_RemoveCondition(client, TFCond_Cloaked);
	}
	else if(condition == TFCond_Stealthed)
	{
		int HealthRemaining = GetEntProp(client, Prop_Send, "m_iHealth");
		HealthRemaining -= 40;
		//Heals by 40.
		SetEntProp(client, Prop_Send, "m_iHealth", HealthRemaining);
		TF2_RemoveCondition(client, TFCond_Stealthed);
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
		SDKCall_SetSpeed(client);
	}
	else if (condition == TFCond_Slowed && IsPlayerAlive(client))
	{
		SDKCall_SetSpeed(client);
	}
#if defined ZR
	else if (condition == TFCond_Taunting && (BetWar_Mode() || f_PreventMovementClient[client] > GetGameTime()))
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
	}
#endif
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if(IsValidClient(client) && IsPlayerAlive(client)) //Need this, i think this has a chance to return -1 for some reason. probably disconnect.
	{
		switch(condition)
		{
			case TFCond_Zoomed:
			{
				ViewChange_Update(client);

				if(thirdperson[client])
				{
					SetVariantInt(1);
					AcceptEntityInput(client, "SetForcedTauntCam");
					SDKCall_SetSpeed(client);
				}
			}
			case TFCond_Slowed:
			{
				SDKCall_SetSpeed(client);
			}
			case TFCond_Taunting:
			{
				Viewchange_UpdateDelay(client);

				if(!b_TauntSpeedIncrease[client])
				{
					int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(weapon_holding != -1)
					{
						static char classname[64];
						GetEntityClassname(weapon_holding, classname, sizeof(classname));
						if(TF2_GetClassnameSlot(classname, weapon_holding) == TFWeaponSlot_Melee)
						{
							float attack_speed;
						
							attack_speed = 1.0 / Attributes_Get(weapon_holding, 6, 1.0);
							
							if(attack_speed > 5.0)
							{
								attack_speed *= 0.5; //Too fast! It makes animations barely play at all
							}
							Attributes_Set(client, 201, attack_speed);
						}
						else
						{	
							Attributes_Set(client, 201, 1.0);
						}
					}
				}
			}
		}
	}
}

stock bool InteractKey(int client, int weapon, bool Is_Reload_Button = false)
{
	if(weapon != -1) //Just allow. || GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")<GetGameTime())
	{
		static float vecEndOrigin[3];
		int entity = GetClientPointVisible(client, 100.0, _, _, vecEndOrigin); //So you can also correctly interact with players holding shit.
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
			if(Vehicle_Interact(client, weapon, entity))
				return true;
			
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if (GetTeam(entity) != TFTeam_Red)
				{
					if(Construction_Material_Interact(client, entity))
						return false;

					return false;
				}
				
				if(Object_Interact(client, weapon, entity))
					return true;

				//shouldnt invalidate clicking, makes battle hard.
				if(!PlayerIsInNpcBattle(client) && Store_Girogi_Interact(client, entity, buffer, Is_Reload_Button))
					return false;

				if (TeutonType[client] == TEUTON_WAITING)
					return false;

				if(Escape_Interact(client, entity))
					return true;
				//interacting with citizens shouldnt invalidate clicking, it makes battle hard.
				if(Is_Reload_Button && !PlayerIsInNpcBattle(client) && Citizen_Interact(client, entity))
					return false;

				if(Is_Reload_Button && BarrackBody_Interact(client, entity))
					return true;
				
			}
#endif
			
#if defined RPG
			if(Tinker_Interact(client, entity, weapon))
				return true;
				
			if(Actor_Interact(client, entity))
				return true;
			
			if(TextStore_Interact(client, entity, Is_Reload_Button))
				return true;
			
			if(Plots_Interact(client, entity, weapon))
				return true;
			
			if(Mining_Interact(client, entity, weapon))
				return true;
			
			if(Crafting_Interact(client, entity))
				return true;
			
			if(Dungeon_Interact(client, entity))
				return true;

			if(AllyNpcInteract(client, entity, weapon))
				return true;
#endif
		
		}
		else
		{

#if defined ZR
			if(GetEntityMoveType(client) == MOVETYPE_NONE && Vehicle_Interact(client, weapon, entity))
				return true;
#endif
			
#if defined RPG
			if(Fishing_Interact(client, weapon))
				return true;
			
			if(Mining_Interact(client, entity, weapon))
				return true;
			
			if(Garden_Interact(client, vecEndOrigin))
				return true;
#endif

		}
	}
	return false;
}
#endif	// ZR & RPG

#if defined _tf2items_included
public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int index, Handle &item)
{
#if defined RTS
	//if(!RTS_InSetup())
	//	return Plugin_Stop;
#else
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
#endif
	return Plugin_Continue;
}
#endif

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
			KickAt = CalcMaxPlayers();
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

stock void TF2_SetPlayerClass_ZR(int client, TFClassType classType, bool weapons=true, bool persistent=true)
{
	if(classType < TFClass_Scout || classType > TFClass_Engineer)
	{
		LogStackTrace("Invalid class %d", classType);
		classType = TFClass_Scout;
	}
	
	TF2_SetPlayerClass(client, classType, weapons, persistent);
}

#if defined ZR
void ReviveClientFromOrToEntity(int target, int client, int extralogic = 0, int medigun = 0)
{
	bool WasClientReviving = true;
	bool WasRevivingEntity = false;
	if(client > MaxClients)
	{
		WasClientReviving = false;
	}
	else
	{
		if(f_ClientReviveDelayMax[client] > GetGameTime())
		{
			return;
		}
		f_ClientReviveDelayMax[client] = GetGameTime() + 0.09;
	}
	if(Citizen_ThatIsDowned(target))
	{
		WasRevivingEntity = true;
	}
	float GameTime = GetGameTime();
	
	if(!WasRevivingEntity)
		SetEntityMoveType(target, MOVETYPE_NONE);

	if(WasClientReviving)
	{
		was_reviving[client] = true;
		f_DelayLookingAtHud[client] = GameTime + 0.5;
	}
	if(!WasRevivingEntity)
	{
		f_DelayLookingAtHud[target] = GameTime + 0.5;
		f_ClientBeingReviveDelay[target] = GameTime + 0.15;
	}

	if(WasClientReviving)
	{
		
		if(WasRevivingEntity)
		{
			Citizen npc = view_as<Citizen>(target);
			PrintCenterText(client, "%t", "Reviving", npc.m_iReviveTicks);
		}
		else
			PrintCenterText(client, "%t", "Reviving", dieingstate[target]);
	}

	if(!WasRevivingEntity)
		PrintCenterText(target, "%t", "You're Being Revived.", dieingstate[target]);
		
	if(WasClientReviving)
		was_reviving_this[client] = target;

	if(!WasRevivingEntity)
	{
		if(f_DisableDyingTimer[target] != FAR_FUTURE)
			f_DisableDyingTimer[target] = GameTime + 0.15;
	}

	int speed = 3;
	if(WasClientReviving && (i_CurrentEquippedPerk[client] & PERK_REGENE))
	{
		speed = 12;
	}
	else
	{
		if(WasClientReviving)
			speed = 6;
	}
		
	if(medigun > 0)
	{
		speed = RoundToNearest(float(speed) * 0.65);
	}
	if(HasSpecificBuff(client, "Dimensional Turbulence"))
	{
		speed *= 2;
	}

	if(WasClientReviving)
	{
		int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(activeWeapon))
		{
			speed = RoundToNearest(float(speed) * Attributes_Get(activeWeapon, Attrib_ReviveSpeedBonus, 1.0));
		}
	}
	Rogue_ReviveSpeed(speed);
	if(WasRevivingEntity)
	{
		if(Citizen_ReviveTicks(target, speed, client) <= 0)
		{
			float pos[3], ang[3];
			GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
			ang[0] = 0.0;
			TeleportEntity(target, pos, ang, NULL_VECTOR);
			//teleport em to me!
		}
		return;
	}
	dieingstate[target] -= speed;
	
	if(dieingstate[target] <= 0)
	{
		if(WasClientReviving)
		{
			AddHealthToUbersaw(client, 1, 0.065);
			HealPointToReinforce(client, 1, 0.065);
			i_Reviving_This_Client[client] = 0;
			f_Reviving_This_Client[client] = 0.0;
			Native_OnRevivingPlayer(client, target);
		}
		if(extralogic)
		{
			i_AmountDowned[target]--;
			b_BobsCuringHand_Revived[target] = -9999;
		}
		SetEntityMoveType(target, MOVETYPE_WALK);
		RequestFrame(Movetype_walk, EntRefToEntIndex(target));
		dieingstate[target] = 0;
		ClientSaveUber(target);
		ClientSaveRageMeterStatus(target);
		
		SetEntPropEnt(target, Prop_Send, "m_hObserverTarget", client);
		f_WasRecentlyRevivedViaNonWave[target] = GameTime + 1.0;
		DHook_RespawnPlayer(target);
		
		float pos[3], ang[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
		ang[2] = 0.0;
		SetEntProp(target, Prop_Send, "m_bDucked", true);
		SetEntityFlags(target, GetEntityFlags(target)|FL_DUCKING);
		CClotBody npc = view_as<CClotBody>(target);
		npc.m_bThisEntityIgnored = false;
		TeleportEntity(target, pos, ang, NULL_VECTOR);
		SetEntityCollisionGroup(target, 5);

		if(WasClientReviving)
			PrintCenterText(client, "");

		PrintCenterText(target, "");
		DoOverlay(target, "", 2);
		SetEntityHealth(target, 50);
		RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(target));
		Rogue_TriggerFunction(Artifact::FuncRevive, target);
		int entity, i;
		while(TF2U_GetWearable(target, entity, i))
		{
			if(entity == EntRefToEntIndex(Armor_Wearable[target]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;

			SetEntityRenderMode(entity, RENDER_NORMAL);
			SetEntityRenderColor(entity, 255, 255, 255, 255);
		}
		if(WasClientReviving && (i_CurrentEquippedPerk[client] & PERK_REGENE))
		{
			HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) * 0.2, 1.0, 1.0);
			HealEntityGlobal(client, target, float(SDKCall_GetMaxHealth(target)) * 0.2, 1.0, 1.0, HEAL_ABSOLUTE);
		}
		else
		{
			if(WasClientReviving)
				HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) * 0.1, 1.0, 1.0);
			if(extralogic)
			{
				HealEntityGlobal(client, target, float(SDKCall_GetMaxHealth(target)) * 1.0, 1.0, 1.0, HEAL_ABSOLUTE);
			}
			else
			{	
				HealEntityGlobal(client, target, float(SDKCall_GetMaxHealth(target)), 0.1, 1.0, HEAL_ABSOLUTE);
			}
		}
		
		SetEntityRenderMode(target, RENDER_NORMAL);
		SetEntityRenderColor(target, 255, 255, 255, 255);
		EmitSoundToAll("mvm/mvm_revive.wav", target, SNDCHAN_AUTO, 90, _, 1.0);
		MakePlayerGiveResponseVoice(target, 3); //Revived response!
		f_ClientBeingReviveDelay[target] = 0.0;
	//	if(b_KahmlLastWish[target])
		{
			HealEntityGlobal(client, target, float(SDKCall_GetMaxHealth(target)) * 0.1, 0.1, 1.0, HEAL_ABSOLUTE);
			GiveArmorViaPercentage(target, 0.1, 1.0, false);
			IncreaseEntityDamageTakenBy(target, 0.85, 5.0);
		}
		CreateTimer(0.25, ReviveDisplayMessageDelay, EntIndexToEntRef(target), TIMER_FLAG_NO_MAPCHANGE);
		CheckLastMannStanding(0);
	}
}

public Action ReviveDisplayMessageDelay(Handle timer, int ref)
{
	int target = EntRefToEntIndex(ref);
	if(IsValidClient(target))
	{
		int downsleft;
		downsleft = 2;
		downsleft -= i_AmountDowned[target];
		if(downsleft <= 0)
		{
			SetDefaultHudPosition(target, 255, 0, 0, 2.5);
			SetGlobalTransTarget(target);
			ShowSyncHudText(target,  SyncHud_Notifaction, "%t", "Last Down Warning");	
		}
		/*
		else if(b_KahmlLastWish[target])
		{
			SetDefaultHudPosition(target, 0, 0, 255, 1.5);
			SetGlobalTransTarget(target);
			ShowSyncHudText(target,  SyncHud_Notifaction, "%t", "Kahmlstein Courage");	
		}
		*/
	}
	return Plugin_Continue;
}
void ClientRevivalTickLogic(int client)
{
	if(!f_ClientBeingReviveDelay[client])
		return;
	
	if(f_ClientBeingReviveDelay[client] < GetGameTime())
	{
		f_ClientBeingReviveDelay[client] = 0.0;
		SetEntityMoveType(client, MOVETYPE_WALK);
		PrintCenterText(client, "");
	}
}
#endif	// ZR


void checkOS()
{
	char cmdline[256];
	GetCommandLine(cmdline, sizeof(cmdline));
	//Todo , this is bad but we dont even use this.
	if (StrContains(cmdline, "./srcds_linux ", false) != -1)
	{
		OperationSystem = OS_Linux;
	}
	else if (StrContains(cmdline, ".exe", false) != -1)
	{
		OperationSystem = OS_Windows;
	}
	else
	{
		OperationSystem = OS_Unknown;
	}

	if(OperationSystem == OS_Linux)
		PrintToServer("Hi linux!");
}


public void ArrowTouchNonCombatEntity(int entity, int other)
{
	//This fixes arrows not detecting/intereacting with some entities, in this case its our custom buildings.
	if(i_IsNpcType[other] != 1)
		return;

	if(!b_ThisWasAnNpc[other])
		return;

		
	float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
	int Weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
	int attacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	float chargerPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", chargerPos);
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(attacker == client)
			{
				switch(GetRandomInt(1,3))
				{
					case 1:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal.wav", attacker, SNDCHAN_STATIC, 70, _, 1.0);
					
					case 2:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal2.wav", attacker, SNDCHAN_STATIC, 70, _, 1.0);
					
					case 3:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal4.wav", attacker, SNDCHAN_STATIC, 70, _, 1.0);
				}	
			}
			else
			{

				switch(GetRandomInt(1,3))
				{
					case 1:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal.wav", other, SNDCHAN_STATIC, 70, _, 1.0);
					
					case 2:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal2.wav", other, SNDCHAN_STATIC, 70, _, 1.0);
					
					case 3:
						EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal4.wav", other, SNDCHAN_STATIC, 70, _, 1.0);
				}	
			}
		}
	}
	SDKHooks_TakeDamage(other, attacker, attacker, original_damage , DMG_BULLET, Weapon, NULL_VECTOR, chargerPos);
	RemoveEntity(entity);
}


void PlayerHasInteract(int client, char[] Buffer, int Buffersize)
{
	if(zr_interactforcereload.BoolValue) //Cvar is on
	{
		if(b_InteractWithReload[client]) //If this is enabled, then force T
		{
			Format(Buffer, Buffersize, "%t","Interact With T Spray");
		}
		else if(!b_InteractWithReload[client])
		{
			Format(Buffer, Buffersize, "%t","Interact With R");
		}
	}
	else
	{
		if(b_InteractWithReload[client]) //If this is enabled, then force T
		{
			Format(Buffer, Buffersize, "%t","Interact With R");
		}
		else if(!b_InteractWithReload[client])
		{
			Format(Buffer, Buffersize, "%t","Interact With T Spray");
		}
	}
	
}



int CalcMaxPlayers()
{
	int playercount = CvarMaxPlayerAlive.IntValue;
	if(playercount < 1)
		playercount = MAXPLAYERS - 1;
	/*
	if(OperationSystem == OS_Linux)
	{
		playercount -= 2; //linux is abit shite
	}
	*/

	return playercount;
}


//This is needed as MVM breaks friendly fire.
void TakeDamage_EnableMVM()
{
/*
#if defined ZR
	if(CheckInHud())
		return;

	if(mp_friendlyfire.IntValue == 0)
		return;
		
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
#endif
*/
}
void TakeDamage_DisableMVM()
{
/*
#if defined ZR
	if(CheckInHud())
		return;

	if(mp_friendlyfire.IntValue == 0)
		return;

	GameRules_SetProp("m_bPlayingMannVsMachine", false);
#endif
*/
}
