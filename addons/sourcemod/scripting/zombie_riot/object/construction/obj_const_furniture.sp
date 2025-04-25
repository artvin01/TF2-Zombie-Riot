#pragma semicolon 1
#pragma newdecls required

static ArrayList NPCIds;

void ObjectFurniture_MapStart()
{
	delete NPCIds;
	if(!NPCIds)
		return;
		//for now block.
	NPCIds = new ArrayList();

	PrecacheModel("models/props_c17/lamppost03a_off.mdl");
	AddFurniture("Decorative Lamp", "obj_const_furniture1", ClotSummonLamp);

	PrecacheModel("models/props_interiors/furniture_shelf01a.mdl");
	AddFurniture("Decorative Shelf", "obj_const_furniture2", ClotSummonShelf);

	PrecacheModel("models/props_interiors/furniture_desk01a.mdl");
	AddFurniture("Decorative Desk", "obj_const_furniture3", ClotSummonDesk);

	PrecacheModel("models/props_interiors/furniture_couch01a.mdl");
	AddFurniture("Decorative Couch", "obj_const_furniture4", ClotSummonCouch);

	PrecacheModel("models/props_interiors/furniture_chair03a.mdl");
	AddFurniture("Decorative Chair", "obj_const_furniture5", ClotSummonChair);
}

static void AddFurniture(const char[] name, const char[] plugin, Function func)
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), name);
	strcopy(data.Plugin, sizeof(data.Plugin), plugin);
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = func;
	NPCIds.Push(NPC_Add(data));

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), plugin);
	build.Cost = 4;
	build.Health = 50;
	build.HealthScaleCost = true;
	build.Cooldown = 10.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Decorative Furniture"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 15;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCIds.FindValue(i_NpcInternalId[entity]) != -1)
			count++;
	}

	return count;
}

static any ClotSummonLamp(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFurnitureLamp(client, vecPos, vecAng);
}

methodmap ObjectFurnitureLamp < ObjectGeneric
{
	public ObjectFurnitureLamp(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFurnitureLamp npc = view_as<ObjectFurnitureLamp>(ObjectGeneric(client, vecPos, vecAng, "models/props_swamp/lamp_post001.mdl", "1.0", "50", {10.0, 10.0, 40.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static any ClotSummonShelf(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFurnitureShelf(client, vecPos, vecAng);
}

methodmap ObjectFurnitureShelf < ObjectGeneric
{
	public ObjectFurnitureShelf(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFurnitureShelf npc = view_as<ObjectFurnitureShelf>(ObjectGeneric(client, vecPos, vecAng, "models/props_interiors/furniture_shelf01a.mdl", "1.0", "50", {25.0, 25.0, 88.0}, 43.0, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static any ClotSummonDesk(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFurnitureDesk(client, vecPos, vecAng);
}

methodmap ObjectFurnitureDesk < ObjectGeneric
{
	public ObjectFurnitureDesk(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFurnitureDesk npc = view_as<ObjectFurnitureDesk>(ObjectGeneric(client, vecPos, vecAng, "models/props_spytech/work_table001.mdl", "1.0", "50", {34.0, 34.0, 40.0}, 0.0, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static any ClotSummonCouch(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFurnitureCouch(client, vecPos, vecAng);
}

methodmap ObjectFurnitureCouch < ObjectGeneric
{
	public ObjectFurnitureCouch(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFurnitureCouch npc = view_as<ObjectFurnitureCouch>(ObjectGeneric(client, vecPos, vecAng, "models/props_manor/couch_01.mdl", "1.0", "50", {40.0, 40.0, 44.0}, 0.0, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static any ClotSummonChair(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFurnitureChair(client, vecPos, vecAng);
}

methodmap ObjectFurnitureChair < ObjectGeneric
{
	public ObjectFurnitureChair(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFurnitureChair npc = view_as<ObjectFurnitureChair>(ObjectGeneric(client, vecPos, vecAng, "models/props_interiors/furniture_chair03a.mdl", "1.0", "50", {10.0, 10.0, 40.0}, 19.0, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}