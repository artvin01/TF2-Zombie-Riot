function OnGameEvent_scorestats_accumulated_update(params)
{
	ResetStats()
}

function OnGameEvent_player_spawn(params)
{
	local hPlayer = GetPlayerFromUserID(params.userid)
	if(hPlayer == null)
		return

	if(params.team == TEAM_UNASSIGNED)
	{
		EntFireByHandle(hPlayer, "CallScriptFunction", "ZREscapePlayerStart", 0.0, null, null)
		return
	}

	EntFireByHandle(hPlayer, "CallScriptFunction", "ZREscapeStarterItems", 0.0, null, null)
}

function OnGameEvent_player_disconnect(params)
{
	local hPlayer = GetPlayerFromUserID(params.userid)
	if(hPlayer == null)
		return

	local iIndex = g_aPlayerList.find(hPlayer)
	if(iIndex != null)
		g_aPlayerList.remove(iIndex)
}

function OnScriptHook_ZR_StartSetup(params)
{
	ZR_PapModeOnly(1)
	ZR_PerkModeOnly(1)
	ZR_LockWeapons()
	ZR_RandomizeNPCStore(ZR_STORE_RESET, 0, -1.0)
	//ZR_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, 10, -1.0)
	ResetStats()
}

function OnScriptHook_ZR_CacheWaves(params)
{
	//params.npc_sensal <- "sc7;wave_40"
}