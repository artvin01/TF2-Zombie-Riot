#pragma semicolon 1
#pragma newdecls required

enum
{
	Texas_Waiting = 0,
	Texas_WarmUp,
	Texas_Active,
	Texas_Results
}

static int BlindBet;
static int GameState;
static int PrizePool;
static int GameWinner;
static int CurrentBet;
static float TimeLeft;
static int GlobalHand[5];
static bool Viewing[MAXPLAYERS];
static int BlindSince[MAXPLAYERS];
static bool Playing[MAXPLAYERS];
static int PlayerBet[MAXPLAYERS];
static int Cards[MAXPLAYERS][2];
static ArrayList CurrentDeck;
static Handle TexasTimer;

void Games_Texas(int client)
{
	bool found;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(Viewing[i])
		{
			found = true;
			break;
		}
	}

	int cash = TextStore_GetItemCount(client, ITEM_CHIP);
	Menu menu = new Menu(TexasJoinMenu);

	if(found)
	{
		menu.SetTitle("Texas Hold 'Em\n \nRules:\nBlind: %d, %d Chips\nRaise Limit: x16\n ", BlindBet / 2, BlindBet);

		menu.AddItem(NULL_STRING, "How to Play");
		menu.AddItem(NULL_STRING, "View Table");
	}
	else
	{
		menu.SetTitle("Texas Hold 'Em\n ");

		menu.AddItem(NULL_STRING, "How to Play\n \nRules:");

		menu.AddItem(NULL_STRING, "1, 2 Chip Blind", cash < 40 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "2, 4 Chip Blind", cash < 80 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "5, 10 Chip Blind", cash < 200 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "10, 20 Chip Blind", cash < 400 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "25, 50 Chip Blind", cash < 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "50, 100 Chip Blind", cash < 2000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "100, 200 Chip Blind", cash < 4000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "250, 500 Chip Blind", cash < 10000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "500, 1000 Chip Blind", cash < 20000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.Pagination = 0;
		menu.ExitButton = true;
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int TexasJoinMenu(Menu menu, MenuAction action, int client, int choice)
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
				Games_Texas(client);
		}
		case MenuAction_Select:
		{
			if(choice)
			{
				bool found;
				for(int i = 1; i <= MaxClients; i++)
				{
					if(Viewing[i])
					{
						found = true;
						break;
					}
				}

				if(!found)
				{
					switch(choice)
					{
						case 1:
							BlindBet = 4;
						
						case 2:
							BlindBet = 10;
						
						case 3:
							BlindBet = 20;
						
						case 4:
							BlindBet = 50;
						
						case 5:
							BlindBet = 100;
						
						case 6:
							BlindBet = 200;
						
						case 7:
							BlindBet = 500;
						
						case 8:
							BlindBet = 1000;
						
						default:
							BlindBet = 2;
					}
				}

				BlindSince[client] = 99;
				Viewing[client] = true;
				TexasMenu(client);

				if(!TexasTimer)
					TexasTimer = CreateTimer(0.5, Texas_Timer, _, TIMER_REPEAT);
			}
			else
			{
				Menu menu2 = new Menu(TexasJoinMenu);

				menu2.SetTitle("Texas Hold Em'\n ");

				menu2.AddItem(NULL_STRING, "Each player draws 2 cards from the deck.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "2 players will be will pay a blind and half a blind.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can choose to match the starting blind or in a blind to play.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Dealer will draw 3 cards, up to 5, in a global hand you share with.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can increase the bet, other players will have to match this bet.", ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "Your goal is to get matching cards with your hand annd the global hand.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "This means cards with the same number or letter.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can also get all matching suits or an ordered set of numbers.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "To win, you must best your oppenent's hand.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "The following are the highest hands in order:", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Straight Flush - Q♥️ J♥️ 10♥️ 9♥️ 8♥️", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Four of a Kind - 9♠️ 9♣️ 9♥️ 9♦️ ?", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Full House - A♥️ A♣️ A♦️ 3♠️ 3♥️", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Flush - K♣️ 10♣️ 8♣️ 7♣️ 5♣️", ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "Straight - 10♥️ 9♣️ 8♦️ 7♠️ 6♥️", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Three of a Kind - 7♥️ 7♦️ 7♣️ ? ?", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Two Pair - J♥️ J♣️ 5♦️ 5♠️ ?", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Pair - A♣️ A♥️ ? ? ?", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "High Card - K♦️ ? ? ? ?", ITEMDRAW_DISABLED);

				menu2.Pagination = 5;
				menu2.ExitButton = true;
				menu2.ExitBackButton = true;
				menu2.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
	return 0;
}

public Action Texas_Timer(Handle timer)
{
	int players;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Viewing[client])
			players++;
	}
	
	if(!players)
	{
		GameState = Texas_Waiting;
		TexasTimer = null;
		return Plugin_Stop;
	}

	float gameTime = GetGameTime();
	switch(GameState)
	{
		case Texas_Waiting:
		{
			if(players > 1)
			{
				TimeLeft = 0.0;
				GameState = Texas_WarmUp;

				for(int i = 1; i <= MaxClients; i++)
				{
					Playing[i] = false;
					PlayerBet[i] = 0;
				}
			}
		}
		case Texas_WarmUp:
		{
			if(players < 2)
			{
				GameState = Texas_Waiting;
			}
			else
			{
				int count;
				for(int i = 1; i <= MaxClients; i++)
				{
					if(Playing[i])
						count++;
				}

				if(count < 2)
				{
					TimeLeft = 0.0;
				}
				else if(!TimeLeft)
				{
					TimeLeft = gameTime + 20.0;
				}
				else if(count > 19 || TimeLeft < gameTime)
				{
					StartGame();
				}
			}
		}
		case Texas_Active:
		{
			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(count < 2 || TimeLeft < gameTime)
				NextPeriod();
		}
		case Texas_Results:
		{
			if(TimeLeft < gameTime)
			{
				Zero(Playing);

				TimeLeft = 0.0;
				GameState = Texas_WarmUp;
			}
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(Viewing[client])
			TexasMenu(client);
	}
	return Plugin_Continue;
}

static void TexasMenu(int client)
{
	Menu menu = new Menu(TexasTableMenu);

	switch(GameState)
	{
		case Texas_Waiting:
		{
			menu.SetTitle("Texas Hold 'Em\nWaiting for players%s\n ", FancyPeriodThing());

			menu.AddItem(NULL_STRING, "Rejoin to change table rules", ITEMDRAW_DISABLED);
		}
		case Texas_WarmUp:
		{
			if(TimeLeft)
			{
				menu.SetTitle("Texas Hold 'Em\nGetting ready... %.0f\n ", TimeLeft - GetGameTime());
			}
			else
			{
				menu.SetTitle("Texas Hold 'Em\nGetting ready%s\n ", FancyPeriodThing());
			}

			char buffer[32];
			if(Playing[client])
			{
				menu.AddItem(buffer, "Leave Game\n ");
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "Join Game (%d Blind)\n ", BlindBet);
				menu.AddItem(buffer, buffer, TextStore_GetItemCount(client, ITEM_CHIP) < (BlindBet * 16) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}

			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(TimeLeft)
			{
				FormatEx(buffer, sizeof(buffer), "%d / 20 players in game", count);
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "%d / 2 players to start game", count);
			}

			menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}
		case Texas_Active:
		{
			char buffer[32];
			if(Playing[client])
			{
				menu.SetTitle("Texas Hold 'Em\n%s... %.0f\n ", RankNames[GetCardRank(Cards[client])], TimeLeft - GetGameTime());

				for(int i; i < sizeof(GlobalHand); i++)
				{
					menu.AddItem(buffer, Games_GetCardIcon(GlobalHand[i]), ITEMDRAW_DISABLED);
				}

				for(int i; i < sizeof(Cards[]); i++)
				{
					menu.AddItem(buffer, Games_GetCardIcon(Cards[client][i]), ITEMDRAW_DISABLED);
				}

				menu.AddItem(buffer, buffer, ITEMDRAW_SPACER);

				bool allIn;
				if(PlayerBet[client] < CurrentBet)
				{
					FormatEx(buffer, sizeof(buffer), "Match Bet and Keep Playing? (¢%d -> ¢%d)\n ", Playing[client], CurrentBet);
					menu.AddItem(buffer, buffer);
				}
				else if(CurrentBet >= (BlindBet * 16))
				{
					FormatEx(buffer, sizeof(buffer), "All In (¢%d)\n ", CurrentBet);
					menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
					allIn = true;
				}
				else if(CurrentBet >= (BlindBet * 8))
				{
					FormatEx(buffer, sizeof(buffer), "All In (¢%d -> ¢%d)\n ", CurrentBet, CurrentBet * 2);
					menu.AddItem(buffer, buffer);
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "Double Bet (¢%d -> ¢%d)\n ", CurrentBet, CurrentBet * 2);
					menu.AddItem(buffer, buffer);
				}

				menu.AddItem(buffer, "Fold", allIn ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				menu.Pagination = 0;
			}
			else
			{
				menu.SetTitle("Texas Hold 'Em\nGame in progress%s\n ", FancyPeriodThing());

				int count;
				for(int i = 1; i <= MaxClients; i++)
				{
					if(Playing[i])
						count++;
				}

				FormatEx(buffer, sizeof(buffer), "%d players left", count);
				menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
			}
		}
		case Texas_Results:
		{
			char buffer[32];
			if(!IsClientInGame(GameWinner) || !GetClientName(GameWinner, buffer, sizeof(buffer)))
				strcopy(buffer, sizeof(buffer), "Disconnected");

			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(count > 1)
			{
				int rank = GetCardRank(Cards[GameWinner]);
				
				menu.SetTitle("Texas Hold 'Em\n%s won the game\n%s\n%s %s\n%s %s %s %s %s\n ", buffer, RankNames[rank],
					Games_GetCardIcon(Cards[GameWinner][0]), 
					Games_GetCardIcon(Cards[GameWinner][1]), 
					Games_GetCardIcon(GlobalHand[0]), 
					Games_GetCardIcon(GlobalHand[1]), 
					Games_GetCardIcon(GlobalHand[2]), 
					Games_GetCardIcon(GlobalHand[3]), 
					Games_GetCardIcon(GlobalHand[4]));
			}
			else
			{
				menu.SetTitle("Texas Hold 'Em\n%s won the game\nLast Man\n%s %s %s %s %s\n ", buffer,
					Games_GetCardIcon(GlobalHand[0]), 
					Games_GetCardIcon(GlobalHand[1]), 
					Games_GetCardIcon(GlobalHand[2]), 
					Games_GetCardIcon(GlobalHand[3]), 
					Games_GetCardIcon(GlobalHand[4]));
			}

			if(GameWinner == client)
			{
				FormatEx(buffer, sizeof(buffer), "You won %d chips", PrizePool);
			}
			else
			{
				menu.AddItem(buffer, "Your Hand:", ITEMDRAW_DISABLED);

				if(Playing[client])
				{
					int rank = GetCardRank(Cards[client]);
					menu.AddItem(buffer, RankNames[rank], ITEMDRAW_DISABLED);

					FormatEx(buffer, sizeof(buffer), "%s %s",
						Games_GetCardIcon(Cards[client][0]), 
						Games_GetCardIcon(Cards[client][1]));
				}
				else
				{
					buffer[0] = 0;
				}
			}

			menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}
	}

	menu.ExitButton = !Playing[client];
	Viewing[client] = menu.Display(client, 2);
}

public int TexasTableMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			Viewing[client] = false;
		}
		case MenuAction_Select:
		{
			switch(GameState)
			{
				case Texas_WarmUp:
				{
					if(Playing[client])
					{
						Playing[client] = false;
						TriggerTimer(TexasTimer);
					}
					else if(TextStore_GetItemCount(client, ITEM_CHIP) >= (BlindBet * 16))
					{
						Playing[client] = true;
						TriggerTimer(TexasTimer);
					}
				}
				case Texas_Active:
				{
					if(Playing[client])
					{
						if(choice == 8)	// Bet
						{
							if(PlayerBet[client] < CurrentBet)
							{
								int cost = CurrentBet - PlayerBet[client];
								if(TextStore_GetItemCount(client, ITEM_CHIP) >= cost)
								{
									PrizePool += cost;
									TextStore_AddItemCount(client, ITEM_CHIP, -cost);
									PlayerBet[client] = CurrentBet;
									ClientCommand(client, "playgamesound %s", SOUND_MATCH);
								}
							}
							else if(TextStore_GetItemCount(client, ITEM_CHIP) >= CurrentBet)
							{
								PrizePool += CurrentBet;
								TextStore_AddItemCount(client, ITEM_CHIP, -CurrentBet);

								CurrentBet *= 2;
								PlayerBet[client] = CurrentBet;
								ClientCommand(client, "playgamesound %s", SOUND_MATCH);

								float time = GetGameTime() + 10.0;
								if(TimeLeft < time)
									TimeLeft = time;

								for(int i = 1; i <= MaxClients; i++)
								{
									if(i != client && PlayerBet[i])
									{
										SPrintToChat(i, "%N doubled the current bet!", client);
										ClientCommand(i, "playgamesound %s", SOUND_BET);
										TexasMenu(i);
									}
								}
							}
						}
						else if(choice == 9)	// Fold
						{
							Playing[client] = false;
							ClientCommand(client, "playgamesound %s", SOUND_LOST);

							for(int i = 1; i <= MaxClients; i++)
							{
								if(i != client && Playing[i])
									SPrintToChat(i, "%N folded!", client);
							}
						}
					}
				}
			}

			TexasMenu(client);
		}
	}
	return 0;
}

