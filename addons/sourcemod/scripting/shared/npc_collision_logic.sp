
public bool ShouldCollide_NpcLoco(CBaseNPC_Locomotion loco, int otherindex)
{ 
	int bot_entidx = loco.GetBot().GetNextBotCombatCharacter();
	return ShouldCollide_NpcLoco_Internal(bot_entidx, otherindex);
}

bool ShouldCollide_NpcLoco_Internal(int bot_entidx, int otherindex, int extrarules = 0)
{ 
	if(bot_entidx == otherindex)
		return false;
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
		if(i_IsABuilding[otherindex])
		{
			if(GetTeam(bot_entidx) != TFTeam_Red && IsEntityTowerDefense(bot_entidx))
			{
				if(extrarules == 0)
					NpcStartTouch(bot_entidx,otherindex);
				return true;
			}
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
		//this player has some type of logic to prevent collisions, ignore.
		if(b_ThisEntityIgnored[otherindex])
		{
			return false;
		}
		//we collided with a player, change target.
		if(extrarules == 0)
			NpcStartTouch(bot_entidx,otherindex);
		return true;
	}
	if(i_IsABuilding[otherindex])
	{
		if(RaidbossIgnoreBuildingsLogic(2) || b_NpcIgnoresbuildings[bot_entidx])
		{
			return false;
		}
		if(extrarules == 0)
			NpcStartTouch(bot_entidx,otherindex);
		return true;
	}
	//always collide with vehicles if on opesite teams.
	if(b_IsVehicle[otherindex])
	{
		if(extrarules == 0)
			NpcStartTouch(bot_entidx,otherindex);
		return true;
	}
	//other entity is an npc
	if(!b_NpcHasDied[otherindex])
	{
		//we are ignoring them, skip them, but only during traces.
		if(b_IgnorePlayerCollisionNPC[bot_entidx])
		{
			return false;
		}
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
	if(extrarules == 0)
		NpcStartTouch(bot_entidx,otherindex);
	return true;
}

bool NpcCollisionCheck(int npc, int other, int extrarules = 0)
{
	return ShouldCollide_NpcLoco_Internal(npc, other, extrarules);
}



bool IsEntityTowerDefense(int entity)
{
#if defined ZR
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(VIPBuilding_Active())
			return true;
	}
#endif
	return false;
}