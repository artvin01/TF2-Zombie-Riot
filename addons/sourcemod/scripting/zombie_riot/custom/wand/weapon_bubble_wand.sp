
#pragma semicolon 1
#pragma newdecls required

#define SOUND_BUBBLE_SHOT 	"weapons/cleaver_throw.wav"
#define SOUND_BUBBLE_EXPLODE "weapons/rocket_jumper_explode1.wav"
#define SOUND_BUBBLE_ABILITY "misc/halloween/spell_lightning_ball_cast.wav"

// don't ask why please i NEED THESE IT TOOK ME LIKE 6 HOURS
static float sf_Bubble_M2Duration[MAXPLAYERS];
static float sf_BubbleTime[MAXENTITIES];
static float sf_BubbleSpeed[MAXENTITIES];
static float sf_BubbleDamage[MAXENTITIES];
static float sf_BubbleRadius[MAXENTITIES];
static int sf_BubbleWeapon[MAXENTITIES];
static int sf_BubbleOwner[MAXENTITIES];
static int LaserIndex;

static float sf_BubbleDamageMax[MAXENTITIES];
static float sf_BubbleRadiusMax[MAXENTITIES];


void BubbleWand_MapStart()
{
	PrecacheSound(SOUND_BUBBLE_SHOT, true);
	PrecacheSound(SOUND_BUBBLE_EXPLODE, true);
	PrecacheSound(SOUND_BUBBLE_ABILITY, true);

	Zero(sf_Bubble_M2Duration);
	Zero(sf_BubbleTime);
	Zero(sf_BubbleSpeed);
	Zero(sf_BubbleDamage);
	Zero(sf_BubbleRadius);
	Zero(sf_BubbleSpeed);
	Zero(sf_BubbleWeapon);
	Zero(sf_BubbleTime);
	Zero(sf_BubbleSpeed);
	Zero(sf_BubbleDamageMax);
	Zero(sf_BubbleRadiusMax);
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
}


public void Weapon_Wand_Bubble_Wand(int client, int weapon, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 0.0));
	if(mana_cost <= Current_Mana[client])
	{
		float thetime;
		int pap = 0;
		pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		switch(pap)
		{
			case 1:
			{
				thetime = 2.6;
			}
			case 2:
			{
				thetime = 2.55;
			}
			case 3:
			{
				thetime = 2.4;
			}
			case 4:
			{
				thetime = 2.25;
			}
			default:
			{
				thetime = 2.75;
			}
		}
		SDKhooks_SetManaRegenDelayTime(client, thetime);
		Mana_Hud_Delay[client] = 0.0;

		Current_Mana[client] -= mana_cost;
		delay_hud[client] = 0.0;
		
		float damage = 350.0;

		damage *= WeaponDamageAttributeMultipliers(weapon, MULTIDMG_MAGIC_WAND);
		
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
		float time = 11000.0/speed; // 10 seconds, in case projectile speed fucks it over
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		char particle[32];
		
		Format(particle, sizeof(particle), "%s", "flaregun_energyfield_blue");

		EmitSoundToAll(SOUND_BUBBLE_SHOT, client, _, 65, _, 0.45, GetRandomInt(80, 135));
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, particle);
		int model = ApplyCustomModelToWandProjectile(projectile, "models/buildables/sentry_shield.mdl", 0.65, "", -15.0);
		SetEntProp(model, Prop_Send, "m_nSkin", 1);

		sf_BubbleTime[projectile] = GetGameTime() + time;
		sf_BubbleSpeed[projectile] = speed;
		sf_BubbleDamage[projectile] = damage;
		sf_BubbleDamageMax[projectile] = sf_BubbleDamage[projectile];
		sf_BubbleRadius[projectile] = 175.0;
		sf_BubbleRadiusMax[projectile] = sf_BubbleRadius[projectile] * 1.35;
		sf_BubbleOwner[projectile] = client;
		sf_BubbleWeapon[projectile] = weapon;
		WandProjectile_ApplyFunctionToEntity(projectile, Wand_BubbleWandTouch);

		CreateTimer(0.1, Timer_BubbleWand, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
}

