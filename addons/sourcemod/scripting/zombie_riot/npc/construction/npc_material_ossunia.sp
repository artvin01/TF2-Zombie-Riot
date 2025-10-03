#pragma semicolon 1
#pragma newdecls required

void MaterialOssunia_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Material ossunia");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_ossunia");
	strcopy(data.Icon, sizeof(data.Icon), "material_ossunia");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_mining/rock001.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialOssunia(vecPos, vecAng, team);
}

methodmap MaterialOssunia < CClotBody
{
	public MaterialOssunia(float vecPos[3], float vecAng[3], int team)
	{
		MaterialOssunia npc = view_as<MaterialOssunia>(CClotBody(vecPos, vecAng, "models/props_mining/rock001.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
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

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 200, 200, 125);
		
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
//		MaterialOssunia npc = view_as<MaterialOssunia>(victim);
	//	bool angery = npc.Anger;
		if(Construction_OnTakeDamage("ossunia", 0, victim, attacker, damage, damagetype))
		{
			/*
			if(angery)
			{
				float pos[3];
				for(int i; i < 10; i++)
				{
					CNavArea area = PickRandomArea();
					if(area == NULL_AREA)
						continue;
					
					if(area.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
						continue;
					
					WorldSpaceCenter(npc.index, pos);
					ParticleEffectAt(pos, "teleported_blue", 0.5);
					view_as<Sensal>(victim).PlayDeathSound();
					
					area.GetCenter(pos);
					TeleportEntity(victim, pos);
					break;
				}
			}
			*/
		}
	}
}

static void ClotDeath(int entity)
{
	MaterialOssunia npc = view_as<MaterialOssunia>(entity);
	Construction_NPCDeath("ossunia", 30, npc);
}
