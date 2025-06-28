#pragma semicolon 1
#pragma newdecls required

/*
TODO: make everything :
(augh)

This kit introduces the Plasmic Elemental debuff.
If filled, the following happens:
- victim recieves vulnerability for a certain duration, both things based on attacker's pap level, 
maxing out at +34% vulnerability for 6 (melee) / 4 (ranged) seconds. duration is reduced by half against raids/bosses.
- victim recieves the Plasm debuff with a duration based on attacker's pap level, 
maximg out at 6 (melee) / 4 (ranged) seconds. duration is reduced by 25% on bosses and by 35% on raids
- has NO elemental immunity cooldown, however the more times its triggered, the lower the elemental buildup will be
on the target until it dies. (buildup is multiplied by x0.5 [ranged] / x0.75 [melee] each time)

PASSIVE - Plasma Levelling
If the victim already has a level of the Plasm debuff, and is inflicted with the Plasm debuff again, its strength is increased, up to Plasm III.
(say, if the victim has Plasm I, it gets upgraded to Plasm II, and if it has Plasm II, it gets upgraded to Plasm III.)

Plasma Injector (melee) - Grants NO resistance, is meant to be more like a quick-use weapon now.
Inflicts 100% of its damage as Plasmic Elemental damage.
Lethal Injection (M2 Melee Ability), upon activation:
- Next melee attack will deal x1.75 damage
- Next melee attack will deal x3.5 Plasmic Elemental damage.
PaP Upgrades (all of them increase overall stats):
1 - Allows the Plasmic Injector to deal x1.5 damage against Plasm-ed targets.
2 - Unlocks Lethal Injection.
3 - Allows Lethal Injection to inflict Plasm I for 5 seconds. (x0.5 against bosses/raids)
4 - Reduces Lethal Injection's cooldown.
5 - Ditto, allows it to inflict Plasm II for 5 seconds. (x0.5 against bosses/raids)

Plasm-ubblinator (secondary) - A secondary unlocked after papping it once.
Doesn't fire normally, instead it only fires after charging its ability.
You can charge it dealing hits to enemies. Melee hits charge the ability as twice as fast.
Plasmatized Bubble (M1/M2 Ability), upon activation:
- Shoots a gravity-affected projectile that, upon landing, creates an AoE zone that grows,
enemies inside this AoE zone recieve Plasm I (which lingers for 1s after they're out of it)
and a above-average amount of Plasmic Elemental Damage. This bubble checks for targets every 0.5s.
- The bubble lasts for a base duration of 6 seconds.
- This weapon is NOT affected by Plasma Levelling, and thus will always inflict Plasm I regardless.
PaP Upgrades (all of them increase its Plasmic Elemental Damage):
1 - Unlocks the Plasm-ubblinator.
2 - Reduces the hits required to charge the Plasmatized Bubble.
Increases the bubble's duration by 1.5 seconds.
3 - Increases the lingering duration of the Plasm I debuff inside it by 1s.
4 - Reduces the hits required to charge the Plasmatized Bubble.
Increases the bubble's duration by 1.5 seconds.
5 - Increases the lingering duration of its Plasm I debuff inside it by 1s,
and reduces the hits required to charge the Plasmatized Bubble.
Increases the bubble's duration by 1 second.

Koshi's Plasminator (primary) - Shoots "plasmic balls" in quick succession, like the clockwork assault rifle from Terraria.
These projectiles deal 33% of their damage as Plasmic Elemental damage.
Plasmic Burst (M2 Primary Ability), upon activation:
- Shoots a short-ranged laser that causes a bit of shake.
- This laser inflicts AoE damage in front, and deals 50% of its damage as Plasmic Elemental damage.
PaP Upgrades (all of them increase overall stats):
1 - Nothing special.
2 - Unlocks Plasmic Burst.
3 - Now allows Plasmic Burst to inflict Plasm I for 5s to the enemies it hits. (x0.5 on raids/bosses),
4 - Slightly increases its range and increases its Plasmic Elemental damage by an additional 7.5%, 
also reduces its cooldown by 5 seconds.
5 - Ditto.

6th, 7th and 8th paps increase ALL stats and almost all ability stats overall.
*/

