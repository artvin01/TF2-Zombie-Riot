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
static int BookPage[MAXPLAYERS];
static bool BookDirty[MAXPLAYERS];

void Quests_PluginStart()
{
	RegAdminCmd("rpg_givekill", QuestsKillDebug, ADMFLAG_ROOT, "Give X kills from X NPC");
	RegAdminCmd("rpg_clearquests", QuestsClearDebug, ADMFLAG_ROOT, "Remove all quest status");
}

static Action QuestsKillDebug(int client, int args)
{
	if(!client)
	{

	}
	else if(args == 1 || args == 2)
	{
		char name[64];
		GetCmdArg(1, name, sizeof(name));

		int amount = 999;
		if(args == 2)
			amount = GetCmdArgInt(2);
		
		KeyValues kv = Saves_Kv("quests");
		kv.JumpToKey("_kills", true);
		kv.JumpToKey(name, true);

		char id[64];
		if(Saves_ClientCharId(client, id, sizeof(id)))
		{
			kv.SetNum(id, kv.GetNum(id) + amount);
			Quests_MarkBookDirty(client);
			SReplyToCommand(client, "Gave %d kills for %s", amount, name);
		}
		else
		{
			SReplyToCommand(client, "No save state");
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: rpg_givekill <name> [amount]");
	}

	return Plugin_Handled;
}

static Action QuestsClearDebug(int client, int args)
{
	char id[64];
	if(client && Saves_ClientCharId(client, id, sizeof(id)))
	{
		Quests_DeleteChar(id);
		SReplyToCommand(client, "Cleared all quest status");
	}
	else
	{
	}

	return Plugin_Handled;
}

void Quests_ConfigSetup()
{
	delete QuestKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "quests");
	QuestKv = new KeyValues("Quests");
	QuestKv.SetEscapeSequences(true);
	QuestKv.ImportFromFile(buffer);
}

void Quests_DeleteChar(const char[] id)
{
	KeyValues kv = Saves_Kv("quests");
	
	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.DeleteKey(id);

			if(kv.GotoFirstSubKey())
			{
				do
				{
					kv.DeleteKey(id);
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}
		}
		while(kv.GotoNextKey());
	}
}

