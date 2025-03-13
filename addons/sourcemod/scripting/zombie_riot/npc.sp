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
	// Buildings

	// Constructs
	ObjectConstruction_LightHouse_MapStart();
	ObjectStove_MapStart();
	ObjectFactory_MapStart();
	// Constructs

	// Vehicles
	VehicleHL2_Setup();
	VehicleFullJeep_Setup();
	VehicleAmbulance_Setup();
	VehicleBus_Setup();
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
	/*
	BasicBones_OnMapStart_NPC();
	BeefyBones_OnMapStart_NPC();
	BrittleBones_OnMapStart_NPC();
	BigBones_OnMapStart_NPC();*/
	AlliedLeperVisualiserAbility_OnMapStart_NPC();
	AlliedKiryuVisualiserAbility_OnMapStart_NPC();
	
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
//wave 1~15
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
	
//wave 16~30
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
	
//wave 31~45
	Victoria_BaseBreaker_OnMapStart_NPC();
	VictoriaAntiarmorInfantry_OnMapStart_NPC();
	VictoriaAssulter_OnMapStart_NPC();
	VictorianMechafist_OnMapStart_NPC();
	VictorianBooster_OnMapStart_NPC();
	VictoriaScorcher_OnMapStart_NPC();
	VictoriaMowdown_OnMapStart_NPC();
	VictoriaMortar_OnMapStart_NPC();
	VictoriaBreachcart_MapStart();
	VictoriaBombcart_Precache();
	VictoriaBigpipe_OnMapStart_NPC();
	VictoriaHarbringer_OnMapStart_NPC();
	VictoriaBirdeye_OnMapStart_NPC();

//wave 46~60
	VictorianCaffeinator_OnMapStart_NPC();
	VictorianMechanist_as_OnMapStart_NPC();
	VictorianOfflineAvangard_MapStart();
	VictorianWelder_OnMapStart_NPC();
	VIctorianTanker_OnMapStart_NPC();
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
	MajorVoided_MapStart();
	DuckFollower_Setup();
	BobTheFirstFollower_Setup();
	TwirlFollower_Setup();
	
	// Construction
	BaseBuilding_MapStart();

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

	//Victoria stuff? idfk, come back in 1.5 years and comment on it Beep
	VictorianFactory_MapStart();
	VictorianDroneFragments_MapStart();
	VictorianDroneAnvil_MapStart();
	Victorian_Tacticalunit_OnMapStart_NPC();
	Victorian_TacticalProtector_OnMapStart_NPC();


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
	FreeplaySigmaller_OnMapStart_NPC();
	Spotter_OnMapStart_NPC();
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

stock int NPC_GetByPlugin(const char[] name, NPCData data = {})
{
	int index = NPCList.FindString(name, NPCData::Plugin);
	if(index != -1)
	{
		NPCList.GetArray(index, data);
		PrecacheNPC(index, data);
	}
	
	return index;
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
			}
			Waves_UpdateMvMStats();
		}
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
#include "zombie_riot/npc/expidonsa/npc_expidonsa_base.sp" //ALSO IN RPG!
#include "zombie_riot/npc/seaborn/npc_nethersea_shared.sp"

//BUILDINGS
#include "zombie_riot/object/obj_shared.sp"
#include "zombie_riot/object/obj_armortable.sp"
#include "zombie_riot/object/obj_decorative.sp"
#include "zombie_riot/object/obj_perkmachine.sp"
#include "zombie_riot/object/obj_healingstation.sp"
#include "zombie_riot/object/obj_packapunch.sp"
#include "zombie_riot/object/obj_barricade.sp"
#include "zombie_riot/object/obj_ammobox.sp"
#include "zombie_riot/object/obj_tinker_anvil.sp"
#include "zombie_riot/object/obj_sentrygun.sp"
#include "zombie_riot/object/obj_mortar.sp"
#include "zombie_riot/object/obj_railgun.sp"
#include "zombie_riot/object/obj_village.sp"
#include "zombie_riot/object/obj_barracks.sp"
#include "zombie_riot/object/obj_brewing_stand.sp"
#include "zombie_riot/object/obj_revenant.sp"
#include "zombie_riot/object/construction/obj_giant_lighthouse.sp"
#include "zombie_riot/object/construction/obj_const_stove.sp"
#include "zombie_riot/object/construction/obj_const_factory.sp"
//#include "zombie_riot/object/construction/obj_hospital.sp"

