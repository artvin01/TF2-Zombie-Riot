#pragma semicolon 1
#pragma newdecls required

static float BONES_SUPREME_SPEED[4] = { 280.0, 290.0, 300.0, 320.0 };
static float SSB_RaidTime[4] = { 200.0, 220.0, 240.0, 260.0 };
static float SSB_RaidPower[4] = { 0.001, 0.01, 0.1, 1.0 };

#define BONES_SUPREME_SCALE				"1.45"
#define BONES_SUPREME_SKIN				"1"
#define BONES_SUPREME_HP				"35000"
#define MODEL_SKULL						"models/props_mvm/mvm_human_skull_collide.mdl"
#define MODEL_HIDDEN_PROJECTILE			"models/weapons/w_models/w_drg_ball.mdl"

#define SND_SPAWN_ALERT			"misc/halloween/merasmus_appear.wav"
#define SND_DESPAWN				"misc/halloween/merasmus_disappear.wav"
#define SND_FIREBALL_CAST		")misc/halloween/spell_meteor_cast.wav"
#define SND_FIREBALL_EXPLODE	")misc/halloween/spell_fireball_impact.wav"
#define SND_HOMING_ACTIVATE		")misc/halloween/spell_mirv_cast.wav"
#define SND_BARRAGE_HIT			")weapons/flare_detonator_explode_world.wav"
#define SND_BARRAGE_SPAWN		")weapons/bison_main_shot_01.wav"
#define SND_BARRAGE_LAUNCH		")weapons/flare_detonator_launch.wav"
#define SND_PULL_ACTIVATED		")misc/halloween/merasmus_spell.wav"
#define SND_PLAYER_PULLED		")misc/halloween/merasmus_stun.wav"
#define SND_COSMIC_STRIKE		")misc/halloween/spell_spawn_boss.wav"
#define SND_COSMIC_MARKED		")misc/halloween/hwn_bomb_flash.wav"
#define SND_RING_MARKED			")misc/halloween/spell_teleport.wav"
#define SND_TARTARUS_SLOW		"weapons/breadmonster/gloves/bm_gloves_on.wav"
#define SND_TARTARUS_BEGIN		")misc/halloween/spell_skeleton_horde_rise.wav"
#define SND_MEGASKULLBLAST		")misc/doomsday_missile_explosion.wav"
#define SND_SKULL_MINIFIRE		")weapons/pomson_fire_01.wav"
#define SND_SKULL_SDBEEP		")misc/halloween/spelltick_01.wav"
#define SND_SKULL_PORTAL		")misc/halloween/spell_teleport.wav"
#define SND_SKULL_SPAWN			")misc/halloween/spell_meteor_cast.wav"
#define SND_NECROBLAST_EXTRA_1	")misc/halloween/spell_spawn_boss.wav"
#define SND_NECROBLAST_EXTRA_2	")items/halloween/crazy02.wav"
#define SND_NECROBLAST_EXTRA_3	")items/cart_explode.wav"
#define SND_SUMMON_BLAST		")misc/halloween/spell_spawn_boss.wav"
#define SND_SUMMON_SPAWN		")misc/halloween/merasmus_appear.wav"
#define SND_SUMMON_INTRO		")misc/halloween/gotohell.wav"
#define SND_SUMMON_LOOP			")ambient/halloween/underground_wind_lp_02.wav"
#define SND_SPIN_WHOOSH			")misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_SPIN_HIT			")misc/halloween/strongman_fast_impact_01.wav"
#define SND_NECROBLAST_CHARGEUP		"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_chargeup.mp3"
#define SND_NECROBLAST_BIGBANG		"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_extra.mp3"
#define SND_SPIN2WIN_ACTIVE		")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_spin2win_active.mp3"
#define SND_STUNNED				"misc/halloween/merasmus_stun.wav"
#define SND_HELL_STOMP			")player/taunt_tank_shoot.wav"
#define SND_HELL_BEGIN			")items/halloween/banshee01.wav"
#define SND_HELL_END			")misc/halloween/merasmus_disappear.wav"
#define SND_HELL_FIRE			")misc/halloween/spell_meteor_cast.wav"

#define PARTICLE_OBJECTSPAWN_1				"merasmus_spawn_flash"
#define PARTICLE_OBJECTSPAWN_2				"merasmus_spawn_flash2"
#define PARTICLE_GREENBLAST_SSB				"merasmus_dazed_explosion"
#define PARTICLE_EXPLOSION_FIREBALL_RED		"spell_fireball_tendril_parent_red"
#define PARTICLE_EXPLOSION_FIREBALL_BLUE	"spell_fireball_tendril_parent_blue"
#define PARTICLE_FIREBALL_RED				"spell_fireball_small_red"
#define PARTICLE_FIREBALL_BLUE				"spell_fireball_small_blue"
#define PARTICLE_LASER_RED					"raygun_projectile_red"
#define PARTICLE_LASER_BLUE					"raygun_projectile_blue"
#define PARTICLE_LASER_RED_PREDICT			"raygun_projectile_red_crit"
#define PARTICLE_LASER_BLUE_PREDICT			"raygun_projectile_blue_crit"
#define PARTICLE_BARRAGE_HIT				"nutsnbolts_repair"
#define PARTICLE_TARTARUS					"utaunt_hands_purple_parent"
#define PARTICLE_TARTARUS_BEGIN				"skull_island_explosion"
#define PARTICLE_SPAWNVFX_GREEN				"duck_collect_green"
#define PARTICLE_MEGASKULL					"eyeboss_team_red"
#define PARTICLE_MEGASKULLBLAST				"fireSmoke_collumn_mvmAcres"
#define PARTICLE_SKULL_MINI					"flaregun_trail_red"
#define PARTICLE_PORTAL_PURPLE				"eyeboss_tp_vortex"
#define PARTICLE_SUMMON_VANISH				"ghost_appearation"
#define PARTICLE_SPIN_TRAIL_1				"halloween_pickup_active_green"//"critgun_weaponmodel_red"
#define PARTICLE_SPIN_TRAIL_2				"halloween_pickup_active_green"//"critgun_weaponmodel_blu"
#define PARTICLE_STUNNED					"merasmus_dazed"
#define PARTICLE_HELLISHERE_HEAD			"spell_fireball_small_blue"

static char Volley_HomingSFX[][] = {
	")items/halloween/witch01.wav",
	")items/halloween/witch02.wav",
	")items/halloween/witch03.wav"
};

static char Hell_HomingSFX[][] = {
	")ambient/halloween/male_scream_03.wav",
	")ambient/halloween/male_scream_04.wav",
	")ambient/halloween/male_scream_05.wav",
	")ambient/halloween/male_scream_06.wav",
	")ambient/halloween/male_scream_07.wav",
	")ambient/halloween/male_scream_08.wav",
	")ambient/halloween/male_scream_09.wav",
	")ambient/halloween/male_scream_10.wav"
};

static char Cross_BlastSFX[][] = {
	")misc/halloween_eyeball/book_exit.wav",
	")misc/halloween/merasmus_hiding_explode.wav",
	")misc/halloween/spell_lightning_ball_cast.wav"
};

static char Skull_LaughSFX[][] = {
	")vo/halloween_boss/knight_laugh01.mp3",
	")vo/halloween_boss/knight_laugh02.mp3",
	")vo/halloween_boss/knight_laugh03.mp3",
	")vo/halloween_boss/knight_laugh04.mp3"
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

/*static char g_SSBBigHit_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}:OH FUCK YOU, YOU PIECE OF SHIT!",
	"{haunted}Supreme Spookmaster Bones{default}:OOOHHH, I HATE THAT ATTACK!",
	"{haunted}Supreme Spookmaster Bones{default}:OH, YOU SON OF A FUCKING BITCH!"
};*/

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

static char g_SSBGenericWindup_Sounds[][] = {
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericwindup_1.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericwindup_2.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericwindup_3.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericwindup_4.mp3"
};

static char g_SSBGenericWindup_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}YEEEESSSSS...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}Get ready!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}Here we go!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}Are you ready?{default}"
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

static char g_SSBStunned_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_stunned_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_stunned_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_stunned_3.mp3"
};

static char g_SSBStunned_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {yellow}UH, W-w-w-WHAT?!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {yellow}Oh, woah woah woah, WOAH WOAH WOAH, WOAHWOAHWOAHWOAHWOAHWOAH, dude, woah, hello!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {yellow}Oooohhh no.... what the fuck?{default}"
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

/*static char g_SSBKill_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: He will never walk again.",
	"{haunted}Supreme Spookmaster Bones{default}: Oh! Oh, I broke his fucking leg!",
	"{haunted}Supreme Spookmaster Bones{default}: Oh my God, he-he's a dead man.",
    "{haunted}Supreme Spookmaster Bones{default}: HA HA HA HAAAA! Suck it.",
    "{haunted}Supreme Spookmaster Bones{default}: He's so useless!"
};*/

static char g_SSBNecroBlast_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_3.mp3"
};

static char g_SSBNecroBlast_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}FUCK YOU!!!!!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}BOOM, BABY!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}DAMN!!!!!{default}"
};

static char g_SSBNecroBlastWarning_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_prepare_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_prepare_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroticblast_prepare_3.mp3"
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

/*static char g_SSBLoss_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}Life sucks, and then you fucking die.{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {red}Good job, guys. Good job.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {red}Mmhmhahahahahahahahahahahaaaa... AAAAAAHAHAHAHAHAHAHAHA!{default}"
};*/

static char g_SSBLossEasterEgg_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win_waytoolong.mp3"
};

/*static char g_SSBLossEasterEgg_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}YO, SHIT FOR BRAINS! What GOD DAMN color is this? HUH?! YOU FUCKING BLIND MOTHERFUCKER!{default}",
    "{red}Who the FUCK do you think you are? Coming here and shitting in MY mailbox, playing MY God damn video games? You're gonna learn about colors, you dumb FORESKIN.{default}"
};*/

/*static char g_SSBSupremeSlayerIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: ...",
	"......",
	"..........",
	"{unusual}Get ready to receive some unholy spirit.{default}"
};*/

/*static char g_SSBFinaleIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: Well, I'd be lying if I said this hasn't been a fun time.",
	"I'd also be lying if I said you've all done anything less than a {unusual}superb{default} job making it this far. {green}Good job!{default}",
	"Honestly, I thought you'd all have been long dead by now.",
	"I mean, I am quite literally the {red}God of the Dead{default}, I'm kind of an expert when it comes to people dying.",
	"So yeah, congrats on defying my expectations!",
	"You just seem to be forgetting one tiny thing...",
	"...",
	"{crimson}You can't outrun the devil.",
	"{darkgrey}Now Playing: {community}King Stephen {default}| {lightgreen}You Can't Outrun the Devil"
};

static char g_SSBVictorySpeech_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}ALRIGHT, ALRIGHT, I GET IT! CHILL OUT!{default}",
	"Do you have any idea how much {red}work{default} this whole zombie apocalypse thing has given me?",
	//"I don't just sit down there in the underworld and boss people around all day, you know.",
	"Every time someone dies, they show up down in my realm and join a nice, orderly queue.",
	"When they get to the front of that queue, I have to {yellow}judge them personally{default}. That means I have to read their entire life story. {red}It's a lot of paperwork!{default}",
	//"Dealing with just one of you {olive}mortals{default}can take up to an hour, sometimes even longer!",
	"Do you have {crimson}ANY IDEA{default} how much overtime I have to clock in for you people every time there's a {orange}war{default}, or an {red}apocalyptic event{default} like this?",
	"I haven't had so much as a {orange}single minute{default} of free time since those {red}bastard cat people{default} let their silly little infection breach containment, and that's not even mentioning all of the trouble caused by those {vintage}disgusting fish people{default}.",
	"I used to think the {green}Ruanians{default} and their magic were proof that you mortals weren't ALL bad, but even THEY messed up by somehow managing to build {haunted}a robot that can be infected by a disease{default}... Like, WHAT? {red}HOW DO YOU MESS UP THAT BADLY?{default}",
	"So I thought, {haunted}''hey! If there are no more mortals, there won't be any mortals that I need to judge!''{default} Brilliant idea, right? At least, I thought so.",
	"...But fine, I'll admit it: Maybe trying to {red}wipe out all of humanity{default} wasn't the {yellow}best{default} way to get some relief from my day job.",
	//"You people seem {green}more than capable{default}. I guess I'll just go back to my office and let you all put a stop to this zombie ordeal on your own.",
	"...",
	"Right, I guess you're probably {yellow}expecting something{default} for all of that. And I suppose I probably should give you something for your trouble...",
	"{green}Here. {default}Call this number if you ever need help, and I'll {teal}send up some of my guys to help.{default}",
	"You'd better put a stop to this infection, though. After all, if I see you in my queue before this zombie apocalypse is over...",
	"{crimson}You're going to have a very bad time in the afterlife."
};*/

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
	for (int i = 0; i < (sizeof(g_SSBNecroBlast_Sounds));   i++) { PrecacheSound(g_SSBNecroBlast_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBNecroBlastWarning_Sounds));   i++) { PrecacheSound(g_SSBNecroBlastWarning_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSpin2Win_Sounds));   i++) { PrecacheSound(g_SSBSpin2Win_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSummonIntro_Sounds));   i++) { PrecacheSound(g_SSBSummonIntro_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLoss_Sounds));   i++) { PrecacheSound(g_SSBLoss_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLossEasterEgg_Sounds));   i++) { PrecacheSound(g_SSBLossEasterEgg_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBGenericWindup_Sounds));   i++) { PrecacheSound(g_SSBGenericWindup_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBStunned_Sounds));   i++) { PrecacheSound(g_SSBStunned_Sounds[i]);   }

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
	PrecacheSound(SND_COSMIC_STRIKE);
	PrecacheSound(SND_COSMIC_MARKED);
	PrecacheSound(SND_RING_MARKED);
	PrecacheSound(SND_TARTARUS_SLOW);
	PrecacheSound(SND_TARTARUS_BEGIN);
	PrecacheSound(SND_MEGASKULLBLAST);
	PrecacheSound(SND_SKULL_MINIFIRE);
	PrecacheSound(SND_SKULL_SDBEEP);
	PrecacheSound(SND_SKULL_PORTAL);
	PrecacheSound(SND_SKULL_SPAWN);
	PrecacheSound(SND_NECROBLAST_EXTRA_1);
	PrecacheSound(SND_NECROBLAST_EXTRA_2);
	PrecacheSound(SND_NECROBLAST_EXTRA_3);
	PrecacheSound(SND_SUMMON_BLAST);
	PrecacheSound(SND_SUMMON_SPAWN);
	PrecacheSound(SND_SUMMON_INTRO);
	PrecacheSound(SND_SUMMON_LOOP);
	PrecacheSound(SND_SPIN_WHOOSH);
	PrecacheSound(SND_SPIN_HIT);
	PrecacheSound(SND_NECROBLAST_CHARGEUP);
	PrecacheSound(SND_NECROBLAST_BIGBANG);
	PrecacheSound(SND_SPIN2WIN_ACTIVE);
	PrecacheSound(SND_STUNNED);
	PrecacheSound(SND_HELL_BEGIN);
	PrecacheSound(SND_HELL_END);
	PrecacheSound(SND_HELL_FIRE);
	PrecacheSound(SND_HELL_STOMP);

	for (int i = 0; i < (sizeof(Volley_HomingSFX));   i++) { PrecacheSound(Volley_HomingSFX[i]);   }
	for (int i = 0; i < (sizeof(Hell_HomingSFX));   i++) { PrecacheSound(Hell_HomingSFX[i]);   }
	for (int i = 0; i < (sizeof(Cross_BlastSFX));   i++) { PrecacheSound(Cross_BlastSFX[i]);   }
	for (int i = 0; i < (sizeof(Skull_LaughSFX));   i++) { PrecacheSound(Skull_LaughSFX[i]);   }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supreme Spookmaster Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ssb");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = Summon_SSB;
	NPC_Add(data);

	SSB_PrepareAbilities();
}

