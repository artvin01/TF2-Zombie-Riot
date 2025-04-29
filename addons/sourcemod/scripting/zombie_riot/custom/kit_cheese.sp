#pragma semicolon 1
#pragma newdecls required

/*
was meant to be cheese, but its plasma instead smh. 

This kit introduces the Plasmic Elemental status.
Upon reaching 100%, the target recieves massive damage based on the attacker's 
pap level and applier weapon, and is debuffed with Plasm II for 8s (bosses for 4s, raids get I for 4s instead).
Plasmic Elemental buildup is reduced by 50% on bosses and raids 
for 10/20 seconds respectively when the elemental cooldown wears off.
If applied via melee, elemental cooldown is reduced to 8s, and deals 25% more damage.

Melee - Deals damage below average and grants low resistance compared to other melees,
but has a much better health on kill stat and builds the Plasmic Elemental status much faster.
1st pap allows the user to heal off Plasmed targets with the melee, healing grows stronger with more paps.
Lethal Injection (M2 Melee Ability) temporarily increases attackspeed, 
damage and GREATLY increases melee Plasmic Elemental status buildup.
Later paps buff this ability to last a bit longer and to inflict true dmg bleed.
Plasmic Inoculation (R Melee Ability) greatly increases a random stat of the melee temporarily
(Damage, Resistance, plasmic buildup or attackspeed) and slowly heals the user overtime.
Later paps buff this ability's buffs and healing to last longer and be a bit stronger.

Primary - Shoots "plasmic balls" in quick succession, like the clockwork assault rifle from Terraria.
These projectiles build the Plasmic Elemental status much slower than the melee.
Plasmic Burst (M2 Primary Ability) - Shoots a short-ranged laser similar to the Laserstick, minus the knockback.
This laser inflicts Plasm I temporarily to enemies hit by it.
Later paps buff this ability to have a slightly larger range, less cooldown,
and allow it to inflict Plasm II instead of I for an overall longer duration.
Debuff duration is reduced by 60% against raids, and by 33% against bosses.
*/

#define SOUND_LETHAL_ABILITY "items/powerup_pickup_reflect.wav"
#define SOUND_MOCHA_ABILITY1 "items/powerup_pickup_reduced_damage.wav"
#define SOUND_MOCHA_ABILITY2 "misc/halloween/duck_pickup_pos_01.wav"
#define SOUND_CHEESEBALL_SQUASH "ui/hitsound_squasher.wav"
//#define SOUND_ELEMENTALAPPLY    "zombiesurvival/cheese_elementalapply.mp3"
#define SOUND_CHEDDAR_ABILITY  "weapons/tf2_back_scatter.wav"

static int LaserIndex;
static float Cheese_PenaltyDur[MAXENTITIES];
static float Cheese_LethalDur[MAXTF2PLAYERS];
static float Cheese_MochaBuild[MAXTF2PLAYERS];
static int Cheese_PapLevel[MAXTF2PLAYERS];

static int Cheese_Glow;
static int Cheese_BuildingHit[MAX_TARGETS_HIT];
static float Cheese_TargetsHit[MAXTF2PLAYERS];
static float Cheese_CloseDamage[MAXTF2PLAYERS];
static float Cheese_FarDamage[MAXTF2PLAYERS];
static float Cheese_MaxDistance[MAXTF2PLAYERS];
static int Cheese_BeamRadius[MAXTF2PLAYERS];
static float Cheese_BeamOffset[MAXTF2PLAYERS][3];

static Handle EffectTimer[MAXTF2PLAYERS];
static bool Precached = false;
void Cheese_MapStart()
{
	PrecacheSound(SOUND_LETHAL_ABILITY, true);
	PrecacheSound(SOUND_MOCHA_ABILITY1, true);
	PrecacheSound(SOUND_MOCHA_ABILITY2, true);
    PrecacheSound(SOUND_CHEESEBALL_SQUASH, true);
 //   PrecacheSound(SOUND_ELEMENTALAPPLY, true);
    PrecacheSound(SOUND_CHEDDAR_ABILITY, true);
    Zero(Cheese_PenaltyDur);
    Zero(Cheese_LethalDur);
    Zero(Cheese_MochaBuild);
    Zero(Cheese_PapLevel);
    LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Cheese_Glow = PrecacheModel("sprites/glow02.vmt", true);
	Precached = false;
}

