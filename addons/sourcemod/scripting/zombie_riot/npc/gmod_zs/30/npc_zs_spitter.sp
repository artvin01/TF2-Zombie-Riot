#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/zombie_poison/pz_die2.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/fast_zombie/fz_alert_close1.wav",
};

static const char g_MeleeMissSounds[][] =
{
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/fast_zombie/leap1.wav",
};

void ZsSpitter_Precache()
{
	NPCData data;
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
	strcopy(data.Name, sizeof(data.Name), "ZS Spitter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_spitter");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_spitter");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ZsSpitter(vecPos, vecAng, team, data);
}

methodmap ZsSpitter < CSeaBody
{
	property bool m_bCarrier
	{
		public get()
		{
			return this.m_iMedkitAnnoyance == 2;
		}
	}
	property bool m_bElite
	{
		public get()
		{
			return this.m_iMedkitAnnoyance == 1;
		}
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	public ZsSpitter(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ZsSpitter npc = view_as<ZsSpitter>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "3200", ally, false));
		// 4400 x 0.15
		// 5000 x 0.15
		
		npc.SetElite(view_as<bool>(data[0]));
		i_NpcWeight[npc.index] = 1;
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = ZsSpitter_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZsSpitter_OnTakeDamage;
		func_NPCThink[npc.index] = ZsSpitter_ClotThink;
		
		npc.m_flSpeed = 231.0;	// 0.75 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 50, 50, 255, 255);
		return npc;
	}
}

public void ZsSpitter_ClotThink(int iNPC)
{
	ZsSpitter npc = view_as<ZsSpitter>(iNPC);
	
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(16);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_FLINCH", false);
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
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
				
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.PlayRangedSound();
				int entity = npc.FireArrow(vecTarget, npc.m_bElite ? 40.0 : 40.0, 800.0, "models/weapons/w_bugbait.mdl");
				// 280 * 0.15
				// 320 * 0.15
				
				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);

					SetEntityRenderColor(entity, 100, 100, 255, 255);
					WandProjectile_ApplyFunctionToEntity(entity, zs_spitter_StartTouch);
					
					WorldSpaceCenter(entity, vecTarget);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "rockettrail_bubbles", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}
		}

		if(distance < 250000.0 && npc.m_flNextMeleeAttack < gameTime)	// 2.5 * 200
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture((GetURandomInt() % 2) ? "ACT_ZOM_SWATLEFTMID" : "ACT_ZOM_SWATRIGHTMID");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.25;

				npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flNextMeleeAttack = gameTime + 3.0;
				npc.m_flHeadshotCooldown = gameTime + 2.0;
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
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
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static Action zs_spitter_StartTouch(int entity, int target)
{
    int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if(!IsValidEntity(owner))
        owner = 0;
    if(target > 0 && target < MAXENTITIES)    //did we hit something???
    {
        int inflictor = h_ArrowInflictorRef[entity];
        if(inflictor != -1)
            inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

        if(inflictor == -1)
            inflictor = owner;
            
        float DamageDeal = fl_rocket_particle_dmg[entity];
        if(ShouldNpcDealBonusDamage(target))
            DamageDeal *= h_BonusDmgToSpecialArrow[entity];
        KillFeed_SetKillIcon(owner, "ball");
        SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);    //acts like a kinetic rocket    
        if(target <= MaxClients && !IsInvuln(target))
            if(!HasSpecificBuff(target, "Fluid Movement"))
                TF2_StunPlayer(target, 2.0, 0.5, TF_STUNFLAG_SLOWDOWN);
        ApplyStatusEffect(owner, target, "Cellular Breakdown", NpcStats_VictorianCallToArms(owner) ? 7.5 : 5.0);
		Elemental_AddPheromoneDamage(target, owner, 15);
    }
    int particle = EntRefToEntIndex(i_WandParticle[entity]);
    if(IsValidEntity(particle))
        RemoveEntity(particle);
    RemoveEntity(entity);
    return Plugin_Handled;
}

public Action ZsSpitter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	ZsSpitter npc = view_as<ZsSpitter>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void ZsSpitter_NPCDeath(int entity)
{
	ZsSpitter npc = view_as<ZsSpitter>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
}
