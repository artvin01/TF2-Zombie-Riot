#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_LoopSounds[] = "mvm/giant_heavy/giant_heavy_loop.wav";

static const char g_MeleeHitSounds[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav"
};
static const char g_HornSounds[][] = {
	"ambient_mp3/mvm_warehouse/car_horn03.mp3",
	"ambient_mp3/mvm_warehouse/car_horn05.mp3"
};

void VestanAssaultVehicle_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vestan Assault Vehicle");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vestan_assault_vehicle");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_assault_vehicle");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Vesta;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_HornSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_LoopSounds);
	PrecacheModel("models/combine_apc_dynamic.mdl");
	PrecacheModel("models/props_2fort/chimney007.mdl");
	PrecacheModel("models/props_2fort/chimney008.mdl");
	PrecacheModel("models/props_hydro/keg_large.mdl");
	PrecacheSound("weapons/stinger_fire1.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	vecAng = view_as<float>( { 0.0, 0.0, 0.0 } );
	return VestanAssaultVehicle(vecPos, vecAng, team, data);
}

methodmap VestanAssaultVehicle < CClotBody
{
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_HornSounds[GetRandomInt(0, sizeof(g_HornSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 75);
	}
	public void PlayLoopSound()
	{
		if(!this.m_fbRangedSpecialOn)
		{
			EmitSoundToAll(g_LoopSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 20, _, 0.9);
			this.m_fbRangedSpecialOn=true;
		}
	}

	property float m_flSpawnTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flStartSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpeedModify
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flStartSpeed_ForData
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flSpeedModify_ForData
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flSpawnMeleeArmor
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flSpawnRangedArmor
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flSpawnHealth
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flSpawnExtraDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property int m_iMode
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	
	public VestanAssaultVehicle(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VestanAssaultVehicle npc = view_as<VestanAssaultVehicle>(CClotBody(vecPos, vecAng, "models/combine_apc_dynamic.mdl", "0.8", "30000", ally, .isGiant = true));
		i_NpcWeight[npc.index] = 5;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
		func_NPCDeath[npc.index] = VestanAssaultVehicle_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VestanAssaultVehicle_OnTakeDamage;
		func_NPCThink[npc.index] = VestanAssaultVehicle_ClotThink;

		KillFeed_SetKillIcon(npc.index, "resurfacer");
		npc.m_iState = 0;
		npc.m_iMode = 0;
		npc.g_TimesSummoned = 0;
		npc.m_iChanged_WalkCycle=-1;
		npc.m_flReloadDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.Anger = false;
		
		npc.m_flSpeed = 50.0;
		npc.m_flStartSpeed = 50.0;
		npc.m_flSpeedModify = 1.0;
		npc.m_flStartSpeed_ForData = 75.0;
		npc.m_flSpeedModify_ForData = 1.2;
		npc.m_flSpawnMeleeArmor = 1.0;
		npc.m_flSpawnRangedArmor = 1.0;
		npc.m_flSpawnHealth = 1.0;
		npc.m_flSpawnExtraDamage = 1.0;
		f_NpcTurnPenalty[npc.index] = 0.6;
		npc.m_iMaxAmmo=3;
		npc.m_flSpawnTime = GetGameTime();
		
		npc.m_flMeleeArmor = 1.50;
		npc.m_flRangedArmor = 1.0;
		npc.m_bDissapearOnDeath = true;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		static char countext[14][512];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "halfstartspeed") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "halfstartspeed", "");
				npc.m_flStartSpeed_ForData = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "halfspeedmodify") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "halfspeedmodify", "");
				npc.m_flSpeedModify_ForData = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "startspeed") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "startspeed", "");
				npc.m_flStartSpeed = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "speedmodify") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "speedmodify", "");
				npc.m_flSpeedModify = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "player_priority") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "player_priority", "");
				npc.m_iState = 1;
			}
			else if(StrContains(countext[i], "meleearmor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "meleearmor", "");
				npc.m_flSpawnMeleeArmor = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "rangedarmor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "rangedarmor", "");
				npc.m_flSpawnRangedArmor = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "extrahealth") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "health", "");
				npc.m_flSpawnHealth = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "extradamage") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "extradamage", "");
				npc.m_flSpawnExtraDamage = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "whonpc") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "whonpc", "");
				npc.g_TimesSummoned = StringToInt(countext[i]);
				if(!npc.g_TimesSummoned)
					npc.g_TimesSummoned = NPC_GetByPlugin(countext[i]);
				//PrintToChatAll("NPC ID: %i", npc.g_TimesSummoned);
			}
			else if(StrContains(countext[i], "maxspawn") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "maxspawn", "");
				npc.m_iMaxAmmo = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "mode") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "mode", "");
				npc.m_iMode = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "spawner") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "spawner", "");
				if(!VIPBuilding_Active())
				{
					for(int ii; ii < ZR_MAX_SPAWNERS; ii++)
					{
						if(!i_ObjectsSpawners[ii] || !IsValidEntity(i_ObjectsSpawners[ii]))
						{
							Spawns_AddToArray(EntIndexToEntRef(npc.index), true);
							i_ObjectsSpawners[ii] = EntIndexToEntRef(npc.index);
							break;
						}
					}
				}
			}
		}
		
		fl_ruina_battery_max[npc.index] = 20.0;
		fl_ruina_battery[npc.index] = 0.0;
		npc.m_iAmmo=npc.m_iMaxAmmo;
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_2fort/chimney007.mdl",_,1,1.001,_,true);
		Ang = view_as<float>( { 0.0, -90.0, -90.0 } );
		Vec[0] += 37.5;
		Vec[2] += 51.2;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderColor(npc.m_iWearable1, 136, 136, 136, 255);

		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_2fort/chimney008.mdl",_,1,1.001,_,true);
		Ang = view_as<float>( { -90.0, 180.0, 0.0 } );
		Vec[0] -= 102.4;
		Vec[2] += 51.2;
		TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
		SetVariantString("0.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 102, 102, 102, 255);

		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable3 = npc.EquipItemSeperate("models/props_hydro/keg_large.mdl",_,1,1.001,_,true);
		Ang = view_as<float>( { -90.0, 0.0, 0.0 } );
		Vec[0] -= 51.2;
		Vec[2] += 51.2;
		TeleportEntity(npc.m_iWearable3, Vec, Ang, NULL_VECTOR);
		SetVariantString("0.96");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 136, 136, 136, 255);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable1);
		SetVariantString("spinslow");
		AcceptEntityInput(npc.m_iWearable1, "SetAnimation");
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable2);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable3);
		
		return npc;
	}
}

