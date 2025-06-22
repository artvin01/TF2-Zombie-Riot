static float f_DamageToAbsorb[MAXPLAYERS];
static float f_DamageToAbsorbMax[MAXPLAYERS];
static bool b_BeserkActive[MAXPLAYERS];
static float f_DamageResistance[MAXPLAYERS];
static float f_HealthToRegain[MAXPLAYERS];
static int i_ParticleEffect[MAXPLAYERS];

void BeserkerRageGain_Map_Precache()
{
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
	PrecacheSound("items/powerup_pickup_knockout.wav");
	PrecacheSound("misc/halloween/spell_overheal.wav");
}

public float BeserkerRageGain(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee && !i_IsWandWeapon[weapon])
			{
				if(Stats_Strength(client) >= 20)
				{
					Ability_BeserkerRageGain(client, 1, weapon);
					return (GetGameTime() + 40.0);
				}
				else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Strength [20]");
					return 0.0;
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

public void Ability_BeserkerRageGain(int client, int level, int weapon)
{
	CreateTimer(5.0, Timer_BeserkDeactivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	b_BeserkActive[client] = true;
	float MaxHealthScale = float(SDKCall_GetMaxHealth(client)) * 0.4;
	f_DamageToAbsorb[client] = MaxHealthScale;	
	f_DamageToAbsorbMax[client] = MaxHealthScale;
	f_DamageResistance[client] = 0.2;	
	f_HealthToRegain[client] = 0.0;
	EmitSoundToAll("items/powerup_pickup_knockout.wav", client, _, 70);

	CreateTimer(0.1, Beserk_ringTracker_effect, EntIndexToEntRef(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

static Action Beserk_ringTracker_effect(Handle ringTracker, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client) && b_BeserkActive[client])
	{
		float Range = 50.0;
		float abspos[3]; 
		float alpha;
		alpha = f_DamageToAbsorb[client] * 255.0  / (RoundToFloor(f_DamageToAbsorbMax[client]) + 1.0);

	//	alpha = 255.0 - alpha;

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", abspos);
		spawnRing_Vectors(abspos, Range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, RoundToFloor(alpha), 1, 0.21, 5.0, 8.0, 1);	
	}
	else
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

void BeserkHealthArmorDisconnect(int client)
{
	b_BeserkActive[client] = false;
}

public Action Timer_BeserkDeactivate(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		int ParticleEntity = EntRefToEntIndex(i_ParticleEffect[client]);
		if(IsValidEntity(ParticleEntity))
		{
			RemoveEntity(ParticleEntity);
		}
		if(b_BeserkActive[client])
		{
			Beserk_EndAbility(client);
		}
		b_BeserkActive[client] = false;
	}
	return Plugin_Handled;
}

float BeserkHealthArmor_OnTakeDamage(int victim, float damage)
{
	if(b_BeserkActive[victim] && f_DamageToAbsorb[victim] > 0)
	{
		float dmg_through_armour = damage * 0.1;
					
		if(damage * 0.9 >= f_DamageToAbsorb[victim])
		{
			float damage_recieved_after_calc;
			damage_recieved_after_calc = damage - f_DamageToAbsorb[victim];
			f_HealthToRegain[victim] += damage - damage_recieved_after_calc;
			f_DamageToAbsorb[victim] = 0.0;
			damage = damage_recieved_after_calc;
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25);
			Beserk_EndAbility(victim);
			b_BeserkActive[victim] = false;
		}
		else
		{
			f_DamageToAbsorb[victim] -= damage * 0.9;
			f_HealthToRegain[victim] += damage * 0.9;
			damage = 0.0;
			damage += dmg_through_armour;
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25);
		}
	}
	return damage;
}


void Beserk_EndAbility(int client)
{
	float HealthToRegen = f_HealthToRegain[client];
	f_HealthToRegain[client] = 0.0;
	HealthToRegen *= 0.04;
	//adjusts for 25 ticks of healing

	float Range = 75.0;
	float abspos[3]; 
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", abspos);
	spawnRing_Vectors(abspos, Range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 125, 1, 0.21, 5.0, 8.0, 1, 1.0);
	EmitSoundToAll("misc/halloween/spell_overheal.wav", client, _, 70,_, 0.5);	

	/*
	´ß

	*/

	StartHealingTimer(client, 0.1, HealthToRegen, 25, true);
}