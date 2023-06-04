public void Rogue_HandShotgun_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 13, 200, 45, 220, 448, 669, 772, 1078, 1103,
			10, 199, 415, 1141, 1153, 12, 11, 425,
			9, 141, 527, 997, 1004:
		{
			// +35% melee resistance

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 206);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 206, value * 0.65);
		}
	}
}

public void Rogue_HandPistol_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 22, 209, 160, 294, 30666, 23, 449, 773:
		{
			// 0.5s speed on hit

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 877);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 877, value + 0.5);
		}
	}
}

public void Rogue_HandGrenade_Weapon(int entity)
{
	char classname[36];
	if(!StrContains(classname, "tf_weapon_jar"))
	{
		// +200% damage bonus

		float value = 1.0;
		Address address = TF2Attrib_GetByDefIndex(entity, 2);
		if(address != Address_Null)
			value = TF2Attrib_GetValue(address);
		
		TF2Attrib_SetByDefIndex(entity, 2, value * 3.0);
	}
}

public void Rogue_HandRocket_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 18, 205, 127, 228, 237, 414, 441, 513, 658, 730, 1085, 1104:
		{
			// +150% jump height

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 524);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 524, value * 2.5);
		}
	}
}

public void Rogue_HandBison_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 442:	// Bison
		{
			// +600% damage bonus

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 2, value * 7.0);

			// +50% firing speed

			value = 1.0;
			address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 6, value * 0.5);

			// +100% clip size

			value = 1.0;
			address = TF2Attrib_GetByDefIndex(entity, 4);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 4, value * 2.0);
		}
		case 588:	// Pomson
		{
			// +100% damage bonus

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 2);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 2, value * 2.0);

			// +50% firing speed

			value = 1.0;
			address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 6, value * 0.5);

			// +100% clip size

			value = 1.0;
			address = TF2Attrib_GetByDefIndex(entity, 4);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 4, value * 2.0);
		}
	}
}

public void Rogue_HandBuff_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 129, 226, 354, 1001:
		{
			// +10 health regen

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 57);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 57, value + 10.0);
		}
	}
}

public void Rogue_HandFlame_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 21, 208, 40, 215, 594, 659, 741, 1146, 1178,
			39, 351, 595, 740, 1081:
		{
			// Afterburn -> Bleed

			float value = 3.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 208);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 149, value);
			TF2Attrib_SetByDefIndex(entity, 208, 0.0);
		}
	}
}

public void Rogue_HandLauncher_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 19, 206, 308, 996, 1007, 1151:
		{
			// Note: If tf_weapon_cannon get used, blacklist this classname

			// Begger styled reloading
			TF2Attrib_SetByDefIndex(entity, 413, 1.0);

			// +33% firing speed

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 6, value * 0.67);

			// +100% clip size

			value = 1.0;
			address = TF2Attrib_GetByDefIndex(entity, 4);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 4, value * 2.0);
		}
	}
}

public void Rogue_HandSticky_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 20, 207, 130, 265, 661, 1150:
		{
			// +6 max pipebombs

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 88);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 88, value + 6.0);

			// Detonates stickybombs near the crosshair and directly under your feet

			TF2Attrib_SetByDefIndex(entity, 119, 1.0);
		}
	}
}

public void Rogue_HandMinigun_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 15, 202, 41, 298, 312, 424, 654, 811, 832, 850:
		{
			// Bullets destroy rockets and grenades in-flight

			TF2Attrib_SetByDefIndex(entity, 323, 2.0);
		}
	}
}

public void Rogue_HandTrap_Weapon(int entity)
{
	char classname[36];
	if(!StrContains(classname, "tf_weapon_shotgun_building_rescue"))
	{
		// Firing Speed -> Reload Speed

		float value = 1.0;
		Address address = TF2Attrib_GetByDefIndex(entity, 6);
		if(address != Address_Null)
			value = TF2Attrib_GetValue(address);
		
		TF2Attrib_SetByDefIndex(entity, 97, value);

		switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case 997:	// Spike Layer
			{
				// +90% firing speed
				TF2Attrib_SetByDefIndex(entity, 6, 0.1);

				// 40/60 clip size
				TF2Attrib_SetByDefIndex(entity, 303, value > 2.0 ? 40.0 : 60.0);
			}
			case 1004:	// Aresenal
			{
				// +60% firing speed
				TF2Attrib_SetByDefIndex(entity, 6, 0.4);

				// 6 clip size
				TF2Attrib_SetByDefIndex(entity, 303, 6.0);
			}
		}
	}
}