// VEHICLES
#include "shared/vehicles/vehicle_shared.sp"
#include "shared/vehicles/vehicle_hl2.sp"
#include "zombie_riot/vehicles/vehicle_fulljeep.sp"
#include "zombie_riot/vehicles/vehicle_ambulance.sp"
#include "zombie_riot/vehicles/vehicle_bus.sp"
#include "zombie_riot/vehicles/vehicle_camper.sp"
#include "zombie_riot/vehicles/vehicle_dumptruck.sp"
#include "zombie_riot/vehicles/vehicle_landrover.sp"
#include "zombie_riot/vehicles/vehicle_pickup.sp"

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

#include "zombie_riot/npc/xeno_lab/npc_xeno_acclaimed_swordsman.sp"
#include "zombie_riot/npc/xeno_lab/npc_xeno_early_infected.sp"
#include "zombie_riot/npc/xeno_lab/npc_xeno_patient_few.sp"
#include "zombie_riot/npc/xeno_lab/npc_xeno_ekas_robo.sp"

#include "zombie_riot/npc/special/npc_sawrunner.sp"
#include "zombie_riot/npc/special/npc_l4d2_tank.sp"
#include "zombie_riot/npc/special/npc_phantom_knight.sp"
#include "zombie_riot/npc/special/npc_beheaded_kamikaze.sp"
#include "zombie_riot/npc/special/npc_doctor.sp"
#include "zombie_riot/npc/special/npc_wandering_spirit.sp"
#include "zombie_riot/npc/special/npc_vengefull_spirit.sp"
#include "zombie_riot/npc/special/npc_fallen_warrior.sp"
#include "zombie_riot/npc/special/npc_3650.sp"
#include "zombie_riot/npc/special/npc_john_the_allmighty.sp"

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
#include "zombie_riot/npc/ally/npc_citizen_new.sp"
#include "zombie_riot/npc/ally/npc_allied_sensal_afterimage.sp"
#include "zombie_riot/npc/ally/npc_allied_leper_visualiser.sp"
#include "zombie_riot/npc/ally/npc_allied_kahml_afterimage.sp"
#include "zombie_riot/npc/ally/npc_allied_kiyru_visualiser.sp"

#include "zombie_riot/npc/raidmode_bosses/npc_true_fusion_warrior.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_blitzkrieg.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_god_alaxios.sp"

#if defined RUINA_BASE
//Ruina

#include "zombie_riot/npc/ruina/ruina_npc_enchanced_ai_core.sp"	//this controls almost every ruina npc's behaviors.
//stage 1
#include "zombie_riot/npc/ruina/stage1/npc_ruina_theocracy.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_adiantum.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_lanius.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_magia.sp"
#include "zombie_riot/npc/ruina/stage1/npc_ruina_helia.sp"
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
#include "zombie_riot/npc/ruina/stage2/npc_ruina_heliara.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_astriana.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_europis.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_draedon.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_aetheria.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_maliana.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_ruianus.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_lazius.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_dronian.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_lex.sp"
#include "zombie_riot/npc/ruina/stage2/npc_ruina_iana.sp"

//stage 3

#include "zombie_riot/npc/ruina/stage3/npc_ruina_loonaris.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_magianas.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_heliaris.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_astrianis.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_eurainis.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_draeonis.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_aetherium.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_malianium.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_rulius.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_lazines.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_dronis.sp"
#include "zombie_riot/npc/ruina/stage3/npc_ruina_ruliana.sp"

//stage 4

#include "zombie_riot/npc/ruina/stage4/npc_ruina_aetherianus.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_astrianious.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_draconia.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_dronianis.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_euranionis.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_heliarionus.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_lazurus.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_loonarionus.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_magianius.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_malianius.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_rulianius.sp"
#include "zombie_riot/npc/ruina/stage4/npc_ruina_lancelot.sp"


//Special Ruina
#include "zombie_riot/npc/ruina/special/npc_ruina_valiant.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_magia_anchor.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_storm_weaver.sp"
#include "zombie_riot/npc/ruina/special/npc_ruina_storm_weaver_mid.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_twirl.sp"
//#include "zombie_riot/npc/raidmode_bosses/npc_levita.sp"

#endif

