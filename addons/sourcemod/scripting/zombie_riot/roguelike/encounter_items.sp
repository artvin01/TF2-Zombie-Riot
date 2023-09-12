static ArrayList ShopListing;
static bool FirstSuperSale;

public float Rogue_Encounter_Shop()
{
	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	if(Rogue_GetRandomArtfiact(artifact, true, -1) != -1)
	{
		FirstSuperSale = true;
		ShopListing.PushArray(artifact);
	}

	int ingots = Rogue_GetIngots();

	if(ingots > 7)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 8) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 11)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 12) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 17)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 18) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 23)
	{
		if(Rogue_GetRandomArtfiact(artifact, true, 24) != -1)
			ShopListing.PushArray(artifact);
	}

	StartShopVote();
	return 35.0;
}
static void StartShopVote()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_ShopEncounter, "Shop Encounter Title");
	Vote vote;

	Artifact artifact;
	int ingots = Rogue_GetIngots();
	int length = ShopListing.Length;
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
		}
	}

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	Rogue_StartGenericVote(30.0);
}
public void Rogue_Vote_ShopEncounter(const Vote vote)
{
	int index = StringToInt(vote.Config);
	if(index != -1)
	{
		Artifact artifact;
		ShopListing.GetArray(index, artifact);
		ShopListing.Erase(index);

		Rogue_GiveNamedArtifact(artifact.Name);

		if(FirstSuperSale && index == 0)
		{
			FirstSuperSale = false;
			Rogue_AddIngots(-artifact.ShopCost * 7 / 10);
		}
		else
		{
			Rogue_AddIngots(-artifact.ShopCost);
		}

		StartShopVote();
		Rogue_SetProgressTime(35.0, false);
	}
	else
	{
		delete ShopListing;
	}
}

public float Rogue_Encounter_Boons()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_ItemEncounter, "Boons Encounter Title");
	Vote vote;

	Artifact artifact;
	int index = Rogue_GetRandomArtfiact(artifact, true);
	if(index != -1)
	{
		strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		IntToString(index, vote.Config, sizeof(vote.Config));
		list.PushArray(vote);
	}

	index = Rogue_GetRandomArtfiact(artifact, true);
	if(index != -1)
	{
		strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		IntToString(index, vote.Config, sizeof(vote.Config));
		list.PushArray(vote);
	}

	if(!list.Length)
	{
		strcopy(vote.Name, sizeof(vote.Name), "There's nothing here?");
		strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
		IntToString(-1, vote.Config, sizeof(vote.Config));
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_ItemEncounter(const Vote vote)
{
	if(StringToInt(vote.Config) != -1)
		Rogue_GiveNamedArtifact(vote.Name);
}

public float Rogue_Encounter_SwordInStone()	// Note: Occurs in Floor 4
{
	PrintToChatAll("%t", "Sword and Stone Lore");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_SwordInStone, "Lore Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Sword and Stone Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Brokenblade");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Sword and Stone Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Blademace");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Sword and Stone Option 3");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_SwordInStone(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Sword and Stone Lore 1");
		}
		case 1:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Sword and Stone Lore 2");
		}
		default:
		{
			PrintToChatAll("%t", "Sword and Stone Lore 3");
		}
	}
}

public float Rogue_Encounter_Theatrical()
{
	PrintToChatAll("%t", "Theatrical Lore");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Theatrical, "Lore Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Theatrical Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Theatrical Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Theatrical Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_Theatrical(const Vote votee, int index)
{
	switch(index)
	{
		case 0:
		{
			PrintToChatAll("%t", "Theatrical Lore 1");

			Ammo_Count_Ready -= 10;

			ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_ItemEncounter, "Lore Title");
			Vote vote;

			strcopy(vote.Name, sizeof(vote.Name), "Right Eye of the Natator");
			strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
			list.PushArray(vote);

			strcopy(vote.Name, sizeof(vote.Name), "Left Eye of the Natator");
			strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
			list.PushArray(vote);

			Rogue_StartGenericVote(20.0);
		}
		default:
		{
			PrintToChatAll("%t", "Theatrical Lore 2");
		}
	}
}

