#pragma semicolon 1
#pragma newdecls required

static Function EditorMenu[MAXTF2PLAYERS] = {INVALID_FUNCTION, ...};

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
			EditorMenu[client] = callback;
		
		return result;
	}
	public bool DisplayAt(int client, int first_item, Function callback)
	{
		bool result = view_as<Menu>(this).DisplayAt(client, first_item, MENU_TIME_FOREVER);
		if(result)
			EditorMenu[client] = callback;
		
		return result;
	}
}

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
		static bool holding[MAXTF2PLAYERS];
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
			}
		}
	}
	
	return 0;
}

void Editor_MainMenu(int client)
{
	EditMenu menu = new EditMenu();
	menu.SetTitle("RPG Fortress: Game Editor\nChat messages are overriden while this menu is up\nPress special attack to toggle noclip\n ");

	menu.AddItem("zones", "Zones");
	menu.AddItem("spawns", "Spawns");
	menu.AddItem("quests", "Quests");

	menu.Display(client, MainMenuHandler);
}

static void MainMenuHandler(int client, const char[] buffer)
{
	if(StrContains(buffer, "zones") != -1)
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
}
