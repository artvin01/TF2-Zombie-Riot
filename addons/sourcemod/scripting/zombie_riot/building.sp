#pragma semicolon 1
#pragma newdecls required

#define SOUND_GRAB_TF "ui/item_default_pickup.wav"      // grab
#define SOUND_TOSS_TF "ui/item_default_drop.wav"        // throww

static const char BuildingPlugin[][] =
{
	//"obj_barricade", // Cheap Barricade
	"obj_barricade", // Normal Barricade
	"obj_decorative",

	"obj_ammobox",
	"obj_armortable",
	"obj_perkmachine",
	"obj_packapunch",

	"obj_sentrygun",
	"obj_mortar",
	"obj_railgun",
	"obj_healingstation",
	"obj_village",
	"obj_barracks",

	"obj_tinker_anvil"
};


// Base metal cost of building
static const int BuildingCost[sizeof(BuildingPlugin)] =
{
	//-50,
	560,
	0,

	579,
	379,
	979,
	979,

	587,
	587,
	587,
	587,
	1187,
	1179,

	400
};

// Base health of building
static const int BuildingHealth[sizeof(BuildingPlugin)] =
{
	//150,
	420,
	50,

	50,
	50,
	50,
	50,

	30,
	30,
	30,
	30,
	30,
	50,

	420
};

// Cooldown between creation (not effected during setup)
static const float BuildingCooldown[sizeof(BuildingPlugin)] =
{
	//99999.9,
	15.0,
	10.0,

	20.0,
	20.0,
	60.0,
	60.0,

	30.0,
	30.0,
	30.0,
	30.0,
	30.0,
	15.0,

	15.0
};

static const char BuildingFuncName[sizeof(BuildingPlugin)][] =
{
	//"ObjectBarricade_CanBuildCheap",
	"ObjectBarricade_CanBuild",
	"ObjectDecorative_CanBuild",

	"ObjectGeneric_CanBuild",
	"ObjectGeneric_CanBuild",
	"ObjectGeneric_CanBuild",
	"ObjectGeneric_CanBuild",

	"ObjectGeneric_CanBuildSentry",
	"ObjectGeneric_CanBuildSentry",
	"ObjectGeneric_CanBuildSentry",
	"ObjectGeneric_CanBuildSentry",
	"ObjectGeneric_CanBuildSentry",
	"ObjectGeneric_CanBuildSentry",

	"ObjectTinkerAnvil_CanBuild"
};

static int BuildingId[sizeof(BuildingPlugin)];
static Function BuildingFunc[sizeof(BuildingPlugin)];
static Function BuildingFuncSave[MAXENTITIES];
static float Cooldowns[MAXTF2PLAYERS][sizeof(BuildingPlugin)];
static float GrabThrottle[MAXENTITIES];
static int MenuPage[MAXTF2PLAYERS];
static Handle MenuTimer[MAXTF2PLAYERS];
static int Player_BuildingBeingCarried[MAXTF2PLAYERS];
static int i_IDependOnThisBuilding[MAXENTITIES];
static float PlayerWasHoldingProp[MAXTF2PLAYERS];
float PreventSameFrameActivation[2][MAXPLAYERS + 1];
int RandomIntSameRequestFrame[MAXPLAYERS + 1];

