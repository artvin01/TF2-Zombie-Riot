#pragma semicolon 1
#pragma newdecls required

static KeyValues ActorKv;
//static bool ForcedMenu[MAXPLAYERS];
//static float DelayTalkFor[MAXPLAYERS];
static char CurrentChat[MAXPLAYERS][128];
static char CurrentNPC[MAXPLAYERS][128];
static int CurrentRef[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
static bool b_NpcHasQuestForPlayer[MAXENTITIES][MAXPLAYERS];
//static int b_ParticleToOwner[MAXENTITIES];
//static int b_OwnerToParticle[MAXENTITIES];

void Actor_ConfigSetup()
{
	delete ActorKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "actor");
	ActorKv = new KeyValues("Actor");
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
						SoundExists(buffer);
				}
				while(ActorKv.GotoNextKey());

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}
	}
	while(ActorKv.GotoNextKey());
}

KeyValues Actor_KV()
{
	return ActorKv;
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
				
				entity = NPC_CreateByName("npc_actor", client, pos, ang, TFTeam_Red);
				if(entity != -1)
				{
					ActorKv.SetNum("_entref", EntIndexToEntRef(entity));

				/*	pos[2] += 110.0;

					int particle = ParticleEffectAt(pos, "powerup_icon_regen", 0.0);
					
					SetEntPropVector(particle, Prop_Data, "m_angRotation", ang);
					
					DataPack pack;
					CreateDataTimer(0.3, TeleportTextTimer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					pack.WriteCell(EntIndexToEntRef(particle));
					pack.WriteCell(EntIndexToEntRef(entity));
					pack.WriteFloat(0.0);
					pack.WriteFloat(0.0);
					pack.WriteFloat(110.0);

					SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
					SDKHook(particle, SDKHook_SetTransmit, QuestIndicatorTransmit);
					b_ParticleToOwner[particle] = EntIndexToEntRef(entity);
					b_OwnerToParticle[entity] = EntIndexToEntRef(particle);
					b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
					//as of now, this code is useless as it doesnt check for quests, just if you can talk.
				*/
				}
			}
			else
			{
				b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
			}
		}
	}
	while(ActorKv.GotoNextKey());
}

/*
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
*/

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
				/*
				int particle = EntRefToEntIndex(b_OwnerToParticle[entity]);
				if(IsValidEntity(particle))
				{
					RemoveEntity(particle);
				}
				*/
				int brush = EntRefToEntIndex(b_OwnerToBrush[entity]);
				if(IsValidEntity(brush))
				{
					RemoveEntity(brush);
				}
				NPC_Despawn(entity);
			}
			
			ActorKv.SetNum("_entref", INVALID_ENT_REFERENCE);
		}
	}
	while(ActorKv.GotoNextKey());
}

