#pragma semicolon 1
#pragma newdecls required

// TODO: enum list of elements instead of each one being it's own variable

enum
{
	Element_Nervous,
	Element_Chaos,
	Element_Cyro,
	Element_Necrosis,
	Element_Void,
	Element_Osmosis,
	Element_Corruption,
	Element_Burger,
	Element_Plasma,

	Element_MAX
}

static const char ElementName[][] =
{
	"AC",
	"CH",
	"CY",
	"NE",
	"VO",
	"OS",
	"CO",
	"FOOD",
	"PL"
};

static float LastTime[MAXENTITIES];
static int LastElement[MAXENTITIES];
static int ElementDamage[MAXENTITIES][Element_MAX];

// OnEntityCreated
void Elemental_ClearDamage(int entity)
{
	LastTime[entity] = 0.0;

	for(int i; i < Element_MAX; i++)
	{
		ElementDamage[entity][i] = 0;
	}
}

stock bool Elemental_HasDamage(int entity, int type = -1)
{
	if(type != -1)
		return view_as<bool>(ElementDamage[entity][type]);
	
	for(int i; i < Element_MAX; i++)
	{
		if(ElementDamage[entity][i])
			return true;
	}
	
	return false;
}

stock bool Elemental_GoingCritical(int entity)
{
	if(entity <= MaxClients)
		return (Armor_Charge[entity] * 5 / 4) < (-MaxArmorCalculation(Armor_Level[entity], entity, 1.0));
	
	for(int i; i < Element_MAX; i++)
	{
		if((ElementDamage[entity][i] * 5 / 4) > TriggerDamage(entity, i))
			return true;
	}
	
	return false;
}

stock void Elemental_RemoveDamage(int entity, int amount)
{
	for(int i; i < Element_MAX; i++)
	{
		if(ElementDamage[entity][i] > 0)
		{
			ElementDamage[entity][i] -= amount;
			if(ElementDamage[entity][i] < 0)
				ElementDamage[entity][i] = 0;
		}
	}
}

static int TriggerDamage(int entity, int type)
{
	if(entity <= MaxClients)
		return MaxArmorCalculation(Armor_Level[entity], entity, 1.0);
	

	float divide = 3.0;

	switch(type)
	{
		case Element_Necrosis:
		{
			if(GetTeam(entity) == TFTeam_Red)
				return 1000;
			
			if(b_thisNpcIsARaid[entity])
				return 50000;
			
			return b_thisNpcIsABoss[entity] ? 25000 : 12500;
		}
		case Element_Cyro:
		{
			divide = 4.0;
		}
		case Element_Void, Element_Plasma:
		{
			divide = 2.0;
		}
		case Element_Burger:
		{
			divide = 2.0;

			if(b_thisNpcIsARaid[entity] || EntRefToEntIndex(RaidBossActive) == entity)
			{
				divide = 3.0;
			}
			else if(b_thisNpcIsABoss[entity])
			{
				divide = 3.0;
			}
		}
	}

	if(Citizen_IsIt(entity))
		return view_as<Citizen>(entity).m_iGunValue / 20;
	
	if(type != Element_Burger)
	{
		//also works against superbosses.
		if(b_thisNpcIsARaid[entity] || EntRefToEntIndex(RaidBossActive) == entity)
		{
			divide *= (5.2 * MultiGlobalHighHealthBoss); //Reduce way further so its good against raids.
		}
		else if(b_thisNpcIsABoss[entity])
		{
			divide *= (3.0 * MultiGlobalHealthBoss); //Reduce way further so its good against bosses.
		}
		else if (b_IsGiant[entity])
		{
			divide *= 2.0;
		}
	}

	return RoundToCeil((float(ReturnEntityMaxHealth(entity)) / fl_GibVulnerablity[entity]) / divide);
}

