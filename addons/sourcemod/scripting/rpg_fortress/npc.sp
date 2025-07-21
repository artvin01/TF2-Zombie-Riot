#pragma semicolon 1
#pragma newdecls required

#define NORMAL_ENEMY_MELEE_RANGE_FLOAT 130.0
// 130 * 130
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED 16900.0

#define GIANT_ENEMY_MELEE_RANGE_FLOAT 160.0
// 160 * 160
#define GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED 25600.0

static ArrayList NPCList;

enum struct NPCData
{
	char Plugin[64];
	char Name[64];
	Function Func;
}

// FileNetwork_ConfigSetup needs to be ran first
void NPC_ConfigSetup()
{
	delete NPCList;
	NPCList = new ArrayList(sizeof(NPCData));

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nothing");
	data.Func = INVALID_FUNCTION;
	NPCList.PushArray(data);

	NPCActor_Setup();
	StartChicken_OnMapStart_NPC();
	MadChicken_OnMapStart_NPC();
	MadRoost_OnMapStart_NPC();
	HeavyBear_OnMapStart_NPC();
	HeavyBearBoss_OnMapStart_NPC();
	HeavyBearMinion_OnMapStart_NPC();
	Miner_Enemy_OnMapStart_NPC();
	DeepMiner_OnMapStart_NPC();
	HeavyExcavator_OnMapStart_NPC();
	CaveGuardsman_OnMapStart_NPC();
	NemanBoss_OnMapStart_NPC();
	ExtremeHeatDigger_OnMapStart_NPC();
	Driller_OnMapStart_NPC();
	CaveBowmen_OnMapStart_NPC();
	AutomaticCaveDefense_OnMapStart_NPC();
	CaveEnslaver_OnMapStart_NPC();
	EnslavedMiner_OnMapStart_NPC();
	ChaosAfflictedMiner_OnMapStart_NPC();
	SlaveMaster_OnMapStart_NPC();
	HeadcrabZombie_OnMapStart_NPC();
	HeadcrabZombieElectro_OnMapStart_NPC();
	ExplosiveHeadcrabZombie_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	ZombiefiedCombineSwordsman_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	GiantHeadcrabZombie_OnMapStart_NPC();
	EnemyFatherGrigori_OnMapStart_NPC();
	BobTheTargetDummy_OnMapStart_NPC();
	WaterZombie_OnMapStart_NPC();
	DrowedZombieHuman_OnMapStart_NPC();
	MutatedDrowedZombieHuman_OnMapStart_NPC();
	FarmBear_OnMapStart_NPC();
	FarmCow_OnMapStart_NPC();
	SeaInfectedZombieHuman_OnMapStart_NPC();
	ScoutHyper_OnMapStart_NPC();
	PlayerAnimatorNPC_OnMapStart_NPC();
	OriginalInfected_OnMapStart_NPC();
	HeavyExtreme_OnMapStart_NPC();
	SniperAccuracy_OnMapStart_NPC();
	Huirgrajo_Setup();

	RookieGambler_Setup();
	BuckshotGambler_Setup();
	HeavyGambler_Setup();
	BigWins_Setup();
	CasinoRat_Setup();
	CasinoRatBoom_Setup();
	TrashMan_Setup();

	BaseSquad_MapStart();
	Whiteflower_AcclaimedSwordsman_OnMapStart_NPC();
	Whiteflower_Ekas_Piloteer_OnMapStart_NPC();
	Whiteflower_Rocketeer_OnMapStart_NPC();
	Whiteflower_PrototypeDDT_OnMapStart_NPC();
	Whiteflower_Nano_Blaster_OnMapStart_NPC();

	Whiteflower_selected_few_OnMapStart_NPC();

	Whiteflower_Mage_Blaster_OnMapStart_NPC();
	Whiteflower_ExtremeKnight_OnMapStart_NPC();
	Whiteflower_ExtremeKnightGiant_OnMapStart_NPC();
	Whiteflower_ExpertFighter_OnMapStart_NPC();
	Whiteflower_FloweringDarkness_OnMapStart_NPC();
	Whiteflower_RagingBlader_OnMapStart_NPC();
	Whiteflower_Boss_OnMapStart_NPC();

	RiverSeaMelee_Setup();
	RiverSeaRanged_Setup();
	RiverSeaFast_Setup();
	RiverSeaTank_Setup();
}

