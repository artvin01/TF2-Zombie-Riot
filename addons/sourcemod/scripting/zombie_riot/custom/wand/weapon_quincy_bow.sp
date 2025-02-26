#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerQuincy_BowManagement[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXTF2PLAYERS+1];
static float fl_Quincy_Charge[MAXTF2PLAYERS + 1];
static float fl_Quincy_Max_Battery[MAXTF2PLAYERS + 1];
static float fl_Quincy_Charge_Multi[MAXTF2PLAYERS + 1];

#define QUINCY_BOW_HYPER_BARRAGE_DRAIN 10.0		//how much charge is drained per shot
#define QUINCY_BOW_HYPER_BARRAGE_MINIMUM 50.0	//what % of charge does the battery need to start firing
#define QUINCY_BOW_MAX_HYPER_BARRAGE 11			//how many maximum individual timers/origin points are shot, kinda like how many of them can be fired a second, this is the max amt
#define QUINCY_BOW_MULTI_SHOT_MINIMUM	50.0	//yada yada

#define QUINCY_BOW_ARROW_TOUCH_SOUND "friends/friend_online.wav"

#define QUINCY_BOW_HYPER_CHARGE	1500.0
#define QUINCY_BOW_ONHIT_GAIN	50.0
#define QUINCY_BOW_ONHIT_MULTI_ARROW 10.0
static float fl_hyper_arrow_charge[MAXTF2PLAYERS];


static float fl_quincy_hyper_arrow_timeout[MAXTF2PLAYERS];
static float fl_sound_timer[MAXTF2PLAYERS + 1];

static const char hyper_arrow_sounds[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_06.mp3",
};

static const char Spark_Sound[][] = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav",
};

static const char Zap_Sound[][] = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav",
};
#define QUINCY_BOW_BASELINE_BATTERY 400.0	//this is kinda like the true mana cost of the weapon


static float fl_Quincy_Barrage_Firerate[MAXTF2PLAYERS + 1][QUINCY_BOW_MAX_HYPER_BARRAGE+1];

static int g_particleImpactTornado;

static int i_combine_laser;
static int i_halo_laser;

