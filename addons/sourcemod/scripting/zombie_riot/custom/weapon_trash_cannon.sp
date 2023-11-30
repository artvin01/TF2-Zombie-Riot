#pragma semicolon 1
#pragma newdecls required

//Stats based on pap level. Uses arrays for simpler code.
//Example: Weapon_Damage[3] = { 100.0, 250.0, 500.0 }; Default damage is 100, pap1 is 250, pap2 is 500.

//NOTES:
//		- 5.9136 is the multiplier to use for calculating damage at max ranged upgrades.

//FLIMSY ROCKET: The default roll. If all other rolls fail, this is what gets launched. A rocket that flops out of the barrel and explodes on impact.
float f_FlimsyDMG[3] = { 500.0, 750.0, 1000.0 };
float f_FlimsyRadius[3] = { 300.0, 350.0, 400.0 };
float f_FlimsyVelocity[3] = { 800.0, 1200.0, 1600.0 };

//SHOCK STOCK: An electric orb, affected by gravity. Explodes into Passanger's Device chain lightning on impact.
float f_ShockChance[3] = { 0.08, 0.12, 0.16 };
bool b_ShockEnabled[3] = { true, true, true };

//MORTAR MARKER: A beacon which marks the spot it lands on for a special mortar strike, which scales with ranged upgrades.
float f_MortarChance[3] = { 0.04, 0.06, 0.08 };
bool b_MortarEnabled[3] = { true, true, true };

//BUNDLE OF ARROWS: A giant shotgun blast of Huntsman arrows.
float f_ArrowsChance[3] = { 0.00, 0.04, 0.08 };
bool b_ArrowsEnabled[3] = { false, true, true };

//PYRE: A fireball which is affected by gravity.
float f_PyreChance[3] = { 0.05, 0.08, 0.12 };
bool b_PyreEnabled[3] = { true, true, true };

//SKELETON: Fires a shotgun blast of skeleton gibs which deal huge contact damage.
float f_SkeletonChance[3] = { 0.00, 0.04, 0.08 };
bool b_SkeletonEnabled[3] = { false, true, true };

//NICE ICE: Fires a big block of ice which deals high contact damage and explodes, freezing all zombies hit by it.
float f_IceChance[3] = { 0.00, 0.04, 0.08 };
bool b_IceEnabled[3] = { false, true, true };

//TRASH: Fires a garbage bag which explodes on impact and applies a powerful poison to all zombies hit by it. Poisoned zombies are given the lesser Medusa debuff.
float f_TrashChance[3] = { 0.00, 0.03, 0.06 };
bool b_TrashEnabled[3] = { false, true, true };

//MICRO-MISSILES: Fires a burst of X micro-missiles which aggressively home in on the nearest enemy and explode.
float f_MissilesChance[3] = { 0.00, 0.00, 0.05 };
bool b_MissilesEnabled[3] = { false, false, true };

//MONDO MASSACRE: The strongest possible roll. Fires an EXTREMELY powerful rocket which deals a base damage of 100k within an enormous blast radius.
float f_MondoChance[3] = { 0.00, 0.00, 0.0001 };
bool b_MondoEnabled[3] = { false, false, true };

static int i_TrashNumEffects = 9;

static int i_TrashWeapon[2049] = { -1, ... };
static int i_TrashTier[2049] = { 0, ... };

#define MODEL_ROCKET				"models/weapons/w_models/w_rocket.mdl"

#define SOUND_FLIMSY_BLAST			"weapons/explode1.wav"

#define PARTICLE_FLIMSY_TRAIL		"rockettrail"
#define PARTICLE_EXPLOSION_GENERIC	"ExplosionCore_Wall"

void Trash_Cannon_Precache()
{
	PrecacheModel(MODEL_ROCKET, true);
	
	PrecacheSound(SOUND_FLIMSY_BLAST, true);
}

public void Trash_Cannon_EntityDestroyed(int ent)
{
	if (!IsValidEdict(ent))
		return;
}

public void Weapon_Trash_Cannon_Fire(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 0);
}
public void Weapon_Trash_Cannon_Fire_Pap1(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 1);
}
public void Weapon_Trash_Cannon_Fire_Pap2(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 2);
}

public void Trash_Cannon_Shoot(int client, int weapon, bool crit, int tier)
{
	Queue scramble = Rand_GenerateScrambledQueue(i_TrashNumEffects);
	
	bool success = false;
	while (!success && !scramble.Empty)
	{
		int effect = scramble.Pop();
		switch(effect)
		{
			case 1:
				success = Trash_Shock(client, weapon, tier);
			case 2:
				success = Trash_Mortar(client, weapon, tier);
			case 3:
				success = Trash_Arrows(client, weapon, tier);
			case 4:
				success = Trash_Pyre(client, weapon, tier);
			case 5:
				success = Trash_Skeleton(client, weapon, tier);
			case 6:
				success = Trash_Ice(client, weapon, tier);
			case 7:
				success = Trash_Trash(client, weapon, tier);
			case 8:
				success = Trash_Missiles(client, weapon, tier);
			case 9:
				success = Trash_Mondo(client, weapon, tier);
		}
	}
	
	delete scramble;
	
	if (!success)
		Trash_FlimsyRocket(client, weapon, tier);
}

