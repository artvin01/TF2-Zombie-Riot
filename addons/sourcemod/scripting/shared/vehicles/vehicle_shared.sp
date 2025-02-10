#pragma semicolon 1
#pragma newdecls required

// https://github.com/Mikusch/source-vehicles
// https://github.com/ficool2/vscript_vehicle

enum VehicleType
{
	VEHICLE_TYPE_CAR_WHEELS = (1 << 0),	// hl2_jeep
	VEHICLE_TYPE_CAR_RAYCAST = (1 << 1),
	VEHICLE_TYPE_JETSKI_RAYCAST = (1 << 2),
	VEHICLE_TYPE_AIRBOAT_RAYCAST = (1 << 3)	// hl2_airboat
}

methodmap VehicleGeneric < CClotBody
{
	public VehicleGeneric(const float vecPos[3], const float vecAng[3], VehicleType type, const char[] model, const char[] script)
	{
		int obj = CreateEntityByName("obj_vehicle");
		
		DispatchKeyValue(obj, "model", model);
		DispatchKeyValue(obj, "vehiclescript", script);
		DispatchKeyValue(obj, "spawnflags", "1");
		DispatchKeyValueVector(obj, "origin", vecPos);
		DispatchKeyValueVector(obj, "angles", vecAng);
		SetEntProp(obj, Prop_Data, "m_nVehicleType", type);

		DispatchSpawn(obj);

		i_IsVehicle[obj] = 2;
		i_TargetToWalkTo[obj] = -1;
		fl_NextRunTime[obj] = GetGameTime(obj) + 1.0;
		view_as<CClotBody>(obj).bCantCollidieAlly = true;
		b_IsAProjectile[obj] = true;

		SDKHook(obj, SDKHook_Think, VehicleThink);
		SDKHook(obj, SDKHook_OnTakeDamage, VehicleTakeDamage);

		return view_as<VehicleGeneric>(obj);
	}
	property int m_hDriver
	{
		public get()
		{
			return GetEntPropEnt(this.index, Prop_Data, "m_hPlayer2");
		}
		public set(int entity)
		{
			SetEntPropEnt(this.index, Prop_Data, "m_hPlayer2", entity);
		}
	}
	property float m_flNextInteractAt
	{
		public get()
		{
			return GetEntPropFloat(this.index, Prop_Data, "m_flNextInteract");
		}
		public set(float time)
		{
			SetEntPropFloat(this.index, Prop_Data, "m_flNextInteract", time);
		}
	}
}

void Vehicle_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("obj_vehicle", _, OnDestroy);
	factory.DeriveFromClass("prop_vehicle_driveable");
	factory.BeginDataMapDesc()
	.DefineEntityField("m_hPlayer2")
	.DefineFloatField("m_flNextInteract")
	.EndDataMapDesc();
	factory.Install();

	RegAdminCmd("sm_remove_vehicles", RemoveVehicleCmd, ADMFLAG_RCON, "Deletes all obj_vehicle entities");
}

static Action RemoveVehicleCmd(int client, int args)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		RemoveEntity(entity);
	}

	return Plugin_Handled;
}

void Vehicle_PlayerSpawn(int client)
{
	Vehicle_Exit(client, false, false);

	// Blocks +use
	SetEntProp(client, Prop_Data, "m_iEFlags", GetEntProp(client, Prop_Data, "m_iEFlags")|(1 << 20));
}

static void OnDestroy(int entity)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(entity);

	Vehicle_Exit(obj.index, false, false);

	if(IsValidEntity(obj.m_iWearable1))
		RemoveEntity(obj.m_iWearable1);
	if(IsValidEntity(obj.m_iWearable2))
		RemoveEntity(obj.m_iWearable2);
	if(IsValidEntity(obj.m_iWearable3))
		RemoveEntity(obj.m_iWearable3);
	if(IsValidEntity(obj.m_iWearable4))
		RemoveEntity(obj.m_iWearable4);
	if(IsValidEntity(obj.m_iWearable5))
		RemoveEntity(obj.m_iWearable5);
}

int Vehicle_Driver(int target)
{
	if(i_IsVehicle[target] == 2)
		return view_as<VehicleGeneric>(target).m_hDriver;
	
	if(i_IsVehicle[target])
		return GetEntPropEnt(target, Prop_Data, "m_hPlayer");
	
	for(int entity = MaxClients + 1; entity < sizeof(i_IsVehicle); entity++)
	{
		if(i_IsVehicle[entity])
		{
			if(Vehicle_Driver(entity) == target)
				return entity;
		}
	}

	return -1;
}

