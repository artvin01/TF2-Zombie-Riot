#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//STANDARD M1 PROJECTILE: The Magnesis Staff's primary fire is nothing special, just a generic projectile.
static int Magnesis_M1_NumProjectiles[3] = { 3, 4, 5 };			//Number of projectiles fired.
static float Magnesis_M1_DMG[3] = { 320.0, 520.0, 800.0 };          //M1 projectile damage.
static float Magnesis_M1_Lifespan[3] = { 0.3, 0.3, 0.3 };          	//M1 projectile lifespan.
static float Magnesis_M1_Velocity[3] = { 1400.0, 1600.0, 1800.0 };  //M1 projectile velocity.
static float Magnesis_M1_Spread[3] = { 6.0, 5.0, 4.0 };				//M1 projectile deviation.

//M2 - GRAB: Clicking M2 on a living zombie allows the user to grab that zombie and hold it in front of them, provided 
//the target is within range. Holding a zombie drains mana, which becomes more expensive the longer the zombie is held.
//Held zombies are stunned. At any time, the user may press M2 again to throw the zombie (if they do not have the mana
//to afford the throw, the zombie is simply dropped). The velocity of this throw is based on the amount of damage
//that zombie took while grabbed, relative to their max health.
static float Magnesis_Grab_WaitTime[3] = { 5.0, 5.0, 5.0 };						//Time after an enemy has been thrown/dropped before they can be grabbed again, to prevent team stacks from grabbing enemies indefinitely.
static float Magnesis_Grab_Requirement[3] = { 50.0, 100.0, 150.0 };				//Initial mana cost in order to grab an enemy.
static float Magnesis_Grab_Cooldown_Normal[3] = { 5.0, 5.0, 5.0 };				//Cooldown applied when grabbing normal zombies.
static float Magnesis_Grab_Cooldown_Special[3] = { 30.0, 30.0, 30.0 };			//Cooldown applied when grabbing mini-bosses/bosses.
static float Magnesis_Grab_Cooldown_Raids[3] = { 70.0, 70.0, 70.0 };			//Cooldown applied when grabbing raid bosses.
static float Magnesis_Grab_Cost_Normal[3] = { 5.0, 10.0, 20.0 };				//Mana drained per 0.1s while holding a normal enemy.
static float Magnesis_Grab_Cost_Scaling_Normal[3] = { 0.01, 0.01, 0.01 };		//Additional percentage of the user's max mana to drain per 0.1s while holding a normal enemy (0.1 = 10%).
static float Magnesis_Grab_Cost_Special[3] = { 35.0, 35.0, 35.0 };				//Mana drained per 0.1s while holding a boss/mini-boss.
static float Magnesis_Grab_Cost_Scaling_Special[3] = { 0.01, 0.01, 0.01 };		//Additional percentage of the user's max mana to drain per 0.1s while holding a special enemy (0.1 = 10%).
static float Magnesis_Grab_Cost_Raid[3] = { 35.0, 35.0, 35.0 };					//Mana drained per 0.1s while holding a raid.
static float Magnesis_Grab_Cost_Scaling_Raid[3] = { 0.020, 0.020, 0.020 };		//Additional percentage of the user's max mana to drain per 0.1s while holding a raid.
static float Magnesis_Grab_DragRate[3] = { 10.0, 10.0, 10.0 };					//Base speed at which grabbed targets move towards the puller, per frame.
static float Magnesis_Grab_DragRate_WeightPenalty[3] = { 7.5, 3.0, 1.25 };		//Amount to reduce grab movement speed per point of NPC weight above 1.
static float Magnesis_Grab_Range[3] = { 150.0, 200.0, 250.0 };					//Maximum distance from which enemies can be grabbed.
static float Magnesis_Grab_Distance[3] = { 80.0, 80.0, 80.0 };					//Distance from the user to hold zombies at.
static float Magnesis_Grab_MaxVel[3] = { 1000.0, 1400.0, 2000.0 };				//Maximum throw velocity.
static float Magnesis_Grab_MaxVel_Raids[3] = { 500.0, 600.0, 700.0 };				//Maximum throw velocity.
static float Magnesis_Grab_ThrowCost[3] = { 50.0, 100.0, 150.0 };				//Cost to throw the enemy instead of simply dropping them.
static float Magnesis_Grab_ThrowThreshold_Normal[3] = { 0.25, 0.2, 0.125 };		//Percentage of max health taken as damage while grabbed in order for the throw to reach max velocity, for normal enemies.
static float Magnesis_Grab_ThrowThreshold_Special[3] = { 0.25, 0.2, 0.15 };		//Throw threshold for bosses/mini-bosses.
static float Magnesis_Grab_ThrowThreshold_Raid[3] = { 0.125, 0.066, 0.0425 };	//Throw threshold for raids.
static float Magnesis_Grab_Throw_WeightPenalty[3] = { 0.25, 0.15, 0.05 };		//Percentage to reduce throw strength per point of NPC weight above 1.
static float Magnesis_Grab_ThrowDMG[3] = { 1250.0, 2000.0, 2500.0 };			//Damage dealt to grabbed enemies when they are thrown.
static float Magnesis_Grab_ThrowDMG_Scale[3] = { 2500.0, 6000.0, 7500.0 };		//Maximum amount of damage to add to the throw damage. This scales in the same way as throw velocity.
static bool Magnesis_Grab_Specials[3] = { false, true, true };					//Can the Magnesis Staff grab bosses/mini-bosses on this tier?
static bool Magnesis_Grab_Raids[3] = { false, true, true };						//Can the Magnesis Staff grab raids on this tier?
static float Magnesis_StunTime_Normal[3] = { 4.0, 4.0, 4.0 };					//Duration to stun enemies when they are grabbed by the Magnesis Staff (0.0 = stun until dropped, below 0.0 = no stun at all).
static float Magnesis_StunTime_Special[3] = { 2.5, 2.5, 2.5 };					//Stun duration for bosses/mini-bosses.
static float Magnesis_StunTime_Raid[3] = { 1.66, 1.66, 1.66 };					//Stun duration for raids.
static float Magnesis_Resistance[3] = { 0.75, 0.66, 0.5 };						//Amount to multiply damage taken by grabbed enemies.
static float Magnesis_Grab_StrangleDMG[3] = { 0.0, 50.0, 75.0 };				//Damage dealt per 0.1s to enemies who are grabbed.
static float Magnesis_Grab_Vulnerability[3] = { 0.1, 0.15, 0.2 };				//Amount to multiply all damage dealt to enemies who are grabbed.

