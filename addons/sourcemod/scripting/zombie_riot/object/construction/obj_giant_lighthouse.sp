#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectConstruction_LightHouse_MapStart()
{
	PrecacheModel("models/props_sunshine/lighthouse_blu_bottom.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Giant Lighthouse");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_lighthouse");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_lighthouse");
	build.Cost = 1000;
	build.Health = 100;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

stock int ObjectConstruction_LightHouse_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectConstruction_LightHouse(client, vecPos, vecAng);
}

methodmap ObjectConstruction_LightHouse < ObjectGeneric
{
	public ObjectConstruction_LightHouse(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectConstruction_LightHouse npc = view_as<ObjectConstruction_LightHouse>(ObjectGeneric(client, vecPos, vecAng, "models/props_sunshine/lighthouse_blu_bottom.mdl", "0.3", "600",{30.0, 30.0, 80.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		npc.m_bConstructBuilding = true;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Giant Lighthouse"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 2;

		if(Construction_HasNamedResearch("Base Level III"))
			maxcount++;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static void ClotThink(ObjectSentrygun npc)
{
	LighthouseGiveBuff(npc.index, 2000.0);
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}

static void LighthouseGiveBuff(int iNpc, float range = 2000.0)
{
	b_NpcIsTeamkiller[iNpc] = true;
	float spawnLoc[3]; 	
	WorldSpaceCenter(iNpc, spawnLoc);
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	spawnLoc,
	range,
	_,
	_,
	true,
	99,
	false,
	_,
	LighthouseGiveBuffDo);
	b_NpcIsTeamkiller[iNpc] = false;
}

static void LighthouseGiveBuffDo(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		ApplyStatusEffect(entity, victim, "Lighthouse Enlightment", 1.0);
	}
}

