#pragma semicolon 1
#pragma newdecls required

enum struct ClassData
{
	char Race[64];
	char Name[64];
	char Func[32];

	void Setup(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));
		if(!this.Name[0] || !TranslationPhraseExists(this.Name))
		{
			LogError("[Config] Missing translation '%s' in '%s'", this.Name, this.Race);
			strcopy(this.Name, sizeof(this.Name), "nothing");
		}

		kv.GetString("function", this.Func, sizeof(this.Func));
	}
}

static ArrayList ClassList;

void Classes_ConfigSetup()
{
	delete ClassList;
	ClassList = new ArrayList(sizeof(ClassData));

	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "classes");
	KeyValues kv = new KeyValues("Classes");
	kv.ImportFromFile(buffer);

	ClassData data;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(data.Race, sizeof(data.Race));
		if(!data.Race[0] || !TranslationPhraseExists(data.Race))
		{
			LogError("[Config] Missing translation '%s'", data.Race);
			strcopy(data.Race, sizeof(data.Race), "nothing");
		}

		kv.GotoFirstSubKey();
		do
		{
			data.Setup(kv);
			ClassList.PushArray(data);
		}
		while(kv.GotoNextKey());

		kv.GoBack();
	}
	while(kv.GotoNextKey());

	delete kv;
}

void Classes_NPCSpawn(int entity, const NPCData data, int team)
{
	if(StartTeamFunc(team, "NPCSpawn"))
	{
		Call_PushCell(entity);
		Call_PushArray(data, sizeof(data));
		Call_Finish();
	}
}

static bool StartTeamFunc(int team, const char[] name)
{
	static ClassData data;
	ClassList.GetArray(TeamClass[team], data);

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%s_%s", data.Func, name);

	Function func = GetFunctionByName(null, buffer);
	if(func == INVALID_FUNCTION)
		return false;
	
	Call_StartFunction(null, func);
	Call_PushCell(team);
	return true;
}

#include "fortress_wars/class/empire/class_base_empire.sp"
