#pragma semicolon 1
#pragma newdecls required

#define BONES_JESTER_HP			"300"
#define BONES_JESTER_HP_BUFFED	"600"

#define BONES_JESTER_SKIN		"2"
#define BONES_JESTER_SKIN_BUFFED	"2"

#define BONES_JESTER_SCALE		 "1.0"
#define BONES_JESTER_SCALE_BUFFED "1.2"

#define BONES_JESTER_BUFFPARTICLE	"utaunt_wispy_parent_g"

#define PARTICLE_JESTER_FUSE		"fuse_sparks"
#define PARTICLE_JESTER_FUSE_BUFFED	"spell_fireball_small_red"

#define PARTICLE_MONDO_SUMMON_BLAST	"merasmus_object_spawn"
#define PARTICLE_MONDO_SUMMON_BOLTS	"merasmus_zap"
#define PARTICLE_MONDO_BLAST_BIG	"hammer_impact_button"
#define PARTICLE_MONDO_BLAST_SMALL	"ExplosionCore_MidAir"
#define PARTICLE_MONDO_LAND			"taunt_flip_land_dust2"
#define PARTICLE_JESTER_BOMB_TELEPORT	"teleported_blue"

static float BONES_JESTER_SPEED = 280.0;
static float BONES_JESTER_SPEED_BUFFED = 180.0;
static float JESTER_NATURAL_BUFF_CHANCE = 0.0;			//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float JESTER_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float JESTER_NATURAL_BUFF_LEVEL = 100.0;				//The average level at which level_modifier reaches its max.

//FEARSOME FOOL (Non-Buffed Variant):
//A jester who juggles two large cannonballs. When an enemy gets close enough, it will throw both bombs at them.
//It must stop juggling before it can throw the bombs, which takes approximately one full second.
static float BONES_JESTER_ATTACKINTERVAL = 3.0;		//Delay between attacks.
static float BONES_JESTER_RANGE = 800.0;			//Attack range.
static float BONES_JESTER_MAX_RANGE = 800.0;		//Distance from its target at which the jester will continue moving.
static float BONES_JESTER_OPTIMAL_RANGE = 400.0;	//Distance from its target at which the jester will stop moving.
static float BONES_JESTER_RANGE_PREDICT = 300.0;	//Range at which the jester will predict its target's location when throwing bombs.
static float BONES_JESTER_VELOCITY = 1600.0;		//Projectile velocity.
static float BONES_JESTER_DAMAGE = 140.0;			//Explosive damage.
static float BONES_JESTER_ENTITYMULT = 18.0;		//Amount to multiply damage dealt to entities.
static float BONES_JESTER_RADIUS = 150.0;			//Explosive radius.
static float BONES_JESTER_FALLOFF_RADIUS = 0.8;		//Maximum damage lost based on distance from the center of the blast.
static float BONES_JESTER_FALLOFF_MULTIHIT = 0.66;	//Amount to multiply damage dealt per enemy hit by explosions.
static float BONES_JESTER_GRAVITY = 0.66;			//Projectile gravity.
static float BONES_JESTER_ATTACK_DELAY = 6.0;		//Delay after spawning before it can attack.
static float BONES_JESTER_ATTACK_DELAY_TRANSFORM = 2.0;	//Delay after transforming before it can attack.
static float BONES_JESTER_ATTACK_DELAY_HOLDING = 0.0;	//Delay after both bombs have stopped juggling before the Jester can throw its bombs.
static float BONES_JESTER_TOO_CLOSE = 200.0;		//Range at which the Jester will attempt to run away if an enemy is too close.
static int BONES_JESTER_WEIGHT = 1;

//SERVANT OF MONDO (Buffed Variant):
//A deranged cultist who worships a figure known only as "Mondo". Moves very slowly while carrying an enormous bomb on its back.
//When it is ready to attack, it tosses this bomb up into the air, waits for it to fall back down, and then punches it, sending it flying straight forwards.
//The bomb explodes on contact and inflicts devastating damage within an enormous radius.
static float BONES_MONDO_ATTACKINTERVAL = 6.0;		//Delay between attacks.
static float BONES_MONDO_RANGE = 1800.0;			//Range in which the attack will begin.
static float BONES_MONDO_MAX_RANGE = 800.0;			//Distance from its target at which the Servant of Mondo will continue moving.
static float BONES_MONDO_OPTIMAL_RANGE = 400.0;		//Distance from its target at which the Servant of Mondo will stop moving.
static float BONES_MONDO_VELOCITY = 2800.0;			//Projectile velocity.
static float BONES_MONDO_DAMAGE = 1800.0;			//Blast damage.
static float BONES_MONDO_ENTITYMULT = 24.0;			//Amount to multiply damage dealt to entities.
static float BONES_MONDO_RADIUS = 400.0;			//Blast radius.
static float BONES_MONDO_FALLOFF_RADIUS = 0.5;		//Maximum damage falloff based on distance from the center of the blast.
static float BONES_MONDO_FALLOFF_MULTIHIT = 0.9;	//Amount to multiply damage dealt per target hit.
static float BONES_MONDO_GRAVITY = 0.66;			//Projectile gravity.
static float BONES_MONDO_ATTACK_DELAY = 12.0;			//Delay before attacking upon spawning. Must be above 0.5 or else the cannonball doesn't show up on time.
static float BONES_MONDO_ATTACK_DELAY_TRANSFORM = 3.0;	//Delay before attacking upon transforming. Must be above 0.5 or else the cannonball doesn't show up on time.
static float BONES_MONDO_ATTACK_TURNRATE = 200.0;		//Rate at which the Servant of Mondo can turn to face its target while preparing to throw.
static int BONES_MONDO_WEIGHT = 999;
static float BONES_MONDO_TOO_CLOSE = 200.0;			//Range at which the Servant of Mondo will attempt to run away if an enemy is too close.

