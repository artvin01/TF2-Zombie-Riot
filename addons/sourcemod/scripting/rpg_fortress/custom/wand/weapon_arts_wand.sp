#pragma semicolon 1
#pragma newdecls required

void Wand_Arts_MapStart()
{
	PrecacheSound("misc/halloween/spell_teleport.wav");
}

public Action Weapon_Arts_Wand(int client, int weapon, bool &crit, int slot)
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
		float damage = 65.0;
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
		damage *= 1.0 + (Stats_OriginiumPower(client) / 2.0);
		// x1.0 to x2.5

		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 104);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 475);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
	
		float time = 500.0 / speed;
		address = TF2Attrib_GetByDefIndex(weapon, 101);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 102);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
		
		EmitSoundToAll("misc/halloween/spell_teleport.wav", client, _, 65, _, 0.45);
		Wand_Projectile_Spawn(client, speed, time, damage, 1, weapon, "eyeboss_projectile");
	}
	return Plugin_Continue;
}

public Action Weapon_Arts_CorruptM2(int client, int weapon, bool &crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
	else
	{
		Stats_AddOriginium(client, 2);
		TF2_AddCondition(client, TFCond_Buffed, 10.0);
		Ability_Apply_Cooldown(client, slot, 25.0);
		ClientCommand(client, "playgamesound items/powerup_pickup_plague_infected.wav");
	}
	return Plugin_Continue;
}