#pragma semicolon 1
#pragma newdecls required

//Do you think i have time to use the bathroom?
//If you need to sneeze, do it now
#define MAX_TARGETS_HIT_RIOT 10 //Dont hit more then 5.

//same as melee for now. but abit more fat
#define RIOT_MAX_RANGE 150
#define RIOT_MAX_BOUNDS 45.0

static int ShieldModel;
static int ViewmodelRef[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int WearableRef[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int RIOT_EnemiesHit[MAX_TARGETS_HIT_RIOT];
static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};

#define SOUND_RIOTSHIELD_ACTIVATION "weapons/air_burster_explode1.wav"

void Weapon_RiotShield_Map_Precache()
{
	Zero(f_AniSoundSpam);
	PrecacheSound(SOUND_RIOTSHIELD_ACTIVATION);
	ShieldModel = PrecacheModel("models/player/items/sniper/knife_shield.mdl");
}

public void Weapon_RiotShield_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_RiotShield_M2_Base(client, weapon, slot, 0);
}

public void Weapon_RiotShield_M2_PaP(int client, int weapon, bool crit, int slot)
{
	Weapon_RiotShield_M2_Base(client, weapon, slot, 1);
}

public void Weapon_RiotShield_M2_Alt(int client, int weapon, bool crit, int slot)
{
	Weapon_RiotShield_M2_Base(client, weapon, slot, 2);
}

static void Weapon_RiotShield_M2_Base(int client, int weapon, int slot, int pap)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		static float hullMin[3]; hullMin = view_as<float>({-RIOT_MAX_BOUNDS, -RIOT_MAX_BOUNDS, -RIOT_MAX_BOUNDS});
		static float hullMax[3]; hullMax = view_as<float>({RIOT_MAX_BOUNDS, RIOT_MAX_BOUNDS, RIOT_MAX_BOUNDS});

		float fPos[3];
		float fAng[3];
		float endPoint[3];
		float fPosForward[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		
		GetAngleVectors(fAng, fPosForward, NULL_VECTOR, NULL_VECTOR);
		
		endPoint[0] = fPos[0] + fPosForward[0] * RIOT_MAX_RANGE;
		endPoint[1] = fPos[1] + fPosForward[1] * RIOT_MAX_RANGE;
		endPoint[2] = fPos[2] + fPosForward[2] * RIOT_MAX_RANGE;

		bool find = false;
		
		for (int enemy_reset = 1; enemy_reset < MAX_TARGETS_HIT_RIOT; enemy_reset++)
		{
			RIOT_EnemiesHit[enemy_reset] = false;
		}

		Handle trace;

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		trace = TR_TraceHullFilterEx(fPos, endPoint, hullMin, hullMax, 1073741824, Shield_TraceTargets, client);	// 1073741824 is CONTENTS_LADDER?
		CloseHandle(trace);
		FinishLagCompensation_Base_boss();

		bool RaidActive = false;

		if(RaidbossIgnoreBuildingsLogic(1))
			RaidActive = true;

		for (int enemy_hit = 0; enemy_hit < MAX_TARGETS_HIT; enemy_hit++)
		{
			if (RIOT_EnemiesHit[enemy_hit])
			{
				if(IsValidEntity(RIOT_EnemiesHit[enemy_hit]))
				{
					find = true;

					float Duration_Stun = 1.0;
					float Duration_Stun_Boss = 0.5;

					if(pap == 1)
					{
						Duration_Stun = 1.5;
						Duration_Stun_Boss = 0.75;
					}

					if(!b_thisNpcIsABoss[RIOT_EnemiesHit[enemy_hit]] && !RaidActive)
					{
						FreezeNpcInTime(RIOT_EnemiesHit[enemy_hit],Duration_Stun);
					}
					else
					{
						FreezeNpcInTime(RIOT_EnemiesHit[enemy_hit],Duration_Stun_Boss);
					}
					//PrintToChatAll("boom! %i",RIOT_EnemiesHit[enemy_hit]);
				}
			}
		}

		if(find)
		{
			Rogue_OnAbilityUse(client, weapon);
			//Boom! Do effects and buff weapon!

			if(pap == 2)
			{
				ApplyTempAttrib(weapon, 2, 1.35, 5.0);
				ApplyTempAttrib(weapon, 6, 2.0, 5.0);
				ApplyTempAttrib(weapon, 45, 3.0, 5.0);
			}
			else
			{
				ApplyTempAttrib(weapon, 6, 0.25, 3.0); //Make them attack WAY faster.
			}

			EmitSoundToAll(SOUND_RIOTSHIELD_ACTIVATION, client, SNDCHAN_STATIC, 80, _, 0.9);

			float ClientAng[3];
			float ClientPos[3];
			GetAttachment(client, "effect_hand_l", ClientPos, ClientAng);
				
			int particle = ParticleEffectAt(ClientPos, "mvm_loot_dustup2", 0.5);
					
			SetParent(client, particle, "effect_hand_l");

			TE_Particle("mvm_soldier_shockwave", ClientPos, NULL_VECTOR, ClientAng, -1, _, _, _, _, _, _, _, _, _, 0.0);

			TeleportEntity(particle, NULL_VECTOR,fAng,NULL_VECTOR);

			float cooldownAbility = 25.0;
			if(pap == 1)
			{
				cooldownAbility = 25.0;
			}
			else
			{
				cooldownAbility = 35.0;
			}

			if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
			{
				cooldownAbility *= 0.65;
			}

			Ability_Apply_Cooldown(client, slot, cooldownAbility);
		}
		else
		{
			//There was no-one to Kapow :(
			ClientCommand(client, "playgamesound items/medshotno1.wav");
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
	}
}

