#pragma semicolon 1
#pragma newdecls required

static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};


public void Weapon_Magic_Restore(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if(CurrentAmmo[client][Ammo_Hand_Grenade] >= 1)
		{
			Give_bomb_back[client] = CreateTimer(60.0 * CooldownReductionAmount(client), Give_Back_Magic_Restore, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(60.0 * CooldownReductionAmount(client), Give_Back_Magic_Restore_Ammo, client, TIMER_FLAG_NO_MAPCHANGE);
		//	CreateTimer(59.5, ResetWeaponAmmoStatus, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
			GrenadeApplyCooldownHud(client, 60.0);
			if(Handle_on[client])
			{
				delete Give_bomb_back[client];
			}
		//	SetDefaultHudPosition(client);
		//	SetGlobalTransTarget(client);
		//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Drank Mana Regen Potion");
			SetAmmo(client, Ammo_Hand_Grenade, 0); //Give ammo back that they just spend like an idiot
			CurrentAmmo[client][Ammo_Hand_Grenade] = 0;
			Handle_on[client] = true;
			
			f_TempCooldownForVisualManaPotions[client] = GetGameTime() + (60.0 * CooldownReductionAmount(client));
			
				
			ManaCalculationsBefore(client);
			if(Current_Mana[client] < RoundToCeil(max_mana[client]))
			{
				Current_Mana[client] += RoundToCeil(max_mana[client]);
					
				if(Current_Mana[client] > RoundToCeil(max_mana[client])) 	//Dont drink it if youre full already idiot
					Current_Mana[client] = RoundToCeil(max_mana[client]);
			}
				
			EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		}
		else
		{
			float Ability_CD = f_TempCooldownForVisualManaPotions[client] - GetGameTime();
		
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
}

public void MagicRestore_MapStart()
{
	PrecacheSound("player/pl_scout_dodge_can_drink.wav");
	Zero(Handle_on);
}

public void Reset_stats_Drink_Singular(int client)
{
	Handle_on[client] = false;
}
public Action Give_Back_Magic_Restore_Ammo(Handle cut_timer, int client)
{
	if(!IsValidClient(client))
		CurrentAmmo[client][Ammo_Hand_Grenade] = 1;
		
	return Plugin_Handled;
}
public Action Give_Back_Magic_Restore(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Hand_Grenade, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Hand_Grenade] = 1;
	//	ClientCommand(client, "playgamesound items/gunpickup2.wav");
	//	SetDefaultHudPosition(client);
	//	SetGlobalTransTarg77et(client);
	//	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Mana Regen Potion Back");
		Handle_on[client] = false;
	}
	return Plugin_Handled;
}
