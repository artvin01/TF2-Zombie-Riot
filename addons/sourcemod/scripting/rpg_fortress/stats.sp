#pragma semicolon 1
#pragma newdecls required

//#define MACRO_SHOWDIFF(%1)	if(oldAmount != newAmount) { FormatEx(buffer, sizeof(buffer), %1 ... " (%d -> %d)", oldAmount, newAmount); menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED); }

static bool HasKeyHintHud[MAXPLAYERS];
static int SaveIn[MAXPLAYERS];
static int InputMulti[MAXPLAYERS];
static StringMap Mastery[MAXPLAYERS];
static ArrayList HasKilled[MAXPLAYERS];
static int StatStrength[MAXPLAYERS];
static int StatPrecision[MAXPLAYERS];
static int StatArtifice[MAXPLAYERS];
static int StatEndurance[MAXPLAYERS];
static int StatStructure[MAXPLAYERS];
static int StatIntelligence[MAXPLAYERS];
static int StatCapacity[MAXPLAYERS];
static int ReskillPoints[MAXPLAYERS];

#define INTELLIGENCE_1ST_STAT_MULTI 3000
#define INTELLIGENCE_2ST_STAT_MULTI 8000

void Stats_PluginStart()
{
	RegConsoleCmd("rpg_stats", Stats_ShowStats, "Shows your RPG stats");
	RegConsoleCmd("rpg_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stats", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegConsoleCmd("sm_stat", Stats_ShowStats, "Shows your RPG stats", FCVAR_HIDDEN);
	RegAdminCmd("sm_give_mastery", Command_Give_Mastery, ADMFLAG_RCON, "Force gives mastery to current form");
}

void Stats_EnableCharacter(int client)
{
	KeyValues kv = Saves_Kv("stats");

	char buffer[64];
	if(Saves_ClientCharId(client, buffer, sizeof(buffer)))
		kv.JumpToKey(buffer);

	StatStrength[client] = kv.GetNum("strength");
	StatPrecision[client] = kv.GetNum("precision");
	StatArtifice[client] = kv.GetNum("artifice");
	StatEndurance[client] = kv.GetNum("endurnace");
	StatStructure[client] = kv.GetNum("structure");
	StatIntelligence[client] = kv.GetNum("intelligence");
	StatCapacity[client] = kv.GetNum("capacity");
	XP[client] = kv.GetNum("xp");
	InputMulti[client] = kv.GetNum("input", 1);
	kv.GetVector("spawn", f3_PositionArrival[client]);
	ReskillPoints[client] = kv.GetNum("reskills");

	delete Mastery[client];

	Race race;
	Races_GetClientInfo(client, race);
	if(race.StartLevel > 0 && (Stats_GetStatCount(client) / BaseUpdateStats) <= 0)
	{
		int stats = Stats_GetStatCount(client) + ReskillPoints[client];
		int minStats = race.StartLevel * BaseUpdateStats;
		if(stats < minStats)
		{
			ReskillPoints[client] = minStats - stats;
		}
	}

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

	if(kv.JumpToKey("haskilled") && kv.GotoFirstSubKey(false))
	{
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			Stats_SetHasKill(client, buffer);
		}
		while(kv.GotoNextKey(false));
	}
	
	Stats_UpdateLevel(client);
}
/*
int RPGStats_MaxXPAllowed(int client)
{
	return (BaseMaxExperience + (BaseMaxExperiencePerLevel * Level[client]));
}
*/
void Stats_GiveXP(int client, int xp, int quest = 0)
{
	int XPToGive;
	if(xp > 0)
	{
		int CurrentXp = XP[client];
		XPToGive = RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue);
		if(quest == 2)
		{
			//We were in a CC
			if(CurrentXp >= XPToGive)
			{
				SPrintToChat(client, "You are unable to gain XP from Chaos Surgance's untill you spend your XP.");
				return;
			}
		}
		int CalculatedXP;
		CalculatedXP = XP[client] + XPToGive;
		if(CalculatedXP < XPToGive || CalculatedXP >= 2000000000)
		{
			XP[client] = 2000000000;
			SPrintToChat(client, "You hit the MAX XP cap, spend your XP.");
			//we did an overflow. set to 2billion.
		}
		else
		{
			XP[client] += XPToGive;
		}
	}
	else
	{
		//if its negative, just give minus.
		XP[client] += xp;
	}

	if(XP[client] > SaveIn[client])
	{
		Stats_SaveClientStats(client);
		SaveIn[client] = BaseUpgradeCost + (Level[client] * BaseUpgradeScale);
	}
	else
	{
		SaveIn[client] -= XP[client];
	}
}

