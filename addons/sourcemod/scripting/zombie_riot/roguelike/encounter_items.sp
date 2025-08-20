#pragma semicolon 1
#pragma newdecls required

static ArrayList ShopListing;
static bool FirstSuperSale;

public float Rogue_Encounter_Shop()
{
	delete ShopListing;
	ShopListing = new ArrayList(sizeof(Artifact));

	Artifact artifact;

	if(GetURandomInt() % 5)
	{
		if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
		{
			FirstSuperSale = true;
			ShopListing.PushArray(artifact);
		}
	}
	else if(Rogue_GetRandomArtifact(artifact, true, 30) != -1)
	{
		ShopListing.PushArray(artifact);
	}

	int ingots = Rogue_GetIngots();

	if(ingots > 7)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 8) != -1)
			ShopListing.PushArray(artifact);
	}

	if(ingots > 11)
	{
		if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
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

	strcopy(vote.Name, sizeof(vote.Name), "Better save up now");
	vote.Append[0] = 0;
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	strcopy(vote.Config, sizeof(vote.Config), "-1");
	list.PushArray(vote);

	Rogue_StartGenericVote(found ? 30.0 : 10.0);
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
			Rogue_AddIngots(-artifact.ShopCost * 7 / 10, true);
		}
		else
		{
			Rogue_AddIngots(-artifact.ShopCost, true);
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
	int index = Rogue_GetRandomArtifact(artifact, true);
	if(index != -1)
	{
		strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
		strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
		IntToString(index, vote.Config, sizeof(vote.Config));
		list.PushArray(vote);
	}

	index = Rogue_GetRandomArtifact(artifact, true);
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
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_SwordInStone, "Sword and Stone Lore");
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
			PrintToChatAll("%t", "Sword and Stone Lore 3a");
			PrintToChatAll("%t", "Sword and Stone Lore 3b");
		}
	}
}

public float Rogue_Encounter_Theatrical()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Theatrical, "Theatrical Lore");
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
			PrintToChatAll("%t", "Theatrical Lore 1a");
			PrintToChatAll("%t", "Theatrical Lore 1b");

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
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_EccentricCost, 	"Eccentric Lore");
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
	GrantAllPlayersCredits_Rogue(450);
	if(!index && Rogue_GetIngots() > 3)
	{
		PrintToChatAll("%t", "Eccentric Lore 1a");
		PrintToChatAll("%t", "Eccentric Lore 1b");

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
	GrantAllPlayersCredits_Rogue(450);
	switch(index)
	{
		case 0:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Eccentric Lore 1-1a");
			PrintToChatAll("%t", "Eccentric Lore 1-1b");
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
	if(Rogue_GetRandomArtifact(artifact, true, 12) != -1)
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
		if(Rogue_GetRandomArtifact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}

public float Rogue_Encounter_CoffinOfEvil()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_CoffinOfEvil, "Coffin of Evil Lore");
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

		Rogue_AddIngots(8);
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
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_EyeForAnEye, "Eye for an Eye Lore");
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
			Rogue_AddIngots(30);
			
			PrintToChatAll("%t", "Eye for an Eye Lore 1");
		}
		case 1:
		{
			Ammo_Count_Ready -= 20;
			
			CurrentCash += 3000;
			GlobalExtraCash += 3000;
			
			PrintToChatAll("%t", "Eye for an Eye Lore 2");
		}
		default:
		{
			Ammo_Count_Ready += 30;

			PrintToChatAll("%t", "Eye for an Eye Lore 3");
		}
	}
}

public float Rogue_Encounter_BrokenCrown()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BrokenCrown, "Broken Crown Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Broken Crown Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Broken Crown Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Broken Crown Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Broken Crown Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_BrokenCrown(const Vote vote, int index)
{
	if(index)
	{
		PrintToChatAll("%t", "Broken Crown Lore 2");

		Rogue_AddIngots(8);
	}
	else
	{
		PrintToChatAll("%t", "Broken Crown Lore 1");

		Rogue_GiveNamedArtifact("Broken Combine Crown");
	}
}

