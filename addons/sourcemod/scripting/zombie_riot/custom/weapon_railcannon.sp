#pragma semicolon 1
#pragma newdecls required

#define RAILCANNON_BOOM 			"weapons/physcannon/superphys_launch2.wav"
#define RAILCANNONPAP2_BOOM 		"beams/beamstart5.wav"
#define RAILCANNONPAP3_BOOM 		"weapons/gauss/fire1.wav"
#define RAILCANNONPAP4_ABILITY_BOOM "weapons/sniper_railgun_charged_shot_01.wav"
#define RAILCANNONPAP4_ABILITY		"weapons/loose_cannon_charge.wav"
#define RAILCANNONPAP4_BEEP			"misc/rd_finale_beep01.wav"
#define RAILCANNONPAP4_HIT			"physics/glass/glass_largesheet_break1.wav"

static float Strength[MAXTF2PLAYERS];

static bool BEAM_CanUse[MAXTF2PLAYERS];
static bool BEAM_IsUsing[MAXTF2PLAYERS];
static int BEAM_TicksActive[MAXTF2PLAYERS];
static int Beam_Laser;
static int Beam_Glow;
static int BEAM_MaxDistance[MAXTF2PLAYERS];
static int BEAM_BeamRadius[MAXTF2PLAYERS];
static int BEAM_ColorHex[MAXTF2PLAYERS];
static int BEAM_ChargeUpTime[MAXTF2PLAYERS];
static float BEAM_Duration[MAXTF2PLAYERS];
static float BEAM_BeamOffset[MAXTF2PLAYERS][3];
static float BEAM_ZOffset[MAXTF2PLAYERS];
static bool BEAM_HitDetected[MAXTF2PLAYERS];
static int BEAM_BuildingHit[MAX_TARGETS_HIT];
static bool BEAM_UseWeapon[MAXTF2PLAYERS];
static float BEAM_Targets_Hit[MAXTF2PLAYERS];

