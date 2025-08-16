#pragma semicolon 1
#pragma newdecls required

float f_HandOfElderMagesAntiSpam[MAXENTITIES];
void OnTakeDamage_HandOfElderMages(int client, int holding_weapon)
{
	if(b_HandOfElderMages)
	{
		//dont give twice a frame!
		if(f_HandOfElderMagesAntiSpam[holding_weapon] == GetGameTime())
			return;
		
		if(i_WeaponArchetype[holding_weapon] == 19 || i_WeaponArchetype[holding_weapon] == 20 || i_WeaponArchetype[holding_weapon] == 18) //todo: do this only with multi caster and chaincaster items
		{
			f_HandOfElderMagesAntiSpam[holding_weapon] = GetGameTime();
			Saga_ChargeReduction(client, holding_weapon, 2.0);
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