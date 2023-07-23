#pragma semicolon 1
#pragma newdecls required

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int SSS_overheat[MAXENTITIES]={0, ...};
static float starshooter_hud_delay[MAXTF2PLAYERS];
static int Star_HitTarget[MAXENTITIES][MAXENTITIES];
static float StarShooterCoolDelay[MAXTF2PLAYERS];

Handle Timer_Starshooter_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

#define COLLISION_DETECTION_MODEL	"models/props_lab/monitor01a.mdl"
#define SOUND_WAND_SHOT_STAR 	"weapons/gauss/fire1.wav"
#define SOUND_ZAP_STAR "ambient/energy/zap1.wav"

void SSS_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_STAR);
	PrecacheSound(SOUND_ZAP_STAR);
	PrecacheModel(COLLISION_DETECTION_MODEL);
	Zero(StarShooterCoolDelay);

}


void Reset_stats_starshooter()
{
	Zero(Timer_Starshooter_Management);
	Zero(starshooter_hud_delay);
	Zero(StarShooterCoolDelay);
}
/*
The damage getting lower after having a higher overheat amount now works properly but i am not quite sure how to make a proper counter to make it tick down,
my current plan was to make it decrease by 1 overheat charge every half a second after the weapon hasn't been used for a full 2 seconds, just idk how to make a timer for that
*/

public void Super_Star_Shooter_Main(int client, int weapon, bool crit, int slot)
{
	Enable_StarShooter(client, weapon);
	Ability_Apply_Cooldown(client, slot, 2.0);
	StarShooterCoolDelay[client] = GetGameTime() + 2.0;
	SSS_overheat[client] += 1;

	float damage = 1000.0;
		
	if(SSS_overheat[client] > 15)
	{
		damage = 750.0;
	} 
	if(SSS_overheat[client] > 18)
	{
		damage = 500.0;
	} 
	if(SSS_overheat[client] > 20)
	{
		damage = 250.0;
	}
			
	if(SSS_overheat[client] > 25)
	{
		SSS_overheat[client] = 25;
	}

	float speed = 1750.0;
	float time = 5000.0/speed;
	
	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	time *= Attributes_Get(weapon, 101, 1.0);
	
	time *= Attributes_Get(weapon, 102, 1.0);
		
	int iRot = CreateEntityByName("func_door_rotating");
	if(iRot == -1) return;
	
	float fPos[3];
	GetClientEyePosition(client, fPos);
	
	DispatchKeyValueVector(iRot, "origin", fPos);
	DispatchKeyValue(iRot, "distance", "99999");
	DispatchKeyValueFloat(iRot, "speed", speed);
	DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
	DispatchSpawn(iRot);
	SetEntityCollisionGroup(iRot, 27);
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "Open");
//	EmitSoundToAll(SOUND_WAND_SHOT_STAR, client, _, 65, _, 0.7);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
	Wand_Launch(client, iRot, speed, time, damage);
	
}

static void Wand_Launch(int client, int iRot, float speed, float time, float damage, int pap = 0)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return;

	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iCarrier, "model", COLLISION_DETECTION_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);
				
				
	CClotBody npc = view_as<CClotBody>(iCarrier);
	npc.UpdateCollisionBox();
				
	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_NOCLIP);
	
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iCarrier));
	RequestFrame(See_Projectile_Team, EntIndexToEntRef(iRot));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;

	if(pap == 1)
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal_blue", 5.0);
	}
	else
	{
		particle = ParticleEffectAt(position, "powerup_icon_supernova", 5.0);
	}
	
        
	
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	for (int i = 0; i < MAXENTITIES; i++)
	{
		Star_HitTarget[iCarrier][i] = false;
	}
	
	SDKHook(iCarrier, SDKHook_StartTouch, Event_SSS_OnHatTouch);
}

public Action Event_SSS_OnHatTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		if(!Star_HitTarget[entity][other]) //dont hit the same target 50450435 times.
		{
			Star_HitTarget[entity][other] = true;
			
			//Code to do damage position and ragdolls
			static float angles[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			Entity_Position = WorldSpaceCenter(target);
			//Code to do damage position and ragdolls
			
			SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , _);	// 2048 is DMG_NOGIB?
			int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
			if(IsValidEntity(particle) && particle != 0)
			{
				EmitSoundToAll(SOUND_ZAP_STAR, other, SNDCHAN_STATIC, 70, _, 0.6);
			//	RemoveEntity(particle);
			}
			
			Damage_Projectile[entity] /= LASER_AOE_DAMAGE_FALLOFF;
		}
	//	RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP_STAR, entity, SNDCHAN_STATIC, 70, _, 0.6);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}



public void Enable_StarShooter(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Starshooter_Management[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 2) //2
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(Timer_Starshooter_Management[client]);
			Timer_Starshooter_Management[client] = INVALID_HANDLE;
			DataPack pack;
			Timer_Starshooter_Management[client] = CreateDataTimer(0.1, Timer_Management_StarShooter, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 2) //
	{
		DataPack pack;
		Timer_Starshooter_Management[client] = CreateDataTimer(0.1, Timer_Management_StarShooter, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_StarShooter(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Starshooter_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Starshooter(client);
		}
		else
			Kill_Timer_Starshooter(client);
	}
	else
		Kill_Timer_Starshooter(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Starshooter(int client)
{
	if (Timer_Starshooter_Management[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Starshooter_Management[client]);
		Timer_Starshooter_Management[client] = INVALID_HANDLE;
	}
}


public void Starshooter_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == 2) //Double check to see if its good or bad :(
		{	
			//Do your code here :)
			
			if (StarShooterCoolDelay[client] < GetGameTime())
			{
				SSS_overheat[client] -= 1;
				
				if(SSS_overheat[client] < 0)
				{
					SSS_overheat[client] = 0;
				}
			}
			if(starshooter_hud_delay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					PrintHintText(client,"Star Shooter Overheat %i%%%", SSS_overheat[client] * 4);
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				}
				starshooter_hud_delay[client] = GetGameTime() + 0.5;
			}
		}
		else
		{
			Kill_Timer_Starshooter(client);
		}
	}
	else
	{
		Kill_Timer_Starshooter(client);
	}
}