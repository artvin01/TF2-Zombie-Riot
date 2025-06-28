#pragma semicolon 1
#pragma newdecls required

//If i see any of you using this on any bvb hale i will kill you and turn you into a kebab.
//This shit is so fucking unfair for the targeted.

Handle h_TimerMg42Mangement[MAXPLAYERS+1] = {null, ...};
bool b_WeaponAccuracyModified[MAXENTITIES];
bool b_WeaponAttackspeedModified[MAXENTITIES];
float f_MG42huddelay[MAXPLAYERS+1];

void MG42_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	Zero(h_TimerMg42Mangement);
}

void Reset_stats_MG42_Singular_Weapon(int weapon) //This is on weapon remake. cannot set to 0 outright.
{
	b_WeaponAccuracyModified[weapon] = false;
	b_WeaponAttackspeedModified[weapon] = false;
}

public void Weapon_MG42_DoubleStrike(int client, int weapon, int StandingStill)
{
	float Accuracy = Attributes_Get(weapon, 106, 1.0);
	if(b_WeaponAccuracyModified[weapon] && StandingStill == 0)
	{
		Accuracy = (Accuracy / 0.2);
		Attributes_Set(weapon, 106, Accuracy);
		b_WeaponAccuracyModified[weapon] = false;
	}
	else if(!b_WeaponAccuracyModified[weapon] && StandingStill > 0)
	{
		Accuracy = (Accuracy * 0.2);
		Attributes_Set(weapon, 106, Accuracy);
		b_WeaponAccuracyModified[weapon] = true;
	}

	float Reloadspeed = Attributes_Get(weapon, 97, 1.0);

	if(b_WeaponAttackspeedModified[weapon] && StandingStill != 2)
	{
		Reloadspeed = (Reloadspeed / 0.8);
		Attributes_Set(weapon, 97, Reloadspeed);
		b_WeaponAttackspeedModified[weapon] = false;
	}
	else if(!b_WeaponAttackspeedModified[weapon] && StandingStill == 2)
	{
		Reloadspeed = (Reloadspeed * 0.8);
		Attributes_Set(weapon, 97, Reloadspeed);
		b_WeaponAttackspeedModified[weapon] = true;
	}
}

public void Enable_MG42(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerMg42Mangement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MG42) //6 Is for Passanger
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerMg42Mangement[client];
			h_TimerMg42Mangement[client] = null;
			DataPack pack;
			h_TimerMg42Mangement[client] = CreateDataTimer(0.25, Timer_Management_MG42, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MG42) //6 is for MG42.
	{
		DataPack pack;
		h_TimerMg42Mangement[client] = CreateDataTimer(0.25, Timer_Management_MG42, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_MG42(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerMg42Mangement[client] = null;
		return Plugin_Stop;
	}	
	MG42_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}


public void MG42_Cooldown_Logic(int client, int weapon)
{
	if(f_MG42huddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			int StandingStill = 0;
			float SubjectAbsVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
			if(MovementSpreadSpeedTooLow(SubjectAbsVelocity))
			{
				StandingStill = 1;
				if((GetEntityFlags(client) & FL_DUCKING))
				{
					StandingStill = 2;
				}
			}
	

			if(StandingStill == 2)
			{
				PrintHintText(client,"마운트 견착 기관총 모드!");
			}
			else if(StandingStill == 1)
			{
				PrintHintText(client,"MG42 명중률 최대 상태.");
			}
			else
			{
				PrintHintText(client,"MG42 명중률 감소 상태!!");
			}

			Weapon_MG42_DoubleStrike(client, weapon, StandingStill);
			
			
			f_MG42huddelay[client] = GetGameTime() + 0.45;
		}
	}
}