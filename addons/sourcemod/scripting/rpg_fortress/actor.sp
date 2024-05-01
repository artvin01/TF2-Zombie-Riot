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
	// TODO: Delete actor NPCs

	delete ActorKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "actor");
	ActorKv = new KeyValues("Actor");
	ActorKv.SetEscapeSequences(true);
	ActorKv.ImportFromFile(buffer);

	ActorKv.GotoFirstSubKey();
	do
	{
		ActorKv.GetString("model", buffer, sizeof(buffer), COMBINE_CUSTOM_MODEL);
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

void Actor_EnterZone(int client, const char[] name)
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
				
				buffer[0] = view_as<char>(ActorKv);
				entity = NPC_CreateByName("npc_actor", client, pos, ang, TFTeam_Red, buffer);
				
				ActorKv.SetNum("_entref", EntIndexToEntRef(entity));

				pos[2] += 110.0;

				int particle = ParticleEffectAt(pos, "powerup_icon_regen", 0.0);
				
				SetEntPropVector(particle, Prop_Data, "m_angRotation", ang);

				SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
				SDKHook(particle, SDKHook_SetTransmit, QuestIndicatorTransmit);
				b_ParticleToOwner[particle] = EntIndexToEntRef(entity);
				b_OwnerToParticle[entity] = EntIndexToEntRef(particle);
				b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
			}
			else
			{
				b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
			}
		}
	}
	while(ActorKv.GotoNextKey());
}

static Action QuestIndicatorTransmit(int entity, int client)
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

void Actor_DisableZone(const char[] name)
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

