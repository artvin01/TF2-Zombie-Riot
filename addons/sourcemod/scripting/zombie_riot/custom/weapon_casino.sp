#pragma semicolon 1
#pragma newdecls required

Handle Timer_Casino_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static Handle DamageFalloff_timer[MAXPLAYERS+1];
static Handle AmmoRefill_timer[MAXPLAYERS+1];
static Handle Frenzy_timer[MAXPLAYERS+1];
<<<<<<< Updated upstream
=======
static Handle Payday_timer[MAXPLAYERS+1];

char g_RandomColoursDo[][] = {
	"aliceblue", 
	"allies",
	"ancient",
	"antiquewhite",
	"aqua", 
	"aquamarine",
	"arcana",
	"axis",
	"azure",
	"beige",
	"bisque",
	"black",
	"blue", 
	"blueviolet",
	"brown",
	"burlywood", 
	"cadetblue", 
	"chartreuse",
	"chocolate", 
	"collectors",
	"common",
	"community", 
	"coral",
	"cornsilk",
	"corrupted", 
	"crimson",
	"cyan",
	"darkblue", 
	"darkcyan", 
	"darkgray", 
	"darkgrey",
	"darkgreen", 
	"darkkhaki", 
	"darkmagenta",
	"darkolivegreen",
	"darkorange",
	"darkorchid",
	"darkred",
	"darksalmon",
	"darkseagreen",
	"darkslateblue",
	"darkviolet",
	"deeppink",
	"deepskyblue",
	"dimgray",
	"dimgrey",
	"dodgerblue",
	"exalted",
	"firebrick", 
	"floralwhite",
	"forestgreen",
	"frozen", 
	"fuchsia", 
	"fullblue",
	"fullred",
	"gainsboro", 
	"genuine",
	"ghostwhite",
	"gold",
	"goldenrod", 
	"gray",
	"grey",
	"green", 
	"greenyellow",
	"haunted",
	"honeydew",
	"hotpink", 
	"immortal",
	"indianred",
	"indigo", 
	"ivory",
	"khaki", 
	"lavender", 
	"lawngreen", 
	"legendary", 
	"lightblue", 
	"lightcoral",
	"lightcyan", 
	"lightgray", 
	"lightgrey", 
	"lightgreen",
	"lightpink", 
	"lightsalmon",
	"lightyellow",
	"lime", 
	"limegreen", 
	"linen",
	"magenta",
	"maroon",
	"mediumblue",
	"mintcream", 
	"mistyrose", 
	"moccasin",
	"mythical",
	"navajowhite",
	"navy", 
	"normal",
	"oldlace", 
	"olive",
	"olivedrab", 
	"orange",
	"orangered", 
	"orchid",
	"palegreen", 
	"papayawhip",
	"peachpuff", 
	"peru",
	"pink",
	"plum",
	"powderblue",
	"purple",
	"rare",
	"red",
	"rosybrown", 
	"royalblue", 
	"saddlebrown",
	"salmon", 
	"sandybrown",
	"seagreen",
	"seashell",
	"selfmade",
	"sienna",
	"silver", 
	"skyblue",
	"slateblue", 
	"slategray", 
	"slategrey", 
	"snow", 
	"springgreen",
	"steelblue", 
	"strange", 
	"tan", 
	"teal", 
	"thistle",
	"tomato",
	"turquoise", 
	"uncommon", 
	"unique", 
	"unusual",
	"valve", 
	"vintage",
	"violet", 
	"wheat", 
	"white",
	"whitesmoke",
	"yellow",
	"yellowgreen",
};

