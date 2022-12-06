#pragma semicolon 1
#pragma newdecls required

int Tier[MAXTF2PLAYERS];
int Level[MAXENTITIES];
int Cash[MAXENTITIES];
int XP[MAXENTITIES];

#include "rpg_fortress/npc.sp"	// Global NPC List

#include "rpg_fortress/levels.sp"
#include "rpg_fortress/spawns.sp"
#include "rpg_fortress/textstore.sp"
#include "rpg_fortress/zones.sp"

void RPG_PluginStart()
{
	LoadTranslations("rpgfortress.phrases.enemynames");
	
	Store_Reset();
	Levels_PluginStart();
	Zones_PluginStart();

	CountPlayersOnRed();
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