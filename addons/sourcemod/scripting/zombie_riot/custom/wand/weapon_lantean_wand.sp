#pragma semicolon 1
#pragma newdecls required

static int lantean_Wand_Drone_Count[MAXPLAYERS+1]={0, ...};
static float fl_hud_timer[MAXPLAYERS+1]={0.0, ...};
static float fl_AimbotTimer[MAXPLAYERS+1]={0.0, ...};

static float fl_lantean_Wand_Drone_Life[MAXENTITIES] = { 0.0, ... };

static int i_drone_targets_penetrated[MAXENTITIES] = { 0, ... };

static char particle_type[MAXPLAYERS + 1][200];

static float f3_Vector_To_Aimbot_To[MAXPLAYERS + 1][3];


static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

static int i_lantean_max_penetration[MAXENTITIES];	//how many npc's the drone will penetrate before commiting die
static float fl_lantean_penetration_dmg_penatly[MAXENTITIES];	
static float fl_lantean_overcharge_dmg_penalty[MAXENTITIES];
static float fl_drone_base_speed[MAXENTITIES];
static float fl_targetshit[MAXENTITIES];	//
static bool b_is_lantean[MAXENTITIES];


#define LANTEAN_MAX_ACTIVE_DRONES 20

static float fl_lantean_drone_life[MAXENTITIES];

#define LANTEEN_PAP_0_PENETRATION 						3
#define LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF 			1.6
#define LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF 	1.8

#define LANTEEN_PAP_1_PENETRATION 						7
#define LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF 			1.5
#define LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF 	1.4

#define LANTEEN_PAP_2_PENETRATION 						17
#define LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF 			1.3
#define LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF 	1.0



public void Weapon_lantean_Wand_ClearAll()
{
	Zero(ability_cooldown);
	Zero(fl_AimbotTimer);
	Zero(fl_hud_timer);
	Zero(fl_lantean_Wand_Drone_Life);
	Zero(fl_lantean_drone_life);
	Zero(fl_targetshit);
	Zero(b_is_lantean);
}

#define LANTEAN_WAND_SHOT_1 	"weapons/physcannon/energy_sing_flyby1.wav"
#define LANTEAN_WAND_SHOT_2 	"weapons/physcannon/energy_sing_flyby2.wav"

void Weapon_lantean_Wand_Map_Precache()
{
	PrecacheSound(LANTEAN_WAND_SHOT_1);
	PrecacheSound(LANTEAN_WAND_SHOT_2);
	Zero(lantean_Wand_Drone_Count);
}

public void Weapon_Lantean_Mouse1(int client, int weapon, bool crit, int slot)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//nuking a drone costs more mana!
	{
		mana_cost *= 2;
	}

	if(mana_cost <= Current_Mana[client])
	{
		int pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		Current_Mana[client] -= mana_cost;
		Mana_Hud_Delay[client] = 0.0;
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		delay_hud[client] = 0.0;

		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
					
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
					
			
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);

		time *= Attributes_Get(weapon, 102, 1.0);

		switch(pap)
		{
			case 0:
			{
				particle_type[client]="flaregun_energyfield_red";
				Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_0_PENETRATION, LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF,
				damage,speed,time);
			}
			case 1:
			{
				particle_type[client]="flaregun_energyfield_blue";
				Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_1_PENETRATION, LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF,
				damage,speed,time);
			}
			case 2:
			{
				particle_type[client]="flaregun_energyfield_blue";
				Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_2_PENETRATION, LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF,
				damage,speed,time);
			}
			default:
			{
				particle_type[client]="flaregun_energyfield_red";
				Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_0_PENETRATION, LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF,
				damage,speed,time);
			}
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

public void Lantean_Reload_Ability(int client, int weapon, bool crit, int slot)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	mana_cost *=2;

	if(mana_cost <= Current_Mana[client])
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 5.0);

			Current_Mana[client] -=mana_cost;

			Set_Drones_Noclip(client);
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

