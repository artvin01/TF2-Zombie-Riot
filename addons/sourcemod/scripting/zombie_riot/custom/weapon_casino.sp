#pragma semicolon 1
#pragma newdecls required

Handle Timer_Casino_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

static float Casino_hud_delay[MAXTF2PLAYERS];
static float fl_Damage_Ammount[MAXTF2PLAYERS];

//cooldowns lol//
static float fl_minor_damage_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_speed_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_reload_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_accuracy_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_clip_cooldown[MAXTF2PLAYERS+1];

static float fl_major_damage_cooldown[MAXTF2PLAYERS+1];
static float fl_major_speed_cooldown[MAXTF2PLAYERS+1];
static float fl_major_reload_cooldown[MAXTF2PLAYERS+1];
static float fl_major_accuracy_cooldown[MAXTF2PLAYERS+1];
static float fl_major_clip_cooldown[MAXTF2PLAYERS+1];
static float fl_jackpot_cooldown[MAXTF2PLAYERS+1];
////////////////

static int i_Dollars_Ammount[MAXTF2PLAYERS+1];
static int i_slot1[MAXTF2PLAYERS+1];
static int i_slot2[MAXTF2PLAYERS+1];
static int i_slot3[MAXTF2PLAYERS+1];
static int i_Current_Pap[MAXTF2PLAYERS+1];

#define CASINO_MAX_DOLLARS 100
#define CASINO_SALARY_GAIN_PER_HIT 1
#define CASINO_DAMAGE_GAIN_PER_HIT 1.0
#define CASINO_MAX_DAMAGE 100.0

public void Casino_MapStart() //idk what to precisely precache so hopefully this is good enough
{
	//normal stuff//
	Zero(Timer_Casino_Management);
	Zero(i_Dollars_Ammount);
	Zero(Casino_hud_delay);
	Zero(fl_Damage_Ammount);

	//cooldowns//
	Zero(fl_minor_damage_cooldown);
	Zero(fl_minor_speed_cooldown);
	Zero(fl_minor_reload_cooldown);
	Zero(fl_minor_accuracy_cooldown);
	Zero(fl_minor_clip_cooldown);

	Zero(fl_major_damage_cooldown);
	Zero(fl_major_speed_cooldown);
	Zero(fl_major_reload_cooldown);
	Zero(fl_major_accuracy_cooldown);
	Zero(fl_major_clip_cooldown);
	Zero(fl_jackpot_cooldown);
}

/*void Reset_stats_Casino_Global()
{
	Zero(Casino_hud_delay);
}*/

