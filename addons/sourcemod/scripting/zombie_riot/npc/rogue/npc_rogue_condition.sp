#pragma semicolon 1
#pragma newdecls required

static float LastGameTime;
static char LastData[96];
static bool LastResult;

void RogueCondition_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rogue_condition");
	strcopy(data.Icon, sizeof(data.Icon), "rogue_chaos_1");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	static char buffers[3][64];

	bool same = StrEqual(data, LastData);
	if(!same)
	{
		strcopy(LastData, sizeof(LastData), data);
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
	}

	if(!same || (GetGameTime() > LastGameTime))
	{
		LastGameTime = GetGameTime() + 0.5;
		LastResult = true;

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
				
				if(Construction_Mode())
				{
					if(!Construction_InSetup())
						value *= 5.0;
					
					value *= ConstructionItems_OddIncrease();
				}
				
				value += (Rogue_GetChaosLevel() * 0.1);
				if(value < rand)
					LastResult = false;
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
				LastResult = false;
		}
	}

	if(LastResult)
		return NPC_CreateByName(buffers[1], client, vecPos, vecAng, team, buffers[2], true);
	
	return -1;
}