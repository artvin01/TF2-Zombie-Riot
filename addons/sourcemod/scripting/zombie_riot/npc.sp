#pragma semicolon 1
#pragma newdecls required

#define NORMAL_ENEMY_MELEE_RANGE_FLOAT 130.0
// 130 * 130
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED 16900.0

#define GIANT_ENEMY_MELEE_RANGE_FLOAT 160.0
// 160 * 160
#define GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED 25600.0

#define RAIDITEM_INDEX_WIN_COND 9999

static float f_FactionCreditGain;
static float f_FactionCreditGainReduction[MAXTF2PLAYERS];

static ArrayList NPCList;

enum struct NPCData
{
	char Plugin[64];
	char Name[64];
	int Category;
	Function Func;
	int Flags;
	char Icon[32];
	bool IconCustom;
}

// FileNetwork_ConfigSetup needs to be ran first
void NPC_ConfigSetup()
{
	f_FactionCreditGain = 0.0;
	Zero(f_FactionCreditGainReduction);

	delete NPCList;
	NPCList = new ArrayList(sizeof(NPCData));

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nothing");
	data.Category = Type_Hidden;
	data.Func = INVALID_FUNCTION;
	strcopy(data.Icon, sizeof(data.Icon), "duck");
	NPCList.PushArray(data);

	GetOldMethodNPCs();

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
	
	XenoHeadcrabZombie_OnMapStart_NPC();
	XenoFortified_HeadcrabZombie_OnMapStart_NPC();
	XenoFastZombie_OnMapStart_NPC();
	XenoFortifiedFastZombie_OnMapStart_NPC();
	XenoTorsolessHeadcrabZombie_OnMapStart_NPC();
	XenoFortifiedGiantPoisonZombie_OnMapStart_NPC();
	XenoPoisonZombie_OnMapStart_NPC();
	XenoFortifiedPoisonZombie_OnMapStart_NPC();
	
	XenoFatherGrigori_OnMapStart_NPC();
	
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
	
	
	
	XenoSpyThief_OnMapStart_NPC();
	XenoSpyTrickstabber_OnMapStart_NPC();
	XenoSpyCloaked_OnMapStart_NPC();
	XenoSniperMain_OnMapStart_NPC();
	XenoDemoMain_OnMapStart_NPC();
	XenoMedicMain_OnMapStart_NPC();
	XenoPyroGiant_OnMapStart_NPC();
	XenoCombineDeutsch_OnMapStart_NPC();
	XenoSpyMainBoss_OnMapStart_NPC();
	
	NaziPanzer_OnMapStart_NPC();
	BobTheGod_OnMapStart_NPC();
	NecroCombine_OnMapStart_NPC();
	NecroCalcium_OnMapStart_NPC();
	CuredFatherGrigori_OnMapStart_NPC();
	
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
	MedivalTrebuchet_OnMapStart();
	
	L4D2_Tank_OnMapStart_NPC();
	MedivalRam_OnMapStart();
	
	Soldier_Barrager_OnMapStart_NPC();
	The_Shit_Slapper_OnMapStart_NPC();
	
	BasicBones_OnMapStart_NPC();
	BeefyBones_OnMapStart_NPC();
	BrittleBones_OnMapStart_NPC();
	BigBones_OnMapStart_NPC();
	AlliedLeperVisualiserAbility_OnMapStart_NPC();
	
	Mecha_Engineer_OnMapStart_NPC();
	Mecha_Heavy_OnMapStart_NPC();
	Mecha_HeavyGiant_OnMapStart_NPC();
	Mecha_PyroGiant_OnMapStart_NPC();
	Mecha_Scout_OnMapStart_NPC();
	
	Donnerkrieg_OnMapStart_NPC();
	Schwertkrieg_OnMapStart_NPC();
	PhantomKnight_OnMapStart_NPC();
	BeheadedKamiKaze_OnMapStart_NPC();
	Alt_Medic_Constructor_OnMapStart_NPC();	//3rd alt medic.
	/*
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
	*/
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
	MedivalCavalary_OnMapStart_NPC();
	MedivalCrossbowGiant_OnMapStart();
	MedivalPaladin_OnMapStart_NPC();
	SpecialDoctor_OnMapStart();
	MedivalSwordsmanGiant_OnMapStart();
	MedivalEagleGiant_OnMapStart();
	
	Ikunagae_OnMapStart_NPC();
	MechaSoldier_Barrager_OnMapStart_NPC();
	NearlSwordAbility_OnMapStart_NPC();

	SeaRunner_MapStart();
	SeaSlider_Precache();
	SeaSpitter_Precache();
	SeaReaper_Precache();
	SeaCrawler_MapStart();
	SeaPiercer_MapStart();
	FirstToTalk_MapStart();
	UnderTides_MapStart();
	Remain_MapStart();
	SeaFounder_Precache();
	SeaPredator_Precache();
	SeaBrandguider_Precache();
	SeaSpewer_Precache();
	SeaSwarmcaller_Precache();
	SeaReefbreaker_Precache();
	EndSpeaker_MapStart();
	SeabornScout_Precache();
	SeabornSoldier_Precache();
	CitizenRunner_Precache();
	SeabornPyro_Precache();
	SeabornDemo_Precache();
	SeabornHeavy_Precache();
	SeabornEngineer_Precache();
	SeabornMedic_Precache();
	SeabornSniper_Precache();
	SeabornSpy_Precache();
	KazimierzKnight_OnMapStart_NPC();
	KazimierzKnightArcher_OnMapStart_NPC();
	KazimierzBeserker_OnMapStart_NPC();
	KazimierzLongArcher_OnMapStart_NPC();
	KazimierzKnightAssasin_OnMapStart_NPC();
	LastKnight_Precache();
	SeabornGuard_Precache();
	SeabornVanguard_Precache();
	SeabornDefender_Precache();
	SeabornCaster_Precache();
	SeabornSpecialist_Precache();
	SeabornSupporter_Precache();
	SaintCarmen_Precache();
	TidelinkedArchon_Precache();
	TidelinkedBishop_Precache();
	Pathshaper_Precache();
	PathshaperFractal_Precache();
	Isharmla_Precache();
	IsharmlaTrans_MapStart();
	
	//Ruina waves	//warp
	Ruina_Ai_Core_Mapstart();
	//Stage 1.
	Theocracy_OnMapStart_NPC();
	Adiantum_OnMapStart_NPC();
	Lanius_OnMapStart_NPC();
	Magia_OnMapStart_NPC();
	Stella_OnMapStart_NPC();
	Astria_OnMapStart_NPC();
	Aether_OnMapStart_NPC();
	Europa_OnMapStart_NPC();
	Ruina_Drone_OnMapStart_NPC();
	Ruriana_OnMapStart_NPC();
	Venium_OnMapStart_NPC();
	Daedalus_OnMapStart_NPC();
	Malius_OnMapStart_NPC();
	Laz_OnMapStart_NPC();
	//Stage 2.
	Laniun_OnMapStart_NPC();
	Magnium_OnMapStart_NPC();
	Stellaria_OnMapStart_NPC();
	Astriana_OnMapStart_NPC();
	Europis_OnMapStart_NPC();
	Draedon_OnMapStart_NPC();
	Aetheria_OnMapStart_NPC();
	Maliana_OnMapStart_NPC();
	Ruianus_OnMapStart_NPC();
	Lazius_OnMapStart_NPC();
	Dronian_OnMapStart_NPC();

	//Special.
	Magia_Anchor_OnMapStart_NPC();
	Ruina_Storm_Weaver_MapStart();
	Ruina_Storm_Weaver_Mid_MapStart();

	//Expidonsa Waves
//wave 1-15:
	Benera_OnMapStart_NPC();
	Pental_OnMapStart_NPC();
	Defanda_OnMapStart_NPC();
	SelfamIre_OnMapStart_NPC();
	VausMagica_OnMapStart_NPC();
	Pistoleer_OnMapStart_NPC();
	Diversionistico_OnMapStart_NPC();	//reused in waves all over
	HeavyPunuel_OnMapStart_NPC();
	SeargentIdeal_OnMapStart_NPC();	
//wave 16-30:
	RifalManu_OnMapStart_NPC();
	Siccerino_OnMapStart_NPC();
	SoldinePrototype_OnMapStart_NPC();
	Soldine_OnMapStart_NPC();
	EnegaKapus_OnMapStart_NPC();
	Sniponeer_OnMapStart_NPC();
	EgaBunar_OnMapStart_NPC();
	Protecta_OnMapStart_NPC();
//wave 31 - 45
	CaptinoAgentus_OnMapStart_NPC();
	DualRea_OnMapStart_NPC();
	Guardus_OnMapStart_NPC();
	VausTechicus_OnMapStart_NPC();
	MinigunAssisa_OnMapStart_NPC();
	Ignitus_OnMapStart_NPC();
	Helena_OnMapStart_NPC();
//wave 45-60 there arent as many enemies as im running out of ideas and i want to resuse top enemies
	Erasus_OnMapStart_NPC();
	GiantTankus_OnMapStart_NPC();
	AnfuhrerEisenhard_OnMapStart_NPC();
	SpeedusAdivus_OnMapStart_NPC();

//internius
	DesertAhim_OnMapStart_NPC();
	DesertInabdil_OnMapStart_NPC();
	DesertKhazaan_OnMapStart_NPC();
	DesertSakratan_OnMapStart_NPC();
	DesertYadeam_OnMapStart_NPC();
	DesertRajul_OnMapStart_NPC();
	DesertQanaas_OnMapStart_NPC();
	DesertAtilla_OnMapStart_NPC();
	DesertAncientDemon_OnMapStart_NPC();
	WinterSniper_OnMapStart_NPC();
	WinterZiberianMiner_OnMapStart_NPC();
	WinterSnoweyGunner_OnMapStart_NPC();
	WinterFreezingCleaner_OnMapStart_NPC();
	WinterAirbornExplorer_OnMapStart_NPC();
	WinterArcticMage_OnMapStart_NPC();
	WinterFrostHunter_OnMapStart_NPC();
	WinterSkinHunter_OnMapStart_NPC();
	WinterIrritatedPerson_OnMapStart_NPC();
	AnarchyRansacker_OnMapStart_NPC();
	AnarchyRunover_OnMapStart_NPC();
	AnarchyHitman_OnMapStart_NPC();
	AnarchyMadDoctor_OnMapStart_NPC();
	AnarchyAbomination_OnMapStart_NPC();
	AnarchyEnforcer_OnMapStart_NPC();
	AnarchyBraindead_OnMapStart_NPC();
	AnarchyBehemoth_OnMapStart_NPC();
	AnarchyAbsoluteIncinirator_OnMapStart_NPC();
	MajorSteam_MapStart();
	AegirOnMapStart();
	CautusOnMapStart();
	CaprinaeOnMapStart();
	ArchosauriaOnMapStart();
	AslanOnMapStart();
	LiberiOnMapStart();
	PerroOnMapStart();
	UrsusOnMapStart();

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
	VIPBuilding_MapStart();
	AlliedSensalAbility_OnMapStart_NPC();
	BarrackVillagerOnMapStart();
	BarrackTwoHandedOnMapStart();
	BarrackTeutonOnMapStart();
	BarrackSwordsmanOnMapStart();
	BarrackMonkOnMapStart();
	BarrackMilitiaOnMapStart();
	BarrackManAtArmsOnMapStart();
	BarrackLongbowOnMapStart();
	BarrackHussarOnMapStart();
	BarrackLastKnightOnMapStart();
	BarrackCrossbowOnMapStart();
	BarrackChampionOnMapStart();
	BarrackArcherOnMapStart();
	BarrackArbelastOnMapStart();
	AlliedKahmlAbilityOnMapStart();


	// Raid Low Prio
	TrueFusionWarrior_OnMapStart();
	Blitzkrieg_OnMapStart();
	RaidbossSilvester_OnMapStart();
	RaidbossBlueGoggles_OnMapStart();
	RaidbossNemesis_OnMapStart();
	GodArkantos_OnMapStart();
	Sensal_OnMapStart_NPC();
	Raidboss_Schwertkrieg_OnMapStart_NPC();
	Raidboss_Donnerkrieg_OnMapStart_NPC();
	RaidbossBobTheFirst_OnMapStart();
	TheMessenger_OnMapStart_NPC();
	ChaosKahmlstein_OnMapStart_NPC();
	ThePurge_MapStart();

	// Bloon Low Prio
	Bloon_MapStart();
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

	// Rogue Mode Low Prio
	OverlordRogue_OnMapStart_NPC();
	RaidbossBladedance_MapStart();
}

stock int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");
	
	if(data.Icon[0] && data.IconCustom)
		PrecacheMvMIconCustom(data.Icon);
	
	if(!TranslationPhraseExists(data.Name))
		ThrowError("Translation '%s' does not exist", data.Name);

	return NPCList.PushArray(data);
}

