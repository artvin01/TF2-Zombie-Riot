#pragma semicolon 1
#pragma newdecls required

static void PlayerAdd(StringMap map, const char[] key, float add)
{
	float value = 0.0;
	map.GetValue(key, value);
	map.SetValue(key, value + add);
}

static void PlayerMulti(StringMap map, const char[] key, float multi)
{
	float value = 1.0;
	map.GetValue(key, value);
	map.SetValue(key, value * (1.0 + multi));
}

public void SkillPlayer_HealthUp(int client, StringMap map, int amount)
{
	// +1 every X
	PlayerAdd(map, "26", amount);
}

public void SkillPlayer_ResistUp(int client, StringMap map, int amount)
{
	// +0.01% every X
	PlayerMulti(map, "412", amount * -0.0001);
}

public void SkillPlayer_LuckUp(int client, StringMap map, int amount)
{
	// +0.005% every X
	PlayerAdd(map, "4030", amount * 0.00005);
}
public void SkillPlayer_HealthUpHigh(int client, StringMap map, int amount)
{
	// +5 every X
	PlayerAdd(map, "26", amount * 5);
}

public void SkillPlayer_CashUp(int client, StringMap map, int amount)
{
	// +2 every X
	int PLEASE_ADD_THIS_ATTRIB_FOR_EXTRA_CASH;
	PlayerAdd(map, "4031", amount * 2);
}

public void SkillPlayer_CashUpHigh(int client, StringMap map, int amount)
{
	// +20 every X
	PlayerAdd(map, "4031", amount * 20);
}
