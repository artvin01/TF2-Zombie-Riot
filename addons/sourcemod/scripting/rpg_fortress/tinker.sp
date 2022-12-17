#pragma semicolon 1
#pragma newdecls required

static const char TierName[][] =
{
	// 1 = Sell
	// 2 = XP
	// 3 = Forge Stat
	// 4 = Forge Stat
	// 5 = Forge Stat
	// 6 = Forge Stat
	"Strange",			// 3 / 9
	"Unremarkable",		// 4 / 10
	"Scarcely Lethal",	// 5 / 11
	"Uncharitable"		// 6 / 12
	"Truely Feared"		// 7 / 13
	"Wicked Nasty"		// 8 / 14
	"Epic"				// 9 / 15
	"Legendary"			// 10 / 16
};

#define TINKER_CAP	10

#define FLAG_MELEE	(1 << 0)	// 1
#define FLAG_RANGE	(1 << 1)	// 2
#define FLAG_WAND	(1 << 2)	// 4
#define FLAG_MINE	(1 << 3)	// 8
#define FLAG_FISH	(1 << 4)	// 16
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
	int Level;

	int Perks[TINKER_CAP];
	int PerkCount;

	int Forge[4];
	float Value[4];
	int ForgeCount;

	int Tier()
	{
		int tier = XpToLevel(this.XP * 5);
		if(tier >= sizeof(TierName))
			tier = sizeof(TierName) - 1;
		
		return tier;
	}
	int XpToNextTier()
	{
		int tier = XpToLevel(this.XP * 5) + 1;
		if(tier >= sizeof(TierName))
			return 0;
		
		return LevelToXp(tier) / 5;
	}
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

	Tinker_ResetAll();

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

void Tinker_ResetAll()
{
	delete WeaponList;
	WeaponList = new ArrayList(sizeof(WeaponEnum));
}

static int TinkerCost(int level)
{
	return 2000 + (level * 100);
}

static void ToMetaData(const WeaponEnum wepaon, char data[512])
{
	int sell = TinkerCost(weapon.Level);

	Format(data, sizeof(data), "txp%d", weapon.XP);

	for(int i; i < weapon.PerkCount; i++)
	{
		static TinkerEnum tinker;
		TinkerList.GetArray(weapon.Perk[i], tinker);
		Format(data, sizeof(data), "%s:%s", data, tinker.Name);
		sell += tinker.Credits - (tinker.Level * 100);
	}

	if(weapon.ForgeCount)
	{
		for(int i; i < weapon.ForgeCount; i++)
		{
			Format(data, sizeof(data), "%s:forge,%d,%.2f", data, weapon.Forge[i], weapon.Value[i]);
		}

		sell += 1000;
	}
	
	Format(data, sizeof(data), "sell%d:%s", sell, data);
}

static void ConvertToTinker(int client, int index)
{

}

void Tinker_EquipItem(int client, KeyValues &kv, int index, const char[] name, bool auto)
{
	if(index < 0)
	{
		static char data[512];
		TextStore_GetItemData(index, data, sizeof(data));
		
		WeaponEnum weapon;
		strcopy(wepaon.Name, sizeof(weapon.Name), name);
		weapon.Store = index;
		weapon.Owner = client;

		static char buffers[16][32];
		int count = ExplodeString(data, ":", buffers, sizeof(buffers), sizeof(buffers[]));
		int length = TinkerList.Length;
		for(int i; i < count; i++)
		{
			if(!StrContains(buffers[i], "sell"))
				continue;
			
			if(!StrContains(buffers[i], "txp"))
			{
				weapon.XP = StringToInt(buffers[i][3]);
			}
			else if(!StrContains(buffers[i], "forge"))
			{
				if(i > 1)
				{
					ExplodeString(buffers[i], ",", buffers, 2, sizeof(buffers[]));
					weapon.Forge[weapon.ForgeCount] = StringToInt(buffers[1]);
					weapon.Value[weapon.ForgeCount++] = StringToFloat(buffers[2]);
				}
			}
			else
			{
				for(int a; a < length; a++)
				{
					static TinkerEnum tinker;
					TinkerList.GetArray(a, tinker);
					if(StrEqual(tinker, buffers[i], false))
					{
						weapon.Perks[weapon.PerkCount++] = a;
						break;
					}
				}
			}
		}
	}
}