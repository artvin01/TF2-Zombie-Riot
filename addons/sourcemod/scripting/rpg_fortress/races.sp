
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

int i_TransformationLevel[MAXTF2PLAYERS];
int i_TransformationProgress[MAXTF2PLAYERS][5]; //secondary is for sub forms, bur we dont have them yet, but we should prepare just incase.
float f_TransformationDelay[MAXTF2PLAYERS]; 	//if he takess too long and cancels it, itll just drop the progress.
			

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
enum struct Form
{
	char Name[64];
	int Level;
	int Upgrade;
	int Mastery;
	Function Func;
	float DrainRate[2];

	float StrengthMulti[2];
	float PrecisionMulti[2];
	float ArtificeMulti[2];
	float EnduranceMulti[2];
	float StructureMulti[2];
	float IntelligenceMulti[2];
	int LuckAdd[2];
	int AgilityAdd[2];

	void SetupKV(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));

		this.Level = kv.GetNum("Form Level");
		this.Upgrade = kv.GetNum("Form Upgrade Cost");
		this.Mastery = kv.GetNum("Mastery Max Level");
		this.Func = KvGetFunction(kv, "Form Function Requirement");

		this.DrainRate[0] = kv.GetFloat("Min Capacity Drain");
		this.DrainRate[1] = kv.GetFloat("Max Capacity Drain");

		this.StrengthMulti[0] = kv.GetFloat("Min_Strength", 1.0);
		this.StrengthMulti[1] = kv.GetFloat("Max_Strength", 1.0);

		this.PrecisionMulti[0] = kv.GetFloat("Min_Precision", 1.0);
		this.PrecisionMulti[1] = kv.GetFloat("Max_Precision", 1.0);

		this.ArtificeMulti[0] = kv.GetFloat("Min_Artifice", 1.0);
		this.ArtificeMulti[1] = kv.GetFloat("Max_Artifice", 1.0);

		this.EnduranceMulti[0] = kv.GetFloat("Min_Endurance", 1.0);
		this.EnduranceMulti[1] = kv.GetFloat("Max_Endurance", 1.0);

		this.StructureMulti[0] = kv.GetFloat("Min_Structure", 1.0);
		this.StructureMulti[1] = kv.GetFloat("Max_Structure", 1.0);

		this.IntelligenceMulti[0] = kv.GetFloat("Min_Intelligence", 1.0);
		this.IntelligenceMulti[1] = kv.GetFloat("Max_Intelligence", 1.0);

		this.LuckAdd[0] = kv.GetNum("Min_Luck");
		this.LuckAdd[1] = kv.GetNum("Max_Luck");

		this.AgilityAdd[0] = kv.GetNum("Min_Agility");
		this.AgilityAdd[1] = kv.GetNum("Max_Agility");
	}
}

enum struct Race
{
	char Name[64];
	ArrayList Forms;

	float StrengthMulti;
	float PrecisionMulti;
	float ArtificeMulti;
	float EnduranceMulti;
	float StructureMulti;
	float IntelligenceMulti;
	float CapacityMulti;
	float LuckMulti;
	float AgilityMulti;

	void SetupKV(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));

		if(kv.JumpToKey("Stat Multi"))
		{
			this.StrengthMulti = kv.GetFloat("Strength", 1.0);
			this.PrecisionMulti = kv.GetFloat("Precision", 1.0);
			this.ArtificeMulti = kv.GetFloat("Artifice", 1.0);
			this.EnduranceMulti = kv.GetFloat("Endurance", 1.0);
			this.StructureMulti = kv.GetFloat("Structure", 1.0);
			this.IntelligenceMulti = kv.GetFloat("Intelligence", 1.0);
			this.CapacityMulti = kv.GetFloat("Capacity", 1.0);
			this.LuckMulti = kv.GetFloat("Luck", 1.0);
			this.AgilityMulti = kv.GetFloat("Agility", 1.0);
			kv.GoBack();
		}

		this.Forms = new ArrayList(sizeof(Form));

		if(kv.JumpToKey("Forms"))
		{
			if(kv.GotoFirstSubKey())
			{
				Form form;

				do
				{
					form.SetupKV(kv);
					this.Forms.PushArray(form);
				}
				while(kv.GotoNextKey());
				kv.GoBack();
			}
			kv.GoBack();
		}
	}
	void Delete()
	{
		delete this.Forms;
	}
}

static ArrayList Races;

void Races_ConfigSetup()
{
	Race race;

	if(Races)
	{
		int length = Races.Length;
		for(int i; i < length; i++)
		{
			Races.GetArray(i, race);
			race.Delete();
		}

		delete Races;
	}
	
	Races = new ArrayList(sizeof(Race));

	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "races");
	KeyValues kv = new KeyValues("Races");
	kv.ImportFromFile(buffer);

	if(kv.JumpToKey("Base Stating Stats"))
	{
		BaseStrength = kv.GetNum("Strength");
		BasePrecision = kv.GetNum("Precision");
		BaseArtifice = kv.GetNum("Artifice");
		BaseEndurance = kv.GetNum("Endurance");
		BaseStructure = kv.GetNum("Structure");
		BaseIntelligence = kv.GetNum("Intelligence");
		BaseCapacity = kv.GetNum("Capacity");
		BaseLuck = kv.GetNum("Luck");
		BaseAgility = kv.GetNum("Agility");
		BaseUpgradeCost = kv.GetNum("Base Experience Upgrade Cost");
		BaseUpgradeScale = kv.GetNum("Experience Cost Increace Per Level");
		BaseUpdateStats = kv.GetNum("Stats Into Level Needed");
		BaseMaxLevel = kv.GetNum("Max Level");
		BaseMaxExperience = kv.GetNum("Max Experience At Once Allowed");
		BaseMaxExperiencePerLevel = kv.GetNum("Max Experience At Once Allowed Per Level Increace");

		kv.GoBack();
	}

	kv.JumpToKey("Classes");
	kv.GotoFirstSubKey();

	do
	{
		race.SetupKV(kv);
		Races.PushArray(race);
	}
	while(kv.GotoNextKey());

	delete kv;
}

void Races_GetRaceByIndex(int index, Race race)
{
	Races.GetArray(index, race);
}
