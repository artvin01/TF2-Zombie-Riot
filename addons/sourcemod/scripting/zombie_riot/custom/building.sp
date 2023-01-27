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

//#define BARRICADE_MODEL "models/props_c17/concrete_barrier001a.mdl"
#define BARRICADE_MODEL "models/props_gameplay/sign_barricade001a.mdl"

#define ELEVATOR_MODEL "models/props_mvm/mvm_museum_pedestal.mdl"

#define SUMMONER_MODEL	"models/props_island/parts/guard_tower01.mdl"

#define BUILDINGCOLLISIONNUMBER	27

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
	BuildingSummoner = 11
}

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

//static int gLaser1;

static int Beam_Laser;
static int Beam_Glow;

static float f_MarkerPosition[MAXTF2PLAYERS][3];

static Handle h_Pickup_Building[MAXPLAYERS + 1];

void Building_MapStart()
{
	if(Village_Effects)
		delete Village_Effects;
	
	Village_Effects = new ArrayList(sizeof(VillageBuff));
	
//	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
//	SyncHud_Notifaction = CreateHudSynchronizer();
	PrecacheModel(CUSTOM_SENTRYGUN_MODEL); //MORTAR MODEL AND RAILGUN MODEL!!!
	AddFileToDownloadsTable("models/zombie_riot/buildings/mortar_2.mdl");
	AddFileToDownloadsTable("models/zombie_riot/buildings/mortar_2.dx80.vtx");
	AddFileToDownloadsTable("models/zombie_riot/buildings/mortar_2.dx90.vtx");
	AddFileToDownloadsTable("models/zombie_riot/buildings/mortar_2.vvd"); 			//ADD TO DOWNLOADS!
	
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
	PrecacheSound("weapons/drg_wrench_teleport.wav");
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheModel("models/items/ammocrate_smg1.mdl");
	PrecacheModel("models/props_manor/table_01.mdl");
	PrecacheModel(PERKMACHINE_MODEL);
	
	PrecacheModel(PACKAPUNCH_MODEL);
	PrecacheModel(HEALING_STATION_MODEL);
	PrecacheModel(VILLAGE_MODEL);
	PrecacheModel(BARRICADE_MODEL);
	PrecacheModel(ELEVATOR_MODEL);
	PrecacheModel(SUMMONER_MODEL);
	
	PrecacheSound("items/powerup_pickup_uber.wav");
	PrecacheSound("player/mannpower_invulnerable.wav");
}

//static int RebelTimerSpawnIn;
static int Building_Repair_Health[MAXENTITIES]={0, ...};
static int Building_Hidden_Prop[MAXENTITIES][2];
static int Building_Hidden_Prop_To_Building[MAXENTITIES]={-1, ...};
static int Building_Max_Health[MAXENTITIES]={0, ...};


static int i_HasSentryGunAlive[MAXTF2PLAYERS]={-1, ...};

static bool Building_cannot_be_repaired[MAXENTITIES]={false, ...};

static float Building_Sentry_Cooldown[MAXTF2PLAYERS];

static int i_MachineJustClickedOn[MAXTF2PLAYERS];

void Building_ClearAll()
{
	Zero2(Building_Collect_Cooldown);
	Zero(Building_Sentry_Cooldown);
	Zero(Village_TierExists);
	//RebelTimerSpawnIn = 0;
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
	if(i_BarricadesBuild[client] < MaxBarricadesAllowed(client))
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
//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
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
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
//	CreateTimer(0.5, Timer_DroppedBuildingWaitSentryLeveLUp, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_railgun");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_mortar");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
	CreateDataTimer(0.1, Timer_DroppedBuildingWaitHealingStation, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	pack.WriteCell(client); //Need original client index id please.
//	SDKHook(entity, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmit);
	
	//This is so low because it has to update the animation very often, this is needed.
	//i dont want to use an sdkhook for this as i already have this here, and i dont think buildings have think, and it wouldnt be needed here
	//anyways as i have to reuse whats in there anyways.
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_healingstation");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	for (int i = 1; i <= MaxClients; i++)
	{
		Building_Collect_Cooldown[entity][i] = 0.0;
	}
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
		int level = RoundFloat(Attributes_FindOnPlayer(client, 148))+1;
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
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_barricade");
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
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
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_elevator");
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 255, 255, 255, 150);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	return false;
}

public bool Building_AmmoBox(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingAmmobox;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack;
	CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.1, Timer_DroppedBuildingWaitAmmobox, pack_2, TIMER_REPEAT);
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
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_ammobox");
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	return false;
}

public bool Building_ArmorTable(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingArmorTable;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack;
	CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.1, Timer_DroppedBuildingWaitArmorTable, pack_2, TIMER_REPEAT);
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
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_armortable");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	return false;
}

public bool Building_PerkMachine(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingPerkMachine;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	
//	SDKHook(entity, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmit);
	
	DataPack pack;
	CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;

	DataPack pack_2;
	CreateDataTimer(0.1, Timer_DroppedBuildingWaitPerkMachine, pack_2, TIMER_REPEAT);
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
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_perkmachine");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	return false;
}

public bool Building_PackAPunch(int client, int entity)
{
	i_WhatBuilding[entity] = BuildingPackAPunch;
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack;
	CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(client)); 
	pack.WriteCell(client); //Need original client index id please.
	i_SupportBuildingsBuild[client] += 1;
	
	DataPack pack_2;
	CreateDataTimer(0.1, Timer_DroppedBuildingWaitPackAPunch, pack_2, TIMER_REPEAT);
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
	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199);
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", 200);
	SetEntProp(entity, Prop_Send, "m_bCarried", true);
//	SetEntProp(entity, Prop_Send, "m_iAmmoMetal", 300);

	SetEntPropString(entity, Prop_Data, "m_iName", "zr_packapunch");
	
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
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


/*
void Building_IncreaseSentryLevel(int client)
{
	int level = RoundFloat(Attributes_FindOnPlayer(client, 148)) + 1;
	
	int sentry = MaxClients+1;
	while((sentry=FindEntityByClassname(sentry, "obj_sentrygun")) != -1)
	{
		if(GetEntPropEnt(sentry, Prop_Send, "m_hBuilder") == client)
		{
			SetEntProp(sentry, Prop_Send, "m_iUpgradeLevel", level);
			switch(level)
			{
				case 2:
				{
					SetEntityModel(sentry, "models/buildables/sentry2.mdl");
				}
				case 3:
				{
					SetEntityModel(sentry, "models/buildables/sentry3.mdl");
				}
				default:
				{
					SetEntityModel(sentry, "models/buildables/sentry1.mdl");
				}
			}
		}
	}
}
*/

