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

void TidelinkedArchon_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tidelinked Archon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_tidelinkedarchon");
	strcopy(data.Icon, sizeof(data.Icon), "ds_archon");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TidelinkedArchon(vecPos, vecAng, team);
}

methodmap TidelinkedArchon < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	public TidelinkedArchon(float vecPos[3], float vecAng[3], int ally)
	{
		TidelinkedArchon npc = view_as<TidelinkedArchon>(CClotBody(vecPos, vecAng, "models/headcrabblack.mdl", "2.3", "20000", ally, false, true));
		// 20000 x 1.0

		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = TidelinkedArchon_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = TidelinkedArchon_OnTakeDamage;
		func_NPCThink[npc.index] = TidelinkedArchon_ClotThink;
		
		npc.m_flSpeed = 300.0;//150.0;	// 0.6 x 250
		npc.m_flMeleeArmor = 0.5;
		npc.m_flRangedArmor = 1.25;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		i_TargetAlly[npc.index] = -1;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		return npc;
	}
}

public void TidelinkedArchon_ClotThink(int iNPC)
{
	TidelinkedArchon npc = view_as<TidelinkedArchon>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(i_TargetAlly[npc.index] == -1)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth = ReturnEntityMaxHealth(npc.index) * 5;
		
		int entity = NPC_CreateByName("npc_tidelinkedbishop", -1, pos, ang, GetTeam(npc.index));
		if(entity > MaxClients)
		{
			i_TargetAlly[npc.index] = EntIndexToEntRef(entity);
			i_TargetAlly[entity] = EntIndexToEntRef(npc.index);
			view_as<CClotBody>(entity).m_bThisNpcIsABoss = npc.m_bThisNpcIsABoss;

			Zombies_Currently_Still_Ongoing++;	// FIXME
			SetEntProp(entity, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
			
			fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
			
			if(view_as<CClotBody>(entity).m_iWearable3 == -1)
			{
				view_as<CClotBody>(entity).m_iWearable3 = ConnectWithBeam(view_as<CClotBody>(entity).m_iWearable1, npc.index, 0, 55, 255, 5.0, 5.0, 0.0, "sprites/laserbeam.vmt");
			}
		}
	}
	
	if(b_NpcIsInvulnerable[npc.index])
	{
		int entity = EntRefToEntIndex(i_TargetAlly[npc.index]);
		if(entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity) || b_NpcIsInvulnerable[entity])
		{
			SmiteNpcToDeath(npc.index);
			return;
		}

		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = ReturnEntityMaxHealth(npc.index);

		health += maxhealth / 100;	// 20 seconds
		if(health >= maxhealth)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", maxhealth);

			b_NpcIsInvulnerable[npc.index] = false;
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_RUN");
		}
		else
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		}
		return;
	}

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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 6000.0 : 300.0, DMG_CLUB);
						// 600 x 0.5

						Elemental_AddNervousDamage(target, npc.index, 150);
						// 600 x 0.5 x 0.5
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

				npc.AddGesture("ACT_HEADCRAB_THREAT_DISPLAY");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.55;
				npc.m_flNextMeleeAttack = gameTime + 1.7;
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

public void TidelinkedArchon_DownedThink(int entity)
{
	TidelinkedArchon npc = view_as<TidelinkedArchon>(entity);
	npc.SetActivity("ACT_DIESIMPLE");
	npc.SetPlaybackRate(0.5);
	SDKUnhook(entity, SDKHook_Think, TidelinkedArchon_DownedThink);
}

void TidelinkedArchon_OnTakeDamage(int victim, int attacker, float damage)
{
	if(attacker > 0)
	{
		TidelinkedArchon npc = view_as<TidelinkedArchon>(victim);

		if(!b_NpcIsInvulnerable[npc.index] && (damage * 2.0) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			npc.m_iTarget = 0;
			npc.m_bisWalking = false;
			b_NpcIsInvulnerable[npc.index] = true;
			npc.StopPathing();

			SDKHook(victim, SDKHook_Think, TidelinkedArchon_DownedThink);
		}
		
		if(!b_NpcIsInvulnerable[npc.index] && npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
}

void TidelinkedArchon_NPCDeath(int entity)
{
	TidelinkedArchon npc = view_as<TidelinkedArchon>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}
