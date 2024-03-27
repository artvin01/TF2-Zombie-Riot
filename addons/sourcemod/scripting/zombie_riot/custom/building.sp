#pragma semicolon 1
#pragma newdecls required

/*
	Placement Type
	static Handle SyncHud_Notifaction;
*/
#define CUSTOM_SENTRYGUN_MODEL	"models/zombie_riot/buildings/mortar_2.mdl"

#define HEALING_STATION_MODEL	"models/props_halloween/fridge.mdl"

#define MORTAR_SHOT	"weapons/mortar/mortar_fire1.wav"
#define MORTAR_BOOM	"beams/beamstart5.wav"

#define MORTAR_SHOT_INCOMMING	"weapons/mortar/mortar_shell_incomming1.wav"

#define MORTAR_RELOAD	"vehicles/tank_readyfire1.wav"


#define RAILGUN_PREPARE_SHOOT	"vehicles/apc/apc_start_loop3.wav"

#define RAILGUN_SHOOT	"ambient/explosions/explode_7.wav"


#define RAILGUN_START_CHARGE	"vehicles/apc/apc_shutdown.wav"

#define RAILGUN_END	"vehicles/apc/apc_slowdown_fast_loop5.wav"

#define RAILGUN_READY	"vehicles/tank_turret_start1.wav"

#define RAILGUN_READY_ALARM	"ambient/alarms/klaxon1.wav"

#define RAILGUN_ACTIVATED	"buttons/button1.wav"

#define PERKMACHINE_MODEL "models/props_farm/welding_machine01.mdl"

#define PACKAPUNCH_MODEL "models/props_spytech/computer_low.mdl"

#define VILLAGE_MODEL "models/props_rooftop/roof_dish001.mdl"
#define VILLAGE_MODEL_LIGHTHOUSE "models/props_sunshine/lighthouse_top_skybox.mdl"
#define VILLAGE_MODEL_MIDDLE "models/props_urban/urban_skybuilding005a.mdl"
#define VILLAGE_MODEL_REBEL "models/egypt/tent/tent.mdl"

//#define BARRICADE_MODEL "models/props_c17/concrete_barrier001a.mdl"
#define BARRICADE_MODEL "models/props_gameplay/sign_barricade001a.mdl"

#define ELEVATOR_MODEL "models/props_mvm/mvm_museum_pedestal.mdl"

#define SUMMONER_MODEL	"models/props_island/parts/guard_tower01.mdl"

#define BUILDINGCOLLISIONNUMBER	24

#define MAX_REBELS_ALLOWED 4

enum
{
	BuildingNone = 0,
	BuildingBarricade = 1,
	BuildingElevator = 2,
	BuildingAmmobox = 3,
	BuildingArmorTable = 4,
	BuildingPerkMachine = 5,
	BuildingPackAPunch = 6,
	BuildingRailgun = 7,
	BuildingSentrygun = 8,
	BuildingMortar = 9,
	BuildingHealingStation = 10,
	BuildingSummoner = 11,
	BuildingVillage = 12,
	BuildingBlacksmith = 13
}
enum
{
	EMPTY 							= 0,
	UNIT_COPPER_SMITH 				= 1,
	UNIT_IRON_CASTING 				= 2,
	UNIT_STEEL_CASTING 				= 3,
	UNIT_REFINED_STEEL 				= 4,
	
	
	UNIT_FLETCHING 					= 5,
	UNIT_STEEL_ARROWS 				= 6,
	UNIT_BRACER 					= 7,
	UNIT_OBSIDIAN_REFINED_TIPS 		= 8,
		
	UNIT_COPPER_ARMOR_PLATE 		= 9,
	UNIT_IRON_ARMOR_PLATE 			= 10,
	UNIT_CHAINMAIL_ARMOR 			= 11,
	UNIT_REFORGED_ARMOR_PLATE 		= 12,
	
	UNIT_HERBAL_MEDICINE 			= 13,
	UNIT_REFINED_MEDICINE 			= 14,

	BUILDING_TOWER					= 15,
	BUILDING_GUARD_TOWER			= 16,
	BUILDING_IMPERIAL_TOWER			= 17,
	BUILDING_BALLISTICAL_TOWER		= 18,
	BUILDING_DONJON					= 19,
	BUILDING_KREPOST				= 20,
	BUILDING_CASTLE					= 21,

	
	BUILDING_MANUAL_FIRE			= 22,
	
	BUILDING_MUDERHOLES				= 23,
	BUILDING_BALLISTICS				= 24,
	BUILDING_CHEMISTRY				= 25,
	BUILDING_CRENELATIONS			= 26,

	
	BUILDING_CONSCRIPTION			= 27,
	BUILDING_GOLDMINERS				= 28,

	BUILDING_ASSISTANT_VILLAGER		= 29,
	BUILDING_VILLAGER_EDUCATION		= 30,

	BUILDING_STRONGHOLDS			= 31,
	BUILDING_HOARDINGS				= 32,
	BUILDING_EXQUISITE_HOUSING		= 33,
	BUILDING_TROOP_CLASSES			= 34,
}

public const char BuildingUpgrade_Names[][] =
{
	"nothing",
	"Barracks Copper Smith",
	"Barracks Iron Casting",
	"Barracks Steel Casting",
	"Barracks Refined Steel",

	"Barracks Fletching",
	"Barracks Steel Arrows",
	"Barracks Bracer",
	"Barracks Obsidian Refined Tips",
	
	"Barracks Copper Armor Plate",
	"Barracks Iron Armor Plate",
	"Barracks Chainmail Armor",
	"Barracks Reforged Armor Plate",

	"Barracks Herbal Medicine",
	"Barracks Refined Medicine",

	"Barracks Tower",
	"Barracks Guard Tower",
	"Barracks Imperial Tower",
	"Barracks Ballistical Tower",
	"Barracks Donjon",
	"Barracks Krepost",
	"Barracks Castle",

	"Barracks Manual Fire",

	"Barracks Murder Holes",
	"Barracks Ballistics",
	"Barracks Chemistry",
	"Barracks Crenelations",

	"Barracks Conscription",
	"Barracks Goldminers",

	"Barracks Assistant Villager",
	"Barracks Villager Education",
	
	"Barracks Strongholds",
	"Barracks Hoardings",
	"Barracks Exquisite Housing",
	"Barracks Troop Classes",
};


enum struct VillageBuff
{
	int EntityRef;
	int VillageRef;
	int Effects;
	bool IsWeapon;
}

#define VILLAGE_000	(1 << 0)
#define VILLAGE_100	(1 << 1)
#define VILLAGE_200	(1 << 2)
#define VILLAGE_300	(1 << 3)
#define VILLAGE_400	(1 << 4)
#define VILLAGE_500	(1 << 5)
#define VILLAGE_010	(1 << 6)
#define VILLAGE_020	(1 << 7)
#define VILLAGE_030	(1 << 8)
#define VILLAGE_040	(1 << 9)
#define VILLAGE_050	(1 << 10)
#define VILLAGE_001	(1 << 11)
#define VILLAGE_002	(1 << 12)
#define VILLAGE_003	(1 << 13)
#define VILLAGE_004	(1 << 14)
#define VILLAGE_005	(1 << 15)

static float Village_ReloadBuffFor[MAXTF2PLAYERS];
static int Village_Flags[MAXTF2PLAYERS];
static bool Village_ForceUpdate[MAXTF2PLAYERS];
static ArrayList Village_Effects;
static int Village_TierExists[3];
static float f_VillageRingVectorCooldown[MAXENTITIES];
static float f_VillageSavingResources[MAXENTITIES];
static int i_VillageModelAppliance[MAXENTITIES];
static int i_VillageModelApplianceCollisionBox[MAXENTITIES];

//static int gLaser1;

static int Beam_Laser;
static int Beam_Glow;

static float f_MarkerPosition[MAXTF2PLAYERS][3];

Handle h_ClaimedBuilding[MAXPLAYERS + 1][MAXENTITIES];
static Handle h_Pickup_Building[MAXPLAYERS + 1];
static float Perk_Machine_Sickness[MAXTF2PLAYERS];

void Building_PluginStart()
{
	for(int i; i < MAXPLAYERS + 1; i++)
	{
		for(int i1; i1 < MAXENTITIES; i1++)
		{
			h_ClaimedBuilding[i][i1] = null;
		}
	}
}
void Building_MapStart()
{
	if(Village_Effects)
		delete Village_Effects;
	
	Village_Effects = new ArrayList(sizeof(VillageBuff));
	
	PrecacheModel(CUSTOM_SENTRYGUN_MODEL); //MORTAR MODEL AND RAILGUN MODEL!!!
	
	PrecacheSound(MORTAR_SHOT);
	PrecacheSound(MORTAR_BOOM); 
	PrecacheSound(MORTAR_SHOT_INCOMMING); 
	PrecacheSound(MORTAR_RELOAD); 
	
	PrecacheSound(RAILGUN_PREPARE_SHOOT); 
	PrecacheSound(RAILGUN_SHOOT);
	PrecacheSound(RAILGUN_START_CHARGE);
	PrecacheSound(RAILGUN_END);
	PrecacheSound(RAILGUN_READY);
	PrecacheSound(RAILGUN_ACTIVATED);
	PrecacheSound(RAILGUN_READY_ALARM);
	PrecacheModel("models/props_manor/clocktower_01.mdl");
	PrecacheSound("weapons/drg_wrench_teleport.wav");
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheModel("models/items/ammocrate_smg1.mdl");
	PrecacheModel("models/props_manor/table_01.mdl");
	PrecacheModel(PERKMACHINE_MODEL);
	
	PrecacheModel(PACKAPUNCH_MODEL);
	PrecacheModel(HEALING_STATION_MODEL);
	PrecacheModel(VILLAGE_MODEL);
	PrecacheModel(VILLAGE_MODEL_LIGHTHOUSE);
	PrecacheModel(VILLAGE_MODEL_MIDDLE);
	PrecacheModel(VILLAGE_MODEL_REBEL);
	PrecacheModel(BARRICADE_MODEL);
	PrecacheModel(ELEVATOR_MODEL);
	PrecacheModel(SUMMONER_MODEL);
	PrecacheModel("models/props_medieval/anvil.mdl");
	
	PrecacheSound("items/powerup_pickup_uber.wav");
	PrecacheSound("player/mannpower_invulnerable.wav");
	Zero(f_VillageRingVectorCooldown);
	Zero(f_VillageSavingResources);
	Zero(Perk_Machine_Sickness);
}

//static int RebelTimerSpawnIn;
//int Building_Hidden_Prop[MAXENTITIES][2];
static int Building_Hidden_Prop_To_Building[MAXENTITIES]={-1, ...};


static int i_HasSentryGunAlive[MAXTF2PLAYERS]={-1, ...};

bool Building_cannot_be_repaired[MAXENTITIES]={false, ...};

static float Building_Sentry_Cooldown[MAXTF2PLAYERS];

static int i_MachineJustClickedOn[MAXTF2PLAYERS];

void Building_ClearAll()
{
	Zero2(Building_Collect_Cooldown);
	Zero(Building_Sentry_Cooldown);
	Zero(Village_TierExists);
	//RebelTimerSpawnIn = 0;
}

void ResetSentryCD()
{
	Zero(Building_Sentry_Cooldown);
}

int Building_GetClientVillageFlags(int client)
{
	int applied;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	VillageBuff buff;
	int length = Village_Effects.Length;
	for(int i; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		int entity = EntRefToEntIndex(buff.EntityRef);
		if(entity == client || entity == weapon)
			applied |= buff.Effects;
	}

	return applied;
}

public Action Building_PlaceSentry(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Sentry, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public Action Building_PlaceMortar(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Mortar, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public Action Building_PlaceHealingStation(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_HealingStation, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public Action Building_PlaceRailgun(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Railgun, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public Action Building_PlaceDispenser(int client, int weapon, const char[] classname, bool &result)
{
	if(BarricadeMaxSupply(client) < MaxBarricadesAllowed(client))
	{
		PlaceBuilding(client, weapon, Building_DispenserWall, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Barricades, you have reached the max amount.");
	}
	return Plugin_Handled;	
}
	
public Action Building_PlaceElevator(int client, int weapon, const char[] classname, bool &result)
{
	if(Elevators_Currently_Build[client] < 3)
	{
		PlaceBuilding(client, weapon, Building_DispenserElevator, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Elevators, you have reached the max amount.");
	}
	return Plugin_Handled;	
}
public Action Building_PlaceAmmoBox(int client, int weapon, const char[] classname, bool &result)
{
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client, false))
	{
		PlaceBuilding(client, weapon, Building_AmmoBox, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
	}
	return Plugin_Handled;	
}

public Action Building_PlaceArmorTable(int client, int weapon, const char[] classname, bool &result)
{
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client, false))
	{
		PlaceBuilding(client, weapon, Building_ArmorTable, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
	}
	return Plugin_Handled;	
}

public Action Building_PlacePerkMachine(int client, int weapon, const char[] classname, bool &result)
{
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client, false))
	{
		PlaceBuilding(client, weapon, Building_PerkMachine, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
	}
	return Plugin_Handled;	
}

public Action Building_PlacePackAPunch(int client, int weapon, const char[] classname, bool &result)
{
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client, false))
	{
		PlaceBuilding(client, weapon, Building_PackAPunch, TFObject_Dispenser);
		return Plugin_Continue;		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
	}
	return Plugin_Handled;
}


/*
	Building Modifiers
*/
public bool Building_Sentry(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingSentrygun;
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = false;
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.5, Timer_DroppedBuildingWaitSentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 10.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	Barracks_UpdateEntityUpgrades(client, entity, true);
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	
//	CreateTimer(0.5, Timer_DroppedBuildingWaitSentryLeveLUp, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	return true;
}
public bool Building_Railgun(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingRailgun;
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
//	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.1, Timer_DroppedBuildingWaitRailgun, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	//This is so low because it has to update the animation very often, this is needed.
	//i dont want to use an sdkhook for this as i already have this here, and i dont think buildings have think, and it wouldnt be needed here
	//anyways as i have to reuse whats in there anyways.
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_railgun");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 10.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	Barracks_UpdateEntityUpgrades(client, entity, true);
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	
	return true;
}

public bool Building_Mortar(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingMortar;
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
//	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.1, Timer_DroppedBuildingWaitMortar, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	//This is so low because it has to update the animation very often, this is needed.
	//i dont want to use an sdkhook for this as i already have this here, and i dont think buildings have think, and it wouldnt be needed here
	//anyways as i have to reuse whats in there anyways.

	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)

	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_mortar");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 10.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	Barracks_UpdateEntityUpgrades(client, entity, true);
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	
	return true;
}

public bool Building_HealingStation(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingHealingStation;
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
//	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	DataPack pack;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitHealingStation, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	pack.WriteCell(client); //Need original client index id please.
//	SDKHook(entity, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmit);
	
	//This is so low because it has to update the animation very often, this is needed.
	//i dont want to use an sdkhook for this as i already have this here, and i dont think buildings have think, and it wouldnt be needed here
	//anyways as i have to reuse whats in there anyways.
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_healingstation");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 10.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	Barracks_UpdateEntityUpgrades(client, entity, true);
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	
	return true;
}

public Action Timer_DroppedBuildingWaitSentryLeveLUp(Handle htimer, int entref)
{
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		return Plugin_Stop;
	}
	int client=GetEntPropEnt(obj, Prop_Send, "m_hBuilder");
	if(!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed")>0.99)
	{
		int level = RoundFloat(Attributes_FindOnPlayerZR(client, 148))+1;
		SetEntProp(obj, Prop_Send, "m_iUpgradeLevel", level);
		
		switch(level)
		{
			case 2:
			{
				SetEntityModel(obj, "models/buildables/sentry2.mdl");
			}
			case 3:
			{
				SetEntityModel(obj, "models/buildables/sentry3.mdl");
			}
			default:
			{
				SetEntityModel(obj, "models/buildables/sentry1.mdl");
			}
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public bool Building_DispenserWall(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingBarricade;
	b_SentryIsCustom[entity] = false;

	DataPack pack;
	CreateDataTimer(0.5, Timer_ClaimedBuildingremoveBarricadeCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(client); //Need original client index id please.
	i_BarricadesBuild[client] += 1;

	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack_2;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitWall, pack_2, TIMER_REPEAT);
	pack_2.WriteCell(EntIndexToEntRef(entity));
	
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Constructed[entity] = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_barricade");
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public bool Building_DispenserElevator(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingElevator;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack;
	CreateDataTimer(0.5, Building_Is_Elevator_There, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Elevators_Currently_Build[client] += 1;
	Is_Elevator[entity] = true;
	Building_Constructed[entity] = false;
	Elevator_Owner[entity] = client;
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_elevator");
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 255, 255, 255, 150);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public bool Building_AmmoBox(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingAmmobox;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	if(h_ClaimedBuilding[client][entity] != null)
		delete h_ClaimedBuilding[client][entity];

	DataPack pack;
	h_ClaimedBuilding[client][entity] = CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(entity); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitAmmobox, pack_2, TIMER_REPEAT);
	pack_2.WriteCell(EntIndexToEntRef(entity));
	pack_2.WriteCell(entity);
	
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Constructed[entity] = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_ammobox");
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public bool Building_ArmorTable(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingArmorTable;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	if(h_ClaimedBuilding[client][entity] != null)
		delete h_ClaimedBuilding[client][entity];

	DataPack pack;
	h_ClaimedBuilding[client][entity] = CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(entity); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitArmorTable, pack_2, TIMER_REPEAT);
	pack_2.WriteCell(EntIndexToEntRef(entity));
	pack_2.WriteCell(entity);
	
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Constructed[entity] = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_armortable");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public bool Building_PerkMachine(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingPerkMachine;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	
//	SDKHook(entity, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmit);
	
	if(h_ClaimedBuilding[client][entity] != null)
		delete h_ClaimedBuilding[client][entity];

	DataPack pack;
	h_ClaimedBuilding[client][entity] = CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(entity); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitPerkMachine, pack_2, TIMER_REPEAT);
	pack_2.WriteCell(EntIndexToEntRef(entity));
	pack_2.WriteCell(entity);
	
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Constructed[entity] = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_perkmachine");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public bool Building_PackAPunch(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingPackAPunch;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	if(h_ClaimedBuilding[client][entity] != null)
		delete h_ClaimedBuilding[client][entity];

	DataPack pack;
	h_ClaimedBuilding[client][entity] = CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(entity); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;
	
	DataPack pack_2;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitPackAPunch, pack_2, TIMER_REPEAT);
	pack_2.WriteCell(EntIndexToEntRef(entity));
	pack_2.WriteCell(entity);
	
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Constructed[entity] = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_packapunch");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return false;
}

public Action Building_TimerDisableDispenser(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_bCarried", true);
		return Plugin_Continue;
	}
	
	return Plugin_Stop;
}


public Action Building_TakeDamage(int entity, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype == DMG_CRUSH)
	{
		if(damage >= 1000000.0)
		{
			return Plugin_Continue;
		}
		damage = 0.0;
		return Plugin_Handled;
	}
	if(i_BeingCarried[entity])
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if(RaidBossActive && (RaidbossIgnoreBuildingsLogic(2))) //They are ignored anyways
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if(f_ClientInvul[entity] > GetGameTime())
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if(Rogue_Mode()) //buildings are refunded alot, so they shouldnt last long.
	{
		int scale = Rogue_GetRoundScale();
		if(scale < 2)
		{
			//damage *= 1.0;
		}
		else if(scale < 4)
		{
			damage *= 2.0;
		}
		else
		{
			int Owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			if(Owner > 0)
			{
				if(MaxSupportBuildingsAllowed(Owner, false) > 1)
				{
					damage *= 2.0;
				}
				else
				{
					damage *= 3.0;
				}
			}
			else
			{
				damage *= 3.0;
			}
		}
	}

	damage *= fl_Extra_Damage[attacker];

	if(f_FreeplayDamageExtra != 1.0 && !b_thisNpcIsARaid[attacker])
	{
		damage *= f_FreeplayDamageExtra;
	}
	if(f_PotionShrinkEffect[attacker] > GetGameTime() || (IsValidEntity(inflictor) && f_PotionShrinkEffect[attacker] > GetGameTime()))
	{
		damage *= 0.5; //half the damage when small.
	}
	if(f_HussarBuff[attacker] > GetGameTime()) //hussar!
	{
		damage *= 1.10;
	}
	if(f_MultiDamageTaken[entity] != 1.0)
	{
		damage *= f_MultiDamageTaken[entity];
	}
	if(f_MultiDamageTaken_Flat[entity] != 1.0)
	{
		damage *= f_MultiDamageTaken_Flat[entity];
	}
	if(b_thisNpcIsABoss[attacker])
	{
		damage *= 1.5;
	}
	if(GetEntProp(entity, Prop_Data, "m_iHealth") <= damage)
	{
		b_BuildingHasDied[entity] = true;
		KillFeed_Show(entity, inflictor, attacker, 0, weapon, damagetype);
	}
	//This is no longer needed, this logic has been added to the base explosive plugin, this also means that it allows
	//npc vs npc interaction (mainly from blu to red) to deal 3x the explosive damage, so its not so weak.
	/*
	if(damagetype & DMG_BLAST)
	{
		damage *= 3.0; //OTHERWISE EXPLOSIVES ARE EXTREAMLY WEAK!!
	}
	*/
	
	if(Resistance_for_building_High[entity] > GetGameTime())
	{
		damage *= 0.75;
		return Plugin_Changed;
	}
	

	damagePosition[2] -= 40.0;
	TE_ParticleInt(g_particleImpactMetal, damagePosition);
	TE_SendToAll();
	damagePosition[2] += 40.0;

	return Plugin_Changed;
}