#include "zombie_riot/npc/ally/npc_fractal_cannon_animation.sp"


#include "zombie_riot/npc/rogue/chaos_expansion/npc_lelouch.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_manipulation_ent.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_interstellar_weaver.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_interstellar_weaver_mid.sp"

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
#include "zombie_riot/npc/cof/npc_sewmo.sp"
#include "zombie_riot/npc/cof/npc_faster.sp"
#include "zombie_riot/npc/cof/npc_psycho.sp"
#include "zombie_riot/npc/cof/npc_suicider.sp"
#include "zombie_riot/npc/cof/npc_crazylady.sp"
#include "zombie_riot/npc/ally/npc_cured_purnell.sp"
#include "zombie_riot/npc/cof/npc_corruptedbarney.sp"
#include "zombie_riot/npc/xeno/npc_xeno_malfunctioning_robot.sp"

/*
#include "zombie_riot/npc/bonezone/npc_basicbones.sp"
#include "zombie_riot/npc/bonezone/npc_beefybones.sp"
#include "zombie_riot/npc/bonezone/npc_brittlebones.sp"
#include "zombie_riot/npc/bonezone/npc_bigbones.sp"
*/


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
#include "zombie_riot/npc/ally/npc_barrack_handcannoneer.sp"
#include "zombie_riot/npc/ally/npc_barrack_champion.sp"
#include "zombie_riot/npc/ally/npc_barrack_monk.sp"
#include "zombie_riot/npc/ally/npc_barrack_hussar.sp"
#include "zombie_riot/npc/ally/npc_barrack_thorns.sp"
#include "zombie_riot/npc/ally/npc_barrack_teutonic_knight.sp"
#include "zombie_riot/npc/ally/npc_barrack_villager.sp"
#include "zombie_riot/npc/ally/npc_barrack_building.sp"

#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_basic_mage.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_iku_nagae.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_intermediate_mage.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_advanced_mage.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_railgunner.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_schwertkrieg.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_donnerkrieg.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_holy_knight.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_mecha_barrager.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_barrager.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_mecha_loader.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_crossbowman.sp"
#include "zombie_riot/npc/ally/alt_barracks/npc_barrack_alt_scientific_witchery.sp"

#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_pistol.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_swordsman.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_smg.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_ar2.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_ddt.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_shotgunner.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_collos.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_elite.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_sniper.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_unit.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_giant_ddt.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_super.sp"
#include "zombie_riot/npc/ally/combine_barracks/npc_barrack_combine_commander.sp"

#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_runner.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_gunner.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_tanker.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_rocketeer.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_healer.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_boomstick.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_healtanker.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_guards.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_elite_gunner.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_commando.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_headhunter.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_inquisitor.sp"
#include "zombie_riot/npc/ally/iberia_barracks/npc_barrack_lighthouse_guardian.sp"


#include "zombie_riot/npc/ally/npc_nearl_sword.sp"

#include "zombie_riot/npc/respawn/npc_stalker_combine.sp"
#include "zombie_riot/npc/respawn/npc_stalker_father.sp"
#include "zombie_riot/npc/respawn/npc_stalker_goggles.sp"

#include "zombie_riot/npc/raidmode_bosses/xeno/npc_infected_silvester.sp"
#include "zombie_riot/npc/raidmode_bosses/xeno/npc_infected_goggles.sp"
#include "zombie_riot/npc/raidmode_bosses/xeno/npc_nemesis.sp"
#include "zombie_riot/npc/raidmode_bosses/xeno/npc_mrx.sp"

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

#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_stella.sp"
#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_karlas.sp"
#include "zombie_riot/npc/raidmode_bosses/seaborn/npc_bob_the_first_last_savior.sp"

#include "zombie_riot/npc/expidonsa/npc_benera.sp"
#include "zombie_riot/npc/expidonsa/npc_pental.sp"
#include "zombie_riot/npc/expidonsa/npc_defanda.sp"
#include "zombie_riot/npc/expidonsa/npc_selfam_ire.sp"
#include "zombie_riot/npc/expidonsa/npc_vaus_magica.sp"
#include "zombie_riot/npc/expidonsa/npc_benera_pistoleer.sp"
#include "zombie_riot/npc/expidonsa/npc_diversionistico.sp"
#include "zombie_riot/npc/expidonsa/npc_heavy_punuel.sp"
#include "zombie_riot/npc/expidonsa/npc_sergeant_ideal.sp"
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
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_whiteflower.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_acclaimed_swordsman.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_ekas_piloteer.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_ekas_robo.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_extreme_knight_giant.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_flowering_darkness.sp"
#include "zombie_riot/npc/rogue/whiteflower_rogue/npc_combine_raging_blader.sp"
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

