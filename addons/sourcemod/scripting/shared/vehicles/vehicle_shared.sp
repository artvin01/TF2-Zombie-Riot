#pragma semicolon 1
#pragma newdecls required

// https://github.com/Mikusch/source-vehicles
// https://github.com/ficool2/vscript_vehicle

#define VEHICLE_MAX_SEATS	24

#if defined ZR
static int ModifiedWeapons[MAXPLAYERS];
#endif

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
		SetEntityCollisionGroup(obj, COLLISION_GROUP_VEHICLE); //COLLISION_GROUP_DEBRIS_TRIGGER

		DispatchSpawn(obj);

		i_IsVehicle[obj] = 2;
		NPCStats_SetFuncsToZero(obj);

#if defined ZR
		Armor_Charge[obj] = 10000;
#endif

		SDKHook(obj, SDKHook_Think, VehicleThink);
		SDKHook(obj, SDKHook_OnTakeDamage, VehicleTakeDamage);

		return view_as<VehicleGeneric>(obj);
	}
	public void AddSeat(const float pos[3], int index, int gun = 0)
	{
		if(index < VEHICLE_MAX_SEATS)
		{
			SetEntPropVector(this.index, Prop_Data, "m_vecSeatPos", pos, index);
			SetEntProp(this.index, Prop_Data, "m_iSeatGunIndex", gun, _, index);
		}
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
	property bool m_bNoAttack
	{
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bNoAttack"));
		}
		public set(bool value)
		{
			SetEntProp(this.index, Prop_Data, "m_bNoAttack", value);
		}
	}
}

static bool DoneSoundScript;

void Vehicle_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("obj_vehicle", _, OnDestroy);
	factory.DeriveFromClass("prop_vehicle_driveable");
	factory.BeginDataMapDesc()
	.DefineEntityField("m_hPlayer2")
	.DefineBoolField("m_bNoAttack")
	.DefineEntityField("m_hSeatEntity", VEHICLE_MAX_SEATS)
	.DefineVectorField("m_vecSeatPos", VEHICLE_MAX_SEATS)
	.DefineIntField("m_iSeatGunIndex", VEHICLE_MAX_SEATS)
	.EndDataMapDesc();
	factory.Install();

	RegAdminCmd("sm_remove_vehicles", RemoveVehicleCmd, ADMFLAG_RCON, "Deletes all obj_vehicle entities");
	RegAdminCmd("sm_seat_offset", SeatOffsetCmd, ADMFLAG_RCON, "Set the offset of your vehicle seat");
}

void Vehicle_MapEnd()
{
	DoneSoundScript = false;
}

void Vehicle_PluginEnd()
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		SDKCall_RemoveImmediate(entity);
	}
}

void Vehicle_PrecacheSounds()
{
	if(DoneSoundScript)
		return;
	
	DoneSoundScript = true;
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

static Action RemoveVehicleCmd(int client, int args)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		RemoveEntity(entity);
	}

	return Plugin_Handled;
}

