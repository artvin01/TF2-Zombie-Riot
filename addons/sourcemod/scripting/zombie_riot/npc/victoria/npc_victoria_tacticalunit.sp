#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3"
};

static const char g_MeleeAttackSounds[] = "weapons/machete_swing.wav";

static const char g_DronPingSounds[] = "misc/rd_finale_beep01.wav";

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav"
};


void Victorian_Tacticalunit_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	PrecacheSound(g_MeleeAttackSounds);
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheSound(g_DronPingSounds);
	PrecacheModel("models/player/scout.mdl");
	PrecacheModel(LASERBEAM);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Tacticalunit");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_tacticalunit");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tacticalunits"); 
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaTacticalunit(vecPos, vecAng, ally, data);
}

methodmap VictoriaTacticalunit < CClotBody
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDronPingSound() 
	{
		EmitSoundToAll(g_DronPingSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void SetWeaponModel(const char[] model, float Scale = 1.0)		//dynamic weapon model change, don't touch
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		if(model[0])
		{
			this.m_iWearable1 = this.EquipItem("head", model);
			if(Scale != 1.0)
			{
				char buffer[32];
				FormatEx(buffer, sizeof(buffer), "%.2f", Scale);
				SetVariantString(buffer);
				AcceptEntityInput(this.m_iWearable1, "SetModelScale");
			}
		}
	}
	public VictoriaTacticalunit(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "7500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		func_NPCDeath[npc.index] = view_as<Function>(VictoriaTacticalunit_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaTacticalunit_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaTacticalunit_ClotThink);
		
		FactorySpawn[npc.index]=false;
		MK2[npc.index]=false;
		Limit[npc.index]=false;
		Anvil[npc.index]=false;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			if(!StrContains(countext[i], "factory"))FactorySpawn[npc.index]=true;
			else if(!StrContains(countext[i], "mk2"))MK2[npc.index]=true;
			else if(!StrContains(countext[i], "limit"))Limit[npc.index]=true;
			else if(!StrContains(countext[i], "anvil"))Anvil[npc.index]=true;
		}
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bFUCKYOU = false;
		npc.Anger = false;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_bisWalking = true;
		npc.m_flSpeed = 280.0;
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_machete/c_machete.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/scout/grfs_scout.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_jungle_jersey/fall17_jungle_jersey.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_transparent_trousers/fall17_transparent_trousers.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_forest_footwear/fall17_forest_footwear.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		float Ang[3]={0.0,0.0,0.0};
		Ang[0] = 0.0;
		Ang[1] = 90.0;
		Ang[2] = 0.0;
		TeleportEntity(npc.m_iWearable1, NULL_VECTOR, Ang, NULL_VECTOR);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void VictoriaTacticalunit_ClotThink(int iNPC)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(iNPC);
	
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
		target = VictoriaTacticalunitGetTarget(npc.index, gameTime);
		
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
				npc.Anger=true;
				npc.m_bFUCKYOU=true;
				return;
			}
		}
		if(DistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*10.0)
		{
			if(!npc.Anger)
			{
				npc.SetWeaponModel("models/weapons/c_models/c_wrangler.mdl", 1.0);
				npc.Anger=true;
			}
			if(npc.m_iChanged_WalkCycle != 0)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flSpeed = 0.0;
				npc.SetActivity("ACT_MP_STAND_SECONDARY");
				npc.StopPathing();
			}
			npc.m_iWearable7 = ConnectWithBeam(npc.m_iWearable2, target, 255, 215, 0, 3.0, 3.0, 1.35, LASERBEAM);
			if(IsValidEntity(npc.m_iWearable7))
			{
				SetEntityRenderColor(npc.m_iWearable4, 255, 13, 13, 255);
			}
			npc.PlayDronPingSound();
			npc.m_flNextThinkTime = gameTime + 3.0;
			npc.m_bFUCKYOU=true;
			
			char Adddeta[512];
			if(FactorySpawn[npc.index])
				FormatEx(Adddeta, sizeof(Adddeta), "factory");
			if(MK2[npc.index])
				FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
			if(Limit[npc.index])
				FormatEx(Adddeta, sizeof(Adddeta), "%s;limit", Adddeta);
			FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, target);
			VecSelfNpc[2]+=45.0;
			int spawn_index;
			if(Anvil[npc.index])
				spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
			else
				spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
			if(spawn_index > MaxClients)
			{
				int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.7);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
				FreezeNpcInTime(spawn_index, 3.0, true);
				IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 3.0);
			}
			
			return;
		}
		else if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.m_flSpeed = 280.0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}
	}
	else
	{
		if(npc.Anger)
		{
			npc.SetWeaponModel("models/weapons/c_models/c_machete/c_machete.mdl", 1.0);
			float Ang[3]={0.0,0.0,0.0};
			Ang[0] = 0.0;
			Ang[1] = 90.0;
			Ang[2] = 0.0;
			TeleportEntity(npc.m_iWearable1, NULL_VECTOR, Ang, NULL_VECTOR);
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);

			npc.Anger=false;
		}
		int AI = VictoriaTacticalunitAssaultMode(npc.index, gameTime, target, DistanceToTarget);
		switch(AI)
		{
			case 0, 1://notfound, cooldown
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.m_flSpeed = 280.0;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}
			}
			case 2://attack
			{
				/*if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flSpeed = 0.0;
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.StopPathing();
				}*/
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

static Action VictoriaTacticalunit_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaTacticalunit_NPCDeath(int entity)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(entity);
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


int VictoriaTacticalunitGetTarget(int iNPC, float gameTime)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(iNPC);
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

int VictoriaTacticalunitAssaultMode(int iNPC, float gameTime, int target, float distance)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(iNPC);
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			//Play attack ani
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
				npc.FaceTowards(VecEnemy, 20000.0);
				if(npc.DoSwingTrace(swingTrace, target))
				{
					int Hittarget = TR_GetEntityIndex(swingTrace);	
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, Hittarget))
					{
						if(ShouldNpcDealBonusDamage(Hittarget))
							SDKHooks_TakeDamage(Hittarget, npc.index, npc.index, 325.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(Hittarget, npc.index, npc.index, 65.0, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					}
					else
					{
						WorldSpaceCenter(npc.index, vecHit);
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, vecHit, 125.0, _, _, true, 1, false, _, PlayerHit);
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

static void PlayerHit(int entity, int victim, float damage, int weapon)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	SDKHooks_TakeDamage(victim, npc.index, npc.index, 65.0, DMG_CLUB, -1, _, vecHit);
	npc.PlayMeleeHitSound();
}