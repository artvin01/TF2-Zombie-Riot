#pragma semicolon 1
#pragma newdecls required

#define SSB_CHAIR_SCALE			"1.45"
#define SSB_CHAIR_HP			"50000"
#define SSB_CHAIR_SKIN			"1"

static float SSB_CHAIR_SPEED = 240.0;
static float SSBChair_RaidTime = 481.0;		//I recommend not changing this, 8:01 is synced up to the duration of the phase 1 theme. Mercs should NEVER take 8 minutes to beat phase 1 anyways, if they are then something is wrong.

static int Chair_Tier[2049] = { 0, ... };	//The current "tier" the raid is on. Starts at 0 and increments by 1 each time SSB's army is defeated.
static bool Chair_UsingAbility[2049] = { false, ... };	//Whether or not SSB is currently using an ability. Set to TRUE upon ability activation and FALSE once the ability is finished. Otherwise, he can use abilities while using other abilities, which can break animations. Very stinky!
Function Chair_QueuedSpell[2049];			//The spell which will be cast when SSB's cast animation plays out.
static float f_DamageSinceLastArmy[2049] = { 0.0, ... };
static float f_NextTeleport[2049] = { 0.0, ... };

static bool Chair_ChangeSequence[2049] = { false, ... };
static bool Chair_CanMove[2049] = { false, ... };
static bool useHeightOverride[2049] = { false, ... };
static bool b_SSBChairHasArmy[2049] = { false, ... };
static bool SSBChair_LaserHit[2049] = { false, ... };
static char Chair_Sequence[2049][255];
static char Chair_SpellEffect[2049][255];
static char Chair_SpellEffectExtra[2049][255];
static char Chair_SpellEffect_Point[2049][255];

static float SSBCHAIR_ARMY_INTERVAL = 0.25;		//Every X% of max health lost, SSB will summon his next army. When that army is defeated, SSB powers up and Chair_Tier increases by 1. Note that if Chair_Tier can reach a max value higher than 3, you'll need to increase the size of all arrays accordingly.

static float Teleport_Interval[4] = { 14.0, 13.0, 12.0, 10.0 };	//Every X seconds, SSB will teleport to a random enemy and face towards them. This stops him from being a total sitting duck. Keep in mind he still has a few abilities that teleport him automatically, so don't make these too low or he'll be cancer to fight against.

//DEATH WAVER: If at least X enemies and/or Y allies are within radius, SSB waves his hand, healing all allies within radius while damaging and knocking back all enemies.
//This is NOT a Spell Card, and is thus unaffected by the casting system. It DOES get stronger based on tier, though.
static int Waver_MinEnemies[4] = { 1, 1, 1, 1 };							//Minimum enemies within radius required to use.
static int Waver_MinAllies[4] = { 3, 3, 3, 3 };								//Minimum allies within radius required to use.
static float Waver_Radius_DMG[4] = { 140.0, 143.33, 146.66, 150.0 };		//Radius in which enemies will be damaged by this ability.
static float Waver_Radius_Healing[4] = { 400.0, 600.0, 800.0, 1200.0 };		//Radius in which allies will be healed by this ability.
static float Waver_Healing[4] = { 0.33, 0.5, 0.66, 0.75 };					//Percentage of max HP to heal allies for.
static float Waver_MinHealing[4] = { 10000.0, 15000.0, 20000.0, 40000.0 };		//Minimum healing provided by allies healed by this ability.
static float Waver_MaxHealing[4] = { 20000.0, 50000.0, 100000.0, 200000.0 };		//Maximum healing given to each ally healed by this ability.
static float Waver_DMG[4] = { 200.0, 350.0, 500.0, 650.0 };					//Damage dealt to enemies within radius.
static float Waver_Falloff_MultiHit[4] = { 0.66, 0.7, 0.75, 0.8 };			//Amount to multiply damage for each target hit.
static float Waver_Falloff_Radius[4] = { 0.66, 0.75, 0.8, 0.85 };			//Maximum damage falloff fbased on radius.
static float Waver_EntityMult[4] = { 5.0, 6.0, 7.0, 8.0 };					//Amount to multiply damage dealt to entities.
static float Waver_Knockback[4] = { 600.0, 900.0, 1200.0, 1500.0 };			//Knockback velocity applied to enemies who get hit.
static float Waver_Cooldown[4] = { 12.0, 11.0, 10.0, 9.0 };					//Cooldown between uses.

//NECROTIC BOMBARDMENT: SSB marks every enemy's location, and then strikes that location with a blast of necrotic energy after a short delay.
#define BOMBARDMENT_NAME	"Necrotic Bombardment"
static float Bombardment_Radius[4] = { 180.0, 220.0, 260.0, 300.0 };		//Blast radius.
static float Bombardment_Delay[4] = { 2.0, 1.9, 1.8, 1.66 };				//Time until the blast hits.
static float Bombardment_DMG[4]	= { 300.0, 600.0, 1200.0, 2400.0 };			//Damage dealt by the blast.
static float Bombardment_EntityMult[4] = { 5.0, 10.0, 15.0, 20.0 };			//Amount to multiply damage dealt to entities.
static float Bombardment_Falloff_MultiHit[4] = { 0.66, 0.7, 0.75, 0.8 };	//Amount to multiply damage per target hit.
static float Bombardment_Falloff_Radius[4] = { 0.5, 0.66, 0.75, 0.8 };		//Maximum distance-based falloff.
static float Bombardment_Cooldown[4] = { 12.0, 11.0, 10.0, 9.0 };			//Ability cooldown.
static float Bombardment_GlobalCD[4] = { 4.0, 3.0, 2.0, 1.0 };				//Global cooldown.

//RING OF HELL: SSB fires a cluster of explosive skulls in a ring pattern. These skulls transform into homing skulls after a short delay.
#define HELLRING_NAME		"Ring of Hell"
static int HellRing_NumSkulls[4] = { 12, 16, 20, 28 };						//The number of skulls fired.
static int HellRing_MaxTargets[4] = { 3, 4, 5, 8 };							//Maximum targets hit by a single skull explosion.
static float HellRing_Velocity[4] = { 265.0, 300.0, 350.0, 400.0 };			//Skull velocity.
static float HellRing_HomingDelay[4] = { 1.0, 0.75, 0.5, 0.25 };			//Delay after firing before skulls gain homing properties.
static float HellRing_HomingAngle[4] = { 60.0, 70.0, 80.0, 90.0 };			//Skulls' maximum homing angle.
static float HellRing_HomingPerSecond[4] = { 9.0, 9.5, 10.0, 10.5 };		//Number of times per second for skulls to readjust their velocity for the sake of homing in on their target.
static float HellRing_DMG[4] = { 120.0, 180.0, 320.0, 500.0 };				//Skull base damage.
static float HellRing_EntityMult[4] = { 2.0, 2.5, 3.0, 4.0 };				//Amount to multiply damage dealt by skulls to entities.
static float HellRing_Radius[4] = { 50.0, 50.0, 50.0, 50.0 };				//Skull explosion radius.
static float HellRing_Falloff_Radius[4] = { 0.66, 0.5, 0.33, 0.165 };		//Skull falloff, based on radius.
static float HellRing_Falloff_MultiHit[4] = { 0.66, 0.76, 0.86, 1.0 }; 		//Amount to multiply explosion damage for each target hit.
static float HellRing_Pitch[4] = { 5.0, 5.0, 5.0, 5.0 };					//Amount to tilt skull vertical angle on spawn, used mainly for VFX.
static float HellRing_Cooldown[4] = { 12.0, 11.0, 10.0, 9.0 };				//Ability cooldown.
static float HellRing_GlobalCD[4] = { 5.0, 4.0, 3.0, 2.0 };					//Global cooldown.

//SPATIAL DISPLACEMENT: SSB claps his hands and teleports directly above a random enemy. After a short delay, he will fall to the ground, creating a shockwave
//when he lands. This shockwave knocks enemies away.
#define TELEPORT_NAME		"Spatial Displacement"
static float Teleport_Height[4] = { 800.0, 800.0, 800.0, 800.0 };				//Maximum distance above the target SSB will teleport. If a valid height is not found, he'll choose a random nav spot instead of an enemy.
static float Teleport_Delay[4] = { 0.5, 0.45, 0.4, 0.33 };						//Delay after teleporting before SSB falls down. DO NOT make this longer than 0.5, the ability will break if you do. I know how to fix it, but unless it becomes totally necessary to make this longer than 0.85 I won't bother.
static float Teleport_FallSpeed[4] = { 800.0, 900.0, 1000.0, 1200.0 };			//Rate at which SSB falls to the ground when he begins falling.
static float Teleport_Radius[4] = { 150.0, 155.0, 160.0, 165.0 };				//Shockwave radius.
static float Teleport_DMG[4] = { 600.0, 900.0, 1200.0, 1800.0 };				//Base shockwave damage.
static float Teleport_Falloff_MultiHit[4] = { 0.5, 0.66, 0.75, 0.85 };			//Amount to multiply damage per target hit by the shockwave.
static float Teleport_Falloff_Radius[4] = { 0.25, 0.25, 0.33, 0.5 };			//Distance-based falloff.
static float Teleport_EntityMult[4] = { 4.0, 6.0, 8.0, 10.0 };					//Amount to multiply damage dealt to entities.
static float Teleport_Knockback[4] = { 600.0, 900.0, 1200.0, 1500.0 };			//Knockback velocity applied to enemies hit by the shockwave.
static float Teleport_FallbackRadius[4] = { 1200.0, 1600.0, 2000.0, 2400.0 };	//Radius in which a random nav area will be chosen for the teleport location instead of a random enemy, if none of the enemies can be successfully teleported above.
static float Teleport_Cooldown[4] = { 20.0, 16.0, 12.0, 8.0 };					//Ability cooldown.
static float Teleport_GlobalCD[4] = { 2.0, 1.5, 1.0, 0.0 };						//Global cooldown.

//NECROTIC CATASTROPHE: A more powerful variant of npc_ssb's Necrotic Cataclysm. This time, it's green! Wow!
//If SSB is being carried by his carrier skeleton, this attack can rotate, making it extra dangerous.
#define CATASTROPHE_NAME	"Necrotic Catastrophe"
static float Catastrophe_IntroSpeed[4] = { 1.0, 1.25, 1.25, 1.5 };			//Intro speed multiplier. Higher values make the intro animation play faster, which means the beam starts charging up sooner.
static float Catastrophe_Delay[4] = { 1.25, 1.15, 1.075, 1.0 };				//Time until the laser is fired after SSB begins charging.
static float Catastrophe_DMG[4] = { 10000.0, 20000.0, 40000.0, 80000.0 };	//Damage dealt by the laser.
static float Catastrophe_EntityMult[4] = { 10.0, 15.0, 17.5, 20.0 };		//Amount to multiply damage dealt by the laser to entities.
static float Catastrophe_Width[4] = { 475.0, 550.0, 600.0, 650.0 };			//Laser width, in hammer units.
//static float Catastrophe_YawSpeed[4];//TODO: = { X, X, X, X };				//Yaw speed applied to SSB's carrier skeleton while this ability is active, if he has a carrier.
static float Catastrophe_Cooldown[4] = { 30.0, 25.0, 20.0, 15.0 };			//Ability cooldown.
static float Catastrophe_GlobalCD[4] = { 5.0, 4.0, 3.0, 2.0 };				//Global cooldown.

