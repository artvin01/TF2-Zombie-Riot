/*
	Skill 1
	Second swing - 1 ammo

	Skill 2
	Third swing - 1 ammo

	Skill 3
*/

#pragma semicolon 1
#pragma newdecls required

//i_WeaponAmmoAdjustable
static const int MaxAmmo = 30;			// From 12 in-game
static const int ExtraAmmo = 2;			// Ammo supply cost
static const float ChargeExtra = 10.0;	// Normal charge cooldown
static const float BurningDamage = 8.0;	// Burning damage (1 potency)

enum BurningThumbEnum
{
	NoMove = 0,

	Slash_1,
	Slash_2,
	Slash_3,

	Counter_2,

	Tanglecleaver_0,
	Tanglecleaver_1,
	Tanglecleaver_2,
	Tanglecleaver_3,

	Tigerslayer_0,
	Tigerslayer_1,
	Tigerslayer_2,
	Tigerslayer_3,
	Tigerslayer_4,
	Tigerslayer_5
}

static BurningThumbEnum LastMove[MAXPLAYERS+1];
static BurningThumbEnum CurrentMove[MAXPLAYERS+1];
static Handle ResetMove[MAXPLAYERS+1];
static int WeaponLevel[MAXPLAYERS+1];
static int AmmoSpent[MAXPLAYERS+1];
static int TotalSpent[MAXPLAYERS+1];
static bool ShinForm[MAXPLAYERS+1];
static bool ChargeSpent[MAXPLAYERS+1];

void BurningThumb_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		AmmoSpent[client] = 0;
		TotalSpent[client] = 0;
		ShinForm[client] = false;
	}
}

void BurningThumb_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BURNINGTHUMB)
	{
		CurrentMove[client] = NoMove;
		WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	}
}

public void Weapon_BurningThumb_M1(int client, int weapon, bool crit, int slot)
{
	delete ResetMove[client];

	bool final;
	float cooldown = 0.8;
	switch(LastMove[client])
	{
		case NoMove, Slash_3, Tanglecleaver_3, Tigerslayer_5:
		{
			// Slash1
			CurrentMove[client] = Slash_1;
		}
		case Slash_1:
		{
			if(ChargeSpent[client])
			{
				// Slash1 -> Charge -> Slash2
				CurrentMove[client] = Slash_2;
			}
			else if(GetClientButtons(client) & IN_DUCK)
			{
				// Slash1 -> Duck Counter
				CurrentMove[client] = Counter_2;
				cooldown = 1.2;
				final = true;
			}
			else
			{
				// Slash1 -> Miss/Hit -> Slash1
				CurrentMove[client] = Slash_1;
			}
		}
		case Slash_2:
		{
			if(ChargeSpent[client])
			{
				// Slash2 -> Charge -> Slash3
				CurrentMove[client] = Slash_3;
				cooldown = 1.2;
				final = true;
			}
			else if(CurrentMove[client] != Slash_2)
			{
				// Slash2 -> Hit -> Slash1
				CurrentMove[client] = Slash_1;
			}

			// Slash2 -> Miss -> Slash2
		}
		case Tanglecleaver_2:
		{
			CurrentMove[client] = Tanglecleaver_3;
			cooldown = 2.0;
			final = true;
		}
		case Tigerslayer_4:
		{
			CurrentMove[client] = Tigerslayer_5;
			cooldown = 2.0;
			final = true;
		}
		default:
		{
			CurrentMove[client]++;
			cooldown = 1.2;
		}
	}

	SetWeaponCooldown(client, cooldown);

	if(final)
	{
		LastMove[client] = NoMove;
	}
	else
	{
		cooldown += 1.5;
		LastMove[client] = CurrentMove[client];
	}

	ResetCombo(client, weapon, cooldown, (final || ChargeSpent[client]));
}

public void Weapon_BurningThumb_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0)
		return;

	if(!ResetMove[client])
	{
		// Must attack first
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Use a move first before charging!");
		return;
	}
	
	if(ChargeSpent[client])
	{
		// Already charged, hit next
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Already charged, hit an enemy!");
		return;
	}

	if(TotalWeaponAmmo(client, weapon) < 1)
	{
		// No charges left
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Not enough ammo!");
		return;
	}
	
	if(Ability_Check_Cooldown(client, 2) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, 2));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);

	// TODO: Charge Logic
	
	if(LastMove[client] != Tigerslayer_0 && LastMove[client] != Tigerslayer_1)
	{
		ChargeSpent[client] = true;
		SpendAmmo(client, weapon);
	}

	// Reset combo, apply charge cooldown
	TF2_AddCondition(client, TFCond_FocusBuff, 19.9);
	ResetCombo(client, weapon, 3.0, true);
}

public void Weapon_BurningThumb_R(int client, int weapon, bool crit, int slot)
{
	if(!ShinForm[client])
	{
		if((GetClientButtons(client) & IN_DUCK) || TotalWeaponAmmo(client, weapon) < 1)
		{
			Rogue_OnAbilityUse(client, weapon);
			return;
		}
	}
	
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	Rogue_OnAbilityUse(client, weapon);
	TF2_AddCondition(client, TFCond_CritOnKill, 19.9);
	Ability_Apply_Cooldown(client, 2, 0.0, weapon, true);
	ResetCombo(client, weapon, 5.0, false);

	if(ShinForm[client] && TotalWeaponAmmo(client, weapon) > 0)
	{
		LastMove[client] = Tigerslayer_0;
	}
	else
	{
		LastMove[client] = Tanglecleaver_0;
	}
}