/*
	TO DO
	1a) An ability that paps the weapon for free - i cant do this on my own ill have to ask artvin for helpsies
	||1b) Pap 1, 3, 5 and 7 that are in-between paps - easy ??? i do this later.
	||2) Switch blood ammo to slots 7/7/X - very easy|| DONE
	||3) Make PayDay ability (more cash) - doable for me [X]
	|| 4) Redo The Big One - doable for me
	||5) Replace Cryo bullets with Cursed bullets - relatively simple - NO IT WASNT [X]
	6) Make the buffs into actual timers so that they don't disappear when the weapon gets updated somehow - incredibly time consuming but should be doable - NEVERMIND!
	||7) config changes (damage, around 10% unpapped, 10% papped, 25% 2nd pap and 30% 3rd pap) - I LOVE TESTING I LOVE TESTING [X]? - this will obviously need to be tested in game
*/
>>>>>>> Stashed changes

static float Casino_hud_delay[MAXTF2PLAYERS];
static float fl_Damage_Ammount[MAXTF2PLAYERS+1];

//cooldowns lol//
static float fl_minor_damage_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_speed_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_reload_cooldown[MAXTF2PLAYERS+1];
static float fl_minor_accuracy_cooldown[MAXTF2PLAYERS+1];

static float fl_major_damage_cooldown[MAXTF2PLAYERS+1];
static float fl_major_speed_cooldown[MAXTF2PLAYERS+1];
static float fl_ammo_cooldown[MAXTF2PLAYERS+1];
static float fl_frenzy_cooldown[MAXTF2PLAYERS+1];
//static float fl_jackpot_cooldown[MAXTF2PLAYERS+1];
////////////////

static int i_CryoShot[MAXTF2PLAYERS+1];
static int i_MegaShot[MAXTF2PLAYERS+1];
static int i_Ricochet[MAXTF2PLAYERS+1];
static int i_Dollars_Ammount[MAXTF2PLAYERS+1];
static int i_slot1[MAXTF2PLAYERS+1];
static int i_slot2[MAXTF2PLAYERS+1];
static int i_slot3[MAXTF2PLAYERS+1];
static int i_Current_Pap[MAXTF2PLAYERS+1];
static int LastHitTarget;

static bool CryoEasy;

#define CASINO_MAX_DOLLARS 100
#define CASINO_SALARY_GAIN_PER_HIT 1
#define CASINO_DAMAGE_GAIN_PER_HIT 0.5
#define CASINO_MAX_DAMAGE 50.0


public void Casino_MapStart() //idk what to precisely precache so hopefully this is good enough
{
	//normal stuff//
	Zero(Timer_Casino_Management);
	Zero(i_Dollars_Ammount);
	Zero(i_CryoShot);
	Zero(i_MegaShot);
	Zero(i_Ricochet);
	Zero(Casino_hud_delay);
	Zero(fl_Damage_Ammount);
	PrecacheSound("ambient/explosions/explode_3.wav");

	//cooldowns//
	Zero(fl_minor_damage_cooldown);
	Zero(fl_minor_speed_cooldown);
	Zero(fl_minor_reload_cooldown);
	Zero(fl_minor_accuracy_cooldown);

	Zero(fl_major_damage_cooldown);
	Zero(fl_major_speed_cooldown);
	Zero(fl_ammo_cooldown);
	Zero(fl_frenzy_cooldown);
//	Zero(fl_jackpot_cooldown);
}

/*void Reset_stats_Casino_Global()
{
	Zero(Casino_hud_delay);
}*/

