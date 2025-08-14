//Weapon description:
//
//	- M2 summons a skull, which orbits the player and automatically fires at nearby zombies. 5s cooldown.
//	- M1 launches ALL skulls at the user's cursor. The skulls explode on impact for a decent chunk of damage each.
//	- Swings EXTREMELY slowly, which gives M1 a heavy cooldown.
//	- Using M2 while already at the max number of skulls will launch the oldest skull.
//	- Can be pack-a-punched twice to increase the maximum number of skulls summoned at a time, the rate-of-fire, damage, and range of each skull,
//		the damage dealt by launched skulls, and swing speed.
//
//	This style allows the Staff of the Skull Servants to alternate between a rapid, more consistent flow of weaker single-target damage
//	from all of the skulls auto-firing, and a slower, more powerful burst of massive crowd damage by launching all of your skulls at once.
//	Each mode has their strengths and weaknesses. The M2 allows the user to consistently dish out damage, but robs them of autonomy because they
//	cannot control the skulls. The m2 allows them to regain their autonomy, at the cost of harming their damage output severely for several seconds.

//NOTE: I used the default wand as a base, but most of this is custom-coded. I used the stocks where I could, but I didn't end up using them much.

#pragma semicolon 1
#pragma newdecls required

//Level 1 skulls are green, level 2 are orange, level 3 are bright blue.

#define SKULL_MODEL				"models/props_mvm/mvm_human_skull_collide.mdl"//"models/freak_fortress_2/new_spookmaster/skullrocket.mdl"
#define SKULL_PARTICLE_1		"superrare_burning2"
#define SKULL_PARTICLE_2		"superrare_burning1"
#define SKULL_PARTICLE_3		"drg_cow_rockettrail_normal_blue"
#define SKULL_PROJECTILE_PARTICLE_1	"superrare_burning2"
#define SKULL_PROJECTILE_PARTICLE_2	"raygun_projectile_red"
#define SKULL_PROJECTILE_PARTICLE_3	"raygun_projectile_blue_crit"
#define SKULL_PARTICLE_SUMMON_2 "spell_cast_wheel_red"
#define SKULL_PARTICLE_SUMMON_3 "spell_cast_wheel_blue"
#define SKULL_PARTICLE_EXPLOSION	"merasmus_dazed_explosion"
#define SKULL_SOUND_SUMMON		"misc/halloween/spell_teleport.wav"
#define SKULL_SOUND_SHOOT_1		"weapons/flaregun_shoot.wav"
#define SKULL_SOUND_SHOOT_2		"weapons/doom_flare_gun.wav"
#define SKULL_SOUND_SHOOT_3		"weapons/doom_flare_gun_crit.wav"
#define SKULL_SOUND_LAUNCH		"misc/halloween/spell_blast_jump.wav"
#define SKULL_SOUND_LAUNCH_LAUGH_1	"items/halloween/witch01.wav"
#define SKULL_SOUND_LAUNCH_LAUGH_2	"items/halloween/witch02.wav"
#define SKULL_SOUND_LAUNCH_LAUGH_3	"items/halloween/witch03.wav"
#define SKULL_SOUND_EXPLODE		"misc/halloween/spell_meteor_impact.wav"
#define SKULL_SOUND_EXPLODE_BONES		"misc/halloween/skeleton_break.wav"
#define SOUND_SKULL_IMPACT	"weapons/flare_detonator_explode_world.wav"
#define SKULL_PARTICLE_IMPACT	"spell_skeleton_goop_green"

ArrayList Skulls_ArrayStack[MAXPLAYERS+1] = {null, ...};
float Skulls_OrbitAngle[MAXPLAYERS + 1] = { 0.0, ... };

//Stats based on pap level. Uses arrays for simpler code.
//Example: Skulls_ShootDMG[3] = { 100.0, 250.0, 500.0 }; default damage is 100, pap1 is 250, pap2 is 500.
float Skulls_ShootDMG[3] = { 350.0, 750.0, 1300.0 };	//Damage dealt by projectiles fired by skulls
float Skulls_ShootVelocity[3] = { 950.0, 1100.0, 1300.0 };	//Velocity of projectiles fired by skulls
float Skulls_ShootRange[3] = { 600.0, 600.0, 700.0 };	//Max range in which skulls will auto-fire at zombies
float Skulls_ShootFrequency[3] = { 1.35, 1.2, 1.1 };	//Time it takes for skulls to auto-fire
float Skulls_LaunchVel[3] = { 1000.0, 1200.0, 1600.0 };	//Velocity of skulls which get launched
float Skulls_LaunchDMG[3] = { 600.0, 2250.0, 3000.0 };	//Damage of skulls which get launched
float Skulls_Lifespan[3] = { 20.0, 30.0, 40.0 };	//Time until skulls automatically launch themselves
float Skulls_ShootPenaltyPerSkull[3] = { 0.0, 0.1, 0.08 };
int Skulls_ManaCost_M1[3] = { 100, 300, 600 };	//Mana cost of M1
int Skulls_ManaCost_M2[3] = { 50, 150, 300 };	//Mana cost of M2
//I contemplated adding a mana cost to the skulls' auto-fire. Decided against it.
int Skulls_MaxSkulls[3] = { 2, 3, 4 };	//Max skulls summoned at once

