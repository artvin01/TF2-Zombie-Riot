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
static float f_FactionCreditGainReduction[MAXPLAYERS];

static ArrayList NPCList;

/*
int SaveCurrentHpAt = -1;
int SaveCurrentHpAtFirst = -1;
int SaveCurrentHurtAt = -1;
int HurtIttirationAt = 0;
float AntiChatSpamDebug;
*/
enum struct NPCData
{
	char Plugin[64];
	char Name[64];
	int Category;
	Function Func;
	int Flags;
	char Icon[32];
	bool IconCustom;
	Function Precache;
	Function Precache_data;
	Function WikiFunc;

	// Don't touch below
	bool Precached;
}

// FileNetwork_ConfigSetup needs to be ran first
void NPC_ConfigSetup()
{
//	AntiChatSpamDebug = 0.0;
	f_FactionCreditGain = 0.0;
	Zero(f_FactionCreditGainReduction);

	Building_ConfigSetup();

	delete NPCList;
	NPCList = new ArrayList(sizeof(NPCData));

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nothing");
	data.Category = Type_Hidden;
	data.Func = INVALID_FUNCTION;
	strcopy(data.Icon, sizeof(data.Icon), "duck");
	NPCList.PushArray(data);

	HeadcrabZombie_OnMapStart_NPC();
	Fortified_HeadcrabZombie_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	FortifiedFastZombie_OnMapStart_NPC();
	TorsolessHeadcrabZombie_OnMapStart_NPC();
	FortifiedGiantPoisonZombie_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	FortifiedPoisonZombie_OnMapStart_NPC();
	FatherGrigori_OnMapStart_NPC();

	// Buildings
	ObjectBarricade_MapStart();
	ObjectDecorative_MapStart();
	ObjectAmmobox_MapStart();
	ObjectArmorTable_MapStart();
	ObjectPerkMachine_MapStart();
	ObjectPackAPunch_MapStart();
	ObjectHealingStation_MapStart();
	ObjectTinkerAnvil_MapStart();
	ObjectSentrygun_MapStart();
	ObjectMortar_MapStart();
	ObjectRailgun_MapStart();
	ObjectBarracks_MapStart();
	ObjectVillage_MapStart();
	ObjectTinkerBrew_MapStart();
	ObjectRevenant_Setup();
	ObjectTinkerGrill_MapStart();
	ObjectVintulumBomb_MapStart();
	// Buildings

	// Constructs
	ObjectResearch_MapStart();
	ObjectWall_MapStart();
	
	ObjectPump_MapStart();
	ObjectWood_MapStart();
	ObjectStone_MapStart();
	ObjectSupply_MapStart();
	ObjectStove_MapStart();
	ObjectFactory_MapStart();
	ObjectMinter_MapStart();

	ObjectConstruction_LightHouse_MapStart();
	ObjectHeavyCaliberTurret_MapStart();
	Object_MinigunTurret_MapStart();
	Object_TeslarsMedusa_MapStart();
	ObjectStunGun_MapStart();
	ObjectDispenser_MapStart();
	ObjectFurniture_MapStart();
	ObjectHelper_MapStart();
	ObjectVoidstone_MapStart();
	
	ObjectDWall_MapStart();
	ObjectDungeonCenter_MapStart();
	ObjectGemCrafter_MapStart();
	ObjectDStove_MapStart();

	ObjectDLightHouse_MapStart();
	ObjectDCaliberTurret_MapStart();
	ObjectDMinigunTurret_MapStart();
	ObjectDTeslarsMedusa_MapStart();
	ObjectDStunGun_MapStart();
	ObjectDDispenser_MapStart();
	// Constructs

	// Vehicles
	VehicleHL2_Setup();
	VehicleFullJeep_Setup();
	VehicleAmbulance_Setup();
//	VehicleBus_Setup(); This vehicle is too big.
	VehicleCamper_Setup();
	VehicleDumpTruck_Setup();
	VehicleLandrover_Setup();
	VehiclePickup_Setup();
	// Vehicles
	
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
	XenoInfectedLabDoctor_OnMapStart_NPC();
	XenoSoldier_OnMapStart_NPC();
	XenoSoldierMinion_OnMapStart_NPC();
	XenoSoldierGiant_OnMapStart_NPC();
	XenoMedicHealer_OnMapStart_NPC();
	
	
	
	XenoSpyThief_OnMapStart_NPC();
	XenoSpyTrickstabber_OnMapStart_NPC();
	XenoSpyCloaked_OnMapStart_NPC();
	XenoSniperMain_OnMapStart_NPC();
	XenoDemoMain_OnMapStart_NPC();
	XenoMedicMain_OnMapStart_NPC();
	XenoPyroGiant_OnMapStart_NPC();
	XenoCombineDeutsch_OnMapStart_NPC();
	XenoSpyMainBoss_OnMapStart_NPC();


	XenoAcclaimedSwordsman_OnMapStart_NPC();
	XenoFortifiedEarlyZombie_OnMapStart_NPC();
	XenoPatientFew_OnMapStart_NPC();
	XenoOuroborosEkas_OnMapStart_NPC();

	
	WanderingSpirit_OnMapStart_NPC();
	VengefullSpirit_OnMapStart_NPC();
	BobTheGod_OnMapStart_NPC();
	NecroCombine_OnMapStart_NPC();
	NecroCalcium_OnMapStart_NPC();
	CuredFatherGrigori_OnMapStart_NPC();
	FallenWarrior_OnMapStart();
	ThirtySixFifty_OnMapStart();
	JohnTheAllmighty_OnMapStart_NPC();
	RavagingIntellect_OnMapStart();
	
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
	AltCombineMage_OnMapStart_NPC();
	
	L4D2_Tank_OnMapStart_NPC();
	MedivalRam_OnMapStart();
	
	Soldier_Barrager_OnMapStart_NPC();
	The_Shit_Slapper_OnMapStart_NPC();
	
	AlliedLeperVisualiserAbility_OnMapStart_NPC();
	AlliedKiryuVisualiserAbility_OnMapStart_NPC();
	AlliedRitualistAbility_OnMapStart_NPC();
	
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
	
#if defined RUINA_BASE
	//Ruina waves	//warp
	Ruina_Ai_Core_Mapstart();
	//Stage 1.
	Theocracy_OnMapStart_NPC();
	Adiantum_OnMapStart_NPC();
	Lanius_OnMapStart_NPC();
	Magia_OnMapStart_NPC();
	Helia_OnMapStart_NPC();
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
	Heliara_OnMapStart_NPC();
	Astriana_OnMapStart_NPC();
	Europis_OnMapStart_NPC();
	Draedon_OnMapStart_NPC();
	Aetheria_OnMapStart_NPC();
	Maliana_OnMapStart_NPC();
	Ruianus_OnMapStart_NPC();
	Lazius_OnMapStart_NPC();
	Dronian_OnMapStart_NPC();
	Lex_OnMapStart_NPC();
	Iana_OnMapStart_NPC();
	//Stage 3.
	Magianas_OnMapStart_NPC();
	Loonaris_OnMapStart_NPC();
	Heliaris_OnMapStart_NPC();
	Astrianis_OnMapStart_NPC();
	Eurainis_OnMapStart_NPC();
	Draeonis_OnMapStart_NPC();
	Aetherium_OnMapStart_NPC();
	Malianium_OnMapStart_NPC();
	Rulius_OnMapStart_NPC();
	Lazines_OnMapStart_NPC();
	Dronis_OnMapStart_NPC();
	Ruliana_OnMapStart_NPC();
	//Stage 4.
	Aetherianus_OnMapStart_NPC();
	Astrianious_OnMapStart_NPC();
	Draconia_OnMapStart_NPC();
	Dronianis_OnMapStart_NPC();
	Euranionis_OnMapStart_NPC();
	Heliarionus_OnMapStart_NPC();
	Lazurus_OnMapStart_NPC();
	Loonarionus_OnMapStart_NPC();
	Magianius_OnMapStart_NPC();
	Malianius_OnMapStart_NPC();
	Rulianius_OnMapStart_NPC();
	Lancelot_OnMapStart_NPC();

	//Special.
	Twirl_OnMapStart_NPC();
	Magia_Anchor_OnMapStart_NPC();
	Ruina_Storm_Weaver_MapStart();
	Ruina_Storm_Weaver_Mid_MapStart();

	Interstellar_Weaver_MapStart();
	Interstellar_Weaver_MapStart_Mid();

#endif


	Kit_Fractal_NPC_MapStart();

	Lelouch_OnMapStart_NPC();
	Manipulation_OnMapStart_NPC();

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
	SergeantIdeal_OnMapStart_NPC();	
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
	VulpoOnMapStart();

	VoidPortal_OnMapStart_NPC();
//VoidCreatures and affected
//1-15
	VoidEaling_OnMapStart_NPC();
	VoidFramingVoider_OnMapStart_NPC();
	GrowingExat_OnMapStart_NPC();
	VoidMutatingBlob_OnMapStart_NPC();
	VoidSpreader_OnMapStart_NPC();
	VoidInfestor_OnMapStart_NPC();
	VoidHardCrust_OnMapStart_NPC();
	VoidCarrier_OnMapStart_NPC();
	//boss
	VoidIxufan_OnMapStart_NPC();

//16-30
	VoidEnFramedVoider_OnMapStart_NPC();
	VoidBloodPollutor_OnMapStart_NPC();
	VoidExpidonsanFortifier_OnMapStart_NPC();
	VoidParticle_OnMapStart_NPC();
	VoidHostingBlob_OnMapStart_NPC();
	VoidBlobbingMonster_OnMapStart_NPC();
	VoudSprayer_OnMapStart_NPC();

	//boss
	VoidEncasulator_OnMapStart_NPC();

//31-45
	VoudExpidonsanCleaner_OnMapStart_NPC();
	VoidExpidonsanContainer_OnMapStart_NPC();
	VoidSacraficer_OnMapStart_NPC();
	VoidingBedrock_OnMapStart_NPC();
	VoidHeavyPerisher_OnMapStart_NPC();
	VoidMinigateKeeper_OnMapStart_NPC();

//boss
	VoidBroodingPetra_OnMapStart_NPC();

//46-60
	VoidKunul_OnMapStart_NPC();
	VoidTotalGrowth_OnMapStart_NPC();
	VoidsOffspring_OnMapStart_NPC();
	VoidRejuvinator_OnMapStart_NPC();
	VoidedErasus_OnMapStart_NPC();

//boss
	VoidSpeechless_OnMapStart_NPC();
//Raids
	VoidUnspeakable_OnMapStart_NPC();

	//void events
	VoidedDiversionistico_OnMapStart_NPC();

//Iberia Expidonsa
	//Overall usage
	Iberia_Beacon_OnMapStart_NPC();
	IberiaBeaconConstructor_OnMapStart_NPC();
	Iberia_Lighthouse_OnMapStart_NPC();
	Huirgrajo_Precache();
	
// wave 1-15
	Iberia_Cambino_OnMapStart_NPC();
	Iberia_Irani_OnMapStart_NPC();
	Iberia_Kinat_OnMapStart_NPC();
	Iberia_Ginus_OnMapStart_NPC();
	Iberia_SpeedusInitus_OnMapStart_NPC();
	Iberia_Anania_OnMapStart_NPC();
	Iberia_Victorian_OnMapStart_NPC();
	Iberia_inqusitor_iidutas_OnMapStart_NPC();
  

//wave 16 -30
	IberiaVivintu_OnMapStart_NPC();
	IberiaCenula_OnMapStart_NPC();
	IberiaKumbai_OnMapStart_NPC();
	IberiaSpeedusInstantus_OnMapStart_NPC();
	IberiaCombastia_OnMapStart_NPC();
	IberiaMorato_OnMapStart_NPC();
	IberiaSeaXploder_OnMapStart_NPC();
	Iberia_AntiSeaRobot_OnMapStart_NPC();

// 31-45

	IberiaRanka_S_OnMapStart_NPC();
	IberiaMurdarato_OnMapStart_NPC();
	IberiaEliteKinat_OnMapStart_NPC();
	Iberia_SeabornAnnihilator_OnMapStart_NPC();
	IberianSentinel_OnMapStart_NPC();
	IberianIronborus_OnMapStart_NPC();
	IberianDestructius_OnMapStart_NPC();
	IberiaSpeedusItus_OnMapStart_NPC();

//wave 45-60

	IberiaSpeedusElitus_OnMapStart_NPC();
	IberiaSeaDryer_OnMapStart_NPC();
	IberiaRunaka_OnMapStart_NPC();
	IberiaDeathMarker_OnMapStart_NPC();
	Iberia_inqusitor_irene_OnMapStart_NPC();

//Victorian Raid
//wave 1~10
	Victoria_Batter_OnMapStart_NPC();
	Victorian_Charger_OnMapStart_NPC();
	Victorian_Teslar_OnMapStart_NPC();
	VictorianBallista_OnMapStart_NPC();
	VictorianVanguard_OnMapStart_NPC();
	VictorianSupplier_OnMapStart_NPC();
	VictorianIgniter_OnMapStart_NPC();
	VictorianGrenadier_OnMapStart_NPC();
	VictorianSquadleader_OnMapStart_NPC();
	VictorianSignaller_OnMapStart_NPC();
	
//wave 11~20
	VictorianHumbee_MapStart();
	VictorianShotgunner_OnMapStart_NPC();
	Bulldozer_OnMapStart_NPC();
	VictorianHardener_OnMapStart_NPC();
	VictorianRaider_OnMapStart_NPC();
	Zapper_OnMapStart_NPC();
	VictorianPayback_OnMapStart_NPC();
	Blocker_OnMapStart_NPC();
	VictoriaDestructor_Precache();
	VictorianIronShield_OnMapStart_NPC();
	Aviator_OnMapStart_NPC();
	
//wave 21~30
	Victoria_BaseBreaker_OnMapStart_NPC();
	VictoriaAntiarmorInfantry_OnMapStart_NPC();
	VictoriaAssaulter_OnMapStart_NPC();
	VictorianMechafist_OnMapStart_NPC();
	VictorianBooster_OnMapStart_NPC();
	VictoriaScorcher_OnMapStart_NPC();
	VictoriaMowdown_OnMapStart_NPC();
	VictoriaMortar_OnMapStart_NPC();
	VictoriaArtillerist_OnMapStart_NPC();
	VictoriaBreachcart_MapStart();
	VictoriaBombcart_Precache();
	VictoriaBigpipe_OnMapStart_NPC();
	VictoriaHarbringer_OnMapStart_NPC();
	VictoriaBirdeye_OnMapStart_NPC();

//wave 31~40
	VictorianCaffeinator_OnMapStart_NPC();
	VictorianMechanist_as_OnMapStart_NPC();
	VictorianOfflineAvangard_MapStart();
	VictorianWelder_OnMapStart_NPC();
	VIctorianTanker_OnMapStart_NPC();
	VictorianAssaultVehicle_OnMapStart();
	VictorianPulverizer_OnMapStart_NPC();
	VIctorianAmbusher_OnMapStart_NPC();
	VictoriaTank_MapStart();
	VictoriaTaser_OnMapStart_NPC();
	VictoriaRadiomast_OnMapStart_NPC();
	VictoriaRepair_OnMapStart_NPC();
	Victorian_Radioguard_OnMapStart_NPC();

//raid
	Atomizer_OnMapStart_NPC();
	Huscarls_OnMapStart_NPC();
	Harrison_OnMapStart_NPC();
	Castellan_OnMapStart_NPC();
	
//Special
	CyberGrindGM_OnMapStart_NPC();
	Invisible_TRIGGER_Man_OnMapStart_NPC();
	CyberMessenger_OnMapStart_NPC();
	TrueCyberWarrior_OnMapStart();
	VillageAlaxios_OnMapStart();

//special
	Invisible_TRIGGER_OnMapStart_NPC();//It is currently used as a trigger for the Victoria Factory.
	CaptinoBaguettus_OnMapStart_NPC();//Captino Meinus Follower
	VictorianFactory_MapStart();
	VictorianDroneFragments_MapStart();
	VictorianDroneAnvil_MapStart();
	Victorian_Tacticalunit_OnMapStart_NPC();
	Victorian_TacticalProtector_OnMapStart_NPC();
	TEST_Dummy_OnMapStart_NPC();

	//Alt Barracks
	Barrack_Alt_Ikunagae_MapStart();
	Barrack_Alt_Shwertkrieg_MapStart();
	Barrack_Railgunner_MapStart();
	Barrack_Alt_Basic_Mage_MapStart();
	Barrack_Alt_Intermediate_Mage_MapStart();
	Barrack_Alt_Advanced_Mage_MapStart();
	Barrack_Alt_Donnerkrieg_MapStart();
	Barrack_Alt_Holy_Knight_MapStart();
	Barrack_Alt_Mecha_Barrager_MapStart();
	Barrack_Alt_Barrager_MapStart();
	Barrack_Alt_Mecha_Loader_MapStart();
	Barrack_Alt_Crossbowmedic_MapStart();
	Barrack_Alt_Scientific_Witchery_MapStart();
	VIPBuilding_MapStart();
	AlliedSensalAbility_OnMapStart_NPC();
	BarrackVillagerOnMapStart();
	BarrackBuildingOnMapStart();
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
	BarrackHandCannoneerOnMapStart();
	BarrackArcherOnMapStart();
	BarrackArbelastOnMapStart();
	AlliedKahmlAbilityOnMapStart();
	RitualistInstinct_MapStart();

	//Combine Barracks
	Barracks_Combine_Pistol_Precache();
	Barracks_Combine_Smg_Precache();
	
	Barracks_Combine_Sword_Precache();
	Barracks_Combine_Ar2_Precache();
	
	Barracks_Combine_Ddt_Precache();
	Barracks_Combine_Shotgun_Precache();
	
	Barracks_Combine_Collos_Precache();
	Barracks_Combine_Elite_Precache();
	
	Barracks_Combine_Sniper_Precache();
	Barracks_Combine_Giant_DDT_Precache();
	
	Barracks_Combine_Super_Precache();
	Barracks_Combine_Chaos_Containment_Unit_Precache();
	
	Barracks_Combine_Commander_Precache();

	//Iberia Barracks
	Barracks_Iberia_Runner_Precache();
	Barracks_Iberia_Gunner_Precache();

	Barracks_Iberia_Tanker_Precache();
	Barracks_Iberia_Rocketeer_Precache();

	Barracks_Iberia_Healer_Precache();
	Barracks_Iberia_Boomstick_Precache();
	
	Barracks_Iberia_Healtanker_Precache();
	Barracks_Iberia_Elite_Gunner_Precache();
	
	Barracks_Iberia_Guards_Precache();
	Barracks_Iberia_Commando_Precache();

	Barracks_Iberia_Headhunter_Precache();
	Barrack_Iberia_Inquisitor_Lynsen_Precache();

	Barracks_Iberia_Lighthouse_Guardian_Precache();
	
	//Iberia Last Hope
	Barracks_Thorns();

	// Raid Low Prio
	TrueFusionWarrior_OnMapStart();
	Blitzkrieg_OnMapStart();
	RaidbossSilvester_OnMapStart();
	RaidbossBlueGoggles_OnMapStart();
	RaidbossNemesis_OnMapStart();
	RaidbossMrX_OnMapStart();
	GodAlaxios_OnMapStart();
	Sensal_OnMapStart_NPC();
	Karlas_OnMapStart_NPC();
	Stella_OnMapStart_NPC();
	RaidbossBobTheFirst_OnMapStart();
	TheMessenger_OnMapStart_NPC();
	ChaosKahmlstein_OnMapStart_NPC();
	ThePurge_MapStart();
	Nemal_OnMapStart_NPC();
	Silvester_OnMapStart_NPC();

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
	Wisp_Setup();

	// COF Low Prio
	Addiction_OnMapStart_NPC();
	Doctor_MapStart();
	Simon_MapStart();
	Sewmo_OnMapStart_NPC();
	Faster_OnMapStart_NPC();
	Psycho_OnMapStart_NPC();
	Suicider_OnMapStart_NPC();
	Crazylady_OnMapStart_NPC();
	Children_OnMapStart_NPC();
	Taller_OnMapStart_NPC();
	Baby_OnMapStart_NPC();
	Stranger_OnMapStart_NPC();
	CuredPurnell_OnMapStart_NPC();
	CorruptedBarney_OnMapStart_NPC();
	XenoMalfuncRobot_OnMapStart_NPC();
	

	// Bloon Raid Low Prio
	Bloonarius_MapStart();

	// Rogue Mode Low Prio
	OverlordRogue_OnMapStart_NPC();
	RaidbossBladedance_MapStart();
	//whiteflower special:
	Whiteflower_Boss_OnMapStart_NPC();
	WFOuroborosEkas_OnMapStart_NPC();
	Whiteflower_Ekas_Piloteer_OnMapStart_NPC();
	AcclaimedSwordsman_OnMapStart_NPC();
	Whiteflower_ExtremeKnightGiant_OnMapStart_NPC();
	Whiteflower_RagingBlader_OnMapStart_NPC();
	Whiteflower_FloweringDarkness_OnMapStart_NPC();

	//Normal rogue again:
	RogueCondition_Setup();
	GogglesFollower_Setup();
	TheHunter_Setup();

	FinalHunter_Setup();
	KahmlsteinFollower_Setup();
	Vhxis_OnMapStart_NPC();
	ChaosMage_OnMapStart_NPC();
	ChaosSupporter_OnMapStart_NPC();
	ChaosInsane_OnMapStart_NPC();
	ChaosSickKnight_OnMapStart_NPC();
	ChaosInjuredCultist_OnMapStart_NPC();
	ChaosEvilDemon_OnMapStart_NPC();
	HallamGreatDemon_OnMapStart_NPC();
	HallamDemonWhisperer_OnMapStart_NPC();
	ChaosSwordsman_OnMapStart_NPC();
	NightmareSwordsman_OnMapStart_NPC();
	MajorVoided_MapStart();
	DuckFollower_Setup();
	BobTheFirstFollower_Setup();
	TwirlFollower_Setup();
	
	// Construction
	BaseBuilding_MapStart();
	ZeinaFreeFollower_Setup();

	// Survival
	Nightmare_OnMapStart_NPC();
	PetrisBaron_OnMapStart_NPC();
	Sphynx_OnMapStart_NPC();
	ZombineSurvival_OnMapStart_NPC();
	ZMainHeadcrabZombie_OnMapStart_NPC();
	Headcrab_MapStart();
	PoisonHeadcrab_MapStart();
	ZMainPoisonZombie_OnMapStart_NPC();
	ZMainHeadcrab_OnMapStart_NPC();

	// Matrix
	AgentAlan_OnMapStart_NPC();
	AgentAlexander_OnMapStart_NPC();
	AgentChase_OnMapStart_NPC();
	AgentDave_OnMapStart_NPC();
	AgentGraham_OnMapStart_NPC();
	AgentJames_OnMapStart_NPC();
	AgentJohn_OnMapStart_NPC();
	AgentSteve_OnMapStart_NPC();
	Antiviral_Program_OnMapStart_NPC();
	AgentEric_OnMapStart_NPC();
	AgentJack_OnMapStart_NPC();
	AgentJim_OnMapStart_NPC();
	AgentJosh_OnMapStart_NPC();
	AgentKenneth_OnMapStart_NPC();
	AgentPaul_OnMapStart_NPC();
	AgentTyler_OnMapStart_NPC();
	AgentWayne_OnMapStart_NPC();
	Merovingian_OnMapStart_NPC();
	AgentBen_OnMapStart_NPC();
	AgentChad_OnMapStart_NPC();
	AgentChris_OnMapStart_NPC();
	AgentDick_OnMapStart_NPC();
	AgentIan_OnMapStart_NPC();
	AgentJackson_OnMapStart_NPC();
	AgentMike_OnMapStart_NPC();
	AgentSam_OnMapStart_NPC();
	AgentZack_OnMapStart_NPC();
	AgentConnor_OnMapStart_NPC();
	AgentHenry_OnMapStart_NPC();
	AgentJeremy_OnMapStart_NPC();
	AgentJones_OnMapStart_NPC();
	AgentKurt_OnMapStart_NPC();
	AgentLogan_OnMapStart_NPC();
	AgentRoss_OnMapStart_NPC();
	AgentSpencer_OnMapStart_NPC();
	AgentTodd_OnMapStart_NPC();

	//Matrix Giants
	GiantHaste_OnMapStart_NPC();
	GiantKnockout_OnMapStart_NPC();
	GiantReflector_OnMapStart_NPC();
	GiantRegeneration_OnMapStart_NPC();

	//Matrix Raids
	AgentJohnson_OnMapStart_NPC();
	AgentThompson_OnMapStart_NPC();
	Twin1_OnMapStart_NPC();
	AgentSmith_OnMapStart_NPC();

	//Matrix Freeplay
	AgentDaveFreeplay_OnMapStart_NPC();
	AgentWayneFreeplay_OnMapStart_NPC();
	AgentIanFreeplay_OnMapStart_NPC();
	AgentSpencerFreeplay_OnMapStart_NPC();

	BossSummonRandom_OnMapStart_NPC();
	//Combine Mutation
	OmegaRaid_OnMapStart_NPC();
	LostKnight_OnMapStart_NPC();
	Merlton_Boss_OnMapStart_NPC();
	BobFollower_Setup();
	Hunter_OnMapStart_NPC();
	Void_Combine_Police_Pistol_OnMapStart_NPC();
	VoidCombinePoliceSmg_OnMapStart_NPC();
	VoidCombineElite_OnMapStart_NPC();
	VoidCombineSoldierAr2_OnMapStart_NPC();
	VoidCombineSoldierShotgun_OnMapStart_NPC();
	Seaborn_Combine_Police_Pistol_OnMapStart_NPC();
	SeabornCombinePoliceSmg_OnMapStart_NPC();
	SeabornCombineElite_OnMapStart_NPC();
	SeabornCombineSoldierAr2_OnMapStart_NPC();
	SeabornCombineSoldierShotgun_OnMapStart_NPC();

	// Freeplay
	DimensionalFragment_OnMapStart_NPC();
	ImmutableHeavy_OnMapStart_NPC();
	VanishingMatter_OnMapStart_NPC();
	Erasus_OnMapStart_NPC();
	AnnoyingSpirit_OnMapStart_NPC();
	FogOrbHeavy_OnMapStart_NPC();

	// Construction
	MaterialCash_MapStart();
	MaterialCopper_MapStart();
	MaterialCrystal_MapStart();
	MaterialIron_MapStart();
	MaterialJalan_MapStart();
	MaterialOssunia_MapStart();
	MaterialStone_MapStart();
	MaterialWizuh_MapStart();
	MaterialWood_MapStart();
	MaterialEvilExpi_MapStart();
	MaterialGift_MapStart();

	//April Fools
	PackaPunch_OnMapStart();
	PerkMachiner_OnMapStart();
	AmmoBox_OnMapStart();
	Male07_OnMapStart();
	SpiritRunner_OnMapStart_NPC();
	ErrorMelee_OnMapStart_NPC();
	ErrorRanged_OnMapStart_NPC();
	ToddHoward_OnMapStart();
	KevinMery_OnMapStart_NPC();
	RedHeavy_OnMapStart_NPC();
	BlueHeavy_OnMapStart_NPC();
	CyanHeavy_OnMapStart_NPC();
	GreenHeavy_OnMapStart_NPC();
	OrangeHeavy_OnMapStart_NPC();
	YellowHeavy_OnMapStart_NPC();
	PurpleHeavy_OnMapStart_NPC();
	Temperals_Buster_OnMapStart_NPC();
	TrollAr2_OnMapStart_NPC();
	TrollPistol_OnMapStart_NPC();
	TrollRPG_OnMapStart_NPC();
	TrollBrawler_OnMapStart_NPC();

	//Expidonsa Rogue forces in Construction
	Eirasus_OnMapStart_NPC();
	Haltera_OnMapStart_NPC();
	Flaigus_OnMapStart_NPC();
	BigGunAssisa_OnMapStart_NPC();
	HiaRejuvinator_OnMapStart_NPC();
	CuttusSiccino_OnMapStart_NPC();
	ArmsaManu_OnMapStart_NPC();
	SpeedusAbsolutos_OnMapStart_NPC();
	VausShaldus_OnMapStart_NPC();
	SoldinusIlus_OnMapStart_NPC();
	SelfamScythus_OnMapStart_NPC();
	Diversionistico_Elitus_OnMapStart_NPC();
	Construction_Raid_Zilius_OnMapStart();
	ZeinaPrisoner_OnMapStart_NPC();


	//Aperture
	Aperture_Shared_OnMapStart();
	RefragmentedBase_OnMapStart();
	ApertureCombatant_OnMapStart_NPC();
	ApertureShotgunner_OnMapStart_NPC();
	ApertureDevastator_OnMapStart_NPC();
	ApertureHuntsman_OnMapStart_NPC();
	ApertureJumper_OnMapStart_NPC();
	AperturePhaser_OnMapStart_NPC();
	ApertureSniper_OnMapStart_NPC();
	ApertureRepulsor_OnMapStart_NPC();
	ApertureMinigunner_OnMapStart_NPC();
	ApertureSpecialist_OnMapStart_NPC();
	ApertureSupporter_OnMapStart_NPC();
	ApertureCombatantV2_OnMapStart_NPC();
	ApertureShotgunnerV2_OnMapStart_NPC();
	ApertureHuntsmanV2_OnMapStart_NPC();
	ApertureJumperV2_OnMapStart_NPC();
	AperturePhaserV2_OnMapStart_NPC();
	ApertureSniperV2_OnMapStart_NPC();
	ApertureSpecialistV2_OnMapStart_NPC();
	ApertureDemolisherV2_OnMapStart_NPC();
	ApertureDevastatorV2_OnMapStart_NPC();
	ApertureMinigunnerV2_OnMapStart_NPC();
	ApertureRepulsorV2_OnMapStart_NPC();
	ApertureSupporterV2_OnMapStart_NPC();
	ApertureCombatantPerfected_OnMapStart_NPC();
	ApertureShotgunnerPerfected_OnMapStart_NPC();
	ApertureHuntsmanPerfected_OnMapStart_NPC();
	ApertureSniperPerfected_OnMapStart_NPC();
	AperturePhaserPerfected_OnMapStart_NPC();
	ApertureJumperPerfected_OnMapStart_NPC();
	ApertureSpecialistPerfected_OnMapStart_NPC();
	ApertureDemolisherPerfected_OnMapStart_NPC();
	ApertureDevastatorPerfected_OnMapStart_NPC();
	ApertureMinigunnerPerfected_OnMapStart_NPC();
	ApertureRepulsorPerfected_OnMapStart_NPC();
	ApertureSupporterPerfected_OnMapStart_NPC();
	ApertureBuilder_OnMapStart_NPC();
	ApertureSentry_OnMapStart_NPC();
	ApertureDispenser_OnMapStart_NPC();
	ApertureTeleporter_OnMapStart_NPC();
	ApertureDemolisher_OnMapStart_NPC();
	ApertureContainer_OnMapStart_NPC();
	ApertureTraveller_OnMapStart_NPC();
	PortalGate_OnMapStart_NPC();
	FatherGrigoriScience_OnMapStart_NPC();
	ApertureExterminator_OnMapStart_NPC();
	ApertureSpokesman_OnMapStart_NPC();
	ApertureResearcher_OnMapStart_NPC();
	RefragmentedHeadcrabZombie_OnMapStart_NPC();
	RefragmentedFastZombie_OnMapStart_NPC();
	RefragmentedPoisonZombie_OnMapStart_NPC();
	Refragmented_Combine_Police_Pistol_OnMapStart_NPC();
	RefragmentedCombinePoliceSmg_OnMapStart_NPC();
	RefragmentedCombineSoldierAr2_OnMapStart_NPC();
	RefragmentedCombineElite_OnMapStart_NPC();
	RefragmentedHeavy_OnMapStart_NPC();
	RefragmentedMedic_OnMapStart_NPC();
	RefragmentedSpy_OnMapStart_NPC();
	Parasihtta_OnMapStart_NPC();
	Talker_OnMapStart_NPC();
	Hostis_OnMapStart_NPC();
	Defectio_OnMapStart_NPC();
	ApertureCollector_OnMapStart_NPC();
	ApertureFueler_OnMapStart_NPC();
	ApertureHalter_OnMapStart_NPC();
	ApertureSuppressor_OnMapStart_NPC();
	CAT_OnMapStart_NPC();
	ARIS_OnMapStart_NPC();
	ARISBeacon_OnMapStart_NPC();
	CHIMERA_OnMapStart_NPC();
	RefragmentedWinterSniper_OnMapStart_NPC();
	RefragmentedWinterFrostHunter_OnMapStart_NPC();
	Vincent_OnMapStart_NPC();
	Vincent_Beacon_OnMapStart_NPC();

	//rogue 3
	Umbral_Ltzens_OnMapStart_NPC();
	Umbral_Refract_OnMapStart_NPC();
	Umbral_Koulm_OnMapStart_NPC();
	HHH_OnMapStart_NPC();
	GentleSpy_OnMapStart_NPC();
	ChristianBrutalSniper_OnMapStart_NPC();
	Umbral_Spuud_OnMapStart_NPC();
	Umbral_Keitosis_OnMapStart_NPC();
	AlmagestSeinr_OnMapStart_NPC();
	AlmagestJkei_OnMapStart_NPC();
	JkeiDrone_OnMapStart_NPC();
	RandomizerBaseFlamethrower_OnMapStart_NPC();
	RandomizerBaseHuntsman_OnMapStart_NPC();
	RandomizerBaseSouthernHospitality_OnMapStart_NPC();
	Randomizer_OnMapStart_NPC();
	BossReila_OnMapStart_NPC();
	ReilaBeacon_OnMapStart_NPC();
	ReilaFollower_Setup();
	Umbral_Automaton_OnMapStart_NPC();
	OmegaFollower_Setup();
	
	VhxisFollower_Setup();
	Shadow_FloweringDarkness_OnMapStart_NPC();
	Shadowing_Darkness_Boss_OnMapStart_NPC();
	TornUmbralGate_OnMapStart_NPC();
	Umbral_WF_OnMapStart_NPC();
	AlliedWarpedCrystal_Visualiser_OnMapStart_NPC();
	Umbral_Rouam_OnMapStart_NPC();
	WinTimer_MapStart();
	SensalFollower_Setup();
	OverlordFollower_Setup();
	
	#if defined BONEZONE_BASE
	BasicBones_OnMapStart_NPC();
	BeefyBones_OnMapStart_NPC();
	BrittleBones_OnMapStart_NPC();
	BigBones_OnMapStart_NPC();

	CriminalBones_OnMapStart_NPC();
	SluggerBones_OnMapStart_NPC();
	RattlerBones_OnMapStart_NPC();
	MolotovBones_OnMapStart_NPC();
	Godfather_OnMapStart_NPC();

	DeckhandBones_OnMapStart_NPC();
	PirateBones_OnMapStart_NPC();
	FlintlockBones_OnMapStart_NPC();
	BuccaneerBones_OnMapStart_NPC();
	AleraiserBones_OnMapStart_NPC();
	Captain_OnMapStart_NPC();

	PeasantBones_OnMapStart_NPC();
	SquireBones_OnMapStart_NPC();
	ArchmageBones_OnMapStart_NPC();
	JesterBones_OnMapStart_NPC();
	NecromancerBones_OnMapStart_NPC();
	SaintBones_OnMapStart_NPC();
	AlchemistBones_OnMapStart_NPC();
	Lordread_OnMapStart_NPC();

	GrimReaper_OnMapStart_NPC();
	SupremeSpookmasterBones_OnMapStart_NPC();
	SSBChair_OnMapStart_NPC();
	#endif

	DrDamSpecialDelivery_OnMapStart_NPC();
	DrDamClone_OnMapStart_NPC();

	
	BarbaricTeardownOnMapStart();
	SkilledCrossbowmanOnMapStart();
	DemonDevoterOnMapStart();
	DungeonLoot_MapStart();
	
	// Foolish
	EasyBobTheFirst_OnMapStart();
	EasyAlaxios_OnMapStart();
	
	// Gmod ZS
	ZSZombie_OnMapStart_NPC();
	ZSHeadcrab_OnMapStart_NPC();
	Ghoul_OnMapStart_NPC();
	ZSPoisonZombie_OnMapStart_NPC();
	ZSPoisonHeadcrab_MapStart();
	ZSFortifiedGiantPoisonZombie_OnMapStart_NPC();
	Butcher_OnMapStart_NPC();
	ZSThe_Shit_Slapper_OnMapStart_NPC();
	BloatedZombie_OnMapStart_NPC();
	ZSFastZombie_OnMapStart_NPC();
	Skeleton_OnMapStart_NPC();
	ShadowWalker_OnMapStart_NPC();
	ElderGhoul_OnMapStart_NPC();
	GoreBlaster_OnMapStart_NPC();
	Bastardzine_OnMapStart_NPC();
	FastHeadcrab_OnMapStart_NPC();
	VileBloatedZombie_OnMapStart_NPC();
	FleshCreeper_OnMapStart_NPC();
	Nest_OnMapStart_NPC();
	ZSZmain_OnMapStart_NPC();
	ZombieSummonRandom_OnMapStart_NPC();
	Amplification_Precache();
	Pregnant_Precache();
	ZSHeadcrabZombie_OnMapStart_NPC();
	ZSFastheadcrabZombie_OnMapStart_NPC();
	ZSPoisonheadcrabZombie_OnMapStart_NPC();
	ZsSpitter_Precache();
	Zsrunner_Precache();
	ZSsoldierOnMapStart();
	ZsSpy_OnMapStart_NPC();
	ZSscout_OnMapStart_NPC();
	InfectedHeavy_Precache();
	Zsvulture_OnMapStart_NPC();
	ZsSoldier_Barrager_OnMapStart_NPC();
	ZSoldierGrave_OnMapStart_NPC();
	InfectedSniperjarate_Precache();
	NinjaSpy_OnMapStart_NPC();
	ZsUnspeakable_OnMapStart_NPC();
	InfectedDemoMain_OnMapStart_NPC();
	InfectedKamikaze_OnMapStart_NPC();
	InfectedEngineer_OnMapStart_NPC();
	Eradicator_OnMapStart_NPC();
	ZSHowler_OnMapStart_NPC();
	ZSSphynx_OnMapStart_NPC();
	ZSNightmare_OnMapStart_NPC();
	ZSMedicHealer_OnMapStart_NPC();
	ZSHuntsman_OnMapStart_NPC();
	InfectedFatScout_Precache();
	InfectedBattleMedic_OnMapStart_NPC();
	InfectedFatSpy_Precache();
	InfectedCleaner_OnMapStart_NPC();
	InfectedFireFighter_OnMapStart_NPC();
	ZSCombineElite_OnMapStart_NPC();
	ZSVILEPoisonheadcrabZombie_OnMapStart_NPC();
	StrangPyro_OnMapStart_NPC();
	InfectedMessengerOnMapStart();
	InfectedHazardous_OnMapStart_NPC();
	BreadMonster_Precache();
	ZsMalfuncHeavy_OnMapStart_NPC();
	RedMarrow_OnMapStart_NPC();
	InfectedSniperOnMapStart();
	Bonemesh_OnMapStart_NPC();
	DasNaggenvatcher_OnMapStart();
	StoneAgeMaker_OnMapStart_NPC();
	MassShootingLover_OnMapStart_NPC();
	Allymedic_OnMapStart_NPC();
	Allysoldier_OnMapStart_NPC();
	Allyheavy_OnMapStart_NPC();
	AllySniper_OnMapStart_NPC();
}

