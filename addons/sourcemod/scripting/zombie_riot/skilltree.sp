#pragma semicolon 1
#pragma newdecls required

#define POINTS_PER_LEVEL	2

enum
{
	RIGHT = 0,
	DOWN,
	LEFT,
	UP,

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
static bool CanAccess[MAXTF2PLAYERS][DIR_MAX+1];
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
	
	if(SkillList.ContainsKey(parent))
	{
		LogError("Duplicate entry \"%s\" skill", parent);
		return false;
	}

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
			if(dir >= DIR_MAX)
				dir = 0;
			
			if(ReverseDir(intDir) == dir)	// Backwards
				dir++;
			
			if(dir >= DIR_MAX)
				dir = 0;

			if(dir == intDir)
			{
				if(kv.GotoNextKey())
					LogError("\"%s\" skill has too many subtrees", parent);

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

bool SkillTree_GetNext(int client, int &i, char id[32], int &amount)
{
	if(SkillCount[client])
	{
		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		if(i < length)
		{
			SkillCountSnap[client].GetKey(i, id, sizeof(id));
			SkillCount[client].GetValue(id, amount);
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
		StringMap map = new StringMap();

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

int SkillTree_GetByName(int client, const char[] name)
{
	int amount;

	if(SkillCount[client])
	{
		if(!SkillCountSnap[client])
			SkillCountSnap[client] = SkillCount[client].Snapshot();
		
		int length = SkillCountSnap[client].Length;
		for(int i; i < length; i++)
		{
			int size = SkillCountSnap[client].KeyBufferSize(i);
			char[] id = new char[size];
			SkillCountSnap[client].GetKey(i, id, size);

			static Skill skill;
			SkillList.GetArray(id, skill, sizeof(skill));
			if(StrEqual(skill.Name, name))
			{
				SkillCount[client].GetValue(id, size);
				amount += size;
			}
		}
	}

	return amount;
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

int SkillTree_UnspentPoints(int client)
{
	return (Level[client] * POINTS_PER_LEVEL) - PointsSpent[client];
}

void SkillTree_OpenMenu(int client)
{
	MainMenu(client);
}

bool SkillTree_PlayerRunCmd(int client, int &buttons, float vel[3])
{
	if(!InMenu[client])
		return false;
	
	static bool holding[MAXTF2PLAYERS][DIR_MAX+1];
	if(holding[client][UP])
	{
		if(vel[0] < 250.0)
			holding[client][UP] = false;
	}
	else if(vel[0] > 250.0)
	{
		holding[client][UP] = true;
		if(CanAccess[client][UP])
			FakeClientCommand(client, "menuselect 2");
	}
	
	if(holding[client][DOWN])
	{
		if(vel[0] > -250.0)
			holding[client][DOWN] = false;
	}
	else if(vel[0] < -250.0)
	{
		holding[client][DOWN] = true;
		if(CanAccess[client][DOWN])
			FakeClientCommand(client, "menuselect 4");
	}

	if(holding[client][RIGHT])
	{
		if(vel[1] < 250.0)
			holding[client][RIGHT] = false;
	}
	else if(vel[1] > 250.0)
	{
		holding[client][RIGHT] = true;
		if(CanAccess[client][RIGHT])
			FakeClientCommand(client, "menuselect 5");
	}
	
	if(holding[client][LEFT])
	{
		if(vel[1] > -250.0)
			holding[client][LEFT] = false;
	}
	else if(vel[1] < -250.0)
	{
		holding[client][LEFT] = true;
		if(CanAccess[client][LEFT])
			FakeClientCommand(client, "menuselect 3");
	}
	
	if(holding[client][DIR_MAX])
	{
		if(!(buttons & IN_JUMP))
			holding[client][DIR_MAX] = false;
	}
	else if(buttons & IN_JUMP)
	{
		holding[client][DIR_MAX] = true;
		if(CanAccess[client][DIR_MAX])
			FakeClientCommand(client, "menuselect 1");
	}

	buttons = 0;
	Zero(vel);
	return true;
}

static void MainMenu(int client)
{
	if(PointsSpent[client] == -1)
		SkillTree_CalcSkillPoints(client);
	
	int points = SkillTree_UnspentPoints(client);
	
	Menu menu = new Menu(MainMenuH);

	SetGlobalTransTarget(client);
	
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", "Skill Points", points);

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%t", "Browse Skill Tree");
	menu.AddItem(NULL_STRING, buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Reset Skill Tree");
	menu.AddItem(NULL_STRING, buffer);

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
						//Kill current music.
						Music_Stop_All(client);
						SetMusicTimer(client, GetTime() + 1);
						EmitCustomToClient(client, CustomMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, CustomMusic.Volume);
						
						if(CustomMusic.Name[0] || CustomMusic.Artist[0])
							CPrintToChat(client, "%t", "Now Playing Song", CustomMusic.Artist, CustomMusic.Name);
					}
				}
				case 1:
				{
					Menu menu2 = new Menu(ResetSkillH);

					SetGlobalTransTarget(client);
					
					menu2.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", "Reset Skill Tree Confirm");

					char buffer[64];
					FormatEx(buffer, sizeof(buffer), "%t", "Yes");
					menu2.AddItem(NULL_STRING, buffer);
					
					FormatEx(buffer, sizeof(buffer), "%t", "No");
					menu2.AddItem(NULL_STRING, buffer);

					menu2.Display(client, MENU_TIME_FOREVER);
				}
			}
		}
	}

	return 0;
}

static int ResetSkillH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_Exit)
				MainMenu(client);
		}
		case MenuAction_Select:
		{
			if(!choice)
				SkillTree_ClearClient(client);
			
			MainMenu(client);
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

	for(int i; i < sizeof(CanAccess[]); i++)
	{
		CanAccess[client][i] = false;
	}

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
			if(!parent && skill2.MinNeed > charge)
			{
				Format(buffers[dir], sizeof(buffers[]), "%c%c {%d}", skill2.Name[0], skill2.Name[1], skill2.MinNeed);
			}
			else
			{
				size = 0;
				SkillCount[client].GetValue(name, size);
				CanAccess[client][dir] = true;
				
				if(skill2.MaxCap > 1)
				{
					Format(buffers[dir], sizeof(buffers[]), "%c%c [%d/%d]", skill2.Name[0], skill2.Name[1], size, skill2.MaxCap);
				}
				else
				{
					Format(buffers[dir], sizeof(buffers[]), "%c%c [%s]", skill2.Name[0], skill2.Name[1], size ? "X" : "  ");
				}
			}
		}
	}

	static char buffer[512];
	static const char ArrowH[][] = { "< <", "> >" };

	// Left Side
	if(buffers[LEFT][0])
	{
		Format(buffer, sizeof(buffer), "%s %s [%s] %s", buffers[LEFT],
								ArrowH[skill.Dir == RIGHT ? 1 : 0],
								CanAccess[client][LEFT] ? "A" : "  ",
								ArrowH[skill.Dir == RIGHT ? 1 : 0]);
	}
	else
	{
		strcopy(buffer, sizeof(buffer), "										");
	}

	// Center
	if(skill.MaxCap > 1)
	{
		Format(buffer, sizeof(buffer), "%s (%t [%d/%d])", buffer, skill.Name, charge, skill.MaxCap);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s (%t [%s])", buffer, skill.Name, charge ? "X" : "  ");
	}

	// Count spaces from the left side
	int leftSize = strlen(buffer) - 3;

	char leftBuffer[12][20];	// Space cap
	if(leftSize > (sizeof(leftBuffer[]) - 2))
		leftSize = sizeof(leftBuffer[]) - 2;
	
	for(int i; i < leftSize; i++)
	{
		for(int a = 1; a < 11; a++)
		{
			leftBuffer[a][i] = GetURandomInt() % 99 ? '	' : '*';
		}
	}

	length = leftSize - (strlen(buffers[UP]) / 3);
	for(int i; i < length; i++)
	{
		leftBuffer[0][i] = GetURandomInt() % 99 ? '	' : '*';
	}

	length = leftSize - (strlen(buffers[DOWN]) / 3);
	for(int i; i < length; i++)
	{
		leftBuffer[11][i] = GetURandomInt() % 99 ? '	' : '*';
	}

	// Right Side
	if(buffers[RIGHT][0])
	{
		Format(buffer, sizeof(buffer), "%s %s [%s] %s %s", buffer,
								ArrowH[skill.Dir == LEFT ? 0 : 1],
								CanAccess[client][RIGHT] ? "D" : "  ",
								ArrowH[skill.Dir == LEFT ? 0 : 1],
								buffers[RIGHT]);
	}

	// Top Side
	if(buffers[UP][0])
	{
		Format(buffer, sizeof(buffer), "%s%s\n%s %s\n%s %s\n%s[%s]\n%s %s\n%s %s\n%s", leftBuffer[0], buffers[UP],
											leftBuffer[1], skill.Dir == DOWN ? "v" : "^",
											leftBuffer[2], skill.Dir == DOWN ? "v" : "^",
											leftBuffer[3], CanAccess[client][UP] ? "W" : "  ",
											leftBuffer[4], skill.Dir == DOWN ? "v" : "^",
											leftBuffer[5], skill.Dir == DOWN ? "v" : "^",
											buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s\n%s\n%s\n%s\n%s\n%s\n%s", leftBuffer[0],
											leftBuffer[1],
											leftBuffer[2],
											leftBuffer[3],
											leftBuffer[4],
											leftBuffer[5],
											buffer);
	}

	// Bottom Side
	if(buffers[DOWN][0])
	{
		Format(buffer, sizeof(buffer), "%s\n%s %s\n%s %s\n%s[%s]\n%s %s\n%s %s\n%s%s", buffer,
											leftBuffer[6], skill.Dir == UP ? "^" : "v",
											leftBuffer[7], skill.Dir == UP ? "^" : "v",
											leftBuffer[8], CanAccess[client][DOWN] ? "S" : "  ",
											leftBuffer[9], skill.Dir == UP ? "^" : "v",
											leftBuffer[10], skill.Dir == UP ? "^" : "v",
											leftBuffer[11], buffers[DOWN]);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%s\n%s\n%s\n%s\n%s\n%s\n%s", buffer,
											leftBuffer[6],
											leftBuffer[7],
											leftBuffer[8],
											leftBuffer[9],
											leftBuffer[10],
											leftBuffer[11]);
	}

	Format(buffers[0], sizeof(buffers[]), "%s Desc", skill.Name);
	
	Menu menu = new Menu(TreeMenuH);
	menu.SetTitle("%s\n \n%t", buffer, buffers[0]);

	bool upgrade;
	
	/*
	if(skill.Key[0] && !Items_HasNamedItem(client, skill.Key))
	{
		Format(buffer, sizeof(buffer), "Requires \"%s\"", skill.Key);
	}
	else 
	*/
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

	CanAccess[client][DIR_MAX] = upgrade;

	menu.AddItem(NULL_STRING, buffer, upgrade ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem(names[UP], "W", CanAccess[client][UP] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[LEFT], "A", CanAccess[client][LEFT] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[DOWN], "S", CanAccess[client][DOWN] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);
	menu.AddItem(names[RIGHT], "D", CanAccess[client][RIGHT] ? ITEMDRAW_DEFAULT : ITEMDRAW_SPACER);

	menu.OptionFlags |= MENUFLAG_NO_SOUND;
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
			
			if(CustomMusic.Path[0])
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
					char buffer[64];
					FormatEx(buffer, sizeof(buffer), "ui/hitsound_electro%d.wav", 1 + (GetURandomInt() % 3));
					EmitSoundToClient(client, buffer, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.6, GetRandomInt(80,85));
					
					menu.GetItem(choice, Selected[client], sizeof(Selected[]));
				}
				else
				{
					EmitSoundToClient(client, "ui/hitsound_space.wav", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.6, GetRandomInt(50,55));

					int amount;
					SkillCount[client].GetValue(Selected[client], amount);
					SkillCount[client].SetValue(Selected[client], amount + 1);
					PointsSpent[client] += skill.Cost;

					delete SkillCountSnap[client];
				}

				TreeMenu(client);
			}
		}
	}

	return 0;
}

#include "zombie_riot/skilltree/player.sp"
#include "zombie_riot/skilltree/weapon.sp"