#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerVictorianLauncherManagement[MAXPLAYERS+1] = {null, ...};
#define SOUND_VIC_SHOT 	"weapons/doom_rocket_launcher.wav"
#define SOUND_VIC_IMPACT "weapons/explode1.wav"
#define SOUND_VIC_CHARGE_ACTIVATE 	"items/powerup_pickup_agility.wav"
#define SOUND_VIC_SUPER_CHARGE 	"ambient/portcullis_up.wav"
#define SOUND_RAPID_SHOT_ACTIVATE "items/powerup_pickup_precision.wav"
#define SOUND_RAPID_SHOT_HYPER "mvm/mvm_warning.wav"
//#define MAX_VICTORIAN_CHARGE 5
#define MAX_VICTORIAN_SUPERCHARGE 10
static int i_VictoriaParticle[MAXTF2PLAYERS];
static int hurt_count[MAXTF2PLAYERS];
//static int how_many_times_fired[MAXTF2PLAYERS];
static int how_many_supercharge_left[MAXTF2PLAYERS];
static int how_many_shots_reserved[MAXTF2PLAYERS];
static bool During_Ability[MAXPLAYERS];
static bool Super_Hot[MAXPLAYERS];
//static bool Toggle_Burst[MAXPLAYERS];
static bool Mega_Burst[MAXPLAYERS];
static bool Overheat[MAXPLAYERS];
static float f_VIChuddelay[MAXPLAYERS+1]={0.0, ...};
static float f_VICAbilityActive[MAXPLAYERS+1]={0.0, ...};
static float Victorian_Rapid_Spread = 3.0;


void ResetMapStartVictoria()
{
	Victoria_Map_Precache();
	Zero(f_VIChuddelay);
	//Zero(how_many_times_fired);
	Zero(how_many_supercharge_left);
	Zero(hurt_count);
	Zero(how_many_shots_reserved);
}
void Victoria_Map_Precache()
{
	PrecacheSound(SOUND_VIC_SHOT);
	PrecacheSound(SOUND_VIC_IMPACT);
	PrecacheSound(SOUND_VIC_CHARGE_ACTIVATE);
	PrecacheSound(SOUND_VIC_SUPER_CHARGE);
	PrecacheSound(SOUND_RAPID_SHOT_ACTIVATE);
	PrecacheSound(SOUND_RAPID_SHOT_HYPER);
}


