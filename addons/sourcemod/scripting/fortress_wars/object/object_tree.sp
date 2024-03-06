#pragma semicolon 1
#pragma newdecls required

void TreeObject_Setup()
{
	PrecacheModel("models/props_foliage/deadtree01.mdl");
	
	ObjectData data;
	strcopy(data.Name, sizeof(data.Name), "Dead Tree");
	strcopy(data.Plugin, sizeof(data.Plugin), "object_tree_dead");
	data.Func = DeadTreeSummon;
	Object_Add(data);
}

static any DeadTreeSummon(int team, const float vecPos[3], const char[] data)
{
	float ang[3];
	ang[1] = (GetURandomFloat() * 360.0) - 180.0;

	int health = data[0] ? StringToInt(data) : 100;

	UnitObject obj = UnitObject(team, vecPos, 1, health);
	
	obj.m_iResourceType = Resource_Wood;
	obj.m_hOnTakeDamageFunc = ClotTakeDamage;

	Stats[obj.index].RangeArmor = 99;

	obj.m_hWearable1 = obj.EquipItemSeperate("models/props_foliage/deadtree01.mdl", _, _, 1.0);
	if(obj.m_hWearable1 != -1)
		TeleportEntity(obj.m_hWearable1, NULL_VECTOR, ang, NULL_VECTOR);

	return obj;
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype & DMG_BLAST)
	{
		// Blast outright breaks trees
		damage *= 100.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}
