#pragma semicolon 1
#pragma newdecls required


static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static int attacks_made[MAXPLAYERS+1]={12, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static bool Handle_on[MAXPLAYERS+1]={false, ...};

public void Weapon_Rampager(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = EntIndexToEntRef(weapon);
		attacks_made[client] += -1;
				
		if (attacks_made[client] <= 4)
		{
			attacks_made[client] = 4;
		}
		Attributes_Set(weapon, 396, RampagerAttackSpeed(attacks_made[client]));
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
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
			Attributes_Set((EntRefToEntIndex(weapon_id[client])), 396, RampagerAttackSpeed(attacks_made[client]));
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
	Handle_on[client] = false;
	return Plugin_Handled;
}



float RampagerAttackSpeed(int number)
{
	switch(number)
	{
		case 1:
		{
			return 0.050000;
		} 
		case 2:
		{
			return 0.102811;
		} 
		case 3:
		{
			return 0.156738;
		} 
		case 4:
		{
			return 0.211403;
		} 
		case 5:
		{
			return 0.266623;
		} 
		case 6:
		{
			return 0.322290;
		} 
		case 7:
		{
			return 0.378331;
		} 
		case 8:
		{
			return 0.434693;
		} 
		default:
		{
			return 1.0;
		} 
	}
}