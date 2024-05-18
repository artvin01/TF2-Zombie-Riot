#pragma semicolon 1
#pragma newdecls required

static int ST_HitEntitiesTeleportTrace[MAXENTITIES];

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"
#define WAND_TELEPORT_SOUND "misc/halloween/spell_teleport.wav"

static int ShortTeleportLaserIndex;

public void Wand_Short_Teleport_ClearAll()
{
	ShortTeleportLaserIndex = PrecacheModel("materials/sprites/laser.vmt", false);
}

void Wand_Short_Teleport_Map_Precache()
{
	Wand_Short_Teleport_ClearAll();
	PrecacheSound(WAND_TELEPORT_SOUND);
	PrecacheSound(SOUND_WAND_ATTACKSPEED_ABILITY);
}

public float AbilityShortTeleport(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (!i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 65)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [65]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Artifice(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}
	
	int StatsForCalcMultiAdd_dmg;
	StatsForCalcMultiAdd_dmg = Stats_Artifice(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd_dmg);

	damageDelt *= 1.4;

	float time = Weapon_Wand_ShortTeleport(client, weapon, 1, damageDelt);
	if(time > 0.0)
	{
		EmitSoundToAll(WAND_TELEPORT_SOUND, client, SNDCHAN_AUTO, 80, _, 0.7);
		RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);
		if(ChronoShiftReady(client) == 2)
		{
			ChronoShiftDoCooldown(client);
			time = 0.0;
		}
		else
		{
			RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
		}
	}
	return (GetGameTime() + time);
}

float Weapon_Wand_ShortTeleport(int client, int weapon, int level, float damage)
{
		
	static float startPos[3];
	GetClientEyePosition(client, startPos);
//	float sizeMultiplier = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
	static float endPos[3], eyeAngles[3];
	GetClientEyeAngles(client, eyeAngles);
	TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayersOrEntityCombat, client);
	TR_GetEndPosition(endPos);

	// don't even try if the distance is less than 82
	float distance = GetVectorDistance(startPos, endPos);
	if (distance < 82.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return 0.0;
	}
		
	if (distance > (600.0 * level))
		constrainDistance(startPos, endPos, distance, (600.0 * level));
	else // shave just a tiny bit off the end position so our point isn't directly on top of a wall
		constrainDistance(startPos, endPos, distance, distance - 1.0);

	float abspos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", abspos);

	if(Player_Teleport_Safe(client, endPos))
	{
		float Range = 100.0;
		float Time = 0.25;
		spawnRing_Vectors(abspos, Range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 	Time, 10.0, 8.0, 1, 1.0);	
		spawnRing_Vectors(abspos, Range * 2.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 	Time, 10.0, 8.0, 1, 1.0);	
		spawnRing_Vectors(abspos, Range * 2.0, 0.0, 0.0, 70.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 	Time, 10.0, 8.0, 1, 1.0);	
		spawnRing_Vectors(endPos, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 		255, 255, 255, 200, 1, 		Time, 10.0, 8.0, 1,Range * 2.0);	
		spawnRing_Vectors(endPos, 1.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt",		255, 255, 255, 200, 1,		Time, 10.0, 8.0, 1,Range * 2.0);		
		spawnRing_Vectors(endPos, 1.0, 0.0, 0.0, 70.0, "materials/sprites/laserbeam.vmt", 		255, 255, 255, 200, 1, 		Time, 10.0, 8.0, 1,Range * 2.0);		
		
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Explode_Logic_Custom(damage, client, client, weapon, abspos, Range, _, _, false, _, _, _);
		Explode_Logic_Custom(damage, client, client, weapon, endPos, Range, _, _, false, _, _, _);

		Zero(ST_HitEntitiesTeleportTrace);
		static float maxs[3];
		static float mins[3];
		maxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		mins = view_as<float>( { -24.0, -24.0, 0.0 } );	
		Handle hTrace = TR_TraceHullFilterEx(abspos, endPos, mins, maxs, MASK_SOLID, ST_TeleportDetectEnemy, client);
		delete hTrace;
		float damage_1;
		float VictimPos[3];
		float CalculateExplosiveDamage[3];
		float damage_reduction = 1.0;
		damage_1 = damage;
		float ExplosionDmgMultihitFalloff = EXPLOSION_AOE_DAMAGE_FALLOFF;
		float Teleport_CD = 15.0;

		for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
		{
			if(!ST_HitEntitiesTeleportTrace[entity_traced])
				break;

			WorldSpaceCenter(ST_HitEntitiesTeleportTrace[entity_traced], VictimPos);

			CalculateExplosiveDamageForce(abspos, VictimPos, 5000.0, CalculateExplosiveDamage);

			SDKHooks_TakeDamage(ST_HitEntitiesTeleportTrace[entity_traced], client, client, damage_1 / damage_reduction, DMG_BLAST, weapon, CalculateExplosiveDamage, VictimPos, false);	
			damage_reduction *= ExplosionDmgMultihitFalloff;
			Teleport_CD = 10.0;
		}
		FinishLagCompensation_Base_boss();
		abspos[2] += 40.0;
		endPos[2] += 40.0;
		TE_SetupBeamPoints(abspos, endPos, ShortTeleportLaserIndex, 0, 0, 0, Time, 10.0, 10.0, 0, 1.0, {255,255,255,200}, 3);
		TE_SendToAll(0.0);
		return Teleport_CD;
	}
	ClientCommand(client, "playgamesound items/medshotno1.wav");
	return 0.0;
}

public bool ST_TeleportDetectEnemy(int entity, int contentsMask, any iExclude)
{
	if(IsValidEnemy(iExclude, entity, true, true))
	{
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!ST_HitEntitiesTeleportTrace[i])
			{
				ST_HitEntitiesTeleportTrace[i] = entity;
				break;
			}
		}
	}
	return false;
}
