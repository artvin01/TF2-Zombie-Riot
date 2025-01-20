#pragma semicolon 1
#pragma newdecls required

static GlobalForward OnDifficultySet;
static GlobalForward OnClientLoaded;

void Natives_PluginLoad()
{
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetLevelCount", Native_GetLevelCount);
	CreateNative("ZR_GetWaveCount", Native_GetWaveCounts);
	CreateNative("ZR_HasNamedItem", Native_HasNamedItem);
	CreateNative("ZR_GiveNamedItem", Native_GiveNamedItem);
	CreateNative("ZR_GetAliveStatus", Native_GetAliveStatus);

	OnDifficultySet = new GlobalForward("ZR_OnDifficultySet", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	OnClientLoaded = new GlobalForward("ZR_OnClientLoaded", ET_Ignore, Param_Cell);
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
