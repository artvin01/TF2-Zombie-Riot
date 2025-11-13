//THIS IS THE PSEUDO-MELEE MAGE WEAPON WITH THE GIANT LIGHTNING BOLT ON M2, NOT TO BE CONFUSED WITH REIUJI!!!!!!!!

//Attribute 733 on this weapon is used as a multiplier for the costs specified in this code. This is so that modifiers, such as from Heavy Mage, can impact the charge cost for M2.

#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is unpapped, then first pap, then second pap, etc.

static int M1_NumBlades[4] = { 1, 2, 3, 4 };			    //Number of blade sweeps to perform in a row per M1.
static float M1_Cost[4] = { 40.0, 60.0, 120.0, 240.0 };		//Primary attack base mana cost.
static float M1_Range[4] = { 180.0, 200.0, 220.0, 240.0 };  //Electric blade range.
static float M1_Width[4] = { 120.0, 140.0, 160.0, 180.0 };  //Electric blade arc swing angle.
static float M1_Damage[4] = { 200.0, 400.0, 600.0, 900.0 }; //Electric blade damage.
static float M1_Falloff[4] = { 0.825, 0.85, 0.875, 0.9 };   //Amount to multiply electric blade damage per target hit.
static float M1_Interval[4] = { 0.5, 0.4, 0.3, 0.2 };       //Time it takes for electric blades to sweep across the screen.

static int Charge_MaxTargets[4] = { 6, 8, 10, 12 };						//Max targets hit at once by Static Electricity ticks.
static float Charge_Cost[4] = { 6.0, 12.0, 24.0, 48.0 };				//Mana drained per interval while charging the M2 ability.
static float Charge_CostAtFullCharge[4] = { 3.0, 6.0, 12.0, 24.0 };		//Mana drained per interval while charging the M2 ability, while it is already fully-charged. This is needed so that the user can't just charge to full, and then keep holding M2 to have Static Electricity and resistance forever at no cost.
static float Charge_Requirement[4] = { 300.0, 600.0, 1200.0, 2400.0 };	//Total mana spent to fully charge the M2 ability.
static float Charge_Min[4] = { 0.2, 0.2, 0.2, 0.2 };					//Minimum charge percentage needed to cast Raigeki. Releasing M2 or running out of mana below this threshold immediately cancels the ability and does not refund anything.
static float Charge_Interval[4] = { 0.3, 0.3, 0.3, 0.3 };				//Interval between Static Electricity shocks and charge gain while charging the M2 ability.
static float Charge_SpeedMod[4] = { 0.5, 0.5, 0.5, 0.5 };				//Base move speed multiplier while charging Raigeki.
static float Charge_InstantRes[4] = { 0.1, 0.125, 0.15, 0.2 };			//Instant damage resistance given as soon as you begin charging Raigeki.
static float Charge_BonusRes[4] = { 0.2, 0.225, 0.25, 0.3 };			//Maximum bonus damage resistance given based on the ability's charge level.
static float Charge_DMG[4] = { 24.0, 48.0, 90.0, 135.0 };				//Base damage per interval dealt per Static Electricity tick while charging.
static float Charge_Radius[4] = { 100.0, 105.0, 110.0, 115.0 };			//Radius in which Static Electricity deals damage.
static float Charge_Falloff[4] = { 0.7, 0.75, 0.8, 0.85 };				//Amount to multiply Static Electricity damage per target hit.

static int Raigeki_MaxTargets[4] = { 9, 10, 11, 12 };						//Maximum number of enemies hit at once with Raigeki.
static float Raigeki_Delay[4] = { 3.0, 3.0, 3.0, 3.0 };						//Duration for which the user is stunned upon casting Raigeki. After this time passes, Raigeki's giant thunderbolt will strike, supercharging the user and ending the stun.
static float Raigeki_ResMult[4] = { 0.8, 0.8, 0.8, 0.8 };					//Amount to multiply damage taken during the stun state while casting Raigeki. This is stacked multiplicatively with the user's current damage resistance granted by charging Raigeki.
static float Raigeki_Damage[4] = { 15000.0, 20000.0, 25000.0, 30000.0 };	//Raigeki's base damage at max charge.
static float Raigeki_Radius[4] = { 450.0, 550.0, 650.0, 800.0 };			//Raigeki's radius at max charge.
static float Raigeki_Falloff_MultiHit[4] = { 0.825, 0.85, 0.875, 0.9 };		//Amount to multiply damage dealt by Raigeki per target hit.
static float Raigeki_Falloff_Radius[4] = { 0.75, 0.8, 0.85, 0.9 };			//Distance-based falloff. Lower numbers = more damage is lost based on distance.
static float Raigeki_Cooldown[4] = { 90.0, 90.0, 90.0, 90.0 };				//Raigeki's cooldown.
static float Raigeki_Cooldown_Failed[4] = { 45.0, 45.0, 45.0, 45.0 };		//Raigeki's cooldown if the user fails to cast it (releases M2 without enough charge, is downed/dies while charging).

