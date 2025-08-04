#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_HealSound[] = "physics/metal/metal_box_strain1.wav";


static int OverrideAlly[MAXENTITIES];

void VictorianDroneAnvil_MapStart()
{
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_HealSound);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Anvil");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_anvil");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_anvil");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianDroneAnvil(vecPos, vecAng, ally, data);
}

methodmap VictorianDroneAnvil < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);
	}
	
	public VictorianDroneAnvil(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "3000", ally, _, true, .CustomThreeDimensions = {20.0, 20.0, 20.0}, .CustomThreeDimensionsextra = {-20.0, -20.0, -20.0}));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		b_IgnoreAllCollisionNPC[npc.index] = true;
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;
		
		MK2[npc.index]=false;
		Limit[npc.index]=false;
		OverrideAlly[npc.index]=-1;
		
		bool FactorySpawndo;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			if(!StrContains(countext[i], "factory"))FactorySpawndo=true;
			else if(!StrContains(countext[i], "mk2")){MK2[npc.index]=true;strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Victoria Anvil MK2");}
			else if(!StrContains(countext[i], "limit"))Limit[npc.index]=true;
			int targetdata = StringToInt(countext[i]);
			if(IsValidEntity(targetdata) && GetTeam(npc.index) == GetTeam(targetdata))OverrideAlly[npc.index] = targetdata;
		}

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 3;
		npc.m_flAttackHappens = GetGameTime(npc.index)+500.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = true;
		npc.Anger = false;
		Is_a_Medic[npc.index] = true;

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl",_,1,1.001,_,true);
		Vec[0] += 15.5;
		Vec[1] += 0.5;
		Vec[2] -= 61.5;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_teaser/saucer.mdl",_,1,1.001,_,true);
		SetEntityRenderColor(npc.m_iWearable2, 80, 50, 50, 255);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.m_iWearable2);
		MakeObjectIntangeable(npc.m_iWearable1);
		Ang[0] = 0.0;
		Ang[1] = -90.0;
		Ang[2] = 0.0;
		TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable2);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({45, 237, 164, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		GetAbsOrigin(npc.index, Vec);
		if(FactorySpawndo)
		{
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
				{
					GetAbsOrigin(entity, Vec);
					break;
				}
			}
		}
		Vec[2]+=45.0;
		TeleportEntity(npc.index, Vec, NULL_VECTOR, NULL_VECTOR);
		npc.StopPathing();
		return npc;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ClotThink(int iNPC)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(!npc.m_bisWalking)
	{
		npc.SetVelocity({0.0,0.0,0.0});
		npc.m_flSpeed=0.0;
	}
	else
	{
		npc.m_flSpeed = NpcStats_VictorianCallToArms(npc.index) ? 400.0 : 300.0;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	if((!IsValidAlly(npc.index, GetClosestAlly(npc.index)) && !IsValidAlly(npc.index, OverrideAlly[npc.index]))
	|| (gameTime > npc.m_flAttackHappens && Limit[npc.index]))
	{
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTargetAlly;

	float VecAlly[3]; WorldSpaceCenter(target, VecAlly);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecAlly, VecSelfNpc, true);
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < gameTime)
		target = VictoriaAnvilGetTarget(npc.index, gameTime);
	
	int AI = VictoriaAnvilDefenseMode(npc.index, gameTime, target, DistanceToTarget);
	switch(AI)
	{
		case 0://attack
		{
			npc.m_bisWalking = false;
			npc.m_flCharge_delay = gameTime + 0.8;
			
			if(!npc.Anger && Limit[npc.index])
			{
				npc.m_flAttackHappens = gameTime + (MK2[npc.index] ? 30.0 : 20.0);
				npc.Anger = true;
			}
		}
		case 1://cooldown
		{
			/*none*/
		}
		case 2://notfound
		{
			if(gameTime > npc.m_flCharge_delay)
			{
				npc.m_bisWalking = true;
				float Pathing[3], Npvel[3], NPCAng[3];
				float Ang[3], OpenSky[3], distance;
				Ang[0]=-90.0;
				LookPoint(target, Ang, VecAlly, OpenSky);
				distance = GetVectorDistance(VecAlly, OpenSky);
				if(distance>300.0) VecAlly[2]+=300.0;
				else if(distance>200.0) VecAlly[2]+=200.0;
				else if(distance>100.0) VecAlly[2]+=100.0;
				else if(distance>50.0) VecAlly[2]+=20.0;
				SubtractVectors(VecAlly, VecSelfNpc, Pathing);
				GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_angRotation", NPCAng);
				npc.GetVelocity(Npvel);
				float NPCSpeed = npc.m_flSpeed;
				NormalizeVector(Pathing, Npvel);
				ScaleVector(Npvel, NPCSpeed);
				GetVectorAngles(Npvel, NPCAng);
				npc.SetVelocity(Npvel);
				NPCAng[2]=0.0;
				NPCAng[0]=0.0;
				SetEntPropVector(npc.m_iWearable2, Prop_Data, "m_angRotation", NPCAng);
			}
		}
	}
}

int VictoriaAnvilGetTarget(int iNPC, float gameTime)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);
	if(!IsValidAlly(npc.index,npc.m_iTargetAlly))
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(!IsValidAlly(npc.index,npc.m_iTargetAlly))
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index);
		}	
	}
	npc.m_flGetClosestTargetTime = gameTime + 1.0;
	return npc.m_iTargetAlly;
}

int VictoriaAnvilDefenseMode(int iNPC, float gameTime, int target, float distance)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * (MK2[npc.index] ? 20.0 : 10.0)))
		{
			npc.PlayHealSound();
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			spawnRing_Vectors(vecTarget, (MK2[npc.index] ? 400.0 : 200.0)  * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 30, 255, 0, 150, 1, 0.3, 5.0, 8.0, 3);	
			//CreateTimer(0.1, Timer_MachineShop, npc.index, TIMER_FLAG_NO_MAPCHANGE);
			//VictorianFactory npc = view_as<VictorianFactory>(iNPC);
			float entitypos[3], dist;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) == GetTeam(npc.index))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					dist = GetVectorDistance(vecTarget, entitypos);
					if(dist<(MK2[npc.index] ? 400.0 : 200.0))
					{
						IncreaseEntityDamageTakenBy(entity, 0.8, 0.3);
						HealEntityGlobal(npc.index, entity, 75.0, 1.0);
					}
				}
			}
			npc.m_flNextMeleeAttack = gameTime + 0.3;
			return 0;
		}
		return 2;
	}
	return 1;
}

static void ClotDeath(int entity)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(entity);

	npc.PlayDeathSound();

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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}