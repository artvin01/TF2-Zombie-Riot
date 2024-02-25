#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerQuincy_BowManagement[MAXPLAYERS+1] = {null, ...};
static float fl_hud_timer[MAXTF2PLAYERS+1];
static float fl_Quincy_Charge[MAXTF2PLAYERS + 1];
static float fl_Quincy_Max_Battery[MAXTF2PLAYERS + 1];
static float fl_Quincy_Charge_Multi[MAXTF2PLAYERS + 1];

#define QUINCY_BOW_HYPER_BARRAGE_DRAIN 10.0		//how much charge is drained per shot
#define QUINCY_BOW_HYPER_BARRAGE_MINIMUM 25.0	//what % of charge does the battery need to start firing
#define QUINCY_BOW_MAX_HYPER_BARRAGE 14			//how many maximum individual timers/origin points are shot, kinda like how many of them can be fired a second, this is the max amt
#define QUINCY_BOW_MULTI_SHOT_MINIMUM	50.0	//yada yada

#define QUINCY_BOW_ARROW_TOUCH_SOUND "friends/friend_online.wav"

static float fl_sound_timer[MAXTF2PLAYERS + 1];

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
#define QUINCY_BOW_BASELINE_BATTERY 300.0


static float fl_Quincy_Barrage_Firerate[MAXTF2PLAYERS + 1][QUINCY_BOW_MAX_HYPER_BARRAGE+1];

static int g_rocket_particle;
static int g_particleImpactTornado;

