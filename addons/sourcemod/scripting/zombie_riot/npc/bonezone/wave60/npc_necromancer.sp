#pragma semicolon 1
#pragma newdecls required

static float BONES_NECROMANCER_SPEED = 220.0;
static float BONES_NECROMANCER_SPEED_BUFFED = 260.0;
static float NECROMANCER_NATURAL_BUFF_CHANCE = 0.0;			//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float NECROMANCER_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float NECROMANCER_NATURAL_BUFF_LEVEL = 100.0;		//The average level at which level_modifier reaches its max.

#define BONES_NECROMANCER_HP				"5000"
#define BONES_NECROMANCER_HP_BUFFED			"25000"

static float BONES_NECROMANCER_ATTACKINTERVAL = 0.0;
static float BONES_NECROMANCER_ATTACKINTERVAL_BUFFED = 0.0;

static float Necromancer_Hover_MinDist = 300.0;
static float Necromancer_Hover_MaxDist = 600.0;

static float Necromancer_AttackRange = 800.0;
static float Necromancer_AttackRange_Buffed = 1000.0;

static float BOLT_RADIUS = 175.0;
static float BOLT_RADIUS_BUFFED = 250.0;

static float BOLT_DELAY = 2.0;
static float BOLT_DELAY_BUFFED = 2.0;

static float BOLT_DAMAGE = 60.0;
static float BOLT_DAMAGE_BUFFED = 120.0;

static float BOLT_FALLOFF_MULTIHIT = 0.66;
static float BOLT_FALLOFF_MULTIHIT_BUFFED = 0.85;

static float BOLT_FALLOFF_RADIUS = 0.66;
static float BOLT_FALLOFF_RADIUS_BUFFED = 0.66;

static float BOLT_DAMAGE_ENTITYMULT = 3.0;
static float BOLT_DAMAGE_ENTITYMULT_BUFFED = 4.0;

static float NECROMANCER_MAX_SUMMONS = 4.0;
static float NECROMANCER_MAX_SUMMONS_BUFFED = 8.0;

#define BONES_NECROMANCER_SCALE					"1.0"
#define BONES_NECROMANCER_BUFFED_SCALE			"1.2"

#define BONES_NECROMANCER_SKIN						"0"
#define BONES_NECROMANCER_BUFFED_SKIN				"1"

#define BONES_NECROMANCER_BUFFPARTICLE			"utaunt_cremation_purple_parent"

#define PARTICLE_NECROMANCER_CAST_BUFFED		"raygun_projectile_blue"
#define PARTICLE_NECROMANCER_CAST				"raygun_projectile_red"

#define SOUND_BOLT_IMPACT		")misc/halloween/spell_spawn_boss.wav"
#define SOUND_BOLT_CAST			")misc/halloween/spell_mirv_cast.wav"

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

enum Necromancer_CastState
{
	NECRO_CASTSTATE_INACTIVE,
	NECRO_CASTSTATE_INTRO,
	NECRO_CASTSTATE_CASTING
};

Necromancer_CastState NecroCastState[MAXENTITIES] = { NECRO_CASTSTATE_INACTIVE };

static int cast_Target[MAXENTITIES];
static int castParticle[MAXENTITIES];
//static int NecroAnim[MAXENTITIES];

static float Necro_TargetLoc[MAXENTITIES][3];
static float castTime[MAXENTITIES];
static float currentRadius[MAXENTITIES];
static float currentDelay[MAXENTITIES];

public void NecromancerBones_OnMapStart_NPC()
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

	PrecacheSound(SOUND_BOLT_IMPACT);
	PrecacheSound(SOUND_BOLT_CAST);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Novice Necromancer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_necromancer");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Bringer of Bones");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_necromancer_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return NecromancerBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return NecromancerBones(client, vecPos, vecAng, ally, true);
}

