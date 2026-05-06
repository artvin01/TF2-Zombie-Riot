#pragma semicolon 1
#pragma newdecls required

static const int MaxAmmo = 18;			// From 12 in-limbus
static const int ExtraAmmo = 2;			// Ammo supply cost
static const float ChargeExtra = 10.0;	// Normal charge cooldown
static const float BurningDamage = 4.0;	// Burning damage (1 potency)
static const float TremorTime = 10.0;	// Tremor count time
static const int TremorStagger = 100;	// Stagger damage per Tremor
static const float ScorchDamage = 50.0;	// Damage per scorch stack

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
static bool HasCharged[MAXPLAYERS+1];

void BurningThumb_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(ShinForm[client])
		{
			RemoveSpecificBuff(client, "Shin - Tiantui Star");
			RemoveSpecificBuff(client, "Tiantui Star");
			RemoveSpecificBuff(client, "Overheat");
		}

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
		// TODO: Display ammo timer
	}
}

public void Weapon_BurningThumb_M1(int client, int weapon, bool crit, int slot)
{
	delete ResetMove[client];

	float cooldown = 0.5;
	switch(LastMove[client])
	{
		case NoMove:
		{
			// Slash1
			CurrentMove[client] = Slash_1;
		}
		case Slash_3, Tanglecleaver_3, Tigerslayer_5:
		{
			if(CurrentMove[client] != LastMove[client])
			{
				// X -> Hit -> Slash1
				CurrentMove[client] = Slash_1;
			}
			else
			{
				// X -> Miss -> X
				cooldown = 0.75;
			}
		}
		case Slash_1:
		{
			if(ChargeSpent[client])
			{
				// Slash1 -> Charge -> Slash2
				CurrentMove[client] = Slash_2;
			}
			else if(CurrentMove[client] != Slash_1)
			{
				// Slash1 -> Hit -> Counter
				CurrentMove[client] = Counter_2;
			}
			
			// Slash1 -> Miss -> Slash1
		}
		case Slash_2:
		{
			if(ChargeSpent[client])
			{
				// Slash2 -> Charge -> Slash3
				CurrentMove[client] = Slash_3;
				cooldown = 0.75;
			}
			else if(CurrentMove[client] != Slash_2)
			{
				// Slash2 -> Hit -> Slash1
				CurrentMove[client] = Slash_1;
			}

			// Slash2 -> Miss -> Slash2
		}
		case Counter_2:
		{
			if(ChargeSpent[client])
			{
				// Counter -> Charge -> Slash2
				CurrentMove[client] = Slash_2;
			}
			else
			{
				// Counter -> Hit/Miss -> Counter
				CurrentMove[client] = Slash_1;
			}
		}
		case Tanglecleaver_2:
		{
			CurrentMove[client] = Tanglecleaver_3;
			cooldown = 0.75;
		}
		case Tigerslayer_4:
		{
			CurrentMove[client] = Tigerslayer_5;
			cooldown = 0.75;
		}
		default:
		{
			CurrentMove[client] = ++LastMove[client];
			cooldown = 0.75;
		}
	}

	SetWeaponCooldown(client, cooldown);

	cooldown += 1.5;
	LastMove[client] = CurrentMove[client];
	ResetCombo(client, weapon, cooldown, false);
}

public void Weapon_BurningThumb_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0)
		return;
	
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

	if(LastMove[client] == NoMove)
	{
		LastMove[client] = Slash_1;
	}
	else if(LastMove[client] != Tigerslayer_0 && LastMove[client] != Tigerslayer_1)
	{
		ChargeSpent[client] = true;
		SpendAmmo(client, weapon);
	}

	// Reset combo, apply charge cooldown
	TF2_AddCondition(client, TFCond_FocusBuff, 19.9);
	HasCharged[client] = true;
	ResetCombo(client, weapon, 5.0, true);
}

