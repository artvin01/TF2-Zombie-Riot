#pragma semicolon 1
#pragma newdecls required

void Events_PluginStart()
{
	HookEvent("teamplay_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("post_inventory_application", OnPlayerResupply, EventHookMode_Post);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("teamplay_broadcast_audio", OnBroadcast, EventHookMode_Pre);
	HookEvent("teamplay_win_panel", OnWinPanel, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre);
	HookEvent("player_connect_client", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("deploy_buff_banner", OnBannerDeploy, EventHookMode_Pre);
	HookEvent("teams_changed", EventHook_TeamsChanged, EventHookMode_PostNoCopy);
#if defined ZR
	HookEvent("teamplay_round_win", OnRoundEnd, EventHookMode_Pre);
	HookEvent("mvm_begin_wave", OnSetupFinished, EventHookMode_PostNoCopy);
	HookEvent("mvm_wave_failed", OnWinPanel, EventHookMode_Pre);
	HookEvent("mvm_mission_complete", OnWinPanel, EventHookMode_Pre);
	HookEvent("restart_timer_time", OnRestartTimer, EventHookMode_Pre);
	HookEvent("arrow_impact", EventOverride_ArrowImpact, EventHookMode_Pre);

#endif	
	
	HookUserMessage(GetUserMessageId("SayText2"), Hook_BlockUserMessageEx, true);
	
	HookEntityOutput("logic_relay", "OnTrigger", OnRelayTrigger);
}

#if defined ZR

public Action EventOverride_ArrowImpact(Event event, const char[] name, bool dontBroadcast)
{
	int AttachedEntity = event.GetInt("attachedEntity");
	int ShooterEntity = event.GetInt("shooter");
	int WhatBoneAttached = event.GetInt("boneIndexAttached");
	float BonePosition[3];
	BonePosition[0] = event.GetFloat("bonePositionX");
	BonePosition[1] = event.GetFloat("bonePositionY");
	BonePosition[2] = event.GetFloat("bonePositionZ");
	float BoneAngles[3];
	BoneAngles[0] = event.GetFloat("boneAnglesX");
	BoneAngles[1] = event.GetFloat("boneAnglesY");
	BoneAngles[2] = event.GetFloat("boneAnglesZ");
	int ProjectileType = event.GetInt("projectileType");
	bool IsCrit = event.GetBool("isCrit");
	event.BroadcastDisabled = true;
	EventOverride_ArrowImpact_ZRSeperate(AttachedEntity, ShooterEntity, WhatBoneAttached, BonePosition, BoneAngles, ProjectileType, IsCrit);
	
	return Plugin_Changed;
}

void EventOverride_ArrowImpact_ZRSeperate(int AttachedEntity, int ShooterEntity, int WhatBoneAttached,
float BonePosition[3], float BoneAngles[3], int ProjectileType, bool IsCrit)
{
	Event event = CreateEvent("arrow_impact", true);

	event.SetInt("attachedEntity", AttachedEntity);
	event.SetInt("shooter", ShooterEntity);
	event.SetInt("boneIndexAttached", WhatBoneAttached);
	event.SetFloat("bonePositionX", BonePosition[0]);
	event.SetFloat("bonePositionY", BonePosition[1]);
	event.SetFloat("bonePositionZ", BonePosition[2]);
	event.SetFloat("boneAnglesX", BoneAngles[0]);
	event.SetFloat("boneAnglesY", BoneAngles[1]);
	event.SetFloat("boneAnglesZ", BoneAngles[2]);
	event.SetInt("projectileType", ProjectileType);
	event.SetBool("isCrit", IsCrit);
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && b_EnableClutterSetting[client])
			event.FireToClient(client);
	}
}
#endif	
public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
#if defined ZR
	DeleteShadowsOffZombieRiot();
	EventRoundStartMusicFilter();
	b_GameOnGoing = true;
	
	
	LastMann = false;
	Ammo_Count_Ready = 0;
	Zero(Ammo_Count_Used);
	Zero(Healing_done_in_total);
	Zero(Damage_dealt_in_total);
	Zero(Resupplies_Supplied);
	Zero(i_BarricadeHasBeenDamaged);
	Zero(i_ExtraPlayerPoints);
	WaveStart_SubWaveStart(GetGameTime());
	ResetWaldchLogic();
	CurrentGibCount = 0;
	for(int client=1; client<=MaxClients; client++)
	{
		i_AmountDowned[client] = 0;
		Building_ClientDisconnect(client);
		for(int i; i<Ammo_MAX; i++)
		{
			CurrentAmmo[client][i] = CurrentAmmo[0][i];
		}	
	}
	
	CreateMVMPopulator();
	Zero(b_BobsCuringHand_Revived);
	
	Escape_RoundStart();
	Waves_RoundStart(true);
	Blacksmith_RoundStart();
	Merchant_RoundStart();
	Flametail_RoundStart();
	BlacksmithBrew_RoundStart();
	BlacksmithGrill_RoundStart();
	Zealot_RoundStart();
	Drops_ResetChances();
	NPCStats_HandlePaintedWearables();

	for(int client=1; client<=MaxClients; client++)
	{
		Armor_Charge[client] = 0; //reset armor to 0
	}
	ReviveAll();
	if(RoundStartTime > GetGameTime())
	{
		//This asumes it already picked a map, get loadouts while not redoing map logic!
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client))
				Loadout_DatabaseLoadFavorite(client);
		}
		return;
	}
	
	Waves_SetReadyStatus(2);
	RoundStartTime = FAR_FUTURE;
	//FOR ZR
	char mapname[64];
	GetMapName(mapname, sizeof(mapname));
	
	KeyValues kv = Configs_GetMapKv(mapname);
	
	DeleteStatusEffectsFromAll();
	Waves_MapEnd();
	Waves_SetupVote(kv);
	Waves_SetupMiniBosses(kv);
	delete kv;
