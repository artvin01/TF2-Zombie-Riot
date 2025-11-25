static int RMR_CurrentHomingTarget[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RMR_HomingPerSecond[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static bool RWI_LockOnlyOnce[MAXENTITIES];
static bool RWI_WasLockedOnce[MAXENTITIES];
static float RWI_RocketSpeed[MAXENTITIES];

static bool RWI_AlterRocketActualAngle[MAXENTITIES];
static float RWI_RocketRotation[MAXENTITIES][3];
static Handle RWI_HandleHome[MAXENTITIES];

void TriggerTimerHoming(int entity)
{
	TriggerTimer(RWI_HandleHome[entity]);
}
#if defined ZR
void GetRocketAngles(int entity, float angles[3])
{
	angles = RWI_RocketRotation[entity];
}
#endif

stock void HomingProjectile_SetProjectileSpeed(int projectile, float speed)
{
	RWI_RocketSpeed[projectile] = speed;
}

stock bool HomingProjectile_IsActive(int projectile)
{
	return RMR_CurrentHomingTarget[projectile] != -1;
}
stock void HomingProjectile_Deactivate(int projectile)
{
	//this will kill the homing of a projectile by simply making the target it has invalid / making it "lock only once", aka it won't try to find a new target and instead it will kill the timer
	RWI_LockOnlyOnce[projectile] = true;
	RMR_CurrentHomingTarget[projectile] = -1;
}

//Credits: Me (artvin) for rewriting it abit so its easier to read
// Sarysa (sarysa pub 1 plugin)
void Initiate_HomingProjectile(int projectile, int owner, float lockonAngleMax, float homingaSec, bool LockOnlyOnce, bool changeAngles, float AnglesInitiate[3], int initialTarget = -1)
{
	RMR_RocketOwner[projectile] = EntIndexToEntRef(owner);
	RMR_HomingPerSecond[projectile] = homingaSec; 	//whats the homingpersec
	RWI_LockOnAngle[projectile] = lockonAngleMax;	//at what point do i lose my Target if out of my angle
	RWI_LockOnlyOnce[projectile] = LockOnlyOnce; 	//Incase we do not want to refind a Target to home onto
	RWI_WasLockedOnce[projectile] = false;
	if(initialTarget != -1)
		RWI_WasLockedOnce[projectile] = true;
		
	RMR_CurrentHomingTarget[projectile] = initialTarget;
	RWI_AlterRocketActualAngle[projectile] = changeAngles;

	RWI_RocketRotation[projectile][0] = AnglesInitiate[0];
	RWI_RocketRotation[projectile][1] = AnglesInitiate[1];
	RWI_RocketRotation[projectile][2] = AnglesInitiate[2];

	float vecVelocityCurrent[3];
	GetEntPropVector(projectile, Prop_Data, "m_vInitialVelocity", vecVelocityCurrent);
	RWI_RocketSpeed[projectile] = getLinearVelocity(vecVelocityCurrent);
	//homing will always be 0.1 seconds, thats the delay.
	if(RWI_HandleHome[projectile] != null)
		delete RWI_HandleHome[projectile];
	//incase a homing will be reused, just do this!
	DataPack pack;
	RWI_HandleHome[projectile] = CreateDataTimer(0.1, Projectile_NonPerfectHoming, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(projectile));
	pack.WriteCell(projectile);
	//TriggerTimer(RWI_HandleHome[entity]);
	/*
		dont bother using EntRef for RMR_CurrentHomingTarget, it has a 0.1 timer
		and the same entity cannot be repeated/id cant be replaced in under 1 second
		due to source engine
		todo perhaps: Use requestframes and make a loop of it, thats basically OnGameFrame!
	*/
}


public Action Projectile_NonPerfectHoming(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int entityIdx = pack.ReadCell();
	if(IsValidEntity(entity))
	{
		if(!IsValidEntity(RMR_RocketOwner[entity])) //no need for converting.
		{
			RemoveEntity(entity);
			RWI_HandleHome[entityIdx] = null;
			return Plugin_Stop;
		}

		//if we home onto ourselves, allow this regardless of everything.
		if(EntRefToEntIndex(RMR_RocketOwner[entity]) == RMR_CurrentHomingTarget[entity])
		{
			HomingProjectile_TurnToTarget_NonPerfect(entity, RMR_CurrentHomingTarget[entity]);
			return Plugin_Continue;
		}
		//The enemy is valid
		if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity],true, true))
		{
			if(GetEntityMoveType(entity) == MOVETYPE_NOCLIP || HomingProjectile_IsVisible(entity, RMR_CurrentHomingTarget[entity]))
			{
				if(HomingProjectile_ValidTargetCheck(entity, RMR_CurrentHomingTarget[entity]))
				{
					HomingProjectile_TurnToTarget_NonPerfect(entity, RMR_CurrentHomingTarget[entity]);
					return Plugin_Continue;
				}
			}
		}
		RMR_CurrentHomingTarget[entity] = -1;

		//We already lost our homing Target AND we made it so we cant get another, kill the homing.
		if(RWI_LockOnlyOnce[entity] && RWI_WasLockedOnce[entity])
		{
			RWI_HandleHome[entityIdx] = null;
			return Plugin_Stop;
		}

		//the current enemy doesnt exist, rehome
		int Closest = GetClosestTarget(entity, _, _, true,_,_,_,_,_,_,_,_,view_as<Function>(HomingProjectile_ValidTargetCheck));
		if(IsValidEnemy(EntRefToEntIndex(RMR_RocketOwner[entity]), Closest))
		{
			if(IsValidEnemy(entity, Closest,true, true))
			{
				if(GetEntityMoveType(entity) == MOVETYPE_NOCLIP || HomingProjectile_IsVisible(entity, Closest))
				{
					if(HomingProjectile_ValidTargetCheck(entity, Closest))
					{
						RMR_CurrentHomingTarget[entity] = Closest;
						RWI_WasLockedOnce[entity] = true;
						HomingProjectile_TurnToTarget_NonPerfect(entity, Closest);
					}
				}
				return Plugin_Continue;
			}
		}
	}
	else
	{
		RWI_HandleHome[entityIdx] = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}	

