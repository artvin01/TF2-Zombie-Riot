#pragma semicolon 1
#pragma newdecls required

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
	CPrintToChatAll("%t", "Gained Ammo Supplies", amount);
}

public void Dungeon_Crate_Wood()
{
	int amount = GetRandomInt(1, 3);
	Construction_AddMaterial("wood", amount);
}

public void Dungeon_Crate_Iron()
{
	int amount = GetRandomInt(2, 4);
	Construction_AddMaterial("iron", amount);
}

public void Dungeon_Crate_Copper()
{
	int amount = GetRandomInt(2, 4);
	Construction_AddMaterial("copper", amount);
}

public void Dungeon_Crate_Crystal()
{
	Construction_AddMaterial("crystal", 1);
}

public void Dungeon_Crate_BonusCash25()
{
	int amount = GetRandomInt(10, 40);
	GlobalExtraCash += amount;
	CPrintToChatAll("%t", "Gained Extra Cash", amount);
}

public void Dungeon_Crate_BonusCash100()
{
	int amount = GetRandomInt(50, 150);
	GlobalExtraCash += amount;
	CPrintToChatAll("%t", "Gained Extra Cash", amount);
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