/* Must be first interactable */
bool Actor_Interact(int client, int entity)
{
	if(CurrentChat[client][0])
		return true;
	
	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			ActorKv.GetSectionName(CurrentNPC[client], sizeof(CurrentNPC[]));
			StartChat(client);
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
					ActorKv.GetSectionName(buffer, sizeof(buffer));
					switch(ActorKv.GetNum(NULL_STRING))
					{
						case 0:	// Not Started
						{
							if(Quests_GetStatus(client, buffer) >= Status_InProgress)
							{
								failed = true;
								break;
							}
						}
						case 1:	// In Progress
						{
							if(Quests_GetStatus(client, buffer) != Status_InProgress ||
								Quests_CanTurnIn(client, buffer))
							{
								failed = true;
								break;
							}
						}
						case 2:	// Can Turn In
						{
							if(Quests_GetStatus(client, buffer) != Status_InProgress ||
								!Quests_CanTurnIn(client, buffer))
							{
								failed = true;
								break;
							}
						}
						case 3:	// Completed
						{
							if(Quests_GetStatus(client, buffer) != Status_Completed)
							{
								failed = true;
								break;
							}
						}
					}
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
					int count = TextStore_GetItemCount(client, buffer);
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

bool Actor_InChatMenu(int client, bool message = true)
{
	bool inChat = view_as<bool>(CurrentChat[client][0]);
	if(inChat && message)
		PrintToChat(client, "[SM] You can not use this command right now");
	
	return inChat;
}

void Actor_ReopenMenu(int client)
{
	ActorKv.Rewind();
	if(ActorKv.JumpToKey(CurrentNPC[client]))
	{
		int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
		if(ActorKv.JumpToKey("Chats") && ActorKv.JumpToKey(CurrentChat[client]))
		{
			OpenChatLineKv(client, entity, true);
		}
	}
}

static void StartChat(int client, const char[] override = "")
{
	if(override[0])
	{
		CurrentChat[client][0] = 0;
	}
	else if(CurrentChat[client][0])
	{
		// Should never call anyways
		Actor_ReopenMenu(client);
		return;
	}

	ActorKv.Rewind();
	if(ActorKv.JumpToKey(CurrentNPC[client]))
	{
		int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
		if(ActorKv.JumpToKey("Chats"))
		{
			bool found;

			if(override[0])
			{
				found = ActorKv.JumpToKey(override);
			}
			else
			{
				found = ActorKv.GotoFirstSubKey();
			}

			if(found)
			{
				static char buffer[64];

				for(int i; i < 999; i++)
				{
					if(CheckCondKv(client))
					{
						OpenChatLineKv(client, entity, false);
						return;
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

	if(ForcedMenu[client])
	{
		ForcedMenu[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

static bool ShouldShowPointerKv(int client)
{
	bool result;
	if(ActorKv.JumpToKey("Chats"))
	{
		if(ActorKv.GotoFirstSubKey())
		{
			static char buffer[64];

			for(int i; i < 999; i++)
			{
				if(CheckCondKv(client))
				{
					// Simple text, don't show icon
					if(ActorKv.GetNum("simple"))
						break;
					
					if(ActorKv.JumpToKey("options"))
					{
						if(ActorKv.GotoFirstSubKey())
						{
							do
							{
								bool cond = CheckCondKv(client);
								if(cond)
								{
									result = true;
									break;
								}
							}
							while(ActorKv.GotoNextKey());

							ActorKv.GoBack();
						}

						ActorKv.GoBack();
					}

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

			ActorKv.GoBack();
		}

		ActorKv.GoBack();
	}

	return result;
}

static void OpenChatLineKv(int client, int entity, bool noActions)
{
	static char buffer1[256], buffer2[64];

	if(!noActions && entity != -1)
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

	if(!noActions && ActorKv.JumpToKey("actions"))
	{
		if(ActorKv.GetNum("deposit"))
			TextStore_DepositBackpack(client, false, true);
		
		if(ActorKv.JumpToKey("setquest"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					switch(ActorKv.GetNum(NULL_STRING))
					{
						case 0:
							Quests_StartQuest(client, buffer1);
						
						case 1:
							Quests_CancelQuest(client, buffer1);
						
						case 2:
							Quests_TurnIn(client, buffer1);
					}
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}
		
		if(ActorKv.JumpToKey("giveitem"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				do
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					TextStore_AddItemCount(client, buffer1, ActorKv.GetNum(NULL_STRING));
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		ActorKv.GoBack();
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

		if(options)
		{
			ForcedMenu[client] = true;
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		else
		{
			menu.AddItem(NULL_STRING, "...");

			if(ForcedMenu[client])
			{
				ForcedMenu[client] = false;
				SetEntityMoveType(client, MOVETYPE_WALK);
			}
		}
		
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

static int MenuHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_Disconnected)
			{
				ForcedMenu[client] = false;
				CurrentNPC[client][0] = 0;
				CurrentChat[client][0] = 0;
			}
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));

			if(buffer[0])
			{
				ActorKv.Rewind();
				if(ActorKv.JumpToKey(CurrentNPC[client]))
				{
					//int entity = EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE));
					if(ActorKv.JumpToKey("Chats") &&
						ActorKv.JumpToKey(CurrentChat[client]) &&
						ActorKv.JumpToKey("options") &&
						ActorKv.JumpToKey(buffer))
					{

						ActorKv.GetString("chat", buffer, sizeof(buffer));
						if(buffer[0])
						{
							StartChat(client, buffer);
							return 0;
						}
					}
				}
			}

			if(ForcedMenu[client])
			{
				ForcedMenu[client] = false;
				SetEntityMoveType(client, MOVETYPE_WALK);
			}

			CurrentChat[client][0] = 0;
		}
	}

	return 0;
}

static Handle TimerZoneEditing[MAXTF2PLAYERS];
static char CurrentSectionEditing[MAXTF2PLAYERS][64];
static char CurrentChatEditing[MAXTF2PLAYERS][64];
static char CurrentKeyEditing[MAXTF2PLAYERS][64];
static char CurrentNPCEditing[MAXTF2PLAYERS][64];
static char CurrentZoneEditing[MAXTF2PLAYERS][64];

void Actor_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH], buffer3[64];

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
	else if(CurrentChatEditing[client][0])
	{
		ActorKv.Rewind();
		ActorKv.JumpToKey(CurrentNPCEditing[client]);
		//bool missing = !ActorKv.JumpToKey(CurrentChatEditing[client]);

		menu.SetTitle("Quests\n%s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client]);

		menu.AddItem("", "WIP AAAAA", ITEMDRAW_DISABLED);
		
		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
	}
	else if(StrEqual(CurrentKeyEditing[client], "model"))
	{
		menu.SetTitle("Quests\n%s\n ", CurrentNPCEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

		menu.AddItem("", "Combine Police");
		menu.AddItem("models/player/scout.mdl", "Scout");
		menu.AddItem("models/player/soldier.mdl", "Soldier");
		menu.AddItem("models/player/pyro.mdl", "Pyro");
		menu.AddItem("models/player/demo.mdl", "Demoman");
		menu.AddItem("models/player/heavy.mdl", "Heavy");

		menu.AddItem("models/player/engineer.mdl", "Engineer");
		menu.AddItem("models/player/medic.mdl", "Medic");
		menu.AddItem("models/player/sniper.mdl", "Sniper");
		menu.AddItem("models/player/spy.mdl", "Spy");
		menu.AddItem("models/alyx.mdl", "Alyx");
		menu.AddItem("models/barney.mdl", "Barney");
		menu.AddItem("models/eli.mdl", "Eli");

		menu.AddItem("models/gman.mdl", "G-Man");
		menu.AddItem("models/monk.mdl", "Father");
		menu.AddItem("models/kleiner.mdl", "Kleiner");
		menu.AddItem("models/vortigaunt.mdl", "Vortigaunt");
		menu.AddItem("models/humans/group01/male_07.mdl", "Male07");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
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

		menu.SetTitle("Actor\n%s\nClick to set it's value:\n ", CurrentNPCEditing[client]);

		if(!missing)
		{
			if(ActorKv.JumpToKey("Chats"))
			{
				if(ActorKv.GotoFirstSubKey())
				{
					do
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));
						AutoGenerateChatSuffixKv(buffer1, buffer3, sizeof(buffer3));
						menu.AddItem(buffer1, buffer3);
					}
					while(ActorKv.GotoNextKey());

					ActorKv.GoBack();
				}

				ActorKv.GoBack();
			}

			menu.AddItem("back", "New Chat (Type in Chat)\n ", ITEMDRAW_DISABLED);
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
		menu.AddItem("_zone", buffer2);

		ActorKv.GetString("model", buffer1, sizeof(buffer1), COMBINE_CUSTOM_MODEL);
		FormatEx(buffer2, sizeof(buffer2), "Model: \"%s\"%s", buffer1, FileExists(buffer1, true) ? "" : " {WARNING: Model does not exist}");
		menu.AddItem("_model", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Scale: %f", ActorKv.GetFloat("scale", 1.0));
		menu.AddItem("_scale", buffer2);

		float vec[3];
		ActorKv.GetVector("pos", vec);
		FormatEx(buffer2, sizeof(buffer2), "Position: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("_pos", buffer2);

		ActorKv.GetVector("ang", vec);
		FormatEx(buffer2, sizeof(buffer2), "Angle: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
		menu.AddItem("_ang", buffer2);

		ActorKv.GetString("anim_idle", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Idle Animation: \"%s\"", buffer1);
		menu.AddItem("_anim_idle", buffer2);

		if(!missing)
		{
			ActorKv.GetString("anim_walk", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Walk Animation: \"%s\"", buffer1);
			menu.AddItem("_anim_walk", buffer2);

			ActorKv.GetString("anim_talk", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Talk Animation: \"%s\"", buffer1);
			menu.AddItem("_anim_talk", buffer2);

			ActorKv.GetString("anim_leave", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Leave Animation: \"%s\"", buffer1);
			menu.AddItem("_anim_leave", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Wander Delay: %f", ActorKv.GetFloat("walk_delay"));
			menu.AddItem("_walk_delay", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Wander Speed: %.1f", ActorKv.GetFloat("walk_speed"));
			menu.AddItem("_walk_speed", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Wander Radius: %.1f", ActorKv.GetFloat("walk_range"));
			menu.AddItem("_walk_range", buffer2);

			ActorKv.GetString("wear1", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1: \"%s\"", buffer1);
			menu.AddItem("_wear1", buffer2);

			ActorKv.GetString("wear2", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2: \"%s\"", buffer1);
			menu.AddItem("_wear2", buffer2);

			ActorKv.GetString("wear3", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3: \"%s\"", buffer1);
			menu.AddItem("_wear3", buffer2);
		}

		menu.AddItem("_delete", "Delete NPC");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPC);
	}
	else if(CurrentZoneEditing[client][0])
	{
		menu.SetTitle("Actor\n%s\nType in chat to create a new NPC\n ", CurrentZoneEditing[client]);

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
		menu.SetTitle("Actor\n \nSelect a zone:\n ");

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

static int AutoGenerateChatSuffixKv(const char[] name, char[] display, int length)
{
	char buffer[32], data[128];
	if(ActorKv.JumpToKey("cond"))
	{
		if(ActorKv.JumpToKey("race"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				bool more;

				do
				{
					ActorKv.GetSectionName(buffer, sizeof(buffer));
					
					if(more)
					{
						strcopy(data, sizeof(data), buffer);
					}
					else
					{
						strcopy(buffer, sizeof(buffer), "Racist");
						more = true;
					}
				}
				while(ActorKv.GotoNextKey());
				
				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(ActorKv.JumpToKey("quest"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				int more;
				
				do
				{
					more++;

					if(more > 1)
						break;

					ActorKv.GetSectionName(buffer, sizeof(buffer));
					switch(ActorKv.GetNum(NULL_STRING))
					{
						case 0:
							Format(data, sizeof(data), "Not Started %s%s%s", buffer, data[0] ? ", " : "", data);
						
						case 1:
							Format(data, sizeof(data), "In Progress %s%s%s", buffer, data[0] ? ", " : "", data);
						
						case 2:
							Format(data, sizeof(data), "Objectives Done %s%s%s", buffer, data[0] ? ", " : "", data);
						
						case 3:
							Format(data, sizeof(data), "Turned In %s%s%s", buffer, data[0] ? ", " : "", data);
					}
				}
				while(ActorKv.GotoNextKey());

				if(more > 1)
					Format(data, sizeof(data), "%s, Other Quests", data);

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(ActorKv.JumpToKey("item"))
		{
			if(ActorKv.GotoFirstSubKey())
			{
				int more;
				
				do
				{
					more++;

					if(more > 1)
						break;

					ActorKv.GetSectionName(buffer, sizeof(buffer));
					int need = ActorKv.GetNum(NULL_STRING);
					
					if(need != 1)
						Format(buffer, sizeof(buffer), "%s x%d", buffer, need);
				}
				while(ActorKv.GotoNextKey());
				
				ActorKv.GoBack();

				if(more > 1)
				{
					Format(data, sizeof(data), "%s%sItems", data, data[0] ? ", " : "");
				}
				else
				{
					Format(data, sizeof(data), "%s%s%s", data, data[0] ? ", " : "", buffer);
				}

			}

			ActorKv.GoBack();
		}

		int value = ActorKv.GetNum("level");
		Format(data, sizeof(data), "%s%sLv %d", data, data[0] ? ", " : "", value);
	}

	if(data[0])
		return Format(display, length, "%s (%s)", name, data);
	
	return strcopy(display, length, name);
}

static Action Timer_RefreshHud(Handle timer, int client)
{
	TimerZoneEditing[client] = null;
	if(Editor_MenuFunc(client) != NPCPicker)
		return Plugin_Stop;
	
	Actor_EditorMenu(client);
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
	Actor_EditorMenu(client);
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
	Actor_EditorMenu(client);
}

static void AdjustNPC(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentNPCEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	if(!ActorKv.JumpToKey(CurrentNPCEditing[client]))
	{
		ActorKv.JumpToKey(CurrentNPCEditing[client], true);
		ActorKv.SetString("zone", CurrentZoneEditing[client]);
	}

	if(StrEqual(key, "_pos"))
	{
		float pos[3];
		GetClientPointVisible(client, _, _, _, pos);
		ActorKv.SetVector("pos", pos);
	}
	else if(StrEqual(key, "_ang"))
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		ActorKv.SetVector("ang", ang);
	}
	else if(StrEqual(key, "_delete"))
	{
		ActorKv.DeleteThis();
		CurrentNPCEditing[client][0] = 0;
	}
	else if(key[0] == '_')
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key[1]);
		Actor_EditorMenu(client);
		return;
	}
	else
	{
		strcopy(CurrentChatEditing[client], sizeof(CurrentChatEditing[]), key);
		Actor_EditorMenu(client);
		return;
	}

	SaveActorKv();
	Actor_ConfigSetup();
	Zones_Rebuild();
	Actor_EditorMenu(client);
}

static void AdjustNPCKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
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

	SaveActorKv();
	Actor_ConfigSetup();
	Zones_Rebuild();
	Actor_EditorMenu(client);
}

static void SaveActorKv()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "actor");
	
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
