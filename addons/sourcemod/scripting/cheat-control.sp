// enforce semicolons after each code statement
#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.5"



/*****************************************************************


					P L U G I N   I N F O


*****************************************************************/

public Plugin:myinfo = 
{
  name = "Cheat Control",
  author = "Berni",
  description = "Allows admins to use cheat commands, cheat impulses and cheat cvars, and blocks them for none admins",
  version = PLUGIN_VERSION,
  url = "http://forums.alliedmods.net/showthread.php?p=600521"
};



/*****************************************************************


					G L O B A L   V A R S


*****************************************************************/

// ConVar Handles
new Handle:sv_cheats;
new Handle:cheatcontrol_version;
new Handle:cheatcontrol_adminsonly;
new Handle:cheatcontrol_enablewarnings;
new Handle:cheatcontrol_maxwarnings;
new Handle:cheatcontrol_printtoadmins;
new Handle:cheatcontrol_stripnotifyflag;

// Others
new playerWarnings[MAXPLAYERS];
new Handle:adt_allowedCommands;
new Handle:adt_allowedImpulses;

new cheatImpulses[] = {
	50, 51, 52, 76, 81, 82, 83, 101, 102, 103, 106, 107, 108, 195, 196, 197, 200, 202, 203
};



/*****************************************************************


				F O R W A R D   P U B L I C S


*****************************************************************/

public OnPluginStart() {
	
	// ConVars
	cheatcontrol_version = CreateConVar("cheatcontrol_version", PLUGIN_VERSION, "Cheatcontrol plugin version", FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_NOTIFY);
	// Set it to the correct version, in case the plugin gets updated...
	SetConVarString(cheatcontrol_version, PLUGIN_VERSION);

	cheatcontrol_adminsonly			= CreateConVar("cheatcontrol_enable",			"1", 	"Enable/disable this plugin (disabling it enables usage of cheats for everyone)",	FCVAR_PLUGIN);
	cheatcontrol_enablewarnings		= CreateConVar("cheatcontrol_enablewarnings",	"1",	"Enable the cheatcontrol warning system"										,	FCVAR_PLUGIN);
	cheatcontrol_maxwarnings		= CreateConVar("cheatcontrol_maxwarnings",		"5",	"Max warnings a player gets after he will be kicked"							,	FCVAR_PLUGIN);
	cheatcontrol_printtoadmins		= CreateConVar("cheatcontrol_printtoadmins",	"0",	"Set if to forward warning messages to admins or not"							,	FCVAR_PLUGIN);
	cheatcontrol_stripnotifyflag	= CreateConVar("cheatcontrol_stripnotifyflag",	"1",	"Sets if to strip the notification flag from sv_cheats or not"					,	FCVAR_PLUGIN);
	
	// We need to hook this one cvar to react on changes
	HookConVarChange(cheatcontrol_adminsonly, OnConVarChanged_CheatsAdmOnly);
	
	sv_cheats = FindConVar("sv_cheats");
	HookConVarChange(sv_cheats, OnConVarChanged_SvCheats);
	
	// Auto generate config file
	AutoExecConfig();
	
	// Admin Commands
	RegAdminCmd("sm_allowcheatcommand",			Command_AllowCheatCommand,			ADMFLAG_CHEATS,	"Allows a specific cheat comamnd for usage by none-admins");
	RegAdminCmd("sm_disallowcheatcommand",		Command_DisallowCheatCommand,		ADMFLAG_CHEATS,	"Disallows a specific cheat comamnd for usage by none-admins", "");
	RegAdminCmd("sm_cheatcontrol_reloadcfg",	Command_ReloadCfg,					ADMFLAG_CHEATS,	"Reloads the cheat-control config file(s)", "");
	
	
	if (GetConVarBool(cheatcontrol_stripnotifyflag)) {
		// Stripping the nofity flag off sv_cheats
		new cvarCheatsflags = GetConVarFlags(sv_cheats);
		cvarCheatsflags &= ~FCVAR_NOTIFY;
		SetConVarFlags(sv_cheats, cvarCheatsflags);
	}
	
	UpdateClientCheatValue();
	HookCheatCommands();

	adt_allowedCommands = CreateArray(64);
	adt_allowedImpulses = CreateArray();
}

