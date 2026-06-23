#pragma semicolon 1
#pragma newdecls required

static const int MaxAmmo = 12;				// From 12 in-limbus
static const int ExtraAmmo = 4;				// Ammo supply cost
static const float ChargeExtra = 15.0;		// Normal charge cooldown
static const float BurningDamage = 8.0;		// Burning damage (1 potency)
static const float BurningTime = 3.0;		// Burning duration (1 count)
static const float TremorTime = 10.0;		// Tremor count time
static const int TremorStagger = 1000;		// Stagger damage per Tremor (up to x99)
static const float ScorchDamage = 500.0;	// Damage per scorch stack (up to x198)
static const float RCooldown = 45.0;		// R ability cooldown

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

static int WeaponStore;
static BurningThumbEnum LastMove[MAXPLAYERS+1];
static Handle ResetMove[MAXPLAYERS+1];
static Handle WeaponTimer[MAXPLAYERS+1];
static int WeaponLevel[MAXPLAYERS+1];
static int AmmoSpent[MAXPLAYERS+1];
static int TotalSpent[MAXPLAYERS+1];
static bool ShinForm[MAXPLAYERS+1];
static int ChargeSpent[MAXPLAYERS+1];
static float HasCharged[MAXPLAYERS+1];
static int PlayerChargeParticle[MAXPLAYERS+1];
static float InCharge[MAXPLAYERS+1];

#define BURN_DASH_SOUND_AMMO 	"weapons/dragons_fury_shoot.wav"
#define BURN_DASH_SOUND_EMPTY	"weapons/fx/nearmiss/dragons_fury_nearmiss.wav"

static char g_BurnShootsound[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};
public void BurningThumb_MapStart()
{
	PrecacheSound(BURN_DASH_SOUND_AMMO);
	PrecacheSound(BURN_DASH_SOUND_EMPTY);
	PrecacheSoundArray(g_BurnShootsound);
	Zero(InCharge);
}
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

