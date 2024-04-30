#pragma semicolon 1
#pragma newdecls required

static KeyValues ZonesKv;
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

void Zones_MapStart()
{
	PrecacheModel("models/error.mdl");
}

void Zones_ResetAll()
{
	Zones_Rebuild();
}

void Zones_RoundStart()
{
	Zones_Rebuild();
}

void Zones_ConfigSetup()
{
	delete ZonesKv;
	
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "zones");
	ZonesKv = new KeyValues("Zones");
	ZonesKv.ImportFromFile(buffer);

	Zones_Rebuild();
}

void Zones_Rebuild()
{
	delete ActiveZones;
	ActiveZones = new ArrayList(ByteCountToCells(64));

	int entity;
	while((entity=FindEntityByClassname(entity, "trigger_rpgzone")) != -1)
	{
		RemoveEntity(entity);
	}
	
	ZonesKv.Rewind();
	if(ZonesKv.GotoFirstSubKey())
	{
		char name[64];
		float pos[3], mins[3], maxs[3];
		
		do
		{
			if(ZonesKv.GetSectionName(name, sizeof(name)))
			{
				entity = CreateEntityByName("trigger_rpgzone");
				if(entity != -1)
				{
					ZonesKv.GetVector("point1", pos);
					ZonesKv.GetVector("point2", maxs);

					for(int i; i < sizeof(maxs); i++)
					{
						if(pos[i] < maxs[i])
						{
							float val = pos[i];
							pos[i] = maxs[i];
							maxs[i] = val;
						}

						maxs[i] = (pos[i] - maxs[i]) / 2.0;
						mins[i] = -maxs[i];
						pos[i] -= maxs[i];
					}

					DispatchKeyValueVector(entity, "origin", pos);
					DispatchKeyValue(entity, "spawnflags", "1");
					DispatchKeyValue(entity, "targetname", name);

					DispatchSpawn(entity);
					ActivateEntity(entity);    

					SetEntityModel(entity, "models/error.mdl");
					SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
					SetEntityCollisionGroup(entity, 5);
					
					SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", mins);
					SetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
					
					SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxs);
					SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);

					ZonesKv.GetVector("telepos", mins);
					SetEntPropVector(entity, Prop_Data, "m_vecTelePos", mins);

					ZonesKv.GetVector("teleang", mins);
					SetEntPropVector(entity, Prop_Data, "m_vecTeleAng", mins);

					ZonesKv.GetString("item", name, sizeof(name));
					SetEntPropString(entity, Prop_Data, "m_nItemKey", name);

					view_as<CClotBody>(entity).UpdateCollisionBox();

					SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW); 
					TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		while(ZonesKv.GotoNextKey());
	}
}

static void OnEnter(int entity, const char[] name)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
		NPC_Despawn_Zone(entity, name);
	}
	else if(entity > 0 && entity <= MaxClients)
	{
		Actor_EnterZone(entity, name);
		Crafting_ClientEnter(entity, name);
		Games_ClientEnter(entity, name);
		Garden_ClientEnter(entity, name);
		Music_ZoneEnter(entity, name);
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
		Actor_DisableZone(name);
		Dungeon_DisableZone(name);
		Mining_DisableZone(name);
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
		char name[64];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnEnter(caller, name);

		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecTelePos", pos);
		if(pos[0])
		{
			GetEntPropString(entity, Prop_Data, "m_nItemKey", name, sizeof(name));
			if(caller <= MaxClients && name[0] && TextStore_GetItemCount(caller, name) < 1)
			{
				ShowGameText(caller, _, 0, "You need \"%s\" to enter", name);
			}
			else
			{
				float ang[3];
				GetEntPropVector(entity, Prop_Data, "m_vecTeleAng", ang);
				TeleportEntity(caller, pos, ang, {0.0, 0.0, 0.0});
				if(caller <= MaxClients)
					TF2_StunPlayer(caller, 0.3, 1.0, TF_STUNFLAG_SLOWDOWN);
			}
		}
	}
	return Plugin_Continue;
}

