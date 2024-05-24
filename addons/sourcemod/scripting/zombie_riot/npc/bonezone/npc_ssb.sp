#pragma semicolon 1
#pragma newdecls required

static float BONES_SUPREME_SPEED[4] = { 280.0, 310.0, 340.0, 370.0 };

#define BONES_SUPREME_SCALE				"1.45"
#define BONES_SUPREME_SKIN				"1"
#define BONES_SUPREME_HP				"35000"
#define MODEL_SSB   					"models/zombie_riot/the_bone_zone/supreme_spookmaster_bones.mdl"
#define MODEL_SKULL						"models/props_mvm/mvm_human_skull_collide.mdl"
#define MODEL_HIDDEN_PROJECTILE			"models/weapons/w_models/w_drg_ball.mdl"

#define SND_SPAWN_ALERT		"misc/halloween/merasmus_appear.wav"
#define SND_DESPAWN			"misc/halloween/merasmus_disappear.wav"
#define SND_FIREBALL_CAST	")misc/halloween/spell_meteor_cast.wav"
#define SND_FIREBALL_EXPLODE	")misc/halloween/spell_fireball_impact.wav"
#define SND_HOMING_ACTIVATE		")misc/halloween/spell_mirv_cast.wav"
#define SND_BARRAGE_HIT			")weapons/flare_detonator_explode_world.wav"
#define SND_BARRAGE_SPAWN		")weapons/bison_main_shot_01.wav"
#define SND_BARRAGE_LAUNCH		")weapons/flare_detonator_launch.wav"
#define SND_PULL_ACTIVATED		")misc/halloween/merasmus_spell.wav"
#define SND_PLAYER_PULLED		")misc/halloween/merasmus_stun.wav"

#define PARTICLE_SSB_SPAWN	"doomsday_tentpole_vanish01"
#define PARTICLE_OBJECTSPAWN_1	"merasmus_spawn_flash"
#define PARTICLE_OBJECTSPAWN_2	"merasmus_spawn_flash2"
#define PARTICLE_GREENBLAST_SSB		"merasmus_dazed_explosion"
#define PARTICLE_EXPLOSION_FIREBALL_RED	"spell_fireball_tendril_parent_red"
#define PARTICLE_EXPLOSION_FIREBALL_BLUE	"spell_fireball_tendril_parent_blue"
#define PARTICLE_FIREBALL_RED		"spell_fireball_small_red"
#define PARTICLE_FIREBALL_BLUE		"spell_fireball_small_blue"
#define PARTICLE_LASER_RED			"raygun_projectile_red"
#define PARTICLE_LASER_BLUE			"raygun_projectile_blue"
#define PARTICLE_LASER_RED_PREDICT			"raygun_projectile_red_crit"
#define PARTICLE_LASER_BLUE_PREDICT			"raygun_projectile_blue_crit"
#define PARTICLE_BARRAGE_HIT				"nutsnbolts_repair"

static char Volley_HomingSFX[][] = {
	")items/halloween/witch01.wav",
	")items/halloween/witch02.wav",
	")items/halloween/witch03.wav"
};

static char Cross_BlastSFX[][] = {
	")misc/halloween_eyeball/book_exit.wav",
	")misc/halloween/merasmus_hiding_explode.wav",
	")misc/halloween/spell_lightning_ball_cast.wav"
};

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_GibSounds[][] = {
	"items/pumpkin_explode1.wav",
	"items/pumpkin_explode2.wav",
	"items/pumpkin_explode3.wav",
};

static char g_SSBBigHit_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit3.mp3"
};

static char g_SSBBigHit_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}:OH FUCK YOU, YOU PIECE OF SHIT!",
	"{haunted}Supreme Spookmaster Bones{default}:OOOHHH, I HATE THAT ATTACK!",
	"{haunted}Supreme Spookmaster Bones{default}:OH, YOU SON OF A FUCKING BITCH!"
};

static char g_SSBPull_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_deathmagnetic_warning_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_deathmagnetic_warning_2.mp3"
};

static char g_SSBPull_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}GET OVER HERE, BROTHERRRRR!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}GET OVER HEERRREEEE!{default}"
};

static char g_SSBMinorWin_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_3.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_4.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_5.mp3"
};

static char g_SSBMinorWin_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}NOOOOOO! {default}This is an outrage!",
	"{haunted}Supreme Spookmaster Bones{default}: I hate you all. How dare you.",
	"{haunted}Supreme Spookmaster Bones{default}: Ooohhhh noooo, it's one of {olive}these{default} games...",
	"{haunted}Supreme Spookmaster Bones{default}: {yellow}Sigh... {default}What a good game.",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}OH YOU FUCKING PIECE OF SHIT, GOD DAMMIT- {default}Agh...!"
};

static char g_SSBGenericSpell_Sounds[][] = {
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_1.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_2.mp3"
};

static char g_SSBHellIsHere_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_3.mp3"
};

static char g_SSBHellIsHere_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}I AM A GOD!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}TAKE THIS!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}I AM THE MASTER NOW!{default}"
};

static char g_SSBIntro_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro3.mp3"
};

static char g_SSBIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: Get ready, boys. {unusual}Here it comes!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {unusual}I AM A GOD OF VIOLENCE AND WAR, AND YOU ARE BENEATH ME!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: Who dares enter... {unusual}THE HELL ZONE?{default}"
};

static char g_SSBKill_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill3.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill4.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill5.mp3"
};

static char g_SSBKill_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: He will never walk again.",
	"{haunted}Supreme Spookmaster Bones{default}: Oh! Oh, I broke his fucking leg!",
	"{haunted}Supreme Spookmaster Bones{default}: Oh my God, he-he's a dead man.",
    "{haunted}Supreme Spookmaster Bones{default}: HA HA HA HAAAA! Suck it.",
    "{haunted}Supreme Spookmaster Bones{default}: He's so useless!"
};

static char g_SSBNecroBlast_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_3.mp3"
};

static char g_SSBNecroBlast_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}FUCK YOU!!!!!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}BOOM, BABY!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}DAMN!!!!!{default}"
};

static char g_SSBNecroBlastWarning_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_3.mp3"
};

static char g_SSBNecroBlastWarning_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}LAUNCH...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}NOT QUITE HADOUKEN...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}YOU'RE DEAD MEAT...{default}"
};

static char g_SSBSpin2Win_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_spin2win_intro1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_spin2win_intro2.mp3"
};

static char g_SSBSpin2Win_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}I'm spinning to winning...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {red}Spin 2 Win, baby!{default}"
};

static char g_SSBSummonIntro_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_2.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_3.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_4.mp3"
};

static char g_SSBSummonIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {vintage}I'm just gonna place out some Mr. Bones on this map, and they'll never notice...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {vintage}GO HERE, YOU DUMB FUCK.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {vintage}OBJECTIVE: {crimson}KILL.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {vintage}Come on, family! You'll have fuuuuuunnn~!{default}"
};

static char g_SSBLoss_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win2.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win3.mp3"
};

static char g_SSBLoss_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}Life sucks, and then you fucking die.{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {red}Good job, guys. Good job.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {red}Mmhmhahahahahahahahahahahaaaa... AAAAAAHAHAHAHAHAHAHAHA!{default}"
};

static char g_SSBLossEasterEgg_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win_waytoolong.mp3"
};

static char g_SSBLossEasterEgg_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}YO, SHIT FOR BRAINS! What GOD DAMN color is this? HUH?! YOU FUCKING BLIND MOTHERFUCKER!{default}",
    "{red}Who the FUCK do you think you are? Coming here and shitting in MY mailbox, playing MY God damn video games? You're gonna learn about colors, you dumb FORESKIN.{default}"
};

public void SupremeSpookmasterBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	for (int i = 0; i < (sizeof(g_SSBBigHit_Sounds));   i++) { PrecacheSound(g_SSBBigHit_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBPull_Sounds));   i++) { PrecacheSound(g_SSBPull_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBMinorWin_Sounds));   i++) { PrecacheSound(g_SSBMinorWin_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBGenericSpell_Sounds));   i++) { PrecacheSound(g_SSBGenericSpell_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBHellIsHere_Sounds));   i++) { PrecacheSound(g_SSBHellIsHere_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBIntro_Sounds));   i++) { PrecacheSound(g_SSBIntro_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBKill_Sounds));   i++) { PrecacheSound(g_SSBKill_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBNecroBlast_Sounds));   i++) { PrecacheSound(g_SSBBigHit_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBNecroBlastWarning_Sounds));   i++) { PrecacheSound(g_SSBNecroBlastWarning_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSpin2Win_Sounds));   i++) { PrecacheSound(g_SSBSpin2Win_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSummonIntro_Sounds));   i++) { PrecacheSound(g_SSBSummonIntro_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLoss_Sounds));   i++) { PrecacheSound(g_SSBLoss_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLossEasterEgg_Sounds));   i++) { PrecacheSound(g_SSBLossEasterEgg_Sounds[i]);   }

	PrecacheModel(MODEL_SSB);
	PrecacheModel(MODEL_SKULL);
	PrecacheModel(MODEL_HIDDEN_PROJECTILE);

	PrecacheSound(SND_SPAWN_ALERT);
	PrecacheSound(SND_DESPAWN);
	PrecacheSound(SND_FIREBALL_CAST);
	PrecacheSound(SND_FIREBALL_EXPLODE);
	PrecacheSound(SND_HOMING_ACTIVATE);
	PrecacheSound(SND_BARRAGE_SPAWN);
	PrecacheSound(SND_BARRAGE_LAUNCH);
	PrecacheSound(SND_BARRAGE_HIT);
	PrecacheSound(SND_PULL_ACTIVATED);
	PrecacheSound(SND_PLAYER_PULLED);

	for (int i = 0; i < (sizeof(Volley_HomingSFX));   i++) { PrecacheSound(Volley_HomingSFX[i]);   }
	for (int i = 0; i < (sizeof(Cross_BlastSFX));   i++) { PrecacheSound(Cross_BlastSFX[i]);   }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supreme Spookmaster Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ssb");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_SSB;
	NPC_Add(data);

	SSB_PrepareAbilities();
}

