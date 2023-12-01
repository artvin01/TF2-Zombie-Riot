#pragma semicolon 1
#pragma newdecls required

//Stats based on pap level. Uses arrays for simpler code.
//Example: Weapon_Damage[3] = { 100.0, 250.0, 500.0 }; Default damage is 100, pap1 is 250, pap2 is 500.

//NOTES:
//		- 5.9136 is the multiplier to use for calculating damage at max ranged upgrades.

//FLIMSY ROCKET: The default roll. If all other rolls fail, this is what gets launched. A rocket that flops out of the barrel and explodes on impact.
float f_FlimsyDMG[3] = { 500.0, 750.0, 1000.0 };		//Flimsy Rocket base damage.
float f_FlimsyRadius[3] = { 300.0, 350.0, 400.0 };		//Flimsy Rocket explosion radius.
float f_FlimsyVelocity[3] = { 600.0, 800.0, 1200.0 };	//Flimsy Rocket projectile velocity.

//SHOCK STOCK: An electric orb, affected by gravity. Explodes into Passanger's Device-esque chain lightning on impact.
int i_ShockMaxHits[3] = { 6, 10, 14 };					//Max number of zombies hit by the shock.

float f_ShockChance[3] = { 1.0, 0.12, 0.16 };			//Chance for Shock Stock to be fired.
float f_ShockVelocity[3] = { 600.0, 800.0, 1200.0 };	//Shock Stock projectile velocity.
float f_ShockDMG[3] = { 800.0, 1250.0, 1500.0 };		//Base damage dealt.
float f_ShockRadius[3] = { 300.0, 350.0, 400.0 };		//Initial blast radius.
float f_ShockChainRadius[3] = { 600.0, 800.0, 1000.0 };	//Chain lightning radius.
float f_ShockDMGReductionPerHit[3] = { 0.65, 0.75, 0.85 };	//Amount to multiply damage dealt for each zombie shocked.
float f_ShockPassangerTime[3] = { 0.2, 0.25, 0.3 };			//Duration to apply the Passanger's Device debuff to zombies hit by Shock Stock chain lightning.

bool b_ShockEnabled[3] = { true, true, true };			//Is Shock Stock enabled on this pap level?

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

//TRASH: Fires a garbage bag which explodes on impact and applies a powerful poison to all zombies hit by it. Poisoned zombies are given the lesser Medusa debuff and take damage over time.
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
#define MODEL_DRG					"models/weapons/w_models/w_drg_ball.mdl"

#define SOUND_FLIMSY_BLAST			"weapons/explode1.wav"
#define SOUND_SHOCK					"misc/halloween/spell_lightning_ball_impact.wav"
#define SOUND_SHOCK_FIRE			"misc/halloween/spell_lightning_ball_cast.wav"

#define PARTICLE_FLIMSY_TRAIL		"drg_manmelter_trail_red"
#define PARTICLE_EXPLOSION_GENERIC	"ExplosionCore_MidAir"
#define PARTICLE_SHOCK_1			"drg_cow_rockettrail_normal"
#define PARTICLE_SHOCK_2			"critical_rocket_red"
#define PARTICLE_SHOCK_3			"critical_rocket_redsparks"
#define PARTICLE_SHOCK_1_MAX		"drg_cow_rockettrail_normal_blue"
#define PARTICLE_SHOCK_2_MAX		"critical_rocket_blue"
#define PARTICLE_SHOCK_3_MAX		"critical_rocket_bluesparks"
#define PARTICLE_SHOCK_BLAST		"drg_cow_explosioncore_charged"
#define PARTICLE_SHOCK_BLAST_MAX	"drg_cow_explosioncore_charged_blue"
#define PARTICLE_SHOCK_CHAIN		"spell_lightningball_hit_red"
#define PARTICLE_SHOCK_CHAIN_MAX	"spell_lightningball_hit_blue"