public OnConfigsExecuted() {
	ReadAllowedCommands();
}

public OnRebuildAdminCache(AdminCachePart:part) {
	UpdateClientCheatValue();
}

public OnClientPutInServer(client) {
	// Don't send the value to fake clients
	if (IsFakeClient(client)) {
		return;
	}

	if (GetConVarBool(sv_cheats) && GetConVarBool(cheatcontrol_adminsonly)) {
		SendConVarValue(client, sv_cheats, "1");
	}
}

public OnClientPostAdminCheck(client) {
	// Don't send the value to fake clients
	if (IsFakeClient(client)) {
		return;
	}

	if (CanClientCheat(client) || !GetConVarBool(cheatcontrol_adminsonly)) {
		SendConVarValue(client, sv_cheats, "1");
	}
}

public Action:OnCheatCommand(client, const String:command[], argc) {
	
	if (CanClientCheat(client)) {	
		return Plugin_Continue;
	}
	
	decl String:buf[64];
	new size = GetArraySize(adt_allowedCommands);
	for (new i=0; i<size; ++i) {
		GetArrayString(adt_allowedCommands,i, buf, sizeof(buf));
		
		if (StrEqual(buf, command, false)) {
			return Plugin_Continue;
		}
	}
	
	new maxWarnings = GetConVarInt(cheatcontrol_maxwarnings);
	
	if (GetConVarBool(cheatcontrol_printtoadmins)) {
		PrintToChatAdmins("\x04[Cheat-Control] \x01Player %N tried to execute cheat-command: %s - \x04%d\x01/\x04%d \x01warnings", client, command, playerWarnings[client], maxWarnings);
	}
	
	if (GetConVarBool(cheatcontrol_enablewarnings)) {
		
		if (playerWarnings[client] == maxWarnings) {
			KickClient(client, "[Cheat-Control] Permission denied to command %s - max. number of warnings reached", command);
		}
		else {
			playerWarnings[client]++;
			
			PrintToChat(client,"\x04[Cheat-Control] \x01Permission denied to command %s - \x04%d\x01/\x04%d \x01warnings", command, playerWarnings[client], maxWarnings);
		}
	}
	
	
	return Plugin_Handled;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon) {
	
	if (!CheatImpulse(client, impulse)) {
		impulse = 0;
	}
	
	return Plugin_Changed;
	
}

/****************************************************************


			C A L L B A C K   F U N C T I O N S


****************************************************************/

public OnConVarChanged_CheatsAdmOnly(Handle:convar, const String:oldValue[], const String:newValue[]) {
	UpdateClientCheatValue();
}

public OnConVarChanged_SvCheats(Handle:convar, const String:oldValue[], const String:newValue[]) {
	UpdateClientCheatValue();
}

public Action:Command_AllowCheatCommand(client, args) {
	if (args == 1) {

		decl String:arg1[32], String:toks[2][32];
		
		GetCmdArg(1, arg1, sizeof(arg1));
		
		ExplodeString(arg1, " ", toks, 2, sizeof(toks[]));
		if (strcmp(toks[0], "impulse", false) == 0) {
			
			new impulse = StringToInt(toks[1]);
			
			new size = GetArraySize(adt_allowedImpulses);
			for (new i=0; i<size; ++i) {
				if (impulse == GetArrayCell(adt_allowedImpulses, i)) {
					ReplyToCommand(client, "\x04[Cheat-Control] \x01Impulse %d is already allowed !", impulse);
					return Plugin_Handled;
				}
			}
			
			PushArrayCell(adt_allowedImpulses, impulse);
			ReplyToCommand(client, "\x04[Cheat-Control] \x01Impulse %d has been allowed !", impulse);
		}
		else {
			decl String:buf[64];
			new size = GetArraySize(adt_allowedCommands);
			for (new i=0; i<size; ++i) {
				GetArrayString(adt_allowedCommands,i, buf, sizeof(buf));
				
				if (StrEqual(buf, arg1, false)) {
					ReplyToCommand(client, "\x04[Cheat-Control] \x01Command %s is already allowed !", arg1);
					return Plugin_Handled;
				}
			}
			
			PushArrayString(adt_allowedCommands, arg1);
			ReplyToCommand(client, "\x04[Cheat-Control] \x01Command %s has been allowed !", arg1);
		}
	}
	else {
		decl String:arg0[32];
		GetCmdArg(0, arg0, 32);
		ReplyToCommand(client, "\x04[Cheat-Control] \x01 Usage: %s <command>", arg0);
	}
	
	return Plugin_Handled;
}

