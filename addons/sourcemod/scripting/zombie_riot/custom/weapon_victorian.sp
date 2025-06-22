#pragma semicolon 1
#pragma newdecls required

#define SOUND_VIC_SHOT 	"mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
#define SOUND_VIC_IMPACT "weapons/explode1.wav"
#define SOUND_VIC_CHARGE_ACTIVATE 	"items/powerup_pickup_agility.wav"
#define SOUND_VIC_SUPER_CHARGE 	"ambient/cp_harbor/furnace_1_shot_05.wav"
#define SOUND_RAPID_SHOT_ACTIVATE "items/powerup_pickup_precision.wav"
#define SOUND_RAPID_SHOT_HYPER "mvm/mvm_warning.wav"
#define SOUND_OVERHEAT "player/medic_charged_death.wav"

#define MAX_VICTORIAN_SUPERCHARGE 10
static Handle h_TimerVictorianLauncherManagement[MAXPLAYERS+1] = {null, ...};
static bool HasRocketSteam[MAXPLAYERS];
static int i_VictoriaParticle[MAXPLAYERS];
static int LineofDefenseParticle_I[MAXPLAYERS];
static int LineofDefenseParticle_II[MAXPLAYERS];
static float VictoriaLauncher_HUDDelay[MAXPLAYERS];

static float f_ProjectileSinceSpawn[MAXENTITIES];
static float f_ProjectileDMG[MAXENTITIES];
static float f_ProjectileRadius[MAXENTITIES];

static int how_many_supercharge_left[MAXPLAYERS];
static int how_many_shots_reserved[MAXPLAYERS];
static bool Mega_Burst[MAXPLAYERS];

static bool During_Ability[MAXPLAYERS];
static bool Super_Hot[MAXPLAYERS];
static float Victoria_Rapid[MAXPLAYERS];

void ResetMapStartVictoria()
{
	Victoria_Map_Precache();
	Zero(how_many_supercharge_left);
	Zero(how_many_shots_reserved);
	Zero(f_ProjectileSinceSpawn);
	PrecacheSound("weapons/crit_power.wav");
}
static void Victoria_Map_Precache()
{
	PrecacheSound(SOUND_VIC_SHOT);
	PrecacheSound(SOUND_VIC_IMPACT);
	PrecacheSound(SOUND_VIC_CHARGE_ACTIVATE);
	PrecacheSound(SOUND_VIC_SUPER_CHARGE);
	PrecacheSound(SOUND_RAPID_SHOT_ACTIVATE);
	PrecacheSound(SOUND_RAPID_SHOT_HYPER);
	PrecacheSound(SOUND_OVERHEAT);
}

public void Enable_Victorian_Launcher(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(h_TimerVictorianLauncherManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
		{
			HasRocketSteam[client] = true;
			delete h_TimerVictorianLauncherManagement[client];
			h_TimerVictorianLauncherManagement[client] = null;
			DataPack pack;
			h_TimerVictorianLauncherManagement[client] = CreateDataTimer(0.1, Timer_Management_Victoria, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
		{
			HasRocketSteam[client] = true;
			DataPack pack;
			h_TimerVictorianLauncherManagement[client] = CreateDataTimer(0.1, Timer_Management_Victoria, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		
	}
	if(i_WeaponArchetype[weapon] == 28)	// Victoria
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerVictorianLauncherManagement[i])
			{
				ApplyStatusEffect(weapon, weapon, "Victorian Launcher's Call", 9999999.0);
				Attributes_SetMulti(weapon, 99, 1.1);
			}
		}
	}
}

static Action Timer_Management_Victoria(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerVictorianLauncherManagement[client] = null;
		DestroyVictoriaEffect(client, 1);
		return Plugin_Stop;
	}	

	CreateVictoriaEffect(client, weapon);
	return Plugin_Continue;
}

