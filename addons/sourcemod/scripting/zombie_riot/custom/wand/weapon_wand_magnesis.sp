#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.

//STANDARD M1 PROJECTILE: The Magnesis Staff's primary fire is nothing special, just a generic projectile.
static float Magnesis_M1_Cost[3] = { 10.0, 10.0, 10.0 };            //M1 cost.
static float Magnesis_M1_DMG[3] = { 40.0, 60.0, 80.0 };             //M1 projectile damage.
static float Magnesis_M1_Lifespan[3] = { 0.2, 0.25, 0.3 };          //M1 projectile lifespan.
static float Magnesis_M1_Velocity[3] = { 1200.0, 1400.0, 1600.0 };  //M1 projectile velocity.

//M2 - GRAB: Clicking M2 on a living zombie allows the user to grab that zombie and hold it in front of them, provided 
//the target is within range. Holding a zombie drains mana, which becomes more expensive the longer the zombie is held.
//Held zombies are stunned. At any time, the user may press M2 again to throw the zombie (if they do not have the mana
//to afford the throw, the zombie is simply dropped). The velocity of this throw is based on the amount of damage
//that zombie took while grabbed, relative to their max health.
static float Magnesis_Grab_Requirement[3] = { 50.0, 100.0, 150.0 };		//Initial mana cost in order to grab an enemy.
static float Magnesis_Grab_Cost_Normal[3] = { 5.0, 5.0, 5.0 };			//Mana drained per 0.1s while holding a normal enemy.
static float Magnesis_Grab_Cost_Special[3] = { 35.0, 35.0, 35.0 };		//Mana drained per 0.1s while holding a boss/mini-boss.
static float Magnesis_Grab_Cost_Raid[3] = { 75.0, 75.0, 75.0 };			//Mana drained per 0.1s while holding a raid.
static float Magnesis_Grab_Range[3] = { 150.0, 200.0, 250.0 };			//Maximum distance from which enemies can be grabbed.
static float Magnesis_Grab_MaxVel[3] = { 400.0, 600.0, 800.0 };			//Maximum throw velocity.
static float Magnesis_Grab_ThrowThreshold[3] = { 0.75, 0.66, 0.5 };		//Percentage of max health taken as damage while grabbed in order for the throw to reach max velocity.
static float Magnesis_Grab_ThrowDMG[3] = { 1000.0, 1500.0, 2000.0 };	//Damage dealt to grabbed enemies when they are thrown.
static bool Magnesis_Grab_Specials[3] = { false, true, true };			//Can the Magnesis Staff grab bosses/mini-bosses on this tier?
static bool Magnesis_Grab_Raids[3] = { false, false, true };			//Can the Magnesis Staff grab raids on this tier?

//NEWTONIAN KNUCKLES: Alternate PaP path which replaces the M1 with a far stronger explosive projectile with a slower rate of fire.
//Replaces M2 with a shockwave that deals knockback. M1 projectile deals bonus damage if it airshots an enemy who is airborne because of the M2 attack.
static float Newtonian_M1_Cost[3] = { 50.0, 75.0, 100.0 };						//M1 cost.
static float Newtonian_M1_DMG[3] = { 400.0, 800.0, 1200.0 };					//M1 damage.
static float Newtonian_M1_Radius[3] = { 150.0, 165.0, 180.0 };					//M1 explosion radius.
static float Newtonian_M1_Velocity[3] = { 1400.0, 1800.0, 2200.0 };				//M1 projectile velocity.
static float Newtonian_M1_Lifespan[3] = { 1.0, 1.15, 1.3 };						//M1 projectile lifespan.
static float Newtonian_M1_Falloff_MultiHit[3] = { 0.66, 0.75, 0.85 };			//Amount to multiply damage dealt by M1 per target hit.
static float Newtonian_M1_Falloff_Distance[3] = { 0.66, 0.75, 0.85 };			//Maximum M1 damage falloff, based on distance.
static float Newtonian_M1_ComboMult[3] = { 2.0, 2.0, 2.0 };						//Amount to multiply damage dealt by the M1 to enemies who have been knocked airborne by the M2.
static int Newtonian_M1_MaxTargets[3] = { 4, 5, 6 };							//Max targets hit by the M1 projectile's explosion.
static float Newtonian_M2_Cost[3] = { 200.0, 300.0, 400.0 };					//M2 cost.
static float Newtonian_M2_DMG[3] = { 800.0, 1600.0, 2400.0 };					//M2 damage.
static float Newtonian_M2_Radius[3] = { 160.0, 180.0, 200.0 };					//M2 radius.
static float Newtonian_M2_Falloff_MultiHit[3] = { 0.5, 0.66, 0.75 };			//Amount to multiply damage dealt by the M2 shockwave per target hit.
static float Newtonian_M2_Falloff_Distance[3] = { 0.5, 0.66, 0.75 };			//Maximum M2 damage falloff, based on distance.
static float Newtonian_M2_Knockback_Horizontal[3] = { 200.0, 250.0, 300.0 };	//Horizontal knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_Knockback_Vertical[3] = { 400.0, 500.0, 600.0 };		//Vertical knockback applied to enemies hit by the M2 shockwave.
static float Newtonian_M2_AttackDelay[3] = { 0.66, 0.66, 0.66 };				//Duration to prevent the user from attacking with M1 after triggering a shockwave. This is to prevent cheesy combos where you press M2 and M1 at the same time.

