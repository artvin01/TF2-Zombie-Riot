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
static int CurrentBet;
static float TimeLeft;
static bool Viewing[MAXTF2PLAYERS];
static int Playing[MAXTF2PLAYERS];
static int Cards[MAXTF2PLAYERS][5];
static int Discarding[MAXTF2PLAYERS];
static ArrayList CurrentDeck;
static Handle PokerTimer;

void Games_Poker(int client)
{
	if(!PokerTable)
		PokerTable = new StringMap();
	
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

	int bet;
	if(found && PokerTable.GetValue(name, bet))
	{
		menu.SetTitle("Draw Poker\n \nRules:\nMin Bet: %d Credits\nRaise Limit: %s\nJokers: 0\n ", bet, bet ? "x10" : "x0");

		int cash = TextStore_Cash(client);

		menu.AddItem(name, "How to Play");
		menu.AddItem(name, "Join Table");
	}
	else
	{
		menu.SetTitle("Draw Poker\n ");

		menu.AddItem(name, "How to Play\n \nRules:");

		int cash = TextStore_Cash(client);

		menu.AddItem(name, "0 Credit Bet");
		menu.AddItem(name, "10 Credit Bet", cash < 500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "25 Credit Bet", cash < 1250 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "50 Credit Bet", cash < 2500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "100 Credit Bet", cash < 5000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "250 Credit Bet", cash < 12500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "500 Credit Bet", cash < 25000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(name, "1000 Credit Bet", cash < 50000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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

				int bet;
				if(!found || !PokerTable.GetValue(name, bet))
				{
					switch(choice)
					{
						case 1:
							bet = 10;
						
						case 2:
							bet = 25;
						
						case 3:
							bet = 50;
						
						case 4:
							bet = 100;
						
						case 5:
							bet = 250;
						
						case 6:
							bet = 500;
						
						case 7:
							bet = 1000;
						
						default:
							bet = 0;
					}

					PokerTable.SetValue(name, bet);
				}

				Viewing[client] = true;
				PokerMenu(client);

				if(!PokerTimer)
					PokerTimer = CreateTimer(0.5, Poker_Timer, _, TIMER_REPEAT);
			}
			else
			{
				Menu menu2 = new Menu(PokerJoinMenu);

				menu2.SetTitle("Draw Poker:\n ");

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
				menu2.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
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
				else if(TimeLeft < gameTime)
				{
					StartGame();
				}
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
				menu.SetTitle("Draw Poker\nGetting ready... %.0f\n ", FancyPeriodThing(), TimeLeft - GetGameTime());
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
				menu.AddItem(buffer, buffer, TextStore_Cash(client) < (MinBet * 10) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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
	}

	menu.ExitButton = Playing[client];
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
						Playing[client] = false;
						TriggerTimer();
					}
					else if(TextStore_Cash(client) >= MinBet)
					{
						Playing[client] = true;
					}
				}
			}

			PokerMenu(client);
		}
	}
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

	CurrentDeck = Games_GenerateNewDeck();
	for(int client = 1; client <= MaxClients; client++)
	{
		if(Playing[client])
		{
			// Normally, we would give out one at a time to each player
			// Counterpoint: We're in code baby
			for(int i; i < 5; i++)
			{
				int index = GetURandomInt() % CurrentDeck.Length;
				Cards[client][i] = CurrentDeck.Get(index);
				CurrentDeck.Erase(index);
			}
		}
	}

	TimeLeft = gameTime + 30.0;
	GameState = Poker_Discard;
}