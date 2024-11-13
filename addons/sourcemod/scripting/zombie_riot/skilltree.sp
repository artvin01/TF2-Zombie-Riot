#pragma semicolon 1
#pragma newdecls required

enum
{
	RIGHT = 0,
	DOWN = 1,
	LEFT = 2,
	UP = 3,

	DIR_MAX
}

enum struct Skill
{
	char Name[32];
	char Key[32];
	Function FuncPlayer;
	Function FuncWeapon;
	int MaxCap;
	int MinNeed;
	int Cost;

	int Parent[32];
	int Dir;
	
	bool SetupKV(KeyValues kv)
	{
		kv.GetString("name", this.Name, 32);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 32, "Missing Rogue Translation");
		}
		
		char buffer[38];
		Format(buffer, sizeof(buffer), "%s Desc", this.Name);
		if(!TranslationPhraseExists(buffer))
		{
			LogError("\"%s\" translation does not exist", buffer);
			strcopy(this.Name, 32, "Missing Rogue Translation");
		}

		kv.GetString("key", this.Key, 32);
		this.FuncPlayer = KvGetFunction(kv, "func_player");
		this.FuncWeapon = KvGetFunction(kv, "func_weapon");
		this.Cost = kv.GetNum("cost", 1);
		this.MaxCap = kv.GetNum("max", 1);
		this.MinNeed = kv.GetNum("min", -1);
	}
}

static StringMap SkillList;
static StringMap SkillCount[MAXTF2PLAYERS];

void SkillTree_PluginStart()
{
	LoadTranslations("zombieriot.phrases.skilltree");
}

void SkillTree_ConfigSetup()
{
	delete SkillList;
	SkillList = new StringMap();
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "skilltree");
	KeyValues kv = new KeyValues("");
	kv.ImportFromFile(buffer);

	CfgSetup(NULL_STRING, kv, UP);

	delete kv;
}

static void CfgSetup(const char[] intParent, KeyValues kv, int intDir)
{
	char parent[32];
	kv.GetSectionName(parent, sizeof(parent));

	Skill skill;
	strcopy(skill.Parent, sizeof(skill.Parent), intParent);
	skill.Dir = intDir;
	skill.SetupKV(kv);

	SkillList.SetArray(parent, skill);
	
	if(kv.GotoFirstSubKey())
	{
		int dir = intDir;
		do
		{
			CfgSetup(parent, kv, dir);

			dir++;
			if(dir >= DIR_MAX)
				dir = 0;
			
			if(dir == intDir)
			{
				LogError("\"%s\" skill has too many subtrees", skill.Name);
				break;
			}
		}
		while(kv.GotoNextKey());
		kv.GoBack();
	}
}

void SkillTree_ClearClient(int client)
{
	delete SkillCount[client];
}

void SkillTree_AddNext(int client, const char[] id, int amount)
{
	if(!SkillCount[client])
		SkillCount[client] = new StringMap();
	
	SkillCount[client].SetValue(id, amount);
}

StringMap SkillTree_GetMap(int client)
{
	/*
	if(SkillList)
	{
		StringMapSnapshot snap = SkillCount[client].Snapshot();
		
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i);
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			SkillCount[client].GetValue(name, size);

			strcopy(id, sizeof(id), skill.Id);
			amount = skill.Owned[client];
			return true;
		}

		delete snap;
	}
	*/
	return SkillCount[client];
}

void Store_Get