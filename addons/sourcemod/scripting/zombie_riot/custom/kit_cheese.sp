#pragma semicolon 1
#pragma newdecls required

/*
This kit introduces the Plasmic Elemental debuff.
If filled, the following happens:
- an AoE healing effect is triggered, healing allies around the affected. healing is based on the user's pap level,
although it can also be affected by the heal rate attribute.
- inflicting the effect on the target multiple times will cause buildup to slow down overtime until the target dies.
- if triggered via melee, elemental cooldown is reduced from 8s to 2s, and buildup penalty is lowered.
- on raids, elemental cooldown via ranged appliance is reduced from 8s to 4s.
- on raids, buildup penalty is reduced by a flat 15% on both types.

Passive - The kit revives allies 30% faster.

Plasma Injector (melee) - Grants NO resistance, is meant to be more like a quick-use weapon now.
Health on kill is still very great, and its better to combo and time it with the Plasminator.
Inflicts a LOT of its damage as Plasmic Elemental damage due to its kinda-average melee damage.
Lethal Injection (M2 Melee Ability), upon activation:
- Next melee attack will deal x2.25 damage
- Next melee attack will deal x5 Plasmic Elemental damage. THIS IS SEPARATE FROM THE DAMAGE BONUS!
PaP Upgrades (all of them increase overall stats):
1 - Nothing special
2 - Unlocks Lethal Injection.
3 - Reduces Lethal Injection's cooldown.
4 - Ditto.
5 - Ditto.

Plasm-ubblinator (secondary) - A secondary unlocked after papping it once.
Doesn't fire normally, instead it only fires after charging its ability.
You can charge it dealing hits to enemies. Melee hits charge the ability x3 as fast.
Plasmatized Bubble (M1/M2 Ability), upon activation:
- Shoots a gravity-affected projectile that, upon landing, creates an AoE zone that grows,
enemies inside this AoE zone receive a high amount of Plasmic Elemental Damage, 
which scales based off the weapon's damage attribs.
- Allies inside this bubble are cured from elemental damage, for a percent based on the owner's pap level.
- This bubble checks for targets every 0.5s, but the tickrate also scales with attackspeed.
- The bubble lasts for a base duration of 5 seconds.
All PaP upgrades reduce the hits required to charge the Plasmatized Bubble by 10, increase
the Plasmic Elemental Damage it deals, and increase the bubble duration by 1.5s (up to 12.5s).
Pap 3 allows the Plasmatized Bubble to grant Plasmic Layering to allies inside it, Pap 5 boosts
the level of Plasmic Layering.

Koshi's Plasminator (primary) - Shoots "plasmic balls" in quick succession, like the clockwork assault rifle from Terraria.
These projectiles deal 50% of their damage as Plasmic Elemental damage.
Plasmic Burst (M2 Primary Ability), upon activation:
- Shoots a short-ranged laser that causes a bit of shake.
- This laser inflicts AoE damage in front, and deals 75% of its damage as additional Plasmic Elemental damage.
PaP Upgrades (all of them increase overall stats):
1 - Nothing special.
2 - Unlocks Plasmic Burst.
3 - Slightly increases its range and increases its Plasmic Elemental damage by an additional 15%.
4 - Ditto, also reduces its cooldown by 5 seconds.
5 - Ditto.

6th, 7th and 8th paps increase ALL stats and almost all ability stats overall.
*/

#define SOUND_LETHAL_ABILITY 	"items/powerup_pickup_reflect.wav"
#define SOUND_CHEESEBALL_SQUASH "ui/hitsound_squasher.wav"
#define SOUND_ELEMENTALAPPLY   "ui/killsound_vortex.wav"
#define SOUND_CHEDDAR_ABILITY  "weapons/tf2_back_scatter.wav"
#define SOUND_CAPSULE_EXPLODE  "weapons/sentry_finish.wav"
#define SOUND_LETHAL_ACTIVATE	"weapons/buffed_on.wav"
#define PARTICLE_BUBBLE	       "halloween_ghost_smoke"