static float BONES_MONDO_MULTIPLIER_DEATH = 0.5;		//Amount to multiply damage and radius of bombs dropped when the Servant of Mondo dies.
static float BONES_MONDO_VELOCITY_DEATH = 1200.0;		//Death bomb velocity.
static float BONES_MONDO_GRAVITY_DEATH = 3.0;			//Death bomb gravity.

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

#define SOUND_JESTER_FUSE	")misc/halloween/hwn_bomb_fuse.wav"
#define SOUND_MONDO_ATTACK_BIGSWING	")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_MONDO_ATTACK_SWING	")weapons/machete_swing.wav"
#define SOUND_MONDO_ATTACK_LAUNCH_1	")weapons/bumper_car_hit_ball.wav"
#define SOUND_MONDO_ATTACK_LAUNCH_2	")weapons/bumper_car_jump.wav"
#define SOUND_MONDO_ATTACK_LAUNCH_3	")misc/halloween/strongman_fast_impact.wav"
#define SOUND_MONDO_ATTACK_SUMMON	")misc/halloween/merasmus_spell.wav"
#define SOUND_MONDO_ATTACK_INTRO	")player/cyoa_pda_shake.wav"
#define SOUND_MONDO_ATTACK_LAND		")weapons/bumper_car_hit1.wav"
#define SOUND_MONDO_EXPLODE			")misc/doomsday_missile_explosion.wav"
#define SOUND_JESTER_JUGGLE_IMPACT	")weapons/fist_hit_world1.wav"
#define SOUND_JESTER_JUGGLE_TOSS	")weapons/machete_swing.wav"
#define SOUND_JESTER_BOMB_TELEPORT		")misc/halloween/spell_teleport.wav"
#define SOUND_JESTER_EXPLODE		")weapons/explode1.wav"

#define MODEL_JESTER_CANNONBALL		"models/weapons/w_models/w_cannonball.mdl"

static bool b_MondoAttacking[2049] = { false, ... };
static bool b_IsDeathBomb[2049] = { false, ... };
static bool Jester_HoldingLeft[2049] = { false, ... };
static bool Jester_HoldingRight[2049] = { false, ... };
static float Jester_HoldingBothTime[2049] = { 0.0, ... };

public void JesterBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SOUND_JESTER_FUSE);
	PrecacheSound(SOUND_MONDO_ATTACK_BIGSWING);
	PrecacheSound(SOUND_MONDO_ATTACK_SWING);
	PrecacheSound(SOUND_MONDO_ATTACK_LAUNCH_1);
	PrecacheSound(SOUND_MONDO_ATTACK_LAUNCH_2);
	PrecacheSound(SOUND_MONDO_ATTACK_LAUNCH_3);
	PrecacheSound(SOUND_MONDO_ATTACK_SUMMON);
	PrecacheSound(SOUND_MONDO_ATTACK_INTRO);
	PrecacheSound(SOUND_MONDO_ATTACK_LAND);
	PrecacheSound(SOUND_MONDO_EXPLODE);
	PrecacheSound(SOUND_JESTER_JUGGLE_IMPACT);
	PrecacheSound(SOUND_JESTER_JUGGLE_TOSS);
	PrecacheSound(SOUND_JESTER_BOMB_TELEPORT);
	PrecacheSound(SOUND_JESTER_EXPLODE);
	PrecacheModel(MODEL_JESTER_CANNONBALL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fearsome Fool");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_jester");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Servant of Mondo");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_jester_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return JesterBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return JesterBones(client, vecPos, vecAng, ally, true);
}

