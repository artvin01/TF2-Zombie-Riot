#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectSupply_MapStart()
{
	PrecacheModel("models/props_farm/barn_loft001a.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks House");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_supply");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_supply");
	build.Cost = 800;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectSupply(client, vecPos, vecAng);
}

methodmap ObjectSupply < ObjectGeneric
{
	public ObjectSupply(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectSupply npc = view_as<ObjectSupply>(ObjectGeneric(client, vecPos, vecAng, "models/props_farm/barn_loft001a.mdl", "0.4", "50", {65.0, 65.0, 70.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectSupply_CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Command Center"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 2;

		if(Construction_HasNamedResearch("Base Level II"))
			maxcount++;

		if(Construction_HasNamedResearch("Base Level III"))
			maxcount++;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

int ObjectSupply_CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}
