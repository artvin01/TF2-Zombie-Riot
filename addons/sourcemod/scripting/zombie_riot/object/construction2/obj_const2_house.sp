#pragma semicolon 1
#pragma newdecls required

#undef CONSTRUCT_NAME
#undef CONSTRUCT_RESOURCE1
#undef CONSTRUCT_RESOURCE2
#undef CONSTRUCT_COST1
#undef CONSTRUCT_COST2
#undef CONSTRUCT_MAXLVL

#define CONSTRUCT_NAME		"House"
#define CONSTRUCT_RESOURCE1	"copper"
#define CONSTRUCT_COST1		((5 + (CurrentLevel * 5)) * (CurrentLevel > 3 ? 2 : 1))
#define CONSTRUCT_MAXLVL	8

static const char NPCModel[] = "models/props_farm/wood_shack001.mdl";
// 310 total cost

static int NPCId;
static int LastGameTime;
static int CurrentLevel;

void ObjectC2House_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

	PrecacheModel(NPCModel);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const2_house");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const2_house");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectC2House(client, vecPos, vecAng);
}

methodmap ObjectC2House < ObjectGeneric
{

	public ObjectC2House(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectC2House npc = view_as<ObjectC2House>(ObjectGeneric(client, vecPos, vecAng, NPCModel, "0.65", "50", {25.0, 25.0, 60.0},_,false));

		float flPos[3]; // original

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectC2House_ClotThink;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

void ObjectC2House_ClotThink(ObjectC2House npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;

	if(npc.m_flNextMeleeAttack > gameTime)
	{
		return;
	}
	npc.m_flNextMeleeAttack = gameTime + 0.5;

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

		maxcount = CurrentLevel > 4 ? 2 : 1;
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
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}


static void ClotShowInteractHud(ObjectGeneric npc, int client)
{
	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		PrintCenterText(client, "%t", "Upgrade Max");
	}
	else
	{
		SetGlobalTransTarget(client);

		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%t", "Upgrade Using Materials", CurrentLevel + 1, CONSTRUCT_MAXLVL, button);
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

	menu.SetTitle("%t\n%d / %d %t\n ", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1);

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