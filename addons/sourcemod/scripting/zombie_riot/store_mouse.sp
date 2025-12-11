#pragma semicolon 1
#pragma newdecls required

enum
{
	Screen_Title = 0,
	Screen_Sprite1,
	Screen_OwnedWeapons,

	Screen_MAX
}
static bool b_InsideMenu[MAXPLAYERS];
static float LastMousePos[MAXPLAYERS][2];
static int i_NextRenderMouse[MAXPLAYERS];
static float ClickMousePos[MAXPLAYERS][2];
static float f_TranslateHoveredText[MAXPLAYERS];

#define PLAYSOUND_CLICK "ui/buttonclick.wav"
#define PLAYSOUND_CLICK_RELEASE "ui/buttonclickrelease.wav"
#define PLAYSOUND_CLOSESHOP "ambient/levels/citadel/pod_close1.wav"
#define PLAYSOUND_OPENSHOP "items/battery_pickup.wav"

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
static Handle SyncHudTrans;

#define SCALE_FORITEMS 0.1
void ZR_StoreMouse_PluginStart()
{
	PrecacheSound(PLAYSOUND_CLICK);
	PrecacheSound(PLAYSOUND_CLICK_RELEASE);
	PrecacheSound(PLAYSOUND_CLOSESHOP);
	PrecacheSound(PLAYSOUND_OPENSHOP);
	SyncHud = CreateHudSynchronizer();
	SyncHudTrans = CreateHudSynchronizer();
	RegConsoleCmd("sm_new_shop", 		Access_StoreMouseViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
	Zero(f_TranslateHoveredText);

	RegConsoleCmd("zr_newshop_text", StoreMouse_DebugText, "Debug", FCVAR_HIDDEN);
	RegConsoleCmd("zr_newshop_sprite", StoreMouse_DebugSprite, "Debug", FCVAR_HIDDEN);

	for(int a; a < sizeof(ScreenRef); a++)
	{
		for(int b; b < sizeof(ScreenRef[]); b++)
		{
			ScreenRef[a][b] = -1;
		}
	}
}

static Action StoreMouse_DebugText(int client, int args)
{
	if(args == 4)
	{
		float pos[2];
		pos[0] = GetCmdArgFloat(1);
		pos[1] = GetCmdArgFloat(2);

		if(pos[0] >= 0.0 && pos[0] <= 1.0 &&
			pos[1] >= 0.0 && pos[1] <= 1.0)
		{
			float scale = GetCmdArgFloat(3);

			char message[256];
			GetCmdArg(4, message, sizeof(message));
			ReplaceString(message, sizeof(message), "\\n", "\n");
			ReplaceString(message, sizeof(message), "|", "\n");

			RemoveScreenItem(ScreenRef[client][Screen_Sprite1]);
			CreateScreenText(ScreenRef[client][Screen_Sprite1], client, pos, scale);
			DisplayScreenText(ScreenRef[client][Screen_Sprite1], message);
			return Plugin_Handled;
		}
	}

	ReplyToCommand(client, "[SM] Usage: zr_newshop_text <x> <y> <size> <text>");
	return Plugin_Handled;
}

static Action StoreMouse_DebugSprite(int client, int args)
{
	if(args == 5)
	{
		float pos[2];
		pos[0] = GetCmdArgFloat(1);
		pos[1] = GetCmdArgFloat(2);

		if(pos[0] >= 0.0 && pos[0] <= 1.0 &&
			pos[1] >= 0.0 && pos[1] <= 1.0)
		{
			int width = GetCmdArgInt(3);
			int height = GetCmdArgInt(4);
			
			char filepath[256];
			GetCmdArg(5, filepath, sizeof(filepath));
		//	if(!StrContains(filepath, "materials") && StrContains(filepath, ".vmt") != -1)
			{
				RemoveScreenItem(ScreenRef[client][Screen_Sprite1]);
				CreateScreenVGUI(ScreenRef[client][Screen_Sprite1], client, filepath, pos, width, height);
				return Plugin_Handled;
			}
		}
	}

	ReplyToCommand(client, "[SM] Usage: zr_newshop_sprite <x> <y> <width> <height> <VGUI script> <filepath, no vmt or material>");
	return Plugin_Handled;
}

void ZR_StoreMouse_MapStart()
{
	AddToDownloadsTable("materials/zombie_riot/shopoverlay/shop_overlay_1.vmt");
	AddToDownloadsTable("materials/zombie_riot/shopoverlay/shop_overlay_1.vtf");
	Zero(f_TranslateHoveredText);
}

void ZR_OpenMouseStore(int client)
{
	if(b_InsideMenu[client])
	{	
		CancelStoreMouseMenu(client);
		return;
	}
	if(f_PreventMovementClient[client] < GetGameTime())
	{
		f_PreventMovementClient[client] = GetGameTime() + 0.1;
		Store_ApplyAttribs(client); //update.
	}
	SPrintToChat(client, "Please click tab instead to open the store.");
	SendConVarValue(client, mp_tournament, "0");
	EmitSoundToClient(client, PLAYSOUND_OPENSHOP, client,_,_,_, _,80,.soundtime = GetGameTime() - (0.15 / 0.8));
	DoOverlay(client, "zombie_riot/shopoverlay/shop_overlay_1", 0);
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
	StoreMouse_OpenMenu(client);

	LastFOV[client] = GetEntProp(client, Prop_Send, "m_iFOV");
	LastDefaultFOV[client] = GetEntProp(client, Prop_Send, "m_iDefaultFOV");
}
public Action Access_StoreMouseViaCommand(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	ZR_OpenMouseStore(client);
	return Plugin_Handled;
}
#define DEFAULT_MOUSE_SENSIVITY 0.0006
bool StoreMouse_PlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], int weapon, const int rawMouse[2])
{
	if(!b_InsideMenu[client])
		return false;

	if((buttons & IN_JUMP))
	{
		CancelStoreMouseMenu(client);
		return false;
	}
	float mouse[2];
	for(int i; i < sizeof(mouse); i++)
	{
		if(i == 0)
		{
			//assume 16 : 9 ratio for now
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (DEFAULT_MOUSE_SENSIVITY * (9.0 / 16.0) * TickrateModify));
		}
		else
		{
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (DEFAULT_MOUSE_SENSIVITY * TickrateModify));
		}

		mouse[i] = fClamp(mouse[i], 0.02, 0.99);
	}
	static int holding[MAXPLAYERS];
	if((buttons & IN_ATTACK))
	{
		if(!(holding[client] & IN_ATTACK))
		{
			PlaySoundClick(client, 0);
			holding[client] |= IN_ATTACK;
		}
		i_NextRenderMouse[client] = CURSOR_RED;
		ClickMousePos[client] = mouse;
	}
	else
	{
		if(holding[client] & IN_ATTACK)
		{
			PlaySoundClick(client, 1);
			if(fabs(ClickMousePos[client][0] - mouse[0]) < 0.01 &&
				fabs(ClickMousePos[client][1] - mouse[1]) < 0.01)
			{
				PrintToChat(client, "%f %f", ClickMousePos[client][0], ClickMousePos[client][1]);
			}
		}
		holding[client] &= ~IN_ATTACK;
		
	}
	LastMousePos[client] = mouse;
	/*
	if(LastMousePos[client][1] >= 0.95
	 || LastMousePos[client][1] <= 0.05
	 || LastMousePos[client][0] >= 0.95
	 || LastMousePos[client][0] <= 0.05)
	 {
		CancelStoreMouseMenu(client);
		return false;
	 }
	*/
	
	StoreMouse_RenderItems(client);
	StoreMouse_RenderMouse(client, mouse);
	return true;
}

