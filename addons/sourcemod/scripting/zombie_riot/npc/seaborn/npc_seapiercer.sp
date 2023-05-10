#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/headcrab_poison/ph_pain3.wav"
};

static const char g_HurtSound[][] =
{
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/headcrab_poison/ph_rattle1.wav",
	"npc/headcrab_poison/ph_rattle2.wav",
	"npc/headcrab_poison/ph_rattle3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/headcrab_poison/ph_scream1.wav",
	"npc/headcrab_poison/ph_scream2.wav",
	"npc/headcrab_poison/ph_scream3.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/headcrab/headbite.wav"
};

void SeaPiercer_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_HurtSound);

	PrecacheModel("models/headcrabblack.mdl");
}

methodmap SeaPiercer < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	public SeaPiercer(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		SeaPiercer npc = view_as<SeaPiercer>(CClotBody(vecPos, vecAng, "models/headcrabblack.mdl", "2.25", data[0] ? "1875" : "1350", ally, false, true));
		// 9000 x 0.15
		// 12500 x 0.15

		i_NpcInternalId[npc.index] = data[0] ? SEAPIERCER_ALT : SEAPIERCER;
		npc.SetActivity("ACT_RUN");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, SeaPiercer_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, SeaPiercer_ClotThink);
		
		npc.m_flSpeed = 187.5;	// 0.75 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 50, 50, 255, 255);
		
		npc.StartPathing();
		return npc;
	}
}

public void SeaPiercer_ClotThink(int iNPC)
{
	SeaPiercer npc = view_as<SeaPiercer>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						
						b_ThisNpcIsSawrunner[npc.index] = true;

						if(target <= MaxClients && i_HealthBeforeSuit[target] > 0)
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, 999999.9, DMG_DROWN); // Make it oneshot the enemy if they have the quantum armor
							Custom_Knockback(npc.index, target, 1000.0); // Kick them away.
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, i_NpcInternalId[npc.index] == SEAPIERCER_ALT ? 105.0 : 82.5, DMG_DROWN);
							// 550 x 0.15
							// 700 x 0.15
						}

						b_ThisNpcIsSawrunner[npc.index] = false;
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 22500.0)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_HEADCRAB_THREAT_DISPLAY");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.55;

				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flNextMeleeAttack = gameTime + 3.5;
				npc.m_flHeadshotCooldown = gameTime + 1.5;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action SeaPiercer_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	SeaPiercer npc = view_as<SeaPiercer>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaPiercer_NPCDeath(int entity)
{
	SeaPiercer npc = view_as<SeaPiercer>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, SeaPiercer_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, SeaPiercer_ClotThink);
}