int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	return NPCList.PushArray(data);
}

stock int NPC_GetCount()
{
	return NPCList.Length;
}

stock int NPC_GetNameById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Name);
}

stock int NPC_GetPluginById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Plugin);
}

stock void NPC_GetById(int id, NPCData data)
{
	NPCList.GetArray(id, data);
}

stock int NPC_GetByPlugin(const char[] plugin, NPCData data = {})
{
	int length = NPCList.Length;
	for(int i; i < length; i++)
	{
		NPCList.GetArray(i, data);
		if(StrEqual(plugin, data.Plugin))
			return i;
	}
	return -1;
}

stock int NPC_CreateByName(const char[] name, int client, const float vecPos[3], const float vecAng[3], int team, const char[] data = "")
{
	static NPCData npcdata;
	int id = NPC_GetByPlugin(name, npcdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid NPC!", name);
		return -1;
	}

	return CreateNPC(npcdata, id, client, vecPos, vecAng, team, data);
}

stock int NPC_CreateById(int Index_Of_Npc, int client, const float vecPos[3], const float vecAng[3], int team, const char[] data = "")
{
	if(Index_Of_Npc < 1 || Index_Of_Npc >= NPCList.Length)
	{
		PrintToChatAll("[%d] is not a valid NPC!", Index_Of_Npc);
		return -1;
	}

	static NPCData npcdata;
	NPC_GetById(Index_Of_Npc, npcdata);
	return CreateNPC(npcdata, Index_Of_Npc, client, vecPos, vecAng, team, data);
}

static int CreateNPC(NPCData npcdata, int id, int client, const float vecPos[3], const float vecAng[3], int team, const char[] data)
{
	any entity = -1;

	Call_StartFunction(null, npcdata.Func);
	Call_PushCell(client);
	Call_PushArray(vecPos, sizeof(vecPos));
	Call_PushArray(vecAng, sizeof(vecAng));
	Call_PushCell(team);
	Call_PushString(data);
	Call_Finish(entity);
	
	if(entity != -1)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), npcdata.Name);
		
		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
	}

	return entity;
}

void NPCDeath(int entity)
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int DeathNoticer = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if(IsValidEntity(DeathNoticer) && !b_NpcHasDied[DeathNoticer])
		{
			Function func = func_NPCDeathForward[DeathNoticer];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(DeathNoticer);
				Call_PushCell(entity);
				Call_Finish();
			}
		}
	}

	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
	}
	
	int MaxHealth = ReturnEntityMaxHealth(entity);
	int client;
	while(RpgCore_CountClientsWorthyForKillCredit(entity, client))
	{
		RpgCore_OnKillGiveMastery(client, MaxHealth);
	}
}

void NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(IsValidEntity(attacker))
	{
		CClotBody npcBase = view_as<CClotBody>(victim);
		if(GetTeam(attacker) != GetTeam(victim))
		{
			npcBase.m_flGetClosestTargetNoResetTime = GetGameTime(npcBase.index) + 5.0; //make them angry for 5 seconds if they are too far away.

			if(!IsValidEnemy(npcBase.index, npcBase.m_iTarget)) //Only set it if they actaully have no target.
			{
				npcBase.m_iTarget = attacker;
			}
		}
	}
	Function func = func_NPCOnTakeDamage[victim];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArray(damageForce, sizeof(damageForce));
		Call_PushArray(damagePosition, sizeof(damagePosition));
		Call_PushCell(damagecustom);
		Call_Finish();
	}
}

