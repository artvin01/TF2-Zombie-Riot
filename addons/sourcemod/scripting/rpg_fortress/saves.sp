#pragma semicolon 1
#pragma newdecls required

static KeyValues SaveKv;
static char CharacterId[MAXPLAYERS][32];
#define MAX_CHARACTER_SLOTS 5 

void Saves_PluginStart()
{
	RegConsoleCmd("rpg_character", Saves_Command, "View your characters");
	RegConsoleCmd("sm_character", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("rpg_characters", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("sm_characters", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("rpg_save", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("sm_save", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("rpg_saves", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("sm_saves", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("rpg_char", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("sm_char", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("rpg_chars", Saves_Command, "View your characters", FCVAR_HIDDEN);
	RegConsoleCmd("sm_chars", Saves_Command, "View your characters", FCVAR_HIDDEN);
}

void Saves_ConfigSetup()
{
	delete SaveKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "savedata");
	SaveKv = new KeyValues("SaveData");
	SaveKv.ImportFromFile(buffer);

	FormatTime(buffer, sizeof(buffer), "savedata-backup%F");
	RPG_BuildPath(buffer, sizeof(buffer), buffer);
	SaveKv.ExportToFile(buffer);
}

void Saves_PluginEnd()
{
	Saves_SaveClient(0);
}

void Saves_SaveClient(int client)
{
	static char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "savedata");

	SaveKv.Rewind();
	SaveKv.ExportToFile(buffer);

	if(client)
		TextStore_ClientSave(client);
}

KeyValues Saves_Kv(const char[] section)
{
	SaveKv.Rewind();
	SaveKv.JumpToKey(section, true);
	return SaveKv;
}

bool Saves_HasCharacter(int client)
{
	return view_as<bool>(CharacterId[client][0]);
}

int Saves_ClientCharId(int client, char[] buffer, int length)
{
	return strcopy(buffer, length, CharacterId[client]);
}

void Saves_ClientDisconnect(int client)
{
	SaveCharacter(client, true);
}

static void EnableCharacter(int client, const char[] id)
{
	//dont show transforms.
	i_TransformationSelected[client] = 0;
	if(!CharacterId[client][0])
	{
		char buffer1[64], buffer2[64];

		KeyValues kv = Saves_Kv("characters");
		if(kv.JumpToKey(id))
		{
			mp_disable_respawn_times.ReplicateToClient(client, "0");
			SetTeam(client, TFTeam_Red);
			strcopy(CharacterId[client], sizeof(CharacterId[]), id);
			RaceIndex[client] = kv.GetNum("race");

			kv.GetString("model", buffer1, sizeof(buffer1));
			switch(buffer1[2])
			{
				case 'o':	// Scout
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Scout);
				}
				case 'l':	// Soldier
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Soldier);
				}
				case 'r':	// Pyro
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Pyro);
				}
				case 'm':	// Demoman
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_DemoMan);
				}
				case 'a':	// Heavy
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Heavy);
				}
				case 'g':	// Engineer
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Engineer);
				}
				case 'i':	// Sniper
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Sniper);
				}
				case 'y':	// Spy
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Spy);
				}
				default:	// Medic
				{
					SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Medic);
				}
			}

			Stats_EnableCharacter(client);
			TextStore_DelayMenuHud(client);
			Mana_Hud_Delay[client] = GetGameTime() + 2.0;
			delay_hud[client] = GetGameTime() + 2.5;
		}

		int uniques, count;
		int length = TextStore_GetItems(uniques);
		
		kv = Saves_Kv("characters");
		if(kv.JumpToKey(id))
		{
			if(kv.JumpToKey("equipped"))
			{
				if(kv.GotoFirstSubKey(false))
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						ReplaceString(buffer1, sizeof(buffer1), "#", "\"");

						for(int i = -uniques; i < length; i++)
						{
							if(!TextStore_GetInv(client, i, count) && count)
							{
								TextStore_GetItemName(i, buffer2, sizeof(buffer2));
								if(StrEqual(buffer1, buffer2, false))
								{
									TextStore_UseItem(client, i);
								}
							}
						}
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();
				}

				kv.GoBack();
			}
		}
	}
}

