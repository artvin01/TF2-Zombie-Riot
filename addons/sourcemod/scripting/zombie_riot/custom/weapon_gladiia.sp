#pragma semicolon 1
#pragma newdecls required

#define LASERBEAM_PANZER "cable/rope.vmt"
static Handle HealingTimer[MAXPLAYERS] = {null, ...};
static int ParticleRef[MAXPLAYERS] = {-1, ...};

static Handle WeaponTimer[MAXPLAYERS] = {null, ...};
static int WeaponRef[MAXPLAYERS];
static int WeaponCharge[MAXPLAYERS];
static int EliteLevel[MAXPLAYERS];

void Gladiia_MapStart()
{
	Zero(WeaponCharge);
	PrecacheSound("weapons/grappling_hook_reel_stop.wav");
	PrecacheSound("weapons/grappling_hook_impact_flesh.wav");
	PrecacheSound("weapons/grappling_hook_shoot.wav");
	PrecacheModel(LASERBEAM_PANZER);
}

void Gladiia_Enable(int client, int weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_GLADIIA:
		{
			if (HealingTimer[client] != null)
			{
				delete HealingTimer[client];
			}
			HealingTimer[client] = null;

			HealingTimer[client] = CreateTimer(0.1, Gladiia_TimerHealing, client, TIMER_REPEAT);

			WeaponRef[client] = EntIndexToEntRef(weapon);
			if (WeaponTimer[client] != null)
			{
				delete WeaponTimer[client];
			}
			WeaponTimer[client] = null;

			float value = Attributes_Get(weapon, 868, -1.0);
			
			switch(RoundFloat(value))
			{
				case 0:
				{
					// E1 S1 L7
					WeaponTimer[client] = CreateTimer(1.0, Gladiia_TimerS1L7, client, TIMER_REPEAT);
					EliteLevel[client] = 1;
				}
				case 1:
				{
					// E2 S1 L8
					WeaponTimer[client] = CreateTimer(1.0, Gladiia_TimerS1L8, client, TIMER_REPEAT);
					EliteLevel[client] = 2;
				}
				case 2:
				{
					// E2 S1 L10
					WeaponTimer[client] = CreateTimer(1.0, Gladiia_TimerS1L10, client, TIMER_REPEAT);
					EliteLevel[client] = 2;
				}
				case 3:
				{
					// E2 S1 L10 M3
					WeaponTimer[client] = CreateTimer(1.0, Gladiia_TimerS1L10, client, TIMER_REPEAT);
					EliteLevel[client] = 3;
				}
				default:
				{
					// E0 S1 L4
					WeaponTimer[client] = CreateTimer(1.0, Gladiia_TimerS1L4, client, TIMER_REPEAT);
					EliteLevel[client] = 0;
				}
			}
		}
		default:
		{
			if(Store_IsWeaponFaction(client, weapon, Faction_Seaborn))
			{
				if (HealingTimer[client] != null)
				{
					delete HealingTimer[client];
				}
				HealingTimer[client] = null;

				HealingTimer[client] = CreateTimer(0.1, Gladiia_TimerHealing, client, TIMER_REPEAT);
			}
		}
	}
}

bool Gladiia_HasCharge(int client, int weapon)
{
	return (WeaponTimer[client] && EntRefToEntIndex(WeaponRef[client]) == weapon);
}

void Gladiia_ChargeReduction(int client, int weapon, float time)
{
	if(Gladiia_HasCharge(client, weapon))
	{
		WeaponCharge[client] += Int_CooldownReductionDo(client, RoundToNearest(time));
	}
}

