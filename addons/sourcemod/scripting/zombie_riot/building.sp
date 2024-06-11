#pragma semicolon 1
#pragma newdecls required

static const char BuildingPlugin[][] =
{
	"obj_barricade",
	"obj_ammobox"
};

// Base metal cost of building
static const int BuildingCost[sizeof(BuildingPlugin)] =
{
	1000,
	4000
};

// Base health of building
static const int BuildingHealth[sizeof(BuildingPlugin)] =
{
	6000,
	750
};

// Max storage of building
static const int BuildingSupply[sizeof(BuildingPlugin)] =
{
	3,
	3,
};

static const char BuildingFuncName[sizeof(BuildingPlugin)][] =
{
	"ObjectBarricade_CanBuild",
	"ObjectGeneric_CanBuild"
};

static int BuildingId[sizeof(BuildingPlugin)];
static Function BuildingFunc[sizeof(BuildingPlugin)];
static int Consumed[MAXTF2PLAYERS][sizeof(BuildingPlugin)];
static int MenuPage[MAXTF2PLAYERS];
static Handle MenuTimer[MAXTF2PLAYERS];

void Building_PluginStart()
{
	for(int i; i < sizeof(BuildingFuncName); i++)
	{
		BuildingFunc[i] = GetFunctionByName(null, BuildingFuncName[i]);
		if(BuildingFunc[i] == INVALID_FUNCTION)
			LogError("Function '%s' is missing in building.sp", BuildingFuncName[i]);
	}
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

	Zero2(Consumed);
}

void Building_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		for(int i; i < sizeof(Consumed[]); i++)
		{
			if(Consumed[client][i] > 0)
				Consumed[client][i]--;
		}
	}
}

public void Building_WrenchM2(int client, int weapon, bool crit, int slot)
{
	BuildingMenu(client);
}

static int GetCost(int id, float multi)
{
	return BuildingCost[id] + RoundFloat(BuildingHealth[id] * multi / 3.0);
}

static bool HasWrench(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1 || EntityFuncAttack2[weapon] != Building_WrenchM2)
		return false;
	
	return true;
}

static void BuildingMenu(int client)
{
	if(MenuTimer[client] || !HasWrench(client))
		return;
	
	int metal = GetAmmo(client, Ammo_Metal);
	float multi = Object_GetMaxHealthMulti(client);

	static const int ItemsPerPage = 3;

	Menu menu = new Menu(BuildingMenuH);

	menu.SetTitle("%t\n ", "Building Menu");

	char buffer1[196], buffer2[64];
	for(int i = MenuPage[client] * ItemsPerPage; i < sizeof(BuildingPlugin); i++)
	{
		int cost = GetCost(i, multi);
		int alive = Object_NamedBuildings(_, BuildingPlugin[i]);
		int count, maxcount;
		bool allowed;

		if(BuildingFunc[i] != INVALID_FUNCTION)
			allowed = Object_CanBuild(BuildingFunc[i], client, count, maxcount);
		
		if(cost > metal)
			allowed = false;

		NPC_GetNameById(BuildingId[i], buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "%s Desc", buffer1);
		Format(buffer1, sizeof(buffer1), "%t (%d %t) [%d/%d] {%d}", buffer1, cost, "Metal", count, maxcount, alive);
		if(TranslationPhraseExists(buffer2))
			Format(buffer1, sizeof(buffer1), "%s\n%t", buffer1, buffer2);

		IntToString(i, buffer2, sizeof(buffer2));
		menu.AddItem(buffer2, buffer1, allowed ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	for(int i; i < MenuPage[client] ? 7 : 8; i++)
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
		MenuTimer[client] = CreateTimer(1.0, Timer_RefreshMenu, client);
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
			delete MenuTimer[client];
		}
		case MenuAction_Select:
		{
			delete MenuTimer[client];

			if(HasWrench(client))
			{
				switch(choice)
				{
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
						char buffer[64];
						menu.GetItem(choice, buffer, sizeof(buffer));

						int id = StringToInt(buffer);
						PrintToChat(client, BuildingPlugin[id]);
					}
				}

				BuildingMenu(client);
			}
		}
	}
}

static Action Timer_RefreshMenu(Handle timer, int client)
{
	MenuTimer[client] = null;
	BuildingMenu(client);
}

void Barracks_UpdateAllEntityUpgrades(int client, bool first_upgrade = false, bool first_barracks = false)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if(IsValidEntity(i) && (i_IsABuilding[i] || !b_NpcHasDied[i])) //This isnt expensive.
		{
/*			BarrackBody npc = view_as<BarrackBody>(i);
			if(GetClientOfUserId(npc.OwnerUserId) == client && !b_NpcHasDied[i])
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
			else */
			if(i_IsABuilding[i] && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == client)
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
		}
	}
}

