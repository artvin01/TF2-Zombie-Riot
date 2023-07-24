#pragma semicolon 1
#pragma newdecls required

static int Arrows_Ability_Shot[MAXPLAYERS+1]={0, ...};

#define SPLIT_ANGLE_OFFSET 2.0

#define SOUND_ARROW_SHOOT		"weapons/bow_shoot.wav"

public void Weapon_Arrow_Shoot_Map_Precache()
{
	PrecacheSound(SOUND_ARROW_SHOOT);
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
		RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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
			RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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
				RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 50.0;
		Max_Arrows[client] = 10;
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
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		Client_To_Weapon[client] = weapon;
		Arrows_Damage[client] = 50.0;
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

public void Weapon_Shoot_Arrow_Ability_Weakest(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
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
			int Ammo_type = GetEntProp(Client_To_Weapon[client], Prop_Send, "m_iPrimaryAmmoType");
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
						RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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
							RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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
								RequestFrame(See_Projectile_Team, EntIndexToEntRef(Arrow));
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