/* Must be first interactable */
bool Actor_Interact(int client, int entity)
{
	if(Dungeon_IsDungeon(client))
		return false;
	
	if(CurrentChat[client][0])
		return true;
	
	ActorKv.Rewind();
	ActorKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(ActorKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			if(Editor_MenuFunc(client) != INVALID_FUNCTION)
			{
				OpenEditorFrom(client);
				return true;
			}

			ActorKv.GetSectionName(CurrentNPC[client], sizeof(CurrentNPC[]));
			CurrentRef[client] = EntIndexToEntRef(entity);
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
			if(ActorKv.GotoFirstSubKey(false))
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
				while(ActorKv.GotoNextKey(false));
				
				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!failed && ActorKv.JumpToKey("quest"))
		{
			if(ActorKv.GotoFirstSubKey(false))
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
				while(ActorKv.GotoNextKey(false));

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(!failed && ActorKv.JumpToKey("item"))
		{
			if(ActorKv.GotoFirstSubKey(false))
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
								Format(fail, length, "%s x%d", buffer, need);
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
				while(ActorKv.GotoNextKey(false));
				
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

static bool StartChat(int client, const char[] override = "")
{
	if(override[0])
	{
		CurrentChat[client][0] = 0;
	}
	else if(CurrentChat[client][0])
	{
		// Should never call anyways
		Actor_ReopenMenu(client);
		return true;
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
						return true;
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

	//if(ForcedMenu[client])
	{
		//ForcedMenu[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
	}

	return false;
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

static bool SoundExists(const char[] sound)
{
	if(sound[0])
	{
		if(StrContains(sound, ".mp3") == -1 && StrContains(sound, ".wav") == -1)
		{
			return PrecacheScriptSound(sound);
		}
		else
		{
			return PrecacheSound(sound);
		}
	}

	return false;
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
				EmitGameSoundToClient(client, buffer1, entity);
			}
			else
			{
				EmitSoundToClient(client, buffer1, entity);
			}
		}
	}

	if(!noActions && ActorKv.JumpToKey("actions"))
	{
		if(ActorKv.GetNum("deposit"))
		{
			TF2_RegeneratePlayer(client);
		}
		
		if(ActorKv.JumpToKey("setquest"))
		{
			if(ActorKv.GotoFirstSubKey(false))
			{
				do
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					switch(ActorKv.GetNum(NULL_STRING))
					{
						case 0:
							Quests_CancelQuest(client, buffer1);
						
						case 1:
							Quests_StartQuest(client, buffer1);
						
						case 2:
							Quests_TurnIn(client, buffer1);
					}
				}
				while(ActorKv.GotoNextKey(false));

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
			
			if(entity != -1)
				b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
		}
		
		if(ActorKv.JumpToKey("giveitem"))
		{
			if(ActorKv.GotoFirstSubKey(false))
			{
				do
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					TextStore_AddItemCount(client, buffer1, ActorKv.GetNum(NULL_STRING));
				}
				while(ActorKv.GotoNextKey(false));

				ActorKv.GoBack();
			}

			ActorKv.GoBack();
		}

		if(ActorKv.GetNum("resetspawn"))
		{
			f3_PositionArrival[client][0] = 0.0;
			Stats_SaveClientStats(client);
		}

		float pos[3];
		ActorKv.GetVector("teleport", pos);
		if(pos[0])
		{
			float ang[3];
			ActorKv.GetVector("angles", ang);
			RPGCore_CancelMovementAbilities(client);
			TeleportEntity(client, pos, ang, NULL_VECTOR);

			if(ActorKv.GetNum("setspawn"))
			{
				f3_PositionArrival[client] = pos;
				Stats_SaveClientStats(client);
			}
		}
		else if(ActorKv.GetNum("setspawn"))
		{
			GetClientAbsOrigin(client, f3_PositionArrival[client]);
			Stats_SaveClientStats(client);
		}

		if(ActorKv.GetNum("reskillpoints"))
			Stats_ReskillEverything(client);

		ActorKv.GoBack();
	}

	if(ActorKv.GetNum("simple"))
	{
		if(entity != -1 && !noActions)
		{
			NPCActor_TalkStart(entity, client, 5.0);

			ActorKv.GetString("text", buffer1, sizeof(buffer1));
			FormatText(client, buffer1, sizeof(buffer1));
			NpcSpeechBubble(entity, buffer1, 5, {255, 255, 255, 255}, {0.0, 0.0, 90.0}, "");
		}
	}
	else
	{
		if(entity != -1 && !noActions)
			NPCActor_TalkStart(entity, client);

		ActorKv.GetString("text", buffer1, sizeof(buffer1));
		FormatText(client, buffer1, sizeof(buffer1));

		Menu menu = new Menu(MenuHandle);
		menu.SetTitle("%s\n \n%s\n ", CurrentNPC[client], buffer1);

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
		//	DelayTalkFor[client] = GetGameTime() + 1.5;
			
			/*ForcedMenu[client] = true;
			SetEntityMoveType(client, MOVETYPE_NONE);
			RPGCore_CancelMovementAbilities(client);
			TeleportEntity(client, _, _, {0.0, 0.0, 0.0});
			ActorKv.GetSectionName(CurrentChat[client], sizeof(CurrentChat[]));*/
			
		}
		else
		{
		// DelayTalkFor[client] = 0.0;
			menu.AddItem(NULL_STRING, "...");
			
			/*if(ForcedMenu[client])
			{
				ForcedMenu[client] = false;
				SetEntityMoveType(client, MOVETYPE_WALK);
			}
			*/
		}

		//ForcedMenu[client] = true;
		RPGCore_CancelMovementAbilities(client);
		SetEntityMoveType(client, MOVETYPE_NONE);
		TeleportEntity(client, _, _, {0.0, 0.0, 0.0});
		ActorKv.GetSectionName(CurrentChat[client], sizeof(CurrentChat[]));
		
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static void FormatText(int client, char[] text, int length)
{
	static char buffer[64];

	GetClientName(client, buffer, sizeof(buffer));
	ReplaceString(text, length, "{playername}", buffer);

	static Race race;
	Races_GetClientInfo(client, race);
	ReplaceString(text, length, "{playerrace}", race.Name);

	ReplaceString(text, length, "\\n", "\n");
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
				//ForcedMenu[client] = false;
				CurrentNPC[client][0] = 0;
				CurrentChat[client][0] = 0;
			}

			if(!CurrentNPC[client][0]/* || !ForcedMenu[client]*/)
			{
				CurrentNPC[client][0] = 0;

				int entity = EntRefToEntIndex(CurrentRef[client]);
				if(entity != -1)
					NPCActor_TalkEnd(entity);
				
				CurrentRef[client] = -1;
			}
		}
		case MenuAction_Select:
		{
			/*
			if(DelayTalkFor[client] > GetGameTime())
			{
				float time = DelayTalkFor[client];
				Actor_ReopenMenu(client);
				DelayTalkFor[client] = time;
				return 0;
			}
			*/
			
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
							if(StartChat(client, buffer))
								return 0;
						}
					}
				}
			}

			//if(ForcedMenu[client])
			{
				//ForcedMenu[client] = false;
				SetEntityMoveType(client, MOVETYPE_WALK);
			}

			CurrentChat[client][0] = 0;
			CurrentNPC[client][0] = 0;

			int entity = EntRefToEntIndex(CurrentRef[client]);
			if(entity != -1)
				NPCActor_TalkEnd(entity);
			
			CurrentRef[client] = -1;
		}
	}

	return 0;
}