methodmap JesterBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		if (!b_BonesBuffed[this.index])
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, 120, _, _, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayMeleeHitSound()");
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
	
	public void PlayMondoAttackIntro()
	{
		EmitSoundToAll(SOUND_MONDO_ATTACK_BIGSWING, this.index, _, 110, _, _, GetRandomInt(80, 100));
	}

	public void PlayMondoAttackSwing()
	{
		EmitSoundToAll(SOUND_MONDO_ATTACK_SWING, this.index, _, 110, _, 0.66, 80);
		EmitSoundToAll(SOUND_MONDO_ATTACK_SWING, this.index, _, 110, _, 0.66, 80);
		EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], this.index);
	}

	public void PlayMondoAttackLaunch()
	{
		EmitSoundToAll(SOUND_MONDO_ATTACK_LAUNCH_1, this.index, _, 120, _, _, GetRandomInt(90, 110));
		EmitSoundToAll(SOUND_MONDO_ATTACK_LAUNCH_2, this.index, _, 120, _, _, GetRandomInt(90, 110));
		EmitSoundToAll(SOUND_MONDO_ATTACK_LAUNCH_3, this.index, _, 120, _, _, GetRandomInt(80, 90));
	}

	public void PlayMondoAttackSummonStart()
	{
		EmitSoundToAll(SOUND_MONDO_ATTACK_SWING, this.index, _, 110, _, 0.66, 80);
		EmitSoundToAll(SOUND_MONDO_ATTACK_SWING, this.index, _, 110, _, 0.66, 80);
	}

	public void PlayMondoAttackSummon()
	{
		EmitSoundToAll(SOUND_MONDO_ATTACK_SUMMON, this.index, _, _, _, _, GetRandomInt(80, 100));
		EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], this.index);
	}

	public void PlayMondoAttackEnd()
	{
		int pitch = GetRandomInt(80, 100);
		EmitSoundToAll(SOUND_MONDO_ATTACK_LAND, this.index, _, _, _, _, pitch);
		EmitSoundToAll(SOUND_MONDO_ATTACK_LAND, this.index, _, _, _, _, pitch);
	}

	public void PlayJuggleImpactSound(int source)
	{
		EmitSoundToAll(SOUND_JESTER_JUGGLE_IMPACT, source, _, _, _, 0.5, GetRandomInt(100, 140));
	}

	public void PlayJuggleThrowSound(int source)
	{
		EmitSoundToAll(SOUND_JESTER_JUGGLE_TOSS, source, _, _, _, 0.66, GetRandomInt(80, 120));
	}

	public void PlayThrowBombSound(int source)
	{
		int pitch = GetRandomInt(80, 120);
		EmitSoundToAll(SOUND_JESTER_JUGGLE_TOSS, source, _, 120, _, _, pitch);
		EmitSoundToAll(SOUND_JESTER_JUGGLE_TOSS, source, _, 120, _, _, pitch);

		EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], this.index, SNDCHAN_VOICE, _, _, _, GetRandomInt(80, 110));
	}
	
	public JesterBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = JESTER_NATURAL_BUFF_CHANCE;
			if (JESTER_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
			{
				float total;
				float players;
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						total += float(Level[i]);
						players += 1.0;
					}
				}
				
				float average = total / players;
				float mult = average / JESTER_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * JESTER_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		JesterBones npc;
		if (client > 0 && IsValidClient(client))
			npc = view_as<JesterBones>(BarrackBody(client, vecPos, vecAng, buffed && !randomlyBuffed ? BONES_JESTER_HP_BUFFED : BONES_JESTER_HP, BONEZONE_MODEL, _, buffed ? BONES_JESTER_SCALE_BUFFED : BONES_JESTER_SCALE));
		else
			npc = view_as<JesterBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_JESTER_SCALE_BUFFED : BONES_JESTER_SCALE, buffed && !randomlyBuffed ? BONES_JESTER_HP_BUFFED : BONES_JESTER_HP, ally, false));

		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_JESTER_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_JESTER_HP_BUFFED);
		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_JESTER_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_JESTER_SCALE_BUFFED);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_JESTER_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_JESTER_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Servant of Mondo");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Fearsome Fool");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(JesterBones_SetBuffed);
		b_MondoAttacking[npc.index] = false;

		func_NPCDeath[npc.index] = view_as<Function>(JesterBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(JesterBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(JesterBones_ClotThink);
		npc.m_bisWalking = false;
		Jester_HoldingLeft[npc.index] = false;
		Jester_HoldingRight[npc.index] = false;

		if (buffed)
		{
			int iActivity = npc.LookupActivity("ACT_JESTER_RUN_BUFFED");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Mondo_AnimEvent;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_MONDO_ATTACK_DELAY;
			npc.BoneZone_SetExtremeDangerState(true);
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_JESTER_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Jester_AnimEvent;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_JESTER_ATTACK_DELAY;
		}

		b_IsGiant[npc.index] = buffed;

		Jester_AttachFuseParticles(npc);
		//Jester_GiveCosmetics(npc, buffed);

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_JESTER_SKIN_BUFFED : BONES_JESTER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_JESTER_SPEED_BUFFED : BONES_JESTER_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void JesterBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);

	Jester_RemoveFuseParticles(npc);
	npc.RemoveAllWearables();
	npc.RemoveGesture("ACT_JESTER_HOLD_LEFT");
	npc.RemoveGesture("ACT_JESTER_HOLD_RIGHT");
	npc.RemoveGesture("ACT_JESTER_ATTACK");

	b_MondoAttacking[index] = false;

	Jester_HoldingLeft[npc.index] = false;
	Jester_HoldingRight[npc.index] = false;

	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_MONDO_ATTACK_DELAY_TRANSFORM;
		
		//Apply buffed stats:
		DispatchKeyValue(index, "skin", BONES_JESTER_SKIN_BUFFED);

		func_NPCAnimEvent[npc.index] = Mondo_AnimEvent;
		npc.m_blSetBuffedSkeletonAnimation = true;
		npc.m_blSetNonBuffedSkeletonAnimation = false;

		npc.BoneZone_SetExtremeDangerState(true);

		i_NpcWeight[index] = BONES_MONDO_WEIGHT;
		b_IsGiant[npc.index] = true;

		//Jester_GiveCosmetics(npc, true);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_JESTER_ATTACK_DELAY_TRANSFORM;

		//Remove buffed stats:
		DispatchKeyValue(index, "skin", BONES_JESTER_SKIN);
		func_NPCAnimEvent[npc.index] = Jester_AnimEvent;

		npc.m_blSetBuffedSkeletonAnimation = false;
		npc.m_blSetNonBuffedSkeletonAnimation = true;

		i_NpcWeight[index] = BONES_JESTER_WEIGHT;
		b_IsGiant[npc.index] = false;
		npc.BoneZone_SetExtremeDangerState(false);
		//Jester_GiveCosmetics(npc, false);
	}
}

