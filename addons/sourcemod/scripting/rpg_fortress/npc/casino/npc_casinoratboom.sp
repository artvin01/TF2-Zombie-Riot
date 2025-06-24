#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSound[][] =
{
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav"
};

static const char g_IdleSound[][] =
{
	"npc/headcrab_poison/ph_idle1.wav",
	"npc/headcrab_poison/ph_idle2.wav",
	"npc/headcrab_poison/ph_idle3.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/headcrab/headbite.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/headcrab_poison/ph_scream1.wav",
	"npc/headcrab_poison/ph_scream2.wav",
	"npc/headcrab_poison/ph_scream3.wav"
};

void CasinoRatBoom_Setup()
{
	PrecacheModel("models/headcrab.mdl");
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infused Rat");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_casinoratboom");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CasinoRatBoom(client, vecPos, vecAng, team);
}

methodmap CasinoRatBoom < CClotBody
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
	public void PlayMeleeHitSound()
 	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public CasinoRatBoom(int client, float vecPos[3], float vecAng[3], int team)
	{
		CasinoRatBoom npc = view_as<CasinoRatBoom>(CClotBody(vecPos, vecAng, "models/headcrab.mdl", "1.15", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_IDLE");
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
	CasinoRatBoom npc = view_as<CasinoRatBoom>(iNPC);

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
	Npc_Base_Thinking(npc.index, 350.0, "ACT_RUN", "ACT_IDLE", 216.0, gameTime);

	int target = npc.m_iTarget;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
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
						KillFeed_SetKillIcon(npc.index, "bread_bite");

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, CasinoShared_GetDamage(npc, 0.7), DMG_CLUB, _, _, vecHit);

						if(!NpcStats_IsEnemySilenced(npc.index))
						{
							KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");

							makeexplosion(npc.index, vecHit, RoundFloat(CasinoShared_GetDamage(npc, 0.7)), 100, _, true);
						}
					}
				}
				delete swingTrace;
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

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_RANGE_ATTACK1");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 1.45;
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	CasinoRatBoom npc = view_as<CasinoRatBoom>(entity);
	//if(!npc.m_bGib)
	//	npc.PlayDeathSound();

	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		KillFeed_SetKillIcon(npc.index, "pumpkindeath");

		float pos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos); 
		pos[2] += 30;

		makeexplosion(npc.index, pos, RoundFloat(CasinoShared_GetDamage(npc, 0.3)), 100, _, true);
	}
}