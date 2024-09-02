#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//STANDARD M1 PROJECTILE: The Magnesis Staff's primary fire is nothing special, just a generic projectile.
//static float Magnesis_M1_Cost[3] = { 10.0, 10.0, 10.0 };            //M1 cost.
static float Magnesis_M1_DMG[3] = { 80.0, 120.0, 160.0 };             //M1 projectile damage.
static float Magnesis_M1_Lifespan[3] = { 0.2, 0.2, 0.2 };          //M1 projectile lifespan.
static float Magnesis_M1_Velocity[3] = { 1200.0, 1400.0, 1600.0 };  //M1 projectile velocity.

//M2 - GRAB: Clicking M2 on a living zombie allows the user to grab that zombie and hold it in front of them, provided 
//the target is within range. Holding a zombie drains mana, which becomes more expensive the longer the zombie is held.
//Held zombies are stunned. At any time, the user may press M2 again to throw the zombie (if they do not have the mana
//to afford the throw, the zombie is simply dropped). The velocity of this throw is based on the amount of damage
//that zombie took while grabbed, relative to their max health.
static float Magnesis_Grab_Requirement[3] = { 50.0, 100.0, 150.0 };		//Initial mana cost in order to grab an enemy.
static float Magnesis_Grab_Cooldown_Normal[3] = { 10.0, 10.0, 10.0 };	//Cooldown applied when grabbing normal zombies.
static float Magnesis_Grab_Cooldown_Special[3] = { 45.0, 45.0, 45.0 };	//Cooldown applied when grabbing mini-bosses/bosses.
static float Magnesis_Grab_Cooldown_Raids[3] = { 70.0, 70.0, 70.0 };	//Cooldown applied when grabbing raid bosses.
static float Magnesis_Grab_Cost_Normal[3] = { 5.0, 5.0, 5.0 };			//Mana drained per 0.1s while holding a normal enemy.
static float Magnesis_Grab_Cost_Special[3] = { 35.0, 35.0, 35.0 };		//Mana drained per 0.1s while holding a boss/mini-boss.
static float Magnesis_Grab_Cost_Raid[3] = { 75.0, 75.0, 75.0 };			//Mana drained per 0.1s while holding a raid.
static float Magnesis_Grab_Range[3] = { 150.0, 200.0, 250.0 };			//Maximum distance from which enemies can be grabbed.
static float Magnesis_Grab_Distance[3] = { 60.0, 60.0, 60.0 };			//Distance from the user to hold zombies at.
static float Magnesis_Grab_MaxVel[3] = { 400.0, 600.0, 800.0 };			//Maximum throw velocity.
static float Magnesis_Grab_ThrowCost[3] = { 200.0, 300.0, 400.0 };		//Cost to throw the enemy instead of simply dropping them.
static float Magnesis_Grab_ThrowThreshold[3] = { 0.75, 0.66, 0.5 };		//Percentage of max health taken as damage while grabbed in order for the throw to reach max velocity.
static float Magnesis_Grab_ThrowDMG[3] = { 1000.0, 1500.0, 2000.0 };	//Damage dealt to grabbed enemies when they are thrown.
static bool Magnesis_Grab_Specials[3] = { false, true, true };			//Can the Magnesis Staff grab bosses/mini-bosses on this tier?
static bool Magnesis_Grab_Raids[3] = { false, false, true };			//Can the Magnesis Staff grab raids on this tier?

