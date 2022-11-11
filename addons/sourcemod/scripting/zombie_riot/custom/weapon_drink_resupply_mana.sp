static Handle Give_bomb_back[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};

public void Weapon_Magic_Restore(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(CurrentAmmo[client][Ammo_Potion_Supply] >= 1)
		{
			Give_bomb_back[client] = CreateTimer(60.0, Give_Back_Magic_Restore, client, TIMER_FLAG_NO_MAPCHANGE);
			if(Handle_on[client])
			{
				KillTimer(Give_bomb_back[client]);
			}
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Drank Mana Regen Potion");
			SetAmmo(client, Ammo_Potion_Supply, 0); //Give ammo back that they just spend like an idiot
			CurrentAmmo[client][Ammo_Potion_Supply] = GetAmmo(client, Ammo_Potion_Supply);
			Handle_on[client] = true;
			
			float max_mana_temp = 400.0;
			f_TempCooldownForVisualManaPotions[client] = GetGameTime() + 60.0;
			

			max_mana_temp *= Mana_Regen_Level[client];	
				
			if(Current_Mana[client] < RoundToCeil(max_mana_temp))
			{
				Current_Mana[client] += RoundToCeil(max_mana_temp);
					
				if(Current_Mana[client] > RoundToCeil(max_mana_temp)) 	//Dont drink it if youre full already idiot
					Current_Mana[client] = RoundToCeil(max_mana_temp);
			}
				
			EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		}
		else
		{
			float Ability_CD = f_TempCooldownForVisualManaPotions[client] - GetGameTime();
		
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
}

public void MagicRestore_MapStart()
{
	PrecacheSound("player/pl_scout_dodge_can_drink.wav");

}

public Action Give_Back_Magic_Restore(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Potion_Supply, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Potion_Supply] = GetAmmo(client, Ammo_Potion_Supply);
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Mana Regen Potion Back");
	}
	Handle_on[client] = false;
	return Plugin_Handled;
}
