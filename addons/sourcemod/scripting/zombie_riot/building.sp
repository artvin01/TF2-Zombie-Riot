#pragma semicolon 1
#pragma newdecls required

#define SOUND_GRAB_TF "ui/item_default_pickup.wav"      // grab
#define SOUND_TOSS_TF "ui/item_default_drop.wav"        // throww
#define MODEL_HEALINGBOLT "models/weapons/w_models/w_repair_claw.mdl"        // throww
#define SOUND_HOSE_HEALED		"weapons/rescue_ranger_charge_01.wav"

#define CLAW_TRAIL_RED "effects/repair_claw_trail_red.vmt"
static const char SectionName[][] =
{
	"Support Buildings",
	"Unique Buildings",
	"Construct Buildings"
};

enum struct BuildingInfo
{
	int Section;
	char Plugin[64];
	int Cost;
	int Health;
	bool HealthScaleCost;
	float Cooldown;
	Function Func;
	float Cooldowns[MAXPLAYERS];
}

static ArrayList BuildingList;
static Function BuildingFuncSave[MAXENTITIES];
static float GrabThrottle[MAXENTITIES];
static int MenuSection[MAXPLAYERS] = {-1, ...};
static int MenuPage[MAXPLAYERS];
static Handle MenuTimer[MAXPLAYERS];
static int Player_BuildingBeingCarried[MAXPLAYERS];
static float PlayerWasHoldingProp[MAXPLAYERS];
float PreventSameFrameActivation[2][MAXPLAYERS];
int RandomIntSameRequestFrame[MAXPLAYERS];

bool BuildingIsSupport(int entity)
{
	if(BuildingFuncSave[entity] == ObjectGeneric_CanBuild)
		return true;

	return false;
}
int Building_HasThisBuilding(int entity)
{
	return i_IDependOnThisBuilding[entity];
}

int Building_OnThisBuilding(int entity)
{
	for(int i = 0; i < MAXENTITIES; i++)
	{
		if(!IsValidEntity(i))
			continue;
			
		if(EntRefToEntIndex(i_IDependOnThisBuilding[i]) == entity)
			return i;
	}

	return -1;
}
void ResetPlayer_BuildingBeingCarried(int client)
{
	Player_BuildingBeingCarried[client] = 0;
}
bool IsPlayerCarringObject(int client)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
		return true;
	if(PlayerWasHoldingProp[client] > GetGameTime())
		return true;
		
	return false;
}
bool BuildingIsBeingCarried(int buildingindx)
{
	if(IsValidEntity(Building_BuildingBeingCarried[buildingindx]))
		return true;
		
	return false;
}
#define MAX_CASH_VIA_BUILDINGS 5000
#define MAX_SUPPLIES_EACH_WAVE 10
static float f_GiveAmmoSupplyFacture[MAXPLAYERS];
static int i_GiveAmmoSupplyLimit[MAXPLAYERS];
static int i_GiveCashBuilding[MAXPLAYERS];

//dont do this on disconnect!
void Building_ResetRewardValues(int client)
{
	f_GiveAmmoSupplyFacture[client] = 0.0;
	i_GiveAmmoSupplyLimit[client] = 0;
	i_GiveCashBuilding[client] = 0;
}

void Building_ResetRewardValuesWave()
{
	Zero(i_GiveAmmoSupplyLimit);
}

void Building_GiveRewardsUse(int client, int trueOwner, int Cash, bool CashLimit = true, float AmmoSupply = 0.0, bool SupplyLimit = true)
{
	int owner = trueOwner;
	if(owner > MaxClients)
		owner = client;
	
	//when using your own buildings, you get half as much.
	if(client == owner)
	{
		Cash /= 2;
		AmmoSupply *= 0.5;
	}
	
	AmmoSupply *= 0.65;
	if(CashLimit)
	{
		//affected by limit.
		int MaxCashBuildings = MAX_CASH_VIA_BUILDINGS;
		MaxCashBuildings += RoundToNearest(Attributes_GetOnPlayer(owner, Attrib_ExtendExtraCashGain, false, _,0.0));
		//max cash overall should be 50000
		int MaxBuildingCashAllow = CurrentCash / 7;
		if(MaxBuildingCashAllow <= 1000)
			MaxBuildingCashAllow = 1000;

		if(MaxBuildingCashAllow >= MaxCashBuildings)
			MaxBuildingCashAllow = MaxCashBuildings;

		if(i_GiveCashBuilding[owner] < MaxBuildingCashAllow)
		{
			Native_OnGivenCash(owner, Cash);
			i_GiveCashBuilding[owner] += Cash;
			GiveCredits(owner, Cash, true);
		}
	}
	else
	{
		//This building doesnt affect the limit.
		Native_OnGivenCash(owner, Cash);
		CashReceivedNonWave[owner] += Cash;
		CashSpent[owner] -= Cash;
	}
	if(AmmoSupply <= 0.0)
	{
		return;
	}
	int ConvertedAmmoSupplyGive;
	ConvertedAmmoSupplyGive = RoundToFloor(AmmoSupply);
	float Decimal_Ammo = FloatFraction(AmmoSupply);

	f_GiveAmmoSupplyFacture[owner] += Decimal_Ammo;
						
	while(f_GiveAmmoSupplyFacture[owner] >= 1.0)
	{
		f_GiveAmmoSupplyFacture[owner] -= 1.0;
		ConvertedAmmoSupplyGive += 1;
	}
	if(ConvertedAmmoSupplyGive <= 0)
		return;
		
	Resupplies_Supplied[trueOwner] += ConvertedAmmoSupplyGive;
	Resupplies_Supplied[owner] += ConvertedAmmoSupplyGive;
	if(SupplyLimit)
	{
		if(i_GiveAmmoSupplyLimit[owner] < MAX_SUPPLIES_EACH_WAVE)
		{
			i_GiveAmmoSupplyLimit[owner] += ConvertedAmmoSupplyGive;
			Ammo_Count_Used[owner] -= ConvertedAmmoSupplyGive;
		}
	}
	else
	{
		Ammo_Count_Used[owner] -= ConvertedAmmoSupplyGive;
	}

}

float f_ExpidonsanRepairDelay[MAXPLAYERS];
void Building_MapStart()
{
	PrecacheSound(SOUND_GRAB_TF, true);
	PrecacheSound(SOUND_TOSS_TF, true);
	Zero(GrabThrottle);
	Zero(PlayerWasHoldingProp);
	PrecacheSound("player/taunt_sorcery_fail.wav");
	PrecacheSound("physics/metal/metal_box_strain2.wav");
	PrecacheSound("physics/metal/metal_box_strain4.wav");
	PrecacheSound("npc/manhack/bat_away.wav");
	Zero(f_ExpidonsanRepairDelay);
	Zero(i_IDependOnThisBuilding);
	PrecacheModel(MODEL_HEALINGBOLT);
	PrecacheModel(CLAW_TRAIL_RED);
	PrecacheDecal(CLAW_TRAIL_RED, true);
	PrecacheSound(SOUND_HOSE_HEALED);
}

void Building_ClientDisconnect(int client)
{
	MenuSection[client] = -1;
	MenuPage[client] = 0;
}

// Called BEFORE NPC_ConfigSetup()
void Building_ConfigSetup()
{
	delete BuildingList;
	BuildingList = new ArrayList(sizeof(BuildingInfo));
}

int Building_Add(BuildingInfo info)
{
	return BuildingList.PushArray(info);
}

public void Building_OpenMenuWeapon(int client, int weapon, bool crit, int slot)
{
	MenuSection[client] = -1;
	MenuPage[client] = 0;
	//reset to main menu for easier quick access
	delete MenuTimer[client];
	BuildingMenu(client);
}

static bool HasWrench(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
		return false;
	
	if(EntityFuncAttack2[weapon] != Building_OpenMenuWeapon &&
	   EntityFuncAttack3[weapon] != Building_OpenMenuWeapon)
		return false;

	return true;
}

static int GetCost(int client, BuildingInfo info/*, float multi*/)
{
	int buildCost = info.Cost;
	if(info.HealthScaleCost)//if(id <= 1 || id == 12)
	{
		/*
		int cost_extra = RoundFloat(info.Health * multi / 2.4);
		if(cost_extra <= 0)
		{
			cost_extra = 0;
		}
		buildCost = buildCost + cost_extra;
		*/
		if(!Waves_Started())
		{
			buildCost /= 3;
		}
		//only reduce off buildigns that actually cost more to build.
		ReduceMetalCost(client, buildCost);
	}


	if(Rogue_Mode())
		buildCost /= 3;

	return buildCost;
}

