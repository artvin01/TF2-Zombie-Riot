#pragma semicolon 1
#pragma newdecls required

int Stats_BaseCarry(int client, int &base = 0, int &bonus = 0)
{
	int strength = 9 + Level[client] / 2;
	if(strength > 20)
		strength = 20;
	
	base = strength + (Tier[client] * 10);
	bonus = BackpackBonus[client];

	return base + bonus;
}