#pragma semicolon 1
#pragma newdecls required

#define BOOMERANG_MODEL "models/props_forest/saw_blade.mdl"

static int HitsLeft[MAXENTITIES]={0, ...};

void WeaponBoomerang_MapStart()
{


}

public void Weapon_Boomerang_Attack(int client, int weapon, bool crit)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	delay_hud[client] = 0.0;
			
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	float time = 2500.0 / speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);

	time *= 5.0;
	float fAng[3];
	GetClientEyeAngles(client, fAng);

	float fPos[3];
	GetClientEyePosition(client, fPos);

		
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, -1, weapon, "", fAng, false , fPos);
	WandProjectile_ApplyFunctionToEntity(projectile, Weapon_Boomerang_Touch);
	HitsLeft[projectile] = 30;

	//store_owner = GetClientUserId(client);
	ApplyCustomModelToWandProjectile(projectile, BOOMERANG_MODEL, 1.0, "");
	b_NpcIsTeamkiller[projectile] = true; //allows self hitting
}

public void Weapon_Boomerang_Touch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(owner < 0)
	{
		//owner doesnt exist???
		//suicide.
		//dont bother with coding these annyoing exceptions.
		RemoveEntity(entity);
		return;
	}
			
	//we dont want it to count allies as enemies so we temp set it to false.
	b_NpcIsTeamkiller[entity] = false;
	//we have found a valid target.
	if(IsValidEnemy(entity,target, true, true) 
	&& !IsIn_HitDetectionCooldown(entity,target, Boomerang) 
	&& HitsLeft[entity] > 0)
	{
		//we also want to never try to rehit the same target we already have hit.
		//we found a valid target.

		//Code to do damage position and ragdolls
		static float angles[3];
		GetRocketAngles(entity, angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		//it may say "wand" but its just the name, its used for any type of projectile at this point.
		
		//This is basically like saying a bool got hit and so on, this just saves those massive arrays.
		Set_HitDetectionCooldown(entity, target, FAR_FUTURE, Boomerang);
		HitsLeft[entity]--;

		
		if(HitsLeft[entity] > 0)
		{
			//we can still hit new targets, cycle through the closest enemy!
			int EnemyFound = GetClosestTarget(entity,
			true,
			500.0, //mas distanec of 500 i'd say.
			true,
			false,
			-1, 
			_,
			true, //only targts we can see should be homed to.
			_,
			_,
			true,
			_,
			view_as<Function>(Boomerang_ValidTargetCheck));

			if(!IsValidEntity(EnemyFound))
			{
				//noone was found... return to owner
				HitsLeft[entity] = 0;
			}
			else
			{
				float ang[3];
				GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
				Initiate_HomingProjectile(entity, 
				owner, 
				180.0, 
				180.0, 
				true, 
				true, 
				ang, 
				EnemyFound);
				SetEntityMoveType(entity, MOVETYPE_NOCLIP);
				//make it phase through everything to get to its owner.
			}
		}
		if(HitsLeft[entity] <= 0)
		{
			/*
				we have hit enough targets.... we need to go back without damaging any other targets,
				see above asto why i used HitsLeft[entity] there.
				we want to back to the owner, so just fly towards them.
			*/
			float ang[3];
			GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
			Initiate_HomingProjectile(entity, 
			owner, 
			180.0, 
			180.0, 
			true, 
			true, 
			ang, 
			owner);
		}
		//set it back to true once done so it can get us again.
		b_NpcIsTeamkiller[entity] = true;
		return;
	}
	if(HitsLeft[entity] <= 0 && target == owner)
	{
		//back home!
		RemoveEntity(entity);
		return;
	}

	if(target == 0)
	{
		/*
			hit world, go back home.
		*/
		HitsLeft[entity] = 0;
		float ang[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		Initiate_HomingProjectile(entity, 
		owner, 
		180.0, 
		180.0, 
		true, 
		true, 
		ang, 
		owner);
	}

	b_NpcIsTeamkiller[entity] = true;

}

bool Boomerang_ValidTargetCheck(int projectile, int Target)
{
	if(IsIn_HitDetectionCooldown(projectile,Target, Boomerang))
	{
		return false;
		//we have already hit this target, skip.
	}
	return true;
}