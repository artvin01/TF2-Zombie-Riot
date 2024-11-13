#pragma semicolon 1
#pragma newdecls required

#define POINTS_PER_LEVEL	2

enum
{
	RIGHT = 0,
	DOWN = 1,
	LEFT = 2,
	UP = 3,

	DIR_MAX
}

static int ReverseDir(int dir)
{
	int newDir = dir + 2;
	if(newDir >= DIR_MAX)
		newDir -= DIR_MAX;
	
	return newDir;
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

static MusicEnum CustomMusic;
static StringMap SkillList;
static StringMapSnapshot SkillListSnap;
static StringMap SkillCount[MAXTF2PLAYERS];
static StringMapSnapshot SkillCountSnap[MAXTF2PLAYERS];
static char Selected[MAXTF2PLAYERS][32];
static bool InMenu[MAXTF2PLAYERS];
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

	CustomMusic.SetupKv("music", kv);

	CfgSetup(NULL_STRING, kv, UP);

	SkillListSnap = SkillList.Snapshot();

	delete kv;
}

static bool CfgSetup(const char[] intParent, KeyValues kv, int intDir)
{
	char parent[32];
	kv.GetSectionName(parent, sizeof(parent));
	if(StrEqual(parent, "music"))
		return false;

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
			if(!CfgSetup(parent, kv, dir))
				continue;

			dir++;
			if(ReverseDir(intDir) == dir)	// Backwards
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

	return true;
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

			strcopy(id, sizeof(id), name);
			amount = size;
			i++;
			return true;
		}
	}

	return false;
}

void SkillTree_ApplyAttribs(int client, StringMap map)
{
	if(CvarSkillPoints.BoolValue && SkillList && SkillCount[client])
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
	if(CvarSkillPoints.BoolValue && SkillList && SkillCount[client])
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
	MainMenu(client);
}

Action SkillTree_PlayerRunCmd(int client, float vel[3])
{
	return Plugin_Continue;
}

static void MainMenu(int client)
{
	if(PointsSpent[client] == -1)
		SkillTree_CalcSkillPoints(client);
	
	int points = (Level[client] * POINTS_PER_LEVEL) - PointsSpent[client];
	
	Menu menu = new Menu(MainMenuH);

	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", "Skill Points", points);

	menu.AddItem(NULL_STRING, "Browse Skill Tree");
	menu.AddItem(NULL_STRING, "Reset Skill Tree");

	menu.Display(client, MENU_TIME_FOREVER);
}

static int MainMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			switch(choice)
			{
				case 0:
				{
					TreeMenu(client);

					if(InMenu[client] && CustomMusic.Path[0])
					{
						EmitCustomToClient(client, CustomMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, CustomMusic.Volume);
						
						if(CustomMusic.Name[0] || CustomMusic.Artist[0])
							CPrintToChat(client, "%t", "Now Playing Song", CustomMusic.Artist, CustomMusic.Name);
					}
				}
			}
		}
	}

	return 0;
}

// For Music
bool SkillTree_InMenu(int client)
{
	return InMenu[client];
}

