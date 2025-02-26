#pragma semicolon 1
#pragma newdecls required

public void Rogue_None_Remove()
{
	// Nothing happens when removed
}

public void Rogue_Refresh_Remove()
{
	// Refresh players when removed
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			Store_ApplyAttribs(client);
			Store_GiveAll(client, GetClientHealth(client));
		}
	}
}

static float GrigoriCoinPurseCalc()
{
	int Ingots = Rogue_GetIngots();
	
	return 150.0 / (150.0 + float(Ingots));
	//at 100 ingots, we double our attackspeed
}

public void Rogue_Item_GrigoriCoinPurse_Ally(int entity, StringMap map)
{
	float Multi = GrigoriCoinPurseCalc();
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			npc.m_fGunBonusReload *= Multi;
			npc.m_fGunBonusFireRate *= Multi;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				npc.BonusFireRate /= Multi;
			}
		}
	}
}

public void Rogue_Item_GrigoriCoinPurse_Weapon(int entity)
{
	float Multi = GrigoriCoinPurseCalc();

	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, Multi);
	if(Attributes_Has(entity, 97))
		Attributes_SetMulti(entity, 97, Multi);
	if(Attributes_Has(entity, 733))
		Attributes_SetMulti(entity, 733, Multi);
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, (1.0 / Multi));
}

public void Rogue_Item_Provoked_Anger()
{
	b_ProvokedAnger = true;
}
public void Rogue_Item_Provoked_AngerRemove()
{
	b_ProvokedAnger = false;
}

public void Rogue_Item_Malfunction_Shield()
{
	AnyShieldOnObtained();
	ShieldLogicRegen(1);
	b_MalfunctionShield = true;
}
public void Rogue_Item_Malfunction_ShieldRemove()
{
	b_MalfunctionShield = true;
}

public void Rogue_Item_Bob_Exchange_Money()
{
	//give 18 dollars
	Rogue_AddIngots(18, true);
}

public void Rogue_Item_ReleasingRadio()
{
	b_MusicReleasingRadio = true;
}
public void Rogue_Item_ReleasingRadioRemove()
{
	b_MusicReleasingRadio = false;
}

public void Rogue_Item_WrathOfItallians()
{
	b_WrathOfItallians = true;
}
public void Rogue_Item_WrathOfItalliansRemove()
{
	b_WrathOfItallians = false;
}

public void Rogue_Item_BraceletsOfAgility()
{
	b_BraceletsOfAgility = true;
}
public void Rogue_Item_BraceletsOfAgilityRemove()
{
	b_BraceletsOfAgility = false;
}

public void Rogue_Item_ElasticFlyingCape()
{
	b_ElasticFlyingCape = true;
}
public void Rogue_Item_ElasticFlyingCapeRemove()
{
	b_ElasticFlyingCape = false;
}

public void Rogue_SteelRazor_Weapon(int entity)
{
	// +15% damage bonus for melee's
	char classname[36];
	GetEntityClassname(entity, classname, sizeof(classname));
	int WeaponSlot = TF2_GetClassnameSlot(classname);
	if(i_OverrideWeaponSlot[entity] != -1)
	{
		WeaponSlot = i_OverrideWeaponSlot[entity];
	}
	if(WeaponSlot == TFWeaponSlot_Melee)
	{
		if(Attributes_Has(entity, 2))
			Attributes_SetMulti(entity, 2, 1.15);
	}
}
public void Rogue_Item_SteelRazor()
{
	b_SteelRazor = true;
}
public void Rogue_Item_SteelRazorRemove()
{
	b_SteelRazor = false;
}

public void Rogue_Item_HealthyEssence()
{
	b_HealthyEssence = true;
}
public void Rogue_Item_HealthyEssenceRemove()
{
	b_HealthyEssence = false;
}

public void Rogue_Item_FizzyDrink()
{
	b_FizzyDrink = true;
}
public void Rogue_Item_FizzyDrinkRemove()
{
	b_FizzyDrink = false;
}

bool RogueFizzyDrink()
{	
	return b_FizzyDrink;
}

public void Rogue_Item_HoverGlider()
{
	b_HoverGlider = true;
}
public void Rogue_Item_HoverGliderRemove()
{
	b_HoverGlider = false;
}

void OnTakeDamage_RogueItemGeneric(int attacker, float &damage, int damagetype, int inflictor)
{
	if(b_HoverGlider)
	{
		if(attacker <= MaxClients)
		{
			if((GetEntityFlags(attacker) & FL_ONGROUND) == 0)
			{
				damage *= 1.3;
			}
		}
	}
	if(b_SteelRazor)
	{
		if(attacker > MaxClients || inflictor > MaxClients)
		{
			if(GetTeam(attacker) == TFTeam_Red || GetTeam(inflictor) == TFTeam_Red)
			{
				//15%% more melee dmg for all allies
				if(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))
				{
					damage *= 1.15;
				}
			}
		}
	}
	if(b_SpanishSpecialisedGunpowder)
	{
		if(attacker > MaxClients || inflictor > MaxClients)
		{
			if(GetTeam(attacker) == TFTeam_Red || GetTeam(inflictor) == TFTeam_Red)
			{
				//15%% more Ranged dmg for all allies
				if(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))
				{

				}
				else
				{
					damage *= 1.15;

				}
			}
		}
	}
	if(b_NickelInjectedPack)
	{
		if(attacker > 0 && (GetTeam(attacker) == TFTeam_Red || attacker <= MaxClients))
		{
			int maxhealth;
			if(attacker <= MaxClients)
			{
				maxhealth = SDKCall_GetMaxHealth(attacker);
			}
			else
			{
				maxhealth = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
			}	
			int health = GetEntProp(attacker, Prop_Data, "m_iHealth");	
			float damageMulti;

			damageMulti = float(health) / float(maxhealth);

			damageMulti *= 1.25;

			if(damageMulti > 1.0)
			{
				damageMulti = 1.0;
			}
			damageMulti += 0.35;

			if(damageMulti > 1.0)
			{
				damage *= damageMulti;
			}
		}
	}
}