static int LaserIndex;
static int Cheese_PapLevel[MAXPLAYERS];
static bool Cheese_HasModernizer1[MAXPLAYERS];

static int Cheese_Glow;
static int Cheese_Bubble_Hits[MAXPLAYERS];
static int Cheese_BuildingHit[MAX_TARGETS_HIT];
static float Cheese_TargetsHit[MAXPLAYERS];
static float hudtimer[MAXPLAYERS];
static int iref_WeaponConnect[MAXPLAYERS+1][3];

static float Cheese_Buildup_Penalty[MAXENTITIES] = { 1.0, ... };

static int Cheese_Bubble_MaxHits[9]  = {150, 150, 140, 130, 120, 110, 100, 90, 80}; // Plasmatized Bubble's max charge
static float Cheese_Bubble_ElementalDmg = 100.0; // Plasmatized Bubble's base plasmic elemental damage, multiplied by the weapon's damage attrib
static float Cheese_Lethal_Cooldown[9]  = {25.0, 25.0, 25.0, 22.5, 20.0, 17.5, 15.0, 15.0, 10.0}; // Lethal Injection's cooldown
static float Cheese_Lethal_DmgBoost[9] = {2.25, 2.25, 2.25, 2.25, 2.3, 2.35, 2.4, 2.45, 2.5}; // Lethal Injection's damage bonus
static float Cheese_Lethal_ElementalBoost[9] = {5.0, 5.0, 5.0, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5}; // Lethal Injection's elemental damage bonus
static float Cheese_Burst_ElementalDmg[9]  = {0.75, 0.75, 0.75, 0.9, 1.05, 1.2, 1.35, 1.5, 1.65}; // Additional Elemental damage multiplier for Plasmic Burst
static float Cheese_Burst_Range[9]  = {235.0, 235.0, 235.0, 250.0, 265.0, 280.0, 295.0, 310.0, 325.0}; // Range for Plasmic Burst
static float Cheese_Burst_Cooldown[9]  = {27.5, 27.5, 27.5, 27.5, 22.5, 17.5, 15.0, 12.5, 10.0}; // Plasmic Burst's cooldown

