#pragma semicolon 1
#pragma newdecls required

/*
	https://github.com/geominorai/sm-rts-starter
*/

#define ZERO_VECTOR		{0.0, 0.0, 0.0}
#define DEFAULT_ANGLES		{45.0, 0.0, 0.0}
#define HEALTH_BAR_HP_SCALE	0.0001
#define AXIS_OFFSET		0.196350 // FLOAT_PI/16
#define ZOOM_DECEL_MULTIPLIER	0.9
#define SCROLL_DECEL_MULTIPLIER	0.9
#define MOUSE2_DRAG_START_DELAY	0.1
#define MOUSE2_DRAG_MIN_DIST	0.01
#define MOUSE2_DRAG_SPEED_MULT	4.0
#define HUD_TEXT_COLORR_IDLE	{255, 255, 255, 255}
#define HUD_TEXT_COLORR_SCROLL	{  0, 255,   0, 255}
#define HUD_TEXT_COLORR_SELECT	{  0, 255,   0, 255}
#define COLORR_WHITE				{255, 255, 255, 255}
#define COLORR_RED				{255,   0,   0, 255}
#define COLORR_YELLOW			{255, 255,   0, 255}
#define COLORR_GREEN				{  0, 255,   0, 255}
#define COLORR_GRAY				{ 128,  128,  128, 255}

enum
{
	OBS_MODE_NONE = 0,	// not in spectator mode
	OBS_MODE_DEATHCAM,	// special mode for death cam animation
	OBS_MODE_FREEZECAM,	// zooms to a target, and freeze-frames on them
	OBS_MODE_FIXED,		// view from a fixed camera position
	OBS_MODE_IN_EYE,	// follow a player in first person view
	OBS_MODE_CHASE,		// follow a player in third person view
	OBS_MODE_ROAMING,	// free roaming

	NUM_OBSERVER_MODES
};

#define IN_MAX	26

static const char LaserModel[] = "sprites/laserbeam.vmt";

#define CURSOR_DEFAULT		" ▶ "
#define CURSOR_SELECTABLE	"［ ］"
#define CURSOR_MOVE		" ◇ "

static const char ScrollCursors[][] =
{
	" ▵ ",
	" ◸ ",
	" ◃ ",
	" ◺ ",
	" ▿ ",
	" ◿ ",
	" ▹ ",
	" ◹ "
};

enum
{
	Key_LeftClick,
	Key_RightClick,
	Key_Ctrl,
	Key_Escape,
	Key_SelectAll,
	Key_IdleWorker,
	Key_Delete,

	Key_AdjustCamera,
	Key_ZoomIn,
	Key_ZoomOut,
	Key_MoveUp,
	Key_MoveDown,
	Key_MoveLeft,
	Key_MoveRight,

	Key_Skill1,
	Key_Skill2,
	Key_Skill3,
	Key_Skill4,
	Key_Skill5,

	Key_Attack,
	Key_Stand,
	Key_Patrol,
	Key_Alt4,
	Key_Alt5,

	Key_MAX
}

static const char DisplayKey[Key_MAX][] =
{
	"Left-Click",
	"Right-Click",
	"Add To Selection",
	"Clear Selection",
	"Select All Units",
	"Select Idle Worker",
	"Delete Selected",

	"Adjust Camera",
	"Zoom In",
	"Zoom Out",
	"Scroll Up",
	"Scroll Down",
	"Scroll Left",
	"Scroll Right",

	"Q (Skill 1)",
	"W (Skill 2)",
	"E (Skill 3)",
	"R (Skill 4)",
	"T (Skill 5)",

	"A (Attack Move)",
	"S (Stand Ground)",
	"D (Patrol Area)",
	"F (Skill 9)",
	"G (Skill 10)"
};

static const char DefaultCmd[Key_MAX][] =
{
	"b 0",
	"b 11",
	"b 2",
	"b 1",
	"b 16",
#if defined RTS
	"+use_action_slot_item",
	"dropitem",
#else
	"<unbound>",
	"dropitem",
#endif

	"b 25",
#if defined RTS
	"invprev",
	"invnext",
#else
	"+inspect",
	"+use_action_slot_item",
#endif
	"<unbound>",
	"<unbound>",
	"<unbound>",
	"<unbound>",

#if defined RTS
	"lastinv",
#else
	"<unbound>",
#endif
	"b 3",
#if defined RTS
	"voicemenu",
#else
	"<unbound>",
#endif
	"b 13",
	"i 201",

	"b 9",
	"b 4",
	"b 10",
#if defined RTS
	"+inspect",
	"+taunt"
#else
	"<unbound>",
	"<unbound>"
#endif
};

static const char ButtonCmd[IN_MAX][] =
{
	"+attack",
	"+jump",
	"+duck",
	"+forward",
	"+back",
	"+use",
	"???",
	"+left",
	"+right",
	"+moveleft",
	"+moveright",
	"+attack2",
	"???",
	"+reload",
	"+alt1",
	"+alt2",
	"+showscores",
	"+speed",
	"+walk",
	"+zoom",
	"???",
	"???",
	"???",
	"+grenade1",
	"+grenade2",
	"+attack3"
};

#if defined ZR
enum
{
	Move_Normal = 0,
	Move_Attack,
	Move_HoldPos,
	Move_Patrol,
}
#endif

static Cookie MouseCookie;
static Cookie BindCookie;
static Handle SyncHud;

