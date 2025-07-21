#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/headcrab/die1.wav",
	"npc/headcrab/die2.wav"
};

static const char g_HurtSound[][] =
{
	"npc/headcrab/pain1.wav",
	"npc/headcrab/pain2.wav",
	"npc/headcrab/pain3.wav"
};

static const char g_IdleSound[][] =
{
	"npc/headcrab/idle1.wav",
	"npc/headcrab/idle2.wav",
	"npc/headcrab/idle3.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/headcrab/headbite.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/headcrab/attack1.wav",
	"npc/headcrab/attack2.wav",
	"npc/headcrab/attack3.wav"
};

void CasinoRat_Setup()
{
	PrecacheModel("models/headcrabclassic.mdl");
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rat");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_casinorat");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CasinoRat(client, vecPos, vecAng, team);
}

methodmap CasinoRat < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetURandomInt() % sizeof(g_IdleSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetURandomInt() % sizeof(g_HurtSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	
	public CasinoRat(int client, float vecPos[3], float vecAng[3], int team)
	{
		CasinoRat npc = view_as<CasinoRat>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.15", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_IDLE");
		npc.AddGesture("ACT_HEADCRAB_BURROW_OUT");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		i_NpcWeight[npc.index] = 0;

		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	CasinoRat npc = view_as<CasinoRat>(iNPC);

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

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(npc.index, 350.0, "ACT_RUN", "ACT_IDLE", 100.0, gameTime);

	int target = npc.m_iTarget;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			if(IsValidEnemy(npc.index, target))
			{
				float vecTarget[3]; 
				WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.m_flAttackHappens = 0.0;

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, CasinoShared_GetDamage(npc, 1.0), DMG_CLUB, _, _, vecHit);
					}
				}
				delete swingTrace;
			}

			if(npc.m_flAttackHappens && (npc.m_flAttackHappens + 0.3) < gameTime)
			{
				// Attack lasts for 0.3s until it hits something
				npc.m_flAttackHappens = 0.0;
			}
		}
	}

	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
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
		npc.SetActivity("ACT_RUN");
		npc.m_bisWalking = true;

		if(distance < (300.0 * 300.0) && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_RANGE_ATTACK1");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.45;
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 2.05;

				if(!NpcStats_IsEnemySilenced(npc.index))
					PluginBot_Jump(npc.index, vecTarget);
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	CasinoRat npc = view_as<CasinoRat>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}