#include "zombie_riot/npc/void/npc_spawn_void_portal.sp"
#include "zombie_riot/npc/void/npc_void_base.sp"
#include "zombie_riot/npc/void/npc_voided_diversionistico.sp"
//1-15
#include "zombie_riot/npc/void/early/npc_ealing.sp"
#include "zombie_riot/npc/void/early/npc_framing_voider.sp"
#include "zombie_riot/npc/void/early/npc_growing_exat.sp"
#include "zombie_riot/npc/void/early/npc_mutating_blob.sp"
#include "zombie_riot/npc/void/early/npc_void_spreader.sp"
#include "zombie_riot/npc/void/early/npc_void_infestor.sp"
#include "zombie_riot/npc/void/early/npc_void_crust.sp"
#include "zombie_riot/npc/void/early/npc_void_carrier.sp"
#include "zombie_riot/npc/void/early/npc_void_ixufan.sp"

#include "zombie_riot/npc/void/earlymid/npc_enframed_voider.sp"
#include "zombie_riot/npc/void/earlymid/npc_blood_pollutor.sp"
#include "zombie_riot/npc/void/earlymid/npc_voided_expidonsan_fortifier.sp"
#include "zombie_riot/npc/void/earlymid/npc_void_particle.sp"
#include "zombie_riot/npc/void/earlymid/npc_hosting_blob.sp"
#include "zombie_riot/npc/void/earlymid/npc_blobbing_monster.sp"
#include "zombie_riot/npc/void/earlymid/npc_void_sprayer.sp"
#include "zombie_riot/npc/void/earlymid/npc_void_encasulator.sp"


#include "zombie_riot/npc/void/midlate/npc_void_expidonsan_container.sp"
#include "zombie_riot/npc/void/midlate/npc_void_expidonsan_cleaner.sp"
#include "zombie_riot/npc/void/midlate/npc_void_sacraficer.sp"
#include "zombie_riot/npc/void/midlate/npc_voiding_bedrock.sp"
#include "zombie_riot/npc/void/midlate/npc_void_heavy_perisher.sp"
#include "zombie_riot/npc/void/midlate/npc_void_minigate_keeper.sp"
#include "zombie_riot/npc/void/midlate/npc_void_brooding_petra.sp"


#include "zombie_riot/npc/void/late/npc_void_erasus.sp"
#include "zombie_riot/npc/void/late/npc_void_kunul.sp"
#include "zombie_riot/npc/void/late/npc_void_total_growth.sp"
#include "zombie_riot/npc/void/late/npc_voids_offspring.sp"
#include "zombie_riot/npc/void/late/npc_void_rejuvinator.sp"
#include "zombie_riot/npc/void/late/npc_void_speechless.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_void_unspeakable.sp"

#include "zombie_riot/npc/rogue/npc_rogue_condition.sp"
#include "zombie_riot/npc/rogue/chaos/npc_goggles_follower.sp"
#include "zombie_riot/npc/rogue/chaos/npc_thehunter.sp"
#include "zombie_riot/npc/rogue/chaos/npc_finalhunter.sp"
#include "zombie_riot/npc/rogue/chaos/npc_kahmlstein_follower.sp"
#include "zombie_riot/npc/rogue/chaos/npc_chaos_mage.sp"
#include "zombie_riot/npc/rogue/chaos/npc_chaos_supporter.sp"
#include "zombie_riot/npc/rogue/chaos/npc_chaos_insane.sp"
#include "zombie_riot/npc/rogue/chaos/npc_chaos_sick_knight.sp"
#include "zombie_riot/npc/rogue/chaos/npc_chaos_injured_cultist.sp"
#include "zombie_riot/npc/rogue/chaos/npc_vhxis.sp"
#include "zombie_riot/npc/rogue/chaos/npc_duck_follower.sp"


#include "zombie_riot/npc/rogue/chaos_expansion/npc_evil_chaos_demon.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_chaos_swordsman.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_bob_first_follower.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_twirl_follower.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_hallam_great_demon.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_Ihanal_demon_whisperer.sp"
#include "zombie_riot/npc/rogue/chaos_expansion/npc_majorvoided.sp"

