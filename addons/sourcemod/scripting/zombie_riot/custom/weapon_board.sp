#pragma semicolon 1
#pragma newdecls required
//no idea how those work but they are needed from what i see
static int weapon_id[MAXPLAYERS+1]={0, ...};
static int Board_Hits[MAXPLAYERS+1]={0, ...};
static int Board_Level[MAXPLAYERS+1]={0, ...};
static float f_ParryDuration[MAXPLAYERS+1]={0.0, ...};
static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};
static int Board_OutlineModel[MAXPLAYERS+1]={INVALID_ENT_REFERENCE, ...};
static bool Board_Ability_1[MAXPLAYERS+1]; //please forgive me for I have sinned
static float f_BoardReflectCooldown[MAXPLAYERS][MAXENTITIES];
static int ParryCounter[MAXPLAYERS];
static int EnemiesHit[6];

Handle h_TimerWeaponBoardManagement[MAXPLAYERS+1] = {null, ...};
static Handle HealPurgatory_timer[MAXPLAYERS+1];
static float f_WeaponBoardhuddelay[MAXPLAYERS+1]={0.0, ...};

static bool BlockHealEasy[MAXPLAYERS+1];

//this code makes me sad

void WeaponBoard_Precache()
{
	PrecacheSound("weapons/air_burster_explode1.wav");
	Zero(f_ParryDuration);
	Zero2(f_BoardReflectCooldown);
	Zero(HealPurgatory_timer);
	Zero(h_TimerWeaponBoardManagement);
	Zero(f_WeaponBoardhuddelay);
}

void Board_DoSwingTrace(int &enemies_hit_aoe, float &CustomMeleeRange)
{
	enemies_hit_aoe = 3;
	CustomMeleeRange = MELEE_RANGE * 0.65;
}

public void Board_M1_ability(int client, int weapon, int slot)
{
	if (Ability_Check_Cooldown(client, 2) < 1.0)
	{
		Ability_Apply_Cooldown(client, 2, 1.0);
	}
}

public void Board_M1_ability_Spike(int client, int weapon, int slot)
{
	if (Ability_Check_Cooldown(client, 2) < 1.0)
	{
		Ability_Apply_Cooldown(client, 2, 1.0);
	}
}

void Board_EntityCreated(int entity) 
{
	for(int i=1; i<=MaxClients; i++)
	{
		f_BoardReflectCooldown[i][entity] = 0.0;
	}
}

public bool Board_TraceTargets(int entity, int contentsMask, int client)
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

public void PurgKnockback(int victim, int weapon, int client)
{
	static const float hullMin[3] = {-45.0, -45.0, -45.0};
	static const float hullMax[3] = {45.0, 45.0, 45.0};

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
	TR_TraceHullFilter(fPos, endPoint, hullMin, hullMax, 1073741824, Board_TraceTargets, victim);	// 1073741824 is CONTENTS_LADDER?
	FinishLagCompensation_Base_boss();
	
	for(int ammount; ammount < 6; ammount++)
	{
		int weight = i_NpcWeight[EnemiesHit[ammount]];
		if(weight > 5)
			continue;
		
		if(weight < 0)
			weight = 1;
		
		if(HasSpecificBuff(EnemiesHit[ammount], "Solid Stance"))
			continue;

		float knockback = 500.0;
		switch(weight)
		{
			case 0:
			{
				knockback *= 1.25;
			}
			case 1:
			{
				knockback *= 1.1;
			}
			case 2:
			{
				knockback *= 0.75;
			}
			case 3:
			{
				knockback *= 0.35;
			}
			default:
			{
				knockback *= 0.0;
			}
		}
		if(b_thisNpcIsABoss[EnemiesHit[ammount]])
		{
			knockback *= 0.65; //They take half knockback
		}
		FreezeNpcInTime(EnemiesHit[ammount], 0.25);	
		Custom_Knockback(client, EnemiesHit[ammount], knockback, true, true, true);
	}
}

