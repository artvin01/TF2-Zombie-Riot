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
	
	if(BluePrints)
	{
		StringMapSnapshot snap = BluePrints.Snapshot();

		delete snap;
	}

	CraftEnum craft;
	
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

	CraftList = new ArrayList(sizeof(CraftEnum));
	
	RPG_BuildPath(buffer, sizeof(buffer), "crafting");
	KeyValues kv = new KeyValues("Crafting");
	kv.ImportFromFile(buffer);

	if(kv.GotoFirstSubKey())
	{
		craft.EntRef = -1;

		do
		{
			craft.SetupKV(kv);
			CraftList.PushArray(craft);
		}
		while(kv.GotoNextKey());
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

	Menu menu = new Menu(CraftMenuH);

	int length = craft.List;
	for(int i; i < length; i++)
	{
		craft.List.GetString(craft.Model, sizeof(craft.Model));
		menu.AddItem(craft.Model, craft.Model);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int CraftMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			
			i_TransformationSelected[client] = StringToInt(num) + 1;

			ShowMenu(client);
		}
	}
	return 0;
}