//NEWTONIAN KNUCKLES: Alternate PaP path which replaces the M1 with a far stronger explosive projectile with a slower rate of fire.
//Replaces M2 with a shockwave that deals knockback. M1 projectile deals bonus damage if it airshots an enemy who is airborne because of the M2 attack.
//static float Newtonian_M1_Cost[3] = { 50.0, 75.0, 100.0 };					//M1 cost.
static float Newtonian_M1_DMG[3] = { 400.0, 1000.0, 1400.0 };					//M1 damage.
static float Newtonian_M1_Radius[3] = { 150.0, 165.0, 180.0 };					//M1 explosion radius.
static float Newtonian_M1_Velocity[3] = { 1400.0, 1800.0, 2200.0 };				//M1 projectile velocity.
static float Newtonian_M1_Lifespan[3] = { 1.0, 0.5, 0.65 };						//M1 projectile lifespan.
//static float Newtonian_M1_Falloff_MultiHit[3] = { 0.66, 0.75, 0.85 };			//Amount to multiply damage dealt by M1 per target hit.
//static float Newtonian_M1_Falloff_Distance[3] = { 0.66, 0.75, 0.85 };			//Maximum M1 damage falloff, based on distance.
static float Newtonian_M1_ComboMult[3] = { 4.0, 6.0, 8.0 };						//Amount to multiply damage dealt by the M1 to enemies who have been knocked airborne by the M2.
static float Newtonian_M1_ComboCDR[3] = { 5.0, 5.0, 5.0 };						//Amount to reduce remaining M2 cooldown when airshotting an enemy launched by M2.
static float Newtonian_M1_ComboCDR_Raids[3] = { 10.0, 10.0, 10.0 };				//Amount to reduce remaining M2 cooldown when airshotting a raid launched by M2 (does not stack with the other cdr). 
static int Newtonian_M1_MaxTargets[3] = { 1, 2, 3 };							//Max targets hit by the M1 projectile's explosion.
static float Newtonian_M2_Cost[3] = { 200.0, 150.0, 200.0 };					//M2 cost.
static float Newtonian_M2_Cooldown[3] = { 40.0, 25.0, 25.0 };					//M2 cooldown.
static float Newtonian_M2_DMG[3] = { 1600.0, 2400.0, 3500.0 };					//M2 damage.
static float Newtonian_M2_Radius[3] = { 160.0, 180.0, 200.0 };					//M2 radius.
static float Newtonian_M2_Falloff_MultiHit[3] = { 0.5, 0.66, 0.75 };			//Amount to multiply damage dealt by the M2 shockwave per target hit.
static float Newtonian_M2_Falloff_Distance[3] = { 0.5, 0.66, 0.75 };			//Maximum M2 damage falloff, based on distance.
static float Newtonian_M2_Knockback_Horizontal[3] = { 400.0, 600.0, 750.0 };	//Horizontal knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_Vertical[3] = { 400.0, 600.0, 750.0 };		//Vertical knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_RaidMult[3] = { 1.0, 1.0, 1.0 };			//Amount to multiply knockback dealt to raids.
static float Newtonian_M2_Knockback_WeightPenalty[3] = { 150.0, 100.0, 100.0 };	//Amount to reduce knockback per point of NPC weight above 1.0.
static float Newtonian_M2_AttackDelay[3] = { 0.66, 0.66, 0.66 };				//Duration to prevent the user from attacking with M1 after triggering a shockwave. This is to prevent cheesy combos where you press M2 and M1 at the same time.
static int Newtonian_M2_MaxTargets[3] = { 4, 6, 8 };							//Max zombies hit by M2 shockwave.

//Client/entity-specific global variables below, don't touch these:
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};
static int Magnesis_ProjectileTier[2049] = { 0, ... };
static int Magnesis_StartParticle[MAXPLAYERS + 1] = { -1, ... };
static int Magnesis_EndParticle[MAXPLAYERS + 1] = { -1, ... };
static int Magnesis_Tier[2049] = { 0, ... };
static int Magnesis_GrabTarget[MAXPLAYERS + 1] = { false, ... };
static bool Magnesis_ProjectileIsNewtonian[2049] = { false, ... };
static bool Magnesis_Grabbed[2049] = { false, ... };
static bool Newtonian_Airborne[2049] = { false, ... };
static float Magnesis_CooldownToApply[MAXPLAYERS + 1] = { 0.0, ... };
static float Magnesis_DamageTakenWhileGrabbed[2049] = { 0.0, ... };
static float Magnesis_DroppedAt[2049] = { 0.0, ... };
static float Magnesis_GrabbedAt[2049] = { 0.0, ... };
static float Magnesis_NextDrainTick[MAXPLAYERS + 1] = { 0.0, ... };
static float Magnesis_GrabCost_Bucket[MAXPLAYERS + 1] = { 0.0, ... };

static int Magnesis_GrabWeapon[MAXPLAYERS + 1] = { -1, ... };

public void Magnesis_ResetAll()
{
	Zero(ability_cooldown);
	Zero(Magnesis_NextDrainTick);

	for (int i = 0; i < 2049; i++)
	{
		Newtonian_Airborne[i] = false;
		Magnesis_Grabbed[i] = false;
		Magnesis_DroppedAt[i] = 0.0;
		Magnesis_DamageTakenWhileGrabbed[i] = 0.0;
	}
}

float MagnesisDamageBuff(int Tier)
{
	return Magnesis_Grab_Vulnerability[Tier];
}
#define SND_MAGNESIS_M1         	")weapons/shooting_star_shoot.wav"
#define SND_MAGNESIS_M1_2			")weapons/bison_main_shot_01.wav"
#define SND_MAGNESIS_M1_COLLIDE		")weapons/flare_detonator_explode_world.wav"
#define SND_MAGNESIS_GRAB			")weapons/physcannon/physcannon_pickup.wav"
#define SND_MAGNESIS_GRAB_LOOP		")weapons/physcannon/superphys_hold_loop.wav"
#define SND_MAGNESIS_THROW			")weapons/physcannon/superphys_launch2.wav"
#define SND_MAGNESIS_DROP			")weapons/physcannon/physcannon_drop.wav"
#define SND_NEWTONIAN_M1			")weapons/cow_mangler_main_shot.wav"
#define SND_NEWTONIAN_M1_COLLIDE	")weapons/cow_mangler_explosion_normal_01.wav"
#define SND_NEWTONIAN_M2			")weapons/bumper_car_spawn.wav"
#define SND_NEWTONIAN_M2_2			")weapons/cow_mangler_explode.wav"
#define SND_NEWTONIAN_M2_KNOCKBACK	")weapons/bumper_car_hit_ball.wav"
#define SND_MAGNESIS_HOMING_BEGIN	")weapons/man_melter_fire_crit.wav"

