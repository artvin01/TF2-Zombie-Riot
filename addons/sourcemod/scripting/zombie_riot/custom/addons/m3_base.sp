#pragma semicolon 1
#pragma newdecls required

stock void Addon_OnBombDrop(int entity, const char [] name)
{
	if(!IsValidEntity(entity))
		return;
	if(StrContains(name, "ZR_ReinforcePOD_", false) != -1)
	{
	
	}
}

stock void Addon_M3_Abilities(int client, int slot)
{
	switch(slot)
	{
		case 195:
		{
		}
		case 65:
		{
		}
	}
}

stock void Addon_M3_WaveEnd()
{
	return;
}

stock void Addon_M3_ClearAll()
{
	return;
}