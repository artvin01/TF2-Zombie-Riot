#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectMinter_MapStart()
{
	PrecacheModel("models/props_spytech/computer_printer.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Minting Station");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_minter");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_minter");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectMinter(client, vecPos, vecAng);
}

methodmap ObjectMinter < ObjectGeneric
{
	public ObjectMinter(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectMinter npc = view_as<ObjectMinter>(ObjectGeneric(client, vecPos, vecAng, "models/props_spytech/computer_printer.mdl", _, "600", {23.0, 23.0, 66.0}));
		
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		npc.m_bConstructBuilding = true;

		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 50.0;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Minting Station"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 2;
		
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

static bool ClotCanUse(ObjectMinter npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectMinter npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
	{
		if((Building_Collect_Cooldown[npc.index][0] - GetGameTime()) >= 999999.9)
			PrintCenterText(client, "%t","Object Cooldown NextWave");
		else
			PrintCenterText(client, "%t", "Object Cooldown", Building_Collect_Cooldown[npc.index][0] - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto convert 5 Crystals to 1000 Cash.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectMinter npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if(Construction_GetMaterial("crystal") > 4)
	{
		CPrintToChatAll("%t 1000 Cash", "Player Used 1 to", client, 5, "Material crystal");

		CurrentCash += 1000;
		GlobalExtraCash += 1000;	
		
		Construction_AddMaterial("crystal", -5, true);
	}
	
	Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 50.0;
	return true;
}