static Handle EffectTimer[MAXPLAYERS];
static bool Precached = false;
void Cheese_MapStart()
{
	PrecacheSound(SOUND_LETHAL_ABILITY, true);
	PrecacheSound(SOUND_CHEESEBALL_SQUASH, true);
	PrecacheSound(SOUND_ELEMENTALAPPLY, true);
	PrecacheSound(SOUND_CHEDDAR_ABILITY, true);
	PrecacheSound(SOUND_CAPSULE_EXPLODE, true);
	PrecacheSound(SOUND_LETHAL_ACTIVATE, true);
	PrecacheSound(")weapons/tf2_backshot_shotty.wav");
	Zero(Cheese_HasModernizer1);
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

void Cheese_BeamEffect(float position[3], float startrad = 1.0, float endrad = 125.0, float lifetime = 0.25, float width = 6.5, bool elemental = false, int client = -1, float amplitude = 0.0)
{
	if(elemental)
	{
		TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, amplitude, { 235, 75, 210, 50 }, 1, 0);
		TE_SendToClient(client);
	}
	else
	{
		TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, amplitude, { 235, 75, 210, 175 }, 1, 0);
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
	Cheese_Buildup_Penalty[i] = 1.0;
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
		EffectTimer[client] = CreateDataTimer(0.5, Cheese_EffectTimer, pack, TIMER_REPEAT);
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
		Cheese_OnNPCDeath(client);
		EffectTimer[client] = null;
		return Plugin_Stop;
	}	

	Cheese_PapLevel[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	if(LastMann)
	{
	 	if(!HasSpecificBuff(client, "Plasmatic Rampage"))
			ApplyStatusEffect(client, client, "Plasmatic Rampage", 999.0);

		HealEntityGlobal(client, client, (float(ReturnEntityMaxHealth(client)) * 0.01), 0.25, 0.0, HEAL_SELFHEAL);
		Elemental_AddPlasmicDamage(client, client, 25, EntRefToEntIndex(iref_WeaponConnect[client][0]), true);
	}
	else
	{
		if(HasSpecificBuff(client, "Plasmatic Rampage"))
		{
			RemoveSpecificBuff(client, "Plasmatic Rampage");
			Cheese_OnNPCDeath(client);	
		}

		if(Cheese_HasModernizer1[client])
		{
			//HealEntityGlobal(client, client, (float(ReturnEntityMaxHealth(client)) * 0.01), 0.25, 0.0, HEAL_SELFHEAL);
			//Elemental_AddPlasmicDamage(client, client, 16, EntRefToEntIndex(iref_WeaponConnect[client][0]), true); // less than lastman so its not that punishing
		}
		else
		{
			Cheese_OnNPCDeath(client);
		}
	}

	/*
	if(Store_HasNamedItem(client, "Kit Modernizer I"))
	{
		if(!Cheese_HasModernizer1[client])
		{
			CPrintToChat(client, "{gold}Koshi{white}: What's that, hmm? You really want to feel this weapon's potential?");
			CPrintToChat(client, "{gold}Koshi{white}: If that's what you want, go ahead. {red}Just don't fill the place with plasma, will you?");
			CPrintToChat(client, "{darkviolet}Suddenly, plasma starts engulfing your body...!");
			Cheese_HasModernizer1[client] = true;
		}
	}
	else
	{
		if(Cheese_HasModernizer1[client])
		{
			CPrintToChat(client, "{gold}Koshi{white}: Oh, getting rid of the fun so soon? Awww...");
			CPrintToChat(client, "{violet}Plasma is no longer engulfing your body.");
			Cheese_HasModernizer1[client] = false;
		}
	}
	*/

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
	if(HasSpecificBuff(client, "Plasmatic Rampage"))
	{
		Cheese_BeamEffect(pos, 200.0, 1.0, 0.075, 10.0, _, _, 2.5);
	}
	else
	{
		Cheese_BeamEffect(pos, 1.0, 75.0, 0.075, 6.0, true, client);
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
	if(Cheese_PapLevel[client] > 0)
	{
		if(Cheese_Bubble_Hits[client] >= Cheese_Bubble_MaxHits[Cheese_PapLevel[client]])
			Format(CheeseHud, sizeof(CheeseHud), "%sPlasmatized Bubble: Ready!", CheeseHud);
		else
			Format(CheeseHud, sizeof(CheeseHud), "%sPlasmatized Bubble: [%d | %d]", CheeseHud, Cheese_Bubble_Hits[client], Cheese_Bubble_MaxHits[Cheese_PapLevel[client]]);
	}

	if(Cheese_PapLevel[client] > 1)
	{
		if(HasSpecificBuff(client, "Plasmatized Lethalitation"))
		{
			Format(CheeseHud, sizeof(CheeseHud), "%s\nLethal Injection: ACTIVE!", CheeseHud);
			Cheese_BeamEffect(pos, 1.0, 100.0, 0.075, 7.5, true, client);
		}
		else
		{
			if(LethalCooldown <= 0.0)
				Format(CheeseHud, sizeof(CheeseHud), "%s\nLethal Injection: Ready!", CheeseHud);
			else
				Format(CheeseHud, sizeof(CheeseHud), "%s\nLethal Injection: [%.1f]", CheeseHud, LethalCooldown);
		}		

		if(BurstCooldown <= 0.0)
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmic Burst: Ready!", CheeseHud);
		else
			Format(CheeseHud, sizeof(CheeseHud), "%s\nPlasmic Burst: [%.1f]", CheeseHud, BurstCooldown);
	}

	hudtimer[client] = GameTime + 0.4;
	PrintHintText(client, "%s", CheeseHud);
}

public float Cheese_OnTakeDamage_Melee(int attacker, int victim, float &damage, int damagetype, int weapon)
{
	if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return damage;

	if((damagetype & DMG_CLUB))
	{   
		if(Cheese_PapLevel[attacker] > 0)
			Cheese_Bubble_Hits[attacker] += 4;

		float cheesedmg = damage;

		if(HasSpecificBuff(attacker, "Plasmatized Lethalitation"))
		{
			cheesedmg *= Cheese_Lethal_ElementalBoost[Cheese_PapLevel[attacker]];
			damage *= Cheese_Lethal_DmgBoost[Cheese_PapLevel[attacker]];

			if(Cheese_HasModernizer1[attacker])
			{
				damage *= 1.25;
				cheesedmg *= 1.25;
			}

			float position[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
			position[2] += 25.0;
			Cheese_BeamEffect(position, 1.0, 200.0, 0.2, 5.0);
			position[2] -= 12.5;
			Cheese_BeamEffect(position, 1.0, 200.0, 0.2, 5.0);

			Rogue_OnAbilityUse(attacker, weapon);
			RemoveSpecificBuff(attacker, "Plasmatized Lethalitation");
			float thecooldown = Cheese_Lethal_Cooldown[Cheese_PapLevel[attacker]];
			if(HasSpecificBuff(attacker, "Plasmatic Rampage"))
			{
				thecooldown *= 0.5;
			}
			else
			{
				if(Cheese_HasModernizer1[attacker])
				{
					thecooldown *= 0.75;
				}
			}
				
			Ability_Apply_Cooldown(attacker, 2, thecooldown);
			EmitSoundToClient(attacker, SOUND_LETHAL_ABILITY);
		}
		Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(cheesedmg * 1.25), weapon);
	}

	return damage;
}

void Cheese_OnTakeDamage_Primary(int attacker, int victim, float damage, int weapon)
{
	Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(damage * 0.5), weapon);
	if(Cheese_PapLevel[attacker] > 0)
		Cheese_Bubble_Hits[attacker]++;
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
			{
				Cooldown *= 0.5;
			}
			else
			{
				if(Cheese_HasModernizer1[client])
				{
					Cooldown *= 0.75;
				}
			}

			Ability_Apply_Cooldown(client, slot, Cooldown);
			EmitSoundToClient(client, SOUND_CHEDDAR_ABILITY);
			Cheese_PlaySplat(client);

			Cheese_TargetsHit[client] = 0.0;

			float basedmg = (435.0 * Attributes_Get(weapon, 2, 1.0));
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

public void Weapon_Kit_CheeseBubble(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Cheese_Bubble_Hits[client] >= Cheese_Bubble_MaxHits[Cheese_PapLevel[client]])
		{
			Cheese_Bubble_Hits[client] = 0;
	
			float speed = 1000.0;
			speed *= Attributes_Get(weapon, 103, 1.0);
			
			float ang[3];
			GetClientEyeAngles(client, ang);
			ang[0] -= 10.0;
			
			char particle[32];
			Format(particle, sizeof(particle), "%s", "eyeboss_projectile");
			int entity = Wand_Projectile_Spawn(client, speed, 20.0, 0.0, 0, weapon, particle, ang, false);
			if(entity > MaxClients)
			{
				SetEntityGravity(entity, 1.5);
				SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);

				int model = ApplyCustomModelToWandProjectile(entity, "models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl", 1.35, "");
				int team = 0;
				if(GetTeam(client) != 2)
					team = 1;
				SetEntProp(model, Prop_Send, "m_nSkin", team); // 0 = red, 1 = blue (for m_nSkin)

				model = i_WeaponModelIndexOverride[weapon];
				SetEntProp(entity, Prop_Send, "m_nBody", i_WeaponBodygroup[weapon]);
				for(int i; i < 4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", model, _, i);
				}

				WandProjectile_ApplyFunctionToEntity(entity,Cheese_BubbleTouch);
		
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Plasma Kit Insufficient Charge");
			return;
		}
	}
}