void Barracks_UpdateEntityUpgrades(int entity, int client, bool firstbuild = false, bool BarracksUpgrade = false)
{
	/*
	if(i_IsABuilding[entity] && b_NpcHasDied[entity])
	{
		if(!GlassBuilder[entity] && b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			SetBuildingMaxHealth(entity, 0.25, false, true,true);
		}
		if(GlassBuilder[entity] && !b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			if(firstbuild)
				SetBuildingMaxHealth(entity, 0.25, true, true ,true);
			else
				SetBuildingMaxHealth(entity, 0.25, true, _ ,true);

		}
		if(!HasMechanic[entity] && b_HasMechanic[client])
		{
			HasMechanic[entity] = true;

			if(firstbuild)
				SetBuildingMaxHealth(entity, 1.15, false, true);
			else
				SetBuildingMaxHealth(entity, 1.15, false);

		}
		if(HasMechanic[entity] && !b_HasMechanic[client])
		{
			HasMechanic[entity] = false;
			SetBuildingMaxHealth(entity, 1.15, true, false);
		}
		if(i_WhatBuilding[entity] == BuildingSummoner)
		{
			
			float healthMult = 1.0;
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER) && !(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_TOWER))
			{
				healthMult *= 1.3;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_TOWER;
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
				
				if(IsValidEntity(prop1))
				{
					SetEntityModel(prop1, "models/props_manor/clocktower_01.mdl");
					//"0.65" default
					SetEntPropFloat(prop1, Prop_Send, "m_flModelScale", 0.11); 
				}
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
	}*/
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

			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_", false) != -1)
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

stock void ApplyBuildingCollectCooldown(int building, int client, float Duration, bool IgnoreVotingExtraCD = false)
{
	if(CvarInfiniteCash.BoolValue)
	{
		Building_Collect_Cooldown[building][client] = 0.0;
	}
	//else if(GameRules_GetRoundState() == RoundState_BetweenRounds && !IgnoreVotingExtraCD)
	//{
	//	Building_Collect_Cooldown[building][client] = FAR_FUTURE;
	//}
	else
	{
		Building_Collect_Cooldown[building][client] = GetGameTime() + Duration;
	}
}


static int Building_BuildingBeingCarried[MAXENTITIES];
static int Player_BuildingBeingCarried[MAXTF2PLAYERS];
float f3_Building_KnockbackToTake[MAXENTITIES][3];

public void Pickup_Building_M2(int client, int weapon, bool crit)
{
	if(IsValidEntity(Player_BuildingBeingCarried[client]))
	{

		int buildingindx = EntRefToEntIndex(Player_BuildingBeingCarried[client]);
		
		float VecPos[3];
		GetEntPropVector(BuildingNPC, Prop_Send, "m_vecOrigin", VecPos);
		float VecMin[3];
		float VecMax[3];
		VecMin = f3_CustomMinMaxBoundingBox[buildingindx];
		VecMin[0] *= -1.0;
		VecMin[1] *= -1.0;
		VecMin[2] = 0.0;
		VecMax = f3_CustomMinMaxBoundingBox[buildingindx];

		bool Success = Npc_Teleport_Safe(buildingindx, VecPos, VecMin, VecMax, false, false);
		
		if(Success)
		{
			SDKUnhook(buildingindx, SDKHook_Think, BuildingPickUp);
			b_ThisEntityIgnoredBeingCarried[buildingindx] = false;
			Player_BuildingBeingCarried[client] = 0;
		}
		return;
	}
	int entity = GetClientPointVisible(client, _ , false, false,_,1);
	if(entity < MaxClients)
		return;

	if (!IsValidEntity(entity))
		return;

	if (!i_IsABuilding[entity])
		return;

	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client)
		return;

	SDKUnhook(entity, SDKHook_Think, BuildingPickUp);
	SDKHook(entity, SDKHook_Think, BuildingPickUp);
	Building_BuildingBeingCarried[entity] = EntIndexToEntRef(client);
	Player_BuildingBeingCarried[client] = EntIndexToEntRef(entity);
	b_ThisEntityIgnoredBeingCarried[entity] = true;
}

#define BUILDING_DISTANCE_GRAB 100.0
void BuildingPickUp(int BuildingNPC)
{
	int client = EntRefToEntIndex(Building_BuildingBeingCarried[BuildingNPC]);
	if(!IsValidClient(client))
	{
		b_ThisEntityIgnoredBeingCarried[BuildingNPC] = false;
		SDKUnhook(BuildingNPC, SDKHook_Think, BuildingPickUp);
		return;
	}
	float vecView[3];
	float vecFwd[3];
	float vecPos[3];
	float vecVel[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);

	vecPos[0]+=vecFwd[0]* BUILDING_DISTANCE_GRAB;
	vecPos[1]+=vecFwd[1]* BUILDING_DISTANCE_GRAB;
	vecPos[2]+=vecFwd[2]* BUILDING_DISTANCE_GRAB;

	GetEntPropVector(BuildingNPC, Prop_Send, "m_vecOrigin", vecFwd);
	vecFwd[2] += 30.0;

	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 5.0);
	for(int i; i < 3; i++)
	{
		f3_Building_KnockbackToTake[BuildingNPC][i] = vecVel[i];
	}
	
	CBaseCombatCharacter npc = view_as<CBaseCombatCharacter>(BuildingNPC);
	npc.MyNextBotPointer().GetLocomotionInterface().Jump();
	CBaseNPC baseNPC = TheNPCs.FindNPCByEntIndex(BuildingNPC);
	baseNPC.GetLocomotion().SetVelocity(f3_Building_KnockbackToTake[BuildingNPC]);
}