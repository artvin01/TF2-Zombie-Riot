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

enum
{
	Build_None = 0,
	Build_Interact,
	Build_All
}

static ArrayList BlockList;
static StringMap PlotOwner;
static char BlockZone[32];
static int LevelRequired;
static int MaxBlocks;
static int MaxRange;

static char InPlot[MAXTF2PLAYERS][32];
static bool InMenu[MAXTF2PLAYERS];
static int LastPage[MAXTF2PLAYERS];
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

	MaxBlocks = kv.GetNum("maxblocks", 80);
	kv.GetString("zoneprefix", BlockZone, sizeof(BlockZone));
	LevelRequired = kv.GetNum("levelrequired", 50);
	MaxRange = kv.GetNum("maxrange", 8);
	
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
				PrintCenterText(client, "This plot is owned by %N");
			}
		}
		else
		{
			Plots_ShowMenu(client);
		}
	}
}

void Plots_ClientLeave(const char[] name)
{
	if(InPlot[client][0] && StrEqual(name, InPlot[client]))
	{
		InPlot[client][0] = 0;
		if(InMenu[client])
			CancelClientMenu(client);
	}
}

bool Plots_CanShowMenu(int client)
{
	return CanBuildHere(client);
}

bool Plots_ShowMenu(int client)
{
	int owner;
	if(PlotOwner.GetValue(name, owner) && (owner = GetClientOfUserId(owner)))
	{
		Menu menu = new Menu(Plots_MainMenu);

		if(owner == client)
		{
			menu.SetTitle("RPG Fortress\n \nPlot:");

			menu.AddItem(NULL_STRING, "Party Setting:");
		}
		else
		{
			menu.SetTitle("RPG Fortress\n \n%N's Plot:", owner);
		}
	}
}

static bool CanInteractHere(int client)
{
	if(InPlot[client][0])
	{
		int owner;
		if(PlotOwner.GetValue(InPlot[client], owner) && (owner = GetClientOfUserId(owner)))
		{
			if(Party_IsClientMember(client, owner) && PartyMode[owner] >= Build_Interact)
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
			if(Party_IsClientMember(client, owner) && PartyMode[owner] == Build_All)
				return true;
		}
	}
	return false;
}