static any Summon_SSB(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SupremeSpookmasterBones(vecPos, vecAng, ally);
}

//The following just stores/restores the target NPC's speed, friction, and acceleration for temporary changes.
//I ended up needing to do this in multiple cases, so I refactored it into this.
float SSB_Movement_Data_OldSpeed[MAXENTITIES];
float SSB_Movement_Data_OldFrictionSideways[MAXENTITIES];
float SSB_Movement_Data_OldFrictionForward[MAXENTITIES];
float SSB_Movement_Data_OldAcceleration[MAXENTITIES];

public void SSB_Movement_Data_ReadValues(SupremeSpookmasterBones ssb)
{
	SSB_Movement_Data_OldSpeed[ssb.index] = ssb.m_flSpeed;
	SSB_Movement_Data_OldFrictionSideways[ssb.index] = ssb.GetBaseNPC().flFrictionSideways;
	SSB_Movement_Data_OldFrictionForward[ssb.index] = ssb.GetBaseNPC().flFrictionForward;
	SSB_Movement_Data_OldAcceleration[ssb.index] = ssb.GetBaseNPC().flAcceleration;
}

public void SSB_Movement_Data_RestoreFromValues(SupremeSpookmasterBones ssb)
{
	ssb.m_flSpeed = SSB_Movement_Data_OldSpeed[ssb.index];
	ssb.GetBaseNPC().flFrictionSideways = SSB_Movement_Data_OldFrictionSideways[ssb.index];
	ssb.GetBaseNPC().flFrictionForward = SSB_Movement_Data_OldFrictionForward[ssb.index];
	ssb.GetBaseNPC().flAcceleration = SSB_Movement_Data_OldAcceleration[ssb.index];
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
float Cross_DMG[4] = { 400.0, 600.0, 800.0, 1000.0 };		//Laser damage.
float Cross_EntityMult[4] = { 2.0, 4.0, 6.0, 8.0 };			//Amount to multiply damage dealt by lasers to entities.
float Cross_Range[4] = { 1200.0, 2400.0, 3600.0, 4800.0 };	//Laser range.
float Cross_Width[4] = { 120.0, 90.0, 70.0, 60.0 };			//Laser hitbox width.
float Cross_Delay[4] = { 3.0, 2.75, 2.5, 2.25 };			//Delay until the lasers are fired once this Spell Card is activated.
float Cross_Space[4] = { 60.0, 45.0, 30.0, 20.0 };			//Angles between each laser fired by this ability. Lower = more lasers are fired. Number of lasers = 360 / this. Players CAN be hit by multiple lasers.
bool SSB_LaserHit[MAXENTITIES] = { false, ... };			//Used exclusively to see if an entity was hit by any of SSB's laser effects.
float Cross_Pos[MAXENTITIES][3];		//The position this ability was activated at. Used so indicator beams are accurate.

//SPELL CARD #3 - CHAOS BARRAGE: SSB launches a bunch of weak laser projectiles in random directions. These lasers deal no damage and do not touch players.
//After a short delay, the lasers freeze in place. Then, after another delay, the lasers fly towards whoever is closest and deal damage on contact.
int Barrage_NumWaves[4] = { 8, 9, 10, 12 };							//The number of waves to fire.
int Barrage_PerWave[4] = { 2, 2, 3, 3 };							//The number of projectiles fired per wave.
float Barrage_WaveDelay[4] = { 0.2, 0.15, 0.1, 0.05 };				//Delay between projectile waves.
float Barrage_InitialVelocity[4] = { 400.0, 400.0, 400.0, 400.0 };	//Projectile velocity before they pause.
float Barrage_PauseDelay[4] = { 1.0, 0.86, 0.76, 0.66};				//Time until projectiles pause.
float Barrage_PauseDuration[4] = {1.66, 1.5, 1.33, 1.2 };			//Projectile pause duration.
float Barrage_Velocity[4] = { 1200.0, 1200.0, 1400.0, 1600.0 }; 	//Projectile velocity after they unpause.
float Barrage_DMG[4] = { 20.0, 25.0, 30.0, 40.0 };					//Projectile base damage.
bool Barrage_Prediction[4] = { false, false, true, true };			//Whether or not the projectiles should predict target movement once they become lethal.
float f_BarrageProjectileDMG[MAXENTITIES];							//Ignore this.

//SPELL CARD #4 - DEATH MAGNETIC: SSB freezes in place and begins conjuring a spell. When ready: all players within line-of-sight are pulled to SSB.
//If at least one player was pulled, this spell forces one of the following abilities to be used immediately, ignoring cooldowns and max usage:
//Cursed Cross, Soul Harvester, Spin to Win, MEGA MORTIS
float Death_Delay[4] = { 4.0, 3.75, 3.5, 3.0 };				//Delay before the pull activates.
float Death_Radius[4] = { 1000.0, 1050.0, 1100.0, 1150.0 };	//Maximum radius in which the pull can be activated.

//SPELL CARD #5 - NECROTIC BOMBARDMENT: SSB chooses up to X player(s) at random and marks the spot they are currently at. Y seconds later, that spot is struck by a necrotic bolt
//from the sky, triggering an explosion. This is repeated for all targeted player(s) an additional Z time(s).
//PS: I'm using the SSB_ prefix for these variables because otherwise we interfere with the Cosmic Terror weapon.
int SSB_Cosmic_NumTargets[4] = { 3, 6, 9, 12 };						//The maximum number of players who can be marked by the ability.'
int SSB_Cosmic_NumStrikes[4] = { 5, 6, 7, 8 };						//The number of times to attempt to strike marked playes.
float SSB_Cosmic_Delay[4] = { 2.0, 1.75, 1.5, 1.25 };				//Duration until the strikes land.
float SSB_Cosmic_DMG[4] = { 150.0, 300.0, 600.0, 900.0 };			//Damage dealt by strikes.
float SSB_Cosmic_Radius[4] = { 150.0, 180.0, 220.0, 260.0 };		//Damage radius.
float SSB_Cosmic_Falloff_Radius[4] = { 0.25, 0.15, 0.05, 0.0 };		//Maximum falloff percentage, based on radius.
float SSB_Cosmic_Falloff_MultiHit[4] = { 0.8, 0.85, 0.9, 0.95 };	//Amount to multiply damage dealt by the strikes per entity hit.
float SSB_Cosmic_EntityMult[4] = { 4.0, 6.0, 8.0, 10.0 };			//Amount to multiply damage dealt to entities.

//SPELL CARD #6 - RING OF TARTARUS: The locations of up to X player(s) are marked with a purple ring. After Y second(s), these rings activate and will begin to slow down
//and rapidly deal damage to any enemies within its radius. Victims must be on the ground.
int Ring_NumTargets[4] = { 2, 4, 6, 8 };				//The maximum number of players to spawn rings on.
float Ring_Delay[4] = { 4.0, 4.0, 4.0, 4.0 };			//Duration until the rings activate.
float Ring_Duration[4] = { 8.0, 10.0, 12.0, 14.0 };		//Ring lifespan.
float Ring_DMG[4] = { 1.0, 2.0, 3.0, 5.0 };				//Ring damage per 0.1s.
float Ring_Radius[4] = { 200.0, 250.0, 300.0, 350.0 };	//Ring radius.
float Ring_Height[4] = { 40.0, 40.0, 40.0, 40.0 };		//Ring height.
float Ring_SlowAmt[4] = { 0.5, 0.66, 0.75, 0.85 };		//Percentage to reduce the movement speed of any enemy within a ring.

//SPELL CARD #7 - GAZE UPON THE SKULL: SSB launches one big but very slow skull, which homes in on the nearest enemy.
//While active, the skull rapidly fires smaller, weaker homing projectiles in random directions.
//If the skull collides with something (or automatically after X seconds), it will trigger a huge explosion.
float Skull_SpawnDelay[4] = { 3.0, 3.0, 3.0, 3.0 };					//Time until the big skull spawns.
float Skull_Velocity[4] = { 240.0, 240.0, 240.0, 240.0 };			//Velocity of the big skull.
float Skull_DMG[4] = { 400.0, 800.0, 1600.0, 3200.0 };				//Base damage of the big skull.
float Skull_Radius[4] = { 400.0, 450.0, 500.0, 500.0 };				//Explosion radius of the big skull.
float Skull_Falloff_Radius[4] = { 0.5, 0.5, 0.5, 0.5 };				//Falloff-based radius of the big skull.
float Skull_Falloff_MultiHit[4] = { 0.66, 0.75, 0.8, 0.85 };		//Amount to multiply the big skull's explosion damage for each target it hits.
float Skull_EntityMult[4] = { 4.0, 8.0, 12.0, 16.0 };				//Amount to multiply the big skull's explosion damage against entities.
float Skull_Duration[4] = { 8.0, 10.0, 12.0, 14.0 };				//Duration until the big skull automatically detonates.
float Skull_SelfDestructDelay[4] = { 3.0, 3.0, 3.0, 3.0 };			//When the big skull reaches the end of its duration: how long should it pause before exploding?
float Skull_HomingAngle[4] = { 60.0, 65.0, 70.0, 80.0 };		//Big skull's maximum homing angle.
float Skull_HomingPerSecond[4] = { 9.0, 10.0, 11.0, 12.0 };		//Number of times per second for thee big skull to readjust its velocity for the sake of homing in on its target.
float Skull_MiniRate[4] = { 0.33, 0.33, 0.25, 0.15 };				//Number of seconds between mini projectiles fired by the skull.
float Skull_MiniVelocity[4] = { 600.0, 700.0, 800.0, 1000.0 };		//Velocity of the small projectiles fired by the big skull.
float Skull_MiniDMG[4] = { 15.0, 17.5, 20.0, 22.5 };				//Damage dealt by the small projectiles.
float Skull_MiniDuration[4] = {0.66, 0.66, 0.66, 0.66 };			//Lifespan of the small projectiles.
float Skull_MiniHomingAngle[4] = { 60.0, 70.0, 80.0, 90.0 };		//Small projectile max homing angle.
float Skull_MiniHomingPerSecond[4] = {6.0, 7.0, 8.0, 9.0 };			//Number of times per second for the small projectiles to readjust their velocity.
float Skull_MiniSpread[4] = { 16.0, 16.0, 16.0, 16.0 };				//Degrees of random spread for the small projectiles when fired.

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
float Necrotic_Delay[4] = { 1.5, 1.35, 1.2, 1.15 };				//Time until the laser is fired after SSB enters his stance. Note that 1.16 is ALWAYS added to this for the intro sequence.
float Necrotic_DMG[4] = { 2400.0, 6000.0, 15000.0, 37500.0 };	//Damage dealt by the laser.
float Necrotic_EntityMult[4] = { 10.0, 10.0, 10.0, 10.0 };		//Amount to multiply damage dealt by the laser to entities.
float Necrotic_Width[4] = { 400.0, 475.0, 550.0, 625.0 };		//Laser width, in hammer units.
float Necrotic_SelfKB[4] = { 800.0, 1200.0, 1600.0, 2000.0 };	//Amount of knockback taken by SSB when the laser is fired.

//SPOOKY SPECIAL #2 - MASTER OF THE DAMNED: SSB takes an immobile stance where he rapidly summons skeletal minions to fight for him. These minions are summoned by telegraphed
//green thunderbolts which deal damage in the area around the minion's spawn point.
int Summon_Count[4] = { 2, 3, 4, 5 };								//Number of minions summoned per summon interval.
float Summon_HPCost[4] = { 0.66, 0.4, 0.33, 0.25 };					//After losing this percentage of his max HP, SSB will immediately activate Master of the Damned the next time he takes damage.
float Summon_Max[4] = { 16.0, 25.0, 35.0, 45.0 };					//Maximum total summon value of minions summoned by SSB by this ability (lightning strikes will still occur once this cap is reached, but new minions will not be summoned).
float Summon_Duration[4] = { 6.5, 7.0, 7.5, 8.0 };					//Duration for which SSB should summon minions.
float Summon_Resistance[4] = { 0.5, 0.42, 0.33, 0.25 };				//Amount to multiply all damage taken by SSB while he is summoning.
float Summon_BonusTime[4] = { 10.0, 12.0, 14.0, 16.0 };				//Bonus time given to the mercenaries when SSB activates this ability.
float Summon_Radius[4] = { 600.0, 800.0, 1000.0, 1200.0 };			//Radius in which minions are summoned.
float Summon_Interval[4] = { 1.0, 0.8, 0.66, 0.5 };					//Time between summon waves.
float Summon_SpawnDelay[4] = { 0.66, 0.66, 0.66, 0.66 };			//Time after the thunderbolt is called until it hits its target and spawns a minion.
float Summon_ThunderDMG[4] = { 100.0, 200.0, 300.0, 400.0 };		//Damage dealt by thunderbolts.
float Summon_ThunderRadius[4] = { 120.0, 140.0, 160.0, 180.0 };		//Thunderbolt radius.
float Summon_ThunderEntityMult[4] = { 2.0, 4.0, 6.0, 8.0 };			//Amount to multiply damage dealt by thunderbolts to entities.
float Summon_ThunderFalloffMultiHit[4] = { 0.66, 0.75, 0.8, 0.8 };	//Amount to multiply damage dealt by thunderbolts for each target hit.
float Summon_ThunderFalloffRange[4] = { 0.66, 0.5, 0.33, 0.165 };	//Maximum damage falloff of thunderbolts, based on range.
float Summon_DamageTracker[MAXENTITIES];							//Don't touch this, it's just used to track how much damage SSB has taken since the last time he used this ability.

//SPOOKY SPECIAL #3 - SOUL HARVESTER: SSB takes an immobile stance where he raises his arms and attempts to drain the life of all nearby enemies, drawing them in as they rapidly
//take damage which is then given to SSB as healing. This ability is immune to damage falloff.
float Harvester_Delay[4] = { 4.0, 4.0, 4.0, 4.0 };							//Delay until the effects of this ability activate.
float Harvester_Duration[4] = { 6.0, 7.0, 8.0, 9.0 };						//Duration of the ability.
float Harvester_Radius[4] = { 600.0, 800.0, 1200.0, 1200.0 };				//Radius.
float Harvester_Resistance[4] = { 0.75, 0.7, 0.66, 0.5 };					//Amount to multiply damage dealt to SSB during this ability.
float Harvester_DMG[4] = { 10.0, 20.0, 35.0, 50.0 };						//Damage dealt per 0.1s to all enemies within Soul Harvester's radius.
float Harvester_EntityMult[4] = { 2.0, 4.0, 6.0, 8.0 };						//Amount to multiply damage dealt to entities.
float Harvester_HealRatio[4] = { 4.0, 6.0, 8.0, 10.0 };						//Amount to heal SSB per point of damage dealt by this attack. Note that he only heals when hitting players, not NPCs.
float Harvester_PullStrength[4] = { 400.0, 450.0, 500.0, 550.0 };			//Strength of the pull effect. Note that this is for point-blank, and is scaled downwards the further the target is.
float Harvester_MinPullStrengthMultiplier[4] = { 0.2, 0.25, 0.3, 0.35 };	//The minimum percentage of the pull force to use, depending on how far the target is. It's recommended to be at least a *little* bit above 0.0, because otherwise the knockback from the damage will outweigh the pull if you're far enough away and actually *push* you, making escape easier.

//SPOOKY SPECIAL #4 - HELL IS HERE: SSB takes - you guessed it - an immobile stance where he proudly stands up straight in a sardonic superman pose, with his head floating high 
//above his body. After a brief delay, his head begins to rapidly spin while firing homing skulls in all directions.
int Hell_Count[4] = { 3, 3, 2, 2 };									//Number of skulls fired per interval.
int Hell_MaxTargets[4] = { 8, 12, 16, 32 };							//Max targets hit by skull explosions.
float Hell_Delay[4] = { 1.66, 1.66, 1.66, 1.66 };					//Wind-up time.
float Hell_Duration[4] = { 6.0, 7.0, 8.0, 9.0 };					//Duration.
float Hell_Resistance[4] = { 0.33, 0.5, 0.5, 0.66 };				//Amount to multiply damage taken by SSB during this ability. This is backwards on purpose, I want him to have less resistance based on how hard this is to dodge.
float Hell_Interval[4] = { 1.0, 0.66, 0.33, 0.2 };					//Interval in which skulls are fired.
float Hell_Velocity[4] = { 360.0, 380.0, 400.0, 420.0 };			//Skull velocity.
float Hell_HomingDelay[4] = { 0.75, 0.625, 0.5, 0.375 };			//Time until the skulls begin to home in on targets.
float Hell_DMG[4] = { 60.0, 90.0, 160.0, 250.0 };					//Skull base damage.
float Hell_EntityMult[4] = { 2.0, 2.5, 3.0, 4.0 };					//Amount to multiply damage dealt by skulls to entities.
float Hell_Radius[4] = { 20.0, 20.0, 20.0, 20.0 };					//Skull explosion radius.
float Hell_Falloff_Radius[4] = { 0.66, 0.5, 0.33, 0.165 };			//Skull falloff, based on radius.
float Hell_Falloff_MultiHit[4] = {0.66, 0.76, 0.86, 1.0 }; 			//Amount to multiply explosion damage for each target hit.
float Hell_HomingAngle[4] = { 70.0, 72.5, 72.5, 75.0 };				//Skulls' maximum homing angle.
float Hell_HomingPerSecond[4] = { 7.0, 7.25, 7.5, 8.0 };			//Number of times per second for skulls to readjust their velocity for the sake of homing in on their target.
float Hell_Spread[4] = { 9.0, 10.0, 11.0, 12.0 };					//Random spread of skulls.
float Hell_Distance[4] = { 60.0, 80.0, 100.0, 120.0 };				//Distance to spread skulls apart when they spawn.
float Hell_SpinSpeed[4] = { 2.0, 4.0, 6.0, 8.0 };					//Amount to rotate the firing angle per frame.
static int Hell_Fireball[2049] = { -1, ... };

//SPOOKY SPECIAL #5 - SPIN 2 WIN: SSB pulls out his trusty Mortis Masher and begins to spin wildly. During this, he moves VERY quickly, but has his friction reduced, making
//him prone to overshooting his target.
float Spin_Delay[4] = { 3.0, 3.0, 3.0, 3.0 };						//Time until the spin begins.
float Spin_DMG[4] = { 200.0, 300.0, 400.0, 800.0 };					//Damage dealt per interval to anyone close enough during the spin.
float Spin_Radius[4] = { 120.0, 120.0, 120.0, 120.0 };				//Radius in which SSB's hammer will bludgeon players while he is spinning.
float Spin_Interval[4] = { 0.33, 0.3, 0.25, 0.2 };					//Interval in which the hammer will hit anyone who is too close.
float Spin_Duration[4] = { 9.0, 9.0, 9.0, 9.0 };					//Duration of the ability.
float Spin_Speed[4] = { 600.0, 700.0, 800.0, 900.0 };				//SSB's movement speed while spinning.
float Spin_EntityMult[4] = { 10.0, 10.0, 10.0, 10.0 };				//Amount to multiply damage dealt to entities.
float Spin_KB[4] = { 900.0, 1200.0, 1500.0, 1800.0 };				//Knockback velocity applied to players who get hit. This prevents the ability from just straight-up killing people if they fail to sidestep and SSB gets caught on them, and also makes the ability more fun.
float Spin_StunTime[4] = { 6.0, 4.5, 3.0, 0.0 };					//Duration to stun SSB for when he stops spinning.
//SPECIAL NOTE FOR SPIN 2 WIN: Friction and acceleration seem to be inextricably linked. You will need the perfect blend of both to get the effects you're looking for, 
//so don't just change these willy-nilly without testing first.
float Spin_Friction[4] = { 0.5, 0.66, 0.85, 1.0 };					//SSB's friction while spinning. Higher friction will make Spin 2 Win harder to avoid. (5.0 = default friction)
float Spin_Acceleration[4] = { 1200.0, 1500.0, 1800.0, 2100.0 };	//SSB's acceleration while spinning (friction does nothing if this is not set). Usually, 2 * Spin_Speed is the optimal value for this. Higher makes it harder to avoid.

//TO-DO:
//	- The following abilities need animations:
//		- Death Magnetic (Wind-Up, Intro Delay, Activation, attach particle to hand while charging and have player tether beams emit from that hand)
//		- Necrotic Bombardment, Ring of Tartarus (Finger Snap Gesture, activation beams should spawn from the hand)
//		- Necrotic Cataclysm (Knockback Pose)
//		- Spin 2 Win (Reworked Intro Sequence, Hammer Spawn VFX)
//	- Important details:
//		- Master of the Damned will not be able to be finished until every other Bone Zone NPC is also finished.
//		- Master of the Damned needs to have scaling on its summons. HP needs to scale with wave count and player count, and the number summoned needs to scale with player count.
//		- Add an EntityMult variable to ALL damaging abilities, not just explosions.

//NOTES (NOT TO-DO)
//	- Note: intended Spooky Special unlock progression is as follows:
//		- Wave Phase 0: Necrotic Blast, Master of the Damned
//		- Wave Phase 1: Gains access to Spin 2 Win and Soul Harvester.
//		- Wave Phase 2: Gains access to Hell is Here.
//		- Wave Phase 3: Gains access to MEGA MORTIS.
//	- DO NOT FORGET:
//		- Summoner's Stance, Soul Harvester, and Hell is Here all grant resistance while active.
//		- When the last merc dies, he needs to play his victory sound and mock RED team in chat.
//		- If he takes more than X% (probably 2.5%?) of his max HP from a single attack, he needs to play the BigHit sound.

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

public bool SSB_Filter_MustBeOnGround(SupremeSpookmasterBones ssb, int victim)
{
	if (!ssb.IsOnGround())
		return false;

	return true;
}

methodmap SSB_Ability __nullable__
{
	public SSB_Ability()
	{
		int index = 0;
		while (SSB_AbilitySlotUsed[index] && index < SSB_MAX_ABILITIES - 1)
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
			success = this.Uses < this.MaxUses || this.MaxUses == 0;

		//I've decided to ignore the "forced" parameter for the filter function, because otherwise filters do nothing to the default Spell Card/Spooky Special.
		if (success && /*!forced &&*/ this.FilterFunction != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.FilterFunction);
			Call_PushCell(user);
			Call_PushCell(target);
			Call_Finish(success);
		}
		
		if (success/* || forced*/)
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
	//So if we have 3 abilities and a chance variable of 0.33, our chance is: (1 / 3) * 0.33 -> 0.33 * 0.33 -> 10.89% chance of being used. This does not necessarily mean all abilities will add up to 100%.

	//Wave 15 (and before):
	//Spell Cards:
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("NIGHTMARE VOLLEY", 0.5, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility("CURSED CROSS", 0.66, 0, SpellCard_CursedCross, SSB_Filter_MustBeOnGround, _, true, Cross_Delay[0]));
	//Spooky Specials:
	//PushArrayCell(SSB_Specials[0], SSB_CreateAbility("NECROTIC CATACLYSM", 1.0, 0, Special_NecroticBlast, SSB_Filter_MustBeOnGround, false, _, Necrotic_Delay[0] + 1.6));
	//PushArrayCell(SSB_Specials[0], SSB_CreateAbility("MASTER OF THE DAMNED", 0.0, -1, Special_Summoner, SSB_Filter_MustBeOnGround, false, _, Summon_Duration[0] + 2.2));
	//PushArrayCell(SSB_Specials[0], SSB_CreateAbility("SPIN 2 WIN", 1.0, 0, Special_Spin, SSB_Filter_MustBeOnGround, false, _, Spin_Delay[1] + Spin_Duration[1] + 1.0));
	PushArrayCell(SSB_Specials[3], SSB_CreateAbility("HELL IS HERE", 1.0, 0, Special_Hell, SSB_Filter_MustBeOnGround, false, _, Hell_Delay[3] + Hell_Duration[3] + 1.5));

	//Wave 30:
	//Spell Cards:
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, SSB_Filter_MustBeOnGround, _, true, Cross_Delay[1]));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("CHAOS BARRAGE", 0.75, 0, SpellCard_ChaosBarrage));
	PushArrayCell(SSB_SpellCards[1], SSB_CreateAbility("DEATH MAGNETIC", 0.5, 3, SpellCard_DeathMagnetic, SSB_Filter_MustBeOnGround, _, true, Death_Delay[1]));
	//Spooky Specials:
	PushArrayCell(SSB_Specials[1], SSB_CreateAbility("NECROTIC CATACLYSM", 1.0, 0, Special_NecroticBlast, SSB_Filter_MustBeOnGround, false, _, Necrotic_Delay[1] + 1.6));
	PushArrayCell(SSB_Specials[1], SSB_CreateAbility("MASTER OF THE DAMNED", 0.0, -1, Special_Summoner, SSB_Filter_MustBeOnGround, false, _, Summon_Duration[1] + 2.2));
	PushArrayCell(SSB_Specials[1], SSB_CreateAbility("SOUL HARVESTER", 0.0, -1, Special_Harvester, SSB_Filter_MustBeOnGround, false, _, Harvester_Delay[1] + Harvester_Duration[1] + 2.2));
	PushArrayCell(SSB_Specials[1], SSB_CreateAbility("SPIN 2 WIN", 1.0, 0, Special_Spin, SSB_Filter_MustBeOnGround, false, _, Spin_Delay[1] + Spin_Duration[1] + 1.0));

	//Wave 45:
	//Spell Cards:
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, SSB_Filter_MustBeOnGround, _, true, Cross_Delay[2]));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("CHAOS BARRAGE", 1.0, 0, SpellCard_ChaosBarrage));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("DEATH MAGNETIC", 0.66, 2, SpellCard_DeathMagnetic, SSB_Filter_MustBeOnGround, _, true, Death_Delay[2]));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("NECROTIC BOMBARDMENT", 0.5, 2, SpellCard_CosmicTerror));
	PushArrayCell(SSB_SpellCards[2], SSB_CreateAbility("RING OF TARTARUS", 0.33, 1, SpellCard_RingOfTartarus));
	//Spooky Specials:
	PushArrayCell(SSB_Specials[2], SSB_CreateAbility("NECROTIC CATACLYSM", 1.0, 0, Special_NecroticBlast, SSB_Filter_MustBeOnGround, false, _, Necrotic_Delay[2] + 1.6));
	PushArrayCell(SSB_Specials[2], SSB_CreateAbility("MASTER OF THE DAMNED", 1.0, 1, Special_Summoner, SSB_Filter_MustBeOnGround, false, _, Summon_Duration[2] + 2.2));
	PushArrayCell(SSB_Specials[2], SSB_CreateAbility("SOUL HARVESTER", 0.0, -1, Special_Harvester, SSB_Filter_MustBeOnGround, false, _, Harvester_Delay[2] + Harvester_Duration[2] + 2.2));
	PushArrayCell(SSB_Specials[2], SSB_CreateAbility("SPIN 2 WIN", 1.0, 0, Special_Spin, SSB_Filter_MustBeOnGround, false, _, Spin_Delay[2] + Spin_Duration[2] + 1.0));

	//Wave 60+:
	//Spell Cards:
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("NIGHTMARE VOLLEY", 1.0, 0, SpellCard_NightmareVolley));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("CURSED CROSS", 1.0, 0, SpellCard_CursedCross, SSB_Filter_MustBeOnGround, _, true, Cross_Delay[3]));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("CHAOS BARRAGE", 1.0, 0, SpellCard_ChaosBarrage));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("DEATH MAGNETIC", 0.66, 3, SpellCard_DeathMagnetic, SSB_Filter_MustBeOnGround, _, true, Death_Delay[3]));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("NECROTIC BOMBARDMENT", 0.66, 3, SpellCard_CosmicTerror));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("RING OF TARTARUS", 0.33, 3, SpellCard_RingOfTartarus));
	//PushArrayCell(SSB_SpellCards[3], SSB_CreateAbility("WITNESS THE SKULL", 0.125, 3, SpellCard_TheSkull));
	//Spooky Specials:
	//PushArrayCell(SSB_Specials[3], SSB_CreateAbility("NECROTIC CATACLYSM", 1.0, 0, Special_NecroticBlast, SSB_Filter_MustBeOnGround, false, _, Necrotic_Delay[3] + 1.6));
	//PushArrayCell(SSB_Specials[3], SSB_CreateAbility("MASTER OF THE DAMNED", 1.0, 1, Special_Summoner, SSB_Filter_MustBeOnGround, false, _, Summon_Duration[3] + 2.2));
	//PushArrayCell(SSB_Specials[3], SSB_CreateAbility("SOUL HARVESTER", 0.0, -1, Special_Harvester, SSB_Filter_MustBeOnGround, false, _, Harvester_Delay[3] + Harvester_Duration[3] + 2.2));
	//PushArrayCell(SSB_Specials[3], SSB_CreateAbility("SPIN 2 WIN", 1.0, 0, Special_Spin, SSB_Filter_MustBeOnGround, false, _, Spin_Delay[3] + Spin_Duration[3] + 1.0));
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

