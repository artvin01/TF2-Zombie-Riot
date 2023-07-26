#pragma semicolon 1
#pragma newdecls required

#define ITSTILIVES 666
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT 100.0

static float f_FactionCreditGain;
static float f_FactionCreditGainReduction[MAXTF2PLAYERS];

enum
{
	NOTHING 						= 0,	
	HEADCRAB_ZOMBIE 				= 1,	
	FORTIFIED_HEADCRAB_ZOMBIE 		= 2,	
	FASTZOMBIE 						= 3,	
	FORTIFIED_FASTZOMBIE 			= 4,
	TORSOLESS_HEADCRAB_ZOMBIE 		= 5,	
	FORTIFIED_GIANT_POISON_ZOMBIE 	= 6,	
	POISON_ZOMBIE 					= 7,	
	FORTIFIED_POISON_ZOMBIE 		= 8,	
	FATHER_GRIGORI 					= 9,
	COMBINE_POLICE_PISTOL			= 10,	
	COMBINE_POLICE_SMG				= 11,	
	COMBINE_SOLDIER_AR2				= 12,
	COMBINE_SOLDIER_SHOTGUN			= 13,	
	COMBINE_SOLDIER_SWORDSMAN		= 14,
	COMBINE_SOLDIER_ELITE			= 15,
	COMBINE_SOLDIER_GIANT_SWORDSMAN	= 16,
	COMBINE_SOLDIER_DDT				= 17,
	COMBINE_SOLDIER_COLLOSS			= 18, //Hetimus
	COMBINE_OVERLORD				= 19, 
	SCOUT_ZOMBIE					= 20,
	ENGINEER_ZOMBIE					= 21,
	HEAVY_ZOMBIE					= 22,
	FLYINGARMOR_ZOMBIE				= 23,
	FLYINGARMOR_TINY_ZOMBIE			= 24,
	KAMIKAZE_DEMO					= 25,
	MEDIC_HEALER					= 26,
	HEAVY_ZOMBIE_GIANT				= 27,
	SPY_FACESTABBER					= 28,
	SOLDIER_ROCKET_ZOMBIE			= 29,
	SOLDIER_ZOMBIE_MINION			= 30,
	SOLDIER_ZOMBIE_BOSS				= 31,
	SPY_THIEF						= 32,
	SPY_TRICKSTABBER				= 33,
	SPY_HALF_CLOACKED				= 34,
	SNIPER_MAIN						= 35,
	DEMO_MAIN						= 36,
	BATTLE_MEDIC_MAIN				= 37,
	GIANT_PYRO_MAIN					= 38,
	COMBINE_DEUTSCH_RITTER			= 39,
	SPY_MAIN_BOSS					= 40,
	
	
	XENO_HEADCRAB_ZOMBIE 				= 41,	
	XENO_FORTIFIED_HEADCRAB_ZOMBIE 		= 42,	
	XENO_FASTZOMBIE 					= 43,	
	XENO_FORTIFIED_FASTZOMBIE 			= 44,
	XENO_TORSOLESS_HEADCRAB_ZOMBIE 		= 45,	
	XENO_FORTIFIED_GIANT_POISON_ZOMBIE 	= 46,	
	XENO_POISON_ZOMBIE 					= 47,	
	XENO_FORTIFIED_POISON_ZOMBIE 		= 48,	
	XENO_FATHER_GRIGORI 				= 49,
	XENO_COMBINE_POLICE_PISTOL			= 50,	
	XENO_COMBINE_POLICE_SMG				= 51,	
	XENO_COMBINE_SOLDIER_AR2			= 52,
	XENO_COMBINE_SOLDIER_SHOTGUN		= 53,	
	XENO_COMBINE_SOLDIER_SWORDSMAN		= 54,
	XENO_COMBINE_SOLDIER_ELITE			= 55,
	XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN	= 56,
	XENO_COMBINE_SOLDIER_DDT			= 57,
	XENO_COMBINE_SOLDIER_COLLOSS		= 58, //Hetimus
	XENO_COMBINE_OVERLORD				= 59, 
	XENO_SCOUT_ZOMBIE					= 60,
	XENO_ENGINEER_ZOMBIE				= 61,
	XENO_HEAVY_ZOMBIE					= 62,
	XENO_FLYINGARMOR_ZOMBIE				= 63,
	XENO_FLYINGARMOR_TINY_ZOMBIE		= 64,
	XENO_KAMIKAZE_DEMO					= 65,
	XENO_MEDIC_HEALER					= 66,
	XENO_HEAVY_ZOMBIE_GIANT				= 67,
	XENO_SPY_FACESTABBER				= 68,
	XENO_SOLDIER_ROCKET_ZOMBIE			= 69,
	XENO_SOLDIER_ZOMBIE_MINION			= 70,
	XENO_SOLDIER_ZOMBIE_BOSS			= 71,
	XENO_SPY_THIEF						= 72,
	XENO_SPY_TRICKSTABBER				= 73,
	XENO_SPY_HALF_CLOACKED				= 74,
	XENO_SNIPER_MAIN					= 75,
	XENO_DEMO_MAIN						= 76,
	XENO_BATTLE_MEDIC_MAIN				= 77,
	XENO_GIANT_PYRO_MAIN				= 78,
	XENO_COMBINE_DEUTSCH_RITTER			= 79,
	XENO_SPY_MAIN_BOSS					= 80,
	
	NAZI_PANZER							= 81,
	BOB_THE_GOD_OF_GODS					= 82,
	NECRO_COMBINE						= 83,
	NECRO_CALCIUM						= 84,
	CURED_FATHER_GRIGORI				= 85,
	
	ALT_COMBINE_MAGE					= 86,
	
	BTD_BLOON							= 87,
	BTD_MOAB							= 88,
	BTD_BFB								= 89,
	BTD_ZOMG							= 90,
	BTD_DDT								= 91,
	BTD_BAD								= 92,
	
	ALT_MEDIC_APPRENTICE_MAGE			= 93,
	SAWRUNNER							= 94,
	
	RAIDMODE_TRUE_FUSION_WARRIOR		= 95,
	ALT_MEDIC_CHARGER					= 96,
	ALT_MEDIC_BERSERKER					= 97,
	
	MEDIVAL_MILITIA						= 98,
	MEDIVAL_ARCHER						= 99,
	MEDIVAL_MAN_AT_ARMS					= 100,
	MEDIVAL_SKIRMISHER					= 101,
	MEDIVAL_SWORDSMAN					= 102,
	MEDIVAL_TWOHANDED_SWORDSMAN			= 103,
	MEDIVAL_CROSSBOW_MAN				= 104,
	MEDIVAL_SPEARMEN					= 105,
	MEDIVAL_HANDCANNONEER				= 106,
	MEDIVAL_ELITE_SKIRMISHER			= 107,
	RAIDMODE_BLITZKRIEG					= 108,
	MEDIVAL_PIKEMAN						= 109,
	ALT_MEDIC_SUPPERIOR_MAGE			= 110,
	CITIZEN								= 111,
	
	MEDIVAL_EAGLE_SCOUT					= 112,
	MEDIVAL_SAMURAI						= 113,
	
	THEADDICTION						= 114,
	THEDOCTOR							= 115,
	BOOKSIMON							= 116,
	ALT_KAHMLSTEIN						= 117,
	
	L4D2_TANK							= 118,
	ALT_COMBINE_DEUTSCH_RITTER			= 119,
	ALT_SNIPER_RAILGUNNER				= 120,
	
	BTD_GOLDBLOON	= 121,
	BTD_BLOONARIUS	= 122,
	BTD_LYCH		= 123,
	BTD_LYCHSOUL	= 124,
	BTD_VORTEX	= 125,
	
	MEDIVAL_RAM	= 126,
	ALT_SOLDIER_BARRAGER = 127,
	ALT_The_Shit_Slapper = 128,
	
	BONEZONE_BASICBONES = 129,
	
	ALT_MECHA_ENGINEER			= 130,
	ALT_MECHA_HEAVY				= 131,
	ALT_MECHA_HEAVYGIANT		= 132,
	ALT_MECHA_PYROGIANT			= 133,
	ALT_MECHA_SCOUT				= 134,
	ALT_DONNERKRIEG				= 135,
	ALT_SCHWERTKRIEG			= 136,
	PHANTOM_KNIGHT				= 137, //Lucian "Blood diamond"
	ALT_MEDIC_HEALER_3			= 138, //3 being the 3rd stage of alt waves.
	
	THE_GAMBLER				= 139,
	PABLO_GONZALES				= 140,
	DOKTOR_MEDICK				= 141,
	KAPTAIN_HEAVY				= 142,
	BOOTY_EXECUTIONIER 			= 143,
	SANDVICH_SLAYER 			= 144,
	PAYDAYCLOAKER				= 145,
	BUNKER_KAHML_VTWO			= 146,
	TRUE_ZEROFUSE				= 147,
	BUNKER_BOT_SOLDIER			= 148,
	BUNKER_BOT_SNIPER			= 149,
	BUNKER_SKELETON				= 150,
	BUNKER_SMALL_SKELETON		= 151,
	BUNKER_KING_SKELETON		= 152,
	BUNKER_HEADLESSHORSE		= 153,

	MEDIVAL_SCOUT				= 154,
	MEDIVAL_VILLAGER			= 155,
	MEDIVAL_BUILDING			= 156,
	MEDIVAL_CONSTRUCT			= 157,
	MEDIVAL_CHAMPION			= 158,
	MEDIVAL_LIGHT_CAV			= 159,
	MEDIVAL_HUSSAR				= 160,
	MEDIVAL_KNIGHT				= 161,
	MEDIVAL_OBUCH				= 162,
	MEDIVAL_MONK				= 163,

	BARRACK_MILITIA				= 164,
	BARRACK_ARCHER				= 165,
	BARRACK_MAN_AT_ARMS			= 166,

	MEDIVAL_HALB				= 167,
	MEDIVAL_BRAWLER				= 168,
	MEDIVAL_LONGBOWMEN			= 169,
	MEDIVAL_ARBALEST			= 170,
	MEDIVAL_ELITE_LONGBOWMEN	= 171,

	BARRACK_CROSSBOW			= 172,
	BARRACK_SWORDSMAN			= 173,
	BARRACK_ARBELAST			= 174,
	BARRACK_TWOHANDED			= 175,
	BARRACK_LONGBOW				= 176,
	BARRACK_CHAMPION			= 177,
	BARRACK_MONK				= 178,
	BARRACK_HUSSAR				= 179,
	
	MEDIVAL_CAVALARY			= 180,
	MEDIVAL_PALADIN				= 181,
	MEDIVAL_CROSSBOW_GIANT		= 182,
	MEDIVAL_SWORDSMAN_GIANT		= 183,
	MEDIVAL_RIDDENARCHER		= 184,
	MEDIVAL_EAGLE_WARRIOR		= 185,
	MEDIVAL_EAGLE_GIANT			= 186,
	MEDIVAL_SON_OF_OSIRIS		= 187,
	MEDIVAL_ACHILLES			= 188,
	MEDIVAL_TREBUCHET			= 189,
	
	ALT_IKUNAGAE				= 190,
	ALT_MECHASOLDIER_BARRAGER	= 191,
	NEARL_SWORD					= 192,
	
	STALKER_COMBINE		= 193,
	STALKER_FATHER		= 194,
	STALKER_GOGGLES		= 195,

	XENO_RAIDBOSS_SILVESTER		= 196,
	XENO_RAIDBOSS_BLUE_GOGGLES	= 197,
	XENO_RAIDBOSS_SUPERSILVESTER	= 198,
	XENO_RAIDBOSS_NEMESIS	= 199,

	SEARUNNER	= 200,
	SEARUNNER_ALT,
	SEASLIDER	= 202,
	SEASLIDER_ALT,
	SEASPITTER	= 204,
	SEASPITTER_ALT,
	SEAREAPER	= 206,
	SEAREAPER_ALT,
	SEACRAWLER	= 208,
	SEACRAWLER_ALT,
	SEAPIERCER	= 210,
	SEAPIERCER_ALT,
	FIRSTTOTALK	= 212,
	UNDERTIDES	= 213,
	SEABORN_KAZIMIERZ_KNIGHT	= 214,
	SEABORN_KAZIMIERZ_KNIGHT_ARCHER	= 215,
	SEABORN_KAZIMIERZ_BESERKER	= 216,
	SEABORN_KAZIMIERZ_LONGARCHER	= 217,
	REMAINS		= 218,
	ENDSPEAKER_1	= 219,
	ENDSPEAKER_2	= 220,
	ENDSPEAKER_3	= 221,
	ENDSPEAKER_4	= 222,
	SEAFOUNDER	= 223,
	SEAFOUNDER_ALT,
	SEAFOUNDER_CARRIER,
	SEAPREDATOR	= 226,
	SEAPREDATOR_ALT,
	SEAPREDATOR_CARRIER,
	SEABRANDGUIDER	= 229,
	SEABRANDGUIDER_ALT,
	SEABRANDGUIDER_CARRIER,
	SEABORN_KAZIMIERZ_ASSASIN_MELEE	= 232,
	SEASPEWER	= 233,
	SEASPEWER_ALT,
	SEASPEWER_CARRIER,
	SEASWARMCALLER	= 236,
	SEASWARMCALLER_ALT,
	SEASWARMCALLER_CARRIER,
	SEAREEFBREAKER	= 239,
	SEAREEFBREAKER_ALT,
	SEAREEFBREAKER_CARRIER,
	BARRACK_THORNS	= 242,
	RAIDMODE_GOD_ARKANTOS = 243,
	SEABORN_SCOUT		= 244,
	SEABORN_SOLDIER		= 245,
	CITIZEN_RUNNER		= 246,
	SEABORN_PYRO		= 247,
	SEABORN_DEMO		= 248,
	SEABORN_HEAVY		= 249,
	SEABORN_ENGINEER	= 250,
	SEABORN_MEDIC		= 251,
	SEABORN_SNIPER		= 252,
	SEABORN_SPY		= 253,
	ALT_BARRACKS_SCHWERTKRIEG = 254,
	ALT_BARRACK_IKUNAGAE = 255,
	ALT_BARRACK_RAILGUNNER = 256,
	ALT_BARRACK_BASIC_MAGE = 257,
	ALT_BARRACK_INTERMEDIATE_MAGE = 258,
	ALT_BARRACK_DONNERKRIEG = 259,
	ALT_BARRACKS_HOLY_KNIGHT = 260,
	ALT_BARRACK_MECHA_BARRAGER = 261,
	ALT_BARRACK_BARRAGER = 262,
	ALT_BARRACKS_BERSERKER = 263,
	ALT_BARRACKS_CROSSBOW_MEDIC = 264,
	LASTKNIGHT		= 265,
	BARRACK_LASTKNIGHT	= 266,
	SAINTCARMEN		= 267,
	PATHSHAPER		= 268,
	PATHSHAPER_FRACTAL	= 269,
	BARRACKS_TEUTONIC_KNIGHT	= 270,
	BARRACKS_VILLAGER			= 271,
	BARRACKS_BUILDING			= 272,
	TIDELINKED_BISHOP	= 273,
	TIDELINKED_ARCHON	= 274,
	ALT_BARRACK_SCIENTIFIC_WITCHERY = 275,
	SEABORN_GUARD		= 276,
	SEABORN_DEFENDER	= 277,
	SEABORN_VANGUARD	= 278,
	SEABORN_CASTER		= 279,
	SEABORN_SPECIALIST	= 280,
	SEABORN_SUPPORTER	= 281,
	ISHARMLA		= 282,
	ISHARMLA_TRANS		= 283,
	
	//ruina
	RUINA_THEOCRACY = 284,
	EXPIDONSA_BENERA = 285,
	EXPIDONSA_PENTAL = 286,
	EXPIDONSA_DEFANDA = 287,
	EXPIDONSA_SELFAM_IRE = 288,
	EXPIDONSA_VAUSMAGICA = 289,
	EXPIDONSA_PISTOLEER = 290,
	EXPIDONSA_DIVERSIONISTICO 	= 291,
	RUINA_ADIANTUM 				= 292,
	RUINA_LANIUS				= 293,
	EXPIDONSA_HEAVYPUNUEL		= 294,
	RUINA_MAGIA					= 295,
	EXPIDONSA_SEARGENTIDEAL		= 296,
}

