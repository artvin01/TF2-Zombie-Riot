#pragma semicolon 1
#pragma newdecls required

enum struct CraftEnum
{
	char Zone[32];
	ArrayList List;

	char Model[PLATFORM_MAX_PATH];
	float Pos[3];
	float Ang[3];
	float Scale;

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
		this.Scale = kv.GetFloat("scale", 1.0);
		kv.GetString("model", this.Model, sizeof(this.Model));
		kv.GetString("zone", this.Zone, sizeof(this.Zone));
		if(!this.Model[0])
			strcopy(this.Model, sizeof(this.Model), "error.mdl");
		
		PrecacheModel(this.Model);
	}
	
	void Despawn()
	{
		if(this.EntRef != -1)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
				RemoveEntity(entity);
						
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
				DispatchKeyValueFloat(entity, "modelscale", this.Scale);
				DispatchKeyValue(entity, "solid", "6");
				SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
				SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);				
				DispatchSpawn(entity);
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR, true);

				b_is_a_brush[entity] = true;
				b_BrushToOwner[entity] = EntIndexToEntRef(entity);

				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

static ArrayList CraftList;
static StringMap BluePrints;
static int CurrentMenu[MAXTF2PLAYERS];
static int CurrentPrint[MAXTF2PLAYERS];
static char CurrentRecipe[MAXTF2PLAYERS][64];

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
			CurrentMenu[client] = i;
			CurrentPrint[client] = -1;
			CraftMenu(client);
			return true;
		}
	}

	return false;
}

static void CraftMenu(int client)
{
	static CraftEnum craft;
	CraftList.GetArray(CurrentMenu[client], craft);

	if(CurrentRecipe[client][0])
	{
		craft.List.GetString(CurrentPrint[client], craft.Model, sizeof(craft.Model));

		StringMap map;
		BluePrints.GetValue(craft.Model, map);
		map.GetValue(CurrentRecipe[client], map);
		StringMapSnapshot snap = map.Snapshot();

		bool failed, failed5;
		int amount;
		char cost[128], result[128];
		strcopy(cost, sizeof(cost), "Cost:");
		strcopy(result, sizeof(result), "Result:");

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, craft.Model, sizeof(craft.Model));
			map.GetValue(craft.Model, amount);

			if(amount > 0)
			{
				int count = TextStore_GetItemCount(client, craft.Model);
				if(count < amount)
					failed = true;
				
				if(count < (amount * 5))
					failed5 = true;
				
				Format(cost, sizeof(cost), "%s\n%s (%d / %d)", cost, craft.Model, count, amount);
			}
			else if(amount < 0)
			{
				int count = TextStore_GetItemCount(client, craft.Model);
				Format(result, sizeof(result), "%s\n%s (%d -> %d)", result, craft.Model, count, count - amount);
			}
			else
			{
				int count = TextStore_GetItemCount(client, craft.Model);
				if(count < 1)
					failed = true;
				
				Format(cost, sizeof(cost), "%s\n%s [TOOL%s]", cost, craft.Model, count < 1 ? " MISSING" : "");
			}
		}

		delete snap;

		Menu menu = new Menu(CraftRecipe);
		menu.SetTitle("RPG Fortress\n \nCrafting: %s\n \n%s\n \n%s\n ", CurrentRecipe[client], cost, result);

		menu.AddItem("1", "Craft x1", failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("5", "Craft x5", failed5 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(CurrentPrint[client] != -1)
	{
		craft.List.GetString(CurrentPrint[client], craft.Model, sizeof(craft.Model));

		StringMap map;
		BluePrints.GetValue(craft.Model, map);
		StringMapSnapshot snap = map.Snapshot();

		Menu menu = new Menu(SelectRecipe);
		menu.SetTitle("RPG Fortress\n \nCrafting: %s\n ", craft.Model);

		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, craft.Model, sizeof(craft.Model));
			menu.AddItem(craft.Model, craft.Model);
		}

		delete snap;

		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(SelectBlueprint);
		menu.SetTitle("RPG Fortress\n \nCrafting\n ");

		int length = craft.List.Length;
		for(int i; i < length; i++)
		{
			craft.List.GetString(i, craft.Model, sizeof(craft.Model));
			menu.AddItem(craft.Model, craft.Model);
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
		case MenuAction_Cancel:
		{
			CurrentMenu[client] = -1;
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
			else
			{
				CurrentMenu[client] = -1;
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
				CurrentMenu[client] = -1;
			}
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int multi = StringToInt(buffer);
			
			static CraftEnum craft;
			CraftList.GetArray(CurrentMenu[client], craft);
			craft.List.GetString(CurrentPrint[client], craft.Model, sizeof(craft.Model));

			StringMap map;
			BluePrints.GetValue(craft.Model, map);
			map.GetValue(CurrentRecipe[client], map);
			StringMapSnapshot snap = map.Snapshot();

			bool failed;
			int amount;

			int length = snap.Length;
			for(int i; i < length; i++)
			{
				snap.GetKey(i, craft.Model, sizeof(craft.Model));
				map.GetValue(craft.Model, amount);

				if(amount > 0)
				{
					int count = TextStore_GetItemCount(client, craft.Model);
					if(count < (amount * multi))
					{
						failed = true;
						break;
					}
				}
				else if(amount == 0)
				{
					int count = TextStore_GetItemCount(client, craft.Model);
					if(count < 1)
					{
						failed = true;
						break;
					}
				}
			}

			if(!failed)
			{
				for(int i; i < length; i++)
				{
					snap.GetKey(i, craft.Model, sizeof(craft.Model));
					map.GetValue(craft.Model, amount);

					if(amount)
						TextStore_AddItemCount(client, craft.Model, -(amount * multi));
				}
			}

			delete snap;
			CraftMenu(client);
		}
	}
	return 0;
}