public void Rogue_Item_HandWrittenLetter()
{
	CurrentCash += 750;
	GlobalExtraCash += 750;	
}

public void Rogue_Item_HandWrittenLetter_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		//3% more building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.03);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +3% damage bonus
			npc.m_fGunBonusDamage *= 1.03;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +3% damage bonus
				npc.BonusDamageBonus *= 1.03;
			}
		}
	}
}

public void Rogue_Item_HandWrittenLetter_Weapon(int entity)
{
	// +3% damage bonus
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.03);
	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.03);
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		if(Attributes_Has(entity, 1))
			Attributes_SetMulti(entity, 1, 1.03);
	}
	//Extra damage for mediguns.
}



public void Rogue_Item_CrudeFlute()
{
	CurrentCash += 500;
	GlobalExtraCash += 500;	
}
public void Rogue_Item_CrudeFlute_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +3% max health
			int health = ReturnEntityMaxHealth(npc.index);

			health = RoundToCeil(float(health) * 1.03);

			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +3% max health
				int health = ReturnEntityMaxHealth(npc.index);

				health = RoundToCeil(float(health) * 1.03);
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
	else if(i_IsABuilding[entity])	// Building
	{

	}
}


public void Rogue_Item_ScrappedWallet()
{
	CurrentCash += 500;
	GlobalExtraCash += 500;	
}

public void Rogue_Item_ScrappedWallet_Weapon(int entity)
{
	// +1% damage bonus
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.01);
	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.01);
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		if(Attributes_Has(entity, 1))
			Attributes_SetMulti(entity, 1, 1.01);
	}
	//Extra damage for mediguns.
}
public void Rogue_Item_ScrappedWallet_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		//1% more building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.01);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +1% damage bonus
			npc.m_fGunBonusDamage *= 1.01;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +1% damage bonus
				npc.BonusDamageBonus *= 1.01;
			}
		}
	}
}

public void Rogue_Item_GoldenCoin()
{
	CurrentCash += 2000;
	GlobalExtraCash += 2000;
		
	Rogue_AddIngots(10, true);
}

public void Rogue_Item_NickelInjectedPack()
{
	b_NickelInjectedPack = true;
}

public void Rogue_Item_NickelInjectedPackRemove()
{
	b_NickelInjectedPack = false;
}


public void Rogue_Item_SpanishSpecialisedGunpowder_Weapon(int entity)
{
	// +15% damage bonus for ranged
	char classname[36];
	GetEntityClassname(entity, classname, sizeof(classname));
	int WeaponSlot = TF2_GetClassnameSlot(classname);
	if(i_OverrideWeaponSlot[entity] != -1)
	{
		WeaponSlot = i_OverrideWeaponSlot[entity];
	}

	if(WeaponSlot != TFWeaponSlot_Melee) //anything that isnt melee
	{
		if(Attributes_Has(entity, 2))
			Attributes_SetMulti(entity, 2, 1.15);
	}

	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.15);

	if(!StrContains(classname, "tf_weapon_medigun"))
	{
		if(Attributes_Has(entity, 1))
			Attributes_SetMulti(entity, 1, 1.15);
	}
}
public void Rogue_Item_SpanishSpecialisedGunpowder()
{
	b_SpanishSpecialisedGunpowder = true;
}
public void Rogue_Item_SpanishSpecialisedGunpowderRemove()
{
	b_SpanishSpecialisedGunpowder = false;
}

public void Rogue_Item_SpanishSpecialisedGunpowder_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		//15% more building damage, usually is ranged except for 1 weapon.
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.15);
	}
}

public void Rogue_Item_GenericDamage5_Weapon(int entity)
{
	// +5% damage bonus
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.05);
	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.05);

	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		if(Attributes_Has(entity, 1))
			Attributes_SetMulti(entity, 1, 1.05);
	}
}
public void Rogue_Item_GenericDamage5_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +5% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.05);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +5% damage bonus
			npc.m_fGunBonusDamage *= 1.05;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +5% damage bonus
				npc.BonusDamageBonus *= 1.05;
			}
		}
	}
}

public void Rogue_Item_GenericDamage10_Weapon(int entity)
{
	// +10% damage bonus
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, 1.1);

	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, 1.1);

	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		if(Attributes_Has(entity, 1))
			Attributes_SetMulti(entity, 1, 1.1);
	}
}
public void Rogue_Item_GenericDamage10_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +10% building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.1);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +10% damage bonus
			npc.m_fGunBonusDamage *= 1.1;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +10% damage bonus
				npc.BonusDamageBonus *= 1.1;
			}
		}
	}
}



public void Rogue_Chicken_Nugget_Box_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// +15% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 1.15);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% max health
			int health = RoundToCeil((float(ReturnEntityMaxHealth(npc.index)) * 1.15));
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +15% max health
				int health = RoundToCeil((float(ReturnEntityMaxHealth(npc.index)) * 1.15));
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}