static float Cryo_M1_Damage = 7.5; //M1 base damage per particle
static int Cryo_M1_Particles = 2;	//Number of particles fired by each M1 attack
static float Cryo_M1_Damage_Pap = 10.0; //M1 base damage per particle (Pack-a-Punch)
static int Cryo_M1_Particles_Pap = 2;	//Number of particles fired by each M1 attack (Pack-a-Punch)
static int Cryo_M1_Particles_Pap2 = 3; //Number of particles fired by each M1 attack (Pack-a-Punch Tier 2)
static float Cryo_M1_Damage_Pap2 = 12.5; //M1 base damage per particle (Pack-a-Punch Tier 2)
static float Cryo_M1_Radius = 100.0;	//Size of each cryo particle, in hammer units
static float Cryo_M1_Spread = 6.0;	//Random spread for particles
static float Cryo_M1_Time = 175.0;	//Time of M1 particles
static float Cryo_M1_Velocity = 500.0;	//Velocity of M1 particles

static float Cryo_M2_Damage = 350.0; //M2 base damage
static float Cryo_M2_FreezeMult = 2.0;	//Amount to multiply damage dealt by M2 to frozen zombies
static float Cryo_M2_Damage_Pap = 450.0; //M2 base damage (Pack-a-Punch)
static float Cryo_M2_FreezeMult_Pap = 3.0;	//Amount to multiply damage dealt by M2 to frozen zombies (Pack-a-Punch)
static float Cryo_M2_Damage_Pap2 = 550.0; //M2 base damage (Pack-a-Punch Tier 2)
static float Cryo_M2_FreezeMult_Pap2 = 4.0;	//Amount to multiply damage dealt by M2 to frozen zombies (Pack-a-Punch Tier 2)
static int Cryo_M2_Cost = 250;	//M2 Cost
static float Cryo_M2_Radius = 400.0;
static float Cryo_M2_Radius_Pap = 500.0;
static float Cryo_M2_Radius_Pap2 = 600.0;

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Cryo_M2_Cooldown = 10.0;	//M2 Cooldown
static float Cryo_M2_Falloff = 0.7;	//Amount to multiply damage dealt by M2 for each zombie it hits, like explosives

static float Cryo_FreezeRequirement = 0.3; //% of target's max health M1 must do in order to trigger the freeze
static float Cryo_FreezeDuration = 4.0; //Duration to freeze zombies when the threshold is surpassed
static float Cryo_SlowDuration = 5.0; //Duration to slow zombies when they are unfrozen
static int Cryo_SlowType[MAXENTITIES] = {0, ...}; //Type of slow applied by the projectile, 0: None, 1: Weak Teslar Slow, 2: Strong Teslar Slow
static int Cryo_SlowType_Zombie[MAXENTITIES] = {0, ...};	//^Ditto, but applied to zombies when they get frozen

static float Cryo_FreezeLevel[MAXENTITIES]={0.0, ...}; //Damage tracker for m1, used to determine how close a zombie is to freezing
static bool Cryo_Frozen[MAXENTITIES]={false, ...}; //Is this zombie frozen?
static bool Cryo_Slowed[MAXENTITIES]={false, ...}; //Is this zombie frozen?
static bool Cryo_IsCryo[MAXENTITIES] = {false, ...}; //Is this entity a cryo projectile?

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};
static bool Cryo_AlreadyHit[MAXENTITIES][MAXENTITIES];

//#define SOUND_WAND_CRYO_M1		"weapons/syringegun_reload_air1.wav"
#define SOUND_WAND_CRYO_M1		"weapons/flame_thrower_bb_end.wav"
#define SOUND_WAND_CRYO_M2		"weapons/icicle_melt_01.wav"
#define SOUND_WAND_CRYO_M2_2	"weapons/breadmonster/gloves/bm_gloves_on.wav"
#define SOUND_WAND_CRYO_M2_3	"weapons/cow_mangler_explosion_charge_05.wav"
#define SOUND_WAND_CRYO_FREEZE	"weapons/icicle_freeze_victim_01.wav"
#define SOUND_WAND_CRYO_SHATTER	"weapons/bottle_break.wav"

#define CRYO_PARTICLE_1			"unusual_icetornado_blue_parent"
#define CRYO_PARTICLE_2			"unusual_icetornado_white_parent"
#define CRYO_PARTICLE_3			"unusual_icetornado_purple_parent"
#define CRYO_FREEZE_PARTICLE	"utaunt_snowring_space_parent"

