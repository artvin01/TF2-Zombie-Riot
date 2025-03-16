#pragma semicolon 1
#pragma newdecls required

static GlobalForward OnDifficultySet;
static GlobalForward OnClientLoaded;
static GlobalForward OnClientWorldmodel;
static GlobalForward OnGivenItem;
static GlobalForward OnKilledNPC;
static GlobalForward OnGivenCash;

void Natives_PluginLoad()
{
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetLevelCount", Native_GetLevelCount);
	CreateNative("Waves_GetRound", Native_GetWaveCounts);
	CreateNative("ZR_HasNamedItem", Native_HasNamedItem);
	CreateNative("ZR_GiveNamedItem", Native_GiveNamedItem);
	CreateNative("ZR_GetAliveStatus", Native_GetAliveStatus);

	OnDifficultySet = new GlobalForward("ZR_OnDifficultySet", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	OnClientLoaded = new GlobalForward("ZR_OnClientLoaded", ET_Ignore, Param_Cell);
	OnClientWorldmodel = new GlobalForward("ZR_OnClientWorldmodel", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	OnGivenItem = new GlobalForward("ZR_OnGivenItem", ET_Event, Param_Cell, Param_String);
	OnKilledNPC = new GlobalForward("ZR_OnKilledNPC", ET_Ignore, Param_Cell, Param_String);
	OnGivenCash = new GlobalForward("ZR_OnGivenCash", ET_Event, Param_Cell, Param_CellByRef);

	RegPluginLibrary("zombie_riot");
}

void Native_OnDifficultySet(int index, const char[] name, int level)
{
	Call_StartForward(OnDifficultySet);
	Call_PushCell(index);
	Call_PushString(name);
	Call_PushCell(level);
	Call_Finish();
}

void Native_OnClientLoaded(int client)
{
	Call_StartForward(OnClientLoaded);
	Call_PushCell(client);
	Call_Finish();
}

bool Native_OnClientWorldmodel(int client, TFClassType class, int &worldmodel, int &sound, int &bodyOverride, bool &animOverride)
{
	Action action;

	Call_StartForward(OnClientWorldmodel);
	Call_PushCell(client);
	Call_PushCell(class);
	Call_PushCellRef(worldmodel);
	Call_PushCellRef(sound);
	Call_PushCellRef(bodyOverride);
	Call_PushCellRef(animOverride);
	Call_Finish(action);

	return action >= Plugin_Changed;
}

bool Native_OnGivenItem(int client, char item[64])
{
	Action action;

	Call_StartForward(OnGivenItem);
	Call_PushCell(client);
	Call_PushStringEx(item, sizeof(item), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(action);

	if(action >= Plugin_Handled)
		item[0] = 0;

	return action >= Plugin_Changed;
}

void Native_OnKilledNPC(int client, const char[] name)
{
	Call_StartForward(OnKilledNPC);
	Call_PushCell(client);
	Call_PushString(name);
	Call_Finish();
}

bool Native_OnGivenCash(int client, int &cash)
{
	Action action;

	Call_StartForward(OnGivenCash);
	Call_PushCell(client);
	Call_PushCellRef(cash);
	Call_Finish(action);

	if(action >= Plugin_Handled)
	{
		cash = 0;
		return true;
	}

	return false;
}

public any Native_ApplyKillEffects(Handle plugin, int numParams)
{
	NPC_DeadEffects(GetNativeCell(1));
	return Plugin_Handled;
}

public any Native_GetLevelCount(Handle plugin, int numParams)
{
	return Level[GetNativeCell(1)];
}

public any Native_GetWaveCounts(Handle plugin, int numParams)
{
	return CurrentRound;
}

public any Native_HasNamedItem(Handle plugin, int numParams)
{
	int length;
	GetNativeStringLength(2, length);

	char[] buffer = new char[++length];
	GetNativeString(2, buffer, length);

	return Items_HasNamedItem(GetNativeCell(1), buffer);
}

public any Native_GiveNamedItem(Handle plugin, int numParams)
{
	int length;
	GetNativeStringLength(2, length);

	char[] buffer = new char[++length];
	GetNativeString(2, buffer, length);

	return Items_GiveNamedItem(GetNativeCell(1), buffer);
}

public any Native_GetAliveStatus(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if(TeutonType[client] == TEUTON_WAITING || GetClientTeam(client) != 2)
		return 4;	// *SPEC*
	
	if(!IsPlayerAlive(client))
		return 3;	// *DEAD*
	
	if(TeutonType[client] != TEUTON_NONE)
		return 2;	// *DEAD*

	if(dieingstate[client] != 0)
		return 1;	// *DOWNED*
	
	return 0;	// :)
}
