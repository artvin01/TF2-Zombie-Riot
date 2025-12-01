#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerCastleBreakerWeaponManagement[MAXPLAYERS] = {null, ...};
static bool b_AbilityActivated[MAXPLAYERS];
static bool b_AbilityDone[MAXPLAYERS];
static bool Change[MAXPLAYERS];
static int i_VictoriaParticle[MAXPLAYERS];
static int CastleBreaker_WeaponPap[MAXPLAYERS];
static float CastleBreaker_HUDDelay[MAXPLAYERS];

static int CastleBreaker_Cylinder[MAXPLAYERS];
static float CastleBreaker_SoundsDelay[MAXPLAYERS];
static int CashGainLimitWavePer_CastleBreaker[MAXPLAYERS];
static float CastleBreaker_DoubleTapR[MAXPLAYERS];
static bool CastleBreaker_ModeLock[MAXPLAYERS];

#define MAX_CASH_PER_WAVE_CASTLEBREAKER 500

void ResetMapStartCastleBreakerWeapon()
{
	CastleBreaker_Map_Precache();
}

void CastleBreaker_ResetCashGain()
{
	Zero(CashGainLimitWavePer_CastleBreaker);
}

bool AllowMaxCashgainWaveCustom(int client)
{
	if(CashGainLimitWavePer_CastleBreaker[client] >= MAX_CASH_PER_WAVE_CASTLEBREAKER)
		return false;

	return true;
}
void AddCustomCashMadeThisWave(int client, int cash)
{
	CashGainLimitWavePer_CastleBreaker[client] += cash;
}

static void CastleBreaker_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_05.wav");
	PrecacheSound("weapons/grenade_launcher_worldreload.wav");
	PrecacheSound("weapons/syringegun_reload_air1.wav");
	PrecacheSound("weapons/syringegun_reload_air2.wav");
	PrecacheSound("weapons/sniper_railgun_world_reload.wav");
	PrecacheSound("weapons/sniper_railgun_bolt_back.wav");
}

void CastleBreaker_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	CustomMeleeRange = MELEE_RANGE * 1.15; //shorter than rapier
	CustomMeleeWide = MELEE_BOUNDS * 0.85;
	if(b_AbilityActivated[client])
	{
		enemies_hit_aoe = 2; //hit 2 targets.
	}
}

public void CastleBreaker_M1(int client, int weapon, bool crit, int slot)
{
	float attackspeed = Attributes_Get(weapon, 6, 1.0);
	//PrintHintText(client,"Attack!");
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

	if(Change[client])
	{
		int Ammo_Cost = 8;
		int new_ammo = GetAmmo(client, 8); //rocket ammo
		if(new_ammo < 8)
		{
			ClientCommand(client, "playgamesound weapons/shotgun_empty.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Ammo", Ammo_Cost);
			if(!CastleBreaker_ModeLock[client])
			{
				Ability_Apply_Cooldown(client, 3, 5.0);
				Change[client]=false;
				DataPack pack;
				CreateDataTimer(0.1, Timer_ChangeSound, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				pack.WriteCell(GetClientUserId(client));
				pack.WriteCell(EntIndexToEntRef(weapon));
				pack.WriteCell(Change[client]);
			}
			return;
		}
		new_ammo -= 8;
		SetAmmo(client, 8, new_ammo);
		CurrentAmmo[client][8] = GetAmmo(client, 8);
	}
}

void WeaponCastleBreaker_Extra(int client, int victim, int weapon)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	CastleBreaker_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
	switch (CastleBreaker_WeaponPap[client])
	{
		case 0: //base pap
		{
			damage *= 0.05;
		}
		case 1: //base pap
		{
			damage *= 0.1;
		}
		case 2: //base pap
		{
			damage *= 0.15;
		}
		case 3: //base pap
		{
			damage *= 0.2;
		}
	}
	if(IsValidEnemy(client, victim))
	{
		float vecHit[3];
		WorldSpaceCenter(victim, vecHit);
		//PrintHintText(client,"TrueHit!");
		SDKHooks_TakeDamage(victim, client, client, damage, DMG_TRUEDAMAGE, -1, _, vecHit);
	}
}

