#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/antlion_guard/antlion_guard_die1.wav",
	"npc/antlion_guard/antlion_guard_die2.wav"
};

static char g_HurtSounds[][] = {
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav",
	"npc/headcrab_poison/ph_pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/headcrab_poison/ph_rattle1.wav",
	"npc/headcrab_poison/ph_rattle2.wav",
	"npc/headcrab_poison/ph_rattle3.wav",
	"npc/antlion/idle1.wav",
	"npc/antlion/idle2.wav",
	"npc/antlion/idle3.wav",
	"npc/antlion/idle4.wav",
	"npc/antlion/idle5.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/antlion_guard/angry1.wav",
	"npc/antlion_guard/angry2.wav",
	"npc/antlion_guard/angry3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/antlion_guard/shove1.wav",
	"npc/vort/foot_hit.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/antlion_guard/foot_light1.wav",
	"npc/antlion_guard/foot_light2.wav",
};

void ZSSphynx_OnMapStart_NPC()
{
	PrecacheModel("models/antlion_guard.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sphynx");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_sphynx");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_sphynx");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSound(g_DeathSounds[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSSphynx(vecPos, vecAng, team);
}
methodmap ZSSphynx < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 16.0);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeAttackSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	
	public ZSSphynx(float vecPos[3], float vecAng[3], int ally)
	{
		ZSSphynx npc = view_as<ZSSphynx>(CClotBody(vecPos, vecAng, "models/antlion_guard.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		func_NPCDeath[npc.index] = view_as<Function>(ZSSphynx_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ZSSphynx_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ZSSphynx_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 275.0;
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		npc.m_bDissapearOnDeath = false;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		return npc;
	}
}

public void ZSSphynx_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, view_as<ZSSphynx>(attacker) ? 3 : 2);
	// 140 x 0.05 x 0.15
	// 160 x 0.05 x 0.15
	// 140 x 0.1 x 0.15
}

public void ZSSphynx_ClotThink(int iNPC)
{
	ZSSphynx npc = view_as<ZSSphynx>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	ZSSphynx_ApplyBuffInLocation_Optimized(VecSelfNpcabs, GetTeam(npc.index), npc.index);

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_BIG_FLINCH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flDoingAnimation)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		Explode_Logic_Custom(1.0, -1, npc.index, -1, vecMe, 175.0, 150.0, 150.0, true, 14, false);
	}

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			npc.m_iTargetAlly = GetClosestTarget(npc.index);
		}
		
		if(npc.m_iTargetAlly > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(flDistanceToTarget > (0.0*0.0))
			{
				npc.StartPathing();
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_,vPredictedPos );
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetAlly);
				}
			}
			else
			{
				npc.StopPathing();
			}
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.5;
	}
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.25;
		ExpidonsaGroupHeal(npc.index, 40.0, 500, 9999.0, 1.0, false,Expidonsa_DontHealSameIndex);		
		ChaosSupporter npc1 = view_as<ChaosSupporter>(npc.index);
		float ProjectileLoc[3];
		GetEntPropVector(npc1.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 0, 125, 0, 200, 1, 0.3, 5.0, 8.0, 3, 40.0 * 2.0);	
		npc1.PlayHealSound();
	}
	
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ZSSphynxSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}
#define ZSSphynx_RANGE 350.0

void ZSSphynx_ApplyBuffInLocation_Optimized(float BannerPos[3], int Team, int iMe = 0)
{
    // 거리 제곱값을 미리 상수로 계산 (루프 밖에서 1번만)
    float rangeSq = ZSSphynx_RANGE * ZSSphynx_RANGE; 
    float targPos[3];

    // 1. 플레이어 루프
    for(int ally=1; ally<=MaxClients; ally++)
    {
        if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
        {
            GetClientAbsOrigin(ally, targPos);
            // 단순 X, Y 거리 필터링 (선택 사항)
            if (FloatAbs(BannerPos[0] - targPos[0]) > ZSSphynx_RANGE) continue; 
            
            if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
            {
                ApplyStatusEffect(ally, ally, "Godly Motivation", 1.0);
            }
        }
    }

    // 2. NPC 루프 (초기화 및 활성 카운트 적용)
    for(int i = 0; i < i_MaxcountNpcTotal; i++) // 0으로 명확히 초기화
    {
        int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
        
        // 유효성 검사를 먼저 수행하여 무거운 연산을 피함
        if (ally != -1 && IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally)
        {
            GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
            if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
            {
                ApplyStatusEffect(ally, ally, "Godly Motivation", 1.0);
            }
        }
    }
}

public Action ZSSphynx_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZSSphynx npc = view_as<ZSSphynx>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ZSSphynx_NPCDeath(int entity)
{
	ZSSphynx npc = view_as<ZSSphynx>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}
public Action Timer_RemoveEntityZSSphynx(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("env_sawblood", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		//TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

void ZSSphynxSelfDefense(ZSSphynx npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {0.0 ,0.0, 0.0};
			static float MinVec[3] = {-0.0 ,-0.0, -0.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 10.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;

			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.AddGesture("ACT_MELEE_ATTACK1");

				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
}