//NEWTONIAN KNUCKLES: Alternate PaP path which replaces the M1 with a far stronger explosive projectile with a slower rate of fire.
//Replaces M2 with a shockwave that deals knockback. M1 projectile deals bonus damage if it airshots an enemy who is airborne because of the M2 attack.
//static float Newtonian_M1_Cost[3] = { 50.0, 75.0, 100.0 };						//M1 cost.
static float Newtonian_M1_DMG[3] = { 400.0, 800.0, 1200.0 };					//M1 damage.
static float Newtonian_M1_Radius[3] = { 150.0, 165.0, 180.0 };					//M1 explosion radius.
static float Newtonian_M1_Velocity[3] = { 1400.0, 1800.0, 2200.0 };				//M1 projectile velocity.
static float Newtonian_M1_Lifespan[3] = { 1.0, 1.15, 1.3 };						//M1 projectile lifespan.
static float Newtonian_M1_Falloff_MultiHit[3] = { 0.66, 0.75, 0.85 };			//Amount to multiply damage dealt by M1 per target hit.
static float Newtonian_M1_Falloff_Distance[3] = { 0.66, 0.75, 0.85 };			//Maximum M1 damage falloff, based on distance.
static float Newtonian_M1_ComboMult[3] = { 3.0, 3.0, 3.0 };						//Amount to multiply damage dealt by the M1 to enemies who have been knocked airborne by the M2.
static float Newtonian_M1_ComboCDR[3] = { 5.0, 5.0, 5.0 };					//Amount to reduce remaining M2 cooldown when airshotting an enemy launched by M2.
static int Newtonian_M1_MaxTargets[3] = { 4, 5, 6 };							//Max targets hit by the M1 projectile's explosion.
static float Newtonian_M2_Cost[3] = { 200.0, 300.0, 400.0 };					//M2 cost.
static float Newtonian_M2_Cooldown[3] = { 30.0, 30.0, 30.0 };					//M2 cooldown.
static float Newtonian_M2_DMG[3] = { 800.0, 1600.0, 2400.0 };					//M2 damage.
static float Newtonian_M2_Radius[3] = { 160.0, 180.0, 200.0 };					//M2 radius.
static float Newtonian_M2_Falloff_MultiHit[3] = { 0.5, 0.66, 0.75 };			//Amount to multiply damage dealt by the M2 shockwave per target hit.
static float Newtonian_M2_Falloff_Distance[3] = { 0.5, 0.66, 0.75 };			//Maximum M2 damage falloff, based on distance.
static float Newtonian_M2_Knockback_Horizontal[3] = { 400.0, 500.0, 600.0 };	//Horizontal knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_Vertical[3] = { 100.0, 125.0, 150.0 };		//Vertical knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_RaidMult[3] = { 0.5, 0.5, 0.5 };			//Amount to multiply knockback dealt to raids.
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

public void Magnesis_ResetAll()
{
	Zero(ability_cooldown);
}

#define SND_MAGNESIS_M1         	")weapons/capper_shoot.wav"
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

#define PARTICLE_MAGNESIS_M1     			"raygun_projectile_blue"
#define PARTICLE_MAGNESIS_M1_FINALPAP		"raygun_projectile_blue_crit"
#define PARTICLE_MAGNESIS_M1_COLLIDE		"impact_metal"
#define PARTICLE_MAGNESIS_GRAB				"medicgun_beam_machinery_trail"
#define PARTICLE_MAGNESIS_GRAB_FINALPAP		"medicgun_beam_blue_trail"
#define PARTICLE_NEWTONIAN_M1    			"raygun_projectile_red"
#define PARTICLE_NEWTONIAN_M1_FINALPAP    	"raygun_projectile_red_crit"
#define PARTICLE_NEWTONIAN_M1_COLLIDE		"drg_cow_explosioncore_charged"
#define PARTICLE_NEWTONIAN_M2				"mvm_soldier_shockwave"

static int Beam_Lightning;
static int Beam_Glow;

void Magnesis_Precache()
{
    PrecacheSound(SND_MAGNESIS_M1);
	PrecacheSound(SND_MAGNESIS_M1_COLLIDE);
	PrecacheSound(SND_MAGNESIS_GRAB);
	PrecacheSound(SND_MAGNESIS_GRAB_LOOP);
	PrecacheSound(SND_MAGNESIS_THROW);
	PrecacheSound(SND_MAGNESIS_DROP);
	PrecacheSound(SND_NEWTONIAN_M1);
	PrecacheSound(SND_NEWTONIAN_M1_COLLIDE);
	PrecacheSound(SND_NEWTONIAN_M2);
	PrecacheSound(SND_NEWTONIAN_M2_2);
	PrecacheSound(SND_NEWTONIAN_M2_KNOCKBACK);

	Beam_Lightning = PrecacheModel("materials/sprites/lgtning.vmt");
	Beam_Glow = PrecacheModel("materials/sprites/glow02.vmt");
}

void Magnesis_OnKill(int victim)
{
	Newtonian_Airborne[victim] = false;
	Magnesis_Grabbed[victim] = false;
}

public void Magnesis_OnNPCDamaged(int victim, float damage)
{
	if (Magnesis_Grabbed[victim])
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
				Format(HUDText, sizeof(HUDText), "%.2fx Throw Velocity\nPress M2 to throw this enemy!\nGrab cooldown upon releasing enemy: %.2fs", mult, Magnesis_CooldownToApply[client]);
			}

			PrintHintText(client, HUDText);

			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
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
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		Current_Mana[client] -= mana_cost;

		delay_hud[client] = 0.0;
		
		Utility_FireProjectile(client, weapon, tier, false);

        EmitSoundToAll(SND_MAGNESIS_M1, client, _, _, _, 0.4, GetRandomInt(80, 100));
		EmitSoundToClient(client, SND_MAGNESIS_M1, _, _, _, _, 0.33, GetRandomInt(80, 100));
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

