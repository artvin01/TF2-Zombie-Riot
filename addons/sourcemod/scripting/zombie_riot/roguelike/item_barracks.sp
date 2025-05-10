#pragma semicolon 1
#pragma newdecls required

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

public void Rogue_AlHallam_Fortress_Collect()
{
	SupplyBonus += 2;
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
	if(!b_NpcHasDied[entity] && view_as<BarrackBody>(entity).OwnerUserId)
	{
		char buffer[32];
		NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
		if(StrContains(buffer, "archer") != -1 || StrContains(buffer, "bow") != -1 || StrContains(buffer, "arbelast") != -1)
		{
			view_as<BarrackBody>(entity).BonusFireRate *= 0.75;
		}
	}
}

public void Rogue_ThumbRing_Weapon(int entity)
{
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(!StrContains(buffer, "bow"))
	{
		if(Attributes_Has(entity,6))
		{
			Attributes_Set(entity, 6, Attributes_Get(entity, 6, 1.0) * 0.75);
		}
		if(Attributes_Has(entity,97))
		{
			Attributes_Set(entity, 97, Attributes_Get(entity, 97, 1.0) * 0.75);
		}
	}
}