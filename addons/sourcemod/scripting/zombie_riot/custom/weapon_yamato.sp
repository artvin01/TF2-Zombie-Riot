#pragma semicolon 1
#pragma newdecls required

Handle TimerYamatoManagement[MAXPLAYERS+1] = {null, ...};
static float f_Yamatohuddelay[MAXPLAYERS+1];

static int i_Yamato_Rainsword_Count[MAXPLAYERS+1];
static int g_particleImpactTornado;

static bool b_mouse2_held[MAXPLAYERS+1];

static int b_Yamato_State[MAXPLAYERS+1];

static float fl_Yamato_Motivation[MAXPLAYERS+1];

static float fl_yamato_stats_timer[MAXPLAYERS+1];

#define YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN	1.0	//Self explanitory
#define YAMATO_MAX_RAINSWORD_COUNT 10	//How many maximum swords can exist, blocks the hp scaling from going higher than this

//NOTE: Most of these stats have scaling at "static void Yamato_Update_Stats(int client, int weapon)" Treat these as like "base" stats.

#define	YAMATO_RAINSWORD_COST_SPAWN	5.0			//how much "motivation" *better name pending* does the player need to have for a rainsword to exist. not consumed
#define YAMATO_BASE_RAINSOWRD_COUNT 2			//base rainsword count, scales on HP, eg: 2+RoundToFloor(MaxHp/200)
#define YAMATO_RAINSWORD_RELOAD_TIME	5.0		//how long for the sword to regenerate after being fired.	float, in seconds	scales on firerate
#define YAMATO_RAINSWORD_DMG	42.5			//dmg
#define YAMATO_RAINSWORD_COST	1.0				//cost of firing one
#define YAMATO_RAINSWORD_GAIN	1.25			//How much motivation the player gains back when they deal damage with the ability

#define YAMATO_SUB_RAINSWORD_DMG 6.0			//damage happens roughly 4 times a second.. THIS IS PER INDIVIDUAL SWORD!!!!
#define YAMATO_SUB_RAINSWORD_PASSIVE_DRAIN	0.3	//How fast the player loses motivation with this ability active. its a passive drain thats constant even while doing dmg. THIS IS PER INDIVIDUAL SWORD!!!!
#define YAMATO_SUB_RAINSWORD_GAIN	0.3125			//How much motivation the player gains back when they deal damage while in rainsword second mode. THIS IS PER INDIVIDUAL SWORD!!!!

#define YAMATO_MOUSE2_ATTACK_DELAY 0.1			//A attack delay to the rainsword firing

#define YAMATO_MAX_MOTIVATION	60.0

#define YAMATO_RAINSWORD_SOUND "weapons/shooting_star_shoot.wav"

static int i_Yamato_Max_Rainsword_Count[MAXPLAYERS+1];
static float f_Yamato_Rainsword_Reload_Time[MAXPLAYERS+1];
static float f_Yamato_Rainsword_Damage[MAXPLAYERS+1];
static float f_Yamato_Rainsword_Cost[MAXPLAYERS+1];

static float f_Yamato_Mouse2_attack_delay[MAXPLAYERS+1];

static float f_Yamato_Sub_Rainsword_Dmg[MAXPLAYERS+1];
static float f_Yamato_Sub_Rainsword_Passive_Drain[MAXPLAYERS+1];

static float f_Yamato_Rainsword_Reload_Timer[MAXPLAYERS+1][YAMATO_MAX_RAINSWORD_COUNT+1];
static float fl_Sprial_Trace_Throttle[MAXPLAYERS+1][YAMATO_MAX_RAINSWORD_COUNT+1];

enum struct Yamato_Blades
{
	int index;

	float Offset_Times;