public Action BuildingSetAlphaClientSideReady_SetTransmitProp_1_Summoner(int entity, int client)
{
	int building = EntRefToEntIndex(Building_Hidden_Prop_To_Building[entity]);
	
	if(IsValidEntity(building))
	{
		if(i_BeingCarried[building])
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}


public Action BuildingSetAlphaClientSideReady_SetTransmitProp_1_Armor(int entity, int client)
{
	if(RaidbossIgnoreBuildingsLogic(0))
	{
		int building = EntRefToEntIndex(Building_Hidden_Prop_To_Building[entity]);
		if(!IsValidEntity(building))
		{
			RemoveEntity(entity);
			return Plugin_Handled;
		}
		if(i_MaxArmorTableUsed[client] >= RAID_MAX_ARMOR_TABLE_USE)
		{
			return Plugin_Continue;
		}
	}
	return BuildingSetAlphaClientSideReady_SetTransmitProp_1(entity, client);
}


public Action BuildingSetAlphaClientSideReady_SetTransmitProp_2_Armor(int entity, int client)
{
	if(RaidbossIgnoreBuildingsLogic(0))
	{
		int building = EntRefToEntIndex(Building_Hidden_Prop_To_Building[entity]);
		if(!IsValidEntity(building))
		{
			RemoveEntity(entity);
			return Plugin_Handled;
		}
		if(i_MaxArmorTableUsed[client] >= RAID_MAX_ARMOR_TABLE_USE)
		{
			return Plugin_Handled;
		}
	}
	return BuildingSetAlphaClientSideReady_SetTransmitProp_2(entity, client);
}

public Action BuildingSetAlphaClientSideReady_SetTransmitProp_1(int entity, int client)
{
	float Gametime = GetGameTime();
	
	int building = EntRefToEntIndex(Building_Hidden_Prop_To_Building[entity]);
	
	if(IsValidEntity(building))
	{
		if(i_BeingCarried[building])
		{
			return Plugin_Handled;
		}
		if(Building_Collect_Cooldown[building][client] > Gametime)
		{
			return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}

public Action BuildingSetAlphaClientSideReady_SetTransmitProp_2(int entity, int client)
{
	float Gametime = GetGameTime();
	
	int building = EntRefToEntIndex(Building_Hidden_Prop_To_Building[entity]);
	
	if(IsValidEntity(building))
	{
		if(i_BeingCarried[building])
		{
			return Plugin_Handled;
		}
		if(Building_Collect_Cooldown[building][client] > Gametime)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}

public Action Building_Set_HP_Colour(Handle dashHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
			
		if(IsValidClient(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")))
		{
			int red = 255;
			int green = 255;
			int blue = 0;

			if(Building_Max_Health[entity] <= 0)
			{
				Building_Max_Health[entity] = 1;
			}

			int BuildingHealth = GetEntProp(entity, Prop_Send, "m_iHealth");
			if(BuildingHealth > Building_Max_Health[entity])
			{
				red = 0;
				green = 0;
				blue = 255;
			}
			else
			{
				red = BuildingHealth * 255  / Building_Max_Health[entity];
			//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
				green = BuildingHealth * 255  / Building_Max_Health[entity];		
				red = 255 - red;		
			}
			SetEntityCollisionGroup(entity, BUILDINGCOLLISIONNUMBER);
		//	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, red, green, blue, 255);
			
			
			if(IsValidEntity(prop1))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop1, red, green, blue, 100);
			}
			if(IsValidEntity(prop2))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop2, red, green, blue, 255);
			}
		}
		else
		{
			SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
			int red = 0;
			int green = 0;
			int blue = 0;
			int Alpha = 125;
			
			SetEntityRenderColor(entity, red, green, blue, Alpha);
			if(IsValidEntity(prop1))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop1, red, green, blue, Alpha);
			}
			if(IsValidEntity(prop2))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop2, red, green, blue, Alpha);
			}

		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action Building_Set_HP_Colour_Sentry(Handle dashHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		static char buffer[36];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		if(!StrContains(buffer, "obj_dispenser"))
		{
			return Plugin_Stop;
		}
		SetEntProp(entity, Prop_Send, "m_iAmmoShells", 150);
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
		
		if(IsValidClient(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")))
		{
			int red = 255;
			int green = 255;
			int blue = 0;
			int BuildingHealth = GetEntProp(entity, Prop_Send, "m_iHealth");

			if(Building_Max_Health[entity] <= 0)
			{
				Building_Max_Health[entity] = 1;
			}

			if(BuildingHealth > Building_Max_Health[entity])
			{
				red = 0;
				green = 0;
				blue = 255;
			}
			else
			{
				red = BuildingHealth * 255  / Building_Max_Health[entity];
			//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
				green = BuildingHealth * 255  / Building_Max_Health[entity];		
				red = 255 - red;		
			}
			
			SetEntityCollisionGroup(entity, BUILDINGCOLLISIONNUMBER);
		//	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, red, green, blue, 255);
			
			if(IsValidEntity(prop1))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop1, red, green, blue, 100);
			}
			if(IsValidEntity(prop2))
			{
			//	SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(prop2, red, green, blue, 255);
			}
		}
		else
		{
		//	SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_SLASH|DMG_CLUB);
			SDKHooks_TakeDamage(entity, 0, 0, 100000.0, DMG_ACID);
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Building_Is_Elevator_There(Handle dashHud, DataPack pack)
{
	pack.Reset();
	int ref = pack.ReadCell();
	int entity_Original_Index = pack.ReadCell();
	
	int entity = EntRefToEntIndex(ref);
//	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		if(IsValidClient(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")))
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, 150);
			SetEntityCollisionGroup(entity, BUILDINGCOLLISIONNUMBER);
		}
		else
		{
			SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
			int red = 0;
			int green = 0;
			int blue = 0;
			SetEntityRenderColor(entity, red, green, blue, 150);
		}
	}
	else
	{
		Elevators_Currently_Build[Elevator_Owner[entity_Original_Index]] -= 1;
		Elevator_Owner[entity_Original_Index] = 0;
		Is_Elevator[entity_Original_Index] = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

/*
public Action Building_Set_HP_Elevator(Handle dashHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
			
	//	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 60);
	}
	else
	{
		KillTimer(dashHud);
	}
}
*/

int Building_GetBuildingRepair(int entity)
{
	return Building_cannot_be_repaired[entity] ? 0 : Building_Repair_Health[entity];
}

void Building_SetBuildingRepair(int entity, int health)
{
	if(!Building_cannot_be_repaired[entity])
	{
		int damage = Building_Repair_Health[entity] - health;
		Building_Repair_Health[entity] = health;

		if(Building_Repair_Health[entity] > 0)
		{
			int progress = Building_Repair_Health[entity] * 100 / GetEntProp(entity, Prop_Data, "m_iMaxHealth");
			progress += 1; //so it goes to 100 :)
			if(progress > 100)
			{
				progress = 100;
			}
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", progress);
		}
		else
		{
			Building_Repair_Health[entity] = 0;
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 0);
			Building_cannot_be_repaired[entity] = true;
		}

		int client = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(IsValidClient(client))
		{
			i_BarricadeHasBeenDamaged[client] += damage;
		}
	}
}

public void Building_TakeDamagePost(int entity, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(damagetype == DMG_CRUSH)
	{
		return;
	}
	if(i_BeingCarried[entity])
	{
		return;
	}
	if(damagetype == DMG_ACID)
	{
		return;
	}
	if(RaidBossActive && (RaidbossIgnoreBuildingsLogic(2))) //They are ignored anyways
	{
		return;
	}
	if(f_ClientInvul[entity] > GetGameTime())
	{
		return;
	}

	int dmg = RoundFloat(damage);
		
	if(!Building_cannot_be_repaired[entity])
	{
		Building_Repair_Health[entity] -= dmg;
		if(Building_Repair_Health[entity] > 0)
		{
			dmg = 0;
			int progress = Building_Repair_Health[entity] * 100 / GetEntProp(entity, Prop_Data, "m_iMaxHealth");
			progress += 1; //so it goes to 100 :)
			if(progress > 100)
			{
				progress = 100;
			}
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", progress);
		}
		else
		{
			dmg += Building_Repair_Health[entity];
			SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 0);
			Building_cannot_be_repaired[entity] = true;
		}
	}
	
	if(dmg)
	{
		Building_Repair_Health[entity] = 0;
		int health = GetEntProp(entity, Prop_Data, "m_iMaxHealth")-dmg;
		if(health < 1)
			health = 1;
		
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
	int client = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(IsValidClient(client))
	{
		i_BarricadeHasBeenDamaged[client] += RoundToCeil(damage);
	}
}

/*
	Da Code
*/

static Function Building[MAXTF2PLAYERS] = {INVALID_FUNCTION, ...};
static int BuildingWeapon[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};
//static float GrabAt[MAXTF2PLAYERS];
//static int GrabRef[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};

void Building_WeaponSwitchPost(int client, int &weapon, const char[] buffer)
{
	if(EntityFuncAttack[weapon] && EntityFuncAttack[weapon]!=INVALID_FUNCTION)
	{
		Function func = EntityFuncAttack[weapon];
		if(func == Building_PlaceSummoner || func == Building_PlaceVillage || func == Building_PlaceHealingStation || func == Building_PlacePackAPunch || func == Building_PlacePerkMachine || func==Building_PlaceRailgun || func==Building_PlaceMortar || func==Building_PlaceSentry || func==Building_PlaceDispenser || func==Building_PlaceAmmoBox || func==Building_PlaceArmorTable || func==Building_PlaceElevator || func==Building_PlaceBlacksmith)
		{
			if(Building[client] != INVALID_FUNCTION)
			{
				Building[client] = INVALID_FUNCTION;
				BuildingWeapon[client] = INVALID_ENT_REFERENCE;
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
			}
			
			bool success = true;
			Call_StartFunction(null, func);
			Call_PushCell(client);
			Call_PushCell(weapon);
			Call_PushString(buffer);
			Call_PushCellRef(success);
			Call_Finish();
			
			if(success)
			{
				if(Building[client] != INVALID_FUNCTION)
				{
					int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(entity != -1)
						weapon = entity;
				}
			}
		}
	}
}

bool AllowBuildingCurrently()
{
	if(Rogue_Mode())
	{
		if(Rogue_InSetup())
		{
			return false;
		}
	}
	
	return true;
}
public void Pickup_Building_M2(int client, int weapon, bool crit)
{
		int entity = GetClientPointVisible(client, _ , true, true,_,1);
		if(entity > MaxClients)
		{
			if (IsValidEntity(entity))
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)))
				{
					if(!StrContains(buffer, "obj_"))
					{
						if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
						{
							if(b_Doing_Buildingpickup_Handle[client])
							{
								delete h_Pickup_Building[client];
							}
							b_Doing_Buildingpickup_Handle[client] = true;
							DataPack pack;
							h_Pickup_Building[client] = CreateDataTimer(b_ThisEntityIgnored[entity] ? 0.0 : 1.0, Building_Pickup_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(client);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(GetClientUserId(client));
							f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
							SetGlobalTransTarget(client);
							PrintCenterText(client, "%t", "Picking Up Building");
						}
					}
				}
			}
		}
}
					
public Action Building_Pickup_Timer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	
	b_Doing_Buildingpickup_Handle[original_index] = false;

	if(IsValidClient(client))
	{
		if(TF2_IsPlayerInCondition(client,TFCond_Taunting)) //prevent people that taunt from picking up buildings due to npc targetting issues
		{
			return Plugin_Handled;
		}
		PrintCenterText(client, " ");
		if (IsValidEntity(entity))
		{
			int looking_at = GetClientPointVisible(client, _ , true, true,_,1);
			if (looking_at == entity)
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)) && !StrContains(buffer, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
				{
					SetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed", 0.1);
					CClotBody npc = view_as<CClotBody>(entity);
					npc.bBuildingIsPlaced = false;
					if(!StrContains(buffer, "obj_dispenser"))
					{
						Building[client] = INVALID_FUNCTION;
						BuildingWeapon[client] = INVALID_ENT_REFERENCE;
						TF2_SetPlayerClass_ZR(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						Event_ObjectMoved_Custom(entity);
						SDKCall(g_hSDKMakeCarriedObjectDispenser, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass_ZR(client, TFClass_Engineer, false, false);
						
					}
					else if(!StrContains(buffer, "obj_sentrygun"))
					{
						Building[client] = INVALID_FUNCTION;
						BuildingWeapon[client] = INVALID_ENT_REFERENCE;
						TF2_SetPlayerClass_ZR(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						
						Event_ObjectMoved_Custom(entity);
						SDKCall(g_hSDKMakeCarriedObjectSentry, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
					//	TF2_SetPlayerClass_ZR(client, TFClass_Engineer);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass_ZR(client, TFClass_Engineer, false, false);
					}	
					TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); //They stay invis in that pos, move away.
				}	
			}
		}
	}
	return Plugin_Handled;	
}
		
void Building_ShowInteractionHud(int client, int entity)
{
	if (TeutonType[client] == TEUTON_WAITING)
		return;

	bool Hide_Hud = true;
	if(IsValidEntity(entity))
	{
		if(entity <= MaxClients)
		{
			if(dieingstate[entity] > 0 && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
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
		static char buffer[36];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		if(StrEqual(buffer, "prop_dynamic"))
		{
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(!StrContains(buffer, "zr_weapon_", false))
			{
				Hide_Hud = false;
				SetGlobalTransTarget(client);
				PrintCenterText(client, "%t", "Pickup this weapon with RELOAD");
			}
		}
		else if(StrEqual(buffer, "obj_sentrygun"))
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == -1)
			{
				Hide_Hud = false; //This should never even be possible in this case.
				SetGlobalTransTarget(client);
				PrintCenterText(client, "%t", "Claim this building");
			
			}
			else
			{
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrContains(buffer, "zr_healingstation"))
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Healing Station Tooltip");						
					}
				}
				else if(!StrContains(buffer, "zr_village_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
				{
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					PrintCenterText(client, "%t", "Village Upgrade Tooltip");
				}
				else if(!StrContains(buffer, "zr_blacksmith"))
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Blacksmith Tooltip");
					}
				}
			}
		}
		else if(StrEqual(buffer, "obj_dispenser"))
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == -1)
			{
				Hide_Hud = false;
				SetGlobalTransTarget(client);
				PrintCenterText(client, "%t", "Claim this building");
			}
			else
			{
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrContains(buffer, "zr_ammobox"))
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Ammobox Tooltip");						
					}
				}
				else if(!StrContains(buffer, "zr_armortable"))
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Armortable Tooltip");						
					}
				}
				else if(!StrContains(buffer, "zr_perkmachine"))
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Perkmachine Tooltip");						
					}
				}
				else if(!StrContains(buffer, "zr_packapunch"))
				{
					int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(weapon != -1 && StoreWeapon[weapon] > 0)
					{
						if(Store_CanPapItem(client, StoreWeapon[weapon]))
						{
							PrintCenterText(client, "%t", "PackAPunch Tooltip");
						}
						else
						{
							PrintCenterText(client, "%t", "Cannot Pap this");	
						}
					}
					
					Hide_Hud = false;
					//Unused for now, will have extra code saying how much it costs and stuff.
				}
			}
		}
		else if(StrEqual(buffer, "zr_base_npc"))
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
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Armortable Tooltip");				
					}
				}
				case 2:
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Ammobox Tooltip");						
					}
				}
				case 5:
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Perkmachine Tooltip");						
					}
				}
				case 6:
				{
					int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if(weapon != -1 && StoreWeapon[weapon] > 0)
					{
						if(Store_CanPapItem(client, StoreWeapon[weapon]))
						{
							PrintCenterText(client, "%t", "PackAPunch Tooltip");
						}
						else
						{
							PrintCenterText(client, "%t", "Cannot Pap this");	
						}
					}
					
					Hide_Hud = false;
					//Unused for now, will have extra code saying how much it costs and stuff.
				}
				case 7:
				{
					Hide_Hud = false;
					if(Building_Collect_Cooldown[entity][client] > GetGameTime())
					{
						float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
						
						if(Building_Picking_up_cd <= 0.0)
							Building_Picking_up_cd = 0.0;
							
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
					}
					else
					{
						SetGlobalTransTarget(client);
						PrintCenterText(client, "%t", "Healing Station Tooltip");						
					}
				}
			}
		}
	}
	if(Hide_Hud)
	{
		PrintCenterText(client, "");	
	}
}
bool Building_Interact(int client, int entity, bool Is_Reload_Button = false)
{
	if (TeutonType[client] == TEUTON_WAITING)
		return false;
	/*
	static char buffer[36];
	if(!Is_Reload_Button && GrabRef[client] == INVALID_ENT_REFERENCE && !StrContains(classname, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon > MaxClients && GetEntityClassname(weapon, buffer, sizeof(buffer)) && (StrEqual(buffer, "tf_weapon_wrench") || StrEqual(buffer, "tf_weapon_robot_arm")))
		{
			GrabAt[client] = GetGameTime()+1.0; //Make building pickup a bit faster, was 1.5 before, 1.0 is good
	//		SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			PrintCenterText(client, "%t", "Picking Up Building");
	//		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Picking Up Building");
		}
	}
	*/
	if(IsValidEntity(entity))
	{
		bool BuildingWasMounted = false;
		if(entity <= MaxClients)
		{
			if(dieingstate[entity] > 0)
			{
				return false;
			}
			entity = EntRefToEntIndex(Building_Mounted[entity]);
			if(!IsValidEntity(entity))
			{
				return false;
			}
			else
			{
				BuildingWasMounted = true;
			}
		}
		
		int buildingType;
		int owner = -1;
		
		static char buffer[36];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		if(StrEqual(buffer, "obj_sentrygun"))
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, "zr_healingstation"))
			{
				buildingType = 7;
			}
			else if((!PlayerIsInNpcBattle(client) || !BuildingWasMounted || client == owner)  && !StrContains(buffer, "zr_village"))
			{
				buildingType = 8;
			}
			else if((!PlayerIsInNpcBattle(client) || !BuildingWasMounted || client == owner) && !StrContains(buffer, "zr_summoner"))
			{
				buildingType = 9;
			}
			else if(!StrContains(buffer, "zr_blacksmith"))
			{
				buildingType = BuildingBlacksmith;
			}
		}
		else if(StrEqual(buffer, "obj_dispenser"))
		{
			owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			if(owner == -1)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon > MaxClients && GetEntityClassname(weapon, buffer, sizeof(buffer)) && (StrEqual(buffer, "tf_weapon_wrench") || StrEqual(buffer, "tf_weapon_robot_arm")))
				{
					if(Is_Reload_Button)
					{
						GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
						if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client, false) && (StrEqual(buffer, "zr_ammobox") || StrEqual(buffer, "zr_armortable") || StrEqual(buffer, "zr_perkmachine") || StrEqual(buffer, "zr_packapunch")))
						{
							if(MaxSupportBuildingsAllowed(client, false) <= 1 && i_WhatBuilding[entity] == BuildingPackAPunch)
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								PrintToChat(client,"You do not own enough builder upgrades to own a pack a punch.");
								return true;
							}
							if(h_ClaimedBuilding[client][entity] != null)
								delete h_ClaimedBuilding[client][entity];

							DataPack pack;
							h_ClaimedBuilding[client][entity] = CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(EntIndexToEntRef(client)); 
							pack.WriteCell(entity); 
							pack.WriteCell(client); //Need original client index id please.
							i_SupportBuildingsBuild[client] += 1;
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);
							SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
							SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
						}
						else if(StrEqual(buffer, "zr_barricade") && i_BarricadesBuild[client] < MaxBarricadesAllowed(client)) // do not check for if too many barricades, doesnt make sense to do this anyways.
						{
							DataPack pack;
							CreateDataTimer(0.5, Timer_ClaimedBuildingremoveBarricadeCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(EntIndexToEntRef(client)); 
							pack.WriteCell(client); //Need original client index id please.
							i_BarricadesBuild[client] += 1;
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);		
							SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
							SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);					
						}
						else if(StrEqual(buffer, "zr_elevator")) // bruh why.
						{
							DataPack pack;
							CreateDataTimer(0.5, Timer_ClaimedBuildingremoveElevatorCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(EntIndexToEntRef(client)); 
							pack.WriteCell(client); //Need original client index id please.
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);		
							SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
							SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
							
							Elevators_Currently_Build[client] += 1;
							Is_Elevator[entity] = true;
							Building_Constructed[entity] = false;
							Elevator_Owner[entity] = client;
						}
						else
						{
							if(StrEqual(buffer, "zr_barricade"))
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								PrintToChat(client,"You can only own 2 barricades at once.");
							}
							else if(StrEqual(buffer, "zr_elevator")) // bruh why.
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								PrintToChat(client,"You can only own 3 Elevators at once.");
							}
							else
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
							}

						}
						return true;
					}
					else if(!b_IgnoreWarningForReloadBuidling[client])
					{
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");	
						return true;			
					}
				}
				return false; //Dont let them interact with it if it has no owner!
			}
			
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, "zr_ammobox"))
			{
				buildingType = 2;
			}
			else if (StrEqual(buffer, "zr_armortable"))
			{
				buildingType = 1;
			}	
			else if (StrEqual(buffer, "zr_mortar"))
			{
				buildingType = 3;
			}	
			else if (StrEqual(buffer, "zr_railgun"))
			{
				buildingType = 4;
			}	
			else if (((!PlayerIsInNpcBattle(client) || !BuildingWasMounted) || i_CurrentEquippedPerk[client] == 0 || client == owner)  && StrEqual(buffer, "zr_perkmachine"))
			{
				buildingType = 5;
			}					
			else if ((!PlayerIsInNpcBattle(client) || !BuildingWasMounted || client == owner)  && StrEqual(buffer, "zr_packapunch"))
			{
				buildingType = 6;
			}
		}
		else if(!PlayerIsInNpcBattle(client) && Is_Reload_Button && StrEqual(buffer, "zr_base_npc"))
		{
			buildingType = Citizen_BuildingInteract(entity);
			int temp_owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
			if(IsValidClient(temp_owner)) //Fix not getting the owner correctly when interacting with barney or citicens!
			{
				owner = temp_owner;
			}
			else
			{
				owner = -1;
			}
		}
		
		if(buildingType)
		{
			if(!Is_Reload_Button && !b_IgnoreWarningForReloadBuidling[client])
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");
				return true;
			}
			
			if(Building_Collect_Cooldown[entity][client] > GetGameTime())
			{
				float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
				
				if(Building_Picking_up_cd <= 0.0)
					Building_Picking_up_cd = 0.0;
					
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t","Object Cooldown",Building_Picking_up_cd);
				return true;
			}
			
			switch(buildingType)
			{
				case 7:
				{
					ApplyBuildingCollectCooldown(entity, client, 90.0);
					ClientCommand(client, "playgamesound items/smallmedkit1.wav");
					float HealAmmount = 30.0;
					if(IsValidClient(owner))
					{
						HealAmmount *= Attributes_GetOnPlayer(owner, 8, true, true);
					}

					HealEntityGlobal(owner, client, HealAmmount, _, 3.0, _);
					if(!Rogue_Mode() && owner != -1 && i_Healing_station_money_limit[owner][client] < 20)
					{
						if(!Rogue_Mode() && owner != client)
						{
							i_Healing_station_money_limit[owner][client] += 1;
							Resupplies_Supplied[owner] += 2;
							GiveCredits(owner, 20, true);
							SetDefaultHudPosition(owner);
							SetGlobalTransTarget(owner);
							ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Healing Station Used");
						}
					}
				}
				case 2:
				{
						if((Ammo_Count_Ready - Ammo_Count_Used[client]) > 0)
						{
							int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
							if(IsValidEntity(weapon))
							{
								if(i_IsWandWeapon[weapon])
								{
									float max_mana_temp = 800.0;
									float mana_regen_temp = 100.0;
									
									if(i_CurrentEquippedPerk[client] == 4)
									{
										mana_regen_temp *= 1.35;
									}
									
									if(Mana_Regen_Level[client])
									{			
										mana_regen_temp *= Mana_Regen_Level[client];
										max_mana_temp *= Mana_Regen_Level[client];	
									}
									if(b_AggreviatedSilence[client])
										mana_regen_temp *= 0.30;
									
									if(Current_Mana[client] < RoundToCeil(max_mana_temp))
									{
										Ammo_Count_Used[client] += 1;
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										if(Current_Mana[client] < RoundToCeil(max_mana_temp))
										{
											Current_Mana[client] += RoundToCeil(mana_regen_temp);
											
											if(Current_Mana[client] > RoundToCeil(max_mana_temp)) //Should only apply during actual regen
												Current_Mana[client] = RoundToCeil(max_mana_temp);
										}
										
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;

										ApplyBuildingCollectCooldown(entity, client, 5.0, true);

										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
										Mana_Hud_Delay[client] = 0.0;
									}
									else
									{
										ClientCommand(client, "playgamesound items/medshotno1.wav");
										SetDefaultHudPosition(client);
										SetGlobalTransTarget(client);
										ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Max Mana Reached");
									}
								}
								else
								{
									int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
									int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
									if(weaponindex == 211)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										AddAmmoClient(client, 21 ,_,2.0);
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										ApplyBuildingCollectCooldown(entity, client, 5.0, true);
										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 411)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										AddAmmoClient(client, 22 ,_,2.0);
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										ApplyBuildingCollectCooldown(entity, client, 5.0, true);
										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 441 || weaponindex == 35)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										AddAmmoClient(client, 23 ,_,2.0);
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}		
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										ApplyBuildingCollectCooldown(entity, client, 5.0, true);
										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 998)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										AddAmmoClient(client, 3 ,_,2.0);
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										ApplyBuildingCollectCooldown(entity, client, 5.0, true);
										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(AmmoBlacklist(Ammo_type) && i_OverrideWeaponSlot[weapon] != 2) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										AddAmmoClient(client, Ammo_type ,_,2.0);
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										ApplyBuildingCollectCooldown(entity, client, 5.0, true);
										if(!Rogue_Mode() && owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											GiveCredits(owner, 20, true);
											SetDefaultHudPosition(owner);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else
									{
										int Armor_Max = 150;
									
										Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 0.75);
											
										if(Armor_Charge[client] < Armor_Max)
										{
											GiveArmorViaPercentage(client, 0.1, 1.0);
											
											fl_NextThinkTime[entity] = GetGameTime() + 2.0;
											i_State[entity] = -1;
											ApplyBuildingCollectCooldown(entity, client, 5.0, true);
											if(!Rogue_Mode() && owner != -1 && owner != client)
											{
												Resupplies_Supplied[owner] += 2;
												GiveCredits(owner, 20, true);
												SetDefaultHudPosition(owner);
												SetGlobalTransTarget(owner);
												ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
											}
											Ammo_Count_Used[client] += 1;
											
											ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
										}
										else
										{
											ClientCommand(client, "playgamesound items/medshotno1.wav");
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(client);
											ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Armor Max Reached Ammo Box");
										}
									}
								}
							}
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetDefaultHudPosition(client);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Ammo Supplies");
							
						}
				}
				case 1:
				{
						int Armor_Max = 300;

						Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);
							
						if(Armor_Charge[client] < Armor_Max)
						{
							bool GiveArmor = true;
							if(RaidbossIgnoreBuildingsLogic(0))
							{
								if(i_MaxArmorTableUsed[client] < RAID_MAX_ARMOR_TABLE_USE)
								{
									i_MaxArmorTableUsed[client]++;
								}
								else
									GiveArmor = false;
							}
							if(GiveArmor)
							{
								GiveArmorViaPercentage(client, 0.2, 1.0);
								ApplyBuildingCollectCooldown(entity, client, 45.0);

								float pos[3];
								GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

								pos[2] += 45.0;

								ParticleEffectAt(pos, "halloween_boss_axe_hit_sparks", 1.0);

								if(!Rogue_Mode() && owner != -1 && owner != client)
								{
									if(Armor_table_money_limit[owner][client] < 30)
									{
										GiveCredits(owner, 20, true);
										Armor_table_money_limit[owner][client] += 1;
										Resupplies_Supplied[owner] += 2;
										SetDefaultHudPosition(owner);
										SetGlobalTransTarget(owner);
										ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Armor Table Used");
									}
								}
								
								ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
							}
							else
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								SetDefaultHudPosition(client);
								SetGlobalTransTarget(client);
								ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Armor Max Reached Raid");
							}
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetDefaultHudPosition(client);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Armor Max Reached");
						}
				}
				case 5:
				{
					if(Perk_Machine_Sickness[client] > GetGameTime())
					{
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Perk Machine Sickness", Perk_Machine_Sickness[client] - GetGameTime());	
					}
					else
					{
						if(Is_Reload_Button)
						{
							i_MachineJustClickedOn[client] = EntIndexToEntRef(entity);
							
							CancelClientMenu(client);
							SetStoreMenuLogic(client, false);
							SetGlobalTransTarget(client);
							
							Menu menu2 = new Menu(Building_ConfirmMountedAction);
							menu2.SetTitle("%t", "Which perk do you desire?");
								
							FormatEx(buffer, sizeof(buffer), "%t", "Recycle Poire");
							menu2.AddItem("-9", buffer);

							FormatEx(buffer, sizeof(buffer), "%t", "Widows Wine");
							menu2.AddItem("-8", buffer);
							
							FormatEx(buffer, sizeof(buffer), "%t", "Deadshot Daiquiri");
							menu2.AddItem("-7", buffer);
							
							FormatEx(buffer, sizeof(buffer), "%t", "Speed Cola");
							menu2.AddItem("-6", buffer);
							
							FormatEx(buffer, sizeof(buffer), "%t", "Double Tap");
							menu2.AddItem("-5", buffer);
							
							FormatEx(buffer, sizeof(buffer), "%t", "Juggernog");
							menu2.AddItem("-4", buffer);
							
							FormatEx(buffer, sizeof(buffer), "%t", "Quick Revive");
							menu2.AddItem("-3", buffer);
											
							FormatEx(buffer, sizeof(buffer), "%t", "No");
							menu2.AddItem("-2", buffer);
												
							menu2.Display(client, MENU_TIME_FOREVER); // they have 3 seconds.
						}
						else if(!b_IgnoreWarningForReloadBuidling[client])
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetDefaultHudPosition(client);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");				
						}		
					}
				}
				case 6:
				{
						if(Is_Reload_Button)
						{
							int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
							if(weapon != -1 && StoreWeapon[weapon] > 0)
							{
								switch(i_CustomWeaponEquipLogic[weapon])
								{
									case WEAPON_ION_BEAM:
									{
										int buttons = GetClientButtons(client);
										bool attack2 = (buttons & IN_ATTACK2) != 0;
										if(attack2)
										{
											Neuvellete_Menu(client, weapon);
											return true;
										}
									}
								}
								if(Store_CanPapItem(client, StoreWeapon[weapon]))
								{
									bool started = Waves_Started();
									if(started || Rogue_Mode() || CvarNoRoundStart.BoolValue)
									{
										Store_PackMenu(client, StoreWeapon[weapon], weapon, owner);
									}
									else
									{
										ClientCommand(client, "playgamesound items/medshotno1.wav");
										SetDefaultHudPosition(client);
										SetGlobalTransTarget(client);
										ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Pre Round Pap Limit");											
									}
								}
								else
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Pap this");	
								}
							}
						}
						else if(!b_IgnoreWarningForReloadBuidling[client])
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetDefaultHudPosition(client);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");				
						}
				}
				case 8:
				{
					if(Is_Reload_Button && owner != -1)
					{
						VillageUpgradeMenu(owner, client);
					}
				}
				case 9:
				{
					if(Is_Reload_Button && owner != -1)
					{
						OpenSummonerMenu(owner, client);
					}
				}
				case BuildingBlacksmith:
				{
					Blacksmith_BuildingUsed(entity, client, owner);
				}
			}
			return true;
		}
	}
	return false;
}