public void BurningThumb_Enable(int client, int weapon)
{
	LastMove[client] = NoMove;
	WeaponStore = StoreWeapon[weapon];
	WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	
	delete WeaponTimer[client];

	DataPack pack;
	WeaponTimer[client] = CreateDataTimer(2.0, UpdateAmmoHud, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

public void BurningThumbWeaponTrace(int client, int weapon, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	if(InCharge[client] > GetGameTime())
	{
		CustomMeleeRange *= 2.0;
	}
}
public void Weapon_BurningThumb_M1(int client, int weapon, bool crit, int slot)
{
	delete ResetMove[client];

	float cooldown = 0.8;
	if(LastMove[client] >= Tanglecleaver_0 && LastMove[client] <= Tigerslayer_5)
		cooldown = 1.2;

	SetWeaponCooldown(weapon, cooldown);
	ResetCombo(client, cooldown + 5.0, false);
}
#define BURNING_DASHSPEED 720.0
public void Weapon_BurningThumb_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || TF2_IsPlayerInCondition(client, TFCond_LostFooting))
		return;
	
	if(ChargeSpent[client])
	{
		// Already charged, hit next
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Already charged, hit an enemy!");
		return;
	}
	
	float cooldown = Store_GetCooldownIndex(client, WeaponStore, 2);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}

	bool hasAmmo = TotalWeaponAmmo(client, weapon) > 0;
	bool canUse = !hasAmmo;
	int target = client;

	if(!canUse)
	{
		Handle trace;
		b_LagCompNPC_No_Layers = true;
		float vec[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(trace, client, vec, 250.0, false, 60.0, true);

		target = TR_GetEntityIndex(trace);
		if(IsValidEnemy(client, target, true))
		{
			canUse = true;
		}
		else
		{
			// May hit the wall right now because it's fat
			DoSwingTrace_Custom(trace, client, vec, 250.0, false, _, true);
			target = TR_GetEntityIndex(trace);
			if(IsValidEnemy(client, target, true))
			{
				canUse = true;
			}
		}

		FinishLagCompensation_Base_boss();

		delete trace;
	}

	if(canUse)
	{
		Rogue_OnAbilityUse(client, weapon);

		if(hasAmmo && !(GetClientButtons(client) & IN_DUCK))
		{
			float VecAbsClient[3];
			float VecAbsEntity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", VecAbsClient);
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VecAbsEntity);
			float Distance = GetVectorDistance(VecAbsClient, VecAbsEntity);
			float TimeUntillReach = Distance / BURNING_DASHSPEED;
			TimeUntillReach += 0.35;

			if(ShinForm[client])
			{
				EmitSoundToAll(BURN_DASH_SOUND_AMMO, client, _, _, _, 1.0, 80);
				EmitSoundToAll(g_BurnShootsound[GetRandomInt(0, sizeof(g_BurnShootsound) - 1)], client, SNDCHAN_AUTO, 80, _, 0.9, 80);
			}
			else
			{
				EmitSoundToAll(BURN_DASH_SOUND_EMPTY, client, _, _, _, 1.0, 80);	
				EmitSoundToAll(g_BurnShootsound[GetRandomInt(0, sizeof(g_BurnShootsound) - 1)], client, SNDCHAN_AUTO, 80, _, 0.9, 90);
			}

			InCharge[client] = GetGameTime() + TimeUntillReach;
			Burning_Thumb_ApplyParticle(client, false, TimeUntillReach);
			f_AntiStuckPhaseThrough[client] = GetGameTime() + TimeUntillReach;
			f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + TimeUntillReach;
			ApplyStatusEffect(client, client, "Intangible", TimeUntillReach);
			ApplyStatusEffect(client, client, "Touch Ingored", TimeUntillReach);

			int ShieldGive;
			RemoveSpecificBuff(client, "Shielding");
			ApplyStatusEffect(client, client, "Shielding", TimeUntillReach);
			ShieldGive = ReturnEntityMaxHealth(client) / 13;

			Shielding_Add(client, ShieldGive);

			TF2_AddCondition(client, TFCond_LostFooting, TimeUntillReach);
			TF2_AddCondition(client, TFCond_AirCurrent, TimeUntillReach);

			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(target));
			ThumbPush(pack, true);

			if(LastMove[client] != Tigerslayer_0 && LastMove[client] != Tigerslayer_1)
			{
				ChargeSpent[client] = 2;
				SpendAmmo(client, weapon);
			}
		}
		else
		{
			ChargeSpent[client] = 1;
		}

		// Reset combo, apply charge cooldown
		TF2_AddCondition(client, TFCond_FocusBuff, 29.9);
		HasCharged[client] = GetGameTime();
		ResetCombo(client, 5.0, true);

		if(WeaponTimer[client])
			TriggerTimer(WeaponTimer[client], true);
	}
	else
	{
		if(ResetMove[client])
			ResetCombo(client, 5.0, false);
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "No target in sight!");
	}
}

static void ThumbPushFrame(DataPack pack)
{
	ThumbPush(pack, false);
}

static void ThumbPush(DataPack pack, bool first)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client && dieingstate[client] == 0 && f_AntiStuckPhaseThrough[client] > GetGameTime())
	{
		int target = EntRefToEntIndex(pack.ReadCell());
		if(target != -1)
		{
			float vec1[3], vec2[3];
			WorldSpaceCenter(client, vec1);
			WorldSpaceCenter(target, vec2);
			MakeVectorFromPoints(vec1, vec2, vec1);
			if(GetVectorLength(vec1, true) < 10000.0)
			{
				// In contact, drift away now
				if(InCharge[client])
				{
					InCharge[client] = GetGameTime() + 0.3;
				}
				f_AntiStuckPhaseThrough[client] = GetGameTime() + 0.3;
				f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 0.3;
				ApplyStatusEffect(client, client, "Intangible", 0.3);
				ApplyStatusEffect(client, client, "Touch Ingored", 0.3);

				TF2_AddCondition(client, TFCond_LostFooting, 0.3);
				TF2_AddCondition(client, TFCond_AirCurrent, 0.3);
			}
			else
			{
				GetVectorAngles(vec1, vec1);
				GetAngleVectors(vec1, vec1, NULL_VECTOR, NULL_VECTOR);

				ScaleVector(vec1, BURNING_DASHSPEED);

				if(first)
				{
					vec1[2] += 150.0;    // a little boost to alleviate arcing issues
				}
				else
				{
					GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec2);
					vec1[2] = vec2[2];
				}

				TeleportEntity(client, _, _, vec1);

				RequestFrame(ThumbPushFrame, pack);
				return;
			}
		}
	}

	delete pack;
}

