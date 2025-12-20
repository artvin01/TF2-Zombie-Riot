#pragma semicolon 1
#pragma newdecls required

static int SSS_overheat[MAXENTITIES]={0, ...};
static float starshooter_hud_delay[MAXPLAYERS];
static float StarShooterCoolDelay[MAXPLAYERS];
static int IsAbilityActive[MAXPLAYERS];

Handle Timer_Starshooter_Management[MAXPLAYERS+1] = {null, ...};

#define COLLISION_DETECTION_MODEL	"models/props_lab/monitor01a.mdl"
#define SOUND_WAND_SHOT_STAR 	"weapons/gauss/fire1.wav"
#define SOUND_ZAP_STAR "ambient/energy/zap1.wav"

void SSS_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_STAR);
	PrecacheSound(SOUND_ZAP_STAR);
	PrecacheModel(COLLISION_DETECTION_MODEL);
	Zero(StarShooterCoolDelay);

}


void Reset_stats_starshooter()
{
	Zero(Timer_Starshooter_Management);
	Zero(starshooter_hud_delay);
	Zero(StarShooterCoolDelay);
}
/*
The damage getting lower after having a higher overheat amount now works properly but i am not quite sure how to make a proper counter to make it tick down,
my current plan was to make it decrease by 1 overheat charge every half a second after the weapon hasn't been used for a full 2 seconds, just idk how to make a timer for that
*/

public void Super_Star_Shooter_Main(int client, int weapon, bool crit, int slot) //stuff that happens when you press m1
{
	Enable_StarShooter(client, weapon);
	Ability_Apply_Cooldown(client, slot, 2.0);
	StarShooterCoolDelay[client] = GetGameTime() + 2.0;
	SSS_overheat[client] += 4;

	float damage = 1000.0;
		
	if(SSS_overheat[client] >= 50)
	{
		damage = 750.0;
	} 
	if(SSS_overheat[client] >= 75)
	{
		damage = 500.0;
	} 
	if(SSS_overheat[client] >= 100)
	{
		damage = 250.0;
	}
			
	if(SSS_overheat[client] > 100)
	{
		SSS_overheat[client] = 100;
	}

	float speed = 1750.0;
	float time = 5000.0/speed;
	
	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	time *= Attributes_Get(weapon, 101, 1.0);
	
	time *= Attributes_Get(weapon, 102, 1.0);
		
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_STAR_SHOOTER, weapon, "powerup_icon_supernova");
	SetEntProp(projectile, Prop_Send, "m_usSolidFlags", 12); 
}


public void Super_Star_Shooter_pap1_Main(int client, int weapon, bool crit, int slot) //stuff that happens when you press m1 at the first pap
{
	Enable_StarShooter(client, weapon);
	Ability_Apply_Cooldown(client, slot, 2.0);
	StarShooterCoolDelay[client] = GetGameTime() + 2.0;
	SSS_overheat[client] += 3;

	float damage = 1000.0;
		
	if(SSS_overheat[client] >= 50)
	{
		damage = 750.0;
	} 
	if(SSS_overheat[client] >= 75)
	{
		damage = 500.0;
	} 
	if(SSS_overheat[client] >= 100)
	{
		damage = 250.0;
	}
			
	if(SSS_overheat[client] > 100)
	{
		SSS_overheat[client] = 100;
	}

	float speed = 1750.0;
	float time = 5000.0/speed;
	
	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	time *= Attributes_Get(weapon, 101, 1.0);
	
	time *= Attributes_Get(weapon, 102, 1.0);
	
	float fPos[3];
	GetClientEyePosition(client, fPos);
	//burningplayer_corpse_rainbow_stars
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_STAR_SHOOTER, weapon, "powerup_icon_supernova");
	SetEntProp(projectile, Prop_Send, "m_usSolidFlags", 12); 
}

public void Star_Shooter_Meteor_shower_ability(int client, int weapon, bool crit, int slot)// ability stuff here
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 45.0);
		ClientCommand(client, "playgamesound weapons/cow_mangler_over_charge_shot.wav");

		//PrintToChatAll("test meteor shower");
		ApplyTempAttrib(weapon, 6, 0.5, 7.5); //applies faster fire rate for the next 7.5 seconds
		ApplyTempAttrib(weapon, 2, 0.6, 7.5); //Nerf damage down as its way too strong otherwise, it already has no cooldown.
		IsAbilityActive[client] = 1; //1 for enabled, 0 for disabled
		SSS_overheat[client] = 0;
		CreateTimer(7.5, Disable_Star_Shooter_Ability, client, TIMER_FLAG_NO_MAPCHANGE);

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

public Action Disable_Star_Shooter_Ability(Handle timer, int client)
{
	IsAbilityActive[client] = 0; //1 for enabled, 0 for disabled
	//PrintToChatAll("Ability disabled");
	return Plugin_Handled;
}


public void SuperStarShooterOnHit(int entity, int target)
{
	if (target > 0)	
	{
		if(IsIn_HitDetectionCooldown(entity,target))
			return;

		Set_HitDetectionCooldown(entity,target, FAR_FUTURE);
		
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
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

		EmitSoundToAll(SOUND_ZAP_STAR, target, SNDCHAN_STATIC, 70, _, 0.7);
		
		f_WandDamage[entity] *= LASER_AOE_DAMAGE_FALLOFF;
		
		if(f_WandDamage[entity] <= 1.0)
		{
			int particle = EntRefToEntIndex(i_WandParticle[entity]);
			//damage so low it doesnt even matter.+
			if(IsValidEntity(particle) && particle != 0)
			{
				RemoveEntity(particle);
			}
			RemoveEntity(entity);
		}
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP_STAR, entity, SNDCHAN_STATIC, 70, _, 0.7);
		RemoveEntity(entity);
	}
}



public void Enable_StarShooter(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Starshooter_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_STAR_SHOOTER) //2
		{
			//Is the weapon it again?
			//Yes?
			delete Timer_Starshooter_Management[client];
			Timer_Starshooter_Management[client] = null;
			DataPack pack;
			Timer_Starshooter_Management[client] = CreateDataTimer(0.1, Timer_Management_StarShooter, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_STAR_SHOOTER) //
	{
		DataPack pack;
		Timer_Starshooter_Management[client] = CreateDataTimer(0.1, Timer_Management_StarShooter, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_StarShooter(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Starshooter_Management[client] = null;
		return Plugin_Stop;
	}	
	Starshooter_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}



public void Starshooter_Cooldown_Logic(int client, int weapon)
{
	//Do your code here :)
	
	if (StarShooterCoolDelay[client] < GetGameTime())
	{
		SSS_overheat[client] -= 4;
		
		if(SSS_overheat[client] < 0)
		{
			SSS_overheat[client] = 0;
		}
	}
	if(starshooter_hud_delay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			PrintHintText(client,"유성 발사기 과열 %i％", SSS_overheat[client]);
			
		}
		starshooter_hud_delay[client] = GetGameTime() + 0.5;
	}

	if(IsAbilityActive[client] == 1) //consantly sets overheat to 0 while ability is active, 1 for enabled, 0 for disabled
	{
		SSS_overheat[client] = 0;
	}
}