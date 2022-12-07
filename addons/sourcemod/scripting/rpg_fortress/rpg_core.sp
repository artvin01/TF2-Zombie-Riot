#pragma semicolon 1
#pragma newdecls required

int Tier[MAXTF2PLAYERS];
int Level[MAXENTITIES];
int Cash[MAXENTITIES];
int XP[MAXENTITIES];

int BackpackBonus[MAXTF2PLAYERS];

#include "rpg_fortress/npc.sp"	// Global NPC List

#include "rpg_fortress/levels.sp"
#include "rpg_fortress/spawns.sp"
#include "rpg_fortress/stats.sp"
#include "rpg_fortress/textstore.sp"
#include "rpg_fortress/zones.sp"

void RPG_PluginStart()
{
	LoadTranslations("rpgfortress.phrases.enemynames");
	
	Store_Reset();
	Levels_PluginStart();
	TextStore_PluginStart();
	Zones_PluginStart();

	CountPlayersOnRed();
}

void RPG_PluginEnd()
{
	char buffer[64];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			if(StrEqual(buffer, "base_boss"))
			{
				NPC_Despawn(i);
				continue;
			}
			else if(!StrContains(buffer, "prop_dynamic"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrEqual(buffer, "rpg_fortress"))
					continue;
			}
			else if(!StrContains(buffer, "prop_physics"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrContains(buffer, "rpg_item"))
					continue;
			}
			else
			{
				continue;
			}

			RemoveEntity(i);
		}
	}
}

void RPG_MapStart()
{
	Zero2(f3_SpawnPosition);
}

void RPG_MapEnd()
{
	Spawns_MapEnd();
}

void RPG_PutInServer()
{
	CountPlayersOnRed();
}

void RPG_ClientDisconnect_Post()
{
	CountPlayersOnRed();
}