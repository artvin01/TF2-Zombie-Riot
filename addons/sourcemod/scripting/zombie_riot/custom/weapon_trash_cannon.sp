#pragma semicolon 1
#pragma newdecls required

bool allowMultipleMondos = true;		//Set to false to prevent multiple Mondo Massacres from being rolled in the same wave.
int i_LastMondoWave = -1;

//Stats based on pap level. Uses arrays for simpler code.
//Example: Weapon_Damage[3] = { 100.0, 250.0, 500.0 }; Default damage is 100, pap1 is 250, pap2 is 500.

//FLIMSY ROCKET: The default roll. If all other rolls fail, this is what gets launched. A rocket that flops out of the barrel and explodes on impact.
int i_FlimsyMaxTargets[3] = { 4, 5, 6 };				//Max targets hit by the blast.

float f_FlimsyDMG[3] = { 840.0, 2400.0, 3250.0 };		//Flimsy Rocket base damage.
float f_FlimsyRadius[3] = { 200.0, 200.0, 200.0 };		//Flimsy Rocket explosion radius.
float f_FlimsyVelocity[3] = { 1200.0, 1200.0, 1200.0 };	//Flimsy Rocket projectile velocity.

//SHOCK STOCK: An electric orb, affected by gravity. Explodes into Passanger's Device-esque chain lightning on impact.
int i_ShockMaxHits[3] = { 6, 7, 8 };					//Max number of zombies hit by the shock.

float f_ShockChance[3] = { 0.1, 0.2, 0.25 };			//Chance for Shock Stock to be fired.
float f_ShockVelocity[3] = { 600.0, 800.0, 1200.0 };	//Shock Stock projectile velocity.
float f_ShockDMG[3] = { 1200.0, 2600.0, 3500.0 };		//Base damage dealt.
float f_ShockRadius[3] = { 100.0, 150.0, 200.0 };		//Initial blast radius.
float f_ShockChainRadius[3] = { 400.0, 600.0, 800.0 };	//Chain lightning radius.
float f_ShockDMGReductionPerHit[3] = { 0.65, 0.75, 0.85 };	//Amount to multiply damage dealt for each zombie shocked.
float f_ShockPassangerTime[3] = { 0.2, 0.25, 0.3 };			//Duration to apply the Passanger's Device debuff to zombies hit by Shock Stock chain lightning.

bool b_ShockEnabled[3] = { false, true, true };			//Is Shock Stock enabled on this pap level?

//MORTAR MARKER: A beacon which marks the spot it lands on for a special mortar strike, which scales with ranged upgrades.
//UNUSED - decided it was just another source of AoE damage so there was no real reason to bother with it.
float f_MortarChance[3] = { 0.04, 0.06, 0.08 };
bool b_MortarEnabled[3] = { false, false, false };

//BUNDLE OF ARROWS: A giant shotgun blast of Huntsman arrows.
int i_ArrowsMinArrows[3] = { 3, 5, 6 };		//Minimum number of arrows fired.
int i_ArrowsMaxArrows[3] = { 4, 6, 7 };		//Maximum number of arrows fired.

float f_ArrowsChance[3] = { 0.08, 0.14, 0.18 };			//Chance for Bundle of Arrows to be fired.
float f_ArrowsDMG[3] = { 1200.0, 1600.0, 2000.0 };			//Base arrow damage.
float f_ArrowsVelocity[3] = { 1200.0, 1600.0, 2000.0 }; //Arrow velocity.
float f_ArrowsSpread[3] = { 10.0, 8.0, 6.0 };			//Arrow spread penalty.
bool b_ArrowsEnabled[3] = { true, true, true };			//Is Bundle of Arrows enabled on this pap level?

//PYRE: A fireball which is affected by gravity.
float f_PyreChance[3] = { 0.12, 0.16, 0.1 };			//Chance for Pyre to be fired.
float f_PyreDMG[3] = { 2000.0, 3500.0, 5500.0 };		//Damage dealt by fireballs.
float f_PyreVel[3] = { 600.0, 800.0, 1200.0 };			//Fireball velocity.
float f_PyreGravity[3] = { 1.0, 1.0, 1.0 };				//Fireball gravity multiplier.

bool b_PyreEnabled[3] = { true, true, true };			//Is Pyre enabled on this pap level?

//SKELETON: Fires a shotgun blast of skeleton gibs which deal huge damage, but have a small radius and can only hit one zombie each.
float f_SkeletonChance[3] = { 0.00, 0.15, 0.22 };		//Chance for Skeleton to be fired.
float f_SkeletonVel[3] = { 800.0, 1000.0, 1200.0 };		//Skeleton projectile velocity.
float f_SkeletonDMG[3] = { 1500.0, 2000.0, 2400.0 };	//Skeleton damage.
float f_SkeletonRadius[3] = { 90.0, 95.0, 100.0 };		//Skeleton radius.
float f_SkeletonSpread[3] = { 8.0, 8.0, 8.0 };			//Skeleton projectile deviation.

bool b_SkeletonEnabled[3] = { false, true, true };		//Is Skeleton enabled on this pap tier?

//NICE ICE: Fires a big block of ice which deals enormous damage and explodes, with a high chance of freezing all zombies hit by it.
int i_IceMaxTargets[3] = { 3, 4, 5 };

float f_IceChance[3] = { 0.00, 0.025, 0.03 };
float f_IceDMG[3] = { 400.0, 600.0, 800.0 };
float f_IceRadius[3] = { 300.0, 350.0, 400.0 };
float f_IceVelocity[3] = { 600.0, 800.0, 1000.0 };

