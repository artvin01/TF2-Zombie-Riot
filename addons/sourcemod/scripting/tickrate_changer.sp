#include <sourcemod>
#include <dhooks>



ConVar CvarTickrateModify;
float ModifTickrateCurrent;
Address ADR_HostStates;

public void OnPluginStart()
{
	ModifTickrateCurrent = 66.0;
	CvarTickrateModify = CreateConVar("sv_modiftickrate", "66.0", "What should the new tickrate be? This only takes into affect after mapchange.");
	GameData gamedata = LoadGameConfigFile("tickrate_changer");


	DHook_CreateDetour(gamedata, "CServerGameDLL::GetTickInterval()", DhookGetTickInterval, _);
	int TicksToTimeOffset = gamedata.GetOffset("TicksToTimeOffset_to_host_state");
	ADR_HostStates = GameConfGetAddress(gamedata,"TicksToTime_Engine");
	ADR_HostStates = (ADR_HostStates + view_as<Address>(TicksToTimeOffset));

	PrintToServer("Change the map to make The tickrate changer take into affect!");
	PrintToServer("host_state Time : %.3f",LoadFromAddress(ADR_HostStates, NumberType_Int32));
}


public void OnMapEnd()
{
	ModifTickrateCurrent = CvarTickrateModify.FloatValue;
	StoreToAddress(ADR_HostStates, (1.0 / ModifTickrateCurrent), NumberType_Int32);
	ConVar TempCvar;
	TempCvar = FindConVar("sv_maxcmdrate");
	TempCvar.IntValue = RoundToNearest(ModifTickrateCurrent);
	TempCvar = FindConVar("sv_mincmdrate");
	TempCvar.IntValue = RoundToNearest(ModifTickrateCurrent);
	TempCvar = FindConVar("sv_minupdaterate");
	TempCvar.IntValue = RoundToNearest(ModifTickrateCurrent);
	TempCvar = FindConVar("sv_maxupdaterate");
	TempCvar.IntValue = RoundToNearest(ModifTickrateCurrent);
}

public MRESReturn DhookGetTickInterval(any useless, DHookReturn returnHook, DHookParam param)
{
	returnHook.Value = (1.0 / ModifTickrateCurrent);
	PrintToChatAll("testlol %i",ModifTickrateCurrent);
	PrintToServer("testlol %i",ModifTickrateCurrent);
	return MRES_Supercede;
}


stock void DHook_CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if(detour)
	{
		if(preCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, false, preCallback))
			LogError("[Gamedata] Failed to enable pre detour: %s", name);

		if(postCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, true, postCallback))
			LogError("[Gamedata] Failed to enable post detour: %s", name);

		delete detour;
	}
	else
	{
		LogError("[Gamedata] Could not find %s", name);
	}
}