//The attributes of a skull are applied when it is summoned, and are not modified afterwards. 
//If you have a tier 1 skull, and you pack-a-punch the staff, that skull does NOT get upgrades to a tier 2 skull. It stays tier 1.
//This is intentional, and these variables hold the attributes for each skull.
float Skull_ShootDMG[MAXENTITIES + 1] = { 0.0, ... };
float Skull_ShootVelocity[MAXENTITIES + 1] = { 0.0, ... };
float Skull_ShootRange[MAXENTITIES + 1] = { 0.0, ... };
float Skull_ShootFrequency[MAXENTITIES + 1] = { 0.0, ... };
float Skull_NextShootTime[MAXENTITIES + 1] = { 0.0, ... };
float Skull_CurrentSpeed[MAXENTITIES + 1] = { 0.0, ... };
float Skull_MoveTarget[MAXENTITIES + 1][3];
float Skull_LifetimeEnd[MAXENTITIES + 1] = { 0.0, ... };
int Skull_Tier[MAXENTITIES + 1] = { 0, ... };
int Skull_Weapon[MAXENTITIES + 1] = { -1, ... };
//Launch variables are applied at the moment the skull is launched instead of when the skull is created.
//Again, this is intentional.
float Skull_LaunchDMG[MAXENTITIES + 1] = { 0.0, ... };
float SkullFloatDelay[MAXENTITIES + 1] = { 0.0, ... };

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

void Wand_Skulls_Precache()
{
	PrecacheModel(SKULL_MODEL);
	PrecacheSound(SKULL_SOUND_SUMMON);
	PrecacheSound(SKULL_SOUND_SHOOT_1);
	PrecacheSound(SKULL_SOUND_SHOOT_2);
	PrecacheSound(SKULL_SOUND_SHOOT_3);
	PrecacheSound(SKULL_SOUND_LAUNCH);
	PrecacheSound(SKULL_SOUND_LAUNCH_LAUGH_1);
	PrecacheSound(SKULL_SOUND_LAUNCH_LAUGH_2);
	PrecacheSound(SKULL_SOUND_LAUNCH_LAUGH_3);
	PrecacheSound(SKULL_SOUND_EXPLODE);
	PrecacheSound(SKULL_SOUND_EXPLODE_BONES);
	PrecacheSound(SOUND_SKULL_IMPACT);
}
public void Reset_stats_Skullswand_Singular(int client)
{
	if (Skulls_ArrayStack[client] != null)
	{
		DeleteAllSkulls(client);
	}
}
public void Skulls_EntityDestroyed(int ent)
{
	if (!IsValidEdict(ent))
		return;
		
	Skull_ShootDMG[ent] = 0.0;
	Skull_ShootVelocity[ent] = 0.0;
	Skull_ShootRange[ent] = 0.0;
	Skull_ShootFrequency[ent] = 0.0;
	Skull_NextShootTime[ent] = 0.0;
	Skull_CurrentSpeed[ent] = 0.0;
	Skull_MoveTarget[ent] = NULL_VECTOR;
	Skull_Tier[ent] = 0;
	Skull_LaunchDMG[ent] = 0.0;
	Skull_Weapon[ent] = -1;
}

public void Wand_Skull_Summon_ClearAll()
{
	Zero(SkullFloatDelay);
	Zero(ability_cooldown);
}

public void Skulls_PlayerKilled(int client)
{
	if (Skulls_ArrayStack[client] != null)
	{
		DeleteAllSkulls(client);
	}
}

//Launches all summoned skulls towards your cursor.
public void Weapon_Skulls_M1(int client, int weapon, bool crit)
{
	Skulls_LaunchAll(client, weapon, crit, 0);
}
public void Weapon_Skulls_M1_Pap1(int client, int weapon, bool crit)
{
	Skulls_LaunchAll(client, weapon, crit, 1);
}
public void Weapon_Skulls_M1_Pap2(int client, int weapon, bool crit)
{
	Skulls_LaunchAll(client, weapon, crit, 2);
}

