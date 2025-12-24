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
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleFullJeep(vecPos, vecAng);
}

methodmap VehicleFullJeep < VehicleGeneric
{
	public VehicleFullJeep(const float vecPos[3], const float vecAng[3])
	{
		VehicleFullJeep obj = view_as<VehicleFullJeep>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/buggy.mdl", "scripts/vehicles/jeep_test.txt"));
		
		int gun = Store_GetItemIndex("Tommygun");

		obj.m_bNoAttack = true;
		obj.AddSeat({22.0, -42.0, 12.0}, 0, gun);
		obj.AddSeat({2.0, -90.0, 34.0}, 1, gun);

		FuncShowInteractHud[obj.index] = VehicleFullJeep_ClotShowInteractHud;
		func_NPCInteract[obj.index] = VehicleFullJeep_ClotInteract;

		return obj;
	}
}

bool VehicleFullJeep_ClotShowInteractHud(VehicleFullJeep obj, int client)
{
	float ang1[3], ang2[3];
	GetEntPropVector(obj.index, Prop_Data, "m_angRotation", ang1);
	GetClientEyeAngles(client, ang2);

	if(fabs(fabs(ang1[1]) - fabs(ang2[1])) > 15.0)
		return false;
	
	SetGlobalTransTarget(client);

	if(Building_Collect_Cooldown[obj.index][client] > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", Building_Collect_Cooldown[obj.index][client] - GetGameTime());
	}
	else
	{
		char ButtonDisplay[255];
		PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
		PrintCenterText(client, "%s%t", ButtonDisplay, "Ammobox Tooltip", Ammo_Count_Ready - Ammo_Count_Used[client]);
	}
	return true;
}

bool VehicleFullJeep_ClotInteract(int client, int weapon, VehicleFullJeep obj)
{
	float ang1[3], ang2[3];
	GetEntPropVector(obj.index, Prop_Data, "m_angRotation", ang1);
	GetClientEyeAngles(client, ang2);

	if(fabs(fabs(ang1[1]) - fabs(ang2[1])) > 15.0)
		return false;
	
	if(Building_Collect_Cooldown[obj.index][client] > GetGameTime())
		return true;
	
	int UsedBoxLogic = AmmoboxUsed(client, obj.index);
	if(UsedBoxLogic >= 1)
	{
		int owner = obj.m_hDriver;
		if(owner == -1)
			owner = client;
		
		if(UsedBoxLogic >= 2)
		{
			Building_GiveRewardsUse(client, owner, 10, true, 0.35, true);
			Barracks_TryRegenIfBuilding(client);
		}

		Building_GiveRewardsUse(client, owner, 10, true, 0.35, true);
		Barracks_TryRegenIfBuilding(client);
	}
	return true;
}