#endif

#if defined RPG
	Zones_RoundStart();
#endif

#if defined RPG || defined RTS
	ServerCommand("mp_waitingforplayers_cancel 1");
#endif
}

#if defined ZR
public void OnSetupFinished(Event event, const char[] name, bool dontBroadcast)
{
	if(CvarAutoSelectDiff.BoolValue && !Waves_Started())
	{
		//Do this only once!
		char mapname[64];
		GetMapName(mapname, sizeof(mapname));
		
		KeyValues kv = Configs_GetMapKv(mapname);
		Waves_SetupVote(kv, true);
		delete kv;
	}
	
	for(int client=1; client<=MaxClients; client++)
	{
		SetMusicTimer(client, 0);
	}
	BuildingVoteEndResetCD();
	Waves_SetReadyStatus(0);
	Waves_Progress();
}
#endif

public Action OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(event.GetBool("autoteam"))
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if(client)
		{
			SetTeam(client, 3);
			OnAutoTeam(client, name, 0);
		}
	}
	
	if(event.GetBool("silent"))
		return Plugin_Continue;
	
	event.BroadcastDisabled = true;
	return Plugin_Continue;
}

public Action OnBannerDeploy(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Handled;
}

public Action OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	if(!event.GetBool("bot"))
		return Plugin_Continue;
	
	event.BroadcastDisabled = true;
	return Plugin_Changed;
}

#if defined ZR
public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	MVMHud_Disable();
	GameRules_SetProp("m_iRoundState", RoundState_TeamWin);
	f_FreeplayDamageExtra = 1.0;
	b_GameOnGoing = false;
	GlobalExtraCash = 0;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Escape_DropItem(client);
			Damage_dealt_in_total[client] = 0.0;
			Resupplies_Supplied[client] = 0;
			i_BarricadeHasBeenDamaged[client] = 0;
			i_PlayerDamaged[client] = 0;
			CashReceivedNonWave[client] = 0;
			Healing_done_in_total[client] = 0;
			Ammo_Count_Used[client] = 0;
			Armor_Charge[client] = 0;
			Building_ResetRewardValues(client);
		}
	}

	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsClientInGame(client_check) && TeutonType[client_check] != TEUTON_WAITING)
			TeutonType[client_check] = 0;
	}
	
	DeleteStatusEffectsFromAll();
	Store_Reset();
	Waves_RoundEnd();
	Escape_RoundEnd();
	Rogue_RoundEnd();
	Construction_RoundEnd();
	BetWar_RoundEnd();
	CurrentGame = 0;
	RoundStartTime = 0.0;
	if(event != INVALID_HANDLE && event.GetInt("team") == 3)
	{
		//enemy team won due to timer or something else.
		ZR_NpcTauntWin();
	}
	return Plugin_Continue;
}
#endif

public void OnPlayerResupply(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client)
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDEHUD_BUILDING_STATUS | HIDEHUD_CLOAK_AND_FEIGN);
#if defined ZR
		TransferDispenserBackToOtherEntity(client, true);
#endif
#if defined RPG
		TextStore_DepositBackpack(client, false, Level[client] < 5);
