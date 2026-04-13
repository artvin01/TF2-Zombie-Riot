#pragma semicolon 1
#pragma newdecls required

void VehicleMinecraft_Setup()
{
	if(!FileExists("models/mcmodelpack/entities/minecart-empty.mdl", true))
		return;
	
	if(!FileExists("scripts/vehicles/tf2_minecraft.txt", true))
		return;
	/*
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_mc_minecart");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	*/
}

static void ClotPrecache()
{
	PrecacheModel("models/mcmodelpack/entities/minecart-empty.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/mcmodelpack/entities/minecart-empty.mdl", "scripts/vehicles/tf2_minecraft.txt");
}
