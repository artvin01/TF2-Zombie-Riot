#pragma semicolon 1
#pragma newdecls required

public void Rogue_Vote_BattleEncounter(const Vote vote)
{
	if(vote.Config[0])
		Rogue_StartThisBattle(5.0);
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

public float Rogue_Encounter_OptionalBattle_Nightmare()
{
	Rogue_SetBattleIngots(8);

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Nightmare Battle Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Stay and find out who is causing it");
	strcopy(vote.Desc, sizeof(vote.Desc), "Enter a special battle");
	vote.Config[0] = 1;
	list.PushArray(vote);

	strcopy(vote.Name, sizeof(vote.Name), "Pinch yourself awake");
	strcopy(vote.Desc, sizeof(vote.Desc), "Leave this encounter");
	vote.Config[0] = 0;
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0;
}

public float Rogue_Encounter_HardBattle()
{
	Rogue_SetBattleIngots(4 + (Rogue_GetFloor() / 2));
	return 0.0;
}

public float Rogue_Encounter_BossBattle()
{
	Rogue_SetRequiredBattle(true);
	Rogue_SetBattleIngots(5 + (Rogue_GetFloor() / 2));
	return 0.0;
}

public float Rogue_Encounter_CrimsonTroupe()
{
	Rogue_SetBattleIngots(15);

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

public float Rogue_Encounter_XenoShaft()
{
	Rogue_SetBattleIngots(15);

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Xeno Shaft Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Investigate the mines");
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

public float Rogue_Encounter_Stultifera()
{
	Rogue_SetBattleIngots(15);

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Stultifera Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Investigate the mines");
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

public float Rogue_Encounter_MedivealAlly()
{
	Rogue_SetBattleIngots(15);

	ArrayList list = Rogue_CreateGenericVote(Rogue_Vote_BattleEncounter, "Mediveal Ally Title");
	Vote vote;

	strcopy(vote.Name, sizeof(vote.Name), "Mediveal Option 1");
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