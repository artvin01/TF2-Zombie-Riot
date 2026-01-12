#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"The Dispenser"
#define CONSTRUCT_RESOURCE1	"iron"
#define CONSTRUCT_COST1		(20 + (CurrentLevel * 20))
#define CONSTRUCT_MAXLVL	(ObjectDungeonCenter_Level() - 1)

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectDDispenser_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheModel("models/buildables/dispenser_lvl3_light.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_dispenser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_dispenser");
	build.Cost = 600;
	build.Health = 150;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDDispenser(client, vecPos, vecAng);
}

methodmap ObjectDDispenser < ObjectGeneric
{
	public ObjectDDispenser(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDDispenser npc = view_as<ObjectDDispenser>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/dispenser_lvl3_light.mdl", "1.0", "50", {26.0, 26.0, 67.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCThink[npc.index] = ClotThink;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

static void ClotThink(ObjectDDispenser npc)
{
	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.5;

	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(0.0,
	npc.index,
	npc.index,
	-1,
	_,
	350.0,
	_,
	_,
	true,
	99,
	false,
	_,
	DispenserExplode);
	b_NpcIsTeamkiller[npc.index] = false;
}

static void DispenserExplode(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if(GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		int level = GetTeam(entity) == TFTeam_Red ? CurrentLevel : Dungeon_GetRound();

		HealEntityGlobal(entity, victim, 5.0 + (level * 7.5), _, 0.5);
		if(victim <= MaxClients)
			TF2_AddCondition(victim, TFCond_InHealRadius, 0.6);
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 1 || LastGameTime != CurrentGame)
			{
				maxcount = 0;
				return false;
			}
		}

		maxcount = CurrentLevel >= CONSTRUCT_MAXLVL ? 2 : 1;
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

static void ClotShowInteractHud(ObjectGeneric npc, int client)
{
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%t", ObjectDungeonCenter_Level() < 3 ? "Upgrade Max Limited" : "Upgrade Max");
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
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	int amount1 = Construction_GetMaterial(CONSTRUCT_RESOURCE1);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n \n%d / %d %t", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%t", "Upgrade Building To", CurrentLevel + 2);
	menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
