#pragma semicolon 1
#pragma newdecls required

static bool Projectile_Is_Silent[MAXENTITIES]={false, ...};

static int RMR_CurrentHomingTarget[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

public void Wand_autoaim_ClearAll()
{
	Zero(ability_cooldown);
}
//#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT_AUTOAIM 	"weapons/man_melter_fire.wav"
#define SOUND_WAND_SHOT_AUTOAIM_ABILITY	"weapons/man_melter_fire_crit.wav"
#define SOUND_AUTOAIM_IMPACT 		"misc/halloween/spell_lightning_ball_impact.wav"

void Wand_autoaim_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM);
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM_ABILITY);
	PrecacheSound(SOUND_AUTOAIM_IMPACT);
//	PrecacheModel(ENERGY_BALL_MODEL);
}

public void Weapon_autoaim_Wand_Shotgun(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		int pap=0;
		pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		int mana_cost = 140;
		if(pap == 1)
		{
			mana_cost = 180;
		}
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(client, weapon);
				if(pap == 0)
				{
					Ability_Apply_Cooldown(client, slot, 2.0);
				}
				else
				{
					Ability_Apply_Cooldown(client, slot, 0.5);
				}
				
				float damage = 65.0;
				damage *= Attributes_Get(weapon, 410, 1.0);

				damage *= 1.1;

				if(pap == 1)
					damage *= 0.75;
				
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
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

				time *= 0.75;
					
				EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM_ABILITY, client, _, 75, _, 0.8, 135);
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client);
				Handle swingTrace;
				float vecSwingForward[3];
				DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				FinishLagCompensation_Base_boss();
							
				int target = TR_GetEntityIndex(swingTrace);	
				delete swingTrace;
			
				float Angles[3];
				damage *= 2.0; //halved amount, so double damage
				for(int HowOften=0; HowOften<=5; HowOften++)
				{
					GetClientEyeAngles(client, Angles);
					for (int spread = 0; spread < 3; spread++)
					{
						Angles[spread] += GetRandomFloat(-15.0, 15.0);
					}
					int projectile;
					if(pap == 0)
					{
						projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_tesla_flash", Angles);
					}
					else
					{
						projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_stardust_white_parent", Angles);
					}
					Projectile_Is_Silent[projectile] = true;

					bool LockOnOnce = true;
					if(IsValidEntity(target))
						LockOnOnce = false;

					Initiate_HomingProjectile(projectile,
					client,
						90.0,			// float lockonAngleMax,
						5.0,				//float homingaSec,
						LockOnOnce,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						Angles,
						target);			// float AnglesInitiate[3]);	
				}
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}
public void Weapon_autoaim_Wand(int client, int weapon, bool crit, int slot)
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
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
		float Angles[3];
		GetClientEyeAngles(client, Angles);
		for (int spread = 0; spread < 3; spread++)
		{
			Angles[spread] += GetRandomFloat(-5.0, 5.0);
		}
		EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM, client, _, 75, _, 0.7, 135);

		int pap=0;
		pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));

		int projectile;
		if(pap == 0)
		{
			projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_tesla_flash", Angles);
		}
		else
		{
			projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_stardust_white_parent", Angles);
		}
		

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Handle swingTrace;
		float vecSwingForward[3];
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
		FinishLagCompensation_Base_boss();
					
		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;

		bool LockOnOnce = true;
		if(IsValidEntity(target))
			LockOnOnce = false;

		Initiate_HomingProjectile(projectile,
		client,
			90.0,			// float lockonAngleMax,
			15.0,				//float homingaSec,
			LockOnOnce,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			Angles,
			target);			// float AnglesInitiate[3]);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

//Sarysapub1 code but fixed and altered to make it work for our base bosses
#define TARGET_Z_OFFSET 40.0

public void Want_HomingWandTouch(int entity, int target)
{
	if (target > 0)	
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
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

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST); // 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		if(Projectile_Is_Silent[entity])
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.1);
		}
		else
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		
		RemoveEntity(entity);
	}
	else if(target == 0)
	{	
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		if(Projectile_Is_Silent[entity])
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.1);
		}
		else
		{
			EmitSoundToAll(SOUND_AUTOAIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		
		RemoveEntity(entity);
	}
}