public void Skulls_LaunchAll(int client, int weapon, bool crit, int tier)
{
	int mana_cost = Skulls_ManaCost_M1[tier];
	mana_cost = RoundToNearest(float(mana_cost) * Attributes_Get(weapon, 733, 1.0));
	Skull_Tier[client] = tier;
	
	if (Ability_Check_Cooldown(client, 1) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 1);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	if(mana_cost <= Current_Mana[client] && !Skulls_PlayerHasNoSkulls(client))
	{	
		Ability_Apply_Cooldown(client, 1, 6.0);
		Rogue_OnAbilityUse(client, weapon);
		SDKhooks_SetManaRegenDelayTime(client, 3.5);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		int length = Skulls_ArrayStack[client].Length;
		for(int a; a < length; a++)
		{
			int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(a));
			
			if (IsValidEdict(ent))
			{
				Skulls_LaunchSkull(ent, weapon, client, tier, true, 0.5);
			}
		}
		
	//	delete Skulls_ArrayStack[client];
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		
		if (mana_cost > Current_Mana[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
		else
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Skull Servant Launch Failure");
		}
	}
}

void Skulls_LaunchSkull(int ent, int weapon, int client, int tier, bool KeepOriginal = false, float damagemulti = 1.0)
{
	float damage = Skulls_LaunchDMG[tier];
	float velocity = Skulls_LaunchVel[tier];
	if(IsValidEntity(weapon))
	{
		damage *= Attributes_Get(weapon, 410, 1.0);
				
		velocity *= Attributes_Get(weapon, 103, 1.0);
		
		velocity *= Attributes_Get(weapon, 104, 1.0);
		
		velocity *= Attributes_Get(weapon, 475, 1.0);
	}
	damage *= damagemulti;
		
	float pos[3], ang[3], TargetLoc[3], DummyAngles[3];
	
	Handle trace = getAimTrace(client);
	TR_GetEndPosition(TargetLoc, trace);
	delete trace;
	
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	GetAngleToPoint(ent, TargetLoc, DummyAngles, ang);
	tier = Skull_Tier[ent];
	weapon = EntRefToEntIndex(Skull_Weapon[ent]);

	NearlSwordAbility npc = view_as<NearlSwordAbility>(ent);

	if(!KeepOriginal)
	{
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);

		RemoveEntity(ent);
	}
	if(!IsValidEntity(weapon))
	{
		return;
	}
	char particle[255];
	
	switch(tier)
	{
		case 0:
		{
			particle = SKULL_PARTICLE_1;
		}
		case 1:
		{
			particle = SKULL_PARTICLE_2;
		}
		case 2:
		{
			particle = SKULL_PARTICLE_3;
		}
	}
	
	int projectile = Wand_Projectile_Spawn(client, velocity, 15.0, damage, 18, weapon, particle, ang);
	
	if (IsValidEdict(projectile))
	{	
		TeleportEntity(projectile, pos, NULL_VECTOR, NULL_VECTOR);
		int ModelApply = ApplyCustomModelToWandProjectile(projectile, SKULL_MODEL, 1.25, "");
		
		switch(tier)
		{
			case 0:
			{
				SetEntityRenderColor(ModelApply, 100, 255, 180, 255);
			}
			case 1:
			{
				SetEntityRenderColor(ModelApply, 255, 140, 70, 255);
			}
			case 2:
			{
				SetEntityRenderColor(ModelApply, 120, 200, 255, 255);
			}
		}
		
		SetEntityRenderFx(ModelApply, RENDERFX_GLOWSHELL);
		
		EmitSoundToAll(SKULL_SOUND_LAUNCH, ModelApply);
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll(SKULL_SOUND_LAUNCH_LAUGH_1, ModelApply);
			}
			case 2:
			{
				EmitSoundToAll(SKULL_SOUND_LAUNCH_LAUGH_2, ModelApply);
			}
			case 3:
			{
				EmitSoundToAll(SKULL_SOUND_LAUNCH_LAUGH_3, ModelApply);
			}
		}
	}
}

public void Weapon_Skulls_M2(int client, int weapon, bool crit)
{
	Skulls_Summon(client, weapon, crit, 0);
}
public void Weapon_Skulls_M2_Pap1(int client, int weapon, bool crit)
{
	Skulls_Summon(client, weapon, crit, 1);
}
public void Weapon_Skulls_M2_Pap2(int client, int weapon, bool crit)
{
	Skulls_Summon(client, weapon, crit, 2);
}

