#pragma semicolon 1
#pragma newdecls required

static int BrokenBlade;
static int BladeDancer;
static float BladeDancerTime;
static float LastFlowerHealth;
static ArrayStack LastShadowHealth;
static bool Friendship;

void Rogue_StoryTeller_Reset()
{
	BrokenBlade = 0;
	BladeDancer = 0;
	LastFlowerHealth = 1000.0;
	delete LastShadowHealth;
	Friendship = false;
}

bool Rogue_HasFriendship()
{
	return Friendship;
}

void Rogue_StoryTeller_ReviveSpeed(int &amount)
{
	if(BrokenBlade)
		amount *= BrokenBlade * 2;
}

public void Rogue_Blademace_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +20% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 1.2);

		// -10% movement speed
		value = 1.0;
		map.GetValue("107", value);
		map.SetValue("107", value * 0.9);

		// +20% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.2);

		// -2% damage vuln
		value = 1.0;
		map.GetValue("412", value);
		map.SetValue("412", value * 0.98);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +20% damage bonus
			npc.m_fGunBonusDamage *= 1.2;

			// +20% max health
			int health = ReturnEntityMaxHealth(npc.index) * 6 / 5;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +20% damage bonus
				npc.BonusDamageBonus *= 1.2;

				// +20% max health
				int health = ReturnEntityMaxHealth(npc.index) * 6 / 5;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_Blademace_Weapon(int entity)
{
	Attributes_SetMulti(entity, 2, 1.2);
	Attributes_SetMulti(entity, 410, 1.2);
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		Attributes_SetMulti(entity, 1, 1.2);
	}
}

public void Rogue_Brokenblade_Collect()
{
	BrokenBlade++;
}

public void Rogue_Brokenblade_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// -20% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 0.8);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// -20% max health
			int health = ReturnEntityMaxHealth(npc.index) * 4 / 5;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
	}
}

public void Rogue_Bladedance_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		if(BladeDancer && BladeDancer != entity)
		{
			if(fabs(GetGameTime() - BladeDancerTime) < 180 && IsClientInGame(BladeDancer) && IsPlayerAlive(BladeDancer) && TeutonType[BladeDancer] == TEUTON_NONE && !dieingstate[BladeDancer])
				return;
		}

		if(TeutonType[entity] == TEUTON_NONE && !dieingstate[entity])
		{
			if(BladeDancer != entity)
			{
				BladeDancer = entity;
				BladeDancerTime = GetGameTime();
				CPrintToChatAll("{red}%N {crimson}recieved +100%% max health and +100%% damage bonus.", BladeDancer);
			}

			float value;

			// +100% max health
			map.GetValue("26", value);
			map.SetValue("26", value * 2.0);

			// +100% building damage
			value = 1.0;
			map.GetValue("287", value);
			map.SetValue("287", value * 2.0);
		}
	}
}

public void Rogue_Bladedance_Weapon(int entity)
{
	if(BladeDancer == GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))
	{
		Attributes_SetMulti(entity, 2, 2.0);
		Attributes_SetMulti(entity, 410, 2.0);
		char buffer[36];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		if(StrEqual(buffer, "tf_weapon_medigun"))
		{
			Attributes_SetMulti(entity, 1, 2.0);
		}
	}
}

public void Rogue_Whiteflower_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float last;
		map.GetValue("26", last);
		map.SetValue("26", LastFlowerHealth);

		LastFlowerHealth = last * 1.25;
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			int last = ReturnEntityMaxHealth(npc.index);

			int health = RoundFloat(LastFlowerHealth);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

			LastFlowerHealth = float(last) * 1.25;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				int last = ReturnEntityMaxHealth(npc.index);

				int health = RoundFloat(LastFlowerHealth);
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

				LastFlowerHealth = float(last) * 1.25;
			}
		}
	}
}

public void Rogue_Shadow_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		if(!LastShadowHealth)
			LastShadowHealth = new ArrayStack();
		
		float last;
		map.GetValue("26", last);
		LastShadowHealth.Push(RoundFloat(last));
	}
	else if(!b_NpcHasDied[entity] && LastShadowHealth && !LastShadowHealth.Empty)	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			int health = LastShadowHealth.Pop();
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				int health = LastShadowHealth.Pop();
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_RightNatator_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 0.95;
	fl_Extra_RangedArmor[entity] *= 1.2;
}

public void Rogue_LeftNatator_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.2;
	fl_Extra_RangedArmor[entity] *= 0.95;
}

public void Rogue_ProofOfFriendship_Collect()
{
	Friendship = true;
}

public void Rogue_CombineCrown_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// -5% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 0.95);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// -5% max health
			int health = ReturnEntityMaxHealth(npc.index) * 19 / 20;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// -5% max health
				int health = ReturnEntityMaxHealth(npc.index) * 19 / 20;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_BobResearch_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// -10% movement speed
		value = 1.0;
		map.GetValue("107", value);
		map.SetValue("107", value * 0.9);
	}
}

public void Rogue_BobFinal_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +20% movement speed
		value = 1.0;
		map.GetValue("107", value);
		map.SetValue("107", value * 1.2);

		// +15% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.15);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunBonusDamage *= 1.15;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +15% damage bonus
				npc.BonusDamageBonus *= 1.15;
			}
		}
	}
}

public void Rogue_BobFinal_Weapon(int entity)
{
	Attributes_SetMulti(entity, 2, 1.15);
	Attributes_SetMulti(entity, 410, 1.15);

	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		Attributes_SetMulti(entity, 1, 1.15);
	}
}