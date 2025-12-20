#pragma semicolon 1
#pragma newdecls required

#define SOLDINE_MAX_MELEE_CHARGE 35.0
#define SOLDINE_MAX_ROCKETJUMP_CHARGE 65.0
#define SOLDINE_ROCKET_JUMP_DURATION_MAX 2.0

static Handle Soldine_Timer[MAXPLAYERS] = {null, ...};
static bool Precached;
float Soldine_HudDelay[MAXPLAYERS+1];
static int ParticleRef[MAXPLAYERS+1];
static int i_PaPLevel[MAXPLAYERS+1];
static float i_SoldineMeleeCharge[MAXPLAYERS+1];
static float i_SoldineRocketjumpCharge[MAXPLAYERS+1];
static float f_SoldineRocketJumpDuration[MAXPLAYERS+1];
static int i_ParticleMeleeHit[MAXPLAYERS+1];
static bool b_DisableSuperJump[MAXPLAYERS+1];


/*
	Pap 1: Unlocks melee charge
	Pap 2: Unlocks Rocket Jump Charge
	Pap 3: Makes both chrage faster, Melee Heals
	Pap 4: Makes both charge faster, 
	rest is just more stats
*/
public void Wkit_Soldin_OnMapStart()
{
	Precached = false;
	Zero(i_SoldineMeleeCharge);
	Zero(i_SoldineRocketjumpCharge);
	Zero(f_SoldineRocketJumpDuration);
	Zero(Soldine_HudDelay);
	Zero(b_DisableSuperJump);
}

void ChargeSoldineMeleeHit(int client, int victim, bool Melee, float Multi = 1.0)
{
	if(i_PaPLevel[client] < 1)
	{
		return;
	}
	float MeleeChargeDo = 1.0;
	
	if(Melee)
		MeleeChargeDo *= 2.0;
	else
	{
		if(!b_thisNpcIsARaid[victim])
			MeleeChargeDo *= 0.75;
	}

	if(i_PaPLevel[client] >= 3)
		MeleeChargeDo *= 1.1;

	if(i_PaPLevel[client] >= 4)
		MeleeChargeDo *= 1.1;

	if(LastMann)
	{
		MeleeChargeDo *= 1.5;
	}

	MeleeChargeDo *= Multi;

	i_SoldineMeleeCharge[client] += MeleeChargeDo;

	if(i_SoldineMeleeCharge[client] > SOLDINE_MAX_MELEE_CHARGE)
		i_SoldineMeleeCharge[client] = SOLDINE_MAX_MELEE_CHARGE;
}

bool Wkit_Soldin_LastMann(int client)
{
	bool SoldinTHEME=false;
	if(Soldine_Timer[client] != null)
	{
		if(i_PaPLevel[client] >= 1)
			SoldinTHEME = true;
	}
	return SoldinTHEME;
}

bool Wkit_Soldin_BvB(int client)
{
	return Soldine_Timer[client] != null;
}

bool CanSelfHurtAndJump(int client)
{
	if(i_SoldineRocketjumpCharge[client] >= SOLDINE_MAX_ROCKETJUMP_CHARGE && !b_DisableSuperJump[client] && i_PaPLevel[client] >= 2)
	{
		return true;
	}
	return false;
}

void ChargeSoldineRocketJump(int client, int victim, bool Melee, float Multi = 1.0)
{
	if(i_PaPLevel[client] < 2)
	{
		return;
	}
	float MeleeChargeDo = 1.0;
	
	if(Melee)
		MeleeChargeDo *= 2.0;
	else
	{
		if(!b_thisNpcIsARaid[victim])
			MeleeChargeDo *= 0.75;
	}

	if(i_PaPLevel[client] >= 3)
		MeleeChargeDo *= 1.1;

	if(i_PaPLevel[client] >= 4)
		MeleeChargeDo *= 1.1;

	if(LastMann)
	{
		MeleeChargeDo *= 1.5;
	}

	MeleeChargeDo *= Multi;

	i_SoldineRocketjumpCharge[client] += MeleeChargeDo;

	if(i_SoldineRocketjumpCharge[client] > SOLDINE_MAX_ROCKETJUMP_CHARGE)
		i_SoldineRocketjumpCharge[client] = SOLDINE_MAX_ROCKETJUMP_CHARGE;
}