static char[] FancyPeriodThing()
{
	char buffer[4];
	int amount = (RoundToCeil(GetGameTime()) % 3) + 1;
	for(int i; ; i++)
	{
		if(i < amount)
		{
			buffer[i] = '.';
		}
		else
		{
			buffer[i] = '\0';
			break;
		}
	}
	return buffer;
}

static void StartGame()
{
	delete CurrentDeck;
	Zero(GlobalHand);
	Zero2(Cards);
	PrizePool = 0;
	CurrentBet = BlindBet;

	CurrentDeck = Games_GenerateNewDeck();
	
	int low, high;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			if(TextStore_GetItemCount(client, ITEM_CHIP) < BlindBet)
			{
				Playing[client] = false;
			}
			else
			{
				BlindSince[client]++;
				PlayerBet[client] = 0;
				ClientCommand(client, "playgamesound %s", SOUND_START);
				
				// Normally, we would give out one at a time to each player
				// Counterpoint: We're in code baby
				for(int i; i < 2; i++)
				{
					Cards[client][i] = DrawNewCard();
				}

				if(!high)
				{
					high = client;
				}
				else if(!low)
				{
					low = client;
				}
				else if(BlindSince[client] > BlindSince[high])
				{
					high = client;
				}
				else if(BlindSince[client] < BlindSince[low])
				{
					low = client;
				}
			}
		}
	}

	if(high)
	{
		BlindSince[high] = 0;
		PlayerBet[high] = BlindBet;
		TextStore_Cash(high, -PlayerBet[high]);
		PrizePool += PlayerBet[high];
	}

	if(low)
	{
		PlayerBet[low] = BlindBet / 2;
		TextStore_Cash(low, -PlayerBet[low]);
		PrizePool += PlayerBet[low];
	}

	TimeLeft = GetGameTime() + 15.0;
	GameState = Texas_Active;
}
/*
public int Texas_BindSorting(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(BlindSince[elem1] > BlindSince[elem2])
		return -1;
	
	if(BlindSince[elem1] < BlindSince[elem2] || elem1 < elem2)
		return 1;
	
	return -1;
}
*/
static void NextPeriod()
{
	int players;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			if(PlayerBet[client] < CurrentBet)
			{
				ClientCommand(client, "playgamesound %s", SOUND_LOST);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(Playing[i])
						SPrintToChat(i, "%N folded!", client);
				}
				
				Playing[client] = false;
			}
			else
			{
				players++;
			}
		}
	}

	int cards;
	while(cards < sizeof(GlobalHand) && GlobalHand[cards])
	{
		cards++;
	}

	if(players < 2 || cards >= sizeof(GlobalHand))
	{
		ResultPeriod();
	}
	else
	{
		TimeLeft = GetGameTime() + 15.0;

		if(!cards)
		{
			for(int i; i < 3; i++)
			{
				GlobalHand[i] = DrawNewCard();
			}
		}
		else
		{
			GlobalHand[cards] = DrawNewCard();
		}

		for(int client = 1; client <= MaxClients; client++)
		{
			if(Playing[client])
				ClientCommand(client, "playgamesound %s", SOUND_EVENT);
		}
	}
}

