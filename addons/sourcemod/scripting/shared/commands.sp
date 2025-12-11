#pragma semicolon 1
#pragma newdecls required

#if defined ZR
static bool BlockNext[MAXPLAYERS];
#endif

void Commands_PluginStart()
{
	//AddCommandListener(OnNavCommand);
	AddCommandListener(OnAutoTeam, "autoteam");
	AddCommandListener(OnAutoTeam, "jointeam");
	AddCommandListener(OnBuildCmd, "build");
	AddCommandListener(OnDropItem, "dropitem");
	AddCommandListener(OnTaunt, "taunt");
	AddCommandListener(OnTaunt, "+taunt");
	AddCommandListener(OnSayCommand, "say");
	AddCommandListener(OnSayCommand, "say_team");

#if defined ZR || defined RPG
	AddCommandListener(Command_Voicemenu, "voicemenu");
#endif

#if defined ZR || defined RPG
	AddCommandListener(OnJoinClass, "joinclass");
#endif

}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	char buffer[64];
	KvGetSectionName(kv, buffer, sizeof(buffer));
	PrintToChatAll(" CMD %s",buffer);
	if(f_PreventMovementClient[client] > GetGameTime())
	{
#if defined ZR
		//Medic E call, its really really delayed it is NOT the same as voicemenu 0 0, this is way faster.
		if(StrEqual(buffer, "+helpme_server", false))
		{
			//add a delay, so if you call E it doesnt do the voice menu one, though keep the voice menu one for really epic cfg nerds.
			f_MedicCallIngore[client] = GetGameTime() + 0.5;
			
			bool has_been_done = BuildingCustomCommand(client);
			if(has_been_done)
			{
				return Plugin_Handled;
			}
		}
		else if(!StrContains(buffer, "MvM_UpgradesBegin", false))
		{
			//Remove MVM buy hud
			BlockNext[client] = true;
			ClientCommand(client, "+inspect");
			ClientCommand(client, "-inspect");
			return Plugin_Handled;
		}
		else if(!StrContains(buffer, "MvM_Upgrade", false))
		{
			return Plugin_Handled;
		}
#endif
		//dont call anything.
		return Plugin_Handled;
	}
#if defined ZR
	if(BlockNext[client])
	{
		if(!StrEqual(buffer, "+inspect_server", false))
			BlockNext[client] = false;
		
		return Plugin_Handled;
	}
#endif
	
#if defined RTS_CAMERA
	if(RTSCamera_ClientCommandKeyValues(client, buffer))
	{
		return Plugin_Handled;
	}
#endif

	if(StrEqual(buffer, "+use_action_slot_item_server", false))
	{
#if defined ZR
		b_HoldingInspectWeapon[client] = true;
		if((LastStoreMenu[client] && LastStoreMenu_Store[client]))
		{
			Store_OpenItemPage(client);
		}
		else if(!TF2_IsPlayerInCondition(client, TFCond_Slowed) && !TF2_IsPlayerInCondition(client, TFCond_Zoomed))
		{
			Store_SwapItems(client);
		}
#endif
		return Plugin_Continue;
	}
#if defined ZR
	else if(!StrContains(buffer, "MvM_UpgradesBegin", false))
	{
		//Remove MVM buy hud
		BlockNext[client] = true;
		ClientCommand(client, "+inspect");
		ClientCommand(client, "-inspect");
		return Plugin_Handled;
	}
	else if(!StrContains(buffer, "MvM_Upgrade", false))
	{
		return Plugin_Handled;
	}
	else if(StrEqual(buffer, "-use_action_slot_item_server", false))
	{
		b_HoldingInspectWeapon[client] = false;
	}
	//Medic E call, its really really delayed it is NOT the same as voicemenu 0 0, this is way faster.
	else if(StrEqual(buffer, "+helpme_server", false))
	{
		//add a delay, so if you call E it doesnt do the voice menu one, though keep the voice menu one for really epic cfg nerds.
		f_MedicCallIngore[client] = GetGameTime() + 0.5;
		
		bool has_been_done = BuildingCustomCommand(client);
		if(has_been_done)
		{
			return Plugin_Handled;
		}
	}
	
//	HINT: there is a - version, which is detected when letting go of the button, its basically a fancy onclientruncmd, although it shouldnt be used really.

	else if(StrEqual(buffer, "+inspect_server", false))
	{
		BuilderMenu(client);
		
		//This is an extra slot, incase you want to use it for anything.
	}
#elseif defined RPG
	if(StrEqual(buffer, "+inspect_server", false))
	{
		TextStore_Inspect(client);
	}
	else if(StrEqual(buffer, "+helpme_server", false))
	{
		//add a delay, so if you call E it doesnt do the voice menu one, though keep the voice menu one for really epic cfg nerds.
		f_MedicCallIngore[client] = GetGameTime() + 1.0;
		RPGCommands_TriggerMedicCall(client);
		return Plugin_Handled;
	}
#endif
	return Plugin_Continue;
}
/*
public Action OnNavCommand(int client, const char[] command, int args)
{
	if(!client && !StrContains(command, "nav", false))
	{
		PrintToServer("[ZR] Reloaded Nav Gamedata");
	}
	return Plugin_Continue;
}
*/
#if defined ZR
public Action OnJoinClass(int client, const char[] command, int args)
{
	
	char Bufferlol[32];
	GetCmdArgString(Bufferlol,sizeof(Bufferlol));
	TFClassType ClassChangeTo = TF2_GetClass(Bufferlol);

	JoinClassInternal(client, ClassChangeTo);
	return Plugin_Handled;
}

