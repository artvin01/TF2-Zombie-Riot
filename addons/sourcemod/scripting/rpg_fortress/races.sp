
#define RACE_MERC_HUMAN 1 //all around
#define RACE_EXPIDONSAN 2 //melee
#define RACE_RUANIANS 	3 //mage
#define RACE_IBERIANS 	4 //ranged

//upgrdeable skills
#define STAT_STRENGTH 		1 // -> direct damage delt
#define STAT_PRECISION 		2 // -> driect damage delt, each weapon has its own damage % logic
#define STAT_ARTIFICE 		3 // -> Direct damage delt
#define STAT_ENDURANCE 		4 // -> flat damage reduction perhaps?
#define STAT_STRUCTURE 		5 // -> health and stamina
#define STAT_INTELLIGENCE	6 // -> very slight overall boost in all stats, its at each goal point that we'll set ourselves, needed to get skills
#define STAT_CAPACITY		7 // -> resource to use either skills or upgrades to your self, or mana or ammo so to speak.

//non upgradeable skills
#define STAT_LUCK			8 // -> random crit? idk lol, but increaced chance based shit
#define STAT_AGILITY		9 // -> more movesmentspeed attackspeed reload speed, all speed things speedy.

static const float RaceStatBonuses[][] =
{
	//race, its a blank space 	STAT_STRENGTH	STAT_PRECISION	STAT_ARTIFICE		STAT_ENDURANCE	STAT_STRUCTURE	STAT_INTELLIGENCE	STAT_CAPACITY
	{ 0.0 /*defaults!*/ 		, 1.0			, 1.0			, 1.0				, 1.0			, 10.0			, 1.0				, 5.0},
	{ 0.0 /*RACE_MERC_HUMAN */ 	, 1.1			, 1.1			, 1.1				, 1.1			, 11.0			, 1.0				, 5.5}, 				//RACE_MERC_HUMAN
	{ 0.0 /*RACE_EXPIDONSAN	*/	, 1.2			, 1.0			, 0.8				, 1.2			, 13.0			, 1.2				, 4.5},			 		//RACE_EXPIDONSAN
	{ 0.0 /*RACE_RUANIANS	*/	, 0.9			, 0.9			, 1.25				, 0.9			, 9.0			, 1.1				, 7.5},			 	//RACE_RUANIANS
	{ 0.0 /*RACE_IBERIANS	*/	, 1.075			, 1.22			, 1.0				, 1.0			, 11.5			, 1.15				, 7.5},			 	//RACE_IBERIANS
};					


/*
	this defineswhat stats get multiplied by what.
	It should really never multiply the stats such as stat capacity and stat intelligence.
	
	Certain stats here do not get multiplied but added, these stats include...
	STAT_LUCK
	STAT_AGILITY

	Each transformation should be able to be mastered, this just gives player an insentive also we likely extra stat boost :3


	how this works:
	1.form minimum mastery stats
	2.form max mastery stats

	3. new form
	4. new form's max mastery stats

	etc etc
*/
static const float MercHumanTransformationMulti[][] =
{
	//Drain from Capacity!		STAT_STRENGTH	STAT_PRECISION	STAT_ARTIFICE		STAT_ENDURANCE	STAT_STRUCTURE	STAT_INTELLIGENCE	STAT_CAPACITY	STAT_LUCK++,	STAT_AGILITY++
	{ 0.0 /*defaults!*/ 		, 1.0			, 1.0			, 1.0				, 1.0			, 1.0			, 1.0				, 1.0			,0.0			,0.0},
	
	{ 10.0 /*Respawn Spirit!*/	, 2.0			, 2.0			, 2.0				, 2.0			, 2.0			, 1.0				, 1.0			,0.0			,0.0},
	{ 7.0 /*Mastered ^^!*/		, 3.0			, 3.0			, 3.0				, 3.0			, 3.0			, 1.0				, 1.0			,0.0			,0.0},

	{ 15.0 /*Halloween Magic!*/	, 3.5			, 3.5			, 3.5				, 3.5			, 3.5			, 1.0				, 1.0			,0.0			,0.0},
	{ 7.0 /*Mastered ^^!*/		, 4.5			, 4.5			, 4.5				, 4.5			, 4.5			, 1.0				, 1.0			,0.0			,0.0},
}

