#pragma semicolon 1
#pragma newdecls required

static KeyValues SaveKv;
static char CharacterName[MAXTF2PLAYERS][64];

void Saves_PluginStart()
{
	RegConsoleCmd("rpg_character", Saves_Command, "View your characters");
}

void Saves_ConfigSetup()
{
	delete SaveKv;

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "savedata");
	SaveKv = new KeyValues("SaveData");
	SaveKv.ImportFromFile(buffer);

	FormatTime(buffer, sizeof(buffer), "savedata-backup%F");
	RPG_BuildPath(buffer, sizeof(buffer), buffer);
	SaveKv.ExportToFile(buffer);
}

void Saves_SaveClient(int client)
{
	static char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "savedata");

	SaveKv.Rewind();
	SaveKv.ExportToFile(buffer);

	TextStore_ClientSave(client);
}

KeyValues Saves_KV(const char[] section)
{
	SaveKv.Rewind();
	SaveKv.JumpToKey(section, true);
	return SaveKv;
}

void Saves_ClientCharName(int client, char[] buffer, int length)
{
	strcopy(buffer, length, CharacterName[client]);
}