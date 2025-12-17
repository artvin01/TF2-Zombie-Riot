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

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_tinker_anvil");
	build.Cost = 350;
	build.Health = 600;
	build.HealthScaleCost = true;
	build.Cooldown = 15.0;
	build.Func = ObjectTinkerAnvil_CanBuild;
	Building_Add(build);
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
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		for(int i = 1; i <= MaxClients; i++)
		{
			ApplyBuildingCollectCooldown(npc.index, i, 0.0);
		}

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

		SetEntProp(npc.index, Prop_Data, "m_iRepair", repair);
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
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%t", ButtonDisplay2, ButtonDisplay, "Blacksmith Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectTinkerAnvil npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if((GetURandomInt() % 4) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
	{
		Building_Collect_Cooldown[npc.index][client] = GetGameTime() + 5.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	
	Blacksmith_BuildingUsed(npc.index, client);
//	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	
	return true;
}