#pragma semicolon 1
#pragma newdecls required

static float BONES_FLINTLOCK_SPEED = 360.0;	//Flintlock movement speed while it has ammo
static float BONES_FLINTLOCK_SPEED_NO_AMMO = 230.0;	//Flintlock movement speed while it has no ammo
static float BONES_FLINTLOCK_SPEED_BUFFED = 260.0;	//Deadeye movement speed while it is not charging its gun
static float BONES_FLINTLOCK_SPEED_BUFFED_CHARGING = 360.0;	//Deadeye movement speed while it is charging its gun

#define BONES_FLINTLOCK_HP				"900"
#define BONES_FLINTLOCK_HP_BUFFED		"4500"

//FLINTLOCK: Basic ranged unit. Wields an SMG with a large clip and high rate of fire, but low damage.
//When their SMG is loaded, they will run towards the nearest target. Then, when within range, they will stop and unload their clip on that target.
//Once they run out of ammo, they will initiate a reload phase, running away if an enemy is too close.
static float FLINTLOCK_DAMAGE = 40.0;		//Projectile damage for Flintlocks.
static float FLINTLOCK_VELOCITY = 1000.0;	//Projectile velocity.
static int FLINTLOCK_COUNT = 8;				//Number of projectiles fired per shot.
static float FLINTLOCK_LIFESPAN = 1.33;	//Projectile lifespan.
static float FLINTLOCK_ENTITYMULT = 2.0;	//Amount to multiply damage dealt by Flintlock projectiles to enemies.
static float FLINTLOCK_RANGE = 500.0;		//Range in which Flintlocks will shoot.
static int FLINTLOCK_CLIP = 6;			//Clip size.
static float FLINTLOCK_RELOADTIME = 2.0;	//Time after attack finishes before the NPC will reload.
static float FLINTLOCK_RELOADSPEED = 1.0;	//Reload animation speed multiplier.
static float FLINTLOCK_TURNRATE = 2000.0;	//Rate at which the NPC turns to face its target while firing.
static int FLINTLOCK_EMPTY = 2;			//Number of times the Flintlock will attempt to fire its gun once it runs out of ammo. This is used to indicate it has run out with a unique animation and sound effect, so players can react.
static float FLINTLOCK_SPREAD = 6.0;		//Random spread.
static float FLINTLOCK_RELOAD_DELAY = 1.0;	//Delay after the reload finishes before the Flintlock can attack again.

//HOLLOW DEADEYE: Buffed range unit, slowly fires powerful explosive projectiles from a revolver. Predicts within a large radius.
//Functions similarly to Flintlocks in that it will run away while charging up its next shot, then chase the nearest target until in-range once its shot is fully charged.
static float DEADEYE_RANGE = 1500.0;			//Range in which Hollow Hitmen will shoot.
//static float DEADEYE_PREDICT_RANGE = 600.0;	//Range in which Hollow Hitmen will predict their target's position.
static float DEADEYE_VELOCITY = 1200.0;		//Projectile velocity.
static float DEADEYE_DMG = 400.0;			//Blast damage.
static float DEADEYE_RADIUS = 140.0;			//Blast radius.
static float DEADEYE_FALLOFF_MULTIHIT = 0.8;	//Amount to multiply damage dealt per target hit by the blast.
static float DEADEYE_FALLOFF_RADIUS = 0.66;	//Maximum damage falloff, based on radius.
static float DEADEYE_CHARGE_TIME = 4.0;		//Time it takes for Hollow Hitmen to charge a shot.
static float DEADEYE_ENTITYMULT = 4.0;		//Damage multiplier for buildings.

static float FLINTLOCK_NATURAL_BUFF_CHANCE = 0.05;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float FLINTLOCK_NATURAL_BUFF_LEVEL_MODIFIER = 0.1;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float FLINTLOCK_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static float BONES_FLINTLOCK_ATTACKINTERVAL = 0.75;
static float BONES_FLINTLOCK_ATTACKINTERVAL_BUFFED = 2.0;

static float FLINTLOCK_HOVER_MINDIST = 400.0;
//static float FLINTLOCK_HOVER_OPTIMALDIST = 550.0;