public Action Timer_BubbleWand(Handle timer, int ent)
{
	int projectile = EntRefToEntIndex(ent);
	if(!IsValidEntity(projectile))
	{
		return Plugin_Stop;
	}

	if(!IsValidEntity(sf_BubbleWeapon[projectile]) || !IsValidClient(sf_BubbleOwner[projectile]))
	{
		RemoveEntity(projectile);
		return Plugin_Stop;
	}

	float startPosition[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", startPosition);

	int pap = 0;
	pap = RoundFloat(Attributes_Get(sf_BubbleWeapon[projectile], Attrib_PapNumber, 0.0)); 
	int particle = EntRefToEntIndex(i_WandParticle[projectile]);
	if(sf_BubbleTime[projectile] > GetGameTime())
	{
		if(sf_BubbleSpeed[projectile] > 10.0)
		{
			float f_BubbleAngles[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", f_BubbleAngles); //set it so it can be used

			float f_Buffer[3];
			GetAngleVectors(f_BubbleAngles, f_Buffer, NULL_VECTOR, NULL_VECTOR);

			float VelocityMod = sf_BubbleSpeed[projectile];
			
			float f_Velocity[3];
			f_Velocity[0] = f_Buffer[0] * VelocityMod;
			f_Velocity[1] = f_Buffer[1] * VelocityMod;
			f_Velocity[2] = f_Buffer[2] * VelocityMod;

			sf_BubbleSpeed[projectile] *= 0.81;
			TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, f_Velocity);

			VelocityMod *= 0.2;
			TE_SetupBeamRingPoint(startPosition, VelocityMod, VelocityMod-1.0, LaserIndex, LaserIndex, 0, 1, 0.1, 3.0, 0.1, { 75, 75, 255, 100 }, 1, 0);
			TE_SendToClient(sf_BubbleOwner[projectile]);

			float dmgmult = 1.0;
			float dmgmultrate = 1.03;
			float dmglimit = 1.5;
			switch(pap)
			{
				case 1:
				{
					dmglimit = 1.7;
					dmgmultrate = 1.0425;
				}
				case 2:
				{
					dmglimit = 1.85;
					dmgmultrate = 1.045;
				}
				case 3:
				{
					dmglimit = 2.0;
					dmgmultrate = 1.05;
				}
				case 4:
				{
					dmglimit = 2.15;
					dmgmultrate = 1.06;
				}
				default:
				{
					dmglimit = 1.55;
					dmgmultrate = 1.075;
				}
			}

			dmgmult *= dmgmultrate;
			if(dmgmult > dmglimit)
				dmgmult = dmglimit;

			sf_BubbleDamage[projectile] *= dmgmult;
			if(sf_BubbleDamage[projectile] > sf_BubbleDamageMax[projectile] * dmglimit)
				sf_BubbleDamage[projectile] = sf_BubbleDamageMax[projectile] * dmglimit;

			sf_BubbleRadius[projectile] *= 1.0215;
			if(sf_BubbleRadius[projectile] > sf_BubbleRadiusMax[projectile])
				sf_BubbleRadius[projectile] = sf_BubbleRadiusMax[projectile];

			//PrintToChatAll("Damage: %.2f | Max Damage: %.2f | Radius: %.2f", sf_BubbleDamage[projectile], sf_BubbleDamageMax[projectile] * dmglimit, sf_BubbleRadius[projectile]);
		}
		else
		{
			BubbleWand_ExplodeHere(projectile, sf_BubbleOwner[projectile], sf_BubbleWeapon[projectile], sf_BubbleDamage[projectile], startPosition, sf_BubbleRadius[projectile]);
			if(IsValidEntity(particle))
				RemoveEntity(particle);

			RemoveEntity(projectile);
		}
	}
	else
	{
		BubbleWand_ExplodeHere(projectile, sf_BubbleOwner[projectile], sf_BubbleWeapon[projectile], sf_BubbleDamage[projectile], startPosition, sf_BubbleRadius[projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);

		RemoveEntity(projectile);
	}

	return Plugin_Continue;
}

public void BubbleWand_ExplodeHere(int projectile, int owner, int weapon, float damage, float position[3], float radius)
{
	// more transparent and smaller, so people know that this projectile exploded instead of assuming it just disappeared
	TE_SetupBeamRingPoint(position, 10.0, radius*0.375, LaserIndex, LaserIndex, 0, 1, 0.35, 3.0, 0.1, { 75, 75, 255, 125 }, 1, 0);
	TE_SendToAll(0.0);

	TE_SetupBeamRingPoint(position, 10.0, radius*0.7, LaserIndex, LaserIndex, 0, 1, 0.35, 3.0, 0.1, { 75, 75, 255, 200 }, 1, 0);
	TE_SendToClient(owner);
	position[2] += 35.0;
	TE_SetupBeamRingPoint(position, 10.0, radius*0.5, LaserIndex, LaserIndex, 0, 1, 0.35, 3.0, 0.1, { 75, 75, 255, 200 }, 1, 0);
	TE_SendToClient(owner);
	position[2] -= 70.0;
	TE_SetupBeamRingPoint(position, 10.0, radius*0.5, LaserIndex, LaserIndex, 0, 1, 0.35, 3.0, 0.1, { 75, 75, 255, 255 }, 1, 0);
	TE_SendToClient(owner);

	Explode_Logic_Custom(damage, owner, owner, weapon, position, radius, _, 0.65, _, RoundToNearest(Attributes_Get(weapon, 4011, 5.0)), false, _, BubbleWand_Logic);
	EmitSoundToAll(SOUND_BUBBLE_EXPLODE, projectile, _, 75, _, 1.0, GetRandomInt(80, 120));
}

public void Weapon_Wand_Bubble_Wand_Ability(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int pap = 0;
		pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));

		// This is for the ability's mana cost to scale with mana cost modifiers
		int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 0.0));
		switch(pap)
		{
			case 2:
			{
				mana_cost = RoundToFloor(mana_cost*3.0); // 65 base -> ability costs 195 on pap 2
			}
			case 3:
			{
				mana_cost = RoundToFloor(mana_cost*3.0); // 75/100 base -> ability costs 225/300 on pap 3/4 respectively
			}
			case 4:
			{

			}
		}

		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0 && !HasSpecificBuff(client, "Bubble Frenzy"))
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 37.5);
				EmitSoundToClient(client, SOUND_BUBBLE_ABILITY);

				ApplyStatusEffect(client, client, "Bubble Frenzy", 10.0);
				ApplyTempAttrib(weapon, 6, 0.65, 10.0);
				ApplyTempAttrib(weapon, 733, 0.65, 10.0);
				ApplyTempAttrib(weapon, 410, 0.85, 10.0);
				//dont allow the player to use this and then switch weapons
				//inacse of tonic and etc, its not a problem as its supposed to be mixed, i.e. group buff
				//in this case its a free damage buff that can be spammed alot
				//some buffs just gotta be like this.
				sf_Bubble_M2Duration[client] = GetGameTime() + 10.0;

				float position[3];
				GetClientAbsOrigin(client, position);
				position[2] += 36.0;
				TE_SetupBeamRingPoint(position, 600.0, 10.0, LaserIndex, LaserIndex, 0, 1, 0.25, 3.0, 0.1, { 50, 50, 255, 200 }, 1, 0);
				TE_SendToAll(0.0);
				position[2] -= 12.0;
				TE_SetupBeamRingPoint(position, 500.0, 10.0, LaserIndex, LaserIndex, 0, 1, 0.25, 3.0, 0.1, { 63, 63, 255, 200 }, 1, 0);
				TE_SendToAll(0.0);
				position[2] -= 12.0;
				TE_SetupBeamRingPoint(position, 400.0, 10.0, LaserIndex, LaserIndex, 0, 1, 0.25, 3.0, 0.1, { 75, 75, 255, 200 }, 1, 0);
				TE_SendToAll(0.0);
				
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				Mana_Hud_Delay[client] = 0.0;
				Current_Mana[client] -= mana_cost;
				delay_hud[client] = 0.0;
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
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			return;
		}
	}
}

