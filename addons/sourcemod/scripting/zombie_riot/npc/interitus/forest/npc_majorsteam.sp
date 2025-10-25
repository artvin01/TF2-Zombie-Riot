#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav";

void MajorSteam_MapStart()
{
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound("misc/halloween/hwn_dance_howl.wav");
	PrecacheSound("weapons/barret_arm_zap.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Major Steam");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_majorsteam");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_major_crits");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MajorSteam(vecPos, vecAng, team);
}

methodmap MajorSteam < CClotBody
{
	public void PlayHurtSound()
	{
		EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	
	public MajorSteam(float vecPos[3], float vecAng[3], int ally)
	{
		MajorSteam npc = view_as<MajorSteam>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "2.0", "300000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		b_NpcUnableToDie[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 0.01;
		npc.m_flRangedArmor = 0.01;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
		if(Rogue_Paradox_RedMoon())
			IgniteTargetEffect(npc.m_iWearable1);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/robo_soldier_fullmetaldrillhat/robo_soldier_fullmetaldrillhat.mdl", _, _, 1.001);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	MajorSteam npc = view_as<MajorSteam>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	if(npc.Anger)
	{
		RemoveSpecificBuff(npc.index, "Unstoppable Force");
		SDKHooks_TakeDamage(npc.index, 0, 0, 1000000.0, DMG_BLAST);
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				if(Rogue_Paradox_RedMoon())
				{
					target = Can_I_See_Enemy(npc.index, target);
					if(IsValidEnemy(npc.index, target))
					{
						npc.m_iTarget = target;
						npc.m_flGetClosestTargetTime = gameTime + 0.45;
					}
					else
					{
						npc.m_flAttackHappens = 0.0;
					}
				}

				float damageDeal = 165.0;
				float ProjectileSpeed = 450.0;
				if(Rogue_Paradox_RedMoon())
				{
					ProjectileSpeed *= 1.15;
				}

				if(npc.m_iOverlordComboAttack % 3)
					ProjectileSpeed *= 1.25;

				if(npc.m_iOverlordComboAttack % 2)
					PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);

				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				npc.PlayMeleeSound();

				int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,70.0);
				if(entity != -1)
				{
					i_ChaosArrowAmount[entity] = 80;
					if(Rogue_Paradox_RedMoon())
						i_ChaosArrowAmount[entity] = 125;

					//max duration of 4 seconds beacuse of simply how fast they fire
					CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					SetEntProp(entity, Prop_Send, "m_bCritical", true);
				}

				npc.m_iOverlordComboAttack--;

				if(npc.m_iOverlordComboAttack < 1)
				{
					npc.m_flAttackHappens = 0.0;
				}
				else
				{
					npc.m_flAttackHappens = gameTime + 0.15;
				}
			}
		}
		else if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iOverlordComboAttack += 2;
			npc.m_flNextMeleeAttack = gameTime + 0.45;
			npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");

			if(npc.m_iOverlordComboAttack > 13)
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 2.45;
					npc.m_flAttackHappens = gameTime + 0.15;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
	}
}

static void MajorSteam_DownedThink(int entity)
{
	MajorSteam npc = view_as<MajorSteam>(entity);
	npc.SetActivity("ACT_MP_STUN_MIDDLE");
	npc.AddGesture("ACT_MP_STUN_BEGIN");
	npc.Update();
	func_NPCThink[npc.index] = ClotThink;
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	MajorSteam npc = view_as<MajorSteam>(victim);
	
	if(!npc.Anger && damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
		ApplyStatusEffect(npc.index, npc.index, "Unstoppable Force", 3.0);

		npc.Anger = true;
		npc.PlayHurtSound();
		npc.StopPathing();
		npc.m_flNextThinkTime = GetGameTime() + 2.0;

		func_NPCThink[npc.index] = MajorSteam_DownedThink;
		
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		spawnRing_Vectors(vecMe, 450.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1);
		spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1, 450.0 * 2.0);
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		damage = 0.0;
		return Plugin_Handled;
	}
	
	npc.m_flMeleeArmor += 0.001 / MultiGlobalEnemy;
	npc.m_flRangedArmor += 0.001 / MultiGlobalEnemy;

	if(npc.m_flMeleeArmor > 2.0)
		npc.m_flMeleeArmor = 2.0;

	if(npc.m_flRangedArmor > 2.0)
		npc.m_flRangedArmor = 2.0;

	return Plugin_Changed;
}

static void ClotDeath(int entity)
{
	MajorSteam npc = view_as<MajorSteam>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();
	
	KillFeed_SetKillIcon(npc.index, "pumpkindeath");
	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(999999.9, npc.index, npc.index, -1, vecMe, 450.0, 1.0, _, true, 40, _, _, _, MajorSteamExplodePre);
	b_NpcIsTeamkiller[npc.index] = false;

	int health = ReturnEntityMaxHealth(npc.index) / 4;
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int other = NPC_CreateByName("npc_vulpo", -1, pos, ang, team, "EX");
	if(other > MaxClients)
	{
		if(team != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		
		SetEntProp(other, Prop_Data, "m_iHealth", health);
		SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
		
		fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
		b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
		b_StaticNPC[other] = b_StaticNPC[npc.index];
		if(b_StaticNPC[other])
			AddNpcToAliveList(other, 1);
		NpcStats_CopyStats(npc.index, other);
		view_as<CClotBody>(other).m_flNextThinkTime = GetGameTime() + 4.0;
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static float MajorSteamExplodePre(int attacker, int victim, float damage, int weapon)
{
	if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
		return 10000.0;	// 10k dmg vs bosses
	
	return damage;
}

