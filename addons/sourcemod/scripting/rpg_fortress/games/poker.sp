#pragma semicolon 1
#pragma newdecls required

// ♠️ ♣️ ♥️ ♦️

enum
{
	Poker_Waiting = 0,
	Poker_WarmUp,
	Poker_Discard,
	Poker_Final,
	Poker_Results
}

static int MinBet;
static int GameState;
static int PrizePool;
static int GameWinner;
static int CurrentBet;
static float TimeLeft;
static bool Viewing[MAXPLAYERS];
static int Playing[MAXPLAYERS];
static int Cards[MAXPLAYERS][5];
static int Discarding[MAXPLAYERS];
static ArrayList CurrentDeck;
static Handle PokerTimer;

void Games_Poker(int client)
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

	Menu menu = new Menu(PokerJoinMenu);

	if(found)
	{
		menu.SetTitle("Draw Poker\n \nRules:\nMin Bet: %d Chips\nRaise Limit: %s\nJokers: 0\n ", MinBet, MinBet ? "x8" : "x0");

		menu.AddItem(NULL_STRING, "How to Play");
		menu.AddItem(NULL_STRING, "View Table");
	}
	else
	{
		menu.SetTitle("Draw Poker\n ");

		menu.AddItem(NULL_STRING, "How to Play\n \nRules:");

		int cash = TextStore_GetItemCount(client, ITEM_CHIP);

		menu.AddItem(NULL_STRING, "0 Chip Bet");
		menu.AddItem(NULL_STRING, "1 Chip Bet", cash < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "5 Chip Bet", cash < 50 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "10 Chip Bet", cash < 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "25 Chip Bet", cash < 250 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "50 Chip Bet", cash < 500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "100 Chip Bet", cash < 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "250 Chip Bet", cash < 2500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "500 Chip Bet", cash < 5000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.Pagination = 0;
		menu.ExitButton = true;
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int PokerJoinMenu(Menu menu, MenuAction action, int client, int choice)
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
				Games_Poker(client);
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
							MinBet = 1;
						
						case 2:
							MinBet = 5;
						
						case 3:
							MinBet = 10;
						
						case 4:
							MinBet = 25;
						
						case 5:
							MinBet = 50;
						
						case 6:
							MinBet = 100;
						
						case 7:
							MinBet = 250;
						
						case 8:
							MinBet = 500;
						
						default:
							MinBet = 0;
					}
				}

				Viewing[client] = true;
				PokerMenu(client);

				if(!PokerTimer)
					PokerTimer = CreateTimer(0.5, Poker_Timer, _, TIMER_REPEAT);
			}
			else
			{
				Menu menu2 = new Menu(PokerJoinMenu);

				menu2.SetTitle("Draw Poker\n ");

				menu2.AddItem(NULL_STRING, "Each player draws 5 cards from the deck.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You will have the chance to discard cards you choose.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can also increase the bet, other players will have to match this bet.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Afterwards you draw to obtain 5 total cards in hand.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "One more chance to increase the bet is done.", ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "Your goal is to get matching cards.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "This means cards with the same number or letter.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can also get all matching suits or an ordered set of numbers.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "To win, you must best your oppenent's hand.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_DISABLED);

				// ♠️ ♣️ ♥️ ♦️
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

public Action Poker_Timer(Handle timer)
{
	int players;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Viewing[client])
			players++;
	}
	
	if(!players)
	{
		GameState = Poker_Waiting;
		PokerTimer = null;
		return Plugin_Stop;
	}

	float gameTime = GetGameTime();
	switch(GameState)
	{
		case Poker_Waiting:
		{
			if(players > 1)
			{
				TimeLeft = 0.0;
				GameState = Poker_WarmUp;

				for(int i = 1; i <= MaxClients; i++)
				{
					Playing[i] = 0;
				}
			}
		}
		case Poker_WarmUp:
		{
			if(players < 2)
			{
				GameState = Poker_Waiting;
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
					TimeLeft = gameTime + 15.0;
				}
				else if(count > 4 || TimeLeft < gameTime)
				{
					StartGame();
				}
			}
		}
		case Poker_Discard:
		{
			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(count < 2)
			{
				ResultPeriod();
			}
			else if(TimeLeft < gameTime)
			{
				RedrawPeriod();
			}
		}
		case Poker_Final:
		{
			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(count < 2 || TimeLeft < gameTime)
			{
				ResultPeriod();
			}
		}
		case Poker_Results:
		{
			if(TimeLeft < gameTime)
			{
				Zero(Playing);

				TimeLeft = 0.0;
				GameState = Poker_WarmUp;
			}
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(Viewing[client])
			PokerMenu(client);
	}
	return Plugin_Continue;
}