stock void NPC_Despawn(int entity)
{
	/*
	if(i_NpcInternalId[entity] == NPCActor_ID())
		LogStackTrace("Actor Despawned");
	
	PrintToChatAll("NPC_Despawn::%d", i_NpcInternalId[entity]);
	*/
	if(IsValidEntity(entity))
	{
		CClotBody npc = view_as<CClotBody>(entity);
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
		if(IsValidEntity(npc.m_iTextEntity1))
			RemoveEntity(npc.m_iTextEntity1);
		if(IsValidEntity(npc.m_iTextEntity2))
			RemoveEntity(npc.m_iTextEntity2);
		if(IsValidEntity(npc.m_iTextEntity3))
			RemoveEntity(npc.m_iTextEntity3);
		if(IsValidEntity(npc.m_iTextEntity4))
			RemoveEntity(npc.m_iTextEntity4);

		RemoveEntity(entity);
	}
}

stock void Npc_Base_Thinking(int entity, float distance, const char[] WalkBack, const char[] StandStill, float walkspeedback, float gameTime, bool walkback_use_sequence = false, bool standstill_use_sequence = false, Function ExtraValidityFunction = INVALID_FUNCTION)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		if(b_NpcIsInADungeon[npc.index])
		{
			distance = 99999.9;
		}
		int entity_found = GetClosestTarget(npc.index, false, distance, .UseVectorDistance = true, .ExtraValidityFunction = ExtraValidityFunction);
		if(npc.m_flGetClosestTargetNoResetTime > gameTime) //We want to make sure that their aggro doesnt get reset instantly!
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if((b_NpcIsInADungeon[npc.index]) || (IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))) //Can i even see this enemy that i want to go to newly?
				{
					if(b_NpcIsInADungeon[npc.index])
					{
						npc.m_iTarget = entity_found;
					}
					else
					{
						//found enemy, go to new enemy
						npc.m_iTarget = Enemy_I_See;
					}
				}
			}
		}
		else //Allow the reset of aggro.
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
								
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if((b_NpcIsInADungeon[npc.index]) || (IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See)))
				{
					if(b_NpcIsInADungeon[npc.index])
					{
						npc.m_iTarget = entity_found;
					}
					else
					{
						//found enemy, go to new enemy
						npc.m_iTarget = Enemy_I_See;
					}
				}
			}
			else //can reset to -1
			{
				npc.m_iTarget = entity_found;
			}
		}
		npc.m_flGetClosestTargetTime = gameTime + 2.0;
	}

	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		i_NoEntityFoundCount[npc.index] += 1; //no enemy found, increment a few times.
		if(i_NoEntityFoundCount[npc.index] > 11) //There was no enemies found after like 11 tries, which is a second. go back to our spawn position.
		{	
			float vecTarget[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float fl_DistanceToOriginalSpawn = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			if(fl_DistanceToOriginalSpawn > (80.0 * 80.0)) //We are too far away from our home! return!
			{
				npc.SetGoalVector(f3_SpawnPosition[npc.index]);
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != -1) 	
				{
					npc.m_iChanged_WalkCycle = -1;
					if(walkback_use_sequence)
					{
						npc.AddActivityViaSequence(WalkBack);
					}
					else
					{
						npc.SetActivity(WalkBack);
					}
				}

			}
			else
			{
				//We now afk and are back in our spawnpoint heal back up, but not instantly incase they quickly can attack again.

				int MaxHealth = ReturnEntityMaxHealth(npc.index);
				int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

				int HealthToHealPerIncrement = MaxHealth / 100;

				if(HealthToHealPerIncrement < 1) //should never be 0
				{
					HealthToHealPerIncrement = 1;
				}

				SetEntProp(npc.index, Prop_Data, "m_iHealth", Health + HealthToHealPerIncrement);
				

				if((Health + HealthToHealPerIncrement) >= MaxHealth)
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
				}
				//Slowly heal when we are standing still.

				npc.m_bisWalking = false;
				if(npc.m_iChanged_WalkCycle != -2) 	//Stand still.
				{
					npc.m_iChanged_WalkCycle = -2;
					if(standstill_use_sequence)
					{
						npc.AddActivityViaSequence(StandStill);
					}
					else
					{
						npc.SetActivity(StandStill);
					}
				}
				RPGNpc_UpdateHpHud(npc.index);
			}
		}
		npc.m_flGetClosestTargetTime = 0.0;
	}
	else
	{
		if(npc.m_flDoingAnimation < GetGameTime())
		{
			if(ShouldNpcJumpAtThisClient(npc.index, npc.m_iTarget))
			{
				float vecMe[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe);
				float vecTarget[3];
				GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecTarget);

				if((vecTarget[2] - vecMe[2]) > 100.0 && (vecTarget[2] - vecMe[2]) < 250.0)
				{
					vecMe[2] = vecTarget[2];
					//Height should not be a factor in this calculation.
					float f_DistanceForJump = GetVectorDistance(vecMe, vecTarget, true);
					if(f_DistanceForJump < (200.0 * 200.0)) //Are they close enough for us to even jump after them..?
					{
						if((GetGameTime() - npc.m_flJumpStartTimeInternal) < 2.0)
							return;

						npc.m_flJumpStartTimeInternal = GetGameTime();

						vecTarget[2] += 50.0;

						PluginBot_Jump(npc.index, vecTarget);
					}
				}
			}
		}
		i_NoEntityFoundCount[npc.index] = 0;

	}

	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly, also happens when they stop follwing.
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = 0.0;
		}
		
		npc.StopPathing();
	}
	else
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = walkspeedback;
		}
		
		npc.StartPathing();
	}
}