void Victorian_Melee_Swing(float &CustomMeleeRange, float &CustomMeleeWide)
{
	CustomMeleeRange = 50.0;
	CustomMeleeWide = 20.0;
}

public void Weapon_Victoria(int client, int weapon, bool crit)
{
	float Overheat = Ability_Check_Cooldown(client, 1);
	if(Overheat <= 0.0)
		Overheat = 0.0;
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction,"This Weapon still Over Heated! %.1f seconds!", Overheat);
		return;
	}
	int new_ammo = GetAmmo(client, 8);
	if(new_ammo < 3)
	{
		ClientCommand(client, "playgamesound weapons/shotgun_empty.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Ammo", 3);
		return;
	}
	new_ammo -= 3;
	SetAmmo(client, 8, new_ammo);
	CurrentAmmo[client][8] = GetAmmo(client, 8);
	float BaseDMG = 950.0;
	BaseDMG *= Attributes_Get(weapon, 2, 1.0);
	BaseDMG *= Attributes_Get(weapon, 621, 1.0);

	float Radius = EXPLOSION_RADIUS;
	Radius *= Attributes_Get(weapon, 99, 1.0);

	if(RaidbossIgnoreBuildingsLogic(1))
	{
		Radius *= 1.5;
	}
	//Rapid Shot
	if(During_Ability[client])
	{
		BaseDMG *= 0.8;
		if(Super_Hot[client])
		{
			BaseDMG *= 1.2;
		}
		//PrintToChatAll("Rapid Boom");
	}
	//Change Rocket
	if(how_many_supercharge_left[client] > 0 && !Mega_Burst[client])
	{
		BaseDMG *= 1.2;
		Radius *= 1.2;
		//PrintToChatAll("Strong Boom");
		if(how_many_supercharge_left[client] < 5)
		{
			BaseDMG *= 1.1;
			//PrintToChatAll("Stronger Boom");
		}
	}
	//Super Change
	else if(Mega_Burst[client])
	{
		BaseDMG *= 1.3 * how_many_shots_reserved[client];
		Radius *= 1 + how_many_shots_reserved[client]/2;
	}
	else
		BaseDMG *= 1.0;

	float speed = 800.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	speed *= Attributes_Get(weapon, 101, 1.0);
	speed *= Attributes_Get(weapon, 102, 1.0);

	float Angles[3];
	GetClientEyeAngles(client, Angles);
	Angles[0] -= 40.0;
	if(Angles[0] < -89.0)
	{
		Angles[0] = -89.0;
	}
	int projectile;
	if(Super_Hot[client] && !Mega_Burst[client])
		projectile = Wand_Projectile_Spawn(client, speed, 9.0, 0.0, -1, weapon, "flaregun_trail_crit_red",Angles,false);
	else if(!Super_Hot[client] && Mega_Burst[client])
	{
		projectile = Wand_Projectile_Spawn(client, speed, 9.0, 0.0, -1, weapon, "critical_rocket_red",Angles,false);
	}
	else if(!Super_Hot[client] && !Mega_Burst[client])
		projectile = Wand_Projectile_Spawn(client, speed, 9.0, 0.0, -1, weapon, "rockettrail",Angles,false);
	f_ProjectileSinceSpawn[projectile] = GetGameTime() + 1.0;
	f_ProjectileRadius[projectile] = Radius;
	f_ProjectileDMG[projectile] = BaseDMG;
	WandProjectile_ApplyFunctionToEntity(projectile, Shell_VictorianTouch);
	//SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
	EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 70, _, 0.9);
	if(i_CurrentEquippedPerk[client] == 5)
	{
		speed+=200.0;
	
		float vec[3], VecStart[3], SpeedReturn[3]; WorldSpaceCenter(client, VecStart);
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, speed, false, 45.0, true);

		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, vec);
		}
		else
		{
			delete swingTrace;
			int MaxTargethit = -1;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, speed, false, 45.0, true,MaxTargethit);
			TR_GetEndPosition(vec, swingTrace);
		}
		FinishLagCompensation_Base_boss();
		delete swingTrace;
	
		ArcToLocationViaSpeedProjectile(VecStart, vec, SpeedReturn, 1.0, 1.0);
		TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
	}
	Better_Gravity_Rocket(projectile, 55.0);

	if(how_many_supercharge_left[client] > 0)
		how_many_supercharge_left[client] -= 1;
	if(Mega_Burst[client])
	{
		how_many_supercharge_left[client] = 0;
		int flMaxHealth = SDKCall_GetMaxHealth(client);
		int flHealth = GetClientHealth(client);
		float Cooldown = 0.8; //Melee attack speed

		int health = flMaxHealth / how_many_shots_reserved[client];
		flHealth -= health;
		if((flHealth) < 1)
		{
			flHealth = 1;
		}
		SetEntityHealth(client, flHealth);
		
		Cooldown *= Attributes_Get(weapon, 6, 1.0); //2.4s
		Cooldown *= how_many_shots_reserved[client];
		Ability_Apply_Cooldown(client, 1, Cooldown);
		EmitSoundToAll(SOUND_OVERHEAT, client, SNDCHAN_AUTO, 70, _, 1.0, 70);
		float flPos[3];
		float flAng[3];
		GetAttachment (client, "effect_hand_r", flPos, flAng);
		int particle_hand = ParticleEffectAt(flPos, "flaregun_trail_crit_red", Cooldown);
		AddEntityToThirdPersonTransitMode(client, particle_hand);
		SetParent(client, particle_hand, "effect_hand_r");
		Mega_Burst[client] = false;
		//PrintToChatAll("MEGA Fire");
	}
}

