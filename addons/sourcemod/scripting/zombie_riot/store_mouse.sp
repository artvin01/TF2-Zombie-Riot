#pragma semicolon 1
#pragma newdecls required

enum
{
	Screen_Title = 0,
	Screen_Sprite1,

	Screen_MAX
}

static bool b_InsideMenu[MAXPLAYERS];
static float LastMousePos[MAXPLAYERS][2];
static int i_NextRenderMouse[MAXPLAYERS];
static int LastFOV[MAXPLAYERS];
static int LastDefaultFOV[MAXPLAYERS];
static int ScreenRef[MAXPLAYERS][Screen_MAX];

enum
{
	CURSOR_WHITE = 0,
	CURSOR_RED = 1,
}
#define CURSOR_DEFAULT		" ▶ "
#define CURSOR_SELECTABLE	"［ ］"
#define CURSOR_MOVE		" ◇ "
static Handle SyncHud;

void ZR_StoreMouse_PluginStart()
{
	SyncHud = CreateHudSynchronizer();
	RegConsoleCmd("sm_new_shop", 		Access_StoreMouseViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);

	for(int a; a < sizeof(ScreenRef); a++)
	{
		for(int b; b < sizeof(ScreenRef[]); b++)
		{
			ScreenRef[a][b] = -1;
		}
	}
}


public Action Access_StoreMouseViaCommand(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(f_PreventMovementClient[client] < GetGameTime())
	{
		f_PreventMovementClient[client] = GetGameTime() + 0.1;
		Store_ApplyAttribs(client); //update.
	}
	SetEntityFlags(client, GetEntityFlags(client)|FL_FROZEN|FL_ATCONTROLS);
	SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_PIPES_AND_CHARGE | 
	HIDEHUD_HEALTH | 
	HIDEHUD_BUILDING_STATUS | 
	HIDEHUD_CLOAK_AND_FEIGN |
	HIDEHUD_MISCSTATUS | 
	HIDEHUD_WEAPONSELECTION);
	LastMousePos[client] = {0.5, 0.5};
	b_InsideMenu[client] = true;
	i_NextRenderMouse[client] = CURSOR_WHITE;

	LastFOV[client] = GetEntProp(client, Prop_Send, "m_iFOV");
	LastDefaultFOV[client] = GetEntProp(client, Prop_Send, "m_iDefaultFOV");
	return Plugin_Handled;
}
bool StoreMouse_PlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], int weapon, const int rawMouse[2])
{
	if(!b_InsideMenu[client])
	{
		// TODO: Make cleaning function
		for(int a; a < sizeof(ScreenRef[]); a++)
		{
			RemoveScreenItem(ScreenRef[client][a]);
		}

		return false;
	}

	if((buttons & IN_JUMP))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN);
		//we jumped, cancel menu!
		b_InsideMenu[client] = false;
		if(f_PreventMovementClient[client] + 0.1 < GetGameTime())
			f_PreventMovementClient[client] = 0.0;
		SetEntityFlags(client, GetEntityFlags(client)& ~(FL_FROZEN|FL_ATCONTROLS));
		Store_ApplyAttribs(client); //update.
		return true;
	}
	float mouse[2];
	for(int i; i < sizeof(mouse); i++)
	{
		if(i == 0)
		{
			//assume 16 : 9 ratio for now
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (0.0005 * (9.0 / 16.0) * TickrateModify));
		}
		else
		{
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (0.0005 * TickrateModify));
		}

		mouse[i] = fClamp(mouse[i], 0.02, 0.99);
	}
	if((buttons & IN_ATTACK))
	{
		i_NextRenderMouse[client] = CURSOR_RED;
	}
	LastMousePos[client] = mouse;
	
	StoreMouse_RenderItems(client);
	StoreMouse_RenderMouse(client, mouse);
	return true;
}
void StoreMouse_RenderMouse(int client, float mouse[2])
{
	int color[4] = {255, 255, 255, 255};
	float cursorPos[3];
	char cursor[8];

	cursor = CURSOR_DEFAULT;
	switch(i_NextRenderMouse[client])
	{
		case CURSOR_RED:
		{
			color = {255, 65, 65, 255};
			cursor = CURSOR_MOVE;
			mouse[0] += 0.01;
			mouse[1] += 0.02;
		}
	}
	i_NextRenderMouse[client] = CURSOR_WHITE;
	
	SetHudTextParams(mouse[0]-0.01, mouse[1]-0.02, 0.5, color[0], color[1], color[2], color[3], 0, 0.0, 0.0, 0.0);
	ShowSyncHudText(client, SyncHud, cursor);
}

