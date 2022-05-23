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

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

public void Wand_autoaim_ClearAll()
{
	Zero(ability_cooldown);
}
//#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT_AUTOAIM 	"weapons/man_melter_fire.wav"
#define SOUND_WAND_SHOT_AUTOAIM_ABILITY	"weapons/man_melter_fire_crit.wav"
#define SOUND_AUTOAIM_IMPACT 		"misc/halloween/spell_lightning_ball_impact.wav"

void Wand_autoaim_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM);
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM_ABILITY);
	PrecacheSound(SOUND_AUTOAIM_IMPACT);
//	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_autoaim_Wand_Shotgun(int client, int weapon, bool crit)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 120;
		if(mana_cost <= Current_Mana[client])
		{
			if (ability_cooldown[client] < GetGameTime())
			{
				ability_cooldown[client] = GetGameTime() + 5.0; //10 sec CD
				
				float damage = 65.0;
				Address address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
				
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
				
				delay_hud[client] = 0.0;
					
				float speed = 1100.0;
				address = TF2Attrib_GetByDefIndex(weapon, 103);
				if(address != Address_Null)
					speed *= TF2Attrib_GetValue(address);
			
				address = TF2Attrib_GetByDefIndex(weapon, 104);
				if(address != Address_Null)
					speed *= TF2Attrib_GetValue(address);
			
				address = TF2Attrib_GetByDefIndex(weapon, 475);
				if(address != Address_Null)
					speed *= TF2Attrib_GetValue(address);
			
			
				float time = 500.0/speed;
				address = TF2Attrib_GetByDefIndex(weapon, 101);
				if(address != Address_Null)
					time *= TF2Attrib_GetValue(address);
			
				address = TF2Attrib_GetByDefIndex(weapon, 102);
				if(address != Address_Null)
					time *= TF2Attrib_GetValue(address);
					
				EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM_ABILITY, client, _, 75, _, 0.8, 135);
				
				for(int HowOften=0; HowOften<=10; HowOften++)
				{
					
					int iRot = CreateEntityByName("func_door_rotating");
					if(iRot == -1) return;
					CreateTimer(time, Timer_RemoveEntity, EntIndexToEntRef(iRot), TIMER_FLAG_NO_MAPCHANGE);
				
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
				//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
					Wand_Launch(client, iRot, speed, time, damage, weapon, true);
				}
			}
			else
			{
				float Ability_CD = ability_cooldown[client] - GetGameTime();
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}
public void Weapon_autoaim_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
		mana_cost = RoundToCeil(TF2Attrib_GetValue(address));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 104);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 475);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
	
		float time = 500.0/speed;
		address = TF2Attrib_GetByDefIndex(weapon, 101);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 102);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
		
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
		EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM, client, _, 75, _, 0.7, 135);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
		Wand_Launch(client, iRot, speed, time, damage, weapon, false);
	
	
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

static void Wand_Launch(int client, int iRot, float speed, float time, float damage, int weapon, bool silent = false)
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
	Projectile_To_Weapon[iCarrier] = weapon;
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "unusual_tesla_flash", 5.0);

		default:
			particle = ParticleEffectAt(position, "unusual_tesla_flash", 5.0);
	}
		
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	
	Angles[0] += GetRandomFloat(-5.0, 5.0);
	
	Angles[1] += GetRandomFloat(-5.0, 5.0);
	
	Angles[2] += GetRandomFloat(-5.0, 5.0);
	
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);
	SetParent(iCarrier, particle);	
	
	CreateTimer(0.1, Homing_Shots_Repeat_Timer, EntIndexToEntRef(iCarrier), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//	RMR_NextDeviationAt[iCarrier] = GetGameTime() + 0.4;
	RMR_HomingPerSecond[iCarrier] = 150.0;
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
	
	if(silent)
	{
		SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_autoaim_OnHatTouchSilent);
	}
	else
	{
		SDKHook(iCarrier, SDKHook_StartTouch, Event_Wand_autoaim_OnHatTouch);
	}
		
	
}

//Sarysapub1 code but fixed and altered to make it work for our base bosses
#define TARGET_Z_OFFSET 40.0

public Action Homing_Shots_Repeat_Timer(Handle timer, int ref)
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
public Action Event_Wand_autoaim_OnHatTouch(int entity, int other)
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
		
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_SHOCK, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position); // 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		NPC_Ignite(target, Projectile_To_Client[entity], 3.0, Projectile_To_Weapon[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action Event_Wand_autoaim_OnHatTouchSilent(int entity, int other)
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
		
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_SHOCK, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position); // 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		NPC_Ignite(target, Projectile_To_Client[entity], 3.0, Projectile_To_Weapon[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.1);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.1);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}