#pragma semicolon 1
#pragma newdecls required

//TODO
//To use this template, just replace "BUCCANEER" with whatever your NPC is named.
//Attack logic and custom movement logic are not included in this template.

static float BONES_BUCCANEER_SPEED =  240.0;
static float BONES_BUCCANEER_SPEED_BUFFED = 140.0;

#define BONES_BUCCANEER_HP				"3000"
#define BONES_BUCCANEER_HP_BUFFED			"50000"

static float BONES_BUCCANEER_ATTACKINTERVAL = 0.5;
static float BONES_BUCCANEER_ATTACKINTERVAL_BUFFED = 1.0;

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
		
		int iActivity = npc.LookupActivity("ACT_WIZARD_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		//npc.m_bDoSpawnGesture = true;

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_BUCCANEER_BUFFED_SKIN : BONES_BUCCANEER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
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
		
		//Apply buffed particle:
		/*TE_SetupParticleEffect(BONES_BUCCANEER_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();*/
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
		
		//Remove buffed particle:
		/*TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_BUCCANEER_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();*/
	}
	
	running[npc.index] = false;
}

stock void Buccaneer_GiveCosmetics(CClotBody npc, bool buffed)
{
	//TODO: The non-buffed variant should be bonemerged to an invisible demoman and use demo animations
	npc.RemoveAllWearables();
	
	npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
	
	if (buffed)
	{
		DispatchKeyValue(npc.m_iWearable1, "skin", "0");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 9999.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 9999.0);
		
		DispatchKeyValue(npc.index, "model", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
		
		int iActivity = npc.LookupActivity("ACT_WIZARD_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else	//TODO: Hat is too small on the non-buffed variant, find a way to shift it
	{
		DispatchKeyValue(npc.index, "model", "models/player/demo.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/player/demo.mdl");
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
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
		float pos[3], targPos[3], optimalPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
		NPC_SetGoalEntity(npc.index, closest);
		npc.FaceTowards(targPos, 15000.0);
		
		if (!b_BonesBuffed[npc.index] && !running[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
			if(iActivity > 0) npc.StartActivity(iActivity);
			running[npc.index] = true;
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


