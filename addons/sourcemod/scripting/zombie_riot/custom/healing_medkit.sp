#pragma semicolon 1
#pragma newdecls required

/*
	Placement Type
*/
static bool is_pressisng_m1[MAXTF2PLAYERS];
static bool is_pressisng_m2[MAXTF2PLAYERS];
static float f_cooldown_per_usage_global[MAXTF2PLAYERS];

public void MedKit_ClearAll()
{
	Zero(f_cooldown_per_usage_global);
}
void Remove_Healthcooldown()
{
	for(int client=1; client<=MaxClients; client++)
	{
		healing_cooldown[client] = 0.0;
	}
	
}
public Action Medikit_healing(int client, int buttons)
{
	if(buttons & IN_ATTACK)
	{
		if(f_cooldown_per_usage_global[client] < GetGameTime())
		{
			if(!is_pressisng_m1[client])
			{
				is_pressisng_m1[client] = true;
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon))
				{
					int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
					if(weaponindex == 810)
					{
						if(healing_cooldown[client] < GetGameTime())
						{
							int player_looking_at;
							
							StartPlayerOnlyLagComp(client, true);
							player_looking_at = GetClientPointVisibleOnlyClient(client, 150.0);
							if(player_looking_at <= MAXPLAYERS && player_looking_at > 0 && dieingstate[player_looking_at] == 0 && dieingstate[client] == 0)
							{
								float Healer[3];
								Healer[2] += 62;
								GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Healer); 
								float Injured[3];
								Injured[2] += 62;
								GetEntPropVector(player_looking_at, Prop_Data, "m_vecAbsOrigin", Injured);
								if(GetVectorDistance(Healer, Injured) <= 150.0)
								{
									int ammo_amount_left = GetAmmo(client, 21);
									
									if(ammo_amount_left <= 0)
									{
										ClientCommand(client, "playgamesound items/medshotno1.wav");
									}	
									else
									{
										int Healing_Max = 70;
										if(ammo_amount_left > Healing_Max)
										{
											ammo_amount_left = Healing_Max;
										}
										
										int flHealth = GetEntProp(player_looking_at, Prop_Send, "m_iHealth");
										int flMaxHealth = SDKCall_GetMaxHealth(player_looking_at);
										
										int Health_To_Max;
										
										Health_To_Max = flMaxHealth - flHealth;
										
										if(Health_To_Max <= 0 || Health_To_Max > flMaxHealth)
										{
											ClientCommand(client, "playgamesound items/medshotno1.wav");
											PrintHintText(client,"%N Is already at full hp.", player_looking_at);
										}
										else
										{
											if(Health_To_Max < 50)
											{
												ammo_amount_left = Health_To_Max;
											}
											
											StartHealingTimer(player_looking_at, 0.1, 1.0, ammo_amount_left);
											Healing_done_in_total[client] += ammo_amount_left;
											healing_cooldown[client] = GetGameTime() + float(ammo_amount_left / 5);
											
											int new_ammo = GetAmmo(client, 21) - ammo_amount_left;
											ClientCommand(client, "playgamesound items/smallmedkit1.wav");
											ClientCommand(player_looking_at, "playgamesound items/smallmedkit1.wav");
											f_cooldown_per_usage_global[client] = GetGameTime() + 1.0;
											PrintHintText(client,"You Healed %N for %i HP!, you gain a %i healing cooldown.", player_looking_at, ammo_amount_left, ammo_amount_left / 5);
											
											Give_Assist_Points(player_looking_at, client);
											SetAmmo(client, 21, new_ammo);
											for(int i; i<Ammo_MAX; i++)
											{
												CurrentAmmo[client][i] = GetAmmo(client, i);
											}
										}
									}
								}
							}
							EndPlayerOnlyLagComp(client);
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							PrintHintText(client,"You have %.1f Seconds left before you can heal again.", healing_cooldown[client] - GetGameTime());
						}
					}
				}
			}
		}
	}
	else
	{
		is_pressisng_m1[client] = false;
	}
	
	if(buttons & IN_ATTACK2)
	{
		if(f_cooldown_per_usage_global[client] < GetGameTime())
		{
			if(!is_pressisng_m2[client])
			{
				is_pressisng_m2[client] = true;
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon) && dieingstate[client] == 0)
				{
					int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
					if(weaponindex == 810)
					{
						if(healing_cooldown[client] < GetGameTime())
						{
							int ammo_amount_left = GetAmmo(client, 21);
									
							if(ammo_amount_left <= 0)
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
							}	
							else
							{
								int Healing_Max = 25;
								if(ammo_amount_left > Healing_Max)
								{
									ammo_amount_left = Healing_Max;
								}
								
								int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
								int flMaxHealth = SDKCall_GetMaxHealth(client);
								
								int Health_To_Max;
								
								Health_To_Max = flMaxHealth - flHealth;
							
								if(Health_To_Max <= 0 || Health_To_Max > flMaxHealth)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									PrintHintText(client,"You're already at full hp.");
								}
								else
								{
									if(Health_To_Max < 15)
									{
										ammo_amount_left = Health_To_Max;
									}
									
									StartHealingTimer(client, 0.1, 1.0, ammo_amount_left);
									Healing_done_in_total[client] += ammo_amount_left;
									int new_ammo = GetAmmo(client, 21) - ammo_amount_left;
									
									healing_cooldown[client] = GetGameTime() + float(ammo_amount_left / 2);
									
									PrintHintText(client,"You Healed yourself for %i HP!, you gain a %i healing cooldown.", ammo_amount_left, ammo_amount_left / 2);
									
									f_cooldown_per_usage_global[client] = GetGameTime() + 1.0;
									ClientCommand(client, "playgamesound items/smallmedkit1.wav");
									SetAmmo(client, 21, new_ammo);
									for(int i; i<Ammo_MAX; i++)
									{
										CurrentAmmo[client][i] = GetAmmo(client, i);
									}
								}
								
							}
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							PrintHintText(client,"You have %.1f Seconds left before you can heal again.", healing_cooldown[client] - GetGameTime());
						}
					}
				}
			}
		}
	}
	else
	{
		is_pressisng_m2[client] = false;
	}
	
	return Plugin_Continue;
}