public void Weapon_RiotShield_Deploy(int client, int weapon)
{
	int entity = CreateEntityByName("prop_dynamic");
	if(entity != -1)
	{
		DispatchKeyValue(entity, "model", "models/player/items/sniper/knife_shield.mdl");
		DispatchKeyValue(entity, "disablereceiveshadows", "0");
		DispatchKeyValue(entity, "disableshadows", "1");
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		
		float pos[3], ang[3];
		GetClientAbsOrigin(client, pos);
		GetClientAbsAngles(client, ang);
		
		float offset = ang[1];
		if(offset > 90.0)
		{
			offset = 180.0 - offset;
		}
		else if(offset < -90.0)
		{
			offset = -180.0 - offset;
		}
		
		pos[0] -= 15.0 * offset / 90.0;
		pos[1] += 15.0 * (90.0 - fabs(ang[1])) / 90.0;
		pos[2] -= 72.5;
		ang[1] += 180.0;
		ang[2] = 1.5;
		
		TeleportEntity(entity, pos, ang, NULL_VECTOR);
		DispatchSpawn(entity);
		
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));
		
		SDKHook(entity, SDKHook_SetTransmit, FirstPersonTransmit);

		ViewmodelRef[client] = EntIndexToEntRef(entity);
		
		entity = CreateEntityByName("tf_wearable");
		if(entity != -1)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndex", ShieldModel);
			
			DispatchSpawn(entity);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			
			WearableRef[client] = EntIndexToEntRef(entity);
			SDKCall_EquipWearable(client, entity);
			
			SetEntProp(entity, Prop_Send, "m_fEffects", 0);
			
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", weapon);
			
			pos[0] = 0.0;
			pos[1] = 7.5;
			pos[2] = -60.0;
			ang[1] = 180.0;
			ang[2] = 1.5;
			TeleportEntity(entity, pos, ang, NULL_VECTOR);

			SDKHook(entity, SDKHook_SetTransmit, ThirdPersonTransmit);
		}
	}
}

public void Weapon_RiotShield_Holster(int client)
{
	int entity = EntRefToEntIndex(ViewmodelRef[client]);
	if(entity != INVALID_ENT_REFERENCE)
		RemoveEntity(entity);
	
	ViewmodelRef[client] = INVALID_ENT_REFERENCE;

	entity = EntRefToEntIndex(WearableRef[client]);
	if(entity != INVALID_ENT_REFERENCE)
		TF2_RemoveWearable(client, entity);
	
	WearableRef[client] = INVALID_ENT_REFERENCE;
	
}

