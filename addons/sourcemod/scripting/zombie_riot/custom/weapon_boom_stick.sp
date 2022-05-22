#define HITSCAN_BOOM	  "ambient/explosions/explode_4.wav"

void BoomStick_MapPrecache()
{
	PrecacheSound(HITSCAN_BOOM);
}
public void Weapon_Boom_Stick(int client, int weapon, const char[] classname, bool &result)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(velocity, -500.0);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 100.0; // a little boost to alleviate arcing issues
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	Client_Shake(client, 0, 35.0, 20.0, 0.8);
}

public void Weapon_Boom_Stick_Louder(int client, int weapon, const char[] classname, bool &result)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
	{
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(velocity, -500.0);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 100.0; // a little boost to alleviate arcing issues
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 80);
	Client_Shake(client, 0, 45.0, 30.0, 0.8);
}

public void Marksman_boom_rifle(int client, int weapon, const char[] classname, bool &result)
{
	float damage = 100.0;
	Address address = TF2Attrib_GetByDefIndex(weapon, 2);
	if(address != Address_Null)
		damage *= RoundToCeil(TF2Attrib_GetValue(address));
		
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
			   
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client, false);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	FinishLagCompensation_Base_boss();
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	} 
	CloseHandle(trace);
//	if (GetVectorDistance(eyePos, spawnLoc, true) <= Pow(650.0, 2.0))
	{	

		SpawnSmallExplosionNotRandom(spawnLoc);
		EmitSoundToAll(HITSCAN_BOOM, -1, _, 90, _, _, _, _,spawnLoc);
		Explode_Logic_Custom(damage, client, client, weapon, spawnLoc);
	}
}