static any Summon_SSB(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SupremeSpookmasterBones(client, vecPos, vecAng, ally);
}

//The following are variables used for SSB's various stats and attacks.
//I use the same trick here as I use for my weapons, but for the wave of the encounter instead.
//When you see a variable that looks like "int MyVariable[4] = { 1, 2, 3, 4 };", 1 is the value used on/before wave 15, 2 is the value used on wave 30, 3 is 45, and 4 is 60+.

int SSB_WavePhase = 0;		//This gets set based on the wave number whenever SSB spawns. <= W15 = 0, 16-30 = 1, 31-45 = 2, 46+ = 3.
							//Used purely to know which array slot to use for ability stats.

//SPELL CARDS: SSB's basic attacks. These come out instantly, but are far weaker than his specials.
//NOTE: Spell Cards must have their own function, which takes a "SupremeSpookmasterBones" as a parameter, plus one entity index for the target entity.
ArrayList SSB_SpellCards[4];								//DO NOT TOUCH THIS DIRECTLY!!!! This is used for setting the collection of Spell Cards SSB can use on each wave.
															//To change this, see "SSB_PrepareAbilities".
int SSB_LastSpell[MAXENTITIES] = { -1, ... };				//The most recently-used spell card. Used so that the same Spell Card cannot be used twice in a row.
int SSB_DefaultSpell[4] = { 0, 0, 0, 0 };					//The Spell Card slot to default to if none of the other Spell Cards are successfully cast.
float SSB_NextSpell[MAXENTITIES] = { 0.0, ... }; 			//The GameTime at which SSB will use his next Spell Card.
float SSB_SpellCDMin[4] = { 6.0, 6.0, 5.0, 4.0 };			//The minimum cooldown between spell cards.
float SSB_SpellCDMax[4] = { 11.0, 11.0, 10.0, 9.0 };		//The maximum cooldown between spell cards.

//SPELL CARD #1 - NIGHTMARE VOLLEY: SSB fires a spread of skulls, one of which will always be centered, which home in on victims and explode. Victims are ignited.
//Skulls start red, but turn blue when homing begins.
int Volley_Count[4] = { 4, 8, 12, 16 };							//The number of skulls fired by this Spell Card.
int Volley_MaxTargets[4] = { 3, 4, 5, 6 };						//Maximum number of enemies hit by skull explosions.
float Volley_Velocity[4] = { 360.0, 420.0, 480.0, 540.0 };		//Skull velocity.
float Volley_HomingDelay[4] = { 0.75, 0.625, 0.5, 0.375 };		//Time until the skulls begin to home in on targets.
float Volley_DMG[4] = { 60.0, 90.0, 160.0, 250.0 };				//Skull base damage.
float Volley_EntityMult[4] = { 2.0, 2.5, 3.0, 4.0 };			//Amount to multiply damage dealt by skulls to entities.
float Volley_Radius[4] = { 60.0, 100.0, 140.0, 180.0 };			//Skull explosion radius.
float Volley_Falloff_Radius[4] = { 0.66, 0.5, 0.33, 0.165 };	//Skull falloff, based on radius.
float Volley_Falloff_MultiHit[4] = {0.66, 0.76, 0.86, 1.0 }; 	//Amount to multiply explosion damage for each target hit.
float Volley_HomingAngle[4] = { 90.0, 95.0, 100.0, 105.0 };		//Skulls' maximum homing angle.
float Volley_HomingPerSecond[4] = { 9.0, 10.0, 11.0, 12.0 };	//Number of times per second for skulls to readjust their velocity for the sake of homing in on their target.
float Volley_Spread[4] = { 9.0, 10.0, 11.0, 12.0 };				//Random spread of skulls.
float Volley_Distance[4] = { 60.0, 80.0, 100.0, 120.0 };		//Distance to spread skulls apart when they spawn.
bool b_IsHoming[MAXENTITIES] = { false, ... };					//This is set to true by the plugin when Nightmare Volley's skulls begin to home in on players.
int i_SkullParticle[MAXENTITIES] = { -1, ... };					//The particle associated with a given Nightmare Volley skull, used exclusively to change the trail from red to blue once homing begins.

//SPELL CARD #2 - CURSED CROSS: SSB stops in place and begins to charge up. Once ready: SSB fires a cross of deathly green lasers from his position.
//These lasers have infinite piercing and are not subject to falloff.
//TODO: Needs an intro, wind-up, and activation animation
float Cross_DMG[4] = { 240.0, 480.0, 960.0, 1920.0 };		//Laser damage.
float Cross_EntityMult[4] = { 2.0, 4.0, 6.0, 8.0 };			//Amount to multiply damage dealt by lasers to entities.
float Cross_Range[4] = { 400.0, 600.0, 900.0, 1200.0 };		//Laser range.
float Cross_Width[4] = { 120.0, 160.0, 200.0, 280.0 };		//Laser hitbox width.
float Cross_Delay[4] = { 3.0, 2.75, 2.5, 2.25 };			//Delay until the lasers are fired once this Spell Card is activated.
bool SSB_LaserHit[MAXENTITIES] = { false, ... };			//Used exclusively to see if an entity was hit by any of SSB's laser effects.

//SPELL CARD #3 - CHAOS BARRAGE: SSB launches a bunch of weak laser projectiles in random directions. These lasers deal no damage and do not touch players.
//After a short delay, the lasers freeze in place. Then, after another delay, the lasers fly towards whoever is closest and deal damage on contact.
int Barrage_NumWaves[4] = { 8, 9, 10, 12 };							//The number of waves to fire.
int Barrage_PerWave[4] = { 2, 2, 3, 3 };							//The number of projectiles fired per wave.
float Barrage_WaveDelay[4] = { 0.2, 0.15, 0.1, 0.05 };				//Delay between projectile waves.
float Barrage_InitialVelocity[4] = { 400.0, 400.0, 400.0, 400.0 };	//Projectile velocity before they pause.
float Barrage_PauseDelay[4] = { 1.0, 0.86, 0.76, 0.66};				//Time until projectiles pause.
float Barrage_PauseDuration[4] = {1.66, 1.0, 0.66, 0.33};			//Projectile pause duration.
float Barrage_Velocity[4] = { 2000.0, 2200.0, 2200.0, 2200.0 }; 	//Projectile velocity after they unpause.
float Barrage_DMG[4] = { 20.0, 25.0, 30.0, 40.0 };					//Projectile base damage.
bool Barrage_Prediction[4] = { false, false, true, true };			//Whether or not the projectiles should predict target movement once they become lethal.
float f_BarrageProjectileDMG[MAXENTITIES];							//Ignore this.

//SPELL CARD #4 - DEATH MAGNETIC: SSB freezes in place and begins conjuring a spell. When ready: all players within line-of-sight are pulled to SSB.
//If at least one player was pulled, this spell forces one of the following abilities to be used immediately, ignoring cooldowns and max usage:
//Cursed Cross, Soul Harvester, Spin to Win, MEGA MORTIS
float Death_Delay[4] = { 4.0, 3.75, 3.5, 3.0 };				//Delay before the pull activates.
float Death_Radius[4] = { 1000.0, 1050.0, 1100.0, 1150.0 };	//Maximum radius in which the pull can be activated.

//SPELL CARD #5 - COSMIC TERROR: SSB chooses up to X player(s) at random and marks the spot they are currently at. Y seconds later, that spot summons a laser from the sky,
//which moves towards the nearest enemy and deals rapid damage to anything too close. This is not affected by falloff.
//PS: I'm using the SSB_ prefix for these variables because otherwise we interfere with the actual Cosmic Terror weapon.
int SSB_Cosmic_NumTargets[4] = { 1, 2, 4, 6 };					//The maximum number of players who can be marked by the ability.
float SSB_Cosmic_Delay[4] = { 4.0, 3.5, 2.5, 1.5 };				//Duration until the beams activate and begin to move.
float SSB_Cosmic_Duration[4] = { 8.0, 10.0, 12.0, 14.0 };		//Beam lifespan.
float SSB_Cosmic_DMG[4] = { 20.0, 25.0, 30.0, 40.0 };			//Damage dealt per 0.1s to players who are within the beam's radius.
float SSB_Cosmic_Radius[4] = { 160.0, 180.0, 200.0, 220.0 };	//Damage radius.
float SSB_Cosmic_Speed[4] = { 2.0, 2.5, 3.0, 3.5 };				//Speed at which the beams move towards their target, in hammer units per frame.