public void Building_EntityCreatedPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(client > 0 && client <= MaxClients && Building[client] != INVALID_FUNCTION)
		CreateTimer(0.1, Building_CheckTimer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Building_CheckTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > MaxClients)
	{
		if(GetEntProp(entity, Prop_Send, "m_bPlacing"))
			return Plugin_Continue;
		
		int client = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(client > 0 && client <= MaxClients && Building[client] != INVALID_FUNCTION)
		{
			bool result = false;
			Call_StartFunction(null, Building[client]);
			Call_PushCell(client);
			Call_PushCell(entity);
			Call_Finish(result);

			Rogue_AllySpawned(entity);
			
			if(!result)
			{
				int weapon = EntRefToEntIndex(BuildingWeapon[client]);
				if(weapon == -1)
					return Plugin_Stop;
				
				Store_ConsumeItem(client, StoreWeapon[weapon]);
				Store_OpenItemThis(client, StoreWeapon[weapon]);

				//TF2_RemoveItem(client, weapon);
				//TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
			}
			else
			{
				int weapon = EntRefToEntIndex(BuildingWeapon[client]);
				if(weapon == -1)
					return Plugin_Stop;
				
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				
				Building[client] = INVALID_FUNCTION;
				BuildingWeapon[client] = INVALID_ENT_REFERENCE;
			}

			Building[client] = INVALID_FUNCTION;
			BuildingWeapon[client] = INVALID_ENT_REFERENCE;

			Store_GiveAll(client, GetClientHealth(client));
		}
	}
	return Plugin_Stop;
}
static void PlaceBuilding(int client, int weapon, Function callback, TFObjectType type, TFObjectMode mode=TFObjectMode_None)
{
	TF2_SetPlayerClass_ZR(client, TFClass_Engineer, false, false);
	int iBuilder = Spawn_Buildable(client, view_as<int>(type));
	if(iBuilder > MaxClients)
	{
		switch(type)
		{
			case TFObject_Dispenser:
				ClientCommand(client, "build 0");
			
			case TFObject_Teleporter:
				ClientCommand(client, "build %d", mode==TFObjectMode_Exit ? 3 : 1);
			
			case TFObject_Sentry:
				ClientCommand(client, "build 2");
		}
		Building[client] = callback;
		BuildingWeapon[client] = EntIndexToEntRef(weapon);
	}
}
/*
public void Disallow_Building(int client)
{
	b_AllowBuildCommand[client] = false;	
}
*/

public Action Timer_ClaimedBuildingremoveSupportCounterOnDeath(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell()); 
	int entity_original_index = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	if(!IsValidEntity(entity))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		h_ClaimedBuilding[client_original_index][entity_original_index] = null;
		return Plugin_Stop;
	}
	if(!IsValidClient(client)) //Are they valid ? no ? DIE!
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		h_ClaimedBuilding[client_original_index][entity_original_index] = null;
		return Plugin_Stop;
	}
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner != client_original_index)
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		h_ClaimedBuilding[client_original_index][entity_original_index] = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_ClaimedBuildingremoveBarricadeCounterOnDeath(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell()); 
	int client_original_index = pack.ReadCell(); //Need original!
	
	if(!IsValidEntity(entity))
	{
		i_BarricadesBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	if(!IsValidClient(client)) //Are they valid ? no ? DIE!
	{
		i_BarricadesBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_ClaimedBuildingremoveElevatorCounterOnDeath(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell()); 
	int client_original_index = pack.ReadCell(); //Need original!
	
	if(!IsValidEntity(entity))
	{
		Elevators_Currently_Build[client_original_index] -= 1;
		return Plugin_Stop;
	}
	if(!IsValidClient(client)) //Are they valid ? no ? DIE!
	{
		Elevators_Currently_Build[client_original_index] -= 1;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitAmmobox(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))	
		{
			RemoveEntity(prop2);
		}
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
			
			int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
			int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		//	i_State[obj] = 
			if(IsValidEntity(prop1) && IsValidEntity(prop2))
			{
				if(fl_NextThinkTime[obj] + 0.4 < GetGameTime())
				{
					if(i_State[obj] != 0)
					{
						i_State[obj] = 0;
						SetVariantString("Idle");
						AcceptEntityInput(prop1, "SetAnimation");
						SetVariantString("Idle");
						AcceptEntityInput(prop2, "SetAnimation");
						SetVariantInt(1);
						AcceptEntityInput(prop1, "SetBodyGroup");
						SetVariantInt(1);
						AcceptEntityInput(prop2, "SetBodyGroup");
					}
				}
				else if(fl_NextThinkTime[obj] - 0.5 < GetGameTime())
				{
					if(i_State[obj] != 1)
					{
						i_State[obj] = 1;
						SetVariantString("Close");
						AcceptEntityInput(prop1, "SetAnimation");
						SetVariantString("Close");
						AcceptEntityInput(prop2, "SetAnimation");
					}
				}
				else if(fl_NextThinkTime[obj] - 1.3 < GetGameTime())
				{
					if(i_State[obj] != 2)
					{
						i_State[obj] = 2;
						SetVariantInt(0);
						AcceptEntityInput(prop1, "SetBodyGroup");
						SetVariantInt(0);
						AcceptEntityInput(prop2, "SetBodyGroup");
					//	SetVariantString("Close");
					//	AcceptEntityInput(obj, "SetAnimation");
					}
				}
				else if(fl_NextThinkTime[obj] - 2.1 < GetGameTime() )
				{
					if(i_State[obj] != 3)
					{
						i_State[obj] = 3;
						SetVariantString("0.5");
						AcceptEntityInput(prop1, "SetPlayBackRate");
						SetVariantString("0.5");
						AcceptEntityInput(prop2, "SetPlayBackRate");

						SetVariantString("Open");
						AcceptEntityInput(prop1, "SetAnimation");
						SetVariantString("Open");
						AcceptEntityInput(prop2, "SetAnimation");

						SetVariantInt(1);
						AcceptEntityInput(prop1, "SetBodyGroup");
						SetVariantInt(1);
						AcceptEntityInput(prop2, "SetBodyGroup");
					}
				}
			}
			

		//	fl_NextThinkTime[entity] = GetGameTime() + 2.0;
		
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		return Plugin_Continue;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") &~ EF_NODRAW);
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}
/*
	How to start an animation:
	npc.AddGesture("ACT_MELEE_ATTACK1");
	doesnt cancel itself out, although i should most likely add support for it, isnt hard though. 
	
	Set default animation:
	//This doesnt work for buildings.....
	int iActivity = npc.LookupActivity("MORTAR_IDLE");
	if(iActivity > 0) npc.StartActivity(iActivity);
*/
public Action Timer_DroppedBuildingWaitRailgun(Handle htimer, int entref)
{
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		CClotBody npc = view_as<CClotBody>(obj);
		if(Building_Constructed[obj])
		{
			int iActivity = npc.LookupActivity("RAIL_IDLE");
			if(iActivity > 0) npc.StartActivity(iActivity, _, false);
		//	npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
		}
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		return Plugin_Continue;
		
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitMortar(Handle htimer, int entref)
{
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		CClotBody npc = view_as<CClotBody>(obj);
		if(Building_Constructed[obj])
		{
			int iActivity = npc.LookupActivity("MORTAR_IDLE");
			if(iActivity > 0) npc.StartActivity(iActivity, _, false);
		//	npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
		}
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		return Plugin_Continue;
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitHealingStation(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	pack.ReadCell(); //Need original!
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
//			int iActivity = npc.LookupActivity("MORTAR_IDLE");
//			if(iActivity > 0) npc.StartActivity(iActivity);
//			npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		return Plugin_Continue;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitArmorTable(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		
	//	i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
		//	SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		return Plugin_Continue;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitPerkMachine(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}
public Action Timer_DroppedBuildingWaitPackAPunch(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitWall(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
	//	i_BarricadesBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}

	if(GetEntPropEnt(obj, Prop_Send, "m_hBuilder") == -1)
	{
		SetEntityCollisionGroup(obj, 1);
		b_ThisEntityIgnored[obj] = true; //Hey! Be ignored! you have no owner!
	}
	else
	{
		SetEntityCollisionGroup(obj, BUILDINGCOLLISIONNUMBER);
		b_ThisEntityIgnored[obj] = false;
	}

	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitSentry(Handle htimer, int entref)
{
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
	{
		char buffer[32];
		GetEntityClassname(obj, buffer, sizeof(buffer));
		if(!StrContains(buffer, "obj_sentrygun"))
		{
			SetEntProp(obj, Prop_Send, "m_iAmmoShells", 150);
		}
		if(Building_Constructed[obj])
			return Plugin_Continue;

		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	}
	return Plugin_Continue;
}
public bool BuildingCustomCommand(int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && obj>MaxClients)
	{
		if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") >= 1.0)
		{
			static char buffer[36];
			GetEntPropString(obj, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, "zr_mortar"))
			{
				if(f_BuildingIsNotReady[client] < GetGameTime())
				{
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					BuildingMortarAction(client, obj);
				}
				else
				{
					float Ability_CD = f_BuildingIsNotReady[client] - GetGameTime();
			
					if(Ability_CD <= 0.0)
						Ability_CD = 0.0;
				
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
				}
			}
			else if(StrEqual(buffer, "zr_railgun"))
			{
				if(obj == EntRefToEntIndex(g_CarriedDispenser[client]))
				{
					if(f_BuildingIsNotReady[client] < GetGameTime())
					{
						f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
						BuildingRailgunShotClient(client, obj);
					}
					else
					{
						float Ability_CD = f_BuildingIsNotReady[client] - GetGameTime();
				
						if(Ability_CD <= 0.0)
							Ability_CD = 0.0;
					
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
					}
				}
				else
				{
					int looking_at = GetClientPointVisible(client, _ , _, _,_,1);
					if(IsValidEntity(looking_at) && looking_at > 0)
					{
						GetEntPropString(looking_at, Prop_Data, "m_iName", buffer, sizeof(buffer));
						if(StrEqual(buffer, "zr_railgun"))
						{
							if(GetEntPropEnt(looking_at, Prop_Send, "m_hBuilder") == client)
							{
								if(f_BuildingIsNotReady[client] < GetGameTime())
								{
									f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
									BuildingRailgunShot(client, looking_at);
								}
								else
								{
									float Ability_CD = f_BuildingIsNotReady[client] - GetGameTime();
							
									if(Ability_CD <= 0.0)
										Ability_CD = 0.0;
								
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
								}
							}
						}
					}
				}
			}
			else if(StrEqual(buffer, "zr_healingstation"))
			{
				if(obj == EntRefToEntIndex(g_CarriedDispenser[client]))
				{
					if(Building_Collect_Cooldown[obj][client] < GetGameTime())
					{
						ApplyBuildingCollectCooldown(obj, client, 75.0);
						ClientCommand(client, "playgamesound items/smallmedkit1.wav");
						float HealAmmount = 30.0;
						if(IsValidClient(client))
						{
							HealAmmount *= Attributes_GetOnPlayer(client, 8, true, true);
						}
						HealEntityGlobal(client, client, HealAmmount, 1.0, 3.0, _);
					}
					else
					{
						float Ability_CD = Building_Collect_Cooldown[obj][client] - GetGameTime();
				
						if(Ability_CD <= 0.0)
							Ability_CD = 0.0;
					
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
					}
				}
				else
				{
					int looking_at = GetClientPointVisible(client, _ , _, _,_,1);
					if(IsValidEntity(looking_at) && looking_at > 0)
					{
						GetEntPropString(looking_at, Prop_Data, "m_iName", buffer, sizeof(buffer));
						if(StrEqual(buffer, "zr_healingstation"))
						{
							if(GetEntPropEnt(looking_at, Prop_Send, "m_hBuilder") == client)
							{
								if(Building_Collect_Cooldown[obj][client] < GetGameTime())
								{
									ApplyBuildingCollectCooldown(obj, client, 75.0);
									ClientCommand(client, "playgamesound items/smallmedkit1.wav");
									float HealAmmount = 30.0;
									if(IsValidClient(client))
									{
										HealAmmount *= Attributes_GetOnPlayer(client, 8, true, true);
									}
									HealEntityGlobal(client, client, HealAmmount, 1.0, 3.0, _);
								}
								else
								{
									float Ability_CD = Building_Collect_Cooldown[obj][client] - GetGameTime();
							
									if(Ability_CD <= 0.0)
										Ability_CD = 0.0;
								
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
								}
							}
						}
					}
				}
			}
			else if((Village_Flags[client] & VILLAGE_040) && StrEqual(buffer, "zr_village"))
			{
				//if(Ammo_Count_Used[client] > 0)
				{
					if(f_BuildingIsNotReady[client] < GetGameTime())
					{
						//Ammo_Count_Used[client]--;
						f_BuildingIsNotReady[client] = GetGameTime() + 90.0;
						
						if(Village_Flags[client] & VILLAGE_050)
						{
							i_ExtraPlayerPoints[client] += 100; //Static point increace.
							Village_ReloadBuffFor[client] = GetGameTime() + 20.0;
							EmitSoundToAll("items/powerup_pickup_uber.wav");
							EmitSoundToAll("items/powerup_pickup_uber.wav");
						}
						else
						{
							i_ExtraPlayerPoints[client] += 50; //Static point increace.
							Village_ReloadBuffFor[client] = GetGameTime() + 15.0;
							EmitSoundToAll("player/mannpower_invulnerable.wav", client);
							EmitSoundToAll("player/mannpower_invulnerable.wav", client);
						}
					}
					else
					{
						float Ability_CD = f_BuildingIsNotReady[client] - GetGameTime();
						
						if(Ability_CD <= 0.0)
							Ability_CD = 0.0;
						
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
					}
				}
				/*else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "%t", "No Ammo Supplies");
				}*/
			}
			else if(StrEqual(buffer, "zr_summoner"))
			{
				OpenSummonerMenu(client, client);
			}
		}
		return true;
	}
	return false;
}
						
						
public void BuildingRailgunShot(int client, int Railgun)
{
	CClotBody npc = view_as<CClotBody>(Railgun);
	npc.AddGesture("RAIL_FIRE");	
	float pos[3];
	GetEntPropVector(Railgun, Prop_Send, "m_vecOrigin", pos);
	EmitSoundToAll(RAILGUN_ACTIVATED, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_ACTIVATED, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, Railgun, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, Railgun, _, 90, _, 0.8);
	CreateTimer(0.75, RailgunFire, client, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(15.5, RailgunFire_DeleteSound, Railgun, TIMER_FLAG_NO_MAPCHANGE);
}

public void BuildingRailgunShotClient(int client, int Railgun)
{
	EmitSoundToAll(RAILGUN_ACTIVATED, client, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_ACTIVATED, client, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, client, _, 90, _, 0.8);
	EmitSoundToAll(RAILGUN_PREPARE_SHOOT, client, _, 90, _, 0.8);
	CreateTimer(0.75, RailgunFire_Client, client, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(15.5, RailgunFire_DeleteSound_client, client, TIMER_FLAG_NO_MAPCHANGE);
}

static int BEAM_BuildingHit[MAX_TARGETS_HIT];
static float BEAM_Targets_Hit[MAXENTITIES];
static bool BEAM_HitDetected[MAXENTITIES];
public Action RailgunFire(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj))
	{
		float pos[3];
		GetEntPropVector(obj, Prop_Send, "m_vecOrigin", pos);
		CreateEarthquake(pos, 0.5, 350.0, 16.0, 255.0);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
		StopSound(obj, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
		EmitSoundToAll(RAILGUN_SHOOT, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_SHOOT, obj, _, 90, _, 0.8);
		BEAM_Targets_Hit[obj] = 1.0;
		Railgun_Boom(client);
		float flPos[3]; // original
		GetEntPropVector(obj, Prop_Data, "m_vecOrigin", flPos);
		flPos[2] += 50.0;
	//	flAng[1] += 33.0;
		ParticleEffectAt(flPos, "halloween_boss_axe_hit_sparks", 1.0);
		ParticleEffectAt(flPos, "eotl_pyro_pool_explosion_streaks", 1.0);
		CreateTimer(1.5, RailgunFire_ReloadStart, client, TIMER_FLAG_NO_MAPCHANGE);
	}		
	return Plugin_Stop;
}	
public Action RailgunFire_ReloadStart(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_START_CHARGE, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_START_CHARGE, obj, _, 90, _, 0.8);
		CreateTimer(9.0, RailgunFire_ReloadMiddle, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}
public Action RailgunFire_ReloadMiddle(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		CreateTimer(3.5, RailgunFire_ReloadEnd, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}

public Action RailgunFire_ReloadEnd(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj))
	{
		EmitSoundToAll(RAILGUN_READY_ALARM, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY_ALARM, obj, _, 90, _, 0.8);
	}
	return Plugin_Stop;
}

public Action RailgunFire_Client(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
		if(IsValidEntity(obj))
		{
			float pos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			CreateEarthquake(pos, 0.5, 350.0, 16.0, 255.0);
			StopSound(client, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
			StopSound(client, SNDCHAN_AUTO, RAILGUN_PREPARE_SHOOT);
			EmitSoundToAll(RAILGUN_SHOOT, client, _, 90, _, 0.8);
			EmitSoundToAll(RAILGUN_SHOOT, client, _, 90, _, 0.8);
			BEAM_Targets_Hit[obj] = 1.0;
			Railgun_Boom_Client(client);
			CreateTimer(1.5, RailgunFire_ReloadStart_Client, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}		
	return Plugin_Stop;
}	
public Action RailgunFire_ReloadStart_Client(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
		EmitSoundToAll(RAILGUN_START_CHARGE, client, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_START_CHARGE, client, _, 90, _, 0.8);
		CreateTimer(12.5, RailgunFire_ReloadMiddle_Client, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}

public Action RailgunFire_ReloadMiddle_Client(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY, obj, _, 90, _, 0.8);
		CreateTimer(3.5, RailgunFire_ReloadEnd_Client, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}

public Action RailgunFire_ReloadEnd_Client(Handle timer, int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
		EmitSoundToAll(RAILGUN_READY_ALARM, client, _, 90, _, 0.8);
		EmitSoundToAll(RAILGUN_READY_ALARM, client, _, 90, _, 0.8);
	}
	return Plugin_Stop;
}

public Action RailgunFire_DeleteSound(Handle timer, int obj)
{
	StopSound(obj, SNDCHAN_AUTO, RAILGUN_READY);
	StopSound(obj, SNDCHAN_AUTO, RAILGUN_END);
	StopSound(obj, SNDCHAN_AUTO, RAILGUN_START_CHARGE);
	StopSound(obj, SNDCHAN_AUTO, RAILGUN_ACTIVATED);
	return Plugin_Stop;
}
public Action RailgunFire_DeleteSound_client(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		StopSound(client, SNDCHAN_AUTO, RAILGUN_READY);
		StopSound(client, SNDCHAN_AUTO, RAILGUN_END);
		StopSound(client, SNDCHAN_AUTO, RAILGUN_START_CHARGE);
		StopSound(client, SNDCHAN_AUTO, RAILGUN_ACTIVATED);
	}
	return Plugin_Stop;
}
public void BuildingMortarAction(int client, int mortar)
{
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	FinishLagCompensation_Base_boss();
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	} 
	int color[4];
	color[0] = 255;
	color[1] = 255;
	color[2] = 0;
	color[3] = 255;
									
	if (GetTeam(client) == TFTeam_Blue)
	{
		color[2] = 255;
		color[0] = 0;
	}
	GetAttachment(client, "effect_hand_R", eyePos, eyeAng);
	int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	float amp = 0.2;
	float life = 0.1;
	TE_SetupBeamPoints(eyePos, spawnLoc, SPRITE_INT, 0, 0, 0, life, 2.0, 2.2, 1, amp, color, 0);
	TE_SendToAll();
								
	delete trace;
	EmitSoundToAll("weapons/drg_wrench_teleport.wav", client, SNDCHAN_AUTO, 70);
	static float pos[3];
	CreateTimer(1.0, MortarFire_Anims, client, TIMER_FLAG_NO_MAPCHANGE);
	f_MarkerPosition[client] = spawnLoc;
	float position[3];
	position[0] = spawnLoc[0];
	position[1] = spawnLoc[1];
	position[2] = spawnLoc[2];
				
	position[2] += 3000.0;

	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj))
	{
		int particle = ParticleEffectAt(position, "kartimpacttrail", 2.0);
		SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
		float pos_obj[3];
		CreateTimer(1.7, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		ParticleEffectAt(pos, "utaunt_portalswirl_purple_warp2", 2.0);
		GetEntPropVector(obj, Prop_Send, "m_vecOrigin", pos_obj);
		pos_obj[2] += 100.0;
		ParticleEffectAt(pos_obj, "skull_island_embers", 2.0);
	}
}

public Action MortarFire_Falling_Shot(Handle timer, int ref)
{
	int particle = EntRefToEntIndex(ref);
	if(particle>MaxClients && IsValidEntity(particle))
	{
		float position[3];
		GetEntPropVector(particle, Prop_Send, "m_vecOrigin", position);
		position[2] -= 3700;
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Handled;
}
public Action MortarFire_Anims(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int obj = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
		if(obj>MaxClients && IsValidEntity(obj))
		{
			EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
			EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
		//	SetColorRGBA(glowColor, r, g, b, alpha);
			ParticleEffectAt(f_MarkerPosition[client], "taunt_flip_land_ring", 1.0);
			CreateTimer(0.8, MortarFire, client, TIMER_FLAG_NO_MAPCHANGE);
		}	
	}	
	return Plugin_Handled;
}

public Action MortarFire(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int obj = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
		if(obj>MaxClients && IsValidEntity(obj))
		{
			float damage = 10.0;
							
			damage *= 30.0;
			
			float attack_speed;
			float sentry_range;

			attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
			damage = attack_speed * damage * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
			
			sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
			
			float AOE_range = 350.0 * sentry_range;

			Explode_Logic_Custom(damage, client, client, -1, f_MarkerPosition[client], AOE_range, 1.45, _, false);
			
			CreateEarthquake(f_MarkerPosition[client], 0.5, 350.0, 16.0, 255.0);
			CreateTimer(10.0, MortarReload, client, TIMER_FLAG_NO_MAPCHANGE);
			EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
			EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
			ParticleEffectAt(f_MarkerPosition[client], "rd_robot_explosion", 1.0);
		}
	}
	return Plugin_Handled;
}

public Action MortarReload(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int obj = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
		if(obj>MaxClients && IsValidEntity(obj))
		{
			float pos_obj[3];
			GetEntPropVector(obj, Prop_Send, "m_vecOrigin", pos_obj);
			pos_obj[2] += 100.0;
			CClotBody npc = view_as<CClotBody>(obj);
			npc.AddGesture("MORTAR_RELOAD");		
			EmitSoundToAll(MORTAR_RELOAD, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos_obj);
			EmitSoundToAll(MORTAR_RELOAD, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos_obj);			
		}
	}
	return Plugin_Handled;
}

public Action Block_All_Touch(int entity, int other)
{
	return Plugin_Handled;
}
/*
TF2 thinks that npcs are sky boxes or something. Just block this, this is the wierdest thing i have EVER seen.
void CObjectDispenser::Touch( CBaseEntity *pOther )
{
	// We dont want to touch these
	if ( pOther->IsSolidFlagSet( FSOLID_TRIGGER | FSOLID_VOLUME_CONTENTS ) )
		return;

	// Handle hitting skybox (disappear).
	const trace_t *pTrace = &CBaseEntity::GetTouchTrace();
	if( pTrace->surface.flags & SURF_SKY )
	{
		UTIL_Remove( this );
		return;
	}

}
*/

static void Railgun_Boom(int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
	//	int BossTeam = GetClientTeam(client);
	//	BEAM_TicksActive[client] = tickCount;
		int BEAM_BeamRadius = 40;
		float Strength = 10.0;
							
		Strength *= 20.0;

		float attack_speed;

		attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
		Strength = attack_speed * Strength * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
		
		float sentry_range;
			
		sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
					
		float BEAM_CloseBuildingDPT = Strength;
		float BEAM_FarBuildingDPT = Strength;
		int BEAM_MaxDistance = RoundToCeil(1500.0 * sentry_range);
		int BEAM_ColorHex = ParseColor("FFA500");
		float diameter = float(BEAM_BeamRadius * 2);
		int r = GetR(BEAM_ColorHex);
		int g = GetG(BEAM_ColorHex);
		int b = GetB(BEAM_ColorHex);
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(obj, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(obj, Prop_Data, "m_vecOrigin", startPoint);
		startPoint[2] += 50.0;
		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(BEAM_MaxDistance));
			float lineReduce = BEAM_BeamRadius * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXTF2PLAYERS; i++)
			{
				BEAM_HitDetected[i] = false;
			}
			
			
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				BEAM_BuildingHit[building] = false;
			}
			
			
			hullMin[0] = -float(BEAM_BeamRadius);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, obj);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			
			bool First_Target_Hit = true;
			
			BEAM_Targets_Hit[client] = 1.0;
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				if (BEAM_BuildingHit[building])
				{
					if(IsValidEntity(BEAM_BuildingHit[building]))
					{
						GetEntPropVector(BEAM_BuildingHit[building], Prop_Send, "m_vecOrigin", playerPos, 0);
						float distance = GetVectorDistance(startPoint, playerPos, false);
						float damage = BEAM_CloseBuildingDPT + (BEAM_FarBuildingDPT-BEAM_CloseBuildingDPT) * (distance/BEAM_MaxDistance);
						if (damage < 0)
							damage *= -1.0;
							
						if(First_Target_Hit)
						{
							damage *= 1.55;
							First_Target_Hit = false;
						}
						float CalcDamageForceVec[3]; CalculateDamageForce(vecForward, 10000.0, CalcDamageForceVec);
						SDKHooks_TakeDamage(BEAM_BuildingHit[building], obj, client, damage/BEAM_Targets_Hit[obj], DMG_PLASMA, -1, CalcDamageForceVec, playerPos);	// 2048 is DMG_NOGIB?
						BEAM_Targets_Hit[obj] *= LASER_AOE_DAMAGE_FALLOFF;
					}
					else
						BEAM_BuildingHit[building] = false;
				}
			}
			
			float belowBossEyes[3];
			GetEntPropVector(obj, Prop_Data, "m_vecOrigin", belowBossEyes);
			belowBossEyes[2] += 50.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 60);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.44, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 60);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 0.55, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
			endPoint[2] -= 15.0;
			ParticleEffectAt(endPoint, "ExplosionCore_MidAir_Flare", 0.25);
			CreateExplosion(client, endPoint, 0.0, 0, 0);
		}
		else
		{
			delete trace;
		}
		delete trace;
	}
}