int NPC_GetCount()
{
	return NPCList.Length;
}

int NPC_GetNameById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Name);
}

void NPC_GetById(int id, NPCData data)
{
	NPCList.GetArray(id, data);
}

int NPC_GetByPlugin(const char[] name, NPCData data = {})
{
	int length = NPCList.Length;
	for(int i; i < length; i++)
	{
		NPCList.GetArray(i, data);
		if(StrEqual(name, data.Plugin))
			return i;
	}
	return -1;
}

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
	
	NOTHING_86					= 86,
	
	BTD_BLOON							= 87,
	BTD_MOAB							= 88,
	BTD_BFB								= 89,
	BTD_ZOMG							= 90,
	BTD_DDT								= 91,
	BTD_BAD								= 92,
	
	UNUSED_93			= 93,
	SAWRUNNER							= 94,
	
	RAIDMODE_TRUE_FUSION_WARRIOR		= 95,
	UNUSED_96					= 96,
	UNUSED_97					= 97,
	
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

	MEDIVAL_PIKEMAN						= 109,
	UNUSED_110			= 110,
	CITIZEN								= 111,
	
	MEDIVAL_EAGLE_SCOUT					= 112,
	MEDIVAL_SAMURAI						= 113,
	
	THEADDICTION						= 114,
	THEDOCTOR							= 115,
	BOOKSIMON							= 116,
	UNUSED_117						= 117,
	
	L4D2_TANK							= 118,
	UNUSED_119			= 119,
	UNUSED_120				= 120,
	
	BTD_GOLDBLOON	= 121,
	BTD_BLOONARIUS	= 122,
	BTD_LYCH		= 123,
	BTD_LYCHSOUL	= 124,
	BTD_VORTEX	= 125,
	
	MEDIVAL_RAM	= 126,
	UNUSED_127 = 127,
	UNUSED_128 = 128,
	
	BONEZONE_BASICBONES = 129,
	
	UNUSED_130			= 130,
	UNUSED_131				= 131,
	UNUSED_132		= 132,
	UNUSED_133			= 133,
	UNUSED_134				= 134,
	UNUSED_135				= 135,
	NOTHING_136			= 136,
	PHANTOM_KNIGHT				= 137, //Lucian "Blood diamond"
	UNUSED_138			= 138, //3 being the 3rd stage of alt waves.
	
	THE_GAMBLER					= 139,
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
	
	UNUSED_190				= 190,
	UNUSED_191	= 191,
	NEARL_SWORD					= 192,
	
	STALKER_COMBINE		= 193,
	STALKER_FATHER		= 194,
	STALKER_GOGGLES		= 195,

	XENO_RAIDBOSS_BLUE_GOGGLES	= 197,
	XENO_RAIDBOSS_SUPERSILVESTER	= 198,
	XENO_RAIDBOSS_NEMESIS	= 199,

	BARRACK_THORNS	= 242,
	RAIDMODE_GOD_ARKANTOS = 243,

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
	UNUSED_RUN10 = 284,
	UNUSED_285 = 285,
	EXPIDONSA_PENTAL = 286,
	UNUSED_287 = 287,
	EXPIDONSA_SELFAM_IRE = 288,
	EXPIDONSA_VAUSMAGICA = 289,
	EXPIDONSA_PISTOLEER = 290,
	EXPIDONSA_DIVERSIONISTICO 	= 291,
	UNUSED_RUN3 				= 292,
	UNUSED_RUN1				= 293,
	EXPIDONSA_HEAVYPUNUEL		= 294,
	UNUSED_RUN2					= 295,
	EXPIDONSA_SEARGENTIDEAL		= 296,

	UNUSED_1			= 297,
	UNUSED_2			= 298,
	UNUSED_299	= 299,
	UNUSED_300	= 300,

	SEA_ALLY_SILVESTER		= 303,
	SEA_ALLY_GOGGLES		= 304,
	SEA_ALLY_DONNERKRIEG		= 305,
	SEA_ALLY_SCHWERTKRIEG		= 306,
	SEA_ALLY_GOD_ARKANTOS		= 307,
	VIP_BUILDING			= 308,
	EXPIDONSA_RIFALMANU 	= 309,
	EXPIDONSA_SICCERINO		= 310,
	EXPIDONSA_SOLDINE_PROTOTYPE		= 311,
	EXPIDONSA_SOLDINE				= 312,
	EXPIDONSA_PROTECTA				= 313,
	EXPIDONSA_SNIPONEER				= 314,
	EXPIDONSA_EGABUNAR				= 315,
	EXPIDONSA_ENEGAKAPUS			= 316,
	EXPIDONSA_CAPTINOAGENTUS		= 317,
	UNUSED_318		= 318,
	EXPIDONSA_DUALREA				= 319,
	EXPIDONSA_GUARDUS				= 320,
	EXPIDONSA_VAUSTECHICUS			= 321,
	EXPIDONSA_MINIGUNASSISA			= 322,
	EXPIDONSA_IGNITUS				= 323,
	EXPIDONSA_HELENA				= 324,

	EXPIDONSA_ERASUS				= 325,
	EXPIDONSA_GIANTTANKUS			= 326,
	EXPIDONSA_ANFUHREREISENHARD		= 327, //not as many gimmics as everything else has a million gimmics
	EXPIDONSA_SPEEDUSADIVUS			= 328,
	WEAPON_SENSAL_AFTERIMAGE		= 329,
	WEAPON_LEPER_AFTERIMAGE			= 330,
	OVERLORD_ROGUE					= 331,
	RAIDBOSS_BLADEDANCE 			= 332,
	UNUSED_RUN9					= 333,
	UNUSED_RUN5 					= 334,
	UNUSED_RUN4 					= 335,
	UNUSED_RUN7 					= 336,
	UNUSED_RUN6 					= 337,
	UNUSED_RUN8					= 338,
	UNUSED_RUN11					= 339,
	UNUSED_RUN12				= 340,
	UNUSED_RUN14			= 341,
	UNUSED_RUN13		= 342,
	MINI_BEHEADED_KAMI				= 343,
	
	BONEZONE_BEEFYBONES				= 344,
	BONEZONE_BRITTLEBONES			= 345,
	BONEZONE_BIGBONES				= 346,
	BONEZONE_BUFFED_BASICBONES		= 347,
	BONEZONE_BUFFED_BEEFYBONES		= 348,
	BONEZONE_BUFFED_BRITTLEBONES	= 349,
	BONEZONE_BUFFED_BIGBONES		= 350,
	//INTERITUS_DESERT_AHIM			= 351,
	INTERITUS_DESERT_INABDIL		= 352,
	INTERITUS_DESERT_KHAZAAN		= 353,
	INTERITUS_DESERT_SAKRATAN		= 354,
	INTERITUS_DESERT_YADEAM			= 355,
	INTERITUS_DESERT_RAJUL			= 356,
	INTERITUS_DESERT_QANAAS			= 357,
	INTERITUS_DESERT_ATILLA			= 358,
	INTERITUS_DESERT_ANCIENTDEMON	= 359,
	INTERITUS_WINTER_SNIPER			= 360,
	INTERITUS_WINTER_ZIBERIANMINER 	= 361,
	INTERITUS_WINTER_SNOWEY_GUNNER	= 362,
	INTERITUS_WINTER_FREEZING_CLEANER = 363,
	INTERITUS_WINTER_AIRBORN_EXPLORER = 364,
	INTERITUS_WINTER_ARCTIC_MAGE	  = 365,
	INTERITUS_WINTER_FROST_HUNTER	  = 366,
	INTERITUS_WINTER_SKIN_HUNTER	  = 367,
	INTERITUS_WINTER_IRRITATED_PERSON = 368,
	THEDOCTOR_MINIBOSS				  = 369,
  
	INTERITUS_ANARCHY_RANSACKER		  = 370,
  
	INTERITUS_FOREST_SNIPER = 371,
	INTERITUS_FOREST_SCOUT = 372,
	INTERITUS_FOREST_SOLDIER = 373,
	INTERITUS_FOREST_DEMOMAN = 374,

	INTERITUS_ANARCHY_RUNOVER		  = 375,
	INTERITUS_ANARCHY_HITMAN		  = 376,
	INTERITUS_ANARCHY_MADDOCTOR		  = 377,
	INTERITUS_ANARCHY_ABOMINATION	  = 378,
	INTERITUS_ANARCHY_ENFORCER	 	  = 379,
	INTERITUS_ANARCHY_BRAINDEAD	 	  = 380,
	INTERITUS_ANARCHY_BEHEMOTH		  = 381,
	INTERITUS_ANARCHY_ABSOLUTE_INCINIRATOR= 382,
  
	INTERITUS_FOREST_MEDIC 			= 383,
	INTERITUS_FOREST_HEAVY 			= 384,
	INTERITUS_FOREST_PYRO 			= 385,
	INTERITUS_FOREST_SPY 			= 386,
	INTERITUS_FOREST_ENGINEER 		= 387,
	INTERITUS_FOREST_BOSS 			= 388,
	RAIDMODE_THE_MESSENGER			= 389,
	RAIDMODE_CHAOS_KAHMLSTEIN 		= 390,
	RAIDBOSS_THE_PURGE 				= 391,
	WEAPON_KAHML_AFTERIMAGE			= 392,
	
	MAX_OLD_NPCS = 393	// DO NOT ADD MORE HERE, USE NEW METHOD
}

static const char NPC_Names[MAX_OLD_NPCS][] =
{
	"nothing",
	"",
	"",
	"",
	"",
	"",
	"",
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
	"",
	
	"Bloon",
	"Massive Ornery Air Blimp",
	"Brutal Floating Behemoth",
	"Zeppelin of Mighty Gargantuaness",
	"Dark Dirigible Titan",
	"Big Airship of Doom",
	
	
	"",
	"Sawrunner",
	"True Fusion Warrior",
	"",
	"",
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
	"nothing",
	"Pikeman",
	"",
	"Rebel",
	"Eagle Scout",
	"Samurai",
	"The Addiction",
	"The Doctor",
	"Book Simon",
	"",
	"L4D2 Tank",
	"",
	"",
	
	"Gold Bloon",
	"Bloonarius",
	"Gravelord Lych",
	"Lych-Soul",
	"Vortex",
	
	"Capped Ram",
	"",
	"",
	
	"Basic Bones",
	
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"Phantom Knight",
	"",
	
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
	
	"",
	"",
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
	"nothing",
	"",
	"Pental",
	"",
	"Selfam Ire",
	"Vaus Magica",
	"Pistoleer",
	"Diversionistico",
	"nothing",	//unused
	"nothing",	//unused
	"Heavy Punuel",
	"nothing",	//unused
	"Seargent Ideal",

	"nothing",
	"nothing",
	"",
	"",
	"?????????????",
	"Bob the First",
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"VIP Building, The Objective",
	"Rifal Manu",
	"Siccerino",
	"Soldine Prototype",
	"Soldine",
	"Protecta",
	"Sniponeer",
	"Ega Bunar",
	"Enega Kapus",
	"Captino Agentus",
	"Sensal",
	"Dual Rea",
	"Guardus",
	"Vaus Techicus",
	"Minigun Assisa",
	"Ignitus",
	"Helena",
	"Erasus",
	"Giant Tankus",
	"Anfuhrer Eisenhard",
	"Speedus Adivus",
	"Allied Sensal Afterimage",
	"Allied Leper Afterimage",
	"Overlord The Last",
	"Bladedance The Combine",
	"nothing",
	"nothing",
	"nothing",	//unused
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"nothing",
	"Beheaded Kamikaze",
	
	"Beefy Bones",
	"Brittle Bones",
	"Big Bones",
	"Buffed Basic Bones",
	"Buffed Beefy Bones",
	"Buffed Brittle Bones",
	"Buffed Big Bones",

	"Ahim",
	"Inabdil",
	"Khazaan",
	"Sakratan",
	"Yadeam",
	"Rajul",
	"Qanaas",
	"Atilla",
	"Ancient Demon",
	"Winter Sniper",
	"Ziberian Miner",
	"Snowey Gunner",
	"Freezing Cleaner",
	"Airborn Explorer",
	"Arctic Mage",
	"Frost Hunter",
	"Skin Hunter",
	"Irritated Person",
	"Rouge Expidonsan Doctor",
	"Ransacker",
	"Archosauria",
	"Aslan",
	"Perro",
	"Caprinae",
	"Runover",
	"Hitman",
	"Mad Doctor",
	"Abomination",
	"Anarchist Enforcer",
	"Braindead",
	"Behemonth",
	"Absolute Incinirator",

	"Liberi",
	"Ursus",
	"Aegir",
	"Cautus",
	"Vulpo",
	"Major Steam",
	"The Messenger",
	"Chaos Kahmlstein",
	"The Purge",
	"Kahmlstein"
};

