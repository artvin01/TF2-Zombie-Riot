#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_RangeAttackSounds[] = "player/taunt_tank_shoot.wav";
static const char g_LMGAttackSounds[] = "weapons/csgo_awp_shoot.wav";
static const char g_MeleeHitSounds[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav"
};

void VictoriaTank_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victorian_tank");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tank");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_LMGAttackSounds);
	PrecacheModel("models/player/items/taunts/tank/tank.mdl");
	PrecacheModel("models/buildables/gibs/sentry1_gib1.mdl");
	PrecacheModel("models/buildables/gibs/sentry2_gib3.mdl");
	PrecacheModel("models/weapons/w_models/w_drg_ball.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	vecAng[0]=0.0;
	vecAng[1]=0.0;
	vecAng[2]=0.0;
	return VictoriaTank(vecPos, vecAng, ally, data);
}

methodmap VictoriaTank < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayLMGSound()
	{
		EmitSoundToAll(g_LMGAttackSounds, this.index, _, 70, _, 0.6);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	property float m_flTurnRate
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public VictoriaTank(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaTank npc = view_as<VictoriaTank>(CClotBody(vecPos, vecAng, "models/player/items/taunts/tank/tank.mdl", "2.5", "300000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictoriaTank_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaTank_ClotThink;
		
		f_NpcTurnPenalty[npc.index] = 0.5;
		npc.m_flSpeed = 90.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flTurnRate = 400.0;
		npc.m_flRangedSpecialDelay = 0.0;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bFUCKYOU = false;
		
		f_ExtraOffsetNpcHudAbove[npc.index] = -45.0;
		
		//Maybe used for special waves
		/*Call To Victoria activates this NPC's LMG.*/
		if(StrContains(data, "mount_lmg") != -1)
			npc.m_bFUCKYOU = true;
		/*Always activate LMG*/
		if(StrContains(data, "alway_mount_lmg") != -1)
			npc.m_fbRangedSpecialOn = true;

		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.7;
		/*LMG Turn Speed*/
		if(StrContains(data, "turnrate") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "turnrate", "");
			npc.m_flTurnRate = StringToFloat(buffers[0]);
		}

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);
		
		/*for LMG*/
		if(npc.m_bFUCKYOU || npc.m_fbRangedSpecialOn)
		{
			float Vec[3], Ang[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Ang);
			Ang[0]=0.0;
			Ang[1]=0.0;
			Ang[2]=0.0;
			GetAbsOrigin(npc.index, Vec);
			npc.m_iWearable1 = npc.EquipItemSeperate("models/weapons/w_models/w_drg_ball.mdl",_,1,1.001,_,true);
			Vec[2] += 120.0;
			TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
			
			GetAbsOrigin(npc.index, Vec);
			npc.m_iWearable2 = npc.EquipItemSeperate("models/buildables/gibs/sentry1_gib1.mdl",_,1,1.001,_,true);
			Ang[0] = 90.0;
			Ang[1] = 90.0;
			Ang[2] = 0.0;
			Vec[1] -= 70.0;
			Vec[2] += 82.0;
			TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
			
			GetAbsOrigin(npc.index, Vec);
			npc.m_iWearable3 = npc.EquipItemSeperate("models/buildables/gibs/sentry1_gib1.mdl",_,1,1.001,_,true);
			Ang[0] = 90.0;
			Ang[1] = 270.0;
			Ang[2] = 0.0;
			Vec[1] += 70.0;
			Vec[2] += 82.0;
			TeleportEntity(npc.m_iWearable3, Vec, Ang, NULL_VECTOR);
			
			GetAbsOrigin(npc.index, Vec);
			npc.m_iWearable4 = npc.EquipItemSeperate("models/buildables/gibs/sentry2_gib3.mdl",_,1,1.001,_,true);
			Ang[0] = -15.0;
			Ang[1] = 0.0;
			Ang[2] = -90.0;
			Vec[1] -= 80.0;
			Vec[2] += 80.0;
			TeleportEntity(npc.m_iWearable4, Vec, Ang, NULL_VECTOR);
			
			npc.m_iWearable5 = npc.EquipItemSeperate("models/weapons/w_models/w_drg_ball.mdl",_,1,1.001,_,true);
			Ang[0] = 0.0;
			Ang[1] = 0.0;
			Ang[2] = 0.0;
			TeleportEntity(npc.m_iWearable5, NULL_VECTOR, Ang, NULL_VECTOR);
			
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
			
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			SetEntityRenderColor(npc.m_iWearable3, 255, 168, 0, 255);
			
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			SetEntityRenderColor(npc.m_iWearable2, 255, 168, 0, 255);
			
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
			
			SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 1);
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
			
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable1);
			
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.m_iWearable5);
			MakeObjectIntangeable(npc.m_iWearable2);
			
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.m_iWearable5);
			MakeObjectIntangeable(npc.m_iWearable3);
			
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable4, "SetParent", npc.m_iWearable5);
			MakeObjectIntangeable(npc.m_iWearable4);
			
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable5, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable5);
		}

		return npc;
	}
}