void Trash_Cannon_Precache()
{
	PrecacheModel(MODEL_ROCKET, true);
	
	PrecacheSound(SOUND_FLIMSY_BLAST, true);
	PrecacheSound(SOUND_SHOCK, true);
	PrecacheSound(SOUND_SHOCK_FIRE, true);
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
	Trash_LaunchPhysProp(client, MODEL_ROCKET, GetRandomFloat(0.8, 1.2), f_FlimsyVelocity[tier], weapon, tier, Flimsy_Explode, true, true);
}

public MRESReturn Flimsy_Explode(int entity)
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
	
	return MRES_Supercede; //DONT.
}

public bool Trash_Shock(int client, int weapon, int tier)
{
	if (!b_ShockEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ShockChance[tier])
		return false;
		
	int rocket = Trash_LaunchPhysProp(client, MODEL_DRG, 0.001, f_ShockVelocity[tier], weapon, tier, Shock_Explode, true, true);
	
	if (IsValidEntity(rocket))
	{
		EmitSoundToAll(SOUND_SHOCK_FIRE, client, SNDCHAN_STATIC, 80, _, 1.0);
		
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_1_MAX : PARTICLE_SHOCK_1, 6.0, "");
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_2_MAX : PARTICLE_SHOCK_2, 6.0, "");
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_3_MAX : PARTICLE_SHOCK_3, 6.0, "");
		
		return true;
	}
	
	return false;
}

public MRESReturn Shock_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, tier > 1 ? PARTICLE_SHOCK_BLAST_MAX : PARTICLE_SHOCK_BLAST, 1.0);
	EmitSoundToAll(SOUND_SHOCK, entity, SNDCHAN_STATIC, 80, _, 1.0);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	
	float damage = f_ShockDMG[tier];
	float radius = f_ShockRadius[tier];
	
	//TODO: Modify damage and radius based on attributes
	
	Shock_ChainToVictim(entity, owner, weapon, damage, radius, position, tier, 0);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

static float f_NextShockTime[2049] = { 0.0, ... };

public void Shock_ChainToVictim(int inflictor, int client, int weapon, float damage, float radius, float position[3], int tier, int NumHits)
{
	if (NumHits >= i_ShockMaxHits[tier])
		return;
		
	int victim = Shock_GetClosestVictim(position, radius);
	float gt = GetGameTime();
	if (IsValidEntity(victim))
	{
		float vicLoc[3];
		vicLoc = WorldSpaceCenter(victim);
		SDKHooks_TakeDamage(victim, inflictor, client, damage, DMG_BLAST | DMG_ALWAYSGIB, weapon);
		
		if (f_PassangerDebuff[victim] < gt)
			f_PassangerDebuff[victim] = gt + f_ShockPassangerTime[tier];
		else
			f_PassangerDebuff[victim] += f_ShockPassangerTime[tier];
		
		f_NextShockTime[victim] = gt + 0.01;
		
		ParticleEffectAt(vicLoc, tier > 1 ? PARTICLE_SHOCK_BLAST_MAX : PARTICLE_SHOCK_BLAST, 1.0);
		SpawnParticle_ControlPoints(position, vicLoc, tier > 1 ? PARTICLE_SHOCK_CHAIN_MAX : PARTICLE_SHOCK_CHAIN, 1.0);
		
		if (NumHits < i_ShockMaxHits[tier])
		{
			Shock_ChainToVictim(inflictor, client, weapon, damage * f_ShockDMGReductionPerHit[tier], f_ShockChainRadius[tier], vicLoc, tier, NumHits + 1);
		}
	}
}

