#pragma semicolon 1
#pragma newdecls required

static float Strength[MAXTF2PLAYERS];
static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float Damage_Tornado[MAXENTITIES]={0.0, ...};
static float Duration_Tornado[MAXENTITIES]={0.0, ...};
static float f_TornadoM2CooldownTimer[MAXENTITIES]={0.0, ...};
static int i_WeaponRefM2[MAXENTITIES]={0, ...};
static float f_TornadoDamage[MAXENTITIES]={0.0, ...};
static int i_TornadoManaCost[MAXENTITIES]={0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};

static float TORNADO_Radius[MAXTF2PLAYERS];

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

public void WindStaff_ClearAll()
{
	Zero(Damage_Tornado);
	Zero(f_TornadoM2CooldownTimer);
}
void Wind_Staff_MapStart()
{
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	TBB_Precache_Wind_Staff();
}

public void Weapon_Wind_Laser_Builder_Unused(int client, int weapon, const char[] classname, bool &result)
{
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
	
	float flMultiplier = (GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime")) / 4.0; // 4.0 is the default one
	
	flMultiplier -= 0.30; // Minimum dmg is lower so they dont just spam the fuck out of it and expect more damage like idiots
		
	flMultiplier *= 2.2;
	
	BEAM_Targets_Hit[client] = 0.0;
	Strength[client] = 400.0 * flMultiplier;
	
	Strength[client] *= Attributes_FindOnPlayerZR(client, 287);
	
	float Sniper_Sentry_Bonus_Removal = Attributes_FindOnPlayerZR(client, 344);
			
	if(Sniper_Sentry_Bonus_Removal >= 1.01) //do 1.01 cus minigun sentry can give abit more then less half range etc
	{
		Strength[client] *= 0.5; //Nerf in half as it gives 2x the dmg.
	}
		
	//	TBB_Ability(client);
	RequestFrame(TBB_Ability_Wind_Staff, client);
	
}

public void Weapon_Wind_Laser_Builder(int client, int weapon, const char[] classname, bool &result)
{
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
	
	float flMultiplier = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime"); // 4.0 is the default one
	
	flMultiplier += 1.3; // have a minimum.
		
	flMultiplier *= 1.5;
	
	BEAM_Targets_Hit[client] = 0.0;
	
	Strength[client] = 100.0 * flMultiplier;
	
	float attack_speed;
		
	attack_speed = 1.0 / Attributes_FindOnPlayerZR(client, 343, true, 1.0); //Sentry attack speed bonus
				
	Strength[client] = attack_speed * Strength[client] * Attributes_FindOnPlayerZR(client, 287, true, 1.0);			//Sentry damage bonus
	
	Strength[client] *= 0.5;
			
	//	TBB_Ability(client);
	RequestFrame(TBB_Ability_Wind_Staff, client);
	
}

public void Weapon_Wind_Staff(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
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
		float damage = 125.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
			
		
		int iRot = CreateEntityByName("func_door_rotating");
		if(iRot == -1) return;
	
		float fPos[3];
		GetClientEyePosition(client, fPos);
	
		DispatchKeyValueVector(iRot, "origin", fPos);
		DispatchKeyValue(iRot, "distance", "99999");
		DispatchKeyValueFloat(iRot, "speed", speed);
		DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
		DispatchSpawn(iRot);
		SetEntityCollisionGroup(iRot, 27);
	
		SetVariantString("!activator");
		AcceptEntityInput(iRot, "Open");
	//	EmitSoundToAll(SOUND_WAND_SHOT_FIRE, client, SNDCHAN_WEAPON, 65, _, 0.45, 135);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
		Wand_Launch_Tornado(client, iRot, speed, time, damage, weapon);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}


public void Weapon_Wind_StaffM2(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
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
		float damage = 125.0;
		damage *= Attributes_Get(weapon, 410, 1.0);

		i_WeaponRefM2[client] = EntIndexToEntRef(weapon);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		i_TornadoManaCost[client] = mana_cost / 8;
		f_TornadoDamage[client] = damage * 0.25;

		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
		SDKHook(client, SDKHook_PreThink, WindStaffM2_Think);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void WindStaffM2_Think(int client)
{
	if(GetGameTime() > f_TornadoM2CooldownTimer[client])
	{
		f_TornadoM2CooldownTimer[client] = GetGameTime() + 0.1;
		int buttons = GetClientButtons(client);
		int weapon = EntRefToEntIndex(i_WeaponRefM2[client]);
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != weapon_active)
		{
			SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
			return;
		}
		if (buttons & IN_ATTACK2)
		{
			if(i_TornadoManaCost[client] <= Current_Mana[client])
			{
				Current_Mana[client] -= i_TornadoManaCost[client];
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				float TornadoRange = 300.0;
				Explode_Logic_Custom(f_TornadoDamage[client], client, client, weapon, _, TornadoRange,1.9,_,false);
				float flCarrierPos[3];//, targPos[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", flCarrierPos);
				flCarrierPos[2] += 15.0;
				TE_SetupBeamRingPoint(flCarrierPos, TornadoRange*2.0, (TornadoRange*2.0)+0.5, Beam_Laser, Beam_Glow, 0, 10, 0.11, 25.0, 0.8, {50, 50, 250, 250}, 10, 0);
				TE_SendToAll(0.0);
				return;
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", i_TornadoManaCost[client]);
			}
		}
		SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
		return;
	}	
}

void TBB_Precache_Wind_Staff()
{
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

void TBB_Ability_Wind_Staff(int client)
{
	for (int building = 1; building < MAX_TARGETS_HIT; building++)
	{
		BEAM_BuildingHit[building] = false;
		BEAM_Targets_Hit[client] = 0.0;
	}
			
	BEAM_IsUsing[client] = false;
	BEAM_TicksActive[client] = 0;

	BEAM_CanUse[client] = true;
	BEAM_CloseDPT[client] = 2.0;
	BEAM_FarDPT[client] = 1.0;
	
	float sentry_range;
			
	sentry_range = Attributes_FindOnPlayerZR(client, 344, true, 1.0);			//Sentry Range bonus
	
	BEAM_MaxDistance[client] = RoundToCeil(1000.0 * sentry_range);
	BEAM_BeamRadius[client] = 50;
	BEAM_ColorHex[client] = ParseColor("D3D3D3");
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
		entity = Target_Hit_Wand_Detection(client, entity);
		if(0 < entity)
		{
			for(int i=1; i <= (MAX_TARGETS_HIT -1 ); i++)
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
		CloseHandle(trace);
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
		
		
		for (int building = 1; building < MAX_TARGETS_HIT; building++)
		{
			BEAM_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -float(BEAM_BeamRadius[client]);
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
//		int weapon = BEAM_UseWeapon[client] ? GetPlayerWeaponSlot(client, 2) : -1;
		/*
		for (int victim = 1; victim < MaxClients; victim++)
		{
			if (BEAM_HitDetected[victim] && BossTeam != GetClientTeam(victim))
			{
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
				float distance = GetVectorDistance(startPoint, playerPos, false);
				float damage = BEAM_CloseDPT[client] + (BEAM_FarDPT[client]-BEAM_CloseDPT[client]) * (distance/BEAM_MaxDistance[client]);
				if (damage < 0)
					damage *= -1.0;
				TakeDamage(victim, client, client, damage/6, 2048, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
			}
		}
		*/
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
					playerPos = WorldSpaceCenter(BEAM_BuildingHit[building]);
					
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BEAM_CloseBuildingDPT[client] + (BEAM_FarBuildingDPT[client]-BEAM_CloseBuildingDPT[client]) * (distance/BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					SDKHooks_TakeDamage(BEAM_BuildingHit[building], client, client, damage/BEAM_Targets_Hit[client], DMG_PLASMA, weapon_active, CalculateDamageForce(vecForward, 10000.0), playerPos);	// 2048 is DMG_NOGIB?
					BEAM_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF; //sneaky. DONT do 1.25.
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
	else
	{
		delete trace;
	}
}

static void Wand_Launch_Tornado(int client, int iRot, float speed, float time, float damage, int weapon)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return;
	

	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);

	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);	
	
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", GetClientTeam(client));

	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iCarrier));
	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iRot));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	Projectile_To_Weapon[iCarrier] = EntIndexToEntRef(weapon);
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	//raygun_projectile_blue
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "utaunt_tornado_twist_white", 5.0);

		default:
			particle = ParticleEffectAt(position, "utaunt_tornado_twist_white", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	
	DataPack pack;
	CreateDataTimer(time, Timer_Stop_Tornado, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Tornado_OnHatTouch);
}

