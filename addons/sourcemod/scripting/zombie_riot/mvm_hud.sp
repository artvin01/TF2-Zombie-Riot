#pragma semicolon 1
#pragma newdecls required

void CreateMVMPopulator()
{
	//find populator
	int populator = -1;
	FindEntityByClassname(populator, "info_populator");
	if(populator != i_MVMPopulator)
	{
		if(!IsValidEntity(populator))
			populator = CreateEntityByName("info_populator");

		i_MVMPopulator = populator;

		//Disables thinking.
		SetEntityFlags(i_MVMPopulator, GetEntityFlags(i_MVMPopulator)|4194304);
		GameRules_SetProp("m_iRoundState", 10);
		GameRules_SetProp("m_bPlayingMannVsMachine", true);
		GameRules_SetProp("m_bPlayingSpecialDeliveryMode", true);
	}
}