void CancelStoreMouseMenu(int client)
{
	SendConVarValue(client, mp_tournament, "1");
	HideMenuInstantly(client);
	//show a blank page to instantly hide it
	CancelClientMenu(client);
	ClientCommand(client, "slot10");
	ResetStoreMenuLogic(client);
	for(int a; a < sizeof(ScreenRef[]); a++)
	{
		RemoveScreenItem(ScreenRef[client][a]);
	}

	EmitSoundToClient(client, PLAYSOUND_CLOSESHOP, client,_,_,_, _,80, .soundtime = GetGameTime() - (0.5 / 0.8));
	DoOverlay(client, "", 0);
	SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN);
	//we jumped, cancel menu!
	b_InsideMenu[client] = false;
	if(f_PreventMovementClient[client] < (GetGameTime() + 0.2))
	{
		f_PreventMovementClient[client] = 0.0;
	}
	SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));
	//RequestFrames(FixStandStillDelay, 3, EntIndexToEntRef(client));
	Store_ApplyAttribs(client); //update.
}
void StoreMouse_RenderMouse(int client, float mouse[2])
{
	int color[4] = {255, 255, 255, 255};
//	float cursorPos[3];
	char cursor[8];

	cursor = CURSOR_DEFAULT;
	switch(i_NextRenderMouse[client])
	{
		case CURSOR_RED:
		{
			color = {255, 65, 65, 255};
			cursor = CURSOR_MOVE;
			mouse[0] -= 0.0085;
			mouse[1] -= 0.01;
		}
	}
	mouse[0] += 0.006;
	mouse[1] += 0.008;
	i_NextRenderMouse[client] = CURSOR_WHITE;
	
	if(f_TranslateHoveredText[client] < GetGameTime())
	{
		f_TranslateHoveredText[client] = GetGameTime() + 0.25;
		//what do we hover over, translate for player.
		SetHudTextParams(-1.0, 1.0, 0.5, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, SyncHudTrans, "이 텍스트는 마우스를 올려 놓으면 무엇이든 번역됩니다.\n공백도 지원합니다!");
	}
	else
	{
		SetHudTextParams(mouse[0]-0.01, mouse[1]-0.02, 0.5, color[0], color[1], color[2], color[3], 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, SyncHud, cursor);
	}
}


