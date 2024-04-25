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

	StartChicken_OnMapStart_NPC();

/*
	MadChicken_OnMapStart_NPC();
	StartChicken_OnMapStart_NPC();
	MadRoost_OnMapStart_NPC();
	HeavyBear_OnMapStart_NPC();
	HeavyBearBoss_OnMapStart_NPC();
	HeavyBearMinion_OnMapStart_NPC();
	Miner_Enemy_OnMapStart_NPC();
	HeadcrabZombie_OnMapStart_NPC();
	HeadcrabZombieElectro_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	ExplosiveHeadcrabZombie_OnMapStart_NPC();
	ZombiefiedCombineSwordsman_OnMapStart_NPC();
	BobTheTargetDummy_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	EnemyFatherGrigori_OnMapStart_NPC();
	FarmCow_OnMapStart_NPC();
	ArkSlug_MapStart();
	ArkSinger_MapStart();
	ArkSlugAcid_MapStart();
	ArkSlugInfused_MapStart();
	BaseSquad_MapStart();
	CombineTurtle_MapStart();
	FarmBear_OnMapStart_NPC();
*/
}

int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	if(!TranslationPhraseExists(data.Name))
		LogError("Translation '%s' does not exist", data.Name);

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
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if(IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			Function func = func_NPCDeathForward[baseboss_index];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(baseboss_index);
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
	
	int MaxHealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	int client;
	while(RpgCore_CountClientsWorthyForKillCredit(entity, client) <= MaxClients)
	{
		//only a 10% chance!
		if(GetRandomFloat(0.0, 1.0) >= 0.1)
			continue;

		float CombinedDamagesPre;
		float CombinedDamages;
		int BaseDamage;
		float Multiplier;
		int bonus;
		Stats_Strength(client, BaseDamage, bonus, Multiplier);
		CombinedDamagesPre = float(BaseDamage) * Multiplier;
		if(CombinedDamagesPre > CombinedDamages)
			CombinedDamages = CombinedDamagesPre;

		Stats_Precision(client, BaseDamage, bonus, Multiplier);
		CombinedDamagesPre = float(BaseDamage) * Multiplier;
		if(CombinedDamagesPre > CombinedDamages)
			CombinedDamages = CombinedDamagesPre;

		Stats_Artifice(client, BaseDamage, bonus, Multiplier);
		CombinedDamagesPre = float(BaseDamage) * Multiplier;
		if(CombinedDamagesPre > CombinedDamages)
			CombinedDamages = CombinedDamagesPre;
		//Get the highest statt you can find.
		float f_Stats_GetCurrentFormMastery;
		f_Stats_GetCurrentFormMastery = RPGStats_FlatDamageSetStats(client, 0, RoundToNearest(CombinedDamages));

		//todo: Make it also work if your level is low enough!
		if(float(MaxHealth) > f_Stats_GetCurrentFormMastery * 1.5)
		{
			float MasteryCurrent = Stats_GetCurrentFormMastery(client);
			if(GetRandomFloat(0.0, 1.0) <= 0.1)
			{
				MasteryCurrent += GetRandomFloat(0.4, 0.8);
			}
			MasteryCurrent += 0.1;
			Stats_SetCurrentFormMastery(client, MasteryCurrent);
			//enemy was able to survive atleast 1 hit and abit more, allow them to use form mastery, it also counts the current form!.
		}
	}
	
}

void NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
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

stock void Npc_Base_Thinking(int entity, float distance, const char[] WalkBack, const char[] StandStill, float walkspeedback, float gameTime, bool walkback_use_sequence = false, bool standstill_use_sequence = false)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		if(b_NpcIsInADungeon[npc.index])
		{
			distance = 99999.9;
		}
		int entity_found = GetClosestTarget(npc.index, false, distance);
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
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
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
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
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

				int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
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

				Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

				npc.m_bisWalking = false;
				if(npc.m_iChanged_WalkCycle != 5) 	//Stand still.
				{
					npc.m_iChanged_WalkCycle = 5;
					if(standstill_use_sequence)
					{
						npc.AddActivityViaSequence(StandStill);
					}
					else
					{
						npc.SetActivity(StandStill);
					}
				}

				char HealthString[512];
				Format(HealthString, sizeof(HealthString), "%i / %i", Health, MaxHealth);

				if(IsValidEntity(npc.m_iTextEntity3))
				{
					DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
				}
			}
		}
		npc.m_flGetClosestTargetTime = 0.0;
	}
	else
	{
		if(npc.m_flDoingAnimation < GetGameTime())
		{
			if(ShouldNpcJumpAtThisClient(npc.m_iTarget))
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

stock bool ShouldNpcJumpAtThisClient(int client)
{
	bool AllowJump = true;
	/*
	if(AbilityGroundPoundReturnFloat(client) > GetGameTime())
	{
		AllowJump = false;
	}
	*/
	return AllowJump;
}

stock bool AllyNpcInteract(int client, int entity, int weapon)
{
	bool result;
/*
	Function func = func_NPCInteract[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_Finish(result);
	}
*/
	return result;
}

#include "rpg_fortress/npc/normal/npc_chicken_2.sp"
/*
#include "rpg_fortress/npc/normal/npc_chicken_mad.sp"
#include "rpg_fortress/npc/normal/npc_roost_mad.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_boss.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_minion.sp"
#include "rpg_fortress/npc/normal/npc_miner.sp"

#include "rpg_fortress/npc/normal/npc_headcrab_zombie.sp"
#include "rpg_fortress/npc/normal/npc_headcrab_zombie_electro.sp"
#include "rpg_fortress/npc/normal/npc_poison_zombie.sp"
#include "rpg_fortress/npc/normal/npc_headcrab_zombie_explosive.sp"
#include "rpg_fortress/npc/normal/npc_zombiefied_combine_soldier_swordsman.sp"
#include "rpg_fortress/npc/normal/npc_bob_the_targetdummy.sp"
#include "rpg_fortress/npc/normal/npc_fastzombie.sp"
#include "rpg_fortress/npc/normal/npc_enemy_grigori.sp"

#include "rpg_fortress/npc/farm/npc_heavy_cow.sp"
#include "rpg_fortress/npc/farm/npc_heavy_bear.sp"

#include "rpg_fortress/npc/normal/npc_ark_slug.sp"
#include "rpg_fortress/npc/normal/npc_ark_singer.sp"
#include "rpg_fortress/npc/normal/npc_ark_slug_acid.sp"
#include "rpg_fortress/npc/normal/npc_ark_slug_infused.sp"

#include "rpg_fortress/npc/combine/npc_basesquad.sp"
#include "rpg_fortress/npc/combine/npc_combine_pistol.sp"
#include "rpg_fortress/npc/combine/npc_combine_smg.sp"
#include "rpg_fortress/npc/combine/npc_combine_ar2.sp"
#include "rpg_fortress/npc/combine/npc_combine_elite.sp"
#include "rpg_fortress/npc/combine/npc_combine_shotgun.sp"
#include "rpg_fortress/npc/combine/npc_combine_swordsman.sp"
#include "rpg_fortress/npc/combine/npc_combine_giant.sp"
#include "rpg_fortress/npc/combine/npc_combine_overlord.sp"
#include "rpg_fortress/npc/combine/npc_townguard_pistol.sp"
#include "rpg_fortress/npc/combine/npc_combine_overlord_cc.sp"
#include "rpg_fortress/npc/combine/npc_combine_turtle.sp"
*/
