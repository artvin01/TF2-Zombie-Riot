#pragma semicolon 1
#pragma newdecls required

enum struct GardenEnum
{
	char Zone[32];
	float Pos[3];
	
	int Store[MAXPLAYERS];
	float StartAt[MAXPLAYERS];
	float ReadyIn[MAXPLAYERS];
}

static ArrayList GardenList;
static char InGarden[MAXPLAYERS][32];
static float UpdateTrace[MAXPLAYERS];
static int InMenu[MAXPLAYERS] = {-1, ...};

void Garden_ResetAll()
{
	if(GardenList)
	{
		GardenEnum garden;
		int length = GardenList.Length;
		for(int i; i < length; i++)
		{
			GardenList.GetArray(i, garden);
			Zero(garden.ReadyIn);
			GardenList.SetArray(i, garden);
		}
	}
}

void Garden_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "garden");
	KeyValues kv = new KeyValues("Garden");
	kv.ImportFromFile(buffer);
	
	delete GardenList;
	GardenList = new ArrayList(sizeof(GardenEnum));

	GardenEnum garden;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(garden.Zone, sizeof(garden.Zone));
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					ExplodeStringFloat(buffer, " ", garden.Pos, sizeof(garden.Pos));
					GardenList.PushArray(garden);
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}
		}
		while(kv.GotoNextKey());
	}

	delete kv;
}

static int GetNearestGarden(const char[] zone, const float pos[3])
{
	int found = -1;
	float distance = 10000.0;
	
	int length = GardenList.Length;
	for(int i; i < length; i++)
	{
		static GardenEnum garden;
		GardenList.GetArray(i, garden);
		if(StrEqual(garden.Zone, zone, false))
		{
			float dist = GetVectorDistance(pos, garden.Pos, true);
			if(dist < distance)
			{
				found = i;
				distance = dist;
			}
		}
	}
	
	return found;
}

void Garden_ClientEnter(int client, const char[] zone)
{
	if(GardenList)
	{
		static GardenEnum garden;
		int length = GardenList.Length;
		for(int i; i < length; i++)
		{
			GardenList.GetArray(i, garden);
			if(StrEqual(garden.Zone, zone))
			{
				strcopy(InGarden[client], sizeof(InGarden[]), zone);
				UpdateTrace[client] = 0.0;
				break;
			}
		}
	}
}

void Garden_ClientLeave(int client, const char[] zone)
{
	if(StrEqual(InGarden[client], zone))
	{
		InGarden[client][0] = 0;
		if(InMenu[client] != -1)
			CancelClientMenu(client);
	}
}

void Garden_Interact(int client, const float pos[3])
{
	if(InGarden[client][0])
	{
		int index = GetNearestGarden(InGarden[client], pos);
		if(index != -1)
		{
			if(Editor_MenuFunc(client) != INVALID_FUNCTION)
			{
				OpenEditorFrom(client);
				return;
			}

			InMenu[client] = index;
			ShowMenu(client, true);
		}
	}
}

void Garden_PlayerRunCmd(int client)
{
	if(InGarden[client][0])
	{
		float gameTime = GetGameTime();
		if(UpdateTrace[client] < gameTime)
		{
			UpdateTrace[client] = gameTime + 3.0;
			
			int length = GardenList.Length;
			int DelayFrameDo = 0;
			for(int i; i < length; i++)
			{
				static GardenEnum garden;
				GardenList.GetArray(i, garden);
				if(StrEqual(garden.Zone, InGarden[client], false))
				{
					if(garden.ReadyIn[client])
					{
						float time = garden.ReadyIn[client] - garden.StartAt[client];
						float left = garden.ReadyIn[client] - GetGameTime();
						int stage = 4 - RoundToCeil(left * 4.0 / time);
						if(stage > 4)
							stage = 4;
						
						DelayFrameDo += 2;
						
						DataPack pack = new DataPack();
						pack.WriteCell(EntIndexToEntRef(client));
						pack.WriteFloat(garden.Pos[0]);
						pack.WriteFloat(garden.Pos[1]);
						pack.WriteFloat(garden.Pos[2]);
						pack.WriteCell(stage);
						RequestFrames(PlantHasBeenPlanted, DelayFrameDo, pack);
					}
					else
					{
						NoPlantPlanted(client, garden.Pos);
						// No Plant
					}
				}
			}
			
			if(InMenu[client] != -1)
				ShowMenu(client, false);
		}
	}
}