static void ResultPeriod()
{
	int count, winrank;
	int[] winners = new int[MaxClients];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			int rank = GetCardRank(Cards[client]);
			if(rank > winrank)
			{
				winners[0] = client;
				count = 1;
				winrank = rank;
			}
			else if(winrank == rank)
			{
				winners[count++] = client;
			}
		}
	}

	if(!count)
	{
		GameState = Texas_WarmUp;
		TimeLeft = 0.0;
	}
	else
	{
		GameState = Texas_Results;
		TimeLeft = GetGameTime() + 10.0;

		int index;
		if(count > 1)
		{
			int high;
			for(int c; c < sizeof(Cards[]); c++)
			{
				for(int i; i < count; i++)
				{
					int card = Cards[winners[i]][c] % 100;
					if(card > high)
					{
						high = card;
						index = i;
					}
				}
			}
		}
		
		GameWinner = winners[index];
		ClientCommand(winners[index], "playgamesound %s", SOUND_WIN);
		TextStore_AddItemCount(winners[index], ITEM_CHIP, PrizePool);

		for(int client = 1; client <= MaxClients; client++)
		{
			if(client != winners[index] && Playing[client])
				ClientCommand(client, "playgamesound %s", SOUND_LOST);
		}
	}
}

static int DrawNewCard()
{
	int index = GetURandomInt() % CurrentDeck.Length;
	int card = CurrentDeck.Get(index);
	CurrentDeck.Erase(index);
	return card;
}

static int GetCardRank(const int card[2])
{
	int cards[sizeof(card) + sizeof(GlobalHand)];
	for(int i; i < sizeof(card); i++)
	{
		cards[i] = card[i];
	}

	int count = sizeof(card);
	for(int i; i < sizeof(GlobalHand); i++)
	{
		if(!GlobalHand[i])
			break;
		
		cards[i + sizeof(card)] = GlobalHand[i];
	}

	return Games_GetCardRank(cards, count);
}