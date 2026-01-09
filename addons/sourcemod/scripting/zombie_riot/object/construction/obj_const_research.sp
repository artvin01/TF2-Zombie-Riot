#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectResearch_MapStart()
{
	PrecacheModel("models/props_combine/masterinterface.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Research Station");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_research");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_research");
	build.Cost = 400;
	build.Health = 50;
	build.Cooldown = 20.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectResearch(client, vecPos, vecAng);
}

methodmap ObjectResearch < ObjectGeneric
{
	public ObjectResearch(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectResearch npc = view_as<ObjectResearch>(ObjectGeneric(client, vecPos, vecAng, "models/props_combine/masterinterface.mdl", _, "600", {65.0, 65.0, 197.0},_,false));
		
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		npc.m_bConstructBuilding = true;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!Construction_Mode())
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;
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
		if(NPCId == i_NpcInternalId[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
		{
			count++;
		}
	}

	return count;
}

static void ClotShowInteractHud(ObjectResearch npc, int client)
{
	char button[64];
	PlayerHasInteract(client, button, sizeof(button));
	PrintCenterText(client, "%sto research using materials.", button);
}

static bool ClotInteract(int client, int weapon, ObjectResearch npc)
{
	Construction_OpenResearch(client);
	return true;
}