bool Vehicle_Interact(int client, int entity)
{
	int vehicle = Vehicle_Driver(client);
	if(vehicle != -1)
	{
		static float forceOutTime[MAXTF2PLAYERS];

		if(fabs(forceOutTime[client] - GetGameTime()) < 0.4 || CanExit(vehicle))
		{
			Vehicle_Exit(vehicle, false);
		}
		else
		{
			forceOutTime[client] = GetGameTime();
		}
		
		return true;
	}

	if(TeutonType[client] != TEUTON_NONE || dieingstate[client] || entity == -1 || i_IsVehicle[entity] != 2)
		return false;
	
	VehicleGeneric obj = view_as<VehicleGeneric>(entity);

	if(obj.m_hDriver != -1 || obj.m_flNextInteractAt > GetGameTime(obj.index))
		return false;
	
	Vehicle_Enter(obj.index, client);
	return true;
}

void Vehicle_Enter(int vehicle, int target)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(vehicle);

	int driver = obj.m_hDriver;
	if(driver == -1)
	{
		SetEntityCollisionGroup(target, COLLISION_GROUP_IN_VEHICLE);
		SetEntityMoveType(target, MOVETYPE_NONE);
		
		float pos[3], ang[3];
		if(!obj.GetAttachment("vehicle_driver_eyes", pos, ang))
			GetEntPropVector(obj.index, Prop_Data, "m_vecOrigin", pos);
		
		pos[2] -= 64.0;
		TeleportEntity(target, pos, _, {0.0, 0.0, 0.0});
		
		SetParent(obj.index, target);
		
		if(target > 0 && target <= MaxClients)
		{
			SetEntityFlags(target, GetEntityFlags(target) & ~(FL_DUCKING));
			SetEntProp(target, Prop_Send, "m_nAirDucked", 8);
			SetEntProp(target, Prop_Data, "deadflag", true);
			SetVariantString("self.AddCustomAttribute(\"no_duck\", 1, -1)");
			AcceptEntityInput(target, "RunScriptCode");
		}

		AcceptEntityInput(obj.index, "TurnOn");
		obj.m_flNextInteractAt = GetGameTime(obj.index) + 1.0;
		obj.m_hDriver = target;
	}
}

// Should be called in PlayerSpawn, PlayerDeath, and ClientDisconnect
void Vehicle_Exit(int target, bool killed, bool teleport = true)
{
	if(i_IsVehicle[target] == 2)
	{
		VehicleGeneric obj = view_as<VehicleGeneric>(target);

		int driver = obj.m_hDriver;
		if(driver != -1)
		{
			AcceptEntityInput(driver, "ClearParent");

			float pos[3], ang[3], vel[3];
			if(driver > 0 && driver <= MaxClients)
			{
				if(!killed)
					SetEntProp(driver, Prop_Data, "deadflag", false);

				GetEntPropVector(driver, Prop_Send, "m_vecOrigin", pos);
				pos[2] += 8.0;

				GetClientEyeAngles(driver, ang);
				ang[2] = 0.0;
			}
			else
			{
				GetEntPropVector(driver, Prop_Data, "m_vecOrigin", pos);
				pos[2] += 8.0;
			}
			
			if(driver > 0 && driver <= MaxClients)
			{
				SetEntityCollisionGroup(driver, COLLISION_GROUP_PLAYER);
				SetEntityMoveType(driver, MOVETYPE_WALK);
				
				SetVariantString("self.RemoveCustomAttribute(\"no_duck\")");
				AcceptEntityInput(driver, "RunScriptCode");
				//SetEntProp(driver, Prop_Send, "m_bDucked", true);
				//SetEntityFlags(driver, GetEntityFlags(driver)|FL_DUCKING);
			}

			if(teleport)
			{
				CanExit(obj.index, pos, ang);
				GetEntPropVector(obj.index, Prop_Data, "m_vecVelocity", vel);
				TeleportEntity(driver, pos, ang, vel);
			}

			obj.m_hDriver = -1;
		}

		SetEntPropFloat(obj.index, Prop_Data, "m_controls.steering", 0.0);
		SetEntPropFloat(obj.index, Prop_Data, "m_controls.throttle", 0.0);
		
		obj.m_flNextInteractAt = GetGameTime(obj.index) + 1.0;
	}
	else
	{
		int entity = -1;
		while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
		{
			VehicleGeneric obj = view_as<VehicleGeneric>(entity);
			if(obj.m_hDriver == target)
			{
				Vehicle_Exit(entity, false);
				return;
			}
		}
	}
}

