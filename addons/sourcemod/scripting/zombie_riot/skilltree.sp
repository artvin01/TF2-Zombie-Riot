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
	Function Player;
	Function Weapon;
	int MaxCap;
	int MinNeed;
	int Cost;

	char Parent[32];
	int Dir;
	
	void SetupKV(KeyValues kv)
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
		this.Player = KvGetFunction(kv, "player");
		this.Weapon = KvGetFunction(kv, "weapon");
		this.Cost = kv.GetNum("cost", 1);
		this.MaxCap = kv.GetNum("max", 1);
		this.MinNeed = kv.GetNum("min", -1);
	}
}

static StringMap SkillList;
static StringMapSnapshot SkillListSnap;
static StringMap SkillCount[MAXTF2PLAYERS];
static StringMapSnapshot SkillCountSnap[MAXTF2PLAYERS];
static char Selected[MAXTF2PLAYERS][32];
static int PointsSpent[MAXTF2PLAYERS];

void SkillTree_PluginStart()
{
	LoadTranslations("zombieriot.phrases.skilltree");
}

void SkillTree_ConfigSetup()
{
	delete SkillListSnap;
	delete SkillList;
	SkillList = new StringMap();
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "skilltree");
	KeyValues kv = new KeyValues("");
	kv.ImportFromFile(buffer);

	CfgSetup(NULL_STRING, kv, UP);

	SkillListSnap = SkillList.Snapshot();

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

	SkillList.SetArray(parent, skill, sizeof(skill));
	
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
	delete SkillCountSnap[client];
	delete SkillCount[client];
	PointsSpent[client] = 0;
	Selected[client][0] = 0;
}

void SkillTree_AddNext(int client, const char[] id, int amount)
{
	if(!SkillCount[client])
		SkillCount[client] = new StringMap();
	
	SkillCount[client].SetValue(id, amount);
	PointsSpent[client] = -1;

	delete SkillCountSnap[client];
}

// i starts at 0
bool SkillTree_GetNext(int client, int &i, char id[32], int &amount)
{
	if(SkillCount[client])
	{
		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		if(i < length)
		{
			int size = SkillCountSnap[client].KeyBufferSize(i);
			char[] name = new char[size];
			SkillCountSnap[client].GetKey(i, name, size);
			SkillCount[client].GetValue(name, size);

			strcopy(id, sizeof(id), skill.Id);
			amount = skill.Owned[client];
			i++;
			return true;
		}
	}

	return false;
}

void SkillTree_ApplyAttribs(int client, StringMap map)
{
	if(SkillList && SkillCount[client])
	{
		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		for(int i; i < length; i++)
		{
			int size = SkillCountSnap[client].KeyBufferSize(i);
			char[] name = new char[size];
			SkillCountSnap[client].GetKey(i, name, size);
			SkillCount[client].GetValue(name, size);

			static Skill skill;
			SkillList.GetArray(name, skill, sizeof(skill));
			if(skill.Player != INVALID_FUNCTION)
			{
				Call_StartFunction(null, skill.Player);
				Call_PushCell(client);
				Call_PushCell(map);
				Call_PushCell(size);
				Call_Finish();
			}
		}
	}
}

void SkillTree_GiveItem(int client, int weapon)
{
	if(SkillList && SkillCount[client])
	{
		StringMap map;

		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		for(int i; i < length; i++)
		{
			int size = SkillCountSnap[client].KeyBufferSize(i);
			char[] name = new char[size];
			SkillCountSnap[client].GetKey(i, name, size);
			SkillCount[client].GetValue(name, size);

			static Skill skill;
			SkillList.GetArray(name, skill, sizeof(skill));
			if(skill.Weapon != INVALID_FUNCTION)
			{
				Call_StartFunction(null, skill.Weapon);
				Call_PushCell(weapon);
				Call_PushCell(map);
				Call_PushCell(size);
				Call_PushCell(client);
				Call_Finish();
			}
		}

		StringMapSnapshot snap = map.Snapshot();
		
		float value;
		length = snap.Length;
		for(int i; i < length; i++)
		{
			int size = snap.KeyBufferSize(i);
			char[] name = new char[size];
			snap.GetKey(i, name, size);
			
			map.GetValue(name, value);
			Attributes_SetMulti(weapon, StringToInt(name), 1.0 + value);
		}

		delete snap;
		delete map;
	}
}

void SkillTree_CalcSkillPoints(int client)
{
	PointsSpent[client] = 0;
	
	if(SkillCount[client])
	{
		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		for(int i; i < length; i++)
		{
			int size = SkillCountSnap[client].KeyBufferSize(i);
			char[] name = new char[size];
			SkillCountSnap[client].GetKey(i, name, size);
			SkillCount[client].GetValue(name, size);

			static Skill skill;
			SkillList.GetArray(name, skill, sizeof(skill));
			PointsSpent[client] += skill.Cost * size;
		}
	}
}

void SkillTree_OpenMenu(int client)
{
	TreeMenu(client);
}

Action SkillTree_PlayerRunCmd(int client, float vel[3])
{
	return Plugin_Continue;
}

static void TreeMenu(int client)
{
	if(PointsSpent[client] == -1)
		SkillTree_CalcSkillPoints(client);
	
	int points = (Level[client] * 3) - PointsSpent[client];
	
	Menu menu = new Menu(TreeMenuH);

	SetGlobalTransTarget(client);
	
	static char buffer[512];
	Format(buffer, sizeof(buffer), "%t\n \n%t\n ", "TF2: Zombie Riot", "Skill Points", points);

	static Skill skill;

	if(!Selected[client][0])
	{
		// Find the top node
		// TODO: Set a global variable of the default id
		int length = SkillListSnap.Length;
		for(int i; i < length; i++)
		{
			int size = SkillListSnap.KeyBufferSize(i);
			char[] name = new char[size];
			SkillListSnap.GetKey(i, name, size);
			SkillList.GetArray(name, skill, sizeof(skill));
			if(!skill.Parent[0])
			{
				strcopy(Selected[client], sizeof(Selected[]), name);
				break;
			}
		}
	}

	if(!SkillList.GetArray(name, skill, sizeof(skill)))
	{
		Selected[client][0] = 0;
		delete menu;
		return;
	}

	int length = SkillListSnap.Length;
	for(int i; i < length; i++)
	{
		int size = SkillListSnap.KeyBufferSize(i);
		char[] name = new char[size];
		SkillListSnap.GetKey(i, name, size);
		SkillList.GetArray(name, skill, sizeof(skill));
		
		if()
	}
}

