#pragma semicolon 1
#pragma newdecls required

enum struct CraftEnum
{
	char Zone[32];
	ArrayList List;

	char Model[PLATFORM_MAX_PATH];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];
	char QuestReq[PLATFORM_MAX_PATH];
	float AxisOffset[3];

	int EntRef;

	void SetupKV(KeyValues kv)
	{
		kv.GetSectionName(this.Model, sizeof(this.Model));
		ExplodeStringFloat(this.Model, " ", this.Pos, sizeof(this.Pos));

		this.List = new ArrayList(ByteCountToCells(64));
		if(kv.JumpToKey("Blueprints"))
		{
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetSectionName(this.Model, sizeof(this.Model));
					this.List.PushString(this.Model);
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}

			kv.GoBack();
		}

		kv.GetVector("ang", this.Ang);
		kv.GetVector("axis_offset", this.AxisOffset);
		kv.GetString("anim_idle", this.Idle, 64);
		this.Scale = kv.GetFloat("scale", 1.0);
		kv.GetString("model", this.Model, sizeof(this.Model));
		kv.GetString("zone", this.Zone, sizeof(this.Zone));
		if(!this.Model[0])
			strcopy(this.Model, sizeof(this.Model), "error.mdl");
		
		PrecacheModel(this.Model);
		
		kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
		if(this.Wear1[0])
			PrecacheModel(this.Wear1);
		
		kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
		if(this.Wear2[0])
			PrecacheModel(this.Wear2);
		
		kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
		if(this.Wear3[0])
			PrecacheModel(this.Wear3);
			
		kv.GetString("quest", this.QuestReq, PLATFORM_MAX_PATH);
	}
	
	void Despawn()
	{
		if(this.EntRef != -1)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
			{
				int brush = EntRefToEntIndex(b_OwnerToBrush[entity]);
				if(brush != -1)
					RemoveEntity(brush);
				
				RemoveEntity(entity);
			}

			this.EntRef = -1;
		}
	}
	
	void Spawn()
	{
		if(EntRefToEntIndex(this.EntRef) == -1)
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				//DispatchKeyValueFloat(entity, "modelscale", this.Scale);
				//DispatchKeyValue(entity, "solid", "2");
				SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
				SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);				
				DispatchSpawn(entity);
				float PosChange[3];
				PosChange = this.Pos;

				TeleportEntity(entity, PosChange, this.Ang, NULL_VECTOR, true);

				SetEntityCollisionGroup(entity, 2);

				int brush = SpawnSeperateCollisionBox(entity);
				PosChange[0] += this.AxisOffset[0];
				PosChange[1] += this.AxisOffset[1];
				PosChange[2] += this.AxisOffset[2];
				TeleportEntity(entity, PosChange, NULL_VECTOR, NULL_VECTOR, true);
				//Just reuse it.
				b_BrushToOwner[brush] = EntIndexToEntRef(entity);
				b_OwnerToBrush[entity] = EntIndexToEntRef(brush);
				
				if(this.Wear1[0])
					GivePropAttachment(entity, this.Wear1);
				
				if(this.Wear2[0])
					GivePropAttachment(entity, this.Wear2);
				
				if(this.Wear3[0])
					GivePropAttachment(entity, this.Wear3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetAnimation", entity, entity);

				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static ArrayList CraftList;
static StringMap BluePrints;
static bool CurrentCustom[MAXPLAYERS];
static ArrayList CurrentMenu[MAXPLAYERS];
static int CurrentPrint[MAXPLAYERS];
static char CurrentRecipe[MAXPLAYERS][64];

void Crafting_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	StringMap map1, map2;
	CraftEnum craft;

	if(BluePrints)
	{
		StringMapSnapshot snap1 = BluePrints.Snapshot();
		int length1 = snap1.Length;
		for(int a; a < length1; a++)
		{
			snap1.GetKey(a, buffer, sizeof(buffer));
			BluePrints.GetValue(buffer, map1);

			StringMapSnapshot snap2 = map1.Snapshot();
			int length2 = snap2.Length;
			for(int b; b < length2; b++)
			{
				snap2.GetKey(b, buffer, sizeof(buffer));
				map1.GetValue(buffer, map2);
				delete map2;
			}

			delete snap2;
			delete map1;
		}

		delete snap1;
		delete BluePrints;
	}
	
	if(CraftList)
	{
		int length = CraftList.Length;
		for(int i; i < length; i++)
		{
			CraftList.GetArray(i, craft);
			delete craft.List;
		}
		delete CraftList;
	}

	BluePrints = new StringMap();
	CraftList = new ArrayList(sizeof(CraftEnum));
	
	RPG_BuildPath(buffer, sizeof(buffer), "crafting");
	KeyValues kv = new KeyValues("Crafting");
	kv.ImportFromFile(buffer);

	if(kv.JumpToKey("Tables"))
	{
		if(kv.GotoFirstSubKey())
		{
			craft.EntRef = -1;

			do
			{
				craft.SetupKV(kv);
				CraftList.PushArray(craft);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	if(kv.JumpToKey("Blueprints"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				map1 = new StringMap();

				if(kv.GotoFirstSubKey())
				{
					do
					{
						map2 = new StringMap();

						if(kv.GotoFirstSubKey(false))
						{
							do
							{
								kv.GetSectionName(buffer, sizeof(buffer));
								map2.SetValue(buffer, kv.GetNum(NULL_STRING));	// Item
							}
							while(kv.GotoNextKey(false));

							kv.GoBack();
						}

						kv.GetSectionName(buffer, sizeof(buffer));
						map1.SetValue(buffer, map2);	// Recipe
					}
					while(kv.GotoNextKey());

					kv.GoBack();
				}

				kv.GetSectionName(buffer, sizeof(buffer));
				BluePrints.SetValue(buffer, map1);	// Blueprint
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	delete kv;
}

bool Crafting_LookAtTable(int client)
{
	int entity = GetClientPointVisible(client);
	if(entity > 0 && b_is_a_brush[entity])
	{
		entity = BrushToEntity(entity);
		if(entity != -1)
		{
			int ref = EntIndexToEntRef(entity);
			int length = CraftList.Length;
			for(int i; i < length; i++)
			{
				static CraftEnum craft;
				CraftList.GetArray(i, craft);
				if(craft.EntRef == ref)
					return true;
			}
		}
	}

	return false;
}

void Crafting_EnableZone(const char[] zone)
{
	if(CraftList)
	{
		static CraftEnum craft;
		int length = CraftList.Length;
		for(int i; i < length; i++)
		{
			CraftList.GetArray(i, craft);
			if(StrEqual(craft.Zone, zone))
			{
				craft.Spawn();
				CraftList.SetArray(i, craft);
			}
		}
	}
}

void Crafting_DisableZone(const char[] zone)
{
	if(CraftList)
	{
		static CraftEnum craft;
		int length = CraftList.Length;
		for(int i; i < length; i++)
		{
			CraftList.GetArray(i, craft);
			if(StrEqual(craft.Zone, zone))
			{
				craft.Despawn();
				CraftList.SetArray(i, craft);
			}
		}
	}
}

bool Crafting_Interact(int client, int entity)
{
	int ref = EntIndexToEntRef(entity);
	int length = CraftList.Length;
	for(int i; i < length; i++)
	{
		static CraftEnum craft;
		CraftList.GetArray(i, craft);
		if(craft.EntRef == ref)
		{
			if(Editor_MenuFunc(client) != INVALID_FUNCTION)
			{
				OpenEditorFrom(client, craft);
				return true;
			}
			if(client <= MaxClients && craft.QuestReq[0] && Quests_GetStatus(client, craft.QuestReq) != Status_Completed)
			{
				ShowGameText(client, _, 0, "You need to complete \"%s\" quest to interact.", craft.QuestReq);
				return false;
			}

			if(CurrentCustom[client])
			{
				delete CurrentMenu[client];
				CurrentCustom[client] = false;
			}
			
			CurrentMenu[client] = craft.List;
			CurrentPrint[client] = -1;
			CurrentRecipe[client][0] = 0;
			CraftMenu(client);
			return true;
		}
	}

	return false;
}

void Crafting_SetCustomMenu(int client, ArrayList list)
{
	if(CurrentCustom[client])
	{
		delete CurrentMenu[client];
		CurrentCustom[client] = false;
	}
	
	CurrentCustom[client] = true;
	CurrentMenu[client] = list;
	CurrentPrint[client] = -1;
	CurrentRecipe[client][0] = 0;
	CraftMenu(client);
}

static void CraftMenu(int client)
{
	char buffer[64];
	if(CurrentRecipe[client][0])
	{
		CurrentMenu[client].GetString(CurrentPrint[client], buffer, sizeof(buffer));

		StringMap map;
		BluePrints.GetValue(buffer, map);
		map.GetValue(CurrentRecipe[client], map);
		StringMapSnapshot snap = map.Snapshot();

		bool nonMoney, failed, failed5, failed10;
		int amount;
		char cost[384], result[64];
		strcopy(cost, sizeof(cost), "Cost:");
		strcopy(result, sizeof(result), "Result:");

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, buffer, sizeof(buffer));
			map.GetValue(buffer, amount);

			if(amount > 0)
			{
				int count = TextStore_GetItemCount(client, buffer);
				if(count < amount)
					failed = true;
				
				if(count < (amount * 5))
					failed5 = true;
				
				if(count < (amount * 10))
					failed10 = true;
				
				if(!nonMoney && !StrEqual(buffer, ITEM_CASH, false))
					nonMoney = true;

				Format(cost, sizeof(cost), "%s\n%s (%d / %d)", cost, buffer, count, amount);
			}
			else if(amount < 0)
			{
				int count = TextStore_GetItemCount(client, buffer);
				Format(result, sizeof(result), "%s\n%s (%d -> %d)", result, buffer, count, count - amount);
			}
			else
			{
				int count = TextStore_GetItemCount(client, buffer);
				if(count < 1)
					failed = true;
				
				Format(cost, sizeof(cost), "%s\n%s [TOOL%s]", cost, buffer, count < 1 ? " MISSING" : "");
			}
		}

		delete snap;

		Menu menu = new Menu(CraftRecipe);
	//	menu.SetTitle("RPG Fortress\n \nCraft & Shop: %s\n \n%s\n \n%s\n ", CurrentRecipe[client], cost, result);
		if(nonMoney)
			menu.SetTitle("RPG Fortress\n \nCraft: \n%s\n \n%s\nCraft:\n", cost, result);
		else
			menu.SetTitle("RPG Fortress\n \nShop: \n%s\n \n%s\nBuy:\n", cost, result);

		menu.AddItem("1", "x1", failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("5", "x5", failed5 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("10", "x10", failed10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(CurrentPrint[client] != -1)
	{
		CurrentMenu[client].GetString(CurrentPrint[client], buffer, sizeof(buffer));

		StringMap map;
		BluePrints.GetValue(buffer, map);
		StringMapSnapshot snap = map.Snapshot();

		Menu menu = new Menu(SelectRecipe);
		menu.SetTitle("RPG Fortress\n \nCraft & Shop: %s\n ", buffer);

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, buffer, sizeof(buffer));
			menu.AddItem(buffer, buffer);
		}

		delete snap;

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(SelectBlueprint);
		menu.SetTitle("RPG Fortress\n \nCraft & Shop\n ");

		int length = CurrentMenu[client].Length;
		for(int i; i < length; i++)
		{
			CurrentMenu[client].GetString(i, buffer, sizeof(buffer));
			menu.AddItem(buffer, buffer);
		}

		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static int SelectBlueprint(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			CurrentPrint[client] = choice;
			CraftMenu(client);
		}
	}
	return 0;
}

static int SelectRecipe(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			CurrentPrint[client] = -1;

			if(choice == MenuCancel_ExitBack)
			{
				CraftMenu(client);
			}
		}
		case MenuAction_Select:
		{
			menu.GetItem(choice, CurrentRecipe[client], sizeof(CurrentRecipe[]));
			CraftMenu(client);
		}
	}
	return 0;
}

static int CraftRecipe(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			CurrentRecipe[client][0] = 0;

			if(choice == MenuCancel_ExitBack)
			{
				CraftMenu(client);
			}
			else
			{
				CurrentPrint[client] = -1;
			}
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int multi = StringToInt(buffer);
			
			CurrentMenu[client].GetString(CurrentPrint[client], buffer, sizeof(buffer));

			StringMap map;
			BluePrints.GetValue(buffer, map);
			map.GetValue(CurrentRecipe[client], map);
			StringMapSnapshot snap = map.Snapshot();

			bool failed;
			int amount;

			int length = snap.Length;
			for(int i; i < length; i++)
			{
				snap.GetKey(i, buffer, sizeof(buffer));
				map.GetValue(buffer, amount);

				if(amount > 0)
				{
					int count = TextStore_GetItemCount(client, buffer);
					if(count < (amount * multi))
					{
						failed = true;
						break;
					}
				}
				else if(amount == 0)
				{
					int count = TextStore_GetItemCount(client, buffer);
					if(count < 1)
					{
						failed = true;
						break;
					}
				}
			}

			if(!failed)
			{
				ClientCommand(client, "playgamesound mvm/mvm_money_pickup.wav");
				
				for(int i; i < length; i++)
				{
					snap.GetKey(i, buffer, sizeof(buffer));
					map.GetValue(buffer, amount);

					if(amount)
						TextStore_AddItemCount(client, buffer, -(amount * multi), true);
				}
			}

			delete snap;
			CraftMenu(client);
		}
	}
	return 0;
}

static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentRecipeEditing[MAXPLAYERS][64];
static char CurrentSectionEditing[MAXPLAYERS][64];
static int CurrentMenuEditing[MAXPLAYERS];

static void OpenEditorFrom(int client, const CraftEnum craft)
{
	CurrentMenuEditing[client] = 1;
	strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), craft.Zone);
	CurrentRecipeEditing[client][0] = 0;
	CurrentKeyEditing[client][0] = 0;
	Crafting_EditorMenu(client);
}

