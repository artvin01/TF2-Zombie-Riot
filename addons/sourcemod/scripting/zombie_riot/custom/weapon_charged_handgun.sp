#pragma semicolon 1
#pragma newdecls required

static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static float base_chargetime[MAXPLAYERS+1]={-1.0, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static bool Handle_on[MAXPLAYERS+1]={false, ...};

static float Damage_Reduction[MAXENTITIES]={0.0, ...};
static float Damage_Tornado[MAXENTITIES]={0.0, ...};
static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float TORNADO_Radius[MAXPLAYERS];
static bool Laser_Cutter_Static[MAXPLAYERS] = {false, ...};
static int Projectile_To_Duo[MAXENTITIES]={0, ...};
static int Projectile_Cutter_Link[MAXENTITIES]={0, ...};
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

public void Charged_Reload(int client, int weapon, bool crit, int slot) {
	ClientCommand(client, "playgamesound weapons/teleporter_ready.wav");
}

public void Weapon_IEM_Launcher(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
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

		float fAng[3];
		GetClientEyeAngles(client, fAng);
		
		Wand_Launch_IEM(client, iRot, speed, 5.0, damage, 0, fAng, fPos);
	}
}

public void Weapon_IEM_Launcher_PAP(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
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
		
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= (1.0 / Attributes_Get(weapon, 6, 1.0));
		damage *= (1.0 / Attributes_Get(weapon, 97, 1.0));
		
		float fAng[3];
		GetClientEyeAngles(client, fAng);
		Wand_Launch_IEM(client, iRot, speed, 5.0, damage, 1, fAng, fPos);
	}
}

public void Weapon_IEM_Launcher_PAP_Star(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
		}
		else 
		{
			float flMultiplier = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flDetonateTime"); // 4.0 is the default one
			if (flMultiplier<-0.05)
			{
				SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+100);
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
		
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= (1.0 / Attributes_Get(weapon, 6, 1.0));
		damage *= (1.0 / Attributes_Get(weapon, 97, 1.0));
		
		
		float fAng[3];
		GetClientEyeAngles(client, fAng);
		Wand_Launch_IEM(client, iRot, speed, 20.0, damage, 2, fAng, fPos);
	}
}

public void Weapon_IEM_Cutter(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
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
		
		
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= (1.0 / Attributes_Get(weapon, 6, 1.0));
		damage *= (1.0 / Attributes_Get(weapon, 97, 1.0));
		
		
		Laser_Cutter_Static[client] = false;
		Wand_Launch_Cutter_IEM(client, speed, 15.0, damage, false);
	}
}

public void Weapon_IEM_Cutter_PAP_M2(int client, int weapon, bool crit, int slot)
{
	if (!Laser_Cutter_Static[client])
	{
		Laser_Cutter_Static[client] = true;
		PrintHintText(client, "Weapon Mode: Static");
	}
	else
	{
		Laser_Cutter_Static[client] = false;
		PrintHintText(client, "Weapon Mode: Expand");
	}
	
}

public void Weapon_IEM_Cutter_PAP(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
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
		
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= (1.0 / Attributes_Get(weapon, 6, 1.0));
		damage *= (1.0 / Attributes_Get(weapon, 97, 1.0));
		
		
		Wand_Launch_Cutter_IEM(client, speed, 15.0, damage, true);
	}
}