static void VictoriaTank_ClotThink(int iNPC)
{
	VictoriaTank npc = view_as<VictoriaTank>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 20.0);

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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		VictoriaTank_Work(npc, gameTime, distance);
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
}

static void VictoriaTank_ClotDeath(int entity)
{
	VictoriaTank npc = view_as<VictoriaTank>(entity);

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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	
	int team = GetTeam(npc.index);
	int health = RoundToCeil(ReturnEntityMaxHealth(npc.index) / 7.5);
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	for(int i; i < 3; i++)
	{
		int other = NPC_CreateByName("npc_welder", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
	health = RoundToCeil(ReturnEntityMaxHealth(npc.index) / 8.5);
	for(int i; i < 2; i++)
	{
		int other = NPC_CreateByName("npc_pulverizer", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
}

static void VictoriaTank_Work(VictoriaTank npc, float gameTime, float distance)
{
	/*Launch the DAMMMN Rocket*/
	if(npc.m_flNextRangedAttack < gameTime)
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			float damageDeal = 600.0;
			float ProjectileSpeed = 1400.0;

			if(NpcStats_VictorianCallToArms(npc.index))
				ProjectileSpeed *= 1.25;

			npc.PlayRangeSound();

			int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,45.0);
			if(entity != -1)
			{
				//max duration of 4 seconds beacuse of simply how fast they fire
				SDKHook(entity, SDKHook_StartTouch, TankHEShell_StartTouch);
				CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
			npc.m_flNextRangedAttack = gameTime + 3.00;
		}
	}
	/*Destroy the Building*/
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 100.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt*=5.0;
						KillFeed_SetKillIcon(npc.index, "vehicle");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
						ParticleEffectAt(vecHit, "drg_cow_explosion_sparkles_blue", 1.5);
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
	/*LMG || I hate this part -Baka*/
	if(npc.m_fbRangedSpecialOn || (npc.m_bFUCKYOU&&NpcStats_VictorianCallToArms(npc.index)))
	{
		float eyePitch[3], subPitch[3], VecSelfNpc[3];
		int GetClosestEnemyToAttack = GetClosestTarget(npc.index, .CanSee=true);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		GetAbsOrigin(npc.m_iWearable1, VecSelfNpc);
		CClotBody LMG = view_as<CClotBody>(npc.m_iWearable1);
		LMG.FaceTowards(vecTarget, npc.m_flTurnRate);
		GetEntPropVector(npc.m_iWearable1, Prop_Data, "m_angRotation", subPitch);
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
		subPitch[2]=0.0;
		subPitch[0]=0.0;
		subPitch[1] = fixAngle(npc.UTIL_AngleDiff(subPitch[1], eyePitch[1]));
		SDKCall_SetLocalAngles(npc.m_iWearable5, subPitch);
		WorldSpaceCenter(npc.index, VecSelfNpc);
		distance = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(IsValidEnemy(npc.index,GetClosestEnemyToAttack) && npc.m_flRangedSpecialDelay < gameTime && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 30.0))
		{
			npc.PlayLMGSound();
			float x = GetRandomFloat( -0.045, 0.045 ) + GetRandomFloat( -0.045, 0.045 );
			float y = GetRandomFloat( -0.045, 0.045 ) + GetRandomFloat( -0.045, 0.045 );
			
			float vecDirShooting[3], vecRight[3], vecUp[3];
			
			vecTarget[2] += 15.0;
			MakeVectorFromPoints(VecSelfNpc, vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);
			GetEntPropVector(npc.m_iWearable1, Prop_Data, "m_angRotation", eyePitch);
			vecDirShooting[1] = eyePitch[1];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			
			float damage = 5.0;
			if(distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*6.0)
				damage *= NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*6.0 / distance;
			if(damage<1.0)
				damage=1.0;
			damage *= 3.5;
			KillFeed_SetKillIcon(npc.index, "minigun");
			FireBullet(npc.index, npc.m_iWearable1, VecSelfNpc, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer02_blue");
			npc.m_flRangedSpecialDelay = gameTime + 0.1;
		}
	}
	/*else if(npc.m_bFUCKYOU)
	{
		float eyePitch[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
		eyePitch[0]=0.0;
		eyePitch[2]=0.0;
		SetEntPropVector(npc.m_iWearable5, Prop_Data, "m_angRotation", eyePitch);
	}*/
}

static void TankHEShell_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	if(target > 0 && target < MAXENTITIES)
		KillFeed_SetKillIcon(owner, "tf_projectile_rocket");
}