public void Cheese_BubbleTouch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);

	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetTeam(target) == GetTeam(owner))
			return;
	}

	WandProjectile_ApplyFunctionToEntity(entity,INVALID_FUNCTION);
	//stand still.

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	ParticleEffectAt(pos1, PARTICLE_BUBBLE, 2.0);
	EmitSoundToAll(SOUND_CAPSULE_EXPLODE, entity, _, _, _, _, _, _, pos1);

	// no stocks for spawning a model on a position without parenting it to anything?
	// fine, i'll spawn another projectile to manipulate to my desires
	float duration = Attributes_Get(weapon, 868, 1.0) + 1.0; // +1 extra second for arm time
	int bubble1 = Wand_Projectile_Spawn(owner, 0.0, duration, 0.0, 0, weapon, "", _, _, pos1);
	WandProjectile_ApplyFunctionToEntity(bubble1, Cheese_Bubble_OverrideTouch);
	CreateTimer(1.0, CheeseBubble_FirstCheck, EntIndexToEntRef(bubble1), TIMER_FLAG_NO_MAPCHANGE);
	b_NoKnockbackFromSources[bubble1] = true;
	SetEntityMoveType(bubble1, MOVETYPE_NONE);

	// man...
	pos1[2] += 10.0;
	Cheese_BeamEffect(pos1, _, 500.0, 1.0, 7.5);
	
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	RemoveEntity(entity);
}

