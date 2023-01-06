#pragma semicolon 1
#pragma newdecls required

#define IRENE_JUDGEMENT_MAX_HITS_NEEDED 64 	//Double the amount because we do double hits.
#define IRENE_JUDGEMENT_MAXRANGE 200.0 		

#define IRENE_MAX_HITUP 10

Handle h_TimerIreneManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_Irenehuddelay[MAXTF2PLAYERS];
static int i_IreneHitsDone[MAXTF2PLAYERS];
static float f_WeaponAttackSpeedModified[MAXENTITIES];
static int i_IreneTargetsAirborn[MAXTF2PLAYERS][IRENE_MAX_HITUP];
static float f_TargetAirtime[MAXENTITIES];

void Npc_OnTakeDamage_Iberia(int attacker, int damagetype, int weapon)
{
	if(damagetype & DMG_CLUB) //We only count normal melee hits.
	{
		i_IreneHitsDone[attacker] += 1;
		if(i_IreneHitsDone[attacker] > IRENE_JUDGEMENT_MAX_HITS_NEEDED) //We do not go above this, no double charge.
		{
			i_IreneHitsDone[attacker] = IRENE_JUDGEMENT_MAX_HITS_NEEDED;
		}
	}
}

void Irene_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	return;
}

void Reset_stats_Irene_Global()
{
	Zero(h_TimerIreneManagement);
	Zero(f_Irenehuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_IreneHitsDone); //This only ever gets reset on map change or player reset
}

void Reset_stats_Irene_Singular(int client) //This is on disconnect/connect
{
	i_IreneHitsDone[client] = 0;
}

void Reset_stats_Irene_Singular_Weapon(int client, int weapon) //This is on weapon remake. cannot set to 0 outright.
{
	f_WeaponAttackSpeedModified[weapon] = Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
}

public void Weapon_Irene_DoubleStrike(int client, int weapon, bool crit, int slot)
{
	//Show the timer, this is purely for looks and doesnt do anything.
//	float cooldown = 0.65 * Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);

	//We wish to do a double attack.
	//Delay it abit extra!

	
	/*
	LAZY WAY:
	DataPack pack;
	CreateDataTimer(0.25, Timer_Do_Melee_Attack, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteString("tf_weapon_knife"); //We will hardcode this to tf_weapon_knife because i am lazy as fuck. 
	*/
	/* 
		PRO WAY:
		So that animations display properly, we wish to accelerate the attackspeed massively by 1
		Issue: players can just delay the double attack
		Fix for this would be just just reset back to the original attack speed if they dont attack.
		This is annoying but this is really cool instead of the above LAZY method!

	*/
	//We save this onto the weapon if the modified attackspeed is not modified.

	float attackspeed = Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
	if(attackspeed > 0.35) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
	{
		TF2Attrib_SetByDefIndex(weapon, 6, attackspeed * 0.15); //Make it really fast for 1 hit!
		f_WeaponAttackSpeedModified[weapon] = attackspeed;
	}
	else
	{
		//The attackspeed was really fast. Lets set it back to normal.
		TF2Attrib_SetByDefIndex(weapon, 6, f_WeaponAttackSpeedModified[weapon]);
		f_WeaponAttackSpeedModified[weapon] = 0.0; //reset back to 0. Loop and repeat.
	}
}

public void Enable_Irene(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerIreneManagement[client] != INVALID_HANDLE)
		return;
		
	if(i_CustomWeaponEquipLogic[weapon] == 6) //6 is for irene.
	{
		DataPack pack;
		h_TimerIreneManagement[client] = CreateDataTimer(0.1, Timer_Management_Irene, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	else
	{
		Kill_Timer_Irene(client);
	}
}



public Action Timer_Management_Irene(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Irene_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Irene(client);
		}
		else
			Kill_Timer_Irene(client);
	}
	else
		Kill_Timer_Irene(client);
		
	return Plugin_Continue;
}


public void Irene_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == 6) //Double check to see if its good or bad :(
		{	
			if(f_Irenehuddelay[client] < GetGameTime())
			{
				if(i_IreneHitsDone[client] < IRENE_JUDGEMENT_MAX_HITS_NEEDED)
				{
					PrintHintText(client,"Judgemet Of Iberia [%i%/%i]", i_IreneHitsDone[client], IRENE_JUDGEMENT_MAX_HITS_NEEDED);
				}
				else
				{
					PrintHintText(client,"Judgemet Of Iberia [READY!]");
				}
				
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				f_Irenehuddelay[client] = GetGameTime() + 0.5;
			}
		}
		else
		{
			Kill_Timer_Irene(client);
		}
	}
	else
	{
		Kill_Timer_Irene(client);
	}
}

public void Kill_Timer_Irene(int client)
{
	if (h_TimerIreneManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerIreneManagement[client]);
		h_TimerIreneManagement[client] = INVALID_HANDLE;
	}
}



public void Weapon_Irene_Judgement(int client, int weapon, bool crit, int slot)
{
	//This ability has no cooldown in itself, it just relies on hits you do.
	if(i_IreneHitsDone[client] >= IRENE_JUDGEMENT_MAX_HITS_NEEDED)
	{
		//Sucess! You have enough charges.
		//Heavy logic incomming.
		float UserLoc[3], VicLoc[3];
		GetClientAbsOrigin(client, UserLoc);

		bool raidboss_active = false;
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			raidboss_active = true;
		}
		//Reset all airborn targets.
		for (int enemy = 1; enemy < IRENE_MAX_HITUP; enemy++)
		{
			i_IreneTargetsAirborn[client][building] = false;
		}

		//We want to lag compensate this.
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);

		for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
		{
			int target = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
			if(IsValidEntity(target) && !b_NpcHasDied[target])
			{
				static float Entity_Position[3];
				VicLoc = WorldSpaceCenter(target);
				
				if (GetVectorDistance(UserLoc, VicLoc,true) <= Pow(IRENE_JUDGEMENT_MAXRANGE, 2.0))
				{
					bool Hitlimit = true;
					for(int i=1; i <= (MAX_TARGETS_HIT -1 ); i++)
					{
						if(!i_IreneTargetsAirborn[client][i])
						{
							i_IreneTargetsAirborn[client][i] = entity;
							Hitlimit = false;
							break;
						}
					}
					if(Hitlimit)
					{
						break;
					}

					if (b_thisNpcIsABoss[target] || raidboss_active)
					{
						f_TargetAirtime[target] = GetGameTime(target) + 1.0; //Kick up for way less time.
					}
					else
					{
						f_TargetAirtime[target] = GetGameTime(target) + 3.0; //Kick up for the full skill duration.
					}
					//For now, there is no limit.
				}
			}
		}
		FinishLagCompensation_Base_boss();
		//End of logic, everything done regarding getting all enemies effected by this effect.
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255, 1, 0.1, 0.1, 0.1);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}