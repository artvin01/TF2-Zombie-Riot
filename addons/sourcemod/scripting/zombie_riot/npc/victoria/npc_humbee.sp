#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "weapons/rocket_blackbox_shoot.wav";

void VictorianHumbee_MapStart()
{
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Humbee");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_humbee");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_humbee");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianHumbee(vecPos, vecAng, ally, data);
}

methodmap VictorianHumbee < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.6, _);
	}
	
	public VictorianHumbee(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianHumbee npc = view_as<VictorianHumbee>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "9000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_KART_IDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;

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
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 1.75;
		npc.m_flRangedArmor = 0.75;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec2014_copilot_2014/dec2014_copilot_2014_heavy.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/cc_summer2015_el_duderino/cc_summer2015_el_duderino.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_siberian_tigerstripe/fall17_siberian_tigerstripe.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		if(npc.g_TimesSummoned == 0)
		{
			npc.m_iWearable2 = npc.EquipItemSeperate("models/workshop/player/items/heavy/road_rager/road_rager.mdl");
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	VictorianHumbee npc = view_as<VictorianHumbee>(iNPC);

	if(npc.g_TimesSummoned == 0)
	{
		if(npc.m_fbRangedSpecialOn)
		{
			if(!IsValidEntity(npc.m_iWearable2))
			{
				npc.m_iWearable2 = npc.EquipItemSeperate("models/workshop/player/items/heavy/road_rager/road_rager.mdl");
				SetVariantString("1.5");
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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
			{	
				float damageDeal = 35.0;
				float ProjectileSpeed = 600.0;

				if(NpcStats_VictorianCallToArms(npc.index))
				{
					ProjectileSpeed *= 1.5;
				}

				npc.PlayMeleeSound();

				int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,7.5);
				if(entity != -1)
				{
					//max duration of 4 seconds beacuse of simply how fast they fire
					CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
				}
				npc.m_flNextMeleeAttack = gameTime + 1.50;	
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

	TE_Particle("rd_robot_explosion_smoke_linger", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
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
		if(b_StaticNPC[other])
			AddNpcToAliveList(other, 1);
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

