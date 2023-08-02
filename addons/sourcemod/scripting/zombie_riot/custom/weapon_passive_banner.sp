#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Enable_Management_Banner(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management[client] != INVALID_HANDLE)
	{
		if(i_BuffBannerPassively[weapon] == 2)
		{
			Kill_Timer_Management_Banner(client);
		}
		else
		{
			return;
		}
	}

	if(i_BuffBannerPassively[weapon] == 2)
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
				if(i_BuffBannerPassively[weapon] == 2)
				{
					float BannerPos[3];
					float targPos[3];
					GetClientAbsOrigin(client, BannerPos);
					for(int ally=1; ally<=MaxClients; ally++)
					{
						if(IsClientInGame(ally) && IsPlayerAlive(ally))
						{
							GetClientAbsOrigin(ally, targPos);
							if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
							{
								f_BuffBannerNpcBuff[ally] = GetGameTime() + 1.1;
								i_ExtraPlayerPoints[client] += 1;
							}
						}
					}
					for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
					{
						int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
						if (IsValidEntity(ally) && !b_NpcHasDied[ally])
						{
							GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
							if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
							{
								f_BuffBannerNpcBuff[ally] = GetGameTime() + 1.1;
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






Handle Timer_Banner_Management_1[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Enable_Management_Banner_1(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management_1[client] != INVALID_HANDLE)
	{
		if(i_BuffBannerPassively[weapon] == 1)
		{
			Kill_Timer_Management_Banner_1(client);
		}
		else
		{
			return;
		}
	}

	if(i_BuffBannerPassively[weapon] == 1)
	{	
		DataPack pack;
		//The delay is usually 0.2 seconds.
		Timer_Banner_Management_1[client] = CreateDataTimer(0.1, Timer_Management_Banner_1, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Banner_1(Handle timer, DataPack pack)
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
				if(i_BuffBannerPassively[weapon] == 1)
				{
					if(f_BuffBannerNpcBuff[client] > GetGameTime())
					{
						float BannerPos[3];
						float targPos[3];
						GetClientAbsOrigin(client, BannerPos);
						for(int ally=1; ally<=MaxClients; ally++)
						{
							if(IsClientInGame(ally) && IsPlayerAlive(ally) && ally != client)
							{
								GetClientAbsOrigin(ally, targPos);
								if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
								{
									f_BuffBannerNpcBuff[ally] = GetGameTime() + 1.1;
									i_ExtraPlayerPoints[client] += 1;
								}
							}
						}
						for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
						{
							int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
							if (IsValidEntity(ally) && !b_NpcHasDied[ally])
							{
								GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
								if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
								{
									f_BuffBannerNpcBuff[ally] = GetGameTime() + 0.5;
									i_ExtraPlayerPoints[client] += 1;
								}
							}
						}
					}
				}
			}
			else
				Kill_Timer_Management_Banner_1(client);
		}
		else
			Kill_Timer_Management_Banner_1(client);
	}
	else
		Kill_Timer_Management_Banner_1(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_Banner_1(int client)
{
	if (Timer_Banner_Management_1[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Banner_Management_1[client]);
		Timer_Banner_Management_1[client] = INVALID_HANDLE;
	}
}








Handle Timer_Banner_Management_2[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Enable_Management_Banner_2(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management_2[client] != INVALID_HANDLE)
	{
		if(i_CustomWeaponEquipLogic[weapon] == 18)
		{
			Kill_Timer_Management_Banner_2(client);
		}
		else
		{
			return;
		}
	}

	if(i_CustomWeaponEquipLogic[weapon] == 18)
	{	
		DataPack pack;
		//The delay is usually 0.2 seconds.
		Timer_Banner_Management_2[client] = CreateDataTimer(0.1, Timer_Management_Banner_2, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Banner_2(Handle timer, DataPack pack)
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
				if(i_CustomWeaponEquipLogic[weapon] == 18)
				{
					if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
					{
						float BannerPos[3];
						float targPos[3];
						GetClientAbsOrigin(client, BannerPos);
						for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
						{
							int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
							if (IsValidEntity(ally) && !b_NpcHasDied[ally])
							{
								GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
								if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
								{
									f_BattilonsNpcBuff[ally] = GetGameTime() + 0.5;
									i_ExtraPlayerPoints[client] += 1;
								}
							}
						}
					}
				}
			}
			else
				Kill_Timer_Management_Banner_2(client);
		}
		else
			Kill_Timer_Management_Banner_2(client);
	}
	else
		Kill_Timer_Management_Banner_2(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_Banner_2(int client)
{
	if (Timer_Banner_Management_2[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Banner_Management_2[client]);
		Timer_Banner_Management_2[client] = INVALID_HANDLE;
	}
}




Handle Timer_Banner_Management_3[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

public void Enable_Management_Banner_3(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management_3[client] != INVALID_HANDLE)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
		{
			Kill_Timer_Management_Banner_3(client);
		}
		else
		{
			return;
		}
	}

	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
	{	
		DataPack pack;
		//The delay is usually 0.2 seconds.
		Timer_Banner_Management_3[client] = CreateDataTimer(0.1, Timer_Management_Banner_3, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Banner_3(Handle timer, DataPack pack)
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
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
				{
					if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
					{
						float BannerPos[3];
						float targPos[3];
						GetClientAbsOrigin(client, BannerPos);
						for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
						{
							int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
							if (IsValidEntity(ally) && !b_NpcHasDied[ally])
							{
								GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
								if (GetVectorDistance(BannerPos, targPos, true) <= 422500.0) // 650.0
								{
									f_BattilonsNpcBuff[ally] = GetGameTime() + 0.5;
									i_ExtraPlayerPoints[client] += 1;
								}
							}
						}
					}
				}
			}
			else
				Kill_Timer_Management_Banner_3(client);
		}
		else
			Kill_Timer_Management_Banner_3(client);
	}
	else
		Kill_Timer_Management_Banner_3(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Management_Banner_3(int client)
{
	if (Timer_Banner_Management_3[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Banner_Management_3[client]);
		Timer_Banner_Management_3[client] = INVALID_HANDLE;
	}
}

void AncientBannerActivate(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
	{
		PrintToChatAll("activated Banner");
	}
}