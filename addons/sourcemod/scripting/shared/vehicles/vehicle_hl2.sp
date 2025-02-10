#pragma semicolon 1
#pragma newdecls required

void VehicleHL2_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ATV");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_jeep");
	data.Category = Type_Hidden;
	data.Func = ClotSummonJeep;
	data.Precache = ClotPrecache;
	NPC_Add(data);

	strcopy(data.Name, sizeof(data.Name), "Airboat");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_airboat");
	data.Category = Type_Hidden;
	data.Func = ClotSummonAirboat;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/buggy.mdl");
	PrecacheModel("models/airboat.mdl");

	if(LibraryExists("LoadSoundscript"))
	{
		char soundname[256];
		SoundScript soundscript = LoadSoundScript("scripts/game_sounds_vehicles.txt");
		for(int i = 0; i < soundscript.Count; i++)
		{
			SoundEntry entry = soundscript.GetSound(i);
			entry.GetName(soundname, sizeof(soundname));
			PrecacheScriptSound(soundname);
		}
	}
}

static any ClotSummonJeep(int client, float vecPos[3], float vecAng[3])
{
	return VehicleJeep(vecPos, vecAng);
}

methodmap VehicleJeep < VehicleGeneric
{
	public VehicleJeep(const float vecPos[3], const float vecAng[3])
	{
		VehicleJeep npc = view_as<VehicleJeep>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/buggy.mdl", "scripts/vehicles/jeep_test.txt"));
		
		return npc;
	}
}

static any ClotSummonAirboat(int client, float vecPos[3], float vecAng[3])
{
	return VehicleAirboat(vecPos, vecAng);
}

methodmap VehicleAirboat < VehicleGeneric
{
	public VehicleAirboat(const float vecPos[3], const float vecAng[3])
	{
		VehicleAirboat npc = view_as<VehicleAirboat>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_AIRBOAT_RAYCAST, "models/airboat.mdl", "scripts/vehicles/airboat.txt"));
		
		return npc;
	}
}