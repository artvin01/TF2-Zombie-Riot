#pragma semicolon 1
#pragma newdecls required

enum struct CvarInfo
{
	ConVar cvar;
	char value[16];
	char defaul[16];
	bool enforce;
}

static ArrayList CvarList;
static bool CvarEnabled;

void ConVar_PluginStart()
{
	if(CvarList != INVALID_HANDLE)
		delete CvarList;

	CvarList = new ArrayList(sizeof(CvarInfo));

	ConVar_Add("nb_allow_climbing", "0.0"); // default:1
	ConVar_Add("nb_allow_gap_jumping", "0.0"); // default:1
	ConVar_Add("nb_update_framelimit", "30"); // default:15
	ConVar_Add("nb_update_frequency", "0.1"); // default:0
	ConVar_Add("nb_last_area_update_tolerance", "2.0"); // default:4
	
	CvarDisableThink = CreateConVar("zr_disablethinking", "0", "Disable NPC thinking", FCVAR_DONTRECORD);
#if defined ZR
	zr_downloadconfig = CreateConVar("zr_downloadconfig", "", "Downloads override config zr/ .cfg already included");
#endif
	zr_showdamagehud = CreateConVar("zr_showdamagehud", "0", "If to show the damage dealt HUD when hitting NPCs");
}

void ConVar_Add(const char[] name, const char[] value, bool enforce=true)
{
	CvarInfo info;
	info.cvar = FindConVar(name);
	info.cvar.Flags &= ~FCVAR_CHEAT;
	strcopy(info.value, sizeof(info.value), value);
	info.enforce = enforce;

	if(CvarEnabled)
	{
		info.cvar.GetString(info.defaul, sizeof(info.defaul));
		info.cvar.SetString(info.value);
		info.cvar.AddChangeHook(ConVar_OnChanged);
	}

	CvarList.PushArray(info);
}

stock void ConVar_Remove(const char[] name)
{
	ConVar cvar = FindConVar(name);
	int index = CvarList.FindValue(cvar, CvarInfo::cvar);
	if(index != -1)
	{
		CvarInfo info;
		CvarList.GetArray(index, info);
		CvarList.Erase(index);

		if(CvarEnabled)
		{
			info.cvar.RemoveChangeHook(ConVar_OnChanged);
			info.cvar.SetString(info.defaul);
		}
	}
}

void ConVar_Enable()
{
	if(!CvarEnabled)
	{
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarInfo info;
			CvarList.GetArray(i, info);
			info.cvar.GetString(info.defaul, sizeof(info.defaul));
			CvarList.SetArray(i, info);

			info.cvar.SetString(info.value);
			info.cvar.AddChangeHook(ConVar_OnChanged);
		}

		CvarEnabled = true;
	}
}

void ConVar_Disable()
{
	if(CvarEnabled)
	{
		int length = CvarList.Length;
		for(int i; i<length; i++)
		{
			CvarInfo info;
			CvarList.GetArray(i, info);

			info.cvar.RemoveChangeHook(ConVar_OnChanged);
			info.cvar.SetString(info.defaul);
		}

		CvarEnabled = false;
	}
}

public void ConVar_OnChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	int index = CvarList.FindValue(cvar, CvarInfo::cvar);
	if(index != -1)
	{
		CvarInfo info;
		CvarList.GetArray(index, info);

		if(!StrEqual(newValue, info.value))
		{
			if(info.enforce)
			{
				strcopy(info.defaul, sizeof(info.defaul), newValue);
				CvarList.SetArray(index, info);
				info.cvar.SetString(info.value);
			}
			else
			{
				info.cvar.RemoveChangeHook(ConVar_OnChanged);
				CvarList.Erase(index);
			}
		}
	}
}