bool b_IceEnabled[3] = { false, true, true };

//TRASH: Fires a garbage bag which explodes on impact, releasing a cluster of smaller projectiles.
int i_TrashMaxTargets[3] = { 4, 5, 6 };				//Max targets hit by the blast.
int i_TrashMiniMaxTargets[3] = { 2, 3, 4 };				//Max targets hit by the blast of extra projectiles.
int i_TrashMinExtras[3] = { 3, 4, 5 };					//Minimum number of extra projectiles created when the trash bag explodes.
int i_TrashMaxExtras[3] = { 4, 5, 6 };				//Maximum number of extra projectiles created when the trash bag explodes.

float f_TrashChance[3] = { 0.08, 0.12, 0.16 };			//Chance for Trash to be fired.
float f_TrashVelocity[3] = { 600.0, 1000.0, 1400.00 };	//Projectile velocity for the trash bag.
float f_TrashMiniVelocity[3] = { 400.0, 450.0, 500.00 };	//Projectile velocity for the extra projectiles created when the trash bag explodes.
float f_TrashDMG[3] = { 1600.0, 3000.0, 4000.0 };			//Base damage for the trash bag.
float f_TrashMiniDMG[3] = { 400.0, 750.0, 1000.0 };			//Base damage for the extra projectiles created when the trash bag explodes.
float f_TrashRadius[3] = { 400.0, 250.0, 350.0 };			//Blast radius for the trash bag.
float f_TrashMiniRadius[3] = { 200.0, 150.0, 175.0 };		//Blast radius for the extra projectiles created when the trash bag explodes.

bool b_TrashEnabled[3] = { true, true, true };			//Is Trash enabled on this pap tier?

//MICRO-MISSILES: Fires a burst of X micro-missiles which aggressively home in on the nearest enemy after a short delay and explode.
int i_MissilesCount[3] = { 2, 3, 3 };						//The number of micro-missiles fired.
int i_MissilesMaxTargets[3] = { 4, 5, 6 };					//The max number of zombies hit by the blast.
int i_MissilesNumWaves[3] = { 2, 2, 2 };					//Number of sets of micro-missiles to be fired.

float f_MissilesChance[3] = { 0.00, 0.00, 0.07 };			//The chance for Micro-Missiles to be fired.
float f_MissilesDMG[3] = { 800.0, 1600.0, 2400.0 };			//Base missile damage.
float f_MissilesVelocity[3] = { 1600.0, 1800.0, 2000.0 };	//Base missile velocity.
float f_MissilesRadius[3] = { 200.0, 150.0, 200.0 };		//Base blast radius.
float f_MissilesSpread[3] = { 6.0, 6.0, 6.0 };				//Micro-Missile initial projectile spread.
float f_MissilesHomingStartTime[3] = { 0.2, 0.15, 0.1 };	//Delay after firing before micro-missiles begin to home.
float f_MissilesWaveDelay[3] = { 0.1, 0.2, 0.1 };			//Delay between sets.

bool b_MissilesEnabled[3] = { false, false, true };			//Are Micro-Missiles enabled on this PaP tier?

//MONDO MASSACRE: The strongest possible roll. Fires an EXTREMELY powerful, VERY big bomb which deals a base damage of 100k within an enormous blast radius.
int i_MondoMaxTargets[3] = { 999, 999, 999 };

float f_MondoChance[3] = { 0.00, 0.00, 0.0001 };
float f_MondoVelocity[3] = { 2000.0, 3000.0, 4000.0 };
float f_MondoDMG[3] = { 300000.0, 300000.0, 300000.0 };
float f_MondoRadius[3] = { 2000.0, 3000.0, 4000.0 };

bool b_MondoEnabled[3] = { false, false, true };

static int i_TrashNumEffects = 8;

static int i_TrashWeapon[2049] = { -1, ... };
static int i_TrashTier[2049] = { 0, ... };