static void Railgun_Boom_Client(int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
		int BEAM_BeamRadius = 40;
		float Strength = 10.0;
							
		Strength *= 20.0;
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
		Strength = attack_speed * Strength * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
		
		float sentry_range;
			
		sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
		
		float BEAM_CloseBuildingDPT = Strength;
		float BEAM_FarBuildingDPT = Strength;
		int BEAM_MaxDistance = RoundToCeil(1500.0 * sentry_range);
		int BEAM_ColorHex = ParseColor("FFA500");
		float diameter = float(BEAM_BeamRadius * 2);
		int r = GetR(BEAM_ColorHex);
		int g = GetG(BEAM_ColorHex);
		int b = GetB(BEAM_ColorHex);
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetClientEyePosition(client, startPoint);
		GetClientEyeAngles(client, angles);
		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(BEAM_MaxDistance));
			float lineReduce = BEAM_BeamRadius * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXTF2PLAYERS; i++)
			{
				BEAM_HitDetected[i] = false;
			}
			
			
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				BEAM_BuildingHit[building] = false;
			}
			
			
			hullMin[0] = -float(BEAM_BeamRadius);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			StartLagCompensation_Base_Boss(client);
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			FinishLagCompensation_Base_boss();

			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			
			bool First_Target_Hit = true;
			BEAM_Targets_Hit[client] = 1.0;
			for (int building = 0; building < MAX_TARGETS_HIT; building++)
			{
				if (BEAM_BuildingHit[building])
				{
					if(IsValidEntity(BEAM_BuildingHit[building]))
					{
						GetEntPropVector(BEAM_BuildingHit[building], Prop_Send, "m_vecOrigin", playerPos, 0);
						float distance = GetVectorDistance(startPoint, playerPos, false);
						float damage = BEAM_CloseBuildingDPT + (BEAM_FarBuildingDPT-BEAM_CloseBuildingDPT) * (distance/BEAM_MaxDistance);
						if (damage < 0)
							damage *= -1.0;
							
						if(First_Target_Hit)
						{
							damage *= 1.55;
							First_Target_Hit = false;
						}

						float TargetVecPos[3]; WorldSpaceCenter(BEAM_BuildingHit[building], TargetVecPos);
						float CalcDamageForceVec[3]; CalculateDamageForce(vecForward, 10000.0, CalcDamageForceVec);
						SDKHooks_TakeDamage(BEAM_BuildingHit[building], obj, client, damage/BEAM_Targets_Hit[obj], DMG_PLASMA, -1, CalcDamageForceVec, TargetVecPos);	// 2048 is DMG_NOGIB?
						BEAM_Targets_Hit[obj] *= LASER_AOE_DAMAGE_FALLOFF;
					}
					else
						BEAM_BuildingHit[building] = false;
				}
			}
			
			static float belowBossEyes[3];
			GetBeamDrawStartPoint_Client(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 60);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Laser, 0, 0, 0, 0.44, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 60);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Beam_Glow, 0, 0, 0, 0.55, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
			endPoint[2] -= 15.0;
			ParticleEffectAt(endPoint, "ExplosionCore_MidAir_Flare", 0.25);
			CreateExplosion(client, endPoint, 0.0, 0, 0);
		}
		else
		{
			delete trace;
		}
		delete trace;
	}
}

static bool BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsValidEntity(entity))
	{
		if(0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));
			
			if (((!StrContains(classname, "zr_base_npc", true) && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
			{
				for(int i=1; i <= (MAX_TARGETS_HIT -1 ); i++)
				{
					if(!BEAM_BuildingHit[i])
					{
						BEAM_BuildingHit[i] = entity;
						break;
					}
				}
			}
			
		}
	}
	return false;
}

static void GetBeamDrawStartPoint_Client(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
}

int MaxSupportBuildingsAllowed(int client, bool ingore_glass)
{
	int maxAllowed = 1;
	
  	int Building_health_attribute = i_MaxSupportBuildingsLimit[client];
	
	maxAllowed += Building_health_attribute; 
	maxAllowed += Blacksmith_Additional_SupportBuildings(client); 
	
	if(maxAllowed < 1)
	{
		maxAllowed = 1;
	}

	if(b_HasGlassBuilder[client])
	{
		if(!ingore_glass)
			maxAllowed = 1;
	}

	if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES)
	{
		if(!ingore_glass)
			maxAllowed = 1;
	}
	return maxAllowed;
}


public int MaxBarricadesAllowed(int client)
{
	int maxAllowed = 4;

	if(maxAllowed < 1)
	{
		maxAllowed = 1;
	}
	
	return maxAllowed;
}						
							
public int Building_ConfirmMountedAction(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			
			/*if(id == -1)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					//if(IsValidClient(owner))
					{
						int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
						for(int i; i<6; i++)
						{
							if(weapon == GetPlayerWeaponSlot(client, i))
							{
								int index = Store_GetEquipped(client, i);
								int number_return = Store_PackCurrentItem(client, index);
								if(number_return == 3)
								{
									TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAG_BONKSTUCK | TF_STUNFLAG_SOUND, 0);
									Building_Collect_Cooldown[entity][client] = GetGameTime() + 1.0;
									if(owner != -1 && owner != client)
									{
										if(Pack_A_Punch_Machine_money_limit[owner][client] <= 5)
										{
											Pack_A_Punch_Machine_money_limit[owner][client] += 1;
											CashSpent[owner] -= 400;
											Resupplies_Supplied[owner] += 40;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Pap Machine Used");
										}
									}
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "Your weapon was boosted");
									Store_ApplyAttribs(client);
									Store_GiveAll(client, GetClientHealth(client));
								}
								else if(number_return == 2)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Money To Pap");	
								}
								else if(number_return == 1)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetDefaultHudPosition(client);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Pap this");	
								}
								else if(number_return == 0)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav"); //This isnt supposed to ever happen.
								}
								break;
							}
						}
					}
				}
			}
			else if(id == -2)
			{
				delete menu;
			}
			else */
			if(id == -3)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 1);
				}
			}
			else if(id == -4)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 2);
				}
			}
			else if(id == -5)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 3);
				}
			}
			else if(id == -6)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 4);
				}
			}
			else if(id == -7)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}	
					Do_Perk_Machine_Logic(owner, client, entity, 5);
				}
			}
			else if(id == -8)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					Do_Perk_Machine_Logic(owner, client, entity, 6);
				}
			}
			else if(id == -9)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					Do_Perk_Machine_Logic(owner, client, entity, 7);
				}
			}
		}
	}
	return 0;
}

public void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk)
{
	/*
	float pos1[3];
	float pos2[3];
	int MountedBuilding = EntRefToEntIndex(Building_Mounted[owner]); 
	if(MountedBuilding == entity)
	{
		GetEntPropVector(owner, Prop_Data, "m_vecAbsOrigin", pos2);
	}
	else
	{
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
	}
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
	if(GetVectorDistance(pos1, pos2, true) > (200.0 * 200.0))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Too Far Away");		
		return;	
	}
	*/
	TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
	ApplyBuildingCollectCooldown(entity, client, 40.0);
	
	i_CurrentEquippedPerk[client] = what_perk;
	i_CurrentEquippedPerkPreviously[client] = what_perk;
	
	if(!Rogue_Mode() && owner > 0 && owner != client)
	{
		if(!Rogue_Mode() && Perk_Machine_money_limit[owner][client] < 10)
		{
			GiveCredits(owner, 40, true);
			Perk_Machine_money_limit[owner][client] += 1;
			Resupplies_Supplied[owner] += 4;
			SetDefaultHudPosition(owner);
			SetGlobalTransTarget(owner);
			ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Perk Machine Used");
		}
	}
	float pos[3];
	float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);

	pos[2] += 45.0;
	angles[1] -= 90.0;

	int particle = ParticleEffectAt(pos, "flamethrower_underwater", 1.0);
	SetEntPropVector(particle, Prop_Send, "m_angRotation", angles);
	Perk_Machine_Sickness[client] = GetGameTime() + 2.0;
	SetDefaultHudPosition(client, _, _, _, 5.0);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", PerkNames_Recieved[i_CurrentEquippedPerk[client]]);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	
	Barracks_UpdateAllEntityUpgrades(client);
}

public Action Building_PlaceVillage(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Village, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public bool Building_Village(int client, int entity)
{
	VillageCheckItems(client);
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	i_WhatBuilding[entity] = BuildingVillage;
	b_SentryIsCustom[entity] = !(Village_Flags[client] & VILLAGE_500);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.5, Timer_VillageThink, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT); //No custom anims
	i_VillageModelAppliance[entity] = 0;
	i_VillageModelApplianceCollisionBox[entity] = 0;
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_village");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 10.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	Building_Collect_Cooldown[entity][0] = 0.0;
	Barracks_UpdateEntityUpgrades(client, entity, true);
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	
	return true;
}

public Action Timer_VillageThink(Handle timer, int ref)
{
	float pos1[3] = {999999999.9, 999999999.9, 999999999.9};
	bool mounted;
	int owner;
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
	{
		owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(owner < 1 || owner > MaxClients)
		{
			SDKHooks_TakeDamage(entity, entity, entity, 999999.9);
			entity = INVALID_ENT_REFERENCE;
			owner = 0;
		}
		else if(Building_Mounted[owner] == ref)
		{
			GetClientEyePosition(owner, pos1);
			mounted = true;
		}
		else if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") >= 1.0)
		{
			if(!Building_Constructed[entity])
			{
				//BELOW IS SET ONCE!
				view_as<CClotBody>(entity).bBuildingIsPlaced = true;
				Building_Constructed[entity] = true;
				BuildingVillageChangeModel(owner, entity);
			}
			
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		}
		else
		{
			i_VillageModelAppliance[entity] = 0;
			i_VillageModelApplianceCollisionBox[entity] = 0;
			Building_Constructed[entity] = false;
		}
	}
	if(Village_Flags[owner] & VILLAGE_500)
	{
		if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") >= 1.0)
		{
			if(Building_Constructed[entity])
			{
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
			//	SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
			}
			CClotBody npc = view_as<CClotBody>(entity);
			npc.bBuildingIsPlaced = true;
			Building_Constructed[entity] = true;
		}
		else
		{
			SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") & ~EF_NODRAW);
			
			int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
			int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
			
			if(IsValidEntity(prop1))
			{
				RemoveEntity(prop1);
			}
			if(IsValidEntity(prop2))
			{
				RemoveEntity(prop2);
			}
			Building_Constructed[entity] = false;
		}
	}
	
	
	i_ExtraPlayerPoints[owner] += 2; //Static low point increace.
	if(IsValidEntity(entity))
	{
		if(Building_Constructed[entity])
		{
			BuildingVillageChangeModel(owner, entity);
		}
	}
	
	int effects = Village_Flags[owner];
	
	float range = 600.0;
	
	if(effects & VILLAGE_040)
		Village_ForceUpdate[owner] = true;
	
	if(Village_ReloadBuffFor[owner] > GetGameTime())
	{
		if(effects & VILLAGE_050)
			range = 10000.0;
	}
	else
	{
		effects &= ~VILLAGE_050;
		effects &= ~VILLAGE_040;
	}
	
	if(!(effects & VILLAGE_050))
	{
		if(effects & VILLAGE_100)
			range += 120.0;
		
		if(effects & VILLAGE_500)
		{
			range += 125.0;
		}
		else if(effects & VILLAGE_005)
		{
			range += 150.0;
		}
	}
	
	if(mounted)
		range *= 0.55;

	int points = VillagePointsLeft(owner);
	if(points < 0)
	{
		range = 0.0;
	}
	BuildingApplyDebuffyToEnemiesInRange(owner, range, mounted);

	range = range * range;
	ArrayList weapons = new ArrayList();
	ArrayList allies = new ArrayList();
	
	float pos2[3];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range && f_ClientArmorRegen[client] - 0.3 < GetGameTime())
			{
				allies.Push(client);

				if(effects & VILLAGE_002)
				{
					int maxarmor = MaxArmorCalculation(Armor_Level[client], client, 0.5);
					if(Armor_Charge[client] < maxarmor)
					{
						f_ClientArmorRegen[client] = GetGameTime() + 0.7;
						if(f_TimeUntillNormalHeal[client] > GetGameTime())
							GiveArmorViaPercentage(client, 0.00125, 1.0);
						else
							GiveArmorViaPercentage(client, 0.005, 1.0);
					}
				}
				else if(effects & VILLAGE_001)
				{
					if(Armor_Charge[client] < 0)
					{
						f_ClientArmorRegen[client] = GetGameTime() + 0.7;
						GiveArmorViaPercentage(client, 0.005, 1.0);
					}
				}

				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon > MaxClients)
					weapons.Push(weapon);
			}
		}
	}
	
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(GetTeam(i) == TFTeam_Red)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range)
				allies.Push(i);
		}
	}
	
	VillageBuff buff;
	int length = Village_Effects.Length;
	for(i = 0; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		if(buff.VillageRef == ref)
		{
			int target = EntRefToEntIndex(buff.EntityRef);
			if(target == -1)
			{
				Village_Effects.Erase(i--);
				length--;
			}
			else
			{
				int weapPos = -1;
				int allyPos = allies.FindValue(target);
				if(allyPos == -1)
					weapPos = weapons.FindValue(target);
				
				if(allyPos == -1 && weapPos == -1)
				{
					int oldBuffs = GetBuffEffects(buff.EntityRef);
					
					Village_Effects.Erase(i--);
					length--;
					
					UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
				}
				else
				{
					if(allyPos != -1)
					{
						allies.Erase(allyPos);
					}
					else
					{
						weapons.Erase(weapPos);
					}
					
					if(Village_ForceUpdate[owner])
					{
						int oldBuffs = GetBuffEffects(buff.EntityRef);
						
						buff.Effects = effects;
						Village_Effects.SetArray(i, buff);
						
						UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
					}
				}
			}
		}
	}
	
	length = allies.Length;
	for(i = 0; i < length; i++)
	{
		int target = allies.Get(i);
		
		buff.EntityRef = EntIndexToEntRef(target);
		
		int oldBuffs = GetBuffEffects(buff.EntityRef);
		
		buff.VillageRef = ref;
		buff.IsWeapon = false;
		buff.Effects = effects;
		Village_Effects.PushArray(buff);
		
		UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
	}
	
	length = weapons.Length;
	for(i = 0; i < length; i++)
	{
		int target = weapons.Get(i);
		
		buff.EntityRef = EntIndexToEntRef(target);
		
		int oldBuffs = GetBuffEffects(buff.EntityRef);
		
		buff.VillageRef = ref;
		buff.IsWeapon = true;
		buff.Effects = effects;
		Village_Effects.PushArray(buff);
		
		UpdateBuffEffects(target, buff.IsWeapon, oldBuffs, GetBuffEffects(buff.EntityRef));
	}
	
	delete weapons;
	delete allies;
	
	Village_ForceUpdate[owner] = false;
	return entity == INVALID_ENT_REFERENCE ? Plugin_Stop : Plugin_Continue;
}

void Building_ClearRefBuffs(int ref)
{
	for(int i = -1; (i = Village_Effects.FindValue(ref, VillageBuff::EntityRef)) != -1; )
	{
		Village_Effects.Erase(i);
	}
}

bool Building_NeatherseaReduced(int entity)
{
	return view_as<bool>(GetBuffEffects(EntIndexToEntRef(entity)) & VILLAGE_003);
}

void BuildingApplyDebuffyToEnemiesInRange(int client, float range, bool mounted)
{
	if(Village_Flags[client] & VILLAGE_004)
	{
		static float pos2[3];
		if(mounted)
		{
			GetClientEyePosition(client, pos2);
		}
		else
		{
			GetEntPropVector(i_HasSentryGunAlive[client], Prop_Data, "m_vecAbsOrigin", pos2);
		}

		Explode_Logic_Custom(0.0,
		client,
		client,
		-1,
		pos2,
		range,
		_,
		_,
		false,
		99,
		false,
		_,
		BuildingAntiRaidInternal);
	}
}

void BuildingAntiRaidInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if(b_thisNpcIsARaid[victim])
	{
		f_BuildingAntiRaid[victim] = GetGameTime() + 3.0;
	}
}

void Building_CamoOrRegrowBlocker(int entity, bool &camo = false, bool &regrow = false)
{
	if(camo || regrow)
	{
		if(GetTeam(entity) != 2)
		{
			static float pos1[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsValidEntity(i_HasSentryGunAlive[client]))
				{
					static float pos2[3];
					bool mounted = (Building_Mounted[client] == i_HasSentryGunAlive[client]);
					if(mounted)
					{
						GetClientEyePosition(client, pos2);
					}
					else
					{
						GetEntPropVector(i_HasSentryGunAlive[client], Prop_Data, "m_vecAbsOrigin", pos2);
					}

					float range = 600.0;
					
					if(Village_Flags[client] & VILLAGE_100)
						range += 120.0;
					
					if(Village_Flags[client] & VILLAGE_500)
					{
						range += 125.0;
					}
					else if(Village_Flags[client] & VILLAGE_005)
					{
						range += 150.0;
					}
					
					if(mounted)
						range *= 0.55;
					
					range = range * range;

					if(GetVectorDistance(pos1, pos2, true) < range)
					{
						if(camo && (Village_Flags[client] & VILLAGE_020))
							camo = false;
						
						if(regrow && (Village_Flags[client] & VILLAGE_010))
							regrow = false;
					}
				}
			}
		}
	}
}

void BarracksCheckItems(int client)
{
	i_NormalBarracks_HexBarracksUpgrades[client] = Store_HasNamedItem(client, "Barracks Hex Upgrade 1");
	i_NormalBarracks_HexBarracksUpgrades_2[client] = Store_HasNamedItem(client, "Barracks Hex Upgrade 2");
	WoodAmount[client] = float(Store_HasNamedItem(client, "Barracks Wood"));
	FoodAmount[client] = float(Store_HasNamedItem(client, "Barracks Food"));
	GoldAmount[client] = float(Store_HasNamedItem(client, "Barracks Gold"));
}

