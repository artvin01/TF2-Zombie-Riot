#pragma semicolon 1
#pragma newdecls required

int Level[MAXENTITIES];
int XP[MAXENTITIES];

#include "rpg_fortress/npc.sp"	// Global NPC List

void RPG_MapStart()
{
	Zero2(f3_SpawnPosition);
}