#define SOUND_LETHAL_ABILITY "items/powerup_pickup_reflect.wav"
#define SOUND_CHEESEBALL_SQUASH "ui/hitsound_squasher.wav"
#define SOUND_ELEMENTALAPPLY    "ui/killsound_vortex.wav"
#define SOUND_CHEDDAR_ABILITY  "weapons/tf2_back_scatter.wav"

static int LaserIndex;
static int Cheese_PapLevel[MAXPLAYERS];

static int Cheese_Glow;
static int Cheese_Bubble_Hits[MAXPLAYERS];
static int Cheese_BuildingHit[MAX_TARGETS_HIT];
static float Cheese_TargetsHit[MAXPLAYERS];
static float hudtimer[MAXPLAYERS];
static int iref_WeaponConnect[MAXPLAYERS+1][3];

static float Cheese_Buildup_Penalty[MAXENTITIES];

static int Cheese_Bubble_MaxHits[9]  = {100, 100, 100, 100, 85, 70, 65, 60, 60}; // Plasmatized Bubble's max charge
static float Cheese_Bubble_ElementalDmg = 50.0; // Plasmatized Bubble's base plasmic elemental damage, multiplied by the weapon's damage attrib
static float Cheese_Lethal_Cooldown[9]  = {30.0, 30.0, 30.0, 30.0, 25.0, 20.0, 17.5, 15.0, 12.5}; // Lethal Injection's cooldown
static float Cheese_Lethal_DmgBoost[9] = {1.75, 1.75, 1.75, 1.75, 1.8, 1.85, 1.9, 1.95, 2.0}; // Lethal Injection's damage bonus
static float Cheese_Lethal_ElementalBoost[9] = {3.0, 3.0, 3.0, 3.0, 3.25, 3.5, 3.75, 4.0, 4.25}; // Lethal Injection's elemental damage bonus
static float Cheese_Burst_ElementalDmg[9]  = {0.50, 0.50, 0.575, 0.65, 0.725, 0.8, 0.875, 0.95, 1.0}; // Elemental damage multiplier for Plasmic Burst
static float Cheese_Burst_Range[9]  = {225.0, 225.0, 225.0, 225.0, 240.0, 255.0, 270.0, 285.0, 300.0}; // Elemental damage multiplier for Plasmic Burst
static float Cheese_Burst_Cooldown[9]  = {22.5, 22.5, 22.5, 22.5, 17.5, 15.0, 12.5, 10.0, 7.5}; // Plasmic Burst's cooldown

static Handle EffectTimer[MAXPLAYERS];
static bool Precached = false;
void Cheese_MapStart()
{
	PrecacheSound(SOUND_LETHAL_ABILITY, true);
	PrecacheSound(SOUND_CHEESEBALL_SQUASH, true);
	PrecacheSound(SOUND_ELEMENTALAPPLY, true);
	PrecacheSound(SOUND_CHEDDAR_ABILITY, true);
	PrecacheSound(")weapons/tf2_backshot_shotty.wav");
	Zero(Cheese_PapLevel);
	Zero(Cheese_Bubble_Hits);
	Zero(Cheese_TargetsHit);
	Zero(hudtimer);
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Cheese_Glow = PrecacheModel("sprites/glow02.vmt", true);
	Precached = false;
}

void Cheese_PrecacheMusic()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/cheese_lastman.mp3",_,1);
		Precached = true;
	}
}

void Cheese_BeamEffect(float position[3], float startrad = 1.0, float endrad = 125.0, float lifetime = 0.25, float width = 6.5, bool elemental = false, int client = -1)
{
	if(elemental)
	{
		TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, 0.0, { 235, 75, 210, 60 }, 1, 0);
		TE_SendToClient(client);
	}
	else
	{
		TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, 0.0, { 235, 75, 210, 200 }, 1, 0);
		TE_SendToAll();
	}
}