void Cheese_PrecacheMusic()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/cheese_lastman.mp3",_,1);
      //  PrecacheSoundCustom("#zombiesurvival/cheese_elementalapply.mp3",_,1);
		Precached = true;
	}
}


float Cheese_GetPenaltyDuration(int entity)
{
    return Cheese_PenaltyDur[entity];
}
void Cheese_SetPenaltyDuration(int entity, float duration)
{
    Cheese_PenaltyDur[entity] = GetGameTime() + duration;
}
void Cheese_BeamEffect(float position[3], float startrad = 1.0, float endrad = 125.0, float lifetime = 0.25, float width = 6.5, bool elemental = false, int client = -1)
{
    if(elemental)
    {
        TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, 0.0, { 235, 75, 210, 65 }, 1, 0);
	TE_SendToClient(client);
    }
    else
    {
        TE_SetupBeamRingPoint(position, startrad, endrad, LaserIndex, LaserIndex, 0, 1, lifetime, width, 0.0, { 235, 75, 210, 255 }, 1, 0);
	TE_SendToAll();
    }
}
/*
void Cheese_PlaySplat(int entity)
{
    	int pitch = GetRandomInt(75, 125);
//	EmitSoundToAll(SOUND_ELEMENTALAPPLY, entity, _, _, _, _, pitch);
   // 	EmitSoundToAll(SOUND_ELEMENTALAPPLY, entity, _, _, _, _, pitch);
}

*/
void Cheese_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_MELEE || i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_PRIMARY)
	{
		if(FileNetwork_Enabled())
			Cheese_PrecacheMusic();

		delete EffectTimer[client];
		EffectTimer[client] = CreateTimer(0.5, Cheese_EffectTimer, client, TIMER_REPEAT);
	}
}

// its so fucking over
bool Is_Cheesed_Up(int client)
{
	if(EffectTimer[client] != null)
		return true;

	return false;
}

public Action Cheese_EffectTimer(Handle timer, int client)
{
	if(IsValidClient(client)) // i'd use IsClientInGame but for some reason it just breaks whenever I (samuu) use it
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1 && IsPlayerAlive(client))
		{
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_MELEE || i_CustomWeaponEquipLogic[weapon] == WEAPON_CHEESY_PRIMARY)
			{
				float pos[3]; GetClientAbsOrigin(client, pos);
				pos[2] += 5.0;
				if(LastMann)
				{
					ApplyStatusEffect(client, client, "Plasmatic Rampage", 1.0);
			                Cheese_BeamEffect(pos, 1.0, 150.0, 0.125, 12.0);
                    
					return Plugin_Continue;
				}
                		else
	               	 	{
	                    		Cheese_BeamEffect(pos, 1.0, 75.0, 0.25, 6.0, true, client);
	                	}

                		Cheese_PapLevel[client] = RoundFloat(Attributes_Get(weapon, 122, 0.0));
			}
		}

		return Plugin_Continue;
	}

	EffectTimer[client] = null;
	return Plugin_Stop;
}

public float Cheese_OnTakeDamage_Melee(int attacker, int victim, float &damage, int damagetype, int weapon)
{
	if((damagetype & DMG_CLUB))
	{   
        	if(Cheese_PapLevel[attacker] > 0)
        	{
            		if(HasSpecificBuff(victim, "Plasm I") || HasSpecificBuff(victim, "Plasm II"))
            		{
                		HealEntityGlobal(attacker, attacker, (3.0 * float(Cheese_PapLevel[attacker])), 0.0, 0.0, HEAL_SELFHEAL);
            		}   
        	}
		float cheesedmg = damage;
	        float bleed_dmg = Attributes_Get(weapon, 2, 1.0);
	        bleed_dmg *= Attributes_Get(weapon, 1, 1.0);
	
	        if(Cheese_MochaBuild[attacker] > GetGameTime())
	        {
	            cheesedmg *= 1.75;
	        }
	        if(Cheese_LethalDur[attacker] > GetGameTime())
	        {
			cheesedmg *= 2.35;
	            	if(Cheese_PapLevel[attacker] == 4)
		        	StartBleedingTimer(victim, attacker, bleed_dmg*0.75, 12, -1, DMG_TRUEDAMAGE);
	            	else if(Cheese_PapLevel[attacker] >= 5)
	        		StartBleedingTimer(victim, attacker, bleed_dmg*0.9, 26, -1, DMG_TRUEDAMAGE);
	        }
	        Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(cheesedmg * 1.5), weapon);
    	}

    	return damage;
}

