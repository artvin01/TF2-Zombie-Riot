#include <sourcemod>
#include <vector>
#include <dhooks>

#define	MAX_OVERLAY_DIST_SQR 90000000.0

static ConVar localplayer_index = null;

static int native_NDebugOverlay_Line(Handle plugin, int params)
{
	float origin[3];
	GetNativeArray(1, origin, 3);

	float target[3];
	GetNativeArray(2, target, 3);

	int r = GetNativeCell(3);
	int g = GetNativeCell(4);
	int b = GetNativeCell(5);

	bool noDepthTest = GetNativeCell(6);

	float duration = GetNativeCell(7);

	DrawLine(origin, target, r, g, b, noDepthTest, duration);

	return 0;
}

static int native_NDebugOverlay_Circle3(Handle plugin, int params)
{
	float position[3];
	GetNativeArray(1, position, 3);

	float xAxis[3];
	GetNativeArray(2, xAxis, 3);

	float yAxis[3];
	GetNativeArray(3, yAxis, 3);

	float radius = GetNativeCell(4);

	int r = GetNativeCell(5);
	int g = GetNativeCell(6);
	int b = GetNativeCell(7);
	int a = GetNativeCell(8);

	bool bNoDepthTest = GetNativeCell(9);

	float flDuration = GetNativeCell(10);

	DrawCircle( position, xAxis, yAxis, radius, r, g, b, a, bNoDepthTest, flDuration );

	return 0;
}

static int native_NDebugOverlay_BoxAngles(Handle plugin, int params)
{
	float origin[3];
	GetNativeArray(1, origin, 3);

	float mins[3];
	GetNativeArray(2, mins, 3);

	float maxs[3];
	GetNativeArray(3, maxs, 3);

	float angles[3];
	GetNativeArray(4, angles, 3);

	int r = GetNativeCell(5);
	int g = GetNativeCell(6);
	int b = GetNativeCell(7);
	int a = GetNativeCell(8);

	float duration = GetNativeCell(9);

	DrawBoxAngles( origin, mins, maxs, angles, r, g, b, a, duration );

	return 0;
}

static void DrawSphere( const float center[3], float radius, int r, int g, int b, bool noDepthTest, float flDuration )
{
	float edge[3]
	float lastEdge[3];

	float axisSize = radius;

	float tmp1[3];
	tmp1[0] = 0.0;
	tmp1[1] = 0.0;
	tmp1[2] = -axisSize;
	AddVectors(center, tmp1, tmp1);

	float tmp2[3];
	tmp2[0] = 0.0;
	tmp2[1] = 0.0;
	tmp2[2] = axisSize;
	AddVectors(center, tmp2, tmp2);

	DrawLine( tmp1, tmp2, r, g, b, noDepthTest, flDuration );

	tmp1[0] = 0.0;
	tmp1[1] = -axisSize;
	tmp1[2] = 0.0;
	AddVectors(center, tmp1, tmp1);

	tmp2[0] = 0.0;
	tmp2[1] = axisSize;
	tmp2[2] = 0.0;
	AddVectors(center, tmp2, tmp2);

	DrawLine( tmp1, tmp2, r, g, b, noDepthTest, flDuration );

	tmp1[0] = -axisSize;
	tmp1[1] = 0.0;
	tmp1[2] = 0.0;
	AddVectors(center, tmp1, tmp1);

	tmp2[0] = axisSize;
	tmp2[1] = 0.0;
	tmp2[2] = 0.0;
	AddVectors(center, tmp2, tmp2);

	DrawLine( tmp1, tmp2, r, g, b, noDepthTest, flDuration );

	lastEdge[0] = radius + center[0];
	lastEdge[1] = center[1];
	lastEdge[2] = center[2];

	float angle;
	for( angle=0.0; angle <= 360.0; angle += 22.5 )
	{
		edge[0] = radius * Cosine( angle / 180.0 * FLOAT_PI ) + center[0];
		edge[1] = center[1];
		edge[2] = radius * Sine( angle / 180.0 * FLOAT_PI ) + center[2];

		DrawLine( edge, lastEdge, r, g, b, noDepthTest, flDuration );

		lastEdge[0] = edge[0];
		lastEdge[1] = edge[1];
		lastEdge[2] = edge[2];
	}

	lastEdge[0] = center[0];
	lastEdge[1] = radius + center[1];
	lastEdge[2] = center[2];

	for( angle=0.0; angle <= 360.0; angle += 22.5 )
	{
		edge[0] = center[0];
		edge[1] = radius * Cosine( angle / 180.0 * FLOAT_PI ) + center[1];
		edge[2] = radius * Sine( angle / 180.0 * FLOAT_PI ) + center[2];

		DrawLine( edge, lastEdge, r, g, b, noDepthTest, flDuration );

		lastEdge[0] = edge[0];
		lastEdge[1] = edge[1];
		lastEdge[2] = edge[2];
	}

	lastEdge[0] = center[0];
	lastEdge[1] = radius + center[1];
	lastEdge[2] = center[2];

	for( angle=0.0; angle <= 360.0; angle += 22.5 )
	{
		edge[0] = radius * Cosine( angle / 180.0 * FLOAT_PI ) + center[0];
		edge[1] = radius * Sine( angle / 180.0 * FLOAT_PI ) + center[1];
		edge[2] = center[2];

		DrawLine( edge, lastEdge, r, g, b, noDepthTest, flDuration );

		lastEdge[0] = edge[0];
		lastEdge[1] = edge[1];
		lastEdge[2] = edge[2];
	}
}

