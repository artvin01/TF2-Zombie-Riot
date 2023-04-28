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

#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
#define SOUND_WAND_SHOT 	"weapons/capper_shoot.wav"
#define SOUND_ZAP "misc/halloween/spell_lightning_ball_impact.wav"

//Level 1 skulls are green, level 2 are orange, level 3 are bright blue.

#define SKULL_MODEL				"models/freak_fortress_2/new_spookmaster/skullrocket.mdl"
#define SKULL_PARTICLE_1		"superrare_burning2"
#define SKULL_PARTICLE_2		"flaregun_crit_red"
#define SKULL_PARTICLE_3		"flaregun_sparkles_blue"
#define SKULL_PROJECTILE_PARTICLE_1	"superrare_burning2"
#define SKULL_PROJECTILE_PARTICLE_2	"raygun_projectile_red"
#define SKULL_PROJECTILE_PARTICLE_3	"raygun_projectile_blue_crit"
#define SKULL_PARTICLE_SUMMON_2 "spell_cast_wheel_red"
#define SKULL_PARTICLE_SUMMON_3 "spell_cast_wheel_blue"
#define SKULL_PARTICLE_EXPLOSION	""
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

Queue Skulls_Queue[MAXPLAYERS+1] = {null, ...};
float Skulls_OrbitAngle[MAXPLAYERS + 1] = { 0.0, ... };

//Stats based on pap level. Uses arrays for simpler code.
//Example: Skulls_ShootDMG[3] = { 100.0, 250.0, 500.0 }; default damage is 100, pap1 is 250, pap2 is 500.
float Skulls_ShootDMG[3] = { 200.0, 400.0, 600.0 };	//Damage dealt by projectiles fired by skulls
float Skulls_ShootVelocity[3] = { 1600.0, 2000.0, 2400.0 };	//Velocity of projectiles fired by skulls
float Skulls_ShootRange[3] = { 350.0, 500.0, 700.0 };	//Max range in which skulls will auto-fire at zombies
float Skulls_ShootFrequency[3] = { 1.5, 1.0, 0.75 };	//Time it takes for skulls to auto-fire
float Skulls_LaunchVel[3] = { 1200.0, 1600.0, 2000.0 };	//Velocity of skulls which get launched
float Skulls_LaunchDMG[3] = { 800.0, 1600.0, 2250.0 };	//Damage of skulls which get launched
int Skulls_ManaCost_M1[3] = { 200, 600, 1200 };	//Mana cost of M1
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
int Skull_Tier[MAXENTITIES + 1] = { 0, ... };
//Launch variables are applied at the moment the skull is launched instead of when the skull is created.
//Again, this is intentional.
float Skull_LaunchDMG[MAXENTITIES + 1] = { 0.0, ... };

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

	if(mana_cost <= Current_Mana[client] && !Skulls_PlayerHasNoSkulls(client))
	{	
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		Queue Skulls = Skulls_Queue[client].Clone();
		
		while (!Skulls.Empty)
		{
			int ent = EntRefToEntIndex(Skulls.Pop());
			
			if (IsValidEdict(ent))
			{
				Skulls_LaunchSkull(ent, weapon, client, tier);
			}
		}
		
		Skulls_Queue[client] = null;
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
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "This attack requires you to summon at least one skull!");
		}
	}
}

