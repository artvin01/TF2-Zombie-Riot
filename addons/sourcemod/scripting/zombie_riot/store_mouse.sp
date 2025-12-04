#pragma semicolon 1
#pragma newdecls required

static bool b_InsideMenu[MAXPLAYERS];
static float LastMousePos[MAXPLAYERS][2];
static int i_NextRenderMouse[MAXPLAYERS];

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
	return Plugin_Handled;
}
bool StoreMouse_PlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], int weapon, const int rawMouse[2])
{
	if(!b_InsideMenu[client])
		return false;

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