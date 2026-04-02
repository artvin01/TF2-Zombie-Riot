#pragma semicolon 1
#pragma newdecls required

static int AimPitch;
static int AimYaw;
static int NPCId;

void VehicleFullAPC_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "APC");
	strcopy(data.Plugin, sizeof(data.Plugin), "vehicle_fullapc");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
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
		VehicleFullAPC obj = view_as<VehicleFullAPC>(VehicleGeneric(vecPos, vecAng, VEHICLE_TYPE_CAR_WHEELS, "models/combine_apc.mdl", "scripts/vehicles/zr_custom/apc.txt"));
		
		obj.SetDriverOffset({0.0, -10.0, 40.0});
		
		obj.m_iGunIndex = Store_GetItemIndex("APC Turret");
		obj.AddSeat({0.0, -60.0, 80.0}, 0, Store_GetItemIndex("APC Rockets"));

		func_NPCThink[obj.index] = ClotThink;
		Armor_Charge[obj.index] = 15000;
		obj.m_iMaxArmor = 15000;

		AimPitch = obj.LookupPoseParameter("vehicle_weapon_pitch");
		AimYaw = obj.LookupPoseParameter("vehicle_weapon_yaw");

		return obj;
	}
}

static void ClotThink(VehicleGeneric obj)
{
	int slot = -1;
	int client = Vehicle_Driver(obj.index, slot);
	if(client > 0 && client <= MaxClients && slot == -1)
	{
		float pos[3], ang[3], goal[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		
		Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, Trace_APCAim, obj.index);
		TR_GetEndPosition(goal, trace);
		delete trace;

		obj.GetAttachment("gun_base", pos, ang);
		//GetEntPropVector(obj.index, Prop_Data, "m_angRotation", ang);

		MakeVectorFromPoints(goal, pos, pos);
		GetVectorAngles(pos, pos);

		SubtractVectors(pos, ang, ang);

		ang[0] = fixAngle(-ang[0]);
		ang[1] = fixAngle(ang[1] + 180.0);

		if(AimPitch >= 0)
			obj.SetPoseParameter(AimPitch, ang[0]);
		
		if(AimYaw >= 0)
			obj.SetPoseParameter(AimYaw, ang[1]);
	}
}

void VehicleFullAPC_WeaponEnable(int client, int weapon)
{
	int slot = 1;
	int vehicle = Vehicle_Driver(client, slot);
	if(vehicle != -1 && i_NpcInternalId[vehicle] == NPCId)
	{
		//Attributes_SetMulti(weapon, 2, float(Waves_GetRoundScale() + 1) / 80.0);

		switch(slot)
		{
			case -1:	// Driver
			{
				SetEntityRenderMode(weapon, RENDER_NONE);
				SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
			}
			default:	// Passenger
			{

			}
		}
	}
}

public void VehicleFullAPC_WeaponTurret_M1(int client, int weapon, bool crit, int slot)
{
	int vehicle = Vehicle_Driver(client);
	if(vehicle != -1)
	{
		VehicleGeneric obj = view_as<VehicleGeneric>(vehicle);
		
		float pos[3], ang[3], goal[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		ang[0] += GetRandomFloat(-0.5, 0.5);
		ang[1] += GetRandomFloat(-0.5, 0.5);
		
		Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, Trace_APCAim, obj.index);
		TR_GetEndPosition(goal, trace);

		if(TR_GetFraction(trace) < 1.0)
		{
			int target = TR_GetEntityIndex(trace);
			if(target < 1 || target > MaxClients)
			{
				TR_GetPlaneNormal(trace, ang);
				GetVectorAngles(ang, ang);

				static char class[12];
				GetEntityClassname(target, class, sizeof(class));
				if(!b_ThisWasAnNpc[target] && StrContains(class, "obj_")) //if its the world, then do this.
				{
					CreateParticle("impact_concrete", goal, ang);
				}
			}
		}

		delete trace;

		obj.GetAttachment("muzzle", pos, ang);

		ShootLaser(obj.index, "bullet_tracer01_red", pos, goal, false);
	}
}

static bool Trace_APCAim(int entity, int mask, any data)
{
	return entity != data && (!entity || entity > MaxClients);
}