static Action SeatOffsetCmd(int client, int args)
{
	if(args != 3)
	{
		ReplyToCommand(client, "[SM] Usage: sm_seat_offset <x> <y> <z>");
	}
	else
	{
		int vehicle = Vehicle_Driver(client);
		if(vehicle == -1)
		{
			ReplyToCommand(client, "[SM] Enter a vehicle first");
		}
		else
		{
			float pos1[3], pos2[3];
			GetEntPropVector(vehicle, Prop_Data, "m_vecOrigin", pos1);
			pos2[0] = GetCmdArgFloat(1);
			pos2[1] = GetCmdArgFloat(2);
			pos2[2] = GetCmdArgFloat(3);
			
			AcceptEntityInput(client, "ClearParent");
			TeleportEntity(client, pos1, _, {0.0, 0.0, 0.0});
			SetParent(vehicle, client, "root", pos2);

			ReplyToCommand(client, "%f %f %f", pos2[0], pos2[1], pos2[2]);
		}
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

// If target is a vehicle, returns the driver or passenger with the higher priority, -1 if none
// If target is a user, returns the vehicle currently on, -1 if none
int Vehicle_Driver(int target, int &slot = -1)
{
	if(i_IsVehicle[target] == 2)
	{
		int driver = view_as<VehicleGeneric>(target).m_hDriver;
		if(driver == -1)
		{
			for(slot = 0; slot < VEHICLE_MAX_SEATS; slot++)
			{
				int passenger = GetEntPropEnt(target, Prop_Data, "m_hSeatEntity", slot);
				if(passenger != -1)
					return passenger;
			}
		}

		slot = -1;
		return driver;
	}
	
	if(i_IsVehicle[target])
	{
		slot = -1;
		return GetEntPropEnt(target, Prop_Data, "m_hPlayer");
	}
	
	for(int entity = MaxClients + 1; entity < sizeof(i_IsVehicle); entity++)
	{
		if(i_IsVehicle[entity] && IsValidEntity(entity))
		{
			if(i_IsVehicle[entity] == 2)
			{
				int driver = view_as<VehicleGeneric>(entity).m_hDriver;
				if(driver == target)
				{
					slot = -1;
					return entity;
				}
				
				for(slot = 0; slot < VEHICLE_MAX_SEATS; slot++)
				{
					driver = GetEntPropEnt(entity, Prop_Data, "m_hSeatEntity", slot);
					if(driver == target)
						return entity;
				}
			}
			else if(GetEntPropEnt(entity, Prop_Data, "m_hPlayer") == target)
			{
				slot = -1;
				return entity;
			}
		}
	}
	
	slot = -1;
	return -1;
}

bool Vehicle_ShowInteractHud(int client, int entity)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(entity);

	bool space;
	if(obj.m_hDriver == -1)
	{
		space = true;
	}
	else
	{
		// Passenger Seat
		float pos[3];
		for(int i; i < VEHICLE_MAX_SEATS; i++)
		{
			GetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", pos, i);
			if(pos[0] && GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i) == -1)
			{
				space = true;
				break;
			}
		}
	}

	if(!space)
		return false;
	
	Function func = FuncShowInteractHud[entity];
	if(func && func != INVALID_FUNCTION)
	{
		bool result;

		Call_StartFunction(null, FuncShowInteractHud[entity]);
		Call_PushCell(entity);
		Call_PushCell(client);
		Call_Finish(result);
		
		if(result)
			return true;
	}

	SetGlobalTransTarget(client);
	char ButtonDisplay[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	PrintCenterText(client, "%s%t", ButtonDisplay, "Enter this vehicle");
	return space;
}

bool Vehicle_Interact(int client, int weapon, int entity)
{
	int vehicle = Vehicle_Driver(client);
	if(vehicle != -1)
	{
		static float forceOutTime[MAXPLAYERS];

		if(view_as<VehicleGeneric>(vehicle).m_hDriver == -1)
		{
			// Driver is out, I'll take the wheel!
			AcceptEntityInput(client, "ClearParent");
			SwitchToDriver(view_as<VehicleGeneric>(vehicle), client);

#if defined ZR
			AdjustClientWeapons(client);
#endif
		}
		else if(fabs(forceOutTime[client] - GetGameTime()) < 0.4 || CanExit(vehicle))
		{
			Vehicle_Exit(client);
		}
		else
		{
			forceOutTime[client] = GetGameTime();
		}
		
		return true;
	}

	if(TeutonType[client] != TEUTON_NONE || dieingstate[client] || entity == -1 || i_IsVehicle[entity] != 2)
		return false;
	
	Function func = func_NPCInteract[entity];
	if(func && func != INVALID_FUNCTION)
	{
		bool result;

		Call_StartFunction(null, func);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushCell(entity);
		Call_Finish(result);

		if(result)
			return true;
	}

	return Vehicle_Enter(entity, client);
}

bool Vehicle_Enter(int vehicle, int target)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(vehicle);

	float pos1[3];
	int index = -2;

	if(obj.m_hDriver == -1)
	{
		// Driver Seat
		index = -1;
	}
	else
	{
		// Passenger Seat
		for(int i; i < VEHICLE_MAX_SEATS; i++)
		{
			GetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", pos1, i);
			if(pos1[0] && GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i) == -1)
			{
				index = i;
				break;
			}
		}
	}
	
	if(index == -2)
		return false;
	