// See items.sp for IDs to names
static const int NPCCategory[MAX_OLD_NPCS] =
{
	-1,	// NOTHING 						= 0,	
	3,	// HEADCRAB_ZOMBIE 				= 1,	
	3,	// FORTIFIED_HEADCRAB_ZOMBIE 		= 2,	
	3,	// FASTZOMBIE 						= 3,	
	3,	// FORTIFIED_FASTZOMBIE 			= 4,
	3,	// TORSOLESS_HEADCRAB_ZOMBIE 		= 5,	
	3,	// FORTIFIED_GIANT_POISON_ZOMBIE 	= 6,	
	3,	// POISON_ZOMBIE 					= 7,	
	3,	// FORTIFIED_POISON_ZOMBIE 		= 8,	
	3,	// FATHER_GRIGORI 					= 9,
	3,	// COMBINE_POLICE_PISTOL			= 10,	
	3,	// COMBINE_POLICE_SMG				= 11,	
	3,	// COMBINE_SOLDIER_AR2				= 12,
	3,	// COMBINE_SOLDIER_SHOTGUN			= 13,	
	3,	// COMBINE_SOLDIER_SWORDSMAN		= 14,
	3,	// COMBINE_SOLDIER_ELITE			= 15,
	3,	// COMBINE_SOLDIER_GIANT_SWORDSMAN	= 16,
	3,	// COMBINE_SOLDIER_DDT				= 17,
	3,	// COMBINE_SOLDIER_COLLOSS			= 18, //Hetimus
	3,	// COMBINE_OVERLORD				= 19, 
	3,	// SCOUT_ZOMBIE					= 20,
	3,	// ENGINEER_ZOMBIE					= 21,
	3,	// HEAVY_ZOMBIE					= 22,
	3,	// FLYINGARMOR_ZOMBIE				= 23,
	3,	// FLYINGARMOR_TINY_ZOMBIE			= 24,
	3,	// KAMIKAZE_DEMO					= 25,
	3,	// MEDIC_HEALER					= 26,
	3,	// HEAVY_ZOMBIE_GIANT				= 27,
	3,	// SPY_FACESTABBER					= 28,
	3,	// SOLDIER_ROCKET_ZOMBIE			= 29,
	3,	// SOLDIER_ZOMBIE_MINION			= 30,
	3,	// SOLDIER_ZOMBIE_BOSS				= 31,
	3,	// SPY_THIEF						= 32,
	3,	// SPY_TRICKSTABBER				= 33,
	3,	// SPY_HALF_CLOACKED				= 34,
	3,	// SNIPER_MAIN						= 35,
	3,	// DEMO_MAIN						= 36,
	3,	// BATTLE_MEDIC_MAIN				= 37,
	3,	// GIANT_PYRO_MAIN					= 38,
	3,	// COMBINE_DEUTSCH_RITTER			= 39,
	3,	// SPY_MAIN_BOSS					= 40,

	5,	// XENO_HEADCRAB_ZOMBIE 				= 41,	
	5,	// XENO_FORTIFIED_HEADCRAB_ZOMBIE 		= 42,	
	5,	// XENO_FASTZOMBIE 					= 43,	
	5,	// XENO_FORTIFIED_FASTZOMBIE 			= 44,
	5,	// XENO_TORSOLESS_HEADCRAB_ZOMBIE 		= 45,	
	5,	// XENO_FORTIFIED_GIANT_POISON_ZOMBIE 	= 46,	
	5,	// XENO_POISON_ZOMBIE 					= 47,	
	5,	// XENO_FORTIFIED_POISON_ZOMBIE 		= 48,	
	5,	// XENO_FATHER_GRIGORI 				= 49,
	5,	// XENO_COMBINE_POLICE_PISTOL			= 50,	
	5,	// XENO_COMBINE_POLICE_SMG				= 51,	
	5,	// XENO_COMBINE_SOLDIER_AR2			= 52,
	5,	// XENO_COMBINE_SOLDIER_SHOTGUN		= 53,	
	5,	// XENO_COMBINE_SOLDIER_SWORDSMAN		= 54,
	5,	// XENO_COMBINE_SOLDIER_ELITE			= 55,
	5,	// XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN	= 56,
	5,	// XENO_COMBINE_SOLDIER_DDT			= 57,
	5,	// XENO_COMBINE_SOLDIER_COLLOSS		= 58, //Hetimus
	5,	// XENO_COMBINE_OVERLORD				= 59, 
	5,	// XENO_SCOUT_ZOMBIE					= 60,
	5,	// XENO_ENGINEER_ZOMBIE				= 61,
	5,	// XENO_HEAVY_ZOMBIE					= 62,
	5,	// XENO_FLYINGARMOR_ZOMBIE				= 63,
	5,	// XENO_FLYINGARMOR_TINY_ZOMBIE		= 64,
	5,	// XENO_KAMIKAZE_DEMO					= 65,
	5,	// XENO_MEDIC_HEALER					= 66,
	5,	// XENO_HEAVY_ZOMBIE_GIANT				= 67,
	5,	// XENO_SPY_FACESTABBER				= 68,
	5,	// XENO_SOLDIER_ROCKET_ZOMBIE			= 69,
	5,	// XENO_SOLDIER_ZOMBIE_MINION			= 70,
	5,	// XENO_SOLDIER_ZOMBIE_BOSS			= 71,
	5,	// XENO_SPY_THIEF						= 72,
	5,	// XENO_SPY_TRICKSTABBER				= 73,
	5,	// XENO_SPY_HALF_CLOACKED				= 74,
	5,	// XENO_SNIPER_MAIN					= 75,
	5,	// XENO_DEMO_MAIN						= 76,
	5,	// XENO_BATTLE_MEDIC_MAIN				= 77,
	5,	// XENO_GIANT_PYRO_MAIN				= 78,
	5,	// XENO_COMBINE_DEUTSCH_RITTER			= 79,
	5,	// XENO_SPY_MAIN_BOSS					= 80,

	1,	// NAZI_PANZER							= 81,
	0,	// BOB_THE_GOD_OF_GODS					= 82,
	0,	// NECRO_COMBINE						= 83,
	0,	// NECRO_CALCIUM						= 84,
	0,	// CURED_FATHER_GRIGORI				= 85,

	-1,	// 					= 86,

	6,	// BTD_BLOON							= 87,
	6,	// BTD_MOAB							= 88,
	6,	// BTD_BFB								= 89,
	6,	// BTD_ZOMG							= 90,
	6,	// BTD_DDT								= 91,
	6,	// BTD_BAD								= 92,

	-1,	// 			= 93,
	1,	// SAWRUNNER							= 94,

	2,	// RAIDMODE_TRUE_FUSION_WARRIOR		= 95,
	-1,	// 					= 96,
	-1,	// 					= 97,

	7,	// MEDIVAL_MILITIA						= 98,
	7,	// MEDIVAL_ARCHER						= 99,
	7,	// MEDIVAL_MAN_AT_ARMS					= 100,
	7,	// MEDIVAL_SKIRMISHER					= 101,
	7,	// MEDIVAL_SWORDSMAN					= 102,
	7,	// MEDIVAL_TWOHANDED_SWORDSMAN			= 103,
	7,	// MEDIVAL_CROSSBOW_MAN				= 104,
	7,	// MEDIVAL_SPEARMEN					= 105,
	7,	// MEDIVAL_HANDCANNONEER				= 106,
	7,	// MEDIVAL_ELITE_SKIRMISHER			= 107,
	-1,	//					= 108,
	7,	// MEDIVAL_PIKEMAN						= 109,
	-1,	// 			= 110,
	0,	// CITIZEN								= 111,

	7,	// MEDIVAL_EAGLE_SCOUT					= 112,
	7,	// MEDIVAL_SAMURAI						= 113,

	8,	// THEADDICTION						= 114,
	8,	// THEDOCTOR							= 115,
	8,	// BOOKSIMON							= 116,
	-1,	// 						= 117,

	1,	// L4D2_TANK							= 118,
	-1,	// 			= 119,
	4,	// 				= 120,

	-1,	// BTD_GOLDBLOON	= 121,
	2,	// BTD_BLOONARIUS	= 122,
	-1,	// BTD_LYCH		= 123,
	-1,	// BTD_LYCHSOUL	= 124,
	-1,	// BTD_VORTEX	= 125,

	7,	// MEDIVAL_RAM	= 126,
	-1,	//  = 127,
	4,	//  = 128,

	0,	// BONEZONE_BASICBONES = 129,

	-1,	// 			= 130,
	-1,	// 				= 131,
	-1,	// 		= 132,
	-1,	// 			= 133,
	-1,	// 				= 134,
	-1,	// 				= 135,
	-1,	// 			= 136,
	1,	// PHANTOM_KNIGHT				= 137, //Lucian "Blood diamond"
	4,	// 			= 138, //3 being the 3rd stage of alt waves.

	-1,	// THE_GAMBLER				= 139,
	-1,	// PABLO_GONZALES				= 140,
	-1,	// DOKTOR_MEDICK				= 141,
	-1,	// KAPTAIN_HEAVY				= 142,
	-1,	// BOOTY_EXECUTIONIER 			= 143,
	-1,	// SANDVICH_SLAYER 			= 144,
	-1,	// PAYDAYCLOAKER				= 145,
	-1,	// BUNKER_KAHML_VTWO			= 146,
	-1,	// TRUE_ZEROFUSE				= 147,
	-1,	// BUNKER_BOT_SOLDIER			= 148,
	-1,	// BUNKER_BOT_SNIPER			= 149,
	-1,	// BUNKER_SKELETON				= 150,
	-1,	// BUNKER_SMALL_SKELETON		= 151,
	-1,	// BUNKER_KING_SKELETON		= 152,
	-1,	// BUNKER_HEADLESSHORSE		= 153,

	7,	// MEDIVAL_SCOUT				= 154,
	1,	// MEDIVAL_VILLAGER			= 155,
	1,	// MEDIVAL_BUILDING			= 156,
	7,	// MEDIVAL_CONSTRUCT			= 157,
	7,	// MEDIVAL_CHAMPION			= 158,
	7,	// MEDIVAL_LIGHT_CAV			= 159,
	7,	// MEDIVAL_HUSSAR				= 160,
	7,	// MEDIVAL_KNIGHT				= 161,
	7,	// MEDIVAL_OBUCH				= 162,
	7,	// MEDIVAL_MONK				= 163,

	7,	// BARRACK_MILITIA				= 164,
	7,	// BARRACK_ARCHER				= 165,
	7,	// BARRACK_MAN_AT_ARMS			= 166,

	7,	// MEDIVAL_HALB				= 167,
	7,	// MEDIVAL_BRAWLER				= 168,
	7,	// MEDIVAL_LONGBOWMEN			= 169,
	7,	// MEDIVAL_ARBALEST			= 170,
	7,	// MEDIVAL_ELITE_LONGBOWMEN	= 171,

	7,	// BARRACK_CROSSBOW			= 172,
	7,	// BARRACK_SWORDSMAN			= 173,
	7,	// BARRACK_ARBELAST			= 174,
	7,	// BARRACK_TWOHANDED			= 175,
	7,	// BARRACK_LONGBOW				= 176,
	7,	// BARRACK_CHAMPION			= 177,
	7,	// BARRACK_MONK				= 178,
	7,	// BARRACK_HUSSAR				= 179,

	7,	// MEDIVAL_CAVALARY			= 180,
	7,	// MEDIVAL_PALADIN				= 181,
	7,	// MEDIVAL_CROSSBOW_GIANT		= 182,
	7,	// MEDIVAL_SWORDSMAN_GIANT		= 183,
	7,	// MEDIVAL_RIDDENARCHER		= 184,
	7,	// MEDIVAL_EAGLE_WARRIOR		= 185,
	7,	// MEDIVAL_EAGLE_GIANT			= 186,
	7,	// MEDIVAL_SON_OF_OSIRIS		= 187,
	7,	// MEDIVAL_ACHILLES			= 188,
	7,	// MEDIVAL_TREBUCHET			= 189,

	-1,	// 				= 190,
	-1,	// 	= 191,
	0,	// NEARL_SWORD					= 192,

	1,	// STALKER_COMBINE		= 193,
	1,	// STALKER_FATHER		= 194,
	1,	// STALKER_GOGGLES		= 195,

	2,	// XENO_RAIDBOSS_SILVESTER		= 196,
	2,	// XENO_RAIDBOSS_BLUE_GOGGLES	= 197,
	2,	// XENO_RAIDBOSS_SUPERSILVESTER	= 198,
	2,	// XENO_RAIDBOSS_NEMESIS	= 199,

	9,	// SEARUNNER	= 200,
	9,	// SEARUNNER_ALT,
	9,	// SEASLIDER	= 202,
	9,	// SEASLIDER_ALT,
	9,	// SEASPITTER	= 204,
	9,	// SEASPITTER_ALT,
	9,	// SEAREAPER	= 206,
	9,	// SEAREAPER_ALT,
	9,	// SEACRAWLER	= 208,
	9,	// SEACRAWLER_ALT,
	9,	// SEAPIERCER	= 210,
	9,	// SEAPIERCER_ALT,
	9,	// FIRSTTOTALK	= 212,
	9,	// UNDERTIDES	= 213,
	9,	// SEABORN_KAZIMIERZ_KNIGHT	= 214,
	9,	// SEABORN_KAZIMIERZ_KNIGHT_ARCHER	= 215,
	9,	// SEABORN_KAZIMIERZ_BESERKER	= 216,
	9,	// SEABORN_KAZIMIERZ_LONGARCHER	= 217,
	9,	// REMAINS		= 218,
	9,	// ENDSPEAKER_1	= 219,
	-1,	// ENDSPEAKER_2	= 220,
	-1,	// ENDSPEAKER_3	= 221,
	-1,	// ENDSPEAKER_4	= 222,
	9,	// SEAFOUNDER	= 223,
	9,	// SEAFOUNDER_ALT,
	9,	// SEAFOUNDER_CARRIER,
	9,	// SEAPREDATOR	= 226,
	9,	// SEAPREDATOR_ALT,
	9,	// SEAPREDATOR_CARRIER,
	9,	// SEABRANDGUIDER	= 229,
	9,	// SEABRANDGUIDER_ALT,
	9,	// SEABRANDGUIDER_CARRIER,
	9,	// SEABORN_KAZIMIERZ_ASSASIN_MELEE	= 232,
	9,	// SEASPEWER	= 233,
	9,	// SEASPEWER_ALT,
	9,	// SEASPEWER_CARRIER,
	9,	// SEASWARMCALLER	= 236,
	9,	// SEASWARMCALLER_ALT,
	9,	// SEASWARMCALLER_CARRIER,
	9,	// SEAREEFBREAKER	= 239,
	9,	// SEAREEFBREAKER_ALT,
	9,	// SEAREEFBREAKER_CARRIER,
	0,	// BARRACK_THORNS	= 242,
	2,	// RAIDMODE_GOD_ARKANTOS = 243,
	9,	// SEABORN_SCOUT		= 244,
	9,	// SEABORN_SOLDIER		= 245,
	0,	// CITIZEN_RUNNER		= 246,
	9,	// SEABORN_PYRO		= 247,
	9,	// SEABORN_DEMO		= 248,
	9,	// SEABORN_HEAVY		= 249,
	9,	// SEABORN_ENGINEER	= 250,
	9,	// SEABORN_MEDIC		= 251,
	9,	// SEABORN_SNIPER		= 252,
	9,	// SEABORN_SPY		= 253,
	0,	// ALT_BARRACKS_SCHWERTKRIEG = 254,
	0,	// ALT_BARRACK_IKUNAGAE = 255,
	0,	// ALT_BARRACK_RAILGUNNER = 256,
	0,	// ALT_BARRACK_BASIC_MAGE = 257,
	0,	// ALT_BARRACK_INTERMEDIATE_MAGE = 258,
	0,	// ALT_BARRACK_DONNERKRIEG = 259,
	0,	// ALT_BARRACKS_HOLY_KNIGHT = 260,
	0,	// ALT_BARRACK_MECHA_BARRAGER = 261,
	0,	// ALT_BARRACK_BARRAGER = 262,
	0,	// ALT_BARRACKS_BERSERKER = 263,
	0,	// ALT_BARRACKS_CROSSBOW_MEDIC = 264,
	9,	// LASTKNIGHT		= 265,
	0,	// BARRACK_LASTKNIGHT	= 266,
	9,	// SAINTCARMEN		= 267,
	9,	// PATHSHAPER		= 268,
	9,	// PATHSHAPER_FRACTAL	= 269,
	0,	// BARRACKS_TEUTONIC_KNIGHT	= 270,
	0,	// BARRACKS_VILLAGER			= 271,
	0,	// BARRACKS_BUILDING			= 272,
	9,	// TIDELINKED_BISHOP	= 273,
	9,	// TIDELINKED_ARCHON	= 274,
	0,	// ALT_BARRACK_SCIENTIFIC_WITCHERY = 275,
	9,	// SEABORN_GUARD		= 276,
	9,	// SEABORN_DEFENDER	= 277,
	9,	// SEABORN_VANGUARD	= 278,
	9,	// SEABORN_CASTER		= 279,
	9,	// SEABORN_SPECIALIST	= 280,
	9,	// SEABORN_SUPPORTER	= 281,
	9,	// ISHARMLA		= 282,
	-1,	// ISHARMLA_TRANS		= 283,

	-1,	//  = 284,
	-1,	//  = 285,
	10,	// EXPIDONSA_PENTAL = 286,
	-1,	//  = 287,
	10,	// EXPIDONSA_SELFAM_IRE = 288,
	10,	// EXPIDONSA_VAUSMAGICA = 289,
	10,	// EXPIDONSA_PISTOLEER = 290,
	10,	// EXPIDONSA_DIVERSIONISTICO 	= 291,
	-1,	// unused 				= 292,
	-1,	// unused
	10,	// EXPIDONSA_HEAVYPUNUEL		= 294,
	-1,	// unused
	10,	// EXPIDONSA_SEARGENTIDEAL		= 296,

	-1,	// 		= 297,
	-1,	// 		= 298,
	-1,	// 	= 299,
	-1,	// 	= 300,
	-1,	// BOB_THE_FIRST		= 301,
	-1,	// BOB_THE_FIRST_S		= 302,
	-1,	// 		= 303,
	-1,	// 		= 304,
	-1,	// 		= 305,
	-1,	// 		= 306,
	-1,	// 		= 307,
	0,	// VIP_BUILDING			= 308
	10,	// EXPIDONSA_RIFALMANU		= 309,
	10,	// EXPIDONSA_SICCERINO			= 310,
	10,	// EXPIDONSA_SOLDINE_PROTOTYPE			= 311,
	10,	// EXPIDONSA_SOLDINE					= 312,
	10,	// EXPIDONSA_PROTECTA					= 313,
	10,	// EXPIDONSA_SNIPONEER					= 314,
	10,	// EXPIDONSA_EGABUNAR					= 315,
	10,	// EXPIDONSA_ENEGAKAPUS					= 316,
	10, // EXPIDONSA_CAPTINOAGENTUS				= 317,
	-1, // UNUSED_318							= 318,
	10, // EXPIDONSA_DUALREA					= 319,
	10, // EXPIDONSA_GUARDUS					= 320,
	10, // EXPIDONSA_VAUSTECHICUS				= 321,
	10,	// EXPIDONSA_MINIGUNASSISA				= 322
	10,	// EXPIDONSA_IGNITUS				= 323,
	10,	// EXPIDONSA_HELENA				= 324,

	10,	// EXPIDONSA_ERASUS				= 325,
	10,	// EXPIDONSA_GIANTTANKUS			= 326,
	10,	// EXPIDONSA_ANFUHREREISENHARD		= 327,
	10, //EXPIDONSA_SPEEDUSADIVUS			= 328,
	0, 	//WEAPON_SENSAL_AFTERIMAGE			= 329 
	-1,	// OVERLORD_ROGUE
	-1,	// RAIDBOSS_BLADEDANCE
	-1,	//
	-1,	//
	-1,	//unused
	-1,	//
	-1,	//
	-1,	//
	-1,	//
	-1,	//
	-1,	//
	-1,	//
	1,	// MINI_BEHEADED_KAMI

	-1,	// BONEZONE_BEEFYBONES
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,	// BONEZONE_BUFFED_BIGBONES

	-1,	//INTERITUS_DESERT_AHIM_UNSUED			= 351,
	11,	//	INTERITUS_DESERT_INABDIL		= 352,
	11,	//	INTERITUS_DESERT_KHAZAAN		= 353,
	11,	//	INTERITUS_DESERT_SAKRATAN		= 354,
	11,	//	INTERITUS_DESERT_YADEAM			= 355,
	11,	//	INTERITUS_DESERT_RAJUL			= 356,
	11,	//	INTERITUS_DESERT_QANAAS			= 357,
	11,	//	INTERITUS_DESERT_ATILLA			= 358,
	11,	//	INTERITUS_DESERT_ANCIENTDEMON	= 359,
	11,	//	INTERITUS_WINTER_SNIPER			= 360,
	11,	//	INTERITUS_WINTER_ZIBERIANMINER 	= 361,
	11,	//	INTERITUS_WINTER_SNOWEY_GUNNER	= 362,
	11,	//	INTERITUS_WINTER_FREEZING_CLEANER = 363,
	11,	//	INTERITUS_WINTER_AIRBORN_EXPLORER = 364,
	11,	//	INTERITUS_WINTER_ARCTIC_MAGE	  = 365,
	11,	//	INTERITUS_WINTER_FROST_HUNTER	  = 366,
	11,	//	INTERITUS_WINTER_SKIN_HUNTER	  = 367,
	11,	//	INTERITUS_WINTER_IRRITATED_PERSON = 368,
	1,	//	THEDOCTOR_MINIBOSS				  = 369,
  
	11,	//	INTERITUS_ANARCHY_RANSACKER		  = 370,
  
	11,	//	INTERITUS_FOREST_SNIPER = 371,
	11,	//	INTERITUS_FOREST_SCOUT = 372,
	11,	//	INTERITUS_FOREST_SOLDIER = 373,
	11,	//	INTERITUS_FOREST_DEMOMAN = 374,

	11,	//	INTERITUS_ANARCHY_RUNOVER		  = 375,
	11,	//	INTERITUS_ANARCHY_HITMAN		  = 376,
	11,	//	INTERITUS_ANARCHY_MADDOCTOR		  = 377,
	11,	//	INTERITUS_ANARCHY_ABOMINATION	  = 378,
	11,	//	INTERITUS_ANARCHY_ENFORCER	 	  = 379,
	11,	//	INTERITUS_ANARCHY_BRAINDEAD	 	  = 380,
	11,	//	INTERITUS_ANARCHY_BEHEMOTH		  = 381,
	11,	//	INTERITUS_ANARCHY_ABSOLUTE_INCINIRATOR= 382,
  
	11,	//	INTERITUS_FOREST_MEDIC = 383,
	11,	//	INTERITUS_FOREST_HEAVY = 384,
	11,	//	INTERITUS_FOREST_PYRO = 385,
	11,	//	INTERITUS_FOREST_SPY = 386,
	11,	//	INTERITUS_FOREST_ENGINEER = 387,
	11,	//	INTERITUS_FOREST_BOSS = 388,
	2,	//	RAIDMODE_THE_MESSENGER	= 389,
	2,	//	RAIDMODE_CHAOS_KAHMLSTEIN = 390,
	2,	//	RAIDBOSS_THE_PURGE = 391,
	-1, // WEAPON_KAHML_AFTERIMAGE = 392,
};

