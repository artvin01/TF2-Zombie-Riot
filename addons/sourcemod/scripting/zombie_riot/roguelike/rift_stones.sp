#pragma semicolon 1
#pragma newdecls required

public void Rogue_StoneItem0_Collect()
{
	Rogue_AddUmbral(6, true);
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
		
		Rogue_AddUmbral(-6);
	}
}

public void Rogue_StoneItem1_Collect()
{
	Rogue_AddUmbral(9, true);
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
		
		Rogue_AddUmbral(-9);
	}
}

public void Rogue_StoneItem2_Collect()
{
	Rogue_AddUmbral(9, true);
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
		
		Rogue_AddUmbral(-9);
	}
}

public void Rogue_StoneItem3_Collect()
{
	Rogue_AddUmbral(9, true);
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
		
		Rogue_AddUmbral(-9);
	}
}

public void Rogue_StoneSprout_Collect()
{
	Rogue_AddUmbral(6, true);
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
		
		Rogue_AddUmbral(-6);
	}
}

public void Rogue_StoneCheerful_Collect()
{
	Rogue_AddUmbral(15, true);
}

public void Rogue_StoneCheerful_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 30) != -1)
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
	Rogue_AddUmbral(15, true);
}

public void Rogue_StoneNemesis_FloorChange(int newFloor)
{
	Rogue_AddUmbral(-3);
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
		
		Rogue_AddUmbral(-15);
	}
}

public void Rogue_StoneWildGrass_Collect()
{
	Rogue_AddUmbral(12, true);
}

public void Rogue_StoneWildGrass_Remove()
{
	if(Rogue_Started())
	{
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
		
		Rogue_AddUmbral(-12);
	}
}

public void Rogue_StoneShopBan_Remove()
{
	if(Rogue_Started())
	{
		Rogue_AddIngots(-Rogue_GetIngots());
	}
}