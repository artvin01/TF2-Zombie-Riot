
void OnTakeDamage_HandOfElderMages(int client, int holding_weapon)
{
	if(b_HandOfElderMages)
	{
		if(i_WeaponArchetype[holding_weapon] == 19 || i_WeaponArchetype[holding_weapon] == 20) //todo: do this only with multi caster and chaincaster items
		{
			Saga_ChargeReduction(client, holding_weapon, 1.0);
		}	
	}
}

public void Rogue_Item_HandOfElderMages()
{
	b_HandOfElderMages = true;
}
public void Rogue_Item_HandOfElderMagesRemoved()
{
	b_HandOfElderMages = false;
}