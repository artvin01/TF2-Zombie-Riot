#pragma semicolon 1
#pragma newdecls required

static ArrayList ShopListing;

public float Rogue_Encounter_RiftShop()
{	
	if(false)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 1);
			}
		}

		RemoveAllCustomMusic();

		strcopy(MusicString1.Path, sizeof(MusicString1.Path), "#zombiesurvival/forest_rogue/knucklebones.mp3");
		MusicString1.Time = 999;
		MusicString1.Volume = 1.0;
		MusicString1.Custom = true;
		strcopy(MusicString1.Name, sizeof(MusicString1.Name), "Knucklebones");
		strcopy(MusicString1.Artist, sizeof(MusicString1.Artist), "River Boy");
	}

	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	int ingots = Rogue_GetIngots();

	bool rare = Rogue_GetFloor() > 0;

	if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
		ShopListing.PushArray(artifact);

	if(ingots > 11)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
			ShopListing.PushArray(artifact);
		
		if(!rare && Rogue_GetRandomArtifact(artifact, true, 12) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 17)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 23)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
			ShopListing.PushArray(artifact);
	}

	if(rare)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 30) != -1)
			ShopListing.PushArray(artifact);
	}

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
	return 35.0;
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

	int length = ShopListing.Length;

	Artifact artifact;
	int ingots = Rogue_GetIngots();
	for(int i; i < length; i++)
	{
		ShopListing.GetArray(i, artifact);

		int cost = artifact.ShopCost;

		strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
		Format(vote.Append, sizeof(vote.Append), " △%d", cost);
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		IntToString(i, vote.Config, sizeof(vote.Config));
		vote.Locked = ingots < cost;
		list.PushArray(vote);
	}

	if(length)
	{
		strcopy(vote.Name, sizeof(vote.Name), "Steal Grigori");
		vote.Append[0] = 0;
		strcopy(vote.Desc, sizeof(vote.Desc), "Steal Grigori Desc");
		strcopy(vote.Config, sizeof(vote.Config), "-2");
		vote.Locked = false;
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(length ? (first ? 30.0 : 15.0) : 3.0);
}

static void FinishShopVote(const Vote vote)
{
	Artifact artifact;
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			Rogue_SetProgressTime(5.0, false);

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
		case -2:
		{
			Rogue_StartThisBattle(5.0);
			Rogue_SetBattleIngots(1);
			Rogue_GiveNamedArtifact("Mark of a Thief", true);

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
			ShopListing.Erase(index);

			Rogue_GiveNamedArtifact(artifact.Name);

			int cost = artifact.ShopCost;

			Rogue_ParadoxGeneric_ShopCost(cost);
			
			Rogue_AddIngots(-cost, true);

			StartShopVote(false);
			Rogue_SetProgressTime(20.0, false);
		}
	}
}

void Rogue_RiftShop_Victory()
{
	if(ShopListing)
	{
		Artifact artifact;

		int length = ShopListing.Length;
		for(int i; i < length; i++)
		{
			ShopListing.GetArray(i, artifact);
			Rogue_GiveNamedArtifact(artifact.Name);
		}

		delete ShopListing;
	}
}

void Rogue_RiftShop_Fail()
{
	delete ShopListing;
}