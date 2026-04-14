#pragma semicolon 1
#pragma newdecls required

void VehicleMinecraft_Setup()
{
	if(!FileExists("models/vehicles/minecraft/minecraft_boat.mdl", true))
		return;
	
	if(!FileExists("scripts/vehicles/tf2_minecraft.txt", true))
		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_mc_boat");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/minecraft/minecraft_boat.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleMinecraft(vecPos, vecAng);
}


methodmap VehicleMinecraft < VehicleGeneric
{
	public VehicleMinecraft(const float vecPos[3], const float vecAng[3])
	{
		VehicleMinecraft obj = view_as<VehicleMinecraft>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/minecraft/minecraft_boat.mdl", "scripts/vehicles/tf2_minecraft.txt"));

		Armor_Charge[obj.index] = 2000;
		obj.m_iMaxArmor = 2000;

		return obj;
	}
}