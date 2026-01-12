#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};

void SeabornSoldier_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Soldier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_soldier");
	strcopy(data.Icon, sizeof(data.Icon), "ds_soldier");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SeabornSoldier(vecPos, vecAng, team);
}

methodmap SeabornSoldier < CClotBody
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
	
	public SeabornSoldier(float vecPos[3], float vecAng[3], int ally)
	{
		SeabornSoldier npc = view_as<SeabornSoldier>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "8000", ally));
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "demokatana");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = SeabornSoldier_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornSoldier_ClotThink;
		
		npc.m_flSpeed = 240.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl");

		return npc;
	}
}

public void SeabornSoldier_ClotThink(int iNPC)
{
	SeabornSoldier npc = view_as<SeabornSoldier>(iNPC);

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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 110.0, DMG_CLUB);
						Elemental_AddNervousDamage(target, npc.index, 22);

						if(!NpcStats_IsEnemySilenced(npc.index) && !IsValidEnemy(npc.index, target))	// Killed target, spawn 3 copies
						{
							int health = ReturnEntityMaxHealth(npc.index);

							if(!HasSpecificBuff(npc.index, "Growth Blocker"))
								SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
							
							float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
							float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
							int team = GetTeam(npc.index);

							fl_Extra_Speed[npc.index] *= 1.25;
							fl_Extra_Damage[npc.index] *= 1.1;

							for(int i; i < 5; i++)
							{
								if(MaxEnemiesAllowedSpawnNext(1) <= (EnemyNpcAlive - EnemyNpcAliveStatic))
								{
									fl_Extra_Speed[npc.index] *= 1.1;
									fl_Extra_Damage[npc.index] *= 1.05;
									SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 1.1));
									SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 1.1));
									continue;
								}

								int entity = NPC_CreateById(i_NpcInternalId[npc.index], -1, pos, ang, team);
								if(entity > MaxClients)
								{
									if(team != TFTeam_Red)
										NpcAddedToZombiesLeftCurrently(entity, true);
									
									SetEntProp(entity, Prop_Data, "m_iHealth", health);
									SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
									
									fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
									fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
									fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
									fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
								}
							}
						}
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

void SeabornSoldier_NPCDeath(int entity)
{
	SeabornSoldier npc = view_as<SeabornSoldier>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