void RPGNpc_UpdateHpHud(int entity)
{
	if(entity <= MaxClients)
		return;
		
	CClotBody npc = view_as<CClotBody>(entity);
	if(!IsValidEntity(npc.m_iTextEntity3))
		return;
		
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	char HealthString[64];
	IntToString(Health,HealthString, sizeof(HealthString));
	int offset = Health < 0 ? 1 : 0;
	ThousandString(HealthString[offset], sizeof(HealthString) - offset);
	DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
}

void HealOutOfBattleNpc(int entity)
{
	int MaxHealth = ReturnEntityMaxHealth(entity);
	int Health = GetEntProp(entity, Prop_Data, "m_iHealth");

	int HealthToHealPerIncrement = MaxHealth / 50;

	if(HealthToHealPerIncrement < 1) //should never be 0
	{
		HealthToHealPerIncrement = 1;
	}

	SetEntProp(entity, Prop_Data, "m_iHealth", Health + HealthToHealPerIncrement);
	

	if((Health + HealthToHealPerIncrement) >= MaxHealth)
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", MaxHealth);
	}
	//Slowly heal when we are standing still.
	RPGNpc_UpdateHpHud(entity);
	
}
stock bool ShouldNpcJumpAtThisClient(int iNpc, int client)
{
	bool AllowJump = true;
	
	if(AbilityGroundPoundReturnFloat(client) > GetGameTime())
	{
		AllowJump = false;
	}
	if(i_NpcIsABuilding[iNpc])
		AllowJump = false;
	
	return AllowJump;
}

stock bool AllyNpcInteract(int client, int entity, int weapon)
{
	bool result;

	Function func = func_NPCInteract[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushCell(entity);
		Call_Finish(result);
	}

	return result;
}

#include "npc/npc_actor.sp"

#include "../zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"

#include "npc/normal/npc_chicken_2.sp"
#include "npc/normal/npc_chicken_mad.sp"
#include "npc/normal/npc_roost_mad.sp"
#include "npc/normal/npc_heavy_bear.sp"
#include "npc/normal/npc_heavy_bear_boss.sp"
#include "npc/normal/npc_heavy_bear_minion.sp"
#include "npc/normal/npc_miner.sp"
#include "npc/normal/npc_deep_miner.sp"
#include "npc/normal/npc_heavy_excavator.sp"
#include "npc/normal/npc_cave_guardsman.sp"
#include "npc/normal/npc_neman.sp"
#include "npc/normal/npc_extreme_heat_digger.sp"
#include "npc/normal/npc_driller.sp"
#include "npc/normal/npc_cave_bowmen.sp"
#include "npc/normal/npc_auto_cave_defense.sp"
#include "npc/normal/npc_cave_enslaver.sp"
#include "npc/normal/npc_enslaved_miner.sp"
#include "npc/normal/npc_slave_master.sp"
#include "npc/normal/npc_chaos_afflicted_miner.sp"

#include "npc/normal/npc_bob_the_targetdummy.sp"

