#pragma semicolon 1
#pragma newdecls required

#define SYRINGE_MODEL	"models/weapons/w_models/w_nail.mdl"

#define SOUND_AUTOAIM_IMPACT_FLESH_1 		"physics/flesh/flesh_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_2 		"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_3 		"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_4 		"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_5 		"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_AUTOAIM_IMPACT_CONCRETE_1 		"physics/concrete/concrete_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

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
	float damage = 7.5;
		
	float attack_speed;
		
	attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
	damage = attack_speed * damage * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		
	float sentry_range;
			
	sentry_range = Attributes_FindOnPlayer(client, 344, true, 1.0);			//Sentry Range bonus
			
	float speed = 1100.0;
	Address address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 104);
	if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 475);
	if(address != Address_Null)
		speed *= TF2Attrib_GetValue(address);
	
	speed *= sentry_range;
		
	float time = 10.0; //Pretty much inf.
	


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
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
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