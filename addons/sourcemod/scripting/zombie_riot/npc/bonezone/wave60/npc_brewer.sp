#pragma semicolon 1
#pragma newdecls required

#define BONES_ALCHEMIST_HP			"15000"
#define BONES_ALCHEMIST_SKIN		"1"
#define BONES_ALCHEMIST_SCALE		"1.0"

static float BONES_ALCHEMIST_SPEED = 440.0;

//The Alchemist is a ranged support unit who stays at a distance and tosses potions at allies.
//These bottles shatter on contact, providing a small amount of healing in a radius with a chance to permanently buff those who are healed.
//If no allies are alive, they smash their bottle on their head, healing themselves, before immediately sprinting towards enemies and rapidly slashing them with the broken bottle.
static float ALCHEMIST_THROW_RANGE = 600.0;				//Range at which the Alchemist will begin throwing potions at targets.
static float ALCHEMIST_THROW_COOLDOWN = 1.5;			//Cooldown between throws.
static float ALCHEMIST_THROW_VELOCITY = 2400.0;			//Bottle throw velocity.
static float ALCHEMIST_STOP_RANGE = 400.0;				//Distance from its target at which the Alchemist will stop moving.
static float ALCHEMIST_RADIUS = 240.0;					//Ale effect radius.
static float ALCHEMIST_HEAL_PERCENT = 0.15;				//percentage of max health to heal allies for.
static float ALCHEMIST_HEAL_MINIMUM = 500.0;			//Minimum healing provided to allies who are within the potions's radius.
static float ALCHEMIST_HEAL_BUFF_CHANCE = 0.15;			//Chance for allies who are healed by thrown bottles to be instantly converted to their buffed form, permanently.
static float ALCHEMIST_SMASH_HEALS = 15000.0;			//Amount the Alchemist should heal itself when it enters its melee phase.
static float ALCHEMIST_SPEED_NO_ALLIES = 560.0;			//Movement speed when no non-medic allies are alive.
static float ALCHEMIST_MELEE_DAMAGE = 90.0;				//Melee damage.
static float ALCHEMIST_MELEE_INTERVAL = 0.05;			//Cooldown between melee attacks.
static float ALCHEMIST_MELEE_START_RANGE = 80.0;		//Distance at which the Alchemist will attempt to attack its target if it can.

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
	")weapons/bottle_broken_hit_flesh1.wav",
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

static bool b_AlchemistGoneBerserk[2049] = { false, ... };
static bool b_AlchemistBerserkSequence[2049] = { false, ... };
static bool b_AlchemistThrowing[2049] = { false, ... };
static float f_AlchemistCanGoBerserkAt[2049] = { 0.0, ... };

#define PARTICLE_ALCHEMIST_BOTTLE_SMASH	"spell_pumpkin_mirv_goop_blue"
#define PARTICLE_ALCHEMIST_BOTTLE_TRAIL	"peejar_trail_blu"
#define PARTICLE_ALCHEMIST_HEAL			"spell_overheal_blue"

#define SND_ALCHEMIST_SWING				")weapons/machete_swing.wav"
#define SND_ALCHEMIST_BOTTLE_SMASH		")weapons/bottle_break.wav"
#define SND_ALCHEMIST_BOTTLE_SMASH_IMMINENT	")vo/halloween_boss/knight_alert02.mp3"
#define SND_ALCHEMIST_BOTTLE_SMASH_OW	")vo/halloween_boss/knight_pain03.mp3"
#define SND_ALCHEMIST_HEAL				")misc/halloween/spell_overheal.wav"

#define MODEL_ALCHEMIST_BOTTLE			"models/props_halloween/flask_erlenmeyer.mdl"

public void AlchemistBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SND_ALCHEMIST_BOTTLE_SMASH);
	PrecacheSound(SND_ALCHEMIST_BOTTLE_SMASH_IMMINENT);
	PrecacheSound(SND_ALCHEMIST_BOTTLE_SMASH_OW);
	PrecacheSound(SND_ALCHEMIST_SWING);
	PrecacheSound(SND_ALCHEMIST_HEAL);
	PrecacheModel(MODEL_ALCHEMIST_BOTTLE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bone Brewer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alchemist");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Alchemist;
	NPC_Add(data);
}

static any Summon_Alchemist(int client, float vecPos[3], float vecAng[3], int ally)
{
	return AlchemistBones(client, vecPos, vecAng, ally);
}

