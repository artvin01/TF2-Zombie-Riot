#pragma semicolon 1
#pragma newdecls required

static int PreviousFloor;
static int PreviousStage;
static bool HolyBlessing;

stock bool Rogue_Rift_HolyBlessing()
{
	return HolyBlessing;
}

public void Rogue_GamemodeHistory_Collect()
{
	PreviousFloor = -1;
	int floor = Rogue_GetFloor();
	int stage = Rogue_GetStage();

	Rogue_SendToFloor(6, 0);

	PreviousFloor = floor;
	PreviousStage = stage;
}

public void Rogue_GamemodeHistory_FloorChange(int &floor, int &stage)
{
	if(PreviousFloor == -1)
		return;
	
	// Send them back to where they were
	floor = PreviousFloor;
	stage = PreviousStage;
	Rogue_RemoveNamedArtifact("Gamemode History");
}

public void Rogue_GamemodeHistory_StageEnd(bool &victory)
{
	if(!victory)
	{
		// They lost, send them back
		victory = true;
		Rogue_RemoveNamedArtifact("Gamemode History");
		Rogue_SendToFloor(PreviousFloor, PreviousStage, false);
	}
}

public void Rogue_PoisonWater_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 0.8);
}

public void Rogue_PoisonWater_FloorChange(int &floor, int &stage)
{
	if(floor > 1)
		Rogue_RemoveNamedArtifact("Poisoned Water");
}

public void Rogue_HolyBlessing_Collect()
{
	HolyBlessing = true;
}

public void Rogue_HolyBlessing_Remove()
{
	HolyBlessing = false;
}

static void GiveMaxHealth(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		// +X% max health
		map.GetValue("26", value);
		map.SetValue("26", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		// +X% max health
		int health = RoundFloat(ReturnEntityMaxHealth(entity) * amount);

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}


public void Rogue_Minion_Energizer_Ally(int entity, StringMap map)
{
	if(map)	// Players
	{
		
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		fl_Extra_Damage[entity] *= 1.25;
		MultiHealth(entity, 1.25);
	}
}



static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
}