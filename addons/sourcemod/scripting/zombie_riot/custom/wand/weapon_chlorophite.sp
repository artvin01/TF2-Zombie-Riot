#pragma semicolon 1
#pragma newdecls required

static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];


#define SOUND_AUTOAIM_IMPACT_FLESH_1 		"physics/flesh/flesh_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_2 		"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_3 		"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_4 		"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_5 		"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_AUTOAIM_IMPACT_CONCRETE_1 		"physics/concrete/concrete_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

void Wand_Chlorophite_Map_Precache()
{
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_4);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_5);
	
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_4);
}

public void Weapon_Chlorophite(int client, int weapon, bool crit)
{
	float damage = 8.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 2000.0;
	
	speed *= Attributes_Get(weapon, 103, 1.0);
		
	float time = 500.0/speed;
	
	time = 10.0;
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 9/*Default wand*/, weapon, "raygun_projectile_blue_trail");
	
	CreateTimer(0.1, Homing_Shots_Repeat_Timer_Chlorophite, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//	RMR_NextDeviationAt[iCarrier] = GetGameTime() + 0.4;
	RMR_HomingPerSecond[projectile] = 359.0;
	RMR_RocketOwner[projectile] = client;
	RMR_HasTargeted[projectile] = false;
	RWI_HomeAngle[projectile] = 180.0;
	RWI_LockOnAngle[projectile] = 180.0;
	RMR_RocketVelocity[projectile] = speed;
	RMR_CurrentHomingTarget[projectile] = -1;
}

public Action Homing_Shots_Repeat_Timer_Chlorophite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidClient(RMR_RocketOwner[entity]))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}

		if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
		{
			if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
			{
				HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
			}
			return Plugin_Continue;
		}
		int Closest = GetClosestTarget(entity, _, _, true);
		if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
		{
			RMR_CurrentHomingTarget[entity] = Closest;
			if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
			{
				if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
				{
					HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
				}
				return Plugin_Continue;
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}	
