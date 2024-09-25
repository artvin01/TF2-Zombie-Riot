#pragma semicolon 1
#pragma newdecls required

#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT 	"weapons/capper_shoot.wav"
#define SOUND_ZAP "misc/halloween/spell_lightning_ball_impact.wav"

void Wand_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_Default_Wand(int client, int weapon, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 0.0));
	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;

		damage *= WeaponDamageAttributeMultipliers(weapon, MULTIDMG_MAGIC_WAND);

		RPGCore_ResourceReduction(client, mana_cost);
		
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		char particle[32];
		
		Format(particle, sizeof(particle), "%s", "drg_cow_rockettrail_normal");

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 1/*Default wand*/, weapon, particle);
		WandProjectile_ApplyFunctionToEntity(projectile, Want_DefaultWandTouch);

	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Weapon_Default_Wand_pap2(int client, int weapon, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 0.0));
	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		
		damage *= WeaponDamageAttributeMultipliers(weapon, MULTIDMG_MAGIC_WAND);

		RPGCore_ResourceReduction(client, mana_cost);
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
		float time = 500.0/speed;
	
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		char particle[32];
		
		Format(particle, sizeof(particle), "%s","drg_cow_rockettrail_normal_blue");
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 1/*Default wand*/, weapon, particle);
		WandProjectile_ApplyFunctionToEntity(projectile, Want_DefaultWandTouch);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Want_DefaultWandTouch(int entity, int target)
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

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, PushforceDamage, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
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