//SPELL CARD #6 - RING OF TARTARUS: The locations of up to X player(s) are marked with a red ring. After Y second(s), these rings activate and will begin to slow down
//and rapidly deal damage to any enemies within its radius.
int Ring_NumTargets[4] = { 2, 4, 6, 8 };				//The maximum number of players to spawn rings on.
float Ring_Delay[4] = { 4.0, 4.0, 4.0, 4.0 };			//Duration until the rings activate.
float Ring_Duration[4] = { 8.0, 10.0, 12.0, 14.0 };		//Ring lifespan.
float Ring_DMG[4] = { 10.0, 15.0, 20.0, 25.0 };			//Ring damage per 0.1s.
float Ring_Radius[4] = { 250.0, 300.0, 350.0, 400.0 };	//Ring radius.
float Ring_SlowAmt[4] = { 0.25, 0.33, 0.5, 0.66 };		//Percentage to reduce the movement speed of any enemy within a ring.

//SPELL CARD #7 - GAZE UPON THE SKULL: SSB launches one big but very slow skull, which homes in on the nearest enemy.
//While active, the skull rapidly fires smaller, weaker homing projectiles in random directions.
//If the skull collides with something (or automatically after X seconds), it will trigger a huge explosion.
float Skull_Velocity[4] = { 100.0, 150.0, 200.0, 250.0 };			//Velocity of the big skull.
float Skull_DMG[4] = { 400.0, 800.0, 1600.0, 3200.0 };				//Base damage of the big skull.
float Skull_Radius[4] = { 300.0, 350.0, 400.0, 500.0 };				//Explosion radius of the big skull.
float Skull_Falloff_Radius[4] = { 0.5, 0.5, 0.5, 0.5 };				//Falloff-based radius of the big skull.
float Skull_Falloff_MultiHit[4] = { 0.66, 0.75, 0.8, 0.85 };		//Amount to multiply the big skull's explosion damage for each target it hits.
float Skull_HomingAngle[4] = { 180.0, 220.0, 260.0, 300.0 };		//Big skull's maximum homing angle.
float Skull_HomingPerSecond[4] = { 120.0, 120.0, 120.0, 120.0 };	//Number of times per second for thee big skull to readjust its velocity for the sake of homing in on its target.
float Skull_MiniVelocity[4] = { 800.0, 1000.0, 1200.0, 1400.0 };	//Velocity of the small projectiles fired by the big skull.
float Skull_MiniDMG[4] = { 15.0, 20.0, 25.0, 30.0 };				//Damage dealt by the small projectiles.
float Skull_MiniDuration[4] = {1.0, 1.5, 2.0, 2.5 };				//Lifespan of the small projectiles.
float Skull_MiniHomingAngle[4] = { 40.0, 60.0, 80.0, 100.0 };		//Small projectile max homing angle.
float Skull_MiniHomingPerSecond[4] = {3.0, 4.0, 5.0, 6.0 };			//Number of times per second for the small projectiles to readjust their velocity.

//SPOOKY SPECIALS: SSB's big attacks. These typically have wind-up periods and are very powerful, but have long cooldowns and are more easily avoided.
ArrayList SSB_Specials[4];								//DO NOT TOUCH THIS DIRECTLY!!!! This is used for setting the collection of Spooky Specials SSB can use on each wave.
														//To change this, see "SSB_PrepareAbilities".
int SSB_LastSpecial[MAXENTITIES] = { -1, ... };			//The most recently-used special. Used so that the same special cannot be used twice in a row.
int SSB_DefaultSpecial[4] = { 0, 0, 0, 0 };				//The Spooky Special slot to default to if none of the other Spooky Specials are successfully cast.
float SSB_NextSpecial[MAXENTITIES] = { 0.0, ... };		//The GameTime at which SSB will use his next Spooky Special.
float SSB_SpecialCDMin[4] = { 20.0, 17.5, 15.0, 12.5 };	//The minimum cooldown between specials.
float SSB_SpecialCDMax[4] = { 30.0, 27.5, 25.0, 22.5 }; //The maximum cooldown between specials.

//SPOOKY SPECIAL #1 - NECROTIC BLAST: SSB takes a stance where he points a finger gun forwards and begins to charge up an enormous laser. Once fully-charged, he unleashes the laser
//in one giant, cataclysmic blast which obliterates everything in its path. The laser has infinite range and pierces EVERYTHING, including walls. SSB cannot move or turn while charging.
float Necrotic_Delay[4] = { 4.0, 3.5, 3.0, 2.5 };			//Time until the laser is fired after SSB enters his stance.
float Necrotic_DMG[4] = { 800.0, 2000.0, 5000.0, 12500.0 };	//Damage dealt by the laser.
float Necrotic_EntityMult[4] = { 10.0, 10.0, 10.0, 10.0 };	//Amount to multiply damage dealt by the laser to entities.
float Necrotic_Width[4] = { 300.0, 350.0, 400.0, 450.0 };	//Laser width, in hammer units.

//SPOOKY SPECIAL #2 - MASTER OF THE DAMNED: SSB takes an immobile stance where he rapidly summons skeletal minions to fight for him. These minions are summoned by telegraphed
//green thunderbolts which deal damage in the area around the minion's spawn point.
int Summon_Count[4] = { 2, 3, 4, 5 };								//Number of minions summoned per summon interval.
float Summon_Max[4] = { 16.0, 25.0, 35.0, 45.0 };					//Maximum total summon value of minions summoned by SSB by this ability (lightning strikes will still occur once this cap is reached, but new minions will not be summoned).
float Summon_Duration[4] = { 8.0, 10.0, 12.0, 14.0 };				//Duration for which SSB should summon minions.
float Summon_Resistance[4] = { 0.5, 0.42, 0.33, 0.25 };				//Amount to multiply all damage taken by SSB while he is summoning.
float Summon_BonusTime[4] = { 10.0, 12.0, 14.0, 16.0 };				//Bonus time given to the mercenaries when SSB activates this ability.
float Summon_Radius[4] = { 600.0, 800.0, 1000.0, 1200.0 };			//Radius in which minions are summoned.
float Summon_Interval[4] = { 1.0, 0.9, 0.8, 0.6 };					//Time between summon waves.
float Summon_ThunderDMG[4] = { 100.0, 200.0, 300.0, 400.0 };		//Damage dealt by thunderbolts.
float Summon_ThunderRadius[4] = { 120.0, 180.0, 240.0, 300.0 };		//Thunderbolt radius.
float Summon_ThunderEntityMult[4] = { 2.0, 4.0, 6.0, 8.0 };			//Amount to multiply damage dealt by thunderbolts to entities.
float Summon_ThunderFalloffMultiHit[4] = { 0.66, 0.75, 0.8, 0.8 };	//Amount to multiply damage dealt by thunderbolts for each target hit.
float Summon_ThunderFalloffRange[4] = { 0.66, 0.5, 0.33, 0.165 };	//Maximum damage falloff of thunderbolts, based on range.

//SPOOKY SPECIAL #3 - SOUL HARVESTER: SSB takes an immobile stance where he raises his arms and attempts to drain the life of all nearby enemies, drawing them in as they rapidly
//take damage which is then given to SSB as healing. This ability is immune to damage falloff.
float Harvester_Duration[4] = { 6.0, 7.0, 8.0, 9.0 };				//Duration of the ability.
float Harvester_Radius[4] = { 400.0, 500.0, 600.0, 800.0 };			//Radius.
float Harvester_Resistance[4] = { 0.75, 0.7, 0.66, 0.5 };			//Amount to multiply damage dealt to SSB during this ability.
float Harvester_DMG[4] = { 5.0, 10.0, 15.0, 20.0 };					//Damage dealt per 0.1s to all enemies within Soul Harvester's radius.
float Harvester_HealRatio[4] = { 1.0, 1.5, 2.0, 3.0 };				//Amount to heal SSB per point of damage dealt by this attack.
float Harvester_PullStrength[4] = { 200.0, 250.0, 300.0, 350.0 };	//Strength of the pull effect. Note that this is for point-blank, and is scaled downwards the further the target is.

//SPOOKY SPECIAL #4 - HELL IS HERE: SSB takes - you guessed it - an immobile stance where he thrusts his arms forward and begins to fire a barrage of homing skulls.
//This ability functions like a supercharged version of the Nightmare Volley Spell Card. SSB CAN turn during this ability.
int Hell_Count[4] = { 4, 4, 3, 2 };									//Number of skulls fired per interval.
float Hell_Duration[4] = { 4.0, 5.0, 6.0, 7.0 };					//Duration.
float Hell_Resistance[4] = { 0.5, 0.5, 0.5, 0.5 };					//Amount to multiply damage taken by SSB during this ability.
float Hell_Interval[4] = { 1.0, 0.66, 0.33, 0.2 };					//Interval in which skulls are fired.
float Hell_Velocity[4] = { 360.0, 420.0, 480.0, 540.0 };			//Skull velocity.
float Hell_HomingDelay[4] = { 0.75, 0.625, 0.5, 0.375 };			//Time until the skulls begin to home in on targets.
float Hell_DMG[4] = { 60.0, 90.0, 160.0, 250.0 };					//Skull base damage.
float Hell_EntityMult[4] = { 2.0, 2.5, 3.0, 4.0 };					//Amount to multiply damage dealt by skulls to entities.
float Hell_Radius[4] = { 60.0, 100.0, 140.0, 180.0 };				//Skull explosion radius.
float Hell_Falloff_Radius[4] = { 0.66, 0.5, 0.33, 0.165 };			//Skull falloff, based on radius.
float Hell_Falloff_MultiHit[4] = {0.66, 0.76, 0.86, 1.0 }; 			//Amount to multiply explosion damage for each target hit.
float Hell_HomingAngle[4] = { 90.0, 95.0, 100.0, 105.0 };			//Skulls' maximum homing angle.
float Hell_HomingPerSecond[4] = { 9.0, 10.0, 11.0, 12.0 };			//Number of times per second for skulls to readjust their velocity for the sake of homing in on their target.
float Hell_Spread[4] = { 9.0, 10.0, 11.0, 12.0 };					//Random spread of skulls.
float Hell_Distance[4] = { 60.0, 80.0, 100.0, 120.0 };				//Distance to spread skulls apart when they spawn.