public void Punish(int victim, int weapon, int bool) //AOE parry damage that scales with melee upgrades, im a coding maestro SUPREME
{
	float damage = 107.5;
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= 3.2;
			
	int value = i_ExplosiveProjectileHexArray[victim];
	i_ExplosiveProjectileHexArray[victim] = EP_DEALS_CLUB_DAMAGE;

	float UserLoc[3];
	GetClientAbsOrigin(victim, UserLoc);

	float Range = 250.0;
//	b_LagCompNPC_No_Layers = true;
//	StartLagCompensation_Base_Boss(victim);		
//This is only used when you press m2 and get hurt, using lag comp on this makes no sense.		
	Explode_Logic_Custom(damage, victim, victim, weapon, _, Range, 1.0, _, false, 6,_,_);
//	FinishLagCompensation_Base_boss();

	i_ExplosiveProjectileHexArray[victim] = value;

	EmitSoundToAll("weapons/air_burster_explode1.wav", victim, SNDCHAN_AUTO, 90, _, 1.0);
}

public void SwagMeter(int victim, int weapon, int client) //so that parrying 2 enemies at once doesnt grant more effects
{
	if (Board_Ability_1[victim] == true)
	{
		if(dieingstate[victim] > 0)
			return;

		float MaxHealth = float(SDKCall_GetMaxHealth(victim));
		if (MaxHealth > 2000.0)
		{
			MaxHealth = 2000.0;
		}
		if (Board_Level[victim] == 5)
		{
			HealEntityGlobal(victim, victim, MaxHealth * 0.05, _, 0.5,HEAL_SELFHEAL);
			Board_Ability_1[victim] = false;
		}
		else if(Board_Level[victim] == 4)
		{
			Punish(victim, weapon, true);
			Board_Ability_1[victim] = false;
		}
		else if(Board_Level[victim] == 7)
		{
			PurgKnockback(victim, weapon, client);
			Punish(victim, weapon, true);
			Board_Ability_1[victim] = false;
		}
		else
		{
			return;
		}
	}
	else
	{
		return;
	}

}

public void Board_empower_ability(int client, int weapon, bool crit, int slot) // Base parry mechanic, level 0
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 0;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board ability");

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

public void Board_empower_ability_Spike(int client, int weapon, bool crit, int slot) // Parry for the Spike shield, level 1
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 1;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Spike parry");
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

public void Board_empower_ability_Rookie(int client, int weapon, bool crit, int slot) // Parry for the Rookie Shield, level 3
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 4.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 3;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);
				

		//PrintToChatAll("Rookie Parry");

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

public void Board_empower_ability_Punishment(int client, int weapon, bool crit, int slot) // Parry for the Punishment Shield, level 4
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 4;
		
		Board_Ability_1[client] = true;

		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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

public void Board_empower_ability_Cudgel(int client, int weapon, bool crit, int slot) // Parry for the Cudgel Shield, level 6
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 4.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 6;
		
		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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

public void Board_empower_ability_Purgatory(int client, int weapon, bool crit, int slot) // Parry for the Purgatory shield, level 7
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 5.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 7;
		
		Board_Ability_1[client] = true;

		weapon_id[client] = weapon;
		
		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Leaf parry");

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

public void Board_empower_ability_Limbo(int client, int weapon, bool crit, int slot) // Parry for the Limbo Shield, level 8
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		float Cooldown = 4.0;
		Cooldown = ShieldCutOffCooldown_Board(Cooldown);
		Ability_Apply_Cooldown(client, slot, Cooldown);

		Board_Level[client] = 8;

		weapon_id[client] = weapon;

		OnAbilityUseEffect_Board(client, weapon);

		//PrintToChatAll("Board parry");

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

public Action HealPurgatory(Handle cut_timer, int client)
{
	HealPurgatory_timer[client] = null;
	BlockHealEasy[client] = false;
	return Plugin_Handled;
}

