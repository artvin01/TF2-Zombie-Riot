#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectStone_MapStart()
{
	PrecacheModel("models/props_mining/generator_machine01.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stonework Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_stone");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_stone");
	build.Cost = 1500;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectStone(client, vecPos, vecAng);
}

methodmap ObjectStone < ObjectGeneric
{
	public ObjectStone(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectStone npc = view_as<ObjectStone>(ObjectGeneric(client, vecPos, vecAng, "models/props_mining/generator_machine01.mdl", "0.7", "600", {80.0, 80.0, 80.0}));
		
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		npc.m_bConstructBuilding = true;

		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 140.0;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Stonework Factory"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;
		
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

static bool ClotCanUse(ObjectStone npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectStone npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", Building_Collect_Cooldown[npc.index][0] - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto collect stone.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectStone npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if((GetURandomInt() % 3) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
	{
		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 70.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	float time = 140.0;
	int amount = 5;
	
	if(Construction_HasNamedResearch("Base Level III"))
		amount += 5;
	
	if(Construction_HasNamedResearch("Enchanced Stonework Factory"))
		amount *= 2;

	Construction_AddMaterial("stone", amount);
	Building_Collect_Cooldown[npc.index][0] = GetGameTime() + time;
	return true;
}
