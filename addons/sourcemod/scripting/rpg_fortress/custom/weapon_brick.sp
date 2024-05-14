#pragma semicolon 1
#pragma newdecls required


void BrickWeapon_Map_Precache()
{
	PrecacheSound("physics/concrete/rock_impact_hard1.wav");
	PrecacheSound("physics/concrete/rock_impact_hard2.wav");
	PrecacheSound("physics/concrete/rock_impact_hard3.wav");
	PrecacheSound("physics/concrete/rock_impact_hard4.wav");
	PrecacheSound("physics/concrete/rock_impact_hard5.wav");
	PrecacheSound("physics/concrete/rock_impact_hard6.wav");
	PrecacheSound("weapons/slam/throw.wav");
}

public void Weapon_ThrowBrick(int client, int weapon, bool crit, int slot)
{
	float damage = 50.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	b_IsABow[weapon] = true;

		
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	EmitSoundToAll("weapons/slam/throw.wav", weapon, SNDCHAN_WEAPON, 80, _, 1.0);
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);

	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(target <= 0)
	{
		target = -2;
	}
	FinishLagCompensation_Base_boss();

	float speed = 2000.0;
	int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, 0, weapon, "bullet_distortion_trail_tracer");
	ApplyCustomModelToWandProjectile(projectile, "models/props_debris/concrete_cynderblock001.mdl", 0.8, "");
	WandProjectile_ApplyFunctionToEntity(projectile, BrickTouchStart);

	Initiate_HomingProjectile(projectile,
	projectile,
		180.0,			// float lockonAngleMax,
		180.0,				//float homingaSec,
		true,				// bool LockOnlyOnce,
		true,				// bool changeAngles,
		fAng,
		target);			// float AnglesInitiate[3]);
}


public void Weapon_ThrowBrick_Admin(int client, int weapon, bool crit, int slot)
{
	float damage = 50.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	b_IsABow[weapon] = true;

		
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	EmitSoundToAll("weapons/slam/throw.wav", weapon, SNDCHAN_WEAPON, 80, _, 1.0);

	float speed = 2000.0;
	int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, 0, weapon, "bullet_distortion_trail_tracer");
	ApplyCustomModelToWandProjectile(projectile, "models/props_debris/concrete_cynderblock001.mdl", 0.8, "");
	WandProjectile_ApplyFunctionToEntity(projectile, BrickTouchStart);

	Initiate_HomingProjectile(projectile,
	projectile,
		180.0,			// float lockonAngleMax,
		180.0,				//float homingaSec,
		false,				// bool LockOnlyOnce,
		true,				// bool changeAngles,
		fAng,
		0);			// float AnglesInitiate[3]);
}

public void BrickTouchStart(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
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

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, PushforceDamage, Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		PlayBrickSound(entity);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		PlayBrickSound(entity);
		RemoveEntity(entity);
	}
}

void PlayBrickSound(int entity)
{
	switch(GetRandomInt(1,6))
	{
		case 1:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 4:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 5:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 6:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
	}
}