static void SaveCharacter(int client, bool remove)
{
	if(CharacterId[client][0])
	{
		KeyValues kv = Saves_Kv("characters");
		if(kv.JumpToKey(CharacterId[client]))
		{
			kv.SetNum("lastsave", GetTime());
			kv.SetNum("level", Level[client]);
			
			kv.DeleteKey("equipped");
			kv.JumpToKey("equipped", true);

			char buffer[64];

			int uniques;
			int length = TextStore_GetItems(uniques);
			for(int i = -uniques; i < length; i++)
			{
				KeyValues item = TextStore_GetItemKv(i);
				if(item)
				{
					item.GetString("plugin", buffer, sizeof(buffer));
					if(StrEqual(buffer, "rpg_fortress", false))
					{
						TextStore_GetItemName(i, buffer, sizeof(buffer));
						if(TextStore_GetInv(client, i))
						{
							ReplaceString(buffer, sizeof(buffer), "\"", "#");
							kv.SetNum(buffer, 1);

							if(remove)
								TextStore_SetInv(client, i, _, false);
						}
					}
				}
			}

			kv.GoBack();

			Saves_SaveClient(client);
		}

		if(remove)
		{
			CharacterId[client][0] = 0;
			mp_disable_respawn_times.ReplicateToClient(client, "1");
		}
	}

	if(remove)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			ForcePlayerSuicide(client);
			SetTeam(client, TFTeam_Spectator);
		}
	}
}

static Action Saves_Command(int client, int args)
{
	if(client)
	{
		Saves_MainMenu(client);
	}
	return Plugin_Handled;
}

void Saves_MainMenu(int client)
{
	if(!SaveKv)	// Lateload Fix
		return;
	
	if(Actor_InChatMenu(client))
		return;

	Race race;

	char buffer1[64], buffer2[32];

	KeyValues kv = Saves_Kv("characters");
	if(CharacterId[client][0] && kv.JumpToKey(CharacterId[client]))
	{
		Races_GetRaceByIndex(RaceIndex[client], race);
		kv.GetString("title", buffer1, sizeof(buffer1), "Normal");
		kv.GetString("model", buffer2, sizeof(buffer2), "N/A");

		Menu menu = new Menu(CharacterInfoH);
		menu.SetTitle("RPG Fortress\n \nCharacter:\n \n" ...
		"Race: %s\nOutfit: %s\nTrait: %s\nLevel: %d\nUnspent XP: %d", race.Name, buffer2, buffer1, Level[client], XP[client]);

		menu.AddItem(NULL_STRING, "Change Characters", ITEMDRAW_SPACER);
		menu.AddItem(NULL_STRING, "Change Characters");

		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(CharacterSelectH);
		menu.SetTitle("RPG Fortress\n \nCharacter Selection:\n ");

		int chars;

		char steamid[32];
		if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)) && strlen(steamid) > 9)
		{
			if(kv.GotoFirstSubKey())
			{
				do
				{
					kv.GetString("owner", buffer2, sizeof(buffer2));
					if(StrEqual(buffer2, steamid))
					{
						Races_GetRaceByIndex(kv.GetNum("race"), race);
						kv.GetString("title", buffer1, sizeof(buffer1));
						kv.GetString("model", buffer2, sizeof(buffer2));

						if(buffer1[0])
						{
							Format(buffer1, sizeof(buffer1), "Level %d \"%s\" %s %s", kv.GetNum("level"), buffer1, race.Name, buffer2);
						}
						else
						{
							FormatEx(buffer1, sizeof(buffer1), "Level %d %s %s", kv.GetNum("level"), race.Name, buffer2);
						}
						
						kv.GetSectionName(buffer2, sizeof(buffer2));
						menu.AddItem(buffer2, buffer1);
						chars++;
					}
				}
				while(kv.GotoNextKey());
			}

			for(; chars < MAX_CHARACTER_SLOTS; chars++)
			{
				menu.AddItem("", "New Character");
			}

			menu.Pagination = 0;
			menu.ExitButton = false;
			menu.Display(client, MENU_TIME_FOREVER);
		}
		else
		{
			menu.AddItem("", "Connecting to Steam...", ITEMDRAW_DISABLED);

			menu.ExitButton = false;
			menu.Display(client, 2);
		}
	}
}

