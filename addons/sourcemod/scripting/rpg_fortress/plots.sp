#pragma semicolon 1
#pragma newdecls required

enum struct BlockEnum
{
	char Item[48];
	int Space;

	char Model[PLATFORM_MAX_PATH];
	char Skin[4];

	int Rotate;
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Item, 48);

		kv.GetString("model", this.Model, PLATFORM_MAX_PATH, "models/error.mdl");
		if(!this.Model[0])
			SetFailState("Missing model in plots.cfg");
		
		kv.GetString("skin", this.Skin, 4, "0");
		this.Rotate = kv.GetNum("rotate");
		this.Space = kv.GetNum("space", 1);
	}
	
	int Spawn(const float pos[3], float ang[3], bool fake)
	{
		int entity = CreateEntityByName("prop_dynamic_override");
		if(entity != -1)
		{
			DispatchKeyValue(entity, "targetname", "rpg_fortress");
			DispatchKeyValue(entity, "model", this.Model);
			DispatchKeyValue(entity, "skin", this.Skin);
			DispatchKeyValue(entity, "solid", "6");
			SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);
			DispatchSpawn(entity);

			for(int i; i < 3; i++)
			{
				if(i == 1)
				{
					if(this.Rotate == 1)
					{
						ang[i] = (RoundToNearest(ang[i] / 90.0) * 90.0) + 180.0;
					}
					else if(this.Rotate > 1)
					{
						ang[i] = (RoundToNearest(ang[i] / 90.0) * 90.0);
					}
					else
					{
						ang[i] = -90.0;
					}
				}
				else if(this.Rotate > 1)
				{
					ang[i] = (RoundToNearest(ang[i] / 90.0) * 90.0) + 180.0;
				}
			}
			
			TeleportEntity(entity, pos, ang, NULL_VECTOR, true);
		}
		return entity;
	}
}

enum struct BuildEnum
{
	int Owner;
	char Item[48];

	int Pos[3];
	int Ang[3];

	int EntRef;

	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Item, 48);
		ExplodeStringInt(this.Item, " ", this.Pos, 3);

		kv.GetString("ang", this.Item, 48);
		ExplodeStringInt(this.Item, " ", this.Ang, 3);

		kv.GetString("name", this.Item, 48);
	}
	void AddEntry(KeyValues kv)
	{
		static char buffer[48];
		Format(buffer, sizeof(buffer), "%d %d %d", this.Pos[0], this.Pos[1], this.Pos[2]);
		kv.JumpToKey(buffer, true);

		Format(buffer, sizeof(buffer), "%d %d %d", this.Ang[0], this.Ang[1], this.Ang[2]);
		kv.SetString("ang", buffer);

		kv.SetString("name", this.Item);

		kv.GoBack();
	}
}

enum
{
	Build_None = 0,
	Build_Interact,
	Build_All
}

static ArrayList BlockList;
static StringMap PlotOwner;
static ArrayList BuildList;
static char BlockZone[32];
static int MaxBlocks;
static int MaxRange;
static float BlockDistance;
static int CurrentEdicts;

static char InPlot[MAXENTITIES+1][32];
static bool InMenu[MAXTF2PLAYERS];
static char CurrentItem[MAXTF2PLAYERS][32];
static int PartyMode[MAXTF2PLAYERS];

void Plots_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Plots"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "plots");
		kv = new KeyValues("Plots");
		kv.ImportFromFile(buffer);
	}

	delete PlotOwner;
	PlotOwner = new StringMap();

	MaxBlocks = kv.GetNum("maxblocks", 50);
	kv.GetString("zoneprefix", BlockZone, sizeof(BlockZone));
	MaxRange = kv.GetNum("maxrange", 9) / 2;
	BlockDistance = kv.GetFloat("blocksize", 50.0);
	
	delete BlockList;
	BlockList = new ArrayList(sizeof(BlockEnum));

	BlockEnum block;

	if(kv.JumpToKey("Blocks"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				block.SetupEnum(kv);
				BlockList.PushArray(block);
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
	}

	if(kv != map)
		delete kv;
}

void Plots_EntityCreated(int entity)
{
	InPlot[entity][0] = 0;

	if(entity > CurrentEdicts)
		CurrentEdicts = entity;
}

void Plots_EntityDestoryed()
{
	// In Source Engine, edicts won't get reallocated for 1 second after being freed
	CreateTimer(1.01, Plots_EdictCleared);
}

public Action Plots_EdictCleared(Handle timer)
{
	CurrentEdicts--;
	return Plugin_Continue;
}

void Plots_ClientEnter(int client, const char[] name)
{
	if(!InPlot[client][0] && !StrContains(name, BlockZone, false))
	{
		strcopy(InPlot[client], sizeof(InPlot[]), name);

		int owner;
		if(PlotOwner.GetValue(name, owner) && (owner = GetClientOfUserId(owner)))
		{
			if(owner == client)
			{
				PrintCenterText(client, "");
			}
			else
			{
				PrintCenterText(client, "This plot is owned by %N", owner);
			}
		}
		else
		{
			Plots_ShowMenu(client);
		}
	}
}

