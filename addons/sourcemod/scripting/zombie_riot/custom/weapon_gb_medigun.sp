#pragma semicolon 1
#pragma newdecls required

void Gb_Ball_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_GB_Ball(int client, int weapon, bool crit)
{
	if(GetAmmo(client, 22) > 0)
	{
		SetAmmo(client, 22, (GetAmmo(client, 22) - 50));
		CurrentAmmo[client][22] = GetAmmo(client, 22);
		PrintHintText(client,"Medigun Medicine Fluid: %iml\n Press RELOAD to Enable Fast Cooldown system.\n Press M2 to Shoot Energy projectiles.", GetAmmo(client, 22));
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		
		float damage = 75.0;

		damage *= Attributes_FindOnWeapon(client, weapon, 8, true, 1.0);
		damage *= Attributes_GetOnPlayer(client, 8, true, true);

		if(LastMann)	
			damage *= 2.0;

		float speed = 2000.0;

		float time = 1000.0/speed;
		
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);

		Wand_Projectile_Spawn(client, speed, time, damage, 23/*GB gun*/, weapon, "drg_cow_rockettrail_normal",_,false);
	}
}

public void Event_GB_OnHatTouch(int entity, int target)
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
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity] * Target_Sucked_Long_Return(target), DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}