//SPOOKY SPECIAL #5 - SPIN 2 WIN: SSB pulls out his trusty Mortis Masher and begins to spin wildly. During this, he moves VERY quickly, but has his friction reduced, making
//him prone to overshooting his target.
float Spin_DMG[4] = { 100.0, 150.0, 200.0, 400.0 };					//Damage dealt per interval to anyone close enough during the spin.
float Spin_Radius[4] = { 120.0, 120.0, 120.0, 120.0 };				//Radius in which SSB's hammer will bludgeon players while he is spinning.
float Spin_Interval[4] = { 0.33, 0.3, 0.25, 0.2 };					//Interval in which the hammer will hit anyone who is too close.
float Spin_Duration[4] = {7.0, 8.0, 9.0, 10.0 };					//Duration of the ability.
float Spin_Speed[4] = { 600.0, 700.0, 800.0, 900.0 };				//SSB's movement speed while spinning.
float Spin_KB[4] = { 300.0, 600.0, 900.0, 1200.0 };					//Knockback velocity applied to players who get hit. This prevents the ability from just straight-up killing people if they fail to sidestep and SSB gets caught on them, and also makes the ability more fun.
//SPECIAL NOTE FOR SPIN 2 WIN: Friction and acceleration seem to be inextricably linked. You will need the perfect blend of both to get the effects you're looking for, 
//so don't just change these willy-nilly without testing first.
float Spin_Friction[4] = { 0.5, 0.75, 1.0, 1.5 };					//SSB's friction while spinning. Higher friction will make Spin 2 Win harder to avoid. (5.0 = default friction)
float Spin_Acceleration[4] = { 1200.0, 1540.0, 2000.0, 2520.0 };	//SSB's acceleration while spinning (friction does nothing if this is not set). Usually, 2 * Spin_Speed is the optimal value for this. Higher makes it harder to avoid.

//SPOOKY SPECIAL #6 - MEGA MORTIS: SSB once again pulls out his trusty Mortis Masher and lifts it high into the air, charging it with necrotic energy. After X second(s),
//he slams it down, dealing massive damage within a large radius to anybody who is on the ground. Anyone who is directly hit by the hammer itself is instantly killed,
//no matter what. This bypasses downs entirely. In other words: don't try to face-tank it, you will fail.
float Mortis_Delay[4] = { 5.0, 4.5, 4.0, 3.5 };						//Charge time.
float Mortis_DMG[4] = { 800.0, 1600.0, 2400.0, 3200.0 };			//Damage.
float Mortis_Radius[4] = { 900.0, 1000.0, 1100.0, 1200.0 };			//Radius.
float Mortis_InstaDeathRadius[4] = { 100.0, 100.0, 100.0, 100.0 };	//Radius in which players are considered to have been hit directly by the hammer, and are thus instantly killed.
float Mortis_Falloff_Radius[4] = { 0.5, 0.5, 0.5, 0.5 };			//Falloff based on radius.
float Mortis_Falloff_MultiHit[4] = { 1.0, 1.0, 1.0, 1.0 };			//Amount to multiply damage dealt for each target hit.
float Mortis_KB[4] = { 800.0, 1000.0, 1200.0, 1400.0 };				//Upward velocity applied to each target hit.

//TODO:
//	- All specials and spells.
//		- Master of the Damned will not be able to be finished until every other Bone Zone NPC is also finished.
//	- Finalize the VFX/SFX on the following abilities:
//		- Cursed Cross (needs wind-up, charge loop, and cast animations, also a generic wind-up sound)
//		- Death Magnetic (needs wind-up, charge loop, and cast animations, attach particle to hand while charging and have player tether beams emit from that hand)
//	- Generic melee attack. On wave phases 0 and 1, he should just slap people, but on wave phases 2+ he should try to smash them with his hammer. This is obviously far stronger, which makes him way harder to just face-tank, but has a longer wind-up and more end lag.
//	- Note: intended Spooky Special unlock progression is as follows:
//		- Wave Phase 0: Necrotic Blast, Master of the Damned
//		- Wave Phase 1: Gains access to Spin 2 Win and Soul Harvester.
//		- Wave Phase 2: Gains access to Hell is Here.
//		- Wave Phase 3: Gains access to MEGA MORTIS.
//	- Make Supreme Slayer stance:
//		- Entered after reaching 33% HP on wave phase 3. Increases movement speed by 66%, triples damage output, and reduces cooldowns to 33%.
//		- Melee attack is replaced with a short-ranged necrotic bolt, which has a very low cooldown and deals enormous damage.
//		- Lasts for 30 seconds.
//		- Entered permanently when the mercenaries run out of time on any wave phase.

//Below are the stats governing both of SSB's ability systems (Spell Cards AND Spooky Specials). Do not touch these! Instead, use the methodmap's getters and setters if you need to change them.
#define SSB_MAX_ABILITIES 255

int Ability_MaxUses[SSB_MAX_ABILITIES] = { 0, ... };	//The maximum number of times the ability can be used per fight. <= 0: no limit.
int Ability_Uses[SSB_MAX_ABILITIES] = { 0, ... };		//The number of times the ability has been used during this fight.
float Ability_Chance[SSB_MAX_ABILITIES] = { 0.0, ... };	//The chance for this ability to be used when SSB attempts to activate a Spooky Special or use a Spell Card (0.0 = 0%, 1.0 = 100%).
float Ability_ExtraCD[SSB_MAX_ABILITIES] = { 0.0, ... };	//Additional cooldown caused by this ability. Used mainly for long-duration abilities, so SSB doesn't chain them back-to-back.
Function Ability_Function[SSB_MAX_ABILITIES] = { INVALID_FUNCTION, ... };	//The function to call when this ability is successfully activated.
Function Ability_Filter[SSB_MAX_ABILITIES] = { INVALID_FUNCTION, ... };		//The function to call when this ability is about to be activated, to check manually if it can be used or not. Must take one SupremeSpookmasterBones and an entity index for the victim as parameters, and return a bool (true: activate, false: don't).
char Ability_Name[SSB_MAX_ABILITIES][255];				//The ability's name. Used for printing Spell Card alerts to chat, and also for looking up ability indices.
bool Ability_IsCard[SSB_MAX_ABILITIES] = { false, ... };	//If true, the ability is a spell card.
bool Ability_SkipCardSound[SSB_MAX_ABILITIES] = { false, ... };	//If true, the ability will not print an alert to chat or play the generic spell sound.

bool SSB_AbilitySlotUsed[SSB_MAX_ABILITIES] = {false, ...};

methodmap SSB_Ability __nullable__
{
	public SSB_Ability()
	{
		int index = 0;
		while (SSB_AbilitySlotUsed[index] && index < SSB_MAX_ABILITIES)
			index++;

		if (index >= SSB_MAX_ABILITIES)
			LogError("ERROR: SSB SOMEHOW has more than %i spell cards/specials...\nThis should never happen.", SSB_MAX_ABILITIES);
		
		SSB_AbilitySlotUsed[index] = true;

		return view_as<SSB_Ability>(index);
	}

	//Rolls to see if this ability can successfully be used, auto-using it and returning true on success.
	//Set "forced" to true to ignore random chance, max uses, and the filter function and force the ability to go through.
	public bool Activate(SupremeSpookmasterBones user, int target, bool forced = false)
	{
		bool success = true;
		if (!forced)
			success = GetRandomFloat(0.0, 1.0) <= this.Chance;

		if (success && !forced)
			success = this.Uses < this.MaxUses || this.MaxUses <= 0;

		if (success && !forced && this.FilterFunction != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.FilterFunction);
			Call_PushCell(user);
			Call_PushCell(target);
			Call_Finish(success);
		}
		
		if (success || forced)
		{
			Call_StartFunction(null, this.ActivationFunction);
			Call_PushCell(user);
			Call_PushCell(target);
			Call_Finish();

			this.Uses++;

			if (this.IsCard && !this.SkipCardSound)
			{
				CPrintToChatAll("{darkorange}- = { {unusual}SPELL CARD: {haunted}%s!{darkorange} } = -{default}", Ability_Name[this.Index]);
				user.PlayGenericSpell();
			}
		}

		return success;
	}

	public void Delete()
	{
		this.Chance = 0.0;
		this.ActivationFunction = INVALID_FUNCTION;
		this.Uses = 0;
		this.MaxUses = 0;
		SSB_AbilitySlotUsed[this.Index] = false;
	}

	public void SetName(const char[] name)
	{
		Format(Ability_Name[this.Index], 255, "%s", name);
	}

	public void GetName(char output[255])
	{
		strcopy(output, sizeof(output), Ability_Name[this.Index]);
	}

	property int Index
	{ 
		public get() { return view_as<int>(this); }
	}

	property int MaxUses
	{
		public get() { return Ability_MaxUses[this.Index]; }
		public set(int value) { Ability_MaxUses[this.Index] = value; }
	}

	property int Uses
	{
		public get() { return Ability_Uses[this.Index]; }
		public set(int value) { Ability_Uses[this.Index] = value; }
	}

	property float Chance
	{
		public get() { return Ability_Chance[this.Index]; }
		public set(float value) { Ability_Chance[this.Index] = value; }
	}

	property float ExtraCD
	{
		public get() { return Ability_ExtraCD[this.Index]; }
		public set(float value) { Ability_ExtraCD[this.Index] = value; }
	}

	property Function ActivationFunction
	{
		public get() { return Ability_Function[this.Index]; }
		public set(Function value) { Ability_Function[this.Index] = value; }
	}

	property Function FilterFunction
	{
		public get() { return Ability_Filter[this.Index]; }
		public set(Function value) { Ability_Filter[this.Index] = value; }
	}

	property bool IsCard
	{
		public get() { return Ability_IsCard[this.Index]; }
		public set(bool value) { Ability_IsCard[this.Index] = value; }
	}

	property bool SkipCardSound
	{
		public get() { return Ability_SkipCardSound[this.Index]; }
		public set(bool value) { Ability_SkipCardSound[this.Index] = value; }
	}
}