public void SpellCard_NightmareVolley(SupremeSpookmasterBones ssb, int target)
{
	if (Volley_Count[SSB_WavePhase] < 1)
		return;

	ssb.AddGesture("ACT_SPELLCAST_2");
	DataPack pack = new DataPack();
	CreateDataTimer(0.5, NightmareVolley_Launch, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, EntIndexToEntRef(target));
	ssb.UsingAbility = true;
	ssb.Pause();
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
	ssb.Unpause();

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

public void SpellCard_CursedCross(SupremeSpookmasterBones ssb, int target)
{
	ssb.Pause();
	ssb.UsingAbility = true;
	ssb.PlayGenericWindup();

	int iActivity = ssb.LookupActivity("ACT_CURSED_CROSS_INTRO");
	if(iActivity > 0) ssb.StartActivity(iActivity);

	CreateTimer(Cross_Delay[SSB_WavePhase], Cross_Activate, EntIndexToEntRef(ssb.index), TIMER_FLAG_NO_MAPCHANGE);
	if (Cross_Delay[SSB_WavePhase] > 0.58)
	{
		DataPack pack = new DataPack();
		RequestFrame(Cross_ChangeToLoop, pack);
		WritePackCell(pack, EntIndexToEntRef(ssb.index));
		WritePackFloat(pack, GetGameTime(ssb.index) + 0.58);
	}

	float ang[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_angRotation", ang);
	ang[0] = 0.0;
	ang[2] = 0.0;
	WorldSpaceCenter(ssb.index, Cross_Pos[ssb.index]);

	for (float mod = 0.0; mod < 360.0; mod += Cross_Space[SSB_WavePhase])
	{
		float shootAng[3], shootPos[3];
		shootAng = ang;
		shootAng[1] += mod;

		GetPointFromAngles(Cross_Pos[ssb.index], shootAng, Cross_Range[SSB_WavePhase], shootPos, Priest_OnlyHitWorld, MASK_SHOT);
		SpawnBeam_Vectors(Cross_Pos[ssb.index], shootPos, Cross_Delay[SSB_WavePhase], 20, 200, 80, 90, PrecacheModel("materials/sprites/laserbeam.vmt"), 24.0, 24.0, _, 0.0);
	}

	for (int victim = 1; victim < MAXENTITIES; victim++)
		SSB_LaserHit[victim] = false;
}

public void Cross_ChangeToLoop(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float time = ReadPackFloat(pack);

	if (!IsValidEntity(ent))
	{
		delete pack;
		return;
	}

	if (GetGameTime(ent) >= time)
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
		int iActivity = ssb.LookupActivity("ACT_CURSED_CROSS_LOOP");
		if(iActivity > 0) ssb.StartActivity(iActivity);
		delete pack;
		return;
	}

	RequestFrame(Cross_ChangeToLoop, pack);
}

public Action Cross_Cast(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	for (int i = 0; i < sizeof(Cross_BlastSFX); i++)
	{
		EmitSoundToAll(Cross_BlastSFX[i], ssb.index, _, 120, _, _, 80);
	}

	float ang[3], hullMin[3], hullMax[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_angRotation", ang);
	ang[0] = 0.0;
	ang[2] = 0.0;
	hullMin[0] = -Cross_Width[SSB_WavePhase];
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	for (float mod = 0.0; mod < 360.0; mod += Cross_Space[SSB_WavePhase])
	{
		float shootAng[3], shootPos[3];
		shootAng = ang;
		shootAng[1] += mod;

		GetPointFromAngles(Cross_Pos[ssb.index], shootAng, Cross_Range[SSB_WavePhase], shootPos, Priest_OnlyHitWorld, MASK_SHOT);

		TR_TraceHullFilter(Cross_Pos[ssb.index], shootPos, hullMin, hullMax, 1073741824, SSB_LaserTrace, ssb.index);
			
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
		SpawnBeam_Vectors(Cross_Pos[ssb.index], shootPos, 0.25, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(Cross_Pos[ssb.index], shootPos, 0.25, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(Cross_Pos[ssb.index], shootPos, 0.25, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 6.0, 6.0, _, 10.0);
		SpawnBeam_Vectors(Cross_Pos[ssb.index], shootPos, 0.25, 20, 255, 120, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 20.0);
	}

	return Plugin_Continue;
}

public Action Cross_RevertAnim(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
	ssb.Unpause();
	ssb.UsingAbility = false;
	ssb.RevertSequence();

	return Plugin_Continue;
}

public Action Cross_Activate(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
	int iActivity = ssb.LookupActivity("ACT_CURSED_CROSS_ATTACK");
	if(iActivity > 0) ssb.StartActivity(iActivity);
	ssb.PlayGenericSpell();
	CreateTimer(0.16, Cross_Cast, EntIndexToEntRef(ssb.index));
	CreateTimer(0.5, Cross_RevertAnim, EntIndexToEntRef(ssb.index));

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

	if (!IsEntityAlive(ent))
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

	if (!IsEntityAlive(ent))
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

	if (!IsEntityAlive(ent))
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
	if (!IsEntityAlive(ent))
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
		SDKHooks_TakeDamage(other, entity, owner, f_BarrageProjectileDMG[entity], DMG_CLUB, _, _, pos);
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

	if (!IsEntityAlive(ent))
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
	ArrayList Players = new ArrayList(255);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && dieingstate[i] == 0 && TeutonType[i] == 0)
			PushArrayCell(Players, i);
	}

	int remaining = SSB_Cosmic_NumTargets[SSB_WavePhase];
	while (GetArraySize(Players) > 0 && remaining > 0)
	{
		int random = GetRandomInt(0, GetArraySize(Players) - 1);
		target = GetArrayCell(Players, random);
		Cosmic_BeginStrike(ssb, target, SSB_Cosmic_NumStrikes[SSB_WavePhase], true);

		RemoveFromArray(Players, random);
		remaining--;
	}

	delete Players;
}

public void Cosmic_BeginStrike(SupremeSpookmasterBones ssb, int target, int remainingStrikes, bool first)
{
	float pos[3];
	GetClientAbsOrigin(target, pos);

	int particle = ParticleEffectAt(pos, PARTICLE_SPAWNVFX_GREEN);
	EmitSoundToAll(SND_COSMIC_MARKED, particle, _, _, _, _, GetRandomInt(80, 110));

	if (first)
	{
		float UserLoc[3];
		WorldSpaceCenter(ssb.index, UserLoc);
		SpawnBeam_Vectors(UserLoc, pos, 0.33, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 15.0);
	}

	spawnRing_Vectors(pos, SSB_Cosmic_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, SSB_Cosmic_Delay[SSB_WavePhase], 6.0, 0.0, 0);
	spawnRing_Vectors(pos, SSB_Cosmic_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, SSB_Cosmic_Delay[SSB_WavePhase], 4.0, 0.0, 0, 0.0);

	remainingStrikes--;

	DataPack pack = new DataPack();
	CreateDataTimer(SSB_Cosmic_Delay[SSB_WavePhase], Cosmic_StrikePlayer, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, GetClientUserId(target));
	WritePackCell(pack, remainingStrikes);
	WritePackFloat(pack, pos[0]);
	WritePackFloat(pack, pos[1]);
	WritePackFloat(pack, pos[2]);
}

public Action Cosmic_StrikePlayer(Handle timer, DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	int target = GetClientOfUserId(ReadPackCell(pack));
	int remaining = ReadPackCell(pack);
	float pos[3], skyPos[3];
	for (int i = 0; i < 3; i++)
		pos[i] = ReadPackFloat(pack);

	if (!IsValidEntity(ent) || target < 1 || target > MaxClients)
		return Plugin_Continue;

	skyPos = pos;
	skyPos[2] += 9999.0;

	int particle = ParticleEffectAt(pos, PARTICLE_GREENBLAST_SSB, 2.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, pos, 0.33, 0, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 20.0);

	bool isBlue = GetEntProp(ent, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(SSB_Cosmic_DMG[SSB_WavePhase], ent, ent, 0, pos, SSB_Cosmic_Radius[SSB_WavePhase], SSB_Cosmic_Falloff_MultiHit[SSB_WavePhase], SSB_Cosmic_Falloff_Radius[SSB_WavePhase], isBlue, _, _, SSB_Cosmic_EntityMult[SSB_WavePhase]);

	int pitch = GetRandomInt(80, 110);
	EmitSoundToAll(SND_COSMIC_STRIKE, particle, _, _, _, _, pitch);
	EmitSoundToAll(SND_COSMIC_STRIKE, particle, _, _, _, _, pitch);

	if (!IsClientInGame(target) || dieingstate[target] != 0 || TeutonType[target] != 0 || remaining < 1)
		return Plugin_Continue;

	Cosmic_BeginStrike(view_as<SupremeSpookmasterBones>(ent), target, remaining, false);

	return Plugin_Continue;
}

#define RING_MAX 	255

int Tartarus_Ring_Owner[RING_MAX] = { -1, ... };

float Tartarus_Ring_Radius[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_DMG[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_Height[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_SlowAmt[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_EndTime[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_NextVFX[RING_MAX] = { 0.0, ... };
float Tartarus_Ring_Origin[RING_MAX][3];

bool Tartarus_Ring_SlotUsed[RING_MAX] = { false, ... };

methodmap Tartarus_Ring __nullable__
{
	public Tartarus_Ring(float pos[3], int phase)
	{
		int index = 0;
		while (Tartarus_Ring_SlotUsed[index] && index < RING_MAX - 1)
			index++;

		if (index >= RING_MAX)
			LogError("ERROR: More than %i Rings of Tartarus cannot exist at once.", RING_MAX);
		
		Tartarus_Ring_SlotUsed[index] = true;

		spawnRing_Vectors(pos, Ring_Radius[phase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 85, 0, 255, 120, 0, Ring_Delay[phase] + 0.1, 6.0, 0.0, 0);
		spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 85, 0, 255, 255, 0, Ring_Delay[phase] + 0.1, 4.0, 0.0, 0, Ring_Radius[phase] * 2.0);

		return view_as<Tartarus_Ring>(index);
	}

	public void Activate() { CreateTimer(Ring_Delay[SSB_WavePhase], Ring_Activate, this, TIMER_FLAG_NO_MAPCHANGE); }

	public void Stop() { Tartarus_Ring_SlotUsed[this.Index] = false; this.Owner = -1; }

	public void SetOrigin(float pos[3])
	{
		Tartarus_Ring_Origin[this.Index] = pos;
	}

	public void GetOrigin(float output[3])
	{
		output = Tartarus_Ring_Origin[this.Index];
	}

	property int Index
	{ 
		public get() { return view_as<int>(this); }
	}

	property int Owner
	{
		public get() { return EntRefToEntIndex(Tartarus_Ring_Owner[this.Index]); }
		public set(int value)
		{
			if (IsValidEntity(value))
				Tartarus_Ring_Owner[this.Index] = EntIndexToEntRef(value); 
			else
				Tartarus_Ring_Owner[this.Index] = value;
		}
	}

	property float Radius
	{
		public get() { return Tartarus_Ring_Radius[this.Index]; }
		public set(float value) { Tartarus_Ring_Radius[this.Index] = value; }
	}

	property float Damage
	{
		public get() { return Tartarus_Ring_DMG[this.Index]; }
		public set(float value) { Tartarus_Ring_DMG[this.Index] = value; }
	}

	property float Height
	{
		public get() { return Tartarus_Ring_Height[this.Index]; }
		public set(float value) { Tartarus_Ring_Height[this.Index] = value; }
	}

	property float SlowAmt
	{
		public get() { return Tartarus_Ring_SlowAmt[this.Index]; }
		public set(float value) { Tartarus_Ring_SlowAmt[this.Index] = value; }
	}

	property float EndTime
	{
		public get() { return Tartarus_Ring_EndTime[this.Index]; }
		public set(float value) { Tartarus_Ring_EndTime[this.Index] = value; }
	}

	property float NextVFX
	{
		public get() { return Tartarus_Ring_NextVFX[this.Index]; }
		public set(float value) { Tartarus_Ring_NextVFX[this.Index] = value; }
	}
}

public void SpellCard_RingOfTartarus(SupremeSpookmasterBones ssb, int target)
{
	ArrayList Players = new ArrayList(255);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && dieingstate[i] == 0 && TeutonType[i] == 0)
			PushArrayCell(Players, i);
	}

	int remaining = Ring_NumTargets[SSB_WavePhase];
	while (GetArraySize(Players) > 0 && remaining > 0)
	{
		int random = GetRandomInt(0, GetArraySize(Players) - 1);
		target = GetArrayCell(Players, random);

		float pos[3], UserLoc[3];
		GetClientAbsOrigin(target, pos);
		WorldSpaceCenter(ssb.index, UserLoc);

		if (GetEntityFlags(target) & FL_ONGROUND == 0)
			pos[2] -= SSB_GetDistanceToGround(pos);

		EmitSoundToAll(SND_RING_MARKED, _, _, _, _, _, GetRandomInt(80, 110), _, pos);

		SpawnBeam_Vectors(UserLoc, pos, 0.33, 85, 0, 255, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 15.0);
		
		Ring_CreateRing(pos, SSB_WavePhase, ssb);

		RemoveFromArray(Players, random);
		remaining--;
	}

	delete Players;
}

public void Ring_CreateRing(float pos[3], int phase, SupremeSpookmasterBones ssb)
{
	Tartarus_Ring ring = new Tartarus_Ring(pos, SSB_WavePhase);

	ring.Owner = ssb.index;
	ring.Radius = Ring_Radius[phase];
	ring.Damage = Ring_DMG[phase];
	ring.Height = Ring_Height[phase];
	ring.SlowAmt = Ring_SlowAmt[phase];
	ring.EndTime = GetGameTime() + Ring_Duration[phase] + Ring_Delay[phase];
	ring.SetOrigin(pos);

	ring.Activate();
}

public Action Ring_Activate(Handle timer, Tartarus_Ring ring)
{
	if (!IsValidEntity(ring.Owner))
	{
		ring.Stop();
		return Plugin_Continue;
	}

	float pos[3];
	ring.GetOrigin(pos);
	CreateTimer(0.1, Ring_Logic, ring, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	int particle = ParticleEffectAt(pos, PARTICLE_TARTARUS_BEGIN);
	EmitSoundToAll(SND_TARTARUS_BEGIN, particle);
	EmitSoundToAll(SND_TARTARUS_BEGIN, particle);
	EmitSoundToAll(SND_TARTARUS_BEGIN, particle);

	return Plugin_Continue;
}

public Action Ring_Logic(Handle timer, Tartarus_Ring ring)
{
	float gt = GetGameTime();
	if (!IsValidEntity(ring.Owner) || gt >= ring.EndTime)
	{
		ring.Stop();
		return Plugin_Stop;
	}

	float pos[3];
	ring.GetOrigin(pos);

	//Uncomment this and delete the for loop inside of (if gt >= ring.NextVFX) if the hand particles cause problems that can't be solved by reducing the number of them that spawn
	//spawnRing_Vectors(pos, ring.Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 105, 0, 255, 255, 0, 0.1, 6.0, 4.0, 0);
	if (gt >= ring.NextVFX)
	{
		spawnRing_Vectors(pos, ring.Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 105, 0, 255, 255, 0, 0.4, 3.0, 2.0, 0, 0.0);

		for (int i = 0; i < GetRandomInt(8, 16); i++)
		{
			float randPos[3];
			randPos = pos;
			randPos[0] += GetRandomFloat(-ring.Radius, ring.Radius);
			randPos[1] += GetRandomFloat(-ring.Radius, ring.Radius);

			ParticleEffectAt(randPos, PARTICLE_TARTARUS, 0.8);
		}

		ring.NextVFX = gt + 0.8;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && dieingstate[i] == 0 && TeutonType[i] == 0)
		{
			if (GetEntityFlags(i) & FL_ONGROUND == 0)
				continue;

			float vicLoc[3];
			GetClientAbsOrigin(i, vicLoc);
			float ZOff = vicLoc[2];
			vicLoc[2] = 0.0;

			if (GetVectorDistance(pos, vicLoc) <= ring.Radius && GetDifference(ZOff, pos[2]) <= ring.Height)
			{
				if (!TF2_IsPlayerInCondition(i, TFCond_Dazed))
					TF2_StunPlayer(i, 0.5, ring.SlowAmt, TF_STUNFLAG_SLOWDOWN);

				SDKHooks_TakeDamage(i, ring.Owner, ring.Owner, ring.Damage, DMG_CLUB, _, _, pos);
			}
		}
	}

	return Plugin_Continue;
}

public float GetDifference(float a, float b)
{
	float diff = a - b;
	if (diff < 0.0)
		diff *= -1.0;

	return diff;
}

public void SpellCard_TheSkull(SupremeSpookmasterBones ssb, int target)
{
	ssb.AddGesture("ACT_SPELLCAST_2");
	CreateTimer(0.5, Skull_Launch, EntIndexToEntRef(ssb.index), TIMER_FLAG_NO_MAPCHANGE);
	ssb.UsingAbility = true;
	ssb.Pause();
}

public Action Skull_Launch(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);

	if (!IsValidEntity(ent))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	ssb.UsingAbility = false;
	ssb.Unpause();

	float pos[3], ang[3], testAng[3];
	GetEntPropVector(ssb.index, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(ssb.index, Prop_Send, "m_angRotation", ang);
	pos[2] += 60.0;

	testAng[0] = 0.0;
	testAng[1] = ang[1];
	testAng[2] = 0.0;
				
	GetPointFromAngles(pos, testAng, 40.0, pos, Priest_IgnoreAll, MASK_SHOT);

	int portal = SSB_CreateProjectile(ssb, MODEL_HIDDEN_PROJECTILE, pos, testAng, 0.0, 0.1, SSB_BlockExplosion);
	if (IsValidEntity(portal))
	{
		SSB_AttachParticle(portal, PARTICLE_PORTAL_PURPLE, _, "");
		EmitSoundToAll(SND_SKULL_PORTAL, portal, _, 120);
		SetEntityMoveType(portal, MOVETYPE_NONE);

		DataPack pack = new DataPack();
		RequestFrame(Skull_WaitForSpawn, pack);
		WritePackCell(pack, EntIndexToEntRef(portal));
		WritePackCell(pack, EntIndexToEntRef(ssb.index));
		WritePackCell(pack, SSB_WavePhase);
		WritePackFloat(pack, GetGameTime() + Skull_SpawnDelay[SSB_WavePhase]);
	}

	return Plugin_Continue;
}

public void Skull_WaitForSpawn(DataPack pack)
{
	ResetPack(pack);

	int portal = EntRefToEntIndex(ReadPackCell(pack));
	int owner = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float spawnTime = ReadPackFloat(pack);

	if (!IsValidEntity(portal) || !IsValidEntity(owner))
	{
		delete pack;
		return;
	}

	if (GetGameTime() >= spawnTime)
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(owner);

		float pos[3], testAng[3], ang[3], targPos[3];
		GetEntPropVector(portal, Prop_Data, "m_vecAbsOrigin", pos);

		int target = GetClosestTarget(portal, true, _, _, _, _, _, true);
		if (IsValidEntity(target))
		{
			WorldSpaceCenter(target, targPos);

			MakeVectorFromPoints(pos, targPos, ang);
			GetVectorAngles(ang, testAng);
		}
		else
		{
			GetEntPropVector(portal, Prop_Data, "m_angRotation", testAng);
		}

		RemoveEntity(portal);

		int skull = SSB_CreateProjectile(ssb, MODEL_SKULL, pos, testAng, Skull_Velocity[phase], 4.0, Skull_Collide);
		if (IsValidEntity(skull))
		{
			ParticleEffectAt(pos, PARTICLE_GREENBLAST_SSB, 3.0);
			EmitSoundToAll(SND_SKULL_SPAWN, skull, _, 120);
			EmitSoundToAll(Skull_LaughSFX[GetRandomInt(0, sizeof(Skull_LaughSFX) - 1)], skull, _, 120);

			SSB_AttachParticle(skull, PARTICLE_MEGASKULL, _, "");
			SSB_AttachParticle(skull, PARTICLE_FIREBALL_RED, _, "");
			SetEntityRenderMode(skull, RENDER_GLOW);
			SetEntityRenderColor(skull, 255, 160, 80, 200);

			Initiate_HomingProjectile(skull, ssb.index, Skull_HomingAngle[phase], Skull_HomingPerSecond[phase], false, true, testAng);

			delete pack;
			pack = new DataPack();
			RequestFrame(Skull_Logic, pack);
			WritePackCell(pack, EntIndexToEntRef(skull));
			WritePackCell(pack, EntIndexToEntRef(ssb.index));
			WritePackCell(pack, phase);
			WritePackFloat(pack, GetGameTime() + Skull_MiniRate[phase]);
			WritePackFloat(pack, GetGameTime() + Skull_Duration[phase]);
		}

		return;
	}
	
	RequestFrame(Skull_WaitForSpawn, pack);
}

public void Skull_Logic(DataPack pack)
{
	ResetPack(pack);

	int skull = EntRefToEntIndex(ReadPackCell(pack));
	int owner = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float nextProjectile = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(skull) || !IsValidEntity(owner))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(owner);
	float gt = GetGameTime();

	if (gt >= endTime)
	{
		SetEntityMoveType(skull, MOVETYPE_NONE);
		float ang[3];
		GetEntPropVector(skull, Prop_Data, "m_angRotation", ang);

		pack = new DataPack();
		RequestFrame(Skull_SelfDestructSequence, pack);
		WritePackCell(pack, EntIndexToEntRef(skull));
		WritePackCell(pack, EntIndexToEntRef(owner));
		WritePackCell(pack, phase);
		WritePackFloat(pack, gt + Skull_SelfDestructDelay[phase]);
		WritePackFloat(pack, ang[1]);
		WritePackFloat(pack, 2.0);
		WritePackFloat(pack, 0.0);
		WritePackFloat(pack, 1.0);

		return;
	}

	if (gt >= nextProjectile)
	{
		int target = GetClosestTarget(skull, true, _, _, _, _, _, true);
		if (IsValidEntity(target))
		{
			float pos[3], ang[3], otherPos[3];
			GetEntPropVector(skull, Prop_Data, "m_vecAbsOrigin", pos);
			WorldSpaceCenter(target, otherPos);

			MakeVectorFromPoints(pos, otherPos, ang);
			GetVectorAngles(ang, ang);

			for (int i = 0; i < 3; i++)
				ang[i] += GetRandomFloat(-Skull_MiniSpread[phase], Skull_MiniSpread[phase]);

			int projectile = SSB_CreateProjectile(ssb, MODEL_HIDDEN_PROJECTILE, pos, ang, Skull_MiniVelocity[phase], 0.5, SSB_BlockExplosion);
			if (IsValidEntity(projectile))
			{
				CreateTimer(Skull_MiniDuration[phase], Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);

				SSB_AttachParticle(projectile, PARTICLE_SKULL_MINI, _, "");

				Initiate_HomingProjectile(projectile, ssb.index, Skull_MiniHomingAngle[phase], Skull_MiniHomingPerSecond[phase], false, true, ang);

				SDKHook(projectile, SDKHook_TouchPost, Skull_MiniTouch);

				EmitSoundToAll(SND_SKULL_MINIFIRE, skull, _, _, _, _, GetRandomInt(80, 120));

				f_BarrageProjectileDMG[projectile] = Skull_MiniDMG[phase];
			}

			nextProjectile = gt + Skull_MiniRate[phase];
		}
	}

	pack = new DataPack();
	RequestFrame(Skull_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(skull));
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, phase);
	WritePackFloat(pack, nextProjectile);
	WritePackFloat(pack, endTime);
}

public void Skull_SelfDestructSequence(DataPack pack)
{
	ResetPack(pack);

	int skull = EntRefToEntIndex(ReadPackCell(pack));
	int owner = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float endTime = ReadPackFloat(pack);
	float yaw = ReadPackFloat(pack);
	float acceleration = ReadPackFloat(pack);
	float nextlaugh = ReadPackFloat(pack);
	float laughdelay = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(skull) || !IsValidEntity(owner))
		return;

	float gt = GetGameTime();

	if (gt >= endTime)
	{
		Skull_Collide(skull);
		return;
	}

	if (gt >= nextlaugh)
	{
		float remainingTime = (endTime - gt);
		float ratio = remainingTime / Skull_SelfDestructDelay[phase];

		int pitch = 160 - RoundToCeil(100.0 * ratio);

		EmitSoundToAll(Skull_LaughSFX[GetRandomInt(0, sizeof(Skull_LaughSFX) - 1)], skull, _, 120, _, _, pitch);
		EmitSoundToAll(Skull_LaughSFX[GetRandomInt(0, sizeof(Skull_LaughSFX) - 1)], skull, _, 120, _, _, pitch);
		EmitSoundToAll(SND_SKULL_SDBEEP, skull, _, 120, _, _, pitch);
		EmitSoundToAll(SND_SKULL_SDBEEP, skull, _, 120, _, _, pitch);

		float pos[3];
		GetEntPropVector(skull, Prop_Data, "m_vecAbsOrigin", pos);

		int alpha = 255 - RoundToCeil(255.0 * ratio);
		spawnRing_Vectors(pos, Skull_Radius[phase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, alpha, 0, 0.2, 6.0, 2.0, 0, 0.0);

		laughdelay *= 0.66;
		nextlaugh = gt + laughdelay;
	}
	
	float ang[3];
	ang[1] = yaw;
	TeleportEntity(skull, _, ang);

	pack = new DataPack();
	RequestFrame(Skull_SelfDestructSequence, pack);
	WritePackCell(pack, EntIndexToEntRef(skull));
	WritePackCell(pack, EntIndexToEntRef(owner));
	WritePackCell(pack, phase);
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, yaw + acceleration);
	WritePackFloat(pack, acceleration * 1.04);
	WritePackFloat(pack, nextlaugh);
	WritePackFloat(pack, laughdelay);
}

public Action Skull_MiniTouch(int entity, int other)
{
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

	ParticleEffectAt(pos, PARTICLE_BARRAGE_HIT);
	EmitSoundToAll(SND_BARRAGE_HIT, entity, _, _, _, _, GetRandomInt(80, 110));

	if (IsValidEnemy(entity, other))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		SDKHooks_TakeDamage(other, entity, owner, f_BarrageProjectileDMG[entity], DMG_CLUB, _, _, pos);
	}

	RemoveEntity(entity);
	return Plugin_Continue;
}

public MRESReturn Skull_Collide(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

	ParticleEffectAt(position, PARTICLE_MEGASKULLBLAST, 1.0);
	EmitSoundToAll(SND_MEGASKULLBLAST, entity, _, 120);
	EmitSoundToAll(SND_MEGASKULLBLAST, entity, _, 120);

	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(IsValidEntity(owner))
	{
		bool isBlue = GetEntProp(owner, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Skull_DMG[SSB_WavePhase], owner, entity, 0, position, Skull_Radius[SSB_WavePhase], Skull_Falloff_MultiHit[SSB_WavePhase],
		Skull_Falloff_Radius[SSB_WavePhase], isBlue, 9999, true, Skull_EntityMult[SSB_WavePhase]);
	}

	RemoveEntity(entity);
	return MRES_Supercede;
}

public void Special_NecroticBlast(SupremeSpookmasterBones ssb, int target)
{
	float pos[3];
	WorldSpaceCenter(target, pos);
	ssb.FaceTowards(pos, 15000.0);

	ssb.UsingAbility = true;
	ssb.Pause();
	ssb.PlayNecroBlastWarning();

	int iActivity = ssb.LookupActivity("ACT_NULL_POINTER_INTRO");
	if(iActivity > 0) ssb.StartActivity(iActivity);

	float begin = GetGameTime(ssb.index) + 1.16;

	DataPack pack = new DataPack();
	RequestFrame(NecroBlast_WaitForCharge, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, SSB_WavePhase);
	WritePackFloat(pack, begin);

	DataPack pack2 = new DataPack();
	RequestFrame(NecroBlast_ChargeVFX, pack2);
	WritePackCell(pack2, EntIndexToEntRef(ssb.index));
	WritePackCell(pack2, SSB_WavePhase);
	WritePackFloat(pack2, GetGameTime(ssb.index) + Necrotic_Delay[SSB_WavePhase] + 1.16);
	WritePackFloat(pack2, GetGameTime(ssb.index));
	WritePackFloat(pack2, 0.0);
	WritePackFloat(pack2, 0.0);
}

public void NecroBlast_ChargeVFX(DataPack pack)
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
		return;

	if (gt >= next)
	{
		float remaining = end - GetGameTime(user);
		float total = end - start;
		float ratio = remaining / total;

		RaidModeScaling = (SSB_RaidPower[phase] * 100000.0) * (1.0 - ratio);

		int alpha = 255 - RoundToCeil(255.0 * ratio);
		
		float pos[3], ang[3];
		WorldSpaceCenter(user, pos);
		GetEntPropVector(user, Prop_Data, "m_angRotation", ang);
		ang[0] = 0.0;
		ang[2] = 0.0;

		for (float i = 0.0; i < 360.0; i += 45.0)
		{
			float spawnAng[3], startPos[3], endPos[3], Direction[3];
			spawnAng[0] = i + spin;
			spawnAng[1] = ang[1] + 90.0;
			spawnAng[2] = ang[2];

			GetAngleVectors(spawnAng, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, Necrotic_Width[phase] * 0.5);
			AddVectors(pos, Direction, startPos);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, 9999.0);
			AddVectors(startPos, Direction, endPos);

			SpawnBeam_Vectors(pos, startPos, 0.1, 255, 60, 0, alpha, PrecacheModel("materials/sprites/laserbeam.vmt"), 2.0, 2.0, _, 0.0);
			SpawnBeam_Vectors(startPos, endPos, 0.1, 255, 60, 0, alpha, PrecacheModel("materials/sprites/laserbeam.vmt"), 2.0, 2.0, _, 0.0);
		}

		next = gt + 0.0;
	}

	pack = new DataPack();
	RequestFrame(NecroBlast_ChargeVFX, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, end);
	WritePackFloat(pack, start);
	WritePackFloat(pack, spin + 16.0);
	WritePackFloat(pack, next);
}