	void Create(float Loc[3], float Angles[3], int client)
	{

		int prop = CreateEntityByName("prop_physics_override");
	
		if (IsValidEntity(prop))
		{
			this.Offset_Times = GetGameTime()+0.25;
			DispatchKeyValue(prop, "model", RUINA_POINT_MODEL);
			
			DispatchKeyValue(prop, "modelscale", "0.01");
			

			int ModelApply = ApplyCustomModelToWandProjectile(prop, RUINA_CUSTOM_MODELS_2, 1.5, "");
			if(IsValidEntity(ModelApply))
			{
				SetEntPropEnt(ModelApply, Prop_Send, "m_hOwnerEntity", client);
				float angles[3];
				Angles = angles; //????
				GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
				angles[1]+=180.0;
				TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
				SetVariantInt(RUINA_ZANGETSU);
				AcceptEntityInput(ModelApply, "SetBodyGroup");
				if(!LastMann)
					SDKHook(ModelApply, SDKHook_SetTransmit, SetTransmitBlades);
			}
			
			DispatchKeyValue(prop, "solid", "0"); 
			
			DispatchSpawn(prop);
			
			ActivateEntity(prop);
			
			//SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
			
			MakeObjectIntangeable(prop);

			TeleportEntity(prop, Loc, NULL_VECTOR, NULL_VECTOR);

			//CPrintToChatAll("Sword created: %i", prop);
			this.index = EntIndexToEntRef(prop);
			
		}

	}
	void Check()
	{
		if(this.Offset_Times < GetGameTime())
		{
			int entity = EntRefToEntIndex(this.index);
			if(IsValidEntity(entity))
				this.Delete();
		}
	}
	void Move(int client, float loc[3], float Look_Vec[3], int ID)
	{
		float GameTime = GetGameTime();

		int entity = EntRefToEntIndex(this.index);
		
		float Ang[3];
		MakeVectorFromPoints(loc, Look_Vec, Ang);
		GetVectorAngles(Ang, Ang);
		if(f_Yamato_Rainsword_Reload_Timer[client][ID] > GameTime)
		{
			if(IsValidEntity(entity))
				this.Delete();
			
			return;
		}
		else
		{
			if(!IsValidEntity(entity))
			{
				this.Create(loc, Ang, client);
				return;
			}
				
		}
		

		this.Offset_Times = GameTime + 0.25;

	

		float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
		
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Entity_Loc);
		
		MakeVectorFromPoints(Entity_Loc, loc, vecView);
		GetVectorAngles(vecView, vecView);
		
		float dist = GetVectorDistance(Entity_Loc, loc);

		GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	
		Entity_Loc[0]+=vecFwd[0] * dist;
		Entity_Loc[1]+=vecFwd[1] * dist;
		Entity_Loc[2]+=vecFwd[2] * dist;
		
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecFwd);
		
		SubtractVectors(Entity_Loc, vecFwd, vecVel);
		ScaleVector(vecVel, 10.0);

		if(!b_Yamato_State[client])
			Ang[2]=90.0;
		else
			Ang[2]=0.0;

		TeleportEntity(entity, NULL_VECTOR, Ang, vecVel);
	}
	void Delete()
	{
		int sword = EntRefToEntIndex(this.index);
		if(IsValidEntity(sword))
			RemoveEntity(sword);
		
		this.index = INVALID_ENT_REFERENCE;

	}
}

static Action SetTransmitBlades(int entity, int target)
{
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == target)
		return Plugin_Continue;

	return Plugin_Handled;
}

static Yamato_Blades struct_Yamato_Blades[MAXPLAYERS][YAMATO_MAX_RAINSWORD_COUNT+1];

public void Npc_OnTakeDamage_Yamato(int client, int damagetype)
{
	if(damagetype & DMG_CLUB) //Only count the usual melee only etc etc etc. 
	{
		fl_Yamato_Motivation[client] += YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN;
	}
}



void Reset_stats_Yamato_Global()	//happens on mapchange!
{
	Zero(TimerYamatoManagement);
	Zero(f_Yamatohuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_Yamato_Rainsword_Count);
	Zero(b_mouse2_held);
	Zero(b_Yamato_State);
	Zero2(f_Yamato_Rainsword_Reload_Timer);
	Zero(fl_Yamato_Motivation);
	Zero(fl_yamato_stats_timer);
	Zero2(fl_Sprial_Trace_Throttle);
	Zero(f_Yamato_Mouse2_attack_delay);
	PrecacheSound(YAMATO_RAINSWORD_SOUND);
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	

}