static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};
static bool b_ChargingRaigeki[MAXPLAYERS + 1] = { false, ... };

public void Raigeki_ResetAll()
{
	Zero(ability_cooldown);
}

#define PARTICLE_RAIGEKI_STRIKE			"drg_cow_explosioncore_charged"

#define PARTICLE_RAIGEKI_CHARGEUP_AURA_START	 "teleporter_red_exit"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_MID 		 "teleporter_red_exit_level1"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_HIGH 	 "teleporter_red_exit_level2"
#define PARTICLE_RAIGEKI_CHARGEUP_AURA_MAX 		 "teleporter_red_exit_level3"
#define PARTICLE_RAIGEKI_CASTING_AURA	 		 "utaunt_poweraura_teamcolor_red"

#define SOUND_RAIGEKI_BLADE_SWEEP       ")weapons/samurai/tf_katana_crit_miss_01.wav"
#define SOUND_CHARGE_LOOP				")player/quickfix_invulnerable_on.wav"
#define SOUND_CHARGE_LOOP_MAX			")weapons/weapon_crit_charged_on.wav"
#define SOUND_CHARGE_MAX_NOTIF			")weapons/vaccinator_charge_tier_04.wav"
#define SOUND_RAIGEKI_FAILED			")player/taunt_sorcery_fail.wav"
#define SOUND_RAIGEKI_CAST_1			")ambient/hell/hell_rumbles_01.wav"
#define SOUND_RAIGEKI_CAST_2			")misc/halloween/spell_spawn_boss_disappear.wav"
#define SOUND_RAIGEKI_INCOMING			")ambient/halloween/thunder_04.wav"
#define SOUND_RAIGEKI_STRIKE_1			")misc/halloween/spell_spawn_boss.wav"
#define SOUND_RAIGEKI_STRIKE_2			")misc/doomsday_missile_explosion.wav"

static char g_StaticSounds[][] = {
	")weapons/stunstick/spark1.wav",
	")weapons/stunstick/spark2.wav",
	")weapons/stunstick/spark3.wav",
};

static int Model_Lightning;
static int Model_Glow;

void Raigeki_Precache()
{
	Model_Lightning = PrecacheModel("materials/sprites/lgtning.vmt");
	Model_Glow = PrecacheModel("materials/sprites/glow02.vmt");
	PrecacheModel("materials/effects/repair_claw_trail_red.vmt");
	PrecacheModel("materials/sprites/laser.vmt", false);

    PrecacheSound(SOUND_RAIGEKI_BLADE_SWEEP, true);
	PrecacheSound(SOUND_CHARGE_LOOP, true);
	PrecacheSound(SOUND_CHARGE_LOOP_MAX, true);
	PrecacheSound(SOUND_CHARGE_MAX_NOTIF, true);
	PrecacheSound(SOUND_RAIGEKI_FAILED, true);
	PrecacheSound(SOUND_RAIGEKI_CAST_1, true);
	PrecacheSound(SOUND_RAIGEKI_CAST_2, true);
	PrecacheSound(SOUND_RAIGEKI_INCOMING, true);
	PrecacheSound(SOUND_RAIGEKI_STRIKE_1, true);
	PrecacheSound(SOUND_RAIGEKI_STRIKE_2, true);

	for (int i = 0; i < sizeof(g_StaticSounds); i++) { PrecacheSound(g_StaticSounds[i]); }
}

//Block Burst Pack while charging Raigeki.
public bool Raigeki_OnBurstPack(int client)
{
	return !b_ChargingRaigeki[client];
}

void Raigeki_OnKill(int attacker, int victim)
{
}

float Player_OnTakeDamage_Raigeki(int victim, float &damage, int attacker)
{
	/*int grabber = Raigeki_GetGrabTarget(victim);
	if (IsValidEnemy(victim, grabber) && grabber == attacker)
	{
		damage *= Raigeki_Resistance[Raigeki_Tier[victim]];
	}

	return damage;*/
}

public void Raigeki_OnNPCDamaged(int victim, float damage)
{
	//Raigeki_DamageTakenWhileGrabbed[victim] += damage;
}

