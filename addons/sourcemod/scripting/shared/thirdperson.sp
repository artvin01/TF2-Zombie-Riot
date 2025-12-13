#pragma semicolon 1
#pragma newdecls required

#if defined RPG
static Cookie clientcookie;
#endif

void Thirdperson_PluginLoad()
{
	CreateNative("TPC_Get", Native_Get);
}

void Thirdperson_PluginStart()
{
	RegConsoleCmd("sm_thirdperson", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_tp", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_3", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_firstperson", Command_TpOn, "Usage: sm_firstperson");
	RegConsoleCmd("sm_fp", Command_TpOn, "Usage: sm_firstperson");

#if defined RPG
	clientcookie = RegClientCookie("tp_cookie", "", CookieAccess_Protected);
#endif

	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
}

#if defined RPG
void ThirdPerson_OnClientCookiesCached(int client)
{
	if (!IsFakeClient(client))
	{
		retrieveClientCookies(client);
	}
}

static void retrieveClientCookies(int client)									   // gets the client's cookie, or creates a new one
{
	char cookie[2];

	GetClientCookie(client, clientcookie, cookie, 2);

	if (!strlen(cookie))										// They're new, fix them
	{
		SetClientCookie(client, clientcookie, "0");
		thirdperson[client] = false;
	}
	else
	{
		thirdperson[client] = (StringToInt(cookie) == 0 ? false : true);
	}
}

static void storeClientCookies(int client)															   // stores client's cookie
{
	if(AreClientCookiesCached(client))											   // make sure DB isn't being slow
	{
		char cookie[2];

		IntToString(thirdperson[client], cookie, 2);
		SetClientCookie(client, clientcookie, cookie);
	}
}
#endif	// RPG

void Thirdperson_PlayerSpawn(int client)
{
	//if(!IsFakeClient(client))												// ignore bots, they don't need client pref entries
	{
		if (thirdperson[client])
		{
			CreateTimer(0.1, Timer_EnableFp, GetClientUserId(client));			// Fixes a bug where sometimes you get stuck in first person, by forcing this mode.
		}
	}
}

public Action Timer_EnableFp(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
		SetVariantInt(0);													// Enable TP camera
		AcceptEntityInput(client, "SetForcedTauntCam");
		CreateTimer(0.2, Timer_EnableTp, userid);								// Because sometimes, delay
	}
	return Plugin_Stop;
}

public Action Timer_EnableFp_Force(Handle timer, int client)
{
/*
#if defined ZR
	if(IsValidEntity(Building_Mounted[client]))
	{
		PrintToChat(client,"You cannot change third person while mounting.");
		return Plugin_Handled;
	}
#endif
*/
	SetVariantInt(0);					
	AcceptEntityInput(client, "SetForcedTauntCam");
	return Plugin_Stop;
}

public Action Timer_EnableTp_Force(Handle timer, int client)
{
/*
	if(BetWar_Mode())
		return Plugin_Stop;
#if defined ZR
	if(IsValidEntity(Building_Mounted[client]))
	{
		PrintToChat(client,"You cannot change third person while mounting.");
		return Plugin_Handled;
	}
#endif
*/

	SetVariantInt(1);					
	AcceptEntityInput(client, "SetForcedTauntCam");
	return Plugin_Stop;
}

public Action Timer_EnableTp(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
/*
#if defined ZR
		if(IsValidEntity(Building_Mounted[client]))
		{
			PrintToChat(client,"You cannot change third person while mounting.");
			return Plugin_Handled;
		}
#endif
*/
#if defined ZR
		if(BetWar_Mode())
			return Plugin_Stop;
#endif
		SetVariantInt(1);													// Enable TP camera
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
	return Plugin_Stop;
}

public Action Command_TpOn(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
#if defined ZR
	if(BetWar_Mode())
		return Plugin_Handled;
/*
	if(IsValidEntity(Building_Mounted[client]))
	{
		PrintToChat(client,"You cannot change third person while mounting.");
		return Plugin_Handled;
	}
*/
	if(dieingstate[client] > 0)
	{
		return Plugin_Handled;
	}
#endif
	if (IsPlayerAlive(client) && !thirdperson[client])													   // If they arn't alive, they won't have the cam set, it'll spam.
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
		thirdperson[client] = true;
	}
	else if(IsPlayerAlive(client) && thirdperson[client])
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		thirdperson[client] = false;		
		ViewChange_Update(client);
	}

#if defined RPG
	storeClientCookies(client);
#endif
	
	return Plugin_Handled;
}

public Action Command_TpOff(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
#if defined ZR
#endif
	if (IsPlayerAlive(client))
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		ViewChange_Update(client);
	}

	thirdperson[client] = false;
	
#if defined RPG
	storeClientCookies(client);
#endif

	return Plugin_Handled;
}


public int Native_Get(Handle plugin, int numParams)
{
	return thirdperson[GetNativeCell(1)];
}


public Action Timer_ChangePersonModel(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
/*
		if(BetWar_Mode())
			return Plugin_Stop;
*/
		if (thirdperson[client])													   // If they arn't alive, they won't have the cam set, it'll spam.
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}
		else if( !thirdperson[client])
		{
			SetVariantInt(0);
			AcceptEntityInput(client, "SetForcedTauntCam");
			Viewchange_UpdateDelay(client);
		}
	}
	return Plugin_Stop;
}
