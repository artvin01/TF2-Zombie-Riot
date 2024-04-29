#pragma semicolon 1
#pragma newdecls required

static KeyValues ActorKv;
static bool ForcedMenu[MAXTF2PLAYERS];
static char CurrentChat[MAXTF2PLAYERS][64];
static char CurrentNPC[MAXTF2PLAYERS][64];
static bool b_NpcHasQuestForPlayer[MAXENTITIES][MAXTF2PLAYERS];
static int b_ParticleToOwner[MAXENTITIES];
static int b_OwnerToParticle[MAXENTITIES];

void Actor_ConfigSetup()
{
	delete ActorKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "actor");
	ActorKv = new KeyValues("Actor");
	ActorKv.SetEscapeSequences(true);
	ActorKv.ImportFromFile(buffer);

	ActorKv.GotoFirstSubKey();
	do
	{
		ActorKv.GetString("model", buffer, sizeof(buffer), "error.mdl");
		if(!buffer[0])
			continue;
		
		PrecacheModel(buffer);

		ActorKv.GetString("wear1", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		ActorKv.GetString("wear2", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		ActorKv.GetString("wear3", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);
		
		if(ActorKv.JumpToKey("Chats"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					ActorKv.GetString("sound", buffer, sizeof(buffer));
					if(buffer[0])
						PrecacheScriptSound(buffer);
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}
	}
	while(ActorKv.GotoNextKey());
}

void Actor_EnableZone(int client, const char[] name)
{
	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();
	do
	{
		static char buffer[PLATFORM_MAX_PATH];
		ActorKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
			if(entity == INVALID_ENT_REFERENCE)
			{
				static float pos[3], ang[3];
				ActorKv.GetVector("pos", pos);
				ActorKv.GetVector("ang", ang);
				
				buffer[0] = view_as<char>(ActorKv[0]);
				entity = NPC_CreateByName("npc_actor", client, pos, ang, TFTeam_Red, buffer);
				
				ActorKv.SetNum("_entref", EntIndexToEntRef(entity));

				pos[2] += 110.0;

				int particle = ParticleEffectAt(pos, "powerup_icon_regen", 0.0);
				
				SetEntPropVector(particle, Prop_Data, "m_angRotation", ang);

				SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
				SDKHook(particle, SDKHook_SetTransmit, QuestIndicatorTransmit);
				b_ParticleToOwner[particle] = EntIndexToEntRef(entity);
				b_OwnerToParticle[entity] = EntIndexToEntRef(particle);
				b_NpcHasQuestForPlayer[entity][client] = Quests_ShouldShowPointer(client);
			}
			else
			{
				b_NpcHasQuestForPlayer[entity][client] = Quests_ShouldShowPointer(client);
			}
		}
	}
	while(ActorKv.GotoNextKey());
}

public Action QuestIndicatorTransmit(int entity, int client)
{
//	return Plugin_Handled;
	int owner = EntRefToEntIndex(b_ParticleToOwner[entity]);
	if(IsValidEntity(owner))
	{
		if(!b_NpcHasQuestForPlayer[owner][client])
		{
			return Plugin_Handled;
		}
	}
	else
	{
		RemoveEntity(entity);
	}
	return Plugin_Continue;
}

void Quests_DisableZone(const char[] name)
{
	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();
	do
	{
		static char buffer[32];
		ActorKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
			if(entity != INVALID_ENT_REFERENCE)
			{
				int particle = EntRefToEntIndex(b_OwnerToParticle[entity]);
				if(IsValidEntity(particle))
				{
					RemoveEntity(particle);
				}
				int brush = EntRefToEntIndex(b_OwnerToBrush[entity]);
				if(IsValidEntity(brush))
				{
					RemoveEntity(brush);
				}
				RemoveEntity(entity);
			}
			
			ActorKv.SetNum("_entref", INVALID_ENT_REFERENCE);
		}
	}
	while(ActorKv.GotoNextKey());
}

bool Actor_Interact(int client, int entity)
{
	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			ActorKv.GetSectionName(CurrentNPC[client], sizeof(CurrentNPC[]));
			//TextStore_DepositBackpack(client, false);
			MainMenu(client);
			return true;
		}
	}
	while(ActorKv.GotoNextKey());
	return false;
}

