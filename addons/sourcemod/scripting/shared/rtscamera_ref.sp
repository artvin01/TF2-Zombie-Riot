#pragma semicolon 1

#define PLUGIN_AUTHOR			"AI"
#define PLUGIN_VERSION			"1.0.0"

#define LASER_MODEL				"sprites/laserbeam.vmt"

#define MOUSE_SENSITIVITY		0.0004

#define CLAMP_MOUSE_MIN_X		0.01
#define CLAMP_MOUSE_MAX_X		0.99

#define CLAMP_MOUSE_MIN_Y		0.02
#define CLAMP_MOUSE_MAX_Y		0.99

#define DEFAULT_MIN_ZOOM		300.0
#define DEFAULT_ASPECT_RATIO	1.77777777777777777777777777777777 // 16:9 for 1920x1080

#define ROTATION_KEYPRESS_SPEED	0.025

#define SCROLL_SPEED			500.0
#define SCROLL_DECEL_MULTIPLIER	0.9

#define ZOOM_SPEED				3000.0
#define ZOOM_DECEL_MULTIPLIER	0.9

#define MOUSE2_DRAG_START_DELAY	0.1
#define MOUSE2_DRAG_MIN_DIST	0.01
#define MOUSE2_DRAG_SPEED_MULT	4.0

#define DEFAULT_ANGLES			{45.0, 0.0, 0.0}
#define ZERO_VECTOR				{0.0, 0.0, 0.0}

#define AXIS_OFFSET				0.19634954084936207740391521145497 // FLOAT_PI/16

#define POSITIVE_INFINITY		view_as<float>(0x7F800000)
#define NEGATIVE_INFINITY		view_as<float>(0xFF800000)

#define COLORR_WHITE				{255, 255, 255, 255}
#define COLORR_RED				{255,   0,   0, 255}
#define COLORR_YELLOW			{255, 255,   0, 255}
#define COLORR_GREEN				{  0, 255,   0, 255}
#define COLORR_GRAY				{ 128,  128,  128, 255}

#define HEALTH_BAR_HP_SCALE		0.0001
#define HEALTH_BAR_COLORR_FULL 	{  0, 255, 0, 255}
#define HEALTH_BAR_COLORR_LOW 	{255, 0  , 0, 255}
#define HEALTH_BAR_LOW_PCT		0.3333	// Health percentage minimum before considered low

#define HUD_TEXT_COLORR_IDLE		{255, 255, 255, 255}
#define HUD_TEXT_COLORR_SCROLL	{  0, 255,   0, 255}
#define HUD_TEXT_COLORR_SELECT	{  0, 255,   0, 255}

#define CURSOR_DEFAULT			" ▶ "
#define CURSOR_SELECTABLE		"［ ］"
#define CURSOR_MOVE				" ◇ "

#define	HIDEHUD_WEAPONSELECTION		( 1<<0 )	// Hide ammo count & weapon selection
#define	HIDEHUD_FLASHLIGHT			( 1<<1 )
#define	HIDEHUD_ALL					( 1<<2 )
#define HIDEHUD_HEALTH				( 1<<3 )	// Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			( 1<<4 )	// Hide when local player's dead
#define HIDEHUD_NEEDSUIT			( 1<<5 )	// Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS			( 1<<6 )	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				( 1<<7 )	// Hide all communication elements (saytext, voice icon, etc)
#define	HIDEHUD_CROSSHAIR			( 1<<8 )	// Hide crosshairs
#define	HIDEHUD_VEHICLE_CROSSHAIR	( 1<<9 )	// Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			( 1<<10 )
#define HIDEHUD_BONUS_PROGRESS		( 1<<11 )	// Hide bonus progress display (for bonus map challenges)

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

static const char g_sScrollCursors[8][5] = {
	" ▵ ",
	" ◸ ",
	" ◃ ",
	" ◺ ",
	" ▿ ",
	" ◿ ",
	" ▹ ",
	" ◹ "
};

enum struct Commander {
	bool bEnabled;

	int iFOV;
	int iDefaultFOV;

	bool bHasForceTauntCamProp;
	bool bBackupForceTauntCam;
	int hBackupObsTarget;
	int iBackupObsMode;

	char sCursor[8];

	float vecMins[3];
	float vecMaxs[3];
	float fMinZoom;

	float fAspectRatio;
	int iFocusEntRef;
	int iCameraEntRef;
	int iViewControlEntRef;

	float vecVector[3];
	float fDistance;
	float fMouse[2];

	bool bMouseButton1Down;
	bool bMouseButton2Down;
	ArrayList hSelectedUnits;

	bool bMoving;
	bool bMoveDragging;
	bool bRotating;
	bool bDragging;
	bool bZoomingIn;
	bool bZoomingOut;

	float vecRotatingStartVector[3];
	float vecRotatingStartDistance;
	float fRotatingStartMouse[2];
	float fRotatingKeyPress;

	float vecMoveDragVel[3];

	float fMouseDragStart[2];
	float fMouseDragStartTime;
	float vecSelectionVerticies[12];

	int iSelectBeamsEntRef[4];

	void SetSelectionVertex(int iIdx, float vecVertex[3]) {
		this.vecSelectionVerticies[3*iIdx  ] = vecVertex[0];
		this.vecSelectionVerticies[3*iIdx+1] = vecVertex[1];
		this.vecSelectionVerticies[3*iIdx+2] = vecVertex[2];
	}

	void GetSelectionVertex(int iIdx, float vecVertex[3]) {
		vecVertex[0] = this.vecSelectionVerticies[3*iIdx  ];
		vecVertex[1] = this.vecSelectionVerticies[3*iIdx+1];
		vecVertex[2] = this.vecSelectionVerticies[3*iIdx+2];
	}

	bool SelectionContains(float vecVertex[3]) {
		float vecVectors[4][3];
		this.GetSelectionVertex(0, vecVectors[0]);
		this.GetSelectionVertex(1, vecVectors[1]);
		this.GetSelectionVertex(2, vecVectors[2]);
		this.GetSelectionVertex(3, vecVectors[3]);

		float vecFocusPos[3];
		GetEntPropVector(EntRefToEntIndex(this.iFocusEntRef), Prop_Send, "m_vecOrigin", vecFocusPos);

		float vecCameraPos[3];
		GetEntPropVector(EntRefToEntIndex(this.iCameraEntRef), Prop_Send, "m_vecOrigin", vecCameraPos);

		AddVectors(vecFocusPos, vecCameraPos, vecCameraPos);

		SubtractVectors(vecVectors[0], vecCameraPos, vecVectors[0]);
		SubtractVectors(vecVectors[1], vecCameraPos, vecVectors[1]);
		SubtractVectors(vecVectors[2], vecCameraPos, vecVectors[2]);
		SubtractVectors(vecVectors[3], vecCameraPos, vecVectors[3]);

		float vecNormals[4][3];
		GetVectorCrossProduct(vecVectors[0], vecVectors[1], vecNormals[0]);
		GetVectorCrossProduct(vecVectors[1], vecVectors[2], vecNormals[1]);
		GetVectorCrossProduct(vecVectors[2], vecVectors[3], vecNormals[2]);
		GetVectorCrossProduct(vecVectors[3], vecVectors[0], vecNormals[3]);

		float vecVertexVector[3];
		SubtractVectors(vecVertex, vecCameraPos, vecVertexVector);

		return
			GetVectorDotProduct(vecVertexVector, vecNormals[0]) > 0 &&
			GetVectorDotProduct(vecVertexVector, vecNormals[1]) > 0 &&
			GetVectorDotProduct(vecVertexVector, vecNormals[2]) > 0 &&
			GetVectorDotProduct(vecVertexVector, vecNormals[3]) > 0;
	}
}

enum struct UnitSelection {
	int iUnitEntRef;
	int iHealthBeamEntRef[3];

	void Init(int iSelectedEntity) {
		this.iUnitEntRef = EntIndexToEntRef(iSelectedEntity);
		this.iHealthBeamEntRef = {INVALID_ENT_REFERENCE, INVALID_ENT_REFERENCE, INVALID_ENT_REFERENCE};
	}
}

static Commander g_eCommander[MAXPLAYERS+1];

static Handle g_hHudText;

