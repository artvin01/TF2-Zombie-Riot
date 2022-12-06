#pragma semicolon 1
#pragma newdecls required

static ArrayList ActiveZones;

void Zones_PluginStart()
{
	char name[32];
	ActiveZones = new ArrayList(ByteCountToCells(sizeof(name)));
	
	HookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);
	
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "zr_", false))
			AcceptEntityInput(entity, "TouchTest", entity, entity);
	}
	
	UnhookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouchAll);
	
	HookEntityOutput("trigger_multiple", "OnStartTouch", Zones_StartTouch);
	HookEntityOutput("trigger_multiple", "OnStartTouchAll", Zones_StartTouchAll);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Zones_EndTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouchAll", Zones_EndTouchAll);
}

static void OnEnter(int client, const char[] name)
{
	TextStore_ZoneEnter(client, name);
}

static void OnLeave(int client, const char[] name)
{
	TextStore_ZoneLeave(client, name);
}

static void OnActive(const char[] name)
{
	Spawns_UpdateSpawn(name);
}

static void OnDisable(const char[] name)
{
	Spawns_DisableSpawn(name);
	TextStore_ZoneAllLeave(name);
}

bool Zones_IsActive(const char[] name)
{
	return ActiveZones.FindString(name) != -1;
}

public Action Zones_StartTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[32];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnEnter(caller, entity);
	}
	return Plugin_Continue;
}

public Action Zones_EndTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[32];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnLeave(caller, entity);
	}
	return Plugin_Continue;
}

public Action Zones_StartTouchAll(const char[] output, int entity, int caller, float delay)
{
	char name[32];
	GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
	if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
	{
		ActiveZones.PushString(name);
		OnActive(name);
	}
	return Plugin_Continue;
}

public Action Zones_EndTouchAll(const char[] output, int entity, int caller, float delay)
{
	char name[32];
	GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
	if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
	{
		int pos = ActiveZones.FindString(name);
		if(pos != -1)
		{
			ActiveZones.Erase(pos);
			OnDisable(name);
		}
	}
	return Plugin_Continue;
}