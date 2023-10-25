#pragma semicolon 1
#pragma newdecls required

static int MeleeLevel[MAXTF2PLAYERS];

public void Weapon_SeaMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 90.0);

	EmitSoundToClient(client, "ambient/halloween/thunder_01.wav");

	ApplyTempAttrib(weapon, 2, 0.75, 10.0);
	ApplyTempAttrib(weapon, 6, 0.5, 10.0);

	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 10.0);

	float pos1[3], pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 100000) // 316 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					ApplyTempAttrib(entity, 2, 0.75, 10.0);
					ApplyTempAttrib(entity, 6, 0.5, 10.0);
					ApplyTempAttrib(entity, 97, 0.5, 10.0);
					ApplyTempAttrib(entity, 410, 0.75, 10.0);
					ApplyTempAttrib(entity, 733, 0.5, 10.0);

					EmitSoundToClient(target, "ambient/halloween/thunder_01.wav");
					EmitSoundToClient(target, "ambient/halloween/thunder_01.wav");
				}
			}
		}
	}
}

void SeaMelee_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SEABORNMELEE)
	{
		MeleeLevel[client] = RoundFloat(Attributes_Get(weapon, 861, 0.0));
	}
}

#define DEFAULT_MELEE_RANGE 64.0
#define DEFAULT_MELEE_BOUNDS 22.0
void SeaMelee_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	switch(MeleeLevel[client])
	{
		case 1:
		{
			CustomMeleeRange = DEFAULT_MELEE_RANGE * 1.25;
			CustomMeleeWide = DEFAULT_MELEE_BOUNDS * 1.25;
			ignore_walls = true;
			enemies_hit_aoe = 4;
		}
		case 2:
		{
			CustomMeleeRange = DEFAULT_MELEE_RANGE * 1.25;
			CustomMeleeWide = DEFAULT_MELEE_BOUNDS * 1.25;
			ignore_walls = true;
			enemies_hit_aoe = 5;
		}
		default:
		{
			CustomMeleeRange = DEFAULT_MELEE_RANGE * 1.15;
			CustomMeleeWide = DEFAULT_MELEE_BOUNDS * 1.15;
			enemies_hit_aoe = 3;
		}
	}
}

public void Weapon_SeaRange_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 60.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");

	float pos1[3], ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);

	int entity = Npc_Create(SEARUNNER, client, pos1, ang, true);
	if(entity > MaxClients)
		fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
}

public void Weapon_SeaRangePap_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 75.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");

	float pos1[3], ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);

	for(int i; i < 2; i++)
	{
		int entity = Npc_Create(SEARUNNER, client, pos1, ang, true);
		if(entity > MaxClients)
			fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
	}
}

public void Weapon_SeaRangePapFull_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 90.0);

	ClientCommand(client, "playgamesound ambient/halloween/male_scream_13.wav");
	
	ApplyTempAttrib(weapon, 2, 2.0, 10.0);
	ApplyTempAttrib(weapon, 6, 1.333, 10.0);
	ApplyTempAttrib(weapon, 97, 1.333, 10.0);

	float pos1[3], pos2[3], ang[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(client, Prop_Data, "m_angRotation", ang);

	for(int i; i < 3; i++)
	{
		int entity = Npc_Create(SEARUNNER, client, pos1, ang, true);
		if(entity > MaxClients)
			fl_Extra_Damage[entity] = Attributes_Get(weapon, 2, 1.0);
	}
	
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 100000) // 316 HU
			{
				i_ExtraPlayerPoints[client] += 10;

				int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(entity != -1)
				{
					ApplyTempAttrib(entity, 2, 2.0, 10.0);
					ApplyTempAttrib(entity, 6, 1.333, 10.0);
					ApplyTempAttrib(entity, 97, 1.333, 10.0);
					ApplyTempAttrib(entity, 410, 2.0, 10.0);

					ClientCommand(target, "playgamesound ambient/halloween/male_scream_13.wav");
					ClientCommand(target, "playgamesound ambient/halloween/male_scream_13.wav");
				}
			}
		}
	}
}

