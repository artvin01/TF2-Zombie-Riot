#pragma semicolon 1
#pragma newdecls required

//no idea how those work but they are needed from what i see
static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];
static int weapon_id[MAXPLAYERS+1]={0, ...};
static int Ark_Hits[MAXPLAYERS+1]={0, ...};

static int Ark_Level[MAXPLAYERS+1]={0, ...};

static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};



#define SOUND_LAPPLAND_SHOT 	"weapons/fx/nearmiss/dragons_fury_nearmiss.wav"
#define SOUND_LAPPLAND_ABILITY 	"items/powerup_pickup_plague.wav"

#define LAPPLAND_SILENCE_DUR_NORMAL 3.0
#define LAPPLAND_SILENCE_DUR_ABILITY 6.0

Handle h_TimerWeaponArkManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_WeaponArkhuddelay[MAXPLAYERS+1]={0.0, ...};


//This shitshow of a weapon is basicly the combination of bad wand/homing wand along with some abilities and a sword

#define LAPPLAND_MAX_HITS_NEEDED 84 //Double the amount because we do double hits.
#define LAPPLAND_AOE_SILENCE_RANGE 200.0
#define LAPPLAND_AOE_SILENCE_RANGE_SQUARED 40000.0
Handle h_TimerLappLandManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static int i_LappLandHitsDone[MAXPLAYERS+1]={0, ...};
static float f_LappLandAbilityActive[MAXPLAYERS+1]={0.0, ...};
static float f_LappLandhuddelay[MAXPLAYERS+1]={0.0, ...};

void Ark_autoaim_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM);
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM_ABILITY);
	PrecacheSound(SOUND_AUTOAIM_IMPACT);
	PrecacheModel(ENERGY_BALL_MODEL);
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheSound(SOUND_LAPPLAND_SHOT);
	PrecacheSound(SOUND_LAPPLAND_ABILITY);
	Zero(f_AniSoundSpam);
	Zero(h_TimerLappLandManagement);
	Zero(i_LappLandHitsDone);
	Zero(f_LappLandAbilityActive);
	Zero(f_LappLandhuddelay);
	Zero(h_TimerWeaponArkManagement);
	Zero(f_WeaponArkhuddelay);
}

void Reset_stats_LappLand_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerLappLandManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerLappLandManagement[client]);
	}	
	h_TimerLappLandManagement[client] = INVALID_HANDLE;
	i_LappLandHitsDone[client] = 0;
}

