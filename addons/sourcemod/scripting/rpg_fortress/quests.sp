#pragma semicolon 1
#pragma newdecls required

enum
{
	Status_NotStarted = 0,
	Status_Canceled,
	Status_InProgress,
	Status_Completed
}

static KeyValues QuestKv;
static int BookPage[MAXTF2PLAYERS];
static bool BookDirty[MAXTF2PLAYERS];

void Quests_ConfigSetup()
{
	delete QuestKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "quests");
	QuestKv = new KeyValues("Quests");
	QuestKv.SetEscapeSequences(true);
	QuestKv.ImportFromFile(buffer);
}

void Quests_AddKill(int client, int entity)
{
	char name[64];
	NPC_GetNameById(i_NpcInternalId[entity], name, sizeof(name));

	KeyValues kv = Saves_Kv("quests");
	kv.JumpToKey("_kills", true);
	kv.JumpToKey(name, true);

	for(int target = 1; target <= MaxClients; target++)
	{
		if(client == target || Party_IsClientMember(client, target))
		{
			static char id[64];
			if(Saves_ClientCharId(target, id, sizeof(id)))
			{
				kv.SetNum(id, kv.GetNum(id) + 1);
				Quests_MarkBookDirty(target);
			}
		}
	}
}

void Quests_MarkBookDirty(int client)
{
	BookDirty[client] = true;
}

bool Quests_CanTurnIn(int client, const char[] name)
{
	bool result;

	static char id[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
			result = CanTurnInQuest(client, id);
	}
	
	return result;
}

static bool CanTurnInQuest(int client, const char[] id, char[] title = "", int length = 0)
{
	bool canTurnIn = true;
	static char buffer[64];

	if(QuestKv.JumpToKey("obtain"))
	{
		Format(title, length, "%s\n \nObtain:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);
				int count = TextStore_GetItemCount(client, buffer);

				Format(title, length, "%s\n%s (%d / %d)", title, buffer, count, need);
				
				if(count < need)
					canTurnIn = false;
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}

		QuestKv.GoBack();
	}

	if(QuestKv.JumpToKey("give"))
	{
		Format(title, length, "%s\n \nGive:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);
				int count = TextStore_GetItemCount(client, buffer);

				Format(title, length, "%s\n%s (%d / %d)", title, buffer, count, need);
				
				if(count < need)
					canTurnIn = false;
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}

		QuestKv.GoBack();
	}

	if(QuestKv.JumpToKey("kill"))
	{
		KeyValues kv = Saves_Kv("quests");
		kv.JumpToKey("_kills", true);

		Format(title, length, "%s\n \nKill:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);

				int count;
				if(kv.JumpToKey(buffer, true))
				{
					count = kv.GetNum(id);
					kv.GoBack();
				}

				Format(title, length, "%s\n%s (%d / %d)", title, buffer, count, need);
				
				if(count < need)
					canTurnIn = false;
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}
		
		QuestKv.GoBack();
	}

	if(QuestKv.JumpToKey("equip"))
	{
		Format(title, length, "%s\n \nEquip:", title);
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				Format(title, length, "%s\n%s", title, buffer);

				if(canTurnIn)
				{
					canTurnIn = false;

					int i, entity;
					while(TF2_GetItem(client, entity, i))
					{
						int index = Store_GetStoreOfEntity(entity);
						if(index != -1)
						{
							KeyValues kv = TextStore_GetItemKv(index);
							if(kv)
							{
								static char buffer2[48];
								kv.GetSectionName(buffer2, sizeof(buffer2));
								if(StrEqual(buffer, buffer2, false))
								{
									canTurnIn = true;
									break;
								}
							}
						}
					}
				}
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}

		QuestKv.GoBack();
	}

	return (canTurnIn || CvarRPGInfiniteLevelAndAmmo.BoolValue);
}

int Quests_GetStatus(int client, const char[] name)
{
	static char id[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
		{
			KeyValues kv = Saves_Kv("quests");
			kv.JumpToKey(name, true);
			return kv.GetNum(id);
		}
	}

	return -1;
}

bool Quests_StartQuest(int client, const char[] name)
{
	static char id[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
		{
			KeyValues kv = Saves_Kv("quests");
			kv.JumpToKey(name, true);

			int previous = kv.GetNum(id);
			if(previous != Status_InProgress)
			{
				SPrintToChat(client, "New Quest: %s", name);
				kv.SetNum(id, Status_InProgress);

				if(previous != Status_Canceled && QuestKv.JumpToKey("start"))
				{
					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(id, sizeof(id));
							TextStore_AddItemCount(client, id, QuestKv.GetNum(NULL_STRING, 1));
						}
						while(QuestKv.GotoNextKey(false));
					}

					Saves_SaveClient(client);
				}

				Quests_MarkBookDirty(client);
			}

			return true;
		}
	}

	return false;
}