public float Npc_OnTakeDamage_Casino(int client, float &damage, int damagetype) //cash gain on hit for each pap + damage modifier
{
	if(damagetype & DMG_BULLET) //boculum
	{
		int pap = i_Current_Pap[client];
		switch(pap)
		{
			case 0:
			{
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT;
				if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			case 1:
			{
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 2;
				if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 2.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			case 2:
			{
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 3;
				if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 3.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			case 3:
			{
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 4;
				if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 4.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
	}
	float damageMod = ((fl_Damage_Ammount[client] / 100.0) + 1.0);
	return damage *= damageMod;
}

void CasinoSalaryPerKill(int client) //cash gain on KILL MURDER OBLITERATE ANNIHILATE GRAAAAAAA
{
	int pap = i_Current_Pap[client];
	switch(pap)
	{
		case 0:
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 5;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 5.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
		case 1:
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 6;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 6.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
		case 2:
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 7;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 7.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
		case 3:
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 8;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 8.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
	}
}

static int Casino_Get_Pap(int weapon) //deivid inspired pap detection system (as in literally a copy-paste from fantasy blade)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

public int RecurringNumbers(int client) //the logic for generating and showing the random numbers, thank u sammy
{
	i_slot1[client] = GetRandomInt(1,7), i_slot2[client] = GetRandomInt(1,7), i_slot3[client] = GetRandomInt(1,7);
	int Jackpot = i_slot1[client];
	if (i_slot1[client] == i_slot2[client] && i_slot2[client] == i_slot3[client])
	{
		return Jackpot + 7; // if all numbers are the same, add 7 and then return slot 1 number
	}

	if(i_slot1[client] == i_slot2[client]) //if slots 1 and 2 are same, return slot 1 number
		return i_slot1[client];
	if(i_slot1[client] == i_slot3[client]) //if slots 1 and 3 are same, return slot 3 number
		return i_slot3[client];
	if(i_slot2[client] == i_slot3[client]) //if slots 2 and 3 are same, return slot 2 number
		return i_slot2[client];
	
	return 0; //no slots are same?
}

public void Weapon_Casino_M2(int client, int weapon)
{
	if (i_Dollars_Ammount[client] >= 7) //only go through if you can afford it
	{
		i_Dollars_Ammount[client] -= CASINO_SALARY_GAIN_PER_HIT * 7; //cost of slots
		fl_Damage_Ammount[client] -= CASINO_DAMAGE_GAIN_PER_HIT * 7.0;
		ROLL_THE_SLOTS(client, weapon);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "You're too poor!"); //lmao nerd
	}
}

public void ROLL_THE_SLOTS(int client, int weapon)
{
	float GameTime = GetGameTime();
	int pap = i_Current_Pap[client];

	RecurringNumbers(client); //function :)
	switch(RecurringNumbers(client)) //5000000000000x better than else if spam
	{
		case 1: //minor damage
		{
			if(fl_minor_damage_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 2, 1.25, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor damage boost] for 60 seconds!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.375, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor damage boost] for 60 seconds!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.45, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor damage boost] for 60 seconds!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 1.5, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor damage boost] for 60 seconds!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Minor damage boost]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 1;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}

				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 1.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 2: //minor firing speed
		{
			if(fl_minor_speed_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 6, 0.9, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor firing speed boost] for 60 seconds!");
						fl_minor_speed_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 6, 0.85, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor firing speed boost] for 60 seconds!");
						fl_minor_speed_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 6, 0.80, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor firing speed boost] for 60 seconds!");
						fl_minor_speed_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 6, 0.75, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor firing speed boost] for 60 seconds!");
						fl_minor_speed_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Minor firing speed boost]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 1;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 1.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 3: //minor reload
		{
			if(fl_minor_reload_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 97, 0.8, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor reloading speed] boost for 60 seconds!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 97, 0.75, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor reloading speed] boost for 60 seconds!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 97, 0.7, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor reloading speed] boost for 60 seconds!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 97, 0.65, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor reloading speed] boost for 60 seconds!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Minor reloading speed]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 1;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 1.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 4: //perfect accuracy
		{
			if(fl_minor_accuracy_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] for 60 seconds!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.1, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] for 60 seconds!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.15, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] for 60 seconds!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.2, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] for 60 seconds!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
				}
			}
			else
			{
				ApplyTempAttrib(weapon, 2, 1.05, 60.0);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Perfect accuracy]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 1;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 1.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 5: //minor clip
		{
			if(fl_minor_clip_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 4, 1.3, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor clip size boost] for 60 seconds!");
						fl_minor_clip_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 4, 1.5, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor clip size boost] for 60 seconds!");
						fl_minor_clip_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 4, 1.7, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor clip size boost] for 60 seconds!");
						fl_minor_clip_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 4, 1.9, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Minor clip size boost] for 60 seconds!");
						fl_minor_clip_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound player/crit_hit.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Minor clip size boost]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 1;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 1.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 6: //minor cash
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 27;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 27.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Gain [a few dollars]!");
			ClientCommand(client, "playgamesound player/crit_hit.wav");
		}
		case 8: //major damage
		{
			if(fl_major_damage_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 2, 1.5, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major damage boost] for 120 seconds!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.75, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major damage boost] for 120 seconds!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.9, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major damage boost] for 120 seconds!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 2.0, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major damage boost] for 120 seconds!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
				}
			}
			else
			{
				ApplyTempAttrib(weapon, 2, 1.1, 120.0);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Major damage boost]!");
			}
		}
		case 9: //major firing
		{
			if(fl_major_speed_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 6, 0.75, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major firing speed boost] for 120 seconds!");
						fl_major_speed_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 6, 0.7, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major firing speed boost] for 120 seconds!");
						fl_major_speed_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 6, 0.65, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major firing speed boost] for 120 seconds!");
						fl_major_speed_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 6, 0.6, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major firing speed boost] for 120 seconds!");
						fl_major_speed_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Major firing speed boost]!");
			}
		}
		case 10: //major reload
		{
			if(fl_major_reload_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 97, 0.6, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major reloading speed boost] for 120 seconds!");
						fl_major_reload_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 97, 0.55, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major reloading speed boost] for 120 seconds!");
						fl_major_reload_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 97, 0.50, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major reloading speed boost] for 120 seconds!");
						fl_major_reload_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 97, 0.45, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major reloading speed boost] for 120 seconds!");
						fl_major_reload_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
				}
			}
			else
			{
				ApplyTempAttrib(weapon, 97, 0.9, 120.0);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Major reloading speed boost]!");
			}
		}
		case 11: //perfect accuracy and minor damage
		{
			if(fl_major_accuracy_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 120.0);
						ApplyTempAttrib(weapon, 2, 1.25, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] and [Minor damage boost] for 120 seconds!");
						fl_major_accuracy_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 120.0);
						ApplyTempAttrib(weapon, 2, 1.3, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] and [Minor damage boost] for 120 seconds!");
						fl_major_accuracy_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 120.0);
						ApplyTempAttrib(weapon, 2, 1.35, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] and [Minor damage boost] for 120 seconds!");
						fl_major_accuracy_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 120.0);
						ApplyTempAttrib(weapon, 2, 1.4, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy] and [Minor damage boost] for 120 seconds!");
						fl_major_accuracy_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
				}
			}
			else
			{
				ApplyTempAttrib(weapon, 2, 1.1, 120.0);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Major perfect accuracy]!");
			}
		}
		case 12: //major clip
		{
			if(fl_major_clip_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 4, 2.0, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major clip size boost] for 120 seconds!");
						fl_major_clip_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 4, 2.2, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major clip size boost] for 120 seconds!");
						fl_major_clip_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 4, 2.4, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major clip size boost] for 120 seconds!");
						fl_major_clip_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 4, 2.5, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Major clip size boost] for 120 seconds!");
						fl_major_clip_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received1.wav");
					}
				}
			}
			else
			{
				ApplyTempAttrib(weapon, 97, 0.9, 120.0);
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Major clip size boost]");
			}
		}
		case 13: //major cash
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 57;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 57.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Gain [a lot of dollars]!");
			ClientCommand(client, "playgamesound player/crit_received1.wav");
		}
		case 14: //jackpot
		{
			if(fl_jackpot_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 2, 1.325, 90.0);
						ApplyTempAttrib(weapon, 6, 0.8, 90.0);
						ApplyTempAttrib(weapon, 97, 0.77, 90.0);
						ApplyTempAttrib(weapon, 106, 0.1, 90.0);
						ApplyTempAttrib(weapon, 4, 1.3, 90.0);
						i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 37;
						if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
						{
							i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
						}
						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound player/crit_received2.wav");

						fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 37.0;
						if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
						{
							fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
						}
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.4125, 90.0);
						ApplyTempAttrib(weapon, 6, 0.8, 90.0);
						ApplyTempAttrib(weapon, 97, 0.725, 90.0);
						ApplyTempAttrib(weapon, 106, 0.1, 90.0);
						ApplyTempAttrib(weapon, 4, 1.5, 90.0);
						i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 37;
						if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
						{
							i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
						}
						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound player/crit_received2.wav");

						fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 37.0;
						if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
						{
							fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
						}
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.45, 90.0);
						ApplyTempAttrib(weapon, 6, 0.75, 90.0);
						ApplyTempAttrib(weapon, 97, 0.6725, 90.0);
						ApplyTempAttrib(weapon, 106, 0.1, 90.0);
						ApplyTempAttrib(weapon, 4, 1.7, 90.0);
						i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 37;
						if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
						{
							i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
						}
						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound player/crit_received2.wav");

						fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 37.0;
						if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
						{
							fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
						}
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 1.525, 90.0);
						ApplyTempAttrib(weapon, 6, 0.75, 90.0);
						ApplyTempAttrib(weapon, 97, 0.625, 90.0);
						ApplyTempAttrib(weapon, 106, 0.1, 90.0);
						ApplyTempAttrib(weapon, 4, 1.9, 90.0);
						i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 37;
						if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
						{
							i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
						}
						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound player/crit_received2.wav");

						fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 37.0;
						if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
						{
							fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
						}
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [JACKPOT]. How lucky!");
			}
		}
		default: //womp womp
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
}


