#pragma semicolon 1
#pragma newdecls required

void VehicleBus_Setup()
{
	if(!IsFileInDownloads("models/vehicles/bus001.mdl"))
		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bus");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_bus");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/bus001.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleBus(vecPos, vecAng);
}

methodmap VehicleBus < VehicleGeneric
{
	public VehicleBus(const float vecPos[3], const float vecAng[3])
	{
		VehicleBus obj = view_as<VehicleBus>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/bus001.mdl", "scripts/vehicles/tf2_bus.txt"));
		
		SetEntProp(obj.index, Prop_Send, "m_nSkin", GetURandomInt() % 2);

		obj.m_bNoAttack = true;
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {-44.0, 108.0, 32.0}, 0);	// Front Left
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {44.0, 110.0, 32.0}, 1);		// Front Right
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {-44.0, -82.0, 32.0}, 2);	// 1 Left
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {44.0, -82.0, 32.0}, 3);		// 1 Right
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {-44.0, -146.0, 32.0}, 4);	// 2 Left
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {44.0, -146.0, 32.0}, 5);	// 2 Right
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {-44.0, -196.0, 32.0}, 6);	// 3 Left
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {44.0, -196.0, 32.0}, 7);	// 3 Right
		SetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", {0.0, -196.0, 32.0}, 8);		// 3 Center

		return obj;
	}
}