public void NecroBlast_WaitForCharge(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float begin = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	if (GetGameTime(user) >= begin)
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

		if (Necrotic_Delay[phase] <= 0.0)
		{
			delete pack;
			NecroBlast_Fire(ssb, phase);
		}
		else
		{
			int iActivity = ssb.LookupActivity("ACT_NULL_POINTER_CHARGE");
			if(iActivity > 0) ssb.StartActivity(iActivity);

			ssb.SetPlaybackRate((32.0 / 24.0) / Necrotic_Delay[phase]);

			pack = new DataPack();
			RequestFrame(NecroBlast_ChargeUp, pack);
			WritePackCell(pack, EntIndexToEntRef(ssb.index));
			WritePackCell(pack, phase);
			WritePackFloat(pack, GetGameTime(ssb.index) + Necrotic_Delay[phase]);
		}

		return;
	}

	RequestFrame(NecroBlast_WaitForCharge, pack);
}

public void NecroBlast_ChargeUp(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float fire = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);
	if (GetGameTime(user) >= fire)
	{
		NecroBlast_Fire(ssb, phase);
		delete pack;
		return;
	}

	RequestFrame(NecroBlast_ChargeUp, pack);
}

public void NecroBlast_Fire(SupremeSpookmasterBones ssb, int phase)
{
	ssb.SetPlaybackRate(1.0);
	ssb.PlayNecroBlast();

	float ang[3], pos[3], hullMin[3], hullMax[3], testAng[3], shootPos[3], Direction[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_angRotation", ang);
	WorldSpaceCenter(ssb.index, pos);
	testAng[1] = ang[1];

	hullMin[0] = -Necrotic_Width[phase] * 0.475;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	GetPointFromAngles(pos, testAng, 9999.0, shootPos, Priest_IgnoreAll, MASK_SHOT);

	TR_TraceHullFilter(pos, shootPos, hullMin, hullMax, 1073741824, SSB_LaserTrace, ssb.index);
			
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (SSB_LaserHit[victim])
		{
			SSB_LaserHit[victim] = false;
					
			if (IsValidEnemy(ssb.index, victim))
			{
				float damage = Necrotic_DMG[SSB_WavePhase];
					
				if (ShouldNpcDealBonusDamage(victim))
				{
					damage *= Necrotic_EntityMult[SSB_WavePhase];
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
		ScaleVector(Direction, Necrotic_Width[phase] * 0.5);
		AddVectors(pos, Direction, startPos);

		GetAngleVectors(testAng, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, 9999.0);
		AddVectors(startPos, Direction, endPos);

		SpawnBeam_Vectors(startPos, endPos, 0.33, 255, 60, 0, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 66.0, 66.0, _, 0.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 255, 60, 0, 255, PrecacheModel("materials/sprites/glow02.vmt"), 66.0, 66.0, _, 0.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 255, 60, 0, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 33.0, 33.0, _, 10.0);
		SpawnBeam_Vectors(startPos, endPos, 0.33, 255, 60, 0, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 11.0, 11.0, _, 20.0);
	}

	SSB_BigVFX(true, _, _, 2.0, false);

	if (Necrotic_SelfKB[phase] > 0.0)
	{
		float targPos[3];

		WorldSpaceCenter(ssb.index, pos);

		ang[1] += 180.0;
		ang[0] = -6.0;

		GetPointFromAngles(pos, ang, Necrotic_SelfKB[phase], targPos, Priest_IgnoreAll, MASK_SHOT);
		PluginBot_Jump(ssb.index, targPos);

		RequestFrame(NecroBlast_FunnySpin, EntIndexToEntRef(ssb.index));
		//TODO: This needs a custom anim
	}
	else
	{
		ssb.RevertSequence();
		ssb.Unpause();
		ssb.UsingAbility = false;
	}

	RaidModeScaling = SSB_RaidPower[SSB_WavePhase];
}

public void NecroBlast_FunnySpin(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsEntityAlive(ent))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);

	if (ssb.IsOnGround())
	{
		ssb.Unpause();
		ssb.UsingAbility = false;
		ssb.RevertSequence();

		return;
	}

	RequestFrame(NecroBlast_FunnySpin, ref);
}

public void Special_Summoner(SupremeSpookmasterBones ssb, int target)
{
	ssb.UsingAbility = true;
	ssb.Pause();
	ssb.PlaySummonerIntro();
	ssb.DmgMult = Summon_Resistance[SSB_WavePhase];
	ssb.GiveTime(Summon_BonusTime[SSB_WavePhase]);

	int iActivity = ssb.LookupActivity("ACT_SUMMONERS_STANCE_INTRO");
	if(iActivity > 0) ssb.StartActivity(iActivity);

	float begin = GetGameTime(ssb.index) + 1.04;

	DataPack pack = new DataPack();
	RequestFrame(Summoner_EndIntroAnim, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack, begin);

	float pos[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_vecAbsOrigin", pos);
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 120, 1, 1.04, 32.0, 0.0, 1, Summon_Radius[SSB_WavePhase] * 2.0);
}

public void Summoner_EndIntroAnim(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	float end = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

	if (GetGameTime(user) >= end)
	{
		int iActivity = ssb.LookupActivity("ACT_SUMMONERS_STANCE_LOOP");
		if(iActivity > 0) ssb.StartActivity(iActivity);

		delete pack;
		pack = new DataPack();
		RequestFrame(Summoner_Logic, pack);
		WritePackCell(pack, EntIndexToEntRef(user));
		WritePackCell(pack, SSB_WavePhase);
		WritePackFloat(pack, GetGameTime(user) + Summon_Duration[SSB_WavePhase]);
		WritePackFloat(pack, 0.0);
		WritePackFloat(pack, 0.0);

		return;
	}

	RequestFrame(Summoner_EndIntroAnim, pack);
}

public void Summoner_Logic(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float endTime = ReadPackFloat(pack);
	float nextWave = ReadPackFloat(pack);
	float nextVFX = ReadPackFloat(pack);
	delete pack;

	if (!IsValidEntity(user))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

	float gt = GetGameTime(user);
	if (gt >= endTime)
	{
		int iActivity = ssb.LookupActivity("ACT_SUMMONERS_STANCE_OUTRO");
		if(iActivity > 0) ssb.StartActivity(iActivity);

		CreateTimer(1.0, Summon_End, EntIndexToEntRef(user), TIMER_FLAG_NO_MAPCHANGE);

		return;
	}

	float pos[3];
	GetEntPropVector(ssb.index, Prop_Data, "m_vecAbsOrigin", pos);

	if (gt >= nextWave)
	{
		for (int i = 0; i < Summon_Count[phase]; i++)
		{
			float randAng[3], spawnLoc[3];
			randAng[1] = GetRandomFloat(0.0, 360.0);

			GetPointFromAngles(pos, randAng, GetRandomFloat(0.0, Summon_Radius[phase]), spawnLoc, Priest_OnlyHitWorld, MASK_SHOT);

			spawnLoc[2] -= SSB_GetDistanceToGround(spawnLoc);

			spawnRing_Vectors(spawnLoc, Summon_ThunderRadius[phase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, Summon_SpawnDelay[phase], 16.0, 0.0, 0);
			spawnRing_Vectors(spawnLoc, Summon_ThunderRadius[phase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 0, Summon_SpawnDelay[phase], 16.0, 0.0, 0, 0.0);
			ParticleEffectAt(spawnLoc, PARTICLE_SPAWNVFX_GREEN);

			DataPack summonPack = new DataPack();
			CreateDataTimer(Summon_SpawnDelay[phase], Summoner_Spawn, summonPack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(summonPack, EntIndexToEntRef(ssb.index));
			WritePackCell(summonPack, phase);
			WritePackFloat(summonPack, spawnLoc[0]);
			WritePackFloat(summonPack, spawnLoc[1]);
			WritePackFloat(summonPack, spawnLoc[2]);
		}

		nextWave = gt + Summon_Interval[phase];
	}

	if (gt >= nextVFX)
	{
		spawnRing_Vectors(pos, Summon_Radius[SSB_WavePhase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, 0.1, 32.0, 0.0, 1);
		nextVFX = gt + 0.1;
	}

	pack = new DataPack();
	RequestFrame(Summoner_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, nextWave);
	WritePackFloat(pack, nextVFX);
}

#define SUMMONER_MAX	255

bool Summoner_Minion_SlotUsed[SUMMONER_MAX];
bool Summoner_HasBuffedForm[SUMMONER_MAX];

float Summoner_BuffChance[SUMMONER_MAX];
float Summoner_Value[SUMMONER_MAX];

int Summoner_Count[SUMMONER_MAX];

Function Summoner_SummonFunction[SUMMONER_MAX] = { INVALID_FUNCTION, ... };

methodmap Summoner_Minion __nullable__
{
	public Summoner_Minion(Function SummonFunction, bool HasBuffedForm = true, float BuffChance = 0.0, float SummonValue = 1.0, int SummonCount = 1)
	{
		int index = 0;
		while (Summoner_Minion_SlotUsed[index] && index < SUMMONER_MAX - 1)
			index++;

		if (index >= SUMMONER_MAX)
			LogError("ERROR: More than %i minion templates for Master of the Damned cannot exist at once.", SUMMONER_MAX);
		
		Summoner_Minion_SlotUsed[index] = true;
		Summoner_HasBuffedForm[index] = HasBuffedForm;
		Summoner_SummonFunction[index] = SummonFunction;
		Summoner_BuffChance[index] = BuffChance;
		Summoner_Value[index] = SummonValue;
		Summoner_Count[index] = SummonCount;

		return view_as<Summoner_Minion>(index);
	}

	public void Dispatch(SupremeSpookmasterBones ssb, float pos[3], int phase)
	{
		Summoner_Minion_SlotUsed[this.Index] = false;

		if (this.SummonFunction == INVALID_FUNCTION || this.Count < 1)
			return;

		for (int i = 0; i < this.Count && ssb.m_flBoneZoneNumSummons + this.Value < Summon_Max[phase]; i++)
		{
			float randAng[3];
			randAng[1] = GetRandomFloat(0.0, 360.0);

			int entity = -1;

			Call_StartFunction(null, this.SummonFunction);

			Call_PushArray(pos, 3);
			Call_PushArray(randAng, 3);
			Call_PushCell(GetTeam(ssb.index));
			if (this.HasBuffedForm)
				Call_PushCell(GetRandomFloat(0.0, 1.0) <= this.BuffChance);

			Call_Finish(entity);

			CClotBody summoned = view_as<CClotBody>(entity);
			summoned.m_iBoneZoneSummoner = ssb.index;
			summoned.m_flBoneZoneSummonValue = this.Value;
			ssb.m_flBoneZoneNumSummons += this.Value;
			NpcAddedToZombiesLeftCurrently(entity, true);
		}

		this.SummonFunction = INVALID_FUNCTION;
	}

	property int Index
	{
		public get() { return view_as<int>(this); }
	}

	property int Count
	{
		public get() { return Summoner_Count[this.Index]; }
		public set(int value) { Summoner_Count[this.Index] = value; }
	}

	property float BuffChance
	{
		public get() { return Summoner_BuffChance[this.Index]; }
		public set(float value) { Summoner_BuffChance[this.Index] = value; }
	}

	property float Value
	{
		public get() { return Summoner_Value[this.Index]; }
		public set(float value) { Summoner_Value[this.Index] = value; }
	}

	property bool HasBuffedForm
	{
		public get() { return Summoner_HasBuffedForm[this.Index]; }
		public set(bool value) { Summoner_HasBuffedForm[this.Index] = value; }
	}

	property Function SummonFunction
	{
		public get() { return Summoner_SummonFunction[this.Index]; }
		public set(Function value) { Summoner_SummonFunction[this.Index] = value; }
	}
}

public Action Summoner_Spawn(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float spawnLoc[3], skyPos[3];
	for (int i = 0; i < 3; i++)
		spawnLoc[i] = ReadPackFloat(pack);

	if (!IsValidEntity(user))
		return Plugin_Continue;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

	skyPos = spawnLoc;
	skyPos[2] += 9999.0;

	int particle = ParticleEffectAt(spawnLoc, PARTICLE_GREENBLAST_SSB, 2.0);
	int pitch = GetRandomInt(70, 110);
	EmitSoundToAll(SND_SUMMON_BLAST, particle, _, 120, _, _, pitch);
	EmitSoundToAll(SND_SUMMON_SPAWN, particle, _, 120, _, _, pitch);

	SpawnBeam_Vectors(skyPos, spawnLoc, 0.33, 0, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, spawnLoc, 0.33, 0, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 36.0, 36.0, _, 0.0);
	SpawnBeam_Vectors(skyPos, spawnLoc, 0.33, 0, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 20.0);

	bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(Summon_ThunderDMG[phase], ssb.index, ssb.index, -1, spawnLoc, Summon_ThunderRadius[phase], Summon_ThunderFalloffMultiHit[phase], 
	Summon_ThunderFalloffRange[phase], isBlue, _, _, Summon_ThunderEntityMult[phase]);

	ArrayList minions = new ArrayList();

	//TODO: Expand on this once all other Bone Zone NPCs are finished.
	//	- Phase 0: Already finished, should ONLY be able to summon Basic Bones, Beefy Bones, and 2x Brittle Bones.
	//	- Phase 1: Normal pirate-themed skeletons.
	//	- Phase 2: Medieval-era skeletons.
	//	- Phase 3: Literally any non-boss skeleton, minion stats are mega-buffed.
	switch(phase)
	{
		case 0:
		{
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BasicBones), true, 0.1));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BeefyBones), true, 0.1));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BrittleBones), true, 0.2, 0.5, 2));
		}
		case 1:
		{
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BasicBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BeefyBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BrittleBones), true, 0.33, 0.5, 2));
		}
		case 2:
		{
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BasicBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BeefyBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BrittleBones), true, 0.33, 0.5, 2));
		}
		default:
		{
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BasicBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BeefyBones), true, 0.2));
			PushArrayCell(minions, new Summoner_Minion(view_as<Function>(Summon_BrittleBones), true, 0.33, 0.5, 2));
		}
	}

	if (GetArraySize(minions) > 0)
	{
		int chosen = GetRandomInt(0, GetArraySize(minions) - 1);
		Summoner_Minion minion = GetArrayCell(minions, chosen);
		minion.Dispatch(ssb, spawnLoc, phase);
	}

	delete minions;

	return Plugin_Continue;
}

