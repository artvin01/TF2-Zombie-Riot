#pragma semicolon 1

#include <tf2>
#include <collisionhook>
#include <sourcemod>
#include <clientprefs>
#include <tf2_stocks>
#include <sdkhooks>
#include <dhooks>
#include <tf2items>
#include <tf_econ_data>
#include <tf2attributes>
#include <morecolors>

Handle g_hSDKStartLagComp;
Handle g_hSDKEndLagComp;

#define MAXTF2PLAYERS 32

public void OnPluginStart()
{
	GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");
//	DHook_CreateDetour(gamedata, "CLagCompensationManager::StartLagCompensation", DHook_StartLagCompensationPre, DHook_StartLagCompensationPost);
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::StartLagCompensation");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer); //cmd? I dont know.
	if ((g_hSDKStartLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::StartLagCompensation");
	
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::FinishLagCompensation");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
	if ((g_hSDKEndLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::FinishLagCompensation");
    
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre, _);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	
	
	delete gamedata_lag_comp;	
}

static void DHook_CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
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

public MRESReturn StartLagCompensationPre(Address manager, DHookParam param)
{
	PrintToChatAll("CLagCompensationManager::StartLagCompensation");
	PrintToServer("CLagCompensationManager::StartLagCompensation");
	return MRES_Ignored;
}

public MRESReturn FinishLagCompensation(Address manager, DHookParam param)
{
	PrintToChatAll("CLagCompensationManager::FinishLagCompensation");
	PrintToServer("CLagCompensationManager::FinishLagCompensation");
	return MRES_Ignored;
}

public void SDK_StartPlayerOnlyLagComp(int client, bool Compensate_allies)
{
	SDKCall(g_hSDKStartLagComp, client, (GetEntityAddress(client) + view_as<Address>(3512)));
}

public void SDK_EndPlayerOnlyLagComp(int client)
{
	SDKCall(g_hSDKEndLagComp, client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	static int holding[MAXTF2PLAYERS];
	if(holding[client])
	{
		if(!(buttons & holding[client]))
			holding[client] = 0;
	}
	else if(buttons & IN_ATTACK2)
	{
		SDK_StartPlayerOnlyLagComp(client, true);
		SDK_EndPlayerOnlyLagComp(client);
		holding[client] = IN_ATTACK2;
	}
	return Plugin_Continue;
}