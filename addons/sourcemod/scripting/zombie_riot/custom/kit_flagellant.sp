#pragma semicolon 1
#pragma newdecls required

/*
Passives:
Fester - Passively nearby enemies will always gib
Suffer - Passively steal nearby bleed/afterburn from allies

Melee:
Punish - Melee attack, bleed, self damage
More! MORE! - M2 that every hit (up to X) gives healing after the ability ends

Healer:
Deathless - M1 on Ally that heals
Lash's Gift - M2 on Ally that buffs
Acid Rain - M1 on Enemy with small AOE and bleed
Sepsis - M2 on Enemy with big damage, self heal, requires <50% HP, 1 use per wave, bleed tick rate sped up
*/

static int LaserIndex;

static int DeathDoors[MAXPLAYERS];
static int LastDeathDoor[MAXPLAYERS];
static bool LastDeathDoorRaid[MAXPLAYERS];

static int HealLevel[MAXPLAYERS];
static int MeleeLevel[MAXPLAYERS];

static float MoreMoreFor[MAXPLAYERS];
static int MoreMoreHits[MAXPLAYERS];
static int MoreMoreHealing[MAXPLAYERS];
static int MoreMoreCap[MAXPLAYERS];

static int ParticleRef[MAXPLAYERS] = {-1, ...};
static Handle EffectTimer[MAXPLAYERS];
static bool Precached = false;

#define FLAGGELANT_BASE_HEAL 40.0
#define FLAGGELANT_GLOBAL_HP_NERF 0.8
void Flagellant_MapStart()
{
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Precached = false;
}