static void BuildingMenu(int client)
{
	if(MenuTimer[client])
		return;
	if(!HasWrench(client))
	{
		HideMenuInstantly(client);
		//show a blank page to instantly hide it
		CancelClientMenu(client);
		ClientCommand(client, "slot10");
		ResetStoreMenuLogic(client);
		return;
		//no wrench, die
	}
	
	int metal = GetAmmo(client, Ammo_Metal);
	int cash = CurrentCash - CashSpent[client];
	if(StarterCashMode[client])
	{
		int maxCash = StartCash;
		maxCash -= CashSpentLoadout[client];
		cash = maxCash;
	}
	//float multi = Object_GetMaxHealthMulti(client);
	float gameTime = GetGameTime();
	bool ducking = view_as<bool>(GetClientButtons(client) & IN_DUCK);

	SetGlobalTransTarget(client);

	static const int ItemsPerPage = 5;

	Menu menu = new Menu(BuildingMenuH);
	SetGlobalTransTarget(client);

	char buffer1[196], buffer2[64], buffer3[196];
	if(MenuSection[client] == -1)
		FormatEx(buffer3, sizeof(buffer3), "%T\n ", "Building Menu", client);
	else
		FormatEx(buffer3, sizeof(buffer3), "%T", "Building Menu", client);
		
	switch(MenuSection[client])
	{
		case -1:
		{
			Format(buffer3, sizeof(buffer3), "%s\n%T\n ", buffer3,"Mount Menu Explain", client);
		}
		case 0:
		{
			Format(buffer3, sizeof(buffer3), "%s\n%T\n ", buffer3,"Support Buildings Explain", client);
		}
		case 1:
		{
			Format(buffer3, sizeof(buffer3), "%s\n%T\n ", buffer3,"Unique Buildings Explain", client);
		}
		case 2:
		{
			Format(buffer1, sizeof(buffer1), "%s\n%T\n ", buffer3,"Construct Buildings Explain", client);
		}
	}
	menu.SetTitle("%s", buffer3);


	if(MenuSection[client] == -1 || !ducking)
	{
		FormatEx(buffer1, sizeof(buffer1), "%t [%d] ($%d)", "Scrap Metal", AmmoData[Ammo_Metal][1], AmmoData[Ammo_Metal][0]);
		menu.AddItem(buffer1, buffer1, cash < AmmoData[Ammo_Metal][0] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

		FormatEx(buffer1, sizeof(buffer1), "%t x10 [%d] ($%d)%s", "Scrap Metal", AmmoData[Ammo_Metal][1] * 10, AmmoData[Ammo_Metal][0] * 10, MenuSection[client] == -1 ? "" : "\n ");
		menu.AddItem(buffer1, buffer1, cash < (AmmoData[Ammo_Metal][0] * 10) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else
	{
		menu.AddItem(buffer1, buffer1, ITEMDRAW_DISABLED);
		menu.AddItem(buffer1, " \n", ITEMDRAW_DISABLED);
	}

	if(MenuSection[client] == -1)
	{
		FormatEx(buffer1, sizeof(buffer1), "%t\n ", "Destroy Building Select");
		menu.AddItem(buffer1, buffer1);

		for(int i; i < sizeof(SectionName); i++)
		{
			if(i == 2 && !Construction_Mode() && !Dungeon_Mode() && !CvarInfiniteCash.BoolValue)
				continue;

			
			FormatEx(buffer1, sizeof(buffer1), "%t", SectionName[i]);
			if(i == 2 && !Waves_Started() && !CvarInfiniteCash.BoolValue)
				menu.AddItem(buffer1, buffer1, ITEMDRAW_DISABLED);
			else
				menu.AddItem(buffer1, buffer1);
		}
	}
	else
	{
		bool corrupt = Rogue_HasNamedArtifact("System Malfunction");
		int items;

		BuildingInfo info;
		int length = BuildingList.Length;
		for(int i; i < length; i++)
		{
			BuildingList.GetArray(i, info);
			if(info.Section != MenuSection[client])
				continue;
			
			int cost = GetCost(client, info);
			int count;
			int maxcount = 99;
			bool allowed;
			
			float cooldown = info.Cooldowns[client] - gameTime;
			if(cooldown > 9999.9)
				continue;

			if(info.Func != INVALID_FUNCTION)
				allowed = Object_CanBuild(info.Func, client, count, maxcount);
			
			// Hide if maxcount is 0
			if(maxcount < 1)
				continue;
			
			// Add Items if they belong in that page
			if(items < (MenuPage[client] * ItemsPerPage) || items >= ((MenuPage[client] + 1) * ItemsPerPage))
			{
				items++;
				continue;
			}

			items++;

			if(corrupt)
			{
				// Visual glitching
				while(maxcount > 0 && (GetURandomInt() % 5) == 0)
				{
					maxcount--;
				}

				if((GetURandomInt() % 5) == 0)
				{
					cost *= 3;
				}

				if((GetURandomInt() % 5) == 0)
				{
					count = 0;
				}
			}

			if(cost > metal)
				allowed = false;
			
			if((Waves_InSetup() && !Construction_Mode() && !Dungeon_Mode()) || f_AllowInstabuildRegardless > GetGameTime())
			{
				cooldown = 0.0;
			}
			else if(cooldown > 0.0)
			{
				allowed = false;
			}

			NPC_GetNameByPlugin(info.Plugin, buffer1, sizeof(buffer1));

			if(EnableSilentMode)
			{
				if(StrContains(info.Plugin, "obj_barracks", false) != -1)
				{
					//ignore barracks if they didnt have it previously
					if(!(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES))
						continue;
				}
			}
			if(ducking)
			{
				FormatEx(buffer2, sizeof(buffer2), "%s Desc", buffer1);
				if(!TranslationPhraseExists(buffer2))
					strcopy(buffer2, sizeof(buffer2), buffer1);

				int alive = Object_NamedBuildings(_, info.Plugin);
				Format(buffer1, sizeof(buffer1), "{x%d} %t", alive, buffer2);
			}
			else if(cooldown > 0.0)
			{
				Format(buffer1, sizeof(buffer1), "%t (%.1fs) [%d/%d]", buffer1, RoundToCeil(cooldown * 2.0) / 2.0, count, maxcount);
			}
			else
			{
				Format(buffer1, sizeof(buffer1), "%t (%d %t) [%d/%d]", buffer1, cost, "Metal", count, maxcount);
			}

			IntToString(i, buffer2, sizeof(buffer2));
			menu.AddItem(buffer2, buffer1, allowed ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}

		if(menu.ItemCount < 3)
		{
			delete menu;
			//retry
			if(MenuPage[client] == 0)
				MenuSection[client] = -1;
			MenuPage[client] = 0;
			BuildingMenu(client);
			return;
		}

		for(int i = menu.ItemCount; i < 7; i++)
		{
			menu.AddItem(buffer2, buffer2, ITEMDRAW_SPACER);
		}
		
		if(MenuPage[client])
		{
			FormatEx(buffer2, sizeof(buffer2), "%t", "Previous");
			menu.AddItem(buffer2, buffer2);
		}
		else
		{
			FormatEx(buffer2, sizeof(buffer2), "%t", "Back");
			menu.AddItem(buffer2, buffer2);
		}
		
		if(items > ((MenuPage[client] + 1) * ItemsPerPage))
		{
			FormatEx(buffer2, sizeof(buffer2), "%t", "Next");
			menu.AddItem(buffer2, buffer2);
		}
	}

	menu.Pagination = 0;
	menu.ExitButton = true;

	if(menu.Display(client, 2))
		MenuTimer[client] = CreateTimer(0.5, Timer_RefreshMenu, client);

	AnyMenuOpen[client] = 1.0;
}

static int BuildingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Cancel:
		{
			delete MenuTimer[client];
			AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			delete MenuTimer[client];
			AnyMenuOpen[client] = 0.0;

			if(HasWrench(client))
			{
				if(MenuSection[client] == -1)
				{
					switch(choice)
					{
						case 0:
						{
							CashSpent[client] += AmmoData[Ammo_Metal][0];
							CashSpentTotal[client] += AmmoData[Ammo_Metal][0];
							CashSpentLoadout[client] += AmmoData[Ammo_Metal][0];
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							int ammo = GetAmmo(client, Ammo_Metal) + AmmoData[Ammo_Metal][1];
							SetAmmo(client, Ammo_Metal, ammo);
							CurrentAmmo[client][Ammo_Metal] = ammo;
						}
						case 1:
						{
							CashSpent[client] += AmmoData[Ammo_Metal][0] * 10;
							CashSpentTotal[client] += AmmoData[Ammo_Metal][0] * 10;
							CashSpentLoadout[client] += AmmoData[Ammo_Metal][0] * 10;
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							int ammo = GetAmmo(client, Ammo_Metal) + (AmmoData[Ammo_Metal][1] * 10);
							SetAmmo(client, Ammo_Metal, ammo);
							CurrentAmmo[client][Ammo_Metal] = ammo;
						}
						case 2:
						{
						//	BuilderMenu(client);
							if(IsValidClient(client))
							{
								DeleteBuildingLookedAt(client);
							}
							return 0;
						}
						default:
						{
							MenuSection[client] = choice - 3;
						}
					}
				}
				else
				{
					switch(choice)
					{
						case 0:
						{
							CashSpent[client] += AmmoData[Ammo_Metal][0];
							CashSpentTotal[client] += AmmoData[Ammo_Metal][0];
							CashSpentLoadout[client] += AmmoData[Ammo_Metal][0];
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							int ammo = GetAmmo(client, Ammo_Metal) + AmmoData[Ammo_Metal][1];
							SetAmmo(client, Ammo_Metal, ammo);
							CurrentAmmo[client][Ammo_Metal] = ammo;
						}
						case 1:
						{
							CashSpent[client] += AmmoData[Ammo_Metal][0] * 10;
							CashSpentTotal[client] += AmmoData[Ammo_Metal][0] * 10;
							CashSpentLoadout[client] += AmmoData[Ammo_Metal][0] * 10;
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							int ammo = GetAmmo(client, Ammo_Metal) + (AmmoData[Ammo_Metal][1] * 10);
							SetAmmo(client, Ammo_Metal, ammo);
							CurrentAmmo[client][Ammo_Metal] = ammo;
						}
						case 7:
						{
							if(MenuPage[client] == 0)
							{
								MenuSection[client] = -1;
							}
							else
							{
								MenuPage[client]--;
							}
						}
						case 8:
						{
							MenuPage[client]++;
						}
						default:
						{
							if(CanCreateBuilding(client))
							{
								char buffer[64];
								menu.GetItem(choice, buffer, sizeof(buffer));
								int id = StringToInt(buffer);

								BuildingInfo info;
								BuildingList.GetArray(id, info);

								int metal = GetAmmo(client, Ammo_Metal);
								int cost = GetCost(client, info);

								if(metal >= cost && (info.Func == INVALID_FUNCTION || Object_CanBuild(info.Func, client)))
								{
									float vecPos[3], vecAng[3];
									GetClientAbsOrigin(client, vecPos);
									GetClientEyeAngles(client, vecAng);
									vecAng[0] = 0.0;
									vecAng[2] = 0.0;

									int entity = BuildByInfo(info, client, vecPos, vecAng);
									if(entity != -1)
									{
										GiveBuildingMetalCostOnBuy(entity, cost);

										Building_PlayerWieldsBuilding(client, entity);
										Barracks_UpdateEntityUpgrades(entity, client, true, _);

										metal -= cost;
										SetAmmo(client, Ammo_Metal, metal);
										CurrentAmmo[client][Ammo_Metal] = metal;
										float CooldownGive = info.Cooldown;
										if(Rogue_Mode())
											CooldownGive *= 0.5;
										
										if(Items_HasNamedItem(client, "Builder's Blueprints"))
										{
											if(CooldownGive>1.0)
												CooldownGive-=1.0;
											else
												CooldownGive=0.0;
										}
										
										if(Construction_Mode())
											CooldownGive *= 3.0;
											
										UpdateDoublebuilding(entity);
										
										info.Cooldowns[client] = GetGameTime() + CooldownGive;
										BuildingList.SetArray(id, info);
									}
								}
							}
						}
					}
				}

				BuildingMenu(client);
			}
		}
	}

	return 0;
}

int Building_BuildByName(const char[] plugin, int client, float vecPos[3], float vecAng[3])
{
	int index = BuildingList.FindString(plugin, BuildingInfo::Plugin);
	if(index == -1)
		return index;
	
	BuildingInfo info;
	BuildingList.GetArray(index, info);
	return BuildByInfo(info, client, vecPos, vecAng);
}

static int BuildByInfo(BuildingInfo info, int client, float vecPos[3], float vecAng[3])
{
	int entity = NPC_CreateByName(info.Plugin, client, vecPos, vecAng, GetTeam(client));
	if(entity != -1)
	{
		ObjectGeneric obj = view_as<ObjectGeneric>(entity);
		BuildingFuncSave[entity] = info.Func;
		obj.BaseHealth = info.Health;
		int health = GetEntProp(obj.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(obj.index, Prop_Data, "m_iMaxHealth");
		float Multi = Object_GetMaxHealthMulti(client);
		int expected = RoundFloat(obj.BaseHealth * Multi);

		if(obj.m_bConstructBuilding && !info.HealthScaleCost)
		{
			expected = RoundFloat(obj.BaseHealth * Construction_GetMaxHealthMulti(Multi));
		}

		if(maxhealth && expected && maxhealth != expected)
		{
			float change = float(expected) / float(maxhealth);
			Attributes_Set(obj.index, 286, Multi);

			maxhealth = expected;
			health = RoundFloat(float(health) * change);
			int maxrepair = RoundFloat(float(GetEntProp(obj.index, Prop_Data, "m_iRepairMax")) * change);
			int repair = RoundFloat(float(GetEntProp(obj.index, Prop_Data, "m_iRepair")) * change);
			
			SetEntProp(obj.index, Prop_Data, "m_iMaxHealth", maxhealth);
			SetEntProp(obj.index, Prop_Data, "m_iHealth", health);
			SetEntProp(obj.index, Prop_Data, "m_iRepairMax", maxrepair);
			SetEntProp(obj.index, Prop_Data, "m_iRepair", repair);
		}
		SetTeam(obj.index, GetTeam(client));

		GiveBuildingMetalCostOnBuy(entity, 0);
	}

	return entity;
}

static bool CanCreateBuilding(int client)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
		return false;
	
	return true;
}

static Action Timer_RefreshMenu(Handle timer, int client)
{
	MenuTimer[client] = null;
	BuildingMenu(client);
	return Plugin_Stop;
}

void Barracks_UpdateAllEntityUpgrades(int client, bool first_upgrade = false, bool first_barracks = false)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if(IsValidEntity(i) && (i_IsABuilding[i] || !b_NpcHasDied[i])) //This isnt expensive.
		{
			BarrackBody npc = view_as<BarrackBody>(i);
			if(GetClientOfUserId(npc.OwnerUserId) == client && !b_NpcHasDied[i])
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
			else if(i_IsABuilding[i] && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == client)
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
		}
	}
}
	