void PlaySoundClick(int client, int clickmode)
{
	switch(clickmode)
	{
		case 0:
		{
			EmitSoundToClient(client, PLAYSOUND_CLICK, client);
		}
		case 1:
		{
			EmitSoundToClient(client, PLAYSOUND_CLICK_RELEASE, client);
		}
	}
}
static void StoreMouse_RenderItems(int client)
{
	// Creates an item, if it doesn't already exist
	CreateScreenText(ScreenRef[client][Screen_Title], client, {0.5, 0.15}, 100.0);
	// Updates text for the item
	DisplayScreenText(ScreenRef[client][Screen_Title], "Store");

	// Creates an item, if it doesn't already exist
	CreateScreenVGUI(ScreenRef[client][Screen_Sprite1], client, "materials/test_sprite_sniper2", {0.5, 0.5});

	// Removes an item, if it exists
	//RemoveScrrenItem(ScreenRef[client][Screen_Sprite1]);
	StoreMouse_RenderItems_Internal(client);
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

	ScaleVector(vec, scale * SCALE_FORITEMS); // Higher = less text size

	float eyePos[3];
	GetClientEyePosition(client, eyePos);
	AddVectors(eyePos, vec, vec);	// Add to position

	ref = SpawnFormattedWorldText("ABC\n123", vec, 10, color, -1, rainbow);
	if(ref != -1)
	{
		DispatchKeyValueInt(ref, "font", 8);
		DispatchKeyValueFloat(ref, "textsize", 10.0 * SCALE_FORITEMS);
		SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);
		SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
		ref = EntIndexToEntRef(ref);
	}

}

static void DisplayScreenText(int ref, const char[] message)
{
	if(ref != -1)
	{
		SetEntPropString(ref, Prop_Send, "m_szText", message);
		SetEntProp(ref, Prop_Data, "m_bForcePurgeFixedupStrings", true);
	}
}



enum
{
	VGUI_SCREEN_ACTIVE = 1,
	VGUI_SCREEN_VISIBLE_TO_TEAMMATES = 2,
	VGUI_SCREEN_ATTACHED_TO_VIEWMODEL = 4,
	VGUI_SCREEN_TRANSPARENT = 8,
	VGUI_SCREEN_ONLY_USABLE_BY_OWNER = 16,
};

