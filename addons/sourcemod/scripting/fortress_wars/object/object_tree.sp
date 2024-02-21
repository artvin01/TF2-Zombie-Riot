#pragma semicolon 1
#pragma newdecls required

void TreeObject_Setup()
{
	PrecacheModel("models/props_manor/clocktower_01.mdl");
	PrecacheModel("models/props_foliage/deadtree01.mdl");
	
	ObjectData data;
	strcopy(data.Name, sizeof(data.Name), "Dead Tree");
	strcopy(data.Plugin, sizeof(data.Plugin), "object_tree_dead");
	data.Func = GetFunctionByName(null, "DeadTree.DeadTree");
	Object_Add(data);
}

methodmap DeadTree < UnitObject
{
	public DeadTree(const float vecPos[3], const float vecAng[3], const char[] data)
	{
		float ang[3];
		ang = vecAng;
		ang[1] = (GetURandomFloat() * 360.0) - 180.0;

		int health = data[0] ? StringToInt(data) : 100;

		DeadTree unit = view_as<DeadTree>(UnitObject(vecPos, vecAng, "models/props_manor/clocktower_01.mdl", 0.25, health));
		
		unit.m_iResourceType = Resource_Wood;
		unit.m_hOnTakeDamageFunc = ClotTakeDamage;

		SetEntityRenderMode(unit.index, RENDER_NONE);

		unit.m_hWearable1 = unit.EquipItemSeperate("models/props_foliage/deadtree01.mdl", _, _, 1.01);

		return unit;
	}
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype & DMG_BLAST)
	{
		// Blast outright breaks trees
		damage *= 100.0;
		return Plugin_Changed;
	}
	else if(!(damagetype & DMG_CLUB))
	{
		// 'Infinite' pierce armor
		damage = 1.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}
