#pragma semicolon 1
#pragma newdecls required

static ArrayList ActiveZones;

void Zones_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("trigger_rpgzone", OnCreate, OnDestroy);
	factory.DeriveFromClass("trigger_multiple");
	factory.BeginDataMapDesc()
	.DefineVectorField("m_vecTelePos")
	.DefineVectorField("m_vecTeleAng")
	.DefineStringField("m_nItemKey")
	.EndDataMapDesc();
	factory.Install();
}

static void OnCreate(int entity)
{
	HookSingleEntityOutput(entity, "OnStartTouch", Zones_StartTouch, false);
	HookSingleEntityOutput(entity, "OnStartTouchAll", Zones_StartTouchAll, false);
	HookSingleEntityOutput(entity, "OnEndTouch", Zones_EndTouch, false);
	HookSingleEntityOutput(entity, "OnEndTouchAll", Zones_EndTouchAll, false);
}

static void OnDestroy(int entity)
{
	UnhookSingleEntityOutput(entity, "OnStartTouch", Zones_StartTouch);
	UnhookSingleEntityOutput(entity, "OnStartTouchAll", Zones_StartTouchAll);
	UnhookSingleEntityOutput(entity, "OnEndTouch", Zones_EndTouch);
	UnhookSingleEntityOutput(entity, "OnEndTouchAll", Zones_EndTouchAll);
}

void Zones_ResetAll()
{
	Zones_ConfigSetup();
}

void Zones_RoundStart()
{
	Zones_ConfigSetup();
}

void Zones_ConfigSetup()
{
	delete ActiveZones;
	ActiveZones = new ArrayList(ByteCountToCells(32));
	
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "zones");
	KeyValues kv = new KeyValues("Zones");
	kv.ImportFromFile(buffer);

	int entity;
	while((entity=FindEntityByClassname(entity, "trigger_rpgzone")) != -1)
	{
		RemoveEntity(entity);
	}
	
	if(kv.GotoFirstSubKey())
	{
		char name[32];
		float pos[3], vec[3];
		
		do
		{
			if(kv.GetSectionName(name, sizeof(name)))
			{
				entity = CreateEntityByName("trigger_rpgzone");
				if(entity != -1)
				{
					kv.GetVector("origin", pos);
					DispatchKeyValueVector(entity, "origin", pos);
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "targetname", "rpg_fortress");

					DispatchSpawn(entity);
					ActivateEntity(entity);    

					SetEntityModel(entity, "models/error.mdl");
					SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
					SetEntityCollisionGroup(entity, 5);
					
					kv.GetVector("mins", vec);
					SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", vec);
					SetEntPropVector(entity, Prop_Send, "m_vecMins", vec);
					
					kv.GetVector("maxs", vec);
					SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", vec);
					SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);

					kv.GetVector("telepos", vec);
					SetEntPropVector(entity, Prop_Data, "m_vecTelePos", vec);

					kv.GetVector("teleang", vec);
					SetEntPropVector(entity, Prop_Data, "m_vecTeleAng", vec);

					kv.GetString("item", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nItemKey", buffer);

					view_as<CClotBody>(entity).UpdateCollisionBox();

					SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW); 
					TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		while(kv.GotoNextKey());
	}

	delete kv;
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
		Levels_ClientEnter(entity, name);
		Music_ZoneEnter(entity, name);
		Quests_EnableZone(entity, name);
		Spawns_ClientEnter(entity, name);
		TextStore_ZoneEnter(entity, name);		
	}

	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecTelePos", pos);
	if(pos[0])
	{
		
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

static void OnEnable(int entity, const char[] name)
{
	/*if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else*/
	{
		Dungeon_EnableZone(name);
		Mining_EnableZone(name);
		Spawns_EnableZone(entity, name);
		Tinker_EnableZone(name);
	}
}

static void OnDisable(const char[] name)
{
	/*if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else*/
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
			OnEnable(entity, name);
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
				OnDisable(name);
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
				PrintCenterText(target, "You need cl_allowdownload 1 and cl_downloadfilter all");
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