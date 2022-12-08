#pragma semicolon 1
#pragma newdecls required

static Handle HudLevel;

void Levels_PluginStart()
{
	HudLevel = CreateHudSynchronizer();
	CreateTimer(1.0, Levels_Timer, _, TIMER_REPEAT);
}

public Action Levels_Timer(Handle timer)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			ShowLevelHud(client);
	}
	return Plugin_Continue;
}

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
	
	int nextLevel = XpToLevel(XP[client]);
	int levelCap = GetLevelCap(Tier[client]);
	if(nextLevel > levelCap)
		nextLevel = levelCap;
	
	if(nextLevel > Level[client])
	{
		if(!silent)
		{
			static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
			ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);
			
			SPrintToChat(client, "%t", "Level Up", nextLevel - GetLevelCap(Tier[client] - 1));
		}

		Level[client] = nextLevel;
		
		if(!silent)
			Store_ApplyAttribs(client);
	}

	ShowLevelHud(client);
}

void ShowLevelHud(int client)
{
	static char buffer[128];
	if(Tier[client])
	{
		Format(buffer, sizeof(buffer), "Elite %d Level %d", Tier[client], Level[client]);
	}
	else
	{
		Format(buffer, sizeof(buffer), "Level %d", Level[client]);
	}

	if(Level[client] == GetLevelCap(Tier[client]))
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