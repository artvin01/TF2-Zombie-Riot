#pragma semicolon 1
#pragma newdecls required

static int lantean_Wand_Drone_Count[MAXPLAYERS+1]={0, ...};
static float fl_hud_timer[MAXPLAYERS+1]={0.0, ...};
static float fl_AimbotTimer[MAXPLAYERS+1]={0.0, ...};
static float fl_overcharge[MAXENTITIES]={0.0, ...};

static float fl_lantean_Wand_Drone_Life[MAXENTITIES] = { 0.0, ... };
static float fl_lantean_Wand_Drone_HitSafe[MAXENTITIES][MAXENTITIES];

static int i_drone_targets_penetrated[MAXENTITIES] = { 0, ... };

static char particle_type[MAXPLAYERS + 1][200];

static float f3_Vector_To_Aimbot_To[MAXPLAYERS + 1][3];


static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

static int i_lantean_max_penetration[MAXENTITIES];	//how many npc's the drone will penetrate before commiting die
static float fl_lantean_penetration_dmg_penatly[MAXENTITIES];	
static float fl_lantean_overcharge_dmg_penalty[MAXENTITIES];	


#define LANTEAN_MAX_ACTIVE_DRONES 20

#define LANTEEN_PAP_0_PENETRATION 						3
#define LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF 			1.3
#define LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF 	1.8

#define LANTEEN_PAP_1_PENETRATION 						7
#define LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF 			1.2
#define LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF 	1.4

#define LANTEEN_PAP_2_PENETRATION 						17
#define LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF 			1.0
#define LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF 	1.0



public void Weapon_lantean_Wand_ClearAll()
{
	Zero(ability_cooldown);
	Zero(fl_AimbotTimer);
	Zero(fl_hud_timer);
	Zero(fl_lantean_Wand_Drone_Life);
	Zero(fl_overcharge);
	Zero2(fl_lantean_Wand_Drone_HitSafe);
}

#define LANTEAN_WAND_SHOT_1 	"weapons/physcannon/energy_sing_flyby1.wav"
#define LANTEAN_WAND_SHOT_2 	"weapons/physcannon/energy_sing_flyby2.wav"