public void Ark_empower_ability(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Ark_Level[client] = 0;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 6;
				
		ApplyTempAttrib(weapon, 6, 0.75, 3.0);

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");

		//PrintToChatAll("test empower");

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

public void Ark_empower_ability_2(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Ark_Level[client] = 1;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 10;
				

		ApplyTempAttrib(weapon, 6, 0.75, 3.0);
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");

		//PrintToChatAll("test empower");

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

public void Ark_empower_ability_3(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");

		Ark_Level[client] = 2;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 10;
				
				
		ApplyTempAttrib(weapon, 6, 0.75, 3.0);

		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
			
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");
				

		//PrintToChatAll("test empower");

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

public void Ark_attack0(int client, int weapon, bool crit, int slot) // stats for the base version of the weapon
{       
	if(Ark_Hits[client] >= 1)
	{
		Ark_Hits[client] -= 1;
		float damage = 25.0;

		damage *= Attributes_Get(weapon, 2, 1.0);
			
		float speed = 500.0;

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);

		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
	}
}
public void Ark_attack1(int client, int weapon, bool crit, int slot) //first pap version
{
	if(Ark_Hits[client] >= 1)
	{
		Ark_Hits[client] -= 1;
		float damage = 50.0;
			
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
	}
}

public void Ark_attack2(int client, int weapon, bool crit, int slot) //second pap version
{

	if(Ark_Hits[client] >= 1)
	{

		Ark_Hits[client] -= 1;

		float damage = 50.0;
			
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);
			
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
		Ark_Lauch_projectile(client, weapon, true, speed, time, damage);
	}
}


void Ark_Lauch_projectile(int client, int weapon, bool multi, float speed, float time, float damage)
{
	char Particle[36];

	if(multi)
	{	
		float Angles[3];
		GetClientEyeAngles(client, Angles);
		Format(Particle, sizeof(Particle), "%s", "unusual_robot_radioactive2");
		for (int i = 1; i <= 4; i++)
		{
			damage *= 0.25;
			
			for (int spread = 0; spread < 3; spread++)
			{
				Angles[spread] += GetRandomFloat(-5.0, 5.0);
			}
			int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 15/*ark*/, weapon, Particle, Angles);
				
			CreateTimer(0.1, Ark_Homing_Repeat_Timer, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		Format(Particle, sizeof(Particle), "%s", "unusual_robot_radioactive");
		Wand_Projectile_Spawn(client, speed, time, damage, 15/*ark*/, weapon, Particle);
		/*
		CreateTimer(0.1, Ark_Homing_Repeat_Timer, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		RMR_HomingPerSecond[projectile] = 150.0;
		RMR_RocketOwner[projectile] = client;
		RMR_HasTargeted[projectile] = false;
		RWI_HomeAngle[projectile] = 180.0;
		RWI_LockOnAngle[projectile] = 180.0;
		RMR_RocketVelocity[projectile] = speed;
		RMR_CurrentHomingTarget[projectile] = -1;	
		*/	
	}
}
public Action Ark_Homing_Repeat_Timer(Handle timer, int ref)
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

public Action Event_Ark_OnHatTouch(int entity, int other)// code responsible for doing damage to the enemy
{
	int target = Target_Hit_Wand_Detection(entity, other);
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
		//Code to do damage position and ragdolls

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(other, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle) && particle != 0)
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


//stuff that gets activated upon taking damage
public float Player_OnTakeDamage_Ark(int victim, float &damage, int attacker, int weapon, float damagePosition[3])
{
	if (Ability_Check_Cooldown(victim, 2) >= 14.0 && Ability_Check_Cooldown(victim, 2) < 16.0)
	{
		float damage_reflected = damage;
		//PrintToChatAll("parry worked");
		if(Ark_Level[victim] == 2)
		{
			damage_reflected *= 40.0;
			
			if(Ark_Hits[victim] < 20)
			{
				Ark_Hits[victim] = 20;
			}
			Ark_Hits[victim] += 1;
		}
		else if(Ark_Level[victim] == 1)
		{
			damage_reflected *= 15.0;
			
			if(Ark_Hits[victim] < 12)
			{
				Ark_Hits[victim] = 12;

			}
			Ark_Hits[victim] += 1;		
		}
		else
		{
			damage_reflected *= 6.0;
			
			if(Ark_Hits[victim] < 3)
			{
				Ark_Hits[victim] = 3;

			}
			Ark_Hits[victim] += 1;	
		}
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			ClientCommand(victim, "playgamesound weapons/samurai/tf_katana_impact_object_02.wav");
		}
		
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(attacker);
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(victim, "effect_hand_r", flPos, flAng);
		
		int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.15);


	//	TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, flAng, -1, _, _, _, _, _, _, _, _, _, 0.0);
		
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(particler));
		pack.WriteFloat(Entity_Position[0]);
		pack.WriteFloat(Entity_Position[1]);
		pack.WriteFloat(Entity_Position[2]);
		
		RequestFrame(TeleportParticleArk, pack);
	
		
		SDKHooks_TakeDamage(attacker, victim, victim, damage_reflected, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);
		
		return damage * 0.1;
	}
	else 
	{
		 //PrintToChatAll("parry failed");
		return damage;
	}
}



public void Kill_Timer_WeaponArk(int client)
{
	if (h_TimerWeaponArkManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerWeaponArkManagement[client]);
		h_TimerWeaponArkManagement[client] = INVALID_HANDLE;
	}
}




public void WeaponArk_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ARK) //Double check to see if its good or bad :(
		{	
			if(f_WeaponArkhuddelay[client] < GetGameTime())
			{
				f_WeaponArkhuddelay[client] = GetGameTime() + 0.5;
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					PrintHintText(client, "Ark Energy [%d]", Ark_Hits[client]);
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
				}
			}
		}
		else
		{
			Kill_Timer_WeaponArk(client);
		}
	}
	else
	{
		Kill_Timer_WeaponArk(client);
	}
}
public Action Timer_Management_WeaponArk(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				WeaponArk_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_WeaponArk(client);
		}
		else
			Kill_Timer_WeaponArk(client);
	}
	else
		Kill_Timer_WeaponArk(client);
		
	return Plugin_Continue;
}