static bool Handle_on[MAXPLAYERS+1]={false, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static float base_chargetime[MAXPLAYERS+1]={-1.0, ...};

static bool Zoom_Active[MAXTF2PLAYERS] = {false, ...};
static int Zoom_Default[MAXTF2PLAYERS] = {90, ...};
static Handle ORC_Timer[MAXTF2PLAYERS];
static Handle ORC_BeepTimer[MAXTF2PLAYERS];

void Precache_Railcannon()
{
	PrecacheSound(RAILCANNON_BOOM);
	PrecacheSound(RAILCANNONPAP2_BOOM);
	PrecacheSound(RAILCANNONPAP3_BOOM);
	PrecacheSound(RAILCANNONPAP4_ABILITY);
	Beam_Laser = PrecacheModel("materials/sprites/physbeam.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
}

//no pap
public void Weapon_Railcannon(int client, int weapon, const char[] classname, bool &result)
{
	Check_Railcannon(client, weapon, 0);
}
//1
public void Weapon_Railcannon_Pap1(int client, int weapon, const char[] classname, bool &result)
{
	Check_Railcannon(client, weapon, 1);
}
//2
public void Weapon_Railcannon_Pap2(int client, int weapon, const char[] classname, bool &result)
{
	Check_Railcannon(client, weapon, 2);
}

public void Weapon_Railcannon_Pap2_Zoom(int client, int weapon, const char[] classname, bool &result)
{
	Zoom_Railcannon(client);
}

public void Weapon_Railcannon_Pap2_Holster(int client, int weapon, const char[] classname, bool &result)
{
	int ZoomFOV = 30; //if you change this, change the next 2 occurances too
	Zoom_Active[client] = false;
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	if (Zoom_Default[client] == ZoomFOV)
		Zoom_Default[client] = 90;
	SetEntProp(client, Prop_Send, "m_iFOV", Zoom_Default[client]);
}
//3
public void Weapon_Railcannon_Pap3(int client, int weapon, const char[] classname, bool &result)
{
	Check_Railcannon(client, weapon, 3);
}
//4
public void Weapon_Railcannon_Pap4(int client, int weapon, const char[] classname, bool &result)
{
	Check_Railcannon(client, weapon, 4);
}

public void Weapon_Railcannon_Pap4_Zoom(int client, int weapon, const char[] classname, bool &result)
{
	Zoom_Railcannon(client);
}

public void Weapon_Railcannon_Pap4_Ability(int client, int weapon, bool crit, int slot)
{
	float cooldown = 100.0;
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ability_Apply_Cooldown(client, slot, cooldown);
			EmitSoundToAll(RAILCANNONPAP4_ABILITY, client, SNDCHAN_STATIC, 90, _, 1.0, 40);
			SetEntityMoveType(client, MOVETYPE_NONE);
			DataPack pack;
			ORC_Timer[client] = CreateDataTimer(10.0, Ability_ORC, pack);
			pack.WriteCell(client);
			pack.WriteCell(weapon);
			ORC_BeepTimer[client] = CreateTimer(9.15, Beep_ORC, client);
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public void Weapon_Railcannon_Pap4_Holster(int client, int weapon, const char[] classname, bool &result)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	int ZoomFOV = 30;
	Zoom_Active[client] = false;
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	if (Zoom_Default[client] == ZoomFOV)
		Zoom_Default[client] = 90;
	SetEntProp(client, Prop_Send, "m_iFOV", Zoom_Default[client]);
	StopSound(client, SNDCHAN_STATIC, RAILCANNONPAP4_ABILITY);
	if (ORC_Timer[client])
	{
		delete ORC_Timer[client];
	}
	if (ORC_BeepTimer[client])
	{
		delete ORC_BeepTimer[client];
	}
}

static void Beep_ORC(Handle timer, int client)
{
	ORC_BeepTimer[client] = null;
	EmitSoundToAll(RAILCANNONPAP4_BEEP, client, SNDCHAN_STATIC, 00, _, 1.0, 200);
}

static void Ability_ORC(Handle timer, DataPack pack)
{
	int client;
	int weapon;
	pack.Reset();
	client = pack.ReadCell();
	weapon = pack.ReadCell();
	ORC_Timer[client] = null;

	Strength[client] = 1200.0;
	Strength[client] *= Attributes_Get(weapon, 1, 1.0);
	Strength[client] *= Attributes_Get(weapon, 2, 1.0);

	Attack_Railcannon(client, 4, true);

	SetEntityMoveType(client, MOVETYPE_WALK);
}

static void Zoom_Railcannon(int client)
{
	int ZoomFOV = 30;
	if (Zoom_Active[client] == false)
	{
		Zoom_Default[client] = GetEntProp(client, Prop_Send, "m_iFOV");
		Zoom_Active[client] = true;
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", ZoomFOV);
	}
	else
	{
		Zoom_Active[client] = false;
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		if (Zoom_Default[client] == ZoomFOV)
			Zoom_Default[client] = 90;
		SetEntProp(client, Prop_Send, "m_iFOV", Zoom_Default[client]);
	}
}

static void Check_Railcannon(int client, int weapon, int pap)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
		}
		else 
		{
			base_chargetime[client] = Attributes_Get(weapon, 670, 1.0);
				
			if(Attributes_Has(weapon,466))
				base_chargetime[client] = Attributes_Get(weapon, 466, 1.0);
			
			float flMultiplier = GetRailcannonPercentage(weapon, client);
			
			switch(pap)
			{
				case 0:
					if (flMultiplier<3.85)
					{
						SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
						return;
					}
				case 1:
					if (flMultiplier<1.33)
					{
						SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
						return;
					}
				case 2:
					if (flMultiplier<3.925) //increased value due to compensate for longer charge time
					{
						SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
						return;
					}
				case 4:
					if (flMultiplier<3.925) //increased value due to compensate for longer charge time
					{
						SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
						return;
					}
			}
		}

		//pre-beam damage
		BEAM_Targets_Hit[client] = 0.0;
		
		Strength[client] = 150.0;
					
		Strength[client] *= Attributes_Get(weapon, 1, 1.0);
					
		Strength[client] *= Attributes_Get(weapon, 2, 1.0);

		float flMultiplier = GetRailcannonPercentage(weapon, client);
		if (pap == 3)
		{
			//Reduced charge damage for TAU cannon
			Strength[client] *= 1 + (flMultiplier/8);
		}
		else
		{
			Strength[client] *= (flMultiplier/4);
		}

		//knockback
		if (pap == 1 || pap == 3)
		{
			Knockback_Railcannon(client, weapon, true);
		}
		else
		{
			Knockback_Railcannon(client, weapon, false);
		}

		Attack_Railcannon(client, pap, false);
	}
}

static void Knockback_Railcannon(int client, int weapon, bool analogue)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);

		float flMultiplier = GetRailcannonPercentage(weapon, client);
		float knockback;
		if (analogue == true)
		{
			knockback = -100.0 * (flMultiplier/4);
		}
		else
		{
			knockback = -100.0;
		}
		
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 100.0; // a little boost to alleviate arcing issues
		
		if (analogue == true)
			velocity[2] *= (flMultiplier/4);
		
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
	Client_Shake(client, 0, 35.0, 20.0, 0.8);
}

