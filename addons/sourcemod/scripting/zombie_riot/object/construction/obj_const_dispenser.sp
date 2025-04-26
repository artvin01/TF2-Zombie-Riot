#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectDispenser_MapStart()
{
	PrecacheModel("models/buildables/dispenser_lvl3_light.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Dispenser");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_dispenser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_dispenser");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectDispenser(client, vecPos, vecAng);
}

methodmap ObjectDispenser < ObjectGeneric
{
	public ObjectDispenser(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectDispenser npc = view_as<ObjectDispenser>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/dispenser_lvl3_light.mdl", "1.0", "50", {26.0, 26.0, 67.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

static void ClotThink(ObjectDispenser npc)
{
	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.5;

	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(0.0,
	npc.index,
	npc.index,
	-1,
	_,
	350.0,
	_,
	_,
	true,
	99,
	false,
	_,
	DispenserExplode);
	b_NpcIsTeamkiller[npc.index] = false;
}

static void DispenserExplode(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if(GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		HealEntityGlobal(entity, victim, 20.0, _, 0.5);
		if(victim <= MaxClients)
			TF2_AddCondition(victim, TFCond_InHealRadius, 0.6);
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("The Dispenser"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;

		if(Construction_HasNamedResearch("Base Level III"))
			maxcount++;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
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
