#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Enable_Management_Banner(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management[client] != INVALID_HANDLE)
	{
		if(i_BuffBannerPassively[weapon] > 0)
		{
			Kill_Timer_Management_Banner(client);
		}
		else
		{
			return;
		}
	}

	if(i_BuffBannerPassively[weapon] > 0)
	{	
		DataPack pack;
		//The delay is usually 0.2 seconds.
		Timer_Banner_Management[client] = CreateDataTimer(0.1, Timer_Management_Banner, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Banner(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			if(IsValidEntity(weapon))
			{
				if(i_BuffBannerPassively[weapon] > 0)
				{
					float BannerPos[3];
					GetClientAbsOrigin(client, BannerPos);
					for(int ally=1; ally<=MaxClients; ally++)
					{
						if(IsClientInGame(ally) && IsPlayerAlive(ally))
						{
							float targPos[3];
							GetClientAbsOrigin(ally, targPos);
							if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
							{
								TF2_AddCondition(ally, TFCond_Buffed, 0.5, client); //So if they go out of range, they'll keep it abit
								i_ExtraPlayerPoints[client] += 1;
							}
						}
					}
				}
			}
			else
				Kill_Timer_Management_Banner(client);
		}
		else
			Kill_Timer_Management_Banner(client);
	}
	else
		Kill_Timer_Management_Banner(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_Banner(int client)
{
	if (Timer_Banner_Management[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Banner_Management[client]);
		Timer_Banner_Management[client] = INVALID_HANDLE;
	}
}