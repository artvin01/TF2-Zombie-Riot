#pragma semicolon 1
#pragma newdecls required

static KeyValues HashKey;

#define ITEM_XP		"Experience Points"
static int ItemXP = -1;

#define ITEM_TIER	"Elite Promotions"
static int ItemTier = -1;

static void HashCheck(KeyValues kv)
{
	if(kv != HashKey)
	{
		ItemXP = -1;
		ItemTier = -1;
		HashKey = kv;
	}
}

void TextStore_ConfigSetup()
{
	HashCheck(TextStore_GetItemKv(0));
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && TextStore_GetClientLoad(client))
			LoadItems(client);
	}
}

public ItemResult TextStore_Item(int client, bool equipped, KeyValues item, int index, const char[] name, int &count, bool auto)
{
	HashCheck(item);

	if(equipped)
		return Item_Off;
	
	Store_EquipItem(client, item, index, name, auto);
	return Item_On;
}

public Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH])
{
	RequestFrame(TextStore_LoadFrame, GetClientUserId(client));
	return Plugin_Continue;
}

public void TextStore_LoadFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(TextStore_GetClientLoad(client))
		{
			HashCheck(TextStore_GetItemKv(0));
			LoadItems(client);
		}
		else
		{
			RequestFrame(TextStore_LoadFrame, userid);
		}
	}
}

static void LoadItems(int client)
{
	char buffer[48];
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, ITEM_XP, false))
		{
			TextStore_GetInv(client, i, XP[client]);
			ItemXP = i;
		}
		else if(StrEqual(buffer, ITEM_TIER, false))
		{
			TextStore_GetInv(client, i, Tier[client]);
			ItemTier = i;
		}
	}

	Level[client] = XpToLevel(XP[client]);
	int cap = GetLevelCap(Tier[client]);
	if(Level[client] > cap)
		Level[client] = cap;
}

void TextStore_AddXP(int client, int xp)
{
	HashCheck(TextStore_GetItemKv(0));
	if(ItemXP != -1)
	{
		TextStore_GetInv(client, ItemXP, XP[client]);
		XP[client] += xp;
		TextStore_SetInv(client, ItemXP, XP[client]);
	}
}

stock void TextStore_AddTier(int client)
{
	HashCheck(TextStore_GetItemKv(0));
	if(ItemTier != -1)
	{
		TextStore_GetInv(client, ItemTier, Tier[client]);
		Tier[client]++;
		TextStore_SetInv(client, ItemTier, Tier[client]);
	}
}