void NPC_MapEnd()
{
	#if defined BONEZONE_BASE
	SSB_DeleteAbilities();
	SSBChair_DeleteAbilities();
	#endif
}

int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	if(!TranslationPhraseExists(data.Name))
	{
		LogError("Translation '%s' does not exist", data.Name);
		strcopy(data.Name, sizeof(data.Name), "nothing");
	}

	return NPCList.PushArray(data);
}

stock int NPC_GetCount()
{
	return NPCList.Length;
}

stock int NPC_GetNameById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Name);
}

stock int NPC_GetNameByPlugin(const char[] name, char[] buffer, int length)
{
	int index = NPCList.FindString(name, NPCData::Plugin);
	if(index == -1)
		return 0;
	
	static NPCData data;
	NPCList.GetArray(index, data);
	return strcopy(buffer, length, data.Name);
}

stock int NPC_GetPluginById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Plugin);
}

stock void NPC_GetById(int id, NPCData data)
{
	NPCList.GetArray(id, data);
}

stock int NPC_GetByPlugin(const char[] name, NPCData data = {}, const char[] chardata = "")
{
	int index = NPCList.FindString(name, NPCData::Plugin);
	if(index != -1)
	{
		NPCList.GetArray(index, data);
		PrecacheNPC(index, data);
		PrecacheNPC_WithData(data, chardata);
	}
	
	return index;
}

