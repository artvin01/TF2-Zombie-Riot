#pragma semicolon 1
#pragma newdecls required

methodmap CombineSwordsman < CombineWarrior
{
	public CombineSwordsman(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombineSwordsman npc = view_as<CombineSwordsman>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_SWORDSMAN;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, CombineSwordsman_TakeDamagePost);
		SDKHook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineSwordsman_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/jul13_trojan_helmet/jul13_trojan_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		return npc;
	}
}

public void CombineSwordsman_ClotThink(int iNPC)
{
	CombineSwordsman npc = view_as<CombineSwordsman>(iNPC);

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

	float vecMe[3];
	vecMe = WorldSpaceCenter(npc.index);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = true;
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);

		if(npc.m_bRanged)
		{
			bool shouldCharge = true;

			if(!b_NpcIsInADungeon[npc.index])
			{
				bool friendly = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2;
				int count = friendly ? i_MaxcountNpc_Allied : i_MaxcountNpc;

				for(int i; i < count; i++)
				{
					BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndex(friendly ? i_ObjectsNpcs_Allied[i] : i_ObjectsNpcs[i]));
					if(ally.index != -1 && ally.index != npc.index)
					{
						if(ally.m_bIsSquad && ally.m_iTargetAttack == npc.m_iTargetAttack && !ally.m_bRanged)
						{
							shouldCharge = false;	// An ally already attacking with melee, let them 1v1 em
							break;
						}
					}
				}
			}

			if(shouldCharge)
				npc.m_bRanged = false;
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L15 = 157.5, E2 L20 = 175
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 3.5, DMG_CLUB, -1, _, vecTarget);
						npc.PlaySwordHit();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedAttackHappening)
		{
			canWalk = false;

			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				npc.FaceTowards(vecTarget, 20000.0);

				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				npc.PlaySwordSpecial();

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L15 = 225, E2 L20 = 250
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 5.0, DMG_BULLET, -1, _, vecTarget);
					}
				}

				delete swingTrace;
			}
			else if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
			{
				npc.FaceTowards(vecTarget, 2000.0);
			}
		}
		else if(npc.m_flNextRangedSpecialAttackHappens)
		{
			canWalk = false;
			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
			
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.m_flNextRangedSpecialAttackHappens = 0.0;
				npc.m_flRangedArmor = 0.0001;

				npc.m_iWearable5 = npc.SpawnShield(3.0, "models/props_mvm/mvm_player_shield.mdl",80.0);
				npc.PlaySwordDeploy();
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.85;
			}
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(npc.m_flNextRangedAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_PUSH_PLAYER");

				npc.m_flNextRangedAttackHappening = gameTime + 0.35;
				npc.m_flNextRangedAttack = gameTime + 4.45;
				npc.m_flNextRangedSpecialAttack = gameTime + 0.95;
			}
		}

		// No moving when ranged mode or on special cooldown
		if(canWalk && (npc.m_flNextRangedSpecialAttack > gameTime || npc.m_bRanged))
		{
			canWalk = false;
			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
		}
	}

	if(canWalk)
	{
		int attacker = npc.m_iTargetAttack;
		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = 0;
		
		BaseSquad_BaseWalking(npc, vecMe, true);

		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = attacker;
	}
	else
	{
		npc.StopPathing();
	}

	bool anger = BaseSquad_BaseAnim(npc, 66.33, "ACT_IDLE", "ACT_WALK", 212.24, "ACT_IDLE_ANGRY_MELEE", "ACT_RUN");
	npc.PlayIdle(anger);

	if(!anger)
		npc.m_bRanged = true;
}

public void CombineSwordsman_TakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	CombineSwordsman npc = view_as<CombineSwordsman>(victim);

	if(attacker > 0 && attacker <= MaxClients)
	{
		// He hit me, no 1v1 honor
		npc.m_bRanged = false;
	}

	if(!npc.m_iTargetWalk && npc.m_iTargetAttack)
	{
		float gameTime = GetGameTime(npc.index);
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");
			
			npc.m_flNextMeleeAttack = gameTime + 1.15;
			npc.m_flNextRangedAttack = gameTime + 1.15;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.75;
			npc.m_flNextRangedSpecialAttack = gameTime + 3.75;
		}
	}
}

void CombineSwordsman_NPCDeath(int entity)
{
	CombineSwordsman npc = view_as<CombineSwordsman>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, CombineSwordsman_TakeDamagePost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineSwordsman_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}
