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

#define CONSTRUCT_NAME		"Control Center"
#define CONSTRUCT_COST1		(30 + (CurrentLevel * 45))
#define CONSTRUCT_MAXLVL	3
#define CONSTRUCT_MAXCOUNT	1

static float BuffTimerLimited;

static const int Ending2CrystalCost = 1;
static const int CompassCrystalCost = 3;
static const int TreasureKeyCost = 10;
static const int UnboxCrystalCost = 10;

static int LastGameTime;
static int CurrentLevel;

static int NPCId;
void ObjectDungeonCenter_MapStart()
{
	LastGameTime = -1;
	CurrentLevel = 0;

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
/*
	BuildingInfo build;
	build.Section = 3;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_dungeon_center");
	build.Cost = 400;
	build.Health = 2000;
	build.Cooldown = 20.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
*/
}

int IsDungeonCenterId()
{
	return NPCId;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ObjectDungeonCenter(client, vecPos, vecAng ,data);
}

methodmap ObjectDungeonCenter < ObjectGeneric
{
	property bool m_bEnemyBase
	{
		public get()							{ return b_movedelay_walk[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_walk[this.index] = TempValueForProperty; }
	}
	public ObjectDungeonCenter(int client, const float vecPos[3], const float vecAng[3], const char[] data)
	{
		if(LastGameTime != CurrentGame)
		{
			CurrentLevel = 0;
			LastGameTime = CurrentGame;
		}

		ObjectDungeonCenter npc = view_as<ObjectDungeonCenter>(ObjectGeneric(client, vecPos, vecAng, "models/props_combine/masterinterface.mdl", _, "3000", {65.0, 65.0, 197.0},_,false));
		
		
		npc.m_bEnemyBase = false;
		if(StrContains(data, "enemy_base") != -1)
		{
			npc.m_bEnemyBase = true;
			func_NPCDeath[npc.index] = Dungeon_MainBuildingDeath;
		}
		else
		{
			npc.FuncShowInteractHud = ClotShowInteractHud;
			npc.FuncCanBuild = ClotCanBuild;
			func_NPCThink[npc.index] = ClotThink;
			func_NPCInteract[npc.index] = ClotInteract;
			BuffTimerLimited = GetGameTime() + 160.0;
			SetTeam(npc.index, TFTeam_Red);
		}
		npc.m_bConstructBuilding = true;
		npc.m_bCannotBePickedUp = true;

		return npc;
	}
}

static void ClotThink(ObjectDungeonCenter npc)
{
	if(BuffTimerLimited)
		StartingBaseBuffGiveBuff(npc.index);
	if(Dungeon_InSetup())
		HomebaseMomentumGiveBuff(npc.index);
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

int ObjectDungeonCenter_Level()
{
	return CurrentLevel;
}

int ObjectDungeonCenter_MaxLevel()
{
	return CONSTRUCT_MAXLVL;
}

bool ObjectDungeonCenter_Alive()
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
		if(NPCId == i_NpcInternalId[entity])
		{
			if(!IsValidEntity(view_as<ObjectGeneric>(entity).m_iConstructDeathModel))
				return true;
		}
	}

	return false;
}

