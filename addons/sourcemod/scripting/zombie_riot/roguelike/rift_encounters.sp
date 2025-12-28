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
			int Disable = ReturnFoundEntityViaName("computer_off_stage");
			if(IsValidEntity(Disable))
				AcceptEntityInput(Disable, "Disable");

			CreateTimer(15.0, Timer_Rogue_DisableScreenAgain);
			Rogue_GiveNamedArtifact("Gamemode History", true);
			GiveCash(5000);
		}
		case 1:
		{
			GiveCash(10000);
			PrintToChatAll("%t", "Gamemode History Lore 2");
		}
	}
}
static Action Timer_Rogue_DisableScreenAgain(Handle timer, int progress)
{
	int Disable = ReturnFoundEntityViaName("computer_off_stage");
	if(IsValidEntity(Disable))
		AcceptEntityInput(Disable, "Enable");
	return Plugin_Stop;
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
	Format(vote.Append, sizeof(vote.Append), "");
	vote.Locked = false;
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
			Rogue_AddUmbral(5, false);
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
	list.PushArray(vote);
	
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
			Rogue_GiveNamedArtifact("Incorruptable Leaf");
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
	list.PushArray(vote);
	
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
	list.PushArray(vote);
	
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
			Artifact artifact;
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

public float Rogue_Crystalized_Warped_Subjects()
{

	ArrayList list = Rogue_CreateGenericVote(Rogue_Crystalized_Warped_Subjects_Vote, "Crystalized Warped Subjects Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Crystalized Warped Subjects Search Cancel");
	strcopy(vote.Desc, sizeof(vote.Desc), "Crystalized Warped Subjects Search Cancel Desc");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Crystalized Warped Subjects Search More");
	strcopy(vote.Desc, sizeof(vote.Desc), "Crystalized Warped Subjects Search More Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(15.0);

	return 25.0;
}

public void Rogue_Crystalized_Warped_Subjects_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			GiveCash(7000);
			Artifact artifact;
			if(Rogue_GetRandomArtifact(artifact, true) != -1)
				Rogue_GiveNamedArtifact(artifact.Name);
		}
		case 1:
		{
			Rogue_Crystalized_Warped_Subjects_Repeat();
		}
	}
}
static Action Timer_AdvanceGulnLore(Handle timer, int progress)
{
	switch(progress)
	{
		case 1:
		{
			CPrintToChatAll("{white}밥 {default}: 아... 이건... {crimson} 굴른...");
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{gold}Omega{default}: 굴른... 썅.");
		}
		case 2:
		{
			CPrintToChatAll("{snow}밥이 굴른의 결정화된 머리를 보면서 힘없이 고개를 떨군다.");
			if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
				CPrintToChatAll("{purple}비히시스{default}: 그는 고지식한 자였지만, 이건... 이건 정말 전례가 없는 죽음이로군.");
		}
		case 3:
		{
			CPrintToChatAll("{snow}그는 몸 가까이에 떨어져있는 종이를 읽으면서 주먹을 꽉 쥔다.");
		}
		case 4:
		{
			CPrintToChatAll("{snow}그는 결정화된 몸체를 지탱하던 기반을 부수고 그를 들어올린다.");
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{gold}Omega{default}: 밥, 그 종이에 뭐라고 적혀있었어?");
		}
		case 5:
		{
			CPrintToChatAll("{snow}그가 방을 나간다.");
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
				{
					SmiteNpcToDeath(other);
					break;
				}
			}
			Rogue_RemoveNamedArtifact("Bob's Assistance");
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{gold}오메가{default}: 밥, 어디 가는거야?");
		}
		case 6:
		{
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{purple}비히시스{default}와 {gold}오메가{default}는 종이를 주워 읽어본다:");
			else
				CPrintToChatAll("{snow}당신은 떨어져있는 종이를 주워 읽어본다:");
		}
		case 7:
		{
			CPrintToChatAll("{grey}굴른, 우린 완전히 포위됐어. 나도 포위됐고. 엄브랄의 세력이 너무 강해. 너라도 도망쳐야해. 지금 당장! 내가 저들을 막고 있을게!");
		}
		case 8:
		{
			CPrintToChatAll("{grey}내가 만들어줬던 것들 기억나? 계속 가지고 있어. 널 구해줄 지도 모르니까. 하지만 우린 이제 끝난 것 같아.");
		}
		case 9:
		{
			CPrintToChatAll("{grey}네가 두 번이나 죽음을 모면했던 거 기억해? 다시 한번 해줄 수 있어? 날 위해서?");
		}
		case 10:
		{
			CPrintToChatAll("{grey}그리고, 밥을 냅두고 너 혼자 죽지 마. 화내지 말고, 평소처럼 긍정적으로 생각해, 알았지?");
		}
		case 11:
		{
			CPrintToChatAll("{grey}만약에... 아니, 다음에 우리 다시 만날 때, 네가 그렇게 좋아했던 케이크 레시피를 꼭 줄게. 약속할게.");
		}
		case 12:
		{
			CPrintToChatAll("{crimson}-칼춤");
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{purple}비히시스{default}와 {gold}오메가{default}가 크게 동요하고 있다.");
		}
		case 13:
		{
			CPrintToChatAll("{crimson}당신은 아무것도 얻지 못한 채 방을 나섭니다...");
			
			if(!Rogue_HasNamedArtifact("Immensive Guilt"))
				Rogue_GiveNamedArtifact("Immensive Guilt", false, true);
			GiveCash(4000);

			return Plugin_Stop;
		}
	}
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client); //This is actually more expensive then i thought.
			SetMusicTimer(client, GetTime() + 10);
		}
	}
	Rogue_SetProgressTime(10.0, false);
	CreateTimer(4.5, Timer_AdvanceGulnLore, progress + 1);
	return Plugin_Continue;
}
public void Rogue_ImmensiveGuilt_FloorChange(int &floor, int &stage)
{
	if(Rogue_HasNamedArtifact("Immensive Guilt"))
		Rogue_RemoveNamedArtifact("Immensive Guilt");
	if(!Rogue_HasNamedArtifact("Bob's Wrath"))
		Rogue_GiveNamedArtifact("Bob's Wrath", false, true);
	if(!Rogue_HasNamedArtifact("Bob's Assistance"))
		Rogue_GiveNamedArtifact("Bob's Assistance", true, true);

	CPrintToChatAll("{snow}밥이 돌아왔다.");
	CPrintToChatAll("{white}밥 {default}: ...");
	if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
	{
		CPrintToChatAll("{gold}오메가{default}: 우린 굴른의 복수를 해야해. 반드시.");
		CPrintToChatAll("{purple}비히시스{default}: 우리 셋은 반드시 승리해야한다. 우리의 동지를 위해서.");
	}
}
public void Rogue_Crystalized_Warped_Subjects_Repeat()
{
	if((GetURandomInt() % 4) == 0)
	{
		CPrintToChatAll("{snow}시체들 속에서, 무언가 익숙한 인물이 보이는걸 알아차립니다...");
		CreateTimer(4.0, Timer_AdvanceGulnLore, 1);
		return;	
	}
	Rogue_GiveNamedArtifact("Bad Lab Air");
	ArrayList list = Rogue_CreateGenericVote(Rogue_Crystalized_Warped_Subjects_Vote, "Crystalized Warped Subjects Title Repeat");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Crystalized Warped Subjects Search Cancel");
	strcopy(vote.Desc, sizeof(vote.Desc), "Crystalized Warped Subjects Search Cancel Desc");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Crystalized Warped Subjects Search More");
	strcopy(vote.Desc, sizeof(vote.Desc), "Crystalized Warped Subjects Search More Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(10.0);
	Rogue_SetProgressTime(15.0, false);
}
public float Rogue_Encounter_Rogue3Gamble()
{
	int Disable = ReturnFoundEntityViaName("gambling_machine");
	if(IsValidEntity(Disable))
		AcceptEntityInput(Disable, "Enable");
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
			if(!vote.Config[0])
				Rogue_AddUmbral(15);
			
			PrintToChatAll("%t", "Rouge3 Gamble Lore 2");
			int Disable = ReturnFoundEntityViaName("gambling_machine");
			if(IsValidEntity(Disable))
				AcceptEntityInput(Disable, "Disable");
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
					
					int Disable = ReturnFoundEntityViaName("gambling_machine");
					if(IsValidEntity(Disable))
						AcceptEntityInput(Disable, "Disable");
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

public float Rogue_Encounter_WhiteflowerBladedance()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_WhiteflowerBladedance, "Finale Encounter Lore");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Finale Encounter Option 1");
	strcopy(vote.Desc, sizeof(vote.Desc), "Finale Encounter Desc 1");
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Finale Encounter Option 2");
	strcopy(vote.Desc, sizeof(vote.Desc), "Finale Encounter Desc 2");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}
