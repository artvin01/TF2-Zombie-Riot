#pragma semicolon 1
#pragma newdecls required

Handle Timer_Rapier_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static Handle DuelState_timer[MAXPLAYERS+1];

#define DUEL					"ui/duel_challenge.wav"
//#define DUEL2					"coach/coach_look_here.wav"
#define DUEL3					"passtime/projectile_swoosh2.wav"
#define DUEL4					"ui/duel_event.wav"
#define DUEL5					"ui/duel_challenge_accepted_with_restriction.wav"
#define DUEL6					"ui/duel_challenge_rejected_with_restriction.wav"

static int i_Current_Pap_Rapier[MAXPLAYERS+1];
static int i_CashLimit[MAXPLAYERS+1];
static int DuelHit = 0;

static bool b_WonDuel[MAXPLAYERS];

static float fl_Rapier_hud_delay[MAXPLAYERS];

void Weapon_RapierMapChange()
{
	Zero(Timer_Rapier_Management);
	Zero(fl_Rapier_hud_delay);
	Zero(DuelState_timer);
	PrecacheSound(DUEL);
	//PrecacheSound(DUEL2);
	PrecacheSound(DUEL3);
	PrecacheSound(DUEL4);
	PrecacheSound(DUEL5);
	PrecacheSound(DUEL6);
	PrecacheSound("player/crit_hit_mini.wav");
	PrecacheSound("player/crit_hit_mini2.wav");
	PrecacheSound("player/crit_hit_mini3.wav");
	PrecacheSound("player/crit_hit_mini4.wav");
	PrecacheSound("player/crit_hit_mini5.wav");
}

void Rapier_DoSwingTrace(float &CustomMeleeRange, float &CustomMeleeWide)
{
	bool raidboss_active = false;
	if(RaidbossIgnoreBuildingsLogic(1))
	{
		raidboss_active = true;
	}

	switch(raidboss_active)
	{
		case true:
		{
			CustomMeleeRange = MELEE_RANGE * 1.55;
			CustomMeleeWide = MELEE_BOUNDS * 0.5;
		}
		case false:
		{
			CustomMeleeRange = MELEE_RANGE * 1.35;
			CustomMeleeWide = MELEE_BOUNDS * 0.5;
		}
	}
}

void Rapier_CashWaveEnd()
{
	Zero(i_CashLimit);
}

void RapierEndDuelOnKill(int client,int victim)
{
	if(f_DuelStatus[victim] > 0.0 && DuelState_timer[client] != INVALID_HANDLE)
	{
		int pap = i_Current_Pap_Rapier[client];
		float MaxHealth = float(SDKCall_GetMaxHealth(client));
		EmitSoundToClient(client, DUEL5, _, _, 80, _, 0.8, 100);
		switch(pap)
		{
			case 4: //second highest pap)) :)
			{
				HealEntityGlobal(client, client, MaxHealth * 0.75, _, 0.5,HEAL_SELFHEAL);
				i_CashLimit[client]++;
				if(i_CashLimit[client] < 11)
				{
					CashRecievedNonWave[client] += 25;
					CashSpent[client] -= 25;
				}
			}
			case 5: //highest pap
			{
				HealEntityGlobal(client, client, MaxHealth * 0.125, _, 0.5,HEAL_SELFHEAL);
				i_CashLimit[client]++;
				if(i_CashLimit[client] < 11)
				{
					CashRecievedNonWave[client] += 50;
					CashSpent[client] -= 50;
				}
			}
		}
		delete DuelState_timer[client];
		DuelHit *= 0;
	}
}

public float Player_OnTakeDamage_Rapier(int victim, int attacker, float &damage)
{
	if(!CheckInHud() && f_DuelStatus[attacker] > 0.0 && DuelState_timer[victim] != INVALID_HANDLE)
	{
		Client_Shake(victim, 0, 10.0, 5.0, 0.5);
		return damage *= 1.25; // 25% more damage taken
	}
	else
	{
		return damage;
	}
}
void Rapier_duel_minicrits(int attacker)
{
	switch(GetRandomInt(1,5))
	{
		case 1:
		{
			EmitSoundToClient(attacker, "player/crit_hit_mini.wav", _, _, 80, _, 0.8, 100);
		}
		case 2:
		{
			EmitSoundToClient(attacker, "player/crit_hit_mini2.wav", _, _, 80, _, 0.8, 100);
		}
		case 3:
		{
			EmitSoundToClient(attacker, "player/crit_hit_mini3.wav", _, _, 80, _, 0.8, 100);
		}
		case 4:
		{
			EmitSoundToClient(attacker, "player/crit_hit_mini4.wav", _, _, 80, _, 0.8, 100);
		}
		case 5:
		{
			EmitSoundToClient(attacker, "player/crit_hit_mini5.wav", _, _, 80, _, 0.8, 100);
		}
	}
}

