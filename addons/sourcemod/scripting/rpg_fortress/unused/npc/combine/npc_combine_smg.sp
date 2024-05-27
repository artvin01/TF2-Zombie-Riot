#pragma semicolon 1
#pragma newdecls required

methodmap CombineSMG < CombinePolice
{
	public CombineSMG(int client, float vecPos[3], float vecAng[3], int ally)
	{
		CombineSMG npc = view_as<CombineSMG>(BaseSquad(vecPos, vecAng, "models/police.mdl", "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_SMG;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "smg");

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 45;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineSMG_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_smg1.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		return npc;
	}
}

public void CombineSMG_ClotThink(int iNPC)
{
	CombineSMG npc = view_as<CombineSMG>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.PlayHurt();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	float vecMe[3];
	vecMe = WorldSpaceCenterOld(npc.index);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = (npc.m_iTargetWalk || !npc.m_iTargetAttack);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenterOld(npc.m_iTargetAttack);
		
		if(npc.m_flNextRangedAttack < gameTime)
		{
			float distance = GetVectorDistance(vecMe, vecTarget, true);

			if(distance > 100000.0 && npc.m_iTargetWalk)	// 316 HU
			{
				// Too far away to shoot
			}
			else if(npc.m_iAttacksTillReload < 1)
			{
				canWalk = false;
				
				npc.AddGesture("ACT_RELOAD_SMG1");
				npc.m_flNextRangedAttack = gameTime + 1.75;
				npc.m_iAttacksTillReload = 45;
				npc.PlaySMGReload();
			}
			else
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTargetAttack);
				if(IsValidEnemy(npc.index, target))
				{
					npc.FaceTowards(vecTarget, 2000.0);
					canWalk = false;

					float eyePitch[3], vecDirShooting[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);

					if(BaseSquad_InFireRange(vecDirShooting[1], eyePitch[1]))
					{
						vecDirShooting[1] = eyePitch[1];

						//npc.m_flNextRangedAttack = gameTime + 0.09;
						npc.m_iAttacksTillReload--;
						
						float x = GetRandomFloat( -0.1, 0.1 );
						float y = GetRandomFloat( -0.1, 0.1 );
						
						float vecRight[3], vecUp[3];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];
						for(int i; i < 3; i++)
						{
							vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
						}

						NormalizeVector(vecDir, vecDir);
						
						// E2 L0 = 3.75, E2 L5 = 4.375
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, Level[npc.index] * 0.10, 9000.0, DMG_BULLET, "bullet_tracer01_red");
						
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
						npc.PlaySMGFire();
					}
				}
			}
		}
		else
		{
			npc.FaceTowards(vecTarget, 1500.0);
			canWalk = false;
		}
	}

	if(canWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe);
	}
	else
	{
		npc.StopPathing();
	}

	bool anger = BaseSquad_BaseAnim(npc, 66.33, "ACT_IDLE_SMG", "ACT_WALK_RIFLE", 212.24, "ACT_IDLE_ANGRY_SMG1", "ACT_RUN_AIM_RIFLE");
	npc.PlayIdle(anger);

	if(!anger && !npc.m_bPathing && npc.m_iAttacksTillReload < 45)
	{
		npc.AddGesture("ACT_RELOAD_SMG1");
		npc.m_flNextRangedAttack = gameTime + 1.75;
		npc.m_iAttacksTillReload = 45;
		npc.PlaySMGReload();
	}
}

void CombineSMG_NPCDeath(int entity)
{
	CombineSMG npc = view_as<CombineSMG>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineSMG_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
