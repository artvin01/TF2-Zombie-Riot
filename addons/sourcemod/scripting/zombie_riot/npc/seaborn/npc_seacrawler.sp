#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/stunstick/alyx_stunner1.wav",
	"weapons/stunstick/alyx_stunner2.wav"
};

void SeaCrawler_MapStart()
{
	PrecacheSoundArray(g_MeleeAttackSounds);
}

methodmap SeaCrawler < CClotBody
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
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
	}
	
	public SeaCrawler(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		SeaCrawler npc = view_as<SeaCrawler>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.75", data[0] ? "5250" : "3750", ally, false, true));
		// 25000 x 0.15
		// 35000 x 0.15

		SetVariantInt(data[0] ? 15 : 7);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = data[0] ? SEACRAWLER_ALT : SEACRAWLER;
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_WALK");
		KillFeed_SetKillIcon(npc.index, "pumpkindeath");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		
		SDKHook(npc.index, SDKHook_Think, SeaCrawler_ClotThink);
		
		npc.m_flSpeed = 100.0;	// 0.4 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iAttacksTillReload = 6;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 50, 50, 255, 255);
		return npc;
	}
}

public void SeaCrawler_ClotThink(int iNPC)
{
	SeaCrawler npc = view_as<SeaCrawler>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
		
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		
		if(health < (maxhealth * npc.m_iAttacksTillReload / 7))
		{
			npc.m_iAttacksTillReload--;
			npc.PlayAngerSound();

			float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
			spawnRing_Vectors(vecMe, 100.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.4, 6.0, 0.1, 1, 800.0);
			Explode_Logic_Custom(i_NpcInternalId[npc.index] == SEACRAWLER_ALT ? 60.0 : 45.0, -1, npc.index, -1, vecMe, 400.0, _, _, true, _, false, 1.0, SeaCrawler_ExplodePost);
			// 300 x 0.15
			// 400 x 0.15
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
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
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public void SeaCrawler_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	ParticleEffectAt(WorldSpaceCenter(victim), "water_bulletsplash01", 3.0);
	SeaSlider_AddNeuralDamage(victim, attacker, RoundToCeil(damage));
}

public Action SeaCrawler_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	SeaCrawler npc = view_as<SeaCrawler>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaCrawler_NPCDeath(int entity)
{
	SeaCrawler npc = view_as<SeaCrawler>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	
	SDKUnhook(npc.index, SDKHook_Think, SeaCrawler_ClotThink);
}