public const char NPC_Names[][] =
{
	"nothing",
	"Headcrab Zombie",
	"Fortified Headcrab Zombie",
	"Fast Zombie",
	"Fortified Fast Zombie",
	"Torsoless Headcrab Zombie",
	"Fortified Giant Poison Zombie",
	"Poison Zombie",
	"Fortified Poison Zombie",
	"Father Grigori",
	"Metro Cop",
	"Metro Raider",
	"Combine Rifler",
	"Combine Shotgunner",
	"Combine Swordsman",
	"Combine Elite",
	"Combine Giant Swordsman",
	"Combine DDT",
	"Combine Golden Collos",
	"Combine Overlord",
	"Scout Assulter",
	"Engineer Deconstructor",
	"Heavy Brawler",
	"Flying Armor",
	"Tiny Flying Armor",
	"Kamikaze Demo",
	"Medic Supporter",
	"Giant Heavy Brawler",
	"Spy Facestabber",
	"Soldier Rocketeer",
	"Soldier Minion",
	"Soldier Giant Summoner",
	"Spy Thief",
	"Spy Trickstabber",
	"Half Cloaked Spy",
	"Sniper Main",
	"Demoknight Main",
	"Battle Medic Main",
	"Giant Pyro Main",
	"Combine Deutsch Ritter",
	"X10 Spy Main",
	
	//XENO
	
	"Xeno Headcrab Zombie",
	"Xeno Fortified Headcrab Zombie",
	"Xeno Fast Zombie",
	"Xeno Fortified Fast Zombie",
	"Xeno Torsoless Headcrab Zombie",
	"Xeno Fortified Giant Poison Zombie",
	"Xeno Poison Zombie",
	"Xeno Fortified Poison Zombie",
	"Xeno Father Grigori",
	"Xeno Metro Cop",
	"Xeno Metro Raider",
	"Xeno Combine Rifler",
	"Xeno Combine Shotgunner",
	"Xeno Combine Swordsman",
	"Xeno Combine Elite",
	"Xeno Combine Giant Swordsman",
	"Xeno Combine DDT",
	"Xeno Combine Golden Collos",
	"Xeno Combine Overlord",
	"Xeno Scout Assulter",
	"Xeno Engineer Deconstructor",
	"Xeno Heavy Brawler",
	"Xeno Flying Armor",
	"Xeno Tiny Flying Armor",
	"Xeno Kamikaze Demo",
	"Xeno Medic Supporter",
	"Xeno Giant Heavy Brawler",
	"Xeno Spy Facestabber",
	"Xeno Soldier Rocketeer",
	"Xeno Soldier Minion",
	"Xeno Soldier Giant Summoner",
	"Xeno Spy Thief",
	"Xeno Spy Trickstabber",
	"Xeno Half Cloaked Spy",
	"Xeno Sniper Main",
	"Xeno Demoknight Main",
	"Xeno Battle Medic Main",
	"Xeno Giant Pyro Main",
	"Xeno Combine Deutsch Ritter",
	"Xeno X10 Spy Main",
	
	"Nazi Panzer",
	"Bob the Overgod of gods and destroyer of multiverses",
	"Revived Combine DDT",
	"Spookmaster Boner",
	"Cured Father Grigori",
	"Combine Mage",
	
	"Bloon",
	"Massive Ornery Air Blimp",
	"Brutal Floating Behemoth",
	"Zeppelin of Mighty Gargantuaness",
	"Dark Dirigible Titan",
	"Big Airship of Doom",
	
	
	"Medic Apprentice Mage",
	"Sawrunner",
	"True Fusion Warrior",
	"Medic Charger",
	"Medic Berserker",
	"Militia",
	"Archer",
	"Man-At-Arms",
	"Skirmisher",
	"Long Swordsman",
	"Twohanded Swordsman",
	"Crossbow Man",
	"Spearman",
	"Hand Cannoneer",
	"Elite Skirmisher",
	"Blitzkrieg",
	"Pikeman",
	"Medic Supperior Mage",
	"Rebel",
	"Eagle Scout",
	"Samurai",
	"The Addiction",
	"The Doctor",
	"Book Simon",
	"Kahmlstein",
	"L4D2 Tank",
	"Holy Knight",
	"Sniper Railgunner",
	
	"Gold Bloon",
	"Bloonarius",
	"Gravelord Lych",
	"Lych-Soul",
	"Vortex",
	
	"Capped Ram",
	"Soldier Barrager",
	"The Shit Slapper",
	
	"Basic Bones",
	
	"Mecha Engineer",
	"Mecha Heavy",
	"Mecha Giant Heavy",
	"Mecha Giant Pyro",
	"Mecha Scout",
	"Donnerkrieg",
	"Schwertkrieg",
	"Phantom Knight",
	"Medic Constructor",
	
	"Gambler",
	"Pablo Gonzales",
	"Doktor Medick",
	"Eternal Kaptain Heavy",
	"Booty Executioner",
	"Sandvich Slayer",
	"Payday Cloaker",
	"Bunker Kahmlstein",
	"Zerofuse",
	"Bunker Bot Soldier",
	"Bunker Bot Sniper",
	"Bunker Skeleton",
	"Bunker Small Skeleton",
	"Bunker Skeleton King",
	"Bunker Headless Horseman",

	"Medival Scout",
	"Medival Villager",
	"Building",
	"Medival Construct",
	"Champion",
	"Light Cavalry",
	"Hussar",
	"Knight",
	"Obuch",
	"Monk",

	"Militia",
	"Archer",
	"Man-At-Arms",

	"Medival Halberdier",
	"Medival Brawler",
	"Medival Longbowmen",
	"Medival Abalest",
	"Medival Elite Longbowmen",

	"Crossbow Man",
	"Long Swordsman",
	"Medival Abalest",
	"Twohanded Swordsman",
	"Medival Longbowmen",
	"Champion",
	"Monk",
	"Hussar",

	"Cavalary",
	"Paladin",
	"Crossbow Giant",
	"Swordsman Giant",
	"Mounted Archer",
	"Eagle Warrior",
	"Giant Eagle Warrior",
	"Son Of Osiris",
	"Achilles",
	"Trebuchet",
	
	"Ikunagae",
	"Mecha Soldier Barrager",
	"Nearl Radiant Sword",

	"Spawned Combine",
	"Spawned Father Grigori",
	"Spawned Blue Goggles",

	"Silvester",
	"Blue Goggles",
	"Angeled Silvester",
	"Nemesis",

	"Shell Sea Runner",
	"Nourished Runner",
	"Deep Sea Slider",
	"Nourished Slider",
	"Ridge Sea Spitter",
	"Nourished Spitter",
	"Basin Sea Reaper",
	"Nourished Reaper",
	"Pocket Sea Crawler",
	"Nourished Crawler",
	"Primal Sea Piercer",
	"Nourished Piercer",
	"The First To Talk",
	"Sal Viento Bishop Quintus",
	"Armorless Union Knight",
	"Roar Knightclub Trainee",
	"Bloodboil Knightclub Trainee",
	"Armorless Union Cleanup Squad",
	"Consumable Remains",
	"The Endspeaker, Will of We Many",
	"The Endspeaker, Will of We Many",
	"The Endspeaker, Will of We Many",
	"The Endspeaker, Will of We Many",
	"Nethersea Founder",
	"Nourished Founder",
	"Regressed Founder",
	"Nethersea Predator",
	"Nourished Predator",
	"Regressed Predator",
	"Nethersea Brandguider",
	"Nourished Brandguider",
	"Regressed Brandguider",
	"Armorless Union Assassin",
	"Nethersea Spewer",
	"Nourished Spewer",
	"Regressed Spewer",
	"Nethersea Swarmcaller",
	"Nourished Swarmcaller",
	"Regressed Swarmcaller",
	"Nethersea Reefbreaker",
	"Nourished Reefbreaker",
	"Regressed Reefbreaker",
	"Thorns",
	"God Arkantos",
	"Seaborn Scout",
	"Seaborn Soldier",
	"Citizen",
	"Seaborn Pyro",
	"Seaborn Demoman",
	"Seaborn Heavy",
	"Seaborn Engineer",
	"Seaborn Medic",
	"Seaborn Sniper",
	"Seaborn Spy",
	"Barracks SchwertKrieg",	
	"Barracks Ikunagae",
	"Barracks Railgunner",
	"Barracks Basic Mage",
	"Barracks Intermediate Mage",
	"Barracks Donnerkrieg",
	"Barracks Holy Knight",
	"Barracks Mecha Barrager",
	"Barracks Barrager",
	"Barracks Berserker",
	"Barracks Crossbow Medic",
	"The Last Knight",
	"Tide-Hunt Knight",
	"Saint Carmen",
	"Pathshaper",
	"Pathshaper Fractal",
	"Barracks Teutonic Knight",
	"Barracks Villager",
	"Barracks Building",
	"Tidelinked Bishop",
	"Tidelinked Archon",
	"Scientific Witchery",
	"Seaborn Guard",
	"Seaborn Defender",
	"Seaborn Vanguard",
	"Seaborn Caster",
	"Seaborn Specialist",
	"Seaborn Supporter",
	"Ishar'mla, Heart of Corruption",
	"Ishar'mla, Heart of Corruption",
	"Theocracy",
	"Benera",
	"Pental",
	"Defanda",
	"Selfam Ire",
	"Vaus Magica",
	"Pistoleer",
	"Diversionistico",
	"Adiantum",
	"Lanius",
	"Heavy Punuel",
	"Magia",
	"Seargent Ideal"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"npc_nothing",
	"npc_headcrabzombie",
	"npc_headcrabzombie_fortified",
	"npc_fastzombie",
	"npc_fastzombie_fortified",
	"npc_torsoless_headcrabzombie",
	"npc_poisonzombie_fortified_giant",
	"npc_poisonzombie",
	"npc_poisonzombie_fortified",
	"npc_last_survivor",
	"npc_combine_police_pistol",
	"npc_combine_police_smg",
	"npc_combine_soldier_ar2",
	"npc_combine_soldier_shotgun",
	"npc_combine_soldier_swordsman",
	"npc_combine_soldier_elite",
	"npc_combine_soldier_giant_swordsman",
	"npc_combine_soldier_swordsman_ddt",
	"npc_combine_soldier_collos_swordsman",
	"npc_combine_soldier_overlord",
	"npc_zombie_scout_grave",
	"npc_zombie_engineer_grave",
	"npc_zombie_heavy_grave",
	"npc_flying_armor",
	"npc_flying_armor_tiny_swords",
	"npc_kamikaze_demo",
	"npc_medic_healer",
	"npc_zombie_heavy_giant_grave",
	"npc_zombie_spy_grave",
	"npc_zombie_soldier_grave",
	"npc_zombie_soldier_minion_grave",
	"npc_zombie_soldier_giant_grave",
	"npc_spy_thief",
	"npc_spy_trickstabber",
	"npc_spy_half_cloacked_main",
	"npc_sniper_main",
	"npc_zombie_demo_main",
	"npc_medic_main",
	"npc_zombie_pyro_giant_main",
	"npc_combine_soldier_deutsch_ritter",
	"npc_spy_boss",
	
	//XENO
	
	"npc_xeno_headcrabzombie",
	"npc_xeno_headcrabzombie_fortified",
	"npc_xeno_fastzombie",
	"npc_xeno_fastzombie_fortified",
	"npc_xeno_torsoless_headcrabzombie",
	"npc_xeno_poisonzombie_fortified_giant",
	"npc_xeno_poisonzombie",
	"npc_xeno_poisonzombie_fortified",
	"npc_xeno_last_survivor",
	"npc_xeno_combine_police_pistol",
	"npc_xeno_combine_police_smg",
	"npc_xeno_combine_soldier_ar2",
	"npc_xeno_combine_soldier_shotgun",
	"npc_xeno_combine_soldier_swordsman",
	"npc_xeno_combine_soldier_elite",
	"npc_xeno_combine_soldier_giant_swordsman",
	"npc_xeno_combine_soldier_swordsman_ddt",
	"npc_xeno_combine_soldier_collos_swordsman",
	"npc_xeno_combine_soldier_overlord",
	"npc_xeno_zombie_scout_grave",
	"npc_xeno_zombie_engineer_grave",
	"npc_xeno_zombie_heavy_grave",
	"npc_xeno_flying_armor",
	"npc_xeno_flying_armor_tiny_swords",
	"npc_xeno_kamikaze_demo",
	"npc_xeno_medic_healer",
	"npc_xeno_zombie_heavy_giant_grave",
	"npc_xeno_zombie_spy_grave",
	"npc_xeno_zombie_soldier_grave",
	"npc_xeno_zombie_soldier_minion_grave",
	"npc_xeno_zombie_soldier_giant_grave",
	"npc_xeno_spy_thief",
	"npc_xeno_spy_trickstabber",
	"npc_xeno_spy_half_cloacked_main",
	"npc_xeno_sniper_main",
	"npc_xeno_zombie_demo_main",
	"npc_xeno_medic_main",
	"npc_xeno_zombie_pyro_giant_main",
	"npc_xeno_combine_soldier_deutsch_ritter",
	"npc_xeno_spy_boss",
	
	"npc_panzer",
	"npc_bob_the_overlord",
	"npc_necromancy_combine",
	"npc_necromancy_calcium",
	"npc_cured_last_survivor",
	
	"npc_alt_combine_soldier_mage",
	
	"npc_bloon",
	"",
	"",
	"",
	"",
	"",
	"npc_alt_medic_apprentice_mage",
	"npc_sawrunner",
	"npc_true_fusion_warrior",
	"npc_alt_medic_charger",
	"npc_alt_medic_berserker",
	"npc_medival_militia",
	"npc_medival_archer",
	"npc_medival_man_at_arms",
	"npc_medival_skrirmisher",
	"npc_medival_swordsman",
	"npc_medival_twohanded_swordsman",
	"npc_medival_crossbow",
	"npc_medival_spearmen",
	"npc_medival_handcannoneer",
	"npc_medival_elite_skirmisher",
	"npc_blitzkrieg",
	"npc_medival_pikeman",
	"npc_alt_medic_supperior_mage",
	"npc_citizen",
	"npc_medival_eagle_scout",
	"npc_medival_samurai",
	"",
	"",
	"",
	"npc_alt_kahml",
	"npc_l4d2_tank",
	"npc_alt_combine_soldier_deutsch_ritter",
	"npc_alt_sniper_railgunner",
	"npc_golden_bloon",
	"",
	"",
	"",
	"",
	"npc_medival_ram",
	"npc_alt_soldier_barrager",
	"npc_alt_the_shit_slapper",
	
	"npc_basicbones",
	
	"npc_alt_mecha_engineer",
	"npc_alt_mecha_heavy",
	"npc_alt_mecha_heavy_giant",
	"npc_alt_mecha_pyro_giant",
	"npc_alt_mecha_scout",
	"npc_alt_donnerkrieg",
	"npc_alt_schwertkrieg",
	"npc_phantom_knight",
	"npc_alt_medic_healer_3",			//3 being the 3rd stage of alt waves.
	
	"npc_gambler",
	"npc_pablo",
	"npc_dokmedick",
	"npc_kapheavy",
	"npc_booty_execut",
	"npc_sand_slayer",
	"npc_payday_cloaker",
	"npc_bunker_kahml",
	"npc_zerofuse",
	"npc_bunker_bot_soldier",
	"npc_bunker_bot_sniper",
	"npc_bunker_skeleton",
	"npc_bunker_small_skeleton",
	"npc_bunker_king_skeleton",
	"npc_bunker_hhh",
	"npc_medival_scout",
	"npc_medival_villager",
	"npc_medival_building",
	"npc_medival_construct",
	"npc_medival_champion",
	"npc_medival_light_cav",
	"npc_medival_hussar",
	"npc_medival_knight",
	"npc_medival_obuch",
	"npc_medival_monk",

	"",
	"",
	"",

	"npc_medival_halbadeer",
	"npc_medival_brawler",
	"npc_medival_longbowmen",
	"npc_medival_arbalest",
	"npc_medival_elite_longbowmen",

	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_barrack_hussar",

	"npc_medival_cavalary",
	"npc_medival_paladin",
	"npc_medival_crossbow_giant",
	"npc_medival_swordsman_giant",
	"npc_medival_riddenarcher",
	"npc_medival_eagle_warrior",
	"npc_medival_eagle_giant",
	"npc_medival_son_of_osiris",
	"npc_medival_achilles",
	"npc_medival_trebuchet",
	"npc_alt_ikunagae",
	"npc_alt_mecha_soldier_barrager",
	"",

	"npc_stalker_combine",
	"npc_stalker_father",
	"npc_stalker_goggles",

	"npc_xeno_raidboss_silvester",
	"npc_xeno_raidboss_blue_goggles",
	"",
	"npc_xeno_raidboss_nemesis",

	"npc_searunner",
	"",
	"npc_seaslider",
	"",
	"npc_seaspitter",
	"",
	"npc_seareaper",
	"",
	"npc_seacrawler",
	"",
	"npc_seapiercer",
	"",
	"npc_firsttotalk",
	"npc_undertides",
	"npc_seaborn_kazimersch_knight",
	"npc_seaborn_kazimersch_archer",
	"npc_seaborn_kazimersch_beserker",
	"npc_seaborn_kazimersch_longrange",
	"npc_endspeaker_freeplay",
	"npc_endspeaker_1",
	"npc_endspeaker_2",
	"npc_endspeaker_3",
	"npc_endspeaker_4",
	"npc_netherseafounder",
	"",
	"",
	"npc_netherseapredator",
	"",
	"",
	"npc_netherseabrandguider",
	"",
	"",
	"npc_seaborn_kazimersch_melee_assasin",
	"npc_netherseaspewer",
	"",
	"",
	"npc_netherseaswarmcaller",
	"",
	"",
	"npc_netherseareefbreaker",
	"",
	"",
	"",
	"npc_god_arkantos",
	"npc_seaborn_scout",
	"npc_seaborn_soldier",
	"npc_citizen_runner",
	"npc_seaborn_pyro",
	"npc_seaborn_demo",
	"npc_seaborn_heavy",
	"npc_seaborn_engineer",
	"npc_seaborn_medic",
	"npc_seaborn_sniper",
	"npc_seaborn_spy",
	
	"",	//schwert
	"",	//Iku
	"",	//Railgunner
	"",	//Basic Mage
	"",	//Intermediate mage
	"",	//Donnerkrieg
	"",	//Holy Knights
	"",	//mecha barragers
	"",	//Barrager
	"",	//Bereserker
	"",	//Medic Crossbowman

	"npc_lastknight",
	"",
	"npc_saintcarmen",
	"npc_pathshaper",
	"npc_pathshaper_fractal",
	"",
	"",
	"",
	"npc_tidelinkedbishop",
	"npc_tidelinkedarchon",
	"",	//Scientific Witchery
	"npc_seaborn_guard",
	"npc_seaborn_defender",
	"npc_seaborn_vanguard",
	"npc_seaborn_caster",
	"npc_seaborn_specialist",
	"npc_seaborn_supporter",
	"npc_isharmla",
	"npc_isharmla_trans",
	
	"npc_ruina_theocracy",	//warp
	"npc_benera",
	"npc_pental",
	"npc_defanda",
	"npc_selfam_ire",
	"npc_vaus_magica",
	"npc_benera_pistoleer",
	"npc_diversionistico",
	"npc_ruina_adiantum",
	"npc_ruina_lanius",
	"npc_heavy_punuel",
	"npc_ruina_magia",
	"npc_seargent_ideal"
};

