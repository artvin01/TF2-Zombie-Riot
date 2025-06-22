#pragma semicolon 1
#pragma newdecls required

#define RAILGUN_PREPARE_SHOOT	"vehicles/apc/apc_start_loop3.wav"

#define RAILGUN_SHOOT	"ambient/explosions/explode_7.wav"


#define RAILGUN_START_CHARGE	"vehicles/apc/apc_shutdown.wav"

#define RAILGUN_END	"vehicles/apc/apc_slowdown_fast_loop5.wav"

#define RAILGUN_READY	"vehicles/tank_turret_start1.wav"

#define RAILGUN_READY_ALARM	"ambient/alarms/klaxon1.wav"

#define RAILGUN_ACTIVATED	"buttons/button1.wav"

static int Beam_Laser;
static int Beam_Glow;

static char g_ShootingSound[][] = {
	"weapons/sentry_shoot_mini.wav",
};

void ObjectRailgun_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/zombie_riot/buildings/mortar_2.mdl");
	PrecacheSound(RAILGUN_PREPARE_SHOOT); 
	PrecacheSound(RAILGUN_SHOOT);
	PrecacheSound(RAILGUN_START_CHARGE);
	PrecacheSound(RAILGUN_END);
	PrecacheSound(RAILGUN_READY);
	PrecacheSound(RAILGUN_ACTIVATED);
	PrecacheSound(RAILGUN_READY_ALARM);
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Railgun");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_railgun");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_railgun");
	build.Cost = 600;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectRailgun(client, vecPos, vecAng);
}

methodmap ObjectRailgun < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
	public ObjectRailgun(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectRailgun npc = view_as<ObjectRailgun>(ObjectGeneric(client, vecPos, vecAng, "models/zombie_riot/buildings/mortar_2.mdl", "0.7","50", {15.0, 15.0, 60.0},_,false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
	//	func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;

		SetRotateByDefaultReturn(npc.index, 180.0);
		npc.SetActivity("RAIL_IDLE");		

		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}
/*
static void ClotThink(ObjectRailgun npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(Owner))
	{
		return;
	}
	float gameTime = GetGameTime(npc.index);
}
*/

static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(Owner != client)
		return false;
		
	if(f_BuildingIsNotReady[client] > GetGameTime())
		return false;
	
	if(f_MedicCallIngore[client] < GetGameTime())
		return false;

	BuildingRailgunShot(client, npc.index);
	return true;
}

public void BuildingRailgunShot(int client, int Railgun)
{
	CClotBody npc = view_as<CClotBody>(Railgun);
	npc.SetActivity("RAIL_FIRE");		
	float pos[3];
	GetEntPropVector(Railgun, Prop_Data, "m_vecAbsOrigin", pos);
	EmitSoundToAll(RAILGUN_ACTIVATED, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_ACTIVATED, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, Railgun, _, 90, _, 0.8);
	DataPack pack;
	CreateDataTimer(0.75, RailgunFire, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(Railgun));
	pack.WriteCell(EntIndexToEntRef(client));
	CreateTimer(15.5, RailgunFire_DeleteSound, Railgun, TIMER_FLAG_NO_MAPCHANGE);
	f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
}


static int BEAM_BuildingHit[MAX_TARGETS_HIT];
static float BEAM_Targets_Hit[MAXENTITIES];
static bool BEAM_HitDetected[MAXENTITIES];
public Action RailgunFire(Handle timer, DataPack pack)
{
	pack.Reset();
	int obj = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());

	if(IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(obj))
	{
		float pos[3];
		GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", pos);
		CreateEarthquake(pos, 0.5, 350.0, 16.0, 255.0);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
		EmitSoundToAll(RAILGUN_SHOOT, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_SHOOT, obj, _, 90, _, 0.8);
		BEAM_Targets_Hit[obj] = 1.0;
		Railgun_Boom(client, obj);
		float flPos[3]; // original
		GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 50.0;
	//	flAng[1] += 33.0;
		TE_Particle("halloween_boss_axe_hit_sparks", flPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		ParticleEffectAt(flPos, "eotl_pyro_pool_explosion_streaks", 1.0);
		DataPack pack2;
		CreateDataTimer(1.5, RailgunFire_ReloadStart, pack2, TIMER_FLAG_NO_MAPCHANGE);
		pack2.WriteCell(EntIndexToEntRef(obj));
		pack2.WriteCell(EntIndexToEntRef(client));
	}		
	return Plugin_Stop;
}	
public Action RailgunFire_ReloadStart(Handle timer, DataPack pack)
{
	pack.Reset();
	int obj = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_START_CHARGE, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_START_CHARGE, obj, _, 90, _, 0.8);

		CClotBody npc = view_as<CClotBody>(obj);
		DataPack pack2;
		CreateDataTimer(9.0, RailgunFire_ReloadMiddle, pack2, TIMER_FLAG_NO_MAPCHANGE);
		pack2.WriteCell(EntIndexToEntRef(obj));
		pack2.WriteCell(EntIndexToEntRef(client));
		npc.SetActivity("RAIL_IDLE");		
	}
	return Plugin_Stop;
}
public Action RailgunFire_ReloadMiddle(Handle timer, DataPack pack)
{
	pack.Reset();
	int obj = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		
		DataPack pack2;
		CreateDataTimer(3.5, RailgunFire_ReloadEnd, pack2, TIMER_FLAG_NO_MAPCHANGE);
		pack2.WriteCell(EntIndexToEntRef(obj));
		pack2.WriteCell(EntIndexToEntRef(client));
	}
	return Plugin_Stop;
}