static void PrecacheNPC_WithData(NPCData data, const char[] chardata)
{
	if(data.Precache_data && data.Precache_data != INVALID_FUNCTION)
	{
		Call_StartFunction(null, data.Precache_data);
		Call_PushString(chardata);
		Call_Finish();
	}
}
static void PrecacheNPC(int i, NPCData data)
{
	
	if(!data.Precached)
	{
		if(data.Icon[0] && data.IconCustom)
			PrecacheMvMIconCustom(data.Icon);
		
		if(data.Precache && data.Precache != INVALID_FUNCTION)
		{
			Call_StartFunction(null, data.Precache);
			Call_Finish();
		}

		data.Precached = true;
		NPCList.SetArray(i, data);
	}
}

stock int NPC_CreateByName(const char[] name, int client, float vecPos[3], float vecAng[3], int team, const char[] data = "", bool ignoreSetup = false)
{
	static NPCData npcdata;
	int id = NPC_GetByPlugin(name, npcdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid NPC!", name);
		return -1;
	}

	return CreateNPC(npcdata, id, client, vecPos, vecAng, team, data, ignoreSetup);
}

int NPC_CreateById(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], int team, const char[] data = "", bool ignoreSetup = false)
{
	if(Index_Of_Npc < 1 || Index_Of_Npc >= NPCList.Length)
	{
		PrintToChatAll("[%d] is not a valid NPC!", Index_Of_Npc);
		return -1;
	}

	static NPCData npcdata;
	NPC_GetById(Index_Of_Npc, npcdata);
	return CreateNPC(npcdata, Index_Of_Npc, client, vecPos, vecAng, team, data, ignoreSetup);
}

