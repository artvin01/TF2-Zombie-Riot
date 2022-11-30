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

#include "zombie_riot/npc/normal/npc_headcrabzombie.sp"