static void SSB_PrepareAbilities()
{
	SSB_DeleteAbilities();
	for (int i = 0; i < 4; i++)
	{
		SSB_SpellCards[i] = new ArrayList(255);
		SSB_Specials[i] = new ArrayList(255);
	}

	//The following example adds a Spell Card named "Example Spell" to the wave 15 pool of spells (SSB_SpellCards[0]), which has a 15% cast chance, can be used twice, checks SpellCard_Filter before activation, and calls SpellCard_Example when successfully cast.
	//Simply copy what this does to add new Spell Cards to each wave's pool of Spell Cards.
	//PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("Example Spell", 0.15, 2, SpellCard_Example, SpellCard_Filter));

	//IMPORTANT NOTE: The chance of a specific ability being chosen is NOT its chance variable. The chance variable ONLY determines the likelihood of it being cast if it is chosen.
	//The ACTUAL chance of the spell being used can be calculated with this formula:
	//Real Chance = (1 / Total # of Abilities In Wave's Ability Pack) * Ability's Chance Variable
	//So if we have 3 abilities and a chance variable of 0.33, our chance is: (1 / 3) * 0.33 -> 0.33 * 0.33 -> 10.89% chance of being used.

	//Wave 15 (and before):
	//PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("NIGHTMARE VOLLEY", 0.5, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("CURSED CROSS", /*0.66*/0.0, 0, SpellCard_CursedCross, _, _, true, Cross_Delay[0]));
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("DEATH MAGNETIC", 1.0, 0, SpellCard_DeathMagnetic, _, _, true, Death_Delay[0]));

	//Wave 30:
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, _, _, true, Cross_Delay[1]));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("CHAOS BARRAGE", 0.75, 0, SpellCard_ChaosBarrage));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("DEATH MAGNETIC", 0.5, 3, SpellCard_DeathMagnetic, _, _, true, Death_Delay[1]));

	//Wave 45:
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, _, _, true, Cross_Delay[2]));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("CHAOS BARRAGE", 1.0, 0, SpellCard_ChaosBarrage));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("DEATH MAGNETIC", 0.66, 2, SpellCard_DeathMagnetic, _, _, true, Death_Delay[2]));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("COSMIC TERROR", 0.33, 1, SpellCard_CosmicTerror));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("RING OF TARTARUS", 0.2, 2, SpellCard_RingOfTartarus));

	//Wave 60+:
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, _, _, true, Cross_Delay[3]));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("CHAOS BARRAGE", 1.0, 0, SpellCard_ChaosBarrage));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("DEATH MAGNETIC", 0.66, 3, SpellCard_DeathMagnetic, _, _, true, Death_Delay[3]));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("COSMIC TERROR", 0.5, 2, SpellCard_CosmicTerror));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("RING OF TARTARUS", 0.2, 3, SpellCard_RingOfTartarus));
	PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("WITNESS THE SKULL", 0.125, 2, SpellCard_TheSkull));
}

public void SpellCard_NightmareVolley(SupremeSpookmasterBones ssb, int target)
{
	if (Volley_Count[SSB_WavePhase] < 1)
		return;

	ssb.AddGesture("ACT_SPELLCAST_2");
	DataPack pack = new DataPack();
	CreateTimer(0.5, NightmareVolley_Launch, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, EntIndexToEntRef(target));
	ssb.UsingAbility = true;
}