#endif

		ForcePlayerCrouch(client, false);

		TF2_RemoveAllWeapons(client); //Remove all weapons. No matter what.
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
		SetVariantString("");
	  	AcceptEntityInput(client, "SetCustomModelWithClassAnimations");

		CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));

		ViewChange_DeleteHands(client);
		ViewChange_UpdateHands(client, CurrentClass[client]);
		TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);

		if(b_HideCosmeticsPlayer[client])
		{
		  	int entity = MaxClients+1;
			while(TF2_GetWearable(client, entity))
			{
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
			}
		}
		Stocks_ColourPlayernormal(client);

#if defined ZR
		//DEFAULTS
		if(dieingstate[client] == 0)
		{
			b_ThisEntityIgnored[client] = false;
		}
	  	//DEFAULTS
		
		if(!b_AntiLateSpawn_Allow[client])
			if(TeutonType[client] == TEUTON_NONE)
				TeutonType[client] = TEUTON_DEAD;
		if(WaitingInQueue[client])
			TeutonType[client] = TEUTON_WAITING;

		if(i_ClientHasCustomGearEquipped[client])
		{
			SDKCall_GiveCorrectAmmoCount(client);

			ViewChange_PlayerModel(client);
			ViewChange_Update(client);
			return;
		}
		
		if(TeutonType[client] != TEUTON_NONE)
		{
			FakeClientCommand(client, "menuselect 0");
			SDKHook(client, SDKHook_GetMaxHealth, OnTeutonHealth);
			SetEntityRenderMode(client, RENDER_NONE);
		//	SetEntityRenderColor(client, 255, 255, 255, 0);
			
			int entity = MaxClients+1;
			while(TF2_GetWearable(client, entity))
			{
				TF2_RemoveWearable(client, entity);
			}
			ViewChange_PlayerModel(client);
			ViewChange_Update(client);
			
			TF2Attrib_RemoveAll(client);
			Attributes_Set(client, 68, -1.0);
			SetVariantString(COMBINE_CUSTOM_2_MODEL);
	  		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
			
#if defined ZR
			SDKUnhook(client, SDKHook_SetTransmit, TeutonViewOnly);
			SDKHook(client, SDKHook_SetTransmit, TeutonViewOnly);
#endif
	   		b_ThisEntityIgnored[client] = true;
			
	   		int weapon_index = Store_GiveSpecificItem(client, "Teutonic Longsword");
			SetVariantInt(0);
			AcceptEntityInput(client, "SetBodyGroup");
			if(!b_HasBeenHereSinceStartOfWave[client])
			{
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", FAR_FUTURE);
				SetEntPropFloat(weapon_index, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
			}
			//apply model correctly.


	   		ViewChange_Switch(client, weapon_index, "tf_weapon_sword");

	   		TF2Attrib_RemoveAll(weapon_index);
	   		
	   		float damage = 1.0;
			
			if(TeutonType[client] == TEUTON_WAITING)
			{
				damage *= 0.65;
			}
			
	   		Attributes_Set(weapon_index, 2, damage);
	   		Attributes_Set(weapon_index, 264, 0.0);
	   		Attributes_Set(weapon_index, 263, 0.0);
	   		Attributes_Set(weapon_index, 6, 1.2);
	   		Attributes_Set(weapon_index, 412, 0.0);
			
	   		Attributes_Set(weapon_index, 443, 1.25);
	   		Attributes_Set(weapon_index, 442, 1.25);

	   		TFClassType ClassForStats = WeaponClass[client];
	   		
	   		Attributes_Set(weapon_index, 107, RemoveExtraSpeed(ClassForStats, 330.0));
	   		Attributes_Set(weapon_index, 476, 0.0);
	   		SetEntityCollisionGroup(client, 1);
	   		SetEntityCollisionGroup(weapon_index, 1);
	   		
			if(!view_as<bool>(Store_HasNamedItem(client, "Shadow's Letter")))
			{
				int wearable;
				
				wearable = GiveWearable(client, 30727);
				
				SetEntPropFloat(wearable, Prop_Send, "m_flModelScale", 0.9);
				
				wearable = GiveWearable(client, 30969);
				
				SetEntPropFloat(wearable, Prop_Send, "m_flModelScale", 1.25);
	   			SetEntPropFloat(weapon_index, Prop_Send, "m_flModelScale", 0.8);
			}
			else
			{
				
	   			SetEntPropFloat(weapon_index, Prop_Send, "m_flModelScale", 0.01);
				f_WeaponSizeOverride[weapon_index] = 0.01;
			}
	   		
	   		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.7);
	   		
			SDKCall_GiveCorrectAmmoCount(client);
	   		
		}
		else
		{
			int entity = MaxClients+1;
			while(TF2_GetWearable(client, entity))
			{
				switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
				{
					case 57, 131, 133, 231, 405, 406, 444, 608, 642, 1099, 1144:
						TF2_RemoveWearable(client, entity);
				}
			}
			
			ViewChange_PlayerModel(client);
			ViewChange_Update(client);
			Store_ApplyAttribs(client);
			
			if(dieingstate[client])
			{
			}
			else
			{
				Store_GiveAll(client, Waves_GetRoundScale()>1 ? 50 : 300); //give 300 hp instead of 200 in escape.
			}
			
			SDKCall_GiveCorrectAmmoCount(client);
			
			//PrintHintText(client, "%T", "Open Store", client);
		}
