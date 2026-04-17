#pragma semicolon 1
#pragma newdecls required

static int Arrows_Ability_Shot[MAXPLAYERS+1]={0, ...};

#define SPLIT_ANGLE_OFFSET 2.0

#define SOUND_ARROW_SHOOT		"weapons/bow_shoot.wav"
#define BRICK_MODEL "models/props_debris/concrete_cynderblock001.mdl"

public void Weapon_Arrow_Shoot_Map_Precache()
{
	PrecacheSound(SOUND_ARROW_SHOOT);
	PrecacheModel(BRICK_MODEL);
	PrecacheSound("physics/concrete/rock_impact_hard1.wav");
	PrecacheSound("physics/concrete/rock_impact_hard2.wav");
	PrecacheSound("physics/concrete/rock_impact_hard3.wav");
	PrecacheSound("physics/concrete/rock_impact_hard4.wav");
	PrecacheSound("physics/concrete/rock_impact_hard5.wav");
	PrecacheSound("physics/concrete/rock_impact_hard6.wav");
	PrecacheSound("weapons/slam/throw.wav");
}

public void Weapon_Shoot_Arrow(int client, int weapon, bool crit, int slot)
{
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);

		
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	float Charge_Time = GetGameTime();
	
	Charge_Time -= GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
	
	Charge_Time += 0.6;
	
	if(Charge_Time > 1.0)
		Charge_Time = 1.0;
		
	if(Charge_Time < 0.3)
		Charge_Time = 0.3;
		
	Charge_Time /= 1.0;
	
	damage *= Charge_Time;
	/*
		1 - Bullet
	2 - Rocket
	3 - Pipebomb
	4 - Stickybomb (Stickybomb Launcher)
	5 - Syringe
	6 - Flare
	8 - Huntsman Arrow
	11 - Crusader's Crossbow Bolt
	12 - Cow Mangler Particle
	13 - Righteous Bison Particle
	14 - Stickybomb (Sticky Jumper)
	17 - Loose Cannon
	18 - Rescue Ranger Claw
	19 - Festive Huntsman Arrow
	22 - Festive Jarate
	23 - Festive Crusader's Crossbow Bolt
	24 - Self Aware Beuty Mark
	25 - Mutated Milk
	*/
	float speed = 2600.0;
	speed *= Charge_Time;
	float storedAngle[3];
	float storedAngle_2[3];
	storedAngle = fAng;
	storedAngle_2 = fAng;
	int Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
	if(IsValidEntity(Arrow))
	{
		SetEntityCollisionGroup(Arrow, 27);
		SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);	// Damage
		SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", weapon);
		SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", weapon);
		SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
		fAng[0] = storedAngle[0];
		fAng[1] = fixAngle(storedAngle[1] + SPLIT_ANGLE_OFFSET);
		fAng[2] = storedAngle[2];
		
		Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
		if(IsValidEntity(Arrow))
		{
			SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);	// Damage
			SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", weapon);
			SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", weapon);
			SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
			SetEntityCollisionGroup(Arrow, 27);
			storedAngle_2[0] = storedAngle[0];
			storedAngle_2[1] = fixAngle(storedAngle[1] - SPLIT_ANGLE_OFFSET);
			storedAngle_2[2] = storedAngle[2];
			Arrow = SDKCall_CTFCreateArrow(fPos, storedAngle_2, speed, 0.1, 8, client, client);
			if(IsValidEntity(Arrow))
			{
				SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);	// Damage
				SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", weapon);
				SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", weapon);
				SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
				SetEntityCollisionGroup(Arrow, 27);
			}		
		}
	}
}

static float Arrows_Damage[MAXPLAYERS+1]={0.0, ...};
static int Client_To_Weapon[MAXPLAYERS+1]={0, ...};
static int Max_Arrows[MAXPLAYERS+1]={0, ...};

public void Arrow_Spell_ClearAll()
{
	//Zero(ability_cooldown);
}

