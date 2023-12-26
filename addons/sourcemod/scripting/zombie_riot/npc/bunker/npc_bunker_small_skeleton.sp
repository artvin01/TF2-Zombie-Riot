#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static const char g_HurtSounds[][] = {
	")misc/halloween/skeletons/skelly_small_18.wav",
};

static const char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_small_11.wav",
	")misc/halloween/skeletons/skelly_small_12.wav",
	")misc/halloween/skeletons/skelly_small_13.wav",
	")misc/halloween/skeletons/skelly_small_14.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_small_05.wav",
};

static const char g_MeleeHitSounds[][] = {
	")misc/halloween/skeletons/skelly_small_19.wav",
	")misc/halloween/skeletons/skelly_small_21.wav",
	")misc/halloween/skeletons/skelly_small_22.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/axe_hit_flesh1.wav",
	"weapons/slap_hit1.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_HeIsAwake[][] = {
	")misc/halloween/spell_skeleton_horde_rise.wav",
};

static bool WakeTheFUCKUp[MAXENTITIES];

public void BunkerSkeletonSmall_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_HeIsAwake));   i++) { PrecacheSound(g_HeIsAwake[i]);   }
	PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}

methodmap BunkerSkeletonSmall < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayMeleeMissSound()");
		#endif
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeletonSmall::PlayHeIsAwakeSound()");
		#endif
	}
	
	public BunkerSkeletonSmall(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerSkeletonSmall npc = view_as<BunkerSkeletonSmall>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", "0.65", "3000", ally, false));
		
		i_NpcInternalId[npc.index] = BUNKER_SMALL_SKELETON;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		
		WakeTheFUCKUp[npc.index] = false;
		npc.Anger = false;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		
		//IDLE
		npc.m_flSpeed = 300.0;
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerSkeletonSmall_ClotThink);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void BunkerSkeletonSmall_ClotThink(int iNPC)
{
	BunkerSkeletonSmall npc = view_as<BunkerSkeletonSmall>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
//		WakeTheFUCKUp[npc.index] = true && GetGameTime(npc.index) + 4.0;
	}
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(WakeTheFUCKUp[npc.index])//this is only there so he can actually move
	{
		WakeTheFUCKUp[npc.index] = false;
		npc.m_flSpeed = 300.0;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		if(flDistanceToTarget < npc.GetLeadRadius()) //Predict their pos.
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
		}
		if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen) //Target close enough to hit
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 20000.0);
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)//Play attack anims
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					//npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.45;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
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
							if(EscapeModeForNpc)
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 25.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 45.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 40.0, DMG_CLUB, -1, _, vecHit);					
							}
							npc.PlayMeleeSound();
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
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

public Action BunkerSkeletonSmall_OnTakeDamage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BunkerSkeletonSmall npc = view_as<BunkerSkeletonSmall>(iNPC);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BunkerSkeletonSmall_NPCDeath(int entity)
{
	BunkerSkeletonSmall npc = view_as<BunkerSkeletonSmall>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	SDKUnhook(entity, SDKHook_Think, BunkerSkeletonSmall_ClotThink);
//	AcceptEntityInput(npc.index, "KillHierarchy");
}