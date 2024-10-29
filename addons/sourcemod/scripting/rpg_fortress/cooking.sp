#pragma semicolon 1
#pragma newdecls required

static const char FoodType[][] =
{
	"Meat",
	"Fruit",
	"Vegetable",
	"Grain",
	"Sauce",
	"Spice",
	"Liquid",
	"Sweet",
	"Seafood"
};

enum
{
	Food_Meat = 0,
	Food_Fruit = 1,
	Food_Vegi = 2,
	Food_Grain = 3,
	Food_Sauce = 4,
	Food_Spice = 5,
	Food_Liquid = 6,
	Food_Sweet = 7,
	Food_Seafood = 8,

	Food_MAX = 15
}

enum struct MealEnum
{
	int Store;
	char Item[48];

	int Uses;
	int Foods;
	float Bonuses[Food_MAX];
	char Required[48];
	int RequireAmount;
	int Level;
	int Extra;
	
	bool SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Item, 48);

		this.Uses = kv.GetNum("uses", 1);
		this.Foods = kv.GetNum("food", 1);
		kv.GetString("required", this.Required, 48);
		this.RequireAmount = kv.GetNum("requiredamount");
		this.Level = kv.GetNum("level");
		this.Extra = kv.GetNum("extra", -1);

		char num[4];
		for(int i; i < Food_MAX; i++)
		{
			IntToString(i, num, sizeof(num));
			this.Bonuses[i] = kv.GetFloat(num, 1.0);
		}

		return true;
	}
}

static StringMap LevelBalance;
static ArrayList MealList;
static int CurrentMeal[MAXTF2PLAYERS] = {-1, ...};
static int CurrentChoice[MAXTF2PLAYERS] = {-1, ...};
static int CurrentLevelBuff[MAXTF2PLAYERS];
static int CurrentFood[MAXTF2PLAYERS][16];

void Cooking_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "cooking");
	KeyValues kv = new KeyValues("Cooking");
	kv.ImportFromFile(buffer);
	
	delete LevelBalance;
	
	if(kv.JumpToKey("LevelAdjust"))
	{
		LevelBalance = new StringMap();

		char buffer2[16];
		kv.GotoFirstSubKey(false);
		do
		{
			kv.GetSectionName(buffer2, sizeof(buffer2));
			LevelBalance.SetValue(buffer2, kv.GetFloat(NULL_STRING));
		}
		while(kv.GotoNextKey(false));
	}

	delete kv;
}

void Cooking_StoreCached()
{
	delete MealList;
	MealList = new ArrayList(sizeof(MealEnum));

	MealEnum meal;

	char buffer[64];
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv)
		{
			kv.GetString("plugin", buffer, sizeof(buffer));
			if(StrEqual(buffer, "rpg_fortress"))
			{
				kv.GetString("type", buffer, sizeof(buffer));
				if(!StrContains(buffer, "healing", false) || !StrContains(buffer, "spell", false))
				{
					if(KvGetFunction(kv, "func") == Cooking_UseFunction)
					{
						if(meal.SetupEnum(kv))
						{
							meal.Store = i;
							MealList.PushArray(meal);
						}
					}
				}
			}
		}
	}
}

public float Cooking_UseFunction(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		return GetGameTime() + 5.0;
	}
	return FAR_FUTURE;
}

void Cooking_OpenMenu(int client)
{
	CookingMenu(client);
}

