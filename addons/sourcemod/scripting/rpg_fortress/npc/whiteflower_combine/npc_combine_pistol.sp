#pragma semicolon 1
#pragma newdecls required

void OnMapStartCombinePistol()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Enforcer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_pistoleer");
	data.Func = ClotSummon;
	NPC_Add(data);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CombinePistol(vecPos, vecAng, team);
}
methodmap CombinePistol < CombinePolice
{
	public CombinePistol(float vecPos[3], float vecAng[3], int ally)
	{
		CombinePistol npc = view_as<CombinePistol>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = true;

		npc.m_flNextMeleeAttack = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 18;
		npc.m_bisWalking = true;
		
		func_NPCDeath[npc.index] = CombinePistol_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BaseSquad_TakeDamage;
		func_NPCThink[npc.index] = CombinePistol_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_stunbaton.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		return npc;
	}
}

public void CombinePistol_ClotThink(int iNPC)
{
	CombinePistol npc = view_as<CombinePistol>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurt();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// Due to animation bug, we force switch our idle anim
	bool forceWalk = view_as<bool>(npc.m_iTargetAttack);

	float vecMe[3];
	WorldSpaceCenter(npc.index, vecMe);
	BaseSquad_BaseThinking(npc, vecMe);

	// Due to animation bug, we force switch our idle anim
	forceWalk = (forceWalk != view_as<bool>(npc.m_iTargetAttack));

	bool canWalk = (npc.m_iTargetWalk || !npc.m_iTargetAttack);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTargetAttack, vecTarget);

		bool shouldGun = !npc.m_iTargetWalk;
		if(!shouldGun && !b_NpcIsInADungeon[npc.index])
		{
			int count = i_MaxcountNpcTotal;

			for(int i; i < count; i++)
			{
				BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]));
				if(ally.index != -1 && ally.index != npc.index && GetTeam(npc.index) == GetTeam(ally.index))
				{
					if(ally.m_bIsSquad && ally.m_iTargetAttack == npc.m_iTargetAttack && !ally.m_bRanged)
					{
						shouldGun = true;	// An ally rushing with a melee, I should cover them
						break;
					}
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
				if(distance > 650000.0 && npc.m_iTargetWalk)	// 806 HU
				{
					// Too far away to shoot
				}
				else if(npc.m_iAttacksTillReload < 1)
				{
					canWalk = false;
					
					npc.AddGesture("ACT_RELOAD_PISTOL");
					npc.m_flNextRangedAttack = gameTime + 1.35;
					npc.m_iAttacksTillReload = 18;
					npc.PlayPistolReload();
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

						vecDirShooting[1] = eyePitch[1];

						npc.m_flNextRangedAttack = gameTime + 0.35;
						npc.m_iAttacksTillReload--;
						
						float x = GetRandomFloat( -0.03, 0.03 );
						float y = GetRandomFloat( -0.03, 0.03 );
						
						float vecRight[3], vecUp[3];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];
						for(int i; i < 3; i++)
						{
							vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
						}

						NormalizeVector(vecDir, vecDir);
						
						// E2 L0 = 6.0, E2 L5 = 7.0
						KillFeed_SetKillIcon(npc.index, "pistol");
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 95000.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");

						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
						npc.PlayPistolFire();
					}
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
				npc.PlayStunStickDeploy();
			}
			
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

							// E2 L0 = 90, E2 L5 = 105
							KillFeed_SetKillIcon(npc.index, "wrench");
							SDKHooks_TakeDamage(target, npc.index, npc.index, 200000.0, DMG_CLUB, -1, _, vecTarget);
							
							npc.PlayStunStickHit();
						}
					}

					delete swingTrace;
				}
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(distance < 10000.0 && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))	// 100 HU
				{
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.PlayStunStickFire();

					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.05;
				}
			}
		}
	}

	if(canWalk || forceWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe, !npc.m_bRanged);
	}
	else
	{
		npc.StopPathing();
	}

	bool anger = BaseSquad_BaseAnim(npc, 80.0, npc.m_bRanged ? "ACT_IDLE_PISTOL" : "ACT_IDLE", npc.m_bRanged ? "ACT_WALK_PISTOL" : "ACT_WALK_ANGRY", 300.0, npc.m_bRanged ? "ACT_IDLE_ANGRY_PISTOL" : "ACT_IDLE_ANGRY_MELEE", npc.m_bRanged ? "ACT_RUN_PISTOL" : "ACT_RUN");
	npc.PlayIdle(anger);
}

void CombinePistol_NPCDeath(int entity)
{
	CombinePistol npc = view_as<CombinePistol>(entity);
	
	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
