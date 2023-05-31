/*
	public void Rouge_Ally_Spearhead(int entity)
	{
		
	}
	
	public void Rouge_Enemy_Spearhead(int entity)
	{
		
	}
*/

public void Rouge_Collect_Spearhead()
{
	b_SpearheadSquad = true;
}
public void Rouge_Collect_SpearheadRemove()
{
	b_SpearheadSquad = false;
}

public void Rouge_Item_GrigoriCoinPurse()
{
	b_GrigoriCoinPurse = true;
}
public void Rouge_Item_GrigoriCoinPurseRemove()
{
	b_GrigoriCoinPurse = false;
}

public void Rouge_Item_Provoked_Anger()
{
	b_ProvokedAnger = true;
}
public void Rouge_Item_Provoked_AngerRemove()
{
	b_ProvokedAnger = false;
}

public void Rouge_Item_Malfunction_Shield()
{
	AnyShieldOnObtained();
	ShieldLogicRegen(1);
	b_MalfunctionShield = true;
}
public void Rouge_Item_Malfunction_ShieldRemove()
{
	b_MalfunctionShield = true;
}

public void Rouge_Item_Bob_Exchange_Money()
{
	//give 18 dollars
}

public void Rouge_Item_ReleasingRadio()
{
	b_MusicReleasingRadio = true;
}
public void Rouge_Item_ReleasingRadioRemove()
{
	b_MusicReleasingRadio = false;
}

public void Rouge_Item_WrathOfItallians()
{
	b_WrathOfItallians = true;
}
public void Rouge_Item_WrathOfItalliansRemove()
{
	b_WrathOfItallians = false;
}

public void Rouge_Item_BraceletsOfAgility()
{
	b_BraceletsOfAgility = true;
}
public void Rouge_Item_BraceletsOfAgilityRemove()
{
	b_BraceletsOfAgility = false;
}

public void Rouge_Item_ElasticFlyingCape()
{
	b_ElasticFlyingCape = true;
}
public void Rouge_Item_ElasticFlyingCapeRemove()
{
	b_ElasticFlyingCape = false;
}

public void Rouge_Item_HealingSalve()
{
	b_HealingSalve = true;
}
public void Rouge_Item_HealingSalveRemove()
{
	b_HealingSalve = false;
}

void Rouge_HealingSalve(int client, int &flHealth, flMaxHealth)
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

public void Rouge_Item_SteelRazor()
{
	b_SteelRazor = true;
}
public void Rouge_Item_SteelRazorRemove()
{
	b_SteelRazor = false;
}

public void Rouge_Item_HealthyEssence()
{
	b_HealthyEssence = true;
}
public void Rouge_Item_HealthyEssenceRemove()
{
	b_HealthyEssence = false;
}

public void Rouge_Item_ChickenNuggetBox()
{
	b_ChickenNuggetBox = true;
}
public void Rouge_Item_ChickenNuggetBoxRemove()
{
	b_ChickenNuggetBox = false;
}