static bool CheckCondKv(int client, char[] fail = "", int length = 0)
{
	fail[0] = 0;

	if(ActorKv.JumpToKey("cond"))
	{
		bool failed;

		static char buffer[64];

		if(ActorKv.JumpToKey("race"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				static Race race;

				do
				{
					ActorKv.GetSectionName(buffer, sizeof(buffer));
					Races_GetRaceByIndex(RaceIndex[client], race);

					if(StrEqual(race.Name, buffer, false) != view_as<bool>(ActorKv.GetNum(NULL_STRING)))
					{
						failed = true;
						break;
					}
				}
				while(ActorKv.GotoNextKey());
				
				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!failed && ActorKv.JumpToKey("quest"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!failed && ActorKv.JumpToKey("item"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					ActorKv.GetSectionName(buffer, sizeof(buffer));
					int need = ActorKv.GetNum(NULL_STRING);
					int count = TextStore_GetItemCount(buffer);
					if(need < 0)
					{
						if(count >= -need)
						{
							failed = true;
							break;
						}
					}
					else if(need > 0)
					{
						if(count < need)
						{
							if(need == 1)
							{
								strcopy(fail, length, buffer);
							}
							else
							{
								Format(fail, length, "%s x%d", buffer);
							}
							
							failed = true;
							break;
						}
					}
					else if(count)
					{
						failed = true;
						break;
					}
				}
				while(ActorKv.GotoNextKey());
				
				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!failed)
		{
			int value = ActorKv.GetNum("level");
			if(Level[client] < value)
			{
				Format(fail, length, "Level %d", value);
				failed = true;
			}
		}

		ActorKv.GoBack();

		if(failed)
			return false;
	}

	return true;
}

static void MainMenu(int client)
{
	ActorKv.Rewind();
	if(ActorKv.JumpToKey(CurrentNPC[client]))
	{
		int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
		if(ActorKv.JumpToKey("Chats") && ActorKv.GotoFirstSubKey())
		{
			static char buffer[64];

			for(int i; i < 999; i++)
			{
				if(CheckCondKv(client))
				{
					OpenChatLineKv(client);
					break;
				}
				
				ActorKv.GetString("altchat", buffer, sizeof(buffer));
				if(buffer[0] == ';')
				{
					break;
				}
				else if(buffer[0])
				{
					ActorKv.GoBack();
					if(!ActorKv.JumpToKey(buffer))
						break;
				}
				else if(!ActorKv.GotoNextKey())
				{
					break;
				}
			}
		}
	}
}

static void OpenChatLineKv(int client, int entity)
{
	static char buffer1[256];

	if(entity != -1)
	{
		ActorKv.GetString("sound", buffer1, sizeof(buffer1));
		if(buffer1[0])
		{
			if(StrContains(buffer1, ".mp3") == -1 && StrContains(buffer1, ".wav") == -1)
			{
				EmitSoundToClient(client, buffer1, entity);
			}
			else
			{
				EmitGameSoundToClient(client, buffer1, entity);
			}
		}
	}

	if(ActorKv.GetNum("simple"))
	{
		if(entity != -1)
		{
			ActorKv.GetString("text", buffer1, sizeof(buffer1));
			FormatText(client, buffer1, sizeof(buffer1));
			NpcSpeechBubble(entity, buffer1, 5, {255, 255, 255, 255}, {0.0, 0.0, 60.0}, "");
		}
	}
	else
	{
		static char buffer2[64];

		ActorKv.GetString("text", buffer1, sizeof(buffer1));
		FormatText(client, buffer1, sizeof(buffer1));

		Menu menu = new Menu(MenuHandle);
		menu.SetTitle(buffer1);

		bool options;
		if(ActorKv.JumpToKey("options"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					bool cond = CheckCondKv(client, buffer2, sizeof(buffer2));
					if(cond)
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));
						menu.AddItem(buffer1, buffer1);
						options = true;
					}
					else if(buffer2[0])
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));
						Format(buffer1, sizeof(buffer1), "%s [%s]", buffer1, buffer2);
						menu.AddItem(NULL_STRING, buffer1, ITEMDRAW_DISABLED);
					}
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!options)
			menu.AddItem(NULL_STRING, "...");
		
		menu.ExitButton = false;
		menu.Display(client, options ? MENU_TIME_FOREVER : 30);
	}
}

static void FormatText(int client, char[] text, int length)
{
	static char buffer[64];

	GetClientName(client, buffer, sizeof(buffer));
	ReplaceString(text, length, "{playername}", buffer);
}