bool Elemental_HurtHud(int entity, char Debuff_Adder[128])
{
	float gameTime = GetGameTime();
	
	// An elemental effect is in cooldown
	for(int i; i < Element_MAX; i++)
	{
		if(LastElement[entity] == i && f_ArmorCurrosionImmunity[entity][i] > GetGameTime())
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), "<%s %ds>", ElementName[LastElement[entity]], RoundToCeil(f_ArmorCurrosionImmunity[entity][i] - gameTime));
			return true;
		}
	}
	

	// Don't display anything after 5 seconds of nothing
	if((LastTime[entity] + 5.0) < gameTime && GetTeam(entity) != TFTeam_Red)
		return false;
	
	// Find the element that's closest to trigger
	int low = -1;
	int lowHealth = 1000000;
	for(int i; i < Element_MAX; i++)
	{
		if(ElementDamage[entity][i] > 0)
		{
			int health = TriggerDamage(entity, i) - ElementDamage[entity][i];
			if(health < lowHealth)
			{
				low = i;
				lowHealth = health;
			}
		}
	}

	// Nothing found
	if(low == -1)
		return false;
	
	// <CY 50%>
	Format(Debuff_Adder, sizeof(Debuff_Adder), "<%s %d％>", ElementName[low], ElementDamage[entity][low] * 100 /TriggerDamage(entity, low));
	return true;
}

void Elemental_AddNervousDamage(int victim, int attacker, int damagebase, bool sound = true, bool ignoreArmor = false)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients && victim > 0)
	{
		Armor_DebuffType[victim] = 1;
		if(f_ArmorCurrosionImmunity[victim][Element_Nervous] < GetGameTime() && (ignoreArmor || Armor_Charge[victim] < 1))
		{
			if(i_HealthBeforeSuit[victim] > 0)
			{
				SDKHooks_TakeDamage(victim, attacker, attacker, damagebase * 4.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
			else
			{
				damage -= RoundToNearest(Attributes_GetOnPlayer(victim, Attrib_ElementalDef, false));
				if(damage < 1)
					damage = 1;
				
				Armor_Charge[victim] -= damage;
				if(Armor_Charge[victim] < (-MaxArmorCalculation(Armor_Level[victim], victim, 1.0)))
				{
					Armor_Charge[victim] = 0;
					f_ArmorCurrosionImmunity[victim][Element_Nervous] = GetGameTime() + 5.0;
					
					if(!HasSpecificBuff(victim, "Fluid Movement"))
						TF2_StunPlayer(victim, 5.0, 0.9, TF_STUNFLAG_SLOWDOWN);

					DealTruedamageToEnemy(0, victim, 500.0);
				}
			}
			
			if(sound || !Armor_Charge[victim])
				ClientCommand(victim, "playgamesound weapons/drg_pomson_drain_01.wav");
		}
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Nervous]  < GetGameTime())
		{
			int trigger;
			if(Citizen_IsIt(victim))	// Rebels
			{
				if(!ignoreArmor)
				{
					// Has "armor" at 75% HP
					if(GetEntProp(victim, Prop_Data, "m_iHealth") > (ReturnEntityMaxHealth(victim) * 3 / 4))
						return;
				}

			}
			
			trigger = TriggerDamage(victim, Element_Nervous);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Nervous;
			ElementDamage[victim][Element_Nervous] += damage;
			if(ElementDamage[victim][Element_Nervous] > trigger)
			{
				ElementDamage[victim][Element_Nervous] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Nervous]  = GetGameTime() + 5.0;

				if(GetTeam(victim) == TFTeam_Red)
				{
					FreezeNpcInTime(victim, 3.0);
					SDKHooks_TakeDamage(victim, attacker, attacker, 400.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
				}
				else
				{
					FreezeNpcInTime(victim, b_thisNpcIsARaid[victim] ? 3.0 : 5.0);
					SDKHooks_TakeDamage(victim, attacker, attacker, 1000.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
				}
			}
		}
	}
	else if(i_IsABuilding[victim])	// Buildings
	{
		int health = Object_GetRepairHealth(victim);
		if(health < 1 || ignoreArmor)
		{
			DealTruedamageToEnemy(0, victim, damage * 100.0);
		}
	}
}

