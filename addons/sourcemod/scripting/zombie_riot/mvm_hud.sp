#pragma semicolon 1
#pragma newdecls required

void CreateMVMPopulator()
{
	//find populator
	int populator = FindEntityByClassname(-1, "info_populator");
	if(populator == -1 || populator != i_MVMPopulator)
	{
		if(!IsValidEntity(populator))
			populator = CreateEntityByName("info_populator");

		i_MVMPopulator = populator;

		//Disables thinking.
		SetEntityFlags(i_MVMPopulator, GetEntityFlags(i_MVMPopulator)|4194304);
	}

	GameRules_SetProp("m_iRoundState", 10);
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
	GameRules_SetProp("m_bPlayingSpecialDeliveryMode", true);
}

void MVMHud_Disable()
{
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
	GameRules_SetProp("m_bPlayingSpecialDeliveryMode", false);
}