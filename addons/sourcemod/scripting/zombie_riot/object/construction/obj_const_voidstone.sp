#pragma semicolon 1
#pragma newdecls required

static const char Artifacts[][] =
{
	"Consume Voidstone",
	"Consume Voidstone",
	"Reclaim Voidstone",
	"Pillage Voidstone",
	"Pillage Voidstone",
	"Invasion Voidstone",
	"Words Voidstone",
	"Words Voidstone",
	"Assembly Voidstone"
};

static const int CrystalCost = 10;

static int NPCId;
static float GlobalCooldown;
static bool Shuffled;
static bool Enabled[sizeof(Artifacts)];

void ObjectVoidstone_MapStart()
{
	Shuffled = false;
	GlobalCooldown = 0.0;
	PrecacheModel("models/props_spytech/computer_printer.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Crystal Polisher");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_voidstone");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_voidstone");
	build.Cost = 1000;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectVoidstone(client, vecPos, vecAng);
}

methodmap ObjectVoidstone < ObjectGeneric
{
	public ObjectVoidstone(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectVoidstone npc = view_as<ObjectVoidstone>(ObjectGeneric(client, vecPos, vecAng, "models/props_spytech/computer_printer.mdl", _, "600", {23.0, 23.0, 66.0}));
		
		npc.FuncCanUse = ClotCanUse;
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
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Crystal Polisher"))
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
			count++;
	}

	return count;
}

static bool ClotCanUse(ObjectVoidstone npc, int client)
{
	if(GlobalCooldown > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectVoidstone npc, int client)
{
	if(GlobalCooldown > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", GlobalCooldown - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto process crystals into voidstones.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectVoidstone npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	if(!Shuffled)
	{
		Zero(Enabled);
		Shuffled = true;

		for(int i; i < 2; i++)
		{
			Enabled[GetURandomInt() % sizeof(Enabled)] = true;
		}
	}

	int crystal = Construction_GetMaterial("crystal");

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d / %d %t\n \n%t", "Crystal Polisher", crystal, CrystalCost, "Material crystal", "Crouch and select to view description Alone");

	char buffer[64];
	for(int i; i < sizeof(Enabled); i++)
	{
		if(Enabled[i])
		{
			FormatEx(buffer, sizeof(buffer), "%t", Artifacts[i]);
			menu.AddItem(Artifacts[i], buffer);
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int ThisBuildingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			if(GetClientButtons(client) & IN_DUCK)
			{
				char desc[64];
				FormatEx(desc, sizeof(desc), "%s Desc", buffer);
				CPrintToChat(client, "%t", "Artifact Info", buffer, desc);

				ThisBuildingMenu(client);
			}
			else if(GlobalCooldown < GetGameTime() && Construction_GetMaterial("crystal") >= CrystalCost)
			{
				GlobalCooldown = GetGameTime() + 200.0;
				Shuffled = false;

				CPrintToChatAll("%t", "Player Used 1 to", client, CrystalCost, "Material crystal");
				
				Construction_AddMaterial("crystal", -CrystalCost, true);
				Rogue_GiveNamedArtifact(buffer);
			}
		}
	}
	return 0;
}