#pragma semicolon 1
#pragma newdecls required

void Wand_Arts_MapStart()
{
	PrecacheSound("misc/halloween/spell_teleport.wav");
}

public Action Weapon_Arts_Wand(int client, int weapon, bool &crit, int slot)
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
		float damage = 65.0 * Attributes_Get(weapon, 410, 1.0);
		
		damage *= 1.0 + (Stats_OriginiumPower(client) / 2.0);
		// x1.0 to x2.5

		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
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