bool BuildingIsSupport(int entity)
{
	if(BuildingFuncSave[entity] == ObjectGeneric_CanBuild)
		return true;

	return false;
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
#define MAX_SUPPLIES_EACH_WAVE 5
static float f_GiveAmmoSupplyFacture[MAXTF2PLAYERS];
static int i_GiveAmmoSupplyLimit[MAXTF2PLAYERS];
static int i_GiveCashBuilding[MAXTF2PLAYERS];

void Building_PluginStart()
{
	for(int i; i < sizeof(BuildingFuncName); i++)
	{
		BuildingFunc[i] = GetFunctionByName(null, BuildingFuncName[i]);
		if(BuildingFunc[i] == INVALID_FUNCTION)
			LogError("Function '%s' is missing in building.sp", BuildingFuncName[i]);
	}
}

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

void Building_GiveRewardsUse(int client, int owner, int Cash, bool CashLimit = true, float AmmoSupply = 0.0, bool SupplyLimit = true)
{
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
		if(i_GiveCashBuilding[owner] < MAX_CASH_VIA_BUILDINGS)
		{
			i_GiveCashBuilding[owner] += Cash;
			GiveCredits(owner, Cash, true);
		}
	}
	else
	{
		//This building doesnt affect the limit.
		CashRecievedNonWave[owner] += Cash;
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
	if(SupplyLimit)
	{
		if(i_GiveAmmoSupplyLimit[owner] < MAX_SUPPLIES_EACH_WAVE)
		{
			i_GiveCashBuilding[owner] += ConvertedAmmoSupplyGive;
			Ammo_Count_Used[owner] -= ConvertedAmmoSupplyGive;
		}
	}
	else
	{
		Ammo_Count_Used[owner] -= ConvertedAmmoSupplyGive;
	}

}

void Building_MapStart()
{
	PrecacheSound(SOUND_GRAB_TF, true);
	PrecacheSound(SOUND_TOSS_TF, true);
	Zero(GrabThrottle);
	Zero(PlayerWasHoldingProp);
}

// Called after NPC_ConfigSetup()
void Building_ConfigSetup()
{
	for(int i; i < sizeof(BuildingPlugin); i++)
	{
		BuildingId[i] = NPC_GetByPlugin(BuildingPlugin[i]);
		if(BuildingId[i] == -1)
			LogError("NPC '%s' is missing in building.sp", BuildingPlugin[i]);
	}

	Zero2(Cooldowns);
}

void Building_WaveEnd()
{
	//Zero2(Cooldowns);
}

public void Building_OpenMenuWeapon(int client, int weapon, bool crit, int slot)
{
	MenuPage[client] = 0;
	if(MenuTimer[client] != null)
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

static int GetCost(int id, float multi)
{
	int buildCost = BuildingCost[id];
	int cost_extra = RoundFloat(BuildingHealth[id] * multi / 2.4);
	if(cost_extra <= 0)
	{
		cost_extra = 0;
	}
	buildCost = buildCost + cost_extra;

	if(Rogue_Mode())
		buildCost /= 3;
	
	return buildCost;
}

static void BuildingMenu(int client)
{
	if(MenuTimer[client] || !HasWrench(client))
		return;
	
	int metal = GetAmmo(client, Ammo_Metal);
	int cash = CurrentCash - CashSpent[client];
	float multi = Object_GetMaxHealthMulti(client);
	float gameTime = GetGameTime();
	bool ducking = view_as<bool>(GetClientButtons(client) & IN_DUCK);

	SetGlobalTransTarget(client);

	static const int ItemsPerPage = 5;

	Menu menu = new Menu(BuildingMenuH);
	SetGlobalTransTarget(client);

	menu.SetTitle("%t\n ", "Building Menu");

	char buffer1[196], buffer2[64];

	if(ducking)
	{
		menu.AddItem(buffer1, buffer1, ITEMDRAW_SPACER);
		menu.AddItem(buffer1, buffer1, ITEMDRAW_SPACER);
	}
	else
	{
		FormatEx(buffer1, sizeof(buffer1), "%t", "Extra Menu");
		menu.AddItem(buffer1, buffer1, ITEMDRAW_DEFAULT);

		FormatEx(buffer1, sizeof(buffer1), "%t x10 [%d] ($%d)\n ", "Scrap Metal", AmmoData[Ammo_Metal][1] * 10, AmmoData[Ammo_Metal][0] * 10);
		menu.AddItem(buffer1, buffer1, cash < (AmmoData[Ammo_Metal][0] * 10) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}

	int items;
	for(int i; i < sizeof(BuildingPlugin); i++)
	{
		int cost = GetCost(i, multi);
		int count;
		int maxcount = 99;
		bool allowed;
		
		float cooldown = Cooldowns[client][i] - gameTime;
		if(cooldown > 9999.9)
			continue;

		if(BuildingFunc[i] != INVALID_FUNCTION)
			allowed = Object_CanBuild(BuildingFunc[i], client, count, maxcount);
		
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

		if(cost > metal)
			allowed = false;
		
		if(Waves_InSetup())
		{
			cooldown = 0.0;
		}
		else if(cooldown > 0.0)
		{
			allowed = false;
		}

		NPC_GetNameById(BuildingId[i], buffer1, sizeof(buffer1));

		if(ducking)
		{
			FormatEx(buffer2, sizeof(buffer2), "%s Desc", buffer1);
			if(!TranslationPhraseExists(buffer2))
				strcopy(buffer2, sizeof(buffer2), buffer1);

			int alive = Object_NamedBuildings(_, BuildingPlugin[i]);
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

	if(menu.ItemCount <= 2)
	{
		delete menu;
		//retry
		MenuPage[client] = 0;
		BuildingMenu(client);
		return;
	}

	for(int i = menu.ItemCount; i < (MenuPage[client] ? 7 : 8); i++)
	{
		menu.AddItem(buffer2, buffer2, ITEMDRAW_SPACER);
	}
	
	if(MenuPage[client])
	{
		FormatEx(buffer2, sizeof(buffer2), "%t", "Previous");
		menu.AddItem(buffer2, buffer2);
	}
	
	if(sizeof(BuildingPlugin) > ((MenuPage[client] + 1) * ItemsPerPage))
	{
		FormatEx(buffer2, sizeof(buffer2), "%t", "Next");
		menu.AddItem(buffer2, buffer2);
	}

	menu.Pagination = 0;
	menu.ExitButton = true;

	if(menu.Display(client, 2))
		MenuTimer[client] = CreateTimer(0.5, Timer_RefreshMenu, client);
}

static int BuildingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(MenuTimer[client] != null)
				delete MenuTimer[client];
		}
		case MenuAction_Select:
		{
			if(MenuTimer[client] != null)
				delete MenuTimer[client];

			if(HasWrench(client))
			{
				switch(choice)
				{
					case 0:
					{
						BuilderMenu(client);
						return 0;
					}
					case 1:
					{
						CashSpent[client] += AmmoData[Ammo_Metal][0] * 10;
						CashSpentTotal[client] += AmmoData[Ammo_Metal][0] * 10;
						ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
						
						int ammo = GetAmmo(client, Ammo_Metal) + (AmmoData[Ammo_Metal][1] * 10);
						SetAmmo(client, Ammo_Metal, ammo);
						CurrentAmmo[client][Ammo_Metal] = ammo;
					}
					case 7:
					{
						MenuPage[client]--;
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
							if(id > sizeof(BuildingPlugin))
							{		
								BuildingMenu(client);
								return 0;
							}

							int metal = GetAmmo(client, Ammo_Metal);
							int cost = GetCost(id, Object_GetMaxHealthMulti(client));

							if(metal >= cost && (BuildingFunc[id] == INVALID_FUNCTION || Object_CanBuild(BuildingFunc[id], client)))
							{
								float vecPos[3], vecAng[3];
								GetClientAbsOrigin(client, vecPos);
								GetClientEyeAngles(client, vecAng);
								vecAng[0] = 0.0;
								vecAng[2] = 0.0;

								int entity = NPC_CreateById(BuildingId[id], client, vecPos, vecAng, GetTeam(client));
								if(entity != -1)
								{
									ObjectGeneric obj = view_as<ObjectGeneric>(entity);
									BuildingFuncSave[entity] = BuildingFunc[id];
									obj.BaseHealth = BuildingHealth[id];
									int health = GetEntProp(obj.index, Prop_Data, "m_iHealth");
									int maxhealth = GetEntProp(obj.index, Prop_Data, "m_iMaxHealth");
									int expected = RoundFloat(obj.BaseHealth * Object_GetMaxHealthMulti(client));
									if(maxhealth && expected && maxhealth != expected)
									{
										float change = float(expected) / float(maxhealth);

										maxhealth = expected;
										health = RoundFloat(float(health) * change);
										int maxrepair = RoundFloat(float(GetEntProp(obj.index, Prop_Data, "m_iRepairMax")) * change);
										int repair = RoundFloat(float(GetEntProp(obj.index, Prop_Data, "m_iRepair")) * change);
										
										SetEntProp(obj.index, Prop_Data, "m_iMaxHealth", maxhealth);
										SetEntProp(obj.index, Prop_Data, "m_iHealth", health);
										SetEntProp(obj.index, Prop_Data, "m_iRepairMax", maxrepair);
										SetEntProp(obj.index, Prop_Data, "m_iRepair", repair);
									}
									GiveBuildingMetalCostOnBuy(entity, cost);

									Building_PlayerWieldsBuilding(client, entity);
									Barracks_UpdateEntityUpgrades(entity, client, true, _);

									metal -= cost;
									SetAmmo(client, Ammo_Metal, metal);
									CurrentAmmo[client][Ammo_Metal] = metal;
									float CooldownGive = BuildingCooldown[id];
									if(Rogue_Mode())
										CooldownGive *= 0.5;
										
									Cooldowns[client][id] = GetGameTime() + CooldownGive;
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
				PrintCenterText(client, "%t", "Revive Teammate tooltip");
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
					PrintCenterText(client, "%t", "Claim this building");
				}
				else if(Building_Collect_Cooldown[entity][client] > GetGameTime())
				{
					float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
					
					if(Building_Picking_up_cd <= 0.0)
						Building_Picking_up_cd = 0.0;
					
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
				}
				else if(Object_ShowInteractHud(client, entity))
				{
					Hide_Hud = false;
				}
			}
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

public void Pickup_Building_M2(int client, int weapon, bool crit)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
	{
		int buildingindx = EntRefToEntIndex(Player_BuildingBeingCarried[client]);
		
		float VecPos[3];
		GetEntPropVector(buildingindx, Prop_Data, "m_vecAbsOrigin", VecPos);
		float VecMin[3];
		float VecMax[3];
		VecMin = f3_CustomMinMaxBoundingBox[buildingindx];
		VecMin[0] *= -1.0;
		VecMin[1] *= -1.0;
		VecMin[2] = 0.0;
		VecMax = f3_CustomMinMaxBoundingBox[buildingindx];

		b_ThisEntityIgnoredBeingCarried[buildingindx] = false;
		bool Success = BuildingSafeSpot(buildingindx, VecPos, VecMin, VecMax);
		if(!Success)
		{
			b_ThisEntityIgnoredBeingCarried[buildingindx] = true;
			CanBuild_VisualiseAndWarn(client, buildingindx, true, VecPos);
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		
		//do we want to build on anothrer building?
		int buildingHit;
		float endPos[3];
		if(IsValidGroundBuilding(VecPos , 70.0, endPos, buildingHit, buildingindx)) //130.0
		{
			float endPos2[3];
			GetEntPropVector(buildingHit, Prop_Data, "m_vecAbsOrigin", endPos2);
			//We use custom offets for buildings, so we do our own magic here
			float Delta = f3_CustomMinMaxBoundingBox[buildingHit][2];
			//Be sure to now set all the things we need.
			//Set the dependency
			endPos2[0] = VecPos[0];
			endPos2[1] = VecPos[1];
			endPos2[2] += Delta;
			i_IDependOnThisBuilding[buildingindx] = EntIndexToEntRef(buildingHit);
			CanBuild_VisualiseAndWarn(client, buildingindx, false, endPos2);
			SDKCall_SetLocalOrigin(buildingindx, endPos2);	
			SDKUnhook(buildingindx, SDKHook_Think, BuildingPickUp);
			Player_BuildingBeingCarried[client] = 0;
			Building_BuildingBeingCarried[buildingindx] = 0;
			b_ThisEntityIgnored[buildingindx] = false;
			b_ThisEntityIsAProjectileForUpdateContraints[buildingindx] = false;
			EmitSoundToClient(client, SOUND_TOSS_TF);
			return;
		}
		Success = Building_IsValidGroundFloor(client, buildingindx, VecPos);
		if(!Success)
		{
			b_ThisEntityIgnoredBeingCarried[buildingindx] = true;
			CanBuild_VisualiseAndWarn(client, buildingindx, true, VecPos);
			return;
		}
		if(Success)
		{
			SDKCall_SetLocalOrigin(buildingindx, VecPos);	
			SDKUnhook(buildingindx, SDKHook_Think, BuildingPickUp);
			Player_BuildingBeingCarried[client] = 0;
			Building_BuildingBeingCarried[buildingindx] = 0;
			b_ThisEntityIgnored[buildingindx] = false;
			b_ThisEntityIsAProjectileForUpdateContraints[buildingindx] = false;
			EmitSoundToClient(client, SOUND_TOSS_TF);
		}
		return;
	}
	int entity = GetClientPointVisible(client, 150.0 , false, false,_,1);
	if(entity < MaxClients)	
		return;

	if (!IsValidEntity(entity))
		return;

	if (!i_IsABuilding[entity])
		return;

	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client)
		return;

	Building_PlayerWieldsBuilding(client, entity);
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
	
	TeleportEntity(BuildingNPC, VecCheckBottom, vecView2, NULL_VECTOR);
}


bool BuildingSafeSpot(int client, float endPos[3], float hullcheckmins_Player[3], float hullcheckmaxs_Player[3])
{
	bool FoundSafeSpot = false;
	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition_Building(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	for (int x = 0; x < 6; x++)
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

			case 4:
				endPos[2] += TELEPORT_STUCK_CHECK_3;

			case 5:
				endPos[2] -= TELEPORT_STUCK_CHECK_3;	
		}
		for (int y = 0; y < 7; y++)
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

				case 5:
					endPos[1] += TELEPORT_STUCK_CHECK_3;

				case 6:
					endPos[1] -= TELEPORT_STUCK_CHECK_3;	
			}

			for (int z = 0; z < 7; z++)
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

					case 5:
						endPos[0] += TELEPORT_STUCK_CHECK_3;

					case 6:
						endPos[0] -= TELEPORT_STUCK_CHECK_3;
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
		CanBuild_VisualiseAndWarn(client, buildingindx, true,VecBottom);
		return false;
	}
	VecBottom = VecCheckBottom;
	CanBuild_VisualiseAndWarn(client, buildingindx, false, VecBottom);
	return true;
}

//The laser boxes and warnings.
void CanBuild_VisualiseAndWarn(int client, int entity, bool Fail = false, float VecBottom[3])
{
	float VecMin[3];
	float VecMax[3];
	VecMin = f3_CustomMinMaxBoundingBox[entity];
	VecMin[0] *= -1.0;
	VecMin[1] *= -1.0;
	VecMin[2] = 0.0;
	VecMax = f3_CustomMinMaxBoundingBox[entity];
	float VecLaser[3];
	VecLaser = VecBottom;
	if(Fail)
	{
		TE_DrawBox(client, VecLaser, VecMin, VecMax, 0.5, view_as<int>({255, 0, 0, 255}));
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client, 255, 0, 0);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Build Here");	
	}
	else
	{
		TE_DrawBox(client, VecLaser, VecMin, VecMax, 0.5, view_as<int>({0, 255, 0, 255}));
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Can Build Here");	
	}
}


//Derived from function in SMLIB
stock bool IsValidGroundBuilding(const float pos[3], float distance, float posEnd[3], int& buildingHit, int self)
{
	bool foundbuilding = false;
	Handle trace = TR_TraceRayFilterEx(pos, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID, RayType_Infinite, TraceRayFilterBuildOnBuildings, self);

	if (TR_DidHit(trace))
	{
		int EntityHit = TR_GetEntityIndex(trace);

		if (EntityHit <= 0 || EntityHit==self)
		{
			delete trace;
			return false;
		}

		if(!i_IsABuilding[EntityHit])
		{
			delete trace;
			return false;
		}
		//no multi stacking
		if(IsValidEntity(i_IDependOnThisBuilding[EntityHit]))
		{
			delete trace;
			return false;
		}


		TR_GetEndPosition(posEnd, trace);

		if (GetVectorDistance(pos, posEnd, true) <= (distance * distance))
		{
			foundbuilding = true;
			buildingHit = EntityHit;
		}
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

	if(i_IsABuilding[entity]) // We don't want to build on teleporters(exploits, stuck, ...) You know what i mean.
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
				SDKHooks_TakeDamage(building, 0, 0, 1000000.0, DMG_CRUSH);
				return;
			}
			TeleportEntity(building, endPos2, NULL_VECTOR, NULL_VECTOR);
			//we hit something
		}
		else
		{
			SDKHooks_TakeDamage(building, 0, 0, 1000000.0, DMG_CRUSH);
			return;
		}
	}
	m_vecMaxs = view_as<float>( { 20.0, 20.0, 50.0 } );
	m_vecMins = view_as<float>( { -20.0, -20.0, 35.0 } );	
	//Check if half of the top half of the building is inside a wall, if it is, detroy, if it is not, then we leave it be.
	if(IsSpaceOccupiedWorldOnly(endPos2, m_vecMins, m_vecMaxs, building))
	{
		SDKHooks_TakeDamage(building, 0, 0, 1000000.0, DMG_CRUSH);
	}
}

//Make sure all buildings are placed correctly
void Building_RotateAllDepencencies(int entityLost = 0)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if(!IsValidEntity(i))
			continue;
			
		if(EntRefToEntIndex(i_IDependOnThisBuilding[i]) == entityLost)
		{
			BuildingAdjustMe(i, entityLost);
		}
	}
}