static int i_NextShot[MAXPLAYERS + 1] = { 0, ... };
static float f_TrashNextHUD[MAXPLAYERS + 1] = { 0.0, ... };
Handle Timer_Trash[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

#define MODEL_ROCKET				"models/weapons/w_models/w_rocket.mdl"
#define MODEL_DRG					"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_ICE					"models/props_moonbase/moon_cube_crystal00.mdl"
#define MODEL_TRASH					"models/props_soho/trashbag001.mdl"
#define MODEL_MONDO					"models/weapons/w_models/w_cannonball.mdl"

#define SOUND_FLIMSY_BLAST			"weapons/explode1.wav"
#define SOUND_SHOCK					"misc/halloween/spell_lightning_ball_impact.wav"
#define SOUND_SHOCK_FIRE			"misc/halloween/spell_lightning_ball_cast.wav"
#define SOUND_ARROWS_FIRE			"weapons/bow_shoot.wav"
#define SOUND_PYRE_FIRE				"misc/halloween/spell_fireball_cast.wav"
#define SOUND_SKELETON_FIRE			"misc/halloween/spell_blast_jump.wav"
#define SOUND_SKELETON_BREAK		"misc/halloween/skeleton_break.wav"
#define SOUND_ICE_FIRE				"player/sleigh_bells/tf_xmas_sleigh_bells_01.wav"
#define SOUND_ICE_BREAK				"weapons/cow_mangler_explosion_charge_05.wav"
#define SOUND_TRASH_FIRE			"weapons/loose_cannon_shoot.wav"
#define SOUND_TRASH_BREAK			"physics/metal/metal_box_break1.wav"
#define SOUND_TRASH_MINI_BREAK		"physics/flesh/flesh_squishy_impact_hard3.wav"
#define SOUND_MISSILES_FIRE			"weapons/airstrike_fire_01.wav"
#define SOUND_MISSILES_BEGIN_HOMING	"weapons/sentry_spot_client.wav"
#define SOUND_MONDO_FIRE			"mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
#define SOUND_MONDO_BREAK_1			"mvm/mvm_tank_explode.wav"
#define SOUND_MONDO_BREAK_2			"misc/doomsday_missile_explosion.wav"

public const char s_SkeletonGibs[][] =
{
	"models/bots/skeleton_sniper/skeleton_sniper_gib_arm_l.mdl",
//	"models/bots/skeleton_sniper/skeleton_sniper_gib_arm_r.mdl",
	"models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl",
	"models/bots/skeleton_sniper/skeleton_sniper_gib_leg_l.mdl",
//	"models/bots/skeleton_sniper/skeleton_sniper_gib_leg_r.mdl", dont spawn so many.... cuauses massive lag.
	"models/bots/skeleton_sniper/skeleton_sniper_gib_torso.mdl"
};

public const char s_TrashProps[][] =
{
	"models/props_soho/bulb001.mdl",
	"models/props_soho/bottlecrate001.mdl",
	"models/props_halloween/eyeball_projectile.mdl",
	"models/props_halloween/flask_erlenmeyer.mdl",
	"models/props_halloween/flask_bottle.mdl",
	"models/props_halloween/hwn_spellbook_magazine.mdl",
	"models/props_halloween/jackolantern_01.mdl",
	"models/props_halloween/smlprop_spider.mdl",
	"models/props_farm/padlock.mdl",
	"models/props_farm/tools_shovel.mdl",
	"models/props_2fort/frog.mdl"
};

#define PARTICLE_FLIMSY_TRAIL		"drg_manmelter_trail_red"
#define PARTICLE_EXPLOSION_GENERIC	"ExplosionCore_MidAir"
#define PARTICLE_SHOCK_1			"drg_cow_rockettrail_normal"
#define PARTICLE_SHOCK_2			"critical_rocket_red"
#define PARTICLE_SHOCK_3			"critical_rocket_redsparks"
#define PARTICLE_SHOCK_1_MAX		"drg_cow_rockettrail_normal_blue"
#define PARTICLE_SHOCK_2_MAX		"critical_rocket_blue"
#define PARTICLE_SHOCK_3_MAX		"critical_rocket_bluesparks"
#define PARTICLE_SHOCK_BLAST		"drg_cow_explosioncore_charged"
#define PARTICLE_SHOCK_BLAST_MAX	"drg_cow_explosioncore_charged_blue"
#define PARTICLE_SHOCK_CHAIN		"spell_lightningball_hit_red"
#define PARTICLE_SHOCK_CHAIN_MAX	"spell_lightningball_hit_blue"
#define PARTICLE_SKELETON_BREAK		"spell_skeleton_goop_green"
#define PARTICLE_ICE				"utaunt_snowflakesaura_parent"
#define PARTICLE_ICE_BREAK			"utaunt_snowring_space_parent"
#define PARTICLE_TRASH				"merasmus_ambient"
#define PARTICLE_TRASH_BREAK		"spell_skeleton_goop_green"
#define PARTICLE_TRASH_MINI			"superrare_burning2"
#define PARTICLE_TRASH_BREAK_MINI	"spell_skeleton_goop_green"
#define PARTICLE_EXPLOSION_MONDO	"fireSmokeExplosion"

void Trash_Cannon_Precache()
{
	PrecacheModel(MODEL_ROCKET, true);
	PrecacheModel(MODEL_DRG, true);
	PrecacheModel(MODEL_ICE, true);
	PrecacheModel(MODEL_TRASH, true);
	PrecacheModel(MODEL_MONDO, true);
	
	for (int i = 0; i < sizeof(s_SkeletonGibs); i++)
	{
		PrecacheModel(s_SkeletonGibs[i]);
	}
	
	for (int j = 0; j < sizeof(s_TrashProps); j++)
	{
		PrecacheModel(s_TrashProps[j]);
	}
	
	PrecacheSound(SOUND_FLIMSY_BLAST, true);
	PrecacheSound(SOUND_SHOCK, true);
	PrecacheSound(SOUND_SHOCK_FIRE, true);
	PrecacheSound(SOUND_ARROWS_FIRE, true);
	PrecacheSound(SOUND_PYRE_FIRE, true);
	PrecacheSound(SOUND_SKELETON_FIRE, true);
	PrecacheSound(SOUND_SKELETON_BREAK, true);
	PrecacheSound(SOUND_ICE_FIRE, true);
	PrecacheSound(SOUND_ICE_BREAK, true);
	PrecacheSound(SOUND_TRASH_FIRE, true);
	PrecacheSound(SOUND_TRASH_BREAK, true);
	PrecacheSound(SOUND_TRASH_MINI_BREAK, true);
	PrecacheSound(SOUND_MISSILES_FIRE, true);
	PrecacheSound(SOUND_MISSILES_BEGIN_HOMING, true);
	PrecacheSound(SOUND_MONDO_FIRE, true);
	PrecacheSound(SOUND_MONDO_BREAK_1, true);
	PrecacheSound(SOUND_MONDO_BREAK_2, true);

	i_LastMondoWave = -1;
}

static float f_NextShockTime[2049] = { 0.0, ... };

public void Trash_Cannon_EntityDestroyed(int ent)
{
	if (ent < 1 || ent > 2048)
		return;
		
	f_NextShockTime[ent] = 0.0;
	i_TrashTier[ent] = 0;
}

public void Enable_Trash_Cannon(int client, int weapon)
{
	if (Timer_Trash[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TRASH_CANNON)
		{
			delete Timer_Trash[client];
			Timer_Trash[client] = null;
			DataPack pack;
			Timer_Trash[client] = CreateDataTimer(0.1, Timer_TrashControl, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TRASH_CANNON)
	{
		DataPack pack;
		Timer_Trash[client] = CreateDataTimer(0.1, Timer_TrashControl, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		f_TrashNextHUD[client] = 0.0;
	}
}

public Action Timer_TrashControl(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Trash[client] = null;
		return Plugin_Stop;
	}	

	Trash_HUD(client, weapon, false);

	return Plugin_Continue;
}

public void Trash_HUD(int client, int weapon, bool forced)
{
	if(f_TrashNextHUD[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon)
		{
			switch(i_NextShot[client])
			{
				case 1:
					PrintHintText(client, "NEXT: 충격 볼트");
				case 2:
					PrintHintText(client, "NEXT: 박격 표식탄");
				case 3:
					PrintHintText(client, "NEXT: 화살 묶음");
				case 4:
					PrintHintText(client, "NEXT: 파이어볼");
				case 5:
					PrintHintText(client, "NEXT: 인간 뼈대");
				case 6:
					PrintHintText(client, "NEXT: 시원한 얼음");
				case 7:
					PrintHintText(client, "NEXT: 쓰레기더미");
				case 8:
					PrintHintText(client, "NEXT: 마이크로 미사일 폭격");
				default:
				{
					if (i_TrashTier[weapon] > 1)
						PrintHintText(client, "NEXT: 파이어볼");
					else
						PrintHintText(client, "NEXT: 연약한 로켓");
				}
			}
		}
		f_TrashNextHUD[client] = GetGameTime() + 0.5;
	}
}

public void Weapon_Trash_Cannon_Fire(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 0);
}
public void Weapon_Trash_Cannon_Fire_Pap1(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 1);
}
public void Weapon_Trash_Cannon_Fire_Pap2(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 2);
}

