#pragma semicolon 1
#pragma newdecls required

static int HitEntitiesTeleportTrace[MAXENTITIES];

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
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (i_IsWandWeapon[weapon])
			{
				float time = Weapon_Wand_ShortTeleport(client, weapon, 1);
				return (GetGameTime() + time);
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

float Weapon_Wand_ShortTeleport(int client, int weapon, int level)
{

	float damage;
	
	damage = Config_GetDPSOfEntity(weapon);

	damage *= 2.0;
		
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
		
	if (distance > (400.0 * level))
		constrainDistance(startPos, endPos, distance, (400.0 * level));
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

		Zero(HitEntitiesTeleportTrace);
		static float maxs[3];
		static float mins[3];
		maxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		mins = view_as<float>( { -24.0, -24.0, 0.0 } );	
		Handle hTrace = TR_TraceHullFilterEx(abspos, endPos, mins, maxs, MASK_SOLID, TeleportDetectEnemy, client);
		delete hTrace;
		float damage_1;
		float VictimPos[3];
		float damage_reduction = 1.0;
		damage_1 = damage;
		float ExplosionDmgMultihitFalloff = EXPLOSION_AOE_DAMAGE_FALLOFF;
		float Teleport_CD = 15.0;

		for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
		{
			if(!HitEntitiesTeleportTrace[entity_traced])
				break;

			VictimPos = WorldSpaceCenter(HitEntitiesTeleportTrace[entity_traced]);

			SDKHooks_TakeDamage(HitEntitiesTeleportTrace[entity_traced], client, client, damage_1 / damage_reduction, DMG_BLAST, weapon, CalculateExplosiveDamageForce(abspos, VictimPos, 5000.0), VictimPos, false);	
			damage_reduction *= ExplosionDmgMultihitFalloff;
			Teleport_CD = 5.0;
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

public bool TeleportDetectEnemy(int entity, int contentsMask, any iExclude)
{
	if(IsValidEnemy(iExclude, entity, true, true))
	{
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!HitEntitiesTeleportTrace[i])
			{
				HitEntitiesTeleportTrace[i] = entity;
				break;
			}
		}
	}
	return false;
}


//TODO:
/*
	Unique effect on teleport
	Damage on teleport on where you teleport to, and old position

	Higher levels allow to bring allies
*/
bool Player_Teleport_Safe(int client, float endPos[3])
{
	bool FoundSafeSpot = false;

	static float hullcheckmaxs_Player[3];
	static float hullcheckmins_Player[3];
	hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
	hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	

	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	for (int x = 0; x < 6; x++)
	{
		if (FoundSafeSpot)
			break;

		endPos = OriginalPos;
		//ignore 0 at all costs.
		
		switch(x)
		{
			case 0:
				endPos[0] += 20.0;

			case 1:
				endPos[0] -= 20.0;

			case 2:
				endPos[0] += 30.0;

			case 3:
				endPos[0] -= 30.0;

			case 4:
				endPos[0] += 40.0;

			case 5:
				endPos[0] -= 40.0;	
		}
		for (int y = 0; y < 7; y++)
		{
			if (FoundSafeSpot)
				break;

			endPos[1] = OriginalPos[1];
				
			switch(y)
			{
				case 1:
					endPos[1] += 20.0;

				case 2:
					endPos[1] -= 20.0;

				case 3:
					endPos[1] += 30.0;

				case 4:
					endPos[1] -= 30.0;

				case 5:
					endPos[1] += 40.0;

				case 6:
					endPos[1] -= 40.0;	
			}

			for (int z = 0; z < 7; z++)
			{
				if (FoundSafeSpot)
					break;

				endPos[2] = OriginalPos[2];
						
				switch(z)
				{
					case 1:
						endPos[2] += 20.0;

					case 2:
						endPos[2] -= 20.0;

					case 3:
						endPos[2] += 30.0;

					case 4:
						endPos[2] -= 30.0;

					case 5:
						endPos[2] += 40.0;

					case 6:
						endPos[2] -= 40.0;	
				}
				if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
					FoundSafeSpot = true;
			}
		}
	}
				

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	if(FoundSafeSpot)
	{
		TeleportEntity(client, endPos, NULL_VECTOR, NULL_VECTOR);
		EmitSoundToAll(WAND_TELEPORT_SOUND, client, SNDCHAN_STATIC, 80, _, 0.5);
	}
	return FoundSafeSpot;
}

//We wish to check if this poisiton is safe or not.
//This is only for players.
bool IsSafePosition(int entity, float Pos[3], float mins[3], float maxs[3])
{
	int ref;
	Handle hTrace = TR_TraceHullFilterEx(Pos, Pos, mins, maxs, MASK_NPCSOLID, BulletAndMeleeTrace, entity);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	if(ref < 0) //It hit nothing, good!
		return true;
	
	//It Hit something, bad!
	return false;
}



static void constrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance)
{
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}