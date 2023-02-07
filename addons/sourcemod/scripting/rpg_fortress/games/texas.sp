#pragma semicolon 1
#pragma newdecls required

enum
{
	Texas_Waiting = 0,
	Texas_WarmUp,
	Texas_Active,
	Texas_Results
}

enum
{
	Texas_HighCard = 0,
	Texas_OnePair,
	Texas_TwoPair,
	Texas_ThreeKind,
	Texas_Straight,
	Texas_Flush,
	Texas_FullHouse,
	Texas_FourKind,
	Texas_StraightFlush
}

static const char RankNames[][] =
{
	"High Card",
	"One Pair",
	"Two Pair",
	"Three of a Kind",
	"Straight",
	"Flush",
	"Full House",
	"Four of a Kind",
	"Straight Flush"
};

static int BlindBet;
static int GameState;
static int PrizePool;
static int GameWinner;
static int CurrentBet;
static float TimeLeft;
static bool Viewing[MAXTF2PLAYERS];
static int BlindSince[MAXTF2PLAYERS];
static int Playing[MAXTF2PLAYERS];
static int Cards[MAXTF2PLAYERS][5];
static int Discarding[MAXTF2PLAYERS];
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

	int cash = TextStore_Cash(client);
	Menu menu = new Menu(TexasJoinMenu);

	if(found)
	{
		menu.SetTitle("Texas Hold 'Em\n \nRules:\nBlind: %d, %d Credits\nRaise Limit: x16\n ", BlindBet / 2, BlindBet);

		menu.AddItem(NULL_STRING, "How to Play");
		menu.AddItem(NULL_STRING, "View Table");
	}
	else
	{
		menu.SetTitle("Texas Hold 'Em\n ");

		menu.AddItem(NULL_STRING, "How to Play\n \nRules:");

		menu.AddItem(NULL_STRING, "5, 10 Credit Blind", cash < 500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "10, 20 Credit Blind", cash < 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "25, 50 Credit Blind", cash < 2500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "50, 100 Credit Blind", cash < 5000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "100, 200 Credit Blind", cash < 10000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "250, 500 Credit Blind", cash < 25000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "500, 1000 Credit Blind", cash < 50000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "1000, 2000 Credit Blind", cash < 100000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "2500, 5000 Credit Blind", cash < 250000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
							BlindBet = 20;
						
						case 2:
							BlindBet = 50;
						
						case 3:
							BlindBet = 100;
						
						case 4:
							BlindBet = 200;
						
						case 5:
							BlindBet = 500;
						
						case 6:
							BlindBet = 1000;
						
						case 7:
							BlindBet = 2000;
						
						case 8:
							BlindBet = 5000;
						
						default:
							BlindBet = 10;
					}
				}

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
					Playing[i] = 0;
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

			if(count < 2)
			{
				ResultPeriod();
			}
			else if(TimeLeft < gameTime)
			{
				RedrawPeriod();
			}
		}
		case Texas_Results:
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
			TexasMenu(client);
	}
	return Plugin_Continue;
}

