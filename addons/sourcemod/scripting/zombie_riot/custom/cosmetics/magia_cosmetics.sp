
static bool b_MagiaCosmeticEffect[MAXENTITIES];

public bool MagiaWingsDo(int client)
{
	return b_MagiaCosmeticEffect[client];
}

public void EnableMagiaCosmetic(int client) 
{
	//for now block
	if(TeutonType[client] != TEUTON_NONE)
		return;

	//block entirely for now.
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Magia Wings [???]"));
	b_MagiaCosmeticEffect[client] = HasWings;
}
int MagiaWingsType(int client)
{
	int type = WINGS_TWIRL;	//default to twirl's wings.

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(!IsValidEntity(weapon))
		return type;

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_IMPACT_LANCE: type = WINGS_LANCELOT;	//time to cosplay as a lancelot.
		case WEAPON_GRAVATON_WAND: type = WINGS_RULIANA;
	}
	return type;

}