static void VillageCheckItems(int client)
{
	int lastFlags = Village_Flags[client];
	
	if(Store_HasNamedItem(client, "Buildable Village"))
	{
		Village_Flags[client] = VILLAGE_000;
		
		switch(Store_HasNamedItem(client, "Village NPC Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_100;
			
			case 2:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200;
			
			case 3:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300;
			
			case 4:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300 + VILLAGE_400;
			
			case 5:
				Village_Flags[client] += VILLAGE_100 + VILLAGE_200 + VILLAGE_300 + VILLAGE_400 + VILLAGE_500;
		}
		
		switch(Store_HasNamedItem(client, "Village Buffing Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_010;
			
			case 2:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020;
			
			case 3:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030;
			
			case 4:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030 + VILLAGE_040;
			
			case 5:
				Village_Flags[client] += VILLAGE_010 + VILLAGE_020 + VILLAGE_030 + VILLAGE_040 + VILLAGE_050;
		}
		
		switch(Store_HasNamedItem(client, "Village Support Expert"))
		{
			case 1:
				Village_Flags[client] += VILLAGE_001;
			
			case 2:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002;
			
			case 3:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003;
			
			case 4:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003 + VILLAGE_004;
			
			case 5:
				Village_Flags[client] += VILLAGE_001 + VILLAGE_002 + VILLAGE_003 + VILLAGE_004 + VILLAGE_005;
		}
		
		if(lastFlags != Village_Flags[client])
			Village_ForceUpdate[client] = true;
	}
	else
	{
		Village_Flags[client] = 0;
	}
}

static const int VillageCosts[] =
{
	// B0 1
	// B1 2
	// B2 4
	// B3 7
	// B4 11
	// B5 16
	// B6 35

	// R0 0
	// R1 1
	// R2 2
	// R3 4
	// R4 6
	// R5 9

	0,

	1,	// 1	- B0 R0
	3,	// 4	- B1 R2
	2,	// 6	- B2 R2
	3,	// 9	- B3 R2
	4,	// 13	- B4 R2

	1,	// 1	- B0 R0
	2,	// 3	- B1 R1
	5,	// 8	- B3 R1
	6,	// 14	- B4 R3
	7,	// 21	- B5 R4

	2,	// 2	- B1 R0
	2,	// 4	- B1 R2
	6,	// 10	- B3 R3
	12,	// 24	- B5 R5
	18,	// 44	- B6 R5
};

static int VillagePointsLeft(int client)
{
	int level = MaxSupportBuildingsAllowed(client, true);	// 1 - 16

	if(Store_HasNamedItem(client, "Construction Novice"))
		level++;
	
	if(Store_HasNamedItem(client, "Construction Apprentice"))
		level++;
	
	if(Store_HasNamedItem(client, "Engineering Repair Handling book"))
		level += 2;
	
	if(Store_HasNamedItem(client, "Alien Repair Handling book"))
		level += 2;
	
	if(Store_HasNamedItem(client, "Cosmic Repair Handling book"))
		level += 3;
	
	if(Store_HasNamedItem(client, "Construction Killer"))	// 25 -> 44
		level += 19;
	
	for(int i = 1; i < sizeof(VillageCosts); i++)
	{
		if(Village_Flags[client] & (1 << i))
			level -= VillageCosts[i];
	}

	return level;	// 1 - 25/44
}

static void VillageUpgradeMenu(int client, int viewer)
{
	bool owner = client == viewer;
	
	Menu menu = new Menu(VillageUpgradeMenuH);
	
	SetGlobalTransTarget(viewer);
	int points = VillagePointsLeft(client);
	if(points >= 0)
	{
		menu.SetTitle("%s\n \nBananas: %d (%s)\n ", TranslateItemName(viewer, "Buildable Village", ""), points, TranslateItemName(viewer, "Building Upgrades", ""));
	}
	else
	{
		menu.SetTitle("%s\n \nYoure in Banana dept! Buffs dont work!: %d (%s)\n ", TranslateItemName(viewer, "Buildable Village", ""), points, TranslateItemName(viewer, "Building Upgrades", ""));	
	}
	
	int paths;
	if(Village_Flags[client] & VILLAGE_100)
		paths++;
	
	if(Village_Flags[client] & VILLAGE_010)
		paths++;
	
	if(Village_Flags[client] & VILLAGE_001)
		paths++;
	
	bool tier = (Village_Flags[client] & VILLAGE_300) || (Village_Flags[client] & VILLAGE_030) || (Village_Flags[client] & VILLAGE_003);
	
	char buffer[256];
	if(Village_Flags[client] & VILLAGE_500)
	{
		menu.AddItem("", TranslateItemName(viewer, "Rebel Expertise", ""), ITEMDRAW_DISABLED);
		menu.AddItem("", "Village becomes an attacking sentry, plus all Rebels in", ITEMDRAW_DISABLED);
		menu.AddItem("", "radius attack faster, deal more damage, and start with $1750.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_400)
	{
		if(Village_TierExists[0] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Rebel Mentoring", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "All Rebels in radius start with $500,", ITEMDRAW_DISABLED);
			menu.AddItem("", "increased range and attack speed.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [4 Bananas]", TranslateItemName(viewer, "Rebel Expertise", ""));
			menu.AddItem(VilN(VILLAGE_500), buffer, (!owner || points < 4) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Village becomes an attacking sentry, plus all Rebels in", ITEMDRAW_DISABLED);
			menu.AddItem("", "radius attack faster, deal more damage, and start with $1750.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_300)
	{
		FormatEx(buffer, sizeof(buffer), "%s [3 Bananas]%s", TranslateItemName(viewer, "Rebel Mentoring", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_400), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "All Rebels in radius start with $500,", ITEMDRAW_DISABLED);
		menu.AddItem("", "increased range and attack speed.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_200)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Jungle Drums", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Increases attack speed and reloadspeed of all", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies in the radius.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [2 Bananas]%s", TranslateItemName(viewer, "Rebel Training", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_300), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "All Rebels in radius get", ITEMDRAW_DISABLED);
			menu.AddItem("", "more range and more damage.\n", ITEMDRAW_DISABLED);
			menu.AddItem("", "Village will spawn rebels every 3 waves upto 3\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_100)
	{
		FormatEx(buffer, sizeof(buffer), "%s [3 Bananas]%s", TranslateItemName(viewer, "Jungle Drums", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_200), buffer, (!owner || points < 3) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases attack speed of all", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies in the radius by 5% and healrate by 8%.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		if(owner)
			menu.AddItem("", "TIP: Only one path can have a tier 3 upgrade.\n ", ITEMDRAW_DISABLED);
		
		FormatEx(buffer, sizeof(buffer), "%s [1 Banana]%s", TranslateItemName(viewer, "Bigger Radius", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : Village_TierExists[0] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_100), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases influence radius of the village.\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_050)
	{
		menu.AddItem("", TranslateItemName(viewer, "Homeland Defense", ""), ITEMDRAW_DISABLED);
		menu.AddItem("", "Ability now increases attack speed and reloadspeed and heal rate by 25%", ITEMDRAW_DISABLED);
		menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_040)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Call To Arms", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies +12% attack speed and reloadspeed and heal rate for a short time.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [7 Bananas]", TranslateItemName(viewer, "Homeland Defense", ""));
			menu.AddItem(VilN(VILLAGE_050), buffer, (!owner || points < 7) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Ability now increases attack speed and reloadspeed and heal rate by 25%", ITEMDRAW_DISABLED);
			menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_030)
	{
		FormatEx(buffer, sizeof(buffer), "%s [6 Bananas]%s", TranslateItemName(viewer, "Call To Arms", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_040), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies +12% attack speed and reloadspeed and heal rate for a short time.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_020)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Radar Scanner", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Removes camo properites off", ITEMDRAW_DISABLED);
			menu.AddItem("", "enemies while in influence radius.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [5 Bananas]%s", TranslateItemName(viewer, "Monkey Intelligence Bureau", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_030), buffer, (!owner || points < 5) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "The Bureau grants special Bloon popping knowledge, allowing", ITEMDRAW_DISABLED);
			menu.AddItem("", "nearby players and allies to deal 5% more damage.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_010)
	{
		FormatEx(buffer, sizeof(buffer), "%s [2 Bananas]%s", TranslateItemName(viewer, "Radar Scanner", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_020), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Removes camo properites off", ITEMDRAW_DISABLED);
		menu.AddItem("", "enemies while in influence radius.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "%s [1 Banana]%s", TranslateItemName(viewer, "Grow Blocker", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : Village_TierExists[1] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_010), buffer, (!owner || points < 1) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Lowers non-boss enemies from", ITEMDRAW_DISABLED);
		menu.AddItem("", "gaining health in the influence radius as much (50% usually).\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_005)
	{
		menu.AddItem("", "Iberia Lighthouse", ITEMDRAW_DISABLED);
		menu.AddItem("", "Increases influnce radius and all nearby allies", ITEMDRAW_DISABLED);
		menu.AddItem("", "gains a +10% attack speed and healing rate.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_004)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", "Iberia Anti-Raid", ITEMDRAW_DISABLED);
			menu.AddItem("", "Causes Raid Bosses to take 10% more damage in its range and for 3 seconds after existing the range.", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Iberia Lighthouse [18 Bananas]");
			menu.AddItem(VilN(VILLAGE_005), buffer, (!owner || points < 18) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Increases influnce radius and all nearby allies", ITEMDRAW_DISABLED);
			menu.AddItem("", "gains a +10% attack speed and healing rate.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_003)
	{
		FormatEx(buffer, sizeof(buffer), "Iberia Anti-Raid [12 Bananas]");
		menu.AddItem(VilN(VILLAGE_004), buffer, (!owner || points < 12) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Causes Raid Bosses to take 10% more damage in its range and for 3 seconds after existing the range.", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_002)
	{
		if(tier)
		{
			menu.AddItem("", "Armor Aid", ITEMDRAW_DISABLED);
			menu.AddItem("", "Gain a point of armor every half second.\n ", ITEMDRAW_DISABLED);
			menu.AddItem("", "to all players with armor in range.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Little Handy [6 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_003), buffer, (!owner || points < 6) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Reduces the damage caused by nethersea brands", ITEMDRAW_DISABLED);
			menu.AddItem("", "by 80% to all allies with in range.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_001)
	{
		FormatEx(buffer, sizeof(buffer), "Armor Aid [2 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_002), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Gain 1% of armor every half.\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "second to all players in range.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "Wandering Aid [2 Bananas]%s", Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : Village_TierExists[2] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_001), buffer, (!owner || points < 2) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Heals 1% of armor erosion every.\n ", ITEMDRAW_DISABLED);
		menu.AddItem("", "half second to all players in range.\n ", ITEMDRAW_DISABLED);
	}

	float pos[3];
	bool mounted = (Building_Mounted[client] == i_HasSentryGunAlive[client]);
	if(mounted)
	{
		GetClientEyePosition(client, pos);
	}
	else
	{
		if(IsValidEntity(i_HasSentryGunAlive[client]))
		{
			GetEntPropVector(i_HasSentryGunAlive[client], Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 15.0;
		}
	}
/*
	float range = 600.0;
	
	if(Village_Flags[client] & VILLAGE_100)
		range += 120.0;
	
	if(Village_Flags[client] & VILLAGE_500)
	{
		range += 125.0;
	}
	else if(Village_Flags[client] & VILLAGE_005)
	{
		range += 150.0;
	}
	
	if(mounted)
		range *= 0.55;
	
	int BuildingAlive = i_HasSentryGunAlive[client];
	if(IsValidEntity(BuildingAlive))
	{
		BuildingAlive = EntRefToEntIndex(BuildingAlive);
		if(f_VillageRingVectorCooldown[BuildingAlive] < GetGameTime())
		{
			f_VillageRingVectorCooldown[BuildingAlive] = GetGameTime() + 3.0;
			spawnRing_Vectors(pos, range, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 3.0, 6.0, 0.1, 1);
		}
	}*/
	
	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(viewer, MENU_TIME_FOREVER);
}

public int VillageUpgradeMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));
			
			switch(StringToInt(num))
			{
				case VILLAGE_500:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 5);
					Village_TierExists[0] = 5;
					
					int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
					if(entity > MaxClients && IsValidEntity(entity))
					{
						RemoveEntity(entity);
						f_BuildingIsNotReady[client] = 0.0; 
						Building_Sentry_Cooldown[client] = 0.0; //Reset the cooldown!
					}
					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_400:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 4);
					Village_TierExists[0] = 4;

					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_300:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 3);
					Village_TierExists[0] = 3;

					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
					{
						if(!b_NpcHasDied[i])
						{
							if(Citizen_IsIt(i))
								count++;
						}
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_200:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 2);
					Village_TierExists[0] = 2;
				}
				case VILLAGE_100:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 1);
					Village_TierExists[0] = 1;
				}
				case VILLAGE_050:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 5);
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 5;
				}
				case VILLAGE_040:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 4);
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 4;
				}
				case VILLAGE_030:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 3);
					Village_TierExists[1] = 3;
				}
				case VILLAGE_020:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 2);
					Village_TierExists[1] = 2;
				}
				case VILLAGE_010:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 1);
					Village_TierExists[1] = 1;
				}
				case VILLAGE_005:
				{
					Store_SetNamedItem(client, "Village Support Expert", 5);
					Village_TierExists[2] = 5;
				}
				case VILLAGE_004:
				{
					Store_SetNamedItem(client, "Village Support Expert", 4);
					Village_TierExists[2] = 4;
				}
				case VILLAGE_003:
				{
					Store_SetNamedItem(client, "Village Support Expert", 3);
					Village_TierExists[2] = 3;
				}
				case VILLAGE_002:
				{
					Store_SetNamedItem(client, "Village Support Expert", 2);
					Village_TierExists[2] = 2;
				}
				case VILLAGE_001:
				{
					Store_SetNamedItem(client, "Village Support Expert", 1);
					Village_TierExists[2] = 1;
				}
			}
			
			ClientCommand(client, "playgamesound \"mvm/mvm_money_pickup.wav\"");
			VillageCheckItems(client);
			VillageUpgradeMenu(client, client);
		}
	}
	return 0;
}

static char[] VilN(int flag)
{
	char num[16];
	IntToString(flag, num, sizeof(num));
	return num;
}

static int GetBuffEffects(int ref)
{
	int flags;
	
	VillageBuff buff;
	int length = Village_Effects.Length;
	for(int i; i < length; i++)
	{
		Village_Effects.GetArray(i, buff);
		if(buff.EntityRef == ref)
			flags |= buff.Effects;
	}
	
	return flags;
}

static void UpdateBuffEffects(int entity, bool weapon, int oldBuffs, int newBuffs)
{
	if(weapon)
	{
		for(int i; i < 16; i++)
		{
			int flag = (1 << i);
			bool hadBefore = view_as<bool>(oldBuffs & flag);
			
			if(newBuffs & flag)
			{
				if(!hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_000:
						{
							if(Attributes_Has(entity, 101))
								Attributes_SetMulti(entity, 101, 1.1);	// Projectile Range
							
							if(Attributes_Has(entity, 103))
								Attributes_SetMulti(entity, 103, 1.1);	// Projectile Speed
						}
						case VILLAGE_200:
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 0.975);	// Fire Rate
							
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 0.975);	// Reload Time
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.025);	// Heal Rate
						}
						case VILLAGE_030:
						{
							if(Attributes_Has(entity, 2))
								Attributes_SetMulti(entity, 2, 1.05);	// Damage
							
							if(Attributes_Has(entity, 410))
								Attributes_SetMulti(entity, 410, 1.05);	// Mage Damage
						}
						case VILLAGE_040, VILLAGE_050:
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 0.88);	// Fire Rate
							
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 0.88);	// Reload Time
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.12);	// Heal Rate
						}
						case VILLAGE_005:
						{
							if(Attributes_Has(entity, 6))
								Attributes_SetMulti(entity, 6, 0.90);	// Fire Rate
							
							if(Attributes_Has(entity, 97))
								Attributes_SetMulti(entity, 97, 0.90);	// Reload Time
							
							if(Attributes_Has(entity, 8))
								Attributes_SetMulti(entity, 8, 1.1);	// Heal Rate
						}
					}
				}
			}
			else if(hadBefore)
			{
				switch(flag)
				{
					case VILLAGE_000:
					{
						if(Attributes_Has(entity, 101))
							Attributes_SetMulti(entity, 101, 1.0 / 1.1);	// Projectile Range
						
						if(Attributes_Has(entity, 103))
							Attributes_SetMulti(entity, 103, 1.0 / 1.1);	// Projectile Speed
					}
					case VILLAGE_200:
					{
						if(Attributes_Has(entity, 6))
							Attributes_SetMulti(entity, 6, 1.0 / 0.975);	// Fire Rate
						
						if(Attributes_Has(entity, 97))
							Attributes_SetMulti(entity, 97, 1.0 / 0.975);	// Reload Time
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.025);	// Heal Rate
					}
					case VILLAGE_030:
					{
						if(Attributes_Has(entity, 2))
								Attributes_SetMulti(entity, 2, 1.0 / 1.05);	// Damage
					
						if(Attributes_Has(entity, 410))
							Attributes_SetMulti(entity, 410, 1.0 / 1.05);	// Mage Damage
					}
					case VILLAGE_040, VILLAGE_050:
					{
						if(Attributes_Has(entity, 6))
							Attributes_SetMulti(entity, 6, 1.0 / 0.88);	// Fire Rate
						
						if(Attributes_Has(entity, 97))
							Attributes_SetMulti(entity, 97, 1.0 / 0.88);	// Reload Time
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.12);	// Heal Rate
					}
					case VILLAGE_005:
					{
						if(Attributes_Has(entity, 6))
							Attributes_SetMulti(entity, 6, 1.0 / 0.90);	// Fire Rate
						
						if(Attributes_Has(entity, 97))
							Attributes_SetMulti(entity, 97, 1.0 / 0.90);	// Reload Time
						
						if(Attributes_Has(entity, 8))
							Attributes_SetMulti(entity, 8, 1.0 / 1.1);	// Heal Rate
					}
				}
			}
		}
	}
	else if(Citizen_IsIt(entity))
	{
		Citizen npc = view_as<Citizen>(entity);
		
		for(int i; i < 16; i++)
		{
			int flag = (1 << i);
			bool hadBefore = view_as<bool>(oldBuffs & flag);
			
			if(newBuffs & flag)
			{
				if(!hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_000:
						{
							npc.m_fGunRangeBonus *= 1.1;
						}
						case VILLAGE_200:
						{
							npc.m_fGunFirerate *= 0.975;
							npc.m_fGunReload *= 0.975;
						}
						case VILLAGE_300:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip++;
							
							npc.m_fGunRangeBonus *= 1.05;
						}
						case VILLAGE_400:
						{
							if(npc.m_iGunValue < 500)
								npc.m_iGunValue = 500;
							
							npc.m_fGunFirerate *= 0.95;
							npc.m_fGunReload *= 0.95;
						}
						case VILLAGE_500:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip += 2;
							
							if(npc.m_iGunValue < 1750)
								npc.m_iGunValue = 1750;
							
							npc.m_fGunRangeBonus *= 1.1;
							npc.m_fGunFirerate *= 0.9;
							npc.m_fGunReload *= 0.9;
						}
						case VILLAGE_030:
						{
							npc.m_fGunRangeBonus *= 1.05;
						}
						case VILLAGE_040:
						{
							npc.m_fGunFirerate *= 0.88;
							npc.m_fGunReload *= 0.88;
						}
						case VILLAGE_050:
						{
							npc.m_fGunFirerate *= 0.85;
							npc.m_fGunReload *= 0.85;
						}
						case VILLAGE_005:
						{
							npc.m_fGunFirerate *= 0.90;
							npc.m_fGunReload *= 0.90;
						}
					}
				}
			}
			else if(hadBefore)
			{
				switch(flag)
				{
					case VILLAGE_000:
					{
						npc.m_fGunRangeBonus /= 1.1;
					}
					case VILLAGE_200:
					{
						npc.m_fGunFirerate /= 0.975;
						npc.m_fGunReload /= 0.975;
					}
					case VILLAGE_300:
					{
					//	if(npc.m_iGunClip > 1)
					//		npc.m_iGunClip--;
						
						npc.m_fGunRangeBonus /= 1.05;
					}
					case VILLAGE_400:
					{
						npc.m_fGunFirerate /= 0.95;
						npc.m_fGunReload /= 0.95;
					}
					case VILLAGE_500:
					{
					//	if(npc.m_iGunClip > 2)
					//		npc.m_iGunClip -= 2;
						
						npc.m_fGunRangeBonus /= 1.1;
						npc.m_fGunFirerate /= 0.9;
						npc.m_fGunReload /= 0.9;
					}
					case VILLAGE_030:
					{
						npc.m_fGunRangeBonus /= 1.05;
					}
					case VILLAGE_040:
					{
						npc.m_fGunFirerate /= 0.88;
						npc.m_fGunReload /= 0.88;
					}
					case VILLAGE_050:
					{
						npc.m_fGunFirerate /= 0.85;
						npc.m_fGunReload /= 0.85;
					}
					case VILLAGE_005:
					{
						npc.m_fGunFirerate /= 0.90;
						npc.m_fGunReload /= 0.90;
					}
				}
			}
		}
	}
	else if(entity > MaxClients)
	{
		BarrackBody npc = view_as<BarrackBody>(entity);
		
		if(npc.OwnerUserId)
		{
			for(int i; i < 16; i++)
			{
				int flag = (1 << i);
				bool hadBefore = view_as<bool>(oldBuffs & flag);
				
				if(newBuffs & flag)
				{
					if(!hadBefore)
					{
						switch(flag)
						{
							case VILLAGE_200:
							{
								npc.BonusFireRate *= 0.975;
							}
							case VILLAGE_030:
							{
								npc.BonusDamageBonus *= 1.05;
							}
							case VILLAGE_040:
							{
								npc.BonusFireRate *= 0.88;
							}
							case VILLAGE_050:
							{
								npc.BonusFireRate *= 0.85;
							}
							case VILLAGE_005:
							{
								npc.BonusFireRate *= 0.90;
							}
						}
					}
				}
				else if(hadBefore)
				{
					switch(flag)
					{
						case VILLAGE_200:
						{
							npc.BonusFireRate/= 0.95;
						}
						case VILLAGE_030:
						{
							npc.BonusDamageBonus /= 1.05;
						}
						case VILLAGE_040:
						{
							npc.BonusFireRate /= 0.88;
						}
						case VILLAGE_050:
						{
							npc.BonusFireRate /= 0.85;
						}
						case VILLAGE_005:
						{
							npc.BonusFireRate /= 0.90;
						}
					}
				}
			}
		}
	}
	/*
	else if(entity <= MaxClients)
	{
		bool oldBuff = (oldBuffs & VILLAGE_200) || (oldBuffs & VILLAGE_030) || (oldBuffs & VILLAGE_003);
		
		if((newBuffs & VILLAGE_200) || (newBuffs & VILLAGE_030) || (newBuffs & VILLAGE_003))
		{
			if(!oldBuff)
				TF2_AddCondition(entity, TFCond_TeleportedGlow);
		}
		else if(oldBuff)
		{
			TF2_RemoveCondition(entity, TFCond_TeleportedGlow);
		}
		
	}
	*/
}

public MRESReturn Dhook_FinishedBuilding_Pre(int Building_Index, Handle hParams) 
{
	/*
	SetEntPropFloat(Building_Index, Prop_Send, "m_flModelScale", 0.85);

	SetEntityModel(Building_Index, BARRICADE_MODEL);

	*/
	return MRES_Ignored;
}