public void Weapon_BurningThumb_R(int client, int weapon, bool crit, int slot)
{
	if(!ShinForm[client])
	{
		if((GetClientButtons(client) & IN_DUCK) || TotalWeaponAmmo(client, weapon) < 1)
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
					if(i_WeaponVMTExtraSetting[entity] != -1)
						continue;

					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255);
				SetEntityCollisionGroup(client, 5);
				DoOverlay(client, "", 2);
				SetEntityMoveType(client, MOVETYPE_WALK);

				SetEntityHealth(client, 50);
				Rogue_TriggerFunction(Artifact::FuncRevive, client);

				HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)), (i_CurrentEquippedPerk[client] & PERK_REGENE) ? 0.2 : 0.1, 1.0, HEAL_ABSOLUTE);

				GiveCompleteInvul(client, 1.5);
				CheckLastMannStanding(0);
			}

			Rogue_OnAbilityUse(client, weapon);

			AmmoSpent[client] = 0;
			ShinForm[client] = true;
			ApplyStatusEffect(client, client, TotalSpent[client] >= (MaxAmmo * 2 / 3) ? "Shin - Tiantui Star" : "Tiantui Star", 999.9);
			BurningThumbtion(client, 1);
			
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
	
	float cooldown = Store_GetCooldownIndex(client, WeaponStore, 3);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}

	Store_ApplyCooldownIndex(client, WeaponStore, 3, RCooldown);
	
	Rogue_OnAbilityUse(client, weapon);
	TF2_AddCondition(client, TFCond_CritOnKill, 29.9);
	Store_ApplyCooldownIndex(client, WeaponStore, 2, 0.0, true);
	ResetCombo(client, 5.0, false);

	if(ShinForm[client] && TotalWeaponAmmo(client, weapon) > 0)
	{
		LastMove[client] = Tigerslayer_0;
	}
	else
	{
		LastMove[client] = Tanglecleaver_0;
	}
	
	if(WeaponTimer[client])
		TriggerTimer(WeaponTimer[client], true);
}