#define MAX_MATERIAL_STRING_BITS 10
#define MAX_MATERIAL_STRINGS (1 << MAX_MATERIAL_STRING_BITS)
#define OVERLAY_MATERIAL_INVALID_STRING (MAX_MATERIAL_STRINGS - 1)
static void CreateScreenVGUI(int &ref, int client, const char[] material, const float pos[2], int width = 1000, int height = 562)
{
	if(EntRefToEntIndex(ref) != -1)
		return;
	
	float ang[3], offset[3];
	GetClientEyeAngles(client, ang);
	GetCursorVector(client, ang, pos, offset);

	//infront of face!
	ScaleVector(offset, 10.0); // Higher = less text size

	float vec[3];
	GetClientEyePosition(client, vec);
	AddVectors(vec, offset, vec);	// Add to position
	/*
	RunScriptCode(client, -1, -1, "local background = SpawnEntityFromTable(\"vgui_screen\","...
									"{"...
										"origin          = self.EyePosition(),"...
										"angles          = QAngle(),"...
										"panelname       = \"pda_panel_spy_invis\","...
										"overlaymaterial = \"tf2ware_ultimate/grey\","...
										"width           = 50,"...
										"height          = 50.0,"...
									"}); "...
									"NetProps.SetPropInt(background, \"m_fScreenFlags\", 17);");
	*/
	
	ref = CreateEntityByName("vgui_screen");
	if(ref != -1)
	{
		ang[1] -= 90.0;
		ang[2] += 90.0;
		DispatchKeyValueVector(ref, "origin", vec);
		DispatchKeyValueVector(ref, "angles", ang);
		DispatchKeyValue(ref, "panelname", "pda_panel_spy_invis");
		PrintToChatAll("%s material",material);
	//	SetEntProp(ref, Prop_Send, "m_nOverlayMaterial", OVERLAY_MATERIAL_INVALID_STRING);
		DispatchKeyValue(ref, "overlaymaterial", material);
		DispatchKeyValueInt(ref, "width", width);
		DispatchKeyValueInt(ref, "height", height);
		DispatchSpawn(ref);
	//	SetEdictFlags(ref, (GetEdictFlags(ref) & ~FL_EDICT_ALWAYS));^
	//	SetEntPropEnt(ref, Prop_Send, "m_hOwnerEntity", client);

		SetEntProp(ref, Prop_Send, "m_fScreenFlags", VGUI_SCREEN_ACTIVE | VGUI_SCREEN_ONLY_USABLE_BY_OWNER);
	//	SDKHook(ref, SDKHook_SetTransmit, SetTransmit_Owner);
		ref = EntIndexToEntRef(ref);
	}

}

static void RemoveScreenItem(int &ref)
{
	if(ref != -1)
	{
		if(IsValidEntity(EntRefToEntIndex(ref)))
			RemoveEntity(ref);
		
		ref = -1;
	}
}

static Action SetTransmit_Owner(int entity, int client)
{
	SetEdictFlags(entity, (GetEdictFlags(entity) & ~FL_EDICT_ALWAYS));
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") == client ? Plugin_Continue : Plugin_Handled;
}

bool InsideShopMenu(int client)
{
	return b_InsideMenu[client];
}



void StoreMouse_OpenMenu(int client)
{
	if(!InsideShopMenu(client))
		return;
	
	MenuPage(client);
}
static void MenuPage(int client)
{
	Menu menu = new Menu(StoreMouse_ButtonInput);
	menu.SetTitle(" ");
	
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.AddItem("-1", "");
	menu.ExitBackButton = true;
	menu.Pagination = false;
	SetMenuOptionFlags(menu, MENUFLAG_NO_SOUND);
	menu.Display(client, MENU_TIME_FOREVER);
}

public int StoreMouse_ButtonInput(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
	//		delete menu;
		}
		case MenuAction_Select:
		{
			choice++;
			PrintToChatAll("choice %i",choice);
			StoreMouse_OpenMenu(client);
			PlaySoundClick(client, 0);
			PlaySoundClick(client, 1);
		}
	}
}

void StoreMouse_RenderItems_Internal(int client)
{
	CreateScreenText(ScreenRef[client][Screen_OwnedWeapons], client, {0.195, 0.27}, 200.0);
	DisplayScreenText(ScreenRef[client][Screen_OwnedWeapons], "Owned Weapons");
}