public void Skulls_Summon(int client, int weapon, bool crit, int tier)
{
	if (Ability_Check_Cooldown(client, 2) < 0.0)
	{
		Skull_Tier[client] = tier;
		int mana_cost = Skulls_ManaCost_M2[tier];
		mana_cost = RoundToNearest(float(mana_cost) * Attributes_Get(weapon, 733, 1.0));
	
		if(mana_cost <= Current_Mana[client])
		{
			Rogue_OnAbilityUse(client, weapon);
			int prop = CreateEntityByName("prop_physics_override");
			
			if (IsValidEntity(prop))
			{
				b_EntityIgnoredByShield[prop] = true;
				DispatchKeyValue(prop, "targetname", "droneparent"); 
				DispatchKeyValue(prop, "spawnflags", "4"); 
				DispatchKeyValue(prop, "model", "models/props_c17/canister01a.mdl");
				
				DispatchSpawn(prop);
				
				ActivateEntity(prop);
				
				int Drone = CreateEntityByName("prop_dynamic_override");
				
				if (IsValidEntity(Drone))
				{
					float spawnLoc[3];
					float eyePos[3];
					float eyeAng[3];
					
					GetClientEyePosition(client, eyePos);
					GetClientEyeAngles(client, eyeAng);
					for (int i = 0; i < 3; i++)
					{
						eyeAng[i] += GetRandomFloat(0.0, 360.0);
					}
					
					Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
					
					if (TR_DidHit(trace))
					{
						TR_GetEndPosition(spawnLoc, trace);
					}
					
					delete trace;
					
					if (GetVectorDistance(spawnLoc, eyePos, true) >= (200.0 * 200.0)) //Constraint logic, borrowed from Dynamic Point Teleport and converted to a for loop
					{
						float constraint = 200.0/GetVectorDistance(spawnLoc, eyePos);
						
						for (int i = 0; i < 3; i++)
						{
							spawnLoc[i] = ((spawnLoc[i] - eyePos[i]) * constraint) + eyePos[i];
						}
					}
					
					SetEntityModel(Drone, SKULL_MODEL);
					
					DispatchKeyValue(Drone, "modelscale", "1.25");
					DispatchKeyValue(Drone, "StartDisabled", "false");
		
					DispatchKeyValue(prop, "Health", "9999999999");
					//SetEntProp(prop, Prop_Data, "m_takedamage", 2, 1);
					SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
					
					DispatchSpawn(Drone);
					
					AcceptEntityInput(Drone, "Enable");
					
					SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
					SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
					TeleportEntity(prop, spawnLoc, NULL_VECTOR, NULL_VECTOR);
					TeleportEntity(Drone, spawnLoc, NULL_VECTOR, NULL_VECTOR);
					
					DispatchKeyValue(Drone, "spawnflags", "1");
					SetEntPropEnt(Drone, Prop_Data, "m_hOwnerEntity", client);
					SetVariantString("!activator");
					AcceptEntityInput(Drone, "SetParent", prop);
					
					SetEntityGravity(prop, 0.0);
					SetEntityGravity(Drone, 0.0);
					MakeObjectIntangeable(Drone);
					MakeObjectIntangeable(prop);
								
					switch(tier)
					{
						case 0:
						{
							SetEntityRenderColor(Drone, 100, 255, 180, 255);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_1);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_2, 3.0);
						}
						case 1:
						{
							SetEntityRenderColor(Drone, 255, 140, 70, 255);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_2);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_2, 3.0);
						}
						case 2:
						{
							SetEntityRenderColor(Drone, 120, 200, 255, 255);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_3);
							Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_3, 3.0);
						}
					}
					
					SetEntityRenderFx(Drone, RENDERFX_GLOWSHELL);

					EmitSoundToAll(SKULL_SOUND_SUMMON, Drone);
					EmitSoundToClient(client, SKULL_SOUND_SUMMON, Drone);
					
					Skulls_SetVariables(prop, weapon, tier, client);
					NearlSwordAbility npc = view_as<NearlSwordAbility>(prop);

					int Textentity = WandSkulls_HealthHud(npc);

					i_WandOwner[Textentity] = client;
					
					SDKHook(Textentity, SDKHook_SetTransmit, Skulls_Transmit);
										
					//Create ArrayList and apply prethink hook if the ArrayList is null:
					if (Skulls_ArrayStack[client] == null)
					{
						SDKHook(client, SDKHook_PreThink, Skulls_PreThink);
						Skulls_ArrayStack[client] = new ArrayList();
					}
					
					//Add the newly-summoned skull to the ArrayList:
					Skulls_ArrayStack[client].Push(EntIndexToEntRef(prop));
					//Launch ALL excess skulls if the player has more than the max:
					while (Skulls_ArrayStack[client].Length > Skulls_MaxSkulls[tier])
					{
						//FIXED: It's supposed to launch skulls in order of oldest to newest, this was backwards.
						int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(0));
						Skulls_ArrayStack[client].Erase(0);

						if (IsValidEdict(ent))
						{
							Skulls_LaunchSkull(ent, weapon, client, tier);
						}
					}
					
					Current_Mana[client] -= mana_cost;
					SDKhooks_SetManaRegenDelayTime(client, 2.0);
					Ability_Apply_Cooldown(client, 2, 5.0);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Skull Servant Summoned", Skulls_ArrayStack[client].Length, Skulls_MaxSkulls[tier]);
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
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Skulls_SetVariables(int prop, int weapon, int tier, int client)
{
//	Address address;
	float damage = Skulls_ShootDMG[tier];
	float velocity = Skulls_ShootVelocity[tier];
	
	Skull_ShootDMG[prop] = damage;
	Skull_ShootVelocity[prop] = velocity;
	Skull_ShootRange[prop] = (Skulls_ShootRange[tier] * Skulls_ShootRange[tier]);
	Skull_ShootFrequency[prop] = Skulls_ShootFrequency[tier];
	Skull_Tier[prop] = tier;
	Skull_Weapon[prop] = EntIndexToEntRef(weapon);
	Skull_LifetimeEnd[prop] = GetGameTime() + Skulls_Lifespan[tier];
	Skull_SetNextShootTime(prop);
}

