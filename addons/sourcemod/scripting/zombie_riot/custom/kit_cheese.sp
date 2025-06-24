#pragma semicolon 1
#pragma newdecls required

/*
TODO: make everything later

this is STILL plasma, not cheese... smh....

This kit introduces the Plasmic Elemental debuff.
If filled, the following happens:
- victim recieves vulnerability for a certain duration, both things based on attacker's pap level, 
maxing out at +40% vulnerability for 6 (melee) / 4 (ranged) seconds.
- victim recieves the Plasm I debuff with a duration based on attacker's pap level, 
maximg out at 9 (melee) / 6 (ranged) seconds. duration is reduced by 20% on bosses and by 35% on raids
- if the victim already has a Plasm debuff, its strength is increased, up to Plasm III.
(say, if the victim has Plasm I, it gets upgraded to Plasm II, and if it has Plasm II, it gets upgraded to Plasm III.)
- elemental immunity cooldown is reduced from 15 to 10 seconds.

Plasma Injector (melee) - Grants NO resistance, is meant to be more like a quick-use weapon now.
Inflicts 100% of its damage as Plasmic Elemental damage.
Lethal Injection (M2 Melee Ability), upon activation:
- Next melee attack will deal x1.75 damage
- Next melee attack will deal x3.5 Plasmic Elemental damage.
PaP Upgrades (all of them increase overall stats):
1 - Allows the Plasmic Injector to deal x1.5 damage against Plasm-ed targets.
2 - Unlocks Lethal Injection.
3 - Reduces Lethal Injection's cooldown, allows it to inflict Plasm I for 3 seconds.
4 - Ditto, grants it an extra charge.
5 - Ditto, allows it to inflict Plasm II for 4 seconds instead of I for 3.

Plas-Matter Siphoner (secondary) - A 'vacuum' that sucks the plasmatic matter off nearby enemies,
and transforms it into energy that powers the Plasma Injector and the Plasminator.
Grants a bonus +10% melee resistance and +5% ranged resistance while held.
Deals a very small amount of damage in an area (like the mana succ thing from the twink kit), but
as it damages, it grants very small general bonuses, and increases stats for the melee and primary.
The rate at which the bonuses are granted is doubled if the enemy has more than 25% Plasmic Elemental damage,
but also drains said damage by 2% each time.
Upon reaching +50% charge, the Siphoner will begin to overheat, and either reaching 100% charge or
disabling it after this point causes it to go into a 18 second cooldown before it can be reused again.
These bonuses slowly decay overtime down to 0% after 3 seconds of not draining anything.
Maximum base bonuses:
- +25% Overall resistance
- +20% Melee damage
- +10% Primary damage
- +35% Plasmic Elemental damage
- +20% Attack speed
- 9HP Regen per second
PaP Upgrades (also increases resists while held and how many enemies the Siphoner can feed off by 1 each):
1 - Increases maximum melee+primary damage and attackspeed bonuses.
2 - Ditto, now also increases maximum Plasmic Elemental damage bonus.
3 - Ditto, now also increases maximum overall resistance and HP regen bonuses.
5 - Increases all maximum stats.
5 - Increases all maximum stats.

Koshi's Plasminator (primary) - Shoots "plasmic balls" in quick succession, like the clockwork assault rifle from Terraria.
These projectiles deal 25% of their damage as Plasmic Elemental damage.
Plasmic Burst (M2 Primary Ability), upon activation:
- Shoots a short-ranged laser that causes a bit of shake.
- This laser inflicts AoE damage in front, and deals 35% of its damage as Plasmic Elemental damage.
PaP Upgrades (all of them increase overall stats):
1 - Nothing special.
2 - Unlocks Plasmic Burst.
3 - Slightly increases Plasmic Burst's range and increases its Plasmic Elemental damage by an additional 5%.
4 - Ditto, also reduces its cooldown.
5 - Ditto.

6th, 7th and 8th paps increase ALL stats and almost all ability stats overall.
*/

#define SOUND_LETHAL_ABILITY "items/powerup_pickup_reflect.wav"
#define SOUND_SIPHONER_HALFCHARGE "misc/halloween/duck_pickup_pos_01.wav"
#define SOUND_CHEESEBALL_SQUASH "ui/hitsound_squasher.wav"
#define SOUND_ELEMENTALAPPLY    "ui/killsound_vortex.wav"
#define SOUND_CHEDDAR_ABILITY  "weapons/tf2_back_scatter.wav"