public int Summon_BasicBones(int owner, float pos[3], float ang[3], int team, bool buffed)
{
	return BasicBones(pos, ang, team, buffed).index;
}

public int Summon_BeefyBones(float pos[3], float ang[3], int team, bool buffed)
{
	return BeefyBones(pos, ang, team, buffed).index;
}

public int Summon_BrittleBones(float pos[3], float ang[3], int team, bool buffed)
{
	return BrittleBones(pos, ang, team, buffed).index;
}

public Action Summon_End(Handle end, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
		ssb.UsingAbility = false;
		ssb.Unpause();
		ssb.RevertSequence();
		ssb.DmgMult = 1.0;
		Summon_StopLoop(ssb);
	}

	return Plugin_Continue;
}

public void Summon_StopLoop(SupremeSpookmasterBones ssb)
{
	StopSound(ssb.index, SNDCHAN_AUTO, SND_SUMMON_LOOP);
	StopSound(ssb.index, SNDCHAN_AUTO, SND_SUMMON_LOOP);
}

public void Summon_DeleteMinions(SupremeSpookmasterBones ssb)
{
	for (int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int ent = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
		if (!IsValidEntity(ent))
			continue;

		CClotBody summoned = view_as<CClotBody>(ent);
		if (summoned.m_iBoneZoneSummoner == ssb.index)
		{
			float pos[3];
			WorldSpaceCenter(ent, pos);
			ParticleEffectAt(pos, PARTICLE_SUMMON_VANISH);

			RemoveEntity(ent);
		}
	}
}

