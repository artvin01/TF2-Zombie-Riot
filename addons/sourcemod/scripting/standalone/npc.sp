#pragma semicolon 1
#pragma newdecls required

static ArrayList NPCList;

enum struct NPCData
{
	char Plugin[64];
	char Name[64];
	Function Func;
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

	HeadcrabZombie_Precache();
	CombinePolicePistol_Precache();
	MyNPCs();
}

#include "npc/npc_headcrabzombie.sp"
#include "npc/npc_combine_police_pistol.sp"
#include "mynpcs.sp"

int NPC_Add(NPCData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	if(!TranslationPhraseExists(data.Name))
	{
		LogError("Translation '%s' does not exist", data.Name);
		strcopy(data.Name, sizeof(data.Name), "nothing");
	}
	
	return NPCList.PushArray(data);
}

stock int NPC_GetNameById(int id, char[] buffer, int length)
{
	static NPCData data;
	NPC_GetById(id, data);
	return strcopy(buffer, length, data.Name);
}

stock int NPC_GetNameByPlugin(const char[] name, char[] buffer, int length)
{
	static NPCData data;
	int lengt = NPCList.Length;
	for(int i; i < lengt; i++)
	{
		NPCList.GetArray(i, data);
		if(StrEqual(name, data.Plugin))
			return strcopy(buffer, length, data.Name);
	}
	return 0;
}

void NPC_GetById(int id, NPCData data)
{
	NPCList.GetArray(id, data);
}

int NPC_GetByPlugin(const char[] name, NPCData data = {})
{
	int length = NPCList.Length;
	for(int i; i < length; i++)
	{
		NPCList.GetArray(i, data);
		if(StrEqual(name, data.Plugin))
			return i;
	}
	return -1;
}

int NPC_CreateByName(const char[] name, int client, const float vecPos[3], const float vecAng[3], int team, const char[] data = "")
{
	static NPCData npcdata;
	int id = NPC_GetByPlugin(name, npcdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid NPC!", name);
		return -1;
	}

	return CreateNPC(npcdata, id, client, vecPos, vecAng, team, data);
}

static int CreateNPC(const NPCData npcdata, int id, int client, const float vecPos[3], const float vecAng[3], int team, const char[] data)
{
	int entity = -1;
	Call_StartFunction(null, npcdata.Func);
	Call_PushCell(client);
	Call_PushArray(vecPos, sizeof(vecPos));
	Call_PushArray(vecAng, sizeof(vecAng));
	Call_PushCell(team);
	Call_PushString(data);
	Call_Finish(entity);
	
	if(entity > 0)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), npcdata.Name);
		
		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
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