static int Jester_LeftFuse[2049] = { -1, ... };
static int Jester_RightFuse[2049] = { -1, ... };

//Maybe I'll add cosmetics later, but really I feel like the GIANT BOMB is enough for Servant of Mondo, and Fearsome Fool gets its cosmetics via bodygroups.
/*void Jester_GiveCosmetics(CClotBody npc, bool buffed)
{
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/demo_hood.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/sum23_glorious_gambeson/sum23_glorious_gambeson.mdl");
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		DispatchKeyValue(npc.m_iWearable2, "skin", "1");
	}
	else
	{
		//We skip wearables 1 and 2 for the non-buffed variant because those are used for the bombs.
		npc.m_iWearable3 = npc.EquipItem("hat", "models/workshop/player/items/all_class/hwn2016_pestering_jester/hwn2016_pestering_jester_scout.mdl");
		npc.m_iWearable4 = npc.EquipItem("hat", "models/workshop/player/items/scout/hwn2023_last_laugh_style1/hwn2023_last_laugh_style1.mdl");
		npc.m_iWearable5 = npc.EquipItem("root", "models/workshop/player/items/scout/hwn2023_jumping_jester/hwn2023_jumping_jester.mdl");
		DispatchKeyValue(npc.m_iWearable3, "skin", "1");
		DispatchKeyValue(npc.m_iWearable4, "skin", "1");
		DispatchKeyValue(npc.m_iWearable5, "skin", "1");
	}
}*/

void Jester_AttachFuseParticles(CClotBody npc, bool left = true, bool right = true)
{
	float pos[3], ang[3];
	int particle = -1;

	Jester_RemoveFuseParticles(npc, left, right);

	if (!npc.BoneZone_GetBuffedState())
	{
		if (left)
		{
			npc.m_iWearable1 = npc.EquipItemSeperate(MODEL_JESTER_CANNONBALL, "", 1);
			if (IsValidEntity(npc.m_iWearable1))
			{
				SetParent(npc.index, npc.m_iWearable1, "bomb_left_center");
				GetAttachment(npc.m_iWearable1, "attach_fuse", pos, ang);
				DispatchKeyValue(npc.m_iWearable1, "skin", "1");

				particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE, npc.m_iWearable1, "attach_fuse");

				if (IsValidEntity(particle))
				{
					Jester_LeftFuse[npc.index] = EntIndexToEntRef(particle);
					EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, 0.5);
				}
			}
		}

		if (right)
		{
			npc.m_iWearable2 = npc.EquipItemSeperate(MODEL_JESTER_CANNONBALL, "", 1);
			if (IsValidEntity(npc.m_iWearable2))
			{
				SetParent(npc.index, npc.m_iWearable2, "bomb_right_center");
				GetAttachment(npc.m_iWearable2, "attach_fuse", pos, ang);
				DispatchKeyValue(npc.m_iWearable2, "skin", "1");

				particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE, npc.m_iWearable2, "attach_fuse");

				if (IsValidEntity(particle))
				{
					Jester_RightFuse[npc.index] = EntIndexToEntRef(particle);
					EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, 0.5);
				}
			}
		}
	}
	else
	{
		npc.GetAttachment("bomb_fuse_mondo", pos, ang);
		particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE_BUFFED, npc.index, "bomb_fuse_mondo");
		if (IsValidEntity(particle))
		{
			Jester_LeftFuse[npc.index] = EntIndexToEntRef(particle);
			EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, 0.5, 75);
		}
	}
}

