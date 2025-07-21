#pragma semicolon 1
#pragma newdecls required

static float BONES_RATTLER_SPEED = 360.0;	//Rattler movement speed while it has ammo
static float BONES_RATTLER_SPEED_NO_AMMO = 230.0;	//Rattler movement speed while it has no ammo
static float BONES_RATTLER_SPEED_BUFFED = 260.0;	//Hitman movement speed while it is not charging its gun
static float BONES_RATTLER_SPEED_BUFFED_CHARGING = 400.0;	//Hitman movement speed while it is charging its gun

#define BONES_RATTLER_HP				"900"
#define BONES_RATTLER_HP_BUFFED		"4500"

//RATTLER: Basic ranged unit. Wields an SMG with a large clip and high rate of fire, but low damage.
//When their SMG is loaded, they will run towards the nearest target. Then, when within range, they will stop and unload their clip on that target.
//Once they run out of ammo, they will initiate a reload phase, running away if an enemy is too close.
static float RATTLER_DAMAGE = 20.0;		//Projectile damage for Rattlers.
static float RATTLER_VELOCITY = 800.0;	//Projectile velocity.
static float RATTLER_LIFESPAN = 1.0;	//Projectile lifespan.
static float RATTLER_ENTITYMULT = 2.0;	//Amount to multiply damage dealt by Rattler projectiles to enemies.
static float RATTLER_RANGE = 500.0;		//Range in which Rattlers will shoot.
static int RATTLER_CLIP = 24;			//Clip size.
static float RATTLER_RELOADTIME = 3.0;	//Time after attack finishes before the NPC will reload.
static float RATTLER_TURNRATE = 1200.0;	//Rate at which the NPC turns to face its target while firing.
static int RATTLER_EMPTY = 3;			//Number of times the Rattler will attempt to fire its gun once it runs out of ammo. This is used to indicate it has run out with a unique animation and sound effect, so players can react.
static float RATTLER_SPREAD = 4.0;		//Random spread.
static float RATTLER_RELOAD_DELAY = 1.0;	//Delay after the reload finishes before the Rattler can attack again.

//HOLLOW HITMAN: Buffed range unit, slowly fires powerful explosive projectiles from a revolver. Predicts within a large radius.
//Functions similarly to Rattlers in that it will run away while charging up its next shot, then chase the nearest target until in-range once its shot is fully charged.
static float HITMAN_RANGE = 1000.0;			//Range in which Hollow Hitmen will shoot.
//static float HITMAN_PREDICT_RANGE = 600.0;	//Range in which Hollow Hitmen will predict their target's position.
static float HITMAN_VELOCITY = 1200.0;		//Projectile velocity.
static float HITMAN_DMG = 400.0;			//Blast damage.
static float HITMAN_RADIUS = 140.0;			//Blast radius.
static float HITMAN_FALLOFF_MULTIHIT = 0.8;	//Amount to multiply damage dealt per target hit by the blast.
static float HITMAN_FALLOFF_RADIUS = 0.66;	//Maximum damage falloff, based on radius.
static float HITMAN_CHARGE_TIME = 4.0;		//Time it takes for Hollow Hitmen to charge a shot.
static float HITMAN_ENTITYMULT = 4.0;		//Damage multiplier for buildings.

static float RATTLER_NATURAL_BUFF_CHANCE = 0.05;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float RATTLER_NATURAL_BUFF_LEVEL_MODIFIER = 0.1;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float RATTLER_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static float BONES_RATTLER_ATTACKINTERVAL = 0.125;
static float BONES_RATTLER_ATTACKINTERVAL_BUFFED = 2.0;

static float RATTLER_HOVER_MINDIST = 400.0;
//static float RATTLER_HOVER_MAXDIST = 700.0;
//static float RATTLER_HOVER_OPTIMALDIST = 550.0;

static float f_RattlerFireballDMG[2049] = { 0.0, ... };

#define BONES_RATTLER_SCALE				"1.0"
#define BONES_RATTLER_BUFFED_SCALE			"1.2"

#define BONES_RATTLER_SKIN						"0"
#define BONES_RATTLER_BUFFED_SKIN				"1"

