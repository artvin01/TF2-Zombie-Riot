#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_HealSound[] = "physics/metal/metal_box_strain1.wav";

static int NPCId;

void VictorianDroneAnvil_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Anvil");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_anvil");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_anvil");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId=NPC_Add(data);
}

int VictorianAnvil_ID()
{
	return NPCId;
}

static void ClotPrecache()
{
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_HealSound);
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	vecAng[0]=0.0;
	vecAng[1]=0.0;
	vecAng[2]=0.0;
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
	
	public void StartHealing()
	{
		int im_iWearable3 = this.m_iWearable3;
		if(im_iWearable3 != INVALID_ENT_REFERENCE)
		{
			this.Healing = true;
			
		//	EmitSoundToAll("m_iWearable3s/medigun_heal.wav", this.index, SNDCHAN_m_iWearable3);
		}
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable5;
		if(iBeam != INVALID_ENT_REFERENCE)
		{
			int iBeamTarget = GetEntPropEnt(iBeam, Prop_Send, "m_hOwnerEntity");
			if(IsValidEntity(iBeamTarget))
			{
				AcceptEntityInput(iBeamTarget, "ClearParent");
				RemoveEntity(iBeamTarget);
			}
			
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
		//	StopSound(this.index, SNDCHAN_m_iWearable3, "m_iWearable3s/medigun_heal.wav");
			
			this.Healing = false;
		}
	}
	
	property float m_flLifeTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public VictorianDroneAnvil(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "3000", ally, _, true, .CustomThreeDimensions = {20.0, 20.0, 20.0}, .CustomThreeDimensionsextra = {-20.0, -20.0, -20.0}));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictorianDroneAnvil_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianDroneAnvil_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianDroneAnvil_ClotThink;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		b_we_are_reloading[npc.index]=false;
		npc.m_flLifeTime=20.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		b_IgnoreAllCollisionNPC[npc.index] = true;
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = true;
		npc.m_bFUCKYOU = false;
		npc.Anger = false;
		npc.m_bFUCKYOU_move_anim = false;
		Is_a_Medic[npc.index] = true;
		
		bool FactorySpawndo;
		static char countext[5][128];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "lifetime") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "lifetime", "");
				npc.m_flLifeTime = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "mk2") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "mk2", "");
				b_we_are_reloading[npc.index] = true;
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Victoria Anvil MK2");
			}
			else if(StrContains(countext[i], "factory") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "factory", "");
				FactorySpawndo=true;
			}
			else if(StrContains(countext[i], "raidmode") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "raidmode", "");
				npc.m_bFUCKYOU_move_anim = true;
			}
			else if(StrContains(countext[i], "overridetarget") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "overridetarget", "");
				npc.m_iTarget = EntRefToEntIndex(StringToInt(countext[i]));
			}
		}
		
		if(npc.m_flLifeTime!=-1.0)
		{
			fl_ruina_battery_max[npc.index]=npc.m_flLifeTime;
			fl_ruina_battery[npc.index]=npc.m_flLifeTime;
			ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		}

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
		npc.m_bDoSpawnGesture = true;
		
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

static Action VictorianDroneAnvil_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