void JoinClassInternal(int client, TFClassType ClassChangeTo)
{
	bool FailedInstachange = false;
	if(!client)
		return;

	if(TeutonType[client] != TEUTON_NONE)
		FailedInstachange = true;

	if(dieingstate[client] != 0)
		FailedInstachange = true;
	
	if(!IsPlayerAlive(client))
		FailedInstachange = true;
	
	if(f_TimeUntillNormalHeal[client] > GetGameTime())
		FailedInstachange = true;
		
	if(f_InBattleHudDisableDelay[client] > GetGameTime())
		FailedInstachange = true;

	
	if(ClassChangeTo <= TFClass_Unknown)
	{
		return;
	}

	if(FailedInstachange)
	{
		CurrentClass[client] = ClassChangeTo;
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", ClassChangeTo);
		PrintToChat(client, "You are unable to change classes instantly, it'll be changed later when you respawn.");
		return;
	}
#if defined ZR
	TransferDispenserBackToOtherEntity(client, true);
#endif
	//save clips to not insta reload. lol.
	Clip_SaveAllWeaponsClipSizes(client);
	int Health = GetClientHealth(client);
	float SubjectAbsVelocity[3];
	float clientvec[3];
	float clientveceye[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", clientvec);
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	GetClientEyeAngles(client,clientveceye);
	TF2_SetPlayerClass_ZR(client, ClassChangeTo);
	CurrentClass[client] = ClassChangeTo;
	f_WasRecentlyRevivedViaNonWaveClassChange[client] = GetGameTime() + 0.5;
	f_WasRecentlyRevivedViaNonWave[client] = GetGameTime() + 0.5;
	DHook_RespawnPlayer(client);
	Store_GiveAll(client, Health);
	TeleportEntity(client, clientvec, clientveceye, SubjectAbsVelocity);
	RemoveInvul(client);
	RequestFrames(Removeinvul1frame, 10, EntIndexToEntRef(client));
	PrintToChat(client, "You changed classes immedietely!");
	f_InBattleHudDisableDelay[client] = GetGameTime() + 1.0; //little cooldown to prevent bug
}
#endif

#if defined RPG

bool RPGCommands_TriggerMedicCall(int client)
{
	bool CanTransform = RPGCore_ClientCanTransform(client);
	if(CanTransform)
		TransformButton(client);
	
	return CanTransform;
}
public Action OnJoinClass(int client, const char[] command, int args)
{
	if(client && GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"))
		return Plugin_Handled;
	
	return Plugin_Continue;
}
#endif

public void Removeinvul1frame(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		RemoveInvul(client);
	}
}
public Action OnAutoTeam(int client, const char[] command, int args)
{
	if(client)
	{
		if(IsFakeClient(client))
		{
			SetTeam(client, view_as<int>(TFTeam_Blue));
			return Plugin_Handled;
		}
#if defined ZR
		Queue_JoinTeam(client);
		return Plugin_Continue;
#else
		SetTeam(client, view_as<int>(TFTeam_Red));
		ShowVGUIPanel(client, "class_red");
#endif
	}
	return Plugin_Handled;
}

public Action OnBuildCmd(int client, const char[] command, int args)
{
	return Plugin_Handled;
}

public Action OnDropItem(int client, const char[] command, int args)
{
#if defined ZR
	Escape_DropItem(client);
#endif
	return Plugin_Handled;
}

public Action OnTaunt(int client, const char[] command, int args)
{
#if defined ZR
	if(dieingstate[client] != 0)
	{
		return Plugin_Handled;
	}
#endif
	return Plugin_Continue;
}

public Action OnSayCommand(int client, const char[] command, int args)
{
	
#if defined ZR
	if(Encyclopedia_SayCommand(client))
		return Plugin_Handled;

	if(Store_SayCommand(client))
		return Plugin_Handled;
		
	if(Rebel_Rename(client))
		return Plugin_Handled;
#endif
	
#if defined RPG
	if(Editor_SayCommand(client))
		return Plugin_Handled;
	
	if(TextStore_SayCommand(client))
		return Plugin_Handled;
	
	if(Tinker_SayCommand(client))
		return Plugin_Handled;
#endif

	return Plugin_Continue;
}

#if defined ZR || defined RPG
public Action Command_Voicemenu(int client, const char[] command, int args)
{
	if(client && args == 2 && IsPlayerAlive(client))
	{
		char arg[4];
		GetCmdArg(1, arg, sizeof(arg));
		if(arg[0] == '0')
		{
			GetCmdArg(2, arg, sizeof(arg));
			if(arg[0] == '0')
			{
#if defined ZR
				if(TeutonType[client] != TEUTON_NONE)
					return Plugin_Handled;
#endif

				if(f_MedicCallIngore[client] < GetGameTime())
				{
#if defined RPG
					RPGCommands_TriggerMedicCall(client);
#endif
#if defined ZR
					f_MedicCallIngore[client] = GetGameTime() + 0.5;
					BuildingCustomCommand(client);
#endif
					return Plugin_Handled;
				}
				/*
				//Block medic call.
				return Plugin_Handled;
				*/
			}
		}
	}
	return Plugin_Continue;
}
#endif



bool DoInteractKeyLogic(float angles[3], int client)
{
	bool Success = false;
	f_ClientReviveDelayReviveTime[client] = GetGameTime() + 1.0;
#if defined ZR
	if(angles[0] < -70.0)
	{
		int entity = EntRefToEntIndex(Building_Mounted[client]);
		if(IsValidEntity(entity))
		{
			Object_Interact(client, GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"), client);
		}
	}
#endif
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	StartPlayerOnlyLagComp(client, true);
	if(InteractKey(client, weapon_holding, true))
		Success = true;

	EndPlayerOnlyLagComp(client);
	return Success;
}