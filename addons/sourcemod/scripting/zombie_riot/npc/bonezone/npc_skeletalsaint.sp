#pragma semicolon 1
#pragma newdecls required

#define BONES_SAINT_HP			"500"
#define BONES_SAINT_HP_BUFFED	"5000"

#define BONES_SAINT_SKIN		"2"
#define BONES_SAINT_SKIN_BUFFED	"3"

#define BONES_SAINT_SCALE		"1.0"
#define BONES_SAINT_SCALE_BUFFED	"1.2"

#define BONES_SAINTBONES_BUFFPARTICLE	"utaunt_auroraglow_orange_parent"

#define PRIEST_HEALINGPARTICLE		"superrare_greenenergy"

static float BONES_SAINT_SPEED = 300.0;
static float BONES_SAINT_SPEED_BUFFED = 350.0;

static float SAINTBONES_HEAL_RANGE = 300.0;
static float SAINTBONES_HEAL_RANGE_BUFFED = 450.0;

static float SAINTBONES_PRIEST_HEALPERCENTAGE = 0.05;
static int SAINTBONES_PRIEST_MINHEALING = 2;

static float Priest_EnemyHover_MinDist = 200.0;
static float Priest_EnemyHover_MaxDist = 400.0;

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
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

static bool b_BonesBuffed[MAXENTITIES];

static int Priest_OldHealTarget[MAXENTITIES];
static int Priest_HealingParticle[MAXENTITIES];
static bool Priest_IsHealing[MAXENTITIES];
static float Priest_LoopHealingGesture[MAXENTITIES];

public void SaintBones_OnMapStart_NPC()
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

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/classic.mdl");
	PrecacheModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
}

methodmap SaintBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayMeleeHitSound()");
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
	
	
	
	public SaintBones(int client, float vecPos[3], float vecAng[3], bool ally, bool buffed)
	{
		SaintBones npc = view_as<SaintBones>(CClotBody(vecPos, vecAng, "models/zombie_riot/the_bone_zone/basic_bones.mdl", buffed ? BONES_SAINT_SCALE_BUFFED : BONES_SAINT_SCALE, buffed ? BONES_SAINT_HP_BUFFED : BONES_SAINT_HP, ally, false));
		
		i_NpcInternalId[npc.index] = buffed ? BONEZONE_BUFFED_SAINTBONES : BONEZONE_SAINTBONES;
		b_BonesBuffed[npc.index] = buffed;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_SAINTBONES_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}
		
		Saint_GiveCosmetics(npc, buffed);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_ARCHMAGE_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_SAINT_SKIN_BUFFED : BONES_SAINT_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_SAINT_SPEED_BUFFED : BONES_SAINT_SPEED);
		
		SDKHook(npc.index, SDKHook_Think, SaintBones_ClotThink);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void SaintBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		i_NpcInternalId[index] = BONEZONE_BUFFED_SAINTBONES;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_SAINT_SCALE_BUFFED);
		int HP = StringToInt(BONES_SAINT_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_SAINT_SPEED_BUFFED;
		Saint_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_SAINT_SKIN_BUFFED);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_SAINTBONES_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		i_NpcInternalId[index] = BONEZONE_SAINTBONES;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_SAINT_SCALE);
		int HP = StringToInt(BONES_SAINT_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_SAINT_SPEED;
		Saint_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_SAINT_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_SAINTBONES_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();
	}
}

stock void Saint_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/spy/mbsf_spy.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/spr17_guilden_guardian/spr17_guilden_guardian.mdl");
	}
	else
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/demo_hood.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/sum23_glorious_gambeson/sum23_glorious_gambeson.mdl");
	}
	
	DispatchKeyValue(npc.m_iWearable1, "skin", "1");
	DispatchKeyValue(npc.m_iWearable2, "skin", "1");
}