static void StoreMouse_RenderItems(int client)
{
	// Creates an item, if it doesn't already exist
	CreateScreenText(ScreenRef[client][Screen_Title], client, {0.5, 0.2});
	// Updates text for the item
	DisplayScreenText(ScreenRef[client][Screen_Title], "Store");

	// Creates an item, if it doesn't already exist
	CreateScreenSprite(ScreenRef[client][Screen_Sprite1], client, "materials/test_sprite_sniper2.vmt", {0.5, 0.5}, 100.0);

	// Removes an item, if it exists
	//RemoveScrrenItem(ScreenRef[client][Screen_Sprite1]);
}

static void GetCursorVector(int client, const float angle[3], const float mouse[2], float cursorVector[3])
{
	float aspectRatio = (9.0 / 16.0);

	float maxX = ArcTangent2(DegToRad(LastDefaultFOV[client] * 0.5), 1.0);
	float maxY = ArcTangent2(DegToRad(LastDefaultFOV[client] * 0.5 / aspectRatio), 1.0);

	float cursorX = 4.0 * (mouse[0] - 0.5) * maxX;
	float cursorY = 2.0 * aspectRatio * (mouse[1] - 0.5) * maxY;

	float ang[3];
	ang[0] = DegToRad(angle[0]);
	ang[1] = DegToRad(angle[1]);
	ang[2] = DegToRad(angle[2]);

	float cursor[3];
	cursor[0] = 1.0;
	cursor[1] = -cursorX;
	cursor[2] = -cursorY;

	float matRotation[3][3];
	Matrix_GetRotationMatrix(matRotation, ang[2], ang[0], ang[1]);

	Matrix_VectorMultiply(matRotation, cursor, cursorVector);
}

static void CreateScreenText(int &ref, int client, const float pos[2], float scale = 225.0, const int color[4] = {255, 255, 255, 255}, bool rainbow = false)
{
	if(EntRefToEntIndex(ref) != -1)
		return;
	
	float vec[3];
	GetClientEyeAngles(client, vec);
	GetCursorVector(client, vec, pos, vec);

	ScaleVector(vec, scale); // Higher = less text size

	float eyePos[3];
	GetClientEyePosition(client, eyePos);
	AddVectors(eyePos, vec, vec);	// Add to position

	ref = SpawnFormattedWorldText("ABC\n123", vec, 10, color, client, rainbow);
	if(ref != -1)
	{
		DispatchKeyValueInt(ref, "font", 5);
		SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);
		SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
		ref = EntIndexToEntRef(ref);
	}
}

static void DisplayScreenText(int ref, const char[] message)
{
	if(ref != -1)
		DispatchKeyValue(ref, "message", message);
}

static void CreateScreenSprite(int &ref, int client, const char[] material, const float pos[2], float scale = 100.0)
{
	if(EntRefToEntIndex(ref) != -1)
		return;
	
	float ang[3], offset[3];
	GetClientEyeAngles(client, ang);
	GetCursorVector(client, ang, pos, offset);

	ScaleVector(offset, scale); // Higher = less text size

	float vec[3];
	GetClientEyePosition(client, vec);
	AddVectors(vec, offset, vec);	// Add to position

	ref = CreateEntityByName("env_sprite_oriented");
	if(ref != -1)
	{
		DispatchKeyValue(ref, "model", material);
		
		DispatchSpawn(ref);
		SetEdictFlags(ref, (GetEdictFlags(ref) & ~FL_EDICT_ALWAYS));

		TeleportEntity(ref, vec, ang, NULL_VECTOR);
		SetParent(client, ref, "", offset);

		AcceptEntityInput(ref, "ShowSprite");
		
		SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);
		SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
		ref = EntIndexToEntRef(ref);
	}
}

static void RemoveScreenItem(int &ref)
{
	if(ref != -1)
	{
		if(EntRefToEntIndex(ref) != -1)
			RemoveEntity(ref);
		
		ref = -1;
	}
}

static Action SetTransmit_Owner(int entity, int client)
{
	SetEdictFlags(entity, (GetEdictFlags(entity) & ~FL_EDICT_ALWAYS));
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") == client ? Plugin_Continue : Plugin_Handled;
}