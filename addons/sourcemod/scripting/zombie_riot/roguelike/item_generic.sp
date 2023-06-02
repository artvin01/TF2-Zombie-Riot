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

float GrigoriCoinPurseCalc()
{
	int Ingots = Rogue_GetIngots();
	
	return(Pow(0.993, (float(Ingots))));
	//at 100 ingots, we double our attackspeed minimum
}

public void Rogue_Item_GrigoriCoinPurse_Ally(int entity, StringMap map)
{
	float Multi = GrigoriCoinPurseCalc();
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunBonusReload *= Multi;
			npc.m_fGunBonusFireRate *= Multi;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				npc.BonusFireRate *= Multi;
			}
		}
	}
}

public void Rogue_Item_GrigoriCoinPurse_Weapon(int entity)
{
	float Multi = GrigoriCoinPurseCalc();

	Address address = TF2Attrib_GetByDefIndex(entity, 6);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(address) * Multi);
	
	address = TF2Attrib_GetByDefIndex(entity, 97);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 97, TF2Attrib_GetValue(address) * Multi);

	address = TF2Attrib_GetByDefIndex(entity, 733);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 733, TF2Attrib_GetValue(address) * Multi);

	address = TF2Attrib_GetByDefIndex(entity, 8);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 8, TF2Attrib_GetValue(address) * (1.0 / Multi)); //invert it for this.

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
	Rogue_AddIngots(18);
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

public void Rogue_Item_HealingSalve()
{
	b_HealingSalve = true;
}
public void Rogue_Item_HealingSalveRemove()
{
	b_HealingSalve = false;
}

void Rogue_HealingSalve(int client, int &flHealth, flMaxHealth)
{
	if(b_HealingSalve)
	{
		if(flHealth < flMaxHealth)
		{
			int healing_Amount = 1;
					
			int newHealth = flHealth + healing_Amount;
						
			if(newHealth >= flMaxHealth)
			{
				healing_Amount -= newHealth - flMaxHealth;
				newHealth = flMaxHealth;
			}
			ApplyHealEvent(client, healing_Amount);
						
			SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
			flHealth = newHealth;
		}	
	}
}

public void Rogue_SteelRazor_Weapon(int entity)
{
	// +15% damage bonus
	Address address = TF2Attrib_GetByDefIndex(entity, 2);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(address) * 1.15);
	
	address = TF2Attrib_GetByDefIndex(entity, 410);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 410, TF2Attrib_GetValue(address) * 1.15);

	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(!StrEqual(buffer, "tf_weapon_medigun"))
	{
		address = TF2Attrib_GetByDefIndex(entity, 1);
		if(address != Address_Null)
			TF2Attrib_SetByDefIndex(entity, 1, TF2Attrib_GetValue(address) * 1.15);
	}
	//Extra damage for mediguns.
}

public void Rogue_SteelRazor_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		//15% more building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.15);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunRangeBonus *= 1.15;
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

public void Rogue_Item_HealthyEssence()
{
	b_HealthyEssence = true;
}
public void Rogue_Item_HealthyEssenceRemove()
{
	b_HealthyEssence = false;
}

public void Rogue_Item_ChickenNuggetBox()
{
	b_ChickenNuggetBox = true;
}
public void Rogue_Item_ChickenNuggetBoxRemove()
{
	b_ChickenNuggetBox = false;
}