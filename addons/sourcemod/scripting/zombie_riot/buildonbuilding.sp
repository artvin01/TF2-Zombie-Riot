int iBuildingDependency[2049] = {0, ...};

DynamicHook dtIsPlacementPosValid;

public void OnPluginStart_Build_on_Building()
{

	GameData hGameConf = new GameData("buildonbuildings_defs.games");

	if(!hGameConf)
		SetFailState("Cannot find file buildonbuildings_defs.games!");

	dtIsPlacementPosValid = DynamicHook.FromConf(hGameConf, "CBaseObject::IsPlacementPosValid()");
	// new DynamicHook(334, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);

	if(!dtIsPlacementPosValid)
		SetFailState("Failed to setup detour for CBaseObject::IsPlacementPosValid");

	// Dummy hook, we need pThis in the post hook
	//dtIsPlacementPosValid.Enable(Hook_Pre, OnIsPlacementPosValidPre);
	// Add a post hook on the function.
	//dtIsPlacementPosValid.Enable(Hook_Post, OnIsPlacementPosValidPost);
	
	HookEvent("player_carryobject", Event_ObjectMoved);

	delete hGameConf;

	return;
}

public void Event_ObjectMoved(Handle event, const char[] name, bool dontBroadCast)
{
	int building=GetEventInt(event, "index");
	if(!IsValidEntity(building))
	{
		return;
	}
	char str[32];
	GetEntityClassname(building, str, sizeof(str));
	if(StrEqual(str, "obj_attachment_sapper", false))
	{
		return;
	}
	if(iBuildingDependency[building])
	{
		SDKHooks_TakeDamage(iBuildingDependency[building], 0, 0, 100000.0, DMG_ACID);
		iBuildingDependency[building]=0;
		for(int i=0; i<2048; i++)
		{
			if(iBuildingDependency[i]==building)
			{
				iBuildingDependency[i]=0;
			}
		}
	}
}

public void Event_ObjectMoved_Custom(int building)
{
	if(!IsValidEntity(building))
	{
		return;
	}
	char str[32];
	GetEntityClassname(building, str, sizeof(str));
	if(StrEqual(str, "obj_attachment_sapper", false))
	{
		return;
	}
	if(iBuildingDependency[building])
	{
		SDKHooks_TakeDamage(iBuildingDependency[building], 0, 0, 100000.0, DMG_ACID);
		iBuildingDependency[building]=0;
		for(int i=0; i<2048; i++)
		{
			if(iBuildingDependency[i]==building)
			{
				iBuildingDependency[i]=0;
			}
		}
	}
}

public void OnMapStart_Build_on_Build()
{
	for(int i=0; i<2048; i++)
	{
		iBuildingDependency[i]=0;
	}
}

public MRESReturn OnIsPlacementPosValidPre(int pThis, Handle hReturn, Handle hParams)
{
	return MRES_Ignored;
}

public MRESReturn OnIsPlacementPosValidPost(int pThis, Handle hReturn, Handle hParams)
{
	if(pThis==-1)
	{
		return MRES_Ignored;
	}
	CClotBody npc = view_as<CClotBody>(pThis);
	
	npc.bBuildingIsStacked = false;
	//Filter the permissible returns - the game is right about building there
	if(DHookGetReturn(hReturn))
	{
		//We are built on "legal" ground, clear the dependency tree
		iBuildingDependency[pThis]=0;
		for(int i=0; i<2048; i++)
		{
			if(iBuildingDependency[i]==pThis)
			{
				iBuildingDependency[i]=0;
			}
		}
		return MRES_Ignored;
	}
	if(GetEntPropEnt(pThis, Prop_Send, "m_hBuilder")==-1)
	{
		DHookSetReturn(hReturn, false);
		return MRES_ChangedOverride;
	}
	float position[3];
	GetEntPropVector(pThis, Prop_Send, "m_vecOrigin", position);
	
	float endPos[3];
	int buildingHit=0;
	if(IsValidGroundBuilding(position , 130.0, endPos, buildingHit, pThis)) //130.0
	{
		if(iBuildingDependency[buildingHit])
		{
			DHookSetReturn(hReturn, false);
			return MRES_ChangedOverride;
		}
		//Bug: The traceray may hit the ground and report obj_X classname
		//Also coords are reported as (0.0, 0.0, 0.0) for both entities?!?
		//And here is my hack
		float endPos2[3];
		GetEntPropVector(buildingHit, Prop_Send, "m_vecOrigin", endPos2);
		const float Delta=50.0;
		if(FloatAbs(endPos2[2]-endPos[2])<Delta)
		{
			DHookSetReturn(hReturn, false);
			return MRES_ChangedOverride;
		}
		DataPack datapack=new DataPack();
		datapack.WriteCell(EntIndexToEntRef(pThis));
		datapack.WriteCell(EntIndexToEntRef(buildingHit));
		datapack.WriteFloat(endPos[0]);
		datapack.WriteFloat(endPos[1]);
		datapack.WriteFloat(endPos[2]);
		datapack.WriteCell(GetEntProp(GetEntPropEnt(pThis, Prop_Send, "m_hBuilder"), Prop_Data, "m_iAmmo", 4, 3));
		datapack.Reset();
		DHookSetReturn(hReturn, true);
		RequestFrame(Frame_TeleportBuilding, datapack);
		npc.bBuildingIsStacked = true;
		return MRES_ChangedOverride;
	}
	DHookSetReturn(hReturn, false);
	return MRES_ChangedOverride;
}