static int MenuHandle(Menu menu2, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu2;
		}
		case MenuAction_Cancel:
		{
			bool forced = ForcedMenu[client];
			ForcedMenu[client] = false;

			if(forced && choice == MenuCancel_Interrupted)
			{
				MainMenu(client);
			}
			else
			{
				CurrentNPC[client][0] = 0;
			}
		}
		case MenuAction_Select:
		{
			ForcedMenu[client] = false;

			ActorKv.Rewind();
			if(ActorKv.JumpToKey(CurrentNPC[client]))
			{
				int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
				if(ActorKv.JumpToKey("Chats") && ActorKv.JumpToKey(CurrentChat[client]))
				{
				}
			}
		}
	}
	return 0;
}

/*
static Handle TimerZoneEditing[MAXTF2PLAYERS];
static char CurrentSectionEditing[MAXTF2PLAYERS][64];
static char CurrentQuestEditing[MAXTF2PLAYERS][64];
static char CurrentKeyEditing[MAXTF2PLAYERS][64];
static char CurrentNPCEditing[MAXTF2PLAYERS][64];
static char CurrentZoneEditing[MAXTF2PLAYERS][64];

void Quests_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];

	EditMenu menu = new EditMenu();

	if(CurrentKeyEditing[client][0])
	{
		// Set item amount
		// Click (0) to remove
	}
	else if(CurrentSectionEditing[client][0])
	{
		// View item and amounts
		// Type to add 1 new item
	}
	else if(CurrentKeyEditing[client][0])
	{
		// Edit questline item
	}
	else if(CurrentQuestEditing[client][0])
	{
		// Questline details
		// View reward/give/etc with amount of entries
	}
	else if(StrEqual(CurrentKeyEditing[client], "zone"))
	{
		menu.SetTitle("Quests\n%s\n ", CurrentNPCEditing[client]);
		
		KeyValues kv = Zones_GetKv();
		kv.GotoFirstSubKey();

		do
		{
			kv.GetSectionName(buffer1, sizeof(buffer1));
			menu.AddItem(buffer1, buffer1);
		}
		while(kv.GotoNextKey());

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
	}
	else if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Quests\n%s\n ", CurrentNPCEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

		menu.AddItem("", "Set To Default");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
	}
	else if(CurrentNPCEditing[client][0])
	{
		ActorKv.Rewind();
		bool missing = !ActorKv.JumpToKey(CurrentNPCEditing[client]);

		menu.SetTitle("Quests\n%s\nClick to set it's value:\n ", CurrentNPCEditing[client]);

		if(!missing)
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					menu.AddItem(buffer1, buffer1);
				}
				while(ActorKv.GotoNextKey());
				ActorKv.GoBack();
			}

			menu.AddItem("new", "New Quest (NOT FINISHED :3)\n ", ITEMDRAW_DISABLED);
		}
		
		if(missing)
		{
			strcopy(buffer1, sizeof(buffer1), CurrentZoneEditing[client]);
		}
		else
		{
			ActorKv.GetString("zone", buffer1, sizeof(buffer1));
		}
		
		FormatEx(buffer2, sizeof(buffer2), "Zone: \"%s\"%s", buffer1, Zones_GetKv().JumpToKey(buffer1) ? "" : " {WARNING: Zone does not exist}");
		menu.AddItem("zone", buffer2);

		ActorKv.GetString("model", buffer1, sizeof(buffer1), "error.mdl");
		FormatEx(buffer2, sizeof(buffer2), "Model: \"%s\"%s", buffer1, FileExists(buffer1) ? "" : " {WARNING: Model does not exist}");
		menu.AddItem("model", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Scale: %f", ActorKv.GetFloat("scale", 1.0));
		menu.AddItem("scale", buffer2);

		float vec[3];
		ActorKv.GetVector("pos", vec);
		FormatEx(buffer2, sizeof(buffer2), "Position: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("pos", buffer2);

		ActorKv.GetVector("ang", vec);
		FormatEx(buffer2, sizeof(buffer2), "Angle: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("ang", buffer2);

		ActorKv.GetString("sound_talk", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Talk Sound: \"%s\"%s", buffer1, (!buffer1[0] || PrecacheScriptSound(buffer1)) ? "" : " {WARNING: Script does not exist}");
		menu.AddItem("sound_talk", buffer2);

		ActorKv.GetString("sound_leave", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Leave Sound: \"%s\"%s", buffer1, (!buffer1[0] || PrecacheScriptSound(buffer1)) ? "" : " {WARNING: Script does not exist}");
		menu.AddItem("sound_leave", buffer2);

		if(!missing)
		{
			ActorKv.GetString("anim_idle", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Idle Animation: \"%s\"", buffer1);
			menu.AddItem("anim_idle", buffer2);

			ActorKv.GetString("anim_talk", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Talk Animation: \"%s\"", buffer1);
			menu.AddItem("anim_talk", buffer2);

			ActorKv.GetString("anim_leave", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Leave Animation: \"%s\"", buffer1);
			menu.AddItem("anim_leave", buffer2);

			ActorKv.GetString("wear1", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1: \"%s\"", buffer1);
			menu.AddItem("wear1", buffer2);

			ActorKv.GetString("wear2", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2: \"%s\"", buffer1);
			menu.AddItem("wear2", buffer2);

			ActorKv.GetString("wear3", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3: \"%s\"", buffer1);
			menu.AddItem("wear3", buffer2);

			menu.AddItem("delete", "Delete NPC");
		}

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPC);
	}
	else if(CurrentZoneEditing[client][0])
	{
		menu.SetTitle("Quests\n%s\nType in chat to create a new NPC\n ", CurrentZoneEditing[client]);

		ActorKv.Rewind();
		ActorKv.GotoFirstSubKey();
		do
		{
			ActorKv.GetString("zone", buffer1, sizeof(buffer1));
			if(strlen(CurrentZoneEditing[client]) < 2 || StrEqual(CurrentZoneEditing[client], buffer1, false))
			{
				ActorKv.GetSectionName(buffer1, sizeof(buffer1));
				menu.AddItem(buffer1, buffer1);
			}
		}
		while(ActorKv.GotoNextKey());

		menu.ExitBackButton = true;
		menu.Display(client, NPCPicker);

		if(strlen(CurrentZoneEditing[client]) > 1)
		{
			Zones_RenderZone(client, CurrentZoneEditing[client]);
			delete TimerZoneEditing[client];
			TimerZoneEditing[client] = CreateTimer(1.0, Timer_RefreshHud, client);
		}
	}
	else
	{
		menu.SetTitle("Quests\n \nImportant Note:\nQuestline names have to be unique or they will be synced!\n \nSelect a zone:\n ");

		KeyValues zones = Zones_GetKv();

		menu.AddItem(" ", "All Zones");
		
		if(zones.GotoFirstSubKey())
		{
			do
			{
				zones.GetSectionName(buffer1, sizeof(buffer1));
				menu.AddItem(buffer1, buffer1);
			}
			while(zones.GotoNextKey());
		}

		menu.ExitBackButton = true;
		menu.Display(client, ZonePicker);
	}
}

static Action Timer_RefreshHud(Handle timer, int client)
{
	TimerZoneEditing[client] = null;
	if(Editor_MenuFunc(client) != NPCPicker)
		return Plugin_Stop;
	
	Quests_EditorMenu(client);
	return Plugin_Continue;
}

static void ZonePicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]), key);
	Quests_EditorMenu(client);
}

static void NPCPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentZoneEditing[client][0] = 0;
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentNPCEditing[client], sizeof(CurrentNPCEditing[]), key);
	Quests_EditorMenu(client);
}

static void AdjustNPC(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentNPCEditing[client][0] = 0;
		Quests_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	if(!ActorKv.JumpToKey(CurrentNPCEditing[client]))
	{
		ActorKv.JumpToKey(CurrentNPCEditing[client], true);
		ActorKv.SetString("zone", CurrentZoneEditing[client]);
	}

	if(StrEqual(key, "pos"))
	{
		float pos[3];
		GetClientPointVisible(client, _, _, _, pos);
		ActorKv.SetVector("pos", pos);
	}
	else if(StrEqual(key, "ang"))
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		ActorKv.SetVector("ang", ang);
	}
	else if(StrEqual(key, "delete"))
	{
		ActorKv.DeleteThis();
		CurrentNPCEditing[client][0] = 0;
	}
	else
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Quests_EditorMenu(client);
		return;
	}

	SaveQuestsKv();
	Quests_ConfigSetup();
	Zones_Rebuild();
	Quests_EditorMenu(client);
}

static void AdjustNPCKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Quests_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);

	if(key[0])
	{
		ActorKv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		ActorKv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	SaveQuestsKv();
	Quests_ConfigSetup();
	Zones_Rebuild();
	Quests_EditorMenu(client);
}

static void SaveQuestsKv()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "quests");

	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();

	do
	{
		ActorKv.DeleteKey("_entref");
	}
	while(ActorKv.GotoNextKey());

	ActorKv.Rewind();
	ActorKv.ExportToFile(buffer);
}
*/
