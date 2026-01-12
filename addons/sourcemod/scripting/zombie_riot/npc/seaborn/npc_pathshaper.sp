#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav"
};

static const char g_HurtSounds[][] =
{
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav"
};

void Pathshaper_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Pathshaper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_pathshaper");
	strcopy(data.Icon, sizeof(data.Icon), "ds_pathshaper");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Pathshaper(vecPos, vecAng, team);
}

methodmap Pathshaper < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);	
	}
	
	public Pathshaper(float vecPos[3], float vecAng[3], int ally)
	{
		Pathshaper npc = view_as<Pathshaper>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.75", "35000", ally, false, true));
		// 35000 x 1.0
		
		SetVariantInt(31);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		func_NPCDeath[npc.index] = Pathshaper_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Pathshaper_OnTakeDamage;
		func_NPCThink[npc.index] = Pathshaper_ClotThink;
		
		npc.m_flSpeed = 250.0;	// 0.5 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iAttacksTillReload = 0;
		npc.m_iAttacksTillMegahit = 0;
		
		SetEntityRenderColor(npc.index, 55, 55, 255, 255);

		return npc;
	}
}

public void Pathshaper_ClotThink(int iNPC)
{
	Pathshaper npc = view_as<Pathshaper>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 8000.0 : 800.0, DMG_CLUB);
						// 800 x 0.5

						Custom_Knockback(npc.index, target, 750.0);
					}
				}

				delete swingTrace;

				if(++npc.m_iAttacksTillMegahit > 2)
				{
					int health = ReturnEntityMaxHealth(npc.index) * 4 / 7;
					Pathshaper_SpawnFractal(npc, health, 8);
					npc.m_iAttacksTillMegahit = 0;
				}
			}
		}

		if(distance < 22500.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_MELEE_ATTACK1");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.75;
				npc.m_flNextMeleeAttack = gameTime + 2.75;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void Pathshaper_OnTakeDamage(int victim, int attacker)
{
	if(attacker > 0)
	{
		Pathshaper npc = view_as<Pathshaper>(victim);
		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;

			if(++npc.m_iAttacksTillReload > 9)
			{
				int health = ReturnEntityMaxHealth(npc.index) * 4 / 7;
				Pathshaper_SpawnFractal(npc, health, 8);
				npc.m_iAttacksTillReload = 0;
			}
		}
	}
}

void Pathshaper_NPCDeath(int entityy)
{
	Pathshaper npc = view_as<Pathshaper>(entityy);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	int team = GetTeam(entityy);
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == PathshaperFractal_ID() && IsEntityAlive(entity) && GetTeam(entity) == team)
		{
			RequestFrame(KillNpc, i_ObjectsNpcsTotal[i]);
		}
	}
}

void Pathshaper_SpawnFractal(CClotBody npc, int health, int limit)
{
	int team = GetTeam(npc.index);
	int count;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == PathshaperFractal_ID() && IsEntityAlive(entity) && GetTeam(entity) == team)
		{
			if(++count == limit)
				return;
		}
	}

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int entity = NPC_CreateById(PathshaperFractal_ID(), -1, pos, ang, GetTeam(npc.index));
	if(entity > MaxClients)
	{
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);

		fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
	}
}
