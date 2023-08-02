#define SPECTER_DAMAGE_1	"ambient/sawblade_impact1.wav"
#define SPECTER_DAMAGE_2	"ambient/sawblade_impact2.wav"
#define SPECTER_BONEFRACTURE	"misc/halloween/hwn_wheel_of_fate.wav"
#define SPECTER_SURVIVEUSE	"items/powerup_pickup_strength.wav"
#define SPECTER_SURVIVEHIT	"items/powerup_pickup_knockout_melee_hit.wav"
#define SPECTER_SINGING		"player/taunt_medic_heroic.wav"	// 5 seconds
#define SPECTER_CHARGED		"ui/halloween_boss_escape_ten.wav"

#define SPECTER_BONE_FRACTURE_DURATION				8.0
#define SPECTER_AOE_HIT_RANGE						100.0
#define SPECTER_MAXCHARGE							100
#define SPECTER_DEAD_RANGE							350.0
#define SPECTER_DAMAGE_FALLOFF_PER_ENEMY			1.1

#define SPECTER_THREE	(1 << 0)
#define SPECTER_REVIVE	(1 << 1)

static float SpecterExpireIn[MAXTF2PLAYERS];
static int SpecterCharge[MAXTF2PLAYERS];
static float SpecterSurviveFor[MAXTF2PLAYERS];
Handle h_TimerSpecterAlterManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_SpecterAlterhuddelay[MAXPLAYERS+1]={0.0, ...};
static float f_SpecterDeadDamage[MAXPLAYERS+1]={0.0, ...};
static float f_SpecterDyingTime[MAXPLAYERS+1]={0.0, ...};
static int i_SpecterExtraHitsNeeded[MAXPLAYERS+1]={0, ...};


int SpecterMaxCharge(int client)
{
	int charges = SPECTER_MAXCHARGE;
	charges += i_SpecterExtraHitsNeeded[client];

	return charges;
}
void Specter_AbilitiesWaveEnd()
{
	Zero(i_SpecterExtraHitsNeeded);
}
void Specter_MapStart()
{
	PrecacheSound(SPECTER_DAMAGE_1);
	PrecacheSound(SPECTER_DAMAGE_2);
	PrecacheSound(SPECTER_SINGING);
	PrecacheSound(SPECTER_SURVIVEHIT);
	Zero(h_TimerSpecterAlterManagement);
	Zero(f_SpecterDyingTime);
	Zero(f_SpecterAlterhuddelay);
	Zero(f_SpecterDeadDamage);
	Zero(SpecterExpireIn);

	Zero(SpecterSurviveFor);
	Zero(i_SpecterExtraHitsNeeded);
}

void PlayCustomSoundSpecter(int client)
{
	if(SpecterSurviveFor[client] > GetGameTime())
	{
		bool rand = view_as<bool>(GetURandomInt() % 2);
		int pitch = GetRandomInt(65,75);
		EmitSoundToAll(rand ? SPECTER_DAMAGE_1 : SPECTER_DAMAGE_2, client, SNDCHAN_AUTO, 75,_,0.8,pitch);
//		EmitSoundToAll(rand ? SPECTER_DAMAGE_1 : SPECTER_DAMAGE_2, client, SNDCHAN_AUTO, 80,_,_,pitch);
//		EmitSoundToAll(SPECTER_SURVIVEHIT, client, SNDCHAN_AUTO, 80);
	}
	else
	{
		bool rand = view_as<bool>(GetURandomInt() % 2);
		int pitch = GetRandomInt(95,105);
		EmitSoundToAll(rand ? SPECTER_DAMAGE_1 : SPECTER_DAMAGE_2, client, SNDCHAN_AUTO, 75,_,0.8,pitch);
	}
}

static int Specter_GetSpecterFlags(int weapon)
{
	int flags = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	
	return flags;
}