stock void NoPlantPlanted(int client, float pos[3])
{
	/*
	static float m_vecMaxs[3];
	static float m_vecMins[3];
	m_vecMaxs = view_as<float>( { 10.0, 10.0, -5.0 } );
	m_vecMins = view_as<float>( { -10.0, -10.0, 5.0 } );	
	TE_DrawBox(client, pos, m_vecMins, m_vecMaxs, 3.5, view_as<int>({255, 0, 0, 255}));
	*/
	float temp[3];
	temp = pos;
	temp[2] += 5.0;
	TE_SendBeam(client, pos, temp, 3.5, {255, 255, 255, 255}); //it grew abit, make it abit more yellow.
}
stock void PlantHasBeenPlanted(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(client))
	{
		delete pack;
		return;
	}
	float pos[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();
	int stage = pack.ReadCell();
	delete pack;

	float temp[3];
	static float m_vecMaxs[3];
	static float m_vecMins[3];	
	temp = pos; 
	//since this wont ever be rotated, we dont have to bother with rotating this position
	switch(stage)
	{
		case 0: //new sprout!
		{
			temp[2] += 5.0;
			TE_SendBeam(client, pos, temp, 3.5, {0, 255, 0, 255}); //very new plant! we want it to be green.
		}
		case 1: //it grew abit! how cute!
		{
			temp[2] += 15.0;
			TE_SendBeam(client, pos, temp, 3.5, {50, 255, 0, 255}); //it grew abit, make it abit more yellow.
			m_vecMaxs = view_as<float>( { 5.0, 5.0, 10.0 } );
			m_vecMins = view_as<float>( { -5.0, -5.0, 0.0 } );	
			TE_DrawBox(client, temp, m_vecMins, m_vecMaxs, 3.5, view_as<int>({50, 255, 0, 255}));
		}
		case 2: //oh its abit more now!
		{
			temp[2] += 25.0;
			TE_SendBeam(client, pos, temp, 3.5, {100, 255, 0, 255}); //it grew abit, make it abit more yellow.
			m_vecMaxs = view_as<float>( { 10.0, 10.0, 20.0 } );
			m_vecMins = view_as<float>( { -10.0, -10.0, 0.0 } );	
			TE_DrawBox(client, temp, m_vecMins, m_vecMaxs, 3.5, view_as<int>({100, 255, 0, 255}));
		}
		case 3: //grow abit more, almost done!
		{
			temp[2] += 35.0;
			TE_SendBeam(client, pos, temp, 3.5, {150, 255, 0, 255}); //it grew abit, make it abit more yellow.

			m_vecMaxs = view_as<float>( { 15.0, 15.0, 30.0 } );
			m_vecMins = view_as<float>( { -15.0, -15.0, 0.0 } );
			TE_DrawBox(client, temp, m_vecMins, m_vecMaxs, 3.5, view_as<int>({150, 255, 0, 255}));
		}
		case 4: //its done!
		{
			float temp_2[3];
			float temp_3[3];
			temp_2 = pos;
			temp_3 = pos;
			temp[2] += 45.0;
			TE_SendBeam(client, pos, temp, 3.5, {255, 255, 0, 255}); //it grew abit, make it abit more yellow.

			temp_2[2] += 10.0;
			temp_3[2] += 35.0;
			temp_3[1] += 25.0;
			TE_SendBeam(client, temp_2, temp_3, 3.5, {255, 255, 0, 255}); //it grew abit, make it abit more yellow.

			m_vecMaxs = view_as<float>( { 20.0, 20.0, 40.0 } );
			m_vecMins = view_as<float>( { -20.0, -20.0, 0.0 } );
			TE_DrawBox(client, temp, m_vecMins, m_vecMaxs, 3.5, view_as<int>({255, 255, 0, 255}));
		}
	}
}

