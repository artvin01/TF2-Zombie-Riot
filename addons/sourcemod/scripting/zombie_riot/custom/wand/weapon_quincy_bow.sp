#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerQuincy_BowManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float fl_hud_timer[MAXTF2PLAYERS+1];
static int i_Quincy_Skill_Points[MAXTF2PLAYERS + 1];
static float fl_Quincy_Charge[MAXTF2PLAYERS + 1];
static float fl_Quincy_Max_Battery[MAXTF2PLAYERS + 1];
static float fl_Quincy_Charge_Multi[MAXTF2PLAYERS + 1];

static bool b_quincy_battery_special_one[MAXTF2PLAYERS + 1];
static bool b_quincy_battery_special_two[MAXTF2PLAYERS + 1];
static int i_quincy_pap[MAXTF2PLAYERS + 1];

static int Beam_Laser;
static int Beam_Glow;

#define QUINCY_BOW_HYPER_SHOT_SOUND "ambient_mp3/halloween/thunder_01.mp3"	//I cast floodgate!
#define QUINCY_BOW_PENETRATING_SHOT_SOUND "ambient_mp3/halloween/thunder_07.mp3"
#define QUINCY_BOW_ARROW_TOUCH_SOUND "friends/friend_online.wav"	//who needs friends anyway... :(
#define QUINCY_BOW_MENU_SOUND1 "misc/halloween/spelltick_02.wav"
#define QUINCY_BOW_MENU_SOUND2 "misc/halloween/spelltick_01.wav"

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


/*
	How much mana the bow can store
	
	100% = 300	//baseline.
	800	//battery1
	1300	//battery2
	1800	//battery3
	750% = 2300	//battery4
	
	Baseline damage is 100*charge%
	
	so if charge is 500%
	dmg = 100*5.0
	baseline dmg = 500.0*upgrades

*/
#define QUINCY_BOW_HYPER_BARRAGE_DRAIN 10.0		//how much charge is drained per shot
#define QUINCY_BOW_HYPER_BARRAGE_MINIMUM 25.0	//what % of charge does the battery need to start firing
#define QUINCY_BOW_MAX_HYPER_BARRAGE 15			//how many maximum individual timers/origin points are shot, kinda like how many of them can be fired a second, this is the max amt
#define QUINCY_BOW_MULTI_SHOT_MINIMUM	50.0	//yada yada

#define QUINCY_BOW_HYPER_ARROW_MINIMUM	700.0		//what % of charge does the battery need to be before hyper arrow is triggerable
#define QUINCY_BOW_PENETRATING_ARROW_MINIMUM 425.0	//same thing as hyper arrow



#define QUINCY_BOW_FAST_CHARGE_1	(1 << 1)
#define QUINCY_BOW_FAST_CHARGE_2	(1 << 2)
#define QUINCY_BOW_FAST_CHARGE_3	(1 << 3)
#define QUINCY_BOW_FAST_CHARGE_4	(1 << 4)

#define QUINCY_BOW_BATTERY_1		(1 << 5)
#define QUINCY_BOW_BATTERY_2		(1 << 6)
#define QUINCY_BOW_BATTERY_3		(1 << 7)
#define QUINCY_BOW_BATTERY_4		(1 << 8)

static bool b_skill_points_give_at_pap[MAXTF2PLAYERS + 1][7];

static int Quincy_Bow_Hex_Array[MAXTF2PLAYERS+1];
static float fl_Quincy_Barrage_Firerate[MAXTF2PLAYERS + 1][QUINCY_BOW_MAX_HYPER_BARRAGE+1];

static int g_rocket_particle;
static int g_particleImpactTornado;

public void Quincy_On_Buy_Reset(int client)
{
	Quincy_Bow_Hex_Array[client] = 0;
	i_Quincy_Skill_Points[client] = 0;
	for(int i=0 ; i < 7 ; i++)
	{
		b_skill_points_give_at_pap[client][i] = false;
	}
	//CPrintToChatAll("client %N, Stats RESET", client);
}

