#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/headcrab_poison/ph_pain3.wav"
};

static const char g_HurtSound[][] = {
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav"
};

static const char g_IdleSound[][] = {
	"npc/headcrab_poison/ph_rattle1.wav",
	"npc/headcrab_poison/ph_rattle2.wav",
	"npc/headcrab_poison/ph_rattle3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"npc/headcrab_poison/ph_poisonbite1.wav",
	"npc/headcrab_poison/ph_poisonbite2.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"npc/headcrab_poison/ph_scream1.wav",
	"npc/headcrab_poison/ph_scream2.wav",
	"npc/headcrab_poison/ph_scream3.wav"
};

static int NPCId;
void ZSPoisonHeadcrab_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);

	PrecacheModel("models/headcrabblack.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Poison Headcrab");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_poisonheadcrab");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_poison_headcrab");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int ZSPoisonHeadcrab_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSPoisonHeadcrab(vecPos, vecAng, team);
}

methodmap ZSPoisonHeadcrab < CSeaBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
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
	
	public ZSPoisonHeadcrab(float vecPos[3], float vecAng[3], int ally)
	{
		ZSPoisonHeadcrab npc = view_as<ZSPoisonHeadcrab>(CClotBody(vecPos, vecAng, "models/headcrabblack.mdl", "1.25", "500", ally, false));
		// 3000 x 0.15
		// 4000 x 0.15

		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSPoisonHeadcrab_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSPoisonHeadcrab_OnTakeDamage;
		func_NPCThink[npc.index] = ZSPoisonHeadcrab_ClotThink;
		
		npc.m_flSpeed = 250.0;	// 1.9 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;

		return npc;
	}
}

public void ZSPoisonHeadcrab_ClotThink(int iNPC)
{
	ZSPoisonHeadcrab npc = view_as<ZSPoisonHeadcrab>(iNPC);

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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				npc.m_bAllowBackWalking = false;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, 0.0, DMG_CLUB, -1, _, vecHit);
						if(!HasSpecificBuff(target, "Envenomed"))
						{
							ApplyStatusEffect(npc.index, target, "Envenomed", 10.0);
							if(target <= MaxClients)
							{
								Force_ExplainBuffToClient(target, "Envenomed");
								SetEntProp(target, Prop_Data, "m_iHealth", 1);
								HealEntityGlobal(target, target, 250.0, 1.0, 20.0, HEAL_SELFHEAL);
							}
						}
						if (i_IsABuilding[target])
						{
							//use void a subtitute, it just reduces repair HP alot.
							Elemental_AddVoidDamage(target, npc.index, 2000, false, false);
						}
						if(b_ThisWasAnNpc[target])
						{
							//for some fucking reason these fucking npcs don't wanna get fucking affected by the fucking envenomed buff that I fucking made, fuck them.
							GetEntProp(target, Prop_Data, "m_iHealth");
							SetEntProp(target, Prop_Data, "m_iHealth", 1);
						}
						if(!i_IsABuilding[target] && !b_ThisWasAnNpc[target])
						{
							TF2_AddCondition(target, TFCond_LostFooting, 5.0);
							TF2_AddCondition(target, TFCond_MarkedForDeathSilent, 10.0);
							DoOverlay(target, "debug/yuv", 0);
							CreateTimer(15.0, Parasihtta_RemoveOverlay, GetClientUserId(target), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_bAllowBackWalking = true;
			int PrimaryThreatIndex = npc.m_iTarget;
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < 4000.0) //too close, back off!! Now!
			{
				npc.StartPathing();
				
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					float vBackoffPos[3];
					npc.m_flSpeed = 500.0;
					BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, 300.0, vBackoffPos);
					npc.SetGoalVector(vBackoffPos, true);
				}
			}
			else
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flSpeed = 250.0;
					npc.AddGesture("ACT_HEADCRAB_THREAT_DISPLAY");

					npc.PlayMeleeSound();

					npc.m_flAttackHappens = gameTime + 0.50;

					//npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					npc.m_flHeadshotCooldown = gameTime + 1.0;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action ZSPoisonHeadcrab_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	ZSPoisonHeadcrab npc = view_as<ZSPoisonHeadcrab>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void ZSPoisonHeadcrab_NPCDeath(int entity)
{
	ZSPoisonHeadcrab npc = view_as<ZSPoisonHeadcrab>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
}