static int native_NDebugOverlay_Sphere1(Handle plugin, int params)
{
	float center[3];
	GetNativeArray(1, center, 3);

	float radius = GetNativeCell(2);

	int r = GetNativeCell(3);
	int g = GetNativeCell(4);
	int b = GetNativeCell(5);

	bool noDepthTest = GetNativeCell(6);

	float flDuration = GetNativeCell(7);

	DrawSphere( center, radius, r, g, b, noDepthTest, flDuration );

	return 0;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int length)
{
	RegPluginLibrary("listen");

	CreateNative("NDebugOverlay_Line", native_NDebugOverlay_Line);
	CreateNative("NDebugOverlay_Circle3", native_NDebugOverlay_Circle3);
	CreateNative("NDebugOverlay_BoxAngles", native_NDebugOverlay_BoxAngles);
	CreateNative("NDebugOverlay_Sphere1", native_NDebugOverlay_Sphere1);

	return APLRes_Success;
}

public void OnPluginStart()
{
	GameData gamedata = new GameData("listen");

	DynamicDetour tmp_detour = DynamicDetour.FromConf(gamedata, "UTIL_GetLocalPlayer");
	tmp_detour.Enable(Hook_Pre, UTIL_GetLocalPlayer);

	tmp_detour = DynamicDetour.FromConf(gamedata, "UTIL_GetListenServerHost");
	tmp_detour.Enable(Hook_Pre, UTIL_GetListenServerHost);

	tmp_detour = DynamicDetour.FromConf(gamedata, "NDebugOverlay::Line");
	tmp_detour.Enable(Hook_Pre, NDebugOverlayLine);

	tmp_detour = DynamicDetour.FromConf(gamedata, "NDebugOverlay::Circle");
	tmp_detour.Enable(Hook_Pre, NDebugOverlayCircle);

	tmp_detour = DynamicDetour.FromConf(gamedata, "NDebugOverlay::Triangle");
	tmp_detour.Enable(Hook_Pre, NDebugOverlayTriangle);

	tmp_detour = DynamicDetour.FromConf(gamedata, "NDebugOverlay::BoxAngles");
	tmp_detour.Enable(Hook_Pre, NDebugOverlayBoxAngles);

	delete gamedata;

	localplayer_index = CreateConVar("localplayer_index", "-1");

	RegAdminCmd("sm_listen", sm_listen, ADMFLAG_ROOT);
}

public void OnConfigsExecuted()
{
	localplayer_index.IntValue = -1;
}

public void OnClientDisconnect(int client)
{
	if(client == localplayer_index.IntValue) {
		localplayer_index.IntValue = -1;
	}
}

static Action sm_listen(int client, int params)
{
	localplayer_index.IntValue = client;
	return Plugin_Handled;
}

static int get_local_player()
{
	int local = localplayer_index.IntValue;
	if(local <= 0 || local > MaxClients) {
		local = -1;
	}
	return local;
}

static int halo = -1;
static int laser = -1;
static int arrow = -1;

public void OnMapStart()
{
	switch(GetEngineVersion()) {
		case Engine_TF2: {
			halo = PrecacheModel("materials/sprites/halo01.vmt");
			laser = PrecacheModel("materials/sprites/laser.vmt");
			arrow = PrecacheModel("materials/sprites/obj_icons/capture_highlight.vmt");
		}
		case Engine_Left4Dead2: {
			halo = PrecacheModel("materials/sprites/glow01.vmt");
			laser = PrecacheModel("materials/sprites/laserbeam.vmt");
			arrow = PrecacheModel("materials/sprites/laserbeam.vmt");
		}
	}
}