void Cheese_PlaySplat(int entity)
{
	int pitch = GetRandomInt(75, 125);
	EmitSoundToAll(SOUND_ELEMENTALAPPLY, entity, _, _, _, _, pitch);
	//EmitSoundToAll(SOUND_ELEMENTALAPPLY, entity, _, _, _, _, pitch);
}

void Cheese_SetPenalty(int entity, float mult)
{
	Cheese_Buildup_Penalty[entity] *= mult;
}

float Cheese_GetPenalty(int entity)
{
	return Cheese_Buildup_Penalty[entity];
}

void Cheese_OnNPCDeath(int i)
{
	Cheese_Buildup_Penalty[entity] = 1.0;
}

void Cheese_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_PRIMARY)
	{
		iref_WeaponConnect[client][2] = EntIndexToEntRef(weapon);
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_SECONDARY)
	{
		iref_WeaponConnect[client][1] = EntIndexToEntRef(weapon);
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_MELEE)
	{
		iref_WeaponConnect[client][0] = EntIndexToEntRef(weapon);
		if(FileNetwork_Enabled())
			Cheese_PrecacheMusic();

		if(EffectTimer[client] != null)
		{
			delete EffectTimer[client];
			EffectTimer[client] = null;
		}

		DataPack pack;
		EffectTimer[client] = CreateDataTimer(0.25, Cheese_EffectTimer, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

// its so fucking over
bool Is_Cheesed_Up(int client)
{
	if(EffectTimer[client] != null)
		return true;

	return false;
}

public Action Cheese_EffectTimer(Handle timer, DataPack DataDo)
{
	DataDo.Reset();
	int client = DataDo.ReadCell();
	int weapon = EntRefToEntIndex(DataDo.ReadCell());
	if(!IsValidEntity(weapon) || !IsValidClient(client) || !IsPlayerAlive(client))
	{
		EffectTimer[client] = null;
		return Plugin_Stop;
	}	

	Cheese_PapLevel[client] = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	if(LastMann)
	{
	 	ApplyStatusEffect(client, client, "Plasmatic Rampage", 0.5);
		HealEntityGlobal(client, client, 15.0, 0.25, 0.0, HEAL_SELFHEAL);
	}

	Cheese_Hud(client, false);		
	
	return Plugin_Continue;
}

static void Cheese_Hud(int client, bool ignorecd)
{
	float GameTime = GetGameTime();

	if(hudtimer[client] > GameTime && !ignorecd)
		return;

	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 5.0;
	if(LastMann)
	{
		Cheese_BeamEffect(pos, 200.0, 1.0, 0.075, 10.0);
	}
	else
	{
		Cheese_BeamEffect(pos, 1.0, 75.0, 0.075, 5.0, true, client);
	}

	float LethalCooldown = 0.0;
	float BurstCooldown = 0.0;
	int WeaponEntity = EntRefToEntIndex(iref_WeaponConnect[client][0]);
	if(IsValidEntity(WeaponEntity))
	{
		//3 is R
		//2 is M2
		LethalCooldown = Ability_Check_Cooldown(client, 2, WeaponEntity);
	}
	WeaponEntity = EntRefToEntIndex(iref_WeaponConnect[client][2]);
	if(IsValidEntity(WeaponEntity))
	{
		BurstCooldown = Ability_Check_Cooldown(client, 2, WeaponEntity);
	}

	char CheeseHud[255];
	if(Cheese_PapLevel[client] > 1)
	{
		if(HasSpecificBuff(client, "Plasmatized Lethalization"))
		{
			Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: ACTIVE!", CheeseHud);
			Cheese_BeamEffect(pos, 1.0, 100.0, 0.075, 7.5, true, client);
		}
		else
		{
			if(LethalCooldown <= 0.0)
				Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: Ready!", CheeseHud);
			else
				Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: [%.1f]", CheeseHud, LethalCooldown);
		}		

		if(BurstCooldown <= 0.0)
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmic Burst: Ready!", CheeseHud);
		else
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmic Burst: [%.1f]", CheeseHud, BurstCooldown);

		if(Cheese_Bubble_Hits[client] >= Cheese_Bubble_MaxHits[Cheese_PapLevel[client]])
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmatized Bubble: Ready!", CheeseHud);
		else
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmatized Bubble: [%d | %d]", CheeseHud, Cheese_Bubble_Hits[client], Cheese_Bubble_MaxHits[Cheese_PapLevel[client]]);
	}

	hudtimer[client] = GameTime + 0.5;
	PrintHintText(client, "%s", CheeseHud);
}

public float Cheese_OnTakeDamage_Melee(int attacker, int victim, float &damage, int damagetype, int weapon)
{
	if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return damage;

	if((damagetype & DMG_CLUB))
	{   
		float cheesedmg = damage;

		if(Cheese_PapLevel[attacker] > 0 && (HasSpecificBuff(victim, "Plasm I") || HasSpecificBuff(victim, "Plasm II") || HasSpecificBuff(victim, "Plasm III")))
		{
			damage *= 1.5;
		}

		if(HasSpecificBuff(attacker, "Plasmatized Lethalitation"))
		{
			cheesedmg *= Cheese_Lethal_ElementalBoost[Cheese_PapLevel[attacker]];
			damage *= Cheese_Lethal_DmgBoost[Cheese_PapLevel[attacker]];

			if(Cheese_PapLevel[attacker] > 2)
			{
				bool IsNotNormal = (b_thisNpcIsARaid[victim]] || b_thisNpcIsABoss[victim]);
				if(Cheese_PapLevel[attacker] > 4)
				{
					if(HasSpecificBuff(victim, "Plasm III"))
					{
						ApplyStatusEffect(attacker, victim, "Plasm III", (IsNotNormal ? 2.5 : 5.0));
					}
					else if(HasSpecificBuff(victim, "Plasm II"))
					{
						ApplyStatusEffect(attacker, victim, "Plasm III", (IsNotNormal ? 2.5 : 5.0));
					}
					else
					{
						ApplyStatusEffect(attacker, victim, "Plasm II", (IsNotNormal ? 2.5 : 5.0));
					}
				}
				else
				{
					if(HasSpecificBuff(victim, "Plasm III"))
					{
						ApplyStatusEffect(attacker, victim, "Plasm III", (IsNotNormal ? 2.5 : 5.0));
					}
					else if(HasSpecificBuff(victim, "Plasm II"))
					{
						ApplyStatusEffect(attacker, victim, "Plasm III", (IsNotNormal ? 2.5 : 5.0));
					}
					else if(HasSpecificBuff(victim, "Plasm I"))
					{
						ApplyStatusEffect(attacker, victim, "Plasm II", (IsNotNormal ? 2.5 : 5.0));
					}
					else
					{
						ApplyStatusEffect(attacker, victim, "Plasm I", (IsNotNormal ? 2.5 : 5.0));
					}
				}
			}

			float position[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
			position[2] += 25.0;
			Cheese_BeamEffect(position, 10.0, 200.0, 0.2, 7.5);
			position[2] -= 12.5;
			Cheese_BeamEffect(position, 1.0, 150.0, 0.1, 5.0);

			Rogue_OnAbilityUse(attacker, weapon);
			RemoveSpecificBuff(attacker, "Plasmatized Lethalitation");
			Ability_Apply_Cooldown(attacker, 2, Cheese_Lethal_Cooldown[Cheese_PapLevel[attacker]]);
			EmitSoundToClient(attacker, SOUND_LETHAL_ABILITY);
		}
		//Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(cheesedmg * 1.5), weapon);
	}

	return damage;
}

void Cheese_OnTakeDamage_Primary(int attacker, int victim, float damage, int weapon)
{
	//Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(damage * 0.33), weapon);
}

public void Weapon_Kit_Cheddinator_M2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && Cheese_PapLevel[client] >= 2)
		{
			Rogue_OnAbilityUse(client, weapon);
			float Cooldown = Cheese_Burst_Cooldown[Cheese_PapLevel[client]];
			if(HasSpecificBuff(client, "Plasmatic Rampage"))
				Cooldown *= 0.65;

			Ability_Apply_Cooldown(client, slot, Cooldown);
			EmitSoundToClient(client, SOUND_CHEDDAR_ABILITY);
			Cheese_PlaySplat(client);

			Cheese_TargetsHit[client] = 0.0;

			float basedmg = (375.0 * Attributes_Get(weapon, 2, 1.0));
			basedmg *= Attributes_Get(weapon, 1, 1.0);
			Client_Shake(client, 0, 35.0, 90.0, 0.6);

			Cheese_Burst(client, basedmg, basedmg, Cheese_Burst_Range[Cheese_PapLevel[client]], 12.5, weapon);
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
					
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
	}
}