static float f_FlintlockFireballDMG[2049] = { 0.0, ... };

#define BONES_FLINTLOCK_SCALE				"1.0"
#define BONES_FLINTLOCK_BUFFED_SCALE			"1.2"

#define BONES_FLINTLOCK_SKIN						"0"
#define BONES_FLINTLOCK_BUFFED_SKIN				"1"

#define SND_FLINTLOCK_SHOOT					")weapons/shotgun_shoot.wav"
#define SND_FLINTLOCK_SHOOT_NO_AMMO			")weapons/shotgun_empty.wav"
#define SND_FLINTLOCK_HIT						")player/pain.wav"
#define SND_FLINTLOCK_RELOAD_FINISH			")weapons/sniper_bolt_forward.wav"
#define SND_FLINTLOCK_RELOAD_START			")weapons/sniper_bolt_back.wav"
#define SND_FLINTLOCK_SCARED					")vo/scout_sf12_scared01.mp3"
#define SND_FLINTLOCK_SWING					")weapons/machete_swing.wav"
#define SND_FLINTLOCK_SWING_BIG				")misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_FLINTLOCK_STOMP					")weapons/push_impact.wav"
#define SND_DEADEYE_REVOLVER_SPIN			")player/taunt_clip_spin.wav"
#define SND_DEADEYE_EXPLODE					")misc/halloween/spell_fireball_impact.wav"
#define SND_DEADEYE_FIRE						")weapons/diamond_back_03_crit.wav"
#define SND_DEADEYE_FIRE_2					")misc/halloween/spell_fireball_cast.wav"
#define SND_FLINTLOCK_MOVE_GUN				")player/cyoa_pda_draw.wav"

#define PARTICLE_FLINTLOCK_FIREBALL			"nailtrails_medic_red_crit"
#define PARTICLE_FLINTLOCK_FIREBALL_BUFFED	"spell_fireball_small_blue"
#define PARTICLE_FLINTLOCK_BARREL				"sentry_rocket_8"
#define PARTICLE_FLINTLOCK_MUZZLE				"muzzle_pistol"
#define PARTICLE_DEADEYE_FLASH				"muzzle_bignasty"

#define BONES_FLINTLOCK_BUFFPARTICLE			"utaunt_runeprison_teamcolor_blue"//"utaunt_auroraglow_purple_parent"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds_Buffed[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
	")misc/halloween/skeletons/skelly_giant_02.wav",
	")misc/halloween/skeletons/skelly_giant_03.wav"
};

static char g_IdleAlertedSounds_Buffed[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
	")misc/halloween/skeletons/skelly_giant_02.wav",
	")misc/halloween/skeletons/skelly_giant_03.wav"
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
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

public void FlintlockBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds_Buffed));		i++) { PrecacheSound(g_IdleSounds_Buffed[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds_Buffed)); i++) { PrecacheSound(g_IdleAlertedSounds_Buffed[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }
	PrecacheSound(SND_FLINTLOCK_SHOOT);
	PrecacheSound(SND_FLINTLOCK_HIT);
	PrecacheSound(SND_FLINTLOCK_SHOOT_NO_AMMO);
	PrecacheSound(SND_FLINTLOCK_RELOAD_START);
	PrecacheSound(SND_FLINTLOCK_RELOAD_FINISH);
	PrecacheSound(SND_FLINTLOCK_SCARED);
	PrecacheSound(SND_FLINTLOCK_SWING);
	PrecacheSound(SND_FLINTLOCK_SWING_BIG);
	PrecacheSound(SND_FLINTLOCK_STOMP);
	PrecacheSound(SND_DEADEYE_REVOLVER_SPIN);
	PrecacheSound(SND_DEADEYE_EXPLODE);
	PrecacheSound(SND_DEADEYE_FIRE);
	PrecacheSound(SND_DEADEYE_FIRE_2);
	PrecacheSound(SND_FLINTLOCK_MOVE_GUN);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Swashbuckler Skelebones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_flintlock");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Deadeye");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_flintlock_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return FlintlockBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return FlintlockBones(client, vecPos, vecAng, ally, true);
}

