//THIS IS THE PSEUDO-MELEE MAGE WEAPON WITH THE GIANT LIGHTNING BOLT ON M2, NOT TO BE CONFUSED WITH REIUJI!!!!!!!!

//Attribute 733 on this weapon is used as a multiplier for the costs specified in this code. This is so that modifiers, such as from Heavy Mage, can impact the charge cost for M2.

#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is unpapped, then first pap, then second pap, etc.
//NOTE: Tier 4 (the 5th entry in the array, so IE Energy_Enabled[4]) is meant for Crisis Conductor, AKA the Tank path. Tier 5 is meant for Mortal Blackout, AKA the DPS path. Tier 3 is the "middle-ground" path.

//KINETIC ENERGY: Gained by hitting and killing enemies with the primary attack, as well as by being hit while charging Raigeki. Up to 100.0 can be held at a time. 
//Kinetic Energy buffs Static Electricity, and also buffs the primary attack while Supercharged.
//Additionally, it makes Raigeki (the giant thunderbolt) stronger if the user uses the Mortal Blackout PaP path.
static bool Energy_Enabled[6] = { false, true, true, true, true, true };				//Is Kinetic Energy even active on this tier?
static float Energy_OnHit[6] = { 0.5, 0.65, 0.8, 1.0, 2.0, 0.5 };						//Kinetic Energy given for every enemy hit by the primary attack.
static float Energy_OnKill[6] = { 1.0, 1.5, 2.0, 2.5, 5.0, 1.25 };						//Kinetic Energy given for every enemy killed by the primary attack.
static float Energy_OnHit_Raigeki[6] = { 5.0, 6.0, 7.0, 8.0, 16.0, 4.0 };				//Kinetic Energy given for every enemy hit by Raigeki (the big thunderbolt).
static float Energy_OnKill_Raigeki[6] = { 10.0, 15.0, 20.0, 25.0, 50.0, 12.5 };			//Kinetic Energy given for every enemy killed by Raigeki (the big thunderbolt).
static float Energy_OnHurt[6] = { 1.0, 1.25, 1.5, 1.75, 3.5, 0.875 };					//Kinetic Energy given every time the user is hurt while charging Raigeki.
static float Energy_FromBossesMult[6] = { 1.5, 1.5, 1.5, 1.5, 2.0, 1.5 };				//Amount to multiply all Kinetic Energy gained from interactions with bosses.
static float Energy_FromRaidsMult[6] = { 2.5, 2.5, 2.5, 2.5, 3.5, 2.5 };				//Amount to multiply all Kinetic Energy gained from interactions with raids.

//ELECTRIC BLADE: Sweeps across the screen from left to right, damaging every enemy it passes through.
//Multiple blades can sweep in rapid succession, but only the first one consumes mana.
//Becomes X% weaker for every enemy it passes through, but will always deal full damage to the enemy the user was aiming at when they summoned the blade.
//Range and width scale with projectile lifespan and velocity modifiers.
//Sweep speed scales with attack speed modifiers.
static int M1_NumBlades[6] = { 1, 1, 1, 1, 1, 2 };			    				//Number of blade sweeps to perform in a row per M1.
static float M1_Cost[6] = { 40.0, 60.0, 80.0, 100.0, 120.0, 200.0 };			//Primary attack base mana cost.
static float M1_Range[6] = { 140.0, 150.0, 160.0, 180.0, 140.0, 200.0 };  		//Electric blade range.
static float M1_Width[6] = { 120.0, 140.0, 160.0, 180.0, 120.0, 220.0 };  		//Electric blade arc swing angle.
static float M1_Damage[6] = { 750.0, 1000.0, 1250.0, 1500.0, 750.0, 2000.0 }; 	//Electric blade damage.
static float M1_Falloff[6] = { 0.825, 0.85, 0.875, 0.9, 0.825, 0.9 };   		//Amount to multiply electric blade damage per target hit.
static float M1_Interval[6] = { 0.8, 0.85, 0.8, 0.75, 0.8, 0.675 };     		//Time it takes for electric blades to sweep across the screen.

//STATIC ELECTRICITY: Holding M2 allows the user to charge up Raigeki. This imposes a huge speed penalty, prevents Burst Pack from being used, and prevents the user from using their primary attack.
//In exchange: the user gains damage resistance, plus additional damage resistance based on the ability's charge, and emits Static Electricity, which damages nearby enemies.
//Charging drains mana. If the user does not have enough mana, they may continue to hold M2 to keep the resistance, but Static Electricity will stop working, and they will still be unable to attack.
static int Charge_MaxTargets[6] = { 6, 8, 10, 12, 12, 6 };								//Max targets hit at once by Static Electricity ticks.
static float Charge_Cost[6] = { 6.0, 9.0, 12.0, 24.0, 6.0, 24.0 };						//Mana drained per interval while charging the M2 ability.
static float Charge_CostAtFullCharge[6] = { 3.0, 4.5, 6.0, 12.0, 3.0, 24.0 };			//Mana drained per interval while charging the M2 ability, while it is already fully-charged. This is needed so that the user can't just charge to full, and then keep holding M2 to have Static Electricity and resistance forever at no cost.
static float Charge_Requirement[6] = { 300.0, 600.0, 800.0, 1400.0, 750.0, 2000.0  };	//Total mana spent to fully charge the M2 ability.
static float Charge_Min[6] = { 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 };							//Minimum charge percentage needed to cast Raigeki. Releasing M2 or running out of mana below this threshold immediately cancels the ability and does not refund anything.
static float Charge_Interval[6] = { 0.3, 0.3, 0.3, 0.3, 0.3, 0.3 };						//Interval between Static Electricity shocks and charge gain while charging the M2 ability.
static float Charge_InstantRes[6] = { 0.1, 0.125, 0.15, 0.2, 0.35, 0.1 };				//Instant damage resistance given as soon as you begin charging Raigeki.
static float Charge_BonusRes[6] = { 0.2, 0.225, 0.25, 0.3, 0.35, 0.1 };					//Maximum bonus damage resistance given based on the ability's charge level.
static float Charge_DMG[6] = { 24.0, 48.0, 90.0, 135.0, 200.0, 48.0 };					//Base damage per interval dealt per Static Electricity tick while charging.
static float Charge_Radius[6] = { 100.0, 105.0, 110.0, 115.0, 150.0, 100.0 };			//Radius in which Static Electricity deals damage.
static float Charge_Falloff[6] = { 0.7, 0.75, 0.8, 0.85, 0.9, 0.7 };					//Amount to multiply Static Electricity damage per target hit.
static float Charge_EnergyMult[6] = { 3.0, 3.5, 4.0, 5.0, 5.0, 2.0 };					//Maximum Static Electricity bonus damage multiplier based on Kinetic Energy (example: this is 5.0 and the user has 100% Kinetic Energy, a Static Electricity tick will deal 500% extra damage, for a total of 600% damage).
static float Charge_EnergyDrain[6] = { 0.4, 0.4, 0.4, 0.4, 0.3, 0.0 };					//Kinetic Energy drained every time Static Electricity hits an enemy.
static float Charge_ManaOnKill[6] = { 10.0, 15.0, 20.0, 25.0, 40.0, 20.0 };				//Mana to immediately regenerate whenever Static Electricity kills an enemy.

//RAIGEKI: Once the user has charged their M2 enough, they may release M2 to summon Raigeki. This stuns them, during which their resistance is boosted.
//After X second(s), Raigeki will strike, dealing enormous damage within a huge radius. This ends the stun and removes the user's resistance.
static int Raigeki_MaxTargets[6] = { 18, 20, 22, 24, 16, 24 };								//Maximum number of enemies hit at once with Raigeki. I recommend keeping this higher than other sources, because of the ability's inherently risky nature.
static float Raigeki_Delay[6] = { 3.0, 3.0, 3.0, 3.0, 4.0, 3.0 };							//Duration for which the user is stunned upon casting Raigeki. After this time passes, Raigeki's giant thunderbolt will strike, supercharging the user and ending the stun.
static float Raigeki_ResMult[6] = { 0.8, 0.8, 0.8, 0.8, 0.6, 1.0 };							//Amount to multiply damage taken during the stun state while casting Raigeki. This is stacked multiplicatively with the user's current damage resistance granted by charging Raigeki.
static float Raigeki_Damage[6] = { 15000.0, 20000.0, 25000.0, 30000.0, 20000.0, 40000.0 };	//Raigeki's base damage at max charge.
static float Raigeki_Radius[6] = { 450.0, 550.0, 650.0, 800.0, 500.0, 1000.0 };				//Raigeki's radius at max charge.
static float Raigeki_EnergyMult_DMG[6] = { 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 };					//Maximum bonus damage percentage added to Raigeki by Kinetic Energy.
static float Raigeki_EnergyMult_Radius[6] = { 0.0, 0.0, 0.0, 0.0, 0.25 };					//Maximum bonus radius percentage added to Raigeki by Kinetic Energy.
static float Raigeki_Falloff_MultiHit[6] = { 0.825, 0.85, 0.875, 0.9, 0.825, 0.9 };			//Amount to multiply damage dealt by Raigeki per target hit.
static float Raigeki_Falloff_Radius[6] = { 0.75, 0.8, 0.85, 0.9, 0.65, 0.9 };				//Distance-based falloff. Lower numbers = more damage is lost based on distance.
static float Raigeki_Cooldown[6] = { 90.0, 90.0, 90.0, 90.0, 45.0, 90.0 };					//Raigeki's cooldown.
static float Raigeki_Cooldown_Failed[6] = { 45.0, 45.0, 45.0, 45.0, 22.5, 45.0 };			//Raigeki's cooldown if the user fails to cast it (releases M2 without enough charge, is downed/dies while charging).

//SUPERCHARGED: After Raigeki hits, if the user has enough Kinetic Energy, they will become Supercharged.
//While Supercharged, the user's Kinetic Energy drains rapidly, and they cannot gain more Kinetic Energy, but their primary attack is massively buffed.
//Supercharged ends as soon as the user runs out of Kinetic Energy. Also, getting downed while Supercharged instantly removes all Kinetic Energy.
static int Supercharge_ExtraBlades[6] = { 1, 1, 2, 3, 1, 4 };							//Number of extra blades to swing per cast whil Supercharged.
static float Supercharge_DMGMult[6] = { 2.5, 2.5, 3.0, 3.25, 2.5, 3.5 };				//Amount to multiply primary attack damage while Supercharged.
static float Supercharge_SpeedMult[6] = { 1.25, 1.25, 1.3, 1.35, 1.25, 1.425 };			//Amount to multiply attack speed and beam sweep speed while Supercharged.
static float Supercharge_RangeMult[6] = { 1.1, 1.125, 1.15, 1.15, 1.0, 1.2 };			//Amount to multiply beam range while Supercharged.
static float Supercharge_WidthMult[6] = { 1.25, 1.3, 1.35, 1.4, 1.25, 1.5 };			//Amount to multiply beam arc width while Supercharged.
static float Supercharge_Drain[6] = { 1.0, 1.0, 1.0, 1.0, 1.2, 0.8 };					//Amount of Kinetic Energy to drain per 0.1s while Supercharged.

