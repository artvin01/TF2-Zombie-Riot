#pragma semicolon 1
#pragma newdecls required

static float fl_cosmic_heating_timer[MAXPLAYERS];
static float Cosmic_Base_BeamSpeed[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_DMG[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Radius[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_BeamLoc[MAXPLAYERS+1][3];
static float Cosmic_Terror_Hud_Delay[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Terror_Trace_Delay[MAXPLAYERS+1] = {0.0, ...};

static int i_Railcannon_ammo[MAXPLAYERS];
static float fl_Ammo_Gain_Timer[MAXPLAYERS];
static float fl_Railcannon_recharge[MAXPLAYERS];
static float fl_recently_added_heat[MAXPLAYERS];

static char gLaser1;
static int BeamWand_Laser;

#define COSMIC_RAILGUN_PROJECTILE_MODEL "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl"

#define SND_WELD_SOUND		"ambient/energy/weld1.wav"
#define COSMIC_TERROR_TE_DELAY 0.08
#define SND_CLIENT_COSMIC_TERROR_OVERHEAT_SOUND "weapons/physcannon/physcannon_charge.wav"
#define SND_CLIENT_COSMIC_TERROR_SOUND	"ambient/energy/weld1.wav"

static char gGlow1;	//blue

void Cosmic_Map_Precache()
{
	Zero(fl_recently_added_heat);
	Zero(i_Railcannon_ammo);
	Zero(fl_Ammo_Gain_Timer);
	Zero(fl_Railcannon_recharge);
	PrecacheModel(COSMIC_RAILGUN_PROJECTILE_MODEL);
	PrecacheSound(SND_WELD_SOUND, true);
	PrecacheSound(SND_CLIENT_COSMIC_TERROR_OVERHEAT_SOUND, true);
	PrecacheSound(SND_CLIENT_COSMIC_TERROR_SOUND, true);
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt");
	Zero(Cosmic_Terror_Hud_Delay);
	Zero(Cosmic_Terror_Trace_Delay);
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
	PrecacheSound("weapons/vaccinator_charge_tier_01.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_02.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_03.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_04.wav");
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
}

static float fl_Cosmic_Dmg_Throttle[MAXPLAYERS+1]={0.0,...};
static bool b_cosmic_touchdown[MAXPLAYERS];
static float fl_Cosmic_TE_Throttle[MAXPLAYERS+1]={0.0,...};
static float fl_Cosmic_Heat[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Heat_Max[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Charge_Timer[MAXPLAYERS+1];

static float Cosmic_Terror_Charge_Timer_Base[MAXPLAYERS+1];
static float fl_angle[MAXPLAYERS+1];
static bool b_use_override_angle[MAXPLAYERS+1];
static float fl_spin_speed[MAXPLAYERS+1];
static int i_effect_amount[MAXPLAYERS+1];
static int i_current_number[MAXPLAYERS+1];
static bool b_arced_number[MAXPLAYERS+1];

static float fl_cosmic_heat_multi[MAXPLAYERS];
static int Cosmic_Terror_Pap[MAXPLAYERS+1]={0,...};
static bool b_cosmic_overheat[MAXPLAYERS+1]={false, ...};
static bool Cosmic_Terror_On[MAXPLAYERS+1]={false, ...};
static float fl_Cosmic_Terror_Sound_Timer[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Sound_Charge_Timer[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Sound_Charge_Timer2[MAXPLAYERS+1]={0.0,...};
static int Cosmic_Terror_Charge_Sound_interval[MAXPLAYERS+1]={0,...};
static float Cosmic_Terror_Angle[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Last_Known_Loc[MAXPLAYERS + 1][3];
static float fl_hexagon_angle[MAXPLAYERS+1];

public void Cosmic_Terror_Pap0(int client, int weapon, bool &result, int slot)
{
	Cosmic_Heat_Max[client]=1350.0; //How much heat before we force a shutdown.
	float speed = 25.0;	//how fast the beam is
	Cosmic_Radius[client] = 50.0;	//damage radius
	Cosmic_Terror_Pap[client]=0;
	i_effect_amount[client] = 3;
	fl_spin_speed[client] = 1.5;
	float time = 4.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	//Nothing configure here.
	fl_Cosmic_Dmg_Throttle[client]=0.0;
	fl_Cosmic_TE_Throttle[client]=0.0;
	fl_Cosmic_Terror_Sound_Timer[client]=0.0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;

	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon, speed);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
}
public void Cosmic_Terror_Pap1(int client, int weapon, bool &result, int slot)
{
	Cosmic_Heat_Max[client]=1750.0; //How much heat before we force a shutdown.
	float speed = 29.0;	//how fast the beam is
	Cosmic_Radius[client] = 75.0;	//damage radius
	Cosmic_Terror_Pap[client]=1;
	i_effect_amount[client] = 5;
	float time = 3.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	fl_spin_speed[client] = 1.11;
	
	//Nothing configure here.
	fl_Cosmic_Dmg_Throttle[client]=0.0;
	fl_Cosmic_TE_Throttle[client]=0.0;
	fl_Cosmic_Terror_Sound_Timer[client]=0.0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;

	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon, speed);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
}
public void Cosmic_Terror_Pap2(int client, int weapon, bool &result, int slot)
{
	Cosmic_Heat_Max[client]=2500.0; //How much heat before we force a shutdown.
	float speed = 32.5;	//how fast the beam is
	Cosmic_Radius[client] = 100.0;	//damage radius

	fl_spin_speed[client] = 0.75;
	Cosmic_Terror_Pap[client]=2;
	float time = 2.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	i_effect_amount[client] = 7;
	i_current_number[client] = 0;
	b_arced_number[client] = false;

	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon, speed);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
}
public void Cosmic_Activate(int client, int weapon, float speed)
{
	float heat_multi = 1.0; 

	heat_multi *= Attributes_Get(weapon, 96, 1.0);
	heat_multi *= Attributes_Get(weapon, 97, 1.0);

	fl_Cosmic_Dmg_Throttle[client]=0.0;
	fl_Cosmic_TE_Throttle[client]=0.0;
	fl_Cosmic_Terror_Sound_Timer[client]=0.0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;

	fl_cosmic_heat_multi[client] = heat_multi;

	Cosmic_Base_BeamSpeed[client] = speed;
	
	fl_cosmic_heating_timer[client] = GetGameTime() + 1.0;

	b_cosmic_touchdown[client] = false;

	Cosmic_Terror_Angle[client]=0.0;

	float dmg = 100.0;
	dmg *= Attributes_Get(weapon, 1, 1.0);
	dmg *= Attributes_Get(weapon, 2, 1.0);

	dmg *= (1.0 / Attributes_Get(weapon, 6, 1.0));

	
	Cosmic_DMG[client] = dmg;
	
	if(!b_cosmic_overheat[client])
	{
		if(!Cosmic_Terror_On[client])
		{
			float Origin[3]; GetClientEyePosition(client, Origin);
			float Angles[3]; GetClientEyeAngles(client, Angles);
			float SpawnLoc[3];
			Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
			TR_GetEndPosition(SpawnLoc, trace);
			delete trace;
			Cosmic_Terror_Last_Known_Loc[client] = SpawnLoc;
			Cosmic_Terror_Trace_Delay[client] = 0.0;

			Cosmic_Terror_On[client]=true;
			SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
			SDKHook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
		}
		else
		{
			Kill_Cosmic_Hook(client, -1);

			int new_ammo = GetAmmo(client, 23);
			new_ammo += 10*(Cosmic_Terror_Pap[client]+1);
			SetAmmo(client, 23, new_ammo);
			CurrentAmmo[client][23] = GetAmmo(client, 23);
			Cosmic_Terror_On[client]=false;
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public Action Cosmic_Activate_Tick(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_COSMIC_TERROR)
	{
		Kill_Cosmic_Hook(client, -1);
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();

	if(!b_use_override_angle[client])
	{
		fl_hexagon_angle[client] += (fl_spin_speed[client]/TickrateModify);
		if(fl_hexagon_angle[client]>360.0)
		{
			fl_hexagon_angle[client] -= 360.0;
		}
	}
	else
	{
		fl_hexagon_angle[client] = fl_angle[client];
	}

	if(Cosmic_Terror_Charge_Timer[client]<GameTime)
		Cosmic_FullCharg_Effects(client);
	else
	{
		Cosmic_Terror_Charging(client, GameTime);
		Do_charge_sounds(client, GameTime);
		
	}

	
	if(Cosmic_Terror_Trace_Delay[client] > GameTime)
		return Plugin_Continue;
	
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo <= 5)
	{
		Kill_Cosmic_Hook(client, 0);
		return Plugin_Stop;
	}

	
	float Origin[3]; GetClientEyePosition(client, Origin);
	float Angles[3]; GetClientEyeAngles(client, Angles);
	float SpawnLoc[3];
	Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	TR_GetEndPosition(SpawnLoc, trace);
	delete trace;
	Cosmic_Terror_Last_Known_Loc[client] = SpawnLoc;

	Cosmic_Terror_Trace_Delay[client] = GameTime + 0.1;

	if(Cosmic_Terror_Charge_Timer[client] > GameTime)
	{
		float duration = Cosmic_Terror_Charge_Timer[client] - GameTime;
		float offset = duration / Cosmic_Terror_Charge_Timer_Base[client];
		int pitch = 25+100-RoundToFloor(100*(offset));
		EmitSoundToClient(client, SND_WELD_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.2, pitch);
		return Plugin_Continue;
	}
	//me trying to compile:
	//the 50 things I didn't see / oversights due to old code: let us introduce ourselves.

	float Speed = Cosmic_Base_BeamSpeed[client];
	
	if(LastMann)
	{
		Speed *=3.0;
	}

	if(fl_Cosmic_Heat[client]>=Cosmic_Heat_Max[client])
	{
		b_cosmic_overheat[client]=true;	//we overheated the gun, cool it.
		Kill_Cosmic_Hook(client, 1);
		return Plugin_Stop;
	}

	
	if(!b_cosmic_touchdown[client])
	{
		Cosmic_Terror_Sound(client);
		b_cosmic_touchdown[client] = true;
	}
	
	float heating = 2.0;
	heating = heating*fl_cosmic_heat_multi[client];
	if(fl_cosmic_heating_timer[client] < GameTime)
	{
		fl_Cosmic_Heat[client]+=heating*3.0;
	}
	else
	{
		fl_Cosmic_Heat[client]+=heating;
	}

	Cosmic_Terror_FullCharge(client, Speed, GameTime);

	return Plugin_Continue;
}
static void Do_charge_sounds(int client, float GameTime)
{
	if(Cosmic_Terror_Sound_Charge_Timer2[client]<GameTime)
	{
		if(Cosmic_Terror_Charge_Sound_interval[client]==0)
		{
			ClientCommand(client, "playgamesound weapons/vaccinator_charge_tier_01.wav");
		}
		else if(Cosmic_Terror_Charge_Sound_interval[client]==1)
		{
			ClientCommand(client, "playgamesound weapons/vaccinator_charge_tier_02.wav");
		}
		else if(Cosmic_Terror_Charge_Sound_interval[client]==2)
		{
			ClientCommand(client, "playgamesound weapons/vaccinator_charge_tier_03.wav");
		}
		else if(Cosmic_Terror_Charge_Sound_interval[client]==3)
		{
			ClientCommand(client, "playgamesound weapons/vaccinator_charge_tier_04.wav");
		}
		Cosmic_Terror_Charge_Sound_interval[client]++;
		Cosmic_Terror_Sound_Charge_Timer2[client]=GameTime+Cosmic_Terror_Sound_Charge_Timer[client];
	}
}

static void Kill_Cosmic_Hook(int client, int type = -1)
{
	Cosmic_Terror_On[client]=false;
	switch(type)
	{
		case 0:
		{
			PrintHintText(client,"You ran out of Laser Battery!");
		}
		case 1:
		{
			PrintHintText(client,"Your weapon overheated!");
		}
	}
	SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
	SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
	Cosmic_Terror_Trace_Delay[client] = 0.0;
	SDKHook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
}

static Action Cosmic_Heat_Tick(int client)
{
	if(Cosmic_Terror_On[client])
	{
		SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
		return Plugin_Stop;
	}
	float GameTime = GetGameTime();
	if(Cosmic_Terror_Hud_Delay[client] > GameTime)
		return Plugin_Continue;
	
	Cosmic_Terror_Hud_Delay[client] = GameTime + 0.5;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(IsValidEntity(weapon) && i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_TERROR)	//Checks if the wep is indeed cosmic terror.
	{
		int Heat = RoundToFloor((fl_Cosmic_Heat[client]*100.0/Cosmic_Heat_Max[client]));
		if(b_cosmic_overheat[client])
		{
			PrintHintText(client,"Overheat: [%i％]", Heat);
		}
		else
		{
			PrintHintText(client,"Cooling: [%i％]", Heat);
		}
		
		int pitch = 25+Heat;
		EmitSoundToClient(client, SND_CLIENT_COSMIC_TERROR_OVERHEAT_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.5, pitch);
	}

	if(fl_Cosmic_Heat[client]<=0.0)
	{
		fl_Cosmic_Heat[client]=0.0;
		if(IsValidEntity(weapon) && i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_TERROR)	//Checks if the wep is indeed cosmic terror.
		{
			PrintHintText(client,"Fully Cooled Down");
		}
		b_cosmic_overheat[client]=false;
		SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
		return Plugin_Stop;
	}
	else
	{
		//CPrintToChatAll("overheat: %i", fl_Cosmic_Heat[client]);
		if(b_cosmic_overheat[client])	//if you overheat this thing, have fun cooling it down.
		{
			fl_Cosmic_Heat[client]-=20.0;
		}
		else
		{
			fl_Cosmic_Heat[client]-=35.0+(Cosmic_Terror_Pap[client]*18.0);
		}
	}
	return Plugin_Continue;
}
static void Cosmic_Terror_Sound(int client)
{					
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.5, 80);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.5, 80);			
		}
		case 2:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.5, 80);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.5, 80);
		}
		case 3:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.5, 80);	
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.5, 80);			
		}
		case 4:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.5, 80);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.5, 80);
		}	
	}		
}
static void Cosmic_Terror_Charging(int client, float gametime)
{
	fl_cosmic_heating_timer[client] = gametime + 1.0;
	b_use_override_angle[client] = true;
	
	float duration = Cosmic_Terror_Charge_Timer[client] - gametime;
	float offset = duration / Cosmic_Terror_Charge_Timer_Base[client];
	float range = Cosmic_Radius[client];
	range *= offset;
	
	if(Cosmic_Terror_Hud_Delay[client]<gametime)
	{
		PrintHintText(client,"Cosmic Terror Activating In: [%.1f]", duration);
		
		Cosmic_Terror_Hud_Delay[client]=gametime+0.5;
	}
	
	
	Cosmic_BeamLoc[client] = Cosmic_Terror_Last_Known_Loc[client];
	
	int red=3, green=4, blue=94, alpha=150;
	int colour[4];
	colour[0] = red;
	colour[1] = green;
	colour[2] = blue;
	colour[3] = alpha;
	
	float target_vec[3];
	target_vec=Cosmic_BeamLoc[client];
	int amount = i_effect_amount[client];
	
	target_vec[2]+=10.0;

	if(fl_angle[client]>=360.0)
	{
		fl_angle[client] = 0.0;
	}
	fl_angle[client] += fl_spin_speed[client]/TickrateModify;
	float EndLoc[3];
	
	for (int j = 0; j < amount; j++)
	{
		float tempAngles[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = fl_angle[client] + (float(j) * (360.0/amount));
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, range);
		AddVectors(target_vec, Direction, EndLoc);
		
		float sky_loc[3]; sky_loc = EndLoc; sky_loc[2] += 5000.0;
		
		TE_SetupGlowSprite(EndLoc, gGlow1, COSMIC_TERROR_TE_DELAY, 0.35, 255);
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
					
		//spawnRing_Vectors(EndLoc, range/10.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, BLITKZIREG_TE_THING_DELAY, 2.0, 1.25, 1);
		
		TE_SetupBeamPoints(sky_loc, EndLoc, gLaser1, 0, 0, 0, COSMIC_TERROR_TE_DELAY, 0.25, 0.5, 0, 0.25, colour, 0);
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
	}
	if(Cosmic_Terror_Pap[client]>=2)
	{
		Cosmic_Terror_Create_Hexagon(client, target_vec, range, colour, amount, true, 3.0, 3.0);
	}
	else
	{
		spawnRing_Vector(Cosmic_Terror_Last_Known_Loc[client], range, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
	}
	
}

static void Cosmic_Terror_Create_Hexagon(int client, float target_vec[3], float range, int colour[4], int amount, bool show_all = false, float start_size, float end_size, bool invert = false, bool arc=false)
{
	float ang_multi = 1.0;
	if(invert)
	{
		ang_multi = -1.0;
	}
	int funny = GetRandomInt(0, amount);
	for (int j = 0; j < amount; j++)
	{
		float offset = (360.0/amount) * float(j);
		float vec_temp[4][3];
		for(int i=1 ; i<=3 ; i++)
		{
			float tempAngles[3], Direction[3], EndLoc[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = ang_multi*(fl_hexagon_angle[client]+float(i) * ((360.0/amount)*3)+offset);
			tempAngles[2] = 0.0;
					
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, range);
			AddVectors(target_vec, Direction, EndLoc);
			vec_temp[i] = EndLoc;
		}
		if(arc && !b_arced_number[client] && (funny==j))	//help
		{
			b_arced_number[client] = true;
			for(int b=1 ; b<= 1 ;  b++)
			{
				TE_SetupBeamPoints(vec_temp[b], Cosmic_BeamLoc[client], BeamWand_Laser, 0, 0, 0, COSMIC_TERROR_TE_DELAY, 30.0, 15.0, 1, 2.5, colour, 0);
				if(!LastMann)
					TE_SendToClient(client);
				else
					TE_SendToAll();
			}
		}		
		if(!show_all && !LastMann)
		{
			TE_SetupBeamPoints(vec_temp[1], vec_temp[2], BeamWand_Laser, 0, 0, 0, COSMIC_TERROR_TE_DELAY, start_size, end_size, 0, 0.25, colour, 0);
			TE_SendToClient(client);
			TE_SetupBeamPoints(vec_temp[1], vec_temp[3], BeamWand_Laser, 0, 0, 0, COSMIC_TERROR_TE_DELAY, start_size, end_size, 0, 0.25, colour, 0);
			TE_SendToClient(client);
			//TE_SetupGlowSprite(vec_temp[1], gGlow1, COSMIC_TERROR_TE_DELAY, 0.35, 255);
			//TE_SendToClient(client);
		}
		else
		{
			TE_SetupBeamPoints(vec_temp[1], vec_temp[2], BeamWand_Laser, 0, 0, 0, COSMIC_TERROR_TE_DELAY, start_size, end_size, 0, 0.25, colour, 0);
			TE_SendToAll();
			TE_SetupBeamPoints(vec_temp[1], vec_temp[3], BeamWand_Laser, 0, 0, 0, COSMIC_TERROR_TE_DELAY, start_size, end_size, 0, 0.25, colour, 0);
			TE_SendToAll();
			//TE_SetupGlowSprite(vec_temp[1], gGlow1, COSMIC_TERROR_TE_DELAY, 0.35, 255);
			//TE_SendToAll();
		}
	}
	if(arc)
	{
		b_arced_number[client] = false;
		i_current_number[client]++;
	}
}
static void Cosmic_FullCharg_Effects(int client)
{
	fl_spin_speed[client] = 0.7;

	b_use_override_angle[client] = false;

	float SkyLoc[3];

	SkyLoc[0] = Cosmic_BeamLoc[client][0];
	SkyLoc[1] = Cosmic_BeamLoc[client][1];
	SkyLoc[2] = Cosmic_BeamLoc[client][2] + 1000.0;
	
	int red = 0;
	int green = 0;
	int blue = 0;
	int alpha = 75;
			
	int amount=RoundToFloor(fl_Cosmic_Heat[client]*100.0/Cosmic_Heat_Max[client]*1.25); 
			
	blue = 125 - amount;
	red = 0 + amount;
	green = 125 - amount;
			
	if(fl_Cosmic_Heat[client]>Cosmic_Heat_Max[client]/2.0)
	{
		alpha =125-amount;
	}
		
			
	if(red > 255)
		red = 255;
			
	if(blue > 255)
		blue = 255;
				
	if(red < 0)
		red = 0;
				
	if(blue < 0)
		blue = 0;
				
	if(alpha < 0)
		alpha = 0;
				
	if(green < 0)
		green=0;
		
	int colour[4];
	colour[0]=red;
	colour[1]=green;
	colour[2]=blue;
	colour[3]=alpha;
	
	TE_SetupBeamPoints(Cosmic_BeamLoc[client], SkyLoc, BeamWand_Laser, 0, 0, 0, 0.1, 45.0, 45.0, 0, 2.5, colour, 1);
	TE_SendToAll();
	
	int Heat = RoundToFloor((fl_Cosmic_Heat[client]*100/Cosmic_Heat_Max[client]));
	
	float fuck[3];
	fuck = Cosmic_BeamLoc[client];
	fuck[2] += 10.0;
	TE_SetupGlowSprite(fuck, gGlow1, COSMIC_TERROR_TE_DELAY, 0.75, 101-Heat);
	TE_SendToAll();
	
	
	if(Cosmic_Terror_Pap[client]<1)
		return;

	//Extra client side effects.
	float Client_Side_Effect_Vec[3];
	Client_Side_Effect_Vec[0]=Cosmic_BeamLoc[client][0];
	Client_Side_Effect_Vec[1]=Cosmic_BeamLoc[client][1];
	Client_Side_Effect_Vec[2]=Cosmic_BeamLoc[client][2]+10;
	

	float range = Cosmic_Radius[client];

	spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.075, 8.0, 0.1, 1);

	Client_Side_Effect_Vec[2]+=150.0;
	Cosmic_Terror_Create_Hexagon(client, Client_Side_Effect_Vec, range*1.9, colour, 5, _, 5.0, 5.0);

	
	if(Cosmic_Terror_Pap[client]< 2)
		return;

	float UserAng[3];
	
	UserAng[0] = 0.0;
	UserAng[1] = Cosmic_Terror_Angle[client];
	UserAng[2] = 0.0;
	
	float tempAngles[3], endLoc[3], Direction[3];
	tempAngles[1] = UserAng[1];
	
	Cosmic_Terror_Angle[client] += 1.25;
	
	if (Cosmic_Terror_Angle[client] >= 360.0)
	{
		Cosmic_Terror_Angle[client] = 0.0;
	}
	SkyLoc[2]-=700.0;
	Client_Side_Effect_Vec[2]=SkyLoc[2];
	int times_spin = 5;
	Cosmic_Terror_Create_Hexagon(client, Client_Side_Effect_Vec, range*2.2, colour, 7, _, 10.0, 10.0, true, true);
	spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client]*1.25, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
	for(int j=1 ; j <= times_spin ; j++)
	{
		tempAngles[1] = UserAng[1]+(360.0/times_spin)*float(j);
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Cosmic_Radius[client]*0.66);
		AddVectors(SkyLoc, Direction, endLoc);
		Spawn_4Beams(client, endLoc, colour);
	}
	
}
static void Cosmic_Terror_FullCharge(int client, float speed, float gametime)
{

	int new_ammo = GetAmmo(client, 23);

	if(new_ammo >= 2)
	{
		new_ammo -= 2;
		SetAmmo(client, 23, new_ammo);
		CurrentAmmo[client][23] = GetAmmo(client, 23);
	}

	float SpawnLoc[3], EyeLoc[3];
	GetClientEyePosition(client, EyeLoc);
	GetClientEyeAngles(client, SpawnLoc);
	

	float Target_Vec[3], Vec_Current[3];
	Target_Vec	= Cosmic_Terror_Last_Known_Loc[client];
	Vec_Current	= Cosmic_BeamLoc[client];

	bool moving = false;
		
	for(int vec = 0; vec < 3; vec++)
	{
		float Dist = FloatAbs(Vec_Current[vec]-Target_Vec[vec]);

		float Buffer_Speed = speed;

		if(Dist < speed)
		{
			if(Dist < speed*0.5)
			{
				continue;
			}
			Buffer_Speed *= (Dist/speed);
		}
		else
		{
			moving = true;
		}

		if(Vec_Current[vec] < Target_Vec[vec])
		{
			Vec_Current[vec] += Buffer_Speed;
		}
		if(Vec_Current[vec] > Target_Vec[vec])
		{
			Vec_Current[vec] += -Buffer_Speed;
		}
	}

	if(moving)
	{
		fl_cosmic_heating_timer[client] += 0.2;

		if(fl_cosmic_heating_timer[client] > gametime + 0.5)
			fl_cosmic_heating_timer[client] = gametime + 0.5;
	}
	else
	{
		if(fl_cosmic_heating_timer[client] < gametime - 10.0 )
			fl_cosmic_heating_timer[client] = gametime - 10.0;	//a limit of 10 seconds of overheating still lens.
	}

	Cosmic_BeamLoc[client] = Vec_Current;

	Cosmic_Terror_Do_Dmg(client);
	
	int Heat = RoundToFloor((fl_Cosmic_Heat[client]*100/Cosmic_Heat_Max[client]));

	if(Cosmic_Terror_Hud_Delay[client]<gametime)
	{
		if(fl_cosmic_heating_timer[client] > gametime || LastMann)
		{
			PrintHintText(client,"Cosmic Heat: [%i％]", Heat);
		}
		else
		{
			PrintHintText(client,"Cosmic Heat: [%i％]\nLens Overheating, move the beam.", Heat);
		}
		
		
		Cosmic_Terror_Hud_Delay[client]=gametime+0.5;
	}

	EmitSoundToAll(SND_WELD_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.15, SNDPITCH_NORMAL, -1, Cosmic_BeamLoc[client]);
	int pitch = 25+100-Heat;
	EmitSoundToClient(client, SND_CLIENT_COSMIC_TERROR_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.15, pitch);
}

