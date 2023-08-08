#pragma semicolon 1
#pragma newdecls required

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static float base_chargetime[MAXPLAYERS+1]={-1.0, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static bool Handle_on[MAXPLAYERS+1]={false, ...};

static float Damage_Reduction[MAXENTITIES]={0.0, ...};
static float Damage_Tornado[MAXENTITIES]={0.0, ...};
static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float TORNADO_Radius[MAXTF2PLAYERS];
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};

static int Beam_Laser;
static int Beam_Glow;

void Charged_Handgun_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheModel(ENERGY_BALL_MODEL);
	
	PrecacheModel("materials/sprites/lgtning.vmt", false);
	PrecacheModel("sprites/glow02.vmt", true);
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

public void Charged_Reload(int client, int weapon, const char[] classname, bool &result) {
	ClientCommand(client, "playgamesound weapons/teleporter_ready.wav");
}

public void Weapon_IEM_Launcher(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			KillTimer(Revert_Weapon_Back_Timer[client]);
		}
		else 
		{
			float flMultiplier = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime"); // 4.0 is the default one
			if (flMultiplier<-0.05)
			{
				SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+20);
				return;
			}
		}
		
		float speed = 1100.0;
		speed /= Attributes_Get(weapon, 103, 1.0);
		
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
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		
		float damage = 50.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		Wand_Launch_IEM(client, iRot, speed, 5.0, damage, false);
	}
}

public void Weapon_IEM_Launcher_PAP(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			KillTimer(Revert_Weapon_Back_Timer[client]);
		}
		else 
		{
			float flMultiplier = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime"); // 4.0 is the default one
			if (flMultiplier<-0.05)
			{
				SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+40);
				return;
			}
		}
		
		float speed = 1100.0;
		speed /= Attributes_Get(weapon, 103, 1.0);
		
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
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		
		float damage = 50.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		Wand_Launch_IEM(client, iRot, speed, 5.0, damage, true);
	}
}

public void Weapon_Charged_Handgun(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			KillTimer(Revert_Weapon_Back_Timer[client]);
		}
		else 
		{
			base_chargetime[client] = Attributes_Get(weapon, 670, 1.0);
				
			if(Attributes_Has(weapon,466))
				base_chargetime[client] = Attributes_Get(weapon, 466, 1.0);
			
			float flMultiplier = GetGameTime(); // 4.0 is the default one
			
			if (HasEntProp(weapon, Prop_Send, "m_flChargeBeginTime"))
			{
				flMultiplier -= GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
				flMultiplier /= base_chargetime[client];
				if (flMultiplier<3.85)
				{
					SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
					return;
				}
			}
			else 
			{
				flMultiplier -= GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime");
				if (flMultiplier<-0.05)
				{
					SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
					return;
				}
			}
		}
		
		DataPack pack;
		Revert_Weapon_Back_Timer[client] = CreateDataTimer(0.4, Reset_weapon_charged_handgun, pack);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		
		Handle_on[client] = true;
		
		if(Attributes_Has(weapon, 670))
			Attributes_Set(weapon, 670, -1.0);
		else
			Attributes_Set(weapon, 466, -1.0);
		
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
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
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		
		float damage = 50.0;
		if (HasEntProp(weapon, Prop_Send, "m_flChargeBeginTime"))
			damage = 120.0;
		
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		Wand_Launch(client, iRot, speed, 2.0, damage);
	}
}

static void Wand_Launch(int client, int iRot, float speed, float time, float damage)
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
	
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "flaregun_crit_red", 5.0);

		default:
			particle = ParticleEffectAt(position, "flaregun_crit_red", 5.0);
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
		
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Charged_Hand_OnHatTouch);
}

public Action Event_Charged_Hand_OnHatTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

