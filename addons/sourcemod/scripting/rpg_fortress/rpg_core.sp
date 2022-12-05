#pragma semicolon 1
#pragma newdecls required

int Tier[MAXTF2PLAYERS];
int Level[MAXENTITIES];
int XP[MAXENTITIES];

#include "rpg_fortress/npc.sp"	// Global NPC List

#include "rpg_fortress/zones.sp"

void RPG_PluginStart()
{
	LoadTranslations("rpgfortress.phrases.enemynames");
	
	Zones_PluginStart();
}

void RPG_MapStart()
{
	Zero2(f3_SpawnPosition);
}