stock void Specter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{

	int flags = Specter_GetSpecterFlags(weapon);
	float gameTime = GetGameTime();
	bool survival = SpecterSurviveFor[attacker] > gameTime;
	if(b_thisNpcIsARaid[victim])
	{
		damage *= 1.25;
	}
	if(survival)
	{
		int health = GetClientHealth(attacker);
		int maxhealth = SDKCall_GetMaxHealth(attacker);
		float attackerHealthRatio = float(health) / float(maxhealth);
		float victimHealthRatio = float(GetEntProp(victim, Prop_Data, "m_iHealth")) / float(GetEntProp(victim, Prop_Data, "m_iMaxHealth"));
		
		if(victimHealthRatio < attackerHealthRatio)
		{
			// If victim has less health %, self damage (1.5% of max health)
			health -= maxhealth * 3 / 200;
			if(health < 1)
				health = 1;
			
			SetEntityHealth(attacker, health);
		}
		else
		{
			// If victim has more health %, bonus damage (+70% damage)
			damage *= 1.7;
			DisplayCritAboveNpc(victim, attacker, false);
			if((flags & SPECTER_REVIVE) &&  dieingstate[attacker] < 1 && SpecterCharge[attacker] < SpecterMaxCharge(attacker))
				SpecterCharge[attacker] += 5;
		}
	}
	else if((flags & SPECTER_REVIVE) && dieingstate[attacker] < 1 && SpecterCharge[attacker] < SpecterMaxCharge(attacker))
	{
		SpecterCharge[attacker]++;
	}


	if((flags & SPECTER_REVIVE) && dieingstate[attacker] < 1)
	{
		SpecterCharge[attacker]++;
		SpecterExpireIn[attacker] = gameTime + 30.0;

		if(CvarInfiniteCash.BoolValue)
			SpecterCharge[attacker] = SpecterMaxCharge(attacker);
	}

	if(SpecterCharge[attacker] > SpecterMaxCharge(attacker))
	{
		SpecterCharge[attacker] = SpecterMaxCharge(attacker);
	}
}

int SpecterHowManyEnemiesHit(int client, int weapon)
{
	bool survival = SpecterSurviveFor[client] > GetGameTime();
	int flags = Specter_GetSpecterFlags(weapon);

	return (survival ? 4 : ((flags & SPECTER_THREE) ? 3 : 2));
}

public void Weapon_SpecterBone(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		ClientCommand(client, "playgamesound %s", SPECTER_BONEFRACTURE);

		TF2_AddCondition(client, TFCond_MegaHeal, SPECTER_BONE_FRACTURE_DURATION);
		TF2_AddCondition(client, TFCond_NoHealingDamageBuff, SPECTER_BONE_FRACTURE_DURATION);
		MakePlayerGiveResponseVoice(client, 1); //haha!

		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			ApplyTempAttrib(weapon, 412, 0.25, SPECTER_BONE_FRACTURE_DURATION);
		}
		else
		{
			TF2_AddCondition(client, TFCond_UberchargedHidden, SPECTER_BONE_FRACTURE_DURATION);
			CreateTimer(0.1, Specter_DrainTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		ApplyTempAttrib(weapon, 6, 0.40,SPECTER_BONE_FRACTURE_DURATION);
	//	ApplyTempAttrib(weapon, 2, 0.75,SPECTER_BONE_FRACTURE_DURATION);
		
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "eyeglow_R", flPos, flAng);				
		int particle_Hand = ParticleEffectAt(flPos, "utaunt_glowyplayer_orange_sparks", SPECTER_BONE_FRACTURE_DURATION);
		SetParent(client, particle_Hand, "eyeglow_R");

		CreateTimer(SPECTER_BONE_FRACTURE_DURATION - 0.15, Specter_BoneTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		Ability_Apply_Cooldown(client, slot, CvarInfiniteCash.BoolValue ? SPECTER_BONE_FRACTURE_DURATION : 106.6);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}

public Action Specter_DrainTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(IsPlayerAlive(client) && TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden))
		{
			int health = GetClientHealth(client) * 9 / 10;
			if(health < 1)
				health = 1;
			
			SetEntityHealth(client, health);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action Specter_BoneTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		TF2_RemoveCondition(client, TFCond_MegaHeal);
		TF2_RemoveCondition(client, TFCond_UberchargedHidden);
		TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
		f_ImmuneToFalldamage[client] = GetGameTime() + 5.0;
		if(!dieingstate[client])
			SetEntityHealth(client, 1);
		
		TF2_StunPlayer(client, 1.0, 0.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_SOUND, 0);
		StopSound(client, SNDCHAN_STATIC, "player/pl_impact_stun.wav");
	}
	return Plugin_Stop;
}