void Elemental_AddChaosDamage(int victim, int attacker, int damagebase, bool sound = true, bool ignoreArmor = false)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;

	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		Armor_DebuffType[victim] = 2;
		if((b_thisNpcIsARaid[attacker] || f_ArmorCurrosionImmunity[victim][Element_Chaos]  < GetGameTime()) && (ignoreArmor || Armor_Charge[victim] < 1))
		{
			if(i_HealthBeforeSuit[victim] > 0)
			{
				SDKHooks_TakeDamage(victim, attacker, attacker, damagebase * 4.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
			else
			{
				damage -= RoundToNearest(Attributes_GetOnPlayer(victim, Attrib_ElementalDef, false));
				if(damage < 1)
					damage = 1;
				
				Armor_Charge[victim] -= damage;
				if(Armor_Charge[victim] < (-MaxArmorCalculation(Armor_Level[victim], victim, 1.0)))
				{
					Armor_Charge[victim] = 0;
					float ProjectileLoc[3];
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
					ProjectileLoc[2] += 45.0;

					//if server starts crashing out of nowhere, change how to change teamnum
					EmitSoundToAll("mvm/mvm_tank_explode.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					ParticleEffectAt(ProjectileLoc, "hightower_explosion", 1.0);
					b_NpcIsTeamkiller[victim] = true;
					Explode_Logic_Custom(0.0,
					attacker,
					attacker,
					-1,
					ProjectileLoc,
					250.0,
					_,
					_,
					true,
					99,
					false,
					_,
					SakratanGroupDebuff);
					b_NpcIsTeamkiller[victim] = false;
					f_ArmorCurrosionImmunity[victim][Element_Chaos]  = GetGameTime() + 10.0;
				//	Explode_Logic_Custom(fl_rocket_particle_dmg[entity] , inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
				}
			}
			
			if(sound || !Armor_Charge[victim])
				ClientCommand(victim, "playgamesound friends/friend_online.wav");
		}
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Chaos] < GetGameTime())
		{
			int trigger;
			if(Citizen_IsIt(victim))	// Rebels
			{
				if(!ignoreArmor)
				{
					// Has "armor" at 75% HP
					if(GetEntProp(victim, Prop_Data, "m_iHealth") > (ReturnEntityMaxHealth(victim) * 3 / 4))
						return;
				}
			}
			
			trigger = TriggerDamage(victim, Element_Chaos);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Chaos;
			ElementDamage[victim][Element_Chaos] += damage;
			if(ElementDamage[victim][Element_Chaos] > trigger)
			{
				ElementDamage[victim][Element_Chaos] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Chaos]  = GetGameTime() + 5.0;

				IncreaseEntityDamageTakenBy(victim, 1.30, 10.0);
				NPC_Ignite(victim, attacker, 10.0, -1);

				float burn = GetTeam(victim) == TFTeam_Red ? 10.0 : 25.0;
				if(BurnDamage[victim] < burn)
					BurnDamage[victim] = burn;
			}
		}
	}
	else if(i_IsABuilding[victim])	// Buildings
	{
		IncreaseEntityDamageTakenBy(victim, (damage * 0.001), 5.0, true);
	}
}


