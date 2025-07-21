#pragma semicolon 1
#pragma newdecls required

#define BONES_MOLOTOV_HP			"5000"
#define BONES_MOLOTOV_SKIN		"1"
#define BONES_MOLOTOV_SCALE		"1.0"

static float BONES_MOLOTOV_SPEED = 280.0;

//Mr. Molotov is the ranged explosive unit of the Mafia era. He tosses molotovs, which explode and deal AOE damage. Survivors are ignited.
static float MOLOTOV_THROW_RANGE = 400.0;				//Range at which Mr. Molotov will begin throwing molotovs at targets.
static float MOLOTOV_THROW_COOLDOWN = 2.0;				//Cooldown between throws.
static float MOLOTOV_THROW_VELOCITY = 1200.0;			//Bottle throw velocity.
static float MOLOTOV_STOP_RANGE = 300.0;				//Distance from its target at which Mr. Molotov will stop moving.
static float MOLOTOV_TOO_CLOSE = 150.0;					//Distance from the nearest enemy at which Mr. Molotov will begin to run away.
static float MOLOTOV_RADIUS = 100.0;					//Molotov blast radius.
static float MOLOTOV_DAMAGE = 90.0;						//Molotov damage.
static float MOLOTOV_ENTITYMULT = 10.0;					//Amount to multiply damage dealt to entities.
static float MOLOTOV_FALLOFF_RADIUS = 0.8;				//Range-based falloff multiplier.
static float MOLOTOV_FALLOFF_MULTIHIT = 0.9;			//Amount to multiply blast damage per target hit.
static float MOLOTOV_GRAVITY = 1.0;						//Molotov projectile gravity.
static float MOLOTOV_PREDICT_RANGE = 300.0;				//Range in which the projectile predicts its target's location.

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

static bool b_MolotovThrowing[2049] = { false, ... };

#define PARTICLE_MOLOTOV_BOTTLE_SMASH		"spell_fireball_tendril_parent_red"
#define PARTICLE_MOLOTOV_BOTTLE_TRAIL		"fuse_sparks"

#define SND_MOLOTOV_SWING					")weapons/machete_swing.wav"
#define SND_MOLOTOV_BOTTLE_SMASH			")weapons/bottle_break.wav"
#define SND_MOLOTOV_BOTTLE_SMASH_2			")misc/halloween/spell_fireball_impact.wav"

#define MODEL_MOLOTOV_BOTTLE				"models/weapons/c_models/c_bottle/c_bottle.mdl"

public void MolotovBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SND_MOLOTOV_BOTTLE_SMASH);
	PrecacheSound(SND_MOLOTOV_SWING);
	PrecacheModel(MODEL_MOLOTOV_BOTTLE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mr. Molotov");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_molotov");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Molotov;
	NPC_Add(data);
}

static any Summon_Molotov(int client, float vecPos[3], float vecAng[3], int ally)
{
	return MolotovBones(client, vecPos, vecAng, ally);
}

methodmap MolotovBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CMolotovBones::PlayMeleeHitSound()");
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
	
	public MolotovBones(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		MolotovBones npc = view_as<MolotovBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, BONES_MOLOTOV_SCALE, BONES_MOLOTOV_HP, ally, false));
		
		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_MOLOTOV_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_MOLOTOV_HP);

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Mr. Molotov");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Mr. Molotov");

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = true;

		func_NPCDeath[npc.index] = view_as<Function>(MolotovBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(MolotovBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(MolotovBones_ClotThink);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.m_bisWalking = false;

		int iActivity = npc.LookupActivity("ACT_ALERAISER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", BONES_MOLOTOV_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = BONES_MOLOTOV_SPEED;
		
		npc.StartPathing();

		//TODO: Replace
		/*npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/xms2013_soviet_stache/xms2013_soviet_stache_sniper.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/tomb_readers/tomb_readers_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/sniper/bio_sniper_boater.mdl");*/
		
		return npc;
	}
}

//TODO 
//Rewrite
public void MolotovBones_ClotThink(int iNPC)
{
	MolotovBones npc = view_as<MolotovBones>(iNPC);
	
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
		npc.m_iTarget = GetClosestTarget(npc.index);
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

		if (!b_MolotovThrowing[npc.index])
		{
			if (!Can_I_See_Enemy_Only(npc.index, closest))
			{
				npc.SetGoalEntity(closest);
				npc.StartPathing();
			}
			else
			{
				if (flDistanceToTarget <= MOLOTOV_TOO_CLOSE)
				{
					npc.StartPathing();
					BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, vecTarget);
					npc.SetGoalVector(vecTarget, true);
				}
				else if (flDistanceToTarget <= MOLOTOV_STOP_RANGE)
				{
					npc.StopPathing();
				}
				else
				{
					npc.SetGoalEntity(closest);
					npc.StartPathing();
				}
			}

			if (flDistanceToTarget <= MOLOTOV_THROW_RANGE && npc.m_flNextRangedAttack <= GetGameTime(npc.index) && Can_I_See_Enemy_Only(npc.index, closest))
			{
				b_MolotovThrowing[npc.index] = true;

				WorldSpaceCenter(closest, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);
				int iActivity = npc.LookupActivity("ACT_ALERAISER_THROW");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.StopPathing();

				DataPack pack = new DataPack();
				RequestFrame(Molotov_ThrowBottle, pack);
				WritePackCell(pack, EntIndexToEntRef(npc.index));
				WritePackFloat(pack, GetGameTime(npc.index) + 0.3);
				WritePackFloat(pack, GetGameTime(npc.index) + 0.5);
				WritePackFloat(pack, GetGameTime(npc.index) + 1.0);
			}
		}	
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.PlayIdleSound();
}