public Action NightmareVolley_Launch(Handle timer, DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int target = EntRefToEntIndex(ReadPackCell(pack));

	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	ssb.UsingAbility = false;

	float pos[3], ang[3], testAng[3];
	GetEntPropVector(ssb.index, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(ssb.index, Prop_Send, "m_angRotation", ang);
	pos[2] += 60.0;

	testAng[0] = 0.0;
	testAng[1] = ang[1];
	testAng[2] = 0.0;
				
	GetPointFromAngles(pos, testAng, 40.0, pos, Priest_IgnoreAll, MASK_SHOT);

	int num = Volley_Count[SSB_WavePhase];
	NightmareVolley_ShootSkull(ssb, pos, ang, Volley_Velocity[SSB_WavePhase]);
	num--;

	ParticleEffectAt(pos, PARTICLE_GREENBLAST_SSB, 3.0);
	EmitSoundToAll(SND_FIREBALL_CAST, ssb.index, _, 120);

	if (num < 1)
		return Plugin_Continue;

	for (int i = 0; i < num; i++)
	{
		float randAng[3], randPos[3];
		randPos = pos;
		randAng = ang;
		for (int vec = 0; vec < 2; vec++)
			randAng[vec] += GetRandomFloat(-60.0, 60.0);

		GetPointFromAngles(pos, randAng, GetRandomFloat(0.0, Volley_Distance[SSB_WavePhase]), randPos, Priest_OnlyHitWorld, MASK_SHOT);

		int attempts = 10;	//SSB can sometimes try to use this attack in a position where the skulls would spawn in a wall, which causes script execution timeout. This is a hack which fixes that. I may or may not eventually add a REAL fix, but for now, this will do.
		while (NightmareVolley_WouldSkullCollide(pos) && attempts > 0)	//Don't let skulls spawn in places where they would collide with something
		{
			GetPointFromAngles(pos, randAng, GetRandomFloat(0.0, Volley_Distance[SSB_WavePhase]), randPos, Priest_OnlyHitWorld, MASK_SHOT);
			attempts--;
		}

		if (IsValidEntity(target))
		{
			float dummy[3], pos2[3];
			WorldSpaceCenter(target, pos2);
			Priest_GetAngleToPoint(ssb.index, randPos, pos2, dummy, randAng);
		}
		else
		{
			randAng = ang;
			for (int vec = 0; vec < 3; vec++)
				randAng[vec] += GetRandomFloat(-Volley_Spread[SSB_WavePhase], Volley_Spread[SSB_WavePhase]);
		}

		ParticleEffectAt(randPos, PARTICLE_GREENBLAST_SSB, 3.0);
		NightmareVolley_ShootSkull(ssb, randPos, randAng, Volley_Velocity[SSB_WavePhase]);
	}

	return Plugin_Continue;
}

public bool NightmareVolley_WouldSkullCollide(float pos[3])
{
	float angles[3], otherLoc[3];
	angles[0] = 90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Handle trace = TR_TraceRayFilterEx(pos, angles, MASK_SHOT, RayType_Infinite, Priest_OnlyHitWorld);
	TR_GetEndPosition(otherLoc, trace);
	delete trace;
	
	return GetVectorDistance(pos, otherLoc) <= 25.0;
}

public void NightmareVolley_ShootSkull(SupremeSpookmasterBones ssb, float pos[3], float ang[3], float vel)
{
	int skull = SSB_CreateProjectile(ssb, MODEL_SKULL, pos, ang, vel, GetRandomFloat(0.8, 1.2), NightmareVolley_Collide);
	if (IsValidEntity(skull))
	{
		b_IsHoming[skull] = false;
		i_SkullParticle[skull] = EntIndexToEntRef(SSB_AttachParticle(skull, PARTICLE_FIREBALL_RED, _, ""));
		CreateTimer(Volley_HomingDelay[SSB_WavePhase], NightmareVolley_StartHoming, EntIndexToEntRef(skull), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action NightmareVolley_StartHoming(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	int particle = EntRefToEntIndex(i_SkullParticle[ent]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);

	i_SkullParticle[ent] = EntIndexToEntRef(SSB_AttachParticle(ent, PARTICLE_FIREBALL_BLUE, _, ""));

	EmitSoundToAll(Volley_HomingSFX[GetRandomInt(0, sizeof(Volley_HomingSFX) - 1)], ent, _, 120, _, _, GetRandomInt(80, 110));
	EmitSoundToAll(SND_HOMING_ACTIVATE, ent, _, 120, _, _, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	float ang[3];
	GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
	Initiate_HomingProjectile(ent, owner, Volley_HomingAngle[SSB_WavePhase], Volley_HomingPerSecond[SSB_WavePhase], false, true, ang);
	b_IsHoming[ent] = true;

	return Plugin_Continue;
}

public MRESReturn NightmareVolley_Collide(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

	ParticleEffectAt(position, b_IsHoming[entity] ? PARTICLE_EXPLOSION_FIREBALL_BLUE : PARTICLE_EXPLOSION_FIREBALL_RED, 1.0);

	EmitSoundToAll(SND_FIREBALL_EXPLODE, entity);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(IsValidEntity(owner))
	{
		bool isBlue = GetEntProp(owner, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Volley_DMG[SSB_WavePhase], owner, entity, 0, position, Volley_Radius[SSB_WavePhase], Volley_Falloff_MultiHit[SSB_WavePhase],
		Volley_Falloff_Radius[SSB_WavePhase], isBlue, Volley_MaxTargets[SSB_WavePhase], true, Volley_EntityMult[SSB_WavePhase]);
	}

	RemoveEntity(entity);
	return MRES_Supercede;
}

//TODO: Cursed Cross needs anims, also make some generic ability wind-up sounds and play them here
public void SpellCard_CursedCross(SupremeSpookmasterBones ssb, int target)
{
	ssb.Pause();
	ssb.UsingAbility = true;
	CreateTimer(Cross_Delay[SSB_WavePhase], Cross_Activate, EntIndexToEntRef(ssb.index), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Cross_Activate(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
	ssb.Unpause();
	ssb.UsingAbility = false;
	ssb.PlayGenericSpell();

	for (int i = 0; i < sizeof(Cross_BlastSFX); i++)
	{
		EmitSoundToAll(Cross_BlastSFX[i], ssb.index, _, 120, _, _, 80);
	}

	float pos[3], ang[3], hullMin[3], hullMax[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_angRotation", ang);
	ang[0] = 0.0;
	ang[2] = 0.0;
	WorldSpaceCenter(ssb.index, pos);
	hullMin[0] = -Cross_Width[SSB_WavePhase];
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	for (float mod = 0.0; mod < 360.0; mod += 90.0)
	{
		float shootAng[3], shootPos[3];
		shootAng = ang;
		shootAng[1] += mod;

		GetPointFromAngles(pos, shootAng, Cross_Range[SSB_WavePhase], shootPos, Priest_OnlyHitWorld, MASK_SHOT);

		TR_TraceHullFilter(pos, shootPos, hullMin, hullMax, 1073741824, SSB_LaserTrace, ssb.index);
			
		for (int victim = 1; victim < MAXENTITIES; victim++)
		{
			if (SSB_LaserHit[victim])
			{
				SSB_LaserHit[victim] = false;
					
				if (IsValidEnemy(ssb.index, victim))
				{
					float damage = Cross_DMG[SSB_WavePhase];
						
					if (ShouldNpcDealBonusDamage(victim))
					{
						damage *= Cross_EntityMult[SSB_WavePhase];
					}
						
					float vicLoc[3];
					WorldSpaceCenter(victim, vicLoc);
					SDKHooks_TakeDamage(victim, ssb.index, ssb.index, damage, DMG_PLASMA, _, NULL_VECTOR, vicLoc);
				}
			}
		}
			
		ParticleEffectAt(shootPos, PARTICLE_GREENBLAST_SSB, 2.0);
		SpawnBeam_Vectors(pos, shootPos, 0.25, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(pos, shootPos, 0.25, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(pos, shootPos, 0.25, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 6.0, 6.0, _, 10.0);
		SpawnBeam_Vectors(pos, shootPos, 0.25, 20, 255, 120, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 20.0);
	}

	return Plugin_Continue;
}

public bool SSB_LaserTrace(int entity, int contentsMask, int user)
{
	if (IsEntityAlive(entity) && entity != user)
		SSB_LaserHit[entity] = true;
	
	return false;
}

public MRESReturn SSB_BlockExplosion(int entity)
{
	return MRES_Supercede;	//DO NOT.
}

public void SpellCard_ChaosBarrage(SupremeSpookmasterBones ssb, int target)
{
	Barrage_LaunchWave(ssb);
	int numWaves = Barrage_NumWaves[SSB_WavePhase] - 1;
	if (numWaves > 0)
	{
		DataPack pack = new DataPack();
		RequestFrame(Barrage_NextWave, pack);
		WritePackCell(pack, EntIndexToEntRef(ssb.index));
		WritePackCell(pack, numWaves);
		WritePackCell(pack, SSB_WavePhase);
		WritePackFloat(pack, GetGameTime(ssb.index) + Barrage_WaveDelay[SSB_WavePhase]);
	}
}

public void Barrage_NextWave(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int remaining = ReadPackCell(pack);
	int phase = ReadPackCell(pack);
	float next = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(ent) || remaining < 1)
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	float gt = GetGameTime(ssb.index);
	if (gt >= next)
	{
		Barrage_LaunchWave(ssb);
		next = gt + Barrage_WaveDelay[phase];
		remaining--;
	}

	DataPack pack2 = new DataPack();
	RequestFrame(Barrage_NextWave, pack2);
	WritePackCell(pack2, EntIndexToEntRef(ssb.index));
	WritePackCell(pack2, remaining);
	WritePackCell(pack2, phase);
	WritePackFloat(pack2, next);
}

public void Barrage_LaunchWave(SupremeSpookmasterBones ssb)
{
	float pos[3];
	WorldSpaceCenter(ssb.index, pos);

	for (int i = 0; i < Barrage_PerWave[SSB_WavePhase]; i++)
	{
		float randAng[3];
		randAng[0] = GetRandomFloat(20.0, -90.0);	//We don't want too steep of a downward angle, otherwise they might hit the ground and be useless.
		randAng[1] = GetRandomFloat(0.0, 360.0);
		randAng[2] = GetRandomFloat(0.0, 360.0);

		int projectile = SSB_CreateProjectile(ssb, MODEL_HIDDEN_PROJECTILE, pos, randAng, Barrage_InitialVelocity[SSB_WavePhase], 0.33, SSB_BlockExplosion);
		if (IsValidEntity(projectile))
		{
			SetEntityMoveType(projectile, MOVETYPE_NOCLIP);

			i_SkullParticle[projectile] = EntIndexToEntRef(SSB_AttachParticle(projectile, Barrage_Prediction[SSB_WavePhase] ? PARTICLE_LASER_RED_PREDICT : PARTICLE_LASER_RED, 0.0, ""));

			DataPack pack = new DataPack();
			RequestFrame(Barrage_WaitForFreeze, pack);
			WritePackCell(pack, EntIndexToEntRef(projectile));
			WritePackCell(pack, SSB_WavePhase);
			WritePackFloat(pack, GetGameTime() + Barrage_PauseDelay[SSB_WavePhase]);
		}
	}

	EmitSoundToAll(SND_BARRAGE_SPAWN, ssb.index, _, _, _, _, GetRandomInt(80, 110));
}

public void Barrage_WaitForFreeze(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float freezeTime = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(ent))
		return;

	float gt = GetGameTime();
	if (gt >= freezeTime)
	{
		SetEntityMoveType(ent, MOVETYPE_NONE);

		DataPack pack2 = new DataPack();
		RequestFrame(Barrage_WaitForLaunch, pack2);
		WritePackCell(pack2, EntIndexToEntRef(ent));
		WritePackCell(pack2, phase);
		WritePackFloat(pack2, gt + Barrage_PauseDuration[phase]);

		return;
	}

	pack = new DataPack();
	RequestFrame(Barrage_WaitForFreeze, pack);
	WritePackCell(pack, EntIndexToEntRef(ent));
	WritePackCell(pack, phase);
	WritePackFloat(pack, freezeTime);
}

public void Barrage_WaitForLaunch(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float launchTime = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(ent))
		return;

	float gt = GetGameTime();
	if (gt >= launchTime)
	{
		int target = GetClosestTarget(ent, true, _, _, _, _, _, true);
		if (!IsValidEntity(target))
		{
			pack = new DataPack();
			RequestFrame(Barrage_SearchForTarget, pack);
			WritePackCell(pack, EntIndexToEntRef(ent));
			WritePackCell(pack, phase);
		}
		else
		{
			Barrage_Launch(ent, target, phase);
		}

		return;
	}

	pack = new DataPack();
	RequestFrame(Barrage_WaitForLaunch, pack);
	WritePackCell(pack, EntIndexToEntRef(ent));
	WritePackCell(pack, phase);
	WritePackFloat(pack, launchTime);
}

public void Barrage_SearchForTarget(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);

	delete pack;

	if (!IsValidEntity(ent))
		return;

	int target = GetClosestTarget(ent, true, _, _, _, _, _, true);
	if (IsValidEntity(target))
	{
		Barrage_Launch(ent, target, phase);
		return;
	}

	pack = new DataPack();
	RequestFrame(Barrage_SearchForTarget, pack);
	WritePackCell(pack, EntIndexToEntRef(ent));
	WritePackCell(pack, phase);
}

public void Barrage_Launch(int ent, int target, int phase)
{
	SetEntityMoveType(ent, MOVETYPE_FLY);

	SDKHook(ent, SDKHook_TouchPost, Barrage_Touch);

	int particle = EntRefToEntIndex(i_SkullParticle[ent]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);

	i_SkullParticle[ent] = EntIndexToEntRef(SSB_AttachParticle(ent, Barrage_Prediction[phase] ? PARTICLE_LASER_BLUE_PREDICT : PARTICLE_LASER_BLUE, 0.0, ""));

	float pos[3], startPos[3], vel[3], ang[3];
	WorldSpaceCenter(target, pos);
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", startPos);
	GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);

	if (Barrage_Prediction[phase])
		PredictSubjectPositionForProjectiles_NoNPCNeeded(startPos, target, Barrage_Velocity[phase], _, pos);

	MakeVectorFromPoints(startPos, pos, ang);
	GetVectorAngles(ang, ang);

	vel[0] = Cosine(DegToRad(ang[0])) * Cosine(DegToRad(ang[1])) * Barrage_Velocity[phase];
	vel[1] = Cosine(DegToRad(ang[0])) * Sine(DegToRad(ang[1])) * Barrage_Velocity[phase];
	vel[2] = Sine(DegToRad(ang[0])) * -Barrage_Velocity[phase];

	TeleportEntity(ent, _, _, vel);

	f_BarrageProjectileDMG[ent] = Barrage_DMG[phase];
	EmitSoundToAll(SND_BARRAGE_LAUNCH, ent, _, _, _, _, GetRandomInt(80, 110));
}

public void SSB_DeleteIfOwnerDisappears(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner))
	{
		RemoveEntity(ent);
		return;
	}

	RequestFrame(SSB_DeleteIfOwnerDisappears, ref);
}

public Action Barrage_Touch(int entity, int other)
{
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

	ParticleEffectAt(pos, PARTICLE_BARRAGE_HIT);
	EmitSoundToAll(SND_BARRAGE_HIT, entity, _, _, _, _, GetRandomInt(80, 110));

	if (IsValidEnemy(entity, other))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		SDKHooks_TakeDamage(other, entity, owner, f_BarrageProjectileDMG[entity], _, _, _, pos);
	}

	RemoveEntity(entity);
	return Plugin_Continue;
}

public void SpellCard_DeathMagnetic(SupremeSpookmasterBones ssb, int target)
{
	ssb.PlayDeathMagnetic();
	ssb.Pause();
	ssb.UsingAbility = true;

	DataPack pack = new DataPack();
	RequestFrame(Death_Check, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack, GetGameTime(ssb.index) + Death_Delay[SSB_WavePhase]);
	WritePackFloat(pack, GetGameTime(ssb.index));
}

public void Death_Check(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float time = ReadPackFloat(pack);
	float NextVFX = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(ent))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	float gt = GetGameTime(ssb.index);

	if (gt >= time)
	{
		int NumPulled = 0;
		//Copied directly from Bob, thanks Artvin:
		for(int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && dieingstate[client] == 0 && TeutonType[client] == 0)
			{
				if (!Can_I_See_Enemy_Only(ssb.index, client))
					continue;

				float pos[3], EnemyPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", EnemyPos); 
				GetEntPropVector(ssb.index, Prop_Data, "m_vecOrigin", pos); 
								
				float Distance = GetVectorDistance(pos, EnemyPos);
				if(Distance < Death_Radius[SSB_WavePhase])
				{				
					//Pull them.
					static float angles[3];
					GetVectorAnglesTwoPoints(pos, EnemyPos, angles);

					if (GetEntityFlags(client) & FL_ONGROUND)
						angles[0] = 0.0; // toss out pitch if on ground

					static float velocity[3];
					GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(velocity, -Death_Radius[SSB_WavePhase]);
																
					// min Z if on ground
					if (GetEntityFlags(client) & FL_ONGROUND)
						velocity[2] = fmax(325.0, velocity[2]);
												
					// apply velocity
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);   

					NumPulled++;

					float UserCenter[3], OtherCenter[3];
					WorldSpaceCenter(ssb.index, UserCenter);
					WorldSpaceCenter(client, OtherCenter);
					SpawnBeam_Vectors(UserCenter, OtherCenter, 0.33, 255, 80, 80, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 15.0);

					EmitSoundToAll(SND_PLAYER_PULLED, client, _, _, _, _, GetRandomInt(80, 110));
				}
			}
		}

		ssb.Unpause();
		ssb.UsingAbility = false;

		if (NumPulled > 0)
		{
			EmitSoundToAll(SND_PULL_ACTIVATED, ssb.index, _, 120, _, _, GetRandomInt(80, 110));

			ArrayList abilities = new ArrayList(255);
			PushArrayString(abilities, "CURSED CROSS");
			PushArrayString(abilities, "SOUL HARVESTER");
			PushArrayString(abilities, "SPIN 2 WIN");
			PushArrayString(abilities, "MEGA MORTIS");

			bool success = false;
			while (!success && GetArraySize(abilities) > 0)
			{
				int chosen = GetRandomInt(0, GetArraySize(abilities) - 1);
				char name[255];
				GetArrayString(abilities, chosen, name, sizeof(name));

				int slot = ssb.GetAbilityByName(name);
				if (slot != -1)
				{
					ssb.ActivateSpecial(-1, slot);
					success = true;
				}
				else
				{
					slot = ssb.GetSpellByName(name);
					if (slot != -1)
					{
						ssb.CastSpell(-1, slot);
						success = true;
					}
				}

				RemoveFromArray(abilities, chosen);
			}

			delete abilities;
		}

		return;
	}
	else
	{
		float pos[3], UserCenter[3], OtherCenter[3];
		GetEntPropVector(ssb.index, Prop_Data, "m_vecOrigin", pos); 
		WorldSpaceCenter(ssb.index, UserCenter);

		spawnRing_Vectors(pos, Death_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 0, 0, 255, 1, 0.1, 16.0, 2.0, 1);

		for(int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && dieingstate[client] == 0 && TeutonType[client] == 0)
			{
				if (!Can_I_See_Enemy_Only(ssb.index, client))
					continue;

				WorldSpaceCenter(client, OtherCenter);
				if (GetVectorDistance(UserCenter, OtherCenter) <= Death_Radius[SSB_WavePhase])
				{
					SpawnBeam_Vectors(UserCenter, OtherCenter, 0.1, 255, 0, 0, 140, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
				}
			}
		}

		if (gt >= NextVFX)
		{
			spawnRing_Vectors(pos, Death_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 255, 1, 0.1, 32.0, 2.0, 1);
			spawnRing_Vectors(pos, Death_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 0, 0, 255, 1, 0.33, 16.0, 2.0, 1, 0.0);
			NextVFX = gt + 0.25;
		}
	}

	pack = new DataPack();
	RequestFrame(Death_Check, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack, time);
	WritePackFloat(pack, NextVFX);
}

