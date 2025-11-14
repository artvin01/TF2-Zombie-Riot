#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_AttackReadySounds[] = "weapons/sentry_spot_client.wav";
static const char g_RangeAttackSounds[] = "weapons/sentry_shoot3.wav";

static bool ISVOLI[MAXENTITIES];
static int NPCId;

void VictorianDroneFragments_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Fragments");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_fragments");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_fragments");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId=NPC_Add(data);
}

int VictorianFragments_ID()
{
	return NPCId;
}

static void ClotPrecache()
{
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_AttackReadySounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheModel("models/combine_apc_dynamic.mdl");
	PrecacheModel("models/buildables/gibs/sentry1_gib1.mdl");
	PrecacheModel("models/buildables/gibs/sentry2_gib3.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	vecAng[0]=0.0;
	vecAng[1]=-90.0;
	vecAng[2]=0.0;
	return VictorianDroneFragments(vecPos, vecAng, ally, data);
}

methodmap VictorianDroneFragments < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound() 
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayFinedSound() 
	{
		if(!this.m_bFUCKYOU)
			EmitSoundToAll(g_AttackReadySounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_bFUCKYOU=true;
	}
	
	property float m_flLifeTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_fXPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_fZPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_fYPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flNextPosDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property int m_iMainTarget
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	
	public void SaveTreePos(float VecEnemy[3])
	{
		this.m_fXPosSave=VecEnemy[0];
		this.m_fZPosSave=VecEnemy[1];
		this.m_fYPosSave=VecEnemy[2];
	}
	public void LoadTreePos(float VecEnemy[3])
	{
		VecEnemy[0]=this.m_fXPosSave;
		VecEnemy[1]=this.m_fZPosSave;
		VecEnemy[2]=this.m_fYPosSave;
	}
	
	public VictorianDroneFragments(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneFragments npc = view_as<VictorianDroneFragments>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "3000", ally, _, true, .CustomThreeDimensions = {20.0, 20.0, 20.0}, .CustomThreeDimensionsextra = {-20.0, -20.0, -20.0}));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictorianDroneFragments_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianDroneFragments_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianDroneFragments_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "obj_sentrygun2");
		
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iAmmo = 3;
		npc.m_iMaxAmmo=3;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextPosDelay = 0.0;
		
		ISVOLI[npc.index]=false;
		b_we_are_reloading[npc.index]=false;
		npc.m_fXPosSave=0.0;
		npc.m_fZPosSave=0.0;
		npc.m_fYPosSave=0.0;
		npc.m_flLifeTime=20.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_IgnoreAllCollisionNPC[npc.index] = true;
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = true;
		npc.m_bFUCKYOU = false;
		npc.Anger = false;
		Is_a_Medic[npc.index] = true;
		
		bool FactorySpawndo;
		static char countext[20][1024];
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
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Victoria Fragments MK2");
			}
			else if(StrContains(countext[i], "factory") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "factory", "");
				FactorySpawndo=true;
			}
			else if(StrContains(countext[i], "isvoli") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "isvoli", "");
				ISVOLI[npc.index]=true;
			}
			else if(StrContains(countext[i], "overridetarget") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "overridetarget", "");
				npc.m_iMainTarget = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "tracking") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "tracking", "");
				npc.m_iState = -1;
			}
		}
		
		if(npc.m_flLifeTime==-1.0||ISVOLI[npc.index])
		{
			npc.m_flLifeTime=-1.0;
			AddNpcToAliveList(npc.index, 1);
		}

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("models/buildables/gibs/sentry1_gib1.mdl",_,1,1.001,_,true);
		Ang[0] = -90.0;
		Ang[1] = 270.0;
		Vec[1] -= 36.5;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);

		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("models/buildables/gibs/sentry2_gib3.mdl",_,1,1.001,_,true);
		Ang[0] = 30.0;
		Ang[1] = 0.0;
		Ang[2] = -90.0;
		Vec[0] -= 10.0;
		Vec[1] -= 31.5;
		Vec[2] -= 21.0;
		TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable3 = npc.EquipItemSeperate("models/buildables/gibs/sentry2_gib3.mdl",_,1,1.001,_,true);
		Ang[0] = 30.0;
		Ang[1] = 0.0;
		Ang[2] = -90.0;
		Vec[0] -= 10.0;
		Vec[1] -= 47.5;
		Vec[2] -= 21.0;
		TeleportEntity(npc.m_iWearable3, Vec, Ang, NULL_VECTOR);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable4 = npc.EquipItemSeperate("models/props_teaser/saucer.mdl",_,1,1.001,_,true);
		SetEntityRenderColor(npc.m_iWearable4, 80, 50, 50, 255);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable1);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable2);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable3);
		Ang[0] = 0.0;
		Ang[1] = -90.0;
		Ang[2] = 0.0;
		TeleportEntity(npc.m_iWearable4, Vec, Ang, NULL_VECTOR);
		TeleportEntity(npc.index, NULL_VECTOR, {0.0,0.0,0.0}, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable4, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable4);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({229, 235, 52, 200}));
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