static int CharacterInfoH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			if(choice == 1)
			{
				SaveCharacter(client, true);
			}
		}
	}

	return 0;
}

static int CharacterSelectH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char id[32];
			menu.GetItem(choice, id, sizeof(id));

			if(id[0])
			{
				CharacterMenu(client, id);
			}
			else
			{
				CreateCharacter(client);
			}
		}
	}

	return 0;
}

static void CharacterMenu(int client, const char[] id)
{
	KeyValues kv = Saves_Kv("characters");
	if(kv.JumpToKey(id))
	{
		char buffer1[32], buffer2[32], buffer3[32];

		Race race;
		Races_GetRaceByIndex(kv.GetNum("race"), race);
		kv.GetString("title", buffer1, sizeof(buffer1), "Normal");
		kv.GetString("model", buffer2, sizeof(buffer2), "N/A");
		FormatTime(buffer3, sizeof(buffer3), NULL_STRING, kv.GetNum("lastsave"));

		int level = kv.GetNum("level");

		Menu menu = new Menu(CharacterMenuH);

		menu.SetTitle("RPG Fortress\n \nCharacter Selection:\n \n" ...
		"Race: %s\nOutfit: %s\nTrait: %s\nLevel: %d\nLast Played: %s\n ", race.Name, buffer2, buffer1, level, buffer3);

		menu.AddItem(id, "Select Character");
		menu.AddItem(id, "Modifiy Character");
		menu.AddItem(id, "Delete Character");

		menu.ExitBackButton = true;
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static int CharacterMenuH(Menu menuaaaa, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menuaaaa;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				Saves_MainMenu(client);
		}
		case MenuAction_Select:
		{
			char id[32];
			menuaaaa.GetItem(choice, id, sizeof(id));

			switch(choice)
			{
				case 0:	// Select
				{
					EnableCharacter(client, id);

					if(!IsPlayerAlive(client))
					{
						if(GetClientTeam(client) == TFTeam_Red)
						{
							TF2_RespawnPlayer(client);
						}
						else
						{
							SetTeam(client, TFTeam_Red);
						}
					}
				}
				case 1:	// Modifiy
				{
					ModifiyCharacter(client, id);
				}
				case 2:	// Delete
				{
					Menu menu = new Menu(DeleteCharacterH);

					menu.SetTitle("RPG Fortress\n \nAre you sure you want to delete this character?\nThis action can not be undone.\n ");

					menu.AddItem(id, "", ITEMDRAW_SPACER);
					menu.AddItem(id, "", ITEMDRAW_SPACER);
					menu.AddItem(id, "", ITEMDRAW_SPACER);
					menu.AddItem(id, "Yes, delete");
					menu.AddItem(id, "", ITEMDRAW_SPACER);
					menu.AddItem(id, "No, keep");

					menu.ExitBackButton = true;
					menu.ExitButton = false;
					menu.Display(client, MENU_TIME_FOREVER);
				}
			}
		}
	}

	return 0;
}

static int DeleteCharacterH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				char id[32];
				menu.GetItem(0, id, sizeof(id));
				CharacterMenu(client, id);
			}
		}
		case MenuAction_Select:
		{
			char id[32];
			menu.GetItem(choice, id, sizeof(id));

			if(choice == 3)
			{
				KeyValues kv = Saves_Kv("characters");
				kv.DeleteKey(id);

				kv = Saves_Kv("stats");
				kv.DeleteKey(id);

				Quests_DeleteChar(id);
				Dungeon_DeleteChar(id);

				//if(kv.JumpToKey(id))
				//	kv.SetString("owner", "DELETED");

				Saves_MainMenu(client);
			}
			else
			{
				CharacterMenu(client, id);
			}
		}
	}

	return 0;
}