static Action VehicleThink(int entity)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(entity);

	float gameTime = GetGameTime(obj.index);
	if(obj.m_flNextDelayTime > gameTime)
		return Plugin_Continue;
	
	Function func = func_NPCThink[obj.index];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(obj.index);
		Call_Finish();
	}

	obj.StudioFrameAdvance();

	int driver = obj.m_hDriver;
	if(driver == -1)
	{
		obj.m_flNextDelayTime = gameTime + 0.1;
	}
	else if(driver > 0 && driver <= MaxClients)
	{
		// TODO: Controller supported?
		int buttons = GetEntProp(driver, Prop_Data, "m_nButtons");
		
		if(buttons & IN_MOVERIGHT)
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.steering", 1.0);
		}
		else if(buttons & IN_MOVELEFT)
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.steering", -1.0);
		}
		else
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.steering", 0.0);
		}
	
		if(buttons & IN_FORWARD)
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.throttle", 1.0);
		}
		else if(buttons & IN_BACK)
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.throttle", -1.0);
		}
		else
		{
			SetEntPropFloat(obj.index, Prop_Data, "m_controls.throttle", 0.0);
		}
	}

	return Plugin_Continue;
}

static Action VehicleTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(victim);

	if(damagetype & DMG_CRUSH)
		return Plugin_Continue;

	int driver = obj.m_hDriver;
	if(driver != -1)
	{
		// Redirect damage to the driver
		SDKHooks_TakeDamage(driver, inflictor, attacker, damage, damagetype, weapon, damageForce, damagePosition, _, i_HexCustomDamageTypes[victim]);
	}

	return Plugin_Continue;
}

static bool CheckExitPoint(float yaw, float distance, int vehicle, const float vecStart[3], float origin[3], const float mins[3], const float maxs[3])
{
	float vehicleAngles[3];
	GetEntPropVector(vehicle, Prop_Data, "m_angRotation", vehicleAngles);
	vehicleAngles[2] += yaw;
	
	float vecDir[3];
	GetAngleVectors(vehicleAngles, NULL_VECTOR, vecDir, NULL_VECTOR);
	
	origin = vecStart;
	ScaleVector(vecDir, distance);
	AddVectors(origin, vecDir, origin);
	
	Handle trace = TR_TraceHullFilterEx(vecStart, origin, mins, maxs, MASK_PLAYERSOLID, TraceRayHitWorldOnly, vehicle);
	bool failed = TR_GetFraction(trace) < 1.0;
	delete trace;
	
	return !failed;
}

static bool CanExit(int vehicle, float origin[3] = NULL_VECTOR, float angles[3] = NULL_VECTOR)
{
	static const float maxs[] = { 24.0, 24.0, 82.0 };
	static const float mins[] = { -24.0, -24.0, 0.0 };
	
	float vecStart[3];
	if(view_as<VehicleGeneric>(vehicle).GetAttachment("vehicle_driver_exit", vecStart, angles))
	{
		float vecEnd[3];
		vecEnd = vecStart;
		vecStart[2] += 12.0;
	
		Handle trace = TR_TraceHullFilterEx(vecStart, vecEnd, mins, maxs, MASK_PLAYERSOLID, TraceRayHitWorldOnly, vehicle);
		bool failed = TR_DidHit(trace);
		delete trace;

		if(!failed)
		{
			origin = vecEnd;
			return true;
		}
	}
	
	GetEntPropVector(vehicle, Prop_Data, "m_vecOrigin", vecStart);
	vecStart[2] += 12.0;
	
	if(CheckExitPoint(90.0, 90.0, vehicle, vecStart, origin, mins, maxs))
		return true;
	
	if(CheckExitPoint(-90.0, 90.0, vehicle, vecStart, origin, mins, maxs))
		return true;
	
	if(CheckExitPoint(0.0, 100.0, vehicle, vecStart, origin, mins, maxs))
		return true;
	
	if(CheckExitPoint(180.0, 170.0, vehicle, vecStart, origin, mins, maxs))
		return true;
	
	return false;
}