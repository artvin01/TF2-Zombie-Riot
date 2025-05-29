#pragma semicolon 1
#pragma newdecls required

void VehicleAmbulance_Setup()
{
//	PrintToChatAll("test VehicleAmbulance_Setup test");
//	if(!IsFileInDownloads("models/vehicles/ambulance.mdl"))
//		return;
//	PrintToChatAll("test VehicleAmbulance_Setup yes");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ambulance");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_ambulance");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/vehicles/ambulance.mdl");
	Vehicle_PrecacheSounds();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return VehicleAmbulance(vecPos, vecAng);
}

methodmap VehicleAmbulance < VehicleGeneric
{
	public VehicleAmbulance(const float vecPos[3], const float vecAng[3])
	{
		VehicleAmbulance obj = view_as<VehicleAmbulance>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/vehicles/ambulance.mdl", "scripts/vehicles/tf2_ambulance.txt"));
		
		SetEntProp(obj.index, Prop_Send, "m_nSkin", GetURandomInt() % 2);

		obj.m_bNoAttack = true;
		obj.AddSeat({16.0, 6.0, 12.0}, 0);	// Side Seat

		// Back Seats
		obj.AddSeat({-25.0, -60.0, 22.0}, 1);	// Left Center
		obj.AddSeat({25.0, -30.0, 22.0}, 2);		// Right Front
		obj.AddSeat({25.0, -88.0, 22.0}, 3);		// Right Back
		obj.AddSeat({-25.0, -30.0, 22.0}, 4);	// Left Front
		obj.AddSeat({-25.0, -88.0, 22.0}, 5);	// Left Back
		obj.AddSeat({25.0, -60.0, 22.0}, 6);		// Right Center

		FuncShowInteractHud[obj.index] = ClotShowInteractHud;
		func_NPCInteract[obj.index] = ClotInteract;
		func_NPCThink[obj.index] = ClotThink;

		obj.m_flNextThinkTime = 0.0;
		obj.m_flNextMeleeAttack = 0.0;

		return obj;
	}
}

static bool ClotShowInteractHud(VehicleFullJeep obj, int client)
{
	if(obj.m_hDriver == -1)
		return false;
	
	float ang1[3], ang2[3];
	GetEntPropVector(obj.index, Prop_Data, "m_angRotation", ang1);
	GetClientEyeAngles(client, ang2);

	if(fabs(fabs(ang1[1]) - fabs(ang2[1])) > 15.0)
		return false;
	

	if(Building_Collect_Cooldown[obj.index][client] > GetGameTime())
	{
		PrintCenterText(client, "%T", "Object Cooldown", client,Building_Collect_Cooldown[obj.index][client] - GetGameTime());
	}
	else
	{
		PrintCenterText(client, "%T", "Healing Station Tooltip", client);
	}
	return true;
}

static bool ClotInteract(int client, int weapon, VehicleFullJeep obj)
{
	int owner = obj.m_hDriver;
	if(owner == -1)
		return false;
	
	float ang1[3], ang2[3];
	GetEntPropVector(obj.index, Prop_Data, "m_angRotation", ang1);
	GetClientEyeAngles(client, ang2);

	if(fabs(fabs(ang1[1]) - fabs(ang2[1])) > 15.0)
		return false;
	
	if(Building_Collect_Cooldown[obj.index][client] > GetGameTime())
		return true;
	
	ApplyBuildingCollectCooldown(obj.index, client, 90.0);
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	float HealAmmount = 30.0;
	if(IsValidClient(owner))
		HealAmmount *= Attributes_GetOnPlayer(owner, 8, true);
	
	Building_GiveRewardsUse(client, owner, 15, true, 0.4, true);
	HealEntityGlobal(owner, client, HealAmmount, _, 3.0);
	return true;
}

static void ClotThink(VehicleFullJeep obj)
{
	float gameTime = GetGameTime(obj.index);
	if(obj.m_flNextThinkTime > gameTime)
		return;
	
	obj.m_flNextThinkTime = gameTime + 0.5;

	int owner = obj.m_hDriver;
	if(owner == -1)
		return;
	
	// Search for downed players, then pick them up
	float pos1[3], pos2[3];
	GetEntPropVector(obj.index, Prop_Data, "m_vecAbsOrigin", pos1); 
	for(int target = 1; target <= MaxClients; target++) 
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE && dieingstate[target] && Vehicle_Driver(target) == -1)
		{
			GetClientAbsOrigin(target, pos2); 
			
			float distance = GetVectorDistance(pos1, pos2, true); 
			if(distance < 60000.0)
			{
				if(Vehicle_Enter(obj.index, target))
					b_LeftForDead[target] = true;
			}				
		}
	}

	// Heal the driver and all passengers
	if(obj.m_flNextMeleeAttack < gameTime)
	{
		obj.m_flNextMeleeAttack = gameTime + 2.9;

		float HealAmmount = 1.0;
		if(IsValidClient(owner))
			HealAmmount *= Attributes_GetOnPlayer(owner, 8, true);
		
		float selfHeal = 2.0;
		for(int i; i < VEHICLE_MAX_SEATS; i++)
		{
			int passenger = GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i);
			if(passenger != -1)
			{
				HealEntityGlobal(owner, passenger, HealAmmount, _, 3.0);
				selfHeal += 1.0;
			}
		}

		HealEntityGlobal(owner, owner, HealAmmount * selfHeal, _, 3.0);
	}
}
