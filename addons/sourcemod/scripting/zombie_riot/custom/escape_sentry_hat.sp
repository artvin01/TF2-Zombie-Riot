#pragma semicolon 1
#pragma newdecls required

static Handle Mount_Building[MAXPLAYERS + 1];

static int Building_particle[MAXENTITIES];
static int Building_particle_Owner[MAXENTITIES];

//for strength.
static int Building_IconType[MAXENTITIES];

public void SentryHat_OnPluginStart()
{
	HookEvent("player_builtobject", Event_player_builtobject);
	HookEvent("object_detonated", Object_Detonated);
//	AddCommandListener(CancelBuild, "build");			//Cancel out actions
}
public void EscapeSentryHat_MapStart()
{
	Zero(Building_IconType);
}
int BuildingIconType(int client)
{
	return Building_IconType[client];
}
/*
void EscapeSentryHat_ApplyBuidingIcon(int client, bool ignore = false)
{
	int converted_ref = EntRefToEntIndex(Building_Mounted[client]);
	if(IsValidEntity(converted_ref) && !LastMann) //Strip icons! they need the haste buff!
	{
		if(!BuildingIconShown[client] || ignore)
		{
			BuildingIconShown[client] = true;
			TF2_AddCondition(client, TFCond_RuneStrength, -1.0);
			//hide powerup icon.
//			CreateTimer(0.5, RemoveStrengthPowerup, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		float Cooldowntocheck =	Building_Collect_Cooldown[converted_ref][client];
		bool DoSentryCheck = false;
		switch(Building_IconType[client])
		{
			case 3,4,8,9:
				DoSentryCheck = true;
		}

		if(DoSentryCheck) //all non supportive, like sentry and so on.
		{
			Cooldowntocheck = f_BuildingIsNotReady[client];
		}
		if(Cooldowntocheck < GetGameTime()) //Self indication on if your building is ready!
		{
			if(!BuildingIconShownSpecific[client] || ignore)
			{
				BuildingIconShownSpecific[client] = true;
				switch(Building_IconType[client])
				{
					case 1:
					{
						TF2_AddCondition(client, TFCond_RuneWarlock, -1.0);
					}
					case 2:
					{
						TF2_AddCondition(client, TFCond_RuneRegen, -1.0);
					}
					case 5:
					{
						TF2_AddCondition(client, TFCond_KingRune, -1.0);
					}
					case 6:
					{
						TF2_AddCondition(client, TFCond_RuneKnockout, -1.0);
					}
					case 7:
					{
						TF2_AddCondition(client, TFCond_RuneVampire, -1.0);
					}
					case 8:
					{
						TF2_AddCondition(client, TFCond_RuneWarlock, -1.0);
					}
					default:
					{
						TF2_AddCondition(client, TFCond_RunePrecision, -1.0);
					}
				}		
			}	
		}
		else if(BuildingIconShownSpecific[client])
		{
			BuildingIconShownSpecific[client] = false;
			TF2_RemoveCondition(client, TFCond_RuneWarlock);
			TF2_RemoveCondition(client, TFCond_RuneRegen);
			TF2_RemoveCondition(client, TFCond_KingRune);
			TF2_RemoveCondition(client, TFCond_RuneKnockout);
			TF2_RemoveCondition(client, TFCond_RuneVampire);
			TF2_RemoveCondition(client, TFCond_RuneWarlock);
			TF2_RemoveCondition(client, TFCond_RunePrecision);
		}
	}
	else if(BuildingIconShown[client])
	{
		BuildingIconShown[client] = false;		
		TF2_RemoveCondition(client, TFCond_RuneStrength);
		if(BuildingIconShownSpecific[client])
		{
			BuildingIconShownSpecific[client] = false;
			TF2_RemoveCondition(client, TFCond_RuneWarlock);
			TF2_RemoveCondition(client, TFCond_RuneRegen);
			TF2_RemoveCondition(client, TFCond_KingRune);
			TF2_RemoveCondition(client, TFCond_RuneKnockout);
			TF2_RemoveCondition(client, TFCond_RuneVampire);
			TF2_RemoveCondition(client, TFCond_RuneWarlock);
			TF2_RemoveCondition(client, TFCond_RunePrecision);
		}
	}
}
*/
/*
public Action CancelBuild(int client, const char[] command, int args)
{
	if(IsValidClient(client))
	{
		if(!b_AllowBuildCommand[client])
		{
			return Plugin_Handled;
		}
	}
	b_AllowBuildCommand[client] = false;
	return Plugin_Continue;
}
*/
public Action Object_Detonated(Handle event, const char[] name, bool dontBroadcast)
{
	int entity = GetEventInt(event, "index");
	i_BeingCarried[entity] = false;
	SetEntProp(entity, Prop_Send, "m_bCarried", false);	
	return Plugin_Handled;
}

