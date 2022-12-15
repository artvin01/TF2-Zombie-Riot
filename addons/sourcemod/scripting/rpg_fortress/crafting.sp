#pragma semicolon 1
#pragma newdecls required

enum struct CraftEnum
{
	char Zone[32];
	char Item[48];
}

static ArrayList CraftList;

void Crafting_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Crafting"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "crafting");
		kv = new KeyValues("Crafting");
		kv.ImportFromFile(buffer);
	}
	
	delete CraftList;
	CraftList = new ArrayList(sizeof(CraftEnum));

	CraftEnum craft;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(craft.Zone, sizeof(craft.Zone));
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(craft.Item, sizeof(craft.Item));
					CraftList.PushArray(craft);
				}
				while(kv.GotoNextKey(false));
			}
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
}

void Crafting_ClientEnter(int client, const char[] zone)
{
	if(CraftList)
	{
		static CraftEnum craft;
		int length = CraftList.Length;
		for(int i; i < length; i++)
		{
			CraftList.GetArray(i, craft);
			if(StrEqual(craft.Zone, zone))
			{
				int length = TextStore_GetItems();
				for(int a; a < length; a++)
				{
					static char buffer[48];
					TextStore_GetItemName(a, buffer, sizeof(buffer));
					if(StrEqual(buffer, craft.Item, false))
					{
						TextStore_SetInv(client, a, 1);
						break;
					}
				}
			}
		}
	}
}

void Crafting_ClientLeave(int client, const char[] zone)
{
	if(CraftList)
	{
		static CraftEnum craft;
		int length = CraftList.Length;
		for(int i; i < length; i++)
		{
			CraftList.GetArray(i, craft);
			if(StrEqual(craft.Zone, zone))
			{
				int length = TextStore_GetItems();
				for(int a; a < length; a++)
				{
					static char buffer[48];
					TextStore_GetItemName(a, buffer, sizeof(buffer));
					if(StrEqual(buffer, craft.Item, false))
					{
						TextStore_SetInv(client, a, 0);
						break;
					}
				}
			}
		}
	}
}

void Crafting_AllowedFishing(int client, bool allowed)
{
	static bool InWater[MAXTF2PLAYERS];
	if(InWater[client])
	{
		if(!allowed)
		{
			int length = TextStore_GetItems();
			for(int i; i < length; i++)
			{
				static char buffer[48];
				TextStore_GetItemName(i, buffer, sizeof(buffer));
				if(StrEqual(buffer, "Water Source", false))
				{
					TextStore_SetInv(client, i, 0);
					InWater[client] = false;
					break;
				}
			}
		}
	}
	else if(allowed)
	{
		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			static char buffer[48];
			TextStore_GetItemName(i, buffer, sizeof(buffer));
			if(StrEqual(buffer, "Water Source", false))
			{
				TextStore_SetInv(client, i, 1);
				InWater[client] = true;
				break;
			}
		}
	}
}