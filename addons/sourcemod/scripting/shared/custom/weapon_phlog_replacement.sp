#pragma semicolon 1
#pragma newdecls required

#define PHLOG_JUDGEMENT_MAX_HITS_NEEDED 150 	

#define PHLOG_ABILITY "misc/halloween/spell_overheal.wav"

Handle h_TimerPHLOGManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_PHLOGhuddelay[MAXTF2PLAYERS];
static float f_PHLOGabilitydelay[MAXTF2PLAYERS];
static int i_PHLOGHitsDone[MAXTF2PLAYERS];

void Npc_OnTakeDamage_Phlog(int attacker)
{
	if(GetGameTime() > f_PHLOGabilitydelay[attacker])
	{
		i_PHLOGHitsDone[attacker] += 1;
		if(i_PHLOGHitsDone[attacker] > PHLOG_JUDGEMENT_MAX_HITS_NEEDED) //We do not go above this, no double charge.
		{
			i_PHLOGHitsDone[attacker] = PHLOG_JUDGEMENT_MAX_HITS_NEEDED;
		}
	}
}

void PHLOG_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound(PHLOG_ABILITY);
}

void Reset_stats_PHLOG_Global()
{
	Zero(h_TimerPHLOGManagement);
	Zero(f_PHLOGhuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(f_PHLOGabilitydelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_PHLOGHitsDone); //This only ever gets reset on map change or player reset
}

void Reset_stats_PHLOG_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerPHLOGManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerPHLOGManagement[client]);
	}	
	h_TimerPHLOGManagement[client] = INVALID_HANDLE;
	i_PHLOGHitsDone[client] = 0;
}

public void Weapon_PHLOG_Attack(int client, int weapon, bool crit, int slot)
{
	return;
}

public void Enable_PHLOG(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerPHLOGManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 7) //7 is for PHLOG.
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerPHLOGManagement[client]);
			h_TimerPHLOGManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerPHLOGManagement[client] = CreateDataTimer(0.1, Timer_Management_PHLOG, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 7) //7 is for PHLOG.
	{
		DataPack pack;
		h_TimerPHLOGManagement[client] = CreateDataTimer(0.1, Timer_Management_PHLOG, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_PHLOG(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				PHLOG_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_PHLOG(client);
		}
		else
			Kill_Timer_PHLOG(client);
	}
	else
		Kill_Timer_PHLOG(client);
		
	return Plugin_Continue;
}


public void PHLOG_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == 7) //Double check to see if its good or bad :(
		{	
			if(f_PHLOGhuddelay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					if(GetGameTime() > f_PHLOGabilitydelay[client])
					{
						if(i_PHLOGHitsDone[client] < PHLOG_JUDGEMENT_MAX_HITS_NEEDED)
						{
							PrintHintText(client,"Phlog Hit Charge[%i%/%i]", i_PHLOGHitsDone[client], PHLOG_JUDGEMENT_MAX_HITS_NEEDED);
						}
						else
						{
							PrintHintText(client,"Phlog Hit Charge [READY!]");
						}
					}
					else
					{
						PrintHintText(client,"Phlog Hit Charge [Cooldown: %.1f]",f_PHLOGabilitydelay[client] - GetGameTime());
					}
					
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_PHLOGhuddelay[client] = GetGameTime() + 0.5;
				}
			}
			if(GetGameTime() < f_PHLOGabilitydelay[client])
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
				{
					f_PHLOGabilitydelay[client] = 0.0; //They just switched off it, delete.
					TF2_RemoveCondition(client, TFCond_DefenseBuffNoCritBlock);
					TF2_RemoveCondition(client, TFCond_CritCanteen);	
				}
			}
		}
		else
		{
			Kill_Timer_PHLOG(client);
		}
	}
	else
	{
		Kill_Timer_PHLOG(client);
	}
}

public void Kill_Timer_PHLOG(int client)
{
	if (h_TimerPHLOGManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerPHLOGManagement[client]);
		h_TimerPHLOGManagement[client] = INVALID_HANDLE;
	}
}

public void Weapon_PHLOG_Judgement(int client, int weapon, bool crit, int slot)
{
	//This ability has no cooldown in itself, it just relies on hits you do.
	if(i_PHLOGHitsDone[client] >= PHLOG_JUDGEMENT_MAX_HITS_NEEDED || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		i_PHLOGHitsDone[client] = 0;
		f_PHLOGabilitydelay[client] = GetGameTime() + 10.0; //Have a cooldown so they cannot spam it.
		EmitSoundToAll(PHLOG_ABILITY, client, _, 75, _, 0.60);
		TF2_AddCondition(client, TFCond_Ubercharged, 2.0); //ohboy
		TF2_AddCondition(client, TFCond_DefenseBuffNoCritBlock, 10.0);
		TF2_AddCondition(client, TFCond_CritCanteen, 10.0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}