void SMRTS_OnPluginStart() {
	RegConsoleCmd("sm_rts", cmdRTS, "Enter RTS mode");

	RegConsoleCmd("sm_rts_zoom_in", cmdRTSZoomIn, "RTS zoom in");
	RegConsoleCmd("sm_rts_zoom_out", cmdRTSZoomOut, "RTS zoom out");

	RegConsoleCmd("sm_rts_aspect_ratio", cmdRTSAspectRatio, "Set RTS aspect ratio");

	HookEvent("player_death", Event_PlayerChangeState);
	HookEvent("player_spawn", Event_PlayerChangeState);

	HookEvent("player_changeclass", Event_PlayerChangeState);
	HookEvent("player_team", Event_PlayerChangeState);

	AddCommandListener(CommandListener_Taunt, "taunt");

	g_hHudText = CreateHudSynchronizer();
}

void SMRTS_OnPluginEnd() {
	for (int i=1; i<=MaxClients; i++) {
		ResetClient(i);
	}
}

void SMRTS_OnMapStart() {
	PrecacheModel(LASER_MODEL);
}

void SMRTS_OnMapEnd() {
	for (int i=1; i<=MaxClients; i++) {
		ResetClient(i);
	}
}

void SMRTS_OnClientDisconnect(int iClient) {
	ResetClient(iClient);
}

public void OnPlayerRunCmdPre(int iClient, int iButtons, int iImpulse, const float vecVel[3], const float vecAng[3], int iWeapon, int iSubType, int iCmdNum, int iTickCount, int iSeed, const int iMouse[2]) {
	if (g_eCommander[iClient].bEnabled) {
		ProcessCameraControls(iClient, iButtons, iMouse);
	}
}

void SMRTS_TF2_OnConditionAdded(int iClient, TFCond iCondition) {
	// Block taunting when enabled since it overrides the camera
	if (iCondition == TFCond_Taunting && g_eCommander[iClient].bEnabled) {
		TF2_RemoveCondition(iClient, TFCond_Taunting);
	}
}

// Custom callbacks

static Action Event_PlayerChangeState(Event hEvent, const char[] sName, bool bDontBroadcast) {
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!iClient) {
		return Plugin_Continue;
	}

	if (g_eCommander[iClient].bEnabled) {
		ResetClient(iClient);
		return Plugin_Continue;
	}

	return Plugin_Continue;
}

static Action CommandListener_Taunt(int iClient, const char[] sCommand, int iArgC) {
	// Block taunting when enabled since it overrides the camera
	return g_eCommander[iClient].bEnabled ? Plugin_Handled : Plugin_Continue;
}

static bool TraceEntityFilter_Units(int iEntity, int iContentsMask, int iClient) {
	return IsSelectableUnitEntity(iClient, iEntity);
}