methodmap AlchemistBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CAlchemistBones::PlayMeleeHitSound()");
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
	
	public AlchemistBones(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		AlchemistBones npc;
		if (client > 0 && IsValidClient(client))
			npc = view_as<AlchemistBones>(BarrackBody(client, vecPos, vecAng, BONES_ALCHEMIST_HP, BONEZONE_MODEL, _, BONES_ALCHEMIST_SCALE));
		else
			npc = view_as<AlchemistBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, BONES_ALCHEMIST_SCALE, BONES_ALCHEMIST_HP, ally, false));
		
		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_ALCHEMIST_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_ALCHEMIST_HP);

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Bone Brewer");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Bone Brewer");

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_AlchemistGoneBerserk[npc.index] = false;
		b_AlchemistBerserkSequence[npc.index] = false;
		f_AlchemistCanGoBerserkAt[npc.index] = GetGameTime() + 1.0;

		func_NPCDeath[npc.index] = view_as<Function>(AlchemistBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AlchemistBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AlchemistBones_ClotThink);

		Is_a_Medic[npc.index] = true;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.m_bisWalking = false;

		int iActivity = npc.LookupActivity("ACT_ALCHEMIST_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", BONES_ALCHEMIST_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = BONES_ALCHEMIST_SPEED;
		
		npc.StartPathing();

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec23_dapper_dickens/dec23_dapper_dickens_sniper.mdl");
		
		return npc;
	}
}

public int Alchemist_GetTarget(AlchemistBones npc)
{
	int closest = -1;

	if (b_AlchemistGoneBerserk[npc.index])
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
		if (closest <= 0 && GetGameTime() >= f_AlchemistCanGoBerserkAt[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_ALCHEMIST_BREAK_BOTTLE");
			if(iActivity > 0) npc.StartActivity(iActivity);

			closest = GetClosestTarget(npc.index);
			b_AlchemistGoneBerserk[npc.index] = true;
			b_AlchemistBerserkSequence[npc.index] = true;
			npc.m_flSpeed = ALCHEMIST_SPEED_NO_ALLIES;
			npc.StopPathing();

			EmitSoundToAll(SND_ALCHEMIST_BOTTLE_SMASH_IMMINENT, npc.index, _, 120);

			DataPack pack = new DataPack();
			RequestFrame(Alchemist_BerserkSequence, pack);
			WritePackCell(pack, EntIndexToEntRef(npc.index));
			WritePackFloat(pack, GetGameTime(npc.index) + 0.6);
			WritePackFloat(pack, GetGameTime(npc.index) + 0.8);
			WritePackFloat(pack, GetGameTime(npc.index) + 1.25);
			
		}
	}
	
	return closest;
}

public void Alchemist_BerserkSequence(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float swingTime = ReadPackFloat(pack);
	float throwTime = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	delete pack;

	if (!IsEntityAlive(ent))
		return;

	AlchemistBones npc = view_as<AlchemistBones>(ent);
	float gt = GetGameTime(npc.index);

	if (gt >= swingTime)
	{
		EmitSoundToAll(SND_ALCHEMIST_SWING, npc.index, _, 120, _, _, GetRandomInt(80, 110));
		swingTime = 9999999.0;
	}

	if (gt >= throwTime)
	{
		float pos[3], ang[3];
		GetAttachment(npc.index, "head", pos, ang);

		ParticleEffectAt(pos, PARTICLE_ALCHEMIST_BOTTLE_SMASH, 2.0);
		EmitSoundToAll(SND_ALCHEMIST_BOTTLE_SMASH, npc.index, _, 120);
		EmitSoundToAll(SND_ALCHEMIST_BOTTLE_SMASH, npc.index, _, 120);
		EmitSoundToAll(SND_ALCHEMIST_BOTTLE_SMASH_OW, npc.index, _, 120);

		if (GetEntProp(npc.index, Prop_Data, "m_iHealth") < GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + ALCHEMIST_SMASH_HEALS);
			if (GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			}
		}

		throwTime = 9999999.0;
	}

	if (gt >= endTime)
	{
		int iActivity = npc.LookupActivity("ACT_ALCHEMIST_RUN_BROKEN_BOTTLE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iTarget = Alchemist_GetTarget(npc);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
		b_AlchemistBerserkSequence[npc.index] = false;
		return;
	}

	pack = new DataPack();
	RequestFrame(Alchemist_BerserkSequence, pack);
	WritePackCell(pack, EntIndexToEntRef(npc.index));
	WritePackFloat(pack, swingTime);
	WritePackFloat(pack, throwTime);
	WritePackFloat(pack, endTime);
}