public Action Skulls_PreThink(int client)
{
	if (!IsPlayerAlive(client) || !IsClientInGame(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Skulls_PreThink);
		return Plugin_Continue;
	}
	
	if (Skulls_PlayerHasNoSkulls(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Skulls_PreThink);
		return Plugin_Continue;
	}
	
	Skulls_OrbitAngle[client] += 2.0;
			
	if (Skulls_OrbitAngle[client] > 360.0)
	{
		Skulls_OrbitAngle[client] = 0.0;
	}
	if (SkullFloatDelay[client] < GetGameTime())
	{	
		Skulls_Management(client);
		SkullFloatDelay[client] = GetGameTime() + 0.05; //add a tiny delay, otherwise optentially too much processing.
		ApplyStatusEffect(client, client, "Serving Skulls", 0.1);
	}
	
	return Plugin_Continue;
}

void DeleteAllSkulls(int client)
{
	int length = Skulls_ArrayStack[client].Length;
	for(int a; a < length; a++)
	{
		int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(a));
		
		if (IsValidEdict(ent))
		{
			RemoveEntity(ent);
		}
	}
		
	delete Skulls_ArrayStack[client];
}

public void Skulls_Management(int client)
{
	Skulls_UpdateFollowerPositions(client);
	
	//int length = Skulls_ArrayStack[client].Length;
	for(int a; a < Skulls_ArrayStack[client].Length; a++)
	{
		int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(a));
		
		if (IsValidEdict(ent))
		{
			NearlSwordAbility npc = view_as<NearlSwordAbility>(ent);
			WandSkulls_HealthHud(npc);
			if (!IsValidEntity(EntRefToEntIndex(Skull_Weapon[ent])))	//Make sure the skull has a weapon index associated with it at all times. The index doesn't affect any stats, it's just there so Wand_Projectile_Spawn doesn't freak out when I pass it an invalid weapon. Side-note: support for just not having a weapon index would be great for Wand_Projectile_Spawn.
			{
				int i, weapon;
				while(TF2_GetItem(client, weapon, i))
				{
					if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SKULL_SERVANT)
					{
						Skull_Weapon[ent] = EntIndexToEntRef(weapon);
						break;
					}
				}
			}

			if (GetGameTime() >= Skull_LifetimeEnd[ent])	//Skulls auto-launch themselves after a certain time period. This is to prevent players from buying this wand, getting a bunch of skulls, then selling it but keeping the skulls.
			{
				//FIXED: Auto-launched skulls are supposed to be removed from the list when they launch themselves. The ArrayList change did not do this, so they were still counted as being summoned, blocking new skulls from being summoned.
				Skulls_ArrayStack[client].Erase(a);
				Skulls_LaunchSkull(ent, EntRefToEntIndex(Skull_Weapon[ent]), client, Skull_Tier[ent]);
			}
			else
			{
				Skull_MoveToTargetPosition(ent, client);
				if (GetGameTime() >= Skull_NextShootTime[ent])
				{
					Skull_AttemptShoot(ent, client);
				}
			}
		}
	}
	if(Skulls_ArrayStack[client].Length <= 0)
		DeleteAllSkulls(client);
}

public void Skull_AttemptShoot(int ent, int client)
{
	int target = Skull_GetClosestTarget(ent, Skull_ShootRange[ent]);
	if (IsValidEdict(target))
	{
		Skull_AutoFire(ent, target, client);
	}
}

