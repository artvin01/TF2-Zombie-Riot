#pragma semicolon 1
#pragma newdecls required

static bool InClassicMode;

void Classic_PluginStart()
{
}

bool Classic_Mode()	// If ZS-Classic is enabled
{
	return InClassicMode;
}

void Classic_MapStart()
{
	InRogueMode = false;
}

void Classic_Enable()
{
	InClassicMode = true;
}

bool Classic_CanTeutonUpdate(bool respawn)
{
	if(Classic_Mode() && !respawn)
		return false;

	return true;
}