#endif

#if defined RPG
		int entity = MaxClients+1;
		while(TF2_GetWearable(client, entity))
		{
			switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
			{
				case 57, 131, 133, 231, 405, 406, 444, 608, 642, 1099, 1144:
					TF2_RemoveWearable(client, entity);
			}
		}
		
		ViewChange_PlayerModel(client);
		ViewChange_Update(client);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, 1);
		
		SetAmmo(client, 1, 9999);
		SetAmmo(client, 2, 9999);
		SetAmmo(client, Ammo_Metal, 9999);
		SetAmmo(client, Ammo_Jar, 1);
		for(int i=Ammo_Pistol; i<Ammo_MAX; i++)
		{
			SetAmmo(client, i, 9999);
		}
		//In RPG Ammo is infinite and used in a different way.
		UpdateLevelAbovePlayerText(client);

		RequestFrame(UpdateHealthFrame, userid);
#endif
	}
}

#if defined RPG
public void UpdateHealthFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
}
#endif

#if defined ZR
public Action OnTeutonHealth(int client, int &health)
{
	if(TeutonType[client])
	{
		SetEntityHealth(client, 1);
		health = 1;
		return Plugin_Changed;
	}
	
	SDKUnhook(client, SDKHook_GetMaxHealth, OnTeutonHealth);
	return Plugin_Continue;
}
#endif

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client)
	{
		
#if defined ZR
		Waves_PlayerSpawn(client);
		Vehicle_PlayerSpawn(client);
#endif

#if defined ZR || defined RPG
		Thirdperson_PlayerSpawn(client);
#endif
	}
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client)
		return Plugin_Continue;
	
	// Dead Ringer doesn't exist!!

#if defined ZR || defined RPG
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);
#endif

#if defined ZR
	KillFeed_Show(client, event.GetInt("inflictor_entindex"), EntRefToEntIndex(LastHitRef[client]), dieingstate[client] ? -69 : 0, event.GetInt("weaponid"), event.GetInt("damagebits"));
#elseif defined RPG
	KillFeed_Show(client, event.GetInt("inflictor_entindex"), EntRefToEntIndex(LastHitRef[client]), 0, event.GetInt("weaponid"), event.GetInt("damagebits"));
#endif

#if defined ZR
	UnequipDispenser(client, true);
	ArmorDisplayClient(client, true);
	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(-1);
	Update_Ammo(pack);
	Escape_DropItem(client);
	Armor_Charge[client] = 0; //reset to 0 on death

	//Incase they die, do suit!
	if(!Rogue_Mode())
	{
		i_CurrentEquippedPerk[client] = 0;
		UpdatePerkName(client);
	}
		
	i_HealthBeforeSuit[client] = 0;
	f_HealthBeforeSuittime[client] = GetGameTime() + 0.25;
	i_ClientHasCustomGearEquipped[client] = false;
	UnequipQuantumSet(client);
//	CreateTimer(0.0, QuantumDeactivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE); //early cancel out!, save the wearer!
	//

	Citizen_PlayerDeath(client);
	Bob_player_killed(event, name, dontBroadcast);
	Skulls_PlayerKilled(client);
	// Save current uber.
	ClientSaveUber(client);
	SDKHooks_UpdateMarkForDeath(client, true);
	PurnellDeathsound(client);
	Vehicle_Exit(client, true);
#endif

#if defined RPG
	TextStore_DepositBackpack(client, true);
	UpdateLevelAbovePlayerText(client, true);
	De_TransformClient(client);
#endif

#if defined ZR || defined RPG
	Store_WeaponSwitch(client, -1);
	RequestFrame(CheckAlivePlayersforward, client); //REQUEST frame cus isaliveplayer doesnt even get applied yet in this function instantly, so wait 1 frame
#endif
	
	event.BroadcastDisabled = true;
	return Plugin_Changed;
}

