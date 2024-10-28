#pragma semicolon 1
#pragma newdecls required

public bool Plots_Mining_Copper(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Copper Ore");
	return false;
}

public bool Plots_Mining_DirtyCopper(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Dirty Copper");
	return false;
}

public bool Plots_Mining_Iron(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Iron Ore");
	return false;
}

public bool Plots_Mining_DirtyIron(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Dirty Iron");
	return false;
}

public bool Plots_Mining_Bofazem(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Bofazem Ore");
	return false;
}

public bool Plots_Mining_Tin(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "TIN ORE");
	return false;
}

public bool Plots_Mining_Mineral(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Mineral Deposit");
	return false;
}

public bool Plots_Mining_Quarried(int entity, BuildEnum build, int client, int weapon)
{
	if(client)
		return EquipPickaxe(client, weapon);
	
	strcopy(c_NpcName[entity], sizeof(c_NpcName[]), "Quarried Rock");
	return false;
}

static bool EquipPickaxe(int client, int weapon)
{
	if(!Plots_CanInteractHere(client))
		return false;
	
	bool pick = (weapon != -1 && EntityFuncAttack[weapon] == Mining_PickaxeM1);

	if(pick)
	{
		Store_SwitchToWeaponSlot(client, 2);
	}
	else if(!Store_SwitchToWeaponSlot(client, 3))
	{
		SPrintToChat(client, "You must equip a pickaxe!");
	}

	return true;
}