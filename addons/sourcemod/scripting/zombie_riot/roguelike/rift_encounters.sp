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
			GiveCash(2000);
			Rogue_AddUmbral(10, false);
		}
	}
}


public float Rogue_Encounter_Astra()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Astra_Vote, "Astra Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Astra Title Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Astra Title Accept Desc");
	int cost = 12;
	int ingots = Rogue_GetIngots();
	Format(vote.Append, sizeof(vote.Append), " △%d", cost);
	vote.Locked = ingots < cost;
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Astra Title Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Astra Title Decline Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}

public void Rogue_Vote_Astra_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			CPrintToChatAll("%t", "Astra Title Accept Conlusion");
			Rogue_GiveNamedArtifact("Mantle of Stars");
			Rogue_AddIngots(-12);
		}
		case 1:
		{
			CPrintToChatAll("%t", "Astra Title Decline Conlusion");
			GiveCash(5500);
			Rogue_AddUmbral(5, false);
		}
	}
}





public float Rogue_Encounter_Incorruptable_Tree()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Incorruptable_Tree_Vote, "Incorruptable Tree Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Incorruptable Tree Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Incorruptable Tree Accept Desc");
	
	strcopy(vote.Name, sizeof(vote.Name), "Incorruptable Tree Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Incorruptable Tree Decline Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}


public void Rogue_Vote_Incorruptable_Tree_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			CPrintToChatAll("%t", "Incorruptable Tree Accept Conlusion");
			Rogue_GiveNamedArtifact("Incorruptable Leal");
			Rogue_AddUmbral(-10, false);
		}
		case 1:
		{
			CPrintToChatAll("%t", "Incorruptable Tree Decline Conlusion");
			GiveCash(5500);
			Rogue_AddUmbral(10, false);
		}
	}
}




public float Rogue_Encounter_BrokenCrest()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BrokenCrest_Vote, "Broken Crest Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Broken Crest Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Broken Crest Accept Desc");
	
	strcopy(vote.Name, sizeof(vote.Name), "Broken Crest Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Broken Crest Decline Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}


public void Rogue_Vote_BrokenCrest_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			CPrintToChatAll("%t", "Broken Crest Accept Conlusion");
			Rogue_GiveNamedArtifact("Lelouch's Broken Crest");
			Rogue_AddUmbral(-15, false);
		}
		case 1:
		{
			CPrintToChatAll("%t", "Broken Crest Decline Conlusion");
			GiveCash(5500);
			Rogue_AddUmbral(5, false);
		}
	}
}





public float Rogue_Encounter_Pool_Of_Clarity()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Pool_Of_Clarity_Vote, "Pool of Clarity Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Pool of Clarity Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Pool of Clarity Desc 1");
	
	strcopy(vote.Name, sizeof(vote.Name), "Pool of Clarity Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Pool of Clarity Desc 2");
	vote.Locked = Rogue_GetIngots() < 10;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
static void Rogue_Vote_Pool_Of_Clarity_Vote(const Vote vote33, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_SetProgressTime(Rogue_Encounter_RiftConsume(), false);
		}
		case 1:
		{
			Rogue_AddIngots(-10);

			ArrayList list = Rogue_CreateGenericVote(PoolOfClarityPost, "Pool of Clarity Lore 2");
			Vote vote;

			ArrayList collection = Rogue_GetCurrentCollection();

			int found;
			if(collection)
			{
				Artifact artifact;
				int length = collection.Length;

				// Misc items
				for(int i = length - 1; i >= 0; i--)
				{
					Rogue_GetCurrentArtifacts().GetArray(collection.Get(i), artifact);

					if(!artifact.Hidden && artifact.FuncRemove != INVALID_FUNCTION && !(artifact.Multi || artifact.ShopCost == 6))
					{
						strcopy(vote.Name, sizeof(vote.Name), artifact.Name);
						strcopy(vote.Desc, sizeof(vote.Desc), "Artifact Info");
						strcopy(vote.Config, sizeof(vote.Config), artifact.Name);
						list.PushArray(vote);
						
						if(++found > 6)
							break;
					}
				}
			}

			Rogue_StartGenericVote(20.0);
			Rogue_SetProgressTime(25.0, false);
		}
	}
}
static void PoolOfClarityPost(const Vote vote, int index)
{
	Rogue_RemoveNamedArtifact(vote.Config);
	Rogue_GiveNamedArtifact("Holy Blessing");
}

public float Rogue_Encounter_FreeTreasure()
{

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_FreeTreasure, "Free Treasure Ahead!");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Free Treasure Ahead! Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Free Treasure Ahead! Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}

public void Rogue_Vote_FreeTreasure(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			if(Rogue_GetRandomArtifact(artifact, false, 24) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
			if(Rogue_GetRandomArtifact(artifact, false, 18) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
			Rogue_StartThisBattle(5.0);
			Rogue_SetBattleIngots(20);
		}
		case 1:
		{
			GiveCash(5000);
		}
	}
}


public float Rogue_Encounter_AlmagestTechnology()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_AlmagestTechnology_Vote, "Almagest Technology Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Almagest Technology Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Almagest Technology Accept");
	list.PushArray(vote);

	Rogue_StartGenericVote(10.0);

	return 15.0;
}


public void Rogue_Vote_AlmagestTechnology_Vote(const Vote vote, int index)
{
	Rogue_GiveNamedArtifact("Almagest Technology");
	Rogue_AddUmbral(-25, false);
}
