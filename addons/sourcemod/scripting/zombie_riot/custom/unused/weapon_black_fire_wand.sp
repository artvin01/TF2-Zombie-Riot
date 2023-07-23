#pragma semicolon 1
#pragma newdecls required

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Fireball_Damage[MAXPLAYERS+1]={0.0, ...};
static float Damage_Reduction[MAXPLAYERS+1]={0.0, ...};

//#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT_BLACK_FIRE 	"weapons/dragons_fury_shoot.wav"
#define SOUND_FIRE_BLACK_IMPACT "weapons/dragons_fury_impact.wav"

void Wand_Black_Fire_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_BLACK_FIRE);
	PrecacheSound(SOUND_FIRE_BLACK_IMPACT);
//	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_Black_Fire_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
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
		EmitSoundToAll(SOUND_WAND_SHOT_BLACK_FIRE, client, SNDCHAN_WEAPON, 65, _, 0.45, 135);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
		Wand_Launch(client, iRot, speed, time, damage, weapon);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

static void Wand_Launch(int client, int iRot, float speed, float time, float damage, int weapon)
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
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);

	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);
	
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));

	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	Projectile_To_Weapon[iCarrier] = weapon;
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "unusual_breaker_purple_parent", 5.0);

		default:
			particle = ParticleEffectAt(position, "unusual_breaker_purple_parent", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
		
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_Black_Fire_OnHatTouch);
}

public Action Event_Wand_Black_Fire_OnHatTouch(int entity, int other)
{
	char other_classname[32];
	GetEntityClassname(other, other_classname, sizeof(other_classname));
	if ((StrContains(other_classname, "zr_base_npc") != -1 || StrContains(other_classname, "func_breakable") != -1) && (GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(other, Prop_Send, "m_iTeamNum")))	{
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], 2048, -1);	// 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		NPC_Ignite(other, Projectile_To_Client[entity], 3.0, Projectile_To_Weapon[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_FIRE_BLACK_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(other == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_FIRE_BLACK_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


public void Weapon_Amaterasu(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 100;
		if(mana_cost <= Current_Mana[client])
		{
			if (ability_cooldown[client] < GetGameTime())
			{
				ability_cooldown[client] = GetGameTime() + 15.0; //10 sec CD
				
				float damage = 65.0;
				
				damage *= 7.5;
				
				damage *= Attributes_Get(weapon, 410, 1.0);
			
				Fireball_Damage[client] = damage;
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;
				Damage_Reduction[client] = 1.0;
				/*
				float vAngles[3];
				float vOrigin[3];
				float vEnd[3];
				float targPos[3];
	
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, Trace_DontHitEntityOrPlayer);
		    	
				if(TR_DidHit(trace))
				{   	 
		   		 	TR_GetEndPosition(vEnd, trace);
			
					CloseHandle(trace);
					
					int targ = MaxClients + 1;
				}
				*/
				
			}
			else
			{
				float Ability_CD = ability_cooldown[client] - GetGameTime();
		
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
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}