void NPC_MapStart()
{
	f_FactionCreditGain = 0.0;
	Zero(f_FactionCreditGainReduction);
	HeadcrabZombie_OnMapStart_NPC();
	Fortified_HeadcrabZombie_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	FortifiedFastZombie_OnMapStart_NPC();
	TorsolessHeadcrabZombie_OnMapStart_NPC();
	FortifiedGiantPoisonZombie_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	FortifiedPoisonZombie_OnMapStart_NPC();
	FatherGrigori_OnMapStart_NPC();
	
	Combine_Police_Pistol_OnMapStart_NPC();
	CombinePoliceSmg_OnMapStart_NPC();
	CombineSoldierAr2_OnMapStart_NPC();
	CombineSoldierShotgun_OnMapStart_NPC();
	CombineSwordsman_OnMapStart_NPC();
	CombineElite_OnMapStart_NPC();
	CombineGaint_OnMapStart_NPC();
	CombineDDT_OnMapStart_NPC();
	CombineCollos_OnMapStart_NPC();
	CombineOverlord_OnMapStart_NPC();
	
	Scout_OnMapStart_NPC();
	Engineer_OnMapStart_NPC();
	Heavy_OnMapStart_NPC();
	FlyingArmor_OnMapStart_NPC();
	FlyingArmorTiny_OnMapStart_NPC();
	Kamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	HeavyGiant_OnMapStart_NPC();
	Spy_OnMapStart_NPC();
	Soldier_OnMapStart_NPC();
	SoldierMinion_OnMapStart_NPC();
	SoldierGiant_OnMapStart_NPC();
	
	SpyThief_OnMapStart_NPC();
	SpyTrickstabber_OnMapStart_NPC();
	SpyCloaked_OnMapStart_NPC();
	SniperMain_OnMapStart_NPC();
	DemoMain_OnMapStart_NPC();
	MedicMain_OnMapStart_NPC();
	PyroGiant_OnMapStart_NPC();
	CombineDeutsch_OnMapStart_NPC();
	Alt_CombineDeutsch_OnMapStart_NPC();
	SpyMainBoss_OnMapStart_NPC();
	MedivalVillager_OnMapStart_NPC();
	/*
	XenoHeadcrabZombie_OnMapStart_NPC();
	XenoFortified_HeadcrabZombie_OnMapStart_NPC();
	XenoFastZombie_OnMapStart_NPC();
	XenoFortifiedFastZombie_OnMapStart_NPC();
	XenoTorsolessHeadcrabZombie_OnMapStart_NPC();
	XenoFortifiedGiantPoisonZombie_OnMapStart_NPC();
	XenoPoisonZombie_OnMapStart_NPC();
	XenoFortifiedPoisonZombie_OnMapStart_NPC();
	*/
	XenoFatherGrigori_OnMapStart_NPC();
	/*
	XenoCombine_Police_Pistol_OnMapStart_NPC();
	XenoCombinePoliceSmg_OnMapStart_NPC();
	XenoCombineSoldierAr2_OnMapStart_NPC();
	XenoCombineSoldierShotgun_OnMapStart_NPC();
	XenoCombineSwordsman_OnMapStart_NPC();
	XenoCombineElite_OnMapStart_NPC();
	XenoCombineGaint_OnMapStart_NPC();
	XenoCombineDDT_OnMapStart_NPC();
	XenoCombineCollos_OnMapStart_NPC();
	XenoCombineOverlord_OnMapStart_NPC();
	
	XenoScout_OnMapStart_NPC();
	XenoEngineer_OnMapStart_NPC();
	XenoHeavy_OnMapStart_NPC();
	XenoFlyingArmor_OnMapStart_NPC();
	XenoFlyingArmorTiny_OnMapStart_NPC();
	XenoKamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	XenoHeavyGiant_OnMapStart_NPC();
	XenoSpy_OnMapStart_NPC();
	XenoSoldier_OnMapStart_NPC();
	XenoSoldierMinion_OnMapStart_NPC();
	XenoSoldierGiant_OnMapStart_NPC();
	*/
	
	/*
	XenoSpyThief_OnMapStart_NPC();
	XenoSpyTrickstabber_OnMapStart_NPC();
	XenoSpyCloaked_OnMapStart_NPC();
	XenoSniperMain_OnMapStart_NPC();
	XenoDemoMain_OnMapStart_NPC();
	XenoMedicMain_OnMapStart_NPC();
	XenoPyroGiant_OnMapStart_NPC();
	XenoCombineDeutsch_OnMapStart_NPC();
	XenoSpyMainBoss_OnMapStart_NPC();
	*/
	NaziPanzer_OnMapStart_NPC();
	BobTheGod_OnMapStart_NPC();
	NecroCombine_OnMapStart_NPC();
	NecroCalcium_OnMapStart_NPC();
	CuredFatherGrigori_OnMapStart_NPC();
	
	AltMedicApprenticeMage_OnMapStart_NPC();
	SawRunner_OnMapStart_NPC();
	AltMedicCharger_OnMapStart_NPC();
	AltMedicBerseker_OnMapStart_NPC();
	
	MedivalMilitia_OnMapStart_NPC();
	MedivalArcher_OnMapStart_NPC();
	MedivalManAtArms_OnMapStart_NPC();
	MedivalSkirmisher_OnMapStart_NPC();
	MedivalSwordsman_OnMapStart_NPC();
	MedivalTwoHandedSwordsman_OnMapStart_NPC();
	MedivalCrossbowMan_OnMapStart_NPC();
	MedivalSpearMan_OnMapStart_NPC();
	MedivalHandCannoneer_OnMapStart_NPC();
	MedivalEliteSkirmisher_OnMapStart_NPC();
	MedivalPikeman_OnMapStart_NPC();
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC();
	Citizen_OnMapStart();
	MedivalEagleScout_OnMapStart_NPC();
	MedivalSamurai_OnMapStart_NPC();
	Kahmlstein_OnMapStart_NPC();
	Sniper_railgunner_OnMapStart_NPC();
	
	L4D2_Tank_OnMapStart_NPC();
	MedivalRam_OnMapStart();
	
	Soldier_Barrager_OnMapStart_NPC();
	The_Shit_Slapper_OnMapStart_NPC();
	
	BasicBones_OnMapStart_NPC();
	Itstilives_MapStart();
	
	Mecha_Engineer_OnMapStart_NPC();
	Mecha_Heavy_OnMapStart_NPC();
	Mecha_HeavyGiant_OnMapStart_NPC();
	Mecha_PyroGiant_OnMapStart_NPC();
	Mecha_Scout_OnMapStart_NPC();
	
	Donnerkrieg_OnMapStart_NPC();
	Schwertkrieg_OnMapStart_NPC();
	PhantomKnight_OnMapStart_NPC();
	Alt_Medic_Constructor_OnMapStart_NPC();	//3rd alt medic.
	
	TheGambler_OnMapStart_NPC();
	Pablo_Gonzales_OnMapStart_NPC();
	Doktor_Medick_OnMapStart_NPC();
	Eternal_Kaptain_Heavy_OnMapStart_NPC();
	BootyExecutioner_OnMapStart_NPC();
	SandvichSlayer_OnMapStart_NPC();
	Payday_Cloaker_OnMapStart_NPC();
	BunkerKahml_OnMapStart_NPC();
	TrueZerofuse_OnMapStart_NPC();
	BunkerBotSoldier_OnMapStart_NPC();
	BunkerBotSniper_OnMapStart_NPC();
	BunkerSkeleton_OnMapStart_NPC();
	BunkerSkeletonSmall_OnMapStart_NPC();
	BunkerSkeletonKing_OnMapStart_NPC();
	BunkerHeadlessHorse_OnMapStart_NPC();

	MedivalScout_OnMapStart_NPC();
	MedivalBuilding_OnMapStart_NPC();
	MedivalConstruct_OnMapStart_NPC();
	MedivalChampion_OnMapStart_NPC();
	MedivalLightCav_OnMapStart_NPC();
	MedivalHussar_OnMapStart_NPC();
	MedivalKnight_OnMapStart_NPC();
	MedivalObuch_OnMapStart_NPC();
	MedivalMonk_OnMapStart_NPC();
	MedivalHalb_OnMapStart_NPC();
	MedivalBrawler_OnMapStart_NPC();
	MedivalLongbowmen_OnMapStart_NPC();
	MedivalArbalest_OnMapStart_NPC();
	MedivalEliteLongbowmen_OnMapStart_NPC();
	MedivalEagleWarrior_OnMapStart_NPC();
	MedivalRiddenArcher_OnMapStart_NPC();
	MedivalSonOfOsiris_OnMapStart_NPC();
	MedivalAchilles_OnMapStart_NPC();
	
	Ikunagae_OnMapStart_NPC();
	MechaSoldier_Barrager_OnMapStart_NPC();
	NearlSwordAbility_OnMapStart_NPC();

	SeaRunner_MapStart();
	SeaPiercer_MapStart();
	SeaCrawler_MapStart();
	FirstToTalk_MapStart();
	UnderTides_MapStart();
	KazimierzKnight_OnMapStart_NPC();
	KazimierzKnightArcher_OnMapStart_NPC();
	KazimierzBeserker_OnMapStart_NPC();
	KazimierzLongArcher_OnMapStart_NPC();
	EndSpeaker_MapStart();
	Remain_MapStart();
	KazimierzKnightAssasin_OnMapStart_NPC();
	IsharmlaTrans_MapStart();
	
	//Ruina waves	//warp
	Ruina_Ai_Core_Mapstart();
	Theocracy_OnMapStart_NPC();
	Adiantum_OnMapStart_NPC();
	Lanius_OnMapStart_NPC();
	Magia_OnMapStart_NPC();
	

	//Expidonsa Waves
	Benera_OnMapStart_NPC();
	Pental_OnMapStart_NPC();
	Defanda_OnMapStart_NPC();
	SelfamIre_OnMapStart_NPC();
	VausMagica_OnMapStart_NPC();
	Pistoleer_OnMapStart_NPC();
	Diversionistico_OnMapStart_NPC();
	HeavyPunuel_OnMapStart_NPC();
	SeargentIdeal_OnMapStart_NPC();	
	
	//Alt Barracks
	Barrack_Alt_Ikunagae_MapStart();
	Barrack_Alt_Shwertkrieg_MapStart();
	Barrack_Railgunner_MapStart();
	Barrack_Alt_Basic_Mage_MapStart();
	Barrack_Alt_Intermediate_Mage_MapStart();
	Barrack_Alt_Donnerkrieg_MapStart();
	Barrack_Alt_Holy_Knight_MapStart();
	Barrack_Alt_Mecha_Barrager_MapStart();
	Barrack_Alt_Barrager_MapStart();
	Barrack_Alt_Berserker_MapStart();
	Barrack_Alt_Crossbowmedic_MapStart();
	Barrack_Alt_Scientific_Witchery_MapStart();
	
	Barracks_Thorns();

	// Raid Low Prio
	TrueFusionWarrior_OnMapStart();
	Blitzkrieg_OnMapStart();
	RaidbossSilvester_OnMapStart();
	RaidbossBlueGoggles_OnMapStart();
	RaidbossNemesis_OnMapStart();
	GodArkantos_OnMapStart();

	// Bloon Low Prio
	Bloon_MapStart();
	GoldBloon_MapStart();
	Moab_MapStart();
	Bfb_MapStart();
	Zomg_MapStart();
	DDT_MapStart();
	Bad_MapStart();

	// Stalker Low Prio
	StalkerCombine_MapStart();
	StalkerFather_MapStart();
	StalkerGoggles_OnMapStart();

	// COF Low Prio
	Addiction_OnMapStart_NPC();
	Doctor_MapStart();
	Simon_MapStart();

	// Bloon Raid Low Prio
	Bloonarius_MapStart();
}