float AgilityMulti(int amount)
{
	if(amount < -16)
		amount = -16;
	
	return 3.73333*Pow(amount + 16.0, -0.475);
}

void Stats_SaveClientStats(int client)
{
	KeyValues kv = Saves_Kv("stats");

	char buffer[64];
	if(Saves_ClientCharId(client, buffer, sizeof(buffer)))
	{
		kv.JumpToKey(buffer, true);

		kv.SetNum("strength", StatStrength[client]);
		kv.SetNum("precision", StatPrecision[client]);
		kv.SetNum("artifice", StatArtifice[client]);
		kv.SetNum("endurnace", StatEndurance[client]);
		kv.SetNum("structure", StatStructure[client]);
		kv.SetNum("intelligence", StatIntelligence[client]);
		kv.SetNum("capacity", StatCapacity[client]);
		kv.SetNum("xp", XP[client]);
		kv.SetNum("input", InputMulti[client]);
		kv.SetVector("spawn", f3_PositionArrival[client]);
		kv.SetNum("reskills", ReskillPoints[client]);

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

			kv.GoBack();
		}

		if(HasKilled[client] && kv.JumpToKey("haskilled", true))
		{
			int length = HasKilled[client].Length;
			for(int i; i < length; i++)
			{
				HasKilled[client].GetString(i, buffer, sizeof(buffer));
				kv.SetNum(buffer, 1);
			}

			kv.GoBack();
		}
	}
}

void Stats_ClientDisconnect(int client)
{
	HasKeyHintHud[client] = false;
	delete Mastery[client];
	delete HasKilled[client];
	f3_PositionArrival[client][0] = 0.0;
}

void Stats_UpdateHud(int client)
{
	char buffer[256];

	if(IsPlayerAlive(client))
	{
		float total = RPGStats_RetrieveMaxEnergy(Stats_Capacity(client));
		if(Current_Mana[client] > total)
		{
			Current_Mana[client] = RoundToNearest(total);
		}
		max_mana[client] = total;
		i_MaxStamina[client] = RPGStats_RetrieveMaxStamina(Stats_Structure(client));
	}

	if(buffer[0] || HasKeyHintHud[client])
		PrintKeyHintText(client, buffer);
	
	HasKeyHintHud[client] = view_as<bool>(buffer[0]);
}

int RPGStats_RetrieveMaxStamina(int stucture)
{
	return RoundToNearest(float(stucture) * 1.6);
}

float RPGStats_RetrieveMaxEnergy(int capacity)
{
	return float(capacity) * 50.0;
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
//	Level[entity] = 0;
	ArmorCorrosion[entity] = 0;
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

void Stats_SetCustomStats(int entity, int attrib, float value)
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

float Stats_GetCurrentFormMastery(int client, float &maxvalue = 0.0)
{
	float mastery;
	
	Form form;
	if(Races_GetClientInfo(client, _, form))
	{
		maxvalue = form.Mastery;
		if(Mastery[client])
			Mastery[client].GetValue(form.Name, mastery);
	}

	return mastery;
}

bool Stats_GetCurrentFormMasteryMax(int client)
{
	Form form;
	if(Races_GetClientInfo(client, _, form))
	{
		float mastery;

		if(Mastery[client])
			Mastery[client].GetValue(form.Name, mastery);
		
		return mastery >= form.Mastery;
	}

	return true;
}

float Stats_GetFormMastery(int client, const char[] name)
{
	float mastery;
	if(Mastery[client])
		Mastery[client].GetValue(name, mastery);
	
	return mastery;
}
/*
float Stats_GetFormMaxMastery(int client, const char[] name)
{
	float mastery;
	if(Mastery[client])
		Mastery[client].GetValue(name, mastery);
	
	return mastery;
}
*/
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
		Stats_SaveClientStats(client);
	}
}
/*
void Stats_SetFormMastery(int client, const char[] name, float mastery)
{
	if(!Mastery[client])
		Mastery[client] = new StringMap();
	
	Mastery[client].SetValue(name, mastery);
	Stats_SaveClientStats(client);
}
*/
bool Stats_GetHasKill(int client, const char[] name)
{
	if(HasKilled[client])
		return HasKilled[client].FindString(name) != -1;
	
	return false;
}