static void DrawBoxAngles(const float origin[3], const float mins[3], const float maxs[3], const float angles[3], int r, int g, int b, int a, float duration)
{
	int[] clients = new int[MaxClients];
	int num_clients = collect_players(clients);

	if(num_clients == 0) {
		return;
	}

	float corners[8][3];

	for(int i = 0; i < 3; i++) {
		corners[0][i] = mins[i];
	}
	
	corners[1][0] = maxs[0];
	corners[1][1] = mins[1];
	corners[1][2] = mins[2];
	
	corners[2][0] = maxs[0];
	corners[2][1] = maxs[1];
	corners[2][2] = mins[2];
	
	corners[3][0] = mins[0];
	corners[3][1] = maxs[1];
	corners[3][2] = mins[2];
	
	corners[4][0] = mins[0];
	corners[4][1] = mins[1];
	corners[4][2] = maxs[2];
	
	corners[5][0] = maxs[0];
	corners[5][1] = mins[1];
	corners[5][2] = maxs[2];
	
	for(int i = 0; i < 3; i++) {
		corners[6][i] = maxs[i];
	}
	
	corners[7][0] = mins[0];
	corners[7][1] = maxs[1];
	corners[7][2] = maxs[2];

	for(int i = 0; i < sizeof(corners); i++) {
		float rad[3];
		rad[0] = DegToRad(angles[2]);
		rad[1] = DegToRad(angles[0]);
		rad[2] = DegToRad(angles[1]);

		float cosAlpha = Cosine(rad[0]);
		float sinAlpha = Sine(rad[0]);
		float cosBeta = Cosine(rad[1]);
		float sinBeta = Sine(rad[1]);
		float cosGamma = Cosine(rad[2]);
		float sinGamma = Sine(rad[2]);

		float x = corners[i][0], y = corners[i][1], z = corners[i][2];
		float newX, newY, newZ;
		newY = cosAlpha*y - sinAlpha*z;
		newZ = cosAlpha*z + sinAlpha*y;
		y = newY;
		z = newZ;

		newX = cosBeta*x + sinBeta*z;
		newZ = cosBeta*z - sinBeta*x;
		x = newX;
		z = newZ;

		newX = cosGamma*x - sinGamma*y;
		newY = cosGamma*y + sinGamma*x;
		x = newX;
		y = newY;
		
		corners[i][0] = x;
		corners[i][1] = y;
		corners[i][2] = z;
	}

	for(int i = 0; i < sizeof(corners); i++) {
		AddVectors(origin, corners[i], corners[i]);
	}

	int mdl = laser;
	int hal = halo;

	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;

	duration = clamp_duration(duration);

	for(int i = 0; i < 4; i++) {
		int j = ( i == 3 ? 0 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], mdl, hal, 0, 0, duration, 1.0, 1.0, 1, 1.0, color, 0);
		TE_Send(clients, num_clients);
	}

	for(int i = 4; i < 8; i++) {
		int j = ( i == 7 ? 4 : i+1 );
		TE_SetupBeamPoints(corners[i], corners[j], mdl, hal, 0, 0, duration, 1.0, 1.0, 1, 1.0, color, 0);
		TE_Send(clients, num_clients);
	}

	for(int i = 0; i < 4; i++) {
		TE_SetupBeamPoints(corners[i], corners[i+4], mdl, hal, 0, 0, duration, 1.0, 1.0, 1, 1.0, color, 0);
		TE_Send(clients, num_clients);
	}
}

static float clamp_duration(float duration)
{
	if(duration < 0.1) {
		duration = 0.1;
	}

	if(duration > 25.6) {
		duration = 25.6;
	}

	return duration;
}

static int collect_players(int[] clients)
{
	int num_clients = 0;

	int local = get_local_player();

	for(int i = 1; i <= MaxClients; ++i) {
		if(!IsClientInGame(i) ||
			IsFakeClient(i)) {
			continue;
		}

		if((local != -1 && local == i) ||
			!!(GetUserFlagBits(i) & ADMFLAG_ROOT)) {
			clients[num_clients++] = i;
		}
	}

	return num_clients;
}

static void DrawLine(float origin[3], float target[3], int r, int g, int b, bool noDepthTest, float duration)
{
	int[] clients = new int[MaxClients];
	int num_clients = collect_players(clients);

	if(num_clients == 0) {
		return;
	}

	duration = clamp_duration(duration);

	int mdl = noDepthTest ? arrow : laser;
	int hal = halo;

	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = 255;

	TE_SetupBeamPoints(origin, target, mdl, hal, 0, 0, duration, 1.0, 1.0, 1, 1.0, color, 0);
	TE_Send(clients, num_clients);
}

