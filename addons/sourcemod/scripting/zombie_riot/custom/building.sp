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

#define BUILDINGCOLLISIONNUMBER	27
//static int gLaser1;

static int Beam_Laser;
static int Beam_Glow;

int i_HasMarker[MAXTF2PLAYERS];

float f_MarkerPosition[MAXTF2PLAYERS][3];

float f_BuildingIsNotReady[MAXTF2PLAYERS];

static Handle h_Pickup_Building[MAXPLAYERS + 1];

void Building_MapStart()
{
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
	
	PrecacheModel("models/items/ammocrate_rockets.mdl");
	PrecacheModel("models/props_manor/table_01.mdl");
	PrecacheModel(PERKMACHINE_MODEL);
	
	PrecacheModel(PACKAPUNCH_MODEL);
	PrecacheModel(HEALING_STATION_MODEL);
}

static int Building_Repair_Health[MAXENTITIES]={0, ...};
static int Building_Max_Health[MAXENTITIES]={0, ...};

static int i_HasSentryGunAlive[MAXTF2PLAYERS]={-1, ...};

static bool Building_cannot_be_repaired[MAXENTITIES]={false, ...};

static bool Building_Constructed[MAXENTITIES]={false, ...};

static float Building_Collect_Cooldown[MAXENTITIES][MAXTF2PLAYERS];
static float Building_Sentry_Cooldown[MAXTF2PLAYERS];

static int i_MachineJustClickedOn[MAXTF2PLAYERS];

public void Building_ClearAll()
{
	Zero2(Building_Collect_Cooldown);
	Zero(Building_Sentry_Cooldown);
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
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, Building_Sentry, TFObject_Sentry);
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
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, Building_Mortar, TFObject_Sentry);
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
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, Building_HealingStation, TFObject_Sentry);
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
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
		else
		{
			PlaceBuilding(client, Building_Railgun, TFObject_Sentry);
		}
	}
	return Plugin_Continue;
}

public Action Building_PlaceDispenser(int client, int weapon, const char[] classname, bool &result)
{
	if(i_BarricadesBuild[client] < MaxBarricadesAllowed(client))
	{
		PlaceBuilding(client, Building_DispenserWall, TFObject_Dispenser);
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
		PlaceBuilding(client, Building_DispenserElevator, TFObject_Dispenser);
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
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client))
	{
		PlaceBuilding(client, Building_AmmoBox, TFObject_Dispenser);
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
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client))
	{
		PlaceBuilding(client, Building_ArmorTable, TFObject_Dispenser);
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
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client))
	{
		PlaceBuilding(client, Building_PerkMachine, TFObject_Dispenser);
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
	if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client))
	{
		PlaceBuilding(client, Building_PackAPunch, TFObject_Dispenser);
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
	i_HasSentryGunAlive[client] = EntIndexToEntRef(entity);
	b_SentryIsCustom[entity] = true;
//	SetEntProp(entity, Prop_Send, "m_bCarried", true);
	Building_Constructed[entity] = false;
	CreateTimer(0.2, Building_Set_HP_Colour_Sentry, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.1, Timer_DroppedBuildingWaitHealingStation, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT); //No custom anims
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
	b_SentryIsCustom[entity] = false;
	i_BarricadesBuild[client] += 1;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.2, Building_Set_HP_Colour, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	DataPack pack;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitWall, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(client); //Need original client index id please.
	
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
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
//	CreateTimer(0.2, Building_Set_HP_Elevator, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(0.5, Timer_DroppedBuildingWait, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
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
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 255, 255, 255, 60);
	SDKHook(entity, SDKHook_OnTakeDamage, Building_TakeDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, Building_TakeDamagePost);
	SDKHook(entity, SDKHook_Touch, Block_All_Touch);
	return false;
}

