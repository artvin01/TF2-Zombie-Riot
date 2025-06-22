#pragma semicolon 1
#pragma newdecls required

static float fl_laz_dmg_throttle[MAXPLAYERS];
static float fl_laz_distance[MAXPLAYERS];
static int i_weapon_onuse[MAXPLAYERS];
static float fl_heat[MAXPLAYERS];
static float fl_overheat_timer[MAXPLAYERS];
static float fl_hud_timer[MAXPLAYERS];
static float fl_laser_last_fired[MAXPLAYERS];
//static float fl_deviation_cycle[MAXPLAYERS];

#define LAZ_LASER_CANNON_HEATGAIN 1.0	//heat gained every time it deals damage
#define LAZ_LASER_CANNON_OVERHEAT 75.0	//how much heat to have for it to overheat.
#define LAZ_LASER_CANNON_OVERHEAT_TIMER	7.5	//how long must the player forcefully not shoot for the laser cannon to recharge without having to heatdump.
#define LAZ_LASER_CANNON_REPLACE_COST 500	//how much laser battery to consume upon replacing the core

public void Laz_Cannon_Mouse1(int client, int weapon, bool &result, int slot)
{
	float GameTime = GetGameTime();
	if(fl_overheat_timer[client] > GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon's core has overheated [%.1fs]\nPress RELOAD to manually replace the core instantly. Cost [%i]", fl_overheat_timer[client]-GetGameTime(), LAZ_LASER_CANNON_REPLACE_COST);
		return;
	}
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintHintText(client,"You ran out of Laser Battery!");
		return;
	}

	float time = (GetGameTime() - fl_laser_last_fired[client]);
	if(time > LAZ_LASER_CANNON_OVERHEAT_TIMER)
		time = LAZ_LASER_CANNON_OVERHEAT_TIMER;

	float Time_Ratio = time/(LAZ_LASER_CANNON_OVERHEAT_TIMER*0.9);
	fl_heat[client]-= LAZ_LASER_CANNON_OVERHEAT*Time_Ratio;
	if(fl_heat[client]<0.0)
		fl_heat[client] = 0.0;


	fl_laser_last_fired[client] = GetGameTime();
	fl_hud_timer[client] = 0.0;
	//fl_laz_dmg_throttle[client] = 0.0;	//if this existed: auto clicker = does damage every tick
	i_weapon_onuse[client] = EntIndexToEntRef(weapon);
	SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);
	SDKHook(client, SDKHook_PreThink, Laz_Laser_Tick);
}

public void Laz_Cannon_HeatDump(int client, int weapon, bool &result, int slot)
{
	if(fl_heat[client]<=0.0 && fl_overheat_timer[client] < GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon's core is already cold");
		return;
	}
	int new_ammo = GetAmmo(client, 23);
	int Cost = LAZ_LASER_CANNON_REPLACE_COST;
	if(new_ammo < Cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Not Enough Laser Battery to replace Core. [%i/%i]",new_ammo,Cost);
		return;
	}
	fl_laser_last_fired[client] = GetGameTime();
	new_ammo -= Cost;
	SetAmmo(client, 23, new_ammo);
	CurrentAmmo[client][23] = GetAmmo(client, 23);

	fl_overheat_timer[client] = 0.0;
	fl_heat[client] = 0.0;
}

