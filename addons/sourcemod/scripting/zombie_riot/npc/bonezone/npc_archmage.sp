#pragma semicolon 1
#pragma newdecls required

static float BONES_ARCHMAGE_SPEED = 250.0;
static float BONES_ARCHMAGE_SPEED_BUFFED = 320.0;

#define BONES_ARCHMAGE_HP				"5000"
#define BONES_ARCHMAGE_HP_BUFFED		"15000"

static float BONES_ARCHMAGE_PLAYERDAMAGE = 10.0;
static float BONES_ARCHMAGE_PLAYERDAMAGE_BUFFED = 20.0;

static float BONES_ARCHMAGE_BUILDINGDAMAGE = 20.0;
static float BONES_ARCHMAGE_BUILDINGDAMAGE_BUFFED = 40.0;

static float BONES_ARCHMAGE_ATTACKINTERVAL = 0.5;
static float BONES_ARCHMAGE_ATTACKINTERVAL_BUFFED = 1.0;

static float ARCHMAGE_HOVER_MINDIST = 300.0;
static float ARCHMAGE_HOVER_MAXDIST = 500.0;
static float ARCHMAGE_HOVER_OPTIMALDIST = 400.0;

static float ARCHMAGE_CHARGE_DURATION = 4.0;

#define BONES_ARCHMAGE_SCALE				"1.0"
#define BONES_ARCHMAGE_BUFFED_SCALE			"1.2"

#define BONES_ARCHMAGE_SKIN						"0"
#define BONES_ARCHMAGE_BUFFED_SKIN				"1"

#define PARTICLE_ARCHMAGE_FIREBALL			"superrare_burning1"
#define PARTICLE_ARCHMAGE_FIREBALL_BUFFED	"spell_fireball_small_blue"

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

enum Archmage_ThrowState
{
	THROWSTATE_INACTIVE,
	THROWSTATE_INTRO,
	THROWSTATE_CHARGING,
	THROWSTATE_THROWING
};

Archmage_ThrowState throwState[MAXENTITIES] = { THROWSTATE_INACTIVE, ... };
float throwEndTime[MAXENTITIES + 1] = { 0.0, ... };
float throwThrowTime[MAXENTITIES + 1] = { 0.0, ... };
float chargeLoopTime[MAXENTITIES + 1] = { 0.0, ... };
int throwParticle[MAXENTITIES + 1] = { -1, ... };

public void ArchmageBones_OnMapStart_NPC()
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

methodmap ArchmageBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayMeleeHitSound()");
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
	
	
	
	public ArchmageBones(int client, float vecPos[3], float vecAng[3], bool ally, bool buffed)
	{
		ArchmageBones npc = view_as<ArchmageBones>(CClotBody(vecPos, vecAng, "models/zombie_riot/the_bone_zone/basic_bones.mdl", buffed ? BONES_ARCHMAGE_BUFFED_SCALE : BONES_ARCHMAGE_SCALE, buffed ? BONES_ARCHMAGE_HP_BUFFED : BONES_ARCHMAGE_HP, ally, false));
		
		i_NpcInternalId[npc.index] = buffed ? BONEZONE_BUFFED_ARCHMAGE : BONEZONE_ARCHMAGE;
		b_BonesBuffed[npc.index] = buffed;
		
		Archmage_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			TE_SetupParticleEffect(/*"utaunt_auroraglow_purple_parent"*/"utaunt_glowyplayer_purple_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_ARCHMAGE_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		//npc.m_bDoSpawnGesture = true;

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_ARCHMAGE_BUFFED_SKIN : BONES_ARCHMAGE_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_ARCHMAGE_SPEED_BUFFED : BONES_ARCHMAGE_SPEED);
		
		throwState[npc.index] = THROWSTATE_INACTIVE;
		SDKHook(npc.index, SDKHook_Think, ArchmageBones_ClotThink);
		
		//npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

stock void Archmage_GiveCosmetics(ArchmageBones npc, bool buffed)
{
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/workshop/player/items/sniper/hwn2023_sightseer_style1/hwn2023_sightseer_style1.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/hwn2023_sharpshooters_shroud/hwn2023_sharpshooters_shroud.mdl");
		
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		DispatchKeyValue(npc.m_iWearable2, "skin", "1");
	}
	else
	{
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/sniper/headhunters_wrap/headhunters_wrap.mdl");
	}
}

stock int Archmage_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