void Building_ShowInteractionHud(int client, int entity)
{
	if(TeutonType[client] != TEUTON_NONE)
		return;
	
	bool Hide_Hud = true;
	if(dieingstate[client] < 1 && IsValidEntity(entity))
	{
		if(entity <= MaxClients)
		{
			if(dieingstate[entity] > 0 && IsPlayerAlive(client))
			{
				SetGlobalTransTarget(client);
				char ButtonDisplay[255];
				PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
				PrintCenterText(client, "%s%t", ButtonDisplay,"Revive Teammate tooltip");
				return;
			}
			entity = EntRefToEntIndex(Building_Mounted[entity]);
			if(!IsValidEntity(entity))
			{
				return;
			}
		}
		else if(!b_NpcHasDied[entity])
		{
			if(GetTeam(entity) == TFTeam_Red)
			{
				if(f_CooldownForHurtHud[client] < GetGameTime() && f_CooldownForHurtHud_Ally[client] < GetGameTime())
				{
					Calculate_And_Display_hp(client, entity, 0.0, true);
				}
			}

			switch(Citizen_ShowInteractionHud(entity, client))
			{
				case -1:
				{
					Hide_Hud = false;
				}
				case 1:
				{
				}
			}
		}
		else if(i_IsABuilding[entity])
		{
			//static char plugin[64];
			//NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			//if(StrContains(plugin, "obj_", false) != -1)
			{
				if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
				{
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					char ButtonDisplay[255];
					PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
					PrintCenterText(client, "%s%t", ButtonDisplay,"Claim this building");
				}
				else if(Building_Collect_Cooldown[entity][client] > GetGameTime())
				{
					float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
					
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					if(Building_Picking_up_cd >= 999999.9)
						PrintCenterText(client, "%t","Object Cooldown NextWave");
					else
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
				}
				else if(Object_ShowInteractHud(client, entity))
				{
					Hide_Hud = false;
				}
			}
		}
		else if(i_IsVehicle[entity] == 2)
		{
			if(Vehicle_ShowInteractHud(client, entity))
				Hide_Hud = false;
		}
	}

	if(Hide_Hud)
		PrintCenterText(client, "");
}

void BuildingVoteEndResetCD()
{
	Zero2(Building_Collect_Cooldown);
}
stock void ApplyBuildingCollectCooldown(int building, int client, float Duration, bool IgnoreVotingExtraCD = false)
{
	if(CvarInfiniteCash.BoolValue)
	{
		Building_Collect_Cooldown[building][client] = 0.0;
	}
	else if(GameRules_GetRoundState() == RoundState_BetweenRounds && !IgnoreVotingExtraCD)
	{
		Building_Collect_Cooldown[building][client] = FAR_FUTURE;
	}
	else
	{
		Building_Collect_Cooldown[building][client] = GetGameTime() + Duration;
	}
}

public void Pickup_Building_Multi(int client, int weapon, bool crit)
{
	if((GetClientButtons(client) & IN_DUCK)) //This shit only works sometimes, i blame tf2 for this.
	{
		MountBuildingToBack(client, weapon, crit);
		return;
	}
	Pickup_Building_M2(client, weapon, crit);
}

public void Pickup_Building_M2(int client, int weapon, bool crit)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
	{
		int buildingindx = EntRefToEntIndex(Player_BuildingBeingCarried[client]);
		Building_AttemptPlace(buildingindx, client);
		return;
	}
	int entity = GetClientPointVisible(client, 150.0 , false, false,_,1);
	if(entity <= MaxClients)	
		return;

	if (!IsValidEntity(entity))
		return;

	if (!i_IsABuilding[entity])
		return;

	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") <= MaxClients)
	{
		if(!objstats.m_bConstructBuilding)
			return; //anyone can pick up construct buildings!
	}
	if(IsValidEntity(objstats.m_iMasterBuilding))
	{
		entity = objstats.m_iMasterBuilding;
	}
	Building_PlayerWieldsBuilding(client, entity);
}
public void Pickup_Building_M2_InfRange(int client, int weapon, bool crit)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
	{
		int buildingindx = EntRefToEntIndex(Player_BuildingBeingCarried[client]);
		Building_AttemptPlace(buildingindx, client);
		return;
	}
	int entity = GetClientPointVisible(client, 9999.0 , false, false,_,1);
	if(entity <= MaxClients)	
		return;

	if (!IsValidEntity(entity))
		return;

	if (!i_IsABuilding[entity])
		return;

	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") <= MaxClients)
	{
		if(!objstats.m_bConstructBuilding)
			return; //anyone can pick up construct buildings!
	}
	if(IsValidEntity(objstats.m_iMasterBuilding))
	{
		entity = objstats.m_iMasterBuilding;
	}
	Building_PlayerWieldsBuilding(client, entity);
}

/*

	if(f3_CustomMinMaxBoundingBoxMinExtra[client][2])
		endPos[2] -= f3_CustomMinMaxBoundingBoxMinExtra[client][2];
*/
bool Building_AttemptPlace(int buildingindx, int client, bool TestClient = false, float AbsOriginOffset = 0.0)
{
	float VecPos[3];
	GetEntPropVector(buildingindx, Prop_Data, "m_vecAbsOrigin", VecPos);
	VecPos[2] += AbsOriginOffset;
	float VecMin[3];VecMin = f3_CustomMinMaxBoundingBoxMinExtra[buildingindx];
	float VecMax[3];VecMax = f3_CustomMinMaxBoundingBox[buildingindx];

	//for this calculation we want the building to be concidered not carried.
	b_ThisEntityIgnoredBeingCarried[buildingindx] = false;

	int buildingHit;
	float endPos[3];
	//we will first check if we hit a building under us.
	if(IsValidGroundBuilding(VecPos , 70.0, endPos, buildingHit, buildingindx))
	{
		//we successfully found a building we want to go ontop of.
		float endPos2[3];
		GetEntPropVector(buildingHit, Prop_Data, "m_vecAbsOrigin", endPos2);
		//How far high is the offset for the building, and then place ourselves ontop
		float Delta = f3_CustomMinMaxBoundingBox[buildingHit][2];
		
		endPos2[0] = VecPos[0];
		endPos2[1] = VecPos[1];
		endPos2[2] += Delta;
		float endPos3[3];
		endPos3 = endPos2;
		//for this calculation we want to pretend that the bottom building is our dependand so we dont interact with it and get blocked.
		int SavePrevious = i_IDependOnThisBuilding[buildingindx];
		i_IDependOnThisBuilding[buildingindx] = 0;
		bool Success = BuildingSafeSpot(buildingindx, endPos3, VecMin, VecMax);
		i_IDependOnThisBuilding[buildingindx] = SavePrevious;
		if(!Success)
		{
			//we did not find a safe place to place ourselves in.
			if(client <= MaxClients)
			{
				CanBuild_VisualiseAndWarn(client, buildingindx, true, VecPos);
				if(!TestClient)
					ClientCommand(client, "playgamesound items/medshotno1.wav");
			}
			
			b_ThisEntityIgnoredBeingCarried[buildingindx] = true;
			return false;
		}
		else
		{
			//we found a safe place.
			endPos2 = endPos3;
		}

		//we now make the building we just placed, dependand on the building below it.
		if(!TestClient)
			i_IDependOnThisBuilding[buildingindx] = EntIndexToEntRef(buildingHit);

		if(client <= MaxClients)
		{
			CanBuild_VisualiseAndWarn(client, buildingindx, false, endPos2);
		}

		
		
		if(!TestClient)
		{
			//offset needed for stuff like ammoboxes as their model is halfway i

			SDKCall_SetLocalOrigin(buildingindx, endPos2);	
			SDKUnhook(buildingindx, SDKHook_Think, BuildingPickUp);
			if(client <= MaxClients)
			{
				Player_BuildingBeingCarried[client] = 0;
				EmitSoundToClient(client, SOUND_TOSS_TF);
			}
		
			Building_BuildingBeingCarried[buildingindx] = 0;
			b_ThisEntityIgnored[buildingindx] = false;
			b_ThisEntityIsAProjectileForUpdateContraints[buildingindx] = false;
			//reset all defaults and confirm a placement
		}
		return true;
	}
	//no valid building below us, lets try to go to the bottom.
	if(!Building_IsValidGroundFloor(client, buildingindx, VecPos))
	{
		b_ThisEntityIgnoredBeingCarried[buildingindx] = true;
		if(client <= MaxClients)
		{
			if(!TestClient)
				ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
		return false;
	}
	if(f3_CustomMinMaxBoundingBoxMinExtra[buildingindx][2])	//wierd offset.
		VecPos[2] -= f3_CustomMinMaxBoundingBoxMinExtra[buildingindx][2];

	//little elevation so it doesnt hit the floor.
	VecPos[2] += 0.1;
	if(!BuildingSafeSpot(buildingindx, VecPos, VecMin, VecMax))
	{
		b_ThisEntityIgnoredBeingCarried[buildingindx] = true;
		if(client <= MaxClients)
		{
			endPos = VecPos;
			CanBuild_VisualiseAndWarn(client, buildingindx, true, endPos);
			if(!TestClient)
				ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
		return false;
	}

	if(client <= MaxClients)
	{
		CanBuild_VisualiseAndWarn(client, buildingindx, false, VecPos);
	}
	if(!TestClient)
	{
		SDKCall_SetLocalOrigin(buildingindx, VecPos);	
		SDKUnhook(buildingindx, SDKHook_Think, BuildingPickUp);
		Building_BuildingBeingCarried[buildingindx] = 0;
		b_ThisEntityIgnored[buildingindx] = false;
		b_ThisEntityIsAProjectileForUpdateContraints[buildingindx] = false;

		if(client <= MaxClients)
		{
			Player_BuildingBeingCarried[client] = 0;
			EmitSoundToClient(client, SOUND_TOSS_TF);
		}
	}
	return true;
}

//Make the player carry a building
void Building_PlayerWieldsBuilding(int client, int entity)
{
	if(!Building_AllowedToWieldBuilding(client))
		return;
		
	Building_RotateAllDepencencies(entity);
	EmitSoundToClient(client, SOUND_GRAB_TF);
	SDKUnhook(entity, SDKHook_Think, BuildingPickUp);
	SDKHook(entity, SDKHook_Think, BuildingPickUp);
	Building_BuildingBeingCarried[entity] = EntIndexToEntRef(client);
	Player_BuildingBeingCarried[client] = EntIndexToEntRef(entity);
	b_ThisEntityIgnoredBeingCarried[entity] = true;
	b_ThisEntityIgnored[entity] = true;
	b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
}

//make sure they dont carry anything beforehand
bool Building_AllowedToWieldBuilding(int client)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
		return false;
	return true;
}

#define BUILDING_DISTANCE_GRAB 100.0
void BuildingPickUp(int BuildingNPC)
{
	if(GrabThrottle[BuildingNPC] > GetGameTime())
	{
		return;
	}
	GrabThrottle[BuildingNPC] = GetGameTime() + 0.1;
	int client = EntRefToEntIndex(Building_BuildingBeingCarried[BuildingNPC]);
	if(!IsValidClient(client))
	{
		RemoveEntity(BuildingNPC);
		return;
	}
	PlayerWasHoldingProp[client] = GetGameTime() + 0.2;
	if(!IsPlayerAlive(client))
	{
		Player_BuildingBeingCarried[client] = 0;
		RemoveEntity(BuildingNPC);
		return;
	}
	float vecView[3];
	float vecView2[3];
	float vecFwd[3];
	float vecPos[3];
	float vecPosbase[3];
	float vecVel[3];

	GetClientEyeAngles(client, vecView);
	vecView2 = vecView;
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);
	vecPosbase = vecPos;
	vecPosbase[2] -= 15.0;
	vecPos[0]+=vecFwd[0]* BUILDING_DISTANCE_GRAB;
	vecPos[1]+=vecFwd[1]* BUILDING_DISTANCE_GRAB;
	vecPos[2]+=vecFwd[2]* BUILDING_DISTANCE_GRAB;

	GetEntPropVector(BuildingNPC, Prop_Data, "m_vecAbsOrigin", vecFwd);

	SubtractVectors(vecPos, vecFwd, vecVel);
	vecPos[2] -= 15.0;
	vecView2[0] = 0.0;
	vecView2[1] -= 180.0;
	vecView2[1] += RotateByDefaultReturn(BuildingNPC);
	//Fire a trace to check if they can even place a building on where they want to.

	Handle hTrace;
	int SolidityFlags;
	SolidityFlags = MASK_PLAYERSOLID;
	float VecMin[3];
	float VecMax[3];
	VecMax = {5.0, 5.0, 5.0};
	hTrace = TR_TraceHullFilterEx(vecPosbase, vecPos, VecMin, VecMax, SolidityFlags, TraceRayDontHitPlayersOrEntityCombat, BuildingNPC);
	float VecCheckBottom[3];
	TR_GetEndPosition(VecCheckBottom, hTrace);
	delete hTrace;
	
	if(f3_CustomMinMaxBoundingBoxMinExtra[BuildingNPC][2])
	{
		//wierd offset.
		VecCheckBottom[2] -= f3_CustomMinMaxBoundingBoxMinExtra[BuildingNPC][2];
	}
	TeleportEntity(BuildingNPC, VecCheckBottom, vecView2, NULL_VECTOR);
	Building_AttemptPlace(BuildingNPC, client, true);
}


