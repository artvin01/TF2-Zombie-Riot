static int RMR_CurrentHomingTarget[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RMR_HomingPerSecond[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static bool RWI_LockOnlyOnce[MAXENTITIES];
static bool RWI_WasLockedOnce[MAXENTITIES];
static float RWI_RocketSpeed[MAXENTITIES];

static bool RWI_AlterRocketActualAngle[MAXENTITIES];
static float RWI_RocketRotation[MAXENTITIES][3];

//Credits: Me (artvin) for rewriting it abit so its easier to read
// Sarysa (sarysa pub 1 plugin)
void Initiate_HomingProjectile(int projectile, int owner, float lockonAngleMax, float homingaSec, float HomeAngle, bool LockOnlyOnce, bool changeAngles, float AnglesInitiate[3], int initialTarget = -1)
{
	RMR_RocketOwner[projectile] = EntIndexToEntRef(owner);
	RWI_HomeAngle[projectile] = HomeAngle; 			//whats the max homing im allowed to do 
	RMR_HomingPerSecond[projectile] = homingaSec; 	//whats the homingpersec
	RWI_LockOnAngle[projectile] = lockonAngleMax;	//at what point do i lose my Target if out of my angle
	RWI_LockOnlyOnce[projectile] = LockOnlyOnce; 	//Incase we do not want to refind a Target to home onto
	RWI_WasLockedOnce[projectile] = false;
	RMR_CurrentHomingTarget[projectile] = initialTarget;
	RWI_AlterRocketActualAngle[projectile] = changeAngles;
	RWI_RocketRotation[projectile] = AnglesInitiate;
	float vecVelocityCurrent[3];
	GetEntPropVector(projectile, Prop_Send, "m_vInitialVelocity", vecVelocityCurrent);
	RWI_RocketSpeed[projectile] = getLinearVelocity(vecVelocityCurrent);
	//homing will always be 0.1 seconds, thats the delay.
	CreateTimer(0.1, Projectile_NonPerfectHoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	/*
		dont bother using EntRef for RMR_CurrentHomingTarget, it has a 0.1 timer
		and the same entity cannot be repeated/id cant be replaced in under 1 second
		due to source engine
		todo perhaps: Use requestframes and make a loop of it, thats basically OnGameFrame!
	*/
}

public Action Projectile_NonPerfectHoming(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidEntity(RMR_RocketOwner[entity])) //no need for converting.
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}

		//The enemy is valid
		if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
		{
			if(HomingProjectile_IsVisible(entity, RMR_CurrentHomingTarget[entity]))
			{
				HomingProjectile_TurnToTarget_NonPerfect(entity, RMR_CurrentHomingTarget[entity]);
				return Plugin_Continue;
			}
			else
			{
				RMR_CurrentHomingTarget[entity] = -1;
			}
		}

		//We already lost our homing Target AND we made it so we cant get another, kill the homing.
		if(RWI_LockOnlyOnce[entity] && RWI_WasLockedOnce[entity])
		{
			return Plugin_Stop;
		}

		//the current enemy doesnt exist, rehome
		int Closest = GetClosestTarget(entity, _, _, true,_,_,_,_,_,_,_,_,view_as<Function>(HomingProjectile_ValidTargetCheck));
		if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
		{
			if(IsValidEnemy(entity, Closest))
			{
				if(HomingProjectile_IsVisible(entity, Closest))
				{
					RMR_CurrentHomingTarget[entity] = Closest;
					RWI_WasLockedOnce[entity] = true;
					HomingProjectile_TurnToTarget_NonPerfect(entity, Closest);
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

bool HomingProjectile_IsVisible(int projectile, int Target)
{
	//are they even traceable?
	if(!Can_I_See_Enemy_Only(projectile, Target))
	{
		return false;
	}
	static float ang3[3];
	
	float ang_Look[3];
	ang_Look = RWI_RocketRotation[projectile];

	float pos1[3];
	float pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	pos1 = WorldSpaceCenter(Target);
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	// verify angle validity
	if(!(fabs(ang_Look[0] - ang3[0]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[0] - ang3[0]) >= (360.0-RWI_LockOnAngle[projectile]))))
		return false;


	if(!(fabs(ang_Look[1] - ang3[1]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[1] - ang3[1]) >= (360.0-RWI_LockOnAngle[projectile]))))
		return false;


	//they are still in my respected boundry.
	return true;
}

void HomingProjectile_TurnToTarget_NonPerfect(int projectile, int Target)
{
	float maxAngleDeviation = RMR_HomingPerSecond[projectile];

	static float rocketAngle[3];

	rocketAngle = RWI_RocketRotation[projectile];
	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", rocketOrigin);

	float pos1[3];
	pos1 = WorldSpaceCenter(Target);
	GetVectorAnglesTwoPoints(rocketOrigin, pos1, tmpAngles);

	for (int i = 0; i < 2; i++)
	{
		if (fabs(rocketAngle[i] - tmpAngles[i]) <= RWI_HomeAngle[projectile])
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
	// now use the old velocity and tweak it to match the int angles
	float vecVelocity[3];
	GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
	
	vecVelocity[0] *= RWI_RocketSpeed[projectile];
	vecVelocity[1] *= RWI_RocketSpeed[projectile];
	vecVelocity[2] *= RWI_RocketSpeed[projectile];

	RWI_RocketRotation[projectile] = rocketAngle;

	// apply both changes
	if(RWI_AlterRocketActualAngle[projectile])
		TeleportEntity(projectile, NULL_VECTOR, rocketAngle, vecVelocity);
	else
		TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

bool HomingProjectile_ValidTargetCheck(int projectile, int Target)
{
	static float ang3[3];
	
	float ang_Look[3];
	ang_Look = RWI_RocketRotation[projectile];

	float pos1[3];
	float pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	pos1 = WorldSpaceCenter(Target);
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	// verify angle validity
	if(!(fabs(ang_Look[0] - ang3[0]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[0] - ang3[0]) >= (360.0-RWI_LockOnAngle[projectile]))))
		return false;

	if(!(fabs(ang_Look[1] - ang3[1]) <= RWI_LockOnAngle[projectile] ||
	(fabs(ang_Look[1] - ang3[1]) >= (360.0-RWI_LockOnAngle[projectile]))))
		return false;
		
	return true;
}

stock float getLinearVelocity(float vecVelocity[3])
{
	return SquareRoot((vecVelocity[0] * vecVelocity[0]) + (vecVelocity[1] * vecVelocity[1]) + (vecVelocity[2] * vecVelocity[2]));
}