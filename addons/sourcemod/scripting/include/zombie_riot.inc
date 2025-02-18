#if defined _zombie_riot_included
	#endinput
#endif
#define _zombie_riot_included

#include <tf2>

/**
 * Applies effects as if an NPC died
 * Old native from early zombie riot subplugins
 * 
 * @param entity	Entity index of NPC
 * 
 * @error		Invalid entity index
 * 
 * @noreturn
 */
#pragma deprecated Do not use this function.
native void ZR_ApplyKillEffects(int entity);

/**
 * Returns the level of a player
 * 
 * @param client	Client index
 * 
 * @error		Invalid client index
 * 
 * @return		Player's level
 */
native int ZR_GetLevelCount(int client);

/**
 * Returns the current wave number
 * For display purposes, "Wave 30" is 29
 * 
 * Rogue: The wave of an active stage, not the floor
 * Construction: The wave of an active fight
 * 
 * @return		Wave number
 */
native int Waves_GetRound();

/**
 * Returns if a player has a certain unlock
 * 
 * @param client	Client index or 0 to check if any active player has it
 * @param item		Item name
 * 
 * @error		Invalid client index
 * 
 * @return		True if the player has the unlock, false otherwise
 */
native bool ZR_HasNamedItem(int client, const char[] item);

/**
 * Gives a player a certain unlock
 * 
 * @param client	Client index
 * @param item		Item name
 * 
 * @error		Invalid client index
 * 
 * @return		True if newly added, false otherwise
 */
native bool ZR_GiveNamedItem(int client, const char[] item);

/**
 * Returns the alive status of a player
 * 
 * @param client	Client index
 * 
 * @error		Invalid client index or client is not in game
 * 
 * @return		0 for alive, 1 for downed, 2 for teuton, 3 for dead, 4 for spec
 */
native int ZR_GetAliveStatus(int client);

/**
 * Called when a difficulty is selected
 * Will be called after all votes are done
 * 
 * Rogue/Construction: Called when an starting item is voted for
 * 
 * @param index		Index has it was on the vote menu (will be -1 if a modifier vote happened)
 * @param name		Name of the difficulty
 * @param level		Display level of difficulty and modifier
 * 
 * @noreturn
 */
forward void ZR_OnDifficultySet(int index, const char[] name, int level);

/**
 * Called when a player has loaded information from the database
 * 
 * @param client	Client index
 * 
 * @noreturn
 */
forward void ZR_OnClientLoaded(int client);

/**
 * Called when a player model is being set
 * 
 * @param client	Client index
 * @param class		Player's selected class
 * @param worldmodel	Model index of player
 * @param soundOverride	Voiceline override (-1 for normal class)
 * @param bodyOverride	Model bodygroup override (-1 for no change)
 * @param animOverride	Override animations to the model index
 * 
 * @return		Plugin_Changed if changed
 */
forward Action ZR_OnClientWorldmodel(int client, TFClassType class, int &worldmodel, int &soundOverride, int &bodyOverride, bool &animOverride);

public SharedPlugin __pl_zombie_riot =
{
	name = "zombie_riot",
	file = "zombie_riot.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_zombie_riot_SetNTVOptional()
{
	MarkNativeAsOptional("ZR_ApplyKillEffects");
	MarkNativeAsOptional("ZR_GetLevelCount");
	MarkNativeAsOptional("Waves_GetRound");
	MarkNativeAsOptional("ZR_HasNamedItem");
	MarkNativeAsOptional("ZR_GiveNamedItem");
	MarkNativeAsOptional("ZR_GetAliveStatus");
}
#endif
