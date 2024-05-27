#pragma semicolon 1
#pragma newdecls required

methodmap CombineShotgun < CombineSoldier
{
	public CombineShotgun(int client, float vecPos[3], float vecAng[3], int ally)
	{
		CombineShotgun npc = view_as<CombineShotgun>(BaseSquad(vecPos, vecAng, "models/combine_soldier.mdl", "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_SHOTGUN;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 6;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineShotgun_ClotThink);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_shotgun.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		return npc;
	}
}

public void CombineShotgun_ClotThink(int iNPC)
{
	CombineShotgun npc = view_as<CombineShotgun>(iNPC);

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
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				canWalk = false;
				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L5 = 105, E2 L10 = 120
						KillFeed_SetKillIcon(npc.index, "club");
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 3.0, DMG_CLUB, -1, _, vecTarget);
						npc.PlayFistHit();
					}
				}

				delete swingTrace;
			}
		}
		
		if(npc.m_flNextRangedAttack < gameTime)
		{
			float distance = GetVectorDistance(vecMe, vecTarget, true);

			if(distance > 50000.0 && npc.m_iTargetWalk)	// 224 HU
			{
				// Too far away to shoot
			}
			else
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTargetAttack);
				if(IsValidEnemy(npc.index, target))
				{
					if(npc.m_iAttacksTillReload > 0)
					{
						float eyePitch[3], vecDirShooting[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);

						if(BaseSquad_InFireRange(vecDirShooting[1], eyePitch[1]))
						{
							vecDirShooting[1] = eyePitch[1];

							npc.m_flNextRangedAttack = gameTime + 1.45;
							npc.m_iAttacksTillReload--;
							
							float vecRight[3], vecUp[3];
							GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);

							float vecDir[3];

							for(int i; i < 5; i++)
							{
								float x = GetRandomFloat( -0.075, 0.075 );
								float y = GetRandomFloat( -0.075, 0.075 );
								
								for(int a; a < 3; a++)
								{
									vecDir[a] = vecDirShooting[a] + x * vecRight[a] + y * vecUp[a]; 
								}

								NormalizeVector(vecDir, vecDir);
								
								// E2 L5 = 10.5, E2 L10 = 12
								KillFeed_SetKillIcon(npc.index, "shotgun_soldier");
								FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, Level[npc.index] * 0.25, 9000.0, DMG_BULLET, "bullet_tracer01_red");
							}

							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
							npc.PlayShotgunFire();
						}
					}
					else if(distance < 10000.0)	// 100 HU
					{
						npc.AddGesture("ACT_MELEE_ATTACK1");
						npc.PlayFistFire();

						npc.m_flAttackHappens = gameTime + 0.35;
						npc.m_flNextRangedAttack = gameTime + 0.85;
					}
				}
			}
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

	bool anger = BaseSquad_BaseAnim(npc, 247.00, "ACT_IDLE", "ACT_RUN_RIFLE", 247.00, "ACT_IDLE_ANGRY_SHOTGUN", "ACT_RUN_AIM_SHOTGUN");
	npc.PlayIdle(anger);

	// Reloads when not in combat or no ammo and can't go up to target
	if(!npc.m_bPathing && !npc.m_iTargetWalk && npc.m_flNextRangedAttack < gameTime && npc.m_iAttacksTillReload < (anger ? 1 : 6))
	{
		npc.AddGesture("ACT_RELOAD");
		npc.m_flNextRangedAttack = gameTime + 2.15;
		npc.m_iAttacksTillReload = 6;
		npc.PlayShotgunReload();
	}
}

void CombineShotgun_NPCDeath(int entity)
{
	CombineShotgun npc = view_as<CombineShotgun>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineShotgun_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