#define ABSORPTION_NAME		"Soul Redistribution"
static float Absorption_IntroSpeed[4] = { 1.0, 1.1, 1.2, 1.35 };			//Intro speed multiplier. Higher values make the intro animation play faster, which means SSB will begin to absorb souls sooner.
static float Absorption_Duration[4] = { 12.0, 14.0, 16.0, 18.0 };			//Duration of the absorption phase.
static float Absorption_Speed[4] = { 90.0, 120.0, 150.0, 180.0 };			//SSB's movement speed during the absorption phase.
static float Absorption_DMG[4] = { 60.0, 70.0, 80.0, 100.0 };				//Damage dealt per 0.1s to enemies within the radius.
static float Absorption_EntityMult[4] = { 5.0, 7.5, 10.0, 12.5 };			//Amount to multiply damage dealt to entities.
static float Absorption_Radius[4] = { 600.0, 650.0, 700.0, 750.0 };			//Effect radius.
static float Absorption_TeleRadius[4] = { 400.0, 375.0, 350.0, 350.0 };		//Max distance from his victim to which SSB will teleport before using this ability. Lower = he teleports closer and then uses this.
static float Absorption_PullStrength[4] = { 400.0, 450.0, 500.0, 550.0 };			//Strength of the pull effect. Note that this is for point-blank, and is scaled downwards the further the target is.
static float Absorption_MinPullStrengthMultiplier[4] = { 0.2, 0.25, 0.3, 0.35 };	//The minimum percentage of the pull force to use, depending on how far the target is. It's recommended to be at least a *little* bit above 0.0, because otherwise the knockback from the damage will outweigh the pull if you're far enough away and actually *push* you, making escape easier.
static float Absorption_HealRatio[4] = { 1.0, 1.5, 2.0, 2.5 };						//Amount to heal SSB per point of damage dealt by this attack. Note that he only heals when hitting players, not NPCs.
static float Absorption_HealRatio_Allies[4] = { 1.0, 1.25, 1.5, 1.75 };				//Amount to heal all of SSB's allies per point of damage dealt by this attack. Note that he only heals when hitting players, not NPCs.
static float Absorption_Cooldown[4] = { 30.0, 25.0, 20.0, 15.0 };			//Ability cooldown.
static float Absorption_GlobalCD[4] = { 5.0, 4.0, 3.0, 2.0 };				//Global cooldown.

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_05.wav",
};

static char g_MeleeHitSounds[][] = {
	")weapons/grappling_hook_impact_flesh.wav",
};

static char g_MeleeAttackSounds[][] = {
	"player/cyoa_pda_fly_swoosh.wav",
};

static char g_MeleeMissSounds[][] = {
	"misc/blank.wav",
};

static char g_HeIsAwake[][] = {
	"physics/concrete/concrete_break2.wav",
	"physics/concrete/concrete_break3.wav",
};

static char g_GibSounds[][] = {
	"items/pumpkin_explode1.wav",
	"items/pumpkin_explode2.wav",
	"items/pumpkin_explode3.wav",
};

static char g_SSBGenericSpell_Sounds[][] = {
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_1.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_2.mp3"
};

static char g_SSBChair_ChairThudSounds[][] = {
	")physics/wood/wood_box_footstep1.wav",
	")physics/wood/wood_box_footstep2.wav",
	")physics/wood/wood_box_footstep3.wav",
	")physics/wood/wood_box_footstep4.wav"
};

static char g_SSBCatastrophe_Dialogue[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_3.mp3"
};

static char g_SSBCatastrophe_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}FUCK YOU!!!!!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}BOOM, BABY!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}DAMN!!!!!{default}"
};

#define SND_SNAP					"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_snap.mp3"
#define SND_CLAP					"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_clap.mp3"
#define SND_BOMBARDMENT_STRIKE		")misc/halloween/spell_spawn_boss.wav"
#define SND_BOMBARDMENT_MARKED		")misc/halloween/hwn_bomb_flash.wav"
#define SND_BOMBARDMENT_CHARGEUP	")items/powerup_pickup_crits.wav"
#define SND_HELL_CHARGEUP			")misc/halloween_eyeball/book_spawn.wav"
#define SND_HELL_SHOOT				")misc/halloween/spell_meteor_cast.wav"
#define SND_HELL_SHOOT_2			")misc/halloween_eyeball/book_exit.wav"
#define SND_BIG_SWING				")misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_WAVER_CAST				")items/powerup_pickup_strength"
#define SND_WAVER_BLAST				")weapons/bumper_car_spawn.wav"
#define SND_WAVER_BLAST_2			")weapons/cow_mangler_explode.wav"
#define SND_WAVER_KNOCKBACK			")weapons/bumper_car_hit_ball.wav"
#define SND_TELEPORT				")misc/halloween/merasmus_appear.wav"
#define SND_TELEPORT_SLAM_1			")misc/halloween/strongman_fast_impact_01.wav"
#define SND_TELEPORT_SLAM_2			")misc/halloween/spell_meteor_impact.wav"
#define SND_TELEPORT_CHARGEUP		")weapons/teleporter_receive.wav"
#define SND_FALLING_SCREAM			"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_falling.mp3"
#define SND_FALLING_LAND			"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_landed.mp3"
#define SND_CATASTROPHE_INTRO_BOOM	")misc/halloween/spell_lightning_ball_impact.wav"
#define SND_CATASTROPHE_INTRO_BOOM_2	")misc/halloween/merasmus_spell.wav"
#define SND_CATASTROPHE_CHARGEUP		"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_chargeup.mp3"
#define SND_CATASTROPHE_BIGBANG		"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_extra.mp3"
#define SND_ABSORPTION_LOOP			")zombie_riot/the_bone_zone/supreme_spookmaster_bones/absorption.wav"
#define SND_ABSORPTION_END			")misc/halloween/merasmus_disappear.wav"
#define SND_SPELL_MIRV				")misc/halloween/spell_mirv_cast.wav"

#define PARTICLE_BOMBARDMENT_SNAP		"merasmus_dazed_bits"
#define PARTICLE_BOMBARDMENT_SNAP_EXTRA	"hammer_bell_ring_shockwave2"
#define PARTICLE_HELL_HAND				"spell_fireball_small_red"
#define PARTICLE_HELL_SNAP				"spell_fireball_tendril_parent_red"
#define PARTICLE_HELL_TRAIL				"spell_fireball_small_red"
#define PARTICLE_HELL_TRAIL_HOMING		"spell_fireball_small_blue"
#define PARTICLE_HELL_BLAST				"spell_fireball_tendril_parent_red"
#define PARTICLE_HELL_BLAST_HOMING		"spell_fireball_tendril_parent_blue"
#define PARTICLE_BOMBARDMENT_HAND		"superrare_burning2"
#define PARTICLE_WAVER_HAND				"raygun_projectile_red_crit"
#define PARTICLE_WAVER_CAST				"drg_cow_explosioncore_charged"
#define PARTICLE_WAVER_BLAST			"mvm_soldier_shockwave"
#define PARTICLE_WAVER_HEAL_BLUE		"spell_cast_wheel_blue"
#define PARTICLE_WAVER_HEAL_RED			"spell_cast_wheel_red"
#define PARTICLE_TELEPORT				"merasmus_tp"
#define PARTICLE_TELEPORT_SLAM_1		"hammer_impact_button_dust2"
#define PARTICLE_TELEPORT_SLAM_2		"hammer_impact_button_dust"
#define PARTICLE_TELEPORT_SLAM_3		"hammer_bones_kickup"
#define PARTICLE_TELEPORT_HAND			"unusual_robot_time_warp2"
#define PARTICLE_CATASTROPHE_FINGER		"raygun_projectile_blue_crit"
#define PARTICLE_GREENZAP				"merasmus_zap"
#define PARTICLE_GREENSMOKE				"merasmus_ambient"
#define PARTICLE_WARP					"merasmus_tp_warp"
#define PARTICLE_ABSORPTION_ORB			"spell_lightningball_parent_blue"
#define PARTICLE_ABSORPTION_HAND		"superrare_burning2"
#define PARTICLE_GREENBLAST_SPARKLES	"duck_collect_green"
#define PARTICLE_HEALBURST_RED			"healthgained_red"
#define PARTICLE_HEALBURST_BLUE			"healthgained_blu"

static int NPCId;

public void SSBChair_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBGenericSpell_Sounds));   i++) { PrecacheSound(g_SSBGenericSpell_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBChair_ChairThudSounds));   i++) { PrecacheSound(g_SSBChair_ChairThudSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBCatastrophe_Dialogue));   i++) { PrecacheSound(g_SSBCatastrophe_Dialogue[i]);   }

	PrecacheSound(SND_SPAWN_ALERT);
	PrecacheSound(SND_SNAP);
	PrecacheSound(SND_CLAP);
	PrecacheSound(SND_BOMBARDMENT_STRIKE);
	PrecacheSound(SND_BOMBARDMENT_MARKED);
	PrecacheSound(SND_BOMBARDMENT_CHARGEUP);
	PrecacheSound(SND_HELL_CHARGEUP);
	PrecacheSound(SND_HELL_SHOOT);
	PrecacheSound(SND_HELL_SHOOT_2);
	PrecacheSound(SND_BIG_SWING);
	PrecacheSound(SND_WAVER_CAST);
	PrecacheSound(SND_WAVER_BLAST);
	PrecacheSound(SND_WAVER_BLAST_2);
	PrecacheSound(SND_WAVER_KNOCKBACK);
	PrecacheSound(SND_TELEPORT);
	PrecacheSound(SND_TELEPORT_SLAM_1);
	PrecacheSound(SND_TELEPORT_SLAM_2);
	PrecacheSound(SND_TELEPORT_CHARGEUP);
	PrecacheSound(SND_FALLING_SCREAM);
	PrecacheSound(SND_FALLING_LAND);
	PrecacheSound(SND_CATASTROPHE_INTRO_BOOM);
	PrecacheSound(SND_CATASTROPHE_INTRO_BOOM_2);
	PrecacheSound(SND_CATASTROPHE_CHARGEUP);
	PrecacheSound(SND_CATASTROPHE_BIGBANG);
	PrecacheSound(SND_ABSORPTION_LOOP);
	PrecacheSound(SND_SPELL_MIRV);
	PrecacheSound(SND_ABSORPTION_END);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supreme Spookmaster Bones, Magistrate of the Dead");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ssb_finale_phase1");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = Summon_SSBChair;
	NPCId = NPC_Add(data);
}

static any Summon_SSBChair(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return SSBChair(vecPos, vecAng, ally, data);
}

#define SSBCHAIR_MAX_ABILITIES 99999

ArrayList SSB_ChairSpells[2049];

bool SSBChair_AbilitySlotUsed[SSBCHAIR_MAX_ABILITIES] = {false, ...};

Function ChairSpell_Function[SSBCHAIR_MAX_ABILITIES] = { INVALID_FUNCTION, ... };	//The function to call when this ability is successfully activated.
Function ChairSpell_Filter[SSBCHAIR_MAX_ABILITIES] = { INVALID_FUNCTION, ... };		//The function to call when this ability is about to be activated, to check manually if it can be used or not. Must take one SSBChair and an entity index for the victim as parameters, and return a bool (true: activate, false: don't).

float ChairSpell_Cooldown[SSBCHAIR_MAX_ABILITIES] = { 0.0, ... };
float ChairSpell_NextUse[SSBCHAIR_MAX_ABILITIES] = { 0.0, ... };
float ChairSpell_GlobalCooldown[SSBCHAIR_MAX_ABILITIES] = { 0.0, ... };

int ChairSpell_Tier[SSBCHAIR_MAX_ABILITIES] = { 0, ... };

