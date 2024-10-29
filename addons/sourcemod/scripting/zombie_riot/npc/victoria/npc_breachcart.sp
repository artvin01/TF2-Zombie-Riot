#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "mvm/sentrybuster/mvm_sentrybuster_intro.wav";

void VictoriaBreachcart_MapStart()
{
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	NPCData data;
	PrecacheModel("models/bots/tw2/boss_bot/static_boss_tank.mdl");
	strcopy(data.Name, sizeof(data.Name), "Breachcart");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_breachcart");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_major_crits");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaBreachcart(client, vecPos, vecAng, ally, data);
}

methodmap VictoriaBreachcart < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.6, 125);
	}
	
	public VictoriaBreachcart(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaBreachcart npc = view_as<VictoriaBreachcart>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "10000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_RIDER_RUN");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.g_TimesSummoned = 0;

		if(data[0])
			npc.g_TimesSummoned = StringToInt(data);
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 210.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 0.80;
		npc.m_flRangedArmor = 0.75;

		b_CannotBeStunned[npc.index] = true;
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_bat.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/sum20_hazard_headgear/sum20_hazard_headgear.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		if(npc.g_TimesSummoned == 0)
		{
			npc.m_iWearable2 = npc.EquipItemSeperate("head", "models/bots/tw2/boss_bot/static_boss_tank.mdl");
			SetVariantString("0.3");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}

		return npc;

	}
}

static void ClotThink(int iNPC)
{
	VictoriaBreachcart npc = view_as<VictoriaBreachcart>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

	if(npc.g_TimesSummoned == 0)
	{
		if(npc.m_fbRangedSpecialOn)
		{
			if(!IsValidEntity(npc.m_iWearable2))
			{
				npc.m_iWearable2 = npc.EquipItemSeperate("head", "models/bots/tw2/boss_bot/static_boss_tank.mdl");
				SetVariantString("0.3");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			}
			else
			{
				float vecTarget[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
				Custom_SDKCall_SetLocalOrigin(npc.m_iWearable2, vecTarget);
			}
		}
	}

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

		if(npc.m_flNextRangedAttack < gameTime && !NpcStats_IsEnemySilenced(npc.index))
		{
			npc.m_flNextRangedAttack = gameTime + 5.0;

			npc.PlayMeleeSound();

			int health = ReturnEntityMaxHealth(npc.index) / 10;

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			if(MaxEnemiesAllowedSpawnNext(1) > EnemyNpcAlive)
			{
				int entity = NPC_CreateByName("npc_bombcart", -1, pos, ang, GetTeam(npc.index), "EX");
				if(entity > MaxClients)
				{
					if(GetTeam(npc.index) != TFTeam_Red)
						Zombies_Currently_Still_Ongoing++;
					
					SetEntProp(entity, Prop_Data, "m_iHealth", health);
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
					
					fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index] * 0.85;
					fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 2.0;
					view_as<CClotBody>(entity).m_iBleedType = BLEEDTYPE_METAL;
				}
			}
			else
			{
				npc.m_flNextRangedAttack = 0.0;
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
	VictoriaBreachcart npc = view_as<VictoriaBreachcart>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

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

