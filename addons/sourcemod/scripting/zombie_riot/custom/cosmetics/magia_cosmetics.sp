
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