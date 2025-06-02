#pragma semicolon 1
#pragma newdecls required

static int ObsessedIngots = -1;
static bool Solitary;
static bool Blind;

void Rogue_Curse_BattleStart()
{
	if(ObsessedIngots != -1)
		Rogue_AddBattleIngots(3);
}

bool Rogue_Curse_HideNames()
{
	return Blind;
}

void Rogue_Curse_StorePriceMulti(int &cost, bool greg)
{
	if(!greg && Solitary)
		cost = cost * 11 / 10;
}

void Rogue_Curse_PackPriceMulti(int &cost)
{
	if(Solitary)
		cost = cost * 9 / 10;
}

public void Rogue_Curse_Bewildered(bool enable)
{
	if(enable)
	{
		Rogue_AddExtraStage(1);
	}
		
	// ExtraStageCount cleared on new floor
}

public void Rogue_Curse_Sensitive(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Sensitive", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Sensitive");
	}
}

public void Rogue_SensitiveCurse_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;
		map.GetValue("412", value);
		map.SetValue("412", value * 1.25);

		
		map.GetValue("526", value);
		map.SetValue("526", value * 2.0);
	}
}

public void Rogue_FirstClass_Collect()
{
	/*
	int entity = Citizen_SpawnAtPoint("a");
	if(entity != -1)
	{
		Citizen_ReviveTicks(entity, 999, 0);
		Citizen_GivePerk(entity, 2);
	}
	*/
	Spawn_Cured_Grigori();
	Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);
}

public void Rogue_Curse_Obsessed(bool enable)
{
	if(enable)
	{
		ObsessedIngots = Rogue_GetIngots();
	}
	else
	{
		int ingots = Rogue_GetIngots() - ObsessedIngots;
		if(ingots > 0)
			Rogue_AddIngots(-ingots);
		
		ObsessedIngots = -1;
	}
}

public void Rogue_Curse_Solitary(bool enable)
{
	Solitary = enable;
}

public void Rogue_Curse_Blind(bool enable)
{
	Blind = enable;
}