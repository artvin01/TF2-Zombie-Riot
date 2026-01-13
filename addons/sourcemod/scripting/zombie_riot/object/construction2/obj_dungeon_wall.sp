#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL
#undef CONSTRUCT_DAMAGE
#undef CONSTRUCT_FIRERATE
#undef CONSTRUCT_RANGE
#undef CONSTRUCT_MAXCOUNT

#define CONSTRUCT_NAME		"Construct Health"
#define CONSTRUCT_RESOURCE1	"iron"
#define CONSTRUCT_COST1		(10 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	(1 + ObjectDungeonCenter_Level())
#define CONSTRUCT_MAXCOUNT	(24 + (level * 12))

static int NPCId1;
static int NPCId2;
static int NPCId3;
static int LastGameTime;
static int CurrentLevel;

void ObjectDWall_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheModel("models/props_hydro/metal_barrier01.mdl");

	NPCData data;
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;

	BuildingInfo build;
	build.Section = 3;

	strcopy(data.Name, sizeof(data.Name), "Small Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_wall1");
	data.Func = ClotSummon1;
	NPCId1 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_wall1");
	build.Cost = 200;
	build.Health = 700;
	build.HealthScaleCost = false;
	build.Cooldown = 1.0;
	build.Func = ClotCanBuild1;
	Building_Add(build);
	/*
	strcopy(data.Name, sizeof(data.Name), "Large Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_wall2");
	data.Func = ClotSummon2;
	NPCId2 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_wall2");
	build.Cost = 350;
	build.Health = 1500;
	build.HealthScaleCost = false;
	build.Cooldown = 1.0;
	build.Func = ClotCanBuild2;
	Building_Add(build);

	strcopy(data.Name, sizeof(data.Name), "Extreme Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_wall3");
	data.Func = ClotSummon3;
	NPCId3 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_wall3");
	build.Cost = 500;
	build.Health = 2000;
	build.HealthScaleCost = false;
	build.Cooldown = 1.0;
	build.Func = ClotCanBuild3;
	Building_Add(build);
	*/
}

static any ClotSummon1(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDWall1(client, vecPos, vecAng);
}