void Spawn_4Beams(int client, float endLoc[3], int colour[4])
{
	TE_SetupBeamPoints(Cosmic_BeamLoc[client], endLoc, BeamWand_Laser, 0, 0, 0, 0.1, 12.5, 12.5, 0, 1.0, colour, 1);
	TE_SendToClient(client);	
}

static void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}

static void spawnRing_Vector_Client(int client, float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	if(!LastMann)
		TE_SendToClient(client);
	else
		TE_SendToAll();
}
public void Cosmic_Terror_Do_Dmg(int client)
{
	if(fl_Cosmic_Dmg_Throttle[client] < GetGameTime())
	{
		float dmg = Cosmic_DMG[client];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(dmg, client, client, -1, Cosmic_BeamLoc[client], Cosmic_Radius[client], _,_,_, 4);
		FinishLagCompensation_Base_boss();
		fl_Cosmic_Dmg_Throttle[client] = GetGameTime()+0.1;
	}
}

static Handle h_Cosmic_Weapons_Managment[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXPLAYERS+1];

//Railgun

#define RAILCANNON_MAX_AMMO 3

static bool b_Railgun_Charging[MAXPLAYERS];
static float fl_railgun_chargetime[MAXPLAYERS];
static float fl_Railgun_charge[MAXPLAYERS];
#define RAILGUN_INNACURACY_RANGE 250.0

