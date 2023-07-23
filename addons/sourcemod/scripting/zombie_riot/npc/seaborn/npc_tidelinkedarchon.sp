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
	
	public TidelinkedArchon(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		TidelinkedArchon npc = view_as<TidelinkedArchon>(CClotBody(vecPos, vecAng, "models/headcrabblack.mdl", "2.3", "20000", ally, false, true));
		// 20000 x 1.0

		i_NpcInternalId[npc.index] = TIDELINKED_ARCHON;
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, TidelinkedArchon_ClotThink);
		
		npc.m_flSpeed = 300.0;//150.0;	// 0.6 x 250
		npc.m_flMeleeArmor = 0.5;
		npc.m_flRangedArmor = 1.25;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iTargetAlly = -1;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
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

	if(npc.m_iTargetAlly == -1)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 5;
		
		int entity = Npc_Create(TIDELINKED_BISHOP, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
		if(entity > MaxClients)
		{
			npc.m_iTargetAlly = EntIndexToEntRef(entity);
			view_as<CClotBody>(entity).m_iTargetAlly = EntIndexToEntRef(npc.index);
			view_as<CClotBody>(entity).m_bThisNpcIsABoss = npc.m_bThisNpcIsABoss;

			Zombies_Currently_Still_Ongoing++;
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
		int entity = EntRefToEntIndex(npc.m_iTargetAlly);
		if(entity == INVALID_ENT_REFERENCE || b_NpcIsInvulnerable[entity])
		{
			SDKHooks_TakeDamage(npc.index, 0, 0, 9999999.9, DMG_SLASH);
			return;
		}

		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

		health += maxhealth / 200;	// 20 seconds
		if(health > maxhealth)
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
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
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

						SeaSlider_AddNeuralDamage(target, npc.index, 150);
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
		
		if(b_NpcIsInvulnerable[npc.index])
		{
			damage = 0.0;
		}
		else if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
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
	
	SDKUnhook(npc.index, SDKHook_Think, TidelinkedArchon_ClotThink);
}