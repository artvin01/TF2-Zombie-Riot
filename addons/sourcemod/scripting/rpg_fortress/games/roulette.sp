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

static int LastNumber[MAXPLAYERS];
static int Option[MAXPLAYERS];
static int MenuType[MAXPLAYERS];

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

		int cash = TextStore_GetItemCount(client, ITEM_CHIP);
		menu.AddItem(NULL_STRING, "1 Chip Bet", cash < 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "10 Chip Bet", cash < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "100 Chip Bet", cash < 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem(NULL_STRING, "1000 Chip Bet\n ", cash < 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
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
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				MenuType[client] = Roulette_Main;
				RouletteMenu(client);
			}
		}
		case MenuAction_Select:
		{
			int cash;
			switch(choice)
			{
				case 0, 1:
					Option[client]++;
				
				case 2:
					Option[client]--;
				
				case 3:
					cash = 1;
				
				case 4:
					cash = 10;
				
				case 5:
					cash = 100;
				
				case 6:
					cash = 1000;
			}

			if(cash && TextStore_GetItemCount(client, ITEM_CHIP) >= cash)
			{
				LastNumber[client] = GetURandomInt() % 37;

				bool win;
				switch(MenuType[client])
				{
					case Roulette_EvenOdd:
					{
						if(LastNumber[client] && (LastNumber[client] % 2) == (Option[client] % 2))
							win = true;
					}
					case Roulette_Dozen:
					{
						switch(Option[client] % 3)
						{
							case 0:
								win = LastNumber[client] > 0 && LastNumber[client] < 13;
							
							case 1:
								win = LastNumber[client] > 12 && LastNumber[client] < 25;
							
							default:
								win = LastNumber[client] > 24;
						}

						if(win)
							cash *= 2;
					}
					case Roulette_HalfDozen:
					{
						switch(Option[client] % 6)
						{
							case 0:	// 0 - 6
								win = LastNumber[client] > 0 && LastNumber[client] < 7;
							
							case 1:	// 6 - 12
								win = LastNumber[client] > 6 && LastNumber[client] < 13;
							
							case 2:	// 13 - 18
								win = LastNumber[client] > 12 && LastNumber[client] < 19;
							
							case 3:	// 19 - 24
								win = LastNumber[client] > 18 && LastNumber[client] < 25;
							
							case 4:	// 25 - 30
								win = LastNumber[client] > 24 && LastNumber[client] < 31;
							
							default:	// 31 - 36
								win = LastNumber[client] > 30;
						}

						if(win)
							cash *= 5;
					}
					case Roulette_Number:
					{
						win = LastNumber[client] == (Option[client] % 37);
						if(win)
							cash *= 35;
					}
				}

				if(win)
				{
					TextStore_AddItemCount(client, ITEM_CHIP, cash);
					if(MenuType[client] == Roulette_Number)
					{
						ClientCommand(client, "playgamesound misc/achievement_earned.wav");
					}
					else
					{
						ClientCommand(client, "playgamesound ui/chime_rd_2base_pos.wav");
					}
				}
				else
				{
					TextStore_AddItemCount(client, ITEM_CHIP, -cash, true);
					SPrintToChat(client, "You lost %s x%d (%d)", ITEM_CHIP, cash, TextStore_GetItemCount(client, ITEM_CHIP));
					ClientCommand(client, "playgamesound ui/chime_rd_2base_neg.wav");
				}
			}

			RouletteMenu(client);
		}
	}
	return 0;
}