public bool Building_AmmoBox(int client, int entity)
{
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	i_SupportBuildingsBuild[client] += 1;
	DataPack pack;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitAmmobox, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(client); //Need original client index id please.
	
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
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	i_SupportBuildingsBuild[client] += 1;
	DataPack pack;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitArmorTable, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(client); //Need original client index id please.
	
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
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	i_SupportBuildingsBuild[client] += 1;
	DataPack pack;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitPerkMachine, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(client); //Need original client index id please.
	
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
	b_SentryIsCustom[entity] = false;
	CreateTimer(0.5, Building_TimerDisableDispenser, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	i_SupportBuildingsBuild[client] += 1;
	DataPack pack;
	CreateDataTimer(0.5, Timer_DroppedBuildingWaitPackAPunch, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(client); //Need original client index id please.
	
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
	
	if(damagetype & DMG_BLAST)
	{
		damage *= 3.0; //OTHERWISE EXPLOSIVES ARE EXTREAMLY WEAK!!
	}
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
	return Plugin_Changed;
}

public Action Building_Set_HP_Colour(Handle dashHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
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
		}
		else
		{
			SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
			int red = 0;
			int green = 0;
			int blue = 0;
			
			SetEntityRenderColor(entity, red, green, blue, 255);
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
			SetEntityRenderColor(entity, 255, 255, 255, 60);
			SetEntityCollisionGroup(entity, BUILDINGCOLLISIONNUMBER);
		}
		else
		{
			SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
			int red = 0;
			int green = 0;
			int blue = 0;
			SetEntityRenderColor(entity, red, green, blue, 60);
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
//static float GrabAt[MAXTF2PLAYERS];
//static int GrabRef[MAXTF2PLAYERS] = {INVALID_ENT_REFERENCE, ...};

void Building_WeaponSwitchPost(int client, int &weapon, const char[] buffer)
{
	if(EntityFuncAttack[weapon] && EntityFuncAttack[weapon]!=INVALID_FUNCTION)
	{
		Function func = EntityFuncAttack[weapon];
		if(func == Building_PlaceHealingStation || func == Building_PlacePackAPunch || func == Building_PlacePerkMachine || func==Building_PlaceRailgun || func==Building_PlaceMortar || func==Building_PlaceSentry || func==Building_PlaceDispenser || func==Building_PlaceAmmoBox || func==Building_PlaceArmorTable || func==Building_PlaceElevator)
		{
			if(Building[client] != INVALID_FUNCTION)
			{
				Building[client] = INVALID_FUNCTION;
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
		int entity = GetClientPointVisible(client);
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
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	
	if(IsValidClient(client))
	{
		b_Doing_Buildingpickup_Handle[client] = false;
		PrintCenterText(client, " ");
		if (IsValidEntity(entity))
		{
			int looking_at = GetClientPointVisible(client);
			if (looking_at == entity)
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)) && !StrContains(buffer, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
				{
					CClotBody npc = view_as<CClotBody>(entity);
					npc.bBuildingIsPlaced = false;
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
				}			
			}
		}
	}
	return Plugin_Handled;	
}
		
void Building_ShowInteractionHud(int client, int entity)
{
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
					for(int i; i<6; i++)
					{
						if(weapon == GetPlayerWeaponSlot(client, i))
						{
							int index = Store_GetEquipped(client, i);
							int number_return = Store_CheckMoneyForPap(client, index);
							if(number_return > 0)
							{
								PrintCenterText(client, "%t", "PackAPunch Tooltip",number_return);	
							}
							else
							{
								PrintCenterText(client, "%t", "Cannot Pap this");	
							}
							break;
						}
					}
					Hide_Hud = false;
					//Unused for now, will have extra code saying how much it costs and stuff.
				}
			}
		}
		else if(StrEqual(buffer, "base_boss"))
		{
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
						PrintCenterText(client, "%t", "Ammobox Tooltip");						
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
						PrintCenterText(client, "%t", "Armortable Tooltip");						
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
					for(int i; i<6; i++)
					{
						if(weapon == GetPlayerWeaponSlot(client, i))
						{
							int index = Store_GetEquipped(client, i);
							int number_return = Store_CheckMoneyForPap(client, index);
							if(number_return > 0)
							{
								PrintCenterText(client, "%t", "PackAPunch Tooltip",number_return);	
							}
							else
							{
								PrintCenterText(client, "%t", "Cannot Pap this");	
							}
							break;
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
	

	/*
	static char buffer[36];
	if(!Is_Reload_Button && GrabRef[client] == INVALID_ENT_REFERENCE && !StrContains(classname, "obj_") && GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon > MaxClients && GetEntityClassname(weapon, buffer, sizeof(buffer)) && (StrEqual(buffer, "tf_weapon_wrench") || StrEqual(buffer, "tf_weapon_robot_arm")))
		{
			GrabAt[client] = GetGameTime()+1.0; //Make building pickup a bit faster, was 1.5 before, 1.0 is good
	//		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			PrintCenterText(client, "%t", "Picking Up Building");
	//		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Picking Up Building");
		}
	}
	*/
	if(IsValidEntity(entity))
	{
		bool bInteractedBuildingWasMounted = false;
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
			bInteractedBuildingWasMounted = true;
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
				owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
				buildingType = 7;
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
						if(i_SupportBuildingsBuild[client] < MaxSupportBuildingsAllowed(client) && (StrEqual(buffer, "zr_ammobox") || StrEqual(buffer, "zr_armortable") || StrEqual(buffer, "zr_perkmachine") || StrEqual(buffer, "zr_packapunch")))
						{
							DataPack pack;
							CreateDataTimer(0.5, Timer_ClaimedBuildingremoveSupportCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(client); //Need original client index id please.
							i_SupportBuildingsBuild[client] += 1;
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);
							SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
						}
						else if(StrEqual(buffer, "zr_barricade")) // do not check for if too many barricades, doesnt make sense to do this anyways.
						{
							DataPack pack;
							CreateDataTimer(0.5, Timer_ClaimedBuildingremoveBarricadeCounterOnDeath, pack, TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(entity));
							pack.WriteCell(client); //Need original client index id please.
							i_BarricadesBuild[client] += 1;
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", -1);
							AcceptEntityInput(entity, "SetBuilder", client);
							SetEntPropEnt(entity, Prop_Send, "m_hBuilder", client);		
							SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);							
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							PrintToChat(client,"You cannot build anymore Support buildings, you have reached the max amount.\nBuy Builder Upgrades to build more.");
						}
						return true;
					}
					else if(!b_IgnoreWarningForReloadBuidling[client])
					{
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");	
						return true;			
					}
				}
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
			bInteractedBuildingWasMounted = true;
			buildingType = Citizen_BuildingInteract(entity);
		}
		
		if(buildingType)
		{
			if(!Is_Reload_Button && !b_IgnoreWarningForReloadBuidling[client])
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t","Object Cooldown",Building_Picking_up_cd);
				return true;
			}
			
			switch(buildingType)
			{
				case 7:
				{
					Building_Collect_Cooldown[entity][client] = GetGameTime() + 75.0;
					ClientCommand(client, "playgamesound items/smallmedkit1.wav");
					StartHealingTimer(client, 0.1, 1, 30);
					if(owner != -1 && i_Healing_station_money_limit[owner][client] <= 3)
					{
						if(owner != client)
						{
							i_Healing_station_money_limit[owner][client] += 1;
							Resupplies_Supplied[owner] += 2;
							CashSpent[owner] -= 20;
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
							SetGlobalTransTarget(owner);
							ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Healing Station Used");
						}
					}
				}
				case 2:
				{
						if(Ammo_Count_Ready[client] > 0)
						{
							int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
							if(IsValidEntity(weapon))
							{
								if(IsWandWeapon(weapon))
								{
									float max_mana_temp = 1200.0;
									float mana_regen_temp = 100.0;
											
									if(i_CurrentEquippedPerk[client] == 4)
									{
										mana_regen_temp *= 1.35;
									}
									
									if(Mana_Regen_Level[weapon])
									{			
										mana_regen_temp *= Mana_Regen_Level[weapon];
										max_mana_temp *= Mana_Regen_Level[weapon];	
									}
									/*
									Current_Mana[client] += RoundToCeil(mana_regen[client]);
										
									if(Current_Mana[client] < RoundToCeil(max_mana[client]))
										Current_Mana[client] = RoundToCeil(max_mana[client]);
									*/
									
									if(Current_Mana[client] < RoundToCeil(max_mana_temp))
									{
										Ammo_Count_Ready[client] -= 1;
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										if(Current_Mana[client] < RoundToCeil(max_mana_temp))
										{
											Current_Mana[client] += RoundToCeil(mana_regen_temp);
											
											if(Current_Mana[client] > RoundToCeil(max_mana_temp)) //Should only apply during actual regen
												Current_Mana[client] = RoundToCeil(max_mana_temp);
										}
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
										Mana_Hud_Delay[client] = 0.0;
									}
									else
									{
										ClientCommand(client, "playgamesound items/medshotno1.wav");
										SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
										Ammo_Count_Ready[client] -= 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if (weaponindex == 305)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 21, GetAmmo(client, 21)+(AmmoData[21][1]*2));
										Ammo_Count_Ready[client] -= 1;
										SetAmmo(client, 14, GetAmmo(client, 14)+(AmmoData[14][1]*2));
										//Yeah extra ammo, do i care ? no.
										
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}								
									}
									else if(weaponindex == 411)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 22, GetAmmo(client, 22)+(AmmoData[22][1]*2));
										Ammo_Count_Ready[client] -= 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 441 || weaponindex == 35)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 23, GetAmmo(client, 23)+(AmmoData[23][1]*2));
										Ammo_Count_Ready[client] -= 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}		
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(weaponindex == 998)
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, 3, GetAmmo(client, 3)+(AmmoData[3][1]*2));
										Ammo_Count_Ready[client] -= 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}	
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
										}
									}
									else if(Ammo_type != -1 && Ammo_type < Ammo_Hand_Grenade) //Disallow Ammo_Hand_Grenade, that ammo type is regenerative!, dont use jar, tf2 needs jar? idk, wierdshit.
									{
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										ClientCommand(client, "playgamesound items/ammo_pickup.wav");
										SetAmmo(client, Ammo_type, GetAmmo(client, Ammo_type)+(AmmoData[Ammo_type][1]*2));
										Ammo_Count_Ready[client] -= 1;
										for(int i; i<Ammo_MAX; i++)
										{
											CurrentAmmo[client][i] = GetAmmo(client, i);
										}
										Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
										if(owner != -1 && owner != client)
										{
											Resupplies_Supplied[owner] += 2;
											CashSpent[owner] -= 20;
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
											Building_Collect_Cooldown[entity][client] = GetGameTime() + 5.0;
											if(owner != -1 && owner != client)
											{
												Resupplies_Supplied[owner] += 2;
												CashSpent[owner] -= 20;
												SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
												SetGlobalTransTarget(owner);
												ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Ammo Box Used");
											}
											Ammo_Count_Ready[client] -= 1;
											
											ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
										}
										else
										{
											ClientCommand(client, "playgamesound items/medshotno1.wav");
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
						//	CashSpent[owner] -= 20;
							if(owner != -1 && owner != client)
							{
								if(Armor_table_money_limit[owner][client] <= 15)
								{
									CashSpent[owner] -= 40;
									Armor_table_money_limit[owner][client] += 1;
									Resupplies_Supplied[owner] += 4;
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
									SetGlobalTransTarget(owner);
									ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Armor Table Used");
								}
							}
							
							ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");				
						}
				}
				case 6:
				{
						if(Is_Reload_Button)
						{
							if(bInteractedBuildingWasMounted)
							{
								i_MachineJustClickedOn[client] = EntIndexToEntRef(entity);
								
								Menu menu2 = new Menu(Building_ConfirmMountedAction);
								menu2.SetTitle("%t", "Want to Pack a punch?");
												
								FormatEx(buffer, sizeof(buffer), "%t", "Yes");
								menu2.AddItem("-1", buffer);
												
								FormatEx(buffer, sizeof(buffer), "%t", "No");
								menu2.AddItem("-2", buffer);
												
								menu2.Display(client, MENU_TIME_FOREVER); // they have 3 seconds.
							}
							else
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
													SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
													SetGlobalTransTarget(owner);
													ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Pap Machine Used");
												}
											}
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(client);
											ShowSyncHudText(client,  SyncHud_Notifaction, "Your weapon was boosted");
											Store_ApplyAttribs(client);
											Store_GiveAll(client, GetClientHealth(client));
										}
										else if(number_return == 2)
										{
											ClientCommand(client, "playgamesound items/medshotno1.wav");
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(client);
											ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Money To Pap");	
										}
										else if(number_return == 1)
										{
											ClientCommand(client, "playgamesound items/medshotno1.wav");
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
						else if(!b_IgnoreWarningForReloadBuidling[client])
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
							SetGlobalTransTarget(client);
							ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Reload to Interact");				
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
				Store_ConsumeItem(client, TFWeaponSlot_Grenade);
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				Building[client] = INVALID_FUNCTION;
			}
		}
	}
	return Plugin_Stop;
}
static void PlaceBuilding(int client, Function callback, TFObjectType type, TFObjectMode mode=TFObjectMode_None)
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
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_ClaimedBuildingremoveBarricadeCounterOnDeath(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_BarricadesBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitAmmobox(Handle htimer,  DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
			
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
		/*
		int ent=-1;
		while((ent=FindEntityByClassname2(ent, "vgui_screen"))!=-1)
		{
			if(GetEntPropEnt(ent, Prop_Data, "m_hMoveParent")==obj)
			{
				RemoveEntity(ent);
			}
		}
		*/
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
		float vOrigin[3];
									
		GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);

		vOrigin[2] += 15.0;
															
		TeleportEntity(obj, vOrigin, NULL_VECTOR, NULL_VECTOR);
					
		SetEntityModel(obj, "models/items/ammocrate_rockets.mdl");
	//	return Plugin_Stop;
	}
	else
	{
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
			if(iActivity > 0) npc.StartActivity(iActivity);
		//	npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
			return Plugin_Continue;
		}
		
		//BELOW IS SET ONCE!
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	
		
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntityModel(obj, CUSTOM_SENTRYGUN_MODEL);
		
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
			if(iActivity > 0) npc.StartActivity(iActivity);
		//	npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
			return Plugin_Continue;
		}
		
		//BELOW IS SET ONCE!
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	
		
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntityModel(obj, CUSTOM_SENTRYGUN_MODEL);
		
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitHealingStation(Handle htimer, int entref)
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
//			int iActivity = npc.LookupActivity("MORTAR_IDLE");
//			if(iActivity > 0) npc.StartActivity(iActivity);
//			npc.Update(); //SO THE ANIMATION PROPERLY LOOPS! CHECK THIS VERY OFTEN!
			return Plugin_Continue;
		}
		
		//BELOW IS SET ONCE!
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	
		
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntityModel(obj, HEALING_STATION_MODEL);
		
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitArmorTable(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
			
		Building_Constructed[obj] = true;
		/*
		int ent=-1;
		while((ent=FindEntityByClassname2(ent, "vgui_screen"))!=-1)
		{
			if(GetEntPropEnt(ent, Prop_Data, "m_hMoveParent")==obj)
			{
				RemoveEntity(ent);
			}
		}
		*/
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
	//	float vOrigin[3];
									
	//	GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);

		//vOrigin[2] += 10.0;
															
	//	TeleportEntity(obj, vOrigin, NULL_VECTOR, NULL_VECTOR);
					
		SetEntityModel(obj, "models/props_manor/table_01.mdl");
		//return Plugin_Stop;
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitPerkMachine(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
			
		Building_Constructed[obj] = true;
		/*
		int ent=-1;
		while((ent=FindEntityByClassname2(ent, "vgui_screen"))!=-1)
		{
			if(GetEntPropEnt(ent, Prop_Data, "m_hMoveParent")==obj)
			{
				RemoveEntity(ent);
			}
		}
		*/
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
	//	float vOrigin[3];
				
		float eyePitch[3];
		GetEntPropVector(obj, Prop_Data, "m_angRotation", eyePitch);
		eyePitch[1] -= 90.0;
												
		TeleportEntity(obj, NULL_VECTOR, eyePitch, NULL_VECTOR);
					
		SetEntityModel(obj, PERKMACHINE_MODEL);
		//return Plugin_Stop;
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}
public Action Timer_DroppedBuildingWaitPackAPunch(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
			
		Building_Constructed[obj] = true;
		/*
		int ent=-1;
		while((ent=FindEntityByClassname2(ent, "vgui_screen"))!=-1)
		{
			if(GetEntPropEnt(ent, Prop_Data, "m_hMoveParent")==obj)
			{
				RemoveEntity(ent);
			}
		}
		*/
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
	//	float vOrigin[3];
				
		float eyePitch[3];
		GetEntPropVector(obj, Prop_Data, "m_angRotation", eyePitch);
		eyePitch[1] -= 90.0;
												
		TeleportEntity(obj, NULL_VECTOR, eyePitch, NULL_VECTOR);
					
		SetEntityModel(obj, PACKAPUNCH_MODEL);
		//return Plugin_Stop;
	}
	else
	{
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWaitWall(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		i_BarricadesBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
			
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
	}
	return Plugin_Continue;
}

public Action Timer_DroppedBuildingWait(Handle htimer, int entref)
{
	int obj=EntRefToEntIndex(entref);
	if(!IsValidEntity(obj))
	{
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
			return Plugin_Continue;
			
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
		Building_Constructed[obj] = true;
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
		GetEntityClassname(obj, buffer, sizeof(buffer))
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
					SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
						SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
						SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
								}
							}
						}
					}
				}
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

