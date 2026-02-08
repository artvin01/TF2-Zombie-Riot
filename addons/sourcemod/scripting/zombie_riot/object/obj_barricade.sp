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

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_barricade");
	build.Cost = 538;
	build.Health = 420;
	build.HealthScaleCost = true;
	build.Cooldown = 15.0;
	build.Func = ObjectBarricade_CanBuild;
	Building_Add(build);
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
		if(Merchant_IsAMerchant(client))
		{
			maxcount = 0;
		}
		else if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES)
		{
			maxcount = 1;
		}
		else
		{
			maxcount = Object_MaxSupportBuildings(client);
			if(maxcount > 4)
				maxcount = 4;
		}
		
		int total;
		count = ObjectBarricade_Buildings(client, total) + ObjectRevenant_Buildings(client)/* + ActiveCurrentNpcsBarracks(client, true)*/;
		
		if(count >= maxcount || total > 19)
			return false;
	}
	
	return true;
}

int ObjectBarricade_Buildings(int owner, int &total = 0)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
		if(NPCId == i_NpcInternalId[entity])
		{
			total++;
			if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
				count++;
		}
	}

	return count;
}