public void NPC_OnTakeDamage_Rapier(int attacker, int victim, float &damage, int weapon)
{
	int pap = i_Current_Pap_Rapier[attacker];
	StartBleedingTimer(victim, attacker, damage * 0.03, 4, weapon, DMG_TRUEDAMAGE);
	if(i_HasBeenHeadShotted[victim] == true)
	{	
		damage *= 1.25;
		//PrintToChatAll("speedbuff from headshot :D");
		if(pap != 0)
			StartBleedingTimer(victim, attacker, damage * 0.03, 4, weapon, DMG_TRUEDAMAGE);
	}
	switch(pap)
	{
		case 0, 1:
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.4);
		}
		default:
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.8);
		}
	}
	

	if(f_DuelStatus[victim] > 0.0 && DuelState_timer[attacker] != INVALID_HANDLE)
	{
		Rapier_duel_minicrits(attacker);
		damage *= 1.25;
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			if(i_HasBeenHeadShotted[victim] == true)
			{	
				DuelHit++;
			}
			DuelHit++;
			if(DuelHit == 6)
			{
				RapierEndDuelOnKill(attacker, victim);
			}
		}
	}
}

public void Weapon_Rapier_M2(int client, int weapon, bool crit, int slot)
{
	//PrintToChatAll("Pressed M2");
	int Health = GetEntProp(client, Prop_Send, "m_iHealth");
	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		//PrintToChatAll("Didn't trigger Duel");
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
	else if(Health < (MaxHealth/4))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Not healthy enough");
	}
	else
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 100.0, false, 45.0, false); //infinite range, and ignore walls! < ??? no??? whar??
		FinishLagCompensation_Base_boss();

		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		if(!IsValidEnemy(client, target, true))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
			
		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 15.0);
		static float EntLoc[3];

		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

		EmitSoundToClient(client, DUEL, _, _, 80, _, 0.8, 100);
		EmitSoundToClient(client, DUEL3, _, _, 80, _, 0.8, 100);
		//EmitSoundToAll(DUEL2, client, SNDCHAN_STATIC, 80, _, 1.0);
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = -400.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 125.0;    // a little boost to alleviate arcing issues

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		float time = GetGameTime() + 10.00;
		if(f_DuelStatus[target] <= time)
		{
			f_DuelStatus[target] = time;
			delete DuelState_timer[client];
			DuelState_timer[client] = CreateTimer(10.0, DuelState, client);
		}
	}
}

public Action DuelState(Handle cut_timer, int client)
{
	DuelState_timer[client] = null;
	if(b_WonDuel[client] == true)
	{
		EmitSoundToClient(client, DUEL5, _, _, 80, _, 0.8, 100);
		b_WonDuel[client] = false;
	}
	else
	{
		EmitSoundToClient(client, DUEL4, _, _, 80, _, 0.8, 100);
	}
	return Plugin_Handled;
}

static int Rapier_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	return pap;
}

public void Enable_Rapier(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Rapier_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAPIER)
		{
			//Is the weapon it again?
			//Yes?
			i_Current_Pap_Rapier[client] = Rapier_Get_Pap(weapon);
			delete Timer_Rapier_Management[client];
			Timer_Rapier_Management[client] = null;
			DataPack pack;
			Timer_Rapier_Management[client] = CreateDataTimer(0.1, Timer_Management_Rapier, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RAPIER) //
	{
		i_Current_Pap_Rapier[client] = Rapier_Get_Pap(weapon);

		DataPack pack;
		Timer_Rapier_Management[client] = CreateDataTimer(0.1, Timer_Management_Rapier, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Rapier(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Rapier_Management[client] = null;
		return Plugin_Stop;
	}	

	Rapier_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}

public void Rapier_Cooldown_Logic(int client, int weapon)
{
	//Do your code here :) < ok :)
	if(fl_Rapier_hud_delay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		int Health = GetEntProp(client, Prop_Send, "m_iHealth");
		float MaxHealth = float(SDKCall_GetMaxHealth(client));
		SDKCall_SetSpeed(client);
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			i_Current_Pap_Rapier[client] = Rapier_Get_Pap(weapon);
		//	TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 0.65); //reason for not using on_playertakedamage and returining 15% more dmg that way is because this is flashier
		}
		else
		{
		//	TF2_RemoveCondition(client, TFCond_MarkedForDeathSilent);
		}
		if(IsValidClient(client) && IsClientInGame(client) && DuelState_timer[client] != INVALID_HANDLE && Health < (MaxHealth/4))
		{
			EmitSoundToClient(client, DUEL6, _, _, 80, _, 0.8, 100);
			delete DuelState_timer[client];
		}
		fl_Rapier_hud_delay[client] = GetGameTime() + 0.5;
	}
}