#include "zombie_riot/npc/mutations/truesurvival/npc_nightmare.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_petrisisbaron.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_sphynx.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_zombine.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_zmain_headcrabzombie.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_zmain_poisonzombie.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_zmain_headcrab.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_headcrab.sp"
#include "zombie_riot/npc/mutations/truesurvival/npc_poisonheadcrab.sp"
#include "zombie_riot/npc/mutations/randomboss/npc_boss_battle_only.sp"



#include "zombie_riot/npc/iberia_expidonsa/npc_iberia_base.sp"
#include "zombie_riot/npc/iberia_expidonsa/npc_iberia_beacon.sp"
#include "zombie_riot/npc/iberia_expidonsa/npc_iberia_lighthouse.sp"
#include "zombie_riot/npc/iberia_expidonsa/npc_beacon_constructor.sp"
#include "zombie_riot/npc/iberia_expidonsa/npc_huirgrajo.sp"

#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_irani.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_cambino.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_kinat.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_ginus.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_speedus_initus.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_anania.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_victorian.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_15/npc_inqusitor_iidutas.sp"


#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_vivintu.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_cenula.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_kumbai.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_speedus_instantus.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_combastia.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_iberia_morato.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_sea_xploder.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_30/npc_anti_sea_robot.sp"


#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_ranka_s.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_murdarato.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_elite_kinat.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_seaborn_eradicator.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_speedus_itus.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_sentinel.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_destructius.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_45/npc_ironborus.sp"


#include "zombie_riot/npc/iberia_expidonsa/wave_60/npc_death_marker.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_60/npc_runaka.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_60/npc_speedus_elitus.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_60/npc_sea_dryer.sp"
#include "zombie_riot/npc/iberia_expidonsa/wave_60/npc_inqusitor_irene.sp"


#include "zombie_riot/npc/raidmode_bosses/iberia/npc_nemal.sp"
#include "zombie_riot/npc/raidmode_bosses/iberia/npc_raid_silvester.sp"

//Victoria
//Wave 1~15
#include "zombie_riot/npc/victoria/npc_batter.sp"
#include "zombie_riot/npc/victoria/npc_charger.sp"
#include "zombie_riot/npc/victoria/npc_teslar.sp"
#include "zombie_riot/npc/victoria/npc_victorian_vanguard.sp"
#include "zombie_riot/npc/victoria/npc_supplier.sp"
#include "zombie_riot/npc/victoria/npc_ballista.sp"
#include "zombie_riot/npc/victoria/npc_igniter.sp"
#include "zombie_riot/npc/victoria/npc_grenadier.sp"
#include "zombie_riot/npc/victoria/npc_squadleader.sp"
#include "zombie_riot/npc/victoria/npc_signaller.sp"

//wave 16~30
#include "zombie_riot/npc/victoria/npc_humbee.sp"
#include "zombie_riot/npc/victoria/npc_shotgunner.sp"
#include "zombie_riot/npc/victoria/npc_bulldozer.sp"
#include "zombie_riot/npc/victoria/npc_hardener.sp"
#include "zombie_riot/npc/victoria/npc_raider.sp"
#include "zombie_riot/npc/victoria/npc_zapper.sp"
#include "zombie_riot/npc/victoria/npc_payback.sp"
#include "zombie_riot/npc/victoria/npc_blocker.sp"
#include "zombie_riot/npc/victoria/npc_destructor.sp"
#include "zombie_riot/npc/victoria/npc_ironshield.sp"
#include "zombie_riot/npc/victoria/npc_aviator.sp"

//wave 31~45
#include "zombie_riot/npc/victoria/npc_basebreaker.sp"
#include "zombie_riot/npc/victoria/npc_booster.sp"
#include "zombie_riot/npc/victoria/npc_scorcher.sp"
#include "zombie_riot/npc/victoria/npc_mowdown.sp"
#include "zombie_riot/npc/victoria/npc_mechafist.sp"
#include "zombie_riot/npc/victoria/npc_assaulter.sp"
#include "zombie_riot/npc/victoria/npc_antiarmor_infantry.sp"
#include "zombie_riot/npc/victoria/npc_mortar.sp"
#include "zombie_riot/npc/victoria/npc_bombcart.sp"
#include "zombie_riot/npc/victoria/npc_breachcart.sp"
#include "zombie_riot/npc/victoria/npc_birdeye.sp"
#include "zombie_riot/npc/victoria/npc_harbringer.sp"
#include "zombie_riot/npc/victoria/npc_bigpipe.sp"

