#include <sourcemod>
#include <dhooks>

#define TF2_MAXPLAYERS 33

static ArrayList maps;
static int map_idx;

static ConVar nav_edit;
static ConVar sv_cheats;
static ConVar localplayer_index;

static ConVar sm_ensurenav_spam_walk;
static ConVar sm_ensurenav_restart;
/*
static int CNavMesh_m_generationState_offset = -1;
static int CNavMesh_m_generationMode_offset = -1;
static int CNavMesh_m_isAnalyzed_offset = -1;
*/
static float last_walk_seed[TF2_MAXPLAYERS+1];

static char currentmap[PLATFORM_MAX_PATH];

#define SAVE_NAV_MESH 9

#define GENERATE_INCREMENTAL 2
#define GENERATE_ANALYSIS_ONLY 4
#define GENERATE_FULL 1

public void OnPluginStart()
{
	GameData gamedata = new GameData("ensurenav");
	if(gamedata == null) {
		SetFailState("Gamedata not found.");
		return;
	}
/*
	DynamicDetour tmp = DynamicDetour.FromConf(gamedata, "CNavMesh::UpdateGeneration");
	if(!tmp || !tmp.Enable(Hook_Pre, CNavMesh_UpdateGeneration_detour)) {
		SetFailState("Failed to enable pre detour for CNavMesh::UpdateGeneration");
		delete gamedata;
		return;
	}
	if(!tmp.Enable(Hook_Post, CNavMesh_UpdateGeneration_detour_post)) {
		SetFailState("Failed to enable pre detour for CNavMesh::UpdateGeneration");
		delete gamedata;
		return;
	}

	CNavMesh_m_generationState_offset = gamedata.GetOffset("CNavMesh::m_generationState");
	CNavMesh_m_generationMode_offset = gamedata.GetOffset("CNavMesh::m_generationMode");
	CNavMesh_m_isAnalyzed_offset = gamedata.GetOffset("CNavMesh::m_isAnalyzed");
*/
	delete gamedata;

	nav_edit = FindConVar("nav_edit");
	sv_cheats = FindConVar("sv_cheats");
	nav_edit.AddChangeHook(nav_edit_changed);

	int flags = GetCommandFlags("nav_mark_walkable");
	flags &= ~FCVAR_CHEAT;
	SetCommandFlags("nav_mark_walkable", flags);

	flags = GetCommandFlags("nav_generate");
	flags &= ~FCVAR_CHEAT;
	SetCommandFlags("nav_generate", flags);

	flags = GetCommandFlags("nav_generate_incremental");
	flags &= ~FCVAR_CHEAT;
	SetCommandFlags("nav_generate_incremental", flags);

	sm_ensurenav_spam_walk = CreateConVar("sm_ensurenav_spam_walk", "-1.0");
/*
	sm_ensurenav_restart = CreateConVar("sm_ensurenav_restart", "0");
*/
	RegAdminCmd("sm_ensurenav", sm_ensurenav, ADMFLAG_ROOT);
	RegAdminCmd("sm_mark_all_walk", sm_mark_all_walk, ADMFLAG_ROOT);
	RegAdminCmd("sm_mark_walk", sm_mark_walk, ADMFLAG_ROOT);
	RegAdminCmd("sm_nav_edit_mode", sm_nav_edit_mode, ADMFLAG_ROOT);
}

static void nav_edit_changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(localplayer_index == null) {
		return;
	}

	int value = StringToInt(newValue);

	if(value) {
		for(int i = 1; i <= MaxClients; ++i) {
			if(!IsClientInGame(i) || IsFakeClient(i)) {
				continue;
			}

			if(!!(GetUserFlagBits(i) & ADMFLAG_ROOT)) {
				localplayer_index.IntValue = i;
				break;
			}
		}
	} else {
		localplayer_index.IntValue = -1;
	}
}

public void OnAllPluginsLoaded()
{
	localplayer_index = FindConVar("localplayer_index");
}

