#pragma semicolon 1
#pragma newdecls required

static bool b_InsideMenu[MAXPLAYERS];
static float LastMousePos[MAXPLAYERS][2];
static int i_NextRenderMouse[MAXPLAYERS];
#define PLAYSOUND_CLICK "ui/buttonclick.wav"
#define PLAYSOUND_CLICK_RELEASE "ui/buttonclickrelease.wav"
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
	PrecacheSound(PLAYSOUND_CLICK);
	PrecacheSound(PLAYSOUND_CLICK_RELEASE);
	SyncHud = CreateHudSynchronizer();
	RegConsoleCmd("sm_new_shop", 		Access_StoreMouseViaCommand, "Please Press TAB instead", FCVAR_HIDDEN);
}

void ZR_StoreMouse_MapStart()
{
	AddToDownloadsTable("materials/zombie_riot/shopoverlay/shop_overlay_1.vmt");
	AddToDownloadsTable("materials/zombie_riot/shopoverlay/shop_overlay_1.vtf");
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
	return Plugin_Handled;
}
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
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (0.0005 * (9.0 / 16.0) * TickrateModify));
		}
		else
		{
			mouse[i] = LastMousePos[client][i] + (float(rawMouse[i]) * (0.0005 * TickrateModify));
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
	}
	else
	{
		if(holding[client] & IN_ATTACK)
		{
			PlaySoundClick(client, 1);
		}
		holding[client] &= ~IN_ATTACK;
	}
	LastMousePos[client] = mouse;
	if(LastMousePos[client][1] >= 0.95
	 || LastMousePos[client][1] <= 0.05
	 || LastMousePos[client][0] >= 0.95
	 || LastMousePos[client][0] <= 0.05)
	 {
		CancelStoreMouseMenu(client);
		return false;
	 }

	StoreMouse_RenderMouse(client, mouse);
	return true;
}

void CancelStoreMouseMenu(int client)
{
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
/*
void FixStandStillDelay(int ref)
{
	//This delay is needed due to being run inside player run cmd
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return;
	SetEntityFlags(client, GetEntityFlags(client) & ~(FL_FROZEN | FL_ATCONTROLS));
}
*/
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
			mouse[0] -= 0.0075;
			mouse[1] -= 0.01;
		}
	}
	mouse[0] += 0.008;
	mouse[1] += 0.008;
	i_NextRenderMouse[client] = CURSOR_WHITE;
	
	SetHudTextParams(mouse[0]-0.01, mouse[1]-0.02, 0.5, color[0], color[1], color[2], color[3], 0, 0.0, 0.0, 0.0);
	ShowSyncHudText(client, SyncHud, cursor);
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