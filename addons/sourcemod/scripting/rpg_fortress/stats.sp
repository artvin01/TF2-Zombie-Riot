#pragma semicolon 1
#pragma newdecls required

static int BackpackBonus[MAXTF2PLAYERS];

void Stats_ClearCustomStats(int client)
{
	BackpackBonus[client] = 0;
}

void Stats_GetCustomStats(int client, int attrib, float value)
{
	switch(attrib)
	{
		case -1:
		{
			BackpackBonus[client] = RoundFloat(value);
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

	// Backpack
	int oldAmount, newAmount;
	Stats_BaseCarry(client, newAmount, _, oldLevel, oldTier);
	Stats_BaseCarry(client, oldAmount);

	if(oldAmount != newAmount)
	{
		FormatEx(buffer, sizeof(buffer), "Backpack Storage (%d -> %d)", oldAmount, newAmount);
		menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
	}
}

public int Stats_ShowLevelUpH(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_End)
		delete menu;
	
	return 0;
}