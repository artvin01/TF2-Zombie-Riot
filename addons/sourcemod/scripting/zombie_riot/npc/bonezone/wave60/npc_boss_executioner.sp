#pragma semicolon 1
#pragma newdecls required

#define LORDREAD_SCALE			"1.3"
#define LORDREAD_HP			"50000"
#define LORDREAD_SKIN			"1"

static float LORDREAD_SPEED = 260.0;

//NIGHTMARISH BRUTALITY: Lordread kills his foes so brutally that all enemies within a short radius of the initial victim who have line-of-sight are briefly stunned.
static float Brutality_Radius = 300.0;	//Effect radius.
static float Brutality_Stun = 3.0;		//Stun duration.

//PUBLIC EXECUTION: Whenever Lordread kills/downs an enemy, all allies (not counting Lordread) with direct line-of-sight to that enemy are immediately buffed and healed
//to full (max 50k healing).
static float Execution_Heal = 1.0;			//Percentage of max HP to heal allies for when they witness the execution.
static float Execution_MaxHeal = 50000.0;	//Maximum healing given to individual allies by this ability.

//GUILLOTINE: Lordread's basic melee attack. Lordread slams his axe down in front of him, instantly downing anyone who is hit or dealing MASSIVE damage to buildings/barracks
//units. Enemies who are downed by this attack have their down HP halved. This attack's speed and cooldown become faster as Lordread loses health, up to double at 10% HP.
static float Guillotine_Cooldown = 4.0;			//Melee attack interval.
static float Guillotine_DMG = 9999999.0;		//Damage versus players.
static float Guillotine_DMG_Entities = 10000.0;	//Damage versus entities.
static float Guillotine_Range = 90.0;			//Range in which the attack will be used.
static float Guillotine_SpeedMult = 0.5;		//Maximum additional animation speed boost, based on health lost.
static float Guillotine_CDMult = 0.5;			//Maximum additional cooldown multiplier, based on health lost.
static float Guillotine_MinHP = 0.1;			//Health percentage at which Guillotine becomes its fastest.

//LORD OF THE WRETCHED: Lordread thrusts his axe into the air, summoning 8 red lightning bolts on random nav areas within a small radius around him. These lightning bolts
//deal AoE damage and summon random non-buffed medieval skeletons. This ability cannot be used if at least 4 enemies who were summoned by him are still alive.
static float Lord_Radius = 800.0;				//Radius in which lightning is called down.
static float Lord_Interval_Extra = 0.2;			//Interval in which extra (non-summoner) bolts are called down.
static float Lord_Interval_Summon = 0.75;		//Interval in which bolts which summon allies are called down.
static float Lord_Delay = 1.0;					//Delay after being summoned at which the lightning bolt will strike.
static float Lord_BlastDMG = 100.0;				//Lightning bolt damage.
static float Lord_BlastRadius = 120.0;			//Lightning bolt radius.
static float Lord_BlastEntityMult = 4.0;		//Amount to multiply lightning damage against buildings.
static float Lord_BlastFalloff_Range = 0.66;	//Maximum range-based falloff.
static float Lord_BlastFalloff_MultiHit = 0.8;	//Amount to multiply lightning damage per target hit.

//CRIMSON TEMPEST: Lordread holds his axe out and enchants it with red lightning, then begins to spin wildly, rapidly damaging anyone who gets too close. Enemies within
//a small radius (2x the damage radius) are pulled in (weak pull). Lordread is slowed massively during this attack. Buildings take triple damage from this.
static float Tempest_DMG = 100.0;			//Damage dealt per interval.
static float Tempest_EntityMult = 8.0;		//Amount to multiply damage dealt to entities.
static float Tempest_Interval = 0.33;		//Interval in which Crimson Tempest deals damage.
static float Tempest_Radius = 200.0;		//Damage radius.
static float Tempest_SuckRadius = 400.0;	//Radius in which enemies are pulled in.
static float Tempest_Duration = 12.0;		//Spin duration.
static float Tempest_Cooldown = 24.0;		//Cooldown.

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

public void Lordread_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "Lordread, Royal Executioner of Necropolis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_executioner");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Lordread;
	NPC_Add(data);
}

static any Summon_Lordread(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Lordread(client, vecPos, vecAng, ally);
}

methodmap Lordread < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, _, _, _, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayMeleeHitSound()");
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

	public Lordread(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		Lordread npc = view_as<Lordread>(CClotBody(vecPos, vecAng, BONEZONE_MODEL_BOSS, LORDREAD_SCALE, LORDREAD_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(Lordread_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Lordread_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Lordread_ClotThink);

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_EXECUTIONER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", LORDREAD_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = LORDREAD_SPEED;

		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Lordread_ClotThink(int iNPC)
{
	Lordread npc = view_as<Lordread>(iNPC);
	
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
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother, true);
				
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
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


public Action Lordread_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;

	Lordread npc = view_as<Lordread>(victim);
	//TODO: Fill this out if needed, scrap if not

	return Plugin_Changed;
}

public void Lordread_NPCDeath(int entity)
{
	Lordread npc = view_as<Lordread>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}