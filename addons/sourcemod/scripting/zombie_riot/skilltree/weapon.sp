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
	// +0.05% every X
	WeaponMulti(map, "2", amount * 0.0005);
	WeaponMulti(map, "410", amount * 0.0005);
}

public void SkillWeapon_DamageUp_AllHigh(int entity, StringMap map, int amount, int client)
{
	// +0.2% every X
	WeaponMulti(map, "2", amount * 0.002);
	WeaponMulti(map, "410", amount * 0.002);
}
public void SkillWeapon_DamageUp_Kahmlstein(int entity, StringMap map, int amount, int client)
{
	// +1% every X
	WeaponMulti(map, "2", amount * 0.01);
	WeaponMulti(map, "410", amount * 0.01);
}
public void SkillWeapon_TwirlHairpin(int entity, StringMap map, int amount, int client)
{
	// +1% every X
	WeaponMulti(map, "4019", amount * 0.005);
	WeaponMulti(map, "4020", amount * 0.005);
}

public void SkillWeapon_TwirlHairpin2(int entity, StringMap map, int amount, int client)
{
	// +1% every X
	WeaponMulti(map, "4019", amount * 0.005);
	WeaponMulti(map, "4020", amount * 0.005);
}

public void SkillWeapon_AttackReloadSpeed_All(int entity, StringMap map, int amount, int client)
{
	// +0.02% every X
	WeaponMulti(map, "6", amount * 0.0002);
	WeaponMulti(map, "97", amount * 0.0002);
}
public void SkillWeapon_AttackReloadSpeed_AllHigh(int entity, StringMap map, int amount, int client)
{
	// +0.2% every X
	WeaponMulti(map, "6", amount * 0.002);
	WeaponMulti(map, "97", amount * 0.002);
}
public void SkillWeapon_WaldchBonus(int entity, StringMap map, int amount, int client)
{
	// +1.5% every X
	WeaponMulti(map, "97", amount * 0.015);
}
public void SkillWeapon_IberiaBonus(int entity, StringMap map, int amount, int client)
{
	// +1.5% every X
	WeaponMulti(map, "6", amount * 0.01);
}

public void SkillWeapon_BlitzUp(int entity, StringMap map, int amount, int client)
{
	// +0.5% every X
	WeaponMulti(map, "6", amount * 0.005);
	WeaponMulti(map, "97", amount * 0.005);
}
public void SkillWeapon_Iberia_Nemal(int entity, StringMap map, int amount, int client)
{
	// +1% every X
	WeaponMulti(map, "6", amount * 0.01);
	WeaponMulti(map, "97", amount * 0.01);
}

public void SkillWeapon_AttackReloadSpeed_All(int entity, StringMap map, int amount, int client)
{
	// +0.025% every X
	WeaponMulti(map, "97", amount * 0.00025);
}
public void SkillWeapon_AttackSpeed_All(int entity, StringMap map, int amount, int client)
{
	// +0.02% every X
	WeaponMulti(map, "6", amount * 0.0002);
}

public void SkillWeapon_FusionUp_All(int entity, StringMap map, int amount, int client)
{
	// +0.25% every X
	WeaponMulti(map, "2", amount * 0.0025);
	WeaponMulti(map, "410", amount * 0.0025);
}
public void SkillWeapon_SensalUp_All(int entity, StringMap map, int amount, int client)
{
	// +0.35% every X
	WeaponMulti(map, "2", amount * 0.0035);
	WeaponMulti(map, "410", amount * 0.0035);
}
public void SkillWeapon_RepairSpeed(int entity, StringMap map, int amount, int client)
{
	// +0.1% every X
	WeaponMulti(map, "95", amount * 0.001);
}