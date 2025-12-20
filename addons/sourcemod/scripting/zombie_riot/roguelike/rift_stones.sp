#pragma semicolon 1
#pragma newdecls required

public void Rogue_StoneItem0_Collect()
{
	Rogue_AddUmbral(-6, true);
}

public void Rogue_StoneItem0_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(6);
	}
}

public void Rogue_StoneItem1_Collect()
{
	Rogue_AddUmbral(-9, true);
}

public void Rogue_StoneItem1_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(9);
	}
}

public void Rogue_StoneItem2_Collect()
{
	Rogue_AddUmbral(-6, true);
}

public void Rogue_StoneItem2_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(6);
	}
}

public void Rogue_StoneItem3_Collect()
{
	Rogue_AddUmbral(-12, true);
}

public void Rogue_StoneItem3_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(12);
	}
}

public void Rogue_StoneSprout_Collect()
{
	Rogue_AddUmbral(-6, true);
}

public void Rogue_StoneSprout_FloorChange(int newFloor)
{
	Rogue_GiveNamedArtifact("Shrivel and Sprout");
}

public void Rogue_StoneSprout_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
		
		Rogue_AddUmbral(6);
	}
}

public void Rogue_StoneCheerful_Collect()
{
	Rogue_AddUmbral(-15, true);
}

public void Rogue_StoneCheerful_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
	}
}

public void Rogue_StoneNemesis_Collect()
{
	Rogue_AddUmbral(-15, true);
}

public void Rogue_StoneNemesis_FloorChange(int newFloor)
{
	Rogue_AddUmbral(3);
}

public void Rogue_StoneNemesis_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(15);
	}
}

public void Rogue_StoneWildGrass_Collect()
{
	Rogue_AddUmbral(-12, true);
}

public void Rogue_StoneWildGrass_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
		
		Rogue_AddUmbral(12);
	}
}

public void Rogue_StoneShopBan_Remove()
{
	if(Rogue_Started())
	{
		Rogue_AddIngots(-Rogue_GetIngots());
	}
}

public void Rogue_Stone1_StageEnd()
{
	Rogue_AddUmbral(-1);
}

public void Rogue_Stone2_StageEnd()
{
	Rogue_AddUmbral(-2);
}

public void Rogue_Stone3_StageEnd()
{
	Rogue_AddUmbral(-3);
}

public void Rogue_StoneOutblood_Ally(int entity, StringMap map)
{
	RogueHelp_BodyAPSD(entity, map, 1.07);
}

public void Rogue_StoneOutblood_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 1.07);
}

public void Rogue_StoneFlames_Ally(int entity, StringMap map)
{
	RogueHelp_BodyAPSD(entity, map, 1.14);
}

public void Rogue_StoneFlames_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 1.14);
}

public void Rogue_StoneWitchcraft_Enemy(int entity)
{
	fl_Extra_Damage[entity] *= 1.1;
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 1.1));
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.1));
}

public void Rogue_StoneWitchcraft_StageEnd()
{
	Rogue_AddUmbral(3);
}

public void Rogue_StoneConsume_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.075);
}

public void Rogue_StoneReclaim_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.15);
}

public void Rogue_StonePillage_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.05);
}

public void Rogue_StonePillage_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.05);
}

public void Rogue_StoneInvasion_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.1);
}

public void Rogue_StoneInvasion_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.1);
}

public void Rogue_StoneRise_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.15);
}

public void Rogue_StoneRise_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.15);
}

public void Rogue_StoneLost_Collect()
{
	Rogue_AddUmbral(12, true);
}

public void Rogue_StoneLost_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			Rogue_GiveNamedArtifact(artifact.Name);
		}
		
		Rogue_AddUmbral(-12);
	}
}

public void Rogue_StoneWords_Collect()
{
	Rogue_AddUmbral(6, true);
}

public void Rogue_StoneWords_Remove()
{
	if(Rogue_Started())
	{
		GiveCash(2000);
		Rogue_AddUmbral(-6);
	}
}

public void Rogue_StoneAssembly_Collect()
{
	Rogue_AddUmbral(9, true);
}

public void Rogue_StoneAssembly_Remove()
{
	if(Rogue_Started())
	{
		GiveCash(3000);
		Rogue_AddUmbral(-9);
	}
}

public void Rogue_StoneCatastrophe_Collect()
{
	Rogue_AddUmbral(9, true);
}

public void Rogue_StoneCatastrophe_Remove()
{
	if(Rogue_Started())
	{
		Rogue_AddIngots(9);
		Rogue_AddUmbral(-9);
	}
}

public void Rogue_StoneFurnace_Collect()
{
	Rogue_AddUmbral(12, true);
}

public void Rogue_StoneFurnace_Remove()
{
	if(Rogue_Started())
	{
		Rogue_AddIngots(12);
		Rogue_AddUmbral(-12);
	}
}

static void GiveCash(int cash)
{
	CurrentCash += cash;
	GlobalExtraCash += cash;
	CPrintToChatAll("{green}%t", "자금 획득!", cash);
}



public void Rogue_LelouchCrestBroken_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;
		//give 1 armor level
		map.GetValue("701", value);
		map.SetValue("701", value + 50.0);
	}
}
public void Rogue_IncorruptableLeaf_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;
		//give 30% res
		map.GetValue("4049", value);
		map.SetValue("4049", value * 0.7);
	}
}