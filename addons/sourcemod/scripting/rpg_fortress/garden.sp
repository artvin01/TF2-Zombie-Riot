#pragma semicolon 1
#pragma newdecls required

enum struct GardenEnum
{
	char Zone[32];
	float Pos[3];
	
	int Item[MAXTF2PLAYERS];
	float ReadyIn[MAXTF2PLAYERS];
}

static ArrayList GardenList;
static char InGarden[MAXTF2PLAYERS][32];
static float UpdateTrace[MAXTF2PLAYERS];
static int InMenu[MAXTF2PLAYERS];

void Garden_ResetAll()
{
	if(GardenList)
	{
		GardenEnum garden;
		int length = GardenList.Length;
		for(int i; i < length; i++)
		{
			GardenList.GetArray(i, garden);
			Zero(garden.ReadyIn);
			Zero(garden.Item);
			GardenList.SetArray(i, garden);
		}
	}
}

void Garden_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Garden"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "garden");
		kv = new KeyValues("Garden");
		kv.ImportFromFile(buffer);
	}
	
	delete GardenList;
	GardenList = new ArrayList(sizeof(GardenEnum));

	GardenEnum garden;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(garden.Zone, sizeof(garden.Zone));
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					ExplodeStringFloat(buffer, " ", garden.Pos, sizeof(garden.Pos));
					GardenList.PushArray(garden);
				}
				while(kv.GotoNextKey(false));
			}
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
}

static int GetNearestGarden(const char[] zone, const float pos[3])
{
	int found = -1;
	float distance = 10000.0;
	
	int length = GardenList.Length;
	for(int i; i < length; i++)
	{
		static GardenEnum garden;
		GardenList.GetArray(i, garden);
		if(StrEqual(garden.Zone, zone, false))
		{
			float dist = GetVectorDistance(pos, garden.Pos, true);
			if(dist < distance)
			{
				found = i;
				distance = dist;
			}
		}
	}
	
	return found;
}

void Garden_ClientEnter(int client, const char[] zone)
{
	if(GardenList.FindString(zone, GardenEnum::Zone) != -1)
	{
		strcopy(InGarden[client], sizeof(InGarden[]), zone);
		UpdateTrace[client] = 0.0;
	}
}

void Garden_ClientLeave(int client, const char[] zone)
{
	if(StrEqual(InGarden[client], zone))
	{
		InGarden[client][0] = 0;
		if(InMenu[client])
			CancelClientMenu(client);
	}
}

void Garden_Interact(int client, const float pos[3])
{
	if(InGarden[client][0])
	{
		int index = GetNearestGarden(InGarden[client], pos);
		if(index != -1)
		{
			InMenu[client] = index;
			ShowMenu(client);
		}
	}
}

void Garden_PlayerRunCmd(int client)
{
	if(InGarden[client][0])
	{
		float gameTime = GetGameTime();
		if(UpdateTrace[client] < gameTime)
		{
			UpdateTrace[client] = gameTime + 3.0;
			
			int length = GardenList.Length;
			for(int i; i < length; i++)
			{
				static GardenEnum garden;
				GardenList.GetArray(i, garden);
				if(StrEqual(garden.Zone, InGarden[client], false))
				{
					// Do TR Stuff Plz
				}
			}
		}
	}
}

static void ShowMenu(int client)
{
	static GardenEnum garden;
	GardenList.GetArray(index, garden);
	
	static char index[16], buffer[64];
	if(garden.ReadyIn[client])
	{
	}
	else
	{
		Menu menu = new Menu(Garden_PlantHandle);
		
		menu.SetTitle("RPG Fortress\n \nGarden:");
		
		int amount;
		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			KeyValues kv = TextStore_GetItemKv(i);
			if(kv)
			{
				kv.GetString("seed_result", buffer, sizeof(buffer));
				if(buffer[0])
				{
					TextStore_GetInv(client, i, amount);
					if(amount > 0)
					{
						IntToString(i, index, sizeof(index));
						TextStore_GetItemName(i, buffer, sizeof(buffer));
						Format(buffer, sizeof(buffer), "%s (%d)", buffer, amount);
						menu.AddItem(index, buffer);
					}
				}
			}
		}
		
		if(!menu.ItemCount)
			menu.AddItem(index, "No Seeds to Plant", ITEMDRAW_DISABLED);
		
		InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int Garden_PlantHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;
		}
		case MenuAction_Select:
		{
			InMenu[client] = false;
		}
	}
	return 0;
}