public void Enable_Victorian_Launcher(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerVictorianLauncherManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerVictorianLauncherManagement[client];
			h_TimerVictorianLauncherManagement[client] = null;
			DataPack pack;
			h_TimerVictorianLauncherManagement[client] = CreateDataTimer(0.1, Timer_Management_Victoria, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
	{
		DataPack pack;
		h_TimerVictorianLauncherManagement[client] = CreateDataTimer(0.1, Timer_Management_Victoria, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Victoria(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerVictorianLauncherManagement[client] = null;
		DestroyVictoriaEffect(client);
		//Toggle_Burst[client] = false;
		During_Ability[client] = false;
		Overheat[client] = false;
		Mega_Burst[client] = false;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateVictoriaEffect(client);
		Victorian_Cooldown_Logic(client, weapon);
	}
	else
	{
		DestroyVictoriaEffect(client);
	}
	return Plugin_Continue;
}
public void Victorian_Cooldown_Logic(int client, int weapon)
{
	if(f_VIChuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_VICAbilityActive[client] < GetGameTime())
			{
				if(!Overheat[client])
				{
					if(Mega_Burst[client])
					{
						PrintHintText(client,"SUPER SHOT READY! [Next shot: X %i DMG]", how_many_shots_reserved[client]);
					}
					/*
					else if(!During_Ability[client] && !Mega_Burst[client])
					{
						if(how_many_times_fired[client] < MAX_VICTORIAN_CHARGE)
						{
							PrintHintText(client,"Flare Shot Charge [%i%/%i]", how_many_times_fired[client], MAX_VICTORIAN_CHARGE);
						}
						else
						{
							PrintHintText(client,"Flare Shot Ready");
						}
					}
					*/
					else if(!Mega_Burst[client] && how_many_supercharge_left[client] <= 5 && how_many_supercharge_left[client] > 0)
					{
						PrintHintText(client,"Charged Rockets [%i%/%i] \n Press M2 Again to Fire all at once", how_many_supercharge_left[client], MAX_VICTORIAN_SUPERCHARGE);
					}
					else if(!Mega_Burst[client] && how_many_supercharge_left[client]>5)
					{
						PrintHintText(client,"Charged Rockets [%i%/%i]", how_many_supercharge_left[client], MAX_VICTORIAN_SUPERCHARGE);
					}
				}
				else
				{
					PrintHintText(client,"OVERHEATED!");
				}
			}

			else
			{
				PrintHintText(client,"Hi ;D");
			}
			
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			f_VIChuddelay[client] = GetGameTime() + 0.5;
		}
	}
}

public void Weapon_Victoria(int client, int weapon, bool crit)
{
	float damage = 10.0;
	//damage *= 0.8; //Reduction
	damage *= Attributes_Get(weapon, 2, 1.0);	

	float speed = 1000.0;
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);
	
	if(!Overheat[client])
	{
		/*
		float Angles[3];
		if(During_Ability[client])
		{
			for (int spread = 0; spread < 3; spread++)
			{
				GetClientEyeAngles(client, Angles);
				Angles[spread] += GetRandomFloat(-Victorian_Rapid_Spread, Victorian_Rapid_Spread);
			}

		}
		else
		{
			Angles[spread] = 0
		}
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_VICTORIAN_LAUNCHER, weapon, "rockettrail",Angles,false);
		*/
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_VICTORIAN_LAUNCHER, weapon, "rockettrail",_,false);
		EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 140, _, 1.0, 70);

		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
	}


	if(how_many_supercharge_left[client] > 0)
	{
		//During_Ability[client] = true;
		how_many_supercharge_left[client] -= 1;
		PrintToChatAll("Ammo -1");
	}
	if(Mega_Burst[client])
	{
		how_many_supercharge_left[client] = 0;
		int flMaxHealth = SDKCall_GetMaxHealth(client);
		int flHealth = GetClientHealth(client);
		float Cooldown = 5.0;

		int health = flMaxHealth / how_many_shots_reserved[client];
		flHealth -= health;
		if((flHealth) < 1)
		{
			flHealth = 1;
		}
		SetEntityHealth(client, flHealth);	

		Cooldown *= how_many_shots_reserved[client];
		Overheat[client] = true;
		//Give_bomb_back[client] = 
		CreateTimer(Cooldown, Timer_Booooool, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		/*
		if(OnTimer[client])
		{
			KillTimer(OnTimer[client]);
			OnTimer[client] = null;
		}
		*/
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
		int particle_Hand = ParticleEffectAt(flPos, "buildingdamage_dispenser_fire1", Cooldown);
		SetParent(client, particle_Hand, "effect_hand_r");

		Mega_Burst[client] = false;

		PrintToChatAll("MEGA Fire");
	}
	/*
	if(!During_Ability[client])
	{
		if(how_many_times_fired[client] <= MAX_VICTORIAN_CHARGE)
		{
			how_many_times_fired[client] += 1;
		}
		else
		{
			how_many_times_fired[client] = MAX_VICTORIAN_CHARGE;
		}
	}
	*/
}

public Action Timer_Booooool(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	Overheat[client] = false;
	During_Ability[client] = false;
	return Plugin_Stop;
}
public void Shell_VictorianTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(IsValidEntity(weapon))
	{
		//if(damagetype & DMG_CLUB)
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float BaseDMG = 2500.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);

		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
