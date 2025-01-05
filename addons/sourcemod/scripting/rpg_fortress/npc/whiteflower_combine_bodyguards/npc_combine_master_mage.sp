#pragma semicolon 1
#pragma newdecls required

static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_bounce1.wav",
	"weapons/physcannon/energy_bounce2.wav",
};
static char g_RangedAttackSoundsSecondaryReload[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

void OnMapStartCombine_Whiteflower_Master_Mage()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Master Mage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_master_mage");
	data.Func = ClotSummon;
	NPC_Add(data);
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondaryReload));	i++) { PrecacheSound(g_RangedAttackSoundsSecondaryReload[i]);	}
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Combine_Whiteflower_Master_Mage(vecPos, vecAng, team);
}

methodmap Combine_Whiteflower_Master_Mage < CombineSoldier
{
	public void PlayRangedAttackSecondarySound() {

		int RandomInt = GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[RandomInt], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[RandomInt], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);


	}
	public void PlayRangedAttackSecondarySoundReload() {
		EmitSoundToAll(g_RangedAttackSoundsSecondaryReload[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondaryReload) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
		

	}
	public Combine_Whiteflower_Master_Mage(float vecPos[3], float vecAng[3], int ally)
	{
		Combine_Whiteflower_Master_Mage npc = view_as<Combine_Whiteflower_Master_Mage>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");

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
		func_NPCDeath[npc.index] = Combine_Whiteflower_Master_Mage_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BaseSquad_TakeDamage;
		func_NPCThink[npc.index] = Combine_Whiteflower_Master_Mage_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/all_class/trn_wiz_hat_spy.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		

		return npc;
	}
}

public void Combine_Whiteflower_Master_Mage_ClotThink(int iNPC)
{
	Combine_Whiteflower_Master_Mage npc = view_as<Combine_Whiteflower_Master_Mage>(iNPC);

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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 800000.0, DMG_CLUB, -1, _, vecTarget);
						npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						npc.PlayFistHit();
						KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
					}
				}

				delete swingTrace;
			}
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(npc.m_flNextRangedAttack > gameTime)
		{
			canWalk = false;

			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
		}
		else if((npc.m_flNextRangedSpecialAttack) < gameTime)
		{
			canWalk = false;

			npc.AddGesture("ACT_SIGNAL_ADVANCE");
			npc.PlaySpecial();
			RPGDoHealEffect(npc.index, 500.0);

			npc.m_flNextMeleeAttack = gameTime + 0.95;
			npc.m_flNextRangedAttack = gameTime + 1.15;
			npc.m_flNextRangedSpecialAttack = gameTime + 10.0;
			
			if(!b_NpcIsInADungeon[npc.index])
			{
				int count = i_MaxcountNpcTotal;

				for(int i; i < count; i++)
				{
					BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndex(i_ObjectsNpcsTotal[i]));
					if(ally.index != -1 && ally.index != npc.index && GetTeam(npc.index) == GetTeam(ally.index))
					{
						WorldSpaceCenter(ally.index, vecTarget);
						if(GetVectorDistance(vecMe, vecTarget, true) < 250000.0)	// 500 HU
						{
							ApplyStatusEffect(npc.index, ally.index, "False Therapy", 10.0);
							ParticleEffectAt(vecTarget, "utaunt_bubbles_glow_green_parent", 0.5);
							ApplyStatusEffect(npc.index, ally.index, "Buff Banner", 7.0);
							float flMaxhealth = float(ReturnEntityMaxHealth(ally.index));
							flMaxhealth *= 0.35;
							HealEntityGlobal(ally.index, ally.index, flMaxhealth, 1.15, 0.0, HEAL_SELFHEAL);
						}
					}
				}
			}
		}
		else if(distance < 15000.0)	// 122 HU
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_PUSH_PLAYER");
				npc.PlayFistFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}
		else if(distance < 250000.0 || !npc.m_iTargetWalk)	// 500 HU
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(npc.m_iAttacksTillReload < 1)
				{
					canWalk = false;
					
					npc.AddGesture("ACT_ACTIVATE_BATON", .SetGestureSpeed = 0.15);
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.m_flNextRangedAttack = gameTime + 2.05;
					npc.m_iAttacksTillReload = 30;
					npc.PlayRangedAttackSecondarySoundReload();
				}
				else if(npc.m_flNextRangedAttack < gameTime)
				{
					int target = Can_I_See_Enemy(npc.index, npc.m_iTargetAttack);
					if(IsValidEnemy(npc.index, target))
					{
						if(!b_NpcIsInADungeon[npc.index])
						{
							npc.FaceTowards(vecTarget, 2000.0);
							canWalk = false;
						}
						npc.m_iAttacksTillReload--;
						npc.m_flNextRangedAttack = gameTime + 0.2;
						PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 800.0, _,vecTarget);
						npc.FaceTowards(vecTarget, 20000.0);
						npc.FireParticleRocket(vecTarget, 1000000.0 , 800.0 , 100.0 , "raygun_projectile_blue");

						npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", .SetGestureSpeed = 1.5);
						npc.PlayRangedAttackSecondarySound();
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

	bool anger = BaseSquad_BaseAnim(npc, 0.0, "ACT_IDLE", "ACT_RUN", 330.00, "ACT_IDLE", "ACT_RUN");
	npc.PlayIdle(anger);

	if(!anger && !npc.m_bPathing && npc.m_iAttacksTillReload < 31)
	{
		npc.AddGesture("ACT_ACTIVATE_BATON", .SetGestureSpeed = 0.15);
		npc.m_flNextMeleeAttack = gameTime + 1.75;
		npc.m_flNextRangedAttack = gameTime + 2.05;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iAttacksTillReload = 31;
		npc.PlayRangedAttackSecondarySoundReload();
	}
}

void Combine_Whiteflower_Master_Mage_NPCDeath(int entity)
{
	Combine_Whiteflower_Master_Mage npc = view_as<Combine_Whiteflower_Master_Mage>(entity);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
