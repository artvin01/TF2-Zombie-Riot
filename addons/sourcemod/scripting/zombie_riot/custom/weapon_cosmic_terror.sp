#pragma semicolon 1
#pragma newdecls required

static float Cosmic_BeamSpeed[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Base_BeamSpeed[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_DMG[MAXPLAYERS+1] = {0.0, ...};
static float CosmicActualDamage[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_Radius[MAXPLAYERS+1] = {0.0, ...};
static float Cosmic_BeamLoc[MAXPLAYERS+1][3];
static float Cosmic_Terror_Hud_Delay[MAXPLAYERS+1] = {0.0, ...};

static char gLaser1;

#define SND_WELD_SOUND		"ambient/energy/weld1.wav"

void Cosmic_Map_Precache()
{
	PrecacheSound(SND_WELD_SOUND);
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt");
	Zero(Cosmic_Terror_Hud_Delay);
	PrecacheSound("weapons/vaccinator_charge_tier_01.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_02.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_03.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_04.wav");
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
}

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};
static int Cosmic_Dmg_Throttle[MAXPLAYERS+1]={0,...};
static int Cosmic_TE_Throttle[MAXPLAYERS+1]={0,...};
static int Cosmic_Heat[MAXPLAYERS+1]={0,...};
static float Cosmic_Heat_Max[MAXPLAYERS+1]={0.0,...};
static float Cosmic_Terror_Charge_Timer[MAXPLAYERS+1];
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
	float time = 4.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	
	//Noting configure here.
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
	float time = 3.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	
	//Noting configure here.
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

	Cosmic_Terror_Pap[client]=2;
	float time = 2.0;
	Cosmic_Terror_Charge_Timer[client]=GetGameTime()+time;	//Charge time for the beam.
	Cosmic_Terror_Sound_Charge_Timer[client]=time/4.0;
	
	//Noting configure here.
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
			Address address = TF2Attrib_GetByDefIndex(weapon, 1);
			if(address != Address_Null)
				Cosmic_DMG[client] *= TF2Attrib_GetValue(address);
					
			address = TF2Attrib_GetByDefIndex(weapon, 2);
			if(address != Address_Null)
				Cosmic_DMG[client] *= TF2Attrib_GetValue(address);
			
			address = TF2Attrib_GetByDefIndex(weapon, 476);
			if(address != Address_Null)
				Cosmic_DMG[client] *= TF2Attrib_GetValue(address);
			
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
	EmitSoundToClient(client,"weapons/physcannon/energy_sing_loop4.wav",_, SNDCHAN_STATIC, 100, _, 0.175, 30);
	if(Cosmic_Terror_Pap[client]>=1)
	{
		EmitSoundToClient(client,"weapons/physcannon/energy_sing_loop4.wav",_, SNDCHAN_STATIC, 100, _, 0.175, 60);
	}
	if(Cosmic_Terror_Pap[client]>=2)
	{
		EmitSoundToClient(client,"weapons/physcannon/energy_sing_loop4.wav",_, SNDCHAN_STATIC, 100, _, 0.175, 90);
	}
								
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.5, 60);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.5, 60);			
		}
		case 2:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.5, 60);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.5, 60);
		}
		case 3:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.5, 60);	
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.5, 60);			
		}
		case 4:
		{
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.5, 60);
			EmitSoundToClient(client,"weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.5, 60);
		}		
	}
	return Plugin_Continue;
}
public Action Cosmic_Terror_Reset_Wep(Handle cut_timer, int client)
{
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToClient(client,"weapons/physcannon/physcannon_drop.wav",  _, _, _, _, 0.5, 60);
	
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
	float SpawnLoc[3], EyeLoc[3];
	GetClientEyePosition(client, EyeLoc);
	GetClientEyeAngles(client, SpawnLoc);
	
	//Cosmic_Radius[client]= 120.0;
	Handle trace = TR_TraceRayFilterEx(EyeLoc, SpawnLoc, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	TR_GetEndPosition(SpawnLoc, trace);
	CloseHandle(trace);
	
	for (int vec = 0; vec < 3; vec++)
	{
		Cosmic_BeamLoc[client][vec] = SpawnLoc[vec];
	}
	
	int red=3, green=4, blue=94, alpha=150;
	SpawnLoc[2]+=10;
	spawnRing_Vector(SpawnLoc, Cosmic_Radius[client] * 1.25, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
}
void Cosmic_Terror_FullCharge(int client)
{
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
	
	Handle trace = TR_TraceRayFilterEx(EyeLoc, SpawnLoc, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	TR_GetEndPosition(SpawnLoc, trace);
	CloseHandle(trace);
		
	for(int vec = 0; vec < 3; vec++)
	{
		if(Cosmic_BeamLoc[client][vec] < SpawnLoc[vec])
		{
			Cosmic_BeamLoc[client][vec] += Cosmic_BeamSpeed[client];
		}
			
		if(Cosmic_BeamLoc[client][vec] > SpawnLoc[vec])
		{
			Cosmic_BeamLoc[client][vec] += -Cosmic_BeamSpeed[client];
		}
	}
	float SkyLoc[3];

	SkyLoc[0] = Cosmic_BeamLoc[client][0];
	SkyLoc[1] = Cosmic_BeamLoc[client][1];
	SkyLoc[2] = Cosmic_BeamLoc[client][2] + 5000.0;
	
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
	
	TE_SetupBeamPoints(Cosmic_BeamLoc[client], SkyLoc, gLaser1, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
	TE_SendToAll();
	
	Cosmic_Terror_Do_Dmg(client);
	
	if(Cosmic_Terror_Sound_Tick[client]>=20)
	{
		EmitSoundToAll(SND_WELD_SOUND, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.15, SNDPITCH_NORMAL, -1, Cosmic_BeamLoc[client]);
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
			Cosmic_TE_Throttle[client]=0;
			spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.075, 8.0, 0.1, 1);
			
			Client_Side_Effect_Vec[2]+=150;
			spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 3.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.075, 8.0, 0.1, 1);
			
			Client_Side_Effect_Vec[2]+=150;
			spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 4.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.075, 8.0, 0.1, 1);
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
				SkyLoc[2]-=4500.0;
				Client_Side_Effect_Vec[2]=SkyLoc[2];
				spawnRing_Vector_Client(client, Client_Side_Effect_Vec, Cosmic_Radius[client] * 3.35, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 8.0, 0.1, 1);
				
				for(int j=1 ; j <= 4 ; j++)
				{
					tempAngles[1] = UserAng[1]+90*float(j);
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, Cosmic_Radius[client]*1.666);
					AddVectors(SkyLoc, Direction, endLoc);
					Spawn_4Beams(client, endLoc, colour);
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
	TE_SetupBeamPoints(Cosmic_BeamLoc[client], endLoc, gLaser1, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
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
	TE_SendToClient(client);
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