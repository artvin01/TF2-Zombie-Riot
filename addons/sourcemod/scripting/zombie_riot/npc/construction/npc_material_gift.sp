#pragma semicolon 1
#pragma newdecls required

static int InternalID;
void MaterialGift_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Left Remains Of Raids");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_raid");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	InternalID = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/items/tf_gift.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialGift(vecPos, vecAng, team);
}

methodmap MaterialGift < CClotBody
{
	property int m_iMyRisk
	{
		public get()		{	return this.m_iMedkitAnnoyance;	}
		public set(int value) 	{	this.m_iMedkitAnnoyance = value;	}
	}
	public MaterialGift(float vecPos[3], float vecAng[3], int team)
	{
		MaterialGift npc = view_as<MaterialGift>(CClotBody(vecPos, vecAng, "models/items/tf_gift.mdl", "1.5", "5000", team, .isGiant = false, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
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
		npc.Anger = false;	// If true, summons an attack wave when mining
		npc.m_bCamo = false;	// For AI attacking resources
		
		func_NPCThink[npc.index] = Construction_ClotThink;
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		b_NoHealthbar[npc.index] = true;

		return npc;
	}
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		Construction_OnTakeDamage("gift", 0, victim, attacker, damage, damagetype);
	}
}

static void ClotDeath(int entity)
{
	MaterialGift npc = view_as<MaterialGift>(entity);
	int cash = 150;
	int GetRound = npc.m_iMyRisk;
	cash *= GetRound;
	CPrintToChatAll("%t", "Gained Material", cash, "Cash");
	CurrentCash += cash;
	GiveRandomReward(npc.m_iMyRisk, 1);
	int attacker = EntRefToEntIndex(LastHitRef[entity]);
	if(IsValidClient(attacker))
	{
		CPrintToChatAll("%t","Found a gift remain", attacker);
	}
	else
	{
		CPrintToChatAll("%t","Found a gift remain No Attacker");
	}
}


int RemainsRaidsLeftOnMap()
{
	int GiftsOnMap;
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int NpcIndex = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(NpcIndex) && i_NpcInternalId[NpcIndex] == InternalID)
		{
			GiftsOnMap++;
		}
	}

	return GiftsOnMap;
}



int SpawnRandomGiftRemain()
{
	for(int RepeatAlot; RepeatAlot <= 1000; RepeatAlot++)
	{
		CNavArea area = PickRandomArea();
		if(area == NULL_AREA)
			continue;
		
		if(area.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
		{
			continue;
		}
		float ang[3];
		float pos2[3];
		area.GetCenter(pos2);

		//Try to not spawn inside other ores?
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		hullcheckmaxs = view_as<float>( { 40.0, 40.0, 120.0 } );
		hullcheckmins = view_as<float>( { -40.0, -40.0, 0.0 } );	
		if(Construction_IsBuildingInWay(pos2, hullcheckmins, hullcheckmaxs))
		{
			continue;
		}
		
		ang[0] = 0.0;
		ang[1] = float(GetURandomInt() % 360);
		ang[2] = 0.0;


		int entity = NPC_CreateByName("npc_material_raid", -1, pos2, ang, TFTeam_Blue);
		return entity; 
	}
	return 0;
}