public void QuincyMapStart()
{
	PrecacheSound(QUINCY_BOW_ARROW_TOUCH_SOUND);
	
	for (int i = 0; i < (sizeof(Zap_Sound));	   i++) { PrecacheSound(Zap_Sound[i]);	   }
	for (int i = 0; i < (sizeof(Spark_Sound));	   i++) { PrecacheSound(Spark_Sound[i]);	   }
	
	Zero2(fl_Quincy_Barrage_Firerate);
	Zero(fl_sound_timer);
	Zero(fl_Quincy_Charge_Multi);
	Zero(fl_Quincy_Charge);
	Zero(h_TimerQuincy_BowManagement);
	Zero(fl_hud_timer);
	
	g_rocket_particle = PrecacheModel(PARTICLE_ROCKET_MODEL);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");

	
	for(int client=1 ; client <= MAXTF2PLAYERS ; client++)
	{
		fl_Quincy_Charge_Multi[client] = 1.0;
		fl_Quincy_Max_Battery[client] = 300.0;
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
					fl_Quincy_Charge_Multi[client] = 1.0;
				}
				case 1:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.1;
					fl_Quincy_Charge_Multi[client] = 1.5;
				}
				case 2:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.2;
					fl_Quincy_Charge_Multi[client] = 2.0;
				}
				case 3:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.5;
					fl_Quincy_Charge_Multi[client] = 2.25;
				}
				case 5:
				{
					fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.7;
					fl_Quincy_Charge_Multi[client] = 2.5;
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
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.1;
				fl_Quincy_Charge_Multi[client] = 1.5;
			}
			case 2:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.2;
				fl_Quincy_Charge_Multi[client] = 2.0;
			}
			case 3:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.5;
				fl_Quincy_Charge_Multi[client] = 2.25;
			}
			case 5:
			{
				fl_Quincy_Max_Battery[client] = QUINCY_BOW_BASELINE_BATTERY*1.7;
				fl_Quincy_Charge_Multi[client] = 2.5;
			}
		}
		
		DataPack pack;
		h_TimerQuincy_BowManagement[client] = CreateDataTimer(0.1, Timer_Management_Quincy_Bow, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Quincy_Bow(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Delete_Quincy_Weapon(client);
		h_TimerQuincy_BowManagement[client] = null;
		return Plugin_Stop;
	}	

	Quincy_Bow_Blade_Loop_Logic(client, weapon);
		
	return Plugin_Continue;
}
static bool b_lockout[MAXTF2PLAYERS+1];
static void Quincy_Bow_Blade_Loop_Logic(int client, int weapon)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding==weapon)	//And this will only work if they have the weapon in there hands and bought
	{
		Create_Quincy_Weapon(client, _);
		float GameTime = GetGameTime();
		int buttons = GetClientButtons(client);
		bool attack = (buttons & IN_ATTACK) != 0;
		bool attack2 = (buttons & IN_ATTACK2) != 0;

		int pap = Get_Quincy_Pap(weapon);
		
		float charge_percent = (fl_Quincy_Charge[client] / QUINCY_BOW_BASELINE_BATTERY) * 100.0;
		
		if(fl_hud_timer[client]<GameTime)
		{
			fl_hud_timer[client] = GameTime + 0.5;
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
			
			Mana_Regen_Delay[client] = GameTime + 1.0;
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
				
				mana_cost = RoundToCeil(mana_cost*fl_Quincy_Charge_Multi[client]);
				
				if(Current_Mana[client]>=mana_cost)
				{
					fl_Quincy_Charge[client] += mana_cost;					
					Current_Mana[client] -=mana_cost;
				}
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
		if(pap>=4)	//Hyper Barrage
		{
			if(charge_percent>QUINCY_BOW_HYPER_BARRAGE_MINIMUM)
			{
				Quincy_Hyper_Barrage(client, charge_percent, GameTime, weapon);
			}
		}
		
	}
	else
	{
		Delete_Quincy_Weapon(client);
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

	speed = RoundToCeil(speed / 2.0) * 2;

	float special_angle = 45.0;
		
	float Ratio_Core = (180.0)/(speed);

	if(speed>=8)
	{
		UserLoc[2] += 12.0*(speed-7);
	}

	for(int i=1 ; i<=speed ; i++)
	{	
		if(fl_Quincy_Barrage_Firerate[client][i]<GameTime)
		{
			
			float Angle_Adj =  Ratio_Core*i+special_angle-(Ratio_Core/2);

			float firerate = 0.5;
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
			Quincy_Rocket_Launch(client, weapon, endLoc, Vec_offset, fl_speed, damage, "raygun_projectile_blue");
		}
	}
}
static void Quincy_Bow_Fire(int client, int weapon, float charge_percent)
{
	
	int pap = Get_Quincy_Pap(weapon);
	
	float speed = 6000.0*(charge_percent/100.0);

	float damage=1.0;

	if(speed>=3000)
		speed=3000.0;
	
	if(pap>=2)	//removes half charge debuff
	{
		float charge_debuff = (charge_percent / 100.0);
		if(charge_debuff<0.5)
			charge_debuff = 0.5;
		damage = 100.0*charge_debuff*1.5;
		
		speed = 3000.0*(charge_percent/25.0);
		
		float multi_arrow_damage = 0.75*damage * Attributes_Get(weapon, 410, 1.0);
		
		if(charge_percent>QUINCY_BOW_MULTI_SHOT_MINIMUM)
		{
			float amt = charge_percent / (QUINCY_BOW_MULTI_SHOT_MINIMUM/2.0);

			float Vec_offset[3]; 
			Get_Fake_Forward_Vec(client, 100.0, Vec_offset);
			Vec_offset[2] -= 32.5;
			float Npc_Vec[3]; WorldSpaceCenter(client, Npc_Vec);
			
			float ang_Look[3];
			
			MakeVectorFromPoints(Npc_Vec, Vec_offset, ang_Look);
			GetVectorAngles(ang_Look, ang_Look);
			
			float wide_set = 45.0;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing
			
			switch(pap)
			{
				case 2:
				{
					if(amt>=3.0)
						amt=3.0;
				}
				case 3:
				{
					if(amt>=5.0)
						amt=5.0;
				}
				case 4:
				{
					if(amt>=7.0)
						amt=7.0;
				}
				default:
				{
					amt=3.0;
				}
			}

			ang_Look[1] -= wide_set;
			float type = (wide_set*2) / RoundToFloor(amt);	//check why its so horribly offset
			ang_Look[1] -= type/2;

			
			for(int i=1 ; i<= RoundToFloor(amt) ; i++)
			{
		
				float tempAngles[3], endLoc[3], Direction[3];
				
				tempAngles[0] = ang_Look[0];
				tempAngles[1] = ang_Look[1] + type * i;
				tempAngles[2] = 0.0;
									
				GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, 100.0);
				AddVectors(Npc_Vec, Direction, endLoc);
				
				float multi_arrow_speed = 500.0*(charge_percent/50.0);
				
				multi_arrow_speed *= Attributes_Get(weapon, 103, 1.0);
					
				multi_arrow_speed *= Attributes_Get(weapon, 104, 1.0);
					
				multi_arrow_speed *= Attributes_Get(weapon, 475, 1.0);
				
				if(speed>1000.0)
					speed = 1000.0;
				Quincy_Rocket_Launch(client, weapon, Npc_Vec, endLoc, multi_arrow_speed, multi_arrow_damage, "raygun_projectile_blue");
			}
			fl_Quincy_Charge[client] = 0.0;
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

		
	if(speed>3000.0)
		speed = 3000.0;
	Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_QUINCY_BOW, weapon, "raygun_projectile_blue");
	
	fl_Quincy_Charge[client] = 0.0;
}
static void Get_Fake_Forward_Vec(int client, float Range, float Vec_Target[3])
{
	float vecAngles[3], Direction[3], Pos[3];
	GetClientEyeAngles(client, vecAngles);
	GetClientEyePosition(client, Pos);
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

static void Quincy_Bow_Show_Hud(int client, float charge_percent, int weapon)
{
	
	int pap = Get_Quincy_Pap(weapon);
	
	char HUDText[255] = "";
	
	Format(HUDText, sizeof(HUDText), "%sRaishi Concentration: %.1f％", HUDText, charge_percent);


	if(pap>=2)
	{
		if(charge_percent>QUINCY_BOW_MULTI_SHOT_MINIMUM)
		{
			float amt = charge_percent / (QUINCY_BOW_MULTI_SHOT_MINIMUM/2.0);
			switch(pap)
			{
				case 2:
				{
					if(amt>=3.0)
						amt=3.0;
				}
				case 3:
				{
					if(amt>=5.0)
						amt=5.0;
				}
				case 4:
				{
					if(amt>=7.0)
						amt=7.0;
				}
				default:
				{
					amt=3.0;
				}
			}
			Format(HUDText, sizeof(HUDText), "%s\nExtra Shoots: [%i]", HUDText, RoundToFloor(amt));
		}
		else
		{
			Format(HUDText, sizeof(HUDText), "%s\nMulti Shot: Inactive [%.1f％/%.1f％]", HUDText, charge_percent, QUINCY_BOW_MULTI_SHOT_MINIMUM);
		}
		
		if(pap>=4)
		{
			if(charge_percent<25.0)
			{
				Format(HUDText, sizeof(HUDText), "%s\nHyper Barrage Not Active!\nInsufficient Raishi! [%.1f％/%.1f％]", HUDText, charge_percent, QUINCY_BOW_HYPER_BARRAGE_MINIMUM);
			}
			else
			{
				Format(HUDText, sizeof(HUDText), "%s\nHyper Barrage Active!\nHyper Barrage Speed: [%.1f％]", HUDText, charge_percent);
			}
		}
	}
	
	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
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

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, _, _, 1.0);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(QUINCY_BOW_ARROW_TOUCH_SOUND, entity, SNDCHAN_STATIC, _, _, 1.0);
		RemoveEntity(entity);
	}
}
static int i_particle[MAXPLAYERS+1][9];
static int i_laser[MAXPLAYERS+1][7];

