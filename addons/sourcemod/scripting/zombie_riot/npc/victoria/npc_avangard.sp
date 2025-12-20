#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "weapons/sentry_rocket.wav";
static const char g_ActivationSounds[] = "mvm/mvm_tank_horn.wav";

static const char g_HurtSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav"
};
static int NPCId;

static bool b_Already_Link[MAXENTITIES];
static bool b_AdvansedConstruction[MAXENTITIES];

static float fActivationSound;

void VictorianOfflineAvangard_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Avangard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_avangard");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_avangard");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_ActivationSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
}

int VictorianAvangard_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianOfflineAvangard(vecPos, vecAng, ally, data);
}

methodmap VictorianOfflineAvangard < CClotBody
{
	public void PlayActivationSound()
 	{
		if(fActivationSound > GetGameTime())
			return;
		fActivationSound = GetGameTime() + 3.0;
		EmitSoundToAll(g_ActivationSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.8, _);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,110));
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL-20, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayExplodBatterySound()
	{
		EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_i_linkStat
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property int m_i_LifeSupportDevice
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	
	property float m_flSpawnTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flAMBATUBLOW
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public VictorianOfflineAvangard(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "1.75", "100000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictorianOfflineAvangard_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianOfflineAvangard_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianOfflineAvangard_ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flAMBATUBLOW = 0.0;
		npc.m_flSpawnTime = GetGameTime(npc.index)+50.0;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		Is_a_Medic[npc.index]=true;
		b_Already_Link[npc.index] = false;
		npc.m_fbRangedSpecialOn = false;
		b_AdvansedConstruction[npc.index] = false;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 0.90;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		//Maybe used for special waves
		if(StrContains(data, "only") != -1)
		{
			i_AttacksTillMegahit[npc.index]=600;
			npc.m_bFUCKYOU = true;
		}
		
		if(StrContains(data, "imcomplete") != -1)
			npc.m_bFUCKYOU_move_anim = true;
		
		if(StrContains(data, "link_majorsteam") != -1)
			npc.m_fbRangedSpecialOn = true;
		
		if(StrContains(data, "awaiting_mechanist") != -1)
			b_AdvansedConstruction[npc.index] = true;

		SetEntityRenderColor(npc.index, 80, 50, 50, 255);

		if(npc.m_bFUCKYOU_move_anim)
			npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_alcoholic_automaton_style2/hwn2022_alcoholic_automaton_style2.mdl");
		else
			npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_alcoholic_automaton/hwn2022_alcoholic_automaton.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		if(npc.m_bFUCKYOU_move_anim)
			npc.m_iWearable4 = npc.EquipItem("head", "models/bots/gameplay_cosmetic/light_demo_on.mdl");
		else
			npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable4, 100, 100, 100, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		
		if(npc.m_bFUCKYOU_move_anim)
		{
			//npc.m_iWearable6 = npc.EquipItem("flag", "models/props_td/atom_bomb.mdl");
			//└ Why Not Work???????????
			npc.m_iWearable6 = npc.EquipItemSeperate("models/props_td/atom_bomb.mdl",_,1,1.5,_,true);
			SetEntityRenderColor(npc.m_iWearable6, 100, 100, 100, 255);
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable6, "SetParent", npc.index);
			SetVariantString("flag");
			AcceptEntityInput(npc.m_iWearable6, "SetParentAttachmentMaintainOffset"); 
			MakeObjectIntangeable(npc.m_iWearable6);
			
			fl_ruina_battery_max[npc.index] = 50.0;
			fl_ruina_battery[npc.index] = 0.0;
		}
		
		if(!npc.m_bFUCKYOU)
		{
			npc.m_flSpawnTime=0.0;
			float flPos[3];
			float flAng[3];
			
			npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);

			npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "teleporter_mvm_bot_persist", npc.index, "", {0.0,0.0,0.0});
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable9), TIMER_FLAG_NO_MAPCHANGE);
		}
		return npc;
	}
}