static void Wand_Launch_IEM(int client, int iRot, float speed, float time, float damage, bool pap)
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
	
	if(!pap)
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal_blue", 5.0);
	}
	else
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal", 5.0);
	}
	
	//drg_cowmangler_trail_charged cool black wave
	
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 200);
	SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
	SetEntityCollisionGroup(iCarrier, 0);
	
	Damage_Tornado[iCarrier] = damage;
	if(!pap)
	{
		TORNADO_Radius[client] = 150.0;
		CreateTimer(0.2, Timer_Electric_Think, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
	else
	{
		TORNADO_Radius[client] = 250.0;
		CreateTimer(0.2, Timer_Electric_Think_PAP, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
		
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_IEM_OnHatTouch);
}

public Action Event_Wand_IEM_OnHatTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


public Action Timer_Electric_Think_PAP(Handle timer, int iCarrier)
{
	int client = Projectile_To_Client[iCarrier];
	int particle = Projectile_To_Particle[iCarrier];
	
	if (!IsValidEdict(iCarrier) || iCarrier<=MaxClients)
	{
		
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	if (!IsValidClient(client))
	{
		
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	Damage_Reduction[iCarrier] = 1.0;
					
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index))
		{
			if(!b_NpcHasDied[baseboss_index])
			{
				if (GetEntProp(client, Prop_Send, "m_iTeamNum")!=GetEntProp(baseboss_index, Prop_Send, "m_iTeamNum")) 
				{
					targPos = WorldSpaceCenter(baseboss_index);
					if (GetVectorDistance(flCarrierPos, targPos) <= TORNADO_Radius[client])
					{
						//Code to do damage position and ragdolls
						static float angles[3];
						GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
						float vecForward[3];
						GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
						//Code to do damage position and ragdolls
						
						float damage_1 = Damage_Tornado[iCarrier];
						damage_1 /= Damage_Reduction[iCarrier];
						
						SDKHooks_TakeDamage(baseboss_index, client, client, damage_1, DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), targPos);
						
						//If the npc is gibbed at anytime, it will cause this to just go to the world origin...
						/*			
						if(b_NpcHasDied[baseboss_index]) //The npc died!
						{
							PrintToChatAll("dead!");
						}
						else
					 	{
						 	int beam = EntIndexToEntRef(ConnectWithBeam(iCarrier, baseboss_index, 50, 50, 250, 3.0, 3.0, 1.35, "materials/sprites/lgtning.vmt"));
						
							CreateTimer(0.3, Timer_RemoveEntityBeam, beam, TIMER_FLAG_NO_MAPCHANGE);
						}
						*/
						int r = 255;
						int g = 125;
						int b = 125;
						float diameter = 15.0;
							
						int colorLayer4[4];
						SetColorRGBA(colorLayer4, r, g, b, 60);
						int colorLayer3[4];
						SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
						int colorLayer2[4];
						SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
						int colorLayer1[4];
						SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
						int glowColor[4];
						SetColorRGBA(glowColor, r, g, b, 200);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
						TE_SendToAll(0.0);
							
						Damage_Reduction[iCarrier] *= EXPLOSION_AOE_DAMAGE_FALLOFF;
						//use blast cus it does its own calculations for that ahahahah im evil (you scare me sometime man)
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_Electric_Think(Handle timer, int iCarrier)
{
	int client = Projectile_To_Client[iCarrier];
	int particle = Projectile_To_Particle[iCarrier];
	
	if (!IsValidEdict(iCarrier) || iCarrier<=MaxClients)
	{
		
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	if (!IsValidClient(client))
	{
		
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	Damage_Reduction[iCarrier] = 1.0;
					
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index))
		{
			if(!b_NpcHasDied[baseboss_index])
			{
				if (GetEntProp(client, Prop_Send, "m_iTeamNum")!=GetEntProp(baseboss_index, Prop_Send, "m_iTeamNum")) 
				{
					targPos = WorldSpaceCenter(baseboss_index);
					if (GetVectorDistance(flCarrierPos, targPos) <= TORNADO_Radius[client])
					{
						//Code to do damage position and ragdolls
						static float angles[3];
						GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
						float vecForward[3];
						GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
						//Code to do damage position and ragdolls
						
						float damage_1 = Damage_Tornado[iCarrier];			
						damage_1 /= Damage_Reduction[iCarrier];
						
						SDKHooks_TakeDamage(baseboss_index, client, client, damage_1, DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), targPos, _ , ZR_DAMAGE_LASER_NO_BLAST);
						
						//If the npc is gibbed at anytime, it will cause this to just go to the world origin...
						/*			
						if(b_NpcHasDied[baseboss_index]) //The npc died!
						{
							PrintToChatAll("dead!");
						}
						else
					 	{
						 	int beam = EntIndexToEntRef(ConnectWithBeam(iCarrier, baseboss_index, 50, 50, 250, 3.0, 3.0, 1.35, "materials/sprites/lgtning.vmt"));
						
							CreateTimer(0.3, Timer_RemoveEntityBeam, beam, TIMER_FLAG_NO_MAPCHANGE);
						}
						*/
						int r = 125;
						int g = 125;
						int b = 255;
						float diameter = 15.0;
							
						int colorLayer4[4];
						SetColorRGBA(colorLayer4, r, g, b, 60);
						int colorLayer3[4];
						SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
						int colorLayer2[4];
						SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
						int colorLayer1[4];
						SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
						TE_SendToAll(0.0);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
						int glowColor[4];
						SetColorRGBA(glowColor, r, g, b, 200);
						TE_SetupBeamPoints(flCarrierPos, targPos, Beam_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
						TE_SendToAll(0.0);
							
						Damage_Reduction[iCarrier] *= EXPLOSION_AOE_DAMAGE_FALLOFF;
						//use blast cus it does its own calculations for that ahahahah im evil (you scare me sometime man)
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}


public Action Reset_weapon_charged_handgun(Handle cut_timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if (IsValidClient(client))
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != INVALID_ENT_REFERENCE)
		{
			char buffer[36];
			GetEntityClassname(weapon, buffer, sizeof(buffer));
			if(TF2_GetClassnameSlot(buffer) == TFWeaponSlot_Secondary)
			{
				Attributes_Set(weapon, 670, base_chargetime[client]);
				ClientCommand(client, "playgamesound items/medshotno1.wav");
			}
			else 
			{
				Attributes_Set(weapon, 466, base_chargetime[client]);
				ClientCommand(client, "playgamesound items/medshotno1.wav");
			}
		}
	}
	Handle_on[client] = false;
	return Plugin_Handled;
}

public Action Timer_RemoveEntityBeam(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if (IsValidEdict(entity) && entity > MaxClients)
	{
		AcceptEntityInput(entity, "Kill", -1, -1, 0);
	}
	return Plugin_Continue;
}