static Action CheeseBubble_FirstCheck(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(!IsValidEntity(weapon))
	{
		return Plugin_Stop;
	}

	float tickrate = 0.5 * Attributes_Get(weapon, 6, 1.0);

	float scale = 1.0;
	if(Cheese_PapLevel[owner] > 1)
		scale = float(Cheese_PapLevel[owner]) * 0.5;

	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	Explode_Logic_Custom(0.0, owner, owner, weapon, position, 225.0, _, _, _, _, false, _, Cheese_Bubble_InflictLogic);
	PlasmicBubble_HealElementalAllies(owner, (0.06 * scale), 1.0, position, 225.0);
	position[2] += 10.0;
//	Cheese_BeamEffect(position, _, 450.0, tickrate, 7.5, true, owner);
	Cheese_BeamEffect(position, 450.0, 445.0, tickrate, 7.5, _, _, 4.0);

	// MAN
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 400.0, 395.0, tickrate, 7.5, true, owner, 3.0);
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 300.0, 295.0, tickrate, 7.5, true, owner, 2.0);
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 150.0, 145.0, tickrate, 7.5, true, owner, 1.0);
	position[2] -= 50.0;
//	Cheese_BeamEffect(position, 50.0, 45.0, tickrate, 7.5, true, owner, 0.0);
	position[2] += 250.0;
	Cheese_BeamEffect(position, 400.0, 395.0, tickrate, 7.5, true, owner, 3.0);
	position[2] += 50.0;
	Cheese_BeamEffect(position, 300.0, 295.0, tickrate, 7.5, true, owner, 2.0);
	position[2] += 50.0;
	Cheese_BeamEffect(position, 150.0, 145.0, tickrate, 7.5, true, owner, 1.0);
//	position[2] += 50.0;
//	Cheese_BeamEffect(position, 50.0, 45.0, tickrate, 7.5, true, owner, 0.0);
	float tickrateSend = tickrate;
	tickrateSend += 0.1;
	DataPack pack;
	CreateDataTimer(tickrate, CheeseBubble_CheckLoop, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(tickrateSend);

	return Plugin_Continue;
}

