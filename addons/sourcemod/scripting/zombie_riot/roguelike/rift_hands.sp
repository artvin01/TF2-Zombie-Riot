#pragma semicolon 1
#pragma newdecls required

static bool Hand2Charger;
static bool Hand2Rapid;

void Rogue_Hand2_AbilityUse(int client, int weapon)
{
	if(Hand2Charger && i_WeaponArchetype[weapon] == Archetype_Charger)
	{
		Attributes_SetMulti(weapon, 6, 0.935);
	}

	if(Hand2Rapid && i_WeaponArchetype[weapon] == Archetype_Rapid)
	{
		DataPack pack;
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		RequestFrame(RogueHand2RapidFrame, pack);
	}
}

public void Rogue_Hand2Charger_Collect()
{
	Hand2Charger = true;
}

public void Rogue_Hand2Charger_Remove()
{
	Hand2Charger = false;
}

public void Rogue_Hand2Rapid_Collect()
{
	Hand2Rapid = true;
}

public void Rogue_Hand2Rapid_Remove()
{
	Hand2Rapid = false;
}

public void Rogue_Hand2Hexer_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Hexing)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			float extra = GetEntProp(victim, Prop_Data, "m_iHealth") * 0.03;

			// Scale down with health scaling
			if(b_thisNpcIsARaid[victim])
			{
				if(MultiGlobalHighHealthBoss)
					extra /= MultiGlobalHighHealthBoss;
			}
			else if(b_thisNpcIsABoss[victim])
			{
				if(MultiGlobalHealthBoss)
					extra /= MultiGlobalHealthBoss;
			}
			else if(MultiGlobalHealth)
			{
				extra /= MultiGlobalHealth;
			}

			StartBleedingTimer(victim, attacker, extra, 1, weapon, DMG_PLASMA, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED, 1);
		}
	}
}

public void Rogue_Hand2Duelist_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Duelist)
	{
		damagetype = DMG_TRUEDAMAGE;
	}
}

static void RogueHand2RapidFrame(DataPack pack)
{
	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			for(int i = 1; i < 4; i++)
			{
				float cooldown = Ability_Check_Cooldown(client, i, weapon);
				if(cooldown > 0.0)
				{
					Ability_Apply_Cooldown(client, i, (cooldown / 2.0), weapon, true);
					break;
				}
			}
		}
	}

	delete pack;
}

public void Rogue_Hand2Artillery_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Artillery)
	{
		Attributes_Set(entity, Attrib_MaxEnemiesHitExplode, 100.0);
		Attributes_Set(entity, Attrib_ExplosionFalloff, 1.0);
	}
}

public void Rogue_Hand2Defender_Enemy(int entity)
{
	ApplyStatusEffect(entity, entity, "Fisticuffs", 999.9);
}

public void Rogue_Hand2Defender_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(victim <= MaxClients && (damagetype & DMG_CLUB))
	{
		int active = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		if(active != -1 && i_WeaponArchetype[active] == Archetype_Defender && HasSpecificBuff(attacker, "Fisticuffs"))
		{
			RemoveSpecificBuff(attacker, "Fisticuffs");
			FreezeNpcInTime(attacker, 1.0);
			StartBleedingTimer(attacker, victim, damage, 1, weapon, DMG_TRUEDAMAGE, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED, 1);
		}
	}
}

public void Rogue_Hand2Deadeye_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Deadeye)
	{
		if(i_HasBeenHeadShotted[victim] && view_as<CClotBody>(victim).m_iHealthBar < 1 && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			int health = GetEntProp(victim, Prop_Data, "m_iHealth");
			int maxhealth = ReturnEntityMaxHealth(victim);
			
			if(health < (maxhealth / 5))
			{
				damage += float(health);
				damagetype = DMG_TRUEDAMAGE;
			}
		}
	}
}

public void Rogue_Hand2Ambusher_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Ambusher)
	{
		Attributes_Set(entity, 6, 0.45);
	}
}

public void Rogue_Hand2Power_Weapon(int entity)
{
	if(i_WeaponArchetype[entity] == Archetype_Power)
	{
		// +300% max mana
		Attributes_SetMulti(entity, 405, 4.0);
	}
}