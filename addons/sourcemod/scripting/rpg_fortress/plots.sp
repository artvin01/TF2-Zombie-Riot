#pragma semicolon 1
#pragma newdecls required

enum struct BlockEnum
{
	int Store;
	char Item[48];
	int Space;

	char Model[PLATFORM_MAX_PATH];
	int Skin;
	int Render;
	float Scale;
	float Offset[3];
	char Color[16];
	Function Func;

	int Rotate;
	
	bool SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Item, 48);

		kv.GetString("model", this.Model, PLATFORM_MAX_PATH, "models/error.mdl");
		if(!this.Model[0])
			return false;
		
		this.Skin = kv.GetNum("skin");
		this.Render = kv.GetNum("render", 255);
		this.Scale = kv.GetFloat("scale", 1.0);
		this.Rotate = kv.GetNum("rotate");
		this.Space = kv.GetNum("space", 1);
		kv.GetVector("offset", this.Offset);
		kv.GetString("color", this.Color, 16, "255 255 255");
		this.Func = KvGetFunction(kv, "func");
		return true;
	}
	
	int Spawn(float pos[3], float ang[3])
	{
		int entity = CreateEntityByName("prop_dynamic_override");
		if(entity != -1)
		{
			DispatchKeyValue(entity, "targetname", "rpg_fortress");
			DispatchKeyValue(entity, "model", this.Model);
			DispatchKeyValueInt(entity, "skin", this.Skin);
			DispatchKeyValue(entity, "solid", "6");
			DispatchKeyValueInt(entity, "renderamt", this.Render);
			DispatchKeyValueFloat(entity, "modelscale", this.Scale);
			DispatchKeyValue(entity, "rendercolor", this.Color);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);
			DispatchSpawn(entity);

			for(int i; i < 3; i++)
			{
				pos[i] += this.Offset[i];

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
				/*else if(this.Rotate > 1)
				{
					ang[i] = (RoundToNearest(ang[i] / 90.0) * 90.0) + 180.0;
				}*/
				else
				{
					ang[i] = 0.0;
				}
			}
			
			TeleportEntity(entity, pos, ang, NULL_VECTOR, true);

			if(this.Func != INVALID_FUNCTION)
			{
				b_is_a_brush[entity] = true;
				b_BrushToOwner[entity] = EntIndexToEntRef(entity);
			}
		}
		return entity;
	}

	bool CallFunc(int entity, BuildEnum build, int client = 0, int weapon = -1)
	{
		bool result;

		if(this.Func != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.Func);
			Call_PushCell(entity);
			Call_PushArrayEx(build, sizeof(build), SM_PARAM_COPYBACK);
			Call_PushCell(client);
			Call_PushCell(weapon);
			Call_Finish(result);
		}

		return result;
	}
}

enum struct BuildEnum
{
	int UserID;
	char Item[48];
	int Flags;

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

		this.Flags = kv.GetNum("flags");
	}
	void AddEntry(KeyValues kv)
	{
		static char buffer[48];
		Format(buffer, sizeof(buffer), "%d %d %d", this.Pos[0], this.Pos[1], this.Pos[2]);
		kv.JumpToKey(buffer, true);

		Format(buffer, sizeof(buffer), "%d %d %d", this.Ang[0], this.Ang[1], this.Ang[2]);
		kv.SetString("ang", buffer);

		kv.SetString("name", this.Item);
		kv.SetNum("flags", this.Flags);

		kv.GoBack();
	}
}

enum
{
	Build_None = 0,
	Build_Interact,
	Build_All
}

#include "plots/crafting.sp"
#include "plots/mining.sp"
#include "plots/misc.sp"
#include "plots/skinswap.sp"

static KeyValues PlotKv;
static ArrayList BlockList;
static IntMap PlotOwner;
static ArrayList BuildList;
static char BlockZone[32];
static int MaxBlocks;
static int MaxRange;
static float BlockSize;
static float PlatformOffset[3];
static char PlatformModel[PLATFORM_MAX_PATH];
static float PlatformScale;

static int InPlot[MAXENTITIES+1];
static int InMenu[MAXPLAYERS];
static char CurrentItem[MAXPLAYERS][32];
static int PartyMode[MAXPLAYERS];