public void OnEntityDestroyed_Build_On_Build(int entity)
{
	if(entity>-1 && entity<=2048 && iBuildingDependency[entity])
	{
		if(IsValidEntity(iBuildingDependency[entity]))
		{
			SDKHooks_TakeDamage(iBuildingDependency[entity], 0, 0, 100000.0, DMG_ACID);
		}
		iBuildingDependency[entity]=0;
	}
	for(int i=0; i<2048; i++)
	{
		if(iBuildingDependency[i]==entity)
		{
			iBuildingDependency[i]=0;
		}
	}
}

public void OnEntityCreated_Build_On_Build(int entity, const char[] classname)
{
	if(StrEqual(classname, "obj_dispenser") || StrEqual(classname, "obj_sentrygun"))
	{
		// Dummy hook, we need pThis in the post hook
		dtIsPlacementPosValid.HookEntity(Hook_Pre, entity, OnIsPlacementPosValidPre);
		// Add a post hook on the function.
		dtIsPlacementPosValid.HookEntity(Hook_Post, entity, OnIsPlacementPosValidPost);
	}

	iBuildingDependency[entity]=0;
	for(int i=0; i<2048; i++)
	{
		if(iBuildingDependency[i]==entity)
		{
			iBuildingDependency[i]=0;
		}
	}
}

public void Frame_TeleportBuilding(DataPack datapack)
{
	int building=EntRefToEntIndex(datapack.ReadCell());
	int dependenton=EntRefToEntIndex(datapack.ReadCell());
	if(!IsValidEntity(building))
	{   
		delete datapack;
		return;
	}
	if(!GetEntProp(building, Prop_Send, "m_bBuilding"))
	{
		delete datapack;
		return;
	}
	float vecPos[3];
	vecPos[0]=datapack.ReadFloat();
	vecPos[1]=datapack.ReadFloat();
	vecPos[2]=datapack.ReadFloat();
	if(IsValidEntity(dependenton))
	{
		iBuildingDependency[dependenton]=building;
	}
	
	iBuildingDependency[building]=0; //Nothing depends on us
	int metal_to_restore=datapack.ReadCell();
	delete datapack;
	TeleportEntity(building, vecPos, NULL_VECTOR, NULL_VECTOR);
	for(int i=1; i<MaxClients; i++) //Prevent stuck
	{
		if(IsValidClient(i) && IsPlayerAlive(i)) //To-do: Do it the correct way using UTIL_TraceEntity (unfortunately, it requires signature and memory allocations...)
		{
			if(IsPlayerStuckInEnt(i, building))
			{
				int owner=GetEntPropEnt(building, Prop_Send, "m_hBuilder");
				AcceptEntityInput(building, "Kill"); //Destroy the building "quietly"
				SetEntProp(owner, Prop_Data, "m_iAmmo", metal_to_restore, 4, 3);
				break;
			}
		}
	}
	//We're done here
}

stock bool IsPlayerStuckInEnt(int client, int ent)
{
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_PLAYERSOLID, TraceRayHitOnlyEnt, ent);
	return TR_DidHit();
}

public bool TraceRayHitOnlyEnt(int entity, int contentsMask, int ent2)
{
	return entity == ent2;  
}


//Derived from function in SMLIB
stock bool IsValidGroundBuilding(const float pos[3], float distance, float posEnd[3], int& buildingHit, int self)
{
	bool foundbuilding = false;
	Handle trace = TR_TraceRayFilterEx(pos, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID, RayType_Infinite, TraceRayFilter);

	if (TR_DidHit(trace))
	{
		if (TR_GetEntityIndex(trace) <= 0 || TR_GetEntityIndex(trace)==self)
		{
			CloseHandle(trace);
			return false;
		}


		TR_GetEndPosition(posEnd, trace);

		if (GetVectorDistance(pos, posEnd, true) <= (distance * distance)) {
			foundbuilding = true;
			buildingHit=TR_GetEntityIndex(trace);
		}
	}

	CloseHandle(trace);

	return foundbuilding;
}

public bool TraceRayFilter(int entity, int contentsMask)
{
	if(entity==0 || entity==-1) //Never the world or something unknown
	{
		return false;
	}
	if(entity>0 && entity<=MaxClients) //ingore players?
	{
		return false;
	}
	char str[32];
	GetEntityClassname(entity, str, sizeof(str));
	if(StrContains(str, "obj_", false)>-1 && !StrEqual(str, "obj_teleporter", false)) // We don't want to build on teleporters(exploits, stuck, ...) You know what i mean.
	{
		return true;
	}
	return false;
}