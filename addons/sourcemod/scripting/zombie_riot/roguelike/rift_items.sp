#pragma semicolon 1
#pragma newdecls required

static int PreviousFloor;
static int PreviousStage;

public void Rogue_GamemodeHistory_Collect()
{
	PreviousFloor = -1;
	int floor = Rogue_GetFloor();
	int stage = Rogue_GetStage();

	Rogue_SendToFloor(6, 0);

	PreviousFloor = floor;
	PreviousStage = stage;
}

public void Rogue_GamemodeHistory_FloorChange(int &floor, int &stage)
{
	if(PreviousFloor == -1)
		return;
	
	// Send them back to where they were
	floor = PreviousFloor;
	stage = PreviousStage;
	Rogue_RemoveNamedArtifact("Gamemode History");
}

public void Rogue_GamemodeHistory_StageEnd(bool &victory)
{
	if(!victory)
	{
		// They lost, send them back
		victory = true;
		Rogue_RemoveNamedArtifact("Gamemode History");
		Rogue_SendToFloor(PreviousFloor, PreviousStage, false);
	}
}