static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};
static bool b_ChargingRaigeki[MAXPLAYERS + 1] = { false, ... };
static bool b_Supercharged[MAXPLAYERS + 1] = { false, ... };
static float f_Energy[MAXPLAYERS + 1] = { 0.0, ... };
static bool b_BladeHitting[MAXPLAYERS + 1] = { false, ... };
static bool b_RaigekiHitting[MAXPLAYERS + 1] = { false, ... };
static bool b_StaticHitting[MAXPLAYERS + 1] = { false, ... };
static int i_BladeTier[MAXPLAYERS + 1] = { 0, ... };
static int i_ChargeTier[MAXPLAYERS + 1] = { 0, ... };

public void Raigeki_ResetAll()
{
	Zero(ability_cooldown);
	Zero(i_ChargeTier);
	Zero(i_BladeTier);
	ZeroFloat(f_Energy);
}

#define PARTICLE_RAIGEKI_STRIKE			"drg_cow_explosioncore_charged"

#define PARTICLE_RAIGEKI_CHARGEUP_AURA_START	 "teleporter_red_exit"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_MID 		 "teleporter_red_exit_level1"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_HIGH 	 "teleporter_red_exit_level2"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_MAX 		 "teleporter_red_exit_level3"
#define PARTICLE_RAIGEKI_CASTING_AURA	 		 "eyeboss_vortex_red"
#define PARTICLE_SUPERCHARGED_AURA				 "soldierbuff_red_buffed"

#define SOUND_RAIGEKI_BLADE_SWEEP       ")weapons/batsaber_swing_crit3.wav"
#define SOUND_CHARGE_MAX_NOTIF			")weapons/vaccinator_charge_tier_04.wav"
#define SOUND_RAIGEKI_FAILED			")player/taunt_sorcery_fail.wav"
#define SOUND_RAIGEKI_CAST_1			")ambient/hell/hell_rumbles_01.wav"
#define SOUND_RAIGEKI_CAST_2			")misc/halloween/spell_spawn_boss_disappear.wav"
#define SOUND_RAIGEKI_INCOMING			")ambient/halloween/thunder_04.wav"
#define SOUND_RAIGEKI_STRIKE_1			")misc/halloween/spell_spawn_boss.wav"
#define SOUND_RAIGEKI_STRIKE_2			")misc/doomsday_missile_explosion.wav"
#define SOUND_SUPERCHARGE_EXPIRE		")player/invuln_off_vaccinator.wav"
#define SOUND_SUPERCHARGED_SWING		")weapons/samurai/tf_katana_crit_miss_01.wav"

#define SOUND_CHARGE_LOOP				")player/quickfix_invulnerable_on.wav"
#define SOUND_ELECTRICITY_LOOP			")weapons/weapon_crit_charged_on.wav"
#define SOUND_SUPERCHARGED_LOOP			")weapons/man_melter_alt_fire_lp.wav"

static char g_StaticSounds[][] = {
	")weapons/stunstick/spark1.wav",
	")weapons/stunstick/spark2.wav",
	")weapons/stunstick/spark3.wav",
};

static int Model_Lightning;

void Raigeki_Precache()
{
	Model_Lightning = PrecacheModel("materials/sprites/lgtning.vmt");
	PrecacheModel("materials/sprites/glow02.vmt");
	PrecacheModel("materials/effects/repair_claw_trail_red.vmt");
	PrecacheModel("materials/sprites/laser.vmt", false);

    PrecacheSound(SOUND_RAIGEKI_BLADE_SWEEP, true);
	PrecacheSound(SOUND_CHARGE_LOOP, true);
	PrecacheSound(SOUND_ELECTRICITY_LOOP, true);
	PrecacheSound(SOUND_CHARGE_MAX_NOTIF, true);
	PrecacheSound(SOUND_RAIGEKI_FAILED, true);
	PrecacheSound(SOUND_RAIGEKI_CAST_1, true);
	PrecacheSound(SOUND_RAIGEKI_CAST_2, true);
	PrecacheSound(SOUND_RAIGEKI_INCOMING, true);
	PrecacheSound(SOUND_RAIGEKI_STRIKE_1, true);
	PrecacheSound(SOUND_RAIGEKI_STRIKE_2, true);
	PrecacheSound(SOUND_SUPERCHARGED_LOOP, true);
	PrecacheSound(SOUND_SUPERCHARGE_EXPIRE, true);
	PrecacheSound(SOUND_SUPERCHARGED_SWING, true);

	for (int i = 0; i < sizeof(g_StaticSounds); i++) { PrecacheSound(g_StaticSounds[i]); }

	Raigeki_ResetAll();
}

//Block Burst Pack while charging Raigeki.
public bool Raigeki_OnBurstPack(int client)
{
	return !b_ChargingRaigeki[client];
}

void Energy_Give(int client, float amt, int source = -1, int tier = 0)
{
	if (amt > 0.0 && b_Supercharged[client] || (!Energy_Enabled[i_BladeTier[client]] && !Energy_Enabled[i_ChargeTier[client]]))
		return;

	if (IsEntityAlive(source) && amt > 0.0)
	{
		if (b_thisNpcIsABoss[source])
			amt *= Energy_FromBossesMult[tier];
		else if (b_thisNpcIsARaid[source])
			amt *= Energy_FromRaidsMult[tier];
	}

	f_Energy[client] += amt;
	if (f_Energy[client] <= 0.0)
		f_Energy[client] = 0.0;
	if (f_Energy[client] >= 100.0)
		f_Energy[client] = 100.0;

	Raigeki_HUD(client, Raigeki_GetWeapon(client), true);
}

void Raigeki_OnKill(int attacker, int victim)
{
	float amt = 0.0;
	if (b_BladeHitting[attacker])
		amt = Energy_OnKill[i_BladeTier[attacker]];
	else if (b_RaigekiHitting[attacker])
		amt = Energy_OnKill_Raigeki[i_ChargeTier[attacker]];

	if (amt > 0.0)
		Energy_Give(attacker, amt, victim, b_BladeHitting[attacker] ? i_BladeTier[attacker] : i_ChargeTier[attacker]);

	if (b_StaticHitting[attacker] && b_ChargingRaigeki[attacker] && Current_Mana[attacker] < RoundToCeil(max_mana[attacker]))
	{
		Current_Mana[attacker] = RoundToCeil(fmin(float(Current_Mana[attacker]) + Charge_ManaOnKill[i_ChargeTier[attacker]], max_mana[attacker]));
	}
}

Handle Timer_Raigeki[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextRaigekiHUD[MAXPLAYERS + 1] = { 0.0, ... };

public void Enable_Raigeki(int client, int weapon)
{
	if (Timer_Raigeki[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAIGEKI)
		{
			delete Timer_Raigeki[client];
			Timer_Raigeki[client] = null;
			DataPack pack;
			Timer_Raigeki[client] = CreateDataTimer(0.1, Timer_RaigekiControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAIGEKI)
	{
		DataPack pack;
		Timer_Raigeki[client] = CreateDataTimer(0.1, Timer_RaigekiControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextRaigekiHUD[client] = 0.0;
	}
}

public Action Timer_RaigekiControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Raigeki[client] = null;
		return Plugin_Stop;
	}

	Raigeki_HUD(client, weapon, false);

	return Plugin_Continue;
}

static int i_RaigekiWeapon[MAXPLAYERS + 1] = { 0, ... };

static float f_LastGT[MAXPLAYERS + 1] = { 0.0, ... };

static bool b_RaigekiDelayingAttacks[MAXPLAYERS + 1] = { false, ... };

public int Raigeki_GetWeapon(int client) { return EntRefToEntIndex(i_RaigekiWeapon[client]); }

public bool Raigeki_IsHoldingCorrectWeapon(int client)
{
    int weapon = Raigeki_GetWeapon(client);
    if (!IsValidEntity(weapon))
        return false;

    int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    return acWep == weapon;
}

//Infinitely delays the weapon's next attack by extending m_flNextPrimaryAttack by delta time every frame.
//This is automatically stopped if the client stops holding this weapon, and can be manually stopped with Raigeki_StopDelayingAttacks.
//Also, this automatically sets i_RaigekiWeapon to this weapon, so you can call Raigeki_IsHoldingCorrectWeapon to make sure this weapon is held.
public void Raigeki_StartDelayingAttacks(int client, int weapon)
{
	if (!IsValidEntity(weapon))
		return;

	i_RaigekiWeapon[client] = EntIndexToEntRef(weapon);

	if (!b_RaigekiDelayingAttacks[client])
	{
		b_RaigekiDelayingAttacks[client] = true;
		f_LastGT[client] = GetGameTime();

		RequestFrame(Raigeki_DelayAttack, GetClientUserId(client));
	}
}

//This stops delaying the client's next attack if Raigeki_StartDelayingAttacks was used.
//DO NOT CALL Raigeki_StartDelayingAttacks ON THE SAME CLIENT AGAIN UNTIL AT LEAST ONE FRAME HAS PASSED!!!!!
//If a weapon is already being delayed, and you need to change it to a different weapon, just call Raigeki_StartDelayingAttacks again, with the new weapon.
public void Raigeki_StopDelayingAttacks(int client)
{
	b_RaigekiDelayingAttacks[client] = false;
}

public void Raigeki_DelayAttack(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client) || !b_RaigekiDelayingAttacks[client])
		return;

	if (!Raigeki_IsHoldingCorrectWeapon(client))
	{
		b_RaigekiDelayingAttacks[client] = false;
		return;
	}

	float gt = GetGameTime();
	int weapon = Raigeki_GetWeapon(client);
    if (IsValidEntity(weapon))
    {
		float current = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
		if (current < gt)
			current = gt;

		current += (gt - f_LastGT[client]);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", current);
    }

    f_LastGT[client] = gt;
	RequestFrame(Raigeki_DelayAttack, id);
}

public void Raigeki_Charge_0(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 0);
}

public void Raigeki_Charge_1(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 1);
}

public void Raigeki_Charge_2(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 2);
}

public void Raigeki_Charge_3(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 3);
}

public void Raigeki_Charge_4(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 4);
}

public void Raigeki_Charge_5(int client, int weapon, bool &result, int slot)
{
    Raigeki_StartCharging(client, weapon, 5);
}

static int i_ChargeMaxTargets[MAXPLAYERS + 1] = { 0, ... };
static int i_RaigekiParticle[MAXPLAYERS + 1] = { 0, ... };
static int i_RaigekiParticleOwner[2049] = { -1, ... };

static bool b_DoChargeVFX[MAXPLAYERS + 1] = { false, ... };