//Client/entity-specific global variables below, don't touch these:
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};
static int Magnesis_ProjectileTier[2049] = { 0, ... };
static int Magnesis_Tier[2049] = { 0, ... };
static bool Magnesis_ProjectileIsNewtonian[2049] = { false, ... };
static bool Newtonian_Airborne[2049] = { false, ... };

public void Magnesis_ResetAll()
{
	Zero(ability_cooldown);
}

#define SND_MAGNESIS_M1         	")weapons/capper_shoot.wav"
#define SND_MAGNESIS_M1_COLLIDE		")weapons/flare_detonator_explode_world.wav"
#define SND_NEWTONIAN_M1			")weapons/cow_mangler_main_shot.wav"
#define SND_NEWTONIAN_M1_COLLIDE	")weapons/cow_mangler_explosion_normal_01.wav"
#define SND_NEWTONIAN_M2			")weapons/bumper_car_spawn.wav"
#define SND_NEWTONIAN_M2_2			")weapons/cow_mangler_explode.wav"

#define PARTICLE_MAGNESIS_M1     			"raygun_projectile_blue"
#define PARTICLE_MAGNESIS_M1_FINALPAP		"raygun_projectile_blue_crit"
#define PARTICLE_MAGNESIS_M1_COLLIDE		"impact_metal"
#define PARTICLE_MAGNESIS_M2				"arm_muzzleflash_zap2"
#define PARTICLE_MAGNESIS_M2_FINALPAP		"bombonomicon_spell_trail"
#define PARTICLE_NEWTONIAN_M1    			"raygun_projectile_red"
#define PARTICLE_NEWTONIAN_M1_FINALPAP    	"raygun_projectile_red_crit"
#define PARTICLE_NEWTONIAN_M1_COLLIDE		"drg_cow_explosioncore_charged"
#define PARTICLE_NEWTONIAN_M2				"mvm_soldier_shockwave"

void Magnesis_Precache()
{
    PrecacheSound(SND_MAGNESIS_M1);
	PrecacheSound(SND_MAGNESIS_M1_COLLIDE);
	PrecacheSound(SND_NEWTONIAN_M1);
	PrecacheSound(SND_NEWTONIAN_M1_COLLIDE);
	PrecacheSound(SND_NEWTONIAN_M2);
	PrecacheSound(SND_NEWTONIAN_M2_2);
}

void Magnesis_OnKill(int victim)
{
	Newtonian_Airborne[victim] = false;
}

public void Magnesis_OnNPCDamaged(int victim, float damage)
{

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

			PrintHintText(client, HUDText);

			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		}

		f_NextMagnesisHUD[client] = GetGameTime() + 0.5;
	}
}

void Magnesis_Attack_0(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 0);
}

