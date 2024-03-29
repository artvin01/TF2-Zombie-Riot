static int i_Current_Pap_Bloody_Edge[MAXTF2PLAYERS+1];

static float fl_Bloody_Edge_hud_delay[MAXTF2PLAYERS];

Handle Timer_Bloody_Edge_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Bloody_Edge_Attack(int client, int weapon, bool crit, int slot) // stats for the base version of the weapon
{
    PrintToChatAll("Yay");
}


static int Bloody_Edge_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

public float Player_OnTakeDamage_Bloody_Edge(int victim, int attacker, float &damage)
{
	//int pap = i_Current_Pap_Bloody_Edge[victim];
        PrintToChatAll("Ouch");
		return damage *= 0.9259; // 25% more damage taken
        

	/*switch(pap)
	{
		case 4:
		{
			return damage *= 0.8148; // 10% more damage taken
		}
		case 5:
		{
			return damage *= 0.7407; // 0% more damage taken
		}
		default:
		{
			return damage *= 0.8888; // 20% more damage taken
		}
	}
    */
}


public void Enable_Bloody_Edge(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Bloody_Edge_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLOODY_EDGE)
		{
			//Is the weapon it again?
			//Yes?
			i_Current_Pap_Bloody_Edge[client] = Bloody_Edge_Get_Pap(weapon);
			delete Timer_Bloody_Edge_Management[client];
			Timer_Bloody_Edge_Management[client] = null;
			DataPack pack;
			Timer_Bloody_Edge_Management[client] = CreateDataTimer(0.1, Timer_Management_Bloody_Edge, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLOODY_EDGE)
	{
		i_Current_Pap_Bloody_Edge[client] = Bloody_Edge_Get_Pap(weapon);

		DataPack pack;
		Timer_Bloody_Edge_Management[client] = CreateDataTimer(0.1, Timer_Management_Bloody_Edge, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Bloody_Edge(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Bloody_Edge_Management[client] = null;
		return Plugin_Stop;
	}	

	Bloody_Edge_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}

public void Bloody_Edge_Cooldown_Logic(int client, int weapon)
{
	//Do your code here :) < ok :)
	if(fl_Bloody_Edge_hud_delay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		int Health = GetEntProp(client, Prop_Send, "m_iHealth");
		float MaxHealth = float(SDKCall_GetMaxHealth(client));
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
        if(Health < MaxHealth)
        {
            PrintToChatAll("Damaged");
        }
		
		fl_Bloody_Edge_hud_delay[client] = GetGameTime() + 0.5;
	}
}