//Pillars

public void Activate_Cosmic_Weapons(int client, int weapon)
{
	if (h_Cosmic_Weapons_Managment[client] != null)
	{
		//This timer already exists.
		if(IsCosmic(weapon, client))
		{
			//Is the weapon it again?
			//Yes?
			delete h_Cosmic_Weapons_Managment[client];
			h_Cosmic_Weapons_Managment[client] = null;
			DataPack pack;
			h_Cosmic_Weapons_Managment[client] = CreateDataTimer(0.1, Timer_Cosmic_Managment, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			fl_hud_timer[client]=0.0;
		}
		return;
	}
	
	if(IsCosmic(weapon, client))
	{
		DataPack pack;
		h_Cosmic_Weapons_Managment[client] = CreateDataTimer(0.1, Timer_Cosmic_Managment, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		fl_Cosmic_Heat[client] = 0.0;
		fl_hud_timer[client]=0.0;
	}
}
static bool IsCosmic(int weapon, int client)
{
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_PILLAR)
	{
		int pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		if(pap==1)
		{
			Cosmic_Heat_Max[client] = 500.0;
		}
		else if(pap==2)
		{
			Cosmic_Heat_Max[client] = 1000.0;
		}
		Cosmic_Terror_Pap[client] = pap;
		return true;
	}
	else if(i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_RAILCANNON)
	{
		Kill_Railgun(client);
		int pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		if(pap==1)
		{
			Cosmic_Heat_Max[client] = 100.0;
			fl_railgun_chargetime[client] = 7.5;
		}
		else if(pap==2)
		{
			Cosmic_Heat_Max[client] = 200.0;
			fl_railgun_chargetime[client] = 4.5;
		}
		Cosmic_Terror_Pap[client] = pap;
		return true;
	}
	else
	{
		return false;
	}
}

static Action Timer_Cosmic_Managment(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_Cosmic_Weapons_Managment[client] = null;
		return Plugin_Stop;
	}
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_COSMIC_PILLAR:
			{
				//Pillar_Logic(client, weapon);
			}
			case WEAPON_COSMIC_RAILCANNON:
			{
				Railcannon_Logic(client, weapon);
			}
			default:
			{
				CPrintToChatAll("cosmic hud fuckup, scream");
				h_Cosmic_Weapons_Managment[client] = null;
				return Plugin_Stop;
			}
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_PILLAR)
		{
			//Kill_Pillars(client);
		}
		else if(i_CustomWeaponEquipLogic[weapon]==WEAPON_COSMIC_RAILCANNON)
		{
			Kill_Railgun(client);
		}
	}

	return Plugin_Continue;
}
/*
static void Kill_Pillars(int client)
{

}
*/
static void Kill_Railgun(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Railgun_Think);
	b_Railgun_Charging[client]=false;
}

