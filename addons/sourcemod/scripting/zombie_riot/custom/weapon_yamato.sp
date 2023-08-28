#pragma semicolon 1
#pragma newdecls required

//Wonder if mr french will try to learn SP just to recreate the funny sword effects xd

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static bool Handle_on[MAXPLAYERS+1]={false, ...};

Handle TimerYamatoManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_Yamatohuddelay[MAXTF2PLAYERS+1];

static int i_Yamato_Rainsword_Count[MAXTF2PLAYERS+1];
static int g_particleImpactTornado;

static bool b_ATTACK[MAXTF2PLAYERS+1];
static bool b_can_Attack[MAXTF2PLAYERS+1];

static float fl_trace_delay[MAXTF2PLAYERS+1];
static float fl_last_known_loc[MAXTF2PLAYERS+1][3];

static int i_Yamato_Combo[MAXTF2PLAYERS+1];

static float fl_Yamato_Motivation[MAXTF2PLAYERS+1];

static float fl_yamato_stats_timer[MAXTF2PLAYERS+1];




static int g_rocket_particle;

static char gLaser2;

#define YAMATO_MAX_ABILITY_COUNT 2	//how many abilites yamato has

//NOTE: Only increase the ability count IF you added a new ability to EACH one. or you might end up with the 1st main have only 2 sub's but it cycles to a "3rd" which simply doesn't exist and makes the weapon do nothing


#define YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN	1.0	//Self explanitory
#define YAMATO_MAX_RAINSWORD_COUNT 10	//How many maximum swords can exist, blocks the hp scaling from going higher than this

//NOTE: Most of these stats have scaling at "static void Yamato_Update_Stats(int client, int weapon)" Treat these as like "base" stats. gets updated every 2.5 seconds

#define	YAMATO_RAINSWORD_COST_SPAWN	5.0			//how much "motivation" *better name pending* does the player need to have for a rainsword to exist. not consumed
#define YAMATO_BASE_RAINSOWRD_COUNT 2			//base rainsword count, scales on HP, eg: 2+RoundToFloor(MaxHp/200)
#define YAMATO_RAINSWORD_RELOAD_TIME	5.0		//how long for the sword to regenerate after being fired.	float, in seconds	scales on firerate
#define YAMATO_RAINSWORD_DMG	42.5			//dmg
#define YAMATO_RAINSWORD_COST	1.0				//cost of firing one
#define YAMATO_RAINSWORD_GAIN	1.25			//How much motivation the player gains back when they deal damage with the ability

#define YAMATO_SUB_RAINSWORD_DMG 4.6			//damage happens roughly 4 times a second.. THIS IS PER INDIVIDUAL SWORD!!!!
#define YAMATO_SUB_RAINSWORD_PASSIVE_DRAIN	0.1	//How fast the player loses motivation with this ability active. its a passive drain thats constant even while doing dmg. THIS IS PER INDIVIDUAL SWORD!!!!
#define YAMATO_SUB_RAINSWORD_GAIN	0.125		//How much motivation the player gains back when they deal damage while in rainsword second mode. THIS IS PER INDIVIDUAL SWORD!!!!

#define YAMATO_MOUSE2_ATTACK_DELAY 0.1			//A attack delay to the rainsword firing

#define YAMATO_RAINSWORD_SOUND "weapons/shooting_star_shoot.wav"

static int i_Yamato_Max_Rainsword_Count[MAXTF2PLAYERS+1];
static float f_Yamato_Rainsword_Reload_Time[MAXTF2PLAYERS+1];
static float f_Yamato_Rainsword_Damage[MAXTF2PLAYERS+1];
static float f_Yamato_Rainsword_Cost[MAXTF2PLAYERS+1];

static float f_Yamato_Mouse2_attack_delay[MAXTF2PLAYERS+1];

static float f_Yamato_Sub_Rainsword_Dmg[MAXTF2PLAYERS+1];
static float f_Yamato_Sub_Rainsword_Passive_Drain[MAXTF2PLAYERS+1];