void BurningThumb_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	// Offset the status effect nerf
	if(ShinForm[attacker])
		damage *= 2.0;
	
	if(CheckInHud())
		return;

	if(InCharge[attacker])
	{
		InCharge[attacker] = 0.0;
	}
	bool resetCharge;
	int power = 6;

	switch(LastMove[attacker])
	{
		case NoMove, Counter_2, Slash_3, Tanglecleaver_3, Tigerslayer_5:
		{
			LastMove[attacker] = Slash_1;
		}
		case Slash_1:
		{
			LastMove[attacker] = ChargeSpent[attacker] ? Slash_2 : Counter_2;
		}
		default:
		{
			LastMove[attacker]++;
		}
	}

	switch(LastMove[attacker])
	{
		case Slash_2:
		{
			PrintToConsole(attacker, "Double Slash - Blast");

			power = WeaponLevel[attacker] > 1 ? 12 : 10;

			int bonus;
			if(WeaponLevel[attacker] > 0)
				bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 3 : 2);
			
			InflictTremorPotency(victim, attacker, WeaponLevel[attacker] > 2 ? 2 : 1, _, true);

			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				if(WeaponLevel[attacker] > 0)
				{
					bonus += ShinForm[attacker] ? 2 : 1;
					if(WeaponLevel[attacker] > 2)
						damage *= ShinForm[attacker] ? 1.3 : 1.1;
				}
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 4 : 1);

				resetCharge = true;
				if(ChargeSpent[attacker] != 2)
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

			InflictTremorCount(victim, attacker, WeaponLevel[attacker] > 2 ? 2 : 1, _, true);
			
			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				if(WeaponLevel[attacker] > 0)
				{
					bonus += ShinForm[attacker] ? 2 : 1;
					if(WeaponLevel[attacker] > 2)
						damage *= ShinForm[attacker] ? 1.3 : 1.1;
				}
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 4 : 1);

				if(ChargeSpent[attacker] != 2)
					SpendAmmo(attacker, weapon);
			}
			
			if(WeaponLevel[attacker] > 0)
				InflictTremorBurst(victim, attacker, 1, 3, true);
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 1.5;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, cooldown, true);
			TF2_RemoveCondition(attacker, TFCond_FocusBuff);
		}
		case Counter_2:
		{
			//PrintToConsole(attacker, "I'm Burning Up.");

			// 10 - 15
			power = WeaponLevel[attacker] > 2 ? 13 : 10;
			int bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorCount(victim, attacker, 1);

			//PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 1.5;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, cooldown, true);
		}
		case Tanglecleaver_1:
		{
			PrintToConsole(attacker, "Tanglecleaver I");

			// 8 - 11
			power = WeaponLevel[attacker] > 2 ? 9 : 8;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorPotency(victim, attacker, WeaponLevel[attacker] > 2 ? 3 : 2, _, true);

			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(ChargeSpent[attacker] != 2)
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
			
			InflictTremorCount(victim, attacker, WeaponLevel[attacker] > 2 ? 3 : 2, _, true);
			
			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(ChargeSpent[attacker] != 2)
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

			bool ammo = (ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0);
			if(ammo)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				damage *= WeaponLevel[attacker] > 2 ? 1.5 : 1.2;

				if(ChargeSpent[attacker] != 2)
					SpendAmmo(attacker, weapon);
			}
			
			ConvertTremorType(victim, attacker, "Tremor - Scorch");

			int bursts = ammo ? (WeaponLevel[attacker] > 2 ? 3 : 2) : 1;
			for(int i; i < bursts; i++)
			{
				InflictTremorBurst(victim, attacker, 1, true);
			}
			
			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 2.0;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, cooldown, true);
			TF2_RemoveCondition(attacker, TFCond_CritOnKill);
			TF2_RemoveCondition(attacker, TFCond_FocusBuff);
		}
		case Tigerslayer_1:
		{
			PrintToConsole(attacker, "Savage Tigerslayer's Perfected Flurry of Blades I");

			// 5 - 8
			power = WeaponLevel[attacker] > 2 ? 6 : 5;
			int bonus = BonusTremorBurn(victim, 8, WeaponLevel[attacker] > 2 ? 2 : 1);

			InflictTremorPotency(victim, attacker, WeaponLevel[attacker] > 2 ? 3 : 2, _, true);

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

			InflictTremorCount(victim, attacker, WeaponLevel[attacker] > 2 ? 3 : 2, _, true);

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

			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnPotency(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(ChargeSpent[attacker] != 2)
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

			if(ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				InflictBurnCount(victim, attacker, weapon, WeaponLevel[attacker] > 2 ? 5 : 2);

				resetCharge = true;
				if(ChargeSpent[attacker] != 2)
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

			bool ammo = (ChargeSpent[attacker] == 2 || TotalWeaponAmmo(attacker, weapon) > 0);
			if(ammo)
			{
				bonus += ShinForm[attacker] ? 2 : 1;
				if(WeaponLevel[attacker] > 2)
					damage *= ShinForm[attacker] ? 1.3 : 1.1;
				
				if(ChargeSpent[attacker] != 2)
					SpendAmmo(attacker, weapon);
			}
			
			ConvertTremorType(victim, attacker, "Tremor - Scorch");

			int bursts = ammo ? (WeaponLevel[attacker] > 2 ? 3 : 2) : 1;
			for(int i; i < bursts; i++)
			{
				InflictTremorBurst(victim, attacker, 1, true);
			}

			PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;

			float cooldown = 2.0;
			SetWeaponCooldown(weapon, cooldown);
			ResetCombo(attacker, cooldown, true);
			TF2_RemoveCondition(attacker, TFCond_CritOnKill);
			TF2_RemoveCondition(attacker, TFCond_FocusBuff);
			
			//For client only cus too much fancy shit
			float PosDo[3];
			WorldSpaceCenter(victim, PosDo);

			EmitSoundToClient(attacker, "mvm/mvm_tank_explode.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			TE_Particle("hightower_explosion", PosDo, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);

			TE_Particle("mvm_soldier_shockwave", PosDo, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		//	if(RaidbossIgnoreBuildingsLogic(1))
		//		damage *= 2.0;
//
			DataPack pack = new DataPack();
			RequestFrame(BurningThumb_ExplodeDamageDoNow, pack);
			pack.WriteCell(EntIndexToEntRef(attacker));
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteFloatArray(PosDo, sizeof(PosDo));
		//	Explode_Logic_Custom(damage*2.0, attacker, attacker, weapon, position, 250.0, 0.75, _, _, _, _, _, Ground_Slam);
		}
		default:
		{
			//PrintToConsole(attacker, "Single Slash - Blast");

			power = WeaponLevel[attacker] > 1 ? 8 : 7;

			int bonus;
			if(WeaponLevel[attacker] > 0)
			{
				bonus = BonusTremorBurn(victim, 4, WeaponLevel[attacker] > 2 ? 3 : 2);
				InflictTremorPotency(victim, attacker, WeaponLevel[attacker] > 2 ? 2 : 1);
			}
			
			resetCharge = true;
			
			//PrintToConsole(attacker, "> Skill Power: %d (+%d)", power, bonus);
			power += bonus;
		}
	}
	
	damage *= float(power) / 7.0;

	if(resetCharge && HasCharged[attacker])
	{
		ChargeSpent[attacker] = false;
		Store_ApplyCooldownIndex(attacker, WeaponStore, 2, 0.0, true);
	}

	if(WeaponTimer[attacker])
		TriggerTimer(WeaponTimer[attacker], true);
}

static Action UpdateAmmoHud(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(GetClientOfUserId(pack.ReadCell()) == client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				char dash[64] = " ";
				char combo[64] = " ";

				BurningThumbEnum move = ResetMove[client] ? LastMove[client] : NoMove;
				switch(move)
				{
					case Slash_1, Counter_2:
					{
						if(ChargeSpent[client])
						{
							strcopy(combo, sizeof(combo), "Triple Slash - Blast");
							strcopy(dash, sizeof(dash), "Dashes Left: 1");
						}
						else
						{
							strcopy(combo, sizeof(combo), "I'm Burning Up");
						}
					}
					case Slash_2:
					{
						FormatEx(combo, sizeof(combo), "Triple Slash - Blast");
						FormatEx(dash, sizeof(dash), "Dashes Left: %d", ChargeSpent[client] ? 0 : 1);
					}
					case Slash_3:
					{
						FormatEx(combo, sizeof(combo), "Triple Slash - Blast");
						FormatEx(dash, sizeof(dash), "Dashes Left: 0");
					}
					case Tanglecleaver_0, Tanglecleaver_1, Tanglecleaver_2, Tanglecleaver_3:
					{
						BurningThumbEnum index = move - Tanglecleaver_0;
						
						FormatEx(combo, sizeof(combo), "Tanglecleaver");
						FormatEx(dash, sizeof(dash), "Dashes Left: %d", 3 - view_as<int>(index) - (ChargeSpent[client] ? 1 : 0));
					}
					case Tigerslayer_0, Tigerslayer_1, Tigerslayer_2, Tigerslayer_3, Tigerslayer_4, Tigerslayer_5:
					{
						BurningThumbEnum index = move - Tigerslayer_0;
						
						FormatEx(combo, sizeof(combo), "Savage Tigerslayer's Perfected Flurry of Blades");
						FormatEx(dash, sizeof(dash), "Dashes Left: %d", 5 - view_as<int>(index) - (ChargeSpent[client] ? 1 : 0));
					}
				}
				int total = MaxAmmo * 2 / 3;
				PrintHintText(client, "%s\n%s\n%sTigermark Rounds: %d\nAmmo Spent for Shin: (%d / %d)", dash, combo, ShinForm[client] ? "Savage " : "", TotalWeaponAmmo(client, weapon), TotalSpent[client], total);
				
			}
			
			return Plugin_Continue;
		}
	}
	
	WeaponTimer[client] = null;
	return Plugin_Stop;
}

