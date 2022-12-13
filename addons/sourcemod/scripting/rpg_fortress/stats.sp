#pragma semicolon 1
#pragma newdecls required

#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static int BackpackBonus[MAXTF2PLAYERS];
static int Strength[MAXTF2PLAYERS];
static int Dexterity[MAXTF2PLAYERS];
static int Intelligence[MAXTF2PLAYERS];
static int Agility[MAXTF2PLAYERS];
static int Luck[MAXTF2PLAYERS];

void Stats_PluginStart()
{
	RegConsoleCmd("rpg_stats", Stats_ShowStats, "Shows your RPG stats");
	RegConsoleCmd("sm_stats", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
}

void Stats_ClearCustomStats(int client)
{
	BackpackBonus[client] = 0;
	Strength[client] = 0;
	Dexterity[client] = 0;
	Intelligence[client] = 0;
	Agility[client] = 0;
	Luck[client] = 0;
}

void Stats_GetCustomStats(int client, int attrib, float value)
{
	switch(attrib)
	{
		case -1:
			BackpackBonus[client] = RoundFloat(value);
		
		case -2:
			Strength[client] = RoundFloat(value);
		
		case -3:
			Dexterity[client] = RoundFloat(value);
		
		case -4:
			Intelligence[client] = RoundFloat(value);
		
		case -5:
			Luck[client] = RoundFloat(value);

		case -6:
			Agility[client] = RoundFloat(value);
	}
}

static float AgilityMulti(int amount)
{
	return 3.73333*Pow(amount + 16.0, -0.475);
}

void Stats_SetWeaponStats(int client, int entity, int slot)
{
	if(Agility[client])
	{
		float multi = AgilityMulti(Agility[client]);
		//Agility code.

		Address address = TF2Attrib_GetByDefIndex(entity, 6);
		if(address != Address_Null)
			TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * multi);

		address = TF2Attrib_GetByDefIndex(entity, 96);
		if(address != Address_Null)
			TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * multi);
	}

	if(slot > TFWeaponSlot_Melee || i_IsWrench[entity])
	{
		if(Dexterity[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Dexterity[client] / 30.0)));
		}
	}
	else if(i_IsWandWeapon[entity])
	{
		if(Intelligence[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 410);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Intelligence[client] / 30.0)));
		}
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		if(Strength[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Strength[client] / 30.0)));
		}
	}
}

int Stats_BaseHealth(int client, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	return 50 + (lv * 5) + (ti * 20);
}

int Stats_BaseCarry(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	int strength = 9 + lv / 2;
	if(strength > 20)
		strength = 20;
	
	base = strength + (ti * 10);
	bonus = BackpackBonus[client];

	return base + bonus;
}

int Stats_Strength(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Strength[client];

	return base + bonus;
}

int Stats_Dexterity(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Dexterity[client];

	return base + bonus;
}

int Stats_Intelligence(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Intelligence[client];

	return base + bonus;
}

int Stats_Agility(int client)
{
	return Agility[client];
}

int Stats_Luck(int client)
{
	return Luck[client];
}

void Stats_ShowLevelUp(int client, int oldLevel, int oldTier)
{
	Menu menu = new Menu(Stats_ShowLevelUpH, MenuAction_End);

	if(Tier[client])
	{
		menu.SetTitle("You are now Elite %d Level %d!\n ", Tier[client], Level[client]);
	}
	else
	{
		menu.SetTitle("You are now Level %d!\n ", Level[client]);
	}
	
	char buffer[64];

	int oldAmount = Stats_BaseHealth(client, oldLevel, oldTier);
	int newAmount = Stats_BaseHealth(client);
	MACRO_SHOWDIFF("Max Health")

	Stats_BaseCarry(client, oldAmount, _, oldLevel, oldTier);
	Stats_BaseCarry(client, newAmount);
	MACRO_SHOWDIFF("Backpack Storage")

	if(Tier[client] > oldTier)
	{
		oldAmount = 1 + oldTier;
		newAmount = 1 + Tier[client];
		MACRO_SHOWDIFF("Weight Per Equippment")
	}

	Stats_Strength(client, oldAmount, _, oldLevel, oldTier);
	Stats_Strength(client, newAmount);
	MACRO_SHOWDIFF("Strength")

	Stats_Dexterity(client, oldAmount, _, oldLevel, oldTier);
	Stats_Dexterity(client, newAmount);
	MACRO_SHOWDIFF("Dexterity")

	Stats_Intelligence(client, oldAmount, _, oldLevel, oldTier);
	Stats_Intelligence(client, newAmount);
	MACRO_SHOWDIFF("Intelligence")

	menu.Display(client, MENU_TIME_FOREVER);
}

public int Stats_ShowLevelUpH(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

public Action Stats_ShowStats(int client, int args)
{
	if(client)
	{
		Menu menu = new Menu(Stats_ShowStatsH);
		menu.SetTitle("RPG Fortress\n \nStats:");

		char buffer[64];

		int amount = Stats_BaseHealth(client);
		int bonus = SDKCall_GetMaxHealth(client) - amount;
		FormatEx(buffer, sizeof(buffer), "Max Health: %d + %d (0%% resistance)", amount, bonus);
		menu.AddItem(NULL_STRING, buffer);

		Stats_BaseCarry(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Backpack Storage: %d + %d (%d weight per item)", amount, bonus, Tier[client] + 1);
		menu.AddItem(NULL_STRING, buffer);

		int total = Stats_Strength(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Strength: %d + %d (+%.0f%% melee damage)", amount, bonus, total * 3.33333);
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Dexterity(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Dexterity: %d + %d (+%.0f%% ranged damage)", amount, bonus, total * 3.33333);
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Intelligence(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Intelligence: %d + %d (+%.0f%% magic damage)", amount, bonus, total * 3.33333);
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Agility(client);
		FormatEx(buffer, sizeof(buffer), "Agility: %d (+%.0f%% attack speed)", total, 1.0 / AgilityMulti(total));
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Luck(client);
		FormatEx(buffer, sizeof(buffer), "Luck: %d (+%.0f%% item drops)", total, total / 3.0);
		menu.AddItem(NULL_STRING, buffer);

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int Stats_ShowStatsH(Menu menu, MenuAction action, int client, int choice)
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
				FakeClientCommandEx(client, "sm_store");
		}
		case MenuAction_Select:
		{
			FakeClientCommandEx(client, "sm_store");
		}
	}
	return 0;
}