void Cheese_OnTakeDamage_Primary(int attacker, int victim, float damage, int weapon)
{
    	Elemental_AddPlasmicDamage(victim, attacker, RoundToNearest(damage * 0.225), weapon);
}

public void Weapon_Kit_Cheddinator_M2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0 && Cheese_PapLevel[client] >= 2)
		{
			Rogue_OnAbilityUse(client, weapon);
		        if(Cheese_PapLevel[client] >= 4)
				Ability_Apply_Cooldown(client, slot, LastMann ? 12.0 : 20.0);
			else
				Ability_Apply_Cooldown(client, slot, LastMann ? 15.0 : 25.0);
			EmitSoundToClient(client, SOUND_CHEDDAR_ABILITY);
		//	Cheese_PlaySplat(client);

			Cheese_TargetsHit[client] = 0.0;

			float basedmg = (750.0 * Attributes_Get(weapon, 2, 1.0));
		        basedmg *= Attributes_Get(weapon, 1, 1.0);
		        Client_Shake(client, 0, 35.0, 90.0, 0.6);

		        switch(Cheese_PapLevel[client])
		        {
		                case 3:
		                {
		                    Cheese_Burst(client, basedmg, basedmg, 200.0, 10, {0.0, -6.5, 0.0});
		                }
		                case 4:
		                {
		                    Cheese_Burst(client, basedmg, basedmg, 220.0, 10, {0.0, -6.5, 0.0});
		                }
		                case 5:
		                {
		                    Cheese_Burst(client, basedmg*1.25, basedmg, 240.0, 11, {0.0, -6.5, 0.0});
		                }
		                case 6, 7, 8:
		                {
		                    Cheese_Burst(client, basedmg*1.35, basedmg*1.15, 260.0, 12, {0.0, -6.5, 0.0});
		                }
		                default:
		                {
		                    Cheese_Burst(client, basedmg, basedmg, 200.0, 10, {0.0, -6.5, 0.0});
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
			Ability_Apply_Cooldown(client, slot, LastMann ? 22.5 : 35.0);
			EmitSoundToClient(client, SOUND_LETHAL_ABILITY);

            		switch(Cheese_PapLevel[client])
            		{
                		case 2, 3:
                		{
					ApplyTempAttrib(weapon, 6, 0.7, 7.0);
					Cheese_LethalDur[client] = GetGameTime() + 7.0;
				}
				case 4, 5:
		                {
		                    	ApplyTempAttrib(weapon, 6, 0.55, 8.5);
					Cheese_LethalDur[client] = GetGameTime() + 8.5;
		                }
		                case 6, 7, 8:
		                {
		                    	ApplyTempAttrib(weapon, 6, 0.45, 10.0);
		                    	ApplyTempAttrib(weapon, 2, 1.25, 10.0);
					Cheese_LethalDur[client] = GetGameTime() + 10.0;
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
			Ability_Apply_Cooldown(client, slot, LastMann ? 40.0 : 60.0);
			EmitSoundToClient(client, SOUND_MOCHA_ABILITY1);
            		EmitSoundToClient(client, SOUND_MOCHA_ABILITY2);

		        float dmgbuff = 1.75;
		        float resbuff = 0.65;
		        float atkspdbuff = 0.75;
		        float buffdurations = 10.0;
		        float MaxHealth = float(SDKCall_GetMaxHealth(client));

		        switch(Cheese_PapLevel[client])
		        {
		                case 4:
		                {
		                    	dmgbuff = 1.9;
		                    	resbuff = 0.55;
		                    	atkspdbuff = 0.7;
		                    	HealEntityGlobal(client, client, MaxHealth * 0.20, 0.6, 5.0, HEAL_SELFHEAL);
		                }
		                case 5, 6:		
		                {
		                    	dmgbuff = 2.15;
		                   	resbuff = 0.5;
		                    	atkspdbuff = 0.6;
		                    	buffdurations = 15.0;
		                    	HealEntityGlobal(client, client, MaxHealth * 0.25, 0.75, 5.0, HEAL_SELFHEAL);
		                }
		                case 7, 8:
		                {
		                    	dmgbuff = 2.35;
		                    	resbuff = 0.4;
		                    	atkspdbuff = 0.5;
		                    	buffdurations = 20.0;
		                    	HealEntityGlobal(client, client, MaxHealth * 0.35, 1.0, 5.0, HEAL_SELFHEAL);
		                }
		                default:
		                {
		                    	HealEntityGlobal(client, client, MaxHealth * 0.15, 0.5, 5.0, HEAL_SELFHEAL);
		                }
		        }
		
		        SetDefaultHudPosition(client, 235, 75, 210, 3.0);
		        switch(GetRandomInt(1, 4))
		        {
		                case 1:
		                {
		                    	ApplyTempAttrib(weapon, 2, dmgbuff, buffdurations);
		                    	ShowSyncHudText(client, SyncHud_Notifaction, "Recieved x%.2f dmg mult for %.1fs!", dmgbuff, buffdurations);
		                }
		                case 2:
		                {
		                    	ApplyTempAttrib(weapon, 206, resbuff, buffdurations);
		                    	ApplyTempAttrib(weapon, 205, resbuff, buffdurations);
		                    	ShowSyncHudText(client, SyncHud_Notifaction, "Recieved x%.2f resist mult for %.1fs!", resbuff, buffdurations);
		                }
		                case 3:
		                {
		                    	ApplyTempAttrib(weapon, 6, atkspdbuff, buffdurations);
		                    	ShowSyncHudText(client, SyncHud_Notifaction, "Recieved x%.2f atkspd mult for %.1fs!", atkspdbuff, buffdurations);
		                }
		                case 4:
		                {
		                    	Cheese_MochaBuild[client] = GetGameTime() + buffdurations;
		                    	ShowSyncHudText(client, SyncHud_Notifaction, "Recieved faster elemental buildup for %.1fs!", buffdurations);
		                }
		        }
		
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
	float damage = 125.0;
    	damage *= WeaponDamageAttributeMultipliers(weapon);
    	damage *= Attributes_Get(weapon, 1, 1.0);
		
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

static void Cheese_Burst(int client, float damageclose, float damagefar, float distance, int radius, float offsets[3])
{
	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		Cheese_BuildingHit[building] = false;
		Cheese_TargetsHit[client] = 0.0;
	}

	Cheese_CloseDamage[client] = damageclose;
	Cheese_FarDamage[client] = damagefar;
	Cheese_MaxDistance[client] = distance;
	Cheese_BeamRadius[client] = radius;
	Cheese_BeamOffset[client][0] = offsets[0];
	Cheese_BeamOffset[client][1] = offsets[1];
	Cheese_BeamOffset[client][2] = offsets[2];
	
	TBB_Tick(client);
}

static void TBB_Tick(int client)
{
	if(!IsValidClient(client))
	{
		return;
	}

	float diameter = float(Cheese_BeamRadius[client] * 2);
	
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
		ConformLineDistance(endPoint, startPoint, endPoint, Cheese_MaxDistance[client]);
		float lineReduce = Cheese_BeamRadius[client] * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}	
		
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			Cheese_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -float(Cheese_BeamRadius[client]);
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
					float duration = 4.0;
                    			if(Cheese_PapLevel[client] >= 3)
                			duration += 1.5;
                    
                    			if(Cheese_PapLevel[client] >= 5)
                        		duration += 1.0;

			                if(b_thisNpcIsARaid[Cheese_BuildingHit[building]])
			                {
			                	duration *= 0.4;
			                }
			                else if(b_thisNpcIsABoss[Cheese_BuildingHit[building]])
			                {
			                        duration *= 0.67;
			                }
                        
                    			if(Cheese_PapLevel[client] >= 5)
                        			ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm II", duration);
                    			else
		                       		ApplyStatusEffect(client, Cheese_BuildingHit[building], "Plasm I", duration);

                    			WorldSpaceCenter(Cheese_BuildingHit[building],playerPos);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Cheese_CloseDamage[client] + (Cheese_FarDamage[client]-Cheese_CloseDamage[client]) * (distance/Cheese_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
					
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
		GetBeamDrawStartPoint(client, belowBossEyes);
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

static void GetBeamDrawStartPoint(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
	if (0.0 == Cheese_BeamOffset[client][0] && 0.0 == Cheese_BeamOffset[client][1] && 0.0 == Cheese_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Cheese_BeamOffset[client][0];
	tmp[1] = Cheese_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = Cheese_BeamOffset[client][2];
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