char ChairSpell_Name[SSBCHAIR_MAX_ABILITIES][255];

methodmap SSBChair_Spell __nullable__
{
	public SSBChair_Spell()
	{
		int index = 0;
		while (SSBChair_AbilitySlotUsed[index] && index < SSBCHAIR_MAX_ABILITIES - 1)
			index++;

		if (index >= SSBCHAIR_MAX_ABILITIES)
			LogError("ERROR: SSB (Finale Phase 1) SOMEHOW has more than %i spells...\nThis should never happen.", SSBCHAIR_MAX_ABILITIES);
		
		SSBChair_AbilitySlotUsed[index] = true;

		return view_as<SSBChair_Spell>(index);
	}

	public void Activate(SSBChair user, int target = -1)
	{
		Call_StartFunction(null, this.ActivationFunction);
		Call_PushCell(user);
		Call_PushCell(target);
		Call_Finish();

		float gt = GetGameTime(user.index);
		for (int i = 0; i < GetArraySize(SSB_ChairSpells[user.index]); i++)
		{
			SSBChair_Spell spell = view_as<SSBChair_Spell>(GetArrayCell(SSB_ChairSpells[user.index], i));

			if (spell.Index == this.Index)
				spell.NextUse = gt + this.Cooldown;
			else
			{
				if (spell.NextUse < gt)
					spell.NextUse = gt + this.GlobalCooldown;
				else
					spell.NextUse += this.GlobalCooldown;
			}
		}
	}

	public bool CheckCanUse(SSBChair user, int target = -1)
	{
		if (Chair_UsingAbility[user.index])
			return false;

		if (GetGameTime(user.index) < this.NextUse)
			return false;

		if (Chair_Tier[user.index] < this.Tier)
			return false;

		if (this.FilterFunction == INVALID_FUNCTION)
			return true;

		bool success;

		Call_StartFunction(null, this.FilterFunction);
		Call_PushCell(user);
		Call_PushCell(target);
		Call_Finish(success);

		return success;
	}

	public void SetName(char[] name) { strcopy(ChairSpell_Name[this.Index], 255, name); }
	public void GetName(char[] output, int size = 255) { strcopy(output, size, ChairSpell_Name[this.Index]); }

	public void Delete()
	{
		this.ActivationFunction = INVALID_FUNCTION;
		this.NextUse = 0.0;
		SSBChair_AbilitySlotUsed[this.Index] = false;
	}

	property int Index
	{ 
		public get() { return view_as<int>(this); }
	}

	property int Tier
	{
		public get() { return ChairSpell_Tier[this.Index]; }
		public set(int value) { ChairSpell_Tier[this.Index] = value; }
	}

	property Function ActivationFunction
	{
		public get() { return ChairSpell_Function[this.Index]; }
		public set(Function value) { ChairSpell_Function[this.Index] = value; }
	}

	property Function FilterFunction
	{
		public get() { return ChairSpell_Filter[this.Index]; }
		public set(Function value) { ChairSpell_Filter[this.Index] = value; }
	}

	property float Cooldown
	{
		public get () { return ChairSpell_Cooldown[this.Index]; }
		public set(float value) { ChairSpell_Cooldown[this.Index] = value; }
	}

	property float GlobalCooldown
	{
		public get () { return ChairSpell_GlobalCooldown[this.Index]; }
		public set(float value) { ChairSpell_GlobalCooldown[this.Index] = value; }
	}

	property float NextUse
	{
		public get () { return ChairSpell_NextUse[this.Index]; }
		public set(float value) { ChairSpell_NextUse[this.Index] = value; }
	}
}

public void DeathWaver_Pulse(SSBChair ssb, int target)
{
	float pos[3];
	ssb.WorldSpaceCenter(pos);
	ParticleEffectAt(pos, PARTICLE_WAVER_BLAST);

	EmitSoundToAll(SND_WAVER_BLAST, ssb.index, _, 120);
	EmitSoundToAll(SND_WAVER_BLAST_2, ssb.index, _, 120, _, _, 80);
	ssb.PlayGenericSpell();

	bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(Waver_DMG[Chair_Tier[ssb.index]], ssb.index, ssb.index, 0, pos, Waver_Radius_DMG[Chair_Tier[ssb.index]], Waver_Falloff_MultiHit[Chair_Tier[ssb.index]], Waver_Falloff_Radius[Chair_Tier[ssb.index]], isBlue, _, _, Waver_EntityMult[Chair_Tier[ssb.index]], DeathWaver_Knockback);

	float allyPos[3];
	for (int i = 1; i < MAXENTITIES; i++)
	{
		if (!IsValidEntity(i) || i_IsABuilding[i] || i == ssb.index)
			continue;
				
		if (!IsValidAlly(ssb.index, i))
			continue;

		GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", allyPos);
		if (GetVectorDistance(pos, allyPos) <= Waver_Radius_Healing[Chair_Tier[ssb.index]])
		{
			CClotBody ally = view_as<CClotBody>(i);

			if (ally.BoneZone_IsASkeleton() && !ally.BoneZone_GetBuffedState())
				ally.BoneZone_SetBuffedState(true);

			float health = float(GetEntProp(i, Prop_Data, "m_iHealth"));
			float maxhealth;

			if (IsValidClient(i) && dieingstate[i] == 0)
			{
				maxhealth = float(SDKCall_GetMaxHealth(i));
			}
			else if (!IsValidClient(i))
			{
				maxhealth = float(ReturnEntityMaxHealth(i));
			}

			if (maxhealth > 0.0 && health < maxhealth)
			{
				float heals = maxhealth * Waver_Healing[Chair_Tier[ssb.index]];
				if (heals < Waver_MinHealing[Chair_Tier[ssb.index]])
					heals = Waver_MinHealing[Chair_Tier[ssb.index]];
				if (heals > Waver_MaxHealing[Chair_Tier[ssb.index]])
					heals = Waver_MaxHealing[Chair_Tier[ssb.index]];

				health += heals;
				if (health > maxhealth)
					health = maxhealth;

				SetEntProp(i, Prop_Data, "m_iHealth", RoundToFloor(health));
			}

			ParticleEffectAt(allyPos, (GetTeam(i) != 2 ? PARTICLE_WAVER_HEAL_BLUE : PARTICLE_WAVER_HEAL_RED));
			EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], i, _, _, _, _, GetRandomInt(80, 120));
		}
	}
}

public void DeathWaver_Knockback(int attacker, int victim, float damage)
{
	if (b_NoKnockbackFromSources[victim] || b_NpcIsInvulnerable[victim])
		return;

	EmitSoundToAll(SND_WAVER_KNOCKBACK, victim, _, _, _, _, GetRandomInt(80, 100));
	Custom_Knockback(attacker, victim, Waver_Knockback[Chair_Tier[attacker]], true, true, true);
}

public void SSBChair_Bombardment(SSBChair ssb, int target)
{
	ssb.CastSpellWithAnimation("ACT_FINALE_CHAIR_SNAP", SSBChair_Bombardment_Activate, PARTICLE_BOMBARDMENT_HAND, PARTICLE_BOMBARDMENT_SNAP, PARTICLE_BOMBARDMENT_SNAP_EXTRA, "effect_hand_L", SND_BOMBARDMENT_CHARGEUP);
}

public void SSBChair_Bombardment_Activate(SSBChair ssb, int target)
{
	float pos[3];
	ssb.WorldSpaceCenter(pos);
	
	for (int i = 1; i < 2049; i++)
	{
		if (IsValidEnemy(ssb.index, i))
			SSBChair_Bombardment_Mark(ssb.index, i);
	}

	ssb.PlayGenericSpell();
}

public void SSBChair_Bombardment_Mark(int attacker, int victim)
{
	SSBChair ssb = view_as<SSBChair>(attacker);

	float pos[3];
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
	spawnRing_Vectors(pos, Bombardment_Radius[Chair_Tier[ssb.index]] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, Bombardment_Delay[Chair_Tier[ssb.index]], 6.0, 0.0, 0);
	spawnRing_Vectors(pos, Bombardment_Radius[Chair_Tier[ssb.index]] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, Bombardment_Delay[Chair_Tier[ssb.index]], 4.0, 0.0, 0, 0.0);

	int particle = ParticleEffectAt(pos, PARTICLE_SPAWNVFX_GREEN);
	EmitSoundToAll(SND_BOMBARDMENT_MARKED, particle, _, _, _, _, GetRandomInt(80, 110));

	DataPack pack = new DataPack();
	CreateDataTimer(Bombardment_Delay[Chair_Tier[ssb.index]], SSBChair_Bombardment_Hit, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, GetClientUserId(victim));
	WritePackFloat(pack, pos[0]);
	WritePackFloat(pack, pos[1]);
	WritePackFloat(pack, pos[2]);
}

