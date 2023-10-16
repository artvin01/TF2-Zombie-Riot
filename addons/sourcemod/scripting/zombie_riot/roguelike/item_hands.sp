public void Rogue_HandMulti_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 1)	// Multi Pellet
	{
		// +35% melee resistance
		Attributes_SetMulti(entity, 206, 0.65);
	}
}

public void Rogue_HandRapid_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 2)	// Rapid Fire
	{
		// 0.5s speed on hit
		Attributes_SetAdd(entity, 877, 0.5);
	}
}

public void Rogue_HandGrenade_Weapon(int entity)
{
	char classname[36];
	GetEntityClassname(entity, classname, sizeof(classname));
	if(!StrContains(classname, "tf_weapon_jar"))
	{
		// +200% damage bonus
		Attributes_SetMulti(entity, 2, 3.0);
	}
}

public void Rogue_HandExplosive_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 8)	// Explosive Mind
	{
		// +150% jump height
		Attributes_SetMulti(entity, 524, 2.5);
	}
}

public void Rogue_HandSupport_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 9)	// Team Support
	{
		// +10 health regen
		Attributes_SetAdd(entity, 57, 10.0);
	}
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

public void Rogue_HandInfinite_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 3)	// Infinite Fire
	{
		// +3 health on hit
		Attributes_SetAdd(entity, 16, 3.0);
	}
}

public void Rogue_HandleSingle_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 5)	// Single Pellet
	{
		// +75% fire rate at low health
		Attributes_SetMulti(entity, 651, 0.25);
	}
}

public void Rogue_HandleBrawler_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 11)	// Brawler
	{
		// +50% fire rate
		Attributes_SetMulti(entity, 6, 0.5);
	}
}

public void Rogue_HandAmbusher_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 12)	// Ambusher
	{
		// +5s bleed duration
		Attributes_SetAdd(entity, 149, 5.0);
	}
}

public void Rogue_HandDebuff_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 10)	// Debuff
	{
		// +80% ranged resistance
		Attributes_SetMulti(entity, 205, 0.2);
	}
}

public void Rogue_HandAberration_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 14)	// Aberration
	{
		// +300% damage bonus when being healed
		Attributes_SetMulti(entity, 232, 4.0);
	}
}

public void Rogue_HandDuelist_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 15)	// Duelist
	{
		// +150% damage bonus when half health
		Attributes_SetMulti(entity, 224, 2.5);
	}
}

public void Rogue_HandSummoner_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 18)	// Summoner
	{
		// -90% mana cost
		Attributes_Set(entity, 733, 0.1);
	}
}

public void Rogue_HandCaster_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 21)	// Base Caster
	{
		// +100% max mana
		Attributes_Set(entity, 405, 2.0);
	}
}

public void Rogue_HandKazimierz_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == 23)	// Kazimierz
	{
		// +75% damage bonus while over half health
		Attributes_SetMulti(entity, 225, 1.75);
	}
}