public void Yamato_Combo_Switch_R(int client, int weapon, bool crit, int slot)
{
	Yamato_Update_Stats(client, weapon);

	b_Yamato_State[client] = !b_Yamato_State[client];

	//for(int i=0 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i ++)
	//{
	//	struct_Yamato_Blades[client][i].Delete();
	//}
}


public void Yamato_Start_M2(int client, int weapon, bool crit, int slot)
{
	if(!b_Yamato_State[client])
		return;

	if(i_Yamato_Rainsword_Count[client] < 1)
		return;
	
	Yamato_Update_Stats(client, weapon);

	b_mouse2_held[client] = true;

	float GameTime = GetGameTime();

	if(f_Yamato_Mouse2_attack_delay[client] > GameTime)
		return;

	Yamato_Rainsword_Skill_1_Loop(client);	//to make sure the weapon doesn't feel "slugish" do an update when the user can fire a sword and fires it.

}

static float fl_spiral_angle[MAXPLAYERS+1];

static void Yamato_Rainsword_Skill_2_Loop(int client)
{
	float UserLoc[3];
	GetClientEyePosition(client, UserLoc);
	UserLoc[2] -= 30.0;
	
	float UserAng[3];
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_spiral_angle[client];
	UserAng[2] = 0.0;
	
	float CustomAng = 1.0;
	float distance = 100.0;
	
	fl_spiral_angle[client] += 5.0;
	
	if (fl_spiral_angle[client] >= 360.0)
	{
		fl_spiral_angle[client] = 0.0;
	}

	int testing = i_Yamato_Rainsword_Count[client];
	fl_Yamato_Motivation[client] -= f_Yamato_Sub_Rainsword_Passive_Drain[client];

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

	for(int i= 1 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i++)
	{
		struct_Yamato_Blades[client][i].Check();
	}

	return;
}
static int BEAM_BuildingHit[MAX_TARGETS_HIT];

static void Spin_To_Win_attack(int client, float endVec[3], float endVec_2[3], int ID)
{
	float vecAngles[3];
	/*
	int colour[4];
	colour[0]=255;
	colour[1]=0;
	colour[2]=0;
	colour[3]=255;
	TE_SetupBeamPoints(endVec, endVec_2, gLaser2, 0, 0, 0, 0.051, 5.0, 0.75, 0, 0.1, colour, 1);
	TE_SendToClient(client);*/

	struct_Yamato_Blades[client][ID].Move(client, endVec, endVec_2, ID);

	float GameTime = GetGameTime();

	if(f_Yamato_Rainsword_Reload_Timer[client][ID] > GameTime)
		return;
	if(fl_Sprial_Trace_Throttle[client][ID] > GameTime)
		return;

		
	fl_Sprial_Trace_Throttle[client][ID] = GetGameTime() + 0.25;
	static float hullMin[3];
	static float hullMax[3];

	Zero(BEAM_BuildingHit);
	
	float damage = f_Yamato_Sub_Rainsword_Dmg[client];
	
	Set_HullTrace(25.0, hullMin, hullMax);
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace;
	trace = TR_TraceHullFilterEx(endVec, endVec_2, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	FinishLagCompensation_Base_boss();
	
	float vecForward[3];
	GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);
	int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon_active))
		weapon_active = 0;

	float BEAM_Targets_Hit = 1.0;
	for (int target = 0; target < MAX_TARGETS_HIT; target++)
	{
		int Victim = BEAM_BuildingHit[target];
		if(!Victim)
			continue;

		if(!IsValidEntity(Victim))
			continue;
		
		float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
		SDKHooks_TakeDamage(Victim, client, client, damage*BEAM_Targets_Hit, DMG_CLUB, weapon_active, damage_force);

		
		fl_Yamato_Motivation[client] -= YAMATO_ON_MELEE_HIT_MOTIVATION_GAIN;	//blocks gain on hit.
		fl_Yamato_Motivation[client] += YAMATO_SUB_RAINSWORD_GAIN;
		
		BEAM_Targets_Hit *= LASER_AOE_DAMAGE_FALLOFF;
	}
}