//All archmage variants will float a short distance above the ground and attempt to keep a distance from survivors.
//Both variants throw fireballs. 
//Skeletal Mages (the non-buffed variant of the archmage) toss smaller red fireballs which deal 75 damage each and do not explode.
//Skeletal Archmages toss large blue fireballs which deal a base damage of 300 and DO explode within a small radius, with up to 66% falloff. Archmages need to charge these fireballs, during which they suffer a 50% movement speed penalty.

public void Archmage_CheckThrow(ArchmageBones npc, int closest)
{
	if (npc.m_flNextMeleeAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest))
	{
		//Don't try to throw a fireball if the target is too far away.
		if (GetVectorDistance(WorldSpaceCenter(npc.index), WorldSpaceCenter(closest)) > ARCHMAGE_HOVER_MAXDIST)
			return;
			
		throwState[npc.index] = THROWSTATE_INTRO;
		npc.m_flAttackHappens = GetGameTime(npc.index) + 0.1;
		npc.m_flAttackHappenswillhappen = true;
		
		//TODO: Play sound
		npc.AddGesture("ACT_MP_PASSTIME_THROW_BEGIN");
		throwParticle[npc.index] = EntIndexToEntRef(Archmage_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_ARCHMAGE_FIREBALL_BUFFED : PARTICLE_ARCHMAGE_FIREBALL, _, "handR"));
	}
}

public void Archmage_EndIntro(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen)
	{
		if (b_BonesBuffed[npc.index])
		{
			npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
			chargeLoopTime[npc.index] = GetGameTime(npc.index) + 1.8;
			throwState[npc.index] = THROWSTATE_CHARGING;
			npc.m_flAttackHappens = GetGameTime(npc.index) + ARCHMAGE_CHARGE_DURATION;
			//TODO: Play sound(?)
		}
		else
		{
			Archmage_Throw(npc, closest);
		}
	}
}

public void Archmage_ChargeUp(ArchmageBones npc, int closest)
{
	if ((GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen) || !IsValidEnemy(npc.index, closest))
	{
		Archmage_Throw(npc, closest);
	}
	else if (GetGameTime(npc.index) >= chargeLoopTime[npc.index])
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
		chargeLoopTime[npc.index] = GetGameTime(npc.index) + 1.8;
	}
}

public void Archmage_Throw(ArchmageBones npc, int closest)
{
	npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
	
	float duration;
	if (IsValidEnemy(npc.index, closest))
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_END");
		duration = 0.46;
		throwThrowTime[npc.index] = GetGameTime(npc.index) + 0.275;
		//TODO: Play sound
	}
	else
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_CANCEL");
		npc.m_flAttackHappenswillhappen = false;
		duration = 0.1;
		Archmage_RemoveParticle(npc.index);
	}
	
	throwState[npc.index] = THROWSTATE_THROWING;
	throwEndTime[npc.index] = GetGameTime(npc.index) + duration;
}

public void Archmage_CheckLaunch(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= throwThrowTime[npc.index] && npc.m_flAttackHappenswillhappen)
	{
		//TODO: Actually throw the fireball, play sound
		npc.m_flAttackHappenswillhappen = false;
		Archmage_RemoveParticle(npc.index);
	}
}

