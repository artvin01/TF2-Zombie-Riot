#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav";

void VictorianHumbee_MapStart()
{
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound("misc/halloween/hwn_dance_howl.wav");
	PrecacheSound("weapons/barret_arm_zap.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Humbee");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_humbee");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_major_crits");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianHumbee(client, vecPos, vecAng, ally);
}

methodmap VictorianHumbee < CClotBody
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
	
	public VictorianHumbee(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictorianHumbee npc = view_as<VictorianHumbee>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.5", "20000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_KART_IDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 210.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 1.50;
		npc.m_flRangedArmor = 0.75;

		b_CannotBeStunned[npc.index] = true;
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec2014_copilot_2014/dec2014_copilot_2014_heavy.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable2 = npc.EquipItem("m_vecAbsOrigin", "models/workshop/player/items/heavy/road_rager/road_rager.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/cc_summer2015_el_duderino/cc_summer2015_el_duderino.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_siberian_tigerstripe/fall17_siberian_tigerstripe.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	VictorianHumbee npc = view_as<VictorianHumbee>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, target);
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

				float damageDeal = 25.0;
				float ProjectileSpeed = 600.0;

				if(npc.m_iOverlordComboAttack % 3)
					ProjectileSpeed *= 1.25;

				if(npc.m_iOverlordComboAttack % 2)
					PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);

				npc.AddActivityViaSequence("taunt_vehicle_allclass_honk");
				npc.PlayMeleeSound();

				int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,10.0);
				if(entity != -1)
				{
					//max duration of 4 seconds beacuse of simply how fast they fire
					CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
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
			//npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");

			if(npc.m_iOverlordComboAttack > 5)
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

static void ClotDeath(int entity)
{
	VictorianHumbee npc = view_as<VictorianHumbee>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int health = ReturnEntityMaxHealth(npc.index) / 4;
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int other = NPC_CreateByName("npc_shotgunner", -1, pos, ang, team, "EX");
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
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}

