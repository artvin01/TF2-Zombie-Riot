#pragma semicolon 1
#pragma newdecls required

void ObjectTinkerAnvil_MapStart()
{
	PrecacheModel("models/props_medieval/anvil.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tinker Workshop");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_tinker_anvil");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectTinkerAnvil(client, vecPos, vecAng);
}

methodmap ObjectTinkerAnvil < ObjectGeneric
{
	public ObjectTinkerAnvil(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectTinkerAnvil npc = view_as<ObjectTinkerAnvil>(ObjectGeneric(client, vecPos, vecAng, "models/props_medieval/anvil.mdl", _, "600",{20.0, 20.0, 42.0}));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectTinkerAnvil_CanBuild;
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, 90.0);

		return npc;
	}
}

public bool ObjectTinkerAnvil_CanBuild(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
	
	count = Object_GetSentryBuilding(client) == -1 ? 0 : 1;
	maxcount = Blacksmith_IsASmith(client) ? 1 : 0;

	return (!count && maxcount);
}

static void ClotThink(ObjectTinkerAnvil npc)
{
	int maxrepair = GetEntProp(npc.index, Prop_Data, "m_iRepairMax");
	int repair = GetEntProp(npc.index, Prop_Data, "m_iRepair");
	if(repair < maxrepair)
	{
		// Regen 1% repair a second
		repair += maxrepair / 1000;
		if(repair > maxrepair)
			repair = maxrepair;
	}
}

static bool ClotCanUse(ObjectTinkerAnvil npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectTinkerAnvil npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "Blacksmith Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectTinkerAnvil npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	int owner;
	owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	Blacksmith_BuildingUsed(npc.index, client, owner);
	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	
	return true;
}