static void ShowMenu(int client, bool first)
{
	int index = InMenu[client];
	static GardenEnum garden;
	GardenList.GetArray(index, garden);
	
	static char num[16], buffer[64];
	if(garden.ReadyIn[client])
	{
		Menu menu = new Menu(Garden_GrowthHandle);
		
		TextStore_GetItemName(garden.Store[client], buffer, sizeof(buffer));
		menu.SetTitle("RPG Fortress\n \nGarden:\n%s\n ", buffer);
		int totalInt = Stats_Intelligence(client);
		
		int timeleft = RoundToCeil(garden.ReadyIn[client] - GetGameTime());
		if(timeleft > 0)
		{
			Format(buffer, sizeof(buffer), "%d:%02d\n ", timeleft / 60, timeleft % 60);
			menu.AddItem(num, buffer, ITEMDRAW_DISABLED);

			menu.AddItem(num, buffer, ITEMDRAW_SPACER);
		}
		else
		{
			if(totalInt >= 600)
			{
				menu.AddItem(num, "Clean Extract");
			}
			else
			{
				menu.AddItem(num, "Extract");
			}
			
			int count;
			TextStore_GetInv(client, garden.Store[client], count);
			Format(buffer, sizeof(buffer), "And Replant (%d)\n ", count);
			menu.AddItem(num, buffer, count > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		
		menu.AddItem(num, "Cancel");
		
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(first)
	{
		Menu menu = new Menu(Garden_PlantHandle);
		
		menu.SetTitle("RPG Fortress\n \nGarden:");
		
		int amount;
		int length = TextStore_GetItems();
		for(int i; i < length; i++)
		{
			KeyValues kv = TextStore_GetItemKv(i);
			if(kv)
			{
				kv.GetString("seed_result", buffer, sizeof(buffer));
				if(buffer[0])
				{
					TextStore_GetInv(client, i, amount);
					if(amount > 0)
					{
						IntToString(i, num, sizeof(num));
						TextStore_GetItemName(i, buffer, sizeof(buffer));
						Format(buffer, sizeof(buffer), "%s (%d)", buffer, amount);
						menu.AddItem(num, buffer);
					}
				}
			}
		}
		
		if(!menu.ItemCount)
			menu.AddItem(num, "No Seeds to Plant", ITEMDRAW_DISABLED);
		
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	InMenu[client] = index;
}

public int Garden_PlantHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = -1;
		}
		case MenuAction_Select:
		{
			static char buffer[48];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			int index = StringToInt(buffer);
			
			PlantGarden(client, index);
			
			ShowMenu(client, false);
		}
	}
	return 0;
}

static void PlantGarden(int client, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		static char buffer[48];
		kv.GetString("seed_result", buffer, sizeof(buffer));
		if(buffer[0])
		{
			int amount;
			TextStore_GetInv(client, index, amount);
			if(amount > 0)
			{
				static GardenEnum garden;
				GardenList.GetArray(InMenu[client], garden);
				garden.Store[client] = index;
				garden.StartAt[client] = GetGameTime();
				garden.ReadyIn[client] = kv.GetFloat("seed_time", -0.1) + garden.StartAt[client];
				GardenList.SetArray(InMenu[client], garden);
				
				TextStore_SetInv(client, index, amount - 1);
				UpdateTrace[client] = 0.0;

				ClientCommand(client, "playgamesound ui/item_soda_can_drop.wav");
			}
		}
	}
}