//	PrintToChatAll("Vehicle_Enter %d: %N entered in slot %d", vehicle, target, index);
	
	if(!b_ThisWasAnNpc[target])
	{
		SetEntityCollisionGroup(target, COLLISION_GROUP_IN_VEHICLE);
		SetEntityMoveType(target, MOVETYPE_NONE);
	}

	if(index == -1)
	{
		SwitchToDriver(obj, target);
	}
	else
	{
		float pos2[3];
		GetEntPropVector(obj.index, Prop_Data, "m_vecOrigin", pos1);
		GetEntPropVector(obj.index, Prop_Data, "m_vecSeatPos", pos2, index);

		// Offset for not being ducked
		pos2[2] -= 18.0;

		TeleportEntity(target, pos1, _, {0.0, 0.0, 0.0});
		SetParent(obj.index, target, "root", pos2);

		SetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", target, index);
	}
	
	if(target > 0 && target <= MaxClients)
	{
		SetEntityFlags(target, GetEntityFlags(target) & ~(FL_DUCKING));
		SetEntProp(target, Prop_Send, "m_nAirDucked", 8);
		SetEntProp(target, Prop_Data, "deadflag", true);
		SetVariantString("self.AddCustomAttribute(\"no_duck\", 1, -1)");
		AcceptEntityInput(target, "RunScriptCode");

#if defined ZR
		AdjustClientWeapons(target);
#endif
	}
	return true;
}

static void SwitchToDriver(VehicleGeneric obj, int target)
{
	for(int i; i < VEHICLE_MAX_SEATS; i++)
	{
		int passenger = GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i);
		if(passenger == target)
		{
			SetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", -1, i);
			break;
		}
	}

	float pos[3];
	GetEntPropVector(obj.index, Prop_Data, "m_vecOrigin", pos);
	TeleportEntity(target, pos, _, {0.0, 0.0, 0.0});
	SetParent(obj.index, target, "vehicle_driver_eyes", {0.0, 0.0, -68.0});	// Was -40 when being ducked
	
	AcceptEntityInput(obj.index, "TurnOn");
	obj.m_hDriver = target;
}

// Should be called in PlayerSpawn, PlayerDeath, and ClientDisconnect
// If target is a vehicle, kicks all players out
// If target is a user, kicks that player out
// Returns true if something happened
bool Vehicle_Exit(int target, bool killed = false, bool teleport = true)
{
	bool found;

	if(i_IsVehicle[target] == 2)
	{
		int entity = -1;
		while((entity = Vehicle_Driver(target)) != -1)
		{
			ExitVehicle(target, entity, killed, teleport);
			found = true;
		}
	}
	else
	{
		int entity = Vehicle_Driver(target);
		if(entity != -1)
		{
			ExitVehicle(entity, target, killed, teleport);
			found = true;
		}
	}
	
	return found;
}

static void ExitVehicle(int vehicle, int target, bool killed, bool teleport)
{
	VehicleGeneric obj = view_as<VehicleGeneric>(vehicle);

	bool wasDriver;

	if(obj.m_hDriver == target)
	{
		obj.m_hDriver = -1;
		wasDriver = true;
//		PrintToChatAll("ExitVehicle %d: %N exit as driver", vehicle, target);
	}
	else
	{
		for(int i; i < VEHICLE_MAX_SEATS; i++)
		{
			int passenger = GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i);
			if(passenger == target)
			{
				SetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", -1, i);
	//			PrintToChatAll("ExitVehicle %d: %N exit as passenger %d", vehicle, target, i);
				break;
			}
		}
	}

