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
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Missing Mountains Lore 1");
		}
		case 1:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Missing Mountains Lore 2");
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
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Clairvoyance Lore 1");
		}
		case 1:
		{
			Rogue_GiveNamedArtifact(vote.Config);
			PrintToChatAll("%t", "Clairvoyance Lore 2");
		}
		case 3:
		{
			Rogue_GiveNamedArtifact(vote.Config);
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