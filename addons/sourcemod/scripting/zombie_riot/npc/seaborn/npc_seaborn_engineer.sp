#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

void SeabornEngineer_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Engineer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_engineer");
	strcopy(data.Icon, sizeof(data.Icon), "ds_engi");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MISSION;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SeabornEngineer(vecPos, vecAng, team);
}

methodmap SeabornEngineer < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public SeabornEngineer(float vecPos[3], float vecAng[3], int ally)
	{
		SeabornEngineer npc = view_as<SeabornEngineer>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = SeabornEngineer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornEngineer_ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + GetRandomFloat(4.0, 6.0);
		npc.m_fbRangedSpecialOn = false;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_wrench/c_wrench.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/cyoa_pda/cyoa_pda.mdl");
		AcceptEntityInput(npc.m_iWearable2, "Disable");

		return npc;
	}
}

public void SeabornEngineer_ClotThink(int iNPC)
{
	SeabornEngineer npc = view_as<SeabornEngineer>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_fbRangedSpecialOn)
	{
		if(IsValidEntity(npc.m_iTargetAlly) && i_IsABuilding[npc.m_iTargetAlly])
		{
			if(!npc.m_iTarget)
			{
				KillFeed_SetKillIcon(npc.index, "obj_attachment_sapper");

				float trg_vec[3]; WorldSpaceCenter(npc.m_iTargetAlly, trg_vec );
				float self_vec[3]; WorldSpaceCenter(npc.index, self_vec);

				ParticleEffectAt(self_vec, "water_bulletsplash01", 3.0);
				ParticleEffectAt(trg_vec, "water_bulletsplash01", 3.0);

				int repair = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iRepair");
				if(repair < 1)
				{
					Elemental_AddNervousDamage(npc.m_iTargetAlly, npc.index, 75);
				}
				else
				{
					SetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iRepair", repair - 3);
				}

				npc.m_flNextThinkTime = gameTime + 0.4;
				return;
			}
			else
			{
				b_ThisEntityIgnored[npc.m_iTargetAlly] = false;
			}
		}
		
		
		b_thisNpcHasAnOutline[npc.index] = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flNextRangedAttack = FAR_FUTURE;
		npc.SetActivity("ACT_MP_RUN_MELEE");

		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
	}
	else if(npc.m_flNextRangedAttack < gameTime && !NpcStats_IsEnemySilenced(npc.index))
	{
		for(int i; i < i_MaxcountBuilding; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsBuilding[i]);
			if(entity != INVALID_ENT_REFERENCE)
			{
				//CClotBody building = view_as<CClotBody>(entity);
				if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
				{
					b_ThisEntityIgnored[entity] = true;

					b_thisNpcHasAnOutline[npc.index] = true;
					
					npc.m_iTarget = 0;
					npc.m_iTargetAlly = entity;
					npc.m_fbRangedSpecialOn = true;
					npc.m_flNextThinkTime = gameTime + 1.5;
					npc.StopPathing();
					npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");
					npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

					AcceptEntityInput(npc.m_iWearable1, "Disable");
					AcceptEntityInput(npc.m_iWearable2, "Enable");
					return;
				}
			}
		}

		npc.m_flNextRangedAttack = gameTime + 10.0;
	}
	
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
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
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
						KillFeed_SetKillIcon(npc.index, "wrench");

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 150.0 : 75.0, DMG_CLUB);
						Elemental_AddNervousDamage(target, npc.index, 15);
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

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.95;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void SeabornEngineer_NPCDeath(int entity)
{
	SeabornEngineer npc = view_as<SeabornEngineer>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(npc.m_fbRangedSpecialOn)
	{
		if(IsValidEntity(npc.m_iTargetAlly) && i_IsABuilding[npc.m_iTargetAlly])
			b_ThisEntityIgnored[npc.m_iTargetAlly] = false;
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