//	int entity = Vehicle_Driver(target);
//	if(entity != -1)
//		PrintToChatAll("ExitVehicle %d: %N still in a seat somehow???", vehicle, target);

	AcceptEntityInput(target, "ClearParent");

	float pos[3], ang[3], vel[3];
	if(target > 0 && target <= MaxClients)
	{
		if(!killed)
			SetEntProp(target, Prop_Data, "deadflag", false);

		GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 8.0;

		GetClientEyeAngles(target, ang);
	}
	else
	{
		GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
		pos[2] += 8.0;
	}
	
	if(target > 0 && target <= MaxClients)
	{
		SetEntityCollisionGroup(target, COLLISION_GROUP_PLAYER);
		SetEntityMoveType(target, MOVETYPE_WALK);
		
		SetVariantString("self.RemoveCustomAttribute(\"no_duck\")");
		AcceptEntityInput(target, "RunScriptCode");

#if defined ZR
		AdjustClientWeapons(target);
#endif
	}

	if(teleport)
	{
		CanExit(obj.index, pos, ang);
		GetEntPropVector(obj.index, Prop_Data, "m_vecVelocity", vel);
		pos[2] += 8.0;
		ang[2] = 0.0;
		TeleportEntity(target, pos, ang, vel);
	}

	if(wasDriver)
	{
		SetEntPropFloat(obj.index, Prop_Data, "m_controls.steering", 0.0);
		SetEntPropFloat(obj.index, Prop_Data, "m_controls.throttle", 0.0);
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

		if(obj.m_bNoAttack)
		{
			float time = GetGameTime() + 0.2;
			if(GetEntPropFloat(driver, Prop_Send, "m_flNextAttack") < time)
				SetEntPropFloat(driver, Prop_Send, "m_flNextAttack", time);
		}
	}

	for(int i; i < VEHICLE_MAX_SEATS; i++)
	{
		if(GetEntProp(obj.index, Prop_Data, "m_iSeatGunIndex", _, i) < 0)
		{
			int passenger = GetEntPropEnt(obj.index, Prop_Data, "m_hSeatEntity", i);
			if(passenger > 0 && passenger <= MaxClients)
			{
				float time = GetGameTime() + 0.2;
				if(GetEntPropFloat(passenger, Prop_Send, "m_flNextAttack") < time)
					SetEntPropFloat(passenger, Prop_Send, "m_flNextAttack", time);
			}
		}
	}

	return Plugin_Continue;
}

static Action VehicleTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype & DMG_CRUSH)
		return Plugin_Continue;
	
	int driver = Vehicle_Driver(victim);
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
	static const float maxs[] = { 24.0, 24.0, 63.0 };
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

#if defined ZR
static void AdjustClientWeapons(int client)
{
	int slot = -1;
	int vehicle = Vehicle_Driver(client, slot);

	if(vehicle != -1)
	{
		VehicleGeneric obj = view_as<VehicleGeneric>(vehicle);
		if(slot == -1)
		{
			/*if(obj.m_bNoAttack)
			{
				int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(active != -1)
				{
					char classname[36], buffer[36];
					GetEntityClassname(active, classname, sizeof(classname));
					if(TF2_GetClassnameSlot(classname, active) != TFWeaponSlot_Melee)
					{
						Store_SwapToItem(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
						TF2_AddCondition(client, TFCond_RestrictToMelee);
					}
				}
			}
			else*/
		}
		else
		{
			int gun = GetEntProp(obj.index, Prop_Data, "m_iSeatGunIndex", _, slot);
			if(gun > 0)
			{
				if(ModifiedWeapons[client] != gun)
				{
					if(ModifiedWeapons[client])
						Store_RemoveSpecificItem(client, NULL_STRING, _, ModifiedWeapons[client]);
					
					i_ClientHasCustomGearEquipped[client] = true;
					ModifiedWeapons[client] = gun;

					int health = GetClientHealth(client);
					Store_GiveAll(client, health, true);
					Store_GiveSpecificItem(client, NULL_STRING, _, gun);

					SetAmmo(client, 1, 9999);
					SetAmmo(client, 2, 9999);

					Manual_Impulse_101(client, health);
				}
				return;
			}
		}
	}

	if(ModifiedWeapons[client])
	{
		i_ClientHasCustomGearEquipped[client] = false;
		Store_RemoveSpecificItem(client, NULL_STRING, _, ModifiedWeapons[client]);
		ModifiedWeapons[client] = 0;
		
		//TF2_RemoveCondition(client, TFCond_RestrictToMelee);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
	}
}
#endif