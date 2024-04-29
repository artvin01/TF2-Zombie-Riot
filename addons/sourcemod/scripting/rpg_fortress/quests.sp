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
static char CurrentNPC[MAXTF2PLAYERS][64];
static bool b_NpcHasQuestForPlayer[MAXENTITIES][MAXTF2PLAYERS];
static int b_ParticleToOwner[MAXENTITIES];
static int b_OwnerToParticle[MAXENTITIES];

void Quests_ConfigSetup()
{
	delete QuestKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "quests");
	QuestKv = new KeyValues("Quests");
	QuestKv.SetEscapeSequences(true);
	QuestKv.ImportFromFile(buffer);

	QuestKv.GotoFirstSubKey();
	do
	{
		QuestKv.GetString("model", buffer, sizeof(buffer), "error.mdl");
		if(!buffer[0])
			continue;
		
		PrecacheModel(buffer);

		QuestKv.GetString("wear1", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		QuestKv.GetString("wear2", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);

		QuestKv.GetString("wear3", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheModel(buffer);
		
		QuestKv.GetString("sound_talk", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheScriptSound(buffer);
		
		QuestKv.GetString("sound_leave", buffer, sizeof(buffer));
		if(buffer[0])
			PrecacheScriptSound(buffer);
		
		if(QuestKv.GotoFirstSubKey())
		{
			do
			{
				QuestKv.GetString("sound_start", buffer, sizeof(buffer));
				if(buffer[0])
					PrecacheScriptSound(buffer);
				
				QuestKv.GetString("sound_turnin", buffer, sizeof(buffer));
				if(buffer[0])
					PrecacheScriptSound(buffer);
			}
			while(QuestKv.GotoNextKey());

			QuestKv.GoBack();
		}
	}
	while(QuestKv.GotoNextKey());
}

void Quests_EnableZone(int client, const char[] name)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		static char buffer[PLATFORM_MAX_PATH];
		QuestKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
			if(entity == INVALID_ENT_REFERENCE)
			{
				entity = CreateEntityByName("prop_dynamic");
				if(IsValidEntity(entity))
				{
					static float pos[3], ang[3];

					QuestKv.GetVector("pos", pos);
					QuestKv.GetVector("ang", ang);
					TeleportEntity(entity, pos, ang, NULL_VECTOR);

					QuestKv.GetString("model", buffer, sizeof(buffer));
					DispatchKeyValue(entity, "model", buffer);
					DispatchKeyValue(entity, "solid", "1");
					SetEntityCollisionGroup(entity, 1);
					DispatchKeyValue(entity, "targetname", "rpg_fortress");


					DispatchSpawn(entity);

					SetEntPropFloat(entity, Prop_Send, "m_flModelScale", QuestKv.GetFloat("scale", 1.0));
				//	SetEntityModel(entity, buffer);
				//	SetEntityCollisionGroup(entity, 24);
				//	SetVariantString("solid 2");
				//	AcceptEntityInput(entity, "AddOutput");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
					SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);

					int brush = SpawnSeperateCollisionBox(entity);
					//Just reuse it.
					b_BrushToOwner[brush] = EntIndexToEntRef(entity);
					b_OwnerToBrush[entity] = EntIndexToEntRef(brush);

					TeleportEntity(entity, pos, ang, NULL_VECTOR);					
					QuestKv.GetString("wear1", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					QuestKv.GetString("wear2", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					QuestKv.GetString("wear3", buffer, sizeof(buffer));
					if(buffer[0])
						GivePropAttachment(entity, buffer);
					
					QuestKv.GetString("anim_idle", buffer, sizeof(buffer));
					SetVariantString(buffer);
					AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
					
					SetVariantString(buffer);
					AcceptEntityInput(entity, "SetAnimation", entity, entity);
					
					SetEntProp(entity, Prop_Data, "m_bSequenceLoops", true);
					
					int force_bodygroup;

					force_bodygroup = QuestKv.GetNum("force_bodygroup", 0);
					if(force_bodygroup > 0)
					{
						SetVariantInt(force_bodygroup);
						AcceptEntityInput(entity, "SetBodyGroup");
					}

					QuestKv.SetNum("_entref", EntIndexToEntRef(entity));

					pos[2] += 110.0;

					int particle = ParticleEffectAt(pos, "powerup_icon_regen", 0.0);
					
					SetEntPropVector(particle, Prop_Data, "m_angRotation", ang);

					SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
					SDKHook(particle, SDKHook_SetTransmit, QuestIndicatorTransmit);
					b_ParticleToOwner[particle] = EntIndexToEntRef(entity);
					b_OwnerToParticle[entity] = EntIndexToEntRef(particle);
					b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
				}
			}
			else
			{
				b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointerKv(client);
			}
		}
	}
	while(QuestKv.GotoNextKey());
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
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		static char buffer[32];
		QuestKv.GetString("zone", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
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
			
			QuestKv.SetNum("_entref", INVALID_ENT_REFERENCE);
		}
	}
	while(QuestKv.GotoNextKey());
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
				kv.SetNum(id, kv.GetNum(id) + 1);
		}
	}
}