public void Weapon_BurningThumb_R(int client, int weapon, bool crit, int slot)
{
	if(!ShinForm[client])
	{
		if((GetClientButtons(client) & IN_DUCK) || TotalWeaponAmmo(client, weapon) < 1)
		{
			Rogue_OnAbilityUse(client, weapon);

			ShinForm[client] = true;
			ApplyStatusEffect(client, client, TotalSpent[client] >= (MaxAmmo * 2 / 3) ? "Shin - Tiantui Star" : "Tiantui Star", 999.9);
			
			return;
		}
	}

	if(WeaponLevel[client] < 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");

		if(!ShinForm[client])
		{
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "Hold crouch to force a reload!");
		}

		return;
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
	// Offset the status effect nerf
	if(ShinForm[attacker])
		damage *= 2.0;
	
	bool resetCharge;
	int power = 6;

	switch(CurrentMove[attacker])
	{
		case Slash_2:
		{
			PrintToConsole(attacker, "Double Slash - Blast");

			power = WeaponLevel[attacker] > 1 ? 12 : 10;

			int bonus;
			if(WeaponLevel[attacker] > 0)
				bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 3 : 2);
			
			InflictTremorPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 2 : 1);

			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				if(WeaponLevel[attacker] > 0)
				{
					bonus += ShinForm[attacker] ? 2 : 1;
					if(WeaponLevel[attacker] > 2)
						damage *= ShinForm[attacker] ? 1.3 : 1.1;
				}
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 4 : 1);

				resetCharge = true;
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Slash_3:
		{
			PrintToConsole(attacker, "Triple Slash - Blast");

			power = WeaponLevel[attacker] > 1 ? 16 : 13;

			int bonus;
			if(WeaponLevel[attacker] > 0)
				bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 4 : 2);

			InflictTremorCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 2 : 1);
			
			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				if(WeaponLevel[attacker] > 0)
				{
					bonus += ShinForm[attacker] ? 2 : 1;
					if(WeaponLevel[attacker] > 2)
						damage *= ShinForm[attacker] ? 1.3 : 1.1;
				}
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 4 : 1);

				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			if(WeaponLevel[attacker] > 0)
				InflictTremorBurst(victim, attacker, 1, 3);
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Counter_2:
		{
			PrintToConsole(attacker, "I'm Burning Up.");

			// 10 - 15
			power = WeaponLevel[attacker] > 2 ? 13 : 10;
			int bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorCount(victim, attacker, weapon, 1);

			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tanglecleaver_1:
		{
			PrintToConsole(attacker, "Tanglecleaver I");

			// 8 - 11
			power = WeaponLevel[attacker] > 2 ? 9 : 8;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 3 : 2);

			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}

			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tanglecleaver_2:
		{
			PrintToConsole(attacker, "Tanglecleaver II");

			// 12 - 17
			power = WeaponLevel[attacker] > 2 ? 13 : 12;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 2;
			
			InflictTremorCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 3 : 2);
			
			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}

			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tanglecleaver_3:
		{
			PrintToConsole(attacker, "Tanglecleaver III");

			// 16 - 23
			power = WeaponLevel[attacker] > 2 ? 17 : 16;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 3;

			bool ammo = (ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0);
			if(ammo)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				damage *= WeaponLevel[attacker] > 2 ? 1.5 : 1.2;

				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			ConvertTremorType(victim, attacker, "Tremor - Scorch");

			int bursts = ammo ? (WeaponLevel[attacker] > 2 ? 3 : 2) : 1;
			for(int i; i < bursts; i++)
			{
				InflictTremorBurst(victim, attacker, 1);
			}
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 2.0;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, weapon, cooldown, true);
			TF2_RemoveCondition(attacker, TFCond_CritOnKill);
		}
		case Tigerslayer_1:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades I");

			// 5 - 8
			power = WeaponLevel[attacker] > 2 ? 6 : 5;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 3 : 2);

			resetCharge = true;
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tigerslayer_2:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades II");

			// 8 - 13
			power = WeaponLevel[attacker] > 2 ? 9 : 8;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 2;

			InflictTremorCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 3 : 2);

			resetCharge = true;
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tigerslayer_3:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades III");

			// 11 - 18
			power = WeaponLevel[attacker] > 2 ? 12 : 11;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 3;

			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tigerslayer_4:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades IV");

			// 14 - 23
			power = WeaponLevel[attacker] > 2 ? 15 : 14;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 4;

			if(ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
		case Tigerslayer_5:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades V");

			// 17 - 28
			power = WeaponLevel[attacker] > 2 ? 18 : 17;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1) * 5;

			bool ammo = (ChargeSpent[attacker] || TotalWeaponAmmo(attacker, weapon) > 0);
			if(ammo)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				if(!ChargeSpent[attacker])
					SpendAmmo(attacker, weapon);
			}
			
			ConvertTremorType(victim, attacker, "Tremor - Scorch");

			int bursts = ammo ? (WeaponLevel[attacker] > 2 ? 3 : 2) : 1;
			for(int i; i < bursts; i++)
			{
				InflictTremorBurst(victim, attacker, 1);
			}

			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 2.0;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, weapon, cooldown, true);
			TF2_RemoveCondition(attacker, TFCond_CritOnKill);
		}
		default:
		{
			PrintToConsole(attacker, "Single Slash - Blast");

			power = WeaponLevel[attacker] > 1 ? 8 : 7;

			int bonus;
			if(WeaponLevel[attacker] > 0)
			{
				bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 3 : 2);
				InflictTremorPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 2 : 1);
			}
			
			resetCharge = true;
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
	}
	
	damage *= float(power) / 7.0;

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
	PrintToConsole(attacker, "> Burn +%d", potency);
}

static void InflictBurnCount(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
		potency += 2;

	NPC_Ignite(victim, attacker, potency * 3.0, weapon, BurningDamage);
	PrintToConsole(attacker, "> Burn Extend +%d", potency);
}