void Weapon_lantean_Wand_Map_Precache()
{
	PrecacheSound(LANTEAN_WAND_SHOT_1);
	PrecacheSound(LANTEAN_WAND_SHOT_2);
	Zero(lantean_Wand_Drone_Count);
}
/*
public void Reset_Stats_Lantean_Weapon(int client)
{

}
*/
public void Weapon_lantean_Wand_m1(int client, int weapon, bool crit, int slot)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{	
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
		if(mana_cost <= Current_Mana[client])
		{
			particle_type[client]="flaregun_energyfield_red";
			Current_Mana[client] -= mana_cost;
			Mana_Hud_Delay[client] = 0.0;
			Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
			Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_0_PENETRATION, LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF,
			damage,speed,time);
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

public void Weapon_lantean_Wand_pap_m1(int client, int weapon, bool crit, int slot)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{	
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
			
		if(mana_cost <= Current_Mana[client])
		{
			particle_type[client]="flaregun_energyfield_blue";
			Current_Mana[client] -= mana_cost;
			Mana_Hud_Delay[client] = 0.0;
			Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
			Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_1_PENETRATION, LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF,
			damage,speed,time);
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

public void Weapon_lantean_Wand_pap2_m1(int client, int weapon, bool crit, int slot)
{
	
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{			
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
			
		if(mana_cost <= Current_Mana[client])
		{
			particle_type[client]="flaregun_energyfield_blue";
			Current_Mana[client] -= mana_cost;
			Mana_Hud_Delay[client] = 0.0;
			Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
			Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_2_PENETRATION, LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF,
			damage,speed,time);
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

public void Weapon_lantean_Wand_m2(int client, int weapon, bool crit, int slot)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{	
		
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
		
		mana_cost *= 7;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 30.0);
		
				particle_type[client]="scorchshot_trail_crit_red";
				Current_Mana[client] -= mana_cost;
				Mana_Hud_Delay[client] = 0.0;
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
				for(int i=1 ; i<=5 ; i++)
				{
					Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_0_PENETRATION, LANTEEN_PAP_0_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_0_PENETRATION_OVERCHARGE_FALLFOFF,
					damage,speed,time);
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

public void Weapon_lantean_Wand_pap_m2(int client, int weapon, bool crit, int slot)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{		
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
		
		mana_cost *= 12;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 30.0);
		
				particle_type[client]="scorchshot_trail_crit_blue";
				Current_Mana[client] -= mana_cost;
				Mana_Hud_Delay[client] = 0.0;
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
				for(int i=1 ; i<=10 ; i++)
				{
					Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_1_PENETRATION, LANTEEN_PAP_1_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_1_PENETRATION_OVERCHARGE_FALLFOFF,
					damage,speed,time);
				
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

public void Weapon_lantean_Wand_pap_3_m2(int client, int weapon, bool crit, int slot)
{
	if(lantean_Wand_Drone_Count[client]>=LANTEAN_MAX_ACTIVE_DRONES)	//block if drone count too high due to people being too stupid and just holding m1...
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Too Many Drones");
	}
	else
	{			
		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
		
		mana_cost *= 12;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 30.0);
		
				particle_type[client]="scorchshot_trail_crit_blue";
				Current_Mana[client] -= mana_cost;
				Mana_Hud_Delay[client] = 0.0;
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
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
	
				for(int i=1 ; i<=10 ; i++)
				{
					Weapon_lantean_Wand(client, weapon, LANTEEN_PAP_2_PENETRATION, LANTEEN_PAP_2_PENETRATION_DMG_FALLFOFF, LANTEEN_PAP_2_PENETRATION_OVERCHARGE_FALLFOFF,
					damage,speed,time);
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


static void Weapon_lantean_Wand(int client, int weapon, int penetration_count, float penetration_dmg_penalty, float overcharge_dmg_penalty,
float damage,
float speed,
float time)
{
	//sanity check, make sure it despawns eventually if smth goes wrong!
	int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_LANTEAN, weapon, particle_type[client]);


	//30 sec, own respawnlogic.
	int particle = EntRefToEntIndex(i_WandParticle[projectile]);
	DataPack pack;
	CreateDataTimer(30.0, Timer_RemoveEntity_CustomProjectileWand_Lanteen, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(projectile));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(client);

	float GameTimeExtra = GetGameTime() + 0.25;
	//Dont instantly collide for reasons.
	for (int entity = 0; entity < MAXENTITIES; entity++)
	{
		fl_lantean_Wand_Drone_HitSafe[projectile][entity] = GameTimeExtra;
	}
	SetEntityCollisionGroup(projectile, 1); //Do not collide.
	//		SetEntProp(projectile, Prop_Send, "m_nSolidType",(FSOLID_TRIGGER | FSOLID_NOT_SOLID));//FSOLID_TRIGGER && FSOLID_NOT_SOLID
	SDKUnhook(projectile, SDKHook_StartTouch, Wand_Base_StartTouch);
	SDKHook(projectile, SDKHook_Touch, lantean_Wand_Touch_World);//need collisions all the time!

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
			RemoveEntity(entity);
			lantean_Wand_Drone_Count[owner] -= 1;
		}
	}
	//Simular to buildings, it can vanish if touching skyboxes or npcs.
	//It doesnt matter in most cases, but in this one, it actually does, so we want to prevent it.
	//cant put this on all projectiles, or else they stop working!
	return Plugin_Handled;

}
public void lantean_Wand_Touch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		if(fl_lantean_Wand_Drone_HitSafe[entity][target] > GetGameTime())
		{
			return;
		}
		fl_lantean_Wand_Drone_HitSafe[entity][target] = GetGameTime() + 0.3;

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
			Entity_Position = WorldSpaceCenter(target);

			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			
			i_drone_targets_penetrated[entity]++;
			
			float dmg_penalty = 1.0;
			
			if(lantean_Wand_Drone_Count[owner] > 10)	//if drone overcharge kicks in, damage penalty is applied
			{
				dmg_penalty=(lantean_Wand_Drone_Count[owner]/10)*fl_lantean_overcharge_dmg_penalty[entity];
			}
			
			SDKHooks_TakeDamage(target, entity, owner, (f_WandDamage[entity]/(i_drone_targets_penetrated[entity]*fl_lantean_penetration_dmg_penatly[entity]))/dmg_penalty, DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
			
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
				RemoveEntity(entity);
				lantean_Wand_Drone_Count[owner] -= 1;
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
	if(fl_lantean_Wand_Drone_Life[Projectile] > GetGameTime())	//if drone is beyond its lifetime, it loses homing and crashes and burns 
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_LANTEAN)
		{
			if(fl_AimbotTimer[Client] < GetGameTime())
			{
				if(fl_hud_timer[Client] < GetGameTime())
				{
					Lantean_Wand_Hud(Client);
					fl_hud_timer[Client] = GetGameTime() + 0.5;
				}
				fl_AimbotTimer[Client] = GetGameTime() + 0.25;

				LanternFindVecToBotTo(Client);
			}
			if(fl_overcharge[Projectile] < GetGameTime())
			{
				if(lantean_Wand_Drone_Count[Client]>10)
				{
					fl_overcharge[Projectile] = GetGameTime() + lantean_Wand_Drone_Count[Client] / 10.0 - 1.0;	//if drones are over 10, the homing update becomes delayed making them harder to control/hopefuly less resource intensive
				}

				Lantean_HomingProjectile_TurnToTarget(f3_Vector_To_Aimbot_To[Client], Projectile);
			}
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
		vec = WorldSpaceCenter(target);
	}
	else
	{
		TR_GetEndPosition(vec, swingTrace);
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
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
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
	GetEntPropVector(Projectile, Prop_Send, "m_vInitialVelocity", flInitialVelocity);
	float flSpeedInit = GetVectorLength(flInitialVelocity);
	
	
	float flNewVec[3];
	SubtractVectors(flTargetPos, flRocketPos, flNewVec);
	NormalizeVector(flNewVec, flNewVec);
	
	float flAng[3];
	GetVectorAngles(flNewVec, flAng);
	
	ScaleVector(flNewVec, flSpeedInit);
	TeleportEntity(Projectile, NULL_VECTOR, flAng, flNewVec, true);
}