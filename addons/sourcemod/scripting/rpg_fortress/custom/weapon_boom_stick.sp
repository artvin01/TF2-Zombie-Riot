#pragma semicolon 1
#pragma newdecls required

#define HITSCAN_BOOM	  "ambient/explosions/explode_4.wav"

#define MAXENTITIES 2048

void BoomStick_MapPrecache()
{
	PrecacheSound(HITSCAN_BOOM);
}

public void Weapon_Boom_Stick(int client, int weapon, const char[] classname, bool &result)
{
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = -150.0;
		
	ScaleVector(velocity, knockback);
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 300.0);
	else
		velocity[2] += 100.0; // a little boost to alleviate arcing issues
			
			
	float newVel[3];
		
	newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
						
	for (int i = 0; i < 3; i++)
	{
		velocity[i] += newVel[i];
	}
		
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	Client_Shake(client, 0, 35.0, 20.0, 0.8);
}