#pragma semicolon 1
#pragma newdecls required

#define ITSTILIVES 666

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
	"Bunker Headless Horseman"
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
	"",
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
	"npc_bunker_hhh"
};

void NPC_MapStart()
{
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
	
	Bloon_MapStart();
	Moab_MapStart();
	Bfb_MapStart();
	Zomg_MapStart();
	DDT_MapStart();
	Bad_MapStart();
	AltMedicApprenticeMage_OnMapStart_NPC();
	SawRunner_OnMapStart_NPC();
	TrueFusionWarrior_OnMapStart();
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
	Blitzkrieg_OnMapStart();
	MedivalPikeman_OnMapStart_NPC();
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC();
	Citizen_OnMapStart();
	MedivalEagleScout_OnMapStart_NPC();
	MedivalSamurai_OnMapStart_NPC();
	Kahmlstein_OnMapStart_NPC();
	Sniper_railgunner_OnMapStart_NPC();
	
	L4D2_Tank_OnMapStart_NPC();
	Addiction_OnMapStart_NPC();
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
}

any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case HEADCRAB_ZOMBIE:
		{
			entity = HeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_HEADCRAB_ZOMBIE:
		{
			entity = FortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FASTZOMBIE:
		{
			entity = FastZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_FASTZOMBIE:
		{
			entity = FortifiedFastZombie(client, vecPos, vecAng, ally);
		}
		case TORSOLESS_HEADCRAB_ZOMBIE:
		{
			entity = TorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			entity = FortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		}
		case POISON_ZOMBIE:
		{
			entity = PoisonZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_POISON_ZOMBIE:
		{
			entity = FortifiedPoisonZombie(client, vecPos, vecAng, ally);
		}
		case FATHER_GRIGORI:
		{
			entity = FatherGrigori(client, vecPos, vecAng, ally);
		}
		case COMBINE_POLICE_PISTOL:
		{
			entity = Combine_Police_Pistol(client, vecPos, vecAng, ally);
		}
		case COMBINE_POLICE_SMG:
		{
			entity = CombinePoliceSmg(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_AR2:
		{
			entity = CombineSoldierAr2(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_SHOTGUN:
		{
			entity = CombineSoldierShotgun(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_SWORDSMAN:
		{
			entity = CombineSwordsman(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_ELITE:
		{
			entity = CombineElite(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			entity = CombineGaint(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_DDT:
		{
			entity = CombineDDT(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_COLLOSS:
		{
			entity = CombineCollos(client, vecPos, vecAng, ally);
		}
		case COMBINE_OVERLORD:
		{
			entity = CombineOverlord(client, vecPos, vecAng, ally);
		}
		case SCOUT_ZOMBIE:
		{
			entity = Scout(client, vecPos, vecAng, ally);
		}
		case ENGINEER_ZOMBIE:
		{
			entity = Engineer(client, vecPos, vecAng, ally);
		}
		case HEAVY_ZOMBIE:
		{
			entity = Heavy(client, vecPos, vecAng, ally);
		}
		case FLYINGARMOR_ZOMBIE:
		{
			entity = FlyingArmor(client, vecPos, vecAng, ally);
		}
		case FLYINGARMOR_TINY_ZOMBIE:
		{
			entity = FlyingArmorTiny(client, vecPos, vecAng, ally);
		}
		case KAMIKAZE_DEMO:
		{
			entity = Kamikaze(client, vecPos, vecAng, ally);
		}
		case MEDIC_HEALER:
		{
			entity = MedicHealer(client, vecPos, vecAng, ally);
		}
		case HEAVY_ZOMBIE_GIANT:
		{
			entity = HeavyGiant(client, vecPos, vecAng, ally);
		}
		case SPY_FACESTABBER:
		{
			entity = Spy(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ROCKET_ZOMBIE:
		{
			entity = Soldier(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ZOMBIE_MINION:
		{
			entity = SoldierMinion(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ZOMBIE_BOSS:
		{
			entity = SoldierGiant(client, vecPos, vecAng, ally);
		}
		case SPY_THIEF:
		{
			entity = SpyThief(client, vecPos, vecAng, ally);
		}
		case SPY_TRICKSTABBER:
		{
			entity = SpyTrickstabber(client, vecPos, vecAng, ally);
		}
		case SPY_HALF_CLOACKED:
		{
			entity = SpyCloaked(client, vecPos, vecAng, ally);
		}
		case SNIPER_MAIN:
		{
			entity = SniperMain(client, vecPos, vecAng, ally);
		}
		case DEMO_MAIN:
		{
			entity = DemoMain(client, vecPos, vecAng, ally);
		}
		case BATTLE_MEDIC_MAIN:
		{
			entity = MedicMain(client, vecPos, vecAng, ally);
		}
		case GIANT_PYRO_MAIN:
		{
			entity = PyroGiant(client, vecPos, vecAng, ally);
		}
		case COMBINE_DEUTSCH_RITTER:
		{
			entity = CombineDeutsch(client, vecPos, vecAng, ally);
		}
		case ALT_COMBINE_DEUTSCH_RITTER:
		{
			entity = Alt_CombineDeutsch(client, vecPos, vecAng, ally);
		}
		case SPY_MAIN_BOSS:
		{
			entity = SpyMainBoss(client, vecPos, vecAng, ally);
		}
		//XENO
		case XENO_HEADCRAB_ZOMBIE:
		{
			entity = XenoHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
		{
			entity = XenoFortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FASTZOMBIE:
		{
			entity = XenoFastZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_FASTZOMBIE:
		{
			entity = XenoFortifiedFastZombie(client, vecPos, vecAng, ally);
		}
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
		{
			entity = XenoTorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			entity = XenoFortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_POISON_ZOMBIE:
		{
			entity = XenoPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_POISON_ZOMBIE:
		{
			entity = XenoFortifiedPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FATHER_GRIGORI:
		{
			entity = XenoFatherGrigori(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_POLICE_PISTOL:
		{
			entity = XenoCombinePolicePistol(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_POLICE_SMG:
		{
			entity = XenoCombinePoliceSmg(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_AR2:
		{
			entity = XenoCombineSoldierAr2(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_SHOTGUN:
		{
			entity = XenoCombineSoldierShotgun(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
		{
			entity = XenoCombineSwordsman(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_ELITE:
		{
			entity = XenoCombineElite(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			entity = XenoCombineGaint(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_DDT:
		{
			entity = XenoCombineDDT(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_COLLOSS:
		{
			entity = XenoCombineCollos(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_OVERLORD:
		{
			entity = XenoCombineOverlord(client, vecPos, vecAng, ally);
		}
		case XENO_SCOUT_ZOMBIE:
		{
			entity = XenoScout(client, vecPos, vecAng, ally);
		}
		case XENO_ENGINEER_ZOMBIE:
		{
			entity = XenoEngineer(client, vecPos, vecAng, ally);
		}
		case XENO_HEAVY_ZOMBIE:
		{
			entity = XenoHeavy(client, vecPos, vecAng, ally);
		}
		case XENO_FLYINGARMOR_ZOMBIE:
		{
			entity = XenoFlyingArmor(client, vecPos, vecAng, ally);
		}
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
		{
			entity = XenoFlyingArmorTiny(client, vecPos, vecAng, ally);
		}
		case XENO_KAMIKAZE_DEMO:
		{
			entity = XenoKamikaze(client, vecPos, vecAng, ally);
		}
		case XENO_MEDIC_HEALER:
		{
			entity = XenoMedicHealer(client, vecPos, vecAng, ally);
		}
		case XENO_HEAVY_ZOMBIE_GIANT:
		{
			entity = XenoHeavyGiant(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_FACESTABBER:
		{
			entity = XenoSpy(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ROCKET_ZOMBIE:
		{
			entity = XenoSoldier(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ZOMBIE_MINION:
		{
			entity = XenoSoldierMinion(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ZOMBIE_BOSS:
		{
			entity = XenoSoldierGiant(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_THIEF:
		{
			entity = XenoSpyThief(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_TRICKSTABBER:
		{
			entity = XenoSpyTrickstabber(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_HALF_CLOACKED:
		{
			entity = XenoSpyCloaked(client, vecPos, vecAng, ally);
		}
		case XENO_SNIPER_MAIN:
		{
			entity = XenoSniperMain(client, vecPos, vecAng, ally);
		}
		case XENO_DEMO_MAIN:
		{
			entity = XenoDemoMain(client, vecPos, vecAng, ally);
		}
		case XENO_BATTLE_MEDIC_MAIN:
		{
			entity = XenoMedicMain(client, vecPos, vecAng, ally);
		}
		case XENO_GIANT_PYRO_MAIN:
		{
			entity = XenoPyroGiant(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_DEUTSCH_RITTER:
		{
			entity = XenoCombineDeutsch(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_MAIN_BOSS:
		{
			entity = XenoSpyMainBoss(client, vecPos, vecAng, ally);
		}
		case NAZI_PANZER:
		{
			entity = NaziPanzer(client, vecPos, vecAng, ally);
		}
		case BOB_THE_GOD_OF_GODS:
		{
			entity = BobTheGod(client, vecPos, vecAng);
		}
		case NECRO_COMBINE:
		{
			entity = NecroCombine(client, vecPos, vecAng, StringToFloat(data));
		}
		case NECRO_CALCIUM:
		{
			entity = NecroCalcium(client, vecPos, vecAng, StringToFloat(data));
		}
		case CURED_FATHER_GRIGORI:
		{
			entity = CuredFatherGrigori(client, vecPos, vecAng);
		}
		case ALT_COMBINE_MAGE:
		{
			entity = AltCombineMage(client, vecPos, vecAng, ally);
		}
		case BTD_BLOON:
		{
			entity = Bloon(client, vecPos, vecAng, ally, data);
		}
		case BTD_MOAB:
		{
			entity = Moab(client, vecPos, vecAng, ally, data);
		}
		case BTD_BFB:
		{
			entity = BFB(client, vecPos, vecAng, ally, data);
		}
		case BTD_ZOMG:
		{
			entity = Zomg(client, vecPos, vecAng, ally, data);
		}
		case BTD_DDT:
		{
			entity = DDT(client, vecPos, vecAng, ally, data);
		}
		case BTD_BAD:
		{
			entity = Bad(client, vecPos, vecAng, ally, data);
		}
		case ALT_MEDIC_APPRENTICE_MAGE:
		{
			entity = AltMedicApprenticeMage(client, vecPos, vecAng, ally);
		}
		case SAWRUNNER:
		{
			entity = SawRunner(client, vecPos, vecAng, ally);
		}
		case RAIDMODE_TRUE_FUSION_WARRIOR:
		{
			entity = TrueFusionWarrior(client, vecPos, vecAng, ally);
		}
		case ALT_MEDIC_CHARGER:
        {
            entity = AltMedicCharger(client, vecPos, vecAng, ally);
        }
        case ALT_MEDIC_BERSERKER:
		{
			entity = AltMedicBerseker(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_MILITIA:
		{
			entity = MedivalMilitia(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_ARCHER:
		{
			entity = MedivalArcher(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_MAN_AT_ARMS:
		{
			entity = MedivalManAtArms(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SKIRMISHER:
		{
			entity = MedivalSkirmisher(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SWORDSMAN:
		{
			entity = MedivalSwordsman(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_TWOHANDED_SWORDSMAN:
		{
			entity = MedivalTwoHandedSwordsman(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_CROSSBOW_MAN:
		{
			entity = MedivalCrossbowMan(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SPEARMEN:
		{
			entity = MedivalSpearMan(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			entity = MedivalHandCannoneer(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			entity = MedivalEliteSkirmisher(client, vecPos, vecAng, ally);
		}
		case RAIDMODE_BLITZKRIEG:
		{
			entity = Blitzkrieg(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_PIKEMAN:
		{
			entity = MedivalPikeman(client, vecPos, vecAng, ally);
		}
		case ALT_MEDIC_SUPPERIOR_MAGE:
		{
			entity = NPC_ALT_MEDIC_SUPPERIOR_MAGE(client, vecPos, vecAng, ally);
		}
		case CITIZEN:
		{
			entity = Citizen(client, vecPos, vecAng, data);
		}
		case MEDIVAL_EAGLE_SCOUT:
		{
			entity = MedivalEagleScout(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SAMURAI:
		{
			entity = MedivalSamurai(client, vecPos, vecAng, ally);
		}
		case THEADDICTION:
		{
			entity = Addicition(client, vecPos, vecAng, ally, data);
		}
		case THEDOCTOR:
		{
			entity = Doctor(client, vecPos, vecAng, ally, data);
		}
		case BOOKSIMON:
		{
			entity = Simon(client, vecPos, vecAng, ally, data);
		}
		case ALT_KAHMLSTEIN:
		{
			entity = Kahmlstein(client, vecPos, vecAng, ally);
		}
		case L4D2_TANK:
		{
			entity = L4D2_Tank(client, vecPos, vecAng, ally);
		}
		case ALT_SNIPER_RAILGUNNER:
		{
			entity = Sniper_railgunner(client, vecPos, vecAng, ally);
		}
		case BTD_GOLDBLOON:
		{
			entity = GoldBloon(client, vecPos, vecAng, ally, data);
		}
		case BTD_BLOONARIUS:
		{
			entity = Bloonarius(client, vecPos, vecAng, ally, data);
		}
		case MEDIVAL_RAM:
		{
			entity = MedivalRam(client, vecPos, vecAng, ally, data);
		}
		case ALT_SOLDIER_BARRAGER:
		{
			entity = Soldier_Barrager(client, vecPos, vecAng, ally);
		}
		case ALT_The_Shit_Slapper:
		{
			entity = The_Shit_Slapper(client, vecPos, vecAng, ally);
		}
		case BONEZONE_BASICBONES:
		{
			entity = BasicBones(client, vecPos, vecAng, ally);
		}
		case ITSTILIVES:
		{
			entity = Itstilives(client, vecPos, vecAng);
		}
		case ALT_MECHA_ENGINEER:
		{
			entity = Mecha_Engineer(client, vecPos, vecAng, ally);
		}
		case ALT_MECHA_HEAVY:
		{
			entity = Mecha_Heavy(client, vecPos, vecAng, ally);
		}
		case ALT_MECHA_HEAVYGIANT:
		{
			entity = Mecha_HeavyGiant(client, vecPos, vecAng, ally);
		}
		case ALT_MECHA_PYROGIANT:
		{
			entity = Mecha_PyroGiant(client, vecPos, vecAng, ally);
		}
		case ALT_MECHA_SCOUT:
		{
			entity = Mecha_Scout(client, vecPos, vecAng, ally);
		}
		case ALT_DONNERKRIEG:
		{
			entity = Donnerkrieg(client, vecPos, vecAng, ally);
		}
		case ALT_SCHWERTKRIEG:
		{
			entity = Schwertkrieg(client, vecPos, vecAng, ally);
		}
		case PHANTOM_KNIGHT:
		{
			entity = PhantomKnight(client, vecPos, vecAng, ally);
		}
		case ALT_MEDIC_HEALER_3:	//3 being the 3rd stage of alt waves.
		{
			entity = Alt_Medic_Constructor(client, vecPos, vecAng, ally);
		}
		case THE_GAMBLER:
		{
			entity = TheGambler(client, vecPos, vecAng, ally);
		}
		case PABLO_GONZALES:
		{
			entity = Pablo_Gonzales(client, vecPos, vecAng, ally);
		}
		case DOKTOR_MEDICK:
		{
			entity = Doktor_Medick(client, vecPos, vecAng, ally);
		}
		case KAPTAIN_HEAVY:
		{
			entity = Eternal_Kaptain_Heavy(client, vecPos, vecAng, ally);
		}
		case BOOTY_EXECUTIONIER:
		{
			entity = BootyExecutioner(client, vecPos, vecAng, ally);
		}
		case SANDVICH_SLAYER:
		{
			entity = SandvichSlayer(client, vecPos, vecAng, ally);
		}
		case PAYDAYCLOAKER:
		{
			entity = Payday_Cloaker(client, vecPos, vecAng, ally);
		}
		case BUNKER_KAHML_VTWO:
		{
			entity = BunkerKahml(client, vecPos, vecAng, ally);
		}
		case TRUE_ZEROFUSE:
		{
			entity = TrueZerofuse(client, vecPos, vecAng, ally);
		}
		case BUNKER_BOT_SOLDIER:
		{
			entity = BunkerBotSoldier(client, vecPos, vecAng, ally);
		}
		case BUNKER_BOT_SNIPER:
		{
			entity = BunkerBotSniper(client, vecPos, vecAng, ally);
		}
		case BUNKER_SKELETON:
		{
			entity = BunkerSkeleton(client, vecPos, vecAng, ally);
		}
		case BUNKER_SMALL_SKELETON:
		{
			entity = BunkerSkeletonKing(client, vecPos, vecAng, ally);
		}
		case BUNKER_KING_SKELETON:
		{
			entity = BunkerSkeletonKing(client, vecPos, vecAng, ally);
		}
		case BUNKER_HEADLESSHORSE:
		{
			entity = BunkerHeadlessHorse(client, vecPos, vecAng, ally);
		}
		default:
		{
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%i] Is not a valid npc!", Index_Of_Npc);
		}
	}
	
	return entity;
}	
public void NPCDeath(int entity)
{
	switch(i_NpcInternalId[entity])
	{
		case HEADCRAB_ZOMBIE:
		{
			HeadcrabZombie_NPCDeath(entity);
		}
		case FORTIFIED_HEADCRAB_ZOMBIE:
		{
			FortifiedHeadcrabZombie_NPCDeath(entity);
		}
		case FASTZOMBIE:
		{
			FastZombie_NPCDeath(entity);
		}
		case FORTIFIED_FASTZOMBIE:
		{
			FortifiedFastZombie_NPCDeath(entity);
		}
		case TORSOLESS_HEADCRAB_ZOMBIE:
		{
			TorsolessHeadcrabZombie_NPCDeath(entity);
		}
		case FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			FortifiedGiantPoisonZombie_NPCDeath(entity);
		}
		case POISON_ZOMBIE:
		{
			PoisonZombie_NPCDeath(entity);
		}
		case FORTIFIED_POISON_ZOMBIE:
		{
			FortifiedPoisonZombie_NPCDeath(entity);
		}
		case FATHER_GRIGORI:
		{
			FatherGrigori_NPCDeath(entity);
		}
		case COMBINE_POLICE_PISTOL:
		{
			CombinePolicePistol_NPCDeath(entity);
		}
		case COMBINE_POLICE_SMG:
		{
			CombinePoliceSmg_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_AR2:
		{
			CombineSoldierAr2_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_SHOTGUN:
		{
			CombineSoldierShotgun_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_SWORDSMAN:
		{
			CombineSwordsman_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_ELITE:
		{
			CombineElite_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			CombineGaint_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_DDT:
		{
			CombineDDT_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_COLLOSS:
		{
			CombineCollos_NPCDeath(entity);
		}
		case COMBINE_OVERLORD:
		{
			CombineOverlord_NPCDeath(entity);
		}
		case SCOUT_ZOMBIE:
		{
			Scout_NPCDeath(entity);
		}
		case ENGINEER_ZOMBIE:
		{
			Engineer_NPCDeath(entity);
		}
		case HEAVY_ZOMBIE:
		{
			Heavy_NPCDeath(entity);
		}
		case FLYINGARMOR_ZOMBIE:
		{
			FlyingArmor_NPCDeath(entity);
		}
		case FLYINGARMOR_TINY_ZOMBIE:
		{
			FlyingArmorTiny_NPCDeath(entity);
		}
		case KAMIKAZE_DEMO:
		{
			Kamikaze_NPCDeath(entity);
		}
		case MEDIC_HEALER:
		{
			MedicHealer_NPCDeath(entity);
		}
		case HEAVY_ZOMBIE_GIANT:
		{
			HeavyGiant_NPCDeath(entity);
		}
		case SPY_FACESTABBER:
		{
			Spy_NPCDeath(entity);
		}
		case SOLDIER_ROCKET_ZOMBIE:
		{
			Soldier_NPCDeath(entity);
		}
		case SOLDIER_ZOMBIE_MINION:
		{
			SoldierMinion_NPCDeath(entity);
		}
		case SOLDIER_ZOMBIE_BOSS:
		{
			SoldierGiant_NPCDeath(entity);
		}
		case SPY_THIEF:
		{
			SpyThief_NPCDeath(entity);
		}
		case SPY_TRICKSTABBER:
		{
			SpyTrickstabber_NPCDeath(entity);
		}
		case SPY_HALF_CLOACKED:
		{
			SpyCloaked_NPCDeath(entity);
		}
		case SNIPER_MAIN:
		{
			SniperMain_NPCDeath(entity);
		}
		case DEMO_MAIN:
		{
			DemoMain_NPCDeath(entity);
		}
		case BATTLE_MEDIC_MAIN:
		{
			MedicMain_NPCDeath(entity);
		}
		case GIANT_PYRO_MAIN:
		{
			PyroGiant_NPCDeath(entity);
		}
		case COMBINE_DEUTSCH_RITTER:
		{
			CombineDeutsch_NPCDeath(entity);
		}
		case ALT_COMBINE_DEUTSCH_RITTER:
		{
			Alt_CombineDeutsch_NPCDeath(entity);
		}
		case SPY_MAIN_BOSS:
		{
			SpyMainBoss_NPCDeath(entity);
		}
		//XENO
		case XENO_HEADCRAB_ZOMBIE:
		{
			XenoHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
		{
			XenoFortifiedHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FASTZOMBIE:
		{
			XenoFastZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_FASTZOMBIE:
		{
			XenoFortifiedFastZombie_NPCDeath(entity);
		}
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
		{
			XenoTorsolessHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			XenoFortifiedGiantPoisonZombie_NPCDeath(entity);
		}
		case XENO_POISON_ZOMBIE:
		{
			XenoPoisonZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_POISON_ZOMBIE:
		{
			XenoFortifiedPoisonZombie_NPCDeath(entity);
		}
		case XENO_FATHER_GRIGORI:
		{
			XenoFatherGrigori_NPCDeath(entity);
		}
		case XENO_COMBINE_POLICE_PISTOL:
		{
			XenoCombinePolicePistol_NPCDeath(entity);
		}
		case XENO_COMBINE_POLICE_SMG:
		{
			XenoCombinePoliceSmg_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_AR2:
		{
			XenoCombineSoldierAr2_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_SHOTGUN:
		{
			XenoCombineSoldierShotgun_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
		{
			XenoCombineSwordsman_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_ELITE:
		{
			XenoCombineElite_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			XenoCombineGaint_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_DDT:
		{
			XenoCombineDDT_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_COLLOSS:
		{
			XenoCombineCollos_NPCDeath(entity);
		}
		case XENO_COMBINE_OVERLORD:
		{
			XenoCombineOverlord_NPCDeath(entity);
		}
		case XENO_SCOUT_ZOMBIE:
		{
			XenoScout_NPCDeath(entity);
		}
		case XENO_ENGINEER_ZOMBIE:
		{
			XenoEngineer_NPCDeath(entity);
		}
		case XENO_HEAVY_ZOMBIE:
		{
			XenoHeavy_NPCDeath(entity);
		}
		case XENO_FLYINGARMOR_ZOMBIE:
		{
			XenoFlyingArmor_NPCDeath(entity);
		}
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
		{
			XenoFlyingArmorTiny_NPCDeath(entity);
		}
		case XENO_KAMIKAZE_DEMO:
		{
			XenoKamikaze_NPCDeath(entity);
		}
		case XENO_MEDIC_HEALER:
		{
			XenoMedicHealer_NPCDeath(entity);
		}
		case XENO_HEAVY_ZOMBIE_GIANT:
		{
			XenoHeavyGiant_NPCDeath(entity);
		}
		case XENO_SPY_FACESTABBER:
		{
			XenoSpy_NPCDeath(entity);
		}
		case XENO_SOLDIER_ROCKET_ZOMBIE:
		{
			XenoSoldier_NPCDeath(entity);
		}
		case XENO_SOLDIER_ZOMBIE_MINION:
		{
			XenoSoldierMinion_NPCDeath(entity);
		}
		case XENO_SOLDIER_ZOMBIE_BOSS:
		{
			XenoSoldierGiant_NPCDeath(entity);
		}
		case XENO_SPY_THIEF:
		{
			XenoSpyThief_NPCDeath(entity);
		}
		case XENO_SPY_TRICKSTABBER:
		{
			XenoSpyTrickstabber_NPCDeath(entity);
		}
		case XENO_SPY_HALF_CLOACKED:
		{
			XenoSpyCloaked_NPCDeath(entity);
		}
		case XENO_SNIPER_MAIN:
		{
			XenoSniperMain_NPCDeath(entity);
		}
		case XENO_DEMO_MAIN:
		{
			XenoDemoMain_NPCDeath(entity);
		}
		case XENO_BATTLE_MEDIC_MAIN:
		{
			XenoMedicMain_NPCDeath(entity);
		}
		case XENO_GIANT_PYRO_MAIN:
		{
			XenoPyroGiant_NPCDeath(entity);
		}
		case XENO_COMBINE_DEUTSCH_RITTER:
		{
			XenoCombineDeutsch_NPCDeath(entity);
		}
		case XENO_SPY_MAIN_BOSS:
		{
			XenoSpyMainBoss_NPCDeath(entity);
		}
		case NAZI_PANZER:
		{
			NaziPanzer_NPCDeath(entity);
		}
		case BOB_THE_GOD_OF_GODS:
		{
			BobTheGod_NPCDeath(entity);
		}
		case NECRO_COMBINE:
		{
			NecroCombine_NPCDeath(entity);
		}
		case NECRO_CALCIUM:
		{
			NecroCalcium_NPCDeath(entity);
		}
		case CURED_FATHER_GRIGORI:
		{
			CuredFatherGrigori_NPCDeath(entity);
		}
		case ALT_COMBINE_MAGE:
		{
			AltCombineMage_NPCDeath(entity);
		}
		case BTD_BLOON:
		{
			Bloon_NPCDeath(entity);
		}
		case BTD_MOAB:
		{
			Moab_NPCDeath(entity);
		}
		case BTD_BFB:
		{
			Bfb_NPCDeath(entity);
		}
		case BTD_ZOMG:
		{
			Zomg_NPCDeath(entity);
		}
		case BTD_DDT:
		{
			DDT_NPCDeath(entity);
		}
		case BTD_BAD:
		{
			Bad_NPCDeath(entity);
		}
		case ALT_MEDIC_APPRENTICE_MAGE:
		{
			AltMedicApprenticeMage_NPCDeath(entity);
		}
		case SAWRUNNER:
		{
			SawRunner_NPCDeath(entity);
		}
		case RAIDMODE_TRUE_FUSION_WARRIOR:
		{
			TrueFusionWarrior_NPCDeath(entity);
		}
		case ALT_MEDIC_CHARGER:
        {
            AltMedicCharger_NPCDeath(entity);
        }
        case ALT_MEDIC_BERSERKER:
		{
			AltMedicBerseker_NPCDeath(entity);
		}
		case MEDIVAL_MILITIA:
		{
			MedivalMilitia_NPCDeath(entity);
		}
		case MEDIVAL_ARCHER:
		{
			MedivalArcher_NPCDeath(entity);
		}
		case MEDIVAL_MAN_AT_ARMS:
		{
			MedivalManAtArms_NPCDeath(entity);
		}
		case MEDIVAL_SKIRMISHER:
		{
			MedivalSkirmisher_NPCDeath(entity);
		}
		case MEDIVAL_SWORDSMAN:
		{
			MedivalSwordsman_NPCDeath(entity);
		}
		case MEDIVAL_TWOHANDED_SWORDSMAN:
		{
			MedivalTwoHandedSwordsman_NPCDeath(entity);
		}
		case MEDIVAL_CROSSBOW_MAN:
		{
			MedivalCrossbowMan_NPCDeath(entity);
		}
		case MEDIVAL_SPEARMEN:
		{
			MedivalSpearMan_NPCDeath(entity);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			MedivalHandCannoneer_NPCDeath(entity);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			MedivalEliteSkirmisher_NPCDeath(entity);
		}
		case RAIDMODE_BLITZKRIEG:
		{
			Blitzkrieg_NPCDeath(entity);
		}
		case MEDIVAL_PIKEMAN:
		{
			MedivalPikeman_NPCDeath(entity);
		}
		case ALT_MEDIC_SUPPERIOR_MAGE:
		{
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_NPCDeath(entity);
		}
		case CITIZEN:
		{
			Citizen_NPCDeath(entity);
		}
		case MEDIVAL_EAGLE_SCOUT:
		{
			MedivalEagleScout_NPCDeath(entity);
		}
		case MEDIVAL_SAMURAI:
		{
			MedivalSamurai_NPCDeath(entity);
		}
		case THEADDICTION:
		{
			Addicition_NPCDeath(entity);
		}
		case THEDOCTOR:
		{
			Doctor_NPCDeath(entity);
		}
		case BOOKSIMON:
		{
			Simon_NPCDeath(entity);
		}
		case ALT_KAHMLSTEIN:
		{
			Kahmlstein_NPCDeath(entity);
		}
		case L4D2_TANK:
		{
			L4D2_Tank_NPCDeath(entity);
		}
		case ALT_SNIPER_RAILGUNNER:
		{
			Sniper_railgunner_NPCDeath(entity);
		}
		case BTD_GOLDBLOON:
		{
			GoldBloon_NPCDeath(entity);
		}
		case BTD_BLOONARIUS:
		{
			Bloonarius_NPCDeath(entity);
		}
		case MEDIVAL_RAM:
		{
			MedivalRam_NPCDeath(entity);
		}
		case ALT_SOLDIER_BARRAGER:
		{
			Soldier_Barrager_NPCDeath(entity);
		}
		case ALT_The_Shit_Slapper:
		{
			The_Shit_Slapper_NPCDeath(entity);
		}
		case BONEZONE_BASICBONES:
		{
			BasicBones_NPCDeath(entity);
		}
		case ALT_MECHA_ENGINEER:
		{
			Mecha_Engineer_NPCDeath(entity);
		}
		case ALT_MECHA_HEAVY:
		{
			Mecha_Heavy_NPCDeath(entity);
		}
		case ALT_MECHA_HEAVYGIANT:
		{
			Mecha_HeavyGiant_NPCDeath(entity);
		}
		case ALT_MECHA_PYROGIANT:
		{
			Mecha_PyroGiant_NPCDeath(entity);
		}
		case ALT_MECHA_SCOUT:
		{
			Mecha_Scout_NPCDeath(entity);
		}
		case ALT_DONNERKRIEG:
		{
			Donnerkrieg_NPCDeath(entity);
		}
		case ALT_SCHWERTKRIEG:
		{
			Schwertkrieg_NPCDeath(entity);
		}
		case PHANTOM_KNIGHT:
		{
			PhantomKnight_NPCDeath(entity);
		}
		case ALT_MEDIC_HEALER_3:
		{
			Alt_Medic_Constructor_NPCDeath(entity);
		}
		case THE_GAMBLER:
		{
			TheGambler_NPCDeath(entity);
		}
		case PABLO_GONZALES:
		{
			Pablo_Gonzales_NPCDeath(entity);
		}
		case DOKTOR_MEDICK:
		{
			Doktor_Medick_NPCDeath(entity);
		}
		case KAPTAIN_HEAVY:
		{
			Eternal_Kaptain_Heavy_NPCDeath(entity);
		}
		case BOOTY_EXECUTIONIER:
		{
			BootyExecutioner_NPCDeath(entity);
		}
		case SANDVICH_SLAYER:
		{
			SandvichSlayer_NPCDeath(entity);
		}
		case PAYDAYCLOAKER:
		{
			Payday_Cloaker_NPCDeath(entity);
		}
		case BUNKER_KAHML_VTWO:
		{
			BunkerKahml_NPCDeath(entity);
		}
		case TRUE_ZEROFUSE:
		{
			TrueZerofuse_NPCDeath(entity);
		}
		case BUNKER_BOT_SOLDIER:
		{
			BunkerBotSoldier_NPCDeath(entity);
		}
		case BUNKER_BOT_SNIPER:
		{
			BunkerBotSniper_NPCDeath(entity);
		}
		case BUNKER_SKELETON:
		{
			BunkerSkeleton_NPCDeath(entity);
		}
		case BUNKER_SMALL_SKELETON:
		{
			BunkerSkeletonSmall_NPCDeath(entity);
		}
		case BUNKER_KING_SKELETON:
		{
			BunkerSkeletonKing_NPCDeath(entity);
		}
		case BUNKER_HEADLESSHORSE:
		{
			BunkerHeadlessHorse_NPCDeath(entity);
		}
		default:
		{
			PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		}
	}
	
	if(view_as<CClotBody>(entity).m_iCreditsOnKill)
	{
		CurrentCash += view_as<CClotBody>(entity).m_iCreditsOnKill;
			
		int extra;
		
		int client_killer = GetClientOfUserId(LastHitId[entity]);
		if(client_killer && IsClientInGame(client_killer))
		{
			extra = RoundToFloor(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * Building_GetCashOnKillMulti(client_killer));
			extra -= view_as<CClotBody>(entity).m_iCreditsOnKill;
		}
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(extra > 0)
				{
					CashSpent[client] -= extra;
					CashRecievedNonWave[client] += extra;
				}
				if(GetClientTeam(client)!=2)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.40);
					
				}
				else if (TeutonType[client] == TEUTON_WAITING)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.30);
				}
			}
		}
	}
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