Handle Timer_Raigeki[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextRaigekiHUD[MAXPLAYERS + 1] = { 0.0, ... };

public void Enable_Raigeki(int client, int weapon)
{
	if (Timer_Raigeki[client] != null)
	{
		/*if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAIGEKI)
		{
			delete Timer_Raigeki[client];
			Timer_Raigeki[client] = null;
			DataPack pack;
			Timer_Raigeki[client] = CreateDataTimer(0.1, Timer_RaigekiControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;*/
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAIGEKI)
	{
		/*DataPack pack;
		Timer_Raigeki[client] = CreateDataTimer(0.1, Timer_RaigekiControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextRaigekiHUD[client] = 0.0;*/
	}
}

public Action Timer_RaigekiControl(Handle timer, DataPack pack)
{
	/*pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Raigeki[client] = null;
		return Plugin_Stop;
	}

	Raigeki_HUD(client, weapon, false);*/

	return Plugin_Continue;
}

public void Raigeki_HUD(int client, int weapon, bool forced)
{
	/*if(f_NextRaigekiHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			char HUDText[255];

			int grabTarget = Raigeki_GetGrabTarget(client);
			if (IsValidEnemy(client, grabTarget))
			{
				float mult = Raigeki_GetThrowVelMultiplier(client);
				Format(HUDText, sizeof(HUDText), "[%i Mana] M2: Psycho-Toss (%.2fx Power)!\nGrab cooldown upon releasing enemy: %.2fs", RoundFloat(Raigeki_Grab_ThrowCost[Raigeki_Tier[client]]), mult, Raigeki_CooldownToApply[client]);
			}

			PrintHintText(client, HUDText);

			
		}

		f_NextRaigekiHUD[client] = GetGameTime() + 0.5;
	}*/
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
		if (current <= gt)
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

static int i_ChargeMaxTargets[MAXPLAYERS + 1] = { 0, ... };
static int i_ChargeTier[MAXPLAYERS + 1] = { 0, ... };
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
	if (b_ChargingRaigeki[client])
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
		f_ChargeCurrentRes[client] = 0.0;
		b_DoChargeVFX[client] = true;
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_START);

		Attributes_SetMulti(client, 442, Charge_SpeedMod[tier]);
		SDKCall_SetSpeed(client);

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
	int particle = ParticleEffectAt_Parent(pos, particle, client);
	if (IsValidEntity(particle))
	{
		i_RaigekiParticle[client] = EntIndexToEntRef(particle);
		i_RaigekiParticleOwner[particle] = GetClientUserId(client);
		SetEdictFlags(particle, GetEdictFlags(particle)&(~FL_EDICT_ALWAYS));
		SDKHook(particle, SDKHook_SetTransmit, Raigeki_ParticleTransmit);
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
		Raigeki_SetRes(client, f_ChargeCurrentRes[client] * Raigeki_ResMult[i_ChargeTier[client]]);

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

	pos[0] += GetRandomFloat(-f_TrailIntensity[trail], f_TrailIntensity[trail]);
	pos[1] += GetRandomFloat(-f_TrailIntensity[trail], f_TrailIntensity[trail]);

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

	float gt = GetGameTime();
	if (gt >= f_RaigekiVFXTime[client] && f_RaigekiVFXTime[client] > 0.0)
	{
		float targPos[3], startPos[3];
		WorldSpaceCenter(client, targPos);
		targPos[2] += 5.0;

		float amtCharged = f_ChargeAmt[client] / f_ChargeRequirement[client];
		for (int i = 0; i < 4 + RoundToFloor(8.0 * amtCharged); i++)
		{
			startPos = targPos;
			startPos[0] += GetRandomFloat(-200.0, 200.0);
			startPos[1] += GetRandomFloat(-200.0, 200.0);
			startPos[2] += 2000.0;

			Raigeki_SpawnMovingTrail(startPos, targPos, 0.32, "materials/sprites/laserbeam.vmt", 255, RoundToFloor(amtCharged * 160.0), RoundToFloor(amtCharged * 160.0), 10 + RoundToFloor(70.0 * amtCharged), _, 0.24, _, _, view_as<int>(RENDER_TRANSALPHAADD), 12.0);
		}

		EmitSoundToAll(SOUND_RAIGEKI_INCOMING, client);
		EmitSoundToAll(SOUND_RAIGEKI_INCOMING, client, _, _, _, _, 60);
		f_RaigekiVFXTime[client] = 0.0;
	}

	if (gt >= f_RaigekiStrikesAt[client])
	{
		//TODO Add Overcharge

		float amtCharged = f_ChargeAmt[client] / f_ChargeRequirement[client];

		float pos[3], skyPos[3];
		WorldSpaceCenter(client, pos);
		pos[2] += 5.0;
		skyPos = pos;
		skyPos[2] += 2000.0;
		Raigeki_DrawBeamColumn(skyPos, pos, 35.0, 255, RoundToFloor(amtCharged * 200.0), RoundToFloor(amtCharged * 200.0), 210 + RoundToFloor(amtCharged * 45.0));

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

			Raigeki_SpawnMovingTrail(pos, skyPos, GetRandomFloat(0.2, 0.4), "materials/sprites/laserbeam.vmt", 255, RoundToFloor(amtCharged * 160.0), RoundToFloor(amtCharged * 160.0), 10 + RoundToFloor(70.0 * amtCharged), _, 0.2, 8.0, _, view_as<int>(RENDER_TRANSALPHAADD), 16.0);
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
		//I skipped scaling radius because Raigeki already has an enormous radius, and scaling it with bonuses would make it functionally the same as being map-wide in 99% of scenarios.
		Explode_Logic_Custom(damage, client, client, weapon, pos, Raigeki_Radius[i_ChargeTier[client]] * amtCharged, Raigeki_Falloff_MultiHit[i_ChargeTier[client]], Raigeki_Falloff_Radius[i_ChargeTier[client]], _, Raigeki_MaxTargets[i_ChargeTier[client]]);

		return;
	}

	RequestFrame(Raigeki_SummonBolt, id);
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
		EmitSoundToClient(client, SOUND_CHARGE_LOOP_MAX, client, _, _, _, _, 120);
		EmitSoundToClient(client, SOUND_CHARGE_MAX_NOTIF, client, _, _, _, _, 120);
		TF2_AddCondition(client, TFCond_FocusBuff);
		Utility_HUDNotification_Translation(client, "Raigeki Fully Charged");
		Raigeki_AttachParticle(client, PARTICLE_RAIGEKI_CHARGEUP_AURA_MAX);
	}

	Raigeki_SetRes(client, 1.0 - (f_ChargeBaseRes[client] + (f_ChargeBonusRes[client] * amtCharged)));

	//Trigger Static Electricity shockwave:
	float pos[3];
	WorldSpaceCenter(client, pos);
	Explode_Logic_Custom(f_ChargeDMG[client], client, client, weapon, pos, f_ChargeRadius[client], f_ChargeFalloff[client], 1.0, _, i_ChargeMaxTargets[client], false, 1.0, view_as<Function>(Raigeki_StaticElectricity_OnHit));

	f_NextCharge[client] = GetGameTime() + f_ChargeInterval[client];
}

