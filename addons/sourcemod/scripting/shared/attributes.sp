#pragma semicolon 1
#pragma newdecls required

//4007 4008 4009 40010 Melee, Ranged, all damage taken while active | Apply Stats only while active (rpg)
enum
{
	Attrib_PapNumber = 122,
	Attrib_MaxEnemiesHitExplode = 4011,
	Attrib_ReducedGibHealing = 4012,
	Attrib_ExplosionFalloff = 4013,
	Attrib_ConsumeReserveAmmo = 4014,
	Attrib_NeverAttack = 4015, //If set to 1, sets the weapons next attack to FAR_FUTURE, as doing 821 ; 1 ; 128 ; 1 breaks animations.
	Attrib_BonusRaidDamage = 4016,
	Attrib_AttackspeedConvertIntoDmg = 4017,
	Attrib_ClaimCadesAlways = 4018,
	Attrib_MaxManaAdd = 4019,
	Attrib_ManaRegen = 4020, 
	Attrib_OverrideWeaponSkin = 4021, // Override Weapon Skin To This
	Attrib_TerrianRes = 4022,
	Attrib_ElementalDef = 4023,
	Attrib_SlowImmune = 4024,
	Attrib_ObjTerrianAbsorb = 4025,
	Attrib_SetArchetype = 4026,
	Attrib_SetSecondaryDelayInf = 4027, // Set secondary weapon delay to FAR_FUTURE
	Attrib_FormRes = 4028,
	Attrib_OverrideExplodeDmgRadiusFalloff = 4029,
	Attrib_CritChance = 4030,
	// 4031
	// 4032
	Attrib_ReviveTimeCut = 4033,
	Attrib_ExtendExtraCashGain = 4034,
	Attrib_ReduceMedifluidCost = 4035,
	Attrib_ReduceMetalCost = 4036,
	Attrib_BarracksHealth = 4037,
	Attrib_BarracksDamage = 4038,
	Attrib_BlessingBuff = 4039,
	Attrib_ArmorOnHit = 4040,
	Attrib_ArmorOnHitMax = 4041,
	Attrib_Melee_UseBuilderDamage = 4042,
	Attrib_HeadshotBonus = 4043,
	Attrib_ReviveSpeedBonus = 4044,
	Attrib_BuildingOnly_PreventUpgrade = 4045, 
	//used for anti abuse.
	//specifically so you cant repair buildings for low cost and re-upgrade them.

	Attrib_BuildingStatus_PreventAbuse = 4046, 
	//used for anti abuse.
	//specifally so you cant make ranged units lategame and sell all other units and just keep those alive forever.

	Attrib_Weapon_MaxDmgMulti = 4047, 
	Attrib_Weapon_MinDmgMulti = 4048, 
	//used currently for heavy particle rifle
	//but will probably be used for other weapons to define max/min dmg depending on whatever the weapon specific plugin does with it.
	Attrib_ElementalDefPerc = 4049,

	Attrib_BarracksSupplyRate = 4050,
	Attrib_FinalBuilder = 4051,
	Attrib_GlassBuilder = 4052,
	Attrib_WildingenBuilder = 4053,
	Attrib_TauntRangeValue = 4054,
	Attrib_DamageTakenFromRaid = 4055,
	Attrib_RegenHpOutOfBattle_MaxHealthScaling = 4056,

	Attrib_DisallowTinker = 4057,
	Attrib_MultiBuildingDamage = 4058,
	Attrib_ASPD_StatusCalc,	// Only used in status_effect to determine their current ASPD amount
}

StringMap WeaponAttributes[MAXENTITIES + 1];

bool Attribute_ServerSide(int attribute)
{
	if(attribute > 3999)
		return true;
	
	switch(attribute)
	{
		/*

		Various attributes that are not needed as actual attributes.
		*/
		case 526,733, 309, 777, 701, 805, 180, 830, 785, 405, 527, 319, 286,287 , 95 , 93,8, 734:
		{
			return true;
		}

		case 57, 190, 191, 218, 366, 651,33,731,719,544,410,786,3002,3000,149,208,638,17,71,868,122,225, 224,205,206, 412:
		{
			return true;
		}
	}
	return false;
}

