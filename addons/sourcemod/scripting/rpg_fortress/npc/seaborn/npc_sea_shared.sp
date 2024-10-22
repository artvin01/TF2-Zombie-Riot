#pragma semicolon 1
#pragma newdecls required

static float CheckPos[3];
static float CheckDistance;

void SeaShared_Thinking(int entity, float distance, const char[] WalkBack, const char[] StandStill, float walkspeedback, float gameTime, bool walkback_use_sequence = false, bool standstill_use_sequence = false)
{
	if(b_NpcIsInADungeon[entity])
	{
		Npc_Base_Thinking(entity, distance, WalkBack, StandStill, walkspeedback, gameTime, walkback_use_sequence, standstill_use_sequence);
	}
	else
	{
		CheckDistance = distance;
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", CheckPos);
		Npc_Base_Thinking(entity, distance * 2.0, WalkBack, StandStill, walkspeedback, gameTime, walkback_use_sequence, standstill_use_sequence, SeaShared_ClosestTargetValidity);
	}
}

bool SeaShared_ClosestTargetValidity(int entity, int target)
{
	// If touching water, x2 range for Seaborn
	if(target <= MaxClients && ((GetEntityFlags(target) & (FL_SWIM|FL_INWATER)) || TF2_IsPlayerInCondition(target, TFCond_Milked)))
		return true;
	
	static float pos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
	return GetVectorDistance(CheckPos, pos, true) < CheckDistance;
}

stock void SeaShared_DealCorrosion(int victim, int attacker, int damage)
{
	ArmorCorrosion[victim] += damage;

	if(victim <= MaxClients)
	{
		if(ArmorCorrosion[victim] > 0)
		{
			if(Stats_Endurance(victim) < 1)
				TF2_AddCondition(victim, TFCond_Milked, 8.0);
			
			ClientCommand(victim, "playgamesound player/crit_received%d.wav", (GetURandomInt() % 3) + 1);
		}
	}
}