static const char NPC_Plugin_Names_Converted[MAX_OLD_NPCS][] =
{
	"npc_nothing",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	
	//XENO
	
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	
	"npc_panzer",
	"npc_bob_the_overlord",
	"npc_necromancy_combine",
	"npc_necromancy_calcium",
	"npc_cured_last_survivor",
	
	"",
	
	"npc_bloon",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_sawrunner",
	"npc_true_fusion_warrior",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_medival_pikeman",
	"",
	"npc_citizen",
	"npc_medival_eagle_scout",
	"npc_medival_samurai",
	"npc_addiction",
	"npc_doctor_city",
	"npc_simon",
	"",
	"npc_l4d2_tank",
	"",
	"",
	"npc_golden_bloon",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	
	"npc_basicbones",
	
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_phantom_knight",
	"",			//3 being the 3rd stage of alt waves.
	
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
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",

	"",
	"",
	"",

	"",
	"",
	"",
	"",
	"",

	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",

	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",

	"npc_stalker_combine",
	"npc_stalker_father",
	"npc_stalker_goggles",

	"",
	"npc_xeno_raidboss_blue_goggles",
	"",
	"npc_xeno_raidboss_nemesis",

	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_god_arkantos",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	
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

	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",	//Scientific Witchery
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	
	"",
	"",
	"npc_pental",
	"",	//unused
	"npc_selfam_ire",
	"npc_vaus_magica",
	"npc_benera_pistoleer",
	"npc_diversionistico",
	"",	//unused
	"",	//unused
	"npc_heavy_punuel",
	"",	//unused
	"npc_seargent_ideal",
	
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_vip_building",
	"npc_rifal_manu",
	"npc_siccerino",
	"npc_soldine_prototype",
	"npc_soldine",
	"npc_protecta",
	"npc_sniponeer",
	"npc_ega_bunar",
	"npc_enegakapus",
	//wave 30+:
	"npc_captino_agentus",
	"", //Raid
	"npc_dualrea",
	"npc_guardus",
	"npc_vaus_techicus",
	"npc_minigun_assisa",
	"npc_ignitus",
	"npc_helena",
	//wave 45+:
	"npc_erasus",
	"npc_gianttankus",
	"npc_anfuhrer_eisenhard",
	"npc_speedus_adivus",
	"",
	"",
	"npc_overlord_rogue",
	"npc_bladedance",
	"",
	"",
	"",	//unused
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"npc_beheaded_kami",
	
	"npc_beefybones",
	"npc_brittlebones",
	"npc_bigbones",
	"npc_basicbones",
	"npc_beefybones",
	"npc_brittlebones",
	"npc_bigbones",
	"",
	"npc_inabdil",
	"npc_khazaan",
	"npc_sakratan",
	"npc_yadeam",
	"npc_rajul",
	"npc_qanaas",
	"npc_atilla",
	"npc_ancient_demon",
	"npc_winter_sniper",
	"npc_ziberian_miner",
	"npc_snowey_gunner",
	"npc_freezing_cleaner",
	"npc_airborn_explorer",
	"npc_arctic_mage",
	"npc_frost_hunter",
	"npc_skin_hunter",
	"npc_irritated_person",
	"npc_doctor_special",
	"npc_ransacker",
	"npc_archosauria",
	"npc_aslan",
	"npc_perro",
	"npc_caprinae",
	"npc_runover",
	"npc_hitman",
	"npc_mad_doctor",
	"npc_abomination",
	"npc_enforcer",
	"npc_braindead",
	"npc_behemoth",
	"npc_absolute_incinirator",

	"npc_liberi",
	"npc_ursus",
	"npc_aegir",
	"npc_cautus",
	"npc_vulpo",
	"npc_majorsteam",
	"npc_the_messenger",
	"npc_chaos_kahmlstein",
	"npc_the_purge",
	"npc_allied_kahml"
};

