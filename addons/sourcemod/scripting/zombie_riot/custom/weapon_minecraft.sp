#pragma semicolon 1
#pragma newdecls required

public void Minecraft_BuyFiveSand(int client)
{
	MC_SetBlockInv("sand", client, MC_GetBlockInv("sand", client) + 5);
}

public void Minecraft_BuyTenRedSand(int client)
{
	MC_SetBlockInv("red_sand", client, MC_GetBlockInv("red_sand", client) + 10);
}

public void Minecraft_BuyTenGravel(int client)
{
	MC_SetBlockInv("gravel", client, MC_GetBlockInv("gravel", client) + 10);
}

public void Minecraft_Attack(int client, int weapon, const char[] classname, bool &result)
{
	SetEntPropString(weapon, Prop_Data, "m_iName", "pickaxe");
}

public void Minecraft_AltFire(int client, int weapon, const char[] classname, bool &result)
{
	MC_OpenMenu(client, false);
}