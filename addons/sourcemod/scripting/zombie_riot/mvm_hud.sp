#pragma semicolon 1
#pragma newdecls required

static int i_MVMPopulator;
void CreateMVMPopulator()
{
	if(i_MVMPopulator == 99999)
		return;
	//find populator
	int populator = FindEntityByClassname(-1, "info_populator");
	
	if(populator == -1 || populator != i_MVMPopulator)
	{
		if(!IsValidEntity(populator))
			populator = CreateEntityByName("info_populator");

		i_MVMPopulator = populator;

		// EFL_NO_THINK_FUNCTION (1 << 22)
		SetEntityFlags(i_MVMPopulator, GetEntityFlags(i_MVMPopulator)|4194304);
	}

	GameRules_SetProp("m_iRoundState", RoundState_BetweenRounds);
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
	GameRules_SetProp("m_bPlayingSpecialDeliveryMode", true);
	mp_tournament.IntValue = 1;
	
}

void MVMHud_Disable()
{
	i_MVMPopulator = 99999;
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
	GameRules_SetProp("m_bPlayingSpecialDeliveryMode", false);
	mp_tournament.IntValue = 0;
}