#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
int i_SetBannerType[MAXPLAYERS+1];
bool b_ClientHasAncientBanner[MAXENTITIES];
bool b_EntityRecievedBuff[MAXENTITIES];
Handle Timer_AncientBanner = INVALID_HANDLE;

void BannerOnEntityCreated(int entity)
{
	b_ClientHasAncientBanner[entity] = false;
	b_EntityRecievedBuff[entity] = false;
	f_AncientBannerNpcBuff[entity] = 0.0;
}

enum
{
	BuffBanner = 1,
	Battilons = 2,
	AncientBanner = 3
}

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
								f_BuffBannerNpcBuff[ally] = GetGameTime() + 0.5;
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
					if(f_BannerDurationActive[client] > GetGameTime())
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
									f_BuffBannerNpcBuff[ally] = GetGameTime() + 0.5;
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
					if(f_BannerDurationActive[client] > GetGameTime())
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
									f_BattilonsNpcBuff[ally] = GetGameTime() + 1.1;
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
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
	{	
		b_ClientHasAncientBanner[client] = true;
		if (Timer_AncientBanner == INVALID_HANDLE)
		{
			Timer_AncientBanner = CreateTimer(0.4, Timer_AncientBannerGlobal, _, TIMER_REPEAT);
		}
	}
}


public Action Timer_AncientBannerGlobal(Handle timer)
{
	bool ThereWasABuff = false;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && b_ClientHasAncientBanner[client])
		{
			ThereWasABuff = true;
			if(i_SetBannerType[client] != AncientBanner)
			{
				continue;
			}
			if(f_BannerDurationActive[client] < GetGameTime())
			{
				continue;
			}
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
						f_AncientBannerNpcBuff[ally] = GetGameTime() + 0.5;
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
						f_AncientBannerNpcBuff[ally] = GetGameTime() + 0.5;
					}
				}
			}
		}
	}
	if(ThereWasABuff)
	{
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				if(f_AncientBannerNpcBuff[ally] > GetGameTime())
				{
					ModifyEntityAncientBuff(ally, 1, 0.75, true, 1.25);

				}
				else
				{
					ModifyEntityAncientBuff(ally, 1, 0.75, false, 1.25);
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally])
			{
				if(f_AncientBannerNpcBuff[ally] > GetGameTime())
				{
					ModifyEntityAncientBuff(ally, 2, 0.75, true, 1.25);
				}
				else
				{
					ModifyEntityAncientBuff(ally, 2, 0.75, false, 1.25);
				}
			}
		}
	}
	else
	{
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				ModifyEntityAncientBuff(ally, 1, 0.75, false, 1.25);
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally])
			{
				ModifyEntityAncientBuff(ally, 2, 0.75, false, 1.25);
			}
		}
		Kill_Timer_AncientBanner_Buff();
	}
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
		i_SetBannerType[client] = AncientBanner;
	}
}

void BuffBannerActivate(int client, int weapon)
{
	if(i_BuffBannerPassively[weapon] == 1)
	{
		i_SetBannerType[client] = BuffBanner;
	}
}

void BuffBattilonsActivate(int client, int weapon)
{
	if(i_BuffBannerPassively[weapon] == 18)
	{
		i_SetBannerType[client] = Battilons;
	}
}


/*
	type:
	1: client
	2: entity
*/
void ModifyEntityAncientBuff(int entity, int type, float buffammount, bool GrantBuff = true, float buffammount2)
{
	if(type == 1)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(!b_EntityRecievedBuff[weapon])
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[weapon] = true;
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, buffammount);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, buffammount);	// Reload Time
					
					if(Attributes_Has(weapon, 8))
						Attributes_SetMulti(weapon, 8, buffammount2);	// Heal Rate
				}
			}
			else
			{
				if(!GrantBuff)
				{
					if(b_EntityRecievedBuff[weapon])
					{
						b_EntityRecievedBuff[weapon] = false;
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, 1.0 / buffammount);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, 1.0 / buffammount);	// Reload Time
						
						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / buffammount2);	// Heal Rate
					}
				}
			}
		}
	}
	else if(type == 2)
	{
		if(i_NpcInternalId[entity] == CITIZEN)
		{
			Citizen npc = view_as<Citizen>(entity);
			if(!b_EntityRecievedBuff[entity])
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[entity] = true;
					npc.m_fGunFirerate *= buffammount;
					npc.m_fGunReload *= buffammount;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					b_EntityRecievedBuff[entity] = false;
					npc.m_fGunFirerate /= buffammount;
					npc.m_fGunReload /= buffammount;
				}
			}
		}
		else if(entity > MaxClients)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(!b_EntityRecievedBuff[entity])
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[entity] = true;
					npc.BonusFireRate *= buffammount;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					b_EntityRecievedBuff[entity] = false;
					npc.BonusFireRate /= buffammount;
				}
			}
		}
	}
}




public void Kill_Timer_AncientBanner_Buff()
{
	if (Timer_AncientBanner != INVALID_HANDLE)
	{
		KillTimer(Timer_AncientBanner);
		Timer_AncientBanner = INVALID_HANDLE;
	}
}