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
		
		if(i_WeaponArchetype[holding_weapon] == Archetype_Splash || i_WeaponArchetype[holding_weapon] == Archetype_Drone)
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