#define SND_RATTLER_SHOOT					")weapons/doom_sniper_smg.wav"
#define SND_RATTLER_SHOOT_NO_AMMO			")weapons/shotgun_empty.wav"
#define SND_RATTLER_HIT						")player/pain.wav"
#define SND_RATTLER_RELOAD_FINISH			")weapons/sniper_bolt_forward.wav"
#define SND_RATTLER_RELOAD_START			")weapons/sniper_bolt_back.wav"
#define SND_RATTLER_SCARED					")vo/scout_sf12_scared01.mp3"
#define SND_RATTLER_SWING					")weapons/machete_swing.wav"
#define SND_RATTLER_SWING_BIG				")misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_RATTLER_STOMP					")weapons/push_impact.wav"
#define SND_HITMAN_REVOLVER_SPIN			")player/taunt_clip_spin.wav"
#define SND_HITMAN_EXPLODE					")misc/halloween/spell_fireball_impact.wav"
#define SND_HITMAN_FIRE						")weapons/diamond_back_03_crit.wav"
#define SND_HITMAN_FIRE_2					")misc/halloween/spell_fireball_cast.wav"

#define PARTICLE_RATTLER_FIREBALL			"nailtrails_medic_red_crit"
#define PARTICLE_RATTLER_FIREBALL_BUFFED	"spell_fireball_small_blue"
#define PARTICLE_RATTLER_BARREL				"sentry_rocket_8"
#define PARTICLE_FIREBALL_HIT				"flaregun_destroyed"
#define PARTICLE_FIREBALL_EXPLODE			"spell_fireball_tendril_parent_blue"
#define PARTICLE_RATTLER_MUZZLE				"muzzle_pistol"
#define PARTICLE_HITMAN_FLASH				"muzzle_bignasty"

#define BONES_RATTLER_BUFFPARTICLE			"utaunt_runeprison_teamcolor_blue"//"utaunt_auroraglow_purple_parent"

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

public void RattlerBones_OnMapStart_NPC()
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
	PrecacheSound(SND_RATTLER_SHOOT);
	PrecacheSound(SND_RATTLER_HIT);
	PrecacheSound(SND_RATTLER_SHOOT_NO_AMMO);
	PrecacheSound(SND_RATTLER_RELOAD_START);
	PrecacheSound(SND_RATTLER_RELOAD_FINISH);
	PrecacheSound(SND_RATTLER_SCARED);
	PrecacheSound(SND_RATTLER_SWING);
	PrecacheSound(SND_RATTLER_SWING_BIG);
	PrecacheSound(SND_RATTLER_STOMP);
	PrecacheSound(SND_HITMAN_REVOLVER_SPIN);
	PrecacheSound(SND_HITMAN_EXPLODE);
	PrecacheSound(SND_HITMAN_FIRE);
	PrecacheSound(SND_HITMAN_FIRE_2);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rattler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rattler");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Hollow Hitman");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_rattler_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return RattlerBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return RattlerBones(client, vecPos, vecAng, ally, true);
}

static bool b_HitmanCharging[MAXENTITIES] = { false, ... };
static int i_RattlerAmmo[MAXENTITIES] = { 0, ... };
static int i_RattlerDryShots[MAXENTITIES] = { 0, ... };
static bool b_RattlerAttacking[MAXENTITIES] = { false, ... };
static bool b_RattlerWindupPhase[MAXENTITIES] = { false, ... };
static float f_ReloadAt[MAXENTITIES] = { 0.0, ... };
static float f_HitmanChargeTime[MAXENTITIES] = { 0.0, ... };
static bool b_ForceShootAnim[MAXENTITIES] = { false, ...};
static int i_BarrelEffect[MAXENTITIES] = { -1, ... };
static int Hitman_Whooshes[MAXENTITIES] = { -1, ... };

