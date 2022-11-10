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

static float Get_old_pos_back[MAXENTITIES][3];
static bool b_WasTeleported[MAXENTITIES];
static const float OFF_THE_MAP[3] = { 16383.0, 16383.0, -16383.0 };
static int i_DoNotTeleportThisPlayer;

public MRESReturn OnIsPlacementPosValidPre(int pThis, Handle hReturn, Handle hParams)
{
	if(pThis==-1)
	{
		return MRES_Ignored;
	}
	if(GetEntPropEnt(pThis, Prop_Send, "m_hBuilder")==-1)
	{
		return MRES_Ignored;
	}
	i_DoNotTeleportThisPlayer = GetEntPropEnt(pThis, Prop_Send, "m_hBuilder");
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && client != i_DoNotTeleportThisPlayer && !b_WasTeleported[client])
		{
			b_WasTeleported[client] = true;
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Get_old_pos_back[client]);
			SetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", OFF_THE_MAP);
		}
	}
	float vec_origin[3] = { 16383.0, 16383.0, -16383.0 };

	for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied) && !b_WasTeleported[baseboss_index_allied])
		{
			b_WasTeleported[baseboss_index_allied] = true;
			GetEntPropVector(baseboss_index_allied, Prop_Data, "m_vecAbsOrigin", Get_old_pos_back[baseboss_index_allied]);
			SDKCall_SetLocalOrigin(baseboss_index_allied, vec_origin);
		}
	}
	//UGLY ASS FIX! Teleport away all entites we wanna ignore, i have no other idea on how...
	return MRES_Ignored;
}