static float fl_innacuracy_angles[MAXPLAYERS];
static float fl_accuracy_multi[MAXPLAYERS];
static float fl_accuracy_switch_speed[MAXPLAYERS];
public void Cosmic_Terror_Railgun(int client, int weapon, bool &result, int slot)
{
	if(b_Railgun_Charging[client])
	{	
		Kill_Railgun(client);
		Railgun_Fire(client);
	}
	else
	{
		float GameTime = GetGameTime();


		fl_accuracy_multi[client] = GetRandomFloat(-1.0, 1.0);

		fl_accuracy_switch_speed[client] = GameTime + 0.25;

		fl_innacuracy_angles[client] = GetRandomFloat(0.0, 360.0);
		Cosmic_Terror_Trace_Delay[client] = 0.0;
		b_Railgun_Charging[client]=true;
		fl_Railgun_charge[client] = GameTime;
		SDKHook(client, SDKHook_PreThink, Railgun_Think);
	}
}

static void Railgun_Fire(int client)
{
	float Loc[3];
	Do_Cosmic_Trace(client, Loc);

	float GameTime = GetGameTime();

	float Ratio = 1.0-(GameTime - fl_Railgun_charge[client])/fl_railgun_chargetime[client];

	int color[4] = {0, 150, 255, 150};

	float Sky_Loc[3];
	Sky_Loc = Loc;
	Sky_Loc[2]+=GetRandomFloat(750.0,1500.0);
	Sky_Loc[0]+=GetRandomFloat(-150.0,150.0);
	Sky_Loc[1]+=GetRandomFloat(-150.0,150.0);

	float Time = 1.0;
	float Thicc1 = 50.0;
	float Thicc2 = 75.0;

	fl_Cosmic_Heat[client] += 25.0;

	fl_recently_added_heat[client] = GetGameTime() + 2.5;

	if(Ratio > 0.0)
	{
		float Accuracy_Angles[3];
		Accuracy_Angles[0] = 0.0;
		Accuracy_Angles[1] = fl_innacuracy_angles[client];
		Accuracy_Angles[2] = 0.0;
		Get_Fake_Forward_Vec(RAILGUN_INNACURACY_RANGE*Ratio, Accuracy_Angles, Loc, Loc);

		TE_SetupBeamPoints(Loc, Sky_Loc, BeamWand_Laser, 0, 0, 0, Time, Thicc1, Thicc2, 0, 1.0, color, 1);
		TE_SendToAll();	
	}
	else
	{
		TE_SetupBeamPoints(Loc, Sky_Loc, BeamWand_Laser, 0, 0, 0, Time, Thicc1, Thicc2, 0, 1.0, color, 1);
		TE_SendToAll();	
		TE_SetupGlowSprite(Loc, gGlow1, Time, 0.75, 75);
		TE_SendToClient(client);
	}

	float ang_Look[3];
	MakeVectorFromPoints(Sky_Loc, Loc, ang_Look);
	GetVectorAngles(ang_Look, ang_Look);

	float dist = GetVectorDistance(Sky_Loc, Loc);

	float Travel_Time = 0.75;

	float speed = dist/Travel_Time;

	float damage = 1000.0;

	float Radius = 75.0;



	int projectile = Wand_Projectile_Spawn(client, speed, Travel_Time+1.0, damage, 0, -1, "", ang_Look, false , Sky_Loc);

	int ModelApply = ApplyCustomModelToWandProjectile(projectile, COSMIC_RAILGUN_PROJECTILE_MODEL, 4.0, "");

	b_ProjectileCollideIgnoreWorld[projectile] = true;
	SetEntityMoveType(projectile, MOVETYPE_NOCLIP);

	Handle data;
	CreateDataTimer(Travel_Time, Railgun_Explosion, data, TIMER_FLAG_NO_MAPCHANGE);	//a basic ion timer
	WritePackFloat(data, Loc[0]);
	WritePackFloat(data, Loc[1]);
	WritePackFloat(data, Loc[2]);
	WritePackFloat(data, Radius);
	WritePackFloat(data, damage);
	WritePackCell(data, EntIndexToEntRef(client));
	WritePackCell(data, EntIndexToEntRef(projectile));

	float angles[3];
	GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
	angles[1]+=180.0;
	TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
}