public void Rogue_Wrangler_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 140, 1086, 30668, 528:
		{
			// +50% sentry firing speed

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 343);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 343, value * 0.5);

			// While active

			TF2Attrib_SetByDefIndex(entity, 128, 1.0);
		}
	}
}

public void Rogue_Syringe_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 17, 204, 36, 412:
		{
			// +3 health on hit

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 16);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 16, value + 3.0);
		}
	}
}

public void Rogue_Medigun_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 305, 1079, 29, 211, 35, 411, 663, 998:
		{
			// MvM Medigun Shield Lv. 1

			TF2Attrib_SetByDefIndex(entity, 499, 1.0);
		}
	}
}

public void Rogue_Sniper_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 14, 201, 230, 402, 526, 664, 752, 851, 1098, 30665:
		{
			// Hitman's Heatmaker Logic

			TF2Attrib_SetByDefIndex(entity, 116, 6.0);
			TF2Attrib_SetByDefIndex(entity, 387, 35.0);
		}
	}
}

public void Rogue_SMG_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 16, 203, 751, 1149:
		{
			// +5s mini-crits on kill

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 613);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 613, value + 5.0);
		}
	}
}

public void Rogue_Revolver_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 24, 210, 61, 161, 224, 460, 525, 1006, 1142:
		{
			// +75% fire rate at low health

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 651);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 651, value * 0.25);
		}
	}
}

public void Rogue_Bat_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 0, 190, 44, 221, 317, 325, 349, 355, 450, 452, 572, 648, 660, 30667:
		{
			// +50% fire rate

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 6, value * 0.5);
		}
	}
}

public void Rogue_Soldier_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 6, 196, 128, 154, 357, 416, 447, 775:
		{
			// +5s bleed duration

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 149);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 149, value + 5.0);
		}
	}
}

public void Rogue_Fireaxe_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 2, 192, 38, 153, 214, 326, 348, 457, 466, 594, 739, 813, 834, 1000, 1181:
		{
			// +3s afterburn duration

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 208);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 208, value + 3.0);
		}
	}
}

public void Rogue_Bottle_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 1, 191, 132, 154, 172, 266, 307, 327, 357, 404, 482, 609, 1082:
		{
			// +1 head on kill

			float value = 0.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 644);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 644, value + 1.0);
		}
	}
}

public void Rogue_Fists_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 5, 195, 41, 239, 310, 331, 426, 587, 656, 1084, 1100, 1184, 142:
		{
			// +80% ranged resistance

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 205);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 205, value * 0.2);
		}
	}
}

public void Rogue_Wrench_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 7, 197, 155, 169, 329, 589, 662:
		{
			// +200% knockback

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 252);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 252, value * 3.0);

			// While active
			
			TF2Attrib_SetByDefIndex(entity, 128, 1.0);
		}
	}
}

public void Rogue_Bonesaw_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 8, 198, 37, 173, 304, 413, 1003, 1143:
		{
			// +300% damage bonus when being healed

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 233);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 233, value * 4.0);
		}
	}
}

public void Rogue_Club_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 3, 193, 171, 232, 401:
		{
			// +150% damage bonus when half health

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 224);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 224, value * 2.5);
		}
	}
}

public void Rogue_Knife_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 4, 194, 225, 356, 461, 574, 638, 649, 665, 727:
		{
			// Kill always gibs

			TF2Attrib_SetByDefIndex(entity, 309, 1.0);
		}
	}
}

public void Rogue_FryingPan_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 264, 1071:
		{
			// -100% mana cost

			TF2Attrib_SetByDefIndex(entity, 733, 0.0);
		}
	}
}

public void Rogue_Saxxy_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 423, 954:
		{
			// +150% projectile lifetime

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 101);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 101, value * 2.5);
		}
	}
}

public void Rogue_Freedom_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 880, 1127:
		{
			// +50% fire rate

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 6, value * 0.5);

			// -50% mana cost

			value = 0.0;
			address = TF2Attrib_GetByDefIndex(entity, 733);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 733, value * 0.5);
		}
	}
}

public void Rogue_Skull_Weapon(int entity)
{
	switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 939, 30758:
		{
			// +100% max mana

			float value = 1.0;
			Address address = TF2Attrib_GetByDefIndex(entity, 405);
			if(address != Address_Null)
				value = TF2Attrib_GetValue(address);
			
			TF2Attrib_SetByDefIndex(entity, 405, value * 2.0);
		}
	}
}