void Elemental_AddVoidDamage(int victim, int attacker, int damagebase, bool sound = true, bool ignoreArmor = false, bool VoidWeaponDo = false)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;
	if(view_as<CClotBody>(victim).m_iBleedType == BLEEDTYPE_VOID || (victim <= MaxClients && ClientPossesesVoidBlade(victim)))
		return;
	//cant void other voids!

	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		Armor_DebuffType[victim] = 3;
		if((b_thisNpcIsARaid[attacker] || f_ArmorCurrosionImmunity[victim][Element_Void] < GetGameTime()) && (ignoreArmor || Armor_Charge[victim] < 1))
		{
			if(i_HealthBeforeSuit[victim] > 0)
			{
				SDKHooks_TakeDamage(victim, attacker, attacker, damagebase * 4.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
			else
			{
				damage -= RoundToNearest(Attributes_GetOnPlayer(victim, Attrib_ElementalDef, false));
				if(damage < 1)
					damage = 1;
				
				Armor_Charge[victim] -= damage;
				if(Armor_Charge[victim] < (-MaxArmorCalculation(Armor_Level[victim], victim, 1.0)))
				{
					Armor_Charge[victim] = 0;
					float ProjectileLoc[3];
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
					ProjectileLoc[2] += 5.0;
					VoidArea_SpawnNethersea(ProjectileLoc, VoidWeaponDo);
					FramingInfestorSpread(victim);
					EmitSoundToAll("npc/scanner/cbot_discharge1.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					f_ArmorCurrosionImmunity[victim][Element_Void] = GetGameTime() + 5.0;
					//Do code for void spread
				}
			}
			
			if(sound || !Armor_Charge[victim])
				ClientCommand(victim, "playgamesound npc/scanner/cbot_servoscared.wav ; playgamesound npc/scanner/cbot_servoscared.wav");
		}
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Void] < GetGameTime())
		{
			int trigger;
			if(Citizen_IsIt(victim))	// Rebels
			{
				if(!ignoreArmor)
				{
					// Has "armor" at 75% HP
					if(GetEntProp(victim, Prop_Data, "m_iHealth") > (ReturnEntityMaxHealth(victim) * 3 / 4))
						return;
				}

			}
			
			trigger = TriggerDamage(victim, Element_Void);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Void;
			ElementDamage[victim][Element_Void] += damage;
			if(ElementDamage[victim][Element_Void] > trigger)
			{
				ElementDamage[victim][Element_Void] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Void] = GetGameTime() + 5.0;
				float ProjectileLoc[3];
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
				ProjectileLoc[2] += 5.0;
				EmitSoundToAll("npc/scanner/cbot_discharge1.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				VoidArea_SpawnNethersea(ProjectileLoc, VoidWeaponDo);
				//do not spread.
				FramingInfestorSpread(victim);
			}
		}
	}
	else if(i_IsABuilding[victim])	// Buildings
	{
		//removes repair of buildings.
		int Repair = GetEntProp(victim, Prop_Data, "m_iRepair");
		Repair -= (damage / 2);
		if(Repair <= 0)
			Repair = 0;

		SetEntProp(victim, Prop_Data, "m_iRepair", Repair);
	}
}

static void SakratanGroupDebuff(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) != GetTeam(entity))
		SakratanGroupDebuffInternal(victim);
		
}

static void SakratanGroupDebuffInternal(int victim)
{
	if(victim <= MaxClients)
	{
		DealTruedamageToEnemy(0, victim, 250.0);
	}
	IncreaseEntityDamageTakenBy(victim, 1.30, 10.0);
}

void Elemental_AddCyroDamage(int victim, int attacker, int damagebase, int type)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;
	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		// Cyro is treated as Chaos vs Players
		Elemental_AddChaosDamage(victim, attacker, damagebase, _, true);
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Cyro] < GetGameTime())
		{
			int trigger = TriggerDamage(victim, Element_Cyro);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Cyro;
			ElementDamage[victim][Element_Cyro] += damage;
			if(ElementDamage[victim][Element_Cyro] > trigger)
			{
				ElementDamage[victim][Element_Cyro] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Cyro] = GetGameTime() + (9.5 + (type * 0.5));

				Cryo_FreezeZombie(attacker, victim, type);
			}
		}
	}
	else if(i_IsABuilding[victim])	// Buildings
	{
		IncreaseEntityDamageTakenBy(victim, (damage * 0.001), 5.0, true);
	}
}

void Elemental_AddNecrosisDamage(int victim, int attacker, int damagebase, int weapon = -1)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;
	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		// No effect currently for Necrosis vs Players
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Necrosis] < GetGameTime())
		{
			int trigger = TriggerDamage(victim, Element_Necrosis);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Necrosis;
			ElementDamage[victim][Element_Necrosis] += damage;
			if(ElementDamage[victim][Element_Necrosis] > trigger)
			{
				ElementDamage[victim][Element_Necrosis] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Necrosis] = GetGameTime() + 7.5;

				StartBleedingTimer(victim, attacker, 800.0, 15, weapon, DMG_TRUEDAMAGE, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
				
				float time = 7.5;
				if(b_thisNpcIsARaid[victim])
					time = 3.0;
				
				ApplyStatusEffect(attacker, victim, "Enfeeble", time);
			}
		}
	}
}