//stuff that gets activated upon taking any damage
public float Player_OnTakeDamage_Board(int victim, float &damage, int attacker, int weapon, float damagePosition[3], int damagetype)
{
	if(!CheckInHud())
	{
		BlockHealEasy[victim] = true;
		delete HealPurgatory_timer[victim];	
	}
	if (!CheckInHud() && f_ParryDuration[victim] > GetGameTime())
	{
		int client = victim;
		if(Board_Level[victim] == 1)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		}
		else if(Board_Level[victim] == 2)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(5.0, HealPurgatory, victim);
			SwagMeter(victim, weapon, client);
		}
		else if(Board_Level[victim] == 3)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		}
		else if(Board_Level[victim] == 4)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
			SwagMeter(victim, weapon, client);
		}
		else if(Board_Level[victim] == 5)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(5.0, HealPurgatory, victim);
			SwagMeter(victim, weapon, client);
		}
		else if(Board_Level[victim] == 6)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
			ApplyStatusEffect(victim, attacker, "Cudgelled", 4.0);
		}
		else if(Board_Level[victim] == 7)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(5.0, HealPurgatory, victim);
			SwagMeter(victim, weapon, client);
		}
		else if(Board_Level[victim] == 8)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
			ApplyStatusEffect(victim, attacker, "Cudgelled", 8.0);
		}
		else if(Board_Level[victim] == 0)
		{
			Board_Hits[victim] += 1;
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		}
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			PlayParrySoundBoard(victim);
			float flPos[3]; // original
			float flAng[3]; // original
			
			GetAttachment(victim, "effect_hand_l", flPos, flAng);
			
			ParticleEffectAt(flPos, "mvm_soldier_shockwave", 0.15);
		}
	
		
		if(f_BoardReflectCooldown[victim][attacker] < GetGameTime())
		{
			ParryCounter[victim] += 1;
			float ParriedDamage = 0.0; //why did I let Lucella's code live like this
			switch (ParryCounter[victim])
			{
				case 1:
				{
					ParriedDamage = 70.0;
				}
				case 2:
				{
					ParriedDamage = 63.0; //90%
				}
				case 3:
				{
					ParriedDamage = 52.5; //this needs to be put down like a sad dog, also 75%
				}
				case 4:
				{
					ParriedDamage = 35.0; //and i dont mean like a dog that lost its leg, 50%
				}
				case 5, 6, 7:
				{
					ParriedDamage = 25.0; //i mean a truly sad dog, one that lost all of its limbs, 35%
				}
				case 8, 9, 10, 11, 12, 13, 14, 15:
				{
					ParriedDamage = 7.0; //10%
				}
				default:
				{
					ParriedDamage = 0.0; //and is actively trying to drink arsenic
				}
			}
			ParriedDamage = CalculateDamageBonus_Board(ParriedDamage, weapon);
			ParriedDamage *= 2.0;
		
			static float angles[3];
			GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			WorldSpaceCenter(attacker, Entity_Position );

			f_BoardReflectCooldown[victim][attacker] = GetGameTime() + 0.1;
			
			float ReflectPosVec[3]; CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);
			DataPack pack = new DataPack();
			pack.WriteCell(EntIndexToEntRef(attacker));
			pack.WriteCell(EntIndexToEntRef(victim));
			pack.WriteCell(EntIndexToEntRef(victim));
			pack.WriteFloat(ParriedDamage);
			pack.WriteCell(DMG_CLUB);
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteFloat(ReflectPosVec[0]);
			pack.WriteFloat(ReflectPosVec[1]);
			pack.WriteFloat(ReflectPosVec[2]);
			pack.WriteFloat(Entity_Position[0]);
			pack.WriteFloat(Entity_Position[1]);
			pack.WriteFloat(Entity_Position[2]);
			pack.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
			RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
		}

		if(!(damagetype & DMG_TRUEDAMAGE))
		{
			if(ParryCounter[victim] <= 1)
			{
				if(b_thisNpcIsARaid[attacker])
				{
					ParryCounter[victim] = 3;
				}
			}
			else if(b_thisNpcIsARaid[attacker] && ParryCounter[victim] != 2)
				ParryCounter[victim] = 999;

			switch (ParryCounter[victim])
			{
				case 1:
				{
					return damage * 0.25;
				}
				case 2:
				{
					if(b_thisNpcIsARaid[attacker])
						ParryCounter[victim] = 999;
					float Cooldown = Ability_Check_Cooldown(client, 2);
					Cooldown += (5.0 * CooldownReductionAmount(client));
					Ability_Apply_Cooldown(client, 2, Cooldown);
					return damage * 0.3;
				}
				case 3:
				{
					return damage * 0.3;
				}
				case 4, 5:
				{
					return damage * 0.4;
				}
				case 6:
				{
					return damage * 0.5;
				}
				default:
				{
					return damage * 0.75;
				}
			}
		}
		return damage;

	}
	else if(Board_Level[victim] == 0) //board
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);

		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;

		return damage * 0.9;
	}
	else if(Board_Level[victim] == 1) //spike
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.9;
	}
	else if(Board_Level[victim] == 2) //leaf
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(5.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 3) //rookie
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 4) //punish
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.85;
	}
	else if(Board_Level[victim] == 5) //ramp
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(5.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.75;
	}
	else if(Board_Level[victim] == 6) //the last one cudgel
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.8;
	}
	else if(Board_Level[victim] == 8) //Limbo
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.8;
	}
	else if(Board_Level[victim] == 7) //Purgatory
	{
		//PrintToChatAll("damage resist");
		if(!CheckInHud())
			HealPurgatory_timer[victim] = CreateTimer(10.0, HealPurgatory, victim);
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage;
		return damage * 0.75;
	}
	else
	{
		return damage;
	}
}


