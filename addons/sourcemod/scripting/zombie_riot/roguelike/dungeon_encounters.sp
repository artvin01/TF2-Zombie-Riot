#pragma semicolon 1
#pragma newdecls required

static ArrayList ShopListing;
static bool FirstSuperSale;

public float Dungeon_Encounter_Shop()
{
	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;
	c_SupersaleThisItem[0] = 0;

	int ingots = Construction_GetMaterial("crystal");

	if(Rogue_GetRandomArtifact(artifact, true) != -1 && !Rogue_HasNamedArtifact(artifact.Name))
	{
		FirstSuperSale = true;
		ShopListing.PushArray(artifact);
	}

	if(ingots > 1 && Rogue_GetRandomArtifact(artifact, false, 2) != -1)
		ShopListing.PushArray(artifact);

	if(ingots > 11 && Rogue_GetRandomArtifact(artifact, true, 12) != -1 && !Rogue_HasNamedArtifact(artifact.Name))
		ShopListing.PushArray(artifact);
	
	if(ingots > 11 && Rogue_GetRandomArtifact(artifact, true, 12) != -1 && !Rogue_HasNamedArtifact(artifact.Name))
		ShopListing.PushArray(artifact);

	if(ingots > 17 && Rogue_GetRandomArtifact(artifact, true, 18) != -1 && !Rogue_HasNamedArtifact(artifact.Name))
		ShopListing.PushArray(artifact);

	if(ingots > 23 && Rogue_GetRandomArtifact(artifact, true, 24) != -1 && !Rogue_HasNamedArtifact(artifact.Name))
		ShopListing.PushArray(artifact);
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "*")) != -1)
	{
		if(entity < MAXENTITIES)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
			if(StrEqual(artifact.Name, "zr_store_prop", false))
				AcceptEntityInput(entity, "Enable");
		}
	}

	StartShopVote(true);
	return 50.0;
}

static void StartShopVote(bool first)
{
	ArrayList list = Rogue_CreateGenericVote(FinishShopVote, "Shop Encounter Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	Artifact artifact;
	int ingots = Construction_GetMaterial("crystal");
	int length = ShopListing.Length;
	bool found;
	for(int i; i < length; i++)
	{
		ShopListing.GetArray(i, artifact);

		bool sale = FirstSuperSale && !i;
		int cost = sale ? (artifact.ShopCost * 7 / 10) : artifact.ShopCost;

		if(ingots >= cost)
		{
			strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
			Format(vote.Append, sizeof(vote.Append), " △%d%s", cost, sale ? " {$}" : "");
			strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
			IntToString(i, vote.Config, sizeof(vote.Config));
			list.PushArray(vote);
			found = true;
		}
	}

	Rogue_StartGenericVote(found ? (first ? 30.0 : 15.0) : 3.0);
}

static void FinishShopVote(const Vote vote)
{
	Artifact artifact;
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			Dungeon_DelayVoteFor(5.0);

			delete ShopListing;

			int entity = -1;
			while((entity=FindEntityByClassname(entity, "*")) != -1)
			{
				if(entity < MAXENTITIES)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", artifact.Name, sizeof(artifact.Name));
					if(StrEqual(artifact.Name, "zr_store_prop", false))
						AcceptEntityInput(entity, "Disable");
				}
			}
		}
		default:
		{
			ShopListing.GetArray(index, artifact);

			int cost = artifact.ShopCost;
			if(FirstSuperSale && index == 0)
			{
				FirstSuperSale = false;
				cost = cost * 7 / 10;
			}
			
			if(Construction_GetMaterial("crystal") >= cost)
			{
				Rogue_GiveNamedArtifact(artifact.Name);
				Construction_AddMaterial("crystal", -cost, true);
				ShopListing.Erase(index);
			}

			StartShopVote(false);
			Dungeon_DelayVoteFor(20.0);
		}
	}
}