//wave 46~60
#include "zombie_riot/npc/victoria/npc_caffeinator.sp"
#include "zombie_riot/npc/victoria/npc_welder.sp"
#include "zombie_riot/npc/victoria/npc_mechanist.sp"
#include "zombie_riot/npc/victoria/npc_avangard.sp"
#include "zombie_riot/npc/victoria/npc_tanker.sp"
#include "zombie_riot/npc/victoria/npc_pulverizer.sp"
#include "zombie_riot/npc/victoria/npc_ambusher.sp"
#include "zombie_riot/npc/victoria/npc_taser.sp"
#include "zombie_riot/npc/victoria/npc_victorian_tank.sp"
#include "zombie_riot/npc/victoria/npc_victoria_radiomast.sp"
#include "zombie_riot/npc/victoria/npc_radioguard.sp"
#include "zombie_riot/npc/victoria/npc_radio_repair.sp"

#include "zombie_riot/npc/victoria/npc_victorian_moru.sp"
#include "zombie_riot/npc/victoria/npc_victorian_fragments.sp"
#include "zombie_riot/npc/victoria/npc_victorian_factory.sp"
#include "zombie_riot/npc/victoria/npc_victoria_tacticalprotector.sp"
#include "zombie_riot/npc/victoria/npc_victoria_tacticalunit.sp"
//raidbosses
#include "zombie_riot/npc/raidmode_bosses/victoria/npc_the_atomizer.sp"
#include "zombie_riot/npc/raidmode_bosses/victoria/npc_the_wall.sp"
#include "zombie_riot/npc/raidmode_bosses/victoria/npc_harrison.sp"
#include "zombie_riot/npc/raidmode_bosses/victoria/npc_castellan.sp"

//Matrix Enemies
#include "zombie_riot/npc/matrix/15/npc_agentalan.sp"
#include "zombie_riot/npc/matrix/15/npc_agentalexander.sp"
#include "zombie_riot/npc/matrix/15/npc_agentchase.sp"
#include "zombie_riot/npc/matrix/15/npc_agentdave.sp"
#include "zombie_riot/npc/matrix/15/npc_agentgraham.sp"
#include "zombie_riot/npc/matrix/15/npc_agentjames.sp"
#include "zombie_riot/npc/matrix/15/npc_agentjohn.sp"
#include "zombie_riot/npc/matrix/15/npc_agentsteve.sp"
#include "zombie_riot/npc/matrix/30/npc_agenteric.sp"
#include "zombie_riot/npc/matrix/30/npc_agentjack.sp"
#include "zombie_riot/npc/matrix/30/npc_agentjim.sp"
#include "zombie_riot/npc/matrix/30/npc_agentjosh.sp"
#include "zombie_riot/npc/matrix/30/npc_agentkenneth.sp"
#include "zombie_riot/npc/matrix/30/npc_agentpaul.sp"
#include "zombie_riot/npc/matrix/30/npc_agenttyler.sp"
#include "zombie_riot/npc/matrix/30/npc_agentwayne.sp"
#include "zombie_riot/npc/matrix/30/npc_merovingian.sp"
#include "zombie_riot/npc/matrix/45/npc_agentben.sp"
#include "zombie_riot/npc/matrix/45/npc_agentchad.sp"
#include "zombie_riot/npc/matrix/45/npc_agentchris.sp"
#include "zombie_riot/npc/matrix/45/npc_agentdick.sp"
#include "zombie_riot/npc/matrix/45/npc_agentian.sp"
#include "zombie_riot/npc/matrix/45/npc_agentjackson.sp"
#include "zombie_riot/npc/matrix/45/npc_agentmike.sp"
#include "zombie_riot/npc/matrix/45/npc_agentsam.sp"
#include "zombie_riot/npc/matrix/45/npc_agentzack.sp"
#include "zombie_riot/npc/matrix/60/npc_agentconnor.sp"
#include "zombie_riot/npc/matrix/60/npc_agenthenry.sp"
#include "zombie_riot/npc/matrix/60/npc_agentjeremy.sp"
#include "zombie_riot/npc/matrix/60/npc_agentjones.sp"
#include "zombie_riot/npc/matrix/60/npc_agentkurt.sp"
#include "zombie_riot/npc/matrix/60/npc_agentlogan.sp"
#include "zombie_riot/npc/matrix/60/npc_agentross.sp"
#include "zombie_riot/npc/matrix/60/npc_agentspencer.sp"
#include "zombie_riot/npc/matrix/60/npc_agenttodd.sp"

