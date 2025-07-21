#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};


static const char g_IdleAlertedSounds[][] =
{
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav"
};

static const char g_MeleeAttackBackstabSounds[][] =
{
	"player/spy_shield_break.wav",
};

void CautusOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cautus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cautus");
	strcopy(data.Icon, sizeof(data.Icon), "scout_jumping");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Cautus(vecPos, vecAng, team);
}

methodmap Cautus < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeBackstabSound(int target)
	{
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(target <= MaxClients)
		{
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public Cautus(float vecPos[3], float vecAng[3], int ally)
	{
		Cautus npc = view_as<Cautus>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "20000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 320.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_knife/c_knife.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_ttg_max.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/sf14_the_rogues_rabbit/sf14_the_rogues_rabbit.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/spy/grfs_spy.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2016_showstopper/hwn2016_showstopper.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Cautus npc = view_as<Cautus>(iNPC);

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

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.IsOnGround())
	{
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
	}
	else
	{
		npc.m_flMeleeArmor = 0.15;
		npc.m_flRangedArmor = 0.15;
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
					if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
					{
						target = TR_GetEntityIndex(swingTrace);
						if(target > 0)
						{
							float damage = 100.0;
							if(ShouldNpcDealBonusDamage(target))
								damage *= 5.0;
							
							if(Rogue_Paradox_RedMoon() || (IsBehindAndFacingTarget(npc.index, target) && !NpcStats_IsEnemySilenced(npc.index)))
							{
								npc.PlayMeleeBackstabSound(target);
								npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
								KillFeed_SetKillIcon(npc.index, "backstab");
								damage *= 4.0;
							}
							else
							{
								npc.PlayMeleeHitSound();
								npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
								KillFeed_SetKillIcon(npc.index, "knife");
							}

							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						}
					}

					delete swingTrace;

					npc.m_flNextMeleeAttack = gameTime + 1.05;
				}
			}
			else if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5) && distance < 1000000.0)	// 1000 HU
			{
				vecTarget[2] += 300.0;
				PluginBot_Jump(npc.index, vecTarget);
				npc.m_flNextMeleeAttack = gameTime + 2.45;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	Cautus npc = view_as<Cautus>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}