methodmap RattlerBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CRattlerBones::PlayMeleeHitSound()");
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
			return b_HitmanCharging[this.index];
		}
		
		return i_RattlerAmmo[this.index] > 0;
	}
	
	public RattlerBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = RATTLER_NATURAL_BUFF_CHANCE;
			if (RATTLER_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / RATTLER_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * RATTLER_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		RattlerBones npc = view_as<RattlerBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_RATTLER_BUFFED_SCALE : BONES_RATTLER_SCALE, buffed && !randomlyBuffed ? BONES_RATTLER_HP_BUFFED : BONES_RATTLER_HP, ally, false));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_RATTLER_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_RATTLER_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_RATTLER_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_RATTLER_BUFFED_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_RATTLER_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_RATTLER_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Hollow Hitman");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Rattler");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(RattlerBones_SetBuffed);
		npc.m_bisWalking = false;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.5;

		func_NPCDeath[npc.index] = view_as<Function>(RattlerBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RattlerBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RattlerBones_ClotThink);
		
		Rattler_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			int iActivity = npc.LookupActivity("ACT_HITMAN_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Hitman_AnimEvent;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_RATTLER_RUN_LOADED");
			if(iActivity > 0) npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Rattler_AnimEvent;
		}

		i_RattlerAmmo[npc.index] = RATTLER_CLIP;
		b_HitmanCharging[npc.index] = false;
		b_RattlerAttacking[npc.index] = false;
		b_RattlerWindupPhase[npc.index] = false;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_RATTLER_BUFFED_SKIN : BONES_RATTLER_SKIN);

		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (buffed ? BONES_RATTLER_ATTACKINTERVAL_BUFFED : BONES_RATTLER_ATTACKINTERVAL);
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_RATTLER_SPEED_BUFFED : BONES_RATTLER_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void ApplyBarrelEffect(CClotBody npc, char type[255])
{
	RemoveBarrelEffect(npc);
	i_BarrelEffect[npc.index] = EntIndexToEntRef(Rattler_AttachParticle(npc.index, type, _, "revolver_muzzle"));
}

public void RemoveBarrelEffect(CClotBody npc)
{
	int ent = EntRefToEntIndex(i_BarrelEffect[npc.index]);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
}

public void RattlerBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	i_RattlerAmmo[npc.index] = RATTLER_CLIP;
	b_HitmanCharging[npc.index] = false;
	b_RattlerAttacking[npc.index] = false;
	b_RattlerWindupPhase[npc.index] = false;
	npc.RemoveGesture("ACT_HITMAN_CHARGE_GUN");
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
		Rattler_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_RATTLER_BUFFED_SKIN);

		func_NPCAnimEvent[npc.index] = Hitman_AnimEvent;
		npc.m_blSetNonBuffedSkeletonAnimation = false;
		npc.m_blSetBuffedSkeletonAnimation = true;
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		Rattler_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_RATTLER_SKIN);

		func_NPCAnimEvent[npc.index] = Rattler_AnimEvent;

		npc.m_blSetNonBuffedSkeletonAnimation = true;
		npc.m_blSetBuffedSkeletonAnimation = false;
	}
}

stock void Rattler_GiveCosmetics(CClotBody npc, bool buffed)
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

stock int Rattler_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void Rattler_CheckShoot(RattlerBones npc, int closest)
{
	if (npc.m_flNextRangedAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index) && !b_RattlerAttacking[npc.index] && !b_RattlerWindupPhase[npc.index] && !b_HitmanCharging[npc.index])
	{
		if (!Can_I_See_Enemy_Only(npc.index, closest))
			return;

		float vicPos[3], userPos[3];
		WorldSpaceCenter(closest, vicPos);
		WorldSpaceCenter(npc.index, userPos);

		if (!b_BonesBuffed[npc.index] && GetVectorDistance(vicPos, userPos) <= RATTLER_RANGE && npc.IHaveAmmo())
		{
			int iActivity = npc.LookupActivity("ACT_RATTLER_ATTACK_IMMINENT");
			if(iActivity > 0) npc.StartActivity(iActivity);
			b_RattlerWindupPhase[npc.index] = true;
			npc.FaceTowards(vicPos, 15000.0);
			i_RattlerDryShots[npc.index] = RATTLER_EMPTY;
			npc.StopPathing();
		}
		else if (b_BonesBuffed[npc.index] && GetVectorDistance(vicPos, userPos) <= HITMAN_RANGE)
		{
			npc.AddGesture("ACT_HITMAN_DEPLOY_GUN");
			b_HitmanCharging[npc.index] = true;
			b_ForceShootAnim[npc.index] = false;
			f_HitmanChargeTime[npc.index] = GetGameTime(npc.index) + HITMAN_CHARGE_TIME;
			ApplyBarrelEffect(npc, PARTICLE_RATTLER_FIREBALL_BUFFED);
		}
	}
}

