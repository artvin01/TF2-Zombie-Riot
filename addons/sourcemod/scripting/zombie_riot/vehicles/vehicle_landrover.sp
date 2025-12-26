#pragma semicolon 1
#pragma newdecls required

void VehicleLandrover_Setup()
{
//	if(!IsFileInDownloads("models/vehicles/landrover.mdl"))
//		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Landrover");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_landrover");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/landrover.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleLandrover(vecPos, vecAng);
}

methodmap VehicleLandrover < VehicleGeneric
{
	public VehicleLandrover(const float vecPos[3], const float vecAng[3])
	{
		VehicleLandrover obj = view_as<VehicleLandrover>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/landrover.mdl", "scripts/vehicles/tf2_landrover.txt"));
		
		obj.m_bNoAttack = true;
		obj.AddSeat({18.0, -14.0, 34.0}, 0);		// Side Seat
		obj.AddSeat({-22.0, -68.0, 28.0}, 1, -1);	// Back Left
		obj.AddSeat({22.0, -68.0, 28.0}, 2, -1);		// Back Right

		return obj;
	}
}
