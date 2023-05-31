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