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
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav"
};

void SeabornDefender_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Defender");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_defender");
	strcopy(data.Icon, sizeof(data.Icon), "ds_defender");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeabornDefender(vecPos, vecAng, team, data);
}

methodmap SeabornDefender < CClotBody
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
	
	public SeabornDefender(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		SeabornDefender npc = view_as<SeabornDefender>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "100000", ally, false));

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_CUSTOM_WALK_SPEAR");
		KillFeed_SetKillIcon(npc.index, "splendid_screen");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeabornDefender_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeabornDefender_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornDefender_ClotThink;
		
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iOverlordComboAttack = 0;
		

		npc.m_iWearable1 = npc.EquipItem("weapon_targe", "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		
		switch(Waves_GetRoundScale() % 3)
		{
			case 0:
			{
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 0, 255);
			}
			case 1:
			{
				SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
			}
			case 2:
			{
				SetEntityRenderColor(npc.m_iWearable1, 255, 0, 255, 255);
			}
		}

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/jul13_stormn_normn/jul13_stormn_normn.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		if(!StrContains(data, "normal"))
		{
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Defender");
		}
		else
		{
			SetEntityRenderColor(npc.index, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);
		}
		return npc;
	}
}

public void SeabornDefender_ClotThink(int iNPC)
{
	SeabornDefender npc = view_as<SeabornDefender>(iNPC);

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

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_flNextMeleeAttack = gameTime + 0.75;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 500.0 : 130.0, DMG_CLUB);
					}
				}

				delete swingTrace;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void SeabornDefender_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		SeabornDefender npc = view_as<SeabornDefender>(victim);

		bool hot;
		bool magic;
		bool pierce;
		
		if((damagetype & DMG_TRUEDAMAGE))
			return;

		if((damagetype & DMG_BLAST))
		{
			hot = true;
			pierce = true;
		}
		if((damagetype & DMG_BULLET))
		{
			pierce = true;
		}
		
		if(damagetype & DMG_PLASMA)
		{
			magic = true;
			pierce = true;
		}
		else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
		{
			magic = true;
		}

		switch(Waves_GetRoundScale() % 3)
		{
			case 0:
			{
				if(!pierce)
				{
					damage *= 0.1;
					
					damagePosition[2] += 30.0;
					npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
					damagePosition[2] -= 30.0;
				}
			}
			case 1:
			{
				if(hot)
				{
					damage *= 0.1;

					damagePosition[2] += 30.0;
					npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
					damagePosition[2] -= 30.0;
				}
			}
			case 2:
			{
				if(magic)
				{
					damage *= 0.1;

					damagePosition[2] += 30.0;
					npc.DispatchParticleEffect(npc.index, "medic_resist_match_fire_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
					damagePosition[2] -= 30.0;
				}
			}
		}
	}
}

void SeabornDefender_NPCDeath(int entity)
{
	SeabornDefender npc = view_as<SeabornDefender>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