public Action SSBChair_Bombardment_Hit(Handle timer, DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int target = GetClientOfUserId(ReadPackCell(pack));
	float pos[3], skyPos[3];
	for (int i = 0; i < 3; i++)
		pos[i] = ReadPackFloat(pack);

	if (!IsValidEntity(ent) || !IsValidEntity(target))
		return Plugin_Continue;

	if (!IsValidEnemy(ent, target, true, true))
		return Plugin_Continue;

	SSBChair ssb = view_as<SSBChair>(ent);

	skyPos = pos;
	skyPos[2] += 9999.0;

	int particle = ParticleEffectAt(pos, PARTICLE_GREENBLAST_SSB, 2.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 20.0);

	bool isBlue = GetEntProp(ent, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(Bombardment_DMG[Chair_Tier[ssb.index]], ent, ent, 0, pos, Bombardment_Radius[Chair_Tier[ssb.index]], Bombardment_Falloff_MultiHit[Chair_Tier[ssb.index]], Bombardment_Falloff_Radius[Chair_Tier[ssb.index]], isBlue, _, _, Bombardment_EntityMult[Chair_Tier[ssb.index]]);

	int pitch = GetRandomInt(80, 110);
	EmitSoundToAll(SND_BOMBARDMENT_STRIKE, particle, _, _, _, _, pitch);
	EmitSoundToAll(SND_BOMBARDMENT_STRIKE, particle, _, _, _, _, pitch);

	return Plugin_Continue;
}

public void SSBChair_RingOfHell(SSBChair ssb, int target)
{
	ssb.CastSpellWithAnimation("ACT_FINALE_CHAIR_SNAP", SSBChair_RingOfHell_Activate, PARTICLE_HELL_HAND, PARTICLE_HELL_SNAP, "", "effect_hand_L", SND_HELL_CHARGEUP);
}

public void SSBChair_RingOfHell_Activate(SSBChair ssb, int target)
{
	float pos[3], ang[3];
	ssb.GetAttachment("effect_hand_L", pos, ang);

	ang[0] = HellRing_Pitch[Chair_Tier[ssb.index]];

	float skullFloat = float(HellRing_NumSkulls[Chair_Tier[ssb.index]]);
	float amt = 360.0 / skullFloat;

	for (ang[1] = 0.0; ang[1] < 360.0; ang[1] += amt)
	{
		HellRing_ShootSkull(ssb, pos, ang, HellRing_Velocity[Chair_Tier[ssb.index]]);
	}

	ssb.PlayGenericSpell();
	EmitSoundToAll(SND_HELL_SHOOT, ssb.index, _, 120, _, _, GetRandomInt(80, 110));
	EmitSoundToAll(SND_HELL_SHOOT_2, ssb.index, _, 120, _, _, GetRandomInt(80, 110));
}

public MRESReturn HellRing_Collide(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

	ParticleEffectAt(position, b_IsHoming[entity] ? PARTICLE_HELL_BLAST_HOMING : PARTICLE_HELL_BLAST, 1.0);
	EmitSoundToAll(SND_FIREBALL_EXPLODE, entity);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(IsValidEntity(owner))
	{
		bool isBlue = GetEntProp(owner, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(HellRing_DMG[Chair_Tier[owner]], owner, entity, 0, position, HellRing_Radius[Chair_Tier[owner]], HellRing_Falloff_MultiHit[Chair_Tier[owner]],
		HellRing_Falloff_Radius[Chair_Tier[owner]], isBlue, HellRing_MaxTargets[Chair_Tier[owner]], false, HellRing_EntityMult[Chair_Tier[owner]]);
	}

	RemoveEntity(entity);
	return MRES_Supercede;
}

public void HellRing_ShootSkull(SSBChair ssb, float pos[3], float ang[3], float vel)
{
	int skull = SSBChair_CreateProjectile(ssb, MODEL_SKULL, pos, ang, vel, GetRandomFloat(0.8, 1.2), HellRing_Collide);
	if (IsValidEntity(skull))
	{
		b_IsHoming[skull] = false;
		i_SkullParticle[skull] = EntIndexToEntRef(SSB_AttachParticle(skull, PARTICLE_HELL_TRAIL, _, ""));
		CreateTimer(HellRing_HomingDelay[Chair_Tier[ssb.index]], HellRing_StartHoming, EntIndexToEntRef(skull), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action HellRing_StartHoming(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (IsValidEntity(owner))
	{
		int particle = EntRefToEntIndex(i_SkullParticle[ent]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);

		i_SkullParticle[ent] = EntIndexToEntRef(SSB_AttachParticle(ent, PARTICLE_HELL_TRAIL_HOMING, _, ""));

		EmitSoundToAll(SND_HOMING_ACTIVATE, ent, _, 120, _, _, GetRandomInt(80, 110));
		EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], ent, _, 120, _, 0.8, GetRandomInt(80, 110));

		float ang[3];
		GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
		Initiate_HomingProjectile(ent, owner, HellRing_HomingAngle[Chair_Tier[owner]], HellRing_HomingPerSecond[Chair_Tier[owner]], false, true, ang);
		b_IsHoming[ent] = true;
	}

	return Plugin_Continue;
}

public void SSBChair_Teleport(SSBChair ssb, int target)
{
	useHeightOverride[ssb.index] = false;
	ssb.CastSpellWithAnimation("ACT_FINALE_CHAIR_CLAP", SSBChair_Teleport_Activate, PARTICLE_TELEPORT_HAND, "", "", "effect_hand_L", SND_TELEPORT_CHARGEUP, "effect_hand_R");
}

void SSBChair_Teleport_Activate(SSBChair ssb, int target, float heightOverride = 0.0)
{
	ArrayList enemies = GetRandomlySortedEnemies(ssb);

	float height = Teleport_Height[Chair_Tier[ssb.index]];
	if (useHeightOverride[ssb.index])
		height = heightOverride;

	float endPos[3];
	bool passed = GetArraySize(enemies) > 0;	//First check: do we even have any enemies to teleport to? Should almost always pass during actual gameplay.
	if (passed)
	{
		//Second test: do we have at least one enemy who we can teleport above without getting stuck?
		for (int i = 0; i < GetArraySize(enemies); i++)
		{
			int vic = GetArrayCell(enemies, i);

			float vicPos[3];
			WorldSpaceCenter(vic, vicPos);

			bool success = SSBChair_Teleport_CheckSpaceAbovePoint(vicPos, height, endPos, ssb.index);

			if (success)
				break;
			else if (i == GetArraySize(enemies) - 1)
				passed = false;
		}

		//Both tests passed: teleport above the chosen enemy.
		if (passed)
		{
			ssb.Teleport(endPos, true);
		}
	}

	//None of the living enemies have a valid space above them, try to teleport above a random nearby nav area instead of a player.
	//If none of the chosen nav areas can be teleported above, just teleport directly to it and skip the shockwave portion of this ability.
	if (!passed)
	{
		float ssbPos[3];
		WorldSpaceCenter(ssb.index, ssbPos);
		ArrayList areas = GetAllNearbyAreas(ssbPos, Teleport_FallbackRadius[Chair_Tier[ssb.index]]);

		if (GetArraySize(areas) > 0)
		{
			ScrambleArray(areas);
			for (int i = 0; i < GetArraySize(areas); i++)
			{
				float randPos[3];
				CNavArea navi = GetArrayCell(areas, i);
				navi.GetCenter(randPos);

				bool success = SSBChair_Teleport_CheckSpaceAbovePoint(randPos, height, endPos, ssb.index);
				if (success)
				{
					passed = true;
					break;
				}
				else if (i == GetArraySize(areas) - 1)
				{
					ssb.Teleport(randPos, false);
				}
			}
		}

		if (passed)
		{
			ssb.Teleport(endPos, true);
		}

		delete areas;
	}

	delete enemies;
}

public bool SSBChair_Teleport_CheckSpaceAbovePoint(float startPos[3], float height, float endPos[3], int user)
{
	float ssbMaxs[3], ssbMins[3], ang[3], Direction[3];
	ssbMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
	ssbMins = view_as<float>( { -24.0, -24.0, 0.0 } );
	//NOTE: The ability will get weird if we decide to manually override his scale, but that won't happen in normal gameplay so that doesn't really matter.
	ScaleVector(ssbMaxs, StringToFloat(SSB_CHAIR_SCALE));
	ScaleVector(ssbMins, StringToFloat(SSB_CHAIR_SCALE));

	//First: Get the point directly above the given position.
	ang[0] = -90.0;
	GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, height);
	AddVectors(startPos, Direction, endPos);

	//Next: Check to see if there is an obstacle between the start and end points. If there is, that means we hit a ceiling.
	//Therefore: try to move down a bit. If we cannot move down without being below the start point,
	//that means the space above the given position is not a valid teleport spot, so return false.

	//TODO: TRACE_WORLDONLY DOES NOT DETECT THE SKYBOX SO IT BREAKS THE ABILITY! FIX WHEN ARTVIN RESPONDS!
	TR_TraceHullFilter(startPos, endPos, ssbMins, ssbMaxs, (GetTeam(user) == TFTeam_Red ? (MASK_NPCSOLID | MASK_PLAYERSOLID) : MASK_NPCSOLID), TraceRayHitWorldOnly, user);
	
	if (TR_DidHit())
	{
		float blocked[3];
		TR_GetEndPosition(blocked);

		float dist = GetVectorDistance(startPos, blocked);
		endPos[2] = blocked[2];

		if (dist < ssbMaxs[2] * 1.2)
			return false;

		endPos[2] -= ssbMaxs[2] * 1.15;
	}

	//Debug VFX:
	/*SpawnBeam_Vectors(startPos, endPos, 3.0, 255, 120, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, 1, 0.1);
	ParticleEffectAt(startPos, PARTICLE_FIREBALL_BLUE, 3.0);
	ParticleEffectAt(endPos, PARTICLE_FIREBALL_BLUE, 3.0);*/

	TR_TraceRayFilter(startPos, endPos, (GetTeam(user) == TFTeam_Red ? (MASK_NPCSOLID | MASK_PLAYERSOLID) : MASK_NPCSOLID), RayType_EndPoint, TraceRayHitWorldOnly, user);
	if (TR_DidHit())
		return false;

	//Finally: run one last hull check for the final teleport position to make sure SSB won't get stuck if he teleports there.
	//TR_TraceHullFilter(endPos, endPos, ssbMins, ssbMaxs, MASK_SHOT, TraceRayHitWorldOnly, user);
	if (IsSpaceOccupiedWorldOnly(endPos, ssbMins, ssbMaxs, user))
		return false;

	return true;
}

public void SSBChair_Teleport_SlamDelay(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	float endTime = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	SSBChair ssb = view_as<SSBChair>(user);

	if (GetGameTime(ssb.index) >= endTime)
	{
		RequestFrame(SSBChair_Teleport_Falling, EntIndexToEntRef(ssb.index));
		EmitSoundToAll(SND_BIG_SWING, ssb.index, _, 120);
		EmitSoundToAll(SND_FALLING_SCREAM, ssb.index, _, 120);
		EmitSoundToAll(SND_BIG_SWING, ssb.index, _, 120);
		EmitSoundToAll(SND_FALLING_SCREAM, ssb.index, _, 120);

		int iActivity = ssb.LookupActivity("ACT_FINALE_CHAIR_AIRBORNE");
		if (iActivity > 0)
			ssb.StartActivity(iActivity);

		float vel[3];
		vel[2] = -Teleport_FallSpeed[Chair_Tier[ssb.index]];
		ssb.ForceVelocity(vel);

		delete pack;
		return;
	}
	else
	{
		float vel[3];
		ssb.ForceVelocity(vel);
	}

	RequestFrame(SSBChair_Teleport_SlamDelay, pack);
}

ArrayList Teleport_Victims = null;

public void SSBChair_Teleport_Falling(int ref)
{
	int user = EntRefToEntIndex(ref);
	if (!IsValidEntity(user))
		return;

	SSBChair ssb = view_as<SSBChair>(user);

	if (ssb.IsOnGround())
	{
		//Since this ability has a built-in teleport, we don't want to let him teleport again immediately after using it:
		if (ssb.f_NextTeleport <= GetGameTime(ssb.index))
			ssb.f_NextTeleport = GetGameTime(ssb.index) + Teleport_Interval[Chair_Tier[ssb.index]];

		int iActivity = ssb.LookupActivity("ACT_FINALE_CHAIR_LANDING");
		if (iActivity > 0)
			ssb.StartActivity(iActivity);

		b_NoKnockbackFromSources[ssb.index] = false;

		float pos[3];
		GetEntPropVector(ssb.index, Prop_Send, "m_vecOrigin", pos);
		ParticleEffectAt(pos, PARTICLE_TELEPORT_SLAM_1);
		ParticleEffectAt(pos, PARTICLE_TELEPORT_SLAM_2);
		ParticleEffectAt(pos, PARTICLE_TELEPORT_SLAM_3);
		EmitSoundToAll(SND_TELEPORT_SLAM_1, ssb.index, _, 120, _, _, 80);
		EmitSoundToAll(SND_TELEPORT_SLAM_1, ssb.index, _, 120, _, _, 80);
		EmitSoundToAll(SND_TELEPORT_SLAM_2, ssb.index, _, 120, _, 0.8, 80);
		EmitSoundToAll(SND_TELEPORT_SLAM_2, ssb.index, _, 120, _, 0.8, 80);
		EmitSoundToAll(SND_FALLING_LAND, ssb.index, _, 120);
		EmitSoundToAll(SND_FALLING_LAND, ssb.index, _, 120);
		StopSound(ssb.index, SNDCHAN_AUTO, SND_FALLING_SCREAM);
		StopSound(ssb.index, SNDCHAN_AUTO, SND_FALLING_SCREAM);

		bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Teleport_DMG[Chair_Tier[ssb.index]], ssb.index, ssb.index, 0, pos, Teleport_Radius[Chair_Tier[ssb.index]], 
		Teleport_Falloff_MultiHit[Chair_Tier[ssb.index]], Teleport_Falloff_Radius[Chair_Tier[ssb.index]], isBlue, _, _, 
		Teleport_EntityMult[Chair_Tier[ssb.index]], SSBChair_Teleport_DoKnockback);

		return;
	}
	else
	{
		if (Teleport_Victims == null)
			Teleport_Victims = CreateArray(255);

		float pos[3], endPos[3], ssbMaxs[3], ssbMins[3];

		ssbMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		ssbMins = view_as<float>( { -24.0, -24.0, 0.0 } );
		//NOTE: The ability will get weird if we decide to manually override his scale, but that won't happen in normal gameplay so that doesn't really matter.
		ScaleVector(ssbMaxs, StringToFloat(SSB_CHAIR_SCALE) + 0.165);
		ScaleVector(ssbMins, StringToFloat(SSB_CHAIR_SCALE) + 0.165);

		GetEntPropVector(ssb.index, Prop_Send, "m_vecOrigin", pos);
		endPos = pos;
		endPos[2] -= 10.0;

		TR_TraceHullFilter(pos, endPos, ssbMins, ssbMaxs, MASK_SHOT, SSBChair_Teleport_InstaKillFilter, ssb.index);

		if (GetArraySize(Teleport_Victims) > 0)
		{
			for (int i = 0; i < GetArraySize(Teleport_Victims); i++)
			{
				int vic = GetArrayCell(Teleport_Victims, i);
				SDKHooks_TakeDamage(vic, ssb.index, ssb.index, 999999.0, DMG_TRUEDAMAGE, _, _, _, false);
			}
		}

		delete Teleport_Victims;
	}

	RequestFrame(SSBChair_Teleport_Falling, ref);
}

public bool SSBChair_Teleport_InstaKillFilter(int entity, int mask, int user)
{
	if (IsValidEnemy(user, entity))
	{
		PushArrayCell(Teleport_Victims, entity);
	}

	return false;
}

public void SSBChair_Teleport_DoKnockback(int attacker, int victim, float damage)
{
	if (b_NoKnockbackFromSources[victim] || b_NpcIsInvulnerable[victim])
		return;

	Custom_Knockback(attacker, victim, Teleport_Knockback[Chair_Tier[attacker]], true, true, true);
}

public ArrayList GetRandomlySortedEnemies(CClotBody user)
{
	ArrayList list = new ArrayList(255);

	for (int i = 1; i < MAXENTITIES; i++)
	{
		if (IsValidEnemy(user.index, i))
			PushArrayCell(list, i);
	}

	ScrambleArray(list);

	return list;
}

public void ScrambleArray(ArrayList list)
{
	if (GetArraySize(list) > 0)
	{
		for(int i = 0; i < GetArraySize(list) - 1; i++)
		{
			int me = GetArrayCell(list, i);
			int them = GetRandomInt(i + 1, GetArraySize(list) - 1);
			SetArrayCell(list, i, GetArrayCell(list, them));
			SetArrayCell(list, them, me);
		}
	}
}

public bool SSBChair_CatastropheFilter(SSBChair ssb, int target)
{
	return ssb.TeleportNearEnemy(1600.0, 100.0, true, true, false, 100.0);
}

public void SSBChair_Catastrophe(SSBChair ssb, int target)
{
	//REMINDER FOR FUTURE ME: we can use CastSpellWithAnimation for spells like this even if we don't call animevent 1003 in the sequence
	ssb.CastSpellWithAnimation("ACT_FINALE_CHAIR_CATASTROPHE_INTRO", SSBChair_Catastrophe_AttachFingerParticle, "", PARTICLE_GREENBLAST_SSB, "", "effect_hand_R", "");
	ssb.SetPlaybackRate(Catastrophe_IntroSpeed[Chair_Tier[ssb.index]]);
}

void SSBChair_Catastrophe_AttachFingerParticle(SSBChair ssb, int target)
{
	float pos[3], trash[3];
	ssb.GetAttachment("finger_R", pos, trash);
	ssb.m_iWearable5 = ParticleEffectAt_Parent(pos, PARTICLE_CATASTROPHE_FINGER, ssb.index, "finger_R");
	EmitSoundToAll(SND_CATASTROPHE_INTRO_BOOM, ssb.index, _, 120, _, _, 60);
	EmitSoundToAll(SND_CATASTROPHE_INTRO_BOOM_2, ssb.index, _, 120, _, _, 80);

	Catastrophe_ChargeUp(ssb);
}

void Catastrophe_ChargeUp(SSBChair ssb)
{
	ssb.SetPlaybackRate(1.0);

	int activity = ssb.LookupActivity("ACT_FINALE_CHAIR_CATASTROPHE_CHARGEUP");
	if (activity)
		ssb.StartActivity(activity);

	ssb.PlayCatastropheChargeUp();

	float fireTime = GetGameTime(ssb.index) + Catastrophe_Delay[Chair_Tier[ssb.index]] + 0.75;

	DataPack pack2 = new DataPack();
	RequestFrame(Catastrophe_ChargeVFX, pack2);
	WritePackCell(pack2, EntIndexToEntRef(ssb.index));
	WritePackCell(pack2, Chair_Tier[ssb.index]);
	WritePackFloat(pack2, fireTime);
	WritePackFloat(pack2, GetGameTime(ssb.index));
	WritePackFloat(pack2, 0.0);
	WritePackFloat(pack2, 0.0);
}

public void Catastrophe_ChargeVFX(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float end = ReadPackFloat(pack);
	float start = ReadPackFloat(pack);
	float spin = ReadPackFloat(pack);
	float next = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(user))
		return;

	float gt = GetGameTime(user);
	if (gt >= end)
	{
		Catastrophe_Fire(view_as<SSBChair>(user), phase);
		return;
	}

	if (gt >= next)
	{
		float remaining = end - GetGameTime(user);
		float total = end - start;
		float ratio = remaining / total;

		//RaidModeScaling = (SSB_RaidPower[phase] * 100000.0) * (1.0 - ratio);

		int alpha = 255 - RoundToCeil(255.0 * ratio);
		
		float pos[3], ang[3], Direction[3];
		//WorldSpaceCenter(user, pos);
		view_as<SSBChair>(user).GetAttachment("finger_R", pos, ang);
		GetEntPropVector(user, Prop_Data, "m_angRotation", ang);
		ang[0] = 0.0;
		ang[2] = 0.0;

		//GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
		//ScaleVector(Direction, 90.0);
		//AddVectors(pos, Direction, pos);

		for (float i = 0.0; i < 360.0; i += 45.0)
		{
			float spawnAng[3], startPos[3], endPos[3];
			spawnAng[0] = i + spin;
			spawnAng[1] = ang[1] + 90.0;
			spawnAng[2] = ang[2];

			GetAngleVectors(spawnAng, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, Catastrophe_Width[phase] * 0.5);
			AddVectors(pos, Direction, startPos);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, 9999.0);
			AddVectors(startPos, Direction, endPos);

			SpawnBeam_Vectors(pos, startPos, 0.1, 0, 255, 60, alpha, PrecacheModel("materials/sprites/laserbeam.vmt"), 2.0, 2.0, _, 0.0);
			SpawnBeam_Vectors(startPos, endPos, 0.1, 0, 255, 60, alpha, PrecacheModel("materials/sprites/laserbeam.vmt"), 2.0, 2.0, _, 0.0);
		}

		next = gt + 0.0;
	}

	pack = new DataPack();
	RequestFrame(Catastrophe_ChargeVFX, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, end);
	WritePackFloat(pack, start);
	WritePackFloat(pack, spin + 16.0);
	WritePackFloat(pack, next);
}

