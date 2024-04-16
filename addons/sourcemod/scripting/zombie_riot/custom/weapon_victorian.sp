#pragma semicolon 1
#pragma newdecls required

#define SYRINGE_MODEL	"models/weapons/w_models/w_nail.mdl"

void Nailgun_Map_Precache()
{
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_4);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_FLESH_5);
	
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_AUTOAIM_IMPACT_CONCRETE_4);
	PrecacheModel(SYRINGE_MODEL);
}

public void Weapon_Nailgun(int client, int weapon, bool crit)
{
	float damage = 500.0;
	damage *= 0.8; //Reduction
	damage *= Attributes_Get(weapon, 2, 1.0);	

	float speed = 1300.0;
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 7/*Default wand*/, weapon, "furious_flyer_activated",_,false);

	SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
}

public void Gun_NailgunTouch(int entity, int target)
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

		float BaseDMG = 600.0
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);
		Radius *= Attributes_Get(weapon, 100, 1.0);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, spawnLoc, Radius, Falloff);
		EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
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