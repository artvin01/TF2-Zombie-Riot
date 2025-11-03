#pragma semicolon 1
#pragma newdecls required

static float BONES_BIG_SPEED = 160.0;
static float BONES_BIG_SPEED_BUFFED = 200.0;
static float BIG_NATURAL_BUFF_CHANCE = 0.0;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float BIG_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float BIG_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static int BIG_BUFFED_MIN_SPAWNS = 20;	//Minimum number of skeletons to spawn when Buffed Big Bones dies.
static int BIG_BUFFED_MAX_SPAWNS = 20;	//Maximum number of skeletons to spawn when Buffed Big Bones dies.
static float BIG_BUFFED_SUMMON_BUFFCHANCE = 0.33;	//The chance for each individual skeleton summoned by Buffed Big Bones death to be buffed.

#define BONES_BIG_HP		"3000"
#define BONES_BIG_HP_BUFFED	"12000"

static float BONES_BIG_PLAYERDAMAGE = 120.0;
static float BONES_BIG_PLAYERDAMAGE_BUFFED = 180.0;

static float BONES_BIG_BUILDINGDAMAGE = 180.0;
static float BONES_BIG_BUILDINGDAMAGE_BUFFED = 260.0;

static float BONES_BIG_ATTACKINTERVAL = 2.4;
static float BONES_BIG_ATTACKINTERVAL_BUFFED = 2.2;

#define BONES_BIG_BUFFPARTICLE		"utaunt_glowyplayer_orange_parent"

#define BONES_BIG_SCALE			"2.0"
#define BONES_BIG_SCALE_BUFFED	"2.6"
#define BONES_BIG_SKIN		"3"
#define BONES_BIG_SKIN_BUFFED	"3"

#define PARTICLE_BIGBONES_BURST	"pumpkin_explode"
#define SOUND_BIGBONES_BURST	"items/pumpkin_explode1.wav"
#define SOUND_BIGBONES_ABOUT_TO_BURST	")vo/halloween_boss/knight_dying.mp3"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
	")misc/halloween/skeletons/skelly_giant_02.wav",
	")misc/halloween/skeletons/skelly_giant_03.wav"
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
	")misc/halloween/skeletons/skelly_giant_02.wav",
	")misc/halloween/skeletons/skelly_giant_03.wav"
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

public void BigBones_OnMapStart_NPC()
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
	PrecacheSound(SOUND_BIGBONES_ABOUT_TO_BURST);
	PrecacheSound(SOUND_BIGBONES_BURST);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Big Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bigbones");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Buffed Big Bones");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_bigbones_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BigBones(vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BigBones(vecPos, vecAng, ally, true);
}

bool BigBones_Bursting[2049] = { false, ... };

methodmap BigBones < CClotBody
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
	
	
	
	public BigBones(float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = BIG_NATURAL_BUFF_CHANCE;
			if (BIG_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / BIG_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * BIG_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		BigBones npc = view_as<BigBones>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", buffed ? BONES_BIG_SCALE_BUFFED : BONES_BIG_SCALE, buffed && !randomlyBuffed ? BONES_BIG_HP_BUFFED : BONES_BIG_HP, ally, false, true));

		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_BIG_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_BIG_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_BIG_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_BIG_SCALE_BUFFED);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_BIG_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_BIG_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Buffed Big Bones");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Big Bones");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(BigBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(BigBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BigBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BigBones_ClotThink);
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_BIG_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_BIG_SKIN_BUFFED : BONES_BIG_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_BIG_SPEED_BUFFED : BONES_BIG_SPEED);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void BigBones_SetBuffed(int index, bool buffed)
{
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		DispatchKeyValue(index, "skin", BONES_BIG_SKIN_BUFFED);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_BIG_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		DispatchKeyValue(index, "skin", BONES_BIG_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_BIG_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();
	}
}

