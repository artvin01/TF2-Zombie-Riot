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
	PlayerAdd(map, "26", amount * 15);
}
public void SkillPlayer_BobHandUp(int client, StringMap map, int amount)
{
	// +1.0% every X
	PlayerAdd(map, "26", amount * 25);
	PlayerAdd(map, "4030", float(amount) * 0.0005);
	PlayerMulti(map, "286", float(amount) * 0.01);
	PlayerAdd(map, "4033", amount * 5);
}

public void SkillPlayer_LuckUp(int client, StringMap map, int amount)
{
	// +0.005% every X
	PlayerAdd(map, "4030", float(amount) * 0.00005);
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
public void SkillPlayer_CashUpInfinite(int client, StringMap map, int amount)
{
	// +0.2 every X
	int PLEASE_ADD_THIS_ATTRIB_FOR_EXTRA_CASH;
	PlayerAdd(map, "4031", float(amount) * 0.2);
}

public void SkillPlayer_CashUpHigh(int client, StringMap map, int amount)
{
	// +20 every X
	int PLEASE_ADD_THIS_ATTRIB_FOR_EXTRA_CASH;
	PlayerAdd(map, "4031", amount * 20);
}
public void SkillPlayer_CashUpHighBarney(int client, StringMap map, int amount)
{
	// +30 every X
	int PLEASE_ADD_THIS_ATTRIB_FOR_EXTRA_CASH;
	PlayerAdd(map, "4031", amount * 30);
}

public void SkillPlayer_ExtraCoinLow(int client, StringMap map, int amount)
{
	// +1 every X
	int MAKE_ME_WORK_PLEASE;
	PlayerAdd(map, "4032", amount);
}
public void SkillPlayer_ExtraBuildingHP(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "286", float(amount) * 0.001);
}

public void SkillPlayer_RegenUpCalmaticus(int client, StringMap map, int amount)
{
	// 0.25 hp regen every skill up
	PlayerMulti(map, "57", float(amount) * 0.25);
}

public void SkillPlayer_ExtraDamageBuilding(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "287", float(amount) * 0.001);
}

public void SkillPlayer_RecieveExtraHealing(int client, StringMap map, int amount)
{
	// 0.1 every skill up
	PlayerMulti(map, "526", float(amount) * 0.001);
}

public void SkillPlayer_RecieveExtraHealingHigh(int client, StringMap map, int amount)
{
	// 0.5 every skill up
	PlayerMulti(map, "526", float(amount) * 0.005);
}

public void SkillPlayer_ReviveTimeReduce(int client, StringMap map, int amount)
{
	// 1 every skill up
	int ADD_ME_PLEASE1;
	PlayerAdd(map, "4033", amount);
}
public void SkillPlayer_ReviveTimeReduceHigh(int client, StringMap map, int amount)
{
	// 5 every skill up
	PlayerAdd(map, "4033", amount * 5);
}

public void SkillPlayer_ExtendExtraCash(int client, StringMap map, int amount)
{
	// 100 every skill up
	int ADD_ME_PLEASE2;
	PlayerAdd(map, "4034", amount * 100);
}
public void SkillPlayer_ExtendExtraCashHigh(int client, StringMap map, int amount)
{
	// 500 every skill up
	PlayerAdd(map, "4034", amount * 500);
}