public void CastleBreaker_Modechange(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		bool ignore=false;
		static float angles[3];
		GetClientEyeAngles(client, angles);
		if(angles[0] > 85.0)
		{
			if(CastleBreaker_DoubleTapR[client] < GetGameTime())
				CastleBreaker_DoubleTapR[client] = GetGameTime() + 0.2;
			else
				ignore=true;
		}
		
		if(!ignore && GetEntityFlags(client) & FL_DUCKING)
		{
			CastleBreaker_ModeLock[client]=!CastleBreaker_ModeLock[client];
			ClientCommand(client, "playgamesound weapons/vaccinator_toggle.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			if(CastleBreaker_ModeLock[client])
				ShowSyncHudText(client,  SyncHud_Notifaction, "Ability Lock");
			else
				ShowSyncHudText(client,  SyncHud_Notifaction, "Ability Unlock");
			return;
		}
		
		if(!ignore && CastleBreaker_ModeLock[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Ability has Lock!");
			return;
		}
		
		int Ammo_Cost = 12;
		int new_ammo = GetAmmo(client, 8); //rocket ammo
		if(new_ammo < 12)
		{
			ClientCommand(client, "playgamesound weapons/shotgun_empty.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Ammo", Ammo_Cost);
			Change[client]=false;
			return;
		}
		if(Ability_Check_Cooldown(client, slot) > 0.0)
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
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 5.0);
		Change[client]=!Change[client];
		CastleBreaker_Cylinder[client]=0;
		DataPack pack;
		CreateDataTimer(0.1, Timer_ChangeSound, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(Change[client]);
	}
}

void CastleBreakerCashOnKill(int client)
{
	if(CashGainLimitWavePer_CastleBreaker[client] >= MAX_CASH_PER_WAVE_CASTLEBREAKER)
		return;
	//cash on kil
	if(!Waves_InSetup())
	{
		float cashgain = 1.0;
	//	if(b_AvangardCoreB[client])//do you have this unlock?
		cashgain += 1.0;
		if(CastleBreaker_WeaponPap[client]>=2)
			cashgain += 1.0;
		int cash = RoundFloat(cashgain * ResourceRegenMulti);
		CashReceivedNonWave[client] += cash;
		CashSpent[client] -= cash;
		CashGainLimitWavePer_CastleBreaker[client] += cash;
	}
}


public void CastleBreaker_Ability_M2(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
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
	if(Store_IsWeaponFaction(client, weapon, Faction_Victoria))	// Victoria
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerCastleBreakerWeaponManagement[i])
			{
				ApplyStatusEffect(weapon, weapon, "Castle Breaking Power", 9999999.0);
				Attributes_SetMulti(weapon, 2, 1.1);
			}
		}
	}
}

static Action Timer_Management_CastleBreaker(Handle timer, DataPack pack)
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
		CastleBreaker_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		if(CastleBreaker_WeaponPap[client]!=0)
			CreateCastleBreakerEffect(client);
		else Change[client] = false;
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
	if(!Change[attacker]&& (damagetype & DMG_CLUB))
	{
		WeaponCastleBreaker_Extra(attacker, victim, weapon);
	}
	if(Change[attacker]&& (damagetype & DMG_CLUB))
	{
		damage *= 0.5;
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float position[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
		float spawnLoc[3];
		float BaseDMG = 200.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);
		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		Explode_Logic_Custom(BaseDMG, attacker, attacker, weapon, position, _, Falloff);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.2);
		SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.2);
		
		EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, victim, 70,_, 0.9, 70);
		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
	}
}
void WeaponCastleBreaker_OnTakeDamage( int victim, float &damage)
{
	if(b_AbilityActivated[victim])
	{
		damage *= 0.90;
	}
}

static Action Timer_Bool_CastleBreaker(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	b_AbilityActivated[client] = false;
	return Plugin_Stop;
}

static void CreateCastleBreakerEffect(int client)
{
	int new_ammo = GetAmmo(client, 8);
	if(CastleBreaker_HUDDelay[client] < GetGameTime())
	{
		if(Change[client])
			PrintHintText(client,"Mode: BLAST / Blast Shells: %i", new_ammo);
		else
			PrintHintText(client,"Mode: PIERCE / Blast Shells: %i", new_ammo);

		
		CastleBreaker_HUDDelay[client] = GetGameTime() + 0.5;
	}
	if(b_AbilityActivated[client])
	{
		int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "eyeglow_l", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "eye_powerup_blue_lvl_3", 0.0);
				AddEntityToThirdPersonTransitMode(entity, particle);
				SetParent(entity, particle, "eyeglow_l");
				i_VictoriaParticle[client] = EntIndexToEntRef(particle);
			}
		}
	}
	else
		DestroyCastleBreakerEffect(client);
}
static void DestroyCastleBreakerEffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
}

static Action Timer_ChangeSound(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(!IsValidClient(client))
		return Plugin_Stop;

	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(weapon))
		return Plugin_Stop;

	bool GetMode = pack.ReadCell();
	if(CastleBreaker_SoundsDelay[client] > GetGameTime())
		return Plugin_Continue;
	if(GetMode)
	{
		switch(CastleBreaker_Cylinder[client])
		{
			case 5:
			{
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", client, SNDCHAN_AUTO, 65, _, 1.0, 115);
				CastleBreaker_Cylinder[client]=0;
				return Plugin_Stop;
			}
			default:
			{
				EmitSoundToAll("weapons/grenade_launcher_worldreload.wav", client, SNDCHAN_AUTO, 65, _, 0.9, 115);
				CastleBreaker_Cylinder[client]++;
				CastleBreaker_SoundsDelay[client] = GetGameTime() + (CastleBreaker_Cylinder[client]>5 ? 0.3 : 0.01);
			}
		}
	}
	else
	{
		switch(CastleBreaker_Cylinder[client])
		{
			case 0:
			{
				EmitSoundToAll("weapons/sniper_railgun_bolt_back.wav", client, SNDCHAN_AUTO, 65, _, 1.0, 115);
				
				CastleBreaker_Cylinder[client]++;
				CastleBreaker_SoundsDelay[client] = GetGameTime() + 0.01;
			}
			case 1:
			{
				EmitSoundToAll("weapons/syringegun_reload_air2.wav", client, SNDCHAN_AUTO, 65, _, 0.9, 115);
				CastleBreaker_Cylinder[client]++;
				CastleBreaker_SoundsDelay[client] = GetGameTime() + 0.01;
			}
			default:
			{
				EmitSoundToAll("weapons/syringegun_reload_air1.wav", client, SNDCHAN_AUTO, 65, _, 0.9, 115);
				CastleBreaker_Cylinder[client]=0;
				return Plugin_Stop;
			}
		}
	}
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+1.0);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+1.0);
	return Plugin_Continue;
}