void Skull_AutoFire(int ent, int target, int client)
{
	float pos[3], ang[3], TargetLoc[3], DummyAngles[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(target, Prop_Send, "m_angRotation", DummyAngles);
	WorldSpaceCenter(target, TargetLoc);


	float dist = GetVectorDistance(pos, TargetLoc, true);
	
	float velocity = Skull_ShootVelocity[ent];
	float damage = Skull_ShootDMG[ent];
	int weapon = EntRefToEntIndex(Skull_Weapon[ent]);
	
	if (IsValidEntity(weapon))
	{
		damage *= Attributes_Get(weapon, 410, 1.0);

		velocity *= Attributes_Get(weapon, 103, 1.0);
		
		velocity *= Attributes_Get(weapon, 104, 1.0);
		
		velocity *= Attributes_Get(weapon, 475, 1.0);
	}

	int weapon1 = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon1) ||i_CustomWeaponEquipLogic[weapon1] != WEAPON_SKULL_SERVANT)
		damage *= 0.35;

	if(dist < (Skull_ShootRange[ent] * 0.5)) //If at half range, try to predict.
	{
		CClotBody npc = view_as<CClotBody>(ent);
		PredictSubjectPositionForProjectiles(npc, target, velocity, _,TargetLoc);
	}

	GetAngleToPoint(ent, TargetLoc, DummyAngles, ang);
	
	char particle[255];
	switch(Skull_Tier[ent])
	{
		case 0:
		{
			particle = SKULL_PROJECTILE_PARTICLE_1;
		}
		case 1:
		{
			particle = SKULL_PROJECTILE_PARTICLE_2;
		}
		case 2:
		{
			particle = SKULL_PROJECTILE_PARTICLE_3;
		}
	}
	
	int NumSkulls = Skulls_ArrayStack[client].Length;
	float penalty = Skulls_ShootPenaltyPerSkull[Skull_Tier[ent]];
	if (penalty != 0.0)
	{
		damage *= 1.0 - (penalty * float(NumSkulls));
	}
	
	int projectile = Wand_Projectile_Spawn(client, velocity, 5.0, damage, 17, weapon, particle, ang);
	
	if (IsValidEdict(projectile))
	{
		TeleportEntity(projectile, pos, NULL_VECTOR, NULL_VECTOR);
		Skull_SetNextShootTime(ent);
		switch(Skull_Tier[ent])
		{
			case 0:
			{
				EmitSoundToClient(client, SKULL_SOUND_SHOOT_1, ent, SNDCHAN_STATIC, 70);
			}
			case 1:
			{
				EmitSoundToClient(client, SKULL_SOUND_SHOOT_2, ent, SNDCHAN_STATIC, 70);
			}
			case 2:
			{
				EmitSoundToClient(client, SKULL_SOUND_SHOOT_3, ent, SNDCHAN_STATIC, 70);
			}
		}
	}
}

void Skull_SetNextShootTime(int ent)
{
	float BuffAmt = 1.0;
	int weapon = EntRefToEntIndex(Skull_Weapon[ent]);
	
	if (IsValidEntity(weapon))
	{
		BuffAmt = Attributes_Get(weapon, 6, 1.0);
	}

	
	Skull_NextShootTime[ent] = (Skull_ShootFrequency[ent] * BuffAmt) + GetGameTime();
}

void GetAngleToPoint(int ent, float TargetLoc[3], float DummyAngles[3], const float Output[3])
{
	float ang[3], pos[3], fVecFinal[3], fFinalPos[3];

	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);		

	AddInFrontOf(TargetLoc, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(pos, fVecFinal, fFinalPos);

	GetVectorAngles(fFinalPos, ang);

	Output = ang;
}

public int Skull_GetClosestTarget(int ent, float range)
{
	if (ent <= MaxClients || ent > 2048)
		return -1;
		
	int Closest = -1;
	float ShortestDistance = 9999999.0;
	
	float DroneLoc[3], TargetLoc[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", DroneLoc);
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	
	if(owner <= 0)
		return -1;
	
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int i = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if (!IsValidEntity(i))
			continue;
			
		if(IsValidEnemy(owner, i, true, false))
		{
			WorldSpaceCenter(i, TargetLoc);
			float dist = GetVectorDistance(DroneLoc, TargetLoc, true);
			if(dist <= range)
			{	
				Handle Trace = TR_TraceRayFilterEx(DroneLoc, TargetLoc, MASK_ALL, RayType_EndPoint, Skull_DontHitSkulls);
					
				if (TR_DidHit(Trace))
				{
					int iHit = TR_GetEntityIndex(Trace);
					if (b_ThisWasAnNpc[iHit] && dist < ShortestDistance)
					{
						Closest = i;
						ShortestDistance = dist;
					}
				}
					
				delete Trace;
			}
		}
	}
	
	return Closest;
}

