#pragma semicolon 1
#pragma newdecls required

static float BONES_BUCCANEER_SPEED =  240.0;
static float BONES_BUCCANEER_SPEED_BUFFED = 140.0;

#define BONES_BUCCANEER_HP				"6000"
#define BONES_BUCCANEER_HP_BUFFED			"60000"

//BONY BOMBERS (NON-BUFFED VARIANT):
//Walks around holding a Loose Cannon, which it fires at survivors within a given range.
//As this is a ranged unit, it will try to back off if the nearest enemy is too close.
static float BONES_BUCCANEER_ATTACKINTERVAL = 3.5;	//Time between non-buffed variant's shots.
static float BUCCANEER_RANGE = 800.0;	//Maximum distance in which the non-buffed variant can shoot.
static float BUCCANEER_PREDICT_RANGE = 300.0;	//Range in which the non-buffed variant will predict enemy positions when it shoots.
static float BUCCANEER_DAMAGE = 120.0;	//Non-buffed variant's projectile damage.
static float BUCCANEER_RADIUS = 100.0;	//Non-buffed variant's projectile blast radius.
static float BUCCANEER_PROJECTILE_SPEED = 1200.0;	//The speed of non-buffed projectiles.
static float BUCCANEER_FALLOFF_MULTIHIT = 0.8;	//Multi-hit falloff for non-buffed variant.
static float BUCCANEER_FALLOFF_RADIUS = 0.8;	//Radius-based falloff for non-buffed variant.
static float BUCCANEER_ENTITY_MULT = 6.0;		//Amount to multiply damage dealt to buildings.
static float BUCCANEER_TOO_CLOSE = 200.0;		//Proximity at which Bony Bombers begin to back off.
static float BUCCANEER_TOO_FAR = 600.0;			//Distance at which Bony Bombers begin to give chase.
static float BUCCANEER_GRAVITY = 0.66;			//Gravity applied to Bony Bomber projectiles.

//BRIGADIER BONES (BUFFED VARIANT):
//Rides very slowly on a very large wheeled cannon.
//Will occasionally stop and initiate an animation where it commands the cannon to fire. If not killed before this animation ends,
//the cannon will fire an ENORMOUS cannonball which deals massive damage within a decently large radius. Takes self-knockback upon firing.
//This unit will NOT try to back off if enemies get too close. Instead, it will simply run people over like a Capped Ram.
static float BONES_BUCCANEER_ATTACKINTERVAL_BUFFED = 8.0;	//Time between shots.
static float BUFFED_RANGE = 1600.0;	//Range in which shots can be fired.
static float BUFFED_DAMAGE = 1200.0;	//Damage dealt by cannonballs.
static float BUFFED_RADIUS = 350.0;		//Cannonball blast radius.
static float BUFFED_PROJECTILE_SPEED = 1800.0;	//Projectile speed.
static float BUFFED_FALLOFF_MULTIHIT = 0.9;	//Multi-hit falloff for cannonballs.
static float BUFFED_FALLOFF_RADIUS = 0.66;	//Radius falloff for cannonballs.
static float BUFFED_ENTITY_MULT = 3.0;	//Amount to multiply damage dealt to buildings.
static float BUFFED_DELAY_MULT = 5.0; //Amount to multiply the duration of the delay before the cannon fires once its animation begins.
static float BUFFED_SELF_KNOCKBACK = 400.0;	//Self-knockback taken when the cannon fires.

#define BONES_BUCCANEER_SCALE					"1.0"
#define BONES_BUCCANEER_BUFFED_SCALE			"1.2"

#define BONES_BUCCANEER_SKIN					"0"
#define BONES_BUCCANEER_BUFFED_SKIN				"2"

//#define BONES_BUCCANEER_BUFFPARTICLE			"utaunt_auroraglow_purple_parent"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
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

static bool b_BonesBuffed[MAXENTITIES];
static bool running[MAXENTITIES];

static float f_CannonballRadius[MAXENTITIES];
static float f_CannonballDMG[MAXENTITIES];
static float f_CannonballFalloff_MultiHit[MAXENTITIES];
static float f_CannonballFalloff_Radius[MAXENTITIES];
static float f_Cannonball_EntMult[MAXENTITIES];