public Action OnBroadcast(Event event, const char[] name, bool dontBroadcast)
{
	static char sound[PLATFORM_MAX_PATH];
	event.GetString("sound", sound, sizeof(sound));
	if(!StrContains(sound, "Game.Your", false) || !StrContains(sound, "Game.Stalemate", false) || !StrContains(sound, "Announcer.", false))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action OnWinPanel(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Handled;
}

public Action OnRestartTimer(Event event, const char[] name, bool dontBroadcast)
{
	if(event.GetInt("time") != 9)
		return Plugin_Continue;
	
	event.BroadcastDisabled = true;
	return Plugin_Changed;
}

public Action Hook_BlockUserMessageEx(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	char message[32];
	msg.ReadByte();
	msg.ReadByte();
	msg.ReadString(message, sizeof(message));
	
	if(strcmp(message, "#TF_Name_Change") == 0)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action OnRelayTrigger(const char[] output, int entity, int caller, float delay)
{
	char name[32];
	GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
	if(!StrContains(name, "nav_reloader", false)) //Sometimes blocking shit doesnt work.
	{
		UpdateBlockedNavmesh();
	}
#if defined ZR
	else if(!StrContains(name, "zr_respawn", false))
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(!b_AntiLateSpawn_Allow[client])
				continue;
			if(IsClientInGame(client))
			{
				DoOverlay(client, "", 2);
				if(GetClientTeam(client)==2)
				{
					if(!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD)
					{
						DHook_RespawnPlayer(client);
					}
					else if(dieingstate[client] > 0)
					{
						dieingstate[client] = 0;
						Store_ApplyAttribs(client);
						SDKCall_SetSpeed(client);
						Stocks_ColourPlayernormal(client);
						SetEntityCollisionGroup(client, 5);
						SetEntityHealth(client, SDKCall_GetMaxHealth(client));
					}
				}
			}
		}
		
		CheckAlivePlayers();
	}
	else if(!StrContains(name, "zr_cash_", false))
	{
		char buffers[4][12];
		ExplodeString(name, "_", buffers, sizeof(buffers), sizeof(buffers[]));
		
		int cash = StringToInt(buffers[2]);
		CurrentCash += cash;
		PrintToChatAll("Gained %d cash!", cash);
	}
#endif

	// DO NOT DO 
	// return Plugin_Handled;!!!!!!
	//This breaks maps.
	return Plugin_Continue;
}

static float DontRepeatSameFrame;
static void EventHook_TeamsChanged(Event event, const char[] name, bool dontBroadcast)
{
	if(DontRepeatSameFrame == GetGameTime())
		return;
	
	DontRepeatSameFrame = GetGameTime();
	RequestFrame(CheckAndValidifyTeam);
	//No way to seemingly detect
	//PrintToChatAll("EventHook_TeamsChanged");
}

void CheckAndValidifyTeam()
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && TeamNumber[client] <= 4) //If their team is customly set, dont do this
			TeamNumber[client] = GetEntProp(client, Prop_Data, "m_iTeamNum");
	}
}

#if defined ZR
public Action TeutonViewOnly(int teuton, int client)
{
	if(TeutonType[teuton] == TEUTON_NONE)
	{
		SDKUnhook(teuton, SDKHook_SetTransmit, TeutonViewOnly);
		return Plugin_Continue;
	}

	//incase they love it.
	if(b_EnableClutterSetting[client])
		return Plugin_Continue;

	if(TeutonType[client] == TEUTON_NONE)
		return Plugin_Handled;
	
	return Plugin_Continue;
	
}
#endif


/*

	Translations are:
	"Setup Chat Tip 1"
*/
void ChatSetupTip()
{
	if(AntiSpamTipGive > GetGameTime())
	{
		return;
	}
	AntiSpamTipGive = GetGameTime() + 30.0;
	CreateTimer(GetRandomFloat(10.0, 15.0), ChatSetupTipTimer, _, TIMER_FLAG_NO_MAPCHANGE); //early cancel out!, save the wearer!
}


public Action ChatSetupTipTimer(Handle TimerHandle)
{
	char TipText[255];
	static int MaxEntries;
	if(!MaxEntries)
	{
		MaxEntries++;
		Format(TipText, sizeof(TipText), "Setup Chat Tip %i", MaxEntries);
		while(TranslationPhraseExists(TipText))
		{
			MaxEntries++;
			Format(TipText, sizeof(TipText), "Setup Chat Tip %i", MaxEntries);
		}
	}
	Format(TipText, sizeof(TipText), "Setup Chat Tip %i", GetRandomInt(1,MaxEntries- 1));
	SPrintToChatAll("{green}TIP:{snow} %t",TipText);
	return Plugin_Stop;
}