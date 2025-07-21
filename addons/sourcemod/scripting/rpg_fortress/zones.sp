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
	.DefineStringField("m_nQuestKey")
	.DefineStringField("m_nMusicFile")
	.DefineStringField("m_nMusicDesc")
	.DefineIntField("m_iMusicDuration")
	.DefineFloatField("m_fMusicVolume")
	.DefineBoolField("m_bMusicCustom")
	.DefineStringField("m_nSkyBoxOverride")
	.DefineBoolField("m_bSilentKey")
	.DefineBoolField("m_bPvpZone")
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

	int entity = -1;
	while((entity=FindEntityByClassname(entity, "trigger_rpgzone")) != -1)
	{
		RemoveEntity(entity);
	}

	int a;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(hFromSpawnerIndex[entity] != -1)
			NPC_Despawn(entity);
	}
	
	char buffer[PLATFORM_MAX_PATH];
	for(int i=MAXENTITIES; i>MaxClients; i--)
	{
		if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
		{
			if(!StrContains(buffer, "prop_dynamic") || !StrContains(buffer, "point_worldtext") || !StrContains(buffer, "info_particle_system"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrEqual(buffer, "rpg_fortress"))
					continue;
			}
			else if(!StrContains(buffer, "prop_physics"))
			{
				GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrContains(buffer, "rpg_item"))
					continue;
			}
			else
			{
				continue;
			}

			RemoveEntity(i);
		}
	}
	
	ZonesKv.Rewind();
	if(ZonesKv.GotoFirstSubKey())
	{
		float pos[3], mins[3], maxs[3];
		
		do
		{
			if(ZonesKv.GetSectionName(buffer, sizeof(buffer)))
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
					DispatchKeyValue(entity, "spawnflags", ZonesKv.GetNum("despawn") ? "3" : "1");
					DispatchKeyValue(entity, "targetname", buffer);

					DispatchSpawn(entity);
					ActivateEntity(entity);    

					SetEntityModel(entity, "models/error.mdl");
					SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
					SetEntityCollisionGroup(entity, 5);
					
					SetEntPropVector(entity, Prop_Data, "m_vecMinsPreScaled", mins);
					SetEntPropVector(entity, Prop_Data, "m_vecMins", mins);
					
					SetEntPropVector(entity, Prop_Data, "m_vecMaxsPreScaled", maxs);
					SetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxs);

					ZonesKv.GetVector("telepos", mins);
					SetEntPropVector(entity, Prop_Data, "m_vecTelePos", mins);

					ZonesKv.GetVector("teleang", mins);
					SetEntPropVector(entity, Prop_Data, "m_vecTeleAng", mins);

					ZonesKv.GetString("item", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nItemKey", buffer);

					ZonesKv.GetString("quest", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nQuestKey", buffer);

					ZonesKv.GetString("skybox_override", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nSkyBoxOverride", buffer);

					SetEntProp(entity, Prop_Data, "m_bSilentKey", ZonesKv.GetNum("silent"));
					SetEntProp(entity, Prop_Data, "m_bPvpZone", ZonesKv.GetNum("pvp_zone"));
					
					int custom = ZonesKv.GetNum("download");
					ZonesKv.GetString("sounddesc", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nMusicDesc", buffer);
					ZonesKv.GetString("sound", buffer, sizeof(buffer));
					SetEntPropString(entity, Prop_Data, "m_nMusicFile", buffer);
					SetEntProp(entity, Prop_Data, "m_iMusicDuration", ZonesKv.GetNum("duration"));
					SetEntPropFloat(entity, Prop_Data, "m_fMusicVolume", ZonesKv.GetFloat("volume", 1.0));
					SetEntProp(entity, Prop_Data, "m_bMusicCustom", custom);

					if(buffer[0])
					{
						if(custom)
						{
							PrecacheSoundCustom(buffer, _, custom);
						}
						else
						{
							PrecacheSound(buffer);
						}
					}

				//	view_as<CClotBody>(entity).UpdateCollisionBox();

					SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW); 
					TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		while(ZonesKv.GotoNextKey());
	}

	Plots_ZoneCached();
}

static void OnEnter(int entity, const char[] name, int zone)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
		if(GetTeam(entity) != TFTeam_Red)
			NPC_Despawn(entity);
	}
	else if(entity > 0 && entity <= MaxClients)
	{
		Actor_EnterZone(entity, name);
		Games_ClientEnter(entity, name);
		Garden_ClientEnter(entity, name);
		Music_ZoneEnter(entity, zone);
		Plots_ClientEnter(entity, EntIndexToEntRef(zone), name);
		Spawns_ClientEnter(entity, name);
		TextStore_ZoneEnter(entity, name);
	}
}

