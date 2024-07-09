#pragma semicolon 1
#pragma newdecls required

#define HITSCAN_BOOM	  "ambient/explosions/explode_4.wav"
#define LASER_BOOMSTICK	  "npc/scanner/cbot_energyexplosion1.wav"

#define MAX_BOOMSTICK_LASER_SPREAD 7

static float Strength[MAXTF2PLAYERS];
static float Accuracy[MAXTF2PLAYERS];

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
static bool BEAM_HitDetected[MAXTF2PLAYERS][MAX_BOOMSTICK_LASER_SPREAD];
static int BEAM_BuildingHit[MAX_TARGETS_HIT][MAX_BOOMSTICK_LASER_SPREAD];
static bool BEAM_UseWeapon[MAXTF2PLAYERS];
int RepeatOnBoomstickLaser;

static float BEAM_Targets_Hit[MAXTF2PLAYERS];

void BoomStick_MapPrecache()
{
	PrecacheSound(HITSCAN_BOOM);
	PrecacheSound(LASER_BOOMSTICK);
	TBB_Precahce_Boomstick();
}


static void TBB_Precahce_Boomstick()
{
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

public void Weapon_Boom_Stick(int client, int weapon, const char[] classname, bool &result)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 4);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -200.0 * Ratio;
		
		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues

			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;

	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	Client_Shake(client, 0, 35.0 * Ratio, 20.0 * Ratio, 0.8 * Ratio);
}

public void Weapon_Boom_Stick_Louder(int client, int weapon, const char[] classname, bool &result)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 6);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		
		float knockback = -250.0 * Ratio;

		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	Client_Shake(client, 0, 45.0 * Ratio, 30.0 * Ratio, 0.8 * Ratio);
}

public void Weapon_Boom_Stick_Loudest(int client, int weapon, const char[] classname, bool &result)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 8);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		
		float knockback = -275.0 * Ratio;

		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	Client_Shake(client, 0, 50.0 * Ratio, 35.0 * Ratio, 0.9 * Ratio);
}

public void Marksman_boom_rifle(int client, int weapon, const char[] classname, bool &result)
{
	float damage = 100.0;
	damage *= RoundToCeil(Attributes_Get(weapon, 2, 1.0));
		
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
			   
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	}	
	SpawnSmallExplosionNotRandom(spawnLoc);
	EmitSoundToAll(HITSCAN_BOOM, -1, _, 80, _, _, _, _,spawnLoc);
	Explode_Logic_Custom(damage, client, client, weapon, spawnLoc);
		
	FinishLagCompensation_Base_boss();
	delete trace;
}


public void Weapon_Boom_Stick_Louder_Laser(int client, int weapon, const char[] classname, bool &result)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 6);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -200.0 * Ratio;
		
		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	Client_Shake(client, 0, 45.0 * Ratio, 30.0 * Ratio, 0.8 * Ratio);
	
	BEAM_Targets_Hit[client] = 0.0;
	
	Strength[client] = 6.0;
				
	Strength[client] *= Attributes_Get(weapon, 1, 1.0);
					
	Strength[client] *= Attributes_Get(weapon, 2, 1.0);
		
	float extra_accuracy = 6.5;
		
	Accuracy[client] = extra_accuracy;
	
	Accuracy[client] *= Attributes_Get(weapon, 106, 1.0);
			
	TBB_Ability_Boomstick(client);
}