static void TexasMenu(int client)
{
	Menu menu = new Menu(TexasTableMenu);

	switch(GameState)
	{
		case Poker_Waiting:
		{
			menu.SetTitle("Texas Hold 'Em\nWaiting for players%s\n ", FancyPeriodThing());

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
				FormatEx(buffer, sizeof(buffer), "Join Game (%d Blind)\n ", BlindBet);
				menu.AddItem(buffer, buffer, TextStore_Cash(client) < (BlindBet * 16) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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
					menu.SetTitle("Draw Poker\n%s... %.0f\n ", RankNames[GetCardRank(Cards[client])], TimeLeft - GetGameTime());

					for(int i; i < sizeof(Cards[]); i++)
					{
						menu.AddItem(buffer, Games_GetCardIcon(Cards[client][i]), ITEMDRAW_DISABLED);
					}
				}

				menu.AddItem(buffer, buffer, ITEMDRAW_SPACER);

				bool allIn;
				if(!MinBet)
				{
					menu.AddItem(buffer, "Free Game ($0)", ITEMDRAW_DISABLED);
				}
				else if(Playing[client] < CurrentBet)
				{
					FormatEx(buffer, sizeof(buffer), "Match New Bet and Keep Playing? ($%d -> $%d)\n ", Playing[client], CurrentBet);
					menu.AddItem(buffer, buffer);
				}
				else if(CurrentBet >= (MinBet * 8))
				{
					FormatEx(buffer, sizeof(buffer), "All In ($%d)\n ", CurrentBet);
					menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
					allIn = true;
				}
				else if(CurrentBet >= (MinBet * 4))
				{
					FormatEx(buffer, sizeof(buffer), "All In ($%d -> $%d)\n ", CurrentBet, CurrentBet * 2);
					menu.AddItem(buffer, buffer);
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "Double Bet ($%d -> $%d)\n ", CurrentBet, CurrentBet * 2);
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
				int rank = GetCardRank(Cards[GameWinner]);
				
				menu.SetTitle("Draw Poker\n%s won the game\n%s\n%s %s %s %s %s\n ", buffer, RankNames[rank],
					Games_GetCardIcon(Cards[GameWinner][0]), 
					Games_GetCardIcon(Cards[GameWinner][1]), 
					Games_GetCardIcon(Cards[GameWinner][2]), 
					Games_GetCardIcon(Cards[GameWinner][3]), 
					Games_GetCardIcon(Cards[GameWinner][4]));
			}
			else
			{
				menu.SetTitle("Draw Poker\n%s won the game\nLast Man\n ");
			}

			if(GameWinner == client)
			{
				FormatEx(buffer, sizeof(buffer), "You won %d credits", PrizePool);
			}
			else
			{
				menu.AddItem(buffer, "Your Hand:", ITEMDRAW_DISABLED);

				if(Playing[client])
				{
					int rank = GetCardRank(Cards[client]);
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
				case Poker_WarmUp:
				{
					if(Playing[client])
					{
						Playing[client] = 0;
						TriggerTimer(PokerTimer);
					}
					else if(TextStore_Cash(client) >= (MinBet * 8))
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
								if(TextStore_Cash(client) >= cost)
								{
									PrizePool += cost;
									TextStore_Cash(client, -cost);
									Playing[client] = CurrentBet;
									ClientCommand(client, "playgamesound %s", SOUND_MATCH);
								}
							}
							else if(TextStore_Cash(client) >= CurrentBet)
							{
								PrizePool += CurrentBet;
								TextStore_Cash(client, -CurrentBet);

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
			if(TextStore_Cash(client) < MinBet)
			{
				Playing[client] = 0;
			}
			else
			{
				ClientCommand(client, "playgamesound %s", SOUND_START);
				
				TextStore_Cash(client, -MinBet);
				PrizePool += MinBet;

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
						int index = GetURandomInt() % CurrentDeck.Length;
						Cards[client][i] = CurrentDeck.Get(index);
						CurrentDeck.Erase(index);
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
			TextStore_AddItemCount(winners[index], ITEM_CASH, PrizePool);

		for(int client = 1; client <= MaxClients; client++)
		{
			if(client != winners[index] && Playing[client])
				ClientCommand(client, "playgamesound %s", SOUND_LOST);
		}
	}
}

static int GetCardRank(const int card[5])
{
	int count[sizeof(card) - 1];

	bool straight = true;
	bool flush = true;

	for(int i; i < sizeof(card); i++)
	{
		if(i && flush)
		{
			// Check for suits
			if((card[0] / 100) != (card[i] / 100))
				flush = false;
		}

		int number = card[i] % 100;
		if(i != (sizeof(card) - 1))
		{
			bool foundUp, foundDown;
			for(int a = (i + i); a < sizeof(card); a++)
			{
				int num = card[a] % 100;
				if(number == num)	// Found the same number
				{
					foundUp = false;
					foundDown = false;
					break;
				}

				if(number == (num - 1))
				{
					if(foundUp)	// Found the same number
					{
						foundUp = false;
						foundDown = false;
						break;
					}

					foundUp = true;
				}

				if(number == (num + 1))
				{
					if(foundDown)	// Found the same number
					{
						foundUp = false;
						foundDown = false;
						break;
					}

					foundDown = true;
				}
			}

			if(!foundUp && !foundDown)
				straight = false;
		}

		if(i)
		{
			for(int a; a < i; a++)
			{
				if(number == card[a] % 100)
				{
					count[a]++;
					break;
				}
			}
		}
	}

	if(straight && flush)
		return Poker_StraightFlush;
	
	bool three;
	int two;
	for(int i; i < sizeof(count); i++)
	{
		if(count[i] == 3)
			return Poker_FourKind;
		
		if(count[i] == 2)
			three = true;
		
		if(count[i])
			two++;
	}

	if(three && two == 2)
		return Poker_FullHouse;

	if(flush)
		return Poker_Flush;

	if(straight)
		return Poker_Straight;

	if(three)
		return Poker_ThreeKind;

	if(two == 2)
		return Poker_TwoPair;

	if(two)
		return Poker_OnePair;
	
	return Poker_HighCard;
}