bool Attribute_IntAttribute(int attribute)
{
	switch(attribute)
	{
		case 314, 834, 866, 867, Attrib_BarracksSupplyRate, Attrib_FinalBuilder, Attrib_GlassBuilder, Attrib_WildingenBuilder:
			return true;
	}

	return false;
}

bool Attribute_DontSaveAsIntAttribute(int attribute)
{
	switch(attribute)
	{
		//this attrib is a float, but saves as an int, for stuff thats additional, not multi.
		case 314, 142:
			return true;
	}

	return false;
}

/*
	There are attributes that are used only for ZR that dont actually exist
	there are described here:
	4001: Extra melee range
	4002: Medigun overheal
	4007: Melee resisance while equipped in hand
	4008: Ranged resistance while equipped in hand
	4009: total damage reduced while in hand
	4010: RPG ONLY!!! Stats to use while in hand only such as STR or END or DEX
	4011: Explosive weapon limit on hit if its not on default, default is 10 (hits only 10 enemies.), you can reduce it to 2 for example, if your explosive weapon has tiny AOE
	733: Magic shot cost
	410: Magic damage % 

	most of these are via %, 1.0 means just 100% normal, 0.5 means half, 1.5 means 50% more
*/
void Attributes_EntityDestroyed(int entity)
{
	delete WeaponAttributes[entity];
}

stock bool Attributes_RemoveAll(int entity)
{
	delete WeaponAttributes[entity];
	return TF2Attrib_RemoveAll(entity);
}

int ReplaceAttribute_Internally(int attribute)
{
	switch(attribute)
	{
		//replace dmg attrib with another, this is due to the MVM hud on pressing inspect fucking crashing you at high dmges
		case 2:
			return 1000;
	}
	return attribute;
}
bool Attributes_Has(int entity, int attrib)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(!WeaponAttributes[entity])
		return false;
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].ContainsKey(buffer);
}

float Attributes_Get(int entity, int attrib, float defaul = 1.0)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(WeaponAttributes[entity])
	{
		float value = defaul;

		char buffer[6];
		IntToString(attrib, buffer, sizeof(buffer));
		if(WeaponAttributes[entity].GetValue(buffer, value))
			return value;
	}
	
	return defaul;
}

bool Attributes_Set(int entity, int attrib, float value, bool DoOnlyTf2Side = false)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(!DoOnlyTf2Side)
	{
		if(!WeaponAttributes[entity])
			WeaponAttributes[entity] = new StringMap();
		
		char buffer[6];
		IntToString(attrib, buffer, sizeof(buffer));
		WeaponAttributes[entity].SetValue(buffer, value);

		if(Attribute_ServerSide(attrib))
			return false;
	}
	
	if(Attribute_IntAttribute(attrib) && !Attribute_DontSaveAsIntAttribute(attrib))
	{
		TF2Attrib_SetByDefIndex(entity, attrib, view_as<float>(RoundFloat(value)));
		return true;
	}
	
	
	TF2Attrib_SetByDefIndex(entity, attrib, value);
	return true;
}

stock void Attributes_SetAdd(int entity, int attrib, float amount)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(attrib == Attrib_SetArchetype)
	{
		i_WeaponArchetype[entity] = RoundFloat(amount);
		return;
	}

	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 0.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].GetValue(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value += amount;

	WeaponAttributes[entity].SetValue(buffer, value);
	if(!Attribute_ServerSide(attrib))
		Attributes_Set(entity, attrib, value, true);
}

stock void Attributes_SetMulti(int entity, int attrib, float amount)
{
	attrib = ReplaceAttribute_Internally(attrib);
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 1.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].GetValue(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value *= amount;

	WeaponAttributes[entity].SetValue(buffer, value);
	if(!Attribute_ServerSide(attrib))
		Attributes_Set(entity, attrib, value, true);

	if(Attribute_IsMovementSpeed(attrib))
	{
		int owner;
		if(entity <= MaxClients)
			owner = entity;
		else
			owner = GetEntPropEnt(owner, Prop_Send, "m_hOwnerEntity");
		if(owner > 0 && owner <= MaxClients)
		{
			SDKCall_SetSpeed(owner);
		}
	}
}