static bool Handle_Ammo(int client)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 10)
	{
		new_ammo -= 10;
		SetAmmo(client, 23, new_ammo);
		CurrentAmmo[client][23] = GetAmmo(client, 23);
		return true;
	}
	return false;
}
static bool Handle_Heat(int client, char HUDText[255])
{
	fl_heat[client] += LAZ_LASER_CANNON_HEATGAIN;
	float Ratio = fl_heat[client]/LAZ_LASER_CANNON_OVERHEAT*100.0;

	Format(HUDText, sizeof(HUDText), "%sĄHeat:Ę%.0f％%ĖČ",HUDText, Ratio);
	if(Ratio > 75.0)
		Format(HUDText, sizeof(HUDText), "%s\n<HEAT CRITICAL>",HUDText);

	if(fl_heat[client]>=LAZ_LASER_CANNON_OVERHEAT)
		return true;
	return false;
}
/*
static void Laser_Deviation(int client, float Angles[3], float Deviation)
{
	if(fl_deviation_cycle[client] < GetGameTime())
		fl_deviation_cycle[client] = GetGameTime() + 1.0;

	float timer = fl_deviation_cycle[client] - GetGameTime();

	float Cycle = Sine(fabs(timer)*2.0*FLOAT_PI);
	float Cycle2 = Sine(fabs(timer)*-4.0*FLOAT_PI);

	Angles[0]+=Deviation*Cycle2;
	Angles[1]+=Deviation*Cycle;
}
*/
static void Laz_Laser_Tick(int client)
{
	bool Mouse1 = (GetClientButtons(client) & IN_ATTACK) != 0;
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weapon = EntRefToEntIndex(i_weapon_onuse[client]);
	if(!Mouse1 || weapon_holding != weapon || !IsValidEntity(weapon))
	{
		SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);
		return;
	}
	float GameTime = GetGameTime();
	fl_laser_last_fired[client] = GameTime;

	bool update = false;
	if(fl_laz_dmg_throttle[client] < GameTime)
	{
		
		char HUDText[255]; HUDText = "";

		if(Handle_Heat(client, HUDText))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon's Core has overheated!");
			PrintHintText(client,"CORE OVERHEAT");
			
			SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);

			fl_overheat_timer[client] = GameTime + 7.5;
			fl_heat[client] = 0.0;
			return;
		}

		if(!Handle_Ammo(client))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			PrintHintText(client,"You ran out of Laser Battery!");
			SDKUnhook(client, SDKHook_PreThink, Laz_Laser_Tick);
			return;
		}
		Format_Fancy_Hud(HUDText);
		float update_rate = 0.2;
		update_rate *= Attributes_Get(weapon, 6, 1.0);
		fl_laz_dmg_throttle[client] = GameTime + update_rate;
		update = true;
		
		if(fl_hud_timer[client] < GameTime)
		{
			fl_hud_timer[client] = GameTime + 0.5;
			PrintHintText(client, HUDText);
			
		}
	}

	
	float Radius = 7.5;
	float diameter = 60.0;

	//float Deviation = 1.5;
	//Deviation *=Attributes_Get(weapon, 106, 1.0);

	float Start[3], End[3], Angles[3];
	if(update)
	{
		float damage = 100.0;
		damage *=Attributes_Get(weapon, 1, 1.0);
		damage *=Attributes_Get(weapon, 2, 1.0);
		float Range = 1000.0;
		Range *= Attributes_Get(weapon, 103, 1.0);
		Range *= Attributes_Get(weapon, 104, 1.0);
		Range *= Attributes_Get(weapon, 475, 1.0);

		//106 deviation.
		
		Player_Laser_Logic Laser;
		Laser.client = client;
		Laser.Damage = damage;
		Laser.Radius = Radius;
		Laser.damagetype = DMG_PLASMA;
		GetClientEyeAngles(client, Angles);
		//Laser_Deviation(client,Angles, Deviation);
		GetClientEyePosition(client, Start);
		Laser.DoForwardTrace_Custom(Angles, Start, Range);
		Laser.Deal_Damage();
		fl_laz_distance[client] = GetVectorDistance(Laser.Start_Point, Laser.End_Point);
		Offset_Vector({0.0, -12.0, -2.0}, Laser.Angles, Laser.Start_Point);
		Start = Laser.Start_Point;
		End = Laser.End_Point;
	}
	else
	{
		GetClientEyePosition(client, Start);
		GetClientEyeAngles(client, Angles);
		//Laser_Deviation(client,Angles, Deviation);
		Get_Fake_Forward_Vec(fl_laz_distance[client], Angles, End, Start);
		Offset_Vector({0.0, -12.0, -2.0}, Angles, Start);
	}

	float TE_Duration = 0.05019608415;

	int color[4] = {100, 100, 100, 75};

	float 	Rng_Start = GetRandomFloat(diameter*0.3, diameter*0.5);

	float 	Start_Diameter3 = ClampBeamWidth(Rng_Start);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	TE_SetupBeamPoints(Start, End, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, Start_Diameter3*0.9, 0, 0.1, color, 3);
	Send_Te_Client_ZR(client);
	if(update)
	{
		color[3] = 25;
		TE_SetupBeamPoints(Start, End, Beam_Index, 0, 0, 66, 0.1, Start_Diameter3*1.2, Start_Diameter3*1.2, 0, 0.1, color, 3);
		TE_SendToAll();
	}	
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}