static float f_Yamato_Rainsword_Reload_Timer[MAXTF2PLAYERS+1][YAMATO_MAX_RAINSWORD_COUNT+1];
static float f_Spin_To_Win_Throttle[MAXTF2PLAYERS+1][YAMATO_MAX_RAINSWORD_COUNT+1];


public void Npc_OnTakeDamage_Yamato(int client, int damagetype)
{
	if(damagetype & DMG_CLUB) //Only count the usual melee only etc etc etc. 
	{
		fl_Yamato_Motivation[client] += YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN;
	}
}



void Reset_stats_Yamato_Global()	//happens on mapchange!
{
	Zero(fl_trace_delay);
	Zero(TimerYamatoManagement);
	Zero(f_Yamatohuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_Yamato_Rainsword_Count);
	Zero(b_ATTACK);
	Zero(b_can_Attack);
	Zero(i_Yamato_Combo);
	Zero2(f_Yamato_Rainsword_Reload_Timer);
	Zero(fl_Yamato_Motivation);
	Zero(fl_yamato_stats_timer);
	Zero2(f_Spin_To_Win_Throttle);
	Zero(Handle_on);
	Zero(f_Yamato_Mouse2_attack_delay);
	gLaser2= PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheSound(YAMATO_RAINSWORD_SOUND);
	g_rocket_particle = PrecacheModel(PARTICLE_ROCKET_MODEL);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	

}

public void Yamato_Combo_Switch_R(int client, int weapon, bool crit, int slot)
{
	i_Yamato_Combo[client]++;
	if(i_Yamato_Combo[client]>YAMATO_MAX_ABILITY_COUNT)	
	{
		i_Yamato_Combo[client] = 1;
	}
}

/*
public void Yamato_m1(int client, int weapon, bool crit, int slot)
{
	fl_Yamato_Motivation[client] += 5.0;
	CPrintToChatAll("ADDED 5, total: %f",fl_Yamato_Motivation[client]);
}*/

static void Yamato_Mouse2(int client)
{
	switch(i_Yamato_Combo[client])
	{
		case 1:
		{
			if(i_Yamato_Rainsword_Count[client]>1 && b_can_Attack[client])
			{
				b_ATTACK[client] = true;
			}
		}
	}
}

/*
static void Yamato_Primary_M1_Core(int client, int weapon)
{
	
}

static void Yamato_Primary_M2_Core(int client, int weapon, float dmg, float reload, float cost, int amount)	for whenever I make a pap for this wep and wish to make the M1 do something special
{
	
	
}*/

static float fl_Spin_to_win_Angle[MAXTF2PLAYERS+1];
static int i_spin_to_win_throttle[MAXTF2PLAYERS+1];