void Raigeki_DoChargeVFX(int client)
{
	float pos[3];
	WorldSpaceCenter(client, pos);
	pos[2] += 10.0;

	float amtCharged = (f_ChargeAmt[client] / f_ChargeRequirement[client]);

	int numSparks = 1;// + RoundToFloor(amtCharged / 0.5);
	float beamWidth = 0.1 + (amtCharged * 2.0);
	int strongColor = 255;
	int weakColor = RoundToFloor(amtCharged * 160.0);
	int r = strongColor, g = weakColor, b = weakColor, a = 10 + RoundToFloor(70.0 * amtCharged);
	float randOffset = GetRandomFloat(0.0, 360.0);

	for (int i = 0; i < numSparks; i++)
	{
		int trail = CreateTrail("materials/sprites/laserbeam.vmt", a, f_ChargeInterval[client], 0.1, _, view_as<int>(RENDER_TRANSALPHAADD));
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

public void Raigeki_SetRes(int client, float amt)
{
	//Remove current res modifier if there already is one:
	if (f_ChargeCurrentRes[client] != 0.0)
	{
		Attributes_SetMulti(client, 206, (1.0 / f_ChargeCurrentRes[client]));
		Attributes_SetMulti(client, 205, (1.0 / f_ChargeCurrentRes[client]));
	}

	f_ChargeCurrentRes[client] = amt;

	//Give resistance:
	Attributes_SetMulti(client, 206, f_ChargeCurrentRes[client]);
	Attributes_SetMulti(client, 205, f_ChargeCurrentRes[client]);
}

public void Raigeki_StaticElectricity_OnHit(int attacker, int victim, float damage)
{
	float startPos[3], endPos[3];
	WorldSpaceCenter(attacker, startPos);
	WorldSpaceCenter(victim, endPos);
	startPos[2] += 10.0;
	endPos[2] += 10.0;

	SpawnBeam_Vectors(startPos, endPos, 0.2, 160, 160, 255, 255, Model_Lightning, 3.0, 3.0, _, 12.0);

	EmitSoundToAll(g_StaticSounds[GetRandomInt(0, sizeof(g_StaticSounds) - 1)], attacker, _, 80, _, _, GetRandomInt(80, 120));
	return;
}

void Raigeki_TerminateCharge(int client)
{
	if (f_ChargeCurrentRes[client] != 0.0)
	{
		Attributes_SetMulti(client, 206, (1.0 / f_ChargeCurrentRes[client]));
		Attributes_SetMulti(client, 205, (1.0 / f_ChargeCurrentRes[client]));
	}

	Attributes_SetMulti(client, 442, (1.0 / Charge_SpeedMod[i_ChargeTier[client]]));
	SDKCall_SetSpeed(client);

	Raigeki_TerminateChargeFX(client);

	b_ChargingRaigeki[client] = false;
}

void Raigeki_TerminateChargeFX(int client)
{
	StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP);
	StopSound(client, SNDCHAN_AUTO, SOUND_CHARGE_LOOP_MAX);
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

static int i_RemainingBlades[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeStartEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeEndEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeBeamEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeIntendedTarget[MAXPLAYERS + 1] = { -1, ... };
static int i_BladeTier[MAXPLAYERS + 1] = { 0, ... };

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

    //Range scales with both projectile velocity *and* projectile lifespan modifiers.
    if (IsValidEntity(weapon))
    {
        f_BladeRange[client] *= Attributes_Get(weapon, 103, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 104, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 475, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 101, 1.0);
        f_BladeRange[client] *= Attributes_Get(weapon, 102, 1.0);
    }
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

    EmitSoundToAll(SOUND_RAIGEKI_BLADE_SWEEP, client, _, _, _, 0.65, GetRandomInt(110, 140));

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
    SDKHooks_TakeDamage(victim, attacker, attacker, dmg, DMG_PLASMA, (IsValidEntity(weapon) ? weapon : -1), force, pos, false, ZR_DAMAGE_LASER_NO_BLAST);

    Raigeki_Hit[attacker][victim] = true;
    f_BladeDMG[attacker] *= f_BladeFalloff[attacker];
}

public bool Blade_OnlyThoseNotHit(int victim, int attacker) { return !Raigeki_Hit[attacker][victim]; }

public void Blade_MoveBeam(int client, float startPos[3], float endPos[3], float ang[3], float width)
{
	float strength = 1.0 - (2.0 * fabs(f_BladeProgress[client] - 0.5));

	float beamWidth = 0.1 + (strength * 6.0);

	int strongColor = 255;
	int weakColor = RoundToFloor(strength * 240.0);
	int r = strongColor, g = weakColor, b = weakColor, a = RoundToFloor(255.0 * strength);

	GetPointInDirection(startPos, ang, 20.0, startPos);
	startPos[2] -= 25.0;
	endPos[2] -= 25.0;

	int beam, start, end;
	beam = Blade_GetBeamEnt(client);
	if (!IsValidEntity(beam))
	{
		beam = CreateEnvBeam(-1, -1, startPos, endPos, _, _, start, end, r, g, b, a, _, beamWidth, beamWidth);
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
			int trail = CreateTrail("materials/sprites/laserbeam.vmt", a, f_BladeInterval[client] * 0.425, beamWidth, _, view_as<int>(RENDER_TRANSALPHAADD));
			if (IsValidEntity(trail))
				PushArrayCell(g_BladeTrails[client], EntIndexToEntRef(trail));
		}
	}

	SetEntityRenderColor(beam, r, g, b, a);
	SetEntPropFloat(beam, Prop_Data, "m_fWidth", beamWidth);
	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", beamWidth);

	SetEntityMoveType(start, MOVETYPE_NOCLIP);
	SetEntityMoveType(end, MOVETYPE_NOCLIP);
	SetEntityMoveType(beam, MOVETYPE_NOCLIP);
	TeleportEntity(start, startPos);
	TeleportEntity(end, endPos);

	if (g_BladeTrails[client] != null)
	{
		for (int i = 0; i < GetArraySize(g_BladeTrails[client]); i++)
		{
			int trail = EntRefToEntIndex(GetArrayCell(g_BladeTrails[client], i));
			if (IsValidEntity(trail))
			{
				float trailPos[3];
				GetPointInDirection(startPos, ang, float(i + 1) * 75.0, trailPos);

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