#pragma semicolon 1
#pragma newdecls required

static void WeaponMulti(StringMap map, const char[] key, float add)
{
	float value = 0.0;
	map.GetValue(key, value);
	map.SetValue(key, value + add);
}

public void SkillWeapon_DamageUp_All(int entity, StringMap map, int amount, int client)
{
	// +0.1% every X
	WeaponMulti(map, "2", amount * 0.001);
	WeaponMulti(map, "410", amount * 0.001);
}

public void SkillWeapon_DamageUp_AllHigh(int entity, StringMap map, int amount, int client)
{
	// +0.5% every X
	WeaponMulti(map, "2", amount * 0.005);
	WeaponMulti(map, "410", amount * 0.005);
}

public void SkillWeapon_AttackSpeed_All(int entity, StringMap map, int amount, int client)
{
	// +0.1% every X
	WeaponMulti(map, "6", amount * 0.001);
	WeaponMulti(map, "97", amount * 0.001);
}
public void SkillWeapon_AttackSpeed_All(int entity, StringMap map, int amount, int client)
{
	// +0.1% every X
	WeaponMulti(map, "6", amount * 0.001);
	WeaponMulti(map, "97", amount * 0.001);
}