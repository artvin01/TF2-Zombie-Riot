#pragma semicolon 1
#pragma newdecls required

methodmap TownGuardPistol < BaseSquad
{
	public TownGuardPistol(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		char model[PLATFORM_MAX_PATH];

		int seed = GetURandomInt();
		if(seed % 2)
		{
			int rand = seed % 6;
			if(rand > 3)
			{
				rand += 2;
			}
			else
			{
				rand++;
			}
			
			FormatEx(model, sizeof(model), "female_0%d", rand);
		}
		else
		{
			FormatEx(model, sizeof(model), "male_0%d", 1 + (seed % 9));
		}
		
		Format(model, sizeof(model), "models/humans/group03/%s_bloody.mdl", model);

		TownGuardPistol npc = view_as<TownGuardPistol>(BaseSquad(vecPos, vecAng, model, "1.15", true, true));
		
		i_NpcInternalId[npc.index] = TOWNGUARD_PISTOL;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		b_NpcIsInvulnerable[npc.index] = true;
		
		npc.m_flNextRangedAttack = 0.0;
		
		SDKHook(npc.index, SDKHook_Think, TownGuardPistol_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		return npc;
	}
}

public void TownGuardPistol_ClotThink(int iNPC)
{
	TownGuardPistol npc = view_as<TownGuardPistol>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// Due to animation bug, we force switch our idle anim
	bool forceWalk = view_as<bool>(npc.m_iTargetAttack);

	float vecMe[3];
	vecMe = WorldSpaceCenter(npc.index);
	BaseSquad_BaseThinking(npc, vecMe, true);

	// Due to animation bug, we force switch our idle anim
	forceWalk = (forceWalk != view_as<bool>(npc.m_iTargetAttack));

	bool canWalk = (npc.m_iTargetWalk || !npc.m_iTargetAttack);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);

		if(npc.m_flNextRangedAttack < gameTime)
		{
			if(GetVectorDistance(vecTarget, vecMe, true) > 250000.0)	// 500 HU
			{
				//npc.FaceTowards(vecTarget, 1500.0);
				//canWalk = false;
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

						npc.m_flNextRangedAttack = gameTime + 0.15;
						
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

						// E2 L0 = 6.0, E2 L5 = 7.0
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, Level[npc.index] * 0.2, 9000.0, DMG_BULLET, "bullet_tracer01_red");
						
						BaseSquad enemy = view_as<BaseSquad>(target);
						if(enemy.m_bIsSquad)
						{
							enemy.m_iDeathDamage += 19;
							if(enemy.m_iDeathDamage > 99)
							{
								SDKHooks_TakeDamage(target, 0, 0, GetEntProp(target, Prop_Data, "m_iMaxHealth") * 1.4, DMG_DROWN);
							}
						}
						
						npc.AddGesture("ACT_RANGE_ATTACK_PISTOL");
						npc.PlayPistolFire();
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

	if(canWalk || forceWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe);
	}
	else
	{
		npc.StopPathing();
	}

	BaseSquad_BaseAnim(npc, 90.0, "ACT_IDLE", "ACT_WALK", 240.0, "ACT_RELOAD_PISTOL", "ACT_RUN");
}

void TownGuardPistol_NPCDeath(int entity)
{
	TownGuardPistol npc = view_as<TownGuardPistol>(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, TownGuardPistol_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