public int Garden_GrowthHandle(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = -1;
		}
		case MenuAction_Select:
		{
			static GardenEnum garden;
			GardenList.GetArray(InMenu[client], garden);
			
			if(choice < 2)
			{
				KeyValues kv = TextStore_GetItemKv(garden.Store[client]);
				if(kv)
				{
					float luck = float(Stats_Luck(client));
					int totalInt = Stats_Intelligence(client);
					int loopmax = 1;
					if(totalInt >= 600)
						loopmax = 2;

					for(int loop = 0 ; loop < loopmax; loop++)
					{
						static char buffer[48];
						kv.GetString("seed_result", buffer, sizeof(buffer));
						if(buffer[0])
						{
							float low = kv.GetFloat("seed_min", 1.0);
							float high = kv.GetFloat("seed_max", 1.0);
							float rand = GetURandomFloat() * (1.0 + (luck / 50.0));
							if(rand > 1.0)
								rand = 1.0;
							
							TextStore_AddItemCount(client, buffer, RoundFloat(low + ((high - low) * rand)));
						}
						
						float rand = kv.GetFloat("seed_return");
						if(rand > 0.0)
						{
							rand *= 1.0 + (luck / 100.0);
							if(rand > GetURandomFloat())
							{
								kv.GetSectionName(buffer, sizeof(buffer));
								TextStore_AddItemCount(client, buffer, 1);
							}
						}
					}
				}
			}
			
			garden.ReadyIn[client] = 0.0;
			GardenList.SetArray(InMenu[client], garden);
			UpdateTrace[client] = 0.0;

			if(choice == 1)
			{
				PlantGarden(client, garden.Store[client]);
				ShowMenu(client, false);
				return 0;
			}

			ClientCommand(client, "playgamesound ui/item_soda_can_pickup.wav");
			ShowMenu(client, true);
		}
	}
	return 0;
}

static Handle TimerZoneEditing[MAXPLAYERS];
static char CurrentZoneEditing[MAXPLAYERS][64];

static void OpenEditorFrom(int client)
{
	GardenEnum garden;
	GardenList.GetArray(InMenu[client], garden);

	strcopy(CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]), garden.Zone);
	Garden_EditorMenu(client);
}

void Garden_EditorMenu(int client)
{
	char buffer[PLATFORM_MAX_PATH];

	EditMenu menu = new EditMenu();

	if(CurrentZoneEditing[client][0])
	{
		RPG_BuildPath(buffer, sizeof(buffer), "garden");
		KeyValues kv = new KeyValues("Garden");
		kv.ImportFromFile(buffer);
		bool missing = !kv.JumpToKey(CurrentZoneEditing[client]);

		menu.SetTitle("Gardens\n%s\n ", CurrentZoneEditing[client]);
		
		menu.AddItem("new", "Add Planter Box");

		if(!missing && kv.GotoFirstSubKey(false))
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				menu.AddItem(buffer, buffer);
			}
			while(kv.GotoNextKey(false));
		}

		menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustGarden);
		
		delete kv;

		Zones_RenderZone(client, CurrentZoneEditing[client]);

		delete TimerZoneEditing[client];
		TimerZoneEditing[client] = CreateTimer(1.0, Timer_RefreshHud, client);
	}
	else
	{
		menu.SetTitle("Gardens\nSelect a zone:\n ");

		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, ZonePicker);
	}
}

static Action Timer_RefreshHud(Handle timer, int client)
{
	TimerZoneEditing[client] = null;
	Function func = Editor_MenuFunc(client);
	if(func != AdjustGarden)
		return Plugin_Stop;
	
	Garden_EditorMenu(client);
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
	Garden_EditorMenu(client);
}

static void AdjustGarden(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentZoneEditing[client][0] = 0;
		Garden_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "garden");
	KeyValues kv = new KeyValues("Garden");
	kv.ImportFromFile(filepath);
	kv.JumpToKey(CurrentZoneEditing[client], true);

	if(StrEqual(key, "new"))
	{
		char buffer[64];
		float pos[3];
		GetClientAbsOrigin(client, pos);
		FormatEx(buffer, sizeof(buffer), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
		kv.SetString(buffer, "1");
	}
	else if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentZoneEditing[client][0] = 0;
	}
	else
	{
		kv.DeleteKey(key);
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Garden_ConfigSetup();
	Zones_Rebuild();
	Garden_EditorMenu(client);
}
