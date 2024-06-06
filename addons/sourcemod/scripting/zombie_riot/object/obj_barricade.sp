#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectBarricade_MapStart()
{
	PrecacheModel("models/props_gameplay/sign_barricade001a.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barricade");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_barricade");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectBarricade(client, vecPos, vecAng);
}

methodmap ObjectBarricade < ObjectGeneric
{
	public ObjectBarricade(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectBarricade npc = view_as<ObjectBarricade>(ObjectGeneric(client, vecPos, vecAng, "models/props_gameplay/sign_barricade001a.mdl", _, "6000"));
		
		npc.FuncCanBuild = ClotCanBuild;

		return npc;
	}
}

static bool ClotCanBuild(ObjectBarricade npc, int client)
{
	if(client && ObjectBarricade_Buildings(client) > 3)
		return false;
	
	return true;
}

int ObjectBarricade_Buildings(int owner)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(!b_NpcHasDied[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			if(NPCId == i_NpcInternalId[entity])
				count++;
		}
	}

	return count;
}