#pragma semicolon 1
#pragma newdecls required

static ArrayList NPCList;

enum struct NPCData
{
	char Plugin[32];
	char Name[32];
	Function Func;

	int Price[Resource_MAX];
	float TrainTime;
}

int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	if(!TranslationPhraseExists(data.Name))
	{
		LogError("Translation '%s' does not exist", data.Name);
		strcopy(data.Name, sizeof(data.Name), "nothing");
	}
	
	char buffer[32];
	FormatEx(buffer, sizeof(buffer), "%s Desc", data.Name);
	if(!TranslationPhraseExists(buffer))
		LogError("Translation '%s' does not exist", buffer);
	
	return NPCList.PushArray(data);
}

int NPC_GetNameById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Name);
}

stock int NPC_GetNameByPlugin(const char[] name, char[] buffer, int length)
{
	int index = NPCList.FindString(name, NPCData::Plugin);
	if(index == -1)
		return 0;
	
	static NPCData data;
	NPCList.GetArray(index, data);
	return strcopy(buffer, length, data.Name);
}

void NPC_GetById(int id, NPCData data)
{
	NPCList.GetArray(id, data);
}

int NPC_GetByPlugin(const char[] name, NPCData data = {})
{
	int index = NPCList.FindString(name, NPCData::Plugin);
	if(index == -1)
		return 0;
	
	NPCList.GetArray(index, data);
	return index;
}

int NPC_CreateByName(const char[] name, int team, const float vecPos[3], const float vecAng[3], const char[] data = "")
{
	static NPCData npcdata;
	int id = NPC_GetByPlugin(name, npcdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid NPC!", name);
		return -1;
	}

	return CreateNPC(npcdata, id, team, vecPos, vecAng, data);
}

int NPC_CreateById(int id, int team, const float vecPos[3], const float vecAng[3], const char[] data = "")
{
	static NPCData npcdata;
	NPCList.GetArray(id, npcdata);
	return CreateNPC(npcdata, id, team, vecPos, vecAng, data);
}

static int CreateNPC(const NPCData npcdata, int id, int team, const float vecPos[3], const float vecAng[3], const char[] data)
{
	int entity = -1;
	Call_StartFunction(null, npcdata.Func);
	Call_PushCell(team);
	Call_PushArray(vecPos, sizeof(vecPos));
	Call_PushArray(vecAng, sizeof(vecAng));
	Call_PushString(data);
	Call_Finish(entity);
	
	if(entity > 0)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), npcdata.Name);
		
		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
		
		Classes_NPCSpawn(entity, npcdata, team);
	}

	return entity;
}

void NPCDeath(int entity)
{
	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
	}
}

void NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Function func = func_NPCOnTakeDamage[victim];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish();
	}
}

// FileNetwork_ConfigSetup needs to be ran first
void NPC_ConfigSetup()
{
	delete NPCList;
	NPCList = new ArrayList(sizeof(NPCData));

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nothing");
	data.Func = INVALID_FUNCTION;
	NPCList.PushArray(data);

	UnitBody_Setup();
	EmpireBody_Setup();
	Militia_Setup();
	Villager_Setup();
}

#include "fortress_wars/npc/npc_base.sp"

#include "fortress_wars/npc/empire/npc_base_empire.sp"
#include "fortress_wars/npc/empire/npc_militia.sp"
#include "fortress_wars/npc/empire/npc_villager.sp"
