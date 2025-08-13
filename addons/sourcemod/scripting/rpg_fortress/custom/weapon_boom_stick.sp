#pragma semicolon 1
#pragma newdecls required

#define HITSCAN_BOOM	  "ambient/explosions/explode_4.wav"


void BoomStick_MapPrecache()
{
	PrecacheSound(HITSCAN_BOOM);
}

public void Weapon_Boom_Stick(int client, int weapon, bool crit, int slot)
{
	float Ratio = BoomstickAdjustDamageAndAmmoCount(weapon, 4);

//	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
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
	Client_Shake(client, 0, 35.0 * ShakeRatio, 30.0 * ShakeRatio, 0.8 * ShakeRatio);
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