public float Rogue_Encounter_BobResearch()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BobResearch, "Bob Research Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Bob Research Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Bob Research Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_BobResearch(const Vote vote, int index)
{
	if(index)
	{
		PrintToChatAll("%t", "Bob Research Lore 2");
	}
	else
	{
		PrintToChatAll("%t", "Bob Research Lore 1");

		Rogue_GiveNamedArtifact("Bob's Reseach Papers");
	}
}

public float Rogue_Encounter_BobFinal()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BobFinal, "Bob Final Lore");
	Vote vote;

	bool altfinal = Rogue_HasNamedArtifact("Revenge Squad");
	bool LockOut = altfinal;
	bool BeatenBob = false;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && (CvarRogueSpecialLogic.BoolValue || Items_HasNamedItem(client, "Bob's true fear")))
		{
			BeatenBob = true;
			break;
		}
	}
	if(altfinal && !BeatenBob)
	{
		LockOut = false;
	}
	strcopy(vote.Name, sizeof(vote.Name), "Bob Final Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Bob Final Desc 1");
	vote.Locked = LockOut;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Bob Final Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Locked = LockOut;
	list.PushArray(vote);

	if(altfinal)
	{
		if(LockOut)
		{
			//Incase the top ones are locked
			strcopy(vote.Name, sizeof(vote.Name), "Bob Final Option 3");
			strcopy(vote.Desc, sizeof(vote.Desc), "Bob Final Desc 3");
			vote.Locked = false;
			list.PushArray(vote);
		}
		else
		{
			strcopy(vote.Name, sizeof(vote.Name), "Bob Final Option 3 No");
			strcopy(vote.Desc, sizeof(vote.Desc), "Bob Final Option 3 No desc");
			strcopy(vote.Append, sizeof(vote.Append), " (Win against Bladedance)");
			vote.Locked = true;
			list.PushArray(vote);
		}
	}

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_BobFinal(const Vote vote, int index)
{
	GrantAllPlayersCredits_Rogue(1000);

	switch(index)
	{
		case 0:
		{
			PrintToChatAll("%t", "Bob Final Lore 1");

			Rogue_GiveNamedArtifact("Bob's Final Draft");
		}
		case 1:
		{
			PrintToChatAll("%t", "Bob Final Lore 2");
		}
		case 2:
		{
			PrintToChatAll("%t", "Bob Final Lore 3");

			Rogue_GiveNamedArtifact("Bob's Orders");
		}
	}
}

public float Rogue_Encounter_BrokenBridge()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BrokenBridge, "Broken Bridge Title");
	Vote vote;

	if(Rogue_GetIngots() > 2)
	{
		strcopy(vote.Name, sizeof(vote.Name), "Broken Bridge Option 1");
		strcopy(vote.Desc, sizeof(vote.Desc), "Broken Bridge Desc 1");
		list.PushArray(vote);
	}
	
	strcopy(vote.Name, sizeof(vote.Name), "Broken Bridge Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_BrokenBridge(const Vote vote, int index)
{
	if(Rogue_GetIngots() < 3 || index)
	{
		PrintToChatAll("%t", "Broken Bridge Lore 2");
	}
	else
	{
		PrintToChatAll("%t", "Broken Bridge Lore 1");

		Rogue_AddIngots(-3);
		
		Artifact artifact;
		if(Rogue_GetRandomArtifact(artifact, true, 24) != -1 || Rogue_GetRandomArtifact(artifact, true, 18) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}

static void GrantAllPlayersCredits_Rogue(int cash)
{
	cash *= (Rogue_GetFloor()+1);
	CPrintToChatAll("{green}%t","Cash Gained!", cash);
	CurrentCash += cash;
}




public float Rogue_Encounter_Lone_Health()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Lone_Health, "Lone Health Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Lone Health Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Lone Health Accept Desc");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Lone Health Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Lone Health Decline Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}


public void Rogue_Vote_Lone_Health(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_GiveNamedArtifact("Health Pickup");
		}
		case 1:
		{
			CPrintToChatAll("{green}%t","Cash Gained!", 2000);
			CurrentCash += 2000;
			Rogue_AddUmbral(15, false);
		}
	}
}