public void Weapon_SeaHealing_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	int ammo = GetAmmo(client, 21);
	if(ammo > 4)
	{
		StartPlayerOnlyLagComp(client, true);
		int target = GetClientPointVisibleOnlyClient(client, 150.0);
		EndPlayerOnlyLagComp(client);

		if(target > 0 && target <= MaxClients && dieingstate[target] == 0)
		{
			int health = GetEntProp(target, Prop_Send, "m_iHealth");
			int maxHealth = SDKCall_GetMaxHealth(target);
			if(health < maxHealth)
			{
				int healing = maxHealth - health;
				if(healing > 100)
					healing = 100;
				
				if(healing > ammo)
					healing = ammo;
				
				healing = healing / 5 * 5;

				StartHealingTimer(target, 0.5, 5.0, healing / 5);
				ClientCommand(client, "playgamesound items/smallmedkit1.wav");
				ClientCommand(target, "playgamesound items/smallmedkit1.wav");

				Give_Assist_Points(target, client);

				float cooldown = float(health) / 5.0;
				if(cooldown < 1.0)
					cooldown = 1.0;
				
				PrintHintText(client, "You Healed %N for %d HP!, you gain a %.0f healing cooldown.", target, healing, cooldown);

				Ability_Apply_Cooldown(client, slot, cooldown);

				CurrentAmmo[client][21] = ammo - healing;
				SetAmmo(client, 21, CurrentAmmo[client][21]);
				return;
			}
			
			PrintHintText(client, "%N Is already at full hp.", target);
		}
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_SeaHealing_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	int ammo = GetAmmo(client, 21);
	if(ammo > 0)
	{
		int health = GetEntProp(client, Prop_Send, "m_iHealth");
		int maxHealth = SDKCall_GetMaxHealth(client);
		
		int healing = maxHealth - health;
		if(healing > 30)
			healing = 30;
		
		if(healing < 0)
			healing = 0;
		
		if(healing > ammo)
			healing = ammo;
		
		SetEntityHealth(client, health + healing);
		
		ClientCommand(client, "playgamesound items/smallmedkit1.wav");

		PrintHintText(client, "You Healed yourself for %d HP!, you gain a 15 healing cooldown.", healing);

		Ability_Apply_Cooldown(client, slot, 15.0);

		CurrentAmmo[client][21] = ammo - healing;
		SetAmmo(client, 21, CurrentAmmo[client][21]);
		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_SeaHealingPap_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	int ammo = GetAmmo(client, 21);
	if(ammo > 4)
	{
		StartPlayerOnlyLagComp(client, true);
		int target = GetClientPointVisibleOnlyClient(client, 150.0);
		EndPlayerOnlyLagComp(client);

		if(target > 0 && target <= MaxClients && dieingstate[target] == 0)
		{
			int health = GetEntProp(target, Prop_Send, "m_iHealth");
			int maxHealth = SDKCall_GetMaxHealth(target);
			if(health < maxHealth)
			{
				int healing = maxHealth - health;
				if(healing > 200)
					healing = 200;
				
				if(healing > ammo)
					healing = ammo;
				
				healing = healing / 5 * 5;

				StartHealingTimer(target, 0.5, 5.0, healing / 5);
				ClientCommand(client, "playgamesound items/smallmedkit1.wav");
				ClientCommand(target, "playgamesound items/smallmedkit1.wav");

				Give_Assist_Points(target, client);

				float cooldown = float(health) / 2.5;
				if(cooldown < 1.0)
					cooldown = 1.0;
				
				PrintHintText(client, "You Healed %N for %d HP!, you gain a %.0f healing cooldown.", target, healing, cooldown);

				Ability_Apply_Cooldown(client, slot, cooldown);

				CurrentAmmo[client][21] = ammo - healing;
				SetAmmo(client, 21, CurrentAmmo[client][21]);
				return;
			}
			
			PrintHintText(client, "%N Is already at full hp.", target);
		}
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_SeaHealingPap_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	int ammo = GetAmmo(client, 21);
	if(ammo > 0)
	{
		int health = GetEntProp(client, Prop_Send, "m_iHealth");
		int maxHealth = SDKCall_GetMaxHealth(client);
		
		int healing = maxHealth - health;
		if(healing > 50)
			healing = 50;
		
		if(healing < 0)
			healing = 0;
		
		if(healing > ammo)
			healing = ammo;
		
		SetEntityHealth(client, health + healing);
		
		ClientCommand(client, "playgamesound items/smallmedkit1.wav");

		PrintHintText(client,"You Healed yourself for %d HP!, you gain a 25 healing cooldown.", healing);

		Ability_Apply_Cooldown(client, slot, 25.0);

		CurrentAmmo[client][21] = ammo - healing;
		SetAmmo(client, 21, CurrentAmmo[client][21]);
		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}