public void Rogue_Vote_WhiteflowerBladedance(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			Rogue_AddExtraStage(1);
			PrintToChatAll("%t", "Finale Encounter Lore 1");
		}
		case 1:
		{
			GiveCash(5000);
			Rogue_GiveNamedArtifact("The Shadow");
			Rogue_GiveNamedArtifact("The Bladedance");
			Rogue_GiveNamedArtifact("The Whiteflower");
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
	vote.Append[0] = 0;
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
		"챕터 1: 마제트의 구원",
		"수천 년 전, 주민들이 아일린이라고 부르는 행성이 있었다.",
		"엑스피돈사라고 불리는 필라인들이 그곳에 살며 행성을 보살폈다.",
		"그들은 자신들의 지능과 기술을 이용해 동물들과 자연을 보호했다.",
		"하지만 행성 외부에서 문제가 발생했다. 감염이 퍼져나가기 시작한 것이다.",
		"공허라고 불리우는 감염이, 행성에서 행성으로 퍼져나가며, 제멋대로 생명을 파괴했다.",
		"엑스피돈사는 그것도 전부 예견했고, 자신들을 보호할 힘도 있었다.",
		"하지만 그렇다고 해서 다른 종들을 죽게 내버려둘 수는 없었다.",
		"그래서 그들은 우주로 나아가며 가능한 모든 종족을 구해냈다.",
		"지능이 없든 있든간에, 최대한 많은 종족을 구해내었다. 심지어 자연물조차도 말이다.",
		"이렇게 구해낸 자들은 그들의 고향 행성으로 복귀시켜 보금자리를 마련해 주었다.",
		"그리고 퍼져나가는 공허로부터 안전하게 보호해주었다."
	};

	static const char Chapter2[][] =
	{
		"챕터 2 : 마제트의 삶",
		"엑스피돈사인들이 다른 종족들을 구해낸건 좋은데, 그 다음엔 어떻게 되었을까?",
		"그들은 하나의 도시를 건설했고, 그 도시의 이름은...,",
		"마제트 였습니다.",
		"모두가 함께 살며 자신들이 가진 자원을 공유할 수 있는 거대한 도시.",
		"공허는 아일린에 접근조차 못 했고, 그와 동시에 누구도 아일린을 떠날 수 없었다.",
		"아일린에 사는 모든 생명체의 거대한 생명력으로 형성된 이 안전지대는 자연의 선물 그 자체였다.",
		"엑스피돈사는 이 종족들과 협력하여 해결책을 찾기를 바랬다.",
		"공허에 맞서 싸우고 그들의 세계를 구원할 해결책을 말이다.",
		"하지만 엑스피돈사가 바랬던 모든 것이 무너지기 시작했다."
	};

	static const char Chapter3[][] =
	{
		"챕터 3 : 마제트의 몰락",
		"마제트는 모든 종족을 위한 평화로운 도시로 계획되었지만,",
		"정작 그들은 사이 좋게 지내지 못 했다.",
		"종족, 언어, 문화 간의 의견 차이로 갈등이 고조되기 시작했고,",
		"그 갈등은 며칠, 몇 주, 몇 달마다 점점 커져갔다.",
		"급기야 마제트 전역에 내전이 발발했고, 각 종족들은 흩어지면서 역사 속으로 사라졌다.",
		"엑스피돈사는 이런 결과를 예측할 만큼 현명하지 못했다.",
		"그들이 이 사태에서 과연 무엇을 할 수 있었을까?",
		"엑스피돈사인들의 연구 자료는 전쟁의 불길로 전부 불살라졌다.",
		"엑스피돈사인들의 도시는 새로운 종족들의 폭동으로 인해 점령되었다.",
		"엑스피돈사인들은 전쟁에 익숙하지 않은 탓에, 전부 도주했다.",
		"그래도 그들은 재건이 가능할 정도로 지식이 뛰어났고, 그래서 재건했다.",
		"아무도 찾을 수 없는 지하 속에 말이다. 그리고 결국 잊혀졌다.",
		"그들이 무엇을 탄생시켰는지조차 잊은 것처럼.",
		"예측하지 못 한 결과. 그로 인해 탄생한 것의 명칭은...",
		"혼돈."
	};

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
			if(i <= progress && i > (progress - 4))
			{
				switch(chapter)
				{
					case 0:
						panel.DrawText(Chapter1[i]);
					
					case 1:
						panel.DrawText(Chapter2[i]);
					
					case 2:
						panel.DrawText(Chapter3[i]);
				}
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

		delete panel;

		CreateTimer(6.0, Timer_AdvanceStory, progress + 1);
		Rogue_SetProgressTime(15.0, false);
	}

	return Plugin_Continue;
}
static int StoryMenuH(Menu menu, MenuAction action, int param1, int param2)
{
	return 0;
}






