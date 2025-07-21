#pragma semicolon 1
#pragma newdecls required

#define BONES_SQUIRE_HP			"20000"
#define BONES_SQUIRE_HP_BUFFED	"40000"

#define BONES_SQUIRE_SKIN		"2"
#define BONES_SQUIRE_SKIN_BUFFED	"0"

#define BONES_SQUIRE_SCALE		 "1.0"
#define BONES_SQUIRE_SCALE_BUFFED "1.2"

#define BONES_SQUIRE_RAMPAGEPARTICLE	"utaunt_glitter_teamcolor_red"

static float BONES_SQUIRE_MELEE_HIT_DELAY =  0.4;
static float BONES_SQUIRE_MELEE_HIT_DELAY_BUFFED = 0.65;
static float BONES_SQUIRE_MELEE_HIT_DELAY_BUFFED_RAMPAGE = 0.65;

static float BONES_SQUIRE_SPEED = 300.0;
static float BONES_SQUIRE_SPEED_BUFFED = 320.0;
static float BONES_SQUIRE_SPEED_BUFFED_RAMPAGE = 440.0;
static float SQUIRE_NATURAL_BUFF_CHANCE = 0.1;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float SQUIRE_NATURAL_BUFF_LEVEL_MODIFIER = 0.1;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float SQUIRE_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static float BONES_SQUIRE_PLAYERDAMAGE = 90.0;
static float BONES_SQUIRE_PLAYERDAMAGE_BUFFED = 200.0;
static float BONES_SQUIRE_PLAYERDAMAGE_BUFFED_RAMPAGE = 400.0;

static float BONES_SQUIRE_BUILDINGDAMAGE = 200.0;
static float BONES_SQUIRE_BUILDINGDAMAGE_BUFFED = 400.0;
static float BONES_SQUIRE_BUILDINGDAMAGE_BUFFED_RAMPAGE = 1200.0;

static float BONES_SQUIRE_ATTACKINTERVAL = 0.6;
static float BONES_SQUIRE_ATTACKINTERVAL_BUFFED = 1.0;
static float BONES_SQUIRE_ATTACKINTERVAL_BUFFED_RAMPAGE = 0.5;

static float BONES_SQUIRE_RAMPAGE_THRESHOLD = 0.5;		//HP threshold at which the buffed variant enters a rampage state.

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
	")weapons/blade_slice_2.wav",
	")weapons/blade_slice_3.wav",
	")weapons/blade_slice_4.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav",
};

static char g_MeleeHitSounds_Buffed[][] = {
	")weapons/demo_charge_hit_flesh1.wav",
	")weapons/demo_charge_hit_flesh2.wav",
	")weapons/demo_charge_hit_flesh3.wav",
};

static char g_MeleeAttackSounds_Buffed[][] = {
	")misc/halloween/strongman_fast_whoosh_01.wav",
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

static char g_RampageStart[][] = {
	")vo/halloween_boss/knight_pain01.mp3",
	")vo/halloween_boss/knight_pain02.mp3",
	")vo/halloween_boss/knight_pain03.mp3"
};

static char g_RampageEnd[][] = {
	")vo/halloween_boss/knight_alert01.mp3",
	")vo/halloween_boss/knight_alert02.mp3"
};

static bool b_SquireRampage[2049] = { false, ... };

public void SquireBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds_Buffed));	i++) { PrecacheSound(g_MeleeHitSounds_Buffed[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds_Buffed));	i++) { PrecacheSound(g_MeleeAttackSounds_Buffed[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RampageStart));   i++) { PrecacheSound(g_RampageStart[i]);   }
	for (int i = 0; i < (sizeof(g_RampageEnd));   i++) { PrecacheSound(g_RampageEnd[i]);   }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Skeletal Squire");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_skeletalsquire");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Knightmare");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_skeletalsquire_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SquireBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SquireBones(client, vecPos, vecAng, ally, true);
}