#define PARTICLE_MAGNESIS_M1     			"raygun_projectile_blue"
#define PARTICLE_MAGNESIS_M1_FINALPAP		"raygun_projectile_blue_crit"
#define PARTICLE_MAGNESIS_M1_COLLIDE		"impact_metal"
#define PARTICLE_MAGNESIS_GRAB				"medicgun_beam_machinery_trail"
#define PARTICLE_MAGNESIS_GRAB_FINALPAP		"medicgun_beam_blue_trail"
#define PARTICLE_MAGNESIS_THROW				"dxhr_lightningball_hit_red"
#define PARTICLE_MAGNESIS_THROW_FINALPAP	"dxhr_lightningball_hit_blue"
#define PARTICLE_NEWTONIAN_M1    			"raygun_projectile_red"
#define PARTICLE_NEWTONIAN_M1_FINALPAP    	"raygun_projectile_red_crit"
#define PARTICLE_NEWTONIAN_M1_COLLIDE		"drg_cow_explosioncore_charged"
#define PARTICLE_NEWTONIAN_M2				"mvm_soldier_shockwave"

static int Beam_Lightning;
static int Beam_Glow;

void Magnesis_Precache()
{
	PrecacheSound(SND_MAGNESIS_M1);
	PrecacheSound(SND_MAGNESIS_M1_2);
	PrecacheSound(SND_MAGNESIS_M1_COLLIDE);
	PrecacheSound(SND_MAGNESIS_GRAB);
	PrecacheSound(SND_MAGNESIS_GRAB_LOOP);
	PrecacheSound(SND_MAGNESIS_THROW);
	PrecacheSound(SND_MAGNESIS_DROP);
	PrecacheSound(SND_MAGNESIS_HOMING_BEGIN);
	PrecacheSound(SND_NEWTONIAN_M1);
	PrecacheSound(SND_NEWTONIAN_M1_COLLIDE);
	PrecacheSound(SND_NEWTONIAN_M2);
	PrecacheSound(SND_NEWTONIAN_M2_2);
	PrecacheSound(SND_NEWTONIAN_M2_KNOCKBACK);
	PrecacheModel("models/weapons/c_models/c_engineer_gunslinger.mdl");

	Beam_Lightning = PrecacheModel("materials/sprites/lgtning.vmt");
	Beam_Glow = PrecacheModel("materials/sprites/glow02.vmt");
}

public void Magnesis_OnBurstPack(int client)
{
	int grabTarget = Magnesis_GetGrabTarget(client);
	if (IsValidEnemy(client, grabTarget))
	{
		Magnesis_TerminateEffects(client, EntRefToEntIndex(Magnesis_StartParticle[client]), EntRefToEntIndex(Magnesis_EndParticle[client]));

		float stopmoving[3];
		stopmoving[0] = 0.0;
		stopmoving[1] = 0.0;
		stopmoving[2] = 0.0;
		Magnesis_MakeNPCMove(Magnesis_GetGrabTarget(client), stopmoving);
	}
}

void Magnesis_OnKill(int victim)
{
	Newtonian_Airborne[victim] = false;
	Magnesis_Grabbed[victim] = false;
	Magnesis_DroppedAt[victim] = 0.0;
	Magnesis_DamageTakenWhileGrabbed[victim] = 0.0;
}

float Player_OnTakeDamage_Magnesis(int victim, float &damage, int attacker)
{
	int grabber = Magnesis_GetGrabTarget(victim);
	if (IsValidEnemy(victim, grabber) && grabber == attacker)
	{
		damage *= Magnesis_Resistance[Magnesis_Tier[victim]];
	}

	return damage;
}

public void Magnesis_OnNPCDamaged(int victim, float damage)
{
	Magnesis_DamageTakenWhileGrabbed[victim] += damage;
}

Handle Timer_Magnesis[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
static float f_NextMagnesisHUD[MAXPLAYERS + 1] = { 0.0, ... };

public void Enable_Magnesis(int client, int weapon)
{
	if (Timer_Magnesis[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAGNESIS)
		{
			delete Timer_Magnesis[client];
			Timer_Magnesis[client] = null;
			DataPack pack;
			Timer_Magnesis[client] = CreateDataTimer(0.1, Timer_MagnesisControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAGNESIS)
	{
		DataPack pack;
		Timer_Magnesis[client] = CreateDataTimer(0.1, Timer_MagnesisControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_NextMagnesisHUD[client] = 0.0;
	}
}

public Action Timer_MagnesisControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Magnesis[client] = null;
		return Plugin_Stop;
	}

	Magnesis_HUD(client, weapon, false);

	return Plugin_Continue;
}

public void Magnesis_HUD(int client, int weapon, bool forced)
{
	if(f_NextMagnesisHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			char HUDText[255];

			int grabTarget = Magnesis_GetGrabTarget(client);
			if (IsValidEnemy(client, grabTarget))
			{
				float mult = Magnesis_GetThrowVelMultiplier(client);
				Format(HUDText, sizeof(HUDText), "[%i Mana] M2: Psycho-Toss (%.2fx Power)!\nGrab cooldown upon releasing enemy: %.2fs", RoundFloat(Magnesis_Grab_ThrowCost[Magnesis_Tier[client]]), mult, Magnesis_CooldownToApply[client]);
			}

			PrintHintText(client, HUDText);

			
		}

		f_NextMagnesisHUD[client] = GetGameTime() + 0.5;
	}
}

public void Magnesis_Attack_0(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 0);
}

public void Magnesis_Attack_1(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 1);
}

public void Magnesis_Attack_2(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 2);
}

