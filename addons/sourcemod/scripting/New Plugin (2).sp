public Action Timer_DroppedBuildingWaitArmorTable(Handle htimer, DataPack pack)
{
	pack.Reset();
	int entref = pack.ReadCell();
	int original_entity = pack.ReadCell();
	int client_original_index = pack.ReadCell(); //Need original!
	
	int obj=EntRefToEntIndex(entref);
	
	if(!IsValidEntity(obj))
	{
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		
		i_SupportBuildingsBuild[client_original_index] -= 1;
		return Plugin_Stop;
	}
	//Wait until full complete
	if(GetEntPropFloat(obj, Prop_Send, "m_flPercentageConstructed") == 1.0)
	{
		if(Building_Constructed[obj])
		{
			SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") | EF_NODRAW);
		//	SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
			return Plugin_Continue;
		}
		CClotBody npc = view_as<CClotBody>(obj);
		npc.bBuildingIsPlaced = true;
			
		Building_Constructed[obj] = true;
	
		
		/*
		int ent=-1;
		while((ent=FindEntityByClassname2(ent, "vgui_screen"))!=-1)
		{
			if(GetEntPropEnt(ent, Prop_Data, "m_hMoveParent")==obj)
			{
				RemoveEntity(ent);
			}
		}
		*/
		
		float vOrigin[3];
		float vAngles[3];
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);
			GetEntPropVector(obj, Prop_Data, "m_angRotation", vAngles);
			TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
		}
		else
		{
			prop1 = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(prop1))
			{
				DispatchKeyValue(prop1, "model", "models/props_manor/table_01.mdl");
				DispatchKeyValue(prop1, "modelscale", "1.0");
				DispatchKeyValue(prop1, "StartDisabled", "false");
				DispatchKeyValue(prop1, "Solid", "0");
				SetEntProp(prop1, Prop_Data, "m_nSolidType", 0);
				DispatchSpawn(prop1);
				SetEntityCollisionGroup(prop1, 1);
				AcceptEntityInput(prop1, "DisableShadow");
				AcceptEntityInput(prop1, "DisableCollision");
				Building_Hidden_Prop[obj][0] = EntIndexToEntRef(prop1);
				Building_Hidden_Prop_To_Building[prop1] = EntIndexToEntRef(obj);
				SetEntityRenderMode(prop1, RENDER_TRANSCOLOR);

				GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);
				GetEntPropVector(obj, Prop_Data, "m_angRotation", vAngles);
				TeleportEntity(prop1, vOrigin, vAngles, NULL_VECTOR);
				SDKHook(prop1, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_1);
			}
		}
		
		if(IsValidEntity(prop2))
		{
			GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);
			GetEntPropVector(obj, Prop_Data, "m_angRotation", vAngles);
			TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
		}
		else
		{
			prop2 = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(prop2))
			{
				DispatchKeyValue(prop2, "model", "models/props_manor/table_01.mdl");
				DispatchKeyValue(prop2, "modelscale", "1.0");
				DispatchKeyValue(prop2, "StartDisabled", "false");
				DispatchKeyValue(prop2, "Solid", "0");
				SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
				DispatchSpawn(prop2);
				SetEntityCollisionGroup(prop2, 1);
				AcceptEntityInput(prop2, "DisableShadow");
				AcceptEntityInput(prop2, "DisableCollision");
				Building_Hidden_Prop[obj][1] = EntIndexToEntRef(prop2);
				Building_Hidden_Prop_To_Building[prop2] = EntIndexToEntRef(obj);
				SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);

				GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);
				GetEntPropVector(obj, Prop_Data, "m_angRotation", vAngles);
				TeleportEntity(prop2, vOrigin, vAngles, NULL_VECTOR);
				SDKHook(prop2, SDKHook_SetTransmit, BuildingSetAlphaClientSideReady_SetTransmitProp_2);
			}
		}
		
		static const float minbounds[3] = {-10.0, -20.0, 0.0};
		static const float maxbounds[3] = {10.0, 20.0, -2.0};
		SetEntPropVector(obj, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(obj, Prop_Send, "m_vecMaxs", maxbounds);
		
	//	float vOrigin[3];
									
	//	GetEntPropVector(obj, Prop_Data, "m_vecAbsOrigin", vOrigin);

		//vOrigin[2] += 10.0;
															
	//	TeleportEntity(obj, vOrigin, NULL_VECTOR, NULL_VECTOR);
					
		SetEntityModel(obj, "models/props_manor/table_01.mdl");
		//return Plugin_Stop;
	}
	else
	{
		SetEntProp(obj, Prop_Send, "m_fEffects", GetEntProp(obj, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		
		int prop1 = EntRefToEntIndex(Building_Hidden_Prop[obj][0]);
		int prop2 = EntRefToEntIndex(Building_Hidden_Prop[obj][1]);
		
		if(IsValidEntity(prop1))
		{
			RemoveEntity(prop1);
		}
		if(IsValidEntity(prop2))
		{
			RemoveEntity(prop2);
		}
		Building_Constructed[obj] = false;
	}
	return Plugin_Continue;
}