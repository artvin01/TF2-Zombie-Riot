#pragma semicolon 1
#pragma newdecls required

#define DEEP_SEA_VORE_RANGE 250.0
enum
{
	Buff_Founder = 0,
	Buff_Predator,
	Buff_Brandguider,
	Buff_Spewer,
	Buff_Swarmcaller,
	Buff_Reefbreaker
}

static const char RemainModels[][] =
{
	"models/pickups/pickup_powerup_defense.mdl",
	"models/pickups/pickup_powerup_reflect.mdl",
	"models/pickups/pickup_powerup_king.mdl",
	"models/pickups/pickup_powerup_precision.mdl",
	"models/pickups/pickup_powerup_agility.mdl",
	"models/pickups/pickup_powerup_strength_arm.mdl"
};

static int RemainsID;

int Remain_ID()
{
	return RemainsID;
}

void Remain_MapStart()
{
	for(int i; i < sizeof(RemainModels); i++)
	{
		PrecacheModel(RemainModels[i]);
	}

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Consumable Remains");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_endspeaker_freeplay");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	RemainsID = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Remains(vecPos, vecAng, team, data);
}

methodmap Remains < CClotBody
{
	public Remains(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		if(!data[0])
			return view_as<Remains>(EndSpeaker(vecPos, vecAng, ally));
		
		int type = StringToInt(data);
		if(type < 0 || type >= sizeof(RemainModels))
			return view_as<Remains>(-1);

		Remains npc = view_as<Remains>(CClotBody(vecPos, vecAng, RemainModels[type], "1.0", "100", TFTeam_Red, true));

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 2);

		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisEntityIgnored = true;
		npc.m_iBuffType = type;
		npc.m_bisWalking = false;
		
		func_NPCThink[npc.index] = Remains_ClotThink;
		return npc;
	}
	property int m_iBuffType
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
}

public void Remains_ClotThink(int iNPC)
{
	Remains npc = view_as<Remains>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.5;
	ShowScuffedRemainsCircle(npc.index);
}

void Remains_SpawnDrop(float pos[3], int type)
{
	if(Rogue_Whiteflower_RemainDrop(type))
		return;
	
	char data[4];
	IntToString(type, data, sizeof(data));
	NPC_CreateById(RemainsID, -1, pos, {0.0, 0.0, 0.0}, TFTeam_Red, data);
}

static void ShowScuffedRemainsCircle(int entity)
{
	float vecTarget[3]; WorldSpaceCenter(entity, vecTarget);
	int alpha = IsClosestRemain(entity) ? 200 : 50;

	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, alpha, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] -= 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.85, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, alpha, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] -= 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.60, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, alpha, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] += 100.0;
	vecTarget[2] += 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.85, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, alpha, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] += 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.60, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, alpha, 1, 0.55, 6.0, 0.1, 1);
}

static bool IsClosestRemain(int thisEntity)
{
	float pos[3];
	bool hard = EndSpeaker_GetPos(pos);

	int remain1, remain2;
	float dist1 = FAR_FUTURE;
	float dist2 = FAR_FUTURE;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == RemainsID && IsEntityAlive(entity))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(entity, WorldSpaceVec);
			float distance = GetVectorDistance(WorldSpaceVec, pos, true);
			if(distance < dist1)
			{
				remain2 = remain1;
				dist2 = dist1;

				remain1 = entity;
				dist1 = distance;
			}
			else if(distance < dist2)
			{
				remain2 = entity;
				dist2 = distance;
			}
		}
	}

	if(thisEntity == remain1)
		return true;
	
	if(hard && thisEntity == remain2)
		return true;
	
	return false;
}