static void InflictBurnPotency(int victim, int attacker, int weapon, int value)
{
	int potency = value;

	if(WeaponLevel[attacker] > 2 && ShinForm[attacker] && TotalWeaponAmmo(attacker, weapon) > 0)
		potency += 2;
	
	float duration = BurningTime - (IgniteFor[victim] * 0.5);
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

	NPC_Ignite(victim, attacker, potency * BurningTime, weapon, BurningDamage);
	PrintToConsole(attacker, "> Burn Extend +%d", potency);
}

stock void InflictTremorPotency(int victim, int attacker, int value, const char[] name = "Tremor", bool console = false)
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
		if(console)
			PrintToConsole(attacker, "> Tremor +%d", potency);
		
		ClientCommand(attacker, (GetURandomInt() % 2) ? "playgamesound weapons/physcannon/energy_bounce1.wav" : "playgamesound weapons/physcannon/energy_bounce2.wav");
	}
}

stock void InflictTremorCount(int victim, int attacker, int value, const char[] name = "Tremor", bool console = false)
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
		if(console)
			PrintToConsole(attacker, "> Tremor Extend +%d", potency);
		
		ClientCommand(attacker, (GetURandomInt() % 2) ? "playgamesound weapons/physcannon/energy_bounce1.wav" : "playgamesound weapons/physcannon/energy_bounce2.wav");
	}
}

