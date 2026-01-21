#pragma semicolon 1
#pragma newdecls required

#define HITSCAN_BOOM	  "ambient/explosions/explode_4.wav"
#define LASER_BOOMSTICK	  "npc/scanner/cbot_energyexplosion1.wav"

void BoomStick_MapPrecache()
{
	PrecacheSound(HITSCAN_BOOM);
	PrecacheSound(LASER_BOOMSTICK);
}

public void Weapon_Boom_Stick(int client, int weapon, bool crit, int slot)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 4);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -200.0 * Ratio;
		
		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues

			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;

	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	float ShakeRatio = Ratio;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 45.0 * ShakeRatio, 30.0 * ShakeRatio, 0.8 * ShakeRatio);
}

public void Weapon_Boom_Stick_Louder(int client, int weapon, bool crit, int slot)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 6);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		
		float knockback = -250.0 * Ratio;

		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio);
	float ShakeRatio = Ratio;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 45.0 * ShakeRatio, 30.0 * ShakeRatio, 0.8 * ShakeRatio);
}

public void Weapon_Boom_Stick_Loudest(int client, int weapon, bool crit, int slot)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 8);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		
		float knockback = -275.0 * Ratio;

		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	float ShakeRatio = Ratio;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 45.0 * ShakeRatio, 30.0 * ShakeRatio, 0.8 * ShakeRatio);
}

public void Marksman_boom_rifle(int client, int weapon, bool crit, int slot)
{
	float damage = 100.0;
	damage *= RoundToCeil(Attributes_Get(weapon, 2, 1.0));
		
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];

	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);

	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	}	
	SpawnSmallExplosionNotRandom(spawnLoc);
	EmitSoundToAll(HITSCAN_BOOM, -1, _, 80, _, _, _, _,spawnLoc);
	Explode_Logic_Custom(damage, client, client, weapon, spawnLoc);
		
	FinishLagCompensation_Base_boss();
	delete trace;
}


public void Weapon_Boom_Stick_Louder_Laser(int client, int weapon, bool crit, int slot)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 6);

	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -200.0 * Ratio;
		
		float TempRatio = Ratio;
		if(TempRatio > 1.0)
			TempRatio = 1.0;

		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0 * TempRatio);
		else
			velocity[2] += 100.0 * TempRatio; // a little boost to alleviate arcing issues
			
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			velocity[i] += newVel[i];
		}
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	float SoundRatio = 0.5 * Ratio;
	if(SoundRatio > 1.0)
		SoundRatio = 1.0;
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	EmitSoundToAll(LASER_BOOMSTICK, client, SNDCHAN_STATIC, 80, _, SoundRatio, 75);
	float ShakeRatio = Ratio;
	if(ShakeRatio > 1.3)
		ShakeRatio = 1.3;
	Client_Shake(client, 0, 45.0 * ShakeRatio, 30.0 * ShakeRatio, 0.8 * ShakeRatio);

	float damage = 6.0;
	damage *= 6.33;
	//fix broken damage ?
	//old beamstick code was WACK.
	
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);
	float extra_accuracy = 6.5;
	
	extra_accuracy *= Attributes_Get(weapon, 106, 1.0);

	Player_Laser_Logic Laser;
	float Radius = (Inv_Slug_Shell_Pouch[client] ? 10.0 : 5.0);
	Laser.client = client;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;

	int color[4] = {255, 165, 0, 60};
	float Origin[3]; GetClientEyePosition(client, Origin);
	if(Inv_Slug_Shell_Pouch[client])
	{
		color = {255, 65, 15, 80};
		float angles[3];
		GetClientEyeAngles(client, angles);
		Laser.DoForwardTrace_Custom(angles, Origin, 1000.0);
		PlayerLaserDoDamageCombined(Laser, damage, damage*0.6);
		DoPlayerLaserEffectsBigger(Laser, color);
	}
	else
	{
		for (int repeats = 1; repeats <= 6; repeats++)
		{
			float angles[3];
			GetClientEyeAngles(client, angles);
			switch(repeats)
			{
				case 1:
				{
					angles[0] += -extra_accuracy;
					angles[1] += extra_accuracy*2.0;
				}
				case 2:
				{
					angles[0] += -extra_accuracy;
					angles[1] += 0.0;
				}
				case 3:
				{
					angles[0] += -extra_accuracy;
					angles[1] += -(extra_accuracy*2.0);
				}
				case 4:
				{
					angles[0] += extra_accuracy;
					angles[1] += extra_accuracy*2.0;
				}
				case 5:
				{
					angles[0] += extra_accuracy;
					angles[1] += 0.0;
				}
				case 6:
				{
					angles[0] += extra_accuracy;
					angles[1] += -(extra_accuracy*2.0);
				}
			}

			Laser.DoForwardTrace_Custom(angles, Origin, 1000.0);
			PlayerLaserDoDamageCombined(Laser, damage, damage*0.75);
			DoPlayerLaserEffectsBigger(Laser, color);
		}
	}
}


float BoomstickAdjustDamageAndAmmoCount(int weapon, int bulletsmax)
{
	int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	int CurrentClip = GetEntData(weapon, iAmmoTable, 4);

	float RatioMax;

	RatioMax = float(CurrentClip) / float(bulletsmax);

	SetEntData(weapon, iAmmoTable, 1);
	SetEntProp(weapon, Prop_Send, "m_iClip1", 1); // weapon clip amount bullets
	Attributes_Set(weapon, 1, RatioMax);

	return RatioMax;
}