public void QuincyMapStart()
{
	PrecacheSound(QUINCY_BOW_HYPER_SHOT_SOUND);
	PrecacheSound(QUINCY_BOW_PENETRATING_SHOT_SOUND);
	PrecacheSound(QUINCY_BOW_ARROW_TOUCH_SOUND);
	PrecacheSound(QUINCY_BOW_MENU_SOUND1);
	PrecacheSound(QUINCY_BOW_MENU_SOUND2);
	
	for (int i = 0; i < (sizeof(Zap_Sound));	   i++) { PrecacheSound(Zap_Sound[i]);	   }
	for (int i = 0; i < (sizeof(Spark_Sound));	   i++) { PrecacheSound(Spark_Sound[i]);	   }
	
	Zero(i_quincy_pap);
	Zero2(fl_Quincy_Barrage_Firerate);
	Zero(fl_sound_timer);
	Zero(b_quincy_battery_special_one);
	Zero(b_quincy_battery_special_two);
	Zero(fl_Quincy_Charge_Multi);
	Zero(fl_Quincy_Charge);
	Zero(i_Quincy_Skill_Points);
	Zero(h_TimerQuincy_BowManagement);
	Zero(fl_hud_timer);
	Zero(Quincy_Bow_Hex_Array);
	Zero2(b_skill_points_give_at_pap);
	
	g_rocket_particle = PrecacheModel(PARTICLE_ROCKET_MODEL);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	for(int client=1 ; client <= MAXTF2PLAYERS ; client++)
	{
		fl_Quincy_Charge_Multi[client] = 1.0;
		fl_Quincy_Max_Battery[client] = 300.0;
	}
	
}
static void Give_Skill_Points(int client, int pap)
{
	if(!b_skill_points_give_at_pap[client][pap])	//no going back!
	{
		b_skill_points_give_at_pap[client][pap] = true;
		i_Quincy_Skill_Points[client]++;
	}
}
static int Get_Quincy_Pap(int weapon)
{
	int pap = 0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}