//TODO 
//Rewrite
public void AlchemistBones_ClotThink(int iNPC)
{
	AlchemistBones npc = view_as<AlchemistBones>(iNPC);
	
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

	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = Alchemist_GetTarget(npc);

		if (IsValidAlly(npc.index, npc.m_iTarget))
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.2;
		else
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;

		if (!b_AlchemistBerserkSequence[npc.index] && !b_AlchemistThrowing[npc.index])
			npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEntity(closest) && !b_AlchemistBerserkSequence[npc.index])
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother);

		if (!b_AlchemistGoneBerserk[npc.index])
		{
			if (!b_AlchemistThrowing[npc.index])
			{
				if (flDistanceToTarget <= ALCHEMIST_STOP_RANGE && Can_I_See_Ally(npc.index, npc.m_iTarget))
				{
					npc.StopPathing();
				}
				else
				{
					npc.SetGoalEntity(closest);
					npc.StartPathing();
				}

				if (flDistanceToTarget <= ALCHEMIST_THROW_RANGE && npc.m_flNextRangedAttack <= GetGameTime(npc.index) && Can_I_See_Ally(npc.index, npc.m_iTarget))
				{
					b_AlchemistThrowing[npc.index] = true;

					npc.FaceTowards(vecTarget, 15000.0);
					int iActivity = npc.LookupActivity("ACT_ALCHEMIST_THROW");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.StopPathing();

					DataPack pack = new DataPack();
					RequestFrame(Alchemist_ThrowBottle, pack);
					WritePackCell(pack, EntIndexToEntRef(npc.index));
					WritePackFloat(pack, GetGameTime(npc.index) + 0.3);
					WritePackFloat(pack, GetGameTime(npc.index) + 0.5);
					WritePackFloat(pack, GetGameTime(npc.index) + 1.0);
				}
			}
		}	
		else
		{
			if((flDistanceToTarget * flDistanceToTarget) < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(closest);
			}

			if (flDistanceToTarget <= ALCHEMIST_MELEE_START_RANGE && npc.m_flNextMeleeAttack <= GetGameTime(npc.index) && !npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_ALCHEMIST_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappenswillhappen = true;

				DataPack pack = new DataPack();
				RequestFrame(Alchemist_MeleeLogic, pack);
				WritePackCell(pack, EntIndexToEntRef(npc.index));
				WritePackFloat(pack, GetGameTime(npc.index) + 0.16);
				WritePackFloat(pack, GetGameTime(npc.index) + 0.25);
				WritePackFloat(pack, GetGameTime(npc.index) + 0.4);
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = Alchemist_GetTarget(npc);
	}

	npc.PlayIdleSound();
}

public void Alchemist_MeleeLogic(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float swingTime = ReadPackFloat(pack);
	float hitTime = ReadPackFloat(pack);
	delete pack;

	if (!IsValidEntity(ent))
		return;

	AlchemistBones npc = view_as<AlchemistBones>(ent);
	float gt = GetGameTime(npc.index);

	if (gt >= swingTime)
	{
		EmitSoundToAll(SND_ALCHEMIST_SWING, npc.index, _, 120, _, _, GetRandomInt(80, 110));
		swingTime = 9999999.0;
	}

	if (gt >= hitTime)
	{
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + ALCHEMIST_MELEE_INTERVAL;

		if (IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);

			Handle swingTrace;
			npc.FaceTowards(vecTarget, 20000.0);

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
				int target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(target > 0) 
				{
					if(target <= MaxClients)
						SDKHooks_TakeDamage(target, npc.index, npc.index, ALCHEMIST_MELEE_DAMAGE, DMG_CLUB, -1, _, vecHit);
					else
						SDKHooks_TakeDamage(target, npc.index, npc.index, ALCHEMIST_MELEE_DAMAGE, DMG_CLUB, -1, _, vecHit);					

					// Hit sound
					npc.PlayMeleeHitSound();
				}
			}

			delete swingTrace;
		}

		return;
	}

	pack = new DataPack();
	RequestFrame(Alchemist_MeleeLogic, pack);
	WritePackCell(pack, EntIndexToEntRef(npc.index));
	WritePackFloat(pack, swingTime);
	WritePackFloat(pack, hitTime);
}