static Action SDKHookCB_SetTransmit_Beam(int iEntity, int iClient) {
	if (GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity") == iClient) {
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

static Action SDKHookCB_SetTransmit_HealthBeam(int iEntity, int iClient) {
	if (GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity") == iClient) {
		ArrayList hSelectedUnits = g_eCommander[iClient].hSelectedUnits;
		int iIdx = hSelectedUnits.FindValue(EntIndexToEntRef(iEntity), UnitSelection::iHealthBeamEntRef);
		if (iIdx != -1) {
			UnitSelection eUnitSelection;
			hSelectedUnits.GetArray(iIdx, eUnitSelection);

			if (HighlightSelectedUnit(iClient, eUnitSelection))	{
				hSelectedUnits.SetArray(iIdx, eUnitSelection);
			}
		}

		return Plugin_Continue;
	}

	return Plugin_Handled;
}

// Commands

static Action cmdRTS(int iClient, int iArgs) {
	if (g_eCommander[iClient].bEnabled) {
		ResetClient(iClient);
		return Plugin_Handled;
	}

	float vecMins[3];
	float vecMaxs[3];

	if (iArgs != 6) {
		char sCmdName[32];
		GetCmdArg(0, sCmdName, sizeof(sCmdName));

		ReplyToCommand(iClient, "Usage: %s [min_x min_y min_z max_x max_y max_z]", sCmdName);

		SetupClient(iClient);
	} else {
		vecMins[0] = GetCmdArgFloat(1);
		vecMins[1] = GetCmdArgFloat(2);
		vecMins[2] = GetCmdArgFloat(3);

		vecMaxs[0] = GetCmdArgFloat(4);
		vecMaxs[1] = GetCmdArgFloat(5);
		vecMaxs[2] = GetCmdArgFloat(6);

		SetupClient(iClient, vecMins, vecMaxs);
	}

	return Plugin_Handled;
}

static Action cmdRTSZoomIn(int iClient, int iArgs) {
	if (!g_eCommander[iClient].bEnabled || g_eCommander[iClient].bMoving || g_eCommander[iClient].bRotating) {
		return Plugin_Handled;
	}

	g_eCommander[iClient].bZoomingIn = true;
	g_eCommander[iClient].bZoomingOut = false;

	return Plugin_Handled;
}

static Action cmdRTSZoomOut(int iClient, int iArgs) {
	if (!g_eCommander[iClient].bEnabled || g_eCommander[iClient].bMoving || g_eCommander[iClient].bRotating) {
		return Plugin_Handled;
	}

	g_eCommander[iClient].bZoomingIn = false;
	g_eCommander[iClient].bZoomingOut = true;

	return Plugin_Handled;
}

static Action cmdRTSAspectRatio(int iClient, int iArgs) {
	if (!(1 <= iArgs <= 2)) {
		char sCmdName[32];
		GetCmdArg(0, sCmdName, sizeof(sCmdName));

		ReplyToCommand(iClient, "Usage: %s <ratio>", sCmdName);
		ReplyToCommand(iClient, "Usage: %s <width> <height>", sCmdName);

		return Plugin_Handled;
	}

	if (iArgs == 1) {
		g_eCommander[iClient].fAspectRatio = GetCmdArgFloat(1);
	} else {
		g_eCommander[iClient].fAspectRatio = GetCmdArgFloat(1) / GetCmdArgFloat(2);
	}

	return Plugin_Handled;
}

// Helpers

static void SetupClient(
	int iClient,
	float vecMins[3]=NULL_VECTOR,
	float vecMaxs[3]=NULL_VECTOR,
	float vecPosStartFocus[3]=NULL_VECTOR,
	float fMinZoom=DEFAULT_MIN_ZOOM,
	float fAspectRatio=DEFAULT_ASPECT_RATIO) {

	int iFocusEntity = CreateEntityByName("info_target");
	if (iFocusEntity == INVALID_ENT_REFERENCE) {
		return;
	}

	// Separate entity is needed to set camera velocities properly since predictions
	// with point_viewcontrol desynchronizes with beams position calcuations in viewport

	int iCameraEntity = CreateEntityByName("info_target");
	if (iCameraEntity == INVALID_ENT_REFERENCE) {
		RemoveEntity(iFocusEntity);
		return;
	}

	int iViewControl = CreateEntityByName("point_viewcontrol");
	if (iViewControl == INVALID_ENT_REFERENCE) {
		RemoveEntity(iFocusEntity);
		RemoveEntity(iCameraEntity);
		return;
	}

	SetParent(iCameraEntity, iFocusEntity);
	SetParent(iViewControl, iCameraEntity);

	Commander eCommander;

	eCommander.sCursor = CURSOR_DEFAULT;

	eCommander.vecMins = IsNullVector(vecMins) ? {NEGATIVE_INFINITY, NEGATIVE_INFINITY, NEGATIVE_INFINITY} : vecMins;
	eCommander.vecMaxs = IsNullVector(vecMaxs) ? {POSITIVE_INFINITY, POSITIVE_INFINITY, POSITIVE_INFINITY} : vecMaxs;
	eCommander.fMinZoom = fMinZoom;
	eCommander.fAspectRatio = fAspectRatio;

	eCommander.iFOV = GetEntProp(iClient, Prop_Send, "m_iFOV");
	eCommander.iDefaultFOV = GetEntProp(iClient, Prop_Send, "m_iDefaultFOV");
	if ((eCommander.bHasForceTauntCamProp = HasEntProp(iClient, Prop_Send, "m_nForceTauntCam"))) {
		eCommander.bBackupForceTauntCam = GetEntProp(iClient, Prop_Send, "m_nForceTauntCam") != 0;
	}

	eCommander.iFocusEntRef = EntIndexToEntRef(iFocusEntity);
	eCommander.iCameraEntRef = EntIndexToEntRef(iCameraEntity);
	eCommander.iViewControlEntRef = EntIndexToEntRef(iViewControl);

	DispatchSpawn(iFocusEntity);
	DispatchSpawn(iCameraEntity);
	DispatchSpawn(iViewControl);

	SetEntityMoveType(iFocusEntity, MOVETYPE_NOCLIP);
	SetEntityMoveType(iCameraEntity, MOVETYPE_NOCLIP);

	float vecPosFocus[3];
	if (IsNullVector(vecPosStartFocus)) {
		if (!IsNullVector(vecMins) && !IsNullVector(vecMaxs)) {
			vecPosFocus[0] = 0.5*(vecMins[0]+vecMaxs[0]);
			vecPosFocus[1] = 0.5*(vecMins[1]+vecMaxs[1]);
			vecPosFocus[2] = vecMins[2];
		}
	} else {
		vecPosFocus = vecPosStartFocus;
	}

	TeleportEntity(iFocusEntity, vecPosFocus);

	float fInitialDistance = 2*DEFAULT_MIN_ZOOM;
	GetAngleVectors(DEFAULT_ANGLES, eCommander.vecVector, NULL_VECTOR, NULL_VECTOR);

	float vecCameraPos[3];
	vecCameraPos = eCommander.vecVector;
	ScaleVector(vecCameraPos, -fInitialDistance);

	TeleportEntity(iCameraEntity, vecCameraPos, DEFAULT_ANGLES, ZERO_VECTOR);

	SetClientViewEntity(iClient, iViewControl);
	SetEntityFlags(iClient, GetEntityFlags(iClient) | FL_FROZEN | FL_ATCONTROLS);
	AcceptEntityInput(iViewControl, "Enable", iClient, iViewControl, 0);

	/*
	 * HIDEHUD_MISCSTATUS will hide weapon statuses such as the banner rage bar and killstreak number
	 * but menu panels will also no longer show.  If the player must be alive on a team rather than
	 * as a spectator, these weapons may have to be temporarily removed to hide their HUD elements
	 * and keep the HUD interface clean while still allowing menu panels to show.
	 */

	SetEntProp(iClient, Prop_Send, "m_iHideHUD", HIDEHUD_HEALTH | HIDEHUD_WEAPONSELECTION);

	eCommander.hBackupObsTarget = GetEntProp(iClient, Prop_Send, "m_hObserverTarget");
	eCommander.iBackupObsMode = GetEntProp(iClient, Prop_Send, "m_iObserverMode");

	SetEntProp(iClient, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(iClient, Prop_Send, "m_iObserverMode", OBS_MODE_DEATHCAM, false);

	SetEntProp(iClient, Prop_Send, "m_iFOV", eCommander.iFOV);
	SetEntProp(iClient, Prop_Send, "m_iDefaultFOV", eCommander.iDefaultFOV);
	SetEntProp(iClient, Prop_Send, "m_nForceTauntCam", 0);
	SetEntProp(iClient, Prop_Send, "m_nForceTauntCam", 0);
	SetEntProp(iClient, Prop_Data, "m_takedamage", 2);

	eCommander.bEnabled = true;
	eCommander.fMouse = {0.5, 0.5};
	eCommander.fDistance = fInitialDistance;
	eCommander.hSelectedUnits = new ArrayList(sizeof(UnitSelection));

	eCommander.iSelectBeamsEntRef = {INVALID_ENT_REFERENCE, INVALID_ENT_REFERENCE, INVALID_ENT_REFERENCE, INVALID_ENT_REFERENCE};

	g_eCommander[iClient] = eCommander;
}

static void ResetClient(int iClient) {
	if (!g_eCommander[iClient].bEnabled) {
		return;
	}

	int hViewEntity = GetEntPropEnt(iClient, Prop_Data, "m_hViewEntity");
	if (IsValidEntity(hViewEntity) && hViewEntity != iClient) {
		AcceptEntityInput(hViewEntity, "Disable", hViewEntity, hViewEntity);
	}

	SetClientViewEntity(iClient, iClient);

	int iFocusEntity = EntRefToEntIndex(g_eCommander[iClient].iFocusEntRef);
	if (iFocusEntity && IsValidEntity(iFocusEntity)) {
		RemoveEntity(iFocusEntity); // Removes hierarchy, including camera enitty
	}

	SetEntProp(iClient, Prop_Send, "m_iFOV", g_eCommander[iClient].iFOV);
	SetEntProp(iClient, Prop_Send, "m_iDefaultFOV", g_eCommander[iClient].iDefaultFOV);

	if (g_eCommander[iClient].bHasForceTauntCamProp) {
		SetEntProp(iClient, Prop_Send, "m_nForceTauntCam", g_eCommander[iClient].bBackupForceTauntCam);
	}

	SetEntProp(iClient, Prop_Send, "m_hObserverMode", g_eCommander[iClient].iBackupObsMode, false);

	if (IsValidEntity(g_eCommander[iClient].hBackupObsTarget)) {
		SetEntProp(iClient, Prop_Send, "m_hObserverTarget", g_eCommander[iClient].hBackupObsTarget);
	} else {
		SetEntProp(iClient, Prop_Send, "m_hObserverTarget", iClient);
	}

	SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);

	SetEntityFlags(iClient, GetEntityFlags(iClient) & ~(FL_FROZEN | FL_ATCONTROLS));
	SetEntityMoveType(iClient, MOVETYPE_WALK);

	RemoveSelectBeams(iClient);
	ClearUnitSelection(iClient);

	delete g_eCommander[iClient].hSelectedUnits;

	g_eCommander[iClient].bEnabled = false;
}

static int CreateBeam(int iClient, int iColor[4]=COLORR_WHITE, float fWidth=0.1) {
	int iBeamEnt = CreateEntityByName("env_beam");
	if (!IsValidEntity(iBeamEnt)) {
		return INVALID_ENT_REFERENCE;
	}

	SetEntityModel(iBeamEnt, LASER_MODEL);
	SetEntityRenderColor(iBeamEnt, iColor[0], iColor[1], iColor[2], iColor[3]);

	SetEntProp(iBeamEnt, Prop_Send, "m_nBeamType", 2);
	SetEntPropFloat(iBeamEnt, Prop_Data, "m_fWidth", fWidth);
	SetEntPropFloat(iBeamEnt, Prop_Data, "m_fEndWidth", fWidth);

	SetEntPropEnt(iBeamEnt, Prop_Data, "m_hOwnerEntity", iClient);

	DispatchSpawn(iBeamEnt);

	return iBeamEnt;
}

static void AttachBeam(int iBeamEnt, int iOtherEnt) {
	if (!IsValidEntity(iBeamEnt) || !IsValidEntity(iOtherEnt)) {
		return;
	}

	SetEntPropEnt(iBeamEnt, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iBeamEnt));
	SetEntPropEnt(iBeamEnt, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iOtherEnt), 1);
	SetEntProp(iBeamEnt, Prop_Send, "m_nNumBeamEnts", 2);

	AcceptEntityInput(iBeamEnt,"TurnOn");
}

static void RemoveSelectBeams(int iClient) {
	for (int i=0; i<4; i++) {
		int iEnt = EntRefToEntIndex(g_eCommander[iClient].iSelectBeamsEntRef[i]);
		if (iEnt && IsValidEntity(iEnt)) {
			RemoveEntity(iEnt);
		}

		g_eCommander[iClient].iSelectBeamsEntRef[i] = INVALID_ENT_REFERENCE;
	}
}

static void ClearUnitSelection(int iClient) {
	ArrayList hSelectedUnits = g_eCommander[iClient].hSelectedUnits;

	for (int i=0; i<hSelectedUnits.Length; i++) {
		UnitSelection eUnitSelection;
		hSelectedUnits.GetArray(i, eUnitSelection);
		RemoveHealthBeams(eUnitSelection);
		hSelectedUnits.SetArray(i, eUnitSelection);
	}

	hSelectedUnits.Clear();
}

static void RemoveHealthBeams(UnitSelection eUnitSelection) {
	for (int i=0; i<sizeof(UnitSelection::iHealthBeamEntRef); i++) {
		int iEnt = EntRefToEntIndex(eUnitSelection.iHealthBeamEntRef[i]);
		if (iEnt && IsValidEntity(iEnt)) {
			RemoveEntity(iEnt);
		}
		eUnitSelection.iHealthBeamEntRef[i] = INVALID_ENT_REFERENCE;
	}
}