void Elemental_AddOsmosisDamage(int victim, int attacker, int damagebase)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;
	
	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		// No effect currently for Necrosis vs Players
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Osmosis] < GetGameTime())
		{
			int trigger = TriggerDamage(victim, Element_Osmosis);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Osmosis;
			ElementDamage[victim][Element_Osmosis] += damage;
			if(ElementDamage[victim][Element_Osmosis] > trigger)
			{
				ElementDamage[victim][Element_Osmosis] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Osmosis] = GetGameTime() + 15.0;
				OsmosisElementalEffectEnable(victim, 7.5);
			}
		}
	}
}
void OsmosisElementalEffectEnable(int victim, float time)
{
	//Reset hit detection on all players
	EntityKilled_HitDetectionCooldown(victim, Osmosisdebuff);
	if(time > 0.0)
		ApplyStatusEffect(victim, victim, "Osmosis'ity", time);
}

bool Osmosis_CurrentlyInDebuff(int victim)
{
	if(NpcStats_InOsmosis(victim))
		return true;

	return false;
}

void OsmosisElementalEffect_Detection(int attacker, int victim)
{
	if(!NpcStats_InOsmosis(victim))
		return;
	
	if(IsIn_HitDetectionCooldown(victim,attacker, Osmosisdebuff))
		return;

	int weapon_holding = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == -1)
		return;

	if(!Saga_IsChargeWeapon(attacker, weapon_holding))
		return;

	Set_HitDetectionCooldown(victim,attacker, FAR_FUTURE, Osmosisdebuff);
	//play a little sound!
	Saga_ChargeReduction(attacker, weapon_holding, 2.0);
	ClientCommand(attacker, "playgamesound ui/mm_medal_click.wav");
}
void Elemental_AddCorruptionDamage(int victim, int attacker, int damagebase, bool sound = true, bool ignoreArmor = false)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;

	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);

	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(victim <= MaxClients)
	{
		/*
		if(Items_HasNamedItem(victim, "Matrix's Curse") && !Items_HasNamedItem(victim, "A Block of Cheese"))
		{
			damage = RoundToNearest(float(damage) * 1.2);
		}
		*/
		Armor_DebuffType[victim] = 4;
		if((b_thisNpcIsARaid[attacker] || f_ArmorCurrosionImmunity[victim][Element_Corruption] < GetGameTime()) && (ignoreArmor || Armor_Charge[victim] < 1))
		{
			if(i_HealthBeforeSuit[victim] > 0)
			{
				SDKHooks_TakeDamage(victim, attacker, attacker, damagebase * 4.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
			else
			{
				Armor_Charge[victim] -= damage;
				if(Armor_Charge[victim] < (-MaxArmorCalculation(Armor_Level[victim], victim, 1.0)))
				{
					Armor_Charge[victim] = 0;
					
					int count = RoundToCeil(2.0 * MultiGlobalEnemy);
					Matrix_Spawning(attacker, count);

					EmitSoundToAll("ambient/energy/weld1.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					f_ArmorCurrosionImmunity[victim][Element_Corruption] = GetGameTime() + 5.0;
				}
			}
			
			if(sound || !Armor_Charge[victim])
				ClientCommand(victim, "playgamesound buttons/combine_button1.wav ; playgamesound buttons/combine_button1.wav");
		}
	}
	else if(!b_NpcHasDied[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Corruption] < GetGameTime())
		{
			int trigger;
			if(Citizen_IsIt(victim))	// Rebels
			{
				if(!ignoreArmor)
				{
					// Has "armor" at 75% HP
					if(GetEntProp(victim, Prop_Data, "m_iHealth") > (GetEntProp(victim, Prop_Data, "m_iMaxHealth") * 3 / 4))
						return;
				}
			}
			
			trigger = TriggerDamage(victim, Element_Corruption);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Corruption;
			ElementDamage[victim][Element_Corruption] += damage;
			if(ElementDamage[victim][Element_Corruption] > trigger)
			{
				ElementDamage[victim][Element_Corruption] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Corruption] = GetGameTime() + 5.0;
				EmitSoundToAll("ambient/energy/weld1.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				int count = RoundToCeil(3.0 * MultiGlobalEnemy);
				Matrix_Spawning(attacker, count);
			}
		}
	}
	else if(i_IsABuilding[victim])	// Buildings
	{
		//removes repair of buildings.
		int Repair = GetEntProp(victim, Prop_Data, "m_iRepair");
		Repair -= damage;
		if(Repair <= 0)
			Repair = 0;
		SetEntProp(victim, Prop_Data, "m_iRepair", Repair);
	}
}

static char g_Agent_Summons[][] =
{
	//wave 1-29 | 0-6
	"npc_agent_john",
	"npc_agent_james",
	"npc_agent_chase",
	"npc_agent_dave",
	"npc_agent_alexander",
	"npc_agent_steve",
	"npc_agent_alan",
	"npc_agent_eric",
	"npc_agent_jack",
	"npc_agent_jim",
	"npc_agent_josh",
	"npc_agent_kenneth",
	"npc_agent_paul",
	"npc_agent_tyler",
	"npc_agent_wayne",

	//wave 30-59 | 7-11
	"npc_agent_alan",
	"npc_agent_eric",
	"npc_agent_jack",
	"npc_agent_jim",
	"npc_agent_josh",
	"npc_agent_kenneth",
	"npc_agent_paul",
	"npc_agent_tyler",
	"npc_agent_wayne",
	"npc_agent_ben",
	"npc_agent_chad",
	"npc_agent_chris",
	"npc_agent_dick",
	"npc_agent_ian",
	"npc_agent_mike",
	"npc_agent_sam",

	//wave 60 | 12-16
	"npc_agent_connor",
	"npc_agent_henry",
	"npc_agent_jeremy",
	"npc_agent_kurt",
	"npc_agent_logan",
	"npc_agent_ross",
	"npc_agent_spencer",
	"npc_agent_todd",
};

static void Matrix_Spawning(int entity, int count)
{
	int summon = GetRandomInt(0, 6);
	int wave = (ZR_Waves_GetRound() + 1);
	if(wave >= 30)
	{
		summon = GetRandomInt(7, 11);
	}
	if(wave >= 45)
	{
		summon = GetRandomInt(12, 16);
	}

	char name[255];
	FormatEx(name, sizeof(name), "%s", g_Agent_Summons[summon]);
	int health = ReturnEntityMaxHealth(entity);
	if(b_thisNpcIsABoss[entity])
	{
		health = (ReturnEntityMaxHealth(entity)/10);
	}
	if(b_thisNpcIsARaid[entity])
	{
		health = (ReturnEntityMaxHealth(entity)/100);
	}
	
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(name);
	enemy.Health = health;
	enemy.Is_Outlined = false;
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(entity);
	for(int i; i<count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += count;
}

void Elemental_AddBurgerDamage(int victim, int attacker, int damagebase)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;
	
	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(!b_NpcHasDied[victim] && GetTeam(victim) != TFTeam_Red && !i_NpcIsABuilding[victim])	// NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Burger] < GetGameTime())
		{
			int trigger = TriggerDamage(victim, Element_Burger);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Burger;
			ElementDamage[victim][Element_Burger] += damage;
			if(ElementDamage[victim][Element_Burger] > trigger)
			{
				ElementDamage[victim][Element_Burger] = 0;
				f_ArmorCurrosionImmunity[victim][Element_Burger] = GetGameTime() + 100.0;

				if(func_NPCThink[victim] != MedivalConstruct_ClotThink || EntRefToEntIndex(RaidBossActive) != -1)
				{
					SDKHooks_TakeDamage(victim, attacker, attacker, ReturnEntityMaxHealth(victim) * 5.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, .Zr_damage_custom = ZR_DAMAGE_GIB_REGARDLESS);
				}
			}
		}
	}
}