bool BuildingSafeSpot(int client, float endPos[3], float hullcheckmins_Player[3], float hullcheckmaxs_Player[3])
{
	bool FoundSafeSpot = false;
	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition_Building(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	for (int x = 0; x < 3; x++)
	{
		//first we check up and down here
		if (FoundSafeSpot)
			break;

		endPos = OriginalPos;
		switch(x)
		{
			case 0:
				endPos[2] += 1.0;
			case 1:
				endPos[2] += TELEPORT_STUCK_CHECK_1;
			case 2:
				endPos[2] += TELEPORT_STUCK_CHECK_1 * 2.0;
		}
		if(IsSafePosition_Building(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
			FoundSafeSpot = true;
	}
	for (int x = -1; x < 4; x++)
	{
		if (FoundSafeSpot)
			break;

		endPos = OriginalPos;
		//ignore 0 at all costs.
		
		switch(x)
		{
			case 0:
				endPos[2] -= TELEPORT_STUCK_CHECK_1;

			case 1:
				endPos[2] += TELEPORT_STUCK_CHECK_1;

			case 2:
				endPos[2] += TELEPORT_STUCK_CHECK_2;

			case 3:
				endPos[2] -= TELEPORT_STUCK_CHECK_2;
		}
		for (int y = 0; y < 5; y++)
		{
			if (FoundSafeSpot)
				break;

			endPos[1] = OriginalPos[1];
				
			switch(y)
			{
				case 1:
					endPos[1] += TELEPORT_STUCK_CHECK_1;

				case 2:
					endPos[1] -= TELEPORT_STUCK_CHECK_1;

				case 3:
					endPos[1] += TELEPORT_STUCK_CHECK_2;

				case 4:
					endPos[1] -= TELEPORT_STUCK_CHECK_2;
			}

			for (int z = 0; z < 5; z++)
			{
				if (FoundSafeSpot)
					break;

				endPos[0] = OriginalPos[0];
						
				switch(z)
				{
					case 1:
						endPos[0] += TELEPORT_STUCK_CHECK_1;

					case 2:
						endPos[0] -= TELEPORT_STUCK_CHECK_1;

					case 3:
						endPos[0] += TELEPORT_STUCK_CHECK_2;

					case 4:
						endPos[0] -= TELEPORT_STUCK_CHECK_2;
				}
				if(IsSafePosition_Building(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
					FoundSafeSpot = true;
			}
		}
	}
				

	if(IsSafePosition_Building(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	return FoundSafeSpot;
}


//We wish to check if this poisiton is safe or not.
bool IsSafePosition_Building(int entity, float Pos[3], float mins[3], float maxs[3])
{
	if(!BuildingValidPositionFinal(Pos, entity))
		return false;
	if(!Building_ValidSpaceEmpty(entity, Pos, mins, maxs))
		return false;
		
	int ref;
	
	Handle hTrace;
	int SolidityFlags;
	SolidityFlags = MASK_PLAYERSOLID;

	hTrace = TR_TraceHullFilterEx(Pos, Pos, mins, maxs, SolidityFlags, BulletAndMeleeTrace, entity);

	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	float pos_player[3];
	WorldSpaceCenter(entity, pos_player);
	float Pos2Test_Higher[3];
	Pos2Test_Higher = Pos;
	Pos2Test_Higher[2] += 35.0;
	hTrace = TR_TraceRayFilterEx( pos_player, Pos2Test_Higher, SolidityFlags, RayType_EndPoint, TraceRayDontHitPlayersOrEntityCombat, entity );
	if ( TR_GetFraction(hTrace) < 1.0)
	{
		delete hTrace;
		return false;
	}
	if(ref < 0) //It hit nothing, good!
	{
		delete hTrace;
		return true;
	}
	//It Hit something, bad!
	delete hTrace;
	return false;
}

bool Building_IsValidGroundFloor(int client, int buildingindx, float VecBottom[3])
{
	//This code checks if there is a valid ground, if not, itll say no and fail.
	//All the checks here now will say if it cailed, if all pass, its valid.
	
	//Visualise the box for the player!
	//This is the final check.
	static float m_vecLookdown[3];
	m_vecLookdown = view_as<float>( { 90.0, 0.0, 0.0 } );
	float VecCheckBottom[3];
	VecCheckBottom = VecBottom;
	Handle hTrace;
	hTrace = TR_TraceRayFilterEx(VecCheckBottom, m_vecLookdown, ( MASK_ALL ), RayType_Infinite, HitOnlyWorld, client);	
	TR_GetEndPosition(VecCheckBottom, hTrace);
	delete hTrace;
	float Distance = GetVectorDistance(VecCheckBottom, VecBottom);
	if(Distance > 60.0)
	{
		if(client <= MaxClients)
			CanBuild_VisualiseAndWarn(client, buildingindx, true,VecBottom);
		
		return false;
	}
	VecBottom = VecCheckBottom;
	
	return true;
}

//The laser boxes and warnings.
void CanBuild_VisualiseAndWarn(int client, int entity, bool Fail = false, float VecBottom[3])
{
	float VecMin[3];
	float VecMax[3];
	VecMax = f3_CustomMinMaxBoundingBox[entity];
	VecMin = f3_CustomMinMaxBoundingBoxMinExtra[entity];
	float VecLaser[3];
	VecLaser = VecBottom;
	if(Fail)
	{
		TE_DrawBox(client, VecLaser, VecMin, VecMax, 0.2, view_as<int>({255, 0, 0, 255}));
		SetDefaultHudPosition(client, 255, 0, 0, 0.3);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Build Here");	
	}
	else
	{
		TE_DrawBox(client, VecLaser, VecMin, VecMax, 0.2, view_as<int>({0, 255, 0, 255}));
		SetDefaultHudPosition(client,_,_,_, 0.3);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Can Build Here");	
	}
}


//Derived from function in SMLIB
stock bool IsValidGroundBuilding(const float pos[3], float distance, float posEnd[3], int& buildingHit, int self)
{
	bool foundbuilding = false;
	Handle trace = TR_TraceRayFilterEx(pos, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID, RayType_Infinite, TraceRayFilterBuildOnBuildings, self);

	if (!TR_DidHit(trace))
	{
		delete trace;
		return false;
	}
	int EntityHit = TR_GetEntityIndex(trace);
	if (EntityHit <= 0 || EntityHit==self)
	{
		//if we hit the world or ourselves somehow, we dont care.
		delete trace;
		return false;
	}

	if(!i_IsABuilding[EntityHit])
	{
		//if we didnt hit any building then we do not care.
		delete trace;
		return false;
	}
	ObjectGeneric objstats1 = view_as<ObjectGeneric>(EntityHit);
	ObjectGeneric objstats2 = view_as<ObjectGeneric>(self);
	if(objstats1.m_bConstructBuilding || objstats2.m_bConstructBuilding)
	{
		delete trace;
		return false;
	}

	if(IsValidEntity(i_IDependOnThisBuilding[EntityHit]))
	{
		//we dont allow stacking of stacking of stacking.
		delete trace;
		return false;
	}


	TR_GetEndPosition(posEnd, trace);

	if (GetVectorDistance(pos, posEnd, true) <= (distance * distance))
	{
		//is the building we hit close enough to us?
		foundbuilding = true;
		buildingHit = EntityHit;
	}

	delete trace;

	return foundbuilding;
}

public bool TraceRayFilterBuildOnBuildings(int entity, int contentsMask, any iExclude)
{
	if(iExclude == entity)
		return false;

	if(entity==0 || entity==-1) //Never the world or something unknown
	{
		return false;
	}
	if(contentsMask==0) //Never the world or something unknown
	{
		return false;
	}

	if(entity>0 && entity<=MaxClients) //ingore players?
	{
		return false;
	}
	
	if(b_ThisEntityIgnored[entity])
		return false;

	if(i_IsABuilding[iExclude])
	{
		ObjectGeneric objstats = view_as<ObjectGeneric>(iExclude);
		if(objstats.m_iExtrabuilding1 == entity)
			return false;
		else if(objstats.m_iExtrabuilding2 == entity)
			return false;
	}

	if(i_IsABuilding[entity]) // Only buildings should be allowed
	{
		return true;
	}
	return false;
}

void IsBuildingNotFloating(int building)
{
	static float m_vecMaxs[3];
	static float m_vecMins[3];
	m_vecMaxs = view_as<float>( { 20.0, 20.0, 1.0 } );
	m_vecMins = view_as<float>( { -20.0, -20.0, -5.0 } );	
	float endPos2[3];
	GetEntPropVector(building, Prop_Data, "m_vecAbsOrigin", endPos2);

	if(!IsSpaceOccupiedWorldOnly(endPos2, m_vecMins, m_vecMaxs, building))
	{

		float endPos4[3];
		endPos4 = endPos2;
		endPos4[2] += 40.0;
		/*
		int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
		TE_SetupBeamPoints(endPos4, endPos2, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
		TE_SendToAll();
		*/
		//This failed, lets do a trace
		Handle hTrace;
		float endPos3[3];
		endPos3 = endPos2;
		endPos3[2] -= 50.0; //only go down 50 units at max.
		
		m_vecMaxs = view_as<float>( { 20.0, 20.0, 20.0 } );
		m_vecMins = view_as<float>( { -20.0, -20.0, 0.0 } );
		hTrace = TR_TraceHullFilterEx(endPos2, endPos3, m_vecMins, m_vecMaxs, MASK_PLAYERSOLID, TraceRayHitWorldOnly, building);
		
		int target_hit = TR_GetEntityIndex(hTrace);	
		if(target_hit > -1)
		{
			float vecHit[3];
			TR_GetEndPosition(vecHit, hTrace);
		//	vecHit[2] -= 7.5; //if a tracehull collides, it takes the middle, so we have to half our height box, which is 20.
			endPos2 = vecHit;
			if(IsPointHazard(endPos2))
			{
				DestroyBuildingDo(building);
				return;
			}
			if(f3_CustomMinMaxBoundingBoxMinExtra[building][2])
			{
				//wierd offset.
				endPos2[2] -= f3_CustomMinMaxBoundingBoxMinExtra[building][2];
			}
			TeleportEntity(building, endPos2, NULL_VECTOR, NULL_VECTOR);
			//we hit something
		}
		else
		{
			DestroyBuildingDo(building);
			return;
		}
	}
	m_vecMaxs = view_as<float>( { 20.0, 20.0, 50.0 } );
	m_vecMins = view_as<float>( { -20.0, -20.0, 35.0 } );	
	//Check if half of the top half of the building is inside a wall, if it is, detroy, if it is not, then we leave it be.
	if(IsSpaceOccupiedWorldOnly(endPos2, m_vecMins, m_vecMaxs, building))
	{
		DestroyBuildingDo(building);
	}
}

//Make sure all buildings are placed correctly
void Building_RotateAllDepencencies(int entityLost = 0)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if(!IsValidEntity(i))
			continue;
			
		if(i_IsABuilding[i] && EntRefToEntIndex(i_IDependOnThisBuilding[i]) == entityLost)
		{
			BuildingAdjustMe(i, entityLost);
		}
	}
	//Remove its dependency off anything else.
	i_IDependOnThisBuilding[entityLost] = 0;
}

//Make sure all buildings are placed correctly
void BuildingAdjustMe(int building, int DestroyedBuilding)
{
	float posMain[3]; 
	GetEntPropVector(building, Prop_Data, "m_vecAbsOrigin", posMain);
	float posStacked[3]; 
	GetEntPropVector(DestroyedBuilding, Prop_Data, "m_vecAbsOrigin", posStacked);

	posMain[2] = posStacked[2];
	
	if(f3_CustomMinMaxBoundingBoxMinExtra[building][2])
	{
		//wierd offset.
		posMain[2] -= f3_CustomMinMaxBoundingBoxMinExtra[building][2];
	}
	float VecMin[3];
	float VecMax[3];
	VecMax = f3_CustomMinMaxBoundingBox[building];
	VecMin = f3_CustomMinMaxBoundingBoxMinExtra[building];

	posMain[2] += 0.5;
	//go up a lil.
	bool Success = BuildingSafeSpot(building, posMain, VecMin, VecMax);
	if(!Success)
	{
		posMain = posStacked;
		//resort to teleporting to the other buildings position.
	}
	TeleportEntity(building, posMain, NULL_VECTOR, NULL_VECTOR);
	//make npc's that target the previous building target the stacked one now.
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int INpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(INpc))
		{
			CClotBody npc = view_as<CClotBody>(INpc);
			if(npc.m_iTarget == DestroyedBuilding)
			{
				npc.m_iTarget = building; 
			}
		}
	}
	IsBuildingNotFloating(building);
	i_IDependOnThisBuilding[building] = 0;
}

//Acts like a tf2 wrench with repairing
public void Wrench_Hit_Repair_Replacement(int client, int weapon, bool &result, int slot)
{
	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	RequestFrames(Wrench_Hit_Repair_ReplacementInternal, 12, pack);
	
	if(IsPlayerCarringObject(client))
		Pickup_Building_M2(client, weapon, false);
}
public void Wrench_Hit_Repair_ReplacementInternal(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	delete pack;
	if(!client || weapon == -1 || !IsValidCurrentWeapon(client, weapon))
	{
		return;
	}

	Allowbuildings_BulletAndMeleeTraceAllyLogic(true);
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, _, true);
				
	int target = TR_GetEntityIndex(swingTrace);	
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	
	delete swingTrace;
	Allowbuildings_BulletAndMeleeTraceAllyLogic(false);

	if(target < 0)
		return;
	
	if(i_IsVehicle[target] != 2)
	{
		if(!i_IsABuilding[target])
		{
			return;
		}
		if(!i_NpcIsABuilding[target])
			return;
	}

	Building_RepairObject(client, target, weapon,vecHit, 1, 1.0);
}		

public void Expidonsan_RemoteRepairAttackM1_Hold(int client, int weapon, bool &result, int slot)
{
	SDKUnhook(client, SDKHook_PostThink, Expidonsan_RemoteRepairAttackM1_Prethink);
	SDKHook(client, SDKHook_PostThink, Expidonsan_RemoteRepairAttackM1_Prethink);
}

public void Expidonsan_RemoteRepairAttackM1_Prethink(int client)
{
	if(GetClientButtons(client) & IN_ATTACK)
	{
		if(f_ExpidonsanRepairDelay[client] > GetGameTime())
		{
			return;
		}
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_active < 0)
		{
			SDKUnhook(client, SDKHook_PostThink, Expidonsan_RemoteRepairAttackM1_Prethink);
			return;
		}
		if(i_CustomWeaponEquipLogic[weapon_active] != WEAPON_EXPIDONSAN_REAPIR)
		{
			SDKUnhook(client, SDKHook_PostThink, Expidonsan_RemoteRepairAttackM1_Prethink);
			return;
		}
		float Getspeed = Attributes_Get(weapon_active, 6, 1.0);

		f_ExpidonsanRepairDelay[client] = GetGameTime() + (1.0 * Getspeed);
		Expidonsan_RemoteRepairAttackM1(client, weapon_active);
	}
	else
	{
		SDKUnhook(client, SDKHook_PostThink, Expidonsan_RemoteRepairAttackM1_Prethink);
		return;
	}
}

public void Expidonsan_RemoteRepairAttackM1(int client, int weapon)
{
	EmitSoundToAll("npc/manhack/bat_away.wav", client, SNDCHAN_AUTO, 70,_,0.15, GetRandomInt(130, 145));
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));

	float MaxRange = 200.0;

	switch(pap)
	{
		case 1:
			MaxRange = 200.0;
		case 2:
			MaxRange = 300.0;
	}
	//lag comp is unneded here.
	Allowbuildings_BulletAndMeleeTraceAllyLogic(true);
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, MaxRange, true);
				
	int target = TR_GetEntityIndex(swingTrace);	
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	
	delete swingTrace;
	Allowbuildings_BulletAndMeleeTraceAllyLogic(false);
		
	float GunPos[3];
	GetClientEyePosition(client, GunPos);
	float angles[3];
	GetClientEyeAngles(client, angles);
	GunPos[2] -= 25.0;
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = 15.0;
	tmp[1] = -8.0;
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = 0.0;
	GunPos[0] += actualBeamOffset[0];
	GunPos[1] += actualBeamOffset[1];
	GunPos[2] += actualBeamOffset[2];

	int red = 100;
	int green = 100;
	int blue = 100;
	int colorLayer4[4];
	float diameter = float(5 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(GunPos, vecHit, Shared_BEAM_Laser, 0, 0, 0, 0.21, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 2.5, colorLayer1, 3);
	TE_SendToAll(0.0);
	
	TE_SetupBeamPoints(GunPos, vecHit, Shared_BEAM_Laser, 0, 0, 0, 0.21, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 1.2, {50,125,50, 150}, 3);
	TE_SendToAll(0.0);

	if(target < 0)
		return;
	
	if(i_IsVehicle[target] != 2)
	{
		if(!i_IsABuilding[target])
		{
			return;
		}
		if(!i_NpcIsABuilding[target])
			return;
	}

	Building_RepairObject(client, target, weapon,vecHit, 2, 0.2);
}		

