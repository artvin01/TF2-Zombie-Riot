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

void SteamWorks_LibraryAdded(const char[] name)
{
	#if defined _SteamWorks_Included
	if(!SteamWorksCompiled && StrEqual(name, STEAMWORKS_LIBRARY))
	{
		SteamWorksCompiled = true;
		SteamWorks_UpdateGameTitle();
	}
	#endif
}

void SteamWorks_LibraryRemoved(const char[] name)
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
		
		if(Dungeon_Mode())
		{
			strcopy(buffer, sizeof(buffer), "ZR: Dungeon");
		}
		else if(Construction_Mode())
		{
			strcopy(buffer, sizeof(buffer), "ZR: Construction");
		}
		else if(Rogue_Mode())
		{
		//	FormatEx(buffer, sizeof(buffer), "ZR: Rogue (Floor %d-%d)", Rogue_GetFloor() + 1, Rogue_GetCount() + 1);
			strcopy(buffer, sizeof(buffer), "ZR: Rogue");
		}
		/*
		else if(Waves_InFreeplay())
		{
			FormatEx(buffer, sizeof(buffer), "ZR: Freeplay");
		}
		*/
		else if(Waves_Started() && WhatDifficultySetting_Internal[0])
		{
			FormatEx(buffer, sizeof(buffer), "ZR: %s", WhatDifficultySetting_Internal);
		//	FormatEx(buffer, sizeof(buffer), "ZR: %s (Wave %d/%d)", WhatDifficultySetting_Internal, Waves_GetRoundScale() + 1, Waves_GetMaxRound());
		}
		else
		{
			strcopy(buffer, sizeof(buffer), "Zombie Riot");
		}

		SteamWorks_SetGameDescription(buffer);
	}
	#endif
}
/*
void SteamWorks_UpdateTourToLevel()
{
	#if defined _SteamWorks_Included
	if(SteamWorksCompiled)
	{
		SetLobbyMemberData()
	}
	#endif
}
*/