static bool b_DeadeyeCharging[MAXENTITIES] = { false, ... };
static int i_FlintlockAmmo[MAXENTITIES] = { 0, ... };
static int i_FlintlockDryShots[MAXENTITIES] = { 0, ... };
static bool b_FlintlockAttacking[MAXENTITIES] = { false, ... };
static bool b_FlintlockWindupPhase[MAXENTITIES] = { false, ... };
static bool b_ReloadAnimNeeded[MAXENTITIES] = { false, ... };
static float f_ReloadAtFlintlock[MAXENTITIES] = { 0.0, ... };
static float f_DeadeyeChargeTime[MAXENTITIES] = { 0.0, ... };
static bool b_ForceShootAnimFlintlock[MAXENTITIES] = { false, ...};
static int Deadeye_Whooshes[MAXENTITIES] = { -1, ... };

methodmap FlintlockBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CFlintlockBones::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}
	
	public bool IHaveAmmo()
	{
		if (b_BonesBuffed[this.index])
		{
			return b_DeadeyeCharging[this.index];
		}
		
		return i_FlintlockAmmo[this.index] > 0;
	}
	
	public FlintlockBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = FLINTLOCK_NATURAL_BUFF_CHANCE;
			if (FLINTLOCK_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / FLINTLOCK_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * FLINTLOCK_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		FlintlockBones npc = view_as<FlintlockBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_FLINTLOCK_BUFFED_SCALE : BONES_FLINTLOCK_SCALE, buffed && !randomlyBuffed ? BONES_FLINTLOCK_HP_BUFFED : BONES_FLINTLOCK_HP, ally, false));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_FLINTLOCK_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_FLINTLOCK_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_FLINTLOCK_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_FLINTLOCK_BUFFED_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_FLINTLOCK_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_FLINTLOCK_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Deadeye");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Swashbuckler Skelebones");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(FlintlockBones_SetBuffed);
		npc.m_bisWalking = false;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.5;

		func_NPCDeath[npc.index] = view_as<Function>(FlintlockBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(FlintlockBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(FlintlockBones_ClotThink);
		
		Flintlock_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			int iActivity = npc.LookupActivity("ACT_DEADEYE_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Deadeye_AnimEvent;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_SWASHBUCKLER_RUN_LOADED");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Flintlock_AnimEvent;
		}

		i_FlintlockAmmo[npc.index] = FLINTLOCK_CLIP;
		b_DeadeyeCharging[npc.index] = false;
		b_FlintlockAttacking[npc.index] = false;
		b_FlintlockWindupPhase[npc.index] = false;
		b_ReloadAnimNeeded[npc.index] = false;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_FLINTLOCK_BUFFED_SKIN : BONES_FLINTLOCK_SKIN);

		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (buffed ? BONES_FLINTLOCK_ATTACKINTERVAL_BUFFED : BONES_FLINTLOCK_ATTACKINTERVAL);
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_FLINTLOCK_SPEED_BUFFED : BONES_FLINTLOCK_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

/*public void ApplyBarrelEffect(FlintlockBones npc, char type[255])
{
	RemoveBarrelEffect(npc);
	i_BarrelEffectFlintlock[npc.index] = EntIndexToEntRef(Flintlock_AttachParticle(npc.index, type, _, "revolver_muzzle"));
}

public void RemoveBarrelEffect(FlintlockBones npc)
{
	int ent = EntRefToEntIndex(i_BarrelEffectFlintlock[npc.index]);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
}*/

public void FlintlockBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	i_FlintlockAmmo[npc.index] = FLINTLOCK_CLIP;
	b_DeadeyeCharging[npc.index] = false;
	b_FlintlockAttacking[npc.index] = false;
	b_FlintlockWindupPhase[npc.index] = false;
	b_ReloadAnimNeeded[npc.index] = false;
	npc.RemoveGesture("ACT_DEADEYE_CHARGE_GUN");
	RemoveBarrelEffect(npc);

	if (GetGameTime(npc.index) - npc.m_flNextRangedAttack < 0.5)
	{
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.5;
	}

	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		Flintlock_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_FLINTLOCK_BUFFED_SKIN);

		func_NPCAnimEvent[npc.index] = Deadeye_AnimEvent;
		npc.m_blSetNonBuffedSkeletonAnimation = false;
		npc.m_blSetBuffedSkeletonAnimation = true;
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		Flintlock_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_FLINTLOCK_SKIN);

		func_NPCAnimEvent[npc.index] = Flintlock_AnimEvent;

		npc.m_blSetNonBuffedSkeletonAnimation = true;
		npc.m_blSetBuffedSkeletonAnimation = false;
	}
}

