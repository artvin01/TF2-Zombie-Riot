static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};

static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_CanRetarget[MAXENTITIES]={true, ...};
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
	Address address = TF2Attrib_GetByDefIndex(weapon, 2);
	if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
		
	float speed = 2000.0;
	
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
		
	float time = 500.0/speed;
	
	time = 10.0;
	
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
//	EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM, client, SNDCHAN_WEAPON, 75, _, 0.7, 135);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
	Wand_Launch(client, iRot, speed, time, damage, weapon);
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
	
	
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	RequestFrame(See_Projectile_Team, iCarrier);
	RequestFrame(See_Projectile_Team, iRot);

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
			particle = ParticleEffectAt(position, "raygun_projectile_blue_trail", 5.0);

		default:
			particle = ParticleEffectAt(position, "raygun_projectile_blue_trail", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	CreateTimer(0.1, Homing_Shots_Repeat_Timer_Chlorophite, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//	RMR_NextDeviationAt[iCarrier] = GetGameTime() + 0.4;
	RMR_HomingPerSecond[iCarrier] = 359.0;
	RMR_RocketOwner[iCarrier] = client;
	RMR_HasTargeted[iCarrier] = false;
	RWI_HomeAngle[iCarrier] = 180.0;
	RWI_LockOnAngle[iCarrier] = 180.0;
	RMR_RocketVelocity[iCarrier] = speed;
	RMR_CurrentHomingTarget[iCarrier] = -1;
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 0, 0, 0, 0);
		
		
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_Chlorophite_OnHatTouch);
		
	
}

//Sarysapub1 code but fixed and altered to make it work for our base bosses
#define TARGET_Z_OFFSET 40.0

public Action Homing_Shots_Repeat_Timer_Chlorophite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float deltaTime = 0.1;
			
		if(!IsValidClient(RMR_RocketOwner[entity]))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}
		
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
public Action Event_Wand_Chlorophite_OnHatTouch(int entity, int other)
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
		
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_BULLET, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			switch(GetRandomInt(1,5)) 
			{
				case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
			}
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			switch(GetRandomInt(1,4)) 
			{
				case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}