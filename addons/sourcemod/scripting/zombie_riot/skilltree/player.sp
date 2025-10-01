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
	PlayerAdd(map, "26", float(amount));
}
public void SkillPlayer_HealthUpInfinite(int client, StringMap map, int amount)
{
	// +0.1 every X
	PlayerAdd(map, "26", float(amount) * 0.1);
}

public void SkillPlayer_ResistUp(int client, StringMap map, int amount)
{
	// +0.05% every X
	PlayerMulti(map, "412", float(amount) * -0.0005);
}

public void SkillPlayer_FusionResUp(int client, StringMap map, int amount)
{
	// +0.5% every X
	PlayerMulti(map, "412", float(amount) * -0.005);
}
public void SkillPlayer_SensalResUp(int client, StringMap map, int amount)
{
	// +1.0% every X
	PlayerMulti(map, "412", float(amount) * -0.01);
}
public void SkillPlayer_AlaxiosResUp(int client, StringMap map, int amount)
{
	// +1.0% every X
	PlayerMulti(map, "412", float(amount) * -0.01);
	PlayerAdd(map, "26", float(amount) * 15.0);
}
public void SkillPlayer_BobHandUp(int client, StringMap map, int amount)
{
	// +1.0% every X
	PlayerAdd(map, "26", float(amount) * 25.0);
	PlayerAdd(map, "4030", float(amount) * 0.0005);
	PlayerMulti(map, "286", float(amount) * 0.01);
	PlayerAdd(map, "4033", float(amount) * 5.0);
}

public void SkillPlayer_LuckUp(int client, StringMap map, int amount)
{
	// +0.005% every X
	PlayerAdd(map, "4030", float(amount) * 0.00005);
}
public void SkillPlayer_HealthUpHigh(int client, StringMap map, int amount)
{
	// +5 every X
	PlayerAdd(map, "26", float(amount) * 5.0);
}

public void SkillPlayer_ExtraBuildingHP(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "286", float(amount) * 0.001);
}

public void SkillPlayer_RegenUpCalmaticus(int client, StringMap map, int amount)
{
	// 0.25 hp regen every skill up
	PlayerAdd(map, "57", float(amount) * 0.25);
}

public void SkillPlayer_ExtraDamageBuilding(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "287", float(amount) * 0.001);
}

public void SkillPlayer_ReceiveExtraHealing(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "526", float(amount) * 0.001);
}

public void SkillPlayer_ReceiveExtraHealingHigh(int client, StringMap map, int amount)
{
	// 0.5 every skill up
	PlayerMulti(map, "526", float(amount) * 0.005);
}

public void SkillPlayer_ReviveTimeReduce(int client, StringMap map, int amount)
{
	// 1 every skill up
	PlayerAdd(map, "4033", float(amount));
}
public void SkillPlayer_ReviveTimeReduceHigh(int client, StringMap map, int amount)
{
	// 5 every skill up
	PlayerAdd(map, "4033", float(amount) * 5.0);
}

public void SkillPlayer_ExtendExtraCash(int client, StringMap map, int amount)
{
	// 100 every skill up
	PlayerAdd(map, "4034", float(amount) * 100.0);
}
public void SkillPlayer_ExtendExtraCashHigh(int client, StringMap map, int amount)
{
	// 500 every skill up
	PlayerAdd(map, "4034", float(amount) * 500.0);
}