static const float ExpidonsanTransformationMulti[][] =
{
	//Drain from Capacity!		STAT_STRENGTH	STAT_PRECISION	STAT_ARTIFICE		STAT_ENDURANCE	STAT_STRUCTURE	STAT_INTELLIGENCE	STAT_CAPACITY	STAT_LUCK++,	STAT_AGILITY++
	{ 0.0 /*defaults!*/ 		, 1.0			, 1.0			, 1.0				, 1.0			, 1.0			, 1.0				, 1.0			,0.0			,0.0},
	
	{ 12.0 /*Halo activation!*/	, 2.0			, 2.0			, 2.0				, 2.0			, 2.0			, 1.0				, 1.0			,0.0			,0.0},
	{ 8.0 /*Mastered ^^!*/		, 3.0			, 3.0			, 3.0				, 3.0			, 3.0			, 1.0				, 1.0			,0.0			,0.0},

	{ 18.0 /*Exponential Tech!*/, 3.5			, 3.5			, 3.5				, 3.5			, 3.5			, 1.0				, 1.0			,0.0			,0.0},
	{ 5.0 /*Mastered ^^!*/		, 4.5			, 4.5			, 4.5				, 4.5			, 4.5			, 1.0				, 1.0			,0.0			,0.0},
}

static const float IberianTransformationMulti[][] =
{
	//Drain from Capacity!		STAT_STRENGTH	STAT_PRECISION	STAT_ARTIFICE		STAT_ENDURANCE	STAT_STRUCTURE	STAT_INTELLIGENCE	STAT_CAPACITY	STAT_LUCK ++,	STAT_AGILITY++
	{ 0.0 /*defaults!*/ 		, 1.0			, 1.0			, 1.0				, 1.0			, 1.0			, 1.0				, 1.0			,0.0			,0.0},
	
	{ 5.0 /*Super senses!*/		, 2.0			, 2.0			, 2.0				, 2.0			, 2.0			, 1.0				, 1.0			,0.0			,0.0},
	{ 4.0 /*Mastered ^^!*/		, 3.0			, 3.0			, 3.0				, 3.0			, 3.0			, 1.0				, 1.0			,0.0			,0.0},

	{ 15.0/*Immensive Resolve*/ , 3.5			, 3.5			, 3.5				, 3.5			, 3.5			, 1.0				, 1.0			,0.0			,0.0},
	{ 5.0 /*Mastered ^^!*/		, 4.5			, 4.5			, 4.5				, 4.5			, 4.5			, 1.0				, 1.0			,0.0			,0.0},
}

static const float RuianianTransformationMulti[][] =
{
	//Drain from Capacity!		STAT_STRENGTH	STAT_PRECISION	STAT_ARTIFICE		STAT_ENDURANCE	STAT_STRUCTURE	STAT_INTELLIGENCE	STAT_CAPACITY	STAT_LUCK ++,	STAT_AGILITY++
	{ 0.0 /*defaults!*/ 		, 1.0			, 1.0			, 1.0				, 1.0			, 1.0			, 1.0				, 1.0			,0.0			,0.0},
	
	{ 5.0 /*Celestial Compass!*/, 2.0			, 2.0			, 2.0				, 2.0			, 2.0			, 1.0				, 1.0			,0.0			,0.0},
	{ 4.0 /*Mastered ^^!*/		, 3.0			, 3.0			, 3.0				, 3.0			, 3.0			, 1.0				, 1.0			,0.0			,0.0},

	{ 15.0/*Stellar Magnifier*/ , 3.5			, 3.5			, 3.5				, 3.5			, 3.5			, 1.0				, 1.0			,0.0			,0.0},
	{ 5.0 /*Mastered ^^!*/		, 4.5			, 4.5			, 4.5				, 4.5			, 4.5			, 1.0				, 1.0			,0.0			,0.0},
}