public void Skull_MoveToTargetPosition(int ent, int client)
{
	if (ent <= MaxClients || ent > 2048)
		return;
	
	if (!IsValidEntity(ent))
		return;
	
	float DroneLoc[3], Velocity[3], Angles[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", DroneLoc);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", Angles);
	 
	for (int vel = 0; vel < 3; vel++)
	{
		Velocity[vel] = 0.0;
	}
	
	float TargetSpeed = 600.0;
	
	Skull_ChangeSpeed(ent, 10.0, TargetSpeed);
	
	float dist = GetVectorDistance(DroneLoc, Skull_MoveTarget[ent]);
	
	float fVecFinal[3], fFinalPos[3], DummyAngles[3];
	GetClientEyeAngles(client, DummyAngles);
		
	AddInFrontOf(Skull_MoveTarget[ent], DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(DroneLoc, fVecFinal, fFinalPos);
		
	GetVectorAngles(fFinalPos, Angles);
		
	GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
	float mult = (dist/80.0);
	if (mult > 1.0)
	{
		mult = 1.0;
	}
		
	float FinalVelScale = Skull_CurrentSpeed[ent] * mult;
	ScaleVector(Velocity, FinalVelScale);
		
	GetClientEyeAngles(client, Angles);
	Angles[0] = 0.0;
		
	TeleportEntity(ent, NULL_VECTOR, Angles, Velocity);
}

public void Skull_ChangeSpeed(int ent, float mod, float maximum)
{
	if (ent <= MaxClients || ent > 2048)
		return;
	
	if (!IsValidEntity(ent))
	return;
	
	if (Skull_CurrentSpeed[ent] > maximum)
	{
		Skull_CurrentSpeed[ent] += -mod;
	}
	else if (Skull_CurrentSpeed[ent] < maximum)
	{
		Skull_CurrentSpeed[ent] += mod;
	}
	
	
	if (Skull_CurrentSpeed[ent] < 0.0)
	{
		Skull_CurrentSpeed[ent] = 0.0;
	}
	
	if (Skull_CurrentSpeed[ent] > maximum)
	{
		Skull_CurrentSpeed[ent] = maximum;
	}
}

public void Skulls_UpdateFollowerPositions(int client)
{
	if (!IsValidMulti(client))
	return;
	
	int ringSize = Skulls_ArrayStack[client].Length;
	
	float Spacing = 360.0/float(ringSize);
	int NumSpaced = 0;
	float mult = 1.0;
	float HeightMod = 0.0;
	
	int length = Skulls_ArrayStack[client].Length;
	for(int a; a < length; a++)
	{
		int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(a));
		
		if (IsValidEdict(ent))
		{
			float spawnLoc[3];
			float eyePos[3];
			float eyeAng[3];
						
			GetClientEyePosition(client, eyePos);
			GetClientEyeAngles(client, eyeAng);
						
			eyePos[2] += HeightMod;
						
			eyeAng[0] = -22.5;
			eyeAng[1] = float(NumSpaced) * Spacing + (mult * Skulls_OrbitAngle[client]);
			eyeAng[2] = 0.0;

			Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, Skull_DontHitSkulls/*TraceEntityFilterPlayer*/);
						
			if (TR_DidHit(trace))
			{
				TR_GetEndPosition(spawnLoc, trace);
				static float hullcheckmaxs_Player[3];
				static float hullcheckmins_Player[3];
				hullcheckmaxs_Player = view_as<float>( { 10.0, 10.0, 10.0 } );
				hullcheckmins_Player = view_as<float>( { -10.0, -10.0, -10.0 } );	
				delete trace;
				trace = TR_TraceHullFilterEx(eyePos, spawnLoc, hullcheckmins_Player, hullcheckmaxs_Player, MASK_SHOT, Skull_DontHitSkulls);
				if (TR_DidHit(trace))
				{
					TR_GetEndPosition(spawnLoc, trace);//gets middle of trace.
				}
			
			}
						
			delete trace;
						
			if (GetVectorDistance(spawnLoc, eyePos, true) >= (80.0 * 80.0)) //Constraint logic, borrowed from Dynamic Point Teleport and converted to a for loop
			{
				float constraint = 80.0/GetVectorDistance(spawnLoc, eyePos);
							
				for (int j = 0; j < 3; j++)
				{
					spawnLoc[j] = ((spawnLoc[j] - eyePos[j]) * constraint) + eyePos[j];
				}
			}
						
			NumSpaced++;
						
			for (int k = 0; k < 3; k++)
			{
				Skull_MoveTarget[ent][k] = spawnLoc[k];
			}
		}
	}
}

//Does the player have no summoned skulls?
bool Skulls_PlayerHasNoSkulls(int client)
{
	if (!IsValidClient(client))
		return true;
		
	return (Skulls_ArrayStack[client] == null || !Skulls_ArrayStack[client].Length);
}