static void OnLeave(int entity, const char[] name, int zone)
{
	if(!b_NpcHasDied[entity]) //An npc just touched it!
	{
	}
	else if(entity > 0 && entity <= MaxClients)
	{
		Garden_ClientLeave(entity, name);
		Plots_ClientLeave(entity, EntIndexToEntRef(zone));
		Spawns_ClientLeave(entity, name);
		TextStore_ZoneLeave(entity, name);	
	}
}

static void OnEnable(const char[] name)
{
	Crafting_EnableZone(name);
	Dungeon_EnableZone(name);
	Mining_EnableZone(name);
	Spawns_EnableZone(name);
	Tinker_EnableZone(name);
	Worldtext_EnableZone(name);
}

static void OnDisable(const char[] name, int zone)
{
	Actor_DisableZone(name);
	Crafting_DisableZone(name);
	Dungeon_DisableZone(name);
	Mining_DisableZone(name);
	Plots_DisableZone(EntIndexToEntRef(zone));
	Spawns_DisableZone(name);
	TextStore_ZoneAllLeave(name);
	Tinker_DisableZone(name);
	Worldtext_DisableZone(name);
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
		GetEntPropString(entity, Prop_Data, "m_nItemKey", name, sizeof(name));
		if(caller <= MaxClients && name[0] && TextStore_GetItemCount(caller, name) < 1)
		{
			if(!GetEntProp(entity, Prop_Data, "m_bSilentKey"))
				ShowGameText(caller, _, 0, "You need \"%s\" to enter", name);
			
			return Plugin_Continue;
		}
		
		GetEntPropString(entity, Prop_Data, "m_nQuestKey", name, sizeof(name));
		if(caller <= MaxClients && name[0] && Quests_GetStatus(caller, name) != Status_Completed)
		{
			if(!GetEntProp(entity, Prop_Data, "m_bSilentKey"))
				ShowGameText(caller, _, 0, "You need complete \"%s\" quest to enter.", name);
			
			return Plugin_Continue;
		}

		if(caller <= MaxClients)
		{
			if(GetEntProp(entity, Prop_Data, "m_bPvpZone"))
				b_PlayerIsPVP[caller]++;
		}

		GetEntPropString(entity, Prop_Data, "m_nSkyBoxOverride", name, sizeof(name));
		if(caller <= MaxClients && name[0])
		{
			CvarSkyName.ReplicateToClient(caller, name);
		}

		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnEnter(caller, name, entity);

		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecTelePos", pos);
		if(pos[0])
		{
			float ang[3];
			GetEntPropVector(entity, Prop_Data, "m_vecTeleAng", ang);
			TeleportEntity(caller, pos, ang, {0.0, 0.0, 0.0});
			if(caller <= MaxClients)
				TF2_StunPlayer(caller, 0.15, 1.0, TF_STUNFLAG_SLOWDOWN);
		}
	}
	return Plugin_Continue;
}

