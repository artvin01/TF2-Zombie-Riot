#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectDecorative_MapStart()
{
	PrecacheModel("models/props_mvm/mvm_museum_pedestal.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Decorative Object");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_decorative");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_decorative");
	build.Cost = 25;
	build.Health = 50;
	build.HealthScaleCost = true;
	build.Cooldown = 10.0;
	build.Func = ObjectDecorative_CanBuild;
	Building_Add(build);
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
		ObjectDecorative npc = view_as<ObjectDecorative>(ObjectGeneric(client, vecPos, vecAng, "models/props_mvm/mvm_museum_pedestal.mdl", _, "50",{15.0, 15.0, 47.0},_,false));
		
		npc.FuncCanBuild = ObjectDecorative_CanBuild;

		return npc;
	}
}

public bool ObjectDecorative_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectDecorative_Buildings(client);
		maxcount = 2;
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
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
		if(owner == -1 || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			if(NPCId == i_NpcInternalId[entity])
				count++;
		}
	}

	return count;
}