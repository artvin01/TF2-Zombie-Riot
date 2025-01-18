#define SUPERUBERSAW_DAMAGE_1	"ambient/sawblade_impact1.wav"

Handle h_TimerSuperubersawAlterManagement[MAXPLAYERS+1] = {null, ...};
static float f_SuperubersawAlterhuddelay[MAXPLAYERS+1]={0.0, ...};
static int i_Superubersaw_HealAquired[MAXPLAYERS+1]={0, ...};
static int i_Superubersaw_HealAquiredMaxCalc[MAXPLAYERS+1]={0, ...};

#define SUPERUBERSAW_MAXHEALTILLFULL 500.0


void AddHealthToUbersaw(int client, int healthvalue, float autoscale = 0.0)
{
	//they posses no ubersaw.
	if(h_TimerSuperubersawAlterManagement[client] == null)
		return;

	if(autoscale != 0.0)
	{
		healthvalue = RoundToCeil(float(i_Superubersaw_HealAquiredMaxCalc[client]) * autoscale);
	}

	i_Superubersaw_HealAquired[client] += healthvalue;
	if(i_Superubersaw_HealAquired[client] >= i_Superubersaw_HealAquiredMaxCalc[client])
		i_Superubersaw_HealAquired[client] = i_Superubersaw_HealAquiredMaxCalc[client];
}

public bool SuperUbersaw_Existant(int client)
{
	if(h_TimerSuperubersawAlterManagement[client] != null)
	{
		return true
	}
	return false;
}

float SuperUbersawPercentage(int client)
{
	float RatioMax;
	RatioMax = float(i_Superubersaw_HealAquired[client]) / float(i_Superubersaw_HealAquiredMaxCalc[client]);

	if(RatioMax >= 1.0)
		RatioMax = 1.0;
	
	return RatioMax;
}

void SuperUbersaw_Mapstart()
{
	PrecacheSound(SUPERUBERSAW_DAMAGE_1);
	Zero(h_TimerSuperubersawAlterManagement);
	Zero(f_SuperubersawAlterhuddelay);

	Zero(i_Superubersaw_HealAquired);
}

bool PlayCustomSoundSuperubersaw(int client)
{
	float Ratio = SuperUbersawPercentage(client);
	if(Ratio >= 1.0)
	{
		EmitSoundToAll("items/powerup_pickup_knockout_melee_hit.wav", client, SNDCHAN_AUTO, 85,_,1.0);
		float partnerPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", partnerPos);
		CreateEarthquake(partnerPos, 0.5, 350.0, 16.0, 255.0);
		return true;
	}
	return false;
}
void SuperUbersaw_Post(int client)
{
	i_Superubersaw_HealAquired[client] = 0;
}


stock void Superubersaw_OnTakeDamage(int victim, int &attacker, float &damage)
{
	float Ratio = SuperUbersawPercentage(attacker);
	if(Ratio >= 0.5)
	{
		if (b_thisNpcIsARaid[victim])
		{
			damage *= 2.0;
		}
	}
	if(Ratio < 0.49)
	{
		damage *= 2.0;
	}
	else if(Ratio < 0.74)
	{
		damage *= 3.35;
	}
	else if(Ratio < 0.99)
	{
		damage *= 4.5;
	}
	else
	{
		damage *= 6.0;
		DisplayCritAboveNpc(victim, attacker, true);
		SensalCauseKnockback(attacker, victim, 1.5);
	}
	damage *= Attributes_GetOnPlayer(attacker, 8, true, true);

}

int SuperubersawHowManyEnemiesHit(int client)
{
	float Ratio = SuperUbersawPercentage(client);
	if(Ratio < 0.24)
	{
		return 1;
	}
	else if(Ratio < 0.49)
	{
		return 2;
	}
	else if(Ratio < 0.74)
	{
		return 3;
	}
	else if(Ratio < 0.99)
	{
		return 4;
	}
	else
	{
		return 7;
		//max power
	}
}

public Action Timer_Management_SuperubersawAlter(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerSuperubersawAlterManagement[client] = null;
		return Plugin_Stop;
	}	
	
	SuperubersawAlter_Cooldown_Logic(client, weapon);
	return Plugin_Continue;
}

public void SuperubersawAlter_Cooldown_Logic(int client, int weapon)
{
	if(f_SuperubersawAlterhuddelay[client] < GetGameTime())
	{
		f_SuperubersawAlterhuddelay[client] = GetGameTime() + 0.2;
		if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
		{
			if(SuperUbersawPercentage(client) >= 1.0)
				TF2_AddCondition(client, TFCond_CritOnKill, 0.3);
		}
	}
}
public void Enable_SuperubersawAlter(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SUPERUBERSAW)
	{
		delete h_TimerSuperubersawAlterManagement[client];
		h_TimerSuperubersawAlterManagement[client] = null;

		DataPack pack;
		h_TimerSuperubersawAlterManagement[client] = CreateDataTimer(0.1, Timer_Management_SuperubersawAlter, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		float Healing_Value = Attributes_GetOnWeapon(client, weapon, 8, true);

		i_Superubersaw_HealAquiredMaxCalc[client] = RoundToCeil(SUPERUBERSAW_MAXHEALTILLFULL * Healing_Value);
	}
}