#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"Control Center"

static const int CompassCrystalCost = 5;
static const int UnboxCrystalCost = 10;

static int NPCId;

void ObjectDungeonCenter_MapStart()
{
	PrecacheModel("models/props_combine/masterinterface.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_center");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_center");
	build.Cost = 400;
	build.Health = 50;
	build.Cooldown = 20.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDungeonCenter(client, vecPos, vecAng);
}

methodmap ObjectDungeonCenter < ObjectGeneric
{
	public ObjectDungeonCenter(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectDungeonCenter npc = view_as<ObjectDungeonCenter>(ObjectGeneric(client, vecPos, vecAng, "models/props_combine/masterinterface.mdl", _, "600", {65.0, 65.0, 197.0},_,false));
		
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
		
		if(!Dungeon_Mode())
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
		{
			count++;
		}
	}

	return count;
}

static void ClotShowInteractHud(ObjectDungeonCenter npc, int client)
{
	char button[64];
	PlayerHasInteract(client, button, sizeof(button));
	PrintCenterText(client, "%sto view control and crafting options.", button);
}

static bool ClotInteract(int client, int weapon, ObjectDungeonCenter npc)
{
	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	int wood = Construction_GetMaterial("wood");
	int iron = Construction_GetMaterial("iron");
	int copper = Construction_GetMaterial("copper");
	int crystal = Construction_GetMaterial("crystal");
	bool freeKey = Rogue_HasNamedArtifact("Can Opener");
	int unboxCost = freeKey ? 0 : UnboxCrystalCost;

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d %t   %d %t\n%d %t   %d %t\n ", CONSTRUCT_NAME,
		wood, "Material wood",
		crystal, "Material crystal",
		iron, "Material iron",
		copper, "Material copper");

	char buffer[64];

	if(Rogue_HasNamedArtifact("Compass Fragment"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Craft Item", "Dungeon Compass", crystal, CompassCrystalCost, "Material crystal");
		menu.AddItem("1", buffer, (crystal < CompassCrystalCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(Rogue_HasNamedArtifact("Sealed Jalan Crate"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Unbox Item", "Sealed Jalan Crate", crystal, unboxCost, "Material crystal");
		menu.AddItem("2", buffer, (crystal < unboxCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(Rogue_HasNamedArtifact("Sealed Wizuh Crate"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Unbox Item", "Sealed Wizuh Crate", crystal, unboxCost, "Material crystal");
		menu.AddItem("3", buffer, (crystal < unboxCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(Rogue_HasNamedArtifact("Sealed Ossunia Crate"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Unbox Item", "Sealed Ossunia Crate", crystal, unboxCost, "Material crystal");
		menu.AddItem("4", buffer, (crystal < unboxCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(Rogue_HasNamedArtifact("Sealed Bofazem Crate"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Unbox Item", "Sealed Bofazem Crate", crystal, unboxCost, "Material crystal");
		menu.AddItem("5", buffer, (crystal < unboxCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	if(!menu.ItemCount)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "No Actions Needed");
		menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);
	}

	menu.Pagination = 3;
	menu.ExitButton = true;
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
				PrintToChat(client, "%T", CONSTRUCT_NAME ... " Desc", client);
				ThisBuildingMenu(client);
			}
			else
			{
				bool freeKey = Rogue_HasNamedArtifact("Can Opener");
				int unboxCost = freeKey ? 0 : UnboxCrystalCost;

				int option = StringToInt(buffer);
				switch(option)
				{
					case 1:
					{
						if(Rogue_HasNamedArtifact("Compass Fragment") && Construction_GetMaterial("crystal") >= CompassCrystalCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Compass Fragment", CompassCrystalCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Compass Fragment");
							Construction_AddMaterial("crystal", -CompassCrystalCost, true);

							EmitSoundToAll("ui/chime_rd_2base_neg.wav");

							Rogue_GiveNamedArtifact("Dungeon Compass");
						}
					}
					case 2:
					{
						if(Rogue_HasNamedArtifact("Sealed Jalan Crate") && Construction_GetMaterial("crystal") >= unboxCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Sealed Jalan Crate", unboxCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Sealed Jalan Crate");
							Construction_AddMaterial("crystal", -unboxCost, true);

							Dungeon_RollNamedLoot("Rare Jalan Crate");
						}
					}
					case 3:
					{
						if(Rogue_HasNamedArtifact("Sealed Wizuh Crate") && Construction_GetMaterial("crystal") >= unboxCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Sealed Wizuh Crate", unboxCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Sealed Wizuh Crate");
							Construction_AddMaterial("crystal", -unboxCost, true);

							Dungeon_RollNamedLoot("Rare Wizuh Crate");
						}
					}
					case 4:
					{
						if(Rogue_HasNamedArtifact("Sealed Ossunia Crate") && Construction_GetMaterial("crystal") >= unboxCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Sealed Ossunia Crate", unboxCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Sealed Ossunia Crate");
							Construction_AddMaterial("crystal", -unboxCost, true);

							Dungeon_RollNamedLoot("Rare Ossunia Crate");
						}
					}
					case 5:
					{
						if(Rogue_HasNamedArtifact("Sealed Bofazem Crate") && Construction_GetMaterial("crystal") >= unboxCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Sealed Bofazem Crate", unboxCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Sealed Bofazem Crate");
							Construction_AddMaterial("crystal", -unboxCost, true);

							Dungeon_RollNamedLoot("Bofazem Crate");
						}
					}
				}
			}
		}
	}
	return 0;
}