//Matrix Giants
#include "zombie_riot/npc/matrix/giants/npc_giant_haste.sp"
#include "zombie_riot/npc/matrix/giants/npc_giant_knockout.sp"
#include "zombie_riot/npc/matrix/giants/npc_giant_reflector.sp"
#include "zombie_riot/npc/matrix/giants/npc_giant_regeneration.sp"

//Matrix Raids
#include "zombie_riot/npc/matrix/raids/npc_agentjohnson.sp"
#include "zombie_riot/npc/matrix/raids/npc_agentthompson.sp"
#include "zombie_riot/npc/matrix/raids/npc_twins.sp"
#include "zombie_riot/npc/matrix/raids/npc_agent_smith.sp"

//Matrix Freeplay Enemies
#include "zombie_riot/npc/matrix/freeplay/npc_freeplay_agentdave.sp"
#include "zombie_riot/npc/matrix/freeplay/npc_freeplay_agentwayne.sp"
#include "zombie_riot/npc/matrix/freeplay/npc_freeplay_agentian.sp"
#include "zombie_riot/npc/matrix/freeplay/npc_freeplay_agentspencer.sp"

//Combine Hell Mutation
#include "zombie_riot/npc/mutations/combinehell/other/npc_hunter.sp"
#include "zombie_riot/npc/mutations/combinehell/other/npc_merlton.sp"
#include "zombie_riot/npc/mutations/combinehell/other/npc_combine_lost_knight.sp"
#include "zombie_riot/npc/mutations/combinehell/other/npc_omega_raid.sp"
#include "zombie_riot/npc/mutations/combinehell/other/npc_bob_follower.sp"
#include "zombie_riot/npc/mutations/combinehell/seaborn/npc_seaborn_combine_police_pistol.sp"
#include "zombie_riot/npc/mutations/combinehell/seaborn/npc_seaborn_combine_police_smg.sp"
#include "zombie_riot/npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_elite.sp"
#include "zombie_riot/npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_ar2.sp"
#include "zombie_riot/npc/mutations/combinehell/seaborn/npc_seaborn_combine_soldier_shotgun.sp"
#include "zombie_riot/npc/mutations/combinehell/void/npc_voided_combine_police_pistol.sp"
#include "zombie_riot/npc/mutations/combinehell/void/npc_voided_combine_police_smg.sp"
#include "zombie_riot/npc/mutations/combinehell/void/npc_voided_combine_soldier_elite.sp"
#include "zombie_riot/npc/mutations/combinehell/void/npc_voided_combine_soldier_ar2.sp"
#include "zombie_riot/npc/mutations/combinehell/void/npc_voided_combine_soldier_shotgun.sp"

#include "zombie_riot/npc/voices/npc_stalker_wisp.sp"

// Freeplay
#include "zombie_riot/npc/mutations/freeplay/npc_dimensionfrag.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_immutableheavy.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_vanishingmatter.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_freeplay_sigmaller.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_spotter.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_annoying_spirit.sp"
#include "zombie_riot/npc/mutations/freeplay/npc_darkenedheavy.sp"

#include "zombie_riot/npc/construction/npc_base_building.sp"
#include "zombie_riot/npc/construction/npc_material_cash.sp"
#include "zombie_riot/npc/construction/npc_material_copper.sp"
#include "zombie_riot/npc/construction/npc_material_crystal.sp"
#include "zombie_riot/npc/construction/npc_material_iron.sp"
#include "zombie_riot/npc/construction/npc_material_jalan.sp"
#include "zombie_riot/npc/construction/npc_material_ossunia.sp"
#include "zombie_riot/npc/construction/npc_material_stone.sp"
#include "zombie_riot/npc/construction/npc_material_wizuh.sp"
#include "zombie_riot/npc/construction/npc_material_wood.sp"
