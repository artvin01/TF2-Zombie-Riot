#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9

enum
{
	Flag_Light = 0,
	Flag_Heavy,
	Flag_Biological,
	Flag_Mechanical,
	Flag_Structure,
	Flag_Unique,
	Flag_Heroic,
	Flag_Summoned
}

enum
{
	Command_Idle = 0,
	Command_Move,
	Command_Attack,
	Command_HoldPos,
	Command_Patrol
}

#include "fortress_wars/npc.sp"	// Global NPC List

static bool AlliedPlayer[MAXTF2PLAYERS][MAXTF2PLAYERS];
static bool AllowControl[MAXTF2PLAYERS][MAXTF2PLAYERS];

void RTS_PluginStart()
{
	
}

bool RTS_IsPlayerAlly(int attacker, int target)
{
	return attacker == target || AlliedPlayer[attacker][target];
}

bool RTS_CanPlayerControl(int attacker, int target)
{
	return attacker == target || AllowControl[attacker][target];
}