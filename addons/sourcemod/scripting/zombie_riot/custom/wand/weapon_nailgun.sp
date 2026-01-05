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
	float damage = 7.5;
	float attack_speed;
	attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
	damage = attack_speed * damage * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
	float sentry_range;	
	sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
			
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	speed *= sentry_range;
		
	float time = 10.0; //Pretty much inf.
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 7/*Default wand*/, weapon, "furious_flyer_activated",_,false);

	SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
}

void WeaponNailgun_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_NAILGUN_SMG)
	{
		DataPack pack = new DataPack();
		RequestFrame(Weapon_Nailgun_SMG, pack);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_NAILGUN_SHOTGUN)
	{
		DataPack pack = new DataPack();
		RequestFrame(Weapon_Nailgun_Shotgun, pack);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}
public void Weapon_Nailgun_SMG(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsValidEntity(weapon))
	{
		//when the weapon is created.
		float attack_speed;
			
		attack_speed = Attributes_GetOnPlayer(client, 343, true); //Sentry attack speed bonus
		Attributes_Set(weapon, 6, attack_speed);
		float Extra_Clip;
			
		Extra_Clip = 1.0 / Attributes_GetOnPlayer(client, 343, true); 
		Extra_Clip *= 2.0;
		Attributes_Set(weapon, 4, Extra_Clip);

		float damage = Attributes_GetOnPlayer(client, 287, true);			//Sentry damage bonus
		damage * 1.75;
		//reduce
		Attributes_Set(weapon, 2, damage);
	}
	delete pack;
}

public void Weapon_Nailgun_Shotgun(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsValidEntity(weapon))
	{
		//when the weapon is created.
		float attack_speed;
			
		attack_speed = Attributes_GetOnPlayer(client, 343, true); //Sentry attack speed bonus
		Attributes_Set(weapon, 6, attack_speed);
		if(Inv_Mini_Shell[client])attack_speed*=1.05;
		Attributes_Set(weapon, 97, attack_speed);//reload speed too for shotgun
		float Extra_Clip;
		
		Extra_Clip = 1.0 / Attributes_GetOnPlayer(client, 343, true);
		if(Inv_Mini_Shell[client])Extra_Clip*=1.5;
		Attributes_Set(weapon, 4, Extra_Clip);

		float damage = Attributes_GetOnPlayer(client, 287, true);			//Sentry damage bonus
		damage *= 0.85;
		//reduce
		if(Inv_Nailgun_Slug_Ammo[client]!=1.0)
			damage *= Inv_Nailgun_Slug_Ammo[client];
		if(Inv_Mini_Shell[client])
			damage *= 0.7;
		Attributes_Set(weapon, 2, damage);
			
	}
	delete pack;
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

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

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