static void TreeMenu(int client)
{
	if(PointsSpent[client] == -1)
		SkillTree_CalcSkillPoints(client);
	
	if(!SkillCount[client])
		SkillCount[client] = new StringMap();
	
	int points = (Level[client] * POINTS_PER_LEVEL) - PointsSpent[client];

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

	if(!SkillList.GetArray(Selected[client], skill, sizeof(skill)))
	{
		Selected[client][0] = 0;
		return;
	}

	SetGlobalTransTarget(client);

	int charge;
	SkillCount[client].GetValue(Selected[client], charge);

	bool access[4];
	char names[4][32], buffers[4][48];
	int length = SkillListSnap.Length;
	for(int i; i < length; i++)
	{
		int size = SkillListSnap.KeyBufferSize(i);
		char[] name = new char[size];
		SkillListSnap.GetKey(i, name, size);

		int dir = -1;
		bool parent;

		static Skill skill2;
		SkillList.GetArray(name, skill2, sizeof(skill2));
		if(StrEqual(skill2.Parent, Selected[client]))
		{
			// Child Node
			dir = skill2.Dir;
		}
		else if(StrEqual(skill.Parent, name))
		{
			// Parent Node
			dir = ReverseDir(skill.Dir);
			parent = true;
		}

		if(dir != -1)
		{
			strcopy(names[dir], sizeof(names[]), name);
			if(!parent && skill2.Key[0] && !Items_HasNamedItem(client, skill2.Key))
			{
				Format(buffers[dir], sizeof(buffers[]), "{%s}", skill2.Key);
			}
			else if(!parent && skill2.MinNeed > charge)
			{
				Format(buffers[dir], sizeof(buffers[]), "%t {%d}", skill2.Name, skill2.MinNeed);
			}
			else
			{
				SkillCount[client].GetValue(name, size);
				access[dir] = true;
				
				if(skill2.MaxCap > 1)
				{
					Format(buffers[dir], sizeof(buffers[]), "%t [%d/%d]", skill2.Name, size, skill2.MaxCap);
				}
				else
				{
					Format(buffers[dir], sizeof(buffers[]), "%t [%s]", skill2.Name, size ? "X" : "  ");
				}
			}
		}
	}

	static char buffer[512];
	static const char ArrowH[][] = { "< <", "> >" };

	// Left Side
	if(buffers[LEFT][0])
	{
		Format(buffer, sizeof(buffer), "%s %s [%s] %s", buffers[LEFT], ArrowH[skill.Dir == LEFT ? 1 : 0], access[LEFT] ? "A" : "  ", ArrowH[skill.Dir == LEFT ? 1 : 0]);
	}
	else
	{
		strcopy(buffer, sizeof(buffer), "                                ");
	}

	// Center
	if(skill.MaxCap > 1)
	{
		Format(buffer, sizeof(buffer), "%s %t [%d/%d]", buffer, skill.Name, charge, skill.MaxCap);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s %t [%s]", buffer, skill.Name, charge ? "X" : "  ");
	}

	// Count spaces from the left side
	length = strlen(buffer);
	int leftSize = length * 2;
	for(int i; i < length; i++)
	{
		if(buffer[i] == ' ')
			leftSize--;
	}

	leftSize -= strlen(skill.Name);

	char leftBuffer[20];	// Space cap
	if(leftSize > (sizeof(leftBuffer) - 2))
		leftSize = sizeof(leftBuffer) - 2;
	
	for(int i; i < leftSize; i++)
	{
		leftBuffer[i] = ' ';
	}

	// Right Side
	if(buffers[RIGHT][0])
	{
		FormatEx(buffer, sizeof(buffer), "%s %s [%s] %s", buffers[RIGHT], ArrowH[skill.Dir == RIGHT ? 0 : 1], access[RIGHT] ? "D" : "  ", ArrowH[skill.Dir == RIGHT ? 0 : 1]);
	}

	// Top Side
	if(buffers[UP][0])
	{
		FormatEx(buffer, sizeof(buffer), "%s%s\n%s%s\n%s%s\n%s[%s]\n%s%s\n%s%s\n%s", leftBuffer, buffers[UP],
											leftBuffer, skill.Dir == UP ? "v" : "^",
											leftBuffer, skill.Dir == UP ? "v" : "^",
											leftBuffer, access[UP] ? "W" : "  ",
											leftBuffer, skill.Dir == UP ? "v" : "^",
											leftBuffer, skill.Dir == UP ? "v" : "^",
											buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), " \n \n \n \n \n \n%s", buffer);
	}

	// Bottom Side
	if(buffers[DOWN][0])
	{
		FormatEx(buffer, sizeof(buffer), "%s\n%s%s\n%s%s\n%s%s\n%s[%s]\n%s%s\n%s%s", buffer,
											leftBuffer, buffers[DOWN],
											leftBuffer, skill.Dir == DOWN ? "^" : "v",
											leftBuffer, skill.Dir == DOWN ? "^" : "v",
											leftBuffer, access[DOWN] ? "S" : "  ",
											leftBuffer, skill.Dir == DOWN ? "^" : "v",
											leftBuffer, skill.Dir == DOWN ? "^" : "v");
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s\n \n \n \n \n \n ", buffer);
	}

	Format(buffers[0], sizeof(buffers[]), "%s Desc", skill.Name);
	
	Menu menu = new Menu(TreeMenuH);
	menu.SetTitle("%t\n \n%s\n \n%t", "TF2: Zombie Riot", buffer, buffers[0]);

	bool upgrade;
	
	if(!charge)
	{
		Format(buffer, sizeof(buffer), "%t (%d / %d)", "Unlock Skill", points, skill.Cost);
		upgrade = points >= skill.Cost;
	}
	else if(skill.MaxCap > 1)
	{
		if(charge >= skill.MaxCap)
		{
			Format(buffer, sizeof(buffer), "%t", "Fully Upgraded");
		}
		else
		{
			Format(buffer, sizeof(buffer), "%t (%d / %d)", "Upgrade Skill", points, skill.Cost);
			upgrade = points >= skill.Cost;
		}
	}
	else
	{
		Format(buffer, sizeof(buffer), "%t", "Unlocked");
	}

	menu.AddItem(NULL_STRING, buffer, upgrade ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem(names[UP], "W", access[UP] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[LEFT], "A", access[LEFT] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[DOWN], "S", access[DOWN] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[RIGHT], "D", access[RIGHT] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);

	InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
}

static int TreeMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;
			
			if(InMenu[client] && CustomMusic.Path[0])
				StopCustomSound(client, SNDCHAN_STATIC, CustomMusic.Path);

			if(choice == MenuCancel_Exit)
				MainMenu(client);
		}
		case MenuAction_Select:
		{
			InMenu[client] = false;

			static Skill skill;
			if(SkillList.GetArray(Selected[client], skill, sizeof(skill)))
			{
				if(choice)
				{
					menu.GetItem(choice, Selected[client], sizeof(Selected[]));
				}
				else
				{
					ClientCommand(client, "playgamesound ui/mm_xp_chime.wav");

					int amount;
					SkillCount[client].GetValue(Selected[client], amount);
					SkillCount[client].SetValue(Selected[client], amount + 1);
				}

				TreeMenu(client);
			}
		}
	}

	return 0;
}