static Handle TimerZoneEditing[MAXPLAYERS];
static char CurrentTrueBottomEditing[MAXPLAYERS][64];
static char CurrentSubKeyEditing[MAXPLAYERS][64];
static char CurrentSubSectionEditing[MAXPLAYERS][64];
static char CurrentSectionEditing[MAXPLAYERS][64];
static char CurrentChatEditing[MAXPLAYERS][64];
static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentNPCEditing[MAXPLAYERS][64];
static char CurrentZoneEditing[MAXPLAYERS][64];

static void OpenEditorFrom(int client)
{
	ActorKv.GetString("zone", CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]));
	ActorKv.GetSectionName(CurrentNPCEditing[client], sizeof(CurrentNPCEditing[]));
	CurrentKeyEditing[client][0] = 0;
	CurrentChatEditing[client][0] = 0;
	CurrentSectionEditing[client][0] = 0;
	CurrentSubSectionEditing[client][0] = 0;
	CurrentSubKeyEditing[client][0] = 0;
	CurrentTrueBottomEditing[client][0] = 0;
	Actor_EditorMenu(client);
}

void Actor_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH], buffer3[64];

	EditMenu menu = new EditMenu();

	// NPC - Chat - cond
	if(StrEqual(CurrentSectionEditing[client], "cond"))
	{
		ActorKv.Rewind();
		ActorKv.JumpToKey(CurrentNPCEditing[client]);
		ActorKv.JumpToKey("Chats");
		ActorKv.JumpToKey(CurrentChatEditing[client]);
		
		CondMenu(client, menu, CurrentSubSectionEditing[client], CurrentKeyEditing[client]);
		
		if(CurrentKeyEditing[client][0])
		{
			menu.Display(client, AdjustCondSectionKey);
		}
		else if(CurrentSubSectionEditing[client][0])
		{
			menu.Display(client, AdjustCondSection);
		}
		else
		{
			menu.Display(client, AdjustCond);
		}
	}
	else if(StrEqual(CurrentSectionEditing[client], "options"))
	{
		// NPC - Chat - options - subsec - cond
		if(StrEqual(CurrentKeyEditing[client], "cond"))
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.JumpToKey(CurrentChatEditing[client]);
			ActorKv.JumpToKey(CurrentSectionEditing[client], true);		// options
			ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);	// Reply
			
			CondMenu(client, menu, CurrentSubKeyEditing[client], CurrentTrueBottomEditing[client]);
			
			if(CurrentTrueBottomEditing[client][0])
			{
				menu.Display(client, AdjustOptionsSectionCondSectionKey);
			}
			else if(CurrentSubKeyEditing[client][0])
			{
				menu.Display(client, AdjustOptionsSectionCondSection);
			}
			else
			{
				menu.Display(client, AdjustOptionsSectionCond);
			}
		}
		// NPC - Chat - options - subsec - chat
		else if(StrEqual(CurrentKeyEditing[client], "chat"))
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.GotoFirstSubKey();
			
			menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);
			
			menu.AddItem("", "End Chat");

			do
			{
				ActorKv.GetSectionName(buffer1, sizeof(buffer1));
				menu.AddItem(buffer1, buffer1);
			}
			while(ActorKv.GotoNextKey());

			menu.ExitBackButton = true;
			menu.Display(client, AdjustOptionsSectionKey);
		}
		// NPC - Chat - options - subsec
		else if(CurrentSubSectionEditing[client][0])
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.JumpToKey(CurrentChatEditing[client]);
			ActorKv.JumpToKey(CurrentSectionEditing[client]);
			ActorKv.JumpToKey(CurrentSubSectionEditing[client]);

			menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);

			ActorKv.GetString("chat", buffer1, sizeof(buffer1), "End Chat");
			FormatEx(buffer2, sizeof(buffer2), "Set NPC Chat To: \"%s\"", buffer1);
			menu.AddItem("chat", buffer2);

			AutoGenerateChatSuffixKv("Conditions", buffer2, sizeof(buffer2));
			menu.AddItem("cond", buffer2);

			menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
			menu.Display(client, AdjustOptionsSection);

		}
		// NPC - Chat - options
		else
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.JumpToKey(CurrentChatEditing[client]);
			bool missing = !ActorKv.JumpToKey(CurrentSectionEditing[client]);

			menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

			menu.AddItem("new", "New Option (Type in Chat)", ITEMDRAW_DISABLED);

			if(!missing)
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

			menu.ExitBackButton = true;
			menu.Display(client, AdjustOptions);
		}
	}
	else if(StrEqual(CurrentSectionEditing[client], "actions"))
	{
		if(StrEqual(CurrentSubSectionEditing[client], "setquest"))
		{
			// NPC - Chat - actions - setquest - key
			if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);

				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("1", buffer1, ITEMDRAW_DISABLED);

				menu.AddItem("0", "Cancel Quest");
				menu.AddItem("1", "Start Quest");
				menu.AddItem("2", "Finish Quest");

				menu.ExitBackButton = true;
				menu.Display(client, AdjustActionsSectionKey);
			}
			// NPC - Chat - actions - setquest - key
			else
			{
				menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

				FormatEx(buffer1, sizeof(buffer1), "Type to add an entry for \"%s\"", CurrentSubSectionEditing[client]);
				menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

				KeyValues kv = Quests_KV();
				kv.GotoFirstSubKey();

				bool first;
				do
				{
					kv.GetSectionName(buffer1, sizeof(buffer1));
					if(first)
					{
						menu.InsertItem(0, buffer1, buffer1);
					}
					else
					{
						first = true;
						menu.AddItem(buffer1, buffer1);
					}
				}
				while(kv.GotoNextKey());

				menu.ExitBackButton = true;
				menu.Display(client, AdjustActionsSection);
			}
		}
		else if(CurrentSubSectionEditing[client][0])
		{
			// NPC - Chat - actions - subsec - key
			if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);

				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("1", buffer1, ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustActionsSectionKey);
			}
			// NPC - Chat - actions - subsec
			else
			{
				menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

				FormatEx(buffer1, sizeof(buffer1), "Type to add an entry for \"%s\"", CurrentSubSectionEditing[client]);
				menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustActionsSection);
			}
		}
		// NPC - Chat - actions
		else
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.JumpToKey(CurrentChatEditing[client]);
			bool missing = !ActorKv.JumpToKey(CurrentSectionEditing[client]);

			menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

			menu.AddItem("setquest", "Add Quest Change");
			menu.AddItem("giveitem", "Add Item Change");

			if(ActorKv.GetNum("deposit"))
			{
				menu.AddItem("_deposit", "Deposit Items");
			}
			else
			{
				menu.AddItem("_deposit", "Add \"Deposit Items\"");
			}

			if(ActorKv.GetNum("setspawn"))
			{
				menu.AddItem("_setspawn", "Set Spawn Point");
			}
			else
			{
				menu.InsertItem(2, "_setspawn", "Add \"Set Spawn Point\"");
			}

			if(ActorKv.GetNum("resetspawn"))
			{
				menu.AddItem("_resetspawn", "Reset Spawn Point");
			}
			else
			{
				menu.InsertItem(2, "_resetspawn", "Add \"Reset Spawn Point\"");
			}

			float pos[3];
			ActorKv.GetVector("teleport", pos);
			if(pos[0])
			{
				Format(buffer2, sizeof(buffer2), "Teleport: %.0f %.0f %.0f", pos[0], pos[1], pos[2]);
				menu.AddItem("teleport", buffer2);
			}
			else
			{
				menu.InsertItem(2, "teleport", "Add \"Teleport\"");
			}

			if(ActorKv.GetNum("reskillpoints"))
			{
				menu.AddItem("_reskillpoints", "Reskill Points");
			}
			else
			{
				menu.InsertItem(2, "_reskillpoints", "Add \"Reskill Points\"");
			}

			if(!missing)
			{
				if(ActorKv.JumpToKey("setquest"))
				{
					if(ActorKv.GotoFirstSubKey(false))
					{
						do
						{
							ActorKv.GetSectionName(buffer1, sizeof(buffer1));
							switch(ActorKv.GetNum(NULL_STRING))
							{
								case 0:
									Format(buffer2, sizeof(buffer2), "Cancel Quest \"%s\"", buffer1);
								
								case 1:
									Format(buffer2, sizeof(buffer2), "Start Quest \"%s\"", buffer1);
								
								case 2:
									Format(buffer2, sizeof(buffer2), "Finish Quest \"%s\"", buffer1);
								
								default:
									Format(buffer2, sizeof(buffer2), "INVALID \"%s\"", buffer1);
							}

							Format(buffer1, sizeof(buffer1), "setquest;%s", buffer1);
							menu.AddItem(buffer1, buffer2);
						}
						while(ActorKv.GotoNextKey(false));

						ActorKv.GoBack();
					}

					ActorKv.GoBack();
				}

				if(ActorKv.JumpToKey("giveitem"))
				{
					if(ActorKv.GotoFirstSubKey(false))
					{
						do
						{
							ActorKv.GetSectionName(buffer1, sizeof(buffer1));
							Format(buffer2, sizeof(buffer2), "Give %d \"%s\"%s", ActorKv.GetNum(NULL_STRING), buffer1, TextStore_IsValidName(buffer1) ? "" : " {WARNING: Item does not exist}");
							Format(buffer1, sizeof(buffer1), "giveitem;%s", buffer1);
							menu.AddItem(buffer1, buffer2);
						}
						while(ActorKv.GotoNextKey(false));

						ActorKv.GoBack();
					}

					ActorKv.GoBack();
				}
			}

			menu.ExitBackButton = true;
			menu.Display(client, AdjustActions);
		}
	}
	else if(CurrentChatEditing[client][0])
	{
		// NPC - Chat - altchat
		if(StrEqual(CurrentKeyEditing[client], "altchat"))
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.GotoFirstSubKey();
			
			menu.SetTitle("Actors\n%s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client]);
			
			menu.AddItem("", "Check Next");
			menu.AddItem(";", "No Chat");

			do
			{
				ActorKv.GetSectionName(buffer1, sizeof(buffer1));
				menu.AddItem(buffer1, buffer1);
			}
			while(ActorKv.GotoNextKey());

			menu.ExitBackButton = true;
			menu.Display(client, AdjustChatKey);
		}
		// NPC - Chat - altchat
		else if(StrEqual(CurrentKeyEditing[client], "text"))
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			ActorKv.JumpToKey("Chats");
			ActorKv.JumpToKey(CurrentChatEditing[client]);

			ActorKv.GetString("text", buffer1, sizeof(buffer1));
			PrintToConsole(client, buffer1);
			ReplaceString(buffer1, sizeof(buffer1), "\\n", "\n");
			menu.SetTitle("%s\n ", buffer1);
			
			FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
			menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
			menu.Display(client, AdjustChatKey);
		}
		else if(CurrentKeyEditing[client][0])
		{
			menu.SetTitle("Actors\n%s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client]);
			
			FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
			menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

			menu.AddItem("", "Set To Default");

			menu.ExitBackButton = true;
			menu.Display(client, AdjustChatKey);
		}
		// NPC - Chat
		else
		{
			ActorKv.Rewind();
			ActorKv.JumpToKey(CurrentNPCEditing[client]);
			bool missing = !ActorKv.JumpToKey("Chats");
			if(!missing)
				missing = !ActorKv.JumpToKey(CurrentChatEditing[client]);

			menu.SetTitle("Actors\n%s - %s\nClick to set it's value:\n ", CurrentNPCEditing[client], CurrentChatEditing[client]);

			FormatEx(buffer2, sizeof(buffer2), "Edit Dialogue");
			menu.AddItem("text", buffer2);

			ActorKv.GetString("sound", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Sound: \"%s\"%s", buffer1, (!buffer1[0] || SoundExists(buffer1)) ? "" : " {WARNING: Sound does not exist}");
			menu.AddItem("sound", buffer2);

			bool simple = view_as<bool>(ActorKv.GetNum("simple"));
			FormatEx(buffer2, sizeof(buffer2), "Style: %s", simple ? "Worldtext" : "Menu");
			menu.AddItem("simple", buffer2);

			if(!missing)
			{
				ActorKv.GetString("altchat", buffer1, sizeof(buffer1));
				if(buffer1[0] == ';')
				{
					FormatEx(buffer2, sizeof(buffer2), "On Cond Fail: No Chat");
				}
				else if(buffer1[0])
				{
					FormatEx(buffer2, sizeof(buffer2), "On Cond Fail: \"%s\"", buffer1);
				}
				else if(ActorKv.GotoNextKey())
				{
					ActorKv.GetSectionName(buffer1, sizeof(buffer1));
					FormatEx(buffer2, sizeof(buffer2), "On Cond Fail: Check Next (\"%s\")", buffer1);
					ActorKv.GoBack();
					ActorKv.JumpToKey(CurrentChatEditing[client]);
				}
				else
				{
					FormatEx(buffer2, sizeof(buffer2), "On Cond Fail: Check Next (No Chat)");
				}
				
				menu.AddItem("altchat", buffer2);

				int count;
				if(ActorKv.JumpToKey("options"))
				{
					if(ActorKv.GotoFirstSubKey())
					{
						do
						{
							count++;
						}
						while(ActorKv.GotoNextKey());

						ActorKv.GoBack();
					}

					ActorKv.GoBack();
				}

				FormatEx(buffer2, sizeof(buffer2), "Chat Options (%d Options)", count);
				menu.AddItem("_options", buffer2, simple ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

				count = 0;
				if(ActorKv.JumpToKey("actions"))
				{
					if(ActorKv.GotoFirstSubKey())
					{
						do
						{
							if(ActorKv.GotoFirstSubKey(false))
							{
								do
								{
									count++;
								}
								while(ActorKv.GotoNextKey(false));

								ActorKv.GoBack();
							}
						}
						while(ActorKv.GotoNextKey());

						ActorKv.GoBack();
					}

					ActorKv.GoBack();
				}

				FormatEx(buffer2, sizeof(buffer2), "Chat Actions (%d Actions)", count);
				menu.AddItem("_actions", buffer2);

				AutoGenerateChatSuffixKv("Conditions", buffer3, sizeof(buffer3));
				menu.AddItem("_cond", buffer3);
			}
			
			menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);
			
			menu.ExitBackButton = true;
			menu.Display(client, AdjustChat);
		}
	}
	// NPC - model
	else if(StrEqual(CurrentKeyEditing[client], "model"))
	{
		menu.SetTitle("Actors\n%s\n ", CurrentNPCEditing[client]);
		
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
	// NPC - zone
	else if(StrEqual(CurrentKeyEditing[client], "zone"))
	{
		menu.SetTitle("Actors\n%s\n ", CurrentNPCEditing[client]);
		
		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
	}
	// NPC - key
	else if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Actors\n%s\n ", CurrentNPCEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

		menu.AddItem("", "Set To Default");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPCKey);
	}
	// NPC
	else if(CurrentNPCEditing[client][0])
	{
		ActorKv.Rewind();
		bool missing = !ActorKv.JumpToKey(CurrentNPCEditing[client]);

		menu.SetTitle("Actors\n%s\nClick to set it's value:\n ", CurrentNPCEditing[client]);

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
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1: \"%s\"%s", buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
			menu.AddItem("_wear1", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1 Scale: %f", ActorKv.GetFloat("wear1_size", 1.0));
			menu.AddItem("_wear1_size", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1 Skin: %i", ActorKv.GetNum("wear1_skin", 0));
			menu.AddItem("_wear1_skin", buffer2);

			ActorKv.GetString("wear2", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2: \"%s\"%s", buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
			menu.AddItem("_wear2", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2 Scale: %f", ActorKv.GetFloat("wear2_size", 1.0));
			menu.AddItem("_wear2_size", buffer2);
			
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2 Skin: %i", ActorKv.GetNum("wear2_skin", 0));
			menu.AddItem("_wear2_skin", buffer2);

			ActorKv.GetString("wear3", buffer1, sizeof(buffer1));
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3: \"%s\"%s", buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
			menu.AddItem("_wear3", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3 Scale: %f", ActorKv.GetFloat("wear3_size", 1.0));
			menu.AddItem("_wear3_size", buffer2);
			
			FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3 Skin: %i", ActorKv.GetNum("wear3_skin", 0));
			menu.AddItem("_wear3_skin", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Bodygroup: %d", ActorKv.GetNum("bodygroup"));
			menu.AddItem("_bodygroup", buffer2);

			FormatEx(buffer2, sizeof(buffer2), "Skin: %d", ActorKv.GetNum("skin"));
			menu.AddItem("_skin", buffer2);
		}

		menu.AddItem("_delete", "Delete (Type \"_delete\")", ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustNPC);
	}
	// 
	else if(CurrentZoneEditing[client][0])
	{
		menu.SetTitle("Actors\n%s\n ", CurrentZoneEditing[client]);

		menu.AddItem("new", "Type in chat to create a new NPC", ITEMDRAW_DISABLED);

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
		menu.SetTitle("Actors\n \nSelect a zone:\n ");

		menu.AddItem(" ", "All Zones\n ");
		
		bool first = true;
		Zones_GenerateZoneList(client, menu, first);

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
		if(value)
			Format(data, sizeof(data), "%s%sLv %d", data, data[0] ? ", " : "", value);

		ActorKv.GoBack();
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
		Actor_EditorMenu(client);
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
		ang[0] = 0.0;
		ang[1] = (RoundFloat(ang[1]) / 15) * 15.0;
		ang[2] = 0.0;
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
	Actor_EditorMenu(client);
}

static void AdjustChat(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentChatEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);

	if(StrEqual(key, "simple"))
	{
		ActorKv.SetNum("simple", ActorKv.GetNum("simple") ? 0 : 1);
	}
	else if(StrEqual(key, "delete"))
	{
		ActorKv.DeleteThis();
		CurrentChatEditing[client][0] = 0;
	}
	else if(key[0] == '_')
	{
		strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), key[1]);
		Actor_EditorMenu(client);
		return;
	}
	else
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Actor_EditorMenu(client);
		return;
	}

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustChatKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);

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
	Actor_EditorMenu(client);
}