static bool RTSEnabled[MAXTF2PLAYERS];
static ArrayList Selected[MAXTF2PLAYERS];
static int FocusRef[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int CameraRef[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int LastFOV[MAXTF2PLAYERS];
static int LastDefaultFOV[MAXTF2PLAYERS];
static float MinZoom[MAXTF2PLAYERS];
static float LastMousePos[MAXTF2PLAYERS][2];
static float RotateMousePos[MAXTF2PLAYERS][2];
static float StartDragMousePos[MAXTF2PLAYERS][2];
static float CameraVector[MAXTF2PLAYERS][3];
static float RotateVector[MAXTF2PLAYERS][3];
static float CameraDistance[MAXTF2PLAYERS];
static float RotateDistance[MAXTF2PLAYERS];
static float CameraMoveDrag[MAXTF2PLAYERS][3];
static float SelectionVerticies[MAXTF2PLAYERS][4][3];
static bool InSelectDrag[MAXTF2PLAYERS];
static bool InMoveDrag[MAXTF2PLAYERS];
static int BeamRef[MAXENTITIES+1][4];
static bool NewPress[MAXTF2PLAYERS][Key_MAX];	// Input next frame
static bool LastPress[MAXTF2PLAYERS][Key_MAX];	// Input last frame
static bool HoldPress[MAXTF2PLAYERS][Key_MAX];	// Input being held
static int NextMoveType[MAXTF2PLAYERS];
static int BindingKey[MAXTF2PLAYERS] = {-1, ...};

static char KeyBinds[MAXTF2PLAYERS][Key_MAX][32];
static float AspectRatio[MAXTF2PLAYERS];
static float MouseSensitivity[MAXTF2PLAYERS];
static float ScrollSpeed[MAXTF2PLAYERS];
static float ZoomSpeed[MAXTF2PLAYERS];

void RTSCamera_PluginStart()
{
	SyncHud = CreateHudSynchronizer();

	MouseCookie = new Cookie("rts_mouse", "RTS Mouse Settings", CookieAccess_Protected);
	BindCookie = new Cookie("rts_bind", "RTS Binds Settings", CookieAccess_Protected);
	
	AddCommandListener(OnSingleCommand, "-taunt");	// -taunt is called when opening the taunt menu
	AddCommandListener(OnSingleCommand, "dropitem");
	AddCommandListener(OnSingleCommand, "voicemenu");

	RegConsoleCmd("sm_rts", RTSCamera_CommandMenu, "RTS Camera Menu");
	RegConsoleCmd("sm_rtstoggle", RTSCamera_CommandToggle, "Toggle RTS Camera");

	for(int i; i <= MAXENTITIES; i++)
	{
		if(i < MAXTF2PLAYERS)
			SetDefaultValues(i);
		
		for(int a; a < sizeof(BeamRef[]); a++)
		{
			BeamRef[i][a] = INVALID_ENT_REFERENCE;
		}
	}
}

void RTSCamera_PluginEnd()
{
	for(int i; i <= MAXENTITIES; i++)
	{
		RemoveSelectBeams(i);
	}
}

void RTSCamera_ClientDisconnect(int client)
{
	RTSEnabled[client] = false;
	
	if(RTSCamera_InCamera(client))
		DisableCamera(client);
	
	SetDefaultValues(client);
}

void RTSCamera_MapStart()
{
	PrecacheModel(LaserModel);
}

void RTSCamera_ClientCookiesCached(int client)
{
	LoadMouseCookie(client);
	LoadKeybinds(client);
}

static void SetDefaultValues(int client)
{
	AspectRatio[client] = 1.777777;	// 16:9
	MouseSensitivity[client] = 0.0004;
	ScrollSpeed[client] = 500.0;
	ZoomSpeed[client] = 600.0;

	for(int i; i < sizeof(KeyBinds[]); i++)
	{
		strcopy(KeyBinds[client][i], sizeof(KeyBinds[][]), DefaultCmd[i]);
	}
}

public Action RTSCamera_CommandMenu(int client, int args)
{
	if(client)
	{
		ShowMenu(client, 0);
	}
	return Plugin_Handled;
}

public Action RTSCamera_CommandToggle(int client, int args)
{
	if(client)
	{
		ToggleRTS(client);
	}
	return Plugin_Handled;
}

static void ShowMenu(int client, int page)
{
	SetGlobalTransTarget(client);
	Menu menu = new Menu(RTSCamera_ShowMenuH);

	char data[16], buffer[64];

	switch(page)
	{
		case 0:
		{
			bool cached = AreClientCookiesCached(client);

			menu.SetTitle("%t\n ", "Real-Time Camera");

			FormatEx(buffer, sizeof(buffer), "%t (/rtstoggle)\n ", RTSEnabled[client] ? "Disable Camera" : "Enable Camera");
			menu.AddItem("0", buffer);

			FormatEx(buffer, sizeof(buffer), "%t", "Mouse Settings");
			menu.AddItem("1", buffer, cached ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			FormatEx(buffer, sizeof(buffer), "%t", "Bind Settings");
			menu.AddItem("9", buffer, cached ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		case 1, 2, 3, 4, 5:
		{
			menu.SetTitle("%t\n%t\n ", "Real-Time Camera", "Mouse Settings");

			FormatEx(buffer, sizeof(buffer), "%t: %.1f", "Mouse Sensitivity", MouseSensitivity[client] * 10000.0);
			if(page == 2)
			{
				menu.AddItem("21", "^");
				menu.AddItem("22", buffer);
				menu.AddItem("23", "v\n ");
			}
			else
			{
				if(page == 3)
					StrCat(buffer, sizeof(buffer), "\n ");
				
				menu.AddItem("2", buffer);
			}

			FormatEx(buffer, sizeof(buffer), "%t: %d:9", "Screen Aspect Ratio", RoundFloat(AspectRatio[client] * 9.0));
			if(page == 3)
			{
				menu.AddItem("31", "^");
				menu.AddItem("32", buffer);
				menu.AddItem("33", "v\n ");
			}
			else
			{
				if(page == 4)
					StrCat(buffer, sizeof(buffer), "\n ");
				
				menu.AddItem("3", buffer);
			}

			FormatEx(buffer, sizeof(buffer), "%t: %.1f", "Scroll Speed", ScrollSpeed[client] / 100.0);
			if(page == 4)
			{
				menu.AddItem("41", "^");
				menu.AddItem("42", buffer);
				menu.AddItem("43", "v\n ");
			}
			else
			{
				if(page == 5)
					StrCat(buffer, sizeof(buffer), "\n ");
				
				menu.AddItem("4", buffer);
			}

			FormatEx(buffer, sizeof(buffer), "%t: %.1f", "Zoom Speed", ZoomSpeed[client] / 100.0);
			if(page == 5)
			{
				menu.AddItem("51", "^");
				menu.AddItem("52", buffer);
				menu.AddItem("53", "v\n ");
			}
			else
			{
				if(page == 6)
					StrCat(buffer, sizeof(buffer), "\n ");
				
				menu.AddItem("5", buffer);
			}

			menu.ExitBackButton = true;
		}
		case 9:
		{
			menu.SetTitle("%t\n%t\n ", "Real-Time Camera", "Bind Settings");

			for(int i; i < Key_MAX; i++)
			{
				if(StrContains(KeyBinds[client][i], "b ") == 0)
				{
					int button = StringToInt(KeyBinds[client][i][2]);
					if(button >= 0 && button < sizeof(ButtonCmd))
					{
						strcopy(buffer, sizeof(buffer), ButtonCmd[button]);
					}
					else
					{
						strcopy(buffer, sizeof(buffer), "???");
					}
				}
				else if(StrContains(KeyBinds[client][i], "i ") == 0)
				{
					FormatEx(buffer, sizeof(buffer), "impulse%s", KeyBinds[client][i][1]);
				}
				else
				{
					strcopy(buffer, sizeof(buffer), KeyBinds[client][i]);
				}
				
				IntToString(i + 1000, data, sizeof(data));
				Format(buffer, sizeof(buffer), "%t: %s", DisplayKey[i], buffer);
				menu.AddItem(data, buffer);
			}

			menu.ExitBackButton = true;
		}
		default:
		{
			if(page > 999)
			{
				int key = page - 1000;
				menu.SetTitle("%t\n%t\n%t\n ", "Real-Time Camera", "Bind Settings", DisplayKey[key]);

				FormatEx(buffer, sizeof(buffer), "%t\n ", "Press a key to bind");
				menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);

				FormatEx(buffer, sizeof(buffer), "%t", "Valid Key Info 1");
				menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);

				FormatEx(buffer, sizeof(buffer), "%t", "Valid Key Info 2");
				menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);

#if defined RTS
				FormatEx(buffer, sizeof(buffer), "%t", "Valid Key Info 3");
#else
				FormatEx(buffer, sizeof(buffer), "%t", "Valid Key Info 3 ZR");
#endif
				menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
			}
			else
			{
				menu.AddItem("-1", "Huh?", ITEMDRAW_DISABLED);
				menu.ExitBackButton = true;
			}
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int RTSCamera_ShowMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			BindingKey[client] = -1;
			if(choice == MenuCancel_ExitBack)
				ShowMenu(client, 0);
		}
		case MenuAction_Select:
		{
			char buffer[8];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int option = StringToInt(buffer);
			switch(option)
			{
				case 0:
				{
					ToggleRTS(client);
				}
				case 21:
				{
					MouseSensitivity[client] += 0.00001;
					SaveMouseCookie(client);
					option = 2;
				}
				case 22:
				{
					if(MouseSensitivity[client] == 0.0004)
					{
						MouseSensitivity[client] = -0.0004;
					}
					else
					{
						MouseSensitivity[client] = 0.0004;
					}

					SaveMouseCookie(client);
					option = 2;
				}
				case 23:
				{
					MouseSensitivity[client] -= 0.00001;
					SaveMouseCookie(client);
					option = 2;
				}
				case 31:
				{
					AspectRatio[client] = (RoundFloat(AspectRatio[client] * 9.0) + 1) / 9.0;
					SaveMouseCookie(client);
					option = 3;
				}
				case 32:
				{
					AspectRatio[client] = 1.777777;
					SaveMouseCookie(client);
					option = 3;
				}
				case 33:
				{
					AspectRatio[client] = (RoundFloat(AspectRatio[client] * 9.0) - 1) / 9.0;
					SaveMouseCookie(client);
					option = 3;
				}
				case 41:
				{
					ScrollSpeed[client] += 10.0;
					SaveMouseCookie(client);
					option = 4;
				}
				case 42:
				{
					if(ScrollSpeed[client] == 500.0)
					{
						ScrollSpeed[client] = -500.0;
					}
					else
					{
						ScrollSpeed[client] = 500.0;
					}
					
					SaveMouseCookie(client);
					option = 4;
				}
				case 43:
				{
					ScrollSpeed[client] -= 10.0;
					SaveMouseCookie(client);
					option = 4;
				}
				case 51:
				{
					ZoomSpeed[client] += 10.0;
					SaveMouseCookie(client);
					option = 5;
				}
				case 52:
				{
					if(ZoomSpeed[client] == 600.0)
					{
						ZoomSpeed[client] = -600.0;
					}
					else
					{
						ZoomSpeed[client] = 600.0;
					}

					SaveMouseCookie(client);
					option = 5;
				}
				case 53:
				{
					ZoomSpeed[client] -= 10.0;
					SaveMouseCookie(client);
					option = 5;
				}
				default:
				{
					if(option > 999)
						BindingKey[client] = option - 1000;
				}
			}

			ShowMenu(client, option);
		}
	}

	return 0;
}

bool RTSCamera_InCamera(int client)
{
	return FocusRef[client] != INVALID_ENT_REFERENCE;
}

void RTSCamera_PlayerRunCmdPre(int client, int buttons, int impulse, int weapon, const int rawMouse[2])
{
	if(!RTSEnabled[client] || !CanBeInCamera(client))
	{
		if(RTSCamera_InCamera(client))
			DisableCamera(client);
		
		if(BindingKey[client] != -1)
			ProcessInputs(client, buttons, impulse, weapon);
		
		return;
	}

	if(!RTSCamera_InCamera(client))
		EnableCamera(client);
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_DEATHCAM);
	
	bool pressed[Key_MAX], previous[Key_MAX], holding[Key_MAX];
	if(!ProcessInputs(client, buttons, impulse, weapon, pressed, previous, holding))
		return;
	
	float mouse[2];
	for(int i; i < sizeof(mouse); i++)
	{
		mouse[i] = LastMousePos[client][i] + (rawMouse[i] * MouseSensitivity[client]);

		if(!holding[Key_AdjustCamera])
			mouse[i] = fClamp(mouse[i], 0.02, 0.99);
	}

	LastMousePos[client] = mouse;

	int focus = EntRefToEntIndex(FocusRef[client]);
	int camera = EntRefToEntIndex(CameraRef[client]);

	float focusPos[3], cameraPos[3];
	GetEntPropVector(focus, Prop_Send, "m_vecOrigin", focusPos);
	GetEntPropVector(camera, Prop_Send, "m_vecOrigin", cameraPos);	// Relative to parent focus entity

	if(holding[Key_AdjustCamera])
	{
		if(pressed[Key_AdjustCamera])
		{
			RotateMousePos[client] = mouse;
			RotateVector[client] = CameraVector[client];
			RotateDistance[client] = CameraDistance[client];
		}

		// Incompatible since rotation requires fixed spherical radius that zooming would have changed
		holding[Key_ZoomIn] = false;
		holding[Key_ZoomOut] = false;

		// Incompatible since overlapping mouse dragging
		holding[Key_LeftClick] = false;
		holding[Key_RightClick] = false;

		float pitchAngle = ArcSine(RotateVector[client][2]) + FLOAT_PI;
		float yawAngle = 0.5 * FLOAT_PI - ArcTangent2(RotateVector[client][0], RotateVector[client][1]);

		pitchAngle -= (mouse[1]-RotateMousePos[client][1]) * 0.25 * FLOAT_PI;
		yawAngle -= (mouse[0]-RotateMousePos[client][0]) * 0.5 * FLOAT_PI;

		if(pitchAngle < ((-0.5 * FLOAT_PI) + AXIS_OFFSET + FLOAT_PI))
		{
			pitchAngle = (-0.5 * FLOAT_PI) + AXIS_OFFSET + FLOAT_PI;
		}
		else if(pitchAngle > (-AXIS_OFFSET + FLOAT_PI))
		{
			pitchAngle = -AXIS_OFFSET + FLOAT_PI;
		}

		float vec[3];
		vec[0] = Cosine(yawAngle);
		vec[1] = Sine(yawAngle);
		vec[2] = Sine(pitchAngle);

		float dist = SquareRoot((RotateDistance[client] * RotateDistance[client]) - (cameraPos[2] * cameraPos[2]));

		cameraPos[0] = -vec[0] * dist;//Clamp(, vecMins[0] - focusPos[0], vecMaxs[0] - focusPos[0]);
		cameraPos[1] = -vec[1] * dist;//Clamp(, vecMins[1] - focusPos[1], vecMaxs[1] - focusPos[1]);
		cameraPos[2] = vec[2] * RotateDistance[client];//Clamp(, vecMins[2] - focusPos[2], vecMaxs[2] - focusPos[2]);

		float ang[3];
		NormalizeVector(cameraPos, vec);
		ScaleVector(vec, -1.0);
		GetVectorAngles(vec, ang);

		TeleportEntity(camera, cameraPos, ang, ZERO_VECTOR);
		CameraVector[client] = vec;
	}
	else if(previous[Key_AdjustCamera])
	{
		LastMousePos[client] = RotateMousePos[client];
	}

	CameraDistance[client] = GetVectorLength(cameraPos);

	// Camera zoom

	float cameraVel[3];
	GetEntPropVector(camera, Prop_Data, "m_vecVelocity", cameraVel);

	if(holding[Key_ZoomIn] ^ holding[Key_ZoomOut])
	{
		cameraVel = CameraVector[client];
		ScaleVector(cameraVel, ZoomSpeed[client] * (holding[Key_ZoomIn] ? 1.0 : -1.0));
	}
	else
	{
		ScaleVector(cameraVel, ZOOM_DECEL_MULTIPLIER);
	}

	if(CameraDistance[client] < MinZoom[client] && cameraVel[2] < 0.0)
	{
		cameraVel = ZERO_VECTOR;
	}
	/*else if(focusPos[2]+cameraPos[2] > vecMaxs[2] && cameraVel[2] > 0.0)
	{
		cameraVel = ZERO_VECTOR;
	}*/

	// Planar scrolling

	float speed = ScrollSpeed[client] * CameraDistance[client] / MinZoom[client];

	float forwardVec[3];
	forwardVec[0] = CameraVector[client][0];
	forwardVec[1] = CameraVector[client][1];
	NormalizeVector(forwardVec, forwardVec);

	float up[3] = {0.0, 0.0, 1.0};
	float right[3];
	GetVectorCrossProduct(CameraVector[client], up, right);
	NormalizeVector(right, right);

	float focusVel[3];
	GetEntPropVector(focus, Prop_Data, "m_vecVelocity", focusVel);

	bool moving;
	char cursor[8];

	if(InMoveDrag[client])
	{
		focusVel = CameraMoveDrag[client];
	}
	else
	{
		int moveDir[2];
		if(mouse[0] == 0.02 || holding[Key_MoveLeft])
		{
			focusVel[0] = -speed * right[0];
			focusVel[1] = -speed * right[1];

			moveDir[0] = 1;
			moving = true;
		}
		else if(mouse[0] == 0.99 || holding[Key_MoveRight])
		{
			focusVel[0] = speed * right[0];
			focusVel[1] = speed * right[1];

			moveDir[0] = -1;
			moving = true;
		}

		if(mouse[1] == 0.02 || holding[Key_MoveUp])
		{
			if(moving)
			{
				focusVel[0] += speed * forwardVec[0];
				focusVel[1] += speed * forwardVec[1];
			} 
			else
			{
				focusVel[0] = speed * forwardVec[0];
				focusVel[1] = speed * forwardVec[1];

				moving = true;
			}

			moveDir[1] = 1;
		}
		else if(mouse[1] == 0.99 || holding[Key_MoveDown])
		{
			if(moving)
			{
				focusVel[0] += -speed * forwardVec[0];
				focusVel[1] += -speed * forwardVec[1];
			}
			else
			{
				focusVel[0] = -speed * forwardVec[0];
				focusVel[1] = -speed * forwardVec[1];

				moving = true;
			}

			moveDir[1] = -1;
		}

		if(moving)
		{
			float dragAng = ArcTangent2(float(moveDir[0]), float(moveDir[1]));
			if(dragAng < 0)
				dragAng += FLOAT_PI * 2.0;

			int index = RoundToNearest(dragAng / (FLOAT_PI / 4.0)) % sizeof(ScrollCursors);
			strcopy(cursor, sizeof(cursor), ScrollCursors[index]);
		}
	}

	if(!moving)
	{
		ScaleVector(focusVel, SCROLL_DECEL_MULTIPLIER);
	}

	// Move focus and camera entities but not while dragging for unit selection

	if(holding[Key_LeftClick])
	{
		SetEntPropVector(focus, Prop_Data, "m_vecVelocity", ZERO_VECTOR);
		SetEntPropVector(camera, Prop_Data, "m_vecVelocity", ZERO_VECTOR);
	}
	else
	{
		SetEntPropVector(focus, Prop_Data, "m_vecVelocity", focusVel);
		SetEntPropVector(camera, Prop_Data, "m_vecVelocity", cameraVel);
	}

	if(pressed[Key_Escape])
		delete Selected[client];

	if(Selected[Key_Delete] && Selected[client])
	{
		int length = Selected[client].Length;
		for(int i; i < length; i++)
		{
			int entity = EntRefToEntIndex(Selected[client].Get(i));
			if(entity != -1)
			{
				SmiteNpcToDeath(entity);
				if(!pressed[Key_Ctrl])
					break;
			}
		}
	}
	
	// Highlight all selected units
	HighlightSelectedUnits(client);

	if(holding[Key_ZoomIn] || holding[Key_ZoomOut] || holding[Key_AdjustCamera])
	{
		return;
	}

	if(Selected[client])
	{
#if defined RTS
		if(pressed[Key_Attack])
		{
			NextMoveType[client] = Command_Attack;
		}
		else if(pressed[Key_Stand])
		{
			NextMoveType[client] = Command_HoldPos;
		}
		else if(pressed[Key_Patrol])
		{
			NextMoveType[client] = Command_Patrol;
		}
#elseif defined ZR
		if(pressed[Key_Attack])
		{
			NextMoveType[client] = Move_Attack;
		}
		else if(pressed[Key_Stand])
		{
			NextMoveType[client] = Move_HoldPos;
		}
		else if(pressed[Key_Patrol])
		{
			NextMoveType[client] = Move_Patrol;
		}
#endif
	}

	if(pressed[Key_SelectAll])
	{
		if(!holding[Key_Ctrl])
			delete Selected[client];
		
		int entity = MaxClients;
		while(UnitEntityIterator(client, entity))
		{
			if(Selected[client] && Selected[client].FindValue(EntIndexToEntRef(entity)) != -1)
				continue;
			
			SelectUnit(client, entity);
		}
	}

	if(pressed[Key_IdleWorker])
	{
		if(!holding[Key_Ctrl])
			delete Selected[client];
		
#if defined ZR
		for(int entity = MaxClients + 1; entity < MAXENTITIES; entity++)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(!b_NpcHasDied[entity] && i_NpcInternalId[entity] == BARRACKS_VILLAGER && npc.OwnerUserId && GetClientOfUserId(npc.OwnerUserId) == client)
			{
				if(Selected[client] && Selected[client].FindValue(EntIndexToEntRef(entity)) != -1)
					continue;
				
				SelectUnit(client, entity);
			}
		}
#endif
	}

	// Cursor point and rectangle selection through a stationary viewport

	b_LagCompNPC_No_Layers = true;
	b_LagCompNPC_OnlyAllies = true;
	StartLagCompensation_Base_Boss(client);

	float cameraAbsPos[3];
	AddVectors(focusPos, cameraPos, cameraAbsPos);

	float cursorPos[3];
	GetCursorVector(client, CameraVector[client], mouse, cursorPos);
	GetVectorAngles(cursorPos, cursorPos);
	int selected = GetUnitSelectTrace(client, cameraAbsPos, cursorPos, cursorPos);

	if(holding[Key_LeftClick])	// Holding/Pressing Left-Click
	{
		if(InSelectDrag[client])	// Constant Holding Left-Click
		{
			if(moving)
			{
				// TODO: Expand selection while scrolling
				//       In the meantime, block scrolling by moving cursor away from scroll edge

				mouse[0] = fClamp(mouse[0], 0.022, 0.989);
				mouse[1] = fClamp(mouse[1], 0.022, 0.989);
				LastMousePos[client] = mouse;
			}

			// Consistency is required for counter-clockwise order of points used in
			// SelectionContains to generate plane normals that must all point inwards

			float mouseTL[2];
			mouseTL[0] = mouse[0] < StartDragMousePos[client][0] ? mouse[0] : StartDragMousePos[client][0];
			mouseTL[1] = mouse[1] < StartDragMousePos[client][1] ? mouse[1] : StartDragMousePos[client][1];

			float mouseBR[2];
			mouseBR[0] = mouse[0] > StartDragMousePos[client][0] ? mouse[0] : StartDragMousePos[client][0];
			mouseBR[1] = mouse[1] > StartDragMousePos[client][1] ? mouse[1] : StartDragMousePos[client][1];

			GetCursorVector(client, CameraVector[client], mouseTL, SelectionVerticies[client][0]);
			ScaleVector(SelectionVerticies[client][0], 50.0);
			AddVectors(cameraAbsPos, SelectionVerticies[client][0], SelectionVerticies[client][0]);

			GetCursorVector(client, CameraVector[client], mouseBR, SelectionVerticies[client][2]);
			ScaleVector(SelectionVerticies[client][2], 50.0);
			AddVectors(cameraAbsPos, SelectionVerticies[client][2], SelectionVerticies[client][2]);

			float mouse2[2];

			mouse2[0] = mouseBR[0];
			mouse2[1] = mouseTL[1];
			GetCursorVector(client, CameraVector[client], mouse2, SelectionVerticies[client][1]);
			ScaleVector(SelectionVerticies[client][1], 50.0);
			AddVectors(cameraAbsPos, SelectionVerticies[client][1], SelectionVerticies[client][1]);

			mouse2[0] = mouseTL[0];
			mouse2[1] = mouseBR[1];
			GetCursorVector(client, CameraVector[client], mouse2, SelectionVerticies[client][3]);
			ScaleVector(SelectionVerticies[client][3], 50.0);
			AddVectors(cameraAbsPos, SelectionVerticies[client][3], SelectionVerticies[client][3]);

			for(int i; i < sizeof(BeamRef[]); i++)
			{
				int entity = EntRefToEntIndex(BeamRef[client][i]);
				if(entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
				{
					entity = CreateEntityByName("env_beam");
					if(entity != -1)
					{
						SetEntityModel(entity, LaserModel);
						
						SetEntProp(entity, Prop_Send, "m_nBeamType", 2);
						SetEntPropFloat(entity, Prop_Data, "m_fWidth", 0.1);
						SetEntPropFloat(entity, Prop_Data, "m_fEndWidth", 0.1);

						SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);

						DispatchSpawn(entity);

						SDKHook(entity, SDKHook_SetTransmit, SetTransmit_Beam);

						BeamRef[client][i] = EntIndexToEntRef(entity);
					}
				}
			}

			int entity = EntRefToEntIndex(BeamRef[client][3]);
			for(int i; i < sizeof(BeamRef[]); i++)
			{
				int target = entity;
				entity = EntRefToEntIndex(BeamRef[client][i]);

				if(IsValidEntity(entity))
				{
					if((IsValidEntity(target)))
						AttachBeam(target, entity);
					
					TeleportEntity(entity, SelectionVerticies[client][i]);
				}
			}
		}
		else if(!moving)	// New Press Left-Click
		{
			InSelectDrag[client] = true;
			StartDragMousePos[client][0] = mouse[0];
			StartDragMousePos[client][1] = mouse[1];
		}

		NextMoveType[client] = 0;
	}
	else if(previous[Key_LeftClick])	// Let go Left-Click
	{
		if(InSelectDrag[client])
		{
			if(!holding[Key_Ctrl])
				delete Selected[client];

			//if(GetVectorDistance(SelectionVerticies[client][1], SelectionVerticies[client][3], true) > 0.0)
			if(SelectionVerticies[client][1][0] != SelectionVerticies[client][3][0] ||
				SelectionVerticies[client][1][1] != SelectionVerticies[client][3][1] ||
				SelectionVerticies[client][1][2] != SelectionVerticies[client][3][2])
			{
				int entity = MaxClients;
				float pos[3], offset[3], vectors[4][3], vertex[3];
				while(UnitEntityIterator(client, entity))
				{
					if(Selected[client] && Selected[client].FindValue(EntIndexToEntRef(entity)) != -1)
						continue;
					
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

					AddVectors(focusPos, cameraPos, offset);

					SubtractVectors(SelectionVerticies[client][0], offset, vectors[0]);
					SubtractVectors(SelectionVerticies[client][1], offset, vectors[1]);
					SubtractVectors(SelectionVerticies[client][2], offset, vectors[2]);
					SubtractVectors(SelectionVerticies[client][3], offset, vectors[3]);

					vertex = vectors[0];
					GetVectorCrossProduct(vectors[0], vectors[1], vectors[0]);
					GetVectorCrossProduct(vectors[1], vectors[2], vectors[1]);
					GetVectorCrossProduct(vectors[2], vectors[3], vectors[2]);
					GetVectorCrossProduct(vectors[3], vertex, vectors[3]);

					SubtractVectors(pos, offset, vertex);

					if(GetVectorDotProduct(vertex, vectors[0]) > 0 &&
						GetVectorDotProduct(vertex, vectors[1]) > 0 &&
						GetVectorDotProduct(vertex, vectors[2]) > 0 &&
						GetVectorDotProduct(vertex, vectors[3]) > 0)
					{
						SelectUnit(client, entity);
					}
				}

				if(!Selected[client] && selected != INVALID_ENT_REFERENCE)
				{
					SelectUnit(client, selected);
				}
			}
			else if(selected != INVALID_ENT_REFERENCE)
			{
				if(!holding[Key_Ctrl])
					delete Selected[client];
				
				SelectUnit(client, selected);
			}

			RemoveSelectBeams(client);
			InSelectDrag[client] = false;
		}
	}

	FinishLagCompensation_Base_boss();
	
	if(holding[Key_RightClick])	// Holding/Press Right-Click
	{
		if(pressed[Key_RightClick])	// New Press Right-Click
		{
			StartDragMousePos[client][0] = mouse[0];
			StartDragMousePos[client][1] = mouse[1];
		}
		else if(InMoveDrag[client])	// Has moved while holding
		{
			float dragDiff0 = StartDragMousePos[client][0] - mouse[0];
			float dragDiff1 = StartDragMousePos[client][1] - mouse[1];

			float dragAng = ArcTangent2(dragDiff0, dragDiff1);
			if(dragAng < 0)
				dragAng += FLOAT_PI * 2.0;

			int index = RoundToNearest(dragAng / (FLOAT_PI / 4.0)) % sizeof(ScrollCursors);
			strcopy(cursor, sizeof(cursor), ScrollCursors[index]);

			CameraMoveDrag[client][0] = MOUSE2_DRAG_SPEED_MULT * -speed * ((dragDiff0 / 0.5 * right[0]) - (dragDiff1 / 0.5 * forwardVec[0]));
			CameraMoveDrag[client][1] = MOUSE2_DRAG_SPEED_MULT * -speed * ((dragDiff0 / 0.5 * right[1]) - (dragDiff1 / 0.5 * forwardVec[1]));
		}
		else	// Check if moving while holding
		{
			float dragDiff0 = StartDragMousePos[client][0] - mouse[0];
			float dragDiff1 = StartDragMousePos[client][1] - mouse[1];

			float distance = (dragDiff0 * dragDiff0) + (dragDiff1 * dragDiff1);
			if(!Selected[client] || distance > (MOUSE2_DRAG_MIN_DIST * MOUSE2_DRAG_MIN_DIST))
			{
				InMoveDrag[client] = true;
				NextMoveType[client] = 0;
			}
		}
	}
	else if(previous[Key_RightClick])	// Let go Right-Click
	{
		if(InMoveDrag[client])	// Was drag moving
		{
			InMoveDrag[client] = false;
			CameraMoveDrag[client] = ZERO_VECTOR;
			NextMoveType[client] = 0;
		}
		else if(!holding[Key_LeftClick])	// Not cancel with Left-Click
		{
			MoveSelectedUnits(client, cursorPos);
		}
	}

	if(!InSelectDrag[client])	// Not holding Left-Click
	{
		int color[4] = {255, 255, 255, 255};

		if(InMoveDrag[client] || moving)	// Moving camera
		{
			// Move cursor applied above

			// Green
			color[0] = 0;
			color[2] = 0;
		}
		else if(selected != INVALID_ENT_REFERENCE)	// Hovering over an unit
		{
			cursor = CURSOR_SELECTABLE;

			// TODO: Selectable everything, color depending on unit enemy/ally

			// Green
			color[0] = 0;
			color[2] = 0;
		}
		else if(Selected[client] && NextMoveType[client])	// Has selected units
		{
			cursor = CURSOR_MOVE;

#if defined RTS
			switch(NextMoveType[client])
			{
				case Command_Attack:
				{
					// Red
					color[1] = 0;
					color[2] = 0;
				}
				case Command_HoldPos:
				{
					// Yellow
					color[2] = 0;
				}
				case Command_Patrol:
				{
					// Blue
					color[0] = 0;
					color[1] = 0;
				}
			}
#elseif defined ZR
			switch(NextMoveType[client])
			{
				case Move_Attack:
				{
					// Red
					color[1] = 0;
					color[2] = 0;
				}
				case Move_HoldPos:
				{
					// Yellow
					color[2] = 0;
				}
				case Move_Patrol:
				{
					// Blue
					color[0] = 0;
					color[1] = 0;
				}
			}
#endif
		}
		else
		{
			cursor = CURSOR_DEFAULT;
		}

		SetHudTextParams(mouse[0]-0.01, mouse[1]-0.02, 0.5, color[0], color[1], color[2], color[3], 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, SyncHud, cursor);
	}
	else
	{
		ShowSyncHudText(client, SyncHud, "");
	}
}

