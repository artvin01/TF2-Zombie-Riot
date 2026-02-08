#pragma semicolon 1
#pragma newdecls required

void VehicleFullJeep_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Scout Car");
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
		
		obj.m_iGunIndex = -1;
		obj.AddSeat({22.0, -42.0, 12.0}, 0);
		obj.AddSeat({2.0, -90.0, 34.0}, 1);

		FuncShowInteractHud[obj.index] = VehicleFullJeep_ClotShowInteractHud;
		func_NPCInteract[obj.index] = VehicleFullJeep_ClotInteract;
		func_NPCThink[obj.index] = VehicleFullJeep_ClotThink;

		return obj;
	}
}

bool VehicleFullJeep_LookingBehindCar(int entity, int client)
{
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);

	float ang[3], vec1[3], vec2[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	ang[1] += 90.0;

	// Shift position to back of car
	GetAngleVectors(ang, ang, NULL_VECTOR, vec2);
	vec1 = ang;
	ScaleVector(vec1, -93.0);
	ScaleVector(vec2, 32.0);

	AddVectors(pos, vec1, vec1);
	AddVectors(vec1, vec2, vec1);
	
	// Vector of positions
	GetClientEyePosition(client, pos);
	SubtractVectors(pos, vec1, pos);
	NormalizeVector(pos, pos);

	// Vector of where player is looking
	GetClientEyeAngles(client, vec1);
	GetAngleVectors(vec1, vec1, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vec1, vec1);

	// Looking at the ammo box
	if(GetVectorDotProduct(pos, vec1) > -0.9)
		return false;
	
	// Looking from the back of the car
	NormalizeVector(ang, ang);
	return GetVectorDotProduct(ang, vec1) > 0.2;
}

bool VehicleFullJeep_ClotShowInteractHud(VehicleFullJeep obj, int client)
{
	if(!VehicleFullJeep_LookingBehindCar(obj.index, client))
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
	if(!VehicleFullJeep_LookingBehindCar(obj.index, client))
		return false;
	
	if(Building_Collect_Cooldown[obj.index][client] > GetGameTime())
		return true;
	
	if((Ammo_Count_Ready - Ammo_Count_Used[client]) < 1)
		return true;
	
	int UsedBoxLogic = AmmoboxUsed(client, obj.index);
	if(UsedBoxLogic >= 1)
	{
		int owner = obj.m_hDriver;
		if(owner == -1)
			owner = client;
		
		if(UsedBoxLogic >= 2)
		{
			Building_GiveRewardsUse(client, owner, 10, true, 0.5, true);
			Barracks_TryRegenIfBuilding(client);
		}
		Building_GiveRewardsUse(client, owner, 10, true, 0.5, true);
		Barracks_TryRegenIfBuilding(client);
	}
	obj.m_flAttackHappens = GetGameTime(obj.index) + 999999.4;
	return true;
}

void VehicleFullJeep_ClotThink(VehicleFullJeep obj)
{
	if(obj.m_flAttackHappens)
	{
		float gameTime = GetGameTime(obj.index);

		if(obj.m_flAttackHappens > 999999.9)
		{
			obj.SetActivity("ammo_open", true);
			//obj.SetPlaybackRate(0.5);	
			obj.m_flAttackHappens = gameTime + 0.6;
		}
		else if(obj.m_flAttackHappens < gameTime)
		{
			obj.SetActivity("ammo_close", true);
			//obj.SetPlaybackRate(0.5);
			obj.m_flAttackHappens = 0.0;
		}
	}
}