public void Wkit_Soldin_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PROTOTYPE) //
	{
		if (Soldine_Timer[client] != null)
		{
			delete Soldine_Timer[client];
			Soldine_Timer[client] = null;
		}
		i_PaPLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		DataPack pack;
		Soldine_Timer[client] = CreateDataTimer(0.1, Timer_Soldine_Kit, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));

		Soldine_EyeHandler(client);
		SoldineKitDownload();
	}
}
void SoldineKitDownload()
{
	if(!Precached)
	{
		// MASS REPLACE THIS IN ALL FILES
		PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
		Precached = true;
	}
}
static void Delete_Halo(int client)
{
	int halo_particle = EntRefToEntIndex(ParticleRef[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		ParticleRef[client] = INVALID_ENT_REFERENCE;
	}
}

static void Soldine_EyeHandler(int client)
{
	int halo_particle = EntRefToEntIndex(ParticleRef[client]);
	
	if(IsValidEntity(halo_particle))
		return;

	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}

	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3];
		GetAttachment(viewmodelModel, "eyeglow_L", flPos, NULL_VECTOR);
		int particle = ParticleEffectAt(flPos, "eye_powerup_red_lvl_3", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "eyeglow_L");
		ParticleRef[client] = EntIndexToEntRef(particle);
		return;
	}
}
static void Delete_Hand(int client)
{
	int halo_particle = EntRefToEntIndex(i_ParticleMeleeHit[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		i_ParticleMeleeHit[client] = INVALID_ENT_REFERENCE;
	}
}

static void Soldine_HandShowMegaBoom(int client)
{
	int halo_particle = EntRefToEntIndex(i_ParticleMeleeHit[client]);
	
	if(IsValidEntity(halo_particle))
		return;

	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}

	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3];
		GetAttachment(viewmodelModel, "effect_hand_r", flPos, NULL_VECTOR);
		int particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "effect_hand_r");
		i_ParticleMeleeHit[client] = EntIndexToEntRef(particle);
		return;
	}
}
public Action Timer_Soldine_Kit(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Soldine_Timer[client] = null;
		Delete_Halo(client);
		Delete_Hand(client);
		return Plugin_Stop;
	}	
		
	if(i_PaPLevel[client] >= 1)
	{
		if(i_SoldineMeleeCharge[client] >= SOLDINE_MAX_MELEE_CHARGE)
		{
			Soldine_HandShowMegaBoom(client);
		}
		else
		{
			Delete_Hand(client);
		}
	}
	else
	{
		Delete_Hand(client);
	}
	Soldine_EyeHandler(client);
	Soldine_Hud_Logic(client, weapon, false);
	//Wkit_Soldin_Effect(client);
		
	return Plugin_Continue;
}

#define SOLDINE_JUMPDURATIONUFF 2.0
void Wkit_Soldin_Effect(int client)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_BlastJumping))
	{
		return;
	}
	if(b_DisableSuperJump[client])
	{
		return;
	}
	if(i_SoldineRocketjumpCharge[client] < SOLDINE_MAX_ROCKETJUMP_CHARGE)
	{
		return;
	}
	if(i_PaPLevel[client] < 2)
	{
		return;
	}
	i_SoldineRocketjumpCharge[client] = 0.0;

	TF2_AddCondition(client, TFCond_HalloweenCritCandy, SOLDINE_JUMPDURATIONUFF);
	TF2_AddCondition(client, TFCond_RunePrecision, SOLDINE_JUMPDURATIONUFF);
	f_SoldineRocketJumpDuration[client] = GetGameTime() + (SOLDINE_JUMPDURATIONUFF + 1.0);
//	float velocity[3];
//	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
//	velocity[2] += 650.0;
//	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if(IsValidEntity(getweapon))
	{
		ApplyTempAttrib(getweapon, 6, 0.35, SOLDINE_JUMPDURATIONUFF);
		ApplyTempAttrib(getweapon, 178, 0.25, SOLDINE_JUMPDURATIONUFF);
		Rogue_OnAbilityUse(client, getweapon);
	}

	if(IsValidEntity(getweapon))
	{
		int RockeyAmmo=	GetAmmo(client, 8);
		int RocketAmmoMAX=RoundToCeil(8.0* Attributes_Get(getweapon, 4, 1.0));
		SetAmmo(client, 8, RockeyAmmo-RocketAmmoMAX);
		SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), RocketAmmoMAX);
	}
	int entity;
	entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(entity))
	{
		float flPos[3];
		float flAng[3];
		GetAttachment(entity, "foot_L", flPos, flAng);
		int particle = ParticleEffectAt(flPos, "rockettrail", SOLDINE_JUMPDURATIONUFF);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(entity, particle, "foot_L");
		
		GetAttachment(entity, "foot_R", flPos, flAng);
		particle = ParticleEffectAt(flPos, "rockettrail", SOLDINE_JUMPDURATIONUFF);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(entity, particle, "foot_R");
	}
}

