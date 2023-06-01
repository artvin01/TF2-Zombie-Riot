public void Rogue_Vote_Encounter(const Vote vote)
{
	if(vote.Config[0])
	{
		Rogue_StartThisBattle();
	}
	else
	{
		Rogue_NextProgress();
	}
}

public float Rogue_Encounter_OptionalBattle()
{
	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_Encounter, "Optional Battle Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "We can handle this");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	vote.Config[0] = 1;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Better leave now");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote();

	return 30.0;
}