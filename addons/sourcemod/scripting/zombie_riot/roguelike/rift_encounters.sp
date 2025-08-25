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


public float Rogue_Encounter_Rogue3Gamble()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Rogue3Gamble, "Rouge3 Gamble Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Rouge3 Gamble Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Rouge3 Gamble Option 2a");
	vote.Config[0] = 0;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Rouge3 Gamble Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Rouge3 Gamble Desc 1");
	vote.Locked = Rogue_GetIngots() < 4;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
static void Rogue3Gamble(const char[] title)
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Rogue3Gamble, title);
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Rouge3 Gamble Option 2b");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Rouge3 Gamble Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Rouge3 Gamble Desc 1");
	vote.Locked = Rogue_GetIngots() < 4;
	list.PushArray(vote);

	Rogue_StartGenericVote(10.0);
}
public void Rogue_Vote_Rogue3Gamble(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			if(vote.Config[0])
				Rogue_AddUmbral(15);
			
			PrintToChatAll("%t", "Rouge3 Gamble Lore 2");
		}
		case 1:
		{
			char title;
			switch(GetURandomInt() % 19)
			{
				case 0, 1, 2, 3, 11:
				{
					Rogue_AddIngots(2);
					title = 'b';
				}
				case 4, 5:
				{
					Rogue_AddIngots(-4);

					Artifact artifact;
					if(Rogue_GetRandomArtifact(artifact, true, 6) != -1)
						Rogue_GiveNamedArtifact(artifact.Name);
					
					title = 'e';
				}
				case 6, 7, 8, 9:
				{
					Rogue_AddIngots(-4);

					Artifact artifact;
					if(Rogue_GetRandomArtifact(artifact, true) != -1)
						Rogue_GiveNamedArtifact(artifact.Name);
					
					title = 'c';
				}
				case 10:
				{
					Rogue_AddIngots(26);
					PrintToChatAll("%t", "Rouge3 Gamble Lore 1d");
					return;
				}
				default:
				{
					Rogue_AddIngots(-4);
					title = 'a';
				}
			}

			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "Rouge3 Gamble Lore 1%c", title);
			Rogue3Gamble(buffer);
		}
	}
}

public float Rogue_Encounter_PastLore()
{
	int chapter = 1;
	if(Rogue_HasNamedArtifact("Mazeat Lives"))
	{
		chapter = 3;
	}
	else if(Rogue_HasNamedArtifact("Mazeat Saves"))
	{
		chapter = 2;
	}
	
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_PastLore, "Past Lore Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Past Lore Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Past Lore Desc 1");
	FormatEx(vote.Append, sizeof(vote.Append), "Chapter %d", chapter);
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Past Lore Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Past Lore Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_PastLore(const Vote vote, int index)
{
	Timer_AdvanceStory(null, index == 0 ? 0 : 99);
}

static Action Timer_AdvanceStory(Handle timer, int progress)
{
	int chapter;
	/*if(Rogue_HasNamedArtifact("Mazeat Falls"))
	{
		chapter = 3;
	}
	else */
	if(Rogue_HasNamedArtifact("Mazeat Lives"))
	{
		chapter = 2;
	}
	else if(Rogue_HasNamedArtifact("Mazeat Saves"))
	{
		chapter = 1;
	}

	static const char Chapter1[][] =
	{
		"Chapter 1: Mazeat Saves",
		"Thousands of years ago, a planet named Irln called by it's inhabitants,",
		"felines who were called Expidonsans. They oversaw the planet,",
		"using their intelligence and technology for them, the animals, and the nature.",
		"However something was lose outside the planet, an infection spreading,",
		"traveling planet to planet, destroying life for it's own will, the Void.",
		"The Expidonsans far-saw this, they had the power to defend themselves",
		"but felt they could not watch other races and species die out to this.",
		"And so they ventured out into space, gathering whatever species they could save.",
		"It didn't matter feral, intelligent, nature; they wanted to save as many they can.",
		"They brought them back to their home planet, giving them a home",
		"and safety from the Void that spreads."
	};

	static const char Chapter2[][] =
	{
		"Chapter 2: Mazeat Lives",
		"The Expidonsans saved these other species but what to do with them?",
		"Form a unified city, and that city was eventually called,",
		"Mazeat.",
		"A giant city where all could live together and share what resources they had.",
		"The Void could not enter Irln, and nobody could leave Irln.",
		"A safe bubble formed by the mass life of everyone living on Irln, gift by nature.",
		"Expidonsans had hoped to work with these races to come up with a solution.",
		"A solution to fight back against the Void and save their worlds.",
		"Everything the Expidonsans hoped for, was starting to crack."
	}

	static const char Chapter3[][] =
	{
		"Chapter 3: Mazeat Falls",
		"Mazeat was a city meant to a place of peace for all races,",
		"but they didn't get along.",
		"Conflicts brew, disagreements among races, language, culture.",
		"Fights storm up with the storm growing by the months, weeks, days.",
		"Civil war roared across Mazeat, races spread out, passed away, lost to time.",
		"Expidonsans weren't cleaver enough to foresee this.",
		"What was there to do?",
		"Expidonsan research burned away in the ashes of war.",
		"Expidonsan cities torn away for the new races.",
		"Expidonsans weren't the kind for war, so they flee.",
		"They had the knowledge to rebuild, and so they did,",
		"underground where nobody could find them, eventually forgotten.",
		"Just like how they forgotten themselves, what they made,",
		"the unforeseen consequences, and what we call now,",
		"Chaos."
	}

	int length = chapter == 0 ? sizeof(Chapter1) : (chapter == 1 ? sizeof(Chapter2) : sizeof(Chapter3));
	if(progress >= length)
	{
		switch(chapter)
		{
			case 0:
				Rogue_GiveNamedArtifact("Mazeat Saves");
			
			case 1:
				Rogue_GiveNamedArtifact("Mazeat Lives");
			
			case 2:
				Rogue_GiveNamedArtifact("Mazeat Falls");
		}
	}
	else
	{
		Panel panel = new Panel();

		// Show 4 lines at a time
		for(int i; i < length; i++)
		{
			if(i <= progress && i > (progress - 3))
			{
				panel.DrawText(Chapter1[i]);
			}
			else
			{
				panel.DrawText(" ");
			}
		}

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
				panel.Send(client, StoryMenuH, 15);
		}

		CreateTimer(5.0, Timer_AdvanceStory, progress + 1);
		Rogue_SetProgressTime(15.0, false);
	}
}
static int StoryMenuH(Menu menu, MenuAction action, int param1, int param2)
{
}