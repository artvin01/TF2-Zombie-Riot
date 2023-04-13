#pragma semicolon 1
#pragma newdecls required

methodmap CombinePistol < CombinePolice
{
	public CombinePistol(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombinePistol npc = view_as<CombinePistol>(CombinePolice(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_PISTOL;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		npc.m_flNextMeleeAttack = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 12;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, CombinePistol_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombinePistol_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_stunbaton.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		return npc;
	}
}

public void CombinePistol_ClotThink(int iNPC)
{
	ZombiefiedCombineSwordsman npc = view_as<ZombiefiedCombineSwordsman>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	float vecMe[3];
	vecMe = WorldSpaceCenter(npc.index);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = view_as<bool>(npc.m_iTargetWalk);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);

		bool shouldGun = !npc.m_iTargetWalk;

		for(int i = MaxClients + 1; i < MAXENTITIES; i++) 
		{
			if(i != entity)
			{
				BaseSquad ally = view_as<BaseSquad>(i);
				if(ally.m_bIsSquad && ally.m_iTargetAttack == npc.m_iTargetAttack && !npc.m_bRanged)
				{
					shouldGun = true;	// An ally rushing with a melee, I should cover them
					break;
				}
			}
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(!shouldGun)
		{
			if(distance > (npc.m_bRanged ? 70000.0 : 125000.0))	// 265, 355  HU
			{
				shouldGun = true;
			}
		}

		if(shouldGun)
		{
			if(!npc.m_bRanged)
			{
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				npc.m_bRanged = true;
			}

			if(npc.m_flNextRangedAttack < gameTime)
			{
				if(distance > 4000000.0 && npc.m_iTargetWalk)	// 2000 HU
				{
					// Too far away to shoot
				}
				else if(npc.m_iAttacksTillReload < 1)
				{
					canWalk = false;
					
					npc.AddGesture("ACT_RELOAD_PISTOL");
					npc.m_flNextRangedAttack = gameTime + 1.35;
					npc.m_iAttacksTillReload = 12;
					npc.PlayPistolReload();
				}
				else if(IsValidEnemy(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
				{
					npc.FaceTowards(vecTarget, 2000.0);
					canWalk = false;

					npc.m_flNextRangedAttack = gameTime + 0.75 - (Level[npc.index] * 0.015);	// E2 L0 = 0.3, E2 L5 = 0.225  (Note: Rounds to 0.1 cause think)
					npc.m_iAttacksTillReload--;
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x = GetRandomFloat( -0.03, 0.03 );
					float y = GetRandomFloat( -0.03, 0.03 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];
					for(int i; i < 3; i++)
					{
						vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
					}

					NormalizeVector(vecDir, vecDir);
					
					// E2 L0 = 10.5, E2 L5 = 12.25
					FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, Level[npc.index] * 0.35, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
					npc.PlayPistol();
				}
			}
			else
			{
				npc.FaceTowards(vecTarget, 1500.0);
				canWalk = false;
			}
		}
		else
		{
			if(npc.m_bRanged)
			{
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				npc.m_bRanged = false;
				npc.m_flAttackHappens = 0.0;
			}
			
			if(npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					canWalk = false;
					npc.FaceTowards(vecTarget, 20000.0);

					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
					{
						int target = TR_GetEntityIndex(swingTrace);
						if(IsValidEnemy(target))
						{
							TR_GetEndPosition(vecTarget, swingTrace);

							// E2 L0 = 90, E2 L5 = 105
							SDKHooks_TakeDamage(target, npc.index, npc.index, Level[client] * 3.0, DMG_CLUB, -1, _, vecTarget);
							if(target <= MaxClients)
								Stats_AddNeuralDamage(target, npc.index, RoundToFloor(Level[client] * 0.45));	// (15% of dmg)
							
							npc.PlayStunStickHit();
						}
					}

					delete swingTrace;
				}
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(distance < 10000.0 && IsValidEnemy(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))	// 100 HU
				{
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.PlayStunStickSwing();

					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.05;
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

	bool anger = BaseSquad_BaseAnim(npc, 66.33, npc.m_bRanged ? "ACT_IDLE_PISTOL" : "ACT_IDLE", npc.m_bRanged ? "ACT_WALK_PISTOL" : "ACT_WALK_ANGRY", 212.24, npc.m_bRanged ? "ACT_IDLE_ANGRY_PISTOL" : "ACT_IDLE_ANGRY_MELEE", npc.m_bRanged ? "ACT_RUN_PISTOL" : "ACT_RUN");
	npc.PlayIdle(anger);
}