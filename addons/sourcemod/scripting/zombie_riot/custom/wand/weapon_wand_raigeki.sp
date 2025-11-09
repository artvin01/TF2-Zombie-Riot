//THIS IS THE PSEUDO-MELEE MAGE WEAPON WITH THE GIANT LIGHTNING BOLT ON M2, NOT TO BE CONFUSED WITH REIUJI!!!!!!!!

#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

static int Raigeki_M1_NumBlades[4] = { 1, 2, 3, 4 };			    //Number of blade sweeps to perform in a row per M1.
static float Raigeki_M1_Range[4] = { 180.0, 200.0, 220.0, 240.0 };  //Electric blade range.
static float Raigeki_M1_Width[4] = { 120.0, 140.0, 160.0, 180.0 };  //Electric blade arc swing angle.
static float Raigeki_M1_Damage[4] = { 200.0, 400.0, 600.0, 900.0 }; //Electric blade damage.
static float Raigeki_M1_Falloff[4] = { 0.825, 0.85, 0.875, 0.9 };   //Amount to multiply electric blade damage per target hit.
static float Raigeki_M1_Interval[4] = { 0.5, 0.4, 0.3, 0.2 };       //Time it takes for electric blades to sweep across the screen.


static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};


public void Raigeki_ResetAll()
{
	Zero(ability_cooldown);
}

#define SOUND_RAIGEKI_BLADE_SWEEP       ")weapons/samurai/tf_katana_crit_miss_01.wav"

void Raigeki_Precache()
{
	PrecacheModel("materials/sprites/lgtning.vmt");
	PrecacheModel("materials/sprites/glow02.vmt");
    PrecacheModel("materials/effects/repair_claw_trail_red.vmt");
    PrecacheModel("materials/sprites/laser.vmt", false);

    PrecacheSound(SOUND_RAIGEKI_BLADE_SWEEP, true);
}

public void Raigeki_OnBurstPack(int client)
{
	/*int grabTarget = Raigeki_GetGrabTarget(client);
	if (IsValidEnemy(client, grabTarget))
	{
		Raigeki_TerminateEffects(client, EntRefToEntIndex(Raigeki_StartParticle[client]), EntRefToEntIndex(Raigeki_EndParticle[client]));

		float stopmoving[3];
		stopmoving[0] = 0.0;
		stopmoving[1] = 0.0;
		stopmoving[2] = 0.0;
		Raigeki_MakeNPCMove(Raigeki_GetGrabTarget(client), stopmoving);
	}*/
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

public void Raigeki_Attack_0(int client, int weapon, bool &result, int slot)
{
    Raigeki_FireWave(client, weapon, 0);
}

static int i_RemainingBlades[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeStartEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeEndEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeBeamEnt[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeWeapon[MAXPLAYERS + 1] = { 0, ... };
static int i_BladeIntendedTarget[MAXPLAYERS + 1] = { -1, ... };
static int i_BladeTier[MAXPLAYERS + 1] = { 0, ... };

static float f_LastGT[MAXPLAYERS + 1] = { 0.0, ... };
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
public int Blade_GetWeapon(int client) { return EntRefToEntIndex(i_BladeWeapon[client]); }

public bool Blade_IsHoldingCorrectWeapon(int client)
{
    int weapon = Blade_GetWeapon(client);
    if (!IsValidEntity(weapon))
        return false;

    int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    return acWep == weapon;
}

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
	int mana_cost = RoundFloat(Attributes_Get(weapon, 733, 40.0));

	if(mana_cost <= Current_Mana[client])
	{
        f_LastGT[client] = GetGameTime();

        i_BladeTier[client] = tier;
        i_BladeWeapon[client] = EntIndexToEntRef(weapon);
        i_RemainingBlades[client] = Raigeki_M1_NumBlades[tier];
        Blade_StartSwing(client);
        
        Utility_RemoveMana(client, mana_cost, (f_BladeInterval[client] * float(Raigeki_M1_NumBlades[tier])) + 1.25);
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
    int weapon = Blade_GetWeapon(client);

    f_BladeRange[client] = Raigeki_M1_Range[tier];
    f_BladeBaseDMG[client] = Raigeki_M1_Damage[tier];
    f_BladeWidth[client] = Raigeki_M1_Width[tier];
    f_BladeInterval[client] = Raigeki_M1_Interval[tier];

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
    f_BladeFalloff[client] = Raigeki_M1_Falloff[tier];
}

void Blade_StartSwing(int client)
{
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
            if (i_RemainingBlades[client] > 0 && Blade_IsHoldingCorrectWeapon(client))
                Blade_StartSwing(client);
        }

		return;
	}

    //While a blade is swinging, always extend the duration until the next melee attack by delta time, that way we can't swing again until all blades are finished swinging, but attack speed modifiers are still useful.
    int weapon = Blade_GetWeapon(client);
    if (IsValidEntity(weapon))
    {
        SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") + (gt - f_LastGT[client]));
    }

    f_LastGT[client] = gt;

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
        //TODO: REMOVE THIS ONCE DBEUGGING IS DONE!!!!!!!
        FreezeNpcInTime(victim, 2.0);
        dmg = f_BladeBaseDMG[attacker];
    }

    float force[3], pos[3], forceAng[3];

    for (int i = 0; i < 3; i++)
	    forceAng[i] = vec_BladeSwingAng[attacker][i];
	forceAng[1] = f_BladeStartAng[attacker] + ((f_BladeProgress[attacker]) * (f_BladeTargAng[attacker] - f_BladeStartAng[attacker]));
    
    CalculateDamageForce(forceAng, 10000.0, force);
    WorldSpaceCenter(victim, pos);

    int weapon = Blade_GetWeapon(attacker);
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

                //TODO: Maybe only do this while Supercharged? Not sure.
                trailPos[0] += GetRandomFloat(-5.0, 5.0);
               	trailPos[1] += GetRandomFloat(-5.0, 5.0);
                trailPos[2] += GetRandomFloat(-12.0, 12.0);

				TeleportEntity(trail, trailPos);

				SetEntPropFloat(trail, Prop_Data, "m_flStartWidth", beamWidth);
    			SetEntPropFloat(trail, Prop_Data, "m_flEndWidth", 0.0);

				SetEntityRenderColor(trail, r, g, b, 80 + RoundToFloor(strength * 175.0));
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

static void spawnRing_Vectorsss(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
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