bool Building_RepairObject(int client, int target, int weapon,float vectorhit[3], int soundDef = 1, float repairspeedModif = 1.0)
{
	int iHealth, max_health;
	if(i_IsVehicle[target])
	{
		max_health = 10000;
		iHealth = Armor_Charge[target];
	}
	else
	{
		//Cant repair non buildings......
		max_health = ReturnEntityMaxHealth(target);
		iHealth = GetEntProp(target, Prop_Data, "m_iHealth");
	}

	if(iHealth >= max_health)
	{
		switch(soundDef)
		{
			case 1:
				EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70,_,1.0);
			case 2:
			{
				EmitSoundToAll("player/taunt_sorcery_fail.wav", target, SNDCHAN_AUTO, 70,_,0.5);
				EmitSoundToClient(client, "player/taunt_sorcery_fail.wav", client, SNDCHAN_AUTO, 70,_,0.5);
			}
		}
		return false;
	}
	
	int new_ammo = GetAmmo(client, 3);

	float RepairRate = Attributes_Get(weapon, 95, 1.0);
	RepairRate *= Attributes_GetOnPlayer(client, 95, true, true, 1.0);

	RepairRate *= 10.0;
	RepairRate *= repairspeedModif;

	if(i_IsVehicle[target])
		RepairRate *= 5;

	int i_HealingAmount = RoundToCeil(RepairRate);
	int newHealth = iHealth + i_HealingAmount;

	if(newHealth >= max_health)
	{
		i_HealingAmount -= newHealth - max_health;
		newHealth = max_health;
	}
	if(!i_IsVehicle[target] && GetEntProp(target, Prop_Data, "m_iRepair") < i_HealingAmount)
	{
		i_HealingAmount = GetEntProp(target, Prop_Data, "m_iRepair");
	}
	if(i_HealingAmount <= 0)
	{
		switch(soundDef)
		{
			case 1:
				EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70,_,1.0);
			case 2:
			{
				EmitSoundToAll("player/taunt_sorcery_fail.wav", target, SNDCHAN_AUTO, 70,_,0.5);
				EmitSoundToClient(client, "player/taunt_sorcery_fail.wav", client, SNDCHAN_AUTO, 70,_,0.5);
			}
		}
		return false;
	}
	int Healing_Value = i_HealingAmount;
	
	int Remove_Ammo = i_HealingAmount / (i_IsVehicle[target] ? 15 : 3);
	
	if(Remove_Ammo < 0)
	{
		Remove_Ammo = 0;
	}
	
	int HealGiven;
	if(newHealth >= 1 && Healing_Value >= 1) //for some reason its able to set it to 1
	{
		HealGiven = HealEntityGlobal(client, target, float(Healing_Value), _, _, _, new_ammo / (i_IsVehicle[target] ? 15 : 3));
		if(HealGiven <= 0)
		{
			switch(soundDef)
			{
				case 1:
					EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70,_,1.0);
				case 2:
				{
					EmitSoundToAll("player/taunt_sorcery_fail.wav", target, SNDCHAN_AUTO, 70,_,0.5);
					EmitSoundToClient(client, "player/taunt_sorcery_fail.wav", client, SNDCHAN_AUTO, 70,_,0.5);
				}

			}
			return false;
		}
		if(!i_IsVehicle[target])
		{
			SetEntProp(target, Prop_Data, "m_iRepair", GetEntProp(target, Prop_Data, "m_iRepair") - HealGiven);
			if(GetEntProp(target, Prop_Data, "m_iRepair") < 0)
			{
				SetEntProp(target, Prop_Data, "m_iRepair", 0);
			}
		}
		switch(soundDef)
		{
			case 1:
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						TE_Particle("halloween_boss_axe_hit_sparks", vectorhit, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						EmitSoundToAll("weapons/wrench_hit_build_success1.wav", client, SNDCHAN_AUTO, 70,_,1.0);
					}
					case 1:
					{
						TE_Particle("halloween_boss_axe_hit_sparks", vectorhit, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						EmitSoundToAll("weapons/wrench_hit_build_success2.wav", client, SNDCHAN_AUTO, 70,_,1.0);
					}
				}
			}
			case 2:
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						//particle can spawn stuff at 0 0 0 in world spawn, oops!
						TE_Particle("manmelter_impact_sparks01", vectorhit, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						EmitSoundToAll("physics/metal/metal_box_strain2.wav", target, SNDCHAN_AUTO, 70,_,0.6, 120);
						EmitSoundToAll("physics/metal/metal_box_strain2.wav", target, SNDCHAN_AUTO, 70,_,0.6, 120);
						EmitSoundToClient(client, "physics/metal/metal_box_strain2.wav", client, SNDCHAN_AUTO, 70,_,0.7, 120);
					}
					case 1:
					{
						TE_Particle("manmelter_impact_sparks01", vectorhit, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						EmitSoundToAll("physics/metal/metal_box_strain4.wav", target, SNDCHAN_AUTO, 70,_,0.6, 120);
						EmitSoundToAll("physics/metal/metal_box_strain4.wav", target, SNDCHAN_AUTO, 70,_,0.6, 120);
						EmitSoundToClient(client, "physics/metal/metal_box_strain4.wav", client, SNDCHAN_AUTO, 70,_,0.7, 120);
					}
				}
			}

		}
		
	}
	UpdateDoublebuilding(target);
	int HealDo;
	HealDo = HealGiven / 3;
	if(HealDo <= 1)
		HealDo = 1;
	ReduceMetalCost(client, HealDo);
	new_ammo -= HealDo;
	SetAmmo(client, 3, new_ammo);
	CurrentAmmo[client][3] = GetAmmo(client, 3);
	return true;
}


