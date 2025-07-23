#pragma semicolon 1
#pragma newdecls required

static float Cryo_M1_Damage = 14.0; //M1 base damage per particle
static int Cryo_M1_Particles = 2;	//Number of particles fired by each M1 attack
static float Cryo_M1_Damage_Pap = 28.0; //M1 base damage per particle (Pack-a-Punch)
static int Cryo_M1_Particles_Pap = 2;	//Number of particles fired by each M1 attack (Pack-a-Punch)
static int Cryo_M1_Particles_Pap2 = 3; //Number of particles fired by each M1 attack (Pack-a-Punch Tier 2)
static float Cryo_M1_Damage_Pap2 = 40.0; //M1 base damage per particle (Pack-a-Punch Tier 2)
static float Cryo_M1_Spread = 6.0;	//Random spread for particles
static float Cryo_M1_Time = 175.0;	//Time of M1 particles
static float Cryo_M1_Velocity = 1250.0;	//Velocity of M1 particles
static float Cryo_M1_ReductionScale = 0.66; //Amount to multiply M1 damage each time it hits a zombie

static float Cryo_M2_Damage = 450.0; //M2 base damage
static float Cryo_M2_FreezeMult = 2.0;	//Amount to multiply damage dealt by M2 to frozen zombies
static float Cryo_M2_Damage_Pap = 550.0; //M2 base damage (Pack-a-Punch)
static float Cryo_M2_FreezeMult_Pap = 3.0;	//Amount to multiply damage dealt by M2 to frozen zombies (Pack-a-Punch)
static float Cryo_M2_Damage_Pap2 = 650.0; //M2 base damage (Pack-a-Punch Tier 2)
static float Cryo_M2_FreezeMult_Pap2 = 4.0;	//Amount to multiply damage dealt by M2 to frozen zombies (Pack-a-Punch Tier 2)
static int Cryo_M2_Cost = 100;	//M2 Cost
static float Cryo_M2_Radius = 400.0;
static float Cryo_M2_Radius_Pap = 500.0;
static float Cryo_M2_Radius_Pap2 = 600.0;

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Cryo_M2_Cooldown = 15.0;	//M2 Cooldown

//static float Cryo_FreezeRequirement = 0.30; //% of target's max health M1 must do in order to trigger the freeze
static float Cryo_FreezeDuration = 1.5; //Duration to freeze zombies when the threshold is surpassed
static float Cryo_FreezeDuration_Pap1 = 2.0; //Duration to freeze zombies when the threshold is surpassed
static float Cryo_FreezeDuration_Pap2 = 2.5; //Duration to freeze zombies when the threshold is surpassed
static float Cryo_SlowDuration = 8.0; //Duration to slow zombies when they are unfrozen
static int Cryo_SlowType[MAXENTITIES] = {0, ...}; //Type of slow applied by the projectile, 0: None, 1: Weak Teslar Slow, 2: Strong Teslar Slow
static int Cryo_SlowType_Zombie[MAXENTITIES] = {0, ...};	//^Ditto, but applied to zombies when they get frozen

static float Cryo_FreezeLevel[MAXENTITIES]={0.0, ...}; //Damage tracker for m1, used to determine how close a zombie is to freezing
static bool Cryo_Frozen[MAXENTITIES]={false, ...}; //Is this zombie frozen?
static bool Cryo_Slowed[MAXENTITIES]={false, ...}; //Is this zombie frozen?
static bool Cryo_IsCryo[MAXENTITIES] = {false, ...}; //Is this entity a cryo projectile?




#define COLLISION_DETECTION_MODEL_BIG	"models/props_junk/wood_crate001a.mdl"

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

void Wand_Cryo_Precache()
{
	PrecacheSound(SOUND_WAND_CRYO_M1);
	PrecacheSound(SOUND_WAND_CRYO_M2);
	PrecacheSound(SOUND_WAND_CRYO_M2_2);
	PrecacheSound(SOUND_WAND_CRYO_M2_3);
	PrecacheSound(SOUND_WAND_CRYO_FREEZE);
	PrecacheSound(SOUND_WAND_CRYO_SHATTER);
	PrecacheModel(COLLISION_DETECTION_MODEL_BIG);
	PrecacheModel("models/props_moonbase/moon_gravel_crystal_blue.mdl");
}

