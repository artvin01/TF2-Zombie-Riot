#pragma semicolon 1
#pragma newdecls required

static bool Projectile_Is_Silent[MAXENTITIES]={false, ...};

static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];

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
		int mana_cost = 120;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 5.0);
				
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
					
				EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM_ABILITY, client, _, 75, _, 0.8, 135);
				
				float Angles[3];
				for(int HowOften=0; HowOften<=10; HowOften++)
				{
					GetClientEyeAngles(client, Angles);
					for (int spread = 0; spread < 3; spread++)
					{
						Angles[spread] += GetRandomFloat(-5.0, 5.0);
					}
					int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_tesla_flash", Angles);
					CreateTimer(0.1, Homing_Shots_Repeat_Timer, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					Projectile_Is_Silent[projectile] = true;
					RMR_HomingPerSecond[projectile] = 150.0;
					RMR_RocketOwner[projectile] = client;
					RMR_HasTargeted[projectile] = false;
					RWI_HomeAngle[projectile] = 180.0;
					RWI_LockOnAngle[projectile] = 180.0;
					RMR_RocketVelocity[projectile] = speed;
					RMR_CurrentHomingTarget[projectile] = -1;
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

		float Angles[3];
		GetClientEyeAngles(client, Angles);
		for (int spread = 0; spread < 3; spread++)
		{
			Angles[spread] += GetRandomFloat(-5.0, 5.0);
		}
		EmitSoundToAll(SOUND_WAND_SHOT_AUTOAIM, client, _, 75, _, 0.7, 135);
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 5/*Default wand*/, weapon, "unusual_tesla_flash", Angles);
		CreateTimer(0.1, Homing_Shots_Repeat_Timer, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		Projectile_Is_Silent[projectile] = true;
		RMR_HomingPerSecond[projectile] = 150.0;
		RMR_RocketOwner[projectile] = client;
		RMR_HasTargeted[projectile] = false;
		RWI_HomeAngle[projectile] = 180.0;
		RWI_LockOnAngle[projectile] = 180.0;
		RMR_RocketVelocity[projectile] = speed;
		RMR_CurrentHomingTarget[projectile] = -1;
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

public Action Homing_Shots_Repeat_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidClient(RMR_RocketOwner[entity]))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}

		if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
		{
			if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
			{
				HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
			}
			return Plugin_Continue;
		}
		int Closest = GetClosestTarget(entity, _, _, true);
		if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
		{
			RMR_CurrentHomingTarget[entity] = Closest;
			if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
			{
				if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
				{
					HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
				}
				return Plugin_Continue;
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}	

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
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST); // 2048 is DMG_NOGIB?
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