public void Trash_Cannon_ChooseNext(int client, int weapon, int tier)
{
	ArrayStack scramble = Rand_GenerateScrambledArrayStack(i_TrashNumEffects);
	
	bool success = false;
	int effect = 0;
	while (!success && !scramble.Empty)
	{
		effect = scramble.Pop();
		switch(effect)
		{
			case 1:
				success = Trash_RollShock(client, tier);
			case 2:
				success = Trash_RollMortar(client, tier);
			case 3:
				success = Trash_RollArrows(client, tier);
			case 4:
				success = Trash_RollPyre(client, tier);
			case 5:
				success = Trash_RollSkeleton(client, tier);
			case 6:
				success = Trash_RollIce(client, tier);
			case 7:
				success = Trash_RollTrash(client, tier);
			case 8:
				success = Trash_RollMissiles(client, tier);
		}
	}
	
	if (!success)
		i_NextShot[client] = 0;
	else
		i_NextShot[client] = effect;
		
	Trash_HUD(client, weapon, true);
	
	delete scramble;
}

public void Trash_Cannon_Shoot(int client, int weapon, bool crit, int tier)
{
	i_TrashTier[weapon] = tier;

	if (!Trash_Mondo(client, weapon, tier))	//Mondo will override EVERY other possible roll if it is obtained.
	{
		switch(i_NextShot[client])
		{
			case 1:
				Trash_Shock(client, weapon, tier);
			case 2:
				Trash_Mortar(client, weapon, tier);
			case 3:
				Trash_Arrows(client, weapon, tier);
			case 4:
				Trash_Pyre(client, weapon, tier);
			case 5:
				Trash_Skeleton(client, weapon, tier);
			case 6:
				Trash_Ice(client, weapon, tier);
			case 7:
				Trash_Trash(client, weapon, tier);
			case 8:
				Trash_Missiles(client, weapon, tier);
			default:
			{
				if (tier > 1)
					Trash_Pyre(client, weapon, tier);
				else
					Trash_FlimsyRocket(client, weapon, tier);
			}
		}
	}
	
	Trash_Cannon_ChooseNext(client, weapon, tier);
}

public void Trash_FlimsyRocket(int client, int weapon, int tier)
{
	Trash_LaunchPhysProp(client, MODEL_ROCKET, GetRandomFloat(0.8, 1.2), f_FlimsyVelocity[tier], weapon, tier, Flimsy_Explode, true, true);
}

public MRESReturn Flimsy_Explode(int entity)
{
	float position[3];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_EXPLOSION_GENERIC, 1.0);
	EmitSoundToAll(SOUND_FLIMSY_BLAST, entity, SNDCHAN_STATIC, 80, _, 1.0);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	int tier = i_TrashTier[entity];
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_FlimsyDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_FlimsyRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, i_FlimsyMaxTargets[tier]);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

public bool Trash_RollShock(int client, int tier)
{
	if (!b_ShockEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ShockChance[tier])
		return false;
		
	return true;
}

public void Trash_Shock(int client, int weapon, int tier)
{
	int rocket = Trash_LaunchPhysProp(client, MODEL_DRG, 0.001, f_ShockVelocity[tier], weapon, tier, Shock_Explode, true, true);
	
	if (IsValidEntity(rocket))
	{
		EmitSoundToAll(SOUND_SHOCK_FIRE, client, SNDCHAN_STATIC, 80, _, 1.0);
		
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_1_MAX : PARTICLE_SHOCK_1, 6.0, "");
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_2_MAX : PARTICLE_SHOCK_2, 6.0, "");
		Trash_AttachParticle(rocket, tier > 1 ? PARTICLE_SHOCK_3_MAX : PARTICLE_SHOCK_3, 6.0, "");
	}
}