public Action Event_Tornado_OnHatTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0),Entity_Position);	// 2048 is DMG_NOGIB?
		
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			//GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", position);
			RemoveEntity(particle);
		}
		
		SetEntityMoveType(entity, MOVETYPE_NONE);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 0);
		SetEntityCollisionGroup(entity, 0);
		Wand_Create_Tornado(Projectile_To_Client[entity], entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			//GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", position);
			RemoveEntity(particle);
		}
		
		SetEntityMoveType(entity, MOVETYPE_NONE);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 0);
		SetEntityCollisionGroup(entity, 0);
		Wand_Create_Tornado(Projectile_To_Client[entity], entity);
	}
	return Plugin_Handled;
}

public Action Timer_Stop_Tornado(Handle timer, DataPack pack)
{
	pack.Reset();
	int iCarrier = EntRefToEntIndex(pack.ReadCell());
	int particle = EntRefToEntIndex(pack.ReadCell());
	int iRot = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEdict(particle) && particle>MaxClients)
	{
		RemoveEntity(particle);
	}
	if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
	{
		if (GetEntityMoveType(iCarrier)!=MOVETYPE_NONE)
		{
			SetEntityMoveType(iCarrier, MOVETYPE_NONE);
			SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 0);
			SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
			SetEntityCollisionGroup(iCarrier, 0);
			
			Wand_Create_Tornado(Projectile_To_Client[iCarrier], iCarrier);
		}
	}
	if(IsValidEdict(iRot) && iRot>MaxClients)
	{
		RemoveEntity(iRot);
	}
	return Plugin_Handled; 
}