#define SOUND_CANNONBALL_SHOOT		")weapons/loose_cannon_shoot.wav"
#define SOUND_CANNONBALL_EXPLODE	")weapons/loose_cannon_explode.wav"
#define PARTICLE_CANNONBALL_EXPLODE	"ExplosionCore_MidAir_underwater"

public void BuccaneerBones_OnMapStart_NPC()
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

	PrecacheModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
	PrecacheSound(SOUND_CANNONBALL_SHOOT);
	PrecacheSound(SOUND_CANNONBALL_EXPLODE);
}

methodmap BuccaneerBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayMeleeHitSound()");
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
	
	
	
	public BuccaneerBones(int client, float vecPos[3], float vecAng[3], bool ally, bool buffed)
	{
		BuccaneerBones npc = view_as<BuccaneerBones>(CClotBody(vecPos, vecAng, buffed ? "models/zombie_riot/the_bone_zone/basic_bones.mdl" : "models/player/demo.mdl", buffed ? BONES_BUCCANEER_BUFFED_SCALE : BONES_BUCCANEER_SCALE, buffed ? BONES_BUCCANEER_HP_BUFFED : BONES_BUCCANEER_HP, ally, false));
		
		i_NpcInternalId[npc.index] = buffed ? BONEZONE_BUFFED_BUCCANEER : BONEZONE_BUCCANEER;
		b_BonesBuffed[npc.index] = buffed;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		
		Buccaneer_GiveCosmetics(npc, buffed);
		
		running[npc.index] = false;
		
		/*if (buffed)
		{
			TE_SetupParticleEffect(BONES_BUCCANEER_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}*/
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if (b_BonesBuffed[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_CANNON_IDLE");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		
		//npc.m_bDoSpawnGesture = true;

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_BUCCANEER_BUFFED_SKIN : BONES_BUCCANEER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = (buffed ? BONES_BUCCANEER_ATTACKINTERVAL_BUFFED : BONES_BUCCANEER_ATTACKINTERVAL);
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_BUCCANEER_SPEED_BUFFED : BONES_BUCCANEER_SPEED);
		
		throwState[npc.index] = THROWSTATE_INACTIVE;
		SDKHook(npc.index, SDKHook_Think, BuccaneerBones_ClotThink);
		
		//npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void BuccaneerBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		i_NpcInternalId[index] = BONEZONE_BUFFED_BUCCANEER;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_BUCCANEER_BUFFED_SCALE);
		int HP = StringToInt(BONES_BUCCANEER_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_BUCCANEER_SPEED_BUFFED;
		Buccaneer_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_BUCCANEER_BUFFED_SKIN);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		i_NpcInternalId[index] = BONEZONE_BUCCANEER;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_BUCCANEER_SCALE);
		int HP = StringToInt(BONES_BUCCANEER_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_BUCCANEER_SPEED;
		Buccaneer_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_BUCCANEER_SKIN);
	}
	
	running[npc.index] = false;
}