static void test(float vec[3], float vec2[3], float Direction[3])
{
	float vecAngles[3];
	MakeVectorFromPoints(vec, vec2, vecAngles);
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, -25.0);
}

static void Create_Quincy_Weapon(int client, bool first = false)
{
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	
	if(!IsValidEntity(viewmodelModel))
		return;
	
		
	if(first)
	{
		bool do_new = false;
		for(int i=0 ; i < 9 ; i++)
		{
			int wing_laser = EntRefToEntIndex(i_particle[client][i]);
			if(!IsValidEntity(wing_laser))
			{
				do_new = true;
			}
		}	
		for(int i=0 ; i < 7 ; i++)
		{
			int wing_particle = EntRefToEntIndex(i_laser[client][i]);
			if(!IsValidEntity(wing_particle))
			{
				do_new = true;
			}
		}
		if(do_new)
		{
			Spawn_Weapon(client,viewmodelModel);
			
		}
		return;
	}
		
	bool do_new = false;
	
	for(int i=0 ; i < 9 ; i++)
	{
		int wing_laser = EntRefToEntIndex(i_particle[client][i]);
		if(!IsValidEntity(wing_laser))
		{
			do_new = true;
		}
	}	
	for(int i=0 ; i < 7 ; i++)
	{
		int wing_particle = EntRefToEntIndex(i_laser[client][i]);
		if(!IsValidEntity(wing_particle))
		{
			do_new = true;
		}
	}
	if(do_new)
	{
		Delete_Quincy_Weapon(client);
		Spawn_Weapon(client,viewmodelModel);
	}	
}