void Magnesis_FireProjectile(int client, int weapon, int tier)
{
    int mana_cost = RoundFloat(Attributes_Get(weapon, 733, 10.0));

    if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(client, weapon);
		SDKhooks_SetManaRegenDelayTime(client, 2.0);
		Mana_Hud_Delay[client] = 0.0;
		Current_Mana[client] -= mana_cost;

		delay_hud[client] = 0.0;
		
		for (int i = 0; i < Magnesis_M1_NumProjectiles[tier]; i++)
			Utility_FireProjectile(client, weapon, tier, false);

		EmitSoundToAll(SND_MAGNESIS_M1, client, _, _, _, 0.4, GetRandomInt(80, 100));
		EmitSoundToClient(client, SND_MAGNESIS_M1, _, _, _, _, 0.33, GetRandomInt(80, 100));
		EmitSoundToAll(SND_MAGNESIS_M1_2, client, _, _, _, 0.4, GetRandomInt(80, 100));
		EmitSoundToClient(client, SND_MAGNESIS_M1_2, _, _, _, _, 0.33, GetRandomInt(80, 100));
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

public void Magnesis_Grab_0(int client, int weapon, bool &result, int slot)
{
	if (IsValidEnemy(client, Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 0);
	else
    	Magnesis_AttemptGrab(client, weapon, 0);
}

public void Magnesis_Grab_1(int client, int weapon, bool &result, int slot)
{
    if (IsValidEnemy(client, Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 1);
	else
    	Magnesis_AttemptGrab(client, weapon, 1);
}

public void Magnesis_Grab_2(int client, int weapon, bool &result, int slot)
{
    if (IsValidEnemy(client, Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 2);
	else
    	Magnesis_AttemptGrab(client, weapon, 2);
}

int Magnesis_GetGrabTarget(int client)
{
	return EntRefToEntIndex(Magnesis_GrabTarget[client]);
}

float Magnesis_GetStunTime(int client)
{
	int target = Magnesis_GetGrabTarget(client);

	float time = Magnesis_StunTime_Normal[Magnesis_Tier[client]];
	if (b_thisNpcIsARaid[target])
		time = Magnesis_StunTime_Raid[Magnesis_Tier[client]];
	else if (b_thisNpcIsABoss[target])
		time = Magnesis_StunTime_Special[Magnesis_Tier[client]];

	return time;
}

void Magnesis_AttemptThrow(int client, int weapon, int tier)
{
	int target = Magnesis_GetGrabTarget(client);

	int cost = RoundFloat(Magnesis_Grab_ThrowCost[tier]);
	if (cost > Current_Mana[client] || !IsValidEnemy(client, target))
	{
		if (cost > Current_Mana[client])
			Utility_HUDNotification_Translation(client, "Magnesis Throw Failed");
		else
			Utility_HUDNotification_Translation(client, "Magnesis Invalid Throw");

		Magnesis_TerminateEffects(client, EntRefToEntIndex(Magnesis_StartParticle[client]), EntRefToEntIndex(Magnesis_EndParticle[client]));

		float stopmoving[3];
		stopmoving[0] = 0.0;
		stopmoving[1] = 0.0;
		stopmoving[2] = 0.0;
		Magnesis_MakeNPCMove(target, stopmoving);
	}
	else
	{
		Client_Shake(client, _, 15.0, 33.0, 1.0);

		float vicPos[3], ang[3], buffer[3], vel[3], enemyAbsPos[3], dmgForce[3];
		WorldSpaceCenter(target, vicPos);
		GetClientEyeAngles(client, ang);
		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);

		view_as<CClotBody>(target).GetAbsOrigin(enemyAbsPos);

		int start, end;	//These don't get used for anything, but I can't pass 0 by reference so I have to put them here...
		AttachParticle_ControlPoints(client, "", 0.0, 0.0, 60.0, target, "", 0.0, 0.0, vicPos[2] - enemyAbsPos[2], (tier < 2 ? PARTICLE_MAGNESIS_THROW : PARTICLE_MAGNESIS_THROW_FINALPAP), start, end, 0.33);

		float mult = Magnesis_GetThrowVelMultiplier(client);

		float throwVel = (b_thisNpcIsARaid[target] ? Magnesis_Grab_MaxVel_Raids[Magnesis_Tier[client]] :  Magnesis_Grab_MaxVel[Magnesis_Tier[client]]) * mult;
		for (int i = 0; i < 3; i++)
			vel[i] = buffer[i] * throwVel;
		
		Magnesis_MakeNPCMove(target, vel);

		float dmg = Magnesis_Grab_ThrowDMG[tier] + (mult * Magnesis_Grab_ThrowDMG_Scale[tier]);
		dmg *= Attributes_Get(weapon, 410, 1.0);

		CalculateDamageForce(buffer, 100000.0 * mult, dmgForce);
		SDKHooks_TakeDamage(target, client, client, dmg, DMG_PLASMA, weapon, dmgForce, vicPos);

		Current_Mana[client] -= cost;
		Magnesis_TerminateEffects(client, EntRefToEntIndex(Magnesis_StartParticle[client]), EntRefToEntIndex(Magnesis_EndParticle[client]), true);
	}

	Magnesis_GrabTarget[client] = -1;
}

float Magnesis_GetThrowVelMultiplier(int client)
{
	int target = Magnesis_GetGrabTarget(client);
	if (!IsValidEnemy(client, target))
		return 0.0;

	float maxHP = float(GetEntProp(target, Prop_Data, "m_iMaxHealth"));
	float percentage = Magnesis_DamageTakenWhileGrabbed[target] / maxHP;

	float weight = float(i_NpcWeight[target]) - 1.0;
	if (weight > 0.0)
	{
		float weightPenalty = (weight * Magnesis_Grab_Throw_WeightPenalty[Magnesis_Tier[client]]);
		percentage *= 1.0 - weightPenalty;
		if (percentage <= 0.0)
			return 0.0;
	}

	float threshold = Magnesis_Grab_ThrowThreshold_Normal[Magnesis_Tier[client]];
	if (b_thisNpcIsARaid[target])
		threshold = Magnesis_Grab_ThrowThreshold_Raid[Magnesis_Tier[client]];
	else if (b_thisNpcIsABoss[target])
		threshold = Magnesis_Grab_ThrowThreshold_Special[Magnesis_Tier[client]];

	float multiplier = percentage / threshold;
	if (multiplier > 1.0)
		multiplier = 1.0;

	return multiplier;
}

void Magnesis_AttemptGrab(int client, int weapon, int tier)
{
	int mana_cost = RoundFloat(Magnesis_Grab_Requirement[tier]);
	float remCD = Ability_Check_Cooldown(client, 2, weapon);

	if(mana_cost <= Current_Mana[client] && remCD <= 0.0)
	{
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);

		float pos[3], ang[3], endPos[3], hullMin[3], hullMax[3], direction[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);

		hullMin[0] = -1.0;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];

		GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(direction, Magnesis_Grab_Range[tier]);
		AddVectors(pos, direction, endPos);

		TR_TraceHullFilter(pos, endPos, hullMin, hullMax, 1073741824, Magnesis_GrabTrace, client);
		int victim = TR_GetEntityIndex();
		FinishLagCompensation_Base_boss();
		

		if (!IsValidEntity(victim))
		{
			Utility_HUDNotification_Translation(client, "Magnesis No Target Found", true);
			return;
		}
		
		if(HasSpecificBuff(victim, "Solid Stance"))
			return;

		if(HasSpecificBuff(victim, "Raid Strangle Protection", _ , client))
		{
			//already grabbed once.
			return;
		}

		if (Magnesis_Grabbed[victim])
		{
			Utility_HUDNotification_Translation(client, "Magnesis Already Grabbed", true);
			return;
		}

		if ((GetGameTime() - Magnesis_DroppedAt[victim]) < Magnesis_Grab_WaitTime[tier])
		{
			Utility_HUDNotification_Translation(client, "Magnesis Grabbed Too Soon", true);
			return;
		}

		if (!Magnesis_TargetCanBeGrabbed(client, victim, tier))
			return;

		Magnesis_Tier[client] = tier;
		Magnesis_Grabbed[victim] = true;
		Magnesis_GrabCost_Bucket[client] = 0.0;
		Magnesis_GrabWeapon[client] = EntIndexToEntRef(weapon);
		Magnesis_GrabbedAt[victim] = GetGameTime();
		Magnesis_GrabTarget[client] = EntIndexToEntRef(victim);
		Magnesis_NextDrainTick[client] = GetGameTime() + 0.1;
		switch(tier)
		{
			case 1:
				ApplyStatusEffect(client, victim, "Stranglation I", 0.1);
			case 2:
				ApplyStatusEffect(client, victim, "Stranglation II", 0.1);
			case 3:
				ApplyStatusEffect(client, victim, "Stranglation III", 0.1);
		}
		float cd = Magnesis_Grab_Cooldown_Normal[tier];
		if (b_thisNpcIsARaid[victim])
		{
			ApplyStatusEffect(client, victim, "Raid Strangle Protection", 999999.9);
			cd = Magnesis_Grab_Cooldown_Raids[tier];
		}
		else if (b_thisNpcIsABoss[victim])
			cd = Magnesis_Grab_Cooldown_Special[tier];
		Magnesis_CooldownToApply[client] = cd;

		float time = Magnesis_GetStunTime(client);
		FreezeNpcInTime(victim, time);

		EmitSoundToAll(SND_MAGNESIS_GRAB, victim);
		EmitSoundToClient(client, SND_MAGNESIS_GRAB);
		EmitSoundToClient(client, SND_MAGNESIS_GRAB_LOOP, _, _, _, _, 0.66);

		Magnesis_MoveVictim(client);

		int start, end;
		float enemyPos[3], enemyAbsPos[3];
		WorldSpaceCenter(victim, enemyPos);
		view_as<CClotBody>(victim).GetAbsOrigin(enemyAbsPos);

		AttachParticle_ControlPoints(client, "", 0.0, 0.0, 60.0, victim, "", 0.0, 0.0, enemyPos[2] - enemyAbsPos[2], (tier < 2 ? PARTICLE_MAGNESIS_GRAB : PARTICLE_MAGNESIS_GRAB_FINALPAP), start, end);
		
		Magnesis_StartParticle[client] = EntIndexToEntRef(start);
		Magnesis_EndParticle[client] = EntIndexToEntRef(end);

		DataPack pack = new DataPack();
		RequestFrame(Magnesis_Logic, pack);	//Expensive, I know, but a repeating timer does not work for this.
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, EntIndexToEntRef(start));
		WritePackCell(pack, EntIndexToEntRef(end));

		Rogue_OnAbilityUse(client, weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
	}
	else
	{
		if (remCD > 0.0)
			Utility_OnCooldown(client, remCD);
		else
			Utility_NotEnoughMana(client, mana_cost);
	}
}

public void Magnesis_Logic(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int startPart = EntRefToEntIndex(ReadPackCell(pack));
	int endPart = EntRefToEntIndex(ReadPackCell(pack));

	if (!IsValidClient(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		delete pack;
		return;
	}

	if (Magnesis_GrabTarget[client] == -1)
	{
		delete pack;
		return;
	}
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (!IsValidEntity(weapon))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		delete pack;
		return;
	}

	if (dieingstate[client] > 0 || i_CustomWeaponEquipLogic[weapon] != WEAPON_MAGNESIS || !IsPlayerAlive(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		delete pack;
		return;
	}

	if (!Magnesis_MoveVictim(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		delete pack;
		return;
	}

	float gt = GetGameTime();
	if (Magnesis_NextDrainTick[client] <= gt)
	{
		int target = EntRefToEntIndex(Magnesis_GrabTarget[client]);
		
		if(HasSpecificBuff(target, "Solid Stance"))
		{
			Magnesis_TerminateEffects(client, startPart, endPart);
			delete pack;
			return;
		}
		float manaPercentage = Magnesis_Grab_Cost_Scaling_Normal[Magnesis_Tier[client]];
		float cost = Magnesis_Grab_Cost_Normal[Magnesis_Tier[client]];
		if (b_thisNpcIsARaid[target])
		{
			cost = Magnesis_Grab_Cost_Raid[Magnesis_Tier[client]];
			manaPercentage = Magnesis_Grab_Cost_Scaling_Raid[Magnesis_Tier[client]];
		}
		else if (b_thisNpcIsABoss[target])
		{
			cost = Magnesis_Grab_Cost_Special[Magnesis_Tier[client]];
			manaPercentage = Magnesis_Grab_Cost_Scaling_Special[Magnesis_Tier[client]];
		}

		ManaCalculationsBefore(client);
		Magnesis_GrabCost_Bucket[client] += cost + (max_mana[client] * manaPercentage);

		int realCost = RoundToFloor(Magnesis_GrabCost_Bucket[client]);

		if (realCost > 0)
		{
			if (realCost > Current_Mana[client])
			{
				Magnesis_TerminateEffects(client, startPart, endPart);
				delete pack;
				return;
			}
			else
			{
				Current_Mana[client] -= realCost;
				Magnesis_GrabCost_Bucket[client] -= float(realCost);
			}
		}

		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Magnesis_NextDrainTick[client] = gt + 0.1;
		Magnesis_HUD(client, weapon, false);
		if(!VIPBuilding_Active())
			view_as<CClotBody>(target).m_iTarget = client;

		float dmg = Magnesis_Grab_StrangleDMG[Magnesis_Tier[client]];
		if (dmg > 0.0)
		{
			dmg *= Attributes_Get(weapon, 410, 1.0);
			dmg *= ((MagnesisDamageBuff(Magnesis_Tier[client]) -1.0) * -1.0);
			switch(Magnesis_Tier[client])
			{
				case 1:
					ApplyStatusEffect(client, target, "Stranglation I", 0.1);
				case 2:
					ApplyStatusEffect(client, target, "Stranglation II", 0.1);
				case 3:
					ApplyStatusEffect(client, target, "Stranglation III", 0.1);
			}
			SDKHooks_TakeDamage(target, client, client, dmg, DMG_PLASMA, weapon, _, _, false);
		}
	}

	RequestFrame(Magnesis_Logic, pack);
}

void Magnesis_TerminateEffects(int client, int start, int end, bool enemyWasThrown = false)
{
	if (IsValidEntity(start))
		RemoveEntity(start);
	if (IsValidEntity(end))
		RemoveEntity(end);

	if (IsValidClient(client))
	{
		StopSound(client, SNDCHAN_AUTO, SND_MAGNESIS_GRAB_LOOP);

		if (!enemyWasThrown)
			EmitSoundToAll(SND_MAGNESIS_DROP, client);
		else
			EmitSoundToAll(SND_MAGNESIS_THROW, client);

		int weapon = EntRefToEntIndex(Magnesis_GrabWeapon[client]);
		if (!IsValidEntity(weapon))
			Ability_Apply_Cooldown(client, 2, Magnesis_CooldownToApply[client]);
		else
			Ability_Apply_Cooldown(client, 2, Magnesis_CooldownToApply[client], weapon);

		int victim = EntRefToEntIndex(Magnesis_GrabTarget[client]);
		if (IsValidEntity(victim))
		{
			Magnesis_Grabbed[victim] = false;
			Magnesis_DamageTakenWhileGrabbed[victim] = 0.0;
			Magnesis_DroppedAt[victim] = GetGameTime();
			if(!VIPBuilding_Active())
				view_as<CClotBody>(victim).m_iTarget = client;
		}

		Magnesis_GrabTarget[client] = -1;
	}
}

public bool Magnesis_TargetCanBeGrabbed(int client, int victim, int tier)
{
	if (!IsValidEnemy(client, victim))
		return false;

	if (b_NoKnockbackFromSources[victim])
	{
		Utility_HUDNotification_Translation(client, "Magnesis Target Immune to Knockback", true);
		return false;
	}

	if (b_NpcIsInvulnerable[victim])
	{
		Utility_HUDNotification_Translation(client, "Magnesis Target Invulnerable", true);
		return false;
	}

	if ((b_thisNpcIsARaid[victim] && !Magnesis_Grab_Raids[tier]) || (b_thisNpcIsABoss[victim] && !Magnesis_Grab_Specials[tier]))
	{
		Utility_HUDNotification_Translation(client, "Magnesis Target Too Strong", true);
		return false;
	}

	if (!Can_I_See_Enemy(client, victim))
	{
		Utility_HUDNotification_Translation(client, "Magnesis Target LOS Broken", true);
		return false;
	}

	float pos[3], ang[3], direction[3], hullMin[3], hullMax[3], endPos[3];
	WorldSpaceCenter(client, pos);

	ang[0] = 90.0;

	hullMin[0] = -20.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 120.0);
	AddVectors(pos, direction, endPos);

	TR_TraceHullFilter(pos, endPos, hullMin, hullMax, 1073741824, Magnesis_GrabTrace, client);
	int target = TR_GetEntityIndex();
	if (victim == target)
	{
		Utility_HUDNotification_Translation(client, "Magnesis Standing On Target", true);
		return false;
	}

	return true;
}

public bool Magnesis_MoveVictim(int client)
{
	int target = EntRefToEntIndex(Magnesis_GrabTarget[client]);
	if (!Magnesis_TargetCanBeGrabbed(client, target, Magnesis_Tier[client]))
		return false;

	float dragRate = Magnesis_Grab_DragRate[Magnesis_Tier[client]];
	float weight = float(i_NpcWeight[target]) - 1.0;
	if (weight > 0.0)
	{
		float weightPenalty = (weight * Magnesis_Grab_DragRate_WeightPenalty[Magnesis_Tier[client]]);
		dragRate -= weightPenalty;
		if (dragRate <= 0.0)
			return false;
	}
	
	float pos[3], ang[3], endPos[3], direction[3], vicPos[3], targVel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);

	ScaleVector(direction, Magnesis_Grab_Distance[Magnesis_Tier[client]]);
	AddVectors(pos, direction, endPos);

	WorldSpaceCenter(target, vicPos);
	SubtractVectors(endPos, vicPos, targVel);
	ScaleVector(targVel, dragRate);

	Magnesis_MakeNPCMove(target, targVel);

	float time = Magnesis_GetStunTime(client);
	if (time == 0.0)
		FreezeNpcInTime(target, 0.11);

	return true;
}

public void Magnesis_MakeNPCMove(int target, float targVel[3])
{
	//In tower defense, do not allow moving the target.
	if(VIPBuilding_Active())
		return;
		
	if(HasSpecificBuff(target, "Solid Stance"))
	{
		return;
	}
	if(i_IsNpcType[target] == 1)
		return;

	if(f_NoUnstuckVariousReasons[target] > GetGameTime() + 1.0)
	{
		//make the target not stuckable.
		f_NoUnstuckVariousReasons[target] = GetGameTime() + 1.0;
	}
	SDKUnhook(target, SDKHook_Think, NpcJumpThink);
	f3_KnockbackToTake[target] = targVel;
	SDKHook(target, SDKHook_Think, NpcJumpThink);
}

public bool Magnesis_GrabTrace(int entity, int contentsMask, int user)
{
	if (IsValidEnemy(user, entity, true) && entity != user)
		return true;
	
	return false;
}

public void Newtonian_Attack_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 0);
}