void GetOldMethodNPCs()
{
	NPCData data;
	for(int i = 1; i < MAX_OLD_NPCS; i++)
	{
		strcopy(data.Name, sizeof(data.Name), NPC_Names[i]);
		strcopy(data.Plugin, sizeof(data.Plugin), NPC_Plugin_Names_Converted[i]);
		data.Category = NPCCategory[i];
		data.Func = INVALID_FUNCTION;
		NPCList.PushArray(data);
	}
}

stock int NPC_CreateByName(const char[] name, int client, float vecPos[3], float vecAng[3], int team, const char[] data = "")
{
	static NPCData npcdata;
	int id = NPC_GetByPlugin(name, npcdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid NPC or is using old method!", name);
		return -1;
	}

	return CreateNPC(npcdata, id, client, vecPos, vecAng, team, data);
}

int NPC_CreateById(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], int team, const char[] data = "")
{
	if(Index_Of_Npc < 1 || Index_Of_Npc >= NPCList.Length)
	{
		PrintToChatAll("[%d] is not a valid NPC!", Index_Of_Npc);
		return -1;
	}

	static NPCData npcdata;
	NPC_GetById(Index_Of_Npc, npcdata);
	return CreateNPC(npcdata, Index_Of_Npc, client, vecPos, vecAng, team, data);
}

