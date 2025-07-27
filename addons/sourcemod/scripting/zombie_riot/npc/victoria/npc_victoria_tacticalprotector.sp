#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

static const char g_MeleeAttackSounds[] = "ambient/materials/metal_groan.wav";

static const char g_DronPingSounds[] = "misc/rd_finale_beep01.wav";

static const char g_MeleeHitSounds[] = "npc/scanner/cbot_discharge1.wav";




static bool Fragments[MAXENTITIES];

void Victorian_TacticalProtector_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_DronPingSounds);
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheModel(LASERBEAM);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Tactical Protector");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_protector");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tacticalprotectors"); 
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaProtector(vecPos, vecAng, ally, data);
}

methodmap VictoriaProtector < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDronPingSound() 
	{
		EmitSoundToAll(g_DronPingSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public VictoriaProtector(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaProtector npc = view_as<VictoriaProtector>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.45", "15000", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		func_NPCDeath[npc.index] = view_as<Function>(VictoriaProtector_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaProtector_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaProtector_ClotThink);
		
		FactorySpawn[npc.index]=false;
		MK2[npc.index]=false;
		Limit[npc.index]=false;
		Fragments[npc.index]=false;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			if(!StrContains(countext[i], "factory"))FactorySpawn[npc.index]=true;
			else if(!StrContains(countext[i], "mk2"))MK2[npc.index]=true;
			else if(!StrContains(countext[i], "limit"))Limit[npc.index]=true;
			else if(!StrContains(countext[i], "fragments"))Fragments[npc.index]=true;
		}
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bFUCKYOU = false;
		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_bisWalking = true;
		npc.m_flSpeed = 280.0;
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 100, 75, 75, 255);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_war_helmet/sbox2014_war_helmet.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/grfs_soldier.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void VictoriaProtector_ClotThink(int iNPC)
{
	VictoriaProtector npc = view_as<VictoriaProtector>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTarget;

	float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
	
	if(npc.m_flGetClosestTargetTime < gameTime)
		target = VictoriaProtectorGetTarget(npc.index, gameTime);
		
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flSpeed = 0.0;
			npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			npc.StopPathing();
		}
		return;
	}

	if(!npc.m_bFUCKYOU)
	{
		if(FactorySpawn[npc.index])
		{
			bool NoFactory=true;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
				{
					NoFactory=false;
					WorldSpaceCenter(entity, VecSelfNpc);
				}
			}
			if(NoFactory)
			{
				npc.m_bFUCKYOU=true;
				npc.Anger=true;
				return;
			}
		}
		if(npc.m_fbRangedSpecialOn)
		{
			if(IsValidEntity(npc.m_iWearable4))
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					if(npc.m_iChanged_WalkCycle != 4)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 4;
						npc.m_flSpeed = 0.0;
						npc.SetActivity("ACT_MP_STAND_MELEE");
						npc.AddGesture("ACT_MP_STUN_END");
						npc.StopPathing();
					}
					char Adddeta[512];
					if(FactorySpawn[npc.index])
						FormatEx(Adddeta, sizeof(Adddeta), "factory");
					if(MK2[npc.index])
						FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
					if(Limit[npc.index])
						FormatEx(Adddeta, sizeof(Adddeta), "%s;limit", Adddeta);
					VecSelfNpc[2]+=45.0;
					int spawn_index;
					if(Fragments[npc.index])
						spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
					else
						spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
					if(spawn_index > MaxClients)
					{
						int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.35);
						NpcAddedToZombiesLeftCurrently(spawn_index, true);
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
						IncreaseEntityDamageTakenBy(spawn_index, 0.05, 1.0);
					}
					npc.m_bFUCKYOU=true;
					npc.m_flNextThinkTime = gameTime + 1.0;
				}
				else if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.m_bisWalking = false;
					npc.StopPathing();
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.AddGesture("ACT_MP_STUN_MIDDLE");
					npc.m_flNextRangedAttack = gameTime + 0.9;
				}
			}
			else
			{
				VecSelfNpc[2]+=85.0;
				npc.m_iWearable4 = ParticleEffectAt_Parent(VecSelfNpc, "cart_flashinglight_red", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
				npc.PlayDronPingSound();
				npc.m_flNextMeleeAttack = gameTime + 5.0;
			}
			return;
		}
	}

	int AI = VictoriaProtectorAssaultMode(npc.index, gameTime, target, DistanceToTarget);
	switch(AI)
	{
		case 0, 1://notfound, cooldown
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.m_flSpeed = 180.0;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.StartPathing();
			}
		}
		case 2://attack
		{
			if(npc.m_iChanged_WalkCycle != 0)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flSpeed = 100.0;
				npc.SetActivity("ACT_MP_STAND_MELEE");
				npc.StopPathing();
			}
		}
	}
	
	if(npc.m_bisWalking && DistanceToTarget < npc.GetLeadRadius()) 
	{
		float vPredictedPos[3];
		PredictSubjectPosition(npc, target,_,_, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
	}
	else 
	{
		npc.SetGoalEntity(target);
	}
}

static Action VictoriaProtector_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaProtector npc = view_as<VictoriaProtector>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
	{
		if(!npc.Anger)
		{
			damage=0.0;
			IncreaseEntityDamageTakenBy(npc.index, 0.15, 5.0);
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.m_flSpeed = 0.0;
			npc.SetActivity("ACT_MP_STAND_MELEE");
			npc.AddGesture("ACT_MP_STUN_BEGIN");
			npc.StopPathing();
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.65;
			npc.Anger = true;
			npc.m_fbRangedSpecialOn = true;
		}
	}
	
	return Plugin_Changed;
}

static void VictoriaProtector_NPCDeath(int entity)
{
	VictoriaProtector npc = view_as<VictoriaProtector>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);
	
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


int VictoriaProtectorGetTarget(int iNPC, float gameTime)
{
	VictoriaProtector npc = view_as<VictoriaProtector>(iNPC);
	if(!IsValidEnemy(npc.index,npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
				return -1;
		}	
	}

	npc.m_flGetClosestTargetTime = gameTime + 1.0;
	return npc.m_iTarget;
}

int VictoriaProtectorAssaultMode(int iNPC, float gameTime, int target, float distance)
{
	VictoriaProtector npc = view_as<VictoriaProtector>(iNPC);
	if(distance < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
				npc.FaceTowards(VecEnemy, 20000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1))
				{
					int Hittarget = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(Hittarget > 0) 
					{
						if(ShouldNpcDealBonusDamage(Hittarget))
							SDKHooks_TakeDamage(Hittarget, npc.index, npc.index, 255.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(Hittarget, npc.index, npc.index, 85.0, DMG_CLUB, -1, _, vecHit);
						// Hit sound
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
			}
			return 2;
		}
		return 1;
	}
	return 0;
}