static int GetUnitSelectTrace(int client, const float vecPos[3], const float vecAng[3], float vecEndPos[3])
{
	TR_TraceRayFilter(vecPos, vecAng, MASK_PLAYERSOLID, RayType_Infinite, TraceEntityFilter_Units, client);
	if(TR_DidHit())
	{
		TR_GetEndPosition(vecEndPos);

		// Omit worldspawn/0
		int entity = TR_GetEntityIndex();
		if(entity)
			return entity;
	}

	return INVALID_ENT_REFERENCE;
}

static bool TraceEntityFilter_Units(int entity, int contentsMask, int client)
{
	return IsSelectableUnitEntity(client, entity);
}

static void HighlightSelectedUnits(int client)
{
	if(Selected[client])
	{
		int length = Selected[client].Length;
		for(int i; i < length; i++)
		{
			int entity = EntRefToEntIndex(Selected[client].Get(i));
			if(entity == -1)
			{
				Selected[client].Erase(i);
				i--;
				length--;
			}
			else
			{
				DrawUnitHealthBar(client, entity);
			}
		}

		if(!length)
			delete Selected[client];
	}
}

static void MoveSelectedUnits(int client, const float vecMovePos[3])
{
	if(Selected[client])
	{
		CreateParticle("ping_circle", vecMovePos, NULL_VECTOR);

		int length = Selected[client].Length;
		if(length)
		{
			for(int i; i < length; i++)
			{
				int entity = EntRefToEntIndex(Selected[client].Get(i));
				if(entity != -1)
					MoveUnit(client, entity, vecMovePos);
			}
			
#if defined ZR
			switch(NextMoveType[client])
			{
				case Move_Normal:
					ClientCommand(client, "playgamesound coach/coach_go_here.wav");
				
				case Move_Attack:
					ClientCommand(client, "playgamesound coach/coach_attack_here.wav");
				
				case Move_HoldPos:
					ClientCommand(client, "playgamesound coach/coach_defend_here.wav");
				
				case Move_Patrol:
					ClientCommand(client, "playgamesound coach/coach_look_here.wav");
			}
#endif

		}

		NextMoveType[client] = 0;
	}
}