static void VictorianDroneFragments_ClotThink(int iNPC)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(iNPC);

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
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if((npc.m_flLifeTime>0.0 && npc.m_flAttackHappens_bullshit && gameTime > npc.m_flAttackHappens_bullshit)
	||(npc.m_flLifeTime!=-1.0 &&  !IsValidAlly(npc.index, GetClosestAlly(npc.index))))
	{
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}
	//Is old Ver isvoli
	else if(ISVOLI[npc.index] && npc.m_flAttackHappens_bullshit)
	{
		int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.01);
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth")-maxhealth;
		if(health<=0)
		{
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return;
		}
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
	}
	
	float VecEnemy[3];
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(ISVOLI[npc.index] && !IsValidEntity(npc.m_iWearable5))
	{
		float Ang[3];
		npc.GetAttachment("m_vecAbsOrigin", VecSelfNpc, Ang);
		npc.m_iWearable5 = ParticleEffectAt_Parent(VecSelfNpc, "utaunt_poweraura_teamcolor", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
		npc.GetAttachment("", VecSelfNpc, Ang);
	}
	switch(npc.m_iState)
	{
		case -2:
		{
			npc.LoadTreePos(VecEnemy);
			if(GetVectorDistance(VecEnemy, VecSelfNpc, true)<(200.0*200.0))
			{
				npc.m_flSpeed = 0.0;
				npc.SetVelocity({0.0,0.0,0.0});
				npc.m_bisWalking = false;
				if(npc.m_flNextPosDelay < gameTime)
					npc.m_iState=-1;
			}
			else
			{
				float Pathing[3], Npvel[3], NPCAng[3];
				SubtractVectors(VecEnemy, VecSelfNpc, Pathing);
				npc.GetVelocity(Npvel);
				float NPCSpeed = npc.m_flSpeed;
				NormalizeVector(Pathing, Npvel);
				ScaleVector(Npvel, NPCSpeed);
				GetVectorAngles(Npvel, NPCAng);
				npc.SetVelocity(Npvel);
				npc.FaceTowards(VecEnemy, 20000.0);
				if(!IsValidEnemy(npc.index,npc.m_iTarget))
				{
					NPCAng[2]=0.0;
					NPCAng[0]=0.0;
					SetEntPropVector(npc.index, Prop_Data, "m_angRotation", NPCAng);
				}
				npc.m_flNextPosDelay=gameTime+10.0+GetRandomRetargetTime();
			}
			
			if(npc.m_flGetClosestTargetTime < gameTime)
			{
				npc.m_iTarget = VictoriaFragmentsGetTarget(npc);
				npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			}
			if(IsValidEnemy(npc.index,npc.m_iTarget))
			{
				WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				float Pathing[3], NPCAng[3];
				SubtractVectors(VecEnemy, VecSelfNpc, Pathing);
				NormalizeVector(Pathing, Pathing);
				GetVectorAngles(Pathing, NPCAng);
				NPCAng[2]=0.0;
				NPCAng[0]=0.0;
				SetEntPropVector(npc.index, Prop_Data, "m_angRotation", NPCAng);
				npc.PlayFinedSound();
				float flDistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
				VictoriaFragmentsAssaultMode(npc, gameTime, flDistanceToTarget);
			}
			else
			{
				npc.m_iAmmo = 3;
				npc.m_flGetClosestTargetTime=0.0;
				npc.m_bFUCKYOU = false;
			}
		}
		case -1:
		{
			npc.m_bisWalking = true;
			npc.SetVelocity({0.0,0.0,0.0});
			int LZ = -1;
			if(IsValidEnemy(npc.index,npc.m_iMainTarget))
				LZ = npc.m_iMainTarget;
			else
				LZ = GetClosestTarget(npc.index);
			if(IsValidEnemy(npc.index,LZ))
			{
				WorldSpaceCenter(LZ, VecEnemy);
				VecEnemy[2]+=65.0;
				npc.SaveTreePos(VecEnemy);
				npc.m_iState=-2;
				if(npc.m_flLifeTime>0.0)
					npc.m_flAttackHappens_bullshit = gameTime+npc.m_flLifeTime+0.2;
				npc.Anger = true;
			}
		}
		case 0:
		{
			npc.SetVelocity({0.0,0.0,0.0});
			int LZ = -1;
			if(IsValidEnemy(npc.index,npc.m_iMainTarget))
				LZ = npc.m_iMainTarget;
			else
				LZ = GetClosestTarget(npc.index);
			if(IsValidEnemy(npc.index,LZ))
			{
				WorldSpaceCenter(LZ, VecEnemy);
				if(CheckOpenSky(LZ)) VecEnemy[2]+=180.0;
				npc.SaveTreePos(VecEnemy);
				npc.m_iState=1;
			}
		}
		case 1:
		{
			npc.LoadTreePos(VecEnemy);
			if(GetVectorDistance(VecEnemy, VecSelfNpc, true)<(200.0*200.0))
			{
				//float NPCAng[3];
				npc.m_flSpeed = 0.0;
				VecSelfNpc[2] += 500.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, VecSelfNpc);
				npc.m_flNextThinkTime = gameTime + 0.2;
				npc.m_iState=2;
				if(npc.m_flLifeTime>0.0)
					npc.m_flAttackHappens_bullshit = gameTime+npc.m_flLifeTime+0.2;
				npc.Anger = true;
			}
			else
			{
				float Pathing[3], Npvel[3], NPCAng[3];
				SubtractVectors(VecEnemy, VecSelfNpc, Pathing);
				npc.GetVelocity(Npvel);
				float NPCSpeed = npc.m_flSpeed;
				NormalizeVector(Pathing, Npvel);
				ScaleVector(Npvel, NPCSpeed);
				GetVectorAngles(Npvel, NPCAng);
				npc.SetVelocity(Npvel);
				npc.FaceTowards(VecEnemy, 20000.0);
				NPCAng[2]=0.0;
				NPCAng[0]=0.0;
				SetEntPropVector(npc.index, Prop_Data, "m_angRotation", NPCAng);
			}
		}
		case 2:
		{
			npc.m_bisWalking = false;
			if(npc.m_flGetClosestTargetTime < gameTime)
			{
				npc.m_iTarget = VictoriaFragmentsGetTarget(npc);
				npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			}
			if(IsValidEnemy(npc.index,npc.m_iTarget))
			{
				WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				float Pathing[3], NPCAng[3];
				SubtractVectors(VecEnemy, VecSelfNpc, Pathing);
				NormalizeVector(Pathing, Pathing);
				GetVectorAngles(Pathing, NPCAng);
				NPCAng[2]=0.0;
				NPCAng[0]=0.0;
				SetEntPropVector(npc.index, Prop_Data, "m_angRotation", NPCAng);
				npc.PlayFinedSound();
				float flDistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
				VictoriaFragmentsAssaultMode(npc, gameTime, flDistanceToTarget);
			}
			else
			{
				npc.m_iAmmo = 3;
				npc.m_flGetClosestTargetTime=0.0;
				npc.m_bFUCKYOU = false;
			}
		}
	}
}

