#pragma semicolon 1
#pragma newdecls required

void OnMapStartCombine_ThreatCleaner()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Threat Cleaner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_threat_cleaner");
	data.Func = ClotSummon;
	NPC_Add(data);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Combine_ThreatCleaner(vecPos, vecAng, team);
}

methodmap Combine_ThreatCleaner < CombineSoldier
{
	public Combine_ThreatCleaner(float vecPos[3], float vecAng[3], int ally)
	{
		Combine_ThreatCleaner npc = view_as<Combine_ThreatCleaner>(BaseSquad(vecPos, vecAng, "models/combine_super_soldier.mdl", "1.15", ally, false));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 31;

		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		func_NPCDeath[npc.index] = Combine_ThreatCleaner_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BaseSquad_TakeDamage;
		func_NPCThink[npc.index] = Combine_ThreatCleaner_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntityRenderColor(npc.index, 100, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 100, 255);

		return npc;
	}
}

public void Combine_ThreatCleaner_ClotThink(int iNPC)
{
	Combine_ThreatCleaner npc = view_as<Combine_ThreatCleaner>(iNPC);

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
	WorldSpaceCenter(npc.index, vecMe);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = (npc.m_iTargetWalk || !npc.m_iTargetAttack);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTargetAttack, vecTarget);
		
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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 550000.0, DMG_CLUB, -1, _, vecTarget);
						npc.PlayFistHit();
						KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedSpecialAttackHappens)
		{
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.m_flNextRangedSpecialAttackHappens = 0.0;

				// E2 L5 = 280, E2 L10 = 320
				PredictSubjectPositionForProjectiles(npc, npc.m_iTargetAttack, 500.0,_,vecTarget);
				npc.FireRocket(vecTarget, 900000.0, 500.0, "models/effects/combineball.mdl");
			}
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(npc.m_flNextRangedAttack > gameTime)
		{
			canWalk = false;

			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
		}
		else if(distance < 15000.0)	// 122 HU
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_ATTACK1");
				npc.PlayFistFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}
		else if(distance < 250000.0 || !npc.m_iTargetWalk)	// 500 HU
		{
			if(!b_NpcIsInADungeon[npc.index] && npc.m_flNextRangedSpecialAttack < gameTime)
			{
				if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
				{
					npc.AddGesture("ACT_COMBINE_AR2_ALTFIRE");
					npc.PlayAR2Special();

					npc.m_flNextMeleeAttack = gameTime + 1.05;
					npc.m_flNextRangedAttack = gameTime + 1.05;
					npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.45;
					npc.m_flNextRangedSpecialAttack = gameTime + 10.5;
				}
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(npc.m_iAttacksTillReload < 1)
				{
					canWalk = false;
					
					npc.AddGesture("ACT_RELOAD");
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.m_flNextRangedAttack = gameTime + 2.05;
					npc.m_iAttacksTillReload = 30;
					npc.PlayAR2Reload();
				}
				else
				{
					int target = Can_I_See_Enemy(npc.index, npc.m_iTargetAttack);
					if(IsValidEnemy(npc.index, target))
					{
						if(!b_NpcIsInADungeon[npc.index])
						{
							npc.FaceTowards(vecTarget, 2000.0);
							canWalk = false;
						}

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
							
							float x = GetRandomFloat( -0.04, 0.04 );
							float y = GetRandomFloat( -0.04, 0.04 );
							
							float vecRight[3], vecUp[3];
							GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
							
							float vecDir[3];
							for(int i; i < 3; i++)
							{
								vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
							}

							NormalizeVector(vecDir, vecDir);
							
							// E2 L5 = 5.25, E2 L10 = 6
							KillFeed_SetKillIcon(npc.index, "smg");
							if(distance > (300.0 * 300.0))	// extra damage when too far away.
								FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 450000.0, 9000.0, DMG_BULLET, "bullet_tracer01_blue");
							else
								FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 375000.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");

							KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
							npc.PlayAR2Fire();
						}
					}
				}
			}
		}
		else if((npc.m_flNextRangedAttack + 6.0) < gameTime)
		{
			canWalk = false;

			npc.AddGesture("ACT_SIGNAL_ADVANCE");
			npc.PlaySpecial();

			npc.m_flNextMeleeAttack = gameTime + 0.95;
			npc.m_flNextRangedAttack = gameTime + 1.15;
			
			if(!b_NpcIsInADungeon[npc.index])
			{
				int count = i_MaxcountNpcTotal;

				for(int i; i < count; i++)
				{
					BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]));
					if(ally.index != -1 && ally.index != npc.index && GetTeam(npc.index) == GetTeam(ally.index))
					{
						if(ally.m_bIsSquad)
						{
							WorldSpaceCenter(ally.index, vecTarget);
							if(GetVectorDistance(vecMe, vecTarget, true) < 250000.0)	// 500 HU
							{
								ApplyStatusEffect(npc.index, ally.index, "False Therapy", 10.0);
								ParticleEffectAt(vecTarget, "utaunt_bubbles_glow_green_parent", 0.5);
								break;
							}
						}
					}
				}
			}
		}
	}

	if(canWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe, true);
	}
	else
	{
		npc.StopPathing();
	}

	bool anger = BaseSquad_BaseAnim(npc, 0.0, "ACT_IDLE", "ACT_WALK_EASY", 330.00, "ACT_IDLE_ANGRY", "ACT_RUN_AIM_RIFLE");
	npc.PlayIdle(anger);

	if(!anger && !npc.m_bPathing && npc.m_iAttacksTillReload < 31)
	{
		npc.AddGesture("ACT_RELOAD");
		npc.m_flNextMeleeAttack = gameTime + 1.75;
		npc.m_flNextRangedAttack = gameTime + 2.05;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iAttacksTillReload = 31;
		npc.PlayAR2Reload();
	}
}

void Combine_ThreatCleaner_NPCDeath(int entity)
{
	Combine_ThreatCleaner npc = view_as<Combine_ThreatCleaner>(entity);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
