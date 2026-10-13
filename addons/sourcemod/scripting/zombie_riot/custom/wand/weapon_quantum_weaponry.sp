#pragma semicolon 1
#pragma newdecls required

void Quantum_Gear_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Quantum_Repeater_Main_Attack(int client, int weapon, bool crit)
{
	float damage = float(CashSpentTotal[client]);
	damage = Pow(damage, 1.15);
	damage = damage / 120.0;
			
	float speed = 3500.0;
	
	
	float time = 5000.0/speed;

	damage *= 1.1;
		
	EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
	Wand_Projectile_Spawn(client, speed, time, damage, 8/*Default wand*/, weapon, "raygun_projectile_blue_trail");

}

public void Gun_QuantumTouch(int entity, int target)
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
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


public void Quantum_Fists_Main_Attack(int client, int weapon, bool crit)
{
	float damageMulti = float(CashSpentTotal[client]);
	damageMulti = Pow(damageMulti, 1.15);
	damageMulti = damageMulti / 850.0;
	damageMulti *= 1.25;
		
	Attributes_Set(weapon, 2, damageMulti);
}

public void Quantum_Jetpack(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 700.0, false, 45.0, true); //infinite range, and ignore walls!
		FinishLagCompensation_Base_boss(.client = client);

		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		if(!IsValidEnemy(client, target, true))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 4.0);
		static float EntLoc[3];

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

		SpawnSmallExplosionNotRandom(EntLoc);

		EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 1200.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 150.0;    // a little boost to alleviate arcing issues

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}



public void Quantum_Retreater(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 200.0, false, 25.0, true); //infinite range, and ignore walls!
		FinishLagCompensation_Base_boss(.client = client);

		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		if(!IsValidEnemy(client, target, true))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 10.0);
		static float EntLoc[3];

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

		SpawnSmallExplosionNotRandom(EntLoc);

		EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -600.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 150.0;    // a little boost to alleviate arcing issues
			

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}
