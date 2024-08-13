#pragma semicolon 1
#pragma newdecls required

static float fl_laz_dmg_throttle[MAXTF2PLAYERS];
static float fl_laz_distance[MAXTF2PLAYERS];
static int i_weapon_onuse[MAXTF2PLAYERS];

/*void Laz_Laser_Cannon_MapStart()
{
	
}*/

public void Laz_Cannon_Mouse1(int client, int weapon, bool &result, int slot)
{
	fl_laz_dmg_throttle[client] = 0.0;
	i_weapon_onuse[client] = EntIndexToEntRef(weapon);
	SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);
	SDKHook(client, SDKHook_PreThink, Laz_Laser_Tick);
}

static void Laz_Laser_Tick(int client)
{
	bool Mouse1 = (GetClientButtons(client) & IN_ATTACK) != 0;
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weapon = EntRefToEntIndex(i_weapon_onuse[client]);
	if(!Mouse1 || weapon_holding != weapon)
	{
		SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);
		return;
	}
	float GameTime = GetGameTime();

	bool update = false;
	if(fl_laz_dmg_throttle[client] < GameTime)
	{
		fl_laz_dmg_throttle[client] = GameTime + 0.2;
		update = true;
	}

	
	float Radius = 30.0;
	float diameter = Radius*2.0;

	float Start[3], End[3], Angles[3];
	if(update)
	{
		Player_Laser_Logic Laser;
		Laser.client = client;
		Laser.Damage = 100.0;
		Laser.Radius = Radius;
		Laser.damagetype = DMG_PLASMA;
		Laser.DoForwardTrace_Basic(1000.0);
		Laser.Deal_Damage();
		fl_laz_distance[client] = GetVectorDistance(Laser.Start_Point, Laser.End_Point);
		Offset_Vector({0.0, -13.0, -1.0}, Laser.Angles, Laser.Start_Point);
		Start = Laser.Start_Point;
		End = Laser.End_Point;
	}
	else
	{
		GetClientEyePosition(client, Start);
		GetClientEyeAngles(client, Angles);
		Get_Fake_Forward_Vec(fl_laz_distance[client], Angles, End, Start);
		Offset_Vector({0.0, -13.0, -1.0}, Angles, Start);
	}

	float TE_Duration = 0.05019608415;

	int color[4] = {100, 100, 100, 75};

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.3, diameter*0.5);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	TE_SetupBeamPoints(Start, End, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9,  Start_Diameter1*0.9, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start, End, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, Start_Diameter2*0.9, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start, End, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, Start_Diameter3*0.9, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);
}
static void Offset_Vector(float BEAM_BeamOffset[3], float Angles[3], float Result_Vec[3])
{
	float tmp[3];
	float actualBeamOffset[3];

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	Result_Vec[0] += actualBeamOffset[0];
	Result_Vec[1] += actualBeamOffset[1];
	Result_Vec[2] += actualBeamOffset[2];
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}