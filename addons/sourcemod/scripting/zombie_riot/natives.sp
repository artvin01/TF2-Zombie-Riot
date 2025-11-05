#pragma semicolon 1
#pragma newdecls required

static GlobalForward OnDifficultySet;
static GlobalForward OnClientLoaded;
static GlobalForward OnClientWorldmodel;
static GlobalForward OnGivenItem;
static GlobalForward OnKilledNPC;
static GlobalForward OnRevivingPlayer;
static GlobalForward OnGivenCash;
static GlobalForward OnTeamWin;
static GlobalForward OnXpChanged;
static GlobalForward CanRenameNpc;
static GlobalForward OnWaveEnd;
static GlobalForward OnSpecialModeProgress;
static GlobalForward OnGiftCollected;

void Natives_PluginLoad()
{
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetLevelCount", Native_GetLevelCount);
	CreateNative("Waves_GetRound", Native_GetWaveCounts);
	CreateNative("ZR_HasNamedItem", Native_HasNamedItem);
	CreateNative("ZR_GiveNamedItem", Native_GiveNamedItem);
	CreateNative("ZR_GetAliveStatus", Native_GetAliveStatus);
	CreateNative("ZR_GetSpecialMode", Native_GetSpecialMode);
	CreateNative("ZR_SetXpAndLevel", Native_ZR_SetXpAndLevel);
	CreateNative("ZR_GetXp", Native_ZR_GetXp);

	OnDifficultySet = new GlobalForward("ZR_OnDifficultySet", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	OnClientLoaded = new GlobalForward("ZR_OnClientLoaded", ET_Ignore, Param_Cell);
	OnClientWorldmodel = new GlobalForward("ZR_OnClientWorldmodel", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	OnGivenItem = new GlobalForward("ZR_OnGivenItem", ET_Event, Param_Cell, Param_String, Param_Cell);
	OnKilledNPC = new GlobalForward("ZR_OnKilledNPC", ET_Ignore, Param_Cell, Param_String);
	OnRevivingPlayer = new GlobalForward("ZR_OnRevivingPlayer", ET_Ignore, Param_Cell, Param_Cell);
	OnGivenCash = new GlobalForward("ZR_OnGivenCash", ET_Event, Param_Cell, Param_CellByRef);
	OnTeamWin = new GlobalForward("ZR_OnWinTeam", ET_Event, Param_Cell);
	OnGiftCollected = new GlobalForward("ZR_OnGiftCollected", ET_Ignore, Param_Cell, Param_Cell);
	OnXpChanged = new GlobalForward("ZR_OnGetXP", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	CanRenameNpc = new GlobalForward("ZR_CanRenameNPCs", ET_Single, Param_Cell);
	OnWaveEnd = new GlobalForward("ZR_OnWaveEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	OnSpecialModeProgress = new GlobalForward("ZR_OnSpecialModeProgress", ET_Ignore, Param_Cell, Param_Cell);

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

void Native_ZR_OnWinTeam(int team)
{
	Call_StartForward(OnTeamWin);
	Call_PushCell(view_as<TFTeam>(team));
	Call_Finish();
}

void Native_ZR_OnGiftCollected(int collector, ZRGiftRarity rarity)
{
	Call_StartForward(OnGiftCollected);
	Call_PushCell(collector);
	Call_PushCell(rarity);
	Call_Finish();
}

void Native_ZR_OnGetXP(int client, int XPGET, int Mode)
{
	Call_StartForward(OnXpChanged);
	Call_PushCell(client);
	Call_PushCell(XPGET);
	Call_PushCell(Mode);
	Call_Finish();
}
bool Native_CanRenameNpc(int client)
{
	bool WhatReturn = true;
	Call_StartForward(CanRenameNpc);
	Call_PushCell(client);
	Call_Finish(WhatReturn);
	return WhatReturn;
}

bool Native_OnClientWorldmodel(int client, TFClassType class, int &worldmodel, int &sound, int &bodyOverride, bool &animOverride, bool &noCosmetic)
{
	Action action;

	Call_StartForward(OnClientWorldmodel);
	Call_PushCell(client);
	Call_PushCell(class);
	Call_PushCellRef(worldmodel);
	Call_PushCellRef(sound);
	Call_PushCellRef(bodyOverride);
	Call_PushCellRef(animOverride);
	Call_PushCellRef(noCosmetic);
	Call_Finish(action);

	return action >= Plugin_Changed;
}

bool Native_OnGivenItem(int client, char item[64], int index)
{
	Action action;

	Call_StartForward(OnGivenItem);
	Call_PushCell(client);
	Call_PushStringEx(item, sizeof(item), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(index);
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
void Native_OnRevivingPlayer(int reviver, int revived)
{
	Call_StartForward(OnRevivingPlayer);
	Call_PushCell(reviver);
	Call_PushCell(revived);
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

void Native_OnWaveEnd()
{
	Call_StartForward(OnWaveEnd);
	Call_PushCell(Waves_GetRoundScale());
	Call_PushCell(Waves_GetMaxRound(false));
	Call_PushCell(Waves_GetMaxRound(true));
	Call_Finish();
}
void Native_OnSpecialModeProgress(int NewFloor, int MaxFloors)
{
	Call_StartForward(OnSpecialModeProgress);
	Call_PushCell(NewFloor);
	Call_PushCell(MaxFloors);
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
public any Native_GetSpecialMode(Handle plugin, int numParams)
{
	if(Construction_Mode())
		return Mode_Construction;

	if(Rogue_Mode())
	{
		if(Rogue_Theme() == 0)
		{
			return Mode_Rogue1;
		}
		else if(Rogue_Theme() == 1)
		{
			return Mode_Rogue2;
		}
	}
	
	return Mode_Standard;	
}
public any Native_ZR_GetXp(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return XP[client];	// :)
}

public any Native_ZR_SetXpAndLevel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int XPSet = GetNativeCell(2);
	Level[client] = 0; 
	XP[client] = 0; 
	//Reset!
	GiveXP(client, XPSet, false, true);
	return 0;
}