public void QuincyMapStart()
{
	PrecacheSound(QUINCY_BOW_ARROW_TOUCH_SOUND);

	i_halo_laser		= PrecacheModel("materials/sprites/halo01.vmt", true);
	i_combine_laser 	= PrecacheModel("materials/sprites/combineball_trail_blue_1.vmt", true);

	Zero(fl_hyper_arrow_charge);

	PrecacheSoundArray(Zap_Sound);
	PrecacheSoundArray(Spark_Sound);
	PrecacheSoundArray(hyper_arrow_sounds);
	
	Zero(fl_quincy_hyper_arrow_timeout);
	Zero2(fl_Quincy_Barrage_Firerate);
	Zero(fl_sound_timer);
	Zero(fl_Quincy_Charge_Multi);
	Zero(fl_Quincy_Charge);
	Zero(h_TimerQuincy_BowManagement);
	Zero(fl_hud_timer);
	
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	
	for(int client=1 ; client <= MAXTF2PLAYERS ; client++)
	{
		fl_Quincy_Charge_Multi[client] = 1.0;
		fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY;
	}
}
static int Get_Quincy_Pap(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, 122, 0.0));
}
public void Activate_Quincy_Bow(int client, int weapon)
{
	if (h_TimerQuincy_BowManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerQuincy_BowManagement[client];
			h_TimerQuincy_BowManagement[client] = null;			
				
			int pap = Get_Quincy_Pap(weapon);

			switch(pap)
			{
				case 0:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY;
					fl_Quincy_Charge_Multi[client] = 1.0;	//how efficient it is: charge += mana_cost*this.
				}
				case 1:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.25;
					fl_Quincy_Charge_Multi[client] = 1.5;
				}
				case 2:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.5;
					fl_Quincy_Charge_Multi[client] = 2.0;
				}
				case 3:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.75;
					fl_Quincy_Charge_Multi[client] = 2.25;
				}
				case 4:	//hyper barrage
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*2.0;
					fl_Quincy_Charge_Multi[client] = 2.5;
				}
				case 5:	//hyper arrow
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*5.0;
					fl_Quincy_Charge_Multi[client] = 2.0;
				}
			}

			DataPack pack;
			h_TimerQuincy_BowManagement[client] = CreateDataTimer(0.1, Timer_Management_Quincy_Bow, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW)
	{
		int pap = Get_Quincy_Pap(weapon);
		switch(pap)
		{
			case 0:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY;
				fl_Quincy_Charge_Multi[client] = 1.0;
			}
			case 1:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.25;
				fl_Quincy_Charge_Multi[client] = 1.5;
			}
			case 2:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.5;
				fl_Quincy_Charge_Multi[client] = 2.0;
			}
			case 3:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.75;
				fl_Quincy_Charge_Multi[client] = 2.25;
			}
			case 4:	//hyper barrage
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*2.0;
				fl_Quincy_Charge_Multi[client] = 2.5;
			}
			case 5:	//hyper arrow
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*5.0;
				fl_Quincy_Charge_Multi[client] = 1.8;
			}
		}
		
		DataPack pack;
		h_TimerQuincy_BowManagement[client] = CreateDataTimer(0.1, Timer_Management_Quincy_Bow, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public void Quincy_Bow_M2(int client, int weapon, bool crit, int slot)
{
	
	if(fl_hyper_arrow_charge[client] >= QUINCY_BOW_HYPER_CHARGE || CvarInfiniteCash.BoolValue)
	{
		if(fl_quincy_hyper_arrow_timeout[client] > GetGameTime() && !CvarInfiniteCash.BoolValue)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Your Hyper Arrow Is still cooling");
			return;
		}
		int Mana_Cost = 500;
		if(Current_Mana[client] < Mana_Cost)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana", Mana_Cost);
			return;
		}
		Current_Mana[client] -=Mana_Cost;
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		fl_hyper_arrow_charge[client] = 0.0;

		fl_quincy_hyper_arrow_timeout[client] = GetGameTime() + 15.0;

		float Origin[3], Angles[3];
		GetClientEyePosition(client,Origin);
		GetClientEyeAngles(client,Angles);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		float vecHit[3];
		Handle trace = TR_TraceRayFilterEx(Origin, Angles, 11, RayType_Infinite, TraceWalls);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(vecHit, trace);
		}
		FinishLagCompensation_Base_boss();
		delete trace;

		float Radius = 50.0;
		
		EmitSoundToAll(hyper_arrow_sounds[GetRandomInt(0, sizeof(hyper_arrow_sounds)-1)], client, SNDCHAN_STATIC, 100, _, 0.5, 100);	//very loud!

		float damage = 625.0;
		damage *= Attributes_Get(weapon, 410, 1.0);

		Quincy_Damage_Trace(client, Origin, vecHit, Radius, damage);

		Client_Shake(client, 0, 35.0, 20.0, 0.8);

		Origin[2]-=15.0;
		vecHit[2]-=15.0;

		int color[4] = {0, 150, 200, 150};
		float size = Radius*2.0;
		TE_SetupBeamPoints(Origin, vecHit, i_combine_laser, i_halo_laser, 0, 66, 1.5, size, size, 1, 0.5, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, vecHit, i_combine_laser, i_halo_laser, 0, 66, 2.0, size*0.75, size*0.75, 1, 2.5, color, 33);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, vecHit, i_combine_laser, 0, 0, 66, 2.5, size*0.5, size*0.5, 1, 1.0, color, 33);
		TE_SendToAll();
		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}
static bool TraceWalls(int entity, int contentsMask)
{
	return !entity;
}

#define QUINCY_MAX_TARGETS_HIT 50
static int i_quincy_targethit[QUINCY_MAX_TARGETS_HIT];