public void Activate_Quincy_Bow(int client, int weapon)
{
	if (h_TimerQuincy_BowManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW)
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerQuincy_BowManagement[client]);
			h_TimerQuincy_BowManagement[client] = INVALID_HANDLE;
			
			Create_Quincy_Weapon(client, true);
			
			
			int pap = Get_Quincy_Pap(weapon);
			if(pap!=0)
				Give_Skill_Points(client, pap);
			i_quincy_pap[client] = pap;
			DataPack pack;
			h_TimerQuincy_BowManagement[client] = CreateDataTimer(0.1, Timer_Management_Quincy_Bow, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW)
	{
		int pap = Get_Quincy_Pap(weapon);
		if(pap!=0)
			Give_Skill_Points(client, pap);
		i_quincy_pap[client] = pap;

		
		Create_Quincy_Weapon(client, true);
		
		DataPack pack;
		h_TimerQuincy_BowManagement[client] = CreateDataTimer(0.1, Timer_Management_Quincy_Bow, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Quincy_Bow(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Quincy_Bow_Blade_Loop_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Quincy_Bow_Loop(client);
		}
		else
			Kill_Quincy_Bow_Loop(client);
	}
	else
		Kill_Quincy_Bow_Loop(client);
		
	return Plugin_Continue;
}
static bool b_lockout[MAXTF2PLAYERS+1];
static void Quincy_Bow_Blade_Loop_Logic(int client, int weapon)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	

	if(IsValidEntity(weapon))
	{

		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUINCY_BOW)	//this loop will work if the holder doesn't have it in there hands, but they have it bought
		{

			if(weapon_holding==weapon)	//And this will only work if they have the weapon in there hands and bought
			{
				Create_Quincy_Weapon(client, _);
				float GameTime = GetGameTime();
				int buttons = GetClientButtons(client);
				bool attack = (buttons & IN_ATTACK) != 0;
				bool attack2 = (buttons & IN_ATTACK2) != 0;
				
				float charge_percent = (fl_Quincy_Charge[client] / QUINCY_BOW_BASELINE_BATTERY) * 100.0;
				
				if(fl_hud_timer[client]<GameTime)
				{
					//CPrintToChatAll("charge %.1f", fl_Quincy_Charge[client]);
					fl_hud_timer[client] = GameTime + 0.5;
					Quincy_Bow_Show_Hud(client, charge_percent);
					//Update_Quincy(client);
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
				int flags = Quincy_Bow_Hex_Array[client];
				if(flags & QUINCY_BOW_FAST_CHARGE_4)	//Hyper Barrage
				{
					if(charge_percent>QUINCY_BOW_HYPER_BARRAGE_MINIMUM)
					{
						float angles[3];
						float UserLoc[3];
						
						GetClientEyePosition(client, UserLoc);
						GetClientEyeAngles(client, angles);
						int speed = RoundToCeil(charge_percent / 20.0);
						
						
						
						float distance = GetRandomFloat(float(speed)*10.0, float(speed)*25.0);
	
						float tempAngles[3], endLoc[3], Direction[3];
						
						float base = 180.0 / speed;
						
						float tmp=base;
						
						Handle swingTrace;
						float Vec_offset[3] , vec[3];
								
						b_LagCompNPC_No_Layers = true;
						StartLagCompensation_Base_Boss(client);
						DoSwingTrace_Custom(swingTrace, client, Vec_offset, 9999.9, false, 10.0, false); //infinite range, and (doesn't)ignore walls!	
						FinishLagCompensation_Base_boss();
					
						int target = TR_GetEntityIndex(swingTrace);	
						if(IsValidEnemy(client, target))
						{
							vec = WorldSpaceCenter(target);
							
						}
						else
						{
							TR_GetEndPosition(vec, swingTrace);
						}
						Vec_offset = vec;
								
						delete swingTrace;
						
						UserLoc[2] -= 50.0;
						
						if(speed>QUINCY_BOW_MAX_HYPER_BARRAGE)
							speed = QUINCY_BOW_MAX_HYPER_BARRAGE;
						for(int i=1 ; i<=speed ; i++)
						{	
							if(fl_Quincy_Barrage_Firerate[client][i]<GameTime)
							{
								float firerate = 0.5;
								firerate *= Attributes_Get(weapon, 5, 1.0);
								firerate *= Attributes_Get(weapon, 6, 1.0);
								
								fl_Quincy_Barrage_Firerate[client][i] = GameTime + firerate + GetRandomFloat(firerate/-2.0, firerate/2.0);
								
								fl_Quincy_Charge[client] -= QUINCY_BOW_HYPER_BARRAGE_DRAIN;
								
								
								tempAngles[0] =	tmp*float(i)+180-(base/2);	//180 = Directly upwards, minus half the "gap" angle
								tempAngles[1] = angles[1]-90.0;
								tempAngles[2] = 0.0;
								
								if(tempAngles[0]>=360)
								{
									tempAngles[0] -= 360;
								}
											
								GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
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
				}
				
			}
			else
			{
				Delete_Quincy_Weapon(client);
			}
		}
		else
		{
			Kill_Quincy_Bow_Loop(client);
		}
	}
	else
	{
		Kill_Quincy_Bow_Loop(client);
		
	}
}
static void Quincy_Bow_Fire(int client, int weapon, float charge_percent)
{
	
	int flags = Quincy_Bow_Hex_Array[client];
	
	float speed = 3000.0*(charge_percent/100.0);
	if(b_quincy_battery_special_two[client])
	{
		Quincy_Hyper_Arrow(client, charge_percent, weapon);
		return;
	}
	float damage;
	if(b_quincy_battery_special_one[client])
	{
		damage = 200.0*(charge_percent/100.0);
		damage *= Attributes_Get(weapon, 410, 1.0);
		Penetrating_Shot(client, 10.0, damage, 1500.0);
		fl_Quincy_Charge[client] = 0.0;
		return;
	}

	
	if(flags & QUINCY_BOW_FAST_CHARGE_3)	//removes half charge debuff
	{
		float charge_debuff = (charge_percent / 100.0);
		if(charge_debuff<0.5)
			charge_debuff = 0.5;
		damage = 100.0*charge_debuff*1.5;
		
		speed = 3000.0*(charge_percent/25.0);
		
		
		if(charge_percent>50.0)
		{
			float amt = charge_percent / 25.0;
			
			
			float Vec_offset[3]; 
			Get_Fake_Forward_Vec(client, 100.0, Vec_offset);
			Vec_offset[2] -= 32.5;
			float Npc_Vec[3]; Npc_Vec = WorldSpaceCenter(client);
			
			float ang_Look[3];
			
			MakeVectorFromPoints(Npc_Vec, Vec_offset, ang_Look);
			GetVectorAngles(ang_Look, ang_Look);
			
			float wide_set = 45.0;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing
			
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
				
				speed = 3000.0*(charge_percent/50.0);
				
				speed *= Attributes_Get(weapon, 103, 1.0);
					
				speed *= Attributes_Get(weapon, 104, 1.0);
					
				speed *= Attributes_Get(weapon, 475, 1.0);
				
				if(speed>3000.0)
					speed = 3000.0;
				Quincy_Rocket_Launch(client, weapon, Npc_Vec, endLoc, speed, damage, "raygun_projectile_blue");
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

public void Quincy_Bow_Debug(int client, int weapon, bool crit, int slot)
{
	int flags = Quincy_Bow_Hex_Array[client];
	CPrintToChatAll("flags: %i", flags);
	//i_Quincy_Skill_Points[client]++;
	CPrintToChatAll("points, now total %i", i_Quincy_Skill_Points[client]);
	
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

static void Quincy_Bow_Show_Hud(int client, float charge_percent)
{
	int flags = Quincy_Bow_Hex_Array[client];
	
	
	char HUDText[255] = "";
	
	Format(HUDText, sizeof(HUDText), "%sRaishi Concentration: %.1f％", HUDText, charge_percent);
	
	if(flags & QUINCY_BOW_FAST_CHARGE_3 && !(flags & QUINCY_BOW_FAST_CHARGE_4))
	{
		if(charge_percent>QUINCY_BOW_MULTI_SHOT_MINIMUM)
		{
			float amt = charge_percent / (QUINCY_BOW_MULTI_SHOT_MINIMUM/2.0);
			Format(HUDText, sizeof(HUDText), "%s\nExtra Shoots: [%i]", HUDText, RoundToFloor(amt));
		}
		else
		{
			Format(HUDText, sizeof(HUDText), "%s\nMulti Shot: Inactive [%.1f％/%.1f％]", HUDText, charge_percent, QUINCY_BOW_MULTI_SHOT_MINIMUM);
		}
		
	}
	else if(flags & QUINCY_BOW_FAST_CHARGE_4)
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
	
	if(flags & QUINCY_BOW_BATTERY_3)
	{
		if(charge_percent>QUINCY_BOW_PENETRATING_ARROW_MINIMUM)
		{
			b_quincy_battery_special_one[client] = true;
			Format(HUDText, sizeof(HUDText), "%s\nPenetrating Arrow Ready!", HUDText);
		}
		else
		{
			b_quincy_battery_special_one[client] = false;
			Format(HUDText, sizeof(HUDText), "%s\nPenetrating Arrow Not Ready! [%.1f％/%.1f％]", HUDText, charge_percent, QUINCY_BOW_PENETRATING_ARROW_MINIMUM);
		}
			
	}
	if(flags & QUINCY_BOW_BATTERY_4)
	{
		if(charge_percent>QUINCY_BOW_HYPER_ARROW_MINIMUM)
		{
			b_quincy_battery_special_two[client] = true;
			Format(HUDText, sizeof(HUDText), "%s\nHyper Arrow Ready!", HUDText);
				
		}
		else
		{
			b_quincy_battery_special_two[client] = false;
			Format(HUDText, sizeof(HUDText), "%s\nHyper Arrow Not Ready! [%.1f％/%.1f％]", HUDText, charge_percent, QUINCY_BOW_HYPER_ARROW_MINIMUM);
				
		}
	}
	
	
	
	
	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}
public void Kill_Quincy_Bow_Loop(int client)
{
	if (h_TimerQuincy_BowManagement[client] != INVALID_HANDLE)
	{
		Delete_Quincy_Weapon(client);
		KillTimer(h_TimerQuincy_BowManagement[client]);
		h_TimerQuincy_BowManagement[client] = INVALID_HANDLE;
	}
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
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

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

public void Quincy_Menu(int client, int weapon)
{	
	Menu menu2 = new Menu(Quincy_Menu_Selection);
	int flags = Quincy_Bow_Hex_Array[client];
	
	if(i_Quincy_Skill_Points[client]>0)
	{
		menu2.SetTitle("%t", "Quincy Menu First", i_Quincy_Skill_Points[client]);
		
		

		if(!(flags & QUINCY_BOW_FAST_CHARGE_1))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Fast1");
			menu2.AddItem("1", buffer);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_2))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Fast2");
			menu2.AddItem("1", buffer);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_3))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Fast3");
			menu2.AddItem("1", buffer);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_4))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t","Quincy Fast4");
			menu2.AddItem("1", buffer);
		}
		
		
		if(!(flags & QUINCY_BOW_BATTERY_1))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat1");
			menu2.AddItem("2", buffer);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_2))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat2");
			menu2.AddItem("2", buffer);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_3))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat3");
			menu2.AddItem("2", buffer);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_4))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat4");
			menu2.AddItem("2", buffer);
		}
									
	}					
	else
	{
		menu2.SetTitle("%t", "Quincy Menu Second");
		
		if(!(flags & QUINCY_BOW_FAST_CHARGE_1))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Charge_0");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_2))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Charge_1");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_3))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Charge_2");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_FAST_CHARGE_4))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t","Quincy Charge_3");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t","Quincy Charge_4");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		
		if(!(flags & QUINCY_BOW_BATTERY_1))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat_0");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_2))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat_1");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_3))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat_2");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else if(!(flags & QUINCY_BOW_BATTERY_4))
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat_3");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}
		else
		{
			char buffer[255];
			FormatEx(buffer, sizeof(buffer), "%t", "Quincy Bat_4");
			menu2.AddItem("3", buffer, ITEMDRAW_DISABLED);
		}

	}
	menu2.Display(client, MENU_TIME_FOREVER); // they have 3 seconds.
	
}