public void OnConfigsExecuted()
{
	nav_edit.IntValue = 0;
}

public void OnClientDisconnect(int client)
{
	last_walk_seed[client] = 0.0;
	if(localplayer_index.IntValue == client)
	{
		localplayer_index.IntValue = -1;
		sv_cheats.IntValue = 0;
		nav_edit.IntValue = 0;	
	}
}

static void add_walkable_seed(int client, bool aim)
{
	if(localplayer_index != null) {
		int old_localplayer = localplayer_index.IntValue;
		int old_edit = nav_edit.IntValue;
		localplayer_index.IntValue = client;
		nav_edit.IntValue = (aim ? 1 : 0);
		InsertServerCommand("nav_mark_walkable");
		ServerExecute();
		nav_edit.IntValue = old_edit;
		localplayer_index.IntValue = old_localplayer;
	}
}

static Action sm_mark_walk(int client, int args)
{
	add_walkable_seed(client, false);

	return Plugin_Handled;
}

static Action sm_nav_edit_mode(int client, int args)
{

	if(localplayer_index.IntValue != -1)
	{
		localplayer_index.IntValue = -1;
		sv_cheats.IntValue = 0;
		nav_edit.IntValue = 0;	
	}
	else
	{
		NavMenu_Init(client);
		localplayer_index.IntValue = client;
		sv_cheats.IntValue = 1;
		nav_edit.IntValue = 1;	
	}

	return Plugin_Handled;
}

static Action sm_mark_all_walk(int client, int args)
{
	for(int i = 1; i <= MaxClients; ++i) {
		if(!IsClientInGame(i)) {
			continue;
		}

		add_walkable_seed(i, false);
	}

	return Plugin_Handled;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	float time = sm_ensurenav_spam_walk.FloatValue;

	if(time >= 0.0) {
		if(last_walk_seed[client] >= GetGameTime()) {
			return;
		}

		add_walkable_seed(client, false);

		last_walk_seed[client] = GetGameTime() + time;
	}
}
/*
static MRESReturn CNavMesh_UpdateGeneration_detour(Address pThis, DHookReturn hReturn)
{
	int m_generationState = LoadFromAddress(pThis + view_as<Address>(CNavMesh_m_generationState_offset), NumberType_Int32);
	if(m_generationState == SAVE_NAV_MESH) {
		int m_generationMode = LoadFromAddress(pThis + view_as<Address>(CNavMesh_m_generationMode_offset), NumberType_Int32);
		if(m_generationMode == GENERATE_ANALYSIS_ONLY || m_generationMode == GENERATE_FULL) {
			StoreToAddress(pThis + view_as<Address>(CNavMesh_m_isAnalyzed_offset), 1, NumberType_Int8);
		}

		StoreToAddress(pThis + view_as<Address>(CNavMesh_m_generationMode_offset), GENERATE_INCREMENTAL, NumberType_Int32);
	}
	return MRES_Ignored;
}

static MRESReturn CNavMesh_UpdateGeneration_detour_post(Address pThis, DHookReturn hReturn)
{
	int m_generationState = LoadFromAddress(pThis + view_as<Address>(CNavMesh_m_generationState_offset), NumberType_Int32);
	if(m_generationState == SAVE_NAV_MESH) {
		nav_done();
	}
	return MRES_Ignored;
}
*/
static Action sm_ensurenav(int client, int args)
{
	if(maps) {
		ReplyToCommand(client, "Already generating navs");
		return Plugin_Handled;
	}

	char nextmap[PLATFORM_MAX_PATH];

	maps = view_as<ArrayList>(ReadMapList(null, _, "default", MAPLIST_FLAG_MAPSFOLDER));
	for(int i = 0; i < maps.Length;) {
		maps.GetString(map_idx, nextmap, PLATFORM_MAX_PATH);

		Format(nextmap, PLATFORM_MAX_PATH, "maps/%s.nav", nextmap);

		if(FileExists(nextmap, true)) {
			maps.Erase(i);
			continue;
		}

		++i;
	}

	map_idx = 0;

	int len = maps.Length;
	if(len == 0) {
		delete maps;
	} else {
		ReplyToCommand(client, "Generating nav for %i maps", len);

		OnMapStart();
	}

	return Plugin_Handled;
}

