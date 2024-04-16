#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerVictorianLauncherManagement[MAXPLAYERS+1] = {null, ...};
#define SOUND_VIC_SHOT 	"weapons/doom_rocket_launcher.wav"
#define SOUND_VIC_IMPACT "weapons/explode1.wav"
#define SOUND_VIC_CHARGE_ACTIVATE 	"items/powerup_pickup_agility.wav"
#define MAX_VICTORIAN_CHARGE 5
#define MAX_VICTORIAN_SUPERCHARGE 10
static int i_VictoriaParticle[MAXTF2PLAYERS];
static int how_many_times_fired[MAXTF2PLAYERS];
static int how_many_supercharge_left[MAXTF2PLAYERS];
static int how_many_shots_reserved[MAXTF2PLAYERS];
static bool During_Ability[MAXPLAYERS];
static bool Toggle_Burst[MAXPLAYERS];
static bool Mega_Burst[MAXPLAYERS];
static bool Overheat[MAXPLAYERS];
static float f_VIChuddelay[MAXPLAYERS+1]={0.0, ...};
static float f_VICAbilityActive[MAXPLAYERS+1]={0.0, ...};

void ResetMapStartVictoria()
{
	Victoria_Map_Precache();
	Zero(f_VIChuddelay);
	Zero(how_many_times_fired);
	Zero(how_many_supercharge_left);
	Zero(how_many_shots_reserved);
}
void Victoria_Map_Precache()
{
	PrecacheSound(SOUND_VIC_SHOT);
	PrecacheSound(SOUND_VIC_IMPACT);
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
		Toggle_Burst[client] = false;
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
		Toggle_Burst[client] = false;
		During_Ability[client] = false;
		Overheat[client] = false;
		Mega_Burst[client] = false;
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
					else
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
	float damage = 300.0;
	damage *= 0.8; //Reduction
	damage *= Attributes_Get(weapon, 2, 1.0);	

	float speed = 1000.0;
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_VICTORIAN_LAUNCHER, weapon, "rockettrail",_,false);
	EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 140, _, 1.0, 70);

	SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);

	if(how_many_supercharge_left[client] > 0)
	{
		During_Ability[client] = true;
		how_many_supercharge_left[client] -= 1;
	}
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
	else
	{
		During_Ability[client] = false;
		how_many_supercharge_left[client] = 0;
		how_many_times_fired[client] = 0;
	}
}

public void Shell_VictorianTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(IsValidEntity(weapon))
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float BaseDMG = 700.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);

		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		if(how_many_times_fired[owner] >= 5 && !During_Ability[owner] &&!Mega_Burst[owner])
		{
			BaseDMG *= 1.5;
			how_many_times_fired[owner] = 0;
			Radius *= 1.5;
		}
		else if(how_many_supercharge_left[owner] > 0 && !Mega_Burst[owner])
		{
			BaseDMG *= 1.25;
			if(how_many_supercharge_left[owner] <= 5)
			{
				BaseDMG *= 1.2;
			}
		}
		else if(Mega_Burst[owner])
		{
			BaseDMG *= how_many_shots_reserved;
			float Cooldown = 5.0;
			Cooldown *= StringToFloat(how_many_shots_reserved);
			Overheat[owner] = true;
			ApplyTempAttrib(weapon, 6, 0.0, Cooldown);
			float flPos[3]; // original
			float flAng[3]; // original
			GetAttachment(owner, "effect_hand_r", flPos, flAng);
			int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", Cooldown);
		}
		else
		{
			BaseDMG *= 1.0;
		}
		float spawnLoc[3];
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
		EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, _, 100, _,0.6, GetRandomInt(55, 80));
		PrintToChatAll("Boom");

		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else
	{
		PrintToChatAll("haha error message :) complain to Beep :)"); //error message lol
	}
	
}
public void Victorian_Chargeshot(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && how_many_supercharge_left > 5)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			how_many_supercharge_left += 10;
			EmitSoundToAll(SOUND_VIC_CHARGE_ACTIVATE, client, SNDCHAN_AUTO, 100, _, 0.6);
		}
		else if (how_many_supercharge_left[client] <= 5 && how_many_supercharge_left[client] > 0)
		{
			Rogue_OnAbilityUse(weapon);
			how_many_shots_reserved = how_many_supercharge_left;
			how_many_supercharge_left = 0;
			int flMaxHealth = SDKCall_GetMaxHealth(client);
			int flHealth = GetClientHealth(client);
			Mega_Burst[client] = true;
			
			int health = flMaxHealth / how_many_supercharge_left;
			flHealth = health;
			if((flHealth) < 1)
			{
				flHealth = 1;
			}
			SetEntityHealth(client, flHealth);
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

void CreateVictoriaEffect(int client)
{
	DestroyVictoriaEffect(client);
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "eyeglow_R", flPos);
	int particle = ParticleEffectAt(flPos, "raygun_projectile_blue", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle);
	i_VictoriaParticle[client][0] = EntIndexToEntRef(particle);
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