static Action VictorianOfflineAvangard_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianWelder npc = view_as<VictorianWelder>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianOfflineAvangard_ClotThink(int iNPC)
{
	VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(i_AttacksTillMegahit[iNPC] >= 255)
	{
		if(i_AttacksTillMegahit[iNPC] <= 600)
		{
			if(!npc.m_bFUCKYOU)
			{
				npc.PlayActivationSound();
				IncreaseEntityDamageTakenBy(npc.index, 0.000001, 1.0);
			}
			i_AttacksTillMegahit[iNPC] = 601;
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_blackbox/c_blackbox.mdl");
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntityRenderColor(npc.m_iWearable1, 100, 100, 100, 255);

			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");
			SetEntityRenderColor(npc.m_iWearable2, 100, 100, 100, 255);
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			Is_a_Medic[npc.index]=false;
			npc.m_flSpawnTime = gameTime+50.0;
		}
		
		if(npc.m_fbRangedSpecialOn && npc.m_flNextRangedAttack < gameTime)
		{
			switch(npc.m_i_linkStat)
			{
				case 0:
				{
					bool Link_MajorSteam=false;
					for(int i; i < i_MaxcountNpcTotal; i++)
					{
						int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
						if(IsValidEntity(entity))
						{
							char npc_classname[60];
							NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
							if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_majorsteam") && IsEntityAlive(entity) && !b_Already_Link[entity])
							{
								npc.m_i_LifeSupportDevice = entity;
								b_Already_Link[entity] = true;
								npc.m_iWearable8 = ConnectWithBeam(npc.index, entity, 205, 255, 255, 1.5, 1.5, 0.0, LASERBEAM);
								Link_MajorSteam=true;
								break;
							}
						}
					}
					if(Link_MajorSteam)
						npc.m_i_linkStat=1;
					npc.m_flNextRangedAttack = gameTime + 1.0;
				}
				case 1:
				{
					if(IsValidEntity(npc.m_i_LifeSupportDevice) && !b_NpcHasDied[npc.m_i_LifeSupportDevice] && GetTeam(npc.m_i_LifeSupportDevice) == GetTeam(npc.index))
					{
						IncreaseEntityDamageTakenBy(npc.index, 0.5, 0.25);
						HealEntityGlobal(npc.index, npc.index, 4000.0, 1.0);
						HealEntityGlobal(npc.index, npc.m_i_LifeSupportDevice, 75.0, 1.0);
						npc.m_flNextRangedAttack = gameTime + 0.25;
					}
					else
					{
						npc.m_i_linkStat=2;
						if(IsValidEntity(npc.m_iWearable8))
							RemoveEntity(npc.m_iWearable8);
						b_Already_Link[npc.m_i_LifeSupportDevice]=false;
					}
				}
			}
		}
		
		if(npc.m_bFUCKYOU_move_anim)
		{
			if(!HasSpecificBuff(npc.index, "Battery_TM Charge"))
				ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
			fl_ruina_battery[npc.index]=npc.m_flSpawnTime-gameTime;
			/*blow*/
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			if(npc.m_flSpawnTime && npc.m_flSpawnTime < gameTime)
			{
				npc.PlayExplodBatterySound();
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
				npc.SetActivity("ACT_MP_STUN_MIDDLE");
				npc.AddGesture("ACT_MP_STUN_BEGIN");
				spawnRing_Vectors(VecSelfNpc, 560.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 255, 1, 1.95, 5.0, 0.0, 1);
				spawnRing_Vectors(VecSelfNpc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 255, 1, 1.95, 5.0, 0.0, 1, 560.0);
				npc.m_flSpawnTime=0.0;
				npc.m_flAMBATUBLOW=gameTime+2.0;
				b_NpcIsInvulnerable[npc.index] = true;
				npc.m_bisWalking = false;
				npc.m_bAllowBackWalking = false;
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}
			if(npc.m_flAMBATUBLOW)
			{
				if(npc.m_flAMBATUBLOW < gameTime)
				{
					KillFeed_SetKillIcon(npc.index, "megaton");
					TE_Particle("asplode_hoodoo", VecSelfNpc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
					Explode_Logic_Custom(750.0, npc.index, npc.index, -1, VecSelfNpc, 280.0, 1.0, _, true, 40, _, _, _, ExplodBattery);
					b_NpcIsInvulnerable[npc.index] = false;
					SmiteNpcToDeath(iNPC);
				}
				return;
			}
		}

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
			npc.SetActivity("ACT_MP_RUN_PRIMARY");

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
			
			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < gameTime)
				{

					float damageDeal = 150.0;
					float ProjectileSpeed = 700.0;

					PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);

					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.PlayMeleeSound();

					int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,"models/buildables/sentry3_rockets.mdl",_,_,60.0);
					if(entity != -1)
					{
						//max duration of 2.5 seconds beacuse of simply how fast they fire
						if(npc.m_i_linkStat==1)
						{
							i_ChaosArrowAmount[entity] = 80;
							if(Rogue_Paradox_RedMoon())
								i_ChaosArrowAmount[entity] = 125;
							float vecSwingStart[3], vecAngles[3];
							GetAbsOrigin(entity, vecSwingStart);
							int particle = ParticleEffectAt(vecSwingStart, "critical_rocket_blue", 2.4);
							i_WandParticle[entity]= EntIndexToEntRef(particle);
							GetEntPropVector(entity, Prop_Data, "m_angRotation", vecAngles);
							TeleportEntity(particle, NULL_VECTOR, vecAngles, NULL_VECTOR);
							SetParent(entity, particle);
						}
						CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					}

					npc.m_iOverlordComboAttack--;

					if(npc.m_iOverlordComboAttack < 1)
					{
						npc.m_flAttackHappens = 0.0;
					}
					else
					{
						npc.m_flAttackHappens = gameTime + 0.5;
					}
				}
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_iOverlordComboAttack += 2;
				npc.m_flNextMeleeAttack = gameTime + 0.45;
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");

				if(npc.m_iOverlordComboAttack > 4)
				{
					target = Can_I_See_Enemy(npc.index, target);
					if(IsValidEnemy(npc.index, target))
					{
						npc.m_iTarget = target;
						npc.m_flGetClosestTargetTime = gameTime + 2.45;
						npc.m_flAttackHappens = gameTime + 0.5;
					}
				}
			}
		}
		else
		{
			npc.StopPathing();
		}
	}
	else if(!b_AdvansedConstruction[npc.index])
	{
		bool villagerexists = false;
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
			if (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianMechanist_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(iNPC))
			{
				villagerexists = true;
			}
		}
		if(!villagerexists)
		{
			SmiteNpcToDeath(iNPC);
			return;
		}
	}
}

static void VictorianOfflineAvangard_ClotDeath(int entity)
{
	VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(entity);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
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
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}

static float ExplodBattery(int attacker, int victim, float damage, int weapon)
{
	if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
		return 1500.0;
	if(IsValidEntity(RaidBossActive))
		return 500.0 * RaidModeScaling;
	return damage;
}