public void Special_Spin(SupremeSpookmasterBones ssb, int target)
{
	ssb.UsingAbility = true;
	ssb.Pause();
	ssb.PlaySpinIntro();

	int iActivity = ssb.LookupActivity("ACT_SPIN2WIN_INTRO");
	if(iActivity > 0) ssb.StartActivity(iActivity);

	float begin = GetGameTime(ssb.index) + Spin_Delay[SSB_WavePhase] + 0.83;

	DataPack pack = new DataPack();
	RequestFrame(Spin_Begin, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, SSB_WavePhase);
	WritePackFloat(pack, begin);

	begin -= Spin_Delay[SSB_WavePhase];
	DataPack pack2 = new DataPack();
	RequestFrame(Spin_IntroLogic, pack2);
	WritePackCell(pack2, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack2, begin);
	WritePackFloat(pack2, GetGameTime(ssb.index) + 0.3);
}

public void Spin_IntroLogic(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float endTime = ReadPackFloat(pack);
	float hammerSpawn = ReadPackFloat(pack);

	delete pack;

	if (!IsEntityAlive(ent))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
	float gt = GetGameTime(ssb.index);
	if (gt >= endTime)
	{
		int iActivity = ssb.LookupActivity("ACT_SPIN2WIN_INTRO_LOOP");
		if(iActivity > 0) ssb.StartActivity(iActivity);
		return;
	}

	if (gt >= hammerSpawn)
	{
		//TODO: Hammer spawn VFX/SFX
		hammerSpawn += 999999.0;
	}

	pack = new DataPack();
	RequestFrame(Spin_IntroLogic, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, hammerSpawn);
}

