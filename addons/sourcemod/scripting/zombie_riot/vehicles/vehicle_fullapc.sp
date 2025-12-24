#pragma semicolon 1
#pragma newdecls required

void VehicleFullAPC_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ATV");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_fullapc");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/combine_apc.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleFullAPC(vecPos, vecAng);
}

methodmap VehicleFullAPC < VehicleGeneric
{
	public VehicleFullAPC(const float vecPos[3], const float vecAng[3])
	{
		VehicleFullAPC obj = view_as<VehicleFullAPC>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/combine_apc.mdl", "scripts/vehicles/apc.txt"));
		
		int gun = Store_GetItemIndex("Tommygun");

		obj.m_bNoAttack = true;
		obj.AddSeat({22.0, -42.0, 12.0}, 0, gun);
		obj.AddSeat({2.0, -90.0, 34.0}, 1, gun);

		return obj;
	}
}
