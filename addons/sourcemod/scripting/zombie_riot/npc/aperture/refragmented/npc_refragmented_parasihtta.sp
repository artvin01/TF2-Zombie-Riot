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

void Parasihtta_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);

	PrecacheModel("models/headcrabblack.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Parasihtta");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_parasihtta");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Parasihtta(vecPos, vecAng, team);
}

methodmap Parasihtta < CClotBody
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
	
	public Parasihtta(float vecPos[3], float vecAng[3], int ally)
	{
		Parasihtta npc = view_as<Parasihtta>(CClotBody(vecPos, vecAng, "models/headcrabblack.mdl", "1.25", "1000", ally, false));
		// 3000 x 0.15
		// 4000 x 0.15

		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = Parasihtta_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Parasihtta_OnTakeDamage;
		func_NPCThink[npc.index] = Parasihtta_ClotThink;
		
		npc.m_flSpeed = 250.0;	// 1.9 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;

		npc.m_flMeleeArmor = 0.10;
		npc.m_flRangedArmor = 0.10;

		TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
		TE_WriteNum("m_bControlPoint1", npc.index);	
		TE_SendToAll();

		SetEntityRenderMode(npc.index, RENDER_GLOW);
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
		DispatchKeyValue(npc.index, "preset", "25");

		return npc;
	}
}

public Action Parasihtta_RemoveOverlay(Handle helpmeimblind, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
		DoOverlay(client, "");
		
	return Plugin_Continue;
}

public void Parasihtta_ClotThink(int iNPC)
{
	Parasihtta npc = view_as<Parasihtta>(iNPC);

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

	float vecTarget2[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance2 = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(distance2 < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		npc.PlayHurtSound();
		SDKHooks_TakeDamage(npc.index, npc.m_iTarget, npc.m_iTarget, 50.0, DMG_TRUEDAMAGE, -1, _, vecMe, true);
		//Explode_Logic_Custom(10.0, npc.index, npc.index, -1, vecMe, 15.0, _, _, false, 1, false);
		SetEntityRenderColor(npc.index, 180, 0, 0, 200);
	}
	if(distance2 > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
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
						ApplyStatusEffect(npc.index, target, "Envenomed", 10.0);
						if (i_IsABuilding[target])
						{
							//use void a subtirute, it just reduces repair HP alot.
							Elemental_AddVoidDamage(target, npc.index, 1000, false, false);
						}
						
						if (!i_IsABuilding[target] && !b_ThisWasAnNpc[target])
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
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action Parasihtta_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	Parasihtta npc = view_as<Parasihtta>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void Parasihtta_NPCDeath(int entity)
{
	Parasihtta npc = view_as<Parasihtta>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
}