void Stats_SetHasKill(int client, const char[] name)
{
	if(!HasKilled[client])
		HasKilled[client] = new ArrayList(ByteCountToCells(64));
	
	HasKilled[client].PushString(name);
}

void Stats_ApplyAttribsPre(int client)
{
	Stats_ClearCustomStats(client);
}

void Stats_ReskillEverything(int client, int Setstats = 0)
{
	int stats = Stats_GetStatCount(client);
	
	StatStrength[client] = 0;
	StatPrecision[client] = 0;
	StatArtifice[client] = 0;
	StatEndurance[client] = 0;
	StatStructure[client] = 0;
	StatIntelligence[client] = 0;
	StatCapacity[client] = 0;

	if(Setstats == 0)
		ReskillPoints[client] = stats;
	else
		ReskillPoints[client] = Setstats;


	Stats_SaveClientStats(client);
	//Reset em.
	Store_ApplyAttribs(client);
	FakeClientCommandEx(client, "rpg_stats");
}

void Stats_ApplyAttribsPost(int client, TFClassType class)
{
	Attributes_SetAdd(client, 26, RemoveExtraHealth(class, float(Stats_Structure(client) * 30)));
	Attributes_Set(client, 252, 0.0/*Stats_KnockbackResist(client)*/);
	//Give complete immunity to all normal knockback.
	//in RPG we will give knockback another way.

	Stats_ApplyMovementSpeedUpdate(client, class);

	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);
	
	Attributes_SetMulti(client, Attrib_FormRes, form.GetFloatStat(client, Form::DamageResistance, Stats_GetFormMastery(client, form.Name)));
}

void Stats_ApplyMovementSpeedUpdate(int client, TFClassType class)
{
	float speed = 300.0 + float(Stats_Agility(client) * 2);
	
	//CC DIFFICULTY, 15% SLOWER!
	if(b_DungeonContracts_SlowerMovespeed[client])
	{
		speed *= 0.85; 
	}
	
	switch(BubbleProcStatusLogicCheck(client))
	{
		case -1:
		{
			speed *= 1.15; 
		}
		case 1:
		{
			speed *= 0.85; 
		}
	}
	Attributes_Set(client, 107, RemoveExtraSpeed(class, speed));
}

int Stats_BaseCarry(int client, int &base = 0, int &bonus = 0)
{
	base = 15;
	bonus = BackpackBonus[client];

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += BackpackBonus[entity];
	}

	return base + bonus;
}

int Stats_Strength(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseStrength + StatStrength[client];
	bonus = Strength[client];
	multirace = race.StrengthMulti;
	multiform = form.GetFloatStat(client, Form::StrengthMulti, Stats_GetFormMastery(client, form.Name));
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multiform *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multiform *= 1.05;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Strength[entity];
	}
	int returnnumber = (bonus + RoundFloat(base * multirace * multiform));
	if(TrueStength_ClientBuff(client))
	{
		returnnumber = RoundToNearest(float(returnnumber) * 1.35);
	}
	return returnnumber;
}

int Stats_Precision(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BasePrecision + StatPrecision[client];
	bonus = Precision[client];
	multirace = race.PrecisionMulti;
	multiform = form.GetFloatStat(client,Form::PrecisionMulti, Stats_GetFormMastery(client, form.Name));
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multiform *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multiform *= 1.05;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Precision[entity];
	}

	return bonus + RoundFloat(base * multirace * multiform);
}