static void Spawn_Weapon(int client, int viewmodelModel)
{
		
	float flPos[3];
	float flAng[3];
	GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
	
	float flPos_2[3];
	float flAng_2[3];
	GetAttachment(viewmodelModel, "effect_hand_r", flPos_2, flAng_2);
	
	int i_particle_right = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);
	
	float Direction[3], zero_zero[3] = {0.0, 100.0, 0.0};	//use this to get a "fake" forward vec
	
	float offest1 = 8.5;
	float offest2 = 8.5;
	float offest3 = 26.0;
	//zero_zero[0] += offest1;
	//zero_zero[2] += offest2;
	int r, g, b;
	float f_start, f_end, amp;
	r = 1;
	g = 175;
	b = 255;
	f_start = 1.0;
	f_end = 1.0;
	amp = 0.1;
	
	int particle_0 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	float part_0[3] = { 0.0, 12.5, 0.0 };
	part_0[0] += offest1;
	part_0[2] += offest2;
	part_0[1] += offest3;
	test(part_0, zero_zero, Direction); //ScaleVector(Direction, -1.0);
	AddVectors(part_0, Direction, part_0);
	
	int particle_1 = InfoTargetParentAt(part_0, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	float part_1[3] = { 0.0, -10.0, -30.0 };
	part_1[0] += offest1;
	part_1[2] += offest2;
	part_1[1] += offest3;
	test(part_1, zero_zero, Direction);
	AddVectors(part_1, Direction, part_1);
	
	float part_1_1[3] = { 0.0, -10.0, 30.0 };
	part_1_1[0] += offest1;
	part_1_1[2] += offest2;
	part_1_1[1] += offest3;
	test(part_1_1, zero_zero, Direction);
	AddVectors(part_1_1, Direction, part_1_1);
	
	float part_2[3] = {0.0, -15.0, -45.0};
	part_2[0] += offest1;
	part_2[2] += offest2;
	part_2[1] += offest3;
	test(part_2, zero_zero, Direction);
	AddVectors(part_2, Direction, part_2);
	float part_2_1[3] = {0.0, -15.0, 45.0};
	part_2_1[0] += offest1;
	part_2_1[2] += offest2;
	part_2_1[1] += offest3;
	test(part_2_1, zero_zero, Direction);
	AddVectors(part_2_1, Direction, part_2_1);

	float part_3[3] = {0.0, 0.0, -17.0};
	part_3[0] += offest1;
	part_3[2] += offest2;
	part_3[1] += offest3;
	test(part_3, zero_zero, Direction);
	AddVectors(part_3, Direction, part_3);
	
	float part_3_1[3] = {0.0, 0.0, 17.0};
	part_3_1[0] += offest1;
	part_3_1[2] += offest2;
	part_3_1[1] += offest3;
	test(part_3_1, zero_zero, Direction);
	AddVectors(part_3_1, Direction, part_3_1);

	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Foward, Back
	//Z axis - Up Down
	
	int particle_6 = InfoTargetParentAt(part_1, "", 0.0);
	int particle_6_1 = InfoTargetParentAt(part_1_1, "", 0.0);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_6, particle_6_1, "",_, true);
	
	int particle_7 = InfoTargetParentAt(part_2, "", 0.0);
	int particle_7_1 = InfoTargetParentAt(part_2_1, "", 0.0);
	SetParent(particle_1, particle_7, "",_, true);
	SetParent(particle_7, particle_7_1, "",_, true);
	
	int particle_8 = InfoTargetParentAt(part_3, "", 0.0);	//hadle
	int particle_8_1 = InfoTargetParentAt(part_3_1, "", 0.0);
	SetParent(particle_1, particle_8, "",_, true);
	SetParent(particle_8, particle_8_1, "",_, true);
	
	

	
	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(viewmodelModel, particle_0, "effect_hand_l",_);
	
	Custom_SDKCall_SetLocalOrigin(i_particle_right, flPos_2);
	SetEntPropVector(i_particle_right, Prop_Data, "m_angRotation", flAng_2); 
	SetParent(viewmodelModel, i_particle_right, "effect_hand_r",_);
	
	i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM, client));			//inner stick	//base
	
	i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_6_1, r, g, b, f_start, f_end, amp, LASERBEAM, client));		//inner stick	//base
	
	i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_6, i_particle_right, r, g, b, f_start, f_end, amp, LASERBEAM, client));		//string	//base
	
	i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_6_1, i_particle_right, r, g, b, f_start, f_end, amp, LASERBEAM, client));		//string	//base
		
	i_laser[client][4] = EntIndexToEntRef(ConnectWithBeamClient(particle_8, particle_8_1, r, g, b, f_start, f_end, amp, LASERBEAM, client));			//handle	//base

	i_laser[client][5] = EntIndexToEntRef(ConnectWithBeamClient(particle_7, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM, client));			//outer stick	//base
	
	i_laser[client][6] = EntIndexToEntRef(ConnectWithBeamClient(particle_7_1, particle_6_1, r, g, b, f_start, f_end, amp, LASERBEAM, client));		//outer stick	//base

	i_particle[client][0] = EntIndexToEntRef(particle_0);
	i_particle[client][1] = EntIndexToEntRef(particle_1);
	i_particle[client][2] = EntIndexToEntRef(particle_6);
	i_particle[client][3] = EntIndexToEntRef(particle_6_1);
	i_particle[client][4] = EntIndexToEntRef(particle_7_1);
	i_particle[client][5] = EntIndexToEntRef(particle_7_1);
	i_particle[client][6] = EntIndexToEntRef(particle_8);
	i_particle[client][7] = EntIndexToEntRef(particle_8_1);
	i_particle[client][8] = EntIndexToEntRef(i_particle_right);
	
}
static void Delete_Quincy_Weapon(int client)
{
	for(int laser=0 ; laser<7 ; laser++)
	{
		int entity = EntRefToEntIndex(i_laser[client][laser]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
	for(int particle=0 ; particle < 9 ; particle++)
	{
		int entity = EntRefToEntIndex(i_particle[client][particle]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
}
static float f_projectile_dmg[MAXENTITIES];

static int i_Quincy_index[MAXENTITIES+1];
static int i_Quincy_wep[MAXENTITIES+1];

static void Quincy_Rocket_Launch(int client, int weapon, float startVec[3], float targetVec[3], float speed, float dmg, const char[] rocket_particle = "")
{

	float Angles[3], vecForward[3];
	
	MakeVectorFromPoints(startVec, targetVec, Angles);
	GetVectorAngles(Angles, Angles);

	vecForward[0] = Cosine(DegToRad(Angles[0]))*Cosine(DegToRad(Angles[1]))*speed;
	vecForward[1] = Cosine(DegToRad(Angles[0]))*Sine(DegToRad(Angles[1]))*speed;
	vecForward[2] = Sine(DegToRad(Angles[0]))*-speed;

	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		
		f_projectile_dmg[entity] = dmg;
		
		i_Quincy_wep[entity]=weapon;
		i_Quincy_index[entity]=client;
		
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(entity, GetTeam(client));
		TeleportEntity(entity, startVec, Angles, NULL_VECTOR);
		DispatchSpawn(entity);
		int particle = 0;
	
		if(rocket_particle[0]) //If it has something, put it in. usually it has one. but if it doesn't base model it remains.
		{
			particle = ParticleEffectAt(startVec, rocket_particle, 0.0); //Inf duartion
			i_rocket_particle[entity]= EntIndexToEntRef(particle);
			TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
			SetParent(entity, particle);	
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
			SetEntityRenderColor(entity, 255, 255, 255, 0);
		}
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
		
		for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
		{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_rocket_particle, _, i);
		}
		SetEntityModel(entity, PARTICLE_ROCKET_MODEL);
	
		//Make it entirely invis. Shouldnt even render these 8 polygons.
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);

		DataPack pack;
		CreateDataTimer(10.0, Timer_RemoveEntity_Quincy_Projectile, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(EntIndexToEntRef(particle));
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Quincy_RocketExplodePre); 
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Quincy_StartTouch);
	}
	return;
}
public MRESReturn Quincy_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Do. Not.
}
public Action Quincy_StartTouch(int entity, int other)
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
		WorldSpaceCenter(target, Entity_Position);
		
		int owner = EntRefToEntIndex(i_Quincy_index[entity]);
		int weapon =EntRefToEntIndex(i_Quincy_wep[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_projectile_dmg[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		
		
		
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
	   	int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}
public Action Timer_RemoveEntity_Quincy_Projectile(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		RemoveEntity(Projectile);
	}
	if(IsValidEntity(Particle))
	{
		RemoveEntity(Particle);
	}
	return Plugin_Stop; 
}