public MRESReturn Shock_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, tier > 1 ? PARTICLE_SHOCK_BLAST_MAX : PARTICLE_SHOCK_BLAST, 1.0);
	EmitSoundToAll(SOUND_SHOCK, entity, SNDCHAN_STATIC, 80, _, 1.0);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_ShockDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_ShockRadius[tier];

	for (int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int ent = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		
		if (IsValidEntity(ent) && !b_NpcHasDied[ent])
		{
			f_NextShockTime[ent] = 0.0;
		}
	}

	Shock_ChainToVictim(entity, owner, weapon, damage, radius, position, tier, 0);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

public void Shock_ChainToVictim(int inflictor, int client, int weapon, float damage, float radius, float position[3], int tier, int NumHits)
{
	if (NumHits >= i_ShockMaxHits[tier])
		return;
		
	int victim = Trash_GetClosestVictim(position, radius, true);
	float gt = GetGameTime();
	if (IsValidEntity(victim))
	{
		float vicLoc[3];
		WorldSpaceCenter(victim, vicLoc);
		SDKHooks_TakeDamage(victim, inflictor, client, damage, DMG_BLAST | DMG_ALWAYSGIB, weapon);

		ApplyStatusEffect(client, victim, "Electric Impairability", f_ShockPassangerTime[tier]);
		
		f_NextShockTime[victim] = gt + 0.01;
		
		ParticleEffectAt(vicLoc, tier > 1 ? PARTICLE_SHOCK_BLAST_MAX : PARTICLE_SHOCK_BLAST, 1.0);
		SpawnParticle_ControlPoints(position, vicLoc, tier > 1 ? PARTICLE_SHOCK_CHAIN_MAX : PARTICLE_SHOCK_CHAIN, 1.0);
		
		float shockRad = f_ShockChainRadius[tier];
		
		if (NumHits < i_ShockMaxHits[tier])
		{
			Shock_ChainToVictim(inflictor, client, weapon, damage * f_ShockDMGReductionPerHit[tier], shockRad, vicLoc, tier, NumHits + 1);
		}
	}
}

public bool Trash_RollMortar(int client, int tier)
{
	if (!b_MortarEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MortarChance[tier])
		return false;
		
	return true;
}

public void Trash_Mortar(int client, int weapon, int tier)
{
	return;
}

public bool Trash_RollArrows(int client, int tier)
{
	if (!b_ArrowsEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ArrowsChance[tier])
		return false;
		
	return true;
}

public void Trash_Arrows(int client, int weapon, int tier)
{
	float ang[3], pos[3];
	GetClientEyePosition(client, pos);
	
	float damage = f_ArrowsDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float vel = f_ArrowsVelocity[tier] * Attributes_Get(weapon, 103, 1.0) * Attributes_Get(weapon, 104, 1.0) * Attributes_Get(weapon, 475, 1.0);
	
	for (int i = 0; i < GetRandomInt(i_ArrowsMinArrows[tier], i_ArrowsMaxArrows[tier]); i++)
	{
		GetClientEyeAngles(client, ang);
		ang[0] += GetRandomFloat(-f_ArrowsSpread[tier], f_ArrowsSpread[tier]);
		ang[1] += GetRandomFloat(-f_ArrowsSpread[tier], f_ArrowsSpread[tier]);
		ang[2] += GetRandomFloat(-f_ArrowsSpread[tier], f_ArrowsSpread[tier]);
		
		int arrow = SDKCall_CTFCreateArrow(pos, ang, vel, 0.1, 8, client, client);
		if (IsValidEntity(arrow))
		{
			
			SetEntityCollisionGroup(arrow, 27);
			SetEntDataFloat(arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);	// Damage
			SetEntPropEnt(arrow, Prop_Send, "m_hOriginalLauncher", weapon);
			SetEntPropEnt(arrow, Prop_Send, "m_hLauncher", weapon);
			SetEntProp(arrow, Prop_Send, "m_bCritical", false);
		}
	}
	
	EmitSoundToAll(SOUND_ARROWS_FIRE, client, SNDCHAN_STATIC, 110, _, 1.0);
}

public bool Trash_RollPyre(int client, int tier)
{
	if (!b_PyreEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_PyreChance[tier])
		return false;
		
	return true;
}

