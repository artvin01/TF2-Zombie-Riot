#pragma semicolon 1
#pragma newdecls required
/*
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
*/
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

	Food_MAX = 16
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
		this.Foods = kv.GetNum("foods", 1);
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
static int CurrentMeal[MAXPLAYERS] = {-1, ...};
static int CurrentChoice[MAXPLAYERS] = {-1, ...};
static int CurrentLevelBuff[MAXPLAYERS];
static int CurrentFood[MAXPLAYERS][16];

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

void Cooking_OpenMenu(int client)
{
	CurrentChoice[client] = -1;
	CurrentMeal[client] = -1;
	CurrentLevelBuff[client] = 0;
	for(int i; i < sizeof(CurrentFood[]); i++)
	{
		CurrentFood[client][i] = 0;
	}

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
				if(CurrentChoice[client] == meal.Foods)
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
			IntToString(meal.Foods, num, sizeof(num));

			if(CurrentFood[client][meal.Foods])
			{
				TextStore_GetItemName(CurrentFood[client][meal.Foods], buffer, sizeof(buffer));
				StrCat(buffer, sizeof(buffer), " (Extra)");
				menu.AddItem(num, buffer);
			}
			else
			{
				menu.AddItem(num, "X (Extra)");
			}
		}

		if(failed)
		{
			menu.AddItem("-1", "Create Meal", ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem("F", "Create Meal");
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
		
			for(int i; i < sizeof(CurrentFood[]); i++)
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
	float statsBuff = 1.0;
	float healingBuff = 1.0;

	if(LevelBalance && CurrentLevelBuff[client])
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

		// New Level Multi
		statsBuff = lowBuff + (((level - lowLv) / (highLv - lowLv)) * (highBuff - lowBuff));

		lowLv = -1;
		highLv = 1999999999;
		lowBuff = 1.0;
		highBuff = 1.0;
		
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			
			int lv = StringToInt(name);

			if(lv > lowLv && lv < meal.Level)
			{
				lowLv = lv;
				LevelBalance.GetValue(name, lowBuff);
			}
			else if(lv < highLv && lv > meal.Level)
			{
				highLv = lv;
				LevelBalance.GetValue(name, highBuff);
			}
		}

		// Old Level Multi
		healingBuff = statsBuff / (lowBuff + (((meal.Level - lowLv) / (highLv - lowLv)) * (highBuff - lowBuff)));
	}

	char buffer[32];
	StringMap map = new StringMap();

	map.SetValue("level", float(CurrentLevelBuff[client]));
	map.SetValue("uses", float(meal.Uses));

	if(healingBuff != 1.0)
	{
		map.SetValue("healing", healingBuff);
		map.SetValue("stamina", healingBuff);
		map.SetValue("energy", healingBuff);
	}

	char name[256], short[48], good[128], bad[128];
	strcopy(name, sizeof(name), meal.Item);
	strcopy(short, sizeof(short), meal.Item);

	for(int i; i <= meal.Foods; i++)
	{
		if(CurrentFood[client][i])
		{
			KeyValues kv = TextStore_GetItemKv(CurrentFood[client][i]);
			if(kv)
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				Format(name, sizeof(name), "%s %s", buffer, name);
				Format(short, sizeof(short), "%c. %s", buffer[0], short);
				
				int type = i == meal.Foods ? (Food_MAX-1) : kv.GetNum("foodtype");

				if(meal.Bonuses[type] > 1.0)
				{
					if(StrContains(good, " and ") != -1)
					{
						
					}
					else if(good[0])
					{
						Format(good, sizeof(good), "%s and %s", good, buffer);
					}
					else
					{
						strcopy(good, sizeof(good), buffer);
					}
				}
				else if(meal.Bonuses[type] < 1.0)
				{
					if(StrContains(bad, " and ") != -1)
					{
						
					}
					else if(bad[0])
					{
						Format(bad, sizeof(bad), "%s and %s", bad, buffer);
					}
					else
					{
						strcopy(bad, sizeof(bad), buffer);
					}
				}

				if(kv.GotoFirstSubKey(false))
				{
					do
					{
						kv.GetSectionName(buffer, sizeof(buffer));
						if(!StrContains(buffer, "food_a_", false))
						{
							float multi = 0.0;
							map.GetValue(buffer[7], multi);
							multi += kv.GetFloat(NULL_STRING, 1.0) * meal.Bonuses[type];
							map.SetValue(buffer[7], multi);
						}
						else if(!StrContains(buffer, "food_", false))
						{
							float multi = 1.0;
							map.GetValue(buffer[5], multi);
							multi *= 1.0 + ((kv.GetFloat(NULL_STRING, 1.0) - 1.0) * meal.Bonuses[type]);
							map.SetValue(buffer[5], multi);
						}
					}
					while(kv.GotoNextKey(false));
				}

				TextStore_GetInv(client, CurrentFood[client][i], type);
				TextStore_SetInv(client, CurrentFood[client][i], type - 1);
			}
		}
	}

	if(meal.Required[0] && meal.RequireAmount > 0)
	{
		TextStore_AddItemCount(client, meal.Required, -meal.RequireAmount);
	}

	char data[512];

	StringMapSnapshot snap = map.Snapshot();

	float multi = 1.0;
	int length = snap.Length;
	for(int i; i < length; i++)
	{
		snap.GetKey(i, buffer, sizeof(buffer));
		map.GetValue(buffer, multi);

		if(StrEqual(buffer, "strength") ||
			StrEqual(buffer, "precision") || 
			StrEqual(buffer, "artifice") || 
			StrEqual(buffer, "endurnace") || 
			StrEqual(buffer, "structure") || 
			StrEqual(buffer, "intelligence") || 
			StrEqual(buffer, "capacity"))
		{
			multi *= statsBuff;
		}

		if(i)
		{
			Format(data, sizeof(data), "%s:%s:%.2f", data, buffer, multi);
		}
		else
		{
			Format(data, sizeof(data), "%s:%.2f", buffer, multi);
		}
	}

	delete map;

	int index = TextStore_CreateUniqueItem(client, meal.Store, data, strlen(name) > 46 ? short : name);
	TextStore_UseItem(client, index, false);

	SPrintToChat(client, "You prepared a %s%s%s and equipped it", STORE_COLOR2, name, STORE_COLOR);

	if(good[0] && bad[0])
	{
		if(CurrentFood[client][meal.Foods])
		{
			TextStore_GetItemName(CurrentFood[client][meal.Foods], buffer, sizeof(buffer));
			SPrintToChat(client, "The %s%s%s you added worked really good, the %s%s%s doesn't work as good but the %s%s%s seemed to help.",
				STORE_COLOR2, good, STORE_COLOR, STORE_COLOR2, bad, STORE_COLOR, STORE_COLOR2, buffer, STORE_COLOR);
		}
		else
		{
			SPrintToChat(client, "The %s%s%s you added worked really good but the %s%s%s doesn't work as good.",
				STORE_COLOR2, good, STORE_COLOR, STORE_COLOR2, bad, STORE_COLOR);
		}
	}
	else if(good[0])
	{
		if(CurrentFood[client][meal.Foods])
		{
			TextStore_GetItemName(CurrentFood[client][meal.Foods], buffer, sizeof(buffer));
			SPrintToChat(client, "The %s%s%s you added worked really good with this meal and even some %s%s%s.",
				STORE_COLOR2, good, STORE_COLOR, STORE_COLOR2, buffer, STORE_COLOR);
		}
		else
		{
			SPrintToChat(client, "The %s%s%s you added worked really good with this meal.",
				STORE_COLOR2, good, STORE_COLOR);
		}
	}
	else if(bad[0])
	{
		if(CurrentFood[client][meal.Foods])
		{
			SPrintToChat(client, "The %s%s%s doesn't work as good with this but the %s%s%s seemed to help.",
				STORE_COLOR2, bad, STORE_COLOR, STORE_COLOR2, buffer, STORE_COLOR);
		}
		else
		{
			SPrintToChat(client, "The %s%s%s doesn't work as good with this meal.",
				STORE_COLOR2, bad, STORE_COLOR);
		}
	}
	else if(CurrentFood[client][meal.Foods])
	{
		SPrintToChat(client, "The %s%s%s you added help with this meal.",
			STORE_COLOR2, buffer, STORE_COLOR);
	}
	else
	{
		SPrintToChat(client, "This meal works pretty good with your ingredients.");
	}
}