//TODO: Fix zombie movement on test server so you can see if the freeze actually works
//TODO: Add M2 spell
//TODO: Optimize M1 code so you don't have 3 methods doing a lot of the same shit

void Wand_Cryo_Precache()
{
	PrecacheSound(SOUND_WAND_CRYO_M1);
	PrecacheSound(SOUND_WAND_CRYO_M2);
	PrecacheSound(SOUND_WAND_CRYO_M2_2);
	PrecacheSound(SOUND_WAND_CRYO_M2_3);
	PrecacheSound(SOUND_WAND_CRYO_FREEZE);
	PrecacheSound(SOUND_WAND_CRYO_SHATTER);
}

public void Wand_Cryo_Burst_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_Wand_Cryo(int client, int weapon, bool crit, int slot)
{
	Weapon_Wand_Cryo_Shoot(client, weapon, crit, slot, Cryo_M1_Damage, Cryo_M1_Particles, CRYO_PARTICLE_2, 0);
}

public void Weapon_Wand_Cryo_Pap(int client, int weapon, bool crit, int slot)
{
	Weapon_Wand_Cryo_Shoot(client, weapon, crit, slot, Cryo_M1_Damage_Pap, Cryo_M1_Particles_Pap, CRYO_PARTICLE_3, 1);
}

public void Weapon_Wand_Cryo_Pap2(int client, int weapon, bool crit, int slot)
{
	Weapon_Wand_Cryo_Shoot(client, weapon, crit, slot, Cryo_M1_Damage_Pap2, Cryo_M1_Particles_Pap2, CRYO_PARTICLE_1, 2);
}

public void Weapon_Wand_Cryo_Burst(int client, int weapon, bool &result, int slot)
{
	Cryo_CheckBurst(client, weapon, result, slot, Cryo_M2_Damage, Cryo_M2_FreezeMult, Cryo_M2_Radius);
}

public void Weapon_Wand_Cryo_Burst_Pap(int client, int weapon, bool &result, int slot)
{
	Cryo_CheckBurst(client, weapon, result, slot, Cryo_M2_Damage_Pap, Cryo_M2_FreezeMult_Pap, Cryo_M2_Radius_Pap);
}

public void Weapon_Wand_Cryo_Burst_Pap2(int client, int weapon, bool &result, int slot)
{
	Cryo_CheckBurst(client, weapon, result, slot, Cryo_M2_Damage_Pap2, Cryo_M2_FreezeMult_Pap2, Cryo_M2_Radius_Pap2);
}

public void Cryo_CheckBurst(int client, int weapon, bool &result, int slot, float damage, float freezemult, float radius)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = Cryo_M2_Cost;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Cryo_ActivateBurst(client, weapon, result, slot, damage, freezemult, mana_cost, radius);
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
				
				if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Cryo_ActivateBurst(int client, int weapon, bool &result, int slot, float damage, float freezemult, int mana_cost, float radius)
{
	Ability_Apply_Cooldown(client, slot, Cryo_M2_Cooldown);

	Address address = TF2Attrib_GetByDefIndex(weapon, 410);
	if(address != Address_Null)
	damage *= TF2Attrib_GetValue(address);
	
	Mana_Regen_Delay[client] = GetGameTime() + 1.0;
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
	
	float UserLoc[3], VicLoc[3];
	GetClientAbsOrigin(client, UserLoc);
	//int particle = ParticleEffectAt(UserLoc, "bombinomicon_burningdebris", 4.0);
	int particle = ParticleEffectAt(UserLoc, "xms_snowburst", 4.0);
	particle = ParticleEffectAt(UserLoc, "xms_snowburst_child01", 4.0);
	particle = ParticleEffectAt(UserLoc, "xms_snowburst_child02", 4.0);
	particle = ParticleEffectAt(UserLoc, "xms_snowburst_child03", 4.0);
	
	float TestDMG = damage;
	
	for (int target = 1; target < MAXENTITIES; target++)
	{
		if (IsValidEntity(target))
		{
			char TargName[255];
			GetEntityClassname(target, TargName, sizeof(TargName));
				
			if (StrContains(TargName, "base_boss") != -1)
			{
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VicLoc);
				
				if (GetVectorDistance(UserLoc, VicLoc) <= radius)
				{
					//Code to do damage position and ragdolls
					static float angles[3];
					GetEntPropVector(client, Prop_Send, "m_angRotation", angles);
					float vecForward[3];
					GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
					static float Entity_Position[3];
					Entity_Position = WorldSpaceCenter(target);
					//Code to do damage position and ragdolls
						
					if (Cryo_Frozen[target])
					{
						CreateTimer(0.1, Cryo_Unfreeze, EntIndexToEntRef(target), TIMER_FLAG_NO_MAPCHANGE);
						EmitSoundToAll(SOUND_WAND_CRYO_SHATTER, target);
						SDKHooks_TakeDamage(target, weapon, client, TestDMG * freezemult, DMG_SHOCK, -1, CalculateDamageForce(vecForward, 100000.0), Entity_Position); // 2048 is DMG_NOGIB?
					}
					else
					{
						SDKHooks_TakeDamage(target, weapon, client, TestDMG, DMG_SHOCK, -1, CalculateDamageForce(vecForward, 100000.0), Entity_Position); // 2048 is DMG_NOGIB?
					}
						
					TestDMG *= Cryo_M2_Falloff;
				}
			}
		}
	}
	
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 22.5, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	
	EmitSoundToAll(SOUND_WAND_CRYO_M2, client);
	EmitSoundToAll(SOUND_WAND_CRYO_M2_3, client);
	EmitSoundToAll(SOUND_WAND_CRYO_M2_2, client, _, 80);
}