public void Trash_Pyre(int client, int weapon, int tier)
{
	float damage = f_PyreDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float vel = f_PyreVel[tier] * Attributes_Get(weapon, 103, 1.0) * Attributes_Get(weapon, 104, 1.0) * Attributes_Get(weapon, 475, 1.0);

	int entity = CreateEntityByName("tf_projectile_spellfireball");
	if(IsValidEntity(entity))
	{
		float ang[3], pos[3], velVec[3], buffer[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
	
		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		velVec[0] = buffer[0] * vel;
		velVec[1] = buffer[1] * vel;
		velVec[2] = buffer[2] * vel;
	
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetTeam(entity, GetTeam(client));
		
		DispatchSpawn(entity);
		
		SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(entity, f_PyreGravity[tier]);
		TeleportEntity(entity, pos, ang, velVec);
		
		f_CustomGrenadeDamage[entity] = damage;
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
	}
		
	EmitSoundToAll(SOUND_PYRE_FIRE, client, SNDCHAN_STATIC, 90, _, 1.0);
}

public bool Trash_RollSkeleton(int client, int tier)
{
	if (!b_SkeletonEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_SkeletonChance[tier])
		return false;
		
	return true;
}

public void Trash_Skeleton(int client, int weapon, int tier)
{
	int skin = GetRandomInt(0, 3);
	
	for (int i = 0; i < sizeof(s_SkeletonGibs); i++)
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		ang[0] += GetRandomFloat(-f_SkeletonSpread[tier], f_SkeletonSpread[tier]);
		ang[1] += GetRandomFloat(-f_SkeletonSpread[tier], f_SkeletonSpread[tier]);
		ang[2] += GetRandomFloat(-f_SkeletonSpread[tier], f_SkeletonSpread[tier]);
		
		char placeholder[255];
		strcopy(placeholder, 255, s_SkeletonGibs[i]);
		
		Trash_LaunchPhysProp(client, placeholder, GetRandomFloat(0.8, 1.2), f_SkeletonVel[tier], weapon, tier, Skeleton_Explode, true, false, ang, true, skin);
	}
	
	EmitSoundToAll(SOUND_SKELETON_FIRE, client, SNDCHAN_STATIC, 120, _, 1.0);
}

public MRESReturn Skeleton_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_SKELETON_BREAK, 1.0);
	EmitSoundToAll(SOUND_SKELETON_BREAK, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_SkeletonDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_SkeletonRadius[tier];

	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, 1);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

public bool Trash_RollIce(int client, int tier)
{
	if (!b_IceEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_IceChance[tier])
		return false;
		
	return true;
}

public void Trash_Ice(int client, int weapon, int tier)
{		
	float vel = f_IceVelocity[tier];
		
	int ice = Trash_LaunchPhysProp(client, MODEL_ICE, GetRandomFloat(0.8, 1.0), vel, weapon, tier, Ice_Explode, true, true);
	if (IsValidEntity(ice))
	{
		Trash_AttachParticle(ice, PARTICLE_ICE, 6.0, "");
		EmitSoundToAll(SOUND_ICE_FIRE, client, SNDCHAN_STATIC, 120, _, 1.0);
		SetEntityRenderMode(ice, RENDER_TRANSALPHA);
		SetEntityRenderColor(ice, 120, 180, 255, 200);
	}
}

public MRESReturn Ice_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_ICE_BREAK, 1.0);
	EmitSoundToAll(SOUND_ICE_BREAK, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_IceDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_IceRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, i_IceMaxTargets[tier], _, _, CryoWandHitM2, Trash_IceHitPre);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

void Trash_IceHitPre(int entity, int victim, float damage, int weapon)
{
	Elemental_AddCyroDamage(victim, entity, RoundFloat(damage * 240.0), 1);
}

public bool Trash_RollTrash(int client, int tier)
{
	if (!b_TrashEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_TrashChance[tier])
		return false;
		
	return true;
}

public void Trash_Trash(int client, int weapon, int tier)
{	
	float vel = f_TrashVelocity[tier];
		
	int trash = Trash_LaunchPhysProp(client, MODEL_TRASH, GetRandomFloat(0.8, 1.2), vel, weapon, tier, Trash_Explode, true, true);
	if (IsValidEntity(trash))
	{
		Trash_AttachParticle(trash, PARTICLE_TRASH, 6.0, "");
		EmitSoundToAll(SOUND_TRASH_FIRE, client, SNDCHAN_STATIC, 120, _, 1.0);
	}
}

public MRESReturn Trash_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_TRASH_BREAK, 1.0);
	EmitSoundToAll(SOUND_TRASH_BREAK, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_TrashDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_TrashRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, i_TrashMaxTargets[tier]);
	
	RemoveEntity(entity);
	
	float vel = f_TrashMiniVelocity[tier];

	position[2] += 25.0;
	
	for (int i = 0; i < GetRandomInt(i_TrashMinExtras[tier], i_TrashMaxExtras[tier]); i++)
	{
		char placeholder[255];
		strcopy(placeholder, 255, s_TrashProps[GetRandomInt(0, sizeof(s_TrashProps) - 1)]);
		
		float ang[3];
		ang[0] = GetRandomFloat(-20.0, -90.0);
		ang[1] = GetRandomFloat(0.0, 360.0);
		ang[2] = GetRandomFloat(0.0, 360.0);
		
		int mini = Trash_LaunchPhysProp(owner, placeholder, GetRandomFloat(0.8, 1.0), vel, weapon, tier, Trash_MiniExplode, true, true, ang, true, _, position, true);
		if (IsValidEntity(mini))
		{
			Trash_AttachParticle(mini, PARTICLE_TRASH_MINI, 6.0, "");
		}
	}
	
	return MRES_Supercede; //DONT.
}

public MRESReturn Trash_MiniExplode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_TRASH_BREAK_MINI, 1.0);
	EmitSoundToAll(SOUND_TRASH_MINI_BREAK, entity, SNDCHAN_STATIC, 80, _, 1.0, GetRandomInt(80, 110));
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_TrashMiniDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_TrashMiniRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, i_TrashMiniMaxTargets[tier]);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

public bool Trash_RollMissiles(int client, int tier)
{
	if (!b_MissilesEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MissilesChance[tier])
		return false;
		
	return true;
}

public void Trash_Missiles(int client, int weapon, int tier)
{
	DataPack pack = new DataPack();
	CreateDataTimer(f_MissilesWaveDelay[tier], Missiles_FireWave, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, EntIndexToEntRef(weapon));
	WritePackCell(pack, tier);
	WritePackCell(pack, i_MissilesNumWaves[tier]);
}