public Action Zones_EndTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MaxClients)
	{
		if(caller <= MaxClients)
		{
			if(GetEntProp(entity, Prop_Data, "m_bPvpZone"))
				b_PlayerIsPVP[caller]--;
		}
		char name[64];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
			OnLeave(caller, name, entity);
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
			OnEnable(name);
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
				OnDisable(name, entity);
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

static Handle TimerZoneEditing[MAXPLAYERS];
static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentZoneEditing[MAXPLAYERS][64];

void Zones_EditorMenu(int client)
{
	char buffer[PLATFORM_MAX_PATH];
	EditMenu menu = new EditMenu();

	if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Zones\n%s\n ", CurrentZoneEditing[client]);
		
		FormatEx(buffer, sizeof(buffer), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);

		menu.AddItem("", "Set To Default");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustZoneKey);
	}
	else if(CurrentZoneEditing[client][0])
	{
		ZonesKv.Rewind();
		ZonesKv.JumpToKey(CurrentZoneEditing[client], true);

		menu.SetTitle("Zones\n%s\nClick to set it's value:\n ", CurrentZoneEditing[client]);
		
		float pos1[3], pos2[3], telepos[3], teleang[3];
		ZonesKv.GetVector("point1", pos1);
		ZonesKv.GetVector("point2", pos2);
		ZonesKv.GetVector("telepos", telepos);
		ZonesKv.GetVector("telepos", teleang);

		FormatEx(buffer, sizeof(buffer), "Point 1: %.0f %.0f %.0f", pos1[0], pos1[1], pos1[2]);
		menu.AddItem("point1", buffer);

		FormatEx(buffer, sizeof(buffer), "Point 2: %.0f %.0f %.0f", pos2[0], pos2[1], pos2[2]);
		menu.AddItem("point2", buffer);
		
		ZonesKv.GetString("sound", buffer, sizeof(buffer));
		if(buffer[0])
		{
			Format(buffer, sizeof(buffer), "Music File: \"%s\"%s", buffer, PrecacheSound(buffer) ? "" : " {WARNING: Sound does not exist}");
			menu.AddItem("sound", buffer);
			
			Format(buffer, sizeof(buffer), "Music Time: %d", ZonesKv.GetNum("duration"));
			menu.AddItem("duration", buffer);
			
			Format(buffer, sizeof(buffer), "Music Volume: %f", ZonesKv.GetFloat("volume", 1.0));
			menu.AddItem("volume", buffer);
			
			ZonesKv.GetString("sounddesc", buffer, sizeof(buffer), "\" (Song Author - Song Name)");
			Format(buffer, sizeof(buffer), "Music Author: \"%s\"", buffer);
			menu.AddItem("sounddesc", buffer);
			
			int custom = ZonesKv.GetNum("download");
			if(custom)
			{
				Format(buffer, sizeof(buffer), "Music Custom: Download (Level %d)", custom);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Music Custom: Is Base Game");
			}
			menu.AddItem("download", buffer);
		}
		else
		{
			menu.AddItem("sound", "Music File: \"\"");

			if(telepos[0])
			{
				FormatEx(buffer, sizeof(buffer), "Teleport: %.0f %.0f %.0f %.1f", telepos[0], telepos[1], telepos[2], teleang[1]);
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "Teleport: None");
			}
			menu.AddItem("telepos", buffer);

			ZonesKv.GetString("quest", buffer, sizeof(buffer));
			bool hasKey = view_as<bool>(buffer[0]);
			if(buffer[0] && !Quests_KV().JumpToKey(buffer))
			{
				Format(buffer, sizeof(buffer), "Quest Key: \"%s\" {WARNING: Quest does not exist}", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Quest Key: \"%s\"", buffer);
			}
			menu.AddItem("quest", buffer);

			ZonesKv.GetString("item", buffer, sizeof(buffer));
			if(!hasKey)
				hasKey = view_as<bool>(buffer[0]);
			
			if(buffer[0] && !TextStore_IsValidName(buffer))
			{
				Format(buffer, sizeof(buffer), "Item Key: \"%s\" {WARNING: Item does not exist}", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Item Key: \"%s\"", buffer);
			}
			menu.AddItem("item", buffer);

			if(hasKey)
			{
				Format(buffer, sizeof(buffer), "Key Print: %s", ZonesKv.GetNum("silent") ? "None" : "HUD Message");
				menu.AddItem("silent", buffer);
			}
		}

		Format(buffer, sizeof(buffer), "Type: %s%s", ZonesKv.GetNum("pvp_zone") ? "PvP" : "", ZonesKv.GetNum("despawn") ? "Despawner" : "");
		menu.AddItem("_extra", buffer);

		ZonesKv.GetString("skybox_override", buffer, sizeof(buffer));

		Format(buffer, sizeof(buffer), "Skybox: \"%s\"", buffer);
		menu.AddItem("skybox_override", buffer);

		menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);
		
		menu.ExitBackButton = true;
		menu.Display(client, AdjustZone);

		Zones_RenderZone(client, CurrentZoneEditing[client], telepos, true);

		delete TimerZoneEditing[client];
		TimerZoneEditing[client] = CreateTimer(3.0, Timer_RefreshHud, client);
	}
	else
	{
		menu.SetTitle("Zones\nType in chat to create a new zone\n ");
		
		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, NamePicker);
	}
}

void Zones_GenerateZoneList(int client, EditMenu menu, bool &first = false)
{
	char buffer[64];
	
	ZonesKv.Rewind();
	if(ZonesKv.GotoFirstSubKey())
	{
		do
		{
			ZonesKv.GetSectionName(buffer, sizeof(buffer));
			if(Zones_WithinRangeKv(client))
			{
				if(first)
				{
					menu.InsertItem(0, buffer, buffer);
				}
				else
				{
					menu.AddItem(buffer, buffer);
				}
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s (Outside)", buffer);
				menu.AddItem(buffer, buffer);
			}

			first = true;
		}
		while(ZonesKv.GotoNextKey());
	}
	else
	{
		menu.AddItem("", "None", ITEMDRAW_DISABLED);
	}
}