bool HomingProjectile_IsVisible(int projectile, int Target)
{
	//are they even traceable?
	if(!Can_I_See_Enemy_Only(projectile, Target))
	{
		return false;
	}
	return true;
}

void HomingProjectile_TurnToTarget_NonPerfect(int projectile, int Target)
{
	static float rocketAngle[3];

	rocketAngle[0] = RWI_RocketRotation[projectile][0];
	rocketAngle[1] = RWI_RocketRotation[projectile][1];
	rocketAngle[2] = RWI_RocketRotation[projectile][2];

	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", rocketOrigin);

	float pos1[3];
	WorldSpaceCenter(Target, pos1);
	GetRayAngles(rocketOrigin, pos1, tmpAngles);
	
	// Thanks to mikusch for pointing out this function to use instead
	// we had a simular function but i forgot that it existed before
	// https://github.com/Mikusch/ChaosModTF2/pull/4/files
	rocketAngle[0] = ApproachAngle(tmpAngles[0], rocketAngle[0], RMR_HomingPerSecond[projectile]);
	rocketAngle[1] = ApproachAngle(tmpAngles[1], rocketAngle[1], RMR_HomingPerSecond[projectile]);
	
	float vecVelocity[3];
	GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
	
	vecVelocity[0] *= RWI_RocketSpeed[projectile];
	vecVelocity[1] *= RWI_RocketSpeed[projectile];
	vecVelocity[2] *= RWI_RocketSpeed[projectile];

	RWI_RocketRotation[projectile][0] = rocketAngle[0];
	RWI_RocketRotation[projectile][1] = rocketAngle[1];
	RWI_RocketRotation[projectile][2] = rocketAngle[2];

	// Apply only both if we want to, angle doesnt matter mostly
	if(RWI_AlterRocketActualAngle[projectile])
	{
		Custom_SetAbsVelocity(projectile, vecVelocity);
		SetEntPropVector(projectile, Prop_Data, "m_angRotation", rocketAngle); 
	}
	else
	{
		
		Custom_SetAbsVelocity(projectile, vecVelocity);
	}
}

bool HomingProjectile_ValidTargetCheck(int projectile, int Target)
{
	static float ang3[3];
	
	float ang_Look[3];

	ang_Look[0] = RWI_RocketRotation[projectile][0];
	ang_Look[1] = RWI_RocketRotation[projectile][1];
	ang_Look[2] = RWI_RocketRotation[projectile][2];

	float pos1[3];
	float pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	WorldSpaceCenter(Target, pos1);
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	// verify angle validity
	if(!(fabs(ang_Look[0] - ang3[0]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[0] - ang3[0]) >= (360.0-RWI_LockOnAngle[projectile]))))
	{
		return false;
	}

	if(!(fabs(ang_Look[1] - ang3[1]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[1] - ang3[1]) >= (360.0-RWI_LockOnAngle[projectile]))))
	{
		return false;
	}
		
	return true;
}

stock float getLinearVelocity(float vecVelocity[3])
{
	return SquareRoot((vecVelocity[0] * vecVelocity[0]) + (vecVelocity[1] * vecVelocity[1]) + (vecVelocity[2] * vecVelocity[2]));
}