#pragma semicolon 1
#pragma newdecls required

static StringMap ItemsGiven;
static StringMap MatGiven;
static Handle StuffTimer;

void ItemMessage(const char[] string, int amount)
{
	if(!ItemsGiven)
		ItemsGiven = new StringMap();

	if(StuffTimer)
		delete StuffTimer;
	
	StuffTimer = CreateTimer(1.0, Timer_StuffGive);

	int total;
	ItemsGiven.GetValue(string, total);
	total += amount;
	ItemsGiven.SetValue(string, total);
}

void MaterialDelay(const char[] string, int amount)
{
	if(!MatGiven)
		MatGiven = new StringMap();

	if(StuffTimer)
		delete StuffTimer;
	
	StuffTimer = CreateTimer(1.0, Timer_StuffGive);

	int total;
	MatGiven.GetValue(string, total);
	total += amount;
	MatGiven.SetValue(string, total);
}

static Action Timer_StuffGive(Handle timer)
{
	StuffTimer = null;

	if(ItemsGiven)
	{
		StringMapSnapshot snap = ItemsGiven.Snapshot();

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int amount = snap.KeyBufferSize(i) + 1;
			char[] name = new char[amount];
			snap.GetKey(i, name, amount);

			ItemsGiven.GetValue(name, amount);
			CPrintToChatAll("%t", name, amount);
		}

		delete ItemsGiven;
	}

	if(MatGiven)
	{
		StringMapSnapshot snap = MatGiven.Snapshot();

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int amount = snap.KeyBufferSize(i) + 1;
			char[] name = new char[amount];
			snap.GetKey(i, name, amount);

			MatGiven.GetValue(name, amount);
			Construction_AddMaterial(name, amount);
		}

		delete MatGiven;
	}

	EmitSoundToAll("ui/itemcrate_smash_common.wav");
	return Plugin_Continue;
}

public void Dungeon_EasyMode_Enemy(int entity)
{
	float stats = 0.85;

	fl_Extra_Damage[entity] *= stats;
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * stats));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * stats));
}

public void Dungeon_Crate_Ammo()
{
	int amount = GetRandomInt(1, 3);
	Ammo_Count_Ready += amount;
	ItemMessage("Gained Ammo Supplies", amount);
}

public void Dungeon_Crate_Wood()
{
	int amount = GetRandomInt(1, 3);
	MaterialDelay("wood", amount);
}

public void Dungeon_Crate_Iron()
{
	int amount = GetRandomInt(3, 5);
	MaterialDelay("iron", amount);
}

public void Dungeon_Crate_Copper()
{
	int amount = GetRandomInt(3, 5);
	MaterialDelay("copper", amount);
}

public void Dungeon_Crate_Crystal()
{
	MaterialDelay("crystal", 1);
}

public void Dungeon_Crate_Crystal2()
{
	int amount = GetRandomInt(1, 3);
	MaterialDelay("crystal", amount);
}

public void Dungeon_Crate_BonusCash25()
{
	// 50
	int amount = GetRandomInt(30, 70);
	GlobalExtraCash += amount;
	ItemMessage("Gained Extra Cash", amount);
}

public void Dungeon_Crate_BonusCash100()
{
	int amount = GetRandomInt(50, 150);
	GlobalExtraCash += amount;
	ItemMessage("Gained Extra Cash", amount);
}

public void Dungeon_Crate_InscriptionFragment()
{
	Rogue_GiveNamedArtifact("Compass Fragment");
}

public void Dungeon_Crate_InscriptionWhole()
{
	Rogue_GiveNamedArtifact("Dungeon Compass");
}

public void Dungeon_Crate_KeyFragment()
{
	Rogue_GiveNamedArtifact("Key Fragment");
}

public void Dungeon_ShipEnding_Collect()
{
	if(Dungeon_Mode() && Dungeon_InSetup())
		Dungeon_SetRandomMusic();
}