public float Rogue_Encounter_Library_Of_Lixandria()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Encounter_Library_Of_Lixandria_Vote, "Library Of Lixandria Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Book of Weakness");
	strcopy(vote.Desc, sizeof(vote.Desc), "Book of Weakness Desc");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Book of Nature");
	strcopy(vote.Desc, sizeof(vote.Desc), "Book of Nature Desc");
	list.PushArray(vote);

	bool ColdWaterItem = Rogue_HasNamedArtifact("Cold Water");
	strcopy(vote.Name, sizeof(vote.Name), "Book of Liver Optimisation");
	strcopy(vote.Desc, sizeof(vote.Desc), "Book of Liver Optimisation Desc");
	if(!ColdWaterItem)
	{
		vote.Locked = true;
		FormatEx(vote.Append, sizeof(vote.Append), " (Need ''Cold Water'')");
	}
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}


public void Rogue_Encounter_Library_Of_Lixandria_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			CPrintToChatAll("%t", "Book of Weakness Conclusion");
			Rogue_GiveNamedArtifact("Book of Weakness");
		}
		case 1:
		{
			CPrintToChatAll("%t", "Book of Nature Conclusion");
			Rogue_GiveNamedArtifact("Book of Nature");
		}
		case 2:
		{
			CPrintToChatAll("%t", "Book of Liver Optimisation Conclusion");
			Rogue_GiveNamedArtifact("Book of Liver Optimisation");
		}
	}
}