void UpdateDoublebuilding(int entity)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(IsValidEntity(objstats.m_iMasterBuilding))
	{
		SetEntProp(objstats.m_iMasterBuilding, Prop_Data, "m_iRepair", GetEntProp(entity, Prop_Data, "m_iRepair"));
		SetEntProp(objstats.m_iMasterBuilding, Prop_Data, "m_iRepairMax", GetEntProp(entity, Prop_Data, "m_iRepairMax"));
		SetEntProp(objstats.m_iMasterBuilding, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
		SetEntProp(objstats.m_iMasterBuilding, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
		ObjectGeneric objstats2 = view_as<ObjectGeneric>(objstats.m_iMasterBuilding);

		if(IsValidEntity(objstats2.m_iExtrabuilding1))
		{
			SetEntProp(objstats2.m_iExtrabuilding1, Prop_Data, "m_iRepair", GetEntProp(entity, Prop_Data, "m_iRepair"));
			SetEntProp(objstats2.m_iExtrabuilding1, Prop_Data, "m_iRepairMax", GetEntProp(entity, Prop_Data, "m_iRepairMax"));
			SetEntProp(objstats2.m_iExtrabuilding1, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
			SetEntProp(objstats2.m_iExtrabuilding1, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
		}

		if(IsValidEntity(objstats2.m_iExtrabuilding2))
		{
			SetEntProp(objstats2.m_iExtrabuilding2, Prop_Data, "m_iRepair", GetEntProp(entity, Prop_Data, "m_iRepair"));
			SetEntProp(objstats2.m_iExtrabuilding2, Prop_Data, "m_iRepairMax", GetEntProp(entity, Prop_Data, "m_iRepairMax"));
			SetEntProp(objstats2.m_iExtrabuilding2, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
			SetEntProp(objstats2.m_iExtrabuilding2, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
		}
	}
	else
	{
		if(IsValidEntity(objstats.m_iExtrabuilding1))
		{
			SetEntProp(objstats.m_iExtrabuilding1, Prop_Data, "m_iRepair", GetEntProp(entity, Prop_Data, "m_iRepair"));
			SetEntProp(objstats.m_iExtrabuilding1, Prop_Data, "m_iRepairMax", GetEntProp(entity, Prop_Data, "m_iRepairMax"));
			SetEntProp(objstats.m_iExtrabuilding1, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
			SetEntProp(objstats.m_iExtrabuilding2, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
		}

		if(IsValidEntity(objstats.m_iExtrabuilding2))
		{
			SetEntProp(objstats.m_iExtrabuilding2, Prop_Data, "m_iRepair", GetEntProp(entity, Prop_Data, "m_iRepair"));
			SetEntProp(objstats.m_iExtrabuilding2, Prop_Data, "m_iRepairMax", GetEntProp(entity, Prop_Data, "m_iRepairMax"));
			SetEntProp(objstats.m_iExtrabuilding2, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
			SetEntProp(objstats.m_iExtrabuilding2, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
		}
	}
}

void Barracks_UpdateEntityUpgrades(int entity, int client, bool firstbuild = false, bool BarracksUpgrade = false)
{
	if(client <= 0)
	{
		//no valid client.
		return;
	}
	if(i_IsABuilding[entity] && b_NpcHasDied[entity])
	{
		if(firstbuild)
		{
			//rid of warning.
			firstbuild = false;
		}
		float multi = Object_GetMaxHealthMulti(client);
		float CurrentMulti = Attributes_Get(entity, 286, 1.0);
		float IsAlreadyDowngraded = Attributes_Get(entity, Attrib_BuildingOnly_PreventUpgrade, 0.0);
		if(CurrentMulti != multi)
		{
			float MultiChange = multi / CurrentMulti;
			if(MultiChange < 1.0)
			{
				SetBuildingMaxHealth(entity, MultiChange, false, true);
				Attributes_Set(entity, Attrib_BuildingOnly_PreventUpgrade, 1.0);
				Attributes_Set(entity, 286, multi);
			}
			else if(IsAlreadyDowngraded == 0.0)
			{
				SetBuildingMaxHealth(entity, MultiChange, false, true);
				Attributes_Set(entity, 286, multi);
			}

		}
		static char plugin[64];
		NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
		if(StrContains(plugin, "obj_barracks", false) != -1)
		{
			float healthMult = 1.0;
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER) && !(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_TOWER))
			{
				healthMult *= 1.3;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_TOWER;
				/*
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
				if(IsValidEntity(prop1))
				{
					SetEntityModel(prop1, "models/props_manor/clocktower_01.mdl");
					//"0.65" default
					SetEntPropFloat(prop1, Prop_Send, "m_flModelScale", 0.11); 
				}
				*/
			}

			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_GUARD_TOWER) && (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_GUARD_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_GUARD_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER) && (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER) && (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)&& (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_DONJON)))
			{
				healthMult *= 1.3;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_DONJON;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_KREPOST) && (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_KREPOST)))
			{
				healthMult *= 1.4;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_KREPOST;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CASTLE) && (!(i_EntityReceivedUpgrades[entity] & ZR_BARRACKS_UPGRADES_CASTLE)))
			{
				healthMult *= 1.6;
				i_EntityReceivedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_CASTLE;
			}
			if(healthMult > 1.0)
			{
				SetBuildingMaxHealth(entity, healthMult, false, true);
			}
		}
	}
	
	if(!b_NpcHasDied[entity] && !i_IsABuilding[entity])
	{
		int CurrentPlayerValue = RoundToNearest(Attributes_GetOnPlayer(client, Attrib_BuildingStatus_PreventAbuse));
		int CurrentBarracksValue = RoundToNearest(Attributes_Get(entity, Attrib_BuildingStatus_PreventAbuse, 1.0));
		if(CurrentBarracksValue > CurrentPlayerValue)
		{
			SmiteNpcToDeath(entity);
			SPrintToChat(client, "%t", "Barracks Invalid suicide");
			//SUICIDE! THEY WANNA BE ILLIGAL WITH ME!!!!!
			return;
		}
		//update value for the future
		Attributes_Set(entity, Attrib_BuildingStatus_PreventAbuse, float(CurrentPlayerValue));
		float Attribute;
		Attribute = Attributes_GetOnPlayer(client, Attrib_BarracksHealth, true, true);
		if(f_FreeplayAlteredHealthOld_Barracks[entity] != Attribute)
		{
			float AdjustValues = f_FreeplayAlteredHealthOld_Barracks[entity] / Attribute;

			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / AdjustValues));

			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / AdjustValues));

			f_FreeplayAlteredHealthOld_Barracks[entity] = Attribute;
		}
		

		Attribute = Attributes_GetOnPlayer(client, Attrib_BarracksDamage, true, true);
		if(f_FreeplayAlteredDamageOld_Barracks[entity] != Attribute)
		{
			float AdjustValues = f_FreeplayAlteredDamageOld_Barracks[entity] / Attribute;

			view_as<BarrackBody>(entity).BonusDamageBonus /= AdjustValues;
			f_FreeplayAlteredDamageOld_Barracks[entity] = Attribute;
		}
		if(!FinalBuilder[entity] && FinalBuilder[client])
		{
			FinalBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.35;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.8;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.35));
		}
		if(!WildingenBuilder[entity] && WildingenBuilder[client])
		{
			WildingenBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.55;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.7;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.7));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.7));
		}
		if(!WildingenBuilder2[entity] && WildingenBuilder2[client])
		{
			WildingenBuilder2[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.55;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.7;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.7));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.7));
		}
		if(FinalBuilder[entity] && !FinalBuilder[client])
		{
			FinalBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.35;			
			view_as<BarrackBody>(entity).BonusFireRate /= 0.8;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / 1.35));
		}
		if(!GlassBuilder[entity] && GlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.15;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 0.8));
		}
		if(GlassBuilder[entity] && !GlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.15;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / 0.8));
		}
		if(!Inv_Golden_Crown[entity] && Inv_Golden_Crown[client])
		{
			Inv_Golden_Crown[entity] = true;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.15));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.15));
		}
		if(Inv_Golden_Crown[entity] && !Inv_Golden_Crown[client])
		{
			Inv_Golden_Crown[entity] = false;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.15));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / 1.15));
		}
		if(!Inv_Barrack_Backup[entity] && Inv_Barrack_Backup[client])
		{
			Inv_Barrack_Backup[entity] = true;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.5));
		}
		if(Inv_Barrack_Backup[entity] && !Inv_Barrack_Backup[client])
		{
			Inv_Barrack_Backup[entity] = false;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / 1.5));
		}
		if(!Inv_Leaders_Belt[entity] && Inv_Leaders_Belt[client])
		{
			Inv_Leaders_Belt[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.15;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.88;
		}
		if(Inv_Leaders_Belt[entity] && !Inv_Leaders_Belt[client])
		{
			Inv_Leaders_Belt[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.15;			
			view_as<BarrackBody>(entity).BonusFireRate /= 0.88;
		}
		if(!(i_CurrentEquippedPerk[entity] & PERK_MORNING_COFFEE) && (i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE))
		{
			view_as<BarrackBody>(entity).BonusFireRate *= 0.85;
		}
		if((i_CurrentEquippedPerk[entity] & PERK_MORNING_COFFEE) && !(i_CurrentEquippedPerk[client] & PERK_MORNING_COFFEE))
		{
			view_as<BarrackBody>(entity).BonusFireRate /= 0.85;
		}
		if((i_CurrentEquippedPerk[entity] & PERK_OBSIDIAN) && !(i_CurrentEquippedPerk[client] & PERK_OBSIDIAN))
		{
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.15));

			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.15));
		}
		if(!(i_CurrentEquippedPerk[entity] & PERK_OBSIDIAN) && (i_CurrentEquippedPerk[client] & PERK_OBSIDIAN))
		{
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.15));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) / 1.15));
		}
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFINED_MEDICINE) &&!(i_EntityReceivedUpgrades[entity] & ZR_UNIT_UPGRADES_REFINED_MEDICINE))
		{
			i_EntityReceivedUpgrades[entity] |= ZR_UNIT_UPGRADES_REFINED_MEDICINE;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.1));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * 1.1));
		}
		i_CurrentEquippedPerk[entity] = i_CurrentEquippedPerk[client];
	}
}