static int CreateNPC(NPCData npcdata, int id, int client, float vecPos[3], float vecAng[3], int team, const char[] data, bool ignoreSetup)
{
	PrecacheNPC(id, npcdata);

	any entity = -1;

	Call_StartFunction(null, npcdata.Func);
	Call_PushCell(client);
	Call_PushArrayEx(vecPos, sizeof(vecPos), 0);
	Call_PushArrayEx(vecAng, sizeof(vecAng), 0);
	Call_PushCell(team);
	Call_PushString(data);
	Call_Finish(entity);
	
	if(entity != -1)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), npcdata.Name);
		
		if(Rogue_GetChaosLevel() > 0)
		{
			static char last[64];
			b_NameNoTranslation[entity] = true;
			
			if(!(GetURandomInt() % 4))
			{
				strcopy(c_NpcName[entity], sizeof(c_NpcName[]), last);
				strcopy(last, sizeof(last), npcdata.Name);
			}
		}

		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
		
		if(!ignoreSetup)
		{
			if(GetTeam(entity) == 2)
			{
				Rogue_AllySpawned(entity);
				Waves_AllySpawned(entity);
			}
			else
			{
				Rogue_EnemySpawned(entity);
				Waves_EnemySpawned(entity);
				Construction_EnemySpawned(entity);
				Dungeon_EnemySpawned(entity);
			}
			Waves_UpdateMvMStats();
		}
		if(BetWar_Mode())
			b_ShowNpcHealthbar[entity] = true;
	}

	return entity;
}

void ZR_NpcTauntWinClear()
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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
	Freeplay_OnNPCDeath(entity);
	Cheese_OnNPCDeath(entity);
	if(view_as<CClotBody>(entity).m_fCreditsOnKill)
	{
		int GiveMoney = 0;
		float CreditsOnKill = view_as<CClotBody>(entity).m_fCreditsOnKill;
		if (CreditsOnKill <= 1.0)
		{
			f_FactionCreditGain += CreditsOnKill;

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
		Native_OnGivenCash(0, GiveMoney);
		CurrentCash += GiveMoney;
		Waves_AddCashGivenThisWaveViaKills(CurrentCash);
	}
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int DeathNoticer = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(DeathNoticer) && !b_NpcHasDied[DeathNoticer])
		{
			Function func = func_NPCDeathForward[DeathNoticer];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(DeathNoticer);
				Call_PushCell(entity);
				Call_Finish();
			}
		}
	}
	StatusEffectReset(entity, false);
	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
		return;
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
	return Plugin_Changed;
}

//BASES FOR ENEMIES
#include "npc/expidonsa/npc_expidonsa_base.sp" //ALSO IN RPG!
#include "npc/seaborn/npc_nethersea_shared.sp"
#include "npc/ruina/ruina_npc_enchanced_ai_core.sp"	//this controls almost every ruina npc's behaviors.

//BUILDINGS
#include "object/obj_shared.sp"
#include "object/obj_armortable.sp"
#include "object/obj_decorative.sp"
#include "object/obj_perkmachine.sp"
#include "object/obj_healingstation.sp"
#include "object/obj_packapunch.sp"
#include "object/obj_barricade.sp"
#include "object/obj_ammobox.sp"
#include "object/obj_tinker_anvil.sp"
#include "object/obj_sentrygun.sp"
#include "object/obj_vintulum_bomb.sp"
#include "object/obj_mortar.sp"
#include "object/obj_railgun.sp"
#include "object/obj_village.sp"
#include "object/obj_barracks.sp"
#include "object/obj_brewing_stand.sp"
#include "object/obj_revenant.sp"
#include "object/obj_grill.sp"
#include "object/construction/obj_giant_lighthouse.sp"
#include "object/construction/obj_const_stove.sp"
#include "object/construction/obj_const_factory.sp"
//#include "object/construction/obj_hospital.sp"
#include "object/construction/obj_const_research.sp"
#include "object/construction/obj_const_pump.sp"
#include "object/construction/obj_const_wood.sp"
#include "object/construction/obj_const_stone.sp"
#include "object/construction/obj_const_minter.sp"
#include "object/construction/obj_const_wall.sp"
#include "object/construction/obj_supergun.sp"
#include "object/construction/obj_minigun_turret.sp"
#include "object/construction/obj_teslars_medusa.sp"
#include "object/construction/obj_const_stungun.sp"
#include "object/construction/obj_const_dispenser.sp"
#include "object/construction/obj_const_furniture.sp"
#include "object/construction/obj_const_supply.sp"
#include "object/construction/obj_const_helper.sp"
#include "object/construction/obj_const_voidstone.sp"
#include "object/construction/obj_dungeon_center.sp"
#include "object/construction/obj_dungeon_crafter.sp"
#include "object/construction/obj_dungeon_dispenser.sp"
#include "object/construction/obj_dungeon_lighthouse.sp"
#include "object/construction/obj_dungeon_minigun_turret.sp"
#include "object/construction/obj_dungeon_stove.sp"
#include "object/construction/obj_dungeon_stungun.sp"
#include "object/construction/obj_dungeon_supergun.sp"
#include "object/construction/obj_dungeon_teslars_medusa.sp"
#include "object/construction/obj_dungeon_wall.sp"

// VEHICLES
#include "../shared/vehicles/vehicle_shared.sp"
#include "../shared/vehicles/vehicle_hl2.sp"
#include "vehicles/vehicle_fulljeep.sp"
#include "vehicles/vehicle_ambulance.sp"
//#include "vehicles/vehicle_bus.sp"
#include "vehicles/vehicle_camper.sp"
#include "vehicles/vehicle_dumptruck.sp"
#include "vehicles/vehicle_landrover.sp"
#include "vehicles/vehicle_pickup.sp"

//NORMAL
#include "npc/normal/npc_headcrabzombie.sp"
#include "npc/normal/npc_headcrabzombie_fortified.sp"
#include "npc/normal/npc_fastzombie.sp"
#include "npc/normal/npc_fastzombie_fortified.sp"
#include "npc/normal/npc_torsoless_headcrabzombie.sp"
#include "npc/normal/npc_poisonzombie_fortified_giant.sp"
#include "npc/normal/npc_poisonzombie.sp"
#include "npc/normal/npc_poisonzombie_fortified.sp"
#include "npc/normal/npc_last_survivor.sp"
#include "npc/normal/npc_combine_police_pistol.sp"
#include "npc/normal/npc_combine_police_smg.sp"
#include "npc/normal/npc_combine_soldier_ar2.sp"
#include "npc/normal/npc_combine_soldier_shotgun.sp"
#include "npc/normal/npc_combine_soldier_swordsman.sp"
#include "npc/normal/npc_combine_soldier_elite.sp"
#include "npc/normal/npc_combine_soldier_giant_swordsman.sp"
#include "npc/normal/npc_combine_soldier_swordsman_ddt.sp"
#include "npc/normal/npc_combine_soldier_collos_swordsman.sp"
#include "npc/normal/npc_combine_soldier_overlord.sp"
#include "npc/normal/npc_zombie_scout_grave.sp"
#include "npc/normal/npc_zombie_engineer_grave.sp"
#include "npc/normal/npc_zombie_heavy_grave.sp"
#include "npc/normal/npc_flying_armor.sp"
#include "npc/normal/npc_flying_armor_tiny_swords.sp"
#include "npc/normal/npc_kamikaze_demo.sp"
#include "npc/normal/npc_medic_healer.sp"
#include "npc/normal/npc_zombie_heavy_giant_grave.sp"
#include "npc/normal/npc_zombie_spy_grave.sp"
#include "npc/normal/npc_zombie_soldier_grave.sp"
#include "npc/normal/npc_zombie_soldier_minion_grave.sp"
#include "npc/normal/npc_zombie_soldier_giant_grave.sp"
#include "npc/normal/npc_spy_thief.sp"
#include "npc/normal/npc_spy_trickstabber.sp"
#include "npc/normal/npc_spy_half_cloacked_main.sp"
#include "npc/normal/npc_sniper_main.sp"
#include "npc/normal/npc_zombie_demo_main.sp"
#include "npc/normal/npc_medic_main.sp"
#include "npc/normal/npc_zombie_pyro_giant_main.sp"
#include "npc/normal/npc_combine_soldier_deutsch_ritter.sp"
#include "npc/normal/npc_spy_boss.sp"

//XENO

#include "npc/xeno/npc_xeno_headcrabzombie.sp"
#include "npc/xeno/npc_xeno_headcrabzombie_fortified.sp"
#include "npc/xeno/npc_xeno_fastzombie.sp"
#include "npc/xeno/npc_xeno_fastzombie_fortified.sp"
#include "npc/xeno/npc_xeno_torsoless_headcrabzombie.sp"
#include "npc/xeno/npc_xeno_poisonzombie_fortified_giant.sp"
#include "npc/xeno/npc_xeno_poisonzombie.sp"
#include "npc/xeno/npc_xeno_poisonzombie_fortified.sp"
#include "npc/xeno/npc_xeno_last_survivor.sp"
#include "npc/xeno/npc_xeno_combine_police_pistol.sp"
#include "npc/xeno/npc_xeno_combine_police_smg.sp"
#include "npc/xeno/npc_xeno_combine_soldier_ar2.sp"
#include "npc/xeno/npc_xeno_combine_soldier_shotgun.sp"
#include "npc/xeno/npc_xeno_combine_soldier_swordsman.sp"
#include "npc/xeno/npc_xeno_combine_soldier_elite.sp"
#include "npc/xeno/npc_xeno_combine_soldier_giant_swordsman.sp"
#include "npc/xeno/npc_xeno_combine_soldier_swordsman_ddt.sp"
#include "npc/xeno/npc_xeno_combine_soldier_collos_swordsman.sp"
#include "npc/xeno/npc_xeno_combine_soldier_overlord.sp"
#include "npc/xeno/npc_xeno_zombie_scout_grave.sp"
#include "npc/xeno/npc_xeno_zombie_engineer_grave.sp"
#include "npc/xeno/npc_xeno_zombie_heavy_grave.sp"
#include "npc/xeno/npc_xeno_flying_armor.sp"
#include "npc/xeno/npc_xeno_flying_armor_tiny_swords.sp"
#include "npc/xeno/npc_xeno_kamikaze_demo.sp"
#include "npc/xeno/npc_xeno_medic_healer.sp"
#include "npc/xeno/npc_xeno_zombie_heavy_giant_grave.sp"
#include "npc/xeno/npc_xeno_zombie_spy_grave.sp"
#include "npc/xeno/npc_xeno_zombie_soldier_grave.sp"
#include "npc/xeno/npc_xeno_zombie_soldier_minion_grave.sp"
#include "npc/xeno/npc_xeno_zombie_soldier_giant_grave.sp"
#include "npc/xeno/npc_xeno_spy_thief.sp"
#include "npc/xeno/npc_xeno_spy_trickstabber.sp"
#include "npc/xeno/npc_xeno_spy_half_cloacked_main.sp"
#include "npc/xeno/npc_xeno_sniper_main.sp"
#include "npc/xeno/npc_xeno_zombie_demo_main.sp"
#include "npc/xeno/npc_xeno_medic_main.sp"
#include "npc/xeno/npx_xeno_infected_lab_doctor.sp"
#include "npc/xeno/npc_xeno_zombie_pyro_giant_main.sp"
#include "npc/xeno/npc_xeno_combine_soldier_deutsch_ritter.sp"
#include "npc/xeno/npc_xeno_spy_boss.sp"

#include "npc/xeno_lab/npc_xeno_acclaimed_swordsman.sp"
#include "npc/xeno_lab/npc_xeno_early_infected.sp"
#include "npc/xeno_lab/npc_xeno_patient_few.sp"
#include "npc/xeno_lab/npc_xeno_ekas_robo.sp"

#include "npc/special/npc_sawrunner.sp"
#include "npc/special/npc_l4d2_tank.sp"
#include "npc/special/npc_phantom_knight.sp"
#include "npc/special/npc_beheaded_kamikaze.sp"
#include "npc/special/npc_doctor.sp"
#include "npc/special/npc_drdam_special_delivery.sp"
#include "npc/special/npc_drdam_clone.sp"
#include "npc/special/npc_wandering_spirit.sp"
#include "npc/special/npc_vengefull_spirit.sp"
#include "npc/special/npc_fallen_warrior.sp"
#include "npc/special/npc_3650.sp"
#include "npc/special/npc_john_the_allmighty.sp"
#include "npc/special/npc_ravaging_intellect.sp"

#include "npc/btd/npc_bloon.sp"
#include "npc/btd/npc_moab.sp"
#include "npc/btd/npc_bfb.sp"
#include "npc/btd/npc_zomg.sp"
#include "npc/btd/npc_ddt.sp"
#include "npc/btd/npc_bad.sp"
#include "npc/btd/npc_bloonarius.sp"

#include "npc/ally/npc_bob_the_overlord.sp"
#include "npc/ally/npc_necromancy_combine.sp"
#include "npc/ally/npc_necromancy_calcium.sp"
#include "npc/ally/npc_cured_last_survivor.sp"
#include "npc/ally/npc_citizen_new.sp"
#include "npc/ally/npc_allied_sensal_afterimage.sp"
#include "npc/ally/npc_allied_warped_crystal_visualiser.sp"
#include "npc/ally/npc_allied_leper_visualiser.sp"
#include "npc/ally/npc_allied_kahml_afterimage.sp"
#include "npc/ally/npc_allied_kiyru_visualiser.sp"
#include "npc/ally/npc_allied_ritualist_visualiser.sp"