public Action Missiles_FireWave(Handle timed, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int weapon = EntRefToEntIndex(ReadPackCell(pack));
	int tier = ReadPackCell(pack);
	int remaining = ReadPackCell(pack);
	
	if (!IsValidClient(client) || !IsValidEntity(weapon) || remaining < 1)
		return Plugin_Stop;
	
	EmitSoundToAll(SOUND_MISSILES_FIRE, client, SNDCHAN_STATIC, 60, _, 0.8);
	
	for (int i = 0; i < i_MissilesCount[tier]; i++)
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		ang[0] += GetRandomFloat(-3.0, 3.0);
		ang[1] += GetRandomFloat(-f_MissilesSpread[tier], f_MissilesSpread[tier]);
		ang[2] += GetRandomFloat(-f_MissilesSpread[tier], f_MissilesSpread[tier]);
		
		int missile = Trash_LaunchPhysProp(client, MODEL_ROCKET, 0.5, f_MissilesVelocity[tier], weapon, tier, Missiles_Explode, false, false, ang, true);
		if (IsValidEntity(missile))
		{
			CreateTimer(f_MissilesHomingStartTime[tier], Missiles_BeginHoming, EntIndexToEntRef(missile), TIMER_FLAG_NO_MAPCHANGE);
			SetEntityMoveType(missile, MOVETYPE_FLY);
		}
	}
	
	DataPack pack2 = new DataPack();
	CreateDataTimer(f_MissilesWaveDelay[tier], Missiles_FireWave, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(client));
	WritePackCell(pack2, EntIndexToEntRef(weapon));
	WritePackCell(pack2, tier);
	WritePackCell(pack2, remaining - 1);
	
	return Plugin_Stop;
}

public MRESReturn Missiles_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_EXPLOSION_GENERIC, 1.0);
	EmitSoundToAll(SOUND_FLIMSY_BLAST, entity, SNDCHAN_STATIC, 80, _, 0.8);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_MissilesDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_MissilesRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, _, false, i_MissilesMaxTargets[tier]);
	
	RemoveEntity(entity);
	
	return MRES_Supercede; //DONT.
}

public Action Missiles_BeginHoming(Handle begin, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
		float ang[3];
		GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
		Initiate_HomingProjectile(ent, owner, 360.0, 120.0, false, true, ang);
		EmitSoundToAll(SOUND_MISSILES_BEGIN_HOMING, ent, SNDCHAN_STATIC, 80, _, 0.8);
	}
	
	return Plugin_Stop;
}

public bool Trash_Mondo(int client, int weapon, int tier)
{
	if (!b_MondoEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MondoChance[tier] || (Waves_GetRoundScale() == i_LastMondoWave && !allowMultipleMondos))
		return false;
		
	int M_O_N_D_O = Trash_LaunchPhysProp(client, MODEL_MONDO, 5.0, f_MondoVelocity[tier], weapon, tier, Mondo_Explode, true, true);
	if (IsValidEntity(M_O_N_D_O))
	{
		EmitSoundToAll(SOUND_MONDO_FIRE, client, SNDCHAN_STATIC, 120, _, 1.0);
		EmitSoundToAll(SOUND_MONDO_FIRE, client, SNDCHAN_STATIC, 120, _, 1.0, 80);
	}
		
	i_LastMondoWave = Waves_GetRoundScale();
	return true;
}

public MRESReturn Mondo_Explode(int entity)
{
	float position[3];
	int tier = i_TrashTier[entity];
	
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_EXPLOSION_MONDO, 1.0);
	EmitSoundToAll(SOUND_MONDO_BREAK_1, _, _, 120);
	EmitSoundToAll(SOUND_MONDO_BREAK_2, _, _, 120, _, _, 80);
	
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	int weapon = EntRefToEntIndex(i_TrashWeapon[entity]);
	if(!IsValidClient(owner))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	if(!IsValidEntity(weapon))
	{
		int i, weapon1;
		while(TF2_GetItem(owner, weapon1, i))
		{
			if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_TRASH_CANNON)
			{
				i_TrashWeapon[entity] = EntIndexToEntRef(weapon1);
				weapon = weapon1;
				break;
			}
		}
	}
	if(!IsValidEntity(weapon))
	{
		RemoveEntity(entity);
		return MRES_Supercede; //DONT.
	}
	
	float damage = f_MondoDMG[tier] * Attributes_Get(weapon, 2, 1.0);
	float radius = f_MondoRadius[tier];
	
	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, 0.925, _, false, i_MondoMaxTargets[tier]);
	
	RemoveEntity(entity);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			Client_Shake(i, SHAKE_START, 250.0, _, 6.0);
			DoOverlay(i, "lights/white005", 0);
			CreateTimer(0.1, Mondo_RemoveOverlay, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return MRES_Supercede; //DONT.
}

public Action Mondo_RemoveOverlay(Handle helpmeimblind, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
		DoOverlay(client, "");
		
	return Plugin_Continue;
}

