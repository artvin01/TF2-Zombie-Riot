#pragma semicolon 1
#pragma newdecls required



void ObuchHammer_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("weapons/bat_baseball_hit_flesh.wav");
}
public void Npc_OnTakeDamage_ObuchHammer(int attacker, int weapon)
{

	ApplyTempAttrib(weapon, 6, 0.7, 1.2);
	ApplyTempAttrib(weapon, 2, 1.1, 1.2);
	ApplyTempAttrib(weapon, 206, 0.95, 1.2);
	//PrintToChatAll("Hit");
	EmitSoundToAll("weapons/bat_baseball_hit_flesh.wav", attacker, SNDCHAN_STATIC, 80, _, 0.9, 120);
}

/*
public void Melee_ObuchTouch(int entity, int target)
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

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_CLUB, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?

		ApplyTempAttrib(weapon, 6, 0.8, 0.1);
		ApplyTempAttrib(weapon, 2, 1.1, 0.1);

		EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9, 120);

		RemoveEntity(entity);
	}
}
*/