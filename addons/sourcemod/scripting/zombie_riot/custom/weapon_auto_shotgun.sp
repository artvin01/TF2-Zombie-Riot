#pragma semicolon 1
#pragma newdecls required

static bool has_consumed_ammo_before[MAXPLAYERS+1]={false, ...};

public void Weapon_Auto_Shotgun(int client, int weapon, bool crit, int slot)
{
	if(has_consumed_ammo_before[client])
	{
		Add_Back_One_Clip(weapon);
		has_consumed_ammo_before[client] = false;
	}
	else
	{
		has_consumed_ammo_before[client] = true;
	}
}

void Add_Back_One_Clip(int entity)
{
	if(IsValidEntity(entity))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		ammo += 1;

		SetEntData(entity, iAmmoTable, ammo, 4, true);
	}
}