//Make sure all buildings are placed correctly
void BuildingAdjustMe(int building, int DestroyedBuilding)
{
	float posMain[3]; 
	GetEntPropVector(building, Prop_Data, "m_vecAbsOrigin", posMain);
	float posStacked[3]; 
	GetEntPropVector(DestroyedBuilding, Prop_Data, "m_vecAbsOrigin", posStacked);

//	posMain = posStacked;
	posMain[2] = posStacked[2];	
	
	TeleportEntity(building, posMain, NULL_VECTOR, NULL_VECTOR);
	//make npc's that target the previous building target the stacked one now.
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int INpc = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
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
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, _, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	
	delete swingTrace;
	Allowbuildings_BulletAndMeleeTraceAllyLogic(false);
	
	if(target < 0)
		return;
	
	if(!i_IsABuilding[target])
	{
		return;
	}
	int max_health = GetEntProp(target, Prop_Data, "m_iMaxHealth");
	int flHealth = GetEntProp(target, Prop_Data, "m_iHealth");
	
	if(flHealth >= max_health)
	{
		EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70);
		return;
	}

	int new_ammo = GetAmmo(client, 3);

	float RepairRate = Attributes_Get(weapon, 95, 1.0);
	RepairRate *= Attributes_GetOnPlayer(client, 95, true, true);

	RepairRate *= 10.0;

	int i_HealingAmount = RoundToCeil(RepairRate);
	int newHealth = flHealth + i_HealingAmount;

	if(newHealth >= max_health)
	{
		i_HealingAmount -= newHealth - max_health;
		newHealth = max_health;
	}
	if(GetEntProp(target, Prop_Data, "m_iRepair") < i_HealingAmount)
	{
		i_HealingAmount = GetEntProp(target, Prop_Data, "m_iRepair");
	}
	if(i_HealingAmount <= 0)
	{
		EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70);
		return;
	}
	int Healing_Value = i_HealingAmount;
	
	int Remove_Ammo = i_HealingAmount / 3;
	
	if(Remove_Ammo < 0)
	{
		Remove_Ammo = 0;
	}
	
	int HealGiven;
	if(newHealth >= 1 && Healing_Value >= 1) //for some reason its able to set it to 1
	{
		HealGiven = HealEntityGlobal(client, target, float(Healing_Value), _, _, _, new_ammo / 3);
		if(HealGiven <= 0)
		{
			EmitSoundToAll("weapons/wrench_hit_build_fail.wav", client, SNDCHAN_AUTO, 70);
			return;
		}
		SetEntProp(target, Prop_Data, "m_iRepair", GetEntProp(target, Prop_Data, "m_iRepair") - HealGiven);
		if(GetEntProp(target, Prop_Data, "m_iRepair") < 0)
		{
			SetEntProp(target, Prop_Data, "m_iRepair", 0);
		}
		TE_Particle("halloween_boss_axe_hit_sparks", vecHit, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		switch(GetRandomInt(0,1))
		{
			case 0:
			{
				EmitSoundToAll("weapons/wrench_hit_build_success1.wav", client, SNDCHAN_AUTO, 70);
			}
			case 1:
			{
				EmitSoundToAll("weapons/wrench_hit_build_success2.wav", client, SNDCHAN_AUTO, 70);
			}
		}
	}
	new_ammo -= HealGiven / 3;
	SetAmmo(client, 3, new_ammo);
	CurrentAmmo[client][3] = GetAmmo(client, 3);
}			


