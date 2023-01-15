#pragma semicolon 1
#pragma newdecls required

#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static Cookie CookieInfection;
static int BackpackBonus[MAXENTITIES];
static int Strength[MAXENTITIES];
static int Dexterity[MAXENTITIES];
static int Intelligence[MAXENTITIES];
static int Agility[MAXENTITIES];
static int Luck[MAXENTITIES];
static int Originium[MAXENTITIES];
static int NeuralDamage[MAXTF2PLAYERS];

void Stats_PluginStart()
{
	RegConsoleCmd("rpg_stats", Stats_ShowStats, "Shows your RPG stats");
	RegConsoleCmd("sm_stats", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);

	CookieInfection = new Cookie("rpg_originium", "Originium Infection Amount", CookieAccess_Protected);
}

void Stats_ClientCookiesCached(int client)
{
	char buffer[12];
	CookieInfection.Get(client, buffer, sizeof(buffer));
	Originium[client] = StringToInt(buffer);
}

void Stats_ClientDisconnect(int client)
{
	if(AreClientCookiesCached(client))
	{
		char buffer[12];
		IntToString(Originium[client], buffer, sizeof(buffer));
		CookieInfection.Set(client, buffer);
	}

	Originium[client] = 0;
}

void Stats_ClearCustomStats(int entity)
{
	BackpackBonus[entity] = 0;
	Strength[entity] = 0;
	Dexterity[entity] = 0;
	Intelligence[entity] = 0;
	Agility[entity] = 0;
	Luck[entity] = 0;

	if(entity <= MaxClients)
	{
		NeuralDamage[entity] = 0;
	}
	else
	{
		Originium[entity] = 0;
	}
}

void Stats_AddNeuralDamage(int client, int attacker, int damage)
{
	NeuralDamage[client] = damage;
	if(NeuralDamage[client] > 499)
	{
		NeuralDamage[client] = 0;
		int health = GetClientHealth(client);
		if(health > 500)
		{
			TF2_StunPlayer(client, 5.0, 1.0, TF_STUNFLAGS_BIGBONK, client);
			SetEntityHealth(client, health - 500);
		}
		else
		{
			SDKHooks_TakeDamage(client, attacker, attacker, damage * 10.0, DMG_DROWN);
		}
	}
}

void Stats_DescItem(char[] desc, int[] attrib, float[] value, int attribs)
{
	for(int i; i < attribs; i++)
	{
		switch(attrib[i])
		{
			case -1:
				Format(desc, 512, "%s\n%s Backpack Storage", desc, CharInt(RoundFloat(value[i])));
			
			case -2:
				Format(desc, 512, "%s\n%s Strength", desc, CharInt(RoundFloat(value[i])));
			
			case -3:
				Format(desc, 512, "%s\n%s Dexterity", desc, CharInt(RoundFloat(value[i])));
			
			case -4:
				Format(desc, 512, "%s\n%s Intelligence", desc, CharInt(RoundFloat(value[i])));
			
			case -5:
				Format(desc, 512, "%s\n%s Luck", desc, CharInt(RoundFloat(value[i])));

			case -6:
				Format(desc, 512, "%s\n%s Agility", desc, CharInt(RoundFloat(value[i])));

			case 140:
				Format(desc, 512, "%s\n%s Max Health", desc, CharInt(RoundFloat(value[i])));
		
			case 405:
				Format(desc, 512, "%s\n%s Max Mana & Mana Regen", desc, CharPercent(value[i]));
		
			case 412:
				Format(desc, 512, "%s\n%s Damage Taken", desc, CharPercent(value[i]));

		}
	}
}