void PrecacheSharedDarkestMusic()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/flaggilant_lastman.mp3",_,1);
		if(!FileNetwork_Enabled())
		{
			AddToDownloadsTable("materials/zombie_riot/overlays/leper_overlay.vtf");
			AddToDownloadsTable("materials/zombie_riot/overlays/leper_overlay.vmt");
		}
		Precached = true;
	}
}
void Flagellant_Enable(int client, int weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_FLAGELLANT_MELEE:
		{
			MeleeLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
			PrecacheSharedDarkestMusic();
			delete EffectTimer[client];
			EffectTimer[client] = CreateTimer(0.5, Flagellant_EffectTimer, client, TIMER_REPEAT);
		}
		case WEAPON_FLAGELLANT_HEAL:
		{
			HealLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
			
			DataPack pack;
			CreateDataTimer(0.1, Flagellant_HealerTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		case WEAPON_FLAGELLANT_DAMAGE:
		{
			DataPack pack;
			CreateDataTimer(0.1, Flagellant_DamagerTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

bool IsFlaggilant(int client)
{
	if(EffectTimer[client] != null)
		return true;

	return false;
}
void Flagellant_MiniBossChance(int &chance)
{
	return;
	/*
	if(chance > 0)
	{
		int count;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == TFTeam_Red)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon != -1)
				{
					switch(i_CustomWeaponEquipLogic[weapon])
					{
						case WEAPON_FLAGELLANT_MELEE, WEAPON_FLAGELLANT_HEAL, WEAPON_FLAGELLANT_DAMAGE:
						{
							count++;
						}
					}
				}
			}
		}

		if(count)
		{
			int players = CountPlayersOnRed();
			if(players < 4)
				players = 4;

			// Up to 5 extra chance
			static float remainer;
			float multi = (count * 5.0 / float(players)) + remainer;

			while(multi > 1.0 && chance > 0)
			{
				multi -= 1.0;
				chance--;
			}

			remainer = multi;
		}
	}
	*/
}

public Action Flagellant_EffectTimer(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1 && IsPlayerAlive(client))
		{
			switch(i_CustomWeaponEquipLogic[weapon])
			{
				case WEAPON_FLAGELLANT_MELEE, WEAPON_FLAGELLANT_HEAL, WEAPON_FLAGELLANT_DAMAGE:
				{
					if(ParticleRef[client] == -1)
					{
						float pos[3]; GetClientAbsOrigin(client, pos);
						pos[2] += 1.0;

						int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_green", -1.0);
						if(entity > MaxClients)
						{
							SetParent(client, entity);
							ParticleRef[client] = EntIndexToEntRef(entity);
						}
					}
					ApplyRapidSuturing(client);
					ApplyStatusEffect(client, client, "Thick Blood", 0.6);
					
					if(LastMann)
					{
						float maxhealth = 1.0;
						float health = float(GetEntProp(client, Prop_Data, "m_iHealth"));
						maxhealth = float(ReturnEntityMaxHealth(client));

						if(health >= maxhealth * 0.2)
						{
							ApplyStatusEffect(client, client, "Infinite Will", 3.0);
							ApplyStatusEffect(client, client, "Flagellants Punishment", 10.0);
						}
						else
						{
							for(int LoopClient = 1; LoopClient <= MaxClients; LoopClient++)
							{
								if(IsClientInGame(LoopClient) && IsPlayerAlive(LoopClient))
								{
									ApplyStatusEffect(LoopClient, LoopClient, "Death is comming.", 1.0);
								}
							}
						}
					}
					
					return Plugin_Continue;
				}
			}
		}
		
		if(ParticleRef[client] != -1)
		{
			int entity = EntRefToEntIndex(ParticleRef[client]);
			if(entity > MaxClients)
			{
				TeleportEntity(entity, OFF_THE_MAP);
				RemoveEntity(entity);
			}

			ParticleRef[client] = -1;
		}

		return Plugin_Continue;
	}
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}

	EffectTimer[client] = null;
	return Plugin_Stop;
}

void Flagellant_DoSwingTrace(int client)
{
	TriggerSelfDamage(client, 0.005);
}

void Flagellant_OnTakeDamage(int victim)
{
	//dont gain power from bleed or burns, otherwise itll be abit op, inturn we allow damages below 5!
	if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		MoreMoreHits[victim]++;

	//if(damage > 5.0)
}

public Action Flagellant_HealerTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
			{
				if(LastMann)
					return Plugin_Continue;

				float pos[3];
				StartPlayerOnlyLagComp(client, true);
				int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
				EndPlayerOnlyLagComp(client);

				bool validAlly;

				if(target < 1)
				{

				}
				else if(target <= MaxClients)
				{
					if(dieingstate[target] < 1 && TeutonType[target] == TEUTON_NONE)
						validAlly = true;
				}
				else if(!b_NpcHasDied[target])
				{
					if(GetTeam(target) == 2 && !Citizen_ThatIsDowned(target))
					{
						validAlly = true;
					}
				}

				static int color[4] = {50, 255, 50, 200};
				color[0] = validAlly ? 50 : 200;

				if(validAlly)
					GetAbsOrigin(target, pos );
				
				pos[2] += 10.0;

				TE_SetupBeamRingPoint(pos, 100.0, 101.0, LaserIndex, LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
				TE_SendToClient(client);
			}

			return Plugin_Continue;
		}
	}
	
	return Plugin_Stop;
}

public Action Flagellant_DamagerTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
			{
				float pos[3];
				b_LagCompNPC_No_Layers = true;
				b_LagCompNPC_OnlyAllies = false;
				StartLagCompensation_Base_Boss(client);
				int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, true);
				FinishLagCompensation_Base_boss();

				bool validEnemy;

				if(target < 1)
				{

				}
				else if(!b_NpcHasDied[target])
				{
					if(GetTeam(target) != 2)
					{
						if(!b_NpcIsInvulnerable[target])
							validEnemy = true;
					}
				}

				static int color[4] = {255, 50, 50, 200};
				color[1] = validEnemy ? 50 : 200;

				if(validEnemy)
					GetAbsOrigin(target, pos );
				
				pos[2] += 10.0;

				TE_SetupBeamRingPoint(pos, 100.0, 101.0, LaserIndex, LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
				TE_SendToClient(client);
			}

			return Plugin_Continue;
		}
	}
	
	return Plugin_Stop;
}