public void Skulls_LaunchSkull(int ent, int weapon, int client, int tier)
{
	Address address;
	
	float damage = Skulls_LaunchDMG[tier];
	address = TF2Attrib_GetByDefIndex(weapon, 410);
	if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
			
	float velocity = Skulls_LaunchVel[tier];
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 104);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 475);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
		
	float pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(ent);
	
	//TODO: Spawn a rocket at the skull's location, launch it at the location the player is aiming, play sounds
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
	int mana_cost = Skulls_ManaCost_M2[tier];

	if(mana_cost <= Current_Mana[client])
	{
		int prop = CreateEntityByName("prop_physics_override");
		
		if (IsValidEntity(prop))
		{
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
				
				if (GetVectorDistance(spawnLoc, eyePos, true) >= Pow(200.0, 2.0)) //Constraint logic, borrowed from Dynamic Point Teleport and converted to a for loop
				{
					float constraint = 200.0/GetVectorDistance(spawnLoc, eyePos);
					
					for (int i = 0; i < 3; i++)
					{
						spawnLoc[i] = ((spawnLoc[i] - eyePos[i]) * constraint) + eyePos[i];
					}
				}
				
				SetEntityModel(Drone, SKULL_MODEL);
				
				DispatchKeyValue(Drone, "modelscale", "1.0");
				DispatchKeyValue(Drone, "StartDisabled", "false");
	
				DispatchKeyValue(prop, "Health", "9999999999");
				SetEntProp(prop, Prop_Data, "m_takedamage", 2, 1);
				
				DispatchSpawn(Drone);
				
				AcceptEntityInput(Drone, "Enable");
				
				SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
				SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
				TeleportEntity(prop, spawnLoc, NULL_VECTOR, NULL_VECTOR);
				TeleportEntity(Drone, spawnLoc, NULL_VECTOR, NULL_VECTOR);
				
				Skulls_UpdateFollowerPositions(client);
				
				DispatchKeyValue(Drone, "spawnflags", "1");
				SetEntPropEnt(Drone, Prop_Data, "m_hOwnerEntity", client);
				SetVariantString("!activator");
				AcceptEntityInput(Drone, "SetParent", prop);
				
				SetEntityGravity(prop, 0.0);
				SetEntityGravity(Drone, 0.0);
				SetEntityCollisionGroup(Drone, COLLISION_GROUP_DEBRIS_TRIGGER);
				SetEntityCollisionGroup(prop, COLLISION_GROUP_DEBRIS_TRIGGER);
							
				switch(tier)
				{
					case 0:
					{
						SetEntProp(Drone, Prop_Send, "m_nSkin", 2);
						Skull_AttachParticle(Drone, SKULL_PARTICLE_1, _, "bloodpoint");
						Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_2, 3.0, "bloodpoint");
					}
					case 1:
					{
						SetEntProp(Drone, Prop_Send, "m_nSkin", 0);
						Skull_AttachParticle(Drone, SKULL_PARTICLE_2, _, "bloodpoint");
						Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_2, 3.0, "bloodpoint");
					}
					case 2:
					{
						SetEntProp(Drone, Prop_Send, "m_nSkin", 1);
						Skull_AttachParticle(Drone, SKULL_PARTICLE_3, _, "bloodpoint");
						Skull_AttachParticle(Drone, SKULL_PARTICLE_SUMMON_3, 3.0, "bloodpoint");
					}
				}
				
				EmitSoundToAll(SKULL_SOUND_SUMMON, Drone);
				EmitSoundToClient(client, SKULL_SOUND_SUMMON, Drone);
				
				Skulls_SetVariables(prop, weapon, tier);
				
				//Create queue and apply prethink hook if the queue is null:
				if (Skulls_Queue[client] == null)
				{
					SDKHook(client, SDKHook_PreThink, Skulls_PreThink);
					Skulls_Queue[client] = new Queue();
				}
				
				//Add the newly-summoned skull to the queue:
				Skulls_Queue[client].Push(EntIndexToEntRef(prop));
				//Launch ALL excess skulls if the player has more than the max:
				while (Skulls_Queue[client].Length > Skulls_MaxSkulls[tier])
				{
					int ent = EntRefToEntIndex(Skulls_Queue[client].Pop());
				
					if (IsValidEdict(ent))
					{
						Skulls_LaunchSkull(ent, weapon, client, tier);
					}
				}
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

public void Skulls_SetVariables(int prop, int weapon, int tier)
{
	Address address;
	float damage = Skulls_ShootDMG[tier];
	address = TF2Attrib_GetByDefIndex(weapon, 410);
	if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
			
	float velocity = Skulls_ShootVelocity[tier];
	address = TF2Attrib_GetByDefIndex(weapon, 103);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 104);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
	
	address = TF2Attrib_GetByDefIndex(weapon, 475);
	if(address != Address_Null)
		velocity *= TF2Attrib_GetValue(address);
	
	Skull_ShootDMG[prop] = damage;
	Skull_ShootVelocity[prop] = velocity;
	Skull_ShootRange[prop] = Skulls_ShootRange[tier];
	Skull_ShootFrequency[prop] = Skulls_ShootFrequency[tier];
	Skull_NextShootTime[prop] = GetGameTime() + Skull_ShootFrequency[prop];
	Skull_Tier[prop] = tier;
}

public Action Skulls_PreThink(int client)
{
	if (!IsPlayerAlive(client) || !IsClientInGame(client))
	{
		DeleteAllSkulls(Skulls_Queue[client]);
		return;
	}
	
	if (Skulls_PlayerHasNoSkulls(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Skulls_PreThink);
		return;
	}
	
	Skulls_OrbitAngle[client] += 2.0;
			
	if (Skulls_OrbitAngle[client] > 360.0)
	{
		Skulls_OrbitAngle[client] = 0.0;
	}
	
	Skulls_Management(client);
}

void DeleteAllSkulls(Queue SkullQueue)
{
	while (!SkullQueue.Empty)
	{
		int ent = EntRefToEntIndex(SkullQueue.Pop());
			
		if (IsValidEdict(ent))
		{
			RemoveEntity(ent);
		}
	}
}

