#pragma semicolon 1
#pragma newdecls required

enum
{
	NO_BUFF 						= 0,
	MELEE_BUFF_2 					= 1,
	RANGED_BUFF_2 					= 2,
	MAGE_BUFF_2 					= 3,
}

void HealingPotion_Map_Start()
{
	Zero(f_HealingPotionDuration);
	Zero(f_HealingPotionEffect);
}

public float Heal_HealingPotion_Melee2(int client, int index, char name[48])
{
	f_HealingPotionDuration[client] = GetGameTime() + 10.0;
	f_HealingPotionEffect[client] = MELEE_BUFF_2;
	return 	Ammo_HealingSpell(client, index, name);
}

public float Heal_HealingPotion_Ranged2(int client, int index, char name[48])
{
	f_HealingPotionDuration[client] = GetGameTime() + 10.0;
	f_HealingPotionEffect[client] = RANGED_BUFF_2;
	return 	Ammo_HealingSpell(client, index, name);
}

public float Heal_HealingPotion_Mage2(int client, int index, char name[48])
{
	f_HealingPotionDuration[client] = GetGameTime() + 10.0;
	f_HealingPotionEffect[client] = MAGE_BUFF_2;
	return 	Ammo_HealingSpell(client, index, name);
}