void Dhook_FinishedBuilding_Post_Frame(int RefBuild)
{
	int Building_Index = EntRefToEntIndex(RefBuild);
	if(IsValidEntity(Building_Index))
	{
		CClotBody npc = view_as<CClotBody>(Building_Index);
		switch(i_WhatBuilding[Building_Index])
		{
			case BuildingElevator:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;	
				SetEntityModel(Building_Index, ELEVATOR_MODEL);
				SetEntPropFloat(Building_Index, Prop_Send, "m_flModelScale", 1.15); //Abit bigger!
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
			}
			case BuildingBarricade:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntityModel(Building_Index, BARRICADE_MODEL);
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
			}
			case BuildingRailgun:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntityModel(Building_Index, CUSTOM_SENTRYGUN_MODEL);

			}
			case BuildingMortar:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				
				SetEntityModel(Building_Index, CUSTOM_SENTRYGUN_MODEL);

			}
			case BuildingSummoner:
			{
				SetEntProp(Building_Index, Prop_Send, "m_fEffects", GetEntProp(Building_Index, Prop_Send, "m_fEffects") | EF_NODRAW);
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				float vOrigin[3];
				float vAngles[3];
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						int clientPre = GetEntPropEnt(Building_Index, Prop_Send, "m_hBuilder");
						if((i_NormalBarracks_HexBarracksUpgrades[clientPre] & ZR_BARRACKS_UPGRADES_TOWER))
						{
							DispatchKeyValue(prop1, "model", "models/props_manor/clocktower_01.mdl");
							DispatchKeyValue(prop1, "modelscale", "0.11");
						}
						else
						{
							DispatchKeyValue(prop1, "model", SUMMONER_MODEL);
							DispatchKeyValue(prop1, "modelscale", "0.15");
						}
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1_Summoner);
					}
				}
				SetEntityModel(Building_Index, SUMMONER_MODEL);			
			}
			case BuildingHealingStation:
			{	
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] += 180.0;
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", HEALING_STATION_MODEL);
						DispatchKeyValue(prop1, "modelscale", "0.70");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] += 180.0;
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] += 180.0;
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", HEALING_STATION_MODEL);
						DispatchKeyValue(prop2, "modelscale", "0.70");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] += 180.0;
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
					}
				}
				SetEntityModel(Building_Index, HEALING_STATION_MODEL);
				/*
				static const float minbounds[3] = {-15.0, -15.0, 0.0};
				static const float maxbounds[3] = {15.0, 15.0, 45.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);
				npc.UpdateCollisionBox();	
				*/
				//Do not override model collisions of sentries, they are wierd.

			}
			case BuildingPackAPunch:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 90.0;
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", PACKAPUNCH_MODEL);
						DispatchKeyValue(prop1, "modelscale", "1.0");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 90.0;
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 90.0;
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", PACKAPUNCH_MODEL);
						DispatchKeyValue(prop2, "modelscale", "1.0");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);

						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 90.0;
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
					}
				}

				SetEntityModel(Building_Index, PACKAPUNCH_MODEL);

				static const float minbounds[3] = {-25.0, -25.0, 0.0};
				static const float maxbounds[3] = {25.0, 25.0, 65.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);
						
				npc.UpdateCollisionBox();	

				float eyePitch[3];
				GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", eyePitch);
				eyePitch[1] -= 90.0;
														
				TeleportEntity(Building_Index, NULL_VECTOR, eyePitch, NULL_VECTOR);
			}
			case BuildingPerkMachine:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 90.0;
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", PERKMACHINE_MODEL);
						DispatchKeyValue(prop1, "modelscale", "1.0");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 90.0;
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 90.0;
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", PERKMACHINE_MODEL);
						DispatchKeyValue(prop2, "modelscale", "1.0");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 90.0;
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
					}
				}
				SetEntityModel(Building_Index, PERKMACHINE_MODEL);

				static const float minbounds[3] = {-20.0, -20.0, 0.0};
				static const float maxbounds[3] = {20.0, 20.0, 65.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);


				npc.UpdateCollisionBox();	
				float eyePitch[3];
				GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", eyePitch);
				eyePitch[1] -= 90.0;
														
				TeleportEntity(Building_Index, NULL_VECTOR, eyePitch, NULL_VECTOR);
							
			}
			case BuildingArmorTable:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", "models/props_manor/table_01.mdl");
						DispatchKeyValue(prop1, "modelscale", "1.0");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1_Armor);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", "models/props_manor/table_01.mdl");
						DispatchKeyValue(prop2, "modelscale", "1.0");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2_Armor);
					}
				}
				SetEntityModel(Building_Index, "models/props_manor/table_01.mdl");

				static const float minbounds[3] = {-20.0, -20.0, 0.0};
				static const float maxbounds[3] = {20.0, 20.0, 35.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);


				npc.UpdateCollisionBox();		
			}
			case BuildingAmmobox:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					vOrigin[2] += 15.0;
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 180.0;
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", "models/items/ammocrate_smg1.mdl");
						DispatchKeyValue(prop1, "modelscale", "1.00");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 180.0;
						vOrigin[2] += 15.0;
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					vOrigin[2] += 15.0;
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] -= 180.0;
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", "models/items/ammocrate_smg1.mdl");
						DispatchKeyValue(prop2, "modelscale", "1.00");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] -= 180.0;
						vOrigin[2] += 15.0;
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
					}
				}

				SetEntityModel(Building_Index, "models/items/ammocrate_smg1.mdl");

				static const float minbounds[3] = {-20.0, -20.0, -18.0};
				static const float maxbounds[3] = {20.0, 20.0, 18.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);


				npc.UpdateCollisionBox();			
											
				GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
				GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);

				vOrigin[2] += 15.0;
				vAngles[1] -= 180.0;
																	
				TeleportEntity(Building_Index, vOrigin, vAngles, NULL_VECTOR);
							
			}
			case BuildingVillage:
			{
				int owner = GetEntPropEnt(Building_Index, Prop_Send, "m_hBuilder");
				if(IsValidEntity(owner) && (Village_Flags[owner] & VILLAGE_500))
				{
					SetEntProp(Building_Index, Prop_Send, "m_fEffects", GetEntProp(Building_Index, Prop_Send, "m_fEffects") | EF_NODRAW);
					npc.bBuildingIsPlaced = true;
					Building_Constructed[Building_Index] = true;
					float vOrigin[3];
					float vAngles[3];
					
					int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
					
					if(IsValidEntity(prop1))
					{
						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
					}
					else
					{
						prop1 = CreateEntityByName("prop_dynamic_override");
						if(IsValidEntity(prop1))
						{
							DispatchKeyValue(prop1, "model", VILLAGE_MODEL_REBEL);
							DispatchKeyValue(prop1, "modelscale", "0.45");
							DispatchKeyValue(prop1, "StartDisabled", "false");
							DispatchKeyValue(prop1, "Solid", "0");
							SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
							DispatchSpawn(prop1);
							SetEntityCollisionGroup(prop1, 1);
							AcceptEntityInput(prop1, "DisableShadow");
							AcceptEntityInput(prop1, "DisableCollision");
							SetEntityMoveType(prop1, MOVETYPE_NONE);
							SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
							Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop1);
							Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
							SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

							GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
							GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
							
							TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
							SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1_Summoner);
						}
					}
												
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
																		
					TeleportEntity(Building_Index, vOrigin, vAngles, NULL_VECTOR);
					
				}
							
			}
			case BuildingBlacksmith:
			{
				npc.bBuildingIsPlaced = true;
				Building_Constructed[Building_Index] = true;
				SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
				float vOrigin[3];
				float vAngles[3];
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][0]);
				int prop2 = EntRefToEntIndex(Building_Hidden_Prop[Building_Index][1]);
				
				if(IsValidEntity(prop1))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] += 180.0;
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop1 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop1))
					{
						DispatchKeyValue(prop1, "model", "models/props_medieval/anvil.mdl");
						DispatchKeyValue(prop1, "modelscale", "0.8");
						DispatchKeyValue(prop1, "StartDisabled", "false");
						DispatchKeyValue(prop1, "Solid", "0");
						SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop1);
						SetEntityCollisionGroup(prop1, 1);
						AcceptEntityInput(prop1, "DisableShadow");
						AcceptEntityInput(prop1, "DisableCollision");
						SetEntityMoveType(prop1, MOVETYPE_NONE);
						SetEntProp(prop1, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
						Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] += 180.0;
						TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
					}
				}
				
				if(IsValidEntity(prop2))
				{
					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					vAngles[1] += 180.0;
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				}
				else
				{
					prop2 = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(prop2))
					{
						DispatchKeyValue(prop2, "model", "models/props_medieval/anvil.mdl");
						DispatchKeyValue(prop2, "modelscale", "0.8");
						DispatchKeyValue(prop2, "StartDisabled", "false");
						DispatchKeyValue(prop2, "Solid", "0");
						SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
						DispatchSpawn(prop2);
						SetEntityCollisionGroup(prop2, 1);
						AcceptEntityInput(prop2, "DisableShadow");
						AcceptEntityInput(prop2, "DisableCollision");
						SetEntityMoveType(prop2, MOVETYPE_NONE);
						SetEntProp(prop2, Prop_Data, "m_nNextThinkTick", -1.0);
						Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
						Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
						SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

						GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
						GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
						vAngles[1] += 180.0;
						TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
						SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
					}
				}
				SetEntityModel(Building_Index, "models/props_medieval/anvil.mdl");
				/*
				static const float minbounds[3] = {-15.0, -15.0, 0.0};
				static const float maxbounds[3] = {15.0, 15.0, 45.0};
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);
				npc.UpdateCollisionBox();	
				*/
				//Do not override model collisions of sentries, they are wierd.

			}
		}
		int client = GetEntPropEnt(Building_Index, Prop_Send, "m_hBuilder");
		if(IsValidClient(client)) //Make sure that they dont trigger the building once its done and dont get stuck like idiotas
		{
			SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
			SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
		}
	}
}
public MRESReturn Dhook_FinishedBuilding_Post(int Building_Index, Handle hParams) 
{
	//tf2 buildings are aids to work with.
	//Frame_TeleportBuilding_Init Should be smaller.
	RequestFrames(Dhook_FinishedBuilding_Post_Frame, 10, EntIndexToEntRef(Building_Index));
	static char buffer[36];
	GetEntityClassname(Building_Index, buffer, sizeof(buffer));
	if(!StrContains(buffer, "obj_dispenser"))
	{
		SetEntProp(Building_Index, Prop_Send, "m_bCarried", true);
	}
	return MRES_Ignored;
}

// set  Data_prop m_pPhysicsObject  to 1 in here

public MRESReturn Dhook_FirstSpawn_Pre(int Building_Index, Handle hParams) 
{
	return MRES_Ignored;
}

public MRESReturn Dhook_FirstSpawn_Post(int Building_Index, Handle hParams) 
{
	return MRES_Ignored;
}
/*
float WoodAmount[MAXTF2PLAYERS];
float FoodAmount[MAXTF2PLAYERS];
float GoldAmount[MAXTF2PLAYERS];
int SupplyRate[MAXTF2PLAYERS];
See ZR core.
*/
static int InMenu[MAXTF2PLAYERS];
static float TrainingStartedIn[MAXTF2PLAYERS];
static float TrainingIn[MAXTF2PLAYERS];
static int TrainingIndex[MAXTF2PLAYERS];
static int TrainingQueue[MAXTF2PLAYERS];
static float ResearchStartedIn[MAXTF2PLAYERS];
static float ResearchIn[MAXTF2PLAYERS];
static int ResearchIndex[MAXTF2PLAYERS];
static int CommandMode[MAXTF2PLAYERS];
//bool FinalBuilder[MAXENTITIES];
static bool MedievalUnlock[MAXTF2PLAYERS];
//bool GlassBuilder[MAXENTITIES];
static int CivType[MAXTF2PLAYERS];
static bool b_InUpgradeMenu[MAXTF2PLAYERS];

enum
{
	NPCIndex = 0,
	UpgradeIndex = 0,
	WoodCost = 1,
	FoodCost = 2,
	GoldCost = 3,
	TrainTime = 4,
	TrainLevel = 5,
	SupplyCost = 6,
	ResearchRequirement = 7,
	ResearchRequirement2 = 8,
	RequirementHexArray = 6,
	Requirement = 7,
	Requirement2HexArray = 8,
	Requirement2 = 9,
	GiveHexArray = 10,
	GiveClient = 11
}

enum
{
	Default = 0,
	Thorns = 1,
	Alternative = 2,
	Civ_number_2
}

static const char CommandName[][] =
{
	"Command: Defensive",
	"Command: Aggressive",
	"Command: Retreat",
	"Command: Guard Area"
};

/*
	None - 1.0/s
	Repair Handling book for dummies - 1.5/s
	Ikea Repair Handling book - 2.5/s
	Engineering Repair Handling book - 4.5/s
	Alien Repair Handling book - 10.5/s
	Cosmic Repair Handling book - 20.5/s
*/

static const char SummonerBaseNPC[][] =
{
	"npc_barrack_militia",
	
	"npc_barrack_archer",
	"npc_barrack_man_at_arms",
	
	"npc_barrack_crossbow",
	"npc_barrack_swordsman",
	
	"npc_barrack_arbelast",
	"npc_barrack_twohanded",
	
	"npc_barrack_longbow",
	"npc_barrack_champion",
	
	"npc_barrack_monk",
	"npc_barrack_hussar",
	
	"npc_barrack_teutonic_knight",
	"npc_barrack_villager"
};