void Elemental_AddPlasmicDamage(int victim, int attacker, int damagebase, int weapon, bool ignoreArmor = false)
{
	if(i_IsVehicle[victim])
	{
		victim = Vehicle_Driver(victim);
		if(victim == -1)
			return;
	}
	
	if(b_NpcIsInvulnerable[victim])
		return;

	bool melee = (i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_MELEE);

	int damage = RoundFloat(damagebase * fl_Extra_Damage[attacker]);
	if(NpcStats_ElementalAmp(victim))
	{
		damage = RoundToNearest(float(damage) * 1.3);
	}
	if(Cheese_GetPenaltyDuration(victim) > GetGameTime())
	{
		damage = RoundToNearest(float(damage) * 0.5);
	}
	if(victim <= MaxClients) // VS Players, but why?
	{
		Armor_DebuffType[victim] = 5;
		if((f_ArmorCurrosionImmunity[victim][Element_Plasma] < GetGameTime()) && (ignoreArmor || Armor_Charge[victim] < 1))
		{
			if(i_HealthBeforeSuit[victim] > 0)
			{
				SDKHooks_TakeDamage(victim, attacker, attacker, damagebase * 4.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
			else
			{
				damage -= RoundToNearest(Attributes_GetOnPlayer(victim, Attrib_ElementalDef, false));
				if(damage < 1)
					damage = 1;
				
				Armor_Charge[victim] -= damage;
				if(Armor_Charge[victim] < (-MaxArmorCalculation(Armor_Level[victim], victim, 1.0)))
				{
					SDKHooks_TakeDamage(victim, attacker, attacker, (float(ReturnEntityMaxHealth(victim)) * 0.25), DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, weapon);
					ApplyStatusEffect(attacker, victim, "Plasm II", 5.0);
					Cheese_SetPenaltyDuration(victim, 10.0);
					
					float position[3];
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
					position[2] += 10.0;
					for(int i = 0; i < 3; i++)
					{
						Cheese_BeamEffect(position);
						position[2] += 32.5;
					}
					Cheese_PlaySplat(victim);
					Armor_Charge[victim] = 0;
					f_ArmorCurrosionImmunity[victim][Element_Plasma] = GetGameTime() + 5.0;
				}
			}
		}
	}
	else if(!b_NpcHasDied[victim])	// VS NPCs
	{
		if(f_ArmorCurrosionImmunity[victim][Element_Plasma] < GetGameTime())
		{
			int trigger = TriggerDamage(victim, Element_Plasma);

			LastTime[victim] = GetGameTime();
			LastElement[victim] = Element_Plasma;
			ElementDamage[victim][Element_Plasma] += damage;
			if(ElementDamage[victim][Element_Plasma] > trigger)
			{
				ElementDamage[victim][Element_Plasma] = 0;
				float immunitycd = melee ? 10.0 : 15.0;
				f_ArmorCurrosionImmunity[victim][Element_Plasma] = GetGameTime() + immunitycd;

				// i am pap
				int paplvl = RoundFloat(Attributes_Get(weapon, 122, 0.0));
				float cheesedmg;
				if(paplvl > 1)
				{
					cheesedmg = (1350.0 * ((paplvl + paplvl)));
				}
				else if(paplvl > 3)
				{
					cheesedmg = (1625.0 * ((paplvl + paplvl)));
				}
				else
				{
					cheesedmg = 1000.0 * (1 + paplvl);
				}

				if(melee) // if applied via melee, slight dmg boost.
					cheesedmg *= 1.25;

				if(b_thisNpcIsARaid[victim])
				{
					cheesedmg *= 2.75;
					ApplyStatusEffect(attacker, victim, "Plasm I", 5.0);
					Cheese_SetPenaltyDuration(victim, immunitycd + 20.0);
				}
				else if(b_thisNpcIsABoss[victim])
				{
					cheesedmg *= 1.85;
					ApplyStatusEffect(attacker, victim, "Plasm II", 5.0);
					Cheese_SetPenaltyDuration(victim, immunitycd + 10.0);
				}
				else
				{
					ApplyStatusEffect(attacker, victim, "Plasm II", 10.0);
				}

				// important
				cheesedmg *= 0.8;

				if(cheesedmg > float(ReturnEntityMaxHealth(victim)))
					cheesedmg = 1 + float(ReturnEntityMaxHealth(victim));

				// fun fact: this used to deal true damage. Uh oh!
				if(melee) // if applied via melee, slight dmg boost and melee type.
					SDKHooks_TakeDamage(victim, attacker, attacker, cheesedmg*1.25, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, weapon);
				else
					SDKHooks_TakeDamage(victim, attacker, attacker, cheesedmg, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, weapon);

				float position[3];
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
				position[2] += 10.0;
				for(int i = 0; i < 3; i++)
				{
					Cheese_BeamEffect(position);
					position[2] += 32.5;
				}
				Cheese_PlaySplat(victim);
			}
		}
	}
	else if(i_IsABuilding[victim])
	{
		// no effect yet
	}
}