bool Zones_WithinRangeKv(int client)
{
	float pos[3];
	ZonesKv.GetVector("point1", pos);
	if(!pos[0])
		return true;
	
	if(Editor_WithinRange(client, pos))
		return true;
	
	ZonesKv.GetVector("point2", pos);
	if(!pos[0])
		return true;
	
	if(Editor_WithinRange(client, pos))
		return true;
	
	ZonesKv.GetVector("telepos", pos);
	if(pos[0])
	{
		if(Editor_WithinRange(client, pos))
			return true;
	}
	
	return false;
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
			GetClientAbsOrigin(client, pos);
			//GetClientPointVisible(client, _, _, _, pos);
			ZonesKv.SetVector("point1", pos);
		}
		else if(StrEqual(buffer, "point2"))
		{
			float pos[3];
			GetClientAbsOrigin(client, pos);
			//GetClientPointVisible(client, _, _, _, pos);
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
		else if(StrEqual(buffer, "silent") || StrEqual(buffer, "pvp_zone") || StrEqual(buffer, "despawn"))
		{
			ZonesKv.SetNum(buffer, ZonesKv.GetNum(buffer) ? 0 : 1);
		}
		else if(StrEqual(buffer, "_extra"))
		{
			if(ZonesKv.GetNum("pvp_zone"))
			{
				ZonesKv.SetNum("pvp_zone", 0);
				ZonesKv.SetNum("despawn", 1);
			}
			else if(ZonesKv.GetNum("despawn"))
			{
				ZonesKv.SetNum("despawn", 0);
			}
			else
			{
				ZonesKv.SetNum("pvp_zone", 1);
			}
		}
		else if(StrEqual(buffer, "delete"))
		{
			ZonesKv.DeleteThis();
			delete TimerZoneEditing[client];
			CurrentZoneEditing[client][0] = 0;
		}
		else
		{
			strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), buffer);
			Zones_EditorMenu(client);
			return;
		}
	}
	
	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "zones");

	ZonesKv.Rewind();
	ZonesKv.ExportToFile(filepath);

	Zones_Rebuild();
	Zones_EditorMenu(client);
}

static void AdjustZoneKey(int client, const char[] buffer)
{
	if(StrEqual(buffer, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Zones_EditorMenu(client);
		return;
	}

	ZonesKv.Rewind();
	ZonesKv.JumpToKey(CurrentZoneEditing[client], true);

	if(buffer[0])
	{
		ZonesKv.SetString(CurrentKeyEditing[client], buffer);
	}
	else
	{
		ZonesKv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

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

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 255, 255}, 0);
			TE_SendToClient(client);

			vec1 = pos2;
			vec2 = pos2;

			vec2[i] = pos1[i];

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 255, 255}, 0);
			TE_SendToClient(client);

			if(points)
			{
				/*
					Point 1 Box
				*/
				vec1 = pos1;
				vec2 = pos1;

				vec2[i] += 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 30.0, 10.0, 0, 0.0, {255, 0, 255, 255}, 0);
				TE_SendToClient(client);

				vec1 = pos1;
				vec2 = pos1;

				vec2[i] -= 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 30.0, 10.0, 0, 0.0, {255, 0, 255, 255}, 0);
				TE_SendToClient(client);

				/*
					Point 2 Box
				*/
				vec1 = pos2;
				vec2 = pos2;

				vec2[i] += 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 30.0, 10.0, 0, 0.0, {0, 255, 255, 255}, 0);
				TE_SendToClient(client);

				vec1 = pos2;
				vec2 = pos2;

				vec2[i] -= 5.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 30.0, 10.0, 0, 0.0, {0, 255, 255, 255}, 0);
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

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
				
				vec1 = telepos;
				vec1[0] += 23.5;
				vec1[1] += 23.5;
				vec1[2] += 95.0;
				vec2 = vec1;

				vec2[i] -= i == 2 ? 95.0 : 57.0;

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
			}
			/*
				Plot Building Box
			*/
			else if(Plots_IsPlotZone(name))
			{
				vec1 = pos1;
				vec2 = pos2;

				for(int b; b < 2; b++)
				{
					if(vec1[b] < vec2[b])
					{
						float val = vec1[b];
						vec1[b] = vec2[b];
						vec2[b] = val;
					}

					vec2[b] = (vec1[b] - vec2[b]) / 2.0;
					vec1[b] -= vec2[b];
				}

				vec1[0] -= Plots_MaxSize() / 2;	// Bottom
				vec1[1] -= Plots_MaxSize() / 2;	// Left
				if(vec1[2] > vec2[2])		// Floor
					vec1[2] = vec2[2];
				
				vec2 = vec1;
				vec2[i] += Plots_MaxSize();

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
				
				vec1[0] += Plots_MaxSize();	// Top
				vec1[1] += Plots_MaxSize();	// Right
				vec1[2] += Plots_MaxSize();	// Ceiling

				vec2 = vec1;
				vec2[i] -= Plots_MaxSize();

				TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 3.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
				TE_SendToClient(client);
			}
		}
	}
}