public void Weapon_SpecterSurvive(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		ClientCommand(client, "playgamesound %s", SPECTER_SURVIVEUSE);
		ClientCommand(client, "playgamesound %s", SPECTER_SURVIVEUSE);

		SpecterSurviveFor[client] = GetGameTime() + 9.8;

		ApplyTempAttrib(weapon, 2, 3.6, 10.0);
		ApplyTempAttrib(weapon, 6, 2.0, 10.0);
		ApplyTempAttrib(weapon, 412, 0.333, 10.0);
		ApplyTempAttrib(weapon, 740, 0.333, 10.0);
		Ability_Apply_Cooldown(client, slot, CvarInfiniteCash.BoolValue ? 11.0 : 109.8);
		
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "eyeglow_R", flPos, flAng);				
		int particle_Hand = ParticleEffectAt(flPos, "critical_rocket_redsparks", 10.0);
		SetParent(client, particle_Hand, "eyeglow_R");
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}
/*
public Action Specter_ReviveTimer(Handle timer, int client)
{
	if(SpecterCharge[client] < 60 && SpecterExpireIn[client] < GetGameTime())
	{
		SpecterCharge[client]--;
		SpecterExpireIn[client] = GetGameTime() + 5.0;
	}

	bool endTimer;
	if(SpecterCharge[client] < 1 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		endTimer = true;
	}
	else if(dieingstate[client] > 159 || (dieingstate[client] > 0 && !b_LeftForDead[client]))
	{
		if(SpecterCharge[client] > 59)
		{
			ClientCommand(client, "playgamesound %s", SPECTER_SINGING);
			ClientCommand(client, "playgamesound %s", SPECTER_SINGING);

			b_LeftForDead[client] = true;
			dieingstate[client] = 159; // 5 seconds
			i_AmountDowned[client]--;
			SpecterCharge[client] -= 60;
			endTimer = true;

			PrintHintText(client, "Specter Revive Activated");
		}
	}
	else
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1 && weapon == WEAPON_SPECTER)
		{
			PrintHintText(client, "Specter Revive [%d / 60]", SpecterCharge[client]);
			StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
		}
	}

	if(!endTimer)
		return Plugin_Continue;
	
	SpecterExpireIn[client] = 0.0;
	SpecterCharge[client] = 0;
	return Plugin_Stop;
}
*/



public void Kill_Timer_SpecterAlter(int client)
{
	if (h_TimerSpecterAlterManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerSpecterAlterManagement[client]);
		h_TimerSpecterAlterManagement[client] = INVALID_HANDLE;
		f_SpecterDeadDamage[client] = 0.0;
	}
}