static void MakeInteraction(int client, int entity, const char[] sound, const char[] anim)
{
	static char buffer[64];
	QuestKv.GetString(sound, buffer, sizeof(buffer));
	if(buffer[0])
		EmitGameSoundToClient(client, buffer, entity);
	
	QuestKv.GetString(anim, buffer, sizeof(buffer));
	if(buffer[0])
	{
		SetVariantString(buffer);
		AcceptEntityInput(entity, "SetAnimation", entity, entity);
	}
}

static bool ShouldShowPointerKv(int client)
{
	static char steamid[64], name[64], buffer[64];
	QuestKv.GetSectionName(name, sizeof(name));
	
	bool result;
	if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
	{
		if(QuestKv.GotoFirstSubKey())
		{
			do
			{
				int level = QuestKv.GetNum("level");
				if(Level[client] >= level)
				{
					QuestKv.GetSectionName(buffer, sizeof(buffer));

					KeyValues kv = Saves_Kv("quests");
					kv.JumpToKey(name, true);
					if(kv.JumpToKey(buffer, true))
					{
						switch(kv.GetNum(steamid))
						{
							case Status_NotStarted, Status_Canceled:
							{
								result = true;
								break;
							}
							case Status_InProgress:
							{
								if(CanTurnInQuest(client, steamid))
								{
									result = true;
									break;
								}
							}
							case Status_Completed:
							{
								if(QuestKv.GetNum("repeatable"))
								{
									result = true;
									break;
								}
							}
						}
					}
				}
			}
			while(QuestKv.GotoNextKey());

			QuestKv.GoBack();
		}
	}
	return result;
}

static bool ShouldShowPointer(int client, int entity)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			ShouldShowPointerKv(client);
			break;
		}
	}
	while(QuestKv.GotoNextKey());
	return false;
}

bool Quests_Interact(int client, int entity)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		if(EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE)) == entity)
		{
			MakeInteraction(client, entity, "sound_talk", "anim_talk");
			QuestKv.GetSectionName(CurrentNPC[client], sizeof(CurrentNPC[]));
			MainMenu(client);
			return true;
		}
	}
	while(QuestKv.GotoNextKey());
	return false;
}

void Quests_MainMenu(int client, const char[] name)
{
	QuestKv.Rewind();
	if(QuestKv.JumpToKey(name))
	{
		strcopy(CurrentNPC[client], sizeof(CurrentNPC[]), name);
		MainMenu(client);
	}
}

static void MainMenu(int client)
{
	TextStore_DepositBackpack(client, false);
	
	KeyValues kv = Saves_Kv("quests");
	kv.JumpToKey(CurrentNPC[client], true);
	
	Menu menu = new Menu(Quests_MenuHandle);
	menu.SetTitle("%s\n ", CurrentNPC[client]);

	static char steamid[64], name[64], buffer[96];
	if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
	{
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetString("complete", buffer, sizeof(buffer));
			if(buffer[0])
			{
				int progress;
				if(kv.JumpToKey(buffer))
				{
					progress = kv.GetNum(steamid);
					kv.GoBack();
				}

				if(progress != Status_Completed)
					continue;
			}
			
			QuestKv.GetSectionName(name, sizeof(name));
			
			int level = QuestKv.GetNum("level");
			Format(buffer, sizeof(buffer), "%s (Level %d)", name, level);

			if(Level[client] >= level)
			{
				if(kv.JumpToKey(name, true))
				{
					switch(kv.GetNum(steamid))
					{
						case Status_NotStarted, Status_Canceled, Status_InProgress:
						{
							menu.AddItem(name, buffer);
						}
						case Status_Completed:
						{
							if(QuestKv.GetNum("repeatable"))
								menu.AddItem(name, buffer);
						}
						default:
						{
							PrintToChatAll("INVALID QUEST STATUSSSSSSSS REPORTME!!!!!!");
						}
					}

					kv.GoBack();
				}
			}
			else
			{
				menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
			}
		}
		while(QuestKv.GotoNextKey());
	}

	if(!menu.ItemCount)
		menu.AddItem(NULL_STRING, "All Quests Completed", ITEMDRAW_DISABLED);

	menu.Display(client, MENU_TIME_FOREVER);
}

