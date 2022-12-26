#if defined _textstore_included
	#endinput
#endif
#define _textstore_included

#define STORE_PREFIX	"{purple}[RPG]{snow} "
#define STORE_PREFIX2	"{purple}[RPG] "
#define STORE_COLOR	"{snow}"
#define STORE_COLOR2	"{purple}"

enum ItemResult
{
	Item_None = 0,	// Do nothing to the item
	Item_Used,	// Delete one use of the item
	Item_On,		// Equip the item on the client
	Item_Off		// Unequip the item on the client
};

/**
 * Change a client's inventory count/equippment
 *
 * @param client	Client index of using item
 * @param item		Index of the item
 * @param count		Amount of the item
 * @param equip		If to force unequip or equip the item
 *
 * @noreturn
 */
native void TextStore_SetInv(int client, int item, int count=-1, int equip=-1);

/**
 * Get a client's inventory count/equippment
 *
 * @param client	Client index
 * @param item		Item index
 * @param count		Amount of the item in the client's inventory
 *
 * @return		If the item is equipped
 */
native bool TextStore_GetInv(int client, int item, int &count=0);

/**
 * Get, give, remove cash on a client
 *
 * @param client	Client index
 * @param cash		Cash to give/remove
 *
 * @return		New cash value
 */
native int TextStore_Cash(int client, int cash=0);

/**
 * Forces the client to save their current items into the database
 *
 * @param client	Client index
 *
 * @noreturn
 */
native void TextStore_ClientSave(int client);

/**
 * Forces the client to get their current items from previous save
 *
 * @param client	Client index
 *
 * @noreturn
 */
native void TextStore_ClientReload(int client);

/**
 * If the client has their inventory loaded from a save
 *
 * @param client	Client index
 *
 * @return		If the client has items loaded
 */
native bool TextStore_GetClientLoad(int client);

/**
 * Sets if the client has their inventory loaded from a save (If to call saving or not)
 *
 * @param client	Client index
 * @param status	If the player is considered loaded
 *
 * @noreturn
 */
native void TextStore_SetClientLoad(int client, bool status);

/**
 * Gets the current amount of items and categories in the store
 *
 * @param uniques	Number of unique items
 *
 * @return		Amount of items and categories
 */
native int TextStore_GetItems(int &uniques=0);

/**
 * Gets the name of the item
 *
 * @note		Do not close the KeyValues handle given
 *
 * @param item		Item index
 *
 * @return		KeyValues handle
 */
native KeyValues TextStore_GetItemKv(int item);

/**
 * Gets the name of the item
 *
 * @param item		Item index
 * @param buffer	String to write to
 * @param count		Size of the string
 *
 * @return		Number of bytes written
 */
native int TextStore_GetItemName(int item, char[] buffer, int length);

/**
 * Sets the name of a unique item
 *
 * @param item		Item index
 * @param name		Custom item name
 *
 * @noreturn
 */
native void TextStore_SetItemName(int item, const char[] name="");

/**
 * Gets data of a unique item
 *
 * @param item		Item index
 * @param buffer	String to write to
 * @param count		Size of the string
 *
 * @return		Number of bytes written
 */
native int TextStore_GetItemData(int item, char[] buffer, int length);

/**
 * Sets data of a unique item
 *
 * @param item		Item index
 * @param data		Item data string
 *
 * @noreturn
 */
native void TextStore_SetItemData(int item, const char[] data);

/**
 * Creates a unique variant of an item
 *
 * @param client	Client index
 * @param item		Base item index
 * @param data		Item data string
 * @param name		Custom item name
 * @param equipped	If given equipped
 *
 * @return		Given item index
 */
native int TextStore_CreateUniqueItem(int client, int item, const char[] data, const char[] name="", bool equipped=false);

/**
 * Activates an item from the client
 *
 * @param client	Client index
 * @param item		Item index
 * @param auto		If to consider this an auto equip
 *
 * @return		For common items: true if success. For unique items: true if the owner is still valid, false otherwise
 */
native bool TextStore_UseItem(int client, int item, bool auto=false);

/**
 * Gets if the item is hidden in the store
 *
 * @param item		Item index
 *
 * @return		If the item is hidden
 */
native bool TextStore_GetItemHidden(int item);

/**
 * Sets if the item is hidden in the store
 *
 * @param item		Item index
 * @param hidden	If the item is hidden
 *
 * @noreturn
 */
native void TextStore_SetItemHidden(int item, bool hidden);

/**
 * Gets the item's parent category
 *
 * @param item		Item index
 *
 * @return		Parent item index
 */
native int TextStore_GetItemParent(int item);

/**
 * Sets the item's parent category
 *
 * @param item		Item index
 * @param parent	Parent item index
 *
 * @noreturn
 */
native void TextStore_SetItemParent(int item, bool parent);

/**
 * Called when a client's item is about to be sold
 *
 * @param client	Client index
 * @param item		Item index
 * @param cash		The current "cash" the client has
 * @param count		The current amount of the item the client has
 * @param sell		The amount the item is being sold for
 *
 * @return		Plugin_Changed to change values, Plugin_Handled/Plugin_Stop to prevent the sell
 */