void Plots_ConfigSetup()
{
	delete BuildList;
	BuildList = new ArrayList(sizeof(BuildEnum));

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "plots");
	KeyValues kv = new KeyValues("Plots");
	kv.ImportFromFile(buffer);

	delete PlotKv;
	RPG_BuildPath(buffer, sizeof(buffer), "plots_savedata");
	PlotKv = new KeyValues("PlotData");
	PlotKv.ImportFromFile(buffer);

	delete PlotOwner;
	PlotOwner = new IntMap();

	MaxBlocks = kv.GetNum("maxblocks", 50);
	kv.GetString("zoneprefix", BlockZone, sizeof(BlockZone));
	MaxRange = kv.GetNum("maxrange", 9);
	BlockSize = kv.GetFloat("blocksize", 50.0);

	kv.GetString("platform_model", PlatformModel, sizeof(PlatformModel));
	if(PlatformModel[0])
		PrecacheModel(PlatformModel);
	
	kv.GetVector("platform_offset", PlatformOffset);
	PlatformScale = kv.GetFloat("platform_scale", 1.0);

	delete kv;
}

void Plots_StoreCached()
{
	delete BlockList;
	BlockList = new ArrayList(sizeof(BlockEnum));

	BlockEnum block;

	char buffer[64];
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv && kv.GetNum("plots"))
		{
			kv.GetString("plugin", buffer, sizeof(buffer));
			if(StrEqual(buffer, "rpg_fortress"))
			{
				if(block.SetupEnum(kv))
				{
					block.Store = i;
					BlockList.PushArray(block);
				}
			}
		}
	}
}

void Plots_ZoneCached()
{
	if(!PlatformModel[0])
		return;
	
	char buffer[64];
	float pos[3], ang[3];
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "trigger_rpgzone")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(Plots_IsPlotZone(buffer))
		{
			GetPlotData(entity, pos, ang);

			int prop = CreateEntityByName("prop_dynamic_override");
			if(prop != -1)
			{
				DispatchKeyValue(prop, "targetname", "rpg_fortress");
				DispatchKeyValue(prop, "model", PlatformModel);
				DispatchKeyValue(prop, "solid", "2");
				DispatchKeyValueFloat(prop, "modelscale", PlatformScale);
				DispatchSpawn(prop);
				
				for(int i; i < 3; i++)
				{
					pos[i] += PlatformOffset[i];
				}

				TeleportEntity(prop, pos, ang, NULL_VECTOR, true);
			}
		}
	}
}

void Plots_EntityCreated(int entity)
{
	InPlot[entity] = 0;
}

void Plots_ClientEnter(int client, int ref, const char[] name)
{
	if(!InPlot[client] && Plots_IsPlotZone(name))
	{
		InPlot[client] = ref;

		int owner;
		if(PlotOwner.GetValue(ref, owner) && (owner = GetClientOfUserId(owner)))
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
		else if(Editor_MenuFunc(client) == INVALID_FUNCTION)
		{
			if(TextStore_GetItemCount(client, "Plot Building Permit"))
				PrintCenterText(client, "This plot is unclaimed");
			
			//Plots_ShowMenu(client);
		}
	}
}

void Plots_ClientLeave(int client, int ref)
{
	if(InPlot[client] == ref)
	{
		PrintCenterText(client, "");
		InPlot[client] = 0;
		if(InMenu[client])
			TextStore_SwapMenu(client);
	}
}

void Plots_DisableZone(int ref)
{
	int userid;
	if(PlotOwner.GetValue(ref, userid))
		UnloadPlot(userid, ref);
}

int Plots_ZoneOwner(int client)
{
	int owner;
	if(InPlot[client])
	{
		if(PlotOwner.GetValue(InPlot[client], owner))
			owner = GetClientOfUserId(owner);
	}

	return owner;
}

int Plots_ZoneName(int client, char[] name, int length)
{
	if(InPlot[client])
	{
		int entity = EntRefToEntIndex(InPlot[client]);
		if(entity != -1)
			return GetEntPropString(entity, Prop_Data, "m_iName", name, length);
	}

	return 0;
}

bool Plots_CanShowMenu(int client, int &owner = 0)
{
	if(InPlot[client])
	{
		if(!PlotOwner.GetValue(InPlot[client], owner) || !(owner = GetClientOfUserId(owner)))
			return true;
		
		if(owner == client || (Party_IsClientMember(client, owner) && PartyMode[owner] == Build_All))
			return true;
	}
	return false;
	//return (CanClaimHere(client) || CanBuildHere(client));
}

