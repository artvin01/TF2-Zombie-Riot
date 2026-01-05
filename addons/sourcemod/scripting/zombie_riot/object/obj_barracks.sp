#pragma semicolon 1
#pragma newdecls required

/*
float WoodAmount[MAXPLAYERS];
float FoodAmount[MAXPLAYERS];
float GoldAmount[MAXPLAYERS];
int SupplyRate[MAXPLAYERS];
See ZR core.
*/

static float f_VillageSavingResources[MAXENTITIES];

static int InMenu[MAXPLAYERS];
static float TrainingStartedIn[MAXPLAYERS];
static float TrainingIn[MAXPLAYERS];
static int TrainingIndex[MAXPLAYERS];
static int TrainingQueue[MAXPLAYERS];
static float ResearchStartedIn[MAXPLAYERS];
static float ResearchIn[MAXPLAYERS];
static int ResearchIndex[MAXPLAYERS];
static int CommandMode[MAXPLAYERS];
//bool FinalBuilder[MAXENTITIES];
static bool MedievalUnlock[MAXPLAYERS];
//bool GlassBuilder[MAXENTITIES];
static int CivType[MAXPLAYERS];
static bool b_InUpgradeMenu[MAXPLAYERS];

int i_NormalBarracks_HexBarracksUpgrades[MAXENTITIES];

//defined inside obj_shared
//int i_NormalBarracks_HexBarracksUpgrades_2[MAXENTITIES];
int i_EntityReceivedUpgrades[MAXENTITIES];
bool i_BuildingReceivedHordings[MAXENTITIES];
float f_NextHealTime[MAXENTITIES];

//Barracks smith things:

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


#define ZR_UNIT_UPGRADES_NONE					0

//MELEE PERKS
#define ZR_UNIT_UPGRADES_COPPER_SMITH			(1 << 1) //done :)
#define ZR_UNIT_UPGRADES_IRON_CASTING			(1 << 2) //done :)
#define ZR_UNIT_UPGRADES_STEEL_CASTING			(1 << 3) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFINED_STEEL			(1 << 4) //done :)
//in the end this should grant 1.5x damage

//RANGED PERKS
#define ZR_UNIT_UPGRADES_FLETCHING				(1 << 5) //done :)
#define ZR_UNIT_UPGRADES_STEEL_ARROWS			(1 << 6) //done :)
#define ZR_UNIT_UPGRADES_BRACER					(1 << 7) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_OBSIDIAN_REFINED_TIPS	(1 << 8) //done :)
//in the end this should grant 1.35x the damage and 25% more range

//ARMOR PERKS affects all units.
#define ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR		(1 << 9) //done :)
#define ZR_UNIT_UPGRADES_IRON_PLATE_ARMOR		(1 << 10) //done :)
#define ZR_UNIT_UPGRADES_CHAINMAIL_ARMOR		(1 << 11) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFORGED_STEEL_ARMOR	(1 << 12) //done :)
//in the end this should grant 5 flat armor reduction and 25% damage resistance, no health so medics are amazing

#define ZR_UNIT_UPGRADES_HERBAL_MEDICINE		(1 << 13) //done :)
//this will heal units very slowly overtime
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFINED_MEDICINE		(1 << 14) //done :)
//this will make units heal faster and give more max health (10%+ max health)

//UPGRADES TO BUILDINGS
//these should be very expensive, allows building to attack with arrows
//the building will also now gain abit of health, so it can be used as a weak barricade
#define ZR_BARRACKS_UPGRADES_TOWER				(1 << 15) //done :)
#define ZR_BARRACKS_UPGRADES_GUARD_TOWER		(1 << 16) //done :)
#define ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER		(1 << 17) //done :)
#define ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER	(1 << 18) //done :)
//going below this will lower your deployment slots to 2
//BELOW HERE will allow to garrison units (they will be given 0 gravity and teleported off the map and flagged so they dont get deleted)
//they will add extra arrows and heal the units overtime
//garrison will also work if you mount the building, allowing you to save your units in the most dire of situations.
#define ZR_BARRACKS_UPGRADES_DONJON				(1 << 19) //done :)
#define ZR_BARRACKS_UPGRADES_KREPOST			(1 << 20) //done :)
//at this point, the building will have 75% HP of a barricade, but getting this is very lategame, about wave 50 or so
#define ZR_BARRACKS_UPGRADES_CASTLE				(1 << 21) //done :)
//getting here will allow you to make teutonic knights, replacing the champion line.

//Have a toggle option to fire the arrows of your turret manually when you mount it
//it will give a boost in firepower as you do it manually!
#define ZR_BARRACKS_UPGRADES_MANUAL_FIRE		(1 << 22) //done :)
//Allows the building to attack units directly near it
#define ZR_BARRACKS_UPGRADES_MURDERHOLES		(1 << 23) //done :)
//allows the building to predict enemies
#define ZR_BARRACKS_UPGRADES_BALLISTICS			(1 << 24) //done :)
//inflict burning onto enemy and also get abit extra damage
#define ZR_BARRACKS_UPGRADES_CHEMISTY			(1 << 25) //done :)

//only vaiable once reaching donjon:

#define ZR_BARRACKS_UPGRADES_CONSCRIPTION		(1 << 26) //done :)
//allows to make units faster, you also gain resources faster, doesnt affect gold.
#define ZR_BARRACKS_UPGRADES_GOLDMINERS			(1 << 27) //done :)
//THIS is only aviable once you have the gold crown.
//this will allow you to gain gold faster if you have units in your building
//but it will also give you a 25% increase on gold gain passively.
#define ZR_BARRACKS_UPGRADES_CRENELLATIONS		(1 << 28) //done :)
//The castle will have a huge boost in range, allowing to snipe at great ranges
//it will also increase the speed of the arrows by alot.
#define ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER	(1 << 29)
//This will allow you to make one villager, this villager will try to make a building near you, or whereever you tell it to make one
//This building will only fire arrows, its max upgrade limit is another donjon, it cannot be a krepost or castle.
//This villager will try to repair all buildings around it for free, although, it will always prioritise repairing its own buildings
//When it notices its health is too low, then it will automatically run away and garrison inside its own building for safety
//it wont try to garrison inside your building and you cannot manually assign it a tast to repair stuff, only assign it where to build
//its building, but i t can only make one if its directly on a nav mesh to prevent abuse
//This villager will take away one ally spot and 1 barricade limit
//meaning if you have a castle and this villager, then you can only make 1 unit and 1 barricade
//its repair power derives from your repair upgrades.
//it is also unable to attack at all, its not fragile but it just cant defend itself
//garrisoning this unit wont increase the damage of the building it hides inside.
//unless....
#define ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER_EDUCATION	(1 << 30)
//this upgrade will make the villager free and wont consume slots, this means you can have 2 units and 2 barricades when you get this.