//Replaces the Jester's bomb prop with one which is attached to its hand instead of the bomb attachment, or vice-versa.
//It needs to be done this way due to IKRules not working with hands.
void Jester_ReplaceBomb(CClotBody npc, bool left, bool right, bool StoppedJuggling)
{
	if (left)
	{
		int bomb = npc.m_iWearable1;
		if (IsValidEntity(bomb))
		{
			if (StoppedJuggling)
			{
				SetParent(npc.index, bomb, "bomb_left_holding");
			}
			else
			{
				SetParent(npc.index, bomb, "bomb_left_center");
			}
		}
	}
	if (right)
	{
		int bomb = npc.m_iWearable2;
		if (IsValidEntity(bomb))
		{
			if (StoppedJuggling)
			{
				SetParent(npc.index, bomb, "bomb_right_holding");
			}
			else
			{
				SetParent(npc.index, bomb, "bomb_right_center");
			}
		}
	}
}

void Jester_RemoveFuseParticles(CClotBody npc, bool left = true, bool right = true)
{
	int particle;
	int bomb;
	
	if (left)
	{
		particle = EntRefToEntIndex(Jester_LeftFuse[npc.index]);
		if (IsValidEntity(particle))
		{
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			RemoveEntity(particle);
		}

		if (!b_BonesBuffed[npc.index])
		{
			bomb = npc.m_iWearable1;
			if (IsValidEntity(bomb))
			{
				RemoveEntity(bomb);
			}
		}
	}

	if (right)
	{
		particle = EntRefToEntIndex(Jester_RightFuse[npc.index]);
		if (IsValidEntity(particle))
		{
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
			RemoveEntity(particle);
		}

		if (!b_BonesBuffed[npc.index])
		{
			bomb = npc.m_iWearable2;
			if (IsValidEntity(bomb))
			{
				RemoveEntity(bomb);
			}
		}
	}
}