static float f_ChargeRadius[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeCost[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeCostAtFullCharge[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeRequirement[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeMin[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeAmt[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeInterval[MAXPLAYERS + 1] = { 0.0, ... };
static float f_NextChargeVFX[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeBaseRes[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeBonusRes[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeCurrentRes[MAXPLAYERS + 1 ] = { 0.0, ... };
static float f_ChargeDMG[MAXPLAYERS + 1] = { 0.0, ... };
static float f_ChargeFalloff[MAXPLAYERS + 1] = { 0.0, ... };
static float f_NextCharge[MAXPLAYERS + 1] = { 0.0, ... };
static float f_RaigekiVFXTime[MAXPLAYERS + 1] = { 0.0, ... };
static float f_RaigekiStrikesAt[MAXPLAYERS + 1] = { 0.0, ... };

void Raigeki_StartCharging(int client, int weapon, int tier)
{
	//This should never be able to happen in-game, but just to be safe...
	if (b_ChargingRaigeki[client] || b_Supercharged[client])
		return;

	if (dieingstate[client] > 0)
	{
		Utility_HUDNotification_Translation(client, "Raigeki Blocked Because Downed", true);
		return;
	}

	int mana_cost = RoundFloat(Charge_Cost[tier] * Attributes_Get(weapon, 733, 1.0));
	float remCD = Ability_Check_Cooldown(client, 2, weapon);

	if(mana_cost <= Current_Mana[client] && remCD <= 0.0)
	{
		i_ChargeTier[client] = tier;
		f_ChargeAmt[client] = 0.0;
		b_ChargingRaigeki[client] = true;
		f_ChargeCurrentRes[client] = 1.0;
		b_DoChargeVFX[client] = true;
		ApplyStatusEffect(client, client, "Charging Raigeki", 9999.0);

		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_START);

		EmitSoundToClient(client, SOUND_CHARGE_LOOP, client, _, _, _, _, 80);

		Raigeki_StartDelayingAttacks(client, weapon);
		Raigeki_AddCharge(client);
		Raigeki_DoChargeVFX(client);

		RequestFrame(Raigeki_ChargeLogic, GetClientUserId(client));
	}
	else
	{
		if (remCD > 0.0)
			Utility_OnCooldown(client, remCD);
		else
			Utility_NotEnoughMana(client, mana_cost);
	}
}

void Raigeki_RemoveParticle(int client)
{
	int particle = EntRefToEntIndex(i_RaigekiParticle[client]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);

	i_RaigekiParticle[client] = -1;
}

void Raigeki_AttachParticle(int client, char[] particle)
{
	Raigeki_RemoveParticle(client);

	float pos[3];
	GetClientAbsOrigin(client, pos);
	int effect = ParticleEffectAt_Parent(pos, particle, client);
	if (IsValidEntity(effect))
	{
		i_RaigekiParticle[client] = EntIndexToEntRef(effect);
		i_RaigekiParticleOwner[effect] = GetClientUserId(client);
		SetEdictFlags(effect, GetEdictFlags(effect)&(~FL_EDICT_ALWAYS));
		SDKHook(effect, SDKHook_SetTransmit, Raigeki_ParticleTransmit);
	}
}

 public Action Raigeki_ParticleTransmit(int entity, int client)
 {
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	
 	int owner = GetClientOfUserId(i_RaigekiParticleOwner[entity]);
 		
 	if (client != owner || (client == owner && (GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting) || TF2_IsPlayerInCondition(client, TFCond_Dazed))))
 		return Plugin_Continue;
 		
 	return Plugin_Handled;
 }

//This returns true if the player is dead or downed.
//If holdingM2 is set to true, it also returns true if the player is not holding M2, and doesn't have enough charge to cast Raigeki.
//needsWeapon does the same thing, but returns true if the player is not holding the weapon they used to charge Raigeki.
//This function also automatically terminates Raigeki's charge logic if it returns true. The optimal usage of this function is therefore: if (Raigeki_WillFail(client)) { return; }
bool Raigeki_WillFail(int client, bool holdingM2, bool needsWeapon)
{
	float amtCharged = (f_ChargeAmt[client] / f_ChargeRequirement[client]);

	bool failed = (!IsPlayerAlive(client) || dieingstate[client] > 0 || (needsWeapon && !Raigeki_IsHoldingCorrectWeapon(client)) || (holdingM2 && (GetClientButtons(client) & IN_ATTACK2 == 0) && amtCharged < f_ChargeMin[client]));

	if (failed)
	{
		if ((holdingM2 && GetClientButtons(client) & IN_ATTACK2 == 0 && amtCharged < f_ChargeMin[client]))
			Utility_HUDNotification_Translation(client, "Raigeki Failed Low Charge", true);
		else if (dieingstate[client] > 0)
			Utility_HUDNotification_Translation(client, "Raigeki Failed Downed", true);
		else if (!IsPlayerAlive(client))
			Utility_HUDNotification_Translation(client, "Raigeki Failed Killed", true);
		else if (needsWeapon)
			Utility_HUDNotification_Translation(client, "Raigeki Failed Wrong Weapon", true);

		EmitSoundToClient(client, SOUND_RAIGEKI_FAILED, _, _, _, _, _, 80);

		Raigeki_TerminateCharge(client);
		Raigeki_StopDelayingAttacks(client);

		int weapon = Raigeki_GetWeapon(client);
		if (IsValidEntity(weapon))
			Ability_Apply_Cooldown(client, 2, Raigeki_Cooldown_Failed[i_ChargeTier[client]], weapon);
	}

	return failed;
}

void Raigeki_ChargeLogic(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client) || Raigeki_WillFail(client, true, true))
		return;

	if (GetClientButtons(client) & IN_ATTACK2 != 0)	//If the user is holding M2: do charge logic
	{
		float gt = GetGameTime();
		if (gt >= f_NextCharge[client] && Current_Mana[client] >= RoundToFloor(f_ChargeCost[client]))
		{
			Raigeki_AddCharge(client);
		}

		if (gt >= f_NextChargeVFX[client])
		{
			Raigeki_DoChargeVFX(client);
		}
	}
	else	//If the user is not holding M2: we know from the earlier checks that they have enough charge to cast Raigeki. Therefore, stun them and begin casting Raigeki.
	{
		f_ChargeCurrentRes[client] *= Raigeki_ResMult[i_ChargeTier[client]];

		TF2_StunPlayer(client, Raigeki_Delay[i_ChargeTier[client]] - 0.33, _, TF_STUNFLAG_BONKSTUCK);

		Raigeki_TerminateChargeFX(client);
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CASTING_AURA);

		f_RaigekiStrikesAt[client] = GetGameTime() + Raigeki_Delay[i_ChargeTier[client]];
		f_RaigekiVFXTime[client] = f_RaigekiStrikesAt[client] - 0.32;
		RequestFrame(Raigeki_SummonBolt, GetClientUserId(client));
		EmitSoundToAll(SOUND_RAIGEKI_CAST_1, client, _, _, _, _, 80);
		EmitSoundToAll(SOUND_RAIGEKI_CAST_2, client, _, _, _, _, 60);

		return;
	}

	RequestFrame(Raigeki_ChargeLogic, id);
}

Function g_TrailColorFunc[2049] = { INVALID_FUNCTION, ... };

static float f_TrailStartTime[2049] = { 0.0, ... };
static float f_TrailEndTime[2049] = { 0.0, ... };
static float f_TrailDistance[2049] = { 0.0, ... };
static float f_TrailIntensity[2049] = { 0.0, ... };

static float vec_TrailTarg[2049][3];

/**
 * Spawns a trail at startPos, and automatically moves it to targPos over a given span of time.
 * 
 * @param startPos		The starting position of the trail.
 * @param targPos		The ending position of the trail.
 * @param time			The time it should take for the trail to move from startPos to targPos.
 * @param sprite		The sprite to use.
 * @param r				R color value.
 * @param g				G color value.
 * @param b				B color value.
 * @param a				Alpha value.
 * @param func_SetColor	Optional function to call each frame while the trail moves to its target position. Must take an int, being the trail's index, as well as a float representing the trail's progress towards its target position (0.0: still at startPos, 1.0: reached targPos).
 * @param lifetime		Trail's lifetime.
 * @param startWidth	Trail's start width.
 * @param endWidth		Trail's end width.
 * @param rendermode	Trail's render mode.
 * @param intensity		The amount by which the trail should zip around each frame. Higher values make it look more chaotic, like electricity. 0.0 means it goes straight from startPos to targPos.
 * 
 * @return		The entity index of the trail which was created.
 */
int Raigeki_SpawnMovingTrail(float startPos[3], float targPos[3], float time, char[] sprite, int r, int g, int b, int a, Function func_SetColor = INVALID_FUNCTION, float lifetime = 1.0, float startWidth = 22.0, float endWidth = 0.0, int rendermode = 4, float intensity = 6.0)
{
	int trail = CreateTrail(sprite, a, lifetime, startWidth, endWidth, rendermode);

	if (IsValidEntity(trail))
	{
		SetEntityRenderColor(trail, r, g, b, a);
		TeleportEntity(trail, startPos);
		g_TrailColorFunc[trail] = func_SetColor;
		f_TrailStartTime[trail] = GetGameTime();
		f_TrailEndTime[trail] = f_TrailStartTime[trail] + time;
		f_TrailDistance[trail] = GetVectorDistance(startPos, targPos);
		f_TrailIntensity[trail] = intensity;

		for (int i = 0; i < 3; i++)
			vec_TrailTarg[trail][i] = targPos[i];

		RequestFrame(Raigeki_MoveTrailToTarg, EntIndexToEntRef(trail));

		return trail;
	}

	return -1;
}

void Raigeki_MoveTrailToTarg(int ref)
{
	int trail = EntRefToEntIndex(ref);
	if (!IsValidEntity(trail))
		return;

	float pos[3], ang[3];
	WorldSpaceCenter(trail, pos);
	GetAngleBetweenPoints(vec_TrailTarg[trail], pos, ang);

	float gt = GetGameTime();
	float duration = f_TrailEndTime[trail] - f_TrailStartTime[trail];
	float timePassed = duration - (f_TrailEndTime[trail] - gt);

	float progress = timePassed / duration;

	float distance = f_TrailDistance[trail] - (f_TrailDistance[trail] * progress);
	GetPointInDirection(vec_TrailTarg[trail], ang, distance, pos);

	if (progress < 1.0)
	{
		pos[0] += GetRandomFloat(-f_TrailIntensity[trail], f_TrailIntensity[trail]);
		pos[1] += GetRandomFloat(-f_TrailIntensity[trail], f_TrailIntensity[trail]);
	}

	TeleportEntity(trail, pos);

	if (g_TrailColorFunc[trail] != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, g_TrailColorFunc[trail]);

		Call_PushCell(trail);
		Call_PushFloat(progress);

		Call_Finish();
	}

	if (progress >= 1.0)
	{
		ShrinkTrailIntoNothing(trail, 0.33);
		return;
	}

	RequestFrame(Raigeki_MoveTrailToTarg, ref);
}

void Raigeki_SummonBolt(int id)
{
	int client = GetClientOfUserId(id);

	if (!IsValidClient(client) || Raigeki_WillFail(client, false, false))
		return;
		
	float amtCharged = f_ChargeAmt[client] / f_ChargeRequirement[client];

	int r, g, b, a;
	char sprite[255];
	Raigeki_GetTrailColors(i_ChargeTier[client], r, g, b, a, sprite, amtCharged);

	float gt = GetGameTime();
	if (gt >= f_RaigekiVFXTime[client] && f_RaigekiVFXTime[client] > 0.0)
	{
		float targPos[3], startPos[3];
		WorldSpaceCenter(client, targPos);
		targPos[2] += 5.0;

		for (int i = 0; i < 4 + RoundToFloor(8.0 * amtCharged); i++)
		{
			startPos = targPos;
			startPos[0] += GetRandomFloat(-200.0, 200.0);
			startPos[1] += GetRandomFloat(-200.0, 200.0);
			startPos[2] += 2000.0;

			Raigeki_SpawnMovingTrail(startPos, targPos, 0.32, sprite, r, g, b, 10 + RoundToFloor(70.0 * amtCharged), _, 0.24, _, _, view_as<int>(RENDER_TRANSALPHAADD), 12.0);
		}

		EmitSoundToAll(SOUND_RAIGEKI_INCOMING, client);
		EmitSoundToAll(SOUND_RAIGEKI_INCOMING, client, _, _, _, _, 60);
		f_RaigekiVFXTime[client] = 0.0;
	}

	if (gt >= f_RaigekiStrikesAt[client])
	{
		float pos[3], skyPos[3];
		WorldSpaceCenter(client, pos);
		pos[2] += 5.0;
		skyPos = pos;
		skyPos[2] += 2000.0;
		Raigeki_DrawBeamColumn(skyPos, pos, 35.0, r, g, b, 210 + RoundToFloor(amtCharged * 45.0));

		int particle = ParticleEffectAt(pos, PARTICLE_RAIGEKI_STRIKE);
		if (IsValidEntity(particle))
		{
			EmitSoundToAll(SOUND_RAIGEKI_STRIKE_1, client, _, _, _, _, 80);
			EmitSoundToAll(SOUND_RAIGEKI_STRIKE_2, client, _, _, _, _, 80);
		}

		for (int i = 0; i < 4 + RoundToFloor(8.0 * amtCharged); i++)
		{
			skyPos = pos;
			skyPos[0] += GetRandomFloat(-500.0, 500.0);
			skyPos[1] += GetRandomFloat(-500.0, 500.0);
			skyPos[2] += GetRandomFloat(400.0, 600.0);

			Raigeki_SpawnMovingTrail(pos, skyPos, GetRandomFloat(0.2, 0.4), sprite, r, g, b, 10 + RoundToFloor(70.0 * amtCharged), _, 0.2, 8.0, _, view_as<int>(RENDER_TRANSALPHAADD), 16.0);
		}

		Raigeki_TerminateCharge(client);
		Raigeki_StopDelayingAttacks(client);
		int weapon = Raigeki_GetWeapon(client);
		if (IsValidEntity(weapon))
			Ability_Apply_Cooldown(client, 2, Raigeki_Cooldown[i_ChargeTier[client]], weapon);

		Client_Shake(client, _, 10.0 + (amtCharged * 50.0), 15.0, 2.25);
		DoOverlay(client, "lights/white005", 0);
		CreateTimer(0.1, Mondo_RemoveOverlay, id, TIMER_FLAG_NO_MAPCHANGE);

		float damage = Raigeki_Damage[i_ChargeTier[client]] * Attributes_Get(weapon, 410, 1.0) * amtCharged;
		float radius = Raigeki_Radius[i_ChargeTier[client]] * amtCharged;

		if (Energy_Enabled[i_ChargeTier[client]] && f_Energy[client] > 0.0)
		{
			float en = f_Energy[client] / 100.0;

			if (Raigeki_EnergyMult_DMG[i_ChargeTier[client]] > 0.0)
				damage *= 1.0 + (Raigeki_EnergyMult_DMG[i_ChargeTier[client]] * en);

			if (Raigeki_EnergyMult_Radius[i_ChargeTier[client]] > 0.0)
				radius *= 1.0 + (Raigeki_EnergyMult_Radius[i_ChargeTier[client]] * en);
		}

		b_RaigekiHitting[client] = true;
		Explode_Logic_Custom(damage, client, client, weapon, pos, radius, Raigeki_Falloff_MultiHit[i_ChargeTier[client]], Raigeki_Falloff_Radius[i_ChargeTier[client]], _, Raigeki_MaxTargets[i_ChargeTier[client]], _, _, view_as<Function>(Raigeki_OnHit));
		b_RaigekiHitting[client] = false;

		if (f_Energy[client] > 0.0 && Energy_Enabled[i_ChargeTier[client]])
		{
			b_Supercharged[client] = true;

			//Problem: charging the ability which lets us go ham with M1 consumes mana a lot of mana. Going ham with M1 also consumes a lot of mana. Therefore, it is highly likely players will spend all of their mana charging the ability, then be unable to make full use of the Supercharged buff.
			//Solution: if the client has less mana than the product of their charge percentage, energy percentage, and max mana: give them that product. In layman's terms: using the ability at full charge with full Kinetic Energy immediately restores 100% mana.
			if (Current_Mana[client] < RoundToCeil(max_mana[client] * amtCharged * (f_Energy[client] / 100.0)))
				Current_Mana[client] = RoundToCeil(max_mana[client] * amtCharged * (f_Energy[client] / 100.0));

			DataPack pack = new DataPack();
			CreateDataTimer(0.1, Supercharge_DrainEnergy, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(client));
			WritePackFloat(pack, Supercharge_Drain[i_ChargeTier[client]]);

			Raigeki_AttachParticle(client, PARTICLE_SUPERCHARGED_AURA);
			EmitSoundToClient(client, SOUND_SUPERCHARGED_LOOP, _, _, _, _, _, 140);
			EmitSoundToClient(client, SOUND_ELECTRICITY_LOOP);
		}

		return;
	}

	RequestFrame(Raigeki_SummonBolt, id);
}

public void Raigeki_OnHit(int attacker, int victim, float damage)
{
	Energy_Give(attacker, Energy_OnHit_Raigeki[i_ChargeTier[attacker]], victim, i_ChargeTier[attacker]);
}

public Action Supercharge_DrainEnergy(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float drainAmt = ReadPackFloat(pack);

	if (!IsValidClient(client))
		return Plugin_Stop;

	Energy_Give(client, -drainAmt);
	if (f_Energy[client] <= 0.0 || !IsPlayerAlive(client) || dieingstate[client] > 0)
	{
		f_Energy[client] = 0.0;
		b_Supercharged[client] = false;

		Raigeki_RemoveParticle(client);
		StopSound(client, SNDCHAN_AUTO, SOUND_SUPERCHARGED_LOOP);
		StopSound(client, SNDCHAN_AUTO, SOUND_ELECTRICITY_LOOP);
		EmitSoundToClient(client, SOUND_SUPERCHARGE_EXPIRE, _, _, 110);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

static int i_RaigekiBeamStart[2049] = { -1, ... };
static int i_RaigekiBeamEnd[2049] = { -1, ... };

void Raigeki_DrawBeamColumn(float startPos[3], float endPos[3], float width, int r, int g, int b, int a, char[] sprite = "materials/sprites/lgtning.vmt")
{
	for (int i = 0; i < 6; i++)
	{
		float beamStart[3], beamEnd[3];
		beamStart = startPos;
		beamEnd = endPos;
		beamStart[2] -= 17.5;
		beamEnd[2] -= 12.5;

		if (i > 0)
		{
			float beamAng[3], startToEnd[3];
			GetAngleBetweenPoints(beamStart, beamEnd, startToEnd);
			beamAng[0] = startToEnd[0];
			beamAng[1] = startToEnd[1];
			beamAng[2] = (360.0 / 6.0) * float(i);

			float dir[3];
			GetAngleVectors(beamAng, dir, NULL_VECTOR, dir);
			ScaleVector(dir, width);
			AddVectors(beamStart, dir, beamStart);
			AddVectors(beamEnd, dir, beamEnd);
		}

		int startEnt, endEnt;
		int beam = CreateEnvBeam(-1, -1, beamStart, beamEnd, _, _, startEnt, endEnt, r, g, b, a, sprite, 60.0, 60.0, _, 6.0);

		if (IsValidEntity(beam) && IsValidEntity(startEnt) && IsValidEntity(endEnt))
		{
			RequestFrame(Raigeki_DissipateBeam, EntIndexToEntRef(beam));
			i_RaigekiBeamStart[beam] = EntIndexToEntRef(startEnt);
			i_RaigekiBeamEnd[beam] = EntIndexToEntRef(endEnt);
		}
	}

	//The following is commented out instead of deleted, just in case I need to use this as a backup plan:
	//startPos[2] -= 25.0;
	//endPos[2] -= 25.0;

	/*for (int i = 0; i < 2; i++)
	{
		int startEnt, endEnt;
		int beam = CreateEnvBeam(-1, -1, startPos, endPos, _, _, startEnt, endEnt, r, 120, b, 255, SPRITE_BEAM_BLACK, 60.0, 60.0, _, 3.0);

		if (IsValidEntity(beam) && IsValidEntity(startEnt) && IsValidEntity(endEnt))
		{
			RequestFrame(Lance_DissipateBeam, EntIndexToEntRef(beam));
			Lance_DissipateStartEnt[beam] = EntIndexToEntRef(startEnt);
			Lance_DissipateEndEnt[beam] = EntIndexToEntRef(endEnt);
		}
	}*/
}

void Raigeki_DissipateBeam(int ref)
{
	int beam = EntRefToEntIndex(ref);
	if (!IsValidEntity(beam))
		return;

	int start = EntRefToEntIndex(i_RaigekiBeamStart[beam]);
	int end = EntRefToEntIndex(i_RaigekiBeamEnd[beam]);
	
	if (!IsValidEntity(beam) || !IsValidEntity(start) || !IsValidEntity(end))
	{
		if (IsValidEntity(beam))
			RemoveEntity(beam);
		if (IsValidEntity(start))
			RemoveEntity(start);
		if (IsValidEntity(end))
			RemoveEntity(end);

		return;
	}

	int r, g, b, a;
	GetEntityRenderColor(beam, r, g, b, a);
	a = RoundFloat(LerpCurve(float(a), 0.0, 3.0, 6.0));
	if (a <= 0)
	{
		RemoveEntity(beam);
		RemoveEntity(start);
		RemoveEntity(end);

		return;
	}

	SetEntityRenderColor(beam, r, g, b, a);

	float amplitude = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    if (amplitude > 0.0)
    {
        amplitude = LerpCurve(amplitude, 0.0, 0.33, 0.66);
        SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amplitude);
    }

	float width = GetEntPropFloat(beam, Prop_Data, "m_fWidth");
    if (width > 0.0)
    {
        width = LerpCurve(amplitude, 0.0, 0.33, 0.66);
        SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
    	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width);
    }

	RequestFrame(Raigeki_DissipateBeam, ref);
}

static float f_ChargeTrailDist[2049] = { 0.0, ... };
static float f_ChargeTrailSpeed[2049] = { 0.0, ... };
static float f_ChargeTrailTargWidth[2049] = { 0.0, ... };
static int i_ChargeTrailTarget[2049] = { -1, ... };

void Raigeki_AddCharge(int client)
{
	int weapon = Raigeki_GetWeapon(client);	//The weapon is guaranteed to always be valid, because this function is only called in scopes where the weapon has already been checked for validity. Therefore, no need to check again.

	//We call ReadStats every time we add charge, so that we can be 100% sure we're accurate. This prevents exploits such as starting the charge with Morning Coffee for the faster hit rate, then swapping to Obsidian Oaf for the resistance but keeping the hit rate from Coffee.
	//It also allows things like attack speed buffs to affect the charge-up, even if applied/removed mid-charge.
	Raigeki_ReadStats(client, weapon, i_ChargeTier[client]);

	float prevAmt = f_ChargeAmt[client] / f_ChargeRequirement[client];

	int cost = RoundToFloor(f_ChargeCostAtFullCharge[client]);

	if (f_ChargeAmt[client] < f_ChargeRequirement[client])
	{
		cost = RoundToFloor(f_ChargeCost[client]);
		f_ChargeAmt[client] += f_ChargeCost[client];

		if (f_ChargeAmt[client] > f_ChargeRequirement[client])
		{
			cost -= (RoundToFloor(f_ChargeAmt[client] - f_ChargeRequirement[client]));
			if (cost < f_ChargeCostAtFullCharge[client])
				cost = RoundToFloor(f_ChargeCostAtFullCharge[client]);

			f_ChargeAmt[client] = f_ChargeRequirement[client];
		}
	}
	
	Utility_RemoveMana(client, cost, f_ChargeInterval[client] + 2.0);

	float amtCharged = (f_ChargeAmt[client] / f_ChargeRequirement[client]);

	if (prevAmt < 0.33 && amtCharged >= 0.33)
	{
		StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP);
		EmitSoundToClient(client, SOUND_CHARGE_LOOP, client, _, _, _, _, 100);
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_MID);
	}
	else if (prevAmt < 0.66 && amtCharged >= 0.66)
	{
		StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP);
		EmitSoundToClient(client, SOUND_CHARGE_LOOP, client, _, _, _, _, 120);
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_HIGH);
	}
	else if (prevAmt < 1.0 && amtCharged >= 1.0)
	{
		StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP);
		EmitSoundToClient(client, SOUND_CHARGE_LOOP, client, _, _, _, _, 140);
		EmitSoundToClient(client, SOUND_ELECTRICITY_LOOP, client, _, _, _, _, 120);
		EmitSoundToClient(client, SOUND_CHARGE_MAX_NOTIF, client, _, _, _, _, 120);
		TF2_AddCondition(client, TFCond_FocusBuff);
		Utility_HUDNotification_Translation(client, "Raigeki Fully Charged");
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_MAX);
	}

	f_ChargeCurrentRes[client] = 1.0 - (f_ChargeBaseRes[client] + (f_ChargeBonusRes[client] * amtCharged));

	//Trigger Static Electricity shockwave:
	float pos[3];
	WorldSpaceCenter(client, pos);

	float dmg = f_ChargeDMG[client];
	if (f_Energy[client] > 0.0)
		dmg *= (1.0 + ((f_Energy[client] / 100.0) * Charge_EnergyMult[i_ChargeTier[client]]));

	b_StaticHitting[client] = true;
	Explode_Logic_Custom(dmg, client, client, weapon, pos, f_ChargeRadius[client], f_ChargeFalloff[client], 1.0, _, i_ChargeMaxTargets[client], false, 1.0, view_as<Function>(Raigeki_StaticElectricity_OnHit));
	b_StaticHitting[client] = false;

	f_NextCharge[client] = GetGameTime() + f_ChargeInterval[client];
	Raigeki_HUD(client, weapon, true);
}