#include "npc/raidmode_bosses/npc_true_fusion_warrior.sp"
#include "npc/raidmode_bosses/npc_blitzkrieg.sp"
#include "npc/raidmode_bosses/npc_god_alaxios.sp"

#if defined RUINA_BASE
//Ruina

//stage 1
#include "npc/ruina/stage1/npc_ruina_theocracy.sp"
#include "npc/ruina/stage1/npc_ruina_adiantum.sp"
#include "npc/ruina/stage1/npc_ruina_lanius.sp"
#include "npc/ruina/stage1/npc_ruina_magia.sp"
#include "npc/ruina/stage1/npc_ruina_helia.sp"
#include "npc/ruina/stage1/npc_ruina_astria.sp"
#include "npc/ruina/stage1/npc_ruina_aether.sp"
#include "npc/ruina/stage1/npc_ruina_europa.sp"
#include "npc/ruina/stage1/npc_ruina_drone.sp"
#include "npc/ruina/stage1/npc_ruina_ruriana.sp"
#include "npc/ruina/stage1/npc_ruina_daedalus.sp"
#include "npc/ruina/stage1/npc_ruina_malius.sp"
#include "npc/ruina/stage1/npc_ruina_laz.sp"

//Stage 2
#include "npc/ruina/stage2/npc_ruina_laniun.sp"
#include "npc/ruina/stage2/npc_ruina_magnium.sp"
#include "npc/ruina/stage2/npc_ruina_heliara.sp"
#include "npc/ruina/stage2/npc_ruina_astriana.sp"
#include "npc/ruina/stage2/npc_ruina_europis.sp"
#include "npc/ruina/stage2/npc_ruina_draedon.sp"
#include "npc/ruina/stage2/npc_ruina_aetheria.sp"
#include "npc/ruina/stage2/npc_ruina_maliana.sp"
#include "npc/ruina/stage2/npc_ruina_ruianus.sp"
#include "npc/ruina/stage2/npc_ruina_lazius.sp"
#include "npc/ruina/stage2/npc_ruina_dronian.sp"
#include "npc/ruina/stage2/npc_ruina_lex.sp"
#include "npc/ruina/stage2/npc_ruina_iana.sp"

//stage 3

#include "npc/ruina/stage3/npc_ruina_loonaris.sp"
#include "npc/ruina/stage3/npc_ruina_magianas.sp"
#include "npc/ruina/stage3/npc_ruina_heliaris.sp"
#include "npc/ruina/stage3/npc_ruina_astrianis.sp"
#include "npc/ruina/stage3/npc_ruina_eurainis.sp"
#include "npc/ruina/stage3/npc_ruina_draeonis.sp"
#include "npc/ruina/stage3/npc_ruina_aetherium.sp"
#include "npc/ruina/stage3/npc_ruina_malianium.sp"
#include "npc/ruina/stage3/npc_ruina_rulius.sp"
#include "npc/ruina/stage3/npc_ruina_lazines.sp"
#include "npc/ruina/stage3/npc_ruina_dronis.sp"
#include "npc/ruina/stage3/npc_ruina_ruliana.sp"

//stage 4

#include "npc/ruina/stage4/npc_ruina_aetherianus.sp"
#include "npc/ruina/stage4/npc_ruina_astrianious.sp"
#include "npc/ruina/stage4/npc_ruina_draconia.sp"
#include "npc/ruina/stage4/npc_ruina_dronianis.sp"
#include "npc/ruina/stage4/npc_ruina_euranionis.sp"
#include "npc/ruina/stage4/npc_ruina_heliarionus.sp"
#include "npc/ruina/stage4/npc_ruina_lazurus.sp"
#include "npc/ruina/stage4/npc_ruina_loonarionus.sp"
#include "npc/ruina/stage4/npc_ruina_magianius.sp"
#include "npc/ruina/stage4/npc_ruina_malianius.sp"
#include "npc/ruina/stage4/npc_ruina_rulianius.sp"
#include "npc/ruina/stage4/npc_ruina_lancelot.sp"


//Special Ruina
#include "npc/ruina/special/npc_ruina_valiant.sp"
#include "npc/ruina/special/npc_ruina_magia_anchor.sp"
#include "npc/ruina/special/npc_ruina_storm_weaver.sp"
#include "npc/ruina/special/npc_ruina_storm_weaver_mid.sp"
#include "npc/raidmode_bosses/npc_twirl.sp"
//#include "npc/raidmode_bosses/npc_levita.sp"

#endif

#include "npc/ally/npc_fractal_cannon_animation.sp"


#include "npc/rogue/chaos_expansion/npc_lelouch.sp"
#include "npc/rogue/chaos_expansion/npc_manipulation_ent.sp"
#include "npc/rogue/chaos_expansion/npc_interstellar_weaver.sp"
#include "npc/rogue/chaos_expansion/npc_interstellar_weaver_mid.sp"

//Alt

#include "npc/alt/npc_alt_medic_charger.sp"
#include "npc/alt/npc_alt_medic_berserker.sp"
#include "npc/alt/npc_alt_medic_supperior_mage.sp"
#include "npc/alt/npc_alt_kahml.sp"
#include "npc/alt/npc_alt_combine_soldier_deutsch_ritter.sp"
#include "npc/alt/npc_alt_sniper_railgunner.sp"
#include "npc/alt/npc_alt_soldier_barrager.sp"
#include "npc/alt/npc_alt_the_shit_slapper.sp"
#include "npc/alt/npc_alt_mecha_engineer.sp"
#include "npc/alt/npc_alt_mecha_heavy.sp"
#include "npc/alt/npc_alt_mecha_heavy_giant.sp"
#include "npc/alt/npc_alt_mecha_pyro_giant_main.sp"
#include "npc/alt/npc_alt_mecha_scout.sp"
#include "npc/alt/npc_alt_combine_soldier_mage.sp"
#include "npc/alt/npc_alt_donnerkrieg.sp"
#include "npc/alt/npc_alt_schwertkrieg.sp"
#include "npc/alt/npc_alt_medic_constructor.sp"
#include "npc/alt/npc_alt_ikunagae.sp"
#include "npc/alt/npc_alt_mecha_soldier_barrager.sp"


#include "npc/medival/npc_medival_militia.sp"
#include "npc/medival/npc_medival_archer.sp"
#include "npc/medival/npc_medival_man_at_arms.sp"
#include "npc/medival/npc_medival_skirmisher.sp"
#include "npc/medival/npc_medival_swordsman.sp"
#include "npc/medival/npc_medival_twohanded_swordsman.sp"
#include "npc/medival/npc_medival_crossbow.sp"
#include "npc/medival/npc_medival_spearmen.sp"
#include "npc/medival/npc_medival_handcannoneer.sp"
#include "npc/medival/npc_medival_elite_skirmisher.sp"
#include "npc/medival/npc_medival_pikeman.sp"
#include "npc/medival/npc_medival_eagle_scout.sp"
#include "npc/medival/npc_medival_samurai.sp"
#include "npc/medival/npc_medival_ram.sp"
#include "npc/medival/npc_medival_scout.sp"
#include "npc/medival/npc_medival_villager.sp"
#include "npc/medival/npc_medival_building.sp"
#include "npc/medival/npc_medival_construct.sp"
#include "npc/medival/npc_medival_champion.sp"
#include "npc/medival/npc_medival_light_cav.sp"
#include "npc/medival/npc_medival_hussar.sp"
#include "npc/medival/npc_medival_knight.sp"
#include "npc/medival/npc_medival_obuch.sp"
#include "npc/medival/npc_medival_monk.sp"
#include "npc/medival/npc_medival_halbadeer.sp"
#include "npc/medival/npc_medival_longbowmen.sp"
#include "npc/medival/npc_medival_arbalest.sp"
#include "npc/medival/npc_medival_brawler.sp"
#include "npc/medival/npc_medival_elite_longbowmen.sp"
#include "npc/medival/npc_medival_eagle_warrior.sp"
#include "npc/medival/npc_medival_cavalary.sp"
#include "npc/medival/npc_medival_paladin.sp"
#include "npc/medival/npc_medival_crossbow_giant.sp"
#include "npc/medival/npc_medival_swordsman_giant.sp"
#include "npc/medival/npc_medival_eagle_giant.sp"
#include "npc/medival/npc_medival_riddenarcher.sp"
#include "npc/medival/npc_medival_son_of_osiris.sp"
#include "npc/medival/npc_medival_achilles.sp"
#include "npc/medival/npc_medival_trebuchet.sp"

#include "npc/cof/npc_addiction.sp"
#include "npc/cof/npc_doctor.sp"
#include "npc/cof/npc_simon.sp"
#include "npc/cof/npc_sewmo.sp"
#include "npc/cof/npc_faster.sp"
#include "npc/cof/npc_psycho.sp"
#include "npc/cof/npc_suicider.sp"
#include "npc/cof/npc_crazylady.sp"
#include "npc/cof/npc_children.sp"
#include "npc/cof/npc_taller.sp"
#include "npc/cof/npc_baby.sp"
#include "npc/cof/npc_stranger.sp"
#include "npc/ally/npc_cured_purnell.sp"
#include "npc/cof/npc_corruptedbarney.sp"
#include "npc/xeno/npc_xeno_malfunctioning_robot.sp"

/*
#include "npc/bonezone/npc_basicbones.sp"
#include "npc/bonezone/npc_beefybones.sp"
#include "npc/bonezone/npc_brittlebones.sp"
#include "npc/bonezone/npc_bigbones.sp"
*/


/*
#include "npc/bunker/npc_gambler.sp"
#include "npc/bunker/npc_pablo.sp"
#include "npc/bunker/npc_dokmedick.sp"
#include "npc/bunker/npc_kapheavy.sp"
#include "npc/bunker/npc_booty_execut.sp"
#include "npc/bunker/npc_sand_slayer.sp"
#include "npc/bunker/npc_payday_cloaker.sp"
#include "npc/bunker/npc_bunker_kahml.sp"
#include "npc/bunker/npc_zerofuse.sp"
#include "npc/bunker/npc_bunker_bot_soldier.sp"
#include "npc/bunker/npc_bunker_bot_sniper.sp"
#include "npc/bunker/npc_bunker_skeleton.sp"
#include "npc/bunker/npc_bunker_small_skeleton.sp"
#include "npc/bunker/npc_bunker_king_skeleton.sp"
#include "npc/bunker/npc_bunker_hhh.sp"
*/


#include "npc/ally/npc_barrack.sp"
#include "npc/ally/npc_barrack_militia.sp"
#include "npc/ally/npc_barrack_archer.sp"
#include "npc/ally/npc_barrack_man_at_arms.sp"
#include "npc/ally/npc_barrack_crossbow.sp"
#include "npc/ally/npc_barrack_swordsman.sp"
#include "npc/ally/npc_barrack_arbelast.sp"
#include "npc/ally/npc_barrack_twohanded.sp"
#include "npc/ally/npc_barrack_longbow.sp"
#include "npc/ally/npc_barrack_handcannoneer.sp"
#include "npc/ally/npc_barrack_champion.sp"
#include "npc/ally/npc_barrack_monk.sp"
#include "npc/ally/npc_barrack_hussar.sp"
#include "npc/ally/npc_barrack_thorns.sp"
#include "npc/ally/npc_barrack_teutonic_knight.sp"
#include "npc/ally/npc_barrack_villager.sp"
#include "npc/ally/npc_barrack_building.sp"

#include "npc/ally/alt_barracks/npc_barrack_alt_basic_mage.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_iku_nagae.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_intermediate_mage.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_advanced_mage.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_railgunner.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_schwertkrieg.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_donnerkrieg.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_holy_knight.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_mecha_barrager.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_barrager.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_mecha_loader.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_crossbowman.sp"
#include "npc/ally/alt_barracks/npc_barrack_alt_scientific_witchery.sp"

#include "npc/ally/combine_barracks/npc_barrack_combine_pistol.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_swordsman.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_smg.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_ar2.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_ddt.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_shotgunner.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_collos.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_elite.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_sniper.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_unit.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_giant_ddt.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_super.sp"
#include "npc/ally/combine_barracks/npc_barrack_combine_commander.sp"

#include "npc/ally/iberia_barracks/npc_barrack_runner.sp"
#include "npc/ally/iberia_barracks/npc_barrack_gunner.sp"
#include "npc/ally/iberia_barracks/npc_barrack_tanker.sp"
#include "npc/ally/iberia_barracks/npc_barrack_rocketeer.sp"
#include "npc/ally/iberia_barracks/npc_barrack_healer.sp"
#include "npc/ally/iberia_barracks/npc_barrack_boomstick.sp"
#include "npc/ally/iberia_barracks/npc_barrack_healtanker.sp"
#include "npc/ally/iberia_barracks/npc_barrack_guards.sp"
#include "npc/ally/iberia_barracks/npc_barrack_elite_gunner.sp"
#include "npc/ally/iberia_barracks/npc_barrack_commando.sp"
#include "npc/ally/iberia_barracks/npc_barrack_headhunter.sp"
#include "npc/ally/iberia_barracks/npc_barrack_inquisitor.sp"
#include "npc/ally/iberia_barracks/npc_barrack_lighthouse_guardian.sp"

#include "npc/ally/npc_nearl_sword.sp"
#include "npc/ally/npc_ritualist.sp"

#include "npc/respawn/npc_stalker_combine.sp"
#include "npc/respawn/npc_stalker_father.sp"
#include "npc/respawn/npc_stalker_goggles.sp"

#include "npc/raidmode_bosses/xeno/npc_infected_silvester.sp"
#include "npc/raidmode_bosses/xeno/npc_infected_goggles.sp"
#include "npc/raidmode_bosses/xeno/npc_nemesis.sp"
#include "npc/raidmode_bosses/xeno/npc_mrx.sp"