void SetBuildingMaxHealth(int entity, float Multi, bool reduce, bool initial = false, bool inversehealth = false)
{
	if(reduce)
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", 		RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iHealth")) 		/ Multi));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", 	RoundToFloor(float(ReturnEntityMaxHealth(entity))	/ Multi));
		SetEntProp(entity, Prop_Data, "m_iRepair",		RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iRepair")) 		/ Multi));
		SetEntProp(entity, Prop_Data, "m_iRepairMax", 	RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iRepairMax")) 	/ Multi));
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToFloor(float(ReturnEntityMaxHealth(entity)) * Multi));
		SetEntProp(entity, Prop_Data, "m_iRepairMax", RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iRepairMax")) * Multi));
		
		if(initial)
		{
			int HealthToSet = RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * Multi);
			int RepairToSet = RoundToFloor(float(GetEntProp(entity, Prop_Data, "m_iRepair")) * Multi);

			if(inversehealth)
			{
				HealthToSet = GetEntProp(entity, Prop_Data, "m_iHealth") - HealthToSet;
				RepairToSet = GetEntProp(entity, Prop_Data, "m_iHealth") - RepairToSet;

				SetEntProp(entity, Prop_Data, "m_iHealth",HealthToSet);
				SetEntProp(entity, Prop_Data, "m_iRepair",RepairToSet);	
			}
			else
			{
				SetEntProp(entity, Prop_Data, "m_iHealth",HealthToSet);
				SetEntProp(entity, Prop_Data, "m_iRepair",RepairToSet);	
			}
		}
	}
}


float BuildingWeaponDamageModif(int Type)
{
	switch(Type)
	{
		case 1:
		{
			//1 means its a weapon
			return 0.925;
		}
		default:
		{
			return 1.0;
		}
	}
}

public bool BuildingCustomCommand(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RITUALIST)
		{
			RitualistCancelTauntDo(client);
		}
	}
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && obj>MaxClients)
	{
		bool result;
		Function func = func_NPCInteract[obj];
		if(func && func != INVALID_FUNCTION)
		{
			Call_StartFunction(null, func);
			Call_PushCell(client);
			Call_PushCell(-1);
			Call_PushCell(obj);
			Call_Finish(result);
		}
		return true;
	}
	return false;
}

int i2_MountedInfoAndBuilding[2][MAXPLAYERS + 1];

public void MountBuildingToBack(int client, int weapon, bool crit)
{
	MountBuildingToBackInternal(client, false);
}

//true if mounted
bool MountBuildingToBackInternal(int client, bool AllowAnyBuilding)
{
	if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]) || IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
	{
		if(!AllowAnyBuilding)
			UnequipDispenser(client);

		return false;
	}
	if(IsPlayerCarringObject(client))
	{
		Pickup_Building_M2(client, -1, false);
		return false;
	}
	int entity = GetClientPointVisible(client, 150.0 , false, false,_,1);
	if(entity <= MaxClients)
	{
		return false;
	}
	if (!IsValidEntity(entity))
	{
		return false;
	}
	if(!i_IsABuilding[entity])
	{
		return false;
	}
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(IsValidEntity(objstats.m_iMasterBuilding))
	{
		entity = objstats.m_iMasterBuilding;
	}
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client)
	{
		if(!AllowAnyBuilding)
			return false;
		else
		{
			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_decorative", false) != -1)
			{

			}
			else
			{
				return false;
			}
			//This means that we'll allow pciking up allied buildings, howedver we only allow decorative ones.
		}
	}

	ObjectGeneric objstats1 = view_as<ObjectGeneric>(entity);
	if(objstats1.m_bConstructBuilding)
		return false;	// Too fat

	Building_RotateAllDepencencies(entity);
	float ModelScale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
	ModelScale *= 0.33;

	b_ThisEntityIgnored[entity] = true;
	b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
	
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelScale);
	if(IsValidEntity(objstats.m_iWearable1))
	{
		SetEntPropFloat(objstats.m_iWearable1, Prop_Send, "m_flModelScale", ModelScale);
		b_IsEntityAlwaysTranmitted[objstats.m_iWearable1] = true;		
		SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingReady);
	//	SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
	}

	
	//update text
	objstats.m_flNextDelayTime = 0.0;
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	if(f3_CustomMinMaxBoundingBoxMinExtra[entity][2])	//wierd offset.
		flPos[2] -= f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
	SDKCall_SetLocalOrigin(entity, flPos);	
	RandomIntSameRequestFrame[client] = GetRandomInt(-999999,9999999);
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(RandomIntSameRequestFrame[client]);

	RequestFrames(ParentDelayFrameForReasons, 1, pack);
	Building_Mounted[entity] = EntIndexToEntRef(client);
	Building_Mounted[client] = EntIndexToEntRef(entity);
	
	i2_MountedInfoAndBuilding[1][client] = EntIndexToEntRef(entity);
	//all checks succeeded, now mount the building onto their back!
	return true;
}

//its delayed to fix various issues regarding rendering
void ParentDelayFrameForReasons(DataPack pack)
{
	pack.Reset();
	
	int client = EntRefToEntIndex(pack.ReadCell());
	int entity = EntRefToEntIndex(pack.ReadCell());
	int RandomInt = pack.ReadCell();
	delete pack;

	if(!IsValidEntity(client))
		return;

	if(!IsValidEntity(entity))
		return;

	if(RandomIntSameRequestFrame[client] != RandomInt)
		return;

	int Wearable;
	Wearable = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(Wearable))
		return;

	float flPos[3];
	float flAng[3];
	char WhichAttachmentDo[32];
	if(!Yakuza_IsBeastMode(client))
	{
		WhichAttachmentDo = "flag";
	}
	else
	{
		WhichAttachmentDo = "bread_hand_r";
	}
	
	GetAttachment(Wearable, WhichAttachmentDo, flPos, flAng);

	int InfoTarget = InfoTargetParentAt(flPos,"", 0.0);
	SetParent(Wearable, InfoTarget, WhichAttachmentDo,_);
	if(f3_CustomMinMaxBoundingBoxMinExtra[entity][2])	//wierd offset.
		flPos[2] -= f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
	SDKCall_SetLocalOrigin(entity, flPos);	
	SetEntPropVector(entity, Prop_Data, "m_angRotation", flAng);
	SetParent(InfoTarget, entity, _, _, _);
	i2_MountedInfoAndBuilding[0][client] = EntIndexToEntRef(InfoTarget);
}

static Handle Timer_TransferOwnerShip[MAXPLAYERS];

static Action Timer_KillMountedStuff(Handle timer, int client)
{
	Timer_TransferOwnerShip[client] = null;
	if(IsValidClient(client))
		UnequipDispenser(client, true);
		
	return Plugin_Stop;
}


void TransferDispenserBackToOtherEntity(int client, bool DontEquip = false)
{
	if(PreventSameFrameActivation[view_as<int>(DontEquip)][client] == GetGameTime())
		return;
		
	PreventSameFrameActivation[view_as<int>(DontEquip)][client] = GetGameTime();

	int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);

	if(DontEquip && IsValidEntity(entity))
	{
		if(Timer_TransferOwnerShip[client] == null)
		{
			Timer_TransferOwnerShip[client] = CreateTimer(0.25, Timer_KillMountedStuff, client);

			float posStacked[3]; 
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
			AcceptEntityInput(entity, "ClearParent");
			if(f3_CustomMinMaxBoundingBoxMinExtra[entity][2])	//wierd offset.
				posStacked[2] -= f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
			SDKCall_SetLocalOrigin(entity, posStacked);	
		}
		return;
	}
	if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]))
	{
		RemoveEntity(i2_MountedInfoAndBuilding[0][client]);
	}
	i2_MountedInfoAndBuilding[0][client] = INVALID_ENT_REFERENCE;
	if(!IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
	{
		i2_MountedInfoAndBuilding[1][client] = INVALID_ENT_REFERENCE;
		return;
	}
	i2_MountedInfoAndBuilding[1][client] = INVALID_ENT_REFERENCE;
	if(DontEquip)
	{
		return;
	}

	int Wearable;
	Wearable = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(Wearable))
		return;
	
	if(Timer_TransferOwnerShip[client] != null)
	{
		delete Timer_TransferOwnerShip[client];
	}

	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	if(f3_CustomMinMaxBoundingBoxMinExtra[entity][2])	//wierd offset.
		flPos[2] -= f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
	SDKCall_SetLocalOrigin(entity, flPos);	
	RandomIntSameRequestFrame[client] = GetRandomInt(-999999,9999999);
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(RandomIntSameRequestFrame[client]);

	RequestFrames(ParentDelayFrameForReasons, 6, pack);
	Building_Mounted[entity] = EntIndexToEntRef(client);
	Building_Mounted[client] = EntIndexToEntRef(entity);
	
	i2_MountedInfoAndBuilding[1][client] = EntIndexToEntRef(entity);
}
void UnequipDispenser(int client, bool destroy = false)
{
	if(destroy)
	{
		Building_Mounted[client] = -1;
		if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]))
		{
			RemoveEntity(i2_MountedInfoAndBuilding[0][client]);
		}
		if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
		{
			RemoveEntity(i2_MountedInfoAndBuilding[1][client]);
		}
		i2_MountedInfoAndBuilding[0][client] = INVALID_ENT_REFERENCE;
		i2_MountedInfoAndBuilding[1][client] = INVALID_ENT_REFERENCE;
		return;
	}
	//dont carry anything please.
	if(IsPlayerCarringObject(client))
	{
		Pickup_Building_M2(client, -1, false);
		return;
	}
	
	Building_Mounted[client] = -1;
	int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
	if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
	{
		float posStacked[3]; 
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
		AcceptEntityInput(i2_MountedInfoAndBuilding[1][client], "ClearParent");
		if(f3_CustomMinMaxBoundingBoxMinExtra[entity][2])	//wierd offset.
			posStacked[2] -= f3_CustomMinMaxBoundingBoxMinExtra[entity][2];

		SDKCall_SetLocalOrigin(entity, posStacked);	
		i2_MountedInfoAndBuilding[1][client] = INVALID_ENT_REFERENCE;
	}
	if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]))
	{
		RemoveEntity(i2_MountedInfoAndBuilding[0][client]);
		i2_MountedInfoAndBuilding[0][client] = INVALID_ENT_REFERENCE;
	}
	if(!IsValidEntity(entity))
	{
		return;
	}
	Building_Mounted[entity] = -1;
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	b_ThisEntityIgnored[entity] = false;
	b_ThisEntityIsAProjectileForUpdateContraints[entity] = false;
	float ModelScale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
	ModelScale *= 3.0;

	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelScale);
	if(IsValidEntity(objstats.m_iWearable1))
	{
		SetEntPropFloat(objstats.m_iWearable1, Prop_Send, "m_flModelScale", ModelScale);
		b_IsEntityAlwaysTranmitted[objstats.m_iWearable1] = false;
	//	SetEntPropFloat(objstats.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);		
		SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingReady);
		SDKHook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingReady);
	//	SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
	//	SDKHook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
	}

	//update text
	objstats.m_flNextDelayTime = 0.0;

	Building_PlayerWieldsBuilding(client, entity);
}

