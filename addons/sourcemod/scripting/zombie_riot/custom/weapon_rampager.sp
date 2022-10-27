
static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static int attacks_made[MAXPLAYERS+1]={12, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static bool Handle_on[MAXPLAYERS+1]={false, ...};

public void Weapon_Rampager(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = EntIndexToEntRef(weapon);
		attacks_made[client] += -1;
				
		if (attacks_made[client] <= 4)
		{
			attacks_made[client] = 4;
		}
		TF2Attrib_SetByDefIndex(weapon, 396, (Pow((attacks_made[client] * 1.0), 1.04) / 20.0));
		if(Handle_on[client])
		{
			KillTimer(Revert_Weapon_Back_Timer[client]);
		}
		Revert_Weapon_Back_Timer[client] = CreateTimer(3.0, Reset_weapon_rampager, client, TIMER_FLAG_NO_MAPCHANGE);
		Handle_on[client] = true;
	}
}


public Action Reset_weapon_rampager(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		attacks_made[client] = 8;
		if(IsValidEntity(EntRefToEntIndex(weapon_id[client])))
		{
			TF2Attrib_SetByDefIndex((EntRefToEntIndex(weapon_id[client])), 396, (Pow((attacks_made[client] * 1.0), 1.04) / 20.0));
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
	Handle_on[client] = false;
	return Plugin_Handled;
}
