#pragma semicolon 1
#pragma newdecls required

static ArrayList ActiveZones;

void Zones_PluginStart()
{
	HookEntityOutput("trigger_multiple", "OnStartTouch", Zones_StartTouch);
	HookEntityOutput("trigger_multiple", "OnStartTouchAll", Zones_StartTouchAll);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Zones_EndTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouchAll", Zones_EndTouchAll);
}

void Zones_ResetAll()
{
	delete ActiveZones;
	ActiveZones = new ArrayList(ByteCountToCells(32));
	
	char name[32];
	HookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);
	
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "rpg_", false))
			AcceptEntityInput(entity, "TouchTest", entity, entity);
	}
	
	UnhookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);
}

static void OnEnter(int client, const char[] name)
{
	if(!b_NpcHasDied[client]) //An npc just touched it!
	{
		PrintToChatAll("OnEnter");
		return;
	}
	else
	{
		Crafting_ClientEnter(client, name);
		Garden_ClientEnter(client, name);
		Music_ZoneEnter(client, name);
		Quests_EnableZone(client, name);
		TextStore_ZoneEnter(client, name);		
	}
}

static void OnLeave(int client, const char[] name)
{
	if(!b_NpcHasDied[client]) //An npc just touched it!
	{
		PrintToChatAll("OnLeave");
		return;
	}
	else
	{
		Crafting_ClientLeave(client, name);
		Garden_ClientLeave(client, name);
		TextStore_ZoneLeave(client, name);	
	}
}

static void OnActive(int client, const char[] name)
{
	if(!b_NpcHasDied[client]) //An npc just touched it!
	{
		PrintToChatAll("OnActive");
		return;
	}
	else
	{
		Mining_EnableZone(name);
		Spawns_UpdateSpawn(name);
		Tinker_EnableZone(name);
	}
}

static void OnDisable(int client, const char[] name)
{
	if(!b_NpcHasDied[client]) //An npc just touched it!
	{
		PrintToChatAll("OnDisable");
		return;
	}
	else
	{
		Mining_DisableZone(name);
		Quests_DisableZone(name);
		Spawns_DisableSpawn(name);
		TextStore_ZoneAllLeave(name);
		Tinker_DisableZone(name);
	}

}

bool Zones_IsActive(const char[] name)
{
	return (ActiveZones && ActiveZones.FindString(name) != -1);
}

public Action Zones_StartTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnEnter(caller, name);
	}
	return Plugin_Continue;
}

public Action Zones_EndTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnLeave(caller, name);
	}
	return Plugin_Continue;
}

public Action Zones_StartTouchAll(const char[] output, int entity, int caller, float delay)
{
	if(ActiveZones)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
		{
			ActiveZones.PushString(name);
			OnActive(entity, name);
		}
	}
	return Plugin_Continue;
}

public Action Zones_EndTouchAll(const char[] output, int entity, int caller, float delay)
{
	if(ActiveZones)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
		{
			int pos = ActiveZones.FindString(name);
			if(pos != -1)
			{
				ActiveZones.Erase(pos);
				OnDisable(entity, name);
			}
		}
	}
	return Plugin_Continue;
}

void Zones_EntityCreated(int entity, const char[] classname)
{
	if(!StrContains(classname, "trigger_teleport"))
	{
		SDKHook(entity, SDKHook_SpawnPost, Zones_TeleportSpawn);
	}
}

public void Zones_TeleportSpawn(int entity)
{
	char name[32];
	if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "rpg_teleport_", false))
	{
		SDKHook(entity, SDKHook_StartTouch, Zones_TeleportTouch);
		SDKHook(entity, SDKHook_Touch, Zones_TeleportTouch);
	}
}

public Action Zones_TeleportTouch(int entity, int target)
{
	if(target > 0 && target < sizeof(Level))
	{
		static char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "rpg_teleport_", false))
		{
			int lv = StringToInt(name[9]);
			if(lv > Level[target])
			{
				if(target <= MaxClients)
				{
					GetDisplayString(lv, name, sizeof(name));
					ShowGameText(target, _, 0, "You must be %s to enter", name);
				}
				return Plugin_Handled;
			}
		}
		else
		{
			SDKUnhook(entity, SDKHook_StartTouch, Zones_TeleportTouch);
			SDKUnhook(entity, SDKHook_Touch, Zones_TeleportTouch);
		}
	}
	return Plugin_Continue;
}