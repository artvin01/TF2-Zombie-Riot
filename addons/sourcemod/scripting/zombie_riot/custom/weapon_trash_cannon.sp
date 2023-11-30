#pragma semicolon 1
#pragma newdecls required

//Stats based on pap level. Uses arrays for simpler code.
//Example: Weapon_Damage[3] = { 100.0, 250.0, 500.0 }; Default damage is 100, pap1 is 250, pap2 is 500.

//SHOCK STOCK: An electric orb, affected by gravity. Explodes into Passanger's Device chain lightning on impact.
float f_ShockChance[3] = { 0.08, 0.12, 0.16 };
bool b_ShockEnabled[3] = { true, true, true };

//MORTAR MARKER: A beacon which marks the spot it lands on for a special mortar strike, which scales with ranged upgrades.
float f_MortarChance[3] = { 0.04, 0.06, 0.08 };
bool b_MortarEnabled[3] = { true, true, true };

//BUNDLE OF ARROWS: A giant shotgun blast of Huntsman arrows.
float f_ArrowsChance[3] = { 0.00, 0.04, 0.08 };
bool b_ArrowsEnabled[3] = { false, true, true };

//PYRE: A fireball which is affected by gravity.
float f_PyreChance[3] = { 0.05, 0.08, 0.12 };
bool b_PyreEnabled[3] = { true, true, true };

//SKELETON: Fires a shotgun blast of skeleton gibs which deal huge contact damage.
float f_SkeletonChance[3] = { 0.00, 0.04, 0.08 };
bool b_SkeletonEnabled[3] = { false, true, true };

//NICE ICE: Fires a big block of ice which deals high contact damage and explodes, freezing all zombies hit by it.
float f_IceChance[3] = { 0.00, 0.04, 0.08 };
bool b_IceEnabled[3] = { false, true, true };

//TRASH: Fires a garbage bag which explodes on impact and applies a powerful poison to all zombies hit by it. Poisoned zombies are given the lesser Medusa debuff.
float f_TrashChance[3] = { 0.00, 0.03, 0.06 };
bool b_TrashEnabled[3] = { false, true, true };

//MICRO-MISSILES: Fires a burst of X micro-missiles which aggressively home in on the nearest enemy and explode.
float f_MissilesChance[3] = { 0.00, 0.00, 0.05 };
bool b_MissilesEnabled[3] = { false, false, true };

//MONDO MASSACRE: The strongest possible roll. Fires an EXTREMELY powerful rocket which deals a base damage of 100k within an enormous blast radius.
float f_MondoChance[3] = { 0.00, 0.00, 0.0001 };
bool b_MondoEnabled[3] = { false, false, true };

static int i_TrashNumEffects = 10;

void Trash_Cannon_Precache()
{
}

public void Trash_Cannon_EntityDestroyed(int ent)
{
	if (!IsValidEdict(ent))
		return;
}

public void Weapon_Trash_Cannon_Fire(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 0);
}
public void Weapon_Trash_Cannon_Fire_Pap1(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 1);
}
public void Weapon_Trash_Cannon_Fire_Pap2(int client, int weapon, bool crit)
{
	Trash_Cannon_Shoot(client, weapon, crit, 2);
}

public void Trash_Cannon_Shoot(int client, int weapon, bool crit, int tier)
{
	Queue scramble = Rand_GenerateScrambledQueue(i_TrashNumEffects);
	
	bool success = false;
	while (!success && !scramble.Empty)
	{
		int effect = scramble.Pop();
		switch(effect)
		{
			case 1:
				success = Trash_Shock(client, weapon, tier);
			case 2:
				success = Trash_Mortar(client, weapon, tier);
			case 3:
				success = Trash_Arrows(client, weapon, tier);
			case 4:
				success = Trash_Pyre(client, weapon, tier);
			case 5:
				success = Trash_Skeleton(client, weapon, tier);
			case 6:
				success = Trash_Ice(client, weapon, tier);
			case 7:
				success = Trash_Trash(client, weapon, tier);
			case 8:
				success = Trash_Missiles(client, weapon, tier);
			case 9:
				success = Trash_Mondo(client, weapon, tier);
		}
	}
	
	delete scramble;
	
	if (!success)
		Trash_FlimsyRocket(client, weapon, tier);
}

public void Trash_FlimsyRocket(int client, int weapon, int tier)
{
	
}

public bool Trash_Shock(int client, int weapon, int tier)
{
	if (!b_ShockEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ShockChance[tier])
		return false;
		
	return true;
}

public bool Trash_Mortar(int client, int weapon, int tier)
{
	if (!b_MortarEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MortarChance[tier])
		return false;
		
	return true;
}

public bool Trash_Arrows(int client, int weapon, int tier)
{
	if (!b_ArrowsEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_ArrowsChance[tier])
		return false;
		
	return true;
}

public bool Trash_Pyre(int client, int weapon, int tier)
{
	if (!b_PyreEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_PyreChance[tier])
		return false;
		
	return true;
}

public bool Trash_Skeleton(int client, int weapon, int tier)
{
	if (!b_SkeletonEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_SkeletonChance[tier])
		return false;
		
	return true;
}

public bool Trash_Ice(int client, int weapon, int tier)
{
	if (!b_IceEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_IceChance[tier])
		return false;
		
	return true;
}

public bool Trash_Trash(int client, int weapon, int tier)
{
	if (!b_TrashEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_TrashChance[tier])
		return false;
		
	return true;
}

public bool Trash_Missiles(int client, int weapon, int tier)
{
	if (!b_MissilesEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MissilesChance[tier])
		return false;
		
	return true;
}

public bool Trash_Mondo(int client, int weapon, int tier)
{
	if (!b_MondoEnabled[tier])
		return false;
		
	if (GetRandomFloat(0.0, 1.0) > f_MondoChance[tier])
		return false;
		
	return true;
}

public Queue Rand_GenerateScrambledQueue(int numSlots)
{
	Queue scramble = new Queue();
	Handle genericArray = CreateArray(255);
	
	for (int i = 0; i < numSlots; i++)
	{
		PushArrayCell(genericArray, i);
	}
	
	for (int j = 0; j < GetArraySize(genericArray); j++)
	{
		int randSlot = GetRandomInt(j, GetArraySize(genericArray) - 1);
		int currentVal = GetArrayCell(genericArray, j);
		SetArrayCell(genericArray, j, GetArrayCell(genericArray, randSlot));
		SetArrayCell(genericArray, randSlot, currentVal);
		
		scramble.Push(GetArrayCell(genericArray, j));
	}
	
	delete genericArray;
	return scramble;
}