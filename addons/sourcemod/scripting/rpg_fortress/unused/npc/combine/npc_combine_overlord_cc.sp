#pragma semicolon 1
#pragma newdecls required

#define CC_FLAG_BURNDAMAGE	(1 << 0)
#define CC_FLAG_BURNSPEED	(1 << 1)
#define CC_FLAG_MELEEDAMAGE	(1 << 2)

methodmap CombineOverlordCC < CombineSoldier
{
	public CombineOverlordCC(float vecPos[3], float vecAng[3], int ally)
	{
		CombineOverlordCC npc = view_as<CombineOverlordCC>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		i_NpcInternalId[npc.index] = COMBINE_OVERLORD_CC;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "firedeath");

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		// Melee attack
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		// Pulse attack
		npc.m_flNextRangedAttack = GetGameTime() + 15.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		// Movement delay
		npc.m_flNextRangedSpecialAttackHappens = npc.m_flNextRangedAttack + 60.0;

		npc.m_flMeleeArmor = 0.1001;
		npc.m_flRangedArmor = 0.1001;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, CombineOverlordCC_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineOverlordCC_ClotThink);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable1, 180, 155, 155, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		return npc;
	}
}

public void CombineOverlordCC_ClotThink(int iNPC)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

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

				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						BurnTarget(npc, target);

						// E2 L20 = 150, E2 L25 = 165
						KillFeed_SetKillIcon(npc.index, "sword");
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * ((npc.m_hCCFlags & CC_FLAG_MELEEDAMAGE) ? 6.0 : 3.0), DMG_CLUB, -1, _, vecTarget);
						npc.PlaySwordHit();

						KillFeed_SetKillIcon(npc.index, "firedeath");
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedAttackHappening)
		{
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				npc.FaceTowards(vecTarget, 20000.0);

				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				{
					BurnTarget(npc, npc.m_iTargetAttack);
					npc.PlayOverload();
				}

				if(npc.m_flRangedArmor > 0.5)
					npc.m_flRangedArmor = 0.5001;

				if(npc.m_flMeleeArmor > 0.5)
					npc.m_flMeleeArmor = 0.5001;

				npc.m_flRangedArmor -= 0.1;
				if(npc.m_flRangedArmor < 0.01)
					npc.m_flRangedArmor = 0.0101;
				
				npc.m_flMeleeArmor -= 0.1;
				if(npc.m_flMeleeArmor < 0.01)
					npc.m_flMeleeArmor = 0.0101;
			}
			else if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
			{
				npc.FaceTowards(vecTarget, 2000.0);
			}
		}
		else if(GetVectorDistance(vecTarget, vecMe, true) < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_ACHILLES_ATTACK_DAGGER");
				
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.95;
			}
		}
		else
		{
			if((npc.m_flNextRangedAttack < gameTime || (i_NpcFightOwner[npc.index] && !npc.m_iTargetWalk)) && !NpcStats_IsEnemySilenced(npc.index) && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_PULSE");

				npc.m_flNextRangedAttackHappening = gameTime + 0.35;
				npc.m_flNextRangedAttack = gameTime + ((npc.m_hCCFlags & CC_FLAG_BURNSPEED) ? 7.0 : 17.5);

				float time = gameTime + 0.95;
				if(npc.m_flNextRangedSpecialAttackHappens < time)
					npc.m_flNextRangedSpecialAttackHappens = time;
			}
		}

		if(npc.m_flNextRangedSpecialAttackHappens > gameTime)
			canWalk = false;
	}

	if(canWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe, true);
	}
	else
	{
		npc.StopPathing();
	}

	BaseSquad_BaseAnim(npc, 73.6, "ACT_PRINCE_IDLE", "ACT_PRINCE_WALK");
}

static void BurnTarget(CombineOverlordCC npc, int entity)
{
	if(entity > MaxClients)
	{
	//	NPC_Ignite(entity, npc.index, 5.0, -1);
	}
	else if(npc.m_hCCFlags & CC_FLAG_BURNDAMAGE)
	{
		NPC_Ignite(entity, npc.index,8.0, -1, 10.0);
	}
	else
	{
		NPC_Ignite(entity, npc.index,4.0, -1, 10.0);
	}
}

public Action CombineOverlordCC_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(victim);

	if(damagetype & DMG_CLUB)
	{
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		npc.m_flMeleeArmor += 0.0125;
		if(npc.m_flMeleeArmor > 1.5)
			npc.m_flMeleeArmor = 1.5;
	}
	else if(!(damagetype & DMG_TRUEDAMAGE))
	{
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		npc.m_flRangedArmor += 0.005;
		if(npc.m_flRangedArmor > 1.5)
			npc.m_flRangedArmor = 1.5;
	}

	return Plugin_Changed;
}

void CombineOverlordCC_NPCDeath(int entity)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, CombineOverlordCC_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineOverlordCC_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

public void Dungeon_OverlordBurnSpeed(int entity)
{
	if(i_NpcInternalId[entity] == COMBINE_OVERLORD_CC)
	{
		Level[entity] += 2;

		CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
		npc.m_hCCFlags |= CC_FLAG_BURNSPEED;
	}
}

public void Dungeon_OverlordMoveSpeed(int entity)
{
	if(i_NpcInternalId[entity] == COMBINE_OVERLORD_CC)
	{
		Level[entity] += 2;

		CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
		npc.m_flNextRangedSpecialAttackHappens -= 30.0;
	}
}

public void Dungeon_OverlordBurnDamage(int entity)
{
	if(i_NpcInternalId[entity] == COMBINE_OVERLORD_CC)
	{
		Level[entity] += 2;

		CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
		npc.m_hCCFlags |= CC_FLAG_BURNDAMAGE;
	}
}

public void Dungeon_OverlordMeleeDamage(int entity)
{
	if(i_NpcInternalId[entity] == COMBINE_OVERLORD_CC)
	{
		Level[entity] += 2;

		CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
		npc.m_hCCFlags |= CC_FLAG_MELEEDAMAGE;
	}
}