public void Newtonian_Attack_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 1);
}

public void Newtonian_Attack_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 2);
}

void Newtonian_FireProjectile(int client, int weapon, int tier)
{
	int mana_cost = RoundFloat(Attributes_Get(weapon, 733, 75.0));

	if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(client, weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		delay_hud[client] = 0.0;
		
		Utility_FireProjectile(client, weapon, tier, true);

		EmitSoundToAll(SND_NEWTONIAN_M1, client, _, _, _, 0.66);
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

public void Newtonian_Shockwave_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 0);
}

public void Newtonian_Shockwave_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 1);
}

public void Newtonian_Shockwave_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 2);
}

static int Newtonian_ShockwaveTier;

void Newtonian_TryShockwave(int client, int weapon, int tier)
{
	int mana_cost = RoundFloat(Newtonian_M2_Cost[tier]);
	float remCD = Ability_Check_Cooldown(client, 2, weapon);

	if(mana_cost <= Current_Mana[client] && remCD <= 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		float pos[3];
		GetClientAbsOrigin(client, pos);
		ParticleEffectAt(pos, PARTICLE_NEWTONIAN_M2);

		float damage = Newtonian_M2_DMG[tier];
		damage *= Attributes_Get(weapon, 410, 1.0);
		float radius = Newtonian_M2_Radius[tier];
		radius *= Attributes_Get(weapon, 103, 1.0);
		radius *= Attributes_Get(weapon, 104, 1.0);
		radius *= Attributes_Get(weapon, 475, 1.0);
		radius *= Attributes_Get(weapon, 101, 1.0);
		radius *= Attributes_Get(weapon, 102, 1.0);

		Newtonian_ShockwaveTier = tier;
		Explode_Logic_Custom(damage, client, client, weapon, pos, radius, Newtonian_M2_Falloff_MultiHit[tier], Newtonian_M2_Falloff_Distance[tier], _, Newtonian_M2_MaxTargets[tier], false, 1.0, view_as<Function>(Newtonian_M2_OnHit));

		TE_SetupBeamRingPoint(pos, 0.1, radius * 2.0, Beam_Lightning, Beam_Glow, 0, 10, 0.33, 25.0, 12.0, {255, 120, 120, 250}, 10, 0);
		TE_SendToAll(0.0);

		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		Ability_Apply_Cooldown(client, 2, Newtonian_M2_Cooldown[tier], weapon);

		EmitSoundToAll(SND_NEWTONIAN_M2, client, _, _, _, 0.8);
		EmitSoundToAll(SND_NEWTONIAN_M2_2, client, _, _, _, 0.8, 80);

		float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") + Newtonian_M2_AttackDelay[tier];
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", nextAttack);
	}
	else
	{
		if (remCD > 0.0)
			Utility_OnCooldown(client, remCD);
		else
			Utility_NotEnoughMana(client, mana_cost);
	}
}

