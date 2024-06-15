static void GiveShield(int amount)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
		{
			int health = GetClientHealth(client);
			if(health > 0)
				SetEntityHealth(client, health + amount);
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == TFTeam_Red)
			{
				BarrackBody npc = view_as<BarrackBody>(entity);
				if(npc.OwnerUserId)	// Barracks Unit
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + amount);
				}
			}
		}
	}
}

static void GiveLife(int entity, StringMap map, int amount)
{
	if(map)	// Player
	{
		float value;

		// +X max health
		map.GetValue("26", value);
		map.SetValue("26", value + amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		// +X max health
		int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth") + amount;

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}

static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * amount));
}

static void GiveMaxHealth(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		// +X% max health
		map.GetValue("26", value);
		map.SetValue("26", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		// +X% max health
		int health = RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * amount);

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}

public void Rogue_Store1_Collect()
{
	Store_RandomizeNPCStore(2, 1);
}

public void Rogue_Store2_Collect()
{
	Store_RandomizeNPCStore(2, 2);
}

public void Rogue_Store3_Collect()
{
	Store_RandomizeNPCStore(2, 3);
}

public void Rogue_Shield1_Collect()
{
	GiveShield(500);
}

public void Rogue_Shield2_Collect()
{
	GiveShield(1000);
}

public void Rogue_Shield4_Collect()
{
	GiveShield(2000);
}

public void Rogue_Shield6_Collect()
{
	GiveShield(3000);
}

public void Rogue_Hope1_Collect()
{
	CurrentCash += 1000;
	GlobalExtraCash += 1000;
}

public void Rogue_Hope8_Collect()
{
	CurrentCash += 8000;
	GlobalExtraCash += 8000;
}

public void Rogue_Ingot25_Collect()
{
	Rogue_AddIngots(25, true);
}

public void Rogue_Life1_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 125);
}

public void Rogue_Life2_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 250);
}

public void Rogue_Life3_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 375);
}

public void Rogue_Life4_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 500);
}

public void Rogue_Life5_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 625);
}

public void Rogue_Life6_Ally(int entity, StringMap map)
{
	GiveLife(entity, map, 750);
}

public void Rogue_AttackDown1_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.07;
}

public void Rogue_AttackDown2_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.12;
}

public void Rogue_AttackDown3_Enemy(int entity)
{
	fl_Extra_Damage[entity] /= 1.17;
}

public void Rogue_HealthDown1_Enemy(int entity)
{
	MultiHealth(entity, 0.9);
}

public void Rogue_HealthDown2_Enemy(int entity)
{
	MultiHealth(entity, 0.85);
}

public void Rogue_HealthDown3_Enemy(int entity)
{
	MultiHealth(entity, 0.8);
}

public void Rogue_MeleeDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(2, entity))
		Attributes_SetMulti(entity, 2, 1.15);
}

public void Rogue_MeleeDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(2, entity))
		Attributes_SetMulti(entity, 2, 1.25);
}

public void Rogue_RangedDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(7, entity))
		Attributes_SetMulti(entity, 2, 1.15);
}

public void Rogue_RangedDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(7, entity))
		Attributes_SetMulti(entity, 2, 1.25);
}

public void Rogue_MageDamage1_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(8, entity))
		Attributes_SetMulti(entity, 2, 1.15);
}

public void Rogue_MageDamage2_Weapon(int entity)
{
	if(Store_CheckEntitySlotIndex(8, entity))
		Attributes_SetMulti(entity, 2, 1.25);
}

public void Rogue_Health1_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.2);
}

public void Rogue_Health2_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.35);
}

public void Rogue_Health3_Ally(int entity, StringMap map)
{
	GiveMaxHealth(entity, map, 1.5);
}

public void Rogue_MeleeVuln1_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] /= 1.15;
}

public void Rogue_MeleeVuln2_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] /= 1.25;
}

public void Rogue_MeleeVuln3_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] /= 1.35;
}

public void Rogue_RangedVuln1_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] /= 1.15;
}

public void Rogue_RangedVuln1_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] /= 1.15;
}

public void Rogue_RangedVuln2_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] /= 1.25;
}

public void Rogue_RangedVuln3_Enemy(int entity)
{
	fl_Extra_RangedArmor[entity] /= 1.35;
}

public void Rogue_Healing1_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +20% healing bonus
		map.GetValue("526", value);
		map.SetValue("526", value * 1.2);
	}
}

public void Rogue_Healing2_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +30% healing bonus
		map.GetValue("526", value);
		map.SetValue("526", value * 1.3);
	}
}

static Handle EternalNightTimer;

public void Rogue_EternalNight_Collect()
{
	delete EternalNightTimer;
	EternalNightTimer = CreateTimer(0.2, EternalNightTimer, _, TIMER_REPEAT);
}

public void Rogue_EternalNight_Weapon(int entity)
{
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.25);
	
	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 0.75);

	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.25);
}

public void Rogue_EternalNight_Remove()
{
	delete EternalNightTimer;
}

static Action EternalNightTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0)
			{
				int health = GetClientHealth(client);
				if(health > 2)
				{
					SetEntityHealth(client, health - 2);
				}
				else
				{
					SDKHooks_TakeDamage(client, 0, 0, 999.9, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
				}
			}
		}
	}

	return Plugin_Continue;
}

static Handle DeadTreeTimer;

public void Rogue_DeadTree_Collect()
{
	delete DeadTreeTimer;
	DeadTreeTimer = CreateTimer(0.2, DeadTreeTimer, _, TIMER_REPEAT);
}

public void Rogue_DeadTree_Ally(int entity, StringMap map)
{
	if(map)	// Player
		GiveMaxHealth(entity, map, 0.75);
}

public void Rogue_DeadTree_Remove()
{
	delete DeadTreeTimer;
}

static Action DeadTreeTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0)
			{
				int health = GetClientHealth(client);
				if(health > 0)
					SetEntityHealth(client, health + 4);
			}
		}
	}

	return Plugin_Continue;
}