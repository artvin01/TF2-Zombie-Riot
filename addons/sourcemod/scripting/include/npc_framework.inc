#if defined _npc_framework_included
	#endinput
#endif
#define _npc_framework_included

/**
 * Returns the first item on the page of a currently selected menu.
 *
 * This is only valid inside a MenuAction_Select callback.
 *
 * @param name		Internal plugin name of the NPC
 * @param client	Client index for ownership (in some NPCs)
 * @param pos		Spawn position
 * @param ang		Spawn angles
 * @param team		Team number (can be above 3 to use custom teams)
 * @param data		String data used in some NPCs
 * 
 * @return		Entity index of NPC or -1
 * @error		Invalid NPC name, invalid team number, or NPC internal error
 */
native int NPC_SpawnNPC(const char[] name, int client = 0, const float pos[3] = NULL_VECTOR, const float ang[3] = NULL_VECTOR, int team = 4, const char[] data = "");

#if !defined REQUIRE_PLUGIN
public void __pl_npc_framework_SetNTVOptional()
{
	MarkNativeAsOptional("NPC_SpawnNPC");
}
#endif
