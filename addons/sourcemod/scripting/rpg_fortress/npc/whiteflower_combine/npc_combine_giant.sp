#pragma semicolon 1
#pragma newdecls required

void OnMapStartCombineGiantSwordsman()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Giant Swordsman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_giant_swordsman");
	data.Func = ClotSummon;
	NPC_Add(data);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return CombineGiant(client, vecPos, vecAng, ally);
}

methodmap CombineGiant < CombineWarrior
{
	public CombineGiant(int client, float vecPos[3], float vecAng[3], int ally)
	{
		CombineGiant npc = view_as<CombineGiant>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", ally, false, true));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		func_NPCDeath[npc.index] = CombineGiant_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CombineGiant_TakeDamage;
		func_NPCThink[npc.index] = CombineGiant_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/jul13_trojan_helmet/jul13_trojan_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		return npc;
	}
}

public void CombineGiant_ClotThink(int iNPC)
{
	CombineGiant npc = view_as<CombineGiant>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	float vecMe[3];
	WorldSpaceCenter(npc.index, vecMe);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = true;
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTargetAttack, vecTarget);

		if(npc.m_bRanged)
		{
			bool shouldCharge = true;

			if(!b_NpcIsInADungeon[npc.index])
			{
				int count = i_MaxcountNpcTotal;

				for(int i; i < count; i++)
				{
					BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndex(i_ObjectsNpcsTotal[i]));
					if(ally.index != -1 && ally.index != npc.index && GetTeam(npc.index) == GetTeam(ally.index))
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L15 = 270, E2 L20 = 300
						SDKHooks_TakeDamage(target, npc.index, npc.index, 350000, DMG_CLUB, -1, _, vecTarget);
						npc.PlaySwordHit();
					}
				}

				delete swingTrace;
			}
		}

		if(distance < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}

		// No moving when ranged mode
		if(canWalk && npc.m_bRanged)
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

	npc.m_flMeleeArmor = 1.0001;
	npc.m_flRangedArmor = 1.0001;

	bool anger = BaseSquad_BaseAnim(npc, 112.0, "ACT_COLOSUS_IDLE", "ACT_COLOSUS_WALK", 112.0, "ACT_COLOSUS_IDLE", "ACT_COLOSUS_WALK");
	npc.PlayIdle(anger);

	if(!anger)
		npc.m_bRanged = true;
}

public Action CombineGiant_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CombineGiant npc = view_as<CombineGiant>(victim);

	if(attacker > 0 && attacker <= MaxClients)
	{
		// He hit me, no 1v1 honor
		npc.m_bRanged = false;

		if(!npc.m_iTargetWalk && npc.m_iTargetAttack)
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			damage = 0.0;
		}
		else
		{
			float vecMe[3], vecTarget[3];
			WorldSpaceCenter(npc.index, vecMe);
			WorldSpaceCenter(attacker, vecTarget);
			if(GetVectorDistance(vecMe, vecTarget, true) > 30000.0)	// 173 HU
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				damage = 0.0;
			}
		}
	}

	return Plugin_Changed;
}

void CombineGiant_NPCDeath(int entity)
{
	CombineGiant npc = view_as<CombineGiant>(entity);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