void Crafting_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];

	EditMenu menu = new EditMenu();

	switch(CurrentMenuEditing[client])
	{
		case 1:	// Crafting Tables
		{
			if(StrEqual(CurrentKeyEditing[client], "zone"))
			{
				menu.SetTitle("Crafting\nCrafting Tables - %s\n ", CurrentRecipeEditing[client]);
				
				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("", buffer1);

				Zones_GenerateZoneList(client, menu);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustTableKey);
			}
			else if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Crafting\nCrafting Tables - %s\n ", CurrentRecipeEditing[client]);
				
				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("", buffer1);

				menu.AddItem("", "Set To Default");

				menu.ExitBackButton = true;
				menu.Display(client, AdjustTableKey);
			}
			else if(CurrentRecipeEditing[client][0])
			{
				menu.SetTitle("Crafting\nCrafting Tables - %s\nClick to set it's value:\n ", CurrentRecipeEditing[client]);
				
				RPG_BuildPath(buffer1, sizeof(buffer1), "crafting");
				KeyValues kv = new KeyValues("Crafting");
				kv.ImportFromFile(buffer1);
				kv.JumpToKey("Tables");
				bool missing = !kv.JumpToKey(CurrentRecipeEditing[client]);

				if(!missing && kv.JumpToKey("Blueprints"))
				{
					if(kv.GotoFirstSubKey(false))
					{
						do
						{
							kv.GetSectionName(buffer1, sizeof(buffer1));
							if(BluePrints.ContainsKey(buffer1))
							{
								strcopy(buffer2, sizeof(buffer2), buffer1);
							}
							else
							{
								FormatEx(buffer2, sizeof(buffer2), "%s {WARNING: Blueprint does not exist}", buffer1);
							}

							menu.AddItem(buffer1, buffer2);
						}
						while(kv.GotoNextKey(false));

						kv.GoBack();
					}

					kv.GoBack();
				}

				menu.AddItem("0", "Type to add a blueprint", ITEMDRAW_DISABLED);

				FormatEx(buffer2, sizeof(buffer2), "Position: %s", CurrentRecipeEditing[client]);
				menu.AddItem("_pos", buffer2);
				
				float vec[3];
				kv.GetVector("ang", vec);
				FormatEx(buffer2, sizeof(buffer2), "Angle: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
				menu.AddItem("_ang", buffer2);

				kv.GetVector("axis_offset", vec);
				FormatEx(buffer2, sizeof(buffer2), "Axis Offset MDL: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
				menu.AddItem("_axis_offset", buffer2);

				kv.GetString("zone", buffer1, sizeof(buffer1), missing ? CurrentSectionEditing[client] : "");
				FormatEx(buffer2, sizeof(buffer2), "Zone: \"%s\"", buffer1);
				menu.AddItem("_zone", buffer2);

				kv.GetString("anim_idle", buffer1, sizeof(buffer1));
				FormatEx(buffer2, sizeof(buffer2), "Animation: \"%s\"", buffer1);
				menu.AddItem("_anim_idle", buffer2);

				kv.GetString("model", buffer1, sizeof(buffer1), "error.mdl");
				FormatEx(buffer2, sizeof(buffer2), "Model: \"%s\"%s", buffer1, FileExists(buffer1, true) ? "" : " {WARNING: Model does not exist}");
				menu.AddItem("_model", buffer2);

				kv.GetString("wear1", buffer1, sizeof(buffer1));
				FormatEx(buffer2, sizeof(buffer2), "Cosmetic 1: \"%s\"%s", buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
				menu.AddItem("_wear1", buffer2);

				kv.GetString("wear2", buffer1, sizeof(buffer1));
				FormatEx(buffer2, sizeof(buffer2), "Cosmetic 2: \"%s\"%s", buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
				menu.AddItem("_wear2", buffer2);

				kv.GetString("wear3", buffer1, sizeof(buffer1));
				FormatEx(buffer2, sizeof(buffer2), "Cosmetic 3: \"%s\"%s",buffer1, (!buffer1[0] || FileExists(buffer1, true)) ? "" : " {WARNING: Model does not exist}");
				menu.AddItem("_wear3", buffer2);

				
				kv.GetString("quest", buffer2, sizeof(buffer2));
				if(buffer2[0] && !Quests_KV().JumpToKey(buffer2))
				{
					Format(buffer2, sizeof(buffer2), "Quest Key: \"%s\" {WARNING: Quest does not exist}", buffer2);
				}
				else
				{
					Format(buffer2, sizeof(buffer2), "Quest Key: \"%s\"", buffer2);
				}
				menu.AddItem("_quest", buffer2);

				menu.AddItem("_delete", "Delete (Type \"_delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustTable);
				
				delete kv;
			}
			else if(CurrentSectionEditing[client][0])
			{
				menu.SetTitle("Crafting\nCrafting Tables - %s\nSelect a table:\n ", CurrentSectionEditing[client]);

				RPG_BuildPath(buffer1, sizeof(buffer1), "crafting");
				KeyValues kv = new KeyValues("Crafting");
				kv.ImportFromFile(buffer1);
				
				menu.AddItem("", "Create New Table");
				
				if(kv.JumpToKey("Tables") && kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetString("zone", buffer1, sizeof(buffer1));
						if(strlen(CurrentSectionEditing[client]) < 2 || StrEqual(buffer1, CurrentSectionEditing[client]))
						{
							kv.GetSectionName(buffer1, sizeof(buffer1));
							menu.AddItem(buffer1, buffer1);
						}
					}
					while(kv.GotoNextKey());
				}

				menu.ExitBackButton = true;
				menu.Display(client, TablePicker);

				delete kv;
			}
			else
			{
				menu.SetTitle("Crafting\nCrafting Tables\nSelect a zone:\n ");

				menu.AddItem(" ", "All Zones");

				Zones_GenerateZoneList(client, menu);

				menu.ExitBackButton = true;
				menu.Display(client, SectionPicker);
			}
		}
		case 2:	// Blueprints
		{
			if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Crafting\nBlueprints - %s - %s\nClick to set it's value:\n ", CurrentSectionEditing[client], CurrentRecipeEditing[client]);
				
				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

				menu.AddItem("", "(>0 Cost, <0 Gain, =0 Tool)", ITEMDRAW_DISABLED);

				menu.AddItem("", "Remove Item");

				menu.ExitBackButton = true;
				menu.Display(client, AdjustRecipeKey);
			}
			else if(CurrentRecipeEditing[client][0])
			{
				menu.SetTitle("Crafting\nBlueprints - %s - %s\nClick to set it's value:\n ", CurrentSectionEditing[client], CurrentRecipeEditing[client]);
				
				RPG_BuildPath(buffer1, sizeof(buffer1), "crafting");
				KeyValues kv = new KeyValues("Crafting");
				kv.ImportFromFile(buffer1);

				menu.AddItem("", "Type to add an new item", ITEMDRAW_DISABLED);
				
				if(kv.JumpToKey("Blueprints") && kv.JumpToKey(CurrentSectionEditing[client]) && kv.JumpToKey(CurrentRecipeEditing[client]) && kv.GotoFirstSubKey(false))
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						int amount = kv.GetNum(NULL_STRING);
						if(amount > 0)
						{
							FormatEx(buffer2, sizeof(buffer2), "%s (Cost x%d)", buffer1, amount);
						}
						else if(amount < 0)
						{
							FormatEx(buffer2, sizeof(buffer2), "%s (Gain x%d)", buffer1, -amount);
						}
						else
						{
							FormatEx(buffer2, sizeof(buffer2), "%s (Tool)", buffer1);
						}
						
						menu.AddItem(buffer1, buffer2);
					}
					while(kv.GotoNextKey(false));
				}

				menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustRecipe);
				
				delete kv;
			}
			else if(CurrentSectionEditing[client][0])
			{
				menu.SetTitle("Crafting\nBlueprints - %s\nSelect a recipe:\n ", CurrentSectionEditing[client]);

				RPG_BuildPath(buffer1, sizeof(buffer1), "crafting");
				KeyValues kv = new KeyValues("Crafting");
				kv.ImportFromFile(buffer1);
				
				menu.AddItem("", "Type to create a new recipe", ITEMDRAW_DISABLED);
				
				if(kv.JumpToKey("Blueprints") && kv.JumpToKey(CurrentSectionEditing[client]) && kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						menu.AddItem(buffer1, buffer1);
					}
					while(kv.GotoNextKey());
				}

				menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, RecipePicker);

				delete kv;
			}
			else
			{
				menu.SetTitle("Crafting\nBlueprints\nSelect a blueprint:\n ");

				RPG_BuildPath(buffer1, sizeof(buffer1), "crafting");
				KeyValues kv = new KeyValues("Crafting");
				kv.ImportFromFile(buffer1);
				
				menu.AddItem("", "Type to create a new blueprint", ITEMDRAW_DISABLED);
				
				if(kv.JumpToKey("Blueprints") && kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						menu.AddItem(buffer1, buffer1);
					}
					while(kv.GotoNextKey());
				}

				menu.ExitBackButton = true;
				menu.Display(client, SectionPicker);

				delete kv;
			}
		}
		default:
		{
			menu.SetTitle("Crafting\n ");

			menu.AddItem("2", "Blueprints");
			menu.AddItem("1", "Crafting Tables");

			menu.ExitBackButton = true;
			menu.Display(client, MenuPicker);
		}
	}
}

