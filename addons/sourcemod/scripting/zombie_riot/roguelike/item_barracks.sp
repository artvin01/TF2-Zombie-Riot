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
	if(BarracksBlockItem(12))
		return;
	SupplyBonus += 1;
}

public void Rogue_AlHallam_Fortress_Collect()
{
	if(BarracksBlockItem(24))
		return;
	SupplyBonus += 2;
}

public void Rogue_Gambesons_Collect()
{
	if(BarracksBlockItem(12))
		return;
	FlatArmor += 10.0;
}

public void Rogue_Gambesons_Remove()
{
	FlatArmor -= 10.0;
}

public void Rogue_Neosteel_Collect()
{
	if(BarracksBlockItem(18))
		return;
	FlatArmor += 20.0;
}

public void Rogue_Neosteel_Remove()
{
	FlatArmor -= 10.0;
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


bool BarracksBlockItem(int cost)
{
	if(EnableSilentMode)
	{
		SPrintToChatAll("%t", "Barracks Disabled Rogue");
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, cost) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);

		return true;
	}
	return false;
}