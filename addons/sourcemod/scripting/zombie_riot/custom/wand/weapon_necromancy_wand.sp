#pragma semicolon 1
#pragma newdecls required

#define SOUND_WAND_SHOT_NECRO	"weapons/dragons_fury_shoot.wav"
#define SOUND_NECRO_IMPACT "misc/halloween/spell_lightning_ball_impact.wav"

void Wand_Necro_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_NECRO);
	PrecacheSound(SOUND_NECRO_IMPACT);
}

public void Weapon_Necro_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
		
		float time = 500.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
			
		EmitSoundToAll(SOUND_WAND_SHOT_NECRO, client, SNDCHAN_WEAPON, 65, _, 0.45, 100);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "eyeboss_projectile");
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}


public void Want_NecroTouch(int entity, int target)
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
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, false);	// 2048 is DMG_NOGIB?
		ApplyStatusEffect(owner, target, "Marked", 5.0);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_NECRO_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_NECRO_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
}