void Barracks_UpdateEntityUpgrades(int entity, int client, bool firstbuild = false, bool BarracksUpgrade = false)
{
	if(i_IsABuilding[entity] && b_NpcHasDied[entity])
	{
		if(!GlassBuilder[entity] && b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			SetBuildingMaxHealth(entity, 0.25, false, true);
		}
		if(GlassBuilder[entity] && !b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			SetBuildingMaxHealth(entity, 0.25, false, true ,true);
		}
		if(!HasMechanic[entity] && b_HasMechanic[client])
		{
			HasMechanic[entity] = true;
			SetBuildingMaxHealth(entity, 1.15, false, firstbuild);
		}
		if(HasMechanic[entity] && !b_HasMechanic[client])
		{
			HasMechanic[entity] = false;
			SetBuildingMaxHealth(entity, 1.15, true, false);
		}
		static char plugin[64];
		NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
		if(StrContains(plugin, "obj_barracks", false) != -1)
		{
			
			float healthMult = 1.0;
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER) && !(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_TOWER))
			{
				healthMult *= 1.3;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_TOWER;
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

			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_GUARD_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_GUARD_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_GUARD_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)&& (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_DONJON)))
			{
				healthMult *= 1.3;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_DONJON;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_KREPOST) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_KREPOST)))
			{
				healthMult *= 1.4;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_KREPOST;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CASTLE) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_CASTLE)))
			{
				healthMult *= 1.6;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_CASTLE;
			}
			if(healthMult > 1.0)
			{
				SetBuildingMaxHealth(entity, healthMult, false, true);
			}
		}
	}
	
	if(!b_NpcHasDied[entity] && !i_IsABuilding[entity])
	{
		if(!FinalBuilder[entity] && FinalBuilder[client])
		{
			FinalBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.35;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.8;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.35));
		}
		if(!WildingenBuilder[entity] && WildingenBuilder[client])
		{
			WildingenBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.55;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.7;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.7));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.7));
		}
		if(FinalBuilder[entity] && !FinalBuilder[client])
		{
			FinalBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.35;			
			view_as<BarrackBody>(entity).BonusFireRate /= 0.8;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 1.35));
		}
		if(!GlassBuilder[entity] && GlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.15;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 0.8));
		}
		if(GlassBuilder[entity] && !GlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.15;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 0.8));
		}

		//	
		//	//FOR PERK MACHINE!
		//	public const char PerkNames[][] =
		//	{
		//		"No Perk", //unused
		//		"Quick Revive", //get extra healing, see heal code?
		//		"Juggernog",	
		//		"Double Tap",
		//		"Speed Cola",
		//		"Replicate_Damage_Medicationsdshot Daiquiri",
		//		"Widows Wine",
		//		"Recycle Poire"
		//	};
		//	
		//double tap
		if(i_CurrentEquippedPerk[entity] != 3 && i_CurrentEquippedPerk[client] == 3)
		{
			view_as<BarrackBody>(entity).BonusFireRate *= 0.85;
		}
		if(i_CurrentEquippedPerk[entity] == 3 && i_CurrentEquippedPerk[client] != 3)
		{
			view_as<BarrackBody>(entity).BonusFireRate /= 0.85;
		}
		//juggernog
		if(i_CurrentEquippedPerk[entity] != 2 && i_CurrentEquippedPerk[client] == 2)
		{
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.15));

			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.15));
		}
		if(i_CurrentEquippedPerk[entity] == 2 && i_CurrentEquippedPerk[client] != 2)
		{
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.15));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 1.15));
		}
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFINED_MEDICINE) &&!(i_EntityRecievedUpgrades[entity] & ZR_UNIT_UPGRADES_REFINED_MEDICINE))
		{
			i_EntityRecievedUpgrades[entity] |= ZR_UNIT_UPGRADES_REFINED_MEDICINE;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.1));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.1));
		}
		i_CurrentEquippedPerk[entity] = i_CurrentEquippedPerk[client];
	}
}


