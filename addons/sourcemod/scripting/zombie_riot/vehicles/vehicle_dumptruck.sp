#pragma semicolon 1
#pragma newdecls required

void VehicleDumpTruck_Setup()
{
//	if(IsFileInDownloads("models/vehicles/dumptruck.mdl"))
	{
		NPCData data;
		strcopy(data.Name, sizeof(data.Name), "Dump Truck");
		strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_dumptruck");
		data.Category = Type_Hidden;
		data.Func = ClotSummon;
		data.Precache = ClotPrecache;
		NPC_Add(data);
	}
	
//	if(IsFileInDownloads("models/vehicles/dumptruck_empty_v2.mdl"))
	{
		NPCData data;
		strcopy(data.Name, sizeof(data.Name), "Dump Truck");
		strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_dumptruck_empty");
		data.Category = Type_Hidden;
		data.Func = ClotSummonEmpty;
		data.Precache = ClotPrecache;
		NPC_Add(data);
	}
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/dumptruck.mdl");
	PrecacheModel("models/vehicles/dumptruck_empty_v2.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleDumpTruck(vecPos, vecAng, "");
}

static any ClotSummonEmpty(int client, float vecPos[3], float vecAng[3])
{
	return VehicleDumpTruck(vecPos, vecAng, "empty");
}

methodmap VehicleDumpTruck < VehicleGeneric
{
	public VehicleDumpTruck(const float vecPos[3], const float vecAng[3], const char[] data)
	{
		VehicleDumpTruck obj = view_as<VehicleDumpTruck>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, data[0] ? "models/vehicles/dumptruck_empty_v2.mdl" : "models/vehicles/dumptruck.mdl", "scripts/vehicles/tf2_dumptruck.txt"));
		
		obj.m_iGunIndex = -1;
		obj.AddSeat({18.0, -26.0, 54.0}, 0);	// Side Seat

		if(data[0])
		{
			obj.AddSeat({-32.0, -102.0, 62.0}, 1);	// Left Back
			obj.AddSeat({26.0, -158.0, 62.0}, 2);	// Right Back
			obj.AddSeat({-32.0, -158.0, 62.0}, 3);	// Left Front
			obj.AddSeat({26.0, -102.0, 62.0}, 4);	// Right Front
		}
		else
		{
			obj.AddSeat({0.0, -122.0, 108.0}, 1);	// Back
		}

		return obj;
	}
}