bool Attribute_IsMovementSpeed(int attrib)
{
	switch(attrib)
	{
		case 442, 107, 54:
		{
			return true;
		}
	}

	return false;
}

stock bool Attributes_GetString(int entity, int attrib, char[] value, int length, int &size = 0)
{
	if(!WeaponAttributes[entity])
		return false;

	attrib = ReplaceAttribute_Internally(attrib);
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].GetString(buffer, value, length, size);
}

stock void Attributes_SetString(int entity, int attrib, const char[] value)
{
	if(!WeaponAttributes[entity])
		WeaponAttributes[entity] = new StringMap();
	
	attrib = ReplaceAttribute_Internally(attrib);
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	WeaponAttributes[entity].SetString(buffer, value);
}

#if defined ZR || defined RPG
bool Attributes_Fire(int weapon)
{
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	if(clip > 0)
	{
		float gameTime = GetGameTime();
		if(gameTime < GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack"))
		{
			float value = Attributes_Get(weapon, 298, 0.0);	// mod ammo per shot
			if(value && clip < RoundFloat(value))
			{
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", gameTime + 0.2);
				return true;
			}
		}
	}
	return false;
}
#endif

#if defined RPG
int Attributes_Airdashes(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return RoundFloat(Attributes_Get(weapon, 250, 0.0) + Attributes_GetOnPlayer(client, 393, false));	// air dash count, sniper rage DISPLAY ONLY
}
#endif

float PreventSameFrameGivearmor[MAXPLAYERS];
void Attributes_HitTaken(int victim, int attacker, float &damage)
{
	if(victim > MaxClients)
		return;

	int active = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(active < 1)
	{
		return;
	}
	float value;
	
	if(b_thisNpcIsARaid[attacker])
	{
		value = Attributes_Get(active, Attrib_DamageTakenFromRaid, 0.0);
		if(value != 0.0)
		{
			damage *= value;
		}
	}
}
void Attributes_OnHit(int client, int victim, int weapon, float &damage, int& damagetype)
{
	{
		if(weapon < 1)
		{
			return;
		}
		
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			float value = Attributes_Get(weapon, 16, 0.0) +
				Attributes_Get(weapon, 98, 0.0) +
				Attributes_Get(weapon, 110, 0.0) +
				Attributes_Get(weapon, 111, 0.0);	// add_onhit_addhealth
				
			if(value)
			{
				HealEntityGlobal(client, client, value, 1.0, 0.0, HEAL_SELFHEAL);
			}
			
#if defined ZR
			value = Attributes_Get(weapon, Attrib_ArmorOnHit, 0.0);
			if(PreventSameFrameGivearmor[client] == GetGameTime())
				value = 0.0;
				
			if(value)
			{
				PreventSameFrameGivearmor[client] = GetGameTime();
				if(b_thisNpcIsARaid[victim])
					value *= 2.0;

				float ArmorMax = Attributes_Get(weapon, Attrib_ArmorOnHitMax, 1.0);
				GiveArmorViaPercentage(client, value / ArmorMax, ArmorMax);
			}
#endif
	
			value = Attributes_Get(weapon, 149, 0.0);	// bleeding duration
			if(value)
				StartBleedingTimer(victim, client, Attributes_Get(weapon, 2, 1.0) * 4.0, RoundFloat(value * 2.0), weapon, damagetype);
			
			value = Attributes_Get(weapon, 208, 0.0);	// Set DamageType Ignite

			if(value)
			{

				if(value == 1.0)
					value = 7.5;

				if(value < 1.0)
					value = 2.0;
					
				NPC_Ignite(victim, client, value, weapon);
			}	
			value = Attributes_Get(weapon, 638, 0.0);
			if(value)	// Extinquisher
			{
				if(IgniteFor[victim] > 0)
				{
					damage *= (1.5 * value);
					DisplayCritAboveNpc(victim, client, true);
				}
				//dont actually extinquish, just give them more damage.
			}
			
			value = Attributes_Get(weapon, 17, 0.0);
			if(value)
			{
				if(!HasSpecificBuff(client, "UBERCHARGED") && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)) //No infinite uber chain.
				{
					// add uber charge on hit
					
					ArrayList list = new ArrayList();
						
					int entity, i;
					while(TF2_GetItem(client, entity, i))
					{
						if(b_IsAMedigun[entity])
							list.Push(entity);
					}

					int length = list.Length;
					if(length)
					{
						value /= float(length);
						float extra;
						for(i = length - 1; i >= 0; i--)
						{
							entity = list.Get(i);
							float uber = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
							if(Attributes_Get(entity, 2046, 0.0) == 4.0)
							{
								uber -= value + extra;
							}
							else
							{
								uber += value + extra;
							}
								
							if(uber > 1.0)
							{
								extra = uber - 1.0;
								uber = 1.0;
							}
							else if(uber < 0.0)
							{
								extra = -uber;
								uber = 0.0;
							}
							else
							{
								extra = 0.0;
							}
								
							SetEntPropFloat(entity, Prop_Send, "m_flChargeLevel", uber);
						}
					}
					delete list;
				}
			}
		}
		float value = Attributes_Get(weapon, 877, 0.0);	// speed_boost_on_hit_enemy
		if(value)
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, value);

		value = Attributes_Get(weapon, 309, 0.0);	// Gib on crit, in this case, guranted gibs
		if(value)
			view_as<CClotBody>(victim).m_bGib = true;
		
		value = Attributes_Get(weapon, Attrib_BonusRaidDamage, 1.0);	// bonus damage to raids
		if(value != 1.0)
		{
			if(b_thisNpcIsARaid[victim])
			{
				damage *= value;
			}
		}
		value = Attributes_Get(weapon, Attrib_AttackspeedConvertIntoDmg, 0.0);	// Attackspeed converts into damage
		if(value)
		{
			value = Attributes_Get(weapon, 6, 0.0);
			if(value)
			{
				damage /= value;
			}
		}
		
		value = Attributes_Get(weapon, 225, 0.0);	// if Above Half Health
		if(value)
		{
			float flMaxHealth = float(SDKCall_GetMaxHealth(client));
			float flHealth = float(GetEntProp(client, Prop_Data, "m_iHealth"));
			if((flHealth / flMaxHealth) >= 0.5)
			{
				damage *= value;
			} 
		}

		value = Attributes_Get(weapon, 224, 0.0);	// if Below Half Health
		if(value)
		{
			float flMaxHealth = float(SDKCall_GetMaxHealth(client));
			float flHealth = float(GetEntProp(client, Prop_Data, "m_iHealth"));
			if((flHealth / flMaxHealth) <= 0.5)
			{
				damage *= value;
			} 
		}
		
		value = Attributes_Get(weapon, 366, 0.0);	// mod stun waist high airborne
		if(value)
		{
			if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
			{
				value *= 0.5;
			}

			if(b_thisNpcIsARaid[victim])
			{
				if(value > 1.5)
					value = 1.5;
			}
			
			FreezeNpcInTime(victim, value);
		}

		value = Attributes_Get(weapon, 218, 0.0);	// mark for death
		if(value)
		{
			ApplyStatusEffect(client, victim, "Silenced", value);
		}

		/*
		if(Attributes_GetOnPlayer(client, weapon, 2067))	// attack_minicrits_and_consumes_burning
		{
			int ticks = NPC_Extinguish(victim);
			if(ticks)
			{
				EmitGameSoundToClient(client, "TFPlayer.FlameOut", victim);
				damage += ticks*4.0;
				TF2_AddCondition(client, TFCond_NoHealingDamageBuff, 0.1);
			}
		}
		*/
	}
}

