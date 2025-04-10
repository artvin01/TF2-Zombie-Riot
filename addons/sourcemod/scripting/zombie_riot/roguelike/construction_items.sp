#pragma semicolon 1
#pragma newdecls required

static int HardMode;

float ConstructionItems_OddIncrease()
{
	return HardMode ? 1.5 : 1.0;
}

public void Construction_Stalker_Collect()
{
	float pos[3], ang[3];
	
	Spawns_GetNextPos(pos, ang, "spawn_1_3");
	NPC_CreateByName("npc_stalker_wisp", 0, pos, ang, TFTeam_Blue);
	
	Spawns_GetNextPos(pos, ang, "spawn_2_3");
	NPC_CreateByName("npc_stalker_combine", 0, pos, ang, TFTeam_Blue);

	Spawns_GetNextPos(pos, ang, "spawn_3_3");
	NPC_CreateByName("npc_stalker_goggles", 0, pos, ang, TFTeam_Blue);

	Construction_AddMaterial("wizuh", 50, true);
}

public void Construction_Stalker_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			npc.m_fGunBonusReload *= 0.9;
			npc.m_fGunBonusFireRate *= 0.9;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
				npc.BonusFireRate /= 0.9;
		}
	}
}

public void Construction_Stalker_Weapon(int entity)
{
	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 0.9);
	
	if(Attributes_Has(entity, 97))
		Attributes_SetMulti(entity, 97, 0.9);
	
	if(Attributes_Has(entity, 733))
		Attributes_SetMulti(entity, 733, 0.9);
	
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, (1.0 / 0.9));
}

public void Construction_HeavyOre_Collect()
{
	Construction_AddMaterial("jalan", 50, true);
}

public void Construction_HeavyOre_Enemy(int entity)
{
	if(i_NpcIsABuilding[entity])
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.15));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * 1.15));
	}
}

public void Construction_CarStart_Collect()
{
	HardMode++;
	Construction_AddMaterial("ossunia", 50, true);
	Construction_AddMaterial("iron", 15, true);
	Construction_GiveNamedResearch("Base Level I", true);
	Construction_GiveNamedResearch("Vehicle Factory", true);
}

public void Construction_VoidStart_Collect()
{
	HardMode++;
}

public void Construction_HardMode_Remove()
{
	HardMode--;
}

// Health+
public void Construction_H_Ally(int entity, StringMap map)
{
	MultiHealth(entity, map, 1.05);
}

// Health++ Speed-
public void Construction_HS_Ally(int entity, StringMap map)
{
	MultiHealth(entity, map, 1.1);
	MultiSpeed(entity, map, 0.99);
}

// Health++ Damage-
public void Construction_HD_Ally(int entity, StringMap map)
{
	MultiHealth(entity, map, 1.05);
	MultiDamage(entity, false, 0.95);
}

// Health++ ASPD-
public void Construction_HA_Ally(int entity, StringMap map)
{
	MultiHealth(entity, map, 1.05);
	MultiFireRate(entity, false, 1.05);
}

// Speed+
public void Construction_S_Ally(int entity, StringMap map)
{
	MultiSpeed(entity, map, 1.01);
}

// Speed++ Health-
public void Construction_SH_Ally(int entity, StringMap map)
{
	MultiSpeed(entity, map, 1.02);
	MultiHealth(entity, map, 0.95);
}

// Damage+
public void Construction_D_Ally(int entity, StringMap map)
{
	MultiDamage(entity, false, 1.05);
}
public void Construction_D_Weapon(int entity)
{
	MultiDamage(entity, true, 1.05);
}
public void Construction_D0_Weapon(int entity)
{
	MultiDamage(entity, true, 1.1);
}
public void Construction_0D_Weapon(int entity)
{
	MultiDamage(entity, true, 0.95);
}

// Damage++ Speed-
public void Construction_DS_Ally(int entity, StringMap map)
{
	MultiDamage(entity, false, 1.1);
	MultiSpeed(entity, map, 0.99);
}

// APSD+
public void Construction_A_Ally(int entity, StringMap map)
{
	MultiFireRate(entity, false, 0.95);
}
public void Construction_A_Weapon(int entity)
{
	MultiFireRate(entity, true, 0.95);
}
public void Construction_A0_Weapon(int entity)
{
	MultiFireRate(entity, true, 0.9);
}
public void Construction_0A_Weapon(int entity)
{
	MultiFireRate(entity, true, 1.05);
}

// APSD++ Health-
public void Construction_AH_Ally(int entity, StringMap map)
{
	MultiFireRate(entity, false, 0.9);
	MultiHealth(entity, map, 0.95);
}

static void MultiDamage(int entity, bool weapon, float amount)
{
	if(weapon)
	{
		if(Attributes_Has(entity, 2))
			Attributes_SetMulti(entity, 2, amount);
		
		if(Attributes_Has(entity, 8))
			Attributes_SetMulti(entity, 8, amount);
		
		if(Attributes_Has(entity, 410))
			Attributes_SetMulti(entity, 410, amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +X% damage bonus
			npc.m_fGunBonusDamage *= amount;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +X% damage bonus
				npc.BonusDamageBonus *= amount;
			}
		}
	}
}

static void MultiFireRate(int entity, bool weapon, float amount)
{
	if(weapon)
	{
		if(Attributes_Has(entity, 6))
			Attributes_SetMulti(entity, 6, amount);
		
		if(Attributes_Has(entity, 8))
			Attributes_SetMulti(entity, 8, 1.0 / amount);
		
		if(Attributes_Has(entity, 97))
			Attributes_SetMulti(entity, 97, amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +X% fire rate
			npc.m_fGunBonusFireRate *= amount;

			// +X% reload speed
			npc.m_fGunReload *= amount;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +X% fire rate
				npc.BonusFireRate /= amount;
			}
		}
	}
}

static void MultiSpeed(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		// +X% movement speed
		map.GetValue("442", value);
		map.SetValue("442", value * amount);
	}
}

static void MultiHealth(int entity, StringMap map, float amount)
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
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +X% max health
			int health = RoundToCeil((float(ReturnEntityMaxHealth(npc.index)) * amount));
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +X% max health
				int health = RoundToCeil((float(ReturnEntityMaxHealth(npc.index)) * amount));
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Construction_BadExpi_Collect()
{
	CPrintToChatAll("{purple}???{default}: Hah, I knew you'll fall for it.");

	if(Construction_FinalBattle())
	{
		//CreateTimer(2.0, Timer_DialogueBadEnd, 0, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		//CreateTimer(2.0, Timer_DialogueNewEnd, 0, TIMER_FLAG_NO_MAPCHANGE);
	}
}