public void Enable_WeaponArk(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWeaponArkManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ARK)
		{
			KillTimer(h_TimerWeaponArkManagement[client]);
			h_TimerWeaponArkManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerWeaponArkManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponArk, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ARK)
	{
		DataPack pack;
		h_TimerWeaponArkManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponArk, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}





void TeleportParticleArk(DataPack pack)
{
	pack.Reset();
	int particleEntity = EntRefToEntIndex(pack.ReadCell());
	float Vec_Pos[3];
	Vec_Pos[0] = pack.ReadFloat();
	Vec_Pos[1] = pack.ReadFloat();
	Vec_Pos[2] = pack.ReadFloat();
	
	if(IsValidEntity(particleEntity))
	{
		TeleportEntity(particleEntity, Vec_Pos);
	}
	delete pack;
}



public bool Weapon_ark_LappLand_Attack_InAbility(int client) //second pap version
{
	if(f_LappLandAbilityActive[client] < GetGameTime())
	{
		return false;
	}
	return true;
}
void Weapon_ark_LapplandRangedAttack(int client, int weapon)
{
	//woopsies!
	//no need for lag comp, we are already in one.
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	
	EmitSoundToAll(SOUND_LAPPLAND_SHOT, client, _, 75, _, 0.55, GetRandomInt(90, 110));

	float damage = 65.0;
	damage *= 0.6; //Reduction
	if(f_LappLandAbilityActive[client] > GetGameTime())
	{
		damage *= 2.0;
	}
			
	float speed = 1100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	if(IsValidEnemy(client, target))
	{
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LAPPLAND, weapon, "manmelter_projectile_trail");
		

		if(Can_I_See_Enemy_Only(target,projectile)) //Insta home!
		{
			HomingProjectile_TurnToTarget(target, projectile);
		}

		DataPack pack;
		CreateDataTimer(0.1, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(projectile)); //projectile
		pack.WriteCell(EntIndexToEntRef(target));		//victim to annihilate :)
		//We have found a victim.
	}
	else
	{
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LAPPLAND, weapon, "manmelter_projectile_trail");
		//no enemy, fire projectile blindly!, maybe itll hit an enemy!
	}
}

public void Melee_LapplandArkTouch(int entity, int target)
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

		if(f_LappLandAbilityActive[owner] < GetGameTime())
		{
			NpcStats_SilenceEnemy(target, LAPPLAND_SILENCE_DUR_NORMAL);
			i_LappLandHitsDone[owner] += 1;
			if(i_LappLandHitsDone[owner] >= LAPPLAND_MAX_HITS_NEEDED) //We do not go above this, no double charge.
			{
				float flPos[3]; // original
				float flAng[3]; // original
				EmitSoundToAll(SOUND_LAPPLAND_ABILITY, owner, _, 90, _, 1.0);
				GetAttachment(owner, "effect_hand_r", flPos, flAng);				
				int particle_Hand = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 20.0);
				SetParent(owner, particle_Hand, "effect_hand_r");
				Weapon_Ark_SilenceAOE(target); //lag comp or not, doesnt matter.
				i_LappLandHitsDone[owner] = 0;
				
				MakePlayerGiveResponseVoice(owner, 1); //haha!
				f_LappLandAbilityActive[owner] = GetGameTime() + 20.0;
				f_WandDamage[entity] *= 2.0;
			}
		}
		else
		{
			Weapon_Ark_SilenceAOE(target); //lag comp or not, doesnt matter.
		}

		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
		
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
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
	}
}