int Stats_Artifice(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseArtifice + StatArtifice[client];
	bonus = Artifice[client];
	multirace = race.ArtificeMulti;
	multiform = form.GetFloatStat(client,Form::ArtificeMulti, Stats_GetFormMastery(client, form.Name));
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multiform *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multiform *= 1.05;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Artifice[entity];
	}

	return bonus + RoundFloat(base * multirace * multiform);
}

int Stats_Endurance(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseEndurance + StatEndurance[client];
	bonus = Endurance[client] - ArmorCorrosion[client];
	multirace = race.EnduranceMulti;
	multiform = form.GetFloatStat(client,Form::EnduranceMulti, Stats_GetFormMastery(client, form.Name));
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multiform *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multiform *= 1.05;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Endurance[entity];
	}
	int returnnumber = (bonus + RoundFloat(base * multirace * multiform));
	float dummyNumber;
	if(RPG_BobsPureRage(client, -1, dummyNumber))
	{
		returnnumber = RoundToNearest(float(returnnumber) * 1.15);
	}

	return returnnumber;
}

int Stats_Structure(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseStructure + StatStructure[client];
	bonus = Structure[client];
	multirace = race.StructureMulti;
	//donnt form multi
	multiform = form.GetFloatStat(-1,Form::StructureMulti, Stats_GetFormMastery(client, form.Name));
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multiform *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multiform *= 1.05;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Structure[entity];
	}

	return bonus + RoundFloat(base * multirace * multiform);
}

int Stats_Intelligence(int client, int &base = 0, int &bonus = 0, float &multirace = 0.0, float &multiform = 0.0)
{
	static Race race;	
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseIntelligence + StatIntelligence[client];
	bonus = Intelligence[client];
	multirace = race.IntelligenceMulti;
	multiform = form.GetFloatStat(client,Form::IntelligenceMulti, Stats_GetFormMastery(client, form.Name));

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Intelligence[entity];
	}

	return bonus + RoundFloat(base * multirace * multiform);
}

int Stats_Capacity(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	Races_GetClientInfo(client, race);

	base = BaseCapacity + StatCapacity[client];
	bonus = Capacity[client];
	multi = race.CapacityMulti;
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		multi *= 1.1;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		multi *= 1.05;
	}

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Capacity[entity];
	}

	return bonus + RoundFloat(base * multi);
}

int Stats_Agility(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseAgility;
	bonus = Agility[client] + form.GetIntStat(client,Form::AgilityAdd, Stats_GetFormMastery(client, form.Name));
	multi = race.AgilityMulti;
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		bonus += 2;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		bonus += 1;
	}
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Agility[entity];
	}

	return bonus + RoundFloat(base * multi);
}


int Stats_Luck(int client, int &base = 0, int &bonus = 0, float &multi = 0.0)
{
	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);

	base = BaseLuck;
	bonus = Luck[client] + form.GetIntStat(client, Form::LuckAdd, Stats_GetFormMastery(client, form.Name));
	multi = race.LuckMulti;
	if(Stats_Intelligence(client) >= INTELLIGENCE_2ST_STAT_MULTI)
	{
		bonus += 2;
	}
	else if(Stats_Intelligence(client) >= INTELLIGENCE_1ST_STAT_MULTI)
	{
		bonus += 1;
	}

	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		if(RPGStats_WeaponActiveNeeded(client, entity))
			bonus += Luck[entity];
	}

	return RoundFloat((float(bonus) + base) * multi);
}

bool RPGStats_WeaponActiveNeeded(int client, int weapon)
{
	if(Attributes_Get(weapon, 4010, 0.0) > 0.0)
	{
		int Activeweapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(Activeweapon == weapon)
			return true;

		return false;
	}
	return true;
}