public Action Event_player_builtobject(Handle event, const char[] name, bool dontBroadcast)
{
	int entity = GetEventInt(event, "index");
//	int id = GetEventInt(event, "userid");
//	int owner = GetClientOfUserId(id);
	f_ClientInvul[entity] = GetGameTime() + 0.1; //Slight invulnerability
	CClotBody npc = view_as<CClotBody>(entity);
	npc.bBuildingIsPlaced = true;
	i_BeingCarried[entity] = false;
	return Plugin_Continue;
}

public Action RemoveStrengthPowerup(Handle sentryHud, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsClientConnected(client) && IsPlayerAlive(client))
	{
		//SEE IF CRASHES STOPPED!
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(client, "DispatchEffect"); 
	}
	return Plugin_Stop;
}


public Action Check_If_Owner_Dead(Handle sentryHud, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		if(!IsPlayerAlive(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")))
		{
			SDKHooks_TakeDamage(entity, 0, 0, 100000.0, DMG_ACID); //Kill off sentry if the owner is dead in this cenario, kill timer too
			return Plugin_Stop;
		}
		else
		{
			CClotBody npc = view_as<CClotBody>(entity);
			npc.bBuildingIsStacked = true;	//Make npc's ingore the sentrygun, or else they act in wacky ways
			int Inf_Health = 10000;
			SetVariantInt(Inf_Health);
			AcceptEntityInput(entity, "SetHealth");
			SetEntProp(entity, Prop_Send, "m_iMaxHealth", Inf_Health); 	//Make sure the sentrygun cannot die in any other way in escape mode
																		//other then the player dying, idk godmode for sentries lol just do 10k hp
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

int i_BuildingSelectedToBeDeleted[MAXPLAYERS + 1];

public void DeleteBuildingLookedAt(int client)
{
	int entity = GetClientPointVisible(client, _ , true, true);
	if(entity > MaxClients)
	{
		if (IsValidEntity(entity))
		{
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(!StrContains(buffer, "obj_"))
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
					{
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
						DataPack pack;
						CreateDataTimer(0.1, DeleteBuildingTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(client);
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(GetClientUserId(client));
						Menu menu = new Menu(DeleteBuildingMenu);

						SetGlobalTransTarget(client);
						
						menu.SetTitle("%t", "Delete Current Marked Building");

						FormatEx(buffer, sizeof(buffer), "%t", "Yes");
						menu.AddItem("-1", buffer);
						FormatEx(buffer, sizeof(buffer), "%t", "No");
						menu.AddItem("-2", buffer);
									
						menu.ExitButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
					}
				}
			}
		}
	}
}

bool Player_Mounting_Building[MAXPLAYERS + 1];

public void MountBuildingToBack(int client, int weapon, bool crit)
{
	if(!Player_Mounting_Building[client])
	{
		int entity = GetClientPointVisible(client, _ , true, true);
		if(entity > MaxClients)
		{
			if (IsValidEntity(entity))
			{
				static char buffer[64];
				if(GetEntityClassname(entity, buffer, sizeof(buffer)))
				{
					if(!StrContains(buffer, "obj_"))
					{
						if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
						{
							GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
							
							if(StrEqual(buffer, "zr_ammobox"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_armortable"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_mortar"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_railgun"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_perkmachine"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_packapunch"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_healingstation"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_village"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else if (StrEqual(buffer, "zr_summoner"))
							{
								if(Doing_Handle_Mount[client])
								{
									KillTimer(Mount_Building[client]);
								}
								Doing_Handle_Mount[client] = true;
								DataPack pack;
								Mount_Building[client] = CreateDataTimer(1.0, Mount_Building_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(client);
								pack.WriteCell(EntIndexToEntRef(entity));
								pack.WriteCell(GetClientUserId(client));
								SetGlobalTransTarget(client);
								f_DelayLookingAtHud[client] = GetGameTime() + 1.0;	
								PrintCenterText(client, "%t", "Picking Up Building");
							}
							else
							{
								ClientCommand(client, "playgamesound items/medshotno1.wav");
								SetDefaultHudPosition(client);
								SetGlobalTransTarget(client);
								ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Cant Mount This");	
							}	
						}
					}
				}
			}
		}
	}
	else
	{
		UnequipDispenser(client);
	}
}

public Action DeleteBuildingTimer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());

	if(IsValidClient(client))
	{
		if (IsValidEntity(entity) && entity == EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", m_vecMaxs);
			float fPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
			TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, 0.2, view_as<int>({255, 0, 0, 255}));
			return Plugin_Continue;
		}
		else
		{
			i_BuildingSelectedToBeDeleted[original_index] = -1;
			return Plugin_Stop;
		}
	}
	else
	{
		i_BuildingSelectedToBeDeleted[original_index] = -1;
		return Plugin_Stop;
	}
}


public int DeleteBuildingMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			if(IsValidClient(client))
			{
				i_BuildingSelectedToBeDeleted[client] = -1;		
			}
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				i_BuildingSelectedToBeDeleted[client] = -1;		
			}
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int entity = EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]);
						if (IsValidEntity(entity))
						{
							RemoveEntity(entity);
						}
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						i_BuildingSelectedToBeDeleted[client] = -1;		
					}
				}
			}
		}
	}
	return 0;
}


