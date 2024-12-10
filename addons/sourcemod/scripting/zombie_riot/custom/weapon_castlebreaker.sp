#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerCastleBreakerWeaponManagement[MAXTF2PLAYERS] = {null, ...};
static bool b_AbilityActivated[MAXTF2PLAYERS];
static bool b_AbilityDone[MAXTF2PLAYERS];
static bool Change[MAXPLAYERS];
static int i_VictoriaParticle[MAXTF2PLAYERS];

void ResetMapStartCastleBreakerWeapon()
{
	CastleBreaker_Map_Precache();
}

void CastleBreaker_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_05.wav");
}

void CastleBreaker_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	CustomMeleeRange = DEFAULT_MELEE_RANGE * 1.15; //shorter than rapier
	CustomMeleeWide = DEFAULT_MELEE_BOUNDS * 0.85;
	if(b_AbilityActivated[client])
	{
		enemies_hit_aoe = 2; //hit 2 targets.
	}
}


public void CastleBreaker_M1(int client, int weapon, bool crit, int slot)
{
	float attackspeed = Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
	if(b_AbilityActivated[client])
	{
		b_AbilityDone[client] = false;
		if(!b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			b_WeaponAttackSpeedModified[weapon] = true;
			attackspeed = (attackspeed * 0.15);
			Attributes_Set(weapon, 6, attackspeed);
		}
		else
		{
			b_WeaponAttackSpeedModified[weapon] = false;
			attackspeed = (attackspeed / 0.15);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
	}
	else if(b_WeaponAttackSpeedModified[weapon])
	{
		b_WeaponAttackSpeedModified[weapon] = false;
		attackspeed = (attackspeed / 0.15);
		Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
	}

	if(Change[client] == true)
	{
		int new_ammo = GetAmmo(client, 8); //rocket ammo
		if(new_ammo < 12)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		new_ammo -= 12;
		SetAmmo(client, 8, new_ammo);
		CurrentAmmo[client][8] = GetAmmo(client, 8);	
	}
}

public void CastleBreaker_Modechange(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 5.0);
			EmitSoundToAll(SOUND_MES_CHANGE, client, SNDCHAN_AUTO, 65, _, 0.45, 115);
			if(Change[client])
			{
				Change[client]=false;
			}
			else
			{
				Change[client]=true;
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
}

void CastleBreakerCashOnKill(int client)
{
	if(!Waves_InSetup())
	{
		float cashgain = 1.0; // 1cash on kill
		if(b_AvangardCoreB[client])//do you have this unlock?
			cashgain = 2.0;//2 cash on kill
		int cash = RoundFloat(cashgain * ResourceRegenMulti);
		CashRecievedNonWave[client] += cash;
		CashSpent[client] -= cash;
	}
}


public void CastleBreaker_Ability_M2(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 60.0);
			EmitSoundToAll("ambient/cp_harbor/furnace_1_shot_05.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			b_AbilityActivated[client] = true;
			CreateTimer(15.0, Timer_Bool_CastleBreaker, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			//SetParent(client, particle_Base, "m_vecAbsOrigin");
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
}
public void Enable_CastleBreakerWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerCastleBreakerWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASTLEBREAKER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerCastleBreakerWeaponManagement[client];
			h_TimerCastleBreakerWeaponManagement[client] = null;
			DataPack pack;
			h_TimerCastleBreakerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_CastleBreaker, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASTLEBREAKER)
		{
			DataPack pack;
			h_TimerCastleBreakerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_CastleBreaker, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		
	}	
}

public Action Timer_Management_CastleBreaker(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		b_AbilityActivated[client] = false;
		b_AbilityDone[client] = true;
		h_TimerCastleBreakerWeaponManagement[client] = null;
		Change[client] = false;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateCastleBreakerEffect(client);
	}
	else
	{
		b_AbilityDone[client] = true;
		b_AbilityActivated[client] = false;
		DestroyCastleBreakerEffect(client);
	}

	return Plugin_Continue;
}

void WeaponCastleBreaker_OnTakeDamageNpc(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if((damagetype & DMG_CLUB))
		return;
	
	if(i_IsABuilding[victim])
	{
		damage *= 1.2;
	}
	if(b_AbilityActivated[attacker])
	{
		damage *= 0.65;
		if(b_thisNpcIsARaid[victim])
		{
			damage *= 1.15;
		}
	}
	if(Change[attacker] == true)
	{
		damage *= 0.5;
	}
	static float angles[3];
	GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float position[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
	float spawnLoc[3];
	float BaseDMG = 500.0;
	BaseDMG *= Attributes_Get(weapon, 2, 1.0);
	float Radius = EXPLOSION_RADIUS;
	Radius *= Attributes_Get(weapon, 99, 1.0);
	float Falloff = Attributes_Get(weapon, 117, 1.0);
	float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

	Explode_Logic_Custom(BaseDMG, attacker, attacker, weapon, position, Radius, Falloff);
	
	EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, victim, 70,_, 0.9, 70);
	ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
}

void WeaponCastleBreaker_OnTakeDamage( int victim, float &damage)
{
	if(b_AbilityActivated[victim])
	{
		damage *= 0.90;
	}
}

public Action Timer_Bool_CastleBreaker(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	b_AbilityActivated[client] = false;
	return Plugin_Stop;
}

void CreateCastleBreakerEffect(int client)
{
	int new_ammo = GetAmmo(client, 8);
	if(Change[client] == true)
	{
		PrintHintText(client,"Mode: BLAST / Blast Shells: %i", new_ammo);
	}
	else if(Change[client] == false)
	{
		PrintHintText(client,"Mode: PIERCE / Blast Shells: %i", new_ammo);
	}
	
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	if(!IsValidEntity(i_VictoriaParticle[client]))
	{
		return;
	}
	DestroyCastleBreakerEffect(client);
	
	float flPos[3];
	float flAng[3];
	GetAttachment (client, "eyeglow_l", flPos, flAng);
	int particle = ParticleEffectAt(flPos, "eye_powerup_blue_lvl_3", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle, "eyeglow_l");
	i_VictoriaParticle[client] = EntIndexToEntRef(particle);
}
void DestroyCastleBreakerEffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
}