public void Weapon_Kit_CheeseInject_M2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && Cheese_PapLevel[client] >= 2)
		{
			ApplyStatusEffect(client, client, "Plasmatized Lethalization", 999.0);
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
	}
}

public void Cheese_ProjectileTouch(int entity, int target)
{
	bool remove = false;
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		remove = true;
	}
	else if(target == 0)
	{
		remove = true;
	}

	if(remove)
	{
		EmitSoundToAll(SOUND_CHEESEBALL_SQUASH, entity, SNDCHAN_STATIC, 65, _, 0.65);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}

public void Weapon_Kit_Cheddinator_Fire(int client, int weapon, bool crit)
{		
	int FrameDelayAdd = 10;
	float Attackspeed = Attributes_Get(weapon, 6, 1.0);
	Attackspeed *= 0.5;

	FrameDelayAdd = RoundToNearest(float(FrameDelayAdd) * Attackspeed);
	for(int LoopFire ; LoopFire <= 2; LoopFire++)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		if(LoopFire == 0)
			pack.WriteCell(0);
		else
			pack.WriteCell(1);

		if(LoopFire == 0)
			Weapon_Kit_Cheddinator_FireInternal(pack);
		else
			RequestFrames(Weapon_Kit_Cheddinator_FireInternal, RoundToNearest(float(FrameDelayAdd) * LoopFire), pack);
	}
}
public void Weapon_Kit_Cheddinator_FireInternal(DataPack DataDo)
{		
	DataDo.Reset();
	int client = EntRefToEntIndex(DataDo.ReadCell());
	int weapon = EntRefToEntIndex(DataDo.ReadCell());
	bool PlaySound = DataDo.ReadCell();
	delete DataDo;

	if(!IsValidEntity(weapon) || !IsValidClient(client))
		return;
	if(PlaySound)
	{
	//	char SoundStringToPlay[255];
	//	SDKCall_GetShootSound(weapon, SINGLE, SoundStringToPlay, sizeof(SoundStringToPlay));

		EmitSoundToAll(")weapons/tf2_backshot_shotty.wav", client, SNDCHAN_WEAPON, RoundToNearest(90.0 * f_WeaponVolumeSetRange[weapon])
			, _, 1.0 * f_WeaponVolumeStiller[weapon]);
	}

	float damage = 125.0;
	damage *= WeaponDamageAttributeMultipliers(weapon);
		
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	float time = 1400.0/(speed*0.85);
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);
		
	char particle[32];
		
	Format(particle, sizeof(particle), "%s", "eyeboss_projectile");

	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, particle);
	WandProjectile_ApplyFunctionToEntity(projectile, Cheese_ProjectileTouch);
}