static void GetCursorVector(int iClient, float vecVector[3], float fMouse[2], float vecCursorVector[3]) {
	int iFOV = g_eCommander[iClient].iDefaultFOV;
	float fAspectRatio = g_eCommander[iClient].fAspectRatio;

	float fMaxX = ArcTangent2(DegToRad(0.5*iFOV), 1.0);
	float fMaxY = ArcTangent2(DegToRad(0.5*iFOV/fAspectRatio), 1.0);

	float fCursorX = 4*(fMouse[0]-0.5)*fMaxX;
	float fCursorY = 2*fAspectRatio*(fMouse[1]-0.5)*fMaxY;

	float vecVectorAng[3];
	GetVectorAngles(vecVector, vecVectorAng);

	Vector_DegToRad(vecVectorAng);

	float vecCursor[3];
	vecCursor[0] = 1.0;
	vecCursor[1] = -fCursorX;
	vecCursor[2] = -fCursorY;

	float matRotation[3][3];
	Matrix_GetRotationMatrix(matRotation, vecVectorAng[2], vecVectorAng[0], vecVectorAng[1]);

	Matrix_VectorMultiply(matRotation, vecCursor, vecCursorVector);
}

static int GetUnitSelectTrace(int iClient, const float vecPos[3], const float vecAng[3], float vecEndPos[3]) {
	TR_TraceRayFilter(vecPos, vecAng, MASK_PLAYERSOLID, RayType_Infinite, TraceEntityFilter_Units, iClient);
	if (TR_DidHit()) {
		TR_GetEndPosition(vecEndPos);

		// Omit worldspawn/0
		int iEntity = TR_GetEntityIndex();
		if (iEntity) {
			return iEntity;
		}
	}

	return INVALID_ENT_REFERENCE;
}