bool SpecterCheckIfAutoRevive(int client)
{
	if(SpecterCharge[client] >= SpecterMaxCharge(client))
	{
		if(f_SpecterDeadDamage[client] == 0.0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	return false;
}

public void SpecterAlter_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SPECTER) //Double check to see if its good or bad :(
		{	
			if(f_SpecterAlterhuddelay[client] < GetGameTime())
			{
				f_SpecterAlterhuddelay[client] = GetGameTime() + 0.5;
				if(SpecterCharge[client] < SpecterMaxCharge(client) && SpecterExpireIn[client] < GetGameTime())
				{
					SpecterCharge[client]--;
					SpecterExpireIn[client] = GetGameTime() + 5.0;
				}
				if(SpecterCharge[client] < 0)
				{
					SpecterCharge[client] = 0;
				}
				if(dieingstate[client] > 159 || (dieingstate[client] > 0 && !b_LeftForDead[client]))
				{
					if(SpecterCharge[client] >= SpecterMaxCharge(client))
					{
						float flPos[3];
						GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
						int particle_Sing = ParticleEffectAt(flPos, "utaunt_arcane_purple_parent", 5.0);
						//cant use utaunt_lavalamp_green_parent, stays infinitly.
						SetParent(client, particle_Sing);
						ClientCommand(client, "playgamesound %s", SPECTER_SINGING);
						ClientCommand(client, "playgamesound %s", SPECTER_SINGING);
						KillDyingGlowEffect(client);

						b_LeftForDead[client] = true;
						dieingstate[client] = 159; // 5 seconds
						i_AmountDowned[client]--;
						SpecterCharge[client] -= SpecterMaxCharge(client);
						i_SpecterExtraHitsNeeded[client] += 30;

						PrintHintText(client, "Specter Revive Activated");
						f_SpecterDyingTime[client] = GetGameTime() + 6.0;
					}
				}

				if(dieingstate[client] > 0)
				{
					if(SpecterCharge[client] < SpecterMaxCharge(client))
					{
						if(f_SpecterDyingTime[client] > GetGameTime())
						{
							//When dead, you deal way less damage, buff this.
							//This will count as ranged damage.
							float flPos[3];
							GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

							flPos[2] += 45.0;

							i_ExplosiveProjectileHexArray[weapon] = 0;
							i_ExplosiveProjectileHexArray[weapon] |= EP_DEALS_CLUB_DAMAGE;
							Explode_Logic_Custom(f_SpecterDeadDamage[client] * 4.0, client, weapon, weapon, flPos, SPECTER_DEAD_RANGE, SPECTER_DAMAGE_FALLOFF_PER_ENEMY, _, _, 10);
							//Bleed sucks but thats on purpose
		
							float vecTarget[3];
							for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
							{
								int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
								if (IsValidEntity(baseboss_index))
								{
									vecTarget = WorldSpaceCenter(baseboss_index);
									
									float flDistanceToTarget = GetVectorDistance(flPos, vecTarget, true);
									if(flDistanceToTarget < (SPECTER_DEAD_RANGE * SPECTER_DEAD_RANGE))
									{
										f_SpecterDyingDebuff[baseboss_index] = GetGameTime() + 1.0;
									}
								}
							}
						}
					}
					return;
				}
				else
				{
					if(f_SpecterDyingTime[client] > GetGameTime())
					{
						f_SpecterDyingTime[client] = 0.0;
						int maxhealth = SDKCall_GetMaxHealth(client);
						ApplyHealEvent(client, maxhealth / 2);
						SetEntityHealth(client, maxhealth / 2); //Heal the client to half of their max health after being revived, otherwise this revive makes no sense.
					}
				}
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					PrintHintText(client, "Specter Revive [%d / %i]", SpecterCharge[client], SpecterMaxCharge(client));
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
				}
			}
		}
		else
		{
			Kill_Timer_SpecterAlter(client);
		}
	}
	else
	{
		Kill_Timer_SpecterAlter(client);
	}
}

public Action Timer_Management_SpecterAlter(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				SpecterAlter_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_SpecterAlter(client);
		}
		else
			Kill_Timer_SpecterAlter(client);
	}
	else
		Kill_Timer_SpecterAlter(client);
		
	return Plugin_Continue;
}

public void Enable_SpecterAlter(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SPECTER)
	{
		float damage = 65.0;

		damage *= Attributes_Get(weapon, 1, 1.0);

		damage *= Attributes_Get(weapon, 2, 1.0);

		f_SpecterDeadDamage[client] = damage;
		int flags = Specter_GetSpecterFlags(weapon);
		if(flags & SPECTER_REVIVE)
		{
			delete h_TimerSpecterAlterManagement[client];

			DataPack pack;
			h_TimerSpecterAlterManagement[client] = CreateDataTimer(0.1, Timer_Management_SpecterAlter, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}

	if(i_WeaponArchetype[weapon] == 22)	// Abyssal Hunter
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerSpecterAlterManagement[i])
			{
				Attributes_Set(weapon, 26, 200.0);
				break;
			}
		}
	}
}


void SpecterResetHudTime(int client)
{
	f_SpecterAlterhuddelay[client] = 0.0;
}