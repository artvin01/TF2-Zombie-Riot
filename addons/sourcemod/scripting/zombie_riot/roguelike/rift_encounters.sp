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
			GiveCash(6000);
			PrintToChatAll("%t", "Gamemode History Lore 2");
		}
	}
}

static void GiveCash(int cash)
{
	CurrentCash += cash;
	GlobalExtraCash += cash;
	CPrintToChatAll("{green}%t", "Cash Gained!", cash);
}