public MRESReturn OnIsPlacementPosValidPost(int pThis, Handle hReturn, Handle hParams)
{
	for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied) && b_WasTeleported[baseboss_index_allied])
		{
			b_WasTeleported[baseboss_index_allied] = false;
			SDKCall_SetLocalOrigin(baseboss_index_allied, Get_old_pos_back[baseboss_index_allied]);
		}
	}
	for(int clientLoop=1; clientLoop<=MaxClients; clientLoop++)
	{
		if(IsClientInGame(clientLoop) && clientLoop != i_DoNotTeleportThisPlayer && b_WasTeleported[clientLoop])
		{
			b_WasTeleported[clientLoop] = false;
			SetEntPropVector(clientLoop, Prop_Data, "m_vecAbsOrigin", Get_old_pos_back[clientLoop]);
		}
	}
	i_DoNotTeleportThisPlayer = 0;

	if(pThis==-1)
	{
		return MRES_Ignored;
	}
	int client = GetEntPropEnt(pThis, Prop_Send, "m_hBuilder")
	if(client==-1)
	{
		DHookSetReturn(hReturn, false);
		return MRES_ChangedOverride;
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
		if(IsValidClient(client))
		{
			if(f_DelayBuildNotif[client] < GetGameTime())
			{
				f_DelayBuildNotif[client] = GetGameTime() + 0.25;
				SetHudTextParams(-1.0, 0.90, 0.5, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Can Build Here");	
			}
		}
		return MRES_Ignored;
	}
	float position[3];
	GetEntPropVector(pThis, Prop_Send, "m_vecOrigin", position);
	
	float endPos[3];
	int buildingHit=0;
	if(IsValidGroundBuilding(position , 130.0, endPos, buildingHit, pThis)) //130.0
	{
		if(iBuildingDependency[buildingHit])
		{
			if(IsValidClient(client))
			{
				if(f_DelayBuildNotif[client] < GetGameTime())
				{
					f_DelayBuildNotif[client] = GetGameTime() + 0.25;
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetHudTextParams(-1.0, 0.90, 0.5, 200, 25, 34, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Build Here");	
				}
			}
			DHookSetReturn(hReturn, false);
			return MRES_ChangedOverride;
		}
		//Bug: The traceray may hit the ground and report obj_X classname
		//Also coords are reported as (0.0, 0.0, 0.0) for both entities?!?
		//And here is my hack
		float endPos2[3];
		GetEntPropVector(buildingHit, Prop_Send, "m_vecOrigin", endPos2);
		//We use custom offets for buildings, so we do our own magic here
		float Delta = 50.0; //default is 50

		switch(i_WhatBuilding[buildingHit])
		{
			case BuildingAmmobox:
			{
				Delta = (32.0 * 0.5); //half it, the buidling is half in the sky!
			}
			case BuildingArmorTable:
			{
				Delta = 35.0;
			}
			case BuildingPerkMachine:
			{
				Delta = 65.0;
			}
			case BuildingPackAPunch:
			{
				Delta = 65.0;
			}
			case BuildingHealingStation:
			{
				Delta = 45.0;
			}
			case BuildingMortar:
			{
				Delta = 80.0;
			}
			case BuildingRailgun:
			{
				Delta = 40.0;
			}

		}
		if(FloatAbs(endPos2[2]-endPos[2])<Delta)
		{
			if(IsValidClient(client))
			{
				if(f_DelayBuildNotif[client] < GetGameTime())
				{
					f_DelayBuildNotif[client] = GetGameTime() + 0.25;
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetHudTextParams(-1.0, 0.90, 0.5, 200, 25, 34, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Build Here");	
				}
			}
			DHookSetReturn(hReturn, false);
			return MRES_ChangedOverride;
		}
		DataPack datapack=new DataPack();
		datapack.WriteCell(EntIndexToEntRef(pThis));
		datapack.WriteCell(EntIndexToEntRef(buildingHit));
		datapack.WriteFloat(endPos[0]);
		datapack.WriteFloat(endPos[1]);
		datapack.WriteFloat(endPos[2]);
		datapack.Reset();
		DHookSetReturn(hReturn, true);
		RequestFrame(Frame_TeleportBuilding, datapack);
		if(IsValidClient(client))
		{
			if(f_DelayBuildNotif[client] < GetGameTime())
			{
				f_DelayBuildNotif[client] = GetGameTime() + 0.25;
				SetHudTextParams(-1.0, 0.90, 0.5, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Can Build Here");	
			}
		}
		npc.bBuildingIsStacked = true;
		return MRES_ChangedOverride;
	}
	if(IsValidClient(client))
	{
		if(f_DelayBuildNotif[client] < GetGameTime())
		{
			f_DelayBuildNotif[client] = GetGameTime() + 0.25;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 0.5, 200, 25, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cannot Build Here");	
		}
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
	bool NoBuildOnBuild = false;
	if(dependenton == 0)
	{
		NoBuildOnBuild = true;
	}

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
	if(!NoBuildOnBuild)
	{
		if(IsValidEntity(dependenton))
		{
			iBuildingDependency[dependenton]=building;
		}
	}
	iBuildingDependency[building]=0; //Nothing depends on us
	delete datapack;
	TeleportEntity(building, vecPos, NULL_VECTOR, NULL_VECTOR);
	
	for(int i=1; i<MaxClients; i++) //Prevent stuck
	{
		if(IsValidClient(i) && IsPlayerAlive(i)) //To-do: Do it the correct way using UTIL_TraceEntity (unfortunately, it requires signature and memory allocations...)
		{
			if(IsPlayerStuckInEnt(i, building)) //Prevent  stuck but dont kill it.
			{
				SDKUnhook(i, SDKHook_PostThink, PhaseThroughOwnBuildings);
				SDKHook(i, SDKHook_PostThink, PhaseThroughOwnBuildings);
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
	Handle trace = TR_TraceRayFilterEx(pos, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID, RayType_Infinite, TraceRayFilterBuildOnBuildings);

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

public bool TraceRayFilterBuildOnBuildings(int entity, int contentsMask)
{
	if(entity==0 || entity==-1) //Never the world or something unknown
	{
		return false;
	}
	if(entity>0 && entity<=MaxClients) //ingore players?
	{
		return false;
	}
	if(b_BuildingIsStacked[entity])
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