public Action Building_TakeDamage(int entity, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype == DMG_CRUSH)
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if(i_BeingCarried[entity])
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if(RaidBossActive && IsValidEntity(RaidBossActive)) //They are ignored anyways
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if(b_thisNpcIsABoss[attacker])
	{
		damage *= 1.5;
	}
	//This is no longer needed, this logic has been added to the base explosive plugin, this also means that it allows
	//npc vs npc interaction (mainly from blu to red) to deal 3x the explosive damage, so its not so weak.
	/*
	if(damagetype & DMG_BLAST)
	{
		damage *= 3.0; //OTHERWISE EXPLOSIVES ARE EXTREAMLY WEAK!!
	}
	*/
	/*
	if(Resistance_for_building_High[entity] > GetGameTime())
	{
		damage *= 0.15;
		return Plugin_Changed;
	}
	else if(Resistance_for_building_Low[entity] > GetGameTime())
	{
		damage *= 0.30;
		return Plugin_Changed;
	}
	*/
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
			
			red = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
		//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			green = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			
			red = 255 - red;
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
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
		
		if(IsValidClient(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")))
		{
			int red = 255;
			int green = 255;
			int blue = 0;
			
			red = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
		//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			green = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			
			red = 255 - red;
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

public void Building_TakeDamagePost(int entity, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(damagetype != DMG_CRUSH)
	{
		int dmg = RoundFloat(damage);
		
		if(!Building_cannot_be_repaired[entity])
		{
			Building_Repair_Health[entity] -= dmg;
			if(Building_Repair_Health[entity] > 0)
			{
				dmg = 0;
				SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", Building_Repair_Health[entity] * 200 / GetEntProp(entity, Prop_Data, "m_iMaxHealth"));
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
		if(func == Building_PlaceSummoner || func == Building_PlaceVillage || func == Building_PlaceHealingStation || func == Building_PlacePackAPunch || func == Building_PlacePerkMachine || func==Building_PlaceRailgun || func==Building_PlaceMortar || func==Building_PlaceSentry || func==Building_PlaceDispenser || func==Building_PlaceAmmoBox || func==Building_PlaceArmorTable || func==Building_PlaceElevator)
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
/*
void Building_PlayerRunCmd(int client, int buttons)
{
	if(GrabRef[client] != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(GrabRef[client]);
		if(GrabAt[client] == 1.0)
		{
			if(entity > MaxClients)
			{
				if(GetEntProp(entity, Prop_Send, "m_bCarried"))
				{
					GrabAt[client] = 0.0;
				//	SetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed", 0.0);
				}
				
				return;
			}
			
			GrabAt[client] = 0.0;
		}
		else if(entity > MaxClients && GetEntProp(entity, Prop_Send, "m_bCarried"))
		{
			return;
		}
		
		//TF2Attrib_SetByDefIndex(client, 353, 1.0);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
		GrabRef[client] = INVALID_ENT_REFERENCE;
	}
	else if(GrabAt[client])
	{
		if((buttons & IN_ATTACK2))
		{
			if(GrabAt[client] > GetGameTime())
				return;
				
			int entity = GetClientPointVisible(client);
			if(entity > MaxClients)
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)) && !StrContains(buffer, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
				{
					CClotBody npc = view_as<CClotBody>(entity);
					npc.bBuildingIsPlaced = false;
					GrabRef[client] = INVALID_ENT_REFERENCE;
				//	GrabRef[client] = EntIndexToEntRef(entity); //This is not needed.
				//	TF2Attrib_SetByDefIndex(client, 698, 0.0);
					if(!StrContains(buffer, "obj_dispenser"))
					{
						Building[client] = INVALID_FUNCTION;
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						SDKCall(g_hSDKMakeCarriedObjectDispenser, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						Event_ObjectMoved_Custom(entity);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						
					}
					else if(!StrContains(buffer, "obj_sentrygun"))
					{
						Building[client] = INVALID_FUNCTION;
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						SDKCall(g_hSDKMakeCarriedObjectSentry, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						Event_ObjectMoved_Custom(entity);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
					//	TF2_SetPlayerClass(client, TFClass_Engineer);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
					}	
					GrabAt[client] = 1.0;
					PrintCenterText(client, " ");
					return;
				}
			}
		}
		GrabAt[client] = 0.0;
		PrintCenterText(client, " ");
	}
}
*/

public void Pickup_Building_M2(int client, int weapon, bool crit)
{
		int entity = GetClientPointVisible(client, _ , true, true);
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
								KillTimer(h_Pickup_Building[client]);
							}
							b_Doing_Buildingpickup_Handle[client] = true;
							DataPack pack;
							h_Pickup_Building[client] = CreateDataTimer(1.0, Building_Pickup_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
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
		PrintCenterText(client, " ");
		if (IsValidEntity(entity))
		{
			int looking_at = GetClientPointVisible(client, _ , true, true);
			if (looking_at == entity)
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)) && !StrContains(buffer, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
				{
					TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); //They stay invis in that pos, move away.
					SetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed", 0.1);
					CClotBody npc = view_as<CClotBody>(entity);
					npc.bBuildingIsPlaced = false;
					if(!StrContains(buffer, "obj_dispenser"))
					{
						Building[client] = INVALID_FUNCTION;
						BuildingWeapon[client] = INVALID_ENT_REFERENCE;
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						SDKCall(g_hSDKMakeCarriedObjectDispenser, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						Event_ObjectMoved_Custom(entity);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						
					}
					else if(!StrContains(buffer, "obj_sentrygun"))
					{
						Building[client] = INVALID_FUNCTION;
						BuildingWeapon[client] = INVALID_ENT_REFERENCE;
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						int iBuilder = Spawn_Buildable(client);
						SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
						SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
						
						
						SDKCall(g_hSDKMakeCarriedObjectSentry, entity, client);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
						Event_ObjectMoved_Custom(entity);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
					//	TF2_SetPlayerClass(client, TFClass_Engineer);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
						Spawn_Buildable(client);
						TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
					}	
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
		else if(StrEqual(buffer, "base_boss"))
		{
			if(b_IsAlliedNpc[entity])
			{
				if(f_CooldownForHurtHud[client] < GetGameTime())
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
			else if(!StrContains(buffer, "zr_village"))
			{
				buildingType = 8;
			}
			else if(!StrContains(buffer, "zr_summoner"))
			{
				buildingType = 9;
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
							DataPack pack;
							CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(EntIndexToEntRef(client)); 
							pack.WriteCell(client); //Need original client index id please.
							i_SupportBuildingsBuild[client] += 1;
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);
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
			else if (StrEqual(buffer, "zr_perkmachine"))
			{
				buildingType = 5;
			}					
			else if (StrEqual(buffer, "zr_packapunch"))
			{
				buildingType = 6;
			}
		}
		else if(Is_Reload_Button && StrEqual(buffer, "base_boss"))
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
					Building_Collect_Cooldown[entity][client] = GetGameTime() + 90.0;
					ClientCommand(client, "playgamesound items/smallmedkit1.wav");
					int HealAmmount = 1;
					int HealTime = 30;
					if(IsValidClient(owner))
					{
						HealAmmount = RoundToNearest(float(HealAmmount) * Attributes_FindOnPlayer(owner, 8, true, 1.0, true));
					}
				/*
					if(f_TimeUntillNormalHeal[client])
					{
						HealTime =/ 2;
						if(HealTime < 1)
						{
							HealTime = 1;
						}
					}
			*/
					StartHealingTimer(client, 0.1, HealAmmount, HealTime);
					if(owner != -1 && i_Healing_station_money_limit[owner][client] < 10)
					{
						if(owner != client)
						{
							i_Healing_station_money_limit[owner][client] += 1;
							Resupplies_Supplied[owner] += 4;
							CashSpent[owner] -= 40;
							SetDefaultHudPosition(client);
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
									/*
									Current_Mana[client] += RoundToCeil(mana_regen[client]);
										
									if(Current_Mana[client] < RoundToCeil(max_mana[client]))
										Current_Mana[client] = RoundToCeil(max_mana[client]);
									*/
									
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

										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;

										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
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
										SetAmmo(client, 21, GetAmmo(client, 21)+(AmmoData[21][1]*2));
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if (weaponindex == 305)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 21, GetAmmo(client, 21)+(AmmoData[21][1]*2));
										Ammo_Count_Used[client] += 1;
										SetAmmo(client, 14, GetAmmo(client, 14)+(AmmoData[14][1]*2));
										//Yeah extra ammo, do i care ? no.
										
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}								
									}
									else if(weaponindex == 411)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 22, GetAmmo(client, 22)+(AmmoData[22][1]*2));
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 441 || weaponindex == 35)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 23, GetAmmo(client, 23)+(AmmoData[23][1]*2));
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}		
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 998)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 3, GetAmmo(client, 3)+(AmmoData[3][1]*2));
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(AmmoBlacklist(Ammo_type)) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+(AmmoData[Ammo_type][1]*2));
										Ammo_Count_Used[client] += 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}
										fl_NextThinkTime[entity] = GetGameTime() + 2.0;
										i_State[entity] = -1;
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetDefaultHudPosition(client);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else
									{
										int Armor_Max = 150;
										int Extra = 0;
									
										Extra = Armor_Level[client];
										Armor_Max = MaxArmorCalculation(Extra, client, 0.5);
											
										if(Armor_Charge[client] < Armor_Max)
										{
												
											if(Extra == 50)
												Armor_Charge[client] += 25;
												
											else if(Extra == 100)
												Armor_Charge[client] += 35;
												
											else if(Extra == 150)
												Armor_Charge[client] += 50;
												
											else if(Extra == 200)
												Armor_Charge[client] += 75;
												
											else
												Armor_Charge[client] += 25;
														
											if(Armor_Charge[client] >= Armor_Max)
											{
												Armor_Charge[client] = Armor_Max;
											}
											
									//		float Shave_Seconds_off = 5.0 * Extra;
											fl_NextThinkTime[entity] = GetGameTime() + 2.0;
											i_State[entity] = -1;
											Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
											if(owner != -1 && owner != client)
											{
												Resupplies_Supplied[owner] += 2;
												CashSpent[owner] -= 20;
												SetDefaultHudPosition(client);
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
						int Extra = 0;
					
						Extra = Armor_Level[client];
							
						Armor_Max = MaxArmorCalculation(Extra, client, 1.0);
							
							//armoar
							
						if(Armor_Charge[client] < Armor_Max)
						{
								
							if(Extra == 50)
								Armor_Charge[client] += 75;
								
							else if(Extra == 100)
								Armor_Charge[client] += 100;
								
							else if(Extra == 150)
								Armor_Charge[client] += 200;
								
							else if(Extra == 200)
								Armor_Charge[client] += 350;
								
							else
								Armor_Charge[client] += 25;
										
							if(Armor_Charge[client] >= Armor_Max)
							{
								Armor_Charge[client] = Armor_Max;
							}
							
					//		float Shave_Seconds_off = 5.0 * Extra;
							
						//	Armor_Ready[client] = GetGameTime() + 10.0; //ehhhhhhhh make it rlly small
							Building_Collect_Cooldown[entity][client] = GetGameTime() + 45.0; //small also

							float pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

							pos[2] += 45.0;

							ParticleEffectAt(pos, "halloween_boss_axe_hit_sparks", 1.0);

						//	CashSpent[owner] -= 20;
							if(owner != -1 && owner != client)
							{
								if(Armor_table_money_limit[owner][client] < 15)
								{
									CashSpent[owner] -= 40;
									Armor_table_money_limit[owner][client] += 1;
									Resupplies_Supplied[owner] += 4;
									SetDefaultHudPosition(client);
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
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Armor Max Reached");
						}
				}
				case 5:
				{
						if(Is_Reload_Button)
						{
							i_MachineJustClickedOn[client] = EntIndexToEntRef(entity);
							
							SetGlobalTransTarget(client);
							
							Menu menu2 = new Menu(Building_ConfirmMountedAction);
							menu2.SetTitle("%t", "Which perk do you desire?");
								
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
				case 6:
				{
						if(Is_Reload_Button)
						{
							int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
							if(weapon != -1 && StoreWeapon[weapon] > 0)
							{
								if(Store_CanPapItem(client, StoreWeapon[weapon]))
								{
									Store_PackMenu(client, StoreWeapon[weapon], weapon, owner);
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
					if(Is_Reload_Button)
					{
						VillageUpgradeMenu(owner, client);
					}
				}
				case 9:
				{
					if(Is_Reload_Button)
					{
						OpenSummonerMenu(owner, client);
					}
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
			
			if(!result)
			{
				int weapon = EntRefToEntIndex(BuildingWeapon[client]);
				if(weapon == -1)
					return Plugin_Stop;
				
				Store_ConsumeItem(client, StoreWeapon[weapon]);
				MenuPage(client, StoreWeapon[weapon]);

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
	TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
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
	int client_original_index = pack.ReadCell(); //Need original!
	
	if(!IsValidEntity(entity))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	if(!IsValidClient(client)) //Are they valid ? no ? DIE!
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
		if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
					int looking_at = GetClientPointVisible(client);
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
						Building_Collect_Cooldown[obj][client] = GetGameTime() + 75.0;
						ClientCommand(client, "playgamesound items/smallmedkit1.wav");
						StartHealingTimer(client, 0.1, 1, 30);
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
					int looking_at = GetClientPointVisible(client);
					if(IsValidEntity(looking_at) && looking_at > 0)
					{
						GetEntPropString(looking_at, Prop_Data, "m_iName", buffer, sizeof(buffer));
						if(StrEqual(buffer, "zr_healingstation"))
						{
							if(GetEntPropEnt(looking_at, Prop_Send, "m_hBuilder") == client)
							{
								if(Building_Collect_Cooldown[obj][client] < GetGameTime())
								{
									Building_Collect_Cooldown[obj][client] = GetGameTime() + 75.0;
									ClientCommand(client, "playgamesound items/smallmedkit1.wav");
									StartHealingTimer(client, 0.1, 1, 30);
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
						f_BuildingIsNotReady[client] = GetGameTime() + 120.0;
						
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

#define MAX_TARGETS_HIT 10
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
									
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
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
							
			damage *= 35.0;
			
			float attack_speed;
			float sentry_range;
		
			attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
			damage = attack_speed * damage * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
			
			sentry_range = Attributes_FindOnPlayer(client, 344, true, 1.0);			//Sentry Range bonus
			
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
							
		Strength *= 40.0;

		float attack_speed;

		attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
		Strength = attack_speed * Strength * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		
		float sentry_range;
			
		sentry_range = Attributes_FindOnPlayer(client, 344, true, 1.0);			//Sentry Range bonus
					
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
			
			
			for (int building = 1; building < MAX_TARGETS_HIT; building++)
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
	//		int weapon = BEAM_UseWeapon[client] ? GetPlayerWeaponSlot(client, 2) : -1;
			/*
			for (int victim = 1; victim < MaxClients; victim++)
			{
				if (BEAM_HitDetected[victim] && BossTeam != GetClientTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BEAM_CloseDPT[client] + (BEAM_FarDPT[client]-BEAM_CloseDPT[client]) * (distance/BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
	
					TakeDamage(victim, client, client, damage/6, 2048, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			*/
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
							damage *= 1.65;
							First_Target_Hit = false;
						}
					
						SDKHooks_TakeDamage(BEAM_BuildingHit[building], obj, client, damage/BEAM_Targets_Hit[obj], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), startPoint);	// 2048 is DMG_NOGIB?
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
	}
}

static void Railgun_Boom_Client(int client)
{
	int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(obj) && IsValidClient(client))
	{
		int BEAM_BeamRadius = 40;
		float Strength = 10.0;
							
		Strength *= 40.0;
		float attack_speed;
		
		attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
		Strength = attack_speed * Strength * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		
		float sentry_range;
			
		sentry_range = Attributes_FindOnPlayer(client, 344, true, 1.0);			//Sentry Range bonus
		
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
			
			
			for (int building = 1; building < MAX_TARGETS_HIT; building++)
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
	//		int weapon = BEAM_UseWeapon[client] ? GetPlayerWeaponSlot(client, 2) : -1;
			/*
			for (int victim = 1; victim < MaxClients; victim++)
			{
				if (BEAM_HitDetected[victim] && BossTeam != GetClientTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BEAM_CloseDPT[client] + (BEAM_FarDPT[client]-BEAM_CloseDPT[client]) * (distance/BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
	
					TakeDamage(victim, client, client, damage/6, 2048, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			*/
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
							damage *= 1.65;
							First_Target_Hit = false;
						}
	
						SDKHooks_TakeDamage(BEAM_BuildingHit[building], obj, client, damage/BEAM_Targets_Hit[obj], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), startPoint);	// 2048 is DMG_NOGIB?
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
			
			if (((!StrContains(classname, "base_boss", true) && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(client, Prop_Send, "m_iTeamNum")))
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


public int MaxSupportBuildingsAllowed(int client, bool ingore_glass)
{
	int maxAllowed = 1;
	
  	int Building_health_attribute = RoundToNearest(Attributes_FindOnPlayer(client, 762)); //762 is how many extra buildings are allowed on you.
	
	maxAllowed += Building_health_attribute; 
	
	if(maxAllowed < 1)
	{
		maxAllowed = 1;
	}
	
	if(!ingore_glass && b_HasGlassBuilder[client])
	{
		maxAllowed = 1;
	}
	return maxAllowed;
}


public int MaxBarricadesAllowed(int client)
{
	int maxAllowed = 3;
	
 //	int Building_health_attribute = RoundToNearest(Attributes_FindOnPlayer(client, 762)); //762 is how many extra buildings are allowed on you.
	
//	maxAllowed += Building_health_attribute;
	
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
		case MenuAction_Select:
		{
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
		}
	}
	return 0;
}

public void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk)
{
	TF2_StunPlayer(client, 1.0, 0.0, TF_STUNFLAG_BONKSTUCK | TF_STUNFLAG_SOUND, 0);
	Building_Collect_Cooldown[entity][client] = GetGameTime() + 40.0;
	
	i_CurrentEquippedPerk[client] = what_perk;
	
	if(owner != -1 && owner != client)
	{
		if(Perk_Machine_money_limit[owner][client] < 10)
		{
			CashSpent[owner] -= 80;
			Perk_Machine_money_limit[owner][client] += 2;
			Resupplies_Supplied[owner] += 8;
			SetDefaultHudPosition(client);
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

	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", PerkNames_Recieved[i_CurrentEquippedPerk[client]]);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	
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
	b_SentryIsCustom[entity] = !(Village_Flags[client] & VILLAGE_500);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.5, Timer_VillageThink, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT); //No custom anims
	
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.75);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Repair_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_village");
	Building_cannot_be_repaired[entity] = false;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	Building_Collect_Cooldown[entity][0] = 0.0;
	
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
		else if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") == 1.0)
		{
			if(!Building_Constructed[entity])
			{
				//BELOW IS SET ONCE!
				view_as<CClotBody>(entity).bBuildingIsPlaced = true;
				Building_Constructed[entity] = true;
				
				if(Village_Flags[owner] & VILLAGE_500)
				{
					SetEntityModel(entity, "models/buildables/sentry1.mdl");
				}
				else
				{
					static const float minbounds[3] = {-10.0, -20.0, 0.0};
					static const float maxbounds[3] = {10.0, 20.0, -2.0};
					SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
					SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
					
					SetEntityModel(entity, VILLAGE_MODEL);
				}
			}
			
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		}
		else
		{
			Building_Constructed[entity] = false;
		}
	}
	
	
	i_ExtraPlayerPoints[owner] += 2; //Static low point increace.
	
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
		else if(effects & VILLAGE_004)
		{
			range += 150.0;
		}
	}
	
	if(mounted)
		range *= 0.55;
	
	range = range * range;
	
	ArrayList weapons = new ArrayList();
	ArrayList allies = new ArrayList();
	
	float pos2[3];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < range)
			{
				allies.Push(client);
				
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon > MaxClients)
					weapons.Push(weapon);
			}
		}
	}
	
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(GetEntProp(i, Prop_Send, "m_iTeamNum") == 2)
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

float Building_GetDiscount()
{
	int extra;
	bool found;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsValidEntity(i_HasSentryGunAlive[client]))
		{
			if(Village_Flags[client] & VILLAGE_001)
				found = true;
			
			if(Village_Flags[client] & VILLAGE_002)
				extra++;
		}
	}
	
	if(!found)
		return 1.0;
	
	if(extra > 3)
		extra = 3;
	
	return 0.98 - (extra * 0.01);
}

void Building_CamoOrRegrowBlocker(bool &camo, bool &regrow)
{
	if(camo || regrow)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsValidEntity(i_HasSentryGunAlive[client]))
			{
				if(camo && (Village_Flags[client] & VILLAGE_010) && (GetURandomInt() % 2))
					camo = false;
				
				if(regrow && (Village_Flags[client] & VILLAGE_020) && !(GetURandomInt() % 5))
					regrow = false;
			}
		}
	}
}
/*
float Building_GetCashOnKillMulti(int client)
{
	if(GetBuffEffects(EntIndexToEntRef(client)) & VILLAGE_003)
		return 1.15;
	
	return 1.0;
}
*/
stock int Building_GetCashOnWave(int current)
{
	/*
	int popCash;
	int extras;
	int farms;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsValidEntity(i_HasSentryGunAlive[client]))
		{
			if(Village_Flags[client] & VILLAGE_003)
			{
				i_ExtraPlayerPoints[client] += 50;
				popCash++;
			}
			
			if(Village_Flags[client] & VILLAGE_300 || Village_Flags[client] & VILLAGE_400 || Village_Flags[client] & VILLAGE_500)//VILLAGE_004)
			{
				i_ExtraPlayerPoints[client] += 10;
				extras++;
			}
			
			if(Village_Flags[client] & VILLAGE_005)
			{
				i_ExtraPlayerPoints[client] += 200; //Alot of free points.
				farms++;
			}
		}
	}
	
	if(extras)
	{
		if(RebelTimerSpawnIn >= 3)
		{
			RebelTimerSpawnIn = 0;
			int count;
			
			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "base_boss")) != -1)
			{
				if(i_NpcInternalId[i] == CITIZEN)
					count++;
			}
			
			for(i = 0; i < extras && count < MAX_REBELS_ALLOWED; i++) //Do not allow more then this many npcs
			{
				Citizen_SpawnAtPoint();
				count++;
			}
		}
		else
		{
			RebelTimerSpawnIn += 1;
		}
	}
	
	if(popCash > 3)
		popCash = 3;
	
	int red = CountPlayersOnRed();
	if(!red)
		red = 1;
	
	return (current * popCash / 6) + (farms * (Waves_InFreeplay() ? (extras > 1 ? 575 : 500) : (extras > 1 ? 2760 : 2400)) / red);
	*/
	return 0;
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

static void VillageUpgradeMenu(int client, int viewer)
{
	bool owner = client == viewer;
	
	Menu menu = new Menu(VillageUpgradeMenuH);
	
	SetGlobalTransTarget(viewer);
	int cash = CurrentCash-CashSpent[viewer];
	menu.SetTitle("%t\n \n%t\n \n%s\n ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(viewer, "Buildable Village", ""));
	
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
		menu.AddItem("", "radius attack faster, deal more damage, and start with $1000.\n ", ITEMDRAW_DISABLED);
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
			FormatEx(buffer, sizeof(buffer), "%s [$5000]", TranslateItemName(viewer, "Rebel Expertise", ""));
			menu.AddItem(VilN(VILLAGE_500), buffer, (!owner || cash < 5000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Village becomes an attacking sentry, plus all Rebels in", ITEMDRAW_DISABLED);
			menu.AddItem("", "radius attack faster, deal more damage, and start with $1000.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_300)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$2500]%s", TranslateItemName(viewer, "Rebel Mentoring", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_400), buffer, (!owner || cash < 2500) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "All Rebels in radius start with $500,", ITEMDRAW_DISABLED);
		menu.AddItem("", "increased range and attack speed.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_200)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Jungle Drums", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Increases attack speed of all", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies in the radius.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [$800]%s", TranslateItemName(viewer, "Rebel Training", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_300), buffer, (!owner || cash < 800) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "All Rebels in radius get", ITEMDRAW_DISABLED);
			menu.AddItem("", "more range and more damage.\n", ITEMDRAW_DISABLED);
			menu.AddItem("", "Village will spawn rebels every 3 waves upto 3\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_100)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$1500]%s", TranslateItemName(viewer, "Jungle Drums", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_200), buffer, (!owner || cash < 1500) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases attack speed of all", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies in the radius.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		if(owner)
			menu.AddItem("", "TIP: Only one path can have a tier 3 upgrade.\n ", ITEMDRAW_DISABLED);
		
		FormatEx(buffer, sizeof(buffer), "%s [$400]%s", TranslateItemName(viewer, "Bigger Radius", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : Village_TierExists[0] == 3 ? " [Tier 3 Exists]" : Village_TierExists[0] == 2 ? " [Tier 2 Exists]" : Village_TierExists[0] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_100), buffer, (!owner || cash < 400) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases influence radius of the village.\n ", ITEMDRAW_DISABLED);
	}
	
	if(Village_Flags[client] & VILLAGE_050)
	{
		menu.AddItem("", TranslateItemName(viewer, "Homeland Defense", ""), ITEMDRAW_DISABLED);
		menu.AddItem("", "Ability now increases attack speed by 100%", ITEMDRAW_DISABLED);
		menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_040)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Call To Arms", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
			menu.AddItem("", "players and allies +50% attack speed for a short time.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [$15000]", TranslateItemName(viewer, "Homeland Defense", ""));
			menu.AddItem(VilN(VILLAGE_050), buffer, (!owner || cash < 15000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Ability now increases attack speed by 100%", ITEMDRAW_DISABLED);
			menu.AddItem("", "for all players and allies for 20 seconds.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_030)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$8000]%s", TranslateItemName(viewer, "Call To Arms", ""), Village_TierExists[0] == 5 ? " [Tier 5 Exists]" : Village_TierExists[0] == 4 ? " [Tier 4 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_040), buffer, (!owner || cash < 8000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Press E to activate an ability that gives nearby", ITEMDRAW_DISABLED);
		menu.AddItem("", "players and allies +50% attack speed for a short time.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_020)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Radar Scanner", ""), ITEMDRAW_DISABLED);
			menu.AddItem("", "Provides a stackable 50% to remove", ITEMDRAW_DISABLED);
			menu.AddItem("", "Camo properties from spawning bloons.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [$4000]%s", TranslateItemName(viewer, "Monkey Intelligence Bureau", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_030), buffer, (!owner || cash < 4000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "The Bureau grants special Bloon popping knowledge, allowing", ITEMDRAW_DISABLED);
			menu.AddItem("", "nearby players and allies to deal 10% more damage.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_010)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$750]%s", TranslateItemName(viewer, "Radar Scanner", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_020), buffer, (!owner || cash < 750) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Provides a stackable 20% to remove", ITEMDRAW_DISABLED);
		menu.AddItem("", "Camo properties from spawning bloons.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$250]", TranslateItemName(viewer, "Grow Blocker", ""), Village_TierExists[1] == 5 ? " [Tier 5 Exists]" : Village_TierExists[1] == 4 ? " [Tier 4 Exists]" : Village_TierExists[1] == 3 ? " [Tier 3 Exists]" : Village_TierExists[1] == 2 ? " [Tier 2 Exists]" : Village_TierExists[1] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_010), buffer, (!owner || cash < 250) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Provides a stackable 20% to remove", ITEMDRAW_DISABLED);
		menu.AddItem("", "Regrow properties from spawning bloons.\n ", ITEMDRAW_DISABLED);
	}
	/*
	if(Village_Flags[client] & VILLAGE_005)
	{
		menu.AddItem("", TranslateItemName(viewer, "Monkeyopolis"), ITEMDRAW_DISABLED);
		menu.AddItem("", "Provides extra $2400 for each passive", ITEMDRAW_DISABLED);
		menu.AddItem("", "round that's split among other players.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_004)
	{
		if(Village_TierExists[1] == 5)
		{
			menu.AddItem("", TranslateItemName(viewer, "Monkey City"), ITEMDRAW_DISABLED);
			menu.AddItem("", "Increases influence radius, cash generation from other Monkeyopolis,", ITEMDRAW_DISABLED);
			menu.AddItem("", "and spawns a Rebel every 10 round up to 6 Rebels at once.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [$12000]", TranslateItemName(viewer, "Monkeyopolis"));
			menu.AddItem(VilN(VILLAGE_005), buffer, (!owner || cash < 12000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "Provides extra $2400 for each passive", ITEMDRAW_DISABLED);
			menu.AddItem("", "round that's split among other players.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_003)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$3000]", TranslateItemName(viewer, "Monkey City"));
		menu.AddItem(VilN(VILLAGE_004), buffer, (!owner || cash < 3000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Increases influence radius, cash generation from other Monkeyopolis,", ITEMDRAW_DISABLED);
		menu.AddItem("", "and spawns a Rebel every 10 round up to 6 Rebels at once.\n ", ITEMDRAW_DISABLED);
	}
	else if(Village_Flags[client] & VILLAGE_002)
	{
		if(tier)
		{
			menu.AddItem("", TranslateItemName(viewer, "Monkey Commerce"), ITEMDRAW_DISABLED);
			menu.AddItem("", "An additional 1% discount that can stack with", ITEMDRAW_DISABLED);
			menu.AddItem("", "up to 2 other Villages with this upgrade.\n ", ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%s [$9000]%s", TranslateItemName(viewer, "Monkey Town"), Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : "");
			menu.AddItem(VilN(VILLAGE_003), buffer, (!owner || cash < 9000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			menu.AddItem("", "All players within the radius of the Monkey Town get extra cash per", ITEMDRAW_DISABLED);
			menu.AddItem("", "kill and a stackable (up to 3) increase in cash gained on wave end.\n ", ITEMDRAW_DISABLED);
		}
	}
	else if(Village_Flags[client] & VILLAGE_001)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$1000]", TranslateItemName(viewer, "Monkey Commerce"), Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_002), buffer, (!owner || cash < 1000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "An additional 1% discount that can stack with", ITEMDRAW_DISABLED);
		menu.AddItem("", "up to 2 other Villages with this upgrade.\n ", ITEMDRAW_DISABLED);
	}
	else if(paths < 2)
	{
		FormatEx(buffer, sizeof(buffer), "%s [$1000]", TranslateItemName(viewer, "Monkey Business"), Village_TierExists[2] == 5 ? " [Tier 5 Exists]" : Village_TierExists[2] == 4 ? " [Tier 4 Exists]" : Village_TierExists[2] == 3 ? " [Tier 3 Exists]" : Village_TierExists[2] == 2 ? " [Tier 2 Exists]" : Village_TierExists[2] == 1 ? " [Tier 1 Exists]" : "");
		menu.AddItem(VilN(VILLAGE_001), buffer, (!owner || cash < 1000) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		menu.AddItem("", "Provides a global 2% discount", ITEMDRAW_DISABLED);
		menu.AddItem("", "on items in the main store.\n ", ITEMDRAW_DISABLED);
	}
	*/
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
					CashSpent[client] += 5000;
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
					while((i = FindEntityByClassname(i, "base_boss")) != -1)
					{
						if(i_NpcInternalId[i] == CITIZEN)
							count++;
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_400:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 4);
					CashSpent[client] += 2500;
					Village_TierExists[0] = 4;

					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "base_boss")) != -1)
					{
						if(i_NpcInternalId[i] == CITIZEN)
							count++;
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_300:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 3);
					CashSpent[client] += 800;
					Village_TierExists[0] = 3;

					int count;
					int i = MaxClients + 1;
					while((i = FindEntityByClassname(i, "base_boss")) != -1)
					{
						if(i_NpcInternalId[i] == CITIZEN)
							count++;
					}
					
					if(count < MAX_REBELS_ALLOWED)
						Citizen_SpawnAtPoint(_, client);
				}
				case VILLAGE_200:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 2);
					CashSpent[client] += 1500;
					Village_TierExists[0] = 2;
				}
				case VILLAGE_100:
				{
					Store_SetNamedItem(client, "Village NPC Expert", 1);
					CashSpent[client] += 400;
					CashSpentTotal[client] += 400;
					Village_TierExists[0] = 1;
				}
				case VILLAGE_050:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 5);
					CashSpent[client] += 15000;
					CashSpentTotal[client] += 15000;
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 5;
				}
				case VILLAGE_040:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 4);
					CashSpent[client] += 8000;
					CashSpentTotal[client] += 8000;
					f_BuildingIsNotReady[client] = GetGameTime() + 15.0;
					Village_TierExists[1] = 4;
				}
				case VILLAGE_030:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 3);
					CashSpent[client] += 4000;
					CashSpentTotal[client] += 4000;
					Village_TierExists[1] = 3;
				}
				case VILLAGE_020:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 2);
					CashSpent[client] += 750;
					CashSpentTotal[client] += 750;
					Village_TierExists[1] = 2;
				}
				case VILLAGE_010:
				{
					Store_SetNamedItem(client, "Village Buffing Expert", 1);
					CashSpent[client] += 250;
					CashSpentTotal[client] += 250;
					Village_TierExists[1] = 1;
				}
				case VILLAGE_005:
				{
					Store_SetNamedItem(client, "Village Support Expert", 5);
					CashSpent[client] += 12000;
					CashSpentTotal[client] += 12000;
					Village_TierExists[2] = 5;
				}
				case VILLAGE_004:
				{
					Store_SetNamedItem(client, "Village Support Expert", 4);
					CashSpent[client] += 3000;
					CashSpentTotal[client] += 3000;
					Village_TierExists[2] = 4;
				}
				case VILLAGE_003:
				{
					Store_SetNamedItem(client, "Village Support Expert", 3);
					CashSpent[client] += 9000;
					CashSpentTotal[client] += 9000;
					Village_TierExists[2] = 3;
				}
				case VILLAGE_002:
				{
					Store_SetNamedItem(client, "Village Support Expert", 2);
					CashSpent[client] += 1000;
					CashSpentTotal[client] += 1000;
					Village_TierExists[2] = 2;
				}
				case VILLAGE_001:
				{
					Store_SetNamedItem(client, "Village Support Expert", 1);
					CashSpent[client] += 1000;
					CashSpentTotal[client] += 1000;
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
							Address attrib = TF2Attrib_GetByDefIndex(entity, 101);	// Projectile Range
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 101, TF2Attrib_GetValue(attrib) * 1.1);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 103);	// Projectile Speed
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 103, TF2Attrib_GetValue(attrib) * 1.1);
						}
						case VILLAGE_200:
						{
							Address attrib = TF2Attrib_GetByDefIndex(entity, 6);	// Fire Rate
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(attrib) * 0.97);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 97);	// Reload Time
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 97, TF2Attrib_GetValue(attrib) * 0.97);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 8);	// Heal Rate
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 8, TF2Attrib_GetValue(attrib) * 1.06);
						}
						case VILLAGE_030:
						{
							Address attrib = TF2Attrib_GetByDefIndex(entity, 2);	// Damage
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(attrib) * 1.1);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 410);	// Mage Damage
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 410, TF2Attrib_GetValue(attrib) * 1.1);
						}
						case VILLAGE_040, VILLAGE_050:
						{
							Address attrib = TF2Attrib_GetByDefIndex(entity, 6);	// Fire Rate
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(attrib) * 0.75);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 97);	// Reload Time
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 97, TF2Attrib_GetValue(attrib) * 0.75);
							
							attrib = TF2Attrib_GetByDefIndex(entity, 8);	// Heal Rate
							if(attrib != Address_Null)
								TF2Attrib_SetByDefIndex(entity, 8, TF2Attrib_GetValue(attrib) * 1.5);
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
						Address attrib = TF2Attrib_GetByDefIndex(entity, 101);	// Projectile Range
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 101, TF2Attrib_GetValue(attrib) / 1.1);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 103);	// Projectile Speed
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 103, TF2Attrib_GetValue(attrib) / 1.1);
					}
					case VILLAGE_200:
					{
						Address attrib = TF2Attrib_GetByDefIndex(entity, 6);	// Fire Rate
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(attrib) / 0.97);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 97);	// Reload Time
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 97, TF2Attrib_GetValue(attrib) / 0.97);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 8);	// Heal Rate
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 8, TF2Attrib_GetValue(attrib) / 1.06);
					}
					case VILLAGE_030:
					{
						Address attrib = TF2Attrib_GetByDefIndex(entity, 2);	// Damage
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(attrib)/ 1.1);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 410);	// Mage Damage
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 410, TF2Attrib_GetValue(attrib) / 1.1);
					}
					case VILLAGE_040, VILLAGE_050:	// 1.0 * 1.5 / 1.5
					{
						Address attrib = TF2Attrib_GetByDefIndex(entity, 6);	// Fire Rate
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 6, TF2Attrib_GetValue(attrib) / 0.75);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 97);	// Reload Time
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 97, TF2Attrib_GetValue(attrib) / 0.75);
						
						attrib = TF2Attrib_GetByDefIndex(entity, 8);	// Heal Rate
						if(attrib != Address_Null)
							TF2Attrib_SetByDefIndex(entity, 8, TF2Attrib_GetValue(attrib) / 1.5);
					}
				}
			}
		}
	}
	else if(i_NpcInternalId[entity] == CITIZEN)
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
							npc.m_fGunFirerate *= 0.95;
							npc.m_fGunReload *= 0.95;
						}
						case VILLAGE_300:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip++;
							
							npc.m_fGunRangeBonus *= 1.1;
						}
						case VILLAGE_400:
						{
							if(npc.m_iGunValue < 500)
								npc.m_iGunValue = 500;
							
							npc.m_fGunFirerate *= 0.9;
							npc.m_fGunReload *= 0.9;
						}
						case VILLAGE_500:
						{
					//		if(npc.m_iGunClip > 0)
					//			npc.m_iGunClip += 2;
							
							if(npc.m_iGunValue < 1000)
								npc.m_iGunValue = 1000;
							
							npc.m_fGunRangeBonus *= 1.3;
							npc.m_fGunFirerate *= 0.7;
							npc.m_fGunReload *= 0.7;
						}
						case VILLAGE_030:
						{
							npc.m_fGunRangeBonus *= 1.1;
						}
						case VILLAGE_040:
						{
							npc.m_fGunFirerate *= 0.75;
							npc.m_fGunReload *= 0.75;
						}
						case VILLAGE_050:
						{
							npc.m_fGunFirerate *= 0.75;
							npc.m_fGunReload *= 0.75;
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
						npc.m_fGunFirerate /= 0.95;
						npc.m_fGunReload /= 0.95;
					}
					case VILLAGE_300:
					{
						if(npc.m_iGunClip > 1)
							npc.m_iGunClip--;
						
						npc.m_fGunRangeBonus /= 1.1;
					}
					case VILLAGE_400:
					{
						npc.m_fGunFirerate /= 0.9;
						npc.m_fGunReload /= 0.9;
					}
					case VILLAGE_500:
					{
						if(npc.m_iGunClip > 2)
							npc.m_iGunClip -= 2;
						
						npc.m_fGunRangeBonus /= 1.3;
						npc.m_fGunFirerate /= 0.7;
						npc.m_fGunReload /= 0.7;
					}
					case VILLAGE_030:
					{
						npc.m_fGunRangeBonus /= 1.1;
					}
					case VILLAGE_040:
					{
						npc.m_fGunFirerate /= 0.75;
						npc.m_fGunReload /= 0.75;
					}
					case VILLAGE_050:
					{
						npc.m_fGunFirerate /= 0.75;
						npc.m_fGunReload /= 0.75;
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
								npc.BonusFireRate *= 0.95;
							}
							case VILLAGE_030:
							{
								npc.BonusDamageBonus *= 1.1;
							}
							case VILLAGE_040:
							{
								npc.BonusFireRate *= 0.75;
							}
							case VILLAGE_050:
							{
								npc.BonusFireRate *= 0.75;
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
							npc.BonusDamageBonus /= 1.1;
						}
						case VILLAGE_040:
						{
							npc.BonusFireRate /= 0.75;
						}
						case VILLAGE_050:
						{
							npc.BonusFireRate /= 0.75;
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

public MRESReturn Dhook_FinishedBuilding_Post(int Building_Index, Handle hParams) 
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
		}
		case BuildingBarricade:
		{
			npc.bBuildingIsPlaced = true;
			Building_Constructed[Building_Index] = true;
			SetEntityModel(Building_Index, BARRICADE_MODEL);
		}
		case BuildingRailgun:
		{
			npc.bBuildingIsPlaced = true;
			Building_Constructed[Building_Index] = true;
			SetEntityModel(Building_Index, CUSTOM_SENTRYGUN_MODEL);
			/*
			static const float minbounds[3] = {-15.0, -15.0, 0.0};
			static const float maxbounds[3] = {15.0, 15.0, 40.0};
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);
			npc.UpdateCollisionBox();	
			*/

		}
		case BuildingMortar:
		{
			npc.bBuildingIsPlaced = true;
			Building_Constructed[Building_Index] = true;
			
			SetEntityModel(Building_Index, CUSTOM_SENTRYGUN_MODEL);
			/*
			static const float minbounds[3] = {-15.0, -15.0, 0.0};
			static const float maxbounds[3] = {15.0, 15.0, 80.0};
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMins", minbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxs", maxbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMinsPreScaled", minbounds);
			SetEntPropVector(Building_Index, Prop_Send, "m_vecMaxsPreScaled", maxbounds);
			
			npc.UpdateCollisionBox();	
			*/

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
					DispatchKeyValue(prop1, "model", SUMMONER_MODEL);
					DispatchKeyValue(prop1, "modelscale", "0.15");
					DispatchKeyValue(prop1, "StartDisabled", "false");
					DispatchKeyValue(prop1, "Solid", "0");
					SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
					DispatchSpawn(prop1);
					SetEntityCollisionGroup(prop1, 1);
					AcceptEntityInput(prop1, "DisableShadow");
					AcceptEntityInput(prop1, "DisableCollision");
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
					DispatchKeyValue(prop1, "model", HEALING_STATION_MODEL);
					DispatchKeyValue(prop1, "modelscale", "0.70");
					DispatchKeyValue(prop1, "StartDisabled", "false");
					DispatchKeyValue(prop1, "Solid", "0");
					SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
					DispatchSpawn(prop1);
					SetEntityCollisionGroup(prop1, 1);
					AcceptEntityInput(prop1, "DisableShadow");
					AcceptEntityInput(prop1, "DisableCollision");
					Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
					Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
					SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
					SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
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
					DispatchKeyValue(prop2, "model", HEALING_STATION_MODEL);
					DispatchKeyValue(prop2, "modelscale", "0.70");
					DispatchKeyValue(prop2, "StartDisabled", "false");
					DispatchKeyValue(prop2, "Solid", "0");
					SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
					DispatchSpawn(prop2);
					SetEntityCollisionGroup(prop2, 1);
					AcceptEntityInput(prop2, "DisableShadow");
					AcceptEntityInput(prop2, "DisableCollision");
					Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
					Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
					SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
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
					Building_Hidden_Prop[Building_Index][0] = EntIndexToEntRef(prop1);
					Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(Building_Index);
					SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
					SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
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
					Building_Hidden_Prop[Building_Index][1] = EntIndexToEntRef(prop2);
					Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(Building_Index);
					SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

					GetEntPropVector(Building_Index, Prop_Data, "m_vecAbsOrigin", vOrigin);
					GetEntPropVector(Building_Index, Prop_Data, "m_angRotation", vAngles);
					TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
					SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
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
	}
	int client = GetEntPropEnt(Building_Index, Prop_Send, "m_hBuilder");
	if(IsValidClient(client)) //Make sure that they dont trigger the building once its done and dont get stuck like idiotas
	{
		SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
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

static float WoodAmount[MAXTF2PLAYERS];
static float FoodAmount[MAXTF2PLAYERS];
static float GoldAmount[MAXTF2PLAYERS];
static int SupplyRate[MAXTF2PLAYERS];
static int RepairCount[MAXTF2PLAYERS];
static int InMenu[MAXTF2PLAYERS];
static float TrainingStartedIn[MAXTF2PLAYERS];
static float TrainingIn[MAXTF2PLAYERS];
static int TrainingIndex[MAXTF2PLAYERS];
static int TrainingQueue[MAXTF2PLAYERS];
static int CommandMode[MAXTF2PLAYERS];
static bool MedievalUnlock[MAXTF2PLAYERS];

enum
{
	NPCIndex = 0,
	WoodCost,
	FoodCost,
	GoldCost,
	TrainTime,
	TrainLevel
}

static const char CommandName[][] =
{
	"Command: Defensive",
	"Command: Aggressive",
	"Command: Retreat"
};

/*
	None - 1.0/s
	Repair Handling book for dummies - 1.5/s
	Ikea Repair Handling book - 2.5/s
	Engineering Repair Handling book - 4.5/s
	Alien Repair Handling book - 10.5/s
	Cosmic Repair Handling book - 20.5/s
*/

static const int SummonerData[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level
	{ BARRACK_MILITIA, 5, 30, 0, 5, 1 },		// None

	{ BARRACK_ARCHER, 50, 10, 0, 7, 2 },		// Construction Novice
	{ BARRACK_MAN_AT_ARMS, 10, 50, 0, 6, 3 },	// Construction Novice & Ikea Repair Handling book

	{ BARRACK_CROSSBOW, 90, 20, 0, 8, 5 },		// Construction Apprentice & Ikea Repair Handling book
	{ BARRACK_SWORDSMAN, 20, 90, 0, 7, 6 },		// Construction Apprentice & Engineering Repair Handling book

	{ BARRACK_ARBELAST, 210, 50, 0, 9, 9 },		// Construction Worker & Engineering Repair Handling book
	{ BARRACK_TWOHANDED, 50, 210, 0, 8, 12 },	// Construction Expert & Ikea Repair Handling book

	{ BARRACK_LONGBOW, 400, 100, 0, 10, 15 },	// Construction Expert & Cosmic Repair Handling book
	{ BARRACK_CHAMPION, 100, 400, 0, 9, 16 },	// Construction Master


	{ BARRACK_MONK, 210, 0, 50, 10, 10 },		// Construction Worker
	{ BARRACK_HUSSAR, 0, 400, 100, 10, 20 }		// Construction Master & Cosmic Repair Handling book
};

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
	WoodAmount[client] = 0.0;
	FoodAmount[client] = 0.0;
	GoldAmount[client] = 0.0;
	TrainingIn[client] = 0.0;
	CommandMode[client] = 0;
	TrainingQueue[client] = -1;
	
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	DataPack pack;
	CreateDataTimer(0.1, Timer_SummonerThink, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(entity);
	i_WhatBuilding[entity] = BuildingSummoner;
	
	SetEntProp(entity, Prop_Send, "m_bMiniBuilding", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.15);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	Building_Max_Health[entity] = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
	SetEntPropString(entity, Prop_Data, "m_iName", "zr_summoner");
	Building_cannot_be_repaired[entity] = true;
	Is_Elevator[entity] = false;
	Building_Sentry_Cooldown[client] = GetGameTime() + 60.0;
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	Building_Collect_Cooldown[entity][0] = 0.0;
	
	if(!EscapeMode)
	{
		return true;
	}
	else
	{
		return false;
	}
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
		else if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") == 1.0)
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
				
				SetEntityModel(entity, SUMMONER_MODEL);
				
				static const float minbounds[3] = {-20.0, -20.0, 0.0};
				static const float maxbounds[3] = {20.0, 20.0, 30.0};
				SetEntPropVector(entity, Prop_Send, "m_vecMins", minbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", minbounds);
				SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxbounds);

				view_as<CClotBody>(entity).UpdateCollisionBox();			
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
		// 1 Supply = 1 Food Every 2 Seconds, 1 Wood Every 4 Seconds
		WoodAmount[owner] += SupplyRate[owner] / 40.0;
		FoodAmount[owner] += SupplyRate[owner] / 20.0;

		// 1 Supply = 1 Gold Every 30 Seconds
		if(MedievalUnlock[owner])
			GoldAmount[owner] += SupplyRate[owner] / 300.0;

		if(TrainingIn[owner])
		{
			if(!AtMaxSupply(owner))
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
						
						view_as<BarrackBody>(entity).PlaySpawnSound();
						Npc_Create(SummonerData[TrainingIndex[owner]][NPCIndex], owner, pos, ang, true);

						if(TrainingQueue[owner] != -1)
						{
							TrainingIndex[owner] = TrainingQueue[owner];
							TrainingStartedIn[owner] = GetGameTime();
							TrainingIn[owner] = TrainingStartedIn[owner] + float(SummonerData[TrainingQueue[owner]][TrainTime]);
							TrainingQueue[owner] = -1;
						}
					}
					else
					{
						TrainingIn[owner] = gameTime + 0.1;
						TrainingStartedIn[owner] = -1.0;
					}
				}
				else
				{
					int required = RoundFloat((TrainingIn[owner] - TrainingStartedIn[owner]) * 2.0);
					int current = required - RoundToCeil((TrainingIn[owner] - gameTime) * 2.0);
					
					SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", current);
					SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", required);
				}
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

static void CheckSummonerUpgrades(int client)
{
	RepairCount[client] = 0;
	SupplyRate[client] = 2;

	if(Store_HasNamedItem(client, "Repair Handling book for dummies"))
	{
		//RepairCount[client]++;
		SupplyRate[client]++;
	}
	
	if(Store_HasNamedItem(client, "Ikea Repair Handling book"))
	{
		RepairCount[client]++;
		SupplyRate[client] += 2;
	}
	
	if(Store_HasNamedItem(client, "Engineering Repair Handling book"))
	{
		RepairCount[client]++;
		SupplyRate[client] += 4;
	}
	
	if(Store_HasNamedItem(client, "Alien Repair Handling book"))
	{
		RepairCount[client]++;
		SupplyRate[client] += 6;
	}
	
	if(Store_HasNamedItem(client, "Cosmic Repair Handling book"))
	{
		RepairCount[client]++;
		SupplyRate[client] += 10;
	}

	MedievalUnlock[client] = view_as<bool>(HasNamedItem(client, "Medieval Crown"));
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
	int level = MaxSupportBuildingsAllowed(client, true);
	
	Menu menu = new Menu(SummonerMenuH);
	
	SetGlobalTransTarget(viewer);
	menu.SetTitle("%t\n \n%s\n \n$%d £%d ¥%d\n ", "TF2: Zombie Riot", TranslateItemName(viewer, "Buildable Barracks", ""), RoundToFloor(WoodAmount[client]), RoundToFloor(FoodAmount[client]), RoundToFloor(GoldAmount[client]));
	
	menu.AddItem(NULL_STRING, CommandName[CommandMode[client]], owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	char buffer1[256];
	if(TrainingIn[client])
	{
		if(AtMaxSupply(client))
		{
			FormatEx(buffer1, sizeof(buffer1), "Training %t... (At Maximum Supply)\n ", NPC_Names[SummonerData[TrainingIndex[client]][NPCIndex]]);
			if(i_BarricadesBuild[client])
				Format(buffer1, sizeof(buffer1), "%s\nTIP: Your barricades counts towards the supply limit\n ", buffer1);
		}
		else if(TrainingStartedIn[client] < 0.0)
		{
			FormatEx(buffer1, sizeof(buffer1), "Training %t... (Spaced Occupied)\n ", NPC_Names[SummonerData[TrainingIndex[client]][NPCIndex]]);
		}
		else
		{
			float gameTime = GetGameTime();
			FormatEx(buffer1, sizeof(buffer1), "Training %t... (%.0f%%)\n ", NPC_Names[SummonerData[TrainingIndex[client]][NPCIndex]],
				100.0 - ((TrainingIn[client] - gameTime) * 100.0 / (TrainingIn[client] - TrainingStartedIn[client])));
		}

		if(TrainingQueue[client] != -1)
			Format(buffer1, sizeof(buffer1), "%sNext: %t\n ", buffer1, NPC_Names[SummonerData[TrainingQueue[client]][NPCIndex]]);
		
		menu.AddItem(buffer1, buffer1, owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else
	{
		menu.AddItem(buffer1, "\n ", owner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	char buffer2[64];
	int options;
	for(int i = sizeof(SummonerData) - 1; i >= 0; i--)
	{
		if(SummonerData[i][TrainLevel] > level)
			continue;
		
		FormatEx(buffer2, sizeof(buffer2), "%s Desc", NPC_Names[SummonerData[i][NPCIndex]]);
		FormatEx(buffer1, sizeof(buffer1), "%t [", NPC_Names[SummonerData[i][NPCIndex]]);

		if(SummonerData[i][WoodCost])
			Format(buffer1, sizeof(buffer1), "%s $%d", buffer1, SummonerData[i][WoodCost]);
		
		if(SummonerData[i][FoodCost])
			Format(buffer1, sizeof(buffer1), "%s £%d", buffer1, SummonerData[i][FoodCost]);
		
		if(SummonerData[i][GoldCost])
			Format(buffer1, sizeof(buffer1), "%s ¥%d", buffer1, SummonerData[i][GoldCost]);
		
		Format(buffer1, sizeof(buffer1), "%s ]\n%t\n ", buffer1, buffer2);
		IntToString(i, buffer2, sizeof(buffer2));
		bool poor = (!owner || WoodAmount[client] < SummonerData[i][WoodCost]) || (FoodAmount[client] < SummonerData[i][FoodCost]) || (GoldAmount[client] < SummonerData[i][GoldCost]);

		menu.AddItem(buffer2, buffer1, poor ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		if(++options > 3)
			break;
	}

	menu.Pagination = 0;
	menu.ExitButton = true;
	if(menu.Display(viewer, 1))
		InMenu[viewer] = client;
}

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
			InMenu[client] = 0;
		}
		case MenuAction_Select:
		{
			if(choice)
			{
				int entity = EntRefToEntIndex(i_HasSentryGunAlive[client]);
				if(entity != INVALID_ENT_REFERENCE)
				{
					if(choice == 1)
					{
						if(TrainingQueue[client] != -1)
						{
							WoodAmount[client] += float(SummonerData[TrainingQueue[client]][WoodCost]);
							FoodAmount[client] += float(SummonerData[TrainingQueue[client]][FoodCost]);
							GoldAmount[client] += float(SummonerData[TrainingQueue[client]][GoldCost]);

							TrainingQueue[client] = -1;
						}
						else if(TrainingIn[client])
						{
							TrainingIn[client] = 0.0;

							WoodAmount[client] += float(SummonerData[TrainingIndex[client]][WoodCost]);
							FoodAmount[client] += float(SummonerData[TrainingIndex[client]][FoodCost]);
							GoldAmount[client] += float(SummonerData[TrainingIndex[client]][GoldCost]);
						}
					}
					else
					{
						char num[16];
						menu.GetItem(choice, num, sizeof(num));
						int item = StringToInt(num);

						float woodcost = float(SummonerData[item][WoodCost]);
						float foodcost = float(SummonerData[item][FoodCost]);
						float goldcost = float(SummonerData[item][GoldCost]);

						if(WoodAmount[client] >= woodcost && FoodAmount[client] >= foodcost && GoldAmount[client] >= goldcost)
						{
							if(!TrainingIn[client])
							{
								TrainingIndex[client] = item;
								TrainingStartedIn[client] = GetGameTime();
								TrainingIn[client] = TrainingStartedIn[client] + float(SummonerData[item][TrainTime]);
							}
							else if(TrainingQueue[client] == -1)
							{
								TrainingQueue[client] = item;
							}
							else
							{
								WoodAmount[client] += float(SummonerData[TrainingQueue[client]][WoodCost]);
								FoodAmount[client] += float(SummonerData[TrainingQueue[client]][FoodCost]);
								GoldAmount[client] += float(SummonerData[TrainingQueue[client]][GoldCost]);

								TrainingQueue[client] = item;
							}
							
							WoodAmount[client] -= woodcost;
							FoodAmount[client] -= foodcost;
							GoldAmount[client] -= goldcost;
						}
					}

					SummonerMenu(client, client);
				}
			}
			else
			{
				if(++CommandMode[client] >= sizeof(CommandName))
					CommandMode[client] = 0;
				
				SummonerMenu(client, client);
			}
		}
	}
	return 0;
}

static bool AtMaxSupply(int client)
{
	int userid = GetClientUserId(client);
	int personal = i_BarricadesBuild[client];
	int global;
	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "base_boss")) != -1)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2)
		{
			global++;

			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId == userid)
				personal++;
		}
	}

	return (global > 9 || personal > 2);
}