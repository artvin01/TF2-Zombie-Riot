#pragma semicolon 1
#pragma newdecls required

enum
{
	NOTHING 				= 0,
	START_CHICKEN 			= 1,
	MAD_CHICKEN 			= 2
}

public const char NPC_Names[][] =
{
	"nothing",
	"Chicken",
	"Mad Chicken"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"",
	"npc_chicken_2",
	"npc_chicken_mad"
};

void NPC_MapStart()
{
	MadChicken_OnMapStart_NPC();
	StartChicken_OnMapStart_NPC();
}

any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
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
		RemoveEntity(entity);

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
	}


}

public void Npc_Base_Thinking(int entity, float distance, char[] WalkBack, char[] StandStill, float walkspeedback, float gameTime)
{
	CClotBody npc = view_as<CClotBody>(entity);

	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		int entity_found = GetClosestTarget(npc.index, false, f_DefaultAggroRange);
		if(npc.m_flGetClosestTargetNoResetTime > gameTime) //We want to make sure that their aggro doesnt get reset instantly!
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				npc.m_iTarget = entity_found;
			}
		}
		else //Allow the reset of aggro.
		{
			npc.m_iTarget = entity_found;
		}
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		NoNewEnemy += 1; //no enemy found, increment a few times.
		if(NoNewEnemy > 11) //There was no enemies found after like 11 tries, which is a second. go back to our spawn position.
		{	
			float vecTarget[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float fl_DistanceToOriginalSpawn = GetVectorDistance(vecTarget, f3_SpawnPosition, true);
			if(fl_DistanceToOriginalSpawn > Pow(80.0, 2.0)) //We are too far away from our home! return!
			{
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity(WalkBack);
				}

			}
			else
			{
				//We now afk and are back in our spawnpoint heal back up, but not instantly incase they quickly can attack again.

				int HealthToHealPerIncrement = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 100;

				if(HealthToHealPerIncrement < 1) //should never be 0
				{
					HealthToHealPerIncrement = 1;
				}

				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + HealthToHealPerIncrement);

				if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
				}
				//Slowly heal when we are standing still.

				npc.m_bisWalking = false;
				if(npc.m_iChanged_WalkCycle != 5) 	//Stand still.
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity(StandStill);
				}
			}
		}
		npc.m_flGetClosestTargetTime = 0.0;
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