public void Weapon_lantean_Wand_m2(int client, int weapon, bool crit, int slot)
{
	int pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));

	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	switch(pap)
	{
		case 0:
		{
			mana_cost *= 5;
		}
		case 1:
		{
			mana_cost *= 10;
		}
		case 2:
		{
			mana_cost *= 8;
		}
	}

	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	
	{
		mana_cost *=2;
	}
	
	
	if(mana_cost <= Current_Mana[client])
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);

			Current_Mana[client] -= mana_cost;
			Mana_Hud_Delay[client] = 0.0;
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			delay_hud[client] = 0.0;
	
			float damage = 65.0;
			damage *= Attributes_Get(weapon, 410, 1.0);
						
			float speed = 1100.0;
			speed *= Attributes_Get(weapon, 103, 1.0);
			
			speed *= Attributes_Get(weapon, 104, 1.0);
			
			speed *= Attributes_Get(weapon, 475, 1.0);
						
				
			float time = 500.0/speed;
			time *= Attributes_Get(weapon, 101, 1.0);
			
			time *= Attributes_Get(weapon, 102, 1.0);

			switch(pap)
			{
				case 0:
				{
					particle_type[client]="scorchshot_trail_crit_red";
					for(int i=1 ; i<=5 ; i++)
					{
						Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_0_PENETRATION, LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF,
						damage,speed,time);
					}
				}
				case 1:
				{
					particle_type[client]="scorchshot_trail_crit_blue";
					for(int i=1 ; i<=10 ; i++)
					{
						Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_1_PENETRATION, LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF,
						damage,speed,time);
					}
				}
				case 2:
				{
					particle_type[client]="scorchshot_trail_crit_blue";
					for(int i=1 ; i<=10 ; i++)
					{
						Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_2_PENETRATION, LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF,
						damage,speed,time);
					}
				}
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
static void Set_Drones_Noclip(int client)
{
	for (int entity = 0; entity < MAXENTITIES; entity++)
	{
		if(Is_Mine(entity, client))
		{
			b_ProjectileCollideIgnoreWorld[entity] = true;
			SetEntityMoveType(entity, MOVETYPE_NOCLIP);
			CreateTimer(2.5, Remove_Noclip_Timer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
}
static Action Remove_Noclip_Timer(Handle Timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		SetEntityMoveType(entity, MOVETYPE_FLY);
		b_ProjectileCollideIgnoreWorld[entity] = false;
	}
	return Plugin_Stop;
}
static bool Is_Mine(int entity, int client)
{
	if(IsValidEntity(entity))
	{
		if(b_is_lantean[entity])
		{
			int owner = EntRefToEntIndex(i_WandOwner[entity]);
			if(IsValidClient(owner))
			{
				if(owner==client)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}
static void Nuke_Old_Drone(int client)
{
	float lowest = GetGameTime();
	int lowest_id = -1;
	for (int entity = 0; entity < MAXENTITIES; entity++)
	{
		if(Is_Mine(entity, client))
		{
			if(lowest > fl_lantean_drone_life[entity])
			{
				lowest = fl_lantean_drone_life[entity];
				lowest_id = entity;
			}
		}
	}
	if(IsValidEntity(lowest_id))
	{
		lantean_Wand_Drone_Count[client] -= 1;
		if(lantean_Wand_Drone_Count[client] <= 0)
			lantean_Wand_Drone_Count[client] = 0;
		b_is_lantean[lowest_id] = false;
		RemoveEntity(lowest_id);
	}
}


static void Weapon_lantean_Wand(int client, int weapon, int penetration_count, float penetration_dmg_penalty, float overcharge_dmg_penalty,
float damage,
float speed,
float time)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//nuking a drone costs more mana!
	{
		Nuke_Old_Drone(client);
	}
	//sanity check, make sure it despawns eventually if smth goes wrong!
	int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_LANTEAN, weapon, particle_type[client]);

	b_is_lantean[projectile]=true;
	fl_lantean_drone_life[projectile] = GetGameTime();

	fl_targetshit[projectile]=1.0;

	//30 sec, own respawnlogic.
	int particle = EntRefToEntIndex(i_WandParticle[projectile]);
	DataPack pack;
	CreateDataTimer(30.0, Timer_RemoveEntity_CustomProjectileWand_Lanteen, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(projectile));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(client);

//	float GameTimeExtra = GetGameTime() + 0.25;
	//Dont instantly collide for reasons.
	SetEntProp(projectile, Prop_Send, "m_usSolidFlags", 12); 
	SDKHook(projectile, SDKHook_Touch, lantean_Wand_Touch_World);//need collisions all the time!

	fl_drone_base_speed[projectile] = speed;

	lantean_Wand_Drone_Count[client] += 1;
	fl_lantean_Wand_Drone_Life[projectile] = GetGameTime()+time;
	i_drone_targets_penetrated[projectile] = 0;
	i_lantean_max_penetration[projectile] = penetration_count;
	fl_lantean_penetration_dmg_penatly[projectile] = penetration_dmg_penalty;
	fl_lantean_overcharge_dmg_penalty[projectile] = overcharge_dmg_penalty;	

	LanternFindVecToBotTo(client);
	switch(GetRandomInt(1, 2))
	{
		case 1:
		{
			EmitSoundToAll(LANTEAN_WAND_SHOT_1, client, _, 65, _, 0.35, 160);
		}
		case 2:
		{
			EmitSoundToAll(LANTEAN_WAND_SHOT_2, client, _, 65, _, 0.35, 160);
		}
	}

	Lantean_HomingProjectile_TurnToTarget(f3_Vector_To_Aimbot_To[client], projectile);

	DataPack Datapack;
	CreateDataTimer(0.1, Lantean_PerfectHomingShot, Datapack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	Datapack.WriteCell(EntIndexToEntRef(projectile)); //projectile
	Datapack.WriteCell(EntIndexToEntRef(client));		//so rather than a victim, we send the client to use for trace's
}

public Action Timer_RemoveEntity_CustomProjectileWand_Lanteen(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	int clientindex = pack.ReadCell();
	if(IsValidEntity(Projectile))
	{
		lantean_Wand_Drone_Count[clientindex] -= 1;
		if(lantean_Wand_Drone_Count[clientindex] <= 0)
			lantean_Wand_Drone_Count[clientindex] = 0;
		b_is_lantean[Projectile]=false;
		RemoveEntity(Projectile);
	}
	if(IsValidEntity(Particle))
	{
		RemoveEntity(Particle);
	}
	return Plugin_Stop; 
}
public Action lantean_Wand_Touch_World(int entity, int other)
{
	//If it touches world.
	if(other == 0 && !b_ThisEntityIgnoredEntirelyFromAllCollisions[entity])
	{
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(fl_lantean_Wand_Drone_Life[entity] < GetGameTime())
		{
			int particle = EntRefToEntIndex(i_WandParticle[entity]);
			if(IsValidEntity(particle))
			{
				RemoveEntity(particle);
			}
			switch(GetRandomInt(1,4)) 
			{
				case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			}
			b_is_lantean[entity]=false;
			if(owner >= 0)
			{
				lantean_Wand_Drone_Count[owner] -= 1;
				if(lantean_Wand_Drone_Count[owner] <= 0)
					lantean_Wand_Drone_Count[owner] = 0;
			}
			RemoveEntity(entity);
		}
	}
	//Simular to buildings, it can vanish if touching skyboxes or npcs.
	//It doesnt matter in most cases, but in this one, it actually does, so we want to prevent it.
	//cant put this on all projectiles, or else they stop working!
	return Plugin_Handled;

}
public void lantean_Wand_Touch(int entity, int target)
{
	if (target > 0)	
	{
		if(IsIn_HitDetectionCooldown(entity,target))
		{
			return;
		}
		Set_HitDetectionCooldown(entity,target, GetGameTime() + 0.3);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidClient(owner))	
		{
			//Code to do damage position and ragdolls
			static float angles[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			WorldSpaceCenter(target, Entity_Position);

			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			
			i_drone_targets_penetrated[entity]++;
			float Wand_Dmg = f_WandDamage[entity] / fl_targetshit[entity];
			
			float dmg_penalty = 1.0;
			
			if(lantean_Wand_Drone_Count[owner] > 10)	//if drone overcharge kicks in, damage penalty is applied
			{
				dmg_penalty=(lantean_Wand_Drone_Count[owner]/10)*fl_lantean_overcharge_dmg_penalty[entity];
			}
			float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
			SDKHooks_TakeDamage(target, entity, owner, (Wand_Dmg / dmg_penalty), DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
			fl_targetshit[entity] *=fl_lantean_penetration_dmg_penatly[entity];
			
			switch(GetRandomInt(1,5)) 
			{
				case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
				case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
				case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
					
			}
			if(i_drone_targets_penetrated[entity] >= i_lantean_max_penetration[entity])
			{
				b_is_lantean[entity]=false;
				lantean_Wand_Drone_Count[owner] -= 1;
				if(lantean_Wand_Drone_Count[owner] <= 0)
					lantean_Wand_Drone_Count[owner] = 0;
				RemoveEntity(entity);
				if(IsValidEntity(particle))
				{
					RemoveEntity(particle);
				}
			}
		}
	} 
}

public Action Lantean_PerfectHomingShot(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(Client))
	{
		return Plugin_Stop;
	}
	if(!IsValidEntity(Projectile))
	{
		return Plugin_Stop;
	}
	int weapon = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return Plugin_Continue;
	}
	float GameTime = GetGameTime();
	if(fl_lantean_Wand_Drone_Life[Projectile] > GameTime)	//if drone is beyond its lifetime, it loses homing and crashes and burns 
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_LANTEAN)
		{
			if(fl_AimbotTimer[Client] < GameTime)
			{
				if(fl_hud_timer[Client] < GameTime)
				{
					Lantean_Wand_Hud(Client);
					fl_hud_timer[Client] = GameTime + 0.5;
				}
				fl_AimbotTimer[Client] = GameTime + 0.25;

				LanternFindVecToBotTo(Client);
			}
			Lantean_HomingProjectile_TurnToTarget(f3_Vector_To_Aimbot_To[Client], Projectile);
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
static void LanternFindVecToBotTo(int client)
{
	Handle swingTrace;
	float vecSwingForward[3] , vec[3];
			
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, false); //infinite range, and (doesn't)ignore walls!	
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);	
	if(IsValidEnemy(client, target))
	{
		WorldSpaceCenter(target, vec);
	}
	else
	{
		TR_GetEndPosition(vec, swingTrace);
		vec[2]+=50.0;	//a bandaid sollution.
	}
	f3_Vector_To_Aimbot_To[client] = vec;
			
	delete swingTrace;
}
static void Lantean_Wand_Hud(int client)
{
	if(lantean_Wand_Drone_Count[client]<11)
	{
		PrintHintText(client,"Drone Count: %i", lantean_Wand_Drone_Count[client]);
	}
	else
	{
		PrintHintText(client,"Drone Overcharge: %i", lantean_Wand_Drone_Count[client]);
	}
	
}
static void Lantean_HomingProjectile_TurnToTarget(float Vec[3], int Projectile)
{
	float flTargetPos[3];
	flTargetPos = Vec;	//Well this works ig
	flTargetPos[0] += GetRandomFloat(-10.0, 10.0);
	flTargetPos[1] += GetRandomFloat(-10.0, 10.0);
	flTargetPos[2] += GetRandomFloat(-10.0, 10.0);
	float flRocketPos[3];
	GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", flRocketPos);

	float flInitialVelocity[3];
	if(b_IsCustomProjectile[Projectile])
		GetEntPropVector(Projectile, Prop_Data, "m_vInitialVelocity", flInitialVelocity);
	else
		GetEntPropVector(Projectile, Prop_Send, "m_vInitialVelocity", flInitialVelocity);
	float flSpeedInit = GetVectorLength(flInitialVelocity);

	float Ratio = (GetVectorDistance(flTargetPos, flRocketPos))/750.0;

	if(Ratio<1.0)
		Ratio=1.0;
	
	flSpeedInit = fl_drone_base_speed[Projectile]*Ratio;
	
	float flNewVec[3];
	SubtractVectors(flTargetPos, flRocketPos, flNewVec);
	NormalizeVector(flNewVec, flNewVec);
	
	float flAng[3];
	GetVectorAngles(flNewVec, flAng);
	
	ScaleVector(flNewVec, flSpeedInit);
	TeleportEntity(Projectile, NULL_VECTOR, flAng, flNewVec, true);
}


void LeanteanWandCheckDeletion(int entity)
{
	if(b_is_lantean[entity])
	{
		int Owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(IsValidClient(Owner))
		{
			lantean_Wand_Drone_Count[Owner] -= 1;
			if(lantean_Wand_Drone_Count[Owner] <= 0)
				lantean_Wand_Drone_Count[Owner] = 0;
				
			b_is_lantean[entity]=false;
		}
	}
}
