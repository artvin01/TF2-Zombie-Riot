#pragma semicolon 1
#pragma newdecls required


static Handle Revert_Weapon_Back_Timer[MAXPLAYERS+1];
static int attacks_made[MAXPLAYERS+1]={8, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};
static bool Handle_on[MAXPLAYERS+1]={false, ...};

static int RMR_CurrentHomingTarget[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];

public void Weapon_Chlorophite_Heavy(int client, int weapon, bool crit)
{
	if(weapon >= MaxClients)
	{
		weapon_id[client] = EntIndexToEntRef(weapon);
		attacks_made[client] += -1;
				
		if (attacks_made[client] <= 2)
		{
			attacks_made[client] = 2;
		}
		Attributes_Set(weapon, 396, RampagerAttackSpeed(attacks_made[client]));
		if(Handle_on[client])
		{
			delete Revert_Weapon_Back_Timer[client];
		}
		Revert_Weapon_Back_Timer[client] = CreateTimer(3.0, Reset_weapon_rampager_Heavy, client, TIMER_FLAG_NO_MAPCHANGE);
		Handle_on[client] = true;
	}
	
	float damage = 6.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 2000.0;
	
	speed *= Attributes_Get(weapon, 103, 1.0);
		
	float time = 500.0/speed;
	
	time = 10.0;
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 9/*Default wand*/, weapon, "raygun_projectile_red_trail");
	
	RMR_CurrentHomingTarget[projectile] = -1;
	RMR_RocketOwner[projectile] = client;
}

public void Gun_ChlorophiteTouch(int entity, int target)
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

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}



public Action Reset_weapon_rampager_Heavy(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		attacks_made[client] = 8;
		if(IsValidEntity(EntRefToEntIndex(weapon_id[client])))
		{
			Attributes_Set((EntRefToEntIndex(weapon_id[client])), 396, RampagerAttackSpeed(attacks_made[client]));
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
	Handle_on[client] = false;
	return Plugin_Handled;
}
