#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerVictorianLauncherManagement[MAXPLAYERS+1] = {null, ...};
#define SOUND_VIC_SHOT 	"weapons/doom_rocket_launcher.wav"
#define SOUND_VIC_IMPACT "weapons/explode1.wav"
static int i_VictoriaParticle[MAXTF2PLAYERS];

void ResetMapStartVictoria()
{
	Victoria_Map_Precache();
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
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WEST_REVOLVER)
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
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateVictoriaEffect(client);
	}
		
	return Plugin_Continue;
}

public void Weapon_Victoria(int client, int weapon, bool crit)
{
	float damage = 500.0;
	damage *= 0.8; //Reduction
	damage *= Attributes_Get(weapon, 2, 1.0);	

	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_VICTORIAN_LAUNCHER, weapon, "rockettrail",_,false);
	EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 140, _, 1.0, 70);

	SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
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
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float BaseDMG = 650.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);
		Radius *= Attributes_Get(weapon, 100, 1.0);

		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		float spawnLoc[3];
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
		EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, _, 100, _,0.6, GetRandomInt(55, 80));

		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);

		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);

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

void CreateVictoriaEffect(int client)
{
	DestroyVictoriaEffect(client);
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3]; 
		float flAng[3];
		int particle = ParticleEffectAt(flPos, "raygun_projectile_blue", 0.0);
		GetAttachment(viewmodelModel, "eyeglow_R", flPos, flAng);
		SetParent(viewmodelModel, particle, "eyeglow_R");
		i_VictoriaParticle[client][0] = EntIndexToEntRef(particle);
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