bool Plots_ShowMenu(int client)
{
	int owner;
	if(CanBuildHere(client, owner))
	{
		int length = BlockList.Length;
		int[] blocks = new int[length];
		int total = GetBlockSpace(GetClientUserId(owner), blocks, true);

		Menu menu = new Menu(Plots_MainMenu);

		if(owner == client)
		{
			menu.SetTitle("RPG Fortress\n \nPlot:\n%d / %d Space", total, MaxBlocks);

			static const char Settings[][] = { "Party Setting: None", "Party Setting: Interact Only", "Party Setting: Allow Building" };
			menu.AddItem(NULL_STRING, Settings[PartyMode[client]]);
		}
		else
		{
			menu.SetTitle("RPG Fortress\n \n%N's Plot:\n%d / %d Space", owner, total, MaxBlocks);
			
			menu.AddItem(NULL_STRING, "Nothing");
		}

		int page;
		for(int i; i < length; i++)
		{
			static BlockEnum block;
			BlockList.GetArray(i, block);

			int limit;
			TextStore_GetInv(owner, block.Store, limit);

			if(limit > 0)
			{
				bool same = (page == 0 && StrEqual(block.Item, CurrentItem[client]));

				Format(block.Model, sizeof(block.Model), "%s (%d / %d)", block.Item, blocks[i], limit);

				if(same)
				{
					page = i + 1;
					menu.AddItem(NULL_STRING, block.Model, ITEMDRAW_DISABLED);

					if(blocks[i] >= limit)	// Too many blocks
						CurrentItem[client][0] = 0;
				}
				else
				{
					menu.AddItem(block.Item, block.Model);
				}
			}
		}

		if(total >= MaxBlocks)	// Too many total blocks
			CurrentItem[client][0] = 0;

		InMenu[client] = menu.DisplayAt(client, page / 7 * 7, MENU_TIME_FOREVER) ? 2 : 0;
		return view_as<bool>(InMenu[client]);
	}

	if(CanClaimHere(client))
	{
		Menu menu = new Menu(Plots_MainMenu);

		menu.SetTitle("RPG Fortress\n \nPlot:\n ");
		
		if(!TextStore_GetItemCount(client, "Plot Building Permit"))
		{
			menu.AddItem(NULL_STRING, "Claim Plot (Requires Plot Building Permit)", ITEMDRAW_DISABLED);
		}
		else if(CurrentEntities > 1699)
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
		
		InMenu[client] = menu.Display(client, MENU_TIME_FOREVER) ? 1 : 0;
		return view_as<bool>(InMenu[client]);
	}

	return false;
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
			InMenu[client] = 0;

			if(choice == MenuCancel_Exit)
				TextStore_SwapMenu(client);
		}
		case MenuAction_Select:
		{
			if(InMenu[client] == 2)
			{
				InMenu[client] = 0;
				
				int owner;
				if(PlotOwner.GetValue(InPlot[client], owner))
				{
					if(choice)
					{
						menu.GetItem(choice, CurrentItem[client], sizeof(CurrentItem[]));
					}
					else
					{
						if(GetClientOfUserId(owner) == client)
						{
							if(PartyMode[client] > 1)
							{
								PartyMode[client] = 0;
							}
							else
							{
								PartyMode[client]++;
							}
						}

						CurrentItem[client][0] = 0;
					}

					Plots_ShowMenu(client);
				}
			}
			else
			{
				InMenu[client] = 0;

				if(!choice)
				{
					PartyMode[client] = 0;
					LoadPlot(client, InPlot[client]);
					TextStore_OpenSpecificMenu(client, MENU_BUILDING);
				}
			}
		}
	}
	return 0;
}

