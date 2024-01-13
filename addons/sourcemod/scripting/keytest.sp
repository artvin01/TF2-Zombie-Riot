#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <tf2_stocks>

public void OnPluginStart()
{
	AddCommandListener(OnCommand);
}

public void OnPlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	PrintCenterText(client, "Buttons: %d", buttons);

	if(impulse)
		PrintToChat(client, "Impulse: %d", impulse);
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	char buffer[32];
	kv.GetSectionName(buffer, sizeof(buffer));
	PrintToChat(client, "KeyValues: \"%s\"", buffer);
	return Plugin_Continue;
}

Action OnCommand(int client, const char[] command, int argc)
{
	if(client)
	{
		char buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		PrintToChat(client, "Command: \"%s\" \"%s\"", command, buffer);
	}
	return Plugin_Continue;
}