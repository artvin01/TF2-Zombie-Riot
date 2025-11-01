#pragma semicolon 1
#pragma newdecls required

static bool AddedPoint[MAXPLAYERS];

void Queue_PutInServer(int client)
{
	if(Waves_InVote())
		return;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && !WaitingInQueue[i] && IsClientInGame(i) && GetClientTeam(i) > 1 && !IsFakeClient(i))
		{
			if(++count >= CalcMaxPlayers())
			{
				WaitingInQueue[client] = true;
				PrintToChat(client, "Server is full with a maximum of %d players", CalcMaxPlayers());
				PrintToChat(client, "You have been placed in spectator, if you like to join in when a slot is open, join a team. Otherwise you will join in next map change.");
				return;
			}
		}
	}
}

void Queue_AddPoint(int client)
{
	if(!AddedPoint[client] && Database_IsCached(client))
	{
		AddedPoint[client] = true;
		PlayStreak[client]++;
	}
}

void Queue_DifficultyVoteEnded()
{
	int count;
	int[] queue = new int[MaxClients];
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == 2 && !IsFakeClient(i))
			{
				queue[count++] = i;
			}
			else
			{
				WaitingInQueue[i] = true;	
				PlayStreak[i] = 0;
			}
		}
	}
	
	if(count > CalcMaxPlayers())
	{
		SortCustom1D(queue, count, Queue_Sorting);
		
		int i;
		for(; i<CalcMaxPlayers(); i++)
		{
			Queue_AddPoint(queue[i]);
		}
		
		for(; i<count; i++)
		{
			PlayStreak[queue[i]] = 0;
			WaitingInQueue[queue[i]] = true;
			PrintCenterText(queue[i], "Server is full with a maximum of %d players", CalcMaxPlayers());
			PrintToChat(queue[i], "Server is full with a maximum of %d players", CalcMaxPlayers());
			PrintToChat(queue[i], "You have been placed in spectator, if you like to join in when a slot is open, join a team. Otherwise you will join in next map change.");
			PrintToChat(queue[i], "This was done to give place to a player who was waiting in spectator the previous map.");
			ForcePlayerSuicide(queue[i]);
		}
	}
	else
	{
		for(int i; i<count; i++)
		{
			Queue_AddPoint(queue[i]);
		}
	}
}

public int Queue_Sorting(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(!Database_IsCached(elem1))
	{
		if(elem1 > elem2 && !Database_IsCached(elem2))
			return -1;
		
		return 1;
	}
	
	if(!Database_IsCached(elem2))
		return -1;
	
	if(PlayStreak[elem1] < PlayStreak[elem2])
		return -1;
	
	if(PlayStreak[elem1] > PlayStreak[elem2] || elem1 < elem2)
		return 1;
	
	return -1;
}

void Queue_Menu(int client)
{
	SetGlobalTransTarget(client);
	Menu menu = new Menu(Queue_MenuH);
	char buffer[128];

	FormatEx(buffer, sizeof(buffer), "%t", "Server is full, what would you like to do:");
	menu.SetTitle(buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Wait for the next map");
	menu.AddItem("", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Wait for an open slot");
	menu.AddItem("", buffer);

	CvarRerouteToIp.GetString(buffer, sizeof(buffer));
	if(buffer[0])
	{
		FormatEx(buffer, sizeof(buffer), "%t\n ", "Redirect to different ZR server");
		menu.AddItem("", buffer);
	}
	else
	{
		menu.AddItem("", buffer, ITEMDRAW_SPACER);
	}
	
	/*
	menu.AddItem("sm_encyclopedia", "Encyclopedia");
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "nominigames", false) == -1)
	{
		menu.AddItem("sm_idlemine", "Idle Miner");
		menu.AddItem("sm_tetris", "Tetris");
		menu.AddItem("sm_snake", "Snake");
		menu.AddItem("sm_solitaire", "Solitaire");
		menu.AddItem("sm_pong", "Pong");
		menu.AddItem("sm_connect4", "Connect4");
	}*/
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Queue_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			switch(choice)
			{
				case 0:
				{
					if(IsValidClient(client))
					{
						SetTeam(client, 1);
						Queue_Menu(client);
					}
				}
				case 1:
				{
					if(IsValidClient(client))
					{
						int count;
						for(int i=1; i<=MaxClients; i++)
						{
							if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
							{
								if(++count >= CalcMaxPlayers())
								{
									Queue_Menu(client);
									if(GetClientTeam(client) != 2)
									{
										SetTeam(client, view_as<int>(TFTeam_Red));
										ShowVGUIPanel(client, "class_red");
									}
									return 0;
								}
							}
						}
						
						SetTeam(client, view_as<int>(TFTeam_Red));
						if(IsPlayerAlive(client))
							ForcePlayerSuicide(client);
						
						WaitingInQueue[client] = false;
						PlayStreak[client] = 1;
					}
				}
				case 2:
				{
					if(IsValidClient(client))
					{
						char buffer[64];
						CvarRerouteToIp.GetString(buffer, sizeof(buffer));
						ClientCommand(client,"redirect %s",buffer);
					}
				}
				case 3:
				{
					c_WeaponUseAbilitiesHud[client][0] = 0;
					Items_EncyclopediaMenu(client);
				}
				default:
				{
					if(IsValidClient(client))
					{
						char buffer[16];
						menu.GetItem(choice, buffer, sizeof(buffer));
						FakeClientCommand(client, buffer);
					}
				}
			}
		}
	}
	return 0;
}

bool Queue_JoinTeam(int client)
{
	if(Waves_InVote() || (!WaitingInQueue[client] && GetClientTeam(client) == 2))
		return false;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i) && !WaitingInQueue[i])
		{
			if(++count >= CalcMaxPlayers())
			{
				WaitingInQueue[client] = true;
				SetTeam(client, 2);
				PrintCenterText(client, "Server is Full: You will now join when a slot is available");
				return false;
			}
		}
	}
	
	WaitingInQueue[client] = false;
	PlayStreak[client] = 1;
	return true;
}

void Queue_ClientDisconnect(int client)
{
	AddedPoint[client] = false;
	WaitingInQueue[client] = false;
	if(Waves_InVote())
		return;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i) && !WaitingInQueue[i])
		{
			if(++count >= CalcMaxPlayers())
				return;
		}
	}
	
	count = 0;
	int[] queue = new int[MaxClients];
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && WaitingInQueue[i] && IsClientInGame(i) && GetClientTeam(i) > 1 && !IsFakeClient(i))
			queue[count++] = i;
	}
	
	if(count)
	{
		int target = queue[GetRandomInt(0, count-1)];
		WaitingInQueue[target] = false;
		
		if(IsPlayerAlive(target))
			ForcePlayerSuicide(target);
		
		SetTeam(target, view_as<int>(TFTeam_Red));
		ShowVGUIPanel(target, "class_red");
		PlayStreak[client] = 1;
	}
}