#include "npc/normal/npc_headcrab_zombie.sp"
#include "npc/normal/npc_headcrab_zombie_electro.sp"
#include "npc/normal/npc_poison_zombie.sp"
#include "npc/normal/npc_headcrab_zombie_explosive.sp"
#include "npc/normal/npc_zombiefied_combine_soldier_swordsman.sp"
#include "npc/normal/npc_fastzombie.sp"
#include "npc/normal/npc_giant_headcrab_zombie.sp"
#include "npc/normal/npc_enemy_grigori.sp"
#include "npc/normal/npc_water_zombie.sp"
#include "npc/normal/npc_drowned_zombiefied_human.sp"
#include "npc/normal/npc_mutated_drowned_zombiefied_human.sp"
#include "npc/farm/npc_heavy_cow.sp"
#include "npc/farm/npc_heavy_bear.sp"
#include "npc/normal/npc_sea_infected_zombiefied_human.sp"
#include "npc/normal/npc_scout_hyper.sp"
#include "npc/normal/npc_original_infected.sp"
#include "npc/ally/npc_player_animator.sp"
#include "npc/normal/npc_heavy_extreme.sp"
#include "npc/normal/npc_sniper_accuracy.sp"
#include "npc/normal/npc_huirgrajo.sp"

#include "npc/casino/npc_casinoshared.sp"
#include "npc/casino/npc_rookiegambler.sp"
#include "npc/casino/npc_buckshotgambler.sp"
#include "npc/casino/npc_heavygambler.sp"
#include "npc/casino/npc_bigwins.sp"
#include "npc/casino/npc_casinorat.sp"
#include "npc/casino/npc_casinoratboom.sp"
#include "npc/casino/npc_trashman.sp"

#include "npc/whiteflower_combine/npc_basesquad.sp"
#include "npc/whiteflower_combine/npc_combine_pistol.sp"
#include "npc/whiteflower_combine/npc_combine_smg.sp"
#include "npc/whiteflower_combine/npc_combine_swordsman.sp"
#include "npc/whiteflower_combine/npc_combine_ar2.sp"
#include "npc/whiteflower_combine/npc_tank.sp"
#include "npc/whiteflower_combine/npc_combine_shotgun.sp"
#include "npc/whiteflower_combine/npc_combine_elite.sp"
#include "npc/whiteflower_combine/npc_combine_giant.sp"
#include "npc/whiteflower_combine_elite/npc_combine_acclaimed_swordsman.sp"
#include "npc/whiteflower_combine_elite/npc_combine_ekas_piloteer.sp"
#include "npc/whiteflower_combine_elite/npc_combine_rocketeer.sp"
#include "npc/whiteflower_combine_elite/npc_combine_selected_few.sp"
#include "npc/whiteflower_combine_elite/npc_combine_prototype_durable_titan.sp"
#include "npc/whiteflower_combine_elite/npc_combine_nano_blaster.sp"

#include "npc/whiteflower_combine_rush/npc_combine_aggrat.sp"
#include "npc/whiteflower_combine_rush/npc_combine_bloomer.sp"
#include "npc/whiteflower_combine_rush/npc_combine_dreadlander.sp"
#include "npc/whiteflower_combine_rush/npc_combine_guarder.sp"
#include "npc/whiteflower_combine_rush/npc_combine_outlander_leader.sp"
#include "npc/whiteflower_combine_rush/npc_combine_penetrator.sp"
#include "npc/whiteflower_combine_rush/npc_combine_threat_cleaner.sp"


#include "npc/whiteflower_combine_bodyguards/npc_combine_mage.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_extreme_knight.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_extreme_knight_giant.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_expert_fighter.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_raging_blader.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_master_mage.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_flowering_darkness.sp"
#include "npc/whiteflower_combine_bodyguards/npc_combine_whiteflower.sp"

#include "npc/seaborn/npc_sea_shared.sp"
#include "npc/seaborn/npc_riversea_melee.sp"
#include "npc/seaborn/npc_riversea_ranged.sp"
#include "npc/seaborn/npc_riversea_fast.sp"
#include "npc/seaborn/npc_riversea_tank.sp"

//#include "npc/superbosses/npc_levita.sp"
