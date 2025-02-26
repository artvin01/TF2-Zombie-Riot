#pragma semicolon 1
#pragma newdecls required

/*
	Placement Type
*/
static DynamicHook g_Particle_cannon_2nd_fire;

public void OnPluginStartMangler()
{
	GameData gamedata = new GameData("zombie_riot");
	if (gamedata == null)
		SetFailState("Could not find zombie_riot gamedata");
	
	g_Particle_cannon_2nd_fire = DynamicHook.FromConf(gamedata, "CTFParticleCannon::FireChargedShot");
	
	delete gamedata;
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
}

void OnManglerCreated(int entity) 
{
	g_Particle_cannon_2nd_fire.HookEntity(Hook_Pre, entity, Mangler_2nd);
}

static float Strength[MAXTF2PLAYERS];

static bool BEAM_CanUse[MAXTF2PLAYERS];
static bool BEAM_IsUsing[MAXTF2PLAYERS];
static int BEAM_TicksActive[MAXTF2PLAYERS];
static int Beam_Laser;
static int Beam_Glow;
static float BEAM_CloseDPT[MAXTF2PLAYERS];
static float BEAM_FarDPT[MAXTF2PLAYERS];
static int BEAM_MaxDistance[MAXTF2PLAYERS];
static int BEAM_BeamRadius[MAXTF2PLAYERS];
static int BEAM_ColorHex[MAXTF2PLAYERS];
static int BEAM_ChargeUpTime[MAXTF2PLAYERS];
static float BEAM_CloseBuildingDPT[MAXTF2PLAYERS];
static float BEAM_FarBuildingDPT[MAXTF2PLAYERS];
static float BEAM_Duration[MAXTF2PLAYERS];
static float BEAM_BeamOffset[MAXTF2PLAYERS][3];
static float BEAM_ZOffset[MAXTF2PLAYERS];
static bool BEAM_HitDetected[MAXTF2PLAYERS];
static int BEAM_BuildingHit[MAX_TARGETS_HIT];
static bool BEAM_UseWeapon[MAXTF2PLAYERS];

static float BEAM_Targets_Hit[MAXTF2PLAYERS];


public MRESReturn Mangler_2nd(int entity, DHookReturn ret, DHookParam param)
{	
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	{
		int new_ammo = GetAmmo(client, 23);
		if(new_ammo >= 80)
		{
			Rogue_OnAbilityUse(client, entity);
			new_ammo -= 80;
			SetAmmo(client, 23, new_ammo);
			CurrentAmmo[client][23] = GetAmmo(client, 23);
			
			SetGlobalTransTarget(client);
			
			PrintHintText(client,"%t: %i", "Laser Battery", new_ammo);
			
			
			BEAM_Targets_Hit[client] = 0.0;
			
			Client_Shake(client, 0, 50.0, 25.0, 0.5);
			
			Strength[client] = 112.0;

			Strength[client] *= 1.3; //tiny penalty.

			Strength[client] *= 2.0; //tiny penalty.

			Strength[client] *= Attributes_Get(entity, 335, 1.0);

					
			Strength[client] *= Attributes_Get(entity, 1, 1.0);
						
			Strength[client] *= Attributes_Get(entity, 2, 1.0);
	
			float reverse_attackspeed = 1.0;
			
			reverse_attackspeed = Attributes_Get(entity, 6, 1.0);
			
			Strength[client] /= reverse_attackspeed;
			
			TBB_Ability_Mangler_2(client);
		}
		else
		{
			SetGlobalTransTarget(client);
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			PrintHintText(client,"%t", "Out of Laser Battery");
		}
	}
	/*
	SetEntPropFloat(entity, Prop_Send, "m_flChargeBeginTime", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
	SDKCall_SetSpeed(client);
	TF2_RemoveCondition(client, TFCond_Slowed);
	return MRES_Supercede;
	*/
	return MRES_Ignored;
}