static void nav_done_cycle()
{
	if(++map_idx == maps.Length) {
		delete maps;
		map_idx = 0;
	} else {
		char nextmap[PLATFORM_MAX_PATH];
		maps.GetString(map_idx, nextmap, PLATFORM_MAX_PATH);
		SetNextMap(nextmap);
		ForceChangeLevel(nextmap, "ensurenav");
	}
}
/*
static void nav_done()
{
	if(maps) {
		nav_done_cycle();
	} else {
		if(sm_ensurenav_restart.BoolValue) {
			SetNextMap(currentmap);
			ForceChangeLevel(currentmap, "ensurenav");
		}
	}
}
*/
public void OnMapStart()
{
	GetCurrentMap(currentmap, PLATFORM_MAX_PATH);

	if(maps) {
		char nextmap[PLATFORM_MAX_PATH];
		maps.GetString(map_idx, nextmap, PLATFORM_MAX_PATH);

		if(!StrEqual(currentmap, nextmap)) {
			SetNextMap(nextmap);
			ForceChangeLevel(nextmap, "ensurenav");
			return;
		}

		Format(nextmap, PLATFORM_MAX_PATH, "maps/%s.nav", nextmap);

		if(!FileExists(nextmap, true)) {
			InsertServerCommand("nav_generate");
			ServerExecute();
		} else {
			nav_done_cycle();
		}
	} else {
	#if 0
		char nav[PLATFORM_MAX_PATH];
		FormatEx(nav, PLATFORM_MAX_PATH, "maps/%s.nav", currentmap);

		if(!FileExists(nav, true)) {
			InsertServerCommand("nav_generate");
			ServerExecute();
		}
	#endif
	}
}

bool delete_menu;

void NavMenu_Init(int client)
{
	delete_menu = false;

	Menu menu = new Menu(NavMenuH);

	menu.SetTitle("Nav Mesh Menu");
	menu.AddItem("-1", "Mark");
	menu.AddItem("-2", "Connect");
	menu.AddItem("-3", "Disconnect");
	menu.AddItem("-4", "Split");
	menu.AddItem("-5", "Delete");
	menu.AddItem("-6", "Save");
	menu.AddItem("-7", "Load");
					
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	RequestFrame(delete_menu_set);
}

void delete_menu_set()
{	
	delete_menu = true;
}

public int NavMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			if(delete_menu)
			{
				localplayer_index.IntValue = -1;
				sv_cheats.IntValue = 0;
				nav_edit.IntValue = 0;					
			}			
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				localplayer_index.IntValue = -1;
				sv_cheats.IntValue = 0;
				nav_edit.IntValue = 0;	
			}
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					NavMenu_Init(client);
					ServerCommand("nav_mark");
				}
				case -2:
				{
					NavMenu_Init(client);
					ServerCommand("nav_connect");
				}
				case -3:
				{
					NavMenu_Init(client);
					ServerCommand("nav_disconnect");
				}
				case -4:
				{
					NavMenu_Init(client);
					ServerCommand("nav_split");
				}
				case -5:
				{
					NavMenu_Init(client);
					ServerCommand("nav_delete");
				}
				case -6:
				{
					NavMenu_Init(client);
					ServerCommand("nav_save");
				}
				case -7:
				{
					NavMenu_Init(client);
					ServerCommand("nav_load");
				}
				default:
				{
					localplayer_index.IntValue = -1;
					sv_cheats.IntValue = 0;
					nav_edit.IntValue = 0;	
				}
			}
		}
	}
	return 0;
}
