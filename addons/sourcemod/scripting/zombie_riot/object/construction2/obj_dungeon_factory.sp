#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"Vehicle Factory"
#define CONSTRUCT_RESOURCE1	"iron"
#define CONSTRUCT_COST1		(60 + (CurrentLevel * 60))
#define CONSTRUCT_MAXLVL	2

static const char Vehicles[][] =
{
	"vehicle_fulljeep",
	"vehicle_ambulance",
	"vehicle_fullapc"
};

static int NPCId;
static int LastGameTime;
static int CurrentLevel;
static float GlobalCooldown;

void ObjectDFactory_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;
	GlobalCooldown = 0.0;
	PrecacheModel("models/props_mvm/mann_hatch.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vehicle Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_factory");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_factory");
	build.Cost = 2000;
	build.Health = 100;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDFactory(client, vecPos, vecAng);
}

methodmap ObjectDFactory < ObjectGeneric
{
	public ObjectDFactory(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDFactory npc = view_as<ObjectDFactory>(ObjectGeneric(client, vecPos, vecAng, "models/props_mvm/mann_hatch.mdl", "0.5", "600", {80.0, 80.0, 16.0}));
		
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
		
		if(!CvarInfiniteCash.BoolValue || !Dungeon_Mode())
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
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		if(NPCId == i_NpcInternalId[entity])
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

static void ClotShowInteractHud(ObjectDFactory npc, int client)
{
	if(GlobalCooldown > GetGameTime())
	{
		if(GlobalCooldown - GetGameTime() >= 999999.9)
			PrintCenterText(client, "%t","Object Cooldown NextWave");
		else
			PrintCenterText(client, "%t","Object Cooldown",GlobalCooldown - GetGameTime());
	}
	else if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%t", "Upgrade Max");
	}
	else
	{
		SetGlobalTransTarget(client);

		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%t", "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL + 1, button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectGeneric npc)
{
	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	int amount1 = Construction_GetMaterial(CONSTRUCT_RESOURCE1);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	char buffer[64];
	if(CurrentLevel < CONSTRUCT_MAXLVL)
	{
		menu.SetTitle("%t\n \n%d / %d %t", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);

		FormatEx(buffer, sizeof(buffer), "%t\n ", "Upgrade Building To", CurrentLevel + 2);
		menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else
	{
		menu.SetTitle("%t", CONSTRUCT_NAME);
		menu.AddItem(buffer, buffer, ITEMDRAW_SPACER); 
	}

	Format(buffer, sizeof(buffer), "%t", "Crouch and select to view description Alone");
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	for(int a; a < 2; a++)
	{
		for(int b; b < sizeof(Vehicles); b++)
		{
			NPC_GetNameByPlugin(Vehicles[b], buffer, sizeof(buffer));
			Format(buffer, sizeof(buffer), "%t (%s)", buffer, a ? "Raiding" : "Defense");
			
			int minLevel = a ? 1 : 0;
			if(minLevel < b)
				minLevel = b;
			
			if(CurrentLevel < minLevel)
				Format(buffer, sizeof(buffer), "%s [Lv %d]", buffer, minLevel + 1);
			
			if(b == (sizeof(Vehicles) - 1))
				StrCat(buffer, sizeof(buffer), "\n ");

			menu.AddItem(Vehicles[b], buffer, CurrentLevel < minLevel ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}
	}

	menu.Pagination = 0;
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
			if(!choice)
			{
				if(GetClientButtons(client) & IN_DUCK)
				{
					PrintToChat(client, "%T", CONSTRUCT_NAME ... " Desc", client);
					ThisBuildingMenu(client);
				}
				else if(CurrentLevel < CONSTRUCT_MAXLVL && Construction_GetMaterial(CONSTRUCT_RESOURCE1) >= CONSTRUCT_COST1)
				{
					CPrintToChatAll("%t", "Player Used 1 to", client, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);
					CPrintToChatAll("%t", "Upgraded Building To", CONSTRUCT_NAME, CurrentLevel + 2);

					Construction_AddMaterial(CONSTRUCT_RESOURCE1, -CONSTRUCT_COST1, true);

					EmitSoundToAll("ui/chime_rd_2base_pos.wav");

					CurrentLevel++;
					ThisBuildingMenu(client);
				}
			}
			else
			{
				char buffer1[64], buffer2[64];
				menu.GetItem(choice, buffer1, sizeof(buffer1), _, buffer2, sizeof(buffer2));
				
				if(!(GetClientButtons(client) & IN_DUCK))
				{
					if(GlobalCooldown < GetGameTime())
					{
						DungeonZone spot = StrContains(buffer2, "Raid") == -1 ? Zone_HomeBase : Zone_RivalBase;

						float pos[3], ang[3];

						int entity = -1;
						while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
						{
							if(NPCId == i_NpcInternalId[entity])
							{
								if(Dungeon_GetEntityZone(entity) == spot)
								{
									GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
									GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
								}
							}
						}

						if(!pos[0])
						{
							entity = Dungeon_GetZoneMarker(spot);
							if(IsValidEntity(entity))
							{
								GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
								GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
							}
						}

						if(pos[0])
						{
							entity = -1;
							while((entity=FindEntityByClassname(entity, "obj_vehicle")) != -1)
							{
								DungeonZone zone = Dungeon_GetEntityZone(entity);
								if(zone == Zone_Unknown || zone == spot)
								{
									Vehicle_Exit(entity, false, true);
									RemoveEntity(entity);
								}
							}

							NPC_GetNameByPlugin(buffer1, buffer2, sizeof(buffer2));
							CPrintToChatAll("%t", "Spawned Vehicle At", client, buffer2, spot == Zone_HomeBase ? "Home Base" : "Base Raiding");

							GlobalCooldown = GetGameTime() + 300.0;
							
							pos[2] += 10.0;
							ang[1] += 90.0;
							NPC_CreateByName(buffer1, -1, pos, ang, TFTeam_Red);
							return 0;
						}
					}
				}
				
				char desc[64];
				NPC_GetNameByPlugin(buffer1, buffer2, sizeof(buffer2));
				FormatEx(desc, sizeof(desc), "%s Desc", buffer2);
				CPrintToChat(client, "%t", "Artifact Info", buffer2, desc);

				ThisBuildingMenu(client);
			}
		}
	}
	return 0;
}