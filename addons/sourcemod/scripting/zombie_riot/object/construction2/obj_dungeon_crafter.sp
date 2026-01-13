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

#define CONSTRUCT_NAME		"Packing Station"
#define CONSTRUCT_RESOURCE1	"wood"
#define CONSTRUCT_RESOURCE2	"crystal"
#define CONSTRUCT_COST1		20
#define CONSTRUCT_COST2		2
#define CONSTRUCT_MAXCOUNT	1

enum
{
	Pack_None = -1,

	Pack_Discount = 0,
	Pack_Damage,
	Pack_FireRate,
	Pack_Reload,
	Pack_Defensive,
	Pack_Offensive,

	Pack_MAX
}

static const char PackName[][] =
{
	"Clearance Focus",
	"Power Focus",
	"Handling Focus",
	"Refreshing Focus",
	"Defensive Focus",
	"Offensive Focus",
};

static int NPCId;
static float GlobalCooldown;
static int LastGameTime;

static IntMap WeaponPacked;

void ObjectGemCrafter_MapStart()
{
	LastGameTime = -2;
	delete WeaponPacked;

	bool failed;

	char buffer[64];
	for(int i; i < sizeof(PackName); i++)
	{
		if(FailTranslation(PackName[i]))
			failed = true;
		
		FormatEx(buffer, sizeof(buffer), "%s Desc", PackName[i]);
		if(FailTranslation(buffer))
			failed = true;
	}

	if(failed)
		return;

	PrecacheModel("models/props_spytech/computer_low.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), CONSTRUCT_NAME);
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_dungeon_crafter");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_crafter");
	build.Cost = 400;
	build.Health = 100;
	build.Cooldown = 20.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectGemCrafter(client, vecPos, vecAng);
}

methodmap ObjectGemCrafter < ObjectGeneric
{
	public ObjectGemCrafter(int client, const float vecPos[3], const float vecAng[3])
	{
		if(LastGameTime != CurrentGame)
		{
			delete WeaponPacked;
			LastGameTime = CurrentGame;
		}

		ObjectGemCrafter npc = view_as<ObjectGemCrafter>(ObjectGeneric(client, vecPos, vecAng, "models/props_spytech/computer_low.mdl", _, "600", {25.0, 25.0, 65.0}));
		
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = Dungeon_BuildingDeath;
		npc.m_bConstructBuilding = true;
		
		SetRotateByDefaultReturn(npc.index, 90.0);

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
			if(!Dungeon_Mode() || ObjectDungeonCenter_Level() < 1)
			{
				maxcount = 0;
				return false;
			}
		}

		maxcount = CONSTRUCT_MAXCOUNT;
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
		{
			count++;
		}
	}

	return count;
}

static bool ClotCanUse(ObjectGemCrafter npc, int client)
{
	if(GlobalCooldown > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectGemCrafter npc, int client)
{
	char viality[64];
	BuildingVialityDisplay(client, npc.index, viality, sizeof(viality));

	if(GlobalCooldown > GetGameTime())
	{
		PrintCenterText(client, "%s\n%t", viality, "Object Cooldown", GlobalCooldown - GetGameTime());
	}
	else
	{
		char button[64];
		PlayerHasInteract(client, button, sizeof(button));
		PrintCenterText(client, "%s\n%sto pack weapons using materials.", viality, button);
	}
}

static bool ClotInteract(int client, int weapon, ObjectGemCrafter npc)
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
	if(LastGameTime != CurrentGame)
	{
		delete WeaponPacked;
		LastGameTime = CurrentGame;
	}

	int amount1 = Construction_GetMaterial(CONSTRUCT_RESOURCE1);
	int amount2 = Construction_GetMaterial(CONSTRUCT_RESOURCE2);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d / %d %t\n%d / %d %t\n ", CONSTRUCT_NAME, amount1, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1, amount2, CONSTRUCT_COST2, "Material " ... CONSTRUCT_RESOURCE2);

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%t", "Pack Random Weapon");
	menu.AddItem(buffer, buffer, (amount1 < CONSTRUCT_COST1) || (amount2 < CONSTRUCT_COST2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
			else if(GlobalCooldown < GetGameTime() && Construction_GetMaterial(CONSTRUCT_RESOURCE1) >= CONSTRUCT_COST1 && Construction_GetMaterial(CONSTRUCT_RESOURCE2) >= CONSTRUCT_COST2)
			{
				GlobalCooldown = GetGameTime() + 120.0;

				CPrintToChatAll("%t", "Player Used 2 to", client, CONSTRUCT_COST1, "Material " ... CONSTRUCT_RESOURCE1, CONSTRUCT_COST2, "Material " ... CONSTRUCT_RESOURCE2);
				
				Construction_AddMaterial(CONSTRUCT_RESOURCE1, -CONSTRUCT_COST1, true);
				Construction_AddMaterial(CONSTRUCT_RESOURCE2, -CONSTRUCT_COST2, true);

				EmitSoundToAll("ui/chime_rd_2base_neg.wav");

				ApplyRandomEffect();
			}
		}
	}
	return 0;
}

