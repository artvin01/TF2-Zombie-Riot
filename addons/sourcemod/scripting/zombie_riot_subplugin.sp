#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <zombie_riot>
#undef REQUIRE_PLUGIN	// Lateload Fix

//This exists for you to see how to make the sub plugins!

public void ZR_OnRevivingPlayer(int reviver, int revived)
{
	PrintToServer("[ZR] Client %i(%N) revived %i(%N)!",reviver, reviver,revived, revived);
}