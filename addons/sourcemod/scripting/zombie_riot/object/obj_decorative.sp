#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectDecorative_MapStart()
{
	PrecacheModel("models/props_gameplay/sign_barricade001a.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Decorative Object");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_decorative");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}
//This is a reclassification of the elevator.

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDecorative(client, vecPos, vecAng);
}

methodmap ObjectDecorative < ObjectGeneric
{
	public ObjectDecorative(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectDecorative npc = view_as<ObjectDecorative>(ObjectGeneric(client, vecPos, vecAng, "models/props_gameplay/sign_barricade001a.mdl", _, "250"));
		
		npc.FuncCanBuild = ObjectDecorative_CanBuild;

		return npc;
	}
}

bool ObjectDecorative_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectBarricade_Buildings(client);
		maxcount = 7;
		if(count >= maxcount)
			return false;
	}
	
	//no more then 15 decos, as its litterally just deco
	if(ObjectDecorative_Buildings(-1) > 15)
		return false;
	
	return true;
}

int ObjectDecorative_Buildings(int owner)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(!b_NpcHasDied[entity] && owner == -1 || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			if(NPCId == i_NpcInternalId[entity])
				count++;
		}
	}

	return count;
}