public void Molotov_ThrowBottle(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float swingTime = ReadPackFloat(pack);
	float throwTime = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	delete pack;

	if (!IsValidEntity(ent))
		return;

	MolotovBones npc = view_as<MolotovBones>(ent);
	float gt = GetGameTime(npc.index);

	if (gt >= swingTime)
	{
		EmitSoundToAll(SND_MOLOTOV_SWING, npc.index, _, 120, _, _, GetRandomInt(80, 110));
		swingTime = 9999999.0;
	}

	if (gt >= throwTime)
	{
		float pos[3], ang[3], vPredictedPos[3], SpeedReturn[3];
		GetAttachment(npc.index, "handL", pos, ang);

		if (IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float myPos[3], theirPos[3];
			WorldSpaceCenter(npc.index, myPos);
			WorldSpaceCenter(npc.m_iTarget, theirPos);

			if (GetVectorDistance(myPos, theirPos) <= MOLOTOV_PREDICT_RANGE)
				PredictSubjectPosition(npc, npc.m_iTarget, 1.0, _, vPredictedPos);
			else
				vPredictedPos = theirPos;
		}

		int bottle = npc.FireRocket(vPredictedPos, 0.0, MOLOTOV_THROW_VELOCITY);
		SetEntityGravity(bottle, MOLOTOV_GRAVITY); 	
		ArcToLocationViaSpeedProjectile(pos, vPredictedPos, SpeedReturn, 1.0, 1.0);
		SetEntityMoveType(bottle, MOVETYPE_FLYGRAVITY);
		TeleportEntity(bottle, NULL_VECTOR, NULL_VECTOR, SpeedReturn);

		SetEntityModel(bottle, MODEL_MOLOTOV_BOTTLE);
		ParticleEffectAt_Parent(pos, PARTICLE_MOLOTOV_BOTTLE_TRAIL, bottle);
		g_DHookRocketExplode.HookEntity(Hook_Pre, bottle, Molotov_BottleCollide);

		for (int i = 0; i < 3; i++)
		{
			ang[i] = GetRandomFloat(0.0, 360.0);
		}

		TeleportEntity(bottle, _, ang);

		throwTime = 9999999.0;
	}
	else if (IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		npc.FaceTowards(vecTarget, 400.0);
	}

	if (gt >= endTime)
	{
		int iActivity = npc.LookupActivity("ACT_ALERAISER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.StartPathing();
		b_MolotovThrowing[npc.index] = false;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + MOLOTOV_THROW_COOLDOWN;
		return;
	}

	pack = new DataPack();
	RequestFrame(Molotov_ThrowBottle, pack);
	WritePackCell(pack, EntIndexToEntRef(npc.index));
	WritePackFloat(pack, swingTime);
	WritePackFloat(pack, throwTime);
	WritePackFloat(pack, endTime);
}

public MRESReturn Molotov_BottleCollide(int entity)
{
	float position[3];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_MOLOTOV_BOTTLE_SMASH, 1.0);
	EmitSoundToAll(SND_MOLOTOV_BOTTLE_SMASH, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));
	EmitSoundToAll(SND_MOLOTOV_BOTTLE_SMASH_2, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(MOLOTOV_DAMAGE, IsValidEntity(owner) ? owner : entity, entity, entity, position, MOLOTOV_RADIUS, MOLOTOV_FALLOFF_MULTIHIT, MOLOTOV_FALLOFF_RADIUS, isBlue, _, true, MOLOTOV_ENTITYMULT);
	
	RemoveEntity(entity); 

	return MRES_Supercede; //DONT.
}

public Action MolotovBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	MolotovBones npc = view_as<MolotovBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void MolotovBones_NPCDeath(int entity)
{
	MolotovBones npc = view_as<MolotovBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}