#pragma semicolon 1
#pragma newdecls required

void TownCenter_Setup()
{
	PrecacheModel("models/props_buildings/row_corner_2.mdl");
	PrecacheModel("models/props_c17/consolebox03a.mdl");

	if(FailTranslation("Villager"))
		return;
	
	ObjectData data;
	strcopy(data.Name, sizeof(data.Name), "Town Center");
	strcopy(data.Plugin, sizeof(data.Plugin), "object_towncenter");
	data.Func = ClotSummoned;
	data.Price[Resource_Supply] = -6;
	data.Price[Resource_Wood] = 375;
	Object_Add(data);
}

static any ClotSummoned(int team, const float vecPos[3], const char[] data)
{
	return TownCenter(team, vecPos);
}

methodmap TownCenter < EmpireObject
{
	public TownCenter(int team, const float vecPos[3])
	{
		TownCenter obj = view_as<TownCenter>(EmpireObject(team, vecPos, 4, 2400, false/*, "models/props_c17/consolebox03a.mdl", _, 11.0*/));
		
		obj.AddFlag(Flag_Structure);
		obj.AddFlag(Flag_Heroic);

		obj.m_hSkillsFunc = ClotSkill;
		obj.m_hDeathFunc = ClotDeath;
		ObjectTraining_Create(obj.index);

		Stats[obj.index].Sight = 8;
		Stats[obj.index].Damage = 5;
		Stats[obj.index].MeleeArmor = 3;
		Stats[obj.index].RangeArmor = 5;
		Stats[obj.index].Range = 6;

		obj.m_hWearable1 = obj.EquipItemSeperate("models/props_buildings/row_corner_2.mdl", _, _, 1.6);
		if(obj.m_hWearable1 != -1)
			SetEntityRenderColor(obj.m_hWearable1, TeamColor[team][0], TeamColor[team][1], TeamColor[team][2], 255);

		return obj;
	}
}

static bool ClotSkill(int entity, int client, int type, bool use, SkillEnum skill)
{
	switch(type)
	{
		case 0:	// Q
		{
			return ObjectTraining_SkillUnit(entity, client, "npc_villager", use, skill);
		}
		case 5:	// A
		{
			if(ClassEmpire_HasTech(TeamNumber[entity], EmpireTech_Loom))
				return false;
			
			static const int price[Resource_MAX] = {0, 0, 50}; // 50 Gold
			return ObjectTraining_SkillResearch(entity, client, "Loom", LoomResearched, price, 12.5, use, skill);
		}
		case 9:	// G
		{
			return ObjectTraining_ClearSkill(entity, client, use, skill);
		}
	}

	return false;
}

static void LoomResearched(int entity, int team)
{
	ClassEmpire_AddTech(team, EmpireTech_Loom);
}

static void ClotDeath(int entity)
{
	ObjectTraining_Destory(entity);
}