static void Yamato_Rainsword_Skill_2_Loop(int client)
{
	float UserLoc[3];
	GetClientEyePosition(client, UserLoc);
	UserLoc[2] -= 30.0;
	
	float UserAng[3];
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_Spin_to_win_Angle[client];
	UserAng[2] = 0.0;
	
	float CustomAng = 1.0;
	float distance = 100.0;
	
	fl_Spin_to_win_Angle[client] += 0.75;
	
	if (fl_Spin_to_win_Angle[client] >= 360.0)
	{
		fl_Spin_to_win_Angle[client] = 0.0;
	}
	int testing = i_Yamato_Rainsword_Count[client];
	fl_Yamato_Motivation[client] -= f_Yamato_Sub_Rainsword_Passive_Drain[client];
	if(i_spin_to_win_throttle[client]>2)//Very fast
	{
		i_spin_to_win_throttle[client] = 0;
		for(int m=1 ; m <= testing ; m++)
		{
			float tempAngles[3], endLoc[3], Direction[3], Direction_2[3], endLoc_2[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = CustomAng*(UserAng[1]+(360/testing/2)*float(m*2));
			tempAngles[2] = 0.0;
			
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			GetAngleVectors(tempAngles, Direction_2, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction_2, distance*2);
			AddVectors(UserLoc, Direction_2, endLoc_2);
			
			Spin_To_Win_attack(client, endLoc, endLoc_2, m);
		}
	}
	i_spin_to_win_throttle[client]++;
	return;
}

static float BEAM_Targets_Hit[MAXTF2PLAYERS+1];
static int BEAM_BuildingHit[MAX_TARGETS_HIT];
static bool BEAM_HitDetected[MAXTF2PLAYERS+1];

static void Spin_To_Win_attack(int client, float endVec[3], float endVec_2[3], int ID)
{
	float vecAngles[3];
	
	int colour[4];
	colour[0]=41;
	colour[1]=146;
	colour[2]=158;
	colour[3]=175;
	TE_SetupBeamPoints(endVec, endVec_2, gLaser2, 0, 0, 0, 0.051, 5.0, 0.75, 0, 0.1, colour, 1);
	TE_SendToClient(client);
	
	if(f_Spin_To_Win_Throttle[client][ID]<GetGameTime())
	{
		
		f_Spin_To_Win_Throttle[client][ID] = GetGameTime() + 0.25;
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];

		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			BEAM_HitDetected[i] = false;
		}
		
		
		for (int building = 1; building < MAX_TARGETS_HIT; building++)
		{
			BEAM_BuildingHit[building] = false;
		}
		
		
		float damage = f_Yamato_Sub_Rainsword_Dmg[client];
		
		
		
		hullMin[0] = -25.0;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Handle trace;
		trace = TR_TraceHullFilterEx(endVec, endVec_2, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();
		
		float vecForward[3];
		GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);
		BEAM_Targets_Hit[client] = 1.0;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BEAM_BuildingHit[building])
			{
				if(IsValidEntity(BEAM_BuildingHit[building]))
				{
					
					playerPos = WorldSpaceCenter(BEAM_BuildingHit[building]);
					
					
					float damage_force[3];
					damage_force = CalculateDamageForce(vecForward, 10000.0);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BEAM_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage/BEAM_Targets_Hit[client]);
					pack.WriteCell(DMG_CLUB);	//dmg is club so it works with barbarains
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					
					fl_Yamato_Motivation[client] -= YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN;	//blocks gain on hit.
					fl_Yamato_Motivation[client] += YAMATO_SUB_RAINSWORD_GAIN;
					
					BEAM_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
				}
				else
					BEAM_BuildingHit[building] = false;
			}
		}
	}
}

