#pragma semicolon 1
#pragma newdecls required

static float	 Timetillnextbullet[MAXPLAYERS];
static int		 IsAbilityActive[MAXPLAYERS];
static float		 BulletsLoaded[MAXPLAYERS]={5.0, ...};
static float		 CurrentMaxBullets[MAXPLAYERS];
static int		 IsCurrentlyReloading[MAXPLAYERS];
static float		AttackedRecently[MAXPLAYERS];
static float	 AmmoHudDelay[MAXPLAYERS+1]={0.0, ...};
float reload_speed_bonus[MAXPLAYERS+1]={1.0, ...};
float clip_size_bonus[MAXPLAYERS+1]={1.0, ...};
float temporarythingy[MAXPLAYERS+1]; //we do this so we can round the float to a whole number, we dont want 5,7 bullets being a possibility or everything breaks


Handle	 Timer_Hunting_Rifle_Management[MAXPLAYERS + 1] = { null, ... };

public void Hunting_Rifle_Attack_Main(int client, int weapon, bool crit, int slot)  // stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	clip_size_bonus[client] = Attributes_Get(weapon, 4, 1.0);
	temporarythingy[client] = 5.0 * clip_size_bonus[client];
	RoundToNearest(temporarythingy[client]);
	CurrentMaxBullets[client] = temporarythingy[client];
	BulletsLoaded[client] -= 1.0;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	AttackedRecently[client] = GetGameTime() + 0.5;
}

public void Hunting_Rifle_Attack_Main_PAP1(int client, int weapon, bool crit, int slot)	// stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	clip_size_bonus[client] = Attributes_Get(weapon, 4, 1.0);
	temporarythingy[client] = 7.0 * clip_size_bonus[client];
	RoundToNearest(temporarythingy[client]);
	CurrentMaxBullets[client] = temporarythingy[client];
	BulletsLoaded[client] -= 1.0;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	AttackedRecently[client] = GetGameTime() + 0.5;
}

public void Hunting_Rifle_Attack_Main_PAP2(int client, int weapon, bool crit, int slot)	// stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	clip_size_bonus[client] = Attributes_Get(weapon, 4, 1.0);
	temporarythingy[client] = 9.0 * clip_size_bonus[client];
	RoundToNearest(temporarythingy[client]);
	CurrentMaxBullets[client] = temporarythingy[client];
	BulletsLoaded[client] -= 1.0;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	AttackedRecently[client] = GetGameTime() + 0.5;
}

public void Hunting_Rifle_Ability(int client, int weapon, bool crit, int slot)	   // ability stuff here
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 45.0);
		ClientCommand(client, "playgamesound weapons/recon_ping.wav");
		ApplyTempAttrib(weapon, 2, 2.2, 10.0);					// dmg buff while ability is activated
		IsAbilityActive[client] = 1;							// 1 for enabled, 0 for disabled
		//BulletsLoaded[client]	= CurrentMaxBullets[client];	// insantly fills out clip
		CreateTimer(10.0, Disable_Hunting_Rifle_Ability, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}
public void Hunting_Rifle_Ability2(int client, int weapon, bool crit, int slot)	   // ability stuff here
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 45.0);
		ClientCommand(client, "playgamesound weapons/recon_ping.wav");
		ApplyTempAttrib(weapon, 2, 3.0, 15.0);					// dmg buff while ability is activated
		IsAbilityActive[client] = 1;							// 1 for enabled, 0 for disabled
		//BulletsLoaded[client]	= CurrentMaxBullets[client];	// insantly fills out clip
		CreateTimer(15.0, Disable_Hunting_Rifle_Ability, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public Action Disable_Hunting_Rifle_Ability(Handle timer, int client)
{
	IsAbilityActive[client] = 0;	// 1 for enabled, 0 for disabled
	return Plugin_Handled;
}

public void Enable_Hunting_Rifle(int client, int weapon)	 // gets triggered each time you fire the weapon
{
	if (Timer_Hunting_Rifle_Management[client] != null)
	{
		// This timer already exists.
		if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HUNTING_RIFLE)	 // 125
		{
			// Is the weapon it again?
			// Yes?
			delete Timer_Hunting_Rifle_Management[client];
			Timer_Hunting_Rifle_Management[client] = null;
			DataPack pack;
			Timer_Hunting_Rifle_Management[client] = CreateDataTimer(0.1, Timer_Management_Hunting_Rifle, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}

	if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HUNTING_RIFLE)	 // 125
	{
		DataPack pack;
		Timer_Hunting_Rifle_Management[client] = CreateDataTimer(0.1, Timer_Management_Hunting_Rifle, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Hunting_Rifle(Handle timer, DataPack pack)	  // triggers every 0.1 of a second
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if (!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Hunting_Rifle_Management[client] = null;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		HuntingRifleAmmoDisplay(client); //function to display current ammo in your gun
	}
	// ammo logic here, love how nicely this works :D
	if (BulletsLoaded[client] < CurrentMaxBullets[client])	  // if we have less bullets loaded than our max bullet amount
	{
		if (IsCurrentlyReloading[client] == 0)	  // only trigger if not currently reloading otherwise the timer will reset infinitely
		{
			if (IsAbilityActive[client] == 1)	 // makes the reload quicker if ability is activated
			{
				reload_speed_bonus[client] = Attributes_Get(weapon, 97, 1.0);
				Timetillnextbullet[client] = GetGameTime() + 0.3 * reload_speed_bonus[client];
				IsCurrentlyReloading[client] = 1;
			}
			else
			{
				reload_speed_bonus[client] = Attributes_Get(weapon, 97, 1.0);
				Timetillnextbullet[client] = GetGameTime() + 1.2 * reload_speed_bonus[client];
				IsCurrentlyReloading[client] = 1;
			}
		}

		if (Timetillnextbullet[client] < GetGameTime())
		{
			if(AttackedRecently[client] < GetGameTime())
			{
				BulletsLoaded[client] += 1.0;	   // add 1 ammo
				IsCurrentlyReloading[client] = 0;
				if(weapon_holding == weapon) //Only play if you are holding the weapon, but you can still reload while not equiped
				{
				ClientCommand(client, "playgamesound weapons/default_reload.wav");
				}
			}
			
		}
	}
	if (BulletsLoaded[client] == 0.0)
	{
		TF2Attrib_SetByDefIndex(client, 821, 1.0);	  // makes the weapon unable to fire
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 821, 0.0);	  // makes the user to fire the weapon again
	}
	return Plugin_Continue;
}

void HuntingRifleAmmoDisplay(int client)// ty for code arvan :D
{
	
	if(AmmoHudDelay[client] < GetGameTime())
	{
		AmmoHudDelay[client] = GetGameTime() + 0.5;
		char buffer[128];
		for(int i; i < BulletsLoaded[client]; i++)
		{
			buffer[i] = 'I';
		}
		PrintHintText(client, buffer);
		
	}
}