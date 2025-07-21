
static float Duration_Pound[MAXPLAYERS];
static float Is_Duration_Pound[MAXENTITIES];


float AbilityGroundPoundReturnFloat(int client)
{
	return Is_Duration_Pound[client];
}
static int particle[MAXPLAYERS];
static int particle_1[MAXPLAYERS];
static int i_weaponused[MAXPLAYERS];

static int client_slammed_how_many_times[MAXPLAYERS];
static int client_slammed_how_many_times_limit[MAXPLAYERS];
static float client_slammed_pos[MAXPLAYERS][3];
static float client_slammed_forward[MAXPLAYERS][3];
static float client_slammed_right[MAXPLAYERS][3];
static float f_OriginalDamage[MAXPLAYERS];
static bool b_GroundPoundHit[MAXPLAYERS][MAXENTITIES];


void GroundSlam_Map_Precache()
{
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
	Zero(Duration_Pound);
	Zero2(b_GroundPoundHit);
}

public float AbilityGroundSlam(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
		return 0.0;
	}
	
	int StatsForCalcMultiAdd;
	Stats_Strength(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd = Stats_Strength(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 2.2;

	Ability_OnAbility_Ground_Pound(client, 1, weapon, damageDelt);
	return (GetGameTime() + 15.0);
}

public void Ability_OnAbility_Ground_Pound(int client, int level, int weapon, float damage)
{	
	
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
		return;
		
	f_OriginalDamage[client] = damage;
	client_slammed_how_many_times[client] = 0;
	client_slammed_how_many_times_limit[client] = (level * 2);
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
	velocity[0] *= 1.5;
	velocity[1] *= 1.5;
	velocity[2] = fmax(velocity[2], 600.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);		
		
	float flPos[3]; // original
	float flAng[3]; // original
		
	float flPos_l[3]; // original
	float flAng_l[3]; // original
	GetAttachment(viewmodelModel, "foot_L", flPos, flAng);
			

	i_weaponused[client] = EntIndexToEntRef(weapon);
	particle[client] = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 15.0);
			
	SetParent(viewmodelModel, particle[client], "foot_L");
	
	particle[client] = EntIndexToEntRef(particle[client]);

	GetAttachment(viewmodelModel, "foot_R", flPos_l, flAng_l);
			
	particle_1[client] = ParticleEffectAt(flPos_l, "raygun_projectile_red_crit", 15.0);
			
	SetParent(viewmodelModel, particle_1[client], "foot_R");

	particle_1[client] = EntIndexToEntRef(particle_1[client]);

	Duration_Pound[client] = GetGameTime() + 0.35;
	Is_Duration_Pound[client] = GetGameTime() + 5.0;
		
	SDKHook(client, SDKHook_PreThink, contact_ground_shockwave);

	for(int entity=1; entity<MAXENTITIES; entity++)
	{
		b_GroundPoundHit[client][entity] = false;
	}
	
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
		
		GetAbsOrigin(client, client_slammed_pos[client]);
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
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false,_,_,_,_,GroundPoundMeleeHitOnce);
	
		}
		EmitSoundToAll("ambient/atmosphere/terrain_rumble1.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
		CreateEarthquake(vecSwingEnd, 0.5, 350.0, 16.0, 255.0);

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecUp);
		CreateTimer(0.15, shockwave_explosions, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		SDKUnhook(client, SDKHook_PreThink, contact_ground_shockwave);
	}
	return Plugin_Continue;
}

float GroundPoundMeleeHitOnce(int entity, int victim, float damage, int weapon)
{
	if(b_GroundPoundHit[entity][victim])
	{
		damage *= -1.0;
		return damage;
	}
	b_GroundPoundHit[entity][victim] = true;
	return damage;
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
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, weapon, vecSwingEnd,_,_,_,false,_,_,_,_,GroundPoundMeleeHitOnce);
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