bool Plots_PlayerRunCmd(int client, int &buttons)
{
	if(InMenu[client] != 2 || InPlot[client] == -1)
		return false;
	
	float gameTime = GetGameTime();

	static float attackFor[MAXPLAYERS];
	if(fabs(attackFor[client] - gameTime) < 0.5)
	{
		if(!(buttons & IN_ATTACK))
			attackFor[client] = 0.0;
	}
	else if(buttons & IN_ATTACK)
	{
		attackFor[client] = gameTime;
		
		int entity = FireBlockTrace(client);
		if(InPlot[client] == InPlot[entity])
		{
			int pos = BuildList.FindValue(EntIndexToEntRef(entity), BuildEnum::EntRef);
			if(pos != -1)
			{
				RemoveEntity(entity);
				BuildList.Erase(pos);
				Plots_ShowMenu(client);
			}
		}
	}
	
	if(CurrentItem[client][0])
	{
		static float altfireFor[MAXPLAYERS];
		if(fabs(altfireFor[client] - gameTime) < 0.5)
		{
			if(!(buttons & IN_ATTACK2))
				altfireFor[client] = 0.0;
		}
		else if(buttons & IN_ATTACK2)
		{
			altfireFor[client] = gameTime;

			int userid;
			if(PlotOwner.GetValue(InPlot[client], userid))
			{
				float pos[3], ang[3];
				FireBlockTrace(client, pos, ang);

				float center[3], angles[3];
				GetPlotData(InPlot[client], center, angles);

				// center[2] here is the floor
				float highBound = center[2] - 0.01 + (MaxRange * BlockSize);
				float lowBound = center[2] + 0.01;
				pos[2] = fClamp(pos[2], lowBound, highBound);

				// Clamp other directions
				float halfLimit = (1 + (MaxRange / 2)) * BlockSize;
				for(int i; i < 2; i++)
				{
					highBound = center[i] - 0.01 + halfLimit;
					lowBound = center[i] + 0.01 - halfLimit;
					pos[i] = fClamp(pos[i], lowBound, highBound);
				}

				// Snap to offset
				int offset[3];
				for(int i; i < 3; i++)
				{
					if(i == 2)
					{
						// RoundToFloor here with model origin being at feet
						offset[i] = RoundToFloor((pos[i] - center[i]) / BlockSize);
					}
					else
					{
						offset[i] = RoundFloat((pos[i] - center[i]) / BlockSize);
					}
					
					pos[i] = center[i] + (offset[i] * BlockSize);
					ang[i] = fixAngle(ang[i] + angles[i]);
				}

				// Stuck check
				bool failed;
				//float mins[3], maxs[3];
				for(int target = 1; target <= MaxClients; target++)
				{
					if(InPlot[client] == InPlot[target] && IsClientInGame(target) && IsPlayerAlive(target))
					{
						GetEntPropVector(target, Prop_Send, "m_vecOrigin", center);

						failed = true;
						for(int i; i < 3; i++)
						{
							// 24.0 maxs, -24.0 mins
							// 82.0 maxs, 0 mins
							static const float offsets[] = {0.0, 0.0, 41.0};
							static const float box[] = {24.0, 24.0, 41.0};

							float blockPos = i == 2 ? BlockSize / 2.0 : 0.0;	// Both ents have feet origin

							if(fabs((center[i] + offsets[i]) - (pos[i] + blockPos)) > ((BlockSize / 2.0) + box[i]))
							{
								failed = false;
								break;
							}
						}

						if(failed)
							break;
					}
				}

				if(!failed)
				{
					// Space check (due to clamping)
					static BuildEnum build;
					int length = BuildList.Length;
					for(int i; i < length; i++)
					{
						BuildList.GetArray(i, build);
						if(build.UserID == userid &&
							build.Pos[0] == offset[0] &&
							build.Pos[1] == offset[1] &&
							build.Pos[2] == offset[2])
						{
							failed = true;
							break;
						}
					}

					if(!failed)
					{
						build.UserID = userid;
						build.Pos = offset;
						strcopy(build.Item, sizeof(build.Item), CurrentItem[client]);

						for(int i; i < 3; i++)
						{
							build.Ang[i] = RoundFloat(ang[i]);
						}

						static BlockEnum block;
						int id = GetBlockByName(build.Item, block);
						if(id != -1)
						{
							int entity = block.Spawn(pos, ang);
							if(entity != -1)
							{
								InPlot[entity] = InPlot[client];
								build.EntRef = EntIndexToEntRef(entity);

								block.CallFunc(entity, build);
								BuildList.PushArray(build);
								Plots_ShowMenu(client);
							}
						}
					}
				}
			}
		}
	}

	buttons &= ~(IN_ATTACK|IN_ATTACK2|IN_RELOAD|IN_ATTACK3);
	return true;
}

bool Plots_Interact(int client, int entity, int weapon)
{
	if(InPlot[client] == InPlot[entity])
	{
		int pos = BuildList.FindValue(EntIndexToEntRef(entity), BuildEnum::EntRef);
		if(pos != -1)
		{
			static BuildEnum build;
			BuildList.GetArray(pos, build);

			static BlockEnum block;
			int id = GetBlockByName(build.Item, block);
			if(id != -1)
			{
				bool result = block.CallFunc(entity, build, client, weapon);
				if(result)
				{
					BuildList.SetArray(pos, build);
					return result;
				}
			}
		}
	}

	return false;
}

