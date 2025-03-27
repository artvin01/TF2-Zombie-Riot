#pragma semicolon 1
#pragma newdecls required

enum struct Form
{
	char Name[64];
	int Level;
	int Upgrade;
	float Mastery;
	Function Func_Requirement;
	float DrainRate[2];
	char Questline[64];

	float StrengthMulti[2];
	float PrecisionMulti[2];
	float ArtificeMulti[2];
	float EnduranceMulti[2];
	float StructureMulti[2];
	float DamageResistance[2];
	float EnergyMulti[2];

	float IntelligenceMulti[2];
	int LuckAdd[2];
	int AgilityAdd[2];
	Function Func_FormActivate;
	Function Func_FormDeactivate;
	Function Func_FormBeforeDeTransform;
	Function Func_ExtraDrainLogic;
	Function Func_FormNameOverride;
	Function Func_FormExtraMultiLogic;
	Function Func_FormTakeDamage;
	Function Func_FormEnergyRunOutLogic;
	int Form_RGBA[4];

	void SetupKV(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));

		this.Level = kv.GetNum("Form Level");
		this.Upgrade = kv.GetNum("Form Upgrade Cost");
		this.Mastery = kv.GetFloat("Mastery Max Level");
		this.Func_Requirement = KvGetFunction(kv, "Form Function Requirement");
		this.Func_FormActivate = KvGetFunction(kv, "Form Activation Func");
		this.Func_FormDeactivate = KvGetFunction(kv, "Form Disable Func");
		this.Func_FormBeforeDeTransform = KvGetFunction(kv, "Form Before DeTransform");
		this.Func_ExtraDrainLogic = KvGetFunction(kv, "Extra Drain Logic");
		this.Func_FormNameOverride = KvGetFunction(kv, "Form Name Override");
		this.Func_FormExtraMultiLogic = KvGetFunction(kv, "Extra Multi Logic");
		this.Func_FormTakeDamage = KvGetFunction(kv, "Form Take Damage Logic");
		this.Func_FormEnergyRunOutLogic = KvGetFunction(kv, "Form Energy Drop Logic");

		
		kv.GetString("Questline", this.Questline, sizeof(this.Questline));

		kv.GetColor4("Form_RGBA", this.Form_RGBA);

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

		this.DamageResistance[0] = kv.GetFloat("Min_DamageRes", 1.0);
		this.DamageResistance[1] = kv.GetFloat("Max_DamageRes", 1.0);

		this.IntelligenceMulti[0] = kv.GetFloat("Min_Intelligence", 1.0);
		this.IntelligenceMulti[1] = kv.GetFloat("Max_Intelligence", 1.0);

		this.EnergyMulti[0] = kv.GetFloat("Min_Capacity", 1.0);
		this.EnergyMulti[1] = kv.GetFloat("Max_Capacity", 1.0);

		this.LuckAdd[0] = kv.GetNum("Min_Luck");
		this.LuckAdd[1] = kv.GetNum("Max_Luck");

		this.AgilityAdd[0] = kv.GetNum("Min_Agility");
		this.AgilityAdd[1] = kv.GetNum("Max_Agility");
	}
	float GetFloatStat(int client, int stat, float mastery)
	{
		float minval = GetItemInArray(this, stat);
		float maxval = GetItemInArray(this, stat + 1);
		
		if(this.Mastery < 1.0)
			return maxval;
		
		float percent = mastery / this.Mastery;
		if(percent > 1.0)
			percent = 1.0;
		
		if(client != -1 && this.Func_FormExtraMultiLogic != INVALID_FUNCTION)
		{
			float MultiExtra = 1.0;
			Call_StartFunction(null, this.Func_FormExtraMultiLogic);
			Call_PushCell(client);
			Call_PushCell(stat);
			Call_PushFloat(minval);
			Call_PushFloatRef(MultiExtra);
			Call_Finish();
			minval *= MultiExtra;
			maxval *= MultiExtra;
		}
		
		return minval + ((maxval - minval) * percent);
	}
	int GetIntStat(int client, int stat, float mastery)
	{
		int minval = GetItemInArray(this, stat);
		int maxval = GetItemInArray(this, stat + 1);

		if(this.Mastery < 1.0)
			return maxval;
		
		float percent = mastery / this.Mastery;
		if(percent > 1.0)
			percent = 1.0;


		if(this.Func_FormExtraMultiLogic != INVALID_FUNCTION)
		{
			float MultiExtra = 1.0;
			Call_StartFunction(null, this.Func_FormExtraMultiLogic);
			Call_PushCell(client);
			Call_PushCell(stat);
			Call_PushFloat(1.0);
			Call_PushFloatRef(MultiExtra);
			Call_Finish();
			minval = RoundToNearest(float(minval) * MultiExtra);
			maxval = RoundToNearest(float(maxval) * MultiExtra);
		}

		return minval + RoundFloat(float(maxval - minval) * percent);
	}
	void Default()
	{
		strcopy(this.Name, sizeof(this.Name), "Energy");

		this.Level = 0;
		this.Upgrade = 0;
		this.Mastery = 0.0;
		this.Func_Requirement = INVALID_FUNCTION;
		this.Func_FormActivate = INVALID_FUNCTION;
		this.Func_FormDeactivate = INVALID_FUNCTION;

		this.DrainRate[0] = 0.0;
		this.DrainRate[1] = 0.0;

		this.StrengthMulti[0] = 1.0;
		this.StrengthMulti[1] = 1.0;

		this.PrecisionMulti[0] = 1.0;
		this.PrecisionMulti[1] = 1.0;

		this.ArtificeMulti[0] = 1.0;
		this.ArtificeMulti[1] = 1.0;

		this.EnduranceMulti[0] = 1.0;
		this.EnduranceMulti[1] = 1.0;

		this.StructureMulti[0] = 1.0;
		this.StructureMulti[1] = 1.0;

		this.DamageResistance[0] = 1.0;
		this.DamageResistance[1] = 1.0;

		this.IntelligenceMulti[0] = 1.0;
		this.IntelligenceMulti[1] = 1.0;

		this.EnergyMulti[0] = 1.0;
		this.EnergyMulti[1] = 1.0;

		this.LuckAdd[0] = 0;
		this.LuckAdd[1] = 0;

		this.AgilityAdd[0] = 0;
		this.AgilityAdd[1] = 0;
	}
}

enum struct Race
{
	char Name[64];
	char Key[64];
	char Desc[256];
	ArrayList Forms;
	int StartLevel;
	float StartPos[3];
	float StartAngle;

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
		kv.GetString("key", this.Key, sizeof(this.Key));
		kv.GetString("desc", this.Desc, sizeof(this.Desc));
		this.StartLevel = kv.GetNum("startlevel");
		kv.GetVector("startpos", this.StartPos);
		this.StartAngle = kv.GetFloat("startangle");

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
		BaseUpgradeScale = kv.GetNum("Experience Cost increase Per Level");
		BaseUpdateStats = kv.GetNum("Stats Into Level Needed", 1);
		BaseMaxLevel = kv.GetNum("Max Level");

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

stock bool Races_GetRaceByIndex(int index, Race race)
{
	if(index < 0 || index >= Races.Length)
		return false;
	
	Races.GetArray(index, race);
	return true;
}

stock bool Races_GetClientInfo(int client, Race race = {}, Form form = {})
{
	Races.GetArray(RaceIndex[client], race);

	if(i_TransformationLevel[client] < 1 || i_TransformationLevel[client] > race.Forms.Length)
	{
		form.Default();
		return false;
	}
	
	race.Forms.GetArray(i_TransformationLevel[client] - 1, form);
	return true;
}