public float Npc_OnTakeDamage_Casino(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3]) //cash gain on hit for each pap + damage modifier
{
	float damageMod = ((fl_Damage_Ammount[attacker] / 100.0) + 1.0);
	if(damagetype & DMG_BULLET) //boculum
	{
		int pap = i_Current_Pap[attacker];
		switch(pap)
		{
			case 0:
			{
				i_Dollars_Ammount[attacker] += CASINO_SALARY_GAIN_PER_HIT;
				if(i_Dollars_Ammount[attacker]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[attacker] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[attacker] += CASINO_DAMAGE_GAIN_PER_HIT;
				if(fl_Damage_Ammount[attacker]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[attacker] = CASINO_MAX_DAMAGE;
			}
			case 1:
			{
				i_Dollars_Ammount[attacker] += CASINO_SALARY_GAIN_PER_HIT * 2;
				if(i_Dollars_Ammount[attacker]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[attacker] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[attacker] += CASINO_DAMAGE_GAIN_PER_HIT * 2.0;
				if(fl_Damage_Ammount[attacker]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[attacker] = CASINO_MAX_DAMAGE;
			}
			case 2:
			{
				i_Dollars_Ammount[attacker] += CASINO_SALARY_GAIN_PER_HIT * 2;
				if(i_Dollars_Ammount[attacker]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[attacker] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[attacker] += CASINO_DAMAGE_GAIN_PER_HIT * 2.0;
				if(fl_Damage_Ammount[attacker]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[attacker] = CASINO_MAX_DAMAGE;
			}
			case 3,4:
			{
				i_Dollars_Ammount[attacker] += CASINO_SALARY_GAIN_PER_HIT * 3;
				if(i_Dollars_Ammount[attacker]>=CASINO_MAX_DOLLARS)
					i_Dollars_Ammount[attacker] = CASINO_MAX_DOLLARS;

				fl_Damage_Ammount[attacker] += CASINO_DAMAGE_GAIN_PER_HIT * 3.0;
				if(fl_Damage_Ammount[attacker]>= CASINO_MAX_DAMAGE)
					fl_Damage_Ammount[attacker] = CASINO_MAX_DAMAGE;
			}
		}
	}
	if(i_Ricochet[attacker] >= 1 && i_MegaShot[attacker] == 0)
	{
		if(LastHitTarget != victim && !(damagetype & DMG_SLASH) && !(damagetype & DMG_BLAST))
		{
			damageMod *= 0;
			damagetype |= DMG_SLASH;
			int value = i_ExplosiveProjectileHexArray[attacker];
			i_ExplosiveProjectileHexArray[attacker] = 0;	// If DMG_SLASH doesn't block NPC_OnTakeDamage_Equipped_Weapon_Logic, adjust this
			LastHitTarget = victim;
			
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 250.0, 0.83, _, false, 4);		
			i_ExplosiveProjectileHexArray[attacker] = value;
			LastHitTarget = 0;
			i_Ricochet[attacker] -= 1;
		}
	}
	if(i_MegaShot[attacker] >= 1)
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		int ammo = GetEntData(weapon, iAmmoTable, 4);//Get ammo clip
		damageMod += 5 + ammo;
		i_MegaShot[attacker] -= 1;
		ApplyTempAttrib(weapon, 97, 1.2, 3.0);
		SetEntData(weapon, iAmmoTable, 0, 4, true);
		DataPack pack = new DataPack();
		pack.WriteCell(GetClientUserId(attacker));
		pack.WriteCell(EntIndexToEntRef(weapon));
		Update_Ammo(pack);
		Client_Shake(attacker, 0, (((ammo * 3.0)/2.0) + 25.0), 20.0, 0.8);
		EmitSoundToAll("ambient/explosions/explode_3.wav", attacker, SNDCHAN_STATIC, 70, _, 1.0);
	}
	if(i_CryoShot[attacker] >= 1 && i_MegaShot[attacker] == 0)
	{
		if((f_HighIceDebuff[victim] - 1.4) < GetGameTime())
		{
			f_HighIceDebuff[victim] = GetGameTime() + 1.5;
		}
		if(CryoEasy == true)
		{
			i_CryoShot[attacker] -= 1;
		}
	}
	return damage *= damageMod;
}

void CasinoSalaryPerKill(int client, int weapon) //cash gain on KILL MURDER OBLITERATE ANNIHILATE GRAAAAAAA
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
		case 3,4:
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
	}
	if(AmmoRefill_timer[client])
	{
		int AmmoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
		AddAmmoClient(client, AmmoType ,(pap * 2) + 4,1.0, true);
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

public void Weapon_Casino_M1(int client, int weapon)
{
	switch(DamageFalloff_timer[client])
	{
		case INVALID_HANDLE:
		{
			i_WeaponDamageFalloff[weapon] = 0.9;
		}
		default:
		{
			i_WeaponDamageFalloff[weapon] = 1.0;
		}
	}
	if(i_CryoShot[client] > 1)
	{
		i_CryoShot[client] -= 1;
		CryoEasy = false;
	}
	else
	{
		CryoEasy = true;
	}
}

public void Weapon_Casino_M2(int client, int weapon)
{
	switch(Frenzy_timer[client])
	{
		case INVALID_HANDLE:
		{
			if (i_Dollars_Ammount[client] >= 20) //only go through if you can afford it
			{
				i_Dollars_Ammount[client] -= CASINO_SALARY_GAIN_PER_HIT * 20; //cost of slots
				fl_Damage_Ammount[client] -= CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
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
		default:
		{
			ROLL_THE_SLOTS(client, weapon);
		}
	}
}

public Action DamageFalloffCasino(Handle cut_timer, int client)
{
	DamageFalloff_timer[client] = null;
	return Plugin_Handled;
}

public Action AmmoRefillCasino(Handle cut_timer, int client)
{
	AmmoRefill_timer[client] = null;
	return Plugin_Handled;
}

public Action FrenzyCasino(Handle cut_timer, int client)
{
	Frenzy_timer[client] = null;
	return Plugin_Handled;
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
						ApplyTempAttrib(weapon, 2, 1.5, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage+]!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex1.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.6, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage+]!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex1.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.65, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage+]!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex1.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 1.7, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage+]!");
						fl_minor_damage_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex1.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Damage+]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
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
						ApplyTempAttrib(weapon, 6, 0.85, 75.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed+]!");
						fl_minor_speed_cooldown[client] = GameTime + 75.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex3.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 6, 0.8, 75.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed+]!");
						fl_minor_speed_cooldown[client] = GameTime + 75.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex3.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 6, 0.8, 75.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed+]!");
						fl_minor_speed_cooldown[client] = GameTime + 75.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex3.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 6, 0.75, 75.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed+]!");
						fl_minor_speed_cooldown[client] = GameTime + 75.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex3.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Firing Speed+]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 3: //reload
		{
			if(fl_minor_reload_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 97, 0.7, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Reload+]!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex2.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 97, 0.6, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Reload+]!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex2.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 97, 0.55, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Reload+]!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex2.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 97, 0.5, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Reload+]!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex2.wav");
					}