#include "npc/seaborn/npc_firsttotalk.sp"
#include "npc/seaborn/npc_seacrawler.sp"
#include "npc/seaborn/npc_seapiercer.sp"
#include "npc/seaborn/npc_seareaper.sp"
#include "npc/seaborn/npc_searunner.sp"
#include "npc/seaborn/npc_seaslider.sp"
#include "npc/seaborn/npc_seaspitter.sp"
#include "npc/seaborn/npc_undertides.sp"
#include "npc/seaborn/npc_seaborn_kazimersch_knight.sp"
#include "npc/seaborn/npc_seaborn_kazimersch_archer.sp"
#include "npc/seaborn/npc_seaborn_kazimersch_beserker.sp"
#include "npc/seaborn/npc_seaborn_kazimersch_longrange.sp"
#include "npc/seaborn/npc_remains.sp"
#include "npc/seaborn/npc_endspeaker_shared.sp"
#include "npc/seaborn/npc_endspeaker_1.sp"
#include "npc/seaborn/npc_endspeaker_2.sp"
#include "npc/seaborn/npc_endspeaker_3.sp"
#include "npc/seaborn/npc_endspeaker_4.sp"
#include "npc/seaborn/npc_netherseafounder.sp"
#include "npc/seaborn/npc_netherseapredator.sp"
#include "npc/seaborn/npc_netherseabrandguider.sp"
#include "npc/seaborn/npc_seaborn_kazimersch_melee_assasin.sp"
#include "npc/seaborn/npc_netherseaspewer.sp"
#include "npc/seaborn/npc_netherseaswarmcaller.sp"
#include "npc/seaborn/npc_netherseareefbreaker.sp"
#include "npc/seaborn/npc_seaborn_scout.sp"
#include "npc/seaborn/npc_seaborn_soldier.sp"
#include "npc/seaborn/npc_citizen_runner.sp"
#include "npc/seaborn/npc_seaborn_pyro.sp"
#include "npc/seaborn/npc_seaborn_demo.sp"
#include "npc/seaborn/npc_seaborn_heavy.sp"
#include "npc/seaborn/npc_seaborn_engineer.sp"
#include "npc/seaborn/npc_seaborn_medic.sp"
#include "npc/seaborn/npc_seaborn_sniper.sp"
#include "npc/seaborn/npc_seaborn_spy.sp"
#include "npc/seaborn/npc_lastknight.sp"
#include "npc/ally/npc_barrack_lastknight.sp"
#include "npc/seaborn/npc_saintcarmen.sp"
#include "npc/seaborn/npc_pathshaper.sp"
#include "npc/seaborn/npc_pathshaper_fractal.sp"
#include "npc/seaborn/npc_tidelinkedbishop.sp"
#include "npc/seaborn/npc_tidelinkedarchon.sp"
#include "npc/seaborn/npc_seaborn_guard.sp"
#include "npc/seaborn/npc_seaborn_defender.sp"
#include "npc/seaborn/npc_seaborn_vanguard.sp"
#include "npc/seaborn/npc_seaborn_caster.sp"
#include "npc/seaborn/npc_seaborn_specialist.sp"
#include "npc/seaborn/npc_seaborn_supporter.sp"
#include "npc/seaborn/npc_isharmla.sp"
#include "npc/seaborn/npc_isharmla_trans.sp"

#include "npc/raidmode_bosses/seaborn/npc_stella.sp"
#include "npc/raidmode_bosses/seaborn/npc_karlas.sp"
#include "npc/raidmode_bosses/seaborn/npc_bob_the_first_last_savior.sp"

#include "npc/expidonsa/npc_benera.sp"
#include "npc/expidonsa/npc_pental.sp"
#include "npc/expidonsa/npc_defanda.sp"
#include "npc/expidonsa/npc_selfam_ire.sp"
#include "npc/expidonsa/npc_vaus_magica.sp"
#include "npc/expidonsa/npc_benera_pistoleer.sp"
#include "npc/expidonsa/npc_diversionistico.sp"
#include "npc/expidonsa/npc_heavy_punuel.sp"
#include "npc/expidonsa/npc_sergeant_ideal.sp"
#include "npc/expidonsa/npc_rifal_manu.sp"
#include "npc/expidonsa/npc_siccerino.sp"
#include "npc/expidonsa/npc_soldine_prototype.sp"
#include "npc/expidonsa/npc_soldine.sp"
#include "npc/expidonsa/npc_sniponeer.sp"
#include "npc/expidonsa/npc_enegakapus.sp"
#include "npc/expidonsa/npc_ega_bunar.sp"
#include "npc/expidonsa/npc_protecta.sp"

#include "npc/expidonsa/npc_captino_agentus.sp"
#include "npc/expidonsa/npc_dualrea.sp"
#include "npc/expidonsa/npc_guardus.sp"
#include "npc/expidonsa/npc_vaus_techicus.sp"
#include "npc/expidonsa/npc_minigun_assisa.sp"
#include "npc/expidonsa/npc_erasus.sp"
#include "npc/expidonsa/npc_gianttankus.sp"
#include "npc/expidonsa/npc_helena.sp"
#include "npc/expidonsa/npc_ignitus.sp"
#include "npc/expidonsa/npc_speedus_adivus.sp"
#include "npc/expidonsa/npc_anfuhrer_eisenhard.sp"
#include "npc/raidmode_bosses/npc_sensal.sp"

#include "npc/ally/npc_vip_building.sp"
#include "npc/rogue/npc_overlord_rogue.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_whiteflower.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_acclaimed_swordsman.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_ekas_piloteer.sp"
#include "npc/rogue/whiteflower_rogue/npc_ekas_robo.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_extreme_knight_giant.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_flowering_darkness.sp"
#include "npc/rogue/whiteflower_rogue/npc_combine_raging_blader.sp"
#include "npc/raidmode_bosses/npc_bladedance.sp"
#include "npc/raidmode_bosses/npc_the_messenger.sp"
#include "npc/raidmode_bosses/npc_chaos_kahmlstein.sp"

#include "npc/raidmode_bosses/npc_the_purge.sp"

#include "npc/interitus/desert/npc_ahim.sp"
#include "npc/interitus/desert/npc_inabdil.sp"
#include "npc/interitus/desert/npc_khazaan.sp"
#include "npc/interitus/desert/npc_sakratan.sp"
#include "npc/interitus/desert/npc_yadeam.sp"
#include "npc/interitus/desert/npc_rajul.sp"
#include "npc/interitus/desert/npc_qanaas.sp"
#include "npc/interitus/desert/npc_atilla.sp"
#include "npc/interitus/desert/npc_ancient_demon.sp"

#include "npc/interitus/winter/npc_winter_sniper.sp"
#include "npc/interitus/winter/npc_ziberian_miner.sp"
#include "npc/interitus/winter/npc_snowey_gunner.sp"
#include "npc/interitus/winter/npc_freezing_cleaner.sp"
#include "npc/interitus/winter/npc_airborn_explorer.sp"
#include "npc/interitus/winter/npc_arctic_mage.sp"
#include "npc/interitus/winter/npc_skin_hunter.sp"
#include "npc/interitus/winter/npc_frost_hunter.sp"
#include "npc/interitus/winter/npc_irritated_person.sp"

#include "npc/interitus/anarchy/npc_ransacker.sp"
#include "npc/interitus/anarchy/npc_runover.sp"
#include "npc/interitus/anarchy/npc_hitman.sp"
#include "npc/interitus/anarchy/npc_mad_doctor.sp"
#include "npc/interitus/anarchy/npc_abomination.sp"
#include "npc/interitus/anarchy/npc_enforcer.sp"
#include "npc/interitus/anarchy/npc_braindead.sp"
#include "npc/interitus/anarchy/npc_behemoth.sp"
#include "npc/interitus/anarchy/npc_absolute_incinirator.sp"

#include "npc/interitus/forest/npc_archosauria.sp"
#include "npc/interitus/forest/npc_aslan.sp"
#include "npc/interitus/forest/npc_perro.sp"
#include "npc/interitus/forest/npc_caprinae.sp"
#include "npc/interitus/forest/npc_liberi.sp"
#include "npc/interitus/forest/npc_ursus.sp"
#include "npc/interitus/forest/npc_aegir.sp"
#include "npc/interitus/forest/npc_cautus.sp"
#include "npc/interitus/forest/npc_vulpo.sp"
#include "npc/interitus/forest/npc_majorsteam.sp"

#include "npc/void/npc_spawn_void_portal.sp"
#include "npc/void/npc_void_base.sp"
#include "npc/void/npc_voided_diversionistico.sp"
//1-15
#include "npc/void/early/npc_ealing.sp"
#include "npc/void/early/npc_framing_voider.sp"
#include "npc/void/early/npc_growing_exat.sp"
#include "npc/void/early/npc_mutating_blob.sp"
#include "npc/void/early/npc_void_spreader.sp"
#include "npc/void/early/npc_void_infestor.sp"
#include "npc/void/early/npc_void_crust.sp"
#include "npc/void/early/npc_void_carrier.sp"
#include "npc/void/early/npc_void_ixufan.sp"

#include "npc/void/earlymid/npc_enframed_voider.sp"
#include "npc/void/earlymid/npc_blood_pollutor.sp"
#include "npc/void/earlymid/npc_voided_expidonsan_fortifier.sp"
#include "npc/void/earlymid/npc_void_particle.sp"
#include "npc/void/earlymid/npc_hosting_blob.sp"
#include "npc/void/earlymid/npc_blobbing_monster.sp"
#include "npc/void/earlymid/npc_void_sprayer.sp"
#include "npc/void/earlymid/npc_void_encasulator.sp"


#include "npc/void/midlate/npc_void_expidonsan_container.sp"
#include "npc/void/midlate/npc_void_expidonsan_cleaner.sp"
#include "npc/void/midlate/npc_void_sacraficer.sp"
#include "npc/void/midlate/npc_voiding_bedrock.sp"
#include "npc/void/midlate/npc_void_heavy_perisher.sp"
#include "npc/void/midlate/npc_void_minigate_keeper.sp"
#include "npc/void/midlate/npc_void_brooding_petra.sp"


#include "npc/void/late/npc_void_erasus.sp"
#include "npc/void/late/npc_void_kunul.sp"
#include "npc/void/late/npc_void_total_growth.sp"
#include "npc/void/late/npc_voids_offspring.sp"
#include "npc/void/late/npc_void_rejuvinator.sp"
#include "npc/void/late/npc_void_speechless.sp"
#include "npc/raidmode_bosses/npc_void_unspeakable.sp"

#include "npc/rogue/npc_rogue_condition.sp"
#include "npc/rogue/chaos/npc_goggles_follower.sp"
#include "npc/rogue/chaos/npc_thehunter.sp"

#include "npc/rogue/chaos/npc_finalhunter.sp"
#include "npc/rogue/chaos/npc_kahmlstein_follower.sp"
#include "npc/rogue/chaos/npc_chaos_mage.sp"
#include "npc/rogue/chaos/npc_chaos_supporter.sp"
#include "npc/rogue/chaos/npc_chaos_insane.sp"
#include "npc/rogue/chaos/npc_chaos_sick_knight.sp"
#include "npc/rogue/chaos/npc_chaos_injured_cultist.sp"
#include "npc/rogue/chaos/npc_vhxis.sp"
#include "npc/rogue/chaos/npc_duck_follower.sp"


#include "npc/rogue/chaos_expansion/npc_evil_chaos_demon.sp"
#include "npc/rogue/chaos_expansion/npc_chaos_swordsman.sp"
#include "npc/rogue/chaos_expansion/npc_nightmare_swordsman.sp"
#include "npc/rogue/chaos_expansion/npc_bob_first_follower.sp"
#include "npc/rogue/chaos_expansion/npc_twirl_follower.sp"
#include "npc/rogue/chaos_expansion/npc_hallam_great_demon.sp"
#include "npc/rogue/chaos_expansion/npc_Ihanal_demon_whisperer.sp"
#include "npc/rogue/chaos_expansion/npc_majorvoided.sp"


#if defined BONEZONE_BASE
#include "npc/bonezone/wave15/npc_basicbones.sp"
#include "npc/bonezone/wave15/npc_beefybones.sp"
#include "npc/bonezone/wave15/npc_brittlebones.sp"
#include "npc/bonezone/wave15/npc_bigbones.sp"
//////
#include "npc/bonezone/wave30/npc_mrmolotov.sp"
#include "npc/bonezone/wave30/npc_rattler.sp"
#include "npc/bonezone/wave30/npc_slugger.sp"
#include "npc/bonezone/wave30/npc_criminal.sp"
#include "npc/bonezone/wave30/npc_boss_godfather.sp"
//////
#include "npc/bonezone/wave45/npc_buccaneerbones.sp"
#include "npc/bonezone/wave45/npc_calciumcorsair.sp"
#include "npc/bonezone/wave45/npc_undeaddeckhand.sp"
#include "npc/bonezone/wave45/npc_aleraiser.sp"
#include "npc/bonezone/wave45/npc_flintlock.sp"
#include "npc/bonezone/wave45/npc_boss_captain.sp"
//////
#include "npc/bonezone/wave60/npc_archmage.sp"
#include "npc/bonezone/wave60/npc_necromancer.sp"
#include "npc/bonezone/wave60/npc_skeletalsaint.sp"
#include "npc/bonezone/wave60/npc_brewer.sp"
#include "npc/bonezone/wave60/npc_squire.sp"
#include "npc/bonezone/wave60/npc_jester.sp"
#include "npc/bonezone/wave60/npc_peasant.sp"
#include "npc/bonezone/wave60/npc_boss_executioner.sp"
//////
#include "npc/raidmode_bosses/ssb/npc_ssb.sp"
#include "npc/raidmode_bosses/ssb/npc_ssb_finale_phase1.sp" 
#include "npc/special/npc_reaper.sp"
#endif

