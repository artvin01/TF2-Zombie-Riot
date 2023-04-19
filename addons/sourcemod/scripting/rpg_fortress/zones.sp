#pragma semicolon 1
#pragma newdecls required

static ArrayList ActiveZones;

void Zones_PluginStart()
{
	HookEntityOutput("trigger_multiple", "OnStartTouch", Zones_StartTouch);
	HookEntityOutput("trigger_multiple", "OnStartTouchAll", Zones_StartTouchAll);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Zones_EndTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouchAll", Zones_EndTouchAll);

	char name[32];
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_teleport")) != -1)
	{
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "rpg_teleport", false))
		{
			SDKHook(entity, SDKHook_StartTouch, Zones_TeleportTouch);
			SDKHook(entity, SDKHook_Touch, Zones_TeleportTouch);
		}
	}
}

void Zones_ResetAll()
{
	delete ActiveZones;
	ActiveZones = new ArrayList(ByteCountToCells(32));
	
	/*char name[32];
	HookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);
	
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "rpg_", false))
			AcceptEntityInput(entity, "TouchTest", entity, entity);
	}
	
	UnhookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);*/
}

static void OnEnter(int entity, const char[] name)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
		NPC_Despawn_Zone(entity, name);
	}
	else if(entity > 0 && entity <= MaxClients)
	{
		Crafting_ClientEnter(entity, name);
		Games_ClientEnter(entity, name);
		Garden_ClientEnter(entity, name);
		Music_ZoneEnter(entity, name);
		Quests_EnableZone(entity, name);
		Spawns_ClientEnter(entity, name);
		TextStore_ZoneEnter(entity, name);		
	}
}

static void OnLeave(int entity, const char[] name)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else if(entity > 0 && entity <= MaxClients)
	{
		Crafting_ClientLeave(entity, name);
		Garden_ClientLeave(entity, name);
		Spawns_ClientLeave(entity, name);
		TextStore_ZoneLeave(entity, name);	
	}
}

static void OnActive(int entity, const char[] name)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else
	{
		Dungeon_EnableZone(name);
		Mining_EnableZone(name);
		Spawns_EnableZone(entity, name);
		Tinker_EnableZone(name);
	}
}

static void OnDisable(int entity, const char[] name)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else
	{
		Dungeon_DisableZone(name);
		Mining_DisableZone(name);
		Quests_DisableZone(name);
		Spawns_DisableZone(name);
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
	if(caller > 0 && caller <= MAXENTITIES)
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
			if(DisabledDownloads[target])
			{
				ShowGameText(target, _, 0, "cl_allowdownload or cl_downloadfilter was disabled");
				return Plugin_Handled;
			}

			int lv = StringToInt(name[13]);
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