void ResetFreeze(int entity)
{
	Cryo_FreezeLevel[entity] = 0.0;
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
				Rogue_OnAbilityUse(client, weapon);
				Cryo_ActivateBurst(client, weapon, result, slot, damage, freezemult, mana_cost, radius);
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
				
				if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Cryo_ActivateBurst(int client, int weapon, bool &result, int slot, float damage, float freezemult, int mana_cost, float radius)
{
	Ability_Apply_Cooldown(client, slot, Cryo_M2_Cooldown);

	damage *= Attributes_Get(weapon, 410, 1.0);
	
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
	
	float UserLoc[3];
	GetClientAbsOrigin(client, UserLoc);
	//int particle = ParticleEffectAt(UserLoc, "bombinomicon_burningdebris", 4.0);
	ParticleEffectAt(UserLoc, "xms_snowburst", 4.0);
	ParticleEffectAt(UserLoc, "xms_snowburst_child01", 4.0);
	ParticleEffectAt(UserLoc, "xms_snowburst_child02", 4.0);
//	particle = ParticleEffectAt(UserLoc, "xms_snowburst_child03", 4.0);
		
	//We check twice, we first want to prioritise frozen targets!
	i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_PLASMA_DAMAGE;
	i_ExplosiveProjectileHexArray[weapon] |= EP_IS_ICE_DAMAGE;

	Explode_Logic_Custom(damage, client, client, weapon, UserLoc, radius, _, _, false, _, _, _, CryoWandHitM2, CryoWandHitM2Pre);
	
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 22.5, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, 0.33, 12.0, 6.1, 1, radius * 2.0);
	
	EmitSoundToAll(SOUND_WAND_CRYO_M2, client);
	EmitSoundToAll(SOUND_WAND_CRYO_M2_3, client);
	EmitSoundToAll(SOUND_WAND_CRYO_M2_2, client, _, 80);
}

float f_HealthBeforeHurt[MAXENTITIES];

void CryoWandHitM2Pre(int entity, int victim, float damage, int weapon)
{
	if (!Cryo_Frozen[victim])
	{
		f_HealthBeforeHurt[victim] = float(GetEntProp(victim, Prop_Data, "m_iHealth"));
	}
}

void CryoWandHitM2(int entity, int victim, float damage, int weapon)
{
	if (Cryo_Frozen[victim])
	{
		float UserLoc[3], VicLoc[3];
		GetClientAbsOrigin(entity, UserLoc);
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", VicLoc);
		CreateTimer(0.1, Cryo_Unfreeze, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		EmitSoundToAll(SOUND_WAND_CRYO_SHATTER, victim);
		float ExplodePos[3]; CalculateExplosiveDamageForce(UserLoc, VicLoc, 1500.0, ExplodePos);
		SDKHooks_TakeDamage(victim, weapon, entity, damage * Cryo_M2_FreezeMult_Pap2, DMG_PLASMA, -1, ExplodePos, VicLoc, _, ZR_DAMAGE_ICE); // 2048 is DMG_NOGIB?
	}
	else
	{
		if (!Cryo_Slowed[victim])
		{
			Elemental_AddCyroDamage(victim, entity, RoundFloat(damage), Cryo_SlowType[entity]);
		}
	}
}

public void Weapon_Wand_Cryo_Shoot(int client, int weapon, bool crit, int slot, float damage, int NumParticles, char ParticleName[255], int SlowType)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	if(mana_cost <= Current_Mana[client])
	{
		Current_Mana[client] -= mana_cost;
		
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		delay_hud[client] = 0.0;
		
		float speed = Cryo_M1_Velocity;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
		
		
		float time = Cryo_M1_Time/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
		
		float Angles[3];

		for (int i = 0; i < NumParticles; i++)
		{
			GetClientEyeAngles(client, Angles);
			for (int spread = 0; spread < 3; spread++)
			{
				Angles[spread] += GetRandomFloat(-Cryo_M1_Spread, Cryo_M1_Spread);
			}
			//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
			int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 11, weapon, ParticleName, Angles);

			//Remove unused hook.

			Cryo_IsCryo[projectile] = true;
			Cryo_SlowType[projectile] = SlowType;
			EmitSoundToAll(SOUND_WAND_CRYO_M1, client, _, 60, _, 0.4, 80);
		}
		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
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

public void Cryo_Touch(int entity, int target)
{
	if (target > 0)	
	{
		if(IsIn_HitDetectionCooldown(entity,target))
			return;
			
		Set_HitDetectionCooldown(entity,target, FAR_FUTURE);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);		
		float ProjLoc[3], VicLoc[3];
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		
		WorldSpaceCenter(target, VicLoc);
		//Code to do damage position and ragdolls
		//Code to do damage position and ragdolls
		switch (Cryo_SlowType[entity])
		{
			case 0:
			{
				ApplyStatusEffect(owner, target, "Freeze", 1.0);
			}
			case 1:
			{
				ApplyStatusEffect(owner, target, "Cryo", 1.0);
			}
			case 2:
			{
				ApplyStatusEffect(owner, target, "Near Zero", 1.0);
			}
		}
		
		//float Health_Before_Hurt = float(GetEntProp(target, Prop_Data, "m_iHealth"));

		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		if(owner == -1)
		{
			int particle = EntRefToEntIndex(i_WandParticle[entity]);
			if(IsValidEntity(particle))
			{
				RemoveEntity(particle);
			}
			RemoveEntity(entity);
		}
		
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, {0.0,0.0,0.0}, VicLoc, _, ZR_DAMAGE_ICE); // 2048 is DMG_NOGIB?
		
		//float Health_After_Hurt = float(GetEntProp(target, Prop_Data, "m_iHealth"));
		
		if (!Cryo_Frozen[target] && !Cryo_Slowed[target])
		{
			Elemental_AddCyroDamage(target, owner, RoundFloat(f_WandDamage[entity]), Cryo_SlowType[entity]);
		}
		
		f_WandDamage[entity] *= Cryo_M1_ReductionScale;
	}
}