public void VestanAssaultVehicle_ClotThink(int iNPC)
{
	VestanAssaultVehicle npc = view_as<VestanAssaultVehicle>(iNPC);
	
	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		if(npc.m_iState == 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
			b_DoNotChangeTargetTouchNpc[npc.index] = 1;
			if(npc.m_iTarget < 1)
			{
				b_DoNotChangeTargetTouchNpc[npc.index] = 0;
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
			npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		}
	}
	
	float TimeMultiplier = 1.0;
	TimeMultiplier = gameTime - npc.m_flSpawnTime;

	TimeMultiplier *= 0.50;

	if(TimeMultiplier > 20.0)
		TimeMultiplier = 20.0;
	else if(TimeMultiplier > 7.0)
	{
		if(npc.m_iChanged_WalkCycle!=2)
		{
			SetVariantString("spinfast");
			AcceptEntityInput(npc.m_iWearable1, "SetAnimation");
			npc.m_iChanged_WalkCycle=2;
		}
	}
	else if(TimeMultiplier > 5.0)
	{
		if(npc.m_iChanged_WalkCycle!=1)
		{
			SetVariantString("idle");
			AcceptEntityInput(npc.m_iWearable1, "SetAnimation");
			npc.m_iChanged_WalkCycle=1;
		}
	}
	else if(TimeMultiplier <= 1.0)
	{
		TimeMultiplier = 1.0;
		if(npc.m_iChanged_WalkCycle!=0)
		{
			SetVariantString("spinslow");
			AcceptEntityInput(npc.m_iWearable1, "SetAnimation");
			npc.m_iChanged_WalkCycle=0;
		}
	}
	fl_ruina_battery[npc.index] = TimeMultiplier;
	npc.m_flSpeed = (npc.m_flStartSpeed * TimeMultiplier * npc.m_flSpeedModify);
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		VestanAssaultVehicle_Work(npc, gameTime, distance);
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
	}
	npc.PlayLoopSound();
}

