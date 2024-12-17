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

static bool Chair_ChangeSequence[2049] = { false, ... };
static char Chair_Sequence[2049][255];
static char Chair_SnapEffect[2049][255];
static char Chair_SnapEffectExtra[2049][255];

//NECROTIC BOMBARDMENT: SSB marks every enemy's location, and then strikes that location with a blast of necrotic energy after a short delay.
static float Bombardment_Radius[4] = { 180.0, 220.0, 260.0, 300.0 };		//Blast radius.
static float Bombardment_Delay[4] = { 2.0, 1.75, 1.5, 1.25 };				//Time until the blast hits.
static float Bombardment_DMG[4]	= { 200.0, 400.0, 800.0, 1600.0 };			//Damage dealt by the blast.
static float Bombardment_EntityMult[4] = { 5.0, 10.0, 15.0, 20.0 };			//Amount to multiply damage dealt to entities.
static float Bombardment_Falloff_MultiHit[4] = { 0.66, 0.7, 0.75, 0.8 };	//Amount to multiply damage per target hit.
static float Bombardment_Falloff_Radius[4] = { 0.5, 0.66, 0.75, 0.8 };		//Maximum distance-based falloff.

//RING OF HELL: SSB fires a cluster of explosive skulls in a ring pattern. These skulls transform into homing skulls after a short delay.
static int HellRing_NumSkulls[4] = { 12, 16, 20, 28 };						//The number of skulls fired.
static int HellRing_MaxTargets[4] = { 3, 4, 5, 8 };							//Maximum targets hit by a single skull explosion.
static float HellRing_Velocity[4] = { 400.0, 450.0, 500.0, 550.0 };			//Skull velocity.
static float HellRing_HomingDelay[4] = { 1.0, 0.75, 0.5, 0.25 };			//Delay after firing before skulls gain homing properties.
static float HellRing_HomingAngle[4] = { 90.0, 95.0, 100.0, 105.0 };		//Skulls' maximum homing angle.
static float HellRing_HomingPerSecond[4] = { 9.0, 10.0, 11.0, 12.0 };		//Number of times per second for skulls to readjust their velocity for the sake of homing in on their target.
static float HellRing_DMG[4] = { 60.0, 90.0, 160.0, 250.0 };				//Skull base damage.
static float HellRing_EntityMult[4] = { 2.0, 2.5, 3.0, 4.0 };				//Amount to multiply damage dealt by skulls to entities.
static float HellRing_Radius[4] = { 60.0, 100.0, 140.0, 180.0 };			//Skull explosion radius.
static float HellRing_Falloff_Radius[4] = { 0.66, 0.5, 0.33, 0.165 };		//Skull falloff, based on radius.
static float HellRing_Falloff_MultiHit[4] = { 0.66, 0.76, 0.86, 1.0 }; 		//Amount to multiply explosion damage for each target hit.
static float HellRing_Pitch[4] = { 5.0, 5.0, 5.0, 5.0 };					//Amount to tilt skull vertical velocity on spawn, used mainly for VFX.

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

#define SND_SNAP					"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_snap.mp3"
#define SND_BOMBARDMENT_STRIKE		")misc/halloween/spell_spawn_boss.wav"
#define SND_BOMBARDMENT_MARKED		")misc/halloween/hwn_bomb_flash.wav"
#define SND_BOMBARDMENT_CHARGEUP	")items/powerup_pickup_crits.wav"
#define SND_HELL_CHARGEUP			")misc/halloween_eyeball/book_spawn.wav"
#define SND_HELL_SHOOT				")misc/halloween/spell_meteor_cast.wav"
#define SND_HELL_SHOOT_2			")misc/halloween_eyeball/book_exit.wav"

#define PARTICLE_BOMBARDMENT_SNAP		"merasmus_dazed_bits"
#define PARTICLE_BOMBARDMENT_SNAP_EXTRA	"hammer_bell_ring_shockwave2"
#define PARTICLE_HELL_HAND				"spell_fireball_small_red"
#define PARTICLE_HELL_SNAP				"spell_fireball_tendril_parent_red"
#define PARTICLE_HELL_TRAIL				"spell_fireball_small_red"
#define PARTICLE_HELL_TRAIL_HOMING		"spell_fireball_small_blue"
#define PARTICLE_HELL_BLAST				"spell_fireball_tendril_parent_red"
#define PARTICLE_HELL_BLAST_HOMING		"spell_fireball_tendril_parent_blue"
#define PARTICLE_BOMBARDMENT_HAND		"superrare_burning2"

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

	PrecacheSound(SND_SPAWN_ALERT);
	PrecacheSound(SND_SNAP);
	PrecacheSound(SND_BOMBARDMENT_STRIKE);
	PrecacheSound(SND_BOMBARDMENT_MARKED);
	PrecacheSound(SND_BOMBARDMENT_CHARGEUP);
	PrecacheSound(SND_HELL_CHARGEUP);
	PrecacheSound(SND_HELL_SHOOT);
	PrecacheSound(SND_HELL_SHOOT_2);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supreme Spookmaster Bones, Magistrate of the Dead");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ssb_finale_phase1");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = Summon_SSBChair;
	NPC_Add(data);
}

static any Summon_SSBChair(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SSBChair(client, vecPos, vecAng, ally);
}

#define SSBCHAIR_MAX_ABILITIES 99999

ArrayList SSB_ChairSpells[2049];

bool SSBChair_AbilitySlotUsed[SSBCHAIR_MAX_ABILITIES] = {false, ...};

