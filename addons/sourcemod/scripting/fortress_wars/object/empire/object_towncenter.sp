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
	return TownCenter(team, vecPos, vecAng);
}

methodmap TownCenter < EmpireObject
{
	public TownCenter(int team, const float vecPos[3])
	{
		TownCenter obj = view_as<TownCenter>(EmpireObject(team, vecPos, 4, 2400, false, "models/props_c17/consolebox03a.mdl", _, 11.0));
		
		obj.AddFlag(Flag_Structure);
		obj.AddFlag(Flag_Heroic);

		obj.m_hSkillsFunc = ClotSkill;
		ObjectTraining_Create(entity);

		Stats[obj.index].Sight = 8;
		Stats[obj.index].Damage = 5;
		Stats[obj.index].MeleeArmor = 3;
		Stats[obj.index].RangeArmor = 5;
		Stats[obj.index].Range = 6;

		obj.m_hWearable1 = obj.EquipItemSeperate("models/props_buildings/row_corner_2.mdl", _, _, 1.6);
		if(obj.m_hWearable1 != -1)
			SetEntityRenderColor(obj.index, TeamColor[team][0], TeamColor[team][1], TeamColor[team][2], 255);

		return obj;
	}
}

static bool ClotSkill(int entity, int client, int type, bool use, SkillEnum skill)
{
	switch(type)
	{
		case 0:	// Q
		{
			return ObjectTraining_Skill(entity, client, "npc_villager", use, skill);
		}
	}

	return false;
}