static void VestanAssaultVehicle_Work(VestanAssaultVehicle npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappens = gameTime+0.1;
				npc.m_flAttackHappens_bullshit = gameTime+0.29;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 6.0;
						damageDealt *= (npc.m_flSpeed * 0.1);
						if(damageDealt<100.0)
							damageDealt=100.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt*=33.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					}
				}
				delete swingTrace;
				
				if(npc.m_iAmmo && ShouldNpcDealBonusDamage(npc.m_iTarget) && npc.g_TimesSummoned)
				{
					float RNGPos[3]; WorldSpaceCenter(npc.index, RNGPos);
					RNGPos[0] += GetRandomFloat(-5.0, 5.0);
					RNGPos[1] += GetRandomFloat(-5.0, 5.0);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
					
					if(MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
					{
						int entity = NPC_CreateById(npc.g_TimesSummoned, -1, RNGPos, ang, GetTeam(npc.index));
						if(entity > MaxClients)
						{
							if(GetTeam(npc.index) != TFTeam_Red)
								Zombies_Currently_Still_Ongoing++;
							int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index))*npc.m_flSpawnHealth);
							SetEntProp(entity, Prop_Data, "m_iHealth", health);
							SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
							
							fl_Extra_MeleeArmor[entity] = npc.m_flSpawnMeleeArmor;
							fl_Extra_RangedArmor[entity] = npc.m_flSpawnRangedArmor;
							fl_Extra_Damage[entity] = npc.m_flSpawnExtraDamage;
						}
					}
					npc.m_iAmmo--;
				}
				npc.m_flNextMeleeAttack = gameTime + (NpcStats_VestanCallToArms(npc.index) ? 1.0 : 1.5);
				npc.m_flSpawnTime = gameTime;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + (NpcStats_VestanCallToArms(npc.index) ? 1.0 : 1.5);
			}
		}
	}
}

static Action VestanAssaultVehicle_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VestanAssaultVehicle npc = view_as<VestanAssaultVehicle>(victim);
	if(attacker <= 0)
		return Plugin_Continue;
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
	{
		if(!npc.Anger)
		{
			npc.m_flStartSpeed = npc.m_flStartSpeed_ForData;
			npc.m_flSpeedModify = npc.m_flSpeedModify_ForData;
			npc.m_flRangedArmor = 0.5;
			npc.PlayAngerSound();
			npc.Anger = true;
		}
	}
	return Plugin_Continue;
}

static void VestanAssaultVehicle_NPCDeath(int entity)
{
	VestanAssaultVehicle npc = view_as<VestanAssaultVehicle>(entity);
	
	StopSound(npc.index, SNDCHAN_STATIC, g_LoopSounds);
	StopSound(npc.index, SNDCHAN_STATIC, g_LoopSounds);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	
	if(npc.m_iAmmo && npc.m_iMode==1 && npc.g_TimesSummoned)
	{
		for(int i; i < 3; i++)
		{
			pos[2] += 5.0;
			pos[0] += GetRandomFloat(-5.0, 5.0);
			pos[1] += GetRandomFloat(-5.0, 5.0);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			if(MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
			{
				int SpawnNPC = NPC_CreateById(npc.g_TimesSummoned, -1, pos, ang, GetTeam(npc.index));
				if(SpawnNPC > MaxClients)
				{
					if(GetTeam(npc.index) != TFTeam_Red)
						Zombies_Currently_Still_Ongoing++;
					int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index))*npc.m_flSpawnHealth);
					SetEntProp(SpawnNPC, Prop_Data, "m_iHealth", health);
					SetEntProp(SpawnNPC, Prop_Data, "m_iMaxHealth", health);
					
					fl_Extra_MeleeArmor[SpawnNPC] = npc.m_flSpawnMeleeArmor;
					fl_Extra_RangedArmor[SpawnNPC] = npc.m_flSpawnRangedArmor;
					fl_Extra_Damage[SpawnNPC] = npc.m_flSpawnExtraDamage;
					b_StaticNPC[SpawnNPC] = b_StaticNPC[npc.index];
					if(b_StaticNPC[SpawnNPC])
						AddNpcToAliveList(SpawnNPC, 1);
				}
			}
		}
	}
}