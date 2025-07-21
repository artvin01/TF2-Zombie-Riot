#pragma semicolon 1
#pragma newdecls required

void ObjectTinkerBrew_MapStart()
{
	PrecacheModel("models/props_island/island_lab_equipment03.mdl");
	PrecacheModel("models/props_halloween/hwn_flask_vial.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Merchant Brewing Stand");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_brewing_stand");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_brewing_stand");
	build.Cost = 338;
	build.Health = 420;
	build.HealthScaleCost = true;
	build.Cooldown = 15.0;
	build.Func = ObjectTinkerBrew_CanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectTinkerBrew(client, vecPos, vecAng);
}

methodmap ObjectTinkerBrew < ObjectGeneric
{
	public ObjectTinkerBrew(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectTinkerBrew npc = view_as<ObjectTinkerBrew>(ObjectGeneric(client, vecPos, vecAng, "models/props_island/island_lab_equipment03.mdl", _, "600",{18.0, 25.0, 50.0}));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectTinkerBrew_CanBuild;
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;
		//SetRotateByDefaultReturn(npc.index, 90.0);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		int entity = npc.EquipItemSeperate("models/props_halloween/hwn_flask_vial.mdl", "idle", _, 0.85, 8.0);
		npc.m_iWearable5 = entity;
		AcceptEntityInput(entity, "Disable");
		npc.Anger = false;

		return npc;
	}
}

public bool ObjectTinkerBrew_CanBuild(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
	
	count = Object_GetSentryBuilding(client) == -1 ? 0 : 1;
	maxcount = Merchant_IsAMerchant(client) ? 1 : 0;

	return (!count && maxcount);
}

void ObjectTinkerBrew_TogglePotion(int entity, bool enable)
{
	ObjectTinkerBrew npc = view_as<ObjectTinkerBrew>(entity);
	if(IsValidEntity(npc.m_iWearable5))
	{
		if(npc.Anger && !enable)
		{
			AcceptEntityInput(npc.m_iWearable5, "Disable");
			npc.Anger = false;
		}
		else if(!npc.Anger && enable)
		{
			npc.Anger = true;
			AcceptEntityInput(npc.m_iWearable5, "Enable");
		}
	}
}

static void ClotThink(ObjectTinkerBrew npc)
{
	/*int maxrepair = GetEntProp(npc.index, Prop_Data, "m_iRepairMax");
	int repair = GetEntProp(npc.index, Prop_Data, "m_iRepair");
	if(repair < maxrepair)
	{
		// Regen 1% repair a second
		repair += maxrepair / 1000;
		if(repair > maxrepair)
			repair = maxrepair;

		SetEntProp(npc.index, Prop_Data, "m_iRepair", repair);
	}*/
}

static bool ClotCanUse(ObjectTinkerBrew npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectTinkerBrew npc, int client)
{
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%sto apply a potion effect to your active weapon.", ButtonDisplay,ButtonDisplay2);
}

static bool ClotInteract(int client, int weapon, ObjectTinkerBrew npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	BlacksmithBrew_BuildingUsed(npc.index, client);
//	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	
	return true;
}