#pragma semicolon 1
#pragma newdecls required

static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];


#define SOUND_AUTOAIM_IMPACT_FLESH_1 		"physics/flesh/flesh_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_2 		"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_3 		"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_4 		"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_5 		"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_AUTOAIM_IMPACT_CONCRETE_1 		"physics/concrete/concrete_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

void Wand_Chlorophite_Map_Precache()
{
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_4);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_5);
	
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_4);
}

public void Weapon_Chlorophite(int client, int weapon, bool crit)
{
	float damage = 8.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 2000.0;
	
	speed *= Attributes_Get(weapon, 103, 1.0);
		
	float time = 500.0/speed;
	
	time = 10.0;
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 9/*Default wand*/, weapon, "raygun_projectile_blue_trail");
	
	CreateTimer(0.1, Homing_Shots_Repeat_Timer_Chlorophite, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//	RMR_NextDeviationAt[iCarrier] = GetGameTime() + 0.4;
	RMR_HomingPerSecond[projectile] = 359.0;
	RMR_RocketOwner[projectile] = client;
	RMR_HasTargeted[projectile] = false;
	RWI_HomeAngle[projectile] = 180.0;
	RWI_LockOnAngle[projectile] = 180.0;
	RMR_RocketVelocity[projectile] = speed;
	RMR_CurrentHomingTarget[projectile] = -1;
}

