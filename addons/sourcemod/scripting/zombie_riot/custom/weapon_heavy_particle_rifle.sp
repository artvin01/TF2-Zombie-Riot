#pragma semicolon 1
#pragma newdecls required

static float f_AniSoundSpam[MAXPLAYERS];
static int i_shotsfired[MAXPLAYERS];
static float f_rest_time[MAXPLAYERS];
static float f_hud_timer[MAXPLAYERS];
static bool b_fullcharge_sound[MAXPLAYERS];

#define HEAVY_PARTICLE_RIFLE_SHIELD_SOUND1 "weapons/rescue_ranger_charge_01.wav"
#define HEAVY_PARTICLE_RIFLE_SHIELD_SOUND2 "weapons/rescue_ranger_charge_02.wav"
#define HEAVY_PARTICLE_RIFLE_FULLPOWER_SOUND "weapons/sentry_upgrading_steam1.wav"
#define HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND "weapons/sentry_wire_connect.wav"
#define HEAVY_PARTICLE_RIFLE_FIRING_PASSIVE_SOUND		"ambient/energy/weld1.wav"

static const char Spark_Sound[][] = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav",
};

void Heavy_Particle_Rifle_Mapstart()
{
	Zero(f_rest_time);
	Zero(f_AniSoundSpam);
	Zero(f_hud_timer);
	Zero(b_fullcharge_sound);
	PrecacheSound(HEAVY_PARTICLE_RIFLE_SHIELD_SOUND1, true);
	PrecacheSound(HEAVY_PARTICLE_RIFLE_SHIELD_SOUND2, true);
	PrecacheSound(HEAVY_PARTICLE_RIFLE_FULLPOWER_SOUND, true);
	PrecacheSound(HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND, true);
	PrecacheSound(HEAVY_PARTICLE_RIFLE_FIRING_PASSIVE_SOUND, true);
	PrecacheSoundArray(Spark_Sound);
}
public void Heavy_Particle_Rifle_M1(int client, int weapon, bool crit, int slot)
{
	float speed = 1500.0;
	float time = 10.0;
	float damage = 100.0;
	float angles[3];

	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);

	speed *= Attributes_Get(weapon, 103, 1.0);
		
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);

	GetClientEyeAngles(client,angles);

	float GameTime = GetGameTime();

	if(f_rest_time[client] < GameTime)
	{
		i_shotsfired[client]=0;
		b_fullcharge_sound[client]=false;
		EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND);
		EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND);
	}

	i_shotsfired[client]++;
	
	float max_multi = Attributes_Get(weapon, Attrib_Weapon_MaxDmgMulti, 1.0);	//dmg multi when reaching % of clip
	float min_multi = Attributes_Get(weapon, Attrib_Weapon_MinDmgMulti, 1.0);	//dmg multi when attacking for the first time 
	const int weapon_clip = 40;	//the weapons base clip size is 40. attributes then modify this value as it goes.

	float ammo_multi = Attributes_Get(weapon, Attrib_PapNumber, 1.0);	//how much of the clip is needed to reach max multi.

	int max_shots = RoundToFloor(weapon_clip * Attributes_Get(weapon, 4, 1.0) * ammo_multi);

	float Ratio =  float(i_shotsfired[client])/float(max_shots);

	//tl;dr. the Ratio can go over 1.0, so to prevent that I simply block it.
	if(Ratio > 1.0)
		Ratio = 1.0;

	float damage_bonus = min_multi + (max_multi - min_multi) * Ratio;

	damage*=damage_bonus;

	const int max_pitch = 120;
	const int min_pitch = 25;

	int pitch = RoundToFloor(min_pitch + (max_pitch - min_pitch) * (1.0 - Ratio));	//invert the Ratio.

	if(pitch<25)	//just incase it somehow happens
		pitch=25;

	EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_FIRING_PASSIVE_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.2, pitch);

	if(Ratio==1.0)
	{
		if(f_hud_timer[client]<GameTime)
		{
			f_hud_timer[client] = GameTime+0.5;
			PrintHintText(client, "Particle Reactor: [FULL POWER]");
			
		}
		if(!b_fullcharge_sound[client])
		{
			EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_FULLPOWER_SOUND);
			EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_FULLPOWER_SOUND);
			EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_FULLPOWER_SOUND);
			b_fullcharge_sound[client]=true;
		}
	}
	else
	{
		if(f_hud_timer[client]<GameTime)
		{
			f_hud_timer[client] = GameTime+0.5;
			PrintHintText(client, "입자 반응로: [%.0f％]",100.0*Ratio);
		}
	}

	f_rest_time[client] = GameTime + Attributes_Get(weapon, 6, 0.25) *0.4;	//make the rest timer scale on firerate.
	//so a "weapon fires too slow" case doesn't happen and completely fuck over the weapon!

	float accuracy = 0.75 * Attributes_Get(weapon, 106, 1.0);
	float accuracy2 = 1.75 * Attributes_Get(weapon, 106, 1.0);

	angles[0]+=GetRandomFloat(accuracy*-1.0, accuracy);
	angles[1]+=GetRandomFloat(accuracy2*-1.0, accuracy2);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "unusual_genplasmos_b_parent", angles);
	WandProjectile_ApplyFunctionToEntity(projectile, Projectile_Touch);

}
static void Projectile_Touch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	//we hit the ground, nuke the proj
	if(target == 0)
	{
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
		return;
	}
	//we hit something weird. do nothing.
	if(target < 0)
		return;
	//we hit a valid enemy, commence with eradication

	//Code to do damage position and ragdolls
	static float angles[3];
	GetRocketAngles(entity, angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	static float Entity_Position[3];
	WorldSpaceCenter(target, Entity_Position);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	if(owner < 0)
		owner = 0;
		
	EmitSoundToAll(Spark_Sound[GetRandomInt(0, sizeof(Spark_Sound)-1)], 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, ProjectileLoc);
	float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
	SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
	
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	RemoveEntity(entity);
}