static Action CheeseBubble_CheckLoop(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(!IsValidEntity(weapon))
	{
		return Plugin_Stop;
	}
	if(!IsValidEntity(owner))
	{
		return Plugin_Stop;
	}

	float tickrate = pack.ReadFloat();

	float scale = 1.0;
	if(Cheese_PapLevel[owner] > 1)
		scale = float(Cheese_PapLevel[owner]) * 0.5;

	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	Explode_Logic_Custom(0.0, owner, owner, weapon, position, 225.0, _, _, _, 16, false, _, Cheese_Bubble_InflictLogic);
	PlasmicBubble_HealElementalAllies(owner, (0.06 * scale), 1.0, position, 225.0);
	position[2] += 10.0;
//	Cheese_BeamEffect(position, _, 450.0, tickrate, 7.5, true, owner);
	Cheese_BeamEffect(position, 450.0, 445.0, tickrate, 7.5, _, _, 4.0);

	// MAN
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 400.0, 395.0, tickrate, 7.5, true, owner, 3.0);
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 300.0, 295.0, tickrate, 7.5, true, owner, 2.0);
	position[2] -= 50.0;
	Cheese_BeamEffect(position, 150.0, 145.0, tickrate, 7.5, true, owner, 1.0);
	position[2] -= 50.0;
//	Cheese_BeamEffect(position, 50.0, 45.0, tickrate, 7.5, true, owner, 0.0);
	position[2] += 250.0;
	Cheese_BeamEffect(position, 400.0, 395.0, tickrate, 7.5, true, owner, 3.0);
	position[2] += 50.0;
	Cheese_BeamEffect(position, 300.0, 295.0, tickrate, 7.5, true, owner, 2.0);
	position[2] += 50.0;
	Cheese_BeamEffect(position, 150.0, 145.0, tickrate, 7.5, true, owner, 1.0);
//	position[2] += 50.0;
//	Cheese_BeamEffect(position, 50.0, 45.0, tickrate, 7.5, true, owner, 0.0);

	return Plugin_Continue;
}

public void Cheese_Bubble_InflictLogic(int entity, int enemy, float damage, int weapon)
{
	if(!IsValidEntity(enemy) || !IsValidEntity(entity))
		return;

	if(enemy)
	{
		if(enemy <= MaxClients)
			return;
		
		if(GetTeam(enemy) == GetTeam(entity))
			return;
	}

	float cheesedmg = Cheese_Bubble_ElementalDmg;
	cheesedmg *= Attributes_Get(weapon, 2, 1.0);
	cheesedmg *= Attributes_Get(weapon, 1, 1.0);

	if(HasSpecificBuff(entity, "Plasmatic Rampage"))
		cheesedmg *= 2.0;

	Elemental_AddPlasmicDamage(enemy, entity, RoundToNearest(cheesedmg), weapon);
}

public void Cheese_Bubble_OverrideTouch(int entity, int target)
{
	// overriding the starttouch so the projectile that sustains the bubble doesn't get deleted by anything, yeah
}

// im KILLING myself i already tried doing logic with Explode_Logic_Custom and i spent like 5 hours failing over and over i HATE IT
public void PlasmicBubble_HealElementalAllies(int healer, float percent, float maxmulti, float position[3], float distance)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			float clientpos[3];
			GetClientAbsOrigin(client, clientpos);
			if(GetVectorDistance(clientpos, position, false) <= distance)
			{
				if(GetTeam(client) == GetTeam(healer))
				{
					if(Armor_Charge[client] < 0)
					{
						if(f_TimeUntillNormalHeal[client] > GetGameTime())
							percent *= 0.5;

						/*
						for(int i; i < 8; i++) // Remove all elementals except Plasma 
						{
							if(i != 8)
								Elemental_RemoveDamage(client, i, RoundToNearest(float(MaxArmorCalculation(Armor_Level[client], client, 1.0)) * percent));
						}
						*/

						// using this because the above is for npcs, not for clients (breb)
						GiveArmorViaPercentage(client, percent, 1.0, _, true, healer);
					}

					if(Cheese_PapLevel[healer] > 2 && Cheese_PapLevel[healer] <= 4)
					{
						ApplyStatusEffect(healer, client, "Plasmic Layering I", 1.0);
					}
					else if(Cheese_PapLevel[healer] >= 5)
					{
						ApplyStatusEffect(healer, client, "Plasmic Layering II", 1.0);
					}
				}
			}
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(npc != INVALID_ENT_REFERENCE && IsEntityAlive(npc))
		{
			float npcpos[3];
			GetEntPropVector(npc, Prop_Data, "m_vecAbsOrigin", npcpos);
			if(GetVectorDistance(npcpos, position, false) <= distance)
			{
				if(GetTeam(npc) == GetTeam(healer))
				{
					for(int e; e < 9; e++)
					{
						Elemental_RemoveDamage(npc, e, RoundToNearest(float(Elemental_TriggerDamage(npc, e)) * percent));
					}

					if(Cheese_PapLevel[healer] > 2 && Cheese_PapLevel[healer] <= 4)
					{
						ApplyStatusEffect(healer, npc, "Plasmic Layering I", 1.0);
					}
					else if(Cheese_PapLevel[healer] >= 5)
					{
						ApplyStatusEffect(healer, npc, "Plasmic Layering II", 1.0);
					}
				}
			}
		}
	}
}