public void SpellCard_CosmicTerror(SupremeSpookmasterBones ssb, int target)
{

}

public void SpellCard_RingOfTartarus(SupremeSpookmasterBones ssb, int target)
{

}

public void SpellCard_TheSkull(SupremeSpookmasterBones ssb, int target)
{

}

/*void SpellCard_Example(SupremeSpookmasterBones ssb, int target)
{
	//Hypothetical Spell Card code goes here.
}

void SpellCard_Filter(SupremeSpookmasterBones ssb, int target)
{
	//Hypothetical filter code goes here. Return true to allow activation, false otherwise.
}*/

static SSB_Ability SSB_CreateAbility(const char[] name, float Chance, int MaxUses, Function ActivationFunction, Function FilterFunction = INVALID_FUNCTION, bool IsSpellCard = true, bool SkipSpellCardAnnouncement = false, float ExtraCD = 0.0)
{
	SSB_Ability Spell = new SSB_Ability();

	Spell.Chance = Chance;
	Spell.MaxUses = MaxUses;
	Spell.ActivationFunction = ActivationFunction;
	Spell.FilterFunction = FilterFunction;
	Spell.SetName(name);
	Spell.IsCard = IsSpellCard;
	Spell.SkipCardSound = SkipSpellCardAnnouncement;
	Spell.ExtraCD = ExtraCD;

	return Spell;
}

public void SSB_DeleteAbilities()
{
	for (int i = 0; i < 4; i++)
	{
		if (SSB_SpellCards[i] != null)
		{
			for (int spell = 0; spell < GetArraySize(SSB_SpellCards[i]); spell++)
			{
				SSB_Ability ability = GetArrayCell(SSB_SpellCards[i], spell);
				ability.Delete();
			}
		}

		if (SSB_Specials[i] != null)
		{
			for (int special = 0; special < GetArraySize(SSB_Specials[i]); special++)
			{
				SSB_Ability ability = GetArrayCell(SSB_Specials[i], special);
				ability.Delete();
			}
		}

		delete SSB_SpellCards[i];
		delete SSB_Specials[i];
	}
}

bool SSB_UsingAbility[MAXENTITIES];
bool SSB_Paused[MAXENTITIES];

