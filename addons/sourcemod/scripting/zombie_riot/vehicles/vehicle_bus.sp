#pragma semicolon 1
#pragma newdecls required

void VehicleBus_Setup()
{
//	if(!IsFileInDownloads("models/vehicles/bus001.mdl"))
//		return;
	
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

		obj.m_iGunIndex = -1;

		// Bottom
		obj.AddSeat({-44.0, 108.0, 32.0}, 0);	// Front Left
		obj.AddSeat({44.0, 110.0, 32.0}, 1);		// Front Right
		obj.AddSeat({-44.0, -82.0, 32.0}, 2);	// 1 Left
		obj.AddSeat({44.0, -82.0, 32.0}, 3);		// 1 Right
		obj.AddSeat({-44.0, -146.0, 32.0}, 4);	// 2 Left
		obj.AddSeat({44.0, -146.0, 32.0}, 5);	// 2 Right
		obj.AddSeat({-44.0, -196.0, 32.0}, 6);	// 3 Left
		obj.AddSeat({44.0, -196.0, 32.0}, 7);	// 3 Right
		obj.AddSeat({0.0, -196.0, 32.0}, 8);		// 3 Center

		// Top
		obj.AddSeat({26.0, 180.0, 112.0}, 9);
		obj.AddSeat({-26.0, 180.0, 112.0}, 10);
		obj.AddSeat({26.0, 130.0, 112.0}, 11);
		obj.AddSeat({-26.0, 130.0, 112.0}, 12);
		obj.AddSeat({26.0, 80.0, 112.0}, 13);
		obj.AddSeat({-26.0, 80.0, 112.0}, 14);
		obj.AddSeat({-26.0, 30.0, 112.0}, 15);
		obj.AddSeat({26.0, -20.0, 112.0}, 16);
		obj.AddSeat({-26.0, -20.0, 112.0}, 17);
		obj.AddSeat({26.0, -70.0, 112.0}, 18);
		obj.AddSeat({-26.0, -70.0, 112.0}, 19);
		obj.AddSeat({26.0, -120.0, 112.0}, 20);
		obj.AddSeat({-26.0, -120.0, 112.0}, 21);
		obj.AddSeat({26.0, -170.0, 112.0}, 22);
		obj.AddSeat({-26.0, -170.0, 112.0}, 23);

		return obj;
	}
}