methodmap NecromancerBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CNecromancerBones::PlayMeleeHitSound()");
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
	
	
	
	public NecromancerBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = NECROMANCER_NATURAL_BUFF_CHANCE;
			if (NECROMANCER_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / NECROMANCER_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * NECROMANCER_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		NecromancerBones npc = view_as<NecromancerBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_NECROMANCER_BUFFED_SCALE : BONES_NECROMANCER_SCALE, buffed && !randomlyBuffed ? BONES_NECROMANCER_HP_BUFFED : BONES_NECROMANCER_HP, ally, false, false, true));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_NECROMANCER_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_NECROMANCER_HP_BUFFED);
		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_NECROMANCER_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_NECROMANCER_BUFFED_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_NECROMANCER_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_NECROMANCER_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Bringer of Bones");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Novice Necromancer");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(NecromancerBones_SetBuffed);
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(NecromancerBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(NecromancerBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(NecromancerBones_ClotThink);
		
		Necromancer_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_NECROMANCER_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
			npc.BoneZone_SetExtremeDangerState(true);
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_ARCHMAGE_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_NECROMANCER_BUFFED_SKIN : BONES_NECROMANCER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_NECROMANCER_SPEED_BUFFED : BONES_NECROMANCER_SPEED);
		
		throwState[npc.index] = THROWSTATE_INACTIVE;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void NecromancerBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;

		//Apply buffed stats:
		Necromancer_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_NECROMANCER_BUFFED_SKIN);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_NECROMANCER_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();

		npc.BoneZone_SetExtremeDangerState(true);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;

		//Remove buffed stats:
		Necromancer_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_NECROMANCER_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_NECROMANCER_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();

		npc.BoneZone_SetExtremeDangerState(false);
	}
}

stock void Necromancer_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("spine3", "models/workshop/player/items/soldier/hwn2023_warlocks_warcloak/hwn2023_warlocks_warcloak.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2019_horrible_horns/hwn2019_horrible_horns_sniper.mdl");
	}
	else
	{
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/demo/demo_bonehat.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
	}
}

stock int Necromancer_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void Necromancer_SeekTarget(NecromancerBones npc, int closest)
{
	if (npc.m_flNextMeleeAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index))
	{
		float userLoc[3], targLoc[3];
		WorldSpaceCenter(npc.index, userLoc);
		WorldSpaceCenter(closest, targLoc);

		if (GetVectorDistance(userLoc, targLoc) > (b_BonesBuffed[npc.index] ? Necromancer_AttackRange_Buffed : Necromancer_AttackRange))
			return;
		
		if (!Can_I_See_Enemy_Only(npc.index, closest))
			return;

		NecroCastState[npc.index] = NECRO_CASTSTATE_INTRO;
		cast_Target[npc.index] = EntIndexToEntRef(closest);
		npc.m_flAttackHappens = GetGameTime(npc.index) + 0.1;
		npc.m_flAttackHappenswillhappen = true;
		
		npc.AddGesture("ACT_MP_PASSTIME_THROW_END");
		
		castParticle[npc.index] = EntIndexToEntRef(Necromancer_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_NECROMANCER_CAST_BUFFED : PARTICLE_NECROMANCER_CAST, _, "handR"));
	}
}

public void Necro_DeleteCastParticle(int index)
{
	int part = EntRefToEntIndex(castParticle[index]);
	if (IsValidEntity(part))
		RemoveEntity(part);
}