//only vaiable once reaching Krepost:

#define ZR_BARRACKS_UPGRADES_STRONGHOLDS	(1 << 31) //done :)
//The building will attack 33% faster, it will also heal any nearby MELEE player or unit slowly, weaker song of ocean minus buff.


#define ZR_BARRACKS_UPGRADES_HOARDINGS		(1 << 1) //Done :)
//ALL your buildings will gain 25% more health. This is to encurage camping with the building when you get upto middle.
//but making this building again will limit you to not make units and such, and have less barricades out
//this upgrade will only work when the castle is out, the moment the building breaks, the HP of all your buidlings will go down once more.

//i ran out of space...
#define ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING		(1 << 2) //Done :)
//allows you to have 20% increased unit making speed

//defined higher up, see obj_shared
//#define ZR_BARRACKS_TROOP_CLASSES			(1 << 3) //Allows training of units, although will limit support buildings to 1.


//in the end, this should be stronger then a sentry with full upgrades by 2x
//but i will make it eat up barricade slots so if you have this fully upgrades, you can only make 2 barricades at max
//but it wont affect barracks supply limit unless you get some upgrades that change this.

//mounting this building will cause it to deal half the damage, or attack half as fast, whatever works.
//just nerf the building overall, so its more advantagous to have it placed down.
//none of these upgrades cost gold (or should)

#define SUMMONER_MODEL	"models/props_island/parts/guard_tower01.mdl"
#define SUMMONER_MODEL_2	"models/props_manor/clocktower_01.mdl"
#define SUMMONER_MODEL_3	"models/props_spytech/radio_tower001.mdl"
void ObjectBarracks_MapStart()
{
	PrecacheModel(SUMMONER_MODEL);
	PrecacheModel(SUMMONER_MODEL_2);
	PrecacheModel(SUMMONER_MODEL_3);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_barracks");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_barracks");
	build.Cost = 1200;
	build.Health = 50;
	build.Cooldown = 15.0;
	build.Func = ObjectGeneric_CanBuildSentryBarracks;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectBarracks(client, vecPos, vecAng);
}

methodmap ObjectBarracks < ObjectGeneric
{
	public ObjectBarracks(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectBarracks npc = view_as<ObjectBarracks>(ObjectGeneric(client, vecPos, vecAng, SUMMONER_MODEL, "0.11","50", {18.0, 18.0, 40.0}, _, false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		func_NPCThink[npc.index] = Barracks_BuildingThink;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, 180.0);
		Building_Summoner(client, npc.index);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER))
		{
			if(CivType[client] == Combine)
			{
				SetEntityModel(npc.index, SUMMONER_MODEL_3);
				if(IsValidEntity(npc.m_iWearable1))
				{
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale", GetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale") * 0.75);
					SetEntityModel(npc.m_iWearable1, SUMMONER_MODEL_3);
				}
			}
			else if(CivType[client] != Combine)
			{
				SetEntityModel(npc.index, SUMMONER_MODEL_2);
				if(IsValidEntity(npc.m_iWearable1))
				{
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale", GetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale") * 0.75);
					SetEntityModel(npc.m_iWearable1, SUMMONER_MODEL_2);
				}
			}
			SetEntPropFloat(npc.index, Prop_Send, "m_flModelScale", GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale") * 0.75);
			float minbounds[3] = {-18.0, -18.0, 0.0};
			float maxbounds[3] = {18.0, 18.0, 40.0};
			SetEntPropVector(npc.index, Prop_Send, "m_vecMins", minbounds);
			SetEntPropVector(npc.index, Prop_Send, "m_vecMaxs", maxbounds);

			b_Anger[npc.index] = true;
		}
		
		return npc;
	}
}


static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(Owner != client)
		return false;
		
	if(f_BuildingIsNotReady[client] > GetGameTime())
		return false;
	
	if(Owner == client)
	{
		if(f_MedicCallIngore[client] < GetGameTime())
			return false;

		OpenSummonerMenu(Owner, client);
		return true;
	}
	OpenSummonerMenu(Owner, client);
	return true;
}
void BarracksCheckItems(int client)
{
	i_NormalBarracks_HexBarracksUpgrades[client] = Store_HasNamedItem(client, "Barracks Hex Upgrade 1");
	i_NormalBarracks_HexBarracksUpgrades_2[client] = Store_HasNamedItem(client, "Barracks Hex Upgrade 2");
	WoodAmount[client] = float(Store_HasNamedItem(client, "Barracks Wood"));
	FoodAmount[client] = float(Store_HasNamedItem(client, "Barracks Food"));
	GoldAmount[client] = float(Store_HasNamedItem(client, "Barracks Gold"));
}



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
	Combine = 3,
	Iberia_Thorns = 4,
	Iberia_Thornless = 5,
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
	
	"npc_barrack_crossbow",
	"npc_barrack_man_at_arms",
	
	"npc_barrack_arbelast",
	"npc_barrack_swordsman",
	
	"npc_barrack_handcannoneer",
	"npc_barrack_twohanded",
	
	"npc_barrack_villager",
	"npc_barrack_teutonic_knight",
	
	"npc_barrack_monk",
	"npc_barrack_hussar",

	"npc_barrack_longbow",
	"npc_barrack_champion"
};