public void BubbleWand_Logic(int entity, int enemy, float damage, int weapon)
{
	if (!IsValidEntity(enemy) || !IsValidEntity(entity))
		return;

	if(enemy)
	{
		if(enemy <= MaxClients)
			return;
		
		if(GetTeam(enemy) == TFTeam_Red)
			return;
	}

	if(HasSpecificBuff(enemy, "Hardened Aura"))
	{
		return;
	}

	int pap = 0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	float time = 4.0;
	switch(pap)
	{
		case 3:
		{
			time = 6.0;
		}
		case 4:
		{
			time = 8.0;
		}
	}

	if(sf_Bubble_M2Duration[entity] > GetGameTime())
	{
		if(b_thisNpcIsABoss[enemy] || b_StaticNPC[enemy] || b_thisNpcIsARaid[enemy])
		{
			time /= 1.5;
		}

		if(pap <= 3)
		{
			ApplyStatusEffect(entity, enemy, "Soggy", time);
		}
		else
		{
			ApplyStatusEffect(entity, enemy, "Soggiest", time);
		}
	}
	else
	{
		if(b_thisNpcIsARaid[enemy])
		{
			time /= 4.0; // quarter of its duration on raids
			if(pap <= 3)
			{
				ApplyStatusEffect(entity, enemy, "Soggy", time);
			}
			else
			{
				ApplyStatusEffect(entity, enemy, "Soggiest", time);
			}
		}
	}
}

public void Wand_BubbleWandTouch(int entity, int target)
{
	bool explode = false;
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		explode = true;
	}
	else if(target == 0)
	{
		explode = true;
	}

	if(explode)
	{
		float startPosition[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition);
		BubbleWand_ExplodeHere(entity, sf_BubbleOwner[entity], sf_BubbleWeapon[entity], sf_BubbleDamage[entity], startPosition, sf_BubbleRadius[entity]);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}


