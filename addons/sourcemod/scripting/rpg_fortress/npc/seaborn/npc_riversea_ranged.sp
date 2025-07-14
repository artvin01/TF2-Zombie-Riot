#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
};

static const char g_HurtSounds[][] =
{
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav"
};

void RiverSeaRanged_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "River Sea Epinephelus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_riversea_ranged");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RiverSeaRanged(client, vecPos, vecAng, team);
}

methodmap RiverSeaRanged < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleAlertedSounds[GetURandomInt() % sizeof(g_IdleAlertedSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetURandomInt() % sizeof(g_HurtSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
 	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public RiverSeaRanged(int client, float vecPos[3], float vecAng[3], int team)
	{
		RiverSeaRanged npc = view_as<RiverSeaRanged>(CClotBody(vecPos, vecAng, "models/zombie/classic.mdl", "1.0", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_ZOMBIE_TANTRUM");
		KillFeed_SetKillIcon(npc.index, "huntsman");
		i_NpcWeight[npc.index] = 1;

		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		SetEntityRenderColor(npc.index, 126, 126, 255, 255);

		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	RiverSeaRanged npc = view_as<RiverSeaRanged>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	SeaShared_Thinking(npc.index, 350.0, "ACT_WALK", "ACT_IDLE", /*42.5*/1.0, gameTime);

	int target = npc.m_iTarget;

	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
	
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				if(IsValidEnemy(npc.index, target))
				{
					npc.FaceTowards(vecTarget, 15000.0);
					
					npc.PlayMeleeHitSound();
					int entity = npc.FireArrow(vecTarget, 60.0 * Level[npc.index], 800.0, "models/weapons/w_bugbait.mdl");
					
					if(entity != -1)
					{
						if(IsValidEntity(f_ArrowTrailParticle[entity]))
							RemoveEntity(f_ArrowTrailParticle[entity]);

						SetEntityRenderColor(entity, 100, 100, 255, 255);
						
						WorldSpaceCenter(entity, vecMe);
						f_ArrowTrailParticle[entity] = ParticleEffectAt(vecMe, "rockettrail_bubbles", 3.0);
						SetParent(entity, f_ArrowTrailParticle[entity]);
						f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
					}
				}
			}
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, target, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(target);
			}

			npc.StartPathing();
		}

		npc.SetActivity("ACT_WALK");
		npc.m_bisWalking = true;
		npc.m_flSpeed = 187.5;

		if(distance < 250000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture((GetURandomInt() % 2) ? "ACT_ZOM_SWATLEFTMID" : "ACT_ZOM_SWATRIGHTMID");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 1.15;
				npc.m_flNextMeleeAttack = gameTime + 2.95;
				npc.m_flHeadshotCooldown = gameTime + 1.95;
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	RiverSeaRanged npc = view_as<RiverSeaRanged>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}