///FUCK YOU TF2 HUDS///
static void Casino_Show_Hud(int client)
{
	PrintHintText(client,"Dollars: [%.1i$/%.1i$]\n----[%.1i/%.1i/%.1i]----", i_Dollars_Ammount[client],CASINO_MAX_DOLLARS,i_slot1[client],i_slot2[client],i_slot3[client]);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}

public void Enable_Casino(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Casino_Management[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASINO)
		{
			//Is the weapon it again?
			//Yes?
			i_Current_Pap[client] = Casino_Get_Pap(weapon);
			KillTimer(Timer_Casino_Management[client]);
			Timer_Casino_Management[client] = INVALID_HANDLE;
			DataPack pack;
			Timer_Casino_Management[client] = CreateDataTimer(0.1, Timer_Management_Casino, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASINO) //
	{
		i_Current_Pap[client] = Casino_Get_Pap(weapon);

		DataPack pack;
		Timer_Casino_Management[client] = CreateDataTimer(0.1, Timer_Management_Casino, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Casino(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Casino_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Casino(client);
		}
		else
			Kill_Timer_Casino(client);
	}
	else
		Kill_Timer_Casino(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Casino(int client)
{
	if (Timer_Casino_Management[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Casino_Management[client]);
		Timer_Casino_Management[client] = INVALID_HANDLE;
	}
}

public void Casino_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASINO) //Double check to see if its good or bad :(
		{	
			//Do your code here :) < ok :)
			if(Casino_hud_delay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					Casino_Show_Hud(client);
					i_Current_Pap[client] = Casino_Get_Pap(weapon);
				}
				Casino_hud_delay[client] = GetGameTime() + 0.5;
			}
		}
		else
		{
			Kill_Timer_Casino(client);
		}
	}
	else
	{
		Kill_Timer_Casino(client);
	}
}
////////////////////////