bool Quests_CancelQuest(int client, const char[] name)
{
	static char id[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
		{
			KeyValues kv = Saves_Kv("quests");
			kv.JumpToKey(name, true);
			
			if(kv.GetNum(id) == Status_InProgress)
			{
				SPrintToChat(client, "Quest Finished: %s", name);
				kv.SetNum(id, Status_Canceled);
				Quests_MarkBookDirty(client);
			}

			return true;
		}
	}

	return false;
}

bool Quests_TurnIn(int client, const char[] name)
{
	static char id[64], buffer[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
		{
			KeyValues kv = Saves_Kv("quests");
			kv.JumpToKey(name, true);

			if(kv.GetNum(id) != Status_Completed)
			{
				SPrintToChat(client, "Quest Finished: %s", name);
				kv.SetNum(id, Status_Completed);

				if(QuestKv.JumpToKey("give"))
				{
					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(buffer, sizeof(buffer));
							TextStore_AddItemCount(client, buffer, -QuestKv.GetNum(NULL_STRING, 1));
						}
						while(QuestKv.GotoNextKey(false));

						QuestKv.GoBack();
					}

					QuestKv.GoBack();
				}

				if(QuestKv.JumpToKey("kill"))
				{
					kv = Saves_Kv("quests");
					kv.JumpToKey("_kills", true);

					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(buffer, sizeof(buffer));
							if(kv.JumpToKey(buffer))
							{
								kv.SetNum(id, kv.GetNum(id) - QuestKv.GetNum(NULL_STRING, 1));
								kv.GoBack();
							}
						}
						while(QuestKv.GotoNextKey(false));

						QuestKv.GoBack();
					}

					QuestKv.GoBack();
				}

				if(QuestKv.JumpToKey("reward"))
				{
					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(buffer, sizeof(buffer));
							TextStore_AddItemCount(client, buffer, QuestKv.GetNum(NULL_STRING, 1));
						}
						while(QuestKv.GotoNextKey(false));
					}
				}

				Saves_SaveClient(client);
				Quests_MarkBookDirty(client);
			}

			return true;
		}
	}

	return false;
}

bool Quests_BookMenuDirty(int client)
{
	return BookDirty[client];
}

bool Quests_BookMenu(int client)
{
	BookDirty[client] = false;

	Menu menu = new Menu(Quests_BookHandle);
	menu.SetTitle("RPG Fortress\n \n");

	int pages;
	
	static char steamid[64], name[64], buffer[512];
	if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
	{
		QuestKv.Rewind();
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetSectionName(name, sizeof(name));
			if(QuestKv.GotoFirstSubKey())
			{
				do
				{
					KeyValues kv = Saves_Kv("quests");
					if(kv.JumpToKey(name))
					{
						QuestKv.GetSectionName(buffer, sizeof(buffer));
						if(kv.JumpToKey(buffer))
						{
							if(kv.GetNum(steamid) == Status_InProgress)
							{
								pages++;

								if((BookPage[client] / 2) != (pages / 2))
									continue;

								Format(buffer, sizeof(buffer), "%s - %s", name, buffer);
								CanTurnInQuest(client, steamid, buffer, sizeof(buffer));
								Format(buffer, sizeof(buffer), "%s\n ", buffer);
								menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
							}
						}
					}
				}
				while(QuestKv.GotoNextKey());

				QuestKv.GoBack();
			}
		}
		while(QuestKv.GotoNextKey());
	}

	int count = menu.ItemCount;
	if(count)
	{
		for(; count < 7; count++)
		{
			menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
		}

		if(BookPage[client])
		{
			menu.AddItem(NULL_STRING, "Back");
		}
		else
		{
			menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
		}
		
		if((pages / 2) > (BookPage[client] / 2))
		{
			menu.AddItem(NULL_STRING, "Next");
		}

		menu.Pagination = 0;
		menu.ExitButton = true;
	}
	else if(BookPage[client])
	{
		BookPage[client] = 0;
		delete menu;
		return Quests_BookMenu(client);
	}
	else
	{
		menu.AddItem(NULL_STRING, "  No active quests, talk to", ITEMDRAW_DISABLED);
		menu.AddItem(NULL_STRING, "a NPC with an icon above them.", ITEMDRAW_DISABLED);
	}

	return menu.Display(client, MENU_TIME_FOREVER);
}

