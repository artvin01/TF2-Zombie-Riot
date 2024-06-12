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
/*
enum
{
	BuildingNone = 0,				Done					
	BuildingBarricade = 1,			Done			
	BuildingElevator = 2,			Done			
	BuildingAmmobox = 3,			Done			
	BuildingArmorTable = 4,			Done			
	BuildingPerkMachine = 5,		Done				
	BuildingPackAPunch = 6,			Done			
	BuildingRailgun = 7,						
	BuildingSentrygun = 8,						
	BuildingMortar = 9,						
	BuildingHealingStation = 10,						
	BuildingSummoner = 11,						
	BuildingVillage = 12,						
	BuildingBlacksmith = 13						
}
*/

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

bool ObjectBarricade_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectBarricade_Buildings(client);
		maxcount = 4;
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

int ObjectBarricade_Buildings(int owner)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_*")) != -1)
	{
		if(!b_NpcHasDied[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			if(NPCId == i_NpcInternalId[entity])
				count++;
		}
	}

	return count;
}