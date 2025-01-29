#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {null, ...};
int i_SetBannerType[MAXPLAYERS+1];
static bool b_ClientHasAncientBanner[MAXENTITIES];
static float b_EntityRecievedBuff[MAXENTITIES];
static float b_EntityRecievedBuff2[MAXENTITIES];
static bool b_EntityRecievedNonOwner[MAXENTITIES];
Handle Timer_AncientBanner = null;
Handle Timer_Banner_Management_2[MAXPLAYERS+1] = {null, ...};
Handle Timer_Banner_Management_1[MAXPLAYERS+1] = {null, ...};

float BannerDefaultRange()
{
	//if(b_AlaxiosBuffItem[client])
	{
		return 511225.0; //1.1x range
	}
	/*
	else
	{
		return 422500.0;
	}
	*/
}
void BannerOnEntityCreated(int entity)
{
	b_ClientHasAncientBanner[entity] = false;
	b_EntityRecievedBuff[entity] = 0.0;
	b_EntityRecievedNonOwner[entity] = false;
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
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally))
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
			{
				ApplyStatusEffect(client, ally, "Buff Banner", 0.5);
				i_ExtraPlayerPoints[client] += 1;
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
			{
				ApplyStatusEffect(client, ally, "Buff Banner", 0.5);
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
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				GetClientAbsOrigin(ally, targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Buff Banner", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Buff Banner", 0.5);
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
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				GetClientAbsOrigin(ally, targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Battilons Backup", 0.5);
					i_ExtraPlayerPoints[client] += 1;
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
				if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
				{
					ApplyStatusEffect(client, ally, "Battilons Backup", 0.5);
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
					if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
					{
						ApplyStatusEffect(client, ally, "Ancient Banner", 0.5);
						i_ExtraPlayerPoints[client] += 1;
					}
				}
			}
			for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
			{
				int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
				if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
				{
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= BannerDefaultRange()) // 650.0
					{
						ApplyStatusEffect(client, ally, "Ancient Banner", 0.5);
						i_ExtraPlayerPoints[client] += 1;
					}
				}
			}
		}
	}
	//If it returns 1, then it means it doesnt get full benifit
	//if it returns 2, then it gets full benifit
	int OwnerType = 0;
	if(ThereWasABuff)
	{
		for(int ally=1; ally<=MaxClients; ally++)
		{
			if(IsClientInGame(ally) && IsPlayerAlive(ally))
			{
				OwnerType = HasSpecificBuff(ally, "Ancient Banner");
				if(OwnerType == 2)
				{
					//clear.
					if(b_EntityRecievedNonOwner[ally])
						ModifyEntityAncientBuff(ally, 1, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);

					ModifyEntityAncientBuff(ally, 1, 0.8, true, 1.2, 1.01);
				}
				else if(OwnerType == 1)
				{
					ModifyEntityAncientBuff(ally, 1, 0.8, true, 1.2, PlayerCountBuffAttackspeedScaling);
				}
				else
				{
					ModifyEntityAncientBuff(ally, 1, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				OwnerType = HasSpecificBuff(ally, "Ancient Banner");
				if(OwnerType == 2)
				{
					//clear.
					if(b_EntityRecievedNonOwner[ally])
						ModifyEntityAncientBuff(ally, 2, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);

					ModifyEntityAncientBuff(ally, 2, 0.8, true, 1.2, 1.01);
				}
				else if(OwnerType == 1)
				{
					ModifyEntityAncientBuff(ally, 2, 0.8, true, 1.2, PlayerCountBuffAttackspeedScaling);
				}
				else
				{
					ModifyEntityAncientBuff(ally, 2, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);
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
				ModifyEntityAncientBuff(ally, 1, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
			{
				ModifyEntityAncientBuff(ally, 2, 0.8, false, 1.2, PlayerCountBuffAttackspeedScaling);
			}
		}
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


/*
	type:
	1: client
	2: entity
*/
static void ModifyEntityAncientBuff(int entity, int type, float buffammount, bool GrantBuff = true, float buffammount2, float ScalingDo)
{
	float BuffValueDo = MaxNumBuffValue(buffammount, 1.0, ScalingDo);
	float BuffValueDo2 = MaxNumBuffValue(buffammount2, 1.0, ScalingDo);
	if(GrantBuff && ScalingDo == PlayerCountBuffAttackspeedScaling) //we presume its a self buff
		b_EntityRecievedNonOwner[entity] = true;
	
	if(!GrantBuff)
		b_EntityRecievedNonOwner[entity] = false;

	if(type == 1)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(b_EntityRecievedBuff[weapon] == 0.0)
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[weapon] = BuffValueDo;
					b_EntityRecievedBuff2[weapon] = BuffValueDo2;
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, BuffValueDo);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, BuffValueDo);	// Reload Time
					
					if(Attributes_Has(weapon, 8))
						Attributes_SetMulti(weapon, 8, BuffValueDo2);	// Heal Rate
				}
			}
			else
			{
				if(!GrantBuff)
				{
					if(b_EntityRecievedBuff[weapon] != 0.0)
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, 1.0 / (b_EntityRecievedBuff[weapon]));	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, 1.0 / (b_EntityRecievedBuff[weapon]));	// Reload Time
						
						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / (b_EntityRecievedBuff2[weapon]));	// Heal Rate

						b_EntityRecievedBuff[weapon] = 0.0;
					}
				}
			}
		}
	}
	else if(type == 2)
	{
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
		if(StrEqual(npc_classname, "npc_citizen"))
		{
			Citizen npc = view_as<Citizen>(entity);
			if(b_EntityRecievedBuff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[entity] = BuffValueDo;
					npc.m_fGunFirerate *= BuffValueDo;
					npc.m_fGunReload *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.m_fGunFirerate /= (b_EntityRecievedBuff[entity]);
					npc.m_fGunReload /= (b_EntityRecievedBuff[entity]);
					b_EntityRecievedBuff[entity] = 0.0;
				}
			}
		}
		else if(entity > MaxClients)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(b_EntityRecievedBuff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					b_EntityRecievedBuff[entity] = BuffValueDo;
					npc.BonusFireRate *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.BonusFireRate /= (b_EntityRecievedBuff[entity]);
					b_EntityRecievedBuff[entity] = 0.0;
				}
			}
		}
	}
}