//TODO 
//Rewrite
public void JesterBones_ClotThink(int iNPC)
{
	JesterBones npc = view_as<JesterBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	
	if (npc.m_blSetBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_JESTER_RUN_BUFFED");
		npc.m_blSetBuffedSkeletonAnimation = false;
		Jester_AttachFuseParticles(npc);
	}

	if (npc.m_blSetNonBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_JESTER_RUN");
		npc.m_blSetNonBuffedSkeletonAnimation = false;
		Jester_AttachFuseParticles(npc);
	}

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
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother);
				
		if (!Can_I_See_Enemy_Only(npc.index, closest))
		{
			npc.SetGoalEntity(closest);
			npc.StartPathing();
		}
		else
		{
			if (flDistanceToTarget <= (!b_BonesBuffed[npc.index] ? BONES_JESTER_TOO_CLOSE : BONES_MONDO_TOO_CLOSE))
			{
				npc.StartPathing();

				float optimalPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);

				if (GetDistanceToGround(optimalPos) <= 200.0)
				{
					npc.SetGoalVector(optimalPos, true);
					npc.StartPathing();
				}
				else
				{
					npc.StopPathing();
				}
			}
			else if (flDistanceToTarget <= (!b_BonesBuffed[npc.index] ? BONES_JESTER_OPTIMAL_RANGE : BONES_MONDO_OPTIMAL_RANGE))
			{
				npc.StopPathing();
				//npc.FaceTowards(vecTarget, 15000.0);
			}
			else
			{
				if (flDistanceToTarget > (!b_BonesBuffed[npc.index] ? BONES_JESTER_MAX_RANGE : BONES_MONDO_MAX_RANGE))
					npc.StartPathing();

				if (flDistanceToTarget < (npc.GetLeadRadius() * npc.GetLeadRadius()))
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
		}

		if (GetGameTime(npc.index) >= npc.m_flNextRangedAttack && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget) && flDistanceToTarget <= (!b_BonesBuffed[npc.index] ? BONES_JESTER_RANGE : BONES_MONDO_RANGE) && !b_MondoAttacking[npc.index])
		{
			if (b_BonesBuffed[npc.index])
			{
				int iActivity = npc.LookupActivity("ACT_JESTER_ATTACK_BUFFED");
				if(iActivity > 0) npc.StartActivity(iActivity);
				EmitSoundToAll(SOUND_MONDO_ATTACK_INTRO, npc.index);
				EmitSoundToAll(SOUND_MONDO_ATTACK_INTRO, npc.index);
				EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index);
				npc.StopPathing();
				npc.FaceTowards(vecTarget, 999999.0);

				b_MondoAttacking[npc.index] = true;
			}
		}
		else if (b_MondoAttacking[npc.index] && b_BonesBuffed[npc.index])
		{
			npc.StopPathing();
		}

		if (!npc.m_bPathing)
		{
			npc.FaceTowards(vecTarget, (b_BonesBuffed[npc.index] && b_MondoAttacking[npc.index] ? BONES_MONDO_ATTACK_TURNRATE : 600.0));
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public void Mondo_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	JesterBones npc = view_as<JesterBones>(entity);

	if (!b_BonesBuffed[entity])
		return;

	switch(event)
	{
		case 1001:	//Attack sequence begins: Servant of Mondo tosses its bomb up into the air. Play HHHH grunt sound as well as necro-smasher swing sound for effect.
		{
			npc.PlayMondoAttackIntro();
		}
		case 1002:	//Servant of Mondo swings its arms to punch the bomb, play swing sound for effect.
		{
			npc.PlayMondoAttackSwing();
		}
		case 1003: 	//Servant of Mondo's fists impact the bomb, launch the bomb forward and play sounds.
		{
			npc.PlayMondoAttackLaunch();
			Jester_RemoveFuseParticles(npc);

			float bombPos[3], bombAng[3], launchAng[3], direction[3];
			npc.GetAttachment("bomb_mondo_center", bombPos, bombAng);

			//We need to spawn the bomb a bit back because otherwise it spawns far enough ahead that players can just hug the skeleton and never get hit.
			//We also spawn it closer to the floor because otherwise it goes right over buildings and crouching players.
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", launchAng);
			GetAngleVectors(launchAng, direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(direction, -60.0);
			AddVectors(bombPos, direction, bombPos);
			bombPos[2] -= 60.0;

			Jester_ShootProjectile(npc, bombPos, bombAng, launchAng, true);
		}
		case 1004:	//Servant of Mondo swings its hands upward to prepare to summon a new bomb, play sound for effect.
		{
			npc.PlayMondoAttackSummonStart();
		}
		case 1005:	//Servant of Mondo uses its arcane powers to teleport a new bomb above its head, spawn particles and play sound for effect.
		{
			npc.PlayMondoAttackSummon();
			Jester_AttachFuseParticles(npc);

			float bombLoc[3], handLoc[3], garbage[3];
			npc.GetAttachment("bomb_mondo_center", bombLoc, garbage);
			npc.GetAttachment("handL", handLoc, garbage);

			ParticleEffectAt(bombLoc, PARTICLE_MONDO_SUMMON_BLAST, 2.0);
			SpawnParticle_ControlPoints(handLoc, bombLoc, PARTICLE_MONDO_SUMMON_BOLTS, 2.0);
			npc.GetAttachment("handR", handLoc, garbage);
			SpawnParticle_ControlPoints(handLoc, bombLoc, PARTICLE_MONDO_SUMMON_BOLTS, 2.0);
		}
		case 1006:	//The new bomb lands on Servant of Mondo's back, play sound and maybe spawn a particle for effect.
		{
			npc.PlayMondoAttackEnd();
			float pos[3], trash[3];
			npc.GetAttachment("bomb_mondo_center", pos, trash);
			pos[2] -= 50.0;
			ParticleEffectAt(pos, PARTICLE_MONDO_LAND, 2.0);
		}
		case 1007:	//Attack sequence has ended, set isAttacking to false and apply attack cooldown.
		{
			b_MondoAttacking[npc.index] = false;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_MONDO_ATTACKINTERVAL;
			int iActivity = npc.LookupActivity("ACT_JESTER_RUN_BUFFED");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.StartPathing();
		}
	}
}

void Jester_ShootProjectile(JesterBones npc, float bombPos[3], float bombAng[3], float launchAng[3], bool buffed, bool MondoDeathBomb = false)
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vel = (buffed ? (MondoDeathBomb ? BONES_MONDO_VELOCITY_DEATH : BONES_MONDO_VELOCITY) : BONES_JESTER_VELOCITY);

		float buffer[3], vecForward[3];
		GetAngleVectors(launchAng, buffer, NULL_VECTOR, NULL_VECTOR);
			
		vecForward[0] = buffer[0] * vel;
		vecForward[1] = buffer[1] * vel;
		vecForward[2] = buffer[2] * vel;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		TeleportEntity(entity, bombPos, bombAng, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		SetEntityModel(entity, MODEL_JESTER_CANNONBALL);

		//I can't use this because it doesn't let me attach the fuse particle properly:
		/*int g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_cannonball.mdl");
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}*/
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);
		
		SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue) ? 1 : 0);
		RequestFrame(Mondo_Spin, EntIndexToEntRef(entity));

		if (h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;
		
		if (buffed)
		{
			SDKHook(entity, SDKHook_Touch, Mondo_Touch);
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Mondo_DontExplode);
			DispatchKeyValueFloat(entity, "modelscale", 3.0);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, (MondoDeathBomb ? BONES_MONDO_GRAVITY_DEATH : BONES_MONDO_GRAVITY));
			b_IsDeathBomb[entity] = MondoDeathBomb;

			GetAttachment(entity, "attach_fuse", bombPos, bombAng);
			ParticleEffectAt_Parent(bombPos, PARTICLE_JESTER_FUSE_BUFFED, entity, "attach_fuse");
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, Jester_Touch);
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Mondo_DontExplode);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, BONES_JESTER_GRAVITY);

			GetAttachment(entity, "attach_fuse", bombPos, bombAng);
			ParticleEffectAt_Parent(bombPos, PARTICLE_JESTER_FUSE, entity, "attach_fuse");
		}
	}
}

