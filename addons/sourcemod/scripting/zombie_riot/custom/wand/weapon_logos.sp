#pragma semicolon 1
#pragma newdecls required

static Handle PerishTimer[MAXPLAYERS];
static bool PerishReady[MAXPLAYERS];

void Logos_MapStart()
{
	Zero(PerishReady);
}

public void Weapon_Logos_M1(int client, int weapon, bool &result, int slot)
{
	int cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", cost);
	}
	else
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= cost;
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);

		float time = 750.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LOGOS, weapon, "drg_cow_rockettrail_normal");

		if((GetURandomInt() % 5) > 2)
		{
			int entity = Wand_Projectile_Spawn(client, speed * 1.25, time * 3.0, damage * 0.6, WEAPON_LOGOS, weapon, "drg_cow_rockettrail_normal");
			if(entity != -1)
			{
				static float ang_Look[3];
				GetEntPropVector(entity, Prop_Send, "m_angRotation", ang_Look);
				Initiate_HomingProjectile(entity,
					client,
					80.0,		// float lockonAngleMax,
					90.0,		// float homingaSec,
					true,		// bool LockOnlyOnce,
					false,		// bool changeAngles,
					ang_Look,	// float AnglesInitiate[3]);
					-1);
			}
		}
	}
}

void Weapon_Logos_ProjectileTouch(int entity, int target)
{
	if(target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		bool secondary = HomingProjectile_IsActive(entity);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		ApplyStatusEffect(owner, target, "Aeternam", 5.0);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		
		Elemental_AddNecrosisDamage(target, owner, RoundFloat(f_WandDamage[entity]), weapon);

		if(secondary && Nymph_AllowBonusDamage(target))
			StartBleedingTimer(target, owner, f_WandDamage[entity] * 0.15, 4, weapon, DMG_PLASMA, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
}

static int HealthCheck;
static Action Weapon_Logos_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				spawnRing(client, 800.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 100, 155, 100, 125, 1, 0.25, 6.0, 6.1, 1);
				
				float damage = 65.0;
				damage *= Attributes_Get(weapon, 410, 1.0);
				HealthCheck = RoundFloat(damage * 1.5);

				Explode_Logic_Custom(damage * 6.67, client, client, weapon, _, 400.0, .FunctionToCallBeforeHit = LogosPerishExplodeBefore);
			}

			return Plugin_Continue;
		}
		
	}

	PerishTimer[client] = null;
	return Plugin_Stop;
}

static float LogosPerishExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(health > HealthCheck)
	{
		damage = 0.0;
	}
	else
	{
		float speed = 700.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);

		float time = 2000.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		EmitSoundToAll(SOUND_WAND_SHOT, attacker, _, 65, _, 0.45);

		int entity = Wand_Projectile_Spawn(attacker, speed, time, float(health), 1, weapon, "drg_cow_rockettrail_normal");
		if(entity != -1)
		{
			static float ang_Look[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", ang_Look);
			Initiate_HomingProjectile(entity,
				attacker,
				80.0,		// float lockonAngleMax,
				60.0,		// float homingaSec,
				true,		// bool LockOnlyOnce,
				false,		// bool changeAngles,
				ang_Look,	// float AnglesInitiate[3]);
				-1);
		}
	}
	
	return 0.0;
}

public void Weapon_Logos_M2(int client, int weapon, bool &result, int slot)
{
	if(!PerishReady[client])
	{
		PerishReady[client] = true;
		Ability_Apply_Cooldown(client, slot, 300.0);
	}
	else if(!PerishTimer[client])
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		if(cooldown > 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		}
		else
		{
			Rogue_OnAbilityUse(client, weapon);

			Attributes_SetMulti(weapon, 6, 0.5);

			DataPack pack;
			PerishTimer[client] = CreateDataTimer(0.2, Weapon_Logos_Timer, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));

			ClientCommand(client, "playgamesound items/powerup_pickup_uber.wav");
		}
	}
}