public void Newtonian_M2_OnHit(int attacker, int victim, float damage)
{
	if (b_NoKnockbackFromSources[victim] || b_NpcIsInvulnerable[victim])
		return;

	float hKB = Newtonian_M2_Knockback_Horizontal[Newtonian_ShockwaveTier], vKB = Newtonian_M2_Knockback_Vertical[Newtonian_ShockwaveTier];
	if (b_thisNpcIsARaid[victim])
	{
		hKB *= Newtonian_M2_Knockback_RaidMult[Newtonian_ShockwaveTier];
		vKB *= Newtonian_M2_Knockback_RaidMult[Newtonian_ShockwaveTier];
	}

	float weight = float(i_NpcWeight[victim]) - 1.0;
	if (weight > 0.0)
	{
		float weightPenalty = (weight * Newtonian_M2_Knockback_WeightPenalty[Magnesis_Tier[attacker]]);
		hKB -= weightPenalty;
		vKB -= weightPenalty;
		
		if (hKB <= 0.0 && vKB <= 0.0)
			return;

		if (hKB <= 0.0)
			hKB = 0.0;
		if (vKB <= 0.0)
			vKB = 0.0;
	}

	CClotBody npc = view_as<CClotBody>(victim);
	float vel[3], userPos[3], vicPos[3], angles[3], tempVel[3];
	WorldSpaceCenter(attacker, userPos);
	WorldSpaceCenter(victim, vicPos);

	npc.GetVelocity(vel);
	if (vel[2] < vKB)
		vel[2] = vKB;
	else
		vel[2] += vKB;

	GetVectorAnglesTwoPoints(userPos, vicPos, angles);

	GetAngleVectors(angles, tempVel, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(tempVel, hKB);

	vel[1] = tempVel[1];

	Magnesis_MakeNPCMove(victim, vel);

	EmitSoundToAll(SND_NEWTONIAN_M2_KNOCKBACK, victim, _, _, _, _, GetRandomInt(80, 100));
	Newtonian_Airborne[victim] = true;
	CreateTimer(0.2, Newtonian_CheckOnGround, EntIndexToEntRef(victim), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Newtonian_CheckOnGround(Handle timely, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return Plugin_Stop;

	CClotBody npc = view_as<CClotBody>(ent);
	if (npc.IsOnGround())
	{
		Newtonian_Airborne[ent] = false;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void Magnesis_ProjectileTouch(int entity, int target)
{
	float selfPos[3], ang[3], direction[3], dmgForce[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	CalculateDamageForce(direction, 10000.0, dmgForce);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", selfPos);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);

	if (Magnesis_ProjectileIsNewtonian[entity])
	{
		Newtonian_ProjectileTouch(entity, selfPos, owner, weapon, target, particle, dmgForce);
		return;
	}

	if (target >= 0)	
	{
		if (target > 0)
		{
			float targPos[3];
			WorldSpaceCenter(target, targPos);
			SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, dmgForce, targPos, _ , ZR_DAMAGE_LASER_NO_BLAST);
		}

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		ParticleEffectAt(selfPos, PARTICLE_MAGNESIS_M1_COLLIDE);

		EmitSoundToAll(SND_MAGNESIS_M1_COLLIDE, entity, SNDCHAN_STATIC, 70, _, 0.9, GetRandomInt(80, 100));
		RemoveEntity(entity);
	}
}

public void Newtonian_ProjectileTouch(int entity, float selfPos[3], int owner, int weapon, int target, int particle, float dmgForce[3])
{
	if (target >= 0)
	{
		Explode_Logic_Custom(f_WandDamage[entity],
		 owner,
		  owner,
		   weapon,
		    selfPos,
			 Newtonian_M1_Radius[Magnesis_ProjectileTier[entity]],
		_,// Newtonian_M1_Falloff_MultiHit[Magnesis_ProjectileTier[entity]],
		_,//  Newtonian_M1_Falloff_Distance[Magnesis_ProjectileTier[entity]],
		   false,
		   Newtonian_M1_MaxTargets[Magnesis_ProjectileTier[entity]],
		    _,
			 _,
			  _,
			   view_as<Function>(Newtonian_M1Hit));

		ParticleEffectAt(selfPos, PARTICLE_NEWTONIAN_M1_COLLIDE);
		EmitSoundToAll(SND_NEWTONIAN_M1_COLLIDE, entity, SNDCHAN_STATIC, _, _, 0.8);
		EmitSoundToAll(SND_NEWTONIAN_M1_COLLIDE, entity, SNDCHAN_STATIC, _, _, 0.8);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		RemoveEntity(entity);
	}
}

public float Newtonian_M1Hit(int attacker, int victim, float damage, int weapon)
{
	if (Newtonian_Airborne[victim])
	{
		damage *= (2.0 * Newtonian_M1_ComboMult[Magnesis_Tier[attacker]]);
		DisplayCritAboveNpc(victim, attacker, true);

		float cd = Ability_Check_Cooldown(attacker, 2, weapon);
		if (cd > 0.0)
		{
			cd -= (b_thisNpcIsARaid[victim] ? Newtonian_M1_ComboCDR_Raids[Magnesis_Tier[attacker]] : Newtonian_M1_ComboCDR[Magnesis_Tier[attacker]]);
			Ability_Apply_Cooldown(attacker, 2, cd, weapon);
		}
	}

	return damage;
}

void Utility_FireProjectile(int client, int weapon, int tier, bool isNewtonian)
{
	float damage = (isNewtonian ? Newtonian_M1_DMG[tier] : Magnesis_M1_DMG[tier]);
	damage *= Attributes_Get(weapon, 410, 1.0);
			
	float speed = (isNewtonian ? Newtonian_M1_Velocity[tier] : Magnesis_M1_Velocity[tier]);
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	float time = (isNewtonian ? Newtonian_M1_Lifespan[tier] : Magnesis_M1_Lifespan[tier]);
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);
		
	char particle[64];
	if (isNewtonian)
	{
		if (tier > 1)
			particle = PARTICLE_NEWTONIAN_M1_FINALPAP;
		else
			particle = PARTICLE_NEWTONIAN_M1;
	}
	else
	{
		if (tier > 1)
			particle = PARTICLE_MAGNESIS_M1_FINALPAP;
		else
			particle = PARTICLE_MAGNESIS_M1;
	}

	float ang[3];
	GetClientEyeAngles(client, ang);
	if (!isNewtonian)
	{
		for (int i = 0; i < 3; i++)
			ang[i] += GetRandomFloat(-Magnesis_M1_Spread[tier], Magnesis_M1_Spread[tier]);
	}

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_MAGNESIS, weapon, particle, ang);
	if (IsValidEntity(projectile))
	{
		Magnesis_ProjectileIsNewtonian[projectile] = isNewtonian;
		Magnesis_ProjectileTier[projectile] = tier;

		if (!isNewtonian)
		{
			Handle swingTrace;
			float vecSwingForward[3];
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
						
			int target = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;

			if(IsValidEnemy(client, target))
			{
				DataPack pack = new DataPack();
				RequestFrames(Magnesis_DelayHoming, 5, pack);
				pack.WriteCell(EntIndexToEntRef(projectile)); //projectile
				pack.WriteCell(EntIndexToEntRef(target));		//victim to annihilate :)
			}
		}
	}

	Magnesis_Tier[client] = tier;
}

public void Magnesis_DelayHoming(DataPack pack)
{
	ResetPack(pack);
	int projectile = EntRefToEntIndex(ReadPackCell(pack));
	int target = EntRefToEntIndex(ReadPackCell(pack));
	if (!IsValidEntity(projectile) || !IsValidEntity(target))
		return;

	if(Can_I_See_Enemy_Only(target, projectile)) //Insta home!
	{
		HomingProjectile_TurnToTarget(target, projectile);
	}

	DataPack pack2;
	CreateDataTimer(0.1, PerfectHomingShot, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(projectile)); //projectile
	pack2.WriteCell(EntIndexToEntRef(target));		//victim to annihilate :)

	EmitSoundToAll(SND_MAGNESIS_HOMING_BEGIN, projectile, _, _, _, 0.66, GetRandomInt(60, 80));
}

void Utility_NotEnoughMana(int client, int cost)
{
	if (!IsValidClient(client))
		return;

	SetGlobalTransTarget(client);
	char text[255];
	Format(text, sizeof(text), "%t", "Not Enough Mana", cost);
	Utility_HUDNotification(client, text, true);
}

void Utility_OnCooldown(int client, float cost)
{
	if (!IsValidClient(client))
		return;

	SetGlobalTransTarget(client);
	char text[255];
	Format(text, sizeof(text), "%t", "Ability has cooldown", cost);
	Utility_HUDNotification(client, text, true);
}

void Utility_HUDNotification_Translation(int client, char translation[255], bool YouCantDoThat = false)
{
	if (!IsValidClient(client))
		return;

	SetGlobalTransTarget(client);
	char text[255];
	Format(text, sizeof(text), "%t", translation);
	Utility_HUDNotification(client, text, YouCantDoThat);
}

void Utility_HUDNotification(int client, char message[255], bool YouCantDoThat = false)
{
	if (!IsValidClient(client))
		return;

	if (YouCantDoThat)
		ClientCommand(client, "playgamesound items/medshotno1.wav");

	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, message);
}