static void Quincy_Damage_Trace(int client, float Vec_1[3], float Vec_2[3], float radius, float dmg)
{
	static float hullMin[3];
	static float hullMax[3];

	Zero(i_quincy_targethit);
	
	hullMin[0] = -radius;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(Vec_1, Vec_2, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	
	float Falloff = 1.0;	//minimal falloff due to how it works
	
	float BEAM_Targets_Hit = 1.0;
	for (int victim = 1; victim < QUINCY_MAX_TARGETS_HIT; victim++)
	{
		int Target = i_quincy_targethit[victim];
		if (Target && GetTeam(client) != GetTeam(Target))
		{
			float Adjusted_Dmg = dmg*BEAM_Targets_Hit;
			if(b_thisNpcIsARaid[Target])
				Adjusted_Dmg*= 1.25;

			SDKHooks_TakeDamage(Target, client, client, Adjusted_Dmg, DMG_PLASMA, -1, NULL_VECTOR);	// 2048 is DMG_NOGIB?
			BEAM_Targets_Hit *= Falloff;
		}
	}
}
static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=1; i < QUINCY_MAX_TARGETS_HIT; i++)
			{
				if(!i_quincy_targethit[i])
				{
					i_quincy_targethit[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}

public Action Timer_Management_Quincy_Bow(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerQuincy_BowManagement[client] = null;
		return Plugin_Stop;
	}	

	Quincy_Bow_Loop_Logic(client, weapon);
		
	return Plugin_Continue;
}
static bool b_lockout[MAXTF2PLAYERS+1];
static void Quincy_Bow_Loop_Logic(int client, int weapon)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding==weapon)	//And this will only work if they have the weapon in there hands and bought
	{
		float GameTime = GetGameTime();
		int buttons = GetClientButtons(client);
		bool attack = (buttons & IN_ATTACK) != 0;
		bool attack2 = (buttons & IN_ATTACK2) != 0;

		int pap = Get_Quincy_Pap(weapon);
		
		float charge_percent = (fl_Quincy_Charge[client] / QUINCY_BOW_BASELINE_BATTERY) * 100.0;
		
		if(fl_hud_timer[client]<GameTime)
		{
			fl_hud_timer[client] = GameTime + 0.5;//0.5;
			Quincy_Bow_Show_Hud(client, charge_percent, weapon);
		}
		if(!attack && !attack2 && b_lockout[client])
		{
			b_lockout[client] = false;
			fl_Quincy_Charge[client] = 0.0;
			charge_percent = 0.0;
		}
		
		if(attack && !b_lockout[client])	//eat mana if the client is holding m1
		{
			if(attack2)
			{
				b_lockout[client] = true;	//if the client preses m2 while charging the charge will go bye bye.
			}
			
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			Mana_Hud_Delay[client] = 0.0;
			
			float charge_percent_sound = (fl_Quincy_Charge[client] / fl_Quincy_Max_Battery[client]) * 100.0;
			
			if(fl_sound_timer[client]<GameTime)
			{
				fl_sound_timer[client] = GameTime + 0.1;
				
				switch(GetRandomInt(1, 2))
				{
					case 1:
					{
						EmitSoundToAll(Zap_Sound[GetRandomInt(0, sizeof(Zap_Sound)-1)], client, SNDCHAN_STATIC, 80, _, 0.15, RoundToFloor(charge_percent_sound)+25);
					}
					case 2:
					{
						EmitSoundToAll(Spark_Sound[GetRandomInt(0, sizeof(Spark_Sound)-1)], client, SNDCHAN_STATIC, 80, _, 0.15, RoundToFloor(charge_percent_sound)+25);
					}
					
				}		
			}
			if(fl_Quincy_Max_Battery[client]>fl_Quincy_Charge[client])
			{
				int mana_cost;
				mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
				
				if(Current_Mana[client]>mana_cost)
				{
					fl_Quincy_Charge[client] += mana_cost*fl_Quincy_Charge_Multi[client];					
					Current_Mana[client] -=mana_cost;
				}

				if(fl_Quincy_Charge[client] > fl_Quincy_Max_Battery[client] && pap !=4)
					fl_Quincy_Charge[client] = fl_Quincy_Max_Battery[client];
			}
		}
		else if(charge_percent>10.0 && !b_lockout[client])
		{
			Quincy_Bow_Fire(client, weapon, charge_percent);
			fl_Quincy_Charge[client] = 0.0;
			charge_percent = 0.0;
		}
		else if(charge_percent>0 && !b_lockout[client])
		{
			fl_Quincy_Charge[client] = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Insufficient Charge");
		}
		if(pap==4 && !b_lockout[client])	//Hyper Barrage
		{
			if(charge_percent>QUINCY_BOW_HYPER_BARRAGE_MINIMUM)
			{
				Quincy_Hyper_Barrage(client, charge_percent, GameTime, weapon);
			}
		}
	}
	else
	{
		fl_Quincy_Charge[client] = 0.0;
	}
}
static void Quincy_Hyper_Barrage(int client, float charge_percent, float GameTime, int weapon)
{
	float angles[3];
	float UserLoc[3];
	
	GetClientEyePosition(client, UserLoc);
	GetClientEyeAngles(client, angles);
	int speed = RoundToCeil(charge_percent / 20.0);

	float distance = GetRandomFloat(float(speed)*10.0, float(speed)*25.0);

	float tempAngles[3], endLoc[3], Direction[3];
	
	Handle swingTrace;
	float Vec_offset[3] , vec[3];
			
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, Vec_offset, 9999.9, false, 10.0, false); //infinite range, and (doesn't)ignore walls!	
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);	
	if(IsValidEnemy(client, target))
	{
		WorldSpaceCenter(target, vec);
		
	}
	else
	{
		TR_GetEndPosition(vec, swingTrace);
	}
	Vec_offset = vec;
			
	delete swingTrace;
	
	
	
	if(speed>QUINCY_BOW_MAX_HYPER_BARRAGE)
		speed = QUINCY_BOW_MAX_HYPER_BARRAGE;

	speed = RoundToCeil(float(speed) / 2.0) * 2;

	float special_angle = 45.0;
		
	float Ratio_Core = (180.0)/(speed);

	if(speed>=8)
	{
		UserLoc[2] += 12.0*(speed-7);
	}

	for(int i=1 ; i<speed ; i++)
	{	
		if(fl_Quincy_Barrage_Firerate[client][i]<GameTime)
		{
			
			float Angle_Adj =  Ratio_Core*i+special_angle-(Ratio_Core/2);

			float firerate = 0.7;
			firerate *= Attributes_Get(weapon, 5, 1.0);
			firerate *= Attributes_Get(weapon, 6, 1.0);
			
			fl_Quincy_Barrage_Firerate[client][i] = GameTime + firerate + GetRandomFloat(firerate/-2.0, firerate/2.0);
			
			fl_Quincy_Charge[client] -= QUINCY_BOW_HYPER_BARRAGE_DRAIN;

			if(i>speed/2)
			{
				Angle_Adj+=special_angle*2.0;
			}
			
			
			
			tempAngles[0] = angles[0];
			tempAngles[1] = angles[1];
			tempAngles[2] = Angle_Adj;	
			
			if(tempAngles[2]>360.0)
				tempAngles[2] -= 360.0;
						
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			float fl_speed = 3000.0*(charge_percent/50.0);

			fl_speed *= Attributes_Get(weapon, 103, 1.0);
				
			fl_speed *= Attributes_Get(weapon, 104, 1.0);
				
			fl_speed *= Attributes_Get(weapon, 475, 1.0);
			
			if(fl_speed>3000.0)
				fl_speed = 3000.0;
				
			float damage;
			damage = 33.0*(charge_percent/100.0);
			damage *= Attributes_Get(weapon, 410, 1.0);
			float ang_Look[3];
			MakeVectorFromPoints(endLoc, Vec_offset, ang_Look);
			GetVectorAngles(ang_Look, ang_Look);
			Quincy_Rocket_Launch(client, fl_speed, damage, weapon, ang_Look, endLoc);
		}
	}
}

