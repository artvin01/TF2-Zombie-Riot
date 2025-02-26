#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {null, ...};
int i_SetBannerType[MAXPLAYERS+1];
Handle Timer_AncientBanner = null;
Handle Timer_Banner_Management_2[MAXPLAYERS+1] = {null, ...};
Handle Timer_Banner_Management_1[MAXPLAYERS+1] = {null, ...};
static bool b_ClientHasAncientBanner[MAXENTITIES];

void BannerOnEntityCreated(int entity)
{
	b_ClientHasAncientBanner[entity] = false;
}
float BannerDefaultRange(bool normal = false)
{
	if(!normal)
		return 511225.0; //1.1x range
	else
		return 715.0;
}

enum
{
	BuffBanner = 1,
	Battilons = 2,
	AncientBanner = 3
}

int ClientHasBannersWithCD(int client)
{
	if(Timer_Banner_Management_1[client] != null)
		return BuffBanner;
	if(Timer_Banner_Management_2[client] != null)
		return Battilons;
	if(b_ClientHasAncientBanner[client])
		return AncientBanner;

	return 0;
}
public void Enable_Management_Banner(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management[client] != null)
	{
		if(i_BuffBannerPassively[weapon] == 2)
		{
			delete Timer_Banner_Management[client];
			Timer_Banner_Management[client] = null;
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
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Banner_Management[client] = null;
		return Plugin_Stop;
	}	
	b_ClientHasAncientBanner[client] = false;
	float BannerPos[3];
	float targPos[3];
	GetClientAbsOrigin(client, BannerPos);
	spawnRing_Vectors(BannerPos, BannerDefaultRange(true) * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 125, 1, 0.11, 5.0, 1.1, 5, _, client);	
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally))
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
			{
				ApplyStatusEffect(client, ally, "War Cry", 0.5);
				i_ExtraPlayerPoints[client] += 1;
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
			{
				ApplyStatusEffect(client, ally, "War Cry", 0.5);
				i_ExtraPlayerPoints[client] += 1;
			}
		}
	}
	return Plugin_Continue;
}







public void Enable_Management_Banner_1(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management_1[client] != null)
	{
		if(i_BuffBannerPassively[weapon] == 1)
		{
			delete Timer_Banner_Management_1[client];
			Timer_Banner_Management_1[client] = null;
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
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Banner_Management_1[client] = null;
		return Plugin_Stop;
	}	

	if(f_BannerDurationActive[client] > GetGameTime())
	{
		b_ClientHasAncientBanner[client] = false;
		float BannerPos[3];
		float targPos[3];
		GetClientAbsOrigin(client, BannerPos);
		spawnRing_Vectors(BannerPos, BannerDefaultRange(true) * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 125, 1, 0.11, 5.0, 1.1, 5, _, client);	
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				GetClientAbsOrigin(ally, targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "War Cry", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "War Cry", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
	}
		
	return Plugin_Continue;
}









public void Enable_Management_Banner_2(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Banner_Management_2[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == 18)
		{
			delete Timer_Banner_Management_2[client];
			Timer_Banner_Management_2[client] = null;
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
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Banner_Management_2[client] = null;
		return Plugin_Stop;
	}	
	if(f_BannerDurationActive[client] > GetGameTime())
	{
		b_ClientHasAncientBanner[client] = false;
		float BannerPos[3];
		float targPos[3];
		GetClientAbsOrigin(client, BannerPos);
		spawnRing_Vectors(BannerPos, BannerDefaultRange(true) * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 125, 1, 0.11, 5.0, 1.1, 5, _, client);	
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				GetClientAbsOrigin(ally, targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Defensive Backup", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Defensive Backup", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
	}
		
	return Plugin_Continue;
}


public void Enable_Management_Banner_3(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANCIENT_BANNER)
	{	
		b_ClientHasAncientBanner[client] = true;
		if (Timer_AncientBanner == null)
		{
			Timer_AncientBanner = CreateTimer(0.1, Timer_AncientBannerGlobal, _, TIMER_REPEAT);
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
			spawnRing_Vectors(BannerPos, BannerDefaultRange(true) * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 125, 1, 0.11, 5.0, 1.1, 5, _, client);	
			for(int ally=1; ally<=MaxClients; ally++)
			{
				if(IsClientInGame(ally) && IsPlayerAlive(ally))
				{
					GetClientAbsOrigin(ally, targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
					{
						ApplyStatusEffect(client, ally, "Ancient Melodies", 1.0);
						i_ExtraPlayerPoints[client] += 1;
					}
				}
			}
			for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
			{
				int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
				if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
				{
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
					{
						ApplyStatusEffect(client, ally, "Ancient Melodies", 1.0);
						i_ExtraPlayerPoints[client] += 1;
					}
				}
			}
		}
	}
	if(!ThereWasABuff)
	{
		Timer_AncientBanner = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
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