stock void Buccaneer_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("hat", "models/player/items/sniper/summer_shades.mdl");
		
		float pos[3];
		GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 10.0;
		TeleportEntity(npc.m_iWearable2, pos);
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 9999.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 9999.0);
		
		DispatchKeyValue(npc.index, "model", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
		
		int iActivity = npc.LookupActivity("ACT_CANNON_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else
	{
		DispatchKeyValue(npc.index, "model", "models/player/demo.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/player/demo.mdl");
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl");
		npc.m_iWearable3 = npc.EquipItem("pelvis", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		DispatchKeyValue(npc.m_iWearable3, "skin", BONES_BUCCANEER_SKIN);
	}
}

stock int Buccaneer_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void BuccaneerBones_ClotThink(int iNPC)
{
	BuccaneerBones npc = view_as<BuccaneerBones>(iNPC);
	
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
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		if (b_BonesBuffed[npc.index])
		{
			//TODO: Buffed logic
		}
		else
		{
			Buccaneer_NonBuffedLogic(npc, closest);
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		
		if (!b_BonesBuffed[npc.index] && running[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_MP_STAND_SECONDARY");
			if(iActivity > 0) npc.StartActivity(iActivity);
			running[npc.index] = false;
		}
	}
	
	npc.PlayIdleSound();
}

public void Buccaneer_NonBuffedLogic(BuccaneerBones npc, int closest)
{
	float pos[3], targPos[3], optimalPos[3]; 
	WorldSpaceCenter(npc.index, pos);
	WorldSpaceCenter(closest, targPos);
			
	float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
	if (flDistanceToTarget <= BUCCANEER_TOO_CLOSE)
	{
		BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);
		NPC_SetGoalVector(npc.index, optimalPos, true);
		npc.StartPathing();
	}
	else if (flDistanceToTarget >= BUCCANEER_TOO_FAR)
	{
		NPC_SetGoalEntity(npc.index, closest);
		npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
	}
	
	npc.FaceTowards(targPos, 15000.0);
	
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch > 0)
	{				
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(WorldSpaceCenterOld(npc.index), targPos, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
									
		float flPitch = npc.GetPoseParameter(iPitch);
									
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
		
	if (!running[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		running[npc.index] = true;
	}
	
	float gt = GetGameTime(npc.index);
	if (gt >= npc.m_flNextRangedAttack && flDistanceToTarget <= BUCCANEER_RANGE && Can_I_See_Enemy(npc.index, closest))
	{
		if (flDistanceToTarget <= BUCCANEER_PREDICT_RANGE)
		{
			PredictSubjectPositionForProjectiles(npc, closest, BUCCANEER_PROJECTILE_SPEED, _, targPos);
		}
		
		Buccaneer_ShootProjectile(npc, targPos, BUCCANEER_PROJECTILE_SPEED, BUCCANEER_DAMAGE);
		npc.m_flNextRangedAttack = gt + BONES_BUCCANEER_ATTACKINTERVAL;
	}
}

public void Buccaneer_ShootProjectile(BuccaneerBones npc, float vicLoc[3], float vel, float damage)
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		npc.GetVectors(vecForward, vecSwingStart, vecAngles);

		GetAbsOrigin(npc.index, vecSwingStart);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vicLoc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*vel;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*vel;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-vel;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		int g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_cannonball.mdl");
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team(entity);
		
		SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue) ? 0 : 1);
		
		if (b_BonesBuffed[npc.index])
		{
			//g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Archmage_Explode);
			//Archmage_AttachParticle(entity, PARTICLE_ARCHMAGE_FIREBALL_BUFFED, _, "");
			DispatchKeyValueFloat(entity, "modelscale", 4.0);
			
			f_CannonballRadius[entity] = BUFFED_RADIUS;
			f_CannonballDMG[entity] = BUFFED_DAMAGE;
			f_CannonballFalloff_MultiHit[entity] = BUFFED_FALLOFF_MULTIHIT;
			f_CannonballFalloff_Radius[entity] = BUFFED_FALLOFF_RADIUS;
			f_Cannonball_EntMult[entity] = BUFFED_ENTITY_MULT;
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, Buccaneer_CannonballTouch);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Buccaneer_DontExplode);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, BUCCANEER_GRAVITY);
			EmitSoundToAll(SOUND_CANNONBALL_SHOOT, entity);
			npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
			
			f_CannonballRadius[entity] = BUCCANEER_RADIUS;
			f_CannonballDMG[entity] = BUCCANEER_DAMAGE;
			f_CannonballFalloff_MultiHit[entity] = BUCCANEER_FALLOFF_MULTIHIT;
			f_CannonballFalloff_Radius[entity] = BUCCANEER_FALLOFF_RADIUS;
			f_Cannonball_EntMult[entity] = BUCCANEER_ENTITY_MULT;
		}
	}
}

public Action Buccaneer_CannonballTouch(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_CANNONBALL_EXPLODE, 2.0);
	EmitSoundToAll(SOUND_CANNONBALL_EXPLODE, entity, _);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_CannonballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, f_CannonballRadius[entity], f_CannonballFalloff_MultiHit[entity], f_CannonballFalloff_Radius[entity], isBlue, _, _, f_Cannonball_EntMult[entity]);
	
	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public MRESReturn Buccaneer_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public Action BuccaneerBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BuccaneerBones npc = view_as<BuccaneerBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BuccaneerBones_NPCDeath(int entity)
{
	BuccaneerBones npc = view_as<BuccaneerBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, BuccaneerBones_ClotThink);
		
	npc.RemoveAllWearables();
	
	if (!b_BonesBuffed[npc.index])
	{
		DispatchKeyValue(npc.index, "model", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
	}
	
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