static void MenuPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	CurrentMenuEditing[client] = StringToInt(key);
	Crafting_EditorMenu(client);
}

static void SectionPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentMenuEditing[client] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), key);
	Crafting_EditorMenu(client);
}

static void RecipePicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	if(StrEqual(key, "delete"))
	{
		char filepath[PLATFORM_MAX_PATH];
		RPG_BuildPath(filepath, sizeof(filepath), "crafting");
		KeyValues kv = new KeyValues("Crafting");
		kv.ImportFromFile(filepath);
		if(kv.JumpToKey("Blueprints"))
		{
			kv.DeleteKey(CurrentSectionEditing[client]);
			kv.Rewind();
			kv.ExportToFile(filepath);
		}

		delete kv;
		CurrentSectionEditing[client][0] = 0;
	}
	else
	{
		strcopy(CurrentRecipeEditing[client], sizeof(CurrentRecipeEditing[]), key);
	}

	Crafting_EditorMenu(client);
}

static void AdjustRecipe(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentRecipeEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	if(StrEqual(key, "delete"))
	{
		char filepath[PLATFORM_MAX_PATH];
		RPG_BuildPath(filepath, sizeof(filepath), "crafting");
		KeyValues kv = new KeyValues("Crafting");
		kv.ImportFromFile(filepath);
		if(kv.JumpToKey("Blueprints") && kv.JumpToKey(CurrentSectionEditing[client]))
		{
			kv.DeleteKey(CurrentRecipeEditing[client]);
			kv.Rewind();
			kv.ExportToFile(filepath);
			ReloadKv();
		}

		delete kv;
		CurrentRecipeEditing[client][0] = 0;
	}
	else
	{
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
	}
	
	Crafting_EditorMenu(client);
}

