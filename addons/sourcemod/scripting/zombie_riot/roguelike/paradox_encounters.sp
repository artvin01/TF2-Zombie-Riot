#pragma semicolon 1
#pragma newdecls required

public float Rogue_Encounter_MissingMountains()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_MissingMountains, "Missing Mountains Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Missing Mountains Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Peek into the Eternal Night");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Missing Mountains Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Dead Tree's Echo");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Missing Mountains Option 3");
	strcopy(vote.Desc, sizeof(vote.Desc), "Missing Mountains Desc 3");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_MissingMountains(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			PrintToChatAll("%t", "Missing Mountains Lore 1");
			Rogue_GiveNamedArtifact(vote.Config);
		}
		case 1:
		{
			PrintToChatAll("%t", "Missing Mountains Lore 2");
			Rogue_GiveNamedArtifact(vote.Config);
		}
		default:
		{
			if(Rogue_GetChaosLevel() > 2)
			{
				PrintToChatAll("%t", "Missing Mountains Lore 3b");
			}
			else
			{
				Rogue_AddIngots(7);
				PrintToChatAll("%t", "Missing Mountains Lore 3a");
			}
		}
	}
}

public float Rogue_Encounter_Clairvoyance()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Clairvoyance, "Clairvoyance Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Clairvoyance Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Frozen Whetstone");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Clairvoyance Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Config Info");
	strcopy(vote.Config, sizeof(vote.Config), "Clairvoyant's Reveal");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Clairvoyance Option 3");
	strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
	vote.Config[0] = 0;
	list.PushArray(vote);

	if(Rogue_HasNamedArtifact("Blue Goggles"))
	{
		strcopy(vote.Name, sizeof(vote.Name), "Clairvoyance Option 4");
		strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
		vote.Config[0] = 0;
		list.PushArray(vote);
	}

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_Clairvoyance(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			PrintToChatAll("%t", "Clairvoyance Lore 1");
			Rogue_GiveNamedArtifact(vote.Config);
		}
		case 1:
		{
			PrintToChatAll("%t", "Clairvoyance Lore 2");
			Rogue_GiveNamedArtifact(vote.Config);
		}
		case 3:
		{
			PrintToChatAll("%t", "Clairvoyance Lore 4");

			Artifact artifact;
			if(Rogue_GetRandomArtfiact(artifact, false, 24) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
		}
		default:
		{
			if(Rogue_GetChaosLevel() > 1)
			{
				PrintToChatAll("%t", "Clairvoyance Lore 3b");
			}
			else
			{
				PrintToChatAll("%t", "Clairvoyance Lore 3a");

				Artifact artifact;
				if(Rogue_GetRandomArtfiact(artifact, false, 24) != -1)
					Rogue_GiveNamedArtifact(artifact.Name);
				
			}
		}
	}
}

public float Rogue_Encounter_Printer()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Printer, "Printer Lore");
	Vote vote;

	ArrayList collection = Rogue_GetCurrentCollection();

	if(collection)
	{
		collection = collection.Clone();
		collection.Sort(Sort_Random, Sort_Integer);
		
		Artifact artifact;
		int found;
		int length = collection.Length;
		for(int i; i < length; i++)
		{
			Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

			if(artifact.FuncCollect == INVALID_FUNCTION &&
			   artifact.FuncRemove != INVALID_FUNCTION)
			{
				strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
				strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
				strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
				list.PushArray(vote);
				
				if(++found > 2)
					break;
			}
		}

		delete collection;
	}

	strcopy(vote.Name, sizeof(vote.Name), "Printer Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_Printer(const Vote vote, int index)
{
	if(vote.Config[0])
	{
		if(Rogue_GetChaosLevel() > 3)
		{
			CPrintToChatAll("%t", "Printer Lore 1b", vote.Config);
			Rogue_RemoveNamedArtifact(vote.Config);
			Rogue_AddIngots(30);
		}
		else
		{
			PrintToChatAll("%t", "Printer Lore 1a");
			Rogue_GiveNamedArtifact(vote.Config);
		}
	}
	else
	{
		PrintToChatAll("%t", "Printer Lore 2");

		Artifact artifact;
		if(Rogue_GetRandomArtfiact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}

public float Rogue_Encounter_WishFulfilled()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_WishFulfilled, "Wish Fulfilled Lore");
	Vote vote;

	Artifact artifact;
	int chaos = Rogue_GetChaosLevel();

	for(int i = 3; i > 0; i--)
	{
		if(chaos > i)
		{
			strcopy(vote.Name, sizeof(vote.Name), "Unknown Artifact");
			strcopy(vote.Desc, sizeof(vote.Desc), "Unknown Artifact Desc");
			vote.Config[0] = 0;
			list.PushArray(vote);
		}
		else if(Rogue_GetRandomArtfiact(artifact, true) != -1)
		{
			strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
			strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
			vote.Config[0] = 1;
			list.PushArray(vote);
		}
	}

	Rogue_StartGenericVote(20.0);

	return 30.0;
}
public void Rogue_Vote_WishFulfilled(const Vote vote, int index)
{
	if(vote.Config[0])
	{
		Rogue_GiveNamedArtifact(vote.Name);
	}
	else
	{
		Artifact artifact;
		if(Rogue_GetRandomArtfiact(artifact, true) != -1)
			Rogue_GiveNamedArtifact(artifact.Name);
	}
}