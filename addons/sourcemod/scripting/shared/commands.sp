#pragma semicolon 1
#pragma newdecls required

void Commands_PluginStart()
{
	AddCommandListener(OnAutoTeam, "autoteam");
	AddCommandListener(OnAutoTeam, "jointeam");
	AddCommandListener(OnBuildCmd, "build");
	AddCommandListener(OnDropItem, "dropitem");
	AddCommandListener(OnTaunt, "taunt");
	AddCommandListener(OnTaunt, "+taunt");
	AddCommandListener(OnSayCommand, "say");
	AddCommandListener(OnSayCommand, "say_team");

#if defined ZR
	AddCommandListener(Command_Voicemenu, "voicemenu");
#endif
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	char buffer[64];
	kv.GetSectionName(buffer, sizeof(buffer));
	if(StrEqual(buffer, "+inspect_server", false))
	{
		
#if defined ZR
		if(GetClientButtons(client) & IN_SCORE)
		{
			Store_OpenItemPage(client);
		}
		else if(!TF2_IsPlayerInCondition(client, TFCond_Slowed) && !TF2_IsPlayerInCondition(client, TFCond_Zoomed))
		{
			Store_SwapItems(client);
		}
#endif

#if defined RPG
		Store_OpenItemPage(client);
#endif

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action OnAutoTeam(int client, const char[] command, int args)
{
	if(client)
	{
		if(IsFakeClient(client))
		{
			ChangeClientTeam(client, view_as<int>(TFTeam_Blue));
		}
#if defined ZR
		else if(Queue_JoinTeam(client))
#else
		else
#endif
		{
			ChangeClientTeam(client, view_as<int>(TFTeam_Red));
			ShowVGUIPanel(client, "class_red");
		}
	}
	return Plugin_Handled;
}

public Action OnBuildCmd(int client, const char[] command, int args)
{
	if(client && GameRules_GetProp("m_bInWaitingForPlayers"))
		return Plugin_Handled;
		
	return Plugin_Continue;
}

public Action OnDropItem(int client, const char[] command, int args)
{
#if defined ZR
	Escape_DropItem(client);
#endif
	return Plugin_Handled;
}

public Action OnTaunt(int client, const char[] command, int args)
{
#if defined ZR
	if(dieingstate[client] != 0)
	{
		return Plugin_Handled;
	}
	
	Pets_OnTaunt(client);
#endif
	return Plugin_Continue;
}

public Action OnSayCommand(int client, const char[] command, int args)
{
#if defined ZR	// For now
	if(Store_SayCommand(client))
		return Plugin_Handled;
#endif
	
	return NPC_SayCommand(client, command);
}

#if defined ZR
public Action Command_Voicemenu(int client, const char[] command, int args)
{
	if(client && args == 2 && TeutonType[client] == TEUTON_NONE && IsPlayerAlive(client))
	{
		char arg[4];
		GetCmdArg(1, arg, sizeof(arg));
		if(arg[0] == '0')
		{
			GetCmdArg(2, arg, sizeof(arg));
			if(arg[0] == '0')
			{
				bool has_been_done = BuildingCustomCommand(client);
				if(has_been_done)
				{
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}
#endif