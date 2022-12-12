#pragma semicolon 1
#pragma newdecls required

#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static int BackpackBonus[MAXTF2PLAYERS];
static int Strength[MAXTF2PLAYERS];
static int Dexterity[MAXTF2PLAYERS];
static int Intelligence[MAXTF2PLAYERS];
static int Agility[MAXTF2PLAYERS];
static int Luck[MAXTF2PLAYERS];

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
			Intelligence[client] = RoundFloat(value);
	}
}

void Stats_SetWeaponStats(int client, int entity, int slot)
{
	if(slot > TFWeaponSlot_Melee || i_IsWrench[entity])
	{
		if(Dexterity[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Dexterity[client] * 0.03)));
		}
	}
	else if(i_IsWandWeapon[entity])
	{
		if(Intelligence[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Intelligence[client] * 0.03)));
		}
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		if(Strength[client])
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * (1.0 + (Strength[client] * 0.03)));
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

int Stats_Luck(int client, int &base = 0, int &bonus = 0, int tier = -1)
{
	base = tier == -1 ? Tier[client] : tier;
	bonus = Luck[client];

	return base + bonus;
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

	// Health
	int oldAmount = Stats_BaseHealth(client, oldLevel, oldTier);
	int newAmount = Stats_BaseHealth(client);
	MACRO_SHOWDIFF("Max Health")

	// Backpack
	Stats_BaseCarry(client, oldAmount, _, oldLevel, oldTier);
	Stats_BaseCarry(client, newAmount);
	MACRO_SHOWDIFF("Backpack Storage")

	menu.Display(client, MENU_TIME_FOREVER);
}

public int Stats_ShowLevelUpH(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_End)
		delete menu;
	
	return 0;
}