#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_AttackReadySounds[] = "weapons/sentry_spot_client.wav";
static const char g_AttackRocketSounds[] = "weapons/sentry_shoot3.wav";
static bool MK2[MAXENTITIES];
static bool Limit[MAXENTITIES];

void VictorianDroneAnvil_MapStart()
{
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_AttackReadySounds);
	PrecacheSound(g_AttackRocketSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "victoria_anvil");
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
	return VictorianDroneAnvil(client, vecPos, vecAng, ally, data);
}

methodmap VictorianDroneAnvil < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAttackSound() 
	{
		EmitSoundToAll(g_AttackRocketSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_AttackReadySounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public VictorianDroneAnvil(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "8000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		bool FactorySpawn;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			if(!StrContains(countext[i], "factory"))FactorySpawn=true;
			if(!StrContains(countext[i], "mk2"))MK2[npc.index]=true;
			else MK2[npc.index]=false;
			if(!StrContains(countext[i], "limit"))Limit[npc.index]=true;
			else Limit[npc.index]=false;
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
		
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_IgnoreAllCollisionNPC[npc.index]=true;
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = true;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("head", "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl",_,1,1.0,_,true);
		Vec[0] -= 36.5;
		Vec[1] -= 36.5;
		Vec[2] -= 5.5;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("head", "models/props_teaser/saucer.mdl",_,1,1.0,_,true);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
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
		
		GetAbsOrigin(npc.index, Vec);
		if(FactorySpawn)
		{
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
				{
					GetAbsOrigin(entity, Vec);
					break;
				}
			}
		}
		Vec[2]+=45.0;
		TeleportEntity(npc.index, Vec, NULL_VECTOR, NULL_VECTOR);
		NPC_StopPathing(npc.index);
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
	else npc.m_flSpeed = NpcStats_VictorianCallToArms(npc.index) ? 400.0 : 300.0;

	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)) || (gameTime > npc.m_flAttackHappens && Limit[npc.index]))
	{
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTargetAlly;

	float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
	
	if(npc.m_flGetClosestTargetTime < gameTime)
		target = VictoriaAnvilGetTarget(npc.index, gameTime, (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0));
	
	
	int AI = VictoriaAnvilDefenseMode(npc.index, gameTime, target, DistanceToTarget);
	switch(AI)
	{
		case 0://attack
		{
			npc.m_bisWalking = false;
			npc.m_flCharge_delay = gameTime + 0.8;
		}
		case 1://cooldown
		{
			/*none*/
		}
		case 3://notfound
		{
			if(gameTime > npc.m_flCharge_delay)
			{
				npc.m_bisWalking = true;
				float Pathing[3], Npvel[3], NPCAng[3];
				MakeObjectIntangeable(npc.index);
				SubtractVectors(SET_XZY_POS[npc.index], VecSelfNpc, Pathing);
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

int VictoriaAnvilGetTarget(int iNPC, float gameTime, float distance)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			npc.m_iTargetAlly = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	npc.m_flGetClosestTargetTime = gameTime + 1.0;
	return npc.m_iTargetAlly;
}

int VictoriaAnvilDefenseMode(int iNPC, float gameTime, int target, float distance)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(iNPC);
	if(npc.m_iOverlordComboAttack < 1 || gameTime < npc.m_flCharge_delay)
		return 2;
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
		{
			npc.PlayAttackSound();
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
			{
				target = TR_GetEntityIndex(swingTrace);	
					
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float origin[3], angles[3];
				view_as<CClotBody>(npc.index).GetAttachment("partyhat", origin, angles);
				ShootLaser(npc.index, "bullet_tracer01_red", origin, vecHit, false);
				npc.m_flNextMeleeAttack = gameTime + 0.3;
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 25.0;
					if(MK2[npc.index])
					{
						damageDealt +=50.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 4.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(!ShouldNpcDealBonusDamage(target))
							Explode_Logic_Custom(damageDealt/5.0, npc.index, npc.index, -1, vecHit, 125.0,_,_,_,3, _, 1.0);
					}
					else
					{
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 4.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(!ShouldNpcDealBonusDamage(target))
							Explode_Logic_Custom(damageDealt/10.0, npc.index, npc.index, -1, vecHit, 85.0,_,_,_,3, _, 1.0);
					}
				}
				npc.m_iOverlordComboAttack--;
			}
			delete swingTrace;
			return 0;
		}
		return 3;
	}
	return 1;
}

static void ClotDeath(int entity)
{
	VictorianDroneAnvil npc = view_as<VictorianDroneAnvil>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2)
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

public bool LookPoint(int client, float flAng[3], float flPos[3], float pos[3])
{
	Handle trace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterIgnorePlayersAndSelf, client);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

static bool TraceEntityFilterIgnorePlayersAndSelf(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;

	if(1 <= entity <= MaxClients)
		return false;

	return true;
}