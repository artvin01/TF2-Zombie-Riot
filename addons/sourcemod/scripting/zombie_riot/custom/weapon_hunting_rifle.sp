#pragma semicolon 1
#pragma newdecls required

static float	 Timetillnextbullet[MAXTF2PLAYERS];
static int		 IsAbilityActive[MAXTF2PLAYERS];
static int		 BulletsLoaded[MAXTF2PLAYERS] = 5;
static int		 CurrentMaxBullets[MAXTF2PLAYERS];
static int		 IsCurrentlyReloading[MAXTF2PLAYERS];

Handle			 Timer_Hunting_Rifle_Management[MAXPLAYERS + 1] = { null, ... };

public void Hunting_Rifle_Attack_Main(int client, int weapon, bool crit, int slot)  // stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	CurrentMaxBullets[client] = 5;
	BulletsLoaded[client] -= 1;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	if (IsAbilityActive[client] == 1)
	{
		Timetillnextbullet[client] = GetGameTime() + 1.0;	  // reset the reload cooldown if you attack >:3
	}
	else
	{
		Timetillnextbullet[client] = GetGameTime() + 1.25;	 // reset the reload cooldown if you attack >:3
	}
}

public void Hunting_Rifle_Attack_Main_PAP1(int client, int weapon, bool crit, int slot)	// stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	CurrentMaxBullets[client] = 7;
	BulletsLoaded[client] -= 1;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	if(IsAbilityActive[client] == 1)
	{
		Timetillnextbullet[client] = GetGameTime() + 1.0;	  // reset the reload cooldown if you attack >:3
	}
	else
	{
		Timetillnextbullet[client] = GetGameTime() + 1.25;	 // reset the reload cooldown if you attack >:3
	}
}

public void Hunting_Rifle_Attack_Main_PAP2(int client, int weapon, bool crit, int slot)	// stuff that happens when you press m1
{
	Enable_Hunting_Rifle(client, weapon);
	CurrentMaxBullets[client] = 9;
	BulletsLoaded[client] -= 1;
	ClientCommand(client, "playgamesound weapons/enforcer_shoot.wav");
	if(IsAbilityActive[client] == 1)
	{
		Timetillnextbullet[client] = GetGameTime() + 1.0;	  // reset the reload cooldown if you attack >:3
	}
	else
	{
		Timetillnextbullet[client] = GetGameTime() + 1.25;	 // reset the reload cooldown if you attack >:3
	}
}

public void Hunting_Rifle_Ability(int client, int weapon, bool crit, int slot)	   // ability stuff here
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 30.0);
		ClientCommand(client, "playgamesound weapons/recon_ping.wav");
		ApplyTempAttrib(weapon, 2, 3.0, 10.0);					// 200% dmg buff while ability is activated
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
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 30.0);
		ClientCommand(client, "playgamesound weapons/recon_ping.wav");
		ApplyTempAttrib(weapon, 2, 3.0, 15.0);					// 200% dmg buff while ability is activated
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
	// ammo logic here, love how nicely this works :D
	switch (BulletsLoaded[client])	  // i am sorry for doing this but i dunno of a better way to achieve this result
	{
		case 0:
		{
			PrintHintText(client, "X");
		}
		case 1:
		{
			PrintHintText(client, "I");
		}
		case 2:
		{
			PrintHintText(client, "II");
		}
		case 3:
		{
			PrintHintText(client, "III");
		}
		case 4:
		{
			PrintHintText(client, "IIII");
		}
		case 5:
		{
			PrintHintText(client, "IIIII");
		}
		case 6:
		{
			PrintHintText(client, "IIIIII");
		}
		case 7:
		{
			PrintHintText(client, "IIIIIII");
		}
		case 8:
		{
			PrintHintText(client, "IIIIIIII");
		}
		case 9:
		{
			PrintHintText(client, "IIIIIIIII");
		}
	}

	// PrintHintText(client, "Ark Energy [%d]", BulletsLoaded[client]);

	if (BulletsLoaded[client] < CurrentMaxBullets[client])	  // if we have less bullets loaded than our max bullet amount
	{
		if (IsCurrentlyReloading[client] == 0)	  // only trigger if not currently reloading otherwise the timer will reset infinitely
		{
			if (IsAbilityActive[client] == 1)	 // makes the reload quicker if ability is activated
			{
				Timetillnextbullet[client]	 = GetGameTime() + 0.3;
				IsCurrentlyReloading[client] = 1;
			}
			else
			{
				Timetillnextbullet[client]	 = GetGameTime() + 1.2;
				IsCurrentlyReloading[client] = 1;
			}
		}

		if (Timetillnextbullet[client] < GetGameTime())
		{
			BulletsLoaded[client] += 1;	   // add 1 ammo
			IsCurrentlyReloading[client] = 0;
			ClientCommand(client, "playgamesound weapons/default_reload.wav");
		}
	}
	if (BulletsLoaded[client] == 0)
	{
		TF2Attrib_SetByDefIndex(client, 821, 1.0);	  // makes the weapon unable to fire
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 821, 0.0);	  // makes the user to fire the weapon again
	}
	return Plugin_Continue;
}