public Action Gladiia_TimerHealing(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		if(!dieingstate[client])
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon != INVALID_ENT_REFERENCE)
			{
				if(Store_IsWeaponFaction(client, weapon, Faction_Seaborn))
				{
					case WEAPON_OCEAN, WEAPON_OCEAN_PAP, WEAPON_SPECTER, WEAPON_GLADIIA, WEAPON_ULPIANUS, WEAPON_SKADI:
					{
						float amount = 0.0;
						int elite = EliteLevel[GetHighestGladiiaClient()];
						switch(elite)
						{
							case 1:
							{
								amount = 0.0015;
							}
							case 2:
							{
								amount = 0.0025;
							}
							case 3:
							{
								amount = 0.0035;
							}
						}

						if(amount)
						{
							ApplyStatusEffect(client, client, "Waterless Training", 0.5);
							int maxhealth = SDKCall_GetMaxHealth(client);
							if(maxhealth > 1000)
								maxhealth = 1000;
							
							if(f_TimeUntillNormalHeal[client] > GetGameTime())
								amount *= 0.25;

							amount *= float(maxhealth);

							HealEntityGlobal(client, client, amount, _, 0.0,HEAL_SELFHEAL);

							if(ParticleRef[client] == -1)
							{
								float pos[3]; WorldSpaceCenter(client, pos);
								pos[2] += 500.0;

								int entity = ParticleEffectAt(pos, "env_rain_128", -1.0);
								if(entity > MaxClients)
								{
									SetParent(client, entity);
									ParticleRef[client] = EntIndexToEntRef(entity);
								}
							}

							return Plugin_Continue;
						}
					}
				}
			}
		}
		
		if(ParticleRef[client] != -1)
		{
			int entity = EntRefToEntIndex(ParticleRef[client]);
			if(entity > MaxClients)
				RemoveEntity(entity);

			ParticleRef[client] = -1;
		}

		return Plugin_Continue;
	}
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
			RemoveEntity(entity);
		
		ParticleRef[client] = -1;
	}

	HealingTimer[client] = null;
	EliteLevel[client] = 0;
	return Plugin_Stop;
}

public Action Gladiia_TimerS1L4(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 24))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 24);
				
				int ValueCD = Int_CooldownReductionDo(client, 12);
				PrintHintText(client, "Parting of the Great Ocean [%d / 2] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	EliteLevel[client] = 0;
	return Plugin_Stop;
}

public Action Gladiia_TimerS1L7(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 20))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 20);
				
				int ValueCD = Int_CooldownReductionDo(client, 10);
				
				PrintHintText(client, "Parting of the Great Ocean [%d / 2] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	EliteLevel[client] = 0;
	return Plugin_Stop;
}

public Action Gladiia_TimerS1L8(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 30))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 30);
				
				int ValueCD = Int_CooldownReductionDo(client, 10);
				PrintHintText(client, "Parting of the Great Ocean [%d / 3] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	EliteLevel[client] = 0;
	return Plugin_Stop;
}

public Action Gladiia_TimerS1L10(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 24))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 24);
				
				int ValueCD = Int_CooldownReductionDo(client, 8);
				
				PrintHintText(client, "Parting of the Great Ocean [%d / 3] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	EliteLevel[client] = 0;
	return Plugin_Stop;
}

void Gladiia_OnTakeDamageEnemy(int victim, int attacker, float &damage)
{
	if(i_NpcWeight[victim] < 4 && EliteLevel[attacker] > 1)
	{
		// When attacking enemies with weight <= 3, deal 136% (+6%) damage
		damage *= 1.36;
	}
}

float Gladiia_OnTakeDamageSelf(int victim, int attacker, float damage, int damagetype)
{
	if(damagetype & DMG_TRUEDAMAGE)
		return damage;

	switch(EliteLevel[victim])
	{
		case 1:
		{
			if(i_BleedType[attacker] == BLEEDTYPE_SEABORN)
				return damage * 0.925;//0.85;
		}
		case 2:
		{
			if(i_BleedType[attacker] == BLEEDTYPE_SEABORN)
				return damage * 0.875;//0.75;
		}
		case 3:
		{
			return damage * 0.85;//0.7;
		}
	}

	return damage;
}

float Gladiia_OnTakeDamageAlly(int victim, int attacker, float damage, int damagetype)
{
	if(EliteLevel[victim])	// Being two fishes are we?
		return damage;
	if(damagetype & DMG_TRUEDAMAGE)
		return damage;

	return Gladiia_OnTakeDamageSelf(GetHighestGladiiaClient(), attacker, damage, damagetype);
}

static int GetHighestGladiiaClient()
{
	int highest;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(EliteLevel[client] > EliteLevel[highest] && TeutonType[client] == TEUTON_NONE)
			highest = client;
	}

	return highest;
}

public void Weapon_Gladiia_M2_S1L4(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 12, 2, 1.5);
}

public void Weapon_Gladiia_M2_S1L7(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 10, 2, 1.8);
}