stock void InflictTremorPotency(int victim, int attacker, int weapon, int value, const char[] name = "Tremor")
{
	int potency = value;

	if(HasSpecificBuff(attacker, "Shin - Tiantui Star"))
	{
		potency += 2;
	}
	else if(ShinForm[attacker])
	{
		potency++;
	}
	
	ApplyStatusEffect(attacker, victim, name, TremorTime);
	StatusEffects_TremorDebuffAdd(victim, potency, 0.0);

	if(attacker && attacker <= MaxClients)
	{
		PrintToConsole(attacker, "> Tremor +%d", potency);
		ClientCommand(attacker, (GetURandomInt() % 2) ? "playgamesound weapons/physcannon/energy_bounce1.wav" : "playgamesound weapons/physcannon/energy_bounce2.wav");
	}
}

stock void InflictTremorCount(int victim, int attacker, int weapon, int value, const char[] name = "Tremor")
{
	int potency = value;

	if(HasSpecificBuff(attacker, "Shin - Tiantui Star"))
	{
		potency += 2;
	}
	else if(ShinForm[attacker])
	{
		potency++;
	}
	
	ApplyStatusEffect(attacker, victim, name, TremorTime);
	StatusEffects_TremorDebuffAdd(victim, 0, (potency * TremorTime));

	if(attacker && attacker <= MaxClients)
	{
		PrintToConsole(attacker, "> Tremor Extend +%d", potency);
		ClientCommand(attacker, (GetURandomInt() % 2) ? "playgamesound weapons/physcannon/energy_bounce1.wav" : "playgamesound weapons/physcannon/energy_bounce2.wav");
	}
}

stock void InflictTremorBurst(int victim, int attacker, int decrease, int minrequire = 0)
{
	float timeleft;
	char name[64];
	int amount = StatusEffects_TremorDebuffGet(victim, timeleft, name);
	if(amount > 0 && timeleft >= (minrequire * TremorTime))
	{
		Elemental_AddStaggerDamage(victim, attacker, amount * TremorStagger);
		PrintToConsole(attacker, "> Tremor Burst x%d", name, amount);

		if(StrContains(name, "Scorch", false) != -1)
		{
			amount += BurnStacks(victim);
			SDKHooks_TakeDamage(victim, attacker, attacker, amount * ScorchDamage, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, .Zr_damage_custom = ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
			PrintToConsole(attacker, "> %s Burst x%d", name, amount);
		}

		if(decrease)
			StatusEffects_TremorDebuffAdd(victim, 0, -(decrease * TremorTime));
	}
}

stock void ConvertTremorType(int victim, int attacker, const char[] name)
{
	float timeleft;
	int amount = StatusEffects_TremorDebuffGet(victim, timeleft);
	if(amount > 0 && timeleft > 0.0)
	{
		ApplyStatusEffect(attacker, victim, name, TremorTime);
		PrintToConsole(attacker, "> Amplitude Conversion");
	}
}

static int BonusTremorBurn(int victim, int stackper, int maxbonus)
{
	int bonus = StatusEffects_TremorDebuffGet(victim) + BurnStacks(victim);

	bonus /= stackper;

	if(bonus > maxbonus)
		bonus = maxbonus;
	
	return bonus;
}

static int BurnStacks(int victim)
{
	int amount = 0;
	
	if(IgniteFor[victim] > 2)
	{
		IgniteFor[victim] -= 2;

		amount = RoundFloat(BurnDamage[victim] / 48.0);
		if(amount > 99)
			amount = 99;
	}

	return amount;
}

static void SpendAmmo(int client, int weapon)
{
	int total = MaxAmmo;

	if(ShinForm[client])
		total = total * 2 / 3;
	
	if(AmmoSpent[client] < total)
	{
		AmmoSpent[client]++;
	}
	else
	{
		int type = i_WeaponAmmoAdjustable[weapon];
		if(type && type < Ammo_MAX)
		{
			int ammo = GetAmmo(client, type) - (AmmoData[type][1] * ExtraAmmo);
			CurrentAmmo[client][type] = ammo;
			SetAmmo(client, type, ammo);
		}
	}

	TotalSpent[client]++;

	if(ShinForm[client])
	{
		if(AmmoSpent[client] >= total)
			ApplyStatusEffect(client, client, "Overheat", 999.9);
		
		if(TotalSpent[client] >= total)
			ApplyStatusEffect(client, client, "Shin - Tiantui Star", 999.9);
	}
}

static void ResetCombo(int client, int weapon, float cooldown, bool charge)
{
	delete ResetMove[client];
	ResetMove[client] = CreateTimer(cooldown, ResetMoveTimer, client);

	Ability_Apply_Cooldown(client, 1, cooldown, weapon, true);
	if(charge)
	{
		if(HasCharged[client])
		{
			Ability_Apply_Cooldown(client, 2, cooldown + ChargeExtra, weapon);
		}
		else
		{
			Ability_Apply_Cooldown(client, 2, cooldown, weapon, true);
		}
	}
}

static Action ResetMoveTimer(Handle timer, int client)
{
	ResetMove[client] = null;
	LastMove[client] = NoMove;
	ChargeSpent[client] = false;
	HasCharged[client] = false;

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

	if(ShinForm[client])
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