public void Catastrophe_Fire(SSBChair ssb, int phase)
{
	int particle = ssb.m_iWearable5;
	if (IsValidEntity(particle))
		RemoveEntity(particle);
		
	ssb.PlayCatastropheFire();

	float ang[3], pos[3], hullMin[3], hullMax[3], testAng[3], shootPos[3], Direction[3];
	ssb.GetAttachment("finger_R", pos, ang);
	GetEntPropVector(ssb.index, Prop_Data, "m_angRotation", ang);
	ang[0] = 0.0;
	ang[2] = 0.0;
	///WorldSpaceCenter(ssb.index, pos);
	testAng[1] = ang[1];

	///GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
	///ScaleVector(Direction, 90.0);
	///AddVectors(pos, Direction, pos);

	hullMin[0] = -Catastrophe_Width[phase] * 0.475;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	GetPointFromAngles(pos, testAng, 9999.0, shootPos, Priest_IgnoreAll, MASK_SHOT);

	TR_TraceHullFilter(pos, shootPos, hullMin, hullMax, 1073741824, SSBChair_LaserTrace, ssb.index);
			
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (SSBChair_LaserHit[victim])
		{
			SSBChair_LaserHit[victim] = false;
					
			if (IsValidEnemy(ssb.index, victim))
			{
				float damage = Catastrophe_DMG[phase];
					
				if (ShouldNpcDealBonusDamage(victim))
				{
					damage *= Catastrophe_EntityMult[phase];
				}
						
				float vicLoc[3];
				WorldSpaceCenter(victim, vicLoc);
				SDKHooks_TakeDamage(victim, ssb.index, ssb.index, damage, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, _, NULL_VECTOR, vicLoc);
			}
		}
	}

	for (float i = 0.0; i < 360.0; i += 22.5)
	{
		float spawnAng[3], startPos[3], endPos[3];
		spawnAng[0] = i;
		spawnAng[1] = ang[1] + 90.0;
		spawnAng[2] = ang[2];

		GetAngleVectors(spawnAng, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Catastrophe_Width[phase] * 0.5);
		AddVectors(pos, Direction, startPos);

		GetAngleVectors(testAng, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, 9999.0);
		AddVectors(startPos, Direction, endPos);

		SpawnBeam_Vectors(startPos, endPos, 0.33, 0, 255, 60, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 66.0, 66.0, _, 0.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 0, 255, 60, 255, PrecacheModel("materials/sprites/glow02.vmt"), 66.0, 66.0, _, 0.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 0, 255, 60, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 33.0, 33.0, _, 10.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 0, 255, 60, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 11.0, 11.0, _, 20.0);
	}

	SSB_BigVFX(true, _, _, 2.0, false);

	int activity = ssb.LookupActivity("ACT_FINALE_CHAIR_CATASTROPHE_FIRE");
	if (activity)
		ssb.StartActivity(activity);
}

public bool SSBChair_LaserTrace(int entity, int contentsMask, int user)
{
	if (IsEntityAlive(entity) && entity != user)
		SSBChair_LaserHit[entity] = true;
	
	return false;
}

public bool SSBChair_AbsorptionFilter(SSBChair ssb, int target)
{
	return ssb.TeleportNearEnemy(Absorption_TeleRadius[Chair_Tier[ssb.index]], 100.0, true, true, true, 0.0);
}

public void SSBChair_Absorption(SSBChair ssb, int target)
{
	ssb.SetPlaybackRate(Absorption_IntroSpeed[Chair_Tier[ssb.index]]);
	ssb.CastSpellWithAnimation("ACT_FINALE_CHAIR_ABSORPTION_INTRO", SSBChair_Absorption_AttachParticles, "", PARTICLE_GREENBLAST_SPARKLES, PARTICLE_GREENBLAST_SPARKLES, "effect_hand_R", "", "effect_hand_L");
}

public void SSBChair_Absorption_AttachParticles(SSBChair ssb, int target)
{
	float pos[3], trash[3];
	ssb.GetAttachment("effect_hand_R", pos, trash);
	ssb.m_iWearable5 = ParticleEffectAt_Parent(pos, PARTICLE_ABSORPTION_HAND, ssb.index, "effect_hand_R");
	ssb.GetAttachment("effect_hand_L", pos, trash);
	ssb.m_iWearable6 = ParticleEffectAt_Parent(pos, PARTICLE_ABSORPTION_HAND, ssb.index, "effect_hand_L");

	EmitSoundToAll(SND_SPELL_MIRV, ssb.index, _, 120, _, _, 80);
}

