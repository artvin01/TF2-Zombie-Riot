/*
enum
{
	num_ShouldCollideEnemyIngoreBuilding = 1,
	num_ShouldCollideEnemy,
	num_ShouldCollideAllyInvince,
	num_ShouldCollideAlly,
	num_ShouldCollideEnemyTD,
	num_ShouldCollideEnemyTDIgnoreBuilding,
}

public bool ShouldCollideAlly(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideAlly_Internal(loco, otherindex); 
}
bool ShouldCollideAlly_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		return false;
	}	
	if(b_is_a_brush[otherindex])
	{
		return true;
	}
#if defined ZR
	if(extrarules == 1 && npc != 0 && b_NpcIsTeamkiller[npc])
	{
		if(otherindex == npc)
		{
			return false;
		}
		return true;
	}
	else
#endif
	{
		if(b_CantCollidieAlly[otherindex])
		{
			return false;
		}
	}
	if(b_IsVehicle[otherindex])
	{
		return false;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}
public bool ShouldCollideAllyInvince(CBaseNPC_Locomotion loco, int otherindex)
{
	return ShouldCollideAllyInvince_Internal(loco, otherindex); 
}

bool ShouldCollideAllyInvince_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		return false;
	}	
	if(b_is_a_brush[otherindex])
	{
		return true;
	}
	//we fire a bullet or melee attack, we want to not ignore this.
	if(extrarules != num_BulletTraceLogicHandle)
	{
		if(b_CantCollidie[otherindex])
		{
			return false;
		}
	}
#if defined ZR
	if(extrarules == 1 && npc != 0 && b_NpcIsTeamkiller[npc])
	{
		if(otherindex == npc)
		{
			return false;
		}
		return true;
	}
	else
#endif
	{
		if(b_CantCollidieAlly[otherindex]) 
		{
			return false;
		}
	}
	if(b_IsVehicle[otherindex])
	{
		return false;
	}

	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}


public bool ShouldCollideEnemy(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemy_Internal(loco, otherindex);
}

bool ShouldCollideEnemy_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(b_ThisEntityIgnored[otherindex])
		{
			return false;
		}
		if(loco != view_as<CBaseNPC_Locomotion>(0))
			NpcStartTouch(loco,otherindex);

		return true;
	}
	if(b_is_a_brush[otherindex])
	{
		return true;
	} 
#if defined ZR
	if(extrarules == 1 && npc != 0 && b_NpcIsTeamkiller[npc])
	{
		if(otherindex == npc)
		{
			return false;
		}
		return true;
	}
	else
#endif
	{
		if(b_CantCollidie[otherindex]) //no change in performance..., almost.
		{
			return false;
		}
	}
	if(b_IsVehicle[otherindex])
	{
		return true;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}

*/
public bool ShouldCollide_NpcLoco(CBaseNPC_Locomotion loco, int otherindex)
{ 
	int bot_entidx = loco.GetBot().GetNextBotCombatCharacter();
	return ShouldCollide_NpcLoco_Internal(bot_entidx, otherindex);
}