stock void InflictTremorBurst(int victim, int attacker, int decrease, int minrequire = 0, bool console = false)
{
	float timeleft;
	char name[64];
	int amount = StatusEffects_TremorDebuffGet(victim, timeleft, name);
	if(amount > 0 && timeleft >= (minrequire * TremorTime))
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(EntIndexToEntRef(attacker));
		pack.WriteCell(amount * TremorStagger);
		RequestFrame(StaggerDamageFrame, pack);

		if(console)
			PrintToConsole(attacker, "> Tremor Burst x%d", name, amount);

		if(StrContains(name, "Scorch", false) != -1)
		{
			amount += BurnStacks(victim, 2);
			SDKHooks_TakeDamage(victim, attacker, attacker, amount * ScorchDamage, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, .Zr_damage_custom = ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
			
			if(console)
				PrintToConsole(attacker, "> %s Burst x%d", name, amount);
		}

		if(decrease)
			StatusEffects_TremorDebuffAdd(victim, 0, -(decrease * TremorTime));
	}
}

static void StaggerDamageFrame(DataPack pack)
{
	pack.Reset();
	int victim = EntRefToEntIndex(pack.ReadCell());
	if(victim != -1)
	{
		int attacker = EntRefToEntIndex(pack.ReadCell());
		if(attacker != -1)
			Elemental_AddStaggerDamage(victim, attacker, pack.ReadCell());
	}

	delete pack;
}