static void AdjustActions(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);

	if(key[0] == '_')
	{
		ActorKv.SetNum(key[1], ActorKv.GetNum(key[1]) ? 0 : 1);
	}
	else if(StrEqual(key, "teleport"))
	{
		float pos[3];
		ActorKv.GetVector("teleport", pos);
		if(pos[0])
		{
			ActorKv.SetVector("teleport", NULL_VECTOR);
		}
		else
		{
			GetClientAbsOrigin(client, pos);
			ActorKv.SetVector("teleport", pos);

			GetClientAbsAngles(client, pos);
			pos[0] = 0.0;
			pos[1] = (RoundFloat(pos[1]) / 45) * 45.0;
			pos[2] = 0.0;
			ActorKv.SetVector("angles", pos);
		}
	}
	else if(StrEqual(key, "delete"))
	{
		ActorKv.DeleteThis();
		CurrentSectionEditing[client][0] = 0;
	}
	else if(StrContains(key, ";") != -1)
	{
		char buffers[2][64];
		ExplodeString(key, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		if(ActorKv.JumpToKey(buffers[0]))
			ActorKv.DeleteKey(buffers[1]);
	}
	else
	{
		strcopy(CurrentSubSectionEditing[client], sizeof(CurrentSubSectionEditing[]), key);
		ActorKv.JumpToKey(key, true);
	}

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustActionsSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSubSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
	Actor_EditorMenu(client);
}

