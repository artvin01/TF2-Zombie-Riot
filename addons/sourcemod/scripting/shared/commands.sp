#pragma semicolon 1
#pragma newdecls required

#if defined ZR
float f_MedicCallIngore[MAXTF2PLAYERS];
bool b_HoldingInspectWeapon[MAXTF2PLAYERS];
#endif

void Commands_PluginStart()
{
	AddCommandListener(OnNavCommand);
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
		b_HoldingInspectWeapon[client] = true;
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
		TextStore_Inspect(client);
#endif

		return Plugin_Handled;
	}
#if defined ZR
	else if(StrEqual(buffer, "-inspect_server", false))
	{
		b_HoldingInspectWeapon[client] = false;
	}
	//Medic E call, its really really delayed it is NOT the same as voicemenu 0 0, this is way faster.
	else if(StrEqual(buffer, "+helpme_server", false))
	{
		//add a delay, so if you call E it doesnt do the voice menu one, though keep the voice menu one for really epic cfg nerds.
		f_MedicCallIngore[client] = GetGameTime() + 1.0;
		bool has_been_done = BuildingCustomCommand(client);
		if(has_been_done)
		{
			return Plugin_Handled;
		}
	}
	
//	HINT: there is a - version, which is detected when letting go of the button, its basically a fancy onclientruncmd, although it shouldnt be used really.

	if(StrEqual(buffer, "+use_action_slot_item_server", false))
	{
		BuilderMenu(client);
		//This is an extra slot, incase you want to use it for anything.
	}
	
#endif
	return Plugin_Continue;
}

public Action OnNavCommand(int client, const char[] command, int args)
{
	if(!client && !StrContains(command, "nav", false))
	{
		PrintToServer("[ZR] Reloaded Nav Gamedata");
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
#if defined ZR
	if(client && (GameRules_GetProp("m_bInWaitingForPlayers") || !AllowBuildingCurrently()))
		return Plugin_Handled;
		
	return Plugin_Continue;
#else
	return Plugin_Handled;
#endif
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
	
#if defined ZR
	if(Store_SayCommand(client))
		return Plugin_Handled;
#endif
	
#if defined RPG
	if(TextStore_SayCommand(client))
		return Plugin_Handled;
	
	if(Tinker_SayCommand(client))
		return Plugin_Handled;
#endif

	return Plugin_Continue;
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
				if(f_MedicCallIngore[client] < GetGameTime())
				{
					bool has_been_done = BuildingCustomCommand(client);
					if(has_been_done)
					{
						return Plugin_Handled;
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
#endif