public void Trash_FlimsyRocket(int client, int weapon, int tier)
{
	CPrintToChatAll("Flimsy rocket!");
	
	int rocket = Trash_LaunchPhysProp(client, MODEL_ROCKET, f_FlimsyVelocity[tier], weapon);
	if (IsValidEntity(rocket))
	{
		float ang[3];
		for (int i = 0; i < 3; i++)
		{
			ang[i] = GetRandomFloat(0.0, 360.0);
		}
		
		TeleportEntity(rocket, NULL_VECTOR, ang, NULL_VECTOR);
		
		Trash_AttachParticle(rocket, PARTICLE_FLIMSY_TRAIL, 6.0, "trail");
		SDKHook(rocket, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(rocket, SDKHook_StartTouch, Flimsy_OnTouch);
		
		i_TrashWeapon[rocket] = EntIndexToEntRef(weapon);
		i_TrashTier[rocket] = tier;
	}
}

public Action Flimsy_OnTouch(int entity, int other)
{
	float position[3];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_EXPLOSION_GENERIC, 1.0);
	EmitSoundToAll(SOUND_FLIMSY_BLAST, entity, SNDCHAN_STATIC, 80, _, 1.0);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	int tier = i_TrashTier[entity];
	
	float damage = f_FlimsyDMG[tier];
	float radius = f_FlimsyRadius[tier];
	
	//TODO: Modify damage and radius based on attributes
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false);
	
	RemoveEntity(entity);
}

public bool Trash_Shock(int client, int weapon, int tier)
{
	if (!b_ShockEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ShockChance[tier])
		return false;
		
	return true;
}

public bool Trash_Mortar(int client, int weapon, int tier)
{
	if (!b_MortarEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MortarChance[tier])
		return false;
		
	return true;
}

public bool Trash_Arrows(int client, int weapon, int tier)
{
	if (!b_ArrowsEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ArrowsChance[tier])
		return false;
		
	return true;
}

public bool Trash_Pyre(int client, int weapon, int tier)
{
	if (!b_PyreEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_PyreChance[tier])
		return false;
		
	return true;
}

public bool Trash_Skeleton(int client, int weapon, int tier)
{
	if (!b_SkeletonEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_SkeletonChance[tier])
		return false;
		
	return true;
}

public bool Trash_Ice(int client, int weapon, int tier)
{
	if (!b_IceEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_IceChance[tier])
		return false;
		
	return true;
}

public bool Trash_Trash(int client, int weapon, int tier)
{
	if (!b_TrashEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_TrashChance[tier])
		return false;
		
	return true;
}

public bool Trash_Missiles(int client, int weapon, int tier)
{
	if (!b_MissilesEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MissilesChance[tier])
		return false;
		
	return true;
}

public bool Trash_Mondo(int client, int weapon, int tier)
{
	if (!b_MondoEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MondoChance[tier])
		return false;
		
	return true;
}

public int Trash_LaunchPhysProp(int client, char model[255], float velocity, int weapon)
{
	int prop = CreateEntityByName("prop_physics_override");
			
	if (IsValidEntity(prop))
	{
		b_EntityIgnoredByShield[prop] = true;
		DispatchKeyValue(prop, "targetname", "trash_projectile"); 
		DispatchKeyValue(prop, "spawnflags", "4"); 
		DispatchKeyValue(prop, "model", model);
				
		DispatchSpawn(prop);
				
		ActivateEntity(prop);
		
		SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
		
		float pos[3], ang[3], propVel[3], buffer[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);

		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		
		if (IsValidEntity(weapon))
		{
			//TODO: Modify velocity based on attributes
		}
		
		propVel[0] = buffer[0]*velocity;
		propVel[1] = buffer[1]*velocity;
		propVel[2] = buffer[2]*velocity;
			
		TeleportEntity(prop, pos, ang, propVel);
		
		return prop;
	}
	
	return -1;
}

public Queue Rand_GenerateScrambledQueue(int numSlots)
{
	Queue scramble = new Queue();
	Handle genericArray = CreateArray(255);
	
	for (int i = 0; i < numSlots; i++)
	{
		PushArrayCell(genericArray, i);
	}
	
	for (int j = 0; j < GetArraySize(genericArray); j++)
	{
		int randSlot = GetRandomInt(j, GetArraySize(genericArray) - 1);
		int currentVal = GetArrayCell(genericArray, j);
		SetArrayCell(genericArray, j, GetArrayCell(genericArray, randSlot));
		SetArrayCell(genericArray, randSlot, currentVal);
		
		scramble.Push(GetArrayCell(genericArray, j));
	}
	
	delete genericArray;
	return scramble;
}

stock void Trash_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}