public Action Mount_Building_Timer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	
	Doing_Handle_Mount[original_index] = false;

	if(IsValidClient(client))
	{
		PrintCenterText(client, " ");
		if (IsValidEntity(entity))
		{
			int looking_at = GetClientPointVisible(client, _ , true, true);
			if (looking_at == entity)
			{
				static char buffer[64];
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrEqual(buffer, "zr_ammobox"))
				{
					EquipDispenser(client, entity, 2);
				}
				else if (StrEqual(buffer, "zr_armortable"))
				{
					EquipDispenser(client, entity, 1);
				}	
				else if (StrEqual(buffer, "zr_mortar"))
				{
					EquipDispenser(client, entity, 3);
				}	
				else if (StrEqual(buffer, "zr_railgun"))
				{
					EquipDispenser(client, entity, 4);
				}	
				else if (StrEqual(buffer, "zr_perkmachine"))
				{
					EquipDispenser(client, entity, 5);
				}					
				else if (StrEqual(buffer, "zr_packapunch"))
				{
					EquipDispenser(client, entity, 6);
				}	
				else if (StrEqual(buffer, "zr_healingstation"))
				{
					EquipDispenser(client, entity, 7);
				}	
				else if (StrEqual(buffer, "zr_village"))
				{
					EquipDispenser(client, entity, 8);
				}	
				else if (StrEqual(buffer, "zr_summoner"))
				{
					EquipDispenser(client, entity, 9);
				}					
			}
		}
	}
	return Plugin_Handled;	
}

