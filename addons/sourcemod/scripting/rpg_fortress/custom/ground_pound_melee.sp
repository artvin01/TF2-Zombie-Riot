
static float Duration_Pound[MAXTF2PLAYERS];
static float Is_Duration_Pound[MAXTF2PLAYERS];


float AbilityGroundPoundReturnFloat(int client)
{
	return Is_Duration_Pound[client];
}
static int particle[MAXTF2PLAYERS];
static int particle_1[MAXTF2PLAYERS];
static int i_weaponused[MAXTF2PLAYERS];

static int client_slammed_how_many_times[MAXTF2PLAYERS];
static int client_slammed_how_many_times_limit[MAXTF2PLAYERS];
static float client_slammed_pos[MAXTF2PLAYERS][3];
static float client_slammed_forward[MAXTF2PLAYERS][3];
static float client_slammed_right[MAXTF2PLAYERS][3];
static float f_OriginalDamage[MAXTF2PLAYERS];


#define spirite "spirites/zerogxplode.spr"

#define EarthStyleShockwaveRange 250.0
void GroundSlam_Map_Precache()
{
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
	Zero(Duration_Pound);
}

public float AbilityGroundSlam(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		static char classname[36];
		GetEntityClassname(weapon, classname, sizeof(classname));
		if (TF2_GetClassnameSlot(classname) == TFWeaponSlot_Melee && !i_IsWandWeapon[weapon])
		{
			Ability_OnAbility_Ground_Pound(client, 1, weapon);
			return (GetGameTime() + 40.0);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
			return 0.0;
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

public void Ability_OnAbility_Ground_Pound(int client, int level, int weapon)
{
	float damage;
	
	damage = Config_GetDPSOfEntity(weapon);

	damage *= 3.0;		

	f_OriginalDamage[client] = damage;
	client_slammed_how_many_times[client] = 0;
	client_slammed_how_many_times_limit[client] = (level * 2);
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	velocity[0] = 0.0;
	velocity[1] = 0.0;
	velocity[2] = fmax(velocity[2], 600.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);		
		
	float flPos[3]; // original
	float flAng[3]; // original
		
	float flPos_l[3]; // original
	float flAng_l[3]; // original
	GetAttachment(client, "foot_L", flPos, flAng);
			

	i_weaponused[client] = EntIndexToEntRef(weapon);
	particle[client] = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 15.0);
			
	SetParent(client, particle[client], "foot_L");
	
	particle[client] = EntIndexToEntRef(particle[client]);

	GetAttachment(client, "foot_R", flPos_l, flAng_l);
			
	particle_1[client] = ParticleEffectAt(flPos_l, "raygun_projectile_red_crit", 15.0);
			
	SetParent(client, particle_1[client], "foot_R");

	particle_1[client] = EntIndexToEntRef(particle_1[client]);

	Duration_Pound[client] = GetGameTime() + 1.0;
	Is_Duration_Pound[client] = GetGameTime() + 5.0;
		
	SDKHook(client, SDKHook_PreThink, contact_ground_shockwave);
	EmitSoundToAll("weapons/physcannon/energy_sing_flyby2.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
	f_ImmuneToFalldamage[client] = GetGameTime() + 0.5;
}

public Action contact_ground_shockwave(int client)
{
	Is_Duration_Pound[client] = GetGameTime() + 1.0;
	f_ImmuneToFalldamage[client] = GetGameTime() + 0.5;
	if (Duration_Pound[client] < GetGameTime())
	{
		SetEntityGravity(client, 10.0);
	}
	else
	{
		SetEntityGravity(client, 1.0);
	}
	int flags = GetEntityFlags(client);
	
	if (Duration_Pound[client] < GetGameTime() && ((flags & FL_ONGROUND)==1 || (flags & (FL_SWIM|FL_INWATER))))
	{
		Is_Duration_Pound[client] = 0.0;

		SetEntityGravity(client, 1.0);
		if(IsValidEntity(EntRefToEntIndex(particle[client])))
			RemoveEntity(EntRefToEntIndex(particle[client]));
			
		if(IsValidEntity(EntRefToEntIndex(particle_1[client])))
			RemoveEntity(EntRefToEntIndex(particle_1[client]));

		float vecUp[3];
		
		GetVectors(client, client_slammed_forward[client], client_slammed_right[client], vecUp);
		
		client_slammed_pos[client] = GetAbsOrigin(client);
		client_slammed_pos[client][2] += 5.0;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		DataPack pack = new DataPack();
		pack.WriteFloat(vecSwingEnd[0]);
		pack.WriteFloat(vecSwingEnd[1]);
		pack.WriteFloat(vecSwingEnd[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);
		int weapon = EntRefToEntIndex(i_weaponused[client]);
		if(IsValidEntity(weapon))
		{
			i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_CLUB_DAMAGE;
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false);
		}
		EmitSoundToAll("ambient/atmosphere/terrain_rumble1.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
		CreateEarthquake(vecSwingEnd, 0.5, 350.0, 16.0, 255.0);

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecUp);
		CreateTimer(0.15, shockwave_explosions, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		SDKUnhook(client, SDKHook_PreThink, contact_ground_shockwave);
	}
	return Plugin_Continue;
}


public Action shockwave_explosions(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		client_slammed_how_many_times[client] += 1;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		DataPack pack = new DataPack();
		pack.WriteFloat(vecSwingEnd[0]);
		pack.WriteFloat(vecSwingEnd[1]);
		pack.WriteFloat(vecSwingEnd[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);

		int weapon = EntRefToEntIndex(i_weaponused[client]);
		if(IsValidEntity(weapon))
		{
			i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_CLUB_DAMAGE;
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false);
		}

		if(client_slammed_how_many_times[client] > client_slammed_how_many_times_limit[client])
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}