//TODO 
//Rewrite
public void BigBones_ClotThink(int iNPC)
{
	BigBones npc = view_as<BigBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	if (BigBones_Bursting[npc.index])
		return;
	
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_BIG_PLAYERDAMAGE_BUFFED : BONES_BIG_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? BONES_BIG_BUILDINGDAMAGE_BUFFED : BONES_BIG_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);					
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_BIG_ATTACKINTERVAL_BUFFED : BONES_BIG_ATTACKINTERVAL);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_BIG_ATTACKINTERVAL_BUFFED : BONES_BIG_ATTACKINTERVAL);
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


public Action BigBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BigBones npc = view_as<BigBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	if (damage >= float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) && b_BonesBuffed[npc.index])
	{
		b_NpcIsInvulnerable[npc.index] = true;
		npc.StopPathing();
		

		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		npc.m_iWearable1 = npc.EquipItemSeperate(BONEZONE_MODEL, "big_bones_burst", StringToInt(BONES_BIG_SKIN_BUFFED), StringToFloat(BONES_BIG_SCALE_BUFFED));
		
		if (IsValidEntity(npc.m_iWearable1))	//The skin parameter of EquipItemSeperate doesn't seem to work, so I have to do this instead
			DispatchKeyValue(npc.m_iWearable1, "skin", BONES_BIG_SKIN_BUFFED);

		CreateTimer(1.1, BigBones_Burst, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
		EmitSoundToAll(SOUND_BIGBONES_ABOUT_TO_BURST, npc.index, _, 120);

		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", npc.index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_BIG_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();

		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; //Makes it so they never have an outline

		BigBones_Bursting[npc.index] = true;
		damage = 0.0;
	}
//	
	return Plugin_Changed;
}

public Action BigBones_Burst(Handle burst, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Continue;

	BigBones npc = view_as<BigBones>(ent);

	MakeObjectIntangeable(ent);
	float pos[3];
	WorldSpaceCenter(ent, pos);
	ParticleEffectAt(pos, PARTICLE_BIGBONES_BURST, 2.0);
	EmitSoundToAll(SOUND_BIGBONES_BURST, ent, _, 120);
	EmitSoundToAll(SOUND_BIGBONES_BURST, ent, _, 120);
	StopSound(ent, SNDCHAN_AUTO, SOUND_BIGBONES_ABOUT_TO_BURST);
	npc.PlayDeathSound();
	npc.PlayDeathSound();

	for (int i = 0; i < GetRandomInt(BIG_BUFFED_MIN_SPAWNS, BIG_BUFFED_MAX_SPAWNS); i++)
	{
		float ang[3], vel[3], buffer[3];
		ang[0] = GetRandomFloat(-20.0, -90.0);
		ang[1] = GetRandomFloat(0.0, 360.0);
		ang[2] = GetRandomFloat(0.0, 360.0);
		
		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);

		float randVel = GetRandomFloat(300.0, 900.0);
		for (int vec = 0; vec < 3; vec++)
			vel[vec] = buffer[vec] * randVel;

		ang[0] = 0.0;
		ang[2] = 0.0;

		int minion;
		bool buffed = GetRandomFloat(0.0, 1.0) <= BIG_BUFFED_SUMMON_BUFFCHANCE;
		switch (GetRandomInt(0, 2))
		{
			case 0:
				minion = BasicBones(pos, ang, GetTeam(npc.index), buffed).index;
			case 1:
				minion = BeefyBones(pos, ang, GetTeam(npc.index), buffed).index;
			default:
				minion = BrittleBones(pos, ang, GetTeam(npc.index), buffed).index;
		}
		
		if (IsValidEntity(minion))
		{
			view_as<CClotBody>(minion).SetVelocity(vel);
			NpcAddedToZombiesLeftCurrently(minion, true);
		}
	}

	RemoveEntity(ent);
	BigBones_Bursting[ent] = false;

	return Plugin_Continue;
}

public void BigBones_NPCDeath(int entity)
{
	BigBones npc = view_as<BigBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	BigBones_Bursting[npc.index] = false;
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


