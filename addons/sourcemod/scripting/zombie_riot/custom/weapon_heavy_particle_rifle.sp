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

#define HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS 2.0

static const char Spark_Sound[][] = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav",
};

public void Heavy_Particle_Rifle_Mapstart()
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
	for (int i = 0; i < (sizeof(Spark_Sound));	   i++) { PrecacheSound(Spark_Sound[i]);	   }
}


#define BASE_HEAVYRIFLE_CLIPSIZE_NEED (40.0/* * 2.0*/)
public void Heavy_Particle_Rifle_M1(int client, int weapon, const char[] classname, bool &result)
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

	i_shotsfired[client]++;

	if(f_rest_time[client] < GameTime)
	{
		i_shotsfired[client]=0;
		b_fullcharge_sound[client]=false;
		EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND);
		EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_BEGIN_REACTOR_SOUND);
	}
	else
	{
		int max_shots= RoundToFloor(BASE_HEAVYRIFLE_CLIPSIZE_NEED * Attributes_Get(weapon, 4, 1.0)*0.75/HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS);

		float ratio =  float(i_shotsfired[client])/float(max_shots);

		int pitch = 25+150-RoundToFloor(100*(ratio/HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS));

		if(pitch<25)	//just incase it somehow happens
			pitch=25;

		EmitSoundToClient(client, HEAVY_PARTICLE_RIFLE_FIRING_PASSIVE_SOUND ,_, SNDCHAN_STATIC, 100, _, 0.2, pitch);

		if(ratio>=HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS)
		{
			damage*=HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS;
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
			damage*=ratio;
			if(f_hud_timer[client]<GameTime)
			{
				f_hud_timer[client] = GameTime+0.5;
				PrintHintText(client, "Particle Reactor: [%.1f/%.1f]",ratio,HEAVY_PARTICLE_RIFLE_MAX_DMG_BONUS);
				
			}
		}
	}

	

	f_rest_time[client] = GameTime + 0.25;

	float accuracy = 0.75 * Attributes_Get(weapon, 106, 1.0);
	float accuracy2 = 1.75 * Attributes_Get(weapon, 106, 1.0);

	angles[0]+=GetRandomFloat(accuracy*-1.0, accuracy);
	angles[1]+=GetRandomFloat(accuracy2*-1.0, accuracy2);

	Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_HEAVY_PARTICLE_RIFLE, weapon, "unusual_genplasmos_b_parent", angles);

}
/*
public float Player_OnTakeDamage_Heavy_Particle_Rifle(int victim, float &damage, int attacker, int weapon, float damagePosition[3])
{
	// need position of either the inflictor or the attacker
	float actualDamagePos[3];
	float victimPos[3];
	float angle[3];
	float eyeAngles[3];
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);

	bool BlockAnyways = false;
	if(damagePosition[0]) //Make sure if it doesnt
	{
		if(IsValidEntity(attacker))
		{
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", actualDamagePos);
		}
		else
		{
			BlockAnyways = true;
		}
	}
	else
	{
		actualDamagePos = damagePosition;
	}

	GetVectorAnglesTwoPoints(victimPos, actualDamagePos, angle);
	GetClientEyeAngles(victim, eyeAngles);


	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;
		
	// now it's a simple check
	if ((yawOffset >= MINYAW_RAID_SHIELD && yawOffset <= MAXYAW_RAID_SHIELD) || BlockAnyways)
	{
		damage *= 0.75;	//25% resist. God I hope this weapon doesn't become a tank weapon please.
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					EmitSoundToClient(victim, HEAVY_PARTICLE_RIFLE_SHIELD_SOUND1, victim, _, 85, _, 0.8, GetRandomInt(90, 100));
				}
				case 2:
				{
					EmitSoundToClient(victim, HEAVY_PARTICLE_RIFLE_SHIELD_SOUND2, victim, _, 85, _, 0.8, GetRandomInt(90, 100));
				}
			}
		}
	}
	return damage;
}
*/
public void Weapon_Heavy_Particle_Rifle(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
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
		RemoveEntity(entity);
	}
}