public void Spin_Begin(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float startTime = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	float gt = GetGameTime(user);
	if (gt >= startTime)
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

		ssb.Unpause();
		b_NoKnockbackFromSources[ssb.index] = true;

		SSB_Movement_Data_ReadValues(ssb);
		ssb.m_flSpeed = Spin_Speed[phase];
		ssb.GetBaseNPC().flFrictionSideways = Spin_Friction[phase];
		ssb.GetBaseNPC().flFrictionForward = Spin_Friction[phase];
		ssb.GetBaseNPC().flAcceleration = Spin_Acceleration[phase];

		delete pack;
		pack = new DataPack();
		RequestFrame(Spin_Logic, pack);
		WritePackCell(pack, EntIndexToEntRef(user));
		WritePackCell(pack, phase);
		WritePackFloat(pack, GetGameTime(user) + Spin_Interval[phase]);
		WritePackFloat(pack, GetGameTime(user) + Spin_Duration[phase]);

		int iActivity = ssb.LookupActivity("ACT_SPIN2WIN_ACTIVE");
		if(iActivity > 0) ssb.StartActivity(iActivity);

		ssb.SetPlaybackRate(3.0 * (0.13 / Spin_Interval[SSB_WavePhase]));

		EmitSoundToAll(SND_SPIN2WIN_ACTIVE, ssb.index, _, 120);
		EmitSoundToAll(SND_PULL_ACTIVATED);
		
		float pos[3];
		GetEntPropVector(ssb.index, Prop_Data, "m_vecAbsOrigin", pos);
		ParticleEffectAt(pos, PARTICLE_TARTARUS_BEGIN, 2.0);

		for (int i = 1; i <= 8; i++)
		{
			char point[255];
			Format(point, sizeof(point), "hammer_%i", i);

			SSB_AttachParticle(ssb.index, i % 2 == 0 ? PARTICLE_SPIN_TRAIL_1 : PARTICLE_SPIN_TRAIL_2, Spin_Duration[SSB_WavePhase], point);
		}

		return;
	}

	RequestFrame(Spin_Begin, pack);
}

public void Spin_Logic(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float nextHit = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);
	float gt = GetGameTime(user);

	if (gt >= endTime)
	{
		ssb.SetPlaybackRate(1.0);
		SSB_Movement_Data_RestoreFromValues(ssb);

		if (Spin_StunTime[SSB_WavePhase] <= 0.0)
		{
			ssb.UsingAbility = false;
			ssb.RevertSequence();
		}
		else
		{
			ssb.PlayStun();
			ssb.Pause();
			int iActivity = ssb.LookupActivity("ACT_SPIN2WIN_STUNNED");
			if(iActivity > 0) ssb.StartActivity(iActivity);

			SSB_AttachParticle(ssb.index, PARTICLE_STUNNED, Spin_StunTime[SSB_WavePhase], "root", 100.0);

			CreateTimer(Spin_StunTime[SSB_WavePhase], Spin_StopStun, EntIndexToEntRef(ssb.index), TIMER_FLAG_NO_MAPCHANGE);
		}

		b_NoKnockbackFromSources[ssb.index] = false;

		return;
	}

	if (gt >= nextHit)
	{
		float pos[3];
		WorldSpaceCenter(ssb.index, pos);

		bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Spin_DMG[phase], ssb.index, ssb.index, 0, pos, Spin_Radius[phase], 1.0, 1.0, isBlue, 999, _, Spin_EntityMult[phase], Spin_OnHit);

		int pitch = GetRandomInt(70, 120);
		EmitSoundToAll(SND_SPIN_WHOOSH, ssb.index, _, 120, _, _, pitch);
		EmitSoundToAll(SND_SPIN_WHOOSH, ssb.index, _, 120, _, _, pitch);
		EmitSoundToAll(SND_SPIN_WHOOSH, ssb.index, _, 120, _, _, pitch);

		nextHit = gt + Spin_Interval[phase];
	}

	pack = new DataPack();
	RequestFrame(Spin_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, nextHit);
	WritePackFloat(pack, endTime);
}

public Action Spin_StopStun(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
		ssb.UsingAbility = false;
		ssb.RevertSequence();
		ssb.Unpause();
	}

	return Plugin_Continue;
}

public void Spin_OnHit(int attacker, int victim, float damage, int weapon)
{
	EmitSoundToAll(SND_SPIN_HIT, victim, _, _, _, _, GetRandomInt(70, 100));

	float dummy[3], pos[3], pos2[3], ang[3];
	WorldSpaceCenter(victim, pos2);
	Priest_GetAngleToPoint(attacker, pos, pos2, dummy, ang);

	if (ang[0] > -20.0)
		ang[0] = -20.0;

	GetAngleVectors(ang, dummy, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dummy, Spin_KB[SSB_WavePhase]);

	float vel[3];
	GetEntPropVector(victim, Prop_Data, "m_vecVelocity", vel);
	for (int vec = 0; vec < 3; vec++)
		vel[vec] += dummy[vec];

	TeleportEntity(victim, _, _, vel);
}

public void Special_Hell(SupremeSpookmasterBones ssb, int target)
{
	ssb.UsingAbility = true;
	ssb.Pause();
	ssb.PlayHellIntro();
	ssb.DmgMult = Hell_Resistance[SSB_WavePhase];

	int iActivity = ssb.LookupActivity("ACT_HELL_IS_HERE_INTRO");
	if(iActivity > 0) ssb.StartActivity(iActivity);

	float begin = GetGameTime(ssb.index) + Hell_Delay[SSB_WavePhase] + 1.1;

	DataPack pack = new DataPack();
	RequestFrame(Hell_Begin, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, SSB_WavePhase);
	WritePackFloat(pack, begin);

	begin -= Hell_Delay[SSB_WavePhase];
	DataPack pack2 = new DataPack();
	RequestFrame(Hell_IntroLogic, pack2);
	WritePackCell(pack2, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack2, begin);
	WritePackFloat(pack2, GetGameTime(ssb.index) + 0.6);
}

public void Hell_IntroLogic(DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float endTime = ReadPackFloat(pack);
	float fireball = ReadPackFloat(pack);

	delete pack;

	if (!IsEntityAlive(ent))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(ent);
	float gt = GetGameTime(ssb.index);
	if (gt >= endTime)
	{
		int iActivity = ssb.LookupActivity("ACT_HELL_IS_HERE_CHARGING");
		if(iActivity > 0) ssb.StartActivity(iActivity);
		return;
	}

	if (gt >= fireball)
	{
		EmitSoundToAll(SND_HELL_STOMP, ssb.index, _, 120);
		Hell_Fireball[ssb.index] = EntIndexToEntRef(SSB_AttachParticle(ssb.index, PARTICLE_HELLISHERE_HEAD, _, "head", -10.0));

		fireball += 999999.0;
	}

	pack = new DataPack();
	RequestFrame(Hell_IntroLogic, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, fireball);
}

public void Hell_RemoveParticle(int entity)
{
	int part = EntRefToEntIndex(Hell_Fireball[entity]);
	if (IsValidEntity(part))
		RemoveEntity(part);
}

public void Hell_Begin(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float startTime = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	float gt = GetGameTime(user);
	if (gt >= startTime)
	{
		SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);

		delete pack;
		pack = new DataPack();
		RequestFrame(Hell_Logic, pack);
		WritePackCell(pack, EntIndexToEntRef(user));
		WritePackCell(pack, phase);
		WritePackFloat(pack, GetGameTime(user) + Hell_Interval[phase]);
		WritePackFloat(pack, GetGameTime(user) + Hell_Duration[phase]);
		WritePackFloat(pack, 0.0);

		int iActivity = ssb.LookupActivity("ACT_HELL_IS_HERE_ACTIVE");
		if(iActivity > 0) ssb.StartActivity(iActivity);

		float spin = (Hell_SpinSpeed[phase] / 360.0) * 63.0;
		ssb.SetPlaybackRate(spin);
		//ssb.SetPlaybackRate(0.25 / Hell_Interval[phase]);

		EmitSoundToAll(SND_HELL_BEGIN, ssb.index, _, 120);

		return;
	}

	RequestFrame(Hell_Begin, pack);
}

public void Hell_Logic(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float nextWave = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	float rotation = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);
	float gt = GetGameTime(user);

	if (gt >= endTime)
	{
		ssb.SetPlaybackRate(1.0);
		ssb.UsingAbility = false;
		ssb.RevertSequence();
		ssb.Unpause();
		ssb.DmgMult = 1.0;
		EmitSoundToAll(SND_HELL_END, ssb.index, _, 120);
		Hell_RemoveParticle(ssb.index);

		return;
	}

	if (gt >= nextWave)
	{
		int pitch = GetRandomInt(70, 120);
		EmitSoundToAll(SND_HELL_FIRE, ssb.index, _, 120, _, _, pitch);

		int ent = EntRefToEntIndex(Hell_Fireball[ssb.index]);
		if (IsValidEntity(ent))
		{
			float pos[3], ang[3], attachmentAng[3];
			GetAttachment(ssb.index, "head", pos, attachmentAng);
			GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", pos);
			GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
			
			ang[1] = attachmentAng[1];

			Hell_ShootWave(ssb, pos, ang);
		}

		nextWave = gt + Hell_Interval[phase];
	}

	pack = new DataPack();
	RequestFrame(Hell_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, nextWave);
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, rotation + Hell_SpinSpeed[phase]);
}

public void Hell_ShootWave(SupremeSpookmasterBones ssb, float pos[3], float ang[3])
{
	float testAng[3];
	testAng[0] = 0.0;
	testAng[1] = ang[1];
	testAng[2] = 0.0;
				
	GetPointFromAngles(pos, testAng, 20.0, pos, Priest_IgnoreAll, MASK_SHOT);

	int num = Hell_Count[SSB_WavePhase];
	NightmareVolley_ShootSkull(ssb, pos, ang, Volley_Velocity[SSB_WavePhase]);
	num--;

	if (num < 1)
		return;

	for (int i = 0; i < num; i++)
	{
		float randAng[3], randPos[3];
		randPos = pos;
		randAng = ang;
		for (int vec = 0; vec < 2; vec++)
			randAng[vec] += GetRandomFloat(-60.0, 60.0);

		GetPointFromAngles(pos, randAng, GetRandomFloat(0.0, Hell_Distance[SSB_WavePhase]), randPos, Priest_OnlyHitWorld, MASK_SHOT);

		int attempts = 10;	//SSB can sometimes try to use this attack in a position where the skulls would spawn in a wall, which causes script execution timeout. This is a hack which fixes that. I may or may not eventually add a REAL fix, but for now, this will do.
		while (NightmareVolley_WouldSkullCollide(pos) && attempts > 0)	//Don't let skulls spawn in places where they would collide with something
		{
			GetPointFromAngles(pos, randAng, GetRandomFloat(0.0, Hell_Distance[SSB_WavePhase]), randPos, Priest_OnlyHitWorld, MASK_SHOT);
			attempts--;
		}

		randAng = ang;
		for (int vec = 0; vec < 3; vec++)
			randAng[vec] += GetRandomFloat(-Hell_Spread[SSB_WavePhase], Hell_Spread[SSB_WavePhase]);

		Hell_ShootSkull(ssb, randPos, randAng, Hell_Velocity[SSB_WavePhase]);
	}
}

