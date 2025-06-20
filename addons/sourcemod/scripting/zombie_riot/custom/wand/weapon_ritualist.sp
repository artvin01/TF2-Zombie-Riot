#pragma semicolon 1
#pragma newdecls required

enum
{
	Ritualist_None = 0,
	Ritualist_Necrosis,
	Ritualist_Nervous
}

static int WeaponType[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS] = {-1, ...};
static Handle WeaponTimer[MAXTF2PLAYERS];

void Ritualist_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RITUALIST)
	{
		WeaponRef[client] = EntIndexToEntRef(weapon);
		WeaponType[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		if(!WeaponTimer[client])
			WeaponTimer[client] = CreateTimer(0.5, RitualistTimer, client, TIMER_REPEAT);
	}
}

public void Weapon_Ritualist_M1(int client, int weapon, bool &result, int slot)
{
	int cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(Current_Mana[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", cost);
	}
	else
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= cost;
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);

		float time = 750.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		switch(WeaponType[client])
		{
			case Ritualist_Necrosis:
			{
				EmitGameSoundToClient(client, "Player.HitSoundNotes", client);
			}
			case Ritualist_Nervous:
			{
				EmitSoundToAll("misc/halloween/spell_teleport.wav", client, _, 65, _, 0.45);
			}
			default:
			{
				EmitGameSoundToAll("xmas.jingle", client);
			}
		}

		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_RITUALIST, weapon, WeaponType[client] ? "eyeboss_projectile" : "drg_cow_rockettrail_normal");
	}
}

void Weapon_Ritualist_ProjectileTouch(int entity, int target)
{
	if(target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(owner != -1)
		{
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

			float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

			SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		
			switch(WeaponType[owner])
			{
				case Ritualist_Necrosis:
				{
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
				}
				case Ritualist_Nervous:
				{
					ApplyStatusEffect(owner, target, "Elemental Amplification", 0.5);
					Explode_Logic_Custom(f_WandDamage[entity] * 0.2, owner, entity, weapon, .FunctionToCallBeforeHit = NervousExplodeBefore);
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);

					//float pos[3];
					//GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					//ParticleEffectAt(pos, "halloween_ghost_smoke", 3.0);
				}
				default:
				{
					EmitGameSoundToAll("xmas.jingle", entity);
				}
			}
		}

		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(owner != -1)
		{
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			
			switch(WeaponType[owner])
			{
				case Ritualist_Necrosis:
				{
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
				}
				case Ritualist_Nervous:
				{
					Explode_Logic_Custom(f_WandDamage[entity] * 0.2, owner, owner, weapon, .FunctionToCallBeforeHit = NervousExplodeBefore);
					EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);

					//float pos[3];
					//GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					//ParticleEffectAt(pos, "halloween_ghost_smoke", 3.0);
				}
				default:
				{
					EmitGameSoundToAll("xmas.jingle", entity);
				}
			}
		}

		RemoveEntity(entity);
	}
}

static Action RitualistTimer(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(WeaponType[client] == Ritualist_Necrosis)
				{
					float damage = Attributes_Get(weapon, 410, 1.0) * 0.325;
					if(TF2_IsPlayerInCondition(client, TFCond_Taunting))
						damage *= 2.1538;
					
					Explode_Logic_Custom(damage, client, client, weapon, _, 600.0, .FunctionToCallBeforeHit = NecrosisExplodeBefore);
				}
			}

			return Plugin_Continue;
		}
		
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

void Ritualist_MinionExplode(int client, int entity)
{
	if(client < 1 || client > MaxClients)
		return;
	
	int weapon = EntRefToEntIndex(WeaponRef[client]);
	if(weapon != -1)
	{
		float damage = 130.0 * Attributes_Get(weapon, 410, 1.0);
		Explode_Logic_Custom(damage, client, entity, weapon, _, 300.0, .FunctionToCallBeforeHit = NecrosisBleedExplodeBefore);
	}
}

static float NervousExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, RoundFloat(damage * 10.0));
	damage = 0.0;
	return 0.0;
}

static float NecrosisExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Elemental Amplification", 1.1);
	Elemental_AddNecrosisDamage(victim, attacker, RoundFloat(damage * 10.0), weapon);
	damage = 0.0;
	return 0.0;
}

static float NecrosisBleedExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Maimed", 3.0);
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(victim));
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloat(damage);
	CreateTimer(0.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.5, Timer_NecrosisBleed, pack, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(3.0, Timer_NecrosisBleed, pack, TIMER_DATA_HNDL_CLOSE);

	damage = 0.0;
	return 0.0;
}

static Action Timer_NecrosisBleed(Handle timer, DataPack pack)
{
	pack.Reset();
	int victim = EntRefToEntIndex(pack.ReadCell());
	if(victim != -1)
	{
		int attacker = EntRefToEntIndex(pack.ReadCell());
		if(attacker != -1)
		{
			int weapon = EntRefToEntIndex(pack.ReadCell());
			if(weapon != -1)
			{
				float damage = pack.ReadFloat();
				SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_PLASMA, weapon);
				Elemental_AddNecrosisDamage(victim, attacker, RoundFloat(damage * 0.166667), weapon);
			}
		}
	}
	return Plugin_Continue;
}

public void Weapon_RitualistNecrosis_M2(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
	}
	else if(dieingstate[client] != 0 || (GetEntityFlags(client) & FL_ONGROUND) == 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
	else
	{
		Rogue_OnAbilityUse(client, weapon);

		Attributes_Set(client, 201, 0.2);
		FakeClientCommand(client, "taunt");

		Ability_Apply_Cooldown(client, slot, 140.0);
		EmitGameSoundToClient(client, "Fundraiser.PrayerBowl");

		ApplyTempAttrib(weapon, 410, 2.5, 20.0);
		ApplyTempAttrib(weapon, 6, 0.4, 20.0);
		ApplyStatusEffect(client, client, "Liberal Tango", 20.0);

		float pos1[3], pos2[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
		
		int count;
		for(int target = 1; target <= MaxClients; target++)
		{
			if(client != target && IsClientInGame(target) && IsPlayerAlive(target))
			{
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(pos1, pos2, true) < 40000.0)
				{
					i_ExtraPlayerPoints[client] += 10;

					int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
					if(entity != -1)
					{
						EmitGameSoundToClient(target, "Fundraiser.PrayerBowl", client);
						ApplyStatusEffect(client, target, "Liberal Tango", 20.0);
						
						if(++count > 2)
							break;
					}
				}
			}
		}
	}
}

public void Weapon_RitualistNervous_M2(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
	}
	else
	{
		Rogue_OnAbilityUse(client, weapon);

		Ability_Apply_Cooldown(client, slot, 70.0);
		ClientCommand(client, "playgamesound ambient/halloween/male_scream_06.wav");
		
		float pos1[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);

		int entity = NPC_CreateByName("npc_ritualist", client, pos1, {0.0, 0.0, 0.0}, TFTeam_Red);
		if(entity > MaxClients)
		{
			CreateTimer(65.0, Seaborn_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
			b_ShowNpcHealthbar[entity] = false;
		}
	}
}

void StatusEffects_Ritualist()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Liberal Tango");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♬");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.7;	// +30% res
	data.DamageDealMulti			= 0.3;	// +30% dmg
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= -1.0;
	StatusEffect_AddGlobal(data);
}