static void CreateCharacter(int client)
{
	static const int Cooldown = 86400; // 24 hours

	char steamid[32], id[32];
	int time = GetTime();
	int timestamp = time / Cooldown;
	GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid));
	FormatEx(id, sizeof(id), "%d-%s", timestamp, steamid);

	KeyValues kv = Saves_Kv("characters");
	if(kv.JumpToKey(id))
	{
		kv.GetString("owner", steamid, sizeof(steamid));
		if(StrContains(steamid, "delete", false) == -1)
		{
			SPrintToChat(client, "You already recently created a character, delete that character or try again in %d minutes!", (((time / Cooldown) - timestamp + 1) * Cooldown) / 60);
		}
		else
		{
			kv.DeleteThis();
			CreateCharacter(client);
		}
	}
	else
	{
		kv.JumpToKey(id, true);
		kv.SetString("owner", steamid);
		
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:
				kv.SetString("model", "Scout");
			
			case TFClass_Soldier:
				kv.SetString("model", "Soldier");
			
			case TFClass_Pyro:
				kv.SetString("model", "Pyro");
			
			case TFClass_DemoMan:
				kv.SetString("model", "Demoman");
			
			case TFClass_Heavy:
				kv.SetString("model", "Heavy");
			
			case TFClass_Engineer:
				kv.SetString("model", "Engineer");
			
			case TFClass_Sniper:
				kv.SetString("model", "Sniper");
			
			case TFClass_Spy:
				kv.SetString("model", "Spy");
			
			default:
				kv.SetString("model", "Medic");
		}

		kv.SetNum("firstsave", time);
		kv.SetNum("lastsave", time);

		if(CvarRPGInfiniteLevelAndAmmo.BoolValue)
			kv.SetString("title", "Debugger");

		ModifiyCharacter(client, id);
	}
}