// 4 = zr_railgun
// 3 = zr_mortar
// 2 = zr_ammobox
// 1 = zr_armortable
stock void EquipDispenser(int client, int target, int building_variant)
{
	float dPos[3], bPos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", dPos);
	GetClientAbsOrigin(client, bPos);
	
	if(GetVectorDistance(dPos, bPos) <= 125.0 && IsValidBuilding(target))
	{	
		/*
		int iLink = CreateLink(client);
		
		float TeleportToPlayer[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", TeleportToPlayer);
		TeleportEntity(target, TeleportToPlayer, NULL_VECTOR, NULL_VECTOR);
	
		SetVariantString("!activator");
		AcceptEntityInput(target, "SetParent", iLink); 
		
		SetVariantString("root"); 
		AcceptEntityInput(target, "SetParentAttachment", iLink); 
		Building_Owner[iLink] = client;
		SDKHook(iLink, SDKHook_SetTransmit, FirstPersonInvis);
		
		SetEntPropEnt(target, Prop_Send, "m_hEffectEntity", iLink);
		i_BeingCarried[target] = true;
		float pPos[3], pAng[3];
		
		SetEntPropVector(target, Prop_Send, "m_vecOrigin", pPos);
		SetEntPropVector(target, Prop_Send, "m_angRotation", pAng);
		
		SetEntProp(target, Prop_Send, "m_nSolidType", 0);
		SetEntProp(target, Prop_Send, "m_usSolidFlags", 0x0004);
		*/
		CClotBody npc = view_as<CClotBody>(target);
		npc.bBuildingIsPlaced = false;
		
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

//		CreateTimer(0.5, RemoveStrengthPowerup, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		//hide powerup icon.	
//		SetVariantString("ParticleEffectStop");
//		AcceptEntityInput(client, "DispatchEffect"); 
//		flPos[2] += 90.0;
//		Building_particle_2[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_strength", client));
//		SDKHook(Building_particle_2[client], SDKHook_SetTransmit, ParticleTransmitSelf);
//		SDKUnhook(Building_particle_2[client], SDKHook_SetTransmit, ParticleTransmit);
				
//		flPos[2] += 20.0;
		flPos[2] += 100.0;
		Building_IconType[client] = building_variant;
		switch(building_variant)
		{
			case 1:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_resist", client));
			}
			case 2:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_regen", client));
			}
			case 5:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_king", client));
			}
			case 6:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_knockout", client)); //ze pap :)
			}
			case 7:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_vampire", client)); //ze healing station
			}
			case 8:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_reflect", client)); // Village
			}
			default:
			{
				Building_particle[client] = EntIndexToEntRef(ParticleEffectAt_Building_Custom(flPos, "powerup_icon_precision", client)); // Village
			}
		}
		Building_Mounted[client] = EntIndexToEntRef(target);
		i_BeingCarried[target] = true;
		Player_Mounting_Building[client] = true;
		Event_ObjectMoved_Custom(target);
		TeleportEntity(target, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		g_CarriedDispenser[client] = EntIndexToEntRef(target);
	}
}

public void OnEntityDestroyed_BackPack(int iEntity)
{
	if(i_IsABuilding[iEntity])
	{
		SetEntProp(iEntity, Prop_Send, "m_bCarried", false);
		int builder = GetEntPropEnt(iEntity, Prop_Send, "m_hBuilder");
		if(builder > 0 && builder <= MaxClients && IsClientInGame(builder) && iEntity == EntRefToEntIndex(g_CarriedDispenser[builder]))
		{
			if(g_CarriedDispenser[builder] != INVALID_ENT_REFERENCE)
			{
				int Dispenser = EntRefToEntIndex(g_CarriedDispenser[builder]);
				
				int converted_ref = EntRefToEntIndex(Building_particle[builder]);
				if(converted_ref > 0 && IsValidEntity(converted_ref))
				{
					SDKUnhook(converted_ref, SDKHook_SetTransmit, ParticleTransmit);
					AcceptEntityInput(converted_ref, "Stop");
					AcceptEntityInput(converted_ref, "Kill");
				}
				Building_Mounted[builder] = 0;
				i_BeingCarried[Dispenser] = false;
				Player_Mounting_Building[builder] = false;
				g_CarriedDispenser[builder] = INVALID_ENT_REFERENCE;
			}
		}
	}
}