static int SummonerBase[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level, Supply, Requirement
	{ 0, 5, 30, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None

	{ 0, 50, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },		// Construction Novice
	{ 0, 10, 50, 0, 6, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice

	{ 0, 90, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	{ 0, 20, 90, 0, 7, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Worker

	{ 0, 210, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	{ 0, 50, 210, 0, 8, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert

	{ 0, 400, 100, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert
	{ 0, 100, 400, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master

	{ 0, 210, 50, 50, 12, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0, 100, 400, 35, 15, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master
	
	{ 0, 100, 750, 	15, 10, 16, 1, ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 		750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  }	// Construction Expert
};

static const char SummonerThornsNPC[][] =
{
	"npc_barrack_militia",
	
	"npc_barrack_archer",
	"npc_barrack_man_at_arms",
	
	"npc_barrack_crossbow",
	"npc_barrack_swordsman",
	
	"npc_barrack_arbelast",
	"npc_barrack_twohanded",
	
	"npc_barrack_longbow",
	"npc_barrack_champion",
	
	"npc_barrack_thorns",
	
	"npc_barrack_teutonic_knight",
	"npc_barrack_teutonic_knight",
	"npc_barrack_villager"
};

static int SummonerThorns[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level
	{ 0, 5, 30, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None

	{ 0, 50, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// Construction Novice
	{ 0, 10, 50, 0, 6, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice

	{ 0, 90, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice
	{ 0, 20, 90, 0, 7, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker

	{ 0, 210, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES},	// Construction Worker
	{ 0, 50, 210, 0, 8, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert

	{ 0, 400, 100, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0, 100, 400, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master

	{ 0, 1000, 1000, 50, 50, 11, 2, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert

	{ 0, 100, 750, 	15, 10, 16, 1, ZR_BARRACKS_UPGRADES_CASTLE, ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 9999, 99999, 	9999, 9999, 9999, 9999, 0, 0 },	// Fillter
	{ 0, 		750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0 }	// Construction Expert
};

static const char SummonerAlternativeNPC[][] =
{
	"npc_alt_barrack_basic_mage",
	
	"npc_alt_barrack_mecha_barrager",
	"npc_alt_barrack_intermediate_mage",
	
	"npc_alt_barrack_crossbow",
	"npc_alt_barrack_barrager",
	
	"npc_alt_barrack_railgunner",
	"npc_alt_barrack_holy_knight",
	
	"npc_alt_barrack_berserker",
	"npc_alt_barrack_ikunagae",
	
	"npc_alt_barrack_donnerkrieg",
	"npc_alt_barrack_schwertkrieg",
	
	"npc_alt_barrack_witch",
	"npc_barrack_villager"
};

static int SummonerAlternative[][] =
{
	// NPC Index, 						Wood, 	Food, 	Gold, 	Time, Level, Supply
	{ 0 , 			10, 	40, 	0, 		5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None

	{ 0, 		50, 	10, 	1, 		7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// Construction Novice
	{ 0 ,	10, 	50, 	0, 		6, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice

	{ 0, 		50, 	25, 	2, 		8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice
	{ 0,				75,		50, 	1, 		7, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker

	{ 0 , 			100, 	50, 	2,		11, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	{ 0, 		250, 	100, 	0, 		7, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert

	{ 0, 			50, 	100, 	0,		3, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert	//these ones are meant to be spammed into oblivion
	{ 0 , 			125,	300,	0,		7, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master


	{ 0, 			175, 	350, 	15, 	12, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0 , 		225, 	75, 	10, 	13, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 	1000, 	500, 	35, 	30, 16, 2, ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 				750, 	750, 	0,		25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  }	// Construction Expert
};

static const int BarracksUpgrades[][] =
{
	// Building Upgrade ID, 		Wood, 	Food, 	Gold, 	Time, 	Level,		,Requirement HexArray ,Requirement 									,Requirement 2 HexArray,	Requirement 2						,give hex array		,Give Client
	{ UNIT_COPPER_SMITH , 			50, 	100, 	0, 		10, 	2, 			1,						0,											1,							0,									1,					ZR_UNIT_UPGRADES_COPPER_SMITH					},		// Construction Novice
	{ UNIT_IRON_CASTING, 			100, 	200, 	0, 		10,		4, 			1,						ZR_UNIT_UPGRADES_COPPER_SMITH,				1,							0,									1,					ZR_UNIT_UPGRADES_IRON_CASTING					},		// Construction Apprentice
	{ UNIT_STEEL_CASTING, 			150, 	450, 	0, 		10,		7, 			1,						ZR_UNIT_UPGRADES_IRON_CASTING,				1,							0,									1,					ZR_UNIT_UPGRADES_STEEL_CASTING					},		// Construction Worker
	{ UNIT_REFINED_STEEL, 			250, 	1000, 	0, 		15,		11, 		1,						ZR_UNIT_UPGRADES_STEEL_CASTING,				1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_UNIT_UPGRADES_REFINED_STEEL					},		// Construction Expert

	{ UNIT_FLETCHING , 				70, 	50, 	0, 		10, 	2, 			1,						0,											1,							0,									1,					ZR_UNIT_UPGRADES_FLETCHING						},		// Construction Novice
	{ UNIT_STEEL_ARROWS, 			100, 	100, 	0, 		10,		4, 			1,						ZR_UNIT_UPGRADES_FLETCHING,					1,							0,									1,					ZR_UNIT_UPGRADES_STEEL_ARROWS					},		// Construction Apprentice
	{ UNIT_BRACER, 					250, 	150, 	0, 		10,		7, 			1,						ZR_UNIT_UPGRADES_STEEL_ARROWS,				1,							0,									1,					ZR_UNIT_UPGRADES_BRACER							},		// Construction Worker
	{ UNIT_OBSIDIAN_REFINED_TIPS, 	400, 	250, 	0, 		15,		11, 		1,						ZR_UNIT_UPGRADES_BRACER,					1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_UNIT_UPGRADES_OBSIDIAN_REFINED_TIPS			},		// Construction Expert

	{ UNIT_COPPER_ARMOR_PLATE , 	50, 	50, 	0, 		10, 	2, 			1,						0,											1,							0,									1,					ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR				},		// Construction Novice
	{ UNIT_IRON_ARMOR_PLATE, 		100, 	200, 	0, 		10,		4, 			1,						ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR,		1,							0,									1,					ZR_UNIT_UPGRADES_IRON_PLATE_ARMOR				},		// Construction Apprentice
	{ UNIT_CHAINMAIL_ARMOR, 		200, 	450, 	0, 		10,		7, 			1,						ZR_UNIT_UPGRADES_IRON_PLATE_ARMOR,			1,							0,									1,					ZR_UNIT_UPGRADES_CHAINMAIL_ARMOR				},		// Construction Worker
	{ UNIT_REFORGED_ARMOR_PLATE, 	250, 	2000, 	0, 		15,		11, 		1,						ZR_UNIT_UPGRADES_CHAINMAIL_ARMOR,			1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_UNIT_UPGRADES_REFORGED_STEEL_ARMOR			},		// Construction Expert

	{ UNIT_HERBAL_MEDICINE , 		200, 	300, 	0, 		15, 	2, 			1,						0,											1,							0,									1,					ZR_UNIT_UPGRADES_HERBAL_MEDICINE				},		// Construction Novice
	{ UNIT_REFINED_MEDICINE, 		300, 	1000, 	0, 		20,		4, 			1,						ZR_UNIT_UPGRADES_HERBAL_MEDICINE,			1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_UNIT_UPGRADES_REFINED_MEDICINE				},		// Construction Apprentice

	//tower specific upgrades						1,
	{ BUILDING_TOWER, 				50, 	10, 	0, 		10, 	2, 			1,						0,											1,							0,									1,					ZR_BARRACKS_UPGRADES_TOWER						},		// Construction Novice
	{ BUILDING_GUARD_TOWER, 		150, 	25, 	0, 		15,		4, 			1,						ZR_BARRACKS_UPGRADES_TOWER,					1,							0,									1,					ZR_BARRACKS_UPGRADES_GUARD_TOWER				},		// Construction Apprentice
	{ BUILDING_IMPERIAL_TOWER, 		250, 	50, 	0, 		20,		4, 			1,						ZR_BARRACKS_UPGRADES_GUARD_TOWER,			1,							0,									1,					ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER				},		// Construction Worker
	{ BUILDING_BALLISTICAL_TOWER, 	500, 	100, 	0, 		25,		7, 			1,						ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER,		1,							0,									1,					ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER			},		// Construction Expert
	{ BUILDING_DONJON, 				1000, 	200, 	0, 		30,		7, 			1,						ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER,		1,							0,									1,					ZR_BARRACKS_UPGRADES_DONJON						},		// Construction Expert
	{ BUILDING_KREPOST, 			1000, 	1000, 	0, 		35,		11, 		1,						ZR_BARRACKS_UPGRADES_DONJON,				1,							0,									1,					ZR_BARRACKS_UPGRADES_KREPOST					},		// Construction Expert
	{ BUILDING_CASTLE, 				3000, 	3500, 	0, 		50,		16, 		1,						ZR_BARRACKS_UPGRADES_KREPOST,				1,							0,									1,					ZR_BARRACKS_UPGRADES_CASTLE						},		// Construction Expert

//unused for now, too lazy aa
	{ BUILDING_MANUAL_FIRE , 		10, 	40, 	0, 		5, 		9999,/*2,*/ 1,						ZR_BARRACKS_UPGRADES_TOWER,					1,							0,									1,					ZR_BARRACKS_UPGRADES_MANUAL_FIRE				},		// Construction Novice

	{ BUILDING_MUDERHOLES , 		20, 	500, 	0, 		10, 	2, 			1,						0,											1,							ZR_BARRACKS_UPGRADES_TOWER,			1,					ZR_BARRACKS_UPGRADES_MURDERHOLES				},		// Construction Novice
	{ BUILDING_BALLISTICS, 			500, 	200, 	0, 		15,		4, 			1,						ZR_BARRACKS_UPGRADES_MURDERHOLES,			1,							ZR_BARRACKS_UPGRADES_TOWER,			1,					ZR_BARRACKS_UPGRADES_BALLISTICS					},		// Construction Apprentice
	{ BUILDING_CHEMISTRY, 			750, 	200, 	0, 		20,		7, 			1,						ZR_BARRACKS_UPGRADES_BALLISTICS,			1,							ZR_BARRACKS_UPGRADES_TOWER,			1,					ZR_BARRACKS_UPGRADES_CHEMISTY					},		// Construction Worker
	{ BUILDING_CRENELATIONS, 		1000, 	300, 	0, 		40,		11, 		1,						ZR_BARRACKS_UPGRADES_CHEMISTY,				1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_BARRACKS_UPGRADES_CRENELLATIONS				},		// Construction Expert

	{ BUILDING_CONSCRIPTION , 		1000, 	400, 	0, 		30, 	2, 			1,						0,											1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_BARRACKS_UPGRADES_CONSCRIPTION				},		// Construction Novice
	{ BUILDING_GOLDMINERS, 			500, 	500, 	10, 	40,		4, 			1,						ZR_BARRACKS_UPGRADES_CONSCRIPTION,			1,							/*Gold crown?*/0,					1,					ZR_BARRACKS_UPGRADES_GOLDMINERS					},		// Construction Apprentice

	{ BUILDING_ASSISTANT_VILLAGER, 	1200, 	1200, 	0, 		60,		11, 		1,						0,											1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER			},		// Construction Worker
	{ BUILDING_VILLAGER_EDUCATION, 	2000, 	3000, 	0, 		70,		11, 		1,						ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,		1,							ZR_BARRACKS_UPGRADES_CASTLE,		1,					ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER_EDUCATION	},		// Construction Expert

	{ BUILDING_STRONGHOLDS, 		1500, 	2500, 	0, 		30,		7, 			1,						0,											1,							ZR_BARRACKS_UPGRADES_DONJON,		1,					ZR_BARRACKS_UPGRADES_STRONGHOLDS				},		// Construction Worker
	{ BUILDING_HOARDINGS, 			1500, 	3000, 	0, 		50,		11, 		1,						ZR_BARRACKS_UPGRADES_STRONGHOLDS,			1,							ZR_BARRACKS_UPGRADES_KREPOST,		2,					ZR_BARRACKS_UPGRADES_HOARDINGS					},		// Construction Expert
	{ BUILDING_EXQUISITE_HOUSING, 	3000, 	5000, 	10, 	70,		16, 		2,						ZR_BARRACKS_UPGRADES_HOARDINGS,				1,							ZR_BARRACKS_UPGRADES_CASTLE,		2,					ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING			},		// Construction Expert
	{ BUILDING_TROOP_CLASSES, 		10, 	10, 	0, 		5,		0, 			1,						0,											1,							0,									2,					ZR_BARRACKS_TROOP_CLASSES						},		// Construction Expert
};					

static const char CivName[][] =		
{		
	"Standard Barracks",
	"Iberia Barracks",
	"Blitzkrieg's Army"
};

static void SetupNPCIndexes()
{
	for(int i; i < sizeof(SummonerBase); i++)
	{
		SummonerBase[i][NPCIndex] = NPC_GetByPlugin(SummonerBaseNPC[i]);
	}

	for(int i; i < sizeof(SummonerThorns); i++)
	{
		SummonerThorns[i][NPCIndex] = NPC_GetByPlugin(SummonerThornsNPC[i]);
	}
	
	for(int i; i < sizeof(SummonerAlternative); i++)
	{
		SummonerAlternative[i][NPCIndex] = NPC_GetByPlugin(SummonerAlternativeNPC[i]);
	}
}

static int GetUnitCount(int civ)
{
	switch(civ)
	{
		case Thorns:
			return sizeof(SummonerThorns);
			
		case Alternative:
			return sizeof(SummonerAlternative);
		
		default:
			return sizeof(SummonerBase);
	}
}

static int GetSData(int civ, int unit, int index)
{
	switch(civ)
	{
		case Thorns:
			return SummonerThorns[unit][index];
			
		case Alternative:
			return SummonerAlternative[unit][index];
		
		default:
			return SummonerBase[unit][index];
	}
}

static int GetResearchCount()
{
	return sizeof(BarracksUpgrades);
}

static int GetRData(int type, int index)
{
	return BarracksUpgrades[type][index];
}

public Action Building_PlaceSummoner(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Summoner, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public bool Building_Summoner(int client, int entity)
{
	SetupNPCIndexes();
	SetDefaultValuesToZeroNPC(entity);
	b_BuildingHasDied[entity] = false;
	b_CantCollidieAlly[entity] = true;
	i_IsABuilding[entity] = true;
	b_NoKnockbackFromSources[entity] = true;
	b_NpcHasDied[entity] = true;
	BarracksCheckItems(client);
	WoodAmount[client] *= 0.75;
	FoodAmount[client] *= 0.75;
	GoldAmount[client] *= 0.75;
	if(CvarInfiniteCash.BoolValue)
	{
		WoodAmount[client] = 999999.0;
		FoodAmount[client] = 999999.0;
		GoldAmount[client] = 99999.0;
	}
	TrainingIn[client] = 0.0;
	ResearchIn[client] = 0.0;
	CommandMode[client] = 0;
	TrainingQueue[client] = -1;
	CivType[client] = Store_HasNamedItem(client, "Iberia's Last Hope") ? Thorns : Default;

	if(CivType[client] == Default)
		CivType[client] = Store_HasNamedItem(client, "Blitzkrieg's Army") ? Alternative : Default;
	
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	DataPack pack;
	CreateDataTimer(0.21, Timer_SummonerThink, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	i_WhatBuilding[entity] = BuildingSummoner;
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 612); //512 is max shown, then + 100 to have a nice number, abuse overflow :)

	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.15);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_summoner");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	
	if(!CvarInfiniteCash.BoolValue)
		Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
		
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	Building_Collect_Cooldown[entity][0] = 0.0;
	SDKHook(client, SDKHook_PreThink, Barracks_BuildingThink);			
	int SentryHealAmountExtra = GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2;
	SetVariantInt(SentryHealAmountExtra);
	AcceptEntityInput(entity, "AddHealth");
	return true;
}

int Building_GetFollowerEntity(int owner)
{
	if(Building_Mounted[owner] != i_HasSentryGunAlive[owner])
	{
		int entity = EntRefToEntIndex(i_HasSentryGunAlive[owner]);
		if(entity != INVALID_ENT_REFERENCE)
			return entity;
	}
	return owner;
}

int Building_GetFollowerCommand(int owner)
{
	return CommandMode[owner];
}

public Action Timer_SummonerThink(Handle timer, DataPack pack)
{
	bool mounted;
	int owner;
	pack.Reset();
	int ref = pack.ReadCell();
	int entity = EntRefToEntIndex(ref);
	int original_entity = pack.ReadCell(); //Need original!
	if(!IsValidEntity(entity))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[original_entity][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		return Plugin_Stop;
	}
	if(entity != INVALID_ENT_REFERENCE)
	{
		owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(owner < 1 || owner > MaxClients)
		{
			SDKHooks_TakeDamage(entity, entity, entity, 999999.9);
			entity = INVALID_ENT_REFERENCE;
			owner = 0;
		}
		else if(Building_Mounted[owner] == ref)
		{
			mounted = true;
		}
		else if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") >= 1.0)
		{
			if(Building_Constructed[entity])
			{
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
			}
			if(!Building_Constructed[entity])
			{
				//BELOW IS SET ONCE!
				view_as<CClotBody>(entity).bBuildingIsPlaced = true;
				Building_Constructed[entity] = true;
				/*
				if((i_NormalBarracks_HexBarracksUpgrades[owner] & ZR_BARRACKS_UPGRADES_TOWER))
				{
					SetEntityModel(entity, "models/props_manor/clocktower_01.mdl");
					SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.11);
				}
				else
				{
				*/
		//		SetEntityModel(entity, SUMMONER_MODEL);
		//		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.15);
				//}
				
				static const float minbounds[3] = {-20.0, -20.0, 0.0};
				static const float maxbounds[3] = {20.0, 20.0, 30.0};
				SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

				view_as<CClotBody>(entity).UpdateCollisionBox();	
				Barracks_UpdateEntityUpgrades(entity, owner, true);		
			}
		}
		else
		{
			SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
			int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
			
			if(IsValidEntity(prop1))
			{
				RemoveEntity(prop1);
			}
			if(IsValidEntity(prop2))
			{
				RemoveEntity(prop2);
			}
			Building_Constructed[entity] = false;
		}
	}
	
	if(entity != INVALID_ENT_REFERENCE && owner && Building_Constructed[entity])
	{
		SummonerRenerateResources(owner, 1.0);

		if(TrainingIn[owner])
		{
			bool OwnsVillager = false;
			bool HasupgradeVillager = false;
			char npc_classname[60];
			if(GetSData(CivType[owner], TrainingIndex[owner], NPCIndex) == BarrackVillager_ID())
			{
				if(i_NormalBarracks_HexBarracksUpgrades[owner] & ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER)
				{
					HasupgradeVillager = true;
					if(BarrackVillager_ID() == GetSData(CivType[owner], TrainingIndex[owner], NPCIndex))
					{
						for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
						{
							int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);

							if(IsValidEntity(entity_close))
							{
								NPC_GetPluginById(i_NpcInternalId[entity_close], npc_classname, sizeof(npc_classname));
								if(StrEqual(npc_classname, "npc_barrack_villager"))
								{
									BarrackBody npc = view_as<BarrackBody>(entity_close);
									if(GetClientOfUserId(npc.OwnerUserId) == owner)
									{
										OwnsVillager = true;
										break;
									}
								}
							}
						}
					}
				}
			}
			int subtractVillager = 0;
			if(!OwnsVillager && HasupgradeVillager)
			{
				subtractVillager = 1;
			}
			if((/*(!AtMaxSupply(owner) &&*/ GetSupplyLeft(owner) + subtractVillager) >= GetSData(CivType[owner], TrainingIndex[owner], SupplyCost))
			{
				float gameTime = GetGameTime();
				if(TrainingIn[owner] < gameTime)
				{
					static float VecStuckCheck[3];

					int entity_to_heck_from;

					if(mounted)
					{
						entity_to_heck_from = owner;
					}
					else
					{
						entity_to_heck_from = entity;
					}

					GetEntPropVector(entity_to_heck_from, Prop_Data, "m_vecAbsOrigin", VecStuckCheck);
					
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		

					if (!IsSpaceOccupiedRTSBuilding(VecStuckCheck, hullcheckmins, hullcheckmaxs, entity_to_heck_from))
					{
						SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 0);
						TrainingIn[owner] = 0.0;

						float pos[3], ang[3];
						GetEntPropVector(mounted ? owner : entity, Prop_Data, "m_vecAbsOrigin", pos);
						GetEntPropVector(mounted ? owner : entity, Prop_Data, "m_angRotation", ang);
						
						view_as<BarrackBody>(mounted ? owner : entity).PlaySpawnSound();
						int npc = NPC_CreateById(GetSData(CivType[owner], TrainingIndex[owner], NPCIndex), owner, pos, ang, TFTeam_Red);
						view_as<BarrackBody>(npc).m_iSupplyCount = GetSData(CivType[owner], TrainingIndex[owner], SupplyCost);
						Barracks_UpdateEntityUpgrades(owner, npc, true, true); //make sure upgrades if spawned, happen on full health!


						if(TrainingQueue[owner] != -1)
						{
							TrainingIndex[owner] = TrainingQueue[owner];
							TrainingStartedIn[owner] = GetGameTime();
							float trainingTime = float(GetSData(CivType[owner], TrainingQueue[owner], TrainTime));
							if(i_NormalBarracks_HexBarracksUpgrades[owner] & ZR_BARRACKS_UPGRADES_CONSCRIPTION)
							{
								trainingTime *= 0.75;
							}
							if(CvarInfiniteCash.BoolValue)
							{
								trainingTime = 0.0;
							}
							TrainingIn[owner] = TrainingStartedIn[owner] + trainingTime;
							TrainingQueue[owner] = -1;
						}
					}
					else
					{
						TrainingIn[owner] = gameTime + 0.1;
						TrainingStartedIn[owner] = -1.0;
					}
				}
				/*
				else
				{
					int required = RoundFloat((TrainingIn[owner] - TrainingStartedIn[owner]) * 2.0);
					int current = required - RoundToCeil((TrainingIn[owner] - gameTime) * 2.0);
					
				//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", current);
				//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", required);
				}
				*/
			}
		}

		if(ResearchIn[owner])
		{
			float gameTime = GetGameTime();
			if(ResearchIn[owner] < gameTime)
			{
				ResearchIn[owner] = 0.0;

				int Get_GiveHexArray;
				int Get_GiveClient;
			//	GetRData(ResearchIndex[owner], UpgradeIndex);
				Get_GiveHexArray = GetRData(ResearchIndex[owner], GiveHexArray);
				Get_GiveClient = GetRData(ResearchIndex[owner], GiveClient);
				
				if(Get_GiveHexArray == 1)
				{
					i_NormalBarracks_HexBarracksUpgrades[owner] |= Get_GiveClient;
					Store_SetNamedItem(owner, "Barracks Hex Upgrade 1", i_NormalBarracks_HexBarracksUpgrades[owner]);
				}
				else if(Get_GiveHexArray == 2)
				{
					i_NormalBarracks_HexBarracksUpgrades_2[owner] |= Get_GiveClient;
					Store_SetNamedItem(owner, "Barracks Hex Upgrade 2", i_NormalBarracks_HexBarracksUpgrades_2[owner]);
				}
				Barracks_UpdateAllEntityUpgrades(owner);
			}
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(InMenu[i] == owner)
				SummonerMenu(owner, i);
		}
	}

	return entity == INVALID_ENT_REFERENCE ? Plugin_Stop : Plugin_Continue;
}

void BarracksSaveResources(int client)
{
	Store_SetNamedItem(client, "Barracks Wood", RoundToCeil(WoodAmount[client]));
	Store_SetNamedItem(client, "Barracks Food", RoundToCeil(FoodAmount[client]));
	Store_SetNamedItem(client, "Barracks Gold", RoundToCeil(GoldAmount[client]));
}

void CheckSummonerUpgrades(int client)
{
	SupplyRate[client] = 2;

	if(Store_HasNamedItem(client, "Construction Novice"))
		SupplyRate[client]++;
	
	if(Store_HasNamedItem(client, "Construction Apprentice"))
		SupplyRate[client] += 2;
	
	if(Store_HasNamedItem(client, "Engineering Repair Handling book"))
		SupplyRate[client] += 4;
	
	if(Store_HasNamedItem(client, "Alien Repair Handling book"))
		SupplyRate[client] += 6;
	
	if(Store_HasNamedItem(client, "Cosmic Repair Handling book"))
		SupplyRate[client] += 10;
	
	FinalBuilder[client] = view_as<bool>(Store_HasNamedItem(client, "Construction Killer"));
	MedievalUnlock[client] = (CivType[client] || Items_HasNamedItem(client, "Medieval Crown"));
	GlassBuilder[client] = view_as<bool>(Store_HasNamedItem(client, "Glass Cannon Blueprints"));
}

void SummonerRenerateResources(int client, float multi, bool allowgold = false)
{
	// 1 Supply = 1 Food Every 2 Seconds, 1 Wood Every 4 Seconds
	
	if(!Waves_InSetup())
	{
		float SupplyRateCalc = SupplyRate[client] / (LastMann ? 10.0 : 20.0);

		if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CONSCRIPTION)
		{
			SupplyRateCalc *= 1.25;
		}
		if(i_CurrentEquippedPerk[client] == 7)
		{
			SupplyRateCalc *= 1.15;
		}
		if(Rogue_Mode())
		{
			SupplyRateCalc *= 5.0;
		}
		SupplyRateCalc *= multi;

		WoodAmount[client] += SupplyRateCalc * 1.15;
		FoodAmount[client] += SupplyRateCalc * 1.40;

		if(MedievalUnlock[client] || allowgold)
		{
			float GoldSupplyRate = SupplyRate[client] / 1500.0;
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_GOLDMINERS)
			{
				GoldSupplyRate *= 1.25;
			}
			if(i_CurrentEquippedPerk[client] == 7)
			{
				GoldSupplyRate *= 1.25;
			}
			GoldSupplyRate *= multi;
			GoldAmount[client] += GoldSupplyRate;
		}

	}
	if(f_VillageSavingResources[client] < GetGameTime())
	{
		f_VillageSavingResources[client] = GetGameTime() + 0.25;
		BarracksSaveResources(client);
	}
}

static void OpenSummonerMenu(int client, int viewer)
{
	if(client == viewer)
		CheckSummonerUpgrades(client);
	
	SummonerMenu(client, viewer);
}

static void SummonerMenu(int client, int viewer)
{
	int entity = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(entity == INVALID_ENT_REFERENCE)
	{
		CancelClientMenu(viewer);
		return;
	}

	bool owner = client == viewer;
	bool alive = (owner && IsPlayerAlive(client) && !TeutonType[client]);
	int level = MaxSupportBuildingsAllowed(client, true);
	int itemsAddedToList = 0;
	
	Menu menu = new Menu(SummonerMenuH);
	CancelClientMenu(viewer);
	SetStoreMenuLogic(viewer, false);

	SetGlobalTransTarget(viewer);
	if(!(GetEntityFlags(viewer) & FL_DUCKING))
	{
		menu.SetTitle("%s\n%t\n \n$%d £%d ¥%d\n ", CivName[CivType[client]], "Crouch To See Info Barracks", RoundToFloor(WoodAmount[client]), RoundToFloor(FoodAmount[client]), RoundToFloor(GoldAmount[client]));
	}
	else
	{
		menu.SetTitle("%s\n\n \n$%d £%d ¥%d\n ", CivName[CivType[client]], RoundToFloor(WoodAmount[client]), RoundToFloor(FoodAmount[client]), RoundToFloor(GoldAmount[client]));	
	}

	char buffer1[256];
	char buffer2[64];
	int options;
	int options_unitMax = 3;
	
	if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CASTLE)
	{
		options_unitMax += 1;
	}
	if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER)
	{
		options_unitMax += 1;
	}
	if(b_InUpgradeMenu[viewer])
	{
		itemsAddedToList = 2;

		if(ResearchIn[client])
		{
			float gameTime = GetGameTime();
			FormatEx(buffer1, sizeof(buffer1), "Researching %t... (%.0f%%)", BuildingUpgrade_Names[GetRData(ResearchIndex[client], UpgradeIndex)],
				100.0 - ((ResearchIn[client] - gameTime) * 100.0 / (ResearchIn[client] - ResearchStartedIn[client])));
			
			menu.AddItem(buffer1, buffer1, owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			menu.AddItem(buffer1, "Cancel Research\n ", owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		else
		{
			menu.AddItem(buffer1, "\n ", owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			menu.AddItem(buffer1, "\n ", owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		
		int limit = GetResearchCount();
		for(int i; i < limit; i++)
		{
			if(GetRData(i, TrainLevel) > level)
				continue;

			int Get_GiveHexArray = GetRData(i, GiveHexArray);
			int Get_GiveClient = GetRData(i, GiveClient);

			//check if we already down the upgrade!
			if(Get_GiveHexArray == 1)
			{
				if(i_NormalBarracks_HexBarracksUpgrades[client] & Get_GiveClient)
				{
					continue;
				}
			}
			else if(Get_GiveHexArray == 2)
			{
				if(i_NormalBarracks_HexBarracksUpgrades_2[client] & Get_GiveClient)
				{
					continue;
				}
			}

			int Get_RequirementHexArray;
			int Get_Requirement;
			int Get_RequirementHexArray_2;
			int Get_Requirement_2;

			Get_RequirementHexArray = GetRData(i, RequirementHexArray);
			Get_Requirement = GetRData(i, Requirement);
			Get_RequirementHexArray_2 = GetRData(i, Requirement2HexArray);
			Get_Requirement_2 = GetRData(i, Requirement2);
			bool poor;
			
			if(ResearchIn[client])
			{
				poor = true;
			}
			/*
			PrintToServer("Name: %t", BuildingUpgrade_Names[GetRData(i, UpgradeIndex)]);
			PrintToServer("Get_RequirementHexArray %i", Get_RequirementHexArray);
			PrintToServer("Get_Requirement %i", Get_Requirement);
			PrintToServer("Get_RequirementHexArray2 %i", Get_RequirementHexArray);
			PrintToServer("Get_Requirement2 %i", Get_Requirement_2);

			PrintToServer("i_NormalBarracks_HexBarracksUpgrades[client] %i", i_NormalBarracks_HexBarracksUpgrades[client]);
			PrintToServer("i_NormalBarracks_HexBarracksUpgrades_2[client] %i", i_NormalBarracks_HexBarracksUpgrades_2[client]);
			*/
			if(Get_RequirementHexArray > 0 && Get_Requirement > 0)
			{
				if(Get_RequirementHexArray == 1)
				{
					if(i_NormalBarracks_HexBarracksUpgrades[client] == 0) //whatever requirement exists, they do not match it.
					{
						continue;
					}
					if(!(i_NormalBarracks_HexBarracksUpgrades[client] & Get_Requirement))
					{
						continue;
					}
				}
				else
				{
					if(i_NormalBarracks_HexBarracksUpgrades_2[client] == 0) //whatever requirement exists, they do not match it.
					{
						continue;
					}
					if(!(i_NormalBarracks_HexBarracksUpgrades_2[client] & Get_Requirement))
					{
						continue;
					}					
				}
			}
			
			if(Get_RequirementHexArray_2 > 0 && Get_Requirement_2 > 0)
			{
				if(Get_RequirementHexArray_2 == 1)
				{
					if(i_NormalBarracks_HexBarracksUpgrades[client] == 0) //whatever requirement exists, they do not match it.
					{
						continue;
					}
					if(!(i_NormalBarracks_HexBarracksUpgrades[client] & Get_Requirement_2))
					{
						continue;
					}
				}
				else
				{
					if(i_NormalBarracks_HexBarracksUpgrades_2[client] == 0) //whatever requirement exists, they do not match it.
					{
						continue;
					}
					if(!(i_NormalBarracks_HexBarracksUpgrades_2[client] & Get_Requirement_2))
					{
						continue;
					}					
				}
			}
			
			bool ShowingDesc = false;
			if(GetEntityFlags(viewer) & FL_DUCKING)
			{
				ShowingDesc = true;
				FormatEx(buffer2, sizeof(buffer2), "%s Desc", BuildingUpgrade_Names[GetRData(i, UpgradeIndex)]);
			}
			else
			{
				FormatEx(buffer1, sizeof(buffer1), "%t [", BuildingUpgrade_Names[GetRData(i, UpgradeIndex)]);
			}

			if(!ShowingDesc)
			{
				if(GetRData(i, WoodCost))
					Format(buffer1, sizeof(buffer1), "%s $%d", buffer1, GetRData(i, WoodCost));
				
				if(GetRData(i, FoodCost))
					Format(buffer1, sizeof(buffer1), "%s £%d", buffer1, GetRData(i, FoodCost));
				
				if(GetRData(i, GoldCost))
					Format(buffer1, sizeof(buffer1), "%s ¥%d", buffer1, GetRData(i, GoldCost));
				
				Format(buffer1, sizeof(buffer1), "%s ]\n", buffer1);
			}
			else
			{
				Format(buffer1, sizeof(buffer1), "%t\n", buffer2);
			}

			IntToString(i, buffer2, sizeof(buffer2));
			if(!poor)
			{
				poor = (!alive ||
					WoodAmount[client] < GetRData(i, WoodCost) ||
					FoodAmount[client] < GetRData(i, FoodCost) ||
					GoldAmount[client] < GetRData(i, GoldCost));
					
			}

			itemsAddedToList++;
			menu.AddItem(buffer2, buffer1, poor ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			if(++options >= 6)
				break;
		}

	}
	else
	{
		itemsAddedToList += 1;
		menu.AddItem(NULL_STRING, CommandName[CommandMode[client]], owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		if(TrainingIn[client])
		{
			bool OwnsVillager = false;
			bool HasupgradeVillager = false;
			char npc_classname[60];
			if(GetSData(CivType[client], TrainingIndex[client], NPCIndex) == BarrackVillager_ID())
			{
				if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER)
				{
					HasupgradeVillager = true;
					if(BarrackVillager_ID() == GetSData(CivType[client], TrainingIndex[client], NPCIndex))
					{
						for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
						{
							int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);

							if(IsValidEntity(entity_close))
							{
								NPC_GetPluginById(i_NpcInternalId[entity_close], npc_classname, sizeof(npc_classname));
								if(StrEqual(npc_classname, "npc_barrack_villager"))
								{
									BarrackBody npc = view_as<BarrackBody>(entity_close);
									if(GetClientOfUserId(npc.OwnerUserId) == client)
									{
										OwnsVillager = true;
										break;
									}
								}
							}
						}
					}
				}
			}
			int subtractVillager = 0;
			if(!OwnsVillager && HasupgradeVillager)
			{
				subtractVillager = 1;
			}
			if(/*(AtMaxSupply(client) - subtractVillager) || */(GetSupplyLeft(client) + subtractVillager) < GetSData(CivType[client], TrainingIndex[client], SupplyCost))
			{
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (At Maximum Supply)\n ", GetNPCName(GetSData(CivType[client], TrainingIndex[client], NPCIndex)));
				if(i_BarricadesBuild[client])
					Format(buffer1, sizeof(buffer1), "%s\nTIP: Your barricades counts towards the supply limit\n ", buffer1);
			}
			else if(TrainingStartedIn[client] < 0.0)
			{
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (Spaced Occupied)\n ", GetNPCName(GetSData(CivType[client], TrainingIndex[client], NPCIndex)));
			}
			else
			{
				float gameTime = GetGameTime();
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (%.0f%%)\n ", GetNPCName(GetSData(CivType[client], TrainingIndex[client], NPCIndex)),
					100.0 - ((TrainingIn[client] - gameTime) * 100.0 / (TrainingIn[client] - TrainingStartedIn[client])));
			}

			if(TrainingQueue[client] != -1)
				Format(buffer1, sizeof(buffer1), "%sNext: %t\n ", buffer1, GetNPCName(GetSData(CivType[client], TrainingQueue[client], NPCIndex)));
			
			itemsAddedToList += 1;
			menu.AddItem(buffer1, buffer1, owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		else
		{
			itemsAddedToList += 1;
			menu.AddItem(buffer1, "\n ", owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
		
		for(int i = GetUnitCount(CivType[client]) - 1; i >= 0; i--)
		{
			if(GetSData(CivType[client], i, TrainLevel) > level)
				continue;

			bool poor;


			int ResearchRequirement_internal = GetSData(CivType[client], i, ResearchRequirement);
			if(ResearchRequirement_internal > 0)
			{
				if(!(i_NormalBarracks_HexBarracksUpgrades[client] & ResearchRequirement_internal))
				{
					continue;
				}
			}

			int ResearchRequirement_internal_2 = GetSData(CivType[client], i, ResearchRequirement2);
			if(ResearchRequirement_internal_2 > 0)
			{
				if(!(i_NormalBarracks_HexBarracksUpgrades_2[client] & ResearchRequirement_internal_2))
				{
					continue;
				}
			}

			if(ResearchRequirement_internal & ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER)
			{
				if(BarrackVillager_ID() == GetSData(CivType[client], TrainingIndex[client], NPCIndex) && TrainingIn[client] >= GetGameTime())
				{
					//dont train more then one at a time
					poor = true;
				}
				else
				{
					char npc_classname[60];
					for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
					{
						int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);

						if(IsValidEntity(entity_close))
						{
							NPC_GetPluginById(i_NpcInternalId[entity_close], npc_classname, sizeof(npc_classname));
							if(StrEqual(npc_classname, "npc_barrack_villager"))
							{
								BarrackBody npc = view_as<BarrackBody>(entity_close);
								if(GetClientOfUserId(npc.OwnerUserId) == client)
								{
									poor = true;
									break;
								}
							}
						}
					}					
				}
			}

			bool ShowingDesc = false;
			if(GetEntityFlags(viewer) & FL_DUCKING)
			{
				ShowingDesc = true;
				FormatEx(buffer2, sizeof(buffer2), "%s Desc",GetNPCName(GetSData(CivType[client], i, NPCIndex)));
			}
			else
			{
				FormatEx(buffer1, sizeof(buffer1), "%t [", GetNPCName(GetSData(CivType[client], i, NPCIndex)));
			}
			if(!ShowingDesc)
			{
				if(GetSData(CivType[client], i, WoodCost))
					Format(buffer1, sizeof(buffer1), "%s $%d", buffer1, GetSData(CivType[client], i, WoodCost));
				
				if(GetSData(CivType[client], i, FoodCost))
					Format(buffer1, sizeof(buffer1), "%s £%d", buffer1, GetSData(CivType[client], i, FoodCost));
				
				if(GetSData(CivType[client], i, GoldCost))
					Format(buffer1, sizeof(buffer1), "%s ¥%d", buffer1, GetSData(CivType[client], i, GoldCost));
				
				Format(buffer1, sizeof(buffer1), "%s ]\n", buffer1);
			}
			else
			{
				Format(buffer1, sizeof(buffer1), "%t\n", buffer2);
			}

			IntToString(i, buffer2, sizeof(buffer2));
			if(!poor)
			{
				poor = (!alive ||
					WoodAmount[client] < GetSData(CivType[client], i, WoodCost) ||
					FoodAmount[client] < GetSData(CivType[client], i, FoodCost) ||
					GoldAmount[client] < GetSData(CivType[client], i, GoldCost));
			}

			itemsAddedToList += 1;
			menu.AddItem(buffer2, buffer1, poor ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);


			if(++options > options_unitMax)
				break;
		}
		if(options <= 0)
		{
			IntToString(0, buffer2, sizeof(buffer2));
			Format(buffer1, sizeof(buffer1), "%t", "Research Troop Classes");
			itemsAddedToList += 1;
			menu.AddItem(buffer2, buffer1, ITEMDRAW_DISABLED);
		}
	}

	Format(buffer1, sizeof(buffer1), "%t", "Toggle Upgrade Menu Barracks");
	
	itemsAddedToList += 1;
	for(int loops = 0; loops < 10; loops ++)
	{
		if(itemsAddedToList < 9)
		{
			itemsAddedToList += 1;
			menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
		}
		else
		{
			break;
		}
	}

	//should always be at 9
	menu.AddItem("50", buffer1, ITEMDRAW_DEFAULT);

	menu.Pagination = 0;
	menu.ExitButton = true;
	if(menu.Display(viewer, 1))
		InMenu[viewer] = client;
}

static char[] GetNPCName(int id)
{
	NPCData data;
	NPC_GetById(id, data);
	return data.Name;
}

//void AddItemToTrainingList(char item, )
public int SummonerMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
			InMenu[client] = 0;
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			if(choice)
			{
				char buffer[16];
				menu.GetItem(choice, buffer, sizeof(buffer));
				int id = StringToInt(buffer);
				if(id == 50)
				{
					if(b_InUpgradeMenu[client])
					{
						b_InUpgradeMenu[client] = false;
					}
					else
					{
						b_InUpgradeMenu[client] = true;
					}
					
					SummonerMenu(client, client);
					return 0;
				}

				int entity = EntRefToEntIndex(i_HasSentryGunAlive[client]);
				if(entity != INVALID_ENT_REFERENCE)
				{
					if(choice == 1)
					{
						if(b_InUpgradeMenu[client])
						{
							if(ResearchIn[client])
							{
								ResearchIn[client] = 0.0;

								WoodAmount[client] += float(GetRData(ResearchIndex[client], WoodCost));
								FoodAmount[client] += float(GetRData(ResearchIndex[client], FoodCost));
								GoldAmount[client] += float(GetRData(ResearchIndex[client], GoldCost));
							}
						}
						else if(TrainingQueue[client] != -1)
						{
							WoodAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], WoodCost));
							FoodAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], FoodCost));
							GoldAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], GoldCost));

							TrainingQueue[client] = -1;
						}
						else if(TrainingIn[client])
						{
							TrainingIn[client] = 0.0;

							WoodAmount[client] += float(GetSData(CivType[client], TrainingIndex[client], WoodCost));
							FoodAmount[client] += float(GetSData(CivType[client], TrainingIndex[client], FoodCost));
							GoldAmount[client] += float(GetSData(CivType[client], TrainingIndex[client], GoldCost));
						}
						BarracksSaveResources(client);
					}
					else if(b_InUpgradeMenu[client])
					{
						char num[16];
						menu.GetItem(choice, num, sizeof(num));
						int item = StringToInt(num);

						float woodcost = float(GetRData(item, WoodCost));
						float foodcost = float(GetRData(item, FoodCost));
						float goldcost = float(GetRData(item, GoldCost));

						if(WoodAmount[client] >= woodcost && FoodAmount[client] >= foodcost && GoldAmount[client] >= goldcost)
						{
							if(ResearchIn[client])
							{
								WoodAmount[client] += float(GetRData(TrainingQueue[client], WoodCost));
								FoodAmount[client] += float(GetRData(TrainingQueue[client], FoodCost));
								GoldAmount[client] += float(GetRData(TrainingQueue[client], GoldCost));
							}

							ResearchIndex[client] = item;
							ResearchStartedIn[client] = GetGameTime();
							
							float TimeUntillResearch = float(GetRData(item, TrainTime));
							if(Rogue_Mode())
							{
								TimeUntillResearch *= 0.5;
							}
							ResearchIn[client] = ResearchStartedIn[client] + TimeUntillResearch;
							if(CvarInfiniteCash.BoolValue)
							{
								ResearchIn[client] = GetGameTime() + 0.1; 
							}
							
							WoodAmount[client] -= woodcost;
							FoodAmount[client] -= foodcost;
							GoldAmount[client] -= goldcost;
							BarracksSaveResources(client);
						}
					}
					else
					{
						char num[16];
						menu.GetItem(choice, num, sizeof(num));
						int item = StringToInt(num);

						float woodcost = float(GetSData(CivType[client], item, WoodCost));
						float foodcost = float(GetSData(CivType[client], item, FoodCost));
						float goldcost = float(GetSData(CivType[client], item, GoldCost));

						if(WoodAmount[client] >= woodcost && FoodAmount[client] >= foodcost && GoldAmount[client] >= goldcost)
						{
							if(!TrainingIn[client])
							{
								TrainingIndex[client] = item;
								TrainingStartedIn[client] = GetGameTime();
								TrainingIn[client] = TrainingStartedIn[client] + float(LastMann ? (GetSData(CivType[client], item, TrainTime) / 3) : GetSData(CivType[client], item, TrainTime));
								if(CvarInfiniteCash.BoolValue)
								{
									TrainingIn[client] = TrainingStartedIn[client] + 0.5;
								}
							}
							else if(TrainingQueue[client] == -1)
							{
								TrainingQueue[client] = item;
							}
							else
							{
								WoodAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], WoodCost));
								FoodAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], FoodCost));
								GoldAmount[client] += float(GetSData(CivType[client], TrainingQueue[client], GoldCost));

								TrainingQueue[client] = item;
							}
							
							WoodAmount[client] -= woodcost;
							FoodAmount[client] -= foodcost;
							GoldAmount[client] -= goldcost;
							BarracksSaveResources(client);
						}
					}

					SummonerMenu(client, client);
				}
			}
			else
			{
				if(++CommandMode[client] >= sizeof(CommandName))
					CommandMode[client] = 0;

				if(CommandMode[client] == 3)
				{
					float StartOrigin[3], Angles[3], vecPos[3];
					GetClientEyeAngles(client, Angles);
					GetClientEyePosition(client, StartOrigin);
					Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (MASK_NPCSOLID_BRUSHONLY), RayType_Infinite, TraceRayProp);
					if (TR_DidHit(TraceRay))
						TR_GetEndPosition(vecPos, TraceRay);
							
					delete TraceRay;
					
					CreateParticle("ping_circle", vecPos, NULL_VECTOR);
					f3_SpawnPosition[client] = vecPos;
				}
				else
				{
					f3_SpawnPosition[client][0] = 0.0;
					f3_SpawnPosition[client][1] = 0.0;
					f3_SpawnPosition[client][2] = 0.0;
				}
				
				SummonerMenu(client, client);
			}
		}
	}
	return 0;
}


int ActiveCurrentNpcsBarracks(int client, bool ignore_barricades = false)
{
	int userid = GetClientUserId(client);
	int personal;
	if(!ignore_barricades)
	{
		personal = i_BarricadesBuild[client] * 3 / 2;
		if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
		{
			if(personal > MaxBarricadesAllowed(client)) //even if you build a barricade, it will allow you to get 1 more unit.
			{
				personal = MaxBarricadesAllowed(client) - 1;
			}
		}
	}


	int entity = MaxClients + 1;
	char npc_classname[60];
	while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(GetTeam(entity) == 2)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId == userid)
			{
				NPC_GetPluginById(i_NpcInternalId[npc.index], npc_classname, sizeof(npc_classname));
				if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER_EDUCATION)
				{
					if(!StrEqual(npc_classname, "npc_barrack_villager"))
					{
						if(!StrEqual(npc_classname, "npc_barrack_building"))
							personal += npc.m_iSupplyCount;
					}
				}
				else
				{
					if(!StrEqual(npc_classname, "npc_barrack_building"))
						personal += npc.m_iSupplyCount;
				}
			}
		}
	}

	if(!ignore_barricades)
	{
		if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)
		{
			personal += 1;
			if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
				personal -= 1;
		}
	}

	if(personal < 0)
	{
		personal = 0;
	}

	return personal;
}

static int GetSupplyLeft(int client)
{
	int personal = ActiveCurrentNpcsBarracks(client);
	return 3 + Rogue_Barracks_BonusSupply() - personal;
}

int BarricadeMaxSupply(int client)
{
	int Barricades_Active = i_BarricadesBuild[client];
	//4 at max
	int personalalive = ActiveCurrentNpcsBarracks(client, true);

	if(personalalive > 1)
	{
		Barricades_Active += RoundToCeil((float(personalalive) * 1.1));
	}

	if(Barricades_Active <= 0)
	{
		if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
		{
			Barricades_Active -= 1; //allow to always have build atelast 1 barricade when getting this upgrade, unless you have glass builder.
		}
	}

	return Barricades_Active;
}

void TeleportBuilding(int entity, const float origin[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, const float velocity[3] = NULL_VECTOR)
{
	int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
	int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);

	float Orgin_2[3];
	Orgin_2 = origin;
	SDKCall_SetLocalOrigin(entity, Orgin_2);	
	TeleportEntity(entity,NULL_VECTOR,angles,velocity);
	if(IsValidEntity(prop1))
	{
		SDKCall_SetLocalOrigin(prop1, Orgin_2);	
		TeleportEntity(prop1,NULL_VECTOR,angles,velocity);
	}
	if(IsValidEntity(prop2))
	{
		SDKCall_SetLocalOrigin(prop2, Orgin_2);	
		TeleportEntity(prop2,NULL_VECTOR,angles,velocity);
	}
}

void Barracks_BuildingThink(int client)
{
	int building = EntRefToEntIndex(i_HasSentryGunAlive[client]);

	if(!IsValidEntity(building))
	{
		SDKUnhook(client, SDKHook_PreThink, Barracks_BuildingThink);
		return;
	}
	if(i_WhatBuilding[building] != BuildingSummoner)
	{
		SDKUnhook(client, SDKHook_PreThink, Barracks_BuildingThink);
		return;
	}
	BarrackBody npc = view_as<BarrackBody>(building);
	float GameTime = GetGameTime(npc.index);
	
	if(!IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_PreThink, Barracks_BuildingThink);
		return;
	}
	//do not think.

	if(npc.m_flNextThinkTime > GameTime) //add a delay, we dont really need more lol
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	//they do not even have the first upgrade, do not think, but dont cancel.
	if(!(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER))
		return;

	float MinimumDistance = 60.0;

	if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_MURDERHOLES)
		MinimumDistance = 0.0;

	float MaximumDistance = 400.0;
	MaximumDistance = Barracks_UnitExtraRangeCalc(npc.index, client, MaximumDistance, true);
	float pos[3];
	bool mounted = (Building_Mounted[client] == i_HasSentryGunAlive[client]);
	int ValidEnemyToTarget;
	if(mounted)
	{
		GetClientEyePosition(client, pos);
		ValidEnemyToTarget = GetClosestTarget(client, true, MaximumDistance, true, _, _ ,pos, true,_,_,true, MinimumDistance);
	}
	else
	{
		GetEntPropVector(npc.index, Prop_Data, "m_vecOrigin", pos);
		ValidEnemyToTarget = GetClosestTarget(npc.index, true, MaximumDistance, true, _, _ ,pos, true,_,_,true, MinimumDistance);
	}
	
	if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_STRONGHOLDS)
	{
		if(mounted)
		{
			DoHealingOcean(client, client, (500.0 * 500.0), 0.5, true);
		}
		else
		{
			DoHealingOcean(building, building, (500.0 * 500.0), 0.5, true);
		}
	}
	if(IsValidEnemy(client, ValidEnemyToTarget))
	{
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			float ArrowDamage = 100.0;
			int ArrowCount = 1;
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER)
			{
				ArrowDamage += 200.0;
				ArrowCount += 1;
			}
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER)
			{
				ArrowDamage += 500.0;
				ArrowCount += 1;
			}
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)
			{
				ArrowDamage += 800.0;
				ArrowCount += 1;
			}
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_KREPOST)
			{
				ArrowDamage += 1200.0;
				ArrowCount += 1;
			}
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CASTLE)
			{
				ArrowDamage += 3000.0;
				ArrowCount += 1;
			}
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CHEMISTY)
			{
				ArrowDamage *= 1.25;
			}
			if(mounted) //mounted its half as strong.
			{
				ArrowDamage *= 0.5;
			}

			float AttackDelay = 7.0;
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_STRONGHOLDS)
			{
				AttackDelay *= 0.77; //attack 33% faster
			}
			//calc upgrades for damage
			Barracks_UnitExtraDamageCalc(npc.index, client,ArrowDamage, 1);

			npc.m_flNextMeleeAttack = GameTime + AttackDelay;
			npc.m_flDoingSpecial = ArrowDamage;
			npc.m_iOverlordComboAttack = ArrowCount;
		}
		if(npc.m_iOverlordComboAttack > 0)
		{
			BarrackBody playerclient = view_as<BarrackBody>(client);
			float vecTarget[3];
			float projectile_speed = 1200.0;
			
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICS)
			{
				PredictSubjectPositionForProjectiles(mounted ? playerclient : npc, ValidEnemyToTarget, projectile_speed, 55.0,vecTarget);
				if(!Can_I_See_Enemy_Only(mounted ? playerclient.index : npc.index, ValidEnemyToTarget)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					WorldSpaceCenter(ValidEnemyToTarget, vecTarget );
				}
			}
			else
			{
				WorldSpaceCenter(ValidEnemyToTarget, vecTarget );
			}


			EmitSoundToAll("weapons/bow_shoot.wav", mounted ? playerclient.index : npc.index, _, 70, _, 0.9, 100);

			//npc.m_flDoingSpecial is damage, see above.
			int arrow = npc.FireArrow(vecTarget, npc.m_flDoingSpecial, projectile_speed,_,_, 55.0, client, mounted ? client : -1);
			npc.m_iOverlordComboAttack -= 1;

			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CRENELLATIONS)
			{
				DataPack pack;
				CreateDataTimer(0.21, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				pack.WriteCell(EntIndexToEntRef(arrow)); //projectile
				pack.WriteCell(EntIndexToEntRef(ValidEnemyToTarget));		//victim to annihilate :)
			}
		}
	}
	if(npc.m_flDoingAnimation > GameTime)
	{
		return;
	}
	npc.m_flDoingAnimation = GameTime + 5.0;
	//only check for hoardings every 5 seconds.

	if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_HOARDINGS)
	{
		for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
		{
			int Building_hordings = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
			if(IsValidEntity(Building_hordings))
			{
				if(!i_BuildingRecievedHordings[Building_hordings]) 
				{
					if(GetEntPropEnt(Building_hordings, Prop_Send, "m_hBuilder") == client && Building_Constructed[Building_hordings])
					{
						SetBuildingMaxHealth(Building_hordings, 1.25, false, true);
						i_BuildingRecievedHordings[Building_hordings] = true;					
					}
				}
			}
		}
	}					
	BarrackVillager player = view_as<BarrackVillager>(client);
	if(IsValidEntity(player.m_iTowerLinked))
	{
		if(!i_BuildingRecievedHordings[player.m_iTowerLinked]) 
		{
			SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth")) * 1.25));
			SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth")) * 1.25));
			i_BuildingRecievedHordings[player.m_iTowerLinked] = true;
		}			
	}
}	


