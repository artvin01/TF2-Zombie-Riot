#pragma semicolon 1
#pragma newdecls required

static bool SmartBounce;
static int LastHitTarget;
static int SuppliesUsed;

void SniperMonkey_ResetUses()
{
	SuppliesUsed = 0;
}
void SniperMonkey_ClearAll()
{
	SmartBounce = false;
	SuppliesUsed = 0;
}

float SniperMonkey_BouncingBullets(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(LastHitTarget == victim)
		return 0.0;
	
	if(LastHitTarget != victim && !(damagetype & DMG_BLAST))
	{
		if(SmartBounce)
		{

			float pos[3];
			
			int targets[3];
			int healths[3];
			int i;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				i = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(i))
				{
					if(i != victim && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
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
			}
			
			for(i = 0; i < sizeof(targets); i++)
			{
				if(targets[i])
				{
					float DamageDealDo = damage * (0.875 - (0.2 * float(i)));
					if(DamageDealDo >= 0.0)
						SDKHooks_TakeDamage(targets[i], inflictor, attacker, DamageDealDo, damagetype|DMG_BLAST, weapon, damageForce, damagePosition);
				}
			}
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				damage *= 1.5;
			}
		}
		else
		{
			int value = i_ExplosiveProjectileHexArray[attacker];
			i_ExplosiveProjectileHexArray[attacker] = 0;	// If DMG_TRUEDAMAGE doesn't block NPC_OnTakeDamage_Equipped_Weapon_Logic, adjust this
			LastHitTarget = victim;
			
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 250.0, EXPLOSION_AOE_DAMAGE_FALLOFF, _, false, 4);
			if(RaidbossIgnoreBuildingsLogic(1))
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
	
	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 2.0 / 3.0;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
		}
	}

	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

float SniperMonkey_CrippleMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 6.0;

	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 2.0 / 3.0;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
			
			duration *= 2.0;
			ApplyStatusEffect(attacker, victim, "Cripple", duration);
		}
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
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	else if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		float pos1[3], pos2[3];
		GetClientEyePosition(client, pos1);
		
		float distance;
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
				
				float dist = GetVectorDistance(pos1, pos2, true);
				if(distance < dist) 
				{
					target = entity;
					distance = dist;
				}
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			Ability_Apply_Cooldown(client, slot, 120.0);

			SuppliesUsed++;
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
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				target = entity;
				break;
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert_friend.wav");
			Ability_Apply_Cooldown(client, slot, 90.0);
			SuppliesUsed++;
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