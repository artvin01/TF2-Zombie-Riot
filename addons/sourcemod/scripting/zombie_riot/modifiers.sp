#pragma semicolon 1
#pragma newdecls required

static bool MaxMiniBoss;

void Modifier_MiniBossSpawn(bool &spawns)
{
	if(MaxMiniBoss)
		spawns = true;
}

public void Modifier_Collect_MaxMiniBoss()
{
	MaxMiniBoss = true;
}

public void Modifier_Remove_MaxMiniBoss()
{
	MaxMiniBoss = false;
}