void Absorption_BeginAbsorbing(SSBChair ssb)
{
	float vortexPos[3], handPos[3], trash[3];
	ssb.WorldSpaceCenter(vortexPos);
	vortexPos[2] += 320.0;

	int vortex = ParticleEffectAt(vortexPos, PARTICLE_ABSORPTION_ORB, Absorption_Duration[Chair_Tier[ssb.index]]);
	SetParent(ssb.index, vortex);

	ssb.GetAttachment("effect_hand_R", handPos, trash);
	SpawnParticle_ControlPoints(handPos, vortexPos, PARTICLE_GREENZAP, 2.0);
	ssb.GetAttachment("effect_hand_L", handPos, trash);
	SpawnParticle_ControlPoints(handPos, vortexPos, PARTICLE_GREENZAP, 2.0);

	EmitSoundToAll(SND_ABSORPTION_LOOP, ssb.index, _, 120, _, _, GetRandomInt(60, 100));
	EmitSoundToAll(SND_ABSORPTION_LOOP, ssb.index, _, 120, _, _, GetRandomInt(60, 100));
	EmitSoundToAll(SND_CATASTROPHE_INTRO_BOOM, ssb.index, _, 120, _, _, 60);
	EmitSoundToAll(SND_CATASTROPHE_INTRO_BOOM_2, ssb.index, _, 120, _, _, 80);

	ssb.StartPathing();
	ssb.b_CanMove = true;
	ssb.m_flSpeed = Absorption_Speed[Chair_Tier[ssb.index]];

	DataPack pack = new DataPack();
	RequestFrame(Absorption_ActivePhase, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, EntIndexToEntRef(vortex));
	WritePackFloat(pack, GetGameTime(ssb.index) + Absorption_Duration[Chair_Tier[ssb.index]]);
	WritePackCell(pack, Chair_Tier[ssb.index]);
	WritePackFloat(pack, GetGameTime(ssb.index) + 0.1);
}

int Absorption_Hits = 0;
void Absorption_ActivePhase(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int vortex = EntRefToEntIndex(ReadPackCell(pack));
	float endTime = ReadPackFloat(pack);
	int tier = ReadPackCell(pack);
	float nextHit = ReadPackFloat(pack);
	delete pack;

	if (!IsValidEntity(user))
	{
		if (IsValidEntity(vortex))
			RemoveEntity(vortex);
		return;
	}

	SSBChair ssb = view_as<SSBChair>(user);
	float gt = GetGameTime(user);
	if (gt >= endTime)
	{
		if (IsValidEntity(vortex))
			RemoveEntity(vortex);

		Chair_ChangeSequence[ssb.index] = true;
		Chair_Sequence[ssb.index] = "ACT_FINALE_CHAIR_ABSORPTION_OUTRO";
		StopSound(user, SNDCHAN_AUTO, SND_ABSORPTION_LOOP);
		StopSound(user, SNDCHAN_AUTO, SND_ABSORPTION_LOOP);
		EmitSoundToAll(SND_ABSORPTION_END, user, _, _, _, _, 80);
		EmitSoundToAll(SND_BIG_SWING, user, _, _, _, _, 80);
		ssb.StopPathing();
		ssb.b_CanMove = false;

		int particle = ssb.m_iWearable5;
		if (IsValidEntity(particle))
			RemoveEntity(particle);
		particle = ssb.m_iWearable6;
		if (IsValidEntity(particle))
			RemoveEntity(particle); 
		
		return;
	}

	if (gt >= nextHit)
	{
		float vortexPos[3], handPos[3], trash[3], userPos[3];

		ssb.GetAbsOrigin(userPos);
		ssb.WorldSpaceCenter(vortexPos);
		vortexPos[2] += 320.0;

		ssb.GetAttachment("effect_hand_R", handPos, trash);
		SpawnBeam_Vectors(handPos, vortexPos, 0.1, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 10.0);
		ssb.GetAttachment("effect_hand_L", handPos, trash);
		SpawnBeam_Vectors(handPos, vortexPos, 0.1, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 10.0);

		spawnRing_Vectors(userPos, Absorption_Radius[tier] * 2.15, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, 0.1, 24.0, 0.0, 1);

		bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Absorption_Hits = 0;
		Explode_Logic_Custom(Absorption_DMG[tier], ssb.index, ssb.index, 0, userPos, Absorption_Radius[tier], 1.0, 1.0, isBlue, 9999, _, Absorption_EntityMult[tier], Absorption_OnHit);
		if (Absorption_Hits > 0)
		{
			int team = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum");
			TE_SetupParticleEffect((team == 2 ? PARTICLE_HEALBURST_RED : PARTICLE_HEALBURST_BLUE), PATTACH_ABSORIGIN_FOLLOW, ssb.index);
			TE_WriteNum("m_bControlPoint1", ssb.index);	
			TE_SendToAll();
		}

		nextHit = gt + 0.1;
	}

	pack = new DataPack();
	RequestFrame(Absorption_ActivePhase, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, EntIndexToEntRef(vortex));
	WritePackFloat(pack, endTime);
	WritePackCell(pack, tier);
	WritePackFloat(pack, nextHit);
}

public void Absorption_OnHit(int attacker, int victim, float damage, int weapon)
{
	Absorption_Hits++;
	int healing = RoundToCeil(damage * Absorption_HealRatio[Chair_Tier[attacker]] * (victim > MaxClients ? 0.35 : 1.0));
	int allyHealing = RoundToCeil(damage * Absorption_HealRatio_Allies[Chair_Tier[attacker]] * (victim > MaxClients ? 0.35 : 1.0));
	if (healing > 0 && victim > 0)
		SSBChair_HealEntity(attacker, healing, false);

	if (allyHealing > 0 && victim > 0)
	{
		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidEntity(i) || i_IsABuilding[i] || i == attacker)
				continue;
					
			if (!IsValidAlly(attacker, i))
				continue;

			SSBChair_HealEntity(i, allyHealing, false);
		}
	}

	float userPos[3], vicPos[3], portalPos[3];
	WorldSpaceCenter(attacker, userPos);
	WorldSpaceCenter(victim, vicPos);
	portalPos = userPos;
	portalPos[2] += 320.0;
	SpawnBeam_Vectors(portalPos, vicPos, 0.1, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 10.0);

	float multiplier = 1.0 - (GetVectorDistance(userPos, vicPos) / Absorption_Radius[Chair_Tier[attacker]]);
	if (multiplier < Absorption_MinPullStrengthMultiplier[Chair_Tier[attacker]])
		multiplier = Absorption_MinPullStrengthMultiplier[Chair_Tier[attacker]];

	float pullStrength = Absorption_PullStrength[Chair_Tier[attacker]] * multiplier;

	static float angles[3];
	GetVectorAnglesTwoPoints(userPos, vicPos, angles);

	if (GetEntityFlags(victim) & FL_ONGROUND)
		angles[0] = 0.0;

	float velocity[3], currentVelocity[3];
	GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelocity);
	GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(velocity, -pullStrength);
																
	if (GetEntityFlags(victim) & FL_ONGROUND)
		velocity[2] = fmax(25.0, velocity[2]);

	for (int i = 0; i < 3; i++)
		velocity[i] += currentVelocity[i];
												
	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);   
}

void SSBChair_HealEntity(int target, int amount, bool particle = true)
{
	int hp = GetEntProp(target, Prop_Data, "m_iHealth");

	//This should never happen, but just to be safe...
	if (hp <= 0)
		return;

	int maxHP = ReturnEntityMaxHealth(target);

	hp += amount;
	if (hp > maxHP)
		hp = maxHP;

	SetEntProp(target, Prop_Data, "m_iHealth", hp);

	if (particle)
	{
		int team = GetEntProp(target, Prop_Send, "m_iTeamNum");
		TE_SetupParticleEffect((team == 2 ? PARTICLE_HEALBURST_RED : PARTICLE_HEALBURST_BLUE), PATTACH_ABSORIGIN_FOLLOW, target);
		TE_WriteNum("m_bControlPoint1", target);	
		TE_SendToAll();
	}
}