void SetBuildingMaxHealth(int entity, float Multi, bool reduce, bool initial = false, bool inversehealth = false)
{
	if(reduce)
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", 		RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) 		/ Multi));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", 	RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth"))	/ Multi));
		SetEntProp(entity, Prop_Data, "m_iRepair",		RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iRepair")) 		/ Multi));
		SetEntProp(entity, Prop_Data, "m_iRepairMax", 	RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iRepairMax")) 	/ Multi));
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * Multi));
		SetEntProp(entity, Prop_Data, "m_iRepairMax", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iRepairMax")) * Multi));
		
		if(initial)
		{
			int HealthToSet = RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * Multi);
			int RepairToSet = RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iRepair")) * Multi);

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
			return 1.85;
		}
		default:
		{
			return 1.0;
		}
	}
}

public bool BuildingCustomCommand(int client)
{
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
	if(IsValidEntity(i2_MountedInfoAndBuilding[0][client]) || IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
	{
		UnequipDispenser(client);
		return;
	}
	if(IsPlayerCarringObject(client))
	{
		Pickup_Building_M2(client, -1, false);
		return;
	}
	int entity = GetClientPointVisible(client, 150.0 , false, false,_,1);
	if(entity < MaxClients)
	{
		return;
	}
	if (!IsValidEntity(entity))
	{
		return;
	}
	if(!i_IsABuilding[entity])
	{
		return;
	}
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client)
	{
		return;
	}

	Building_RotateAllDepencencies(entity);
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	float ModelScale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
	ModelScale *= 0.33;

	b_ThisEntityIgnored[entity] = true;
	b_ThisEntityIsAProjectileForUpdateContraints[entity] = true;
	
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelScale);
	if(IsValidEntity(objstats.m_iWearable1))
	{
		SetEntPropFloat(objstats.m_iWearable1, Prop_Send, "m_flModelScale", ModelScale);
		b_IsEntityAlwaysTranmitted[objstats.m_iWearable1] = true;		
		SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
	}

	if(IsValidEntity(objstats.m_iWearable2))
	{
		SetEntPropFloat(objstats.m_iWearable2, Prop_Send, "m_flModelScale", ModelScale);
		b_IsEntityAlwaysTranmitted[objstats.m_iWearable2] = true;		
		SDKUnhook(objstats.m_iWearable2, SDKHook_SetTransmit, SetTransmit_BuildingReady);
	}

	if(IsValidEntity(objstats.m_iWearable3))
	{
		SetVariantString("0");
		AcceptEntityInput(objstats.m_iWearable3, "SetTextSize");
	}
	if(IsValidEntity(objstats.m_iWearable4))
	{
		SetVariantString("0");
		AcceptEntityInput(objstats.m_iWearable4, "SetTextSize");
	}
	if(IsValidEntity(objstats.m_iWearable5))
	{
		SetVariantString("6");
		AcceptEntityInput(objstats.m_iWearable5, "SetTextSize");
		SDKUnhook(objstats.m_iWearable5, SDKHook_SetTransmit, SetTransmit_BuildingReadyTestThirdPersonIgnore);
		SDKHook(objstats.m_iWearable5, SDKHook_SetTransmit, SetTransmit_BuildingReadyTestThirdPersonIgnore);
	}
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
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
	GetAttachment(Wearable, "flag", flPos, flAng);

	int InfoTarget = InfoTargetParentAt(flPos,"", 0.0);
	SetParent(Wearable, InfoTarget, "flag",_);
	SDKCall_SetLocalOrigin(entity, flPos);	
	SetEntPropVector(entity, Prop_Data, "m_angRotation", flAng);
	SetParent(InfoTarget, entity, _, _, _);
	i2_MountedInfoAndBuilding[0][client] = EntIndexToEntRef(InfoTarget);
}

