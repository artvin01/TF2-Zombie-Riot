#pragma semicolon 1
#pragma newdecls required

static const char Vehicles[][] =
{
	"vehicle_ambulance",
	"vehicle_bus",
	"vehicle_camper",
	"vehicle_dumptruck_empty",
	"vehicle_landrover",
	"vehicle_pickup"
};

static const int IronCost = 15;

static int NPCId;
static float GlobalCooldown;

void ObjectFactory_MapStart()
{
	GlobalCooldown = 0.0;
	PrecacheModel("models/props_mvm/mann_hatch.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vehicle Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_factory");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_factory");
	build.Cost = 2000;
	build.Health = 100;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectFactory(client, vecPos, vecAng);
}

methodmap ObjectFactory < ObjectGeneric
{
	public ObjectFactory(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectFactory npc = view_as<ObjectFactory>(ObjectGeneric(client, vecPos, vecAng, "models/props_mvm/mann_hatch.mdl", "0.5", "600", {80.0, 80.0, 16.0}));
		
 		b_CantCollidie[npc.index] = true;
	 	b_CantCollidieAlly[npc.index] = true;
		npc.m_bThisEntityIgnored = true;
		npc.m_bConstructBuilding = true;

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		
		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if((!CvarInfiniteCash.BoolValue || !Construction_Mode()) && !Construction_HasNamedResearch("Vehicle Factory"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;

	//	if(Construction_HasNamedResearch("Base Level II"))
	//		maxcount++;
	//	
	//	if(Construction_HasNamedResearch("Base Level III"))
	//		maxcount++;
		
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

static int CountVehicles()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_vehicle")) != -1)
	{
		count++;
	}

	return count;
}

static bool ClotCanUse(ObjectFactory npc, int client)
{
	if(GlobalCooldown > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectFactory npc, int client)
{
	if(GlobalCooldown > GetGameTime())
	{
		if(GlobalCooldown - GetGameTime() >= 999999.9)
			PrintCenterText(client, "%t","Object Cooldown NextWave");
		else
			PrintCenterText(client, "%t","Object Cooldown",GlobalCooldown - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%sto build a vehicle using materials.", button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectFactory npc)
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
	int iron = Construction_GetMaterial("iron");
	int ossunia = Construction_GetMaterial("ossunia");
	int ossuniaCost = OssuniaCost();

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	char buffer2[512];
	Format(buffer2, sizeof(buffer2), "%t\n%d / %d %t\n%d / %d %t\n \n%t", "Vehicle Factory", iron, IronCost, "Material iron", ossunia, ossuniaCost, "Material ossunia", "Crouch and select to view description Alone");
	menu.SetTitle(buffer2);

	char buffer[64];
	for(int i; i < sizeof(Vehicles); i++)
	{
		NPC_GetNameByPlugin(Vehicles[i], buffer, sizeof(buffer));
		Format(buffer, sizeof(buffer), "%t", buffer);
		menu.AddItem(Vehicles[i], buffer);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int OssuniaCost()
{
	switch(CountVehicles())
	{
		case 0:
			return 0;
		
		case 1:
			return 30;
		
		case 2:
			return 60;
	}

	return 999;
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
				NPC_GetNameByPlugin(buffer, buffer, sizeof(buffer));
				FormatEx(desc, sizeof(desc), "%s Desc", buffer);
				CPrintToChat(client, "%t", "Artifact Info", buffer, desc);

				ThisBuildingMenu(client);
			}
			else
			{
				int ossuniaCost = OssuniaCost();

				if(GlobalCooldown < GetGameTime() && Construction_GetMaterial("iron") >= IronCost && Construction_GetMaterial("ossunia") >= ossuniaCost)
				{
					float pos[3], ang[3];
					
					int entity = -1;
					while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
					{
						if(NPCId == i_NpcInternalId[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
						{
							GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
							GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
						}
					}

					if(pos[0])
					{
						GlobalCooldown = Construction_GetNextAttack();
						
						Construction_AddMaterial("iron", -IronCost, true);
						Construction_AddMaterial("ossunia", -ossuniaCost, true);

						pos[2] += 10.0;
						ang[1] += 90.0;
						NPC_CreateByName(buffer, -1, pos, ang, TFTeam_Red);

						NPC_GetNameByPlugin(buffer, buffer, sizeof(buffer));
						CPrintToChatAll("%t {orange}%t", "Player Used 2 to", client, IronCost, "Material iron", ossuniaCost, "Material ossunia", buffer);
					}
				}
			}
		}
	}
	return 0;
}