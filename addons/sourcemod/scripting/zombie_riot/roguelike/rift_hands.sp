#pragma semicolon 1
#pragma newdecls required

static bool Hand2Charger;
static bool Hand2Rapid;
static float Hand2HunterLastTime[MAXPLAYERS];
static Handle Hand2Medical[MAXPLAYERS];

void Rogue_Hand2_AbilityUse(int client, int weapon)
{
	if(Hand2Charger && i_WeaponArchetype[weapon] == Archetype_Charger)
	{
		Attributes_SetMulti(weapon, 6, 0.935);
	}

	if(Hand2Rapid && i_WeaponArchetype[weapon] == Archetype_Rapid)
	{
		DataPack pack = new DataPack();
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
			float extra = float(GetEntProp(victim, Prop_Data, "m_iHealth")) * 0.03;

			// Scale down with health scaling
			if(b_thisNpcIsARaid[victim])
			{
				extra = float(GetEntProp(victim, Prop_Data, "m_iHealth")) * 0.01;
				if(MultiGlobalHighHealthBoss)
					extra /= MultiGlobalHighHealthBoss;
			}
			else if(b_thisNpcIsABoss[victim])
			{
				extra = float(GetEntProp(victim, Prop_Data, "m_iHealth")) * 0.01;
				if(MultiGlobalHealthBoss)
					extra /= MultiGlobalHealthBoss;
			}
			else if(MultiGlobalHealth)
			{
				extra /= MultiGlobalHealth;
			}
			if((extra > (damage)))
			{
				extra = damage;
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

bool DontTriggerArtillery = false;
public void Rogue_Hand2Artillery_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(DontTriggerArtillery)
		return;
	
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Artillery)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			DataPack pack;
			CreateDataTimer(3.0, Rogue_Hand2Atillery_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(attacker));
			pack.WriteCell(EntIndexToEntRef(victim));
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteFloat(damage);
		}
	}
}

static Action Rogue_Hand2Atillery_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	int attacker = EntRefToEntIndex(pack.ReadCell());
	int victim = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damageDeal = pack.ReadFloat();
	if(IsClientInGame(attacker) && IsPlayerAlive(attacker) && IsEntityAlive(victim))
	{
		int WeaponDo = -1;
		if(IsValidEntity(weapon))
			WeaponDo = weapon;
		DontTriggerArtillery = true;
		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		SDKHooks_TakeDamage(victim, attacker, attacker, damageDeal , DMG_BLAST, WeaponDo, NULL_VECTOR, chargerPos);
		DontTriggerArtillery = false;
	}

	return Plugin_Stop;
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

public void Rogue_Hand2Tactician_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Tactician)
	{
		if(i_HasBeenHeadShotted[victim] && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			Building_GiveRewardsUse(attacker, attacker, 2);
		}
	}
}

public void Rogue_Hand2Hunter_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Hunter)
	{
		float time = GetGameTime() - Hand2HunterLastTime[attacker];
		if(time > 25.0)
			time = 25.0;
		
		damage += damage * (time / 5.0);
		
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			RequestFrame(RogueHand2HunterReset, attacker);
	}
}

static void RogueHand2HunterReset(int client)
{
	Hand2HunterLastTime[client] = GetGameTime();
}

public void Rogue_Hand2Drone_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Drone)
	{
		int count;
		int entity = -1;
		while((entity=FindEntityByClassname(entity, "zr_projectile_base")) != -1)
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == attacker)
				count++;
		}

		if(count > 8)
			count = 8;

		damage += damage * (count / 6.666667);
	}
}

public void Rogue_Hand2Lord_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if((damagetype & DMG_BLAST))
	{
		return;
	}
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Lord)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED) && !(GetURandomInt() % 4))
		{
			float fAng[3], fPos[3];
			GetClientEyeAngles(attacker, fAng);
			GetClientEyePosition(attacker, fPos);

			static const float speed = 1000.0;

			float fVel[3];
			GetAngleVectors(fAng, fVel, NULL_VECTOR, NULL_VECTOR);
			fVel[0] *= speed;
			fVel[1] *= speed;
			fVel[2] *= speed;

			int entity = CreateEntityByName("tf_projectile_spellfireball");
			if(IsValidEntity(entity))
			{
				SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", attacker);
				SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
				SetTeam(entity, GetTeam(attacker));
				TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
				DispatchSpawn(entity);
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
				SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(weapon));
				f_CustomGrenadeDamage[entity] = damage * 2.0;
			}
		}
	}
}

public void Rogue_Hand2Crusher_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Crusher)
	{
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			float firerate = Attributes_Get(weapon, 6);
			ApplyTempAttrib(weapon, 6, 0,952, firerate * 1.65);
		}
	}
}

public void Rogue_Hand2Combatant_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	if(attacker <= MaxClients && weapon != -1 && i_WeaponArchetype[weapon] == Archetype_Combatant)
	{
		float value = 0.25;
		if(!dieingstate[attacker] && !LastMann)
		{
			int maxhealth, health;
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsClientInGame(target) && GetClientTeam(target)==2 && TeutonType[target] != TEUTON_WAITING)
				{
					if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
					{
						int maxhp = dieingstate[target] ? 1000 : SDKCall_GetMaxHealth(target);
						maxhealth += maxhp;
						
						int hp = GetClientHealth(target);
						if(hp > maxhp)
							hp = maxhp;
						
						health += hp;
					}
					else
					{
						maxhealth += 1000;
					}
				}
			}
			
			if(maxhealth)
			{
				value = float(health) / float(maxhealth);
				if(value < 0.25)
					value = 0.25;
			}
		}

		damage /= value;
	}
}

public void Rogue_Hand2Medical_Weapon(int weapon, int client)
{
	if(i_WeaponArchetype[weapon] == Archetype_Medical)
	{
		delete Hand2Medical[client];

		DataPack pack;
		Hand2Medical[client] = CreateDataTimer(0.2, RogueHand2MedicalTimer, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

static Action RogueHand2MedicalTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				spawnRing(client, 800.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 100, 155, 100, 125, 1, 0.25, 6.0, 6.1, 1, _, true);
				
				float damage = Attributes_GetOnPlayer(client, 8, true, true);
				damage *= Attributes_Get(weapon, 8, 1.0);

				Explode_Logic_Custom(damage * 65.0, client, client, weapon, _, 400.0);
			}

			return Plugin_Continue;
		}
		
	}

	Hand2Medical[client] = null;
	return Plugin_Stop;
}

public void Rogue_Hand2Mechanic_Weapon(int weapon)
{
	if(i_WeaponArchetype[weapon] == Archetype_Mechanic)
		Attributes_SetMulti(weapon, 95, 1000.0);
}