forward Action TextStore_OnSellItem(int client, int item, int cash, int &count, int &sell);

/**
 * Called when a description of an item is about to be shown
 *
 * @param client	Client index
 * @param item		Item index
 * @param desc		Description of the item
 *
 * @noreturn
 */
forward void TextStore_OnDescItem(int client, int item, char[] desc);

/**
 * Called when a client's items are loading into cache
 *
 * @param client	Client index
 * @param file		TextStore save file
 *
 * @return		Plugin_Changed to change the filepath, Plugin_Handled to not load items but consider client loaded, Plugin_Stop to prevent loading
 */
forward Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH]);

/**
 * Called when a client's items are saving into a file
 *
 * @param client	Client index
 * @param file		TextStore save file
 *
 * @return		Plugin_Changed to change the filepath, Plugin_Handled/Plugin_Stop to not save items
 */
forward Action TextStore_OnClientSave(int client, char file[PLATFORM_MAX_PATH]);

/**
 * Called when a client enters the main menu
 *
 * @param client	Client index
 * @param menu		Menu handle, don't close this handle
 *
 * @return		Plugin_Handled/Plugin_Stop to prevent the menu from showing
 */
forward Action TextStore_OnMainMenu(int client, Menu menu);

/**
 * Called when a client is about to enter a store page
 *
 * @param client	Client index
 *
 * @noreturn
 */
forward void TextStore_OnCatalog(int client, Menu menu);

/**
 * Called when a client is about to buy an item
 *
 * @param client	Client index
 * @param item		Item index
 * @param cash		The current "cash" the client has
 * @param count		The current amount of the item the client has
 * @param cost		The amount the item is being sold for
 *
 * @return		Plugin_Changed to change values, Plugin_Handled/Plugin_Stop to prevent buying
 */
forward Action TextStore_OnBuyItem(int client, int item, int cash, int &count, int &cost);

/**
 * Called when an item's price displayed to the client
 *
 * @param client	Client index
 * @param item		Item index
 * @param price		Item's price
 *
 * @return		Plugin_Changed to change values, Plugin_Handled/Plugin_Stop to prevent buying
 */
forward Action TextStore_OnPriceItem(int client, int item, int &price);

/**
 * Called to a given plugin when a item is used
 *
 * @note		This is not actually a forward, this is called per plugin
 * @note		Do not close the KeyValues handle given
 *
 * @param client	Client index
 * @param equipped	If the item is already equipped on the client
 * @param item		KeyValue of the item (already in place)
 * @param index		Item Index
 * @param name		Name of the item
 * @param count		Amount of the item in the client's inventory
 * @param auto		If the item was used automatically, usually by connecting
 *
 * @return		Item result
 */
forward ItemResult TextStore_Item(int client, bool equipped, KeyValues item, int index, const char[] name, int &count, bool auto);

/**
 * Prints a color message with the store's prefix
 *
 * Uses the same params and return values as CPrintToChat, CPrintToChatAll, and CReplyToCommand
 */
#if defined _colors_included
stock void SPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, "%s%s", STORE_PREFIX, buffer);
}
stock void SPrintToChatAll(const char[] message, any ...)
{
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 2);
	CPrintToChatAll("%s%s", STORE_PREFIX, buffer);
}
stock void SReplyToCommand(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	if(!client)
	{
		CRemoveTags(buffer, sizeof(buffer));
		PrintToServer("[Store] %s", buffer);
	}
	else if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "[Store] %s", buffer);
	}
	else
	{
		CPrintToChat(client, "%s%s", STORE_PREFIX, buffer);
	}
}
#endif

public SharedPlugin __pl_TextStore =
{
	name = "textstore",
	file = "textstore.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_TextStore_SetNTVOptional()
{
	MarkNativeAsOptional("TextStore_GetInv");
	MarkNativeAsOptional("TextStore_SetInv");
	MarkNativeAsOptional("TextStore_Cash");
	MarkNativeAsOptional("TextStore_ClientSave");
	MarkNativeAsOptional("TextStore_ClientReload");
	MarkNativeAsOptional("TextStore_GetClientLoad");
	MarkNativeAsOptional("TextStore_SetClientLoad");
	MarkNativeAsOptional("TextStore_GetItems");
	MarkNativeAsOptional("TextStore_GetItemKv");
	MarkNativeAsOptional("TextStore_GetItemName");
	MarkNativeAsOptional("TextStore_SetItemName");
	MarkNativeAsOptional("TextStore_GetItemData");
	MarkNativeAsOptional("TextStore_SetItemData");
	MarkNativeAsOptional("TextStore_CreateUniqueItem");
	MarkNativeAsOptional("TextStore_UseItem");
	MarkNativeAsOptional("TextStore_GetItemHidden");
	MarkNativeAsOptional("TextStore_SetItemHidden");
	MarkNativeAsOptional("TextStore_GetItemParent");
	MarkNativeAsOptional("TextStore_SetItemParent");
}
#endif