public Action Homing_Shots_Repeat_Timer_Chlorophite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidClient(RMR_RocketOwner[entity]))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}

		if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
		{
			if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
			{
				HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
			}
			return Plugin_Continue;
		}
		int Closest = GetClosestTarget(entity, _, _, true);
		if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
		{
			RMR_CurrentHomingTarget[entity] = Closest;
			if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
			{
				if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
				{
					HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
				}
				return Plugin_Continue;
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}	
/*
void Wand_Homing()
{
	if (RMR_NextDeviationAtGlobal <= GetGameTime())
	{
		RMR_NextDeviationAtGlobal = GetGameTime() + 0.1;
		
		for(int entitycount; entitycount<i_MaxcountHomingMagicShot; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsHomingMagicShot[entitycount]);
			if(IsValidEntity(entity))
			{
				if (RMR_NextDeviationAt[entity] <= GetGameTime())
				{
					float deltaTime = (GetGameTime() - RMR_NextDeviationAt[entity]) + 0.1;
					
					// get the angles and mess with them first
					static float rocketAngle[3];
					GetEntPropVector(entity, Prop_Send, "m_angRotation", rocketAngle);
					
					// missile homing
					if (RMR_HomingPerSecond[entity] > 0.0)
					{
						static float targetOrigin[3];
						static float rocketOrigin[3];
						GetEntPropVector(entity, Prop_Send, "m_vecOrigin", rocketOrigin);
						static float tmpAngles[3];
						static float tmpOrigin[3];
						
						static float PersonOrigin[3];
						GetEntPropVector(RMR_RocketOwner[entity], Prop_Send, "m_vecOrigin", PersonOrigin);
						targetOrigin[2] += TARGET_Z_OFFSET; // target their midsection
						// first, check if the current target is not out of homing range or dead
						if (RMR_CurrentHomingTarget[entity] != -1)
						{
							int target = EntRefToEntIndex(RMR_CurrentHomingTarget[entity]);
							
							if (!RW_IsValidHomingTarget(target, RMR_RocketOwner[entity]))
							{
								RMR_CurrentHomingTarget[entity] = -1;
							}
							else
							{
								GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetOrigin);
								targetOrigin[2] += TARGET_Z_OFFSET; // target their midsection	
								
								// first do a ray trace. if that fails, target lost.
								GetRayAngles(rocketOrigin, targetOrigin, tmpAngles);
								Handle trace = TR_TraceRayFilterEx(rocketOrigin, tmpAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
								TR_GetEndPosition(tmpOrigin, trace);
								CloseHandle(trace);
								if (GetVectorDistance(rocketOrigin, targetOrigin, true) > GetVectorDistance(rocketOrigin, tmpOrigin, true))
								{
									RMR_CurrentHomingTarget[entity] = -1;
								}
								else
								{
									// check the angles to ensure the rocket can still "see" the player, which is just a lazy check of pitch and yaw
									// though it's almost always going to be yaw that fails first
									if (!AngleWithinTolerance(rocketAngle, tmpAngles, RWI_HomeAngle[entity]))
									{
										RMR_CurrentHomingTarget[entity] = -1;
									}
								}
							}
						}
						
						// see it homing can be (re)started
						if (RMR_CurrentHomingTarget[entity] == -1 && !(!RMR_CanRetarget[entity] && RMR_HasTargeted[entity]))
						{
							float nearestValidDistance = 9999.0 * 9999.0;
							float testDist = 0.0;
							int nearestValidTarget = -1;
						
							// find the closest target within tolerance
							for(int entitycount_2; entitycount_2<i_MaxcountNpc; entitycount_2++)
							{
								int entity_npc = EntRefToEntIndex(i_ObjectsNpcs[entitycount_2]);
								if (!RW_IsValidHomingTarget(entity_npc, RMR_RocketOwner[entity]))
									continue;
								
								GetEntPropVector(entity_npc, Prop_Send, "m_vecOrigin", targetOrigin);
								targetOrigin[2] += TARGET_Z_OFFSET;
								
								testDist = GetVectorDistance(rocketOrigin, targetOrigin, true);
								
								// least distance so far?
								if (testDist < nearestValidDistance)
								{
									GetRayAngles(rocketOrigin, targetOrigin, tmpAngles);
									Handle trace = TR_TraceRayFilterEx(rocketOrigin, tmpAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
									TR_GetEndPosition(tmpOrigin, trace);
									CloseHandle(trace);
										
									// wall test passed?
									if (testDist < GetVectorDistance(rocketOrigin, tmpOrigin, true))
									{
										// angle tolerance passed?
										if (AngleWithinTolerance(rocketAngle, tmpAngles, RWI_LockOnAngle[entity]))
										{
											nearestValidTarget = entity_npc;
											nearestValidDistance = testDist;
										}
									}
								}
							}
							
							// if we've locked on, reflect this
							if (nearestValidTarget != -1)
							{
								RMR_CurrentHomingTarget[entity] = EntIndexToEntRef(nearestValidTarget);
								RMR_HasTargeted[entity] = true;
							}
						}
						
						// now home! tmpAngles is already what we want it to be.
						if (RMR_CurrentHomingTarget[entity] != -1)
						{
							float maxAngleDeviation = deltaTime * RMR_HomingPerSecond[entity];
							
							for (int i = 0; i < 2; i++)
							{
								if (fabs(rocketAngle[i] - tmpAngles[i]) <= RWI_HomeAngle[entity])
								{
									if (rocketAngle[i] - tmpAngles[i] < 0.0)
										rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - rocketAngle[i]);
									else
										rocketAngle[i] -= fmin(maxAngleDeviation, rocketAngle[i] - tmpAngles[i]);
								}
								else // it wrapped around
								{
									float tmpRocketAngle = rocketAngle[i];
								
									if (rocketAngle[i] - tmpAngles[i] < 0.0)
										tmpRocketAngle += 360.0;
									else
										tmpRocketAngle -= 360.0;
										
									if (tmpRocketAngle - tmpAngles[i] < 0.0)
										rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - tmpRocketAngle);
									else
										rocketAngle[i] -= fmin(maxAngleDeviation, tmpRocketAngle - tmpAngles[i]);
								}
								
								rocketAngle[i] = fixAngle(rocketAngle[i]);
							}
						}
					
					}
					// now use the old velocity and tweak it to match the int angles
					float vecVelocity[3];
					GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
					vecVelocity[0] *= RMR_RocketVelocity[entity];
					vecVelocity[1] *= RMR_RocketVelocity[entity];
					vecVelocity[2] *= RMR_RocketVelocity[entity];
					// apply both changes
					TeleportEntity(entity, NULL_VECTOR, rocketAngle, vecVelocity);
					
					RMR_NextDeviationAt[entity] = GetGameTime() + 0.1;
				}
			}
		}
	}		
}
*/