static void Yamato_Rainsword_Skill_1_Loop(int client)
{

	float angles[3];
	float UserLoc[3];
	float LookatVec[3];
	
	GetClientEyePosition(client, UserLoc);
	GetClientEyeAngles(client, angles);

	float GameTime = GetGameTime();
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	
	Handle look_trace = TR_TraceRayFilterEx(UserLoc, angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	TR_GetEndPosition(LookatVec, look_trace);
	int i_entity_hit = TR_GetEntityIndex(look_trace);
	delete look_trace;
	
	FinishLagCompensation_Base_boss();

	float distance = 120.0;
	
	float tempAngles[3], endLoc[3], Direction[3];
	
	float base = 180.0 / i_Yamato_Rainsword_Count[client];
	
	float tmp=base;
	
	UserLoc[2] -= 50.0;
	
	for(int i=1 ; i<=i_Yamato_Rainsword_Count[client] ; i++)
	{
		
		if(f_Yamato_Rainsword_Reload_Timer[client][i] < GameTime)
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
			
			Yamato_Rainsword_Spawn(client, endLoc, i, LookatVec, i_entity_hit);
		}
	}
	for(int i= 1 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i++)
	{
		struct_Yamato_Blades[client][i].Check();
	}
		
}

static void Yamato_Rainsword_Spawn(int client, float SpawnVec[3], int num, float TargetVec[3], int i_entity_hit)
{	
	float Range = 115.0;
	
	float endLoc[3], vecAngles[3];
	
	float Direction[3];
	
	MakeVectorFromPoints(SpawnVec, TargetVec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(SpawnVec, Direction, endLoc);
		

	float GameTime = GetGameTime();
	if(b_mouse2_held[client] && f_Yamato_Mouse2_attack_delay[client] < GameTime)
	{
		f_Yamato_Mouse2_attack_delay[client] = GameTime + 0.2;
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		Fire_Blade(client, weapon, num, SpawnVec, endLoc, i_entity_hit);
	}

	struct_Yamato_Blades[client][num].Move(client, SpawnVec, endLoc, num);

	/*
	int colour[4];
	colour[0]=255;
	colour[1]=0;
	colour[2]=0;
	colour[3]=2555;
	TE_SetupBeamPoints(endLoc, SpawnVec, gLaser2, 0, 0, 0, 0.051, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll();
	*/
}
static bool Fire_Blade(int client, int weapon, int Num, float SpawnVec[3], float endLoc[3], int i_entity_hit)
{
	float GameTime = GetGameTime();
	if(f_Yamato_Rainsword_Reload_Timer[client][Num] > GameTime)
		return false;

	Yamato_Rocket_Launch(client, weapon, SpawnVec, endLoc, 1400.0, f_Yamato_Rainsword_Damage[client], "raygun_projectile_blue", i_entity_hit);
	f_Yamato_Rainsword_Reload_Timer[client][Num] = GameTime + f_Yamato_Rainsword_Reload_Time[client];
	fl_Yamato_Motivation[client] -= f_Yamato_Rainsword_Cost[client];
	EmitSoundToClient(client, YAMATO_RAINSWORD_SOUND, _, _, _, _, 0.35);

	

	return true;
}

static void Yamato_Rocket_Launch(int client, int weapon, float startVec[3], float targetVec[3], float speed, float dmg, const char[] rocket_particle = "", int i_entity_hit)
{

	float Angles[3];
	MakeVectorFromPoints(startVec, targetVec, Angles);
	GetVectorAngles(Angles, Angles);

	int projectile = Wand_Projectile_Spawn(client, speed, 30.0, dmg, 0, weapon, rocket_particle, Angles, false , startVec);
	WandProjectile_ApplyFunctionToEntity(projectile, Yamato_Projectile_Touch);
	int ModelApply = ApplyCustomModelToWandProjectile(projectile, RUINA_CUSTOM_MODELS_2, 1.5, "");
	if(IsValidEntity(ModelApply))
	{
		float angles[3];
		GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
		angles[1]+=180.0;
		TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
		SetVariantInt(RUINA_ZANGETSU);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}
	float Homing_Power = 9.0;
	float Homing_Angle = 90.0;
	if(!IsValidEntity(i_entity_hit))
	{
		return;
	}
		

	Initiate_HomingProjectile(projectile,
	client,
	Homing_Angle,			// float lockonAngleMax,
	Homing_Power,				//float homingaSec,
	true,				// bool LockOnlyOnce,
	true,				// bool changeAngles,
	Angles
	);			// float AnglesInitiate[3]);
}


static void Yamato_Projectile_Touch(int entity, int target)
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
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, PushforceDamage, Entity_Position);	// 2048 is DMG_NOGIB?

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
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		RemoveEntity(entity);
	}
}

