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
	Flag_Summoned,
	Flag_Worker
}

enum
{
	Command_Idle = 0,
	Command_Move,
	Command_Attack,
	Command_HoldPos,
	Command_Patrol
}

enum
{
	Sound_Select,
	Sound_Move,
	Sound_Attack,
	Sound_CombatAlert,
	
	Sound_MAX
}

#include "fortress_wars/npc.sp"	// Global NPC List

static bool InSetup;
static bool AlliedPlayer[MAXTF2PLAYERS][MAXTF2PLAYERS];
static bool AllowControl[MAXTF2PLAYERS][MAXTF2PLAYERS];

void RTS_PluginStart()
{
	
}

void RTS_PlayerResupply(int client)
{
	if(!RTS_InSetup())
	{
		TF2_RemoveAllWeapons(client);
		SpawnWeapon(client, "tf_weapon_shotgun_primary", 199, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		SpawnWeapon(client, "tf_weapon_pistol", 209, 1, 0, {128, 301, 821, 2}, {1.0, 1.0, 1.0, 0.0}, 4);
		SpawnWeapon(client, "tf_weapon_wrench", 197, 1, 0, {128, 821, 2}, {1.0, 1.0, 0.0}, 3);
		SpawnWeapon(client, "tf_weapon_pda_engineer_build", 737, 1, 0, {81}, {0.0}, 1);
	}
}

bool RTS_InSetup()
{
	return InSetup;
}

bool RTS_IsPlayerAlly(int attacker, int target)
{
	return attacker == target || AlliedPlayer[attacker][target];
}

bool RTS_CanPlayerControl(int attacker, int target)
{
	return attacker == target || AllowControl[attacker][target];
}