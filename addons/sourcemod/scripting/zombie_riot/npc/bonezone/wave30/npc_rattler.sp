#pragma semicolon 1
#pragma newdecls required

static float BONES_RATTLER_SPEED = 250.0;
static float BONES_RATTLER_SPEED_BUFFED = 320.0;

#define BONES_RATTLER_HP				"900"
#define BONES_RATTLER_HP_BUFFED		"4500"

static float BONES_RATTLER_PLAYERDAMAGE = 40.0;
static float BONES_RATTLER_PLAYERDAMAGE_BUFFED = 400.0;
static float RATTLER_NATURAL_BUFF_CHANCE = 0.05;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float RATTLER_NATURAL_BUFF_LEVEL_MODIFIER = 0.1;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float RATTLER_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

//static float BONES_RATTLER_BUILDINGDAMAGE = 120.0;
//static float BONES_RATTLER_BUILDINGDAMAGE_BUFFED = 800.0;

static float BONES_RATTLER_PROJECTILE_VELOCITY = 800.0;
static float BONES_RATTLER_PROJECTILE_VELOCITY_BUFFED = 1400.0;
static float BONES_RATTLER_PROJECTILE_LIFESPAN = 1.2;
//No lifespan variable for buffed rattlers because their projectiles don't disappear.

static float RATTLER_FIREBALL_BLAST_RADIUS = 200.0;
static float RATTLER_FIREBALL_FALLOFF_MULTIHIT = 0.8;
static float RATTLER_FIREBALL_FALLOFF_RADIUS = 0.66;
static float RATTLER_FIREBALL_ENTITY_MULTIPLIER = 3.0;

static float BONES_RATTLER_ATTACKINTERVAL = 0.5;
static float BONES_RATTLER_ATTACKINTERVAL_BUFFED = 1.0;

static float RATTLER_HOVER_MINDIST = 400.0;
static float RATTLER_HOVER_MAXDIST = 700.0;
//static float RATTLER_HOVER_OPTIMALDIST = 550.0;

static float RATTLER_CHARGE_DURATION = 3.0;

static float f_RattlerFireballDMG[2049] = { 0.0, ... };

#define BONES_RATTLER_SCALE				"1.0"
#define BONES_RATTLER_BUFFED_SCALE			"1.2"

#define BONES_RATTLER_SKIN						"0"
#define BONES_RATTLER_BUFFED_SKIN				"1"

#define PARTICLE_RATTLER_FIREBALL			"flaregun_trail_red"
#define PARTICLE_RATTLER_FIREBALL_BUFFED	"spell_fireball_small_blue"
#define PARTICLE_FIREBALL_HIT				"flaregun_destroyed"
#define PARTICLE_FIREBALL_EXPLODE			"spell_fireball_tendril_parent_blue"

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

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rattler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rattler");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Hollow Hitman");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_rattler_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Common;
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
	
	
	
	public RattlerBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
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
		}
			
		RattlerBones npc = view_as<RattlerBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_RATTLER_BUFFED_SCALE : BONES_RATTLER_SCALE, buffed ? BONES_RATTLER_HP_BUFFED : BONES_RATTLER_HP, ally, false));
		
		b_BonesBuffed[npc.index] = buffed;
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(RattlerBones_SetBuffed);
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(RattlerBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RattlerBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RattlerBones_ClotThink);
		
		Rattler_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			int iActivity = npc.LookupActivity("ACT_HITMAN_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_RATTLER_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		
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

public void RattlerBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_RATTLER_BUFFED_SCALE);
		int HP = StringToInt(BONES_RATTLER_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_RATTLER_SPEED_BUFFED;
		Rattler_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_RATTLER_BUFFED_SKIN);

		int iActivity = npc.LookupActivity("ACT_HITMAN_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_RATTLER_SCALE);
		int HP = StringToInt(BONES_RATTLER_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_RATTLER_SPEED;
		Rattler_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_RATTLER_SKIN);

		int iActivity = npc.LookupActivity("ACT_RATTLER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
}

stock void Rattler_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
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

public void Rattler_CheckThrow(RattlerBones npc, int closest)
{
	if (npc.m_flNextRangedAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index))
	{
		if (!Can_I_See_Enemy_Only(npc.index, closest))
			return;
	}
}

public void Rattler_ShootProjectile(RattlerBones npc, float vicLoc[3], float vel, float damage)
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
		
		f_RattlerFireballDMG[entity] = damage;

		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
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
			CreateTimer(BONES_RATTLER_PROJECTILE_LIFESPAN, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
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
		SDKHooks_TakeDamage(other, entity, IsValidEntity(owner) ? owner : entity, f_RattlerFireballDMG[entity]);
			
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, PARTICLE_FIREBALL_HIT, 2.0);
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
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_RattlerFireballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, RATTLER_FIREBALL_BLAST_RADIUS, RATTLER_FIREBALL_FALLOFF_MULTIHIT, RATTLER_FIREBALL_FALLOFF_RADIUS, isBlue, _, true, RATTLER_FIREBALL_ENTITY_MULTIPLIER);
	
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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int closest = npc.m_iTarget;
	
	//Rattlers will always attempt to stay a certain distance away from their target, not too far but not too close.
	//If they are too far/too close, they will move closer/further as needed.
	//They will still, however, always choose the nearest enemy as their target.
	if(IsValidEnemy(npc.index, closest))
	{
		float pos[3], targPos[3], optimalPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
					
		if (!Can_I_See_Enemy_Only(npc.index, closest))
		{
			npc.StartPathing();
			NPC_SetGoalEntity(npc.index, closest);
		}
		else
		{
			if (flDistanceToTarget < RATTLER_HOVER_MINDIST)
			{
				npc.StartPathing();
				BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);
				NPC_SetGoalVector(npc.index, optimalPos, true);
			}
			else if (flDistanceToTarget > RATTLER_HOVER_MAXDIST)
			{
				npc.StartPathing();
				NPC_SetGoalEntity(npc.index, closest);
			}
			else
			{
				npc.StopPathing();
			}

			Rattler_CheckThrow(npc, closest);
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
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
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


