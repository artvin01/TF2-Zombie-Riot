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
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
		RemoveEntity(entity);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//


public void Quantum_Fists_Main_Attack(int client, int weapon, bool crit)
{
	float damageMulti = float(CashSpentTotal[client]);
	damageMulti = Pow(damageMulti, 1.15);
	damageMulti = damageMulti / 850.0;
	Attributes_Set(weapon, 2, damageMulti);
}