static void Shell_VictorianTouch(int entity, int target)
{
	if (target < 0)	
	{
		//hits soemthing it shouldnt, ignore entirely.
		return;
	}
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(IsValidEntity(weapon))
	{
		//if(damagetype & DMG_CLUB)
		//Code to do damage position and ragdolls
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		
		float BaseDMG = f_ProjectileDMG[entity];
		
		if(f_ProjectileSinceSpawn[entity] > GetGameTime())
		{
			float Ratio = f_ProjectileSinceSpawn[entity] - GetGameTime();
			if(Ratio < 0.0)
			{
				Ratio = 0.01;
			}
			Ratio *= -1.0;
			Ratio += 1.0;
			if(Ratio < 0.25)
			{
				Ratio = 0.25;
			}
			BaseDMG *= Ratio;
		}
		else
		{
			if(IsValidClient(owner))
			{
				if(HasRocketSteam[owner])
					BaseDMG *= 1.1;
			}
		}
		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float spawnLoc[3];
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, f_ProjectileRadius[entity], Falloff, _, _, _, _, _, Did_Someone_Get_Hit);
		EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, entity, 70,_, 0.9, 70);
		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
		
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
	}
}

static void Did_Someone_Get_Hit(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity))
	{
		float Ability_CD = Ability_Check_Cooldown(entity, 2);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
			Ability_Apply_Cooldown(entity, 2, Ability_CD-(b_thisNpcIsARaid[victim] ? 1.0 : 0.2));
	}
}

public void Victorian_Chargeshot(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		float Overheat = Ability_Check_Cooldown(client, 1);
		if(Overheat <= 0.0)
			Overheat = 0.0;
		if(Overheat > 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"This Weapon still Over Heated! %.1f seconds!", Overheat);
			return;
		}
	
		if(!During_Ability[client])
		{
			if(Ability_Check_Cooldown(client, slot) < 0.0 && how_many_supercharge_left[client] == 0)
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 50.0);
				how_many_supercharge_left[client] += 10;
				EmitSoundToAll(SOUND_VIC_CHARGE_ACTIVATE, client, SNDCHAN_AUTO, 70, _, 1.0);
				//PrintToChatAll("Ammo replenished");
			}
			else if(how_many_supercharge_left[client] <= 5 && how_many_supercharge_left[client] > 1)
			{
				Rogue_OnAbilityUse(client, weapon);
				how_many_shots_reserved = how_many_supercharge_left;
				Mega_Burst[client] = true;
				EmitSoundToAll(SOUND_VIC_SUPER_CHARGE, client, SNDCHAN_AUTO, 70, _, 1.0);
				//PrintToChatAll("Super Shot Ready!");
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"You cannot use 2 abilities at the same time");
		}
	}
}