public void Weapon_Gladiia_M2_S1L8(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 10, 2, 1.9);
}

public void Weapon_Gladiia_M2_S1L10(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 8, 3, 2.1);
}

public void Weapon_Gladiia_M2_S1L10M(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 8, 3, 2.1, true);
}

public void Weapon_Gladiia_M2_S1L20M(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 8, 4, 2.1, true);
}

public void Weapon_Gladiia_M2_S1L30M(int client, int weapon, bool crit, int slot)
{
	PullAbilityM2(client, weapon, slot, 8, 5, 2.1, true);
}

static void PullAbilityM2(int client, int weapon, int slot, int cost, int strength, float damagemulti, bool module = false)
{
	cost = Int_CooldownReductionDo(client, cost);
	if(WeaponCharge[client] < cost && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", float(cost - WeaponCharge[client]));
	}
	else if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
	else
	{
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		Handle swingTrace;
		float vecSwingForward[3];
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 900.0, false, 45.0, false); //better detection due to HULL trace addition.
		int entity = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		FinishLagCompensation_Base_boss();

		if(entity > MaxClients && !b_NpcHasDied[entity])
		{
			int weight = i_NpcWeight[entity];
			if(weight < 0)
				weight = 1;
			
			if(b_thisNpcIsABoss[entity])
				weight++;

			if(b_thisNpcIsARaid[entity])
				weight++;

			int force = strength - weight;
			if(force >= 0)
			{
				if(module)
					SDKHooks_TakeDamage(entity, client, client, 3200.0, DMG_CLUB, weapon);

				FreezeNpcInTime(entity, 0.3 + (force * 0.1));
				Custom_Knockback(client, entity, -1500.0, true, true, true, 0.3 + (force * 0.1));
				
				EmitSoundToAll("weapons/grappling_hook_reel_stop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
			}
			else if(force == -1)
			{
				if(module)
					SDKHooks_TakeDamage(entity, client, client, 280.0, DMG_CLUB, weapon);

				FreezeNpcInTime(entity, 0.2);
				Custom_Knockback(client, entity, -300.0, true, true, true, 0.2);

				EmitSoundToAll("weapons/grappling_hook_reel_stop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
			}
			else if(force == -2)
			{
				if(module)
					SDKHooks_TakeDamage(entity, client, client, 24.0, DMG_CLUB, weapon);

				FreezeNpcInTime(entity, 0.5);

				EmitSoundToAll("weapons/grappling_hook_reel_stop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
			}

			float damage = 65.0 * damagemulti;
			damage *= Attributes_Get(weapon, 2, 1.0);
			
			SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB, weapon);

			EmitSoundToAll("weapons/grappling_hook_impact_flesh.wav", entity, SNDCHAN_STATIC, 80, _, 1.0);
			EmitSoundToAll("weapons/grappling_hook_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

			Ability_Apply_Cooldown(client, slot, 1.0);
			WeaponCharge[client] -= cost;

			Rogue_OnAbilityUse(client, weapon);

			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(ConnectWithBeam(client, entity, 5, 5, 5, 3.0, 3.0, 1.0, LASERBEAM_PANZER)), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			Ability_Apply_Cooldown(client, slot, 0.5);
		}
	}
}

void Gladiia_RangedAttack(int client, int weapon)
{

	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;

	EmitSoundToAll("weapons/breadmonster/throwable/bm_throwable_throw.wav", client, _, 75, _, 0.55, GetRandomInt(90, 110));

	float damage = 65.0;
	
	damage *= Attributes_Get(weapon, 1, 1.0);

	damage *= Attributes_Get(weapon, 2, 1.0);
			
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	float time = 500.0 / speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	
	time *= Attributes_Get(weapon, 102, 1.0);

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_GLADIIA, weapon, "rockettrail_bubbles");

	if(IsValidEnemy(client, target))
	{
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
}

void Gladiia_WandTouch(int entity, int target)
{
	if(target > 0)	
	{
		float vecForward[3], Entity_Position[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", vecForward);
		GetAngleVectors(vecForward, vecForward, NULL_VECTOR, NULL_VECTOR);
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitGameSoundToAll("Underwater.BulletImpact", entity);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitGameSoundToAll("Underwater.BulletImpact", entity);
		RemoveEntity(entity);
	}
}