static void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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

public void Weapon_Wand_Cryo_Shoot(int client, int weapon, bool crit, int slot, float damage, int NumParticles, char ParticleName[255], int SlowType)
{
	int mana_cost;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
	mana_cost = RoundToCeil(TF2Attrib_GetValue(address));
	
	if(mana_cost <= Current_Mana[client])
	{
		Current_Mana[client] -= mana_cost;
		
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		delay_hud[client] = 0.0;
		
		float speed = Cryo_M1_Velocity;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
		
		address = TF2Attrib_GetByDefIndex(weapon, 104);
		if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
		
		address = TF2Attrib_GetByDefIndex(weapon, 475);
		if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
		
		
		float time = Cryo_M1_Time/speed;
		address = TF2Attrib_GetByDefIndex(weapon, 101);
		if(address != Address_Null)
		time *= TF2Attrib_GetValue(address);
		
		address = TF2Attrib_GetByDefIndex(weapon, 102);
		if(address != Address_Null)
		time *= TF2Attrib_GetValue(address);
		
		
		for (int i = 0; i < NumParticles; i++)
		{
			int iRot = CreateEntityByName("func_door_rotating");
			if(iRot == -1) return;
			
			float fPos[3];
			GetClientEyePosition(client, fPos);
			
			DispatchKeyValueVector(iRot, "origin", fPos);
			DispatchKeyValue(iRot, "distance", "99999");
			DispatchKeyValueFloat(iRot, "speed", speed);
			DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
			DispatchSpawn(iRot);
			SetEntityCollisionGroup(iRot, 27);
			
			SetVariantString("!activator");
			AcceptEntityInput(iRot, "Open");
			EmitSoundToAll(SOUND_WAND_CRYO_M1, client, _, 60, _, 0.4, 80);
			Wand_Launch_Cryo(client, iRot, speed, time, damage, weapon, ParticleName, SlowType);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

static void Wand_Launch_Cryo(int client, int iRot, float speed, float time, float damage, int weapon, char ParticleName[255], int SlowType)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return;
	
	float fVel[3], fBuf[3];
	for (int spread = 0; spread < 3; spread++)
	{
		fAng[spread] += GetRandomFloat(-Cryo_M1_Spread, Cryo_M1_Spread);
	}
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;
	
	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);
	
	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_NOCLIP);
	
	
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iCarrier));
	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iRot));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	Projectile_To_Weapon[iCarrier] = weapon;
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = ParticleEffectAt(position, ParticleName, 5.0);
	
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	
	for (int spread = 0; spread < 3; spread++)
	{
		Angles[spread] += GetRandomFloat(-Cryo_M1_Spread, Cryo_M1_Spread);
	}
	
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 0, 0, 0, 0);
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	for (int i = 0; i < MAXENTITIES; i++)
	{
		Cryo_AlreadyHit[i][iCarrier] = false;
		Cryo_AlreadyHit[iCarrier][i] = false;
	}
	
	Cryo_IsCryo[iCarrier] = true;
	Cryo_SlowType[iCarrier] = SlowType;
	
	CreateTimer(0.1, Cryo_Timer, EntIndexToEntRef(iCarrier), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

//SearchDamage is a last resort, it uses zombie_riot.sp's OnGameFrame so you probably shouldn't use this unless all else fails:
/*public void Cryo_SearchDamage()
{
	for (int entity = 1; entity < MAXENTITIES; entity++)
	{
		if (IsValidEntity(entity) && Cryo_IsCryo[entity])
		{
			Cryo_DealDamage(entity);
		}
	}
}*/

//If you use SearchDamage (above), convert this timer to a void method and rename it to Cryo_DealDamage:
public Action Cryo_Timer(Handle CryoDMG, int ref)
{
	int entity = EntRefToEntIndex(ref);
	
	if (IsValidEntity(entity))
	{		
		float ProjLoc[3], VicLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		
		for (int target = 1; target < MAXENTITIES; target++)
		{
			if (IsValidEntity(target))
			{
				char TargName[255];
				GetEntityClassname(target, TargName, sizeof(TargName));
				
				if (StrContains(TargName, "base_boss") != -1 && !Cryo_AlreadyHit[target][entity])
				{
					GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VicLoc);
					
					if (GetVectorDistance(ProjLoc, VicLoc) <= Cryo_M1_Radius)
					{
						//Code to do damage position and ragdolls
						static float angles[3];
						GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
						float vecForward[3];
						GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
						static float Entity_Position[3];
						Entity_Position = WorldSpaceCenter(target);
						//Code to do damage position and ragdolls
						
						SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_SHOCK, -1, CalculateDamageForce(vecForward, 0.0), Entity_Position); // 2048 is DMG_NOGIB?
						//SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_SHOCK, -1); // 2048 is DMG_NOGIB?
						
						if (!Cryo_Frozen[target] && !Cryo_Slowed[target] && HasEntProp(target, Prop_Data, "m_iMaxHealth"))
						{
							Cryo_FreezeLevel[target] += Damage_Projectile[entity];
							float maxHealth = float(GetEntProp(target, Prop_Data, "m_iMaxHealth"));
							if (Cryo_FreezeLevel[target] >= maxHealth * Cryo_FreezeRequirement)
							{
								Cryo_SlowType_Zombie[target] = Cryo_SlowType[entity];
								Cryo_FreezeZombie(target);
							}
						}
						
						Cryo_AlreadyHit[target][entity] = true;
					}
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public void Cryo_FreezeZombie(int zombie)
{
	if (!IsValidEntity(zombie))
	return;
	
	EmitSoundToAll(SOUND_WAND_CRYO_FREEZE, zombie, SNDCHAN_STATIC, 120);
	CClotBody ZNPC = view_as<CClotBody>(zombie);
	ZNPC.m_bFrozen = true;
	Cryo_Frozen[zombie] = true;
	Cryo_FreezeLevel[zombie] = 0.0;
	SetEntityRenderColor(zombie, 0, 0, 255, 255);
	CreateTimer(Cryo_FreezeDuration, Cryo_Unfreeze, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
	float position[3];
	GetEntPropVector(zombie, Prop_Data, "m_vecAbsOrigin", position);
	//Un-comment the following line if you want a particle to appear on frozen zombies:
	//int particle = ParticleEffectAt(position, CRYO_FREEZE_PARTICLE, Cryo_FreezeDuration);
}

public Action Cryo_Unfreeze(Handle Unfreeze, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(zombie))
	return Plugin_Continue;
	
	if (Cryo_Frozen[zombie])
	{
		Cryo_Frozen[zombie] = false;
		Cryo_Slowed[zombie] = true;
		
		CClotBody ZNPC = view_as<CClotBody>(zombie);
		ZNPC.m_bFrozen = false;
		
		switch (Cryo_SlowType_Zombie[zombie])
		{
			case 1:
			{
				ZNPC.m_fLowTeslarDebuff = Cryo_SlowDuration;
			}
			case 2:
			{
				ZNPC.m_fHighTeslarDebuff = Cryo_SlowDuration;
			}
		}
		
		CreateTimer(Cryo_SlowDuration, Cryo_Unslow, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderColor(zombie, 0, 255, 255, 255);
	}
	
	return Plugin_Continue;
}

public Action Cryo_Unslow(Handle Unslow, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(zombie))
	return Plugin_Continue;
	
	Cryo_Slowed[zombie] = false;
	SetEntityRenderColor(zombie, 255, 255, 255, 255);
	
	return Plugin_Continue;
}

public void CleanAllApplied_Cryo(int entity)
{
	Cryo_FreezeLevel[entity] = 0.0;
	Cryo_Frozen[entity] = false;
	Cryo_Slowed[entity] = false;
	Cryo_IsCryo[entity] = false;
	
	for (int i = 0; i < MAXENTITIES; i++)
	{
		Cryo_AlreadyHit[i][entity] = false;
		Cryo_AlreadyHit[entity][i] = false;
	}
}