void Stats_GetCustomStats(int entity, int attrib, float value)
{
	switch(attrib)
	{
		case -1:
			BackpackBonus[entity] += RoundFloat(value);
		
		case -2:
			Strength[entity] += RoundFloat(value);
		
		case -3:
			Dexterity[entity] += RoundFloat(value);
		
		case -4:
			Intelligence[entity] += RoundFloat(value);
		
		case -5:
			Luck[entity] += RoundFloat(value);

		case -6:
			Agility[entity] += RoundFloat(value);
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
			TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(address) * multi);

		address = TF2Attrib_GetByDefIndex(entity, 96);
		if(address != Address_Null)
			TF2Attrib_SetByDefIndex(entity, 96, TF2Attrib_GetValue(address) * multi);
	}

	if(slot < TFWeaponSlot_Melee || i_IsWrench[entity])
	{
		int stat = Stats_Dexterity(client);
		if(stat)
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(address) * (1.0 + (stat / 50.0)));
		}
	}
	else if(i_IsWandWeapon[entity])
	{
		int stat = Stats_Intelligence(client);
		if(stat)
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 410);
			if(address != Address_Null)
				TF2Attrib_SetByDefIndex(entity, 410, TF2Attrib_GetValue(address) * (1.0 + (stat / 50.0)));
		}
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		int stat = Stats_Strength(client);
		if(stat)
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(address) * (1.0 + (stat / 50.0)));
		}
	}
}

void Stats_SetBodyStats(int client, TFClassType class, StringMap map)
{
	map.SetValue("26", RemoveExtraHealth(class, float(Stats_BaseHealth(client))));
	map.SetValue("252", Stats_KnockbackResist(client));
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

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += BackpackBonus[entity];
	}

	return base + bonus;
}

int Stats_Strength(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Strength[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Strength[entity];
	}

	return base + bonus;
}

int Stats_Dexterity(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Dexterity[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Dexterity[entity];
	}

	return base + bonus;
}

int Stats_Intelligence(int client, int &base = 0, int &bonus = 0, int level = -1, int tier = -1)
{
	int lv = level == -1 ? Level[client] : level;
	int ti = tier == -1 ? Tier[client] : tier;

	base = lv / 2 + (ti * 5);
	bonus = Intelligence[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Intelligence[entity];
	}

	return base + bonus;
}

int Stats_Agility(int client)
{
	int bonus = Agility[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Agility[entity];
	}

	return bonus;
}

int Stats_Luck(int client)
{
	int bonus = Luck[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Luck[entity];
	}

	return bonus;
}

float Stats_KnockbackResist(int client, int level = -1, int tier = -1)
{
	float lv = float(level == -1 ? Level[client] : level);
	float ti = float(tier == -1 ? Tier[client] : tier);

	return 1.0 / (0.5 + ti + (lv * 0.05));
}

void Stats_ShowLevelUp(int client, int oldLevel, int oldTier)
{
	Menu menu = new Menu(Stats_ShowLevelUpH, MenuAction_End);

	if(Tier[client])
	{
		menu.SetTitle("You are now Elite %d Level %d!\n ", Tier[client], Level[client] - GetLevelCap(Tier[client] - 1));
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

	Tinker_StatsLevelUp(client, oldLevel, menu);

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
		menu.SetTitle("RPG Fortress\n \nPlayer Stats:");

		char buffer[64];

		int amount = Stats_BaseHealth(client);
		int bonus = SDKCall_GetMaxHealth(client) - amount;
		FormatEx(buffer, sizeof(buffer), "Max Health: %d + %d (%.0f%% resistance)", amount, bonus, 1.0 / Attributes_FindOnPlayer(client, 412, true, 1.0));
		menu.AddItem(NULL_STRING, buffer);

		Stats_BaseCarry(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Backpack Storage: %d + %d (%d weight per item)", amount, bonus, Tier[client] + 1);
		menu.AddItem(NULL_STRING, buffer);

		int total = Stats_Strength(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Strength: %d + %d (+%.0f%% melee damage)", amount, bonus, total * 2.0);
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Dexterity(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Dexterity: %d + %d (+%.0f%% ranged damage)", amount, bonus, total * 2.0);
		menu.AddItem(NULL_STRING, buffer);

		total = Stats_Intelligence(client, amount, bonus);
		FormatEx(buffer, sizeof(buffer), "Intelligence: %d + %d (+%.0f%% magic damage)", amount, bonus, total * 2.0);
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