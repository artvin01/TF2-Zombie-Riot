#pragma semicolon 1
#pragma newdecls required

#tryinclude <SteamWorks>

#define STEAMWORKS_LIBRARY	"SteamWorks"

static bool SteamWorksCompiled;

void SteamWorks_PluginStart()
{
	#if defined _SteamWorks_Included
	SteamWorksCompiled = LibraryExists(STEAMWORKS_LIBRARY);
	#endif
}

public void OnLibraryAdded(const char[] name)
{
	#if defined _SteamWorks_Included
	if(!SteamWorksCompiled && StrEqual(name, STEAMWORKS_LIBRARY))
	{
		SteamWorksCompiled = true;
		SteamWorks_UpdateGameTitle();
	}
	#endif
}

public void OnLibraryRemoved(const char[] name)
{
	#if defined _SteamWorks_Included
	if(SteamWorksCompiled && StrEqual(name, STEAMWORKS_LIBRARY))
		SteamWorksCompiled = false;
	#endif
}

void SteamWorks_UpdateGameTitle()
{
	#if defined _SteamWorks_Included
	if(SteamWorksCompiled)
	{
		char buffer[64];
		char BufferAdd[6];
		ZRModifs_CharBuffToAdd(BufferAdd);

		if(!BufferAdd[0])
		{
			FormatEx(BufferAdd, sizeof(BufferAdd), "-");
		}
		if(Rogue_Mode())
		{
			FormatEx(buffer, sizeof(buffer), "ZR Rogue (Floor %d-%d) [%c]", Rogue_GetFloor() + 1, Rogue_GetCount() + 1, BufferAdd);
		}
		else if(Waves_InFreeplay() && WhatDifficultySetting_Internal[0])
		{
			FormatEx(buffer, sizeof(buffer), "ZR %s (Freeplay) [%c]", WhatDifficultySetting_Internal, BufferAdd);
		}
		else if(Waves_Started() && WhatDifficultySetting_Internal[0])
		{
			FormatEx(buffer, sizeof(buffer), "ZR %s (Wave %d/%d) [%c]", WhatDifficultySetting_Internal, Waves_GetRound() + 1, Waves_GetMaxRound(), BufferAdd);
		}
		else
		{
			strcopy(buffer, sizeof(buffer), "ZR (Waiting For Players)");
		}

		SteamWorks_SetGameDescription(buffer);
	}
	#endif
}