static void ApplyRandomEffect()
{
	int index = -1;
	char buffer1[64];
	static Item item;
	static ItemInfo info;

	// Only a chance to grab a weapon someone actually owns
	if((GetURandomInt() % 2) == 0)
	{
		ArrayList list = new ArrayList();

		int owned, scale, equip, sell, hidden;

		for(int client = 1; client <= MaxClients; client++)
		{
			if(b_HasBeenHereSinceStartOfWave[client] && IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				for(int i; Store_GetNextItem(client, i, owned, scale, equip, sell, buffer1, sizeof(buffer1), hidden); i++)
				{
					if(owned && !hidden && sell > 0 && list.FindValue(i) == -1)
					{
						if(Store_GetItemData(i, item, info) && ValidWeapon(i, info))
							list.Push(i);
					}
				}
			}
		}
		
		int length = list.Length;
		if(length)
			index = list.Get(GetURandomInt() % length);

		delete list;
	}

	if(index == -1)
	{
		ArrayList list = new ArrayList();

		for(int i; Store_GetItemData(i, item, info); i++)
		{
			if(ValidWeapon(i, info))
				list.Push(i);
		}
		
		int length = list.Length;
		if(length)
			index = list.Get(GetURandomInt() % length);

		delete list;
	}

	if(index == -1)
	{
		PrintToChatAll("NOTHING????!??!");
		return;
	}

	int type = GetURandomInt() % Pack_MAX;

	if(!WeaponPacked)
		WeaponPacked = new IntMap();
	
	WeaponPacked.SetValue(index, type);

	Store_GetItemData(index, item, info);

	char buffer2[64];
	FormatEx(buffer1, sizeof(buffer1), "%s Desc", PackName[type]);
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			TranslateItemName(client, item.Name, info.Custom_Name, buffer2, sizeof(buffer2));
			CPrintToChat(client, "%t", "Weapon Has Packed", buffer2, PackName[type], buffer1);
		}
	}

	switch(type)
	{
		case Pack_Discount:
			Store_DiscountNamedItem(item.Name, 999, 0.7);
	}
}

static bool ValidWeapon(int index, ItemInfo info)
{
	return info.Cost_Unlock > 0 && info.Cost_Unlock < 99999 && info.Classname[0] && !GemCrafter_HasEffect(index);
}

bool GemCrafter_HasEffect(int index)
{
	if(WeaponPacked)
		return WeaponPacked.ContainsKey(index);
	
	return false;
}

void GemCrafter_ExtraDesc(int client, int index)
{
	if(WeaponPacked)
	{
		int type = -1;
		if(WeaponPacked.GetValue(index, type) && type >= 0)
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "%s Desc", PackName[type]);

			SetGlobalTransTarget(client);
			CPrintToChat(client, "{yellow}%t\n%t", PackName[type], buffer);
		}
	}
}

void GemCrafter_Enable(int client, int weapon)
{
	if(WeaponPacked && client)
	{
		int type = -1;
		if(WeaponPacked.GetValue(StoreWeapon[weapon], type))
		{
			ApplyPackAttribs(type, weapon);
		}
	}
}

static void ApplyPackAttribs(int type, int weapon)
{
	switch(type)
	{
		case Pack_Damage:
		{
			if(Attributes_Has(weapon, 2))
				Attributes_SetMulti(weapon, 2, 1.2);
			
			if(Attributes_Has(weapon, 8))
				Attributes_SetMulti(weapon, 8, 1.2);
		}
		case Pack_FireRate:
		{
			if(Attributes_Has(weapon, 6))
			{
				Attributes_SetMulti(weapon, 6, 1.0 / 1.2);
			}
			else
			{
				ApplyPackAttribs(Pack_Damage, weapon);
			}
		}
		case Pack_Reload:
		{
			if(Attributes_Has(weapon, 97))
			{
				Attributes_SetMulti(weapon, 97, 1.0 / 1.2);
			}
			else if(Attributes_Has(weapon, 733))
			{
				Attributes_SetMulti(weapon, 733, 1.0 / 1.2);
			}
			else
			{
				ApplyPackAttribs(Pack_FireRate, weapon);
			}
		}
		case Pack_Defensive, Pack_Offensive:
		{
			if(Dungeon_InSetup() == (type == Pack_Defensive))
			{
				if(Attributes_Has(weapon, 2))
					Attributes_SetMulti(weapon, 2, 1.4);
				
				if(Attributes_Has(weapon, 8))
					Attributes_SetMulti(weapon, 8, 1.4);
			}
		}
	}
}