void Magnesis_Attack_1(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 1);
}

void Magnesis_Attack_2(int client, int weapon, bool &result, int slot)
{
    Magnesis_FireProjectile(client, weapon, 2);
}

void Magnesis_FireProjectile(int client, int weapon, int tier)
{
    float mana_cost = Magnesis_M1_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		Utility_FireProjectile(client, weapon, tier, false);

        EmitSoundToAll(SND_MAGNESIS_M1, client, _, _, _, 0.66);
		EmitSoundToClient(client, SND_MAGNESIS_M1, _, _, _, _, 0.66);
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

void Magnesis_Grab_0(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 0);
}

void Magnesis_Grab_1(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 1);
}

void Magnesis_Grab_2(int client, int weapon, bool &result, int slot)
{
    Magnesis_AttemptGrab(client, weapon, 2);
}

void Magnesis_AttemptGrab(int client, int weapon, int tier)
{
    float mana_cost = Magnesis_Grab_Requirement[tier];

    if(mana_cost <= Current_Mana[client])
	{
		//TODO: Check to see if we can grab the thing we're looking at.

		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

void Newtonian_Attack_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 0);
}

void Newtonian_Attack_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 1);
}

void Newtonian_Attack_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_FireProjectile(client, weapon, 2);
}

void Newtonian_FireProjectile(int client, int weapon, int tier)
{
    float mana_cost = Newtonian_M1_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{	
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		Utility_FireProjectile(client, weapon, tier, true);

        EmitSoundToAll(SND_NEWTONIAN_M1, client, _, _, _, 0.8);
		EmitSoundToClient(client, SND_NEWTONIAN_M1, _, _, _, _, 0.66);
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
}

void Newtonian_Shockwave_0(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 0);
}

void Newtonian_Shockwave_1(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 1);
}

void Newtonian_Shockwave_2(int client, int weapon, bool &result, int slot)
{
    Newtonian_TryShockwave(client, weapon, 2);
}

void Newtonian_TryShockwave(int client, int weapon, int tier)
{
    float mana_cost = Newtonian_M2_Cost[tier];

    if(mana_cost <= Current_Mana[client])
	{
		Rogue_OnAbilityUse(weapon);
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		float pos[3];
		GetClientAbsOrigin(client, pos);
		ParticleEffectAt(pos, PARTICLE_NEWTONIAN_M2);
		spawnRing_Vector(pos, 0.1, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 120, 120, 255, 1, 0.33, 16.0, 6.0, 1, Newtonian_M2_Radius[tier]);
		spawnRing_Vector(pos, 0.1, 0.0, 0.0, 0.0, "materials/sprites/glow02.vmt", 255, 120, 120, 255, 1, 0.33, 16.0, 6.0, 1, Newtonian_M2_Radius[tier]);

		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;

        EmitSoundToAll(SND_NEWTONIAN_M2, client, _, _, _, 0.8);
		EmitSoundToAll(SND_NEWTONIAN_M2_2, client, _, _, _, 0.8, 80);

		float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") + Newtonian_M2_AttackDelay[tier];
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", nextAttack);
	}
	else
	{
		Utility_NotEnoughMana(client, mana_cost);
	}
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
		Explode_Logic_Custom(f_WandDamage[entity], owner, entity, weapon, selfPos, Newtonian_M1_Radius[Magnesis_ProjectileTier[entity]], Newtonian_M1_Falloff_MultiHit[Magnesis_ProjectileTier[entity]], Newtonian_M1_Falloff_Distance[Magnesis_ProjectileTier[entity]], false, Newtonian_M1_MaxTargets[Magnesis_ProjectileTier[entity]], _, _, view_as<Function>(Newtonian_M1Hit));

		ParticleEffectAt(selfPos, PARTICLE_NEWTONIAN_M1_COLLIDE);
		EmitSoundToAll(SND_NEWTONIAN_M1_COLLIDE, entity, SNDCHAN_STATIC);

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

void Utility_NotEnoughMana(int client, float cost)
{
	char text[255];
	Format(text, sizeof(text), "%t", "Not Enough Mana", cost);
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