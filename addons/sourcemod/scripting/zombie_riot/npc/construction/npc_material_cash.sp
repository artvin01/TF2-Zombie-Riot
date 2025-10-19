#pragma semicolon 1
#pragma newdecls required

void MaterialCash_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Broken Server");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_cash");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_lab/servers.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialCash(vecPos, vecAng, team);
}

methodmap MaterialCash < CClotBody
{
	public MaterialCash(float vecPos[3], float vecAng[3], int team)
	{
		MaterialCash npc = view_as<MaterialCash>(CClotBody(vecPos, vecAng, "models/props_lab/servers.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "resource");
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

	//	npc.m_flRangedArmor = 0.1;
		npc.g_TimesSummoned = 0;
		npc.Anger = true;	// If true, summons an attack wave when mining
		npc.m_bCamo = true;	// For AI attacking resources
		
		func_NPCThink[npc.index] = Construction_ClotThink;
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		b_NoHealthbar[npc.index] = 1;

		return npc;
	}
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		Construction_OnTakeDamage("cash", 0, victim, attacker, damage, damagetype);
	}
}

static void ClotDeath(int entity)
{
	int cash = 1000;

	int GetRound = Construction_GetRisk() + 1;

	if(GetRound > 5)
		GetRound = 5;
		
	cash *= GetRound;
	
	CPrintToChatAll("%t", "Gained Material", cash, "Cash");
	CurrentCash += cash;
}