public void Weapon_FlagellantMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 44.0);

	ClientCommand(client, "playgamesound misc/halloween/spell_skeleton_horde_cast.wav");

	TF2_AddCondition(client, TFCond_MegaHeal, 8.25);
	ApplyStatusEffect(client, client, "Fluid Movement", 8.25);	
	MoreMoreFor[client] = GetGameTime() + 8.0;
	MoreMoreHits[client] = 0;
	MoreMoreCap[client] = 30 + (MeleeLevel[client] * 10) + (HealLevel[client] * 5);

	MoreMoreCap[client] = RoundToNearest(float(MoreMoreCap[client]) * FLAGGELANT_GLOBAL_HP_NERF);

	float ratio = 0.01 + (MeleeLevel[client] * 0.005) + (HealLevel[client] * 0.0025);

	MoreMoreHealing[client] = RoundToFloor(SDKCall_GetMaxHealth(client) * ratio);

	CreateTimer(0.55, Flagellant_MoreMoreTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Flagellant_MoreMoreTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && TeutonType[client] == TEUTON_NONE && IsPlayerAlive(client))
	{
		float time = MoreMoreFor[client] - GetGameTime();

		if(MoreMoreHits[client] > MoreMoreCap[client])
			MoreMoreHits[client] = MoreMoreCap[client];
		
		int healing = MoreMoreHits[client] * MoreMoreHealing[client];

		PrintHintText(client, "More! MORE! | %ds | +%d HP", RoundToCeil(time), healing);
		

		if(time >= 0.0)
			return Plugin_Continue;
		
		TF2_RemoveCondition(client, TFCond_MegaHeal);

		if(healing > 0)
		{
			ClientCommand(client, "playgamesound misc/halloween/spell_skeleton_horde_rise.wav");

			DataPack pack;
			CreateDataTimer(1.8, Flagellant_MoreFinishTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(userid);
			pack.WriteCell(healing);
		}
	}
	return Plugin_Stop;
}