public Action Mondo_Touch(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_MONDO_BLAST_SMALL);
	ParticleEffectAt(position, PARTICLE_MONDO_BLAST_BIG, 2.0);
	
	float mult = 1.0;
	if (b_IsDeathBomb[entity])
		mult = BONES_MONDO_MULTIPLIER_DEATH;

	EmitSoundToAll(SOUND_MONDO_EXPLODE, entity, _, 120);
	SpawnParticlesInRing(position, BONES_MONDO_RADIUS * mult, PARTICLE_MONDO_BLAST_SMALL, 16);
	SpawnParticlesInRing(position, BONES_MONDO_RADIUS * mult * 0.5, PARTICLE_MONDO_BLAST_SMALL, 8);

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(BONES_MONDO_DAMAGE * mult, IsValidEntity(owner) ? owner : entity, entity, entity, position, BONES_MONDO_RADIUS * mult, BONES_MONDO_FALLOFF_MULTIHIT, BONES_MONDO_FALLOFF_RADIUS, isBlue, _, _, BONES_MONDO_ENTITYMULT);
	
	b_IsDeathBomb[entity] = false;
	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public Action Jester_Touch(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_MONDO_BLAST_SMALL);
	EmitSoundToAll(SOUND_JESTER_EXPLODE, entity, _, 120, _, _, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(BONES_JESTER_DAMAGE, IsValidEntity(owner) ? owner : entity, entity, entity, position, BONES_JESTER_RADIUS, BONES_JESTER_FALLOFF_MULTIHIT, BONES_JESTER_FALLOFF_RADIUS, isBlue, _, _, BONES_JESTER_ENTITYMULT);

	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public MRESReturn Mondo_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public void Mondo_Spin(int ref)
{
	int ent = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(ent))
		return;
		
	float ang[3];
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
	ang[0] += 20.0;
	ang[1] += 20.0;
	ang[2] += 20.0;

	TeleportEntity(ent, NULL_VECTOR, ang, NULL_VECTOR);
		
	RequestFrame(Mondo_Spin, EntIndexToEntRef(ent));
}