methodmap SquireBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		if (b_BonesBuffed[this.index])
			EmitSoundToAll(g_MeleeAttackSounds_Buffed[GetRandomInt(0, sizeof(g_MeleeAttackSounds_Buffed) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		if (b_BonesBuffed[this.index])
			EmitSoundToAll(g_MeleeHitSounds_Buffed[GetRandomInt(0, sizeof(g_MeleeHitSounds_Buffed) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayHeIsAwakeSound()");
		#endif
	}
	
	public void PlayRampageStart() {
		int rand = GetRandomInt(0, sizeof(g_RampageStart) - 1);
		EmitSoundToAll(g_RampageStart[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		EmitSoundToAll(g_RampageStart[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayHeIsAwakeSound()");
		#endif
	}

	public void PlayRampageEnd() {
		int rand = GetRandomInt(0, sizeof(g_RampageEnd) - 1);
		EmitSoundToAll(g_RampageEnd[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		EmitSoundToAll(g_RampageEnd[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSquireBones::PlayHeIsAwakeSound()");
		#endif
	}
	
	public SquireBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = SQUIRE_NATURAL_BUFF_CHANCE;
			if (SQUIRE_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / SQUIRE_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * SQUIRE_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		SquireBones npc = view_as<SquireBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_SQUIRE_SCALE_BUFFED : BONES_SQUIRE_SCALE, buffed && !randomlyBuffed ? BONES_SQUIRE_HP_BUFFED : BONES_SQUIRE_HP, ally, false));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_SQUIRE_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_SQUIRE_HP_BUFFED);
		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_SQUIRE_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_SQUIRE_SCALE_BUFFED);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_SQUIRE_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_SQUIRE_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Knightmare");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Skeletal Squire");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(SquireBones_SetBuffed);
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(SquireBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SquireBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SquireBones_ClotThink);

		b_SquireRampage[npc.index] = false;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		Squire_GiveCosmetics(npc, buffed);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_SQUIRE_SPEED_BUFFED : BONES_SQUIRE_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

stock void Squire_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();

	npc.m_iState = -1;
	npc.m_iActivity = -1;
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_sniper.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		//npc.m_iWearable2 = npc.EquipItem("hat", "models/workshop/player/items/demo/tw2_demo_pants/tw2_demo_pants.mdl");

		npc.m_blSetBuffedSkeletonAnimation = true;
		npc.m_blSetNonBuffedSkeletonAnimation = false;

		DispatchKeyValue(npc.index, "skin", BONES_SQUIRE_SKIN_BUFFED);
	}
	else
	{
		npc.m_blSetBuffedSkeletonAnimation = false;
		npc.m_blSetNonBuffedSkeletonAnimation = true;

		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/sniper/sniper_spiral.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");

		//npc.m_iWearable2 = npc.EquipItem("hat", "models/workshop/player/items/demo/tw2_demo_pants/tw2_demo_pants.mdl");
		//DispatchKeyValue(npc.m_iWearable2, "skin", "1");

		DispatchKeyValue(npc.index, "skin", BONES_SQUIRE_SKIN);
	}
}

public void SquireBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);

	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;

		Squire_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_SQUIRE_SKIN_BUFFED);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;

		Squire_GiveCosmetics(npc, false);
		
		//Remove buffed particle:
		SquireBones_RemoveRampageParticle(index);

		if (b_SquireRampage[index])
		{
			b_SquireRampage[index] = false;
			view_as<SquireBones>(index).PlayRampageEnd();
			npc.SetPlaybackRate(1.0);
		}
	}
}

public void SquireBones_ApplyRampageParticle(int index)
{
	TE_SetupParticleEffect(BONES_SQUIRE_RAMPAGEPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
	TE_WriteNum("m_bControlPoint1", index);	
	TE_SendToAll();
}

public void SquireBones_RemoveRampageParticle(int index)
{
	TE_Start("EffectDispatch");
	TE_WriteNum("entindex", index);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_SQUIRE_RAMPAGEPARTICLE));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
}

//TODO 
//Rewrite
public void SquireBones_ClotThink(int iNPC)
{
	SquireBones npc = view_as<SquireBones>(iNPC);
	npc.Update();
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if (b_BonesBuffed[npc.index])
	{
		float maxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		float current = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float percentage = current / maxHealth;

		if (b_SquireRampage[npc.index] && percentage > BONES_SQUIRE_RAMPAGE_THRESHOLD)
		{
			SquireBones_RemoveRampageParticle(npc.index);
			npc.m_flSpeed = BONES_SQUIRE_SPEED_BUFFED;
			b_SquireRampage[npc.index] = false;
			npc.PlayRampageEnd();
			npc.SetPlaybackRate(1.0);
		}
		else if (!b_SquireRampage[npc.index] && percentage <= BONES_SQUIRE_RAMPAGE_THRESHOLD)
		{
			SquireBones_ApplyRampageParticle(npc.index);
			npc.m_flSpeed = BONES_SQUIRE_SPEED_BUFFED_RAMPAGE;
			b_SquireRampage[npc.index] = true;
			npc.PlayRampageStart();
			npc.SetPlaybackRate(1.5);
		}
	}

	if (npc.m_blSetBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_KNIGHTMARE_RUN");
		npc.m_blSetBuffedSkeletonAnimation = false;
	}

	if (npc.m_blSetNonBuffedSkeletonAnimation)
	{
		npc.SetActivity("ACT_SQUIRE_RUN");
		npc.m_blSetNonBuffedSkeletonAnimation = false;
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
					if (b_BonesBuffed[npc.index])
						npc.AddGesture("ACT_KNIGHTMARE_MELEE");
					else
						npc.AddGesture("ACT_SQUIRE_MELEE");

					npc.PlayMeleeSound();
					float delay = (b_BonesBuffed[npc.index] ? (b_SquireRampage[npc.index] ? BONES_SQUIRE_MELEE_HIT_DELAY_BUFFED_RAMPAGE : BONES_SQUIRE_MELEE_HIT_DELAY_BUFFED) : BONES_SQUIRE_MELEE_HIT_DELAY);
					npc.m_flAttackHappens = GetGameTime(npc.index) + delay;
					CreateTimer(delay - 0.15, Squire_PlaySwingSound, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
					npc.m_flAttackHappens_bullshit = npc.m_flAttackHappens + 0.15;
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? (b_SquireRampage[npc.index] ? BONES_SQUIRE_PLAYERDAMAGE_BUFFED_RAMPAGE : BONES_SQUIRE_PLAYERDAMAGE_BUFFED) : BONES_SQUIRE_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? (b_SquireRampage[npc.index] ? BONES_SQUIRE_BUILDINGDAMAGE_BUFFED_RAMPAGE : BONES_SQUIRE_BUILDINGDAMAGE_BUFFED) : BONES_SQUIRE_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);					

							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? (b_SquireRampage[npc.index] ? BONES_SQUIRE_ATTACKINTERVAL_BUFFED_RAMPAGE : BONES_SQUIRE_ATTACKINTERVAL_BUFFED) : BONES_SQUIRE_ATTACKINTERVAL);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? (b_SquireRampage[npc.index] ? BONES_SQUIRE_ATTACKINTERVAL_BUFFED_RAMPAGE : BONES_SQUIRE_ATTACKINTERVAL_BUFFED) : BONES_SQUIRE_ATTACKINTERVAL);
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

public Action Squire_PlaySwingSound(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	view_as<SquireBones>(ent).PlayMeleeSound();
	return Plugin_Continue;
}

public Action SquireBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	SquireBones npc = view_as<SquireBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void SquireBones_NPCDeath(int entity)
{
	SquireBones npc = view_as<SquireBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