void Attributes_OnKill(int victim, int client, int weapon)
{

	SetEntProp(client, Prop_Send, "m_iKills", GetEntProp(client, Prop_Send, "m_iKills") + 1);

	float value;

	value = Attributes_GetOnPlayer(client, 387, false);	// rage on kill
	if(value)
	{
		float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter") + value;
		if(rage > 100.0)
			rage = 100.0;
		
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
	}

	if(IsValidEntity(weapon) && weapon > MaxClients)
	{
		//dont give health on kill!
		if(!(b_OnDeathExtraLogicNpc[victim] & ZRNPC_DEATH_NOHEALTH))
		{
			value = Attributes_Get(weapon, 180, 0.0);	// heal on kill
			if(value)
			{
				if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
				{
					value *= 4.0;
				}
				else if(b_IsGiant[victim])
				{
					value *= 2.0;
				}
				//Grilled!
				if(HasSpecificBuff(victim, "Burn"))
					value *= 1.1;
					
				HealEntityGlobal(client, client, value, 1.0, 1.0, HEAL_SELFHEAL);
			}
		}
		
		value = Attributes_Get(weapon, 613, 0.0);	// minicritboost on kill
		if(value)
			TF2_AddCondition(client, TFCond_MiniCritOnKill, value);

		if(Attributes_Get(weapon, 644,0.0) || Attributes_Get(weapon, 807,0.0))	// clipsize increase on kill, add_head_on_kill
			SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_iDecapitations")+1);
			
	}


}

