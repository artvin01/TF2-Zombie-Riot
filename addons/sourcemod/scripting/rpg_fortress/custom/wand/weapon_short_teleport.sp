#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static int i_FireBallsToThrow[MAXPLAYERS+1]={0, ...};
static float f_OriginalDamage[MAXTF2PLAYERS];
static int i_weaponused[MAXTF2PLAYERS];

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"
#define WAND_TELEPORT_SOUND "misc/halloween/spell_teleport.wav"

public void Wand_Short_Teleport_ClearAll()
{
	Zero(i_FireBallsToThrow);
	Zero(ability_cooldown);
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

	static float startPos[3];
	GetClientEyePosition(client, startPos);
	float sizeMultiplier = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
	static float endPos[3], eyeAngles[3];
	GetClientEyeAngles(client, eyeAngles);
	TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayersOrEntityCombat, client);
	TR_GetEndPosition(endPos);

	// don't even try if the distance is less than 82
	float distance = GetVectorDistance(startPos, endPos);
	if (distance < 82.0)
		return 0.0;
		
	if (distance > (500.0 * level))
		constrainDistance(startPos, endPos, distance, (500.0 * level));
	else // shave just a tiny bit off the end position so our point isn't directly on top of a wall
		constrainDistance(startPos, endPos, distance, distance - 1.0);
	
	if(Player_Teleport_Safe(client, endPos, startPos))
	{
		return 2.0;
	}
	return 0.0;
}

//TODO:
/*
	Unique effect on teleport
	Damage on teleport on where you teleport to, and old position

	Higher levels allow to bring allies
*/
bool Player_Teleport_Safe(int client, float endPos[3], float startPos[3] = {0.0,0.0,0.0})
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
		for (int y = 0; y < 6; y++)
		{
			if (FoundSafeSpot)
				break;
				
			switch(y)
			{
				case 0:
					endPos[1] += 20.0;

				case 1:
					endPos[1] -= 20.0;

				case 2:
					endPos[1] += 30.0;

				case 3:
					endPos[1] -= 30.0;

				case 4:
					endPos[1] += 40.0;

				case 5:
					endPos[1] -= 40.0;	
			}

			for (int z = 0; z < 6; z++)
			{
				if (FoundSafeSpot)
					break;
						
				switch(z)
				{
					case 0:
						endPos[2] += 20.0;

					case 1:
						endPos[2] -= 20.0;

					case 2:
						endPos[2] += 30.0;

					case 3:
						endPos[2] -= 30.0;

					case 4:
						endPos[2] += 40.0;

					case 5:
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