public float Rogue_Encounter_OmegaVhxis()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_OmegaVhxis_Vote, "Omega and Vhxis Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Omega and Vhxis Accept");
	strcopy(vote.Desc, sizeof(vote.Desc), "Omega and Vhxis Accept Desc");
	list.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Omega and Vhxis Decline");
	strcopy(vote.Desc, sizeof(vote.Desc), "Omega and Vhxis Decline Desc");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}

static int OmegaYappingVhxisGroupChat;

public void Rogue_Vote_OmegaVhxis_Vote(const Vote vote, int index)
{
	switch(index)
	{
		case 0:
		{
			CPrintToChatAll("%t", "Omega and Vhxis Accept Conlusion");
			Rogue_GiveNamedArtifact("Omega's Assistance");
			Rogue_GiveNamedArtifact("Vhxis' Assistance");
			Rogue_StartThisBattle(5.0);
			OmegaYappingVhxisGroupChat = GetRandomInt(0,1);
			CreateTimer(5.0, Timer_OmegaVhxisYapping, 1);
		}
		case 1:
		{
			CPrintToChatAll("%t", "Omega and Vhxis Decline Conlusion");
			GiveCash(8000);
		}
	}
}
static Action Timer_OmegaVhxisYapping(Handle timer, int progress)
{
	switch(OmegaYappingVhxisGroupChat)
	{
		case 0:
		{
			switch(progress)
			{
				case 1:
				{
					CPrintToChatAll("{gold}오메가{default}: 좋아, 비히시스, 가서 저 놈들 대갈통을 깨주자고. 저 미친 깡통들이 아직도 그 배신자를 따르다니 정말 어이가 없어.");
				}
				case 2:
				{
					CPrintToChatAll("{purple}비히시스{default}: 그래, 당연하지... 잠깐, 배신자? 누가?");
				}
				case 3:
				{
					CPrintToChatAll("{gold}오메가{default}: 너도 알잖아? 배풍등. 그 미친 또라이. 그 놈이 만든 군대가 한두개가 아니었잖아.");
				}
				case 4:
				{
					CPrintToChatAll("{purple}비히시스{default}: 그 이름은 낯설군. 일단 저 놈들부터 처리하고 왕좌에 집중하는게 좋을것 같다. 이 모든 게 잠잠해지면 더 자세히 말해줘라.");
				}
				case 5:
				{
					CPrintToChatAll("{gold}오메가{default}: 알았어. 뭐 이건 얘기하자면 긴 이야기가 될테니 말이지.");
					return Plugin_Stop;
				}
			}
		}
		case 1:
		{
			switch(progress)
			{
				case 1:
				{
					CPrintToChatAll("{purple}비히시스{default}: 제길, 이놈들이 도대체 어디서 이렇게 몰려오는거지?");
				}
				case 2:
				{
					CPrintToChatAll("{gold}오메가{default}: 그러게 말이다? 그 배풍등놈한테 이렇게나 인생을 바쳐줄 사람들이 많다니, 어이가 없지.");
				}
				case 3:
				{
					CPrintToChatAll("{purple}비히시스{default}: 누구...라고? 그 이름은 좀 낯선데.");
				}
				case 4:
				{
					CPrintToChatAll("{gold}Omega{default}: 젠장, 배풍등이 누군지 모르는거야? 일단 왕좌에 관련된 일이 끝나면 자세히 말해줄게. 지금은 좀 바쁠것 같아.");
				}
				case 5:
				{
					CPrintToChatAll("{purple}비히시스{default}: 좋다.");
					return Plugin_Stop;
				}
			}
		}
	}
	CreateTimer(6.5, Timer_OmegaVhxisYapping, progress + 1);
	return Plugin_Continue;
}