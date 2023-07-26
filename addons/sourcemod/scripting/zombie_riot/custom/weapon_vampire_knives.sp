#pragma semicolon 1
#pragma newdecls required

public void Vampire_Knives_Precache()
{
	
}

//Arrays are used for stats for each pap so I don't have to type ten million different variables. Example:
//static float My_Attribute[3] = { Value_For_Pap_0, Value_For_Pap_1, Value_For_Pap_2 };

//Both pap paps inflict X stacks of Bloodlust on hit. Each stack of Bloodlust deals some bleed damage per Y seconds, then heals the user for a portion of
//that damage, up to a cap.
static float Vamp_BleedDMG[3] = { 5.0, 8.0, 12.0 }; //The base damage dealt per Bloodlust tick.
static float Vamp_BleedRate[3] = { 0.33, 0.275, 0.25 }; //The rate at which Bloodlust deals damage.
static float Vamp_BleedHeal[3] = { 0.5, 0.5, 0.5 };	//Portion of Bloodlust damage to heal the user for.
static float Vamp_HealRadius[3] = { 300.0, 330.0, 360.0 };	//Max distance from the victim to heal the user in.
static int Vamp_MaxHeal[3] = { 4, 3, 2 };	//Max heal per tick.

//Default + Pap Route 1 - Vampire Knives: Fast melee swing speed, low melee damage, M2 throws X knives in a fan pattern which inflict Y* your melee damage.
static int Vamp_BleedStacksOnMelee_Normal[3] = { 6, 8, 10 }; //Number of Bloodlust stacks applied on a melee hit.
static int Vamp_BleedStacksOnThrow_Normal[3] = { 8, 10, 12 }; //Number of Bloodlust stacks applied on a throw hit.
static float Vamp_ThrowMultiplier_Normal[3] = { 2.0, 2.25, 2.5 }; //Amount to multiply damage dealt by thrown knives.
static float Vamp_ThrowCD_Normal[3] = { 6.0, 12.0, 20.0 }; //Knife throw cooldown.
static int Vamp_ThrowKnives_Normal[3] = { 1, 3, 6 }; //Number of knives thrown by M2.
static int Vamp_ThrowWaves_Normal[3] = { 1, 2, 3 }; //Number of times to throw knives with M2.
static float Vamp_ThrowRate_Normal[3] = { 0.0, 0.5, 0.33 }; //Time between throws if more than one wave in M2.
static float Vamp_ThrowSpread_Normal[3] = { 0.0, 60.0, 60.0 }; //Degree of fan throw when throwing knives.
static float Vamp_ThrowVelocity_Normal[3] = { 1200.0, 1600.0, 2400.0 };	//Velocity of thrown knives.