public Action Flagellant_MoreFinishTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client && TeutonType[client] == TEUTON_NONE && IsPlayerAlive(client))
	{
		int healing = pack.ReadCell();

		TriggerDeathDoor(client, healing);

		if(healing > 0)
		{
			float HealedAlly[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", HealedAlly);
			HealedAlly[2] += 70.0;
			float HealedAllyRand[3];
			for(int Repeat; Repeat < 20; Repeat++)
			{
				HealedAllyRand = HealedAlly;
				HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
				TE_Particle("healthgained_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
			}
			HealEntityGlobal(client, client, float(healing), _, 4.0, _);
		}
	}
	return Plugin_Stop;
}

public void Weapon_FlagellantHealing_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	b_LagCompNPC_No_Layers = true;
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
	EndPlayerOnlyLagComp(client);

	bool validAlly;

	//in lastman, target self
	if(LastMann)
		target = client;
		
	if(target < 1)
	{

	}
	else if(target <= MaxClients)
	{
		if(dieingstate[target] < 1 && TeutonType[target] == TEUTON_NONE)
			validAlly = true;
	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) == 2 && !b_NpcIsInvulnerable[target] && !Citizen_ThatIsDowned(target))
		{
			validAlly = true;
		}
	}

	if(validAlly)
	{
		int health, maxhealth;
		if(target > MaxClients)
		{
			health = GetEntProp(target, Prop_Data, "m_iHealth");
			maxhealth = ReturnEntityMaxHealth(target);
		}
		else
		{
			health = GetEntProp(target, Prop_Send, "m_iHealth");
			maxhealth = SDKCall_GetMaxHealth(target);
		}
		
		if(health < maxhealth)
		{
			float multi = Attributes_Get(weapon, 2, 1.0);
			multi *= Attributes_GetOnWeapon(client, weapon, 8, true);
			
			float base = FLAGGELANT_BASE_HEAL + (HealLevel[client] * 7.5);
			float cost = 1.0 - (HealLevel[client] * 0.1);

			base *= FLAGGELANT_GLOBAL_HP_NERF;
			cost *= FLAGGELANT_GLOBAL_HP_NERF;

			float healing = base * multi;
			float injured = float(maxhealth - health);
			if(healing > injured)
				healing = injured;
			
			float healthLost = healing / (1.0 + (multi / 10.0)) * cost;
			float healerHP = float(GetClientHealth(client) - 1);
			if(healthLost > healerHP)
			{
				healing *= healerHP / healthLost;
				healthLost = healerHP;
			}

			if(healing > 0.0 && healthLost > 0.0)
			{
				int BeamIndex = ConnectWithBeam(client, target, 100, 250, 100, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
				SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);

				CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
				
				HealEntityGlobal(client, target, healing, 1.0, 2.0, _);
				HealEntityGlobal(client, client, healthLost, 1.0, 2.0, _);
				MoreMoreHits[client] += 10;
				float HealedAlly[3];
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", HealedAlly);
				HealedAlly[2] += 70.0;
				float HealedAllyRand[3];
				for(int Repeat; Repeat < 10; Repeat++)
				{
					HealedAllyRand = HealedAlly;
					HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
					HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
					HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
					TE_Particle("healthgained_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
				}
				
				ClientCommand(client, "playgamesound player/invuln_off_vaccinator.wav");

				if(target <= MaxClients)
					ClientCommand(target, "playgamesound items/smallmedkit1.wav");
				
				float cooldown = (healing / multi) / 15.0;
				cooldown *= 2.0;
				if(cooldown < 8.0)
				{
					cooldown = 8.0;
				}
				else if(cooldown > 15.0)
				{
					cooldown = 15.0;
				}

				Ability_Apply_Cooldown(client, slot, cooldown);
				
				if(target > MaxClients)
				{
					PrintHintText(client, "You Healed Ally for %.0f HP!, you gain a %.0f healing cooldown.", healing, cooldown);
				}
				else
				{
					PrintHintText(client, "You Healed %N for %.0f HP!, you gain a %.0f healing cooldown.", target, healing, cooldown);
				}
				return;
			}
		}
		else if(target > MaxClients)
		{
			PrintHintText(client, "Ally Is already at full hp.");
		}
		else
		{
			PrintHintText(client, "%N Is already at full hp.", target);
		}
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_FlagellantDamage_M1(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, true);
	FinishLagCompensation_Base_boss();

	bool validEnemy;

	if(target < 1)
	{

	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) != 2)
		{
			if(!b_NpcIsInvulnerable[target])
				validEnemy = true;
		}
	}

	if(validEnemy)
	{
		Rogue_OnAbilityUse(client, weapon);

		TriggerSelfDamage(client, 0.025);
		
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		float multi = Attributes_Get(weapon, 2, 1.0);
		multi *= Attributes_GetOnWeapon(client, weapon, 8, true);

		int flags = i_ExplosiveProjectileHexArray[client];
		i_ExplosiveProjectileHexArray[client] = EP_DEALS_PLASMA_DAMAGE|EP_GIBS_REGARDLESS;
		Explode_Logic_Custom(600.0 * multi, client, client, secondary, pos, _, _, _, false, 4, false, _, Flagellant_AcidHitPost);
		pos[2] += 5.0;
		ParticleEffectAt(pos, "bombinomicon_burningdebris", 0.5);

		i_ExplosiveProjectileHexArray[client] = flags;

		ParticleEffectAt(pos, PARTICLE_JARATE, 2.0);
		
		Ability_Apply_Cooldown(client, slot, 5.0);

		ClientCommand(client, "playgamesound items/pumpkin_explode%d.wav", 1 + (GetURandomInt() % 3));
		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Flagellant_AcidHitPost(int attacker, int victim, float damage, int weapon)
{
	float multi = Attributes_Get(weapon, 2, 1.0);
	multi *= 2.0;
	StartBleedingTimer(victim, attacker, multi, HealLevel[attacker] > 1 ? 40 : 30, weapon, DMG_PLASMA);
	StartBleedingTimer(victim, attacker, multi, HealLevel[attacker] > 1 ? 40 : 30, weapon, DMG_PLASMA);
}

public void Weapon_FlagellantHealing_M2(int client, int weapon, bool crit, int slot)
{
	int health = GetClientHealth(client);
	int maxhealth = SDKCall_GetMaxHealth(client);
	if(health > maxhealth / 2 && !dieingstate[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Must be below half health");
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
		
	b_LagCompNPC_No_Layers = true;
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
	EndPlayerOnlyLagComp(client);

	//in lastman, target self
	if(LastMann)
		target = client;

	bool validAlly;

	if(target < 1)
	{

	}
	else if(target <= MaxClients)
	{
		if(TeutonType[target] == TEUTON_NONE)
			validAlly = true;
	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) == 2 && !b_NpcIsInvulnerable[target])
		{
			validAlly = true;
		}
	}

	if(target > 0 && Elemental_GoingCritical(target))
		validAlly = false;

	if(validAlly)
	{
		int healing = RoundToFloor(maxhealth * (HealLevel[client] > 1 ? 0.35 : 0.25));
		healing = RoundToNearest(float(healing) * FLAGGELANT_GLOBAL_HP_NERF);
		TriggerDeathDoor(client, healing);
		if(healing > 0)
		{
			HealEntityGlobal(client, client, float(healing), 1.0, 2.0, _);
			float HealedAlly[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", HealedAlly);
			HealedAlly[2] += 70.0;
			float HealedAllyRand[3];
			for(int Repeat; Repeat < 10; Repeat++)
			{
				HealedAllyRand = HealedAlly;
				HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
				TE_Particle("healthgained_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
			}
		}

		ClientCommand(client, "playgamesound misc/halloween/merasmus_stun.wav");
		ClientCommand(client, "playgamesound misc/halloween/merasmus_stun.wav");
		
		int BeamIndex = ConnectWithBeam(client, target, 100, 250, 100, 8.0, 8.0, 1.85, "sprites/laserbeam.vmt");
		SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);

		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
		float HealedAlly[3];
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", HealedAlly);
		HealedAlly[2] += 10.0;
		ParticleEffectAt(HealedAlly, "powerup_supernova_explode_red_spikes", 0.5);

		Elemental_AddChaosDamage(target, client, 10, _, true);
		ApplyStatusEffect(client, target, "Flagellants Punishment", 10.0);

		if(target > MaxClients)
		{
			i_ExtraPlayerPoints[client] += 5;
		}
		else
		{
			i_ExtraPlayerPoints[client] += 10;

			int entity = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
			if(entity != -1)
			{
				ApplyTempAttrib(entity, 6, 0.9, 10.0);
				ApplyTempAttrib(entity, 97, 0.9, 10.0);
				ApplyTempAttrib(entity, 733, 0.9, 10.0);
			}

			if(HealLevel[client] > 1)
				TF2_AddCondition(target, TFCond_UberchargedCanteen, 1.5);

			ClientCommand(target, "playgamesound misc/halloween/merasmus_stun.wav");
			ClientCommand(target, "playgamesound misc/halloween/merasmus_stun.wav");
		}
		
		Ability_Apply_Cooldown(client, slot, 25.0);
		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

public void Weapon_FlagellantDamage_M2(int client, int weapon, bool crit, int slot)
{
	int health = GetClientHealth(client);
	int maxhealth = SDKCall_GetMaxHealth(client);
	if(CvarInfiniteCash.BoolValue)
		health = 0;

	if(health > maxhealth / 2 && !dieingstate[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Must be below half health");
		return;
	}

	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	b_LagCompNPC_No_Layers = true;
	b_LagCompNPC_OnlyAllies = false;
	StartLagCompensation_Base_Boss(client);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, true);
	FinishLagCompensation_Base_boss();

	bool validEnemy;

	if(target < 1)
	{

	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) != 2)
		{
			if(!b_NpcIsInvulnerable[target])
				validEnemy = true;
		}
	}

	if(validEnemy)
	{
		Rogue_OnAbilityUse(client, weapon);

		int healing = RoundToFloor(maxhealth * (HealLevel[client] > 1 ? 0.5 : 0.35));
		healing = RoundToNearest(float(healing) * FLAGGELANT_GLOBAL_HP_NERF);
		TriggerDeathDoor(client, healing);
		if(healing > 0)
		{
			HealEntityGlobal(client, client, float(healing), 1.0, 1.0, _);
			float HealedAlly[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", HealedAlly);
			HealedAlly[2] += 70.0;
			float HealedAllyRand[3];
			for(int Repeat; Repeat < 20; Repeat++)
			{
				HealedAllyRand = HealedAlly;
				HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
				HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
				TE_Particle("healthgained_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
			}
		}
		
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		float multi = Attributes_Get(weapon, 2, 1.0);
		multi *= Attributes_GetOnWeapon(client, weapon, 8, true);
		if(HealLevel[client] > 1)
			multi *= 1.2;
		
		int bleed = BleedAmountCountStack[target];
		if(bleed > 20)
			bleed = 20;
		
		float extra = bleed * 100.0 * multi;
		//ApplyRapidSuturing(target);
		
		SDKHooks_TakeDamage(target, client, client, (1600.0 * multi), DMG_PLASMA, secondary);
		if(extra)
			SDKHooks_TakeDamage(target, client, client, extra, DMG_TRUEDAMAGE, secondary, _, _, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);

		if(bleed == 20)
			DisplayCritAboveNpc(target, client, true);

		ParticleEffectAt(pos, PARTICLE_JARATE, 2.0);
		if(!CvarInfiniteCash.BoolValue)
			Ability_Apply_Cooldown(client, slot, 50.0);

		ClientCommand(client, "playgamesound misc/halloween/merasmus_spell.wav");
		
		int BeamIndex = ConnectWithBeam(target, client, 100, 200, 100, 12.0, 3.0, 1.0, "sprites/physbeam.vmt");
		SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);

		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);

		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

static void TriggerSelfDamage(int client, float multi)
{
	int armor = Armor_Charge[client];
	int maxhealth = SDKCall_GetMaxHealth(client);
	Armor_Charge[client] = 0;
	float damage = float(maxhealth) * multi;
	if(damage <= 1.0)
	{
		damage = 1.0;
	}
	SDKHooks_TakeDamage(client, 0, 0, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
	Armor_Charge[client] = armor;
}

static void TriggerDeathDoor(int client, int &healing)
{
	if(dieingstate[client] > 0)
	{
		dieingstate[client] = 0;
		i_CurrentEquippedPerk[client] = i_CurrentEquippedPerkPreviously[client];
		ForcePlayerCrouch(client, false);
		Store_ApplyAttribs(client);
		SDKCall_SetSpeed(client);
		int entity, i;
		while(TF2U_GetWearable(client, entity, i))
		{
			if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;

			SetEntityRenderMode(entity, RENDER_NORMAL);
			SetEntityRenderColor(entity, 255, 255, 255, 255);
		}
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		SetEntityCollisionGroup(client, 5);
		DoOverlay(client, "", 2);
		SetEntityMoveType(client, MOVETYPE_WALK);

		int health = 50;
		if(health > healing)
			health = healing;

		healing -= health;
		SetEntityHealth(client, health);
		ClientCommand(client, "playgamesound misc/halloween/strongman_bell_01.wav");

		int round = Waves_GetRoundScale();
		bool raid = RaidbossIgnoreBuildingsLogic(1);
		GiveCompleteInvul(client, 1.5);
		if(LastDeathDoor[client] != round || LastDeathDoorRaid[client] != raid)
		{
			DeathDoors[client] = 2;
			LastDeathDoor[client] = round;
			LastDeathDoorRaid[client] = raid;
		}

		if(DeathDoors[client] > 0)
		{
			DeathDoors[client]--;
			i_AmountDowned[client]--;
		}
		CheckLastMannStanding(0);
	}
}

int GetClientPointVisiblePlayersNPCs(int iClient, float flDistance, float vecEndOrigin[3], bool enemy)
{
	float vecOrigin[3], vecAngles[3];
	GetClientEyePosition(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngles);
	
	Handle hTrace;
	if(enemy)
		hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, Trace_ClientOrNPCEnemy, iClient);
	else
		hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, Trace_ClientOrNPCAlly, iClient);
	
	TR_GetEndPosition(vecEndOrigin, hTrace);
	
	int iReturn = -1;
	int iHit = TR_GetEntityIndex(hTrace);
	
	if (TR_DidHit(hTrace) && iHit != iClient && GetVectorDistance(vecOrigin, vecEndOrigin, true) < (flDistance * flDistance))
		iReturn = iHit;
	
	delete hTrace;
	return iReturn;
}

public bool Trace_ClientOrNPCEnemy(int entity, int mask, any data)
{
	if(entity == data)
		return false;
	
	if(entity <= MaxClients)
	{
		if(IsValidEnemy(data, entity, true, true))
			return true;
	}
	
	if(!b_NpcHasDied[entity])
	{
		if(IsValidEnemy(data, entity, true, true))
			return true;
	}
	
	return false;
}

public bool Trace_ClientOrNPCAlly(int entity, int mask, any data)
{
	if(entity == data)
		return false;
	
	if(entity <= MaxClients)
	{
		if(IsValidAlly(data, entity))
			return true;
	}
	
	if(!b_NpcHasDied[entity])
	{
		if(IsValidAlly(data, entity))
			return true;
	}
	
	return false;
}