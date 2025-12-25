#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectPump_MapStart()
{
	PrecacheModel("models/props_hydro/water_machinery1.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Water Pump");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_pump");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_pump");
	build.Cost = 500;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectPump(client, vecPos, vecAng);
}

methodmap ObjectPump < ObjectGeneric
{
	public ObjectPump(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectPump npc = view_as<ObjectPump>(ObjectGeneric(client, vecPos, vecAng, "models/props_hydro/water_machinery1.mdl", _, "600", {24.0, 24.0, 283.0}));
		
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		npc.m_bConstructBuilding = true;

		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 120.0;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Base Level I"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 3;

		if(Construction_HasNamedResearch("Base Level II"))
			maxcount++;
		
		if(Construction_HasNamedResearch("Base Level III"))
			maxcount++;
		
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
			count++;
	}

	return count;
}

static bool ClotCanUse(ObjectPump npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectPump npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", Building_Collect_Cooldown[npc.index][0] - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto collect water.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectPump npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if((GetURandomInt() % 3) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
	{
		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 60.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	int amount = 10;

	if(Construction_HasNamedResearch("Base Level II"))
		amount += 5;
	
	if(Construction_HasNamedResearch("Base Level III"))
		amount += 5;
	
	if(Construction_HasNamedResearch("Enchanced Water Pump"))
		amount *= 2;

	Construction_AddMaterial("water", amount);
	Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 120.0;
	return true;
}