static void Cheese_Burst(int client, float dmgclose, float dmgfar, float maxdist, float beamradius, int weapon)
{
	if(!IsValidClient(client))
	{
		return;
	}

	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		Cheese_BuildingHit[building] = false;
		Cheese_TargetsHit[client] = 0.0;
	}

	float diameter = beamradius * 2.0;
	
	int red = 235;
	int green = 75;
	int blue = 215;
		
	static float angles[3];
	static float startPoint[3];
	static float endPoint[3];
	static float hullMin[3];
	static float hullMax[3];
	static float playerPos[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, startPoint);
	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
		CloseHandle(trace);
		ConformLineDistance(endPoint, startPoint, endPoint, maxdist);
		float lineReduce = beamradius * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}	
		
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			Cheese_BuildingHit[building] = false;
		}
		
		hullMin[0] = -beamradius;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		Cheese_TargetsHit[client] = 1.0;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (Cheese_BuildingHit[building])
			{
				if(IsValidEntity(Cheese_BuildingHit[building]))
				{
					WorldSpaceCenter(Cheese_BuildingHit[building], playerPos);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = dmgclose + (dmgfar-dmgclose) * (distance/maxdist);
					if (damage < 0)
						damage *= -1.0;

					if(Cheese_PapLevel[client] > 2)
					{
						float duration = 5.0;
						if(b_thisNpcIsARaid[Cheese_BuildingHit[building]] || b_thisNpcIsABoss[Cheese_BuildingHit[building]])
						{
							duration *= 0.5;
						}
						
						if(HasSpecificBuff(Cheese_BuildingHit[building], "Plasm III"))
						{
							ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm III", duration);
						}
						else if(HasSpecificBuff(Cheese_BuildingHit[building], "Plasm II"))
						{
							ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm III", duration);
						}
						else if(HasSpecificBuff(Cheese_BuildingHit[building], "Plasm I"))
						{
							ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm II", duration);
						}
						else
						{
							ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm I", duration);
						}
					}

					if(IsValidEntity(weapon))
						Elemental_AddPlasmicDamage(Cheese_BuildingHit[building], client, RoundToNearest(damage * Cheese_Burst_ElementalDmg[Cheese_PapLevel[client]]), weapon);
					
					float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(Cheese_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage*Cheese_TargetsHit[client]);
					pack.WriteCell(DMG_BULLET);
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					pack.WriteCell(0);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					
					Cheese_TargetsHit[client] *= 0.75;
				}
				else
					Cheese_BuildingHit[building] = false;
			}
		}
		
		static float belowBossEyes[3];
		GetBeamDrawStartPoint(client, belowBossEyes, {0.0, 0.0, 0.0});
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, red, green, blue, 255);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 235 / 8, colorLayer4[1] * 7 + 75 / 8, colorLayer4[2] * 7 + 210 / 8, 255);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 470 / 8, colorLayer4[1] * 6 + 150 / 8, colorLayer4[2] * 6 + 420 / 8, 255);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 705 / 8, colorLayer4[1] * 5 + 225 / 8, colorLayer4[2] * 5 + 630 / 8, 255);
		TE_SetupBeamPoints(belowBossEyes, endPoint, LaserIndex, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.35), 0, 1.25, colorLayer1, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, LaserIndex, 0, 0, 0, 0.25, ClampBeamWidth(diameter * 0.5 * 1.3), ClampBeamWidth(diameter * 0.5 * 1.4), 0, 1.25, colorLayer1, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, red, green, blue, 175);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Cheese_Glow, 0, 0, 0, 0.3, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.35), 0, 1.65, glowColor, 0);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Cheese_Glow, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.5 * 1.3), ClampBeamWidth(diameter * 0.5 * 1.4), 0, 1.65, glowColor, 0);
		TE_SendToAll(0.0);
	}
	else
	{
		delete trace;
	}
}

static void GetBeamDrawStartPoint(int client, float startPoint[3], float offset[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
	if (0.0 == offset[0] && 0.0 == offset[1] && 0.0 == offset[2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = offset[0];
	tmp[1] = offset[1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = offset[2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

static bool TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=0; i < (MAX_TARGETS_HIT ); i++)
			{
				if(!Cheese_BuildingHit[i])
				{
					Cheese_BuildingHit[i] = entity;
					break;
				}
			}
			
		}
	}
	return false;
}