static Handle Timer_TransferOwnerShip[MAXTF2PLAYERS];

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
		Building_Mounted[client] = 0;
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
	
	Building_Mounted[client] = 0;
	int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
	if(IsValidEntity(i2_MountedInfoAndBuilding[1][client]))
	{
		float posStacked[3]; 
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
		AcceptEntityInput(i2_MountedInfoAndBuilding[1][client], "ClearParent");
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
	Building_Mounted[entity] = 0;
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
		SDKUnhook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
		SDKHook(objstats.m_iWearable1, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
	}

	if(IsValidEntity(objstats.m_iWearable2))
	{
		SetEntPropFloat(objstats.m_iWearable2, Prop_Send, "m_flModelScale", ModelScale);
		b_IsEntityAlwaysTranmitted[objstats.m_iWearable2] = false;
	//	SetEntPropFloat(objstats.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);		
		SDKUnhook(objstats.m_iWearable2, SDKHook_SetTransmit, SetTransmit_BuildingReady);
		SDKHook(objstats.m_iWearable2, SDKHook_SetTransmit, SetTransmit_BuildingReady);	
	}

	if(IsValidEntity(objstats.m_iWearable3))
	{
		SetVariantString("6");
		AcceptEntityInput(objstats.m_iWearable3, "SetTextSize");
	}
	if(IsValidEntity(objstats.m_iWearable4))
	{
		SetVariantString("6");
		AcceptEntityInput(objstats.m_iWearable4, "SetTextSize");
	}
	if(IsValidEntity(objstats.m_iWearable5))
	{
		SetVariantString("0");
		AcceptEntityInput(objstats.m_iWearable5, "SetTextSize");
		SDKUnhook(objstats.m_iWearable5, SDKHook_SetTransmit, SetTransmit_BuildingReadyTestThirdPersonIgnore);
	}

	Building_PlayerWieldsBuilding(client, entity);
}

bool BuildingValidPositionFinal(float AbsOrigin[3], int entity)
{
	float VecMax[3];
	float VecMin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecMaxs", VecMax);
	GetEntPropVector(entity, Prop_Data, "m_vecMins", VecMin);

	//is inside a trigger hurt zone
	if(IsBoxHazard(AbsOrigin,VecMin,VecMax))
	{
		return false;
	}
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
	if(IsValidClient(client))
	{
		int Repair = 	GetEntProp(entity, Prop_Data, "m_iRepair");
		int MaxRepair = GetEntProp(entity, Prop_Data, "m_iRepairMax");
		int Health = 	GetEntProp(entity, Prop_Data, "m_iHealth");
		int MaxHealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
		
		int MaxTotal = MaxRepair + MaxHealth;
		int Total = Repair + Health;

		float RatioReturn = float(Total) / float(MaxTotal);
		
		int MetalReturn = RoundToNearest(MetalSpendOnBuilding[entity] * RatioReturn * 0.8);
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
		int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
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
