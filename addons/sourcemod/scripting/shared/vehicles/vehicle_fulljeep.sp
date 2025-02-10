#pragma semicolon 1
#pragma newdecls required

void VehicleFullJeep_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ATV");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_fulljeep");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/buggy.mdl");

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

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleFullJeep(vecPos, vecAng);
}

methodmap VehicleFullJeep < VehicleGeneric
{
	public VehicleFullJeep(const float vecPos[3], const float vecAng[3])
	{
		VehicleFullJeep npc = view_as<VehicleFullJeep>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/buggy.mdl", "scripts/vehicles/jeep_test.txt"));
		
		npc.m_bNoAttack = true;
		SetEntPropVector(npc.index, Prop_Data, "m_vecSeatPos", {22.0, -42.0, 12.0}, 0);
		SetEntPropVector(npc.index, Prop_Data, "m_vecSeatPos", {2.0, -90.0, 34.0}, 1);

		return npc;
	}
}
