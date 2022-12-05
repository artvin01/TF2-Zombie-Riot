#pragma semicolon 1
#pragma newdecls required

static Handle HudLevel;

void Levels_PluginStart()
{
	HudLevel = CreateHudSynchronizer();
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

void CapLevel(int &lv, int tier)
{
	int cap = GetLevelCap(tier);
	if(lv > cap)
		lv = cap;
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
		Format(buffer, length, "%t", "Level", level);
	}
	else if(short)
	{
		Format(buffer, length, "%t", "Short Tier Level", tier, level);
	}
	else
	{
		Format(buffer, length, "%t", "Tier Level", tier, level);
	}
}

void GiveXP(int client, int xp)
{
	XP[client] += RoundToNearest(float(xp) * CvarXpMultiplier.FloatValue);
	int nextLevel = XpToLevel(XP[client]);
	int levelCap = GetLevelCap(Tier[client]);
	if(nextLevel > levelCap)
		nextLevel = levelCap;
	
	if(nextLevel > Level[client])
	{
		static const char Names[][] = { "one", "two", "three", "four", "five", "six" };
		ClientCommand(client, "playgamesound ui/mm_level_%s_achieved.wav", Names[GetRandomInt(0, sizeof(Names)-1)]);
		
		SPrintToChat(client, "%t", "Level Up", nextLevel - GetLevelCap(Tier[client] - 1));
		Level[client] = nextLevel;
		
		Store_ApplyAttribs(client);
	}
}

void ShowLevelHud(int client)
{
	int xpLevel = LevelToXp(Level[client]);
	int xpNext = LevelToXp(Level[client]+1);
	
	int extra = XP[client]-xpLevel;
	int nextAt = xpNext-xpLevel;
	
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
	
	SetHudTextParams(-1.0, 0.96, 1.8, 200, 69, 0, 200);
	ShowSyncHudText(client, HudLevel, "Level %d\n%d %s %d", Level[client], extra, buffer, xpNext-XP[client]);
}