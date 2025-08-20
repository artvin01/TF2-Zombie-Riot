#pragma semicolon 1
#pragma newdecls required

public float Rogue_Encounter_GamemodeHistory()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_GamemodeHistory, "Gamemode History Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Gamemode History Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Gamemode History Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Gamemode History Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Gamemode History Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_GamemodeHistory(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_GiveNamedArtifact("Gamemode History", true);
		}
		case 1:
		{
			GiveCash(10000);
			PrintToChatAll("%t", "Gamemode History Lore 2");
		}
	}
}

public float Rogue_Encounter_PoisonWater()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_PoisonWater, "Poison Water Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Poison Water Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Poison Water Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Poison Water Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Poison Water Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_PoisonWater(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			GiveCash(2000);
			PrintToChatAll("%t", "Poison Water Lore 1");
		}
		case 1:
		{
			GiveCash(2000);

			Artifact artifact;
			if(Rogue_GetRandomArtifact(artifact, true) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);

			if(GetURandomInt() % 2)
			{
				PrintToChatAll("%t", "Poison Water Lore 2a");
			}
			else
			{
				PrintToChatAll("%t", "Poison Water Lore 2b");
				Rogue_GiveNamedArtifact("Poisoned Water");
			}
		}
	}
}

public float Rogue_Encounter_MagicFactory()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_MagicFactory, "Magic Factory Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Magic Factory Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Magic Factory Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Magic Factory Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Magic Factory Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_MagicFactory(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			static const char Hands[][] =
			{
				"Hand of Predation",
				"Hand of Rumble",
				"Hand of Choker",
				"Hand of Snatcher",
				"Hand of Spark",
				"Hand of Buckler",
				"Hand of Undulation",
				"Hand of Mystery",
				"Hand of Flowing Water",
				"Hand of Diffusion",
				"Hand of Rending",
				"Hand of Fisticuffs",
				"Hand of Superspeed",
				"Hand of Fireworks",
				"Hand of Pulverization",
				"Hand of Revenging",
				"Hand of Purification",
				"Hand of Protraction"
			};

			Rogue_GiveNamedArtifact(Hands[GetURandomInt() % sizeof(Hands)]);
		}
		case 1:
		{
			GiveCash(2000);

			Artifact artifact;
			if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
		}
	}
}

static void GiveCash(int cash)
{
	CurrentCash += cash;
	CPrintToChatAll("{green}%t", "Cash Gained!", cash);
}