void Plots_ClientLeave(int client, const char[] name)
{
	if(InPlot[client][0] && StrEqual(name, InPlot[client]))
	{
		InPlot[client][0] = 0;
		if(InMenu[client])
			CancelClientMenu(client);
	}
}

void Plots_DisableZone(const char[] name)
{
	int userid;
	if(PlotOwner.GetValue(name, userid))
		UnloadPlot(userid, name);
}

bool Plots_CanShowMenu(int client)
{
	return (CanClaimHere(client) || CanBuildHere(client));
}

bool Plots_ShowMenu(int client)
{
	int owner;
	if(PlotOwner.GetValue(name, owner) && (owner = GetClientOfUserId(owner)))
	{
		int length = BlockList.Length;
		int[] blocks = new int[length];
		int total = GetBlockSpace(owner, blocks, true);

		Menu menu;

		if(owner == client)
		{
			menu = new Menu(Plots_MainMenu);
			menu.SetTitle("RPG Fortress\n \nPlot:\n%d / %d Blocks", total, MaxBlocks);

			static const char Settings[][] = { "Party Setting: None", "Party Setting: Interact Only", "Party Setting: Allow Building" }
			menu.AddItem(NULL_STRING, Settings[PartyMode[client]]);
		}
		else if(CanBuildHere(client))
		{
			menu = new Menu(Plots_MainMenu);
			menu.SetTitle("RPG Fortress\n \n%N's Plot:\n%d / %d Blocks", owner, total, MaxBlocks);
		}
		else
		{
			return false;
		}

		char num[12];
		int page;
		for(int i; i < length; i++)
		{
			static BlockEnum block;
			BlockList.GetArray(i, block);

			int limit = TextStore_GetItemCount(owner, block.Item);
			if(limit > 0)
			{
				bool same = (!page && StrEqual(block.Item, CurrentItem[client]));

				Format(block.Item, sizeof(block.Item), "%s (%d / %d)", block.Item, blocks[i], limit);

				if(same)
				{
					page = i;
					menu.AddItem(NULL_STRING, block.Item, ITEMDRAW_DISABLED);
				}
				else
				{
					IntToString(i, num, sizeof(num));
					menu.AddItem(num, block.Item);
				}
			}
		}

		InMenu[client] = menu.DisplayAt(client, page / 7 * 7, MENU_TIME_FOREVER);
	}
	else
	{
		Menu menu = new Menu(Plots_MainMenu);

		menu.SetTitle("RPG Fortress\n \nPlot:\n ");
		
		if(!TextStore_GetItemCount(client, "Plot Building Permit"))
		{
			menu.AddItem(NULL_STRING, "Claim Plot (Requires Plot Building Permit)", ITEMDRAW_DISABLED);
		}
		else if(CurrentEdicts > 1699)
		{
			menu.AddItem(NULL_STRING, "Claim Plot (Server Too Full)", ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem(NULL_STRING, "Claim Plot");
		}

		menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_DISABLED);
		menu.AddItem(NULL_STRING, "Plots allows you to build on your own land.", ITEMDRAW_DISABLED);
		menu.AddItem(NULL_STRING, "These plots will be saved each time you reclaim a plot.", ITEMDRAW_DISABLED);
		menu.AddItem(NULL_STRING, "You can use this land to show off and build special objects.", ITEMDRAW_DISABLED);
		menu.AddItem(NULL_STRING, "You can choose how you want party members to interact with your land.", ITEMDRAW_DISABLED);
		
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return true;
}

public int Plots_MainMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			if(choice == MenuCancel_Exit)
				TextStore_Inspect(client);
		}
		case MenuAction_Select:
		{
			if(InMenu[client])
			{
				InMenu[client] = false;
				// Menu stuff
			}
			else if(choice)
			{
				TextStore_Inspect(client);
			}
			else
			{
				LoadPlot(client);
			}
		}
	}
	return 0;
}

static int GetBlockByName(const char[] item, BlockEnum block)
{
	int length = BlockList.Length;
	for(int i; i < length; i++)
	{
		BlockList.GetArray(i, block);
		if(StrEqual(block.Item, item))
			return i;
	}

	return -1;
}

