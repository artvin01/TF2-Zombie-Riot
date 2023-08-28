#pragma semicolon 1
#pragma newdecls required

static GlobalForward OnDifficultySet;

void Natives_PluginLoad()
{
	CreateNative("ZR_ApplyKillEffects", Native_ApplyKillEffects);
	CreateNative("ZR_GetLevelCount", Native_GetLevelCount);
	CreateNative("ZR_GetWaveCount", Native_GetWaveCounts);

	OnDifficultySet = new GlobalForward("ZR_OnDifficultySet", ET_Ignore, Param_Cell);
}

void Native_OnDifficultySet(int level)
{
	Call_StartForward(OnDifficultySet);
	Call_PushCell(level);
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