static void CookingMenu(int client)
{
	MealEnum meal;
	char num[16], buffer[64];

	if(CurrentChoice[client] != -1)
	{
		MealList.GetArray(CurrentMeal[client], meal);

		Menu menu = new Menu(SelectFood);
		menu.SetTitle("RPG Fortress\n \nCooking: %s\n ", CurrentMeal[client]);

		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			KeyValues kv = TextStore_GetItemKv(i);
			if(kv)
			{
				int type = kv.GetNum("foodtype", -1);
				if(CurrentChoice[client] == meals.Foods)
				{
					if(meal.Extra != type)
						continue;
				}
				else if(type < 0 || (type < Food_MAX && meal.Bonuses[type] <= 0.0))
				{
					continue;
				}

				TextStore_GetInv(client, i, type);
				if(type)
				{
					IntToString(i, num, sizeof(num));
					TextStore_GetItemName(i, buffer, sizeof(buffer));
					menu.AddItem(num, buffer);
				}
			}
		}

		if(!menu.ItemCount)
			menu.AddItem("-1", "No Foods", ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(CurrentMeal[client] != -1)
	{
		MealList.GetArray(CurrentMeal[client], meal);

		Menu menu = new Menu(SelectChoice);
		menu.SetTitle("RPG Fortress\n \nCooking: %s\n ", CurrentMeal[client]);

		if(LevelBalance)
		{
			Format(buffer, sizeof(buffer), "Level: %d", meal.Level + CurrentLevelBuff[client]);
			menu.AddItem("-1", buffer);
		}

		bool failed;

		if(meal.Required[0] && meal.RequireAmount > 0)
		{
			if(meal.RequireAmount > 1)
			{
				Format(buffer, sizeof(buffer), "%s x%d (Required)", meal.Required, meal.RequireAmount);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s (Required)", meal.Required);
			}

			menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);

			failed = TextStore_GetItemCount(client, meal.Required) < meal.RequireAmount;
		}

		for(int i; i < meal.Foods; i++)
		{
			IntToString(i, num, sizeof(num));

			if(CurrentFood[client][i])
			{
				TextStore_GetItemName(CurrentFood[client][i], buffer, sizeof(buffer));
				menu.AddItem(num, buffer);
			}
			else
			{
				menu.AddItem(num, "X");
				failed = true;
			}
		}

		if(meal.Extra != -1)
		{
			if(CurrentFood[client][meal.Foods])
			{
				TextStore_GetItemName(CurrentFood[client][meal.Foods], buffer, sizeof(buffer));
				StrCat(buffer, sizeof(buffer), " (Extra)")
				menu.AddItem(num, buffer);
			}
			else
			{
				menu.AddItem(num, "X (Extra)");
			}
		}

		if(failed)
		{
			menu.AddItem("-1", "Craft Food", ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem("F", "Craft Food");
		}

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(SelectMeal);
		menu.SetTitle("RPG Fortress\n \nCooking\n ");

		int length = MealList.Length;
		for(int i; i < length; i++)
		{
			MealList.GetArray(i, meal);

			if(meal.Required[0] && !meal.RequireAmount)
			{
				if(TextStore_GetItemCount(client, meal.Required) == 0)
				{
					Format(buffer, sizeof(buffer), "??? (%s)", meal.Required);
					menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
					continue;
				}
			}

			Format(buffer, sizeof(buffer), "%s (Lv %d)", meal.Item, meal.Level);
			menu.AddItem(meal.Item, buffer);
		}

		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static int SelectMeal(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			CurrentMeal[client] = choice;
			CookingMenu(client);
		}
	}
	return 0;
}

static int SelectChoice(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			CurrentMeal[client] = -1;
			CurrentLevelBuff[client] = 0;

			for(int i; i < sizeof(CurrentFood[]); i++)
			{
				CurrentFood[client][i] = 0;
			}

			if(choice == MenuCancel_ExitBack)
				CookingMenu(client);
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			if(num[0] == 'F')
			{
				CookProduct(client);
			}
			else
			{
				CurrentChoice[client] = StringToInt(num);
				if(CurrentChoice[client] == -1)
				{
					MealEnum meal;
					MealList.GetArray(CurrentMeal[client], meal);

					if(CurrentLevelBuff[client] == 0)
					{
						CurrentLevelBuff[client] = (Level[client] - meal.Level) / 2500 * 2500;
						if(CurrentLevelBuff[client] < 2500)
							CurrentLevelBuff[client] = 2500;
					}
					else
					{
						CurrentLevelBuff[client] -= 2500;
						if(CurrentLevelBuff[client] < 0)
							CurrentLevelBuff[client] = 0;
					}
				}

				CookingMenu(client);
			}
		}
	}
	return 0;
}

static int SelectFood(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			CurrentChoice[client] = -1;

			if(choice == MenuCancel_ExitBack)
			{
				CookingMenu(client);
			}
			else
			{
				CurrentMeal[client] = -1;
				CurrentLevelBuff[client] = 0;

				for(int i; i < sizeof(CurrentFood[]); i++)
				{
					CurrentFood[client][i] = 0;
				}
			}
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			CurrentFood[client][CurrentChoice[client]] = StringToInt(num);
		
			for(int i; i <= meal.Foods; i++)
			{
				if(CurrentChoice[client] != i && CurrentFood[client][i] == CurrentFood[client][CurrentChoice[client]])
					CurrentFood[client][i] = 0;
			}

			CurrentChoice[client] = -1;
			CookingMenu(client);
		}
	}
	return 0;
}

static void CookProduct(int client)
{
	MealEnum meal;
	MealList.GetArray(CurrentMeal[client], meal);

	int level = meal.Level;
	float globalBuff = 1.0;

	if(LevelBalance)
	{
		level += CurrentLevelBuff[client];

		int lowLv = -1;
		int highLv = 1999999999;
		float lowBuff = 1.0;
		float highBuff = 1.0;
		
		StringMapSnapshot snap = LevelBalance.Snapshot();
		
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			
			int lv = StringToInt(name);

			if(lv > lowLv && lv < level)
			{
				lowLv = lv;
				LevelBalance.GetValue(name, lowBuff);
			}
			else if(lv < highLv && lv > level)
			{
				highLv = lv;
				LevelBalance.GetValue(name, highBuff);
			}
		}

		delete snap;

		globalBuff = lowBuff + (((level - lowKv) / (highLv - lowLv)) * (highBuff - lowBuff));
	}

	for(int i; i <= meal.Foods; i++)
	{
		if(CurrentFood[client][i])
		{
			KeyValues kv = TextStore_GetItemKv(CurrentFood[client][i]);
			if(kv)
			{
				
			}
		}
	}

	if(meal.Required[0] && meal.RequireAmount > 0)
	{
		TextStore_AddItemCount(client, meal.Required, -meal.RequireAmount);
	}
}
