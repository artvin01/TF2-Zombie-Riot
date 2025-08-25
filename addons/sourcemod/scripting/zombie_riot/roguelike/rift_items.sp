#pragma semicolon 1
#pragma newdecls required

static int PreviousFloor;
static int PreviousStage;
static bool HolyBlessing;
static bool VialityThing;
static bool FlashVestThing;

stock bool Rogue_Rift_HolyBlessing()
{
	return HolyBlessing;
}
stock bool Rogue_Rift_VialityThing()
{
	return VialityThing;
}
#define DOWNED_STUN_RANGE 200.0
stock void Rogue_Rift_FlashVest_StunEnemies(int victim)
{
	if(!Rogue_Rift_FlashVestThing())
		return;
	Explode_Logic_Custom(0.0, victim, victim, -1, _, DOWNED_STUN_RANGE, 1.0, _, _, 99,_,_,_,Viality_Stunenemy);
}

float Viality_Stunenemy(int entity, int victim, float damage, int weapon)
{
	FreezeNpcInTime(victim, 1.5);	
	return 0.0;
}
stock bool Rogue_Rift_FlashVestThing()
{
	return FlashVestThing;
}
public void Rogue_GamemodeHistory_Collect()
{
	PreviousFloor = -1;
	int floor = Rogue_GetFloor();
	int stage = Rogue_GetStage();

	Rogue_SendToFloor(6, -1);

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
public void Rogue_Vitality_Injection_Collect()
{
	VialityThing = true;
}

public void Rogue_Vitality_Injection_Remove()
{
	VialityThing = false;
}
public void Rogue_FlashVest_Collect()
{
	FlashVestThing = true;
}

public void Rogue_FlashVest_Remove()
{
	FlashVestThing = false;
}

public void Rogue_Mazeat1_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		MultiHealth(entity, 0.85);
		fl_Extra_Damage[entity] *= 0.85;
	}
}

public void Rogue_Mazeat2_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		fl_Extra_Speed[entity] *= 0.9;
	}
}

public void Rogue_Mazeat3_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_VOID && view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_UMBRAL)
	{
		MultiHealth(entity, 0.7);
		fl_Extra_Damage[entity] *= 0.7;

		for(int i; i < Element_MAX; i++)
		{
			SetEntPropFloat(entity, Prop_Data, "m_flElementRes", GetEntPropFloat(entity, Prop_Data, "m_flElementRes") - 1.0);
		}
	}
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