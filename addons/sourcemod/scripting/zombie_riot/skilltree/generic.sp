#pragma semicolon 1
#pragma newdecls required

public void SkillPlayer_SpeedUp(int client, StringMap map, int amount)
{
	// +0.01% every X
	Multi(map, "107", amount * 0.0001);
}

public void SkillWeapon_DamageUp(int entity, StringMap map, int amount, int client)
{
	// +0.01% every X
	Multi(map, "2", amount * 0.0001);
	Multi(map, "410", amount * 0.0001);
}

static void Multi(StringMap map, const char[] key, float add)
{
	float value = 0.0;
	map.GetValue(key, value);
	map.SetValue(key, value + add);
}