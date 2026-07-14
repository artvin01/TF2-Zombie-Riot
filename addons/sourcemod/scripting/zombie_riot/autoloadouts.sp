#pragma semicolon 1
#pragma newdecls required

enum
{
	AutoLoadoutType_Melee,
	AutoLoadoutType_Ranged,
	AutoLoadoutType_Mage,
	AutoLoadoutType_Kit,
}

enum struct AutoLoadout
{
	char name[64];
	int type;
	ArrayList itemList;
}

enum struct AutoLoadoutItem
{
	char name[64];
	int index;
	int level;
}

static ArrayList AutoLoadoutList;
static AutoLoadout ClientAutoLoadout[MAXPLAYERS + 1];

void AutoLoadouts_ConfigSetup()
{
	LoadTranslations("zombieriot.phrases.autoloadout");
	AutoLoadoutList = new ArrayList(sizeof(AutoLoadout));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "autoloadouts");
	KeyValues kv = new KeyValues("AutoLoadouts");
	kv.ImportFromFile(buffer);
	
	kv.GotoFirstSubKey();
	
	do
	{
		AutoLoadout loadout;
		if(kv.GetSectionName(loadout.name, sizeof(loadout.name)))
		{
			if (StrContains(loadout.name, "Melee", false) == 0)
			{
				loadout.type = AutoLoadoutType_Melee;
			}
			else if (StrContains(loadout.name, "Ranged", false) == 0)
			{
				loadout.type = AutoLoadoutType_Ranged;
			}
			else if (StrContains(loadout.name, "Mage", false) == 0)
			{
				loadout.type = AutoLoadoutType_Mage;
			}
			else if (StrContains(loadout.name, "Kit", false) == 0)
			{
				loadout.type = AutoLoadoutType_Kit;
			}
			else
			{
				LogError("Auto Loadout entry %s has an unknown type prefix!", loadout.name);
				continue;
			}
			
			loadout.itemList = new ArrayList(sizeof(AutoLoadoutItem));
			kv.GotoFirstSubKey();
			
			do
			{
				AutoLoadoutItem item;
				if(kv.GetSectionName(item.name, sizeof(item.name)))
				{
					item.level = kv.GetNum("level", 0);
					loadout.itemList.PushArray(item);
				}
				else
				{
					LogError("An item in the Auto Loadout entry %s could not be parsed!", loadout.name);
					continue;
				}
			} while(kv.GotoNextKey());
			
			kv.GoBack();
			
			AutoLoadoutList.PushArray(loadout);
		}
		else
		{
			LogError("An Auto Loadout entry could not be parsed!");
			continue;
		}
	} while(kv.GotoNextKey());
	
	delete kv;
	
	AutoLoadouts_MapNamesToData();
	
	RegConsoleCmd("sm_autoloadout", Command_AutoLoadout);
}

Action Command_AutoLoadout(int client, int args)
{
	AutoLoadouts_GiveRandomOfTypeToPlayer(client, GetCmdArgInt(1));
	return Plugin_Continue;
}

void AutoLoadouts_MapNamesToData()
{
	int mainLength = AutoLoadoutList.Length;
	for (int i = 0; i < mainLength; i++)
	{
		AutoLoadout loadout;
		AutoLoadoutList.GetArray(i, loadout);
		
		int subLength = loadout.itemList.Length;
		for (int j = 0; j < subLength; j++)
		{
			AutoLoadoutItem loadoutItem;
			loadout.itemList.GetArray(j, loadoutItem);
			loadoutItem.index = Store_GetItemIndexByName(loadoutItem.name);
			loadout.itemList.SetArray(j, loadoutItem);
		}
		
		AutoLoadoutList.SetArray(i, loadout);
	}
}

bool AutoLoadouts_SpecificNameToPlayer(int client, char Name[64])
{
	int length = AutoLoadoutList.Length;
	if (length == 0)
		return false;
	
	AutoLoadout loadout;
	for (int i = 0; i < length; i++)
	{
		AutoLoadoutList.GetArray(i, loadout);
		if(StrEqual(loadout.name, Name, false))
		{
			AutoLoadouts_SetPlayerLoadout(client, i);
			if(ClientTutorialStep(client) == 2)
			{
				f_TutorialUpdateStep[client] = GetGameTime() + 10.0;
				SetClientTutorialStep(client, 3);
			}
			return true;
		}
	}
	
	return false;
}
bool AutoLoadouts_GiveRandomOfTypeToPlayer(int client, int type)
{
	int length = AutoLoadoutList.Length;
	if (length == 0)
		return false;
	
	ArrayList ids = new ArrayList();
	AutoLoadout loadout;
	for (int i = 0; i < length; i++)
	{
		AutoLoadoutList.GetArray(i, loadout);
		if (loadout.type == type)
			ids.Push(i);
	}
	
	length = ids.Length;
	if (length == 0)
	{
		delete ids;
		return false;
	}
	
	int id = ids.Get(GetURandomInt() % length);
	delete ids;
	
	AutoLoadouts_SetPlayerLoadout(client, id);
	
	return true;
}

