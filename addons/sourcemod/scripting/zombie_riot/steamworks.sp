#pragma semicolon 1
#pragma newdecls required

#tryinclude <SteamWorks>

#define STEAMWORKS_LIBRARY	"SteamWorks"

#if defined _SteamWorks_Included
static bool Loaded;
#endif

void SteamWorks_PluginStart()
{
	#if defined _SteamWorks_Included
	Loaded = LibraryExists(STEAMWORKS_LIBRARY);
	#endif
}

public void OnLibraryAdded(const char[] name)
{
	#if defined _SteamWorks_Included
	if(!Loaded && StrEqual(name, STEAMWORKS_LIBRARY))
	{
		Loaded = true;
		SteamWorks_UpdateGameTitle();
	}
	#endif
}

public void OnLibraryRemoved(const char[] name)
{
	#if defined _SteamWorks_Included
	if(Loaded && StrEqual(name, STEAMWORKS_LIBRARY))
		Loaded = false;
	#endif
}

void SteamWorks_UpdateGameTitle()
{
	#if defined _SteamWorks_Included
	if(Loaded)
	{
		char buffer[64];

		if(Rogue_Mode())
		{
			FormatEx(buffer, sizeof(buffer), "ZR Rogue (Floor %d-%d)", Rogue_GetFloor() + 1, Rogue_GetCount() + 1);
		}
		else if(Waves_InFreeplay() && WhatDifficultySetting_Internal[0])
		{
			FormatEx(buffer, sizeof(buffer), "%s (Freeplay)", WhatDifficultySetting_Internal);
		}
		else if(Waves_Started() && WhatDifficultySetting_Internal[0])
		{
			FormatEx(buffer, sizeof(buffer), "%s (Wave %d/%d)", WhatDifficultySetting_Internal, Waves_GetRound() + 1, Waves_GetMaxRound());
		}
		else
		{
			strcopy(buffer, sizeof(buffer), "Zombie Riot");
		}

		SteamWorks_SetGameDescription(buffer);
	}
	#endif
}