public Action RailgunFire_ReloadEnd(Handle timer, DataPack pack)
{
	pack.Reset();
	int obj = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(IsClientInGame(client) && IsPlayerAlive(client) && IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_READY_ALARM, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY_ALARM, obj, _, 90, _, 0.8);
	}
	return Plugin_Stop;
}


public Action RailgunFire_DeleteSound(Handle timer, int obj)
{
	if(IsValidEntity(obj))
	{
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_READY);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_END);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_START_CHARGE);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_ACTIVATED);
	}
	return Plugin_Stop;
}


static void Railgun_Boom(int client, int obj)
{
	bool IsBuildingCarried;
	if(EntRefToEntIndex(Building_Mounted[obj]) == client)
		IsBuildingCarried = true;

	int BEAM_BeamRadius = 40;
	float Strength = 10.0;
	if(IsBuildingCarried)
		Strength *= 0.9;

	Strength *= 20.0;

	float attack_speed;

	attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
			
	Strength = attack_speed * Strength * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
	
	float sentry_range;
		
	sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
				
	float BEAM_CloseBuildingDPT = Strength;
	float BEAM_FarBuildingDPT = Strength;
	int BEAM_MaxDistance = RoundToCeil(1500.0 * sentry_range);
	int BEAM_ColorHex = ParseColor("FFA500");
	float diameter = float(BEAM_BeamRadius * 2);
	int r = GetR(BEAM_ColorHex);
	int g = GetG(BEAM_ColorHex);
	int b = GetB(BEAM_ColorHex);
	static float angles[3];
	static float startPoint[3];
	static float endPoint[3];
	static float hullMin[3];
	static float hullMax[3];
	static float playerPos[3];
	if(!IsBuildingCarried)
	{
		GetEntPropVector(obj, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", startPoint);
		startPoint[2] += 50.0;
	}
	else
	{
		GetClientEyePosition(client, startPoint);
		GetClientEyeAngles(client, angles);
	}
	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
		CloseHandle(trace);
		ConformLineDistance(endPoint, startPoint, endPoint, float(BEAM_MaxDistance));
		float lineReduce = BEAM_BeamRadius * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		for (int i = 1; i < MAXPLAYERS; i++)
		{
			BEAM_HitDetected[i] = false;
		}
		
		
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			BEAM_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -float(BEAM_BeamRadius);
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		
		if(IsBuildingCarried)
		{
			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			FinishLagCompensation_Base_boss();
		}
		else
		{
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, obj);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
		}
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		
		bool First_Target_Hit = true;
		
		BEAM_Targets_Hit[client] = 1.0;
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BEAM_BuildingHit[building])
			{
				if(IsValidEntity(BEAM_BuildingHit[building]))
				{
					GetEntPropVector(BEAM_BuildingHit[building], Prop_Data, "m_vecAbsOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BEAM_CloseBuildingDPT + (BEAM_FarBuildingDPT-BEAM_CloseBuildingDPT) * (distance/BEAM_MaxDistance);
					if (damage < 0)
						damage *= -1.0;
						
					if(First_Target_Hit)
					{
						damage *= 1.55;
						First_Target_Hit = false;
					}
					float CalcDamageForceVec[3]; CalculateDamageForce(vecForward, 10000.0, CalcDamageForceVec);
					SDKHooks_TakeDamage(BEAM_BuildingHit[building], obj, client, damage*BEAM_Targets_Hit[obj], DMG_PLASMA, -1, CalcDamageForceVec, playerPos);	// 2048 is DMG_NOGIB?
					BEAM_Targets_Hit[obj] *= LASER_AOE_DAMAGE_FALLOFF;
				}
				else
					BEAM_BuildingHit[building] = false;
			}
		}
		
		float belowBossEyes[3];
			
		if(!IsBuildingCarried)
		{
			GetEntPropVector(obj, Prop_Data, "m_angRotation", angles);
			GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", startPoint);
			startPoint[2] += 50.0;
		}
		else
		{
			GetClientEyePosition(client, startPoint);
			GetClientEyeAngles(client, angles);
		}
		GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", belowBossEyes);
		belowBossEyes[2] += 50.0;
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 60);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.44, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 60);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 0.55, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
		TE_SendToAll(0.0);
		endPoint[2] -= 15.0;
		ParticleEffectAt(endPoint, "ExplosionCore_MidAir_Flare", 0.25);
		CreateExplosion(client, endPoint, 0.0, 0, 0);
	}
	else
	{
		delete trace;
	}
	delete trace;
}


static bool BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsValidEntity(entity))
	{
		if(0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));
			
			if (((b_ThisWasAnNpc[entity] && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
			{
				for(int i=0; i < (MAX_TARGETS_HIT ); i++)
				{
					if(!BEAM_BuildingHit[i])
					{
						BEAM_BuildingHit[i] = entity;
						break;
					}
				}
			}
			
		}
	}
	return false;
}