void Raigeki_GetTrailColors(int tier, int &r, int &g, int &b, int &a, char sprite[255], float amtCharged)
{
	Format(sprite, sizeof(sprite), "%s", tier < 5 ? "materials/sprites/laserbeam.vmt" : "materials/sprites/glow02.vmt");
	if (tier >= 5)
		a = 255;

	switch (tier)
	{
		case 0:	//Tier 0: Gray -> White
		{
			r = 55 + RoundToFloor(amtCharged * 200.0);
			g = 55 + RoundToFloor(amtCharged * 200.0);
			b = 55 + RoundToFloor(amtCharged * 200.0);
		}
		case 1:	//Tier 1: Dark Red -> Red
		{
			r = 255;
			g = RoundToFloor(amtCharged * 160.0);
			b = RoundToFloor(amtCharged * 160.0);
		}
		case 2:	//Tier 2: Dark Orange -> Orange
		{
			r = 255;
			g = 40 + RoundToFloor(amtCharged * 180.0);
			b = RoundToFloor(amtCharged * 160.0);
		}
		case 3:	//Tier 3: Dark Yellow -> Yellow
		{
			r = 255;
			g = 255;
			b = RoundToFloor(amtCharged * 160.0);
		}
		case 4:	//Tier 4: Dark Blue -> Blue
		{
			r = RoundToFloor(amtCharged * 160.0);
			g = RoundToFloor(amtCharged * 160.0);
			b = 255;
		}
		default: //Tier 5+: Dark Red
		{
			r = 255;
			g = RoundToFloor(amtCharged * 160.0);
			b = RoundToFloor(amtCharged * 160.0);
		}
	}
}