stock void Flintlock_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		/*npc.m_iWearable1 = npc.EquipItem("hat", "models/workshop/player/items/sniper/hwn2023_sightseer_style1/hwn2023_sightseer_style1.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/hwn2023_sharpshooters_shroud/hwn2023_sharpshooters_shroud.mdl");
		
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		DispatchKeyValue(npc.m_iWearable2, "skin", "1");*/
	}
	else
	{
		//npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/sniper/headhunters_wrap/headhunters_wrap.mdl");
	}
}

stock int Flintlock_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void Flintlock_CheckShoot(FlintlockBones npc, int closest)
{
	if (npc.m_flNextRangedAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index) && !b_FlintlockAttacking[npc.index] && !b_FlintlockWindupPhase[npc.index] && !b_DeadeyeCharging[npc.index])
	{
		if (!Can_I_See_Enemy_Only(npc.index, closest))
			return;

		float vicPos[3], userPos[3];
		WorldSpaceCenter(closest, vicPos);
		WorldSpaceCenter(npc.index, userPos);

		if (!b_BonesBuffed[npc.index] && GetVectorDistance(vicPos, userPos) <= FLINTLOCK_RANGE && i_FlintlockAmmo[npc.index] >= FLINTLOCK_CLIP)
		{
			int iActivity = npc.LookupActivity("ACT_SWASHBUCKLER_ATTACK_INTRO");
			if(iActivity > 0) npc.StartActivity(iActivity);
			b_FlintlockWindupPhase[npc.index] = true;
			npc.FaceTowards(vicPos, 15000.0);
			i_FlintlockDryShots[npc.index] = FLINTLOCK_EMPTY;
			npc.StopPathing();
		}
		else if (b_BonesBuffed[npc.index] && GetVectorDistance(vicPos, userPos) <= DEADEYE_RANGE)
		{
			npc.AddGesture("ACT_DEADEYE_DEPLOY_GUN");
			b_DeadeyeCharging[npc.index] = true;
			b_ForceShootAnimFlintlock[npc.index] = false;
			f_DeadeyeChargeTime[npc.index] = GetGameTime(npc.index) + DEADEYE_CHARGE_TIME;
			ApplyBarrelEffect(npc, PARTICLE_FLINTLOCK_FIREBALL_BUFFED);
		}
	}
}

public void Flintlock_ShootProjectile(FlintlockBones npc, float vicLoc[3], float vel, float damage, float startPos[3])
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecAngles[3], currentAngles[3], buffer[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", currentAngles);
		Priest_GetAngleToPoint(npc.index, startPos, vicLoc, buffer, vecAngles);
		vecAngles[1] = currentAngles[1];
		vecAngles[2] = currentAngles[2];

		if (!b_BonesBuffed[npc.index])
		{
			for(int i = 0; i < 3; i++)
				vecAngles[i] += GetRandomFloat(-FLINTLOCK_SPREAD, FLINTLOCK_SPREAD);
		}
			
		GetAngleVectors(vecAngles, buffer, NULL_VECTOR, NULL_VECTOR);
		vecForward[0] = buffer[0] * vel;
		vecForward[1] = buffer[1] * vel;
		vecForward[2] = buffer[2] * vel;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		f_FlintlockFireballDMG[entity] = damage;

		TeleportEntity(entity, startPos, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		int g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_drg_ball.mdl");
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);
		
		if (b_BonesBuffed[npc.index])
		{
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Flintlock_Explode);
			Flintlock_AttachParticle(entity, PARTICLE_FLINTLOCK_FIREBALL_BUFFED, _, "");
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, Flintlock_FireballTouch);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Flintlock_DontExplode);
			Flintlock_AttachParticle(entity, PARTICLE_FLINTLOCK_FIREBALL, _, "");
			CreateTimer(FLINTLOCK_LIFESPAN, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Flintlock_FireballTouch(int entity, int other)
{
	if (!IsValidEntity(other))
		return Plugin_Continue;
		
	int team1 = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(other, Prop_Send, "m_iTeamNum");
	
	if (team1 != team2)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		float damage = (ShouldNpcDealBonusDamage(other) ? f_FlintlockFireballDMG[entity] * FLINTLOCK_ENTITYMULT : f_FlintlockFireballDMG[entity]);
		SDKHooks_TakeDamage(other, entity, IsValidEntity(owner) ? owner : entity, damage);
			
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, PARTICLE_FIREBALL_HIT, 2.0);
		EmitSoundToAll(SND_FLINTLOCK_HIT, entity, _, _, _, 0.8, GetRandomInt(80, 110));

		RemoveEntity(entity);
	}
		
	return Plugin_Continue;
}