static void DrawUnitHealthBar(int client, int entity)
{
	int health = GetEntProp(entity, Prop_Data, "m_iHealth");
	if(health < 1)
	{
		RemoveSelectBeams(entity);
		return;
	}

	int maxHealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth");

	int focus = EntRefToEntIndex(FocusRef[client]);
	int camera = EntRefToEntIndex(CameraRef[client]);

	float focusPos[3];
	GetEntPropVector(focus, Prop_Send, "m_vecOrigin", focusPos);

	float cameraPos[3];
	GetEntPropVector(camera, Prop_Send, "m_vecOrigin", cameraPos); // Relative to parent focus entity

	AddVectors(focusPos, cameraPos, cameraPos); // Now absolute in world coordiates

	float cameraAng[3];
	GetEntPropVector(camera, Prop_Data, "m_angAbsRotation", cameraAng);

	float vecRight[3], vecUp[3];
	GetAngleVectors(cameraAng, NULL_VECTOR, vecRight, vecUp);

	//float entityPos[3];
	//GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);

	// Calculate the center and the highest point at the top
	// of the bounding box as projected onto the camera plane

	float bBoxTop[4][3];
	float heights[4];
	GetEntityBoundingBoxTop(entity, bBoxTop);

	float centerPos[3];
	int highest;
	float maxHeight = -FAR_FUTURE;
	float shiftUp[3];

	for(int i; i < sizeof(bBoxTop); i++)
	{
		SubtractVectors(bBoxTop[i], cameraPos, shiftUp);
		NormalizeVector(shiftUp, shiftUp);

		// Sum total for average calcuation
		AddVectors(centerPos, shiftUp, centerPos);

		heights[i] = GetVectorDotProduct(shiftUp, vecUp);
		if (heights[i] > maxHeight) {
			maxHeight = heights[i];
			highest = i;
		}
	}

	// Divide by 4 for average
	ScaleVector(centerPos, 0.25);

	shiftUp = vecUp;
	ScaleVector(shiftUp, heights[highest] - GetVectorDotProduct(centerPos, vecUp));
	AddVectors(centerPos, shiftUp, centerPos);
	NormalizeVector(centerPos, centerPos);

	float hpbarPos[3];
	hpbarPos = centerPos;
	ScaleVector(hpbarPos, 50.0);
	AddVectors(cameraPos, hpbarPos, hpbarPos);

	// Move center to the left to offset for bar extending due to overheal
	if(health > maxHealth)
	{
		float overhealOffset[3];
		overhealOffset = vecRight;
		ScaleVector(overhealOffset, HEALTH_BAR_HP_SCALE * (maxHealth - health));
		AddVectors(hpbarPos, overhealOffset, hpbarPos);
	}

	float horizontalLeftPos[3];
	float horizontalRightPos[3];

	float barMin = HEALTH_BAR_HP_SCALE * maxHealth;
	float barMax = HEALTH_BAR_HP_SCALE * maxHealth;
	float barSplit = HEALTH_BAR_HP_SCALE * 2.0 * health;

	float vecRightOffset[3], vecLeftOffset[3];
	vecRightOffset = vecRight;
	ScaleVector(vecRightOffset, 50.0);
	vecLeftOffset = vecRightOffset;
	ScaleVector(vecLeftOffset, -1.0);

	horizontalLeftPos = vecLeftOffset;
	ScaleVector(horizontalLeftPos, barMin);
	AddVectors(hpbarPos, horizontalLeftPos, horizontalLeftPos);

	horizontalRightPos = vecRightOffset;
	ScaleVector(horizontalRightPos, barSplit);
	AddVectors(horizontalLeftPos, horizontalRightPos, horizontalRightPos);

	int beam1 = EntRefToEntIndex(BeamRef[entity][0]);
	int beam2 = -1;
	int target = -1;
	if(!IsValidEntity(beam1))
	{
		RemoveSelectBeams(entity);

		beam1 = CreateEntityByName("env_beam");
		if(beam1 != -1)
		{
			SetEntityModel(beam1, LaserModel);
			
			SetEntProp(beam1, Prop_Send, "m_nBeamType", 2);
			SetEntPropFloat(beam1, Prop_Data, "m_fWidth", 0.3);
			SetEntPropFloat(beam1, Prop_Data, "m_fEndWidth", 0.3);

			SetEntPropEnt(beam1, Prop_Data, "m_hOwnerEntity", entity);

			DispatchSpawn(beam1);

			BeamRef[entity][0] = EntIndexToEntRef(beam1);
			SDKHook(beam1, SDKHook_SetTransmit, SetTransmit_HealthBeam);

			target = CreateEntityByName("info_target");
			if(target != -1)
			{
				AttachBeam(beam1, target);
				BeamRef[entity][1] = EntIndexToEntRef(target);

				if(health != maxHealth)
				{
					beam2 = CreateEntityByName("env_beam");
					if(beam2 != -1)
					{
						SetEntityModel(beam2, LaserModel);
						
						SetEntProp(beam2, Prop_Send, "m_nBeamType", 2);
						SetEntPropFloat(beam2, Prop_Data, "m_fWidth", 0.3);
						SetEntPropFloat(beam2, Prop_Data, "m_fEndWidth", 0.3);

						SetEntPropEnt(beam2, Prop_Data, "m_hOwnerEntity", entity);

						DispatchSpawn(beam2);

						BeamRef[entity][2] = EntIndexToEntRef(beam2);
						SDKHook(beam2, SDKHook_SetTransmit, SetTransmit_HealthBeam);

						AttachBeam(beam2, target);
					}
				}
			}
		}
	}
	else
	{
		target = EntRefToEntIndex(BeamRef[entity][1]);
		beam2 = EntRefToEntIndex(BeamRef[entity][2]);

		if(health == maxHealth)
		{
			if(beam2 != -1)
			{
				RemoveEntity(beam2);
				BeamRef[entity][2] = INVALID_ENT_REFERENCE;
			}
		}
		else if(beam2 == -1)
		{
			beam2 = CreateEntityByName("env_beam");
			if(beam2 != -1)
			{
				SetEntityModel(beam2, LaserModel);
				
				SetEntProp(beam2, Prop_Send, "m_nBeamType", 2);
				SetEntPropFloat(beam2, Prop_Data, "m_fWidth", 0.3);
				SetEntPropFloat(beam2, Prop_Data, "m_fEndWidth", 0.3);

				SetEntPropEnt(beam2, Prop_Data, "m_hOwnerEntity", entity);

				DispatchSpawn(beam2);

				BeamRef[entity][2] = EntIndexToEntRef(beam2);
				SDKHook(beam2, SDKHook_SetTransmit, SetTransmit_HealthBeam);

				AttachBeam(beam2, target);
			}
		}
	}

	TeleportEntity(beam1, horizontalLeftPos);
	TeleportEntity(target, horizontalRightPos);

	if(health != maxHealth)
	{
		horizontalLeftPos = horizontalRightPos;

		horizontalRightPos = vecRightOffset;
		ScaleVector(horizontalRightPos, barMax);
		AddVectors(hpbarPos, horizontalRightPos, horizontalRightPos);

		TeleportEntity(beam2, horizontalRightPos);
	}

	// Team Color
	SetEntityRenderColor(beam1, 255, 0, 0, 255);
}