#define MAX_TARGETS_HIT 64
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
	//	PrintToChatAll("%f",flAng[0]);
	//	PrintToChatAll("%f",flAng[1]);
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
	int team = GetClientTeam(client);
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
			   
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
			  
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
								
	CloseHandle(trace);
//	f_DamageReductionMortar[client] = 1.0;
	int entity = CreateEntityByName("tf_projectile_pipe_remote");
	if(IsValidEntity(entity))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
		SetEntProp(entity, Prop_Send, "m_bCritical", true);
		SetEntProp(entity, Prop_Send, "m_iType", 1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.0);
		//	SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
		//	SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);
		DispatchSpawn(entity);
		TeleportEntity(entity, spawnLoc, NULL_VECTOR, NULL_VECTOR);
	
		i_HasMarker[client] = EntIndexToEntRef(entity);
		EmitSoundToAll("weapons/drg_wrench_teleport.wav", entity, SNDCHAN_WEAPON, 70);
		CreateTimer(0.5, MortarMarkSpot, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}
	
public Action MortarMarkSpot(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int entity = EntRefToEntIndex(i_HasMarker[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			if(!GetEntProp(entity, Prop_Send, "m_bTouched"))
				return Plugin_Continue;

			static float pos[3],pos_obj[3], ang[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			GetClientEyeAngles(client, ang);
			ang[0] = 0.0;
			ang[2] = 0.0;
			RemoveEntity(entity);
			int obj=EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
			if(IsValidEntity(obj))
			{
				GetEntPropVector(obj, Prop_Send, "m_vecOrigin", pos_obj);
				pos_obj[2] += 100.0;
				CClotBody npc = view_as<CClotBody>(obj);
				npc.AddGesture("MORTAR_FIRE");
				EmitSoundToAll(MORTAR_SHOT, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos_obj);
				EmitSoundToAll(MORTAR_SHOT, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos_obj);
				CreateTimer(1.0, MortarFire_Anims, client, TIMER_FLAG_NO_MAPCHANGE);
				f_MarkerPosition[client] = pos;
				float position[3];
				position[0] = f_MarkerPosition[client][0];
				position[1] = f_MarkerPosition[client][1];
				position[2] = f_MarkerPosition[client][2];
				
				position[2] += 3000.0;
				
				int particle = ParticleEffectAt(position, "kartimpacttrail", 2.0);
				CreateTimer(1.7, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
				ParticleEffectAt(pos, "utaunt_portalswirl_purple_warp2", 2.0);
				ParticleEffectAt(pos_obj, "skull_island_embers", 2.0);
			}
	
		}
	}
	else
	{
		int entity = EntRefToEntIndex(i_HasMarker[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
			
	}

	i_HasMarker[client] = 0;
	return Plugin_Stop;
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
			/*
			float position[3];
			position[0] = f_MarkerPosition[client][0];
			position[1] = f_MarkerPosition[client][1];
			position[2] += 1500.0;
					
			int r = 255;
			int g = 165;
			int b = 0;
			int alpha = 200;
			int diameter = 50;
					
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, alpha);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, alpha);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, alpha);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, alpha);
			TE_SetupBeamPoints(f_MarkerPosition[client], position, gLaser1, 0, 0, 0, 0.70, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(f_MarkerPosition[client], position, gLaser1, 0, 0, 0, 0.80, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(f_MarkerPosition[client], position, gLaser1, 0, 0, 0, 0.90, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(f_MarkerPosition[client], position, gLaser1, 0, 0, 0, 1.0, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			*/
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
		
			attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
				
			damage = attack_speed * damage * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
			
			sentry_range = Attributes_FindOnPlayer(client, 344, true, 1.0);			//Sentry Range bonus
			
			float AOE_range = 350.0 * sentry_range;
			
			int targ = MaxClients + 1;
			float targPos[3];
			float damage_falloff = 1.0;
			while ((targ = FindEntityByClassname(targ, "base_boss")) != -1)
			{
				if (GetEntProp(client, Prop_Send, "m_iTeamNum")!=GetEntProp(targ, Prop_Send, "m_iTeamNum")) 
				{
					if(!b_NpcHasDied[targ])
					{
						GetEntPropVector(targ, Prop_Data, "m_vecAbsOrigin", targPos);
						if (GetVectorDistance(f_MarkerPosition[client], targPos) <= AOE_range)
						{
							
							float distance_1 = GetVectorDistance(f_MarkerPosition[client], targPos);
							float damage_1 = Custom_Explosive_Logic(client, distance_1, 0.5, damage, AOE_range);
									
						//	damage_1 /= f_DamageReductionMortar[client];
							SDKHooks_TakeDamage(targ, obj, client, damage_1/damage_falloff, DMG_BLAST, -1, CalculateExplosiveDamageForce(f_MarkerPosition[client], targPos, AOE_range), f_MarkerPosition[client]);
							damage_falloff *= EXPLOSION_AOE_DAMAGE_FALLOFF;
						//	f_DamageReductionMortar[client] *= 1.35;
							//use blast cus it does its own calculations for that ahahahah im evil
						}
					}
				}
			}
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
		f_BuildingIsNotReady[client] = GetGameTime() + 2.2;
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
			CloseHandle(trace);
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
			PrintToConsoleAll("Error with dot_beam, could not determine end point for beam.");
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
			StartLagCompensation_Base_Boss(client, false);
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			CloseHandle(trace);
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
			PrintToConsoleAll("Error with dot_beam, could not determine end point for beam.");
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
				for(int i=1; i <= MAXENTITIES; i++)
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


public int MaxSupportBuildingsAllowed(int client)
{
	int maxAllowed = 1;
	
  	int Building_health_attribute = RoundToNearest(Attributes_FindOnPlayer(client, 762)); //762 is how many extra buildings are allowed on you.
	
	maxAllowed += Building_health_attribute;
	
	if(maxAllowed < 1)
	{
		maxAllowed = 1;
	}
	
	return maxAllowed;
}


public int MaxBarricadesAllowed(int client)
{
	int maxAllowed = 2;
	
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
			return 0;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				delete menu;
			}
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			
			if(id == -1)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
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
											SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
											SetGlobalTransTarget(owner);
											ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Pap Machine Used");
										}
									}
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "Your weapon was boosted");
									Store_ApplyAttribs(client);
									Store_GiveAll(client, GetClientHealth(client));
								}
								else if(number_return == 2)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
									SetGlobalTransTarget(client);
									ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Money To Pap");	
								}
								else if(number_return == 1)
								{
									ClientCommand(client, "playgamesound items/medshotno1.wav");
									SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
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
			else if(id == -3)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 1);
					}
				}
			}
			else if(id == -4)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 2);
					}
				}
			}
			else if(id == -5)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 3);
					}
				}
			}
			else if(id == -6)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 4);
					}
				}
			}
			else if(id == -7)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 5);
					}
				}
			}
			else if(id == -8)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					if(IsValidClient(owner))
					{
						Do_Perk_Machine_Logic(owner, client, entity, 6);
					}
				}
			}
		}
	}
	return 0;
}

public void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk)
{
	TF2_StunPlayer(client, 1.0, 0.0, TF_STUNFLAG_BONKSTUCK | TF_STUNFLAG_SOUND, 0);
	Building_Collect_Cooldown[entity][client] = GetGameTime() + 20.0;
	
	i_CurrentEquippedPerk[client] = what_perk;
	
	if(owner != -1 && owner != client)
	{
		if(Perk_Machine_money_limit[owner][client] <= 10)
		{
			CashSpent[owner] -= 80;
			Perk_Machine_money_limit[owner][client] += 2;
			Resupplies_Supplied[owner] += 8;
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(owner);
			ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Perk Machine Used");
		}
	}
	SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", PerkNames_Recieved[i_CurrentEquippedPerk[client]]);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	
}