#pragma semicolon 1
#pragma newdecls required

static Function EditorMenu[MAXPLAYERS] = {INVALID_FUNCTION, ...};

methodmap EditMenu < Menu
{
	public EditMenu(MenuAction actions = MENU_ACTIONS_DEFAULT)
	{
		return view_as<EditMenu>(new Menu(EditorMenuH, actions));
	}
	public bool Display(int client, Function callback)
	{
		bool result = view_as<Menu>(this).Display(client, MENU_TIME_FOREVER);
		if(result)
		{
			EditorMenu[client] = callback;
			if(CvarRPGInfiniteLevelAndAmmo.BoolValue)
				CvarDisableThink.BoolValue = true;
		}
		
		return result;
	}
	public bool DisplayAt(int client, int first_item, Function callback)
	{
		bool result = view_as<Menu>(this).DisplayAt(client, first_item, MENU_TIME_FOREVER);
		if(result)
		{
			EditorMenu[client] = callback;
			if(CvarRPGInfiniteLevelAndAmmo.BoolValue)
				CvarDisableThink.BoolValue = true;
		}
		
		return result;
	}
}

static int PickRange[MAXPLAYERS];

void Editor_PluginStart()
{
	RegAdminCmd("rpg_editor", Editor_Command, ADMFLAG_ROOT, "Enter editing mode");
}

bool Editor_SayCommand(int client)
{
	if(EditorMenu[client] == INVALID_FUNCTION)
		return false;
	
	char buffer[512];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");

	Function func = EditorMenu[client];

	Call_StartFunction(null, func);
	Call_PushCell(client);
	Call_PushString(buffer);
	Call_Finish();
	return true;
}

void Editor_PlayerRunCmd(int client, int buttons)
{
	if(EditorMenu[client] != INVALID_FUNCTION)
	{
		static bool holding[MAXPLAYERS];
		if(holding[client])
		{
			if(!(buttons & IN_ATTACK3))
				holding[client] = false;
		}
		else if(buttons & IN_ATTACK3)
		{
			holding[client] = true;
			SetEntityMoveType(client, GetEntityMoveType(client) == MOVETYPE_NOCLIP ? MOVETYPE_WALK : MOVETYPE_NOCLIP);
		}
	}
}

bool Editor_WithinRange(int client, const float pos[3])
{
	if(PickRange[client] == 0)
		return true;

	float pos2[3];
	GetClientEyePosition(client, pos2);
	return GetVectorDistance(pos, pos2) < PickRange[client];
}

Function Editor_MenuFunc(int client)
{
	return EditorMenu[client];
}

static Action Editor_Command(int client, int args)
{
	if(client)
	{
		Editor_MainMenu(client);
	}
	return Plugin_Handled;
}

static int EditorMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(EditorMenu[client] != INVALID_FUNCTION)
			{
				Function func = EditorMenu[client];
				EditorMenu[client] = INVALID_FUNCTION;

				if(choice == MenuCancel_ExitBack)
				{
					Call_StartFunction(null, func);
					Call_PushCell(client);
					Call_PushString("back");
					Call_Finish();
				}

				if(CvarRPGInfiniteLevelAndAmmo.BoolValue && EditorMenu[client] == INVALID_FUNCTION)
					CvarDisableThink.BoolValue = false;
			}
		}
		case MenuAction_Select:
		{
			if(EditorMenu[client] != INVALID_FUNCTION)
			{
				Function func = EditorMenu[client];
				EditorMenu[client] = INVALID_FUNCTION;

				char buffer[256];
				menu.GetItem(choice, buffer, sizeof(buffer));

				Call_StartFunction(null, func);
				Call_PushCell(client);
				Call_PushString(buffer);
				Call_Finish();

				if(CvarRPGInfiniteLevelAndAmmo.BoolValue && EditorMenu[client] == INVALID_FUNCTION)
					CvarDisableThink.BoolValue = false;
			}
		}
	}
	
	return 0;
}

void Editor_MainMenu(int client)
{
	EditMenu menu = new EditMenu();
	menu.SetTitle("RPG Fortress: Game Editor\nChat messages are overriden while this menu is up\nPress [T (spray)]/interact an object to pull up it's editor menu\nPress special attack to toggle noclip\n ");

	menu.AddItem("reloadrpg", "Reload RPG Fortress");
	menu.AddItem("reloadstore", "Reload Text Store");

	char buffer[64];
	if(PickRange[client] == 0)
	{
		FormatEx(buffer, sizeof(buffer), "Pick-From Range: All\n ");
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "Pick-From Range: %d HU\n ", PickRange[client]);
	}
	
	menu.AddItem("pickrange", buffer);

	menu.AddItem("zones", "Zones");
	menu.AddItem("spawns", "Spawns");
	menu.AddItem("actor", "Actors");
	menu.AddItem("quests", "Quests");
	menu.AddItem("garden", "Gardens");
	menu.AddItem("mining", "Mines");
	menu.AddItem("fishing", "Fishing");
	menu.AddItem("crafting", "Craft/Shop");
	menu.AddItem("worldtext", "Worldtext");

	menu.Display(client, MainMenuHandler);
}

static void MainMenuHandler(int client, const char[] buffer)
{
	if(StrContains(buffer, "reloadrpg") != -1)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i))
				ForcePlayerSuicide(i);
		}

		RequestFrame(ReloadPlugin);
	}
	else if(StrContains(buffer, "reloadstore") != -1)
	{
		ServerCommand("sm plugins reload textstore");
	}
	else if(StrContains(buffer, "pickrange") != -1)
	{
		switch(PickRange[client])
		{
			case 0:
				PickRange[client] = 5000;
			
			case 5000:
				PickRange[client] = 2000;
			
			case 2000:
				PickRange[client] = 1000;
			
			case 1000:
				PickRange[client] = 600;
			
			case 600:
				PickRange[client] = 300;
			
			default:
				PickRange[client] = 0;
		}

		Editor_MainMenu(client);
	}
	else if(StrContains(buffer, "zones") != -1)
	{
		Zones_EditorMenu(client);
	}
	else if(StrContains(buffer, "spawns") != -1)
	{
		Spawns_EditorMenu(client);
	}
	else if(StrContains(buffer, "quests") != -1)
	{
		Quests_EditorMenu(client);
	}
	else if(StrContains(buffer, "actor") != -1)
	{
		Actor_EditorMenu(client);
	}
	else if(StrContains(buffer, "garden") != -1)
	{
		Garden_EditorMenu(client);
	}
	else if(StrContains(buffer, "mining") != -1)
	{
		Mining_EditorMenu(client);
	}
	else if(StrContains(buffer, "fishing") != -1)
	{
		Fishing_EditorMenu(client);
	}
	else if(StrContains(buffer, "crafting") != -1)
	{
		Crafting_EditorMenu(client);
	}
	else if(StrContains(buffer, "worldtext") != -1)
	{
		Worldtext_EditorMenu(client);
	}
}

static void ReloadPlugin()
{
	char plugin[128];
	GetPluginFilename(null, plugin, sizeof(plugin));
	ServerCommand("sm plugins reload %s", plugin);
}