static int LaserIndex;
static int Cheese_PapLevel[MAXPLAYERS];
static float Cheese_Siphoner_CurrentDecayRate[MAXPLAYERS];
static float Cheese_Siphoner_Timeout[MAXPLAYERS];
static float Cheese_Siphoner_DecayDelay[MAXPLAYERS];
static bool Cheese_Siphoner_HalfCharge[MAXPLAYERS];

static int Cheese_Glow;
static int Cheese_BuildingHit[MAX_TARGETS_HIT];
static float Cheese_TargetsHit[MAXPLAYERS];
static float hudtimer[MAXPLAYERS];
static int iref_WeaponConnect[MAXPLAYERS+1][2];

static int Cheese_Siphoner_TargetMaximum[9] = {2, 2, 3, 3, 4, 4, 5, 6, 6}; // Maximum amount of enemies that the Siphoner can hit.
static float Cheese_Siphoner_Range[9] = {250.0, 262.5, 275.0, 287.5, 300.0, 300.0, 300.0, 300.0, 300.0}; // Range of the Siphoner
static float Cheese_Siphoner_MaxResistance[9] = {0.75, 0.75, 0.725, 0.7, 0.675, 0.65, 0.6, 0.5, 0.4}; // Maximum resistance boost from the Siphoner
static float Cheese_Siphoner_MaxMeleeDamage[9] = {1.2, 1.25, 1.3, 1.35, 1.4, 1.5, 1.6, 1.75, 2.0}; // Maximum melee damage boost from the Siphoner
static float Cheese_Siphoner_MaxPrimaryDamage[9] = {1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.5, 1.75}; // Maximum primary damage boost from the Siphoner
static float Cheese_Siphoner_MaxPlasmicDamage[9] = {1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 1.7, 1.85, 2.0}; // Maximum plasmic elemental damage boost from the Siphoner
static float Cheese_Siphoner_MaxAttackspeed[9] = {0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4}; // Maximum attackspeed boost from the Siphoner
static int Cheese_Siphoner_MaxRegen[9] = {9, 9, 9, 12, 15, 18, 21, 24, 30}; // Maximum HP regen boost from the Siphoner

static float Cheese_Siphoner_MaxCharge[9] = {2500.0, 3000.0, 4000.0, 6000.0, 9000.0, 15000.0, 20000.0, 25000.0, 32500.0}; // Maximum Siphoner charge. BASE CHARGE RATE WILL ALWAYS BE 75.0!
static float Cheese_Siphoner_MaxDecayRate[9] = {300.0, 400.0, 500.0, 600.0, 750.0, 900.0, 1150.0, 1300.0, 1500.0}; // Maximum Siphoner decay rate every 0.5s. Decay rate increases exponentially as it goes.
static float Cheese_Siphoner_BaseDecayRate = 20.0; // Formula is (baserate * (pap level * 0.5)), this only takes effect after pap 2

static int Cheese_Lethal_MaxCharges[9] = {1, 1, 1, 2, 3, 3, 4, 4, 5}; // How many charges Lethal Injection has
static float Cheese_Burst_ElementalDmg[9]  = {0.35, 0.35, 0.35, 0.4, 0.45, 0.5, 0.6, 0.75, 1.0}; // Elemental damage multiplier for Plasmic Burst
static float Cheese_Burst_Cooldown[9]  = {22.5, 22.5, 22.5, 22.5, 17.5, 15.0, 12.5, 10.0, 7.5}; // Plasmic Burst's cooldown

