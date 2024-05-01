#pragma semicolon 1
#pragma newdecls required

//#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static bool HasKeyHintHud[MAXTF2PLAYERS];
static int SaveIn[MAXTF2PLAYERS];
static StringMap Mastery[MAXTF2PLAYERS];

void Stats_PluginStart()
{
	RegConsoleCmd("rpg_stats", Stats_ShowStats, "Shows your RPG stats");
	RegConsoleCmd("rpg_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stats", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
}

void Stats_EnableCharacter(int client)
{
	KeyValues kv = Saves_Kv("stats");

	char buffer[64];
	if(Saves_ClientCharId(client, buffer, sizeof(buffer)))
		kv.JumpToKey(buffer);

	BackpackBonus[client] = 0;
	Agility[client] = 0;
	Luck[client] = 0;

	Strength[client] = kv.GetNum("strength");
	Precision[client] = kv.GetNum("precision");
	Artifice[client] = kv.GetNum("artifice");
	Endurance[client] = kv.GetNum("endurnace");
	Structure[client] = kv.GetNum("structure");
	Intelligence[client] = kv.GetNum("intelligence");
	Capacity[client] = kv.GetNum("capacity");
	XP[client] = kv.GetNum("xp");

	delete Mastery[client];

	if(kv.JumpToKey("mastery") && kv.GotoFirstSubKey(false))
	{
		Mastery[client] = new StringMap();

		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			Mastery[client].SetValue(buffer, kv.GetFloat(NULL_STRING));
		}
		while(kv.GotoNextKey(false));
	}
}

void Stats_GiveXP(int client, int xp)
{
	XP[client] += RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue);

	if(XP[client] > SaveIn[client])
	{
		SaveClientStats(client);
		SaveIn[client] = BaseUpgradeCost + (Level[client] * BaseUpgradeScale);
	}
	else
	{
		SaveIn[client] -= XP[client];
	}
}

static void SaveClientStats(int client)
{
	KeyValues kv = Saves_Kv("stats");

	char buffer[32];
	if(Saves_ClientCharId(client, buffer, sizeof(buffer)))
	{
		kv.JumpToKey(buffer, true);

		kv.SetNum("strength", Strength[client]);
		kv.SetNum("precision", Precision[client]);
		kv.SetNum("artifice", Artifice[client]);
		kv.SetNum("endurnace", Endurance[client]);
		kv.SetNum("structure", Structure[client]);
		kv.SetNum("intelligence", Intelligence[client]);
		kv.SetNum("capacity", Capacity[client]);
		kv.SetNum("xp", XP[client]);

		kv.DeleteKey("mastery");

		if(Mastery[client] && kv.JumpToKey("mastery", true))
		{
			float value;
			StringMapSnapshot snap = Mastery[client].Snapshot();
			int length = snap.Length;
			for(int i; i < length; i++)
			{
				snap.GetKey(i, buffer, sizeof(buffer));
				if(Mastery[client].GetValue(buffer, value) && value > 0.0)
					kv.SetFloat(buffer, value);
			}

			delete snap;
		}
	}
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
		float total = float(Stats_Capacity(client) * 50);
		if(Current_Mana[client] > total)
		{
			Current_Mana[client] = RoundToNearest(total);
		}
		max_mana[client] = total;
		i_MaxStamina[client] = RoundToNearest(float(Stats_Structure(client)) * 1.5);
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

float Stats_GetCurrentFormMastery(int client)
{
	float mastery;
	
	Form form;
	if(Races_GetClientInfo(client, _, form))
	{
		if(Mastery[client])
			Mastery[client].GetValue(form.Name, mastery);
	}

	return mastery;
}

float Stats_GetFormMastery(int client, const char[] name)
{
	float mastery;
	if(Mastery[client])
		Mastery[client].GetValue(name, mastery);
	
	return mastery;
}

float Stats_GetFormMaxMastery(int client, const char[] name)
{
	float mastery;
	if(Mastery[client])
		Mastery[client].GetValue(name, mastery);
	
	return mastery;
}

void Stats_SetCurrentFormMastery(int client, float mastery)
{
	Form form;
	if(Races_GetClientInfo(client, _, form))
	{
		if(!Mastery[client])
			Mastery[client] = new StringMap();
		
		if(mastery > form.Mastery)
		{
			mastery = form.Mastery;
		}
		Mastery[client].SetValue(form.Name, mastery);
		SaveClientStats(client);
	}
}

void Stats_SetFormMastery(int client, const char[] name, float mastery)
{
	if(!Mastery[client])
		Mastery[client] = new StringMap();
	
	Mastery[client].SetValue(name, mastery);
	SaveClientStats(client);
}

/*
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
	if(slot < TFWeaponSlot_Melee || i_IsWrench[entity])
	{
		int stat = Stats_Dexterity(client);
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
}
*/

void Stats_SetBodyStats(int client, TFClassType class, StringMap map)
{
	map.SetValue("26", RemoveExtraHealth(class, float(Stats_Structure(client) * 30)));
	map.SetValue("252", 0.0/*Stats_KnockbackResist(client)*/);
	//Give complete immunity to all normal knockback.
	//in RPG we will give knockback another way.

	float speed = 300.0 + float(Stats_Agility(client));
	map.SetValue("107", RemoveExtraSpeed(class, speed));

	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);
	
	map.SetValue("205", form.GetFloatStat(Form::DamageResistance, Stats_GetFormMastery(client, form.Name)));
	map.SetValue("206", form.GetFloatStat(Form::DamageResistance, Stats_GetFormMastery(client, form.Name)));
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
	return 1.0 / (0.5 + (Stats_Structure(client) * 0.0005));
}

static int UpgradeCost(int client)
{
	return BaseUpgradeCost + (Level[client] * BaseUpgradeScale);
}

public Action Stats_ShowStats(int client, int args)
{
	if(client)
	{
		if(Actor_InChatMenu(client))
			return Plugin_Handled;
		
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
				
				Stats_GiveXP(client, -cost);

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

				Stats_UpdateLevel(client);
			}

			SaveClientStats(client);
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
	return (float(total) * 1.35);
}

void Stats_UpdateLevel(int client)
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


void RPGStats_GiveTempomaryStatsToItem(int weaponindx, int statindx, int StatAmount, float duration)
{
	DataPack pack;
	CreateDataTimer(duration, RPGStats_GiveTempomaryStatsToItemTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(weaponindx));	
	pack.WriteCell(statindx);		
	pack.WriteCell(StatAmount);	
	RpgStats_GrantStatsViaIndex(weaponindx, statindx, StatAmount);
}

public Action RPGStats_GiveTempomaryStatsToItemTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int weaponindex = EntRefToEntIndex(pack.ReadCell());
	int statindx = pack.ReadCell();
	int StatAmount = pack.ReadCell();
	StatAmount *= -1;
	//invert
	if(IsValidEntity(weaponindex))
	{
		RpgStats_GrantStatsViaIndex(weaponindex, statindx, StatAmount);
	}

	return Plugin_Stop;
}

void RpgStats_GrantStatsViaIndex(int entity, int statindx, int StatAmount)
{
	switch(statindx)
	{
		case 1:
			Strength[entity] += StatAmount;
		case 2:
			Precision[entity] += StatAmount;
		case 3:
			Artifice[entity] += StatAmount;
		case 4:
			Endurance[entity] += StatAmount;
		case 5:
			Structure[entity] += StatAmount;
		case 6:
			Intelligence[entity] += StatAmount;
		case 7:
			Capacity[entity] += StatAmount;
	}
}