public void Archmage_RemoveParticle(int index)
{
	int particle = EntRefToEntIndex(throwParticle[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

public void Archmage_EndThrow(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= throwEndTime[npc.index])
	{
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_ARCHMAGE_ATTACKINTERVAL_BUFFED : BONES_ARCHMAGE_ATTACKINTERVAL);
		throwState[npc.index] = THROWSTATE_INACTIVE;
	}
}

public int Archmage_GetOptimalTarget(int ent)
{
	float pos[3], otherPos[3];
	pos = WorldSpaceCenter(ent);
	
	float closestDist = 999999999.0;
	int closest = -1;
	
	//TODO: Ask how to make this include NPCs and buildings
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		/*if (Can_I_See_Enemy(ent, i, true) != i)
			continue;*/
			
		CClotBody npc = view_as<CClotBody>(i);
		if (TF2_GetClientTeam(i) != view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum")) && !npc.m_bThisEntityIgnored && IsEntityAlive(i, true))
		{
			otherPos = WorldSpaceCenter(ent);
			
			float dist = GetVectorDistance(pos, otherPos);
			float diff = ARCHMAGE_HOVER_OPTIMALDIST - dist;
			if (diff < 0.0)
				diff *= -1.0;
				
			if (diff < closestDist)
			{
				closest = i;
				closestDist = diff;
			}
		}
	}
	
	return closest;
}

public void Archmage_LookAtPoint(ArchmageBones npc, int closest)
{
	/*int iPitch = npc.LookupPoseParameter("body_pitch");
	int iYaw = npc.LookupPoseParameter("body_yaw");
	if(iPitch < 0 || iYaw < 0)
		return;*/
	
	if (IsValidEnemy(npc.index, closest))
	{
		/*float startLoc[3], targLoc[3], v[3], ang[3];
		startLoc = WorldSpaceCenter(npc.index);
		targLoc = WorldSpaceCenter(closest);
		
		SubtractVectors(startLoc, targLoc, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
					
		float flPitch = npc.GetPoseParameter(iPitch);
		float flYaw = npc.GetPoseParameter(iYaw);
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10000.0));
		npc.SetPoseParameter(iYaw, ApproachAngle(ang[1], flYaw, 10000.0));
		
		flPitch = npc.GetPoseParameter(iPitch);
		flYaw = npc.GetPoseParameter(iYaw);*/
		
		float targLoc[3];
		targLoc = WorldSpaceCenter(closest);
		npc.FaceTowards(targLoc, 15000.0);
	}
	/*else
	{
		npc.SetPoseParameter(iPitch, 0.0);
		npc.SetPoseParameter(iYaw, 0.0);
	}*/
}

//TODO: Mages need to float above the ground and attempt to keep a distance from enemies.
//TODO: Give Archmages custom throw animations instead of using passtime anims, passtime looks out of place and doesn't transition properly with his anims.
public void ArchmageBones_ClotThink(int iNPC)
{
	ArchmageBones npc = view_as<ArchmageBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	
	/*if(npc.m_bDoSpawnGesture)
	{
		//TODO: Archmages need a custom spawn animation so that they don't jarringly transition from walking to floating.
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
	}*/
	
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
		npc.m_iTarget = Archmage_GetOptimalTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int closest = npc.m_iTarget;
	
	//Archmages will always attempt to stay a certain distance away from their target, not too far but not too close.
	//If they are too far/too close, they will move closer/further as needed.
	if(IsValidEnemy(npc.index, closest))
	{
		float pos[3], targPos[3], optimalPos[3]; 
		pos = WorldSpaceCenter(npc.index);
		targPos = WorldSpaceCenter(closest);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
					
		if (flDistanceToTarget < ARCHMAGE_HOVER_MINDIST)
		{
			npc.StartPathing();
			optimalPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, closest);
			NPC_SetGoalVector(npc.index, optimalPos, true);
		}
		else if (flDistanceToTarget > ARCHMAGE_HOVER_MAXDIST)
		{
			npc.StartPathing();
			NPC_SetGoalEntity(npc.index, closest);
		}
		else
		{
			npc.StopPathing();
		}
		
		/*float optimalPos[3], ang[3], testAng[3];
			
		float diff = flDistanceToTarget - ARCHMAGE_HOVER_OPTIMALDIST;
			
		GetAngleToPoint(npc.index, targPos, testAng, ang);
			
		if (diff < 0.0)
		{
			ScaleVector(ang, -1.0);
			diff *= -1.0;
		}
				
		Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, Archmage_WorldOnly);
		TR_GetEndPosition(optimalPos, trace);
		delete trace;
			
		Archmage_ConstrainDistance(pos, optimalPos, diff);
				
		NPC_SetGoalVector(npc.index, optimalPos);*/
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	switch(throwState[npc.index])
	{
		case THROWSTATE_INACTIVE:
		{
			Archmage_CheckThrow(npc, closest);
		}
		case THROWSTATE_INTRO:
		{
			Archmage_EndIntro(npc, closest);
		}
		case THROWSTATE_CHARGING:
		{
			Archmage_ChargeUp(npc, closest);
		}
		case THROWSTATE_THROWING:
		{
			Archmage_CheckLaunch(npc, closest);
			Archmage_EndThrow(npc, closest);
		}
	}
	
	Archmage_LookAtPoint(npc, closest);
	
	npc.PlayIdleSound();
}

stock float[] Archmage_ConstrainDistance(float startPos[3], float endPos[3], float distance)
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

public bool Archmage_WorldOnly(any entity, any contentsMask)
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

public Action ArchmageBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	ArchmageBones npc = view_as<ArchmageBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void ArchmageBones_NPCDeath(int entity)
{
	ArchmageBones npc = view_as<ArchmageBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, ArchmageBones_ClotThink);
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