static void AdjustActionsSectionKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);

	if(key[0])
	{
		ActorKv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		ActorKv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;
	CurrentSubSectionEditing[client][0] = 0;

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustOptions(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	strcopy(CurrentSubSectionEditing[client], sizeof(CurrentSubSectionEditing[]), key);

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);

	ActorKv.SetString("_temp", "1");
	/*
	PrintToChatAll("AdjustOptions::%s:%s:%s:%s", CurrentNPCEditing[client],
	CurrentChatEditing[client],
	CurrentSectionEditing[client],
	CurrentSubSectionEditing[client]);
	*/
	
	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustOptionsSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSubSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);

	if(StrEqual(key, "delete"))
	{
		ActorKv.DeleteThis();
		CurrentSubSectionEditing[client][0] = 0;
	}
	else
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Actor_EditorMenu(client);
		return;
	}

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustOptionsSectionKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);

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
	Actor_EditorMenu(client);
}

static void AdjustOptionsSectionCond(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);		// options
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);	// Reply
	ActorKv.JumpToKey(CurrentKeyEditing[client], true);		// cond

	AdjustCondShared(client, CurrentKeyEditing[client], CurrentSubKeyEditing[client], CurrentTrueBottomEditing[client], key);
}

static void AdjustOptionsSectionCondSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSubKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	strcopy(CurrentTrueBottomEditing[client], sizeof(CurrentTrueBottomEditing[]), key);
	Actor_EditorMenu(client);
}

static void AdjustOptionsSectionCondSectionKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentTrueBottomEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);		// options
	ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);	// Reply
	ActorKv.JumpToKey(CurrentKeyEditing[client], true);		// cond
	if(!StrEqual(CurrentSubKeyEditing[client], "_"))
		ActorKv.JumpToKey(CurrentSubKeyEditing[client], true);

	if(key[0])
	{
		ActorKv.SetString(CurrentTrueBottomEditing[client], key);
	}
	else
	{
		ActorKv.DeleteKey(CurrentTrueBottomEditing[client]);
	}

	CurrentTrueBottomEditing[client][0] = 0;
	CurrentSubKeyEditing[client][0] = 0;

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void CondMenu(int client, EditMenu menu, const char[] subsection, const char[] key)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];
	
	if(StrEqual(subsection, "quest"))
	{
		// cond - quest - key
		if(key[0])
		{
			menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);

			FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", key);
			menu.AddItem("0", buffer1, ITEMDRAW_DISABLED);

			menu.AddItem("0", "Not Started Quest");
			menu.AddItem("1", "In Progress Quest");
			menu.AddItem("2", "Objectives Done Quest");
			menu.AddItem("3", "Turned In Quest");

			menu.ExitBackButton = true;
		}
		// cond - quest - key
		else
		{
			menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

			FormatEx(buffer1, sizeof(buffer1), "Type to add an entry for \"%s\"", subsection);
			menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

			KeyValues kv = Quests_KV();
			kv.GotoFirstSubKey();

			bool first;
			do
			{
				kv.GetSectionName(buffer1, sizeof(buffer1));
				if(first)
				{
					menu.InsertItem(0, buffer1, buffer1);
				}
				else
				{
					first = true;
					menu.AddItem(buffer1, buffer1);
				}
			}
			while(kv.GotoNextKey());

			menu.ExitBackButton = true;
		}
	}
	else if(subsection[0])
	{
		// cond - subsec - key
		if(key[0])
		{
			menu.SetTitle("Actors\n%s - %s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client], CurrentSubSectionEditing[client]);

			FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", key);
			menu.AddItem("0", buffer1, ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
		}
		// cond - subsec
		else
		{
			menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

			FormatEx(buffer1, sizeof(buffer1), "Type to add an entry for \"%s\"", subsection);
			menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

			menu.ExitBackButton = true;
		}
	}
	// cond
	else
	{
		bool missing = !ActorKv.JumpToKey("cond");

		menu.SetTitle("Actors\n%s - %s - %s\n ", CurrentNPCEditing[client], CurrentChatEditing[client], CurrentSectionEditing[client]);

		menu.AddItem("quest", "Add Quest Check");
		menu.AddItem("item", "Add Item Check");
		menu.AddItem("race", "Add Race Check");

		int level = ActorKv.GetNum("level");
		if(level > 0)
		{
			Format(buffer2, sizeof(buffer2), "Must Be Level %d", level);
			menu.AddItem("level", buffer2);
		}
		else
		{
			menu.AddItem("level", "Add Level Check");
		}

		if(!missing)
		{
			if(ActorKv.JumpToKey("quest"))
			{
				if(ActorKv.GotoFirstSubKey(false))
				{
					do
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));
						switch(ActorKv.GetNum(NULL_STRING))
						{
							case 0:
								Format(buffer2, sizeof(buffer2), "Not Started \"%s\"", buffer1);
							
							case 1:
								Format(buffer2, sizeof(buffer2), "In Progress \"%s\"", buffer1);
							
							case 2:
								Format(buffer2, sizeof(buffer2), "Objectives Done \"%s\"", buffer1);
							
							case 3:
								Format(buffer2, sizeof(buffer2), "Turned In \"%s\"", buffer1);
							
							default:
								Format(buffer2, sizeof(buffer2), "INVALID \"%s\"", buffer1);
						}

						Format(buffer1, sizeof(buffer1), "quest;%s", buffer1);
						menu.AddItem(buffer1, buffer2);
					}
					while(ActorKv.GotoNextKey(false));

					ActorKv.GoBack();
				}

				ActorKv.GoBack();
			}

			if(ActorKv.JumpToKey("item"))
			{
				if(ActorKv.GotoFirstSubKey(false))
				{
					do
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));

						int amount = ActorKv.GetNum(NULL_STRING);
						if(amount > 0)
						{
							Format(buffer2, sizeof(buffer2), "Need %d \"%s\"", amount, buffer1);
						}
						else if(amount < 0)
						{
							Format(buffer2, sizeof(buffer2), "Need Less Than %d \"%s\"", -amount, buffer1);
						}
						else
						{
							Format(buffer2, sizeof(buffer2), "Don't Have \"%s\"", buffer1);
						}

						Format(buffer1, sizeof(buffer1), "item;%s", buffer1);
						menu.AddItem(buffer1, buffer2);
					}
					while(ActorKv.GotoNextKey(false));

					ActorKv.GoBack();
				}

				ActorKv.GoBack();
			}

			if(ActorKv.JumpToKey("race"))
			{
				if(ActorKv.GotoFirstSubKey(false))
				{
					do
					{
						ActorKv.GetSectionName(buffer1, sizeof(buffer1));
						
						if(ActorKv.GetNum(NULL_STRING))
						{
							Format(buffer2, sizeof(buffer2), "Must Be \"%s\"", buffer1);
						}
						else
						{
							Format(buffer2, sizeof(buffer2), "Don't Be \"%s\"", buffer1);
						}

						Format(buffer1, sizeof(buffer1), "race;%s", buffer1);
						menu.AddItem(buffer1, buffer2);
					}
					while(ActorKv.GotoNextKey(false));
					
					ActorKv.GoBack();
				}

				ActorKv.GoBack();
			}
		}
	}

	menu.ExitBackButton = true;
}