static void LoadPlot(int client, const char[] zone)
{
	static char id[32];
	if(GetClientAuthId(client, AuthId_Steam3, id, sizeof(id)) && strlen(id) > 9)
	{
		// Check for existing owner
		int length;
		if(PlotOwner.GetValue(zone, length))
			UnloadPlot(length, zone);
		
		int userid = GetClientUserId(client);
		PlotOwner.SetNum(zone, userid);
		
		KeyValues kv = Saves_Kv("plots");
		if(kv.JumpToKey(id))
		{
			if(kv.GotoFirstSubKey())
			{
				length = BlockList.Length;
				int[] blocks = new int[length];
				int[] count = new int[length];
				bool[] cached = new bool[length];

				for(int i; i < length; i++)
				{
					cached[i] = false;
				}

				build.UserID = userid;
				build.EntRef = -1;

				do
				{
					build.SetupEnum(kv);

					static BlockEnum block;
					int id = GetBlockByName(build.Item, block);
					if(id == -1)
						continue;
					
					blocks[id]++;
					
					if(!cached[id])
						count[id] = TextStore_GetItemCount(client, build.Item);
					
					if(count >= blocks[id])
						BuildList.PushArray(build);
				}
				while(kv.GotoNextKey());

				RenderPlot(userid);
			}
		}
	}
}

static void UnloadPlot(int userid, const char[] zone = "")
{
	if(zone[0])
	{
		PlotOwner.Erase(zone);
	}
	else
	{
		StringMapSnapshot snap = PlotOwner.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i) + 1;
			char[] buffer = new char[size];
			snap.GetKey(i, buffer, size);
			
			if(!PlotOwner.GetValue(buffer, size))
			{
				// Should never happen
				PlotOwner.Erase(buffer);
			}
			else if(size == userid)
			{
				// This plot owned by this player
				PlotOwner.Erase(buffer);
				break;
			}
		}
		delete snap;
	}
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		static char id[32];
		if(GetClientAuthId(client, AuthId_Steam3, id, sizeof(id)) && strlen(id) > 9)
		{
			KeyValues kv = Saves_Kv("plots");
			kv.Erase(id);
			kv.JumpToKey(id, true);

			int length = BuildList.Length;
			for(int i; i < length; i++)
			{
				static BuildEnum build;
				BuildList.GetArray(i, build);
				if(build.UserID == userid)
				{
					build.AddEntry(kv);

					int entity = build.EntRef;
					if(entity != -1)
						RemoveEntity(entity);

					BuildList.Erase(i);
				}
			}

			return;
		}
	}

	int length = BuildList.Length;
	for(int i; i < length; i++)
	{
		static BuildEnum build;
		BuildList.GetArray(i, build);
		if(build.UserID == userid)
		{
			int entity = build.EntRef;
			if(entity != -1)
				RemoveEntity(entity);

			BuildList.Erase(i);
		}
	}
}

static void RenderPlot(int userid, const float center[3], const float angles[3] = {})
{
	float pos[3], ang[3];
	int amount;
	int length = BuildList.Length;
	for(int i; i < length; i++)
	{
		static BuildEnum build;
		BuildList.GetArray(i, build);
		if(build.UserID == userid)
		{
			if(build.EntRef == -1 || !IsValidEntity(build.EntRef))
			{
				static BlockEnum block;
				int id = GetBlockByName(build.Item, block);
				if(id != -1)
				{
					pos = center;
					ang = angles;

					for(int b; b < 3; b++)
					{
						pos[b] += build.Pos[b] * BlockDistance;
						ang[b] += float(build.Ang[b]);
					}

					int entity = block.Spawn(pos, ang);
					if(entity != -1)
					{
						build.EntRef = EntIndexToEntRef(entity);
						BuildList.SetArray(i, build);
					}
				}
			}
		}
	}
}

static int GetBlockSpace(int userid, int[] blocks = {}, bool countBlocks = false)
{
	int amount;
	int length = BuildList.Length;
	for(int i; i < length; i++)
	{
		static BuildEnum build;
		BuildList.GetArray(i, build);
		if(build.UserID == userid)
		{
			static BlockEnum block;
			int id = GetBlockByName(build.Item, block);
			if(id != -1)
			{
				amount += block.Space;
				if(countBlocks)
					blocks[id]++;
			}
		}
	}
	return amount;
}

static bool CanInteractHere(int client)
{
	if(InPlot[client][0])
	{
		int owner;
		if(PlotOwner.GetValue(InPlot[client], owner) && (owner = GetClientOfUserId(owner)))
		{
			if(owner == client || (Party_IsClientMember(client, owner) && PartyMode[owner] >= Build_Interact))
				return true;
		}
	}
	return false;
}

static bool CanBuildHere(int client)
{
	if(InPlot[client][0])
	{
		int owner;
		if(PlotOwner.GetValue(InPlot[client], owner) && (owner = GetClientOfUserId(owner)))
		{
			if(owner == client || (Party_IsClientMember(client, owner) && PartyMode[owner] == Build_All))
				return true;
		}
	}
	return false;
}

static bool CanClaimHere(int client)
{
	if(InPlot[client][0])
	{
		int owner;
		if(!PlotOwner.GetValue(InPlot[client], owner) || !GetClientOfUserId(owner))
			return true;
	}
	return false;
}
