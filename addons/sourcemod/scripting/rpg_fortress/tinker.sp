#pragma semicolon 1
#pragma newdecls required

static const char TierName[][] =
{
	"Strange",			// 3 / 6
	"Unremarkable",		// 4 / 7
	"Scarcely Lethal",	// 5 / 8
	"Midly Menacing"	// 6 / 9
	"Uncharitable"		// 7 / 10
	"Truely Feared"		// 8 / 11
	"Gore-Spattered"	// 9 / 12
	"Wicked Nasty"		// 10 / 13
	"Face-Melting"		// 11 / 14
	"Epic"				// 12 / 15
	"Legendary"			// 13 / 16
};

#define TINKER_CAP	13

#define FLAG_MELEE	(1 << 0)
#define FLAG_RANGE	(1 << 1)
#define FLAG_WAND	(1 << 2)
#define FLAG_MINE	(1 << 3)
#define FLAG_FISH	(1 << 4)
#define FLAG_ALL	31

enum struct TinkerEnum
{
	char Name[32];
	int ToolMinLv;
	int ToolMaxLv;
	int ToolMinRarity;
	int ToolMaxRarity;
	int PlayerLevel;

	int ToolFlags;

	int Levels;
	int Credits;
	char Previous[32];

	char Cost1[48];
	int Amount1;

	char Cost2[48];
	int Amount2;

	char Cost3[48];
	int Amount3;

	char Desc[256];
	
	int Attrib[4];
	float Value[4];
	int Attribs;

	Function FuncAttack;
	Function FuncAttack2;
	Function FuncAttack3;
	Function FuncReload;
	Function FuncGainXP;

	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 32);

		this.ToolMinLv = kv.GetNum("tool_minlevel");
		this.ToolMaxLv = kv.GetNum("tool_maxlevel");
		this.ToolMinRarity = kv.GetNum("tool_minlevel");
		this.ToolMaxRarity = kv.GetNum("tool_maxlevel", 9);
		this.PlayerLevel = kv.GetNum("player_minlevel");
		this.ToolFlags = kv.GetNum("tools");
		this.Levels = kv.GetNum("levels");
		this.Credits = kv.GetNum("credits");

		kv.GetString("previous", this.Previous, 32);

		kv.GetString("name_1", this.Cost1, 48);
		this.Amount1 = kv.GetNum("amount_1");

		kv.GetString("name_2", this.Cost2, 48);
		this.Amount2 = kv.GetNum("amount_2");

		kv.GetString("name_3", this.Cost3, 48);
		this.Amount3 = kv.GetNum("amount_3");

		kv.GetString("func_attack", this.Desc, 256);
		this.FuncAttack = GetFunctionByName(null, this.Desc);

		kv.GetString("func_attack2", this.Desc, 256);
		this.FuncAttack2 = GetFunctionByName(null, this.Desc);

		kv.GetString("func_attack3", this.Desc, 256);
		this.FuncAttack3 = GetFunctionByName(null, this.Desc);

		kv.GetString("func_reload", this.Desc, 256);
		this.FuncReload = GetFunctionByName(null, this.Desc);

		kv.GetString("func_gainxp", this.Desc, 256);
		this.FuncGainXP = GetFunctionByName(null, this.Desc);

		static char buffers[32][16];
		kv.GetString("attributes", this.Desc, 256);
		this.Attribs = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
		for(int i; i < this.Attribs; i++)
		{
			this.Attrib[i] = StringToInt(buffers[i*2]);
			if(!this.Attrib[i])
			{
				LogError("Found invalid attribute on '%s'", this.Name);
				this.Attribs = i;
				break;
			}
			
			this.Value[i] = StringToFloat(buffers[i*2+1]);
		}

		kv.GetString("desc", this.Desc, 256);
	}
}

enum struct WeaponEnum
{
	char Name[48];
	int Store;
	int Owner;
	int XP;

	int Perks[TINKER_CAP];
	int PerkCount;
}

static ArrayList TinkerList;
static ArrayList WeaponList;

void Tinker_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Tinker"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "tinker");
		kv = new KeyValues("Tinker");
		kv.ImportFromFile(buffer);
	}
	
	delete WeaponList;
	WeaponList = new ArrayList(sizeof(WeaponEnum));

	delete TinkerList;
	TinkerList = new ArrayList(sizeof(TinkerEnum));

	TinkerEnum tinker;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			tinker.SetupEnum(kv);
			TinkerList.PushArray(tinker);
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
}