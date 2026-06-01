#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] =
{
	"weapons/demo_charge_windup1.wav",
	"weapons/demo_charge_windup2.wav",
	"weapons/demo_charge_windup3.wav"
};

void DwellerDemo_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dweller Demoman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dweller_demo");
	strcopy(data.Icon, sizeof(data.Icon), "ds_demo");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Dweller;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return DwellerDemo(vecPos, vecAng, team);
}

methodmap DwellerDemo < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(2.0, 3.0);
	}
	
	public DwellerDemo(float vecPos[3], float vecAng[3], int ally)
	{
		DwellerDemo npc = view_as<DwellerDemo>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_DWELLER;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_DWELLER;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = DwellerDemo_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = DwellerDemo_ClotThink;
		
		npc.m_bDissapearOnDeath = true;
		npc.m_flSpeed = 406.56;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_caber/c_caber.mdl");

		return npc;
	}
}

public void DwellerDemo_ClotThink(int iNPC)
{
	DwellerDemo npc = view_as<DwellerDemo>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
						KillFeed_SetKillIcon(npc.index, "ullapool_caber");
						SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB);

						if(!NpcStats_IsEnemySilenced(npc.index))
						{
							LastHitRef[npc.index] = -1;
							SmiteNpcToDeath(npc.index);
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

void DwellerDemo_NPCDeath(int entity)
{
	DwellerDemo npc = view_as<DwellerDemo>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		float startPosition[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition); 
		startPosition[2] += 45;

		KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");
		Explode_Logic_Custom(75.0, -1, npc.index, -1, startPosition, 150.0, _, _, true, _, false, 1.0, DwellerDemo_ExplodePost);

		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(startPosition[0]);
		pack_boom.WriteFloat(startPosition[1]);
		pack_boom.WriteFloat(startPosition[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
	}
}

public void DwellerDemo_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	float EnemyVecPos[3]; WorldSpaceCenter(victim, EnemyVecPos);
	ParticleEffectAt(EnemyVecPos, "water_bulletsplash01", 3.0);
	Elemental_AddNervousDamage(victim, attacker, RoundToCeil(damage * 2.0));
}
