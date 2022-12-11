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
static KeyValues SaveKv;
static char CurrentNPC[MAXTF2PLAYERS][64];
static bool b_NpcHasQuestForPlayer[MAXENTITIES][MAXTF2PLAYERS];
static int b_ParticleToOwner[MAXENTITIES];
static int b_OwnerToParticle[MAXENTITIES];

static void ForceSave(int client)
{
	static char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "quests_savedata");

	SaveKv.Rewind();
	SaveKv.ExportToFile(buffer);

	TextStore_ClientSave(client);
}

void Quests_ConfigSetup(KeyValues map)
{
	delete QuestKv;
	delete SaveKv;

	if(map)
	{
		map.Rewind();
		if(map.JumpToKey("Quests"))
		{
			QuestKv = new KeyValues("Quests");
			QuestKv.SetEscapeSequences(true);
			QuestKv.Import(map);
		}
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!QuestKv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "quests");
		QuestKv = new KeyValues("Quests");
		QuestKv.SetEscapeSequences(true);
		QuestKv.ImportFromFile(buffer);
	}

	QuestKv.GotoFirstSubKey();
	do
	{
		QuestKv.GetString("model", buffer, sizeof(buffer));
		if(!buffer[0])
			SetFailState("Missing model in quests.cfg");
		
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

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "quests_savedata");
	SaveKv = new KeyValues("SaveData");
	SaveKv.ImportFromFile(buffer);
}

void Quests_EnableZone(int client, const char[] name)
{
	QuestKv.Rewind();
	QuestKv.GotoFirstSubKey();
	do
	{
		static char buffer[PLATFORM_MAX_PATH];
		QuestKv.GetSectionName(buffer, sizeof(buffer));
		QuestKv.GetString("zone", buffer, sizeof(buffer), buffer);
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
					SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 1600.0);
					SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 2000.0);
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
					
					QuestKv.SetNum("_entref", EntIndexToEntRef(entity));

					pos[2] += 90.0;

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
	SetEdictFlags(entity, GetEdictFlags(entity) &~ FL_EDICT_ALWAYS);
	
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
				RemoveEntity(entity);
			}
			
			QuestKv.SetNum("_entref", INVALID_ENT_REFERENCE);
		}
	}
	while(QuestKv.GotoNextKey());
}