static void PokerMenu(int client)
{
	Menu menu = new Menu(PokerTableMenu);

	switch(GameState)
	{
		case Poker_Waiting:
		{
			menu.SetTitle("Draw Poker\nWaiting for players%s\n ", FancyPeriodThing());

			menu.AddItem(NULL_STRING, "Rejoin to change table rules", ITEMDRAW_DISABLED);
		}
		case Poker_WarmUp:
		{
			if(TimeLeft)
			{
				menu.SetTitle("Draw Poker\nGetting ready... %.0f\n ", TimeLeft - GetGameTime());
			}
			else
			{
				menu.SetTitle("Draw Poker\nGetting ready%s\n ", FancyPeriodThing());
			}

			char buffer[32];
			if(Playing[client])
			{
				menu.AddItem(buffer, "Leave Game\n ");
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "Join Game (%d Bet)\n ", MinBet);
				menu.AddItem(buffer, buffer, TextStore_GetItemCount(client, ITEM_CHIP) < (MinBet * 8) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}

			int count;
			for(int i = 1; i <= MaxClients; i++)
			{
				if(Playing[i])
					count++;
			}

			if(TimeLeft)
			{
				FormatEx(buffer, sizeof(buffer), "%d / 5 players in game", count);
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "%d / 2 players to start game", count);
			}

			menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}
		case Poker_Discard, Poker_Final:
		{
			char buffer[32];
			if(Playing[client])
			{
				if(GameState == Poker_Discard)
				{
					menu.SetTitle("Draw Poker\nChoose what to discard... %.0f\n ", TimeLeft - GetGameTime());

					for(int i; i < sizeof(Cards[]); i++)
					{
						if(Discarding[client] & (1 << i))
						{
							FormatEx(buffer, sizeof(buffer), "%s (Discarding)", Games_GetCardIcon(Cards[client][i]));
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "%s (Keeping)", Games_GetCardIcon(Cards[client][i]));
						}

						menu.AddItem(buffer, buffer);
					}
				}
				else
				{
					menu.SetTitle("Draw Poker\n%s... %.0f\n ", RankNames[Games_GetCardRank(Cards[client], sizeof(Cards[]))], TimeLeft - GetGameTime());

					for(int i; i < sizeof(Cards[]); i++)
					{
						menu.AddItem(buffer, Games_GetCardIcon(Cards[client][i]), ITEMDRAW_DISABLED);
					}
				}

				menu.AddItem(buffer, buffer, ITEMDRAW_SPACER);

				bool allIn;
				if(!MinBet)
				{
					menu.AddItem(buffer, "Free Game (¢0)", ITEMDRAW_DISABLED);
				}
				else if(Playing[client] < CurrentBet)
				{
					FormatEx(buffer, sizeof(buffer), "Match Bet and Keep Playing? (¢%d -> ¢%d)\n ", Playing[client], CurrentBet);
					menu.AddItem(buffer, buffer);
				}
				else if(CurrentBet >= (MinBet * 8))
				{
					FormatEx(buffer, sizeof(buffer), "All In (¢%d)\n ", CurrentBet);
					menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
					allIn = true;
				}
				else if(CurrentBet >= (MinBet * 4))
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
				menu.SetTitle("Draw Poker\nGame in progress%s\n ", FancyPeriodThing());

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
		case Poker_Results:
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
				int rank = Games_GetCardRank(Cards[GameWinner], sizeof(Cards[]));
				
				menu.SetTitle("Draw Poker\n%s won the game\n%s\n%s %s %s %s %s\n ", buffer, RankNames[rank],
					Games_GetCardIcon(Cards[GameWinner][0]), 
					Games_GetCardIcon(Cards[GameWinner][1]), 
					Games_GetCardIcon(Cards[GameWinner][2]), 
					Games_GetCardIcon(Cards[GameWinner][3]), 
					Games_GetCardIcon(Cards[GameWinner][4]));
			}
			else
			{
				menu.SetTitle("Draw Poker\n%s won the game\nLast Man\n ", buffer);
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
					int rank = Games_GetCardRank(Cards[client], sizeof(Cards[]));
					menu.AddItem(buffer, RankNames[rank], ITEMDRAW_DISABLED);

					FormatEx(buffer, sizeof(buffer), "%s %s %s %s %s",
						Games_GetCardIcon(Cards[client][0]), 
						Games_GetCardIcon(Cards[client][1]), 
						Games_GetCardIcon(Cards[client][2]), 
						Games_GetCardIcon(Cards[client][3]), 
						Games_GetCardIcon(Cards[client][4]));
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

public int PokerTableMenu(Menu menu, MenuAction action, int client, int choice)
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
				case Poker_WarmUp:
				{
					if(Playing[client])
					{
						Playing[client] = 0;
						TriggerTimer(PokerTimer);
					}
					else if(TextStore_GetItemCount(client, ITEM_CHIP) >= (MinBet * 8))
					{
						Playing[client] = MinBet;
						TriggerTimer(PokerTimer);
					}
				}
				case Poker_Discard, Poker_Final:
				{
					if(Playing[client])
					{
						if(choice < 5)
						{
							if(Discarding[client] & (1 << choice))
							{
								Discarding[client] &= ~(1 << choice);
							}
							else
							{
								Discarding[client] |= (1 << choice);
							}
						}
						else if(choice == 6 && CurrentBet)	// Bet
						{
							if(Playing[client] < CurrentBet)
							{
								int cost = CurrentBet - Playing[client];
								if(TextStore_GetItemCount(client, ITEM_CHIP) >= cost)
								{
									PrizePool += cost;
									TextStore_AddItemCount(client, ITEM_CHIP, -cost);
									Playing[client] = CurrentBet;
									ClientCommand(client, "playgamesound %s", SOUND_MATCH);
								}
							}
							else if(TextStore_GetItemCount(client, ITEM_CHIP) >= CurrentBet)
							{
								PrizePool += CurrentBet;
								TextStore_AddItemCount(client, ITEM_CHIP, -CurrentBet);

								CurrentBet *= 2;
								Playing[client] = CurrentBet;
								ClientCommand(client, "playgamesound %s", SOUND_MATCH);

								float time = GetGameTime() + 10.0;
								if(TimeLeft < time)
									TimeLeft = time;

								for(int i = 1; i <= MaxClients; i++)
								{
									if(i != client && Playing[i])
									{
										SPrintToChat(i, "%N doubled the current bet!", client);
										ClientCommand(i, "playgamesound %s", SOUND_BET);
										PokerMenu(i);
									}
								}
							}
						}
						else if(choice == 7)	// Fold
						{
							Playing[client] = 0;
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

			PokerMenu(client);
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
	Zero2(Cards);
	Zero(Discarding);
	PrizePool = 0;
	CurrentBet = MinBet;

	CurrentDeck = Games_GenerateNewDeck();
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			if(TextStore_GetItemCount(client, ITEM_CHIP) < MinBet)
			{
				Playing[client] = 0;
			}
			else
			{
				ClientCommand(client, "playgamesound %s", SOUND_START);
				
				TextStore_AddItemCount(client, ITEM_CHIP, -MinBet);
				PrizePool += MinBet;

				// Normally, we would give out one at a time to each player
				// Counterpoint: We're in code baby
				for(int i; i < 5; i++)
				{
					Cards[client][i] = DrawNewCard();
				}
			}
		}
	}

	TimeLeft = GetGameTime() + 30.0;
	GameState = Poker_Discard;
}

static void RedrawPeriod()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			if(Playing[client] < CurrentBet)
			{
				ClientCommand(client, "playgamesound %s", SOUND_LOST);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(Playing[i])
						SPrintToChat(i, "%N folded!", client);
				}
				
				Playing[client] = 0;
			}
			else
			{
				ClientCommand(client, "playgamesound %s", SOUND_EVENT);
				
				for(int i; i < 5; i++)
				{
					if(Discarding[client] & (1 << i))
					{
						Cards[client][i] = DrawNewCard();
					}
				}
			}
		}
	}

	TimeLeft = GetGameTime() + 10.0;
	GameState = Poker_Final;
}

static void ResultPeriod()
{
	int count, winrank;
	int[] winners = new int[MaxClients];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			if(Playing[client] < CurrentBet)
			{
				ClientCommand(client, "playgamesound %s", SOUND_LOST);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(Playing[i])
						SPrintToChat(i, "%N folded!", client);
				}
				
				Playing[client] = 0;
			}
			else
			{
				int rank = Games_GetCardRank(Cards[client], sizeof(Cards[]));
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
	}

	if(!count)
	{
		GameState = Poker_WarmUp;
		TimeLeft = 0.0;
	}
	else
	{
		GameState = Poker_Results;
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
		if(PrizePool)
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