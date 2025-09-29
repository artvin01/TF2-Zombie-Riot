#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSound[][] =
{
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav"
};

static char g_MeleeAttackSounds[][] = {
	")weapons/pickaxe_swing1.wav",
	")weapons/pickaxe_swing2.wav",
	")weapons/pickaxe_swing3.wav",
};
void MaterialWood_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Material wood");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_material_wood");
	strcopy(data.Icon, sizeof(data.Icon), "material_wood");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSound);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_forest/sawmill_logs.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MaterialWood(vecPos, vecAng, team);
}

methodmap MaterialWood < CClotBody
{
	public MaterialWood(float vecPos[3], float vecAng[3], int team)
	{
		MaterialWood npc = view_as<MaterialWood>(CClotBody(vecPos, vecAng, "models/props_forest/sawmill_logs.mdl", "1.0", "10000", team, .isGiant = true, /*.CustomThreeDimensions = {30.0, 30.0, 200.0}, */.NpcTypeLogic = 1));
		
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
		Construction_OnTakeDamage("wood", 0, victim, attacker, damage, damagetype);
	}
}

static void ClotDeath(int entity)
{
	MaterialWood npc = view_as<MaterialWood>(entity);
	Construction_NPCDeath("wood", 45, npc);
}

Handle h_TimerMineDo[MAXPLAYERS];

bool Construction_Material_Interact(int client, int entity)
{
	if(!IsValidClient(client))
		return false;
		
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	if(!StrContains(npc_classname, "npc_material_"))
	{
		if(b_IsCamoNPC[entity])
		{
			SDKHooks_TakeDamage(entity, client, client, 500.0, DMG_CLUB);
		}
		else
		{
			delete h_TimerMineDo[client]; //if handle existed, delito
			Handle pack;
			h_TimerMineDo[client] = CreateDataTimer(0.5, MineMaterial_Passively, pack, TIMER_REPEAT);
			WritePackCell(pack, client);
			WritePackCell(pack, EntIndexToEntRef(client));
			WritePackCell(pack, EntIndexToEntRef(entity));
		}
		
		float vecOrigin[3];
		GetClientEyePosition(client, vecOrigin);
		vecOrigin[2] -= 10.0; //dont blind client.
		float vecOreOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecOreOrigin);

		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], client, SNDCHAN_AUTO, 80, _, 0.8, _);
		TE_SetupBeamPoints(vecOrigin, vecOreOrigin, IreneReturnLaserSprite(), 0, 0, 0, 0.35, 1.0, 1.2, 1, 1.0, {255,50,50,255}, 0);
		TE_SendToAll();
		return true;
	}
	return false;
}

public Action MineMaterial_Passively(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientidx = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	int EntityRock = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && IsEntityAlive(EntityRock))
	{
		float vecOrigin[3];
		GetClientEyePosition(client, vecOrigin);
		vecOrigin[2] -= 10.0; //dont blind client.
		float vecOreOrigin[3];
		GetEntPropVector(EntityRock, Prop_Data, "m_vecAbsOrigin", vecOreOrigin);
		vecOreOrigin[2] += 45.0;
		if(GetVectorDistance(vecOrigin, vecOreOrigin, true) < (250.0 * 250.0))
		{
			//close enough...
			EmitSoundToAll(g_MeleeHitSound[GetRandomInt(0, sizeof(g_MeleeHitSound) - 1)], client, SNDCHAN_AUTO, 80, _, 0.8, _);
			TE_SetupBeamPoints(vecOrigin, vecOreOrigin, IreneReturnLaserSprite(), 0, 0, 0, 0.35, 1.0, 1.2, 1, 1.0, {255,255,255,255}, 0);
			TE_SendToAll();
			SDKHooks_TakeDamage(EntityRock, client, client, 500.0, DMG_TRUEDAMAGE);
			//deal true damage overtime.
			return Plugin_Continue;
		}
	}
	h_TimerMineDo[clientidx] = null;
	return Plugin_Stop;
}