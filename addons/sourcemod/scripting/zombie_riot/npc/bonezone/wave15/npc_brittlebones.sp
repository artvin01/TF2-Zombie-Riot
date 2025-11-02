#pragma semicolon 1
#pragma newdecls required

static float BONES_BRITTLE_SPEED = 440.0;
static float BONES_BRITTLE_SPEED_BUFFED = 520.0;
static float BRITTLE_NATURAL_BUFF_CHANCE = 0.0;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float BRITTLE_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float BRITTLE_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

#define BONES_BRITTLE_HP			"100"
#define BONES_BRITTLE_HP_BUFFED		"300"

static float BONES_BRITTLE_PLAYERDAMAGE = 5.0;
static float BONES_BRITTLE_PLAYERDAMAGE_BUFFED = 10.0;

static float BONES_BRITTLE_BUILDINGDAMAGE = 20.0;
static float BONES_BRITTLE_BUILDINGDAMAGE_BUFFED = 40.0;

static float BONES_BRITTLE_ATTACKINTERVAL = 0.5;
static float BONES_BRITTLE_ATTACKINTERVAL_BUFFED = 0.33;

static int Brittle_Particle[MAXENTITIES] = { -1, ... };

#define BONES_BRITTLE_SCALE			"0.7"

#define BONES_BRITTLE_BUFFPARTICLE		"superrare_burning2"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_small_01.wav",
	")misc/halloween/skeletons/skelly_small_02.wav",
	")misc/halloween/skeletons/skelly_small_03.wav",
	")misc/halloween/skeletons/skelly_small_04.wav",
	")misc/halloween/skeletons/skelly_small_05.wav",
	")misc/halloween/skeletons/skelly_small_06.wav",
	")misc/halloween/skeletons/skelly_small_07.wav",
	")misc/halloween/skeletons/skelly_small_08.wav",
	")misc/halloween/skeletons/skelly_small_09.wav",
	")misc/halloween/skeletons/skelly_small_10.wav",
	")misc/halloween/skeletons/skelly_small_11.wav",
	")misc/halloween/skeletons/skelly_small_12.wav",
	")misc/halloween/skeletons/skelly_small_13.wav",
	")misc/halloween/skeletons/skelly_small_14.wav",
	")misc/halloween/skeletons/skelly_small_15.wav",
	")misc/halloween/skeletons/skelly_small_16.wav",
	")misc/halloween/skeletons/skelly_small_17.wav",
	")misc/halloween/skeletons/skelly_small_18.wav",
	")misc/halloween/skeletons/skelly_small_19.wav",
	")misc/halloween/skeletons/skelly_small_20.wav",
	")misc/halloween/skeletons/skelly_small_21.wav",
	")misc/halloween/skeletons/skelly_small_22.wav"
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_small_01.wav",
	")misc/halloween/skeletons/skelly_small_02.wav",
	")misc/halloween/skeletons/skelly_small_03.wav",
	")misc/halloween/skeletons/skelly_small_04.wav",
	")misc/halloween/skeletons/skelly_small_05.wav",
	")misc/halloween/skeletons/skelly_small_06.wav",
	")misc/halloween/skeletons/skelly_small_07.wav",
	")misc/halloween/skeletons/skelly_small_08.wav",
	")misc/halloween/skeletons/skelly_small_09.wav",
	")misc/halloween/skeletons/skelly_small_10.wav",
	")misc/halloween/skeletons/skelly_small_11.wav",
	")misc/halloween/skeletons/skelly_small_12.wav",
	")misc/halloween/skeletons/skelly_small_13.wav",
	")misc/halloween/skeletons/skelly_small_14.wav",
	")misc/halloween/skeletons/skelly_small_15.wav",
	")misc/halloween/skeletons/skelly_small_16.wav",
	")misc/halloween/skeletons/skelly_small_17.wav",
	")misc/halloween/skeletons/skelly_small_18.wav",
	")misc/halloween/skeletons/skelly_small_19.wav",
	")misc/halloween/skeletons/skelly_small_20.wav",
	")misc/halloween/skeletons/skelly_small_21.wav",
	")misc/halloween/skeletons/skelly_small_22.wav"
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

public void BrittleBones_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "Brittle Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_brittlebones");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Buffed Brittle Bones");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_brittlebones_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BrittleBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BrittleBones(client, vecPos, vecAng, ally, true);
}

methodmap BrittleBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	
	
	public BrittleBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = BRITTLE_NATURAL_BUFF_CHANCE;
			if (BRITTLE_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / BRITTLE_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * BRITTLE_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		BrittleBones npc = view_as<BrittleBones>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", BONES_BRITTLE_SCALE, buffed && !randomlyBuffed ? BONES_BRITTLE_HP_BUFFED : BONES_BRITTLE_HP, ally, false));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_BRITTLE_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_BRITTLE_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_BRITTLE_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_BRITTLE_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_BRITTLE_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_BRITTLE_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Buffed Brittle Bones");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Brittle Bones");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(BrittleBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(BrittleBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BrittleBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BrittleBones_ClotThink);
		
		if (buffed)
		{
			Brittle_Particle[npc.index] = EntIndexToEntRef(Brittle_AttachParticle(npc.index, BONES_BRITTLE_BUFFPARTICLE, _, "eyes"));
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		int skin = GetRandomInt(0, 3);
		char skinChar[16];
		Format(skinChar, sizeof(skinChar), "%i", skin);
		
		DispatchKeyValue(npc.index, "skin", skinChar);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_BRITTLE_SPEED_BUFFED : BONES_BRITTLE_SPEED);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void BrittleBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed particle:
		Brittle_Particle[index] = EntIndexToEntRef(Brittle_AttachParticle(npc.index, BONES_BRITTLE_BUFFPARTICLE, _, "eyes"));
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed particle:
		int particle = EntRefToEntIndex(Brittle_Particle[index]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
}

stock int Brittle_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		
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
		}
		
		return part1;
	}
	
	return -1;
}


public void BrittleBones_ClotThink(int iNPC)
{
	BrittleBones npc = view_as<BrittleBones>(iNPC);
	
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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3];
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
	//		PrintToChatAll("cutoff");
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		//Target close enough to hit
		
		if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 20000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.7;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.83;
					npc.m_flAttackHappenswillhappen = true;
				}
				//Can we attack right now?
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							if(target <= MaxClients)
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_BRITTLE_PLAYERDAMAGE_BUFFED : BONES_BRITTLE_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_BRITTLE_BUILDINGDAMAGE_BUFFED : BONES_BRITTLE_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);						
								
							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_BRITTLE_ATTACKINTERVAL_BUFFED : BONES_BRITTLE_ATTACKINTERVAL);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_BRITTLE_ATTACKINTERVAL_BUFFED : BONES_BRITTLE_ATTACKINTERVAL);
				}
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


public Action BrittleBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BrittleBones npc = view_as<BrittleBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BrittleBones_NPCDeath(int entity)
{
	BrittleBones npc = view_as<BrittleBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	int particle = EntRefToEntIndex(Brittle_Particle[entity]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
		
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}


