#pragma semicolon 1
#pragma newdecls required

static float Cosmic_BeamSpeed[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Base_BeamSpeed[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_DMG[MAXPLAYERS+1] = {0.0, ...};
static float CosmicActualDamage[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Radius[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_BeamLoc[MAXPLAYERS+1][3];
static float Cosmic_Terror_Hud_Delay[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Terror_Trace_Delay[MAXPLAYERS+1] = {0.0, ...};

static char gLaser1;
static int BeamWand_Laser;

#define SND_WELD_SOUND		"ambient/energy/weld1.wav"
#define COSMIC_TERROR_TE_DELAY 0.08
#define SND_CLIENT_COSMIC_TERROR_OVERHEAT_SOUND "weapons/physcannon/physcannon_charge.wav"
#define SND_CLIENT_COSMIC_TERROR_SOUND	"ambient/energy/weld1.wav"

static char gGlow1;	//blue

void Cosmic_Map_Precache()
{
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

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};
static int Cosmic_Dmg_Throttle[MAXPLAYERS+1]={0,...};
static int Cosmic_TE_Throttle[MAXPLAYERS+1]={0,...};
static int Cosmic_Heat[MAXPLAYERS+1]={0,...};
static float Cosmic_Heat_Max[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Charge_Timer[MAXPLAYERS+1];

static float Cosmic_Terror_Charge_Timer_Base[MAXPLAYERS+1];
static float fl_angle[MAXPLAYERS+1];
static bool b_use_override_angle[MAXPLAYERS+1];
static float fl_sping_speed[MAXPLAYERS+1];
static int i_effect_amount[MAXPLAYERS+1];
static int i_current_number[MAXPLAYERS+1];
static bool b_arced_number[MAXPLAYERS+1];

static int Cosmic_Terror_Pap[MAXPLAYERS+1]={0,...};
static bool Cosmic_Terror_Are_we_Cooling[MAXPLAYERS+1]={false, ...};
static bool Cosmic_Terror_Charge[MAXPLAYERS+1]={false, ...};
static bool Cosmic_Terror_Cooling_Reset[MAXPLAYERS+1]={false, ...};
static bool Cosmic_Terror_Full_Reset[MAXPLAYERS+1]={false, ...};
static bool Cosmic_Terror_On[MAXPLAYERS+1]={false, ...};
static int Cosmic_Terror_Sound_Tick[MAXPLAYERS+1]={0,...};
static float Cosmic_Terror_Sound_Charge_Timer[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Sound_Charge_Timer2[MAXPLAYERS+1]={0.0,...};
static int Cosmic_Terror_Charge_Sound_interval[MAXPLAYERS+1]={0,...};
static float Cosmic_Terror_Angle[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Last_Known_Loc[MAXPLAYERS + 1][3];
static float fl_hexagon_angle[MAXPLAYERS+1];

static int Cosmic_Terror_GiveAmmo_interval[MAXPLAYERS+1]={0,...};

public void Cosmic_Terror_Pap0(int client, int weapon, bool &result, int slot)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
	Cosmic_Heat_Max[client]=1350.0; //How much heat before we force a shutdown.
	Cosmic_Base_BeamSpeed[client] = 2.5;	//how fast the beam is
	Cosmic_Radius[client] = 100.0;	//damage radius
	Cosmic_Terror_Pap[client]=0;
	i_effect_amount[client] = 3;
	fl_sping_speed[client] = 1.5;
	float time = 4.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	//Nothing configure here.
	Cosmic_Dmg_Throttle[client]=0;
	Cosmic_TE_Throttle[client]=0;
	Cosmic_Terror_Sound_Tick[client]=0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;
}
public void Cosmic_Terror_Pap1(int client, int weapon, bool &result, int slot)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
	Cosmic_Heat_Max[client]=1750.0; //How much heat before we force a shutdown.
	Cosmic_Base_BeamSpeed[client] = 3.5;	//how fast the beam is
	Cosmic_Radius[client] = 120.0;	//damage radius
	Cosmic_Terror_Pap[client]=1;
	i_effect_amount[client] = 5;
	float time = 3.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	fl_sping_speed[client] = 1.1;
	
	//Nothing configure here.
	Cosmic_Dmg_Throttle[client]=0;
	Cosmic_TE_Throttle[client]=0;
	Cosmic_Terror_Sound_Tick[client]=0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;
}
public void Cosmic_Terror_Pap2(int client, int weapon, bool &result, int slot)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo >= 5)
	{
		Cosmic_Activate(client, weapon);
	}
	else
	{
		PrintHintText(client,"You ran out of Laser Battery!");
	}
	Cosmic_Heat_Max[client]=2500.0; //How much heat before we force a shutdown.
	Cosmic_Base_BeamSpeed[client] = 4.5;	//how fast the beam is
	Cosmic_Radius[client] = 150.0;	//damage radius

	fl_sping_speed[client] = 0.75;
	Cosmic_Terror_Pap[client]=2;
	float time = 2.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	Cosmic_Terror_Charge_Timer_Base[client] = time;
	i_effect_amount[client] = 7;
	i_current_number[client] = 0;
	b_arced_number[client] = false;
	
	//Nothing configure here.
	Cosmic_Dmg_Throttle[client]=0;
	Cosmic_TE_Throttle[client]=0;
	Cosmic_Terror_Sound_Tick[client]=0;
	Cosmic_Terror_Charge_Sound_interval[client]=0;
}
public void Cosmic_Activate(int client, int weapon)
{
	if(IsValidClient(client))
	{
		Cosmic_Terror_Angle[client]=0.0;
		if(weapon >= MaxClients)
		{
			Cosmic_DMG[client]=100.0;
			Cosmic_DMG[client] *= Attributes_Get(weapon, 1, 1.0);
			Cosmic_DMG[client] *= Attributes_Get(weapon, 2, 1.0);
			Cosmic_DMG[client] *= Attributes_Get(weapon, 476, 1.0);
			
			CosmicActualDamage[client] = Cosmic_DMG[client];
			
			Cosmic_BeamSpeed[client]=Cosmic_Base_BeamSpeed[client];
			
			if(!Cosmic_Terror_Are_we_Cooling[client])
			{
				if(!Cosmic_Terror_On[client])
				{
					Cosmic_Terror_On[client]=true;
					SDKHook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
				}
				else
				{
					SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
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
	}
}

public Action Cosmic_Activate_Tick(int client)
{
	if(IsValidClient(client))
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon) && i_CustomWeaponEquipLogic[weapon]==8)
		{
			int new_ammo = GetAmmo(client, 23);
			if(new_ammo >= 5)
			{
				if(!b_use_override_angle[client])
				{
					fl_hexagon_angle[client] += fl_sping_speed[client];
					if(fl_hexagon_angle[client]>360.0)
					{
						fl_hexagon_angle[client] = 0.0;
					}
				}
				else
				{
					fl_hexagon_angle[client] = fl_angle[client];
				}
				
				if(LastMann)
				{
					Cosmic_BeamSpeed[client]=Cosmic_Base_BeamSpeed[client]*3;
				}
				else
				{
					Cosmic_BeamSpeed[client]=Cosmic_Base_BeamSpeed[client];
				}
				if(Cosmic_Heat[client]>=Cosmic_Heat_Max[client])
				{
					Cosmic_Terror_Are_we_Cooling[client]=true;
				}
				else if(!Cosmic_Terror_Are_we_Cooling[client])
				{
					if(Handle_on[client])
					{
						KillTimer(Revert_Weapon_Back_Timer[client]);
						
						SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
					}
					Revert_Weapon_Back_Timer[client] = CreateTimer(0.5, Cosmic_Terror_Reset_Wep, client, TIMER_FLAG_NO_MAPCHANGE);
					
					Handle_on[client] = true;
					Cosmic_Terror_Charge[client]=true;
					Cosmic_Terror_Full_Reset[client]=false;
			
					if(Cosmic_Terror_Charge_Timer[client]>GetGameTime())
					{
						Cosmic_Terror_Charging(client);
						
						if(Cosmic_Terror_Sound_Charge_Timer2[client]<GetGameTime())
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
								
								CreateTimer(Cosmic_Terror_Sound_Charge_Timer[client], Cosmic_Terror_Sound, client, TIMER_FLAG_NO_MAPCHANGE);
							}
							Cosmic_Terror_Charge_Sound_interval[client]++;
							Cosmic_Terror_Sound_Charge_Timer2[client]=GetGameTime()+Cosmic_Terror_Sound_Charge_Timer[client];
						}
					}
					else
					{
						//CPrintToChatAll("heat: %i", Cosmic_Heat[client]);
						if(!LastMann)
							Cosmic_Heat[client]++;
						Cosmic_Terror_FullCharge(client);
					}
				}
			}
			else
			{
				PrintHintText(client,"You ran out of Laser Battery!");
				//SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
			}
		}
	}
	return Plugin_Continue;
}

public Action Cosmic_Heat_Tick(int client)
{
	if(IsValidClient(client))
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		Cosmic_Terror_Cooling_Reset[client]=true;
		if(Cosmic_Terror_Hud_Delay[client]<GetGameTime())
		{
			if(IsValidEntity(weapon) && i_CustomWeaponEquipLogic[weapon]==8)	//Checks if the wep is indeed cosmic terror.
			{
				int Heat = RoundToFloor((Cosmic_Heat[client]*100)/Cosmic_Heat_Max[client]);
				if(Cosmic_Terror_Are_we_Cooling[client])
				{
					PrintHintText(client,"Overheat: [%i]", Heat);
				}
				else
				{
					PrintHintText(client,"Cooling: [%i]", Heat);
				}
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				int pitch = 25+Heat;
				EmitSoundToClient(client, SND_CLIENT_COSMIC_TERROR_OVERHEAT_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.5, pitch);
			}
			Cosmic_Terror_Hud_Delay[client]=GetGameTime()+0.5;
		}
		if(Cosmic_Heat[client]<=0)
		{
			Cosmic_Heat[client]=0;
			if(IsValidEntity(weapon) && i_CustomWeaponEquipLogic[weapon]==8)	//Checks if the wep is indeed cosmic terror.
			{
				PrintHintText(client,"Fully Cooled Down", Cosmic_Heat[client]);
			}
			Cosmic_Terror_Are_we_Cooling[client]=false;
			SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
		}
		else
		{
			//CPrintToChatAll("overheat: %i", Cosmic_Heat[client]);
			if(Cosmic_Terror_Are_we_Cooling[client])	//if you overheat this thing, have fun cooling it down.
			{
				Cosmic_Heat[client]--;
			}
			else
			{
				Cosmic_Heat[client]-=2+Cosmic_Terror_Pap[client];
			}
		}
	}
	else
	{
		Cosmic_Terror_Are_we_Cooling[client]=false;
		Cosmic_Heat[client]=0;
		SDKUnhook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
	}
	return Plugin_Continue;
}
public Action Cosmic_Terror_Sound(Handle timer, int client)
{
	if(IsValidClient(client))
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
	return Plugin_Continue;
}
public Action Cosmic_Terror_Reset_Wep(Handle cut_timer, int client)
{
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	EmitSoundToClient(client,"weapons/physcannon/physcannon_drop.wav",  _, _, _, _, 0.5, 80);

	
	Cosmic_Terror_Trace_Delay[client] = 0.0;
	
	SDKHook(client, SDKHook_PreThink, Cosmic_Heat_Tick);
	Cosmic_Terror_Cooling_Reset[client]=false;
	Handle_on[client] = false;
	Cosmic_Terror_Charge[client]=false;
	Cosmic_Terror_Full_Reset[client]=true;
	Cosmic_Terror_On[client]=false;
	SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
	return Plugin_Handled;
}
void Cosmic_Terror_Charging(int client)
{
	
	b_use_override_angle[client] = true;
	float SpawnLoc[3], EyeLoc[3];
	GetClientEyePosition(client, EyeLoc);
	GetClientEyeAngles(client, SpawnLoc);

	float gametime = GetGameTime();
	
	float duration = Cosmic_Terror_Charge_Timer[client] - gametime;
	float offset = duration / Cosmic_Terror_Charge_Timer_Base[client];
	float range = Cosmic_Radius[client];
	range *= offset;
	
	if(Cosmic_Terror_Hud_Delay[client]<gametime)
	{
		PrintHintText(client,"Cosmic Terror Activating In: [%.1f]", duration);
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		Cosmic_Terror_Hud_Delay[client]=gametime+0.25;
	}
	
	if(Cosmic_Terror_Trace_Delay[client] <= gametime)
	{
		Cosmic_Terror_Trace_Delay[client] = gametime + 0.1;
		Handle trace = TR_TraceRayFilterEx(EyeLoc, SpawnLoc, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
		TR_GetEndPosition(SpawnLoc, trace);
		delete trace;
		
		int pitch = 25+100-RoundToFloor(100*(offset));
		EmitSoundToClient(client, SND_WELD_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.2, pitch);
		
		SpawnLoc[2] += 10.0;
		
		Cosmic_Terror_Last_Known_Loc[client] = SpawnLoc;
		
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
	
	if(fl_angle[client]>=360.0)
	{
		fl_angle[client] = 0.0;
	}
	fl_angle[client] += fl_sping_speed[client];
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
		spawnRing_Vector(Cosmic_Terror_Last_Known_Loc[client], range, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
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
void Cosmic_Terror_FullCharge(int client)
{
	float gametime = GetGameTime();
	fl_sping_speed[client] = 0.75;
	b_use_override_angle[client] = false;
	if(Cosmic_Terror_Full_Reset[client])
	{
		SDKUnhook(client, SDKHook_PreThink, Cosmic_Activate_Tick);
		//CPrintToChatAll("Deactivated");
	}
	int new_ammo = GetAmmo(client, 23);
	if(Cosmic_Terror_GiveAmmo_interval[client] >= 5)
	{
		if(new_ammo >= 1)
		{
			new_ammo -= 1;
			SetAmmo(client, 23, new_ammo);
			CurrentAmmo[client][23] = GetAmmo(client, 23);
			Cosmic_Terror_GiveAmmo_interval[client] = 0;
		}
	}
	Cosmic_Terror_GiveAmmo_interval[client]++;
	float SpawnLoc[3], EyeLoc[3];
	GetClientEyePosition(client, EyeLoc);
	GetClientEyeAngles(client, SpawnLoc);
	
	if(Cosmic_Terror_Trace_Delay[client] <= gametime)
	{
		Cosmic_Terror_Trace_Delay[client] = gametime + 0.33;
		Handle trace = TR_TraceRayFilterEx(EyeLoc, SpawnLoc, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
		TR_GetEndPosition(SpawnLoc, trace);
		delete trace;
		Cosmic_Terror_Last_Known_Loc[client] = SpawnLoc;
	}
		
	for(int vec = 0; vec < 3; vec++)
	{
		if(Cosmic_BeamLoc[client][vec] < Cosmic_Terror_Last_Known_Loc[client][vec])
		{
			Cosmic_BeamLoc[client][vec] += Cosmic_BeamSpeed[client];
		}
			
		if(Cosmic_BeamLoc[client][vec] > Cosmic_Terror_Last_Known_Loc[client][vec])
		{
			Cosmic_BeamLoc[client][vec] += -Cosmic_BeamSpeed[client];
		}
	}
	
	float SkyLoc[3];

	SkyLoc[0] = Cosmic_BeamLoc[client][0];
	SkyLoc[1] = Cosmic_BeamLoc[client][1];
	SkyLoc[2] = Cosmic_BeamLoc[client][2] + 1000.0;
	
	int red = 0;
	int green = 0;
	int blue = 0;
	int alpha = 75;
			
	int amount=RoundToFloor(Cosmic_Heat[client]*100/Cosmic_Heat_Max[client]*1.25); 
			
	blue = 125 - amount;
	red = 0 + amount;
	green = 125 - amount;
			
	if(Cosmic_Heat[client]>Cosmic_Heat_Max[client]/2)
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
	
	
	Cosmic_Terror_Do_Dmg(client);
	
	int Heat = RoundToFloor((Cosmic_Heat[client]*100)/Cosmic_Heat_Max[client]);
	
	float fuck[3];
	fuck = Cosmic_BeamLoc[client];
	fuck[2] += 10.0;
	TE_SetupGlowSprite(fuck, gGlow1, COSMIC_TERROR_TE_DELAY, 0.75, 101-Heat);
	TE_SendToAll();
	
	if(Cosmic_Terror_Hud_Delay[client]<gametime)
	{
		
		PrintHintText(client,"Cosmic Heat: [%i]", Heat);
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		Cosmic_Terror_Hud_Delay[client]=gametime+0.5;
	}
	
	if(Cosmic_Terror_Sound_Tick[client]>=11)
	{
		EmitSoundToAll(SND_WELD_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.15, SNDPITCH_NORMAL, -1, Cosmic_BeamLoc[client]);
		int pitch = 25+100-Heat;
		EmitSoundToClient(client, SND_CLIENT_COSMIC_TERROR_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.15, pitch);
		Cosmic_Terror_Sound_Tick[client]=0;
	}
	else
	{
		Cosmic_Terror_Sound_Tick[client]++;
	}
	if(Cosmic_Terror_Pap[client]>=1)
	{
		//Extra client side effects.
		float Client_Side_Effect_Vec[3];
		Client_Side_Effect_Vec[0]=Cosmic_BeamLoc[client][0];
		Client_Side_Effect_Vec[1]=Cosmic_BeamLoc[client][1];
		Client_Side_Effect_Vec[2]=Cosmic_BeamLoc[client][2]+10;
		
		if(Cosmic_TE_Throttle[client]>=1)
		{
			float range = Cosmic_Radius[client];
			Cosmic_TE_Throttle[client]=0;
			spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 0.75, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.075, 8.0, 0.1, 1);

			Client_Side_Effect_Vec[2]+=150;
			Cosmic_Terror_Create_Hexagon(client, Client_Side_Effect_Vec, range*0.9, colour, 5, _, 5.0, 5.0);

			
			if(Cosmic_Terror_Pap[client]>=2)
			{
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
				SkyLoc[2]-=750.0;
				Client_Side_Effect_Vec[2]=SkyLoc[2];
				int times_spin = 5;
				Cosmic_Terror_Create_Hexagon(client, Client_Side_Effect_Vec, range*1.2, colour, 7, _, 10.0, 10.0, true, true);
				spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client]*1.25, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
				for(int j=1 ; j <= times_spin ; j++)
				{
					tempAngles[1] = UserAng[1]+(360.0/times_spin)*float(j);
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, Cosmic_Radius[client]*0.66);
					AddVectors(SkyLoc, Direction, endLoc);
					Spawn_4Beams(client, endLoc, colour);
					/*TE_SetupGlowSprite(endLoc, gGlow1, COSMIC_TERROR_TE_DELAY, 0.35, 255);
					if(!LastMann)
						TE_SendToClient(client);
					else
						TE_SendToAll();*/
				}
				/*
					The fuck do we use, do we use "colour" or "color", why must these differences in english exist, REEEEEEEE.
				*/
			}
		}
		else
		{
			Cosmic_TE_Throttle[client]++;
		}
	}
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
	if(Cosmic_Dmg_Throttle[client]>10)
	{
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(CosmicActualDamage[client], client, client, -1, Cosmic_BeamLoc[client], Cosmic_Radius[client]);
		FinishLagCompensation_Base_boss();
		Cosmic_Dmg_Throttle[client]=0;
	}
	else
	{
		Cosmic_Dmg_Throttle[client]++;
	}
}