static int Quincy_Menu_Selection(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			int flags = Quincy_Bow_Hex_Array[client];
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			
			if(id==3)
			{
				return 0;	//do nothing
			}
			
			i_Quincy_Skill_Points[client]--;
			//CPrintToChatAll("Skill Points Left: %i", i_Quincy_Skill_Points[client]);
			switch(id)
			{
				case 1:	//speed
				{
					EmitSoundToClient(client, QUINCY_BOW_MENU_SOUND1);
					if(!(flags & QUINCY_BOW_FAST_CHARGE_1))
					{
						//CPrintToChatAll("Speed1");
						Quincy_Bow_Hex_Array[client] |= QUINCY_BOW_FAST_CHARGE_1;
						fl_Quincy_Charge_Multi[client] = 1.5;
					}
					else if(!(flags & QUINCY_BOW_FAST_CHARGE_2))
					{
						//CPrintToChatAll("Speed2");
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_FAST_CHARGE_2;
						fl_Quincy_Charge_Multi[client] = 1.75;
					}
					else if(!(flags & QUINCY_BOW_FAST_CHARGE_3))
					{
						//CPrintToChatAll("Speed3");
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_FAST_CHARGE_3;
						fl_Quincy_Charge_Multi[client] = 3.0;
					}
					else if(!(flags & QUINCY_BOW_FAST_CHARGE_4))
					{
						//CPrintToChatAll("Speed4");
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_FAST_CHARGE_4;
						fl_Quincy_Charge_Multi[client] = 4.5;
					}
					else
					{
						fl_Quincy_Charge_Multi[client] = 1.0;
					}
					
					
				}
				case 2:	//battery
				{
					EmitSoundToClient(client, QUINCY_BOW_MENU_SOUND2);
					if(!(flags & QUINCY_BOW_BATTERY_1))
					{
						//CPrintToChatAll("Battery1");
						fl_Quincy_Max_Battery[client] = 800.0;
						Quincy_Bow_Hex_Array[client] |= QUINCY_BOW_BATTERY_1;
					}
					else if(!(flags & QUINCY_BOW_BATTERY_2))
					{
						//CPrintToChatAll("Battery2");
						fl_Quincy_Max_Battery[client] = 1300.0;
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_BATTERY_2;
					}
					else if(!(flags & QUINCY_BOW_BATTERY_3))
					{
						//CPrintToChatAll("Battery3");
						fl_Quincy_Max_Battery[client] = 1800.0;
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_BATTERY_3;
					}
					else if(!(flags & QUINCY_BOW_BATTERY_4))
					{
						//CPrintToChatAll("Battery4");
						fl_Quincy_Max_Battery[client] = 2300.0;
						Quincy_Bow_Hex_Array[client]  |= QUINCY_BOW_BATTERY_4;
					}
					else
					{
						fl_Quincy_Max_Battery[client] = 300.0;
					}
				}
			}
		}
	}
	return 0;	//do nothing
}

