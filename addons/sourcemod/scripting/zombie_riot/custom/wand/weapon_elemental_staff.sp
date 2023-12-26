#pragma semicolon 1
#pragma newdecls required

//#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT_ELEMENTAL_1 	"weapons/physcannon/energy_sing_flyby1.wav"
#define SOUND_WAND_SHOT_ELEMENTAL_2 	"weapons/physcannon/energy_sing_flyby2.wav"
#define SOUND_ELEMENTAL_IMPACT_1			"weapons/physcannon/energy_bounce1.wav"
#define SOUND_ELEMENTAL_IMPACT_2 			"weapons/physcannon/energy_bounce2.wav"

void Wand_Elemental_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_ELEMENTAL_1);
	PrecacheSound(SOUND_WAND_SHOT_ELEMENTAL_2);
	PrecacheSound(SOUND_ELEMENTAL_IMPACT_1);
	PrecacheSound(SOUND_ELEMENTAL_IMPACT_2);
//	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_Elemental_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);
			
		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				EmitSoundToAll(SOUND_WAND_SHOT_ELEMENTAL_1, client, _, 65, _, 0.45, 135);
			}
			case 2:
			{
				EmitSoundToAll(SOUND_WAND_SHOT_ELEMENTAL_2, client, _, 65, _, 0.45, 135);
			}
		}
		Wand_Projectile_Spawn(client, speed, time, damage, 6/*Default wand*/, weapon, "unusual_genplasmos_b_parent");
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}


public void Want_ElementalWandTouch(int entity, int target)
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

		NPC_Ignite(target, owner, 3.0, weapon);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				EmitSoundToAll(SOUND_ELEMENTAL_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
			case 2:
			{
				EmitSoundToAll(SOUND_ELEMENTAL_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				EmitSoundToAll(SOUND_ELEMENTAL_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
			case 2:
			{
				EmitSoundToAll(SOUND_ELEMENTAL_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
		}
		RemoveEntity(entity);
	}
}