#pragma semicolon 1
#pragma newdecls required

static int BackpackBonus[MAXTF2PLAYERS];

void Stats_ClearCustomStats(int client)
{
	BackpackBonus[client] = 0;
}

void Stats_GetCustomStats(int client, int attrib, float value)
{
	switch(attrib)
	{
		case -1:
		{
			BackpackBonus[client] = RoundFloat(value);
		}
	}
}

int Stats_BaseCarry(int client, int &base = 0, int &bonus = 0)
{
	int strength = 9 + Level[client] / 2;
	if(strength > 20)
		strength = 20;
	
	base = strength + (Tier[client] * 10);
	bonus = BackpackBonus[client];

	return base + bonus;
}