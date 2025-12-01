#pragma semicolon 1
#pragma newdecls required

static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];



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
	
//	RMR_NextDeviationAt[iCarrier] = GetGameTime() + 0.4;
	RMR_HomingPerSecond[projectile] = 359.0;
	RMR_RocketOwner[projectile] = client;
	RMR_HasTargeted[projectile] = false;
	RWI_HomeAngle[projectile] = 180.0;
	RWI_LockOnAngle[projectile] = 180.0;
	RMR_RocketVelocity[projectile] = speed;
	RMR_CurrentHomingTarget[projectile] = -1;
}