public void Weapon_Charged_Handgun(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = weapon;
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
		}
		else 
		{
			base_chargetime[client] = Attributes_Get(weapon, 670, 1.0);
				
			if(Attributes_Has(weapon,466))
				base_chargetime[client] = Attributes_Get(weapon, 466, 1.0);
			
			float flMultiplier = GetGameTime(); // 4.0 is the default one
			
			flMultiplier -= GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
			flMultiplier /= base_chargetime[client];
			if (flMultiplier<3.85)
			{
				SetEntProp(weapon, Prop_Data, "m_iClip1", GetEntProp(weapon, Prop_Data, "m_iClip1")+1);
				return;
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
		
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= (1.0 / Attributes_Get(weapon, 6, 1.0));
		damage *= (1.0 / Attributes_Get(weapon, 97, 1.0));
		
		
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
	
	SetTeam(iCarrier, GetClientTeam(client));
	SetTeam(iRot, GetClientTeam(client));
	
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
	
	SetEntityRenderMode(iCarrier, RENDER_NONE);
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
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls
		
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

static void Wand_Launch_IEM(int client, int iRot, float speed, float time, float damage, int pap, float fAng[3], float fPos[3])
{
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
	
	SetTeam(iCarrier, GetClientTeam(client));
	SetTeam(iRot, GetClientTeam(client));
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	
	if(pap==0)
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal_blue", 5.0);
	}
	else if (pap==1)
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal", 5.0);
	}
	else 
	{
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_charged", 20.0);
	}
	
	//drg_cowmangler_trail_charged cool black wave
	
	TeleportEntity(particle, NULL_VECTOR, fAng, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, fAng, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, fAng, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_NONE);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 200);
	SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
	SetEntityCollisionGroup(iCarrier, 0);
	
	Damage_Tornado[iCarrier] = damage;
	if(pap==0)
	{
		TORNADO_Radius[client] = 150.0;
		CreateTimer(0.2, Timer_Electric_Think, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
	else
	{
		TORNADO_Radius[client] = 250.0;
		CreateTimer(0.2, Timer_Electric_Think_PAP, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

		if (pap==2)
			CreateTimer(1.0, Timer_Electric_Think_PAP_Star, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
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
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


public Action Timer_Electric_Think_PAP(Handle timer, int ref)
{
	int iCarrier = EntRefToEntIndex(ref);
	if(!IsValidEntity(iCarrier))
	{
	    return Plugin_Stop;
	}
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
		
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	Damage_Reduction[iCarrier] = 1.0;
					
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
		{
			if(!b_NpcHasDied[baseboss_index])
			{
				if (GetTeam(client)!=GetTeam(baseboss_index)) 
				{
					WorldSpaceCenter(baseboss_index, targPos);
					if (GetVectorDistance(flCarrierPos, targPos) <= TORNADO_Radius[client])
					{
						//Code to do damage position and ragdolls
						static float angles[3];
						GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
						float vecForward[3];
						GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
						//Code to do damage position and ragdolls
						
						float damage_1 = Damage_Tornado[iCarrier];
						damage_1 *= Damage_Reduction[iCarrier];
						float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
						SDKHooks_TakeDamage(baseboss_index, client, client, damage_1, DMG_PLASMA, -1, Dmg_Force, targPos);
						
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
							
						Damage_Reduction[iCarrier] *= EXPLOSION_AOE_DAMAGE_FALLOFF * 0.9;
						//use blast cus it does its own calculations for that ahahahah im evil 
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_Electric_Think_PAP_Star(Handle timer, int ref)
{
	int iCarrier = EntRefToEntIndex(ref);
	if(!IsValidEntity(iCarrier))
	{
	    return Plugin_Stop;
	}
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
		
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], angll[3], nfAng[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	GetEntPropVector(iCarrier, Prop_Data, "m_angRotation", angll);
	
	nfAng[0] = angll[0] + GetRandomFloat(-50.0, 50.0);
	nfAng[1] = angll[1] + GetRandomFloat(-50.0, 50.0);
	nfAng[2] = angll[2] + GetRandomFloat(-50.0, 50.0);
	
	int iRot = CreateEntityByName("func_door_rotating");
	if(iRot == -1) return Plugin_Stop;

	DispatchKeyValueVector(iRot, "origin", flCarrierPos);
	DispatchKeyValue(iRot, "distance", "99999");
	DispatchKeyValueFloat(iRot, "speed", 100.0);
	DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
	DispatchSpawn(iRot);
	SetEntityCollisionGroup(iRot, 27);

	SetVariantString("!activator");
	AcceptEntityInput(iRot, "Open");
	
	Wand_Launch_IEM(client, iRot, 100.0, 5.0, Damage_Tornado[iCarrier]/2, 1, nfAng, flCarrierPos);

	return Plugin_Continue;
}

public Action Timer_Electric_Think(Handle timer, int ref)
{
	int iCarrier = EntRefToEntIndex(ref);
	if(!IsValidEntity(iCarrier))
	{
	    return Plugin_Stop;
	}
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
		
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	Damage_Reduction[iCarrier] = 1.0;
					
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
		{
			if(!b_NpcHasDied[baseboss_index])
			{
				if (GetTeam(client)!=GetTeam(baseboss_index)) 
				{
					WorldSpaceCenter(baseboss_index, targPos);
					if (GetVectorDistance(flCarrierPos, targPos) <= TORNADO_Radius[client])
					{
						//Code to do damage position and ragdolls
						static float angles[3];
						GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
						float vecForward[3];
						GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
						//Code to do damage position and ragdolls
						
						float damage_1 = Damage_Tornado[iCarrier];		
						damage_1 *= Damage_Reduction[iCarrier];
						float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
						SDKHooks_TakeDamage(baseboss_index, client, client, damage_1, DMG_PLASMA, -1, Dmg_Force, targPos, _ , ZR_DAMAGE_LASER_NO_BLAST);
						
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
							
						Damage_Reduction[iCarrier] *= EXPLOSION_AOE_DAMAGE_FALLOFF * 0.85;
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
			if(TF2_GetClassnameSlot(buffer, weapon) == TFWeaponSlot_Secondary)
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


static void Wand_Launch_Cutter_IEM(int client, float speed, float time, float damage, bool pap)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	float nfPos1[3], nfPos2[3];
	nfPos1[0] = fPos[0];
	nfPos1[1] = fPos[1];
	nfPos1[2] = fPos[2];
	
	nfPos2[0] = fPos[0];
	nfPos2[1] = fPos[1];
	nfPos2[2] = fPos[2];
	
	
	float nfAng1[3], nfAng2[3];
	nfAng1[0] = fAng[0];
	nfAng1[1] = fAng[1];
	nfAng1[2] = fAng[2];
	
	nfAng2[0] = fAng[0];
	nfAng2[1] = fAng[1];
	nfAng2[2] = fAng[2];
	
	if (!Laser_Cutter_Static[client])
	{
		nfAng1[1] -= 10.0;
		nfAng2[1] += 10.0;
	}
	else
	{
		float fRight[3];
		GetAngleVectors(fAng, NULL_VECTOR, fRight, NULL_VECTOR);
		
		nfPos1[0] -= 100.0 * fRight[0];
		nfPos1[1] -= 100.0 * fRight[1];
		
		nfPos2[0] += 100.0 * fRight[0];
		nfPos2[1] += 100.0 * fRight[1];
	}
	
	int iCarrier = CreateWandCutterProjectile(client, speed, nfPos1, nfAng1, time, pap);	
	Damage_Tornado[iCarrier] = damage;
	
	int iCarrier2 = CreateWandCutterProjectile(client, speed, nfPos2, nfAng2, time, pap);	
	Damage_Tornado[iCarrier] = damage;
	Damage_Tornado[iCarrier2] = damage;
	
	
	int beam = -1;
	if (!pap)
		beam = EntIndexToEntRef(ConnectWithBeam(iCarrier, iCarrier2, 50, 50, 250, 3.0, 3.0, 1.35, "materials/sprites/lgtning.vmt"));
	else
		beam = EntIndexToEntRef(ConnectWithBeam(iCarrier, iCarrier2, 250, 50, 50, 3.0, 3.0, 1.35, "materials/sprites/lgtning.vmt"));
		
	CreateTimer(15.0, Timer_RemoveEntityBeam, beam, TIMER_FLAG_NO_MAPCHANGE);
	
	Projectile_Cutter_Link[iCarrier] = beam;
	Projectile_Cutter_Link[iCarrier2] = beam;
	
	Projectile_To_Client[iCarrier] = client;
	Projectile_To_Client[iCarrier2] = client;
	
	Projectile_To_Duo[iCarrier] = EntIndexToEntRef(iCarrier2);
	Projectile_To_Duo[iCarrier2] = EntIndexToEntRef(iCarrier);
	
	CreateTimer(0.2, Timer_Electric_Cutter_Think, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(0.1, Timer_Electric_Cutter_Think_Next, EntIndexToEntRef(iCarrier2), TIMER_FLAG_NO_MAPCHANGE);
		
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_Cutter_IEM_OnHatTouch);
	SDKHook(iCarrier2, SDKHook_StartTouch, Event_Wand_Cutter_IEM_OnHatTouch);
}

public Action Timer_Electric_Cutter_Think_Next(Handle timer, int ref)
{
	int iCarrier = EntRefToEntIndex(ref);
	if (!IsValidEntity(iCarrier))
		return Plugin_Stop;
	CreateTimer(0.2, Timer_Electric_Cutter_Think, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	return Plugin_Continue;
}

public Action Event_Wand_Cutter_IEM_OnHatTouch(int entity, int other)
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
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
	}
	else if(target == 0)
	{
		int otherCarier = EntRefToEntIndex(Projectile_To_Duo[entity]);
		int beam = EntRefToEntIndex(Projectile_Cutter_Link[entity]);
		
		if (!IsValidEdict(otherCarier))
		{			
			if(IsValidEdict(entity) && entity>MaxClients)
			{
				RemoveEntity(entity);
			}
			
			if(IsValidEdict(beam) && beam>MaxClients)
			{
				RemoveEntity(beam);
			}
			return Plugin_Stop;
		}
		
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action Timer_Electric_Cutter_Think(Handle timer, int ref)
{
	int iCarrier = EntRefToEntIndex(ref);
	if (!IsValidEntity(iCarrier))
		return Plugin_Stop;
	int client = Projectile_To_Client[iCarrier];
	int particle = EntRefToEntIndex(Projectile_To_Particle[iCarrier]);
	
	int otherCarier = EntRefToEntIndex(Projectile_To_Duo[iCarrier]);
	int beam = EntRefToEntIndex(Projectile_Cutter_Link[iCarrier]);
	
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
		
		if(IsValidEdict(beam) && beam>MaxClients)
		{
			RemoveEntity(beam);
		}
		
		return Plugin_Stop;
	}
	
	if (!IsValidEdict(otherCarier))
	{
		
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		if(IsValidEdict(beam) && beam>MaxClients)
		{
			RemoveEntity(beam);
		}
		
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
		
		if(IsValidEdict(beam) && beam>MaxClients)
		{
			RemoveEntity(beam);
		}
		
		
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	GetEntPropVector(otherCarier, Prop_Send, "m_vecOrigin", targPos);

	float flAngle[3];
	MakeVectorFromPoints(flCarrierPos, targPos, flAngle);
	GetVectorAngles(flAngle, flAngle);
	
	Damage_Reduction[iCarrier] = 1.0;
	
	static float hullMin[3];
	static float hullMax[3];
	
	hullMin[0] = -50.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(flCarrierPos, targPos, hullMin, hullMax, 1073741824, IEM_Cutter_TraceUsers, iCarrier);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	
	return Plugin_Continue;
}

public bool IEM_Cutter_TraceUsers(int entity, int contentsMask, int carrier)
{
	if (!IsEntityAlive(entity) || !IsValidEntity(carrier))
		return false;
		
	int client = Projectile_To_Client[carrier];
	if (GetTeam(carrier)==GetTeam(entity))
		return false;
		
	SDKHooks_TakeDamage(entity, client, client, Damage_Reduction[carrier]*Damage_Tornado[carrier], DMG_PLASMA, -1);
	Damage_Reduction[carrier] *= 0.75; // I don't want it to be underpower
	
	return false;
}


stock int CreateWandCutterProjectile(int client, float flSpeed, float flPos[3], float flAng[3], float flDuration, bool pap)
{
	int iRot = CreateEntityByName("func_door_rotating");
	if(iRot == -1) return -1;

	DispatchKeyValueVector(iRot, "origin", flPos);
	DispatchKeyValue(iRot, "distance", "99999");
	DispatchKeyValueFloat(iRot, "speed", flSpeed);
	DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
	DispatchSpawn(iRot);
	SetEntityCollisionGroup(iRot, 27);

	SetVariantString("!activator");
	AcceptEntityInput(iRot, "Open");
	
	
	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return -1;

	float fVel[3], fBuf[3];
	GetAngleVectors(flAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*flSpeed;
	fVel[1] = fBuf[1]*flSpeed;
	fVel[2] = fBuf[2]*flSpeed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);

	TeleportEntity(iCarrier, flPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);
	
	SetTeam(iCarrier, GetTeam(client));
	SetTeam(iRot, GetTeam(client));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	float position[3];
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	int particle = 1;
	
	if (!pap)
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal_blue", flDuration);
	else
		particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal", flDuration);
	
	
	
	TeleportEntity(particle, NULL_VECTOR, flAng, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, flAng, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, flAng, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_NONE);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 200);
	SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
	SetEntityCollisionGroup(iCarrier, 0);
	
	DataPack pack;
	CreateDataTimer(15.0, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	return iCarrier;
}