//Pap Route 2 - Bloody Butcher: Becomes a slow but deadly cleaver which inflicts heavy damage and gibs zombies on kill. Inflicts more Bloodlust on hit to balance out the
//slower swing speed. M2 has a longer cooldown and throws fewer knives, but knives become extremely powerful cleavers which keep flying if they kill the
//zombie they hit.
static int Vamp_BleedStacksOnMelee_Cleaver[3] = { 12, 16, 20 }; //Same as pap route 1, but for pap route 2.
static int Vamp_BleedStacksOnThrow_Cleaver[3] = { 16, 20, 24 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowMultiplier_Cleaver[3] = { 3.0, 4.0, 5.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowCD_Cleaver[3] = { 10.0, 20.0, 30.0 }; //Same as pap route 1, but for pap route 2.
static int Vamp_ThrowKnives_Cleaver[3] = { 1, 1, 2 }; //Same as pap route 1, but for pap route 2.
static int Vamp_ThrowWaves_Cleaver[3] = { 1, 1, 2 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowRate_Cleaver[3] = { 0.0, 0.0, 0.66 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowSpread_Cleaver[3] = { 0.0, 0.0, 30.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowVelocity_Cleaver[3] = { 1200.0, 1600.0, 2400.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowDMGMultPerKill[3] = { 0.0, 0.66, 0.8 }; //Amount to multiply the damage dealt by thrown cleavers every time they kill a zombie.

static float Vamp_EndTime[MAXENTITIES] = { 0.0, ... };

public void Vampire_Knives_Melee(int client, int weapon, bool crit, int slot)
{
	VampireKnives_ApplyEffect(weapon, 1, false, false);
}

public void Vampire_Knives_Melee_2(int client, int weapon, bool crit, int slot)
{
	VampireKnives_ApplyEffect(weapon, 2, false, false);
}

public void Vampire_Knives_Melee_3(int client, int weapon, bool crit, int slot)
{
	VampireKnives_ApplyEffect(weapon, 3, false, false);
}

public void Vampire_Knives_Melee_2_Cleaver(int client, int weapon, bool crit, int slot)
{
	VampireKnives_ApplyEffect(weapon, 2, true, false);
}

public void Vampire_Knives_Melee_3_Cleaver(int client, int weapon, bool crit, int slot)
{
	VampireKnives_ApplyEffect(weapon, 3, true, false);
}

public void VampireKnives_ApplyEffect(int weapon, int vampType, bool cleaver, bool isThrow)
{
	if (IsValidEntity(weapon))
	{
		i_VampType[weapon] = vampType;
		b_VampCleaver[weapon] = cleaver;
		b_VampThrow[weapon] = isThrow;
		Vamp_EndTime[weapon] = GetGameTime() + 0.66;
		CreateTimer(0.69, VampireKnives_RemoveEffect, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action VampireKnives_RemoveEffect(Handle remove, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		if (GetGameTime() > Vamp_EndTime[weapon])
		{
			i_VampType[weapon] = 0;
		}
	}
	
	return Plugin_Continue;
}

public void Vamp_ApplyBloodlust(int attacker, int victim, int VampType, bool IsCleaver, bool IsThrow)
{
	int NumStacks = IsCleaver ? Vamp_BleedStacksOnMelee_Cleaver[VampType - 1] : Vamp_BleedStacksOnMelee_Normal[VampType - 1];
	int MaxHeal = Vamp_MaxHeal[VampType - 1];
	float BleedDmg = Vamp_BleedDMG[VampType - 1];
	float BleedRate = Vamp_BleedRate[VampType - 1];
	float BleedHeal = Vamp_BleedHeal[VampType - 1];
	float Radius = Vamp_HealRadius[VampType - 1];
	
	if (IsThrow)
	{
		NumStacks = IsCleaver ? Vamp_BleedStacksOnThrow_Cleaver[VampType - 1] : Vamp_BleedStacksOnThrow_Normal[VampType - 1];
	}
	
	Handle pack;
	CreateDataTimer(BleedRate, Vamp_BloodlustTick, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(attacker));
	WritePackCell(pack, EntIndexToEntRef(victim));
	WritePackCell(pack, 0);
	WritePackCell(pack, NumStacks);
	WritePackCell(pack, MaxHeal);
	WritePackFloat(pack, BleedDmg);
	WritePackFloat(pack, BleedRate);
	WritePackFloat(pack, BleedHeal);
	WritePackFloat(pack, Radius);
}

public Action Vamp_BloodlustTick(Handle bloodlust, any pack)
{
	ResetPack(pack);
	int attacker = GetClientOfUserId(ReadPackCell(pack));
	int victim = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidClient(attacker) || !IsValidEntity(victim))
		return Plugin_Continue;
		
	if (b_NpcIsInvulnerable[victim]) //If the NPC is invulnerable, stop all bleeding.
	{
		return Plugin_Continue;
	}
	
	int NumHits = ReadPackCell(pack);
	int HitQuota = ReadPackCell(pack);
	int MaxHeal = ReadPackCell(pack);
	float DMG = ReadPackFloat(pack);
	float Rate = ReadPackFloat(pack);
	float HealMult = ReadPackFloat(pack);
	float Radius = ReadPackFloat(pack);
	
	float DMG_Final = DMG;
	
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if (IsValidEntity(weapon) && weapon == GetPlayerWeaponSlot(attacker, 2))
	{
		DMG_Final *= Attributes_Get(weapon, 1, 1.0);
		DMG_Final *= Attributes_Get(weapon, 2, 1.0);
		DMG_Final *= Attributes_Get(weapon, 476, 1.0);
	}
	
	float loc[3], vicloc[3], dist;
	GetClientAbsOrigin(attacker, loc);
	vicloc = WorldSpaceCenter(victim);
	dist = GetVectorDistance(loc, vicloc);
	
	for (int i = 0; i < 3; i++)
	{
		vicloc[i] += GetRandomFloat(-45.0, 45.0);
	}
	
	SDKHooks_TakeDamage(victim, attacker, attacker, DMG_Final, _, _, _, vicloc, true);
	
	if (dist <= Radius)
	{
		float mult = HealMult;
		
		if(f_TimeUntillNormalHeal[attacker] > GetGameTime())
		{
			mult *= 0.66;
		}
		
		int heal = RoundToFloor(DMG_Final * HealMult);
		if (heal > MaxHeal)
		{
			heal = MaxHeal;
		}
		if (heal < 1)
		{
			heal = 1;
		}
		
		int hp = GetEntProp(attacker, Prop_Data, "m_iHealth");
		int maxHP = SDKCall_GetMaxHealth(attacker);
		if (hp < maxHP)
		{	
			hp += heal;
			if (hp > maxHP)
			{
				hp = maxHP;
			}
			
			SetEntProp(attacker, Prop_Data, "m_iHealth", hp);
		}
	}
	
	NumHits++;
	if (NumHits >= HitQuota)
		return Plugin_Continue;
		
	Handle pack2;
	CreateDataTimer(Rate, Vamp_BloodlustTick, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(attacker));
	WritePackCell(pack2, EntIndexToEntRef(victim));
	WritePackCell(pack2, NumHits);
	WritePackCell(pack2, HitQuota);
	WritePackCell(pack2, MaxHeal);
	WritePackFloat(pack2, DMG);
	WritePackFloat(pack2, Rate);
	WritePackFloat(pack2, HealMult);
	WritePackFloat(pack2, Radius);
	
	return Plugin_Continue;
}