#define MAX_PLAYER_COUNT	12

static bool AddedPoint[MAXTF2PLAYERS];

void Queue_PutInServer(int client)
{
	if(GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && !WaitingInQueue[i] && IsClientInGame(i) && GetClientTeam(i) > 1 && !IsFakeClient(i))
		{
			if(++count >= MAX_PLAYER_COUNT)
			{
				WaitingInQueue[client] = true;
				PrintToChat(client, "Server is full with a maximum of %d players", MAX_PLAYER_COUNT);
				PrintToChat(client, "You have been placed in spectator, if you like to join in when a slot is open, join a team. Otherwise you will join in next map change.");
				return;
			}
		}
	}
}

void Queue_AddPoint(int client)
{
	if(!AddedPoint[client] && AreClientCookiesCached(client))
	{
		char buffer[6];
		AddedPoint[client] = true;
		CookiePlayStreak.Get(client, buffer, sizeof(buffer));
		IntToString(StringToInt(buffer) + 1, buffer, sizeof(buffer));
		CookiePlayStreak.Set(client, buffer);
	}
}

void Queue_WaitingForPlayersEnd()
{
	int count;
	int[] queue = new int[MaxClients];
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == 2)
			{
				queue[count++] = i;
			}
			else
			{
				WaitingInQueue[i] = true;	
				CookiePlayStreak.Set(i, "0");
			}
		}
	}
	
	if(count > MAX_PLAYER_COUNT)
	{
		SortCustom1D(queue, count, Queue_Sorting);
		
		int i;
		for(; i<MAX_PLAYER_COUNT; i++)
		{
			Queue_AddPoint(queue[i]);
		}
		
		for(; i<count; i++)
		{
			if(AreClientCookiesCached(queue[i]))
				CookiePlayStreak.Set(queue[i], "0");
			
			WaitingInQueue[queue[i]] = true;
			PrintCenterText(queue[i], "Server is full with a maximum of %d players", MAX_PLAYER_COUNT);
			PrintToChat(queue[i], "Server is full with a maximum of %d players", MAX_PLAYER_COUNT);
			PrintToChat(queue[i], "You have been placed in spectator, if you like to join in when a slot is open, join a team. Otherwise you will join in next map change.");
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
	if(!AreClientCookiesCached(elem1))
	{
		if(elem1 > elem2 && !AreClientCookiesCached(elem2))
			return -1;
		
		return 1;
	}
	
	if(!AreClientCookiesCached(elem2))
		return -1;
	
	char buffer[6];
	
	CookiePlayStreak.Get(elem1, buffer, sizeof(buffer));
	int play1 = StringToInt(buffer);
	
	CookiePlayStreak.Get(elem2, buffer, sizeof(buffer));
	int play2 = StringToInt(buffer);
	
	if(play1 < play2)
		return -1;
	
	if(play1 > play2 || elem1 < elem2)
		return 1;
	
	return -1;
}

void Queue_Menu(int client)
{
	Menu menu = new Menu(Queue_MenuH);
	menu.SetTitle("Server is full, what would you like to do:");
	
	menu.AddItem("", "Wait for the next map");
	menu.AddItem("", "Wait for an open slot");
	
	if(CheckCommandAccess(client, "zr_joinanytime", ADMFLAG_RESERVATION, true))
	{
		menu.AddItem("1", "Reserve slot join");
	}
	else
	{
		menu.AddItem("0", " ", ITEMDRAW_SPACER);
	}
	
	menu.AddItem("sm_encyclopedia", "Encyclopedia");
	menu.AddItem("sm_idlemine", "Idle Miner");
	menu.AddItem("sm_tetris", "Tetris");
	menu.AddItem("sm_snake", "Snake");
	menu.AddItem("sm_solitaire", "Solitaire");
	menu.AddItem("sm_pong", "Pong");
	menu.AddItem("sm_connect4", "Connect4");
	
	menu.Pagination = false;
	menu.ExitButton = true;
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
					ChangeClientTeam(client, 1);
					Queue_Menu(client);
				}
				case 1:
				{
					
					int count;
					for(int i=1; i<=MaxClients; i++)
					{
						if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2)
						{
							if(++count >= MAX_PLAYER_COUNT)
							{
								Queue_Menu(client);
								if(GetClientTeam(client) != 2)
								{
									ChangeClientTeam(client, view_as<int>(TFTeam_Red));
									ShowVGUIPanel(client, "class_red");
								}
								return 0;
							}
						}
					}
					
					ChangeClientTeam(client, view_as<int>(TFTeam_Red));
					if(IsPlayerAlive(client))
						ForcePlayerSuicide(client);
					
					WaitingInQueue[client] = false;
					CookiePlayStreak.Set(client, "1");
				}
				case 2:
				{
					char buffer[16];
					menu.GetItem(choice, buffer, sizeof(buffer));
					if(StringToInt(buffer))
					{
						WaitingInQueue[client] = false;
						if(IsPlayerAlive(client))
							ForcePlayerSuicide(client);
						
						ChangeClientTeam(client, view_as<int>(TFTeam_Red));
						ShowVGUIPanel(client, "class_red");
						CookiePlayStreak.Set(client, "99");
					}
				}
				default:
				{
					char buffer[16];
					menu.GetItem(choice, buffer, sizeof(buffer));
					FakeClientCommand(client, buffer);
				}
			}
		}
	}
	return 0;
}

bool Queue_JoinTeam(int client)
{
	if(!WaitingInQueue[client] && GetClientTeam(client) == 2)
		return false;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && !WaitingInQueue[i])
		{
			if(++count >= MAX_PLAYER_COUNT)
			{
				WaitingInQueue[client] = true;
				ChangeClientTeam(client, 2);
				PrintCenterText(client, "Server is Full: You will now join when a slot is available");
				return false;
			}
		}
	}
	
	WaitingInQueue[client] = false;
	CookiePlayStreak.Set(client, "1");
	return true;
}

void Queue_ClientDisconnect(int client)
{
	AddedPoint[client] = false;
	WaitingInQueue[client] = false;
	if(GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	int count;
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && !WaitingInQueue[i])
		{
			if(++count >= MAX_PLAYER_COUNT)
				return;
		}
	}
	
	count = 0;
	int[] queue = new int[MaxClients];
	for(int i=1; i<=MaxClients; i++)
	{
		if(i != client && WaitingInQueue[i] && IsClientInGame(i) && GetClientTeam(i) > 1)
			queue[count++] = i;
	}
	
	if(count)
	{
		int target = queue[GetRandomInt(0, count-1)];
		WaitingInQueue[target] = false;
		
		if(IsPlayerAlive(target))
			ForcePlayerSuicide(target);
		
		ChangeClientTeam(target, view_as<int>(TFTeam_Red));
		ShowVGUIPanel(target, "class_red");
		CookiePlayStreak.Set(target, "1");
	}
}