stock void ConvertTremorType(int victim, int attacker, const char[] name, bool console = false)
{
	float timeleft;
	int amount = StatusEffects_TremorDebuffGet(victim, timeleft);
	if(amount > 0 && timeleft > 0.0)
	{
		ApplyStatusEffect(attacker, victim, name, TremorTime);

		if(console)
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

static int BurnStacks(int victim, int decrease = 0)
{
	int amount = 0;
	
	if(IgniteFor[victim] > 0)
	{
		if(decrease)
		{
			IgniteFor[victim] -= decrease;
			if(IgniteFor[victim] < 0)
				IgniteFor[victim] = 0;
		}

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
}

static void ResetCombo(int client, float cooldown, bool charge)
{
	delete ResetMove[client];
	ResetMove[client] = CreateTimer(cooldown, ResetMoveTimer, client);

	Store_ApplyCooldownIndex(client, WeaponStore, 1, cooldown, true);
	if(charge)
	{
		if(HasCharged[client])
		{
			Store_ApplyCooldownIndex(client, WeaponStore, 2, (HasCharged[client] - GetGameTime()) + ChargeExtra);
		}
		else if(Store_GetCooldownIndex(client, WeaponStore, 2) < cooldown)
		{
			Store_ApplyCooldownIndex(client, WeaponStore, 2, cooldown, true);
		}
	}
}

static Action ResetMoveTimer(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		TF2_RemoveCondition(client, TFCond_CritOnKill);

		if(HasCharged[client])
			Store_ApplyCooldownIndex(client, WeaponStore, 2, (HasCharged[client] - GetGameTime()) + ChargeExtra);

		if(ShinForm[client])
		{
			int total = MaxAmmo * 2 / 3;

			if(AmmoSpent[client] >= total)
				ApplyStatusEffect(client, client, "Overheat", 999.9);
			
			if(TotalSpent[client] >= total)
				ApplyStatusEffect(client, client, "Shin - Tiantui Star", 999.9);
		}
	}

	ResetMove[client] = null;
	LastMove[client] = NoMove;
	ChargeSpent[client] = false;
	HasCharged[client] = 0.0;
	
	if(WeaponTimer[client])
		TriggerTimer(WeaponTimer[client], true);

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
static void BurningThumb_ExplodeDamageDoNow(DataPack pack)
{
	pack.Reset();

	int attacker = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(weapon != -1)
	{
		float Pos[3];
		pack.ReadFloatArray(Pos, sizeof(Pos));
		
		float DamageBoomDo = 65.0;
		DamageBoomDo *= WeaponDamageAttributeMultipliers(weapon);
		DamageBoomDo *= 3.0;

		Explode_Logic_Custom(DamageBoomDo, attacker, attacker, weapon, Pos, 250.0, 0.75, _, _, _, _, _, BurningThumb_FinalBoom);
	}

	delete pack;
}

float BurningThumb_FinalBoom(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return 0.0;

	float VecMe[3]; WorldSpaceCenter(entity, VecMe);
	float VecEnemy[3]; WorldSpaceCenter(victim, VecEnemy);

	float AngleVec[3];
	MakeVectorFromPoints(VecMe, VecEnemy, AngleVec);
	GetVectorAngles(AngleVec, AngleVec);

	AngleVec[0] = -45.0;
	SensalCauseKnockback(entity, victim, 1.25, false, AngleVec);
  
	return damage;
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

	if(CvarInfiniteCash.BoolValue)
		total = 99;

	return total;
}


void Burning_Thumb_ApplyParticle(int client, bool Remove = false, float Duration = 0.5)
{
	if(IsValidEntity(PlayerChargeParticle[client]))
		RemoveEntity(PlayerChargeParticle[client]);

	if(Remove)
		return;

	int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(viewmodelModel))
		return;
		
	int trail = Trail_Attach(client, ARROW_TRAIL_RED, 255, 0.45, 60.0, 3.0, 5);
	SetEntityRenderColor(trail, 200, 177, 124, 75);
	SDKCall_SetLocalOrigin(trail, {0.0,0.0,50.0});
	CreateTimer(Duration, Timer_RemoveEntityParent, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(Duration + 0.65, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);

	float flBasePos[3]; // original
	float flAng[3]; // original
	GetAttachment(viewmodelModel, "eyeglow_R", flBasePos, flAng);
	int particle = ParticleEffectAt(flBasePos, "raygun_projectile_red_crit", Duration);
	SetParent(viewmodelModel, particle, "eyeglow_R");
	AddEntityToThirdPersonTransitMode(client, particle);
	/*
	GetAttachment(viewmodelModel, "effect_hand_r", flBasePos, flAng);
	flAng[1] -= 90.0;

	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(flAng, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	for(int i = 1; i <= 5 ; i++)
	{
		vecSwingEnd[0] = flBasePos[0] + vecSwingForward[0] * (15.0 * i);
		vecSwingEnd[1] = flBasePos[1] + vecSwingForward[1] * (15.0 * i);
		vecSwingEnd[2] = flBasePos[2] + vecSwingForward[2] * (15.0 * i);
		float PosToForward[3]; // original
		PosToForward[0] = vecSwingEnd[0] - flBasePos[0];
		PosToForward[1] = vecSwingEnd[1] - flBasePos[1];
		PosToForward[2] = vecSwingEnd[2] - flBasePos[2];
		int particle = ParticleEffectAt(PosToForward, "raygun_projectile_red_crit", Duration);
		SetParent(viewmodelModel, particle, "effect_hand_r", PosToForward);
	}
	*/
}


#define BURNINGTHUMB_BOUNDS_VIEW_EFFECT 25.0
#define BURNINGTHUMB_MAXRANGE_VIEW_EFFECT 80.0

static int BurningThumbtion(int client, int which)
{
	//Reduce the damage they take
	char animation[255];

	DoOverlayLogicLeper(client);
	switch(which)
	{
		case 1:
		{
			Format(animation, sizeof(animation), "burning_reload");
		}
	}

	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	float vecSwingForward[3];
	float vecSwingEnd[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT * 0.25;
	vecSwingEnd[2] += 15.0;
	
	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-10.0 , -5.0);
	switch(GetRandomInt(0,1))
	{
		case 0:
		{
			vAngles[1] += GetRandomFloat(10.0 , 15.0);
		}
		case 1:
		{
			vAngles[1] -= GetRandomFloat(10.0 , 15.0);
		}
	}

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-BURNINGTHUMB_BOUNDS_VIEW_EFFECT, -BURNINGTHUMB_BOUNDS_VIEW_EFFECT, -BURNINGTHUMB_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({BURNINGTHUMB_BOUNDS_VIEW_EFFECT, BURNINGTHUMB_BOUNDS_VIEW_EFFECT, BURNINGTHUMB_BOUNDS_VIEW_EFFECT});

	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;

	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	GetClientEyeAngles(client, vAngles);
	vAngles[0] = 0.0;
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	delete trace;

	float vecSwingEndMiddle[3];
	vecSwingEndMiddle[0] = vOrigin[0] + vecSwingForward[0] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[1] = vOrigin[1] + vecSwingForward[1] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;
	vecSwingEndMiddle[2] = vOrigin[2] + vecSwingForward[2] * BURNINGTHUMB_MAXRANGE_VIEW_EFFECT;
	trace = TR_TraceHullFilterEx( vOrigin, vecSwingEndMiddle, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit something, uh oh!
		TR_GetEndPosition(vecSwingEndMiddle, trace);
	}
	delete trace;
	float vAngleCamera[3];
	float MiddleAngle[3];
	MiddleAngle[0] = (vecSwingEndMiddle[0] + vOrigin[0]) / 2.0;
	MiddleAngle[1] = (vecSwingEndMiddle[1] + vOrigin[1]) / 2.0;
	MiddleAngle[2] = (vecSwingEndMiddle[2] + vOrigin[2]) / 2.0;
	
	int viewcontrol = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(viewcontrol))
	{
		b_ThisEntityIgnored[viewcontrol] = true;
		GetVectorAnglesTwoPoints(vecSwingEnd, MiddleAngle, vAngleCamera);
		SetEntityModel(viewcontrol, "models/empty.mdl");
		if((GetClientButtons(client) & IN_DUCK))
		{
			//if client crouches it actually messes up the camera
			vecSwingEnd[2] += 30.0;
		}
		DispatchKeyValueVector(viewcontrol, "origin", vecSwingEnd);
		DispatchKeyValueVector(viewcontrol, "angles", vAngleCamera);
		DispatchSpawn(viewcontrol);	
		SetClientViewEntity(client, viewcontrol);
	}
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");	

	int spawn_index = NPC_CreateByName("npc_burningthumb_visualiser", client, vabsOrigin, vabsAngles, -1, animation);

	CClotBody npc = view_as<CClotBody>(spawn_index);
	npc.m_iWearable9 = viewcontrol;
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	
	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	}

	return spawn_index;
}