Function ChairSpell_Function[SSBCHAIR_MAX_ABILITIES] = { INVALID_FUNCTION, ... };	//The function to call when this ability is successfully activated.
Function ChairSpell_Filter[SSBCHAIR_MAX_ABILITIES] = { INVALID_FUNCTION, ... };		//The function to call when this ability is about to be activated, to check manually if it can be used or not. Must take one SSBChair and an entity index for the victim as parameters, and return a bool (true: activate, false: don't).

float ChairSpell_Cooldown[SSBCHAIR_MAX_ABILITIES] = { 0.0, ... };
float ChairSpell_NextUse[SSBCHAIR_MAX_ABILITIES] = { 0.0, ... };

int ChairSpell_Tier[SSBCHAIR_MAX_ABILITIES] = { 0, ... };

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

		this.NextUse = GetGameTime(user.index) + this.Cooldown;
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

	property float NextUse
	{
		public get () { return ChairSpell_NextUse[this.Index]; }
		public set(float value) { ChairSpell_NextUse[this.Index] = value; }
	}
}

public void SSBChair_Bombardment(SSBChair ssb, int target)
{
	ssb.CastSnap(SSBChair_Bombardment_Activate, PARTICLE_BOMBARDMENT_HAND, PARTICLE_BOMBARDMENT_SNAP, PARTICLE_BOMBARDMENT_SNAP_EXTRA, SND_BOMBARDMENT_CHARGEUP);
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
	ssb.CastSnap(SSBChair_RingOfHell_Activate, PARTICLE_HELL_HAND, PARTICLE_HELL_SNAP, "", SND_HELL_CHARGEUP);
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

	public void PrepareAbilities()
	{
		this.DeleteAbilities();
		SSB_ChairSpells[this.index] = new ArrayList(255);

		//TODO: Populate abilities here
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(15.0, 5.0, 0, SSBChair_Bombardment));
		PushArrayCell(SSB_ChairSpells[this.index], this.CreateAbility(18.0, 8.0, 0, SSBChair_RingOfHell));
	}

	public SSBChair_Spell CreateAbility(float cooldown, float startingCD, int tier, Function ActivationFunction, Function FilterFunction = INVALID_FUNCTION)
	{
		SSBChair_Spell spell = new SSBChair_Spell();

		spell.NextUse = GetGameTime(this.index) + startingCD;
		spell.Cooldown = cooldown;
		spell.ActivationFunction = ActivationFunction;
		spell.FilterFunction = FilterFunction;
		spell.Tier = tier;

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

	public void CastSnap(Function spell, char handParticle[255], char snapParticle[255], char snapParticleExtra[255], char sound[255])
	{
		int activity = this.LookupActivity("ACT_FINALE_CHAIR_SNAP");
		if (activity > 0)
		{
			this.StartActivity(activity);
			Chair_UsingAbility[this.index] = true;
			Chair_QueuedSpell[this.index] = spell;
			Chair_SnapEffect[this.index] = snapParticle;
			Chair_SnapEffectExtra[this.index] = snapParticleExtra;

			float pos[3], trash[3];
			this.GetAttachment("effect_hand_L", pos, trash);
			this.m_iWearable3 = ParticleEffectAt_Parent(pos, handParticle, this.index, "effect_hand_L");
			EmitSoundToAll(sound, this.index, _, 120);
		}
	}

	public SSBChair(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		SSBChair npc = view_as<SSBChair>(CClotBody(vecPos, vecAng, MODEL_SSB, SSB_CHAIR_SCALE, SSB_CHAIR_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bisWalking = false;
		Chair_UsingAbility[npc.index] = false;

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
		Chair_Tier[npc.index] = 0;

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

		TeleportDiversioToRandLocation(npc.index);
		ParticleEffectAt(vecPos, PARTICLE_SSB_SPAWN, 3.0);
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
		case 1002:	//Fingers have snapped, cast whatever spell has been queued up.
		{
			if (Chair_QueuedSpell[npc.index] != INVALID_FUNCTION)
			{
				Call_StartFunction(null, Chair_QueuedSpell[npc.index]);
				Call_PushCell(npc);
				Call_PushCell(npc.m_iTarget);
				Call_Finish();
			}

			EmitSoundToAll(SND_SNAP, _, _, 120);
			float pos[3], trash[3];
			npc.GetAttachment("effect_hand_L", pos, trash);

			char the[255];	//This is stupid as hell, but I get an unavoidable error if I don't do it.
			if (!StrEqual(Chair_SnapEffect[npc.index], ""))
			{
				the = Chair_SnapEffect[npc.index];
				ParticleEffectAt(pos, the);
			}
			if (!StrEqual(Chair_SnapEffectExtra[npc.index], ""))
			{
				the = Chair_SnapEffectExtra[npc.index];
				ParticleEffectAt(pos, the);
			}

			if (IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
		}
		case 1003:	//Snap finished, go back to idle animation and remove "UsingAbility" flag.
		{
			Chair_ChangeSequence[npc.index] = true;
			Chair_Sequence[npc.index] = "ACT_FINALE_CHAIR_IDLE";
			Chair_UsingAbility[npc.index] = false;
		}
		case 1004:	//Any and all parts of any animation where the chair itself hits something, play a thud sound.
		{
			npc.PlayChairThud();
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
		//npc.StartPathing();
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.AttemptCast();

	npc.PlayIdleSound();
}


public Action SSBChair_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;

	SSBChair npc = view_as<SSBChair>(victim);
	//TODO: Fill this out if needed, scrap if not

	return Plugin_Changed;
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
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);

		RequestFrame(SSB_DeleteIfOwnerDisappears, EntIndexToEntRef(prop));
		
		return prop;
	}
	
	return -1;
}