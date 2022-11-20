#pragma semicolon 1

#include <sourcemod>
#include <dhooks>

#pragma newdecls required

Handle g_hSDKStartLagComp;
Handle g_hSDKEndLagComp;

Address g_hSDKStartLagCompAddress;
Address g_hSDKEndLagCompAddress;
bool g_GottenAddressesForLagComp;

#define MAXTF2PLAYERS 32

public void OnPluginStart()
{
	GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");
//	DHook_CreateDetour(gamedata, "CLagCompensationManager::StartLagCompensation", DHook_StartLagCompensationPre, DHook_StartLagCompensationPost);
    
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre, _);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	
	
	delete gamedata_lag_comp;	
}
public void Sdkcall_Load_Lagcomp()
{
	if(!g_GottenAddressesForLagComp)
	{
		GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");
		g_GottenAddressesForLagComp = true;
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::StartLagCompensation");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue); //cmd? I dont know.
		if ((g_hSDKStartLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::StartLagCompensation");
		
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::FinishLagCompensation");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
		if ((g_hSDKEndLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::FinishLagCompensation");	
		
		delete gamedata_lag_comp;	
	}
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
	int Compensator = param.Get(1);
	PrintToChatAll("%x",manager);
	g_hSDKStartLagCompAddress = manager;
	PrintToChatAll("CLagCompensationManager::StartLagCompensation %i",Compensator);
	PrintToServer("CLagCompensationManager::StartLagCompensation %i",Compensator);
	return MRES_Ignored;
}

public MRESReturn FinishLagCompensation(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
	PrintToChatAll("%x",manager);
	g_hSDKEndLagCompAddress = manager;
	PrintToChatAll("CLagCompensationManager::FinishLagCompensation %i",Compensator);
	PrintToServer("CLagCompensationManager::FinishLagCompensation %i",Compensator);
	
	Sdkcall_Load_Lagcomp();
	return MRES_Ignored;
}

public void SDK_StartPlayerOnlyLagComp(int client, bool Compensate_allies)
{
	if(g_GottenAddressesForLagComp)
	{
		SDKCall(g_hSDKStartLagComp, g_hSDKStartLagCompAddress, client, (GetEntityAddress(client) + view_as<Address>(3512)));
	}
}

public void SDK_EndPlayerOnlyLagComp(int client)
{
	if(g_GottenAddressesForLagComp)
	{
		SDKCall(g_hSDKEndLagComp, g_hSDKEndLagCompAddress, client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	static int holding[MAXTF2PLAYERS];
	if(holding[client])
	{
		if(!(buttons & holding[client]))
			holding[client] = 0;
	}
	else if(buttons & IN_ATTACK2) //trigger on m2, once.
	{
		Test_Lagcompensation(client);
		holding[client] = IN_ATTACK2;
	}
	return Plugin_Continue;
}

public void Test_Lagcompensation(int client)
{
	SDK_StartPlayerOnlyLagComp(client, true);
	SDK_EndPlayerOnlyLagComp(client);	
}