void Quests_AddKill(int client, int entity)
{
	//char name[64];
	//NPC_GetNameById(i_NpcInternalId[entity], name, sizeof(name));

	KeyValues kv = Saves_Kv("quests");
	kv.JumpToKey("_kills", true);
	kv.JumpToKey(c_NpcName[entity], true);

	static float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);

	int minlevel = Level[entity] * 3 / 4;

	for(int target = 1; target <= MaxClients; target++)
	{
		if(client == target || Party_IsClientMember(client, target))
		{
			if(client != target)
			{
				if(Level[target] < minlevel && !Stats_GetHasKill(target, c_NpcName[entity]))
					continue;
				
				static float pos2[3];
				GetClientAbsOrigin(target, pos2);
				if(GetVectorDistance(pos1, pos2, true) > 1000000.0)	// 1000 HU
					continue;
			}

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

KeyValues Quests_KV()
{
	QuestKv.Rewind();
	return QuestKv;
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
	int value = -1;

	static char id[64];
	if(Saves_ClientCharId(client, id, sizeof(id)))
	{
		QuestKv.Rewind();
		if(QuestKv.JumpToKey(name))
		{
			KeyValues kv = Saves_Kv("quests");
			kv.JumpToKey(name, true);
			value = kv.GetNum(id);
			
			if(value == Status_Completed)
			{
				int repeat = QuestKv.GetNum("repeattime");
				if(repeat > 0)
				{
					Format(id, sizeof(id), "%s_t", id);
					if(kv.GetNum(id) < (GetTime() - repeat - 40))
						value = Status_NotStarted;
				}
			}
		}
	}

	return value;
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
				ClientCommand(client, "playgamesound ui/quest_decode.wav");
				SPrintToChat(client, "New Quest: %s", name);
				kv.SetNum(id, Status_InProgress);

				if(previous != Status_Canceled && QuestKv.JumpToKey("start"))
				{
					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(id, sizeof(id));
							TextStore_AddItemCount(client, id, QuestKv.GetNum(NULL_STRING, 1), _,true);
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

			if(kv.GetNum(id) != Status_Completed || QuestKv.GetNum("repeattime") > 0)
			{
				static const char sounds[][] =
				{
					"one",
					"two",
					"three",
					"four",
					"five",
					"six"
				};

				ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", sounds[GetURandomInt() % sizeof(sounds)]);
				SPrintToChat(client, "Quest Finished: %s", name);
				kv.SetNum(id, Status_Completed);
				
				Format(buffer, sizeof(buffer), "%s_t", id);
				kv.SetNum(buffer, GetTime());

				if(QuestKv.JumpToKey("give"))
				{
					if(QuestKv.GotoFirstSubKey(false))
					{
						do
						{
							QuestKv.GetSectionName(buffer, sizeof(buffer));
							TextStore_AddItemCount(client, buffer, -QuestKv.GetNum(NULL_STRING, 1), _,true);
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
								kv.SetNum(id, 0);//kv.GetNum(id) - QuestKv.GetNum(NULL_STRING, 1));
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
							TextStore_AddItemCount(client, buffer, QuestKv.GetNum(NULL_STRING, 1), _,true);
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
	
	static char steamid[64], buffer[448];
	if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
	{
		QuestKv.Rewind();
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetSectionName(buffer, sizeof(buffer));
			
			KeyValues kv = Saves_Kv("quests");
			if(kv.JumpToKey(buffer))
			{
				if(kv.GetNum(steamid) == Status_InProgress)
				{
					if(BookPage[client] != (pages++))
						continue;

					CanTurnInQuest(client, steamid, buffer, sizeof(buffer));
					Format(buffer, sizeof(buffer), "%s\n ", buffer);
					menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
				}
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
		
		if((pages - 1) > BookPage[client])
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
				TextStore_SwapMenu(client);
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

static char CurrentSectionEditing[MAXPLAYERS][64];
static char CurrentQuestEditing[MAXPLAYERS][64];
static char CurrentKeyEditing[MAXPLAYERS][64];

void Quests_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];

	EditMenu menu = new EditMenu();

	if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Actors\n%s - %s\n ", CurrentQuestEditing[client], CurrentSectionEditing[client]);

		bool invalid;
		if(CurrentSectionEditing[client][0])
		{
			if(StrEqual(CurrentSectionEditing[client], "kill"))
			{
			}
			else if(!TextStore_IsValidName(CurrentKeyEditing[client]))
			{
				FormatEx(buffer1, sizeof(buffer1), "\"%s\" {WARNING: Item does not exist}", CurrentKeyEditing[client]);
				menu.AddItem("1", buffer1, ITEMDRAW_DISABLED);
				invalid = true;
			}
		}

		if(!invalid)
		{
			FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
			menu.AddItem("1", buffer1, ITEMDRAW_DISABLED);
		}

		menu.ExitBackButton = true;
		menu.Display(client, AdjustQuestSharedKey);
	}
	else if(CurrentSectionEditing[client][0])
	{
		QuestKv.Rewind();
		QuestKv.JumpToKey(CurrentQuestEditing[client]);
		bool missing = !QuestKv.JumpToKey(CurrentSectionEditing[client]);

		menu.SetTitle("Quests\n%s - %s\n ", CurrentQuestEditing[client], CurrentSectionEditing[client]);

		menu.AddItem("", "Type to add an item", ITEMDRAW_DISABLED);

		if(!missing && QuestKv.GotoFirstSubKey(false))
		{
			if(StrEqual(CurrentSectionEditing[client], "kill"))
			{
				do
				{
					QuestKv.GetSectionName(buffer1, sizeof(buffer1));
					Format(buffer2, sizeof(buffer2), "%s x%d", buffer1, QuestKv.GetNum(NULL_STRING));
					menu.AddItem(buffer1, buffer2);
				}
				while(QuestKv.GotoNextKey(false));
			}
			else
			{
				do
				{
					QuestKv.GetSectionName(buffer1, sizeof(buffer1));
					Format(buffer2, sizeof(buffer2), "%s x%d%s", buffer1, QuestKv.GetNum(NULL_STRING), TextStore_IsValidName(buffer1) ? "" : " {WARNING: Item does not exist}");
					menu.AddItem(buffer1, buffer2);
				}
				while(QuestKv.GotoNextKey(false));
			}
		}

		menu.ExitBackButton = true;
		menu.Display(client, AdjustQuestSection);
	}
	else if(CurrentQuestEditing[client][0])
	{
		QuestKv.Rewind();
		QuestKv.JumpToKey(CurrentQuestEditing[client]);

		menu.SetTitle("Quests\n%s\n ", CurrentQuestEditing[client]);

		int repeat = QuestKv.GetNum("repeattime");
		if(repeat < 1)
		{
			Format(buffer1, sizeof(buffer1), "Repeat: None");
		}
		else if(repeat > 40)
		{
			Format(buffer1, sizeof(buffer1), "Repeat: In %.4f Hours", repeat / 3600.0);
		}
		else
		{
			Format(buffer1, sizeof(buffer1), "Repeat: Always");
		}
		menu.AddItem("_repeattime", buffer1);

		Format(buffer1, sizeof(buffer1), "Start Quest Give Items (%d Entries)", CountEntries("start"));
		menu.AddItem("start", buffer1);

		Format(buffer1, sizeof(buffer1), "Turn In Quest Rewards (%d Entries)\n ", CountEntries("reward"));
		menu.AddItem("reward", buffer1);

		menu.AddItem("reward", "Objectives:", ITEMDRAW_DISABLED);

		Format(buffer1, sizeof(buffer1), "Equip Item (%d Entries)", CountEntries("equip"));
		menu.AddItem("equip", buffer1);

		Format(buffer1, sizeof(buffer1), "Kill NPC (%d Entries)", CountEntries("kill"));
		menu.AddItem("kill", buffer1);

		Format(buffer1, sizeof(buffer1), "Give Item (%d Entries)", CountEntries("give"));
		menu.AddItem("give", buffer1);

		Format(buffer1, sizeof(buffer1), "Have Item (%d Entries)", CountEntries("obtain"));
		menu.AddItem("obtain", buffer1);

		menu.AddItem("delete", "Delete");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustQuest);
	}
	else
	{
		menu.SetTitle("Quests\nSelect a quest:\n ");

		menu.AddItem("new", "Type in chat to create a new Quest", ITEMDRAW_DISABLED);
		
		QuestKv.Rewind();
		if(QuestKv.GotoFirstSubKey())
		{
			bool first = true;

			do
			{
				QuestKv.GetSectionName(buffer1, sizeof(buffer1));
				if(first)
				{
					menu.AddItem(buffer1, buffer1);
					first = false;
				}
				else
				{
					menu.InsertItem(1, buffer1, buffer1);
				}
			}
			while(QuestKv.GotoNextKey());
		}

		menu.ExitBackButton = true;
		menu.Display(client, QuestPicker);
	}
}

static int CountEntries(const char[] section)
{
	int count;

	if(QuestKv.JumpToKey(section))
	{
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				count++;
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}

		QuestKv.GoBack();
	}

	return count;
}

static void QuestPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentQuestEditing[client], sizeof(CurrentQuestEditing[]), key);
	Quests_EditorMenu(client);
}

static void AdjustQuest(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentQuestEditing[client][0] = 0;
		Quests_EditorMenu(client);
		return;
	}

	QuestKv.Rewind();
	QuestKv.JumpToKey(CurrentQuestEditing[client], true);

	if(StrEqual(key, "delete"))
	{
		QuestKv.DeleteThis();
		CurrentQuestEditing[client][0] = 0;
	}
	else if(key[0] == '_')
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key[1]);
		Quests_EditorMenu(client);
	}
	else
	{
		strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), key);
		Quests_EditorMenu(client);
		return;
	}

	SaveQuestsKv();
	Quests_ConfigSetup();
	Quests_EditorMenu(client);
}

static void AdjustQuestSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Quests_EditorMenu(client);
		return;
	}

	strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
	Quests_EditorMenu(client);
}

static void AdjustQuestSharedKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Quests_EditorMenu(client);
		return;
	}

	QuestKv.Rewind();
	QuestKv.JumpToKey(CurrentQuestEditing[client], true);
	if(CurrentSectionEditing[client][0])
		QuestKv.JumpToKey(CurrentSectionEditing[client], true);
	
	int value;
	if(StrEqual(CurrentKeyEditing[client], "repeattime"))
	{
		value = RoundFloat(StringToFloat(key) * 3600.0);
	}
	else
	{
		value = StringToInt(key);
	}

	if(value > 0)
	{
		QuestKv.SetNum(CurrentKeyEditing[client], value);
	}
	else
	{
		QuestKv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	SaveQuestsKv();
	Quests_ConfigSetup();
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