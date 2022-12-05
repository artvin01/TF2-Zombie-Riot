#pragma semicolon 1
#pragma newdecls required

static ArrayList ActiveZones;

void Zones_PluginStart()
{
	char name[32];
	ActiveZones = new ArrayList(ByteCountToCells(sizeof(name)));
	
	HookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouch);
	
	int entity = -1;
	while((entity = FindEntityByClassname("trigger_multiple"))
	{
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && !StrContains(name, "zr_", false))
			AcceptEntityInput(entity, "TouchTest", entity, entity);
	}
	
	UnhookEntityOutput("trigger_multiple", "OnTouching", Zones_StartTouch);
	HookEntityOutput("trigger_multiple", "OnStartTouchAll", Zones_StartTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouchAll", Zones_EndTouch);
}

static void OnActive(const char[] name)
{
}

static void OnDisable(const char[] name)
{
}

stock bool Zones_IsActive(const char[] name)
{
	return ActiveZones.FindString(name) != -1;
}

public Action Zones_StartTouch(const char[] output, int entity, int caller, float delay)
{
	char name[32];
	if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
	{
		ActiveZones.PushString(name);
		OnActive(name);
	}
	return Plugin_Continue;
}

public Action Zones_EndTouch(const char[] output, int entity, int caller, float delay)
{
	char name[32];
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