public int Quests_BookHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			TextStore_UnmarkInMenu(client);

			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
			switch(choice)
			{
				case 7:
					BookPage[client]--;
				
				case 8:
					BookPage[client]++;
			}
			
			Quests_BookMenu(client);
		}
	}
	return 0;
}

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
		QuestKv.Rewind();
		bool missing = !QuestKv.JumpToKey(CurrentNPCEditing[client]);

		menu.SetTitle("Quests\n%s\nClick to set it's value:\n ", CurrentNPCEditing[client]);

		if(!missing)
		{
			if(QuestKv.GotoFirstSubKey())
			{
				do
				{
					QuestKv.GetSectionName(buffer1, sizeof(buffer1));
					menu.AddItem(buffer1, buffer1);
				}
				while(QuestKv.GotoNextKey());
				QuestKv.GoBack();
			}

			menu.AddItem("new", "New Quest (NOT FINISHED :3)\n ", ITEMDRAW_DISABLED);
		}
		
		if(missing)
		{
			strcopy(buffer1, sizeof(buffer1), CurrentZoneEditing[client]);
		}
		else
		{
			QuestKv.GetString("zone", buffer1, sizeof(buffer1));
		}
		
		FormatEx(buffer2, sizeof(buffer2), "Zone: \"%s\"%s", buffer1, Zones_GetKv().JumpToKey(buffer1) ? "" : " {WARNING: Zone does not exist}");
		menu.AddItem("zone", buffer2);

		QuestKv.GetString("model", buffer1, sizeof(buffer1), "error.mdl");
		FormatEx(buffer2, sizeof(buffer2), "Model: \"%s\"%s", buffer1, FileExists(buffer1) ? "" : " {WARNING: Model does not exist}");
		menu.AddItem("model", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Scale: %f", QuestKv.GetFloat("scale", 1.0));
		menu.AddItem("scale", buffer2);

		float vec[3];
		QuestKv.GetVector("pos", vec);
		FormatEx(buffer2, sizeof(buffer2), "Position: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("pos", buffer2);

		QuestKv.GetVector("ang", vec);
		FormatEx(buffer2, sizeof(buffer2), "Angle: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("ang", buffer2);

		QuestKv.GetString("sound_talk", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Talk Sound: \"%s\"%s", buffer1, (!buffer1[0] || PrecacheScriptSound(buffer1)) ? "" : " {WARNING: Script does not exist}");
		menu.AddItem("sound_talk", buffer2);

		QuestKv.GetString("sound_leave", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Leave Sound: \"%s\"%s", buffer1, (!buffer1[0] || PrecacheScriptSound(buffer1)) ? "" : " {WARNING: Script does not exist}");
		menu.AddItem("sound_leave", buffer2);

		if(!missing)
		{
			QuestKv.GetString("anim_idle", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Idle Animation: \"%s\"", buffer1);
			menu.AddItem("anim_idle", buffer2);

			QuestKv.GetString("anim_talk", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Talk Animation: \"%s\"", buffer1);
			menu.AddItem("anim_talk", buffer2);

			QuestKv.GetString("anim_leave", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Leave Animation: \"%s\"", buffer1);
			menu.AddItem("anim_leave", buffer2);

			QuestKv.GetString("wear1", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1: \"%s\"", buffer1);
			menu.AddItem("wear1", buffer2);

			QuestKv.GetString("wear2", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2: \"%s\"", buffer1);
			menu.AddItem("wear2", buffer2);

			QuestKv.GetString("wear3", buffer1, sizeof(buffer1));
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

		QuestKv.Rewind();
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetString("zone", buffer1, sizeof(buffer1));
			if(strlen(CurrentZoneEditing[client]) < 2 || StrEqual(CurrentZoneEditing[client], buffer1, false))
			{
				QuestKv.GetSectionName(buffer1, sizeof(buffer1));
				menu.AddItem(buffer1, buffer1);
			}
		}
		while(QuestKv.GotoNextKey());

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

	QuestKv.Rewind();
	if(!QuestKv.JumpToKey(CurrentNPCEditing[client]))
	{
		QuestKv.JumpToKey(CurrentNPCEditing[client], true);
		QuestKv.SetString("zone", CurrentZoneEditing[client]);
	}

	if(StrEqual(key, "pos"))
	{
		float pos[3];
		GetClientPointVisible(client, _, _, _, pos);
		QuestKv.SetVector("pos", pos);
	}
	else if(StrEqual(key, "ang"))
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		QuestKv.SetVector("ang", ang);
	}
	else if(StrEqual(key, "delete"))
	{
		QuestKv.DeleteThis();
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

	QuestKv.Rewind();
	QuestKv.JumpToKey(CurrentNPCEditing[client], true);

	if(key[0])
	{
		QuestKv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		QuestKv.DeleteKey(CurrentKeyEditing[client]);
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

	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();

	do
	{
		QuestKv.DeleteKey("_entref");
	}
	while(QuestKv.GotoNextKey());

	QuestKv.Rewind();
	QuestKv.ExportToFile(buffer);
}