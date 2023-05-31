public void Rouge_Vote_Encounter(const Vote vote)
{
	if(vote.Config[0])
	{
		Rouge_StartThisBattle();
	}
	else
	{
		Rouge_NextProgress();
	}
}

public float Rouge_Encounter_OptionalBattle()
{
	ArrayList list = Rouge_CreateGenericVote(Rouge_Vote_Encounter, "Optional Battle Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "We can handle this");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	vote.Config[0] = 1;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Better leave now");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rouge_StartGenericVote();

	return 30.0;
}