any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case HEADCRAB_ZOMBIE:
			entity = HeadcrabZombie(client, vecPos, vecAng, ally);
		
		case FORTIFIED_HEADCRAB_ZOMBIE:
			entity = FortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		
		case FASTZOMBIE:
			entity = FastZombie(client, vecPos, vecAng, ally);
		
		case FORTIFIED_FASTZOMBIE:
			entity = FortifiedFastZombie(client, vecPos, vecAng, ally);
		
		case TORSOLESS_HEADCRAB_ZOMBIE:
			entity = TorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		
		case FORTIFIED_GIANT_POISON_ZOMBIE:
			entity = FortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		
		case POISON_ZOMBIE:
			entity = PoisonZombie(client, vecPos, vecAng, ally);
		
		case FORTIFIED_POISON_ZOMBIE:
			entity = FortifiedPoisonZombie(client, vecPos, vecAng, ally);
		
		case FATHER_GRIGORI:
			entity = FatherGrigori(client, vecPos, vecAng, ally);
		
		case COMBINE_POLICE_PISTOL:
			entity = Combine_Police_Pistol(client, vecPos, vecAng, ally);
		
		case COMBINE_POLICE_SMG:
			entity = CombinePoliceSmg(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_AR2:
			entity = CombineSoldierAr2(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_SHOTGUN:
			entity = CombineSoldierShotgun(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_SWORDSMAN:
			entity = CombineSwordsman(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_ELITE:
			entity = CombineElite(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
			entity = CombineGaint(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_DDT:
			entity = CombineDDT(client, vecPos, vecAng, ally);
		
		case COMBINE_SOLDIER_COLLOSS:
			entity = CombineCollos(client, vecPos, vecAng, ally);
		
		case COMBINE_OVERLORD:
			entity = CombineOverlord(client, vecPos, vecAng, ally);
		
		case SCOUT_ZOMBIE:
			entity = Scout(client, vecPos, vecAng, ally);
		
		case ENGINEER_ZOMBIE:
			entity = Engineer(client, vecPos, vecAng, ally);
		
		case HEAVY_ZOMBIE:
			entity = Heavy(client, vecPos, vecAng, ally);
		
		case FLYINGARMOR_ZOMBIE:
			entity = FlyingArmor(client, vecPos, vecAng, ally);
		
		case FLYINGARMOR_TINY_ZOMBIE:
			entity = FlyingArmorTiny(client, vecPos, vecAng, ally);
		
		case KAMIKAZE_DEMO:
			entity = Kamikaze(client, vecPos, vecAng, ally);
		
		case MEDIC_HEALER:
			entity = MedicHealer(client, vecPos, vecAng, ally);
		
		case HEAVY_ZOMBIE_GIANT:
			entity = HeavyGiant(client, vecPos, vecAng, ally);
		
		case SPY_FACESTABBER:
			entity = Spy(client, vecPos, vecAng, ally);
		
		case SOLDIER_ROCKET_ZOMBIE:
			entity = Soldier(client, vecPos, vecAng, ally);
		
		case SOLDIER_ZOMBIE_MINION:
			entity = SoldierMinion(client, vecPos, vecAng, ally);
		
		case SOLDIER_ZOMBIE_BOSS:
			entity = SoldierGiant(client, vecPos, vecAng, ally);
		
		case SPY_THIEF:
			entity = SpyThief(client, vecPos, vecAng, ally);
		
		case SPY_TRICKSTABBER:
			entity = SpyTrickstabber(client, vecPos, vecAng, ally);
		
		case SPY_HALF_CLOACKED:
			entity = SpyCloaked(client, vecPos, vecAng, ally);
		
		case SNIPER_MAIN:
			entity = SniperMain(client, vecPos, vecAng, ally);
		
		case DEMO_MAIN:
			entity = DemoMain(client, vecPos, vecAng, ally);
		
		case BATTLE_MEDIC_MAIN:
			entity = MedicMain(client, vecPos, vecAng, ally);
		
		case GIANT_PYRO_MAIN:
			entity = PyroGiant(client, vecPos, vecAng, ally);
		
		case COMBINE_DEUTSCH_RITTER:
			entity = CombineDeutsch(client, vecPos, vecAng, ally);
		
		case ALT_COMBINE_DEUTSCH_RITTER:
			entity = Alt_CombineDeutsch(client, vecPos, vecAng, ally);
		
		case SPY_MAIN_BOSS:
			entity = SpyMainBoss(client, vecPos, vecAng, ally);
		
		case XENO_HEADCRAB_ZOMBIE:
			entity = XenoHeadcrabZombie(client, vecPos, vecAng, ally);
		
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
			entity = XenoFortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		
		case XENO_FASTZOMBIE:
			entity = XenoFastZombie(client, vecPos, vecAng, ally);
		
		case XENO_FORTIFIED_FASTZOMBIE:
			entity = XenoFortifiedFastZombie(client, vecPos, vecAng, ally);
		
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
			entity = XenoTorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
			entity = XenoFortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		
		case XENO_POISON_ZOMBIE:
			entity = XenoPoisonZombie(client, vecPos, vecAng, ally);
		
		case XENO_FORTIFIED_POISON_ZOMBIE:
			entity = XenoFortifiedPoisonZombie(client, vecPos, vecAng, ally);
		
		case XENO_FATHER_GRIGORI:
			entity = XenoFatherGrigori(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_POLICE_PISTOL:
			entity = XenoCombinePolicePistol(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_POLICE_SMG:
			entity = XenoCombinePoliceSmg(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_AR2:
			entity = XenoCombineSoldierAr2(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_SHOTGUN:
			entity = XenoCombineSoldierShotgun(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
			entity = XenoCombineSwordsman(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_ELITE:
			entity = XenoCombineElite(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
			entity = XenoCombineGaint(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_DDT:
			entity = XenoCombineDDT(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_SOLDIER_COLLOSS:
			entity = XenoCombineCollos(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_OVERLORD:
			entity = XenoCombineOverlord(client, vecPos, vecAng, ally);
		
		case XENO_SCOUT_ZOMBIE:
			entity = XenoScout(client, vecPos, vecAng, ally);
		
		case XENO_ENGINEER_ZOMBIE:
			entity = XenoEngineer(client, vecPos, vecAng, ally);
		
		case XENO_HEAVY_ZOMBIE:
			entity = XenoHeavy(client, vecPos, vecAng, ally);
		
		case XENO_FLYINGARMOR_ZOMBIE:
			entity = XenoFlyingArmor(client, vecPos, vecAng, ally);
		
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
			entity = XenoFlyingArmorTiny(client, vecPos, vecAng, ally);
		
		case XENO_KAMIKAZE_DEMO:
			entity = XenoKamikaze(client, vecPos, vecAng, ally);
		
		case XENO_MEDIC_HEALER:
			entity = XenoMedicHealer(client, vecPos, vecAng, ally);
		
		case XENO_HEAVY_ZOMBIE_GIANT:
			entity = XenoHeavyGiant(client, vecPos, vecAng, ally);
		
		case XENO_SPY_FACESTABBER:
			entity = XenoSpy(client, vecPos, vecAng, ally);
		
		case XENO_SOLDIER_ROCKET_ZOMBIE:
			entity = XenoSoldier(client, vecPos, vecAng, ally);
		
		case XENO_SOLDIER_ZOMBIE_MINION:
			entity = XenoSoldierMinion(client, vecPos, vecAng, ally);
		
		case XENO_SOLDIER_ZOMBIE_BOSS:
			entity = XenoSoldierGiant(client, vecPos, vecAng, ally);
		
		case XENO_SPY_THIEF:
			entity = XenoSpyThief(client, vecPos, vecAng, ally);
		
		case XENO_SPY_TRICKSTABBER:
			entity = XenoSpyTrickstabber(client, vecPos, vecAng, ally);
		
		case XENO_SPY_HALF_CLOACKED:
			entity = XenoSpyCloaked(client, vecPos, vecAng, ally);
		
		case XENO_SNIPER_MAIN:
			entity = XenoSniperMain(client, vecPos, vecAng, ally);
		
		case XENO_DEMO_MAIN:
			entity = XenoDemoMain(client, vecPos, vecAng, ally);
		
		case XENO_BATTLE_MEDIC_MAIN:
			entity = XenoMedicMain(client, vecPos, vecAng, ally);
		
		case XENO_GIANT_PYRO_MAIN:
			entity = XenoPyroGiant(client, vecPos, vecAng, ally);
		
		case XENO_COMBINE_DEUTSCH_RITTER:
			entity = XenoCombineDeutsch(client, vecPos, vecAng, ally);
		
		case XENO_SPY_MAIN_BOSS:
			entity = XenoSpyMainBoss(client, vecPos, vecAng, ally);
		
		case NAZI_PANZER:
			entity = NaziPanzer(client, vecPos, vecAng, ally);
		
		case BOB_THE_GOD_OF_GODS:
			entity = BobTheGod(client, vecPos, vecAng);
		
		case NECRO_COMBINE:
			entity = NecroCombine(client, vecPos, vecAng, StringToFloat(data));
		
		case NECRO_CALCIUM:
			entity = NecroCalcium(client, vecPos, vecAng, StringToFloat(data));
		
		case CURED_FATHER_GRIGORI:
			entity = CuredFatherGrigori(client, vecPos, vecAng);
		
		case ALT_COMBINE_MAGE:
			entity = AltCombineMage(client, vecPos, vecAng, ally);
		
		case BTD_BLOON:
			entity = Bloon(client, vecPos, vecAng, ally, data);
		
		case BTD_MOAB:
			entity = Moab(client, vecPos, vecAng, ally, data);
		
		case BTD_BFB:
			entity = BFB(client, vecPos, vecAng, ally, data);
		
		case BTD_ZOMG:
			entity = Zomg(client, vecPos, vecAng, ally, data);
		
		case BTD_DDT:
			entity = DDT(client, vecPos, vecAng, ally, data);
		
		case BTD_BAD:
			entity = Bad(client, vecPos, vecAng, ally, data);
		
		case ALT_MEDIC_APPRENTICE_MAGE:
			entity = AltMedicApprenticeMage(client, vecPos, vecAng, ally);
		
		case SAWRUNNER:
			entity = SawRunner(client, vecPos, vecAng, ally);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			entity = TrueFusionWarrior(client, vecPos, vecAng, ally);
		
		case ALT_MEDIC_CHARGER:
			entity = AltMedicCharger(client, vecPos, vecAng, ally);
		
		case ALT_MEDIC_BERSERKER:
			entity = AltMedicBerseker(client, vecPos, vecAng, ally);
		
		case MEDIVAL_MILITIA:
			entity = MedivalMilitia(client, vecPos, vecAng, ally);
		
		case MEDIVAL_ARCHER:
			entity = MedivalArcher(client, vecPos, vecAng, ally);
		
		case MEDIVAL_MAN_AT_ARMS:
			entity = MedivalManAtArms(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SKIRMISHER:
			entity = MedivalSkirmisher(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SWORDSMAN:
			entity = MedivalSwordsman(client, vecPos, vecAng, ally);
		
		case MEDIVAL_TWOHANDED_SWORDSMAN:
			entity = MedivalTwoHandedSwordsman(client, vecPos, vecAng, ally);
		
		case MEDIVAL_CROSSBOW_MAN:
			entity = MedivalCrossbowMan(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SPEARMEN:
			entity = MedivalSpearMan(client, vecPos, vecAng, ally);
		
		case MEDIVAL_HANDCANNONEER:
			entity = MedivalHandCannoneer(client, vecPos, vecAng, ally);
		
		case MEDIVAL_ELITE_SKIRMISHER:
			entity = MedivalEliteSkirmisher(client, vecPos, vecAng, ally);
		
		case RAIDMODE_BLITZKRIEG:
			entity = Blitzkrieg(client, vecPos, vecAng, ally);
		
		case MEDIVAL_PIKEMAN:
			entity = MedivalPikeman(client, vecPos, vecAng, ally);
		
		case ALT_MEDIC_SUPPERIOR_MAGE:
			entity = NPC_ALT_MEDIC_SUPPERIOR_MAGE(client, vecPos, vecAng, ally);
		
		case CITIZEN:
			entity = Citizen(client, vecPos, vecAng, data);
		
		case MEDIVAL_EAGLE_SCOUT:
			entity = MedivalEagleScout(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SAMURAI:
			entity = MedivalSamurai(client, vecPos, vecAng, ally);
		
		case THEADDICTION:
			entity = Addicition(client, vecPos, vecAng, ally, data);
		
		case THEDOCTOR:
			entity = Doctor(client, vecPos, vecAng, ally, data);
		
		case BOOKSIMON:
			entity = Simon(client, vecPos, vecAng, ally, data);
		
		case ALT_KAHMLSTEIN:
			entity = Kahmlstein(client, vecPos, vecAng, ally);
		
		case L4D2_TANK:
			entity = L4D2_Tank(client, vecPos, vecAng, ally);
		
		case ALT_SNIPER_RAILGUNNER:
			entity = Sniper_railgunner(client, vecPos, vecAng, ally);
		
		case BTD_GOLDBLOON:
			entity = GoldBloon(client, vecPos, vecAng, ally, data);
		
		case BTD_BLOONARIUS:
			entity = Bloonarius(client, vecPos, vecAng, ally, data);
		
		case MEDIVAL_RAM:
			entity = MedivalRam(client, vecPos, vecAng, ally, data);
		
		case ALT_SOLDIER_BARRAGER:
			entity = Soldier_Barrager(client, vecPos, vecAng, ally);
		
		case ALT_The_Shit_Slapper:
			entity = The_Shit_Slapper(client, vecPos, vecAng, ally);
		
		case BONEZONE_BASICBONES:
			entity = BasicBones(client, vecPos, vecAng, ally);
		
		case ITSTILIVES:
			entity = Itstilives(client, vecPos, vecAng);
		
		case ALT_MECHA_ENGINEER:
			entity = Mecha_Engineer(client, vecPos, vecAng, ally);
		
		case ALT_MECHA_HEAVY:
			entity = Mecha_Heavy(client, vecPos, vecAng, ally);
		
		case ALT_MECHA_HEAVYGIANT:
			entity = Mecha_HeavyGiant(client, vecPos, vecAng, ally);
		
		case ALT_MECHA_PYROGIANT:
			entity = Mecha_PyroGiant(client, vecPos, vecAng, ally);
		
		case ALT_MECHA_SCOUT:
			entity = Mecha_Scout(client, vecPos, vecAng, ally);
		
		case ALT_DONNERKRIEG:
			entity = Donnerkrieg(client, vecPos, vecAng, ally);
		
		case ALT_SCHWERTKRIEG:
			entity = Schwertkrieg(client, vecPos, vecAng, ally);
		
		case PHANTOM_KNIGHT:
			entity = PhantomKnight(client, vecPos, vecAng, ally);
		
		case ALT_MEDIC_HEALER_3:	//3 being the 3rd stage of alt waves.
			entity = Alt_Medic_Constructor(client, vecPos, vecAng, ally);
		
		case THE_GAMBLER:
			entity = TheGambler(client, vecPos, vecAng, ally);
		
		case PABLO_GONZALES:
			entity = Pablo_Gonzales(client, vecPos, vecAng, ally);
		
		case DOKTOR_MEDICK:
			entity = Doktor_Medick(client, vecPos, vecAng, ally);
		
		case KAPTAIN_HEAVY:
			entity = Eternal_Kaptain_Heavy(client, vecPos, vecAng, ally);
		
		case BOOTY_EXECUTIONIER:
			entity = BootyExecutioner(client, vecPos, vecAng, ally);
		
		case SANDVICH_SLAYER:
			entity = SandvichSlayer(client, vecPos, vecAng, ally);
		
		case PAYDAYCLOAKER:
			entity = Payday_Cloaker(client, vecPos, vecAng, ally);
		
		case BUNKER_KAHML_VTWO:
			entity = BunkerKahml(client, vecPos, vecAng, ally);
		
		case TRUE_ZEROFUSE:
			entity = TrueZerofuse(client, vecPos, vecAng, ally);
		
		case BUNKER_BOT_SOLDIER:
			entity = BunkerBotSoldier(client, vecPos, vecAng, ally);
		
		case BUNKER_BOT_SNIPER:
			entity = BunkerBotSniper(client, vecPos, vecAng, ally);
		
		case BUNKER_SKELETON:
			entity = BunkerSkeleton(client, vecPos, vecAng, ally);
		
		case BUNKER_SMALL_SKELETON:
			entity = BunkerSkeletonKing(client, vecPos, vecAng, ally);
		
		case BUNKER_KING_SKELETON:
			entity = BunkerSkeletonKing(client, vecPos, vecAng, ally);
		
		case BUNKER_HEADLESSHORSE:
			entity = BunkerHeadlessHorse(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SCOUT:
			entity = MedivalScout(client, vecPos, vecAng, ally);
		
		case MEDIVAL_VILLAGER:
			entity = MedivalVillager(client, vecPos, vecAng, ally);
		
		case MEDIVAL_BUILDING:
			entity = MedivalBuilding(client, vecPos, vecAng, ally, data);
		
		case MEDIVAL_CONSTRUCT:
			entity = MedivalConstruct(client, vecPos, vecAng, ally);
		
		case MEDIVAL_CHAMPION:
			entity = MedivalChampion(client, vecPos, vecAng, ally);
		
		case MEDIVAL_LIGHT_CAV:
			entity = MedivalLightCav(client, vecPos, vecAng, ally);
		
		case MEDIVAL_HUSSAR:
			entity = MedivalHussar(client, vecPos, vecAng, ally);
		
		case MEDIVAL_KNIGHT:
			entity = MedivalKnight(client, vecPos, vecAng, ally);
		
		case MEDIVAL_OBUCH:
			entity = MedivalObuch(client, vecPos, vecAng, ally);
		
		case MEDIVAL_MONK:
			entity = MedivalMonk(client, vecPos, vecAng, ally);
		
		case BARRACK_MILITIA:
			entity = BarrackMilitia(client, vecPos, vecAng, ally);
		
		case BARRACK_ARCHER:
			entity = BarrackArcher(client, vecPos, vecAng, ally);
		
		case BARRACK_MAN_AT_ARMS:
			entity = BarrackManAtArms(client, vecPos, vecAng, ally);
		
		case MEDIVAL_HALB:
			entity = MedivalHalb(client, vecPos, vecAng, ally);
		
		case MEDIVAL_BRAWLER:
			entity = MedivalBrawler(client, vecPos, vecAng, ally);
		
		case MEDIVAL_LONGBOWMEN:
			entity = MedivalLongbowmen(client, vecPos, vecAng, ally);
		
		case MEDIVAL_ARBALEST:
			entity = MedivalArbalest(client, vecPos, vecAng, ally);
		
		case MEDIVAL_ELITE_LONGBOWMEN:
			entity = MedivalEliteLongbowmen(client, vecPos, vecAng, ally);
		
		case BARRACK_CROSSBOW:
			entity = BarrackCrossbow(client, vecPos, vecAng, ally);
		
		case BARRACK_SWORDSMAN:
			entity = BarrackSwordsman(client, vecPos, vecAng, ally);
		
		case BARRACK_ARBELAST:
			entity = BarrackArbelast(client, vecPos, vecAng, ally);
		
		case BARRACK_TWOHANDED:
			entity = BarrackTwoHanded(client, vecPos, vecAng, ally);
		
		case BARRACK_LONGBOW:
			entity = BarrackLongbow(client, vecPos, vecAng, ally);
		
		case BARRACK_CHAMPION:
			entity = BarrackChampion(client, vecPos, vecAng, ally);
		
		case BARRACK_MONK:
			entity = BarrackMonk(client, vecPos, vecAng, ally);
		
		case BARRACK_HUSSAR:
			entity = BarrackHussar(client, vecPos, vecAng, ally);
		
		case MEDIVAL_CAVALARY:
			entity = MedivalCavalary(client, vecPos, vecAng, ally);
		
		case MEDIVAL_PALADIN:
			entity = MedivalPaladin(client, vecPos, vecAng, ally);
		
		case MEDIVAL_CROSSBOW_GIANT:
			entity = MedivalCrossbowGiant(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SWORDSMAN_GIANT:
			entity = MedivalSwordsmanGiant(client, vecPos, vecAng, ally);
		
		case MEDIVAL_EAGLE_WARRIOR:
			entity = MedivalEagleWarrior(client, vecPos, vecAng, ally);
		
		case MEDIVAL_RIDDENARCHER:
			entity = MedivalRiddenArcher(client, vecPos, vecAng, ally);
		
		case MEDIVAL_EAGLE_GIANT:
			entity = MedivalEagleGiant(client, vecPos, vecAng, ally);
		
		case MEDIVAL_SON_OF_OSIRIS:
			entity = MedivalSonOfOsiris(client, vecPos, vecAng, ally);
		
		case MEDIVAL_ACHILLES:
			entity = MedivalAchilles(client, vecPos, vecAng, ally);
		
		case MEDIVAL_TREBUCHET:
			entity = MedivalTrebuchet(client, vecPos, vecAng, ally);
		
		case ALT_IKUNAGAE:
			entity = Ikunagae(client, vecPos, vecAng, ally);
		
		case ALT_MECHASOLDIER_BARRAGER:
			entity = MechaSoldier_Barrager(client, vecPos, vecAng, ally);
		
		case NEARL_SWORD:
			entity = NearlSwordAbility(client, vecPos, vecAng, ally);
		
		case STALKER_COMBINE:
			entity = StalkerCombine(client, vecPos, vecAng, false);
		
		case STALKER_FATHER:
			entity = StalkerFather(client, vecPos, vecAng, false);
		
		case STALKER_GOGGLES:
			entity = StalkerGoggles(client, vecPos, vecAng, false);
		
		case XENO_RAIDBOSS_SILVESTER:
			entity = RaidbossSilvester(client, vecPos, vecAng, false);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			entity = RaidbossBlueGoggles(client, vecPos, vecAng, false);
		
		case XENO_RAIDBOSS_SUPERSILVESTER:
			entity = RaidbossSilvester(client, vecPos, vecAng, false);
		
		case XENO_RAIDBOSS_NEMESIS:
			entity = RaidbossNemesis(client, vecPos, vecAng, false);
		
		case SEARUNNER, SEARUNNER_ALT:
			entity = SeaRunner(client, vecPos, vecAng, ally, data);
		
		case SEASLIDER, SEASLIDER_ALT:
			entity = SeaSlider(client, vecPos, vecAng, ally, data);
		
		case SEASPITTER, SEASPITTER_ALT:
			entity = SeaSpitter(client, vecPos, vecAng, ally, data);
		
		case SEAREAPER, SEAREAPER_ALT:
			entity = SeaReaper(client, vecPos, vecAng, ally, data);
		
		case SEACRAWLER, SEACRAWLER_ALT:
			entity = SeaCrawler(client, vecPos, vecAng, ally, data);
		
		case SEAPIERCER, SEAPIERCER_ALT:
			entity = SeaPiercer(client, vecPos, vecAng, ally, data);
		
		case FIRSTTOTALK:
			entity = FirstToTalk(client, vecPos, vecAng, ally);
		
		case UNDERTIDES:
			entity = UnderTides(client, vecPos, vecAng, ally, data);
		
		case SEABORN_KAZIMIERZ_KNIGHT:
			entity = KazimierzKnight(client, vecPos, vecAng, ally);
		
		case SEABORN_KAZIMIERZ_KNIGHT_ARCHER:
			entity = KazimierzKnightArcher(client, vecPos, vecAng, ally, data);
		
		case SEABORN_KAZIMIERZ_BESERKER:
			entity = KazimierzBeserker(client, vecPos, vecAng, ally);
		
		case SEABORN_KAZIMIERZ_LONGARCHER:
			entity = KazimierzLongArcher(client, vecPos, vecAng, ally);
		
		case REMAINS:
			entity = Remains(client, vecPos, vecAng, data);
		
		case ENDSPEAKER_1:
			entity = EndSpeaker1(client, vecPos, vecAng, ally, data);
		
		case ENDSPEAKER_2:
			entity = EndSpeaker2(ally);
		
		case ENDSPEAKER_3:
			entity = EndSpeaker3(ally);
		
		case ENDSPEAKER_4:
			entity = EndSpeaker4(ally);
		
		case SEAFOUNDER, SEAFOUNDER_ALT, SEAFOUNDER_CARRIER:
			entity = SeaFounder(client, vecPos, vecAng, ally, data);
		
		case SEAPREDATOR, SEAPREDATOR_ALT, SEAPREDATOR_CARRIER:
			entity = SeaPredator(client, vecPos, vecAng, ally, data);
		
		case SEABRANDGUIDER, SEABRANDGUIDER_ALT, SEABRANDGUIDER_CARRIER:
			entity = SeaBrandguider(client, vecPos, vecAng, ally, data);

		case SEABORN_KAZIMIERZ_ASSASIN_MELEE:
			entity = KazimierzKnightAssasin(client, vecPos, vecAng, ally);
		
		case SEASPEWER, SEASPEWER_ALT, SEASPEWER_CARRIER:
			entity = SeaSpewer(client, vecPos, vecAng, ally, data);
		
		case SEASWARMCALLER, SEASWARMCALLER_ALT, SEASWARMCALLER_CARRIER:
			entity = SeaSwarmcaller(client, vecPos, vecAng, ally, data);
		
		case SEAREEFBREAKER, SEAREEFBREAKER_ALT, SEAREEFBREAKER_CARRIER:
			entity = SeaReefbreaker(client, vecPos, vecAng, ally, data);
		
		case BARRACK_THORNS:
			entity = BarrackThorns(client, vecPos, vecAng, ally);
		
		case RAIDMODE_GOD_ARKANTOS:
			entity = GodArkantos(client, vecPos, vecAng, ally);
		
		case SEABORN_SCOUT:
			entity = SeabornScout(client, vecPos, vecAng, ally);
		
		case SEABORN_SOLDIER:
			entity = SeabornSoldier(client, vecPos, vecAng, ally);
		
		case CITIZEN_RUNNER:
			entity = CitizenRunner(client, vecPos, vecAng, data);
		
		case SEABORN_PYRO:
			entity = SeabornPyro(client, vecPos, vecAng, ally);
		
		case SEABORN_DEMO:
			entity = SeabornDemo(client, vecPos, vecAng, ally);
		
		case SEABORN_HEAVY:
			entity = SeabornHeavy(client, vecPos, vecAng, ally);
		
		case SEABORN_ENGINEER:
			entity = SeabornEngineer(client, vecPos, vecAng, ally);
		
		case SEABORN_MEDIC:
			entity = SeabornMedic(client, vecPos, vecAng, ally);
		
		case SEABORN_SNIPER:
			entity = SeabornSniper(client, vecPos, vecAng, ally);
		
		case SEABORN_SPY:
			entity = SeabornSpy(client, vecPos, vecAng, ally);
		
		case ALT_BARRACKS_SCHWERTKRIEG:
			entity = Barrack_Alt_Shwertkrieg(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_IKUNAGAE:
			entity = Barrack_Alt_Ikunagae(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_RAILGUNNER:
			entity = Barrack_Alt_Raigunner(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_BASIC_MAGE:
			entity = Barrack_Alt_Basic_Mage(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_INTERMEDIATE_MAGE:
			entity = Barrack_Alt_Intermediate_Mage(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_DONNERKRIEG:
			entity = Barrack_Alt_Donnerkrieg(client, vecPos, vecAng, ally);

		case ALT_BARRACKS_HOLY_KNIGHT:
			entity = Barrack_Alt_Holy_Knight(client, vecPos, vecAng, ally);
		
		case ALT_BARRACK_MECHA_BARRAGER:
			entity = Barrack_Alt_Mecha_Barrager(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_BARRAGER:
			entity = Barrack_Alt_Barrager(client, vecPos, vecAng, ally);
			
		case ALT_BARRACKS_BERSERKER:
			entity = Barrack_Alt_Berserker(client, vecPos, vecAng, ally);
			
		case ALT_BARRACKS_CROSSBOW_MEDIC:
			entity = Barrack_Alt_Crossbowmedic(client, vecPos, vecAng, ally);
		
		case LASTKNIGHT:
			entity = LastKnight(client, vecPos, vecAng, ally, data);
		
		case BARRACK_LASTKNIGHT:
			entity = BarrackLastKnight(client, vecPos, vecAng, ally);
		
		case SAINTCARMEN:
			entity = SaintCarmen(client, vecPos, vecAng, ally);
		
		case PATHSHAPER:
			entity = Pathshaper(client, vecPos, vecAng, ally);
		
		case PATHSHAPER_FRACTAL:
			entity = PathshaperFractal(client, vecPos, vecAng, ally);
			
		case BARRACKS_TEUTONIC_KNIGHT:
			entity = BarrackTeuton(client, vecPos, vecAng, ally);

		case BARRACKS_VILLAGER:
			entity = BarrackVillager(client, vecPos, vecAng, ally);

		case BARRACKS_BUILDING:
			entity = BarrackBuilding(client, vecPos, vecAng, ally);

		case TIDELINKED_BISHOP:
			entity = TidelinkedBishop(client, vecPos, vecAng, ally);

		case TIDELINKED_ARCHON:
			entity = TidelinkedArchon(client, vecPos, vecAng, ally);
			
		case ALT_BARRACK_SCIENTIFIC_WITCHERY:
			entity = Barrack_Alt_Scientific_Witchery(client, vecPos, vecAng, ally);

		case SEABORN_GUARD:
			entity = SeabornGuard(client, vecPos, vecAng, ally);

		case SEABORN_DEFENDER:
			entity = SeabornDefender(client, vecPos, vecAng, ally);

		case SEABORN_VANGUARD:
			entity = SeabornVanguard(client, vecPos, vecAng, ally);

		case SEABORN_CASTER:
			entity = SeabornCaster(client, vecPos, vecAng, ally);

		case SEABORN_SPECIALIST:
			entity = SeabornSpecialist(client, vecPos, vecAng, ally);

		case SEABORN_SUPPORTER:
			entity = SeabornSupporter(client, vecPos, vecAng, ally);

		case ISHARMLA:
			entity = Isharmla(client, vecPos, vecAng, ally);

		case ISHARMLA_TRANS:
			entity = IsharmlaTrans(client, vecPos, vecAng, ally);
			
		case RUINA_THEOCRACY:	//warp
			entity = Theocracy(client, vecPos, vecAng, ally);
		
		case RUINA_ADIANTUM:
			entity = Adiantum(client, vecPos, vecAng, ally);
			
		case RUINA_LANIUS:
			entity = Lanius(client, vecPos, vecAng, ally);
			
		case RUINA_MAGIA:
			entity = Magia(client, vecPos, vecAng, ally);

			
		case EXPIDONSA_BENERA:
			entity = Benera(client, vecPos, vecAng, ally);
			
		case EXPIDONSA_PENTAL:
			entity = Pental(client, vecPos, vecAng, ally);

		case EXPIDONSA_DEFANDA:
			entity = Defanda(client, vecPos, vecAng, ally);

		case EXPIDONSA_SELFAM_IRE:
			entity = SelfamIre(client, vecPos, vecAng, ally);

		case EXPIDONSA_VAUSMAGICA:
			entity = VausMagica(client, vecPos, vecAng, ally);

		case EXPIDONSA_PISTOLEER:
			entity = Pistoleer(client, vecPos, vecAng, ally);

		case EXPIDONSA_DIVERSIONISTICO:
			entity = Diversionistico(client, vecPos, vecAng, ally);

		case EXPIDONSA_HEAVYPUNUEL:
			entity = HeavyPunuel(client, vecPos, vecAng, ally);

		case EXPIDONSA_SEARGENTIDEAL:
			entity = SeargentIdeal(client, vecPos, vecAng, ally);

			
		default:
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%i] Is not a valid npc!", Index_Of_Npc);
		
	}

	if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2)
	{
		Rogue_AllySpawned(entity);
	}
	else
	{
		Rogue_EnemySpawned(entity);
	}
	
	return entity;
}	
public void NPCDeath(int entity)
{
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			switch(i_NpcInternalId[baseboss_index])
			{
				case SEABORN_KAZIMIERZ_BESERKER:
				{
					if(i_NpcInternalId[entity] != SEABORN_KAZIMIERZ_BESERKER)
					{
						KazimierzBeserker_AllyDeath(entity, baseboss_index);	
					}
				}
			}
		}
	}

	switch(i_NpcInternalId[entity])
	{
		case HEADCRAB_ZOMBIE:
			HeadcrabZombie_NPCDeath(entity);
		
		case FORTIFIED_HEADCRAB_ZOMBIE:
			FortifiedHeadcrabZombie_NPCDeath(entity);
		
		case FASTZOMBIE:
			FastZombie_NPCDeath(entity);
		
		case FORTIFIED_FASTZOMBIE:
			FortifiedFastZombie_NPCDeath(entity);
		
		case TORSOLESS_HEADCRAB_ZOMBIE:
			TorsolessHeadcrabZombie_NPCDeath(entity);
		
		case FORTIFIED_GIANT_POISON_ZOMBIE:
			FortifiedGiantPoisonZombie_NPCDeath(entity);
		
		case POISON_ZOMBIE:
			PoisonZombie_NPCDeath(entity);
		
		case FORTIFIED_POISON_ZOMBIE:
			FortifiedPoisonZombie_NPCDeath(entity);
		
		case FATHER_GRIGORI:
			FatherGrigori_NPCDeath(entity);
		
		case COMBINE_POLICE_PISTOL:
			CombinePolicePistol_NPCDeath(entity);
		
		case COMBINE_POLICE_SMG:
			CombinePoliceSmg_NPCDeath(entity);
		
		case COMBINE_SOLDIER_AR2:
			CombineSoldierAr2_NPCDeath(entity);
		
		case COMBINE_SOLDIER_SHOTGUN:
			CombineSoldierShotgun_NPCDeath(entity);
		
		case COMBINE_SOLDIER_SWORDSMAN:
			CombineSwordsman_NPCDeath(entity);
		
		case COMBINE_SOLDIER_ELITE:
			CombineElite_NPCDeath(entity);
		
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
			CombineGaint_NPCDeath(entity);
		
		case COMBINE_SOLDIER_DDT:
			CombineDDT_NPCDeath(entity);
		
		case COMBINE_SOLDIER_COLLOSS:
			CombineCollos_NPCDeath(entity);
		
		case COMBINE_OVERLORD:
			CombineOverlord_NPCDeath(entity);
		
		case SCOUT_ZOMBIE:
			Scout_NPCDeath(entity);
		
		case ENGINEER_ZOMBIE:
			Engineer_NPCDeath(entity);
		
		case HEAVY_ZOMBIE:
			Heavy_NPCDeath(entity);
		
		case FLYINGARMOR_ZOMBIE:
			FlyingArmor_NPCDeath(entity);
		
		case FLYINGARMOR_TINY_ZOMBIE:
			FlyingArmorTiny_NPCDeath(entity);
		
		case KAMIKAZE_DEMO:
			Kamikaze_NPCDeath(entity);
		
		case MEDIC_HEALER:
			MedicHealer_NPCDeath(entity);
		
		case HEAVY_ZOMBIE_GIANT:
			HeavyGiant_NPCDeath(entity);
		
		case SPY_FACESTABBER:
			Spy_NPCDeath(entity);
		
		case SOLDIER_ROCKET_ZOMBIE:
			Soldier_NPCDeath(entity);
		
		case SOLDIER_ZOMBIE_MINION:
			SoldierMinion_NPCDeath(entity);
		
		case SOLDIER_ZOMBIE_BOSS:
			SoldierGiant_NPCDeath(entity);
		
		case SPY_THIEF:
			SpyThief_NPCDeath(entity);
		
		case SPY_TRICKSTABBER:
			SpyTrickstabber_NPCDeath(entity);
		
		case SPY_HALF_CLOACKED:
			SpyCloaked_NPCDeath(entity);
		
		case SNIPER_MAIN:
			SniperMain_NPCDeath(entity);
		
		case DEMO_MAIN:
			DemoMain_NPCDeath(entity);
		
		case BATTLE_MEDIC_MAIN:
			MedicMain_NPCDeath(entity);
		
		case GIANT_PYRO_MAIN:
			PyroGiant_NPCDeath(entity);
		
		case COMBINE_DEUTSCH_RITTER:
			CombineDeutsch_NPCDeath(entity);
		
		case ALT_COMBINE_DEUTSCH_RITTER:
			Alt_CombineDeutsch_NPCDeath(entity);
		
		case SPY_MAIN_BOSS:
			SpyMainBoss_NPCDeath(entity);
		
		case XENO_HEADCRAB_ZOMBIE:
			XenoHeadcrabZombie_NPCDeath(entity);
		
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
			XenoFortifiedHeadcrabZombie_NPCDeath(entity);
		
		case XENO_FASTZOMBIE:
			XenoFastZombie_NPCDeath(entity);
		
		case XENO_FORTIFIED_FASTZOMBIE:
			XenoFortifiedFastZombie_NPCDeath(entity);
		
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
			XenoTorsolessHeadcrabZombie_NPCDeath(entity);
		
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
			XenoFortifiedGiantPoisonZombie_NPCDeath(entity);
		
		case XENO_POISON_ZOMBIE:
			XenoPoisonZombie_NPCDeath(entity);
		
		case XENO_FORTIFIED_POISON_ZOMBIE:
			XenoFortifiedPoisonZombie_NPCDeath(entity);
		
		case XENO_FATHER_GRIGORI:
			XenoFatherGrigori_NPCDeath(entity);
		
		case XENO_COMBINE_POLICE_PISTOL:
			XenoCombinePolicePistol_NPCDeath(entity);
		
		case XENO_COMBINE_POLICE_SMG:
			XenoCombinePoliceSmg_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_AR2:
			XenoCombineSoldierAr2_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_SHOTGUN:
			XenoCombineSoldierShotgun_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
			XenoCombineSwordsman_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_ELITE:
			XenoCombineElite_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
			XenoCombineGaint_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_DDT:
			XenoCombineDDT_NPCDeath(entity);
		
		case XENO_COMBINE_SOLDIER_COLLOSS:
			XenoCombineCollos_NPCDeath(entity);
		
		case XENO_COMBINE_OVERLORD:
			XenoCombineOverlord_NPCDeath(entity);
		
		case XENO_SCOUT_ZOMBIE:
			XenoScout_NPCDeath(entity);
		
		case XENO_ENGINEER_ZOMBIE:
			XenoEngineer_NPCDeath(entity);
		
		case XENO_HEAVY_ZOMBIE:
			XenoHeavy_NPCDeath(entity);
		
		case XENO_FLYINGARMOR_ZOMBIE:
			XenoFlyingArmor_NPCDeath(entity);
		
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
			XenoFlyingArmorTiny_NPCDeath(entity);
		
		case XENO_KAMIKAZE_DEMO:
			XenoKamikaze_NPCDeath(entity);
		
		case XENO_MEDIC_HEALER:
			XenoMedicHealer_NPCDeath(entity);
		
		case XENO_HEAVY_ZOMBIE_GIANT:
			XenoHeavyGiant_NPCDeath(entity);
		
		case XENO_SPY_FACESTABBER:
			XenoSpy_NPCDeath(entity);
		
		case XENO_SOLDIER_ROCKET_ZOMBIE:
			XenoSoldier_NPCDeath(entity);
		
		case XENO_SOLDIER_ZOMBIE_MINION:
			XenoSoldierMinion_NPCDeath(entity);
		
		case XENO_SOLDIER_ZOMBIE_BOSS:
			XenoSoldierGiant_NPCDeath(entity);
		
		case XENO_SPY_THIEF:
			XenoSpyThief_NPCDeath(entity);
		
		case XENO_SPY_TRICKSTABBER:
			XenoSpyTrickstabber_NPCDeath(entity);
		
		case XENO_SPY_HALF_CLOACKED:
			XenoSpyCloaked_NPCDeath(entity);
		
		case XENO_SNIPER_MAIN:
			XenoSniperMain_NPCDeath(entity);
		
		case XENO_DEMO_MAIN:
			XenoDemoMain_NPCDeath(entity);
		
		case XENO_BATTLE_MEDIC_MAIN:
			XenoMedicMain_NPCDeath(entity);
		
		case XENO_GIANT_PYRO_MAIN:
			XenoPyroGiant_NPCDeath(entity);
		
		case XENO_COMBINE_DEUTSCH_RITTER:
			XenoCombineDeutsch_NPCDeath(entity);
		
		case XENO_SPY_MAIN_BOSS:
			XenoSpyMainBoss_NPCDeath(entity);
		
		case NAZI_PANZER:
			NaziPanzer_NPCDeath(entity);
		
		case BOB_THE_GOD_OF_GODS:
			BobTheGod_NPCDeath(entity);
		
		case NECRO_COMBINE:
			NecroCombine_NPCDeath(entity);
		
		case NECRO_CALCIUM:
			NecroCalcium_NPCDeath(entity);
		
		case CURED_FATHER_GRIGORI:
			CuredFatherGrigori_NPCDeath(entity);
		
		case ALT_COMBINE_MAGE:
			AltCombineMage_NPCDeath(entity);
		
		case BTD_BLOON:
			Bloon_NPCDeath(entity);
		
		case BTD_MOAB:
			Moab_NPCDeath(entity);
		
		case BTD_BFB:
			Bfb_NPCDeath(entity);
		
		case BTD_ZOMG:
			Zomg_NPCDeath(entity);
		
		case BTD_DDT:
			DDT_NPCDeath(entity);
		
		case BTD_BAD:
			Bad_NPCDeath(entity);
		
		case ALT_MEDIC_APPRENTICE_MAGE:
			AltMedicApprenticeMage_NPCDeath(entity);
		
		case SAWRUNNER:
			SawRunner_NPCDeath(entity);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			TrueFusionWarrior_NPCDeath(entity);
		
		case ALT_MEDIC_CHARGER:
			AltMedicCharger_NPCDeath(entity);
		
		case ALT_MEDIC_BERSERKER:
			AltMedicBerseker_NPCDeath(entity);
		
		case MEDIVAL_MILITIA:
			MedivalMilitia_NPCDeath(entity);
		
		case MEDIVAL_ARCHER:
			MedivalArcher_NPCDeath(entity);
		
		case MEDIVAL_MAN_AT_ARMS:
			MedivalManAtArms_NPCDeath(entity);
		
		case MEDIVAL_SKIRMISHER:
			MedivalSkirmisher_NPCDeath(entity);
		
		case MEDIVAL_SWORDSMAN:
			MedivalSwordsman_NPCDeath(entity);
		
		case MEDIVAL_TWOHANDED_SWORDSMAN:
			MedivalTwoHandedSwordsman_NPCDeath(entity);
		
		case MEDIVAL_CROSSBOW_MAN:
			MedivalCrossbowMan_NPCDeath(entity);
		
		case MEDIVAL_SPEARMEN:
			MedivalSpearMan_NPCDeath(entity);
		
		case MEDIVAL_HANDCANNONEER:
			MedivalHandCannoneer_NPCDeath(entity);
		
		case MEDIVAL_ELITE_SKIRMISHER:
			MedivalEliteSkirmisher_NPCDeath(entity);
		
		case RAIDMODE_BLITZKRIEG:
			Blitzkrieg_NPCDeath(entity);
		
		case MEDIVAL_PIKEMAN:
			MedivalPikeman_NPCDeath(entity);
		
		case ALT_MEDIC_SUPPERIOR_MAGE:
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_NPCDeath(entity);
		
		case CITIZEN:
			Citizen_NPCDeath(entity);
		
		case MEDIVAL_EAGLE_SCOUT:
			MedivalEagleScout_NPCDeath(entity);
		
		case MEDIVAL_SAMURAI:
			MedivalSamurai_NPCDeath(entity);
		
		case THEADDICTION:
			Addicition_NPCDeath(entity);
		
		case THEDOCTOR:
			Doctor_NPCDeath(entity);
		
		case BOOKSIMON:
			Simon_NPCDeath(entity);
		
		case ALT_KAHMLSTEIN:
			Kahmlstein_NPCDeath(entity);
		
		case L4D2_TANK:
			L4D2_Tank_NPCDeath(entity);
		
		case ALT_SNIPER_RAILGUNNER:
			Sniper_railgunner_NPCDeath(entity);
		
		case BTD_GOLDBLOON:
			GoldBloon_NPCDeath(entity);
		
		case BTD_BLOONARIUS:
			Bloonarius_NPCDeath(entity);
		
		case MEDIVAL_RAM:
			MedivalRam_NPCDeath(entity);
		
		case ALT_SOLDIER_BARRAGER:
			Soldier_Barrager_NPCDeath(entity);
		
		case ALT_The_Shit_Slapper:
			The_Shit_Slapper_NPCDeath(entity);
		
		case BONEZONE_BASICBONES:
			BasicBones_NPCDeath(entity);
		
		case ALT_MECHA_ENGINEER:
			Mecha_Engineer_NPCDeath(entity);
		
		case ALT_MECHA_HEAVY:
			Mecha_Heavy_NPCDeath(entity);
		
		case ALT_MECHA_HEAVYGIANT:
			Mecha_HeavyGiant_NPCDeath(entity);
		
		case ALT_MECHA_PYROGIANT:
			Mecha_PyroGiant_NPCDeath(entity);
		
		case ALT_MECHA_SCOUT:
			Mecha_Scout_NPCDeath(entity);
		
		case ALT_DONNERKRIEG:
			Donnerkrieg_NPCDeath(entity);
		
		case ALT_SCHWERTKRIEG:
			Schwertkrieg_NPCDeath(entity);
		
		case PHANTOM_KNIGHT:
			PhantomKnight_NPCDeath(entity);
		
		case ALT_MEDIC_HEALER_3:
			Alt_Medic_Constructor_NPCDeath(entity);
		
		case THE_GAMBLER:
			TheGambler_NPCDeath(entity);
		
		case PABLO_GONZALES:
			Pablo_Gonzales_NPCDeath(entity);
		
		case DOKTOR_MEDICK:
			Doktor_Medick_NPCDeath(entity);
		
		case KAPTAIN_HEAVY:
			Eternal_Kaptain_Heavy_NPCDeath(entity);
		
		case BOOTY_EXECUTIONIER:
			BootyExecutioner_NPCDeath(entity);
		
		case SANDVICH_SLAYER:
			SandvichSlayer_NPCDeath(entity);
		
		case PAYDAYCLOAKER:
			Payday_Cloaker_NPCDeath(entity);
		
		case BUNKER_KAHML_VTWO:
			BunkerKahml_NPCDeath(entity);
		
		case TRUE_ZEROFUSE:
			TrueZerofuse_NPCDeath(entity);
		
		case BUNKER_BOT_SOLDIER:
			BunkerBotSoldier_NPCDeath(entity);
		
		case BUNKER_BOT_SNIPER:
			BunkerBotSniper_NPCDeath(entity);
		
		case BUNKER_SKELETON:
			BunkerSkeleton_NPCDeath(entity);
		
		case BUNKER_SMALL_SKELETON:
			BunkerSkeletonSmall_NPCDeath(entity);
		
		case BUNKER_KING_SKELETON:
			BunkerSkeletonKing_NPCDeath(entity);
		
		case BUNKER_HEADLESSHORSE:
			BunkerHeadlessHorse_NPCDeath(entity);
		
		case MEDIVAL_SCOUT:
			MedivalScout_NPCDeath(entity);
		
		case MEDIVAL_VILLAGER:
			MedivalVillager_NPCDeath(entity);
		
		case MEDIVAL_BUILDING:
			MedivalBuilding_NPCDeath(entity);
		
		case MEDIVAL_CONSTRUCT:
			MedivalConstruct_NPCDeath(entity);
		
		case MEDIVAL_CHAMPION:
			MedivalChampion_NPCDeath(entity);
		
		case MEDIVAL_LIGHT_CAV:
			MedivalLightCav_NPCDeath(entity);
		
		case MEDIVAL_HUSSAR:
			MedivalHussar_NPCDeath(entity);
		
		case MEDIVAL_KNIGHT:
			MedivalKnight_NPCDeath(entity);
		
		case MEDIVAL_OBUCH:
			MedivalObuch_NPCDeath(entity);
		
		case MEDIVAL_MONK:
			MedivalMonk_NPCDeath(entity);
		
		case BARRACK_MILITIA:
			BarrackMilitia_NPCDeath(entity);
		
		case BARRACK_ARCHER:
			BarrackArcher_NPCDeath(entity);
		
		case BARRACK_MAN_AT_ARMS:
			BarrackManAtArms_NPCDeath(entity);
		
		case MEDIVAL_HALB:
			MedivalHalb_NPCDeath(entity);
		
		case MEDIVAL_BRAWLER:
			MedivalBrawler_NPCDeath(entity);
		
		case MEDIVAL_LONGBOWMEN:
			MedivalLongbowmen_NPCDeath(entity);
		
		case MEDIVAL_ARBALEST:
			MedivalArbalest_NPCDeath(entity);
		
		case MEDIVAL_ELITE_LONGBOWMEN:
			MedivalEliteLongbowmen_NPCDeath(entity);
		
		case BARRACK_CROSSBOW:
			BarrackCrossbow_NPCDeath(entity);
		
		case BARRACK_SWORDSMAN:
			BarrackSwordsman_NPCDeath(entity);
		
		case BARRACK_ARBELAST:
			BarrackArbelast_NPCDeath(entity);
		
		case BARRACK_TWOHANDED:
			BarrackTwoHanded_NPCDeath(entity);
		
		case BARRACK_LONGBOW:
			BarrackLongbow_NPCDeath(entity);
		
		case BARRACK_CHAMPION:
			BarrackChampion_NPCDeath(entity);
		
		case BARRACK_MONK:
			BarrackMonk_NPCDeath(entity);
		
		case BARRACK_HUSSAR:
			BarrackHussar_NPCDeath(entity);
		
		case MEDIVAL_CAVALARY:
			MedivalCavalary_NPCDeath(entity);
		
		case MEDIVAL_PALADIN:
			MedivalPaladin_NPCDeath(entity);
		
		case MEDIVAL_CROSSBOW_GIANT:
			MedivalCrossbowGiant_NPCDeath(entity);
		
		case MEDIVAL_SWORDSMAN_GIANT:
			MedivalSwordsmanGiant_NPCDeath(entity);
		
		case MEDIVAL_EAGLE_WARRIOR:
			MedivalEagleWarrior_NPCDeath(entity);
		
		case MEDIVAL_RIDDENARCHER:
			MedivalRiddenArcher_NPCDeath(entity);
		
		case MEDIVAL_EAGLE_GIANT:
			MedivalEagleGiant_NPCDeath(entity);
		
		case MEDIVAL_SON_OF_OSIRIS:
			MedivalSonOfOsiris_NPCDeath(entity);
		
		case MEDIVAL_ACHILLES:
			MedivalAchilles_NPCDeath(entity);
		
		case MEDIVAL_TREBUCHET:
			MedivalTrebuchet_NPCDeath(entity);
		
		case ALT_IKUNAGAE:
			Ikunagae_NPCDeath(entity);
		
		case ALT_MECHASOLDIER_BARRAGER:
			MechaSoldier_Barrager_NPCDeath(entity);
		
		case NEARL_SWORD:
			NearlSwordAbility_NPCDeath(entity);
		
		case STALKER_COMBINE:
			StalkerCombine_NPCDeath(entity);
		
		case STALKER_FATHER:
			StalkerFather_NPCDeath(entity);
		
		case STALKER_GOGGLES:
			StalkerGoggles_NPCDeath(entity);
		
		case XENO_RAIDBOSS_SILVESTER:
			RaidbossSilvester_NPCDeath(entity);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			RaidbossBlueGoggles_NPCDeath(entity);
		
		case XENO_RAIDBOSS_SUPERSILVESTER:
			RaidbossSilvester_NPCDeath(entity);
		
		case XENO_RAIDBOSS_NEMESIS:
			RaidbossNemesis_NPCDeath(entity);
		
		case SEARUNNER, SEARUNNER_ALT:
			SeaRunner_NPCDeath(entity);
		
		case SEASLIDER, SEASLIDER_ALT:
			SeaSlider_NPCDeath(entity);
		
		case SEASPITTER, SEASPITTER_ALT:
			SeaSpitter_NPCDeath(entity);
		
		case SEAREAPER, SEAREAPER_ALT:
			SeaReaper_NPCDeath(entity);
		
		case SEACRAWLER, SEACRAWLER_ALT:
			SeaCrawler_NPCDeath(entity);
		
		case SEAPIERCER, SEAPIERCER_ALT:
			SeaPiercer_NPCDeath(entity);
		
		case FIRSTTOTALK:
			FirstToTalk_NPCDeath(entity);
		
		case UNDERTIDES:
			UnderTides_NPCDeath(entity);
		
		case SEABORN_KAZIMIERZ_KNIGHT:
			KazimierzKnight_NPCDeath(entity);
		
		case SEABORN_KAZIMIERZ_KNIGHT_ARCHER:
			KazimierzKnightArcher_NPCDeath(entity);
		
		case SEABORN_KAZIMIERZ_BESERKER:
			KazimierzBeserker_NPCDeath(entity);
		
		case SEABORN_KAZIMIERZ_LONGARCHER:
			KazimierzLongArcher_NPCDeath(entity);
		
		case REMAINS:
			Remains_NPCDeath(entity);
		
		case ENDSPEAKER_1:
			EndSpeaker1_NPCDeath(entity);
		
		case ENDSPEAKER_2:
			EndSpeaker2_NPCDeath(entity);
		
		case ENDSPEAKER_3:
			EndSpeaker3_NPCDeath(entity);
		
		case ENDSPEAKER_4:
			EndSpeaker4_NPCDeath(entity);
		
		case SEAFOUNDER, SEAFOUNDER_ALT, SEAFOUNDER_CARRIER:
			SeaFounder_NPCDeath(entity);
		
		case SEAPREDATOR, SEAPREDATOR_ALT, SEAPREDATOR_CARRIER:
			SeaPredator_NPCDeath(entity);
		
		case SEABRANDGUIDER, SEABRANDGUIDER_ALT, SEABRANDGUIDER_CARRIER:
			SeaBrandguider_NPCDeath(entity);
		
		case SEABORN_KAZIMIERZ_ASSASIN_MELEE:
			KazimierzKnightAssasin_NPCDeath(entity);
		
		case SEASPEWER, SEASPEWER_ALT, SEASPEWER_CARRIER:
			SeaSpewer_NPCDeath(entity);
		
		case SEASWARMCALLER, SEASWARMCALLER_ALT, SEASWARMCALLER_CARRIER:
			SeaSwarmcaller_NPCDeath(entity);
		
		case SEAREEFBREAKER, SEAREEFBREAKER_ALT, SEAREEFBREAKER_CARRIER:
			SeaReefbreaker_NPCDeath(entity);
		
		case BARRACK_THORNS:
			BarrackThorns_NPCDeath(entity);

		case RAIDMODE_GOD_ARKANTOS:
			GodArkantos_NPCDeath(entity);

		case SEABORN_SCOUT:
			SeabornScout_NPCDeath(entity);

		case SEABORN_SOLDIER:
			SeabornSoldier_NPCDeath(entity);

		case CITIZEN_RUNNER:
			CitizenRunner_NPCDeath(entity);

		case SEABORN_PYRO:
			SeabornPyro_NPCDeath(entity);

		case SEABORN_DEMO:
			SeabornDemo_NPCDeath(entity);

		case SEABORN_HEAVY:
			SeabornHeavy_NPCDeath(entity);

		case SEABORN_ENGINEER:
			SeabornEngineer_NPCDeath(entity);

		case SEABORN_MEDIC:
			SeabornMedic_NPCDeath(entity);

		case SEABORN_SNIPER:
			SeabornSniper_NPCDeath(entity);

		case SEABORN_SPY:
			SeabornSpy_NPCDeath(entity);
			
		case ALT_BARRACKS_SCHWERTKRIEG:
			Barrack_Alt_Shwertkrieg_NPCDeath(entity);
			
		case ALT_BARRACK_IKUNAGAE:
			Barrack_Alt_Ikunagae_NPCDeath(entity);
			
		case ALT_BARRACK_RAILGUNNER:
			Barrack_Alt_Raigunner_NPCDeath(entity);
			
		case ALT_BARRACK_BASIC_MAGE:
			Barrack_Alt_Basic_Mage_NPCDeath(entity);
			
		case ALT_BARRACK_INTERMEDIATE_MAGE:
			Barrack_Alt_Intermediate_Mage_NPCDeath(entity);
			
		case ALT_BARRACK_DONNERKRIEG:
			Barrack_Alt_Donnerkrieg_NPCDeath(entity);
			
		case ALT_BARRACKS_HOLY_KNIGHT:
			Barrack_Alt_Holy_Knight_NPCDeath(entity);
		
		case ALT_BARRACK_MECHA_BARRAGER:
			Barrack_Alt_Mecha_Barrager_NPCDeath(entity);
		
		case ALT_BARRACK_BARRAGER:
			Barrack_Alt_Barrager_NPCDeath(entity);
		
		case ALT_BARRACKS_BERSERKER:
			Barrack_Alt_Berserker_NPCDeath(entity);
			
		case ALT_BARRACKS_CROSSBOW_MEDIC:
			Barrack_Alt_Crossbowmedic_NPCDeath(entity);
		
		case LASTKNIGHT:
			LastKnight_NPCDeath(entity);
		
		case BARRACK_LASTKNIGHT:
			BarrackLastKnight_NPCDeath(entity);
		
		case SAINTCARMEN:
			SaintCarmen_NPCDeath(entity);
		
		case PATHSHAPER:
			Pathshaper_NPCDeath(entity);
		
		case PATHSHAPER_FRACTAL:
			PathshaperFractal_NPCDeath(entity);
			
		case BARRACKS_TEUTONIC_KNIGHT:
			BarrackTeuton_NPCDeath(entity);

		case BARRACKS_VILLAGER:
			BarrackVillager_NPCDeath(entity);

		case BARRACKS_BUILDING:
			BarrackBuilding_NPCDeath(entity);
		
		case TIDELINKED_BISHOP:
			TidelinkedBishop_NPCDeath(entity);
		
		case TIDELINKED_ARCHON:
			TidelinkedArchon_NPCDeath(entity);
			
		case ALT_BARRACK_SCIENTIFIC_WITCHERY:
			Barrack_Alt_Scientific_Witchery_NPCDeath(entity);
		
		case SEABORN_GUARD:
			SeabornGuard_NPCDeath(entity);
		
		case SEABORN_DEFENDER:
			SeabornDefender_NPCDeath(entity);
		
		case SEABORN_VANGUARD:
			SeabornVanguard_NPCDeath(entity);
		
		case SEABORN_CASTER:
			SeabornCaster_NPCDeath(entity);
		
		case SEABORN_SPECIALIST:
			SeabornSpecialist_NPCDeath(entity);
		
		case SEABORN_SUPPORTER:
			SeabornSupporter_NPCDeath(entity);
		
		case ISHARMLA:
			Isharmla_NPCDeath(entity);
		
		case ISHARMLA_TRANS:
			IsharmlaTrans_NPCDeath(entity);
			
		case RUINA_THEOCRACY, RUINA_ADIANTUM, RUINA_LANIUS, RUINA_MAGIA:
			Ruina_NPCDeath_Override(entity); //all ruina npc deaths are here



		case EXPIDONSA_BENERA:
			Benera_NPCDeath(entity); 

		case EXPIDONSA_PENTAL:
			Pental_NPCDeath(entity);

		case EXPIDONSA_DEFANDA:
			Defanda_NPCDeath(entity);

		case EXPIDONSA_SELFAM_IRE:
			SelfamIre_NPCDeath(entity);

		case EXPIDONSA_VAUSMAGICA:
			VausMagica_NPCDeath(entity);

		case EXPIDONSA_PISTOLEER:
			Pistoleer_NPCDeath(entity);

		case EXPIDONSA_DIVERSIONISTICO:
			Diversionistico_NPCDeath(entity);

		case EXPIDONSA_HEAVYPUNUEL:
			HeavyPunuel_NPCDeath(entity);

		case EXPIDONSA_SEARGENTIDEAL:
			SeargentIdeal_NPCDeath(entity);

		default:
			PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		
	}
	
	if(view_as<CClotBody>(entity).m_fCreditsOnKill)
	{
		int GiveMoney = 0;
		float CreditsOnKill = view_as<CClotBody>(entity).m_fCreditsOnKill;
		if (CreditsOnKill <= 1.0)
		{
			f_FactionCreditGain += CreditsOnKill;

			for(int client=1; client<=MaxClients; client++)
			{
				if(!b_IsPlayerABot[client] && IsClientInGame(client))
				{
					if(GetClientTeam(client) != 2)
					{
						f_FactionCreditGainReduction[client] = f_FactionCreditGain * 0.2;
					}
					else if (TeutonType[client] == TEUTON_WAITING)
					{
						f_FactionCreditGainReduction[client] = f_FactionCreditGain * 0.1;
					}
				}
			}		

			if(f_FactionCreditGain >= 1.0)
			{
				f_FactionCreditGain -= 1.0;
				GiveMoney = 1;
			}
		}
		else
		{
			GiveMoney = RoundToFloor(CreditsOnKill);
			float Decimal_MoneyGain = FloatFraction(CreditsOnKill);	
			f_FactionCreditGain += Decimal_MoneyGain;
			
			for(int client=1; client<=MaxClients; client++)
			{
				if(!b_IsPlayerABot[client] && IsClientInGame(client))
				{
					if(GetClientTeam(client) != 2)
					{
						f_FactionCreditGainReduction[client] = (f_FactionCreditGain * float(GiveMoney) * 0.2);
					}
					else if (TeutonType[client] == TEUTON_WAITING)
					{
						f_FactionCreditGainReduction[client] = (f_FactionCreditGain * float(GiveMoney) * 0.1);
					}
				}
			}

			if(f_FactionCreditGain >= 1.0)
			{
				f_FactionCreditGain -= 1.0;
				GiveMoney += 1;
			}
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client))
			{
				if(f_FactionCreditGainReduction[client] > 1.0)
				{
					int RemoveMoney = RoundToFloor(f_FactionCreditGainReduction[client]);
					f_FactionCreditGainReduction[client] -= float(RemoveMoney);
					CashSpent[client] += RemoveMoney;
				}
			}
		}
		CurrentCash += GiveMoney;
	}
}

Action NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	switch(i_NpcInternalId[victim])
	{
		case HEADCRAB_ZOMBIE, FORTIFIED_HEADCRAB_ZOMBIE, FASTZOMBIE, FORTIFIED_FASTZOMBIE:
			Generic_OnTakeDamage(victim, attacker);
		
		case TORSOLESS_HEADCRAB_ZOMBIE:
			TorsolessHeadcrabZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FORTIFIED_GIANT_POISON_ZOMBIE:
			FortifiedGiantPoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case POISON_ZOMBIE:
			PoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FORTIFIED_POISON_ZOMBIE:
			FortifiedPoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FATHER_GRIGORI:
			FatherGrigori_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_POLICE_PISTOL:
			CombinePolicePistol_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_POLICE_SMG:
			CombinePoliceSmg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_AR2:
			CombineSoldierAr2_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_SHOTGUN:
			CombineSoldierShotgun_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_SWORDSMAN:
			CombineSwordsman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_ELITE:
			CombineElite_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
			CombineGaint_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_DDT:
			CombineDDT_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_SOLDIER_COLLOSS:
			CombineCollos_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_OVERLORD:
			CombineOverlord_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SCOUT_ZOMBIE:
			Scout_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ENGINEER_ZOMBIE:
			Engineer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case HEAVY_ZOMBIE:
			Heavy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FLYINGARMOR_ZOMBIE:
			FlyingArmor_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FLYINGARMOR_TINY_ZOMBIE:
			FlyingArmorTiny_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case KAMIKAZE_DEMO:
			Kamikaze_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIC_HEALER:
			MedicHealer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case HEAVY_ZOMBIE_GIANT:
			HeavyGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SPY_FACESTABBER:
			Spy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SOLDIER_ROCKET_ZOMBIE:
			Soldier_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SOLDIER_ZOMBIE_MINION:
			SoldierMinion_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SOLDIER_ZOMBIE_BOSS:
			SoldierGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SPY_THIEF:
			SpyThief_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SPY_TRICKSTABBER:
			SpyTrickstabber_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SPY_HALF_CLOACKED:
			SpyCloaked_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SNIPER_MAIN:
			SniperMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case DEMO_MAIN:
			DemoMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BATTLE_MEDIC_MAIN:
			MedicMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case GIANT_PYRO_MAIN:
			PyroGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case COMBINE_DEUTSCH_RITTER:
			CombineDeutsch_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_COMBINE_DEUTSCH_RITTER:
			Alt_CombineDeutsch_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SPY_MAIN_BOSS:
			SpyMainBoss_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_HEADCRAB_ZOMBIE:
			XenoHeadcrabZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
			XenoFortifiedHeadcrabZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FASTZOMBIE:
			XenoFastZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FORTIFIED_FASTZOMBIE:
			XenoFortifiedFastZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
			XenoTorsolessHeadcrabZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
			XenoFortifiedGiantPoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_POISON_ZOMBIE:
			XenoPoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FORTIFIED_POISON_ZOMBIE:
			XenoFortifiedPoisonZombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FATHER_GRIGORI:
			XenoFatherGrigori_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_POLICE_PISTOL:
			XenoCombinePolicePistol_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_POLICE_SMG:
			XenoCombinePoliceSmg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_AR2:
			XenoCombineSoldierAr2_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_SHOTGUN:
			XenoCombineSoldierShotgun_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
			XenoCombineSwordsman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_ELITE:
			XenoCombineElite_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
			XenoCombineGaint_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_DDT:
			XenoCombineDDT_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_SOLDIER_COLLOSS:
			XenoCombineCollos_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_OVERLORD:
			XenoCombineOverlord_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SCOUT_ZOMBIE:
			XenoScout_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_ENGINEER_ZOMBIE:
			XenoEngineer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_HEAVY_ZOMBIE:
			XenoHeavy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FLYINGARMOR_ZOMBIE:
			XenoFlyingArmor_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
			XenoFlyingArmorTiny_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_KAMIKAZE_DEMO:
			XenoKamikaze_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_MEDIC_HEALER:
			XenoMedicHealer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_HEAVY_ZOMBIE_GIANT:
			XenoHeavyGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SPY_FACESTABBER:
			XenoSpy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SOLDIER_ROCKET_ZOMBIE:
			XenoSoldier_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SOLDIER_ZOMBIE_MINION:
			XenoSoldierMinion_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SOLDIER_ZOMBIE_BOSS:
			XenoSoldierGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SPY_THIEF:
			XenoSpyThief_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SPY_TRICKSTABBER:
			XenoSpyTrickstabber_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SPY_HALF_CLOACKED:
			XenoSpyCloaked_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SNIPER_MAIN:
			XenoSniperMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_DEMO_MAIN:
			XenoDemoMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_BATTLE_MEDIC_MAIN:
			XenoMedicMain_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_GIANT_PYRO_MAIN:
			XenoPyroGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_COMBINE_DEUTSCH_RITTER:
			XenoCombineDeutsch_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_SPY_MAIN_BOSS:
			XenoSpyMainBoss_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case NAZI_PANZER:
			NaziPanzer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BOB_THE_GOD_OF_GODS:
			BobTheGod_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case NECRO_COMBINE:
			NecroCombine_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case NECRO_CALCIUM:
			NecroCalcium_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case CURED_FATHER_GRIGORI:
			CuredFatherGrigori_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_COMBINE_MAGE:
			AltCombineMage_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_BLOON:
			Bloon_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_MOAB:
			Moab_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_BFB:
			Bfb_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_ZOMG:
			Zomg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_DDT:
			DDT_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_BAD:
			Bad_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MEDIC_APPRENTICE_MAGE:
			AltMedicApprenticeMage_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SAWRUNNER:
			SawRunner_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			TrueFusionWarrior_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MEDIC_CHARGER:
			AltMedicCharger_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MEDIC_BERSERKER:
			AltMedicBerseker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_MILITIA:
			MedivalMilitia_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_ARCHER:
			MedivalArcher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_MAN_AT_ARMS:
			MedivalManAtArms_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SKIRMISHER:
			MedivalSkirmisher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SWORDSMAN:
			MedivalSwordsman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_TWOHANDED_SWORDSMAN:
			MedivalTwoHandedSwordsman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_CROSSBOW_MAN:
			MedivalCrossbowMan_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SPEARMEN:
			MedivalSpearMan_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_HANDCANNONEER:
			MedivalHandCannoneer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_ELITE_SKIRMISHER:
			MedivalEliteSkirmisher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case RAIDMODE_BLITZKRIEG:
			Blitzkrieg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_PIKEMAN:
			MedivalPikeman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MEDIC_SUPPERIOR_MAGE:
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case CITIZEN:
			Citizen_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_EAGLE_SCOUT:
			MedivalEagleScout_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SAMURAI:
			MedivalSamurai_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case THEADDICTION:
			Addicition_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case THEDOCTOR:
	//		Doctor_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case BOOKSIMON:
	//		Simon_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_KAHMLSTEIN:
			Kahmlstein_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case L4D2_TANK:
			L4D2_Tank_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_SNIPER_RAILGUNNER:
			Sniper_railgunner_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BTD_GOLDBLOON:
			GoldBloon_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case BTD_BLOONARIUS:
	//		Bloonarius_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case MEDIVAL_RAM:
	//		MedivalRam_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_SOLDIER_BARRAGER:
			Soldier_Barrager_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_The_Shit_Slapper:
			The_Shit_Slapper_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BONEZONE_BASICBONES:
			BasicBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHA_ENGINEER:
			Mecha_Engineer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHA_HEAVY:
			Mecha_Heavy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHA_HEAVYGIANT:
			Mecha_HeavyGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHA_PYROGIANT:
			Mecha_PyroGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHA_SCOUT:
			Mecha_Scout_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_DONNERKRIEG:
			Donnerkrieg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_SCHWERTKRIEG:
			Schwertkrieg_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case PHANTOM_KNIGHT:
			PhantomKnight_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MEDIC_HEALER_3:
			Alt_Medic_Constructor_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case THE_GAMBLER:
			TheGambler_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case PABLO_GONZALES:
			Pablo_Gonzales_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case DOKTOR_MEDICK:
			Doktor_Medick_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case KAPTAIN_HEAVY:
			Eternal_Kaptain_Heavy_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BOOTY_EXECUTIONIER:
			BootyExecutioner_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SANDVICH_SLAYER:
			SandvichSlayer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case PAYDAYCLOAKER:
			Payday_Cloaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_KAHML_VTWO:
			BunkerKahml_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case TRUE_ZEROFUSE:
			TrueZerofuse_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_BOT_SOLDIER:
			BunkerBotSoldier_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_BOT_SNIPER:
			BunkerBotSniper_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_SKELETON:
			BunkerSkeleton_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_SMALL_SKELETON:
			BunkerSkeletonSmall_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_KING_SKELETON:
			BunkerSkeletonKing_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BUNKER_HEADLESSHORSE:
			BunkerHeadlessHorse_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SCOUT:
			MedivalScout_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_VILLAGER:
			MedivalVillager_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_BUILDING:
			MedivalBuilding_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_CONSTRUCT:
			MedivalConstruct_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_CHAMPION:
			MedivalChampion_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_LIGHT_CAV:
			MedivalLightCav_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_HUSSAR:
			MedivalHussar_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_KNIGHT:
			MedivalKnight_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_OBUCH:
			MedivalObuch_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_MONK:
			MedivalMonk_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BARRACK_MILITIA, BARRACK_ARCHER, BARRACK_MAN_AT_ARMS, BARRACK_CROSSBOW, BARRACK_SWORDSMAN, BARRACK_ARBELAST,
		BARRACK_TWOHANDED, BARRACK_LONGBOW, BARRACK_CHAMPION, BARRACK_MONK, BARRACK_HUSSAR, BARRACK_LASTKNIGHT, BARRACKS_TEUTONIC_KNIGHT,
		BARRACKS_VILLAGER,BARRACKS_BUILDING:
			BarrackBody_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_HALB:
			MedivalHalb_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_BRAWLER:
			MedivalBrawler_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_LONGBOWMEN:
			MedivalLongbowmen_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_ARBALEST:
			MedivalArbalest_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_ELITE_LONGBOWMEN:
			MedivalEliteLongbowmen_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_CAVALARY:
			MedivalCavalary_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_PALADIN:
			MedivalPaladin_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_CROSSBOW_GIANT:
			MedivalCrossbowGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SWORDSMAN_GIANT:
			MedivalSwordsmanGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_EAGLE_WARRIOR:
			MedivalEagleWarrior_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_RIDDENARCHER:
			MedivalRiddenArcher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_EAGLE_GIANT:
			MedivalEagleGiant_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_SON_OF_OSIRIS:
			MedivalSonOfOsiris_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case MEDIVAL_ACHILLES:
			MedivalAchilles_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case MEDIVAL_TREBUCHET:
	//		MedivalTrebuchet_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_IKUNAGAE:
			Ikunagae_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ALT_MECHASOLDIER_BARRAGER:
			MechaSoldier_Barrager_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case NEARL_SWORD:
			NearlSwordAbility_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_COMBINE:
			StalkerCombine_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_FATHER:
			StalkerFather_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_GOGGLES:
			StalkerGoggles_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_SILVESTER:
			RaidbossSilvester_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			RaidbossBlueGoggles_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_SUPERSILVESTER:
			RaidbossSilvester_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_NEMESIS:
			RaidbossNemesis_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEARUNNER, SEARUNNER_ALT:
			SeaRunner_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEASLIDER, SEASLIDER_ALT:
			SeaSlider_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEASPITTER, SEASPITTER_ALT:
			SeaSpitter_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEAREAPER, SEAREAPER_ALT:
			SeaReaper_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEACRAWLER, SEACRAWLER_ALT:
			SeaCrawler_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEAPIERCER, SEAPIERCER_ALT:
			SeaPiercer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case FIRSTTOTALK:
			FirstToTalk_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case UNDERTIDES:
	//		UnderTides_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_KAZIMIERZ_KNIGHT:
			KazimierzKnight_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_KAZIMIERZ_KNIGHT_ARCHER:
			KazimierzKnightArcher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_KAZIMIERZ_BESERKER:
			KazimierzBeserker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_KAZIMIERZ_LONGARCHER:
			KazimierzLongArcher_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case REMAINS:
	//		Remains_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ENDSPEAKER_1:
			EndSpeaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ENDSPEAKER_2:
			EndSpeaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ENDSPEAKER_3:
			EndSpeaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case ENDSPEAKER_4:
			EndSpeaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEAFOUNDER, SEAFOUNDER_ALT, SEAFOUNDER_CARRIER:
			SeaFounder_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEAPREDATOR, SEAPREDATOR_ALT, SEAPREDATOR_CARRIER:
			SeaPredator_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABRANDGUIDER, SEABRANDGUIDER_ALT, SEABRANDGUIDER_CARRIER:
			SeaBrandguider_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_KAZIMIERZ_ASSASIN_MELEE:
			KazimierzKnightAssasin_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEASPEWER, SEASPEWER_ALT, SEASPEWER_CARRIER:
			SeaSpewer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEASWARMCALLER, SEASWARMCALLER_ALT, SEASWARMCALLER_CARRIER:
			SeaSwarmcaller_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEAREEFBREAKER, SEAREEFBREAKER_ALT, SEAREEFBREAKER_CARRIER:
			SeaReefbreaker_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BARRACK_THORNS:
			BarrackBody_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case RAIDMODE_GOD_ARKANTOS:
			GodArkantos_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case SEABORN_SCOUT, SEABORN_SOLDIER, SEABORN_PYRO, SEABORN_DEMO, SEABORN_ENGINEER, SEABORN_MEDIC, SEABORN_SNIPER, SEABORN_SPY:
			Generic_OnTakeDamage(victim, attacker);
		
		case SEABORN_HEAVY:
			SeabornHeavy_OnTakeDamage(victim, attacker, damagetype);
		
		case LASTKNIGHT:
			LastKnight_OnTakeDamage(victim, attacker, damage, weapon);
		
		case SAINTCARMEN, PATHSHAPER_FRACTAL:
			Generic_OnTakeDamage(victim, attacker);
		
		case PATHSHAPER:
			Pathshaper_OnTakeDamage(victim, attacker);
		
		case TIDELINKED_BISHOP:
			TidelinkedBishop_OnTakeDamage(victim, attacker, damage);
		
		case TIDELINKED_ARCHON:
			TidelinkedArchon_OnTakeDamage(victim, attacker, damage);
		
		case SEABORN_GUARD, SEABORN_VANGUARD, SEABORN_CASTER, SEABORN_SPECIALIST, SEABORN_SUPPORTER:
			Generic_OnTakeDamage(victim, attacker);
		
		case SEABORN_DEFENDER:
			SeabornDefender_OnTakeDamage(victim, attacker, damage, damagetype, damagePosition);
		
		case ISHARMLA:
			Isharmla_OnTakeDamage(victim, attacker, damage);
			
		
		case RUINA_THEOCRACY, RUINA_ADIANTUM, RUINA_LANIUS, RUINA_MAGIA:	//warp
			Ruina_NPC_OnTakeDamage_Override(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);



		case EXPIDONSA_BENERA:
			Benera_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_PENTAL:
			Pental_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_DEFANDA:
			Defanda_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SELFAM_IRE:
			Selfamire_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_VAUSMAGICA:
			Vausmagica_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_PISTOLEER:
			Pistoleer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_DIVERSIONISTICO:
			Diversionistico_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_HEAVYPUNUEL:
			HeavyPunuel_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SEARGENTIDEAL:
			SeargentIdeal_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	return Plugin_Changed;
}


//NORMAL

#include "zombie_riot/npc/normal/npc_headcrabzombie.sp"
#include "zombie_riot/npc/normal/npc_headcrabzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_fastzombie.sp"
#include "zombie_riot/npc/normal/npc_fastzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_torsoless_headcrabzombie.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie_fortified_giant.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_last_survivor.sp"
#include "zombie_riot/npc/normal/npc_combine_police_pistol.sp"
#include "zombie_riot/npc/normal/npc_combine_police_smg.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_ar2.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_shotgun.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_elite.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_giant_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_swordsman_ddt.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_collos_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_overlord.sp"
#include "zombie_riot/npc/normal/npc_zombie_scout_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_engineer_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_heavy_grave.sp"
#include "zombie_riot/npc/normal/npc_flying_armor.sp"
#include "zombie_riot/npc/normal/npc_flying_armor_tiny_swords.sp"
#include "zombie_riot/npc/normal/npc_kamikaze_demo.sp"
#include "zombie_riot/npc/normal/npc_medic_healer.sp"
#include "zombie_riot/npc/normal/npc_zombie_heavy_giant_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_spy_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_minion_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_giant_grave.sp"
#include "zombie_riot/npc/normal/npc_spy_thief.sp"
#include "zombie_riot/npc/normal/npc_spy_trickstabber.sp"
#include "zombie_riot/npc/normal/npc_spy_half_cloacked_main.sp"
#include "zombie_riot/npc/normal/npc_sniper_main.sp"
#include "zombie_riot/npc/normal/npc_zombie_demo_main.sp"
#include "zombie_riot/npc/normal/npc_medic_main.sp"
#include "zombie_riot/npc/normal/npc_zombie_pyro_giant_main.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_deutsch_ritter.sp"
#include "zombie_riot/npc/normal/npc_spy_boss.sp"

//XENO

#include "zombie_riot/npc/xeno/npc_xeno_headcrabzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_headcrabzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_fastzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_fastzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_torsoless_headcrabzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie_fortified_giant.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_last_survivor.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_police_pistol.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_police_smg.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_ar2.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_shotgun.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_elite.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_giant_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_swordsman_ddt.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_collos_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_overlord.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_scout_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_engineer_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_heavy_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_flying_armor.sp"
#include "zombie_riot/npc/xeno/npc_xeno_flying_armor_tiny_swords.sp"
#include "zombie_riot/npc/xeno/npc_xeno_kamikaze_demo.sp"
#include "zombie_riot/npc/xeno/npc_xeno_medic_healer.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_heavy_giant_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_spy_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_minion_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_giant_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_thief.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_trickstabber.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_half_cloacked_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_sniper_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_demo_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_medic_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_pyro_giant_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_deutsch_ritter.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_boss.sp"

#include "zombie_riot/npc/special/npc_panzer.sp"
#include "zombie_riot/npc/special/npc_sawrunner.sp"
#include "zombie_riot/npc/special/npc_l4d2_tank.sp"
#include "zombie_riot/npc/special/npc_itstilives.sp"
#include "zombie_riot/npc/special/npc_phantom_knight.sp"

#include "zombie_riot/npc/btd/npc_bloon.sp"
#include "zombie_riot/npc/btd/npc_moab.sp"
#include "zombie_riot/npc/btd/npc_bfb.sp"
#include "zombie_riot/npc/btd/npc_zomg.sp"
#include "zombie_riot/npc/btd/npc_ddt.sp"
#include "zombie_riot/npc/btd/npc_bad.sp"
#include "zombie_riot/npc/btd/npc_goldbloon.sp"
#include "zombie_riot/npc/btd/npc_bloonarius.sp"

#include "zombie_riot/npc/ally/npc_bob_the_overlord.sp"
#include "zombie_riot/npc/ally/npc_necromancy_combine.sp"
#include "zombie_riot/npc/ally/npc_necromancy_calcium.sp"
#include "zombie_riot/npc/ally/npc_cured_last_survivor.sp"
#include "zombie_riot/npc/ally/npc_citizen.sp"

#include "zombie_riot/npc/raidmode_bosses/npc_true_fusion_warrior.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_blitzkrieg.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_god_arkantos.sp"


//Ruina

#include "zombie_riot/npc/ruina/ruina_npc_enchanced_ai_core.sp"	//this controls almost every ruina npc's behaviors.
//stage 1
#include "zombie_riot/npc/ruina/stage1/npc_ruina_theocracy.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_adiantum.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_lanius.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_magia.sp"


//Alt

#include "zombie_riot/npc/alt/npc_alt_medic_charger.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_berserker.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_supperior_mage.sp"
#include "zombie_riot/npc/alt/npc_alt_kahml.sp"
#include "zombie_riot/npc/alt/npc_alt_combine_soldier_deutsch_ritter.sp"
#include "zombie_riot/npc/alt/npc_alt_sniper_railgunner.sp"
#include "zombie_riot/npc/alt/npc_alt_soldier_barrager.sp"
#include "zombie_riot/npc/alt/npc_alt_the_shit_slapper.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_engineer.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_heavy.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_heavy_giant.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_pyro_giant_main.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_scout.sp"
#include "zombie_riot/npc/alt/npc_alt_combine_soldier_mage.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_apprentice_mage.sp"
#include "zombie_riot/npc/alt/npc_alt_donnerkrieg.sp"
#include "zombie_riot/npc/alt/npc_alt_schwertkrieg.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_constructor.sp"
#include "zombie_riot/npc/alt/npc_alt_ikunagae.sp"
#include "zombie_riot/npc/alt/npc_alt_mecha_soldier_barrager.sp"


#include "zombie_riot/npc/medival/npc_medival_militia.sp"
#include "zombie_riot/npc/medival/npc_medival_archer.sp"
#include "zombie_riot/npc/medival/npc_medival_man_at_arms.sp"
#include "zombie_riot/npc/medival/npc_medival_skirmisher.sp"
#include "zombie_riot/npc/medival/npc_medival_swordsman.sp"
#include "zombie_riot/npc/medival/npc_medival_twohanded_swordsman.sp"
#include "zombie_riot/npc/medival/npc_medival_crossbow.sp"
#include "zombie_riot/npc/medival/npc_medival_spearmen.sp"
#include "zombie_riot/npc/medival/npc_medival_handcannoneer.sp"
#include "zombie_riot/npc/medival/npc_medival_elite_skirmisher.sp"
#include "zombie_riot/npc/medival/npc_medival_pikeman.sp"
#include "zombie_riot/npc/medival/npc_medival_eagle_scout.sp"
#include "zombie_riot/npc/medival/npc_medival_samurai.sp"
#include "zombie_riot/npc/medival/npc_medival_ram.sp"
#include "zombie_riot/npc/medival/npc_medival_scout.sp"
#include "zombie_riot/npc/medival/npc_medival_villager.sp"
#include "zombie_riot/npc/medival/npc_medival_building.sp"
#include "zombie_riot/npc/medival/npc_medival_construct.sp"
#include "zombie_riot/npc/medival/npc_medival_champion.sp"
#include "zombie_riot/npc/medival/npc_medival_light_cav.sp"
#include "zombie_riot/npc/medival/npc_medival_hussar.sp"
#include "zombie_riot/npc/medival/npc_medival_knight.sp"
#include "zombie_riot/npc/medival/npc_medival_obuch.sp"
#include "zombie_riot/npc/medival/npc_medival_monk.sp"
#include "zombie_riot/npc/medival/npc_medival_halbadeer.sp"
#include "zombie_riot/npc/medival/npc_medival_longbowmen.sp"
#include "zombie_riot/npc/medival/npc_medival_arbalest.sp"
#include "zombie_riot/npc/medival/npc_medival_brawler.sp"
#include "zombie_riot/npc/medival/npc_medival_elite_longbowmen.sp"
#include "zombie_riot/npc/medival/npc_medival_eagle_warrior.sp"
#include "zombie_riot/npc/medival/npc_medival_cavalary.sp"
#include "zombie_riot/npc/medival/npc_medival_paladin.sp"
#include "zombie_riot/npc/medival/npc_medival_crossbow_giant.sp"
#include "zombie_riot/npc/medival/npc_medival_swordsman_giant.sp"
#include "zombie_riot/npc/medival/npc_medival_eagle_giant.sp"
#include "zombie_riot/npc/medival/npc_medival_riddenarcher.sp"
#include "zombie_riot/npc/medival/npc_medival_son_of_osiris.sp"
#include "zombie_riot/npc/medival/npc_medival_achilles.sp"
#include "zombie_riot/npc/medival/npc_medival_trebuchet.sp"

#include "zombie_riot/npc/cof/npc_addiction.sp"
#include "zombie_riot/npc/cof/npc_doctor.sp"
#include "zombie_riot/npc/cof/npc_simon.sp"

#include "zombie_riot/npc/bonezone/npc_basicbones.sp"

#include "zombie_riot/npc/bunker/npc_gambler.sp"
#include "zombie_riot/npc/bunker/npc_pablo.sp"
#include "zombie_riot/npc/bunker/npc_dokmedick.sp"
#include "zombie_riot/npc/bunker/npc_kapheavy.sp"
#include "zombie_riot/npc/bunker/npc_booty_execut.sp"
#include "zombie_riot/npc/bunker/npc_sand_slayer.sp"
#include "zombie_riot/npc/bunker/npc_payday_cloaker.sp"
#include "zombie_riot/npc/bunker/npc_bunker_kahml.sp"
#include "zombie_riot/npc/bunker/npc_zerofuse.sp"
#include "zombie_riot/npc/bunker/npc_bunker_bot_soldier.sp"
#include "zombie_riot/npc/bunker/npc_bunker_bot_sniper.sp"
#include "zombie_riot/npc/bunker/npc_bunker_skeleton.sp"
#include "zombie_riot/npc/bunker/npc_bunker_small_skeleton.sp"
#include "zombie_riot/npc/bunker/npc_bunker_king_skeleton.sp"
#include "zombie_riot/npc/bunker/npc_bunker_hhh.sp"

#include "zombie_riot/npc/ally/npc_barrack.sp"
#include "zombie_riot/npc/ally/npc_barrack_militia.sp"
#include "zombie_riot/npc/ally/npc_barrack_archer.sp"
#include "zombie_riot/npc/ally/npc_barrack_man_at_arms.sp"
#include "zombie_riot/npc/ally/npc_barrack_crossbow.sp"
#include "zombie_riot/npc/ally/npc_barrack_swordsman.sp"
#include "zombie_riot/npc/ally/npc_barrack_arbelast.sp"
#include "zombie_riot/npc/ally/npc_barrack_twohanded.sp"
#include "zombie_riot/npc/ally/npc_barrack_longbow.sp"
#include "zombie_riot/npc/ally/npc_barrack_champion.sp"
#include "zombie_riot/npc/ally/npc_barrack_monk.sp"
#include "zombie_riot/npc/ally/npc_barrack_hussar.sp"
#include "zombie_riot/npc/ally/npc_nearl_sword.sp"
#include "zombie_riot/npc/ally/npc_barrack_thorns.sp"
#include "zombie_riot/npc/ally/npc_barrack_teutonic_knight.sp"
#include "zombie_riot/npc/ally/npc_barrack_villager.sp"
#include "zombie_riot/npc/ally/npc_barrack_building.sp"

#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_basic_mage.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_iku_nagae.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_intermediate_mage.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_railgunner.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_schwertkrieg.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_donnerkrieg.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_holy_knight.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_mecha_barrager.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_barrager.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_berserker.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_crossbowman.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_alt_barracks_scientific_witchery.sp"

#include "zombie_riot/npc/respawn/npc_stalker_combine.sp"
#include "zombie_riot/npc/respawn/npc_stalker_father.sp"
#include "zombie_riot/npc/respawn/npc_stalker_goggles.sp"

#include "zombie_riot/npc/raidmode_bosses/xeno/npc_infected_silvester.sp"
#include "zombie_riot/npc/raidmode_bosses/xeno/npc_infected_goggles.sp"
#include "zombie_riot/npc/raidmode_bosses/xeno/npc_nemesis.sp"

#include "zombie_riot/npc/seaborn/npc_firsttotalk.sp"
#include "zombie_riot/npc/seaborn/npc_seacrawler.sp"
#include "zombie_riot/npc/seaborn/npc_seapiercer.sp"
#include "zombie_riot/npc/seaborn/npc_seareaper.sp"
#include "zombie_riot/npc/seaborn/npc_searunner.sp"
#include "zombie_riot/npc/seaborn/npc_seaslider.sp"
#include "zombie_riot/npc/seaborn/npc_seaspitter.sp"
#include "zombie_riot/npc/seaborn/npc_undertides.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_kazimersch_knight.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_kazimersch_archer.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_kazimersch_beserker.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_kazimersch_longrange.sp"
#include "zombie_riot/npc/seaborn/npc_remains.sp"
#include "zombie_riot/npc/seaborn/npc_endspeaker_shared.sp"
#include "zombie_riot/npc/seaborn/npc_endspeaker_1.sp"
#include "zombie_riot/npc/seaborn/npc_endspeaker_2.sp"
#include "zombie_riot/npc/seaborn/npc_endspeaker_3.sp"
#include "zombie_riot/npc/seaborn/npc_endspeaker_4.sp"
#include "zombie_riot/npc/seaborn/npc_netherseafounder.sp"
#include "zombie_riot/npc/seaborn/npc_netherseapredator.sp"
#include "zombie_riot/npc/seaborn/npc_netherseabrandguider.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_kazimersch_melee_assasin.sp"
#include "zombie_riot/npc/seaborn/npc_netherseaspewer.sp"
#include "zombie_riot/npc/seaborn/npc_netherseaswarmcaller.sp"
#include "zombie_riot/npc/seaborn/npc_netherseareefbreaker.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_scout.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_soldier.sp"
#include "zombie_riot/npc/seaborn/npc_citizen_runner.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_pyro.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_demo.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_heavy.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_engineer.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_medic.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_sniper.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_spy.sp"
#include "zombie_riot/npc/seaborn/npc_lastknight.sp"
#include "zombie_riot/npc/ally/npc_barrack_lastknight.sp"
#include "zombie_riot/npc/seaborn/npc_saintcarmen.sp"
#include "zombie_riot/npc/seaborn/npc_pathshaper.sp"
#include "zombie_riot/npc/seaborn/npc_pathshaper_fractal.sp"
#include "zombie_riot/npc/seaborn/npc_tidelinkedbishop.sp"
#include "zombie_riot/npc/seaborn/npc_tidelinkedarchon.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_guard.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_defender.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_vanguard.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_caster.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_specialist.sp"
#include "zombie_riot/npc/seaborn/npc_seaborn_supporter.sp"
#include "zombie_riot/npc/seaborn/npc_isharmla.sp"
#include "zombie_riot/npc/seaborn/npc_isharmla_trans.sp"


#include "zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"
#include "zombie_riot/npc/expidonsa/npc_benera.sp"
#include "zombie_riot/npc/expidonsa/npc_pental.sp"
#include "zombie_riot/npc/expidonsa/npc_defanda.sp"
#include "zombie_riot/npc/expidonsa/npc_selfam_ire.sp"
#include "zombie_riot/npc/expidonsa/npc_vaus_magica.sp"
#include "zombie_riot/npc/expidonsa/npc_benera_pistoleer.sp"
#include "zombie_riot/npc/expidonsa/npc_diversionistico.sp"
#include "zombie_riot/npc/expidonsa/npc_heavy_punuel.sp"
#include "zombie_riot/npc/expidonsa/npc_seargent_ideal.sp"