static Action SetTransmit_HealthBeam(int entity, int client)
{
	if(client > 0 && client <= MaxClients && Selected[client])
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		if(owner == -1)
		{
			RemoveEntity(entity);
		}
		else if(Selected[client].FindValue(EntIndexToEntRef(owner)) != -1)
		{
			DrawUnitHealthBar(client, entity);
			return Plugin_Continue;
		}
	}

	return Plugin_Handled;
}

static void RemoveSelectBeams(int owner)
{
	for(int i; i < 4; i++)
	{
		if(BeamRef[owner][i] == INVALID_ENT_REFERENCE)
			continue;
		
		int entity = EntRefToEntIndex(BeamRef[owner][i]);
		if(entity != -1)
			RemoveEntity(entity);

		BeamRef[owner][i] = INVALID_ENT_REFERENCE;
	}
}

static void GetEntityBoundingBoxTop(int entity, float vecPoints[4][3])
{
	float vecMins[3], vecMaxs[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);

	float vecPos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecPos);

	AddVectors(vecPos, vecMins, vecMins);
	AddVectors(vecPos, vecMaxs, vecMaxs);

	vecPoints[0][0] = vecMins[0];
	vecPoints[0][1] = vecMins[1];
	vecPoints[0][2] = vecMaxs[2];

	vecPoints[1][0] = vecMins[0];
	vecPoints[1][1] = vecMaxs[1];
	vecPoints[1][2] = vecMaxs[2];

	vecPoints[2][0] = vecMaxs[0];
	vecPoints[2][1] = vecMins[1];
	vecPoints[2][2] = vecMaxs[2];

	vecPoints[3][0] = vecMaxs[0];
	vecPoints[3][1] = vecMaxs[1];
	vecPoints[3][2] = vecMaxs[2];
}

