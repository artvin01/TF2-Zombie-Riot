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

			bool ignoreOdds = Rogue_Paradox_IgnoreOdds();

			if(Rogue_Theme() == ReilaRift)
			{
				switch(Rogue_GetUmbralLevel())
				{
					case 0, 4:
						ignoreOdds = true;
					
					case 2:
						return -1;
				}
			}

			if(!ignoreOdds)
			{
				float rand = GetURandomFloat();
				float value = StringToFloat(buffers[0]);
				if(value > 1.0)
					rand /= 100.0;
				
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
	{
		bool friendly = (Rogue_Theme() == ReilaRift) && (Rogue_GetUmbralLevel() < 2);

		int entity = NPC_CreateByName(buffers[1], client, vecPos, vecAng, friendly ? TFTeam_Red : team, buffers[2], true);

		if(GetTeam(entity) == TFTeam_Red)
		{
			fl_Extra_Damage[entity] *= 10.0;
			fl_Extra_MeleeArmor[entity] *= 20.0;
			fl_Extra_RangedArmor[entity] *= 20.0;
			TeleportNpcToRandomPlayer(entity);
		}
		else
		{
			switch(Rogue_GetUmbralLevel())
			{
				case 4:
				{
					//if completly hated.
					fl_Extra_Damage[entity] *= 2.0;
					fl_Extra_MeleeArmor[entity] *= 0.65;
					fl_Extra_RangedArmor[entity] *= 0.65;
				}
			}
		}

		return entity;
	}
	
	return -1;
}