public float Player_OnTakeDamage_Board_Hud(int victim)
{
	if(Board_Level[victim] == 0) //board
	{
		return 0.9;
	}
	else if(Board_Level[victim] == 1) //spike
	{
		return 0.9;
	}
	else if(Board_Level[victim] == 3) //rookie
	{
		return 0.85;
	}
	else if(Board_Level[victim] == 4) //punish
	{
		return 0.85;
	}
	else if(Board_Level[victim] == 6) //cudgel
	{
		return 0.8;
	}	
	else if(Board_Level[victim] == 7) //Purgatory
	{
		return 0.75;
	}
	else if(Board_Level[victim] == 8) //Limbo
	{
		return 0.8;
	}
	else
	{
		return 1.0;
	}
}


public void WeaponBoard_Cooldown_Logic(int client, int weapon)
{
	if(f_WeaponBoardhuddelay[client] < GetGameTime())
	{
		f_WeaponBoardhuddelay[client] = GetGameTime() + 0.5;
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(BlockHealEasy[client] == false)
			{
				PassiveBoardHeal(client);
			}
			
		}
		else
		{
			BlockHealEasy[client] = true;
			delete HealPurgatory_timer[client];
			HealPurgatory_timer[client] = CreateTimer(5.0, HealPurgatory, client);
		}
	}
}
public Action Timer_Management_WeaponBoard(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerWeaponBoardManagement[client] = null;
		return Plugin_Stop;
	}	


	WeaponBoard_Cooldown_Logic(client, weapon);

		
	return Plugin_Continue;
}

