#pragma semicolon 1
#pragma newdecls required

void ObjectHealingStation_MapStart()
{
	PrecacheModel("models/props_halloween/fridge.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Food Fridge");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_healingstation");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_healingstation");
	build.Cost = 600;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectHealingStation(client, vecPos, vecAng);
}

methodmap ObjectHealingStation < ObjectGeneric
{
	public ObjectHealingStation(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectHealingStation npc = view_as<ObjectHealingStation>(ObjectGeneric(client, vecPos, vecAng, "models/props_halloween/fridge.mdl", "0.65", "50", {15.0, 15.0, 57.0}));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}

static bool ClotCanUse(ObjectHealingStation npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;
		
	return true;
}

static void ClotShowInteractHud(ObjectHealingStation npc, int client)
{
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%T",ButtonDisplay2,ButtonDisplay, "Healing Station Tooltip",client);
}

static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
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

	int owner;
	owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	ApplyBuildingCollectCooldown(npc.index, client, 90.0);
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	float HealAmmount = 30.0;
	if(IsValidClient(owner))
	{
		HealAmmount *= Attributes_GetOnPlayer(owner, 8, true);
	}
	Building_GiveRewardsUse(client, owner, 15, true, 0.4, true);

	HealEntityGlobal(owner, client, HealAmmount, _, 3.0, _);
	return true;
}