public Action:Command_DisallowCheatCommand(client, args) {
	if (args == 1) {

		decl String:arg1[32], String:toks[2][32];
		
		GetCmdArg(1, arg1, sizeof(arg1));
		ExplodeString(arg1, " ", toks, 2, sizeof(toks[]));
		
		if (strcmp(toks[0], "impulse", false) == 0) {
			
			new impulse = StringToInt(toks[1]);
			
			new size = GetArraySize(adt_allowedImpulses);
			for (new i=0; i<size; ++i) {
				if (impulse == GetArrayCell(adt_allowedImpulses, i)) {
					RemoveFromArray(adt_allowedImpulses, i);
					ReplyToCommand(client, "\x04[Cheat-Control] \x01Impulse %d has been disallowed !", impulse);
					
					return Plugin_Handled;
				}
			}
			
			ReplyToCommand(client, "\x04[Cheat-Control] \x01Impulse %d is not in the list of allowed impulses !", impulse);
		}
		else {			
			decl String:buf[64];
			new size = GetArraySize(adt_allowedCommands);
			for (new i=0; i<size; ++i) {
				GetArrayString(adt_allowedCommands,i, buf, sizeof(buf));
				
				if (StrEqual(buf, arg1, false)) {
					RemoveFromArray(adt_allowedCommands, i);
					ReplyToCommand(client, "\x04[Cheat-Control] \x01Command %s has been disallowed !", arg1);
					
					return Plugin_Handled;
				}
			}
			
			ReplyToCommand(client, "\x04[Cheat-Control] \x01Command %s is not in the list of allowed commands !", arg1);
		}
	}
	else {
		decl String:arg0[32];
		GetCmdArg(0, arg0, 32);
		ReplyToCommand(client, "\x04[Cheat-Control] \x01Usage: %s <command>", arg0);
	}
	
	return Plugin_Handled;
}

public Action:Command_ReloadCfg(client, args) {
	if (ReadAllowedCommands()) {
		ReplyToCommand(client, "The \x04[Cheat-Control] \x01config files have been reloaded !");
	}
	else {
		ReplyToCommand(client, "Unable to reload the \x04[Cheat-Control] \x01config file !");
	}
}

/*****************************************************************


				P L U G I N   F U N C T I O N S


*****************************************************************/

bool:IsCheatImpulse(impulse) {
	
	for (new i=0; i<sizeof(cheatImpulses); i++) {
		
		if (cheatImpulses[i] == impulse) {
			
			return true;
		}
	}
	
	return false;
}

bool:CheatImpulse(client, impulse) {
	
	new isCheat = IsCheatImpulse(impulse);
	
	if (!isCheat) {
		return true;
	}
	
	if (CanClientCheat(client)) {
		
		return true;
	}
	
	// 	Artifact of hl2 sp
	if (impulse == 50) {
		return false;
	}
	
	new size = GetArraySize(adt_allowedImpulses);
	for (new i=0; i<size; ++i) {
		if (impulse == GetArrayCell(adt_allowedImpulses, i)) {
			return true;
		}
	}
	
	new maxWarnings = GetConVarInt(cheatcontrol_maxwarnings);
	
	if (GetConVarBool(cheatcontrol_printtoadmins)) {
		PrintToChatAdmins("\x04[Cheat-Control] \x01Player %N tried to execute cheat-impulse: %d - \x04%d\x01/\x04%d \x01warnings", client, impulse, playerWarnings[client], maxWarnings);
	}

	if (GetConVarBool(cheatcontrol_enablewarnings)) {
		if (playerWarnings[client] == maxWarnings) {
			KickClient(client, "[Cheat-Control] Permission denied to impulse %d - max. number of warnings reached", impulse);
		}
		else {
			playerWarnings[client]++;
		
			PrintToChat(client,"\x04[Cheat-Control] \x01Permission denied to impulse %d - \x04%d\x01/\x04%d \x01warnings", impulse, playerWarnings[client], maxWarnings);
		}
	}
	
	
	return false;
}