void Raigeki_DoChargeVFX(int client)
{
	float pos[3];
	WorldSpaceCenter(client, pos);
	pos[2] += 10.0;

	float amtCharged = (f_ChargeAmt[client] / f_ChargeRequirement[client]);

	int numSparks = 1;// + RoundToFloor(amtCharged / 0.5);
	float beamWidth = 0.1 + (amtCharged * 2.0);

	int r, g, b, a = 10 + RoundToFloor(70.0 * amtCharged);
	char sprite[255];
	Raigeki_GetTrailColors(i_ChargeTier[client], r, g, b, a, sprite, amtCharged);

	float randOffset = GetRandomFloat(0.0, 360.0);

	for (int i = 0; i < numSparks; i++)
	{
		int trail = CreateTrail(sprite, a, f_ChargeInterval[client], 0.1, _, view_as<int>(RENDER_TRANSALPHAADD));
		if (IsValidEntity(trail))
		{
			float ang[3], spawnPos[3];
			GetClientAbsAngles(client, ang);

			ang[0] = GetRandomFloat(-10.0, -15.0);

			//No clue why, but if there's more than one trail, one of them always spawns above the user's head and I can't figure out why.
			//Increasing the "i + 1" to something like "i + 3" reduces the amount by which this happens, but doesn't fix it, and throws everything else off. It's very weird.
			ang[1] = randOffset;// + (((360.0 / float(numSparks)) * float(i + 1)) + GetRandomFloat(-20.0, 20.0));
			if (ang[1] >= 360.0)
				ang[1] %= 360.0;

			f_ChargeTrailTargWidth[trail] = beamWidth;
			f_ChargeTrailDist[trail] = f_ChargeRadius[client];
			f_ChargeTrailSpeed[trail] = 1.0 + (amtCharged * 1.0);

			GetPointInDirection(pos, ang, f_ChargeTrailDist[trail], spawnPos);

			SetEntityRenderColor(trail, r, g, b, a);

			TeleportEntity(trail, spawnPos);

			i_ChargeTrailTarget[trail] = GetClientUserId(client);
			RequestFrame(Raigeki_ChargeTrailVFX, EntIndexToEntRef(trail));
		}
	}

	f_NextChargeVFX[client] = GetGameTime() + fmax((f_ChargeInterval[client] * 1.75), 0.3);	//VFX interval is 75% longer than charge interval, with a minimum interval of 0.3s, so that we aren't spamming VFX *too* much.
}

public void Raigeki_ChargeTrailVFX(int ref)
{
	int trail = EntRefToEntIndex(ref);
	if (!IsValidEntity(trail))
		return;

	int target = GetClientOfUserId(i_ChargeTrailTarget[trail]);
	if (!IsValidClient(target) || !IsPlayerAlive(target) || dieingstate[target] > 0)
	{
		RemoveEntity(trail);
		return;
	}

	float pos[3], currentPos[3], ang[3];
	WorldSpaceCenter(target, pos);
	pos[2] += 10.0;
	WorldSpaceCenter(trail, currentPos);
	GetAngleBetweenPoints(pos, currentPos, ang);

	ang[1] += 3.0 * f_ChargeTrailSpeed[trail];
	if (ang[1] >= 360.0)
		ang[1] %= 360.0;

	f_ChargeTrailDist[trail] -= f_ChargeTrailSpeed[trail];
	GetPointInDirection(pos, ang, f_ChargeTrailDist[trail], pos);

	for (int vec = 0; vec < 3; vec++)
		pos[vec] += GetRandomFloat(-6.0, 6.0);

	TeleportEntity(trail, pos);

	if (f_ChargeTrailDist[trail] <= 0.0)
	{
		ShrinkTrailIntoNothing(trail, 0.33);
		return;
	}

	float width = GetEntPropFloat(trail, Prop_Data, "m_flStartWidth");
	if (width < f_ChargeTrailTargWidth[trail])
	{
		width += f_ChargeTrailSpeed[trail] * 0.05;
		SetEntPropFloat(trail, Prop_Data, "m_flStartWidth", width);
		SetEntPropFloat(trail, Prop_Data, "m_flEndWidth", 0.0);
	}

	RequestFrame(Raigeki_ChargeTrailVFX, ref);
}

public void Raigeki_StaticElectricity_OnHit(int attacker, int victim, float damage)
{
	float startPos[3], endPos[3];
	WorldSpaceCenter(attacker, startPos);
	WorldSpaceCenter(victim, endPos);
	startPos[2] += 10.0;
	endPos[2] += 10.0;

	int r, g, b, a;
	char sprite[255];
	Raigeki_GetTrailColors(i_ChargeTier[attacker], r, g, b, a, sprite, 1.0);

	SpawnBeam_Vectors(startPos, endPos, 0.2, r, g, b, 255, Model_Lightning, 3.0, 3.0, _, 8.0);

	EmitSoundToAll(g_StaticSounds[GetRandomInt(0, sizeof(g_StaticSounds) - 1)], attacker, _, 80, _, _, GetRandomInt(80, 120));

	Energy_Give(attacker, -Charge_EnergyDrain[i_ChargeTier[attacker]], victim, i_ChargeTier[attacker]);
	return;
}

void Raigeki_TerminateCharge(int client)
{
	f_ChargeCurrentRes[client] = 1.0;
	RemoveSpecificBuff(client, "Charging Raigeki");
	Raigeki_TerminateChargeFX(client);
	b_ChargingRaigeki[client] = false;
}

void Raigeki_TerminateChargeFX(int client)
{
	StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP);
	StopSound(client, SNDCHAN_AUTO, SOUND_ELECTRICITY_LOOP);
	TF2_RemoveCondition(client, TFCond_FocusBuff);
	Raigeki_RemoveParticle(client);
}

