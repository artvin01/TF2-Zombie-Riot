#pragma semicolon 1
#pragma newdecls required

void MaterialEvilExpi_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Broken Server");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rogue_expi_building");
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
	PrecacheModel("models/props_combine/masterinterface.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialEvilExpi(client, vecPos, vecAng, team);
}

methodmap MaterialEvilExpi < CClotBody
{
	public MaterialEvilExpi(int client, float vecPos[3], float vecAng[3], int team)
	{
		MaterialEvilExpi npc = view_as<MaterialEvilExpi>(CClotBody(vecPos, vecAng, "models/props_combine/masterinterface.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
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

		npc.m_flRangedArmor = 0.1;
		npc.g_TimesSummoned = 0;
		npc.Anger = true;	// If true, summons an attack wave when mining
		
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
		if(Rogue_HasNamedArtifact("Pickaxes and a Map"))
		{
			Construction_OnTakeDamage("cash", 0, victim, attacker, damage, damagetype);
		}
		else
		{
			bool angery = npc.Anger;
			bool attack = Construction_OnTakeDamageCustom("construction/ending1_fight", victim, attacker, damage, damagetype);
			if(attack && angery && attacker > 0 && attacker <= MaxClients)
				CPrintToChatAll("%t", "Resource Attack Started", attacker, "?????????????");
		}
	}
}

static void ClotDeath(int entity)
{
	if(Rogue_HasNamedArtifact("Pickaxes and a Map"))
	{
		static const int cash = 5000;
		CPrintToChatAll("{green}%t","Cash Gained!", cash);
		CurrentCash += cash;
	}
	else
	{
		Rogue_GiveNamedArtifact("Expidonsa Tech Chip");
	}
}
