#pragma semicolon 1
#pragma newdecls required


void TornUmbralGate_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Torn Umbral Gate");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_torn_umbral_gate");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = 0; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TornUmbralGate(vecPos, vecAng, team);
}
methodmap TornUmbralGate < CClotBody
{
	property float m_flGateSpawnEnemies
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public TornUmbralGate(float vecPos[3], float vecAng[3], int ally)
	{
		TornUmbralGate npc = view_as<TornUmbralGate>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally, .isGiant = true, .CustomThreeDimensions = {55.0, 55.0, 300.0}, .NpcTypeLogic = STATIONARY_NPC));
		
		i_NpcWeight[npc.index] = 999;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(TornUmbralGate_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(TornUmbralGate_ClotThink);
		
		return npc;
	}
}

public void TornUmbralGate_ClotThink(int iNPC)
{
	TornUmbralGate npc = view_as<TornUmbralGate>(iNPC);
	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.5;

	//Gate stuff
	float vecSelf[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vecSelf);

	float EndPos[3];
	EndPos = vecSelf;
	EndPos[2] += 50.0;

	TE_SetupBeamPoints(vecSelf, EndPos, Shared_BEAM_Laser, 0, 0, 0, 0.52, 3.0, 3.0, 0, 0.0, {0,0,255,125}, 3);
	TE_SendToAll(0.0);
	
}

public void TornUmbralGate_NPCDeath(int entity)
{
	//TornUmbralGate npc = view_as<TornUmbralGate>(entity);
	//gone
}