public void Alchemist_ThrowBottle(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float swingTime = ReadPackFloat(pack);
	float throwTime = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	delete pack;

	if (!IsValidEntity(ent))
		return;

	if (b_AlchemistGoneBerserk[ent])
		return;

	AlchemistBones npc = view_as<AlchemistBones>(ent);
	float gt = GetGameTime(npc.index);

	if (gt >= swingTime)
	{
		EmitSoundToAll(SND_ALCHEMIST_SWING, npc.index, _, 120, _, _, GetRandomInt(80, 110));
		swingTime = 9999999.0;
	}

	if (gt >= throwTime)
	{
		float pos[3], ang[3], vPredictedPos[3], SpeedReturn[3];
		GetAttachment(npc.index, "handL", pos, ang);
		PredictSubjectPosition(npc, npc.m_iTarget, 1.0, _, vPredictedPos);

		int bottle = npc.FireRocket(vPredictedPos, 0.0, ALCHEMIST_THROW_VELOCITY);
		SetEntityGravity(bottle, 1.0); 	
		ArcToLocationViaSpeedProjectile(pos, vPredictedPos, SpeedReturn, 1.0, 1.0);
		SetEntityMoveType(bottle, MOVETYPE_FLYGRAVITY);
		TeleportEntity(bottle, NULL_VECTOR, NULL_VECTOR, SpeedReturn);

		SetEntityModel(bottle, MODEL_ALCHEMIST_BOTTLE);
		ParticleEffectAt_Parent(pos, PARTICLE_ALCHEMIST_BOTTLE_TRAIL, bottle);
		g_DHookRocketExplode.HookEntity(Hook_Pre, bottle, Alchemist_BottleCollide);

		for (int i = 0; i < 3; i++)
		{
			ang[i] = GetRandomFloat(0.0, 360.0);
		}

		TeleportEntity(bottle, _, ang);

		throwTime = 9999999.0;
	}
	else if (IsValidAlly(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		npc.FaceTowards(vecTarget, 400.0);
	}

	if (gt >= endTime)
	{
		int iActivity = npc.LookupActivity("ACT_ALCHEMIST_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.StartPathing();
		b_AlchemistThrowing[npc.index] = false;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + ALCHEMIST_THROW_COOLDOWN;
		return;
	}

	pack = new DataPack();
	RequestFrame(Alchemist_ThrowBottle, pack);
	WritePackCell(pack, EntIndexToEntRef(npc.index));
	WritePackFloat(pack, swingTime);
	WritePackFloat(pack, throwTime);
	WritePackFloat(pack, endTime);
}

public MRESReturn Alchemist_BottleCollide(int entity)
{
	float position[3];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_ALCHEMIST_BOTTLE_SMASH, 1.0);
	ParticleEffectAt(position, PARTICLE_ALCHEMIST_HEAL, 1.0);
	EmitSoundToAll(SND_ALCHEMIST_BOTTLE_SMASH, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	for (int i = 1; i < MAXENTITIES; i++)
	{
		if (!IsValidEntity(i) || i_IsABuilding[i] || i == owner)
			continue;
			
		if (!HasEntProp(i, Prop_Send, "m_iTeamNum"))
			continue;
			
		CClotBody healTarget = view_as<CClotBody>(i);		
		if (healTarget.BoneZone_IsASaint())
			continue;
			
		float healPos[3];
		WorldSpaceCenter(i, healPos);
		if (GetTeam(entity) == GetTeam(i) && GetVectorDistance(position, healPos) <= ALCHEMIST_RADIUS)
		{
			float maxHP = float(GetEntProp(healTarget.index, Prop_Data, "m_iHealth"));
			int HealingAmount = RoundFloat(maxHP * ALCHEMIST_HEAL_PERCENT);
			if (HealingAmount < RoundFloat(ALCHEMIST_HEAL_MINIMUM))
				HealingAmount = RoundFloat(ALCHEMIST_HEAL_MINIMUM);
				
			if (GetEntProp(healTarget.index, Prop_Data, "m_iHealth") < GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(healTarget.index, Prop_Data, "m_iHealth", GetEntProp(healTarget.index, Prop_Data, "m_iHealth") + HealingAmount);
				if (GetEntProp(healTarget.index, Prop_Data, "m_iHealth") >= GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(healTarget.index, Prop_Data, "m_iHealth", GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"));
				}
			}
				
			if (GetRandomFloat() <= ALCHEMIST_HEAL_BUFF_CHANCE)
			{
				healTarget.BoneZone_SetBuffedState(true);
				healTarget.m_bBoneZoneNaturallyBuffed = true;
			}

			EmitSoundToAll(SND_ALCHEMIST_HEAL, i, _, _, _, 0.8, GetRandomInt(80, 110));
		}
	}
	
	RemoveEntity(entity);

	return MRES_Supercede; //DONT.
}

public Action AlchemistBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	AlchemistBones npc = view_as<AlchemistBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void AlchemistBones_NPCDeath(int entity)
{
	AlchemistBones npc = view_as<AlchemistBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	npc.RemoveAllWearables();
//	AcceptEntityInput(npc.index, "KillHierarchy");
}