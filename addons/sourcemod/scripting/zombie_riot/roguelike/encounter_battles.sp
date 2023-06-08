public void Rogue_Vote_BattleEncounter(const Vote vote)
{
	if(vote.Config[0])
		Rogue_StartThisBattle();
}

public float Rogue_Encounter_OptionalBattle()
{
	Rogue_SetBattleIngots(8);

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Optional Battle Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "We can handle this");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	vote.Config[0] = 1;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Better leave now");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}

public float Rogue_Encounter_HardBattle()
{
	Rogue_SetBattleIngots(4 + (Rogue_GetRound() / 2));
	return 0.0;
}

public float Rogue_Encounter_CrimsonTroupe()
{
	Rogue_SetBattleIngots(5 + (Rogue_GetRound() / 2));

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Crimson Troupe Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Let's check out this show");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	vote.Config[0] = 1;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Better leave now");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}