#include "npc/mutations/truesurvival/npc_nightmare.sp"
#include "npc/mutations/truesurvival/npc_petrisisbaron.sp"
#include "npc/mutations/truesurvival/npc_sphynx.sp"
#include "npc/mutations/truesurvival/npc_zombine.sp"
#include "npc/mutations/truesurvival/npc_zmain_headcrabzombie.sp"
#include "npc/mutations/truesurvival/npc_zmain_poisonzombie.sp"
#include "npc/mutations/truesurvival/npc_zmain_headcrab.sp"
#include "npc/mutations/truesurvival/npc_headcrab.sp"
#include "npc/mutations/truesurvival/npc_poisonheadcrab.sp"
#include "npc/mutations/randomboss/npc_boss_battle_only.sp"



#include "npc/iberia_expidonsa/npc_iberia_base.sp"
#include "npc/iberia_expidonsa/npc_iberia_beacon.sp"
#include "npc/iberia_expidonsa/npc_iberia_lighthouse.sp"
#include "npc/iberia_expidonsa/npc_beacon_constructor.sp"
#include "npc/iberia_expidonsa/npc_huirgrajo.sp"

#include "npc/iberia_expidonsa/wave_15/npc_irani.sp"
#include "npc/iberia_expidonsa/wave_15/npc_cambino.sp"
#include "npc/iberia_expidonsa/wave_15/npc_kinat.sp"
#include "npc/iberia_expidonsa/wave_15/npc_ginus.sp"
#include "npc/iberia_expidonsa/wave_15/npc_speedus_initus.sp"
#include "npc/iberia_expidonsa/wave_15/npc_anania.sp"
#include "npc/iberia_expidonsa/wave_15/npc_victorian.sp"
#include "npc/iberia_expidonsa/wave_15/npc_inqusitor_iidutas.sp"


#include "npc/iberia_expidonsa/wave_30/npc_vivintu.sp"
#include "npc/iberia_expidonsa/wave_30/npc_cenula.sp"
#include "npc/iberia_expidonsa/wave_30/npc_kumbai.sp"
#include "npc/iberia_expidonsa/wave_30/npc_speedus_instantus.sp"
#include "npc/iberia_expidonsa/wave_30/npc_combastia.sp"
#include "npc/iberia_expidonsa/wave_30/npc_iberia_morato.sp"
#include "npc/iberia_expidonsa/wave_30/npc_sea_xploder.sp"
#include "npc/iberia_expidonsa/wave_30/npc_anti_sea_robot.sp"


#include "npc/iberia_expidonsa/wave_45/npc_ranka_s.sp"
#include "npc/iberia_expidonsa/wave_45/npc_murdarato.sp"
#include "npc/iberia_expidonsa/wave_45/npc_elite_kinat.sp"
#include "npc/iberia_expidonsa/wave_45/npc_seaborn_eradicator.sp"
#include "npc/iberia_expidonsa/wave_45/npc_speedus_itus.sp"
#include "npc/iberia_expidonsa/wave_45/npc_sentinel.sp"
#include "npc/iberia_expidonsa/wave_45/npc_destructius.sp"
#include "npc/iberia_expidonsa/wave_45/npc_ironborus.sp"


#include "npc/iberia_expidonsa/wave_60/npc_death_marker.sp"
#include "npc/iberia_expidonsa/wave_60/npc_runaka.sp"
#include "npc/iberia_expidonsa/wave_60/npc_speedus_elitus.sp"
#include "npc/iberia_expidonsa/wave_60/npc_sea_dryer.sp"
#include "npc/iberia_expidonsa/wave_60/npc_inqusitor_irene.sp"


#include "npc/raidmode_bosses/iberia/npc_nemal.sp"
#include "npc/raidmode_bosses/iberia/npc_raid_silvester.sp"

//Victoria
//special
#include "npc/victoria/npc_invisible_trigger.sp"
#include "npc/victoria/npc_victorian_factory.sp"
#include "npc/victoria/npc_victoria_tacticalprotector.sp"
#include "npc/victoria/npc_victoria_tacticalunit.sp"
#include "npc/victoria/npc_test_dummy.sp"
#include "npc/victoria/npc_baguettus.sp"

//Wave 1~10
#include "npc/victoria/npc_batter.sp"
#include "npc/victoria/npc_charger.sp"
#include "npc/victoria/npc_teslar.sp"
#include "npc/victoria/npc_victorian_vanguard.sp"
#include "npc/victoria/npc_supplier.sp"
#include "npc/victoria/npc_ballista.sp"
#include "npc/victoria/npc_igniter.sp"
#include "npc/victoria/npc_grenadier.sp"
#include "npc/victoria/npc_squadleader.sp"
#include "npc/victoria/npc_signaller.sp"

//wave 11~20
#include "npc/victoria/npc_humbee.sp"
#include "npc/victoria/npc_shotgunner.sp"
#include "npc/victoria/npc_bulldozer.sp"
#include "npc/victoria/npc_hardener.sp"
#include "npc/victoria/npc_raider.sp"
#include "npc/victoria/npc_zapper.sp"
#include "npc/victoria/npc_payback.sp"
#include "npc/victoria/npc_blocker.sp"
#include "npc/victoria/npc_destructor.sp"
#include "npc/victoria/npc_ironshield.sp"
#include "npc/victoria/npc_aviator.sp"

//wave 21~30
#include "npc/victoria/npc_basebreaker.sp"
#include "npc/victoria/npc_booster.sp"
#include "npc/victoria/npc_scorcher.sp"
#include "npc/victoria/npc_mowdown.sp"
#include "npc/victoria/npc_mechafist.sp"
#include "npc/victoria/npc_assaulter.sp"
#include "npc/victoria/npc_antiarmor_infantry.sp"
#include "npc/victoria/npc_mortar.sp"
#include "npc/victoria/npc_victorian_artillerist.sp"
#include "npc/victoria/npc_bombcart.sp"
#include "npc/victoria/npc_breachcart.sp"
#include "npc/victoria/npc_birdeye.sp"
#include "npc/victoria/npc_harbringer.sp"
#include "npc/victoria/npc_bigpipe.sp"

//wave 31~40
#include "npc/victoria/npc_caffeinator.sp"
#include "npc/victoria/npc_welder.sp"
#include "npc/victoria/npc_mechanist.sp"
#include "npc/victoria/npc_avangard.sp"
#include "npc/victoria/npc_tanker.sp"
#include "npc/victoria/npc_pulverizer.sp"
#include "npc/victoria/npc_ambusher.sp"
#include "npc/victoria/npc_taser.sp"
#include "npc/victoria/npc_victorian_tank.sp"
#include "npc/victoria/npc_drive_in_my_car.sp"
#include "npc/victoria/npc_victoria_radiomast.sp"
#include "npc/victoria/npc_radioguard.sp"
#include "npc/victoria/npc_radio_repair.sp"
#include "npc/victoria/npc_victorian_moru.sp"
#include "npc/victoria/npc_victorian_fragments.sp"

//raidbosses
#include "npc/raidmode_bosses/victoria/npc_the_atomizer.sp"
#include "npc/raidmode_bosses/victoria/npc_the_wall.sp"
#include "npc/raidmode_bosses/victoria/npc_harrison.sp"
#include "npc/raidmode_bosses/victoria/npc_castellan.sp"

//Special
#include "npc/baka/npc_cybergrind_gm.sp"
#include "npc/baka/npc_invisible_trigger_man.sp"
#include "npc/baka/raidbosses/npc_cyber_messenger.sp"
#include "npc/baka/raidbosses/npc_true_cyber_warrior.sp"
#include "npc/baka/raidbosses/npc_village_god_alaxios.sp"

//Matrix Enemies
#include "npc/matrix/15/npc_agentalan.sp"
#include "npc/matrix/15/npc_agentalexander.sp"
#include "npc/matrix/15/npc_agentchase.sp"
#include "npc/matrix/15/npc_agentdave.sp"
#include "npc/matrix/15/npc_agentgraham.sp"
#include "npc/matrix/15/npc_agentjames.sp"
#include "npc/matrix/15/npc_agentjohn.sp"
#include "npc/matrix/15/npc_agentsteve.sp"
#include "npc/matrix/15/npc_antiviral_programm.sp"
#include "npc/matrix/30/npc_agenteric.sp"
#include "npc/matrix/30/npc_agentjack.sp"
#include "npc/matrix/30/npc_agentjim.sp"
#include "npc/matrix/30/npc_agentjosh.sp"
#include "npc/matrix/30/npc_agentkenneth.sp"
#include "npc/matrix/30/npc_agentpaul.sp"
#include "npc/matrix/30/npc_agenttyler.sp"
#include "npc/matrix/30/npc_agentwayne.sp"
#include "npc/matrix/30/npc_merovingian.sp"
#include "npc/matrix/45/npc_agentben.sp"
#include "npc/matrix/45/npc_agentchad.sp"
#include "npc/matrix/45/npc_agentchris.sp"
#include "npc/matrix/45/npc_agentdick.sp"
#include "npc/matrix/45/npc_agentian.sp"
#include "npc/matrix/45/npc_agentjackson.sp"
#include "npc/matrix/45/npc_agentmike.sp"
#include "npc/matrix/45/npc_agentsam.sp"
#include "npc/matrix/45/npc_agentzack.sp"
#include "npc/matrix/60/npc_agentconnor.sp"
#include "npc/matrix/60/npc_agenthenry.sp"
#include "npc/matrix/60/npc_agentjeremy.sp"
#include "npc/matrix/60/npc_agentjones.sp"
#include "npc/matrix/60/npc_agentkurt.sp"
#include "npc/matrix/60/npc_agentlogan.sp"
#include "npc/matrix/60/npc_agentross.sp"
#include "npc/matrix/60/npc_agentspencer.sp"
#include "npc/matrix/60/npc_agenttodd.sp"

//Matrix Giants
#include "npc/matrix/giants/npc_giant_haste.sp"
#include "npc/matrix/giants/npc_giant_knockout.sp"
#include "npc/matrix/giants/npc_giant_reflector.sp"
#include "npc/matrix/giants/npc_giant_regeneration.sp"

//Matrix Raids
#include "npc/matrix/raids/npc_agentjohnson.sp"
#include "npc/matrix/raids/npc_agentthompson.sp"
#include "npc/matrix/raids/npc_twins.sp"
#include "npc/matrix/raids/npc_agent_smith.sp"

//Matrix Freeplay Enemies
#include "npc/matrix/freeplay/npc_freeplay_agentdave.sp"
#include "npc/matrix/freeplay/npc_freeplay_agentwayne.sp"
#include "npc/matrix/freeplay/npc_freeplay_agentian.sp"
#include "npc/matrix/freeplay/npc_freeplay_agentspencer.sp"

//Combine Hell Mutation
#include "npc/mutations/combinehell/other/npc_hunter.sp"
#include "npc/mutations/combinehell/other/npc_merlton.sp"
#include "npc/mutations/combinehell/other/npc_combine_lost_knight.sp"
#include "npc/mutations/combinehell/other/npc_omega_raid.sp"
#include "npc/mutations/combinehell/other/npc_bob_follower.sp"
#include "npc/mutations/combinehell/seaborn/npc_seaborn_combine_police_pistol.sp"
#include "npc/mutations/combinehell/seaborn/npc_seaborn_combine_police_smg.sp"
#include "npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_elite.sp"
#include "npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_ar2.sp"
#include "npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_shotgun.sp"
#include "npc/mutations/combinehell/void/npc_voided_combine_police_pistol.sp"
#include "npc/mutations/combinehell/void/npc_voided_combine_police_smg.sp"
#include "npc/mutations/combinehell/void/npc_voided_combine_soldier_elite.sp"
#include "npc/mutations/combinehell/void/npc_voided_combine_soldier_ar2.sp"
#include "npc/mutations/combinehell/void/npc_voided_combine_soldier_shotgun.sp"

#include "npc/voices/npc_stalker_wisp.sp"

// Freeplay
#include "npc/mutations/freeplay/npc_dimensionfrag.sp"
#include "npc/mutations/freeplay/npc_immutableheavy.sp"
#include "npc/mutations/freeplay/npc_vanishingmatter.sp"
#include "npc/mutations/freeplay/npc_annoying_spirit.sp"
#include "npc/mutations/freeplay/npc_darkenedheavy.sp"

#include "npc/construction/npc_base_building.sp"
#include "npc/construction/npc_material_cash.sp"
#include "npc/construction/npc_material_copper.sp"
#include "npc/construction/npc_material_crystal.sp"
#include "npc/construction/npc_material_iron.sp"
#include "npc/construction/npc_material_jalan.sp"
#include "npc/construction/npc_material_ossunia.sp"
#include "npc/construction/npc_material_stone.sp"
#include "npc/construction/npc_material_wizuh.sp"
#include "npc/construction/npc_material_wood.sp"
#include "npc/construction/npc_rogue_expi_building.sp"
#include "npc/construction/npc_material_gift.sp"

// April Fools
#include "npc/aprilfools/npc_packapunch.sp"
#include "npc/aprilfools/npc_perkmachine.sp"
#include "npc/aprilfools/npc_ammobox.sp"
#include "npc/aprilfools/npc_male07.sp"
#include "npc/aprilfools/npc_spiritrunner.sp"
#include "npc/aprilfools/npc_error_melee.sp"
#include "npc/aprilfools/npc_error_ranged.sp"
#include "npc/aprilfools/npc_toddhoward.sp"
#include "npc/aprilfools/npc_kevinmery2009.sp"
#include "npc/aprilfools/npc_red_heavy.sp"
#include "npc/aprilfools/npc_blue_heavy.sp"
#include "npc/aprilfools/npc_cyan_heavy.sp"
#include "npc/aprilfools/npc_green_heavy.sp"
#include "npc/aprilfools/npc_orange_heavy.sp"
#include "npc/aprilfools/npc_yellow_heavy.sp"
#include "npc/aprilfools/npc_purple_heavy.sp"
#include "npc/aprilfools/npc_sentrybuster.sp"
#include "npc/aprilfools/npc_troll_ar2.sp"
#include "npc/aprilfools/npc_troll_pistol.sp"
#include "npc/aprilfools/npc_troll_rpg.sp"
#include "npc/aprilfools/npc_troll_melee.sp"

