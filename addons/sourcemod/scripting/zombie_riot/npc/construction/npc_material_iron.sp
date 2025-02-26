#pragma semicolon 1
#pragma newdecls required

void MaterialIron_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Material iron");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_iron");
	strcopy(data.Icon, sizeof(data.Icon), "material_iron");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_wasteland/rockcliff_cluster03a.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialIron(client, vecPos, vecAng, team);
}

methodmap MaterialIron < CClotBody
{
	public MaterialIron(int client, float vecPos[3], float vecAng[3], int team)
	{
		MaterialIron npc = view_as<MaterialIron>(CClotBody(vecPos, vecAng, "models/props_wasteland/rockcliff_cluster03a.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		npc.m_flRangedArmor = 0.1;
		npc.g_TimesSummoned = 0;
		npc.Anger = view_as<bool>(GetURandomInt() % 4);	// If true, summons an attack wave when mining
		
		func_NPCThink[npc.index] = Construction_ClotThink;
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;

		return npc;
	}
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		Construction_OnTakeDamage("iron", 25, victim, attacker, damage, damagetype);
	}
}

static void ClotDeath(int entity)
{
	MaterialIron npc = view_as<MaterialIron>(entity);
	Construction_NPCDeath("iron", 25, npc);
}