void Cryo_FreezeZombie(int client, int zombie, int type)
{
	if (!IsValidEntity(zombie))
		return;

	if(!IsEntityAlive(zombie))
		return;
		
	Cryo_SlowType_Zombie[zombie] = type;
	
	if(type != 3)
		EmitSoundToAll(SOUND_WAND_CRYO_FREEZE, zombie, SNDCHAN_STATIC, 80);
	CClotBody ZNPC = view_as<CClotBody>(zombie);
	Cryo_Frozen[zombie] = true;
	Cryo_FreezeLevel[zombie] = 0.0;
	float FreezeDuration;

	switch (Cryo_SlowType_Zombie[zombie])
	{
		case 0:
		{
			FreezeDuration = Cryo_FreezeDuration;
		}
		case 1:
		{
			FreezeDuration = Cryo_FreezeDuration_Pap1;
		}
		case 2:
		{
			FreezeDuration = Cryo_FreezeDuration_Pap2;
		}
		case 3:
		{
			if(b_thisNpcIsARaid[zombie])
			{
				FreezeDuration = 1.0;
			}
			else if(b_thisNpcIsABoss[zombie] || b_ThisNpcIsImmuneToNuke[zombie])
			{
				FreezeDuration = 2.0;
			}
			else
			{
				FreezeDuration = 5.0;
			}
		}
	}

	if(b_thisNpcIsARaid[zombie])
	{
		if(type != 3)
			FreezeDuration *= 0.75; //Less duration against raids.
	}

	CreateTimer(FreezeDuration, Cryo_Unfreeze, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
	FreezeNpcInTime(zombie, FreezeDuration);
	if(type != 3)
		ApplyStatusEffect(client, zombie, "Frozen", FreezeDuration);

	if (!IsValidEntity(ZNPC.m_iFreezeWearable) && !HasSpecificBuff(zombie, "Clear Head"))
	{
		float offsetToHeight = 40.0;
		if(b_IsGiant[zombie])
		{
			offsetToHeight = 55.0;
		}
		ZNPC.m_iFreezeWearable = ZNPC.EquipItemSeperate("models/props_moonbase/moon_gravel_crystal_blue.mdl",_,_,_,offsetToHeight);
		if(b_IsGiant[zombie])
		{
			SetVariantString("3.6");
		}
		else
		{
			SetVariantString("2.85");
		}
		AcceptEntityInput(ZNPC.m_iFreezeWearable, "SetModelScale");
		SetEntityRenderMode(ZNPC.m_iFreezeWearable, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iFreezeWearable, 65, 65, 185, 65);
	}

	SetEntityRenderMode(zombie, RENDER_NORMAL, false, 1, false, true);
	SetEntityRenderColor(zombie, 0, 0, 255, 255, false, false, true);
	float position[3];
	GetEntPropVector(zombie, Prop_Data, "m_vecAbsOrigin", position);
	switch (Cryo_SlowType_Zombie[zombie])
	{
		case 0:
		{
			ApplyStatusEffect(client, zombie, "Freeze", Cryo_SlowDuration + FreezeDuration);
		}
		case 1:
		{
			ApplyStatusEffect(client, zombie, "Cryo", Cryo_SlowDuration + FreezeDuration);
		}
		case 2:
		{
			ApplyStatusEffect(client, zombie, "Near Zero", Cryo_SlowDuration + FreezeDuration);
		}
	}
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
		
		CreateTimer(Cryo_SlowDuration, Cryo_Unslow, EntIndexToEntRef(zombie), TIMER_FLAG_NO_MAPCHANGE);
		
		SetEntityRenderMode(zombie, i_EntityRenderMode[zombie], true, 2, false, true);
		SetEntityRenderColor(zombie, i_EntityRenderColour1[zombie], i_EntityRenderColour2[zombie], i_EntityRenderColour3[zombie], i_EntityRenderColour4[zombie], true, false, true);
	}
	
	return Plugin_Continue;
}

public Action Cryo_Unslow(Handle Unslow, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(zombie))
	return Plugin_Continue;
	
	Cryo_Slowed[zombie] = false;
	
	return Plugin_Continue;
}

public void CleanAllApplied_Cryo(int entity)
{
	Cryo_FreezeLevel[entity] = 0.0;
	Cryo_Frozen[entity] = false;
	Cryo_Slowed[entity] = false;
	Cryo_IsCryo[entity] = false;
}