static void AdjustCondShared(int client, char section[64], char subsection[64], char key[64], const char[] input)
{
	if(StrEqual(input, "delete"))
	{
		ActorKv.DeleteThis();
		section[0] = 0;
	}
	else if(StrContains(input, ";") != -1)
	{
		char buffers[2][64];
		ExplodeString(input, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		ActorKv.JumpToKey(buffers[0]);
		ActorKv.DeleteKey(buffers[1]);
	}
	else if(StrEqual(input, "level"))
	{
		// Anything that isn't in it's own tree
		strcopy(subsection, sizeof(subsection), "_");
		strcopy(key, sizeof(key), input);
		Actor_EditorMenu(client);
		return;
	}
	else
	{
		strcopy(subsection, sizeof(subsection), input);
		Actor_EditorMenu(client);
		return;
	}

	SaveActorKv();
	Actor_EditorMenu(client);
}

static void AdjustCond(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);

	AdjustCondShared(client, CurrentSectionEditing[client], CurrentSubSectionEditing[client], CurrentKeyEditing[client], key);
}

static void AdjustCondSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSubSectionEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
	Actor_EditorMenu(client);
}

static void AdjustCondSectionKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Actor_EditorMenu(client);
		return;
	}

	ActorKv.Rewind();
	ActorKv.JumpToKey(CurrentNPCEditing[client], true);
	ActorKv.JumpToKey("Chats", true);
	ActorKv.JumpToKey(CurrentChatEditing[client], true);
	ActorKv.JumpToKey(CurrentSectionEditing[client], true);
	if(!StrEqual(CurrentSubSectionEditing[client], "_"))
		ActorKv.JumpToKey(CurrentSubSectionEditing[client], true);

	if(key[0])
	{
		ActorKv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		ActorKv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;
	CurrentSubSectionEditing[client][0] = 0;

	SaveActorKv();
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
	
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == NPCActor_ID())
			NPC_Despawn(i);
	}

	Actor_ConfigSetup();
	Zones_Rebuild();
}