public Action PerfectHomingShot(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Target = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile) && IsValidEntity(Target))
	{
		if(!b_NpcHasDied[Target])
		{
			if(Can_I_See_Enemy_Only(Target,Projectile))
			{
				HomingProjectile_TurnToTarget(Target, Projectile);
			}
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Stop;
}

void HomingProjectile_TurnToTarget(int enemy, int Projectile)
{
	float flTargetPos[3];
	flTargetPos = WorldSpaceCenter(enemy);
	float flRocketPos[3];
	GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", flRocketPos);

	float flInitialVelocity[3];
	GetEntPropVector(Projectile, Prop_Send, "m_vInitialVelocity", flInitialVelocity);
	float flSpeedInit = GetVectorLength(flInitialVelocity);
	
	//flTargetPos[2] += 50.0;
	//flTargetPos[2] += 1 + Pow(GetVectorDistance(flTargetPos, flRocketPos), 2.0) / 10000;
	
	float flNewVec[3];
	SubtractVectors(flTargetPos, flRocketPos, flNewVec);
	NormalizeVector(flNewVec, flNewVec);
	
	float flAng[3];
	GetVectorAngles(flNewVec, flAng);
	
	ScaleVector(flNewVec, flSpeedInit);
	TeleportEntity(Projectile, NULL_VECTOR, flAng, flNewVec, true);
}

public void Enable_LappLand(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerLappLandManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LAPPLAND)
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerLappLandManagement[client]);
			h_TimerLappLandManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_LappLand, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LAPPLAND)
	{
		DataPack pack;
		h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_LappLand, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public void Kill_Timer_LappLand(int client)
{
	if (h_TimerLappLandManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerLappLandManagement[client]);
		h_TimerLappLandManagement[client] = INVALID_HANDLE;
	}
}


public void LappLand_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LAPPLAND) //Double check to see if its good or bad :(
		{	
			if(f_LappLandhuddelay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					if(f_LappLandAbilityActive[client] < GetGameTime())
					{
						PrintHintText(client,"Wolf Spirit [%i%/%i]", i_LappLandHitsDone[client], LAPPLAND_MAX_HITS_NEEDED);
					}
					else
					{
						float TimeLeft = f_LappLandAbilityActive[client] - GetGameTime();
						PrintHintText(client,"Raging Wolf Spirit [%.1f]",TimeLeft);
					}
					
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_LappLandhuddelay[client] = GetGameTime() + 0.5;
				}
			}
		}
		else
		{
			Kill_Timer_LappLand(client);
		}
	}
	else
	{
		Kill_Timer_LappLand(client);
	}
}

public Action Timer_Management_LappLand(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				LappLand_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_LappLand(client);
		}
		else
			Kill_Timer_LappLand(client);
	}
	else
		Kill_Timer_LappLand(client);
		
	return Plugin_Continue;
}

float Npc_OnTakeDamage_LappLand(float damage ,int attacker, int damagetype, int inflictor, int victim)
{
	if(inflictor == attacker) //make sure it doesnt gain things here if the projectile hit.
	{
		if(damagetype & DMG_CLUB) //We only count normal melee hits.
		{
			if(f_LappLandAbilityActive[attacker] < GetGameTime())
			{
				NpcStats_SilenceEnemy(victim, LAPPLAND_SILENCE_DUR_NORMAL);
				i_LappLandHitsDone[attacker] += 2;
				if(i_LappLandHitsDone[attacker] >= LAPPLAND_MAX_HITS_NEEDED) //We do not go above this, no double charge.
				{
					EmitSoundToAll(SOUND_LAPPLAND_ABILITY, attacker, _, 90, _, 1.0);
					float flPos[3]; // original
					float flAng[3]; // original

					GetAttachment(attacker, "effect_hand_r", flPos, flAng);				
					int particle_Hand = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 20.0);
					SetParent(attacker, particle_Hand, "effect_hand_r");

					i_LappLandHitsDone[attacker] = 0;
					f_LappLandAbilityActive[attacker] = GetGameTime() + 20.0;
					MakePlayerGiveResponseVoice(attacker, 1); //haha!
					Weapon_Ark_SilenceAOE(victim); //lag comp or not, doesnt matter.
					damage *= 2.0; //2x dmg
				}
			}
			else
			{
				Weapon_Ark_SilenceAOE(victim); //lag comp or not, doesnt matter.
				damage *= 2.0; //2x dmg
			}
		}
	}
	return damage;
}

void Weapon_Ark_SilenceAOE(int enemyStruck)
{
	float VictimPos[3];
	float EnemyPos[3];
	GetEntPropVector(enemyStruck, Prop_Data, "m_vecAbsOrigin", VictimPos);
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc; entitycount_again_2++) //Check for npcs
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again_2]);
		if(IsValidEntity(entity))
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EnemyPos);
			if (GetVectorDistance(EnemyPos, VictimPos, true) <= (LAPPLAND_AOE_SILENCE_RANGE_SQUARED))
			{
				NpcStats_SilenceEnemy(entity, LAPPLAND_SILENCE_DUR_ABILITY);
			}
		}
	}
}
