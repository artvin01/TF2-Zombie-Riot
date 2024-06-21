#pragma semicolon 1
#pragma newdecls required

void RogueCondition_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rogue_condition");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	char buffers[3][64];
	ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));

	if(buffers[0][0] == '.' || IsCharNumeric(buffers[0][0]))
	{
		/*
			"0.1"
			".1"
			"10"
		*/

		if(!Rogue_Paradox_IgnoreOdds())
		{
			float rand = GetURandomFloat();
			float value = StringToFloat(buffers[0]);
			if(value >= 1.0)
				rand *= 100.0;
			
			value += (Rogue_GetChaosLevel() * 0.1);
			if(value < rand)
				return -1;
		}
	}
	else 
	{
		/*
			"Calling Card"
			"!Repel Card"
		*/

		bool inverse = (buffers[0][0] == '!');

		if(Rogue_HasNamedArtifact(buffers[0][inverse ? 1 : 0]) == inverse)
			return -1;
	}

	return NPC_CreateByName(buffers[1], client, vecPos, vecAng, team, buffers[2], true);
}