static void Yamato_Rainsword_Skill_1_Loop(int client)	//this happens every tick!
{
	
	
	//CPrintToChatAll("Oya?: %i",i_Yamato_Rainsword_Count[client]);

	float angles[3];
	float UserLoc[3];
	float LookatVec[3];
	
	GetClientEyePosition(client, UserLoc);
	GetClientEyeAngles(client, angles);
	
	if(fl_trace_delay[client]<=GetGameTime())
	{
		float test_vec[3];
		fl_trace_delay[client] = GetGameTime() + 0.1;
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		
		Handle test = TR_TraceRayFilterEx(UserLoc, angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
		TR_GetEndPosition(test_vec, test);
		CloseHandle(test);
		
		fl_last_known_loc[client]= test_vec;
		
		FinishLagCompensation_Base_boss();
	}
	LookatVec = fl_last_known_loc[client];
	float distance = 120.0;
	
	float tempAngles[3], endLoc[3], Direction[3];
	
	float base = 180.0 / i_Yamato_Rainsword_Count[client];
	
	float tmp=base;
	
	UserLoc[2] -= 50.0;
	
	for(int i=1 ; i<=i_Yamato_Rainsword_Count[client] ; i++)
	{
		
		if(f_Yamato_Rainsword_Reload_Timer[client][i] < GetGameTime())
		{	
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
				
			float vecAngles[3];
				
			MakeVectorFromPoints(UserLoc, endLoc, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
			
			Yamato_Rainsword_Spawn(client, endLoc, i, LookatVec);
		}
	}
		
}

static void Yamato_Rainsword_Spawn(int client, float SpawnVec[3], int num, float TargetVec[3])
{	
	float Range = 115.0;
	
	float endLoc[3], vecAngles[3];
	
	float Direction[3];
	
	MakeVectorFromPoints(SpawnVec, TargetVec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(SpawnVec, Direction, endLoc);
		

	b_can_Attack[client] = true;
	int ID=GetRandomInt(1, i_Yamato_Rainsword_Count[client]);
	if(b_ATTACK[client] && ID==num)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		b_ATTACK[client] = false;
		b_can_Attack[client] = false;
		Yamato_Rocket_Launch(client, weapon, SpawnVec, endLoc, 1400.0, f_Yamato_Rainsword_Damage[client], "raygun_projectile_blue");
		f_Yamato_Rainsword_Reload_Timer[client][ID] = GetGameTime() + f_Yamato_Rainsword_Reload_Time[client];
		fl_Yamato_Motivation[client] -= f_Yamato_Rainsword_Cost[client];
		EmitSoundToClient(client, YAMATO_RAINSWORD_SOUND, _, _, _, _, 0.35);
	}
	int colour[4];
	colour[0]=41;
	colour[1]=146;
	colour[2]=158;
	colour[3]=75;
	TE_SetupBeamPoints(endLoc, SpawnVec, gLaser2, 0, 0, 0, 0.051, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll();
}

static float f_projectile_dmg[MAXENTITIES];

static int i_yamato_index[MAXENTITIES+1];
static int i_yamato_wep[MAXENTITIES+1];

static void Yamato_Rocket_Launch(int client, int weapon, float startVec[3], float targetVec[3], float speed, float dmg, const char[] rocket_particle = "")
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
		
		i_yamato_wep[entity]=weapon;
		i_yamato_index[entity]=client;
		
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
		CreateDataTimer(10.0, Timer_RemoveEntity_Yamato_Projectile, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(EntIndexToEntRef(particle));
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Yamato_RocketExplodePre); 
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Yamato_StartTouch);
	}
	return;
}
public MRESReturn Yamato_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Do. Not.
}
public Action Yamato_StartTouch(int entity, int other)
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
		
		int owner = EntRefToEntIndex(i_yamato_index[entity]);
		int weapon =EntRefToEntIndex(i_yamato_wep[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();

		SDKHooks_TakeDamage(target, owner, owner, f_projectile_dmg[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
		fl_Yamato_Motivation[owner] += YAMATO_RAINSWORD_GAIN;
		
		fl_Yamato_Motivation[owner] -= YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN;	//blocks gain on hit.
		
		
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
public Action Timer_RemoveEntity_Yamato_Projectile(Handle timer, DataPack pack)
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

//Managment code that I tottaly didn't steal from irene...

public void Activate_Yamato(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (TimerYamatoManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAMATO)
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(TimerYamatoManagement[client]);
			TimerYamatoManagement[client] = INVALID_HANDLE;
			DataPack pack;
			TimerYamatoManagement[client] = CreateDataTimer(0.1, Timer_Management_Yamato, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			
			
			
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAMATO)
	{
		DataPack pack;
		TimerYamatoManagement[client] = CreateDataTimer(0.1, Timer_Management_Yamato, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Yamato(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Yamato_Loop_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Yamato(client);
		}
		else
			Kill_Timer_Yamato(client);
	}
	else
		Kill_Timer_Yamato(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Yamato(int client)
{
	if (TimerYamatoManagement[client] != INVALID_HANDLE)
	{
		KillTimer(TimerYamatoManagement[client]);
		TimerYamatoManagement[client] = INVALID_HANDLE;
		SDKUnhook(client, SDKHook_PreThink, Yamato_Activate_Tick);
	}
}


static void Yamato_Update_Stats(int client, int weapon)
{
	float damage = 1.0;
	float speed = 1.0;


	damage *= Attributes_Get(weapon, 1, 1.0);
	
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	//reloadrate of rainsword. also how fast the passive drain is.
	speed *= Attributes_Get(weapon, 5, 1.0);
	speed *= Attributes_Get(weapon, 6, 1.0);
					
	int maxhealth = SDKCall_GetMaxHealth(client);
	float tmp=maxhealth/200.0;
					
	f_Yamato_Rainsword_Damage[client] = YAMATO_RAINSWORD_DMG * damage;
	f_Yamato_Rainsword_Cost[client] = YAMATO_RAINSWORD_COST;
	f_Yamato_Rainsword_Reload_Time[client] = YAMATO_RAINSWORD_RELOAD_TIME * speed;
	i_Yamato_Max_Rainsword_Count[client] = YAMATO_BASE_RAINSOWRD_COUNT + RoundToFloor(tmp);
	
	if(i_Yamato_Max_Rainsword_Count[client]>=YAMATO_MAX_RAINSWORD_COUNT)
	{
		i_Yamato_Max_Rainsword_Count[client] = YAMATO_MAX_RAINSWORD_COUNT;
	}
				
	f_Yamato_Sub_Rainsword_Dmg[client] = YAMATO_SUB_RAINSWORD_DMG * damage;
	f_Yamato_Sub_Rainsword_Passive_Drain[client] = YAMATO_SUB_RAINSWORD_PASSIVE_DRAIN * speed;
}
public void Yamato_Loop_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAMATO) //Double check to see if its good or bad :(
		{	
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(f_Yamatohuddelay[client] < GetGameTime())
			{
				
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{	
					switch(i_Yamato_Combo[client])
					{	
						case 1:
						{
							PrintHintText(client,"Skill: Summoned Swords | Motivation: [%i]",RoundToFloor(fl_Yamato_Motivation[client]));	
						}
						case 2:
						{
							PrintHintText(client,"Skill: Spiral Swords | Motivation: [%i]",RoundToFloor(fl_Yamato_Motivation[client]));
						}
					}
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				}			
				f_Yamatohuddelay[client] = GetGameTime() + 0.5;
			}
			
			if(weapon_holding == weapon)
			{
				if(Handle_on[client])
				{
					KillTimer(Revert_Weapon_Back_Timer[client]);
				}
				else
				{
					SDKHook(client, SDKHook_PreThink, Yamato_Activate_Tick);
					
					//CPrintToChatAll("HOOKED");
					i_Yamato_Rainsword_Count[client] = 0;
					i_Yamato_Combo[client] = 1;
					
				}
				Revert_Weapon_Back_Timer[client] = CreateTimer(0.2, Yamato_Reset_Wep, client, TIMER_FLAG_NO_MAPCHANGE);
				Handle_on[client] = true;
				if(fl_yamato_stats_timer[client]<=GetGameTime())
				{
					fl_yamato_stats_timer[client] = GetGameTime() + 2.5;
					Yamato_Update_Stats(client, weapon);
				}	
			}
			
			if(fl_Yamato_Motivation[client]>YAMATO_RAINSWORD_COST_SPAWN)
			{
				float test = fl_Yamato_Motivation[client] / YAMATO_RAINSWORD_COST_SPAWN;
				int what = RoundToFloor(test);
				
				i_Yamato_Rainsword_Count[client] = what;
				if(i_Yamato_Rainsword_Count[client]>i_Yamato_Max_Rainsword_Count[client])
				{
					i_Yamato_Rainsword_Count[client] = i_Yamato_Max_Rainsword_Count[client];
				}
			}
		}
		else
		{
			Kill_Timer_Yamato(client);
		}
	}
	else
	{
		Kill_Timer_Yamato(client);
	}
}

public Action Yamato_Reset_Wep(Handle cut_timer, int client)
{

	Handle_on[client] = false;

	//CPrintToChatAll("UNHOOKED");
	SDKUnhook(client, SDKHook_PreThink, Yamato_Activate_Tick);
	return Plugin_Handled;
}

public Action Yamato_Activate_Tick(int client)
{	
	if(i_Yamato_Rainsword_Count[client]>1)	//don't allow these abilities to trigger when you only have 1 rainsword
	{
		switch(i_Yamato_Combo[client])
		{
			case 1:
			{
				Yamato_Rainsword_Skill_1_Loop(client);
			}
			case 2:
			{
				Yamato_Rainsword_Skill_2_Loop(client);
			}
		}
	}
	
	bool M2Down = (GetClientButtons(client) & IN_ATTACK2) != 0;
	
	if(M2Down && f_Yamato_Mouse2_attack_delay[client] < GetGameTime())
	{
		f_Yamato_Mouse2_attack_delay[client] = GetGameTime() + YAMATO_MOUSE2_ATTACK_DELAY;
		Yamato_Mouse2(client);
	}
	
	return Plugin_Continue;
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