public MRESReturn Flintlock_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public MRESReturn Flintlock_Explode(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_FIREBALL_EXPLODE, 2.0);
	EmitSoundToAll(SND_DEADEYE_EXPLODE, entity, _, 120, _, _, GetRandomInt(90, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_FlintlockFireballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, DEADEYE_RADIUS, DEADEYE_FALLOFF_MULTIHIT, DEADEYE_FALLOFF_RADIUS, isBlue, _, true, DEADEYE_ENTITYMULT);
	
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public void Flintlock_LookAtPoint(FlintlockBones npc, int closest)
{
	if (IsValidEnemy(npc.index, closest))
	{
		float targLoc[3];
		WorldSpaceCenter(closest, targLoc);
		npc.FaceTowards(targLoc, 15000.0);
	}
}

public void Deadeye_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	FlintlockBones npc = view_as<FlintlockBones>(entity);

	if (!b_BonesBuffed[entity])
		return;

	if (b_DeadeyeCharging[npc.index])
	{
		switch(event)
		{
			case 1001:		//Sound
			{
				EmitSoundToAll(SND_FLINTLOCK_SWING, npc.index);
			}
			case 1002:		//Sound
			{
				EmitSoundToAll(SND_FLINTLOCK_STOMP, npc.index);
			}
			case 1003:		//Gun is being held by both hands, switch to the loop sequence.
			{
				npc.AddGesture("ACT_DEADEYE_CHARGE_GUN", false, _, false);
			}
		}
	}
	else if (b_FlintlockWindupPhase[npc.index])
	{
		switch(event)
		{
			case 1001:		//Deadeye swings gun upward, play sounds.
			{
				EmitSoundToAll(SND_FLINTLOCK_SWING, npc.index, _, 120);
				EmitSoundToAll(SND_DEADEYE_REVOLVER_SPIN, npc.index, _, 120);
			}
			case 1002:		//Attack intro sequence ends, switch to attack sequence and fire projectile.
			{
				b_ForceShootAnimFlintlock[npc.index] = true;
				b_FlintlockWindupPhase[npc.index] = false;
				b_FlintlockAttacking[npc.index] = true;

				float pos[3], ang[3], vicLoc[3];
				npc.GetAttachment("revolver_muzzle", pos, ang);
				ParticleEffectAt(pos, PARTICLE_DEADEYE_FLASH);
				EmitSoundToAll(SND_DEADEYE_FIRE, npc.index, _, 120);
				EmitSoundToAll(SND_DEADEYE_FIRE_2, npc.index, _, 120);

				if (IsValidEnemy(npc.index, npc.m_iTarget) && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				{
					PredictSubjectPositionForProjectiles_NoNPCNeeded(pos, npc.m_iTarget, DEADEYE_VELOCITY, _, vicLoc);
					npc.FaceTowards(vicLoc, 15000.0);
				}
				else
				{
					float Direction[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

					GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, 200.0);
					AddVectors(pos, Direction, vicLoc);
				}

				Flintlock_ShootProjectile(npc, vicLoc, DEADEYE_VELOCITY, DEADEYE_DMG, pos);
			}
		}
	}
	else if (b_FlintlockAttacking[npc.index])
	{
		switch(event)
		{
			case 1001:		//Deadeye's torso is spinning, play sound.
			{
				EmitSoundToAll(SND_FLINTLOCK_SWING, npc.index, _, 120, _, _, 80 + (5 * Deadeye_Whooshes[npc.index]));
				EmitSoundToAll(SND_FLINTLOCK_SWING, npc.index, _, 80, _, 0.8, 80 + (5 * Deadeye_Whooshes[npc.index]));
				Deadeye_Whooshes[npc.index]--;
			}
			case 1002:		//Deadeye is about to stomp, play sound.
			{
				EmitSoundToAll(SND_FLINTLOCK_SWING_BIG, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1003:		//Remove smoke particle from gun barrel.
			{
				RemoveBarrelEffect(npc);
			}
			case 1004:		//Deadeye's foot hits the ground, play sound.
			{
				EmitSoundToAll(SND_FLINTLOCK_STOMP, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1005:		//Deadeye laughs, play sound.
			{
				EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index);
			}
			case 1006:		//Attack animation ends, revert to walk cycle.
			{
				b_FlintlockAttacking[npc.index] = false;
				int iActivity = npc.LookupActivity("ACT_DEADEYE_RUN");
				if (iActivity > 0)
					npc.StartActivity(iActivity);
				npc.StartPathing();

				npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_FLINTLOCK_ATTACKINTERVAL_BUFFED;
			}
		}
	}
}

public void Flintlock_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	FlintlockBones npc = view_as<FlintlockBones>(entity);

	if (b_BonesBuffed[entity])
		return;

	if (b_FlintlockWindupPhase[npc.index])
	{
		switch(event)
		{
			case 1001:		//Flintlock swings its gun up into the air, play a sound effect.
			{
				EmitSoundToAll(SND_FLINTLOCK_SWING, npc.index, _, _, _, _, GetRandomInt(80, 90));
			}
			case 1002:		//Flintlock's foot hits the ground, play a sound effect.
			{
				EmitSoundToAll(SND_FLINTLOCK_STOMP, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1003:		//Moving gun into place, play sound.
			{
				EmitSoundToAll(SND_FLINTLOCK_MOVE_GUN, npc.index, _, _, _, _, 60);
			}
			case 1004:		//Moving gun into place, play sound.
			{
				EmitSoundToAll(SND_FLINTLOCK_MOVE_GUN, npc.index, _, _, _, _, 90);
			}
			case 1005:		//Intro sequence ends, transition to active attack sequence.
			{
				b_FlintlockWindupPhase[npc.index] = false;
				b_FlintlockAttacking[npc.index] = true;

				int iActivity = npc.LookupActivity("ACT_SWASHBUCKLER_ATTACK_LOOP");
				if (iActivity > 0)
					npc.StartActivity(iActivity);

				EmitSoundToAll(SOUND_HHH_DEATH, npc.index, _, _, _, _, GetRandomInt(120, 130));
			}
		}
	}
	else if (!b_FlintlockAttacking[npc.index])
	{
		switch(event)
		{
			case 1001:		//Reload sequence intro is over, begin cocking the gun.
			{
				b_ReloadAnimNeeded[npc.index] = true;
			}
			case 1002:		//Reload sequence part 1, play sound effect.
			{
				EmitSoundToAll(SND_FLINTLOCK_RELOAD_START, npc.index);
			}
			case 1003:		//Reload sequence part 2, play sound effect.
			{
				EmitSoundToAll(SND_FLINTLOCK_RELOAD_FINISH, npc.index);
			}
			case 1004:		//Reload sequence ends.
			{
				i_FlintlockAmmo[npc.index]++;

				if (i_FlintlockAmmo[npc.index] >= FLINTLOCK_CLIP)
				{
					EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index, _, _, _, _, GetRandomInt(120, 130));
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + FLINTLOCK_RELOAD_DELAY;
					
					npc.m_flSpeed = BONES_FLINTLOCK_SPEED;

					b_ReloadAnimNeeded[npc.index] = true;
				}
				else
				{
					b_ReloadAnimNeeded[npc.index] = true;
				}
			}
		}
	}
	else
	{
		switch(event)
		{
			case 1001:		//Cocks gun, play sound
			{
				EmitSoundToAll(SND_FLINTLOCK_RELOAD_START, npc.index);
			}
			case 1002:		//Cocks gun, play sound
			{
				EmitSoundToAll(SND_FLINTLOCK_RELOAD_FINISH, npc.index);
			}
		}
	}
}

public void FlintlockBones_ClotThink(int iNPC)
{
	FlintlockBones npc = view_as<FlintlockBones>(iNPC);
	
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
	
	if (npc.m_blSetBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_DEADEYE_RUN");
		npc.m_blSetBuffedSkeletonAnimation = false;
	}

	if (npc.m_blSetNonBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_SWASHBUCKLER_RUN_LOADED");
		npc.m_blSetNonBuffedSkeletonAnimation = false;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + (b_FlintlockAttacking[npc.index] || b_FlintlockWindupPhase[npc.index] || b_DeadeyeCharging[npc.index] || (!b_BonesBuffed[npc.index] && i_FlintlockAmmo[npc.index] < FLINTLOCK_CLIP) ? 0.01 : 0.1);

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	if (b_ReloadAnimNeeded[npc.index])
	{
		if (i_FlintlockAmmo[npc.index] >= FLINTLOCK_CLIP)
			npc.AddGesture("ACT_SWASHBUCKLER_RELOAD_END");
		else
			npc.AddGesture("ACT_SWASHBUCKLER_RELOAD_PUMP", _, _, _, FLINTLOCK_RELOADSPEED);

		b_ReloadAnimNeeded[npc.index] = false;
	}

	if (b_ForceShootAnimFlintlock[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_DEADEYE_SHOOT");
		if (iActivity > 0)
			npc.StartActivity(iActivity);

		Deadeye_Whooshes[npc.index] = 5;

		b_ForceShootAnimFlintlock[npc.index] = false;
	}

	if (b_BonesBuffed[npc.index])
	{
		npc.m_flSpeed = (b_DeadeyeCharging[npc.index] ? BONES_FLINTLOCK_SPEED_BUFFED_CHARGING : BONES_FLINTLOCK_SPEED_BUFFED);
	}

	int closest = npc.m_iTarget;

	if (b_DeadeyeCharging[npc.index] && b_BonesBuffed[npc.index])
	{
		if (GetGameTime(npc.index) >= f_DeadeyeChargeTime[npc.index])
		{
			npc.RemoveGesture("ACT_DEADEYE_CHARGE_GUN");

			int iActivity = npc.LookupActivity("ACT_DEADEYE_ATTACK_IMMINENT");
			if (iActivity > 0)
				npc.StartActivity(iActivity);

			b_DeadeyeCharging[npc.index] = false;
			b_FlintlockWindupPhase[npc.index] = true;
			ApplyBarrelEffect(npc, PARTICLE_FLINTLOCK_BARREL);

			if (IsValidEnemy(npc.index, closest))
			{
				float predict[3], myPos[3];
				WorldSpaceCenter(npc.index, myPos);
				PredictSubjectPositionForProjectiles_NoNPCNeeded(myPos, closest, DEADEYE_VELOCITY, _, predict);
				npc.FaceTowards(predict, 15000.0);
			}

			npc.StopPathing();
		}
	}
	
	if (b_FlintlockAttacking[npc.index] && !b_BonesBuffed[npc.index] && GetGameTime(npc.index) >= npc.m_flNextRangedAttack)
	{
		float vicPos[3];

		if (IsValidEnemy(npc.index, closest) && Can_I_See_Enemy_Only(npc.index, closest))
		{
			WorldSpaceCenter(closest, vicPos);
			npc.FaceTowards(vicPos, FLINTLOCK_TURNRATE);
		}
		else
		{
			float ang[3], Direction[3], startPos[3];
			WorldSpaceCenter(npc.index, startPos);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, 200.0);
			AddVectors(startPos, Direction, vicPos);
		}

		if (npc.IHaveAmmo())
		{
			npc.AddGesture("ACT_SWASHBUCKLER_ATTACK_SHOOT", _, _, _, 0.833 / BONES_FLINTLOCK_ATTACKINTERVAL);
			EmitSoundToAll(SND_FLINTLOCK_SHOOT, npc.index, _, _, _, 0.8, GetRandomInt(80, 110));
			float pos[3], ang[3];
			npc.GetAttachment("shotgun_muzzle", pos, ang);
			ParticleEffectAt(pos, PARTICLE_FLINTLOCK_MUZZLE);

			for (int i = 0; i < FLINTLOCK_COUNT; i++)
				Flintlock_ShootProjectile(npc, vicPos, FLINTLOCK_VELOCITY, FLINTLOCK_DAMAGE, pos);

			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_FLINTLOCK_ATTACKINTERVAL;

			i_FlintlockAmmo[npc.index]--;
		}
		else if (i_FlintlockDryShots[npc.index] > 0)
		{
			npc.AddGesture("ACT_SWASHBUCKLER_ATTACK_SHOOT_NO_AMMO");
			EmitSoundToAll(SND_FLINTLOCK_SHOOT_NO_AMMO, npc.index, _, _, _, 0.8, GetRandomInt(80, 110));
			i_FlintlockDryShots[npc.index]--;

			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_FLINTLOCK_ATTACKINTERVAL;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_SWASHBUCKLER_RUN_LOADED");
			if (iActivity > 0)
				npc.StartActivity(iActivity);
			npc.m_flSpeed = BONES_FLINTLOCK_SPEED_NO_AMMO;

			b_FlintlockAttacking[npc.index] = false;
			f_ReloadAtFlintlock[npc.index] = GetGameTime(npc.index) + FLINTLOCK_RELOADTIME;

			EmitSoundToAll(SND_FLINTLOCK_SCARED, npc.index, _, _, _, _, GetRandomInt(80, 100));
		}
	}
	else if(IsValidEnemy(npc.index, closest) && !b_FlintlockWindupPhase[npc.index] && !b_FlintlockAttacking[npc.index])
	{
		float pos[3], targPos[3], optimalPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
					
		if (!Can_I_See_Enemy_Only(npc.index, closest))
		{
			npc.StartPathing();
			npc.SetGoalEntity(closest);
		}
		else
		{
			if (flDistanceToTarget < FLINTLOCK_HOVER_MINDIST && (!npc.IHaveAmmo() || i_FlintlockAmmo[npc.index] < FLINTLOCK_CLIP))
			{
				npc.StartPathing();
				BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);
				npc.SetGoalVector(optimalPos, true);
			}
			else
			{
				npc.StartPathing();
				npc.SetGoalEntity(closest);
			}

			Flintlock_CheckShoot(npc, closest);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if (GetGameTime(npc.index) >= f_ReloadAtFlintlock[npc.index] && f_ReloadAtFlintlock[npc.index] > 0.0 && !npc.IHaveAmmo() && !b_BonesBuffed[npc.index])
	{
		npc.AddGesture("ACT_SWASHBUCKLER_RELOAD_INTRO");
		f_ReloadAtFlintlock[npc.index] = 0.0;
	}
	
	npc.PlayIdleSound();
}

stock float[] Flintlock_ConstrainDistance(float startPos[3], float endPos[3], float distance)
{	
	if (GetVectorDistance(startPos, endPos, true) >= Pow(distance, 2.0))
	{
		float constraint = distance/GetVectorDistance(startPos, endPos);
		
		for (int i = 0; i < 3; i++)
		{
			endPos[i] = ((endPos[i] - startPos[i]) * constraint) + startPos[i];
		}
	}
	
	return endPos;
}

public bool Flintlock_WorldOnly(any entity, any contentsMask)
{
	if (IsValidClient(entity))
	{
		return false;
	}
	
	bool hit = true;
	
	if (IsValidEntity(entity))
	{
		char entname[255];
		GetEntityClassname(entity, entname, 255);
		hit = StrContains(entname, "zr_base_npc") == -1;
	}
	
	return hit;
}

public Action FlintlockBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	FlintlockBones npc = view_as<FlintlockBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void FlintlockBones_NPCDeath(int entity)
{
	FlintlockBones npc = view_as<FlintlockBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	npc.RemoveAllWearables();
	RemoveBarrelEffect(npc);
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