static void ModifiyCharacter(int client, const char[] id, int submenu = -1)
{
	KeyValues kv = Saves_Kv("characters");
	if(kv.JumpToKey(id))
	{
		char buffer1[32], buffer2[32], buffer3[32];

		switch(submenu)
		{
			case 0:
			{
				Menu menu = new Menu(ModifiyCharacterRaceH);

				menu.SetTitle("RPG Fortress\n \nCharacter Creation:\nRace\n ");

				Race race;
				for(int i; Races_GetRaceByIndex(i, race); i++)
				{
					if(!race.Key[0] || TextStore_GetItemCount(client, race.Key) > 0)
					{
						menu.AddItem(id, race.Name);
					}
					else
					{
						FormatEx(buffer1, sizeof(buffer1), "%s (Locked)", race.Name);
						menu.AddItem(id, buffer1, ITEMDRAW_DISABLED);
					}
				}

				if(!menu.ItemCount)
					menu.AddItem(id, "No Races??????", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.ExitButton = false;
				menu.Display(client, MENU_TIME_FOREVER);
			}
			case 1:
			{
				Menu menu = new Menu(ModifiyCharacterModelH);

				menu.SetTitle("RPG Fortress\n \nCharacter Creation:\nOutfit\n ");

				menu.AddItem(id, "Scout");
				menu.AddItem(id, "Soldier");
				menu.AddItem(id, "Pyro");
				menu.AddItem(id, "Demoman");
				menu.AddItem(id, "Heavy");
				menu.AddItem(id, "Engineer");
				menu.AddItem(id, "Medic");
				menu.AddItem(id, "Sniper");
				menu.AddItem(id, "Spy");

				menu.ExitBackButton = true;
				menu.ExitButton = false;
				menu.Display(client, MENU_TIME_FOREVER);
			}
			default:
			{
				Race race;
				Races_GetRaceByIndex(kv.GetNum("race"), race);
				FormatTime(buffer3, sizeof(buffer3), NULL_STRING, kv.GetNum("lastsave"));

				int level = kv.GetNum("level");

				Menu menu = new Menu(ModifiyCharacterH);

				menu.SetTitle("RPG Fortress\n \nCharacter Creation:\n ");

				FormatEx(buffer1, sizeof(buffer1), "Race: %s", race.Name);
				menu.AddItem(id, buffer1, (level > 199 && !CvarRPGInfiniteLevelAndAmmo.BoolValue) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

				kv.GetString("model", buffer2, sizeof(buffer2));
				FormatEx(buffer1, sizeof(buffer1), "Outfit: %s", buffer2);
				menu.AddItem(id, buffer1);

				kv.GetString("title", buffer2, sizeof(buffer2), "Normal");
				FormatEx(buffer1, sizeof(buffer1), "Trait: %s", buffer2);
				menu.AddItem(id, buffer1, ITEMDRAW_DISABLED);

				Format(buffer1, sizeof(buffer1), "Level: %d", level);
				menu.AddItem(id, buffer1, ITEMDRAW_DISABLED);

				menu.AddItem(id, "", ITEMDRAW_DISABLED);
				menu.AddItem(id, "", ITEMDRAW_DISABLED);
				menu.AddItem(id, "", ITEMDRAW_DISABLED);
				menu.AddItem(id, buffer1, ITEMDRAW_SPACER);

				menu.AddItem(id, "Finish Character");

				menu.Pagination = 0;
				menu.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
}

static int ModifiyCharacterH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char id[32];
			menu.GetItem(choice, id, sizeof(id));
			
			if(choice == 8)
			{
				CharacterMenu(client, id);
			}
			else
			{
				ModifiyCharacter(client, id, choice);
			}
		}
	}

	return 0;
}

static int ModifiyCharacterRaceH(Menu menuaaaa, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menuaaaa;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				char id[32];
				menuaaaa.GetItem(0, id, sizeof(id));
				ModifiyCharacter(client, id);
			}
		}
		case MenuAction_Select:
		{
			char id[32];
			menuaaaa.GetItem(choice, id, sizeof(id));
			
			Race race;
			if(Races_GetRaceByIndex(choice, race))
			{
				Menu menu = new Menu(ModifiyCharacterRaceInfoH);

				ReplaceString(race.Desc, sizeof(race.Desc), "\\n", "\n");
				menu.SetTitle("RPG Fortress\n \n%s\n%s\n ", race.Name, race.Desc);

				menu.AddItem(id, "Select Race\n ");

				char buffer1[32], buffer2[16];
				IntToString(choice, buffer2, sizeof(buffer2));

				FormatEx(buffer1, sizeof(buffer1), "Strength: x%.2f", race.StrengthMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Precision: x%.2f", race.PrecisionMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Artifice: x%.2f", race.ArtificeMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Endurance: x%.2f", race.EnduranceMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Structure: x%.2f", race.StructureMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Intelligence: x%.2f", race.IntelligenceMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Capacity: x%.2f", race.CapacityMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Luck: x%.2f", race.LuckMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				FormatEx(buffer1, sizeof(buffer1), "Agility: x%.2f", race.AgilityMulti);
				menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);

				menu.Pagination = 5;
				menu.ExitBackButton = true;
				menu.ExitButton = false;
				menu.Display(client, MENU_TIME_FOREVER);
			}
		}
	}

	return 0;
}

static int ModifiyCharacterRaceInfoH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				char id[32];
				menu.GetItem(0, id, sizeof(id));
				ModifiyCharacter(client, id, 0);
			}
		}
		case MenuAction_Select:
		{
			char id[32], buffer[16];
			menu.GetItem(0, id, sizeof(id));
			menu.GetItem(1, buffer, sizeof(buffer));
			
			KeyValues kv = Saves_Kv("characters");
			if(kv.JumpToKey(id))
			{
				kv.SetNum("race", StringToInt(buffer));
				ModifiyCharacter(client, id);
			}
		}
	}

	return 0;
}

static int ModifiyCharacterModelH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				char id[32];
				menu.GetItem(0, id, sizeof(id));
				ModifiyCharacter(client, id);
			}
		}
		case MenuAction_Select:
		{
			char id[32], model[32];
			menu.GetItem(choice, id, sizeof(id), _, model, sizeof(model));
			
			KeyValues kv = Saves_Kv("characters");
			if(kv.JumpToKey(id))
			{
				kv.SetString("model", model);
				ModifiyCharacter(client, id);
			}
		}
	}

	return 0;
}