//override default
float Attributes_GetOnPlayer(int client, int index, bool multi = true, bool noWeapons = false, float defaultValue = -1.0)
{
	bool AttribWasFound = false;
	float defaul = multi ? 1.0 : 0.0;

	float TempFind = Attributes_Get(client, index, -1.0);
	float result;
	if(TempFind != -1.0)
	{
		AttribWasFound = true;
		result = TempFind;
	}
	else
	{
		result = defaul;
	}
	
	int entity = MaxClients + 1;
	
	if(!noWeapons)
	{
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		int i;
		while(TF2_GetItem(client, entity, i))
		{
			if(index != 128 && active != entity)
			{
				if(Attributes_Get(entity, 128, 0.0))
					continue;
			}
			
			float value = Attributes_Get(entity, index, defaul);
			if(value != defaul)
			{
				AttribWasFound = true;
				if(multi)
				{
					result *= value;
				}
				else
				{
					result += value;
				}
			}
		}
	}
	if(!AttribWasFound)
	{
		if(defaultValue == -1.0)
		{
			return defaul;
		}
		else
		{
			return defaultValue;
		}
	}
	return result;
}

float Attributes_GetOnWeapon(int client, int entity, int index, bool multi = true, float defaultstat = -1.0)
{
	float defaul = multi ? 1.0 : 0.0;
	if(defaultstat != -1.0)
	{	
		defaul = defaultstat;
	}
	float result = Attributes_Get(client, index, defaul);
	
	if(entity > MaxClients)
	{
		float value = Attributes_Get(entity, index, defaul);
		if(value != defaul)
		{
			if(multi)
			{
				result *= value;
			}
			else
			{
				result += value;
			}
		}
	}
	
	return result;
}

/*
#define MULTIDMG_NONE 		 ( 1<<0 )
#define MULTIDMG_MAGIC_WAND  ( 1<<1 )
#define MULTIDMG_BLEED 		 ( 1<<2 )
#define MULTIDMG_BUILDER 	 ( 1<<3 )
*/

float WeaponDamageAttributeMultipliers(int weapon, int Flags = MULTIDMG_NONE, int client = 0)
{
	float DamageBonusLogic = 1.0;
	if((Flags & MULTIDMG_BUILDER))
	{
		if(client > 0)
		{
			float attack_speed;		
			attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true); //Sentry attack speed bonus
							
			DamageBonusLogic = attack_speed * DamageBonusLogic * Attributes_GetOnPlayer(client, 287, true);			//Sentry damage bonus
			return DamageBonusLogic;	
		}
	}
//	DamageBonusLogic *= Attributes_Get(weapon, 1000, 1.0); //global dmg multi
#if defined ZR
	if(i_CustomWeaponEquipLogic[weapon] != WEAPON_TEUTON_DEAD)
#endif
	{
		DamageBonusLogic *= Attributes_Get(weapon, 476, 1.0); //global dmg multi
	}

	if(!(Flags & MULTIDMG_BLEED))
	{
		DamageBonusLogic *= Attributes_Get(weapon, 1, 1.0); //only base damage
	}

	if((Flags & MULTIDMG_MAGIC_WAND))
	{
		DamageBonusLogic *= Attributes_Get(weapon, 410, 1.0); //wand damage multi
	}
	else if(!(Flags & MULTIDMG_BUILDER))
	{
		DamageBonusLogic *= Attributes_Get(weapon, 2, 1.0); //non wand dmg multi
	}
	return DamageBonusLogic;
}