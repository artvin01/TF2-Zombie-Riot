#pragma semicolon 1
#pragma newdecls required

static const float minbounds[3] = {-15.0, -15.0, 0.0};
				static const float maxbounds[3] = {15.0, 15.0, 45.0};
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
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectHealingStation(client, vecPos, vecAng);
}

methodmap ObjectHealingStation < ObjectGeneric
{
	public ObjectHealingStation(int client, const float vecPos[3], const float vecAng[3])
	{ 
		ObjectHealingStation npc = view_as<ObjectHealingStation>(ObjectGeneric(client, vecPos, vecAng, "models/props_halloween/fridge.mdl", "0.65", "500", {15.0, 15.0, 45.0}));

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;

		return npc;
	}
}

static bool ClotCanUse(ObjectHealingStation npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;
		
	return false;
}

static void ClotShowInteractHud(ObjectHealingStation npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "Healing Station Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	int owner;
	owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	Store_PackMenu(client, StoreWeapon[weapon], weapon, owner);
	ApplyBuildingCollectCooldown(npc.index, client, 90.0);
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	float HealAmmount = 30.0;
	if(IsValidClient(owner))
	{
		HealAmmount *= Attributes_GetOnPlayer(owner, 8, true, true);
	}

	HealEntityGlobal(owner, client, HealAmmount, _, 3.0, _);
	return true;
}