#pragma semicolon 1
#pragma newdecls required

public void Rogue_StoneItem0_Collect()
{
	Rogue_AddUmbral(8, true);
}

public void Rogue_StoneItem0_Remove()
{
	if(Rogue_Started())
	{
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			ShopListing.PushArray(artifact);
		
		Rogue_AddUmbral(-8);
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
		if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		{
			ShopListing.PushArray(artifact);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			ShopListing.PushArray(artifact);
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
		if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
		{
			ShopListing.PushArray(artifact);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			ShopListing.PushArray(artifact);
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
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		{
			ShopListing.PushArray(artifact);
		}
		else if(Rogue_GetRandomArtifact(artifact, true) != -1)
		{
			ShopListing.PushArray(artifact);
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
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			ShopListing.PushArray(artifact);
		
		Rogue_AddUmbral(-6);
	}
}