// Wrapper function for easier handling of console and fake clients
bool:HasAccess(client, AdminFlag:flag=Admin_Generic) {
	if (client == 0 || IsFakeClient(client)) {
		return true;
	}
	
	new AdminId:aid = GetUserAdmin(client);
	if (aid != INVALID_ADMIN_ID && GetAdminFlag(aid, flag)) {
		return true;
	}
	
	return false;
}

bool:CanClientCheat(client) {
	if (!GetConVarBool(cheatcontrol_adminsonly)) {
		return true;
	}
	
	if (HasAccess(client, Admin_Cheats)) {
		return true;
	}
	
	return false;
}

HookCheatCommands() {
	
	decl String:name[64];
	new Handle:cvar;
	new bool:isCommand;
	new flags;
	
	cvar = FindFirstConCommand(name, sizeof(name), isCommand, flags);
	if (cvar ==INVALID_HANDLE) {
		SetFailState("Could not load cvar list");
	}
	
	do {
		if (!isCommand || !(flags & FCVAR_CHEAT)) {
			continue;
		}
		
		AddCommandListener(OnCheatCommand, name);
		
	} while (FindNextConCommand(cvar, name, sizeof(name), isCommand, flags));
	
	CloseHandle(cvar);


	
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/cheat-control/block-commands.ini");
	
	new Handle:file = OpenFile(path, "r");
	
	if (file == INVALID_HANDLE) {
		return;
	}
	
	decl String:line[1024];
	
	while (!IsEndOfFile(file)) {
		if (!ReadFileLine(file, line, sizeof(line))) {
			break;
		}
		
		ReplaceString(line, sizeof(line), "\r", "");
		ReplaceString(line, sizeof(line), "\n", "");
		
		new pos;
		if ((pos = StrContains(line, "//")) != -1) {
			line[pos] = '\0';
		}
		
		TrimString(line);
		
		if (StrEqual(line, "") || StrEqual(line, "\n") || StrEqual(line, "\r\n") || strncmp(line, "//", 2) == 0) {
			continue;
		}
		
		AddCommandListener(OnCheatCommand, line);
	}
	
	CloseHandle(file);
}

bool:ReadAllowedCommands() {
	ClearArray(adt_allowedCommands);
	ClearArray(adt_allowedImpulses);
	
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/cheat-control/allowed-commands.ini");
	
	new Handle:file = OpenFile(path, "r");
	
	if (file == INVALID_HANDLE) {
		return false;
	}
	
	decl String:line[1024];
	decl String:toks[2][32];
	
	while (!IsEndOfFile(file)) {
		if (!ReadFileLine(file, line, sizeof(line))) {
			return true;
		}
		
		ReplaceString(line, sizeof(line), "\r", "");
		ReplaceString(line, sizeof(line), "\n", "");
		
		new pos;
		if ((pos = StrContains(line, "//")) != -1) {
			line[pos] = '\0';
		}
		
		TrimString(line);
		
		if (StrEqual(line, "") || StrEqual(line, "\n") || StrEqual(line, "\r\n")) {
			continue;
		}

		ExplodeString(line, " ", toks, 2, sizeof(toks[]));

		if (StrEqual(toks[0], "impulse", false)) {
			new impulse = StringToInt(toks[1]);
			PushArrayCell(adt_allowedImpulses, impulse);
		}
		else {
			PushArrayString(adt_allowedCommands, line);
		}
	}
	
	CloseHandle(file);
	
	return true;
}

UpdateClientCheatValue() {

	new String:canCheat[2];

	for (new client=1; client<=MaxClients; ++client) {
		
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			IntToString(CanClientCheat(client), canCheat, sizeof(canCheat));
			SendConVarValue(client, sv_cheats, "1");
		}
	}
}

PrintToChatAdmins(String:format[], any:...) {
	new String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	for (new client=1; client<=MaxClients; ++client) {
		
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			new AdminId:aid = GetUserAdmin(client);
			
			if (aid != INVALID_ADMIN_ID && GetAdminFlag(aid, Admin_Generic)) {
				PrintToChat(client, buffer);
				
			}
		}
		
	}
	
	LogMessage(buffer);
}
