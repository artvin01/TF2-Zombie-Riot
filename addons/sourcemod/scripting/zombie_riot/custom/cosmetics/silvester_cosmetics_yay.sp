

static bool b_SilvesterCosmeticEffect[MAXENTITIES];

public bool SilvesterWingsDo(int client)
{
	return b_SilvesterCosmeticEffect[client];
}

public void EnableSilvesterCosmetic(int client) 
{
	//for now block
	if(TeutonType[client] != TEUTON_NONE)
		return;

	//block entirely for now.
	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Silvester Wings [???]"));
	b_SilvesterCosmeticEffect[client] = HasWings;
}