void AutoLoadouts_SetPlayerLoadout(int client, int id)
{
	AutoLoadouts_RemovePlayerLoadout(client);
	
	AutoLoadout loadout;
	AutoLoadoutList.GetArray(id, loadout);
	strcopy(ClientAutoLoadout[client].name, sizeof(loadout.name), loadout.name);
	
	ClientAutoLoadout[client].type = loadout.type;
	ClientAutoLoadout[client].itemList = loadout.itemList.Clone();
}

void AutoLoadouts_RemovePlayerLoadout(int client)
{
	if (ClientAutoLoadout[client].itemList)
		delete ClientAutoLoadout[client].itemList;
}

bool AutoLoadouts_IsClientUsing(int client)
{
	return ClientAutoLoadout[client].itemList != null;
}

void AutoLoadouts_RemoveEnhancementsFromClientList(int client)
{
	// if we manually enhance a weapon or buy a different weapon, we should break the enhancement links
	if (!AutoLoadouts_IsClientUsing(client))
		return;
	
	int length = ClientAutoLoadout[client].itemList.Length;
	for (int i = length - 1; i >= 0; i--)
	{
		AutoLoadoutItem item;
		ClientAutoLoadout[client].itemList.GetArray(i, item);
		if (item.level > 0)
			ClientAutoLoadout[client].itemList.Erase(i);
	}
}

void AutoLoadouts_Handle()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsValidClient(client) || !AutoLoadouts_IsClientUsing(client))
			continue;
		
		AutoLoadoutItem item;
		ClientAutoLoadout[client].itemList.GetArray(0, item);
		
		bool couldAfford;
		if (item.level == 0)
		{
			if (Store_TryToBuyItem(client, item.index))
			{
				SPrintToChat(client, "%t %s", "Autoloadout Bought Item", item.name);
				couldAfford = true;
			}
		}
		else
		{
			Item storeItem;
			Store_GetItemByIndex(item.index, storeItem);
			if (Store_TryToPapWeapon(client, storeItem, item.index, item.level))
			{
				SPrintToChat(client, "%t %s", "Autoloadout Enhance Item", item.name);
				couldAfford = true;
			}
		}
		
		if (couldAfford)
			ClientAutoLoadout[client].itemList.Erase(0);
		
		// Likely can't afford the next item, leave the starter store if we're in it
		if (!couldAfford && StarterCashMode[client])
		{
			StarterCashMode[client] = false;
		}
			
		
		// We're done and don't need the auto loadout anymore
		if (ClientAutoLoadout[client].itemList.Length == 0)
			AutoLoadouts_RemovePlayerLoadout(client);
	}
}


void Autoloadout_DisplayCurrentAuto(int client, char[] buffer, int sizeofbuffer)
{
	Format(buffer, sizeofbuffer, "%s\n%T",buffer,  "Autoloadout Current Have", client);
	if(AutoLoadouts_IsClientUsing(client))
		Format(buffer, sizeofbuffer, "%s %T",buffer, ClientAutoLoadout[client].name, client);
	else
		Format(buffer, sizeofbuffer, "%s %T",buffer, "None", client);
	Format(buffer, sizeofbuffer, "%s \n ",buffer);
}

void AutoLoadouts_DisplayLoadouts(int client)
{
	char buffer[256];
	Menu menu2 = new Menu(AutoLoadouts_DisplayLoadouts_Page);
	
	Format(buffer, sizeof(buffer), "%T", "Autoloadout Select Header", client);
	Autoloadout_DisplayCurrentAuto(client, buffer, sizeof(buffer));
	menu2.SetTitle("%s", buffer, client);
	
	Format(buffer, sizeof(buffer), "%T", "Autoloadout Store Page", client);
	menu2.AddItem("-2", buffer);
	
	Format(buffer, sizeof(buffer), "%T \n ", "Autoloadout CancelLoadout", client);
	if (!AutoLoadouts_IsClientUsing(client))
		menu2.AddItem("-3", buffer, ITEMDRAW_DISABLED);
	else
		menu2.AddItem("-3", buffer, ITEMDRAW_DEFAULT);

	
	int mainLength = AutoLoadoutList.Length;
	for (int i = 0; i < mainLength; i++)
	{
		//Get all auto loadouts
		AutoLoadout loadout;
		AutoLoadoutList.GetArray(i, loadout);
		Format(buffer, sizeof(buffer), "%T", loadout.name, client);
		menu2.AddItem(loadout.name, buffer);
	}

	menu2.Display(client, MENU_TIME_FOREVER);
	AnyMenuOpen[client] = 2.0;
}


public int AutoLoadouts_DisplayLoadouts_Page(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Cancel:
		{
			delete menu;
			AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0.0;
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			if(!AutoLoadouts_SpecificNameToPlayer(client, buffer))
			{
				int id = StringToInt(buffer);
				switch(id)
				{
					case -2:
					{
						Store_Menu(client);
					}
					case -3:
					{
						AutoLoadouts_RemovePlayerLoadout(client);
						AutoLoadouts_DisplayLoadouts(client);
					}
				}
			}
		}

	}
	return 0;
}