void Quests_AddKill(int client, const char[] name)
{
	static char steamid[64];
	if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
	{
		SaveKv.Rewind();
		SaveKv.JumpToKey("_kills", true);
		SaveKv.JumpToKey(name, true);
		SaveKv.SetNum(steamid, SaveKv.GetNum(steamid) + 1);
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
	if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
	{
		if(QuestKv.GotoFirstSubKey())
		{
			do
			{
				int level = QuestKv.GetNum("level");
				if(Level[client] >= level)
				{
					QuestKv.GetSectionName(buffer, sizeof(buffer));

					SaveKv.Rewind();
					SaveKv.JumpToKey(name, true);
					if(SaveKv.JumpToKey(buffer, true))
					{
						switch(SaveKv.GetNum(steamid))
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
	SaveKv.Rewind();
	SaveKv.JumpToKey(CurrentNPC[client], true);
	
	Menu menu = new Menu(Quests_MenuHandle);
	menu.SetTitle("%s\n ", CurrentNPC[client]);

	static char steamid[64], name[64], buffer[96];
	if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
	{
		QuestKv.GotoFirstSubKey();
		do
		{
			QuestKv.GetString("complete", buffer, sizeof(buffer));
			if(buffer[0])
			{
				int progress;
				if(SaveKv.JumpToKey(buffer))
				{
					progress = SaveKv.GetNum(steamid);
					SaveKv.GoBack();
				}

				if(progress != Status_Completed)
					continue;
			}
			
			QuestKv.GetSectionName(name, sizeof(name));
			
			int level = QuestKv.GetNum("level");
			GetDisplayString(level, buffer, sizeof(buffer));
			Format(buffer, sizeof(buffer), "%s (%s)", name, buffer);

			if(Level[client] >= level)
			{
				if(SaveKv.JumpToKey(name, true))
				{
					switch(SaveKv.GetNum(steamid))
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
							PrintToChatAll("INVALID QUEST STATUSSSSSSSS");
						}
					}

					SaveKv.GoBack();
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
		SaveKv.Rewind();
		SaveKv.JumpToKey("_kills", true);

		if(!book)
			Format(title, sizeof(title), "%s\n \nKill:", title);
		
		if(QuestKv.GotoFirstSubKey(false))
		{
			do
			{
				QuestKv.GetSectionName(buffer, sizeof(buffer));
				int need = QuestKv.GetNum(NULL_STRING, 1);

				int count;
				if(SaveKv.JumpToKey(buffer, true))
				{
					count = SaveKv.GetNum(steamid);
					SaveKv.GoBack();
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
						if(StrEqual(StoreWeapon[entity], buffer, false))
						{
							canTurnIn = true;
							break;
						}
					}
				}
			}
			while(QuestKv.GotoNextKey(false));

			QuestKv.GoBack();
		}

		QuestKv.GoBack();
	}

	return canTurnIn;
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
			if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
			{
				QuestKv.Rewind();
				if(QuestKv.JumpToKey(CurrentNPC[client]) && QuestKv.JumpToKey(name))
				{
					static char title[512];
					QuestKv.GetString("desc", title, sizeof(title));
					//Format(title, sizeof(title), "%s\n%s\n \n%s", CurrentNPC[client], name, title);

					bool canTurnIn = CanTurnInQuest(client, steamid, title);

					SaveKv.Rewind();
					SaveKv.JumpToKey(CurrentNPC[client], true);
					SaveKv.JumpToKey(name, true);
					int progress = SaveKv.GetNum(steamid);

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
			if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
			{
				QuestKv.Rewind();
				if(QuestKv.JumpToKey(CurrentNPC[client]))
				{
					int entity = EntRefToEntIndex(QuestKv.GetNum("_entref", INVALID_ENT_REFERENCE));
					if(QuestKv.JumpToKey(name))
					{
						SaveKv.Rewind();
						SaveKv.JumpToKey(CurrentNPC[client], true);
						SaveKv.JumpToKey(name, true);
						
						int progress = SaveKv.GetNum(steamid);
						switch(progress)
						{
							case Status_NotStarted, Status_Completed:
							{
								if(entity != INVALID_ENT_REFERENCE)
									MakeInteraction(client, entity, "sound_start", "anim_start");
								
								SaveKv.SetNum(steamid, Status_InProgress);

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

									ForceSave(client);
								}
							}
							case Status_Canceled:
							{
								if(entity != INVALID_ENT_REFERENCE)
									MakeInteraction(client, entity, "sound_start", "anim_start");
								
								SaveKv.SetNum(steamid, Status_InProgress);
							}
							case Status_InProgress:
							{
								if(choice)
								{
									SaveKv.SetNum(steamid, Status_Canceled);
									Quests_MainMenu(client, CurrentNPC[client]);
								}
								else if(CanTurnInQuest(client, steamid))
								{
									if(entity != INVALID_ENT_REFERENCE)
										MakeInteraction(client, entity, "sound_turnin", "anim_turnin");
									
									SaveKv.Rewind();
									SaveKv.JumpToKey(CurrentNPC[client], true);
									SaveKv.JumpToKey(name, true);
									SaveKv.SetNum(steamid, Status_Completed);

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
										SaveKv.Rewind();
										SaveKv.JumpToKey("_kills", true);

										if(QuestKv.GotoFirstSubKey(false))
										{
											do
											{
												QuestKv.GetSectionName(name, sizeof(name));
												if(SaveKv.JumpToKey(name))
												{
													SaveKv.SetNum(steamid, SaveKv.GetNum(steamid) - QuestKv.GetNum(NULL_STRING, 1));
													SaveKv.GoBack();
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

									ForceSave(client);
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

void Quests_WeaponSwitch(int client, int weapon)
{
	if(weapon != -1 && StrEqual(StoreWeapon[weapon], "Quest Book"))
	{
		Menu menu = new Menu(Quests_BookHandle);
		menu.SetTitle("RPG Fortress\n \n");
		
		static char steamid[64], name[64], buffer[512];
		if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)))
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
						SaveKv.Rewind();
						if(SaveKv.JumpToKey(name))
						{
							QuestKv.GetSectionName(buffer, sizeof(buffer));
							if(SaveKv.JumpToKey(buffer))
							{
								if(SaveKv.GetNum(steamid) == Status_InProgress)
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

		menu.Display(client, MENU_TIME_FOREVER);
	}
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
			if(choice != MenuCancel_Disconnected)
				Store_SwapToItem(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
		}
		case MenuAction_Select:
		{
			Store_SwapToItem(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
		}
	}
	return 0;
}