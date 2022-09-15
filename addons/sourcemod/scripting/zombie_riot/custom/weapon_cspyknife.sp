static int weapon_id[MAXPLAYERS+1]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float AttackSpeedGoBrrr[MAXPLAYERS+1]={0.0, ...};
static float DoMoreDmgPls[MAXPLAYERS+1]={1.0, ...};
static float TakeMoreDmgCauseISaidSo[MAXPLAYERS+1]={0.0, ...};

public void Weapon_Cspyknife_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_CspyKnife(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if(Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ability_Apply_Cooldown(client, slot, 1.0);
			weapon_id[client] = weapon;
			
			switch(GetRandomInt(1,8))
			{
				case 1:
				{
					AttackSpeedGoBrrr[client] = 1.0;
					Address address = TF2Attrib_GetByDefIndex(weapon, 6);
					if(address != Address_Null)
					AttackSpeedGoBrrr[client] = TF2Attrib_GetValue(address);
					TF2Attrib_SetByDefIndex(weapon, 6, AttackSpeedGoBrrr[client] * 0.30);
					CreateTimer(0.88, Reset_TheAttackSpeedCauseISaidSo, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "AttackSpeed bonus")
				}
				case 2:
				{
					TF2_AddCondition(client, TFCond_CritCola, 0.88, 0)
					//PrintToChat(client, "Minicrits")
				}
				case 3:
				{
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.33, 0)
					//PrintToChat(client, "Speedbuff")
				}
				case 4:
				{
					DoMoreDmgPls[client] = 1.0;
					Address address = TF2Attrib_GetByDefIndex(weapon, 2);
					if(address != Address_Null)
					DoMoreDmgPls[client] = TF2Attrib_GetValue(address);
					TF2Attrib_SetByDefIndex(weapon, 2, DoMoreDmgPls[client] * 1.70);
					CreateTimer(0.88, Reset_DoMoreDmgPls, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "More Dmg")
				}
				case 5:
				{
					DoMoreDmgPls[client] = 1.0;
					Address address = TF2Attrib_GetByDefIndex(weapon, 2);
					if(address != Address_Null)
					DoMoreDmgPls[client] = TF2Attrib_GetValue(address);
					TF2Attrib_SetByDefIndex(weapon, 2, DoMoreDmgPls[client] * 0.70);
					CreateTimer(0.88, Reset_DoMoreDmgPls, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Less Dmg")
				}
				case 6:
				{
					TakeMoreDmgCauseISaidSo[client] = 1.0;
					Address address = TF2Attrib_GetByDefIndex(weapon, 206);
					if(address != Address_Null)
					DoMoreDmgPls[client] = TF2Attrib_GetValue(address);
					TF2Attrib_SetByDefIndex(weapon, 206, DoMoreDmgPls[client] * 1.25);
					CreateTimer(0.88, Reset_TakeMoreDmg, client, TIMER_FLAG_NO_MAPCHANGE);
					//PrintToChat(client, "Take More Dmg")
				}
				case 7:
				{
					TF2_StunPlayer(client, 0.88, 0.55, TF_STUNFLAG_SLOWDOWN, _);
					//PrintToChat(client, "You got slowed ha!")
				}
			}
		}
	}
}

public Action Reset_TheAttackSpeedCauseISaidSo(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = GetPlayerWeaponSlot(client, 2);
		if(weapon == weapon_id[client])
		{
			TF2Attrib_SetByDefIndex(weapon, 6, AttackSpeedGoBrrr[client]);
		}
	}
	return Plugin_Handled;
}

public Action Reset_DoMoreDmgPls(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = GetPlayerWeaponSlot(client, 2);
		if(weapon == weapon_id[client])
		{
			TF2Attrib_SetByDefIndex(weapon, 2, DoMoreDmgPls[client]);
		}
	}
	return Plugin_Handled;
}

public Action Reset_TakeMoreDmg(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		int weapon = GetPlayerWeaponSlot(client, 2);
		if(weapon == weapon_id[client])
		{
			TF2Attrib_SetByDefIndex(weapon, 206, DoMoreDmgPls[client]);
		}
	}
	return Plugin_Handled;
}