public void Activate_Yamato(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (TimerYamatoManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAMATO)
		{
			//Is the weapon it again?
			//Yes?
			for(int i=0 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i ++)
			{
				struct_Yamato_Blades[client][i].Delete();
			}
			b_Yamato_State[client] = true;
			delete TimerYamatoManagement[client];
			TimerYamatoManagement[client] = null;
			DataPack pack;
			TimerYamatoManagement[client] = CreateDataTimer(0.1, Timer_Management_Yamato, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));	
			Yamato_Update_Stats(client, weapon);
			
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_YAMATO)
	{
		for(int i=0 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i ++)
		{
		struct_Yamato_Blades[client][i].Delete();
		}
		DataPack pack;
		b_Yamato_State[client] = true;
		TimerYamatoManagement[client] = CreateDataTimer(0.1, Timer_Management_Yamato, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		Yamato_Update_Stats(client, weapon);
	}
}

public Action Timer_Management_Yamato(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		for(int i=0 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i ++)
		{
			struct_Yamato_Blades[client][i].Delete();
		}
		TimerYamatoManagement[client] = null;
		return Plugin_Stop;
	}	

	Yamato_Loop_Logic(client, weapon);

	return Plugin_Continue;
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
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
	if(weapon_holding == weapon)
	{
		float GameTime = GetGameTime();
		if(fl_Yamato_Motivation[client] > YAMATO_MAX_MOTIVATION)
			fl_Yamato_Motivation[client] = YAMATO_MAX_MOTIVATION;
		if(f_Yamatohuddelay[client] < GameTime)
		{
			char HUDText[255] = "Skill:";
			if(b_Yamato_State[client])
			{
				Format(HUDText, sizeof(HUDText), "%s Summoned Swords |", HUDText);
			}
			else
			{
				Format(HUDText, sizeof(HUDText), "%s Spiral Swords |", HUDText);
			}
			Format(HUDText, sizeof(HUDText), "%s Motivation: [%i/%i]", HUDText, RoundToFloor(fl_Yamato_Motivation[client]), RoundToFloor(YAMATO_MAX_MOTIVATION));
			PrintHintText(client, HUDText);
			
			f_Yamatohuddelay[client] = GameTime + 0.5;
		}

		bool M2Down = (GetClientButtons(client) & IN_ATTACK2) != 0;
		
		if(!M2Down && b_mouse2_held[client])
		{
			b_mouse2_held[client] = false;
		}

		if(i_Yamato_Rainsword_Count[client]>1)	//don't allow these abilities to trigger when you only have 1 rainsword
		{
			if(b_Yamato_State[client])
			{
				Yamato_Rainsword_Skill_1_Loop(client);
			}
			else
			{
				Yamato_Rainsword_Skill_2_Loop(client);
			}
		}
		else
		{
			Yamato_Update_Stats(client, weapon);
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
		for(int i=0 ; i <= YAMATO_MAX_RAINSWORD_COUNT ; i ++)
		{
			struct_Yamato_Blades[client][i].Delete();
		}
	}
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=0; i < (MAX_TARGETS_HIT ); i++)
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