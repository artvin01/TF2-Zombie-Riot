#pragma semicolon 1
#pragma newdecls required

public void Weapon_SwordWand(int client, int weapon, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 0.0));
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
	else
	{
		float damage = Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;

		ApplyTempAttrib(weapon, 2, damage);
	}

	i_IsWandWeapon[weapon] = false;
	RequestFrame(Weapon_SwordWand_Frame, EntIndexToEntRef(weapon));
}

public void Weapon_SwordWand_Frame(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(weapon != -1)
		i_IsWandWeapon[weapon] = true;
}