public Action Zones_EndTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		char name[64];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnLeave(caller, name);
	}
	return Plugin_Continue;
}

public Action Zones_StartTouchAll(const char[] output, int entity, int caller, float delay)
{
	if(ActiveZones)
	{
		char name[64];
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
		char name[64];
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
	char name[64];
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
		static char name[64];
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
					ShowGameText(target, _, 0, "You must be Level %d to enter", lv);
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

static Handle TimerZoneEditing[MAXTF2PLAYERS];
static char CurrentZoneEditing[MAXTF2PLAYERS][64];

void Zones_EditorMenu(int client)
{
	char buffer[PLATFORM_MAX_PATH];
	ZonesKv.Rewind();
	EditMenu menu = new EditMenu();

	if(CurrentZoneEditing[client][0])
	{
		ZonesKv.JumpToKey(CurrentZoneEditing[client], true);

		menu.SetTitle("Zones\n%s\n ", CurrentZoneEditing[client]);
		
		float pos1[3], pos2[3], telepos[3], teleang[3];
		ZonesKv.GetVector("point1", pos1);
		ZonesKv.GetVector("point2", pos2);
		ZonesKv.GetVector("telepos", telepos);
		ZonesKv.GetVector("telepos", teleang);

		FormatEx(buffer, sizeof(buffer), "Point 1: %.0f %.0f %.0f (Click to Set)", pos1[0], pos1[1], pos1[2]);
		menu.AddItem("point1", buffer);

		FormatEx(buffer, sizeof(buffer), "Point 2: %.0f %.0f %.0f (Click to Set)", pos2[0], pos2[1], pos2[2]);
		menu.AddItem("point2", buffer);

		if(telepos[0])
		{
			FormatEx(buffer, sizeof(buffer), "Teleport: %.0f %.0f %.0f %.1f (Click to Remove)", telepos[0], telepos[1], telepos[2], teleang[1]);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Teleport: None (Click to Set)");
		}
		menu.AddItem("telepos", buffer);

		ZonesKv.GetString("item", buffer, sizeof(buffer));
		if(buffer[0] && !TextStore_IsValidName(buffer))
		{
			Format(buffer, sizeof(buffer), "Item Key: \"%s\" {WARNING: Item does not exist}\n ", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "Item Key: \"%s\" (Type in chat, Click to Remove)\n ", buffer);
		}
		menu.AddItem("item", buffer);

		menu.AddItem("delete", "Delete Zone");
		
		menu.ExitBackButton = true;
		menu.Display(client, AdjustZone);

		Zones_RenderZone(client, CurrentZoneEditing[client], telepos, true);

		delete TimerZoneEditing[client];
		TimerZoneEditing[client] = CreateTimer(1.0, Timer_RefreshHud, client);
	}
	else
	{
		menu.SetTitle("Zones\nType in chat to create a new zone\n ");
		
		if(ZonesKv.GotoFirstSubKey())
		{
			do
			{
				ZonesKv.GetSectionName(buffer, sizeof(buffer));
				menu.AddItem(buffer, buffer);
			}
			while(ZonesKv.GotoNextKey());
		}
		else
		{
			menu.AddItem("", "None", ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = true;
		menu.Display(client, NamePicker);
	}
}

static Action Timer_RefreshHud(Handle timer, int client)
{
	TimerZoneEditing[client] = null;
	if(Editor_MenuFunc(client) != AdjustZone)
		return Plugin_Stop;
	
	Zones_EditorMenu(client);
	return Plugin_Continue;
}

static void NamePicker(int client, const char[] buffer)
{
	if(StrEqual(buffer, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]), buffer);
	Zones_EditorMenu(client);
}

static void AdjustZone(int client, const char[] buffer)
{
	if(StrEqual(buffer, "back"))
	{
		delete TimerZoneEditing[client];
		CurrentZoneEditing[client][0] = 0;
		Zones_EditorMenu(client);
		return;
	}

	ZonesKv.Rewind();

	if(ZonesKv.JumpToKey(CurrentZoneEditing[client], true))
	{
		if(StrEqual(buffer, "point1"))
		{
			float pos[3];
			GetClientPointVisible(client, _, _, _, pos);
			ZonesKv.SetVector("point1", pos);
		}
		else if(StrEqual(buffer, "point2"))
		{
			float pos[3];
			GetClientPointVisible(client, _, _, _, pos);
			ZonesKv.SetVector("point2", pos);
		}
		else if(StrEqual(buffer, "telepos"))
		{
			float pos[3];
			ZonesKv.GetVector("telepos", pos);
			if(pos[0])
			{
				ZonesKv.DeleteKey("telepos");
			}
			else
			{
				GetClientAbsOrigin(client, pos);
				ZonesKv.SetVector("telepos", pos);
				
				GetClientAbsAngles(client, pos);
				pos[0] = 0.0;
				pos[1] = (RoundFloat(pos[1]) / 45) * 45.0;
				pos[2] = 0.0;
				ZonesKv.SetVector("teleang", pos);
			}
		}
		else if(StrEqual(buffer, "item"))
		{
			ZonesKv.DeleteKey("item");
		}
		else if(StrEqual(buffer, "delete"))
		{
			ZonesKv.DeleteThis();
			delete TimerZoneEditing[client];
			CurrentZoneEditing[client][0] = 0;
		}
		else
		{
			ZonesKv.SetString("item", buffer);
		}
	}
	
	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "zones");

	ZonesKv.Rewind();
	ZonesKv.ExportToFile(filepath);

	Zones_Rebuild();
	Zones_EditorMenu(client);
}

KeyValues Zones_GetKv()
{
	ZonesKv.Rewind();
	return ZonesKv;
}

void Zones_RenderZone(int client, const char[] name, const float telepos[3] = NULL_VECTOR, bool points = false)
{
	ZonesKv.Rewind();
	if(ZonesKv.JumpToKey(name))
	{
		float pos1[3], pos2[3], vec1[3], vec2[3];
		ZonesKv.GetVector("point1", pos1);
		ZonesKv.GetVector("point2", pos2);

		for(int i; i < 3; i++)
		{
			/*
				Trigger Box
			*/
			vec1 = pos1;
			vec2 = pos1;

			vec2[i] = pos2[i];

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 20.0, 20.0, 0, 0.0, {255, 255, 255, 255}, 0);
			TE_SendToClient(client);

			vec1 = pos2;
			vec2 = pos2;

			vec2[i] = pos1[i];

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 20.0, 20.0, 0, 0.0, {255, 255, 255, 255}, 0);
			TE_SendToClient(client);

			if(points)
			{
				/*
					Point 1 Box
				*/
				vec1 = pos1;
				vec2 = pos1;

				vec2[i] += 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 30.0, 10.0, 0, 0.0, {255, 0, 255, 255}, 0);
				TE_SendToClient(client);

				vec1 = pos1;
				vec2 = pos1;

				vec2[i] -= 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 30.0, 10.0, 0, 0.0, {255, 0, 255, 255}, 0);
				TE_SendToClient(client);

				/*
					Point 2 Box
				*/
				vec1 = pos2;
				vec2 = pos2;

				vec2[i] += 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 30.0, 10.0, 0, 0.0, {0, 255, 255, 255}, 0);
				TE_SendToClient(client);

				vec1 = pos2;
				vec2 = pos2;

				vec2[i] -= 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 30.0, 10.0, 0, 0.0, {0, 255, 255, 255}, 0);
				TE_SendToClient(client);
			}

			/*
				Teleport Box
			*/
			if(telepos[0])
			{
				vec1 = telepos;
				vec1[0] -= 23.5;
				vec1[1] -= 23.5;
				vec2 = vec1;

				vec2[i] += i == 2 ? 95.0 : 57.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
				
				vec1 = telepos;
				vec1[0] += 23.5;
				vec1[1] += 23.5;
				vec1[2] += 95.0;
				vec2 = vec1;

				vec2[i] -= i == 2 ? 95.0 : 57.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 1.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
			}
		}
	}
}
