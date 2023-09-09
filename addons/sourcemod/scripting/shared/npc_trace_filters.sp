enum
{
	num_BulletTraceLogicHandle = 1,
	num_TraverseInverse = 2,
}

public bool BulletAndMeleeTrace(int entity, int contentsMask, any iExclude)
{
#if defined ZR
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
#endif
	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	else if(!b_NpcHasDied[entity])
	{
		if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		{
			return false;
		}
		else if(!b_IsCamoNPC[entity] && b_CantCollidie[entity] && b_CantCollidieAlly[entity]) //If both are on, then that means the npc shouldnt be invis and stuff
		{
			return false;
		}
	}
	
	//if anything else is team
	if(b_IsARespawnroomVisualiser[entity])
	{
		return false;
	}	

	if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;

	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}	

#if defined ZR
	if(Saga_EnemyDoomed(entity) && Saga_EnemyDoomed(iExclude))
	{
		return false;
	}
#endif

	if(!b_NpcHasDied[iExclude])
	{
		//1 means we treat it as a bullet trace
		return NpcCollisionCheck(iExclude, entity, 1);
	}

	return !(entity == iExclude);
}

//same as above but we ignore buildings.
public bool BulletAndMeleeTracePlayerAndBaseBossOnly(int entity, int contentsMask, any iExclude)
{
	if(i_IsABuilding[entity])
	{
		return false;
	}
	return BulletAndMeleeTrace(entity, contentsMask, iExclude);
}

//Should only try to collide with players.
public bool TraceRayHitPlayersOnly(int entity,int mask,any iExclude)
{
	/*
	if(!b_NpcHasDied[iExclude])
	{
		return NpcCollisionCheck(iExclude, entity, 0);
	}
	*/

	if (entity > 0 && entity <= MaxClients)
	{
#if defined ZR
		if(TeutonType[entity] == TEUTON_NONE && dieingstate[entity] == 0)
#endif
		{
			if(!b_DoNotUnStuck[entity] && !b_ThisEntityIgnored[entity])
				return true;
		}
	}

	return false;
}

//This is mainly to see if you THE PLAYER!!!!! is stuck inside the WORLD OR BRUSHES OR STUFF LIKE THAT. Not stuck inside an npc, because this code is not made for that.
public bool TraceRayDontHitPlayersOrEntityCombat(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}

	if(entity > 0 && entity <= MaxClients) 
	{
		return false;
	}
	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	
	if(!b_NpcHasDied[entity])
	{
		return false;
	}
	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}

	//if anything else is team
	
	if(GetEntProp(data, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	

	if(b_IsARespawnroomVisualiser[entity])
	{
		return true;//They blockin me and not on same team, otherwsie top filter
	}
	
	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}
	
	if(entity == Entity_to_Respect)
	{
		return false;
	}
	return true;
}

//This is mainly to see if you THE PLAYER!!!!! is stuck inside the WORLD OR BRUSHES OR STUFF LIKE THAT. Not stuck inside an npc, because this code is not made for that.
public bool TraceRayHitWorldOnly(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}
	if(GetEntProp(data, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;

	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}
	return false;
	/*
	if(entity > 0 && entity <= MaxClients) 
	{
		return false;
	}
	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	
	if(!b_NpcHasDied[entity])
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(data, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	

	else if(b_IsARespawnroomVisualiser[entity])
	{
		return true;//They blockin me and not on same team, otherwsie top filter
	}
	
	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}
	
	if(entity == Entity_to_Respect)
	{
		return false;
	}
	return true;
	*/
}
public bool TraceRayHitWorldAndBuildingsOnly(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}
	if(entity == data)
	{
		return false;
	}
	if(i_IsABuilding[entity])
	{
		return true;
	}
	if(GetEntProp(data, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;

	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}
	
	if(i_IsABuilding[entity])
	{
		return true;//They blockin me
	}
	return false;
}