public void Victorian_Rapidshot(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		float Overheat = Ability_Check_Cooldown(client, 1);
		if(Overheat <= 0.0)
			Overheat = 0.0;
		if(Overheat > 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"This Weapon still Over Heated! %.1f seconds!", Overheat);
			return;
		}
		if(how_many_supercharge_left[client] > 0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"You cannot use 2 abilities at the same time");
			return;
		}
		if(Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);
			EmitSoundToAll(SOUND_RAPID_SHOT_ACTIVATE, client, SNDCHAN_AUTO, 70, _, 1.0);
			During_Ability[client] = true;
			Victoria_Rapid[client]=Attributes_Get(weapon, 6, 1.0);
			Attributes_SetMulti(weapon, 6, 0.5);
			//PrintToChatAll("Rapid Shot Activated");
		}
		else if(During_Ability[client])
		{
			Ability_Apply_Cooldown(client, slot, 60.0);
			Attributes_Set(weapon, 6, Victoria_Rapid[client]);
			During_Ability[client] = false;
			Super_Hot[client] =false;
			DestroyVictoriaEffect(client, 2);
			DestroyVictoriaEffect(client, 3);
			//PrintToChatAll("Rapid Shot Manually Deactivated");
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
	
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
		
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
}

static void CreateVictoriaEffect(int client, int weapon)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon && VictoriaLauncher_HUDDelay[client] < GetGameTime())
	{
		char wtf_Why_are_there_so_many_point_hints[512];
		int new_ammo = GetAmmo(client, 8);
		Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
		"Rockets: %i", new_ammo);
		float Overheat = Ability_Check_Cooldown(client, 1);
		if(Overheat <= 0.0)
		{
			Overheat = 0.0;
			if(During_Ability[client])
			{
				Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
				"%s\nPress R Again to Manually Deactivated", wtf_Why_are_there_so_many_point_hints);
				if(Super_Hot[client])
					Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
					"%s\nOVERDRIVE! [Gradually lose HP]", wtf_Why_are_there_so_many_point_hints);
			}
			else if(Mega_Burst[client])
			{
				Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
				"%s\nSUPER SHOT READY! [Next shot: X %i DMG]", wtf_Why_are_there_so_many_point_hints, how_many_shots_reserved[client]);
			}
			else
			{
				if(how_many_supercharge_left[client] <= 5 && how_many_supercharge_left[client] > 1)
					Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
					"%s\nPress M2 Again to Fire all at once", wtf_Why_are_there_so_many_point_hints, how_many_supercharge_left[client], MAX_VICTORIAN_SUPERCHARGE);
				if(how_many_supercharge_left[client]>0)
					Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
					"%s\nCharged Rockets [%i%/%i]", wtf_Why_are_there_so_many_point_hints, how_many_supercharge_left[client], MAX_VICTORIAN_SUPERCHARGE);
			}
		}
		else
		{
			Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
			"%s\n!!OVERHEATED!! [%.1f]", wtf_Why_are_there_so_many_point_hints, Overheat);
		}
		
		if(i_CurrentEquippedPerk[client] == 5)
			Format(wtf_Why_are_there_so_many_point_hints, sizeof(wtf_Why_are_there_so_many_point_hints),
			"%s\n[Aim Assist Online]", wtf_Why_are_there_so_many_point_hints);
		
		PrintHintText(client,"%s", wtf_Why_are_there_so_many_point_hints);
		
		VictoriaLauncher_HUDDelay[client] = GetGameTime() + 0.5;
	}

	if(During_Ability[client])
	{
		if(Ability_Check_Cooldown(client, 3) < 0.0)
		{
			Ability_Apply_Cooldown(client, 3, 60.0);
			Attributes_Set(weapon, 6, Victoria_Rapid[client]);
			During_Ability[client]=false;
			Super_Hot[client] =false;
		}
	
		int entity = EntRefToEntIndex(LineofDefenseParticle_I[client]);
		if(!IsValidEntity(entity))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particle = ParticleEffectAt(flPos, "medic_resist_fire", 0.0);
			SetParent(client, particle, "m_vecAbsOrigin");
			LineofDefenseParticle_I[client] = EntIndexToEntRef(particle);
		}
		if(!Super_Hot[client] && Ability_Check_Cooldown(client, 3) <= 15.0)
		{
			entity = EntRefToEntIndex(LineofDefenseParticle_II[client]);
			if(!IsValidEntity(entity))
			{
				float flPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particle = ParticleEffectAt(flPos, "utaunt_lavalamp_yellow_glow", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(client, particle, "m_vecAbsOrigin");
				LineofDefenseParticle_II[client] = EntIndexToEntRef(particle);
			}
			EmitSoundToAll(SOUND_RAPID_SHOT_HYPER, client, SNDCHAN_AUTO, 70, _, 0.9);
			Super_Hot[client]=true;
		}
		if(Super_Hot[client])
		{
			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.1, client);
			if(TeutonType[client] == TEUTON_NONE && IsPlayerAlive(client))
			{
				float MaxHealth = float(ReturnEntityMaxHealth(client));
				int GetHP = GetClientHealth(client);
				if(GetHP > 100)
				{
					float AbilityCD=Ability_Check_Cooldown(client, 3);
					float Overdrive = (12.0-(AbilityCD > 12.0 ? 11.9 : AbilityCD))/12.0*0.02;
					GetHP = GetHP-RoundToCeil(MaxHealth * Overdrive);
					if(GetHP < 100)
						GetHP = 100;
					SetEntityHealth(client, GetHP);
				}
			}
		}
	}
	else
	{
		DestroyVictoriaEffect(client, 2);
		DestroyVictoriaEffect(client, 3);
	}

	if(Mega_Burst[client] || During_Ability[client] || Super_Hot[client])
	{
		int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "eyeglow_l", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "eye_powerup_red_lvl_2", 0.0);
				AddEntityToThirdPersonTransitMode(entity, particle);
				SetParent(entity, particle, "eyeglow_l");
				i_VictoriaParticle[client] = EntIndexToEntRef(particle);
			}
		}
		if(!Mega_Burst[client])
		{
			TF2_AddCondition(client, TFCond_CritOnKill, 0.3);
			StopSound(client, SNDCHAN_STATIC, "weapons/crit_power.wav");
		}
	}
	else
		DestroyVictoriaEffect(client, 1);
}

static void DestroyVictoriaEffect(int client, int type)
{
	int entity;
	switch(type)
	{
		case 1:
		{
			entity = EntRefToEntIndex(i_VictoriaParticle[client]);
			if(IsValidEntity(entity))
				RemoveEntity(entity);
			i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
		}
		case 2:
		{
			entity = EntRefToEntIndex(LineofDefenseParticle_I[client]);
			if(IsValidEntity(entity))
				RemoveEntity(entity);
			LineofDefenseParticle_I[client] = INVALID_ENT_REFERENCE;
		}
		case 3:
		{
			entity = EntRefToEntIndex(LineofDefenseParticle_II[client]);
			if(IsValidEntity(entity))
				RemoveEntity(entity);
			LineofDefenseParticle_II[client] = INVALID_ENT_REFERENCE;
		}
	}
}