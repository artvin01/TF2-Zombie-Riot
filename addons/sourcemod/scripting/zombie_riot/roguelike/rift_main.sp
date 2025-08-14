#pragma semicolon 1
#pragma newdecls required

static ArrayList ShopListing;

public float Rogue_Encounter_RiftShop()
{
	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	bool rare = Rogue_GetFloor() > 0;

	if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		ShopListing.PushArray(artifact);
	
	if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 18) != -1)
		ShopListing.PushArray(artifact);

	if(Rogue_GetRandomArtifact(artifact, true, 24) != -1)
		ShopListing.PushArray(artifact);

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
			Rogue_GiveNamedArtifact("Despair");

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

stock float Rogue_Rift_OptionalVoteItem(const char[] name)
{
	ArrayList list = Rogue_CreateGenericVote(FinishOptionalVoteItem, "We found a Voidstone");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), name);
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), name);
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Leave it");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave it");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(15.0);
	return 20.0;
}

static void FinishOptionalVoteItem(const Vote vote, int index)
{
	if(index == 0)
		Rogue_GiveNamedArtifact(vote.Config);
}

static int ConsumeLimit;
public float Rogue_Encounter_RiftConsume()
{
	ConsumeLimit = 3;
	StartRiftVote(true);
	return 35.0;
}

static void StartRiftVote(bool first)
{
	ArrayList list = Rogue_CreateGenericVote(FinishRiftVote, "Rift Consume Encounter Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	ArrayList collection = Rogue_GetCurrentCollection();

	int found;
	if(collection)
	{
		Artifact artifact;
		int length = collection.Length;

		// Void Stones
		for(int i; i < length; i++)
		{
			Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

			if(artifact.ShopCost == 6)
			{
				strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
				strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
				strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
				list.PushArray(vote);
				
				if(++found > 5)
					break;
			}
		}

		if(found < 6)
		{
			// Misc items
			for(int i = length - 1; i >= 0; i--)
			{
				Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

				if(artifact.FuncRemove != INVALID_FUNCTION)
				{
					strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
					strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
					strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
					list.PushArray(vote);
					
					if(++found > 5)
						break;
				}
			}
		}

		delete collection;
	}

	Rogue_StartGenericVote(found ? (first ? 30.0 : 15.0) : 3.0);
}

static void FinishRiftVote(const Vote vote)
{
	Artifact artifact;
	int index = StringToInt(vote.Config);
	switch(index)
	{
		case -1:
		{
			Rogue_SetProgressTime(5.0, false);
		}
		default:
		{
			Rogue_RemoveNamedArtifact(artifact.Name);
			
			switch(GetURandomInt() % 5)
			{
				case 0:
					GiveShield(500);
				
				case 1:
					GiveShield(1000);
				
				case 2:
					GiveShield(1500);
				
				default:
					GiveCash(1000);
			}

			ConsumeLimit--;

			if(ConsumeLimit < 1)
			{
				Rogue_SetProgressTime(5.0, false);
			}
			else
			{
				CPrintToChatAll("%t", "Consumes Left", ConsumeLimit);
				StartRiftVote(false);
				Rogue_SetProgressTime(20.0, false);
			}
		}
	}
}

static void GiveCash(int cash)
{
	CurrentCash += cash;
	GlobalExtraCash += cash;
	CPrintToChatAll("{green}%t", "Cash Gained!", cash);
}

static void GiveShield(int amount)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
		{
			int health = GetClientHealth(client);
			if(health > 0)
			{
				ApplyHealEvent(client, amount, client);
				SetEntityHealth(client, health + amount);
			}
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red)
				SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") + amount);
		}
	}
}