static Action Railgun_Explosion(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Radius = ReadPackFloat(data);
	float dmg = ReadPackFloat(data);

	int client = EntRefToEntIndex(ReadPackCell(data));
	int projectile = EntRefToEntIndex(ReadPackCell(data));

	Explode_Logic_Custom(dmg, client, client, -1, startPosition, Radius);

	RemoveEntity(projectile);

	return Plugin_Stop;

}

static Action Railgun_Think(int client)
{
	float GameTime = GetGameTime();

	float Ratio = 1.0-(GameTime - fl_Railgun_charge[client])/fl_railgun_chargetime[client];

	float Extra_Visual_Range = 75.0;

	float Loc[3];

	if(Cosmic_Terror_Trace_Delay[client] < GameTime)
	{
		Cosmic_Terror_Trace_Delay[client] = GameTime + 0.1;
		Do_Cosmic_Trace(client, Loc);
		Cosmic_Terror_Last_Known_Loc[client] = Loc;
	}
	else
	{
		Loc = Cosmic_Terror_Last_Known_Loc[client];
	}

	Cosmic_Terror_Angle[client] += 1.25;
				
	if (Cosmic_Terror_Angle[client] >= 360.0)
	{
		Cosmic_Terror_Angle[client] = 0.0;
	}

	float Angles = Cosmic_Terror_Angle[client];

	Loc[2]+=2.0;

	int color[4] = {0, 150, 255, 150};
	float thicc = 3.0;
	if(Ratio > 0.0)
	{

		float Range = Extra_Visual_Range;

		fl_innacuracy_angles[client] += (3.5*Ratio)*fl_accuracy_multi[client];

		if(fl_innacuracy_angles[client]>360.0)
			fl_innacuracy_angles[client]=0.0;
		if(fl_innacuracy_angles[client]<0.0)
			fl_innacuracy_angles[client]=360.0;

		float Accuracy_Angles[3], Location[3];
		Accuracy_Angles[0] = 0.0;
		Accuracy_Angles[1] = fl_innacuracy_angles[client];
		Accuracy_Angles[2] = 0.0;
		Get_Fake_Forward_Vec(RAILGUN_INNACURACY_RANGE*Ratio, Accuracy_Angles, Location, Loc);

		TE_SetupBeamRingPoint(Location, Range*2.0, Range*2.0+1.0, gLaser1, gLaser1, 0, 1, COSMIC_TERROR_TE_DELAY, thicc, 0.1, color, 1, 0);
		TE_SendToAll();

		int Spam_Amt = 3;

		for(int i=0 ; i < Spam_Amt ; i++)
		{
			float tempAngles[3], EndLoc[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = Angles + (360.0/Spam_Amt)*i;
			tempAngles[2] = 0.0;

			Get_Fake_Forward_Vec(Range, tempAngles, EndLoc, Location);

			TE_SetupGlowSprite(EndLoc, gGlow1, COSMIC_TERROR_TE_DELAY, 0.5, 50);
			TE_SendToClient(client);
		}
	}
	else
	{
		float Range = Extra_Visual_Range;

		TE_SetupBeamRingPoint(Loc, Range*2.0, Range*2.0+1.0, gLaser1, gLaser1, 0, 1, COSMIC_TERROR_TE_DELAY, thicc, 0.1, color, 1, 0);
		TE_SendToAll();

		int Spam_Amt = 3;

		for(int i=0 ; i < Spam_Amt ; i++)
		{
			float tempAngles[3], EndLoc[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = Angles + (360.0/Spam_Amt)*i;
			tempAngles[2] = 0.0;

			Get_Fake_Forward_Vec(Range, tempAngles, EndLoc, Loc);

			TE_SetupGlowSprite(EndLoc, gGlow1, COSMIC_TERROR_TE_DELAY, 0.5, 50);
			TE_SendToClient(client);
		}
	}

	return Plugin_Continue;
}

static void Do_Cosmic_Trace(int client, float EndLoc[3])
{
	float SpawnLoc[3], EyeLoc[3];
	GetClientEyePosition(client, EyeLoc);
	GetClientEyeAngles(client, SpawnLoc);

	Handle trace = TR_TraceRayFilterEx(EyeLoc, SpawnLoc, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	TR_GetEndPosition(EndLoc, trace);
	delete trace;
}

static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

public void Cosmic_Terror_RailCannon(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();

	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		return;
	}

	if(i_Railcannon_ammo[client]>0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 10.0);

		fl_Railcannon_recharge[client] = GameTime+10.0;

		CPrintToChatAll("railgun pew");

		i_Railcannon_ammo[client]--;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}

static void Railcannon_Logic(int client, int weapon)
{
	float GameTime = GetGameTime();

	if(fl_accuracy_switch_speed[client] < GameTime)
	{
		fl_accuracy_switch_speed[client] = GameTime + GetRandomFloat(0.25, 0.5);
		fl_accuracy_multi[client] = GetRandomFloat(-1.0, 1.0);
	}

	if(fl_hud_timer[client] < GameTime)
	{
		fl_hud_timer[client] = GameTime+0.5;

		float Heat = fl_Cosmic_Heat[client]*100/Cosmic_Heat_Max[client];

		char HUDText[255] = "";
		if(!b_Railgun_Charging[client])
		{
			Format(HUDText, sizeof(HUDText), "Railgun Offline | Heat: Ę%.0f％%Ė", Heat);
		}
		else
		{
			float Ratio = 100.0*(GameTime - fl_Railgun_charge[client])/fl_railgun_chargetime[client];
			if(Ratio<=0.0)
				Ratio=0.0;

			if(Ratio>100.0)
				Ratio = 100.0;

			Format(HUDText, sizeof(HUDText), "Railgun Accuracy [%.0f％] | Heat: Ę%.0f％Ė", Ratio, Heat);
			
		}

		if(Cosmic_Terror_Pap[client]>1)
		{
			float Ratio = 100.0 - 100.0*((fl_Railcannon_recharge[client] - GameTime)/10.0); 
			if(Ratio>100.0)
				Ratio=100.0;
			Format(HUDText, sizeof(HUDText), "%s\nRailCannon | Power: Ą%.0f％Č", HUDText, Ratio);
			Show_Railcannon_Ammo(client, HUDText);

			if(fl_Ammo_Gain_Timer[client] < GameTime)
			{	
				if(i_Railcannon_ammo[client]<RAILCANNON_MAX_AMMO)
				{
					float firerate_bonus = 1.0;
					firerate_bonus *=Attributes_Get(weapon, 6, 1.0);
					firerate_bonus *=Attributes_Get(weapon, 5, 1.0);
					fl_Ammo_Gain_Timer[client] = GameTime + 90.0*firerate_bonus;
					i_Railcannon_ammo[client]++;
				}
			}
		}
		Format_Fancy_Hud(HUDText);
		PrintHintText(client, HUDText);
		
	}

	if(fl_recently_added_heat[client] < GameTime)
	{
		
		if(!b_Railgun_Charging[client])
		{
			fl_recently_added_heat[client] = GameTime + 0.1;
		}
		else
		{
			fl_recently_added_heat[client] = GameTime + 0.5;
		}

		if(fl_Cosmic_Heat[client]>0.0)
			fl_Cosmic_Heat[client] -=1.0;
	}
}
static void Format_Fancy_Hud(char Text[255])
{
	ReplaceString(Text, 128, "Ą", "「");
	ReplaceString(Text, 128, "Č", "」");
	ReplaceString(Text, 128, "Ę", "【");
	ReplaceString(Text, 128, "Ė", "】");
}
static void Show_Railcannon_Ammo(int client, char HUDText[255])
{
	
	int ammo = i_Railcannon_ammo[client];


	char Bullet = '|';

	Format(HUDText, sizeof(HUDText), "%s\n[", HUDText);

	for(int i =1 ; i <= ammo ; i++)
	{
		Format(HUDText, sizeof(HUDText), "%s {%s}", HUDText, Bullet);
	}

	Format(HUDText, sizeof(HUDText), "%s ]", HUDText);
	
}

public void Cosmic_Terror_Pillars(int client, int weapon, bool &result, int slot)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
	
	}
}

/*
static void Pillar_Logic(int client, int weapon)
{
	float GameTime = GetGameTime();
}
*/