public void Weapon_Shoot_Arrow_Ability(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 100.0;
		Max_Arrows[client] = 5;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
			
		Arrows_Ability_Shot[client] = 0;
		CreateTimer(0.1, Timer_Multiple_Arrows, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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

public void Weapon_Shoot_Arrow_Ability_Weaker(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 60.0;
		Max_Arrows[client] = 4;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
			
		Arrows_Ability_Shot[client] = 0;
		CreateTimer(0.1, Timer_Multiple_Arrows, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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

public void Weapon_Shoot_Arrow_Ability_Weakest(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 50.0;
		Max_Arrows[client] = 2;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
			
		Arrows_Ability_Shot[client] = 0;
		CreateTimer(0.1, Timer_Multiple_Arrows, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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

public Action Timer_Multiple_Arrows(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == Client_To_Weapon[client])
		{
			int Ammo_type = GetAmmoType_WeaponPrimary(Client_To_Weapon[client]);
			int Ammo_Currently = GetAmmo(client, Ammo_type);
			if(Ammo_Currently > 1)
			{
				SetEntPropFloat(Client_To_Weapon[client], Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+0.3);
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+0.3);
				SetAmmo(client, Ammo_type, Ammo_Currently-1);
				
				for(int i; i<Ammo_MAX; i++)
				{
					CurrentAmmo[client][i] = GetAmmo(client, i);
				}	
							
				if(Arrows_Ability_Shot[client] < Max_Arrows[client])
				{
					EmitSoundToAll(SOUND_ARROW_SHOOT, client, SNDCHAN_WEAPON, 75, _, 0.8, 100);
					
					Arrows_Ability_Shot[client] += 1;
					float fAng[3], fPos[3];
					GetClientEyeAngles(client, fAng);
					GetClientEyePosition(client, fPos);
					
					/*
						1 - Bullet
					2 - Rocket
					3 - Pipebomb
					4 - Stickybomb (Stickybomb Launcher)
					5 - Syringe
					6 - Flare
					8 - Huntsman Arrow
					11 - Crusader's Crossbow Bolt
					12 - Cow Mangler Particle
					13 - Righteous Bison Particle
					14 - Stickybomb (Sticky Jumper)
					17 - Loose Cannon
					18 - Rescue Ranger Claw
					19 - Festive Huntsman Arrow
					22 - Festive Jarate
					23 - Festive Crusader's Crossbow Bolt
					24 - Self Aware Beuty Mark
					25 - Mutated Milk
					*/
					float speed = 2600.0;
					float storedAngle[3];
					float storedAngle_2[3];
					storedAngle = fAng;
					storedAngle_2 = fAng;
					int Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
					if(IsValidEntity(Arrow))
					{
						
						SetEntityCollisionGroup(Arrow, 27);
						SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
						SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
						SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
						SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
						fAng[0] = storedAngle[0];
						fAng[1] = fixAngle(storedAngle[1] + SPLIT_ANGLE_OFFSET);
						fAng[2] = storedAngle[2];
						
						Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
						if(IsValidEntity(Arrow))
						{
							
							SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
							SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
							SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
							SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
							SetEntityCollisionGroup(Arrow, 27);
							storedAngle_2[0] = storedAngle[0];
							storedAngle_2[1] = fixAngle(storedAngle[1] - SPLIT_ANGLE_OFFSET);
							storedAngle_2[2] = storedAngle[2];
							Arrow = SDKCall_CTFCreateArrow(fPos, storedAngle_2, speed, 0.1, 8, client, client);
							if(IsValidEntity(Arrow))
							{
								
								SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
								SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
								SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
								SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
								SetEntityCollisionGroup(Arrow, 27);
							}		
						}
						
					}
				}
				else
				{
					return Plugin_Stop;
				}
			}
			else
			{
				return Plugin_Stop;
			}
		}
		else
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Weapon_Shoot_Arrow_Crossbow_PAP(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
		int Ammo_Currently = GetAmmo(client, Ammo_type);
		if(Ammo_Currently > 1)
		{
			float WeaponDelay = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if(WeaponDelay < GetGameTime())
			{
				WeaponDelay = GetGameTime();
			}
			float PlayerDelay = GetEntPropFloat(client, Prop_Send, "m_flNextAttack");
			if(PlayerDelay < GetGameTime())
			{
				PlayerDelay = GetGameTime();
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", WeaponDelay+0.8);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", PlayerDelay+0.8);
			SetAmmo(client, Ammo_type, Ammo_Currently-1);
			
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}	
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
			
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		EmitSoundToAll(SOUND_ARROW_SHOOT, client, SNDCHAN_WEAPON, 75, _, 0.8, 100);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 400.0;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
		Max_Arrows[client] = 2;
		
		float speed = 2600.0;
		float fAng[3], fPos[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		int Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
		if(IsValidEntity(Arrow))
		{
			
			SetEntityCollisionGroup(Arrow, 27);
			SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
			SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
			SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
			SetEntProp(Arrow, Prop_Send, "m_bCritical", true);
			SetEntPropFloat(Arrow, Prop_Send, "m_flModelScale", 2.0);
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


public void Weapon_Shoot_Arrow_Crossbow_PAP_1(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
		int Ammo_Currently = GetAmmo(client, Ammo_type);
		if(Ammo_Currently > 1)
		{
			float WeaponDelay = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if(WeaponDelay < GetGameTime())
			{
				WeaponDelay = GetGameTime();
			}
			float PlayerDelay = GetEntPropFloat(client, Prop_Send, "m_flNextAttack");
			if(PlayerDelay < GetGameTime())
			{
				PlayerDelay = GetGameTime();
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", WeaponDelay+0.7);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", PlayerDelay+0.7);
			SetAmmo(client, Ammo_type, Ammo_Currently-1);
			
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}	
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
			
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 13.0);
		EmitSoundToAll(SOUND_ARROW_SHOOT, client, SNDCHAN_WEAPON, 75, _, 0.8, 100);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 500.0;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
		Max_Arrows[client] = 2;
		
		float speed = 2600.0;
		float fAng[3], fPos[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		int Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
		if(IsValidEntity(Arrow))
		{
			
			SetEntityCollisionGroup(Arrow, 27);
			SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
			SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
			SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
			SetEntProp(Arrow, Prop_Send, "m_bCritical", true);
			SetEntPropFloat(Arrow, Prop_Send, "m_flModelScale", 2.0);
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



public void Weapon_Shoot_Arrow_Crossbow_PAP_2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int Ammo_type = GetAmmoType_WeaponPrimary(weapon);
		int Ammo_Currently = GetAmmo(client, Ammo_type);
		if(Ammo_Currently > 1)
		{
			float WeaponDelay = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if(WeaponDelay < GetGameTime())
			{
				WeaponDelay = GetGameTime();
			}
			float PlayerDelay = GetEntPropFloat(client, Prop_Send, "m_flNextAttack");
			if(PlayerDelay < GetGameTime())
			{
				PlayerDelay = GetGameTime();
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", WeaponDelay+0.6);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", PlayerDelay+0.6);
			SetAmmo(client, Ammo_type, Ammo_Currently-1);
			
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}	
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
			
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 10.0);
		EmitSoundToAll(SOUND_ARROW_SHOOT, client, SNDCHAN_WEAPON, 75, _, 0.8, 100);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 700.0;
		Arrows_Damage[client] *= Attributes_Get(weapon, 2, 1.0);
		Max_Arrows[client] = 2;
		
		float speed = 2600.0;
		float fAng[3], fPos[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		int Arrow = SDKCall_CTFCreateArrow(fPos, fAng, speed, 0.1, 8, client, client);
		if(IsValidEntity(Arrow))
		{
			
			SetEntityCollisionGroup(Arrow, 27);
			SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, Arrows_Damage[client], true);	// Damage
			SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", Client_To_Weapon[client]);
			SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", Client_To_Weapon[client]);
			SetEntProp(Arrow, Prop_Send, "m_bCritical", true);
			SetEntPropFloat(Arrow, Prop_Send, "m_flModelScale", 2.0);
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


public void WeaponShootBrick(int client, int weapon, bool crit, int slot)
{
	float damage = 50.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 1, 1.0);
	b_IsABow[weapon] = true;

		
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	EmitSoundToAll("weapons/slam/throw.wav", weapon, SNDCHAN_WEAPON, 80, _, 1.0);

	float speed = 3500.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	int projectile = Wand_Projectile_Spawn(client, speed, 1.0, damage, -1, weapon, "bullet_distortion_trail_tracer");
	ApplyCustomModelToWandProjectile(projectile, "models/props_debris/concrete_cynderblock001.mdl", 0.8, "");
	WandProjectile_ApplyFunctionToEntity(projectile, BrickTouchStart);
}

public void BrickTouchStart(int entity, int target)
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
		static float PositionMe[3];
		WorldSpaceCenter(entity, PositionMe);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
	//	SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, PushforceDamage, Entity_Position);	// 2048 is DMG_NOGIB?
		float speed = 2600.0;
		int Arrow = SDKCall_CTFCreateArrow(PositionMe, angles, speed, 0.1, 8, owner, owner);
		if(IsValidEntity(Arrow))
		{
			if(HasSpecificBuff(owner, "Powered Brick"))
				ApplyStatusEffect(owner, Arrow, "Powered Brick", 9999.0);

			SetEntityCollisionGroup(Arrow, 27);
			SetEntDataFloat(Arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, f_WandDamage[entity], true);	// Damage
		//	SetEntData(Arrow, FindSendPropInfo("CTFProjectile_Arrow", "m_iProjectileType ") -1, 1, true);	// m_bPenetrate
			SetEntPropEnt(Arrow, Prop_Send, "m_hOriginalLauncher", weapon);
			SetEntPropEnt(Arrow, Prop_Send, "m_hLauncher", weapon);
			SetEntProp(Arrow, Prop_Send, "m_bCritical", false);
			SetEntPropFloat(Arrow, Prop_Send, "m_flModelScale", 0.0);
			b_MuteArrowSound[Arrow] = true;
			b_MuteArrowSound[owner] = true;
			b_IsEntityNeverTranmitted[Arrow] = true;
			Update_TransmitState(Arrow);
			SDKCall_StartTouch(Arrow, target);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		PlayBrickSound(entity);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		PlayBrickSound(entity);
		RemoveEntity(entity);
	}
}


void PlayBrickSound(int entity)
{
	switch(GetRandomInt(1,6))
	{
		case 1:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard1.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard2.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard3.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 4:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard4.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 5:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard5.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
		case 6:
		{
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("physics/concrete/rock_impact_hard6.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
		}
	}
}



public float Brick_NPCTakeDamage_Do(int attacker, int inflictor, int victim, float damage, int weapon, int &damagetype)
{
	if(!(damagetype & DMG_CRIT))
	{
		if(HasSpecificBuff(attacker, "Powered Brick") || HasSpecificBuff(inflictor, "Powered Brick"))
		{
			damagetype |= DMG_CRIT;
		}
		return damage;
	}

	//we hit a headshot, what do ?
	ApplyStatusEffect(attacker, attacker, "Powered Brick", 4.0);
	return damage;
}


void StatusEffects_BrickWeapon()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Powered Brick");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "PB");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= (1.0 / 1.25);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}