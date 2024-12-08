#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerCastleBreakerWeaponManagement[MAXTF2PLAYERS] = {null, ...};
static bool b_AbilityActivated[MAXTF2PLAYERS];
static bool b_AbilityDone[MAXTF2PLAYERS];
static int i_CastleBreakerDoubleHit[MAXENTITIES];

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
	CustomMeleeRange = DEFAULT_MELEE_RANGE * 1.15;
	CustomMeleeWide = DEFAULT_MELEE_BOUNDS * 0.85;
	if(b_AbilityActivated[client])
	{
		enemies_hit_aoe = 2; //hit 2 targets.
	}
}

void Reset_stats_CastleBreaker_Singular_Weapon(int weapon) //This is on weapon remake. cannot set to 0 outright.
{
	b_WeaponAttackSpeedModified[weapon] = false;
	i_CastleBreakerDoubleHit[weapon] = 0;
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
	else
	{
		if(!b_AbilityDone[client])
		{
			attackspeed = 1.0;
			Attributes_Set(weapon, 6, attackspeed);
			b_AbilityDone[client] = true;
		}
	}
}

void CastleBreakerCashOnKill(int client)
{
	if(!Waves_InSetup())
	{
		float cashgain = 1.0;
		if(b_AvangardCoreB[client])
			cashgain = 2.0;
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
			Ability_Apply_Cooldown(client, slot, 50.0);
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
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
	//	CreateCastleBreakerEffect(client);
	}
	else
	{
		b_AbilityDone[client] = true;
		b_AbilityActivated[client] = false;
	}

	return Plugin_Continue;
}

void WeaponCastleBreaker_OnTakeDamageNpc(int attacker, int victim, float &damage)
{
	if(i_IsABuilding[victim])
	{
		damage *= 1.2;
	}
	if(b_AbilityActivated[attacker])
	{
		if(b_thisNpcIsARaid[victim])
		{
			damage *= 1.15;
		}
	}
}

void WeaponCastleBreaker_OnTakeDamage(int attacker, int victim, float &damage)
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