static Action SetTransmit_Beam(int entity, int client)
{
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") == client ? Plugin_Continue : Plugin_Handled;
}

static void AttachBeam(int entity, int target)
{
	SetEntPropEnt(entity, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(entity));
	SetEntPropEnt(entity, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(target), 1);
	SetEntProp(entity, Prop_Send, "m_nNumBeamEnts", 2);

	AcceptEntityInput(entity, "TurnOn");
}

static bool CanBeInCamera(int client)
{
#if defined ZR
	if(dieingstate[client] > 0 || TeutonType[client] == TEUTON_DEAD)
		return false;
#endif

	return (IsPlayerAlive(client) &&
		!TF2_IsPlayerInCondition(client, TFCond_Taunting));
}

static void GetCursorVector(int client, const float vecVector[3], const float mouse[2], float cursorVector[3])
{
	float maxX = ArcTangent2(DegToRad(LastDefaultFOV[client] * 0.5), 1.0);
	float maxY = ArcTangent2(DegToRad(LastDefaultFOV[client] * 0.5 / AspectRatio[client]), 1.0);

	float cursorX = 4.0 * (mouse[0] - 0.5) * maxX;
	float cursorY = 2.0 * AspectRatio[client] * (mouse[1] - 0.5) * maxY;

	float angle[3];
	GetVectorAngles(vecVector, angle);

	Vector_DegToRad(angle);

	float cursor[3];
	cursor[0] = 1.0;
	cursor[1] = -cursorX;
	cursor[2] = -cursorY;

	float matRotation[3][3];
	Matrix_GetRotationMatrix(matRotation, angle[2], angle[0], angle[1]);

	Matrix_VectorMultiply(matRotation, cursor, cursorVector);
}