bool ShouldCollide_NpcLoco_Internal(int bot_entidx, int otherindex, int extrarules = 0)
{ 
	//bots will always collide with brushes, and not ignored.
	if(b_is_a_brush[otherindex])
	{
		return true;
	}
	//Any entity designated as "cant collide" Will be countes not collideable.
	if(b_CantCollidie[otherindex])
	{
		return false;
	}
	//if the bots team is player team, then they cant collide with any entities that have this flag.
	if(GetTeam(bot_entidx) == TFTeam_Red)
	{
		if(b_CantCollidieAlly[otherindex])
			return false;
	}	
	if(GetTeam(bot_entidx) != TFTeam_Red && IsEntityTowerDefense(bot_entidx))
	{
		CClotBody npc = view_as<CClotBody>(bot_entidx);
		if(npc.m_iTarget == otherindex)
		{
			return true;
		}
		return false;
	}
	//No matter what, if they are on the same team, then they will not collide at all as of now.
	if(GetTeam(bot_entidx) == GetTeam(otherindex))
	{
		//This is a trace, and the initator is a team killer, allow collisions via trace like this.
		if(extrarules == 1 && b_NpcIsTeamkiller[bot_entidx])
		{
			return true;
		}
		return false;
	}
	//the collided index is a player.
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(GetTeam(bot_entidx) != TFTeam_Red && IsEntityTowerDefense(bot_entidx))
		{
			return false;
		}
		//this player has some type of logic to prevent collisions, ignore.
		if(b_ThisEntityIgnored[otherindex])
		{
			return false;
		}
		//we collided with a player, change target.
		NpcStartTouch(bot_entidx,otherindex);
		return true;
	}
	if(i_IsABuilding[otherindex])
	{
		if(GetTeam(bot_entidx) != TFTeam_Red && IsEntityTowerDefense(bot_entidx))
		{
			NpcStartTouch(bot_entidx,otherindex);
			return true;
		}
		if(RaidbossIgnoreBuildingsLogic(2) || b_NpcIgnoresbuildings[bot_entidx])
		{
			return false;
		}
		return true;
	}
	//always collide with vehicles if on opesite teams.
	if(b_IsVehicle[otherindex])
	{
		NpcStartTouch(bot_entidx,otherindex);
		return true;
	}
	//other entity is an npc
	if(!b_NpcHasDied[otherindex])
	{
		//we are ignoring them, skip them, but only during traces.
		if(b_ThisEntityIgnored[bot_entidx] && extrarules == 0)
		{
			return false;
		}
	}
	//the other index is ingored, ignore.
	if(b_ThisEntityIgnored[otherindex])
	{
		return false;
	}
	//They have collided with something, try to change the target.
	NpcStartTouch(bot_entidx,otherindex);
	return true;
}
/*
bool ShouldCollideEnemyIngoreBuilding_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 

	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(b_ThisEntityIgnored[otherindex])
		{
			return false;
		}
		if(loco != view_as<CBaseNPC_Locomotion>(0))
			NpcStartTouch(loco,otherindex);

		return true;
	}
	if(b_is_a_brush[otherindex])
	{
		return true;
	}

#if defined ZR
	if(extrarules == 1 && npc != 0 && b_NpcIsTeamkiller[npc])
	{
		if(otherindex == npc)
		{
			return false;
		}
		return true;
	}
	else
#endif
	{
		if(b_CantCollidie[otherindex])
		{
			return false;
		}
		if(b_CantCollidieAlly[otherindex])
		{
			if(i_IsABuilding[otherindex])
			{
				return false;
			}
		}		
	}

	if(b_IsVehicle[otherindex])
	{
		return true;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}

#if defined ZR
public bool ShouldCollideEnemyTD(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemyTD_Internal(loco, otherindex);
}

bool ShouldCollideEnemyTD_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	//entirely ignore players
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		return false;
	}

	if(b_is_a_brush[otherindex])
	{
		return true;
	}

	if(!b_NpcHasDied[otherindex])
	{
		CClotBody npc1 = view_as<CClotBody>(npc);
		if(i_NpcInternalId[otherindex] == VIP_BUILDING || npc1.m_iTarget == otherindex)
		{
			if(extrarules == num_TraverseInverse)
			{
				return false;
			}
			else
			{
				if(loco != view_as<CBaseNPC_Locomotion>(0))
					NpcStartTouch(loco, otherindex);
				
				return true;
			}
		}
	}
	
	if(b_CantCollidie[otherindex])
	{
		return false;
	}
	if(b_CantCollidieAlly[otherindex])
	{
		if(i_IsABuilding[otherindex])
		{
			if(extrarules != num_TraverseInverse)
			{
				if(loco != view_as<CBaseNPC_Locomotion>(0))
					NpcStartTouch(loco,otherindex);
				
				return true;
			}
		}
		return false;
	}
	if(b_IsVehicle[otherindex])
	{
		return false;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}

public bool ShouldCollideEnemyTDIgnoreBuilding(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemyTDIgnoreBuilding_Internal(loco, otherindex);
}

bool ShouldCollideEnemyTDIgnoreBuilding_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	//entirely ignore players
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		return false;
	}
	if(b_is_a_brush[otherindex])
	{
		return true;
	}
	if(!b_NpcHasDied[otherindex])
	{
		CClotBody npc1 = view_as<CClotBody>(npc);
		if(i_NpcInternalId[otherindex] == VIP_BUILDING || npc1.m_iTarget == otherindex)
		{
			if(extrarules == num_TraverseInverse)
			{
				return false;
			}
			else
			{
				if(loco != view_as<CBaseNPC_Locomotion>(0))
					NpcStartTouch(loco, otherindex);
				
				return true;
			}
		}
	}
	
	if(b_CantCollidie[otherindex])
	{
		return false;
	}

	if(b_CantCollidieAlly[otherindex])
	{
		return false;
	}

	if(b_IsVehicle[otherindex])
	{
		return false;
	}
	
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco, otherindex);

	return true;
}
#endif
*/
bool NpcCollisionCheck(int npc, int other, int extrarules = 0)
{
	return ShouldCollide_NpcLoco_Internal(npc, other, extrarules);
}



bool IsEntityTowerDefense(int entity)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(VIPBuilding_Active())
			return true;
	}
	return false;
}