static int i_particle[MAXPLAYERS+1][9];
static int i_laser[MAXPLAYERS+1][7];
/*
static int i_charge_particle[MAXPLAYERS+1][2][9];
static int i_charge_laser[MAXPLAYERS+1][2][9];

static int i_battery_particle[MAXPLAYERS+1][2][9];
static int i_battery_laser[MAXPLAYERS+1][2][9];*/

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
	
	int i_particle_right = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);
	
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
	
	int particle_0 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	float part_0[3] = { 0.0, 12.5, 0.0 };
	part_0[0] += offest1;
	part_0[2] += offest2;
	part_0[1] += offest3;
	test(part_0, zero_zero, Direction); //ScaleVector(Direction, -1.0);
	AddVectors(part_0, Direction, part_0);
	
	int particle_1 = ParticleEffectAt(part_0, "", 0.0);
	
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
	
	int particle_6 = ParticleEffectAt(part_1, "", 0.0);
	int particle_6_1 = ParticleEffectAt(part_1_1, "", 0.0);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_6, particle_6_1, "",_, true);
	
	int particle_7 = ParticleEffectAt(part_2, "", 0.0);
	int particle_7_1 = ParticleEffectAt(part_2_1, "", 0.0);
	SetParent(particle_1, particle_7, "",_, true);
	SetParent(particle_7, particle_7_1, "",_, true);
	
	int particle_8 = ParticleEffectAt(part_3, "", 0.0);	//hadle
	int particle_8_1 = ParticleEffectAt(part_3_1, "", 0.0);
	SetParent(particle_1, particle_8, "",_, true);
	SetParent(particle_8, particle_8_1, "",_, true);
	
	

	
	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(viewmodelModel, particle_0, "effect_hand_l",_);
	
	Custom_SDKCall_SetLocalOrigin(i_particle_right, flPos_2);
	SetEntPropVector(i_particle_right, Prop_Data, "m_angRotation", flAng_2); 
	SetParent(viewmodelModel, i_particle_right, "effect_hand_r",_);
	
	i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM));			//inner stick	//base
	
	i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_6_1, r, g, b, f_start, f_end, amp, LASERBEAM));		//inner stick	//base
	
	i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_6, i_particle_right, r, g, b, f_start, f_end, amp, LASERBEAM));		//string	//base
	
	i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_6_1, i_particle_right, r, g, b, f_start, f_end, amp, LASERBEAM));		//string	//base
		
	i_laser[client][4] = EntIndexToEntRef(ConnectWithBeamClient(particle_8, particle_8_1, r, g, b, f_start, f_end, amp, LASERBEAM));			//handle	//base

	i_laser[client][5] = EntIndexToEntRef(ConnectWithBeamClient(particle_7, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM));			//outer stick	//base
	
	i_laser[client][6] = EntIndexToEntRef(ConnectWithBeamClient(particle_7_1, particle_6_1, r, g, b, f_start, f_end, amp, LASERBEAM));		//outer stick	//base

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

