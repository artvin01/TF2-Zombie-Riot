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
	
	public SeabornEngineer(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SeabornEngineer npc = view_as<SeabornEngineer>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "10000", ally));
		
		i_NpcInternalId[npc.index] = SEABORN_ENGINEER;
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		SDKHook(npc.index, SDKHook_Think, SeabornEngineer_ClotThink);
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + GetRandomFloat(4.0, 6.0);
		npc.m_fbRangedSpecialOn = false;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
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
			if(!npc.m_iTarget && b_bBuildingIsPlaced[npc.m_iTargetAlly])
			{
				KillFeed_SetKillIcon(npc.index, "obj_attachment_sapper");

				ParticleEffectAt(WorldSpaceCenter(npc.index), "water_bulletsplash01", 3.0);
				ParticleEffectAt(WorldSpaceCenter(npc.m_iTargetAlly), "water_bulletsplash01", 3.0);

				int repair = Building_GetBuildingRepair(npc.m_iTargetAlly);
				if(repair < 1)
				{
					SeaSlider_AddNeuralDamage(npc.m_iTargetAlly, npc.index, 75);
				}
				else
				{
					Building_SetBuildingRepair(npc.m_iTargetAlly, repair - 150);
				}

				npc.m_flNextThinkTime = gameTime + 0.4;
				return;
			}
			else
			{
				b_ThisEntityIgnored[npc.m_iTargetAlly] = false;
			}
		}
		
		if(!npc.m_bThisNpcIsABoss && !b_thisNpcHasAnOutline[npc.index])
			GiveNpcOutLineLastOrBoss(npc.index, false);
		
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
			int entity = EntRefToEntIndex(i_ObjectsBuilding[i]);
			if(entity != INVALID_ENT_REFERENCE)
			{
				CClotBody building = view_as<CClotBody>(entity);
				if(!building.bBuildingIsStacked && building.bBuildingIsPlaced && !b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
				{
					b_ThisEntityIgnored[entity] = true;

					if(!npc.m_bThisNpcIsABoss && !b_thisNpcHasAnOutline[npc.index])
						GiveNpcOutLineLastOrBoss(npc.index, true);
					
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
					if(target > 0)
					{
						KillFeed_SetKillIcon(npc.index, "wrench");

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 150.0 : 75.0, DMG_CLUB);
						SeaSlider_AddNeuralDamage(target, npc.index, 15);
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
	
	SDKUnhook(npc.index, SDKHook_Think, SeabornEngineer_ClotThink);
}