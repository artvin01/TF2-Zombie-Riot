#pragma semicolon 1
#pragma newdecls required

enum
{
	NOTHING 				= 0,
	START_CHICKEN 			= 1,
	MAD_CHICKEN 			= 2,
	MAD_ROOST				= 3,
	HEAVY_BEAR				= 4,
	HEAVY_BEAR_BOSS			= 5,
	HEAVY_BEAR_MINION		= 6,
	MINER_NPC				= 7
}

public const char NPC_Names[][] =
{
	"nothing",
	"Chicken",
	"Mad Chicken",
	"Mad Roost",
	"Heavy Bear",
	"Heavy Bear Boss",
	"Heavy Bear Minion",
	"Ore Miner"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"",
	"npc_chicken_2",
	"npc_chicken_mad",
	"npc_roost_mad",
	"npc_heavy_bear",
	"npc_heavy_bear_boss",
	"npc_heavy_bear_minion",
	"npc_miner"
};

void NPC_MapStart()
{
	MadChicken_OnMapStart_NPC();
	StartChicken_OnMapStart_NPC();
	MadRoost_OnMapStart_NPC();
	HeavyBear_OnMapStart_NPC();
	HeavyBearBoss_OnMapStart_NPC();
	HeavyBearMinion_OnMapStart_NPC();
	Miner_Enemy_OnMapStart_NPC();
}

#define NORMAL_ENEMY_MELEE_RANGE_FLOAT 120.0
#define GIANT_ENEMY_MELEE_RANGE_FLOAT 130.0

stock any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case START_CHICKEN:
		{
			entity = StartChicken(client, vecPos, vecAng, ally);
		}
		case MAD_CHICKEN:
		{
			entity = MadChicken(client, vecPos, vecAng, ally);
		}
		case MAD_ROOST:
		{
			entity = MadRoost(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR:
		{
			entity = HeavyBear(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR_BOSS:
		{
			entity = HeavyBearBoss(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR_MINION:
		{
			entity = HeavyBearMinion(client, vecPos, vecAng, ally);
		}
		case MINER_NPC:
		{
			entity = Miner_Enemy(client, vecPos, vecAng, ally);
		}
		default:
		{
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%i] Is not a valid npc!", Index_Of_Npc);
		}
	}
	
	return entity;
}	

public void NPCDeath(int entity)
{
	switch(i_NpcInternalId[entity])
	{
		case START_CHICKEN:
		{
			StartChicken_NPCDeath(entity);
		}
		case MAD_CHICKEN:
		{
			MadChicken_NPCDeath(entity);
		}
		case MAD_ROOST:
		{
			MadRoost_NPCDeath(entity);
		}
		case HEAVY_BEAR:
		{
			HeavyBear_NPCDeath(entity);
		}
		case HEAVY_BEAR_BOSS:
		{
			HeavyBearBoss_NPCDeath(entity);
		}
		case HEAVY_BEAR_MINION:
		{
			HeavyBearMinion_NPCDeath(entity);
		}
		case MINER_NPC:
		{
			Miner_Enemy_NPCDeath(entity);
		}
		default:
		{
			PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		}
	}
	
	/*if(view_as<CClotBody>(entity).m_iCreditsOnKill)
	{
		CurrentCash += view_as<CClotBody>(entity).m_iCreditsOnKill;
			
		int extra;
		
		int client_killer = GetClientOfUserId(LastHitId[entity]);
		if(client_killer && IsClientInGame(client_killer))
		{
			extra = RoundToFloor(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * Building_GetCashOnKillMulti(client_killer));
			extra -= view_as<CClotBody>(entity).m_iCreditsOnKill;
		}
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(extra > 0)
				{
					CashSpent[client] -= extra;
					CashRecievedNonWave[client] += extra;
				}
				if(GetClientTeam(client)!=2)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.40);
					
				}
				else if (TeutonType[client] == TEUTON_WAITING)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.30);
				}
			}
		}
	}*/
}

public void NPC_Despawn(int entity)
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

		RemoveEntity(entity);
	}
}

public void Npc_Base_Thinking(int entity, float distance, char[] WalkBack, char[] StandStill, float walkspeedback, float gameTime)
{
	CClotBody npc = view_as<CClotBody>(entity);

	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		int entity_found = GetClosestTarget(npc.index, false, distance);
		if(npc.m_flGetClosestTargetNoResetTime > gameTime) //We want to make sure that their aggro doesnt get reset instantly!
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See)) //Can i even see this enemy that i want to go to newly?
				{
					//found enemy, go to new enemy
					npc.m_iTarget = Enemy_I_See;
				}
			}
		}
		else //Allow the reset of aggro.
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
								
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					//if we want to search for new enemies, it must be a valid one that can be seen.
					npc.m_iTarget = Enemy_I_See;
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
			if(fl_DistanceToOriginalSpawn > Pow(80.0, 2.0)) //We are too far away from our home! return!
			{
				PF_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity(WalkBack);
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
					npc.SetActivity(StandStill);
				}

				char HealthString[512];
				Format(HealthString, sizeof(HealthString), "%i | %i", Health, MaxHealth);
		
				DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
			}
		}
		npc.m_flGetClosestTargetTime = 0.0;
	}
	else
	{
		i_NoEntityFoundCount[npc.index] = 0;
	}

	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly, also happens when they stop follwing.
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_bPathing)
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;	
		}
	}
	else
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = walkspeedback;
		}
		if(!npc.m_bPathing)
			npc.StartPathing();
	}
}

#include "rpg_fortress/npc/normal/npc_chicken_2.sp"
#include "rpg_fortress/npc/normal/npc_chicken_mad.sp"
#include "rpg_fortress/npc/normal/npc_roost_mad.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_boss.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_minion.sp"
#include "rpg_fortress/npc/normal/npc_miner.sp"
