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

#define CONSTRUCT_NAME		"Construct Altar"
#define CONSTRUCT_RESOURCE1	"iron"
#define CONSTRUCT_COST1		(10 + (CurrentLevel * 10))
#define CONSTRUCT_MAXLVL	(ObjectDungeonCenter_Level() * 3)
#define CONSTRUCT_DAMAGE	(3000.0 * Pow(level + 1.0, 1.25))	//SET ME
#define CONSTRUCT_FIRERATE	1.0
#define CONSTRUCT_RANGE		(7000.0 * Pow(level + 1.0, 1.25))	//HEALTH
#define CONSTRUCT_MAXCOUNT	(1)

static int NPCId;
static int LastGameTime;
static int CurrentLevel;
static int ConstructIndex;

void ObjectConst2_Altar_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;
	ConstructIndex = -1;

	PrecacheModel("models/props_barnblitz/track_switchbox_bb.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_altar");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_altar");
	build.Cost = 400;
	build.Health = 100;
	build.Cooldown = 20.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectConst2_Altar(client, vecPos, vecAng);
}

methodmap ObjectConst2_Altar < ObjectGeneric
{
	public ObjectConst2_Altar(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectConst2_Altar npc = view_as<ObjectConst2_Altar>(ObjectGeneric(client, vecPos, vecAng, "models/props_barnblitz/track_switchbox_bb.mdl", "2.0", "600", {35.0, 35.0, 30.0},_,false));
		
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = Dungeon_BuildingDeath;
		npc.m_bConstructBuilding = true;
		
		float vecPosnorm[3];
		vecPosnorm = vecPos;
		float vecAngnorm[3];
		vecAngnorm = vecAng;
		int spawn_index = NPC_CreateByName("npc_base_construct_defender", -1, vecPosnorm, vecAngnorm, TFTeam_Red);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			CClotBody npc1 = view_as<CClotBody>(spawn_index);
			npc1.m_iTargetAlly = npc.index;
			ConstructIndex = EntIndexToEntRef(spawn_index);
			int level = CurrentLevel;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToNearest(CONSTRUCT_RANGE));
			Const2UpdateAltarMinion();
		}
		
		SetRotateByDefaultReturn(npc.index, 90.0);

		return npc;
	}
}

int ObjectConst2_Altar_Level()
{
	return CurrentLevel;
}

int ObjectConst2_Altar_Health()
{
	int level = CurrentLevel;
	return RoundFloat(CONSTRUCT_RANGE);
}

float ObjectConst2_Altar_Damage()
{
	int level = CurrentLevel;
	return CONSTRUCT_DAMAGE;
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue)
		{
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 1)
			{
				maxcount = 0;
				return false;
			}
		}

		maxcount = CONSTRUCT_MAXCOUNT;
		if(count >= maxcount)
		{
			maxcount = 0;
			return false;
		}
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
		{
			count++;
		}
	}

	return count;
}

static void ClotShowInteractHud(ObjectConst2_Altar npc, int client)
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

static bool ClotInteract(int client, int weapon, ObjectConst2_Altar npc)
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
	float damagePre = CONSTRUCT_DAMAGE / CONSTRUCT_FIRERATE * DMGMULTI_CONST2_RED;
	float healthPre = CONSTRUCT_RANGE;

	level = CurrentLevel + 1;
	float damagePost = CONSTRUCT_DAMAGE / CONSTRUCT_FIRERATE * DMGMULTI_CONST2_RED;
	float healthPost = CONSTRUCT_RANGE;
	
	char buffer[256];
	FormatEx(buffer, sizeof(buffer), "%t", CONSTRUCT_NAME);

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
		Format(buffer, sizeof(buffer), "%s\n%.0f Health", buffer, healthPre);
	else
		Format(buffer, sizeof(buffer), "%s\n%.0f (+%.0f) Health", buffer, healthPre, healthPost - healthPre);

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
		Format(buffer, sizeof(buffer), "%s\n%.0f DPS", buffer, damagePre);
	else
		Format(buffer, sizeof(buffer), "%s\n%.0f (+%.0f) DPS", buffer, damagePre, damagePost - damagePre);

	Format(buffer, sizeof(buffer), "%s\n120s Revive Time", buffer);

	// Level 2
	if(CurrentLevel >= CONSTRUCT_MAXLVL && CurrentLevel == 0)
		Format(buffer, sizeof(buffer), "%s\n(+New Ability: Stomp [Knockback/Stun])", buffer);
	else if(CurrentLevel > 0)
		Format(buffer, sizeof(buffer), "%s\nAbility: Stomp [Knockback/Stun]", buffer);

	// Level 4
	if(CurrentLevel >= CONSTRUCT_MAXLVL && CurrentLevel == 2)
		Format(buffer, sizeof(buffer), "%s\n(+New Ability: Sword Slam [Knockback/Nuke])", buffer);
	else if(CurrentLevel > 2)
		Format(buffer, sizeof(buffer), "%s\nAbility: Sword Slam [Knockback/Nuke]", buffer);

	if(CurrentLevel >= CONSTRUCT_MAXLVL)
	{
		menu.SetTitle(buffer);

		FormatEx(buffer, sizeof(buffer), "Level %d", CurrentLevel + 1);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	else
	{
		menu.SetTitle("%s\n ", buffer);

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
				Const2UpdateAltarMinion();
			}
		}
	}
	return 0;
}

void Const2UpdateAltarMinion()
{
	int iNpc = EntRefToEntIndex(ConstructIndex);
	if(!IsValidEntity(iNpc))
		return;

	//update max health
	int level = CurrentLevel;
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToNearest(CONSTRUCT_RANGE));
}

float Const2AltarDamageGet()
{
	int level = CurrentLevel;
	return CONSTRUCT_DAMAGE;
}

int Const2AltarGetLevel()
{
	return CurrentLevel + 1;
}