public void Rattler_ShootProjectile(RattlerBones npc, float vicLoc[3], float vel, float damage, float startPos[3])
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
				vecAngles[i] += GetRandomFloat(-RATTLER_SPREAD, RATTLER_SPREAD);
		}
			
		GetAngleVectors(vecAngles, buffer, NULL_VECTOR, NULL_VECTOR);
		vecForward[0] = buffer[0] * vel;
		vecForward[1] = buffer[1] * vel;
		vecForward[2] = buffer[2] * vel;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		f_RattlerFireballDMG[entity] = damage;

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
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rattler_Explode);
			Rattler_AttachParticle(entity, PARTICLE_RATTLER_FIREBALL_BUFFED, _, "");
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, Rattler_FireballTouch);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rattler_DontExplode);
			Rattler_AttachParticle(entity, PARTICLE_RATTLER_FIREBALL, _, "");
			CreateTimer(RATTLER_LIFESPAN, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Rattler_FireballTouch(int entity, int other)
{
	if (!IsValidEntity(other))
		return Plugin_Continue;
		
	int team1 = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(other, Prop_Send, "m_iTeamNum");
	
	if (team1 != team2)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		float damage = (ShouldNpcDealBonusDamage(other) ? f_RattlerFireballDMG[entity] * RATTLER_ENTITYMULT : f_RattlerFireballDMG[entity]);
		SDKHooks_TakeDamage(other, entity, IsValidEntity(owner) ? owner : entity, damage);
			
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, PARTICLE_FIREBALL_HIT, 2.0);
		EmitSoundToAll(SND_RATTLER_HIT, entity, _, _, _, 0.8, GetRandomInt(80, 110));

		RemoveEntity(entity);
	}
		
	return Plugin_Continue;
}

