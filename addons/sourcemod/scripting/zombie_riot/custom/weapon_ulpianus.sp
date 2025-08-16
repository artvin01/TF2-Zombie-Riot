#pragma semicolon 1
#pragma newdecls required

static bool Elited;

void Ulpianus_MapStart()
{
	Elited = false;
}

stock void Ulpianus_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ULPIANUS)
	{
		if(!Elited)
		{
			float value = Attributes_Get(weapon, 868, 0.0);
			if(value)
				Elited = true;
		}
	}
	else if(Elited && Store_IsWeaponFaction(client, weapon, Faction_Seaborn))
	{
		ApplyStatusEffect(weapon, weapon, "Ulpianus' Seriousness", 9999999.0);
		Attributes_SetMulti(weapon, 6, 0.8);
		Attributes_Set(weapon, 140, 540.0);
	}
}

void Ulpianus_OnTakeDamageSelf(int victim)
{
	bool low = GetClientHealth(victim) < (ReturnEntityMaxHealth(victim) / 2);

	if(Elited)
	{
		HealEntityGlobal(victim, victim, low ? 160.0 : 100.0, _, 0.0, HEAL_SELFHEAL);
	}
	else
	{
		HealEntityGlobal(victim, victim, low ? 120.0 : 80.0, _, 0.0, HEAL_SELFHEAL);
	}
}

int Ulpianus_EnemyHitCount()
{
	return Elited ? 3 : 2;
}