static int i_quincy_penetration_amt[MAXENTITIES];
static float fl_quincy_penetrated[MAXENTITIES];
static void Quincy_Bow_Fire(int client, int weapon, float charge_percent)
{
	int pap = Get_Quincy_Pap(weapon);
	
	float speed = 1200.0*(charge_percent/100.0);

	if(speed < 1000.0)
		speed = 1000.0;

	float damage=1.0;

	if(pap>=2)	//removes half charge debuff
	{
		float charge_debuff = (charge_percent / 100.0);
		if(charge_debuff<0.5)
			charge_debuff = 0.5;
		damage = 100.0*charge_debuff*1.5;
		
		speed = 3000.0*(charge_percent/25.0);
		
		float multi_arrow_damage = 0.5*damage * Attributes_Get(weapon, 410, 1.0);
		
		if(charge_percent>QUINCY_BOW_MULTI_SHOT_MINIMUM)
		{
			Quincy_Multi_Shot(client, weapon, charge_percent, multi_arrow_damage);
		}
	}
	else
	{
		damage = 100.0*(charge_percent/100.0);	//this at max battery at max charge would deal like 6k, However, due to the penetrating arrow at 50% the most this can deal is like 3k base
	}
	
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	speed *= Attributes_Get(weapon, 103, 1.0);
		
	speed *= Attributes_Get(weapon, 104, 1.0);
		
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	
	float time = 10.0;

	if(speed>=2200.0)
		speed=2200.0;

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue");
	WandProjectile_ApplyFunctionToEntity(projectile, Quincy_Touch);

	if(pap>=1)
	{	
		Quincy_Do_Homing(client, projectile, charge_percent);
	}
		

	i_quincy_penetration_amt[projectile] = 1;
	fl_quincy_penetrated[projectile] = 1.0;
	if(charge_percent>=50.0)
	{
		int pen_amt = RoundToFloor((charge_percent-50.0)/10.0);
		if(pen_amt>10)
			pen_amt=10;
		i_quincy_penetration_amt[projectile] = pen_amt;
	}

	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetEntData(weapon, iAmmoTable, 1, 4, true);
	
	fl_Quincy_Charge[client] = 0.0;
}
static void Quincy_Do_Homing(int client, int projectile, float charge_percent)
{
	float Origin[3], Angles[3];
	GetClientEyePosition(client,Origin);
	GetClientEyeAngles(client,Angles);

	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float vecHit[3];
	Handle trace = TR_TraceRayFilterEx(Origin, Angles, 11, RayType_Infinite, TraceWalls);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vecHit, trace);
	}
	delete trace;
	static float hullMin[3];
	static float hullMax[3];

	Zero(i_quincy_targethit);
	
	Set_HullTrace(50.0, hullMin, hullMax);
	
	Handle hull_trace = TR_TraceHullFilterEx(Origin, vecHit, hullMin, hullMax, 1073741824, BEAM_HitDetected, client);	// 1073741824 is CONTENTS_LADDER?
	delete hull_trace;

	FinishLagCompensation_Base_boss();

	float Homing_Power = 2.0*(charge_percent/100.0);

	float LockonAngle = 45.0;

	if(Homing_Power > 7.5)
		Homing_Power = 7.5;

	if(IsValidEntity(i_quincy_targethit[0]))
	{
		LockonAngle = 90.0;
		Homing_Power *=1.5;
	}

	

	Initiate_HomingProjectile(projectile,
	client,
		LockonAngle,			// float lockonAngleMax,
		Homing_Power,				//float homingaSec,
		false,				// bool LockOnlyOnce,
		true,				// bool changeAngles,
		Angles,
		i_quincy_targethit[0]);			// float AnglesInitiate[3]);
}
void Set_HullTrace(float radius, float hullMin[3], float hullMax[3])
{
	hullMin[0] = -radius;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
}
static bool BEAM_HitDetected(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			if(!i_quincy_targethit[0])
				i_quincy_targethit[0] = entity;
		}
	}
	return false;
}
static void Quincy_Multi_Shot(int client, int weapon, float charge_percent, float dmg)
{
	float multi_arrow_speed = 500.0*(charge_percent/50.0);
				
	multi_arrow_speed *= Attributes_Get(weapon, 103, 1.0);
		
	multi_arrow_speed *= Attributes_Get(weapon, 104, 1.0);
		
	multi_arrow_speed *= Attributes_Get(weapon, 475, 1.0);

	int amt;

	int pap = Get_Quincy_Pap(weapon);
	float spacing;

	switch(pap)	//can't be a number that dividable by 2.
	{
		case 2:
		{
			amt = 3;
			spacing = 19.0;
		}
		case 3:
		{
			amt = 5;
			spacing = 14.0;
		}
		case 4, 5:
		{
			amt = 7;
			spacing = 10.0;
		}
		default:
		{
			amt=3;
			spacing = 19.0;
		}
	}

	if(multi_arrow_speed>1000.0)
		multi_arrow_speed = 1000.0;

	float fAng[3];
	GetClientEyeAngles(client, fAng);
	float fPos[3];
	GetClientEyePosition(client, fPos);

	int type=3;
	for(int i=0 ; i< amt ; i++)
	{
		float end_vec[3];
		Do_Vector_Stuff(i, fPos, end_vec, fAng, amt, type, spacing);
		Quincy_Rocket_Launch(client, multi_arrow_speed, dmg, weapon, fAng, end_vec);
		if(type==3)
			type=1;
		else
			type=3;
	}
}
static void Do_Vector_Stuff(int cycle, float start_pos[3], float end_Pos[3], float angles[3], int loop_for, int type, float spacing)
{	

	float tempAngles[3], Direction[3], buffer_loc[3];
		
	tempAngles[0] = angles[0];
	tempAngles[1] = angles[1];
	tempAngles[2] = angles[2]+90.0*type;

	if(type==1)
		cycle+=1;
							
	GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
	ScaleVector(Direction, spacing*cycle);
	AddVectors(start_pos, Direction, buffer_loc);

	float dist = (spacing*loop_for) - GetVectorDistance(start_pos, buffer_loc);

	Get_Fake_Forward_Vec(dist, angles, end_Pos, buffer_loc);
}
static void Quincy_Rocket_Launch(int client, float speed, float damage, int weapon, float fAng[3], float fPos[3])
{
	int projectile = Wand_Projectile_Spawn(client, speed, 30.0, damage, 0, weapon, "raygun_projectile_blue", fAng, false , fPos);
	WandProjectile_ApplyFunctionToEntity(projectile, Quincy_MultiArroTouch);
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

static void Quincy_Bow_Show_Hud(int client, float charge_percent, int weapon)
{
	
	int pap = Get_Quincy_Pap(weapon);
	
	char HUDText[255] = "";
	
	Format(HUDText, sizeof(HUDText), "%sRaishi Concentration: [%.0f%%%%%%%%%]", HUDText, charge_percent);


	if(pap>=2)
	{
		if(charge_percent>QUINCY_BOW_MULTI_SHOT_MINIMUM)
		{
			
			int amt;

			switch(pap)	//can't be a number that dividable by 2.
			{
				case 2:
				{
					amt = 3;
				}
				case 3:
				{
					amt = 5;
				}
				case 4, 5:
				{
					amt = 5;
				}
				default:
				{
					amt=3;
				}
			}
			Format(HUDText, sizeof(HUDText), "%s\nExtra Shoots: [%i]", HUDText, amt);
		}
	}
	if(charge_percent>=50.0)
	{
		int pen_amt = RoundToFloor((charge_percent-50.0)/10.0);
		if(pen_amt>10)
			pen_amt=10;
		Format(HUDText, sizeof(HUDText), "%s\nArrow Penetration: [%i/10]", HUDText, pen_amt);
	}
		
	if(pap==4)
	{
		if(charge_percent>25.0)
		{
			Format(HUDText, sizeof(HUDText), "%s\nHyper Barrage Active!", HUDText);
		}
		else
		{
			Format(HUDText, sizeof(HUDText), "%s\nHyper Barrage not enough charge", HUDText);
		}
	}
	if(pap==5)
	{
		if(fl_hyper_arrow_charge[client] >= QUINCY_BOW_HYPER_CHARGE || CvarInfiniteCash.BoolValue)
		{
			float GameTime = GetGameTime();
			if(fl_quincy_hyper_arrow_timeout[client] > GameTime && !CvarInfiniteCash.BoolValue)
			{
				Format(HUDText, sizeof(HUDText), "%s\nHyper Arrow [Cooling{%.1fs}]", HUDText, (fl_quincy_hyper_arrow_timeout[client]-GameTime));
			}
			else
			{
				Format(HUDText, sizeof(HUDText), "%s\nHyper Arrow [READY]", HUDText);
			}
		}
		else
		{
			float Charge = 100.0*(fl_hyper_arrow_charge[client]/QUINCY_BOW_HYPER_CHARGE);
			Format(HUDText, sizeof(HUDText), "%s\nHyper Arrow [%.0f%%%%%%%%%]", HUDText, Charge);
		}
	}
	
	PrintHintText(client, HUDText);
	
}

public void Quincy_Touch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float GameTime = GetGameTime();

		if(f_GlobalHitDetectionLogic[owner][target] < GameTime)
		{
			f_GlobalHitDetectionLogic[owner][target] = GameTime+0.25;
			float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
			
			SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity]*fl_quincy_penetrated[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

			fl_quincy_penetrated[entity] *= LASER_AOE_DAMAGE_FALLOFF;	//LASER_AOE_DAMAGE_FALLOFF;

			fl_hyper_arrow_charge[owner] +=QUINCY_BOW_ONHIT_GAIN;
			if(fl_hyper_arrow_charge[owner] > QUINCY_BOW_HYPER_CHARGE)
				fl_hyper_arrow_charge[owner] = QUINCY_BOW_HYPER_CHARGE;

			i_quincy_penetration_amt[entity]--;
			if(i_quincy_penetration_amt[entity]<=0)
			{
				float pos1[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
				TE_ParticleInt(g_particleImpactTornado, pos1);
				TE_SendToAll();

				if(IsValidEntity(particle))
				{
					RemoveEntity(particle);
				}
				RemoveEntity(entity);
			}
			
			EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
		}
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
		RemoveEntity(entity);
	}
}

static void Quincy_MultiArroTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, PushforceDamage, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.5);
		RemoveEntity(entity);

		

		fl_hyper_arrow_charge[owner] +=QUINCY_BOW_ONHIT_MULTI_ARROW;
		if(fl_hyper_arrow_charge[owner] > QUINCY_BOW_HYPER_CHARGE)
			fl_hyper_arrow_charge[owner] = QUINCY_BOW_HYPER_CHARGE;
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.5);
		RemoveEntity(entity);
	}
}