static  int VictoriaFragmentsGetTarget(VictorianDroneFragments npc)
{
	int GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(IsValidEnemy(npc.index,GetClosestEnemyToAttack))
	{
		float VecEnemy[3]; WorldSpaceCenter(GetClosestEnemyToAttack, VecEnemy);
		if(GetVectorDistance(VecEnemy, VecSelfNpc, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
			return GetClosestEnemyToAttack;
		else
		{
			GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
			if(IsValidEnemy(npc.index, GetClosestEnemyToAttack))
			{
				WorldSpaceCenter(GetClosestEnemyToAttack, VecEnemy);
				if(GetVectorDistance(VecEnemy, VecSelfNpc, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
					return GetClosestEnemyToAttack;
			}
		}
	}
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))
	{
		GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		if(IsValidEnemy(npc.index, GetClosestEnemyToAttack))
		{
			float VecEnemy[3]; WorldSpaceCenter(GetClosestEnemyToAttack, VecEnemy);
			if(GetVectorDistance(VecEnemy, VecSelfNpc, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
				return GetClosestEnemyToAttack;
		}
	}
	return -1;
}

static void VictoriaFragmentsAssaultMode(VictorianDroneFragments npc, float gameTime, float distance)
{
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(gameTime > npc.m_flNextRangedAttack)
			{
				npc.PlayRangeSound();
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }, .vecSwingStartOffset = 10.0))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3];
					WorldSpaceCenter(npc.index, origin);
					ShootLaser(npc.index, "bullet_tracer02_blue", origin, vecHit, false );
					float Cooldown = 3.0;
					if(npc.m_iAmmo < 1)
						npc.m_iAmmo = 3;
					else
					{
						npc.m_iAmmo --;
						Cooldown = 0.3;
					}
					npc.m_flNextRangedAttack = gameTime + Cooldown;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 25.0;
						if(b_we_are_reloading[npc.index])
							damageDealt +=50.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 4.0;
						int GetWave = Waves_GetRoundScale()+1;
						if(GetWave > 10)
							GetWave=10;
						damageDealt*=float(GetWave)*0.1;
						Explode_Logic_Custom(damageDealt/(b_we_are_reloading[npc.index] ? 5.0 : 10.0), npc.index, npc.index, -1, vecHit, (b_we_are_reloading[npc.index] ? 125.0 : 85.0),_,_,_,4, _, 1.0);
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}
	else
	{
		if(npc.m_bFUCKYOU)
			npc.m_flAttackHappens = gameTime+1.0;
		npc.m_flGetClosestTargetTime=0.0;
	}
}

static void VictorianDroneFragments_ClotDeath(int entity)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(entity);

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

static Action VictorianDroneFragments_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
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