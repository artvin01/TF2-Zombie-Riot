#pragma semicolon 1
#pragma newdecls required

float RegenPlayerCooldown[MAXPLAYERS];

void MapStartPlotMisc()
{
	Zero(RegenPlayerCooldown);
}
public bool Plots_Resupply(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	if(RegenPlayerCooldown[client] > GetGameTime())
		return false;

	RegenPlayerCooldown[client] = GetGameTime() + 2.0;
	TF2_RegeneratePlayer(client);
	return true;
}

public bool Plots_PlayerMarket(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	char zone[64];
	if(!Plots_ZoneName(client, zone, sizeof(zone)))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	
	TextStore_ForceEnterStore(client, zone, "market");
	return true;
}

public bool Plots_PersonalMarket(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	char zone[64];
	if(!Plots_ZoneName(client, zone, sizeof(zone)))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	
	char id[64];
	int owner = Plots_ZoneOwner(client);
	if(owner)
		GetClientAuthId(owner, AuthId_Steam3, id, sizeof(id));

	TextStore_ForceEnterStore(client, zone, "market", id);
	return true;
}

public bool Plots_CookingMenu(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	Cooking_OpenMenu(client);
	return true;
}