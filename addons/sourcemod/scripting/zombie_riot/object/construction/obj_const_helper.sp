#pragma semicolon 1
#pragma newdecls required

static int ExpiId;
static int RuniaId;

void ObjectHelper_MapStart()
{
	PrecacheModel("models/props_lab/teleportframe.mdl");
	PrecacheModel("models/items/crystal_ball_pickup_major.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Expidonsa Barracks");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_help_expi");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotExpiSummon;
	ExpiId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_help_expi");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);

	strcopy(data.Name, sizeof(data.Name), "Ruina Barracks");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_help_ruina");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotRuinaSummon;
	RuniaId = NPC_Add(data);

	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_help_ruina");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotExpiSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectHelpExpi(client, vecPos, vecAng);
}

methodmap ObjectHelpExpi < ObjectGeneric
{
	public ObjectHelpExpi(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectHelpExpi npc = view_as<ObjectHelpExpi>(ObjectGeneric(client, vecPos, vecAng, "models/props_lab/teleportframe.mdl", _, "600", {83.0, 83.0, 292.0}, _, false));
		
		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		
		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 30.0;

		return npc;
	}
}

static any ClotRuinaSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectHelpRuina(client, vecPos, vecAng);
}

methodmap ObjectHelpRuina < ObjectGeneric
{
	public ObjectHelpRuina(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectHelpRuina npc = view_as<ObjectHelpRuina>(ObjectGeneric(client, vecPos, vecAng, "models/items/crystal_ball_pickup_major.mdl", _, "600", {25.0, 25.0, 69.0}, _, false));
		
		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		
		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 30.0;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Ally Assistance"))
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
		if((ExpiId == i_NpcInternalId[entity] || RuniaId == i_NpcInternalId[entity]) && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
			count++;
	}

	return count;
}

static void ClotShowInteractHud(ObjectMinter npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][0] > GetGameTime())
	{
		if((Building_Collect_Cooldown[npc.index][0] - GetGameTime()) >= 999999.9)
			PrintCenterText(client, "%t","Object Cooldown NextWave");
		else
			PrintCenterText(client, "%t", "Object Cooldown", Building_Collect_Cooldown[npc.index][0] - GetGameTime());
	}
}

static void ClotThink(ObjectDispenser npc)
{
	float gameTime = GetGameTime();
	if(Building_Collect_Cooldown[npc.index][0] < gameTime)
	{
		int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
		
		if(owner == -1 || GetGlobalSupplyLeft() < 1)
		{
			Building_Collect_Cooldown[npc.index][0] = gameTime + 10.0;
		}
		else
		{
			ArrayList users = new ArrayList();

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2)
				{
					int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
					if(entity != INVALID_ENT_REFERENCE)
					{
						static char plugin[64];
						NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
						if(StrContains(plugin, "obj_barracks", false) != -1)
						{
							owner = client;
							break;
						}
					}
				}
			}

			int length = users.Length;
			if(length)
				owner = users.Get(GetURandomInt() % length);
			
			delete users;

			float pos[3], ang[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			static const char SummonerListNPC[][] =
			{
				"npc_barrack_lighthouse_guardian",
				"npc_barrack_inquisitor",	
				"npc_barrack_headhunter",
				"npc_barrack_commando",
				"npc_barrack_guards",

				"npc_barrack_alt_mecha_loader",
				"npc_barrack_alt_advanced_mage",
				"npc_barrack_alt_witch",
				"npc_barrack_alt_ikunagae",
				"npc_barrack_alt_holy_knight"
			};
			
			int ally = NPC_CreateByName(SummonerListNPC[(GetURandomInt() % 5) + (RuniaId == i_NpcInternalId[npc.index] ? 5 : 0)], owner, pos, ang, TFTeam_Red);
			view_as<BarrackBody>(ally).m_iSupplyCount = 0;

			Building_Collect_Cooldown[npc.index][0] = gameTime + 35.0;
		}
	}

	npc.m_flNextDelayTime = Building_Collect_Cooldown[npc.index][0];
}