static void TBB_Ability_Boomstick(int client)
{
	for (int repeats = 1; repeats <= 6; repeats++)
	{
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			BEAM_BuildingHit[building][repeats] = false;
			BEAM_Targets_Hit[client][repeats] = 0.0;
		}
	}
			
	BEAM_IsUsing[client] = false;
	BEAM_TicksActive[client] = 0;

	BEAM_CanUse[client] = true;
	BEAM_CloseDPT[client] = 2.0;
	BEAM_FarDPT[client] = 1.0;
	BEAM_MaxDistance[client] = 1000;
	BEAM_BeamRadius[client] = 5;
	BEAM_ColorHex[client] = ParseColor("FFA500");
	BEAM_ChargeUpTime[client] = 1;
	BEAM_CloseBuildingDPT[client] = Strength[client];
	BEAM_FarBuildingDPT[client] = Strength[client] * 0.75;
	BEAM_Duration[client] = 2.5;
	
	BEAM_BeamOffset[client][0] = 0.0;
	BEAM_BeamOffset[client][1] = 0.0;
	BEAM_BeamOffset[client][2] = 0.0;

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
				if(!BEAM_BuildingHit[i][RepeatOnBoomstickLaser])
				{
					BEAM_BuildingHit[i][RepeatOnBoomstickLaser] = entity;
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
	
	
	GetClientEyePosition(client, startPoint);
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float Damage_dealt[MAX_TARGETS_HIT];
	
	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		Damage_dealt[building] = 0.0;
	}
	for (int repeats = 1; repeats <= 6; repeats++)
	{
		RepeatOnBoomstickLaser = repeats;
		GetClientEyeAngles(client, angles);
		switch(repeats)
		{
			case 1:
			{
				angles[0] += -Accuracy[client];
				angles[1] += Accuracy[client]*2.0;
			}
			case 2:
			{
				angles[0] += -Accuracy[client];
				angles[1] += 0.0;
			}
			case 3:
			{
				angles[0] += -Accuracy[client];
				angles[1] += -(Accuracy[client]*2.0);
			}
			case 4:
			{
				angles[0] += Accuracy[client];
				angles[1] += Accuracy[client]*2.0;
			}
			case 5:
			{
				angles[0] += Accuracy[client];
				angles[1] += 0.0;
			}
			case 6:
			{
				angles[0] += Accuracy[client];
				angles[1] += -(Accuracy[client]*2.0);
			}
		}
		BEAM_Targets_Hit[client] = 0.0;
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
				BEAM_HitDetected[i][repeats] = false;
			}
			
			
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				BEAM_BuildingHit[building][repeats] = false;
			}
			
			
			hullMin[0] = -float(BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			delete trace;
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?

			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			
			BEAM_Targets_Hit[client] = 1.0;
		//	int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				if (BEAM_BuildingHit[building][repeats])
				{
					if(IsValidEntity(BEAM_BuildingHit[building][repeats]))
					{
						WorldSpaceCenter(BEAM_BuildingHit[building][repeats], playerPos);
						
						float distance = GetVectorDistance(startPoint, playerPos, false);
						float damage = BEAM_CloseBuildingDPT[client] + (BEAM_FarBuildingDPT[client]-BEAM_CloseBuildingDPT[client]) * (distance/BEAM_MaxDistance[client]);
						if (damage < 0)
							damage *= -1.0;

						Damage_dealt[building] += (damage / BEAM_Targets_Hit[client]);
						BEAM_Targets_Hit[client] *= (LASER_AOE_DAMAGE_FALLOFF + 0.35); //Nerf the pierce by alot
					}
					else
						BEAM_BuildingHit[building][repeats] = false;
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
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 60);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		delete trace;
	}
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	
	//Do another loop that does the actual damages!
	int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	for (int repeats = 1; repeats <= 6; repeats++)
	{
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BEAM_BuildingHit[building][repeats])
			{
				if(IsValidEntity(BEAM_BuildingHit[building][repeats]))
				{
					WorldSpaceCenter(BEAM_BuildingHit[building][repeats], playerPos);
							
				//	float distance = GetVectorDistance(startPoint, playerPos, false);
					
					float damage_force[3]; CalculateDamageForce(vecForward, 20000.0, damage_force);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BEAM_BuildingHit[building][repeats]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(Damage_dealt[building]);
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
				}
			}
		}
	}
	FinishLagCompensation_Base_boss();
}


float BoomstickAdjustDamageAndAmmoCount(int weapon, int bulletsmax)
{
	int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	int CurrentClip = GetEntData(weapon, iAmmoTable, 4);

	float RatioMax;

	RatioMax = float(CurrentClip) / float(bulletsmax);

	SetEntData(weapon, iAmmoTable, 1);
	SetEntProp(weapon, Prop_Send, "m_iClip1", 1); // weapon clip amount bullets
	Attributes_Set(weapon, 1, RatioMax);

	return RatioMax;
}