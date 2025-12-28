#pragma semicolon 1
#pragma newdecls required

static ArrayList hConst2_SpawnerSaveWave;

enum struct Const2SpawnerEnum
{
	int SpawnerAmRef;
	char DataWave[512];
}
void Const2SpawnerOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Const2 Spawner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_const2_spawner");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Const2Spawner(vecPos, vecAng, team, data);
}

methodmap Const2Spawner < CClotBody
{
	public Const2Spawner(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Const2Spawner npc = view_as<Const2Spawner>(CClotBody(vecPos, vecAng, "models/empty.mdl", "1.0", "999999999", ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		Is_a_Medic[npc.index] = true;
		i_NpcIsABuilding[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		b_CantCollidie[npc.index] = true; 
		b_CantCollidieAlly[npc.index] = true; 
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath = true;
		b_HideHealth[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		npc.m_flSpeed = 0.0;



		/*
			data will tell what CFG to use and where its located.
			it will try to spawn all thats contained in there
			just like any other wave CFG would.

			its a hack however, itll override the current waveset, set whatever it needs, and set it back.
			hacky but zr wasnt originally made for this stuff.
		*/
		if(!hConst2_SpawnerSaveWave)
			hConst2_SpawnerSaveWave = new ArrayList(sizeof(Const2SpawnerEnum));

		
		Const2SpawnerEnum edata;
		// Create a new entry
		edata.SpawnerAmRef = EntIndexToEntRef(npc.index);
		Format(edata.DataWave, sizeof(edata.DataWave), "%s", data);
		hConst2_SpawnerSaveWave.PushArray(edata);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Const2Spawner npc = view_as<Const2Spawner>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
//	npc.m_flNextThinkTime = gameTime + 0.1;
	npc.m_flNextThinkTime = gameTime + 0.5;

	switch(b_NoHealthbar[npc.index])
	{
		case 0:
		{
			NPC_SpawnNext(false, false, Rounds_Spawner);
		}
		case 1:
		{
			if(hConst2_SpawnerSaveWave)
			{
				Const2SpawnerEnum data;
				int length = hConst2_SpawnerSaveWave.Length;
				for(int i; i < length; i++)
				{
					// Loop through the arraylist to find the right attacker and victim
					hConst2_SpawnerSaveWave.GetArray(i, data);
					if(data.SpawnerAmRef == EntIndexToEntRef(npc.index))
					{
						// We found our match
						float SpawnLocation[3];
						GetAbsOrigin(npc.index, SpawnLocation);
						Spawner_CreateEnemies(SpawnLocation, data.DataWave);
						b_NoHealthbar[npc.index] = 0;
						hConst2_SpawnerSaveWave.Erase(i);
						i--;
						length--;
					}
					else if(!IsValidEntity(data.SpawnerAmRef))
					{
						// No longer Valid
						hConst2_SpawnerSaveWave.Erase(i);
						i--;
						length--;
					}
				}
			}
		}
	}

}
static void ClotDeath(int entity)
{
	Const2Spawner npc = view_as<Const2Spawner>(entity);
	//???
}




static void Spawner_CreateEnemies(float SpawnLocation[3], const char[] data)
{
	PrintToServer("3Server %s",data);
	char Buffer[512];
	BuildPath(Path_SM, Buffer, sizeof(Buffer), CONFIG_CFG, data);
	PrintToServer("4Server %s",Buffer);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(Buffer);
	Waves_SetupWaves(kv, false, Rounds_Spawner);
	delete kv;
}