static void Attack_Railcannon(int client, int pap, bool supercharged)
{
	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		BEAM_BuildingHit[building] = false;
		BEAM_Targets_Hit[client] = 0.0;
	}
			
	BEAM_IsUsing[client] = false;
	BEAM_TicksActive[client] = 0;

	BEAM_CanUse[client] = true;
	BEAM_MaxDistance[client] = 8192;
	BEAM_BeamRadius[client] = 1;
	if (pap == 4)
	{
		BEAM_ColorHex[client] = ParseColor("FFFF00");
	}
	else
	{
		BEAM_ColorHex[client] = ParseColor("00FFFF");
	}
	BEAM_ChargeUpTime[client] = 1;
	BEAM_Duration[client] = 2.5;
	
	BEAM_BeamOffset[client][0] = 0.0;
	BEAM_BeamOffset[client][1] = -8.0;
	BEAM_BeamOffset[client][2] = 15.0;

	BEAM_ZOffset[client] = 0.0;
	BEAM_UseWeapon[client] = false;

	BEAM_IsUsing[client] = true;
	BEAM_TicksActive[client] = 0;

	switch (pap)
	{
		case 2:
			EmitSoundToAll(RAILCANNONPAP2_BOOM, client, SNDCHAN_STATIC, 85, _, 1.0);
		case 3:
			EmitSoundToAll(RAILCANNONPAP3_BOOM, client, SNDCHAN_STATIC, 85, _, 1.0);
		case 4:
			if (supercharged)
				EmitSoundToAll(RAILCANNONPAP4_ABILITY_BOOM, client, SNDCHAN_STATIC, 90, _, 1.0);
			else
				EmitSoundToAll(RAILCANNONPAP3_BOOM, client, SNDCHAN_STATIC, 85, _, 1.0);
		default:
			EmitSoundToAll(RAILCANNON_BOOM, client, SNDCHAN_STATIC, 90, _, 1.0);
	}
	
	Railcannon_Tick(client, pap, supercharged);
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

static void Railcannon_Tick(int client, int pap, bool supercharged)
{
	if(!IsValidClient(client))
	{
		return;
	}

//	int BossTeam = GetClientTeam(client);
//	BEAM_TicksActive[client] = tickCount;
	float diameter = float(BEAM_BeamRadius[client] * 2);
	if (supercharged)
	{
		diameter *= 3;
	}
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
					if (!supercharged || BEAM_Targets_Hit[client] == 1)
					{
						if (supercharged)
						{
							EmitSoundToAll(RAILCANNONPAP4_HIT, BEAM_BuildingHit[building], SNDCHAN_STATIC, 90, _, 1.0, 80);
						}

						playerPos = WorldSpaceCenterOld(BEAM_BuildingHit[building]);
						float distance = GetVectorDistance(startPoint, playerPos, false);
						float damage = Strength[client];
						if (!(GetEntityFlags(client) & FL_ONGROUND) && !supercharged)
						{
							damage *= 1.2;
						}
						if (damage < 0)
						{
							damage *= -1.0;
						}
						if (pap == 2 || pap == 4)
						{
							float criticalDistance = 4000.0;
							float maxDistanceMultiplier = 2.1;
							damage *= (1.0 + (fClamp(distance / criticalDistance, 0.0, criticalDistance) * (maxDistanceMultiplier - 1.0)));
						}
						else
						{
							float minFalloffDistance = 100.0;
							float maxFalloffDistance = 1500.0;
							float minDamageMultiplier = 0.05;
							damage *= (1.0 - (fClamp(((distance - minFalloffDistance) / maxFalloffDistance), 0.0, (1 - minDamageMultiplier))));
						}

						float damage_force[3];
						damage_force = CalculateDamageForceOld(vecForward, 10000.0);
						DataPack pack = new DataPack();
						pack.WriteCell(EntIndexToEntRef(BEAM_BuildingHit[building]));
						pack.WriteCell(EntIndexToEntRef(client));
						pack.WriteCell(EntIndexToEntRef(client));
						pack.WriteFloat(damage/BEAM_Targets_Hit[client]);
						if (supercharged)
							pack.WriteCell(DMG_SLASH);
						else
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
				}
				else
				{
					BEAM_BuildingHit[building] = false;
				}
			}
		}
		
		static float belowBossEyes[3];
		GetBeamDrawStartPoint(client, belowBossEyes);
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 60);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 255);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 255);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 255);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1 * 1.28), ClampBeamWidth(diameter * 1 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 255);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 2 * 1.28), ClampBeamWidth(diameter * 2 * 1.28), 0, 1.5, glowColor, 0);
		TE_SendToAll(0.0);
	}
	delete trace;
}

static float GetRailcannonPercentage(int weapon, int client)
{
	float flMultiplier = GetGameTime();
	flMultiplier -= GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
	flMultiplier /= base_chargetime[client];
	return flMultiplier;
}