static void EnableCamera(int client)
{
	int focus = CreateEntityByName("info_target");
	int camera = CreateEntityByName("info_target");
	int view = CreateEntityByName("point_viewcontrol");

	SetParent(focus, camera);
	SetParent(camera, view);

	LastFOV[client] = GetEntProp(client, Prop_Send, "m_iFOV");
	LastDefaultFOV[client] = GetEntProp(client, Prop_Send, "m_iDefaultFOV");

	FocusRef[client] = EntIndexToEntRef(focus);
	CameraRef[client] = EntIndexToEntRef(camera);

	DispatchSpawn(focus);
	DispatchSpawn(camera);
	DispatchSpawn(view);

	SetEntityMoveType(focus, MOVETYPE_NOCLIP);
	SetEntityMoveType(camera, MOVETYPE_NOCLIP);

	float pos[3];
	pos[2] += 300.0;
	MinZoom[client] = pos[2];
	GetClientEyePosition(client, pos);
	TeleportEntity(focus, pos);

	CameraDistance[client] = MinZoom[client] * -2.0;
	GetAngleVectors(DEFAULT_ANGLES, CameraVector[client], NULL_VECTOR, NULL_VECTOR);

	pos = CameraVector[client];
	ScaleVector(pos, CameraDistance[client]);
	TeleportEntity(camera, pos, DEFAULT_ANGLES, ZERO_VECTOR);

	SetClientViewEntity(client, view);
	SetEntityFlags(client, GetEntityFlags(client)|FL_FROZEN|FL_ATCONTROLS);
	AcceptEntityInput(view, "Enable", client, view);

#if defined RTS
	SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_HEALTH);
#endif
	
	//If these below is even needed
	//SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	//SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_DEATHCAM);

	//SetEntProp(client, Prop_Send, "m_iFOV", LastFOV[client]);
	//SetEntProp(client, Prop_Send, "m_iDefaultFOV", LastDefaultFOV[client]);
	SetEntProp(client, Prop_Send, "m_nForceTauntCam", 0);
	SetEntProp(client, Prop_Data, "m_takedamage", 2);

	LastMousePos[client] = {0.5, 0.5};
}

static void DisableCamera(int client)
{
	int entity = GetEntPropEnt(client, Prop_Data, "m_hViewEntity");
	if(entity != -1 && entity != client)
	{
		AcceptEntityInput(entity, "Disable", entity, entity);
	}

	SetClientViewEntity(client, client);

	entity = EntRefToEntIndex(FocusRef[client]);
	if(entity != -1)
	{
		RemoveEntity(entity);
	}

	FocusRef[client] = INVALID_ENT_REFERENCE;

	RemoveSelectBeams(client);
	delete Selected[client];

	//SetEntProp(client, Prop_Send, "m_iFOV", LastFOV[client]);
	//SetEntProp(client, Prop_Send, "m_iDefaultFOV", LastDefaultFOV[client]);
	
	SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_NONE);
	SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
	SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));

#if defined ZR
	Thirdperson_PlayerSpawn(client);
#endif
}

static void ToggleRTS(int client)
{
	if(RTSEnabled[client])
	{
		RTSEnabled[client] = false;
	}
	else
	{
		RTSEnabled[client] = true;
	}
}

static void LoadMouseCookie(int client)
{
	char buffer[512];
	MouseCookie.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		char buffers[4][16];
		if(ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])))
		{
			AspectRatio[client] = StringToFloat(buffers[0]);
			MouseSensitivity[client] = StringToFloat(buffers[1]);
			ScrollSpeed[client] = StringToFloat(buffers[2]);
			ZoomSpeed[client] = StringToFloat(buffers[3]);
		}
	}
}

static void SaveMouseCookie(int client)
{
	if(AreClientCookiesCached(client))
	{
		char buffer[512];
		FormatEx(buffer, sizeof(buffer), "%f;%f;%.0f;%.0f", AspectRatio[client], MouseSensitivity[client], ScrollSpeed[client], ZoomSpeed[client]);
		MouseCookie.Set(client, buffer);
	}
}