public void Skulls_Management(int client)
{
	Skulls_UpdateFollowerPositions(client);
	
	Queue Skulls = Skulls_Queue[client].Clone();
	
	while (!Skulls.Empty)
	{
		int ent = EntRefToEntIndex(Skulls.Pop());
		
		if (IsValidEdict(ent))
		{
			Skull_MoveToTargetPosition(ent, client);
			if (GetGameTime() <= Skull_NextShootTime[ent])
			{
				Skull_AttemptShoot(ent);
			}
		}
	}
}

public void Skull_AttemptShoot(int ent)
{
	int target = Skull_GetClosestTarget(ent);
	if (IsValidEdict(target))
	{
		Skull_AutoFire(ent, target);
	}
}

void Skull_AutoFire(int ent, int target)
{
	//TODO: Put a modified version of Wand_Projectile_Spawn in here which fires directly at the victim
}

public int Skull_GetClosestTarget(int ent)
{
	if (ent < MaxClients + 1 || ent > 2048)
	return -1;
		
	int Closest = -1;
	float ShortestDistance = 9999999.0;
	
	float DroneLoc[3], TargetLoc[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", DroneLoc);
	
	for (int i = MaxClients + 1; i <= MAXENTITIES; i++)
	{
		char entname[255];
		GetEntityClassname(i, entname);
		if (StrContains(entname, "base_boss") != -1) //TODO: This does not filter out friendly AI, figure out how to do that.
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", TargetLoc);
			TargetLoc[2] += 60.0; //Target the center of the body (this won't look right on big zombies but who cares lol)
			
			Handle Trace = TR_TraceRayFilterEx(DroneLoc, TargetLoc, MASK_SHOT, RayType_EndPoint, Skull_DontHitSkulls);
			
			if (!TR_DidHit(Trace))
			{
				float dist = GetVectorDistance(DroneLoc, TargetLoc);
				if (dist < ShortestDistance)
				{
					Closest = i;
					ShortestDistance = dist;
				}
			}
			
			delete Trace;
		}
	}
	
	return Closest;
}

public void Skull_MoveToTargetPosition(int ent, int client)
{
	if (ent < MaxClients + 1 || ent > 2048)
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
	
	float fVecFinal[3], fFinalPos[3], DummyAngles[3];
	GetClientEyeAngles(client, DummyAngles);
	
	AddInFrontOf(Skull_MoveTarget[ent], DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(DroneLoc, fVecFinal, fFinalPos);
	
	GetVectorAngles(fFinalPos, Angles);
	
	GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
	float mult = (GetVectorDistance(DroneLoc, Skull_MoveTarget[ent])/80.0);
	if (mult > 1.0)
	{
		mult = 1.0;
	}
	
	float FinalVelScale = Skull_CurrentSpeed[ent] * mult;
	ScaleVector(Velocity, FinalVelScale);
	
	Angles[0] = 0.0;
	Angles[1] = 0.0;
	Angles[2] = 0.0;
	
	TeleportEntity(ent, NULL_VECTOR, Angles, Velocity);
}

public void Skull_ChangeSpeed(int ent, float mod, float maximum)
{
	if (ent < MaxClients + 1 || ent > 2048)
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
	
	int ringSize = Skulls_Queue[client].Length;
	
	float Spacing = 360.0/float(ringSize);
	int NumSpaced = 0;
	float mult = 1.0;
	float HeightMod = 0.0;
	
	Queue Skulls = Skulls_Queue[client].Clone();
	
	while (!Skulls.Empty)
	{
		int ent = EntRefToEntIndex(Skulls.Pop());
		
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
						
			Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
						
			if (TR_DidHit(trace))
			{
				TR_GetEndPosition(spawnLoc, trace);
			}
						
			delete trace;
						
			if (GetVectorDistance(spawnLoc, eyePos, true) >= Pow(80.0, 2.0)) //Constraint logic, borrowed from Dynamic Point Teleport and converted to a for loop
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
		
	return (Skulls_Queue[client] == null || Skulls_Queue[client].Empty);
}

stock void Skull_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
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

public bool Skull_DontHitSkulls(entity, contentsMask) //Borrowed from Apocalips
{
	if (IsValidClient(entity))
	{
		return false;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (Skulls_Queue[i] != null && !Skulls_PlayerHasNoSkulls(i))
		{
			Queue skulls = Skulls_Queue[i].Clone();
			
			while (!skulls.Empty)
			{
				int ent = EntRefToEntIndex(skulls.Pop());
				
				if (IsValidEdict(ent))
					return false;
			}
		}
	}
	
	return true;
}