public void Jester_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	JesterBones npc = view_as<JesterBones>(entity);

	if (b_BonesBuffed[entity])
		return;

	if (!b_MondoAttacking[npc.index])
	{
		switch(event)
		{
			case 1001:	//The Jester is holding the left-hand bomb, set the left-hold sequence and mark it as held if we can attack.
			{
				if (GetGameTime(npc.index) >= npc.m_flNextRangedAttack && !Jester_HoldingLeft[npc.index])
				{
					npc.AddGesture("ACT_JESTER_HOLD_LEFT", false, _, false);
					Jester_ReplaceBomb(npc, true, false, true);
					Jester_HoldingLeft[npc.index] = true;
					if (Jester_HoldingRight[npc.index])
					{
						Jester_HoldingBothTime[npc.index] = GetGameTime(npc.index);
					}
				}
			}
			case 1002:	//The Jester is holding the right-hand bomb, set the right-hold sequence and mark it as held if we can attack.
			{
				if (GetGameTime(npc.index) >= npc.m_flNextRangedAttack && !Jester_HoldingRight[npc.index])
				{
					npc.AddGesture("ACT_JESTER_HOLD_RIGHT", false, _, false);
					Jester_ReplaceBomb(npc, false, true, true);
					Jester_HoldingRight[npc.index] = true;
					if (Jester_HoldingLeft[npc.index])
					{
						Jester_HoldingBothTime[npc.index] = GetGameTime(npc.index);
					}
				}
			}
			case 1003:	//The Jester is about to toss the left-hand bomb up into the air while juggling, play a sound effect.
			{
				if (!Jester_HoldingLeft[npc.index])
				{
					npc.PlayJuggleThrowSound(npc.m_iWearable1);
				}
			}
			case 1004:	//The Jester is about to toss the right-hand bomb up into the air while juggling, play a sound effect.
			{
				if (!Jester_HoldingRight[npc.index])
				{
					npc.PlayJuggleThrowSound(npc.m_iWearable2);
				}
			}
			case 1005:	//The Jester's left-hand bomb has landed on his hand, play a sound effect.
			{
				if (!Jester_HoldingLeft[npc.index])
				{
					npc.PlayJuggleImpactSound(npc.m_iWearable1);
				}
			}
			case 1006:	//The Jester's right-hand bomb has landed on his hand, play a sound effect.
			{
				if (!Jester_HoldingRight[npc.index])
				{
					npc.PlayJuggleImpactSound(npc.m_iWearable2);
				}
			}
			case 1007:	//The Jester is ready to attack, make sure we're holding both bombs and can actually attack our chosen target.
			{
				if ((GetGameTime(npc.index) - Jester_HoldingBothTime[npc.index]) >= BONES_JESTER_ATTACK_DELAY_HOLDING && Jester_HoldingLeft[npc.index] && Jester_HoldingRight[npc.index] && IsValidEnemy(npc.index, npc.m_iTarget) && GetGameTime(npc.index) >= npc.m_flNextRangedAttack)
				{
					float loc[3], vicLoc[3];
					WorldSpaceCenter(npc.index, loc);
					WorldSpaceCenter(npc.m_iTarget, vicLoc);

					float dist = GetVectorDistance(loc, vicLoc);
					if (Can_I_See_Enemy_Only(npc.index, npc.m_iTarget) && dist <= BONES_JESTER_RANGE)
					{
						npc.RemoveGesture("ACT_JESTER_HOLD_LEFT");
						npc.RemoveGesture("ACT_JESTER_HOLD_RIGHT");
						npc.AddGesture("ACT_JESTER_ATTACK");
						b_MondoAttacking[npc.index] = true;
						Jester_HoldingLeft[npc.index] = false;
						Jester_HoldingRight[npc.index] = false;
					}
				}
			}
		}
	}
	else
	{
		switch(event)
		{
			case 1008: 	//Left-hand swing.
			{
				npc.PlayThrowBombSound(npc.m_iWearable1);
			}
			case 1009:	//Left hand releases the bomb.
			{
				Jester_RemoveFuseParticles(npc, true, false);
				Jester_FireNonBuffed(npc);
			}
			case 1010: 	//Right-hand swing.
			{
				npc.PlayThrowBombSound(npc.m_iWearable2);
			}
			case 1011: 	//Right hand releases the bomb.
			{
				Jester_RemoveFuseParticles(npc, false);
				Jester_FireNonBuffed(npc);
			}
			/*case 1012:	//New bombs magically teleport into the Jester's hands (SCRAPPED, THIS HAPPENS LATER NOW)
			{
				//(SCRAPPED, THIS HAPPENS LATER NOW)
			}*/
			case 1013:	//End of attack sequence.
			{
				npc.RemoveGesture("ACT_JESTER_ATTACK");
				b_MondoAttacking[npc.index] = false;
				Jester_AttachFuseParticles(npc);
				Jester_ReplaceBomb(npc, true, true, false);

				float pos[3], trash[3];
				npc.GetAttachment("bomb_left_center", pos, trash);
				ParticleEffectAt(pos, PARTICLE_JESTER_BOMB_TELEPORT);
				EmitSoundToAll(SOUND_JESTER_BOMB_TELEPORT, npc.m_iWearable1, _, 80, _, 0.8, GetRandomInt(70, 110));

				npc.GetAttachment("bomb_right_center", pos, trash);
				ParticleEffectAt(pos, PARTICLE_JESTER_BOMB_TELEPORT);
				EmitSoundToAll(SOUND_JESTER_BOMB_TELEPORT, npc.m_iWearable2, _, 80, _, 0.8, GetRandomInt(70, 110));

				npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_JESTER_ATTACKINTERVAL;
			}
		}
	}
}

public void Jester_FireNonBuffed(JesterBones npc)
{
	float bombPos[3], shootAng[3], direction[3], targPos[3], selfAng[3];
	WorldSpaceCenter(npc.index, bombPos);
	bool foundTarget = false;

	if (IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if (Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, targPos);
			if (GetVectorDistance(bombPos, targPos) <= BONES_JESTER_RANGE_PREDICT)
			{
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, BONES_JESTER_VELOCITY, _, targPos);
			}
	
			GetAngleToPoint(npc.index, targPos, selfAng, shootAng);
			npc.FaceTowards(targPos, 15000.0);

			foundTarget = true;
		}
	}

	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", selfAng);
	GetAngleVectors(selfAng, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 20.0);
	AddVectors(bombPos, direction, bombPos);

	Jester_ShootProjectile(npc, bombPos, (foundTarget ? shootAng : selfAng), (foundTarget ? shootAng : selfAng), false);
}

public Action JesterBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	JesterBones npc = view_as<JesterBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void JesterBones_NPCDeath(int entity)
{
	JesterBones npc = view_as<JesterBones>(entity);
	npc.PlayDeathSound();
	
	Jester_RemoveFuseParticles(npc);

	float bombPos[3], bombAng[3], launchAng[3];
	npc.GetAttachment("bomb_mondo_center", bombPos, bombAng);
	WorldSpaceCenter(entity, bombPos);
	bombPos[2] += 20.0;
	launchAng[0] = -90.0;

	if (b_BonesBuffed[entity])
		Jester_ShootProjectile(npc, bombPos, bombAng, launchAng, true, true);

	npc.RemoveAllWearables();

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}