static void Wand_Create_Tornado(int client, int iCarrier)
{
	float flCarrierPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	/*
	int particle = 0;
	//raygun_projectile_blue
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(flCarrierPos, "utaunt_tornado_twist_white", 5.0);

		default:
			particle = ParticleEffectAt(flCarrierPos, "utaunt_tornado_twist_white", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	*/
	
	TORNADO_Radius[client] = 215.0;
	
	int weapon = EntRefToEntIndex(Projectile_To_Weapon[iCarrier]);
	if(IsValidEntity(weapon))
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
			
		Damage_Tornado[iCarrier] = damage;
		Duration_Tornado[iCarrier] = GetGameTime() + 5.0;
		
		TE_SetupBeamRingPoint(flCarrierPos, TORNADO_Radius[client]*2.0, (TORNADO_Radius[client]*2.0)+0.5, Beam_Laser, Beam_Glow, 0, 10, 5.0, 25.0, 0.8, {50, 50, 250, 250}, 10, 0);
		TE_SendToAll(0.0);
		
		CreateTimer(0.5, Timer_Tornado_Think, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
}

public Action Timer_Tornado_Think(Handle timer, int iCarrier)
{
	int client = Projectile_To_Client[iCarrier];
	// int particle = Projectile_To_Particle[iCarrier];
	
	if (!IsValidEdict(iCarrier) || iCarrier<=MaxClients || Duration_Tornado[iCarrier]<=GetGameTime())
	{
		/*
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		*/
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	if (!IsValidClient(client))
	{
		/*
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		*/
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	float flCarrierPos[3];//, targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);

//	i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_PLASMA_DAMAGE;
	
	Explode_Logic_Custom(Damage_Tornado[iCarrier], client, client, -1, flCarrierPos, TORNADO_Radius[client],2.2,_,false);
	
	return Plugin_Continue;
}