public MRESReturn Rattler_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public MRESReturn Rattler_Explode(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_FIREBALL_EXPLODE, 2.0);
	EmitSoundToAll(SND_HITMAN_EXPLODE, entity, _, 120, _, _, GetRandomInt(90, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_RattlerFireballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, HITMAN_RADIUS, HITMAN_FALLOFF_MULTIHIT, HITMAN_FALLOFF_RADIUS, isBlue, _, true, HITMAN_ENTITYMULT);
	
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public void Rattler_LookAtPoint(RattlerBones npc, int closest)
{
	if (IsValidEnemy(npc.index, closest))
	{
		float targLoc[3];
		WorldSpaceCenter(closest, targLoc);
		npc.FaceTowards(targLoc, 15000.0);
	}
}

public void Hitman_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	RattlerBones npc = view_as<RattlerBones>(entity);

	if (!b_BonesBuffed[entity])
		return;

	if (b_HitmanCharging[npc.index])
	{
		switch(event)
		{
			case 1001:		//Sound
			{
				EmitSoundToAll(SND_RATTLER_SWING, npc.index);
			}
			case 1002:		//Sound
			{
				EmitSoundToAll(SND_RATTLER_STOMP, npc.index);
			}
			case 1003:		//Gun is being held by both hands, switch to the loop sequence.
			{
				npc.AddGesture("ACT_HITMAN_CHARGE_GUN", false, _, false);
			}
		}
	}
    else if (b_RattlerWindupPhase[npc.index])
	{
		switch(event)
		{
			case 1001:		//Hitman swings gun upward, play sounds.
			{
				EmitSoundToAll(SND_RATTLER_SWING, npc.index, _, 120);
				EmitSoundToAll(SND_HITMAN_REVOLVER_SPIN, npc.index, _, 120);
			}
			case 1002:		//Attack intro sequence ends, switch to attack sequence and fire projectile.
			{
				b_ForceShootAnim[npc.index] = true;
				b_RattlerWindupPhase[npc.index] = false;
				b_RattlerAttacking[npc.index] = true;

				float pos[3], ang[3], vicLoc[3];
				npc.GetAttachment("revolver_muzzle", pos, ang);
				ParticleEffectAt(pos, PARTICLE_HITMAN_FLASH);
				EmitSoundToAll(SND_HITMAN_FIRE, npc.index, _, 120);
				EmitSoundToAll(SND_HITMAN_FIRE_2, npc.index, _, 120);

				if (IsValidEnemy(npc.index, npc.m_iTarget) && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				{
					PredictSubjectPositionForProjectiles_NoNPCNeeded(pos, npc.m_iTarget, HITMAN_VELOCITY, _, vicLoc);
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

				Rattler_ShootProjectile(npc, vicLoc, HITMAN_VELOCITY, HITMAN_DMG, pos);
			}
		}
	}
	else if (b_RattlerAttacking[npc.index])
	{
		switch(event)
		{
			case 1001:		//Hitman's torso is spinning, play sound.
			{
				EmitSoundToAll(SND_RATTLER_SWING, npc.index, _, 120, _, _, 80 + (5 * Hitman_Whooshes[npc.index]));
				EmitSoundToAll(SND_RATTLER_SWING, npc.index, _, 80, _, 0.8, 80 + (5 * Hitman_Whooshes[npc.index]));
				Hitman_Whooshes[npc.index]--;
			}
			case 1002:		//Hitman is about to stomp, play sound.
			{
				EmitSoundToAll(SND_RATTLER_SWING_BIG, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1003:		//Remove smoke particle from gun barrel.
			{
				RemoveBarrelEffect(npc);
			}
			case 1004:		//Hitman's foot hits the ground, play sound.
			{
				EmitSoundToAll(SND_RATTLER_STOMP, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1005:		//Hitman laughs, play sound.
			{
				EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index);
			}
			case 1006:		//Attack animation ends, revert to walk cycle.
			{
				b_RattlerAttacking[npc.index] = false;
				int iActivity = npc.LookupActivity("ACT_HITMAN_RUN");
				if (iActivity > 0)
					npc.StartActivity(iActivity);
				npc.StartPathing();

				npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_RATTLER_ATTACKINTERVAL_BUFFED;
			}
		}
	}
}

public void Rattler_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	RattlerBones npc = view_as<RattlerBones>(entity);

	if (b_BonesBuffed[entity])
		return;

	if (b_RattlerWindupPhase[npc.index])
	{
		switch(event)
		{
			case 1001:		//Rattler swings its gun up into the air, play a sound effect.
			{
				EmitSoundToAll(SND_RATTLER_SWING, npc.index, _, _, _, _, GetRandomInt(80, 90));
			}
			case 1002:		//Rattler is about to stomp its foot on the ground, play a sound effect.
			{
				EmitSoundToAll(SND_RATTLER_SWING_BIG, npc.index, _, _, _, _, GetRandomInt(80, 90));
			}
			case 1003:		//Rattler's foot hits the ground, play a sound effect.
			{
				EmitSoundToAll(SND_RATTLER_STOMP, npc.index, _, 120, _, _, GetRandomInt(80, 90));
			}
			case 1004:		//Intro sequence ends, transition to active attack sequence.
			{
				b_RattlerWindupPhase[npc.index] = false;
				b_RattlerAttacking[npc.index] = true;

				int iActivity = npc.LookupActivity("ACT_RATTLER_FIRING_POSE");
				if (iActivity > 0)
					npc.StartActivity(iActivity);

				EmitSoundToAll(SOUND_HHH_DEATH, npc.index, _, _, _, _, GetRandomInt(120, 130));
			}
		}
	}
	else if (!b_RattlerAttacking[npc.index])
	{
		switch(event)
		{
			case 1002:		//Reload sequence part 1, play sound effect.
			{
				EmitSoundToAll(SND_RATTLER_RELOAD_START, npc.index);
			}
			case 1003:		//Reload sequence part 2, play sound effect.
			{
				EmitSoundToAll(SND_RATTLER_RELOAD_FINISH, npc.index);
				EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index, _, _, _, _, GetRandomInt(120, 130));

				int iActivity = npc.LookupActivity("ACT_RATTLER_RUN_LOADED");
				if (iActivity > 0)
					npc.StartActivity(iActivity);
				npc.m_flSpeed = BONES_RATTLER_SPEED;

				if (GetGameTime(npc.index) - npc.m_flNextRangedAttack < RATTLER_RELOAD_DELAY)
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + RATTLER_RELOAD_DELAY;
				}

				i_RattlerAmmo[npc.index] = RATTLER_CLIP;
			}
		}
	}
}

public void RattlerBones_ClotThink(int iNPC)
{
	RattlerBones npc = view_as<RattlerBones>(iNPC);
	
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
		npc.SetActivity("ACT_HITMAN_RUN");
		npc.m_blSetBuffedSkeletonAnimation = false;
	}

	if (npc.m_blSetNonBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_RATTLER_RUN_LOADED");
		npc.m_blSetNonBuffedSkeletonAnimation = false;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + (b_RattlerAttacking[npc.index] || b_RattlerWindupPhase[npc.index] || b_HitmanCharging[npc.index] ? 0.01 : 0.1);
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	if (b_ForceShootAnim[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_HITMAN_SHOOT");
		if (iActivity > 0)
			npc.StartActivity(iActivity);

		Hitman_Whooshes[npc.index] = 5;

		b_ForceShootAnim[npc.index] = false;
	}

	if (b_BonesBuffed[npc.index])
	{
		npc.m_flSpeed = (b_HitmanCharging[npc.index] ? BONES_RATTLER_SPEED_BUFFED_CHARGING : BONES_RATTLER_SPEED_BUFFED);
	}

	int closest = npc.m_iTarget;

	if (b_HitmanCharging[npc.index] && b_BonesBuffed[npc.index])
	{
		if (GetGameTime(npc.index) >= f_HitmanChargeTime[npc.index])
		{
			npc.RemoveGesture("ACT_HITMAN_CHARGE_GUN");

			int iActivity = npc.LookupActivity("ACT_HITMAN_ATTACK_IMMINENT");
			if (iActivity > 0)
				npc.StartActivity(iActivity);

			b_HitmanCharging[npc.index] = false;
			b_RattlerWindupPhase[npc.index] = true;
			ApplyBarrelEffect(npc, PARTICLE_RATTLER_BARREL);

			if (IsValidEnemy(npc.index, closest))
			{
				float predict[3], myPos[3];
				WorldSpaceCenter(npc.index, myPos);
				PredictSubjectPositionForProjectiles_NoNPCNeeded(myPos, closest, HITMAN_VELOCITY, _, predict);
				npc.FaceTowards(predict, 15000.0);
			}

			npc.StopPathing();
		}
	}
	
	if (b_RattlerAttacking[npc.index] && !b_BonesBuffed[npc.index] && GetGameTime(npc.index) >= npc.m_flNextRangedAttack)
	{
		float vicPos[3];

		if (IsValidEnemy(npc.index, closest) && Can_I_See_Enemy_Only(npc.index, closest))
		{
			WorldSpaceCenter(closest, vicPos);
			npc.FaceTowards(vicPos, RATTLER_TURNRATE);
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
			npc.AddGesture("ACT_RATTLER_SHOOT");
			EmitSoundToAll(SND_RATTLER_SHOOT, npc.index, _, _, _, 0.8, GetRandomInt(80, 110));
			float pos[3], ang[3];
			npc.GetAttachment("smg_muzzle_left", pos, ang);
			ParticleEffectAt(pos, PARTICLE_RATTLER_MUZZLE);

			Rattler_ShootProjectile(npc, vicPos, RATTLER_VELOCITY, RATTLER_DAMAGE, pos);
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_RATTLER_ATTACKINTERVAL;

			i_RattlerAmmo[npc.index]--;
		}
		else if (i_RattlerDryShots[npc.index] > 0)
		{
			npc.AddGesture("ACT_RATTLER_SHOOT_NO_AMMO");
			EmitSoundToAll(SND_RATTLER_SHOOT_NO_AMMO, npc.index, _, _, _, 0.8, GetRandomInt(80, 110));
			i_RattlerDryShots[npc.index]--;

			npc.m_flNextRangedAttack = GetGameTime(npc.index) + BONES_RATTLER_ATTACKINTERVAL;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_RATTLER_RUN");
			if (iActivity > 0)
				npc.StartActivity(iActivity);
			npc.m_flSpeed = BONES_RATTLER_SPEED_NO_AMMO;

			b_RattlerAttacking[npc.index] = false;
			f_ReloadAt[npc.index] = GetGameTime(npc.index) + RATTLER_RELOADTIME;

			EmitSoundToAll(SND_RATTLER_SCARED, npc.index, _, _, _, _, GetRandomInt(80, 100));
		}
	}
	else if(IsValidEnemy(npc.index, closest) && !b_RattlerWindupPhase[npc.index] && !b_RattlerAttacking[npc.index])
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
			if (flDistanceToTarget < RATTLER_HOVER_MINDIST && !npc.IHaveAmmo())
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

			Rattler_CheckShoot(npc, closest);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if (GetGameTime(npc.index) >= f_ReloadAt[npc.index] && f_ReloadAt[npc.index] > 0.0 && !npc.IHaveAmmo() && !b_BonesBuffed[npc.index])
	{
		npc.AddGesture("ACT_RATTLER_RELOAD");
		f_ReloadAt[npc.index] = 0.0;
	}
	
	npc.PlayIdleSound();
}

stock float[] Rattler_ConstrainDistance(float startPos[3], float endPos[3], float distance)
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

public bool Rattler_WorldOnly(any entity, any contentsMask)
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

public Action RattlerBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	RattlerBones npc = view_as<RattlerBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void RattlerBones_NPCDeath(int entity)
{
	RattlerBones npc = view_as<RattlerBones>(entity);
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