public void Necromancer_WaitForCast(NecromancerBones npc, int closest)
{
	if (GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen)
	{
		if (IsValidEntity(closest))
		{
			GetAbsOrigin(closest, Necro_TargetLoc[npc.index]);
			
			float startLoc[3], ang[3], endLoc[3];
			WorldSpaceCenter(npc.index, startLoc);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			startLoc[2] += 20.0;
			GetPointFromAngles(startLoc, ang, 20.0, endLoc, Priest_IgnoreAll, MASK_SHOT);
			
			SpawnBeam_Vectors(endLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
			SpawnBeam_Vectors(endLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
			SpawnBeam_Vectors(endLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 20.0);
			spawnRing_Vectors(Necro_TargetLoc[npc.index], 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 20, 255, 120, 120, 1, 0.33, 8.0, 0.0, 1, (b_BonesBuffed[npc.index] ? BOLT_RADIUS_BUFFED : BOLT_RADIUS) * 2.0);
			
			EmitSoundToAll(SOUND_BOLT_CAST, 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 30, _, NORMAL_ZOMBIE_VOLUME - 0.1, GetRandomInt(80, 110), -1, endLoc);
			
			castTime[npc.index] = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BOLT_DELAY_BUFFED : BOLT_DELAY);
			NecroCastState[npc.index] = NECRO_CASTSTATE_CASTING;
			currentRadius[npc.index] = (b_BonesBuffed[npc.index] ? BOLT_RADIUS_BUFFED : BOLT_RADIUS);
			currentDelay[npc.index] = (b_BonesBuffed[npc.index] ? BOLT_DELAY_BUFFED : BOLT_DELAY);
		}
		else
		{
			npc.m_flAttackHappenswillhappen = false;
			NecroCastState[npc.index] = NECRO_CASTSTATE_INACTIVE;
		}
		
		Necro_DeleteCastParticle(npc.index);
	}
}

public void Necromancer_WaitForBolt(NecromancerBones npc)
{
	if (NpcStats_IsEnemySilenced(npc.index))	//We have been silenced, cancel the bolt.
	{
		NecroCastState[npc.index] = NECRO_CASTSTATE_INACTIVE;
		npc.m_flAttackHappenswillhappen = false;
		npc.RemoveGesture("ACT_MP_PASSTIME_THROW_END");
	}
	else if (GetGameTime(npc.index) < castTime[npc.index])	//The bolt is not ready yet, draw a ring indicator.
	{
		float timeUntil = castTime[npc.index] - GetGameTime(npc.index);
		float multiplier = timeUntil / currentDelay[npc.index];
		
		spawnRing_Vectors(Necro_TargetLoc[npc.index], currentRadius[npc.index] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 20, 255, 120, 60, 1, 0.33, 8.0, 0.0, 1);
		spawnRing_Vectors(Necro_TargetLoc[npc.index], currentRadius[npc.index] * multiplier * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 20, 255, 120, 255, 1, 0.1, 8.0, 0.0, 1);
	}
	else	//The bolt is ready, cast it and summon skeletons.
	{
		float skyLoc[3];
		skyLoc = Necro_TargetLoc[npc.index];
		skyLoc[2] += 9999.0;
		
		SpawnBeam_Vectors(skyLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(skyLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(skyLoc, Necro_TargetLoc[npc.index], 0.33, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 20.0);
		ParticleEffectAt(Necro_TargetLoc[npc.index], "merasmus_dazed_explosion", 2.0);
		
		bool isBlue = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);	
		Explode_Logic_Custom((b_BonesBuffed[npc.index] ? BOLT_DAMAGE_BUFFED : BOLT_DAMAGE), npc.index, npc.index, npc.index, Necro_TargetLoc[npc.index], currentRadius[npc.index], (b_BonesBuffed[npc.index] ? BOLT_FALLOFF_MULTIHIT_BUFFED : BOLT_FALLOFF_MULTIHIT), (b_BonesBuffed[npc.index] ? BOLT_FALLOFF_RADIUS_BUFFED : BOLT_FALLOFF_RADIUS), isBlue, _, false, (b_BonesBuffed[npc.index] ? BOLT_DAMAGE_ENTITYMULT_BUFFED : BOLT_DAMAGE_ENTITYMULT));
		
		EmitSoundToAll(SOUND_BOLT_IMPACT, 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 20, _, NORMAL_ZOMBIE_VOLUME - 0.1, GetRandomInt(80, 110), -1, Necro_TargetLoc[npc.index]);
		
		Necromancer_Summon(npc);
		if (b_BonesBuffed[npc.index])
			Necromancer_Summon(npc);
		
		NecroCastState[npc.index] = NECRO_CASTSTATE_INACTIVE;
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_NECROMANCER_ATTACKINTERVAL_BUFFED : BONES_NECROMANCER_ATTACKINTERVAL);
		npc.m_flAttackHappenswillhappen = false;
	}
}


public void Necromancer_Summon(NecromancerBones npc)
{
	if (npc.m_flBoneZoneNumSummons < (b_BonesBuffed[npc.index] ? NECROMANCER_MAX_SUMMONS_BUFFED : NECROMANCER_MAX_SUMMONS))
	{
		any entity = -1;
		float randAng[3];
		randAng[1] = GetRandomFloat(0.0, 360.0);
		
		//TODO: MAYBE let necromancers summon fodder skeletons from *all* skeleton types? Would require some max health tomfoolery though.
		entity = PeasantBones(npc.index, Necro_TargetLoc[npc.index], randAng, GetTeam(npc.index), b_BonesBuffed[npc.index]);
		Necromancer_AssignSummonStats(entity, npc, 1.0);

		//The following switch statement can be uncommented and expanded to allow Necromancers to summon more types of NPCs.
		//For obvious reasons, you should NEVER allow Necromancers to summon more Necromancers.
		//I also recommend you don't allow them to summon Skeletal Saints or Profaned Priests unless the necromancer is already buffed. Nothing will break if you do, it would just be too strong.
		//Aside from that, any NPC is fair game.
		
		/*switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				entity = BasicBones(npc.index, Necro_TargetLoc[npc.index], randAng, GetTeam(npc.index), b_BonesBuffed[npc.index]);
				Necromancer_AssignSummonStats(entity, npc, 1.0);
			}
			case 2:
			{
				entity = BeefyBones(npc.index, Necro_TargetLoc[npc.index], randAng, GetTeam(npc.index), b_BonesBuffed[npc.index]);
				Necromancer_AssignSummonStats(entity, npc, 1.0);
			}
			case 3:
			{
				entity = BrittleBones(npc.index, Necro_TargetLoc[npc.index], randAng, GetTeam(npc.index), b_BonesBuffed[npc.index]);
				Necromancer_AssignSummonStats(entity, npc, 0.5);
					
				randAng[1] = GetRandomFloat(0.0, 360.0);
					
				entity = BrittleBones(npc.index, Necro_TargetLoc[npc.index], randAng, GetTeam(npc.index), b_BonesBuffed[npc.index]);
				Necromancer_AssignSummonStats(entity, npc, 0.5);
			}
		}*/
	}
}

public void Necromancer_AssignSummonStats(int entity, NecromancerBones npc, float value)
{
	CClotBody summoned = view_as<CClotBody>(entity);
	summoned.m_iBoneZoneSummoner = npc.index;
	summoned.m_flBoneZoneSummonValue = value;
	npc.m_flBoneZoneNumSummons += value;
	NpcAddedToZombiesLeftCurrently(entity, true);
}

public void NecromancerBones_ClotThink(int iNPC)
{
	NecromancerBones npc = view_as<NecromancerBones>(iNPC);
	
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
			if (flDistanceToTarget < Necromancer_Hover_MinDist)
			{
				npc.StartPathing();
				BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);
				npc.SetGoalVector(optimalPos, true);
			}
			else if (flDistanceToTarget > Necromancer_Hover_MaxDist)
			{
				npc.StartPathing();
				npc.SetGoalEntity(closest);
			}
			else
			{
				npc.StopPathing();
			}
		}
		
		if (NecroCastState[npc.index] != NECRO_CASTSTATE_INACTIVE)
			npc.FaceTowards(targPos, 15000.0);
	}
	else
	{
		npc.StopPathing();
			
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if (NecroCastState[npc.index] == NECRO_CASTSTATE_INTRO)
		npc.m_flSpeed = 0.0;
	else
		npc.m_flSpeed = (b_BonesBuffed[npc.index] ? BONES_NECROMANCER_SPEED_BUFFED : BONES_NECROMANCER_SPEED);
	
	switch(NecroCastState[npc.index])
	{
		case NECRO_CASTSTATE_INACTIVE:
		{
			Necromancer_SeekTarget(npc, closest);
		}
		case NECRO_CASTSTATE_INTRO:
		{
			Necromancer_WaitForCast(npc, EntRefToEntIndex(cast_Target[npc.index]));
		}
		case NECRO_CASTSTATE_CASTING:
		{
			Necromancer_WaitForBolt(npc);
		}
	}
	
	npc.PlayIdleSound();
}

public Action NecromancerBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	NecromancerBones npc = view_as<NecromancerBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void NecromancerBones_NPCDeath(int entity)
{
	NecromancerBones npc = view_as<NecromancerBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Necro_DeleteCastParticle(entity);
		
	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


