#pragma semicolon 1
#pragma newdecls required

#define BONES_TEMPLATE_HP			"300"
#define BONES_TEMPLATE_HP_BUFFED	"600"

#define BONES_TEMPLATE_SKIN		"2"
#define BONES_TEMPLATE_SKIN_BUFFED	"2"

#define BONES_TEMPLATE_SCALE		 "1.0"
#define BONES_TEMPLATE_SCALE_BUFFED "1.2"

#define BONES_TEMPLATE_BUFFPARTICLE	"utaunt_wispy_parent_g"

static float BONES_TEMPLATE_SPEED = 200.0;
static float BONES_TEMPLATE_SPEED_BUFFED = 240.0;
static float TEMPLATE_NATURAL_BUFF_CHANCE = 0.1;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float TEMPLATE_NATURAL_BUFF_LEVEL_MODIFIER = 0.2;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float TEMPLATE_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static float BONES_TEMPLATE_PLAYERDAMAGE = 30.0;
static float BONES_TEMPLATE_PLAYERDAMAGE_BUFFED = 60.0;

static float BONES_TEMPLATE_BUILDINGDAMAGE = 60.0;
static float BONES_TEMPLATE_BUILDINGDAMAGE_BUFFED = 100.0;

static float BONES_TEMPLATE_ATTACKINTERVAL = 1.2;
static float BONES_TEMPLATE_ATTACKINTERVAL_BUFFED = 0.8;

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

public void TemplateBones_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "Template Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_basicbones");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Buffed Template Bones");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_basicbones_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Common;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return TemplateBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return TemplateBones(client, vecPos, vecAng, ally, true);
}

methodmap TemplateBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CTemplateBones::PlayMeleeHitSound()");
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
	
	
	
	public TemplateBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		if (!buffed)
		{
			float chance = TEMPLATE_NATURAL_BUFF_CHANCE;
			if (TEMPLATE_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / TEMPLATE_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * TEMPLATE_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
		}
			
		TemplateBones npc = view_as<TemplateBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_TEMPLATE_SCALE_BUFFED : BONES_TEMPLATE_SCALE, buffed ? BONES_TEMPLATE_HP_BUFFED : BONES_TEMPLATE_HP, ally, false));
		
		b_BonesBuffed[npc.index] = buffed;
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(TemplateBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(TemplateBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(TemplateBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(TemplateBones_ClotThink);
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_TEMPLATE_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}

		//COMMENT THIS OUT IF YOU ARE NOT USING BASICBONES.MDL ANIMATIONS:
		npc.m_bisWalking = false; ////////////////////////////////////////
		//////////////////////////////////////////////////////////////////

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_TEMPLATE_SKIN_BUFFED : BONES_TEMPLATE_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_TEMPLATE_SPEED_BUFFED : BONES_TEMPLATE_SPEED);
		
		//UNCOMMENT IF USING DEFAULT ANIMATIONS:
		//npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		//npc.m_bDoSpawnGesture = true;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void TemplateBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_TEMPLATE_SCALE_BUFFED);
		int HP = StringToInt(BONES_TEMPLATE_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_TEMPLATE_SPEED_BUFFED;
		DispatchKeyValue(index, "skin", BONES_TEMPLATE_SKIN_BUFFED);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_TEMPLATE_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_TEMPLATE_SCALE);
		int HP = StringToInt(BONES_TEMPLATE_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_TEMPLATE_SPEED;
		DispatchKeyValue(index, "skin", BONES_TEMPLATE_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_TEMPLATE_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();
	}
}

//TODO 
//Rewrite
public void TemplateBones_ClotThink(int iNPC)
{
	TemplateBones npc = view_as<TemplateBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	
	//UNCOMMENT IF USING DEFAULT ANIMS:
	/*if(npc.m_bDoSpawnGesture)
	{
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_TEMPLATE_PLAYERDAMAGE_BUFFED : BONES_TEMPLATE_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_TEMPLATE_BUILDINGDAMAGE_BUFFED : BONES_TEMPLATE_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);					

							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_TEMPLATE_ATTACKINTERVAL_BUFFED : BONES_TEMPLATE_ATTACKINTERVAL);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_TEMPLATE_ATTACKINTERVAL_BUFFED : BONES_TEMPLATE_ATTACKINTERVAL);
				}
			}
			
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


public Action TemplateBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	TemplateBones npc = view_as<TemplateBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void TemplateBones_NPCDeath(int entity)
{
	TemplateBones npc = view_as<TemplateBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	npc.RemoveAllWearables();

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}

