#pragma semicolon 1
#pragma newdecls required

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float Damage_Tornado[MAXENTITIES]={0.0, ...};
static float Duration_Tornado[MAXENTITIES]={0.0, ...};
static float f_TornadoM2CooldownTimer[MAXENTITIES]={0.0, ...};
static int i_WeaponRefM2[MAXENTITIES]={0, ...};
static float f_TornadoDamage[MAXENTITIES]={0.0, ...};
static int i_TornadoManaCost[MAXENTITIES]={0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};

static float TORNADO_Radius[MAXPLAYERS];

static int Beam_Laser;
static int Beam_Glow;


public void WindStaff_ClearAll()
{
	Zero(Damage_Tornado);
	Zero(f_TornadoM2CooldownTimer);
}
void Wind_Staff_MapStart()
{
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	TBB_Precache_Wind_Staff();
}

public void Weapon_Wind_Staff(int client, int weapon, bool crit, int slot)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, 80, _, _, 1.0);					
			}
			case 2:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, 80, _, _, 1.0);
			}
			case 3:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, 80, _, _, 1.0);			
			}
			case 4:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, 80, _, _, 1.0);
			}		
		}
		float damage = 125.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
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
	//	EmitSoundToAll(SOUND_WAND_SHOT_FIRE, client, SNDCHAN_WEAPON, 65, _, 0.45, 135);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
		Wand_Launch_Tornado(client, iRot, speed, time, damage, weapon);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}


public void Weapon_Wind_StaffM2(int client, int weapon, bool crit, int slot)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, 80, _, _, 1.0);					
			}
			case 2:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, 80, _, _, 1.0);
			}
			case 3:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, 80, _, _, 1.0);			
			}
			case 4:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, 80, _, _, 1.0);
			}		
		}
		float damage = 125.0;
		damage *= Attributes_Get(weapon, 410, 1.0);

		i_WeaponRefM2[client] = EntIndexToEntRef(weapon);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		i_TornadoManaCost[client] = mana_cost / 8;
		f_TornadoDamage[client] = damage * 0.25;

		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
		SDKHook(client, SDKHook_PreThink, WindStaffM2_Think);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void WindStaffM2_Think(int client)
{
	if(GetGameTime() > f_TornadoM2CooldownTimer[client])
	{
		f_TornadoM2CooldownTimer[client] = GetGameTime() + 0.1;
		int buttons = GetClientButtons(client);
		int weapon = EntRefToEntIndex(i_WeaponRefM2[client]);
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != weapon_active)
		{
			SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
			return;
		}
		if (buttons & IN_ATTACK2)
		{
			if(i_TornadoManaCost[client] <= Current_Mana[client])
			{
				Current_Mana[client] -= i_TornadoManaCost[client];
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				Mana_Hud_Delay[client] = 0.0;
				float TornadoRange = 300.0;
				Explode_Logic_Custom(f_TornadoDamage[client], client, client, weapon, _, TornadoRange,0.52,_,false, 4);
				float flCarrierPos[3];//, targPos[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", flCarrierPos);
				flCarrierPos[2] += 15.0;
				TE_SetupBeamRingPoint(flCarrierPos, TornadoRange*2.0, (TornadoRange*2.0)+0.5, Beam_Laser, Beam_Glow, 0, 10, 0.11, 25.0, 0.8, {50, 50, 250, 250}, 10, 0);
				TE_SendToAll(0.0);
				return;
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", i_TornadoManaCost[client]);
			}
		}
		SDKUnhook(client, SDKHook_PreThink, WindStaffM2_Think);
		return;
	}	
}

void TBB_Precache_Wind_Staff()
{
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}
static void Wand_Launch_Tornado(int client, int iRot, float speed, float time, float damage, int weapon)
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
	
	SetTeam(iRot, GetClientTeam(client));
	SetTeam(iCarrier, GetClientTeam(client));

	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	Projectile_To_Weapon[iCarrier] = EntIndexToEntRef(weapon);
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	//raygun_projectile_blue
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "utaunt_tornado_twist_white", 5.0);

		default:
			particle = ParticleEffectAt(position, "utaunt_tornado_twist_white", 5.0);
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
	CreateDataTimer(time, Timer_Stop_Tornado, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Tornado_OnHatTouch);
}

public Action Event_Tornado_OnHatTouch(int entity, int other)
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
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, Dmg_Force,Entity_Position);	// 2048 is DMG_NOGIB?
		
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			//GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", position);
			RemoveEntity(particle);
		}
		
		SetEntityMoveType(entity, MOVETYPE_NONE);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 0);
		SetEntityCollisionGroup(entity, 0);
		Wand_Create_Tornado(Projectile_To_Client[entity], entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			//GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", position);
			RemoveEntity(particle);
		}
		
		SetEntityMoveType(entity, MOVETYPE_NONE);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 0);
		SetEntityCollisionGroup(entity, 0);
		Wand_Create_Tornado(Projectile_To_Client[entity], entity);
	}
	return Plugin_Handled;
}

