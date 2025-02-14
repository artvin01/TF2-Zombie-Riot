#pragma semicolon 1
#pragma newdecls required

void MaterialStone_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Material stone");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_stone");
	strcopy(data.Icon, sizeof(data.Icon), "material_stone");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_wasteland/rockgranite01b.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialStone(client, vecPos, vecAng, team);
}

methodmap MaterialStone < CClotBody
{
	public MaterialStone(int client, float vecPos[3], float vecAng[3], int team)
	{
		MaterialStone npc = view_as<MaterialStone>(CClotBody(vecPos, vecAng, "models/props_wasteland/rockgranite01b.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		npc.m_flRangedArmor = 0.1;
		npc.g_TimesSummoned = 0;
		npc.Anger = view_as<bool>(GetURandomInt() % 2);	// If true, summons an attack wave when mining
		
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
		Construction_OnTakeDamage("stone", 30, victim, attacker, damage, damagetype);
	}
}

static void ClotDeath(int entity)
{
	MaterialStone npc = view_as<MaterialStone>(entity);
	Construction_NPCDeath("stone", 30, npc);
}