public void PlasmicElemental_HealNearby(int healer, float amount, float position[3], float distance, float healtime, int type, int correct_team)
{
	bool multhp = false;
	if(amount < 0) // If amount is negative, its treated as a maxhp multiplier
	{
		amount += (amount * 2.0);
		multhp = true;
	}

	/*
		//Due how exponential crazy HP values get, we should put a limit on this!
		//i.e. see grigori's blessing, it only scales upto 3k HP.
		in this case you can spam weaker enemies for INSANE heals!
		The same should go for a minimum, however, if an enemy has stupid low HP the heals should still MEAN something.
	*/
	if(amount > 500.0)
	{
		amount = 500.0;
	}
	if(amount < 10.0)
	{
		amount = 10.0;
	}

	float trueamount;
	if(type == 0 || type == 2)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(npc != INVALID_ENT_REFERENCE && IsEntityAlive(npc))
			{
				float npcpos[3];
				GetEntPropVector(npc, Prop_Data, "m_vecAbsOrigin", npcpos);
				if(GetVectorDistance(npcpos, position, false) <= distance)
				{
					if(multhp)
						trueamount = float(ReturnEntityMaxHealth(npc)) * amount;
					else
						trueamount = amount;
					if(healer != -1)
					{
						if(GetTeam(npc) == GetTeam(healer))
							HealEntityGlobal(healer, npc, trueamount, 1.0, healtime, HEAL_SELFHEAL);
					}
					else
					{
						if(GetTeam(npc) == correct_team)
							HealEntityGlobal(npc, npc, trueamount, 1.0, healtime, HEAL_SELFHEAL);
					}
				}
			}
		}
	}

	if(type == 1 || type == 2)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && IsPlayerAlive(client))
			{
				float clientpos[3];
				GetClientAbsOrigin(client, clientpos);
				if(GetVectorDistance(clientpos, position, false) <= distance)
				{
					if(multhp)
						trueamount = float(ReturnEntityMaxHealth(client)) * amount;
					else
						trueamount = amount;
					if(healer != -1)
					{
						if(GetTeam(client) == GetTeam(healer))
							HealEntityGlobal(healer, client, trueamount, 1.0, healtime, HEAL_SELFHEAL);
					}
					else
					{
						if(GetTeam(client) == correct_team)
							HealEntityGlobal(client, client, trueamount, 1.0, healtime, HEAL_SELFHEAL);
					}
				}
			}
		}
	}
}

public void Weapon_Kit_CheeseInject_M2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && Cheese_PapLevel[client] >= 2)
		{
			if(!HasSpecificBuff(client, "Plasmatized Lethalitation"))
				EmitSoundToClient(client, SOUND_LETHAL_ACTIVATE);

			ApplyStatusEffect(client, client, "Plasmatized Lethalitation", 999.0);
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

	if(Cheese_HasModernizer1[client])
	{
		maxdist *= 1.25;
		dmgclose *= 1.25;
		dmgfar *= 1.25;
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



