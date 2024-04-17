#pragma semicolon 1
#pragma newdecls required

//#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static bool HasKeyHintHud[MAXTF2PLAYERS];

static StringMap Mastery[MAXTF2PLAYERS];

void Stats_PluginStart()
{
	RegConsoleCmd("rpg_stats", Stats_ShowStats, "Shows your RPG stats");
	RegConsoleCmd("rpg_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stats", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
}

void Stats_ClientCookiesCached(int client)
{
	XP[client] = 100000;// TEST TEST
}

void Stats_LoadItems(int client)
{
	
}

void Stats_ClientDisconnect(int client)
{
	HasKeyHintHud[client] = false;
	delete Mastery[client];
}

void Stats_UpdateHud(int client)
{
	char buffer[256];

	if(IsPlayerAlive(client))
	{
		float total = float(Stats_Capacity(client) * 5);
		if(Current_Mana[client] > total)
		{
			Current_Mana[client] = RoundToNearest(max_mana[client]);
		}
		max_mana[client] = total;
	}

	if(buffer[0] || HasKeyHintHud[client])
		PrintKeyHintText(client, buffer);
	
	HasKeyHintHud[client] = view_as<bool>(buffer[0]);
}

void Stats_ClearCustomStats(int entity)
{
	BackpackBonus[entity] = 0;
	Strength[entity] = 0;
	Precision[entity] = 0;
	Artifice[entity] = 0;
	Endurance[entity] = 0;
	Structure[entity] = 0;
	Intelligence[entity] = 0;
	Capacity[entity] = 0;
	Agility[entity] = 0;
	Luck[entity] = 0;
	Level[entity] = 0;
/*OLD CODE
	BackpackBonus2[entity] = 0;
	Strength2[entity] = 0;
	Precision2[entity] = 0;
	Artifice2[entity] = 0;
	Endurance2[entity] = 0;
	Structure2[entity] = 0;
	Intelligence2[entity] = 0;
	Capacity2[entity] = 0;
	Agility2[entity] = 0;
	Luck2[entity] = 0;
*/
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
				Format(desc, 512, "%s\n%s Precision", desc, CharInt(RoundFloat(value[i])));
			
			case -4:
				Format(desc, 512, "%s\n%s Artifice", desc, CharInt(RoundFloat(value[i])));
			
			case -5:
				Format(desc, 512, "%s\n%s Endurance", desc, CharInt(RoundFloat(value[i])));
			
			case -6:
				Format(desc, 512, "%s\n%s Structure", desc, CharInt(RoundFloat(value[i])));
			
			case -7:
				Format(desc, 512, "%s\n%s Intelligence", desc, CharInt(RoundFloat(value[i])));
			
			case -8:
				Format(desc, 512, "%s\n%s Capacity", desc, CharInt(RoundFloat(value[i])));
			
			case -9:
				Format(desc, 512, "%s\n%s Luck", desc, CharInt(RoundFloat(value[i])));

			case -10:
				Format(desc, 512, "%s\n%s Agility", desc, CharInt(RoundFloat(value[i])));

			case 140:
				Format(desc, 512, "%s\n%s Max Health", desc, CharInt(RoundFloat(value[i])));
		
			case 405:
				Format(desc, 512, "%s\n%s Max Mana & Mana Regen", desc, CharPercent(value[i]));
		
			case 412:
				Format(desc, 512, "%s\n%s Damage Resistance", desc, CharPercent(1.0 / value[i]));

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
			Precision[entity] += RoundFloat(value);
		
		case -4:
			Artifice[entity] += RoundFloat(value);
		
		case -5:
			Endurance[entity] += RoundFloat(value);
		
		case -6:
			Structure[entity] += RoundFloat(value);
		
		case -7:
			Intelligence[entity] += RoundFloat(value);
		
		case -8:
			Capacity[entity] += RoundFloat(value);
		
		case -9:
			Luck[entity] += RoundFloat(value);

		case -10:
			Agility[entity] += RoundFloat(value);
	}
}

