#pragma semicolon 1
#pragma newdecls required

public void Weapon_SwordWand(int client, int weapon, bool crit)
{
	int mana_cost;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
		mana_cost = RoundToCeil(TF2Attrib_GetValue(address));

	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
	else
	{
		float damage = 1.0;
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
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