public void Hell_ShootSkull(SupremeSpookmasterBones ssb, float pos[3], float ang[3], float vel)
{
	int skull = SSB_CreateProjectile(ssb, MODEL_SKULL, pos, ang, vel, GetRandomFloat(0.8, 1.2), Hell_Collide);
	if (IsValidEntity(skull))
	{
		b_IsHoming[skull] = false;
		i_SkullParticle[skull] = EntIndexToEntRef(SSB_AttachParticle(skull, PARTICLE_FIREBALL_RED, _, ""));
		CreateTimer(Hell_HomingDelay[SSB_WavePhase], Hell_StartHoming, EntIndexToEntRef(skull), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Hell_StartHoming(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	int particle = EntRefToEntIndex(i_SkullParticle[ent]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);

	i_SkullParticle[ent] = EntIndexToEntRef(SSB_AttachParticle(ent, PARTICLE_FIREBALL_BLUE, _, ""));

	EmitSoundToAll(SND_HOMING_ACTIVATE, ent, _, 120, _, _, GetRandomInt(80, 110));
	EmitSoundToAll(Hell_HomingSFX[GetRandomInt(0, sizeof(Hell_HomingSFX) - 1)], ent, _, 120, _, _, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	float ang[3];
	GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
	Initiate_HomingProjectile(ent, owner, Hell_HomingAngle[SSB_WavePhase], Hell_HomingPerSecond[SSB_WavePhase], false, true, ang);
	b_IsHoming[ent] = true;

	return Plugin_Continue;
}

public MRESReturn Hell_Collide(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

	ParticleEffectAt(position, b_IsHoming[entity] ? PARTICLE_EXPLOSION_FIREBALL_BLUE : PARTICLE_EXPLOSION_FIREBALL_RED, 1.0);

	EmitSoundToAll(SND_FIREBALL_EXPLODE, entity);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(IsValidEntity(owner))
	{
		bool isBlue = GetEntProp(owner, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Hell_DMG[SSB_WavePhase], owner, entity, 0, position, Hell_Radius[SSB_WavePhase], Hell_Falloff_MultiHit[SSB_WavePhase],
		Hell_Falloff_Radius[SSB_WavePhase], isBlue, Hell_MaxTargets[SSB_WavePhase], true, Hell_EntityMult[SSB_WavePhase]);
	}

	RemoveEntity(entity);
	return MRES_Supercede;
}

public void Special_Harvester(SupremeSpookmasterBones ssb, int target)
{
	ssb.UsingAbility = true;
	ssb.Pause();
	//ssb.PlayHarvesterIntro();
	ssb.DmgMult = Harvester_Resistance[SSB_WavePhase];
	//TODO: Needs intro sequence

	//int iActivity = ssb.LookupActivity("ACT_SUMMONERS_STANCE_INTRO");
	//if(iActivity > 0) ssb.StartActivity(iActivity);

	float begin = GetGameTime(ssb.index) + Harvester_Delay[SSB_WavePhase];

	DataPack pack = new DataPack();
	RequestFrame(Harvester_Begin, pack);
	WritePackCell(pack, EntIndexToEntRef(ssb.index));
	WritePackCell(pack, SSB_WavePhase);
	WritePackFloat(pack, begin);
}

public void Harvester_Begin(DataPack pack)
{
	ResetPack(pack);
	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float startTime = ReadPackFloat(pack);

	if (!IsValidEntity(user))
	{
		delete pack;
		return;
	}

	float gt = GetGameTime(user);
	if (gt >= startTime)
	{
		//TODO: Sound, animation

		delete pack;
		pack = new DataPack();
		RequestFrame(Harvester_Logic, pack);
		WritePackCell(pack, EntIndexToEntRef(user));
		WritePackCell(pack, phase);
		WritePackFloat(pack, gt + Harvester_Duration[phase]);
		WritePackFloat(pack, gt + 0.1);

		return;
	}

	RequestFrame(Harvester_Begin, pack);
}

public void Harvester_Logic(DataPack pack)
{
	ResetPack(pack);

	int user = EntRefToEntIndex(ReadPackCell(pack));
	int phase = ReadPackCell(pack);
	float endTime = ReadPackFloat(pack);
	float nextHit = ReadPackFloat(pack);

	delete pack;

	if (!IsValidEntity(user))
		return;

	SupremeSpookmasterBones ssb = view_as<SupremeSpookmasterBones>(user);
	float gt = GetGameTime(ssb.index);

	if (gt >= endTime)
	{
		ssb.UsingAbility = false;
		ssb.Unpause();
		ssb.RevertSequence();
		ssb.DmgMult = 1.0;

		return;
	}

	if (gt >= nextHit)
	{
		float pos[3];
		GetEntPropVector(ssb.index, Prop_Data, "m_vecAbsOrigin", pos);

		bool isBlue = GetEntProp(ssb.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
		Explode_Logic_Custom(Harvester_DMG[phase], ssb.index, ssb.index, 0, pos, Harvester_Radius[phase], 1.0, 1.0, isBlue, 9999, _, Harvester_EntityMult[phase], Harvester_OnHit);

		nextHit = gt + 0.1;

		spawnRing_Vectors(pos, Harvester_Radius[phase] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 0, 60, 255, 255, 1, 0.1, 16.0, 2.0, 1);
	}

	pack = new DataPack();
	RequestFrame(Harvester_Logic, pack);
	WritePackCell(pack, EntIndexToEntRef(user));
	WritePackCell(pack, phase);
	WritePackFloat(pack, endTime);
	WritePackFloat(pack, nextHit);
}

public void Harvester_OnHit(int attacker, int victim, float damage, int weapon)
{
	int healing = RoundToCeil(damage * Harvester_HealRatio[SSB_WavePhase]);
	if (healing > 0 && victim > 0 && victim < MaxClients)
	{
		int hp = GetEntProp(attacker, Prop_Data, "m_iHealth");

		//This should never happen, but just to be safe...
		if (hp <= 0)
			return;

		int maxHP = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");

		hp += healing;
		if (hp > maxHP)
			hp = maxHP;

		SetEntProp(attacker, Prop_Data, "m_iHealth", hp);
	}

	float userPos[3], vicPos[3];
	WorldSpaceCenter(attacker, userPos);
	WorldSpaceCenter(victim, vicPos);

	float multiplier = 1.0 - (GetVectorDistance(userPos, vicPos) / Harvester_Radius[SSB_WavePhase]);
	if (multiplier < Harvester_MinPullStrengthMultiplier[SSB_WavePhase])
		multiplier = Harvester_MinPullStrengthMultiplier[SSB_WavePhase];

	float pullStrength = Harvester_PullStrength[SSB_WavePhase] * multiplier;

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

	//TODO: VFX, play sound at victim's location
}

bool SSB_UsingAbility[MAXENTITIES];
bool SSB_Paused[MAXENTITIES];
float SSB_DMGMult[MAXENTITIES];

methodmap SupremeSpookmasterBones < CClotBody
{
	property bool UsingAbility
	{
		public get() { return SSB_UsingAbility[this.index]; }
		public set(bool value) { SSB_UsingAbility[this.index] = value; }
	}

	property float DmgMult
	{
		public get() { return SSB_DMGMult[this.index]; }
		public set(float value) { SSB_DMGMult[this.index] = value; }
	}

	public void Pause()
	{
		SSB_Paused[this.index] = true;
		this.StopPathing();
		this.m_bPathing = false;
		b_NoKnockbackFromSources[this.index] = true;
		/*SSB_Movement_Data_ReadValues(this);
		this.m_flSpeed = 0.0;
		this.GetBaseNPC().flFrictionSideways = 999999.0;
		this.GetBaseNPC().flFrictionForward = 999999.0;
		this.GetBaseNPC().flAcceleration = 0.0;*/
	}

	public void Unpause()
	{
		//SSB_Movement_Data_RestoreFromValues(this);
		SSB_Paused[this.index] = false;
		b_NoKnockbackFromSources[this.index] = false;
		this.StartPathing();
		this.m_bPathing = true;
	}

	public void GiveTime(float amt) { RaidModeTime += amt; }

	public void RevertSequence()
	{
		int iActivity = this.LookupActivity("ACT_STAND_NO_HAMMER");
		if(iActivity > 0) this.StartActivity(iActivity);
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

	public void PlayGenericWindup()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBGenericWindup_Sounds) - 1);
		EmitSoundToAll(g_SSBGenericWindup_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBGenericWindup_Captions[rand]);


		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayNecroBlastWarning()");
		#endif
	}

	public void PlayStun()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBStunned_Sounds) - 1);
		EmitSoundToAll(g_SSBStunned_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBStunned_Captions[rand]);
		EmitSoundToAll(SND_STUNNED);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayNecroBlastWarning()");
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

	public void PlayNecroBlastWarning()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBNecroBlastWarning_Sounds) - 1);
		EmitSoundToAll(g_SSBNecroBlastWarning_Sounds[rand], _, _, 120);
		EmitSoundToAll(SND_NECROBLAST_CHARGEUP, _, _, 120);

		CPrintToChatAll(g_SSBNecroBlastWarning_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayNecroBlastWarning()");
		#endif
	}

	public void PlayNecroBlast()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBNecroBlast_Sounds) - 1);
		EmitSoundToAll(g_SSBNecroBlast_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBNecroBlast_Captions[rand]);
		EmitSoundToAll(SND_NECROBLAST_EXTRA_1, _, _, 120, _, _, GetRandomInt(70, 90));
		EmitSoundToAll(SND_NECROBLAST_BIGBANG, _, _, 120);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayNecroBlast()");
		#endif
	}

	public void PlaySummonerIntro()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBSummonIntro_Sounds) - 1);
		EmitSoundToAll(g_SSBSummonIntro_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBSummonIntro_Captions[rand]);
		EmitSoundToAll(SND_SUMMON_INTRO, _, _, _, _, _, GetRandomInt(80, 110));
		EmitSoundToAll(SND_SUMMON_LOOP, this.index, _, 120, _, 0.8, 85);
		EmitSoundToAll(SND_SUMMON_LOOP, this.index, _, 120, _, 0.8, 85);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlaySummonerIntro()");
		#endif
	}

	public void PlaySpinIntro()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBSpin2Win_Sounds) - 1);
		EmitSoundToAll(g_SSBSpin2Win_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBSpin2Win_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlaySpinIntro()");
		#endif
	}

	public void PlayHellIntro()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBHellIsHere_Sounds) - 1);
		EmitSoundToAll(g_SSBHellIsHere_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBHellIsHere_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlaySpinIntro()");
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
	
	public SupremeSpookmasterBones(float vecPos[3], float vecAng[3], int ally)
	{
		SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(CClotBody(vecPos, vecAng, MODEL_SSB, BONES_SUPREME_SCALE, BONES_SUPREME_HP, ally));
		
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
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

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

		//TODO: Adjust this to account for 40-wave games as well as the standard 60-waves
		int wave = Waves_GetRound() + 1;
		if (wave <= 15)
			SSB_WavePhase = 0;
		else if (wave <= 30)
			SSB_WavePhase = 1;
		else if (wave <= 45)
			SSB_WavePhase = 2;
		else
			SSB_WavePhase = 3;

		npc.m_flSpeed = BONES_SUPREME_SPEED[SSB_WavePhase];

		npc.CalculateNextSpecial();
		npc.CalculateNextSpellCard();
		npc.UsingAbility = false;
		npc.DmgMult = 1.0;

		RaidModeScaling = SSB_RaidPower[SSB_WavePhase];
		RaidModeTime = GetGameTime(npc.index) + SSB_RaidTime[SSB_WavePhase];
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

		switch (SSB_WavePhase)
		{
			case 0:
			{
				npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, "eye_powerup_green_lvl_1", npc.index, "righteye", {0.0,0.0,0.0});
				npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, "eye_powerup_green_lvl_1", npc.index, "lefteye", {0.0,0.0,0.0});
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Bones");
			}
			case 1:
			{
				npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, "eye_powerup_green_lvl_2", npc.index, "righteye", {0.0,0.0,0.0});
				npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, "eye_powerup_green_lvl_2", npc.index, "lefteye", {0.0,0.0,0.0});
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Spookmaster Bones");
			}
			case 2:
			{
				npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, "eye_powerup_green_lvl_3", npc.index, "righteye", {0.0,0.0,0.0});
				npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, "eye_powerup_green_lvl_3", npc.index, "lefteye", {0.0,0.0,0.0});
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Supreme Spookmaster Bones");
			}
			default:
			{
				npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, "eye_powerup_green_lvl_4", npc.index, "righteye", {0.0,0.0,0.0});
				npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, "eye_powerup_green_lvl_4", npc.index, "lefteye", {0.0,0.0,0.0});
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Supreme Spookmaster Bones");
			}
		}

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
			npc.SetGoalEntity(closest);
			npc.FaceTowards(targPos, 225.0);
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
		npc.StopPathing();
		
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
	
	if (npc.DmgMult != 1.0)
		damage *= npc.DmgMult;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	Summon_DamageTracker[victim] += damage;
	if (Summon_DamageTracker[victim] >= (float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * Summon_HPCost[SSB_WavePhase])
	&& !npc.UsingAbility)
	{
		int slot = npc.GetAbilityByName("MASTER OF THE DAMNED");
		if (slot > -1)
			npc.ActivateSpecial(-1, slot);
		else
		{
			slot = npc.GetSpellByName("MASTER OF THE DAMNED");
			if (slot > -1)
				npc.CastSpell(-1, slot);
		}

		Summon_DamageTracker[victim] = 0.0;
	}
//	
	return Plugin_Changed;
}

public void SupremeSpookmasterBones_NPCDeath(int entity)
{
	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(entity);

	npc.PlayMinorLoss();	//TODO: He needs to have a more cinematic death sequence when defeated on wave 60.
		
	npc.RemoveAllWearables();
	Summon_StopLoop(npc);
	Summon_DeleteMinions(npc);
	Hell_RemoveParticle(entity);

	RemoveEntity(entity);
	//AcceptEntityInput(npc.index, "KillHierarchy");
}

int SSB_CreateProjectile(SupremeSpookmasterBones owner, char model[255], float pos[3], float ang[3], float velocity, float scale, DHookCallback CollideCallback, int skin = 0)
{
	int prop = CreateEntityByName("tf_projectile_rocket");
			
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
	//	SetEntPropVector(entity, Prop_Data, "m_vInitialVelocity", vecForward);
		
		if (h_NpcSolidHookType[prop] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[prop]);
		h_NpcSolidHookType[prop] = 0;

		h_NpcSolidHookType[prop] = g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);

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

public float SSB_GetDistanceToGround(float pos[3])
{
	float angles[3], otherLoc[3];
	angles[0] = 90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Handle trace = TR_TraceRayFilterEx(pos, angles, MASK_SHOT, RayType_Infinite, Priest_OnlyHitWorld);
	TR_GetEndPosition(otherLoc, trace);
	delete trace;
	
	return GetVectorDistance(pos, otherLoc);
}

void SSB_BigVFX(bool shake = true, float shakeAmplitude = 50.0, float shakeFrequency = 150.0, float shakeDuration = 2.5, bool flash = true, float flashDuration = 0.1)
{
	if (!shake && !flash)
		return;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (shake)
				Client_Shake(i, SHAKE_START, shakeAmplitude, shakeFrequency, shakeDuration);

			if (flash)
			{
				DoOverlay(i, "lights/white005", 0);
				CreateTimer(flashDuration, SSB_RemoveFlash, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action SSB_RemoveFlash(Handle helpmeimblind, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
		DoOverlay(client, "");
		
	return Plugin_Continue;
}