public void Soldine_Hud_Logic(int client, int weapon, bool ignoreCD)
{
	//Do your code here :)
	if(Soldine_HudDelay[client] > GetGameTime() && !ignoreCD)
		return;

	char SoldineHud[255];

	if(i_PaPLevel[client] >= 1)
	{
		Format(SoldineHud, sizeof(SoldineHud), "%s폭발 주먹[%1.f％]", SoldineHud, (i_SoldineMeleeCharge[client] / SOLDINE_MAX_MELEE_CHARGE) * 100.0);
	}

	if(i_PaPLevel[client] >= 2)
	{
		if(b_DisableSuperJump[client])
			Format(SoldineHud, sizeof(SoldineHud), "%s\n로봇 점프[%1.f％] (비활성화)", SoldineHud, (i_SoldineRocketjumpCharge[client] / SOLDINE_MAX_ROCKETJUMP_CHARGE) * 100.0);	
		else
			Format(SoldineHud, sizeof(SoldineHud), "%s\n로봇 점프[%1.f％]", SoldineHud, (i_SoldineRocketjumpCharge[client] / SOLDINE_MAX_ROCKETJUMP_CHARGE) * 100.0);
	}

	Soldine_HudDelay[client] = GetGameTime() + 0.5;
	PrintHintText(client,"%s",SoldineHud);
	
}



public void Wkit_Soldin_NPCTakeDamage_Melee(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if((damagetype & DMG_CLUB))
	{
		switch(i_PaPLevel[attacker])
		{
			case 1, 2, 3, 4, 5, 6, 7, 8:
			{
				if(i_SoldineMeleeCharge[attacker] >= SOLDINE_MAX_MELEE_CHARGE)
				{
					if(f_SoldineRocketJumpDuration[attacker] > GetGameTime())
					{
						damage *= 2.0;
						DisplayCritAboveNpc(victim, attacker, true, _, _, false);
					}
					i_SoldineMeleeCharge[attacker] = 0.0;
					//Set this to 0 first to prevent infinite loops!
					
					Rogue_OnAbilityUse(attacker, weapon);
					float position[3]; WorldSpaceCenter(victim, position);
					position[2]+=35.0;
					DataPack pack_boom = new DataPack();
					pack_boom.WriteFloat(position[0]);
					pack_boom.WriteFloat(position[1]);
					pack_boom.WriteFloat(position[2]);
					pack_boom.WriteCell(1);
					RequestFrame(MakeExplosionFrameLater, pack_boom);

					//For client only cus too much fancy shit
					EmitSoundToClient(attacker, "mvm/mvm_tank_explode.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					TE_Particle("hightower_explosion", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);

					TE_Particle("mvm_soldier_shockwave", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
					if(RaidbossIgnoreBuildingsLogic(1))
						damage *= 2.0;

					Explode_Logic_Custom(damage*2.0, attacker, attacker, weapon, position, 250.0, 0.75, _, _, _, _, _, Ground_Slam);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.0);
					damage *= 3.0;
					if(i_PaPLevel[attacker] >= 4)
						GiveArmorViaPercentage(attacker, 0.5, 1.25);
					else if(i_PaPLevel[attacker] >= 3)
						GiveArmorViaPercentage(attacker, 0.5, 1.0);

				}
				else
				{
					ChargeSoldineMeleeHit(attacker,victim,true);
					ChargeSoldineRocketJump(attacker,victim, true);
				}
			}
			default:
			{
				
			}
		}
	}
}


public void Wkit_Soldin_NPCTakeDamage_Ranged(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(f_SoldineRocketJumpDuration[attacker] > GetGameTime())
	{
		damage *= 1.15;
		if(!CheckInHud())
			DisplayCritAboveNpc(victim, attacker, true, _, _, true);

		ChargeSoldineMeleeHit(attacker,victim,false);
	}
	else
	{
		if(!CheckInHud())
		{
			ChargeSoldineMeleeHit(attacker,victim,false);
			ChargeSoldineRocketJump(attacker,victim, false);
		}
	}
}

static void Ground_Slam(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		ApplyStatusEffect(entity, victim, "Silenced", (b_thisNpcIsARaid[victim] ? 1.0 : 1.5));
		if(b_thisNpcIsARaid[victim])
			FreezeNpcInTime(victim, 0.5);
		else
			FreezeNpcInTime(victim, 1.0);

		SensalCauseKnockback(entity, victim, 0.75, true);
	}
}


public void Soldine_ToggleSuperJump(int client, int weapon, bool crit, int slot)
{
	if(b_DisableSuperJump[client])
	{
		b_DisableSuperJump[client] = false;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_01.wav");
 	}
	else
	{
		b_DisableSuperJump[client] = true;
		ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
	}
}