bool Cooking_IsCookItem(KeyValues kv)
{
	char buffer[64];
	//kv.GetString("plugin", buffer, sizeof(buffer));
	//if(StrEqual(buffer, "rpg_fortress"))
	{
		kv.GetString("type", buffer, sizeof(buffer));
		if(!StrContains(buffer, "healing", false) || !StrContains(buffer, "spell", false))
		{
			if(KvGetFunction(kv, "func") == Cooking_UseFunction)
				return true;
		}
	}
	return false;
}

void Cooking_DescItem(int index, KeyValues kv, char[] desc)
{
	static char data[512];
	TextStore_GetItemData(index, data, sizeof(data));
	
	static char buffer[512], buffers[32][16];
	StringMap map = new StringMap();

	TextStore_GetItemData(index, buffer, sizeof(buffer));
	
	int count = ExplodeString(buffer, ":", buffers, sizeof(buffers), sizeof(buffers[]));
	for(int i = 1; i < count; i += 2)
	{
		map.SetValue(buffers[i - 1], StringToFloat(buffers[i]));
	}
	
	float uses;
	map.GetValue("uses", uses);
	float duration = MergMult(kv, map, "duration");
	float healing = MergMult(kv, map, "healing");
	float overheal = MergMult(kv, map, "overheal");

	Format(desc, 512, "Uses Left: %d | Level: %.0f\nHeals %.0f HP over %.0f seconds (%d％ Overheal)", RoundToCeil(uses), MergAdd(kv, map, "level"), healing, duration, RoundFloat(overheal * 100.0));

	float value = MergMult(kv, map, "stamina");
	if(value)
		Format(desc, 512, "%s\n%s%d Stats of Stamina", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergMult(kv, map, "energy");
	if(value)
		Format(desc, 512, "%s\n%s%d Stats of Energy", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergMult(kv, map, "resist");
	if(value != 1.0)
		Format(desc, 512, "%s\n%s%.0f％ Damage Resistance", desc, value < 1.0 ? "+" : "", 100.0 - (value * 100.0));

	value = MergMult(kv, map, "damage");
	if(value != 1.0)
		Format(desc, 512, "%s\n%s%.0f％ Damage Dealt", desc, value > 1.0 ? "+" : "", value * 100.0);
	
	value = MergAdd(kv, map, "strength");
	if(value)
		Format(desc, 512, "%s\n%s%d Strength", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "precision");
	if(value)
		Format(desc, 512, "%s\n%s%d Precision", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "artifice");
	if(value)
		Format(desc, 512, "%s\n%s%d Artifice", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "endurnace");
	if(value)
		Format(desc, 512, "%s\n%s%d Endurnace", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "structure");
	if(value)
		Format(desc, 512, "%s\n%s%d Structure", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "intelligence");
	if(value)
		Format(desc, 512, "%s\n%s%d Intelligence", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "capacity");
	if(value)
		Format(desc, 512, "%s\n%s%d Capacity", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "luck");
	if(value)
		Format(desc, 512, "%s\n%s%d Luck", desc, value > 0.0 ? "+" : "", RoundFloat(value));
	
	value = MergAdd(kv, map, "agility");
	if(value)
		Format(desc, 512, "%s\n%s%d Agility", desc, value > 0.0 ? "+" : "", RoundFloat(value));

	delete map;
}

public float Cooking_UseFunction(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		static char buffer[512], buffers[32][16];
		StringMap map = new StringMap();
		int count;

		if(index < 0)
		{
			TextStore_GetItemData(index, buffer, sizeof(buffer));
			
			count = ExplodeString(buffer, ":", buffers, sizeof(buffers), sizeof(buffers[]));
			for(int i = 1; i < count; i += 2)
			{
				map.SetValue(buffers[i - 1], StringToFloat(buffers[i]));
			}
		}

		float duration = MergMult(kv, map, "duration");
		float healing = MergMult(kv, map, "healing");
		float overheal = MergMult(kv, map, "overheal");

		HealEntityGlobal(client, client, healing, overheal, duration, HEAL_SELFHEAL);

		float value = MergMult(kv, map, "stamina");
		if(value)
			RPGCore_StaminaAddition(client, RPGStats_RetrieveMaxStamina(RoundFloat(value)));

		value = MergMult(kv, map, "energy");
		if(value)
			RPGCore_ResourceAddition(client, RoundToNearest(RPGStats_RetrieveMaxEnergy(RoundFloat(value))));

		value = MergMult(kv, map, "resist");
		if(value != 1.0)
			IncreaseEntityDamageTakenBy(client, value, duration);

		value = MergMult(kv, map, "damage");
		if(value != 1.0)
			IncreaseEntityDamageDealtBy(client, value, duration);
		
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1)
		{
			value = MergAdd(kv, map, "strength");
			if(value)
				ApplyTempStat(weapon, -2, value, duration);
			
			value = MergAdd(kv, map, "precision");
			if(value)
				ApplyTempStat(weapon, -3, value, duration);
			
			value = MergAdd(kv, map, "artifice");
			if(value)
				ApplyTempStat(weapon, -4, value, duration);
			
			value = MergAdd(kv, map, "endurnace");
			if(value)
				ApplyTempStat(weapon, -5, value, duration);
			
			value = MergAdd(kv, map, "structure");
			if(value)
				ApplyTempStat(weapon, -6, value, duration);
			
			value = MergAdd(kv, map, "intelligence");
			if(value)
				ApplyTempStat(weapon, -7, value, duration);
			
			value = MergAdd(kv, map, "capacity");
			if(value)
				ApplyTempStat(weapon, -8, value, duration);
			
			value = MergAdd(kv, map, "luck");
			if(value)
				ApplyTempStat(weapon, -9, value, duration);
			
			value = MergAdd(kv, map, "agility");
			if(value)
				ApplyTempStat(weapon, -10, value, duration);
		}

		kv.GetString("sound", buffer, sizeof(buffer));
		if(buffer[0])
			ClientCommand(client, "playgamesound %s", buffer);
		
		if(!map.GetValue("uses", value) || value <= 1.0)
		{
			int amount;
			TextStore_GetInv(client, index, amount);
			TextStore_SetInv(client, index, amount - 1, amount < 2 ? 0 : -1);

			name[0] = 0;
			return FAR_FUTURE;
		}

		if(index < 0)
		{
			for(int i = 1; i < count; i += 2)
			{
				if(StrEqual(buffers[i - 1], "uses"))
				{
					FloatToString(value - 1.0, buffers[i], sizeof(buffers[]));
				}

				if(i == 1)
				{
					Format(buffer, sizeof(buffer), "%s:%s", buffers[i - 1], buffers[i]);
				}
				else
				{
					Format(buffer, sizeof(buffer), "%s:%s:%s", buffer, buffers[i - 1], buffers[i]);
				}
			}

			TextStore_SetItemData(index, buffer);
		}

		duration += GetGameTime();
		TextStore_SetAllItemCooldown(client, duration + 10.0);
		return duration + MergMult(kv, map, "cooldown");
	}
	return FAR_FUTURE;
}

static float MergAdd(KeyValues kv, StringMap map, const char[] name, float defaul = 0.0)
{
	float value = 0.0;
	map.GetValue(name, value);
	return value + kv.GetFloat(name, defaul);
}

static float MergMult(KeyValues kv, StringMap map, const char[] name, float defaul = 1.0)
{
	float multi = 1.0;
	map.GetValue(name, multi);
	return multi * kv.GetFloat(name, defaul);
}

static void ApplyTempStat(int entity, int index, float amount, float duration)
{
	Stats_SetCustomStats(entity, index, amount);

	DataPack pack;
	CreateDataTimer(duration, TimerRestoreStat, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(index);
	pack.WriteFloat(amount);
}

static Action TimerRestoreStat(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int index = pack.ReadCell();
		Stats_SetCustomStats(entity, index, -pack.ReadFloat());
	}
	return Plugin_Stop;
}