static Handle EffectTimer[MAXPLAYERS];
static bool Precached = false;
void Cheese_MapStart()
{
	PrecacheSound(SOUND_LETHAL_ABILITY, true);
	PrecacheSound(SOUND_SIPHONER_HALFCHARGE, true);
	PrecacheSound(SOUND_CHEESEBALL_SQUASH, true);
	PrecacheSound(SOUND_ELEMENTALAPPLY, true);
	PrecacheSound(SOUND_CHEDDAR_ABILITY, true);
	PrecacheSound(")weapons/tf2_backshot_shotty.wav");
	Zero(Cheese_PapLevel);
	Zero(Cheese_Siphoner_CurrentDecayRate);
	Zero(Cheese_Siphoner_Timeout);
	Zero(Cheese_Siphoner_DecayDelay);
	Zero(Cheese_Siphoner_HalfCharge);
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

void Cheese_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_PRIMARY)
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
		HealEntityGlobal(client, client, 12.0, 0.25, 0.0, HEAL_SELFHEAL);
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
	float MochaCD = 0.0;
	int WeaponEntity = EntRefToEntIndex(iref_WeaponConnect[client][0]);
	if(IsValidEntity(WeaponEntity))
	{
		//3 is R
		MochaCD = Ability_Check_Cooldown(client, 3, WeaponEntity);
		//2 is M2
		LethalCooldown = Ability_Check_Cooldown(client, 2, WeaponEntity);
	}