static int SummonerBase[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level, Supply, Requirement
	{ 0, 5, 20, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None
	{ 0, 40, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Novice

	{ 0, 70, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	{ 0, 10, 35, 0, 6, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice

	{ 0, 190, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	{ 0, 20, 60, 0, 7, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Worker

	{ 0, 260, 75, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert
	{ 0, 50, 150, 0, 8, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert

	{ 0, 750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  },	// Construction Expert
	{ 0, 300, 300, 	20, 16, 16, 1, ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },		// Construction Master

	{ 0, 600, 200, 20, 12, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 200, 600, 50, 15, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master
	
	{ 0, 300, 100, 0, 10, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master
	{ 0, 100, 300, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  }		// Construction Master
};

//THIS IS THORNS ONLY.
static const char SummonerThornsNPC[][] =
{
	"npc_barrack_militia",
	"npc_barrack_archer",
	
	"npc_barrack_man_at_arms",
	"npc_barrack_crossbow",
	
	"npc_barrack_swordsman",
	"npc_barrack_arbelast",
	
	"npc_barrack_twohanded",
	"npc_barrack_handcannoneer",
	
	"npc_barrack_longbow",
	"npc_barrack_champion",
	
	"npc_barrack_thorns",
	"npc_barrack_monk",	
	
	"npc_barrack_teutonic_knight",
	"npc_barrack_villager"
};

static int SummonerThorns[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level, Supply, Requirement
	{ 0, 5, 20, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None
	{ 0, 40, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },		// Construction Novice
	
	{ 0, 10, 35, 0, 6, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	{ 0, 70, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	
	{ 0, 20, 60, 0, 7, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Worker
	{ 0, 190, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	
	{ 0, 50, 150, 0, 8, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert
	{ 0, 260, 75, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert

	{ 0, 300, 100, 0, 10, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master 
	{ 0, 100, 300, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master

	{ 0, 1200, 1200, 50, 50, 11, 2, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0, 600, 200, 20, 12, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 400, 400, 	20, 16, 16, 1, ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  }	// Construction Expert 
};

static const char SummonerCombineNPC[][] =
{
	
	"npc_barrack_combine_smg",
	"npc_barrack_combine_pistol",
	
	"npc_barrack_combine_swordsman",	
	"npc_barrack_combine_ar2",
	
	"npc_barrack_combine_ddt",	
	"npc_barrack_combine_shotgunner",
	
	"npc_barrack_combine_collos",
	"npc_barrack_combine_elite",
	
	"npc_barrack_villager",
	"npc_barrack_combine_commander",
	
	"npc_barrack_chaos_containment_unit",
	"npc_barrack_combine_super",
		
	"npc_barrack_combine_sniper",
	"npc_barrack_combine_giant_ddt"	
};

static int SummonerCombine[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level, Supply, Requirement
	
	{ 0, 5, 20, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None
	{ 0, 40, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },		// Construction Novice
	
	{ 0, 10, 35, 0, 5, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	{ 0, 70, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Apprentice
	
	{ 0, 20, 60, 0, 6, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Worker
	{ 0, 190, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	
	{ 0, 50, 150, 0, 7, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Expert
	{ 0, 260, 75, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES  },	// Construction Master
	
	{ 0, 750, 750, 	0, 	25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  },	// Construction Expert
	{ 0, 600, 600, 	30, 30, 16, 1, ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 600, 200, 20, 20, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 200, 600, 20, 20, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES }, // Contruction Master

	{ 0, 300, 100, 0, 10, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 100, 300, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES  }	// Construction Master
	
};

static const char SummonerIberiaNPC[][] =
{
	"npc_barrack_runner",
	"npc_barrack_gunner",
	
	"npc_barrack_tanker",
	"npc_barrack_rocketeer",
	
	"npc_barrack_healer",
	"npc_barrack_boomstick",
	
	"npc_barrack_healtanker",
	"npc_barrack_elite_gunner",
	
	"npc_barrack_villager",
	"npc_barrack_lighthouse_guardian",
		
	"npc_barrack_inquisitor",	
	"npc_barrack_headhunter",
	
	"npc_barrack_commando",
	"npc_barrack_guards",
};

static int SummonerIberiaComplete[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level
	{ 0, 5, 20, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None
	{ 0, 40, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// Construction Novice

	{ 0, 10, 35, 0, 5, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice
	{ 0, 70, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice

	{ 0, 20, 60, 0, 6, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	{ 0, 190, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES},	// Construction Worker
	
	{ 0, 50, 150, 0, 8, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0, 260, 75, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert

	{ 0, 750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0 }, // Construction Expert
	{ 0, 800, 800, 	40, 25, 16, 2, ZR_BARRACKS_UPGRADES_CASTLE, ZR_BARRACKS_TROOP_CLASSES }, // Construction Master

	{ 0, 600, 200, 	20, 15, 16, 1, 0, ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 200, 600, 	20, 15, 16, 1, 0, ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 300, 100, 0, 10, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES }, // Construction Master
	{ 0, 100, 300, 0, 9, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES }	// Construction Master
};


static const char SummonerIberiaIncompleteNPC[][] =
{
	"npc_barrack_runner",
	
	"npc_barrack_gunner",
	"npc_barrack_tanker",
	
	"npc_barrack_rocketeer",
	"npc_barrack_healer",
	
	"npc_barrack_boomstick",
	"npc_barrack_healtanker",
	
	"npc_barrack_elite_gunner",
	"npc_barrack_guards",
	
	"npc_barrack_headhunter",
	
	"npc_barrack_lighthouse_guardian",
	"npc_barrack_villager"
};

static int SummonerIberiaInComplete[][] =
{
	// NPC Index, Wood, Food, Gold, Time, Level
	{ 0, 5, 15, 0, 5, 1, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// None

	{ 0, 50, 10, 0, 7, 2, 1, 0,ZR_BARRACKS_TROOP_CLASSES },		// Construction Novice
	{ 0, 10, 30, 0, 5, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice

	{ 0, 90, 20, 0, 8, 4, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice
	{ 0, 10, 45, 0, 6, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker

	{ 0, 210, 50, 0, 9, 7, 1, 0,ZR_BARRACKS_TROOP_CLASSES},	// Construction Worker
	{ 0, 20, 100, 0, 6, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert

	{ 0, 400, 100, 0, 10, 11, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert
	{ 0, 50, 200, 0, 7, 16, 1, 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master

	{ 0, 100, 350, 	5, 8, 16, 1, 0, ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 900, 900, 	30, 10, 16, 2, ZR_BARRACKS_UPGRADES_CASTLE, ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0, 		750, 750, 	0, 25, 11, 1, ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0 }	// Construction Expert
};

static const char SummonerAlternativeNPC[][] =
{
	"npc_barrack_alt_basic_mage",
	"npc_barrack_alt_mecha_barrager",
	
	"npc_barrack_alt_intermediate_mage",
	"npc_barrack_alt_crossbow",
	
	"npc_barrack_alt_barrager",
	"npc_barrack_alt_railgunner",

	"npc_barrack_alt_mecha_loader",
	"npc_barrack_alt_advanced_mage",
	
	"npc_barrack_villager",
	"npc_barrack_alt_witch",
	
	"npc_barrack_alt_donnerkrieg",
	"npc_barrack_alt_schwertkrieg",
	
	"npc_barrack_alt_ikunagae",
	"npc_barrack_alt_holy_knight"
};

static int SummonerAlternative[][] =
{
	// NPC Index, 	Wood, 	Food, 	Gold, 	Time, Level, Supply
	{ 0 , 			10, 	20, 	0, 		5, 		 1,	 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },		// None
	{ 0, 			30, 	10, 	0, 		7, 		 2,		1, 	0,ZR_BARRACKS_TROOP_CLASSES },		// Construction Novice
	
	{ 0 ,			10, 	40, 	0, 		7, 		 4, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice
	{ 0, 			100, 	25, 	0, 		9, 		 4, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Apprentice

	{ 0,			25,		75, 	0, 		7, 		 7, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker
	{ 0 , 			200, 	50, 	0,		9,		 7, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Worker

	{ 0, 			20, 	200, 	0,		7, 		 11, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert	// Suicide bombers 
	{ 0, 			300, 	50, 	0,		9, 		 11, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Expert	
	
	{ 0, 			750, 	750, 	0,		25,		 11,	1,	 ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER,0  },	// Construction Expert
	{ 0, 			1200, 	1200, 	50, 	30,		 16,	2,	 ZR_BARRACKS_UPGRADES_CASTLE,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	
	{ 0, 			600, 	200, 	25, 	12,		 16,	1,	 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0 , 			200, 	600, 	25, 	13,		 16,	1,	 0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master

	{ 0, 			300, 	100, 	0, 		10, 		 16, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES },	// Construction Master
	{ 0 , 			100,	300,	0,		9, 		 16, 	1, 	0,ZR_BARRACKS_TROOP_CLASSES }	// Construction Master
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
	"Thorns Assitance",
	"Blitzkrieg's Army",
	"Guln's Companions",
	"Iberia and Expidonsan's",
	"Iberia and Expidonsan's",
};

static void SetupNPCIndexes()
{
	for(int i; i < sizeof(SummonerBase); i++)
	{
		SummonerBase[i][NPCIndex] = NPC_GetByPlugin(SummonerBaseNPC[i]);
	}

	for(int i; i < sizeof(SummonerCombine); i++)
	{
		SummonerCombine[i][NPCIndex] = NPC_GetByPlugin(SummonerCombineNPC[i]);
	}

	for(int i; i < sizeof(SummonerThorns); i++)
	{
		SummonerThorns[i][NPCIndex] = NPC_GetByPlugin(SummonerThornsNPC[i]);
	}
	
	for(int i; i < sizeof(SummonerAlternative); i++)
	{
		SummonerAlternative[i][NPCIndex] = NPC_GetByPlugin(SummonerAlternativeNPC[i]);
	}
	
	for(int i; i < sizeof(SummonerIberiaComplete); i++)
	{
		SummonerIberiaComplete[i][NPCIndex] = NPC_GetByPlugin(SummonerIberiaNPC[i]);
	}
	
	for(int i; i < sizeof(SummonerIberiaInComplete); i++)
	{
		SummonerIberiaInComplete[i][NPCIndex] = NPC_GetByPlugin(SummonerIberiaIncompleteNPC[i]);
	}
}

static int GetUnitCount(int civ)
{
	switch(civ)
	{
		case Iberia_Thornless:
			return sizeof(SummonerIberiaInComplete);
			
		case Iberia_Thorns:
			return sizeof(SummonerIberiaComplete);

		case Thorns:
			return sizeof(SummonerThorns);
		
		case Combine:
			return sizeof(SummonerCombine);
			
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
		case Iberia_Thornless:
			return SummonerIberiaInComplete[unit][index];
			
		case Iberia_Thorns:
			return SummonerIberiaComplete[unit][index];

		case Thorns:
			return SummonerThorns[unit][index];

		case Combine:
			return SummonerCombine[unit][index];
			
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


public void Building_Summoner(int client, int entity)
{
	SetupNPCIndexes();
	/*
	SetDefaultValuesToZeroNPC(entity);
	b_BuildingHasDied[entity] = false;
	b_CantCollidieAlly[entity] = true;
	i_IsABuilding[entity] = true;
	b_NoKnockbackFromSources[entity] = true;
	b_NpcHasDied[entity] = true;
	*/
	BarracksCheckItems(client);
	WoodAmount[client] *= 0.75;
	FoodAmount[client] *= 0.75;
	if(WoodAmount[client] < 50.0)
		WoodAmount[client] = 50.0;
	if(FoodAmount[client] < 50.0)
		FoodAmount[client] = 50.0;
		
	if(CvarInfiniteCash.BoolValue)
	{
		WoodAmount[client] = 999999.0;
		FoodAmount[client] = 999999.0;
		GoldAmount[client] = 99999.0;
	}
	SetGlobalTransTarget(client);

	CPrintToChat(client, "{yellow}%t", "Barracks Desc Extra");
	CPrintToChat(client, "{yellow}%t", "Barracks Desc Extra 2");
	ExplainBuildingInChat(client, 2);
	TrainingIn[client] = 0.0;
	ResearchIn[client] = 0.0;
	CommandMode[client] = 0;
	TrainingQueue[client] = -1;
	CivType[client] = Store_HasNamedItem(client, "Iberia's Last Hope") ? Thorns : Default;

	if(CivType[client] == Default)
	{
		CivType[client] = Store_HasNamedItem(client, "Iberia and Expidonsan's Help") ? Iberia_Thornless : Default;
		if(CivType[client] != Default)
		{
			//looks like they have last hope equipped! Do they also possess iberia?
			if(Items_HasNamedItem(client, "Iberia's Last Hope"))
			{
				CivType[client] = Iberia_Thorns;
			}
		}
	}

	if(CivType[client] == Default)
		CivType[client] = Store_HasNamedItem(client, "Blitzkrieg's Army") ? Alternative : Default;
		
	if(CivType[client] == Default)
		CivType[client] = Store_HasNamedItem(client, "Guln's Companions") ? Combine : Default;
		
	i_PlayerToCustomBuilding[client] = EntIndexToEntRef(entity);
	Building_Collect_Cooldown[entity][0] = 0.0;	
}


void Barracks_TryRegenIfBuilding(int client, float ammount = 1.0)
{
	int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(IsValidEntity(entity))
	{
		static char plugin[64];
		NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
		if(StrContains(plugin, "obj_barracks", false) != -1)
		{
			//regen barracks resoruces
			SummonerRenerateResources(client, 12.5 * ammount, 0.0, true);
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Barracks Gained Resources");
			f_VillageSavingResources[client] = GetGameTime() + 0.25;
			BarracksSaveResources(client);
		}
	}
}
void Barracks_BuildingThink(int entity)
{
	BarrackBody npc = view_as<BarrackBody>(entity);
	float GameTime = GetGameTime(npc.index);

	//do not think.
	if(npc.m_flNextThinkTime > GameTime) //add a delay, we dont really need more lol
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.2;
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	if(!IsValidClient(client))
		return;
	
	if(GetTeam(client) != 2)
		return;

	if(Barracks_InstaResearchEverything)
	{
		//adds all flags except ZR_BARRACKS_TROOP_CLASSES
		i_NormalBarracks_HexBarracksUpgrades[client] = (0xFFFFFFFF);
		i_NormalBarracks_HexBarracksUpgrades_2[client] |= ((1 << 1));
		i_NormalBarracks_HexBarracksUpgrades_2[client] |= ((1 << 2));
	}
		
	bool mounted = (Building_Mounted[client] == i_PlayerToCustomBuilding[client]);
	SummonerRenerateResources(client, 1.0);
	//used to be 1.0, but we think 2x as much, ill still buff it abit.

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
						int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);

						if(IsValidEntity(entity_close))
						{
							NPC_GetPluginById(i_NpcInternalId[entity_close], npc_classname, sizeof(npc_classname));
							if(StrEqual(npc_classname, "npc_barrack_villager"))
							{
								BarrackBody npc2 = view_as<BarrackBody>(entity_close);
								if(GetClientOfUserId(npc2.OwnerUserId) == client)
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
		if((GetGlobalSupplyLeft() > 0) && (subtractVillager || ((GetSupplyLeft(client)) >= GetSData(CivType[client], TrainingIndex[client], SupplyCost))))
		{
			float gameTime = GetGameTime();
			if(TrainingIn[client] < gameTime)
			{
				static float VecStuckCheck[3];

				int entity_to_heck_from;

				if(mounted)
				{
					entity_to_heck_from = client;
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
					TrainingIn[client] = 0.0;

					float pos[3], ang[3];
					GetEntPropVector(mounted ? client : entity, Prop_Data, "m_vecAbsOrigin", pos);
					GetEntPropVector(mounted ? client : entity, Prop_Data, "m_angRotation", ang);
					pos[2] += 3.0;
					
					view_as<BarrackBody>(mounted ? client : entity).PlaySpawnSound();
					int npc2 = NPC_CreateById(GetSData(CivType[client], TrainingIndex[client], NPCIndex), client, pos, ang, TFTeam_Red);
					view_as<BarrackBody>(npc2).m_iSupplyCount = GetSData(CivType[client], TrainingIndex[client], SupplyCost);
					Barracks_UpdateEntityUpgrades(client, npc2, true, true); //make sure upgrades if spawned, happen on full health!

					
					if(TrainingQueue[client] != -1)
					{
						TrainingIndex[client] = TrainingQueue[client];
						TrainingStartedIn[client] = GetGameTime();
						float trainingTime = float(GetSData(CivType[client], TrainingQueue[client], TrainTime));
						if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CONSCRIPTION)
						{
							trainingTime *= 0.75;
						}
						if(CvarInfiniteCash.BoolValue)
						{
							trainingTime = 0.0;
						}
						TrainingIn[client] = TrainingStartedIn[client] + trainingTime;
						TrainingQueue[client] = -1;
					}
				}
				else
				{
					TrainingIn[client] = gameTime + 0.1;
					TrainingStartedIn[client] = -1.0;
				}
			}
			/*
			else
			{
				int required = RoundFloat((TrainingIn[client] - TrainingStartedIn[client]) * 2.0);
				int current = required - RoundToCeil((TrainingIn[client] - gameTime) * 2.0);
				
			//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", current);
			//	SetEntProp(entity, Prop_Send, "m_iUpgradeMetalRequired", required);
			}
			*/
		}
	}

	if(ResearchIn[client])
	{
		float gameTime = GetGameTime();
		if(ResearchIn[client] < gameTime)
		{
			ResearchIn[client] = 0.0;

			int Get_GiveHexArray;
			int Get_GiveClient;
		//	GetRData(ResearchIndex[client], UpgradeIndex);
			Get_GiveHexArray = GetRData(ResearchIndex[client], GiveHexArray);
			Get_GiveClient = GetRData(ResearchIndex[client], GiveClient);
			
			if(Get_GiveHexArray == 1)
			{
				i_NormalBarracks_HexBarracksUpgrades[client] |= Get_GiveClient;
				Store_SetNamedItem(client, "Barracks Hex Upgrade 1", i_NormalBarracks_HexBarracksUpgrades[client]);
			}
			else if(Get_GiveHexArray == 2)
			{
				i_NormalBarracks_HexBarracksUpgrades_2[client] |= Get_GiveClient;
				Store_SetNamedItem(client, "Barracks Hex Upgrade 2", i_NormalBarracks_HexBarracksUpgrades_2[client]);
			}
			Building_Check_ValidSupportcount(client);
			Barracks_UpdateAllEntityUpgrades(client);
		}
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(InMenu[i] == client)
			OpenSummonerMenu(client, i);
	}

	//they do not even have the first upgrade, do not think, but dont cancel.
	if(!(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER))
		return;

	if(!b_Anger[npc.index])
	{
		SetEntityModel(npc.index, SUMMONER_MODEL_2);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale", GetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale") * 0.75);
			SetEntityModel(npc.m_iWearable1, SUMMONER_MODEL_2);
		}
		SetEntPropFloat(npc.index, Prop_Send, "m_flModelScale", GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale") * 0.75);
		float minbounds[3] = {-18.0, -18.0, 0.0};
		float maxbounds[3] = {18.0, 18.0, 40.0};
		SetEntPropVector(npc.index, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(npc.index, Prop_Send, "m_vecMaxs", maxbounds);
		b_Anger[npc.index] = true;
	}
	float MinimumDistance = 60.0;

	if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_MURDERHOLES)
		MinimumDistance = 0.0;

	float MaximumDistance = 400.0;
	MaximumDistance = Barracks_UnitExtraRangeCalc(npc.index, client, MaximumDistance, true);
	float pos[3];
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
			DoHealingOcean(entity, entity, (500.0 * 500.0), 0.5, true);
		}
	}
	if(IsValidEnemy(client, ValidEnemyToTarget))
	{
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			float ArrowDamage = 200.0;
			int ArrowCount = 1;
			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER)
			{
				ArrowDamage += 300.0;
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
			if(Store_HasNamedItem(client, "Dubious Cheesy Ideas"))	// lol
			{
				ArrowDamage *= 1.25;
				AttackDelay *= 0.9;
			}
			if(Store_HasNamedItem(client, "Messed Up Cheesy Brain")) // lol
			{
				ArrowDamage *= 1.35;
				AttackDelay *= 0.75;
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
				float fAng[3];
				GetEntPropVector(arrow, Prop_Send, "m_angRotation", fAng);
				Initiate_HomingProjectile(arrow,
					npc.index,
						180.0,			// float lockonAngleMax,
						90.0,				//float homingaSec,
						true,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						fAng,
						ValidEnemyToTarget);			// float AnglesInitiate[3]);
				TriggerTimerHoming(arrow);
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
			int Building_hordings = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
			if(IsValidEntity(Building_hordings))
			{
				if(!i_BuildingReceivedHordings[Building_hordings]) 
				{
					if(GetEntPropEnt(Building_hordings, Prop_Send, "m_hOwnerEntity") == client/* && Building_Constructed[Building_hordings]*/)
					{
						SetBuildingMaxHealth(Building_hordings, 1.25, false, true);
						i_BuildingReceivedHordings[Building_hordings] = true;					
					}
				}
			}
		}
	}					
	BarrackVillager player = view_as<BarrackVillager>(client);
	if(IsValidEntity(player.m_iTowerLinked))
	{
		if(!i_BuildingReceivedHordings[player.m_iTowerLinked]) 
		{
			SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth")) * 1.25));
			SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth")) * 1.25));
			i_BuildingReceivedHordings[player.m_iTowerLinked] = true;
		}			
	}
}	

/*
void BuildingHordingsRemoval(int entity)
{
	if(i_WhatBuilding[entity] == BuildingSummoner)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(i_NormalBarracks_HexBarracksUpgrades_2[owner] & ZR_BARRACKS_UPGRADES_HOARDINGS)
		{
			for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
			{
				int Building_hordings = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
				if(IsValidEntity(Building_hordings))
				{
					if(i_BuildingReceivedHordings[Building_hordings])
					{
						if(GetEntPropEnt(Building_hordings, Prop_Send, "m_hOwnerEntity") == owner)
						{
							SetBuildingMaxHealth(Building_hordings, 1.25, true, false);
							i_BuildingReceivedHordings[Building_hordings] = false;					
						}
					}
				}
			}
		}
		BarrackVillager player = view_as<BarrackVillager>(owner);
		if(IsValidEntity(player.m_iTowerLinked))
		{
			if(i_BuildingReceivedHordings[player.m_iTowerLinked]) 
			{
				SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iHealth")) / 1.25));
				SetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(player.m_iTowerLinked, Prop_Data, "m_iMaxHealth")) / 1.25));
				i_BuildingReceivedHordings[player.m_iTowerLinked] = false;
			}			
		}
	}
}
*/

int Building_GetFollowerEntity(int owner)
{
	if(Building_Mounted[owner] != i_PlayerToCustomBuilding[owner])
	{
		int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[owner]);
		if(entity != INVALID_ENT_REFERENCE)
			return entity;
	}
	return owner;
}

int Building_GetFollowerCommand(int owner)
{
	return CommandMode[owner];
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

	SupplyRate[client] += RoundToNearest(Attributes_Get(client, Attrib_BarracksSupplyRate, 0.0));

	FinalBuilder[client] = view_as<bool>(Attributes_Get(client, Attrib_FinalBuilder, 0.0));
	MedievalUnlock[client] = true;/*Items_HasNamedItem(client, "Medieval Crown");*/

	if(!MedievalUnlock[client])
		MedievalUnlock[client] = view_as<bool>(CivType[client]);

	GlassBuilder[client] = view_as<bool>(Attributes_Get(client, Attrib_GlassBuilder, 0.0));
	int AttributeIs = RoundToNearest(Attributes_Get(client, Attrib_WildingenBuilder, 0.0));
	WildingenBuilder[client] = false;
	WildingenBuilder2[client] = false;
	switch(AttributeIs)
	{
		case 1:
		{
			WildingenBuilder[client] = true;
		}
		case 2:
		{
			WildingenBuilder[client] = true;
			WildingenBuilder2[client] = true;
		}
	}
}
#define MAXRESOURCECAP 2000.0
void SummonerRenerateResources(int client, float multi, float GoldGenMulti = 1.0, bool ignoresetup = false)
{
	bool AllowResoruceGen = false;

	if(Rogue_Mode() || Construction_Mode() || Dungeon_Mode())
	{
		AllowResoruceGen = Waves_Started();
	}
	else
	{
		AllowResoruceGen = !Waves_InSetup();
	}

	if(ignoresetup)
	{
		AllowResoruceGen = true;
	}

	if(AllowResoruceGen)
	{
		float SupplyRateCalc = SupplyRate[client] / 10.0;

		float SupplyRateCalcBase = SupplyRateCalc;
		SupplyRateCalc *= multi;

		SupplyRateCalc *= ResourceGenMulti(client);
		WoodAmount[client] += SupplyRateCalc * (0.7667);
		FoodAmount[client] += SupplyRateCalc * (0.9333);

		if(MedievalUnlock[client] || GoldGenMulti != 1.0)
		{
			float GoldSupplyRate = 0.01;
			GoldSupplyRate *= multi;
			GoldSupplyRate *= GoldGenMulti;
			GoldSupplyRate *= ResourceGenMulti(client, true, true);
			GoldAmount[client] += GoldSupplyRate;
		}
		if(WoodAmount[client] >= MAXRESOURCECAP * SupplyRateCalcBase)
			WoodAmount[client] = MAXRESOURCECAP * SupplyRateCalcBase;

		if(FoodAmount[client] >= MAXRESOURCECAP * SupplyRateCalcBase)
			FoodAmount[client] = MAXRESOURCECAP * SupplyRateCalcBase;
	}
	if(f_VillageSavingResources[client] < GetGameTime())
	{
		f_VillageSavingResources[client] = GetGameTime() + 0.25;
		BarracksSaveResources(client);
	}
}

float ResourceGenMulti(int client, bool gold = false, bool allowgoldgen = false, bool visualise = false)
{
	float SupplyRateCalc = 1.0 * ResourceRegenMulti;
	if(!gold)
	{
		if(visualise)
		{
			float Multi_Extra = float(SupplyRate[client]) / 2.0;
			SupplyRateCalc *= Multi_Extra;
		}
		if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CONSCRIPTION)
		{
			SupplyRateCalc *= 1.25;
		}
		if(i_CurrentEquippedPerk[client] & PERK_STOCKPILE_STOUT)
		{
			SupplyRateCalc *= 1.15;
		}
		if(Rogue_Mode())
		{
			SupplyRateCalc *= Inv_Mining_Foreman_Hat_Enable(client) ? 1.15 : 1.1;
		}
		else if(Inv_Mining_Foreman_Hat_Enable(client))
			SupplyRateCalc *= 1.15;
	}
	else
	{
		if(Rogue_Mode())
		{
			SupplyRateCalc *= Inv_Mining_Foreman_Hat_Enable(client) ? 1.25 : 1.2;
		}
		else if(Inv_Mining_Foreman_Hat_Enable(client))
			SupplyRateCalc *= 1.15;
		if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_GOLDMINERS)
		{
			SupplyRateCalc *= 1.25;
		}
		if(!MedievalUnlock[client])
		{
			if(!allowgoldgen)
			{
				SupplyRateCalc = 0.0;
			}
		}
	}
	return SupplyRateCalc;
}

static void OpenSummonerMenu(int client, int viewer)
{
	if(client == viewer)
		CheckSummonerUpgrades(client);
	
	SummonerMenu(client, viewer);
}


static void SummonerMenu(int client, int viewer)
{
	int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
	if(entity == INVALID_ENT_REFERENCE)
	{
		CancelClientMenu(viewer);
		return;
	}
	
	if(client == -1)
		return;

	bool owner = client == viewer;
	bool alive = (owner && IsPlayerAlive(client) && !TeutonType[client]);
	int level = Object_MaxSupportBuildings(client, true);
	int itemsAddedToList = 0;
	
	Menu menu = new Menu(SummonerMenuH);
	CancelClientMenu(viewer);
	SetStoreMenuLogic(viewer, false);

	SetGlobalTransTarget(viewer);
	if(!(GetEntityFlags(viewer) & FL_DUCKING))
	{
		menu.SetTitle("%s\n%t\n \n$%d £%d ¥%.1f\n%t\n", CivName[CivType[client]], "Crouch To See Info Barracks", RoundToFloor(WoodAmount[client]), RoundToFloor(FoodAmount[client]), GoldAmount[client], "Resource Gain Mult Villager", ResourceGenMulti(client,_,_,true), ResourceGenMulti(client, true));
	}
	else
	{
		menu.SetTitle("%s\n\n \n$%d £%d ¥%.1f\n%t\n", CivName[CivType[client]], RoundToFloor(WoodAmount[client]), RoundToFloor(FoodAmount[client]), GoldAmount[client], "Resource Gain Mult Villager", ResourceGenMulti(client,_,_,true), ResourceGenMulti(client, true));	
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
			FormatEx(buffer1, sizeof(buffer1), "Researching %t... (%.0f％)", BuildingUpgrade_Names[GetRData(ResearchIndex[client], UpgradeIndex)],
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
							int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);

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
			if(GetGlobalSupplyLeft() < 1)
			{
				NPC_GetNameById(GetSData(CivType[client], TrainingIndex[client], NPCIndex), buffer2, sizeof(buffer2));
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (At Maximum Server Limit)\n ", buffer2);
			}
			else if(!subtractVillager && GetSupplyLeft(client) < GetSData(CivType[client], TrainingIndex[client], SupplyCost))
			{
				NPC_GetNameById(GetSData(CivType[client], TrainingIndex[client], NPCIndex), buffer2, sizeof(buffer2));
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (At Maximum Supply)\n ", buffer2);

			//	Format(buffer1, sizeof(buffer1), "%s\nTIP: Your barricades counts towards the supply limit\n ", buffer1);
			}
			else if(TrainingStartedIn[client] < 0.0)
			{
				NPC_GetNameById(GetSData(CivType[client], TrainingIndex[client], NPCIndex), buffer2, sizeof(buffer2));
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (Spaced Occupied, somethings blocking spawns, move barracks.)\n ", buffer2);
			}
			else
			{
				float gameTime = GetGameTime();
				NPC_GetNameById(GetSData(CivType[client], TrainingIndex[client], NPCIndex), buffer2, sizeof(buffer2));
				FormatEx(buffer1, sizeof(buffer1), "Training %t... (%.0f％)\n ", buffer2,
					100.0 - ((TrainingIn[client] - gameTime) * 100.0 / (TrainingIn[client] - TrainingStartedIn[client])));
			}

			if(TrainingQueue[client] != -1)
			{
				NPC_GetNameById(GetSData(CivType[client], TrainingQueue[client], NPCIndex), buffer2, sizeof(buffer2));
				Format(buffer1, sizeof(buffer1), "%sNext: %t\n ", buffer1, buffer2);
			}
			
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
				if(TrainingIn[client] >= GetGameTime() && BarrackVillager_ID() == GetSData(CivType[client], TrainingIndex[client], NPCIndex))
				{
					//dont train more then one at a time
					poor = true;
				}
				else
				{
					char npc_classname[60];
					for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
					{
						int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);

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
				NPC_GetNameById(GetSData(CivType[client], i, NPCIndex), buffer2, sizeof(buffer2));
				Format(buffer2, sizeof(buffer2), "%s Desc", buffer2);
			}
			else
			{
				NPC_GetNameById(GetSData(CivType[client], i, NPCIndex), buffer1, sizeof(buffer1));
				Format(buffer1, sizeof(buffer1), "%t [", buffer1);
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

static int GetSupplyLeft(int client)
{
	int personal = ActiveCurrentNpcsBarracks(client);
	personal -= Rogue_Barracks_BonusSupply();
	personal -= ObjectSupply_CountBuildings();
	return 3 - personal;
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
					
					OpenSummonerMenu(client, client);
					return 0;
				}

				int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
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
								float ModifySpawnRate = 1.0;
								if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
								{
									ModifySpawnRate *= (1.0 / 1.2);
								}
								TrainingIn[client] = TrainingStartedIn[client] + (ModifySpawnRate * float(LastMann ? (GetSData(CivType[client], item, TrainTime) / 3) : GetSData(CivType[client], item, TrainTime)));
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

					OpenSummonerMenu(client, client);
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
				
				OpenSummonerMenu(client, client);
			}
		}
	}
	return 0;
}

int ActiveCurrentNpcsBarracks(int client/*, bool ignore_barricades = false*/)
{
	int userid = GetClientUserId(client);
	int personal;
	/*
	if(!ignore_barricades)
	{
		personal = ObjectBarricade_Buildings(client) * 3 / 2;
		if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
		{
			if(personal > 4) //even if you build a barricade, it will allow you to get 1 more unit.
			{
				personal = 3;
			}
		}
	}
	*/

	char npc_classname[60];
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
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
	/*
	if(!ignore_barricades)
	{
		
		if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)
		{
			personal += 1;
			if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING)
				personal -= 1;
		}
		
	}
	*/

	if(personal < 0)
	{
		personal = 0;
	}

	return personal;
}


int ActiveCurrentNpcsBarracksTotal()
{
	int CurrentAlive = 0;
	char npc_classname[60];
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(GetTeam(entity) == 2)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			NPC_GetPluginById(i_NpcInternalId[npc.index], npc_classname, sizeof(npc_classname));
			if(!StrContains(npc_classname, "npc_barrack"))
			{
				CurrentAlive++;
				if(StrEqual(npc_classname, "npc_barrack_building"))
					CurrentAlive--;
					
				if(StrEqual(npc_classname, "npc_barrack_villager"))
					CurrentAlive--;
			}
		}
	}

	return CurrentAlive;
}

int GetGlobalSupplyLeft()
{
	int CurrentAlive = ActiveCurrentNpcsBarracksTotal();
	CurrentAlive -= Rogue_Barracks_BonusSupply() * 2;
	CurrentAlive -= ObjectSupply_CountBuildings();
	return 9 - CurrentAlive;
}

void BarracksUnitAttack_NPCTakeDamagePost(int victim, int attacker, float damage, int damagetype)
{

	BarrackBody npc = view_as<BarrackBody>(attacker);
	int owner = GetClientOfUserId(npc.OwnerUserId);
	if(IsValidClient(owner))
	{

		int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[owner]);
		if(!IsValidEntity(entity))
			return;

		static char plugin[64];
		NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
		if(StrContains(plugin, "obj_barracks", false) != -1)
		{

		}
		else
		{
			return;
		}

		//make sure they have a barracks

		int MaxHealth = ReturnEntityMaxHealth(victim);
		if(damage >= float(MaxHealth))
			damage = float(MaxHealth);
			
		float gain = b_thisNpcIsARaid[victim] ? (25.0 * MultiGlobalHighHealthBoss) : (b_thisNpcIsABoss[victim] ? (10.0 * MultiGlobalHealth) : (b_IsGiant[victim] ? 2.5 : 1.0));
		gain *= 2.5;
		if(damagetype & DMG_CLUB)
		{
			gain *= 4.5;
		}

		gain = damage * gain / float(MaxHealth);
		float vecTarget[3]; WorldSpaceCenter(owner, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(attacker, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget >= (600.0 * 600.0))
		{
			gain *= 0.35;
		}
		gain *= 0.85;
		//Should ignore setup...
		SummonerRenerateResources(owner, gain, 0.0, true);
	}
}
