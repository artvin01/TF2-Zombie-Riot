static int weapon_id[MAXPLAYERS+1]={8, ...};
static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};

public void Weapon_Grenade(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		Give_bomb_back[client] = CreateTimer(15.0, Give_Back_Grenade, client, TIMER_FLAG_NO_MAPCHANGE);
		if(Handle_on[client])
		{
			KillTimer(Give_bomb_back[client]);
		}
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Threw Grenade");
		Handle_on[client] = true;
		SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
	}
}


public Action Give_Back_Grenade(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = GetAmmo(client, Ammo_Hand_Grenade);
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Grenade Is Back");
		Handle_on[client] = false;
	}
	return Plugin_Handled;
}
