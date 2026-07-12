#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ObjectExplosive_MapStart()
{
	PrecacheModel("models/props_2fort/oildrum.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Explosive Barrel");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_decorativeexplosive");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_decorativeexplosive");
	build.Cost = 100;
	build.Health = 30;
	build.Cooldown = 10.0;
	build.Func = CanBuild;
	Building_Add(build);
}

int ObjectExplosive_Id()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectExplosive(client, vecPos, vecAng);
}

methodmap ObjectExplosive < ObjectGeneric
{
	public ObjectExplosive(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectExplosive npc = view_as<ObjectExplosive>(ObjectGeneric(client, vecPos, vecAng, "models/props_2fort/oildrum.mdl", _, "50", {17.0, 17.0, 56.0}, _, false));
		
		npc.FuncCanBuild = CanBuild;
		func_NPCDeath[npc.index] = ClotDeath;

		return npc;
	}
}

static bool CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = ObjectDecorative_Buildings(client);
		maxcount = Gunsaw_IsMerc(client) ? 2 : 0;
		if(count >= maxcount)
			return false;
	}
	
	//no more then 15 decos, as its litterally just deco
	//if(ObjectDecorative_Buildings(-1) > 15)
	//	return false;
	
	return true;
}

static void ClotDeath(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner > 0 && owner <= MaxClients)
	{
		float radius = 150.0 * Attributes_GetOnPlayer(owner, 344, true, true);
		float damage = 200.0 * Attributes_GetOnPlayer(owner, 287, true) / Attributes_GetOnPlayer(owner, 343, true, true);
		
		float pos[3];
		WorldSpaceCenter(entity, pos);
		TE_Particle("ExplosionCore_buildings", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		Explode_Logic_Custom(damage, owner, owner, -1, pos, radius);
	}
}