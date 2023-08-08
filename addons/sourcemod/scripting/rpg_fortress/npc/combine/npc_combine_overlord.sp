#pragma semicolon 1
#pragma newdecls required

methodmap CombineOverlord < CombineSoldier
{
	public CombineOverlord(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombineOverlord npc = view_as<CombineOverlord>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_OVERLORD;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		// Melee attack
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		// Pull attack
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		// Anger mode
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		npc.m_flAngerDelay = 0.0;

		// Damage summon
		npc.m_iAttacksTillReload = 100;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, CombineOverlord_TakeDamagePost);
		SDKHook(npc.index, SDKHook_OnTakeDamage, CombineOverlord_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineOverlord_ClotThink);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		return npc;
	}
}

public void CombineOverlord_ClotThink(int iNPC)
{
	CombineOverlord npc = view_as<CombineOverlord>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(npc.index, "SetBodyGroup");

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
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
	bool anger = npc.m_flAngerDelay > gameTime;
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);

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

						// E2 L20 = 150, E2 L25 = 165
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 3.0, DMG_CLUB, -1, _, vecTarget);
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
				
				if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				{
					static float angles[3];
					GetVectorAnglesTwoPoints(vecTarget, vecMe, angles);
					
					if(GetEntityFlags(npc.m_iTargetAttack) & FL_ONGROUND)
						angles[0] = 0.0; // toss out pitch if on ground

					static float velocity[3];
					GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(velocity, Pow(distance, 0.5) * 2.15);
					
					// min Z if on ground
					if(GetEntityFlags(npc.m_iTargetAttack) & FL_ONGROUND)
						velocity[2] = fmax(400.0, velocity[2]);
					
					// apply velocity
					TeleportEntity(npc.m_iTargetAttack, NULL_VECTOR, NULL_VECTOR, velocity);
				}
				else
				{
					npc.m_flNextRangedAttack = gameTime + 3.0;
				}
			}
			else if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
			{
				npc.FaceTowards(vecTarget, 2000.0);
			}
		}
		else if(npc.m_flNextRangedSpecialAttackHappens > gameTime)
		{
			canWalk = false;
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture(anger ? "ACT_GENERAL_ATTACK_POKE" : "ACT_MELEE_ATTACK_SWING_GESTURE");
				
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + (anger ? 0.15 : 0.35);
				npc.m_flNextMeleeAttack = gameTime + (anger ? 0.25 : 0.75);
			}
		}
		else if(!anger)
		{
			if((npc.m_flNextRangedAttack < gameTime || (i_NpcFightOwner[npc.index] && !npc.m_iTargetWalk)) && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_PUSH_PLAYER");

				npc.m_flNextRangedAttackHappening = gameTime + 0.45;
				npc.m_flNextRangedAttack = gameTime + 8.5;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.85;
			}
			else if(npc.m_flNextRangedSpecialAttack < gameTime && npc.m_iAttacksTillReload < 66)
			{
				npc.m_flNextRangedSpecialAttack = gameTime + 19.5;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 1.45;
				npc.m_flAngerDelay = gameTime + 4.5;

				npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
			}
		}
	}

	if(canWalk)
	{
		int attacker = npc.m_iTargetAttack;
		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = 0;
		
		BaseSquad_BaseWalking(npc, vecMe, true, true);

		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = attacker;
		
		if(npc.m_iNoTargetCount > 69)
			npc.m_iAttacksTillReload = 100;
	}
	else
	{
		npc.StopPathing();
	}

	BaseSquad_BaseAnim(npc, 66.33, "ACT_IDLE_BOB", "ACT_WALK_ANGRY", anger ? 424.48/*241.5*/ : 212.24, anger ? "ACT_RUN_SHIELDZOBIE" : "ACT_IDLE_ANGRY_MELEE", anger ? "ACT_RUN_SHIELDZOBIE" : "ACT_RUN");
	npc.PlayIdle(true);
}

public Action CombineOverlord_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CombineOverlord npc = view_as<CombineOverlord>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flAngerDelay > gameTime)
	{
		damage *= 0.25;
	}
	else if((!npc.m_iTargetWalk && npc.m_iTargetAttack) || (GetEntityFlags(npc.index) & (FL_SWIM|FL_INWATER)))
	{
		damage = 0.0;
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	else if(damagetype & DMG_CLUB)
	{
		if(npc.m_flMeleeArmor < 1.5)
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

			npc.m_flMeleeArmor += (npc.m_flMeleeArmor < 0.5) ? 0.25001 : 0.05001;
			if(npc.m_flMeleeArmor > 1.5)
				npc.m_flMeleeArmor = 1.5;
		}
	}
	else if(!(damagetype & DMG_SLASH))
	{
		if(npc.m_flRangedArmor < 1.5)
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

			npc.m_flRangedArmor += (npc.m_flRangedArmor < 0.5) ? 0.10001 : 0.02001;
			if(npc.m_flRangedArmor > 1.5)
				npc.m_flRangedArmor = 1.5;
		}
	}

	if(damage > 0.0 && npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void CombineOverlord_TakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	CombineOverlord npc = view_as<CombineOverlord>(victim);

	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	int precent = health * 100 / maxhealth;
	if(precent < 80 && npc.m_iAttacksTillReload > 79)
	{
		BringCombineAlly(npc, COMBINE_PISTOL);
	}
	else if(precent < 70 && npc.m_iAttacksTillReload > 69)
	{
		BringCombineAlly(npc, COMBINE_SMG);
	}
	else if(precent < 60 && npc.m_iAttacksTillReload > 59)
	{
		BringCombineAlly(npc, COMBINE_AR2);
	}
	else if(precent < 50 && npc.m_iAttacksTillReload > 49)
	{
		BringCombineAlly(npc, COMBINE_SHOTGUN);
	}
	else if(precent < 40 && npc.m_iAttacksTillReload > 39)
	{
		BringCombineAlly(npc, COMBINE_ELITE);

		npc.m_flMeleeArmor = 0.0001;
		npc.m_flRangedArmor = 0.0001;
	}
	else if(precent < 30 && npc.m_iAttacksTillReload > 29)
	{
		BringCombineAlly(npc, COMBINE_SWORDSMAN);
	}
	else if(precent < 20 && npc.m_iAttacksTillReload > 19)
	{
		BringCombineAlly(npc, COMBINE_GIANT);
	}
	else if(precent < 10 && npc.m_iAttacksTillReload > 9)
	{
		npc.m_flMeleeArmor = 0.0001;
		npc.m_flRangedArmor = 0.0001;
	}

	npc.m_iAttacksTillReload = precent;
}

static void BringCombineAlly(CombineOverlord npc, int index)
{
	if(!b_NpcIsInADungeon[npc.index])
	{
		bool friendly = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2;
		int count = friendly ? i_MaxcountNpc_Allied : i_MaxcountNpc;

		for(int i; i < count; i++)
		{
			BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndex(friendly ? i_ObjectsNpcs_Allied[i] : i_ObjectsNpcs[i]));
			if(ally.index != -1 && ally.index != npc.index)
			{
				if(ally.m_bIsSquad && i_NpcInternalId[ally.index] == index && !b_NpcIsInADungeon[ally.index])
				{
					float vecMe[3];
					vecMe = WorldSpaceCenter(npc.index);
					TeleportEntity(ally.index, vecMe);
					break;
				}
			}
		}
	}
}

void CombineOverlord_NPCDeath(int entity)
{
	CombineOverlord npc = view_as<CombineOverlord>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, CombineOverlord_TakeDamagePost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, CombineOverlord_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineOverlord_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
