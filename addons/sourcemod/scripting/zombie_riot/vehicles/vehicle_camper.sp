#pragma semicolon 1
#pragma newdecls required

void VehicleCamper_Setup()
{
//	if(!IsFileInDownloads("models/vehicles/camper.mdl"))
//		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Camper Van");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_camper");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/camper.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleCamper(vecPos, vecAng);
}

methodmap VehicleCamper < VehicleGeneric
{
	public VehicleCamper(const float vecPos[3], const float vecAng[3])
	{
		VehicleCamper obj = view_as<VehicleCamper>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/camper.mdl", "scripts/vehicles/tf2_camper.txt"));
		
		obj.m_iGunIndex = -1;
		obj.AddSeat({14.0, 0.0, 26.0}, 0);	// Side Seat
		obj.AddSeat({0.0, -94.0, 118.0}, 1);	// Back Roof
		obj.AddSeat({0.0, 0.0, 130.0}, 2);	// Front Roof

		FuncShowInteractHud[obj.index] = VehicleFullJeep_ClotShowInteractHud;
		func_NPCInteract[obj.index] = VehicleFullJeep_ClotInteract;

		return obj;
	}
}
