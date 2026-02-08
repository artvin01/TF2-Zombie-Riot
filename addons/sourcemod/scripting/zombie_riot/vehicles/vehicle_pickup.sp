#pragma semicolon 1
#pragma newdecls required

void VehiclePickup_Setup()
{
//	if(!IsFileInDownloads("models/vehicles/pickup03.mdl"))
//		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Pickup Truck");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_pickup");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/pickup03.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehiclePickup(vecPos, vecAng);
}

methodmap VehiclePickup < VehicleGeneric
{
	public VehiclePickup(const float vecPos[3], const float vecAng[3])
	{
		VehiclePickup obj = view_as<VehiclePickup>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/pickup03.mdl", "scripts/vehicles/tf2_pickup.txt"));
		
		SetEntProp(obj.index, Prop_Send, "m_nSkin", GetURandomInt() % 2);
		
		obj.m_iGunIndex = -1;
		obj.AddSeat({20.0, -96.0, 40.0}, 0);	// Back Right
		obj.AddSeat({-20.0, -44.0, 40.0}, 1);// Front Left
		obj.AddSeat({20.0, -44.0, 40.0}, 2);	// Back Left
		obj.AddSeat({-20.0, -96.0, 40.0}, 3);// Front Right
		obj.AddSeat({12.0, 12.0, 30.0}, 4);	// Side Seat

		return obj;
	}
}