static int CreateNPC(const NPCData npcdata, int id, int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	any entity = -1;

	switch(id)
	{
		case HEADCRAB_ZOMBIE:
			entity = HeadcrabZombie(client, vecPos, vecAng, team);
		
		case FORTIFIED_HEADCRAB_ZOMBIE:
			entity = FortifiedHeadcrabZombie(client, vecPos, vecAng, team);
		
		case FASTZOMBIE:
			entity = FastZombie(client, vecPos, vecAng, team);
		
		case FORTIFIED_FASTZOMBIE:
			entity = FortifiedFastZombie(client, vecPos, vecAng, team);
		
		case TORSOLESS_HEADCRAB_ZOMBIE:
			entity = TorsolessHeadcrabZombie(client, vecPos, vecAng, team);
		
		case FORTIFIED_GIANT_POISON_ZOMBIE:
			entity = FortifiedGiantPoisonZombie(client, vecPos, vecAng, team);
		
		case POISON_ZOMBIE:
			entity = PoisonZombie(client, vecPos, vecAng, team);
		
		case FORTIFIED_POISON_ZOMBIE:
			entity = FortifiedPoisonZombie(client, vecPos, vecAng, team);
		
		case FATHER_GRIGORI:
			entity = FatherGrigori(client, vecPos, vecAng, team);
		
		case COMBINE_POLICE_PISTOL:
			entity = Combine_Police_Pistol(client, vecPos, vecAng, team);
		
		case COMBINE_POLICE_SMG:
			entity = CombinePoliceSmg(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_AR2:
			entity = CombineSoldierAr2(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_SHOTGUN:
			entity = CombineSoldierShotgun(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_SWORDSMAN:
			entity = CombineSwordsman(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_ELITE:
			entity = CombineElite(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
			entity = CombineGaint(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_DDT:
			entity = CombineDDT(client, vecPos, vecAng, team);
		
		case COMBINE_SOLDIER_COLLOSS:
			entity = CombineCollos(client, vecPos, vecAng, team);
		
		case COMBINE_OVERLORD:
			entity = CombineOverlord(client, vecPos, vecAng, team);
		
		case SCOUT_ZOMBIE:
			entity = Scout(client, vecPos, vecAng, team);
		
		case ENGINEER_ZOMBIE:
			entity = Engineer(client, vecPos, vecAng, team);
		
		case HEAVY_ZOMBIE:
			entity = Heavy(client, vecPos, vecAng, team);
		
		case FLYINGARMOR_ZOMBIE:
			entity = FlyingArmor(client, vecPos, vecAng, team);
		
		case FLYINGARMOR_TINY_ZOMBIE:
			entity = FlyingArmorTiny(client, vecPos, vecAng, team);
		
		case KAMIKAZE_DEMO:
			entity = Kamikaze(client, vecPos, vecAng, team);
		
		case MEDIC_HEALER:
			entity = MedicHealer(client, vecPos, vecAng, team);
		
		case HEAVY_ZOMBIE_GIANT:
			entity = HeavyGiant(client, vecPos, vecAng, team);
		
		case SPY_FACESTABBER:
			entity = Spy(client, vecPos, vecAng, team);
		
		case SOLDIER_ROCKET_ZOMBIE:
			entity = Soldier(client, vecPos, vecAng, team);
		
		case SOLDIER_ZOMBIE_MINION:
			entity = SoldierMinion(client, vecPos, vecAng, team);
		
		case SOLDIER_ZOMBIE_BOSS:
			entity = SoldierGiant(client, vecPos, vecAng, team);
		
		case SPY_THIEF:
			entity = SpyThief(client, vecPos, vecAng, team);
		
		case SPY_TRICKSTABBER:
			entity = SpyTrickstabber(client, vecPos, vecAng, team);
		
		case SPY_HALF_CLOACKED:
			entity = SpyCloaked(client, vecPos, vecAng, team);
		
		case SNIPER_MAIN:
			entity = SniperMain(client, vecPos, vecAng, team);
		
		case DEMO_MAIN:
			entity = DemoMain(client, vecPos, vecAng, team);
		
		case BATTLE_MEDIC_MAIN:
			entity = MedicMain(client, vecPos, vecAng, team);
		
		case GIANT_PYRO_MAIN:
			entity = PyroGiant(client, vecPos, vecAng, team);
		
		case COMBINE_DEUTSCH_RITTER:
			entity = CombineDeutsch(client, vecPos, vecAng, team);
		
		case SPY_MAIN_BOSS:
			entity = SpyMainBoss(client, vecPos, vecAng, team);
		
		case XENO_HEADCRAB_ZOMBIE:
			entity = XenoHeadcrabZombie(client, vecPos, vecAng, team);
		
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
			entity = XenoFortifiedHeadcrabZombie(client, vecPos, vecAng, team);
		
		case XENO_FASTZOMBIE:
			entity = XenoFastZombie(client, vecPos, vecAng, team);
		
		case XENO_FORTIFIED_FASTZOMBIE:
			entity = XenoFortifiedFastZombie(client, vecPos, vecAng, team);
		
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
			entity = XenoTorsolessHeadcrabZombie(client, vecPos, vecAng, team);
		
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
			entity = XenoFortifiedGiantPoisonZombie(client, vecPos, vecAng, team);
		
		case XENO_POISON_ZOMBIE:
			entity = XenoPoisonZombie(client, vecPos, vecAng, team);
		
		case XENO_FORTIFIED_POISON_ZOMBIE:
			entity = XenoFortifiedPoisonZombie(client, vecPos, vecAng, team);
		
		case XENO_FATHER_GRIGORI:
			entity = XenoFatherGrigori(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_POLICE_PISTOL:
			entity = XenoCombinePolicePistol(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_POLICE_SMG:
			entity = XenoCombinePoliceSmg(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_AR2:
			entity = XenoCombineSoldierAr2(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_SHOTGUN:
			entity = XenoCombineSoldierShotgun(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
			entity = XenoCombineSwordsman(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_ELITE:
			entity = XenoCombineElite(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
			entity = XenoCombineGaint(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_DDT:
			entity = XenoCombineDDT(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_SOLDIER_COLLOSS:
			entity = XenoCombineCollos(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_OVERLORD:
			entity = XenoCombineOverlord(client, vecPos, vecAng, team);
		
		case XENO_SCOUT_ZOMBIE:
			entity = XenoScout(client, vecPos, vecAng, team);
		
		case XENO_ENGINEER_ZOMBIE:
			entity = XenoEngineer(client, vecPos, vecAng, team);
		
		case XENO_HEAVY_ZOMBIE:
			entity = XenoHeavy(client, vecPos, vecAng, team);
		
		case XENO_FLYINGARMOR_ZOMBIE:
			entity = XenoFlyingArmor(client, vecPos, vecAng, team);
		
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
			entity = XenoFlyingArmorTiny(client, vecPos, vecAng, team);
		
		case XENO_KAMIKAZE_DEMO:
			entity = XenoKamikaze(client, vecPos, vecAng, team);
		
		case XENO_MEDIC_HEALER:
			entity = XenoMedicHealer(client, vecPos, vecAng, team);
		
		case XENO_HEAVY_ZOMBIE_GIANT:
			entity = XenoHeavyGiant(client, vecPos, vecAng, team);
		
		case XENO_SPY_FACESTABBER:
			entity = XenoSpy(client, vecPos, vecAng, team);
		
		case XENO_SOLDIER_ROCKET_ZOMBIE:
			entity = XenoSoldier(client, vecPos, vecAng, team);
		
		case XENO_SOLDIER_ZOMBIE_MINION:
			entity = XenoSoldierMinion(client, vecPos, vecAng, team);
		
		case XENO_SOLDIER_ZOMBIE_BOSS:
			entity = XenoSoldierGiant(client, vecPos, vecAng, team);
		
		case XENO_SPY_THIEF:
			entity = XenoSpyThief(client, vecPos, vecAng, team);
		
		case XENO_SPY_TRICKSTABBER:
			entity = XenoSpyTrickstabber(client, vecPos, vecAng, team);
		
		case XENO_SPY_HALF_CLOACKED:
			entity = XenoSpyCloaked(client, vecPos, vecAng, team);
		
		case XENO_SNIPER_MAIN:
			entity = XenoSniperMain(client, vecPos, vecAng, team);
		
		case XENO_DEMO_MAIN:
			entity = XenoDemoMain(client, vecPos, vecAng, team);
		
		case XENO_BATTLE_MEDIC_MAIN:
			entity = XenoMedicMain(client, vecPos, vecAng, team);
		
		case XENO_GIANT_PYRO_MAIN:
			entity = XenoPyroGiant(client, vecPos, vecAng, team);
		
		case XENO_COMBINE_DEUTSCH_RITTER:
			entity = XenoCombineDeutsch(client, vecPos, vecAng, team);
		
		case XENO_SPY_MAIN_BOSS:
			entity = XenoSpyMainBoss(client, vecPos, vecAng, team);
		
		case NAZI_PANZER:
			entity = NaziPanzer(client, vecPos, vecAng, team);
		
		case BOB_THE_GOD_OF_GODS:
			entity = BobTheGod(client, vecPos, vecAng, team);
		
		case NECRO_COMBINE:
			entity = NecroCombine(client, vecPos, vecAng, StringToFloat(data));
		
		case NECRO_CALCIUM:
			entity = NecroCalcium(client, vecPos, vecAng, StringToFloat(data));
		
		case CURED_FATHER_GRIGORI:
			entity = CuredFatherGrigori(client, vecPos, vecAng, team);
		
		case BTD_BLOON:
			entity = Bloon(client, vecPos, vecAng, team, data);
		
		case BTD_MOAB:
			entity = Moab(client, vecPos, vecAng, team, data);
		
		case BTD_BFB:
			entity = BFB(client, vecPos, vecAng, team, data);
		
		case BTD_ZOMG:
			entity = Zomg(client, vecPos, vecAng, team, data);
		
		case BTD_DDT:
			entity = DDT(client, vecPos, vecAng, team, data);
		
		case BTD_BAD:
			entity = Bad(client, vecPos, vecAng, team, data);
		
		case SAWRUNNER:
			entity = SawRunner(client, vecPos, vecAng, team);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			entity = TrueFusionWarrior(client, vecPos, vecAng, team, data);
		
		case MEDIVAL_MILITIA:
			entity = MedivalMilitia(client, vecPos, vecAng, team);
		
		case MEDIVAL_ARCHER:
			entity = MedivalArcher(client, vecPos, vecAng, team);
		
		case MEDIVAL_MAN_AT_ARMS:
			entity = MedivalManAtArms(client, vecPos, vecAng, team);
		
		case MEDIVAL_SKIRMISHER:
			entity = MedivalSkirmisher(client, vecPos, vecAng, team);
		
		case MEDIVAL_SWORDSMAN:
			entity = MedivalSwordsman(client, vecPos, vecAng, team);
		
		case MEDIVAL_TWOHANDED_SWORDSMAN:
			entity = MedivalTwoHandedSwordsman(client, vecPos, vecAng, team);
		
		case MEDIVAL_CROSSBOW_MAN:
			entity = MedivalCrossbowMan(client, vecPos, vecAng, team);
		
		case MEDIVAL_SPEARMEN:
			entity = MedivalSpearMan(client, vecPos, vecAng, team);
		
		case MEDIVAL_HANDCANNONEER:
			entity = MedivalHandCannoneer(client, vecPos, vecAng, team);
		
		case MEDIVAL_ELITE_SKIRMISHER:
			entity = MedivalEliteSkirmisher(client, vecPos, vecAng, team);
		
		case MEDIVAL_PIKEMAN:
			entity = MedivalPikeman(client, vecPos, vecAng, team);
		
		case CITIZEN:
			entity = Citizen(client, vecPos, vecAng, data);
		
		case MEDIVAL_EAGLE_SCOUT:
			entity = MedivalEagleScout(client, vecPos, vecAng, team);
		
		case MEDIVAL_SAMURAI:
			entity = MedivalSamurai(client, vecPos, vecAng, team);
		
		case THEADDICTION:
			entity = Addicition(client, vecPos, vecAng, team, data);
		
		case THEDOCTOR:
			entity = Doctor(client, vecPos, vecAng, team, data);
		
		case BOOKSIMON:
			entity = Simon(client, vecPos, vecAng, team, data);
		
		
		case L4D2_TANK:
			entity = L4D2_Tank(client, vecPos, vecAng, team);
		
		
		case BTD_BLOONARIUS:
			entity = Bloonarius(client, vecPos, vecAng, team, data);
		
		case MEDIVAL_RAM:
			entity = MedivalRam(client, vecPos, vecAng, team, data);
		
		case BONEZONE_BASICBONES:
			entity = BasicBones(client, vecPos, vecAng, team, false);
			
		case BONEZONE_BEEFYBONES:
			entity = BeefyBones(client, vecPos, vecAng, team, false);
			
		case BONEZONE_BRITTLEBONES:
			entity = BrittleBones(client, vecPos, vecAng, team, false);
			
		case BONEZONE_BIGBONES:
			entity = BigBones(client, vecPos, vecAng, team, false);
			
		case BONEZONE_BUFFED_BASICBONES:
			entity = BasicBones(client, vecPos, vecAng, team, true);
			
		case BONEZONE_BUFFED_BEEFYBONES:
			entity = BeefyBones(client, vecPos, vecAng, team, true);
			
		case BONEZONE_BUFFED_BRITTLEBONES:
			entity = BrittleBones(client, vecPos, vecAng, team, true);
			
		case BONEZONE_BUFFED_BIGBONES:
			entity = BigBones(client, vecPos, vecAng, team, true);
		
		case PHANTOM_KNIGHT:
			entity = PhantomKnight(client, vecPos, vecAng, team);	
		
		case MINI_BEHEADED_KAMI:
			entity = BeheadedKamiKaze(client, vecPos, vecAng, team);		
		/*
		case THE_GAMBLER:
			entity = TheGambler(client, vecPos, vecAng, team);
		
		case PABLO_GONZALES:
			entity = Pablo_Gonzales(client, vecPos, vecAng, team);
		
		case DOKTOR_MEDICK:
			entity = Doktor_Medick(client, vecPos, vecAng, team);
		
		case KAPTAIN_HEAVY:
			entity = Eternal_Kaptain_Heavy(client, vecPos, vecAng, team);
		
		case BOOTY_EXECUTIONIER:
			entity = BootyExecutioner(client, vecPos, vecAng, team);
		
		case SANDVICH_SLAYER:
			entity = SandvichSlayer(client, vecPos, vecAng, team);
		
		case PAYDAYCLOAKER:
			entity = Payday_Cloaker(client, vecPos, vecAng, team);
		
		case BUNKER_KAHML_VTWO:
			entity = BunkerKahml(client, vecPos, vecAng, team);
		
		case TRUE_ZEROFUSE:
			entity = TrueZerofuse(client, vecPos, vecAng, team);
		
		case BUNKER_BOT_SOLDIER:
			entity = BunkerBotSoldier(client, vecPos, vecAng, team);
		
		case BUNKER_BOT_SNIPER:
			entity = BunkerBotSniper(client, vecPos, vecAng, team);
		
		case BUNKER_SKELETON:
			entity = BunkerSkeleton(client, vecPos, vecAng, team);
		
		case BUNKER_SMALL_SKELETON:
			entity = BunkerSkeletonKing(client, vecPos, vecAng, team);
		
		case BUNKER_KING_SKELETON:
			entity = BunkerSkeletonKing(client, vecPos, vecAng, team);
		
		case BUNKER_HEADLESSHORSE:
			entity = BunkerHeadlessHorse(client, vecPos, vecAng, team);
		*/
		case MEDIVAL_SCOUT:
			entity = MedivalScout(client, vecPos, vecAng, team);
		
		case MEDIVAL_VILLAGER:
			entity = MedivalVillager(client, vecPos, vecAng, team);
		
		case MEDIVAL_BUILDING:
			entity = MedivalBuilding(client, vecPos, vecAng, team, data);
		
		case MEDIVAL_CONSTRUCT:
			entity = MedivalConstruct(client, vecPos, vecAng, team);
		
		case MEDIVAL_CHAMPION:
			entity = MedivalChampion(client, vecPos, vecAng, team);
		
		case MEDIVAL_LIGHT_CAV:
			entity = MedivalLightCav(client, vecPos, vecAng, team);
		
		case MEDIVAL_HUSSAR:
			entity = MedivalHussar(client, vecPos, vecAng, team);
		
		case MEDIVAL_KNIGHT:
			entity = MedivalKnight(client, vecPos, vecAng, team);
		
		case MEDIVAL_OBUCH:
			entity = MedivalObuch(client, vecPos, vecAng, team);
		
		case MEDIVAL_MONK:
			entity = MedivalMonk(client, vecPos, vecAng, team);
		
		case BARRACK_MILITIA:
			entity = BarrackMilitia(client, vecPos, vecAng, team);
		
		case BARRACK_ARCHER:
			entity = BarrackArcher(client, vecPos, vecAng, team);
		
		case BARRACK_MAN_AT_ARMS:
			entity = BarrackManAtArms(client, vecPos, vecAng, team);
		
		case MEDIVAL_HALB:
			entity = MedivalHalb(client, vecPos, vecAng, team);
		
		case MEDIVAL_BRAWLER:
			entity = MedivalBrawler(client, vecPos, vecAng, team);
		
		case MEDIVAL_LONGBOWMEN:
			entity = MedivalLongbowmen(client, vecPos, vecAng, team);
		
		case MEDIVAL_ARBALEST:
			entity = MedivalArbalest(client, vecPos, vecAng, team);
		
		case MEDIVAL_ELITE_LONGBOWMEN:
			entity = MedivalEliteLongbowmen(client, vecPos, vecAng, team);
		
		case BARRACK_CROSSBOW:
			entity = BarrackCrossbow(client, vecPos, vecAng, team);
		
		case BARRACK_SWORDSMAN:
			entity = BarrackSwordsman(client, vecPos, vecAng, team);
		
		case BARRACK_ARBELAST:
			entity = BarrackArbelast(client, vecPos, vecAng, team);
		
		case BARRACK_TWOHANDED:
			entity = BarrackTwoHanded(client, vecPos, vecAng, team);
		
		case BARRACK_LONGBOW:
			entity = BarrackLongbow(client, vecPos, vecAng, team);
		
		case BARRACK_CHAMPION:
			entity = BarrackChampion(client, vecPos, vecAng, team);
		
		case BARRACK_MONK:
			entity = BarrackMonk(client, vecPos, vecAng, team);
		
		case BARRACK_HUSSAR:
			entity = BarrackHussar(client, vecPos, vecAng, team);
		
		case MEDIVAL_CAVALARY:
			entity = MedivalCavalary(client, vecPos, vecAng, team);
		
		case MEDIVAL_PALADIN:
			entity = MedivalPaladin(client, vecPos, vecAng, team);
		
		case MEDIVAL_CROSSBOW_GIANT:
			entity = MedivalCrossbowGiant(client, vecPos, vecAng, team);
		
		case MEDIVAL_SWORDSMAN_GIANT:
			entity = MedivalSwordsmanGiant(client, vecPos, vecAng, team);
		
		case MEDIVAL_EAGLE_WARRIOR:
			entity = MedivalEagleWarrior(client, vecPos, vecAng, team);
		
		case MEDIVAL_RIDDENARCHER:
			entity = MedivalRiddenArcher(client, vecPos, vecAng, team);
		
		case MEDIVAL_EAGLE_GIANT:
			entity = MedivalEagleGiant(client, vecPos, vecAng, team);
		
		case MEDIVAL_SON_OF_OSIRIS:
			entity = MedivalSonOfOsiris(client, vecPos, vecAng, team);
		
		case MEDIVAL_ACHILLES:
			entity = MedivalAchilles(client, vecPos, vecAng, team);
		
		case MEDIVAL_TREBUCHET:
			entity = MedivalTrebuchet(client, vecPos, vecAng, team);
		
		
		case NEARL_SWORD:
			entity = NearlSwordAbility(client, vecPos, vecAng, team);
		
		case STALKER_COMBINE:
			entity = StalkerCombine(client, vecPos, vecAng, team);
		
		case STALKER_FATHER:
			entity = StalkerFather(client, vecPos, vecAng, team);
		
		case STALKER_GOGGLES:
			entity = StalkerGoggles(client, vecPos, vecAng, team);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			entity = RaidbossBlueGoggles(client, vecPos, vecAng, team, data);
		
		case XENO_RAIDBOSS_NEMESIS:
			entity = RaidbossNemesis(client, vecPos, vecAng, team, data);
		
		case BARRACK_THORNS:
			entity = BarrackThorns(client, vecPos, vecAng, team);
		
		case RAIDMODE_GOD_ARKANTOS:
			entity = GodArkantos(client, vecPos, vecAng, team, data);
		
		case ALT_BARRACKS_SCHWERTKRIEG:
			entity = Barrack_Alt_Shwertkrieg(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_IKUNAGAE:
			entity = Barrack_Alt_Ikunagae(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_RAILGUNNER:
			entity = Barrack_Alt_Raigunner(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_BASIC_MAGE:
			entity = Barrack_Alt_Basic_Mage(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_INTERMEDIATE_MAGE:
			entity = Barrack_Alt_Intermediate_Mage(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_DONNERKRIEG:
			entity = Barrack_Alt_Donnerkrieg(client, vecPos, vecAng, team);

		case ALT_BARRACKS_HOLY_KNIGHT:
			entity = Barrack_Alt_Holy_Knight(client, vecPos, vecAng, team);
		
		case ALT_BARRACK_MECHA_BARRAGER:
			entity = Barrack_Alt_Mecha_Barrager(client, vecPos, vecAng, team);
			
		case ALT_BARRACK_BARRAGER:
			entity = Barrack_Alt_Barrager(client, vecPos, vecAng, team);
			
		case ALT_BARRACKS_BERSERKER:
			entity = Barrack_Alt_Berserker(client, vecPos, vecAng, team);
			
		case ALT_BARRACKS_CROSSBOW_MEDIC:
			entity = Barrack_Alt_Crossbowmedic(client, vecPos, vecAng, team);
		
		case BARRACK_LASTKNIGHT:
			entity = BarrackLastKnight(client, vecPos, vecAng, team);
		
		case BARRACKS_TEUTONIC_KNIGHT:
			entity = BarrackTeuton(client, vecPos, vecAng, team);

		case BARRACKS_VILLAGER:
			entity = BarrackVillager(client, vecPos, vecAng, team);

		case BARRACKS_BUILDING:
			entity = BarrackBuilding(client, vecPos, vecAng, team);

		case ALT_BARRACK_SCIENTIFIC_WITCHERY:
			entity = Barrack_Alt_Scientific_Witchery(client, vecPos, vecAng, team);
		
		case EXPIDONSA_PENTAL:
			entity = Pental(client, vecPos, vecAng, team);

		case EXPIDONSA_SELFAM_IRE:
			entity = SelfamIre(client, vecPos, vecAng, team);

		case EXPIDONSA_VAUSMAGICA:
			entity = VausMagica(client, vecPos, vecAng, team);

		case EXPIDONSA_PISTOLEER:
			entity = Pistoleer(client, vecPos, vecAng, team);

		case EXPIDONSA_DIVERSIONISTICO:
			entity = Diversionistico(client, vecPos, vecAng, team, data);

		case EXPIDONSA_HEAVYPUNUEL:
			entity = HeavyPunuel(client, vecPos, vecAng, team);

		case EXPIDONSA_SEARGENTIDEAL:
			entity = SeargentIdeal(client, vecPos, vecAng, team, data);
		
		case VIP_BUILDING:
			entity = VIPBuilding(client, vecPos, vecAng, data);

		case EXPIDONSA_RIFALMANU:
			entity = RifalManu(client, vecPos, vecAng, team);

		case EXPIDONSA_SICCERINO:
			entity = Siccerino(client, vecPos, vecAng, team);

		case EXPIDONSA_SOLDINE_PROTOTYPE:
			entity = SoldinePrototype(client, vecPos, vecAng, team);

		case EXPIDONSA_SOLDINE:
			entity = Soldine(client, vecPos, vecAng, team);
			
		case EXPIDONSA_PROTECTA:
			entity = Protecta(client, vecPos, vecAng, team);

		case EXPIDONSA_SNIPONEER:
			entity = Sniponeer(client, vecPos, vecAng, team);

		case EXPIDONSA_EGABUNAR:
			entity = EgaBunar(client, vecPos, vecAng, team);

		case EXPIDONSA_ENEGAKAPUS:
			entity = EnegaKapus(client, vecPos, vecAng, team);

		case EXPIDONSA_CAPTINOAGENTUS:
			entity = CaptinoAgentus(client, vecPos, vecAng, team, data);

		case EXPIDONSA_DUALREA:
			entity = DualRea(client, vecPos, vecAng, team);

		case EXPIDONSA_GUARDUS:
			entity = Guardus(client, vecPos, vecAng, team);

		case EXPIDONSA_VAUSTECHICUS:
			entity = VausTechicus(client, vecPos, vecAng, team);

		case EXPIDONSA_MINIGUNASSISA:
			entity = MinigunAssisa(client, vecPos, vecAng, team);

		case EXPIDONSA_IGNITUS:
			entity = Ignitus(client, vecPos, vecAng, team);

		case EXPIDONSA_HELENA:
			entity = Helena(client, vecPos, vecAng, team);

		case EXPIDONSA_ERASUS:
			entity = Erasus(client, vecPos, vecAng, team);

		case EXPIDONSA_GIANTTANKUS:
			entity = GiantTankus(client, vecPos, vecAng, team);

		case EXPIDONSA_ANFUHREREISENHARD:
			entity = AnfuhrerEisenhard(client, vecPos, vecAng, team);

		case EXPIDONSA_SPEEDUSADIVUS:
			entity = SpeedusAdivus(client, vecPos, vecAng, team);

		case WEAPON_SENSAL_AFTERIMAGE:
			entity = AlliedSensalAbility(client, vecPos, vecAng, team);

		case WEAPON_LEPER_AFTERIMAGE:
			entity = AlliedLeperVisualiserAbility(client, vecPos, vecAng, team, data);

		case OVERLORD_ROGUE:
			entity = OverlordRogue(client, vecPos, vecAng, team, data);

		case RAIDBOSS_BLADEDANCE:
			entity = RaidbossBladedance(client, vecPos, vecAng, team, data);

		case INTERITUS_DESERT_INABDIL:
			entity = DesertInabdil(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_KHAZAAN:
			entity = DesertKhazaan(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_SAKRATAN:
			entity = DesertSakratan(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_YADEAM:
			entity = DesertYadeam(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_RAJUL:
			entity = DesertRajul(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_QANAAS:
			entity = DesertQanaas(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_ATILLA:
			entity = DesertAtilla(client, vecPos, vecAng, team);

		case INTERITUS_DESERT_ANCIENTDEMON:
			entity = DesertAncientDemon(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_SNIPER:
			entity = WinterSniper(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_ZIBERIANMINER:
			entity = WinterZiberianMiner(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_SNOWEY_GUNNER:
			entity = WinterSnoweyGunner(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_FREEZING_CLEANER:
			entity = WinterFreezingCleaner(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_AIRBORN_EXPLORER:
			entity = WinterAirbornExplorer(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_ARCTIC_MAGE:
			entity = WinterArcticMage(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_FROST_HUNTER:
			entity = WinterFrostHunter(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_SKIN_HUNTER:
			entity = WinterSkinHunter(client, vecPos, vecAng, team);

		case INTERITUS_WINTER_IRRITATED_PERSON:
			entity = WinterIrritatedPerson(client, vecPos, vecAng, team);

		case THEDOCTOR_MINIBOSS:
			entity = SpecialDoctor(client, vecPos, vecAng, team,data);
     
		case INTERITUS_ANARCHY_RANSACKER:
			entity = AnarchyRansacker(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_RUNOVER:
			entity = AnarchyRunover(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_HITMAN:
			entity = AnarchyHitman(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_MADDOCTOR:
			entity = AnarchyMadDoctor(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_ABOMINATION:
			entity = AnarchyAbomination(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_ENFORCER:
			entity = AnarchyEnforcer(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_BRAINDEAD:
			entity = AnarchyBraindead(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_BEHEMOTH:
			entity = AnarchyBehemoth(client, vecPos, vecAng, team);

		case INTERITUS_ANARCHY_ABSOLUTE_INCINIRATOR:
			entity = AnarchyAbsoluteIncinirator(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_SNIPER:
			entity = Archosauria(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_SCOUT:
			entity = Aslan(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_SOLDIER:
			entity = Perro(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_DEMOMAN:
			entity = Caprinae(client, vecPos, vecAng, team, data);

		case INTERITUS_FOREST_MEDIC:
			entity = Liberi(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_HEAVY:
			entity = Ursus(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_PYRO:
			entity = Aegir(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_SPY:
			entity = Cautus(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_ENGINEER:
			entity = Vulpo(client, vecPos, vecAng, team);

		case INTERITUS_FOREST_BOSS:
			entity = MajorSteam(client, vecPos, vecAng, team);
			
		case RAIDMODE_THE_MESSENGER:
			entity = TheMessenger(client, vecPos, vecAng, team, data);

		case RAIDMODE_CHAOS_KAHMLSTEIN:
			entity = ChaosKahmlstein(client, vecPos, vecAng, team, data);
		
		case RAIDBOSS_THE_PURGE:
			entity = ThePurge(client, vecPos, vecAng, team);
			
		case WEAPON_KAHML_AFTERIMAGE:
			entity = AlliedKahmlAbility(client, vecPos, vecAng, team);

		default:
		{
			Call_StartFunction(null, npcdata.Func);
			Call_PushCell(client);
			Call_PushArrayEx(vecPos, sizeof(vecPos), 0);
			Call_PushArrayEx(vecAng, sizeof(vecAng), 0);
			Call_PushCell(team);
			Call_PushString(data);
			Call_Finish(entity);
		}
		
	}
	
	if(entity != -1)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), npcdata.Name);
		
		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
		
		if(GetTeam(entity) == 2)
		{
			Rogue_AllySpawned(entity);
		}
		else
		{
			Rogue_EnemySpawned(entity);
		}

		Waves_UpdateMvMStats();
	}

	return entity;
}

void ZR_NpcTauntWinClear()
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			func_NPCFuncWin[baseboss_index] = INVALID_FUNCTION;
		}
	}
}

void ZR_NpcTauntWin()
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			Function func = func_NPCFuncWin[baseboss_index];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(baseboss_index);
				Call_Finish();
			}
			func_NPCFuncWin[baseboss_index] = INVALID_FUNCTION;
		}
	}
}

void NPCDeath(int entity)
{
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
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			Function func = func_NPCDeathForward[baseboss_index];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(baseboss_index);
				Call_PushCell(entity);
				Call_Finish();
				//todo: convert all on death and on take damage to this.
			}
		}
	}
	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
		return;
		//todo: convert all on death and on take damage to this.
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
		
		
		case SAWRUNNER:
			SawRunner_NPCDeath(entity);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			TrueFusionWarrior_NPCDeath(entity);
		
		
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
		
		case MEDIVAL_PIKEMAN:
			MedivalPikeman_NPCDeath(entity);
		
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
		
		
		case L4D2_TANK:
			L4D2_Tank_NPCDeath(entity);

		
		case BTD_BLOONARIUS:
			Bloonarius_NPCDeath(entity);
		
		case MEDIVAL_RAM:
			MedivalRam_NPCDeath(entity);

		
		case BONEZONE_BASICBONES:
			BasicBones_NPCDeath(entity);
			
		case BONEZONE_BEEFYBONES:
			BeefyBones_NPCDeath(entity);
			
		case BONEZONE_BRITTLEBONES:
			BrittleBones_NPCDeath(entity);
			
		case BONEZONE_BIGBONES:
			BigBones_NPCDeath(entity);
			
		case BONEZONE_BUFFED_BASICBONES:
			BasicBones_NPCDeath(entity);
			
		case BONEZONE_BUFFED_BEEFYBONES:
			BeefyBones_NPCDeath(entity);
			
		case BONEZONE_BUFFED_BRITTLEBONES:
			BrittleBones_NPCDeath(entity);
			
		case BONEZONE_BUFFED_BIGBONES:
			BigBones_NPCDeath(entity);
		
		
		case PHANTOM_KNIGHT:
			PhantomKnight_NPCDeath(entity);

		case MINI_BEHEADED_KAMI:
			BeheadedKamiKaze_NPCDeath(entity);

		/*
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
		*/
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
		
		case NEARL_SWORD:
			NearlSwordAbility_NPCDeath(entity);
		
		case STALKER_COMBINE:
			StalkerCombine_NPCDeath(entity);
		
		case STALKER_FATHER:
			StalkerFather_NPCDeath(entity);
		
		case STALKER_GOGGLES:
			StalkerGoggles_NPCDeath(entity);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			RaidbossBlueGoggles_NPCDeath(entity);
		
		case XENO_RAIDBOSS_NEMESIS:
			RaidbossNemesis_NPCDeath(entity);
		
		case BARRACK_THORNS:
			BarrackThorns_NPCDeath(entity);

		case RAIDMODE_GOD_ARKANTOS:
			GodArkantos_NPCDeath(entity);

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
		
		case BARRACK_LASTKNIGHT:
			BarrackLastKnight_NPCDeath(entity);
		
		case BARRACKS_TEUTONIC_KNIGHT:
			BarrackTeuton_NPCDeath(entity);

		case BARRACKS_VILLAGER:
			BarrackVillager_NPCDeath(entity);

		case BARRACKS_BUILDING:
			BarrackBuilding_NPCDeath(entity);
		
		case ALT_BARRACK_SCIENTIFIC_WITCHERY:
			Barrack_Alt_Scientific_Witchery_NPCDeath(entity);
		
		case EXPIDONSA_PENTAL:
			Pental_NPCDeath(entity);


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
		
		case VIP_BUILDING:
			VIPBuilding_NPCDeath(entity);

		case EXPIDONSA_RIFALMANU:
			RifalManu_NPCDeath(entity);

		case EXPIDONSA_SICCERINO:
			Siccerino_NPCDeath(entity);

		case EXPIDONSA_SOLDINE_PROTOTYPE:
			SoldinePrototype_NPCDeath(entity);

		case EXPIDONSA_SOLDINE:
			Soldine_NPCDeath(entity);

		case EXPIDONSA_PROTECTA:
			Protecta_NPCDeath(entity);

		case EXPIDONSA_SNIPONEER:
			Sniponeer_NPCDeath(entity);

		case EXPIDONSA_EGABUNAR:
			EgaBunar_NPCDeath(entity);

		case EXPIDONSA_ENEGAKAPUS:
			EnegaKapus_NPCDeath(entity);

		case EXPIDONSA_CAPTINOAGENTUS:
			CaptinoAgentus_NPCDeath(entity);

		case EXPIDONSA_DUALREA:
			DualRea_NPCDeath(entity);

		case EXPIDONSA_GUARDUS:
			Guardus_NPCDeath(entity);

		case EXPIDONSA_VAUSTECHICUS:
			VausTechicus_NPCDeath(entity);

		case EXPIDONSA_MINIGUNASSISA:
			MinigunAssisa_NPCDeath(entity);

		case EXPIDONSA_IGNITUS:
			Ignitus_NPCDeath(entity);

		case EXPIDONSA_HELENA:
			Helena_NPCDeath(entity);

		case EXPIDONSA_ERASUS:
			Erasus_NPCDeath(entity);

		case EXPIDONSA_GIANTTANKUS:
			GiantTankus_NPCDeath(entity);

		case EXPIDONSA_ANFUHREREISENHARD:
			AnfuhrerEisenhard_NPCDeath(entity);

		case EXPIDONSA_SPEEDUSADIVUS:
			SpeedusAdivus_NPCDeath(entity);

		case WEAPON_SENSAL_AFTERIMAGE:
			AlliedSensalAbility_NPCDeath(entity);

		case WEAPON_LEPER_AFTERIMAGE:
			AlliedLeperVisualiserAbility_NPCDeath(entity);

		case OVERLORD_ROGUE:
			OverlordRogue_NPCDeath(entity);
		
		case RAIDBOSS_BLADEDANCE:
			RaidbossBladedance_NPCDeath(entity);

		//default:
		//	PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		
	}

}

Action NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Function func = func_NPCOnTakeDamage[victim];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArray(damageForce, sizeof(damageForce));
		Call_PushArray(damagePosition, sizeof(damagePosition));
		Call_PushCell(damagecustom);
		Call_Finish();
		return Plugin_Changed;
		//todo: convert all on death and on take damage to this.
	}

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
		
		
		case SAWRUNNER:
			SawRunner_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case RAIDMODE_TRUE_FUSION_WARRIOR:
			TrueFusionWarrior_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
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
		
		case MEDIVAL_PIKEMAN:
			MedivalPikeman_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		
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
		
		case L4D2_TANK:
			L4D2_Tank_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		

	//	case BTD_BLOONARIUS:
	//		Bloonarius_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//	case MEDIVAL_RAM:
	//		MedivalRam_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		

		
		case BONEZONE_BASICBONES:
			BasicBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BEEFYBONES:
			BeefyBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BRITTLEBONES:
			BrittleBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BIGBONES:
			BigBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BUFFED_BASICBONES:
			BasicBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BUFFED_BEEFYBONES:
			BeefyBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BUFFED_BRITTLEBONES:
			BrittleBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case BONEZONE_BUFFED_BIGBONES:
			BigBones_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case PHANTOM_KNIGHT:
			PhantomKnight_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case MINI_BEHEADED_KAMI:
			BeheadedKamiKaze_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		/*
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
		*/
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


		case NEARL_SWORD:
			NearlSwordAbility_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_COMBINE:
			StalkerCombine_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_FATHER:
			StalkerFather_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case STALKER_GOGGLES:
			StalkerGoggles_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_BLUE_GOGGLES:
			RaidbossBlueGoggles_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case XENO_RAIDBOSS_NEMESIS:
			RaidbossNemesis_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		case BARRACK_THORNS:
			BarrackBody_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case RAIDMODE_GOD_ARKANTOS:
			GodArkantos_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_PENTAL:
			Pental_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
/*
		case EXPIDONSA_SELFAM_IRE:
			Selfamire_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_VAUSMAGICA:
			Vausmagica_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
*/
		case EXPIDONSA_PISTOLEER:
			Pistoleer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_DIVERSIONISTICO:
			Diversionistico_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_HEAVYPUNUEL:
			HeavyPunuel_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SEARGENTIDEAL:
			SeargentIdeal_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case EXPIDONSA_RIFALMANU:
			RifalManu_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case VIP_BUILDING:
			VIPBuilding_OnTakeDamagePost(victim, attacker);

		case EXPIDONSA_SICCERINO:
			Siccerino_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SOLDINE_PROTOTYPE:
			SoldinePrototype_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SOLDINE:
			Soldine_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case EXPIDONSA_PROTECTA:
			Protecta_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SNIPONEER:
			Sniponeer_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_EGABUNAR:
			EgaBunar_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_ENEGAKAPUS:
			EnegaKapus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_CAPTINOAGENTUS:
			CaptinoAgentus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_DUALREA:
			DualRea_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_GUARDUS:
			Guardus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_VAUSTECHICUS:
			VausTechicus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_MINIGUNASSISA:
			MinigunAssisa_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
		case EXPIDONSA_IGNITUS:
			Ignitus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_HELENA:
			Helena_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_ERASUS:
			Erasus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_GIANTTANKUS:
			GiantTankus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_ANFUHREREISENHARD:
			AnfuhrerEisenhard_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case EXPIDONSA_SPEEDUSADIVUS:
			SpeedusAdivus_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case OVERLORD_ROGUE:
			OverlordRogue_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

		case RAIDBOSS_BLADEDANCE:
			RaidbossBladedance_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	return Plugin_Changed;
}

//BASES FOR ENEMIES

#include "zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"
#include "zombie_riot/npc/seaborn/npc_nethersea_shared.sp"

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
#include "zombie_riot/npc/special/npc_phantom_knight.sp"
#include "zombie_riot/npc/special/npc_beheaded_kamikaze.sp"
#include "zombie_riot/npc/special/npc_doctor.sp"

#include "zombie_riot/npc/btd/npc_bloon.sp"
#include "zombie_riot/npc/btd/npc_moab.sp"
#include "zombie_riot/npc/btd/npc_bfb.sp"
#include "zombie_riot/npc/btd/npc_zomg.sp"
#include "zombie_riot/npc/btd/npc_ddt.sp"
#include "zombie_riot/npc/btd/npc_bad.sp"
#include "zombie_riot/npc/btd/npc_bloonarius.sp"

#include "zombie_riot/npc/ally/npc_bob_the_overlord.sp"
#include "zombie_riot/npc/ally/npc_necromancy_combine.sp"
#include "zombie_riot/npc/ally/npc_necromancy_calcium.sp"
#include "zombie_riot/npc/ally/npc_cured_last_survivor.sp"
#include "zombie_riot/npc/ally/npc_citizen.sp"
#include "zombie_riot/npc/ally/npc_allied_sensal_afterimage.sp"
#include "zombie_riot/npc/ally/npc_allied_leper_visualiser.sp"
#include "zombie_riot/npc/ally/npc_allied_kahml_afterimage.sp"

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
#include "zombie_riot/npc/ruina/stage1/npc_ruina_stella.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_astria.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_aether.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_europa.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_drone.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_ruriana.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_daedalus.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_malius.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_laz.sp"

//Stage 2
#include "zombie_riot/npc/ruina/stage2/npc_ruina_laniun.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_magnium.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_stellaria.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_astriana.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_europis.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_draedon.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_aetheria.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_maliana.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_ruianus.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_lazius.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_dronian.sp"



//Special Ruina
#include "zombie_riot/npc/ruina/special/npc_ruina_valiant.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_magia_anchor.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_storm_weaver.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_storm_weaver_mid.sp"

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
#include "zombie_riot/npc/bonezone/npc_beefybones.sp"
#include "zombie_riot/npc/bonezone/npc_brittlebones.sp"
#include "zombie_riot/npc/bonezone/npc_bigbones.sp"

/*
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
*/
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

#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_donnerkrieg.sp"
#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_schwertkrieg.sp"
#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_bob_the_first_last_savior.sp"

#include "zombie_riot/npc/expidonsa/npc_benera.sp"
#include "zombie_riot/npc/expidonsa/npc_pental.sp"
#include "zombie_riot/npc/expidonsa/npc_defanda.sp"
#include "zombie_riot/npc/expidonsa/npc_selfam_ire.sp"
#include "zombie_riot/npc/expidonsa/npc_vaus_magica.sp"
#include "zombie_riot/npc/expidonsa/npc_benera_pistoleer.sp"
#include "zombie_riot/npc/expidonsa/npc_diversionistico.sp"
#include "zombie_riot/npc/expidonsa/npc_heavy_punuel.sp"
#include "zombie_riot/npc/expidonsa/npc_seargent_ideal.sp"
#include "zombie_riot/npc/expidonsa/npc_rifal_manu.sp"
#include "zombie_riot/npc/expidonsa/npc_siccerino.sp"
#include "zombie_riot/npc/expidonsa/npc_soldine_prototype.sp"
#include "zombie_riot/npc/expidonsa/npc_soldine.sp"
#include "zombie_riot/npc/expidonsa/npc_sniponeer.sp"
#include "zombie_riot/npc/expidonsa/npc_enegakapus.sp"
#include "zombie_riot/npc/expidonsa/npc_ega_bunar.sp"
#include "zombie_riot/npc/expidonsa/npc_protecta.sp"

#include "zombie_riot/npc/expidonsa/npc_captino_agentus.sp"
#include "zombie_riot/npc/expidonsa/npc_dualrea.sp"
#include "zombie_riot/npc/expidonsa/npc_guardus.sp"
#include "zombie_riot/npc/expidonsa/npc_vaus_techicus.sp"
#include "zombie_riot/npc/expidonsa/npc_minigun_assisa.sp"
#include "zombie_riot/npc/expidonsa/npc_erasus.sp"
#include "zombie_riot/npc/expidonsa/npc_gianttankus.sp"
#include "zombie_riot/npc/expidonsa/npc_helena.sp"
#include "zombie_riot/npc/expidonsa/npc_ignitus.sp"
#include "zombie_riot/npc/expidonsa/npc_speedus_adivus.sp"
#include "zombie_riot/npc/expidonsa/npc_anfuhrer_eisenhard.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_sensal.sp"

#include "zombie_riot/npc/ally/npc_vip_building.sp"
#include "zombie_riot/npc/rogue/npc_overlord_rogue.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_bladedance.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_the_messenger.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_chaos_kahmlstein.sp"

#include "zombie_riot/npc/raidmode_bosses/npc_the_purge.sp"

#include "zombie_riot/npc/interitus/desert/npc_ahim.sp"
#include "zombie_riot/npc/interitus/desert/npc_inabdil.sp"
#include "zombie_riot/npc/interitus/desert/npc_khazaan.sp"
#include "zombie_riot/npc/interitus/desert/npc_sakratan.sp"
#include "zombie_riot/npc/interitus/desert/npc_yadeam.sp"
#include "zombie_riot/npc/interitus/desert/npc_rajul.sp"
#include "zombie_riot/npc/interitus/desert/npc_qanaas.sp"
#include "zombie_riot/npc/interitus/desert/npc_atilla.sp"
#include "zombie_riot/npc/interitus/desert/npc_ancient_demon.sp"

#include "zombie_riot/npc/interitus/winter/npc_winter_sniper.sp"
#include "zombie_riot/npc/interitus/winter/npc_ziberian_miner.sp"
#include "zombie_riot/npc/interitus/winter/npc_snowey_gunner.sp"
#include "zombie_riot/npc/interitus/winter/npc_freezing_cleaner.sp"
#include "zombie_riot/npc/interitus/winter/npc_airborn_explorer.sp"
#include "zombie_riot/npc/interitus/winter/npc_arctic_mage.sp"
#include "zombie_riot/npc/interitus/winter/npc_skin_hunter.sp"
#include "zombie_riot/npc/interitus/winter/npc_frost_hunter.sp"
#include "zombie_riot/npc/interitus/winter/npc_irritated_person.sp"

#include "zombie_riot/npc/interitus/anarchy/npc_ransacker.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_runover.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_hitman.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_mad_doctor.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_abomination.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_enforcer.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_braindead.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_behemoth.sp"
#include "zombie_riot/npc/interitus/anarchy/npc_absolute_incinirator.sp"

#include "zombie_riot/npc/interitus/forest/npc_archosauria.sp"
#include "zombie_riot/npc/interitus/forest/npc_aslan.sp"
#include "zombie_riot/npc/interitus/forest/npc_perro.sp"
#include "zombie_riot/npc/interitus/forest/npc_caprinae.sp"
#include "zombie_riot/npc/interitus/forest/npc_liberi.sp"
#include "zombie_riot/npc/interitus/forest/npc_ursus.sp"
#include "zombie_riot/npc/interitus/forest/npc_aegir.sp"
#include "zombie_riot/npc/interitus/forest/npc_cautus.sp"
#include "zombie_riot/npc/interitus/forest/npc_vulpo.sp"
#include "zombie_riot/npc/interitus/forest/npc_majorsteam.sp"