//	WeaponEntity = EntRefToEntIndex(iref_WeaponConnect[client][1]);
//	if(IsValidEntity(WeaponEntity))
//	{
//
//	}

	char CheeseHud[255];
	if(Cheese_PapLevel[client] > 1)
	{
		if(HasSpecificBuff(client, "Plasmatized Lethalitation"))
		{
			Cheese_BeamEffect(pos, 1.0, 100.0, 0.25, 8.0);
			Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: ACTIVE!", CheeseHud);
		}
		else
		{
			if(LethalCooldown <= 0.0)
				Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: Ready!", CheeseHud);
			else
				Format(CheeseHud, sizeof(CheeseHud), "%sLethal Injection: [%.1f]", CheeseHud, LethalCooldown);
		}			
	}
			
	if(Cheese_PapLevel[client] > 2)
	{
		if(HasSpecificBuff(client, "Plasmatized Inoculation"))
		{
			Cheese_BeamEffect(pos, 125.0, 1.0, 0.25, 8.0);
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmatic Inoculation: ACTIVE!!", CheeseHud);
		}
		else
		{
			if(MochaCD <= 0.0)
				Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmatic Inoculation: Ready!", CheeseHud);
			else
				Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmatic Inoculation: [%.1f]", CheeseHud, MochaCD);
		}
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

		if(HasSpecificBuff(attacker, "Plasm-Allocator"))
		{
			cheesedmg *= 1.5;
		}
		if(HasSpecificBuff(attacker, "Plasmatized Lethalitation"))
		{
			cheesedmg *= 2.0;
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
			if(Cheese_PapLevel[client] >= 4)
				Ability_Apply_Cooldown(client, slot, LastMann ? 12.0 : 18.0);
			else
				Ability_Apply_Cooldown(client, slot, LastMann ? 15.0 : 22.0);
			EmitSoundToClient(client, SOUND_CHEDDAR_ABILITY);
			Cheese_PlaySplat(client);

			Cheese_TargetsHit[client] = 0.0;

			float basedmg = (375.0 * Attributes_Get(weapon, 2, 1.0));
			basedmg *= Attributes_Get(weapon, 1, 1.0);
			Client_Shake(client, 0, 35.0, 90.0, 0.6);

			switch(Cheese_PapLevel[client])
			{
				case 3:
				{
					Cheese_Burst(client, basedmg, basedmg, 215.0, 12.0, weapon);
				}
				case 4:
				{
					Cheese_Burst(client, basedmg, basedmg, 235.0, 12.0, weapon);
				}
				case 5:
				{
					Cheese_Burst(client, basedmg*1.25, basedmg, 255.0, 12.0, weapon);
				}
				case 6, 7, 8:
				{
					Cheese_Burst(client, basedmg*1.35, basedmg*1.15, 270.0, 12.0, weapon);
				}
				default:
				{
					Cheese_Burst(client, basedmg, basedmg, 215.0, 12.0, weapon);
				}
			}
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
			Rogue_OnAbilityUse(client, weapon);
			float cd = 40.0;
			if(LastMann)
				cd = 25.0;

			Ability_Apply_Cooldown(client, slot, cd);
			EmitSoundToClient(client, SOUND_LETHAL_ABILITY);

			switch(Cheese_PapLevel[client])
			{
				case 2, 3:
				{
					ApplyTempAttrib(weapon, 6, 0.7, 7.0);
					ApplyTempAttrib(weapon, 206, 0.93, 7.0);
					ApplyTempAttrib(weapon, 205, 0.93, 7.0);
					ApplyStatusEffect(client, client, "Plasmatized Lethalitation", 7.0);
				}
				case 4, 5:
				{
					ApplyTempAttrib(weapon, 6, 0.6, 8.5);
					ApplyTempAttrib(weapon, 206, 0.87, 8.5);
					ApplyTempAttrib(weapon, 205, 0.87, 8.5);
					ApplyStatusEffect(client, client, "Plasmatized Lethalitation", 8.5);
				}
				case 6, 7, 8:
				{
					ApplyTempAttrib(weapon, 6, 0.5, 10.0);
					ApplyTempAttrib(weapon, 206, 0.82, 10.0);
					ApplyTempAttrib(weapon, 205, 0.82, 10.0);
					ApplyStatusEffect(client, client, "Plasmatized Lethalitation", 10.0);
				}
			}
			float position[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", position);
			position[2] += 25.0;
			Cheese_BeamEffect(position, 10.0, 200.0, 0.2, 7.5);
			position[2] -= 12.5;
			Cheese_BeamEffect(position, 1.0, 150.0, 0.1, 5.0);
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

public void Weapon_Kit_CheeseInject_R(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && Cheese_PapLevel[client] >= 3)
		{
			Rogue_OnAbilityUse(client, weapon);
			float cd = 70.0;
			if(LastMann)
				cd = 45.0;

			Ability_Apply_Cooldown(client, slot, cd);

			float dmgbuff = 1.95;
			float resbuff = 0.65;
			float atkspdbuff = 0.7;
			float buffdurations = 10.0;
			float MaxHealth = float(SDKCall_GetMaxHealth(client));

			switch(Cheese_PapLevel[client])
			{
				case 4:
				{
					dmgbuff = 2.15;
					resbuff = 0.55;
					atkspdbuff = 0.65;
					HealEntityGlobal(client, client, MaxHealth * 0.15, 0.6, buffdurations, HEAL_SELFHEAL);
				}
				case 5, 6:		
				{
					dmgbuff = 2.35;
					resbuff = 0.5;
					atkspdbuff = 0.55;
					buffdurations = 15.0;
					HealEntityGlobal(client, client, MaxHealth * 0.20, 0.75, buffdurations, HEAL_SELFHEAL);
				}
				case 7, 8:
				{
					dmgbuff = 2.5;
					resbuff = 0.4;
					atkspdbuff = 0.45;
					buffdurations = 20.0;
					HealEntityGlobal(client, client, MaxHealth * 0.25, 1.0, buffdurations, HEAL_SELFHEAL);
				}
				default:
				{
					HealEntityGlobal(client, client, MaxHealth * 0.15, 0.5, buffdurations, HEAL_SELFHEAL);
				}
			}

			ApplyStatusEffect(client, client, "Plasmatized Inoculation", buffdurations);
			
			float position[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", position);
			position[2] += 10.0;
			Cheese_BeamEffect(position, 135.0, 1.0, 0.3, 15.0);
			position[2] += 30.0;
			Cheese_BeamEffect(position, 135.0, 1.0, 0.3, 15.0);
			position[2] += 30.0;
			Cheese_BeamEffect(position, 135.0, 1.0, 0.3, 15.0);
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
					WorldSpaceCenter(Cheese_BuildingHit[building],playerPos);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = dmgclose + (dmgfar-dmgclose) * (distance/maxdist);
					if (damage < 0)
						damage *= -1.0;

					float duration = 5.0;
					if(Cheese_PapLevel[client] >= 3)
						duration += 1.75;
			
					if(Cheese_PapLevel[client] >= 5)
						duration += 1.25;

					if(b_thisNpcIsARaid[Cheese_BuildingHit[building]])
					{
						duration *= 0.5;
					}
					else if(b_thisNpcIsABoss[Cheese_BuildingHit[building]])
					{
						duration *= 0.75;
					}
						
					if(Cheese_PapLevel[client] >= 5)
						ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm II", duration);
					else
						ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm I", duration);

					if(IsValidEntity(weapon))
						Elemental_AddPlasmicDamage(Cheese_BuildingHit[building], client, RoundToNearest(damage * 0.25), weapon);
					
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