int Trash_LaunchPhysProp(int client, char model[255], float scale, float velocity, int weapon, int tier, DHookCallback CollideCallback, bool ForceRandomAngles, bool Spin, float angOverride[3] = NULL_VECTOR, bool useAngOverride = false, int skin = 0, float posOverride[3] = NULL_VECTOR, bool usePosOverride = false)
{
	int prop = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "trash_projectile"); 
				
		SetEntDataFloat(prop, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(prop, GetTeam(client));
				
		DispatchSpawn(prop);
				
		ActivateEntity(prop);
		
		SetEntityModel(prop, model);
		char scaleChar[16];
		Format(scaleChar, sizeof(scaleChar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scaleChar);
		
		SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
		
		char skinChar[16];
		Format(skinChar, 16, "%i", skin);
		DispatchKeyValue(prop, "skin", skinChar);
		
		float pos[3], ang[3], propVel[3], buffer[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		
		if (useAngOverride)
		{
			ang = angOverride;
		}
		
		if (usePosOverride)
		{
			pos = posOverride;
		}

		GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
		
		if (IsValidEntity(weapon))
		{
			velocity *= Attributes_Get(weapon, 103, 1.0);
		
			velocity *= Attributes_Get(weapon, 104, 1.0);
		
			velocity *= Attributes_Get(weapon, 475, 1.0);
			
			i_TrashWeapon[prop] = EntIndexToEntRef(weapon);
		}
		
		SetEntityMoveType(prop, MOVETYPE_FLYGRAVITY);
		
		propVel[0] = buffer[0]*velocity;
		propVel[1] = buffer[1]*velocity;
		propVel[2] = buffer[2]*velocity;
		
		if (ForceRandomAngles)
		{
			for (int i = 0; i < 3; i++)
			{
				ang[i] = GetRandomFloat(0.0, 360.0);
			}
		}
			
		TeleportEntity(prop, pos, ang, propVel);
		SetEntPropVector(prop, Prop_Send, "m_vInitialVelocity", propVel);
		
		if (Spin)
		{
			RequestFrame(SpinEffect, EntIndexToEntRef(prop));
		}
		
		i_TrashTier[prop] = tier;
		if(h_NpcSolidHookType[prop] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[prop]);
		h_NpcSolidHookType[prop] = 0;
		h_NpcSolidHookType[prop] = g_DHookRocketExplode.HookEntity(Hook_Pre, prop, CollideCallback);
		
		return prop;
	}
	
	return -1;
}

public int Trash_GetClosestVictim(float position[3], float radius, bool shock)
{
	int closest = -1;
	float dist = 999999999.0;
	
	for (int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int ent = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		
		if (IsValidEntity(ent) && GetTeam(ent) != TFTeam_Red && !b_NpcHasDied[ent] && (!shock || f_NextShockTime[ent] <= GetGameTime()))
		{
			float vicLoc[3];  
			WorldSpaceCenter(ent, vicLoc);
			
			float targDist = GetVectorDistance(position, vicLoc, true);  
				
			if(targDist <= (radius * radius) && targDist < dist)
			{
				closest = ent;
				dist = targDist;
			}
		}
	}
	
	return closest;
}

public ArrayStack Rand_GenerateScrambledArrayStack(int numSlots)
{
	ArrayStack scramble = new ArrayStack();
	Handle genericArray = CreateArray(255);
	
	for (int i = 0; i <= numSlots; i++)
	{
		PushArrayCell(genericArray, i);
	}
	
	for (int j = 0; j < GetArraySize(genericArray); j++)
	{
		int randSlot = GetRandomInt(j, GetArraySize(genericArray) - 1);
		int currentVal = GetArrayCell(genericArray, j);
		SetArrayCell(genericArray, j, GetArrayCell(genericArray, randSlot));
		SetArrayCell(genericArray, randSlot, currentVal);
		
		scramble.Push(GetArrayCell(genericArray, j));
	}
	
	delete genericArray;
	return scramble;
}

stock void Trash_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			/*
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			*/	
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public void SpinEffect(int ref)
{
	int ent = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(ent))
		return;
		
	float ang[3];
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
		
	for (int i = 0; i < 3; i++)
	{
		ang[i] += 4.0;
	}
		
	TeleportEntity(ent, NULL_VECTOR, ang, NULL_VECTOR);
		
	RequestFrame(SpinEffect, EntIndexToEntRef(ent));
}

stock void SpawnParticle_ControlPoints(float StartPos[3], float EndPos[3], char particleType[255], float duration)
{
	 int particle  = CreateEntityByName("info_particle_system");
	 int particle2 = CreateEntityByName("info_particle_system");
	 int ent = InfoTargetParentAt(StartPos, "", 0.0);
	 int controlpoint = InfoTargetParentAt(EndPos, "", 0.0);
 
	 if (IsValidEdict(particle) && IsValidEdict(particle2) && IsValidEdict(ent) && IsValidEdict(controlpoint))
	 {
		  TeleportEntity(particle, StartPos, NULL_VECTOR, NULL_VECTOR); 
		  TeleportEntity(particle2, EndPos, NULL_VECTOR, NULL_VECTOR);
		  
		  char tName[128];
		  Format(tName, sizeof(tName), "target%i", ent);
		  DispatchKeyValue(ent, "targetname", tName);
		  
		  char cpName[128];
		  Format(cpName, sizeof(cpName), "Xtarget%i", controlpoint);
		  
		  DispatchKeyValue(particle2, "targetname", cpName);
		  
		  DispatchKeyValue(particle, "targetname", "tf2particle");
		  DispatchKeyValue(particle, "parentname", tName);
		  DispatchKeyValue(particle, "effect_name", particleType);
		  DispatchKeyValue(particle, "cpoint1", cpName);
		  
		  DispatchSpawn(particle);
		  SetVariantString(tName);
		  AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		  
		  SetVariantString("flag");
		  AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);
		  
		  ActivateEntity(particle);
		  AcceptEntityInput(particle, "start");
		  
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(controlpoint), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	 }
} 