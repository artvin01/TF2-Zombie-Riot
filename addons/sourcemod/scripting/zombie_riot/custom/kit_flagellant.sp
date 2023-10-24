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

static int DeathDoors[MAXTF2PLAYERS];
static int LastDeathDoor[MAXTF2PLAYERS];
static bool LastDeathDoorRaid[MAXTF2PLAYERS];

static int HealLevel[MAXTF2PLAYERS];
static int MeleeLevel[MAXTF2PLAYERS];

static float MoreMoreFor[MAXTF2PLAYERS];
static int MoreMoreHits[MAXTF2PLAYERS];
static int MoreMoreHealing[MAXTF2PLAYERS];
static int MoreMoreCap[MAXTF2PLAYERS];

static int LastSepsis[MAXTF2PLAYERS];
static bool LastSepsisRaid[MAXTF2PLAYERS];

void Flagellant_MapStart()
{
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
}

void Flagellant_Enable(int client, int weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_FLAGELLANT_MELEE:
		{
			MeleeLevel[client] = RoundFloat(Attributes_Get(weapon, 861, 0.0));
		}
		case WEAPON_FLAGELLANT_HEAL:
		{
			HealLevel[client] = RoundFloat(Attributes_Get(weapon, 861, 0.0));
			
			DataPack pack;
			CreateDataTimer(0.1, Flagellant_ThinkTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

void Flagellant_DoSwingTrace(int client)
{
	TriggerSelfDamage(client, 0.05);
}

void Flagellant_OnTakeDamage(int victim, float damage)
{
	if(damage > 5.0)
		MoreMoreHits[victim]++;
}

public Action Flagellant_ThinkTimer(Handle timer, DataPack pack)
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
				StartPlayerOnlyLagComp(client, true);
				b_LagCompAlliedPlayers = false;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client);
				int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos);
				FinishLagCompensation_Base_boss();
				EndPlayerOnlyLagComp(client);

				bool validEnemy;
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
					if(GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
					{
						if(!b_NpcIsInvulnerable[target])
							validEnemy = true;
					}
					else if(!Citizen_ThatIsDowned(target))
					{
						validAlly = true;
					}
				}

				static int color[4] = {50, 50, 50, 200};
				color[0] = validAlly ? 50 : 255;
				color[1] = validEnemy ? 50 : 255;

				if(validAlly || validEnemy)
					pos = GetAbsOrigin(target);
				
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

	Rogue_OnAbilityUse(weapon);
	Ability_Apply_Cooldown(client, slot, 44.0);

	ClientCommand(client, "playgamesound misc/halloween/spell_skeleton_horde_cast.wav");

	TF2_AddCondition(client, TFCond_MegaHeal, 8.25);
	MoreMoreFor[client] = GetGameTime() + 8.0;
	MoreMoreHits[client] = 0;
	MoreMoreCap[client] = 30 + (MeleeLevel[client] * 10) + (HealLevel[client] * 5);

	float ratio = 0.01 + (MeleeLevel[client] * 0.005) + (HealLevel[client] * 0.0025);

	MoreMoreHealing[client] = RoundToFloor(SDKCall_GetMaxHealth(client) * ratio);

	CreateTimer(0.3, Flagellant_MoreMoreTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");

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
			StartHealingTimer(client, 0.2, float(healing) / 20.0, 20);	// Over 4 seconds
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
	b_LagCompAlliedPlayers = false;
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos);
	FinishLagCompensation_Base_boss();
	EndPlayerOnlyLagComp(client);

	bool validEnemy;
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
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
		{
			if(!b_NpcIsInvulnerable[target])
				validEnemy = true;
		}
		else if(!b_NpcIsInvulnerable[target] && !Citizen_ThatIsDowned(target))
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
			maxhealth = GetEntProp(target, Prop_Data, "m_iMaxHealth");
		}
		else
		{
			health = GetEntProp(target, Prop_Send, "m_iHealth");
			maxhealth = SDKCall_GetMaxHealth(target);
		}
		
		if(health < maxhealth)
		{
			float multi = Attributes_GetOnWeapon(client, weapon, 8, true);
			
			float base = 25.0 + (HealLevel[client] * 7.5);
			float cost = 1.0 - (HealLevel[client] * 0.1);

			float healing = base * multi;
			float injured = float(maxhealth - health);
			if(healing > injured)
				healing = injured;
			
			float healthLost = healing / (1.0 + (multi / 2.0)) * cost;
			float healerHP = float(GetClientHealth(client) - 1);
			if(healthLost > healerHP)
			{
				healing *= healerHP / healthLost;
				healthLost = healerHP;
			}

			if(healing > 0.0 && healthLost > 0.0)
			{
				int BeamIndex = ConnectWithBeam(client, target, 100, 250, 100, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");

				CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
				
				StartHealingTimer(target, 0.1, healing / 20.0, 20);
				StartHealingTimer(client, 0.1, healthLost / -20.0, 20);
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

				if(target < MaxClients)
					ClientCommand(target, "playgamesound items/smallmedkit1.wav");

				Give_Assist_Points(target, client);

				float cooldown = healing / 30.0;
				if(cooldown < 2.0)
				{
					cooldown = 2.0;
				}
				else if(cooldown > 10.0)
				{
					cooldown = 10.0;
				}

				Ability_Apply_Cooldown(client, slot, 10.0);
				
				if(target > MaxClients)
				{
					PrintHintText(client, "You Healed %t for %.0f HP!, you gain a %.0f healing cooldown.", NPC_Names[i_NpcInternalId[target]], healing, cooldown);
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
			PrintHintText(client, "%t Is already at full hp.", NPC_Names[i_NpcInternalId[target]]);
		}
		else
		{
			PrintHintText(client, "%N Is already at full hp.", target);
		}
	}
	else if(validEnemy)
	{
		Rogue_OnAbilityUse(weapon);

		TriggerSelfDamage(client, 0.15);
		
		float multi = Attributes_GetOnWeapon(client, weapon, 8, true);

		int flags = i_ExplosiveProjectileHexArray[client];
		i_ExplosiveProjectileHexArray[client] = EP_DEALS_PLASMA_DAMAGE|EP_GIBS_REGARDLESS;
		Explode_Logic_Custom(300.0 * multi, client, client, weapon, pos, _, _, _, false, 3, false, _, Flagellant_AcidHitPost);
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
	float multi = Attributes_GetOnWeapon(attacker, weapon, 8, true);
	StartBleedingTimer(victim, attacker, multi * 4.0, HealLevel[attacker] > 1 ? 15 : 10, weapon, DMG_PLASMA);
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
	b_LagCompAlliedPlayers = false;
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos);
	FinishLagCompensation_Base_boss();
	EndPlayerOnlyLagComp(client);

	bool validEnemy;
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
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") != 2)
		{
			if(!b_NpcIsInvulnerable[target])
				validEnemy = true;
		}
		else if(!b_NpcIsInvulnerable[target])
		{
			validAlly = true;
		}
	}

	if(validAlly)
	{
		int healing = RoundToFloor(maxhealth * (HealLevel[client] > 1 ? 0.35 : 0.25));
		TriggerDeathDoor(client, healing);
		if(healing > 0)
		{
			StartHealingTimer(client, 0.1, healing / 20.0, 20);
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

		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
		float HealedAlly[3];
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", HealedAlly);
		HealedAlly[2] += 10.0;
		ParticleEffectAt(HealedAlly, "powerup_supernova_explode_red_spikes", 0.5);

		SeaSlider_AddNeuralDamage(target, client, 10, _, true);
		f_HussarBuff[target] = GetGameTime() + 10.0;

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
	}
	else if(validEnemy)
	{
		int round = Rogue_GetRoundScale();
		bool raid = IsValidEntity(EntRefToEntIndex(RaidBossActive));
		if(LastSepsis[client] != round || LastSepsisRaid[client] != raid)
		{
			LastSepsis[client] = round;
			LastSepsisRaid[client] = raid;
			
			Rogue_OnAbilityUse(weapon);

			int healing = RoundToFloor(maxhealth * (HealLevel[client] > 1 ? 0.5 : 0.35));
			TriggerDeathDoor(client, healing);
			if(healing > 0)
			{
				StartHealingTimer(client, 0.1, healing / 10.0, 10);
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
			
			float multi = Attributes_GetOnWeapon(client, weapon, 8, true);
			if(HealLevel[client] > 1)
				multi *= 1.2;
			
			f_NpcImmuneToBleed[target] = GetGameTime() + 0.6;
			float extra = BleedAmountCountStack[target] * 1000.0;

			SDKHooks_TakeDamage(target, client, client, (1000.0 * multi), DMG_PLASMA, weapon);
			SDKHooks_TakeDamage(target, client, client, extra, DMG_SLASH, weapon, _, _, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);

			ParticleEffectAt(pos, PARTICLE_JARATE, 2.0);
			Ability_Apply_Cooldown(client, slot, 25.0);
			ClientCommand(client, "playgamesound misc/halloween/merasmus_spell.wav");
			return;
		}

		ShowSyncHudText(client, SyncHud_Notifaction, "Sepsis will be ready after next wave");
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

static void TriggerSelfDamage(int client, float multi)
{
	int armor = Armor_Charge[client];
	int maxhealth = SDKCall_GetMaxHealth(client);
	Armor_Charge[client] = 0;
	SDKHooks_TakeDamage(client, 0, 0, maxhealth * multi, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
	Armor_Charge[client] = armor;
}

static void TriggerDeathDoor(int client, int &healing)
{
	if(dieingstate[client] > 0)
	{
		dieingstate[client] = 0;

		Store_ApplyAttribs(client);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
		int entity, i;
		while(TF2U_GetWearable(client, entity, i))
		{
			SetEntityRenderMode(entity, RENDER_NORMAL);
			SetEntityRenderColor(entity, 255, 255, 255, 255);
		}
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		SetEntityCollisionGroup(client, 5);
		DoOverlay(client, "");

		int health = 50;
		if(health > healing)
			health = healing;

		healing -= health;
		SetEntityHealth(client, health);
		ClientCommand(client, "playgamesound misc/halloween/strongman_bell_01.wav");

		int round = Rogue_GetRoundScale();
		bool raid = IsValidEntity(EntRefToEntIndex(RaidBossActive));
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
	}
}

static int GetClientPointVisiblePlayersNPCs(int iClient, float flDistance, float vecEndOrigin[3])
{
	float vecOrigin[3], vecAngles[3];
	GetClientEyePosition(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngles);
	
	Handle hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, Trace_ClientOrNPC, iClient);
	TR_GetEndPosition(vecEndOrigin, hTrace);
	
	int iReturn = -1;
	int iHit = TR_GetEntityIndex(hTrace);
	
	if (TR_DidHit(hTrace) && iHit != iClient && GetVectorDistance(vecOrigin, vecEndOrigin, true) < (flDistance * flDistance))
		iReturn = iHit;
	
	delete hTrace;
	return iReturn;
}

public bool Trace_ClientOrNPC(int entity, int mask, any data)
{
	if(entity == data)
		return false;
	
	if(entity <= MaxClients)
		return true;
	
	if(!b_NpcHasDied[entity])
		return true;
	
	return false;
}