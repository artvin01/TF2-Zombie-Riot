static int SupplyBonus;
static float FlatArmor;

void Rogue_Barracks_Reset()
{
	SupplyBonus = 0;
	FlatArmor = 0.0;
}

int Rogue_Barracks_BonusSupply()
{
	return SupplyBonus;
}

float Rogue_Barracks_FlatArmor()
{
	return FlatArmor;
}

public void Rogue_SupplyDepot_Collect()
{
	SupplyBonus++;
}

public void Rogue_Gambesons_Collect()
{
	FlatArmor += 10.0;
}

public void Rogue_Gambesons_Remove()
{
	FlatArmor -= 10.0;
}

public void Rogue_Neosteel_Collect()
{
	FlatArmor += 20.0;
}

public void Rogue_Neosteel_Remove()
{
	FlatArmor -= 10.0;
}

public void Rogue_ThumbRing_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])
	{
		switch(i_NpcInternalId[entity])
		{
			case BARRACK_ARCHER, BARRACK_CROSSBOW, BARRACK_ARBELAST, BARRACK_LONGBOW:
				view_as<BarrackBody>(entity).BonusFireRate *= 0.85;
		}
	}
}

public void Rogue_ThumbRing_Weapon(int entity)
{
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(!StrContains(buffer, "bow"))
	{
		Address address = TF2Attrib_GetByDefIndex(entity, 6);
		if(address != Address_Null)
			Attributes_Set(entity, 6, TF2Attrib_GetValue(address) * 0.85);
		
		address = TF2Attrib_GetByDefIndex(entity, 97);
		if(address != Address_Null)
			Attributes_Set(entity, 97, TF2Attrib_GetValue(address) * 0.85);
	}
}