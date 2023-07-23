static int BrokenBlade;
static int BladeDancer;
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

int Rogue_ReviveSpeed()
{
	switch(BrokenBlade)
	{
		case 0:
			return 1;
		
		case 1:
			return 2;

		default:
			return 4;
	}
}

public void Rogue_Blademace_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +15% max health
		map.GetValue("26", value);

		value += ClassHealth(WeaponClass[entity]);
		value *= 1.15;
		value -= ClassHealth(WeaponClass[entity]);

		map.SetValue("26", value);

		// -15% movement speed
		value = 1.0;
		map.GetValue("107", value);
		map.SetValue("107", value * 0.85);

		// +15% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.15);

		// -1.5% damage vuln
		value = 1.0;
		map.GetValue("412", value);
		map.SetValue("412", value * 0.985);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunRangeBonus *= 1.15;

			// +15% max health
			int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 23 / 20;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +15% damage bonus
				npc.BonusDamageBonus *= 1.15;

				// +15% max health
				int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 23 / 20;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_Blademace_Weapon(int entity)
{
	Attributes_SetMulti(entity, 2, 1.15);
	Attributes_SetMulti(entity, 410, 1.15);
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(!StrEqual(buffer, "tf_weapon_medigun"))
	{
		Attributes_SetMulti(entity, 1, 1.15);
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

		// -25% max health
		map.GetValue("26", value);

		value += ClassHealth(WeaponClass[entity]);
		value *= 0.75;
		value -= ClassHealth(WeaponClass[entity]);

		map.SetValue("26", value);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// -25% max health
			int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 3 / 4;
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
			if(IsClientInGame(BladeDancer) && IsPlayerAlive(BladeDancer) && TeutonType[BladeDancer] == TEUTON_NONE && !dieingstate[BladeDancer])
				return;
		}

		if(TeutonType[entity] != TEUTON_NONE && !dieingstate[entity])
		{
			BladeDancer = entity;

			float value;

			// +100% max health
			map.GetValue("26", value);

			value += ClassHealth(WeaponClass[entity]);
			value *= 2.0;
			value -= ClassHealth(WeaponClass[entity]);

			map.SetValue("26", value);

			// +100% building damage
			value = 1.0;
			map.GetValue("287", value);
			map.SetValue("287", value * 2.0);
		}
	}
}

public void Rogue_Bladedance_Weapon(int entity)
{
	if(BladeDancer == entity)
	{
		Attributes_SetMulti(entity, 2, 2.0);
		Attributes_SetMulti(entity, 410, 2.0);
		char buffer[36];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		if(!StrEqual(buffer, "tf_weapon_medigun"))
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
		last += ClassHealth(WeaponClass[entity]);

		map.SetValue("26", RemoveExtraHealth(WeaponClass[entity], LastFlowerHealth));

		LastFlowerHealth = last;
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			int last = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

			int health = RoundFloat(LastFlowerHealth);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

			LastFlowerHealth = float(last);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				int last = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

				int health = RoundFloat(LastFlowerHealth);
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

				LastFlowerHealth = float(last);
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
		last += ClassHealth(WeaponClass[entity]);

		LastShadowHealth.Push(RoundFloat(last));
	}
	else if(!b_NpcHasDied[entity] && LastShadowHealth && !LastShadowHealth.Empty)	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
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
	fl_Extra_RangedArmor[entity] *= 1.15;
}

public void Rogue_LeftNatator_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.15;
	fl_Extra_RangedArmor[entity] *= 0.95;
}

public void Rogue_ProofOfFriendship_Collect()
{
	Friendship = true;
}