stock void DestroyDispenser(int client)
{
	int Dispenser = EntRefToEntIndex(g_CarriedDispenser[client]);
	if(Dispenser != INVALID_ENT_REFERENCE)
	{
	//	int iLink = GetEntPropEnt(Dispenser, Prop_Send, "m_hEffectEntity");
	//	if(IsValidEntity(iLink))
		{
			/*
			AcceptEntityInput(iLink, "ClearParent");
			AcceptEntityInput(iLink, "Kill");
			*/
			Building_IconType[client] = 0;
			int converted_ref = EntRefToEntIndex(Building_particle[client]);
			if(converted_ref > 0 && IsValidEntity(converted_ref))
			{
				SDKUnhook(converted_ref, SDKHook_SetTransmit, ParticleTransmit);
				AcceptEntityInput(converted_ref, "Stop");
				AcceptEntityInput(converted_ref, "Kill");
			}
			/*
			converted_ref = EntRefToEntIndex(Building_particle_2[client]);
			if(converted_ref > 0 && IsValidEntity(converted_ref))
			{
				SDKUnhook(converted_ref, SDKHook_SetTransmit, ParticleTransmitSelf);
				AcceptEntityInput(converted_ref, "Stop");
				AcceptEntityInput(converted_ref, "Kill");
			}
			*/
			SetVariantInt(999999);
			AcceptEntityInput(Dispenser, "RemoveHealth");
			Building_Mounted[client] = 0;
			i_BeingCarried[Dispenser] = false;
			Player_Mounting_Building[client] = false;
			
			g_CarriedDispenser[client] = INVALID_ENT_REFERENCE;
		}
	}
	{
		Building_Mounted[client] = 0;
		Player_Mounting_Building[client] = false;
		g_CarriedDispenser[client] = INVALID_ENT_REFERENCE; //Just remove entirely, just make sure.
	}
}

stock bool IsValidBuilding(int iBuilding)
{
	if (IsValidEntity(iBuilding))
	{
		if(GetEntPropFloat(iBuilding, Prop_Send, "m_flPercentageConstructed") == 1.0)
			return true;
	}
	
	return false;
}

stock int CreateLink(int iClient)
{
	int iLink = CreateEntityByName("tf_taunt_prop");
	DispatchKeyValue(iLink, "targetname", "DispenserLink");
	DispatchSpawn(iLink); 
	
	char strModel[PLATFORM_MAX_PATH];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
	
	SetEntityModel(iLink, strModel);
	
	SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
	
	float TeleportToPlayer[3];
	
	GetEntPropVector(iClient, Prop_Data, "m_vecAbsOrigin", TeleportToPlayer);
	TeleportEntity(iLink, TeleportToPlayer, NULL_VECTOR, NULL_VECTOR);
	
	SetVariantString("!activator"); 
	AcceptEntityInput(iLink, "SetParent", iClient); 
	
	SetVariantString("root"); 
	AcceptEntityInput(iLink, "SetParentAttachment", iClient);
	
	return iLink;
}

