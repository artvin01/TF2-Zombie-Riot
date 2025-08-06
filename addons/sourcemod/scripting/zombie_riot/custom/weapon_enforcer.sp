#pragma semicolon 1
#pragma newdecls required

#define ENFORCER_MAX_TARGETS		10
#define ENFORCER_MAX_RANGE		200
#define ENFORCER_MAX_BOUNDS		45.0
#define ENFORCER_WEIGHT_PER_HEALTH	1000	// Every X health is 1 weight level for the enemy
#define ENFORCER_KNOCKBACK		750.0	// Knockback when push level and enemy weight is the same
#define ENFORCER_STUN_RATIO		0.00125	// Knockback converted into stun duration
/*
	1 : light
	2 : medium
	3 : heavy (bosses and giants)
	4 : very heavy (slow enemies)
	5 : extreme heavy (some raids and ememies)
	6 : unused

	999: un-moveable
*/
static int EnemiesHit[ENFORCER_MAX_TARGETS];

public void Weapon_Enforcer_M2_Weight2(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 2, 1.5);
}

public void Weapon_Enforcer_M2_Weight3(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 3, 1.75);
}

public void Weapon_Enforcer_M2_Weight5(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 5, 1.85);
}

public void Weapon_Enforcer_M2_Weight8(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 8, 2.0);
}

public void Weapon_Enforcer_M2_Weight12(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 12, 2.1);
}

public void Weapon_Enforcer_M2_Weight17(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 17, 2.15);
}

public void Weapon_Enforcer_M2_Weight23(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 23, 2.5);
}

public void Weapon_Enforcer_M2_Weight30(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 30, 2.6);
}

// Beyond this is freeplay level
public void Weapon_Enforcer_M2_Weight38(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 38, 2.8);
}

public void Weapon_Enforcer_M2_Weight47(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 47, 3.5);
}

public void Weapon_Enforcer_M2_Weight57(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 57, 4.0);
}

public void Weapon_Enforcer_M2_Weight68(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 68, 4.3);
}

public void Weapon_Enforcer_M2_Weight80(int client, int weapon, bool crit, int slot)
{
	Enforcer_AbilityM2(client, weapon, slot, 80, 5.2);
}

public void WepaonRiotgunFillerM2(int client, int weapon, bool crit, int slot)
{
	//This is so it show up on hud for the m2 ability.
	return;
}
void Enforcer_AbilityM2(int client, int weapon, int slot, int pushLevel, float pushforcemulti, bool IngoreAmmo = false)
{
//	if(IngoreAmmo)
//		SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 3.0);

	float cooldown = Ability_Check_Cooldown(client, slot);
	if(!IngoreAmmo && cooldown > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
	else
	{
		int ammo = i_SemiAutoWeapon_AmmoCount[weapon];
		if(ammo > pushLevel)
			ammo = pushLevel;
		
		if(ammo >= sizeof(EnemiesHit))
			ammo = sizeof(EnemiesHit) - 1;
		
		if(IngoreAmmo)
			ammo = pushLevel;

		static const float hullMin[3] = {-ENFORCER_MAX_BOUNDS, -ENFORCER_MAX_BOUNDS, -ENFORCER_MAX_BOUNDS};
		static const float hullMax[3] = {ENFORCER_MAX_BOUNDS, ENFORCER_MAX_BOUNDS, ENFORCER_MAX_BOUNDS};

		float fPos[3];
		float fAng[3];
		float endPoint[3];
		float fPosForward[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		
		GetAngleVectors(fAng, fPosForward, NULL_VECTOR, NULL_VECTOR);
		
		endPoint[0] = fPos[0] + fPosForward[0] * ENFORCER_MAX_RANGE;
		endPoint[1] = fPos[1] + fPosForward[1] * ENFORCER_MAX_RANGE;
		endPoint[2] = fPos[2] + fPosForward[2] * ENFORCER_MAX_RANGE;

		Zero(EnemiesHit);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		TR_TraceHullFilter(fPos, endPoint, hullMin, hullMax, 1073741824, Enforcer_TraceTargets, client);	// 1073741824 is CONTENTS_LADDER?
		FinishLagCompensation_Base_boss();

		for(int i; i < ammo; i++)
		{
			if(!EnemiesHit[i])
			{
				ammo = i;
				break;
			}
			
			int weight = i_NpcWeight[EnemiesHit[i]];
			if(weight > 5)
				continue;
			
			if(weight < 0)
				weight = 1;
			
			if(HasSpecificBuff(EnemiesHit[i], "Solid Stance"))
				continue;

			float knockback = ENFORCER_KNOCKBACK;
			switch(weight)
			{
				case 0:
				{
					knockback *= 0.75;
				}
				case 2:
				{
					knockback *= 0.65;
				}
				case 3:
				{
					knockback *= 0.55;
				}
				case 4:
				{
					knockback *= 0.35;
				}
				case 5:
				{
					knockback *= 0.25;
				}
			}
			if(IngoreAmmo)
			{
				if(weight <= 1)
				{
					knockback *= 0.75;
				}
			}

			knockback *= pushforcemulti; //here we do math depending on how much extra pushforce they got.

			if(b_thisNpcIsABoss[EnemiesHit[i]])
			{
				knockback *= 0.65; //They take half knockback
			}

			if(knockback < (ENFORCER_KNOCKBACK * pushforcemulti * 0.25))
			{
				knockback = (ENFORCER_KNOCKBACK * pushforcemulti * 0.25);
			}
			
			if(!IngoreAmmo)
				FreezeNpcInTime(EnemiesHit[i], knockback * ENFORCER_STUN_RATIO);
				
			Custom_Knockback(client, EnemiesHit[i], knockback, true, true, true);
		}
		
		if(ammo)
		{
			if(!IngoreAmmo)
				EmitSoundToAll("weapons/shotgun/shotgun_dbl_fire.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
			else
				EmitSoundToAll("weapons/push_impact.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

			if(!IngoreAmmo)
			{
				Client_Shake(client, 0, 35.0, 20.0, 0.8);
				GetAttachment(client, "effect_hand_l", fPos, fAng);
				TE_Particle("mvm_soldier_shockwave", fPos, NULL_VECTOR, fAng, -1, _, _, _, _, _, _, _, _, _, 0.0);
			}

			if(!IngoreAmmo)
			{
				Ability_Apply_Cooldown(client, slot, 20.0);
				i_SemiAutoWeapon_AmmoCount[weapon] -= ammo;
			}
			else
			{
				Ability_Apply_Cooldown(client, slot, 3.0);	
			}

			Rogue_OnAbilityUse(client, weapon);
			ShowClientManualAmmoCount(client, weapon);
		}
		else
		{
			if(!IngoreAmmo)
				ClientCommand(client, "playgamesound items/medshotno1.wav");

			Ability_Apply_Cooldown(client, slot, 0.5);
		}
	}
}

public bool Enforcer_TraceTargets(int entity, int contentsMask, int client)
{
	static char classname[64];
	if(IsValidEntity(entity))
	{
		GetEntityClassname(entity, classname, sizeof(classname));
		if(((b_ThisWasAnNpc[entity] && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
		{
			for(int i; i < sizeof(EnemiesHit); i++)
			{
				if(!EnemiesHit[i])
				{
					EnemiesHit[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}