public int Shock_GetClosestVictim(float position[3], float radius)
{
	int closest = -1;
	float dist = 999999999.0;
	
	for (int i = 0; i < i_MaxcountNpc; i++)
	{
		int ent = EntRefToEntIndex(i_ObjectsNpcs[i]);
		
		if (IsValidEntity(ent) && !b_NpcHasDied[ent] && f_NextShockTime[ent] <= GetGameTime())
		{
			float vicLoc[3];  
			vicLoc = WorldSpaceCenter(ent);
			
			float targDist = GetVectorDistance(position, vicLoc, true);  
				
			if(targDist <= (radius * radius) && targDist < dist)
			{
				closest = ent;
				dist = targDist;
			}
		}
	}
	
	return closest;
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

public int Trash_LaunchPhysProp(int client, char model[255], float scale, float velocity, int weapon, int tier, DHookCallback CollideCallback, bool ForceRandomAngles, bool Spin)
{
	int prop = CreateEntityByName("tf_projectile_rocket");
			
	if (IsValidEntity(prop))
	{
		b_Is_Player_Projectile[prop] = true;
		DispatchKeyValue(prop, "targetname", "trash_projectile"); 
				
		SetEntDataFloat(prop, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetEntProp(prop, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
				
		DispatchSpawn(prop);
				
		ActivateEntity(prop);
		
		SetEntityModel(prop, model);
		char scaleChar[16];
		Format(scaleChar, sizeof(scaleChar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scaleChar);
		
		SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
		
		float pos[3], ang[3], propVel[3], buffer[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);

		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		
		if (IsValidEntity(weapon))
		{
			//TODO: Modify velocity based on attributes
			i_TrashWeapon[prop] = EntIndexToEntRef(weapon);
		}
		
		SetEntityMoveType(prop, MOVETYPE_FLYGRAVITY);
		
		propVel[0] = buffer[0]*velocity;
		propVel[1] = buffer[1]*velocity;
		propVel[2] = buffer[2]*velocity;
		
		if (ForceRandomAngles)
		{
			for (int i = 0; i < 3; i++)
			{
				ang[i] = GetRandomFloat(0.0, 360.0);
			}
		}
			
		TeleportEntity(prop, pos, ang, propVel);
		
		if (Spin)
		{
			//TODO: Figure out a way to do this that looks good and doesn't require OnGameFrame.
		}
		
		i_TrashTier[prop] = tier;
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);
		
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

public Action SpinEffect(int ent)
{
	float ang[3];
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
		
	for (int i = 0; i < 3; i++)
	{
		ang[i] += 4.0;
	}
		
	TeleportEntity(ent, NULL_VECTOR, ang, NULL_VECTOR);
		
	return Plugin_Continue;
}

stock void SpawnParticle_ControlPoints(float StartPos[3], float EndPos[3], char particleType[255], float duration)
{
	 int particle  = CreateEntityByName("info_particle_system");
	 int particle2 = CreateEntityByName("info_particle_system");
	 int ent = ParticleEffectAt(StartPos, "", 0.0);
	 int controlpoint = ParticleEffectAt(EndPos, "", 0.0);
 
	 if (IsValidEdict(particle) && IsValidEdict(particle2) && IsValidEdict(ent) && IsValidEdict(controlpoint))
	 {
		  TeleportEntity(particle, StartPos, NULL_VECTOR, NULL_VECTOR); 
		  TeleportEntity(particle2, EndPos, NULL_VECTOR, NULL_VECTOR);
		  
		  char tName[128];
		  Format(tName, sizeof(tName), "target%i", ent);
		  DispatchKeyValue(ent, "targetname", tName);
		  
		  char cpName[128];
		  Format(cpName, sizeof(cpName), "Xtarget%i", controlpoint);
		  
		  DispatchKeyValue(particle2, "targetname", cpName);
		  
		  DispatchKeyValue(particle, "targetname", "tf2particle");
		  DispatchKeyValue(particle, "parentname", tName);
		  DispatchKeyValue(particle, "effect_name", particleType);
		  DispatchKeyValue(particle, "cpoint1", cpName);
		  
		  DispatchSpawn(particle);
		  SetVariantString(tName);
		  AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		  
		  SetVariantString("flag");
		  AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);
		  
		  ActivateEntity(particle);
		  AcceptEntityInput(particle, "start");
		  
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(controlpoint), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	 }
} 