public Action Timer_Stop_Tornado(Handle timer, DataPack pack)
{
	pack.Reset();
	int iCarrier = EntRefToEntIndex(pack.ReadCell());
	int particle = EntRefToEntIndex(pack.ReadCell());
	int iRot = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEdict(particle) && particle>MaxClients)
	{
		RemoveEntity(particle);
	}
	if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
	{
		if (GetEntityMoveType(iCarrier)!=MOVETYPE_NONE)
		{
			SetEntityMoveType(iCarrier, MOVETYPE_NONE);
			SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 0);
			SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
			SetEntityCollisionGroup(iCarrier, 0);
			
			Wand_Create_Tornado(Projectile_To_Client[iCarrier], iCarrier);
		}
	}
	if(IsValidEdict(iRot) && iRot>MaxClients)
	{
		RemoveEntity(iRot);
	}
	return Plugin_Handled; 
}

static void Wand_Create_Tornado(int client, int iCarrier)
{
	float flCarrierPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	/*
	int particle = 0;
	//raygun_projectile_blue
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(flCarrierPos, "utaunt_tornado_twist_white", 5.0);

		default:
			particle = ParticleEffectAt(flCarrierPos, "utaunt_tornado_twist_white", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	*/
	
	TORNADO_Radius[client] = 215.0;
	
	int weapon = EntRefToEntIndex(Projectile_To_Weapon[iCarrier]);
	if(IsValidEntity(weapon))
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
			
		Damage_Tornado[iCarrier] = damage;
		Duration_Tornado[iCarrier] = GetGameTime() + 1.0;
		flCarrierPos[2] += 5.0;
		
		TE_SetupBeamRingPoint(flCarrierPos, TORNADO_Radius[client]*2.0, (TORNADO_Radius[client]*2.0)+0.5, Beam_Laser, Beam_Glow, 0, 10, 5.0, 25.0, 0.8, {50, 50, 250, 85}, 10, 0);
		TE_SendToAll(0.0);
		
		CreateTimer(0.5, Timer_Tornado_Think, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
}

public Action Timer_Tornado_Think(Handle timer, int iCarrier)
{
	int client = Projectile_To_Client[iCarrier];
	// int particle = Projectile_To_Particle[iCarrier];
	
	if (!IsValidEdict(iCarrier) || iCarrier<=MaxClients || Duration_Tornado[iCarrier]<=GetGameTime())
	{
		/*
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		*/
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		return Plugin_Stop;
	}
	
	if (!IsValidClient(client))
	{
		/*
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		*/
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		return Plugin_Stop;
	}
	
	float flCarrierPos[3];//, targPos[3];
	GetEntPropVector(iCarrier, Prop_Send, "m_vecOrigin", flCarrierPos);

//	i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_PLASMA_DAMAGE;
	
	Explode_Logic_Custom(Damage_Tornado[iCarrier], client, client, -1, flCarrierPos, TORNADO_Radius[client],0.45,_,false, 4);
	
	return Plugin_Continue;
}


void RuinaNukeBackstabDo(int victim, int attacker,int weapon)
{
	if (Ability_Check_Cooldown(attacker, 1) > 0.0)
	{
		return;
	}
	Ability_Apply_Cooldown(attacker, 1, 15.0, weapon);
	Rogue_OnAbilityUse(attacker, weapon);
	float posEnemy[3];
	float posEnemyIAm[3];
	float posEnemySave[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", posEnemyIAm);
	posEnemyIAm[2] -= 100.0;
	WorldSpaceCenter(victim, posEnemy);
	posEnemySave = posEnemy;
	posEnemy[2] += 5000.0;
	posEnemy[1] += GetRandomFloat(-2000.0, 2000.0);
	posEnemy[0] += GetRandomFloat(-2000.0, 2000.0);
	int particle = ParticleEffectAt(posEnemy, "kartimpacttrail", 0.4);
	b_IsEntityAlwaysTranmitted[particle] = true;
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));

	DataPack pack;
	CreateDataTimer(0.1, NukeBackstabEffectDo, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteFloat(posEnemyIAm[0]);
	pack.WriteFloat(posEnemyIAm[1]);
	pack.WriteFloat(posEnemyIAm[2]);
	EmitAmbientSound("ambient/explosions/explode_3.wav", posEnemySave, _, 90, _,0.7, GetRandomInt(75, 110));
	TE_Particle("hightower_explosion", posEnemySave, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);
	i_ExplosiveProjectileHexArray[weapon] = 0;
	i_ExplosiveProjectileHexArray[weapon] |= EP_DEALS_CLUB_DAMAGE;
	i_ExplosiveProjectileHexArray[weapon] |= EP_GIBS_REGARDLESS;
		
	float damageSeperate = 65.0;
	damageSeperate *= WeaponDamageAttributeMultipliers(weapon);
	damageSeperate *= 2.0;
	Explode_Logic_Custom(damageSeperate, attacker, weapon, weapon, posEnemySave, .FunctionToCallBeforeHit = RuinaDroneKnifeExplosionDamage); //Big fuckoff nuke
	i_ExplosiveProjectileHexArray[weapon] = 0;
}

static float RuinaDroneKnifeExplosionDamage(int attacker, int victim, float &damage, int weapon)
{
	if(b_thisNpcIsARaid[victim])
	{
		//Remove raid damage bonus from this explosion.
		damage /= EXTRA_RAID_EXPLOSIVE_DAMAGE;
	}
	return 0.0;
}

static Action NukeBackstabEffectDo(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float PosTeleport[3];
	PosTeleport[0] = pack.ReadFloat();
	PosTeleport[1] = pack.ReadFloat();
	PosTeleport[2] = pack.ReadFloat();
	if(entity != -1)
	{
		TeleportEntity(entity, PosTeleport, NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Stop;

}