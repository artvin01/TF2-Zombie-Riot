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

void Remain_MapStart()
{
	for(int i; i < sizeof(RemainModels); i++)
	{
		PrecacheModel(RemainModels[i]);
	}
}

methodmap Remains < CClotBody
{
	public Remains(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(!data[0])
			return view_as<Remains>(EndSpeaker(client, vecPos, vecAng, false));
		
		int type = StringToInt(data);
		if(type < 0 || type >= sizeof(RemainModels))
			return view_as<Remains>(-1);

		Remains npc = view_as<Remains>(CClotBody(vecPos, vecAng, RemainModels[type], "1.0", "100", true, true));

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 2);

		i_NpcInternalId[npc.index] = REMAINS;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisEntityIgnored = true;
		npc.m_iBuffType = type;
		
		SDKHook(npc.index, SDKHook_Think, Remains_ClotThink);
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

	float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.index);
	ShowScuffedRemainsCircle(vecTarget);
}

void Remains_SpawnDrop(float pos[3], int type)
{
	char data[4];
	IntToString(type, data, sizeof(data));
	Npc_Create(REMAINS, -1, pos, {0.0, 0.0, 0.0}, true, data);
}

void Remains_NPCDeath(int entity)
{
	SDKUnhook(entity, SDKHook_Think, Remains_ClotThink);
}


void ShowScuffedRemainsCircle(float vecTarget[3])
{
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] -= 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.85, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] -= 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.60, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] += 100.0;
	vecTarget[2] += 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.85, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 0.55, 6.0, 0.1, 1);
	vecTarget[2] += 50.0;
	spawnRing_Vectors(vecTarget, DEEP_SEA_VORE_RANGE * 2.0 * 0.60, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 0.55, 6.0, 0.1, 1);
}