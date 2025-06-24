#pragma semicolon 1
#pragma newdecls required

static int Hands[MAXPLAYERS][2][12];
static int Dealer[MAXPLAYERS][12];
static int CurrentBet[MAXPLAYERS];
static ArrayList CurrentDeck[MAXPLAYERS];

void Games_Blackjack(int client, bool results = false)
{
	if(!Hands[client][0][0])
	{
		Menu menu = new Menu(BlackjackJoinMenu);

		menu.SetTitle("Blackjack\n \n");
		
		menu.AddItem(NULL_STRING, "How to Play\n \nRules:");
		
		int cash = TextStore_GetItemCount(client, ITEM_CHIP);

		menu.AddItem(NULL_STRING, "1 Chip Bet", cash < 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "5 Chip Bet", cash < 5 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "10 Chip Bet", cash < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "25 Chip Bet", cash < 25 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "50 Chip Bet", cash < 50 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "100 Chip Bet", cash < 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "250 Chip Bet", cash < 250 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "500 Chip Bet", cash < 500 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.Pagination = 0;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(!results)
	{
		Menu menu = new Menu(BlackjackTableMenu);

		char buffer[256];
		FormatEx(buffer, sizeof(buffer), "Blackjack\n \nDealer: %s\n \n", Games_GetCardIcon(Dealer[client][0]));
		
		bool firstTurn = true;
		for(int a; a < sizeof(Hands[]); a++)
		{
			if(!Hands[client][a][0])
				break;
			
			if(a)
				firstTurn = false;
			
			int soft, hard;
			for(int i; i < sizeof(Hands[][]); i++)
			{
				if(!Hands[client][a][i])
					break;
				
				Format(buffer, sizeof(buffer), "%s%s ", buffer, Games_GetCardIcon(Hands[client][a][i]));

				int value = Hands[client][a][i] % 100;
				if(value == Card_Ace)
				{
					soft += 11;
					hard += 1;
				}
				else if(value > 10)
				{
					soft += 10;
					hard += 10;
				}
				else
				{
					soft += value;
					hard += value;
				}

				if(i == 2)
					firstTurn = false;
			}
			
			while(hard != soft && soft > 21)
			{
				soft -= 10;
			}

			if(soft == hard)
			{
				Format(buffer, sizeof(buffer), "%s| %d\n", buffer, hard);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s| %d (%d)\n", buffer, hard, soft);
			}
		}

		menu.SetTitle("%s\n ", buffer);

		menu.AddItem(NULL_STRING, "Stand");
		menu.AddItem(NULL_STRING, "Hit");

		Format(buffer, sizeof(buffer), "Double Down (-¢%d)", CurrentBet[client]);
		menu.AddItem(NULL_STRING, buffer, (!firstTurn || TextStore_GetItemCount(client, ITEM_CHIP) < CurrentBet[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		Format(buffer, sizeof(buffer), "Split (-¢%d)", CurrentBet[client]);
		menu.AddItem(NULL_STRING, buffer, (!firstTurn || TextStore_GetItemCount(client, ITEM_CHIP) < CurrentBet[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		Format(buffer, sizeof(buffer), "Surrender (+¢%d)", CurrentBet[client] / 2);
		menu.AddItem(NULL_STRING, buffer, CurrentBet[client] < 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(BlackjackTableMenu);

		char buffer[256];
		FormatEx(buffer, sizeof(buffer), "Blackjack\n \nDealer: ");

		int soft, hard;
		for(int i; i < sizeof(Dealer[]); i++)
		{
			if(!Dealer[client][i])
				break;
			
			Format(buffer, sizeof(buffer), "%s%s ", buffer, Games_GetCardIcon(Dealer[client][i]));

			int value = Dealer[client][i] % 100;
			if(value == Card_Ace)
			{
				soft += 11;
				hard += 1;
			}
			else if(value > 10)
			{
				soft += 10;
				hard += 10;
			}
			else
			{
				soft += value;
				hard += value;
			}
		}
		
		while(hard != soft && soft > 21)
		{
			soft -= 10;
		}

		menu.SetTitle("%s| %d\n ", buffer, soft);

		for(int a; a < sizeof(Hands[]); a++)
		{
			if(!Hands[client][a][0])
				break;
			
			soft = 0;
			hard = 0;
			for(int i; i < sizeof(Hands[][]); i++)
			{
				if(!Hands[client][a][i])
					break;
				
				Format(buffer, sizeof(buffer), "%s%s ", buffer, Games_GetCardIcon(Hands[client][a][i]));

				int value = Hands[client][a][i] % 100;
				if(value == Card_Ace)
				{
					soft += 11;
					hard += 1;
				}
				else if(value > 10)
				{
					soft += 10;
					hard += 10;
				}
				else
				{
					soft += value;
					hard += value;
				}
			}
			
			while(hard != soft && soft > 21)
			{
				soft -= 10;
			}

			if(soft == hard)
			{
				Format(buffer, sizeof(buffer), "%s| %d\n", buffer, hard);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s| %d (%d)\n", buffer, hard, soft);
			}

			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int BlackjackJoinMenu(Menu menu, MenuAction action, int client, int choice)
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
				Games_Blackjack(client);
		}
		case MenuAction_Select:
		{
			if(choice)
			{
				switch(choice)
				{
					case 1:
						CurrentBet[client] = 1;
					
					case 2:
						CurrentBet[client] = 5;
					
					case 3:
						CurrentBet[client] = 10;
					
					case 4:
						CurrentBet[client] = 25;
					
					case 5:
						CurrentBet[client] = 50;
					
					case 6:
						CurrentBet[client] = 100;
					
					case 7:
						CurrentBet[client] = 250;
					
					case 8:
						CurrentBet[client] = 500;
					
					default:
						CurrentBet[client] = 0;
				}

				ResetToZero2(Hands[client], sizeof(Hands[]), sizeof(Hands[][]));
				ResetToZero(Dealer[client], sizeof(Dealer[]));

				delete CurrentDeck[client];
				CurrentDeck[client] = Games_GenerateNewDeck();

				for(int i; i < 2; i++)
				{
					Hands[client][0][i] = DrawNewCard(client);
					Dealer[client][i] = DrawNewCard(client);
				}

				ClientCommand(client, "playgamesound %s", SOUND_START);
				TextStore_AddItemCount(client, ITEM_CHIP, -CurrentBet[client]);

				Games_Blackjack(client);
			}
			else
			{
				Menu menu2 = new Menu(BlackjackJoinMenu);

				menu2.SetTitle("Blackjack\n ");

				menu2.AddItem(NULL_STRING, "You and the dealer draw two cards, with being able to see one dealer's card.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "You can choose to hit, stand, double down, split, or surrender.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Your goal is to get the highest combined value then the dealer without going over 21.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Jack, Queen, and King count as 10 while Ace count as 1 or 11.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "Hit will draw you a new card.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Stand will finish your turn and results will be revealed.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Double Down will double your bet and draw one new card before finishing your turn.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Split will double your bet, split your hand into two, and draw one for each hand.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "Surrender will end your turn and return half your current bet to you.", ITEMDRAW_DISABLED);

				menu2.AddItem(NULL_STRING, "When your turn finishes, the dealer will then play their turn.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "They will hit until they reach a 17 value.", ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_DISABLED);
				menu2.AddItem(NULL_STRING, "A starting hand of 21 will beat all and winning with it gives a bonus reward.", ITEMDRAW_DISABLED);

				menu2.Pagination = 5;
				menu2.ExitButton = true;
				menu2.ExitBackButton = true;
				menu2.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
	return 0;
}

public int BlackjackTableMenu(Menu menu, MenuAction action, int client, int choice)
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
				Games_Blackjack(client);
		}
		case MenuAction_Select:
		{
			bool results, hit, stand;
			switch(choice)
			{
				case 0:	// Stand
				{
					stand = true;
				}
				case 1:	// Hit
				{
					hit = true;
				}
				case 2:	// Double Down
				{
					if(TextStore_GetItemCount(client, ITEM_CHIP) >= CurrentBet[client])
					{
						hit = true;
						stand = true;

						TextStore_AddItemCount(client, ITEM_CHIP, -CurrentBet[client]);
						CurrentBet[client] *= 2;
					}
				}
				case 3:	// Split
				{
					if(TextStore_GetItemCount(client, ITEM_CHIP) >= CurrentBet[client])
					{
						ClientCommand(client, "playgamesound %s", SOUND_BET);

						TextStore_AddItemCount(client, ITEM_CHIP, -CurrentBet[client]);
						CurrentBet[client] *= 2;

						Hands[client][1][0] = Hands[client][0][1];
						Hands[client][0][1] = DrawNewCard(client);
						Hands[client][1][1] = DrawNewCard(client);
					}
				}
				case 4:	// Surrender
				{
					results = true;
					TextStore_AddItemCount(client, ITEM_CHIP, CurrentBet[client] / 2);
				}
			}

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

				int wins, hands;
				for(int a; a < sizeof(Hands[]); a++)
				{
					if(!Hands[client][a][0])
						break;
					
					hands++;
					if(hard > 21)
					{
						wins += 2;
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
										wins++;	// Tie
									}
									else
									{
										wins += 3;	// Blackjack
									}
								}
								else if(cards != 2)
								{
									wins++;	// Tie
								}
							}
							else
							{
								wins++;	// Tie
							}
						}
						else if(player > soft)
						{
							wins += 2;	// Win
						}
					}
				}

				if(wins)
				{
					win = wins > hands;
					TextStore_AddItemCount(client, ITEM_CHIP, CurrentBet[client] * wins / hands);
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
				ResetToZero(Dealer[client], sizeof(Dealer[]));
				delete CurrentDeck[client];
			}
		}
	}
	return 0;
}

static int DrawNewCard(int client)
{
	int index = GetURandomInt() % CurrentDeck[client].Length;
	int card = CurrentDeck[client].Get(index);
	CurrentDeck[client].Erase(index);
	return card;
}