#pragma semicolon 1
#pragma newdecls required

static float Hose_Velocity = 1000.0;
static float Hose_BaseHeal = 3.0;
static float Hose_UberGain = 0.0025;
static float Hose_UberTime = 6.0;
static float Hose_ShotgunChargeMult = 3.0;
static int Hose_LossPerHit = 2;
static int Hose_Min = 1;

static bool Hose_AlreadyHealed[MAXENTITIES][MAXENTITIES];
static int Hose_Healing[MAXENTITIES] = { 0, ... };
static int Hose_HealLoss[MAXENTITIES] = { 0, ... };
static int Hose_HealMin[MAXENTITIES] = { 0, ... };
static int Hose_Owner[MAXENTITIES] = { -1, ... };
static bool Hose_GiveUber[MAXENTITIES] = { false, ... };
static bool Hose_ProjectileCharged[MAXENTITIES] = { false, ... };
static float Hose_Uber[MAXPLAYERS + 1] = { 0.0, ... };
static float Hose_NextHealSound[MAXPLAYERS + 1] = { 0.0, ... };
static bool Hose_Charged[MAXPLAYERS + 1] = { false, ... };
static bool Hose_ShotgunCharge[MAXPLAYERS + 1] = { false, ... };

#define COLLISION_DETECTION_MODEL_BIG	"models/props_junk/wood_crate001a.mdl"
#define SOUND_HOSE_HEALED		"weapons/rescue_ranger_charge_01.wav"
#define SOUND_HOSE_UBER_END		"player/invuln_off_vaccinator.wav"
#define SOUND_HOSE_UBER_ACTIVATE	"player/invuln_on_vaccinator.wav"
#define SOUND_HOSE_UBER_READY		"weapons/vaccinator_charge_tier_04.wav"
#define SOUND_SHOOT_SHOTCHARGE		"items/powerup_pickup_reflect_reflect_damage.wav"

#define HOSE_PARTICLE			"stunballtrail_red"
#define HOSE_PARTICLE_OLD		"healshot_trail_red" //Looks good but is ridiculously flashy, so scrapped.
#define HOSE_PARTICLE_CHARGED	"stunballtrail_blue_crit"
#define HOSE_PARTICLE_CHARGED_OLD	"healshot_trail_blue" //Looks good but is ridiculously flashy, so scrapped.
#define HEAL_PARTICLE			"healthgained_red"
#define HEAL_PARTICLE_CHARGED	"healthgained_blu"

void Weapon_Hose_Precache()
{
	PrecacheSound(SOUND_HOSE_HEALED);
	PrecacheSound(SOUND_HOSE_UBER_END);
	PrecacheSound(SOUND_HOSE_UBER_ACTIVATE);
	PrecacheSound(SOUND_HOSE_UBER_READY);
	PrecacheSound(SOUND_SHOOT_SHOTCHARGE);
	PrecacheModel(COLLISION_DETECTION_MODEL_BIG);
}

public void Weapon_Health_Hose(int client, int weapon, bool crit, int slot)
{
	Weapon_Hose_Shoot(client, weapon, crit, slot, Hose_Velocity, Hose_BaseHeal, Hose_LossPerHit, Hose_Min, 1, 1.0, HOSE_PARTICLE, false);
}

public void Weapon_Health_Hose_Shotgun(int client, int weapon, bool crit, int slot)
{
	Weapon_Hose_Shoot(client, weapon, crit, slot, Hose_Velocity, Hose_BaseHeal, Hose_LossPerHit, Hose_Min, 6, 4.0, HOSE_PARTICLE, false);
}

public void Weapon_Health_Hose_GiveUber(int client, int weapon, bool crit, int slot)
{
	Weapon_Hose_Shoot(client, weapon, crit, slot, Hose_Velocity, Hose_BaseHeal, Hose_LossPerHit, Hose_Min, 1, 1.0, HOSE_PARTICLE, true);
}

public void Weapon_Health_Hose_Shotgun_GiveUber(int client, int weapon, bool crit, int slot)
{
	Weapon_Hose_Shoot(client, weapon, crit, slot, Hose_Velocity, Hose_BaseHeal, Hose_LossPerHit, Hose_Min, 6, 4.0, HOSE_PARTICLE, true);
}