/*
float Stats_KnockbackResist(int client)
{
	float lv = float(level == -1 ? Level[client] : level);
	float ti = float(tier == -1 ? Tier[client] : tier);

	return 1.0 / (0.5 + ti + (lv * 0.05));
	return 1.0 / (0.5 + (Stats_Structure(client) * 0.0005));
}
*/
int UpgradeCost(int client)
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
		
		char LVLBuffer[64];
		IntToString(Level[client],LVLBuffer, sizeof(LVLBuffer));
		ThousandString(LVLBuffer, sizeof(LVLBuffer));
		if(Level[client] >= BaseMaxLevel)
			strcopy(LVLBuffer, sizeof(LVLBuffer), "MAX");
		
		char XPBuffer[64];
		if(ReskillPoints[client] > 0)
		{
			IntToString(ReskillPoints[client],XPBuffer, sizeof(XPBuffer));
			ThousandString(XPBuffer, sizeof(XPBuffer));
			menu.SetTitle("RPG Fortress\n \nLevel: %s\nSkill Points: %s (x%d)\nReopen menu while crouching for extended info.", LVLBuffer, XPBuffer, InputMulti[client]);
			canSkill = true;
		}
		else
		{
			IntToString(XP[client],XPBuffer, sizeof(XPBuffer));
			ThousandString(XPBuffer, sizeof(XPBuffer));
			char costBuffer[64];
			IntToString(cost,costBuffer, sizeof(costBuffer));
			ThousandString(costBuffer, sizeof(costBuffer));
			menu.SetTitle("RPG Fortress\n \nLevel: %s\nXP: %s / %s (x%d)\nReopen menu while crouching for extended info.", LVLBuffer, XPBuffer, costBuffer, InputMulti[client]);
		}
		
		if(!(GetClientButtons(client) & IN_DUCK))
		{
			char buffer[64];
			int amount, bonus;
			float multirace,multiform;

			int total = Stats_Strength(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Strength: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Precision(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Precision: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Artifice(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Artifice: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Endurance(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Endurance: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Structure(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Structure: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Intelligence(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "Intelligence: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Capacity(client, amount, bonus, multirace);
			static Race race;	
			static Form form;
			Races_GetClientInfo(client, race, form);
			multiform = form.GetFloatStat(client,Form::EnergyMulti, Stats_GetFormMastery(client, form.Name));
			FormatEx(buffer, sizeof(buffer), "Capacity: [%d x%.2f] + %d = [%d]", amount, multirace * multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Agility(client, amount, bonus, multirace);
			FormatEx(buffer, sizeof(buffer), "Agility: [%d x%.2f] + %d = [%d]", amount, multirace, bonus, total);
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

			total = Stats_Luck(client, amount, bonus, multirace);
			FormatEx(buffer, sizeof(buffer), "Luck: [%d x%.2f] + %d = [%d]", amount, multirace, bonus, total);
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

			menu.AddItem(NULL_STRING, "Increase Input Multi", InputMulti[client] > 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(NULL_STRING, "Decrease Input Multi", InputMulti[client] < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}
		else
		{
			//Show more Accurate Info!
			char buffer[64];
			int amount, bonus;
			float multirace,multiform;

			int total = Stats_Strength(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "STR: [R:x%.2f F:x%.2f] (%.0f Melee DMG)", multirace, multiform, RPGStats_FlatDamageSetStats(client, 1));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Precision(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "PRE: [R:x%.2f F:x%.2f] (%.0f Ranged DMG)", multirace, multiform, RPGStats_FlatDamageSetStats(client, 2));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Artifice(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "ART: [R:x%.2f F:x%.2f] (%.0f Mage DMG)", multirace, multiform, RPGStats_FlatDamageSetStats(client, 3));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Endurance(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "END: [R:x%.2f F:x%.2f] (%.0f Flat RES)", multirace, multiform, RPGStats_FlatDamageResistance(client));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Structure(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "STU: [R:x%.2f F:x%.2f] (%d Stamina)", multirace, multiform, RPGStats_RetrieveMaxStamina(total));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Intelligence(client, amount, bonus, multirace, multiform);
			FormatEx(buffer, sizeof(buffer), "INT: [R:x%.2f F:x%.2f] (Skills)", multirace, multiform, bonus, total);
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Capacity(client, amount, bonus, multirace);
			static Race race;	
			static Form form;
			Races_GetClientInfo(client, race, form);
			multiform = form.GetFloatStat(client,Form::EnergyMulti, Stats_GetFormMastery(client, form.Name));
			FormatEx(buffer, sizeof(buffer), "CAP: [R:x%.2f F:x%.2f] (%.0f Energy)", multirace, multiform, RPGStats_RetrieveMaxEnergy(total));
			menu.AddItem(NULL_STRING, buffer, canSkill ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			total = Stats_Agility(client, amount, bonus, multirace);
			FormatEx(buffer, sizeof(buffer), "AGI: [%d x%.2f] + %d = [%d] (%.1f％ Speed)", amount, multirace, bonus, total, 100.0 + (total / 300.0));
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

			total = Stats_Luck(client, amount, bonus, multirace);
			FormatEx(buffer, sizeof(buffer), "LUC: [%d x%.2f] + %d = [%d] (%.1f％ Crits)", amount, multirace, bonus, total, (1 + total) * 0.1);
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

			menu.AddItem(NULL_STRING, "Increase Input Multi", InputMulti[client] > 1000 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem(NULL_STRING, "Decrease Input Multi", InputMulti[client] < 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);			
		}
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
			int oldLevel = Level[client];

			for(int i; i < InputMulti[client]; i++)
			{
				if(choice < 9)
				{
					if(ReskillPoints[client] > 0)
					{
						ReskillPoints[client]--;
					}
					else
					{
						if(Level[client] >= BaseMaxLevel)
							break;
						
						int cost = UpgradeCost(client);
						if(XP[client] < cost)
							break;
						
						// Removes XP
						cost = -cost;
						Stats_GiveXP(client, cost);
					}
				}

				switch(choice)
				{
					case 0:
					{
						StatStrength[client]++;
					}
					case 1:
					{
						StatPrecision[client]++;
					}
					case 2:
					{
						StatArtifice[client]++;
					}
					case 3:
					{
						StatEndurance[client]++;
					}
					case 4:
					{
						StatStructure[client]++;
					}
					case 5:
					{
						StatIntelligence[client]++;
					}
					case 6:
					{
						StatCapacity[client]++;
					}
					case 9:
					{
						InputMulti[client] *= 10;
						break;
					}
					case 10:
					{
						InputMulti[client] /= 10;
						if(InputMulti[client] < 1)
							InputMulti[client] = 1;
						
						break;
					}
				}

				Stats_UpdateLevel(client);
			}

			Tinker_StatsLevelUp(client, oldLevel);

			ClientCommand(client, "playgamesound ui/mm_medal_click.wav");
			UpdateLevelAbovePlayerText(client);
			Stats_SaveClientStats(client);
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
				return (float(total) * 3.0);
			}
			case 2:
			{
				total = Stats_Precision(client);
				return (float(total) * 2.3);
			}
			case 3:
			{
				total = Stats_Artifice(client);
				return (float(total) * 2.2);
			}
		}
	}
	return (float(total) * 3.0);
}

float RPGStats_FlatDamageResistance(int client)
{
	int total;
	if(client <= MaxClients)
		total = Stats_Endurance(client);
	else
		total = Endurance[client] - ArmorCorrosion[client];
	return (float(total) * 2.4);
}

int Stats_GetStatCount(int client)
{
	return StatStrength[client]
		+ StatPrecision[client]
		+ StatArtifice[client]
		+ StatEndurance[client]
		+ StatStructure[client]
		+ StatIntelligence[client]
		+ StatCapacity[client]
		+ ReskillPoints[client];
}

void Stats_UpdateLevel(int client)
{
	Level[client] = Stats_GetStatCount(client) / BaseUpdateStats;
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

static void RpgStats_GrantStatsViaIndex(int entity, int statindx, int StatAmount)
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


public Action Command_Give_Mastery(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_give_mastery <target> <mastery>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	char buf[12];
	GetCmdArg(2, buf, sizeof(buf));
	float money = StringToFloat(buf); 

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		if(money > 0.0)
		{
			PrintToChat(targets[target], "You got %0.2f  Mastery from the admin %N!", money, targets[target]);
			float MasteryAdd = money;
			float MasteryCurrent = Stats_GetCurrentFormMastery(targets[target]);
			MasteryCurrent += MasteryAdd;
			SPrintToChat(targets[target], "Your current form obtained %0.2f Mastery points.",MasteryAdd);
			Stats_SetCurrentFormMastery(targets[target], MasteryCurrent);
		}
	}
	
	return Plugin_Handled;
}

