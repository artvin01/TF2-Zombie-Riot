#pragma semicolon 1
#pragma newdecls required

#define BONES_CRIMINAL_HP			"900"
#define BONES_CRIMINAL_SKIN		"2"
#define BONES_CRIMINAL_SCALE		 "1.0"

static float BONES_CRIMINAL_SPEED = 220.0;
static float CRIMINAL_NATURAL_BUFF_CHANCE = 0.1;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float CRIMINAL_NATURAL_BUFF_LEVEL_MODIFIER = 0.2;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float CRIMINAL_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.
static float CRIMINAL_TRANSFORM_BUFFCHANCE = 0.1;	//Chance to make the skeleton transform into a random buffed variant instead of just a normal skeleton.

static float BONES_CRIMINAL_PLAYERDAMAGE = 60.0;
static float BONES_CRIMINAL_BUILDINGDAMAGE = 100.0;
static float BONES_CRIMINAL_ATTACKINTERVAL = 1.2;

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

public void CriminalBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Calcium Criminal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_criminal");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return CriminalBones(client, vecPos, vecAng, ally, false);
}

methodmap CriminalBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCriminalBones::PlayMeleeHitSound()");
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
	
	
	
	public CriminalBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		if (!buffed)
		{
			float chance = CRIMINAL_NATURAL_BUFF_CHANCE;
			if (CRIMINAL_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / CRIMINAL_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * CRIMINAL_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
		}
			
		CriminalBones npc = view_as<CriminalBones>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", BONES_CRIMINAL_SCALE, BONES_CRIMINAL_HP, ally, false));

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_CRIMINAL_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_CRIMINAL_HP);

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Calcium Criminal");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Calcium Criminal");

		b_BonesBuffed[npc.index] = buffed;
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(Criminal_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(CriminalBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(CriminalBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(CriminalBones_ClotThink);
		
		if (buffed)
		{
			Criminal_SetBuffed(npc.index, true);
		}
		else
		{
			FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
			npc.m_iWearable1 = npc.EquipItem("hat", "models/workshop/player/items/sniper/jul13_sniper_souwester/jul13_sniper_souwester.mdl");
			SetVariantString("1.125");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			
			npc.m_bDoSpawnGesture = true;
			DispatchKeyValue(npc.index, "skin", BONES_CRIMINAL_SKIN);

			npc.m_flNextMeleeAttack = 0.0;
			
			npc.m_iBleedType = BLEEDTYPE_SKELETON;
			npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			
			//IDLE
			npc.m_flSpeed = (BONES_CRIMINAL_SPEED);
			
			npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
			
			npc.StartPathing();
		}
		
		return npc;
	}
}

public void Criminal_SetBuffed(int index, bool buffed)
{
	if (buffed)
	{
		RequestFrame(Criminal_Transform, EntIndexToEntRef(index));
	}
}

public void Criminal_Transform(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	CriminalBones npc = view_as<CriminalBones>(ent);

	float pos[3], ang[3], vel[3];
	npc.GetAbsOrigin(pos);
	npc.GetAbsVelocity(vel);
	npc.GetAbsAngles(ang);

	int spawned;

	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			spawned = RattlerBones(npc.index, pos, ang, GetTeam(npc.index), GetRandomFloat(0.0, 1.0) <= CRIMINAL_TRANSFORM_BUFFCHANCE).index;
		}
		case 2:
		{
			spawned = MolotovBones(npc.index, pos, ang, GetTeam(npc.index)).index;
		}
		default:
		{
			spawned = SluggerBones(npc.index, pos, ang, GetTeam(npc.index), GetRandomFloat(0.0, 1.0) <= CRIMINAL_TRANSFORM_BUFFCHANCE).index;
		}
	}

	if (IsValidEntity(spawned))
	{
		CClotBody spawnedNPC = view_as<CClotBody>(spawned);

		float current = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		float defaultMax = float(npc.m_iBoneZoneNonBuffedMaxHealth);
		float targetMax = float((spawnedNPC.BoneZone_GetBuffedState() ? spawnedNPC.m_iBoneZoneBuffedMaxHealth : spawnedNPC.m_iBoneZoneNonBuffedMaxHealth));
		float multiplier = current / defaultMax;
		if (multiplier != 1.0)
			SetEntProp(spawned, Prop_Data, "m_iMaxHealth", RoundFloat(targetMax * multiplier));

		if (GetEntProp(spawnedNPC.index, Prop_Data, "m_iHealth") > GetEntProp(spawnedNPC.index, Prop_Data, "m_iMaxHealth"))
			SetEntProp(spawnedNPC.index, Prop_Data, "m_iHealth", GetEntProp(spawnedNPC.index, Prop_Data, "m_iMaxHealth"));

		if (IsValidEntity(npc.m_iBoneZoneSummoner))
			spawnedNPC.m_iBoneZoneSummoner = npc.m_iBoneZoneSummoner;

		RemoveEntity(ent);

		pos[2] += 40.0;
		ParticleEffectAt(pos, PARTICLE_TRANSFORM);
		EmitSoundToAll(SND_TRANSFORM, spawned, _, 120);
		view_as<CClotBody>(spawned).SetVelocity(vel);
	}
}

//TODO 
//Rewrite
public void CriminalBones_ClotThink(int iNPC)
{
	CriminalBones npc = view_as<CriminalBones>(iNPC);
	
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, BONES_CRIMINAL_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, BONES_CRIMINAL_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);					

							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + BONES_CRIMINAL_ATTACKINTERVAL;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + BONES_CRIMINAL_ATTACKINTERVAL;
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


public Action CriminalBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	CriminalBones npc = view_as<CriminalBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void CriminalBones_NPCDeath(int entity)
{
	CriminalBones npc = view_as<CriminalBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


