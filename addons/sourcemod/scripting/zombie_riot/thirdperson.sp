Handle clientcookie = INVALID_HANDLE;

bool hooked;

void Thirdperson_PluginStart()
{
//	AddCommandListener(OnSay, "say");
//	AddCommandListener(OnSay, "say_team");

	RegConsoleCmd("sm_thirdperson", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_tp", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_3", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_firstperson", Command_TpOn, "Usage: sm_firstperson");
	RegConsoleCmd("sm_fp", Command_TpOn, "Usage: sm_firstperson");

	clientcookie = RegClientCookie("tp_cookie", "", CookieAccess_Protected);

	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
}
public Action OnSay(int client, const char[] command, int args)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	char chat[150];
	bool handleChat=false;

	GetCmdArgString(chat, sizeof(chat));

	if(strlen(chat)>=2 ){
		if(chat[1]=='!') handleChat=false;
		else if(chat[1]=='/') handleChat=true;
		else return Plugin_Continue;
		}  // start++; && (chat[1]=='!' || chat[1]=='/')
	else{
		return Plugin_Continue;
	}
	chat[strlen(chat)-1]='\0';

	if(StrEqual("tp", chat[2], true) ||
	StrEqual("thirdperson", chat[2], true))
	{
		Command_TpOn(client, 0);
	}

	else if(StrEqual("fp", chat[2], true) ||
	StrEqual("firstperson", chat[2], true))
	{
		Command_TpOn(client, 0);
	}
	
	else if(StrEqual("3", chat[2], true) ||
	StrEqual("3", chat[2], true))
	{
		Command_TpOn(client, 0);
	}
	
	return handleChat ? Plugin_Handled : Plugin_Continue;
}

void Third_PersonOnMapStart()
{
	if (!hooked)
	{
		PrintToServer("[Tf2] Third Person Cookies! Enabled");
		HookEvent("player_spawn", player_spawn);
		HookEvent("player_class", player_spawn);
		hooked = true;
	}
}

void ThirdPerson_OnClientCookiesCached(int client)
{
	if (!IsFakeClient(client))
	{
		retrieveClientCookies(client);
	}
}

void retrieveClientCookies(int client)									   // gets the client's cookie, or creates a new one
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

void storeClientCookies(int client)															   // stores client's cookie
{
	if(AreClientCookiesCached(client))											   // make sure DB isn't being slow
	{
		char cookie[2];

		IntToString(thirdperson[client], cookie, 2);
		SetClientCookie(client, clientcookie, cookie);
	}
}

public Action player_spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!IsFakeClient(client))												// ignore bots, they don't need client pref entries
	{
		if (thirdperson[client])
		{
			CreateTimer(0.1, Timer_EnableFp, GetClientUserId(client));			// Fixes a bug where sometimes you get stuck in first person, by forcing this mode.
		}
	}
	return Plugin_Handled;
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
	return Plugin_Handled;
}

public Action Timer_EnableFp_Force(Handle timer, int client)
{
	SetVariantInt(0);					
	AcceptEntityInput(client, "SetForcedTauntCam");
	return Plugin_Handled;
}

public Action Timer_EnableTp_Force(Handle timer, int client)
{
	SetVariantInt(1);					
	AcceptEntityInput(client, "SetForcedTauntCam");
	return Plugin_Handled;
}

public Action Timer_EnableTp(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
		SetVariantInt(1);													// Enable TP camera
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
	return Plugin_Handled;
}

public Action Command_TpOn(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
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
	}
	storeClientCookies(client);

	return Plugin_Handled;
}

public Action Command_TpOff(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	if (IsPlayerAlive(client))
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}

	thirdperson[client] = false;													 // Set it anyways, because they want us to
	storeClientCookies(client);

	return Plugin_Handled;
}


public int Native_Get(Handle plugin, int numParams)
{
	return thirdperson[GetNativeCell(1)];
}