methodmap SSBChair < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, _, _, _, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}

	public void PlayGenericSpell()
	{
		EmitSoundToAll(g_SSBGenericSpell_Sounds[GetRandomInt(0, sizeof(g_SSBGenericSpell_Sounds) - 1)], _, _, 120);

		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayGenericSpell()");
		#endif
	}

	public void PlayChairThud() {
		EmitSoundToAll(g_SSBChair_ChairThudSounds[GetRandomInt(0, sizeof(g_SSBChair_ChairThudSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayChairThud()");
		#endif
	}

	public void PlayCatastropheChargeUp()
	{
		EmitSoundToAll(SND_CATASTROPHE_CHARGEUP, _, _, 120);

		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayNecroBlastWarning()");
		#endif
	}

	public void PlayCatastropheFire()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBCatastrophe_Dialogue) - 1);
		EmitSoundToAll(g_SSBCatastrophe_Dialogue[rand], _, _, 120);
		CPrintToChatAll(g_SSBCatastrophe_Captions[rand]);
		EmitSoundToAll(SND_NECROBLAST_EXTRA_1, _, _, 120, _, _, GetRandomInt(70, 90));
		EmitSoundToAll(SND_NECROBLAST_BIGBANG, _, _, 120);

		#if defined DEBUG_SOUND
		PrintToServer("CSSBChair::PlayNecroBlast()");
		#endif
	}

	public int GetNearbyAllies(float radius)
	{
		int numAllies;

		float myPos[3], allyPos[3];
		WorldSpaceCenter(this.index, myPos);

		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidAlly(this.index, i) || i_IsABuilding[i] || i == this.index)
				continue;

			WorldSpaceCenter(i, allyPos);
			if (GetVectorDistance(myPos, allyPos) <= radius)
			{
				numAllies++;
			}
		}

		return numAllies;
	}

	public int GetNearbyEnemies(float radius)
	{
		int numEnemies;

		float myPos[3], enemyPos[3];
		WorldSpaceCenter(this.index, myPos);

		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidEnemy(this.index, i) || i_IsABuilding[i] || i == this.index)
				continue;
				
			WorldSpaceCenter(i, enemyPos);
			if (GetVectorDistance(myPos, enemyPos) <= radius)
			{
				numEnemies++;
			}
		}

		return numEnemies;
	}

	public bool CanUseWaver()
	{
		if (Chair_UsingAbility[this.index])
			return false;

		if (GetGameTime(this.index) < this.m_flNextMeleeAttack)
			return false;

		if (this.GetNearbyAllies(Waver_Radius_Healing[Chair_Tier[this.index]]) < Waver_MinAllies[Chair_Tier[this.index]]
		 && this.GetNearbyEnemies(Waver_Radius_DMG[Chair_Tier[this.index]]) < Waver_MinEnemies[Chair_Tier[this.index]])
			return false;

		return true;
	}

	public void DeathWaver()
	{
		this.CastSpellWithAnimation("ACT_FINALE_CHAIR_WAVE", DeathWaver_Pulse, PARTICLE_WAVER_HAND, PARTICLE_WAVER_CAST, "", "effect_hand_R", SND_WAVER_CAST);
		this.m_flNextMeleeAttack = GetGameTime(this.index) + Waver_Cooldown[Chair_Tier[this.index]] + 2.0;
	}

	public void PrepareAbilities()
	{
		this.DeleteAbilities();
		SSB_ChairSpells[this.index] = new ArrayList(255);

		//TODO: Populate abilities here
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(Bombardment_Cooldown[Chair_Tier[this.index]], 3.0, 0, SSBChair_Bombardment, _, Bombardment_GlobalCD[Chair_Tier[this.index]], BOMBARDMENT_NAME));
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(HellRing_Cooldown[Chair_Tier[this.index]], 4.0, 0, SSBChair_RingOfHell, _, HellRing_GlobalCD[Chair_Tier[this.index]], HELLRING_NAME));
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(Teleport_Cooldown[Chair_Tier[this.index]], 5.0, 0, SSBChair_Teleport, _, Teleport_GlobalCD[Chair_Tier[this.index]], TELEPORT_NAME));
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(Catastrophe_Cooldown[Chair_Tier[this.index]], 6.0, 0, SSBChair_Catastrophe, SSBChair_CatastropheFilter, Catastrophe_GlobalCD[Chair_Tier[this.index]], CATASTROPHE_NAME));
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(Absorption_Cooldown[Chair_Tier[this.index]], 7.0, 0, SSBChair_Absorption, SSBChair_AbsorptionFilter, Absorption_GlobalCD[Chair_Tier[this.index]], ABSORPTION_NAME));
	}

	public SSBChair_Spell CreateAbility(float cooldown, float startingCD, int tier, Function ActivationFunction, Function FilterFunction = INVALID_FUNCTION, float globalCD = 0.0, char[] name = "")
	{
		SSBChair_Spell spell = new SSBChair_Spell();

		spell.NextUse = GetGameTime(this.index) + startingCD;
		spell.Cooldown = cooldown;
		spell.ActivationFunction = ActivationFunction;
		spell.FilterFunction = FilterFunction;
		spell.Tier = tier;
		spell.GlobalCooldown = globalCD;
		spell.SetName(name);

		return spell;
	}

	public void DeleteAbilities()
	{
		if (SSB_ChairSpells[this.index] != null)
		{
			for (int spell = 0; spell < GetArraySize(SSB_ChairSpells[this.index]); spell++)
			{
				SSBChair_Spell ability = GetArrayCell(SSB_ChairSpells[this.index], spell);
				ability.Delete();
			}
		}

		delete SSB_ChairSpells[this.index];
	}

	public void AttemptCast()
	{
		if (SSB_ChairSpells[this.index] != null)
		{
			for (int spell = 0; spell < GetArraySize(SSB_ChairSpells[this.index]); spell++)
			{
				SSBChair_Spell ability = GetArrayCell(SSB_ChairSpells[this.index], spell);
				if (ability.CheckCanUse(this, this.m_iTarget))
				{
					ability.Activate(this, this.m_iTarget);
					break;
				}
			}
		}
	}

	public void CastSpellWithAnimation(char sequence[255], Function spell, char handParticle[255], char snapParticle[255], char snapParticleExtra[255], char effectPoint[255], char sound[255], char effectPoint_2[255] = "")
	{
		int activity = this.LookupActivity(sequence);
		if (activity > 0)
		{
			this.StartActivity(activity);
			Chair_UsingAbility[this.index] = true;
			Chair_QueuedSpell[this.index] = spell;
			Chair_SpellEffect[this.index] = snapParticle;
			Chair_SpellEffectExtra[this.index] = snapParticleExtra;
			Chair_SpellEffect_Point[this.index] = effectPoint;

			float pos[3], trash[3];
			this.GetAttachment(effectPoint, pos, trash);
			this.m_iWearable3 = ParticleEffectAt_Parent(pos, handParticle, this.index, effectPoint);
			if (!StrEqual(effectPoint_2, ""))
			{
				this.GetAttachment(effectPoint_2, pos, trash);
				this.m_iWearable4 = ParticleEffectAt_Parent(pos, handParticle, this.index, effectPoint_2);
			}
			EmitSoundToAll(sound, this.index, _, 120);
		}
	}

	//If shockwave is true: trigger a shockwave upon hitting the ground, if teleporting into the air.
	public void Teleport(float pos[3], bool shockwave)
	{
		TeleportEntity(this.index, pos);
		WorldSpaceCenter(this.index, pos);
		ParticleEffectAt(pos, PARTICLE_TELEPORT);
		EmitSoundToAll(SND_TELEPORT, this.index, _, 120);

		if (shockwave)
		{
			float time = GetGameTime(this.index) + Teleport_Delay[Chair_Tier[this.index]];
			DataPack pack = new DataPack();
			WritePackCell(pack, EntIndexToEntRef(this.index));
			WritePackFloat(pack, time);
			RequestFrame(SSBChair_Teleport_SlamDelay, pack);
			b_NoKnockbackFromSources[this.index] = true;
		}
	}

	public bool TeleportNearEnemy(float maxDist, float minDist, bool faceTarget, bool warnTarget, bool requireLOS, float maxHeightDiff)
	{
		int target = this.m_iTarget;
		if (!IsValidEntity(target))
			target = GetClosestTarget(this.index, true, _, true);

		if (!IsValidEntity(target))
			return false;

		float pos[3], targPos[3];
		WorldSpaceCenter(target, pos);

		bool passed = false;

		ArrayList areas = GetAllNearbyAreas(pos, maxDist);

		if (GetArraySize(areas) > 0)
		{
			ScrambleArray(areas);
			for (int i = 0; i < GetArraySize(areas); i++)
			{
				float randPos[3];
				CNavArea navi = GetArrayCell(areas, i);
				navi.GetCenter(randPos);

				if (GetVectorDistance(pos, randPos) < minDist || (maxHeightDiff > 0.0 && fabs(pos[2] - randPos[2]) > maxHeightDiff))
					continue;

				float randLOSCheck[3];
				randLOSCheck = randPos;
				randLOSCheck[2] += 40.0;

				if (requireLOS && !Can_I_See_Enemy_Only(target, target, randLOSCheck))
					continue;

				targPos = randPos;
				passed = true;
			}
		}

		delete areas;

		if (!passed)
			return false;

		float startPos[3];
		this.WorldSpaceCenter(startPos);

		int particle = ParticleEffectAt(startPos, PARTICLE_TELEPORT);
		if (IsValidEntity(particle))
		{
			EmitSoundToAll(SND_TELEPORT, particle, _, 120, _, _, GetRandomInt(90, 110));
			EmitSoundToAll(SND_TELEPORT, particle, _, 120, _, _, GetRandomInt(90, 110));
		}

		TeleportEntity(this.index, targPos);

		ParticleEffectAt(targPos, PARTICLE_SSB_SPAWN);
		EmitSoundToAll(SND_TELEPORT, this.index, _, 120, _, _, GetRandomInt(90, 110));
		EmitSoundToAll(SND_TELEPORT, this.index, _, 120, _, _, GetRandomInt(90, 110));

		if (faceTarget)
			this.FaceTowards(pos, 999999.0);

		if (warnTarget && IsValidClient(target))
		{
			float HudY = -1.0;
			float HudX = -1.0;
			SetHudTextParams(HudX, HudY, 2.0, 0, 255, 120, 255);
			SetGlobalTransTarget(target);
			ShowSyncHudText(target,  SyncHud_Notifaction, "%t", "SSB Teleport Warning");

			EmitSoundToClient(target, SND_COSMIC_MARKED, _, _, _, _, _, GetRandomInt(80, 120));
			EmitSoundToClient(target, SND_COSMIC_MARKED, _, _, _, _, _, GetRandomInt(80, 120));
		}

		return true;
	}

	public void ForceVelocity(float targVel[3])
	{
		SDKUnhook(this.index, SDKHook_Think, NpcJumpThink);
		f3_KnockbackToTake[this.index] = targVel;
		SDKHook(this.index, SDKHook_Think, NpcJumpThink);
	}

	property bool b_CanMove
	{
		public get() { return Chair_CanMove[this.index]; }
		public set(bool value) { Chair_CanMove[this.index] = value; }
	}

	property float f_NextTeleport
	{
		public get() { return f_NextTeleport[this.index]; }
		public set(float value) { f_NextTeleport[this.index] = value; }
	}

	public SSBChair(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{	
		SSBChair npc = view_as<SSBChair>(CClotBody(vecPos, vecAng, MODEL_SSB, SSB_CHAIR_SCALE, SSB_CHAIR_HP, ally));

		if (StrEqual(data, ""))
			Chair_Tier[npc.index] = 0;
		else
		{
			int tier = StringToInt(data);

			if (tier < 0)
				tier = 0;
			if (tier > RoundFloat(1.0 / SSBCHAIR_ARMY_INTERVAL) - 1)
				tier = RoundFloat(1.0 / SSBCHAIR_ARMY_INTERVAL) - 1;

			Chair_Tier[npc.index] = tier;
		}

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bisWalking = false;
		Chair_UsingAbility[npc.index] = false;
		npc.f_NextTeleport = GetGameTime(npc.index) + Teleport_Interval[Chair_Tier[npc.index]];

		func_NPCDeath[npc.index] = view_as<Function>(SSBChair_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SSBChair_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SSBChair_ClotThink);
		func_NPCAnimEvent[npc.index] = SSBChair_AnimEvent;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_FINALE_CHAIR_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", SSB_CHAIR_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		i_NpcWeight[npc.index] = 999;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		Chair_ChangeSequence[npc.index] = false;
		b_NoKnockbackFromSources[npc.index] = false;
		b_SSBChairHasArmy[npc.index] = false;
		f_DamageSinceLastArmy[npc.index] = 0.0;
		npc.b_CanMove = false;

		//IDLE
		npc.m_flSpeed = SSB_CHAIR_SPEED;

		RaidModeScaling = 0.25;
		RaidModeTime = GetGameTime(npc.index) + SSBChair_RaidTime;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({0, 255, 200, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		float rightEye[3], leftEye[3];
		float junk[3];
		npc.GetAttachment("righteye", rightEye, junk);
		npc.GetAttachment("lefteye", leftEye, junk);

		npc.m_bisWalking = false;

		npc.m_flBoneZoneNumSummons = 0.0;

		npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, "eye_powerup_green_lvl_4", npc.index, "righteye", {0.0,0.0,0.0});
		npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, "eye_powerup_green_lvl_4", npc.index, "lefteye", {0.0,0.0,0.0});

		useHeightOverride[npc.index] = true;
		SSBChair_Teleport_Activate(npc, -1, 1800.0);
		Chair_UsingAbility[npc.index] = true;
		EmitSoundToAll(SND_SPAWN_ALERT);

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "SSB Spawn Finale");
			}
		}
		
		npc.PrepareAbilities();

		return npc;
	}
}

public void SSBChair_DeleteAbilities()
{
	for (int i = 0; i < 2049; i++)
	{
		if (SSB_ChairSpells[i] != null)
		{
			for (int spell = 0; spell < GetArraySize(SSB_ChairSpells[i]); spell++)
			{
				SSB_Ability ability = GetArrayCell(SSB_ChairSpells[i], spell);
				ability.Delete();
			}
		}

		delete SSB_ChairSpells[i];
	}
}