void BuildingHordingsRemoval(int entity)
{
	if(i_WhatBuilding[entity] == BuildingSummoner)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
		if(i_NormalBarracks_HexBarracksUpgrades_2[owner] & ZR_BARRACKS_UPGRADES_HOARDINGS)
		{
			for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
			{
				int Building_hordings = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
				if(IsValidEntity(Building_hordings))
				{
					if(i_BuildingRecievedHordings[Building_hordings])
					{
						if(GetEntPropEnt(Building_hordings, Prop_Send, "m_hBuilder") == owner)
						{
							SetBuildingMaxHealth(Building_hordings, 1.25, true, false);
							i_BuildingRecievedHordings[Building_hordings] = false;					
						}
					}
				}
			}
		}
		BarrackVillager player = view_as<BarrackVillager>(owner);
		if(IsValidEntity(player.m_iTowerLinked))
		{
			if(i_BuildingRecievedHordings[player.m_iTowerLinked]) 
			{
				SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth")) / 1.25));
				SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth")) / 1.25));
				i_BuildingRecievedHordings[player.m_iTowerLinked] = false;
			}			
		}
	}
}


void BuildingVillageChangeModel(int owner, int entity)
{
	/*
		Explained:
		Buildings, or sentries in this regard have some special rule where their model scale makes their bounding box scale with it
		thats why we have all this extra shit.


	*/
	int ModelTypeApplied = i_VillageModelAppliance[entity];
	int collisionboxapplied = i_VillageModelApplianceCollisionBox[entity];
	if(ModelTypeApplied == 1 && collisionboxapplied != 1)
	{
		i_VillageModelApplianceCollisionBox[entity] = 1;
		float ModelScaleMulti = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		for(int repeat; repeat < 3; repeat++)
		{
			minbounds[repeat] /= ModelScaleMulti;
			maxbounds[repeat] /= ModelScaleMulti;
		}
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

		view_as<CClotBody>(entity).UpdateCollisionBox();
		SDKUnhook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
	else if(ModelTypeApplied == 2 && collisionboxapplied != 2)
	{
		i_VillageModelApplianceCollisionBox[entity] = 2;
		float ModelScaleMulti = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		for(int repeat; repeat < 3; repeat++)
		{
			minbounds[repeat] /= ModelScaleMulti;
			maxbounds[repeat] /= ModelScaleMulti;
		}
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

		view_as<CClotBody>(entity).UpdateCollisionBox();
		SDKUnhook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
	else if(ModelTypeApplied == 3 && collisionboxapplied != 3)
	{
		i_VillageModelApplianceCollisionBox[entity] = 3;
		float ModelScaleMulti = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		for(int repeat; repeat < 3; repeat++)
		{
			minbounds[repeat] /= ModelScaleMulti;
			maxbounds[repeat] /= ModelScaleMulti;
		}
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

		view_as<CClotBody>(entity).UpdateCollisionBox();
		SDKUnhook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
	else if(ModelTypeApplied == 4 && collisionboxapplied != 4)
	{
		i_VillageModelApplianceCollisionBox[entity] = 4;
		float ModelScaleMulti = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		for(int repeat; repeat < 3; repeat++)
		{
			minbounds[repeat] /= ModelScaleMulti;
			maxbounds[repeat] /= ModelScaleMulti;
		}
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

		view_as<CClotBody>(entity).UpdateCollisionBox();
		SDKUnhook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
	else if(ModelTypeApplied == 5 && collisionboxapplied != 5)
	{
		i_VillageModelApplianceCollisionBox[entity] = 5;
		float ModelScaleMulti = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 30.0};
		for(int repeat; repeat < 3; repeat++)
		{
			minbounds[repeat] /= ModelScaleMulti;
			maxbounds[repeat] /= ModelScaleMulti;
		}
		SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

		view_as<CClotBody>(entity).UpdateCollisionBox();
		SDKUnhook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(owner, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
	if(Village_Flags[owner] & VILLAGE_500 && ModelTypeApplied != 5)
	{
		i_VillageModelAppliance[entity] = 5;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	//	SetEntityModel(entity, VILLAGE_MODEL_REBEL);
	}
	else if(Village_Flags[owner] & VILLAGE_300 && !(Village_Flags[owner] & VILLAGE_500) && ModelTypeApplied != 1)
	{
		i_VillageModelAppliance[entity] = 1;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
		SetEntityModel(entity, VILLAGE_MODEL_REBEL);
	}
	else if(Village_Flags[owner] & VILLAGE_030 && ModelTypeApplied != 2)
	{
		i_VillageModelAppliance[entity] = 2;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
		SetEntityModel(entity, VILLAGE_MODEL_MIDDLE);
	}
	else if(Village_Flags[owner] & VILLAGE_003 && ModelTypeApplied != 3)
	{
		i_VillageModelAppliance[entity] = 3;
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.5);
		SetEntityModel(entity, VILLAGE_MODEL_LIGHTHOUSE);
	}
	else if(ModelTypeApplied == 0)
	{
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
		i_VillageModelAppliance[entity] = 4;
		SetEntityModel(entity, VILLAGE_MODEL);
	}
}

public Action Building_PlaceBlacksmith(int client, int weapon, const char[] classname, bool &result)
{
	int Sentrygun = EntRefToEntIndex(i_HasSentryGunAlive[client]);
	if(!IsValidEntity(Sentrygun))
	{
		if(Building_Sentry_Cooldown[client] > GetGameTime())
		{
			result = false;
			float Ability_CD = Building_Sentry_Cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, weapon, Building_Blacksmith, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public bool Building_Blacksmith(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingBlacksmith;
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
//	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.2, Blacksmith_BuildingTimer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	DataPack pack;
	CreateDataTimer(0.21, Timer_DroppedBuildingWaitHealingStation, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	pack.WriteCell(client); //Need original client index id please.
//	SDKHook(entity, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmit);
	
	//This is so low because it has to update the animation very often, this is needed.
	//i dont want to use an sdkhook for this as i already have this here, and i dont think buildings have think, and it wouldnt be needed here
	//anyways as i have to reuse whats in there anyways.
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 100);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 712); //512 is max shown, then + 200 to have a nice number, abuse overflow :)
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.8);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_blacksmith");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	
	if(!CvarInfiniteCash.BoolValue && !Rogue_Mode())
		Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = Building_Sentry_Cooldown[client] + 60.0;
	}
	Barracks_UpdateEntityUpgrades(client, entity, true);
	return true;
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

bool BuildingIsSupport(int entity)
{
	switch(i_WhatBuilding[entity])
	{
		case BuildingPackAPunch, BuildingPerkMachine, BuildingArmorTable,BuildingAmmobox:
			return true;
		
		default:
			return false;
	}
}
void Building_Check_ValidSupportcount(int client)
{
	if(i_HealthBeforeSuit[client] > 0)
		return;
		
	if(f_HealthBeforeSuittime[client] > GetGameTime())
		return;

	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
		if(IsValidEntity(entity) && BuildingIsSupport(entity))
		{
			int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
			if(builder_owner == client)
			{
				if(i_SupportBuildingsBuild[client] > MaxSupportBuildingsAllowed(client, false))
				{
					SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
					if(h_ClaimedBuilding[client][entity] != null)
						delete h_ClaimedBuilding[client][entity];

					i_SupportBuildingsBuild[client] -= 1;
					//not enough support slots.
				}
				else
				{	
					if(MaxSupportBuildingsAllowed(client, false) <= 1 && i_WhatBuilding[entity] == BuildingPackAPunch)
					{
						SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
						if(h_ClaimedBuilding[client][entity] != null)
							delete h_ClaimedBuilding[client][entity];

						i_SupportBuildingsBuild[client] -= 1;
						//cannot support pap.
					}
				}
			}
		}
	}
}


void BuildingVoteEndResetCD()
{
	Zero2(Building_Collect_Cooldown);
}

void ApplyBuildingCollectCooldown(int building, int client, float Duration, bool IgnoreVotingExtraCD = false)
{
	if(GameRules_GetRoundState() == RoundState_BetweenRounds && !IgnoreVotingExtraCD)
	{
		Building_Collect_Cooldown[building][client] = FAR_FUTURE;
	}
	else
	{
		Building_Collect_Cooldown[building][client] = GetGameTime() + Duration;
	}
}