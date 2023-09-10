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
bool ShouldCollideAlly_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex)
{
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		return false;
	}	
	if(b_is_a_brush[otherindex])
	{
		return true;
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
		NpcStartTouch(loco,otherindex);

	return true;
}
public bool ShouldCollideAllyInvince(CBaseNPC_Locomotion loco, int otherindex)
{
	return ShouldCollideAllyInvince_Internal(loco, otherindex); 
}

bool ShouldCollideAllyInvince_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0)
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
	if(b_CantCollidieAlly[otherindex]) 
	{
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


public bool ShouldCollideEnemy(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemy_Internal(loco, otherindex);
}

bool ShouldCollideEnemy_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex)
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
	if(b_CantCollidie[otherindex]) //no change in performance..., almost.
	{
		return false;
	}
	if(b_IsVehicle[otherindex])
	{
		return true;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}


public bool ShouldCollideEnemyIngoreBuilding(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemyIngoreBuilding_Internal(loco, otherindex);
}

bool ShouldCollideEnemyIngoreBuilding_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex)
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
	if(b_IsVehicle[otherindex])
	{
		return true;
	}
	if(loco != view_as<CBaseNPC_Locomotion>(0))
		NpcStartTouch(loco,otherindex);

	return true;
}

public bool ShouldCollideEnemyTD(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemyTD_Internal(loco, otherindex);
}

bool ShouldCollideEnemyTD_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	//entirely ignore players
	#if defined ZR
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
		if(i_NpcInternalId[otherindex] == VIP_BUILDING || i_Target[npc] == otherindex)
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

	#endif
	return true;
}

public bool ShouldCollideEnemyTDIgnoreBuilding(CBaseNPC_Locomotion loco, int otherindex)
{ 
	return ShouldCollideEnemyTDIgnoreBuilding_Internal(loco, otherindex);
}

bool ShouldCollideEnemyTDIgnoreBuilding_Internal(CBaseNPC_Locomotion loco = view_as<CBaseNPC_Locomotion>(0), int otherindex, int extrarules = 0, int npc = 0)
{ 
	//entirely ignore players
	
	#if defined ZR
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
		if(i_NpcInternalId[otherindex] == VIP_BUILDING || i_Target[npc] == otherindex)
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

	#endif
	return true;
}

public void Change_Npc_Collision(int npc, int CollisionType)
{
	if(IsValidEntity(npc))
	{
		CBaseNPC baseNPC = view_as<CClotBody>(npc).GetBaseNPC();
		CBaseNPC_Locomotion locomotion = baseNPC.GetLocomotion();
		b_NpcCollisionType[npc] = CollisionType;
		switch(CollisionType)
		{
			case 1:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideEnemyIngoreBuilding);
			}
			case 2:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideEnemy);
			}
			case 3:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideAllyInvince);
			}
			case 4:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideAlly);
			}
			case 5:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideEnemyTD);
			}
			case 6:
			{
				locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollideEnemyTDIgnoreBuilding);
			}
		}
	}
}


bool NpcCollisionCheck(int npc, int other, int extrarules = 0)
{
	switch(b_NpcCollisionType[npc])
	{
		case 1:
		{
			return ShouldCollideEnemyIngoreBuilding_Internal(_,other);
		}
		case 2:
		{
			return ShouldCollideEnemy_Internal(_,other);
		}
		case 3:
		{
			return ShouldCollideAllyInvince_Internal(_,other,extrarules);
		}
		case 4:
		{
			return ShouldCollideAlly_Internal(_,other);
		}
		case 5:
		{
			return ShouldCollideEnemyTD_Internal(_,other,extrarules, npc);
		}
		case 6:
		{
			return ShouldCollideEnemyTDIgnoreBuilding_Internal(_,other,extrarules, npc);
		}
	}
	return true; //somehow nothing happens collide with whatever it was!
}



bool IsEntityTowerDefense(int entity)
{
	if(b_NpcCollisionType[entity] == num_ShouldCollideEnemyTD || b_NpcCollisionType[entity] == num_ShouldCollideEnemyTDIgnoreBuilding)
	{
		return true;
	}
	return false;
}