bool BuildingValidPositionFinal(float AbsOrigin[3], int entity)
{
	//is inside a trigger hurt zone
	if(i_InHurtZone[entity])
	{
		return false;
	}
	float VecMax[3];
	float VecMin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecMaxs", VecMax);
	GetEntPropVector(entity, Prop_Data, "m_vecMins", VecMin);
	//is it inside a no build zone
	if(IsPointNoBuild(AbsOrigin,VecMin,VecMax))
	{
		return false;
	}
	float AbsOrigin_after[3];
	AbsOrigin_after = AbsOrigin;
	AbsOrigin_after[2] -= 5.0;
	TR_TraceHullFilter(AbsOrigin, AbsOrigin_after, VecMin, VecMax, MASK_PLAYERSOLID_BRUSHONLY, TraceRayHitWorldOnly, entity);
	if(TR_DidHit())
	{
		// Gets the normal vector of the surface under the building
		float vPlane[3];
		TR_GetPlaneNormal(INVALID_HANDLE, vPlane);
		
		// Make sure it's not flat ground and not a surf ramp (1.0 = flat ground, < 0.7 = surf ramp)
		//its a surf ramp, prevent building.
		if(0.7 >= vPlane[2])
		{
			return false;
		}
	}
	//it passed all checks, allow building.
	return true;
}

int MetalSpendOnBuilding[MAXENTITIES];

void GiveBuildingMetalCostOnBuy(int entity, int cost)
{	
	MetalSpendOnBuilding[entity] = cost;
}
void DeleteAndRefundBuilding(int client, int entity)
{	
	//dont do boom if primed
	if(BombIdVintulum() == i_NpcInternalId[entity])
	{
		ObjectVintulumBomb npc = view_as<ObjectVintulumBomb>(entity);
		if(npc.m_flBombExplodeTill)
			return;
	}

	if(IsValidClient(client))
	{
		int Repair = 	GetEntProp(entity, Prop_Data, "m_iRepair");
		int MaxRepair = GetEntProp(entity, Prop_Data, "m_iRepairMax");
		int Health = 	GetEntProp(entity, Prop_Data, "m_iHealth");
		int MaxHealth = ReturnEntityMaxHealth(entity);
		
		int MaxTotal = MaxRepair + MaxHealth;
		int Total = Repair + Health;

		float RatioReturn = float(Total) / float(MaxTotal);
		
		int MetalReturn = RoundToNearest(MetalSpendOnBuilding[entity] * RatioReturn * 0.8);
		if(MetalReturn >= RoundToNearest(MetalSpendOnBuilding[entity] * 0.8))
			MetalReturn = RoundToNearest(MetalSpendOnBuilding[entity] * 0.8);

		SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) + MetalReturn);
		CurrentAmmo[client][3] = GetAmmo(client, 3);
	}

	RemoveEntity(entity);
}


void Building_Check_ValidSupportcount(int client)
{
	if(i_HealthBeforeSuit[client] > 0)
		return;
		
	if(f_HealthBeforeSuittime[client] > GetGameTime())
		return;

	int maxcount = Object_MaxSupportBuildings(client);
	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
		if(IsValidEntity(entity) && BuildingIsSupport(entity))
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			if(builder_owner == client)
			{
				if(Object_SupportBuildings(client) > maxcount)
				{
					SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", -1);
				}
			}
		}
	}
}

//Acts like a tf2 wrench with repairing
public void Tinker_ShootProjectile(int client, int weapon, bool &result, int slot)
{
	float damage = 50.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 2200.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
	//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
	int Projectile = Wand_Projectile_Spawn(client, speed, -1.0, damage, 0, weapon, "",.hideprojectile = true);
	WandProjectile_ApplyFunctionToEntity(Projectile, Tinker_TouchAnything);
	SetEntityModel(Projectile, MODEL_HEALINGBOLT);
	ApplyCustomModelToWandProjectile(Projectile, MODEL_HEALINGBOLT, 1.0, "");
	b_NpcIsTeamkiller[Projectile] = true;
	b_AllowCollideWithSelfTeam[Projectile] = true;

	SetEntityMoveType(Projectile, MOVETYPE_FLYGRAVITY);
	SetEntityGravity(Projectile, 0.15);
	i_WandParticle[Projectile] = EntIndexToEntRef(Trail_Attach(Projectile, CLAW_TRAIL_RED, 255, 0.3, 3.0, 3.0, 5));
}

static void Tinker_TouchAnything(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target < 0)	
		return;

	if(target == 0)
	{
		int attacker = EntRefToEntIndex(i_WandOwner[entity]);
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(attacker == client)
				{
					switch(GetRandomInt(1,3))
					{
						case 1:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal.wav", attacker, SNDCHAN_STATIC, 70, _, 0.8);
						
						case 2:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal2.wav", attacker, SNDCHAN_STATIC, 70, _, 0.8);
						
						case 3:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal4.wav", attacker, SNDCHAN_STATIC, 70, _, 0.80);
					}	
				}
				else
				{

					switch(GetRandomInt(1,3))
					{
						case 1:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal.wav", entity, SNDCHAN_STATIC, 70, _, 0.8);
						
						case 2:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal2.wav", entity, SNDCHAN_STATIC, 70, _, 0.8);
						
						case 3:
							EmitSoundToClient(client, "weapons/fx/rics/arrow_impact_metal4.wav", entity, SNDCHAN_STATIC, 70, _, 0.8);
					}	
				}
			}
		}
		WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
		if(IsValidEntity(particle))
		{
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderMode(entity, RENDER_NONE);
		SetEntityMoveType(entity, MOVETYPE_NONE);
		int FakeThing = EntRefToEntIndex(iref_PropAppliedToRocket[entity]);
		if(IsValidEntity(FakeThing))
		{
			SetEntityRenderMode(FakeThing, RENDER_NONE);
		}
		return;
	}
	if(GetTeam(entity) != GetTeam(target))
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		int attacker = EntRefToEntIndex(i_WandOwner[entity]);

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		SDKHooks_TakeDamage(target, attacker, attacker, f_WandDamage[entity], DMG_PLASMA, weapon, PushforceDamage, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(attacker == client)
				{
					EmitSoundToClient(client, g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], attacker, SNDCHAN_STATIC, 70, _, 1.0);
				}
				else
				{
					EmitSoundToClient(client, g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], attacker, SNDCHAN_STATIC, 70, _, 1.0);
				}
			}
		}
		WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
		if(IsValidEntity(particle))
		{
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderMode(entity, RENDER_NONE);
		SetEntityMoveType(entity, MOVETYPE_NONE);
		int FakeThing = EntRefToEntIndex(iref_PropAppliedToRocket[entity]);
		if(IsValidEntity(FakeThing))
		{
			SetEntityRenderMode(FakeThing, RENDER_NONE);
		}
		return;
	}
	else
	{
		if(i_NpcIsABuilding[target])
		{
			//heal building?
			bool RepairDone = false;
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			int attacker = EntRefToEntIndex(i_WandOwner[entity]);
			if(IsValidEntity(weapon) && IsValidClient(attacker))
				RepairDone = Building_RepairObject(attacker, target, weapon,{0.0,0.0,0.0}, -1, 0.5);
			
			if(!RepairDone)
				return;

			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(attacker == client)
					{
						EmitSoundToClient(client, SOUND_HOSE_HEALED, attacker, SNDCHAN_STATIC, 70, _, 0.8);
					}
					else
					{
						EmitSoundToClient(client, SOUND_HOSE_HEALED, entity, SNDCHAN_STATIC, 70, _, 0.8);
					}
				}
			}
			
			WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
			if(IsValidEntity(particle))
			{
				CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			}
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			SetEntityRenderMode(entity, RENDER_NONE);
			SetEntityMoveType(entity, MOVETYPE_NONE);
			int FakeThing = EntRefToEntIndex(iref_PropAppliedToRocket[entity]);
			if(IsValidEntity(FakeThing))
			{
				SetEntityRenderMode(FakeThing, RENDER_NONE);
			}
		}
	}
}
public void Weapon_OnBuyUpdateBuilding(int client)
{
	//a little delay!
	CreateTimer(0.1, Timer_Weapon_OnBuyUpdateBuilding, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}



public Action Timer_Weapon_OnBuyUpdateBuilding(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		if(IsPlayerAlive(entity) && TeutonType[entity] == TEUTON_NONE)
			Barracks_UpdateAllEntityUpgrades(entity);
	}
	return Plugin_Stop;
}


public void ExplainBuildingInChat_Buy(int client)
{
	ExplainBuildingInChat(client, 1);
}


void ExplainBuildingInChat(int client, int ExplainWhat)
{
	switch(ExplainWhat)
	{
		case 1:
		{
			Force_ExplainBuffToClient(client, "Wrench Building", true);
		}
		case 2:
		{
			Force_ExplainBuffToClient(client, "Barracks Building Explain", true);
		}
	}
}


bool Building_ValidSpaceEmpty(int buildingindx, float VecBottom[3], float HullMin[3], float HullMaxTemp[3])
{
	//This code checks if we try to place the building inside other buildings
	float HullMax[3];
	HullMax = HullMaxTemp;
	HullMax[2] -= 1.0;
	//allow tight space fitting
	Handle hTrace;
	hTrace = TR_TraceHullFilterEx(VecBottom, VecBottom, HullMin, HullMax, MASK_PLAYERSOLID, TraceRayHitWorldAndBuildingsOnly, buildingindx);
	
	int target_hit = TR_GetEntityIndex(hTrace);	
	delete hTrace;
	
	if(target_hit > 0)
	{
		return false;
	}
	return true;
}