void BurningThumb_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	bool resetCharge;

	switch(CurrentMove[attacker])
	{
		case Slash_2:
		{
			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 2 : 1);

				resetCharge = true;
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
		}
		case Slash_3:
		{
			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 2 : 1);

				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
		}
		case Tanglecleaver_1:
		{
			resetCharge = true;
			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		case Tanglecleaver_2:
		{
			resetCharge = true;

			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		case Tanglecleaver_3:
		{
			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		case Tigerslayer_1:
		{
			resetCharge = true;
		}
		case Tigerslayer_2:
		{
			resetCharge = true;
		}
		case Tigerslayer_3:
		{
			resetCharge = true;
			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		case Tigerslayer_4:
		{
			resetCharge = true;
			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		case Tigerslayer_5:
		{
			if(!ChargeSpent[attacker])
				SpendAmmo(attacker, weapon);
		}
		default:
		{
			resetCharge = true;
		}
	}

	if(resetCharge)
	{
		ChargeSpent[attacker] = false;
		TF2_RemoveCondition(attacker, TFCond_FocusBuff);
		Ability_Apply_Cooldown(attacker, 2, 0.0, weapon, true);
	}

	CurrentMove[attacker] = NoMove;
}

static void InflictBurnPotency(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
		potency += 2;
	
	float duration = 3.0 - (IgniteFor[victim] * 0.5);
	if(duration < 0.0)
		duration = 0.0;
	
	NPC_Ignite(victim, attacker, duration, weapon, potency * BurningDamage);
}

static void InflictBurnCount(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
		potency += 2;

	NPC_Ignite(victim, attacker, potency * 3.0, weapon, BurningDamage);
}

static void InflictTremorPotency(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	//if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
	//	potency += 2;
	
	ApplyStatusEffect(attacker, victim, "Tremor", 5.0);
	StatusEffects_TremorDebuffAdd(victim, potency);
}

static void InflictTremorCount(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	//if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
	//	potency += 2;
	
	float duration;
	if(HasSpecificBuff(victim, "Tremor", _, _, duration))
	{
		if(duration < 0.0)
			duration = 0.0;

		ApplyStatusEffect(attacker, victim, "Tremor", duration + (potency * 5.0));
	}
	else
	{
		ApplyStatusEffect(attacker, victim, "Tremor", 5.0);
		StatusEffects_TremorDebuffAdd(victim, 1);
	}
}

stock void InflictTremorBurst(int victim, int attacker, int decrease)
{
	char name[64];
	int amount = StatusEffects_TremorDebuffAdd(victim, -decrease, name);
	if(amount > 0)
	{
		Elemental_AddStaggerDamage(victim, attacker, amount * 100);

		if(StrContains(name, "Scorch", false) != -1)
		{
			int damage = 0;
			
			if(IgniteFor[victim] > 2)
			{
				IgniteFor[victim] -= 2;

				damage = RoundFloat(BurnDamage[victim] / BurningDamage / 65.0);
				if(damage > 99)
					damage = 99;
			}

			damage += amount;
			
			SDKHooks_TakeDamage(victim, attacker, attacker, damage * 50.0, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, .Zr_damage_custom = ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
		}
	}
}

static void SpendAmmo(int client, int weapon)
{
	int total = MaxAmmo;

	if(ShinForm[client])
	{
		total = total * 2 / 3;
		total -= AmmoSpent[client];
	}
	else
	{
		total -= AmmoSpent[client];
	}

	if(total < 1)
	{
		int type = i_WeaponAmmoAdjustable[weapon];
		if(type && type < Ammo_MAX)
		{
			int ammo = GetAmmo(client, type) - (AmmoData[type][1] * ExtraAmmo);
			CurrentAmmo[client][type] = ammo;
			SetAmmo(client, type, ammo);
		}
	}
}

static void ResetCombo(int client, int weapon, float cooldown, bool charge)
{
	delete ResetMove[client];
	ResetMove[client] = CreateTimer(cooldown, ResetMoveTimer, client);

	Ability_Apply_Cooldown(client, 1, cooldown, weapon, true);
	if(charge)
		Ability_Apply_Cooldown(client, 2, cooldown + ChargeExtra, weapon);
}

static Action ResetMoveTimer(Handle timer, int client)
{
	ResetMove[client] = null;
	LastMove[client] = NoMove;
	ChargeSpent[client] = false;

	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		TF2_RemoveCondition(client, TFCond_CritOnKill);
	}

	return Plugin_Continue;
}

static void SetWeaponCooldown(int weapon, float &cooldown)
{
	cooldown *= Attributes_Get(weapon, 6, 1.0);
	cooldown *= Attributes_Get(weapon, 396, 1.0);

	DataPack pack = new DataPack();
	RequestFrame(ApplyWeaponCooldown, pack);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloat(cooldown);
}

static void ApplyWeaponCooldown(DataPack pack)
{
	pack.Reset();

	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(weapon != -1)
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + pack.ReadFloat());

	delete pack;
}

static int TotalWeaponAmmo(int client, int weapon)
{
	int total = MaxAmmo;

	if(ShinForm[client] == ShinForm_Shin)
	{
		total = total * 2 / 3;
		total -= AmmoSpent[client];
	}
	else
	{
		total -= AmmoSpent[client];

		int type = i_WeaponAmmoAdjustable[weapon];
		if(type && type < Ammo_MAX)
			total += GetAmmo(client, type) / AmmoData[type][1] / ExtraAmmo;
	}

	return total;
}