#include "npc/construction/enemies/npc_eirasus.sp"
#include "npc/construction/enemies/npc_haltera.sp"
#include "npc/construction/enemies/npc_flaigus.sp"
#include "npc/construction/enemies/npc_biggun_assisa.sp"
#include "npc/construction/enemies/npc_hia_rejuvinator.sp"
#include "npc/construction/enemies/npc_cuttus_siccino.sp"
#include "npc/construction/enemies/npc_armsa_manu.sp"
#include "npc/construction/enemies/npc_speedus_absolutos.sp"
#include "npc/construction/enemies/npc_vaus_shaldus.sp"
#include "npc/construction/enemies/npc_soldinus_ilus.sp"
#include "npc/construction/enemies/npc_selfam_scythus.sp"
#include "npc/construction/enemies/npc_diversionistico_elitus.sp"
#include "npc/construction/enemies/npc_zilius.sp"
#include "npc/construction/enemies/npc_zeina_prison.sp"
#include "npc/construction/enemies/npc_zeina_freed.sp"

//Aperture
#include "npc/aperture/npc_base_aperture.sp"
#include "npc/aperture/npc_base_refragmented.sp"
#include "npc/aperture/10/npc_aperture_combatant.sp"
#include "npc/aperture/10/npc_aperture_shotgunner.sp"
#include "npc/aperture/10/npc_aperture_jumper.sp"
#include "npc/aperture/10/npc_aperture_phaser.sp"
#include "npc/aperture/10/npc_aperture_specialist.sp"
#include "npc/aperture/10/npc_aperture_sniper.sp"
#include "npc/aperture/10/npc_aperture_huntsman.sp"
#include "npc/aperture/10/npc_last_survivor_science.sp"
#include "npc/aperture/20/npc_aperture_combatant_v2.sp"
#include "npc/aperture/20/npc_aperture_huntsman_v2.sp"
#include "npc/aperture/20/npc_aperture_jumper_v2.sp"
#include "npc/aperture/20/npc_aperture_phaser_v2.sp"
#include "npc/aperture/20/npc_aperture_shotgunner_v2.sp"
#include "npc/aperture/20/npc_aperture_sniper_v2.sp"
#include "npc/aperture/20/npc_aperture_specialist_v2.sp"
#include "npc/aperture/20/npc_aperture_supporter.sp"
#include "npc/aperture/20/npc_aperture_devastator.sp"
#include "npc/aperture/20/npc_aperture_demolisher.sp"
#include "npc/aperture/20/npc_aperture_minigunner.sp"
#include "npc/aperture/20/npc_aperture_repulsor.sp"
#include "npc/aperture/20/npc_aperture_exterminator.sp"
#include "npc/aperture/30/npc_aperture_combatant_perfected.sp"
#include "npc/aperture/30/npc_aperture_shotgunner_perfected.sp"
#include "npc/aperture/30/npc_aperture_huntsman_perfected.sp"
#include "npc/aperture/30/npc_aperture_phaser_perfected.sp"
#include "npc/aperture/30/npc_aperture_sniper_perfected.sp"
#include "npc/aperture/30/npc_aperture_specialist_perfected.sp"
#include "npc/aperture/30/npc_aperture_jumper_perfected.sp"
#include "npc/aperture/30/npc_aperture_demolisher_v2.sp"
#include "npc/aperture/30/npc_aperture_devastator_v2.sp"
#include "npc/aperture/30/npc_aperture_minigunner_v2.sp"
#include "npc/aperture/30/npc_aperture_repulsor_v2.sp"
#include "npc/aperture/30/npc_aperture_supporter_v2.sp"
#include "npc/aperture/30/npc_aperture_builder.sp"
#include "npc/aperture/30/npc_aperture_sentry.sp"
#include "npc/aperture/30/npc_aperture_dispenser.sp"
#include "npc/aperture/30/npc_aperture_teleporter.sp"
#include "npc/aperture/30/npc_aperture_container.sp"
#include "npc/aperture/30/npc_aperture_spokesman.sp"
#include "npc/aperture/40/npc_aperture_traveller.sp"
#include "npc/aperture/40/npc_aperture_demolisher_perfected.sp"
#include "npc/aperture/40/npc_aperture_devastator_perfected.sp"
#include "npc/aperture/40/npc_aperture_minigunner_perfected.sp"
#include "npc/aperture/40/npc_aperture_repulsor_perfected.sp"
#include "npc/aperture/40/npc_aperture_supporter_perfected.sp"
#include "npc/aperture/40/npc_aperture_researcher.sp"
#include "npc/aperture/refragmented/npc_refragmented_headcrabzombie.sp"
#include "npc/aperture/refragmented/npc_refragmented_fastzombie.sp"
#include "npc/aperture/refragmented/npc_refragmented_poisonzombie.sp"
#include "npc/aperture/refragmented/npc_refragmented_combine_police_pistol.sp"
#include "npc/aperture/refragmented/npc_refragmented_combine_police_smg.sp"
#include "npc/aperture/refragmented/npc_refragmented_combine_soldier_ar2.sp"
#include "npc/aperture/refragmented/npc_refragmented_combine_soldier_elite.sp"
#include "npc/aperture/refragmented/npc_refragmented_heavy.sp"
#include "npc/aperture/refragmented/npc_refragmented_medic.sp"
#include "npc/aperture/refragmented/npc_refragmented_spy.sp"
#include "npc/aperture/refragmented/npc_refragmented_parasihtta.sp"
#include "npc/aperture/refragmented/npc_refragmented_hostis.sp"
#include "npc/aperture/refragmented/npc_refragmented_defectio.sp"
#include "npc/aperture/npc_portalgate.sp"
#include "npc/aperture/npc_talker.sp"
#include "npc/aperture/giants/npc_aperture_collector.sp"
#include "npc/aperture/giants/npc_aperture_fueler.sp"
#include "npc/aperture/giants/npc_aperture_halter.sp"
#include "npc/aperture/giants/npc_aperture_suppressor.sp"
#include "npc/aperture/raids/npc_cat.sp"
#include "npc/aperture/raids/npc_aris.sp"
#include "npc/aperture/npc_aris_makeshift_beacon.sp"
#include "npc/aperture/raids/npc_chimera.sp"
#include "npc/aperture/refragmented/npc_chimeraboss_refragmented_winter_sniper.sp"
#include "npc/aperture/refragmented/npc_chimeraboss_refragmented_frost_hunter.sp"
#include "npc/aperture/raids/npc_vincent.sp"
#include "npc/aperture/npc_vincent_beacon.sp"

#include "npc/rogue/rouge3/npc_umbral_ltzens.sp"
#include "npc/rogue/rouge3/npc_umbral_refract.sp"
#include "npc/rogue/rouge3/npc_umbral_koulm.sp"
#include "npc/rogue/rouge3/npc_hhh.sp"
#include "npc/rogue/rouge3/npc_gentlespy.sp"
#include "npc/rogue/rouge3/npc_christianbrutalsniper.sp"
#include "npc/rogue/rouge3/npc_umbral_spuud.sp"
#include "npc/rogue/rouge3/npc_umbral_keitosis.sp"
#include "npc/rogue/rouge3/npc_almagest_seinr.sp"
#include "npc/rogue/rouge3/npc_almagest_jkei.sp"
#include "npc/rogue/rouge3/npc_almagest_jkei_drone.sp"
#include "npc/rogue/rouge3/npc_randomizer.sp"
#include "npc/rogue/rouge3/randomizer/npc_randomizer_base_flamethrower.sp"
#include "npc/rogue/rouge3/randomizer/npc_randomizer_base_huntsman.sp"
#include "npc/rogue/rouge3/randomizer/npc_randomizer_base_southern_hospitality.sp"
#include "npc/rogue/rouge3/npc_boss_reila.sp"
#include "npc/rogue/rouge3/npc_boss_reila_beacon.sp"
#include "npc/rogue/rouge3/npc_reila_follower.sp"
#include "npc/rogue/rouge3/npc_umbral_automaton.sp"
#include "npc/rogue/rouge3/npc_umbral_rouam.sp"
#include "npc/rogue/rouge3/npc_omega_follower.sp"
#include "npc/rogue/rouge3/npc_vhxis_follower.sp"
#include "npc/rogue/rouge3/npc_shadow_flowering_darkness.sp"
#include "npc/rogue/rouge3/npc_shadowing_darkness.sp"
#include "npc/rogue/rouge3/npc_torn_umbral_gate.sp"
#include "npc/rogue/rouge3/npc_umbral_whiteflower.sp"
#include "npc/construction/logic_win_timer.sp"
#include "npc/construction/npc_sensal_follower.sp"
#include "npc/construction/npc_overlord_follower.sp"
#include "npc/construction/construction2/npc_barbaric_teardown.sp"
#include "npc/construction/construction2/npc_skilled_crossbowman.sp"
#include "npc/construction/construction2/npc_demon_devoter.sp"
#include "npc/construction/npc_dungeon_loot.sp"

// Foolish
#include "npc/foolish/npc_easy_god_alaxios.sp"
#include "npc/foolish/npc_easy_bob_the_first_last_savior.sp"

// Gmod ZS
#include "npc/gmod_zs/15/npc_zs_zombie.sp"
#include "npc/gmod_zs/15/npc_zs_headcrab.sp"
#include "npc/gmod_zs/15/npc_zs_ghoul.sp"
#include "npc/gmod_zs/15/npc_zs_skeleton.sp"
#include "npc/gmod_zs/15/npc_zs_fast_zombie.sp"
#include "npc/gmod_zs/15/npc_zs_bloated_zombie.sp"
#include "npc/gmod_zs/15/npc_zs_shadow_walker.sp"
#include "npc/gmod_zs/15/npc_zs_poisonheadcrab.sp"
#include "npc/gmod_zs/15/npc_zs_poisonzombie.sp"
#include "npc/gmod_zs/30/npc_zs_gore_blaster.sp"
#include "npc/gmod_zs/30/npc_zs_elder_ghoul.sp"
#include "npc/gmod_zs/30/npc_zs_fast_headcrab.sp"
#include "npc/gmod_zs/30/npc_zs_vile_bloated_zombie.sp"
#include "npc/gmod_zs/30/npc_zs_headcrabzombie.sp"
#include "npc/gmod_zs/30/npc_zs_fastheadcrab_zombie.sp"
#include "npc/gmod_zs/30/npc_zs_poisonheadcrab_zombie.sp"
#include "npc/gmod_zs/30/npc_zs_runner.sp"
#include "npc/gmod_zs/30/npc_zs_spitter.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_scout.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_soldier_pickaxe.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_spy.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_heavy.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_soldier.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_sniper_jarate.sp"
#include "npc/gmod_zs/45/npc_zs_ninja_zombie_spy.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_demoknight.sp"
#include "npc/gmod_zs/45/npc_zs_kamikaze_demo.sp"
#include "npc/gmod_zs/45/npc_zs_zombie_engineer.sp"
#include "npc/gmod_zs/45/npc_zs_medic_healer.sp"
#include "npc/gmod_zs/45/npc_zs_huntsman.sp"
#include "npc/gmod_zs/60/npc_zs_eradicator.sp"
#include "npc/gmod_zs/60/npc_zs_zombie_fatspy.sp"
#include "npc/gmod_zs/60/npc_zs_medic_main.sp"
#include "npc/gmod_zs/60/npc_zs_zombie_fatscout.sp"
#include "npc/gmod_zs/60/npc_zs_combine_soldier_elite.sp"
#include "npc/gmod_zs/60/npc_zs_cleaner.sp"
#include "npc/gmod_zs/60/npc_zs_vile_poisonheadcrab_zombie.sp"
#include "npc/gmod_zs/60/npc_zs_stranger.sp"
#include "npc/gmod_zs/60/npc_zs_soldier_messenger.sp"
#include "npc/gmod_zs/60/npc_zs_ihbc.sp"
#include "npc/gmod_zs/60/npc_zs_firefighter.sp"
#include "npc/gmod_zs/60/npc_zs_zombie_breadmonster.sp"
#include "npc/gmod_zs/60/npc_zs_sniper.sp"
#include "npc/gmod_zs/60/npc_zs_sam.sp"
#include "npc/gmod_zs/60/npc_zs_mlsm.sp"
#include "npc/gmod_zs/npc_zs_zmain.sp"
#include "npc/gmod_zs/special/npc_zs_flesh_creeper.sp"
#include "npc/gmod_zs/special/npc_zs_nest.sp"
#include "npc/gmod_zs/special/npc_random_zombie.sp"
#include "npc/gmod_zs/special/npc_zs_amplification.sp"
#include "npc/gmod_zs/special/npc_zs_howler.sp"
#include "npc/gmod_zs/special/npc_zs_poisonzombie_fortified_giant.sp"
#include "npc/gmod_zs/special/npc_zs_the_shit_slapper.sp"
#include "npc/gmod_zs/special/npc_zs_butcher.sp"
#include "npc/gmod_zs/special/npc_zs_bastardzine.sp"
#include "npc/gmod_zs/special/npc_zs_malfunctioning_heavy.sp"
#include "npc/gmod_zs/special/npc_zs_red_marrow.sp"
#include "npc/gmod_zs/special/npc_zs_bonemesh.sp"
#include "npc/gmod_zs/bosses/npc_zs_nightmare.sp"
#include "npc/gmod_zs/bosses/npc_zs_sphynx.sp"
#include "npc/gmod_zs/bosses/npc_zs_pregnant.sp"
#include "npc/gmod_zs/bosses/npc_major_vulture.sp"
#include "npc/gmod_zs/bosses/npc_zs_soldier_barrager.sp"
#include "npc/gmod_zs/bosses/npc_zs_unspeakable.sp"
#include "npc/gmod_zs/bosses/npc_doctor_unclean_one.sp"
#include "npc/gmod_zs/npc_zs_ally_medic.sp"
#include "npc/gmod_zs/npc_zs_ally_soldier.sp"
#include "npc/gmod_zs/npc_zs_ally_heavy.sp"
#include "npc/gmod_zs/npc_zs_ally_sniper.sp"