static int FireBlockTrace(int client, float pos[3] = {}, float ang[3] = {})
{
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	Handle trace = TR_TraceRayFilterEx(pos, ang, CONTENTS_SOLID|MASK_SOLID, RayType_Infinite, Trace_Block, client);
	TR_GetEndPosition(pos, trace);
	int entity = TR_GetEntityIndex(trace);
	delete trace;
	
	return entity;
}

static bool Trace_Block(int entity, int mask, int client)
{
	return entity != client;
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

static void LoadPlot(int client, int zone)
{
	static char steamid[32];
	if(GetClientAuthId(client, AuthId_Steam3, steamid, sizeof(steamid)) && strlen(steamid) > 9)
	{
		// Check for existing owner
		int length;
		if(PlotOwner.GetValue(zone, length))
			UnloadPlot(length, zone);
		
		int userid = GetClientUserId(client);
		PlotOwner.SetValue(zone, userid);
		
		PlotKv.Rewind();
		if(PlotKv.JumpToKey(steamid))
		{
			if(PlotKv.GotoFirstSubKey())
			{
				length = BlockList.Length;
				int[] blocks = new int[length];
				int[] count = new int[length];
				bool[] cached = new bool[length];

				for(int i; i < length; i++)
				{
					cached[i] = false;
				}

				static BuildEnum build;
				build.UserID = userid;
				build.EntRef = -1;

				do
				{
					build.SetupEnum(PlotKv);

					static BlockEnum block;
					int id = GetBlockByName(build.Item, block);
					if(id == -1)
						continue;
					
					blocks[id]++;
					
					if(!cached[id])
					{
						TextStore_GetInv(client, block.Store, count[id]);
						cached[id] = true;
					}
					
					if(count[id] >= blocks[id])
						BuildList.PushArray(build);
				}
				while(PlotKv.GotoNextKey());

				RenderPlot(userid, zone);
			}
		}
	}
}

static void UnloadPlot(int userid, int zone)
{
	PlotOwner.Remove(zone);
	
	int client = GetClientOfUserId(userid);
	if(client)
	{
		static char buffer[PLATFORM_MAX_PATH];
		if(GetClientAuthId(client, AuthId_Steam3, buffer, sizeof(buffer)) && strlen(buffer) > 9)
		{
			PlotKv.Rewind();
			if(PlotKv.JumpToKey(buffer))
			{
				if(!PlotKv.DeleteThis())
					PrintToChatAll("PLOT SAVE ERROR");
			}

			PlotKv.Rewind();
			PlotKv.JumpToKey(buffer, true);

			int length = BuildList.Length;
			for(int i; i < length; i++)
			{
				static BuildEnum build;
				BuildList.GetArray(i, build);
				if(build.UserID == userid)
				{
					build.AddEntry(PlotKv);

					int entity = build.EntRef;
					if(entity != -1)
						RemoveEntity(entity);

					BuildList.Erase(i);
					i--;
					length--;
				}
			}

			RPG_BuildPath(buffer, sizeof(buffer), "plots_savedata");
			PlotKv.Rewind();
			PlotKv.ExportToFile(buffer);

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
			i--;
			length--;
		}
	}
}

static void GetPlotData(int zone, float center[3], float angles[3])
{
	float mins[3], maxs[3];
	GetEntPropVector(zone, Prop_Send, "m_vecMins", mins);
	GetEntPropVector(zone, Prop_Send, "m_vecMaxs", maxs);
	GetEntPropVector(zone, Prop_Data, "m_vecOrigin", center);

	center[2] += mins[2];

	for(int i; i < 3; i++)
	{
		angles[i] = 0.0;
	}
}

static void RenderPlot(int userid, int zone)
{
	float center[3], angles[3], pos[3], ang[3];
	GetPlotData(zone, center, angles);

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
						pos[b] += build.Pos[b] * BlockSize;
						ang[b] += float(build.Ang[b]);
					}

					int entity = block.Spawn(pos, ang);
					if(entity != -1)
					{
						InPlot[entity] = zone;
						build.EntRef = EntIndexToEntRef(entity);

						block.CallFunc(entity, build);
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

bool Plots_CanInteractHere(int client)
{
	if(InPlot[client])
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

static bool CanBuildHere(int client, int &owner = 0)
{
	if(InPlot[client])
	{
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
	if(InPlot[client])
	{
		int owner;
		if(!PlotOwner.GetValue(InPlot[client], owner) || !GetClientOfUserId(owner))
			return true;
	}
	return false;
}

float Plots_MaxSize()
{
	return MaxRange * BlockSize;
}

bool Plots_IsPlotZone(const char[] name)
{
	return !StrContains(name, BlockZone, false);
}
