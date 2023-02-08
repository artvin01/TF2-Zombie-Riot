#pragma semicolon 1
#pragma newdecls required

enum
{
	Roulette_Main = 0,
	Roulette_EvenOdd,
	Roulette_Dozen,
	Roulette_HalfDozen,
	Roulette_Number
}

static const char RouletteName[][] =
{
	"How to Play\n ",
	"Even or Odd",
	"Dozen Bet",
	"Half Dozen Bet",
	"Single Number"
};

static int LastNumber[MAXTF2PLAYERS];
static int Credits[MAXTF2PLAYERS];
static int Option[MAXTF2PLAYERS];
static int MenuType[MAXTF2PLAYERS];

void Games_Roulette(int client)
{
	MenuType[client] = Roulette_Main;
	LastNumber[client] = GetURandomInt() % 37;
	RouletteMenu(client);
}

static void RouletteMenu(int client)
{
	if(MenuType[client] == Roulette_Main)
	{
		Menu menu = new Menu(RouletteJoinMenu);

		menu.SetTitle("Roulette\n \nLatest Number: %d\n ", LastNumber[client]);
		
		for(int i; i < sizeof(RouletteName); i++)
		{
			menu.AddItem(NULL_STRING, RouletteName[i]);
		}

		menu.Pagination = 0;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(RouletteTableMenu);

		menu.SetTitle("Roulette\n \nLatest Number: %d\n%s\n ", LastNumber[client], RouletteName[MenuType[client]]);
		
		switch(MenuType[client])
		{
			case Roulette_EvenOdd:
			{
				menu.AddItem(NULL_STRING, Option[client] % 2 ? "Odd" : "Even");
				menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
				menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
			}
			case Roulette_Dozen:
			{
				static const char names[][] = { "1 - 12", "13 - 24", "25 - 36" };
				menu.AddItem(NULL_STRING, names[Option[client] % sizeof(names)], ITEMDRAW_DISABLED);
				menu.AddItem(NULL_STRING, "Next");
				menu.AddItem(NULL_STRING, "Previous\n ");
			}
			case Roulette_HalfDozen:
			{
				static const char names[][] = { "1 - 6", "7 - 12", "13 - 18", "19 - 24", "25 - 30", "31 - 36" };
				menu.AddItem(NULL_STRING, names[Option[client] % sizeof(names)], ITEMDRAW_DISABLED);
				menu.AddItem(NULL_STRING, "Next");
				menu.AddItem(NULL_STRING, "Previous\n ");
			}
			case Roulette_Number:
			{
				char buffer[6];
				IntToString(Option[client] % 37, buffer, sizeof(buffer));
				menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
				menu.AddItem(NULL_STRING, "Next");
				menu.AddItem(NULL_STRING, "Previous\n ");
			}
		}

		int cash = TextStore_Cash(client);
		menu.AddItem(NULL_STRING, "10 Credits Bet", cash < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "50 Credits Bet", cash < 50 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "250 Credits Bet", cash < 250 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "1000 Credits Bet\n ", cash < 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int RouletteJoinMenu(Menu menu, MenuAction action, int client, int choice)
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
				RouletteMenu(client);
		}
		case MenuAction_Select:
		{
			if(choice)
			{
				MenuType[client] = choice;
				Option[client] = 0;
				RouletteMenu(client);
			}
			else
			{
				Menu menu2 = new Menu(RouletteJoinMenu);

				menu2.SetTitle("Roulette\n ");

				menu2.AddItem(NULL_STRING, "You can choose to bet for a random number between 0 and 36.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can bet on even/odd values, a specific range, or a single number.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Note that zero only wins if you bet on it directly a single number.", ITEMDRAW_DISABLED);

				menu2.Pagination = 5;
				menu2.ExitButton = true;
				menu2.ExitBackButton = true;
				menu2.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
	return 0;
}

public int RouletteTableMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			int bet;
			switch(choice)
			{
				case 0, 1:
					Option[client]++;
				
				case 2:
					Option[client]--;
				
				case 3:
					bet = 10;
				
				case 4:
					bet = 50;
				
				case 5:
					bet = 250;
				
				case 6:
					bet = 1000;
			}

			if(bet && TextStore_Cash(client) >= bet)
			{
				LastNumber[client] = GetURandomInt() % 37;

				if(win)
				{
					ClientCommand(client, "playgamesound %s", SOUND_WIN);
				}
				else
				{
					ClientCommand(client, "playgamesound %s", SOUND_LOST);
				}
			}

			RouletteMenu(client);

			bool win;
			if(hit)
			{
				results = true;
				for(int a; a < sizeof(Hands[]); a++)
				{
					if(!Hands[client][a][0])
						break;
					
					int hard;
					bool found;
					for(int i = 1; i < sizeof(Hands[][]); i++)
					{
						if(!Hands[client][a][i])
						{
							Hands[client][a][i] = DrawNewCard(client);
							found = true;
						}

						int value = Hands[client][a][i] % 100;
						if(value == Card_Ace)
						{
							hard += 1;
						}
						else if(value > 10)
						{
							hard += 10;
						}
						else
						{
							hard += value;
						}

						if(hard > 21 || found)
							break;
					}

					if(hard < 22)
						results = false;
				}
			}

			if(!results && stand)
			{
				results = true;

				int hard, soft, cards;
				for(; cards < sizeof(Dealer[]); cards++)
				{
					if(!Dealer[client][cards])
						break;

					int value = Dealer[client][cards] % 100;
					if(value == Card_Ace)
					{
						hard += 1;
						soft += 11;
					}
					else if(value > 10)
					{
						hard += 10;
						soft += 10;
					}
					else
					{
						hard += value;
						soft += value;
					}
				}

				while(hard < 17 && soft < 16 && cards < sizeof(Dealer[]))
				{
					Dealer[client][cards] = DrawNewCard(client);

					int value = Dealer[client][cards] % 100;
					if(value == Card_Ace)
					{
						hard += 1;
						soft += 11;
					}
					else if(value > 10)
					{
						hard += 10;
						soft += 10;
					}
					else
					{
						hard += value;
						soft += value;
					}

					while(hard != soft && soft > 21)
					{
						soft -= 10;
					}

					cards++;
				}

				int cash, hands;
				for(int a; a < sizeof(Hands[]); a++)
				{
					if(!Hands[client][a][0])
						break;
					
					hands++;
					if(hard > 21)
					{
						cash += 2;
					}
					else
					{
						int player, b;
						for(; b < sizeof(Hands[][]); b++)
						{
							if(!Hands[client][a][b])
								break;
							
							int value = Hands[client][a][b] % 100;
							if(value == Card_Ace)
							{
								player += 11;
							}
							else if(value > 10)
							{
								player += 10;
							}
							else
							{
								player += value;
							}
						}

						while(player > 21)
						{
							player -= 10;
						}

						if(player == soft)
						{
							if(player == 21)
							{
								// Blackjack Check
								if(b == 2)
								{
									if(cards == 2)
									{
										cash++;	// Tie
									}
									else
									{
										cash += 3;	// Blackjack
									}
								}
								else if(cards != 2)
								{
									cash++;	// Tie
								}
							}
							else
							{
								cash++;	// Tie
							}
						}
						else if(player > soft)
						{
							cash += 2;	// Win
						}
					}
				}

				if(cash)
				{
					win = cash > hands;
					TextStore_AddItemCount(client, ITEM_CASH, CurrentBet[client] * cash / hands);
				}
			}

			Games_Blackjack(client, results);

			if(results)
			{
				if(win)
				{
					ClientCommand(client, "playgamesound %s", SOUND_WIN);
				}
				else
				{
					ClientCommand(client, "playgamesound %s", SOUND_LOST);
				}

				ResetToZero2(Hands[client], sizeof(Hands[]), sizeof(Hands[][]));
				ResetToZero(Dealer[client], sizeof(Dealer));
				delete CurrentDeck[client];
			}
		}
	}
	return 0;
}