void Raigeki_ReadStats(int client, int weapon, int tier)
{
	f_ChargeRadius[client] = Charge_Radius[tier];
	f_ChargeCost[client] = Charge_Cost[tier];
	f_ChargeCostAtFullCharge[client] = Charge_CostAtFullCharge[tier];
	f_ChargeRequirement[client] = Charge_Requirement[tier];
	f_ChargeMin[client] = Charge_Min[tier];
	f_ChargeInterval[client] = Charge_Interval[tier];
	f_ChargeBaseRes[client] = Charge_InstantRes[tier];
	f_ChargeBonusRes[client] = Charge_BonusRes[tier];
	f_ChargeDMG[client] = Charge_DMG[tier];
	f_ChargeFalloff[client] = Charge_Falloff[tier];
	i_ChargeMaxTargets[client] = Charge_MaxTargets[tier];

	float mult = 1.0;
	//Radius scales with both projectile velocity *and* projectile lifespan modifiers.
	if (IsValidEntity(weapon))
    {
        mult *= Attributes_Get(weapon, 103, 1.0);
        mult *= Attributes_Get(weapon, 104, 1.0);
        mult *= Attributes_Get(weapon, 475, 1.0);
        mult *= Attributes_Get(weapon, 101, 1.0);
        mult *= Attributes_Get(weapon, 102, 1.0);
    }
    if (i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
        mult *= 1.2;

	f_ChargeRadius[client] *= mult;
	mult = 1.0;

	//Mana cost, max mana to fully charge Raigeki, and min mana required to activate Raigeki all scale with mana cost modifiers.
	if (IsValidEntity(weapon))
		mult = Attributes_Get(weapon, 733, 1.0);

	f_ChargeCost[client] *= mult;
	f_ChargeCostAtFullCharge[client] *= mult;
	f_ChargeRequirement[client] *= mult;
	f_ChargeMin[client] *= mult;
	mult = 1.0;

    //Damage scales with damage modifiers. Obviously.
	if (IsValidEntity(weapon))
        mult = Attributes_Get(weapon, 410, 1.0);

	f_ChargeDMG[client] *= mult;
	mult = 1.0;

    //Charge interval (rate at which mana is consumed, charge is given, and Static Electricity deals damage) scales with attack rate modifiers:
	if (IsValidEntity(weapon))
        mult = Attributes_Get(weapon, 6, 1.0);
    if (i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE)
        mult *= 0.83;

	f_ChargeInterval[client] *= mult;
	f_NextCharge[client] = GetGameTime() + f_ChargeInterval[client];
}

public void Raigeki_Attack_0(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 0);
}

public void Raigeki_Attack_1(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 1);
}

public void Raigeki_Attack_2(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 2);
}

public void Raigeki_Attack_3(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 3);
}

public void Raigeki_Attack_4(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 4);
}

public void Raigeki_Attack_5(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 5);
}