int Stats_GetFormMastery(int client, const char[] name)
{
	int mastery;
	if(Mastery[client])
		Mastery[client].GetValue(name, mastery);
	
	return mastery;
}

void Stats_SetFormMastery(int client, const char[] name, int mastery)
{
	if(!Mastery[client])
		Mastery[client] = new StringMap();
	
	Mastery[client].SetValue(name, mastery);
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

		Attributes_SetMulti(entity, 6, multi);
		Attributes_SetMulti(entity, 96, multi);
	}
	/*
	if(slot < TFWeaponSlot_Melee || i_IsWrench[entity])
	{
		int stat = 0;//Stats_Dexterity(client);
		if(stat)
		{
			Attributes_SetMulti(entity, 2, 1.0 + (stat / 50.0));
		}
	}
	else if(i_IsWandWeapon[entity])
	{
		int stat = Stats_Intelligence(client);
		if(stat)
		{
			Attributes_SetMulti(entity, 410, 1.0 + (stat / 50.0));
		}
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		int stat = Stats_Strength(client);
		if(stat)
		{
			Attributes_SetMulti(entity, 2, 1.0 + (stat / 50.0));
		}
	}
	*/
}

void Stats_SetBodyStats(int client, TFClassType class, StringMap map)
{
	map.SetValue("26", RemoveExtraHealth(class, float(Stats_Structure(client) * 30)));
	map.SetValue("252", Stats_KnockbackResist(client));
}

int Stats_BaseHealth(int client, int &base = 0, int &bonus = 0)
{
	base = 50;
	bonus = 0;

	return base + bonus;
}

int Stats_BaseCarry(int client, int &base = 0, int &bonus = 0)
{
	int strength = 5;
	if(strength > 20)
		strength = 20;
	
	base = strength;
	bonus = BackpackBonus[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += BackpackBonus[entity];
	}

	return base + bonus;
}

