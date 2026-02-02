#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

void SeabornGuard_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_guard");
	strcopy(data.Icon, sizeof(data.Icon), "ds_guard");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeabornGuard(vecPos, vecAng, team, data);
}

methodmap SeabornGuard < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeabornGuard(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		SeabornGuard npc = view_as<SeabornGuard>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "40000", ally, false));

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_CUSTOM_WALK_SWORD");
		KillFeed_SetKillIcon(npc.index, "claidheamohmor");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeabornGuard_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornGuard_ClotThink;
		
		npc.m_flSpeed = 250.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iOverlordComboAttack = 0;
		

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/soldier/sum20_breach_and_bomb/sum20_breach_and_bomb.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop/player/items/medic/hw2013_spacemans_suit/hw2013_spacemans_suit.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		if(!StrContains(data, "normal"))
		{
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Guard");
		}
		else
		{
			SetEntityRenderColor(npc.index, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable3, 155, 155, 255, 255);
		}

		return npc;
	}
}

public void SeabornGuard_ClotThink(int iNPC)
{
	SeabornGuard npc = view_as<SeabornGuard>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						float attack = 200.0;

						if(npc.m_iOverlordComboAttack == 2 || ShouldNpcDealBonusDamage(target))
							attack *= 4.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, attack, DMG_CLUB);

						switch(++npc.m_iOverlordComboAttack)
						{
							case 2:
							{
								SetEntityRenderColor(npc.m_iWearable1, 255, 55, 55, 255);

								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(attack * 0.25));
							}
							case 3:
							{
								SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

								npc.m_iOverlordComboAttack = 0;
								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(attack));
							}
							default:
							{
								SetEntityRenderColor(npc.m_iWearable1, 255, 200, 200, 255);

								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(attack * 0.25));
							}
						}
					}
				}

				delete swingTrace;
			}
		}

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flNextMeleeAttack = gameTime + 0.6;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_CUSTOM_ATTACK_SWORD");
				npc.m_flAttackHappens = gameTime + 0.25;
				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flHeadshotCooldown = gameTime + 0.95;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	if(npc.m_iOverlordComboAttack && NpcStats_IsEnemySilenced(npc.index))
	{
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		npc.m_iOverlordComboAttack = 0;
	}

	npc.PlayIdleSound();
}

void SeabornGuard_NPCDeath(int entity)
{
	SeabornGuard npc = view_as<SeabornGuard>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