public void SSBChair_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	SSBChair npc = view_as<SSBChair>(entity);

	switch(event)
	{
		case 1001:	//Any and all parts of any animation where the chair itself hits something, play a thud sound.
		{
			npc.PlayChairThud();
		}
		case 1002:	//The cast animation has reached its peak, cast whatever spell has been queued up.
		{
			if (Chair_QueuedSpell[npc.index] != INVALID_FUNCTION)
			{
				Call_StartFunction(null, Chair_QueuedSpell[npc.index]);
				Call_PushCell(npc);
				Call_PushCell(npc.m_iTarget);
				Call_Finish();
			}

			float pos[3], trash[3];
			npc.GetAttachment(Chair_SpellEffect_Point[npc.index], pos, trash);
			char the[255];	//This is stupid as hell, but I get an unavoidable error if I don't do it.
			if (!StrEqual(Chair_SpellEffect[npc.index], ""))
			{
				the = Chair_SpellEffect[npc.index];
				ParticleEffectAt(pos, the);
			}
			if (!StrEqual(Chair_SpellEffectExtra[npc.index], ""))
			{
				the = Chair_SpellEffectExtra[npc.index];
				ParticleEffectAt(pos, the);
			}

			if (IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			if (IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
		}
		case 1003:	//Cast animation finished, go back to idle animation and remove "UsingAbility" flag.
		{
			Chair_ChangeSequence[npc.index] = true;
			Chair_Sequence[npc.index] = "ACT_FINALE_CHAIR_IDLE";
			Chair_UsingAbility[npc.index] = false;
		}
		case 1004:	//Fingers have snapped, play sound.
		{
			EmitSoundToAll(SND_SNAP, _, _, 120);
		}
		case 1005:	//Something has been swung, play sound.
		{
			EmitSoundToAll(SND_BIG_SWING, npc.index, _, 120);
		}
		case 1006:	//Hands have clapped, play sound.
		{
			EmitSoundToAll(SND_CLAP, _, _, 120);
		}
		case 1007:	//Necrotic Catastrophe intro animation has finished, transition to charge-up loop and begin VFX.
		{
			Catastrophe_ChargeUp(npc);
		}
		case 1008:	//SSB yells something at this point in the animation, play sound.
		{
			npc.PlayGenericSpell();
		}
		case 1009:	//Soul Redistribution intro anim has reached the point where the spell has been cast, start absorbing souls.
		{
			Absorption_BeginAbsorbing(npc);
		}
		case 1010:	//Soul Redistribution intro has ended, transition to the looping sequence if still active.
		{
			npc.SetPlaybackRate(1.0);

			int activity = npc.LookupActivity("ACT_FINALE_CHAIR_ABSORPTION_LOOP");
			if (activity)
				npc.StartActivity(activity);
		}
		case 1011:	//SSB's chair hits the ground violently, spawn dust particles and play a sound.
		{
			float pos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			ParticleEffectAt(pos, PARTICLE_TELEPORT_SLAM_1);
			ParticleEffectAt(pos, PARTICLE_TELEPORT_SLAM_2);
			EmitSoundToAll(SND_TELEPORT_SLAM_1, npc.index, _, 120, _, _, 80);
		}
	}
}

//TODO 
//Rewrite
public void SSBChair_ClotThink(int iNPC)
{
	SSBChair npc = view_as<SSBChair>(iNPC);
	
	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();	
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	if (Chair_ChangeSequence[npc.index])
	{
		int activity = npc.LookupActivity(Chair_Sequence[npc.index]);
		if (activity > 0)
			npc.StartActivity(activity);
		
		Chair_ChangeSequence[npc.index] = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		if (npc.b_CanMove)
			npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother, true);
				
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.AttemptCast();
	if (npc.CanUseWaver())
		npc.DeathWaver();

	if(b_SSBChairHasArmy[npc.index])
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			b_NpcIsInvulnerable[npc.index] = false;
			Chair_Tier[npc.index]++;
			b_SSBChairHasArmy[npc.index] = false;

			for (int i = 0; i < GetArraySize(SSB_ChairSpells[npc.index]); i++)
			{
				SSBChair_Spell spell = view_as<SSBChair_Spell>(GetArrayCell(SSB_ChairSpells[npc.index], i));
				char name[255];
				spell.GetName(name, 255);

				if (StrEqual(name, BOMBARDMENT_NAME))
				{
					spell.Cooldown = Bombardment_Cooldown[Chair_Tier[npc.index]];
					spell.GlobalCooldown = Bombardment_GlobalCD[Chair_Tier[npc.index]];
				}
				else if (StrEqual(name, HELLRING_NAME))
				{
					spell.Cooldown = HellRing_Cooldown[Chair_Tier[npc.index]];
					spell.GlobalCooldown = HellRing_GlobalCD[Chair_Tier[npc.index]];
				}
				else if (StrEqual(name, TELEPORT_NAME))
				{
					spell.Cooldown = Teleport_Cooldown[Chair_Tier[npc.index]];
					spell.GlobalCooldown = Teleport_GlobalCD[Chair_Tier[npc.index]];
				}
				else if (StrEqual(name, CATASTROPHE_NAME))
				{
					spell.Cooldown = Catastrophe_Cooldown[Chair_Tier[npc.index]];
					spell.GlobalCooldown = Catastrophe_GlobalCD[Chair_Tier[npc.index]];
				}
			}
		}
	}

	if (!Chair_UsingAbility[npc.index] && GetGameTime(npc.index) >= npc.f_NextTeleport)
	{
		if (npc.TeleportNearEnemy(800.0, 100.0, true, false, true, 0.0))
			npc.f_NextTeleport = GetGameTime(npc.index) + Teleport_Interval[Chair_Tier[npc.index]];
	}
}


public Action SSBChair_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;

	SSBChair npc = view_as<SSBChair>(victim);
	
	f_DamageSinceLastArmy[npc.index] += damage;
	if (f_DamageSinceLastArmy[npc.index] >= (float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * SSBCHAIR_ARMY_INTERVAL) && !b_SSBChairHasArmy[npc.index])
	{
		SSBChair_SummonArmy(npc);
		f_DamageSinceLastArmy[npc.index] = 0.0;
	}

	return Plugin_Changed;
}

public void SSBChair_SummonArmy(SSBChair npc)
{
	switch(Chair_Tier[npc.index])
	{
		//First army: Common Riff-Raff: 5 Basic Bones, 2 Beefy Bones, 10 Brittle Bones, 1 Big Bones, 1 Buffed Big Bones
		//TOTAL WITHOUT SCALING: 19
		case 0:
		{
			SSBChair_SummonAlly(npc.index, "npc_basicbones", 50000, RoundToCeil(5.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_beefybones", 100000, RoundToCeil(2.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_brittlebones", 20000, RoundToCeil(10.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_bigbones", 300000, RoundToCeil(1.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_bigbones_buffed", RoundToCeil(300000 * MultiGlobalHighHealthBoss), 1, true);
		}
		//Second army: Godfather Grimme and the Cadaver Troupe: 6 Calcium Criminals, 3 Bone Breakers, 1 Spinal Slugger, 3 Rattlers, 1 Hollow Hitman, 3 Mr. Molotovs, 1 Godfather Grimme, Kingpin of Calcium
		//TOTAL WITHOUT SCALING: 18
		case 1:
		{
			SSBChair_SummonAlly(npc.index, "npc_criminal", 75000, RoundToCeil(6.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_slugger", 125000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_slugger_buffed", 175000, RoundToCeil(1.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_rattler", 40000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_rattler_buffed", 60000, RoundToCeil(1.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_molotov", 60000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_boss_godfather", RoundToCeil(750000 * MultiGlobalHighHealthBoss), 1, true);
		}
		//Third army: Captain Faux-Beard and the Dead Sea Scourge: 7 Undead Deckhands, 4 Buccaneer Bones, 2 Calcium Corsairs, 4 Swashbuckler Skelebones, 2 Deadeyes, 4 Brigadier Bones, 1 Boner Bomber, 3 Aleraisers, 1 Captain Faux-Beard, Terror of the Dead Sea
		//TOTAL WITHOUT SCALING: 28
		case 2:
		{
			SSBChair_SummonAlly(npc.index, "npc_undeaddeckhand", 90000, RoundToCeil(7.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_calciumcorsair", 150000, RoundToCeil(4.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_aleraiser", 200000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_calciumcorsair_buffed", 250000, RoundToCeil(2.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_flintlock", 50000, RoundToCeil(4.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_flintlock_buffed", 75000, RoundToCeil(2.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_buccaneerbones", 80000, RoundToCeil(4.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_buccaneerbones_buffed", 200000, RoundToCeil(1.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_boss_captain", RoundToCeil(1000000 * MultiGlobalHighHealthBoss), 1, true);
		}
		//Final army: Lordread and the Royal Guard: 8 Unpleasant Peasants, 5 Skeletal Squires, 3 Knightmares, 5 Spelletons, 3 Alakablasters, 5 Fearsome Fools, 1 Servant of Mondo, 4 Bone Brewers, 6 Profaned Priests, 1 Lordread, Royal Executioner of Necropolis, 1 Grim Reaper
		//TOTAL WITHOUT SCALING: 42
		case 3:
		{
			SSBChair_SummonAlly(npc.index, "npc_peasant", 100000, RoundToCeil(8.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_squire", 175000, RoundToCeil(5.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_squire_buffed", 300000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_brewer", 250000, RoundToCeil(4.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_skeletalsaint", 150000, RoundToCeil(6.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_archmage", 60000, RoundToCeil(5.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_archmage_buffed", 120000, RoundToCeil(3.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_jester", 100000, RoundToCeil(5.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_jester_buffed", 250000, RoundToCeil(1.0 * MultiGlobalEnemy));
			SSBChair_SummonAlly(npc.index, "npc_boss_executioner", RoundToCeil(1500000 * MultiGlobalHighHealthBoss), 1, true);
			SSBChair_SummonAlly(npc.index, "npc_reaper", RoundToCeil(500000 * MultiGlobalHighHealthBoss), 1, true);
		}
	}

	b_NpcIsInvulnerable[npc.index] = true;
	b_SSBChairHasArmy[npc.index] = true;

	//TODO: Sounds! Also, the bosses need quotes when summoned during this.
}

void SSBChair_SummonAlly(int ssb, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(ssb) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(ssb, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(ssb, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(ssb));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(ssb);
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		Freeplay_AddEnemy(postWaves, enemy, count);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}

public void SSBChair_NPCDeath(int entity)
{
	SSBChair npc = view_as<SSBChair>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	npc.DeleteAbilities();

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}

int SSBChair_CreateProjectile(SSBChair owner, char model[255], float pos[3], float ang[3], float velocity, float scale, DHookCallback CollideCallback, int skin = 0)
{
	int prop = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "ssb_projectile"); 
				
		SetEntDataFloat(prop, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(prop, GetTeam(owner.index));
				
		DispatchSpawn(prop);
				
		ActivateEntity(prop);
		
		SetEntityModel(prop, model);
		char scaleChar[16];
		Format(scaleChar, sizeof(scaleChar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scaleChar);
		
		SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner.index);
		SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
		
		char skinChar[16];
		Format(skinChar, 16, "%i", skin);
		DispatchKeyValue(prop, "skin", skinChar);
		
		float propVel[3], buffer[3];

		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		
		SetEntityMoveType(prop, MOVETYPE_FLY);
		
		propVel[0] = buffer[0]*velocity;
		propVel[1] = buffer[1]*velocity;
		propVel[2] = buffer[2]*velocity;
			
		TeleportEntity(prop, pos, ang, propVel);
		SetEntPropVector(prop, Prop_Send, "m_vInitialVelocity", propVel);
		
		if (h_NpcSolidHookType[prop] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[prop]);
		h_NpcSolidHookType[prop] = 0;

		h_NpcSolidHookType[prop] = g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);

		RequestFrame(SSB_DeleteIfOwnerDisappears, EntIndexToEntRef(prop));
		
		return prop;
	}
	
	return -1;
}