methodmap ObjectDWall1 < ObjectGeneric
{
	public ObjectDWall1(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDWall1 npc = view_as<ObjectDWall1>(ObjectGeneric(client, vecPos, vecAng, "models/props_hydro/metal_barrier01.mdl", _, "600", {49.0, 49.0, 100.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild1;
		npc.m_bConstructBuilding = true;
		npc.m_bTransparrency = true;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

static bool ClotCanBuild1(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode())
			{
				maxcount = 0;
				return false;
			}
		}

		int level = CurrentLevel;
		maxcount = CONSTRUCT_MAXCOUNT;
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static any ClotSummon2(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDWall2(client, vecPos, vecAng);
}

methodmap ObjectDWall2 < ObjectGeneric
{
	public ObjectDWall2(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDWall2 npc = view_as<ObjectDWall2>(ObjectGeneric(client, vecPos, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.7", "600", {40.0, 40.0, 70.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild2;
		npc.m_bConstructBuilding = true;
		npc.m_bTransparrency = true;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);

		float VecLeft[3];
		VecLeft = vecPos;

		VecLeft[1] += 40.0;
		ObjectDWall2 npc_left = view_as<ObjectDWall2>(ObjectGeneric(client, VecLeft, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {40.0, 40.0, 70.0},_,false));
		npc.m_iExtrabuilding1 = npc_left.index;
		npc.m_bTransparrency = true;
		npc_left.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_left.index, "root",{0.0, 40.0, 0.0}, true);
		
		float Vecright[3];
		Vecright = vecPos;

		Vecright[1] -= 40.0;
		ObjectDWall2 npc_right = view_as<ObjectDWall2>(ObjectGeneric(client, Vecright, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {40.0, 40.0, 70.0},_,false));
		npc.m_iExtrabuilding2 = npc_right.index;
		npc.m_bTransparrency = true;
		npc_right.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_right.index, "root",{0.0, -40.0, 0.0}, true);

		TeleportEntity(npc.index, _, vecAng);

		return npc;
	}
}

static bool ClotCanBuild2(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!Dungeon_Mode() || CurrentLevel < 1)
		{
			maxcount = 0;
			return false;
		}

		int level = CurrentLevel;
		maxcount = CONSTRUCT_MAXCOUNT;
		if((count + 1) >= maxcount)
			return false;
	}
	
	return true;
}

static any ClotSummon3(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDWall3(client, vecPos, vecAng);
}

methodmap ObjectDWall3 < ObjectGeneric
{
	public ObjectDWall3(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

	//	ObjectDWall3 npc = view_as<ObjectDWall3>(ObjectGeneric(client, vecPos, vecAng, "models/props_hydro/metal_barrier03.mdl", "0.9", "600", {192.0, 192.0, 177.0},_,false));
		ObjectDWall3 npc = view_as<ObjectDWall3>(ObjectGeneric(client, vecPos, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild3;
		npc.m_bConstructBuilding = true;
		npc.m_bTransparrency = true;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);
		
		float VecLeft[3];
		VecLeft = vecPos;

		VecLeft[1] += 50.0;
		ObjectDWall3 npc_left = view_as<ObjectDWall3>(ObjectGeneric(client, VecLeft, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		npc.m_iExtrabuilding1 = npc_left.index;
		npc.m_bTransparrency = true;
		npc_left.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_left.index, "root",{0.0, 50.0, 0.0}, true);
		
		float Vecright[3];
		Vecright = vecPos;

		Vecright[1] -= 50.0;
		ObjectDWall3 npc_right = view_as<ObjectDWall3>(ObjectGeneric(client, Vecright, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		npc.m_iExtrabuilding2 = npc_right.index;
		npc.m_bTransparrency = true;
		npc_right.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_right.index, "root",{0.0, -50.0, 0.0}, true);

		TeleportEntity(npc.index, _, vecAng);

		return npc;
	}
}

static bool ClotCanBuild3(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!Dungeon_Mode() || CurrentLevel < 3)
		{
			maxcount = 0;
			return false;
		}

		int level = CurrentLevel;
		maxcount = CONSTRUCT_MAXCOUNT;
		if((count + 2) >= maxcount)
			return false;
	}
	
	return true;
}

bool ObjectDWall_IsId(int id)
{
	if(NPCId1 == id)
		return true;
	
	if(NPCId2 == id)
		return true;
	
	if(NPCId3 == id)
		return true;
	
	return false;
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
		ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
		if(IsValidEntity(objstats.m_iMasterBuilding))
			continue;

		if(NPCId1 == i_NpcInternalId[entity])
			count++;
		
		if(NPCId2 == i_NpcInternalId[entity])
			count += 2;
		
		if(NPCId3 == i_NpcInternalId[entity])
			count += 3;
	}

	return count;
}

int ObjectDWall_UpgradeLevel()
{
	if(LastGameTime != CurrentGame)
	{
		CurrentLevel = 0;
		LastGameTime = CurrentGame;
	}

	return CurrentLevel;
}

static void ClotShowInteractHud(ObjectGeneric npc, int client)
{
	char viality[64];
	BuildingVialityDisplay(client, npc.index, viality, sizeof(viality));

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%s\n%t", viality, ObjectDungeonCenter_Level() < ObjectDungeonCenter_MaxLevel() ? "Upgrade Max Limited" : "Upgrade Max");
	}
	else
	{
		SetGlobalTransTarget(client);

		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%s\n%t", viality, "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL + 1, button);
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

	int level = CurrentLevel;
	float healthPre = 1000.0 * Construction_GetMaxHealthMulti(1.0, level);
	int countPre = CONSTRUCT_MAXCOUNT;

	level = CurrentLevel + 1;
	float healthPost = 1000.0 * Construction_GetMaxHealthMulti(1.0, level);
	int countPost = CONSTRUCT_MAXCOUNT;
	
	char buffer[64];

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		menu.SetTitle("%t\n%.0f Health\n%d Supply", CONSTRUCT_NAME, healthPre, countPre);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%t\n%.0f (+%.0f) Health\n%d (+%d) Supply\n ", CONSTRUCT_NAME, healthPre, healthPost - healthPre, countPre, countPost - countPre);

		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t", "Upgrade Building To", CurrentLevel + 2, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);
		menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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

				float healthPre = Construction_GetMaxHealthMulti(1.0);
				CurrentLevel++;
				float healthPost = Construction_GetMaxHealthMulti(1.0);
				
				float multi = healthPost / healthPre;
				
				int entity = -1;
				while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
				{
					if(GetTeam(entity) != TFTeam_Red)
						continue;
					
					ObjectGeneric obj = view_as<ObjectGeneric>(entity);
					if(obj.m_bConstructBuilding)
					{
						int currentMax = GetEntProp(obj.index, Prop_Data, "m_iMaxHealth");
						int newMax = RoundFloat(currentMax * multi);
						SetEntProp(obj.index, Prop_Data, "m_iMaxHealth", newMax);
						SetEntProp(obj.index, Prop_Data, "m_iHealth", GetEntProp(obj.index, Prop_Data, "m_iHealth") + (newMax - currentMax));

						currentMax = GetEntProp(obj.index, Prop_Data, "m_iRepairMax");
						newMax = RoundFloat(currentMax * multi);
						SetEntProp(obj.index, Prop_Data, "m_iRepairMax", newMax);
						SetEntProp(obj.index, Prop_Data, "m_iRepair", GetEntProp(obj.index, Prop_Data, "m_iRepair") + (newMax - currentMax));
					}
				}
			}
		}
	}
	return 0;
}