stock int Priest_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void Priest_RemoveHealingParticle(int index)
{
	int particle = EntRefToEntIndex(Priest_HealingParticle[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

//TODO 
//Skeletal Saints are buff providers and healers.
//Profaned Priests (the non-buffed variant) heal a single target. They will prioritize non-buffed skeletons who do not already have a healer. Skeletons being healed by a Profaned Priest are transformed into their buffed variant, and will revert to their normal variant when the healing stops, unless they naturally spawned buffed.
//Skeletal Saints (the buffed variant) provide healing in a radius. All skeletons being healed by this effect are transformed into their buffed counterpart.
//Profaned Priests cannot be transformed into Skeletal Saints by either of these effects, though they *can* be buffed by other sources.
//If all valid heal targets are dead (meaning everything that is not a Saint or Priest), they will take on the movement patterns of Skeletal Archmages and fight by casting low-damage lightning bolts.

//TODO: PRIEST HEAL TARGET PRIORITY LIST:
//	1. Non-buffed skeletons, not including healers.
//	2. Any skeleton, not including healers.
//	3. Literally any friendly NPC that is not a healer.
//	4. No valid heal targets exist, become the senate and start zapping people.

public void SaintBones_ClotThink(int iNPC)
{
	SaintBones npc = view_as<SaintBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
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
	
	int closest = npc.m_iTarget;
	
	if (b_BonesBuffed[npc.index])
		SaintBones_SaintLogic(npc, closest);
	else
		SaintBones_PriestLogic(npc, closest);
	
	npc.PlayIdleSound();
}

public void SaintBones_PriestLogic(SaintBones npc, int closest)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index) && !IsValidAlly(npc.index, closest))
	{
		npc.m_iTarget = GetClosestAlly(npc.index);	//TODO: This needs to be a custom method which prioritizes non-buffed skeletons, and chooses the nearest enemy if no valid allies are alive
		closest = npc.m_iTarget;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	if (!IsValidEntity(closest))
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		//npc.m_iTarget = GetClosestTarget(npc.index);
		
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_PRIEST_HEALING");
			Priest_IsHealing[npc.index] = false;
		}
		
		return;
	}
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
			
	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index));
				
	CClotBody targetNPC = view_as<CClotBody>(closest);
	
	npc.FaceTowards(vecTarget, 15000.0);
	
	if(IsValidAlly(npc.index, closest))
	{
		int currentHealTarget = EntRefToEntIndex(Priest_OldHealTarget[npc.index]);
		if (closest != currentHealTarget)
		{
			if (IsValidEntity(currentHealTarget))
			{
				CClotBody oldNPC = view_as<CClotBody>(currentHealTarget);
				oldNPC.BoneZone_SetBuffedState(false, npc.index);
			}
			
			Priest_OldHealTarget[npc.index] = EntIndexToEntRef(closest);
		}

		NPC_SetGoalEntity(npc.index, closest);

		//Only walk up to half the healing distance away from the target, we don't want to be *too* close to them.
		if (flDistanceToTarget <= SAINTBONES_HEAL_RANGE * 0.5)
		{
			npc.StopPathing();
		}
		else
		{
			npc.StartPathing();
		}

		//TODO: Add a gesture where he has his arm outstretched towards the heal target. Attach the Green Energy unusual particle to his hand, then 
		//draw a green TE beam from his hand to the heal target's body.
		if(flDistanceToTarget <= SAINTBONES_HEAL_RANGE)
		{
			if (!Priest_IsHealing[npc.index])
			{
				Priest_HealingParticle[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, PRIEST_HEALINGPARTICLE, _, "handR"));
				npc.AddGesture("ACT_PRIEST_HEALING");
				Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				Priest_IsHealing[npc.index] = true;
			}
			else
			{
				if (GetGameTime(npc.index) >= Priest_LoopHealingGesture[npc.index])
				{
					npc.AddGesture("ACT_PRIEST_HEALING");
					Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				}
			}
			
			int particle = EntRefToEntIndex(Priest_HealingParticle[npc.index]);
			if (IsValidEntity(particle))
			{
				float startLoc[3];
				GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", startLoc);	
				vecTarget[2] += 20.0;
				SpawnBeam_Vectors(startLoc, vecTarget, 0.1, 20, 255, 20, 255, PrecacheModel("materials/sprites/lgtning.vmt"), _, _, _, 10.0);
			}
			
			float maxHP = float(GetEntProp(targetNPC.index, Prop_Data, "m_iHealth"));
			int HealingAmount = RoundFloat(maxHP * SAINTBONES_PRIEST_HEALPERCENTAGE);
			if (HealingAmount < SAINTBONES_PRIEST_MINHEALING)
				HealingAmount = SAINTBONES_PRIEST_MINHEALING;
			
			if(GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") < GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(targetNPC.index, Prop_Data, "m_iHealth", GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") + HealingAmount);
				if(GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") >= GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(targetNPC.index, Prop_Data, "m_iHealth", GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"));
				}
			}
			
			targetNPC.BoneZone_SetBuffedState(true, npc.index);
			npc.m_flSpeed = targetNPC.m_flSpeed * 1.2;	//Move a little faster than the target NPC so we don't lose them.
		}
		else
		{
			if (Priest_IsHealing[npc.index])
			{
				Priest_RemoveHealingParticle(npc.index);
				npc.RemoveGesture("ACT_PRIEST_HEALING");
				Priest_IsHealing[npc.index] = false;
			}
			
			targetNPC.BoneZone_SetBuffedState(false, npc.index);
			npc.m_flSpeed = BONES_SAINT_SPEED;
		}
	}
	else if (IsValidEnemy(npc.index, closest))
	{
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_PRIEST_HEALING");
			Priest_IsHealing[npc.index] = false;
		}
			
		float optimalPos[3];
		
		if (flDistanceToTarget < Priest_EnemyHover_MinDist)
		{
			npc.StartPathing();
			optimalPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, closest);
			NPC_SetGoalVector(npc.index, optimalPos, true);
		}
		else if (flDistanceToTarget > Priest_EnemyHover_MaxDist)
		{
			npc.StartPathing();
			NPC_SetGoalEntity(npc.index, closest);
		}
		else
		{
			npc.StopPathing();
		}
		
		//TODO: Make them periodically shoot lightning at the closest enemy.
	}
}

public void SaintBones_SaintLogic(SaintBones npc, int closest)
{
	
}

public Action SaintBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	SaintBones npc = view_as<SaintBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void SaintBones_NPCDeath(int entity)
{
	SaintBones npc = view_as<SaintBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, SaintBones_ClotThink);
	
	for (int i = 1; i < 2049; i++)
	{
		if (!IsValidEntity(i) || i == entity)	
			continue;
			
		CClotBody other = view_as<CClotBody>(i);
		other.BoneZone_SetBuffedState(false, entity);
	}
	
	if (Priest_IsHealing[entity])
	{
		Priest_RemoveHealingParticle(entity);
		npc.RemoveGesture("ACT_PRIEST_HEALING");
		Priest_IsHealing[entity] = false;
	}
	
	npc.RemoveAllWearables();
	
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