<<<<<<< Updated upstream
=======
					case 4:
					{
						ApplyTempAttrib(weapon, 97, 0.4, 60.0);

						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Reload+]!");
						fl_minor_reload_cooldown[client] = GameTime + 60.0;
						ClientCommand(client, "playgamesound ui/hitsound_vortex2.wav");
					}
>>>>>>> Stashed changes
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Reload+]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 4: //perfect accuracy + no dmg fall off
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
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy]!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;

						delete DamageFalloff_timer[client];
						DamageFalloff_timer[client] = CreateTimer(60.0, DamageFalloffCasino, client);
						
						ClientCommand(client, "playgamesound ui/hitsound_space.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.1, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy]!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;

						delete DamageFalloff_timer[client];
						DamageFalloff_timer[client] = CreateTimer(60.0, DamageFalloffCasino, client);
						
						ClientCommand(client, "playgamesound ui/hitsound_space.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.15, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy]!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;

						delete DamageFalloff_timer[client];
						DamageFalloff_timer[client] = CreateTimer(60.0, DamageFalloffCasino, client);
						
						ClientCommand(client, "playgamesound ui/hitsound_space.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 106, 0.1, 60.0);
						ApplyTempAttrib(weapon, 2, 1.2, 60.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Perfect accuracy]!");
						fl_minor_accuracy_cooldown[client] = GameTime + 60.0;

						delete DamageFalloff_timer[client];
						DamageFalloff_timer[client] = CreateTimer(60.0, DamageFalloffCasino, client);
						
						ClientCommand(client, "playgamesound ui/hitsound_space.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Perfect accuracy]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 5: //C bullets
		{
			switch(pap)
			{
				case 0:
				{
					i_CryoShot[client] += GetRandomInt(25,30);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Cryo Shots]!");
					ClientCommand(client, "playgamesound ui/hitsound_retro5.wav");
				}
				case 1:
				{
					i_CryoShot[client] += GetRandomInt(40,45); 
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Cryo Shots]!");
					ClientCommand(client, "playgamesound ui/hitsound_retro5.wav");
				}
				case 2:
				{
					i_CryoShot[client] += GetRandomInt(50,55); 
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Cryo Shots]!");
					ClientCommand(client, "playgamesound ui/hitsound_retro5.wav");
				}
				case 3:
				{
					i_CryoShot[client] += GetRandomInt(55,70); 
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Cryo shots]!");
					ClientCommand(client, "playgamesound ui/hitsound_retro5.wav");
				}
			}
		}
		case 6: //cash
		{
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 70;
			if(i_Dollars_Ammount[client]>=CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}
			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 70.0;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Gain [a few dollars]!");
			ClientCommand(client, "playgamesound mvm/mvm_money_pickup.wav");
		}
		case 8: //major damage
		{
			if(fl_major_damage_cooldown[client] < GameTime)
			{
				switch(pap)
				{
					case 0:
					{
						ApplyTempAttrib(weapon, 2, 1.8, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage++]!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound ui/killsound_beepo.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.9, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage++]!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound ui/killsound_beepo.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.95, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage++]!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound ui/killsound_beepo.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 2.0, 120.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Damage++]!");
						fl_major_damage_cooldown[client] = GameTime + 120.0;
						ClientCommand(client, "playgamesound ui/killsound_beepo.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Damage++]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
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
						ApplyTempAttrib(weapon, 6, 0.7, 100.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed++]!");
						fl_major_speed_cooldown[client] = GameTime + 100.0;
						ClientCommand(client, "playgamesound ui/killsound_vortex.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 6, 0.65, 100.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed++]!");
						fl_major_speed_cooldown[client] = GameTime + 100.0;
						ClientCommand(client, "playgamesound ui/killsound_vortex.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 6, 0.60, 100.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed++]!");
						fl_major_speed_cooldown[client] = GameTime + 100.0;
						ClientCommand(client, "playgamesound ui/killsound_vortex.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 6, 0.55, 100.0);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[Firing Speed++]!");
						fl_major_speed_cooldown[client] = GameTime + 100.0;
						ClientCommand(client, "playgamesound ui/killsound_vortex.wav");
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Firing Speed++]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 10: //Gain ammo on kill
		{
			if(fl_ammo_cooldown[client] < GameTime)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "[Blood Ammo!]");
				fl_ammo_cooldown[client] = GameTime + 100.0;

				delete AmmoRefill_timer[client];
				AmmoRefill_timer[client] = CreateTimer(100.0, AmmoRefillCasino, client);

				ClientCommand(client, "playgamesound ui/killsound_space.wav");
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [Blood Ammo]!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 20;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 20.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
			}
		}
		case 11: //your next hits consumes your entire clip but gain that much damage
		{
			switch(pap)
			{
				case 0:
				{
					i_MegaShot[client] += GetRandomInt(1, 2);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[The Big One]");
					ClientCommand(client, "playgamesound ui/killsound_squasher.wav");
				}
				case 1:
				{
					i_MegaShot[client] += GetRandomInt(1, 3);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[The Big One]");
					ClientCommand(client, "playgamesound ui/killsound_squasher.wav");
				}
				case 2:
				{
					i_MegaShot[client] += GetRandomInt(2, 3);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[The Big One]");
					ClientCommand(client, "playgamesound ui/killsound_squasher.wav");
				}
				case 3:
				{
					i_MegaShot[client] += GetRandomInt(2, 4);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[The Big One]");
					ClientCommand(client, "playgamesound ui/killsound_squasher.wav");
				}
			}
		}
		case 12: //R bullets
		{
			switch(pap)
			{
				case 0:
				{
					i_Ricochet[client] += GetRandomInt(40, 60);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Ricochet]!");
					ClientCommand(client, "playgamesound ui/killsound_electro.wav");
				}
				case 1:
				{
					i_Ricochet[client] += GetRandomInt(50, 70);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Ricochet]!");
					ClientCommand(client, "playgamesound ui/killsound_electro.wav");
				}
				case 2:
				{
					i_Ricochet[client] += GetRandomInt(55, 75);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Ricochet]!");
					ClientCommand(client, "playgamesound ui/killsound_electro.wav");
				}
				case 3:
				{
					i_Ricochet[client] += GetRandomInt(65, 85);
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[Ricochet]!");
					ClientCommand(client, "playgamesound ui/killsound_electro.wav");
				}
			}		
		}
		case 13: //GAMBLING FRENZY!"!!''''"
		{
			if(fl_frenzy_cooldown[client] < GameTime)
			{
				delete Frenzy_timer[client];
				Frenzy_timer[client] = CreateTimer(3.5, FrenzyCasino, client);

				fl_frenzy_cooldown[client] = GameTime + 4.0;
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "[GAMBLING FRENZY]!!!");
				ClientCommand(client, "playgamesound ui/killsound_retro.wav");
			}
		}
		case 14: //jackpot
		{
			switch(pap)
			{
				case 0:
				{
<<<<<<< Updated upstream
					case 0:
					{
						ApplyTempAttrib(weapon, 2, 1.35, 90.0);
						ApplyTempAttrib(weapon, 6, 0.8, 90.0);
						ApplyTempAttrib(weapon, 4, 1.3, 90.0);
						
						i_CryoShot[client] += 7;
						i_Ricochet[client] += 7;

						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
					}
					case 1:
					{
						ApplyTempAttrib(weapon, 2, 1.4, 90.0);
						ApplyTempAttrib(weapon, 6, 0.70, 90.0);
						ApplyTempAttrib(weapon, 4, 1.25, 90.0);
						
						i_CryoShot[client] += 7;
						i_MegaShot[client] += 1;
						i_Ricochet[client] += 7;

						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
					}
					case 2:
					{
						ApplyTempAttrib(weapon, 2, 1.45, 90.0);
						ApplyTempAttrib(weapon, 6, 0.65, 90.0);
						ApplyTempAttrib(weapon, 4, 1.2, 90.0);

						i_CryoShot[client] += 7;
						i_MegaShot[client] += 1;
						i_Ricochet[client] += 7;

						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
					}
					case 3:
					{
						ApplyTempAttrib(weapon, 2, 1.5, 90.0);
						ApplyTempAttrib(weapon, 6, 0.625, 90.0);
						ApplyTempAttrib(weapon, 4, 1.3, 90.0);

						i_CryoShot[client] += 7;
						i_MegaShot[client] += GetRandomInt(1,2);
						i_Ricochet[client] += 7;

						SetDefaultHudPosition(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
						fl_jackpot_cooldown[client] = GameTime + 90.0;
						ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");					
					}
				}
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You already have [JACKPOT]. How lucky!");
				i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * 100;
				if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
				{
					i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
				}
				
				fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * 100.0;
				if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
				{
					fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
				}
=======
					Store_WeaponUpgradeByOnePap(client, weapon);
					SetDefaultHudPosition(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
					ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
				}
				case 1:
				{
					Store_WeaponUpgradeByOnePap(client, weapon);

					SetDefaultHudPosition(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
					ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
				}
				case 2:
				{
					Store_WeaponUpgradeByOnePap(client, weapon);

					SetDefaultHudPosition(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
					ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
				}
				case 3:
				{
					Store_WeaponUpgradeByOnePap(client, weapon);

					SetDefaultHudPosition(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]");
					
					for(int RandomLoop; RandomLoop < 15; RandomLoop++)
					{
						CPrintToChatAll("{%s}%N {%s}HAS GOTTEN THE {%s}BIG WINS!!!!!",g_RandomColoursDo[GetRandomInt(0, sizeof(g_RandomColoursDo) - 1)], client,g_RandomColoursDo[GetRandomInt(0, sizeof(g_RandomColoursDo) - 1)],g_RandomColoursDo[GetRandomInt(0, sizeof(g_RandomColoursDo) - 1)]);		
					}	
					for(int client1=1; client1<=MaxClients; client1++)
					{
						if(IsClientConnected(client1))
						{
							ClientCommand(client1, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");		
						}
					}	
				}
				case 4:
				{
					SetDefaultHudPosition(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "[|- JACKPOT 7/7/7 -|]\nSadly the casino banned you for cheating.");
					ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");			
				}
>>>>>>> Stashed changes
			}
		}
		default: //womp womp
		{
			int RNG = GetRandomInt(0,7);
			ClientCommand(client, "playgamesound ui/item_helmet_drop.wav");
			i_Dollars_Ammount[client] += CASINO_SALARY_GAIN_PER_HIT * RNG;
			if(i_Dollars_Ammount[client]>= CASINO_MAX_DOLLARS)
			{
				i_Dollars_Ammount[client] = CASINO_MAX_DOLLARS;
			}

			fl_Damage_Ammount[client] += CASINO_DAMAGE_GAIN_PER_HIT * RNG;
			if(fl_Damage_Ammount[client]>= CASINO_MAX_DAMAGE)
			{
				fl_Damage_Ammount[client] = CASINO_MAX_DAMAGE;
			}
		}
	}
}


///FUCK YOU TF2 HUDS///
static void Casino_Show_Hud(int client)
{
	switch(Frenzy_timer[client])
	{
		case INVALID_HANDLE:
		{
			PrintHintText(client,"----[%.1i/%.1i/%.1i]----\nDollars: [%.1i$/%.1i$]\nSpecial Bullets: [%.1i R.|%.1i T.B.O.|%.1i C.]",i_slot1[client],i_slot2[client],i_slot3[client], i_Dollars_Ammount[client],CASINO_MAX_DOLLARS,i_Ricochet[client],i_MegaShot[client],i_CryoShot[client]);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		}
		default:
		{
			PrintHintText(client,"----[FRENZY ACTIVE]----\nDollars: [SPAM / M2]\nSpecial Bullets: [%.1i R.|%.1i T.B.O.|%.1i C.]",i_Ricochet[client],i_MegaShot[client],i_CryoShot[client]);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		}
	}
}

public void Enable_Casino(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Casino_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASINO)
		{
			//Is the weapon it again?
			//Yes?
			i_Current_Pap[client] = Casino_Get_Pap(weapon);
			delete Timer_Casino_Management[client];
			Timer_Casino_Management[client] = null;
			DataPack pack;
			Timer_Casino_Management[client] = CreateDataTimer(0.1, Timer_Management_Casino, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CASINO) //
	{
		i_Current_Pap[client] = Casino_Get_Pap(weapon);

		DataPack pack;
		Timer_Casino_Management[client] = CreateDataTimer(0.1, Timer_Management_Casino, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Casino(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Casino_Management[client] = null;
		return Plugin_Stop;
	}	

	Casino_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}

public void Casino_Cooldown_Logic(int client, int weapon)
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