static bool CanTurnInQuest(int client, const char[] steamid, char title[512] = "", Menu book = null)
{
	bool canTurnIn = true;
	static char buffer[64];

	if(QuestKv.JumpToKey("obtain"))
	{
		if(!book)
			Format(title, sizeof(title), "%s\n \nObtain:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);
				int count = TextStore_GetItemCount(client, buffer);

				if(book)
				{
					if(need > count)
					{
						Format(buffer, sizeof(buffer), "Obtain %d more %s", need - count, buffer);
						book.AddItem(NULL_STRING, buffer);
					}
				}
				else
				{
					Format(title, sizeof(title), "%s\n%s (%d / %d)", title, buffer, count, need);
				}

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
		if(!book)
			Format(title, sizeof(title), "%s\n \nGive:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);
				int count = TextStore_GetItemCount(client, buffer);

				if(book)
				{
					if(need > count)
					{
						Format(buffer, sizeof(buffer), "Obtain %d more %s", need - count, buffer);
						book.AddItem(NULL_STRING, buffer);
					}
				}
				else
				{
					Format(title, sizeof(title), "%s\n%s (%d / %d)", title, buffer, count, need);
				}

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

		if(!book)
			Format(title, sizeof(title), "%s\n \nKill:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);

				int count;
				if(kv.JumpToKey(buffer, true))
				{
					count = kv.GetNum(steamid);
					kv.GoBack();
				}

				if(book)
				{
					if(need > count)
					{
						Format(buffer, sizeof(buffer), "Kill %s %d more times", buffer, need - count);
						book.AddItem(NULL_STRING, buffer);
					}
				}
				else
				{
					Format(title, sizeof(title), "%s\n%s (%d / %d)", title, buffer, count, need);
				}

				if(count < need)
					canTurnIn = false;
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}
		
		QuestKv.GoBack();
	}

	if(!book && QuestKv.JumpToKey("equip"))
	{
		Format(title, sizeof(title), "%s\n \nEquip:", title);
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				Format(title, sizeof(title), "%s\n%s", title, buffer);

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

public int Quests_MenuHandle(Menu menu2, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu2;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_Exit)
			{
				QuestKv.Rewind();
				if(QuestKv.JumpToKey(CurrentNPC[client]))
				{
					int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
					if(entity != INVALID_ENT_REFERENCE)
						MakeInteraction(client, entity, "sound_leave", "anim_leave");
				}
			}
		}
		case MenuAction_Select:
		{
			static char name[64], steamid[64];
			menu2.GetItem(choice, name, sizeof(name));
			if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
			{
				QuestKv.Rewind();
				if(QuestKv.JumpToKey(CurrentNPC[client]) && QuestKv.JumpToKey(name))
				{
					static char title[512];
					QuestKv.GetString("desc", title, sizeof(title));
					//Format(title, sizeof(title), "%s\n%s\n \n%s", CurrentNPC[client], name, title);

					bool canTurnIn = CanTurnInQuest(client, steamid, title);

					KeyValues kv = Saves_Kv("quests");
					kv.JumpToKey(CurrentNPC[client], true);
					kv.JumpToKey(name, true);
					int progress = kv.GetNum(steamid);

					if(QuestKv.JumpToKey("reward"))
					{
						Format(title, sizeof(title), "%s\n \nReward:", title);
						if(QuestKv.GotoFirstSubKey(false))
						{
							do
							{
								QuestKv.GetSectionName(steamid, sizeof(steamid));
								int count = QuestKv.GetNum(NULL_STRING, 1);
								if(count == 1)
								{
									Format(title, sizeof(title), "%s\n%s", title, steamid);
								}
								else
								{
									Format(title, sizeof(title), "%s\n%s x%d", title, steamid, count);
								}
							}
							while(QuestKv.GotoNextKey(false));

							QuestKv.GoBack();
						}

						QuestKv.GoBack();
					}

					Menu menu = new Menu(Quests_QuestHandle);
					menu.SetTitle("%s\n ", title);

					switch(progress)
					{
						case Status_NotStarted:
						{
							menu.AddItem(name, "Start Quest");
						}
						case Status_Canceled:
						{
							menu.AddItem(name, "Restart Quest");
						}
						case Status_InProgress:
						{
							menu.AddItem(name, "Turn In", canTurnIn ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
							menu.AddItem(name, "Cancel Quest");
						}
						case Status_Completed:
						{
							menu.AddItem(name, "Restart Quest", QuestKv.GetNum("repeatable") ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
						}
					}

					menu.ExitBackButton = true;
					menu.Display(client, MENU_TIME_FOREVER);
				}
			}
		}
	}
	return 0;
}

public int Quests_QuestHandle(Menu menu2, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu2;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				Quests_MainMenu(client, CurrentNPC[client]);
		}
		case MenuAction_Select:
		{
			static char name[64], steamid[64];
			menu2.GetItem(choice, name, sizeof(name));
			if(Saves_ClientCharId(client, steamid, sizeof(steamid)))
			{
				QuestKv.Rewind();
				if(QuestKv.JumpToKey(CurrentNPC[client]))
				{
					int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
					if(QuestKv.JumpToKey(name))
					{
						KeyValues kv = Saves_Kv("quests");
						kv.JumpToKey(CurrentNPC[client], true);
						kv.JumpToKey(name, true);
						
						int progress = kv.GetNum(steamid);
						switch(progress)
						{
							case Status_NotStarted, Status_Completed:
							{
								if(entity != INVALID_ENT_REFERENCE)
									MakeInteraction(client, entity, "sound_start", "anim_start");
								
								kv.SetNum(steamid, Status_InProgress);

								if(QuestKv.JumpToKey("start"))
								{
									if(QuestKv.GotoFirstSubKey(false))
									{
										do
										{
											QuestKv.GetSectionName(name, sizeof(name));
											TextStore_AddItemCount(client, name, QuestKv.GetNum(NULL_STRING, 1));
										}
										while(QuestKv.GotoNextKey(false));
									}

									Saves_SaveClient(client);
								}
							}
							case Status_Canceled:
							{
								if(entity != INVALID_ENT_REFERENCE)
									MakeInteraction(client, entity, "sound_start", "anim_start");
								
								kv.SetNum(steamid, Status_InProgress);
							}
							case Status_InProgress:
							{
								if(choice)
								{
									kv.SetNum(steamid, Status_Canceled);
									Quests_MainMenu(client, CurrentNPC[client]);
								}
								else if(CanTurnInQuest(client, steamid))
								{
									if(entity != INVALID_ENT_REFERENCE)
										MakeInteraction(client, entity, "sound_turnin", "anim_turnin");
									
									kv = Saves_Kv("quests");
									kv.JumpToKey(CurrentNPC[client], true);
									kv.JumpToKey(name, true);
									kv.SetNum(steamid, Status_Completed);

									if(QuestKv.JumpToKey("give"))
									{
										if(QuestKv.GotoFirstSubKey(false))
										{
											do
											{
												QuestKv.GetSectionName(name, sizeof(name));
												TextStore_AddItemCount(client, name, -QuestKv.GetNum(NULL_STRING, 1));
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
												QuestKv.GetSectionName(name, sizeof(name));
												if(kv.JumpToKey(name))
												{
													kv.SetNum(steamid, kv.GetNum(steamid) - QuestKv.GetNum(NULL_STRING, 1));
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
												QuestKv.GetSectionName(name, sizeof(name));
												TextStore_AddItemCount(client, name, QuestKv.GetNum(NULL_STRING, 1));
											}
											while(QuestKv.GotoNextKey(false));
										}
									}

									Saves_SaveClient(client);
								}
							}
						}
						b_NpcHasQuestForPlayer[entity][client] = ShouldShowPointer(client, entity);
					}
				}
			}
		}
	}
	return 0;
}

bool Quests_BookMenu(int client)
{
	Menu menu = new Menu(Quests_BookHandle);
	menu.SetTitle("RPG Fortress\n \n");
	
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
								Format(buffer, sizeof(buffer), "%s - %s", name, buffer);
								CanTurnInQuest(client, steamid, buffer);
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

	if(menu.ItemCount)
	{
		menu.Pagination = 2;
		menu.ExitButton = true;
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
			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
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