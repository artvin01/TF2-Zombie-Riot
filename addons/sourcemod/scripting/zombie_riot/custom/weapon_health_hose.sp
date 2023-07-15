#pragma semicolon 1
#pragma newdecls required

static float Hose_Velocity = 800.0;
static float Hose_BaseHeal = 5.0;
static int Hose_LossPerHit = 2;
static int Hose_Min = 1;

static bool Hose_AlreadyHealed[MAXENTITIES][MAXENTITIES];
static int Hose_Healing[MAXENTITIES] = { 0, ... };
static int Hose_HealLoss[MAXENTITIES] = { 0, ... };
static int Hose_HealMin[MAXENTITIES] = { 0, ... };
static int Hose_Owner[MAXENTITIES] = { -1, ... };

#define COLLISION_DETECTION_MODEL_BIG	"models/props_junk/wood_crate001a.mdl"
#define SOUND_HOSE_HEALED		"weapons/rescue_ranger_charge_01.wav"

#define HOSE_PARTICLE			"nailtrails_medic_red"
#define HEAL_PARTICLE			"healthgained_red"

void Weapon_Hose_Precache()
{
	PrecacheSound(SOUND_HOSE_HEALED);
	PrecacheModel(COLLISION_DETECTION_MODEL_BIG);
}

public void Weapon_Health_Hose(int client, int weapon, bool crit, int slot)
{
	Weapon_Hose_Shoot(client, weapon, crit, slot, Hose_Velocity, Hose_BaseHeal, Hose_LossPerHit, Hose_Min, 1, 1.0, HOSE_PARTICLE);
}

public void Weapon_Hose_Shoot(int client, int weapon, bool crit, int slot, float speed, float baseHeal, int loss, int minHeal, int NumParticles, float spread, char ParticleName[255])
{
	Address address;
	
	address = TF2Attrib_GetByDefIndex(weapon, 8);
	if(address != Address_Null)
	baseHeal *= TF2Attrib_GetValue(address);
		
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	address = TF2Attrib_GetByDefIndex(weapon, 104);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	address = TF2Attrib_GetByDefIndex(weapon, 475);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	int FinalHeal = RoundFloat(baseHeal);
		
	float Angles[3];

	for (int i = 0; i < NumParticles; i++)
	{
		GetClientEyeAngles(client, Angles);
			
		for (int j = 0; j < 3; j++)
		{
			Angles[j] += GetRandomFloat(-spread, spread);
		}
			
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		int projectile = Wand_Projectile_Spawn(client, speed, 2.5, 0.0, 19, weapon, ParticleName, Angles);

		Hose_Healing[projectile] = FinalHeal;
		Hose_HealLoss[projectile] = loss;
		Hose_HealMin[projectile] = minHeal;
		Hose_Owner[projectile] = GetClientUserId(client);

		//Remove unused hook.
		SDKUnhook(projectile, SDKHook_StartTouch, Wand_Base_StartTouch);

		for (int entity = 0; entity < MAXENTITIES; entity++)
		{
			Hose_AlreadyHealed[projectile][entity] = false;
		}
			
		SetEntityCollisionGroup(projectile, 1); //Do not collide.
		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
	}
}

//If you use SearchDamage (above), convert this timer to a void method and rename it to Cryo_DealDamage:

public void Hose_Touch(int entity, int other)
{
	if (!IsValidClient(Hose_Owner[entity]))
		return;
		
	if (other == Hose_Owner[entity]) //Don't accidentally heal the user every time they fire this thing, it would be WAY too good
		return;
		
	if (Hose_AlreadyHealed[entity][other])
		return;
		
	if (IsValidAlly(other, Hose_Owner[entity]))	
	{	
		float ProjLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		
		ParticleEffectAt(ProjLoc, HEAL_PARTICLE, 1.0);
		
		HealEntityViaFloat(other, float(Hose_Healing[entity]), 1.0);
		
		EmitSoundToClient(Hose_Owner[entity], SOUND_HOSE_HEALED);
		
		Hose_Healing[entity] -= Hose_HealLoss[entity];
		if (Hose_Healing[entity] < Hose_HealMin[entity])
		{
			Hose_Healing[entity] = Hose_HealMin[entity];
		}
		
		Hose_AlreadyHealed[entity][other] = true;
	}
}

public void Hose_OnDestroyed(int entity)
{
	Hose_Owner[entity] = -1;
	for (int i = 0; i < MAXENTITIES; i++)
	{
		Hose_AlreadyHealed[i][entity] = false;
		Hose_AlreadyHealed[entity][i] = false;
	}
}