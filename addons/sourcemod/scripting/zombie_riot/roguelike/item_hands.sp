#pragma semicolon 1
#pragma newdecls required

public void Rogue_HandMulti_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Charger || i_WeaponArchetype[entity] == Archetype_Debuffer)
	{
		// +35% melee resistance
		Attributes_SetMulti(entity, 206, 0.65);
		Attributes_SetAdd(entity, 877, 0.5);
	}
}

public void Rogue_HandExplosive_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Artillery || i_WeaponArchetype[entity] == Archetype_Mechanic)
	{
		// +50% damage bonus
		Attributes_SetMulti(entity, 2, 1.5);
		Attributes_SetMulti(entity, 524, 2.5);
	}
}

public void Rogue_HandSupport_Weapon(int weapon)
{
	if(i_WeaponArchetype[weapon] == Archetype_Medical || i_WeaponArchetype[weapon] == Archetype_Buffer)
	{
		// +10 hp regen
		Attributes_SetAdd(weapon, 57, 25.0);
	}
}

public void Rogue_Item_HealingSalve(int weapon)
{
	// +10 hp regen
	Attributes_SetAdd(weapon, 57, 10.0);
}
public void Rogue_HandFlame_Weapon(int entity)
{
	if(Attributes_Has(entity, 208))
	{
		Attributes_SetAdd(entity, 149, Attributes_Get(entity, 208) * 1.5);
		Attributes_Set(entity, 208, 0.0);
	}
}

public void Rogue_HandTrap_Weapon(int entity)
{
	char classname[36];
	if(!StrContains(classname, "tf_weapon_shotgun_building_rescue"))
	{
		// Firing Speed -> Reload Speed
		float value = Attributes_Get(entity, 6);
		Attributes_Set(entity, 97, value);

		switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case 997:	// Spike Layer
			{
				// +90% firing speed
				Attributes_Set(entity, 6, 0.1);

				// 40/60 clip size
				Attributes_Set(entity, 303, value > 2.0 ? 40.0 : 60.0);
			}
			case 1004:	// Aresenal
			{
				// +60% firing speed
				Attributes_Set(entity, 6, 0.4);

				// 6 clip size
				Attributes_Set(entity, 303, 6.0);
			}
		}
	}
	else
	{
		switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case 20, 207, 130, 265, 661, 1150:
			{
				// +6 max pipebombs
				Attributes_SetAdd(entity, 88, 6.0);

				// Detonates stickybombs near the crosshair and directly under your feet
				Attributes_Set(entity, 119, 1.0);
			}
		}
	}
}


public void Rogue_HandleBrawler_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Ambusher || i_WeaponArchetype[entity] == Archetype_Crusher)
	{
		// +50% fire rate
		Attributes_SetMulti(entity, 6, 0.5);
	}
}

public void Rogue_HandAmbusher_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Ambusher || i_WeaponArchetype[entity] == Archetype_Crusher)
	{
		// +5s bleed duration
		Attributes_SetAdd(entity, 149, 5.0);
		Attributes_SetMulti(entity, 6, 0.75);
	}
}
public void Rogue_HandInfinite_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Tactician || i_WeaponArchetype[entity] == Archetype_Deadeye)
	{
		// +3 health on hit
		Attributes_SetAdd(entity, 16, 3.0);
		Attributes_SetMulti(entity, 205, 0.65);
	}
}

public void Rogue_HandDuelist_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Duelist || i_WeaponArchetype[entity] == Archetype_Combatant)
	{
		// +150% damage bonus when half health
		Attributes_SetMulti(entity, 224, 2.5);
	}
}

public void Rogue_HandCaster_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Rapid || i_WeaponArchetype[entity] == Archetype_Power || i_WeaponArchetype[entity] == Archetype_Hexing)
	{
		// +100% max mana
		Attributes_SetMulti(entity, 405, 2.0);
		Attributes_SetMulti(entity, 6, 0.5);
	}
}

public void Rogue_HandKazimierz_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Lord || i_WeaponArchetype[entity] == Archetype_Defender)
	{
		// +75% damage bonus while over half health
		Attributes_SetMulti(entity, 225, 1.75);
	}
}