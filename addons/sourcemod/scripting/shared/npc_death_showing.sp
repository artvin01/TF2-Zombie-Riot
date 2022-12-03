#pragma semicolon 1
#pragma newdecls required

void NPC_Killed_Show_Hud(int player, int entity, int weapon, char[] npcname, int damagetype)
{
	if(entity>MaxClients && IsValidEntity(entity))
	{
		char buffer[64];
		if(GetEntityClassname(entity, buffer, sizeof(buffer)) && StrEqual(buffer, "base_npc"))
		{
			for(int bot=1; bot<=MaxClients; bot++)
			{
				if(IsClientInGame(bot) && IsFakeClient(bot) && GetClientTeam(bot) == 3)
				{
					GetClientName(bot, buffer, sizeof(buffer));
					if(StrEqual(buffer, npcname))
					{
						ShowKillFeed(player, bot, entity, weapon, npcname, damagetype);
						return;
					}
				}
			}
			
			for(int bot=1; bot<=MaxClients; bot++)
			{
				if(IsClientInGame(bot) && IsFakeClient(bot) && GetClientTeam(bot) == 3 && f_BotDelayShow[bot] < GetGameTime())
				{
					ShowKillFeed(player, bot, entity, weapon, npcname, damagetype);
					return;
				}
			}
			
			for(int bot=1; bot<=MaxClients; bot++)
			{
				if(IsClientInGame(bot) && GetClientTeam(bot) == 3 && f_BotDelayShow[bot] < GetGameTime())
				{
					ShowKillFeed(player, bot, entity, weapon, npcname, damagetype);
					return;
				}
			}
			
			for(int bot=1; bot<=MaxClients; bot++)
			{
				if(IsClientInGame(bot) && GetClientTeam(bot) <= 1 && f_BotDelayShow[bot] < GetGameTime())
				{
					ShowKillFeed(player, bot, entity, weapon, npcname, damagetype);
					return;
				}
			}
		}
	}
}

Action NPC_SayCommand(int client, const char[] command)
{
	float value = f_BotDelayShow[client] - GetGameTime();
	if(value >= 0.0)
	{
		char buffer[512];
		GetCmdArgString(buffer, sizeof(buffer));
		Format(buffer, sizeof(buffer), "%s %s", command, buffer);
		
		DataPack pack;
		CreateDataTimer(value, NPC_PlayerUserCommand, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteString(buffer);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

static stock void ShowKillFeed(int player, int bot, int entity, int weapon, const char[] npcname, int damagetype)
{
	bool fake = IsFakeClient(bot);
	f_BotDelayShow[bot] = GetGameTime() + (fake ? 0.21 : 0.61);
	Event event2 = CreateEvent("player_death", true);
	
	int userid = GetClientUserId(bot);
	if(!fake)
	{
		char buffer[64];
		GetClientName(bot, buffer, sizeof(buffer));
		
		DataPack pack;
		CreateDataTimer(0.4, NPC_PlayerRevertName, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(userid);
		pack.WriteString(buffer);
	}
	
	SetClientName(bot, npcname);
	SetEntPropString(bot, Prop_Data, "m_szNetname", npcname);
							//				event2.SetInt("attacker", userid);
	
	int useridplayer = GetClientUserId(player);
	event2.SetInt("attacker", useridplayer);
	
	/*
	FormatEx(buffer, sizeof(buffer), "Level %d", 51);
	event2.SetString("weapon_logclassname", buffer);
	
	int streak;
	Killstreak.GetValue(npcname, streak);
	streak++;
	Killstreak.SetValue(NPCName[entity], streak);
	event2.SetInt("kill_streak_total", 1);
	event2.SetInt("kill_streak_wep", 1);
	*/
	
	
	event2.SetInt("userid", userid);
	event2.SetInt("victim_entindex", bot);
	event2.SetInt("weaponid", weapon);
	event2.SetInt("customkill", 0);
	
	/*
	if(IsValidClient(i_assist_heal_player[player]))
	{
		if(f_assist_heal_player_time[player] > GetGameTime())
		{
			event2.SetInt("assister", i_assist_heal_player[player]);
		}
		
	}
	*/
	event2.SetInt("assister", -1);
	event2.SetInt("stun_flags", 0);
	event2.SetInt("death_flags", 0);
	event2.SetBool("silent_kill", false);
	event2.SetInt("playerpenetratecount", 0);
	event2.SetBool("rocket_jump", false);
	if(IsValidEntity(weapon))
	{
		int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		char weaponname[64];
		GetEntityClassname(weapon, weaponname, sizeof(weaponname));
		event2.SetInt("inflictor_entindex", weapon);
		
		if(TF2Econ_GetItemDefinitionString(index, "item_iconname", weaponname, sizeof(weaponname)))
										event2.SetString("weapon", weaponname);
										
		event2.SetInt("weapon_def_index", index);
		event2.SetInt("damagebits", damagetype);
	}
	else
	{
		event2.SetInt("weapon_def_index", 0);
	}
	event2.SetInt("crit_type", 0);
	
	CreateTimer(0.2, NPC_PlayerDeathPost, event2, TIMER_FLAG_NO_MAPCHANGE);
}

public Action NPC_PlayerDeathPost(Handle timer, Event event)
{
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			event.FireToClient(i);
		}
	}
	event.Cancel();
	return Plugin_Continue;
}

public Action NPC_PlayerRevertName(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		char buffer[64];
		pack.ReadString(buffer, sizeof(buffer));
		
		SetClientName(client, buffer);
		SetEntPropString(client, Prop_Data, "m_szNetname", buffer);
	}
	return Plugin_Continue;
}

public Action NPC_PlayerUserCommand(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		char buffer[512];
		pack.ReadString(buffer, sizeof(buffer));
		FakeClientCommand(client, buffer);
	}
	return Plugin_Continue;
}