/*
		if(how_many_times_fired[owner] >= 5 && !Mega_Burst[owner])
		{
			BaseDMG *= 1.5;
			how_many_times_fired[owner] = 0;
			Radius *= 1.25;
		}
*/		if(During_Ability[owner])
		{
			BaseDMG *= 1.1;
			
			PrintToChatAll("Rapid Boom");
		}
		if(how_many_supercharge_left[owner] > 0 && !Mega_Burst[owner])
		{
			BaseDMG *= 1.25;
			PrintToChatAll("Strong Boom");
			if(how_many_supercharge_left[owner] < 5)
			{
				BaseDMG *= 1.2;
				PrintToChatAll("Stronger Boom");
			}
		}
		else if(Mega_Burst[owner])
		{
			BaseDMG *= how_many_shots_reserved[owner];
			Radius *= 1 + how_many_shots_reserved[owner]/2;
			PrintToChatAll("Mega Boom");
		}
		else
		{
			BaseDMG *= 1.0;
			PrintToChatAll("Boom");
		}
		
		
		if(!Overheat[owner])
		{
			float spawnLoc[3];
			Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
			EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, _, 100, _,0.6, GetRandomInt(55, 80));
			ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
			
			if(IsValidEntity(particle))
			{
				RemoveEntity(particle);
			}
			RemoveEntity(entity);
		}
	}
	else
	{
		PrintToChatAll("Cheeky attack cancel exploit won't work lul"); //error message lol
	}
	
}

public void Victorian_Chargeshot(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if(!During_Ability[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0 && how_many_supercharge_left[client] == 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 50.0);
				how_many_supercharge_left[client] += 10;
				EmitSoundToAll(SOUND_VIC_CHARGE_ACTIVATE, client, SNDCHAN_AUTO, 100, _, 0.6);
				PrintToChatAll("Ammo replenished");
			}
			else if (how_many_supercharge_left[client] <= 5 && how_many_supercharge_left[client] > 0)
			{
				Rogue_OnAbilityUse(weapon);
				how_many_shots_reserved = how_many_supercharge_left;
				Mega_Burst[client] = true;
				PrintToChatAll("Super Shot Ready!");
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability on cooldown", Ability_CD);
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
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 60.0);
			EmitSoundToAll(SOUND_RAPID_SHOT_ACTIVATE, client, SNDCHAN_AUTO, 120, _, 1.0);
			During_Ability[client] = true;
			CreateTimer(15.0, Timer_RapidFire, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(30, Timer_Booooool, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			PrintToChatAll("Rapid Shot Activated");
			ApplyTempAttrib(weapon, 6, 0.5, 30.0);
			float flPos[3]; // original
			float flAng[3]; // original
			GetAttachment(client, "m_vecAbsOrigin", flPos, flAng);
			int particle_Base = ParticleEffectAt(flPos, "medic_resist_fire", 30.0);
			SetParent(client, particle_Base, "m_vecAbsOrigin");
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
	
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
		
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability on cooldown", Ability_CD);
		}
	}
}
public Action Timer_RapidFire(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	PrintToChatAll("Rapid Hyper Activate");
	EmitSoundToAll(SOUND_RAPID_SHOT_HYPER, client, SNDCHAN_AUTO, 140, _, 0.6);
	CreateTimer(0.1, Victorian_DrainHealth, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	TF2_AddCondition(client, TFCond_HalloweenCritCandy, 15.0, client);
	return Plugin_Stop;
}
public Action Victorian_DrainHealth(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(IsPlayerAlive(client) && TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
		{
			int health = GetClientHealth(client) * 95 / 100;
			if(health < 100)
				health = 100;
			
			SetEntityHealth(client, health);
			return Plugin_Continue;
		}
	}
	else
	{
		TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
	}
	return Plugin_Stop;
}

void CreateVictoriaEffect(int client)
{
	DestroyVictoriaEffect(client);
	
	float flPos[3];
	float flAng[3];
	GetAttachment (client, "eyeglow_l", flPos, flAng);
	int particle = ParticleEffectAt(flPos, "eye_powerup_red_lvl_2", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle, "eyeglow_l");
	i_VictoriaParticle[client][0] = EntIndexToEntRef(particle);


	if(Super_Hot[client])
	{

	}
}
void DestroyVictoriaEffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
}