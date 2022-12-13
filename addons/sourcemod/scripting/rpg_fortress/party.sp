#pragma semicolon 1
#pragma newdecls required

static int PartyLeader[MAXTF2PLAYERS];

void Party_PluginStart()
{
	RegConsoleCmd("rpg_party", Party_Command, "Join or create a party");
	RegConsoleCmd("sm_party", Party_Command, "Join or create a party", FCVAR_HIDDEN);
}

void Party_ClientDisconnect(int client)
{

}

public Action Party_Command(int client, int args)
{
	if(client)
	{
	}
	return Plugin_Handled;
}

static void ShowMenu(int client)
{
	Menu menu = new Menu(Party_MenuHandle);
	menu.SetTitle("RPG Fortress\n \nParty:");

	static int index[16], buffer[96];
	if(PartyLeader[client])
	{
		menu.SetTitle("RPG Fortress\n \nParty:");

		for(int target = 1; target <= MaxClients; target++)
		{
			if(PartyLeader[client] == PartyLeader[target])
			{
				IntToString(GetClientUserId(target), index, sizeof(index));
				GetClientName(target, buffer, sizeof(buffer));
				Format(buffer, sizeof(buffer), "%s", buffer);
				menu.AddItem(index, buffer);
			}
		}
	}
	else
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(!PartyLeader[target] && IsClientInGame(target) && !IsClientMuted(target, client) && !IsClientMuted(client, target))
			{
				IntToString(GetClientUserId(target), index, sizeof(index));
				GetClientName(target, buffer, sizeof(buffer));
				Format(buffer, sizeof(buffer), "%s [Invite]", buffer);
				menu.AddItem(index, buffer);
			}
		}
	}

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Party_MenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_store");
		}
		case MenuAction_Select:
		{
			FakeClientCommandEx(client, "sm_store");
		}
	}
	return 0;
}