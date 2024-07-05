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

int ObjectBarricade_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectBarricade(client, vecPos, vecAng);
}

methodmap ObjectBarricade < ObjectGeneric
{
	public ObjectBarricade(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectBarricade npc = view_as<ObjectBarricade>(ObjectGeneric(client, vecPos, vecAng, "models/props_gameplay/sign_barricade001a.mdl", _, "600",{20.0, 20.0, 63.0},_,false));
		
		npc.FuncCanBuild = ObjectBarricade_CanBuild;

		return npc;
	}
}

public bool ObjectBarricade_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectBarricade_Buildings(client) + ActiveCurrentNpcsBarracks(client, true);
		maxcount = Merchant_IsAMerchant(client) ? 0 : 4;
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

public bool ObjectBarricade_CanBuildCheap(int client, int &count, int &maxcount)
{
	if(!ObjectBarricade_CanBuild(client, count, maxcount))
		return false;
	
	if(client)
	{
		count = 0;
		maxcount = (Level[client] > 19 || CvarInfiniteCash.BoolValue) ? 1 : 0;
		if(count >= maxcount)
			return false;
	}

	return true;
}

int ObjectBarricade_Buildings(int owner)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			if(NPCId == i_NpcInternalId[entity])
				count++;
		}
	}

	return count;
}