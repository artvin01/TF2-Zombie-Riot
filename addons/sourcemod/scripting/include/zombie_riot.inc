#if defined _zombie_riot_included
	#endinput
#endif
#define _zombie_riot_included

#include <tf2>

enum ZRSpecialMode
{
	Mode_Standard = 0,
	Mode_Rogue1,
	Mode_Rogue2,
	Mode_Rogue3,
	Mode_BetWars,
	Mode_Construction,
}

enum ZRLifeState
{
	LifeState_Alive = 0,
	LifeState_Downed,
	LifeState_Teuton,
	LifeState_Dead,
	LifeState_Spectator,
}

enum ZRGiftRarity
{
	None = -1,
	Common,
	Uncommon,
	Rare,
	Legend,
	Mythic
}

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
 * @return		The life state
 */
native ZRLifeState ZR_GetAliveStatus(int client);

/**
 * Returns the current special mode
 * 
 * @return		The current special mode
 */
native ZRSpecialMode ZR_GetSpecialMode();

/**
 * Set Client XP Yourself
 * 
 * @param client	Client index
 * @param XP		XP obtained or lost, level is set silently automatically with this
 * 
 * @return
 */
native void ZR_SetXpAndLevel(int client, int Xp);

/**
 * Get The XP of the client Now, usefull on disconnect
 * 
 * @param client	Client index
 *  To calculate levels and all, please use this formular.
 * 
 * @return
 */
native int ZR_GetXp(int client);

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
 * Called when a player wants to rename the rebel or use any renaming
 * 
 * @param client	Client index
 * 
 * @return  yes can or not cannot
 */
forward bool ZR_CanRenameNPCs(int client);

/**
 * Called when a player model is being set
 * 
 * @param client	Client index
 * @param class		Player's selected class
 * @param worldmodel	Model index of player
 * @param soundOverride	Voiceline override (-1 for normal class)
 * @param bodyOverride	Model bodygroup override (-1 for no change)
 * @param animOverride	Override animations to the model index
 * @param noCosmetic	If to render all econ cosmetics as nodraw
 * 
 * @return		Plugin_Changed if changed
 */
forward Action ZR_OnClientWorldmodel(int client, TFClassType class, int &worldmodel, int &soundOverride, int &bodyOverride, bool &animOverride, bool &noCosmetic);

/**
 * Called when a player receives a certain unlock (including duplicates)
 * 
 * @param client	Client index
 * @param item		Item name
 * @param id		ID of the item
 * 
 * @return		Plugin_Changed if the item was changed, Plugin_Handled to stop the item from being given
 */
forward Action ZR_OnGivenItem(int client, char item[64], int id);

/**
 * Called when a player kills a NPC
 * 
 * @param client	Client index
 * @param name		NPC name
 * 
 * @noreturn
 */
forward void ZR_OnKilledNPC(int client, const char[] name);

/**
 * Called when a player revives another player (downed to not downed)
 * 
 * @param reviver	reviver index
 * @param revived	revived player
 * 
 * @noreturn
 */
forward void ZR_OnRevivingPlayer(int reviver, int revived);

/**
 * Called when cash is earned, either global or one player
 * 
 * @param client	Client index, 0 for all players
 * @param cash		Cash obtained
 * 
 * @return		Plugin_Changed if the amount was changed, Plugin_Handled to stop cash being given
 */
forward Action ZR_OnGivenCash(int client, int &cash);

/**
 * Whenever any team won in ZR
 * 
 * @param Team	What Team
 * 
 * @return		Plugin_Changed if the amount was changed, Plugin_Handled to stop cash being given
 */
forward Action ZR_OnWinTeam(TFTeam Team);

/**
 * Whenever any client gets XP, this is spammed! Be Warned!
 * 
 * @param client	Client index
 * @param XP		XP obtained or lost
 * @param Mode		0= Xp added or lost, 1= XP On disconnect or an admin sets it.
 * 					2 is internal database if you want it.
 * 
 * @return	
 */
forward void ZR_OnGetXP(int client, int Xp, int Mode);

/**
 * Called when a wave ends
 * 
 * Rogue/Construction: Called during the stage/raid
 * 
 * @param waves		New wave number
 * @param maxwaves	Displayed max number of waves
 * @param realmaxwaves	Real max number of waves
 * 
 * @return	
 */
forward void ZR_OnWaveEnd(int waves, int maxwaves, int realmaxwaves);


/**
 * Called when a floor ends
 * 
 * Rogue/Construction: When a floor/Wave Ends
 * 
 * @param CurrentFloor	What the new floor is (can never be 1 due to this)
 * @param MaxFloor	What max floor amount is (This can change midgame due to items)
 * 
 * @return	
 */
forward void ZR_OnSpecialModeProgress(int CurrentFloor, int MaxFloor);

/**
 * Whenever a gift is collected
 * 
 * @param Collector	 What client collected
 * @param Rarity	 What rarity was it
 * 
 * @return	
 */
forward void ZR_OnGiftCollected(int Collector, ZRGiftRarity Rarity)

stock int XpToLevel(int xp)
{
	return RoundToFloor(Pow(xp / 200.0, 0.5));
}

stock int LevelToXp(int lv)
{
	return lv * lv * 200;
}

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
	MarkNativeAsOptional("ZR_OnWinTeam");
	MarkNativeAsOptional("ZR_OnGiftCollected");
	MarkNativeAsOptional("ZR_GetSpecialMode");
	MarkNativeAsOptional("ZR_OnGetXP");
	MarkNativeAsOptional("ZR_SetXpAndLevel");
	MarkNativeAsOptional("ZR_GetXp");
}
#endif
