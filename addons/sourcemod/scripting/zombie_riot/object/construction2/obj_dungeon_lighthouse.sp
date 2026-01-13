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

#define CONSTRUCT_NAME		"Giant Lighthouse"
#define CONSTRUCT_RESOURCE1	"iron"
#define CONSTRUCT_COST1		30
#define CONSTRUCT_MAXLVL	(ObjectDungeonCenter_Level() - 1)
#define CONSTRUCT_RANGE		2000.0
#define CONSTRUCT_MAXCOUNT	(1 + level)

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectDLightHouse_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheModel("models/props_sunshine/lighthouse_blu_bottom.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_lighthouse");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_lighthouse");
	build.Cost = 1000;
	build.Health = 125;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

stock int ObjectDLightHouse_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDLightHouse(client, vecPos, vecAng);
}

methodmap ObjectDLightHouse < ObjectGeneric
{
	public ObjectDLightHouse(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDLightHouse npc = view_as<ObjectDLightHouse>(ObjectGeneric(client, vecPos, vecAng, "models/props_sunshine/lighthouse_blu_bottom.mdl", "0.3", "600",{30.0, 30.0, 80.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = Dungeon_BuildingDeath;
		npc.m_bConstructBuilding = true;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 2)
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

static void ClotThink(ObjectSentrygun npc)
{
	LighthouseGiveBuff(npc.index, CONSTRUCT_RANGE);
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

static void LighthouseGiveBuff(int iNpc, float range = 2000.0)
{
	b_NpcIsTeamkiller[iNpc] = true;
	float spawnLoc[3]; 	
	WorldSpaceCenter(iNpc, spawnLoc);
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	spawnLoc,
	range,
	_,
	_,
	true,
	99,
	false,
	_,
	LighthouseGiveBuffDo);
	b_NpcIsTeamkiller[iNpc] = false;
}

static void LighthouseGiveBuffDo(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		ApplyStatusEffect(entity, victim, "Lighthouse Enlightment", 1.0);
	}
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
	int countPre = CONSTRUCT_MAXCOUNT;

	level = CurrentLevel + 1;
	int countPost = CONSTRUCT_MAXCOUNT;
	
	char buffer[64];

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		menu.SetTitle("%t\n%.0f Range\n%d Supply", CONSTRUCT_NAME, CONSTRUCT_RANGE, countPre);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%t\n%.0f Range\n%d (+%d) Supply\n ", CONSTRUCT_NAME, CONSTRUCT_RANGE, countPre, countPost - countPre);

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

				CurrentLevel++;
			}
		}
	}
	return 0;
}