void TBB_Precahce_Mangler_2()
{
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

static void TBB_Ability_Mangler_2(int client)
{
	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		BEAM_BuildingHit[building] = false;
		BEAM_Targets_Hit[client] = 0.0;
	}
			
	BEAM_IsUsing[client] = false;
	BEAM_TicksActive[client] = 0;

	BEAM_CanUse[client] = true;
	BEAM_CloseDPT[client] = 2.0;
	BEAM_FarDPT[client] = 1.0;
	BEAM_MaxDistance[client] = 2500;
	BEAM_BeamRadius[client] = 15;
	BEAM_ColorHex[client] = ParseColor("4169E1");
	BEAM_ChargeUpTime[client] = 1;
	BEAM_CloseBuildingDPT[client] = Strength[client];
	BEAM_FarBuildingDPT[client] = Strength[client];
	BEAM_Duration[client] = 2.5;
	
	BEAM_BeamOffset[client][0] = 0.0;
	BEAM_BeamOffset[client][1] = -8.0;
	BEAM_BeamOffset[client][2] = 15.0;

	BEAM_ZOffset[client] = 0.0;
	BEAM_UseWeapon[client] = false;

	BEAM_IsUsing[client] = true;
	BEAM_TicksActive[client] = 0;
	/*
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, 80, _, _, 1.0);					
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, 80, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, 80, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, 80, _, _, 1.0);
		}		
	}
			*/
	TBB_Tick(client);
//	SDKHook(client, SDKHook_PreThink, TBB_Tick);
	
//	CreateTimer(999.9, Timer_RemoveEntity, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}

static bool BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
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
	return false;
}

static void GetBeamDrawStartPoint(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
	if (0.0 == BEAM_BeamOffset[client][0] && 0.0 == BEAM_BeamOffset[client][1] && 0.0 == BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = BEAM_BeamOffset[client][0];
	tmp[1] = BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

static void TBB_Tick(int client)
{
	if(!IsValidClient(client))
	{
		return;
	}

//	int BossTeam = GetClientTeam(client);
//	BEAM_TicksActive[client] = tickCount;
	float diameter = float(BEAM_BeamRadius[client] * 2);
	int r = GetR(BEAM_ColorHex[client]);
	int g = GetG(BEAM_ColorHex[client]);
	int b = GetB(BEAM_ColorHex[client]);
	/*int r = GetRandomInt(1, 254);
	int g = GetRandomInt(1, 254);	// This was just for proof of recompile
	int b = GetRandomInt(1, 254);*/
	static float angles[3];
	static float startPoint[3];
	static float endPoint[3];
	static float hullMin[3];
	static float hullMax[3];
	static float playerPos[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, startPoint);
	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
		ConformLineDistance(endPoint, startPoint, endPoint, float(BEAM_MaxDistance[client]));
		float lineReduce = BEAM_BeamRadius[client] * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			BEAM_HitDetected[i] = false;
		}
		
		
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			BEAM_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -float(BEAM_BeamRadius[client]);
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		delete trace;
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		FinishLagCompensation_Base_boss();
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		BEAM_Targets_Hit[client] = 1.0;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BEAM_BuildingHit[building])
			{
				if(IsValidEntity(BEAM_BuildingHit[building]))
				{
					WorldSpaceCenter(BEAM_BuildingHit[building], playerPos);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BEAM_CloseBuildingDPT[client] + (BEAM_FarBuildingDPT[client]-BEAM_CloseBuildingDPT[client]) * (distance/BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
					
					float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BEAM_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage*BEAM_Targets_Hit[client]);
					pack.WriteCell(DMG_PLASMA);
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					pack.WriteCell(0);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					
					BEAM_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
				}
				else
					BEAM_BuildingHit[building] = false;
			}
		}
		
		static float belowBossEyes[3];
		GetBeamDrawStartPoint(client, belowBossEyes);
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
	}
	delete trace;
}
