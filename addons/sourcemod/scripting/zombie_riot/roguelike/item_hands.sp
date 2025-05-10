#pragma semicolon 1
#pragma newdecls required

public void Rogue_HandMulti_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 1 || i_WeaponArchetype[entity] == 2)	// Multi Pellet
	{
		// +35% melee resistance
		Attributes_SetMulti(entity, 206, 0.65);
		Attributes_SetAdd(entity, 877, 0.5);
	}
}

public void Rogue_HandExplosive_Weapon(int entity)
{
	char classname[36];
	GetEntityClassname(entity, classname, sizeof(classname));
	if(!StrContains(classname, "tf_weapon_jar") || i_WeaponArchetype[entity] == 8)
	{
		// +200% damage bonus
		Attributes_SetMulti(entity, 2, 1.5);
		Attributes_SetMulti(entity, 524, 2.5);
	}
}

public void Rogue_HandSupport_Weapon(int weapon)
{
	if(i_WeaponArchetype[weapon] == 9 || i_WeaponArchetype[weapon] == 25 || i_WeaponArchetype[weapon] == 24 || i_WeaponArchetype[weapon] == 22)
	{
		// +10 hp regen
		Attributes_SetAdd(weapon, 57, 10.0);
	}
}

public void Rogue_Item_HealingSalve(int weapon)
{
	// +1 hp regen
	Attributes_SetAdd(weapon, 57, 1.0);
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
	if(i_WeaponArchetype[entity] == 11 || i_WeaponArchetype[entity] == 5 || i_WeaponArchetype[entity] == 6)	// Or Single Pellet
	{
		// +25% fire rate
		Attributes_SetMulti(entity, 6, 0.75);
		Attributes_SetMulti(entity, 97, 0.75);
		if(i_WeaponArchetype[entity] == 6)
			Attributes_SetMulti(entity, 4, 1.5);
	}
}

public void Rogue_HandAmbusher_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 12 || i_WeaponArchetype[entity] == 13)	// Ambusher && combatant
	{
		// +5s bleed duration
		Attributes_SetAdd(entity, 149, 5.0);
		Attributes_SetMulti(entity, 6, 0.75);
	}
}
public void Rogue_HandInfinite_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 3 || i_WeaponArchetype[entity] == 10 || i_WeaponArchetype[entity] == 28)	// Infinite Fire && // Debuff && Victorian
	{
		// +3 health on hit
		if(i_WeaponArchetype[entity] == 28)
			Attributes_SetAdd(entity, 16, 15.0);
		else
			Attributes_SetAdd(entity, 16, 3.0);

		Attributes_SetMulti(entity, 205, 0.65);
	}
}

public void Rogue_HandDuelist_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 15 || i_WeaponArchetype[entity] == 14 || i_WeaponArchetype[entity] == 17)	// Duelist and abberition
	{
		// +150% damage bonus when half health
		Attributes_SetMulti(entity, 224, 2.5);
	}
}

public void Rogue_HandCaster_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 21)	// Base Caster
	{
		// +100% max mana
		Attributes_SetMulti(entity, 405, 2.0);
		Attributes_SetMulti(entity, 6, 0.5);
	}
}

public void Rogue_HandKazimierz_Weapon(int entity)
{
	if(IsWeaponKazimierz(entity) || i_WeaponArchetype[entity] == 16)	// Kazimierz and Lord
	{
		// +75% damage bonus while over half health
		Attributes_SetMulti(entity, 225, 1.75);
	}
}