stock void Skull_AttachParticle(int entity, char type[255], float duration = 0.0, float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
		//	SetVariantString(point);
		//	AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

stock void AddInFrontOf(float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutPut[3])
{
	float fVecView[3]; GetViewVector(fVecAngle, fVecView);
	
	fOutPut[0] = fVecView[0] * fUnits + fVecOrigin[0];
	fOutPut[1] = fVecView[1] * fUnits + fVecOrigin[1];
	fOutPut[2] = fVecView[2] * fUnits + fVecOrigin[2];
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

public bool Skull_DontHitSkulls(int entity, int contentsMask) //Borrowed from Apocalips
{
	if (IsValidClient(entity))
	{
		return false;
	}
	
	bool hit = true;
	for (int i = 1; i <= MaxClients && hit; i++)
	{
		if (!Skulls_PlayerHasNoSkulls(i))
		{
			int length = Skulls_ArrayStack[i].Length;
			for(int a; a < length; a++)
			{
				int ent = EntRefToEntIndex(Skulls_ArrayStack[i].Get(a));
				
				if (entity == ent)
				{
					hit = false;
					break;
				}
			}
		}
	}
	
	if (hit && IsValidEntity(entity))
	{
		hit = b_ThisWasAnNpc[entity];
	}
	
	return hit;
}

Handle getAimTrace(int client)
{
	if (!IsValidClient(client))
	{
		return null;
	}
	
	float eyePos[3];
	float eyeAng[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	Handle trace;
	
	trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	return trace;
}

public void Wand_Skulls_Touch(int entity, int target)
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
		//Code to do damage position and ragdolls
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
	
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, SKULL_PARTICLE_IMPACT, 1.0);
		EmitSoundToAll(SOUND_SKULL_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, SKULL_PARTICLE_IMPACT, 1.0);
		EmitSoundToAll(SOUND_SKULL_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
}

public void Wand_Skulls_Touch_Launched(int entity, int target)
{
	if (target > 0)	
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
			
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
		
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, SKULL_PARTICLE_EXPLOSION, 1.0);
		EmitSoundToAll(SKULL_SOUND_EXPLODE, entity, SNDCHAN_STATIC, 80, _, 1.0);
		EmitSoundToAll(SKULL_SOUND_EXPLODE_BONES, entity, SNDCHAN_STATIC, 80, _, 1.0);
		
		Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, position, 280.0, _, _, false);
			
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
			
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
		
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, SKULL_PARTICLE_EXPLOSION, 1.0);
		EmitSoundToAll(SKULL_SOUND_EXPLODE, entity, SNDCHAN_STATIC, 80, _, 1.0);
		EmitSoundToAll(SKULL_SOUND_EXPLODE_BONES, entity, SNDCHAN_STATIC, 80, _, 1.0);
		
		Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, position, 280.0, _, _, false);
			
		RemoveEntity(entity);
	}
}


public int WandSkulls_HealthHud(NearlSwordAbility npc)
{
	char HealthText[32];
	int HealthColour[4];

	int MaxHealth = RoundToCeil((Skulls_Lifespan[Skull_Tier[npc.index]]) * 10.0);
	int Health = RoundToCeil((Skull_LifetimeEnd[npc.index] - GetGameTime()) * 10.0);
	if(Health == 0)
	{
		Health = 1;
	}
	for(int i=0; i<4; i++)
	{
		if(Health >= MaxHealth*(i*0.25))
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, "|");
		}
		else
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ".");
		}
	}

	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[2] = 0;
	if(Health <= MaxHealth)
	{
		HealthColour[0] = Health * 255  / MaxHealth;
		HealthColour[1] = Health * 255  / MaxHealth;
		
		HealthColour[0] = 255 - HealthColour[0];
	}
	else
	{
		HealthColour[0] = 0;
		HealthColour[1] = 0;
		HealthColour[2] = 255;
	}	
	HealthColour[3] = 255;

	if(IsValidEntity(npc.m_iWearable6))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(npc.m_iWearable6,     "color", sColor);
		DispatchKeyValue(npc.m_iWearable6, "message", HealthText);
	}
	else
	{
		int TextEntity = SpawnFormattedWorldText(HealthText,{0.0,0.0,25.0}, 11, HealthColour, npc.index);
	//	SDKHook(TextEntity, SDKHook_SetTransmit, BarrackBody_Transmit);
		DispatchKeyValue(TextEntity, "font", "1");
		npc.m_iWearable6 = TextEntity;	
	}
	return npc.m_iWearable6;
}

public Action Skulls_Transmit(int entity, int client)
{
	if(client == i_WandOwner[entity])
		return Plugin_Continue;
	
	return Plugin_Handled;
}



void StatusEffects_SkullServants()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Serving Skulls");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☠");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.AttackspeedBuff			= -1.0;
	data.HudDisplay_Func 			= Func_SkullsHud;
	StatusEffect_AddGlobal(data);
}

void Func_SkullsHud(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	int length;
	if(Skulls_ArrayStack[victim])
	{
		length = Skulls_ArrayStack[victim].Length;
	}
	Format(HudToDisplay, SizeOfChar,"☠(%i/%i)", length,Skulls_MaxSkulls[Skull_Tier[victim]]);
}