stock bool ProcessInputs(int client, int buttons, int impulse, int weapon, bool pressed[Key_MAX] = {}, bool previous[Key_MAX] = {}, bool holding[Key_MAX] = {})
{
	if(BindingKey[client] != -1)
	{
		for(int i; i < IN_MAX; i++)
		{
			if(buttons & (1 << i))
			{
				BindKey(client, "b %d", i);
				return false;
			}
		}

		if(impulse)
			BindKey(client, "i %d", impulse);

		return false;
	}

	for(int i; i < Key_MAX; i++)
	{
		if(i == Key_RightClick && holding[Key_LeftClick])
		{
			// Special rule: Left-Click overrides Right-Click
			NewPress[client][i] = false;
			HoldPress[client][i] = false;
		}
		else if(StrContains(KeyBinds[client][i], "b ") == 0)
		{
			int button = 1 << StringToInt(KeyBinds[client][i][2]);
			if(buttons & button)
			{
				if(!HoldPress[client][i])
				{
					NewPress[client][i] = true;
					HoldPress[client][i] = true;
				}
			}
			else
			{
				HoldPress[client][i] = false;
			}
		}
		else if(StrContains(KeyBinds[client][i], "i ") == 0)
		{
			int imp = StringToInt(KeyBinds[client][i][2]);
			if(impulse == imp)
			{
				NewPress[client][i] = true;
			}
			
			HoldPress[client][i] = false;
		}

		//if(HoldPress[client][i])
		//	PrintToChat(client, "%d - %s", i, DefaultCmd[i]);

		previous[i] = LastPress[client][i];
		pressed[i] = NewPress[client][i];
		holding[i] = NewPress[client][i] || HoldPress[client][i];

		LastPress[client][i] = holding[i];
		NewPress[client][i] = false;
	}
	return true;
}

bool RTSCamera_ClientCommandKeyValues(int client, const char[] command)
{
	bool result;
	if(BindingKey[client] != -1)
	{
		BindKey(client, command);
		result = true;
	}
	else if(RTSCamera_InCamera(client))
	{
		int key = InputToKey(client, command);
		if(key != -1)
		{
			switch(command[0])
			{
				case '+':
				{
					NewPress[client][key] = true;
					HoldPress[client][key] = true;
				}
				case '-':
				{
					HoldPress[client][key] = false;
				}
				default:
				{
					NewPress[client][key] = true;
				}
			}

			result = true;
		}
	}
	return result;
}

static Action OnSingleCommand(int client, const char[] command, int argc)
{
	if(client)
	{
		if(BindingKey[client] != -1)
		{
			BindKey(client, command);
		}
		else if(RTSCamera_InCamera(client))
		{
			int key = InputToKey(client, command);
			if(key != -1)
			{
				NewPress[client][key] = true;
			}
		}
	}
	return Plugin_Continue;
}

static void BindKey(int client, const char[] input, any ...)
{
	VFormat(KeyBinds[client][BindingKey[client]], sizeof(KeyBinds[][]), input, 3);
	FormatInput(KeyBinds[client][BindingKey[client]], sizeof(KeyBinds[][]), KeyBinds[client][BindingKey[client]]);

	for(int i; i < Key_MAX; i++)
	{
		if(BindingKey[client] != i && KeyBinds[client][i])
		{
			strcopy(KeyBinds[client][i], sizeof(KeyBinds[][]), "<unbound>");
			break;
		}
	}

	BindingKey[client] = -1;
	SaveKeybinds(client);
	ShowMenu(client, 9);
}

static void LoadKeybinds(int client)
{
	char buffer[512];
	BindCookie.Get(client, buffer, sizeof(buffer));
	if(buffer[0])
	{
		char buffers[Key_MAX][sizeof(KeyBinds[][])];
		if(ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])))
		{
			for(int i; i < Key_MAX; i++)
			{
				strcopy(KeyBinds[client][i], sizeof(KeyBinds[][]), buffers[i]);
			}
		}
	}
}

static void SaveKeybinds(int client)
{
	if(AreClientCookiesCached(client))
	{
		char buffer[512];
		strcopy(buffer, sizeof(buffer), KeyBinds[client][0]);

		for(int i = 1; i < Key_MAX; i++)
		{
			Format(buffer, sizeof(buffer), "%s;%s", buffer, KeyBinds[client][i]);
		}

		BindCookie.Set(client, buffer);
	}
}

static void FormatInput(char[] buffer, int length, const char[] input)
{
	strcopy(buffer, length, input);
	if(buffer[0] == '-')
		buffer[0] = '+';
	
	ReplaceString(buffer, length, "_server", "");
}

static int InputToKey(int client, const char[] input, any ...)
{
	char buffer[32];
	VFormat(buffer, sizeof(buffer), input, 3);
	FormatInput(buffer, sizeof(buffer), buffer);

	for(int i; i < Key_MAX; i++)
	{
		if(StrEqual(buffer, KeyBinds[client][i]))
			return i;
	}

	return -1;
}

// Stubs start here
// Fill in with code specific to bot or unit implementation

/**
 * Checks whether the selected entity is a unit controlled by the game mode
 * and can be selected by the commander
 *
 * @param client			Commander selecting the unit
 * @param entity			Entity being checked
 * @return					True if the entity is a unit
 */
static bool IsSelectableUnitEntity(int client, int entity)
{
	if(entity > MaxClients && entity < sizeof(b_NpcHasDied) && !b_NpcHasDied[entity])
	{
#if defined RTS
		if(UnitBody_CanControl(client, entity))
		{
			return true;
		}
#elseif defined ZR
		BarrackBody npc = view_as<BarrackBody>(entity);
		if(npc.OwnerUserId && GetClientOfUserId(npc.OwnerUserId) == client)
		{
			return true;
		}
#endif
	}

	return false;
}

/**
 * Called when a unit entity is successfully selected
 * 
 * @param client			Commander who selected the unit
 * @param iSelectedEntity	Entity of selected unit
 */
static void SelectUnit(int client, int iSelectedEntity)
{
	if(!Selected[client])
		Selected[client] = new ArrayList();

	Selected[client].Push(EntIndexToEntRef(iSelectedEntity));
}

/**
 * Called to move a selected unit
 * 
 * @param client			Commander who is moving the unit
 * @param entity			Entity of unit being moved
 * @param vecMovePos		Coordinates to move the unit to
 */
static void MoveUnit(int client, int entity, const float vecMovePos[3])
{
#if defined RTS
	int type = NextMoveType[client];
	if(type < Command_Move)
		type = Command_Move;
	
	UnitBody_AddCommand(entity, type, _, vecMovePos);
#elseif defined ZR
	f3_SpawnPosition[entity] = vecMovePos;

	switch(NextMoveType[client])
	{
		case Move_Normal:
			view_as<BarrackBody>(entity).CmdOverride = Command_RTSMove;
		
		case Move_Attack:
			view_as<BarrackBody>(entity).CmdOverride = Command_RTSAttack;
		
		case Move_HoldPos:
			view_as<BarrackBody>(entity).CmdOverride = Command_HoldPos;
		
		case Move_Patrol:
			view_as<BarrackBody>(entity).CmdOverride = Command_RTSAttack;
	}
#endif
}

static bool UnitEntityIterator(int client, int &entity)
{
#if defined RTS
	entity++;
	for(; entity < MAXENTITIES; entity++)
	{
		if(!b_NpcHasDied[entity] && UnitBody_CanControl(client, entity))
		{
			return true;
		}
	}
#elseif defined ZR
	entity++;
	for(; entity < MAXENTITIES; entity++)
	{
		BarrackBody npc = view_as<BarrackBody>(entity);
		if(!b_NpcHasDied[entity] && npc.OwnerUserId && GetClientOfUserId(npc.OwnerUserId) == client)
		{
			return true;
		}
	}
#endif

	return false;
}
