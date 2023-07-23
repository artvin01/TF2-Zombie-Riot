#pragma semicolon 1
#pragma newdecls required

static bool SmartBounce;
static int LastHitTarget;

void SniperMonkey_ClearAll()
{
	SmartBounce = false;
}

float SniperMonkey_BouncingBullets(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(LastHitTarget == victim)
		return 0.0;
	
	if(LastHitTarget != victim && !(damagetype & DMG_SLASH) && !(damagetype & DMG_BLAST))
	{
		damagetype |= DMG_SLASH;
		
		if(SmartBounce)
		{
			if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				damage *= 1.5;
			}
			float pos[3];
			
			int targets[3];
			int healths[3];
			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
			{
				if(i != victim && !b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
				{
					GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos);
					if(GetVectorDistance(pos, damagePosition, true) < 62500.0) 
					{
						int hp = GetEntProp(i, Prop_Data, "m_iHealth");
						if(healths[0] < hp)
						{
							healths[2] = healths[1];
							targets[2] = targets[1];
							
							healths[1] = healths[0];
							targets[1] = targets[0];
							
							healths[0] = hp;
							targets[0] = i;
						}
						else if(healths[1] < hp)
						{
							healths[2] = healths[1];
							targets[2] = targets[1];
							
							healths[1] = hp;
							targets[1] = i;
						}
						else if(healths[2] < hp)
						{
							healths[2] = hp;
							targets[2] = i;
						}
					}
				}
			}
			
			for(i = 0; i < sizeof(targets); i++)
			{
				if(targets[i])
					SDKHooks_TakeDamage(targets[i], inflictor, attacker, damage * (0.875 - (0.125 * float(i))), damagetype|DMG_BLAST, weapon, damageForce, damagePosition);
			}
		}
		else
		{
			int value = i_ExplosiveProjectileHexArray[attacker];
			i_ExplosiveProjectileHexArray[attacker] = 0;	// If DMG_SLASH doesn't block NPC_OnTakeDamage_Equipped_Weapon_Logic, adjust this
			LastHitTarget = victim;
			
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 250.0, 1.2, 0.0, false, 4);
			if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				damage *= 1.5;
			}			
			i_ExplosiveProjectileHexArray[attacker] = value;
			LastHitTarget = 0;
		}
	}
	return damage;
}

float SniperMonkey_MaimMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 6.0;
	switch(i_NpcInternalId[victim])
	{
		case BTD_MOAB:
		{
			duration = 12.0;
		}
		case BTD_BFB:
		{
			duration = 9.0;
		}
		case BTD_BLOON, BTD_GOLDBLOON, BTD_BAD:
		{
			duration = 5.0;
		}
	}
	
	if(duration)
	{
		if((damagetype & DMG_SLASH) || (damagetype & DMG_BLAST))
			duration *= 2.0 / 3.0;
		
		duration += GetGameTime();
		if(duration > f_MaimDebuff[victim])
			f_MaimDebuff[victim] = duration;
	}

	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

float SniperMonkey_CrippleMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 6.0;
	switch(i_NpcInternalId[victim])
	{
		case BTD_BLOON, BTD_GOLDBLOON:
		{
			duration = 0.0;
		}
		case BTD_MOAB:
		{
			duration = 14.0;
		}
		case BTD_BFB:
		{
			duration = 12.0;
		}
		case BTD_ZOMG:
		{
			duration = 6.0;
		}
		case BTD_DDT:
		{
			duration = 8.0;
		}
	}
	
	if(duration)
	{
		if((damagetype & DMG_SLASH) || (damagetype & DMG_BLAST))
			duration *= 2.0 / 3.0;
		
		float time = GetGameTime();
		if((duration + time) > f_MaimDebuff[victim])
			f_MaimDebuff[victim] = (duration + time);
		
		duration *= 2.0;
		if((duration + time) > f_CrippleDebuff[victim])
			f_CrippleDebuff[victim] = (duration + time);
	}
	
	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

public void Weapon_EnableSmartBouncing(int client)
{
	SmartBounce = true;
}

public void Weapon_EliteDefender(int client, int weapon, bool &result, int slot)
{
	float value = 0.3;
	if(!dieingstate[client] && !LastMann)
	{
		int maxhealth, health;
		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && GetClientTeam(target)==2 && TeutonType[target] != TEUTON_WAITING)
			{
				if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					int maxhp = dieingstate[target] ? 1000 : SDKCall_GetMaxHealth(target);
					maxhealth += maxhp;
					
					int hp = GetClientHealth(target);
					if(hp > maxhp)
						hp = maxhp;
					
					health += hp;
				}
				else
				{
					maxhealth += 1000;
				}
			}
		}
		
		if(maxhealth)
		{
			value = float(health) / float(maxhealth);
			if(value < 0.2)
				value = 0.2;
		}
	}
	
	Attributes_Set(weapon, 396, value);
}

public void Weapon_SupplyDrop(int client, int weapon, bool &result, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		float pos1[3], pos2[3];
		GetClientEyePosition(client, pos1);
		
		float distance;
		int target = -1;
		int i = MaxClients + 1;
		while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
		{
			if(!b_NpcHasDied[i] && b_NpcForcepowerupspawn[i] != 2 && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
			{
				GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
				
				float dist = GetVectorDistance(pos1, pos2, true);
				if(distance < dist) 
				{
					target = i;
					distance = dist;
				}
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			Ability_Apply_Cooldown(client, slot, 150.0);
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Weapon_SupplyDropElite(int client, int weapon, bool &result, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int target = MaxClients + 1;
		while((target = FindEntityByClassname(target, "zr_base_npc")) != -1)
		{
			if(!b_NpcHasDied[target] && b_NpcForcepowerupspawn[target] != 2 && GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
				break;
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert_friend.wav");
			Ability_Apply_Cooldown(client, slot, 120.0);
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}