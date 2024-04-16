#pragma semicolon 1
#pragma newdecls required

#define SOUND_VIC_SHOT 	"weapons/doom_rocket_launcher.wav"

void Victoria_Map_Precache()
{
	PrecacheSound(SOUND_VIC_SHOT);
}

public void Weapon_Victoria(int client, int weapon, bool crit)
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

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_VICTORIAN_LAUNCHER, weapon, "rockettrail",_,false);
	EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 140, _, 1.0, 0.7);

	SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
}

public void Shell_VictorianTouch(int entity, int target)
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
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		float BaseDMG = 600.0
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);
		Radius *= Attributes_Get(weapon, 100, 1.0);

		float Falloff = Attributes_Get(weapon, 117, 1.0);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
		EmitAmbientSound(ExplosiveBulletsSFX[GetRandomInt(0, 2)], position, , 120, _,0.7, GetRandomInt(55, 80));
		
		DataPack pack_boom = new DataPack();
        pack_boom.WriteFloat(spawnLoc[0]);
        pack_boom.WriteFloat(spawnLoc[1]);
        pack_boom.WriteFloat(spawnLoc[2]);
        pack_boom.WriteCell(0);
        RequestFrame(MakeExplosionFrameLater, pack_boom);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{	
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
		EmitAmbientSound(ExplosiveBulletsSFX[GetRandomInt(0, 2)], position, , 120, _,0.7, GetRandomInt(55, 80));
		DataPack pack_boom = new DataPack();
        pack_boom.WriteFloat(spawnLoc[0]);
        pack_boom.WriteFloat(spawnLoc[1]);
        pack_boom.WriteFloat(spawnLoc[2]);
        pack_boom.WriteCell(0);
        RequestFrame(MakeExplosionFrameLater, pack_boom);
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 1.0);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 1.0);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 1.0);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}