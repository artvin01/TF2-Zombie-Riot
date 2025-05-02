#pragma semicolon 1
#pragma newdecls required

static int NPCId1;
static int NPCId2;
static int NPCId3;

void ObjectWall_MapStart()
{
	PrecacheModel("models/props_hydro/metal_barrier01.mdl");

	NPCData data;
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;

	BuildingInfo build;
	build.Section = 2;

	strcopy(data.Name, sizeof(data.Name), "Small Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_wall1");
	data.Func = ClotSummon1;
	NPCId1 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_wall1");
	build.Cost = 807;
	build.Health = 630;
	build.HealthScaleCost = true;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild1;
	Building_Add(build);

	strcopy(data.Name, sizeof(data.Name), "Large Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_wall2");
	data.Func = ClotSummon2;
	NPCId2 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_wall2");
	build.Cost = 1076;
	build.Health = 840;
	build.HealthScaleCost = true;
	build.Cooldown = 45.0;
	build.Func = ClotCanBuild2;
	Building_Add(build);

	strcopy(data.Name, sizeof(data.Name), "Extreme Construct Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_wall3");
	data.Func = ClotSummon3;
	NPCId3 = NPC_Add(data);

	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_wall3");
	build.Cost = 1614;
	build.Health = 1260;
	build.HealthScaleCost = true;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild3;
	Building_Add(build);
}

static any ClotSummon1(int client, float vecPos[3], float vecAng[3])
{
	return ObjectWall1(client, vecPos, vecAng);
}

methodmap ObjectWall1 < ObjectGeneric
{
	public ObjectWall1(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectWall1 npc = view_as<ObjectWall1>(ObjectGeneric(client, vecPos, vecAng, "models/props_hydro/metal_barrier01.mdl", _, "600", {49.0, 49.0, 100.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild1;
		npc.m_bConstructBuilding = true;

		return npc;
	}
}

static bool ClotCanBuild1(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Base Level I"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 3;
		
		if(Construction_HasNamedResearch("Base Level II"))
			maxcount += 2;
		
		if(Construction_HasNamedResearch("Base Level III"))
			maxcount += 2;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static any ClotSummon2(int client, float vecPos[3])
{
	return ObjectWall2(client, vecPos);
}

methodmap ObjectWall2 < ObjectGeneric
{
	public ObjectWall2(int client, const float vecPos[3])
	{
		ObjectWall2 npc = view_as<ObjectWall2>(ObjectGeneric(client, vecPos, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.7", "600", {40.0, 40.0, 70.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild2;
		npc.m_bConstructBuilding = true;

		float VecLeft[3];
		VecLeft = vecPos;

		VecLeft[1] += 40.0;
		ObjectWall2 npc_left = view_as<ObjectWall2>(ObjectGeneric(client, VecLeft, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {40.0, 40.0, 70.0},_,false));
		npc.m_iExtrabuilding1 = npc_left.index;
		npc_left.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_left.index, "root",{0.0, 40.0, 0.0}, true);
		
		float Vecright[3];
		Vecright = vecPos;

		Vecright[1] -= 40.0;
		ObjectWall2 npc_right = view_as<ObjectWall2>(ObjectGeneric(client, Vecright, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {40.0, 40.0, 70.0},_,false));
		npc.m_iExtrabuilding2 = npc_right.index;
		npc_right.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_right.index, "root",{0.0, -40.0, 0.0}, true);

		return npc;
	}
}

static bool ClotCanBuild2(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Base Level II"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 5;
		
		if(Construction_HasNamedResearch("Base Level III"))
			maxcount += 4;
		
		if((count + 1) >= maxcount)
			return false;
	}
	
	return true;
}

static any ClotSummon3(int client, float vecPos[3])
{
	return ObjectWall3(client, vecPos);
}

methodmap ObjectWall3 < ObjectGeneric
{
	public ObjectWall3(int client, const float vecPos[3])
	{
	//	ObjectWall3 npc = view_as<ObjectWall3>(ObjectGeneric(client, vecPos, vecAng, "models/props_hydro/metal_barrier03.mdl", "0.9", "600", {192.0, 192.0, 177.0},_,false));
		ObjectWall3 npc = view_as<ObjectWall3>(ObjectGeneric(client, vecPos, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		
		npc.FuncCanBuild = ClotCanBuild3;
		npc.m_bConstructBuilding = true;
		
		float VecLeft[3];
		VecLeft = vecPos;

		VecLeft[1] += 50.0;
		ObjectWall3 npc_left = view_as<ObjectWall3>(ObjectGeneric(client, VecLeft, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		npc.m_iExtrabuilding1 = npc_left.index;
		npc_left.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_left.index, "root",{0.0, 50.0, 0.0}, true);
		
		float Vecright[3];
		Vecright = vecPos;

		Vecright[1] -= 50.0;
		ObjectWall3 npc_right = view_as<ObjectWall3>(ObjectGeneric(client, Vecright, {0.0,0.0,0.0}, "models/props_hydro/metal_barrier02.mdl", "0.8", "600", {50.0, 50.0, 80.0},_,false));
		npc.m_iExtrabuilding2 = npc_right.index;
		npc_right.m_iMasterBuilding = npc.index;
		SetParent(npc.index, npc_right.index, "root",{0.0, -50.0, 0.0}, true);

		return npc;
	}
}

static bool ClotCanBuild3(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Base Level III"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 7;
		
		if((count + 2) >= maxcount)
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
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
		{
			ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
			if(IsValidEntity(objstats.m_iMasterBuilding))
				continue;

			if(NPCId1 == i_NpcInternalId[entity])
				count++;
			
			if(NPCId2 == i_NpcInternalId[entity])
				count += 2;
			
			if(NPCId3 == i_NpcInternalId[entity])
				count += 3;
		}
	}

	return count;
}