int Stats_Strength(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseStrength + Strength[client];
	bonus = 0;
	multi = race.StrengthMulti * form.GetFloatStat(Form::StrengthMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Strength[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Precision(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BasePrecision + Precision[client];
	bonus = 0;
	multi = race.PrecisionMulti * form.GetFloatStat(Form::PrecisionMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Precision[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Artifice(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseArtifice + Artifice[client];
	bonus = 0;
	multi = race.ArtificeMulti * form.GetFloatStat(Form::ArtificeMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Artifice[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Endurance(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseEndurance + Endurance[client];
	bonus = 0;
	multi = race.EnduranceMulti * form.GetFloatStat(Form::EnduranceMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Endurance[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Structure(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseStructure + Structure[client];
	bonus = 0;
	multi = race.StructureMulti * form.GetFloatStat(Form::StructureMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Structure[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Intelligence(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;	
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseIntelligence + Intelligence[client];
	bonus = 0;
	multi = race.IntelligenceMulti * form.GetFloatStat(Form::IntelligenceMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Intelligence[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Capacity(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	Races_GetClientInfo(client, race);

	base = BaseCapacity + Capacity[client];
	bonus = 0;
	multi = race.CapacityMulti;

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Capacity[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Agility(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseAgility + Agility[client];
	bonus = form.GetIntStat(Form::AgilityAdd, Stats_GetFormMastery(client, form.Name));
	multi = race.AgilityMulti;

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Agility[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Luck(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseLuck + Luck[client];
	bonus = form.GetIntStat(Form::LuckAdd, Stats_GetFormMastery(client, form.Name));
	multi = race.LuckMulti;

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		bonus += Luck[entity];
	}

	return bonus + RoundFloat(base * multi);
}

float Stats_KnockbackResist(int client)
{
	/*
	float lv = float(level == -1 ? Level[client] : level);
	float ti = float(tier == -1 ? Tier[client] : tier);

	return 1.0 / (0.5 + ti + (lv * 0.05));
	*/
	return 1.0;
}

void Stats_ShowLevelUp(int client, int oldLevel, int oldTier)
{
	/*
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

	int oldAmount, newAmount;
	Stats_BaseHealth(client, oldAmount, _, oldLevel, oldTier);
	Stats_BaseHealth(client, newAmount);
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
	*/
}

public int Stats_ShowLevelUpH(Menu menu, MenuAction action, int client, int choice)
{
	if(action == MenuAction_End)
		delete menu;
	
	return 0;
}

static int UpgradeCost(int client)
{
	return BaseUpgradeCost + (Level[client] * BaseUpgradeScale);
}

public Action Stats_ShowStats(int client, int args)
{
	if(client)
	{
		int cost = UpgradeCost(client);
		bool canSkill = XP[client] >= cost;

		Menu menu = new Menu(Stats_ShowStatsH);
		menu.SetTitle("RPG Fortress\n \nLevel: %d\nExperience: %d / %d", Level[client], XP[client], cost);

		char buffer[64];
		int amount, bonus;
		float multi;

		int total = Stats_Strength(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Strength: [%d x%.1f] + %d = [%d] (%.0f Melee DMG)", amount, multi, bonus, total, RPGStats_FlatDamageSetStats(client, 1));
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Precision(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Precision: [%d x%.1f] + %d = [%d] (%.0f Ranged DMG)", amount, multi, bonus, total, RPGStats_FlatDamageSetStats(client, 2));
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Artifice(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Artifice: [%d x%.1f] + %d = [%d] (%.0f Mage DMG)", amount, multi, bonus, total, RPGStats_FlatDamageSetStats(client, 3));
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Endurance(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Endurance: [%d x%.1f] + %d = [%d] (-%.0f Flat Res)", amount, multi, bonus, total, RPGStats_FlatDamageResistance(client));
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Structure(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Structure: [%d x%.1f] + %d = [%d]", amount, multi, bonus, total);
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Intelligence(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Intelligence: [%d x%.1f] + %d = [%d]", amount, multi, bonus, total);
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Capacity(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Capacity: [%d x%.1f] + %d = [%d]", amount, multi, bonus, total);
		menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		total = Stats_Agility(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Agility: [%d x%.1f] + %d = [%d]", amount, multi, bonus, total);
		menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

		total = Stats_Luck(client, amount, bonus, multi);
		FormatEx(buffer, sizeof(buffer), "Luck: [%d x%.1f] + %d = [%d]", amount, multi, bonus, total);
		menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

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
			for(int i; i < 1; i++)
			{
				int cost = UpgradeCost(client);
				if(XP[client] < cost)
					break;
				
				TextStore_AddXP(client, -cost);

				switch(choice)
				{
					case 0:
						Strength[client]++;
					
					case 1:
						Precision[client]++;
					
					case 2:
						Artifice[client]++;
					
					case 3:
						Endurance[client]++;
					
					case 4:
						Structure[client]++;
					
					case 5:
						Intelligence[client]++;
					
					case 6:
						Capacity[client]++;
				}

				UpdateLevel(client);
			}

			Stats_ShowStats(client, 0);
		}
	}
	return 0;
}


float RPGStats_FlatDamageSetStats(int client, int damageType = 0, int total = -999999)
{
	if(total == -999999)
	{
		switch(damageType)
		{
			case 1:
			{
				total = Stats_Strength(client);
			}
			case 2:
			{
				total = Stats_Precision(client);
			}
			case 3:
			{
				total = Stats_Artifice(client);
			}
		}
	}
	return (float(total) * 3.0);
}

float RPGStats_FlatDamageResistance(int client)
{
	int total;
	total = Stats_Endurance(client);
	return (float(total) * 1.85);
}

static void UpdateLevel(int client)
{
	int stats = Strength[client]
		+ Precision[client]
		+ Artifice[client]
		+ Endurance[client]
		+ Structure[client]
		+ Intelligence[client]
		+ Capacity[client]
		+ Agility[client]
		+ Luck[client];

	Level[client] = stats / 10;
}