methodmap SupremeSpookmasterBones < CClotBody
{
	property bool UsingAbility
	{
		public get() { return SSB_UsingAbility[this.index]; }
		public set(bool value) { SSB_UsingAbility[this.index] = value; }
	}

	public void Pause()
	{
		SSB_Paused[this.index] = true;
		this.StopPathing();
		this.m_bPathing = false;
	}

	public void Unpause()
	{
		SSB_Paused[this.index] = false;
		this.StartPathing();
		this.m_bPathing = true;
	}

	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayGibSound()");
		#endif
	}

	public void PlayIntroSound()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBIntro_Sounds) - 1);
		EmitSoundToAll(g_SSBIntro_Sounds[rand], _, _, 120);
		EmitSoundToAll(SND_SPAWN_ALERT, _, _, _, _, 0.8);
		CPrintToChatAll(g_SSBIntro_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayIntroSound()");
		#endif
	}

	public void PlayMinorLoss()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBMinorWin_Sounds) - 1);
		EmitSoundToAll(g_SSBMinorWin_Sounds[rand], _, _, 120);
		EmitSoundToAll(SND_DESPAWN);
		CPrintToChatAll(g_SSBMinorWin_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayMinorLoss()");
		#endif
	}

	public void PlayGenericSpell()
	{
		EmitSoundToAll(g_SSBGenericSpell_Sounds[GetRandomInt(0, sizeof(g_SSBGenericSpell_Sounds) - 1)], _, _, 120);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayGenericSpell()");
		#endif
	}

	public void PlayDeathMagnetic()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBPull_Sounds) - 1);
		EmitSoundToAll(g_SSBPull_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBPull_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayDeathMagnetic()");
		#endif
	}

	public void CalculateNextSpecial()
	{
		SSB_NextSpecial[this.index] = GetGameTime(this.index) + GetRandomFloat(SSB_SpecialCDMin[SSB_WavePhase], SSB_SpecialCDMax[SSB_WavePhase]);
	}

	public void CalculateNextSpellCard()
	{
		SSB_NextSpell[this.index] = GetGameTime(this.index) + GetRandomFloat(SSB_SpellCDMin[SSB_WavePhase], SSB_SpellCDMax[SSB_WavePhase]);
	}

	public bool IsSpecialReady()
	{
		if (SSB_Specials[SSB_WavePhase] == null)
			return false;
		
		if (GetArraySize(SSB_Specials[SSB_WavePhase]) < 1)
			return false;

		return SSB_NextSpecial[this.index] <= GetGameTime(this.index) && !this.UsingAbility;
	}

	public bool IsSpellReady()
	{
		if (SSB_SpellCards[SSB_WavePhase] == null)
			return false;
		
		if (GetArraySize(SSB_SpellCards[SSB_WavePhase]) < 1)
			return false;

		return SSB_NextSpell[this.index] <= GetGameTime(this.index) && !this.UsingAbility;
	}

	public void ActivateSpecial(int target, int specific = -1)
	{
		ArrayList clone = SSB_Specials[SSB_WavePhase].Clone();

		bool success = false;
		int activated = -1;
		SSB_Ability chosen;

		//First: Attempt to use a random ability, provided we do not have a specific ability to force.
		while (!success && GetArraySize(clone) > 0 && specific == -1)
		{
			activated = GetRandomInt(0, GetArraySize(clone) - 1);

			if (activated != SSB_LastSpecial[this.index])
			{
				chosen = GetArrayCell(clone, activated);
				success = chosen.Activate(this, target, false);
			}

			RemoveFromArray(clone, activated);
		}

		delete clone;

		//Second: Either we failed to successfully activate any of our random options, or we specified a specific ability to activate.
		//In the former case, force the default ability to activate. Otherwise, activate the specified ability.
		if (!success)
		{
			activated = specific > -1 ? specific : SSB_DefaultSpecial[SSB_WavePhase];
			chosen = GetArrayCell(SSB_Specials[SSB_WavePhase], activated);
			chosen.Activate(this, target, true);
		}

		SSB_LastSpecial[this.index] = activated;
		this.CalculateNextSpecial();

		if (success && chosen.ExtraCD != 0.0)
		{
			SSB_NextSpecial[this.index] += chosen.ExtraCD;
		}
	}

	public void CastSpell(int target, int specific = -1)
	{
		ArrayList clone = SSB_SpellCards[SSB_WavePhase].Clone();

		bool success = false;
		int activated = -1;
		SSB_Ability chosen;

		//First: Attempt to use a random ability, provided we do not have a specific ability to force.
		while (!success && GetArraySize(clone) > 0 && specific == -1)
		{
			activated = GetRandomInt(0, GetArraySize(clone) - 1);

			if (activated != SSB_LastSpell[this.index] || activated == SSB_DefaultSpell[SSB_WavePhase])
			{
				chosen = GetArrayCell(clone, activated);
				success = chosen.Activate(this, target, false);
			}

			RemoveFromArray(clone, activated);
		}

		delete clone;

		//Second: Either we failed to successfully activate any of our random options, or we specified a specific ability to activate.
		//In the former case, force the default ability to activate. Otherwise, activate the specified ability.
		if (!success)
		{
			activated = specific > -1 ? specific : SSB_DefaultSpell[SSB_WavePhase];
			chosen = GetArrayCell(SSB_SpellCards[SSB_WavePhase], activated);
			success = chosen.Activate(this, target, true);
		}

		if (success)
		{
			SSB_LastSpell[this.index] = (activated == SSB_DefaultSpell[SSB_WavePhase] ? -1 : activated);
			this.CalculateNextSpellCard();

			if (chosen.ExtraCD != 0.0)
			{
				SSB_NextSpell[this.index] += chosen.ExtraCD;
			}
		}
	}

	public int GetAbilityByName(char name[255])
	{
		int index = -1;

		for (int i = 0; i < GetArraySize(SSB_Specials[SSB_WavePhase]); i++)
		{
			SSB_Ability check = GetArrayCell(SSB_Specials[SSB_WavePhase], i);
			char checkName[255];
			check.GetName(checkName);

			if (StrEqual(name, checkName))
			{
				index = i;
				break;
			}
		}

		return index;
	}

	public int GetSpellByName(char name[255])
	{
		int index = -1;
		
		for (int i = 0; i < GetArraySize(SSB_SpellCards[SSB_WavePhase]); i++)
		{
			SSB_Ability check = GetArrayCell(SSB_SpellCards[SSB_WavePhase], i);
			char checkName[255];
			check.GetName(checkName);

			if (StrEqual(name, checkName))
			{
				index = i;
				break;
			}
		}

		return index;
	}
	
	public SupremeSpookmasterBones(int client, float vecPos[3], float vecAng[3], int ally)
	{
		SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(CClotBody(vecPos, vecAng, MODEL_SSB, BONES_SUPREME_SCALE, BONES_SUPREME_HP, ally, false, true, true, true));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = true;

		func_NPCDeath[npc.index] = view_as<Function>(SupremeSpookmasterBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SupremeSpookmasterBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SupremeSpookmasterBones_ClotThink);

		int iActivity = npc.LookupActivity("ACT_STAND_NO_HAMMER");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", BONES_SUPREME_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_Think, SupremeSpookmasterBones_ClotThink);

		npc.StartPathing();
		npc.PlayIntroSound();

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "SSB Spawn");
			}
		}

		b_thisNpcIsARaid[npc.index] = true;
		SSB_LastSpell[npc.index] = -1;
		ParticleEffectAt(vecPos, PARTICLE_SSB_SPAWN, 3.0);

		int wave = ZR_GetWaveCount() + 1;
		if (wave <= 15)
			SSB_WavePhase = 0;
		else if (wave <= 30)
			SSB_WavePhase = 1;
		else if (wave <= 45)
			SSB_WavePhase = 2;
		else
			SSB_WavePhase = 3;

		npc.m_flSpeed = BONES_SUPREME_SPEED[SSB_WavePhase];

		//COPY THIS WHEN MAKING SPIN 2 WIN'S CODE
		/*npc.m_flSpeed = Spin_Speed[SSB_WavePhase];
		npc.GetBaseNPC().flFrictionSideways = Spin_Friction[SSB_WavePhase];
		npc.GetBaseNPC().flFrictionForward = Spin_Friction[SSB_WavePhase];
		npc.GetBaseNPC().flAcceleration = Spin_Acceleration[SSB_WavePhase];*/

		npc.CalculateNextSpecial();
		npc.CalculateNextSpellCard();
		npc.UsingAbility = false;

		return npc;
	}
}

public void SupremeSpookmasterBones_ClotThink(int iNPC)
{
	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(iNPC);
	
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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float pos[3], targPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		//float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
		if (!SSB_Paused[npc.index])
		{
			npc.StartPathing();
			NPC_SetGoalEntity(npc.index, closest);
			npc.FaceTowards(targPos, 225.0);
			npc.m_bPathing = true;
		}

		if (npc.IsSpecialReady())
		{
			npc.ActivateSpecial(closest);
		}
		else if (npc.IsSpellReady())
		{
			npc.CastSpell(closest);
		}
		else /*if (flDistanceToTarget <= SSB_MeleeRange && GetGameTime(npc.index) >= npc.m_flNextMeleeAttack)*/
		{
			//TODO: Generic melee attack if the target is close enough
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action SupremeSpookmasterBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void SupremeSpookmasterBones_NPCDeath(int entity)
{
	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(entity);

	npc.PlayMinorLoss();	//TODO: He needs to have a more cinematic death sequence when defeated on wave 60.
	SDKUnhook(entity, SDKHook_Think, SupremeSpookmasterBones_ClotThink);
		
	npc.RemoveAllWearables();
	RemoveEntity(entity);
	//AcceptEntityInput(npc.index, "KillHierarchy");
}

int SSB_CreateProjectile(SupremeSpookmasterBones owner, char model[255], float pos[3], float ang[3], float velocity, float scale, DHookCallback CollideCallback, int skin = 0)
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
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);

		RequestFrame(SSB_DeleteIfOwnerDisappears, EntIndexToEntRef(prop));
		
		return prop;
	}
	
	return -1;
}

stock int SSB_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
			
			return part1;
		}
	}
	
	return -1;
}

stock void PredictSubjectPositionForProjectiles_NoNPCNeeded(float startPos[3], int subject, float projectile_speed, float offset = 0.0, float pathTarget[3])
{
	float botPos[3];
	botPos = startPos;

	botPos[2] += offset;
	
	float subjectPos[3];
	WorldSpaceCenter(subject, subjectPos);
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = (0.0001) + ( range / ( projectile_speed + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	/*
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	*/
	//replace this with a trace.
}