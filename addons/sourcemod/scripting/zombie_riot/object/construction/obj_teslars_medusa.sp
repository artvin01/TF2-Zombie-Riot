#pragma semicolon 1
#pragma newdecls required

static char g_ShootingSound[][] = {
	"npc/scanner/scanner_electric2.wav",
};

static int NPCId;
void Object_TeslarsMedusa_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/buildables/sentry_shield.mdl");
	PrecacheModel("models/props_moonbase/moon_gravel_crystal.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Teslar's Medusa");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_teslarsmedusa");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_teslarsmedusa");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Object_TeslarsMedusa(client, vecPos, vecAng);
}

methodmap Object_TeslarsMedusa < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(95, 110));
	}
	public Object_TeslarsMedusa(int client, const float vecPos[3], const float vecAng[3])
	{
		Object_TeslarsMedusa npc = view_as<Object_TeslarsMedusa>(ObjectGeneric(client, vecPos, vecAng, "models/props_moonbase/moon_gravel_crystal.mdl", "0.85", "50", {25.0, 25.0, 75.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = Object_TeslarsMedusa_ClotThink;

		int entity = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl", "idle", .model_size = 1.1);
		npc.m_iWearable5 = entity;

		return npc;
	}
}

void Object_TeslarsMedusa_ClotThink(Object_TeslarsMedusa npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 1.0;


	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = 700.0;

		npc.m_iTarget = GetClosestTarget(npc.index,_,DistanceLimit,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}

	Handle swingTrace;

	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }, .Npc_type = 3)) //3 is aim bot no matter where they look
	{
		int target = TR_GetEntityIndex(swingTrace);	

		if(IsValidEnemy(npc.index, target))
		{
			npc.PlayShootSound();
			float damagedeal = 30000.0;

			if(Construction_GetRisk() >= 6)
				damagedeal *= 2.0;
			static float AbsOrigin[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
			AbsOrigin[2] += 80.0;
			Passanger_Lightning_Strike(Owner, target, -2, damagedeal, AbsOrigin, true);
		}
	}
	delete swingTrace;
}


static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Teslar's Medusa"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;

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