static bool Quincy_Blade_BEAM_HitDetected[MAXENTITIES];
 static void Quincy_Hyper_Arrow(int client, float charge_percent, int weapon)
 {
 	float damage = 200.0*(charge_percent/100.0);
 	Client_Shake(client, 0, 50.0, 25.0, 1.5);
 	damage *= Attributes_Get(weapon, 410, 1.0);
 	Quincy_Damage_Trace(client, 20.0, damage);
 	
 }
 static void Quincy_Damage_Trace(int client, float radius, float dmg)
{
	
	EmitSoundToAll(QUINCY_BOW_HYPER_SHOT_SOUND, client, SNDCHAN_STATIC, 100, _, 1.0);
	
	float flPos_2[3];
	float flAng_2[3];
	GetAttachment(client, "effect_hand_r", flPos_2, flAng_2);
	
	float Vec_1[3], Vec_2[3], angles[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, Vec_1);
	Handle trace = TR_TraceRayFilterEx(Vec_1, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
			TR_GetEndPosition(Vec_2, trace);
			CloseHandle(trace);
			static float hullMin[3];
			static float hullMax[3];

			for (int i = 1; i < MAXENTITIES; i++)
			{
				Quincy_Blade_BEAM_HitDetected[i] = false;
			}
			
			hullMin[0] = -radius;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			StartLagCompensation_Base_Boss(client);
			Handle btrace = TR_TraceHullFilterEx(Vec_1, Vec_2, hullMin, hullMax, 1073741824, Quincy_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete btrace;
			FinishLagCompensation_Base_boss();
			if(VIPBuilding_Active())
				dmg *= 0.25;
				
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Quincy_Blade_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					SDKHooks_TakeDamage(victim, client, client, dmg, DMG_CLUB, -1, NULL_VECTOR, Vec_1);	// 2048 is DMG_NOGIB?
				}
			}
			radius *= 2.0;
			int r, g, b;
			r = 15;
			g = 179;
			b = 235;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 60);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
			TE_SetupBeamPoints(flPos_2, Vec_2, Beam_Laser, 0, 0, 0, 1.0, ClampBeamWidth(radius * 0.3 * 1.28), ClampBeamWidth(radius * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 60);
			TE_SetupBeamPoints(flPos_2, Vec_2, Beam_Glow, 0, 0, 0, 1.75, ClampBeamWidth(radius * 0.3 * 1.28), ClampBeamWidth(radius * 0.3 * 1.28), 0, 1.5, glowColor, 0);
			TE_SendToAll(0.0);
	}
	else
	{
		delete trace;
	}

}
static bool Quincy_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Quincy_Blade_BEAM_HitDetected[entity] = true;
	}
	return false;
}
static bool BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
static bool BeamWand_HitDetected[MAXTF2PLAYERS];
static int BeamWand_BuildingHit[MAX_TARGETS_HIT];
static float BeamWand_Targets_Hit[MAXTF2PLAYERS];
static void Penetrating_Shot(int client, float radius, float damage, float range)
{

	EmitSoundToAll(QUINCY_BOW_PENETRATING_SHOT_SOUND, client, SNDCHAN_STATIC, 100, _, 1.0);
	
	float diameter = radius*2.0;
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
		ConformLineDistance(endPoint, startPoint, endPoint, range);
		float lineReduce = radius * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			BeamWand_HitDetected[i] = false;
		}
		
		
		for (int building = 1; building < MAX_TARGETS_HIT; building++)
		{
			BeamWand_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -radius;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BeamWand_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();

		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		BeamWand_Targets_Hit[client] = 1.0;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BeamWand_BuildingHit[building])
			{
				if(IsValidEntity(BeamWand_BuildingHit[building]))
				{
					playerPos = WorldSpaceCenter(BeamWand_BuildingHit[building]);
					
					float damage_force[3];
					damage_force = CalculateDamageForce(vecForward, 10000.0);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BeamWand_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage/BeamWand_Targets_Hit[client]);
					pack.WriteCell(DMG_PLASMA);
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					
					BeamWand_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
				}
				else
					BeamWand_BuildingHit[building] = false;
			}
		}
		
		static float belowBossEyes[3];
		float flAng_2[3];
		GetAttachment(client, "effect_hand_r", belowBossEyes, flAng_2);
		int r, g, b;
		r = 15;
		g = 179;
		b = 235;
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 120);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 120);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 120);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 120);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.55, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 120);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 1.1, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.5, glowColor, 0);
		TE_SendToAll(0.0);
	}
	else
	{
		delete trace;
	}
}
static bool BeamWand_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		entity = Target_Hit_Wand_Detection(client, entity);
		if(0 < entity)
		{
			for(int i=1; i <= (MAX_TARGETS_HIT -1 ); i++)
			{
				if(!BeamWand_BuildingHit[i])
				{
					BeamWand_BuildingHit[i] = entity;
					break;
				}
			}
			
		}
	}
	return false;
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

	int entity = CreateEntityByName("tf_projectile_rocket");
	if(IsValidEntity(entity))
	{
		
		f_projectile_dmg[entity] = dmg;
		
		i_Quincy_wep[entity]=weapon;
		i_Quincy_index[entity]=client;
		
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
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
		Entity_Position = WorldSpaceCenter(target);
		
		int owner = EntRefToEntIndex(i_Quincy_index[entity]);
		int weapon =EntRefToEntIndex(i_Quincy_wep[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		SDKHooks_TakeDamage(target, owner, owner, f_projectile_dmg[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
		
		
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