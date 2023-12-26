#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_leap_prepare[][] = {
	")misc/halloween/skeletons/skelly_medium_06.wav",
};

static char g_leap_scream[][] = {
	")misc/halloween/skeletons/skelly_medium_07.wav",
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
	")misc/halloween/skeletons/skelly_medium_02.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/axe_hit_flesh1.wav",
	"weapons/slap_hit1.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_PlayMeleeJumpPrepare[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_PlayMeleeJumpSound[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_HeIsAwake[][] = {
	")misc/halloween/spell_skeleton_horde_rise.wav",
};

static bool WakeTheFUCKUp[MAXENTITIES];

public void BunkerSkeleton_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PlayMeleeJumpPrepare));   i++) { PrecacheSound(g_PlayMeleeJumpPrepare[i]);   }
	for (int i = 0; i < (sizeof(g_PlayMeleeJumpSound));   i++) { PrecacheSound(g_PlayMeleeJumpSound[i]);   }
	for (int i = 0; i < (sizeof(g_leap_scream));   i++) { PrecacheSound(g_leap_scream[i]);   }
	for (int i = 0; i < (sizeof(g_leap_prepare));   i++) { PrecacheSound(g_leap_prepare[i]);   }
	for (int i = 0; i < (sizeof(g_HeIsAwake));   i++) { PrecacheSound(g_HeIsAwake[i]);   }
	PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}

methodmap BunkerSkeleton < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayIdleAlertSound()");
		#endif
	}
	public void PlayLeapPrepare() {
		
		EmitSoundToAll(g_leap_prepare[GetRandomInt(0, sizeof(g_leap_prepare) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeJumpPrepare()");
		#endif
	}
	public void PlayLeapDone() {
		
		EmitSoundToAll(g_leap_scream[GetRandomInt(0, sizeof(g_leap_scream) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeJumpPrepare()");
		#endif
	}
	public void PlayMeleeJumpPrepare() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_PlayMeleeJumpPrepare[GetRandomInt(0, sizeof(g_PlayMeleeJumpPrepare) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeJumpPrepare()");
		#endif
	}
	public void PlayMeleeJumpSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_PlayMeleeJumpSound[GetRandomInt(0, sizeof(g_PlayMeleeJumpSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeJumpSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeMissSound()");
		#endif
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}
	
	public BunkerSkeleton(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerSkeleton npc = view_as<BunkerSkeleton>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", "1.0", "3000", ally, false));
		
		i_NpcInternalId[npc.index] = BUNKER_SKELETON;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		
		WakeTheFUCKUp[npc.index] = false;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.Anger = false;
		
		//IDLE
		npc.m_flSpeed = 300.0;
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerSkeleton_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BunkerSkeleton_ClotDamaged_Post);
		
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 15.0;
		npc.m_flInJump = 0.0;
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void BunkerSkeleton_ClotThink(int iNPC)
{
	BunkerSkeleton npc = view_as<BunkerSkeleton>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
//		WakeTheFUCKUp[npc.index] = true && GetGameTime(npc.index) + 4.0 ;
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
		if(!npc.m_flAttackHappenswillhappen)
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
		
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump < GetGameTime(npc.index) && flDistanceToTarget > 10000 && flDistanceToTarget < 1000000)
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, closest);
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == closest) //Target close enough to hit
			{
				npc.AddGesture("ACT_MP_JUMP_START_MELEE");
				npc.m_flInJump = GetGameTime(npc.index) + 0.25;
				npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.15;
				npc.PlayLeapPrepare();
			}
		}
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump > GetGameTime(npc.index))
		{
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayLeapDone();
			npc.m_flJumpCooldown = GetGameTime(npc.index) + 12.0;
		}
		if(npc.m_flInJump > GetGameTime(npc.index))
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.FaceTowards(vecTarget, 1000.0);
			return;
		}
		
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
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.30;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.75;
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 65.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 85.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);					
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
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.75;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.75;
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

public Action Set_BunkerSkeleton_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void BunkerSkeleton_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	BunkerSkeleton npc = view_as<BunkerSkeleton>(iNPC);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( your mother
		int skin = 3;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_flSpeed = 410.0;
		//for(int client = 1; client <= MaxClients; client++)
		//{
		//	if(IsValidClient(client))
		//	{
		//		ClientCommand(client, "r_screenoverlay freak_fortress_2/corruptedspy/corruptedspy_rageoverlay1");
		//		SetVariantString("HalloweenLongFall");
		//		AcceptEntityInput(client, "SpeakResponseConcept");
		//	}
	}
}

public Action BunkerSkeleton_OnTakeDamage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BunkerSkeleton npc = view_as<BunkerSkeleton>(iNPC);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BunkerSkeleton_NPCDeath(int entity)
{
	BunkerSkeleton npc = view_as<BunkerSkeleton>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	SDKUnhook(entity, SDKHook_OnTakeDamagePost, BunkerSkeleton_ClotDamaged_Post);
	SDKUnhook(entity, SDKHook_Think, BunkerSkeleton_ClotThink);
//	AcceptEntityInput(npc.index, "KillHierarchy");
}