static void VictorianDroneAnvil_ClotThink(int iNPC)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		npc.m_iTeamGlow = TF2_CreateGlow(npc.m_iWearable2);
		SetVariantColor(view_as<int>({45, 237, 164, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		npc.m_bDoSpawnGesture=false;
	}
	
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
	if((npc.m_flLifeTime>0.0 && npc.m_flAttackHappens_bullshit && gameTime > npc.m_flAttackHappens_bullshit)
	||(npc.m_iTarget&&b_NpcHasDied[npc.m_iTarget])||(!npc.m_iTarget&&(npc.m_flLifeTime!=-1.0 && !IsValidAlly(npc.index, GetClosestAlly(npc.index)))))
	{
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(fl_ruina_battery_max[npc.index])
		fl_ruina_battery[npc.index]=npc.m_flAttackHappens_bullshit-gameTime;
	npc.m_flNextThinkTime = gameTime + 0.1;

	float VecAlly[3]; WorldSpaceCenter(npc.m_iTargetAlly, VecAlly);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecAlly, VecSelfNpc, true);
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < gameTime)
		npc.m_iTargetAlly = VictoriaAnvilGetTarget(npc.index, gameTime);
	
	int AI = VictoriaAnvilDefenseMode(npc.index, gameTime, npc.m_iTargetAlly, DistanceToTarget);
	switch(AI)
	{
		case 0://attack
		{
			npc.m_bisWalking = false;
			npc.m_flCharge_delay = gameTime + 0.8;
			
			if(!npc.m_flAttackHappens_bullshit && npc.m_flLifeTime>0.0)
				npc.m_flAttackHappens_bullshit = gameTime+npc.m_flLifeTime+0.2;
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
				if(CheckOpenSky(npc.m_iTargetAlly)) VecAlly[2]+=180.0;
				SubtractVectors(VecAlly, VecSelfNpc, Pathing);
				if(IsValidEntity(npc.m_iWearable2))
				{
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
}

static int VictoriaAnvilGetTarget(int iNPC, float gameTime)
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

static int VictoriaAnvilDefenseMode(int iNPC, float gameTime, int target, float distance)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);
	if(npc.m_iTarget&&b_NpcIsInvulnerable[npc.m_iTarget])
	{
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		return 0;
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * (b_we_are_reloading[npc.index] ? 20.0 : 10.0)))
		{
			npc.PlayHealSound();
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			if(!npc.m_bnew_target)
			{
				npc.StartHealing();
				npc.m_iWearable3 = ConnectWithBeam(npc.m_iWearable2, npc.m_iTarget, 30, 255, 0, 3.0, 3.0, 1.35, LASERBEAM);
				npc.Healing = true;
				npc.m_bnew_target = true;
			}
			//CreateTimer(0.1, Timer_MachineShop, npc.index, TIMER_FLAG_NO_MAPCHANGE);
			//VictorianFactory npc = view_as<VictorianFactory>(iNPC);
			float entitypos[3], dist;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) == GetTeam(npc.index)
				&& i_NpcInternalId[entity] != VictorianFragments_ID() && i_NpcInternalId[entity] != VictorianAnvil_ID())
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					dist = GetVectorDistance(vecTarget, entitypos);
					if(dist<(b_we_are_reloading[npc.index] ? 400.0 : 200.0))
					{
						IncreaseEntityDamageTakenBy(entity, 0.8, 0.3);
						
						int MaxHealth = ReturnEntityMaxHealth(entity);
						
						if(b_thisNpcIsARaid[entity])
							MaxHealth = RoundToCeil(float(MaxHealth) * 0.00725);
						else if(b_thisNpcIsABoss[entity])
							MaxHealth = RoundToCeil(float(MaxHealth) * 0.075);
						else
							MaxHealth = RoundToCeil(float(MaxHealth) * 0.8);
						
						HealEntityGlobal(npc.index, entity, float(MaxHealth / 80), 1.0);
					}
				}
			}
			vecTarget[2]+=25.0;
			spawnRing_Vectors(vecTarget, (b_we_are_reloading[npc.index] ? 400.0 : 200.0) * 2.0, 0.0, 0.0, 0.0, LASERBEAM, 30, 255, 0, 150, 1, 0.3, 3.0, 0.1, 3);
			npc.m_flNextMeleeAttack = gameTime + 0.3;
			return 0;
		}
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		return 2;
	}
	npc.StopHealing();
	npc.Healing = false;
	npc.m_bnew_target = false;
	return 1;
}

static void VictorianDroneAnvil_ClotDeath(int entity)
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

static bool CheckOpenSky(int entity)
{
	static float flMyPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flMyPos);
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];

	hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
	hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

	return (!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, entity));
}