static void ProcessCameraControls(int iClient, int iButtons, const int iMouse[2]) {
	// Prevents changing camera target or mode
	SetEntProp(iClient, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(iClient, Prop_Send, "m_hObserverMode", OBS_MODE_DEATHCAM, false);

	float fMouse[2];
	fMouse[0] = g_eCommander[iClient].fMouse[0] + MOUSE_SENSITIVITY * iMouse[0];
	fMouse[1] = g_eCommander[iClient].fMouse[1] + MOUSE_SENSITIVITY * iMouse[1];

	if (!g_eCommander[iClient].bRotating) {
		fMouse[0] = Clamp(fMouse[0], CLAMP_MOUSE_MIN_X, CLAMP_MOUSE_MAX_X);
		fMouse[1] = Clamp(fMouse[1], CLAMP_MOUSE_MIN_Y, CLAMP_MOUSE_MAX_Y);
	}

	g_eCommander[iClient].fMouse = fMouse;

	float vecMins[3], vecMaxs[3];
	vecMins = g_eCommander[iClient].vecMins;
	vecMaxs = g_eCommander[iClient].vecMaxs;

	int iFocusEntity = EntRefToEntIndex(g_eCommander[iClient].iFocusEntRef);
	int iCameraEntity = EntRefToEntIndex(g_eCommander[iClient].iCameraEntRef);

	float vecFocusPos[3];
	GetEntPropVector(iFocusEntity, Prop_Send, "m_vecOrigin", vecFocusPos);

	float vecCameraPos[3];
	GetEntPropVector(iCameraEntity, Prop_Send, "m_vecOrigin", vecCameraPos);  // Relative to parent focus entity

	// Camera rotation

	bool bRotateKeypress = (iButtons & (IN_LEFT | IN_RIGHT)) != 0 && !(iButtons & (IN_LEFT & IN_RIGHT));

	if (iButtons & IN_ATTACK3 || bRotateKeypress) {
		if (!g_eCommander[iClient].bRotating) {
			g_eCommander[iClient].fRotatingStartMouse = fMouse;

			g_eCommander[iClient].vecRotatingStartVector = g_eCommander[iClient].vecVector;
			g_eCommander[iClient].vecRotatingStartDistance = g_eCommander[iClient].fDistance;

			g_eCommander[iClient].fRotatingKeyPress = 0.0;
		}

		g_eCommander[iClient].bRotating = true;

		// Incompatible since rotation requires fixed spherical radius that zooming would have changed
		g_eCommander[iClient].bZoomingIn = g_eCommander[iClient].bZoomingOut = false;

		// Incompatible since overlapping mouse dragging
		g_eCommander[iClient].bMoveDragging = false;
		g_eCommander[iClient].fMouseDragStartTime = 0.0;

		float vecVector[3];
		vecVector = g_eCommander[iClient].vecRotatingStartVector;

		float fDistance = g_eCommander[iClient].vecRotatingStartDistance;

		float fStartMouse[2];
		fStartMouse = g_eCommander[iClient].fRotatingStartMouse;

		float fCameraPitchAng = ArcSine(vecVector[2]) + FLOAT_PI;
		float fCameraYawAng = 0.5*FLOAT_PI-ArcTangent2(vecVector[0], vecVector[1]);

		if (bRotateKeypress) {
			int iSign = (iButtons & IN_RIGHT) ? 1 : -1;
			float fMouseShift = g_eCommander[iClient].fRotatingKeyPress += iSign*ROTATION_KEYPRESS_SPEED;

			fCameraYawAng -= fMouseShift * 0.5*FLOAT_PI;
		} else {
			fCameraPitchAng -= (fMouse[1]-fStartMouse[1]) * 0.25*FLOAT_PI;
			fCameraYawAng -= (fMouse[0]-fStartMouse[0]) * 0.5*FLOAT_PI;
		}

		if (fCameraPitchAng < -0.5*FLOAT_PI + AXIS_OFFSET + FLOAT_PI) {
			fCameraPitchAng = -0.5*FLOAT_PI + AXIS_OFFSET + FLOAT_PI;
		} else if (fCameraPitchAng > -AXIS_OFFSET + FLOAT_PI) {
			fCameraPitchAng = -AXIS_OFFSET + FLOAT_PI;
		}

		vecVector[0] = Cosine(fCameraYawAng);
		vecVector[1] = Sine(fCameraYawAng);
		vecVector[2] = Sine(fCameraPitchAng);

		float fDist2D = SquareRoot(fDistance*fDistance-vecCameraPos[2]*vecCameraPos[2]);

		vecCameraPos[0] = Clamp(-vecVector[0]*fDist2D, vecMins[0]-vecFocusPos[0], vecMaxs[0]-vecFocusPos[0]);
		vecCameraPos[1] = Clamp(-vecVector[1]*fDist2D, vecMins[1]-vecFocusPos[1], vecMaxs[1]-vecFocusPos[1]);
		vecCameraPos[2] = Clamp(vecVector[2]*fDistance, vecMins[2]-vecFocusPos[2], vecMaxs[2]-vecFocusPos[2]);

		float vecCameraAng[3];
		NormalizeVector(vecCameraPos, vecVector);
		ScaleVector(vecVector, -1.0);
		GetVectorAngles(vecVector, vecCameraAng);

		TeleportEntity(iCameraEntity, vecCameraPos, vecCameraAng, ZERO_VECTOR);

		g_eCommander[iClient].vecVector = vecVector;
	} else if (g_eCommander[iClient].bRotating) {
		g_eCommander[iClient].bRotating = false;

		g_eCommander[iClient].fMouse = g_eCommander[iClient].fRotatingStartMouse;
	}

	g_eCommander[iClient].bMoving = false;

	float vecVector[3];
	vecVector = g_eCommander[iClient].vecVector;

	float fDistance = g_eCommander[iClient].fDistance = GetVectorLength(vecCameraPos);

	// Camera zoom

	bool bZoomingIn = g_eCommander[iClient].bZoomingIn;
	bool bZoomingOut = g_eCommander[iClient].bZoomingOut;

	float vecCameraVel[3];
	GetEntPropVector(iCameraEntity, Prop_Data, "m_vecVelocity", vecCameraVel);

	if (bZoomingIn || bZoomingOut) {
		vecCameraVel = vecVector;
		ScaleVector(vecCameraVel, ZOOM_SPEED * (bZoomingIn ? 1 : -1));

		g_eCommander[iClient].bZoomingIn = g_eCommander[iClient].bZoomingOut = false;
	} else {
		ScaleVector(vecCameraVel, ZOOM_DECEL_MULTIPLIER);
	}

	float fMinZoom = g_eCommander[iClient].fMinZoom;
	if (fDistance < fMinZoom && vecCameraVel[2] < 0.0) {
		vecCameraVel = ZERO_VECTOR;
	} else if (vecFocusPos[2]+vecCameraPos[2] > vecMaxs[2] && vecCameraVel[2] > 0.0) {
		vecCameraVel = ZERO_VECTOR;
	}

	// Planar scrolling

	float fSpeed = SCROLL_SPEED * fDistance / DEFAULT_MIN_ZOOM;

	float vecForward[3];
	vecForward[0] = vecVector[0];
	vecForward[1] = vecVector[1];
	NormalizeVector(vecForward, vecForward);

	float vecUp[3] = {0.0, 0.0, 1.0};
	float vecRight[3];
	GetVectorCrossProduct(vecVector, vecUp, vecRight);
	NormalizeVector(vecRight, vecRight);

	float vecFocusVel[3];
	GetEntPropVector(iFocusEntity, Prop_Data, "m_vecVelocity", vecFocusVel);

	if (g_eCommander[iClient].bMoveDragging) {
		vecFocusVel = g_eCommander[iClient].vecMoveDragVel;
	} else {
		int iMoveDir[2];
		if (fMouse[0] == CLAMP_MOUSE_MIN_X || iButtons & IN_MOVELEFT) {
			vecFocusVel[0] = -fSpeed * vecRight[0];
			vecFocusVel[1] = -fSpeed * vecRight[1];

			iMoveDir[0] = 1;
			g_eCommander[iClient].bMoving = true;
		} else if (fMouse[0] == CLAMP_MOUSE_MAX_X || iButtons & IN_MOVERIGHT) {
			vecFocusVel[0] = fSpeed * vecRight[0];
			vecFocusVel[1] = fSpeed * vecRight[1];

			iMoveDir[0] = -1;
			g_eCommander[iClient].bMoving = true;
		}

		if (fMouse[1] == CLAMP_MOUSE_MIN_Y || iButtons & IN_FORWARD) {
			if (g_eCommander[iClient].bMoving) {
				vecFocusVel[0] += fSpeed * vecForward[0];
				vecFocusVel[1] += fSpeed * vecForward[1];
			} else {
				vecFocusVel[0] = fSpeed * vecForward[0];
				vecFocusVel[1] = fSpeed * vecForward[1];

				g_eCommander[iClient].bMoving = true;
			}

			iMoveDir[1] = 1;
		} else if (fMouse[1] == CLAMP_MOUSE_MAX_Y || iButtons & IN_BACK) {
			if (g_eCommander[iClient].bMoving) {
				vecFocusVel[0] += -fSpeed * vecForward[0];
				vecFocusVel[1] += -fSpeed * vecForward[1];
			} else {
				vecFocusVel[0] = -fSpeed * vecForward[0];
				vecFocusVel[1] = -fSpeed * vecForward[1];

				g_eCommander[iClient].bMoving = true;
			}

			iMoveDir[1] = -1;
		}

		if (g_eCommander[iClient].bMoving & !(iButtons & (IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT))) {
			float fDragAng = ArcTangent2(float(iMoveDir[0]), float(iMoveDir[1]));
			if (fDragAng < 0) {
				fDragAng += 2*FLOAT_PI;
			}

			int iScrollCursorIdx = RoundToNearest(fDragAng/(FLOAT_PI/4)) % 8;

			g_eCommander[iClient].sCursor = g_sScrollCursors[iScrollCursorIdx];
		}
	}

	// Bounds check

	bool bMinOOB[2];
	bMinOOB[0] = vecFocusPos[0] <= vecMins[0] || vecFocusPos[0]+vecCameraPos[0] <= vecMins[0];
	bMinOOB[1] = vecFocusPos[1] <= vecMins[1] || vecFocusPos[1]+vecCameraPos[1] <= vecMins[1];

	bool bMaxOOB[2];
	bMaxOOB[0] = vecFocusPos[0] >= vecMaxs[0] || vecFocusPos[0]+vecCameraPos[0] >= vecMaxs[0];
	bMaxOOB[1] = vecFocusPos[1] >= vecMaxs[1] || vecFocusPos[1]+vecCameraPos[1] >= vecMaxs[1];

	if (vecFocusVel[0] < 0 && bMinOOB[0] || vecFocusVel[0] > 0 && bMaxOOB[0]) {
		vecFocusVel[0] = 0.0;
		vecFocusVel[2] = 0.0;
	}

	if (vecFocusVel[1] < 0 && bMinOOB[1] || vecFocusVel[1] > 0 && bMaxOOB[1]) {
		vecFocusVel[1] = 0.0;
		vecFocusVel[2] = 0.0;
	}

	if (bZoomingOut &&
		(bMinOOB[0] && vecVector[0] > 0 || bMaxOOB[0] && vecVector[0] < 0 ||
		 bMinOOB[1] && vecVector[1] > 0 || bMaxOOB[1] && vecVector[1] < 0)) {

		vecCameraVel = ZERO_VECTOR;

		g_eCommander[iClient].bMoving = true;
	}

	if (!g_eCommander[iClient].bMoving) {
		ScaleVector(vecFocusVel, SCROLL_DECEL_MULTIPLIER);
	}

	// Move focus and camera entities but not while dragging for unit selection

	if (g_eCommander[iClient].bDragging) {
		SetEntPropVector(iFocusEntity, Prop_Data, "m_vecVelocity", ZERO_VECTOR);
		SetEntPropVector(iCameraEntity, Prop_Data, "m_vecVelocity", ZERO_VECTOR);
	} else {
		SetEntPropVector(iFocusEntity, Prop_Data, "m_vecVelocity", vecFocusVel);
		SetEntPropVector(iCameraEntity, Prop_Data, "m_vecVelocity", vecCameraVel);
	}

	// Highlight all selected units
	HighlightSelectedUnits(iClient);

	if (bZoomingIn || bZoomingOut || g_eCommander[iClient].bRotating) {
		return;
	}

	bool bMouseButton1Down = g_eCommander[iClient].bMouseButton1Down;
	bool bMouseButton2Down = g_eCommander[iClient].bMouseButton2Down;

	// Cursor point and rectangle selection through a stationary viewport

	float vecCursorVector[3];
	GetCursorVector(iClient, vecVector, fMouse, vecCursorVector);

	float vecCursorAng[3];
	GetVectorAngles(vecCursorVector, vecCursorAng);

	ArrayList hSelectedUnits = g_eCommander[iClient].hSelectedUnits;

	float vecCameraAbsPos[3];
	AddVectors(vecFocusPos, vecCameraPos, vecCameraAbsPos);

	float vecCursorPos[3];
	int iSelectedEntity = GetUnitSelectTrace(iClient, vecCameraAbsPos, vecCursorAng, vecCursorPos);

	int iCursorColor[4];
	if (g_eCommander[iClient].bMoveDragging || g_eCommander[iClient].bMoving && !(iButtons & (IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT))) {
		iCursorColor = HUD_TEXT_COLORR_SCROLL;
	} else {
		iCursorColor = hSelectedUnits.Length ? HUD_TEXT_COLORR_SELECT : HUD_TEXT_COLORR_IDLE;
	}

	SetHudTextParams(fMouse[0]-0.01, fMouse[1]-0.02, 0.5, iCursorColor[0], iCursorColor[1], iCursorColor[2], iCursorColor[3], 0, 0.0, 0.0, 0.0);
	ShowSyncHudText(iClient, g_hHudText, g_eCommander[iClient].sCursor);

	if (iButtons & IN_ATTACK) {
		if (g_eCommander[iClient].bDragging) {
			if (g_eCommander[iClient].bMoving) {
				// TODO: Expand selection while scrolling
				//       In the meantime, block scrolling by moving cursor away from scroll edge

				fMouse[0] = g_eCommander[iClient].fMouse[0] = Clamp(fMouse[0], CLAMP_MOUSE_MIN_X+0.001, CLAMP_MOUSE_MAX_X-0.001);
				fMouse[1] = g_eCommander[iClient].fMouse[1] = Clamp(fMouse[1], CLAMP_MOUSE_MIN_Y+0.001, CLAMP_MOUSE_MAX_Y-0.001);
			}

			// Consistency is required for counter-clockwise order of points used in
			// SelectionContains to generate plane normals that must all point inwards

			float fMouseTopLeft[2];
			fMouseTopLeft[0] = fMouse[0] < g_eCommander[iClient].fMouseDragStart[0] ? fMouse[0] : g_eCommander[iClient].fMouseDragStart[0];
			fMouseTopLeft[1] = fMouse[1] < g_eCommander[iClient].fMouseDragStart[1] ? fMouse[1] : g_eCommander[iClient].fMouseDragStart[1];

			float fMouseBottomRight[2];
			fMouseBottomRight[0] = fMouse[0] > g_eCommander[iClient].fMouseDragStart[0] ? fMouse[0] : g_eCommander[iClient].fMouseDragStart[0];
			fMouseBottomRight[1] = fMouse[1] > g_eCommander[iClient].fMouseDragStart[1] ? fMouse[1] : g_eCommander[iClient].fMouseDragStart[1];

			float vecBoxC0[3];
			GetCursorVector(iClient, vecVector, fMouseTopLeft, vecBoxC0);
			ScaleVector(vecBoxC0, 50.0);
			AddVectors(vecCameraAbsPos, vecBoxC0, vecBoxC0);

			float vecBoxC2[3];
			GetCursorVector(iClient, vecVector, fMouseBottomRight, vecBoxC2);
			ScaleVector(vecBoxC2, 50.0);
			AddVectors(vecCameraAbsPos, vecBoxC2, vecBoxC2);

			float fTempMouse[2];

			float vecBoxC1[3];
			fTempMouse[0] = fMouseBottomRight[0];
			fTempMouse[1] = fMouseTopLeft[1];
			GetCursorVector(iClient, vecVector, fTempMouse, vecBoxC1);
			ScaleVector(vecBoxC1, 50.0);
			AddVectors(vecCameraAbsPos, vecBoxC1, vecBoxC1);

			float vecBoxC3[3];
			fTempMouse[0] = fMouseTopLeft[0];
			fTempMouse[1] = fMouseBottomRight[1];
			GetCursorVector(iClient, vecVector, fTempMouse, vecBoxC3);
			ScaleVector(vecBoxC3, 50.0);
			AddVectors(vecCameraAbsPos, vecBoxC3, vecBoxC3);

			g_eCommander[iClient].SetSelectionVertex(0, vecBoxC0);
			g_eCommander[iClient].SetSelectionVertex(1, vecBoxC1);
			g_eCommander[iClient].SetSelectionVertex(2, vecBoxC2);
			g_eCommander[iClient].SetSelectionVertex(3, vecBoxC3);

			int iEnt0 = EntRefToEntIndex(g_eCommander[iClient].iSelectBeamsEntRef[0]);
			int iEnt1, iEnt2, iEnt3;
			if (!IsValidEntity(iEnt0)) {
				RemoveSelectBeams(iClient);

				iEnt0 = CreateBeam(iClient);
				iEnt1 = CreateBeam(iClient);
				iEnt2 = CreateBeam(iClient);
				iEnt3 = CreateBeam(iClient);

				SDKHook(iEnt0, SDKHook_SetTransmit, SDKHookCB_SetTransmit_Beam);
				SDKHook(iEnt1, SDKHook_SetTransmit, SDKHookCB_SetTransmit_Beam);
				SDKHook(iEnt2, SDKHook_SetTransmit, SDKHookCB_SetTransmit_Beam);
				SDKHook(iEnt3, SDKHook_SetTransmit, SDKHookCB_SetTransmit_Beam);

				g_eCommander[iClient].iSelectBeamsEntRef[0] = EntIndexToEntRef(iEnt0);
				g_eCommander[iClient].iSelectBeamsEntRef[1] = EntIndexToEntRef(iEnt1);
				g_eCommander[iClient].iSelectBeamsEntRef[2] = EntIndexToEntRef(iEnt2);
				g_eCommander[iClient].iSelectBeamsEntRef[3] = EntIndexToEntRef(iEnt3);

				AttachBeam(iEnt0, iEnt1);
				AttachBeam(iEnt1, iEnt2);
				AttachBeam(iEnt2, iEnt3);
				AttachBeam(iEnt3, iEnt0);
			} else {
				iEnt1 = EntRefToEntIndex(g_eCommander[iClient].iSelectBeamsEntRef[1]);
				iEnt2 = EntRefToEntIndex(g_eCommander[iClient].iSelectBeamsEntRef[2]);
				iEnt3 = EntRefToEntIndex(g_eCommander[iClient].iSelectBeamsEntRef[3]);
			}

			TeleportEntity(iEnt0, vecBoxC0);
			TeleportEntity(iEnt1, vecBoxC1);
			TeleportEntity(iEnt2, vecBoxC2);
			TeleportEntity(iEnt3, vecBoxC3);

			g_eCommander[iClient].sCursor = NULL_STRING;
		} else if (!(g_eCommander[iClient].bMoving || g_eCommander[iClient].bRotating)) {
			g_eCommander[iClient].bDragging = true;

			g_eCommander[iClient].fMouseDragStart[0] = fMouse[0];
			g_eCommander[iClient].fMouseDragStart[1] = fMouse[1];
		}

		g_eCommander[iClient].bMouseButton1Down = true;

		return;
	}

	if (iButtons & IN_ATTACK2) {
		if (!bMouseButton2Down) {
			g_eCommander[iClient].fMouseDragStart[0] = fMouse[0];
			g_eCommander[iClient].fMouseDragStart[1] = fMouse[1];

			g_eCommander[iClient].fMouseDragStartTime = GetGameTime();
		}

		float fMouseDragStartTime = g_eCommander[iClient].fMouseDragStartTime;

		if (g_eCommander[iClient].bMoveDragging) {
			float fDragDiff0 = g_eCommander[iClient].fMouseDragStart[0] - fMouse[0];
			float fDragDiff1 = g_eCommander[iClient].fMouseDragStart[1] - fMouse[1];

			float fDragAng = ArcTangent2(fDragDiff0, fDragDiff1);
			if (fDragAng < 0) {
				fDragAng += 2*FLOAT_PI;
			}

			int iScrollCursorIdx = RoundToNearest(fDragAng/(FLOAT_PI/4)) % 8;
			g_eCommander[iClient].sCursor = g_sScrollCursors[iScrollCursorIdx];

			g_eCommander[iClient].vecMoveDragVel[0] = MOUSE2_DRAG_SPEED_MULT * -fSpeed * (fDragDiff0/0.5*vecRight[0] - fDragDiff1/0.5*vecForward[0]);
			g_eCommander[iClient].vecMoveDragVel[1] = MOUSE2_DRAG_SPEED_MULT * -fSpeed * (fDragDiff0/0.5*vecRight[1] - fDragDiff1/0.5*vecForward[1]);
		} else if (fMouseDragStartTime) {
			if (GetGameTime()-fMouseDragStartTime >= MOUSE2_DRAG_START_DELAY) {
				float fDragDiff0 = g_eCommander[iClient].fMouseDragStart[0] - fMouse[0];
				float fDragDiff1 = g_eCommander[iClient].fMouseDragStart[1] - fMouse[1];

				float fDragDistance = SquareRoot(fDragDiff0*fDragDiff0+fDragDiff1*fDragDiff1);
				if (hSelectedUnits.Length && fDragDistance < MOUSE2_DRAG_MIN_DIST) {
					MoveSelectedUnits(iClient, vecCursorPos, iButtons);
					g_eCommander[iClient].fMouseDragStartTime = 0.0;
				} else {
					g_eCommander[iClient].bMoveDragging = true;
				}
			}
		}

		g_eCommander[iClient].bMouseButton2Down = true;

		return;
	}

	if (bMouseButton1Down) {
		if (g_eCommander[iClient].bDragging) {
			ClearUnitSelection(iClient);

			float vecBoxC1[3], vecBoxC3[3];
			g_eCommander[iClient].GetSelectionVertex(0, vecBoxC1);
			g_eCommander[iClient].GetSelectionVertex(2, vecBoxC3);

			if (GetVectorDistance(vecBoxC1, vecBoxC3) > 0.0) {
				int iIndex;
				int iUnitEntity;
				while ((iIndex = UnitEntityIterator(iClient, iIndex, iUnitEntity)) != INVALID_ENT_REFERENCE) {
					float vecPosUnit[3];
					GetEntPropVector(iUnitEntity, Prop_Send, "m_vecOrigin", vecPosUnit);

					if (g_eCommander[iClient].SelectionContains(vecPosUnit) && hSelectedUnits.FindValue(EntIndexToEntRef(iUnitEntity)) == -1) {
						SelectUnit(iClient, iUnitEntity);
					}
				}

				if (!hSelectedUnits.Length && iSelectedEntity != INVALID_ENT_REFERENCE) {
					SelectUnit(iClient, iSelectedEntity);
				}
			} else if (iSelectedEntity != INVALID_ENT_REFERENCE) {
				ClearUnitSelection(iClient);
				SelectUnit(iClient, iSelectedEntity);
			}

			RemoveSelectBeams(iClient);
			g_eCommander[iClient].bDragging = false;
		}
	} else if (bMouseButton2Down) {
		if (g_eCommander[iClient].bMoveDragging) {
			g_eCommander[iClient].bMoveDragging = false;
			g_eCommander[iClient].fMouseDragStartTime = 0.0;
			g_eCommander[iClient].vecMoveDragVel = ZERO_VECTOR;
		} else if (GetGameTime()-g_eCommander[iClient].fMouseDragStartTime < MOUSE2_DRAG_START_DELAY) {
			MoveSelectedUnits(iClient, vecCursorPos, iButtons);
		}
	}

	g_eCommander[iClient].bMouseButton1Down = false;
	g_eCommander[iClient].bMouseButton2Down = false;

	if (iSelectedEntity != INVALID_ENT_REFERENCE) {
		g_eCommander[iClient].sCursor = CURSOR_SELECTABLE;
	} else if (hSelectedUnits.Length) {
		g_eCommander[iClient].sCursor = CURSOR_MOVE;
	} else {
		g_eCommander[iClient].sCursor = CURSOR_DEFAULT;
	}
}

static void HighlightSelectedUnits(int iClient) {
	ArrayList hSelectedUnits = g_eCommander[iClient].hSelectedUnits;
	for (int i=0; i<hSelectedUnits.Length; i++) {
		UnitSelection eUnitSelection;
		hSelectedUnits.GetArray(i, eUnitSelection);

		if (HighlightSelectedUnit(iClient, eUnitSelection)) {
			hSelectedUnits.SetArray(i, eUnitSelection);
		}
	}
}

static void MoveSelectedUnits(int iClient, float vecMovePos[3], int buttons) {
	ArrayList hSelectedUnits = g_eCommander[iClient].hSelectedUnits;

	for (int i=0; i<hSelectedUnits.Length; i++) {
		int iUnitEntity = EntRefToEntIndex(hSelectedUnits.Get(i));
		if (IsValidEntity(iUnitEntity)) {
			MoveUnit(iClient, iUnitEntity, vecMovePos, buttons);
		}
	}
}

static bool DrawUnitHealthBar(int iClient, UnitSelection eUnitSelection) {
	int iEntity = EntRefToEntIndex(eUnitSelection.iUnitEntRef);
	if (!IsValidEntity(iEntity)) {
		return false;
	}

	int iHealth = GetEntProp(iEntity, Prop_Data, "m_iHealth");
	if (iHealth <= 0.0 || (iEntity > 0 && iEntity <= MaxClients && !IsPlayerAlive(iEntity))) {
		if (eUnitSelection.iHealthBeamEntRef[0] != INVALID_ENT_REFERENCE) {
			RemoveHealthBeams(eUnitSelection);
			return true;
		}

		return false;
	}

	int iMaxHealth = GetEntProp(iEntity, Prop_Data, "m_iMaxHealth");

	int iFocusEntity = EntRefToEntIndex(g_eCommander[iClient].iFocusEntRef);
	int iCameraEntity = EntRefToEntIndex(g_eCommander[iClient].iCameraEntRef);

	float vecFocusPos[3];
	GetEntPropVector(iFocusEntity, Prop_Send, "m_vecOrigin", vecFocusPos);

	float vecCameraPos[3];
	GetEntPropVector(iCameraEntity, Prop_Send, "m_vecOrigin", vecCameraPos); // Relative to parent focus entity

	AddVectors(vecFocusPos, vecCameraPos, vecCameraPos); // Now absolute in world coordiates

	float vecCameraAng[3];
	GetEntPropVector(iCameraEntity, Prop_Data, "m_angAbsRotation", vecCameraAng);

	float vecFwd[3], vecRight[3], vecUp[3];
	GetAngleVectors(vecCameraAng, vecFwd, vecRight, vecUp);

	float vecEntityPos[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vecEntityPos);

	// Calculate the center and the highest point at the top
	// of the bounding box as projected onto the camera plane

	float vecBoundingBoxTop[4][3];
	float fProjectedHeights[4];
	GetEntityBoundingBoxTop(iEntity, vecBoundingBoxTop);

	float vecCenterPos[3];
	int iHighestIdx;
	float fMaxHeight = NEGATIVE_INFINITY;

	for (int i=0; i<sizeof(vecBoundingBoxTop); i++) {
		float vecVectorToPoint[3];
		SubtractVectors(vecBoundingBoxTop[i], vecCameraPos, vecVectorToPoint);
		NormalizeVector(vecVectorToPoint, vecVectorToPoint);

		// Sum total for average calcuation
		AddVectors(vecCenterPos, vecVectorToPoint, vecCenterPos);

		fProjectedHeights[i] = GetVectorDotProduct(vecVectorToPoint, vecUp);
		if (fProjectedHeights[i] > fMaxHeight) {
			fMaxHeight = fProjectedHeights[i];
			iHighestIdx = i;
		}
	}

	// Divide by 4 for average
	ScaleVector(vecCenterPos, 0.25);

	float vecShiftUp[3];
	vecShiftUp = vecUp;
	ScaleVector(vecShiftUp, fProjectedHeights[iHighestIdx] - GetVectorDotProduct(vecCenterPos, vecUp));
	AddVectors(vecCenterPos, vecShiftUp, vecCenterPos);
	NormalizeVector(vecCenterPos, vecCenterPos);

	float vecHealthBarPos[3];
	vecHealthBarPos = vecCenterPos;
	ScaleVector(vecHealthBarPos, 50.0);
	AddVectors(vecCameraPos, vecHealthBarPos, vecHealthBarPos);

	// Move center to the left to offset for bar extending due to overheal
	if (iHealth > iMaxHealth) {
		float vecOverhealOffset[3];
		vecOverhealOffset = vecRight;
		ScaleVector(vecOverhealOffset, HEALTH_BAR_HP_SCALE * (iMaxHealth-iHealth));
		AddVectors(vecHealthBarPos, vecOverhealOffset, vecHealthBarPos);
	}

	float vecHorizontalLeftPos[3];
	float vecHorizontalRightPos[3];

	float fBarMin = HEALTH_BAR_HP_SCALE * iMaxHealth;
	float fBarMax = HEALTH_BAR_HP_SCALE * iMaxHealth;

	float fBarSplit = HEALTH_BAR_HP_SCALE * 2*iHealth;

	float vecRightOffset[3], vecLeftOffset[3];
	vecRightOffset = vecRight;
	ScaleVector(vecRightOffset, 50.0);
	vecLeftOffset = vecRightOffset;
	ScaleVector(vecLeftOffset, -1.0);

	vecHorizontalLeftPos = vecLeftOffset;
	ScaleVector(vecHorizontalLeftPos, fBarMin);
	AddVectors(vecHealthBarPos, vecHorizontalLeftPos, vecHorizontalLeftPos);

	vecHorizontalRightPos = vecRightOffset;
	ScaleVector(vecHorizontalRightPos, fBarSplit);
	AddVectors(vecHorizontalLeftPos, vecHorizontalRightPos, vecHorizontalRightPos);

	bool bModified;

	int iEnt0 = EntRefToEntIndex(eUnitSelection.iHealthBeamEntRef[0]);
	int iEnt1, iEnt2;
	if (!IsValidEntity(iEnt0)) {
		RemoveHealthBeams(eUnitSelection);

		iEnt0 = CreateBeam(iClient);
		iEnt1 = CreateEntityByName("info_target");
		AttachBeam(iEnt0, iEnt1);
		SDKHook(iEnt0, SDKHook_SetTransmit, SDKHookCB_SetTransmit_HealthBeam);

		eUnitSelection.iHealthBeamEntRef[0] = EntIndexToEntRef(iEnt0);
		eUnitSelection.iHealthBeamEntRef[1] = EntIndexToEntRef(iEnt1);

		if (iHealth != iMaxHealth) {
			iEnt2 = CreateBeam(iClient, COLORR_GRAY);
			AttachBeam(iEnt2, iEnt1);
			SDKHook(iEnt2, SDKHook_SetTransmit, SDKHookCB_SetTransmit_HealthBeam);

			eUnitSelection.iHealthBeamEntRef[2] = EntIndexToEntRef(iEnt2);
		}

		bModified = true;
	} else {
		iEnt1 = EntRefToEntIndex(eUnitSelection.iHealthBeamEntRef[1]);
		iEnt2 = EntRefToEntIndex(eUnitSelection.iHealthBeamEntRef[2]);

		if (iHealth == iMaxHealth) {
			if (iEnt2 != INVALID_ENT_REFERENCE) {
				RemoveEntity(iEnt2);

				eUnitSelection.iHealthBeamEntRef[2] = INVALID_ENT_REFERENCE;

				bModified = true;
			}
		} else if (iEnt2 == INVALID_ENT_REFERENCE) {
			iEnt2 = CreateBeam(iClient, COLORR_GRAY);
			AttachBeam(iEnt2, iEnt1);
			SDKHook(iEnt2, SDKHook_SetTransmit, SDKHookCB_SetTransmit_Beam);

			eUnitSelection.iHealthBeamEntRef[2] = EntIndexToEntRef(iEnt2);

			bModified = true;
		}
	}

	TeleportEntity(iEnt0, vecHorizontalLeftPos);
	TeleportEntity(iEnt1, vecHorizontalRightPos);

	if (iHealth != iMaxHealth) {
		vecHorizontalLeftPos = vecHorizontalRightPos;

		vecHorizontalRightPos = vecRightOffset;
		ScaleVector(vecHorizontalRightPos, fBarMax);
		AddVectors(vecHealthBarPos, vecHorizontalRightPos, vecHorizontalRightPos);

		TeleportEntity(iEnt2, vecHorizontalRightPos);
	}

	// Color gradient based on health percentage

	float fHealthPercent = Clamp(float(iHealth)/iMaxHealth, 0.0, 1.0);

	int iHealthBarColor[4];
	int iHealthBarColorMix[4];
	iHealthBarColor = HEALTH_BAR_COLORR_LOW;
	iHealthBarColorMix = HEALTH_BAR_COLORR_FULL;

	float fColorMixRatio = fHealthPercent < HEALTH_BAR_LOW_PCT ? 0.0: fHealthPercent;

	float fHealthBarColor[4];
	fHealthBarColor[0] = fColorMixRatio*iHealthBarColorMix[0] + (1.0-fColorMixRatio)*iHealthBarColor[0];
	fHealthBarColor[1] = fColorMixRatio*iHealthBarColorMix[1] + (1.0-fColorMixRatio)*iHealthBarColor[1];
	fHealthBarColor[2] = fColorMixRatio*iHealthBarColorMix[2] + (1.0-fColorMixRatio)*iHealthBarColor[2];
	fHealthBarColor[3] = fColorMixRatio*iHealthBarColorMix[3] + (1.0-fColorMixRatio)*iHealthBarColor[3];

	// Scale to highest value while keeping RGB ratios or else beam color will appear dull and invisible

	float fMaxColorChannel = fHealthBarColor[0] > fHealthBarColor[1] ? fHealthBarColor[0] : fHealthBarColor[1];
	fMaxColorChannel = fMaxColorChannel > fHealthBarColor[2] ? fMaxColorChannel : fHealthBarColor[2];

	float fScaleToMax = 255/fMaxColorChannel;
	fHealthBarColor[0] *= fScaleToMax;
	fHealthBarColor[1] *= fScaleToMax;
	fHealthBarColor[2] *= fScaleToMax;

	iHealthBarColor[0] = RoundToFloor(fHealthBarColor[0]);
	iHealthBarColor[1] = RoundToFloor(fHealthBarColor[1]);
	iHealthBarColor[2] = RoundToFloor(fHealthBarColor[2]);
	iHealthBarColor[3] = RoundToFloor(fHealthBarColor[3]);

	SetEntityRenderColor(iEnt0, iHealthBarColor[0], iHealthBarColor[1], iHealthBarColor[2], iHealthBarColor[3]);

	return bModified;
}

static void GetEntityBoundingBoxTop(int iEntity, float vecPoints[4][3]) {
	float vecMins[3], vecMaxs[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecMins", vecMins);
	GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", vecMaxs);

	float vecPos[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vecPos);

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

static float Clamp(float fValue, float fMin, float fMax) {
	if (fValue < fMin) {
		return fMin;
	}

	if (fValue > fMax) {
		return fMax;
	}

	return fValue;
}

// Matrix vector ops

static void Vector_DegToRad(float vecVector[3]) {
	vecVector[0] = DegToRad(vecVector[0]);
	vecVector[1] = DegToRad(vecVector[1]);
	vecVector[2] = DegToRad(vecVector[2]);
}

static void Matrix_VectorMultiply(float matMatrix[3][3], float vecVector[3], float vecResult[3]) {
	vecResult[0] = matMatrix[0][0]*vecVector[0] + matMatrix[0][1]*vecVector[1] + matMatrix[0][2]*vecVector[2];
	vecResult[1] = matMatrix[1][0]*vecVector[0] + matMatrix[1][1]*vecVector[1] + matMatrix[1][2]*vecVector[2];
	vecResult[2] = matMatrix[2][0]*vecVector[0] + matMatrix[2][1]*vecVector[1] + matMatrix[2][2]*vecVector[2];
}

static void Matrix_Set(float matMatrix[3][3], float f00, float f01, float f02, float f10, float f11, float f12, float f20, float f21, float f22) {
	matMatrix[0][0] = f00;	matMatrix[0][1] = f01;	matMatrix[0][2] = f02;
	matMatrix[1][0] = f10;	matMatrix[1][1] = f11;	matMatrix[1][2] = f12;
	matMatrix[2][0] = f20;	matMatrix[2][1] = f21;	matMatrix[2][2] = f22;
}

static void Matrix_GetRotationMatrix(float matMatrix[3][3], float fA, float fB, float fG) {
	float fSinA = Sine(fA);
	float fCosA = Cosine(fA);

	float fSinB = Sine(fB);
	float fCosB = Cosine(fB);

	float fSinG = Sine(fG);
	float fCosG = Cosine(fG);

	Matrix_Set(matMatrix,
		fCosB*fCosG, 	fSinA*fSinB*fCosG - fCosA*fSinG, 	fCosA*fSinB*fCosG + fSinA*fSinG,
		fCosB*fSinG,	fSinA*fSinB*fSinG + fCosA*fCosG, 	fCosA*fSinB*fSinG - fSinA*fCosG,
		     -fSinB,		                fSinA*fCosB,	                    fCosA*fCosB
	);
}

// Stubs start here
// Fill in with code specific to bot or unit implementation

/**
 * Checks whether the selected entity is a unit controlled by the game mode
 * and can be selected by the commander
 *
 * @param iClient			Commander selecting the unit
 * @param iEntity			Entity being checked
 * @return					True if the entity is a unit
 */
static bool IsSelectableUnitEntity(int iClient, int iEntity)
{
	if(iEntity > MaxClients && iEntity < sizeof(b_NpcHasDied) && !b_NpcHasDied[iEntity])
	{
		BarrackBody npc = view_as<BarrackBody>(iEntity);
		if(npc.OwnerUserId && GetClientOfUserId(npc.OwnerUserId) == iClient)
		{
			return true;
		}
	}

	return false;
}

/**
 * Called when a unit entity is successfully selected
 * 
 * @param iClient			Commander who selected the unit
 * @param iSelectedEntity	Entity of selected unit
 */
static void SelectUnit(int iClient, int iSelectedEntity)
{
	UnitSelection eUnitSelection;
	eUnitSelection.Init(iSelectedEntity);

	g_eCommander[iClient].hSelectedUnits.PushArray(eUnitSelection);
}

/**
 * Called to highlight a unit that was selected
 * 
 * @param iClient			Commander who selected the unit
 * @param eUnitSelection	Selected unit
 * @return 					True if eUnitSelection has been altered
 */
static bool HighlightSelectedUnit(int iClient, UnitSelection eUnitSelection)
{
	return DrawUnitHealthBar(iClient, eUnitSelection);
}

/**
 * Called to move a selected unit
 * 
 * @param iClient			Commander who is moving the unit
 * @param iEntity			Entity of unit being moved
 * @param vecMovePos		Coordinates to move the unit to
 */
static void MoveUnit(int iClient, int iEntity, float vecMovePos[3], int buttons)
{
	static float LastSoundTime;
	
	bool attackMove = view_as<bool>(buttons & (IN_RELOAD|IN_ATTACK3));
	float gameTime = GetGameTime();

	if(LastSoundTime != gameTime)
	{
		ClientCommand(iClient, "playgamesound %s", attackMove ? "coach/coach_attack_here.wav" : "coach/coach_go_here.wav");
	}

	f3_SpawnPosition[iEntity] = vecMovePos;
	view_as<BarrackBody>(iEntity).CmdOverride = attackMove ? Command_RTSAttack : Command_RTSMove;
}

/**
 * Iterate through controllable units
 * 
 * @param iIndex			Index of a controllable unit starting from 0
 * @param iEntity			Entity of unit at this index, or INVALID_ENT_REFERENCE if it does not exist
 * @return					Returns the next unit index or -1 if there are no more
 */
static int UnitEntityIterator(int iClient, int iIndex=0, int &iEntity=INVALID_ENT_REFERENCE)
{
	iIndex++;
	for(; iIndex < MAXENTITIES; iIndex++)
	{
		BarrackBody npc = view_as<BarrackBody>(iIndex);
		if(!b_NpcHasDied[iIndex] && npc.OwnerUserId && GetClientOfUserId(npc.OwnerUserId) == iClient)
		{
			iEntity = iIndex;
			return iIndex;
		}
	}

	return -1;
}