static void AdjustRecipeKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "crafting");
	KeyValues kv = new KeyValues("Crafting");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Blueprints", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);
	kv.JumpToKey(CurrentRecipeEditing[client], true);

	if(key[0])
	{
		kv.SetNum(CurrentKeyEditing[client], StringToInt(key));
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	ReloadKv();
	Crafting_EditorMenu(client);
}

static void TablePicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	if(key[0])
	{
		strcopy(CurrentRecipeEditing[client], sizeof(CurrentRecipeEditing[]), key);
	}
	else
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		FormatEx(CurrentRecipeEditing[client], sizeof(CurrentRecipeEditing[]), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
	}

	Crafting_EditorMenu(client);
}

static void AdjustTable(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentRecipeEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "crafting");
	KeyValues kv = new KeyValues("Crafting");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Tables", true);
	
	if(!kv.JumpToKey(CurrentRecipeEditing[client]))
	{
		kv.JumpToKey(CurrentRecipeEditing[client], true);
		kv.SetString("zone", CurrentSectionEditing[client]);
	}

	if(StrEqual(key, "_pos"))
	{
		char buffer[64];
		float pos[3];
		GetClientAbsOrigin(client, pos);
		FormatEx(buffer, sizeof(buffer), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
		kv.SetSectionName(buffer);
		strcopy(CurrentRecipeEditing[client], sizeof(CurrentRecipeEditing[]), buffer);
	}
	else if(StrEqual(key, "_ang"))
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		ang[0] = 0.0;
		ang[2] = 0.0;
		kv.SetVector("ang", ang);
	}
	else if(StrEqual(key, "_delete"))
	{
		kv.DeleteThis();
		CurrentRecipeEditing[client][0] = 0;
	}
	else if(key[0] == '_')
	{
		delete kv;
		
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key[1]);
		Crafting_EditorMenu(client);
		return;
	}
	else
	{
		kv.JumpToKey("Blueprints", true);

		if(kv.GetNum(key))
		{
			kv.DeleteKey(key);
		}
		else
		{
			kv.SetNum(key, 1);
		}
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	ReloadKv();
	Crafting_EditorMenu(client);
}

static void AdjustTableKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Crafting_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "crafting");
	KeyValues kv = new KeyValues("Crafting");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Tables", true);
	kv.JumpToKey(CurrentRecipeEditing[client], true);

	if(key[0])
	{
		kv.SetString(CurrentKeyEditing[client], key);
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	ReloadKv();
	Crafting_EditorMenu(client);
}

static void ReloadKv()
{
	static CraftEnum craft;
	int length = CraftList.Length;
	for(int i; i < length; i++)
	{
		CraftList.GetArray(i, craft);
		craft.Despawn();
	}

	Crafting_ConfigSetup();
	Zones_Rebuild();
}