static void DrawTriangle(float p1[3], float p2[3], float p3[3], int r, int g, int b, int a, bool noDepthTest, float duration)
{
	
}

static MRESReturn UTIL_GetLocalPlayer(DHookReturn hReturn)
{
	int client = get_local_player();
	if(client != -1 && IsClientInGame(client)) {
		hReturn.Value = client;
	} else {
		hReturn.Value = -1;
	}
	return MRES_Supercede;
}

static MRESReturn UTIL_GetListenServerHost(DHookReturn hReturn)
{
	int client = get_local_player();
	if(client != -1 && IsClientInGame(client)) {
		hReturn.Value = client;
	} else {
		hReturn.Value = -1;
	}
	return MRES_Supercede;
}

static MRESReturn NDebugOverlayLine(DHookParam hParams)
{
	float origin[3];
	hParams.GetVector(1, origin);

	float target[3];
	hParams.GetVector(2, target);

	int r = hParams.Get(3);
	int g = hParams.Get(4);
	int b = hParams.Get(5);

	bool noDepthTest = hParams.Get(6);

	float duration = hParams.Get(7);

	DrawLine(origin, target, r, g, b, noDepthTest, duration);

	return MRES_Supercede;
}

static MRESReturn NDebugOverlayBoxAngles(DHookParam hParams)
{
	float origin[3];
	hParams.GetVector(1, origin);

	float mins[3];
	hParams.GetVector(2, mins);

	float maxs[3];
	hParams.GetVector(3, maxs);

	float angles[3];
	hParams.GetVector(4, angles);

	int r = hParams.Get(5);
	int g = hParams.Get(6);
	int b = hParams.Get(7);
	int a = hParams.Get(8);

	float duration = hParams.Get(9);

	DrawBoxAngles( origin, mins, maxs, angles, r, g, b, a, duration );

	return MRES_Supercede;
}

static MRESReturn NDebugOverlayTriangle(DHookParam hParams)
{
	float p1[3];
	hParams.GetVector(1, p1);

	float p2[3];
	hParams.GetVector(2, p2);

	float p3[3];
	hParams.GetVector(3, p3);

	int r = hParams.Get(4);
	int g = hParams.Get(5);
	int b = hParams.Get(6);
	int a = hParams.Get(7);

	bool noDepthTest = hParams.Get(8);

	float duration = hParams.Get(9);

	DrawTriangle(p1, p2, p3, r, g, b, a, noDepthTest, duration);

	return MRES_Supercede;
}

static void DrawCircle( const float position[3], const float xAxis[3], const float yAxis[3], float radius, int r, int g, int b, int a, bool bNoDepthTest, float flDuration )
{
	int nSegments = 16;
	float flRadStep = (FLOAT_PI * 2.0) / float(nSegments);

	float vecLastPosition[3];
	float vecStart[3];
	AddVectors(position, xAxis, vecStart);
	ScaleVector(vecStart, radius);
	float vecPosition[3];
	vecPosition = vecStart;

	for(int i = 1; i <= nSegments; ++i)
	{
		vecLastPosition = vecPosition;

		float tmpfl = flRadStep * i;
		float flSin = Sine(tmpfl);
		float flCos = Cosine(tmpfl);

		vecPosition = position;

		float tmpvec[3];
		tmpvec = xAxis;
		ScaleVector(tmpvec, flCos * radius);
		AddVectors(vecPosition, tmpvec, vecPosition);

		tmpvec = yAxis;
		ScaleVector(tmpvec, flSin * radius);
		AddVectors(vecPosition, tmpvec, vecPosition);

		DrawLine(vecLastPosition, vecPosition, r, g, b, bNoDepthTest, flDuration);

		if(a && i > 1)
		{
			DrawTriangle(vecStart, vecLastPosition, vecPosition, r, g, b, a, bNoDepthTest, flDuration);
		}
	}
}

static MRESReturn NDebugOverlayCircle(DHookParam hParams)
{
	float position[3];
	hParams.GetVector(1, position);

	float xAxis[3];
	hParams.GetVector(2, xAxis);

	float yAxis[3];
	hParams.GetVector(3, yAxis);

	float radius = hParams.Get(4);

	int r = hParams.Get(5);
	int g = hParams.Get(6);
	int b = hParams.Get(7);
	int a = hParams.Get(8);

	bool bNoDepthTest = hParams.Get(9);

	float flDuration = hParams.Get(10);

	DrawCircle( position, xAxis, yAxis, radius, r, g, b, a, bNoDepthTest, flDuration );

	return MRES_Supercede;
}