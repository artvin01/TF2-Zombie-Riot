enum
{
	num_BulletTraceLogicHandle = 1,
	num_TraverseInverse = 2,
}
int FilterEntityDo = 0;

void BulletTraceFilterEntity(int entity)
{
	FilterEntityDo = entity;
}

public bool BulletAndMeleeTrace(int entity, int contentsMask, any iExclude)
{
	if(entity == iExclude)
		return false;
		
#if defined ZR

	if(i_IsABuilding[iExclude])
	{
		//dont try to collide with your dependant building,.
		if(EntRefToEntIndex(i_IDependOnThisBuilding[iExclude]) == entity)
		{
			return false;
		}
		ObjectGeneric objstats = view_as<ObjectGeneric>(iExclude);
		if(objstats.m_iExtrabuilding1 == entity)
			return false;
		else if(objstats.m_iExtrabuilding2 == entity)
			return false;
	}
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
#if defined ZR
		if(!b_NpcIsTeamkiller[iExclude] && GetTeam(iExclude) == GetTeam(entity))
		{
			if(!b_AllowCollideWithSelfTeam[iExclude] && !b_AllowCollideWithSelfTeam[entity])
				return false;
		}
		else if(!b_IsCamoNPC[entity] && b_CantCollidie[entity] && b_CantCollidieAlly[entity]) //If both are on, then that means the npc shouldnt be invis and stuff
#else
		if(!b_IsCamoNPC[entity] && b_CantCollidie[entity] && b_CantCollidieAlly[entity])
#endif
		{
			return false;
		}
	}
	/*
#if defined RTS
	else if(IsObject(entity))
	{
		return true;
	}
#endif
	*/

	//if anything else is team
	if(b_IsARespawnroomVisualiser[entity])
	{
		return false;
	}	

	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}	
#if defined ZR
	if(!b_NpcIsTeamkiller[iExclude] && GetTeam(iExclude) == GetTeam(entity))
	{
		//buildings MUST pass through this if interacting with eacother.
		int Wasbuilding = 0;
		if(i_IsABuilding[iExclude])
			Wasbuilding++;

		if(i_IsABuilding[entity])
			Wasbuilding++;
		if(Wasbuilding == 2 || !b_AllowCollideWithSelfTeam[iExclude] || !b_AllowCollideWithSelfTeam[entity])
		{
			return false;
		}
	}

	if(Saga_EnemyDoomed(entity) && Saga_EnemyDoomed(iExclude))
	{
		return false;
	}
#endif
#if defined RPG
	if(GetTeam(iExclude) == GetTeam(entity))
	{
		if(entity > 0 && entity <= MaxClients) 
		{
			if(!RPGCore_PlayerCanPVP(iExclude,entity))
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	if(OnTakeDamageRpgPartyLogic(entity, iExclude, GetGameTime()))
		return false;
#endif

#if defined ZR
	if(YakuzaTestStunOnlyTrace())
	{
		if(f_TimeFrozenStill[entity] < GetGameTime(entity))
		{
			//The target was NOT stunned.
			return false;
		}
		//if its not a valid enemy ,ignore.
		if(!IsValidEnemy(iExclude, entity, true, false))
		{
			return false;
		}
	}
#endif
	if(!b_NpcHasDied[iExclude])
	{	
		//1 means we treat it as a bullet trace
		return NpcCollisionCheck(iExclude, entity, 1);
	}

	//Custom filter
	if(FilterEntityDo > 0 && FilterEntityDo != entity)
		return false;

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
	
	if(GetTeam(data) == GetTeam(entity))
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

#if defined ZR
	if(i_IsABuilding[data])
	{
		ObjectGeneric objstats = view_as<ObjectGeneric>(data);
		if(objstats.m_iExtrabuilding1 == entity)
			return false;
		else if(objstats.m_iExtrabuilding2 == entity)
			return false;
		else if(IsValidEntity(Building_Mounted[entity]))
			return false;
	}
#endif

	return true;
}

//This is mainly to see if you THE PLAYER!!!!! is stuck inside the WORLD OR BRUSHES OR STUFF LIKE THAT. Not stuck inside an npc, because this code is not made for that.
public bool TraceRayHitWorldOnly(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}
	if(GetTeam(data) == GetTeam(entity))
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
	
	if(GetTeam(data) == GetTeam(entity))
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
#if defined ZR
		if(i_IsABuilding[data])
		{
			ObjectGeneric objstats = view_as<ObjectGeneric>(data);
			if(objstats.m_iExtrabuilding1 == entity)
				return false;
			else if(objstats.m_iExtrabuilding2 == entity)
				return false;
		}
#endif
		if(EntRefToEntIndex(i_IDependOnThisBuilding[data]) == entity)
			return false;
		if(IsValidEntity(Building_Mounted[entity]))
			return false;
		return true;
	}
	if(GetTeam(data) == GetTeam(entity))
		return false;

	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}
	
	if(i_IsABuilding[entity])
	{
#if defined ZR
		if(i_IsABuilding[data])
		{
			ObjectGeneric objstats = view_as<ObjectGeneric>(data);
			if(objstats.m_iExtrabuilding1 == entity)
				return false;
			else if(objstats.m_iExtrabuilding2 == entity)
				return false;
		}
#endif
		if(EntRefToEntIndex(i_IDependOnThisBuilding[data]) == entity)
			return false;
		if(IsValidEntity(Building_Mounted[entity]))
			return false;
		return true;//They blockin me
	}
	return false;
}