static int i_RemainingBlades[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeStartEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeEndEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeBeamEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeIntendedTarget[MAXPLAYERS + 1] = { -1, ... };

static float f_BladeRange[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeBaseDMG[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeDMG[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeFalloff[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeWidth[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeStartAng[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeTargAng[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeStartTime[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeEndTime[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeProgress[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeProgressPrevious[MAXPLAYERS + 1] = { 0.0, ... };
static float f_BladeInterval[MAXPLAYERS + 1] = { 0.0, ... };

static float vec_BladeSwingAng[MAXPLAYERS + 1][3];

static bool Raigeki_Hit[MAXPLAYERS + 1][2049];

static ArrayList g_BladeTrails[MAXPLAYERS + 1] = { null, ... };

public int Blade_GetStartEnt(int client) { return EntRefToEntIndex(i_BladeStartEnt[client]); }
public int Blade_GetEndEnt(int client) { return EntRefToEntIndex(i_BladeEndEnt[client]); }
public int Blade_GetBeamEnt(int client) { return EntRefToEntIndex(i_BladeBeamEnt[client]); }

public void Blade_DeleteBeam(int client)
{
	int ent = Blade_GetStartEnt(client);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	ent = Blade_GetEndEnt(client);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	ent = Blade_GetBeamEnt(client);
	if (IsValidEntity(ent))
		RemoveEntity(ent);

	i_BladeBeamEnt[client] = -1;
	i_BladeEndEnt[client] = -1;
	i_BladeStartEnt[client] = -1;

	if (g_BladeTrails[client] != null)
	{
		for (int i = 0; i < GetArraySize(g_BladeTrails[client]); i++)
		{
			int trail = EntRefToEntIndex(GetArrayCell(g_BladeTrails[client], i));
			if (IsValidEntity(trail))
			{
				ShrinkTrailIntoNothing(trail, 0.33);
			}
		}

		delete g_BladeTrails[client];
		g_BladeTrails[client] = null;
	}
}

void Raigeki_FireWave(int client, int weapon, int tier)
{
	if (b_ChargingRaigeki[client])
	{
		Utility_HUDNotification_Translation(client, "Raigeki Primary Attack Blocked By Charge", true);
		return;
	}

	int mana_cost = RoundFloat(M1_Cost[tier] * Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
        i_BladeTier[client] = tier;
        i_RemainingBlades[client] = M1_NumBlades[tier];
		if (b_Supercharged[client] && Energy_Enabled[tier])
			i_RemainingBlades[client] += Supercharge_ExtraBlades[tier];

		Raigeki_StartDelayingAttacks(client, weapon);
		Blade_StartSwing(client);
        
        Utility_RemoveMana(client, mana_cost, (f_BladeInterval[client] * float(M1_NumBlades[tier])) + 1.25);
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

public bool Blade_OnlyEnemies(int entity, int contentsMask, int user)
{
	if (IsValidEnemy(user, entity, true) && entity != user)
		return true;
	
	return false;
}

void Blade_ReadStats(int client, int tier)
{
    int weapon = Raigeki_GetWeapon(client);

    f_BladeRange[client] = M1_Range[tier];
    f_BladeBaseDMG[client] = M1_Damage[tier];
    f_BladeWidth[client] = M1_Width[tier];
    f_BladeInterval[client] = M1_Interval[tier];

	if (b_Supercharged[client] && Energy_Enabled[tier])
	{
		f_BladeBaseDMG[client] *= Supercharge_DMGMult[tier];
		f_BladeInterval[client] /= Supercharge_SpeedMult[tier];
		f_BladeRange[client] *= Supercharge_RangeMult[tier];
		f_BladeWidth[client] *= Supercharge_WidthMult[tier];
	}

    //Range scales with both projectile velocity *and* projectile lifespan modifiers, but receives 40% less scaling from attributes because otherwise it snowballs WAY too quickly and gets insane BS range like 800 HU from just a couple buffs.
    if (IsValidEntity(weapon))
    {
        f_BladeRange[client] *= Attributes_Get(weapon, 103, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 104, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 475, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 101, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 102, 1.0);
    }

	float diff = f_BladeRange[client] - M1_Range[tier];
	if (fabs(diff) > 0.0)
		f_BladeRange[client] -= diff * 0.4;

	//Beer gets full scaling, because otherwise there's really no point in using it.
	if (i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
        f_BladeRange[client] *= 1.2;

    //Damage scales with damage modifiers. Obviously.
    if (IsValidEntity(weapon))
        f_BladeBaseDMG[client] *= Attributes_Get(weapon, 410, 1.0);

    //Arc width scales with radius modifiers, but is capped to 360.0.
    if (IsValidEntity(weapon))
    {
        f_BladeWidth[client] *= Attributes_Get(weapon, 103, 1.0);
        f_BladeWidth[client] *= Attributes_Get(weapon, 104, 1.0);
        f_BladeWidth[client] *= Attributes_Get(weapon, 475, 1.0);
        f_BladeWidth[client] *= Attributes_Get(weapon, 101, 1.0);
        f_BladeWidth[client] *= Attributes_Get(weapon, 102, 1.0);
    }
    if (f_BladeWidth[client] > 360.0)
        f_BladeWidth[client] = 360.0;

    //Sweep speed scales with attack rate modifiers, but for optimization purposes, can NEVER go below 0.15.
    if (IsValidEntity(weapon))
        f_BladeInterval[client] *= Attributes_Get(weapon, 6, 1.0);
    if (i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE)
        f_BladeInterval[client] *= 0.83;
    if (f_BladeInterval[client] < 0.15)
        f_BladeInterval[client] = 0.15;

    f_BladeDMG[client] = f_BladeBaseDMG[client];
    f_BladeFalloff[client] = M1_Falloff[tier];
}

void Blade_StartSwing(int client)
{
	if (b_ChargingRaigeki[client])
		return;

	Blade_ReadStats(client, i_BladeTier[client]);
    
    float ang[3], pos[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);

	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, Blade_OnlyEnemies, client);
    if (TR_DidHit(trace))
    {
        int targ = TR_GetEntityIndex(trace);
        if (IsValidEnemy(targ, client))
            i_BladeIntendedTarget[client] = EntIndexToEntRef(targ);
    }
    delete trace;

	FinishLagCompensation_Base_boss();

	if (ang[0] > 60.0)
        ang[0] = 60.0;
    if (ang[0] < -60.0)
        ang[0] = -60.0;

    float startAng = ang[1] + (f_BladeWidth[client] * 0.5);
    float targAng = ang[1] - (f_BladeWidth[client] * 0.5);

    for (int i = 0; i < 3; i++)
        vec_BladeSwingAng[client][i] = ang[i];

    f_BladeStartAng[client] = startAng;
    f_BladeTargAng[client] = targAng;

    f_BladeStartTime[client] = GetGameTime();
    f_BladeEndTime[client] = GetGameTime() + f_BladeInterval[client];
    f_BladeProgressPrevious[client] = 0.0;

    EmitSoundToAll(SOUND_RAIGEKI_BLADE_SWEEP, client, _, 120, _, _, GetRandomInt(80, 120));
	if (b_Supercharged[client])
		EmitSoundToAll(SOUND_SUPERCHARGED_SWING, client, _, 120, _, _, GetRandomInt(80, 120));

    for (int i = 0; i < 2049; i++)
    {
        Raigeki_Hit[client][i] = false;
    }

	RequestFrame(Blade_Sweep, GetClientUserId(client));
}

public void Blade_Sweep(int id)
{
	int client = GetClientOfUserId(id);
	float gt = GetGameTime();

	if (!IsValidMulti(client) || gt >= f_BladeEndTime[client])
	{
		if (IsValidClient(client))
        {
			Blade_DeleteBeam(client);

			i_RemainingBlades[client]--;
            if (i_RemainingBlades[client] > 0 && Raigeki_IsHoldingCorrectWeapon(client))
                Blade_StartSwing(client);
			else
				Raigeki_StopDelayingAttacks(client);
        }

		return;
	}

	float ang[3];
	for (int i = 0; i < 3; i++)
		ang[i] = vec_BladeSwingAng[client][i];

	float totalMove = f_BladeTargAng[client] - f_BladeStartAng[client];
	float duration = f_BladeEndTime[client] - f_BladeStartTime[client];
	float timePassed = gt - f_BladeStartTime[client];

	f_BladeProgress[client] = clamp(timePassed / duration, 0.0, 1.0);
	ang[1] = f_BladeStartAng[client] + (f_BladeProgress[client] * totalMove);

	float eyePos[3];
	GetClientEyePosition(client, eyePos);

	//When the beam moves too quickly and has too much range, it can miss targets who are far enough away but still technically within range.
	//To "fix" this, we just run a bunch of extra traces between the beam's previous and current points.
	float diff = f_BladeProgress[client] - f_BladeProgressPrevious[client];
	if (diff > 0.02)
    {
        for (float i = 0.02; i <= diff; i += 0.02)
        {
            float diffAng[3];
            diffAng = ang;
            diffAng[1] = f_BladeStartAng[client] + ((f_BladeProgress[client] - i) * totalMove);

            Utility_FireLaser(client, eyePos, diffAng, 0.0, f_BladeRange[client], 0.0, DMG_GENERIC, _, _, Blade_OnHit, _, Blade_OnlyThoseNotHit);
        }
    }

	Utility_FireLaser(client, eyePos, ang, 0.0, f_BladeRange[client], 0.0, DMG_GENERIC, _, _, Blade_OnHit, Blade_MoveBeam, Blade_OnlyThoseNotHit);

	f_BladeProgressPrevious[client] = f_BladeProgress[client];

	RequestFrame(Blade_Sweep, id);
}

public void Blade_OnHit(int victim, int attacker)
{
    if (Raigeki_Hit[attacker][victim] || !Can_I_See_Enemy_Only(attacker, victim))
        return;

    float dmg = f_BladeDMG[attacker];
    if (victim == EntRefToEntIndex(i_BladeIntendedTarget[attacker]))
    {
        dmg = f_BladeBaseDMG[attacker];
    }

    float force[3], pos[3], forceAng[3];

    for (int i = 0; i < 3; i++)
	    forceAng[i] = vec_BladeSwingAng[attacker][i];
	forceAng[1] = f_BladeStartAng[attacker] + ((f_BladeProgress[attacker]) * (f_BladeTargAng[attacker] - f_BladeStartAng[attacker]));
    
	CalculateDamageForce(forceAng, 10000.0, force);
    WorldSpaceCenter(victim, pos);

    int weapon = Raigeki_GetWeapon(attacker);
	b_BladeHitting[attacker] = true;
    SDKHooks_TakeDamage(victim, attacker, attacker, dmg, DMG_PLASMA, (IsValidEntity(weapon) ? weapon : -1), force, pos, false, ZR_DAMAGE_LASER_NO_BLAST);
	b_BladeHitting[attacker] = true;
	Energy_Give(attacker, Energy_OnHit[i_BladeTier[attacker]], victim, i_BladeTier[attacker]);

    Raigeki_Hit[attacker][victim] = true;
    f_BladeDMG[attacker] *= f_BladeFalloff[attacker];
}

public bool Blade_OnlyThoseNotHit(int victim, int attacker) { return !Raigeki_Hit[attacker][victim]; }

public void Blade_MoveBeam(int client, float startPos[3], float endPos[3], float ang[3], float width)
{
	float strength = 1.0 - (2.0 * fabs(f_BladeProgress[client] - 0.5));

	float beamWidth = 0.1 + (strength * 6.0);

	GetPointInDirection(startPos, ang, 20.0, startPos);
	startPos[2] -= 25.0;
	endPos[2] -= 25.0;

	int r, g, b, a;
	char sprite[255];
	Raigeki_GetTrailColors(i_BladeTier[client], r, g, b, a, sprite, strength);

	int beam, start, end;
	beam = Blade_GetBeamEnt(client);
	if (!IsValidEntity(beam))
	{
		beam = CreateEnvBeam(-1, -1, startPos, endPos, _, _, start, end, r, g, b, RoundToFloor(255.0 * strength), _, beamWidth, beamWidth);
		i_BladeBeamEnt[client] = EntIndexToEntRef(beam);
		i_BladeStartEnt[client] = EntIndexToEntRef(start);
		i_BladeEndEnt[client] = EntIndexToEntRef(end);
	}
	else
	{
		start = Blade_GetStartEnt(client);
		end = Blade_GetEndEnt(client);
	}

	if (g_BladeTrails[client] == null)
	{
		g_BladeTrails[client] = CreateArray(255);

		int numTrails = RoundToFloor(f_BladeRange[client] / 75.0);
		for (int i = 0; i < numTrails; i++)
		{
			int trail = CreateTrail(sprite, a, f_BladeInterval[client] * 0.425, beamWidth, _, view_as<int>(RENDER_TRANSALPHAADD));
			if (IsValidEntity(trail))
				PushArrayCell(g_BladeTrails[client], EntIndexToEntRef(trail));
		}
	}

	SetEntityRenderColor(beam, r, g, b, RoundToFloor(255.0 * strength));
	SetEntPropFloat(beam, Prop_Data, "m_fWidth", beamWidth);
	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", beamWidth);

	SetEntityMoveType(start, MOVETYPE_NOCLIP);
	SetEntityMoveType(end, MOVETYPE_NOCLIP);
	SetEntityMoveType(beam, MOVETYPE_NOCLIP);
	TeleportEntity(start, startPos);
	TeleportEntity(end, endPos);

	GetAngleBetweenPoints(endPos, startPos, ang);

	if (g_BladeTrails[client] != null)
	{
		for (int i = 0; i < GetArraySize(g_BladeTrails[client]); i++)
		{
			int trail = EntRefToEntIndex(GetArrayCell(g_BladeTrails[client], i));
			if (IsValidEntity(trail))
			{
				float trailPos[3];
				GetPointInDirection(endPos, ang, float(i) * 75.0, trailPos);

				trailPos[0] += GetRandomFloat(-5.0, 5.0);
               	trailPos[1] += GetRandomFloat(-5.0, 5.0);
                trailPos[2] += GetRandomFloat(-12.0, 12.0);

				TeleportEntity(trail, trailPos);

				SetEntPropFloat(trail, Prop_Data, "m_flStartWidth", beamWidth);
				SetEntPropFloat(trail, Prop_Data, "m_flEndWidth", 0.0);

				SetEntityRenderColor(trail, r, g, b, RoundToFloor(strength * 50.0));
			}
		}
	}
}

ArrayList Laser_HitList;

stock bool Laser_LOSCheck(int entity, int contentsmask, int target)
{
	if (IsValidClient(entity) || entity == target || (!b_NpcHasDied[entity] && b_ThisWasAnNpc[entity]) || i_IsABuilding[entity] || b_IsAProjectile[entity] || !b_is_a_brush[entity])
		return false;

	return true;
}

/**
 * Automatically runs a hull trace, and damages all enemies caught.
 * 
 * @param client		The client firing the laser.
 * @param startPos		Origin of the laser.
 * @param ang			Angle in which to fire the laser.
 * @param width			Hull trace width. Can be set to 0.0 or below to use a ray instead of a hull.
 * @param range			Hull trace length.
 * @param damage		Damage to deal.
 * @param damagetype	Damage type.
 * @param weapon		Optional weapon parameter.
 * @param inflictor		Optional inflictor parameter.
 * @param onHitFunc		Optional function to call when the laser hits an enemy. Must take the victim's index and the attacker's index, in that order.
 * @param drawLaserFunc	Optional function to call to draw the beam. Must take the attacker's index, the start vector of the beam, the end vector of the beam, the angle vector of the beam, and the beam's width (float), all in that order.
 * @param filterFunc	Optional function to filter out certain entities from being hit by the laser. Must take the victim's index and the attacker's index in that order, and return a bool (true to allow the hit, false to prevent it).
 */
stock void Utility_FireLaser(int client, float startPos[3], float ang[3], float width, float range, float damage, int damagetype, int weapon = -1, int inflictor = -1, Function onHitFunc = INVALID_FUNCTION, Function drawLaserFunc = INVALID_FUNCTION, Function filterFunc = INVALID_FUNCTION)
{
	float endPos[3];

	GetPointInDirection(startPos, ang, range, endPos);
	Handle trace = TR_TraceRayFilterEx(startPos, endPos, MASK_SHOT, RayType_EndPoint, Laser_LOSCheck, client);
	if (TR_DidHit(trace))
		TR_GetEndPosition(endPos, trace);
	delete trace;

	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	Laser_HitList = CreateArray(255);

	if (width > 0.0)
	{
		float hullMin[3], hullMax[3];

		hullMin[0] = -width;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];

		TR_TraceHullFilter(startPos, endPos, hullMin, hullMax, 1073741824, Laser_Trace, client);
	}
	else
	{
		TR_TraceRayFilter(startPos, endPos, 1073741824, RayType_EndPoint, Laser_Trace, client);
	}

	FinishLagCompensation_Base_boss();

	if (GetArraySize(Laser_HitList) > 0)
	{
		for (int i = 0; i < GetArraySize(Laser_HitList); i++)
		{
			int target = GetArrayCell(Laser_HitList, i);

			if (filterFunc != INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, filterFunc);

				Call_PushCell(target);
				Call_PushCell(client);

				bool result = true;
				Call_Finish(result);
				if (!result)
					continue;
			}

			if (damage > 0.0)
			    SDKHooks_TakeDamage(target, IsValidEntity(inflictor) ? inflictor : client, client, damage, damagetype, IsValidEntity(weapon) ? weapon : -1);

			if (onHitFunc != INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, onHitFunc);

				Call_PushCell(target);
				Call_PushCell(client);

				Call_Finish();
			}
		}
	}

	delete Laser_HitList;

	if (drawLaserFunc != INVALID_FUNCTION)
	{
		Call_StartFunction(INVALID_HANDLE, drawLaserFunc);

		Call_PushCell(client);
		Call_PushArray(startPos, 3);
		Call_PushArray(endPos, 3);
		Call_PushArray(ang, 3);
		Call_PushFloat(width);

		Call_Finish();
	}
}

stock bool Laser_Trace(int entity, int contentsMask, int client)
{
	if (IsValidEnemy(client, entity, true))
		PushArrayCell(Laser_HitList, entity);

	return false;
}

stock void GetPointInDirection(float startPos[3], float ang[3], float distance, float endPos[3])
{
	float buffer[3];
	GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(buffer, distance);
	AddVectors(startPos, buffer, endPos);
}

/**
 * Gets the angle pointing from point A to point B.
 * 
 * @param pointA		Start position.
 * @param pointB		End position.
 * @param output		Output vector.
 * @param xOff			Optional X-axis offset for the start position.
 * @param yOff			Optional Y-axis offset for the start position.
 * @param zOff			Optional Z-axis offset for the start position.
 * 
 * @return		The angle from point A to point B, stored in the output vector.
 */
stock void GetAngleBetweenPoints(float pointA[3], float pointB[3], float output[3], float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	float midPoint[3], pointACopy[3];
	pointACopy = pointA;
	pointACopy[0] += xOff;
	pointACopy[1] += yOff;
	pointACopy[2] += zOff;

	SubtractVectors(pointB, pointACopy, midPoint);
	NormalizeVector(midPoint, midPoint);
	GetVectorAngles(midPoint, output);
}

stock int CreateTrail(char[] trail, int alpha, float lifetime=1.0, float startwidth=22.0, float endwidth=0.0, int rendermode = 4)
{
	int entIndex = CreateEntityByName("env_spritetrail");
	if (entIndex > 0 && IsValidEntity(entIndex))
	{
		DispatchKeyValue(entIndex, "spritename", trail);
		SetEntPropFloat(entIndex, Prop_Send, "m_flTextureRes", 0.00005);
		
		char sTemp[5];
		IntToString(alpha, sTemp, sizeof(sTemp));
		DispatchKeyValue(entIndex, "renderamt", sTemp);
		
		DispatchKeyValueFloat(entIndex, "lifetime", lifetime);
		DispatchKeyValueFloat(entIndex, "startwidth", startwidth);
		DispatchKeyValueFloat(entIndex, "endwidth", endwidth);

		IntToString(rendermode, sTemp, sizeof(sTemp));
		DispatchKeyValue(entIndex, "rendermode", sTemp);
		
		DispatchSpawn(entIndex);

		return entIndex;
	}

	return -1;
}

stock void ShrinkTrailIntoNothing(int trail, float rate)
{
	DataPack pack = new DataPack();
	RequestFrame(Shrink_Trail, pack);
	WritePackCell(pack, EntIndexToEntRef(trail));
    WritePackFloat(pack, rate);
}

stock void Shrink_Trail(DataPack pack)
{
    ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	float rate = ReadPackFloat(pack);

	if (!IsValidEntity(entity))
    {
        delete pack;
		return;
    }
	
	float width = GetEntPropFloat(entity, Prop_Data, "m_flStartWidth");
	width -= rate;
	if (width <= 0.0)
	{
		width = 0.0;
		CreateTimer(0.1, Timer_RemoveEntity, entity, TIMER_FLAG_NO_MAPCHANGE);
		SetEntPropFloat(entity, Prop_Data, "m_flStartWidth", width);
		return;
	}

	SetEntPropFloat(entity, Prop_Data, "m_flStartWidth", width);
	SetEntPropFloat(entity, Prop_Data, "m_flEndWidth", 0.0);

	RequestFrame(Shrink_Trail, pack);
}

stock void MakeEntityFadeOut(int entity, int rate, bool remove = true)
{
	DataPack pack = new DataPack();
	RequestFrame(Fade_Out, pack);
	WritePackCell(pack, EntIndexToEntRef(entity));
    WritePackCell(pack, rate);
    WritePackCell(pack, remove);
}

stock void Fade_Out(DataPack pack)
{
    ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	int rate = ReadPackCell(pack);
    bool remove = ReadPackCell(pack);
	
	if (!IsValidEntity(entity))
    {
        delete pack;
		return;
    }
	
	int r, g, b, a;
	GetEntityRenderColor(entity, r, g, b, a);
	a -= rate;
	if (a < 0)
		a = 0;
		
	SetEntityRenderColor(entity, r, g, b, a);
	
	if (a == 0)
	{
		if (remove)
			RemoveEntity(entity);
		
		delete pack;
		return;
	}

	RequestFrame(Fade_Out, pack);
}

/**
 * Creates two info_targets, one for the root and one for the end, then draws an env_beam between them.
 * 
 * @param startEnt		The entity to which the root of the env_beam should be parented. If not a valid entity: do not parent to anything.
 * @param endEnt		The entity to which the end of the env_beam should be parented. If not a valid entity: do not parent to anything.
 * @param startPos		The origin of the beginning of the env_beam.
 * @param endPos		The origin of the end of the env_beam.
 * @param startPoint	If startEnt is a valid entity: attach the root of the env_beam to this attachment point. If this is used, "startPos" is used as an offset.
 * @param endPoint		If endEnt is a valid entity: attach the end of the env_beam to this attachment point. If this is used, "endPos" is used as an offset.
 * @param startOutput	If you pass a variable to this parameter, it will be changed to the entity index of the info_target used for the root of the env_beam.
 * @param endOutput		If you pass a variable to this parameter, it will be changed to the entity index of the info_target used for the end of the env_beam.
 * @param r				RGBA "R" value (0-255).
 * @param g				RGBA "G" value (0-255).
 * @param b				RGBA "B" value (0-255).
 * @param a				RGBA "A" value (0-255).
 * @param model			Sprite to use.
 * @param width			Width of the env_beam at its start.
 * @param endWidth		Width of the env_beam at its end.
 * @param fadelength	No idea.
 * @param amplitude		The "strength" of the env_beam. Higher values cause the beam to sporadically shake with higher fluctuations. 0.0 means the beam does not shake at all.
 * @param speed			Scroll speed of the env_beam's sprite.
 * @param duration		Time until the beam automatically expires. <= 0.0: infinite.
 * 
 * @return	The entity index of the env_beam, or -1 on failure. If either of the info_targets fail to be created, the env_beam itself will still be returned, but it will not be connected to anything.
 */
stock int CreateEnvBeam(int startEnt, int endEnt, float startPos[3] = NULL_VECTOR, float endPos[3] = NULL_VECTOR, char[] startPoint = "", char[] endPoint = "", int &startOutput = -1, int &endOutput = -1, int r = 255, int g = 255, int b = 255, int a = 255, char[] model = "materials/sprites/laserbeam.vmt", float width = 2.0, float endWidth = 2.0, float fadelength = 1.0, float amplitude = 0.0, float speed = 0.0, float duration = 0.0)
{
	int beam = CreateEntityByName("env_beam");
	if (!IsValidEntity(beam))
		return -1;

	SetEntityModel(beam, model);

	char color[32];
	Format(color, sizeof(color), "%i %i %i", r, g, b);
	DispatchKeyValue(beam, "rendercolor", color);

	char alpha[8];
	Format(alpha, sizeof(alpha), "%i", a);
	DispatchKeyValue(beam, "renderamt", alpha);

	DispatchKeyValue(beam, "life", "0");

	DispatchSpawn(beam);

	SetEntityRenderMode(beam, RENDER_TRANSALPHA);

	int root = CreateEntityByName("info_target");
	int end = CreateEntityByName("info_target");

	if (!IsValidEntity(root) || !IsValidEntity(end))
	{
		if (IsValidEntity(root))
			RemoveEntity(root);
		if (IsValidEntity(end))
			RemoveEntity(end);

		return beam;
	}

	DispatchSpawn(root);
	DispatchSpawn(end);
	SetEntityMoveType(root, MOVETYPE_NOCLIP);
	SetEntityMoveType(end, MOVETYPE_NOCLIP);
	SetEntityMoveType(beam, MOVETYPE_NOCLIP);

	TeleportEntity(root, startPos);
	TeleportEntity(end, endPos);

	if (IsValidEntity(startEnt))
		SetParent(startEnt, root, startPoint, startPos);
	if (IsValidEntity(endEnt))
		SetParent(endEnt, end, endPoint, endPos);

	SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(root));
	SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(end), 1);

	SetEntProp(beam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(beam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", endWidth);

	SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amplitude);

	SetEntPropFloat(beam, Prop_Data, "m_fSpeed", speed);
	SetEntPropFloat(beam, Prop_Data, "m_fFadeLength", fadelength);

	//SetVariantFloat(32.0);
	//AcceptEntityInput(beam, "Amplitude");
	AcceptEntityInput(beam, "TurnOn");

	SetVariantInt(0);
	AcceptEntityInput(beam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(beam, "damage");

	if (duration > 0.0)
	{
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(beam), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(root), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(end), TIMER_FLAG_NO_MAPCHANGE);
	}

	startOutput = root;
	endOutput = end;
	return beam;
}

public void Utility_RemoveMana(int client, int amount, float regenDelay)
{
    Current_Mana[client] -= amount;

	SDKhooks_SetManaRegenDelayTime(client, regenDelay);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
}

stock float LerpCurve(float start, float target, float minAmt, float maxAmt)
{
	if (start > target)
	{
		float mult = target / start;

		float rate = mult * maxAmt;
		if (rate < minAmt)
			rate = minAmt;
		else if (rate > maxAmt)
			rate = maxAmt;

		start -= rate;
		if (start < target)
			start = target;
	}
	else if (start < target)
	{
		float mult = target / start;

		float rate = mult * maxAmt;
		if (rate < minAmt)
			rate = minAmt;
		else if (rate > maxAmt)
			rate = maxAmt;

		start += rate;
		if (start > target)
			start = target;
	}

	return start;
}

/*stock void AttachAura(int target, char effect[255])
{
	TE_SetupParticleEffect(effect, PATTACH_ABSORIGIN_FOLLOW, target);
	TE_WriteNum("m_bControlPoint1", target);	
	TE_SendToAll();	
}

stock void RemoveAura(int target, char effect[255])
{
	TE_Start("EffectDispatch");
	TE_WriteNum("entindex", target);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(effect));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
}*/

public void Raigeki_HUD(int client, int weapon, bool forced)
{
	if(f_NextRaigekiHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			char HUDText[255];

			if (Energy_Enabled[i_BladeTier[client]] || Energy_Enabled[i_ChargeTier[client]])
				Format(HUDText, sizeof(HUDText), "Kinetic Energy: %iPCNTG%s", RoundToFloor(100.0 * (f_Energy[client] / 100.0)), f_Energy[client] >= 100.0 ? " (MAX)" : "");

			if (b_Supercharged[client])
				Format(HUDText, sizeof(HUDText), "SUPERCHARGED!\n%s", HUDText);
			else if (b_ChargingRaigeki[client])
				Format(HUDText, sizeof(HUDText), "CHARGING RAIGEKI: %iPCNTG%s\n%s", RoundToFloor(100.0 * (f_ChargeAmt[client] / f_ChargeRequirement[client])), f_ChargeAmt[client] >= f_ChargeRequirement[client] ? " (MAX)" : "", HUDText);

			ReplaceString(HUDText, sizeof(HUDText), "PCNTG", "%%");
			PrintHintText(client, HUDText);
		}

		f_NextRaigekiHUD[client] = GetGameTime() + 0.5;
	}
}

float Player_OnTakeDamage_Raigeki(int victim, float &damage, int attacker)
{
	if (!b_ChargingRaigeki[victim])
		return damage;

	if (!CheckInHud())
	{
		Energy_Give(victim, Energy_OnHurt[i_ChargeTier[victim]], attacker, i_ChargeTier[victim]);
	}

	return damage * f_ChargeCurrentRes[victim];
}

void StatusEffects_Raigeki()
{
	StatusEffect data;

	strcopy(data.BuffName, sizeof(data.BuffName), "Charging Raigeki");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "RGKI");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.5;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func 			= Func_RaigekiText;
	data.OnBuffStarted				= Raigeki_OnBuffApplied;
	data.OnBuffStoreRefresh			= Raigeki_OnBuffApplied;
	data.OnBuffEndOrDeleted			= Raigeki_OnBuffEnd;
	StatusEffect_AddGlobal(data);
}

void Func_RaigekiText(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar,"RGKI [%0.f%%]", 100.0 * (f_ChargeAmt[victim] / f_ChargeRequirement[victim]));
}

static void Raigeki_OnBuffApplied(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 0.5);
	SDKCall_SetSpeed(victim);
}

static void Raigeki_OnBuffEnd(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 2.0);
	SDKCall_SetSpeed(victim);
}