public void Magnesis_Grab_0(int client, int weapon, bool &result, int slot)
{
	if (IsValidEntity(Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 0);
	else
    	Magnesis_AttemptGrab(client, weapon, 0);
}

public void Magnesis_Grab_1(int client, int weapon, bool &result, int slot)
{
    if (IsValidEntity(Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 1);
	else
    	Magnesis_AttemptGrab(client, weapon, 1);
}

public void Magnesis_Grab_2(int client, int weapon, bool &result, int slot)
{
    if (IsValidEntity(Magnesis_GetGrabTarget(client)))
		Magnesis_AttemptThrow(client, weapon, 2);
	else
    	Magnesis_AttemptGrab(client, weapon, 2);
}

int Magnesis_GetGrabTarget(int client)
{
	return EntRefToEntIndex(Magnesis_GrabTarget[client]);
}

void Magnesis_AttemptThrow(int client, int weapon, int tier)
{
	int target = Magnesis_GetGrabTarget(client);

	int cost = RoundFloat(Magnesis_Grab_ThrowCost[tier]);
	if (cost > Current_Mana[client])
	{
		Utility_HUDNotification_Translation(client, "Magnesis Throw Failed");
		Magnesis_TerminateEffects(client, EntRefToEntIndex(Magnesis_StartParticle[client]), EntRefToEntIndex(Magnesis_EndParticle[client]));
	}
	else
	{
		Magnesis_TerminateEffects(client, EntRefToEntIndex(Magnesis_StartParticle[client]), EntRefToEntIndex(Magnesis_EndParticle[client]), true);
		Client_Shake(client, _, 15.0, 33.0, 1.0);

		float vicPos[3], ang[3], buffer[3], vel[3];
		WorldSpaceCenter(target, vicPos);
		GetClientEyeAngles(client, ang);
		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);

		float throwVel = Magnesis_Grab_MaxVel[Magnesis_Tier[client]] * Magnesis_GetThrowVelMultiplier(client);
		for (int i = 0; i < 3; i++)
			vel[i] = buffer[i] * throwVel;
		
		Magnesis_MakeNPCMove(target, vel);

		float dmg = Magnesis_Grab_ThrowDMG[tier];
		dmg *= Attributes_Get(weapon, 410, 1.0);
		SDKHooks_TakeDamage(target, client, client, dmg, _, weapon, _, vicPos);

		Current_Mana[client] -= cost;
	}

	Magnesis_GrabTarget[client] = -1;
}

float Magnesis_GetThrowVelMultiplier(int client)
{
	int target = Magnesis_GetGrabTarget(client);
	float maxHP = float(GetEntProp(target, Prop_Data, "m_iMaxHealth"));
	float percentage = Magnesis_DamageTakenWhileGrabbed[target] / maxHP;

	float multiplier = percentage / Magnesis_Grab_ThrowThreshold[Magnesis_Tier[client]];
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
		b_LagCompNPC_ExtendBoundingBox = true;
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

		if (Magnesis_Grabbed[victim])
		{
			Utility_HUDNotification_Translation(client, "Magnesis Already Grabbed", true);
			return;
		}

		if (!Magnesis_TargetCanBeGrabbed(client, victim, tier))
			return;

		Magnesis_Tier[client] = tier;
		Magnesis_Grabbed[victim] = true;
		Magnesis_GrabTarget[client] = EntIndexToEntRef(victim);
		float cd = Magnesis_Grab_Cooldown_Normal[tier];
		if (b_thisNpcIsARaid[victim])
			cd = Magnesis_Grab_Cooldown_Raids[tier];
		else if (b_thisNpcIsABoss[victim])
			cd = Magnesis_Grab_Cooldown_Special[tier];
		Magnesis_CooldownToApply[client] = cd;

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
		CreateDataTimer(0.1, Magnesis_Logic, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, EntIndexToEntRef(start));
		WritePackCell(pack, EntIndexToEntRef(end));

		Rogue_OnAbilityUse(weapon);
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

public Action Magnesis_Logic(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int startPart = EntRefToEntIndex(ReadPackCell(pack));
	int endPart = EntRefToEntIndex(ReadPackCell(pack));

	if (!IsValidClient(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		return Plugin_Stop;
	}

	if (Magnesis_GrabTarget[client] == -1)
		return Plugin_Stop;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (!IsValidEntity(weapon))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		return Plugin_Stop;
	}

	if (dieingstate[client] > 0 || i_CustomWeaponEquipLogic[weapon] != WEAPON_MAGNESIS || !IsPlayerAlive(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		return Plugin_Stop;
	}

	if (!Magnesis_MoveVictim(client))
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		return Plugin_Stop;
	}

	int target = EntRefToEntIndex(Magnesis_GrabTarget[client]);

	float cost = Magnesis_Grab_Cost_Normal[Magnesis_Tier[client]];
	if (b_thisNpcIsARaid[target])
		cost = Magnesis_Grab_Cost_Raid[Magnesis_Tier[client]];
	else if (b_thisNpcIsABoss[target])
		cost = Magnesis_Grab_Cost_Special[Magnesis_Tier[client]];

	int realCost = RoundFloat(cost);

	if (realCost > Current_Mana[client])
	{
		Magnesis_TerminateEffects(client, startPart, endPart);
		return Plugin_Stop;
	}

	Current_Mana[client] -= realCost;
	SDKhooks_SetManaRegenDelayTime(client, 1.0);

	return Plugin_Continue;
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

		Ability_Apply_Cooldown(client, 2, Magnesis_CooldownToApply[client]);

		int victim = EntRefToEntIndex(Magnesis_GrabTarget[client]);
		if (IsValidEntity(victim))
			Magnesis_Grabbed[victim] = false;

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

	return true;
}

public bool Magnesis_MoveVictim(int client)
{
	int target = EntRefToEntIndex(Magnesis_GrabTarget[client]);
	if (!Magnesis_TargetCanBeGrabbed(client, target, Magnesis_Tier[client]))
		return false;
	
	float pos[3], ang[3], endPos[3], direction[3], vicPos[3], targVel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, Magnesis_Grab_Distance[Magnesis_Tier[client]]);
	AddVectors(pos, direction, endPos);

	WorldSpaceCenter(target, vicPos);
	SubtractVectors(pos, vicPos, targVel);
	ScaleVector(targVel, 10.0);

	Magnesis_MakeNPCMove(target, targVel);

	FreezeNpcInTime(target, 0.11);

	return true;
}

public void Magnesis_MakeNPCMove(int target, float targVel[3])
{
	CClotBody npc = view_as<CClotBody>(target);
	if (npc.IsOnGround())
	{
		targVel[2] = fmax(targVel[2], 300.0);
	}
	else
		targVel[2] += 100.0;

	npc.SetVelocity(targVel);
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
		Rogue_OnAbilityUse(weapon);
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
		Rogue_OnAbilityUse(weapon);
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

	CClotBody npc = view_as<CClotBody>(victim);
	float vel[3], userPos[3], vicPos[3], angles[3], tempVel[3];
	WorldSpaceCenter(attacker, userPos);
	WorldSpaceCenter(victim, vicPos);

	vicPos[2] += vKB;
	PluginBot_Jump(victim, vicPos);

	npc.GetVelocity(vel);

	GetVectorAnglesTwoPoints(userPos, vicPos, angles);

	GetAngleVectors(angles, tempVel, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(tempVel, hKB);

	vel[1] = tempVel[1];

	npc.SetVelocity(vel);

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
		Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, selfPos, Newtonian_M1_Radius[Magnesis_ProjectileTier[entity]], Newtonian_M1_Falloff_MultiHit[Magnesis_ProjectileTier[entity]], Newtonian_M1_Falloff_Distance[Magnesis_ProjectileTier[entity]], false, Newtonian_M1_MaxTargets[Magnesis_ProjectileTier[entity]], _, _, _, view_as<Function>(Newtonian_M1Hit));

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
		damage *= Newtonian_M1_ComboMult[Magnesis_Tier[attacker]];
		DisplayCritAboveNpc(victim, attacker, true);

		float cd = Ability_Check_Cooldown(attacker, 2, weapon);
		if (cd > 0.0)
		{
			cd -= Newtonian_M1_ComboCDR[attacker];
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

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_MAGNESIS, weapon, particle);
	if (IsValidEntity(projectile))
	{
		Magnesis_ProjectileIsNewtonian[projectile] = isNewtonian;
		Magnesis_ProjectileTier[projectile] = tier;
	}

	Magnesis_Tier[client] = tier;
}

void Utility_NotEnoughMana(int client, int cost)
{
	char text[255];
	Format(text, sizeof(text), "%t", "Not Enough Mana", cost);
	Utility_HUDNotification(client, text, true);
}

void Utility_OnCooldown(int client, float cost)
{
	char text[255];
	Format(text, sizeof(text), "%t", "Ability has cooldown", cost);
	Utility_HUDNotification(client, text, true);
}

void Utility_HUDNotification_Translation(int client, char translation[255], bool YouCantDoThat = false)
{
	char text[255];
	Format(text, sizeof(text), "%t", translation);
	Utility_HUDNotification(client, text, YouCantDoThat);
}

void Utility_HUDNotification(int client, char message[255], bool YouCantDoThat = false)
{
	if (YouCantDoThat)
		ClientCommand(client, "playgamesound items/medshotno1.wav");

	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, message);
}