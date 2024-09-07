#pragma semicolon 1
#pragma newdecls required

#define BONES_ALERAISER_HP			"5000"
#define BONES_ALERAISER_SKIN		"1"
#define BONES_ALERAISER_SCALE		"1.0"

static float BONES_ALERAISER_SPEED = 400.0;

//The Aleraiser is a ranged support unit who stays at a distance and tosses bottles of ale at allies.
//These bottles shatter on contact, providing a small amount of healing in a radius with a chance to permanently buff those who are healed.
//If no allies are alive, they smash their bottle on their head, healing themselves, before immediately sprinting towards enemies and rapidly slashing them with the broken bottle.
static float ALERAISER_THROW_RANGE = 400.0;				//Range at which the Aleraiser will begin throwing ale at targets.
static float ALERAISER_THROW_COOLDOWN = 2.0;			//Cooldown between throws.
static float ALERAISER_STOP_RANGE = 300.0;				//Distance from its target at which the Aleraiser will stop moving.
static float ALERAISER_RADIUS = 160.0;					//Ale effect radius.
static float ALERAISER_HEAL_PERCENT = 0.1;				//percentage of max health to heal allies for.
static float ALERAISER_HEAL_MINIMUM = 100.0;			//Minimum healing provided to allies who are within the ale's radius.
static float ALERAISER_SMASH_HEALS = 2500.0;			//Amount the Aleraiser should heal itself when it enters its melee phase.
static float ALERAISER_SPEED_NO_ALLIES = 480.0;			//Movement speed when no non-medic allies are alive.
static float ALERAISER_MELEE_DAMAGE = 60.0;				//Melee damage.
static float ALERAISER_MELEE_SPEED = 1.0;				//Melee attack speed multiplier.
static float ALERAISER_MELEE_INTERVAL = 0.1;			//Cooldown between melee attacks.
static float ALERAISER_MELEE_START_RANGE = 60.0;		//Distance at which the Aleraiser will attempt to attack its target if it can.
static float ALERAISER_MELEE_RANGE = 90.0;				//Melee attack trace hull length.

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

static bool b_AleraiserGoneBerserk[2049] = { false, ... };

public void AleraiserBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/classic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aleraiser");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aleraiser");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_Aleraiser;
	NPC_Add(data);
}

static any Summon_Aleraiser(int client, float vecPos[3], float vecAng[3], int ally)
{
	return AleraiserBones(client, vecPos, vecAng, ally);
}

methodmap AleraiserBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAleraiserBones::PlayMeleeHitSound()");
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
	
	public AleraiserBones(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		AleraiserBones npc = view_as<AleraiserBones>(CClotBody(vecPos, vecAng, "models/zombie_riot/the_bone_zone/basic_bones.mdl", BONES_ALERAISER_SCALE, BONES_ALERAISER_HP, ally, false));
		
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_AleraiserGoneBerserk[npc.index] = false;

		func_NPCDeath[npc.index] = view_as<Function>(AleraiserBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AleraiserBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AleraiserBones_ClotThink);

		Is_a_Medic[npc.index] = true;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.m_bisWalking = false;

		int iActivity = npc.LookupActivity("ACT_ALERAISER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = false;
		DispatchKeyValue(npc.index, "skin", BONES_ALERAISER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = BONES_ALERAISER_SPEED;
		
		SDKHook(npc.index, SDKHook_Think, AleraiserBones_ClotThink);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/xms2013_soviet_stache/xms2013_soviet_stache_sniper.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/tomb_readers/tomb_readers_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/sniper/bio_sniper_boater.mdl");
		
		return npc;
	}
}

public int Aleraiser_GetTarget(AleraiserBones npc)
{
	int closest = -1;

	if (b_AleraiserGoneBerserk[npc.index])
	{
		closest = GetClosestTarget(npc.index);
	}
	else
	{
		//Check 1: Find the closest non-buffed skeleton.
		closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsNonBuffedSkeleton));
		
		//Check 2: There are no non-buffed skeletons, find the closest skeleton.
		if (closest <= 0)
			closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsASkeleton));
		
		//Check 3: There are no skeletons, find the closest ally who is not a healer.
		if (closest <= 0)
			closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsNotAHealer));
		
		//Check 4: We were not able to find ANY valid allies to heal, go berserk.
		if (closest <= 0)
		{
			//TODO: Bottle break sequence
			CPrintToChatAll("Aleraiser would have just gone berserk.");
			closest = GetClosestTarget(npc.index);
			b_AleraiserGoneBerserk[npc.index] = true;
			npc.m_flSpeed = ALERAISER_SPEED_NO_ALLIES;
		}
	}
	
	return closest;
}

//TODO 
//Rewrite
public void AleraiserBones_ClotThink(int iNPC)
{
	AleraiserBones npc = view_as<AleraiserBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
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
		npc.m_iTarget = Aleraiser_GetTarget(npc);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEntity(closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother);

		if (!b_AleraiserGoneBerserk[npc.index])
		{
			if (flDistanceToTarget <= ALERAISER_STOP_RANGE)
			{
				npc.StopPathing();
			}
			else
			{
				NPC_SetGoalEntity(npc.index, closest);
				npc.StartPathing();
			}

			if (flDistanceToTarget <= ALERAISER_THROW_RANGE && npc.m_flNextRangedAttack <= GetGameTime(npc.index))
			{
				CPrintToChatAll("Aleraiser would have just thrown a bottle.");

				//TODO: Throw logic, needs to predict.

				npc.m_flNextRangedAttack = GetGameTime(npc.index) + ALERAISER_THROW_COOLDOWN;
			}
		}	
		else
		{
			if((flDistanceToTarget * flDistanceToTarget) < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else
			{
				NPC_SetGoalEntity(npc.index, closest);
			}

			if (flDistanceToTarget <= ALERAISER_MELEE_START_RANGE && npc.m_flNextMeleeAttack <= GetGameTime(npc.index))
			{
				CPrintToChatAll("Aleraiser would have just used a melee attack.");

				//TODO: Melee logic

				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + ALERAISER_MELEE_INTERVAL;
			}
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = Aleraiser_GetTarget(npc);
	}

	npc.PlayIdleSound();
}

public Action AleraiserBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	AleraiserBones npc = view_as<AleraiserBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void AleraiserBones_NPCDeath(int entity)
{
	AleraiserBones npc = view_as<AleraiserBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, AleraiserBones_ClotThink);
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


