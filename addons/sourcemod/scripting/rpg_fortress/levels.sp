#pragma semicolon 1
#pragma newdecls required

#define CURRENT_MAX_LEVEL	55 // E2 L25

//static Handle HudLevel;
static Cookie SpawnCookie;

void Levels_PluginStart()
{
	SpawnCookie = new Cookie("rpg_spawn_point", "Spawn Point Cookie", CookieAccess_Protected);

//	HudLevel = CreateHudSynchronizer();
//	CreateTimer(1.0, Levels_Timer, _, TIMER_REPEAT);
	RegConsoleCmd("rpg_xp_help", Levels_Command, _, FCVAR_HIDDEN);
}

void Levels_ClientEnter(int client, const char[] name)
{
	if(!StrContains(name, "rpg_respawn_", false))
	{
		int level = StringToInt(name[12]);
		if(Levels_GetSpawnPoint(client) != level)
		{
			if(Levels_SetSpawnPoint(client, level))
			{
				SPrintToChat(client, "You have changed your respawn point.");
			}
			else
			{
				SPrintToChat(client, "You can not set your respawn point here.");
			}
		}
	}
}

int Levels_GetSpawnPoint(int client)
{
	char buffer[6];
	SpawnCookie.Get(client, buffer, sizeof(buffer));
	return StringToInt(buffer);
}

bool Levels_SetSpawnPoint(int client, int point)
{
	if(Tier[client] < point)
		return false;
	
	char buffer[6];
	IntToString(point, buffer, sizeof(buffer));
	SpawnCookie.Set(client, buffer);
	return true;
}

public Action Levels_Command(int client, int args)
{
	if(args)
	{
		int level = GetCmdArgInt(1);
		int xp = LevelToXp(level);
		
		char buffer1[32], buffer2[32];
		GetDisplayString(level, buffer1, sizeof(buffer1));
		GetDisplayString(level, buffer2, sizeof(buffer2), true);
		ReplyToCommand(client, "Display Name: %s | Short: %s", buffer1, buffer2);
		ReplyToCommand(client, "From Level 0 to Level %d: %d XP", level, xp);
		ReplyToCommand(client, "From Level %d to Level %d: %d XP", level - 1, level, xp - LevelToXp(level - 1));
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: rpg_xp_help <level>");
	}
	return Plugin_Handled;
}
/*
public Action Levels_Timer(Handle timer)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			ShowLevelHud(client);
	}
	return Plugin_Continue;
}
*/
int XpToLevel(int xp)
{
	return RoundToFloor(Pow(xp/100.0, 0.5));	// sqrt(x/100)
}

int LevelToXp(int lv)
{
	// Adds 200 more each lv (100, 300, 700, 1300...)
	return lv * lv * 100;	// 100x^2
}

int GetLevelCap(int tier)
{
	// Adds 10 more each tier (10, 30, 60, 100...)
	return (tier + 1) * (tier + 2) * 5;	// 5(x+1)(x+2)
}

int GetDisplayLevel(int level, int &tier=0)
{
	tier = 0;
	int thisCap;
	int currCap;
	while(level > (thisCap = GetLevelCap(tier)))
	{
		tier++;
		currCap = thisCap;
	}
	
	return level - currCap;
}
/*
void GetClientString(int client, char[] buffer, int length, bool short = false)
{
	if(!Tier[client])
	{
		Format(buffer, length, "Level %d", Level[client]);
	}
	else if(short)
	{
		Format(buffer, length, "E%d L%d", Tier[client], Level[client]);
	}
	else
	{
		Format(buffer, length, "Elite %d Level %d", Tier[client], Level[client]);
	}
}
*/
void GetDisplayString(int base, char[] buffer, int length, bool short = false)
{
	int tier;
	int level = GetDisplayLevel(base, tier);
	
	if(!tier)
	{
		Format(buffer, length, "Level %d", level);
	}
	else if(short)
	{
		Format(buffer, length, "E%d L%d", tier, level);
	}
	else
	{
		Format(buffer, length, "Elite %d Level %d", tier, level);
	}
}

void GiveXP(int client, int xp, bool silent = false)
{
	TextStore_AddXP(client, RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue));

	int levelCap = GetLevelCap(Tier[client]);
	if(levelCap < Level[client])
		levelCap = CURRENT_MAX_LEVEL;
	
	int nextLevel = XpToLevel(XP[client]);
	if(nextLevel > levelCap)
		nextLevel = levelCap;
	
	if(nextLevel > Level[client])
	{
		int oldLevel = Level[client];
		Level[client] = nextLevel;

		if(!silent)
		{
			static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
			ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);
			
			Stats_ShowLevelUp(client, oldLevel, Tier[client]);
		}
		
		if(!silent)
			Store_ApplyAttribs(client);

		UpdateLevelAbovePlayerText(client);
	}
/*
	if(!silent)
		ShowLevelHud(client);
*/
}

void GiveTier(int client)
{
	static const char Names[][] = { "one", "two", "three", "four", "five" };
	int rand = Tier[client];
	if(rand >= sizeof(Names))
		rand = GetRandomInt(0, sizeof(Names)-1);
	
	ClientCommand(client, "playgamesound ui/mm_rank_%s_achieved.wav", Names[rand]);
	
	int oldLevel = Level[client];
	Tier[client]++;

	GiveXP(client, 0, true);

	Stats_ShowLevelUp(client, oldLevel, Tier[client] - 1);
	Store_ApplyAttribs(client);
//	ShowLevelHud(client);
}
/*
void ShowLevelHud(int client)
{
	static char buffer[128];
	if(Tier[client])
	{
		Format(buffer, sizeof(buffer), "Elite %d Level %d", Tier[client], Level[client] - GetLevelCap(Tier[client] - 1));
	}
	else
	{
		Format(buffer, sizeof(buffer), "Level %d", Level[client]);
	}

	if(Level[client] >= CURRENT_MAX_LEVEL || Level[client] == GetLevelCap(Tier[client]))
	{
		Format(buffer, sizeof(buffer), "%s\n%d", buffer, XP[client] - LevelToXp(Level[client]));

		for(int i=1; i<21; i++)
		{
			Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
		}

		Format(buffer, sizeof(buffer), "%s E%d", buffer, Tier[client] + 1);
	}
	else
	{
		int xpLevel = LevelToXp(Level[client]);
		int xpNext = LevelToXp(Level[client]+1);
		
		int extra = XP[client]-xpLevel;
		int nextAt = xpNext-xpLevel;
		
		Format(buffer, sizeof(buffer), "%s\n%d ", buffer, extra);

		for(int i=1; i<21; i++)
		{
			if(extra > nextAt*(i*0.05))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_FULL);
			}
			else if(extra > nextAt*(i*0.05 - 1.0/60.0))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTFULL);
			}
			else if(extra > nextAt*(i*0.05 - 1.0/30.0))
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_PARTEMPTY);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s%s", buffer, CHAR_EMPTY);
			}
		}

		Format(buffer, sizeof(buffer), "%s %d", buffer, xpNext - XP[client]);
	}
	
	SetHudTextParams(-1.0, 0.96, 1.8, 200, 69, 0, 200);
	ShowSyncHudText(client, HudLevel, buffer);
}
*/