stock void UnequipDispenser(int client)
{
	int entity = EntRefToEntIndex(g_CarriedDispenser[client]);
	if(entity != INVALID_ENT_REFERENCE)
	{
		static char buffer[64];
		if(GetEntityClassname(entity, buffer, sizeof(buffer)))
		{		
			if(!StrContains(buffer, "obj_dispenser"))
			{
				TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				int iBuilder = Spawn_Buildable(client);
				SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
				SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
				
				SDKCall(g_hSDKMakeCarriedObjectDispenser, entity, client);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
				Event_ObjectMoved_Custom(entity);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
				SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
			//	TF2_SetPlayerClass(client, TFClass_Engineer);
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				Spawn_Buildable(client);
				TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
				
			}
			else if(!StrContains(buffer, "obj_sentrygun"))
			{
				TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				int iBuilder = Spawn_Buildable(client);
				SetEntProp(iBuilder, Prop_Send, "m_hObjectBeingBuilt", entity); 
				SetEntProp(iBuilder, Prop_Send, "m_iBuildState", 2); 
				
				SDKCall(g_hSDKMakeCarriedObjectSentry, entity, client);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder); 
				Event_ObjectMoved_Custom(entity);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iBuilder);
				SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);				
			//	TF2_SetPlayerClass(client, TFClass_Engineer);
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
				Spawn_Buildable(client);
				TF2_SetPlayerClass(client, TFClass_Engineer, false, false);
			}	
			/*
			int iLink = GetEntPropEnt(entity, Prop_Send, "m_hEffectEntity");
			if(IsValidEntity(iLink))
			{
				AcceptEntityInput(entity, "ClearParent");
				AcceptEntityInput(iLink, "ClearParent");
				AcceptEntityInput(iLink, "Kill");
			}
			*/
			Building_IconType[client] = 0;

			int converted_ref = EntRefToEntIndex(Building_particle[client]);
			if(converted_ref > 0 && IsValidEntity(converted_ref))
			{
				SDKUnhook(converted_ref, SDKHook_SetTransmit, ParticleTransmit);
				AcceptEntityInput(converted_ref, "Stop");
				AcceptEntityInput(converted_ref, "Kill");
			}
			/*
			converted_ref = EntRefToEntIndex(Building_particle_2[client]);
			if(converted_ref > 0 && IsValidEntity(converted_ref))
			{
				SDKUnhook(converted_ref, SDKHook_SetTransmit, ParticleTransmitSelf);
				AcceptEntityInput(converted_ref, "Stop");
				AcceptEntityInput(converted_ref, "Kill");
			}
			*/
			Building_Mounted[client] = 0;
			SetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed", 0.1);
			i_BeingCarried[entity] = false;
			Player_Mounting_Building[client] = false;
			float StandStill[3];
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, StandStill);
		}
		g_CarriedDispenser[client] = INVALID_ENT_REFERENCE;
	}
	else
	{
		Building_Mounted[client] = 0;
		Player_Mounting_Building[client] = false;
		g_CarriedDispenser[client] = INVALID_ENT_REFERENCE; //Just remove entirely, just make sure.
	}
}

stock int ParticleEffectAt_Building_Custom(float position[3], char[] effectName, int iParent, const char[] szAttachment = "", float vOffsets[3] = {0.0,0.0,0.0})
{
	int particle = CreateEntityByName("info_particle_system");

	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);

		SetParent(iParent, particle);

		ActivateEntity(particle);

		AcceptEntityInput(particle, "start");

		Building_particle_Owner[particle] = iParent;

		SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
		SDKHook(particle, SDKHook_SetTransmit, ParticleTransmit);
		
		//CreateTimer(0.1, Activate_particle_late, particle, TIMER_FLAG_NO_MAPCHANGE);
	}

	return particle;
}

public Action ParticleTransmit(int entity, int client)
{
	if(client == Building_particle_Owner[entity])
		return Plugin_Handled;

	static int building_attached;

	building_attached = EntRefToEntIndex(Building_Mounted[Building_particle_Owner[entity]]);

	if(IsValidEntity(building_attached))
	{
		static float Cooldowntocheck;
		Cooldowntocheck = Building_Collect_Cooldown[building_attached][client];
		static bool DoSentryCheck;
		DoSentryCheck = false;
		switch(Building_IconType[Building_particle_Owner[entity]])
		{
			case 3,4,8,9:
				DoSentryCheck = true;
		}

		if(DoSentryCheck) //all non supportive, like sentry and so on.
		{
			Cooldowntocheck = f_BuildingIsNotReady[Building_particle_Owner[entity]];
		}

		if(Cooldowntocheck > GetGameTime())
			return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action ParticleTransmitCitizen(int entity, int client)
{
	static int building_attached;
	building_attached = EntRefToEntIndex(Building_particle_Owner[entity]);

	if(IsValidEntity(building_attached))
	{
		static float Cooldowntocheck;
		Cooldowntocheck = Building_Collect_Cooldown[building_attached][client];

		if(Cooldowntocheck > GetGameTime())
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

/*
public Action ParticleTransmitSelf(int entity, int client)
{
	if(client == Building_particle_Owner[entity])
		return Plugin_Handled;

	return Plugin_Continue;
}
*/
public void CleanAllBuildingEscape()
{
	Zero(Player_Mounting_Building);
	Zero(Building_Mounted);
}