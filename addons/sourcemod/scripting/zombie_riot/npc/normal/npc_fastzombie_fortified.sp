#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_leap_prepare[][] = {
	"npc/fast_zombie/leap1.wav",
};

static char g_leap_scream[][] = {
	"npc/fast_zombie/fz_scream1.wav",
};

static char g_IdleSounds[][] = {
	"npc/fast_zombie/idle1.wav",
	"npc/fast_zombie/idle2.wav",
	"npc/fast_zombie/idle3.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/fast_zombie/fz_alert_close1.wav",
	"npc/fast_zombie/fz_alert_far1.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/fast_zombie/fz_frenzy1.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpPrepare[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpSound[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

public void FortifiedFastZombie_OnMapStart_NPC()
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
	PrecacheModel("models/zombie/fast.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fortified Fast Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fastzombie_fortified");
	strcopy(data.Icon, sizeof(data.Icon), "norm_fast_zombie_forti");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FortifiedFastZombie(vecPos, vecAng, team);
}


methodmap FortifiedFastZombie < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		
	}
	
	
	public void PlayLeapPrepare() {
		
		EmitSoundToAll(g_leap_prepare[GetRandomInt(0, sizeof(g_leap_prepare) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayLeapDone() {
		
		EmitSoundToAll(g_leap_scream[GetRandomInt(0, sizeof(g_leap_scream) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeJumpPrepare() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_PlayMeleeJumpPrepare[GetRandomInt(0, sizeof(g_PlayMeleeJumpPrepare) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayMeleeJumpSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_PlayMeleeJumpSound[GetRandomInt(0, sizeof(g_PlayMeleeJumpSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	
	
	public FortifiedFastZombie(float vecPos[3], float vecAng[3], int ally)
	{
		FortifiedFastZombie npc = view_as<FortifiedFastZombie>(CClotBody(vecPos, vecAng, "models/zombie/fast.mdl", "1.15", "300", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		func_NPCDeath[npc.index] = FortifiedFastZombie_NPCDeath;
		func_NPCThink[npc.index] = FortifiedFastZombie_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;

		
		
		//IDLE
		npc.m_flSpeed = 400.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
		npc.m_flInJump = 0.0;
		
		npc.StartPathing();
		
		return npc;
	}
	
	
}


public void FortifiedFastZombie_ClotThink(int iNPC)
{
	FortifiedFastZombie npc = view_as<FortifiedFastZombie>(iNPC);
	
	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);		
		
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump < GetGameTime(npc.index) && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex)
			{
				npc.m_flInJump = GetGameTime(npc.index) + 0.65;
				
				npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.5;
				npc.PlayLeapPrepare();
			}
		}
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump > GetGameTime(npc.index))
		{
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayLeapDone();
			npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
			
		}
		if(npc.m_flInJump > GetGameTime(npc.index))
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.FaceTowards(vecTarget, 1000.0);
			
			return;
			
		}
			//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		//Target close enough to hit
		if(flDistanceToTarget < 10000)
		{
			//Look at target so we hit.
	//		npc.FaceTowards(vecTarget, 1000.0)
			
				//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack anim
				npc.AddGesture("ACT_MELEE_ATTACK1");
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
				{
							
					int target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, 12.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0, DMG_CLUB, -1, _, vecHit);
								
						// Hit particle
						
						
						// Hit sound
						npc.PlayMeleeSound();
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
			}
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		else
		{
			npc.StartPathing();
			
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
}

public void FortifiedFastZombie_NPCDeath(int entity)
{
	FortifiedFastZombie npc = view_as<FortifiedFastZombie>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
//	AcceptEntityInput(npc.index, "KillHierarchy");
}
