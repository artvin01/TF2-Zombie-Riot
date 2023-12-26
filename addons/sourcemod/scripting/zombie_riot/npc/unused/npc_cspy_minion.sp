#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_lose.mp3",
};

static const char g_HurtSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_1.mp3",
	"freak_fortress_2/corruptedspy/glitch_2.mp3",
	"freak_fortress_2/corruptedspy/glitch_3.mp3",
	"freak_fortress_2/corruptedspy/glitch_4.mp3",
};

static const char g_IdleSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_8.mp3",
	"freak_fortress_2/corruptedspy/glitch_9.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_1.mp3",
	"freak_fortress_2/corruptedspy/glitch_3.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/knife_swing.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_7.mp3",
	"freak_fortress_2/corruptedspy/glitch_6.mp3",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_decloak[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_lose.mp3",
};

static const char g_CloakSounds[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_lose.mp3",
};


void CorruptedSpyMinion_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_decloak));   i++) { PrecacheSound(g_decloak[i]);   }
	for (int i = 0; i < (sizeof(g_CloakSounds));   i++) { PrecacheSound(g_CloakSounds[i]);   }
	PrecacheModel("models/freak_fortress_2/corruptedspy/corruptedspy_animated_funny_1.mdl");
}

methodmap CorruptedSpyMinion < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayCloakSound() {
	
		EmitSoundToAll(g_CloakSounds[GetRandomInt(0, sizeof(g_CloakSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCloakSound()");
		#endif
	}
	public void PlayDecloakSound() {
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public CorruptedSpyMinion(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CorruptedSpyMinion npc = view_as<CorruptedSpyMinion>(CClotBody(vecPos, vecAng, "models/freak_fortress_2/corruptedspy/corruptedspy_animated_funny_1.mdl", "0.65", "1000", ally, false, true, true ,true));
		
		i_NpcInternalId[npc.index] = CORRUPTEDSPYMINION;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, CorruptedSpyMinion_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 330.0;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		NPC_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		return npc;
	}
}

//TODO 
//Rewrite
public void CorruptedSpyMinion_ClotThink(int iNPC)
{
	CorruptedSpyMinion npc = view_as<CorruptedSpyMinion>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < 7225)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime())
				{
					//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime()+0.24;
					npc.m_flAttackHappens_bullshit = GetGameTime()+0.24;
					npc.m_flAttackHappenswillhappen = true;
				}
						
				if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
				{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
							{
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									
									if(target <= MaxClients)
										SDKHooks_TakeDamage(target, npc.index, npc.index, 30.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 120.0, DMG_CLUB, -1, _, vecHit);
									
									// Hit particle
									//npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
									
									// Hit sound
									npc.PlayMeleeHitSound();
									
									//Did we kill them?
									int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
									if(iHealthPost <= 0) 
									{
										//Yup, time to celebrate
										npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
									}
								} 
							}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.24;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.44;
					}
				}
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
			else
			{
				NPC_StartPathing(npc.index);
				npc.m_bPathing = true;
			}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
	
	if(npc.m_flDead_Ringer_Invis < GetGameTime() && npc.m_flDead_Ringer_Invis_bool)
	{
		npc.m_flDead_Ringer_Invis_bool = false;
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.PlayDecloakSound();
	}
}

public Action CorruptedSpyMinion_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CorruptedSpyMinion npc = view_as<CorruptedSpyMinion>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flDead_Ringer < GetGameTime())
	{
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		
		npc.m_flDead_Ringer_Invis = GetGameTime() + 2.0;
		npc.m_flDead_Ringer = GetGameTime() + 13.0;
		npc.m_flDead_Ringer_Invis_bool = true;
		
		npc.m_flNextMeleeAttack = GetGameTime() + 4.05;

		npc.PlayCloakSound();
	}
	
	if(!npc.m_flDead_Ringer_Invis_bool)
	{
		if (npc.m_flHeadshotCooldown < GetGameTime())
		{
			npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
	else
	{
		damage *= 0.5;
	}

	return Plugin_Changed;
}



public void CorruptedSpyMinion_NPCDeath(int entity)
{
	CorruptedSpyMinion npc = view_as<CorruptedSpyMinion>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, CorruptedSpyMinion_ClotThink);
}