static void ClotShowInteractHud(ObjectDungeonCenter npc, int client)
{
	char viality[64];
	BuildingVialityDisplay(client, npc.index, viality, sizeof(viality));

	char button[64];
	PlayerHasInteract(client, button, sizeof(button));
	PrintCenterText(client, "%s\n%sto view control and crafting options.", viality, button);
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
	int unboxCost = freeKey ? UnboxCrystalCost/2 : UnboxCrystalCost;

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d %t   %d %t\n%d %t   %d %t\n ", CONSTRUCT_NAME,
		wood, "Material wood",
		crystal, "Material crystal",
		iron, "Material iron",
		copper, "Material copper");

	char buffer[64];

	if(Rogue_HasNamedArtifact("Expidonsa Tech Chip"))
	{
		FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Craft Item", "Expidonsa Tech Chip", crystal, Ending2CrystalCost, "Material crystal");
		menu.AddItem("8", buffer, (crystal < Ending2CrystalCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else
	{
		if(CurrentLevel < CONSTRUCT_MAXLVL)
		{
			FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Upgrade Building To", CurrentLevel + 2, wood, CONSTRUCT_COST1, "Material wood");
			menu.AddItem("7", buffer, (wood < CONSTRUCT_COST1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}

		if(Rogue_HasNamedArtifact("Compass Fragment"))
		{
			FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Craft Item", "Dungeon Compass", crystal, CompassCrystalCost, "Material crystal");
			menu.AddItem("1", buffer, (crystal < CompassCrystalCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}

		if(Rogue_HasNamedArtifact("Key Fragment"))
		{
			FormatEx(buffer, sizeof(buffer), "%t\n%d / %d %t\n ", "Craft Item", "Treasure Key", crystal, TreasureKeyCost, "Material crystal");
			menu.AddItem("6", buffer, (crystal < TreasureKeyCost) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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
				int unboxCost = freeKey ? UnboxCrystalCost/2 : UnboxCrystalCost;

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

							EmitSoundToAll("ui/itemcrate_smash_rare.wav");

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

							EmitSoundToAll("ui/itemcrate_smash_rare.wav");

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

							EmitSoundToAll("ui/itemcrate_smash_rare.wav");

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

							EmitSoundToAll("ui/itemcrate_smash_rare.wav");

							Dungeon_RollNamedLoot("Bofazem Crate");
						}
					}
					case 6:
					{
						if(Rogue_HasNamedArtifact("Key Fragment") && Construction_GetMaterial("crystal") >= TreasureKeyCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Key Fragment", TreasureKeyCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Key Fragment");
							Construction_AddMaterial("crystal", -TreasureKeyCost, true);

							EmitSoundToAll("ui/chime_rd_2base_neg.wav");

							Rogue_GiveNamedArtifact("Treasure Key");
						}
					}
					case 7:
					{
						if(CurrentLevel < CONSTRUCT_MAXLVL && Construction_GetMaterial("wood") >= CONSTRUCT_COST1)
						{
							CPrintToChatAll("%t", "Player Used 1 to", client, CONSTRUCT_COST1, "Material wood");
							CPrintToChatAll("%t", "Upgraded Building To", CONSTRUCT_NAME, CurrentLevel + 2);

							Construction_AddMaterial("wood", -CONSTRUCT_COST1, true);

							EmitSoundToAll("ui/chime_rd_2base_pos.wav");

							CurrentLevel++;
						}
					}
					case 8:
					{
						if(Rogue_HasNamedArtifact("Expidonsa Tech Chip") && Construction_GetMaterial("crystal") >= Ending2CrystalCost)
						{
							CPrintToChatAll("%t", "Player Used 2 to", client, 1, "Expidonsa Tech Chip", Ending2CrystalCost, "Material crystal");
							
							Rogue_RemoveNamedArtifact("Expidonsa Tech Chip");
							Construction_AddMaterial("crystal", -Ending2CrystalCost, true);

							EmitSoundToAll("ui/chime_rd_2base_neg.wav");

							Rogue_GiveNamedArtifact("Expidonsa Tech Chip Install", true);
						}
					}
				}
			}
		}
	}
	return 0;
}




static void StartingBaseBuffGiveBuff(int iNpc)
{
	b_NpcIsTeamkiller[iNpc] = true;
	float spawnLoc[3]; 	
	WorldSpaceCenter(iNpc, spawnLoc);
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	spawnLoc,
	9999.9,
	_,
	_,
	false,
	99,
	false,
	_,
	StartingBaseBuffGiveBuffInternal);
	b_NpcIsTeamkiller[iNpc] = false;
}

static void StartingBaseBuffGiveBuffInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		float GiveBuffDuration = BuffTimerLimited - GetGameTime();
		if(GiveBuffDuration <= 0.0)
		{
			BuffTimerLimited = 0.0;
			return;
		}
		ApplyStatusEffect(entity, victim, "Starting Grace", GiveBuffDuration);
		GiveBuffDuration -= 60.0;
		if(GiveBuffDuration <= 0.0)
		{
			GiveBuffDuration = 0.0;
		}
		ApplyStatusEffect(entity, victim, "War Cry", GiveBuffDuration);
		ApplyStatusEffect(entity, victim, "Defensive Backup", GiveBuffDuration);
	}
}
static void HomebaseMomentumGiveBuff(int iNpc)
{
	b_NpcIsTeamkiller[iNpc] = true;
	float spawnLoc[3]; 	
	WorldSpaceCenter(iNpc, spawnLoc);
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	spawnLoc,
	9999.9,
	_,
	_,
	true,
	99,
	false,
	_,
	HomebaseMomentumInternal);
	b_NpcIsTeamkiller[iNpc] = false;
}
static void HomebaseMomentumInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		ApplyStatusEffect(entity, victim, "Homebase Momentum", 0.5);
	}
}


// "Homebase Momentum"