public void Enable_WeaponBoard(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWeaponBoardManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOARD)
		{
			delete h_TimerWeaponBoardManagement[client];
			h_TimerWeaponBoardManagement[client] = null;
			DataPack pack;
			h_TimerWeaponBoardManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponBoard, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOARD)
	{
		DataPack pack;
		h_TimerWeaponBoardManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponBoard, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

void OnAbilityUseEffect_Board(int client, int active, int FramesActive = 35)
{
	int WeaponModel;
	WeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);

	if(!IsValidEntity(WeaponModel)) //somehow doesnt exist, aboard!
		return;

	f_ParryDuration[client] = GetGameTime() + 0.7;
	ClientCommand(client, "playgamesound misc/halloween/strongman_fast_whoosh_01.wav");
	
	int ModelIndex = GetEntProp(WeaponModel, Prop_Send, "m_nModelIndex");
	char model[PLATFORM_MAX_PATH];
	ModelIndexToString(ModelIndex, model, PLATFORM_MAX_PATH);

	int Glow = TF2_CreateGlow_White(model, client, f_WeaponSizeOverride[active]);
	SetVariantColor(view_as<int>({255, 255, 255, 200}));
	AcceptEntityInput(Glow, "SetGlowColor");
	//save for deletion when they switch away too fast
	Board_OutlineModel[client] = EntIndexToEntRef(Glow);
	SDKHook(Glow, SDKHook_SetTransmit, BarrackBody_Transmit);
	BarrackOwner[Glow] = client;

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(active));
	pack.WriteCell(EntIndexToEntRef(WeaponModel));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(Glow));
	RequestFrames(RemoveEffectsOffShield_Board, FramesActive, pack); // 60 is 1 sec?

	if (ParryCounter[client] != 0)
	{
		ParryCounter[client] = 0;
	}
//	SetEntPropFloat(WeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[active] * 1.25);
}

void RemoveEffectsOffShield_Board(DataPack pack)
{
	pack.Reset();
	int WeaponEntity = EntRefToEntIndex(pack.ReadCell());
	int WeaponViewEntity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	int GlowEntity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client)) //does the player still exist, if no, aboard
	{
		delete pack;
		return;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	//does my weapon exist
	//does the model for it exist (different form normal tf2 cus zr)
	//is my current weapon different from what i used before
	if(IsValidEntity(WeaponViewEntity) && IsValidEntity(WeaponEntity) && weapon_holding == WeaponEntity)
	{
		SetEntPropFloat(WeaponViewEntity, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[WeaponEntity]);
	}
	if(IsValidEntity(GlowEntity))
	{
		RemoveEntity(GlowEntity);
	}
	
	delete pack;
}

public void Weapon_BoardHolster(int client)
{
	int entity = EntRefToEntIndex(Board_OutlineModel[client]);
	if(entity != INVALID_ENT_REFERENCE)
		RemoveEntity(entity);	
}

void PlayParrySoundBoard(int client)
{
	float wait;
	if (wait < GetGameTime())
	{
		wait == GetGameTime() + 1.5;
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh1.wav");
			}
			case 2:
			{
				ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh2.wav");
			}
			case 3:
			{
				ClientCommand(client, "playgamesound weapons/demo_charge_hit_flesh3.wav");
			}
		}
	}
}

public void PassiveBoardHeal(int client)
{
	if(dieingstate[client] > 0)
		return;

	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	if (MaxHealth > 2000.0)
	{
		MaxHealth = 2000.0;
	}
	switch(Board_Level[client])
	{
		case 1, 4:
		{
			HealEntityGlobal(client, client, MaxHealth * 0.01, _, 0.0,HEAL_SELFHEAL);
		}
		default:
		{
			HealEntityGlobal(client, client, MaxHealth * 0.02, _, 0.0,HEAL_SELFHEAL);
		}
	}
}

float ShieldCutOffCooldown_Board(float CooldownCurrent)
{
//	CooldownCurrent *= 1.0;
	return CooldownCurrent;
	/*
	float attackspeed = Attributes_Get(weapon, 6, 1.0);

	CooldownCurrent *= 0.5;

	CooldownCurrent *= attackspeed;

	if(CooldownCurrent <= 0.7)
	{
		CooldownCurrent = 0.7; //cant get lower then 0.7
	}
	return CooldownCurrent;
	*/
}
float CalculateDamageBonus_Board(float damage, int weapon)
{
	float damageModif = damage;
	damageModif *= Attributes_Get(weapon, 1, 1.0);
	damageModif *= Attributes_Get(weapon, 2, 1.0);
//	damageModif *= Attributes_Get(weapon, 1000, 1.0);
	return damageModif;
}