public Action FirstPersonTransmit(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(owner == -1)
		{
			RemoveEntity(owner);
			return Plugin_Stop;
		}

		if(Armor_Charge[owner] < 1)
		{
			return Plugin_Stop;
		}
		else if(owner == client)
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Taunting) || GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
				return Plugin_Stop;
		}
		else if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != owner || GetEntProp(client, Prop_Send, "m_iObserverMode") != 4)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action ThirdPersonTransmit(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(owner == -1)
		{
			RemoveEntity(owner);
			return Plugin_Stop;
		}

		if(Armor_Charge[owner] < 1)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

static bool Shield_TraceTargets(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsValidEntity(entity))
	{
		if(0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));
			
			if (((b_ThisWasAnNpc[entity] && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
			{
				for(int i=1; i <= (MAX_TARGETS_HIT_RIOT -1 ); i++)
				{
					if(!RIOT_EnemiesHit[i])
					{
						RIOT_EnemiesHit[i] = entity;
						break;
					}
				}
			}
			
		}
	}
	return false;
}

//taken and edited from ff2_sarysapub3
public float Player_OnTakeDamage_Riot_Shield(int victim, float &damage, int attacker, int weapon, float damagePosition[3], int damagetype)
{
	/*
		Because the hud checks this every so ofte, we can use this as a pseudo Timer,

	*/
	if(Armor_Charge[victim] <= 0)
	{
		if(i_NextAttackDoubleHit[weapon])
		{
			Attributes_SetMulti(weapon, 54, (1.0 / 0.95));
			SDKCall_SetSpeed(victim);
		}

		i_NextAttackDoubleHit[weapon] = false;
	}
	else
	{
		if(!i_NextAttackDoubleHit[weapon])
		{
			Attributes_SetMulti(weapon, 54, 0.95);
			SDKCall_SetSpeed(victim);
		}
			
		i_NextAttackDoubleHit[weapon] = true;
	}
	if(CheckInHud())
	{
		return damage;
	}
	// Require armor charge
	if(Armor_Charge[victim] < 1)
		return damage;

	if(damagetype & DMG_TRUEDAMAGE)
		return damage;

	
	// need position of either the inflictor or the attacker
	float actualDamagePos[3];
	float victimPos[3];
	float angle[3];
	float eyeAngles[3];
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);

	bool BlockAnyways = false;
	if(!damagePosition[0]) //Make sure if it doesnt
	{
		if(IsValidEntity(attacker))
		{
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", actualDamagePos);

		}
		else
		{
			BlockAnyways = true;
		}

	}
	else
	{
		actualDamagePos = damagePosition;
	}

	GetVectorAnglesTwoPoints(victimPos, actualDamagePos, angle);
	GetClientEyeAngles(victim, eyeAngles);


	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;
		
	// now it's a simple check
	if ((yawOffset >= MINYAW_RAID_SHIELD && yawOffset <= MAXYAW_RAID_SHIELD) || BlockAnyways)
	{
		float resist = (b_thisNpcIsARaid[attacker] || b_thisNpcIsABoss[attacker]) ? 0.65 : 0.45;
		int HalfarmorValue = MaxArmorCalculation(Armor_Level[victim], victim, 0.5);
		if(Armor_Charge[victim] < HalfarmorValue)
		{
			float ResistLeft = float(Armor_Charge[victim]) / float(HalfarmorValue);
			//invert resistance.
			resist *= -1.0;
			resist += 1.0;
			//do calcs
			resist *= ResistLeft;

			//invert it again.
			resist *= -1.0;
			resist += 1.0;

		}

		damage *= resist;
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;

			if(Attributes_Get(weapon, 868, 0.0))	// Alt Pap, Cooldown Reduction
			{
				ClientCommand(victim, "playgamesound ambient/energy/spark%d.wav", 1 + (GetURandomInt() % 6));
				Saga_ChargeReduction(victim, weapon, 0.5);

				int ally = GetClosestAlly(victim, 100000.0, victim, Saga_ChargeValidityFunction);
				if(ally > 0)
				{
					ClientCommand(ally, "playgamesound ambient/energy/spark%d.wav", 1 + (GetURandomInt() % 6));

					int i, other;
					while(TF2_GetItem(ally, other, i))
					{
						Saga_ChargeReduction(ally, other, 0.5);
					}
				}
			}
			else
			{
				ClientCommand(victim, "playgamesound Wood_Box.BulletImpact");
			}
		}
	}

	return damage;
}

