#pragma semicolon 1
#pragma newdecls required

static const char Artifacts[][] =
{
	"Atomic Soda",
	"Critical Water",
	"Questionable Milk",
	"Festive Atomic Soda",
	"Bread in Milk",
	"Steamed Mackerel",
	"BBQ Mackerel",
	"Beer Bottle",
	"The Sandvich",
	"The Dalokohs Bar",
	"The Buffalo Steak Sandvich",
	"The Fishcake",
	"The Robo-Sandvich",
	"The Festive Sandvich",
	"The Second Banana"
};

static const int WaterCost = 100;
static const int BofaCost = 5;

static int NPCId;
static float GlobalCooldown;
static bool Shuffled;
static bool Enabled[sizeof(Artifacts)];

void ObjectStove_MapStart()
{
	Shuffled = false;
	GlobalCooldown = 0.0;
	PrecacheModel("models/props_c17/furniturestove001a.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cooking Stove");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_stove");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_stove");
	build.Cost = 1000;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectStove(client, vecPos, vecAng);
}

methodmap ObjectStove < ObjectGeneric
{
	public ObjectStove(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectStove npc = view_as<ObjectStove>(ObjectGeneric(client, vecPos, vecAng, "models/props_c17/furniturestove001a.mdl", _, "600", {27.0, 27.0, 41.0}, 20.0));
		
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
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Cooking Stove"))
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

static bool ClotCanUse(ObjectStove npc, int client)
{
	if(GlobalCooldown > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectStove npc, int client)
{
	if(GlobalCooldown > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", GlobalCooldown - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto cook something using materials.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectStove npc)
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

		for(int i; i < 4; i++)
		{
			Enabled[GetURandomInt() % sizeof(Enabled)] = true;
		}
	}

	int water = Construction_GetMaterial("water");
	int bofazem = Construction_GetMaterial("bofazem");

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d / %d %t\n%d / %d %t\n \n%t", "Cooking Stove", water, WaterCost, "Material water", bofazem, BofaCost, "Material bofazem", "Crouch and select to view description Alone");

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
			else if(GlobalCooldown < GetGameTime() && Construction_GetMaterial("water") >= WaterCost && Construction_GetMaterial("bofazem") >= BofaCost)
			{
				GlobalCooldown = GetGameTime() + 250.0;
				Shuffled = false;

				CPrintToChatAll("%t", "Player Used 2 to", client, WaterCost, "Material water", BofaCost, "Material bofazem");
				
				Construction_AddMaterial("water", -WaterCost, true);
				Construction_AddMaterial("bofazem", -BofaCost, true);
				Rogue_GiveNamedArtifact(buffer);
			}
		}
	}
	return 0;
}