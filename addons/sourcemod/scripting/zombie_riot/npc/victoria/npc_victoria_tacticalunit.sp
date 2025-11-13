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
	
	property float m_flLifeTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
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
		
		i_GunAmmo[npc.index]=0;
		b_we_are_reloading[npc.index]=false;
		npc.m_flLifeTime=20.0;
		i_ammo_count[npc.index]=0;
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
			}
			else if(StrContains(countext[i], "factory") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "factory", "");
				i_GunAmmo[npc.index]=1;
			}
			else if(StrContains(countext[i], "anvil") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "anvil", "");
				i_ammo_count[npc.index] = 1;
			}
			else if(StrContains(countext[i], "tracking") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "tracking", "");
				npc.m_iState = 1;
			}
		}
		
		//IDLE
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
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
		
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
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
	
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);

	if(!npc.m_bFUCKYOU)
	{
		int HowManyFactory[6];
		//└There won't be more cases than this
		if(i_GunAmmo[npc.index])
		{
			bool NoFactory=true;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
				{
					NoFactory=false;
					HowManyFactory[entitycount]=entity;
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
			npc.m_iWearable7 = ConnectWithBeam(npc.m_iWearable2, npc.m_iTarget, 255, 215, 0, 3.0, 3.0, 1.35, LASERBEAM);
			npc.PlayDronPingSound();
			npc.m_flNextThinkTime = gameTime + 3.0;
			npc.m_bFUCKYOU=true;
			
			char Adddeta[512];
			if(b_we_are_reloading[npc.index])
				FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
			FormatEx(Adddeta, sizeof(Adddeta), "%s;lifetime%.1f", Adddeta, npc.m_flLifeTime);
			if(!i_ammo_count[npc.index] && npc.m_iState==1)
			{
				FormatEx(Adddeta, sizeof(Adddeta), "%s;tracking", Adddeta);
				FormatEx(Adddeta, sizeof(Adddeta), "%s;overridetarget%i", Adddeta, npc.m_iTarget);
			}
			
			if(i_GunAmmo[npc.index])
			{
				for(int entitycount; entitycount<6; entitycount++)
				{
					int entity=HowManyFactory[entitycount];
					if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
					{
						WorldSpaceCenter(entity, VecSelfNpc);
						VecSelfNpc[2]+=45.0;
						int spawn_index;
						if(i_ammo_count[npc.index])
							spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						else
							spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						if(spawn_index > MaxClients)
						{
							int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.35);
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
							SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
							SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
							fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
							fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
							fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
							fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
							FreezeNpcInTime(spawn_index, 3.0, true);
							IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 3.0);
						}
					}
				}
			}
			else
			{
				VecSelfNpc[2]+=45.0;
				int spawn_index;
				if(i_ammo_count[npc.index])
					spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
				else
					spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
				if(spawn_index > MaxClients)
				{
					int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.35);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
					fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
					fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
					FreezeNpcInTime(spawn_index, 3.0, true);
					IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 3.0);
				}
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
		VictoriaTacticalunitAssaultMode(npc.index, gameTime, npc.m_iTarget, DistanceToTarget);
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.m_flSpeed = 280.0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}
	}
	
	if(npc.m_bisWalking && DistanceToTarget < npc.GetLeadRadius()) 
	{
		float vPredictedPos[3];
		PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
	}
	else 
	{
		npc.SetGoalEntity(npc.m_iTarget);
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

static void VictoriaTacticalunitAssaultMode(int iNPC, float gameTime, int target, float distance)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(iNPC);
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
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
						float damageDealt = 65.0;
						if(ShouldNpcDealBonusDamage(Hittarget))
							damageDealt*=5.0;
						SDKHooks_TakeDamage(Hittarget, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					}
					else
					{
						WorldSpaceCenter(npc.index, vecHit);
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, vecHit, 125.0, _, _, true, 1, false, _, AoEHit);
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
		}
	}
	return;
}

static void AoEHit(int entity, int victim, float damage, int weapon)
{
	VictoriaTacticalunit npc = view_as<VictoriaTacticalunit>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	float damageDealt = 65.0;
	if(ShouldNpcDealBonusDamage(victim))
		damageDealt*=5.0;
	SDKHooks_TakeDamage(victim, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
	npc.PlayMeleeHitSound();
}