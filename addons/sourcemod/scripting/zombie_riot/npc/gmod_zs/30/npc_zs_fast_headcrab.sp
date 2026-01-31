#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/headcrab/die1.wav",
	"npc/headcrab/die2.wav"
};

static const char g_HurtSound[][] = {
	"npc/headcrab/pain1.wav",
	"npc/headcrab/pain2.wav",
	"npc/headcrab/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/headcrab/alert1.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/headcrab/headbite.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"npc/headcrab/attack1.wav",
	"npc/headcrab/attack2.wav",
	"npc/headcrab/attack3.wav"
};

void FastHeadcrab_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);

	PrecacheModel("models/headcrab.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fast Headcrab");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_fast_headcrab");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_fast_headcrab");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FastHeadcrab(vecPos, vecAng, team);
}

methodmap FastHeadcrab < CSeaBody
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
	
	public FastHeadcrab(float vecPos[3], float vecAng[3], int ally)
	{
		FastHeadcrab npc = view_as<FastHeadcrab>(CClotBody(vecPos, vecAng, "models/headcrab.mdl", "1.25", "600", ally, false));
		// 3000 x 0.15
		// 4000 x 0.15

		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = FastHeadcrab_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = FastHeadcrab_OnTakeDamage;
		func_NPCThink[npc.index] = FastHeadcrab_ClotThink;
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 165, 0, 255);
		
		npc.m_flSpeed = 400.0;	// 1.9 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;

		return npc;
	}
}

public void FastHeadcrab_ClotThink(int iNPC)
{
	FastHeadcrab npc = view_as<FastHeadcrab>(iNPC);

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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
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
			if(flDistanceToTarget < 6000.0) //too close, back off!! Now!
			{
				npc.StartPathing();
				
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					float vBackoffPos[3];
					npc.m_flSpeed = 600.0;
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
					npc.m_flSpeed = 303.6;
					npc.AddGesture("ACT_RANGE_ATTACK1");

					/*
					switch(GetRandomInt(0,1))
					{
						case 0:
						{
							PluginBot_Jump(npc.index, vecTarget);
						}
						case 1:
						{

						}
					}
					*/

					PluginBot_Jump(npc.index, vecTarget);

					npc.PlayMeleeSound();

					npc.m_flAttackHappens = gameTime + 0.08;

					//npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					npc.m_flHeadshotCooldown = gameTime + 0.8;
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

public Action FastHeadcrab_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	FastHeadcrab npc = view_as<FastHeadcrab>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!NpcStats_IsEnemySilenced(victim))
	{
		if(!npc.bXenoInfectedSpecialHurt)
		{
			npc.bXenoInfectedSpecialHurt = true;
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			damage = 0.0;
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.5);
			return Plugin_Changed;
		}
	}
	return Plugin_Changed;
}

void FastHeadcrab_NPCDeath(int entity)
{
	FastHeadcrab npc = view_as<FastHeadcrab>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
}