public float Rogue_Encounter_Eccentric()	// Note: Occurs in Floor 4
{
	PrintToChatAll("%t", "Eccentric Lore");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_EccentricCost, "Lore Title");
	Vote vote;

	if(Rogue_GetIngots() > 3)
	{
		strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 1");
		strcopy(vote.Desc, sizeof(vote.Desc), "Eccentric Desc 1");
		list.PushArray(vote);
	}

	strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_EccentricCost(const Vote votee, int index)
{
	if(!index && Rogue_GetIngots() > 3)
	{
		PrintToChatAll("%t", "Eccentric Lore 1");

		Rogue_AddIngots(-4);

		ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_EccentricItem, "Lore Title");
		Vote vote;

		strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 1-1");
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
		strcopy(vote.Config, sizeof(vote.Config), "Shadow");
		list.PushArray(vote);

		strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 1-2");
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
		strcopy(vote.Config, sizeof(vote.Config), "Bladedance");
		list.PushArray(vote);

		strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 1-3");
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
		strcopy(vote.Config, sizeof(vote.Config), "Whiteflower");
		list.PushArray(vote);

		strcopy(vote.Name, sizeof(vote.Name), "Eccentric Option 1-4");
		strcopy(vote.Desc, sizeof(vote.Desc), "Eccentric Desc 1-4");
		vote.Config[0] = 0;
		list.PushArray(vote);

		Rogue_StartGenericVote(20.0);
	}
	else
	{
		PrintToChatAll("%t", "Eccentric Lore 2");
	}
}
public void Rogue_Vote_EccentricItem(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Eccentric Lore 1-1");
		}
		case 1:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Eccentric Lore 1-2");
		}
		case 2:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Eccentric Lore 1-3");
		}
		default:
		{
			Rogue_AddIngots(4);
			PrintToChatAll("%t", "Eccentric Lore 1-4");
		}
	}
}

public float Rogue_Encounter_ForcefieldChest()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_ForcefieldChest, "Forcefield Chest Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Unknown Artifact");
	strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
	list.PushArray(vote);

	Artifact artifact;
	if(Rogue_GetRandomArtfiact(artifact, true, 12) != -1)
	{
		strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_ForcefieldChest(const Vote vote, int index)
{
	if(index)
	{
		Rogue_GiveNamedArtifact(vote.Name);
	}
	else
	{
		Artifact artifact;
		if(Rogue_GetRandomArtfiact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(vote.Name);
	}
}

public float Rogue_Encounter_Camp()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Camp, "Camp Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Camp Option");
	strcopy(vote.Desc, sizeof(vote.Desc), "Camp Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_Camp(const Vote vote, int index)
{
	Ammo_Count_Ready += 30;
	PrintToChatAll("%t", "Camp Lore");

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
			StartHealingTimer(client, 0.1, 10.0, 250, false);
	}
	
	for(int i; i < i_MaxcountNpc_Allied; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			StartHealingTimer(entity, 0.1, 10.0, 250, false);
	}
}

public float Rogue_Encounter_CoffinOfEvil()
{
	PrintToChatAll("%t", "Coffin of Evil Lore");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_CoffinOfEvil, "Lore Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Coffin of Evil Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Coffin of Evil Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Coffin of Evil Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Coffin of Evil Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_CoffinOfEvil(const Vote vote, int index)
{
	if(index)
	{
		PrintToChatAll("%t", "Coffin of Evil Lore 2");

		Rogue_AddIngots(4);
	}
	else
	{
		PrintToChatAll("%t", "Coffin of Evil Lore 1");

		Ammo_Count_Ready -= 30;
		Rogue_GiveNamedArtifact("Proof of Friendship");
	}
}

public float Rogue_Encounter_EyeForAnEye()
{
	PrintToChatAll("%t", "Eye for an Eye Lore");

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_EyeForAnEye, "Lore Title");
	Vote vote;

	if(Rogue_HasFriendship())
	{
		strcopy(vote.Name, sizeof(vote.Name), "Eye for an Eye Option 1");
		strcopy(vote.Desc, sizeof(vote.Desc), "Eye for an Eye Desc 1");
		list.PushArray(vote);
	}

	strcopy(vote.Name, sizeof(vote.Name), "Eye for an Eye Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Eye for an Eye Desc 2");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Eye for an Eye Option 3");
	strcopy(vote.Desc, sizeof(vote.Desc), "Eye for an Eye Desc 3");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_EyeForAnEye(const Vote vote, int index)
{
	int choice = index;
	if(!Rogue_HasFriendship())
		choice++;
	
	switch(choice)
	{
		case 0:
		{
			Rogue_AddIngots(20);
			
			PrintToChatAll("%t", "Eye for an Eye Lore 1");
		}
		case 1:
		{
			Ammo_Count_Ready -= 20;

			CurrentCash += 1500;
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					CashRecievedNonWave[client] += 1500;
				}
			}

			PrintToChatAll("%t", "Eye for an Eye Lore 2");
		}
		default:
		{
			Ammo_Count_Ready += 30;

			PrintToChatAll("%t", "Eye for an Eye Lore 3");
		}
	}
}