public void Weapon_Health_Hose_Uber_Sprayer(int client, int weapon, bool crit, int slot)
{
	if (Hose_Uber[client] < 1.0 && !Hose_Charged[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		Hose_UpdateText(client);
	}
	else if (!Hose_Charged[client])
	{
		Hose_Uber[client] = 0.0;
		Hose_Charged[client] = true;
		
		float dur = Hose_UberTime + Attributes_FindOnPlayer(client, 314, true, 0.0, true);
		EmitSoundToClient(client, SOUND_HOSE_UBER_ACTIVATE, _, _, 120);
		
		CreateTimer(dur, Hose_RemoveUber, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
		TF2_AddCondition(client, TFCond_MegaHeal, Hose_UberTime);
		TF2_AddCondition(client, TFCond_RuneHaste, Hose_UberTime);
		
		Hose_UpdateText(client);
	}
}

public void Weapon_Health_Hose_Uber_Shotgun(int client, int weapon, bool crit, int slot)
{
	if (Hose_Uber[client] < 1.0 && !Hose_Charged[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
	else if (!Hose_Charged[client])
	{
		Hose_Uber[client] = 0.0;
		Hose_Charged[client] = true;
		Hose_ShotgunCharge[client] = true;
		
		float dur = Hose_UberTime + Attributes_FindOnPlayer(client, 314, true, 0.0, true);
		EmitSoundToClient(client, SOUND_HOSE_UBER_ACTIVATE, _, _, 120);
		
		CreateTimer(dur, Hose_RemoveUber, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
		TF2_AddCondition(client, TFCond_MegaHeal, Hose_UberTime);
		
		Hose_UpdateText(client);
	}
}

public Action Hose_RemoveUber(Handle remove, int id)
{
	int client = GetClientOfUserId(id);
	
	if (IsValidClient(client))
	{
		Hose_Charged[client] = false;
		Hose_ShotgunCharge[client] = false;
		EmitSoundToClient(client, SOUND_HOSE_UBER_END, _, _, 120);
		
		Hose_UpdateText(client);
	}
}

public void Weapon_Hose_Shoot(int client, int weapon, bool crit, int slot, float speed, float baseHeal, int loss, int minHeal, int NumParticles, float spread, char ParticleName[255], bool giveUber)
{
	Address address;
	
	float healmult = Attributes_FindOnPlayer(client, 8, true, 1.0, true);
		
	if (Hose_ShotgunCharge[client])
	{
		healmult *= Hose_ShotgunChargeMult;
	}
		
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	address = TF2Attrib_GetByDefIndex(weapon, 104);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	address = TF2Attrib_GetByDefIndex(weapon, 475);
	if(address != Address_Null)
	speed *= TF2Attrib_GetValue(address);
		
	int FinalHeal = RoundFloat(baseHeal * healmult);
		
	float Angles[3];

	for (int i = 0; i < NumParticles; i++)
	{
		GetClientEyeAngles(client, Angles);
			
		for (int j = 0; j < 3; j++)
		{
			Angles[j] += GetRandomFloat(-spread, spread);
		}
			
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		int projectile = Wand_Projectile_Spawn(client, speed, 1.66, 0.0, 19, weapon, Hose_Charged[client] ? HOSE_PARTICLE_CHARGED : ParticleName, Angles);

		Hose_Healing[projectile] = FinalHeal;
		Hose_HealLoss[projectile] = loss;
		Hose_HealMin[projectile] = minHeal;
		Hose_Owner[projectile] = GetClientUserId(client);
		Hose_GiveUber[projectile] = giveUber && !Hose_Charged[client];
		Hose_ProjectileCharged[projectile] = Hose_Charged[client];

		//Remove unused hook.
		SDKUnhook(projectile, SDKHook_StartTouch, Wand_Base_StartTouch);

		for (int entity = 0; entity < MAXENTITIES; entity++)
		{
			Hose_AlreadyHealed[projectile][entity] = false;
		}
			
		SetEntityCollisionGroup(projectile, 1); //Do not collide.
		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(projectile, 0.5);
	}
	
	if (Hose_ShotgunCharge[client])
	{
		EmitSoundToClient(client, SOUND_SHOOT_SHOTCHARGE, _, _, _, _, _, GetRandomInt(80, 110));
	}
}

//If you use SearchDamage (above), convert this timer to a void method and rename it to Cryo_DealDamage:

public void Hose_Touch(int entity, int other)
{
	int owner = GetClientOfUserId(Hose_Owner[entity]);
	
	if (!IsValidClient(owner))
		return;
		
	if (other == owner) //Don't accidentally heal the user every time they fire this thing, it would be WAY too good
		return;
		
	if (Hose_AlreadyHealed[entity][other])
		return;
		
	if (IsValidAlly(other, owner))	
	{	
		float ProjLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		
		ParticleEffectAt(ProjLoc, Hose_ProjectileCharged[entity] ? HEAL_PARTICLE_CHARGED : HEAL_PARTICLE, 1.0);
		
		Hose_Heal(other, Hose_Healing[entity]);
		
		if (GetGameTime() >= Hose_NextHealSound[owner])
		{
			EmitSoundToClient(owner, SOUND_HOSE_HEALED);
			Hose_NextHealSound[owner] = GetGameTime() + 0.05;
		}
		
		Hose_Healing[entity] -= Hose_HealLoss[entity];
		if (Hose_Healing[entity] < Hose_HealMin[entity])
		{
			Hose_Healing[entity] = Hose_HealMin[entity];
		}
		
		Hose_AlreadyHealed[entity][other] = true;
		
		if (Hose_GiveUber[entity])
		{
			Hose_UpdateText(owner);
			
			if (!Hose_Charged[owner] && Hose_Uber[owner] < 1.0)
			{
				Hose_Uber[owner] += Hose_UberGain;
				if (Hose_Uber[owner] >= 1.0)
				{
					Hose_Uber[owner] = 1.0;
					EmitSoundToClient(owner, SOUND_HOSE_UBER_READY, _, _, 120);
				}
			}
		}
	}
}

public void Hose_Heal(int entity, int amt)
{
	int flHealth = GetEntProp(entity, Prop_Data, "m_iHealth");
		
	int flMaxHealth;
	if(entity > MaxClients)
	{
		flMaxHealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	}
	else
	{
		flMaxHealth = SDKCall_GetMaxHealth(entity);
	}
	
	if (flHealth > flMaxHealth)	//Don't apply the new health because then you'd remove their overheal if they have any
		return;
	
	int newHP = flHealth + amt;
	
	if (newHP > flMaxHealth)
	{
		newHP = flMaxHealth;
	}
	
	SetEntProp(entity, Prop_Data, "m_iHealth", newHP);	
}

public void Hose_UpdateText(int owner)
{
	if (!IsValidClient(owner))
		return;
		
	if (Hose_Charged[owner])
	{
		PrintHintText(owner, "[CHARGE IS ACTIVE]");
	}
	else if (Hose_Uber[owner] >= 1.0)
	{
		PrintHintText(owner, "[CHARGE IS READY! ALT-FIRE TO USE!]");
	}
	else
	{
		PrintHintText(owner, "[CHARGE: %.2f]", Hose_Uber[owner]);
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