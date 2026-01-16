
public bool ShouldCollide_NpcLoco(CBaseNPC_Locomotion loco, int otherindex)
{ 
	int bot_entidx = loco.GetBot().GetNextBotCombatCharacter();
	return ShouldCollide_NpcLoco_Internal(bot_entidx, otherindex);
}

bool ShouldCollide_NpcLoco_Internal(int bot_entidx, int otherindex, int extrarules = 0)
{ 
	if(b_NpcIsTeamkiller[bot_entidx] && bot_entidx == otherindex)
		return false;

	//When in tank grab, dont collide with anythin!
	if(f_TankGrabbedStandStill[bot_entidx] > GetGameTime())
	{
		return false;
	}
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
	//it ignores all npc collisions (But not traces.)
	if(extrarules == 0 && b_ThisEntityIgnoredBeingCarried[bot_entidx])
		return false;
	/*

	This was added when we tried to go away from the extention
	//it ignores all npc collisions (But not traces.)
	if(extrarules == 0 && otherindex <= MaxClients && f_AntiStuckPhaseThrough[otherindex] > GetGameTime())
	{
			return false;
	}
	*/

#if defined ZR
	//if the bots team is player team, then they cant collide with any entities that have this flag.
	if(GetTeam(bot_entidx) == TFTeam_Red)
	{
		if(b_CantCollidieAlly[otherindex])
			return false;
	}	
	if(b_ThisEntityIgnoredByOtherNpcsAggro[otherindex])
	{
		if(GetTeam(otherindex) == TFTeam_Stalkers && GetTeam(bot_entidx) != TFTeam_Red)
		{
			return false;
		}
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
				if(RaidbossIgnoreBuildingsLogic(2) || b_NpcIgnoresbuildings[bot_entidx])
				{
					return false;
				}
				if(b_ThisEntityIgnoredBeingCarried[otherindex])
					return false;

				if(b_ThisEntityIgnored[otherindex])
					return false;

				if(extrarules == 0)
					NpcStartTouch(bot_entidx,otherindex);
					
				return true;
			}
		}
		return false;
	}
#endif

	//No matter what, if they are on the same team, then they will not collide at all as of now.
	if(GetTeam(bot_entidx) == GetTeam(otherindex))
	{
		//This is a trace, and the initator is a team killer, allow collisions via trace like this.
		if(extrarules == 1 && b_NpcIsTeamkiller[bot_entidx])
		{
			return true;
		}
		if(/*extrarules == 0 && */b_AllowCollideWithSelfTeam[bot_entidx] && b_AllowCollideWithSelfTeam[otherindex])
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
#if defined RPG
		if(OnTakeDamageRpgPartyLogic(bot_entidx, otherindex, GetGameTime()))
			return false;
#endif
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
		if(b_ThisEntityIgnoredBeingCarried[otherindex])
			return false;

		if(b_ThisEntityIgnored[otherindex])
			return false;
					
		if(extrarules == 0)
			NpcStartTouch(bot_entidx,otherindex);
			
		return true;
	}
	//always collide with vehicles if on opesite teams.
	if(i_IsVehicle[otherindex])
	{
		// No one inside the vehicle
		if(GetTeam(otherindex) == -1)
			return false;
		
		// Allow being hit via attacks
		if(extrarules == 1)
			return true;
		
		/*if(extrarules == 0)
			NpcStartTouch(bot_entidx,otherindex);*/
		
		return false;
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
		//ignore collisions if they have different camos!
		//but only if its not a trace.
		if(b_IsCamoNPC[bot_entidx] != b_IsCamoNPC[otherindex] && extrarules == 0)
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

stock bool IsEntityTowerDefense(int entity)
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
